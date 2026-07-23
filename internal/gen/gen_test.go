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
	// Seit slice-037 traegt das Skelett KEIN Code-Gate-Fragment mehr (harness/mk/go.mk) —
	// das ist <pfad>-aware und kommt aus gen.CodeGateFragment, nicht aus dem Skelett.
	want := []string{".golangci.yml", "Dockerfile", "cmd/app/main.go", "go.mod"}
	if strings.Join(got, ",") != strings.Join(want, ",") {
		t.Errorf("erzeugter Datei-Satz = %v\nwant %v", got, want)
	}
	assertFileContains(t, filepath.Join(dir, "go.mod"), "module app")
	assertFileContains(t, filepath.Join(dir, "cmd", "app", "main.go"), "package main")
	// Das Fragment ist NICHT im Skelett (Split slice-037).
	if _, err := os.Stat(filepath.Join(dir, "harness", "mk", "go.mk")); err == nil {
		t.Error("Skelett traegt harness/mk/go.mk — das Fragment gehoert seit slice-037 nach gen.CodeGateFragment")
	}
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

// TestCodeGateFragment_TargetsMatchStages ist der LH-QA-01-Anker: jedes Target im
// Code-Gate-Fragment, das `docker build --target <X>` ruft, muss eine gleichnamige
// Dockerfile-Stage `AS <X>` haben — sonst ist es ein halluziniertes Gate. Geprueft
// fuer BEIDE Fassungen (Root unscoped + Subdir modul-scoped): der --target-Wert (die
// Dockerfile-Stage) ist in beiden test/lint/build, nur die make-Target-Namen scopen.
func TestCodeGateFragment_TargetsMatchStages(t *testing.T) {
	dir := genGo(t)
	df := mustRead(t, filepath.Join(dir, "Dockerfile"))
	stages := map[string]bool{}
	for _, m := range regexp.MustCompile(`\bAS (\w+)`).FindAllStringSubmatch(df, -1) {
		stages[m[1]] = true
	}
	for _, path := range []string{".", "apps/api"} {
		mk, err := gen.CodeGateFragment("go", path, gen.DefaultGoVersion)
		if err != nil {
			t.Fatalf("CodeGateFragment(go, %q): %v", path, err)
		}
		targets := regexp.MustCompile(`--target (\w+)`).FindAllStringSubmatch(mk, -1)
		if len(targets) == 0 {
			t.Fatalf("kein `--target` im Fragment (%q) — der Test waere zahnlos", path)
		}
		for _, m := range targets {
			if !stages[m[1]] {
				t.Errorf("Fragment (%q) ruft `--target %s`, aber Dockerfile hat keine Stage `AS %s` (halluziniertes Gate)", path, m[1], m[1])
			}
		}
	}
}

// TestCodeGateFragment_Root (slice-034/035/037): die Root-Fassung (<pfad>=".") haengt
// lint/build/test via `GATE_CHECKS +=` an — NICHT via eigenem gates:-Target (das umginge
// die Ordnungskante des Aggregators) — und baut im Root-Kontext (`docker build .`),
// rueckwaertskompatibel mit dem --lang-One-Shot.
func TestCodeGateFragment_Root(t *testing.T) {
	gomk, err := gen.CodeGateFragment("go", ".", gen.DefaultGoVersion)
	if err != nil {
		t.Fatalf("CodeGateFragment(go, .): %v", err)
	}
	if !strings.Contains(gomk, "GATE_CHECKS += lint build test") {
		t.Errorf("Root-Fragment haengt lint/build/test nicht an GATE_CHECKS:\n%s", gomk)
	}
	if strings.Contains(gomk, "\ngates:") {
		t.Errorf("Fragment definiert ein eigenes gates:-Target (umgeht die Ordnungskante):\n%s", gomk)
	}
	if !strings.Contains(gomk, "--target test -t $(IMAGE):test .") {
		t.Errorf("Root-Fragment baut nicht im Root-Kontext (`docker build .`):\n%s", gomk)
	}
}

// TestCodeGateFragment_ScopedSubdir (slice-037, Mono-Repo-Kern): eine Subdir-Fassung
// traegt MODUL-SCOPED Targets (test-<modul> …, kollisionsfrei) und baut im <pfad>-Kontext
// (`docker build <pfad>`), NICHT im Root. GATE_CHECKS scopt ebenfalls je Modul.
func TestCodeGateFragment_ScopedSubdir(t *testing.T) {
	mk, err := gen.CodeGateFragment("go", "apps/api", gen.DefaultGoVersion)
	if err != nil {
		t.Fatalf("CodeGateFragment(go, apps/api): %v", err)
	}
	for _, want := range []string{
		"test-apps-api:", "lint-apps-api:", "build-apps-api:",
		"GATE_CHECKS += lint-apps-api build-apps-api test-apps-api",
		"--target test -t apps-api:test apps/api",
	} {
		if !strings.Contains(mk, want) {
			t.Errorf("modul-scoped Fragment enthaelt %q nicht:\n%s", want, mk)
		}
	}
	// Kollisionsfreiheit: die UNSCOPED Root-Targets duerfen NICHT auftauchen (sonst
	// definierten zwei Module dasselbe `test`).
	for _, forbidden := range []string{"\ntest:", "\nlint:", "\nbuild:", "GATE_CHECKS += lint build test"} {
		if strings.Contains(mk, forbidden) {
			t.Errorf("modul-scoped Fragment traegt unscoped Target %q (Mono-Repo-Kollisionsrisiko):\n%s", forbidden, mk)
		}
	}
}

// TestModuleName koppelt die Modul-Namens-Ableitung fest (slice-037): Root -> Sprache,
// Subdir -> Slashes zu Bindestrichen, leer/bereinigt -> Root.
func TestModuleName(t *testing.T) {
	cases := map[string]string{".": "go", "": "go", "apps/api": "apps-api", "services/web": "services-web", "./apps/api": "apps-api"}
	for path, want := range cases {
		if got := gen.ModuleName(path, "go"); got != want {
			t.Errorf("ModuleName(%q, go) = %q, want %q", path, got, want)
		}
	}
}

// TestCodeGateFragment_UnknownLang: eine Sprache ohne Fragment-Builder -> *UnknownLangError
// (dieselbe Diagnose wie Generate, damit `add-lang <sprache>` fail-fast ist).
func TestCodeGateFragment_UnknownLang(t *testing.T) {
	_, err := gen.CodeGateFragment("rust", ".", gen.DefaultGoVersion)
	var ule *gen.UnknownLangError
	if !errors.As(err, &ule) {
		t.Fatalf("erwartete *UnknownLangError, got %v", err)
	}
}

// TestGenerate_NoRootMakefile: gen emittiert seit slice-035 KEINE Root-Makefile (der
// Aggregator kommt aus emit.Makefile).
func TestGenerate_NoRootMakefile(t *testing.T) {
	if _, err := os.Stat(filepath.Join(genGo(t), "Makefile")); err == nil {
		t.Error("gen emittiert eine Root-Makefile — die gehoert seit slice-035 in emit.Makefile")
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
	if strings.Join(ule.Available, ",") != "cpp,go" {
		t.Errorf("Available = %v, want [cpp go] (sortiert)", ule.Available)
	}
}

// TestSupportedLangs: sortiert und enthaelt beide Profile (go + cpp, slice-039).
func TestSupportedLangs(t *testing.T) {
	langs := gen.SupportedLangs()
	if !sort.StringsAreSorted(langs) {
		t.Errorf("SupportedLangs nicht sortiert: %v", langs)
	}
	for _, want := range []string{"go", "cpp"} {
		found := false
		for _, l := range langs {
			if l == want {
				found = true
			}
		}
		if !found {
			t.Errorf("SupportedLangs = %v, soll %q enthalten", langs, want)
		}
	}
}

// TestDefaultVersion koppelt die Default-Aufloesung je Sprache (slice-039): go -> die
// Go-Version, cpp -> der ubuntu-Base-Tag, unbekannt -> "" (Generate faengt sie separat).
func TestDefaultVersion(t *testing.T) {
	cases := map[string]string{"go": gen.DefaultGoVersion, "cpp": gen.DefaultCppVersion, "rust": ""}
	for lang, want := range cases {
		if got := gen.DefaultVersion(lang); got != want {
			t.Errorf("DefaultVersion(%q) = %q, want %q", lang, got, want)
		}
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
