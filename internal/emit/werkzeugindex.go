package emit

import (
	"fmt"
	"os"
	"path/filepath"
	"regexp"
	"sort"
	"strings"
)

// WerkzeugIndexPath ist der werkzeug-eigene Teil des Gate-Index im Ziel (Kurs v6.16.0,
// grundlagen-harness-dateien.md §harness/README.md als Einstiegspunkt: harness/mk/<werkzeug>.md).
// KONVERGENT: jeder Lauf (Bootstrap und add-lang) schreibt ihn kanonisch neu, im selben Lauf
// wie die Fragmente, deren Targets er fuehrt. Er steht nicht in enforceFiles(): sein Inhalt
// entsteht aus den Make-Dateien des Ziels und hat keine eingebettete Quelle — dieselbe Lage
// wie d-check.mk in DocGate.
const WerkzeugIndexPath = "harness/mk/ai-harness-init.md"

// harnessReadmePath ist der Gate-Index des Repos im Ziel; er verlinkt den Werkzeug-Teil.
const harnessReadmePath = "harness/README.md"

// werkzeugRegelPattern erfasst eine Make-Regel-Zeile samt optionalem Hilfetext hinter `##`.
// KOPPLUNG: dieselbe Erkennung wie das Modul targets am Pin d-check v0.82.0
// (`^[A-Za-z][A-Za-z0-9 _-]*:([^=]|$)`); Gruppe 1 ist eine Namensliste, jedes Feld ein Target.
// `.PHONY`, Pattern-Regeln und `:=`/`?=` fallen heraus. Gehalten von
// TestWerkzeugIndex_ErkenntRegelnWieDasDokuGate. Grenze: eine Tabellenzelle `make X` erkennt
// das Modul nur fuer einen Namen aus Kleinbuchstaben, Ziffern, `_` und `-` — ein Target mit
// Grossbuchstaben steht hier und meldet trotzdem gate-undocumented.
var werkzeugRegelPattern = regexp.MustCompile(`(?m)^([A-Za-z][A-Za-z0-9 _-]*):(?:[^=\n][^\n]*)?$`)

// werkzeugHilfePattern liest den Hilfetext einer Regel-Zeile (`name: … ## text`).
var werkzeugHilfePattern = regexp.MustCompile(`##[ \t]*(.+)$`)

// readmeZeilePattern erfasst die Target-Zelle einer Tabellenzeile: `make <name>` in der ersten
// Zelle, nackt oder als Link.
var readmeZeilePattern = regexp.MustCompile("(?m)^\\|[ \\t]*\\[?`make ([a-z][a-z0-9_-]*)`")

// werkzeugMakeDateien nennt die Make-Dateien des Werkzeugs im Ziel, in Lese-Reihenfolge:
// Aggregator, die zwei tool-generierten Fragmente an der Wurzel (a-check.mk nur mit
// Arch-Gate) und harness/mk/*.mk. repo.mk gehoert dem Repo und fehlt mit Absicht.
func werkzeugMakeDateien(targetDir string) ([]string, error) {
	files := []string{MakefilePath, "d-check.mk", ArchMkPath}
	frags, err := filepath.Glob(filepath.Join(targetDir, "harness", "mk", "*.mk"))
	if err != nil {
		return nil, err
	}
	sort.Strings(frags)
	for _, f := range frags {
		rel, relErr := filepath.Rel(targetDir, f)
		if relErr != nil {
			return nil, relErr
		}
		files = append(files, filepath.ToSlash(rel))
	}
	return files, nil
}

// werkzeugTarget ist eine Zeile des Werkzeug-Teils.
type werkzeugTarget struct {
	name, hilfe, datei string
}

// werkzeugIndexZeilePattern liest eine geschriebene Zeile des Werkzeug-Teils: Gruppe 1 das
// Target, Gruppe 2 die Bindung-Spalte (`—` in der Gate-Tabelle, `kein Gate` in der zweiten).
// KOPPLUNG: die Zeilenform, die WerkzeugIndex schreibt.
var werkzeugIndexZeilePattern = regexp.MustCompile("(?m)^\\| `make ([^`]+)` \\|.*\\| (—|kein Gate) \\|$")

// WerkzeugTargetNeu ist ein Target, das der geschriebene Werkzeug-Teil gegenueber dem vorigen
// neu fuehrt. Gate ist wahr, wenn es in der Gate-Tabelle steht (ohne Marke `kein Gate`).
type WerkzeugTargetNeu struct {
	Name string
	Gate bool
}

// WerkzeugIndexBericht sagt, was ein Lauf von WerkzeugIndex am Werkzeug-Teil geaendert hat.
// Erstlauf ist wahr, wenn vor dem Lauf kein Werkzeug-Teil lag; Neu ist dann leer. Sonst nennt
// Neu jedes Target, das der vorige Teil nicht fuehrte, und jedes, das jetzt in der Gate-Tabelle
// steht und vorher nicht — Gates zuerst, je Klasse nach Namen sortiert. Ein entfallenes Target
// nennt der Bericht nicht. Targets und Gates zaehlen die Zeilen des geschriebenen Teils.
type WerkzeugIndexBericht struct {
	Erstlauf       bool
	Neu            []WerkzeugTargetNeu
	Targets, Gates int
}

// vorigerWerkzeugIndex liest den liegenden Werkzeug-Teil: je Zeile Target -> Gate-Eigenschaft.
// Fehlt die Datei, ist da false.
func vorigerWerkzeugIndex(targetDir string) (zeilen map[string]bool, da bool, err error) {
	content, err := os.ReadFile(filepath.Join(targetDir, filepath.FromSlash(WerkzeugIndexPath)))
	if os.IsNotExist(err) {
		return nil, false, nil
	}
	if err != nil {
		return nil, false, fmt.Errorf("%s lesen: %w", WerkzeugIndexPath, err)
	}
	zeilen = map[string]bool{}
	for _, m := range werkzeugIndexZeilePattern.FindAllStringSubmatch(string(content), -1) {
		zeilen[m[1]] = m[2] == "—"
	}
	return zeilen, true, nil
}

// WerkzeugIndex schreibt den werkzeug-eigenen Teil des Gate-Index nach targetDir: je Target der
// Make-Dateien des Werkzeugs (werkzeugMakeDateien) eine Zeile; Gate ist, was ein Fragment an
// GATE_CHECKS haengt, dazu `gates`, alles uebrige steht mit `kein Gate` in der zweiten Tabelle.
// DISJUNKT gegen harness/README.md zum Zeitpunkt des Laufs: ein Target, das der Index des Repos
// als Tabellenzeile fuehrt, steht hier nicht. Gehalten von TestWerkzeugIndex_ZeileJeWerkzeugTargetDisjunkt und
// TestWerkzeugIndex_KonvergentHeiltDrift, im Ziel von
// der full-smoke-Stufe targets_im_ziel (gruener Start, gate-phantom, gate-undocumented).
//
// Vor dem Schreiben liest der Lauf den liegenden Teil und gibt im Bericht zurueck, was neu
// hinzukam (WerkzeugIndexBericht) — das Doku-Gate meldet ein solches Target nicht, es ist im
// Teil des Werkzeugs deklariert (Kurs v6.16.0, modul-13-quality-gates.md §Hard Rule), sichtbar
// macht es allein der Lauf. ERSTLAUF (kein voriger Teil): keine Einzelnennung, der Bericht traegt
// die Zahlen. Ohne vorigen Teil fehlt der Vergleichsstand: im frischen Bootstrap wie im Ziel, das
// den Teil zum ersten Mal bekommt, ist jedes Target neu, und eine Liste trennt dort nichts.
// Gehalten von TestWerkzeugIndex_BerichtNenntNeueTargets, im Ziel von der full-smoke-Stufe
// werkzeug_meldung_im_ziel.
func WerkzeugIndex(targetDir string) (WerkzeugIndexBericht, error) {
	var bericht WerkzeugIndexBericht
	files, err := werkzeugMakeDateien(targetDir)
	if err != nil {
		return bericht, err
	}
	vorher, vorherDa, err := vorigerWerkzeugIndex(targetDir)
	if err != nil {
		return bericht, err
	}
	bericht.Erstlauf = !vorherDa
	imRepoIndex := map[string]bool{}
	if readme, readErr := os.ReadFile(filepath.Join(targetDir, filepath.FromSlash(harnessReadmePath))); readErr == nil {
		for _, m := range readmeZeilePattern.FindAllStringSubmatch(string(readme), -1) {
			imRepoIndex[m[1]] = true
		}
	}
	gates := map[string]bool{"gates": true}
	gefunden := map[string]*werkzeugTarget{}
	for _, rel := range files {
		if err := sammleWerkzeugTargets(targetDir, rel, gates, gefunden); err != nil {
			return bericht, err
		}
	}
	var gateZeilen, werkzeugZeilen, gateNamen, werkzeugNamen []string
	namen := make([]string, 0, len(gefunden))
	for n := range gefunden {
		namen = append(namen, n)
	}
	sort.Strings(namen)
	for _, n := range namen {
		if imRepoIndex[n] {
			continue
		}
		t := gefunden[n]
		zelle := t.hilfe
		if zelle == "" {
			zelle = "Ziel aus `" + t.datei + "`, ohne Hilfetext"
		}
		zelle = strings.ReplaceAll(zelle, "|", `\|`)
		if gates[n] {
			gateZeilen = append(gateZeilen, "| `make "+n+"` | "+zelle+" | — |")
			gateNamen = append(gateNamen, n)
		} else {
			werkzeugZeilen = append(werkzeugZeilen, "| `make "+n+"` | "+zelle+" | kein Gate |")
			werkzeugNamen = append(werkzeugNamen, n)
		}
	}
	if vorherDa {
		bericht.Neu = neueWerkzeugTargets(gateNamen, werkzeugNamen, vorher)
	}
	bericht.Targets = len(gateZeilen) + len(werkzeugZeilen)
	bericht.Gates = len(gateZeilen)
	return bericht, writeFileMode(targetDir, WerkzeugIndexPath, []byte(werkzeugIndexText(gateZeilen, werkzeugZeilen)), 0o644)
}

// neueWerkzeugTargets vergleicht die geschriebenen Zeilen mit dem vorigen Teil (Target -> Gate):
// neu ist ein Gate, das vorher nicht in der Gate-Tabelle stand, und ein Werkzeug-Ziel, das vorher
// fehlte. Gates zuerst, beide Listen in der Reihenfolge der Eingabe.
func neueWerkzeugTargets(gateNamen, werkzeugNamen []string, vorher map[string]bool) []WerkzeugTargetNeu {
	var neu []WerkzeugTargetNeu
	for _, n := range gateNamen {
		if !vorher[n] {
			neu = append(neu, WerkzeugTargetNeu{Name: n, Gate: true})
		}
	}
	for _, n := range werkzeugNamen {
		if _, warDa := vorher[n]; !warDa {
			neu = append(neu, WerkzeugTargetNeu{Name: n})
		}
	}
	return neu
}

// sammleWerkzeugTargets liest eine Make-Datei des Werkzeugs: ihre GATE_CHECKS-Eintraege nach
// gates, ihre Regeln nach gefunden (erste Fundstelle gewinnt, ein spaeterer Hilfetext fuellt eine
// leere Zelle). Eine fehlende Datei — a-check.mk ohne Arch-Gate — wird uebersprungen.
func sammleWerkzeugTargets(targetDir, rel string, gates map[string]bool, gefunden map[string]*werkzeugTarget) error {
	content, err := os.ReadFile(filepath.Join(targetDir, filepath.FromSlash(rel)))
	if os.IsNotExist(err) {
		return nil
	}
	if err != nil {
		return fmt.Errorf("%s lesen: %w", rel, err)
	}
	for _, m := range regexp.MustCompile(gateCheckPattern).FindAllStringSubmatch(string(content), -1) {
		for _, t := range strings.Fields(m[1]) {
			gates[t] = true
		}
	}
	for _, m := range werkzeugRegelPattern.FindAllStringSubmatch(string(content), -1) {
		hilfe := ""
		if h := werkzeugHilfePattern.FindStringSubmatch(m[0]); h != nil {
			hilfe = strings.TrimSpace(h[1])
		}
		for _, name := range strings.Fields(m[1]) {
			t, ok := gefunden[name]
			if !ok {
				gefunden[name] = &werkzeugTarget{name: name, hilfe: hilfe, datei: rel}
				continue
			}
			if t.hilfe == "" {
				t.hilfe = hilfe
			}
		}
	}
	return nil
}

// werkzeugIndexText setzt Kopf und beide Tabellen zusammen; eine leere Tabelle wird durch
// einen Satz ersetzt, nicht als Kopf ohne Zeilen geschrieben.
func werkzeugIndexText(gateZeilen, werkzeugZeilen []string) string {
	var b strings.Builder
	b.WriteString(werkzeugIndexKopf)
	b.WriteString("\n## Gates\n\n")
	if len(gateZeilen) == 0 {
		b.WriteString("Keine — jedes Gate des Werkzeugs steht in `harness/README.md`.\n")
	} else {
		b.WriteString("| Target | Vertrag | Bindung |\n|---|---|---|\n")
		b.WriteString(strings.Join(gateZeilen, "\n") + "\n")
	}
	b.WriteString("\n## Werkzeuge — kein Gate\n\n")
	if len(werkzeugZeilen) == 0 {
		b.WriteString("Keine.\n")
	} else {
		b.WriteString("| Target | Tut was | Bindung |\n|---|---|---|\n")
		b.WriteString(strings.Join(werkzeugZeilen, "\n") + "\n")
	}
	return b.String()
}

const werkzeugIndexKopf = `# Gate-Index — Teil des Werkzeugs ai-harness-init

Diese Datei gehört dem Werkzeug ` + "`ai-harness-init`" + `. Jeder Lauf des Werkzeugs (Bootstrap und
` + "`add-lang`" + `) schreibt sie kanonisch neu; eine Änderung von Hand geht beim nächsten Lauf verloren.
Was das Repo über ein Target dieser Datei entscheidet — einen Carveout, eine Sensor-Datei, eine
eigene Bindung —, steht in der Zeile von ` + "`harness/README.md`" + ` §Sensors, die diese Datei verlinkt.

**Was hier steht.** Je Make-Target der Make-Dateien, die das Werkzeug schreibt, eine Zeile:
` + "`Makefile`" + `, ` + "`d-check.mk`" + `, ` + "`a-check.mk`" + ` (nur mit Arch-Gate) und alle Dateien unter
` + "`harness/mk/`" + `. Gate ist, was ein Fragment an ` + "`GATE_CHECKS`" + ` hängt, dazu ` + "`gates`" + `; die
übrigen stehen in der zweiten Tabelle mit ` + "`kein Gate`" + `. Ein Target, das ` + "`harness/README.md`" + ` beim
Lauf schon als Tabellenzeile führt, steht hier nicht. Die Spalte Vertrag bzw. Tut was trägt den
Hilfetext hinter ` + "`##`" + ` der Regel-Zeile.

**Wer das prüft.** Das Doku-Gate des Ziels (` + "`.d-check.yml`" + `, Modul ` + "`targets`" + `) führt diese
Datei und ` + "`harness/README.md`" + ` gemeinsam als Autorität: ein Target ohne Zeile in einer der beiden
meldet ` + "`gate-undocumented`" + `, eine Zeile ohne Target ` + "`gate-phantom`" + `. Die eigenen Targets des Repos
stehen in ` + "`repo.mk`" + ` und brauchen ihre Zeile in ` + "`harness/README.md`" + `.

**Grenzen.**

- Kein Target steht in zwei Teilen: so verlangt es die adoptierte Kurs-Fassung (Regelwerk
  ` + "`grundlagen-harness-dateien.md`" + ` §harness/README.md als Einstiegspunkt). ` + DisjunktheitsBedingung + `
- Eine Datei, die das Repo selbst unter ` + "`harness/mk/`" + ` ablegt, liest der Lauf mit; ihre Targets
  stehen dann hier statt in ` + "`harness/README.md`" + `.
`

// DisjunktheitsBedingung ist der statische Satz der Grenz-Zeile: er nennt die Bedingung, unter
// der das Doku-Gate des Ziels die Disjunktheit der zwei Teile prueft, und liest die
// .d-check.yml des Ziels nicht — er ist darum in einem frisch gebootstrappten wie in einem
// bestehenden Ziel wahr (ADR-0082 Festlegung 2). Er sagt einem bestehenden Ziel nicht, ob es
// die Bedingung erfuellt. Wird durch TestWerkzeugIndex_GrenzeNenntDisjunktheitsBedingung gehalten.
const DisjunktheitsBedingung = "Das Doku-Gate prüft die Disjunktheit, wenn in " +
	"`.d-check.yml` das Modul `targets` in `modules` steht, `targets.authority` beide Teile als " +
	"Liste nennt und `targets.authority-disjoint: true` gesetzt ist; dann meldet es ein Target, " +
	"das in beiden Teilen eine Zeile hat, als `gate-declared-twice`. Sonst bleibt eine Doppelung " +
	"still. Der Sensor sieht eine Doppelung erst, wenn das Repo sie angelegt hat: legt es nach " +
	"einem Lauf eine eigene Zeile für ein Target dieser Datei an, steht es bis zum nächsten Lauf " +
	"in beiden Teilen."

// harnessReadmeTemplate ist die Vorlage des Gate-Index des Repos im Kurs-Satz.
const harnessReadmeTemplate = "harness/README.template.md"

// sensorsUeberschrift ist die Sektion, unter deren Tabellen die Zeile auf den Werkzeug-Teil steht.
const sensorsUeberschrift = "## Sensors (Feedback-Gates)"

// WerkzeugIndexZeile verlinkt den werkzeug-eigenen Teil des Gate-Index aus harness/README.md
// (Kurs v6.16.0, grundlagen-harness-dateien.md: "Eine Zeile unter den Tabellen dieser Sektion
// verlinkt jeden Teil"). Der Link ist relativ zu harness/.
const WerkzeugIndexZeile = "**Targets der Werkzeug-Fragmente:** [`mk/ai-harness-init.md`](mk/ai-harness-init.md) — " +
	"der Teil dieses Index, den `ai-harness-init` bei jedem Lauf neu schreibt; was das Repo über " +
	"eines dieser Targets entscheidet, steht in dieser Zeile."

// InjectWerkzeugIndexLink setzt WerkzeugIndexZeile ans Ende der Sektion sensorsUeberschrift, vor
// die naechste `## `-Ueberschrift. FAIL-CLOSED (MR-017): fehlt die Sektion, endet der Emit mit
// Fehler, statt eine README ohne den Zeiger abzulegen. Die README ist skip-if-present: ein Ziel
// mit liegender harness/README.md bekommt die Zeile nicht.
func InjectWerkzeugIndexLink(body string) (string, error) {
	start := strings.Index(body, "\n"+sensorsUeberschrift+"\n")
	if start < 0 {
		return "", fmt.Errorf("%s: Sektion %q fehlt — die Zeile auf %s hat keinen Ort", harnessReadmeTemplate, sensorsUeberschrift, WerkzeugIndexPath)
	}
	rest := body[start+1+len(sensorsUeberschrift):]
	ende := len(body)
	if i := strings.Index(rest, "\n## "); i >= 0 {
		ende = start + 1 + len(sensorsUeberschrift) + i + 1
	}
	vorne := strings.TrimRight(body[:ende], "\n")
	return vorne + "\n\n" + WerkzeugIndexZeile + "\n\n" + body[ende:], nil
}
