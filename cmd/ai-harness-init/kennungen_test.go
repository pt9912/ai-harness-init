package main

import (
	"bytes"
	"io/fs"
	"os"
	"path/filepath"
	"regexp"
	"sort"
	"strings"
	"testing"
)

// kennungMuster trifft die Kennungen dieses Repos in Ziffernform: ADR-NNNN, LH-XX-NN,
// MR-NNN, SPEC-NNN, CO-NNN, slice-NNN, welle-NN. Ein emittiertes Ziel fuehrt keines
// dieser Register mit diesen Nummern — eine solche Kennung in einer emittierten Datei
// zeigt dort ins Leere.
//
// GRENZE: die Namensform slice-<name> / welle-<name> (MR-057) trifft das Muster nicht.
// Sie ist von Werkzeug-Namen derselben Gestalt (slice-mv, slice-lokal) nur durch den
// Abgleich gegen die Plan-Dateien dieses Repos zu trennen, und die liest der Test nicht —
// eine emittierte Namens-Kennung bleibt unter ihm gruen.
var kennungMuster = regexp.MustCompile(`\b(ADR-[0-9]{4}|LH-[A-Z]{2}-[0-9]{2}|MR-[0-9]{3}|SPEC-[0-9]{3}|CO-[0-9]{3}|slice-[0-9]+|welle-[0-9]+)\b`)

// erlaubteKennungen ist die namentliche Ausnahme-Liste Datei → Kennungs-Menge ueber der
// realen Emission. Beide Eintraege sind funktionale Nutzlast: der Default-Commit-Text der
// Selbstpruefung (SELBSTPRUEFUNG_MSG_GRUEN) muss ein Kennungs-Muster des emittierten
// commit-msg-Traegers treffen, sonst faellt der gruene Probe-Commit am Traeger.
func erlaubteKennungen() map[string][]string {
	return map[string][]string{
		"harness/mk/selbstpruefung.mk":    {"LH-FA-01"},
		"tools/harness/selbstpruefung.sh": {"LH-FA-01"},
	}
}

// kennungsAusnahme nennt die Pfade der realen Emission, die der Waechter nicht liest:
// das Git-Verzeichnis, die vendored Baseline (Fremdtext des Kurses, kein Text dieses
// Werkzeugs) und den abgelegten Traeger (das laufende Binaerbild, im Test das
// Testbinary). GRENZE: die Meldungen, die der Traeger zur Laufzeit ausgibt, liest der
// Waechter damit nicht. Gelesen, aber nicht real ist d-check.mk: im Test kommt es aus
// einer Fixture (docMKFixture), real aus `d-check --print-mk` — Fremdtext wie die
// Baseline, kein Text dieses Werkzeugs; seinen realen Inhalt haelt der Waechter nicht.
func kennungsAusnahme(rel string) bool {
	for _, p := range []string{".git/", ".harness/baseline/", ".harness/state/bin/"} {
		if strings.HasPrefix(rel, p) {
			return true
		}
	}
	return false
}

// kennungenIn liest die Fundmenge eines Ziel-Baums: Datei → sortierte, eindeutige Kennungen.
func kennungenIn(t *testing.T, root string, into map[string]map[string]bool) {
	t.Helper()
	err := filepath.WalkDir(root, func(p string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}
		rel, _ := filepath.Rel(root, p)
		rel = filepath.ToSlash(rel)
		if d.IsDir() {
			if rel != "." && kennungsAusnahme(rel+"/") {
				return filepath.SkipDir
			}
			return nil
		}
		if kennungsAusnahme(rel) || !d.Type().IsRegular() {
			return nil
		}
		data, err := os.ReadFile(p)
		if err != nil {
			return err
		}
		for _, k := range kennungMuster.FindAllString(string(data), -1) {
			if into[rel] == nil {
				into[rel] = map[string]bool{}
			}
			into[rel][k] = true
		}
		return nil
	})
	if err != nil {
		t.Fatalf("Ziel lesen: %v", err)
	}
}

// TestEmittierteDateienTragenNurImZielAufloesendeKennungen haelt ueber der realen Emission
// jeder Lauf-Variante (sprachlos, go und cpp je Layout, mit und ohne Erfassung), dass die
// Fundmenge Datei → Kennungen GLEICH der Ausnahme-Liste ist, in beide Richtungen
// (LH-QA-01): eine Kennung in einer emittierten Datei ausserhalb der Liste ist rot und
// nennt die Datei; ein Listeneintrag, den keine Variante emittiert, ist ebenso rot.
//
// GRENZE: gelesen ist, was diese Varianten schreiben. Der add-lang-Pfad an einem
// Unterverzeichnis und Flag-Kombinationen ausserhalb der Liste unten laufen nicht.
// Erkannt sind die Formen aus kennungMuster; die Namensform slice-<name> nicht (dort
// benannt).
func TestEmittierteDateienTragenNurImZielAufloesendeKennungen(t *testing.T) {
	varianten := []struct {
		name      string
		args      []string
		ohneErfas bool
	}{
		{"sprachlos", nil, false},
		{"sprachlos-ohne-erfassung", nil, true},
		{"go-flat", []string{"--lang", "go"}, false},
		{"go-hexagonal", []string{"--lang", "go", "--arch", "hexagonal"}, false},
		{"go-hexslice", []string{"--lang", "go", "--arch", "hexslice"}, false},
		{"cpp-flat", []string{"--lang", "cpp"}, false},
		{"cpp-hexslice", []string{"--lang", "cpp", "--arch", "hexslice"}, false},
		{"kotlin-flat", []string{"--lang", "kotlin"}, false},
		{"kotlin-hexslice", []string{"--lang", "kotlin", "--arch", "hexslice"}, false},
	}
	fund := map[string]map[string]bool{}
	for _, v := range varianten {
		dir := gitRepo(t)
		if v.ohneErfas {
			blocker := filepath.Join(dir, ".harness", "state", "bin")
			if err := os.MkdirAll(filepath.Dir(blocker), 0o755); err != nil {
				t.Fatalf("%s vorbereiten: %v", v.name, err)
			}
			if err := os.WriteFile(blocker, []byte("kein Verzeichnis\n"), 0o644); err != nil {
				t.Fatalf("%s vorbereiten: %v", v.name, err)
			}
		}
		src := testSources(t)
		src.baseline, src.baselineSHA = baselineFixture(t, struct{ name, content string }{
			"templates/project-readme.template.md", "# <Projektname>\n"})
		src.docMK = docMKFixture(t)
		var out, errb bytes.Buffer
		if code := run(append(append([]string{}, v.args...), dir), dir, src, &out, &errb); code != 0 {
			t.Fatalf("%s: Bootstrap exit %d: %s", v.name, code, errb.String())
		}
		if v.ohneErfas && !strings.Contains(errb.String(), "Erfassungsschicht nicht abgelegt") {
			t.Fatalf("%s: der Lauf hat die Erfassung abgelegt — die Variante faehrt nicht, was ihr Name sagt", v.name)
		}
		kennungenIn(t, dir, fund)
	}

	erlaubt := erlaubteKennungen()
	ist := map[string][]string{}
	for f, ks := range fund {
		for k := range ks {
			ist[f] = append(ist[f], k)
		}
		sort.Strings(ist[f])
	}
	var fehler []string
	for f, ks := range ist {
		if want := erlaubt[f]; strings.Join(want, ",") != strings.Join(ks, ",") {
			fehler = append(fehler, "  "+f+": emittiert "+strings.Join(ks, ", ")+" — erlaubt: "+strings.Join(want, ", "))
		}
	}
	for f, want := range erlaubt {
		if _, ok := ist[f]; !ok {
			fehler = append(fehler, "  "+f+": die Ausnahme "+strings.Join(want, ", ")+" emittiert keine Variante")
		}
	}
	if len(fehler) > 0 {
		sort.Strings(fehler)
		t.Errorf("emittierte Kennungen weichen von der Ausnahme-Liste ab — im Ziel loest keine dieser Kennungen auf (LH-QA-01):\n%s", strings.Join(fehler, "\n"))
	}
}
