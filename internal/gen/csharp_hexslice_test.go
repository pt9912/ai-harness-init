package gen_test

import (
	"path/filepath"
	"regexp"
	"strings"
	"testing"

	"github.com/pt9912/ai-harness-init/internal/gen"
)

// genCsharpHexslice generiert das hexSlice-C#-Skelett in ein frisches Temp-Verzeichnis.
func genCsharpHexslice(t *testing.T) string {
	t.Helper()
	dir := t.TempDir()
	if err := gen.GenerateArch(dir, "csharp", gen.DefaultCsharpVersion, "hexslice"); err != nil {
		t.Fatalf("GenerateArch(csharp, hexslice): %v", err)
	}
	return dir
}

// TestGenerate_CsharpHexsliceProfile_FileSet (LH-FA-04, ADR-0096 Festlegung 5): --arch hexslice
// erzeugt GENAU die Rollen-Dateien unter src/App/{Hexagon,Adapters} plus Composition Root, Test
// und die arch-invariante Geruestung — nicht mehr, nicht weniger. Die Verzeichnisse sind PascalCase, die
// Richtungs-Ordner unter Ports klein (ADR-0097).
func TestGenerate_CsharpHexsliceProfile_FileSet(t *testing.T) {
	got := walkRel(t, genCsharpHexslice(t))
	const a, h = "src/App/Adapters/", "src/App/Hexagon/"
	want := []string{
		".editorconfig", "Directory.Build.props", "Dockerfile", "app.sln",
		a + "Driven/Memory/Example/InMemoryRepository.cs",
		a + "Driven/Notify/StdoutNotifier.cs",
		a + "Driving/Cli/Example/GreetCli.cs",
		"src/App/App.csproj",
		h + "Application/Example/Greet/Handler.cs",
		h + "Application/Example/Greet/Ports/inbound/IGreet.cs",
		h + "Application/Example/Greet/Ports/outbound/INotifier.cs",
		h + "Application/Example/Ports/outbound/IGreetingRepository.cs",
		h + "Domain/Example/Greeting.cs",
		"src/App/Program.cs",
		"tests/App.Tests/App.Tests.csproj", "tests/App.Tests/GreetTests.cs",
	}
	if strings.Join(got, ",") != strings.Join(want, ",") {
		t.Errorf("csharp-hexSlice-Datei-Satz = %v\nwant %v", got, want)
	}
}

// csharpConfigResolution zieht languages-Glob, mode, roots und package_base aus der Config.
func csharpConfigResolution(t *testing.T, cfg string) (langGlob, mode string, roots []string, base string) {
	t.Helper()
	return archConfigResolution(t, cfg, "csharp")
}

// TestArchGateConfig_CsharpResolution (ADR-0096 Festlegung 5, LH-FA-07): die Config traegt
// `languages: csharp: ["**/*.cs"]`, `exclude: ["tests/**"]`, `composition_root:
// ["src/App/Program.cs"]` und `resolution: csharp: {mode: fixed-root, roots: ["src/App"],
// package_base: "App"}` je Schluessel woertlich; der Root endet im package_base-Verzeichnis, und
// jede gerenderte Produktionsdatei ausser dem Composition Root liegt unter diesem Root. Ein
// verfaelschter Schluessel faerbt den Test: test/mutations/749 (mode), 750 (roots), 751
// (package_base), 752 (languages-Glob), 753 (exclude), 754 (composition_root), 755 (Pfade
// ausserhalb des Roots). Dass a-check das using im gebootstrappten Ziel wirklich aufloest,
// belegt allein die Stufe in full-smoke; `exclude: tests/**` ist an keiner Fixture gemessen.
func TestArchGateConfig_CsharpResolution(t *testing.T) {
	cfg, ok := gen.ArchGateConfig("csharp", "hexslice")
	if !ok {
		t.Fatal("csharp+hexslice traegt keine Arch-Gate-Config")
	}
	assertArchConfigResolution(t, cfg, genCsharpHexslice(t), archKeys{
		lang: "csharp", ext: ".cs", langGlob: "**/*.cs", root: "src/App", base: "App", composition: "src/App/Program.cs",
	})
}

// TestArchGateConfig_CsharpMatchesSkeleton (ADR-0096 Festlegung 5, LH-FA-07): jede
// Produktionsdatei ausser dem Composition Root faellt unter den erwarteten Schicht-Glob, und
// jeder Glob ist fuer mindestens eine Datei der spezifischste. Die Erwartung steht
// ausgeschrieben, nicht aus der Config abgeleitet. Tests liegen unter tests/.
func TestArchGateConfig_CsharpMatchesSkeleton(t *testing.T) {
	cfg, ok := gen.ArchGateConfig("csharp", "hexslice")
	if !ok {
		t.Fatal("csharp+hexslice traegt keine Arch-Gate-Config")
	}
	const hex, ad = "src/App/Hexagon/", "src/App/Adapters/"
	want := map[string]string{
		hex + "Domain/Example/Greeting.cs":                                "domain",
		hex + "Application/Example/Greet/Ports/inbound/IGreet.cs":         "ports_inbound",
		hex + "Application/Example/Greet/Ports/outbound/INotifier.cs":     "ports_outbound",
		hex + "Application/Example/Ports/outbound/IGreetingRepository.cs": "ports_outbound",
		hex + "Application/Example/Greet/Handler.cs":                      "app",
		ad + "Driving/Cli/Example/GreetCli.cs":                            "driving_adapters",
		ad + "Driven/Memory/Example/InMemoryRepository.cs":                "driven_adapters",
		ad + "Driven/Notify/StdoutNotifier.cs":                            "driven_adapters",
	}
	nurTest := func(rel string) bool { return strings.HasPrefix(rel, "tests/") }
	assertGlobsMatchSkeleton(t, cfg, genCsharpHexslice(t), ".cs", "src/App/Program.cs", want, nurTest)
}

// csharpVerzeichnisse liefert die Verzeichnisse des Skeletts, die eine .cs-Datei tragen — mit der
// Schreibweise, in der sie gerendert sind.
func csharpVerzeichnisse(t *testing.T, dir string) map[string]bool {
	t.Helper()
	out := map[string]bool{}
	for _, rel := range walkRel(t, dir) {
		if strings.HasSuffix(rel, ".cs") {
			out[filepath.ToSlash(filepath.Dir(rel))] = true
		}
	}
	return out
}

// TestArchGateConfig_CsharpGlobsMatchRenderedDirs (ADR-0096 Festlegung 5, Luecke zu Skelett-
// Pflicht (b)): das literale Praefix jedes Schicht-Globs der Config (der Pfad vor dem `/**`) ist
// ein gerendertes Verzeichnis oder ein Vorfahr eines solchen, und zwar in genau derselben
// Gross-/Kleinschreibung: a-check unterscheidet sie, IDE0130 nicht. Das haelt den Renderer; ein
// Adopter, der Verzeichnisse umbenennt, bleibt ungehalten. Rot faerben test/mutations/756
// (Hexagon-Verzeichnisse klein gerendert) und 766 (Richtungs-Glob der Config gross, Renderer
// klein). Schreiben Renderer UND Config dieselbe Grossschreibung, haelt diesen Test nichts:
// das haelt TestCsharpHexslice_RichtungsOrdnerKlein.
func TestArchGateConfig_CsharpGlobsMatchRenderedDirs(t *testing.T) {
	cfg, _ := gen.ArchGateConfig("csharp", "hexslice")
	dirs := csharpVerzeichnisse(t, genCsharpHexslice(t))
	n := 0
	for layer, globs := range archGlobs(t, cfg) {
		for _, g := range globs {
			n++
			prefix := strings.TrimSuffix(g, "/**")
			if strings.ContainsAny(prefix, "*?[") {
				t.Errorf("Schicht %s: Glob %q traegt kein literales Verzeichnis-Praefix", layer, g)
				continue
			}
			found := false
			for d := range dirs {
				if d == prefix || strings.HasPrefix(d, prefix+"/") {
					found = true
				}
			}
			if !found {
				t.Errorf("Schicht %s: das Praefix %q des Globs %q ist kein gerendertes Verzeichnis (Schreibweise?): %v", layer, prefix, g, dirs)
			}
		}
	}
	if n == 0 {
		t.Fatal("die Config traegt keinen Schicht-Glob")
	}
}

// TestCsharpHexslice_RichtungsOrdnerKlein (ADR-0097 Festlegung 1 und 2): jedes gerenderte
// Verzeichnis unter einem Ordner `Ports` heisst genau `inbound` oder `outbound` (klein), und jeder
// Port-Glob der Config (Schichten ports_inbound und ports_outbound) endet auf `/Ports/inbound/**`
// bzw. `/Ports/outbound/**`, passend zur Richtung seiner Schicht. a-check zieht das Richtungs-
// Segment nur kleingeschrieben ab; ein grosses Segment in Renderer und Config zugleich haelt
// TestArchGateConfig_CsharpGlobsMatchRenderedDirs nicht auf, dieser Test schon. Ob a-check im
// Ziel port-locality prueft, belegt allein die Stufe in full-smoke; test/mutations/765 faerbt
// diesen Test.
func TestCsharpHexslice_RichtungsOrdnerKlein(t *testing.T) {
	cfg, _ := gen.ArchGateConfig("csharp", "hexslice")
	rich := map[string]bool{"inbound": true, "outbound": true}
	n := 0
	for d := range csharpVerzeichnisse(t, genCsharpHexslice(t)) {
		parts := strings.Split(d, "/")
		for i, p := range parts {
			if p != "Ports" || i+1 >= len(parts) {
				continue
			}
			n++
			if !rich[parts[i+1]] {
				t.Errorf("Verzeichnis %s: das Richtungs-Segment unter Ports ist %q, erwartet inbound oder outbound (klein)", d, parts[i+1])
			}
		}
	}
	if n == 0 {
		t.Fatal("kein Richtungs-Verzeichnis unter Ports gerendert")
	}
	globs := archGlobs(t, cfg)
	for layer, want := range map[string]string{"ports_inbound": "inbound", "ports_outbound": "outbound"} {
		if len(globs[layer]) == 0 {
			t.Errorf("Schicht %s fehlt in der Config", layer)
		}
		for _, g := range globs[layer] {
			if !strings.HasSuffix(g, "/Ports/"+want+"/**") {
				t.Errorf("Schicht %s: Glob %q endet nicht auf /Ports/%s/**", layer, g, want)
			}
		}
	}
}

// TestCsharpHexslice_NamensraumGleichVerzeichnis (ADR-0096 Festlegung 5, Skelett-Pflicht (a)):
// jede .cs-Datei unter src/App/ ausser dem Composition Root deklariert genau den Namensraum ihres
// Verzeichnispfads ab App (`namespace App.Hexagon.Domain.Example;`). a-check bildet den Namensraum
// eines using auf einen Pfad ab; ein Namensraum ausserhalb seines Verzeichnisses entginge dem
// Arch-Gate. IDE0130 haelt dasselbe im lint der Adopter-Dateien, dieser Test fuer das Skelett.
func TestCsharpHexslice_NamensraumGleichVerzeichnis(t *testing.T) {
	dir := genCsharpHexslice(t)
	nsRe := regexp.MustCompile(`(?m)^namespace ([A-Za-z.]+);$`)
	n := 0
	for _, rel := range walkRel(t, dir) {
		if !strings.HasPrefix(rel, "src/App/") || !strings.HasSuffix(rel, ".cs") {
			continue
		}
		n++
		want := strings.ReplaceAll(filepath.ToSlash(filepath.Dir(strings.TrimPrefix(rel, "src/"))), "/", ".")
		m := nsRe.FindStringSubmatch(mustRead(t, filepath.Join(dir, filepath.FromSlash(rel))))
		if m == nil {
			t.Errorf("%s traegt keine file-scoped namespace-Zeile", rel)
		} else if m[1] != want {
			t.Errorf("%s deklariert namespace %s, das Verzeichnis verlangt %s", rel, m[1], want)
		}
	}
	if n == 0 {
		t.Fatal("keine .cs-Datei unter src/App/")
	}
}

// TestArchGateConfig_CsharpEdgesMatchSkeleton (ADR-0096 Festlegung 5, LH-FA-07): jedes
// `using App.…;` einer Produktionsdatei wird so aufgeloest, wie a-check es mit dem resolution-Block
// der Config tut (package_base abstreifen, Punkte zu "/", Root voran). Dann gilt in beide
// Richtungen: jedes using loest auf ein Verzeichnis des Skeletts und eine Schicht auf und hat
// seine Kante — darunter driven_adapters->ports_outbound, den die Implementierung des Port-
// Interfaces braucht —, und jede deklarierte Kante wird von einem using gebraucht. Ein Root, der
// nicht im package_base-Verzeichnis endet, loest kein using auf und faerbt den Test rot
// (test/mutations/750); 757 streicht die Port-Kante, 758 deklariert eine ungebrauchte. Die Schicht
// eines Verzeichnisses folgt aus einer Datei darin; ob a-check ein Verzeichnis so zuordnet, belegt
// allein der Lauf im Ziel (full-smoke).
func TestArchGateConfig_CsharpEdgesMatchSkeleton(t *testing.T) {
	cfg, _ := gen.ArchGateConfig("csharp", "hexslice")
	globs := archGlobs(t, cfg)
	declared := archEdges(t, cfg)
	_, _, roots, base := csharpConfigResolution(t, cfg)
	if len(roots) != 1 {
		t.Fatalf("roots = %v, want genau ein Root", roots)
	}
	root := roots[0]
	dir := genCsharpHexslice(t)
	dateiImVerzeichnis := map[string]string{}
	for _, rel := range walkRel(t, dir) {
		if strings.HasSuffix(rel, ".cs") {
			dateiImVerzeichnis[filepath.ToSlash(filepath.Dir(rel))] = rel
		}
	}
	usingRe := regexp.MustCompile(`(?m)^using (` + regexp.QuoteMeta(base) + `(?:\.[A-Za-z]+)+);$`)
	used := map[string]bool{}
	n := 0
	for _, rel := range walkRel(t, dir) {
		if !strings.HasPrefix(rel, "src/App/") || rel == "src/App/Program.cs" || !strings.HasSuffix(rel, ".cs") {
			continue
		}
		from, _ := mostSpecific(globs, rel)
		for _, m := range usingRe.FindAllStringSubmatch(mustRead(t, filepath.Join(dir, filepath.FromSlash(rel))), -1) {
			n++
			cand := root + "/" + strings.ReplaceAll(strings.TrimPrefix(m[1], base+"."), ".", "/")
			file, ok := dateiImVerzeichnis[cand]
			if !ok {
				t.Errorf("%s: using %s loest auf %s auf, ein Verzeichnis mit .cs-Dateien gibt es im Skelett nicht (das Gate saehe es nicht)", rel, m[1], cand)
				continue
			}
			to, _ := mostSpecific(globs, file)
			if to == "" {
				t.Errorf("%s: using %s loest auf %s auf und trifft keine Schicht (das Gate saehe es nicht)", rel, m[1], cand)
				continue
			}
			if to == from {
				continue
			}
			edge := from + "->" + to
			used[edge] = true
			if !declared[edge] {
				t.Errorf("%s verwendet %s (%s), die Config deklariert keine Kante %s", rel, m[1], to, edge)
			}
		}
	}
	if n == 0 {
		t.Fatal("kein using App.… in den Produktionsdateien des Skeletts")
	}
	for edge := range declared {
		if !used[edge] {
			t.Errorf("Kante %s ist deklariert, wird aber von keinem aufgeloesten using gebraucht", edge)
		}
	}
	if !used["driven_adapters->ports_outbound"] {
		t.Error("kein Adapter verwendet seinen Port — die Kante driven_adapters->ports_outbound ist im Skelett ungenutzt")
	}
}
