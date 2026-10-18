package gen_test

import (
	"errors"
	"path/filepath"
	"regexp"
	"strings"
	"testing"

	"github.com/pt9912/ai-harness-init/internal/gen"
)

// TestGenerateArch_JavaOhneHexagonal: hexagonal rendert der Java-Renderer nicht —
// Exit-2-Klasse mit der Liste der Sprache (flat, hexslice), ohne Artefakte (ADR-0094
// Festlegung 4 legt das Layout nicht fest).
func TestGenerateArch_JavaOhneHexagonal(t *testing.T) {
	dir := t.TempDir()
	err := gen.GenerateArch(dir, "java", gen.DefaultJavaVersion, "hexagonal")
	var uae *gen.UnknownArchError
	if !errors.As(err, &uae) {
		t.Fatalf("erwartete *UnknownArchError fuer java+hexagonal, got %v", err)
	}
	if strings.Join(uae.Available, ",") != "flat,hexslice" {
		t.Errorf("Available = %v, want [flat hexslice]", uae.Available)
	}
	if rels := walkRel(t, dir); len(rels) != 0 {
		t.Errorf("abgelehnte Kombination java+hexagonal hat Artefakte geschrieben: %v", rels)
	}
}

// genJavaHexslice generiert das hexSlice-Java-Skelett in ein frisches Temp-Verzeichnis.
func genJavaHexslice(t *testing.T) string {
	t.Helper()
	dir := t.TempDir()
	if err := gen.GenerateArch(dir, "java", gen.DefaultJavaVersion, "hexslice"); err != nil {
		t.Fatalf("GenerateArch(java, hexslice): %v", err)
	}
	return dir
}

// TestGenerate_JavaHexsliceProfile_FileSet (LH-FA-04, ADR-0094 Festlegung 4): --arch
// hexslice erzeugt GENAU die Rollen-Dateien unter src/main/java/app/{hexagon,adapters}
// plus Composition Root, Test und die arch-invariante Geruestung — nicht mehr, nicht weniger.
func TestGenerate_JavaHexsliceProfile_FileSet(t *testing.T) {
	got := walkRel(t, genJavaHexslice(t))
	want := []string{
		"Dockerfile", "build.gradle.kts", "config/checkstyle/checkstyle.xml", "settings.gradle.kts",
		"src/main/java/app/Main.java",
		"src/main/java/app/adapters/driven/memory/example/InMemoryRepository.java",
		"src/main/java/app/adapters/driven/notify/StdoutNotifier.java",
		"src/main/java/app/adapters/driving/cli/example/Cli.java",
		"src/main/java/app/hexagon/application/example/greet/Handler.java",
		"src/main/java/app/hexagon/application/example/greet/ports/inbound/Greet.java",
		"src/main/java/app/hexagon/application/example/greet/ports/outbound/Notifier.java",
		"src/main/java/app/hexagon/application/example/ports/outbound/GreetingRepository.java",
		"src/main/java/app/hexagon/domain/example/Greeting.java",
		"src/test/java/app/GreetTest.java",
	}
	if strings.Join(got, ",") != strings.Join(want, ",") {
		t.Errorf("java-hexSlice-Datei-Satz = %v\nwant %v", got, want)
	}
}

// TestJavaHexslice_PaketGleichVerzeichnis (ADR-0094 Festlegung 4): jede .java-Datei des
// hexSlice-Skeletts deklariert genau das Paket ihres Verzeichnisses unter src/<set>/java.
// a-check loest Importe ueber den Pfad auf; ein Paket ausserhalb seines Verzeichnisses
// entginge dem Arch-Gate. Rot-Gegenbeispiel: test/mutations/719 verschiebt das Paket der
// Domain-Datei.
func TestJavaHexslice_PaketGleichVerzeichnis(t *testing.T) {
	assertPaketGleichVerzeichnis(t, genJavaHexslice(t), "java", ".java", ";")
}

// javaConfigResolution zieht languages-Glob, mode, roots und package_base aus der Config.
// Jeder Schluessel wird einzeln und woertlich gelesen: ein verfaelschter Wert faerbt genau
// die Aussage, die er traegt.
func javaConfigResolution(t *testing.T, cfg string) (langGlob, mode string, roots []string, base string) {
	t.Helper()
	return archConfigResolution(t, cfg, "java")
}

// TestArchGateConfig_JavaResolution (ADR-0094 Festlegung 4, LH-FA-07): die Config traegt
// `languages: java: ["**/*.java"]` und `resolution: java: {mode: fixed-root, roots:
// ["src/main/java/app"], package_base: "app"}` je Schluessel woertlich; der Root endet im
// package_base-Verzeichnis, und jede gerenderte Produktionsdatei ausser dem Composition Root
// liegt unter diesem Root, der Composition Root ist der Pfad aus composition_root. Ein
// verfaelschter Schluessel faerbt den Test: test/mutations/720 (mode), 721 (roots), 722
// (package_base), 723 (languages-Glob). Dass a-check den Import im gebootstrappten Ziel
// wirklich aufloest, belegt allein die Stufe in full-smoke.
func TestArchGateConfig_JavaResolution(t *testing.T) {
	cfg, ok := gen.ArchGateConfig("java", "hexslice")
	if !ok {
		t.Fatal("java+hexslice traegt keine Arch-Gate-Config")
	}
	langGlob, mode, roots, base := javaConfigResolution(t, cfg)
	if langGlob != "**/*.java" {
		t.Errorf("languages java = %q, want **/*.java", langGlob)
	}
	if mode != "fixed-root" {
		t.Errorf("resolution java mode = %q, want fixed-root", mode)
	}
	if len(roots) != 1 || roots[0] != "src/main/java/app" {
		t.Errorf("resolution java roots = %v, want [src/main/java/app]", roots)
	}
	if base != "app" {
		t.Errorf("resolution java package_base = %q, want app", base)
	}
	if len(roots) != 1 || !strings.HasSuffix(roots[0], "/"+base) {
		t.Errorf("Root %v endet nicht im package_base-Verzeichnis %q (a-check streift package_base vor dem Root ab)", roots, base)
	}
	const mainJava = "src/main/java/app/Main.java"
	if !strings.Contains(cfg, "\ncomposition_root: [\""+mainJava+"\"]\n") {
		t.Errorf("composition_root ist nicht %s:\n%s", mainJava, cfg)
	}
	for _, rel := range walkRel(t, genJavaHexslice(t)) {
		if !strings.HasPrefix(rel, "src/main/") || rel == mainJava {
			continue
		}
		if len(roots) == 1 && !strings.HasPrefix(rel, roots[0]+"/") {
			t.Errorf("%s liegt nicht unter dem Root %s der Config (a-check loeste keinen Import dorthin auf)", rel, roots[0])
		}
	}
}

// TestArchGateConfig_JavaMatchesSkeleton (ADR-0094 Festlegung 4, LH-FA-07): jede
// Produktionsdatei ausserhalb des Composition Root faellt unter den erwarteten Schicht-Glob,
// und jeder Glob ist fuer mindestens eine Datei der spezifischste. Die Erwartung steht
// ausgeschrieben, nicht aus der Config abgeleitet.
func TestArchGateConfig_JavaMatchesSkeleton(t *testing.T) {
	cfg, ok := gen.ArchGateConfig("java", "hexslice")
	if !ok {
		t.Fatal("java+hexslice traegt keine Arch-Gate-Config")
	}
	const hex, ad = "src/main/java/app/hexagon/", "src/main/java/app/adapters/"
	want := map[string]string{
		hex + "domain/example/Greeting.java":                                 "domain",
		hex + "application/example/greet/ports/inbound/Greet.java":          "ports_inbound",
		hex + "application/example/greet/ports/outbound/Notifier.java":      "ports_outbound",
		hex + "application/example/ports/outbound/GreetingRepository.java": "ports_outbound",
		hex + "application/example/greet/Handler.java":                      "app",
		ad + "driving/cli/example/Cli.java":                                 "driving_adapters",
		ad + "driven/memory/example/InMemoryRepository.java":               "driven_adapters",
		ad + "driven/notify/StdoutNotifier.java":                           "driven_adapters",
	}
	assertGlobsMatchSkeleton(t, cfg, genJavaHexslice(t), ".java", "src/main/java/app/Main.java", want)
}

// TestArchGateConfig_JavaEdgesMatchSkeleton (ADR-0094 Festlegung 4, LH-FA-07): jeder
// `import app.…;` einer Produktionsdatei wird so aufgeloest, wie a-check es mit dem
// resolution-Block der Config tut (package_base abstreifen, Punkte zu "/", Root voran). Dann
// gilt in beide Richtungen: jeder Import loest auf eine Schicht auf und hat seine Kante —
// darunter driven_adapters->ports_outbound, den `implements` braucht —, und jede deklarierte
// Kante wird von einem Import gebraucht. Ein Root, der nicht im package_base-Verzeichnis
// endet, loest keinen Import auf und faerbt den Test rot — test/mutations/721 setzt genau
// diesen Root.
func TestArchGateConfig_JavaEdgesMatchSkeleton(t *testing.T) {
	cfg, _ := gen.ArchGateConfig("java", "hexslice")
	globs := archGlobs(t, cfg)
	declared := archEdges(t, cfg)
	_, _, roots, base := javaConfigResolution(t, cfg)
	if len(roots) != 1 {
		t.Fatalf("roots = %v, want genau ein Root", roots)
	}
	root := roots[0]
	dir := genJavaHexslice(t)
	importRe := regexp.MustCompile(`(?m)^import (` + regexp.QuoteMeta(base) + `\.[A-Za-z.]+);$`)
	used := map[string]bool{}
	n := 0
	for _, rel := range walkRel(t, dir) {
		if !strings.HasPrefix(rel, "src/main/") || rel == "src/main/java/app/Main.java" || !strings.HasSuffix(rel, ".java") {
			continue
		}
		from, _ := mostSpecific(globs, rel)
		for _, m := range importRe.FindAllStringSubmatch(mustRead(t, filepath.Join(dir, filepath.FromSlash(rel))), -1) {
			n++
			cand := root + "/" + strings.ReplaceAll(strings.TrimPrefix(m[1], base+"."), ".", "/")
			to, _ := mostSpecific(globs, cand+".java")
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
		t.Error("kein Adapter importiert seinen Port — die implements-Kante driven_adapters->ports_outbound ist im Skelett ungenutzt")
	}
}
