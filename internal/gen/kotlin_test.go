package gen_test

import (
	"errors"
	"path/filepath"
	"regexp"
	"strings"
	"testing"

	"github.com/pt9912/ai-harness-init/internal/gen"
)

// genKotlinWith generiert das Kotlin-Skelett mit einem expliziten gradle-Tag.
func genKotlinWith(t *testing.T, version string) string {
	t.Helper()
	dir := t.TempDir()
	if err := gen.Generate(dir, "kotlin", version); err != nil {
		t.Fatalf("Generate(kotlin, %q): %v", version, err)
	}
	return dir
}

// TestGenerate_KotlinProfile: --lang kotlin erzeugt GENAU den erwarteten Skelett-Satz
// (LH-FA-04, ADR-0088 Festlegung 1–3) — Einzelmodul ohne Wrapper, detekt-Config,
// Dockerfile, Main und Test, Paket == Verzeichnis. Nicht mehr, nicht weniger.
func TestGenerate_KotlinProfile(t *testing.T) {
	dir := genKotlinWith(t, gen.DefaultKotlinVersion)
	got := walkRel(t, dir)
	want := []string{
		"Dockerfile", "build.gradle.kts", "detekt.yml", "settings.gradle.kts",
		"src/main/kotlin/app/Main.kt", "src/test/kotlin/app/MainTest.kt",
	}
	if strings.Join(got, ",") != strings.Join(want, ",") {
		t.Errorf("erzeugter Datei-Satz = %v\nwant %v", got, want)
	}
	if s := mustRead(t, filepath.Join(dir, "settings.gradle.kts")); strings.Contains(s, "include") {
		t.Errorf("settings.gradle.kts traegt ein include — ADR-0088 Festlegung 1 verlangt ein Modul:\n%s", s)
	}
	bg := mustRead(t, filepath.Join(dir, "build.gradle.kts"))
	for _, want := range []string{`kotlin("jvm") version "`, `id("io.gitlab.arturbosch.detekt") version "`, `testImplementation(kotlin("test"))`} {
		if !strings.Contains(bg, want) {
			t.Errorf("build.gradle.kts enthaelt %q nicht:\n%s", want, bg)
		}
	}
	assertFileContains(t, filepath.Join(dir, "src", "main", "kotlin", "app", "Main.kt"), "package app\n")
	assertFileContains(t, filepath.Join(dir, "src", "test", "kotlin", "app", "MainTest.kt"), "package app\n")
	assertFileContains(t, filepath.Join(dir, "Dockerfile"), "FROM gradle:${GRADLE_TAG} AS toolchain")
}

// TestGenerate_KotlinDeterministic haelt LH-QA-02 fuer kotlin: zwei Laeufe mit gleichem Tag
// liefern byte-identische Dateien.
func TestGenerate_KotlinDeterministic(t *testing.T) {
	d1, d2 := genKotlinWith(t, gen.DefaultKotlinVersion), genKotlinWith(t, gen.DefaultKotlinVersion)
	rels := walkRel(t, d1)
	if strings.Join(rels, ",") != strings.Join(walkRel(t, d2), ",") {
		t.Fatal("zwei kotlin-Laeufe erzeugten verschiedene Datei-Saetze")
	}
	for _, rel := range rels {
		if mustRead(t, filepath.Join(d1, filepath.FromSlash(rel))) != mustRead(t, filepath.Join(d2, filepath.FromSlash(rel))) {
			t.Errorf("%s unterscheidet sich zwischen zwei kotlin-Laeufen", rel)
		}
	}
}

// TestKotlinCodeGateFragment_TargetsMatchStages ist der LH-QA-01-Anker fuer kotlin
// (ADR-0088 §Fitness Function): jedes `docker build --target <X>` im Fragment hat eine
// gleichnamige Dockerfile-Stage `AS <X>` — in allen drei Fassungen (Root, Subdir,
// gemischter Root) —, und die drei Gate-Ziele test/lint/build sind jeweils gerufen.
func TestKotlinCodeGateFragment_TargetsMatchStages(t *testing.T) {
	df := mustRead(t, filepath.Join(genKotlinWith(t, gen.DefaultKotlinVersion), "Dockerfile"))
	stages := map[string]bool{}
	for _, m := range regexp.MustCompile(`\bAS (\w+)`).FindAllStringSubmatch(df, -1) {
		stages[m[1]] = true
	}
	fassungen := map[string]func() (string, error){
		"root":     func() (string, error) { return gen.CodeGateFragment("kotlin", ".", gen.DefaultKotlinVersion) },
		"subdir":   func() (string, error) { return gen.CodeGateFragment("kotlin", "apps/kt", gen.DefaultKotlinVersion) },
		"gemischt": func() (string, error) { return gen.CodeGateFragmentMixed("kotlin", ".", gen.DefaultKotlinVersion) },
	}
	for name, build := range fassungen {
		mk, err := build()
		if err != nil {
			t.Fatalf("Fragment (%s): %v", name, err)
		}
		gerufen := map[string]bool{}
		for _, m := range regexp.MustCompile(`--target (\w+)`).FindAllStringSubmatch(mk, -1) {
			gerufen[m[1]] = true
			if !stages[m[1]] {
				t.Errorf("kotlin-Fragment (%s) ruft `--target %s`, aber Dockerfile hat keine Stage `AS %s`", name, m[1], m[1])
			}
		}
		for _, ziel := range []string{"test", "lint", "build"} {
			if !gerufen[ziel] {
				t.Errorf("kotlin-Fragment (%s) ruft `--target %s` nicht — das Gate fehlt", name, ziel)
			}
		}
	}
}

// TestKotlinCodeGateFragment_RootUndSubdir: die Root-Fassung haengt lint/build/test an
// GATE_CHECKS und baut im Root-Kontext; die Subdir-Fassung traegt modul-scoped Targets und
// keine unscoped.
func TestKotlinCodeGateFragment_RootUndSubdir(t *testing.T) {
	root, err := gen.CodeGateFragment("kotlin", ".", gen.DefaultKotlinVersion)
	if err != nil {
		t.Fatalf("CodeGateFragment(kotlin, .): %v", err)
	}
	for _, want := range []string{"GATE_CHECKS += lint build test", "--target test -t $(IMAGE):test ."} {
		if !strings.Contains(root, want) {
			t.Errorf("kotlin-Root-Fragment enthaelt %q nicht:\n%s", want, root)
		}
	}
	sub, err := gen.CodeGateFragment("kotlin", "apps/kt", gen.DefaultKotlinVersion)
	if err != nil {
		t.Fatalf("CodeGateFragment(kotlin, apps/kt): %v", err)
	}
	for _, want := range []string{"GATE_CHECKS += lint-apps-kt build-apps-kt test-apps-kt", "--target test -t apps-kt:test apps/kt"} {
		if !strings.Contains(sub, want) {
			t.Errorf("modul-scoped kotlin-Fragment enthaelt %q nicht:\n%s", want, sub)
		}
	}
	for _, forbidden := range []string{"\ntest:", "\nlint:", "\nbuild:"} {
		if strings.Contains(sub, forbidden) {
			t.Errorf("modul-scoped kotlin-Fragment traegt unscoped Target %q:\n%s", forbidden, sub)
		}
	}
	mixed, err := gen.CodeGateFragmentMixed("kotlin", ".", gen.DefaultKotlinVersion)
	if err != nil {
		t.Fatalf("CodeGateFragmentMixed(kotlin, .): %v", err)
	}
	mixedFragmentFest(t, mixed, "kotlin", []string{"--target test -t kotlin:test ."})
}

// TestGenerate_KotlinVersionThreaded: der uebergebene gradle-Tag faedelt ins Dockerfile-ARG
// und in den GRADLE_TAG-Default des Fragments — der Knopf SKEL_KOTLIN_VERSION ist am
// Generator verankert (ADR-0088 Festlegung 2).
func TestGenerate_KotlinVersionThreaded(t *testing.T) {
	df := mustRead(t, filepath.Join(genKotlinWith(t, "8.14.3-jdk21"), "Dockerfile"))
	if got := firstSub(t, regexp.MustCompile(`ARG GRADLE_TAG=(\S+)`), df); got != "8.14.3-jdk21" {
		t.Errorf("Dockerfile ARG GRADLE_TAG = %q, want 8.14.3-jdk21", got)
	}
	mk, err := gen.CodeGateFragment("kotlin", ".", "8.14.3-jdk21")
	if err != nil {
		t.Fatalf("CodeGateFragment(kotlin, ., 8.14.3-jdk21): %v", err)
	}
	if got := firstSub(t, regexp.MustCompile(`GRADLE_TAG \?= (\S+)`), mk); got != "8.14.3-jdk21" {
		t.Errorf("Fragment GRADLE_TAG-Default = %q, want 8.14.3-jdk21", got)
	}
	if !regexp.MustCompile(`^\d+\.\d+(\.\d+)?-jdk\d+$`).MatchString(gen.DefaultKotlinVersion) {
		t.Errorf("DefaultKotlinVersion = %q ist kein gradle-Tag der Form <ver>-jdk<NN> (ADR-0088 Festlegung 2)", gen.DefaultKotlinVersion)
	}
}

// TestGenerateArch_KotlinOhneHexagonal: hexagonal rendert der Kotlin-Renderer nicht —
// Exit-2-Klasse mit der Liste der Sprache (flat, hexslice), ohne Artefakte (ADR-0088
// Festlegung 4 legt das Layout nicht fest).
func TestGenerateArch_KotlinOhneHexagonal(t *testing.T) {
	for _, arch := range []string{"hexagonal"} {
		dir := t.TempDir()
		err := gen.GenerateArch(dir, "kotlin", gen.DefaultKotlinVersion, arch)
		var uae *gen.UnknownArchError
		if !errors.As(err, &uae) {
			t.Fatalf("erwartete *UnknownArchError fuer kotlin+%s, got %v", arch, err)
		}
		if strings.Join(uae.Available, ",") != "flat,hexslice" {
			t.Errorf("Available = %v, want [flat hexslice]", uae.Available)
		}
		if rels := walkRel(t, dir); len(rels) != 0 {
			t.Errorf("abgelehnte Kombination kotlin+%s hat Artefakte geschrieben: %v", arch, rels)
		}
	}
}

// genKotlinHexslice generiert das hexSlice-Kotlin-Skelett in ein frisches Temp-Verzeichnis.
func genKotlinHexslice(t *testing.T) string {
	t.Helper()
	dir := t.TempDir()
	if err := gen.GenerateArch(dir, "kotlin", gen.DefaultKotlinVersion, "hexslice"); err != nil {
		t.Fatalf("GenerateArch(kotlin, hexslice): %v", err)
	}
	return dir
}

// TestGenerate_KotlinHexsliceProfile_FileSet (LH-FA-04, ADR-0088 Festlegung 4): --arch
// hexslice erzeugt GENAU die Rollen-Dateien unter src/main/kotlin/app/{hexagon,adapters}
// plus Composition Root, Test und die arch-invariante Geruestung — nicht mehr, nicht weniger.
func TestGenerate_KotlinHexsliceProfile_FileSet(t *testing.T) {
	got := walkRel(t, genKotlinHexslice(t))
	want := []string{
		"Dockerfile", "build.gradle.kts", "detekt.yml", "settings.gradle.kts",
		"src/main/kotlin/app/Main.kt",
		"src/main/kotlin/app/adapters/driven/memory/example/InMemoryRepository.kt",
		"src/main/kotlin/app/adapters/driven/notify/StdoutNotifier.kt",
		"src/main/kotlin/app/adapters/driving/cli/example/Cli.kt",
		"src/main/kotlin/app/hexagon/application/example/greet/Handler.kt",
		"src/main/kotlin/app/hexagon/application/example/greet/ports/inbound/Greet.kt",
		"src/main/kotlin/app/hexagon/application/example/greet/ports/outbound/Notifier.kt",
		"src/main/kotlin/app/hexagon/application/example/ports/outbound/GreetingRepository.kt",
		"src/main/kotlin/app/hexagon/domain/example/Greeting.kt",
		"src/test/kotlin/app/GreetTest.kt",
	}
	if strings.Join(got, ",") != strings.Join(want, ",") {
		t.Errorf("kotlin-hexSlice-Datei-Satz = %v\nwant %v", got, want)
	}
}

// TestKotlinHexslice_PaketGleichVerzeichnis (ADR-0088 Festlegung 4): jede .kt-Datei des
// hexSlice-Skeletts deklariert genau das Paket ihres Verzeichnisses unter src/<set>/kotlin.
// a-check loest Importe ueber den Pfad auf; ein Paket ausserhalb seines Verzeichnisses
// entginge dem Arch-Gate. Rot-Gegenbeispiel: test/mutations/623 verschiebt das Paket der
// Domain-Datei.
func TestKotlinHexslice_PaketGleichVerzeichnis(t *testing.T) {
	dir := genKotlinHexslice(t)
	pkgRe := regexp.MustCompile(`(?m)^package ([a-z.]+)$`)
	n := 0
	for _, rel := range walkRel(t, dir) {
		if !strings.HasSuffix(rel, ".kt") {
			continue
		}
		n++
		parts := strings.SplitN(rel, "/", 4) // src/<set>/kotlin/<paket-pfad>/<Datei>.kt
		if len(parts) != 4 || parts[0] != "src" || parts[2] != "kotlin" {
			t.Errorf("%s liegt nicht unter src/<set>/kotlin/", rel)
			continue
		}
		want := strings.ReplaceAll(filepath.ToSlash(filepath.Dir(parts[3])), "/", ".")
		m := pkgRe.FindStringSubmatch(mustRead(t, filepath.Join(dir, filepath.FromSlash(rel))))
		if m == nil {
			t.Errorf("%s traegt keine package-Zeile", rel)
		} else if m[1] != want {
			t.Errorf("%s deklariert package %s, das Verzeichnis verlangt %s", rel, m[1], want)
		}
	}
	if n == 0 {
		t.Fatal("keine .kt-Datei im hexSlice-Skelett")
	}
}

// kotlinResolution zieht roots und package_base aus dem resolution-Block der Config.
func kotlinResolution(t *testing.T, cfg string) (root, base string) {
	t.Helper()
	block := cfg[strings.Index(cfg, "\nresolution:\n")+1:]
	rm := regexp.MustCompile(`(?m)^    roots: \["([^"]+)"\]$`).FindStringSubmatch(block)
	bm := regexp.MustCompile(`(?m)^    package_base: "([^"]+)"$`).FindStringSubmatch(block)
	if !strings.Contains(cfg, "\nresolution:\n  kotlin:\n    mode: fixed-root\n") || rm == nil || bm == nil {
		t.Fatalf("kein resolution-Block kotlin/fixed-root mit genau einem Root und package_base:\n%s", block)
	}
	return rm[1], bm[1]
}

// TestArchGateConfig_KotlinMatchesSkeleton (ADR-0088 Festlegung 4, LH-FA-07): jede
// Produktionsdatei ausserhalb des Composition Root faellt unter den erwarteten Schicht-Glob,
// und jeder Glob ist fuer mindestens eine Datei der spezifischste. Die Erwartung steht
// ausgeschrieben, nicht aus der Config abgeleitet.
func TestArchGateConfig_KotlinMatchesSkeleton(t *testing.T) {
	cfg, ok := gen.ArchGateConfig("kotlin", "hexslice")
	if !ok {
		t.Fatal("kotlin+hexslice traegt keine Arch-Gate-Config")
	}
	globs := archGlobs(t, cfg)
	const hex, ad = "src/main/kotlin/app/hexagon/", "src/main/kotlin/app/adapters/"
	want := map[string]string{
		hex + "domain/example/Greeting.kt":                                 "domain",
		hex + "application/example/greet/ports/inbound/Greet.kt":          "ports_inbound",
		hex + "application/example/greet/ports/outbound/Notifier.kt":      "ports_outbound",
		hex + "application/example/ports/outbound/GreetingRepository.kt": "ports_outbound",
		hex + "application/example/greet/Handler.kt":                      "app",
		ad + "driving/cli/example/Cli.kt":                                 "driving_adapters",
		ad + "driven/memory/example/InMemoryRepository.kt":               "driven_adapters",
		ad + "driven/notify/StdoutNotifier.kt":                           "driven_adapters",
	}
	hits := map[string]int{}
	seen := map[string]bool{}
	for _, rel := range walkRel(t, genKotlinHexslice(t)) {
		if !strings.HasSuffix(rel, ".kt") || strings.HasPrefix(rel, "src/test/") || rel == "src/main/kotlin/app/Main.kt" {
			continue // exclude bzw. composition_root
		}
		seen[rel] = true
		layer, glob := mostSpecific(globs, rel)
		hits[glob]++
		switch {
		case layer == "":
			t.Errorf("%s faellt unter KEINE Schicht (Loch im Pruefbereich)", rel)
		case want[rel] == "":
			t.Errorf("%s ist neu im Skelett, aber in der Erwartung nicht gefuehrt", rel)
		case layer != want[rel]:
			t.Errorf("%s faellt unter Schicht %q, want %q", rel, layer, want[rel])
		}
	}
	for rel := range want {
		if !seen[rel] {
			t.Errorf("erwartete Skelett-Datei %s fehlt (Rollen-Pfad gewandert?)", rel)
		}
	}
	for layer, gs := range globs {
		for _, g := range gs {
			if hits[g] == 0 {
				t.Errorf("Schicht %s: Glob %q ist fuer keine Datei der spezifischste (LH-QA-01)", layer, g)
			}
		}
	}
}

// TestArchGateConfig_KotlinEdgesMatchSkeleton (ADR-0088 Festlegung 4, LH-FA-07): jeder
// `import app.…` einer Produktionsdatei wird so aufgeloest, wie a-check es mit dem
// resolution-Block der Config tut (package_base abstreifen, Punkte zu "/", Root voran). Dann
// gilt in beide Richtungen: jeder Import loest auf eine Schicht auf und hat seine Kante, und
// jede deklarierte Kante wird von einem Import gebraucht. Ein Root, der nicht im
// package_base-Verzeichnis endet, loest keinen Import auf und faerbt den Test rot —
// test/mutations/624 setzt genau diesen Root.
func TestArchGateConfig_KotlinEdgesMatchSkeleton(t *testing.T) {
	cfg, _ := gen.ArchGateConfig("kotlin", "hexslice")
	globs := archGlobs(t, cfg)
	declared := archEdges(t, cfg)
	root, base := kotlinResolution(t, cfg)
	dir := genKotlinHexslice(t)
	importRe := regexp.MustCompile(`(?m)^import (` + regexp.QuoteMeta(base) + `\.[A-Za-z.]+)$`)
	used := map[string]bool{}
	for _, rel := range walkRel(t, dir) {
		if !strings.HasPrefix(rel, "src/main/") || rel == "src/main/kotlin/app/Main.kt" {
			continue
		}
		from, _ := mostSpecific(globs, rel)
		for _, m := range importRe.FindAllStringSubmatch(mustRead(t, filepath.Join(dir, filepath.FromSlash(rel))), -1) {
			cand := root + "/" + strings.ReplaceAll(strings.TrimPrefix(m[1], base+"."), ".", "/")
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
	for edge := range declared {
		if !used[edge] {
			t.Errorf("Kante %s ist deklariert, wird aber von keinem aufgeloesten Import gebraucht", edge)
		}
	}
}
