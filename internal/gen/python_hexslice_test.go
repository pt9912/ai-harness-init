package gen_test

import (
	"path/filepath"
	"regexp"
	"strings"
	"testing"

	"github.com/pt9912/ai-harness-init/internal/gen"
)

// genPythonHexslice generiert das hexSlice-Python-Skelett in ein frisches Temp-Verzeichnis.
func genPythonHexslice(t *testing.T) string {
	t.Helper()
	dir := t.TempDir()
	if err := gen.GenerateArch(dir, "python", gen.DefaultPythonVersion, "hexslice"); err != nil {
		t.Fatalf("GenerateArch(python, hexslice): %v", err)
	}
	return dir
}

// TestGenerate_PythonHexsliceProfile_FileSet (LH-FA-04, ADR-0095 Festlegung 5): --arch hexslice
// erzeugt GENAU die Rollen-Dateien unter src/app/{hexagon,adapters} plus Composition Root, Test
// und die arch-invariante Geruestung, dazu je Paket-Verzeichnis eine __init__.py — nicht mehr,
// nicht weniger.
func TestGenerate_PythonHexsliceProfile_FileSet(t *testing.T) {
	got := walkRel(t, genPythonHexslice(t))
	const a, h = "src/app/adapters/", "src/app/hexagon/"
	want := []string{
		"Dockerfile", "pyproject.toml", "requirements-dev.txt",
		"src/app/__init__.py",
		a + "__init__.py",
		a + "driven/__init__.py",
		a + "driven/memory/__init__.py",
		a + "driven/memory/example/__init__.py",
		a + "driven/memory/example/in_memory_repository.py",
		a + "driven/notify/__init__.py",
		a + "driven/notify/stdout_notifier.py",
		a + "driving/__init__.py",
		a + "driving/cli/__init__.py",
		a + "driving/cli/example/__init__.py",
		a + "driving/cli/example/cli.py",
		h + "__init__.py",
		h + "application/__init__.py",
		h + "application/example/__init__.py",
		h + "application/example/greet/__init__.py",
		h + "application/example/greet/handler.py",
		h + "application/example/greet/ports/__init__.py",
		h + "application/example/greet/ports/inbound/__init__.py",
		h + "application/example/greet/ports/inbound/greet.py",
		h + "application/example/greet/ports/outbound/__init__.py",
		h + "application/example/greet/ports/outbound/notifier.py",
		h + "application/example/ports/__init__.py",
		h + "application/example/ports/outbound/__init__.py",
		h + "application/example/ports/outbound/greeting_repository.py",
		h + "domain/__init__.py",
		h + "domain/example/__init__.py",
		h + "domain/example/greeting.py",
		"src/app/main.py",
		"tests/test_greet.py",
	}
	if strings.Join(got, ",") != strings.Join(want, ",") {
		t.Errorf("python-hexSlice-Datei-Satz = %v\nwant %v", got, want)
	}
}

// TestPythonHexslice_InitsLeer: jede __init__.py des hexSlice-Skeletts ist leer. Die Config
// ordnet nur Dateien einer Schicht zu, die einen Import tragen koennen; ein Paket-Marker mit
// Import faellt ausserhalb einer Schicht (src/app/hexagon/__init__.py) unter keinen Glob. a-check
// meldet seinen Import in eine Schicht als wrong-direction; ungeprueft bliebe nur ein Import, dessen
// Ziel selbst in keiner Schicht liegt oder nicht aufloest.
// Rot-Gegenbeispiel: test/mutations/732 legt Inhalt in die Marker.
func TestPythonHexslice_InitsLeer(t *testing.T) {
	dir := genPythonHexslice(t)
	n := 0
	for _, rel := range walkRel(t, dir) {
		if filepath.Base(rel) != "__init__.py" {
			continue
		}
		n++
		if got := mustRead(t, filepath.Join(dir, filepath.FromSlash(rel))); got != "" {
			t.Errorf("%s ist nicht leer: %q", rel, got)
		}
	}
	if n == 0 {
		t.Fatal("keine __init__.py im Skelett")
	}
}

// TestPythonHexslice_NurAbsoluteImporte (ADR-0095 Festlegung 5): jede `from`-Zeile einer
// Python-Datei des Skeletts ist absolut. a-check extrahiert einen relativen Import nicht
// (Hinweis, Exit 0); ein relativer Import im Skelett entginge dem Arch-Gate. Die ruff-Regel
// TID252 haelt dasselbe fuer den Code des Adopters, der Text-Test fuer das Skelett selbst.
// Rot-Gegenbeispiel: test/mutations/733.
func TestPythonHexslice_NurAbsoluteImporte(t *testing.T) {
	dir := genPythonHexslice(t)
	rel := regexp.MustCompile(`(?m)^\s*from\s+\.`)
	n := 0
	for _, f := range walkRel(t, dir) {
		if !strings.HasSuffix(f, ".py") {
			continue
		}
		n++
		if m := rel.FindString(mustRead(t, filepath.Join(dir, filepath.FromSlash(f)))); m != "" {
			t.Errorf("%s traegt einen relativen Import (%q) — a-check extrahiert ihn nicht", f, strings.TrimSpace(m))
		}
	}
	if n == 0 {
		t.Fatal("keine Python-Datei im Skelett")
	}
}

// pythonConfigResolution zieht languages-Glob, mode, roots und package_base aus der Config.
// Jeder Schluessel wird einzeln und woertlich gelesen: ein verfaelschter Wert faerbt genau
// die Aussage, die er traegt.
func pythonConfigResolution(t *testing.T, cfg string) (langGlob, mode string, roots []string, base string) {
	t.Helper()
	return archConfigResolution(t, cfg, "python")
}

// TestArchGateConfig_PythonResolution (ADR-0095 Festlegung 5, LH-FA-07): die Config traegt
// `languages: python: ["**/*.py"]`, `exclude: ["tests/**"]`, `composition_root:
// ["src/app/main.py"]` und `resolution: python: {mode: fixed-root, roots: ["src/app"],
// package_base: "app"}` je Schluessel woertlich; der Root endet im package_base-Verzeichnis,
// und jede gerenderte Produktionsdatei ausser dem Composition Root liegt unter diesem Root.
// Ein verfaelschter Schluessel faerbt den Test: test/mutations/734 (mode), 735 (roots), 736
// (package_base), 737 (languages-Glob), 738 (exclude), 746 (composition_root), 745 (Pfade
// ausserhalb des Roots). Dass a-check den Import im gebootstrappten Ziel wirklich aufloest,
// belegt allein die Stufe in full-smoke.
func TestArchGateConfig_PythonResolution(t *testing.T) {
	cfg, ok := gen.ArchGateConfig("python", "hexslice")
	if !ok {
		t.Fatal("python+hexslice traegt keine Arch-Gate-Config")
	}
	langGlob, mode, roots, base := pythonConfigResolution(t, cfg)
	if langGlob != "**/*.py" {
		t.Errorf("languages python = %q, want **/*.py", langGlob)
	}
	if mode != "fixed-root" {
		t.Errorf("resolution python mode = %q, want fixed-root", mode)
	}
	if len(roots) != 1 || roots[0] != "src/app" {
		t.Errorf("resolution python roots = %v, want [src/app]", roots)
	}
	if base != "app" {
		t.Errorf("resolution python package_base = %q, want app", base)
	}
	if len(roots) != 1 || !strings.HasSuffix(roots[0], "/"+base) {
		t.Errorf("Root %v endet nicht im package_base-Verzeichnis %q (a-check streift package_base vor dem Root ab)", roots, base)
	}
	const mainPy = "src/app/main.py"
	if !strings.Contains(cfg, "\ncomposition_root: [\""+mainPy+"\"]\n") {
		t.Errorf("composition_root ist nicht %s:\n%s", mainPy, cfg)
	}
	if !strings.Contains(cfg, "\nexclude:\n  - \"tests/**\"\n") {
		t.Errorf("exclude ist nicht [tests/**]:\n%s", cfg)
	}
	for _, rel := range walkRel(t, genPythonHexslice(t)) {
		if !strings.HasPrefix(rel, "src/") || rel == mainPy || !strings.HasSuffix(rel, ".py") {
			continue
		}
		if len(roots) == 1 && !strings.HasPrefix(rel, roots[0]+"/") {
			t.Errorf("%s liegt nicht unter dem Root %s der Config (a-check loeste keinen Import dorthin auf)", rel, roots[0])
		}
	}
}

// TestArchGateConfig_PythonMatchesSkeleton (ADR-0095 Festlegung 5, LH-FA-07): jede
// Produktionsdatei mit Inhalt ausserhalb des Composition Root faellt unter den erwarteten
// Schicht-Glob, und jeder Glob ist fuer mindestens eine Datei der spezifischste. Die Erwartung
// steht ausgeschrieben, nicht aus der Config abgeleitet. Die leeren __init__.py nimmt der Test
// aus (TestPythonHexslice_InitsLeer haelt, dass sie keinen Import tragen), Tests liegen unter
// tests/.
func TestArchGateConfig_PythonMatchesSkeleton(t *testing.T) {
	cfg, ok := gen.ArchGateConfig("python", "hexslice")
	if !ok {
		t.Fatal("python+hexslice traegt keine Arch-Gate-Config")
	}
	const hex, ad = "src/app/hexagon/", "src/app/adapters/"
	want := map[string]string{
		hex + "domain/example/greeting.py":                                    "domain",
		hex + "application/example/greet/ports/inbound/greet.py":              "ports_inbound",
		hex + "application/example/greet/ports/outbound/notifier.py":          "ports_outbound",
		hex + "application/example/ports/outbound/greeting_repository.py":     "ports_outbound",
		hex + "application/example/greet/handler.py":                          "app",
		ad + "driving/cli/example/cli.py":                                     "driving_adapters",
		ad + "driven/memory/example/in_memory_repository.py":                  "driven_adapters",
		ad + "driven/notify/stdout_notifier.py":                               "driven_adapters",
	}
	nurTestOderMarker := func(rel string) bool {
		return strings.HasPrefix(rel, "tests/") || filepath.Base(rel) == "__init__.py"
	}
	assertGlobsMatchSkeleton(t, cfg, genPythonHexslice(t), ".py", "src/app/main.py", want, nurTestOderMarker)
}

// TestArchGateConfig_PythonEdgesMatchSkeleton (ADR-0095 Festlegung 5, LH-FA-07): jeder
// `from app.… import …` einer Produktionsdatei wird so aufgeloest, wie a-check es mit dem
// resolution-Block der Config tut (package_base abstreifen, Punkte zu "/", Root voran, ".py"
// an). Dann gilt in beide Richtungen: jeder Import loest auf eine Datei des Skeletts und eine
// Schicht auf und hat seine Kante — darunter driven_adapters->ports_outbound, den die
// Vererbung vom Port braucht —, und jede deklarierte Kante wird von einem Import gebraucht.
// Ein Root, der nicht im package_base-Verzeichnis endet, loest keinen Import auf und faerbt den
// Test rot — test/mutations/735 setzt genau diesen Root; 741 streicht die Port-Kante, 747
// deklariert eine ungebrauchte.
func TestArchGateConfig_PythonEdgesMatchSkeleton(t *testing.T) {
	cfg, _ := gen.ArchGateConfig("python", "hexslice")
	globs := archGlobs(t, cfg)
	declared := archEdges(t, cfg)
	_, _, roots, base := pythonConfigResolution(t, cfg)
	if len(roots) != 1 {
		t.Fatalf("roots = %v, want genau ein Root", roots)
	}
	root := roots[0]
	dir := genPythonHexslice(t)
	files := map[string]bool{}
	for _, rel := range walkRel(t, dir) {
		files[rel] = true
	}
	importRe := regexp.MustCompile(`(?m)^from (` + regexp.QuoteMeta(base) + `(?:\.[a-z_]+)+) import`)
	used := map[string]bool{}
	n := 0
	for _, rel := range walkRel(t, dir) {
		if !strings.HasPrefix(rel, "src/app/") || rel == "src/app/main.py" || !strings.HasSuffix(rel, ".py") {
			continue
		}
		from, _ := mostSpecific(globs, rel)
		for _, m := range importRe.FindAllStringSubmatch(mustRead(t, filepath.Join(dir, filepath.FromSlash(rel))), -1) {
			n++
			cand := root + "/" + strings.ReplaceAll(strings.TrimPrefix(m[1], base+"."), ".", "/") + ".py"
			if !files[cand] {
				t.Errorf("%s: import %s loest auf %s auf, die Datei gibt es im Skelett nicht (das Gate saehe ihn nicht)", rel, m[1], cand)
				continue
			}
			to, _ := mostSpecific(globs, cand)
			if to == "" {
				t.Errorf("%s: import %s loest auf %s auf und trifft keine Schicht (das Gate saehe ihn nicht)", rel, m[1], cand)
				continue
			}
			if to == from {
				continue
			}
			edge := from + "->" + to
			used[edge] = true
			if !declared[edge] {
				t.Errorf("%s importiert %s (%s), die Config deklariert keine Kante %s", rel, m[1], to, edge)
			}
		}
	}
	if n == 0 {
		t.Fatal("kein app-Import in den Produktionsdateien des Skeletts")
	}
	for edge := range declared {
		if !used[edge] {
			t.Errorf("Kante %s ist deklariert, wird aber von keinem aufgeloesten Import gebraucht", edge)
		}
	}
	if !used["driven_adapters->ports_outbound"] {
		t.Error("kein Adapter importiert seinen Port — die Vererbungs-Kante driven_adapters->ports_outbound ist im Skelett ungenutzt")
	}
}
