package main

import (
	"bytes"
	"fmt"
	"go/ast"
	"go/parser"
	"go/token"
	"io/fs"
	"os"
	"path/filepath"
	"regexp"
	"slices"
	"sort"
	"strconv"
	"strings"
	"testing"
)

// kennungMuster trifft die Kennungen dieses Repos in Ziffernform — ADR-NNNN, LH-XX-NN,
// MR-NNN, SPEC-NNN, CO-NNN, slice-NNN, welle-NN — und die Anforderungs-Kennungen der zwei
// Nachbar-Werkzeuge, deren --print-mk-Ausgabe ins Ziel adaptiert wird (DC-…-NNN von
// d-check, AC-…-NN von a-check). Ein emittiertes Ziel fuehrt keines dieser Register mit
// diesen Nummern — eine solche Kennung in einer emittierten Datei zeigt dort ins Leere.
// Die Grenze links ist ausgeschrieben (kein Buchstabe, keine Ziffer, kein `_`/`-` davor),
// die rechts prueft kennungenInText: die Kennung endet mit ihrer Ziffernfolge, danach steht
// kein Buchstabe, keine Ziffer und kein `_`. Ein `-wort` danach gehoert nicht zur Kennung
// und verwirft sie nicht — `MR-077-statt-der`, `slice-082-foo`, `LH-QA-01-Bedingung` (die
// Form der Dateinamen und Komposita dieses Repos) sind Treffer; `x-slice-12`, `ADR-00012`
// und `ADR-0001x` sind keine Kennung.
//
// GRENZE: die Namensform slice-<name> / welle-<name> (MR-057) trifft das Muster nicht.
// Sie ist von Werkzeug-Namen derselben Gestalt (slice-mv, slice-lokal) nur durch den
// Abgleich gegen die Plan-Dateien dieses Repos zu trennen, und die liest der Test nicht —
// eine emittierte Namens-Kennung bleibt unter ihm gruen.
var kennungMuster = regexp.MustCompile(`(?:^|[^A-Za-z0-9_-])(ADR-[0-9]{4}|LH-[A-Z]{2}-[0-9]{2}|MR-[0-9]{3}|SPEC-[0-9]{3}|CO-[0-9]{3}|slice-[0-9]+|welle-[0-9]+|(?:DC|AC)(?:-[A-Z]+)+-[0-9]+)`)

// prosaVerweisMuster trifft einen Verweis auf ein Norm-Artefakt dieses Werkzeugs in Prosa,
// ohne Kennung: Spezifikation, Lastenheft, Festlegung, Adaptions-Eintrag oder Dogfood,
// gefolgt von „von ai-harness-init" im selben Satz. Die Herkunftszeile im Kopf einer
// emittierten Datei („emittiert von ai-harness-init") trifft es nicht. Gelesen wird der
// leerraum-normalisierte Text, damit ein Umbruch den Satz nicht teilt. Der Satz endet an
// einem Punkt vor Leerraum oder Textende; ein Punkt in einem Dateinamen oder einer Version
// (`spezifikation.md`, `v0.6.0`) beendet ihn nicht.
//
// GRENZE: `dogfood` allein trifft jedes Vorkommen, auch eines ohne Bezug auf dieses Repo
// (laut, nicht still). Eine Abkuerzung mit Punkt vor Leerraum zwischen Stichwort und
// Herkunft teilt den Satz; ein Verweis ohne die Wendung von ai-harness-init faellt durch.
var prosaVerweisMuster = regexp.MustCompile(`(?i)\b(?:spezifikation|lastenheft|festlegung(?:en)?|adaptions-eintrag|dogfood[a-z-]*)\b(?:[^.]|\.\S){0,160}\bvon ai-harness-init\b|\bdogfood`)

// kennungenInText liefert die Kennungen aus kennungMuster und die Prosa-Verweise aus
// prosaVerweisMuster in text. Eine Kennung, auf die ein Buchstabe, eine Ziffer oder `_`
// folgt, zaehlt nicht; ein folgendes `-` beendet sie.
func kennungenInText(text string) []string {
	var ks []string
	for _, m := range kennungMuster.FindAllStringSubmatchIndex(text, -1) {
		if e := m[3]; e < len(text) && strings.ContainsRune("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_", rune(text[e])) {
			continue
		}
		ks = append(ks, text[m[2]:m[3]])
	}
	for _, p := range prosaVerweisMuster.FindAllString(strings.Join(strings.Fields(text), " "), -1) {
		ks = append(ks, "Prosa: "+p)
	}
	return ks
}

// agentsAbschnittMuster trifft eine Abschnittsnummer der AGENTS.md in der Form, in der
// dieses Repo sie schreibt: `AGENTS.md 3.5`, `AGENTS.md §3.5`. Es gilt nur fuer Meldungen
// des Traegers, nicht fuer emittierte Dateien — die AGENTS.md des Ziels und ihre Nachbarn
// verweisen dort auf die eigenen Abschnitte, und die loesen im Ziel auf.
var agentsAbschnittMuster = regexp.MustCompile(`AGENTS\.md ?§? ?[0-9]`)

// meldungsVerweise liefert kennungenInText und die Abschnittsnummern aus
// agentsAbschnittMuster in text.
func meldungsVerweise(text string) []string {
	ks := kennungenInText(text)
	for _, a := range agentsAbschnittMuster.FindAllString(text, -1) {
		ks = append(ks, "Abschnittsnummer: "+a)
	}
	return ks
}

// TestKennungenInTextGrenzen haelt die Grenzen der Erkennung an den Formen, die dieses
// Repo schreibt (LH-QA-01): eine Kennung vor `-wort` ist ein Treffer, eine laengere
// Ziffernfolge oder ein angehaengter Buchstabe keiner; ein Prosa-Verweis ueber einen
// Dateinamen oder eine Version hinweg ist ein Treffer; eine Abschnittsnummer der
// AGENTS.md ist in einer Meldung ein Treffer.
func TestKennungenInTextGrenzen(t *testing.T) {
	for _, f := range [][2]string{
		{"siehe MR-077-statt-der", "MR-077"},
		{"siehe slice-082-foo", "slice-082"},
		{"die LH-QA-01-Bedingung", "LH-QA-01"},
		{"(DC-FA-CLI-009-x)", "DC-FA-CLI-009"},
		{"Festlegung in spezifikation.md von ai-harness-init", "Prosa: "},
		{"Spezifikation (v0.6.0) von ai-harness-init", "Prosa: "},
	} {
		if got := strings.Join(kennungenInText(f[0]), "|"); !strings.HasPrefix(got, f[1]) {
			t.Errorf("kennungenInText(%q) = %q, erwartet ein Treffer %q", f[0], got, f[1])
		}
	}
	for _, text := range []string{"x-slice-12", "ADR-00012", "ADR-0001x", "LH-QA-012", "Spezifikation. Danach von ai-harness-init"} {
		if ks := kennungenInText(text); len(ks) > 0 {
			t.Errorf("kennungenInText(%q) = %q, erwartet kein Treffer", text, ks)
		}
	}
	for _, text := range []string{"mit ADR nach AGENTS.md 3.5", "AGENTS.md §3.3"} {
		if ks := meldungsVerweise(text); len(ks) == 0 {
			t.Errorf("meldungsVerweise(%q) erkennt die Abschnittsnummer nicht", text)
		}
	}
}

// erlaubteKennungen ist die namentliche Ausnahme-Liste Datei → Kennungs-Menge ueber der
// realen Emission. Beide Eintraege sind funktionale Nutzlast: der Default-Commit-Text der
// Selbstpruefung (SELBSTPRUEFUNG_MSG_GRUEN) muss ein Kennungs-Muster des emittierten
// commit-msg-Traegers treffen, sonst faellt der gruene Probe-Commit am Traeger. Die Kennung
// LH-FA-01 loest im Ziel auf: dessen spec/lastenheft.md entsteht aus der vendored Vorlage
// spec/lastenheft.template.md und fuehrt die Saat-Anforderung `### LH-FA-01 — …`; sie zeigt
// damit auf eine Anforderung des Ziels, nicht auf eine dieses Repos.
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
// Baseline, kein Text dieses Werkzeugs; seinen realen Inhalt haelt full-smoke
// (fremde_kennungen_im_fragment), ebenso den von a-check.mk.
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
		for _, k := range kennungenInText(string(data)) {
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
// GRENZE: gelesen ist, was diese Varianten schreiben — der Bootstrap und add-lang an je
// einem Unterverzeichnis; Flag-Kombinationen ausserhalb der Liste unten laufen nicht.
// d-check.mk und a-check.mk kommen hier aus Fixtures (docMKFixture, archMKFixture); die
// reale --print-mk-Ausgabe der gepinnten Images haelt harness/tools/full-smoke.sh
// (fremde_kennungen_im_fragment).
// Erkannt sind die Formen aus kennungMuster; die Namensform slice-<name> nicht (dort
// benannt).
func TestEmittierteDateienTragenNurImZielAufloesendeKennungen(t *testing.T) {
	varianten := []struct {
		name      string
		args      []string
		ohneErfas bool
		nach      [][]string // add-lang-Laeufe nach dem Bootstrap, je ein Unterverzeichnis
	}{
		{"sprachlos", nil, false, nil},
		{"sprachlos-ohne-erfassung", nil, true, nil},
		{"go-flat", []string{"--lang", "go"}, false, nil},
		{"go-hexagonal", []string{"--lang", "go", "--arch", "hexagonal"}, false, nil},
		{"go-hexslice", []string{"--lang", "go", "--arch", "hexslice"}, false, nil},
		{"cpp-flat", []string{"--lang", "cpp"}, false, nil},
		{"cpp-hexslice", []string{"--lang", "cpp", "--arch", "hexslice"}, false, nil},
		{"kotlin-flat", []string{"--lang", "kotlin"}, false, nil},
		{"kotlin-hexslice", []string{"--lang", "kotlin", "--arch", "hexslice"}, false, nil},
		{"sprachlos-add-lang", nil, false, [][]string{
			{"add-lang", "kotlin", "apps/kt", "--arch", "hexslice"},
			{"add-lang", "cpp", "apps/cp"},
			{"add-lang", "go", "apps/go", "--arch", "hexagonal"},
		}},
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
		for _, a := range v.nach {
			if code := run(a, dir, src, &out, &errb); code != 0 {
				t.Fatalf("%s: %v exit %d: %s", v.name, a, code, errb.String())
			}
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

// traegerAusnahmen ist die namentliche Ausnahme-Liste des Meldungs-Waechters: Datei →
// Zeichenkette, deren Kennung funktionale Nutzlast ist. Sie ist leer: die Commit-Kennung
// von archive-welle nennt der Aufrufer (ADR-0090), der Traeger bringt keine mit. Ein
// Eintrag hier verlangt, dass die Kennung im Ziel aufloest.
func traegerAusnahmen() map[string][]string {
	return map[string][]string{}
}

// TestTraegerMeldungenTragenKeineKennung haelt, dass der Traeger in keiner Meldung eine
// Kennung dieses Repos oder einen Prosa-Verweis auf seine Norm-Artefakte ausgibt
// (LH-QA-01). Gelesen werden zwei Quellen: (1) jede Zeichenketten-Konstante im Quellcode
// von cmd/ und internal/ (ohne _test.go) — Hilfetexte, Fehler- und Format-Texte und
// Commit-Messages, auch die von Fehlerpfaden, die kein Test erreicht, und die
// Error()-Texte der Fehlertypen; (2) die reale Hilfe-Ausgabe von Init und add-lang.
// Kommentare sind keine Zeichenkette und zaehlen nicht.
//
// Dazu haelt er, dass keine Meldung eine Abschnittsnummer der AGENTS.md nennt
// (agentsAbschnittMuster): die Nummer ist die dieses Repos, im Ziel steht unter derselben
// Nummer eine andere Regel — die Meldung nennt die Regel im Klartext.
//
// GRENZE: eine Meldung, die ihre Kennung aus einer Datei oder einem Laufzeit-Wert
// zusammensetzt, sieht er nicht; ebenso keine Zeichenkette in einer eingebetteten
// Vorlage — die liest TestEmittierteDateienTragenNurImZielAufloesendeKennungen am Ziel.
// Geprueft wird je Literal (ast.BasicLit), nicht je Konstante: eine Kennung oder ein
// Prosa-Verweis, der ueber zwei mit `+` verbundene Literale laeuft (`"… ADR-" + "0007"`,
// ein Satz, der am `+` umbricht), faellt durch. Erkannt sind die Formen aus kennungMuster,
// prosaVerweisMuster und agentsAbschnittMuster; eine Abschnittsnummer in anderer Form
// („§3.5 der AGENTS.md", „Abschnitt 3.5") nicht.
func TestTraegerMeldungenTragenKeineKennung(t *testing.T) {
	ausnahme := traegerAusnahmen()
	var fehler []string
	gesehen := map[string]bool{}
	wurzel, err := filepath.Abs(filepath.Join("..", ".."))
	if err != nil {
		t.Fatalf("Repo-Wurzel: %v", err)
	}
	for _, teil := range []string{"cmd", "internal"} {
		err := filepath.WalkDir(filepath.Join(wurzel, teil), func(p string, d fs.DirEntry, err error) error {
			if err != nil {
				return err
			}
			if d.IsDir() && d.Name() == "testdata" {
				return filepath.SkipDir
			}
			if d.IsDir() || !strings.HasSuffix(p, ".go") || strings.HasSuffix(p, "_test.go") {
				return nil
			}
			rel, _ := filepath.Rel(wurzel, p)
			rel = filepath.ToSlash(rel)
			fset := token.NewFileSet()
			datei, err := parser.ParseFile(fset, p, nil, parser.SkipObjectResolution)
			if err != nil {
				return err
			}
			ast.Inspect(datei, func(n ast.Node) bool {
				lit, ok := n.(*ast.BasicLit)
				if !ok || lit.Kind != token.STRING {
					return true
				}
				if slices.Contains(ausnahme[rel], lit.Value) {
					gesehen[rel+" "+lit.Value] = true
					return true
				}
				wert, err := strconv.Unquote(lit.Value)
				if err != nil {
					wert = lit.Value
				}
				if ks := meldungsVerweise(wert); len(ks) > 0 {
					fehler = append(fehler, fmt.Sprintf("  %s:%d: %s", rel, fset.Position(lit.Pos()).Line, strings.Join(ks, ", ")))
				}
				return true
			})
			return nil
		})
		if err != nil {
			t.Fatalf("Quellcode lesen: %v", err)
		}
	}
	for f, ws := range ausnahme {
		for _, w := range ws {
			if !gesehen[f+" "+w] {
				fehler = append(fehler, "  "+f+": die Ausnahme "+w+" steht dort nicht")
			}
		}
	}
	for _, args := range [][]string{{"--help"}, {"add-lang", "--help"}} {
		var out, errb bytes.Buffer
		run(args, t.TempDir(), testSources(t), &out, &errb)
		if ks := meldungsVerweise(out.String() + errb.String()); len(ks) > 0 {
			fehler = append(fehler, "  Hilfe "+strings.Join(args, " ")+": "+strings.Join(ks, ", "))
		}
	}
	if len(fehler) > 0 {
		sort.Strings(fehler)
		t.Errorf("der Traeger gibt Kennungen dieses Repos aus — im Ziel loest keine davon auf (LH-QA-01):\n%s", strings.Join(fehler, "\n"))
	}
}
