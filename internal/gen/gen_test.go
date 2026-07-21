package gen_test

import (
	"errors"
	"os"
	"path/filepath"
	"regexp"
	"sort"
	"strings"
	"testing"

	"github.com/pt9912/ai-harness-init/internal/gen"
)

// genGo generiert das go-Skelett (Default-Version) in ein frisches Temp-Verzeichnis.
func genGo(t *testing.T) string { return genGoWith(t, gen.DefaultGoVersion) }

// genGoWith generiert das go-Skelett mit einer expliziten Go-Version.
func genGoWith(t *testing.T, goVersion string) string {
	t.Helper()
	dir := t.TempDir()
	if err := gen.Generate(dir, "go", goVersion); err != nil {
		t.Fatalf("Generate(go, %q): %v", goVersion, err)
	}
	return dir
}

// TestGenerate_GoProfile: --lang go erzeugt GENAU die erwarteten Skelett-Dateien
// (LH-FA-04 Generator-Teil), nicht mehr und nicht weniger.
func TestGenerate_GoProfile(t *testing.T) {
	dir := genGo(t)
	got := walkRel(t, dir)
	want := []string{".golangci.yml", "Dockerfile", "Makefile", "cmd/app/main.go", "go.mod"}
	if strings.Join(got, ",") != strings.Join(want, ",") {
		t.Errorf("erzeugter Datei-Satz = %v\nwant %v", got, want)
	}
	assertFileContains(t, filepath.Join(dir, "go.mod"), "module app")
	assertFileContains(t, filepath.Join(dir, "cmd", "app", "main.go"), "package main")
}

// TestGenerate_Deterministic haelt LH-QA-02: zwei Laeufe mit gleicher Sprache
// liefern byte-identische Dateien (kein Zeitstempel, keine Map-Iteration im
// INHALT). Verglichen wird der VOLLE Datei-Satz, nicht nur "existiert".
func TestGenerate_Deterministic(t *testing.T) {
	d1, d2 := genGo(t), genGo(t)
	rels := walkRel(t, d1)
	if strings.Join(rels, ",") != strings.Join(walkRel(t, d2), ",") {
		t.Fatal("zwei Laeufe erzeugten verschiedene Datei-Saetze")
	}
	for _, rel := range rels {
		a := mustRead(t, filepath.Join(d1, filepath.FromSlash(rel)))
		b := mustRead(t, filepath.Join(d2, filepath.FromSlash(rel)))
		if a != b {
			t.Errorf("%s unterscheidet sich zwischen zwei Laeufen", rel)
		}
	}
}

// TestGenerate_MakefileTargetsMatchStages ist der LH-QA-01-Anker: jedes
// Makefile-Target, das `docker build --target <X>` ruft, muss eine gleichnamige
// Dockerfile-Stage `AS <X>` haben — sonst ist es ein halluziniertes Gate. Ohne
// den vollen Zielrepo-Lauf (slice-024) ist das der staerkste statische Beleg.
func TestGenerate_MakefileTargetsMatchStages(t *testing.T) {
	dir := genGo(t)
	mk := mustRead(t, filepath.Join(dir, "Makefile"))
	df := mustRead(t, filepath.Join(dir, "Dockerfile"))

	stages := map[string]bool{}
	for _, m := range regexp.MustCompile(`\bAS (\w+)`).FindAllStringSubmatch(df, -1) {
		stages[m[1]] = true
	}
	targets := regexp.MustCompile(`--target (\w+)`).FindAllStringSubmatch(mk, -1)
	if len(targets) == 0 {
		t.Fatal("kein `--target` im generierten Makefile gefunden — der Test waere zahnlos")
	}
	for _, m := range targets {
		if !stages[m[1]] {
			t.Errorf("Makefile ruft `--target %s`, aber Dockerfile hat keine Stage `AS %s` (halluziniertes Gate)", m[1], m[1])
		}
	}
}

// TestGenerate_UnknownLang: eine Sprache ohne Profil -> *UnknownLangError mit der
// sortierten Liste der unterstuetzten Profile — die --lang-Validierung, die mit
// slice-023 vom Skelett-Fetch zum Generator wanderte.
func TestGenerate_UnknownLang(t *testing.T) {
	err := gen.Generate(t.TempDir(), "rust", gen.DefaultGoVersion)
	var ule *gen.UnknownLangError
	if !errors.As(err, &ule) {
		t.Fatalf("erwartete *UnknownLangError, got %v", err)
	}
	if ule.Lang != "rust" {
		t.Errorf("Lang = %q, want rust", ule.Lang)
	}
	if strings.Join(ule.Available, ",") != "go" {
		t.Errorf("Available = %v, want [go] (sortiert)", ule.Available)
	}
}

// TestSupportedLangs: sortiert und enthaelt das go-Profil.
func TestSupportedLangs(t *testing.T) {
	langs := gen.SupportedLangs()
	if !sort.StringsAreSorted(langs) {
		t.Errorf("SupportedLangs nicht sortiert: %v", langs)
	}
	found := false
	for _, l := range langs {
		if l == "go" {
			found = true
		}
	}
	if !found {
		t.Errorf("SupportedLangs = %v, soll go enthalten", langs)
	}
}

// TestGoProfile_PinsMatchRepo koppelt die Skelett-Default-Pins an die kanonischen
// Repo-Pins (Dockerfile/go.mod) — sonst bumpt ein Repo-Update die eine Haelfte und
// vergisst den Generator (slice-004a-Lehre, LH-QA-02, Wartungslast slice-023 §6).
func TestGoProfile_PinsMatchRepo(t *testing.T) {
	dir := genGo(t) // Default-Version
	genDf := mustRead(t, filepath.Join(dir, "Dockerfile"))
	repoDf := mustRead(t, filepath.Join("..", "..", "Dockerfile"))
	for _, key := range []string{"ARG GO_VERSION", "ARG GOLANGCI_LINT_VERSION"} {
		re := regexp.MustCompile(regexp.QuoteMeta(key) + `=(\S+)`)
		if g, r := firstSub(t, re, genDf), firstSub(t, re, repoDf); g != r {
			t.Errorf("%s: generiert %q != Repo-Dockerfile %q (Drift, LH-QA-02)", key, g, r)
		}
	}
	reGo := regexp.MustCompile(`go (\d+\.\d+)`)
	g := firstSub(t, reGo, mustRead(t, filepath.Join(dir, "go.mod")))
	r := firstSub(t, reGo, mustRead(t, filepath.Join("..", "..", "go.mod")))
	if g != r {
		t.Errorf("go.mod-Sprachversion: generiert %q != Repo %q (Drift)", g, r)
	}
}

// TestGenerate_GoVersionThreaded belegt, dass die uebergebene Go-Version wirklich
// ins Skelett faedelt: das Dockerfile-ARG traegt sie exakt, go.mod die major.minor-
// Ableitung. Damit ist der SKEL_GO_VERSION-Knopf (cmd) am Generator verankert.
func TestGenerate_GoVersionThreaded(t *testing.T) {
	dir := genGoWith(t, "1.27.3")
	df := mustRead(t, filepath.Join(dir, "Dockerfile"))
	if got := firstSub(t, regexp.MustCompile(`ARG GO_VERSION=(\S+)`), df); got != "1.27.3" {
		t.Errorf("Dockerfile ARG GO_VERSION = %q, want 1.27.3", got)
	}
	gomod := mustRead(t, filepath.Join(dir, "go.mod"))
	if got := firstSub(t, regexp.MustCompile(`go (\d+\.\d+)`), gomod); got != "1.27" {
		t.Errorf("go.mod-Version = %q, want 1.27 (major.minor aus 1.27.3)", got)
	}
}

func firstSub(t *testing.T, re *regexp.Regexp, s string) string {
	t.Helper()
	m := re.FindStringSubmatch(s)
	if m == nil {
		t.Fatalf("Muster %s nicht gefunden", re)
	}
	return m[1]
}

func walkRel(t *testing.T, dir string) []string {
	t.Helper()
	var rels []string
	err := filepath.WalkDir(dir, func(p string, d os.DirEntry, walkErr error) error {
		if walkErr != nil {
			return walkErr
		}
		if !d.IsDir() {
			rel, relErr := filepath.Rel(dir, p)
			if relErr != nil {
				return relErr
			}
			rels = append(rels, filepath.ToSlash(rel))
		}
		return nil
	})
	if err != nil {
		t.Fatalf("walk %s: %v", dir, err)
	}
	sort.Strings(rels)
	return rels
}

func mustRead(t *testing.T, path string) string {
	t.Helper()
	data, err := os.ReadFile(path)
	if err != nil {
		t.Fatalf("lesen %s: %v", path, err)
	}
	return string(data)
}

func assertFileContains(t *testing.T, path, want string) {
	t.Helper()
	if !strings.Contains(mustRead(t, path), want) {
		t.Errorf("%s enthaelt %q nicht", path, want)
	}
}
