package gen_test

import (
	"errors"
	"path/filepath"
	"regexp"
	"strings"
	"testing"

	"github.com/pt9912/ai-harness-init/internal/gen"
)

// genCsharpWith generiert das C#-Skelett mit einem expliziten SDK-Tag.
func genCsharpWith(t *testing.T, version string) string {
	t.Helper()
	return generateWith(t, "csharp", version)
}

// csharpFragmente liefert das C#-Code-Gate-Fragment in seinen drei Fassungen (Root, Subdir
// apps/cs, gemischter Root).
func csharpFragmente(t *testing.T, version string) map[string]string {
	t.Helper()
	return fragmentFassungen(t, "csharp", "apps/cs", version)
}

// ohneXMLKommentare entfernt die Kommentare einer XML-Datei — Kommentar-Text ist keine
// Konfiguration.
func ohneXMLKommentare(xml string) string {
	return regexp.MustCompile(`(?s)<!--.*?-->`).ReplaceAllString(xml, "")
}

// editorconfigAbschnitt liefert den Rumpf des Abschnitts [<glob>] einer .editorconfig ohne
// Kommentarzeilen. Fehlt der Abschnitt: Testfehler.
func editorconfigAbschnitt(t *testing.T, text, glob string) string {
	t.Helper()
	ohneKommentar := regexp.MustCompile(`(?m)^#.*\n`).ReplaceAllString(text, "")
	return firstSub(t, regexp.MustCompile(`(?s)(?:^|\n)\[`+regexp.QuoteMeta(glob)+`\]\n(.*?)(?:\n\[|$)`), ohneKommentar)
}

// TestGenerate_CsharpProfile: --lang csharp erzeugt GENAU den erwarteten Skelett-Satz (LH-FA-04,
// ADR-0096 Festlegung 1) — klassische Solution mit beiden Projekten unter festen GUIDs, die zwei
// Projekt-Dateien mit den drei xunit-Paketen je exakt gepinnt, Dockerfile, Entry-Point und Test.
func TestGenerate_CsharpProfile(t *testing.T) {
	dir := genCsharpWith(t, gen.DefaultCsharpVersion)
	got := walkRel(t, dir)
	want := []string{
		".editorconfig", "Directory.Build.props", "Dockerfile", "app.sln",
		"src/App/App.csproj", "src/App/Program.cs",
		"tests/App.Tests/App.Tests.csproj", "tests/App.Tests/ProgramTests.cs",
	}
	if strings.Join(got, ",") != strings.Join(want, ",") {
		t.Errorf("erzeugter Datei-Satz = %v\nwant %v", got, want)
	}
	sln := mustRead(t, filepath.Join(dir, "app.sln"))
	guids := regexp.MustCompile(`(?m)^Project\("\{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC\}"\) = "(App|App\.Tests)", "[^"]+", "(\{[0-9A-F-]{36}\})"$`).FindAllStringSubmatch(sln, -1)
	if len(guids) != 2 || guids[0][2] == guids[1][2] {
		t.Errorf("app.sln fuehrt nicht genau zwei Projekte mit verschiedenen GUIDs: %v", guids)
	}
	proj := mustRead(t, filepath.Join(dir, "tests", "App.Tests", "App.Tests.csproj"))
	for _, want := range []string{
		`Include="Microsoft.NET.Test.Sdk" Version="17.14.1"`,
		`Include="xunit" Version="2.9.3"`,
		`Include="xunit.runner.visualstudio" Version="3.1.4"`,
		`Include="../../src/App/App.csproj"`,
	} {
		if !strings.Contains(proj, want) {
			t.Errorf("App.Tests.csproj fuehrt %q nicht:\n%s", want, proj)
		}
	}
	assertFileContains(t, filepath.Join(dir, "src", "App", "App.csproj"), "<OutputType>Exe</OutputType>")
	assertFileContains(t, filepath.Join(dir, "Dockerfile"), "FROM mcr.microsoft.com/dotnet/sdk:${DOTNET_TAG} AS toolchain")
}

// TestGenerate_CsharpDeterministic haelt LH-QA-02 fuer csharp (assertDeterministic).
func TestGenerate_CsharpDeterministic(t *testing.T) {
	assertDeterministic(t, "csharp", gen.DefaultCsharpVersion)
}

// TestCsharpTFM_FolgtMajorMinorDesTags (ADR-0096 Festlegung 2): die gerenderte TFM in
// Directory.Build.props ist `net<Major>.<Minor>` des SDK-Tags — fuer mehrere Tags, auch mit
// Minor ungleich 0 und mit Varianten-Suffix. Eine Ableitung, die einen festen Wert schreibt,
// faellt an dem Tag, der davon abweicht.
func TestCsharpTFM_FolgtMajorMinorDesTags(t *testing.T) {
	for tag, want := range map[string]string{
		"10.0.402":      "net10.0",
		"10.1.100":      "net10.1",
		"9.0.100":       "net9.0",
		"8.0.426-noble": "net8.0",
		"10.0":          "net10.0",
	} {
		props := ohneXMLKommentare(mustRead(t, filepath.Join(genCsharpWith(t, tag), "Directory.Build.props")))
		if got := firstSub(t, regexp.MustCompile(`<TargetFramework>([^<]*)</TargetFramework>`), props); got != want {
			t.Errorf("Tag %s: TargetFramework = %q, want %q", tag, got, want)
		}
	}
}

// TestGenerateCsharp_TagOhneMajorMinorBrichtAb (ADR-0096 Festlegung 2): ein Knopf-Wert ohne
// Major.Minor (`latest`, `10`, leer, mit fremdem Praefix) ist ein Aufruf-Fehler —
// *InvalidVersionError (Exit 2 am Aufrufer) und KEIN Artefakt, statt einer ungueltigen TFM, die
// erst beim docker build des Ziels rot wuerde.
func TestGenerateCsharp_TagOhneMajorMinorBrichtAb(t *testing.T) {
	for _, tag := range []string{"latest", "10", "", "v10.0.402", "10.x"} {
		dir := t.TempDir()
		err := gen.Generate(dir, "csharp", tag)
		var ive *gen.InvalidVersionError
		if !errors.As(err, &ive) {
			t.Errorf("Tag %q: erwartete *InvalidVersionError, got %v", tag, err)
			continue
		}
		if rels := walkRel(t, dir); len(rels) != 0 {
			t.Errorf("Tag %q: abgelehnter Wert hat Artefakte geschrieben: %v", tag, rels)
		}
	}
}

// TestCsharpConfig_TraegtDieGebundenenZeilen (ADR-0096 Festlegung 3): gebunden ist, dass die
// emittierte .editorconfig im Abschnitt [*.cs] IDE0005 und IDE0130 auf `error` setzt und
// Directory.Build.props TreatWarningsAsErrors true und AnalysisLevel latest-recommended fuehrt.
// Jede der vier Zeilen faerbt beim Entfernen rot; dass lint bzw. build die Regel am
// gebootstrappten Ziel tatsaechlich meldet, belegt die full-smoke-Stufe, nicht dieser Text-Test.
func TestCsharpConfig_TraegtDieGebundenenZeilen(t *testing.T) {
	dir := genCsharpWith(t, gen.DefaultCsharpVersion)
	cs := editorconfigAbschnitt(t, mustRead(t, filepath.Join(dir, ".editorconfig")), "*.cs")
	for _, regel := range []string{"IDE0005", "IDE0130"} {
		if !regexp.MustCompile(`(?m)^dotnet_diagnostic\.` + regel + `\.severity = error$`).MatchString(cs) {
			t.Errorf(".editorconfig [*.cs] setzt %s nicht auf error:\n%s", regel, cs)
		}
	}
	props := ohneXMLKommentare(mustRead(t, filepath.Join(dir, "Directory.Build.props")))
	for _, zeile := range []string{
		"<TreatWarningsAsErrors>true</TreatWarningsAsErrors>",
		"<AnalysisLevel>latest-recommended</AnalysisLevel>",
	} {
		if !strings.Contains(props, zeile) {
			t.Errorf("Directory.Build.props fuehrt %s nicht:\n%s", zeile, props)
		}
	}
	// Nicht gebunden und nicht im Geruest (ADR-0096 Festlegung 3): beide braeuchten eine erzeugte
	// Dokumentationsdatei bzw. waeren Ballast.
	for _, fremd := range []string{"EnforceCodeStyleInBuild", "GenerateDocumentationFile"} {
		if strings.Contains(props, fremd) {
			t.Errorf("Directory.Build.props fuehrt %s — nicht Teil des Geruests (ADR-0096 Festlegung 3)", fremd)
		}
	}
}

// TestCsharpStages_FuehrenDieKommandosDerAdr (ADR-0096 Festlegung 3): der Restore laeuft einmal
// in der toolchain-Stage, build/test/lint fahren ohne erneuten Restore, und lint ist
// `dotnet format --verify-no-changes` — ohne dieses Kommando bliebe der IDE0005-Fall ungeprueft.
func TestCsharpStages_FuehrenDieKommandosDerAdr(t *testing.T) {
	df := mustRead(t, filepath.Join(genCsharpWith(t, gen.DefaultCsharpVersion), "Dockerfile"))
	for _, want := range []string{
		"AS toolchain\n", "\nRUN dotnet restore\n",
		"FROM toolchain AS build\nRUN dotnet build --no-restore -c Release\n",
		"FROM toolchain AS test\nRUN dotnet test --no-restore\n",
		"FROM toolchain AS lint\nRUN dotnet format --verify-no-changes --no-restore\n",
	} {
		if !strings.Contains(df, want) {
			t.Errorf("Dockerfile fuehrt %q nicht:\n%s", want, df)
		}
	}
}

// TestCsharpCodeGateFragment_TargetsMatchStages ist der LH-QA-01-Anker fuer csharp (ADR-0096
// §Fitness Function): jedes `docker build --target <X>` in jeder Fassung des Fragments hat eine
// gleichnamige Dockerfile-Stage `AS <X>`, und test/lint/build sind jeweils gerufen.
func TestCsharpCodeGateFragment_TargetsMatchStages(t *testing.T) {
	df := mustRead(t, filepath.Join(genCsharpWith(t, gen.DefaultCsharpVersion), "Dockerfile"))
	assertTargetsMatchStages(t, "csharp", df, csharpFragmente(t, gen.DefaultCsharpVersion))
}

// TestCsharpCodeGateFragment_RootUndSubdir: Root-, Subdir- und gemischte Fassung tragen die
// gemeinsame Form (assertRootUndSubdir).
func TestCsharpCodeGateFragment_RootUndSubdir(t *testing.T) {
	assertRootUndSubdir(t, "csharp", "apps-cs", "apps/cs", csharpFragmente(t, gen.DefaultCsharpVersion))
}

// TestCsharpCodeGateFragment_EigeneTagVariable: der Versions-Default steht in allen drei
// Fassungen unter DOTNET_TAG und unter keinem der Namen, die die Fragmente von Kotlin, Java und
// Python im selben Ziel mit `?=` setzen — sonst gaelte der erste gelesene Wert fuer beide
// Sprachen und SKEL_CSHARP_VERSION waere kein eigener Knopf (ADR-0096 Festlegung 2).
func TestCsharpCodeGateFragment_EigeneTagVariable(t *testing.T) {
	assertTagVariable(t, "csharp", "DOTNET_TAG", []string{"GRADLE_TAG", "JAVA_GRADLE_TAG", "PYTHON_TAG"}, csharpFragmente(t, "7.7.7"), "7.7.7")
}

// TestGenerate_CsharpVersionThreaded: der uebergebene SDK-Tag faedelt ins Dockerfile-ARG, und
// DefaultVersion("csharp") liefert den Default dorthin — der Knopf SKEL_CSHARP_VERSION ist am
// Generator verankert (ADR-0096 Festlegung 2). DefaultCsharpVersion hat die Form
// <major>.<minor>.<patch>.
func TestGenerate_CsharpVersionThreaded(t *testing.T) {
	df := mustRead(t, filepath.Join(genCsharpWith(t, "9.0.100"), "Dockerfile"))
	if got := firstSub(t, regexp.MustCompile(`ARG DOTNET_TAG=(\S+)`), df); got != "9.0.100" {
		t.Errorf("Dockerfile ARG DOTNET_TAG = %q, want 9.0.100", got)
	}
	if !regexp.MustCompile(`^\d+\.\d+\.\d+$`).MatchString(gen.DefaultCsharpVersion) {
		t.Errorf("DefaultCsharpVersion = %q ist kein SDK-Tag der Form <major>.<minor>.<patch> (ADR-0096 Festlegung 2)", gen.DefaultCsharpVersion)
	}
	if got := mustRead(t, filepath.Join(genCsharpWith(t, gen.DefaultVersion("csharp")), "Dockerfile")); !strings.Contains(got, "ARG DOTNET_TAG="+gen.DefaultCsharpVersion+"\n") {
		t.Errorf("DefaultVersion(csharp) erreicht das Dockerfile nicht:\n%s", got)
	}
}

// TestGenerateArch_CsharpOhneHexagonal: hexagonal rendert der C#-Renderer nicht — Exit-2-Klasse
// mit der Liste der Sprache (flat, hexslice), ohne Artefakte (ADR-0096 Festlegung 5 legt das
// Layout nicht fest).
func TestGenerateArch_CsharpOhneHexagonal(t *testing.T) {
	dir := t.TempDir()
	err := gen.GenerateArch(dir, "csharp", gen.DefaultCsharpVersion, "hexagonal")
	var uae *gen.UnknownArchError
	if !errors.As(err, &uae) {
		t.Fatalf("erwartete *UnknownArchError fuer csharp+hexagonal, got %v", err)
	}
	if strings.Join(uae.Available, ",") != "flat,hexslice" {
		t.Errorf("Available = %v, want [flat hexslice]", uae.Available)
	}
	if rels := walkRel(t, dir); len(rels) != 0 {
		t.Errorf("abgelehnte Kombination csharp+hexagonal hat Artefakte geschrieben: %v", rels)
	}
}
