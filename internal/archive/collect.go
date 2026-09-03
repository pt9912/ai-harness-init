// Package archive sagt, was die Archivierung einer geschlossenen Welle taete:
// welche Zeitdokumente sie einsammelte, welche fail-closed-Ausgaenge ihr im Weg
// stuenden und welche Dateien einen Verweis auf etwas Bewegtes tragen.
//
// ABGRENZUNG, und sie ist die tragende Eigenschaft dieses Pakets: es SCHREIBT
// nichts — kein Move, kein Zip, kein Stub, kein Commit. Jede Funktion liest den
// Baum und rechnet; jede ist ueber einem synthetischen Verzeichnis pruefbar,
// ohne ein Repo zu bewegen.
//
// RANG-ZEIGER: was archiviert wird, was liegen bleibt und in welcher Form,
// steht im Baseline-Regelwerk (modul-06-roadmap.md, §Wellen-Closure-Prozedur,
// Schritt 4). Dass die Operation ein Unterkommando des Produkt-Binaers ist und
// welche drei Abnahme-Kriterien sie schuldet, steht in ADR-0033.
package archive

import (
	"errors"
	"fmt"
	"io/fs"
	"os"
	"path/filepath"
	"regexp"
	"sort"
	"strings"
)

// Die drei Klassen, in die das Kopf-Feld `**Welle:**` einer Slice-Datei faellt.
// Die Menge ist geschlossen: was nicht Mitglied und nicht wellenlos ist, bleibt
// liegen.
const (
	Mitglied  = "mitglied"
	Wellenlos = "wellenlos"
	Fremd     = "fremd"
)

const (
	planningDir = "docs/plan/planning"
	doneName    = "done"
	doneDir     = planningDir + "/" + doneName
	reviewsDir  = "docs/reviews"
	archivName  = "archiv.zip"
)

// WelleFeld liefert den Rohtext hinter dem Kopf-Feld `**Welle:**` aus der ERSTEN
// Zeile, die es traegt. Leer, wenn die Datei kein solches Feld fuehrt — und ein
// fehlendes Feld ist keine dritte Klasse, sondern faellt unten auf Fremd.
func WelleFeld(inhalt string) string {
	for _, zeile := range strings.Split(inhalt, "\n") {
		if rest, ok := strings.CutPrefix(zeile, "**Welle:**"); ok {
			return strings.TrimSpace(rest)
		}
	}
	return ""
}

// KlasseVon ordnet den Wert des Kopf-Felds `**Welle:**` fuer diese Welle ein:
// Mitglied (das Feld nennt sie) · Wellenlos (das Feld sagt "ohne Welle") ·
// Fremd (eine andere Welle, oder gar keine Angabe).
//
// Die drei Zweige sind je einzeln bewacht — TestKlasseVonMitgliedNenntDieWelle,
// TestKlasseVonWellenlosOhneWelle und TestKlasseVonFremdBleibtLiegen —, und die
// Faelle test/mutations/234…236 nehmen je einen davon weg.
func KlasseVon(feld, welleID string) string {
	if nenntWelle(feld, welleID) {
		return Mitglied
	}
	if istWellenlos(feld) {
		return Wellenlos
	}
	return Fremd
}

// nenntWelle vergleicht an einer ZIFFERN-Grenze: "welle-02" trifft die Langform
// "welle-02-fetch-und-readme", "welle-1" trifft "welle-14" nicht. Links steht
// der Bindestrich mit in der Ausschluss-Klasse, weil Wellen-Kennungen einen
// tragen. Eine leere Kennung trifft nichts — sonst waere jedes Feld ein Treffer.
func nenntWelle(feld, welleID string) bool {
	if welleID == "" {
		return false
	}
	re := regexp.MustCompile(`(^|[^A-Za-z0-9_-])` + regexp.QuoteMeta(welleID) + `([^0-9]|$)`)
	return re.MatchString(feld)
}

// istWellenlos trifft die Kopf-Form "ohne Welle" am Feld-ANFANG. Was dahinter
// steht, ist Einordnungs-Prosa und geht die Klasse nichts an.
func istWellenlos(feld string) bool {
	return regexp.MustCompile(`^ohne Welle([^A-Za-z]|$)`).MatchString(feld)
}

// SliceNummer liest die Slice-Nummer aus einem Dateinamen, MIT dem
// Buchstaben-Suffix, den ein Re-Schnitt vergibt ("slice-170-titel.md" -> "170",
// "slice-001a-cli-skeleton.md" -> "001a"). Der Suffix gehoert zur Identitaet: er
// traegt die Grenze, an der die Review-Reports eingesammelt werden. Leer, wenn
// der Name keine Slice-Kennung traegt.
func SliceNummer(basename string) string {
	m := regexp.MustCompile(`^slice-([0-9]+[A-Za-z]*)`).FindStringSubmatch(basename)
	if m == nil {
		return ""
	}
	return m[1]
}

// ReviewTrifft sagt, ob ein Review-Report zu dieser Slice-Nummer gehoert. Die
// Grenze entscheidet, nicht der Glob: hinter der Nummer darf kein Buchstabe und
// keine Ziffer stehen, sonst zoege "slice-001" die Reports von "slice-001a" mit
// — und liegen die zwei Haelften eines Re-Schnitts in verschiedenen Wellen,
// loeschte die erste Archivierung die Reports der zweiten.
// Gedeckt von TestReviewTrifftSuffixGrenze.
func ReviewTrifft(name, nummer string) bool {
	if nummer == "" {
		return false
	}
	re := regexp.MustCompile(`slice-` + regexp.QuoteMeta(nummer) + `([^0-9A-Za-z]|$)`)
	return re.MatchString(name)
}

// Bestand ist, was eine Archivierung dieser Welle anfasste — Pfade repo-relativ
// und sortiert. Die Struktur urteilt nicht: sie sagt, was DA ist; ob der Lauf
// damit liefe, entscheiden die Sperren.
type Bestand struct {
	Welle       string
	Plaene      []string // done/<welle-id>*.md ohne die Ergebnisnotiz — 0, 1 oder mehrdeutig viele
	Ergebnis    string   // done/<welle-id>-results.md; leer, wenn sie fehlt
	Mitglieder  []string
	Wellenlose  []string
	Fremde      []string
	Reviews     []string
	Untergrenze string // ein vorhandenes done/*/archiv.zip; leer = keines
	Archiviert  bool   // done/<welle-id>/ existiert bereits
}

// Slices sind die eingesammelten Slice-Dateien: Mitglieder und Wellenlose. Die
// Fremden stehen bewusst nicht darin — sie bleiben liegen.
func (b Bestand) Slices() []string {
	out := make([]string, 0, len(b.Mitglieder)+len(b.Wellenlose))
	out = append(out, b.Mitglieder...)
	out = append(out, b.Wellenlose...)
	sort.Strings(out)
	return out
}

// Bewegte sind die Basenamen der Dateien, die der schreibende Lauf nach
// done/<welle-id>/ zoege: die eingesammelten Slices und der Welle-Plan. Sie sind
// der Eingang des Verweis-Funds.
func (b Bestand) Bewegte() []string {
	var out []string
	for _, p := range b.Slices() {
		out = append(out, filepath.Base(p))
	}
	for _, p := range b.Plaene {
		out = append(out, filepath.Base(p))
	}
	sort.Strings(out)
	return out
}

// Verschwindend sind die Dateien, die den Lauf NICHT ueberleben oder ihn nur
// unter neuer Adresse ueberleben — die Bewegten und die Review-Reports. Ein
// Verweis aus einer von ihnen ist kein Haenger.
func (b Bestand) Verschwindend() []string {
	out := append(b.Slices(), b.Plaene...)
	out = append(out, b.Reviews...)
	sort.Strings(out)
	return out
}

// Einsammeln liest den Bestand einer Welle aus dem Baum unter root. Der Fehler
// ist ein Lese-Fehler und nichts sonst: ein fehlender Plan, eine fehlende
// Ergebnisnotiz und ein leeres Einsammel-Ergebnis sind ZUSTAENDE und stehen im
// Bestand, damit die Vorschau sie nennen kann statt abzubrechen.
func Einsammeln(root, welleID string) (Bestand, error) {
	b := Bestand{Welle: welleID}
	eintraege, err := os.ReadDir(filepath.Join(root, filepath.FromSlash(doneDir)))
	if err != nil {
		return b, fmt.Errorf("%s lesen: %w", doneDir, err)
	}
	ergebnisName := welleID + "-results.md"
	for _, e := range eintraege {
		name := e.Name()
		rel := doneDir + "/" + name
		switch {
		case e.IsDir():
			if name == welleID {
				b.Archiviert = true
			}
		case name == ergebnisName:
			b.Ergebnis = rel
		case planName(name, welleID):
			b.Plaene = append(b.Plaene, rel)
		case strings.HasPrefix(name, "slice-") && strings.HasSuffix(name, ".md"):
			if err := b.einordnen(root, rel); err != nil {
				return b, err
			}
		}
	}
	b.Untergrenze = untergrenze(root, eintraege)
	if b.Reviews, err = Reviews(root, b.Slices()); err != nil {
		return b, err
	}
	sort.Strings(b.Plaene)
	return b, nil
}

// planName sagt, ob ein Dateiname aus done/ der Welle-Plan dieser Welle ist: er
// beginnt mit der Kennung, traegt die Markdown-Endung — und hinter der Kennung
// steht keine ZIFFER. Dieselbe Grenze, die nenntWelle fuer das Kopf-Feld und
// ReviewTrifft fuer die Slice-Nummer ziehen: ohne sie zoege "welle-1" die
// Dateien von "welle-10" und "welle-14" in die Kandidatenliste, und die
// Ergebnisnotiz einer fremden Welle stuende darin als Welle-Plan.
// Gedeckt von TestEinsammelnPlanAnDerZiffernGrenze.
func planName(name, welleID string) bool {
	if welleID == "" || !strings.HasSuffix(name, ".md") || !strings.HasPrefix(name, welleID) {
		return false
	}
	rest := name[len(welleID):]
	return rest == "" || rest[0] < '0' || rest[0] > '9'
}

// einordnen liest das Kopf-Feld einer Slice-Datei und haengt sie an ihre Klasse.
func (b *Bestand) einordnen(root, rel string) error {
	inhalt, err := os.ReadFile(filepath.Join(root, filepath.FromSlash(rel)))
	if err != nil {
		return fmt.Errorf("%s lesen: %w", rel, err)
	}
	switch KlasseVon(WelleFeld(string(inhalt)), b.Welle) {
	case Mitglied:
		b.Mitglieder = append(b.Mitglieder, rel)
	case Wellenlos:
		b.Wellenlose = append(b.Wellenlose, rel)
	default:
		b.Fremde = append(b.Fremde, rel)
	}
	return nil
}

// untergrenze sucht ein vorhandenes done/<welle-x>/archiv.zip. Es ist die
// beobachtbare Untergrenze fuer "wellenlos seit der letzten Closure"; ohne eines
// umfasste die Klasse jeden wellenlosen Slice, den das Repo je geschlossen hat.
// Der erste Fund genuegt — die Frage ist, OB eine Grenze existiert.
func untergrenze(root string, eintraege []os.DirEntry) string {
	for _, e := range eintraege {
		if !e.IsDir() {
			continue
		}
		rel := doneDir + "/" + e.Name() + "/" + archivName
		if _, err := os.Stat(filepath.Join(root, filepath.FromSlash(rel))); err == nil {
			return rel
		}
	}
	return ""
}

// Reviews sammelt die Review-Reports zu den uebergebenen Slice-Dateien: der
// Dateiname traegt die Nummer, die Suffix-Grenze in ReviewTrifft entscheidet.
// 1:N ist zulaessig (mehrere Runden desselben Slice); doppelt gezaehlt wird
// keiner, weil ein Report die Nummern mehrerer eingesammelter Slices tragen kann.
// Ein fehlendes docs/reviews/ ist kein Fehler, sondern eine leere Liste.
func Reviews(root string, slices []string) ([]string, error) {
	nummern := make([]string, 0, len(slices))
	for _, p := range slices {
		if nr := SliceNummer(filepath.Base(p)); nr != "" {
			nummern = append(nummern, nr)
		}
	}
	eintraege, err := os.ReadDir(filepath.Join(root, filepath.FromSlash(reviewsDir)))
	if errors.Is(err, fs.ErrNotExist) {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("%s lesen: %w", reviewsDir, err)
	}
	var out []string
	for _, e := range eintraege {
		if e.IsDir() || !strings.HasSuffix(e.Name(), ".md") {
			continue
		}
		for _, nr := range nummern {
			if ReviewTrifft(e.Name(), nr) {
				out = append(out, reviewsDir+"/"+e.Name())
				break
			}
		}
	}
	sort.Strings(out)
	return out, nil
}
