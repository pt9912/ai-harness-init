package wire_test

import (
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/pt9912/ai-harness-init/internal/wire"
)

const goodMakefile = "GO_VERSION ?= 1.26.4\n\ngates: lint build test ## Alle Go-Gates\n"

// stageSkeleton baut ein minimales Staging-Skelett (Makefile mit gates-Target +
// eine geschachtelte Datei) und liefert den Pfad.
func stageSkeleton(t *testing.T, makefile string) string {
	t.Helper()
	dir := t.TempDir()
	write := func(rel, content string) {
		p := filepath.Join(dir, filepath.FromSlash(rel))
		if err := os.MkdirAll(filepath.Dir(p), 0o755); err != nil {
			t.Fatalf("mkdir %s: %v", rel, err)
		}
		if err := os.WriteFile(p, []byte(content), 0o644); err != nil {
			t.Fatalf("write %s: %v", rel, err)
		}
	}
	write("Makefile", makefile)
	write("go.mod", "module app\n\ngo 1.26\n")
	write("cmd/app/main.go", "package main\n\nfunc main() {}\n")
	return dir
}

// TestTargets: sortierte Rel-Pfade relativ zum Staging (fuer den Phase-3-Pre-Flight).
func TestTargets(t *testing.T) {
	got, err := wire.Targets(stageSkeleton(t, goodMakefile))
	if err != nil {
		t.Fatalf("Targets: %v", err)
	}
	want := []string{"Makefile", "cmd/app/main.go", "go.mod"}
	if strings.Join(got, ",") != strings.Join(want, ",") {
		t.Errorf("Targets = %v, want %v (sortiert, rel zum Staging)", got, want)
	}
}

// TestPlace_PlacesAndWires: die Skelett-Dateien landen im Ziel-Root, das Makefile
// bindet d-check.mk ein (include + gates: docs-check neben den Go-Gates), und das
// transiente Staging ist danach weg.
func TestPlace_PlacesAndWires(t *testing.T) {
	staging := stageSkeleton(t, goodMakefile)
	target := t.TempDir()
	if err := wire.Place(staging, target, false); err != nil {
		t.Fatalf("Place: %v", err)
	}
	for _, rel := range []string{"Makefile", "go.mod", "cmd/app/main.go"} {
		if _, err := os.Stat(filepath.Join(target, filepath.FromSlash(rel))); err != nil {
			t.Errorf("%s fehlt am Ziel-Root: %v", rel, err)
		}
	}
	mk, err := os.ReadFile(filepath.Join(target, "Makefile"))
	if err != nil {
		t.Fatalf("Makefile lesen: %v", err)
	}
	for _, want := range []string{"include d-check.mk", "gates: docs-check", "gates: lint build test"} {
		if !strings.Contains(string(mk), want) {
			t.Errorf("verdrahtetes Makefile enthaelt %q nicht:\n%s", want, mk)
		}
	}
	if _, err := os.Stat(staging); !os.IsNotExist(err) {
		t.Errorf("transientes Staging nicht aufgeraeumt: %v", err)
	}
}

// TestPlace_NoGatesTarget: ein Makefile ohne gates-Target -> Fehler; `gates:
// docs-check` haette sonst gates OHNE die Go-Gates definiert (still leere
// Verdrahtung). Und es darf nichts platziert worden sein (Vorbedingung vor dem Write).
func TestPlace_NoGatesTarget(t *testing.T) {
	staging := stageSkeleton(t, "all:\n\t@true\n")
	target := t.TempDir()
	err := wire.Place(staging, target, false)
	if err == nil {
		t.Fatal("Makefile ohne gates-Target wurde akzeptiert")
	}
	if !strings.Contains(err.Error(), "gates") {
		t.Errorf("Fehlermeldung nennt das fehlende gates-Target nicht: %v", err)
	}
	if entries, _ := os.ReadDir(target); len(entries) != 0 {
		t.Errorf("trotz Fehler wurde platziert: %v", entries)
	}
}

// TestPlace_Collision: eine vorhandene Zieldatei ohne force -> Fehler VOR jedem
// Write (kein Teil-Placement, konsistent mit slice-025).
func TestPlace_Collision(t *testing.T) {
	staging := stageSkeleton(t, goodMakefile)
	target := t.TempDir()
	if err := os.WriteFile(filepath.Join(target, "go.mod"), []byte("vorhanden"), 0o644); err != nil {
		t.Fatalf("Setup: %v", err)
	}
	err := wire.Place(staging, target, false)
	if err == nil {
		t.Fatal("vorhandene Zieldatei wurde ohne --force ueberschrieben")
	}
	if !strings.Contains(err.Error(), "existiert bereits") {
		t.Errorf("Fehlermeldung nennt die Kollision nicht: %v", err)
	}
	// Kein Teil-Placement: das Makefile darf NICHT geschrieben sein (Vorpass greift).
	if _, statErr := os.Stat(filepath.Join(target, "Makefile")); !os.IsNotExist(statErr) {
		t.Errorf("Makefile trotz Kollision platziert (Teil-Placement): %v", statErr)
	}
}
