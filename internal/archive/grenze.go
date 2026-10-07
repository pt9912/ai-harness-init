package archive

import (
	"fmt"
	"os"
	"path/filepath"
	"regexp"
	"sort"
	"strings"
)

// Abstammung traegt, was der Aufrufer aus git liest, als WERTE: der Lauf
// entscheidet die Klasse, `git` startet er nicht (ADR-0081 Festlegung 5). Ein
// leerer Wert ist zulaessig — liegt keine Ergebnisnotiz in done/, liest die
// Operation nichts davon.
type Abstammung struct {
	// Flach ist die Antwort von `git rev-parse --is-shallow-repository`.
	Flach bool
	// Add nennt je repo-relativem Pfad seinen Add-Commit
	// (`git log -1 --no-renames --diff-filter=A --format=%H -- <pfad>`, ADR-0081
	// Festlegung 1). Ein Pfad ohne Eintrag hat keinen.
	Add map[string]string
	// Vorfahren nennt je Grenz-Commit G die Menge der Commits C mit C <= G,
	// G eingeschlossen (`git rev-list G`).
	Vorfahren map[string]map[string]bool
}

// ergebnisMuster trifft die Ergebnisnotiz einer Welle in done/. Ihre
// Add-Commits sind die Grenz-Commits (ADR-0081 Festlegung 1).
var ergebnisMuster = regexp.MustCompile(`^welle-.+-results\.md$`)

// AbstammungsPfade nennt die Pfade, deren Abstammung die Operation liest: die
// Ergebnisnotizen in done/ (ihre Add-Commits sind die Grenz-Commits) und die
// flachen Slices, deren Kopf-Feld "ohne Welle" sagt. Ohne Ergebnisnotiz sind
// beide Listen leer — dann braucht kein Lauf einen Grenz-Commit. Der Aufrufer
// liest fuer genau diese Pfade und waehlt selbst nichts aus.
func AbstammungsPfade(root string) (ergebnisse, slices []string, err error) {
	eintraege, err := os.ReadDir(filepath.Join(root, filepath.FromSlash(doneDir)))
	if err != nil {
		return nil, nil, fmt.Errorf("%s lesen: %w", doneDir, err)
	}
	for _, e := range eintraege {
		if !e.IsDir() && ergebnisMuster.MatchString(e.Name()) {
			ergebnisse = append(ergebnisse, doneDir+"/"+e.Name())
		}
	}
	if len(ergebnisse) == 0 {
		return nil, nil, nil
	}
	for _, e := range eintraege {
		name := e.Name()
		if e.IsDir() || !strings.HasPrefix(name, "slice-") || !strings.HasSuffix(name, ".md") {
			continue
		}
		rel := doneDir + "/" + name
		inhalt, rerr := os.ReadFile(filepath.Join(root, filepath.FromSlash(rel)))
		if rerr != nil {
			return nil, nil, fmt.Errorf("%s lesen: %w", rel, rerr)
		}
		if istWellenlos(WelleFeld(string(inhalt))) {
			slices = append(slices, rel)
		}
	}
	sort.Strings(ergebnisse)
	sort.Strings(slices)
	return ergebnisse, slices, nil
}

// vorfahr sagt S <= G: S ist Vorfahr von G oder gleich G.
// Gedeckt von TestGrenzeAltbestandNimmtNurSlicesVorEinerGrenze;
// test/mutations/542-archive-welle-go-grenze-vergleich-umgekehrt.sh kehrt den
// Vergleich um.
func (a Abstammung) vorfahr(s, g string) bool {
	return a.Vorfahren[g][s]
}

// gehoert entscheidet, ob ein wellenloser Slice mit Add-Commit s in diesen Lauf
// gehoert. `o` ist der Add-Commit der eigenen Ergebnisnotiz; leer heisst
// Altbestand-Lauf.
//
// Altbestand (ADR-0081 Festlegung 2): s <= G fuer mindestens einen Grenz-Commit.
// Welle (Festlegung 3): s <= o, und kein anderer Grenz-Commit G mit s <= G ist
// echter Vorfahr von o — der Slice gehoert der FRUEHESTEN Closure in seiner
// Abstammung. Parallele Grenz-Commits (keiner Vorfahr des anderen) schliessen
// einander nicht aus; der Slice gehoert dann beiden Laeufen.
func gehoert(a Abstammung, s, o string, grenzen []string) bool {
	if o == "" {
		for _, g := range grenzen {
			if a.vorfahr(s, g) {
				return true
			}
		}
		return false
	}
	if !a.vorfahr(s, o) {
		return false
	}
	for _, g := range grenzen {
		if g != o && a.vorfahr(g, o) && a.vorfahr(s, g) {
			return false
		}
	}
	return true
}

// grenzeAnwenden zieht die Grenze aus der Commit-Abstammung: die wellenlosen
// Slices, die nicht in diesen Lauf gehoeren, wandern nach NachGrenze. Liegt
// keine Ergebnisnotiz in done/, aendert sie nichts. Ein Slice oder eine
// Ergebnisnotiz ohne Add-Commit steht in OhneAdd und bleibt eingeordnet, wie er
// war — die Sperre `add-commit` haelt den Lauf an. Ohne eigene Ergebnisnotiz
// (Welle-Lauf) ordnet sie nichts um; die Sperre `ergebnisnotiz` steht dann.
func (b *Bestand) grenzeAnwenden(root string, a Abstammung) error {
	ergebnisse, _, err := AbstammungsPfade(root)
	if err != nil || len(ergebnisse) == 0 {
		return err
	}
	b.GrenzeAktiv = true
	b.Flach = a.Flach
	var grenzen []string
	for _, p := range ergebnisse {
		if c := a.Add[p]; c != "" {
			grenzen = append(grenzen, c)
		} else {
			b.OhneAdd = append(b.OhneAdd, p)
		}
	}
	o := ""
	if b.Welle != AltbestandSchluessel {
		if o = a.Add[b.Ergebnis]; o == "" {
			return nil
		}
	}
	var behalten []string
	for _, s := range b.Wellenlose {
		c := a.Add[s]
		switch {
		case c == "":
			b.OhneAdd = append(b.OhneAdd, s)
			behalten = append(behalten, s)
		case gehoert(a, c, o, grenzen):
			behalten = append(behalten, s)
		default:
			b.NachGrenze = append(b.NachGrenze, s)
		}
	}
	b.Wellenlose = behalten
	return nil
}

// grenzSperren traegt ADR-0081 Festlegung 4: unaufloesbare Historie sperrt
// fail-closed, und zwar nur dort, wo ein Grenz-Commit gebraucht wird (eine
// Ergebnisnotiz liegt in done/).
// Gedeckt von TestGrenzeSperrtImFlachenKlon und TestGrenzeSperrtOhneAddCommit.
func grenzSperren(b Bestand) []Sperre {
	if !b.GrenzeAktiv {
		return nil
	}
	var out []Sperre
	if b.Flach {
		out = append(out, Sperre{
			Kennung: "flacher-klon",
			Grund:   "das Repo ist ein flacher Klon — die Abstammung der Grenz-Commits ist nicht aufloesbar",
			Zeilen:  []string{"im flachen Klon erscheint der Graft-Commit als Add-Commit jeder Datei; erst die volle Historie holen (git fetch --unshallow)"},
		})
	}
	if len(b.OhneAdd) > 0 {
		out = append(out, Sperre{
			Kennung: "add-commit",
			Grund:   fmt.Sprintf("%d Datei(en) ohne Add-Commit — die Grenze ist fuer sie nicht bestimmbar", len(b.OhneAdd)),
			Zeilen:  b.OhneAdd,
		})
	}
	return out
}
