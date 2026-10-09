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

// TestGenerateArch_KotlinTraegtNurFlat: hexslice und hexagonal rendert der Kotlin-Renderer
// nicht — Exit-2-Klasse mit der Liste der Sprache, ohne Artefakte (ADR-0088 Festlegung 4).
func TestGenerateArch_KotlinTraegtNurFlat(t *testing.T) {
	for _, arch := range []string{"hexslice", "hexagonal"} {
		dir := t.TempDir()
		err := gen.GenerateArch(dir, "kotlin", gen.DefaultKotlinVersion, arch)
		var uae *gen.UnknownArchError
		if !errors.As(err, &uae) {
			t.Fatalf("erwartete *UnknownArchError fuer kotlin+%s, got %v", arch, err)
		}
		if strings.Join(uae.Available, ",") != "flat" {
			t.Errorf("Available = %v, want [flat]", uae.Available)
		}
		if rels := walkRel(t, dir); len(rels) != 0 {
			t.Errorf("abgelehnte Kombination kotlin+%s hat Artefakte geschrieben: %v", arch, rels)
		}
	}
}
