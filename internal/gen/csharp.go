package gen

import (
	"fmt"
	"regexp"
	"strings"
)

// DefaultCsharpVersion ist der gepinnte Default des C#-Skeletts — der **Tag des dotnet-sdk-
// Images** (`mcr.microsoft.com/dotnet/sdk:<tag>`): er bestimmt das SDK der Gate-Stages und,
// ueber csharpTFM, die Ziel-Framework-Moniker der Projekte. TAG-gepinnt, ohne Digest, damit der
// Knopf SKEL_CSHARP_VERSION wirkt; die Konstante ist von den Pins der anderen Sprachen
// entkoppelt (ADR-0096 Festlegung 2, LH-QA-02).
const DefaultCsharpVersion = "10.0.402"

// csharpTagForm ist die Form eines Tags, aus dem Major.Minor ableitbar ist: <major>.<minor>,
// danach hoechstens ein mit `.` oder `-` angeschlossener Rest (`10.0.402`, `10.0.402-noble`).
// `latest` und `10` tragen kein Major.Minor.
var csharpTagForm = regexp.MustCompile(`^(\d+)\.(\d+)(?:[.-].*)?$`)

// InvalidVersionError meldet einen Toolchain-Versions-Wert, aus dem der Renderer der Sprache
// nichts ableiten kann (C#: ein Tag ohne Major.Minor). Als Typ unterscheidbar wie
// UnknownLangError, damit der Aufrufer ihn als Aufruf-Fehler (Exit 2) fuehrt statt als
// Emit-Fehler.
type InvalidVersionError struct {
	Lang    string
	Version string
	Grund   string
}

func (e *InvalidVersionError) Error() string {
	return fmt.Sprintf("ungueltige Toolchain-Version %q fuer %s: %s", e.Version, e.Lang, e.Grund)
}

// csharpTFM leitet den Ziel-Framework-Moniker aus Major.Minor des SDK-Tags ab (`10.0.402` ->
// `net10.0`). Ein Tag ohne Major.Minor ist fail-closed: *InvalidVersionError statt einer
// ungueltigen TFM, die erst beim `docker build` des Ziels rot wuerde (ADR-0096 Festlegung 2).
func csharpTFM(version string) (string, error) {
	m := csharpTagForm.FindStringSubmatch(version)
	if m == nil {
		return "", &InvalidVersionError{
			Lang: "csharp", Version: version,
			Grund: "Major.Minor ist nicht ableitbar (erwartet <major>.<minor>[.<patch>][-<variante>], z.B. 10.0.402)",
		}
	}
	return "net" + m[1] + "." + m[2], nil
}

// csharpProfile ist das C#-SKELETT fuer den gegebenen SDK-Tag (ADR-0096): zwei Projekte
// (src/App, tests/App.Tests) in einer klassischen Solution, die Gates sind Dockerfile-Stages
// (build/test/lint), Test ist xunit, Lint der SDK-Analyzer plus dotnet format ueber
// .editorconfig. Das Code-Gate-Fragment kommt aus gen.CodeGateFragment; das Skelett selbst
// ist ortsunabhaengig. Statisch/deterministisch (LH-QA-02).
func csharpProfile(version, arch string) map[string]string {
	return composeSkeleton(csharpScaffolding, csharpRole, version, arch)
}

// csharpScaffolding — die arch-INVARIANTE C#-Geruestung (ADR-0096 Festlegung 1): Solution,
// gemeinsame Eigenschaften mit der abgeleiteten TFM, Analyzer-Schweregrade, beide Projekt-
// Dateien und das Dockerfile. GenerateArch prueft den Tag (versionValidators) vor dem Aufruf;
// ein nicht ableitbarer Tag erreicht diese Funktion nicht.
func csharpScaffolding(version string) map[string]string {
	tfm, _ := csharpTFM(version)
	return map[string]string{
		"app.sln":                          csharpSolution,
		"Directory.Build.props":            strings.ReplaceAll(csharpBuildProps, "{{TFM}}", tfm),
		".editorconfig":                    csharpEditorconfig,
		"src/App/App.csproj":               csharpAppProject,
		"tests/App.Tests/App.Tests.csproj": csharpTestProject,
		"Dockerfile":                       renderCsharp(csharpDockerfileTmpl, version),
	}
}

// csharpRole rendert eine Code-Rolle als C#-Datei. Getragen ist allein das Layout flat
// (langArchs): Entry-Point unter src/App, Test unter tests/App.Tests. Jede andere Rolle -> nil.
func csharpRole(r codeRole) map[string]string {
	switch r {
	case roleEntrypoint:
		return map[string]string{"src/App/Program.cs": csharpMain}
	case roleTest:
		return map[string]string{"tests/App.Tests/ProgramTests.cs": csharpTest}
	}
	return nil
}

// csharpFragment liefert das C#-Code-Gate-Fragment: am Root (context ".") die UNSCOPED
// Fassung, im Subdir die MODUL-SCOPED. Jedes `docker build --target <stage>` referenziert eine
// gleichnamige Dockerfile-Stage — TestCsharpCodeGateFragment_TargetsMatchStages haelt die
// Kopplung (LH-QA-01).
func csharpFragment(modul, context, version string) string {
	if context == "." {
		return renderCsharp(csharpMkFragmentTmpl, version)
	}
	return renderCsharpScoped(csharpScopedMkFragmentTmpl, modul, context, version)
}

// csharpFragmentMixed liefert die gemischte Root-Fassung: modul-scoped Targets plus
// Praezedenz-Erweiterung der unscoped Ziele ohne eigenes Rezept.
func csharpFragmentMixed(modul, context, version string) string {
	return renderCsharpScoped(csharpMixedMkFragmentTmpl, modul, context, version)
}

// renderCsharp setzt den SDK-Tag in ein C#-Template ein ({{DOTNET_TAG}}).
func renderCsharp(tmpl, version string) string {
	return strings.ReplaceAll(tmpl, "{{DOTNET_TAG}}", version)
}

// renderCsharpScoped setzt Modul-Name, Build-Kontext und SDK-Tag ein.
func renderCsharpScoped(tmpl, modul, context, version string) string {
	return strings.NewReplacer(
		"{{MODULE}}", modul,
		"{{CONTEXT}}", context,
		"{{DOTNET_TAG}}", version,
	).Replace(tmpl)
}

// csharpSolution — die klassische Solution mit festen Projekt-GUIDs (statischer Text, kein
// `dotnet sln` im Generator; ADR-0096 Festlegung 1). Die Typ-GUID FAE04EC0-… ist die der
// C#-SDK-Projekte.
const csharpSolution = `Microsoft Visual Studio Solution File, Format Version 12.00
# Visual Studio Version 17
VisualStudioVersion = 17.0.31903.59
MinimumVisualStudioVersion = 10.0.40219.1
Project("{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}") = "App", "src\App\App.csproj", "{3F6B1C2A-8D4E-4B7A-9C15-6E2A0D7F4B11}"
EndProject
Project("{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}") = "App.Tests", "tests\App.Tests\App.Tests.csproj", "{9A2D5E73-1C48-4F06-B8E1-4D7C3A6F2E95}"
EndProject
Global
	GlobalSection(SolutionConfigurationPlatforms) = preSolution
		Debug|Any CPU = Debug|Any CPU
		Release|Any CPU = Release|Any CPU
	EndGlobalSection
	GlobalSection(SolutionProperties) = preSolution
		HideSolutionNode = FALSE
	EndGlobalSection
	GlobalSection(ProjectConfigurationPlatforms) = postSolution
		{3F6B1C2A-8D4E-4B7A-9C15-6E2A0D7F4B11}.Debug|Any CPU.ActiveCfg = Debug|Any CPU
		{3F6B1C2A-8D4E-4B7A-9C15-6E2A0D7F4B11}.Debug|Any CPU.Build.0 = Debug|Any CPU
		{3F6B1C2A-8D4E-4B7A-9C15-6E2A0D7F4B11}.Release|Any CPU.ActiveCfg = Release|Any CPU
		{3F6B1C2A-8D4E-4B7A-9C15-6E2A0D7F4B11}.Release|Any CPU.Build.0 = Release|Any CPU
		{9A2D5E73-1C48-4F06-B8E1-4D7C3A6F2E95}.Debug|Any CPU.ActiveCfg = Debug|Any CPU
		{9A2D5E73-1C48-4F06-B8E1-4D7C3A6F2E95}.Debug|Any CPU.Build.0 = Debug|Any CPU
		{9A2D5E73-1C48-4F06-B8E1-4D7C3A6F2E95}.Release|Any CPU.ActiveCfg = Release|Any CPU
		{9A2D5E73-1C48-4F06-B8E1-4D7C3A6F2E95}.Release|Any CPU.Build.0 = Release|Any CPU
	EndGlobalSection
EndGlobal
`

// csharpBuildProps — gemeinsame Eigenschaften beider Projekte (ADR-0096 Festlegung 1 und 3).
// Gebunden sind TreatWarningsAsErrors (sonst bleibt eine unbenutzte Variable gruen) und
// AnalysisLevel latest-recommended (sonst faerbt eine nicht-statische Methode ohne
// Instanzzugriff, CA1822, den Build nicht). Die TFM ist ein Literal aus Major.Minor des
// Image-Tags: die Make-Variable DOTNET_TAG zu einem anderen Major zu ueberschreiben, ohne neu
// zu generieren, endet im Ziel mit NETSDK1045.
const csharpBuildProps = `<!-- Directory.Build.props — generiert von ai-harness-init. Die Datei ist DEINE: sie wird
     beim Re-Bootstrap nicht ueberschrieben. Die TFM ist aus Major.Minor des SDK-Tags im
     Dockerfile abgeleitet; einen anderen Major per DOTNET_TAG zu waehlen, ohne das Skelett neu
     zu erzeugen, scheitert mit NETSDK1045. -->
<Project>
  <PropertyGroup>
    <TargetFramework>{{TFM}}</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>disable</ImplicitUsings>
    <TreatWarningsAsErrors>true</TreatWarningsAsErrors>
    <AnalysisLevel>latest-recommended</AnalysisLevel>
  </PropertyGroup>
</Project>
`

// csharpEditorconfig — Analyzer-Schweregrade fuer dotnet format (ADR-0096 Festlegung 3).
// Gebunden sind IDE0005 (unbenutztes using) und IDE0130 (Namensraum folgt dem Verzeichnis);
// ohne die Zeile faerbt die jeweilige Regel weder lint noch build.
const csharpEditorconfig = `# .editorconfig — generiert von ai-harness-init. Die Datei ist DEINE: sie wird beim
# Re-Bootstrap nicht ueberschrieben.
root = true

[*.cs]
indent_style = space
indent_size = 4
dotnet_diagnostic.IDE0005.severity = error
dotnet_diagnostic.IDE0130.severity = error
`

const csharpAppProject = `<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <OutputType>Exe</OutputType>
  </PropertyGroup>

</Project>
`

// csharpTestProject — xunit 2.9.3 mit den Vorlagen-Versionen von Microsoft.NET.Test.Sdk und
// xunit.runner.visualstudio (ADR-0096 Festlegung 3). Transitive Pakete sind nicht gepinnt: ein
// statisch erzeugtes Skelett traegt keine Lock-Datei.
const csharpTestProject = `<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <IsPackable>false</IsPackable>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="Microsoft.NET.Test.Sdk" Version="17.14.1" />
    <PackageReference Include="xunit" Version="2.9.3" />
    <PackageReference Include="xunit.runner.visualstudio" Version="3.1.4" />
  </ItemGroup>

  <ItemGroup>
    <ProjectReference Include="../../src/App/App.csproj" />
  </ItemGroup>

</Project>
`

const csharpMain = `using System;

namespace App;

public static class Greeting
{
    public static string For(string name) => "Hallo, " + name;
}

public static class Program
{
    public static void Main() => Console.WriteLine(Greeting.For("Welt"));
}
`

const csharpTest = `using Xunit;

namespace App.Tests;

public class ProgramTests
{
    [Fact]
    public void GreetingNenntDenNamen() => Assert.Equal("Hallo, Welt", Greeting.For("Welt"));
}
`

const csharpDockerfileTmpl = `# syntax=docker/dockerfile:1.7
# Dockerfile — generiert von ai-harness-init (C#-Skelett). Jede Gate ist eine Stage
# (docker build --target <stage>); das dotnet-sdk-Image ist TAG-gepinnt (kein floating), der
# Digest bewusst weggelassen, damit DOTNET_TAG ein echter Knopf bleibt. Der NuGet-Restore laeuft
# einmal in der toolchain-Stage und braucht beim Bild-Build Netz — das ist kein
# Host-Toolchain-Aufruf (der Guard blockt dotnet nur auf dem Host).
ARG DOTNET_TAG={{DOTNET_TAG}}

FROM mcr.microsoft.com/dotnet/sdk:${DOTNET_TAG} AS toolchain
ENV DOTNET_CLI_TELEMETRY_OPTOUT=1 DOTNET_NOLOGO=1 DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1
WORKDIR /src
COPY . .
RUN dotnet restore

FROM toolchain AS build
RUN dotnet build --no-restore -c Release

FROM toolchain AS test
RUN dotnet test --no-restore

FROM toolchain AS lint
RUN dotnet format --verify-no-changes --no-restore
`

// csharpMkFragmentTmpl — das C#-Code-Gate-Fragment (harness/mk/csharp.mk): lint/build/test
// als Dockerfile-Stages, an GATE_CHECKS gehaengt. Die Make-Variable heisst DOTNET_TAG und
// kollidiert mit keinem Namen der Fragmente der anderen Sprachen. Recipe-Zeilen sind
// TAB-eingerueckt.
const csharpMkFragmentTmpl = `# harness/mk/csharp.mk — C#-Code-Gate-Fragment, generiert von ai-harness-init. Die
# Gates sind Dockerfile-Stages (Docker-only); dieses Fragment haengt
# lint/build/test an GATE_CHECKS, der Root-Aggregator faehrt sie via make gates.
DOTNET_TAG ?= {{DOTNET_TAG}}
IMAGE ?= app

.PHONY: test lint build

test: ## C#-Tests (xunit, Dockerfile test-Stage) — Docker-only
	docker build --build-arg DOTNET_TAG=$(DOTNET_TAG) --target test -t $(IMAGE):test .

lint: ## C#-Lint (dotnet format, Dockerfile lint-Stage) — Docker-only
	docker build --build-arg DOTNET_TAG=$(DOTNET_TAG) --target lint -t $(IMAGE):lint .

build: ## C#-Build (dotnet build, Dockerfile build-Stage) — Docker-only
	docker build --build-arg DOTNET_TAG=$(DOTNET_TAG) --target build -t $(IMAGE):build .

GATE_CHECKS += lint build test
`

// csharpMixedMkFragmentTmpl — die C#-Fassung fuer den GEMISCHTEN Root: modul-scoped Targets,
// und die unscoped Ziele test/lint/build NUR als Praezedenz-Erweiterung ohne eigenes Rezept.
// GATE_CHECKS haengt die UNSCOPED Namen an (record-gates dedupliziert); die scoped Namen stehen
// nicht daneben, sonst liefe der C#-Kontext in gates doppelt.
const csharpMixedMkFragmentTmpl = `# harness/mk/{{MODULE}}.mk — C#-Code-Gate-Fragment (Modul {{MODULE}}), generiert von
# ai-harness-init. Gates als Dockerfile-Stages (Docker-only); modul-scoped
# Targets, Build-Kontext {{CONTEXT}} — ein zweites Sprach-Fragment liegt am Root, darum
# traegt dieses Fragment die unscoped Ziele test/lint/build nur als Praezedenz-Erweiterung
# ohne eigenes Rezept: make haengt Praezedenz-Listen mehrerer Regeln zusammen. Welches
# Fragment das eigene Rezept traegt, haengt vom Verlauf der add-lang-Aufrufe ab.
DOTNET_TAG ?= {{DOTNET_TAG}}

.PHONY: test lint build test-{{MODULE}} lint-{{MODULE}} build-{{MODULE}}

test-{{MODULE}}: ## C#-Tests Modul {{MODULE}} (xunit, test-Stage) — Docker-only
	docker build --build-arg DOTNET_TAG=$(DOTNET_TAG) --target test -t {{MODULE}}:test {{CONTEXT}}

lint-{{MODULE}}: ## C#-Lint Modul {{MODULE}} (dotnet format, lint-Stage) — Docker-only
	docker build --build-arg DOTNET_TAG=$(DOTNET_TAG) --target lint -t {{MODULE}}:lint {{CONTEXT}}

build-{{MODULE}}: ## C#-Build Modul {{MODULE}} (dotnet build, build-Stage) — Docker-only
	docker build --build-arg DOTNET_TAG=$(DOTNET_TAG) --target build -t {{MODULE}}:build {{CONTEXT}}

test: test-{{MODULE}}
lint: lint-{{MODULE}}
build: build-{{MODULE}}

GATE_CHECKS += test lint build
`

// csharpScopedMkFragmentTmpl — die MODUL-SCOPED Fassung fuer ein Mono-Repo-Submodul unter
// {{CONTEXT}}: modul-scoped Targets (kollisionsfrei), Image-Tag inline der Modul-Name.
const csharpScopedMkFragmentTmpl = `# harness/mk/{{MODULE}}.mk — C#-Code-Gate-Fragment (Modul {{MODULE}}), generiert von
# ai-harness-init. Gates als Dockerfile-Stages (Docker-only); modul-scoped
# Targets (kollisionsfrei im Mono-Repo), Build-Kontext {{CONTEXT}}. Haengt an GATE_CHECKS,
# der Root-Aggregator faehrt sie via make gates.
DOTNET_TAG ?= {{DOTNET_TAG}}

.PHONY: test-{{MODULE}} lint-{{MODULE}} build-{{MODULE}}

test-{{MODULE}}: ## C#-Tests Modul {{MODULE}} (xunit, test-Stage) — Docker-only
	docker build --build-arg DOTNET_TAG=$(DOTNET_TAG) --target test -t {{MODULE}}:test {{CONTEXT}}

lint-{{MODULE}}: ## C#-Lint Modul {{MODULE}} (dotnet format, lint-Stage) — Docker-only
	docker build --build-arg DOTNET_TAG=$(DOTNET_TAG) --target lint -t {{MODULE}}:lint {{CONTEXT}}

build-{{MODULE}}: ## C#-Build Modul {{MODULE}} (dotnet build, build-Stage) — Docker-only
	docker build --build-arg DOTNET_TAG=$(DOTNET_TAG) --target build -t {{MODULE}}:build {{CONTEXT}}

GATE_CHECKS += lint-{{MODULE}} build-{{MODULE}} test-{{MODULE}}
`
