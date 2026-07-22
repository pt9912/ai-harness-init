package emit_test

import (
	"os"
	"path/filepath"
	"regexp"
	"strings"
	"testing"

	"github.com/pt9912/ai-harness-init/internal/emit"
)

// TestCommands_EmitsAll: die 3 Workflow-Commands (LH-FA-08) landen im Ziel.
// CommandPaths und der reale Emit koppeln denselben Bestand (Pre-Flight == Emit).
func TestCommands_EmitsAll(t *testing.T) {
	dir := t.TempDir()
	if err := emit.Commands(dir, false); err != nil {
		t.Fatalf("Commands: %v", err)
	}
	want := []string{
		".claude/commands/implement-slice.md",
		".claude/commands/plan-welle.md",
		".claude/commands/close-welle.md",
	}
	for _, rel := range want {
		if _, err := os.Stat(filepath.Join(dir, filepath.FromSlash(rel))); err != nil {
			t.Errorf("%s nicht emittiert: %v", rel, err)
		}
	}
	got := strings.Join(emit.CommandPaths(), "\n")
	for _, w := range want {
		if !strings.Contains(got, w) {
			t.Errorf("CommandPaths fehlt %q", w)
		}
	}
}

// TestCommands_AdaptationMarker (LH-FA-02/LH-FA-08 adaptierbar): jeder Command
// trägt in seiner „Repo-lokale Adaptionen"-Sektion einen ANPASSEN-Marker — die
// repo-spezifische Stelle ist adaptierbar, nicht 1:1 ai-harness-init-hart.
func TestCommands_AdaptationMarker(t *testing.T) {
	for _, rel := range emit.CommandPaths() {
		s := string(emit.CommandFile(rel))
		if !strings.Contains(s, "ANPASSEN") {
			t.Errorf("%s trägt keinen ANPASSEN-Marker (repo-spezifische Stelle nicht adaptierbar, LH-FA-08)", rel)
		}
	}
}

// TestCommands_NoInternalLeak (LH-QA-01 / LH-FA-08 „nicht 1:1 hart"): die
// emittierten Commands tragen keine ai-harness-init-INTERNEN Referenzen, die im
// Ziel falsch wären — Sensoren, die die Emission NICHT mitliefert (`make mutate`,
// `make smoke`, `test/mutations/`), den Quell-Werkzeugnamen, oder konkrete
// ai-harness-init-Slice-Nummern (das Ziel hat eigene Slices).
func TestCommands_NoInternalLeak(t *testing.T) {
	forbidden := []string{
		"make mutate", "make smoke", "test/mutations",
		"ai-harness-init",
	}
	// Konkrete Dogfood-Slice-Nummern (im Ziel bedeutungslos) als NUMERISCHE KLASSE,
	// nicht als Literal-Aufzählung (Review-L-1): jede `slice-<Ziffern>` fällt auf. Das
	// generische Platzhalter-Muster `slice-<NN>`/`slice-<titel>` trägt keine Ziffern
	// und bleibt erlaubt.
	sliceNum := regexp.MustCompile(`slice-[0-9]{2,}`)
	for _, rel := range emit.CommandPaths() {
		s := string(emit.CommandFile(rel))
		for _, f := range forbidden {
			if strings.Contains(s, f) {
				t.Errorf("%s enthält ai-harness-init-interne Referenz %q — im Ziel tot/falsch (LH-FA-08 nicht 1:1 hart)", rel, f)
			}
		}
		if m := sliceNum.FindString(s); m != "" {
			t.Errorf("%s enthält konkrete Dogfood-Slice-Nummer %q — im Ziel bedeutungslos (LH-FA-08 nicht 1:1 hart)", rel, m)
		}
	}
}

// TestCommands_NoOverwriteWithoutForce: Kollisions-Vorpass, kein Teil-Emit.
func TestCommands_NoOverwriteWithoutForce(t *testing.T) {
	dir := t.TempDir()
	dst := filepath.Join(dir, filepath.FromSlash(".claude/commands/plan-welle.md"))
	if err := os.MkdirAll(filepath.Dir(dst), 0o755); err != nil {
		t.Fatalf("vorbereiten: %v", err)
	}
	if err := os.WriteFile(dst, []byte("eigener Command"), 0o644); err != nil {
		t.Fatalf("vorbereiten: %v", err)
	}
	if err := emit.Commands(dir, false); err == nil {
		t.Fatal("vorhandene Datei ohne --force überschrieben")
	}
	if got := mustReadString(t, dst); got != "eigener Command" {
		t.Errorf("Inhalt bei Kollision verändert: %q", got)
	}
	// Kein Teil-Emit: die anderen Commands dürfen NICHT geschrieben sein.
	if _, err := os.Stat(filepath.Join(dir, filepath.FromSlash(".claude/commands/implement-slice.md"))); err == nil {
		t.Error("Teil-Emit trotz Kollision (implement-slice.md geschrieben)")
	}
	if err := emit.Commands(dir, true); err != nil {
		t.Fatalf("Commands mit force: %v", err)
	}
	if got := mustReadString(t, dst); got == "eigener Command" {
		t.Error("--force hat nicht überschrieben")
	}
}
