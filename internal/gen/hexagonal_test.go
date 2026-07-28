package gen_test

import (
	"errors"
	"os/exec"
	"path/filepath"
	"regexp"
	"sort"
	"strings"
	"testing"

	"github.com/pt9912/ai-harness-init/internal/gen"
)

// TestGenerate_GoHexagonalProfile_FileSet (slice-058, ADR-0010 Festlegung 1): --arch
// hexagonal erzeugt GENAU die Rollen-Dateien der gelebten Familien-Konvention (core /
// port / adapter{driven,driving} + Composition Root) PLUS die arch-invariante
// Bau-Gerueestung — nicht mehr, nicht weniger. Insbesondere NICHT das
// `a-check --print-config`-Geruest (internal/core, internal/ports, internal/adapters).
// Die Mutation "eine Schicht-Datei aus goRole entfernen" faerbt diesen Test rot.
func TestGenerate_GoHexagonalProfile_FileSet(t *testing.T) {
	got := walkRel(t, genGoArch(t, "hexagonal"))
	want := []string{
		".golangci.yml",
		"Dockerfile",
		"cmd/app/main.go",
		"go.mod",
		"internal/adapter/driven/memory/repository.go",
		"internal/adapter/driving/cli/cli.go",
		"internal/hexagon/core/greet.go",
		"internal/hexagon/core/greet_test.go",
		"internal/hexagon/core/greeting.go",
		"internal/hexagon/port/greeting_repository.go",
	}
	if strings.Join(got, ",") != strings.Join(want, ",") {
		t.Errorf("hexagonal-Datei-Satz = %v\nwant %v", got, want)
	}
}

// TestGenerate_GoHexagonal_Compiles ist der Renderer-Compile-Beleg (analog slice-045a):
// das gerenderte hexagonale Skelett muss uebersetzen UND seine Tests bestehen — die
// STRING-Konstanten des Generators sind sonst ungeprueft (die Repo-Gates linten sie nicht,
// sie sind nur Daten). Netzlos (nur Standardbibliothek). Ohne go-Toolchain (host-loser
// Kontext) uebersprungen; in der Docker-test-Stage laeuft er real. Den Lint-Beleg auf
// demselben Code fuehrt harness/tools/full-smoke.sh, nicht dieser Test.
func TestGenerate_GoHexagonal_Compiles(t *testing.T) {
	if _, err := exec.LookPath("go"); err != nil {
		t.Skip("go-Toolchain nicht verfuegbar")
	}
	dir := genGoArch(t, "hexagonal")
	cmd := exec.Command("go", "test", "./...")
	cmd.Dir = dir
	cmd.Env = goBuildEnv()
	if out, err := cmd.CombinedOutput(); err != nil {
		t.Fatalf("go test des hexagonalen Skeletts schlug fehl: %v\n%s", err, out)
	}
}

// TestArchGateConfig_HexagonalMatchesSkeleton (slice-058, ADR-0010 Fitness-Function):
// die emittierte `.a-check.yml` deklariert GENAU die Schichten, die das generierte
// hexagonale Skelett traegt — dieselben drei Eigenschaften wie beim hexSlice-Layout:
// keine ungedeckte Produktionsdatei, die gemeinte Schicht je Datei, und kein Glob, den
// nie eine Datei trifft (ein Gate ueber leerem Bereich, LH-QA-01).
func TestArchGateConfig_HexagonalMatchesSkeleton(t *testing.T) {
	globs := archGlobs(t, mustArchConfig(t, "go", "hexagonal"))
	dir := genGoArch(t, "hexagonal")

	// want: die gemeinte Schicht je Produktionsdatei — ausgeschrieben statt aus der Config
	// abgeleitet, sonst pruefte der Test die Config gegen sich selbst.
	want := map[string]string{
		"internal/hexagon/core/greeting.go":            "core",
		"internal/hexagon/core/greet.go":               "core",
		"internal/hexagon/port/greeting_repository.go": "ports",
		"internal/adapter/driven/memory/repository.go": "driven",
		"internal/adapter/driving/cli/cli.go":          "driving",
	}
	hits := map[string]int{}
	seen := map[string]bool{}
	for _, rel := range walkRel(t, dir) {
		if !strings.HasSuffix(rel, ".go") || strings.HasSuffix(rel, "_test.go") || strings.HasPrefix(rel, "cmd/") {
			continue // Tests (exclude) und Composition Root (composition_root) sind befreit
		}
		seen[rel] = true
		layer, glob := mostSpecific(globs, rel)
		if layer == "" {
			t.Errorf("%s faellt unter KEINE Schicht (Loch im Pruefbereich)", rel)
			continue
		}
		hits[glob]++
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
	for layer, gs := range globs {
		for _, g := range gs {
			if hits[g] == 0 {
				t.Errorf("Schicht %s: Glob %q ist fuer KEINE generierte Datei der spezifischste (Gate ueber leerem Bereich, LH-QA-01)", layer, g)
			}
		}
	}
}

// TestArchGateConfig_HexagonalRolesExplicit (slice-058, ADR-0010 Festlegung 1): JEDE
// Schicht des hexagonalen Layouts deklariert ihre Rolle explizit — die Rollen sind nicht
// dekorativ, sie schalten die KATEGORISCHEN Regeln, die keine Kante aufhebt:
//
//	- `driven`/`driving` inferieren KEINE Rolle (die Inferenz kennt nur
//	  core/ports/adapters/application/app). Ohne den Eintrag waeren beide Schichten bloss
//	  kanten-geprueft — und `lateral-adapter` (die tragende Regel dieses Layouts) fiele aus.
//	- Der Kern traegt `app`, NICHT das inferierte `domain`: eine domain-Schicht duerfte
//	  keinen Port importieren, die Use-Case muesste in den befreiten cmd/**-Bereich.
//
// Rot-Gegenbeispiel: test/mutations/99 nimmt eine role:-Zeile weg.
func TestArchGateConfig_HexagonalRolesExplicit(t *testing.T) {
	cfg := mustArchConfig(t, "go", "hexagonal")
	roles := archRoles(t, cfg)
	want := map[string]string{
		"core":    "app",
		"ports":   "port",
		"driven":  "adapter",
		"driving": "adapter",
	}
	for layer := range archGlobs(t, cfg) {
		if roles[layer] == "" {
			t.Errorf("Schicht %q deklariert KEINE Rolle — sie waere bloss kanten-geprueft (ADR-0010)", layer)
		}
	}
	for layer, role := range want {
		if roles[layer] != role {
			t.Errorf("Schicht %q traegt role %q, want %q (ADR-0010 Festlegung 1)", layer, roles[layer], role)
		}
	}
	if len(roles) != len(want) {
		t.Errorf("Rollen-Satz = %v, want genau %v", roles, want)
	}
}

// TestArchGateConfig_HexagonalEdgesMatchSkeleton (slice-058, ADR-0010 Fitness-Function):
// die Kanten-Achse in beide Richtungen — jeder reale schicht-uebergreifende Import hat
// eine Kante (sonst waere das emittierte Skelett im eigenen Gate rot), und jede Kante
// wird von einem realen Import gebraucht (eine Erlaubnis auf Vorrat lockert das Gate
// unbemerkt). Dazu die Menge selbst: sie ist von ADR-0010 FESTGELEGT, nicht Ergebnis der
// Umsetzung — insbesondere fehlt `ports->core` (waere mit `core->ports` ein Import-Zyklus)
// und `driving->driven` (lateral-adapter ist kategorisch, eine Kante hoebe sie nicht auf).
//
// Rot-Gegenbeispiel: test/mutations/100 streicht die Kante `driven->core`, die im
// `--print-config`-Geruest nur auskommentiert steht und darum wie ein Ueberschuss aussieht.
func TestArchGateConfig_HexagonalEdgesMatchSkeleton(t *testing.T) {
	cfg := mustArchConfig(t, "go", "hexagonal")
	globs := archGlobs(t, cfg)
	declared := archEdges(t, cfg)
	dir := genGoArch(t, "hexagonal")

	wantEdges := []string{"core->ports", "driven->core", "driven->ports", "driving->core"}
	got := make([]string, 0, len(declared))
	for edge := range declared {
		got = append(got, edge)
	}
	sort.Strings(got)
	if strings.Join(got, ",") != strings.Join(wantEdges, ",") {
		t.Errorf("Kanten-Menge = %v, want %v (ADR-0010 Festlegung 1)", got, wantEdges)
	}

	// Import-Pfade des Skeletts sind "app/<relpfad>" (das Modul heisst app) — der Praefix
	// faellt weg, dann liegen Datei- und Import-Pfad im selben Raum.
	importRe := regexp.MustCompile(`"app/([^"]+)"`)
	used := map[string]bool{}
	for _, rel := range walkRel(t, dir) {
		if !strings.HasSuffix(rel, ".go") || strings.HasSuffix(rel, "_test.go") || strings.HasPrefix(rel, "cmd/") {
			continue
		}
		from, _ := mostSpecific(globs, rel)
		for _, m := range importRe.FindAllStringSubmatch(readFileT(t, filepath.Join(dir, filepath.FromSlash(rel))), -1) {
			to, _ := mostSpecific(globs, m[1]+"/x.go")
			if to == "" || to == from {
				continue // ausserhalb der Schichten oder schicht-intern: keine Kante noetig
			}
			edge := from + "->" + to
			used[edge] = true
			if !declared[edge] {
				t.Errorf("%s importiert %q (%s), aber die Config deklariert keine Kante %s — das emittierte Skelett waere im eigenen Gate rot", rel, m[1], to, edge)
			}
		}
	}
	for edge := range declared {
		if !used[edge] {
			t.Errorf("Kante %s ist deklariert, wird aber von keinem Import des Skeletts gebraucht (Erlaubnis auf Vorrat)", edge)
		}
	}
}

// TestArchLayouts_Disjunkt (slice-058, ADR-0010 Festlegung 2): zwei schichten-tragende
// Layouts derselben Sprache tragen DISJUNKTE Verzeichnisnamen — keine Datei des einen
// faellt unter einen Schicht-Glob des anderen. Ohne diese Eigenschaft verschmelzen
// `hexagonal` und `hexslice` beim naechsten Aufraeumen zu EINEM Layout mit zwei
// Kanten-Mengen; die HexSlice-Regeln (Slice-Lokalitaet, laterale Trennung) haengen aber an
// literalen Verzeichnis-Praefixen und waeren dann nicht mehr bewachbar.
//
// Die Namen kommen aus den RENDERERN und den emittierten Configs, nicht aus einer
// hartkodierten Liste — sonst altert der Test beim vierten Layout still (Plan-Review F-5).
func TestArchLayouts_Disjunkt(t *testing.T) {
	for _, lang := range gen.SupportedLangs() {
		archs := layeredArchsFor(t, lang)
		if len(archs) < 2 {
			continue // ein einziges geschichtetes Layout kann mit keinem kollidieren
		}
		for _, a := range archs {
			files := walkRel(t, genArch(t, lang, a))
			for _, b := range archs {
				if a == b {
					continue
				}
				globs := archGlobs(t, mustArchConfig(t, lang, b))
				for _, rel := range files {
					if layer, glob := mostSpecific(globs, rel); layer != "" {
						t.Errorf("%s: Datei %s des Layouts %q faellt unter Schicht %q (Glob %q) des Layouts %q — die Layouts sind NICHT disjunkt (ADR-0010 Festlegung 2)", lang, rel, a, layer, glob, b)
					}
				}
			}
		}
	}
}

// TestArchGateConfig_EdgesAcyclic (slice-058, ADR-0010 Fitness-Function): die emittierte
// Kanten-Menge JEDER Arch-Gate-Config ist zyklenfrei. Ein Zyklus im Gate waere nicht bloss
// unsauber — er beschriebe ein Skelett, das die Zielsprache gar nicht uebersetzen kann
// (in Go ist ein Import-Zyklus ein Compile-Fehler). Genau daran haengt, dass ADR-0010
// `ports->core` NICHT fuehrt: zusammen mit `core->ports` waere das in EINER Kern-Schicht
// ein Zyklus.
func TestArchGateConfig_EdgesAcyclic(t *testing.T) {
	for _, lang := range gen.SupportedLangs() {
		for _, arch := range gen.SupportedArchs() {
			cfg, ok := gen.ArchGateConfig(lang, arch)
			if !ok {
				continue
			}
			if cycle := findCycle(archEdges(t, cfg)); cycle != "" {
				t.Errorf("%s+%s: die Kanten-Menge enthaelt einen Zyklus (%s) — das Skelett waere so nicht uebersetzbar", lang, arch, cycle)
			}
		}
	}
}

// TestGenerateArch_LangSpecificArchRejected (slice-058): die ZWEITE Stufe der
// Arch-Validierung — eine Architektur, die es im Achsen-Vokabular GIBT, die der Renderer
// dieser Sprache aber nicht rendert (cpp+hexagonal). Sie war zwischen slice-053 und
// slice-058 von aussen unerreichbar und ehrlich als unbewacht benannt; mit dem dritten
// Achsen-Wert ist sie es wieder. Die Fehlerliste ist die der SPRACHE (enger als das
// globale Vokabular), damit der Adopter sieht, was cpp wirklich kann.
func TestGenerateArch_LangSpecificArchRejected(t *testing.T) {
	dir := t.TempDir()
	err := gen.GenerateArch(dir, "cpp", gen.DefaultVersion("cpp"), "hexagonal")
	var uae *gen.UnknownArchError
	if !errors.As(err, &uae) {
		t.Fatalf("erwartete *UnknownArchError fuer cpp+hexagonal, got %v", err)
	}
	if strings.Join(uae.Available, ",") != "flat,hexslice" {
		t.Errorf("Available = %v, want [flat hexslice] (die Archs der SPRACHE)", uae.Available)
	}
	if rels := walkRel(t, dir); len(rels) != 0 {
		t.Errorf("abgelehnte Kombination hat Artefakte geschrieben: %v", rels)
	}
}

// mustArchConfig liefert die Arch-Gate-Config oder faellt.
func mustArchConfig(t *testing.T, lang, arch string) string {
	t.Helper()
	cfg, ok := gen.ArchGateConfig(lang, arch)
	if !ok {
		t.Fatalf("%s+%s traegt keine Arch-Gate-Config", lang, arch)
	}
	return cfg
}

// genArch generiert das Skelett fuer (lang, arch) in ein frisches Temp-Verzeichnis.
func genArch(t *testing.T, lang, arch string) string {
	t.Helper()
	dir := t.TempDir()
	if err := gen.GenerateArch(dir, lang, gen.DefaultVersion(lang), arch); err != nil {
		t.Fatalf("GenerateArch(%s, %s): %v", lang, arch, err)
	}
	return dir
}

// layeredArchsFor liefert die schichten-tragenden Architekturen von lang — abgeleitet aus
// dem realen Generator (eine Kombination mit Arch-Gate-Config), nicht aus einer Liste.
//
// GRENZE, benannt statt verschwiegen (Review F-5): das Kriterium ist die vorhandene
// Config, nicht der gerenderte Baum. Ein geschichtetes Layout OHNE Config faellt hier
// still aus dem Disjunktheits-Vergleich — es hat dann aber gar kein Arch-Gate, und genau
// diesen Zustand faengt TestArchGateConfig_CoversEveryLayeredCombo (strukturell, aus dem
// Baum). Die Luecke ist also gedeckt, nur von einem anderen Waechter; der Vergleich hier
// braucht die Globs, und die kommen aus der Config.
func layeredArchsFor(t *testing.T, lang string) []string {
	t.Helper()
	var out []string
	for _, arch := range gen.SupportedArchs() {
		if _, ok := gen.ArchGateConfig(lang, arch); ok {
			out = append(out, arch)
		}
	}
	return out
}

// archRoles zieht die deklarierte Rolle je Schicht aus der Config (zeilenweiser Parser wie
// archGlobs, LH-QA-03: keine YAML-Abhaengigkeit fuer eine tool-eigene Konstante bekannter
// Form). Eine Schicht OHNE `role:`-Zeile taucht im Ergebnis NICHT auf — genau das ist der
// Fall, den TestArchGateConfig_HexagonalRolesExplicit fangen soll.
func archRoles(t *testing.T, cfg string) map[string]string {
	t.Helper()
	layerRe := regexp.MustCompile(`^  ([a-z]+):$`)
	roleRe := regexp.MustCompile(`^    role: ([a-z]+)$`)
	out := map[string]string{}
	layer := ""
	inLayers := false
	for _, line := range strings.Split(cfg, "\n") {
		switch {
		case line == "layers:":
			inLayers = true
			continue
		case inLayers && line != "" && !strings.HasPrefix(line, " "):
			inLayers = false // naechster Top-Level-Schluessel beendet den Block
		}
		if !inLayers {
			continue
		}
		if m := layerRe.FindStringSubmatch(line); m != nil {
			layer = m[1]
			continue
		}
		if m := roleRe.FindStringSubmatch(line); m != nil && layer != "" {
			out[layer] = m[1]
		}
	}
	return out
}

// findCycle sucht einen gerichteten Zyklus in der Kanten-Menge ("from->to") und liefert
// ihn als lesbaren Pfad, sonst "". Tiefensuche mit drei Farben (weiss/grau/schwarz).
func findCycle(edges map[string]bool) string {
	adj := map[string][]string{}
	for edge := range edges {
		parts := strings.SplitN(edge, "->", 2)
		adj[parts[0]] = append(adj[parts[0]], parts[1])
	}
	for _, targets := range adj {
		sort.Strings(targets) // deterministische Meldung
	}
	state := map[string]int{} // 0 weiss, 1 grau (im Stack), 2 schwarz
	var walk func(node string, path []string) string
	walk = func(node string, path []string) string {
		state[node] = 1
		path = append(path, node)
		for _, next := range adj[node] {
			switch state[next] {
			case 1:
				return strings.Join(append(path, next), "->")
			case 0:
				if cycle := walk(next, path); cycle != "" {
					return cycle
				}
			}
		}
		state[node] = 2
		return ""
	}
	nodes := make([]string, 0, len(adj))
	for node := range adj {
		nodes = append(nodes, node)
	}
	sort.Strings(nodes)
	for _, node := range nodes {
		if state[node] == 0 {
			if cycle := walk(node, nil); cycle != "" {
				return cycle
			}
		}
	}
	return ""
}
