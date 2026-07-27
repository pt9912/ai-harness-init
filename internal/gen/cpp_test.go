package gen_test

import (
	"path/filepath"
	"regexp"
	"strings"
	"testing"

	"github.com/pt9912/ai-harness-init/internal/gen"
)

// genCppWith generiert das cpp-Skelett mit einer expliziten ubuntu-Version.
func genCppWith(t *testing.T, version string) string {
	t.Helper()
	dir := t.TempDir()
	if err := gen.Generate(dir, "cpp", version); err != nil {
		t.Fatalf("Generate(cpp, %q): %v", version, err)
	}
	return dir
}

// TestGenerate_CppProfile: --lang cpp erzeugt GENAU den erwarteten Skelett-Satz
// (LH-FA-04 Generator-Teil, slice-039) — CMake-Projekt, baubares main, netzloser Test,
// Dockerfile + .clang-tidy — nicht mehr, nicht weniger. Das Code-Gate-Fragment ist wie
// bei go NICHT im Skelett (kommt aus gen.CodeGateFragment).
func TestGenerate_CppProfile(t *testing.T) {
	dir := genCppWith(t, gen.DefaultCppVersion)
	got := walkRel(t, dir)
	want := []string{
		".clang-tidy", "CMakeLists.txt", "Dockerfile",
		"src/main.cpp", "tests/CMakeLists.txt", "tests/test_main.cpp",
	}
	if strings.Join(got, ",") != strings.Join(want, ",") {
		t.Errorf("erzeugter Datei-Satz = %v\nwant %v", got, want)
	}
	assertFileContains(t, filepath.Join(dir, "CMakeLists.txt"), "project(app CXX)")
	assertFileContains(t, filepath.Join(dir, "src", "main.cpp"), "int main()")
	assertFileContains(t, filepath.Join(dir, "tests", "CMakeLists.txt"), "add_test(")
}

// TestGenerate_CppTestNetzlos: der cpp-Test darf KEIN externes Framework ziehen
// (LH-QA-03, netzlos) — kein FetchContent/find_package(GTest)/#include <gtest>. Er belegt
// den Build+CTest-Lauf mit einem reinen Exit-Code-main (assert-frei, greift auch unter NDEBUG).
func TestGenerate_CppTestNetzlos(t *testing.T) {
	dir := genCppWith(t, gen.DefaultCppVersion)
	test := mustRead(t, filepath.Join(dir, "tests", "test_main.cpp"))
	for _, forbidden := range []string{"gtest", "catch2", "doctest", "FetchContent"} {
		if strings.Contains(strings.ToLower(test), strings.ToLower(forbidden)) {
			t.Errorf("cpp-Test zieht externes Framework %q (nicht netzlos, LH-QA-03):\n%s", forbidden, test)
		}
	}
	testCMake := mustRead(t, filepath.Join(dir, "tests", "CMakeLists.txt"))
	for _, forbidden := range []string{"FetchContent", "find_package", "ExternalProject"} {
		if strings.Contains(testCMake, forbidden) {
			t.Errorf("tests/CMakeLists.txt zieht externe Abhaengigkeit %q (nicht netzlos):\n%s", forbidden, testCMake)
		}
	}
}

// TestGenerate_CppDeterministic haelt LH-QA-02 fuer cpp: zwei Laeufe mit gleicher Version
// liefern byte-identische Dateien.
func TestGenerate_CppDeterministic(t *testing.T) {
	d1, d2 := genCppWith(t, gen.DefaultCppVersion), genCppWith(t, gen.DefaultCppVersion)
	rels := walkRel(t, d1)
	if strings.Join(rels, ",") != strings.Join(walkRel(t, d2), ",") {
		t.Fatal("zwei cpp-Laeufe erzeugten verschiedene Datei-Saetze")
	}
	for _, rel := range rels {
		a := mustRead(t, filepath.Join(d1, filepath.FromSlash(rel)))
		b := mustRead(t, filepath.Join(d2, filepath.FromSlash(rel)))
		if a != b {
			t.Errorf("%s unterscheidet sich zwischen zwei cpp-Laeufen", rel)
		}
	}
}

// TestCppCodeGateFragment_TargetsMatchStages ist der LH-QA-01-Anker fuer cpp: jedes
// `docker build --target <X>` im Fragment muss eine gleichnamige Dockerfile-Stage `AS <X>`
// haben — sonst halluziniertes Gate. Geprueft fuer Root (unscoped) + Subdir (modul-scoped).
func TestCppCodeGateFragment_TargetsMatchStages(t *testing.T) {
	dir := genCppWith(t, gen.DefaultCppVersion)
	df := mustRead(t, filepath.Join(dir, "Dockerfile"))
	stages := map[string]bool{}
	for _, m := range regexp.MustCompile(`\bAS (\w+)`).FindAllStringSubmatch(df, -1) {
		stages[m[1]] = true
	}
	for _, path := range []string{".", "apps/engine"} {
		mk, err := gen.CodeGateFragment("cpp", path, gen.DefaultCppVersion)
		if err != nil {
			t.Fatalf("CodeGateFragment(cpp, %q): %v", path, err)
		}
		targets := regexp.MustCompile(`--target (\w+)`).FindAllStringSubmatch(mk, -1)
		if len(targets) == 0 {
			t.Fatalf("kein `--target` im cpp-Fragment (%q) — der Test waere zahnlos", path)
		}
		for _, m := range targets {
			if !stages[m[1]] {
				t.Errorf("cpp-Fragment (%q) ruft `--target %s`, aber Dockerfile hat keine Stage `AS %s`", path, m[1], m[1])
			}
		}
	}
}

// TestCppCodeGateFragment_Root: die Root-Fassung haengt lint/build/test via GATE_CHECKS an
// (kein eigenes gates:-Target) und baut im Root-Kontext.
func TestCppCodeGateFragment_Root(t *testing.T) {
	mk, err := gen.CodeGateFragment("cpp", ".", gen.DefaultCppVersion)
	if err != nil {
		t.Fatalf("CodeGateFragment(cpp, .): %v", err)
	}
	if !strings.Contains(mk, "GATE_CHECKS += lint build test") {
		t.Errorf("cpp-Root-Fragment haengt lint/build/test nicht an GATE_CHECKS:\n%s", mk)
	}
	if strings.Contains(mk, "\ngates:") {
		t.Errorf("cpp-Fragment definiert ein eigenes gates:-Target (umgeht die Ordnungskante):\n%s", mk)
	}
	if !strings.Contains(mk, "--target test -t $(IMAGE):test .") {
		t.Errorf("cpp-Root-Fragment baut nicht im Root-Kontext (`docker build .`):\n%s", mk)
	}
}

// TestCppCodeGateFragment_ScopedSubdir: eine Subdir-Fassung traegt modul-scoped Targets
// (kollisionsfrei im Mono-Repo) und baut im <pfad>-Kontext, nie im Root.
func TestCppCodeGateFragment_ScopedSubdir(t *testing.T) {
	mk, err := gen.CodeGateFragment("cpp", "apps/engine", gen.DefaultCppVersion)
	if err != nil {
		t.Fatalf("CodeGateFragment(cpp, apps/engine): %v", err)
	}
	for _, want := range []string{
		"test-apps-engine:", "lint-apps-engine:", "build-apps-engine:",
		"GATE_CHECKS += lint-apps-engine build-apps-engine test-apps-engine",
		"--target test -t apps-engine:test apps/engine",
	} {
		if !strings.Contains(mk, want) {
			t.Errorf("modul-scoped cpp-Fragment enthaelt %q nicht:\n%s", want, mk)
		}
	}
	for _, forbidden := range []string{"\ntest:", "\nlint:", "\nbuild:", "GATE_CHECKS += lint build test"} {
		if strings.Contains(mk, forbidden) {
			t.Errorf("modul-scoped cpp-Fragment traegt unscoped Target %q (Kollisionsrisiko):\n%s", forbidden, mk)
		}
	}
}

// TestGenerate_CppVersionThreaded belegt, dass die uebergebene ubuntu-Version wirklich ins
// Skelett UND ins Fragment faedelt: das Dockerfile-ARG traegt sie, das Fragment den
// CXX_VERSION-Default. Damit ist der SKEL_CPP_VERSION-Knopf (cmd) am Generator verankert.
func TestGenerate_CppVersionThreaded(t *testing.T) {
	dir := genCppWith(t, "22.04")
	df := mustRead(t, filepath.Join(dir, "Dockerfile"))
	if got := firstSub(t, regexp.MustCompile(`ARG CXX_VERSION=(\S+)`), df); got != "22.04" {
		t.Errorf("Dockerfile ARG CXX_VERSION = %q, want 22.04", got)
	}
	mk, err := gen.CodeGateFragment("cpp", ".", "22.04")
	if err != nil {
		t.Fatalf("CodeGateFragment(cpp, ., 22.04): %v", err)
	}
	if got := firstSub(t, regexp.MustCompile(`CXX_VERSION \?= (\S+)`), mk); got != "22.04" {
		t.Errorf("Fragment CXX_VERSION-Default = %q, want 22.04", got)
	}
}

// genCppArch generiert das cpp-Skelett fuer eine Architektur in ein frisches Temp-Verzeichnis.
func genCppArch(t *testing.T, arch string) string {
	t.Helper()
	dir := t.TempDir()
	if err := gen.GenerateArch(dir, "cpp", gen.DefaultCppVersion, arch); err != nil {
		t.Fatalf("GenerateArch(cpp, %q): %v", arch, err)
	}
	return dir
}

// TestGenerate_CppHexsliceProfile_FileSet (slice-053, ADR-0009): --arch hexslice erzeugt
// GENAU die kanonischen hexSlice-Rollen-Dateien PLUS die arch-invariante Bau-Gerueestung.
// Die Mutation "eine Schicht-Datei aus cppRole entfernen" faerbt diesen Test rot.
func TestGenerate_CppHexsliceProfile_FileSet(t *testing.T) {
	got := walkRel(t, genCppArch(t, "hexslice"))
	want := []string{
		".clang-tidy",
		"CMakeLists.txt",
		"Dockerfile",
		"src/adapters/inbound/cli/example/cli.hpp",
		"src/adapters/outbound/memory/example/repository.hpp",
		"src/adapters/outbound/notify/stdout.hpp",
		"src/hexagon/application/example/greet/command.hpp",
		"src/hexagon/application/example/greet/handler.hpp",
		"src/hexagon/application/example/greet/ports/notifier.hpp",
		"src/hexagon/application/example/ports/greeting_repository.hpp",
		"src/hexagon/domain/example/greeting.hpp",
		"src/main.cpp",
		"tests/CMakeLists.txt",
		"tests/test_greet.cpp",
	}
	if strings.Join(got, ",") != strings.Join(want, ",") {
		t.Errorf("cpp-hexSlice-Datei-Satz = %v\nwant %v", got, want)
	}
}

// TestGenerate_CppHexsliceIncludesAreModuleRootRelative (slice-053) ist der Zahn unter der
// Arch-Gate-Sichtbarkeit: a-check loest NUR modul-root-relative Include-Strings auf
// ("src/hexagon/..."). Ein relativer ("../...") oder praefixloser ("hexagon/...") Include
// uebersetzt zwar — bleibt dem Gate aber UNSICHTBAR, und ein verbotener Import faellt
// still durch (LH-QA-01, gemessen 2026-07-27 gegen das gepinnte a-check-Image).
func TestGenerate_CppHexsliceIncludesAreModuleRootRelative(t *testing.T) {
	dir := genCppArch(t, "hexslice")
	for _, rel := range walkRel(t, dir) {
		if !strings.HasSuffix(rel, ".hpp") && !strings.HasSuffix(rel, ".cpp") {
			continue
		}
		for _, line := range strings.Split(mustRead(t, filepath.Join(dir, filepath.FromSlash(rel))), "\n") {
			line = strings.TrimSpace(line)
			if !strings.HasPrefix(line, `#include "`) {
				continue // <...>-Includes sind Standardbibliothek
			}
			target := strings.Trim(strings.TrimPrefix(line, "#include"), ` "`)
			if !strings.HasPrefix(target, "src/") {
				t.Errorf("%s: %q ist nicht modul-root-relativ — a-check sieht diesen Import nicht", rel, target)
			}
		}
	}
}

// TestArchGateConfig_CppMatchesSkeleton (slice-053, ADR-0009 Fitness-Function): die
// cpp-.a-check.yml deklariert GENAU die Schichten, die das generierte Skelett traegt —
// jede Produktionsdatei ausserhalb des Composition Root faellt unter den erwarteten
// Schicht-Glob. Die Erwartung steht ausgeschrieben, nicht aus der Config abgeleitet
// (sonst pruefte der Test die Config gegen sich selbst).
func TestArchGateConfig_CppMatchesSkeleton(t *testing.T) {
	cfg, ok := gen.ArchGateConfig("cpp", "hexslice")
	if !ok {
		t.Fatal("cpp+hexslice traegt keine Arch-Gate-Config")
	}
	globs := archGlobs(t, cfg)
	want := map[string]string{
		"src/hexagon/domain/example/greeting.hpp":                       "domain",
		"src/hexagon/application/example/ports/greeting_repository.hpp": "ports",
		"src/hexagon/application/example/greet/ports/notifier.hpp":      "ports",
		"src/hexagon/application/example/greet/command.hpp":             "app",
		"src/hexagon/application/example/greet/handler.hpp":             "app",
		"src/adapters/inbound/cli/example/cli.hpp":                      "adapters",
		"src/adapters/outbound/memory/example/repository.hpp":           "adapters",
		"src/adapters/outbound/notify/stdout.hpp":                       "adapters",
	}
	seen := map[string]bool{}
	for _, rel := range walkRel(t, genCppArch(t, "hexslice")) {
		if !strings.HasSuffix(rel, ".hpp") || strings.HasPrefix(rel, "tests/") {
			continue // main.cpp ist composition_root, tests/ ist exclude
		}
		seen[rel] = true
		layer, _ := mostSpecific(globs, rel)
		if layer == "" {
			t.Errorf("%s faellt unter KEINE Schicht (Loch im Pruefbereich)", rel)
			continue
		}
		if want[rel] == "" {
			t.Errorf("%s ist neu im Skelett, aber in der Erwartung nicht gefuehrt (Config/Skelett-Drift?)", rel)
		} else if layer != want[rel] {
			t.Errorf("%s faellt unter Schicht %q, want %q", rel, layer, want[rel])
		}
	}
	for rel := range want {
		if !seen[rel] {
			t.Errorf("erwartete Skelett-Datei %s fehlt (Rollen-Pfad gewandert?)", rel)
		}
	}
}

// TestArchGateConfig_CppAllowsAdapterToPorts (slice-053): die cpp-Config MUSS die
// adapters->ports-Kante tragen — in C++ erfuellt ein Outbound-Adapter seinen Port durch
// VERERBUNG und includiert ihn deshalb. Die Go-Fassung hat die Kante bewusst nicht
// (strukturelle Interface-Erfuellung). Wer sie fuer ein Copy-Paste-Versehen haelt und
// streicht, faerbt das Arch-Gate des generierten Skeletts rot.
func TestArchGateConfig_CppAllowsAdapterToPorts(t *testing.T) {
	cfg, _ := gen.ArchGateConfig("cpp", "hexslice")
	if !strings.Contains(cfg, "{from: adapters, to: ports}") {
		t.Error("cpp-Config ohne adapters->ports-Kante: der erbende Outbound-Adapter faerbt a-check rot")
	}
	goCfg, _ := gen.ArchGateConfig("go", "hexslice")
	if strings.Contains(goCfg, "{from: adapters, to: ports}") {
		t.Error("go-Config traegt adapters->ports — die strukturelle Erfuellung braucht sie nicht")
	}
}
