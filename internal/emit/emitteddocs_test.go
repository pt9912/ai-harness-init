package emit_test

import (
	"io/fs"
	"os"
	"path/filepath"
	"strings"
	"testing"
	"testing/fstest"

	"github.com/pt9912/ai-harness-init/internal/emit"
	"github.com/pt9912/ai-harness-init/internal/gen"
)

// claimsIn liest die `make`-Ziel-Ansprueche eines Dokuments — bewusst OHNE die
// Regexp der Emit-Seite: es zerlegt am Wort `make ` und nimmt den folgenden Namen
// zeichenweise. Eine gemeinsame Erfassung waere in beiden Richtungen gleich blind;
// so faellt ein Loch in der Emit-Regel hier auf.
//
// Ein unmittelbar folgender Stern macht die Nennung zu einem Muster
// (`make verify-*`) und damit zu keinem Anspruch — die Lesart von ADR-0020
// Festlegung 4(e).
func claimsIn(doc string) []string {
	var out []string
	for _, part := range strings.Split(doc, "make ")[1:] {
		i := 0
		for i < len(part) && (part[i] >= 'a' && part[i] <= 'z' || part[i] >= '0' && part[i] <= '9' || part[i] == '-') {
			i++
		}
		if i == 0 || part[0] < 'a' || part[0] > 'z' {
			continue // kein Ziel-Name an dieser Stelle
		}
		if i < len(part) && part[i] == '*' {
			continue // Muster, kein Anspruch
		}
		out = append(out, part[:i])
	}
	return out
}

// rulesIn liest die Ziele, die ein Make-Fragment definiert oder an GATE_CHECKS
// haengt — ebenfalls unabhaengig von der Emit-Seite, Zeile fuer Zeile.
func rulesIn(fragment string) []string {
	var out []string
	for _, line := range strings.Split(fragment, "\n") {
		if rest, ok := strings.CutPrefix(line, "GATE_CHECKS"); ok {
			if add, isAdd := strings.CutPrefix(strings.TrimLeft(rest, " \t"), "+="); isAdd {
				out = append(out, strings.Fields(add)...)
			}
			continue
		}
		name, _, ok := strings.Cut(line, ":")
		if !ok || name == "" || name != strings.TrimLeft(name, " \t.") {
			continue
		}
		if strings.TrimRight(name, "abcdefghijklmnopqrstuvwxyz0123456789-") == "" {
			out = append(out, name)
		}
	}
	return out
}

// claimSet legt ueber den Kurs-Satz aus courseSet die Anspruchs-FORMEN, die der
// vendored Bestand traegt: die Gate-TABELLE der zwei Doku-Tische, die
// PROSA-Nennung des Closure-Note-Reviewer-Skills und eine Nennung in der
// Root-README-Vorlage (eigener Emit-Schritt). `make gates` steht daneben als
// erlaubtes Ziel — ohne es koennte der Waechter nicht zeigen, dass er zwischen
// erfuellbarem und unerfuellbarem Anspruch unterscheidet.
func claimSet(t *testing.T) fs.FS {
	t.Helper()
	base, ok := courseSet().(fstest.MapFS)
	if !ok {
		t.Fatalf("courseSet liefert kein fstest.MapFS — die Fixture-Kopplung greift nicht")
	}
	out := fstest.MapFS{}
	for k, v := range base {
		out[k] = v
	}
	hint := "> **Template-Hinweis.** Vorlage.\n\n"
	f := func(s string) *fstest.MapFile { return &fstest.MapFile{Data: []byte(s)} }
	table := hint + "# <Projektname>\n\n| Target | Zweck |\n|---|---|\n" +
		"| `make lint` | <…> |\n" +
		"| `make gates` | alle inneren Gates |\n" +
		"| `make fullbuild` | volle Closure |\n\n" +
		"Lokal `make help` bzw. `make gates`.\n"
	out["AGENTS.template.md"] = f(table)
	out["harness/README.template.md"] = f(table)
	out[".harness/skills/closure-note-reviewer.template.md"] = f(hint +
		"# <Projektname>\n\nDas Ergebnis von `make verify-closure-notes` fuer denselben Stand.\n")
	out["project-readme.template.md"] = f(hint +
		"# <Projektname>\n\nOut of the box gruen: `make gates`. CI-aequivalent: `make ci`.\n")
	return out
}

// TestEmittierteDokumente_NurInitInvarianteZiele haelt die Eigenschaft aus
// slice-087 fest: ueber dem GANZEN emittierten Dokument-Satz ist die Menge der
// behaupteten `make`-Ziele eine Teilmenge der Ziel-Menge, die die Init-Phase in
// jeder Bootstrap-Variante schreibt (LH-QA-01, ADR-0020 Festlegung 4(e)).
//
// Weder die Ziele noch die Dokumente sind aufgezaehlt: die Ziel-Menge liest
// emit.InitInvariantTargets aus den Fragmenten, der Dokument-Satz entsteht durch
// einen echten Emit ins Zielverzeichnis. GRENZE, benannt: gedeckt sind die fuenf
// Emitter, die heute Dokumente schreiben (Templates, RootReadme, Commands,
// Agents, FieldList) — ein SECHSTER fiele heraus, bis er hier steht.
//
// Agents und FieldList stehen hier, weil ihre Dokumente denselben Weg ins Ziel gehen
// wie die uebrigen: sie landen im geprueften Bereich, und ein Anspruch auf ein Ziel,
// das die Init-Phase nicht schreibt, waere dort dasselbe halluzinierte Gate (LH-QA-01).
func TestEmittierteDokumente_NurInitInvarianteZiele(t *testing.T) {
	src := claimSet(t)
	dir := t.TempDir()
	if err := emit.Templates(src, dir, "Demo"); err != nil {
		t.Fatalf("Templates: %v", err)
	}
	if err := emit.RootReadme(src, dir, "Demo"); err != nil {
		t.Fatalf("RootReadme: %v", err)
	}
	if err := emit.Commands(dir); err != nil {
		t.Fatalf("Commands: %v", err)
	}
	if err := emit.Agents(dir); err != nil {
		t.Fatalf("Agents: %v", err)
	}
	if err := emit.FieldList(dir); err != nil {
		t.Fatalf("FieldList: %v", err)
	}

	targets, err := emit.InitInvariantTargets()
	if err != nil {
		t.Fatalf("InitInvariantTargets: %v", err)
	}
	invariant := map[string]bool{}
	for _, target := range targets {
		invariant[target] = true
	}

	// Vorbedingung: die Quelle traegt ueberhaupt einen unerfuellbaren Anspruch.
	// Ohne sie liefe der Waechter ueber sauberem Eingang und sagte nichts.
	var unerfuellbar int
	if walkErr := fs.WalkDir(src, ".", func(rel string, d fs.DirEntry, err error) error {
		if err != nil || d.IsDir() || !strings.HasSuffix(rel, ".md") {
			return err
		}
		content, readErr := fs.ReadFile(src, rel)
		if readErr != nil {
			return readErr
		}
		for _, claim := range claimsIn(string(content)) {
			if !invariant[claim] {
				unerfuellbar++
			}
		}
		return nil
	}); walkErr != nil {
		t.Fatalf("Quell-Satz lesen: %v", walkErr)
	}
	if unerfuellbar == 0 {
		t.Fatalf("die Quelle traegt keinen unerfuellbaren Anspruch — der Waechter misst nichts")
	}

	var dokumente, erlaubte int
	walkErr := filepath.WalkDir(dir, func(p string, d fs.DirEntry, err error) error {
		if err != nil || d.IsDir() || !strings.HasSuffix(p, ".md") {
			return err
		}
		content, readErr := os.ReadFile(p)
		if readErr != nil {
			return readErr
		}
		dokumente++
		rel, _ := filepath.Rel(dir, p)
		for _, claim := range claimsIn(string(content)) {
			if !invariant[claim] {
				t.Errorf("emittiertes Dokument %s behauptet `make %s` — die Init-Phase schreibt nur %v", rel, claim, targets)
				continue
			}
			erlaubte++
		}
		return nil
	})
	if walkErr != nil {
		t.Fatalf("emittierten Satz lesen: %v", walkErr)
	}
	if dokumente == 0 {
		t.Fatalf("kein emittiertes Dokument gefunden — der Waechter lief ueber leerem Bestand")
	}
	if erlaubte == 0 {
		t.Fatalf("kein erlaubter Anspruch ueberlebt den Emit — der Scanner findet nichts, oder die Neutralisierung raeumt zu breit")
	}
}

// TestInitInvarianteZiele_OhneSprachphase haelt die Trennung fest, an der dieser
// Slice haengt: kein Ziel des Code-Gate-Fragments liegt in der init-invarianten
// Menge. test/lint/build entstehen erst mit --lang und fehlen im sprachlosen
// Ziel; ein Doku-Anspruch auf sie ist in genau einer Variante wahr und damit
// unentscheidbar (ADR-0020 Festlegung 4(e)).
func TestInitInvarianteZiele_OhneSprachphase(t *testing.T) {
	targets, err := emit.InitInvariantTargets()
	if err != nil {
		t.Fatalf("InitInvariantTargets: %v", err)
	}
	invariant := map[string]bool{}
	for _, target := range targets {
		invariant[target] = true
	}
	if !invariant["gates"] {
		t.Errorf("`gates` fehlt in der init-invarianten Menge %v — der Aggregator wird nicht gelesen", targets)
	}
	if !invariant["docs-check"] {
		t.Errorf("`docs-check` fehlt in der init-invarianten Menge %v — die GATE_CHECKS-Kante wird nicht gelesen", targets)
	}
	var geprueft int
	for _, lang := range gen.SupportedLangs() {
		fragment, fragErr := gen.CodeGateFragment(lang, ".", gen.DefaultVersion(lang))
		if fragErr != nil {
			t.Fatalf("CodeGateFragment(%s): %v", lang, fragErr)
		}
		for _, target := range rulesIn(fragment) {
			geprueft++
			if invariant[target] {
				t.Errorf("`%s` stammt aus dem %s-Code-Gate-Fragment und liegt trotzdem in der init-invarianten Menge %v", target, lang, targets)
			}
		}
	}
	if geprueft == 0 {
		t.Fatalf("kein Ziel aus einem Code-Gate-Fragment gelesen — die Gegenprobe misst nichts")
	}
}

// TestNeutralizeMakeClaims_MusterBleibtStehen haelt die eine Ausnahme der
// Neutralisierung fest: `make verify-*` nennt ein Muster und kein Ziel. Ohne sie
// verloere ein emittierter Workflow-Command seine Sensor-Anweisung, und der
// Waechter oben saehe es nicht — er ueberliest Muster ebenfalls.
func TestNeutralizeMakeClaims_MusterBleibtStehen(t *testing.T) {
	in := "Sensoren: `make verify-*`, `make gates`, `make fullbuild`."
	want := "Sensoren: `make verify-*`, `make gates`, `<make-target>`."
	if got := emit.NeutralizeMakeClaims(in, []string{"gates"}); got != want {
		t.Errorf("NeutralizeMakeClaims:\n got %q\nwant %q", got, want)
	}
}
