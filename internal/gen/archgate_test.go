package gen_test

import (
	"regexp"
	"strings"
	"testing"

	"github.com/pt9912/ai-harness-init/internal/gen"
)

// genHexslice generiert das hexSlice-Go-Skelett in ein frisches Temp-Verzeichnis.
func genHexslice(t *testing.T) string {
	t.Helper()
	dir := t.TempDir()
	if err := gen.GenerateArch(dir, "go", gen.DefaultGoVersion, "hexslice"); err != nil {
		t.Fatalf("GenerateArch(go, hexslice): %v", err)
	}
	return dir
}

// archGlobs zieht die Schicht-Globs je Layer aus der Config. Bewusst ein kleiner
// zeilenweiser Parser statt einer YAML-Abhaengigkeit (LH-QA-03): die Config ist eine
// tool-eigene Konstante bekannter Form.
func archGlobs(t *testing.T, cfg string) map[string][]string {
	t.Helper()
	globRe := regexp.MustCompile(`"([^"]+)"`)
	layerRe := regexp.MustCompile(`^  ([a-z]+):$`)
	out := map[string][]string{}
	layer := ""
	inLayers := false
	for _, line := range strings.Split(cfg, "\n") {
		switch {
		case line == "layers:":
			inLayers = true
		case inLayers && line != "" && !strings.HasPrefix(line, " "):
			inLayers = false // naechster Top-Level-Schluessel beendet den Block
		case !inLayers:
			continue
		}
		if m := layerRe.FindStringSubmatch(line); m != nil {
			layer = m[1]
			continue
		}
		if layer != "" && (strings.Contains(line, "globs:") || strings.HasPrefix(strings.TrimSpace(line), "-")) {
			for _, g := range globRe.FindAllStringSubmatch(line, -1) {
				out[layer] = append(out[layer], g[1])
			}
		}
	}
	if len(out) == 0 {
		t.Fatalf("keine Schicht-Globs in der Config gefunden:\n%s", cfg)
	}
	return out
}

// TestArchGateConfig_MatchesSkeleton (slice-046, ADR-0009 Fitness-Function): die
// emittierte `.a-check.yml` deklariert GENAU die Schichten, die das generierte hexSlice-
// Skelett traegt. Drei Eigenschaften, jede fuer sich noetig:
//
//	(a) jede Produktions-Go-Datei ausserhalb des Composition Root faellt unter mindestens
//	    einen Schicht-Glob — eine ungedeckte Datei waere ein Loch im Pruefbereich;
//	(b) der SPEZIFISCHSTE (laengste) Glob bestimmt die gemeinte Schicht — die Port-Globs
//	    liegen bewusst INNERHALB der Slice (…/greet/ports/** unter …/greet/**), und genau
//	    diese Verschachtelung traegt die port-locality-Regel;
//	(c) jeder deklarierte Glob ist fuer mindestens eine reale Datei der spezifischste —
//	    ein Glob, den nie eine Datei trifft, ist der stille Rest, aus dem ein Gate ueber
//	    leerem Bereich wird (LH-QA-01).
//
// Rot-Gegenbeispiel: ein Rollen-Pfad wandert (oder ein Glob wird umgeschrieben), ohne dass
// die andere Seite mitzieht — test/mutations faehrt genau das.
func TestArchGateConfig_MatchesSkeleton(t *testing.T) {
	cfg, ok := gen.ArchGateConfig("go", "hexslice")
	if !ok {
		t.Fatal("go+hexslice traegt keine Arch-Gate-Config")
	}
	globs := archGlobs(t, cfg)
	dir := genHexslice(t)

	// want: die gemeinte Schicht je generierter Produktionsdatei — ausgeschrieben statt
	// aus der Config abgeleitet, sonst pruefte der Test die Config gegen sich selbst.
	want := map[string]string{
		"internal/hexagon/domain/example/greeting.go":                       "domain",
		"internal/hexagon/application/example/ports/greeting_repository.go": "ports",
		"internal/hexagon/application/example/greet/ports/notifier.go":      "ports",
		"internal/hexagon/application/example/greet/command.go":             "app",
		"internal/hexagon/application/example/greet/result.go":              "app",
		"internal/hexagon/application/example/greet/validator.go":           "app",
		"internal/hexagon/application/example/greet/handler.go":             "app",
		"internal/adapters/inbound/cli/example/cli.go":                      "adapters",
		"internal/adapters/outbound/memory/example/repository.go":           "adapters",
		"internal/adapters/outbound/notify/stdout.go":                       "adapters",
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

// mostSpecific liefert Schicht und Glob mit dem laengsten passenden Praefix.
func mostSpecific(globs map[string][]string, rel string) (string, string) {
	bestLayer, bestGlob := "", ""
	for layer, gs := range globs {
		for _, g := range gs {
			if matchGlob(g, rel) && len(g) > len(bestGlob) {
				bestLayer, bestGlob = layer, g
			}
		}
	}
	return bestLayer, bestGlob
}

// matchGlob prueft die eine Glob-Form, die die Config nutzt: ein literales
// Verzeichnis-Praefix gefolgt von `/**`. Bewusst eng — genau diese Form haelt die
// Vertical-Slice-Regeln von a-check scharf; eine andere Form soll hier auffallen.
func matchGlob(glob, rel string) bool {
	prefix, ok := strings.CutSuffix(glob, "/**")
	if !ok {
		return false
	}
	return strings.HasPrefix(rel, prefix+"/")
}

// TestArchGateConfig_OnlyLayered (slice-046, LH-QA-01): nur eine schichten-tragende,
// von der Sprache getragene Kombination bekommt ein Arch-Gate. `flat` traegt keinen
// Pruefbereich, cpp rendert hexslice nicht — beide bekommen keine Config, und der
// Aufrufer emittiert dann nichts.
func TestArchGateConfig_OnlyLayered(t *testing.T) {
	for _, tc := range []struct {
		lang, arch string
		want       bool
	}{
		{"go", "hexslice", true},
		{"go", "flat", false},
		{"go", "", false},
		{"cpp", "flat", false},
		{"cpp", "hexslice", false},
		{"go", "onion", false},
	} {
		if _, ok := gen.ArchGateConfig(tc.lang, tc.arch); ok != tc.want {
			t.Errorf("ArchGateConfig(%q, %q) ok = %v, want %v", tc.lang, tc.arch, ok, tc.want)
		}
	}
}

// TestArchGateConfig_CoversEveryLayeredCombo (slice-046): jede (Sprache, Architektur),
// die ein schichten-tragendes Skelett rendert, MUSS eine Config haben — sonst faellt das
// Gate bei einer kuenftigen Sprache still aus (die Emission ist an ok gekoppelt). Der
// Test leitet die Kombinationen aus dem realen Generator ab, nicht aus einer Liste.
func TestArchGateConfig_CoversEveryLayeredCombo(t *testing.T) {
	for _, lang := range gen.SupportedLangs() {
		for _, arch := range gen.SupportedArchs() {
			dir := t.TempDir()
			if err := gen.GenerateArch(dir, lang, gen.DefaultVersion(lang), arch); err != nil {
				continue // Kombination wird nicht getragen (Exit-2-Klasse) — kein Gate erwartet
			}
			layered := false
			for _, rel := range walkRel(t, dir) {
				if strings.Contains(rel, "hexagon/domain/") {
					layered = true
				}
			}
			if _, ok := gen.ArchGateConfig(lang, arch); layered && !ok {
				t.Errorf("%s+%s rendert Schichten, hat aber keine Arch-Gate-Config (Gate faellt still aus)", lang, arch)
			}
		}
	}
}

// TestArchGateConfig_ModuleRelative (slice-046): die Config ist MODUL-relativ — der
// Gate-Lauf mountet das Modul-Verzeichnis. Ein Pfad-Praefix darin waere ein Fehler
// (er traefe im gemounteten Modul nichts).
func TestArchGateConfig_ModuleRelative(t *testing.T) {
	cfg, _ := gen.ArchGateConfig("go", "hexslice")
	for _, g := range archGlobs(t, cfg)["domain"] {
		if !strings.HasPrefix(g, "internal/") {
			t.Errorf("Domain-Glob %q ist nicht modul-relativ", g)
		}
	}
}
