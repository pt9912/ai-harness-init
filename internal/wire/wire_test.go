package wire_test

import (
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/pt9912/ai-harness-init/internal/wire"
)

// goGomk ist der Inhalt eines gestagten Code-Gate-Fragments — Platzhalter fuer die
// Byte-Gleichheits-Pruefung (Place platziert verbatim). Die Recipe-Zeile ist TAB-eingerueckt.
const goGomk = "GO_VERSION ?= 1.26.4\n\n.PHONY: test\ntest:\n\t@true\n\nGATE_CHECKS += test\n"

// stageSkeleton baut ein minimales Staging-Skelett (Code-Gate-Fragment + go.mod +
// geschachtelte Datei) und liefert den Pfad. Seit slice-035 traegt das Skelett KEINE
// Root-Makefile mehr — die kommt aus dem Init-Emitter emit.Makefile.
func stageSkeleton(t *testing.T) string {
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
	write("harness/mk/go.mk", goGomk)
	write("go.mod", "module app\n\ngo 1.26\n")
	write("cmd/app/main.go", "package main\n\nfunc main() {}\n")
	return dir
}

// TestTargets: sortierte Rel-Pfade relativ zum Staging (fuer den Phase-3-Pre-Flight).
func TestTargets(t *testing.T) {
	got, err := wire.Targets(stageSkeleton(t))
	if err != nil {
		t.Fatalf("Targets: %v", err)
	}
	want := []string{"cmd/app/main.go", "go.mod", "harness/mk/go.mk"}
	if strings.Join(got, ",") != strings.Join(want, ",") {
		t.Errorf("Targets = %v, want %v (sortiert, rel zum Staging)", got, want)
	}
}

// TestPlace_PlacesVerbatim: die Skelett-Dateien landen UNVERAENDERT im Ziel-Root (reiner
// Placer seit slice-034; slice-035: keine Root-Makefile im Skelett mehr — der Aggregator
// kommt aus emit.Makefile), und das transiente Staging ist danach weg. Rot-Gegenbeispiel:
// mutierte Place den Inhalt (alter Inline-Anhang), waere go.mk nicht byte-identisch.
func TestPlace_PlacesVerbatim(t *testing.T) {
	staging := stageSkeleton(t)
	target := t.TempDir()
	if err := wire.Place(staging, target, false); err != nil {
		t.Fatalf("Place: %v", err)
	}
	for _, rel := range []string{"harness/mk/go.mk", "go.mod", "cmd/app/main.go"} {
		if _, err := os.Stat(filepath.Join(target, filepath.FromSlash(rel))); err != nil {
			t.Errorf("%s fehlt am Ziel-Root: %v", rel, err)
		}
	}
	gomk, err := os.ReadFile(filepath.Join(target, filepath.FromSlash("harness/mk/go.mk")))
	if err != nil {
		t.Fatalf("go.mk lesen: %v", err)
	}
	if string(gomk) != goGomk {
		t.Errorf("go.mk wurde beim Platzieren veraendert (Place ist kein reiner Placer mehr):\n%s", gomk)
	}
	// Place verdrahtet NICHTS mehr — die alten Inline-Anhaenge duerfen nirgends auftauchen.
	for _, forbidden := range []string{"include d-check.mk", "gates: docs-check", "bash tools/harness/record-gates.sh"} {
		if strings.Contains(string(gomk), forbidden) {
			t.Errorf("Place haengt %q an — der Inline-Anhang ist seit slice-034 weg", forbidden)
		}
	}
	// Das Skelett traegt keine Root-Makefile mehr (die kommt aus emit.Makefile).
	if _, err := os.Stat(filepath.Join(target, "Makefile")); err == nil {
		t.Error("wire platziert eine Root-Makefile — die gehoert seit slice-035 in emit.Makefile")
	}
	if _, err := os.Stat(staging); !os.IsNotExist(err) {
		t.Errorf("transientes Staging nicht aufgeraeumt: %v", err)
	}
}

// TestPlace_Collision: eine vorhandene Zieldatei ohne force -> Fehler VOR jedem Write
// (kein Teil-Placement, konsistent mit slice-025).
func TestPlace_Collision(t *testing.T) {
	staging := stageSkeleton(t)
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
	// Kein Teil-Placement: das Code-Gate-Fragment darf NICHT geschrieben sein (Vorpass greift).
	if _, statErr := os.Stat(filepath.Join(target, filepath.FromSlash("harness/mk/go.mk"))); !os.IsNotExist(statErr) {
		t.Errorf("go.mk trotz Kollision platziert (Teil-Placement): %v", statErr)
	}
}
