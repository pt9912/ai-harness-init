package gen_test

import (
	"errors"
	"path/filepath"
	"regexp"
	"strings"
	"testing"

	"github.com/pt9912/ai-harness-init/internal/gen"
)

// genPythonWith generiert das Python-Skelett mit einem expliziten python-Tag.
func genPythonWith(t *testing.T, version string) string {
	t.Helper()
	return generateWith(t, "python", version)
}

// pythonFragmente liefert das Python-Code-Gate-Fragment in seinen drei Fassungen (Root,
// Subdir apps/py, gemischter Root).
func pythonFragmente(t *testing.T, version string) map[string]string {
	t.Helper()
	return fragmentFassungen(t, "python", "apps/py", version)
}

// tomlAbschnitt liefert den Rumpf des Abschnitts [<name>] einer TOML-Datei ohne Kommentar-
// zeilen — Kommentar-Text ist keine Konfiguration. Fehlt der Abschnitt: Testfehler.
func tomlAbschnitt(t *testing.T, toml, name string) string {
	t.Helper()
	ohneKommentar := regexp.MustCompile(`(?m)^#.*\n`).ReplaceAllString(toml, "")
	return firstSub(t, regexp.MustCompile(`(?s)(?:^|\n)\[`+regexp.QuoteMeta(name)+`\]\n(.*?)(?:\n\[|$)`), ohneKommentar)
}

// TestGenerate_PythonProfile: --lang python erzeugt GENAU den erwarteten Skelett-Satz
// (LH-FA-04, ADR-0095 Festlegung 1) — Einzelprojekt im src-Layout, pyproject.toml nur mit
// Werkzeug-Konfiguration (kein [project], kein Build-Backend), requirements-dev.txt mit genau
// den drei Direkt-Werkzeugen je exakt gepinnt, Dockerfile, Paket, Entry-Point und Test.
func TestGenerate_PythonProfile(t *testing.T) {
	dir := genPythonWith(t, gen.DefaultPythonVersion)
	got := walkRel(t, dir)
	want := []string{
		"Dockerfile", "pyproject.toml", "requirements-dev.txt",
		"src/app/__init__.py", "src/app/main.py", "tests/test_main.py",
	}
	if strings.Join(got, ",") != strings.Join(want, ",") {
		t.Errorf("erzeugter Datei-Satz = %v\nwant %v", got, want)
	}
	pp := mustRead(t, filepath.Join(dir, "pyproject.toml"))
	// Abschnitts-Kopf am Zeilenanfang: der Kopfkommentar nennt beide Namen.
	if m := regexp.MustCompile(`(?m)^\[(project|build-system)\]`).FindString(pp); m != "" {
		t.Errorf("pyproject.toml traegt %s — ADR-0095 Festlegung 1 verlangt nur Werkzeug-Konfiguration:\n%s", m, pp)
	}
	req := strings.Fields(mustRead(t, filepath.Join(dir, "requirements-dev.txt")))
	pin := regexp.MustCompile(`^(pytest|ruff|mypy)==\d+\.\d+\.\d+$`)
	namen := map[string]bool{}
	for _, zeile := range req {
		m := pin.FindStringSubmatch(zeile)
		if m == nil {
			t.Errorf("requirements-dev.txt: %q ist kein exakter Pin eines der drei Direkt-Werkzeuge", zeile)
			continue
		}
		namen[m[1]] = true
	}
	if len(namen) != 3 || len(req) != 3 {
		t.Errorf("requirements-dev.txt fuehrt %v, want genau pytest, ruff, mypy je einmal", req)
	}
	assertFileContains(t, filepath.Join(dir, "Dockerfile"), "FROM python:${PYTHON_TAG} AS toolchain")
	assertFileContains(t, filepath.Join(dir, "Dockerfile"), "RUN pip install -r requirements-dev.txt")
	assertFileContains(t, filepath.Join(dir, "tests", "test_main.py"), "from app.main import greeting")
}

// TestGenerate_PythonDeterministic haelt LH-QA-02 fuer python (assertDeterministic).
func TestGenerate_PythonDeterministic(t *testing.T) {
	assertDeterministic(t, "python", gen.DefaultPythonVersion)
}

// TestPythonLintConfig_TraegtTIDUndBanRelativeImports (ADR-0095 Festlegung 3): gebunden ist,
// dass die emittierte pyproject.toml `F` (F401, unbenutzter Import) und `TID` in `select` des
// Abschnitts [tool.ruff.lint] fuehrt und im Abschnitt [tool.ruff.lint.flake8-tidy-imports]
// `ban-relative-imports = "all"` setzt, und dass mypy strict laeuft. Eine Config ohne `TID`
// oder mit der Voreinstellung der Regel laesst einen relativen Import (TID252) durch `lint`
// und a-check; dass `lint` am gebootstrappten Ziel einen relativen Import tatsaechlich faerbt,
// belegt die full-smoke-Stufe, nicht dieser Text-Test.
func TestPythonLintConfig_TraegtTIDUndBanRelativeImports(t *testing.T) {
	pp := mustRead(t, filepath.Join(genPythonWith(t, gen.DefaultPythonVersion), "pyproject.toml"))
	sel := firstSub(t, regexp.MustCompile(`(?m)^select = \[(.*)\]$`), tomlAbschnitt(t, pp, "tool.ruff.lint"))
	regeln := map[string]bool{}
	for _, r := range strings.Split(sel, ",") {
		regeln[strings.Trim(strings.TrimSpace(r), `"`)] = true
	}
	for _, want := range []string{"F", "TID"} {
		if !regeln[want] {
			t.Errorf("select fuehrt %q nicht: %v", want, regeln)
		}
	}
	tidy := tomlAbschnitt(t, pp, "tool.ruff.lint.flake8-tidy-imports")
	if !regexp.MustCompile(`(?m)^ban-relative-imports = "all"$`).MatchString(tidy) {
		t.Errorf("[tool.ruff.lint.flake8-tidy-imports] setzt ban-relative-imports = \"all\" nicht:\n%s", tidy)
	}
	if !regexp.MustCompile(`(?m)^strict = true$`).MatchString(tomlAbschnitt(t, pp, "tool.mypy")) {
		t.Errorf("[tool.mypy] setzt strict = true nicht:\n%s", pp)
	}
}

// TestPythonLintStage_FuehrtRuffCheckFormatUndMypy (ADR-0095 Festlegung 3): die lint-Stage des
// Dockerfiles fuehrt ruff check, ruff format --check und mypy in einem RUN — ohne eines davon
// bliebe der Stil-, Format- oder Typ-Fall der Fitness Function ungeprueft.
func TestPythonLintStage_FuehrtRuffCheckFormatUndMypy(t *testing.T) {
	df := mustRead(t, filepath.Join(genPythonWith(t, gen.DefaultPythonVersion), "Dockerfile"))
	run := firstSub(t, regexp.MustCompile(`(?m)^FROM toolchain AS lint\nRUN (.*)$`), df)
	for _, schritt := range []string{"ruff check .", "ruff format --check .", "mypy"} {
		if !strings.Contains(run, schritt) {
			t.Errorf("lint-Stage fuehrt %q nicht: RUN %s", schritt, run)
		}
	}
}

// TestPythonCodeGateFragment_TargetsMatchStages ist der LH-QA-01-Anker fuer python (ADR-0095
// §Fitness Function): jedes `docker build --target <X>` in jeder Fassung des Fragments hat eine
// gleichnamige Dockerfile-Stage `AS <X>`, und test/lint/build sind jeweils gerufen.
func TestPythonCodeGateFragment_TargetsMatchStages(t *testing.T) {
	df := mustRead(t, filepath.Join(genPythonWith(t, gen.DefaultPythonVersion), "Dockerfile"))
	assertTargetsMatchStages(t, "python", df, pythonFragmente(t, gen.DefaultPythonVersion))
}

// TestPythonCodeGateFragment_RootUndSubdir: Root-, Subdir- und gemischte Fassung tragen die
// gemeinsame Form (assertRootUndSubdir).
func TestPythonCodeGateFragment_RootUndSubdir(t *testing.T) {
	assertRootUndSubdir(t, "python", "apps-py", "apps/py", pythonFragmente(t, gen.DefaultPythonVersion))
}

// TestPythonCodeGateFragment_EigeneTagVariable: der Versions-Default steht in allen drei
// Fassungen unter PYTHON_TAG und unter keinem der Namen, die die Fragmente von Kotlin und Java
// im selben Ziel mit `?=` setzen — sonst gaelte der erste gelesene Wert fuer beide Sprachen und
// SKEL_PYTHON_VERSION waere kein eigener Knopf (ADR-0095 Festlegung 2).
func TestPythonCodeGateFragment_EigeneTagVariable(t *testing.T) {
	assertTagVariable(t, "python", "PYTHON_TAG", []string{"GRADLE_TAG", "JAVA_GRADLE_TAG"}, pythonFragmente(t, "7.7.7-slim"), "7.7.7-slim")
}

// TestGenerate_PythonVersionThreaded: der uebergebene python-Tag faedelt ins Dockerfile-ARG,
// und DefaultVersion("python") liefert den Default dorthin — der Knopf SKEL_PYTHON_VERSION ist
// am Generator verankert (ADR-0095 Festlegung 2). DefaultPythonVersion hat die Form
// <major>.<minor>.<patch>-slim.
func TestGenerate_PythonVersionThreaded(t *testing.T) {
	df := mustRead(t, filepath.Join(genPythonWith(t, "3.13.16-slim"), "Dockerfile"))
	if got := firstSub(t, regexp.MustCompile(`ARG PYTHON_TAG=(\S+)`), df); got != "3.13.16-slim" {
		t.Errorf("Dockerfile ARG PYTHON_TAG = %q, want 3.13.16-slim", got)
	}
	if !regexp.MustCompile(`^\d+\.\d+\.\d+-slim$`).MatchString(gen.DefaultPythonVersion) {
		t.Errorf("DefaultPythonVersion = %q ist kein python-Tag der Form <ver>-slim (ADR-0095 Festlegung 2)", gen.DefaultPythonVersion)
	}
	if got := mustRead(t, filepath.Join(genPythonWith(t, gen.DefaultVersion("python")), "Dockerfile")); !strings.Contains(got, "ARG PYTHON_TAG="+gen.DefaultPythonVersion+"\n") {
		t.Errorf("DefaultVersion(python) erreicht das Dockerfile nicht:\n%s", got)
	}
}

// TestGenerateArch_PythonOhneHexagonal: hexagonal rendert der Python-Renderer nicht —
// Exit-2-Klasse mit der Liste der Sprache (flat, hexslice), ohne Artefakte (ADR-0095
// Festlegung 5 legt das Layout nicht fest).
func TestGenerateArch_PythonOhneHexagonal(t *testing.T) {
	dir := t.TempDir()
	err := gen.GenerateArch(dir, "python", gen.DefaultPythonVersion, "hexagonal")
	var uae *gen.UnknownArchError
	if !errors.As(err, &uae) {
		t.Fatalf("erwartete *UnknownArchError fuer python+hexagonal, got %v", err)
	}
	if strings.Join(uae.Available, ",") != "flat,hexslice" {
		t.Errorf("Available = %v, want [flat hexslice]", uae.Available)
	}
	if rels := walkRel(t, dir); len(rels) != 0 {
		t.Errorf("abgelehnte Kombination python+hexagonal hat Artefakte geschrieben: %v", rels)
	}
}
