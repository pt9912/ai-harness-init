package emit_test

import (
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/pt9912/ai-harness-init/internal/emit"
)

func TestTemplates_Layout(t *testing.T) {
	dir := t.TempDir()
	if err := emit.Templates(dir, "X", true); err != nil {
		t.Fatalf("Templates: %v", err)
	}
	singletons := []string{
		"AGENTS.md",
		"spec/lastenheft.md", "spec/architecture.md", "spec/spezifikation.md",
		"harness/README.md", "harness/conventions.md",
		"docs/plan/adr/README.md", "docs/plan/carveouts/README.md",
		"docs/plan/planning/README.md",
		"docs/plan/planning/in-progress/roadmap.md", // Sonderfall: in-progress/, nicht flach
	}
	for _, rel := range singletons {
		if _, err := os.Stat(filepath.Join(dir, rel)); err != nil {
			t.Errorf("Singleton %s fehlt: %v", rel, err)
		}
	}
	recurring := []string{
		"docs/plan/adr/NNNN-titel.template.md",
		"docs/plan/planning/slice.template.md",
		"docs/plan/planning/welle.template.md",
		"docs/plan/carveouts/carveout.template.md",
		"docs/reviews/review-report.template.md",
	}
	for _, rel := range recurring {
		if _, err := os.Stat(filepath.Join(dir, rel)); err != nil {
			t.Errorf("Wiederkehrend %s fehlt: %v", rel, err)
		}
	}
	// Set-Index-README wird NIE emittiert; roadmap NICHT flach unter planning/.
	if _, err := os.Stat(filepath.Join(dir, "README.md")); err == nil {
		t.Error("Set-Index-README.md wurde emittiert (darf nicht)")
	}
	if _, err := os.Stat(filepath.Join(dir, "docs/plan/planning/roadmap.md")); err == nil {
		t.Error("roadmap.md liegt flach unter planning/ statt in-progress/")
	}
}

func TestTemplates_StampAndStrip(t *testing.T) {
	dir := t.TempDir()
	const name = "MeinProjekt"
	if err := emit.Templates(dir, name, true); err != nil {
		t.Fatalf("Templates: %v", err)
	}
	got, err := os.ReadFile(filepath.Join(dir, "spec/lastenheft.md"))
	if err != nil {
		t.Fatalf("lastenheft.md lesen: %v", err)
	}
	s := string(got)
	if !strings.Contains(s, name) {
		t.Errorf("Projektname nicht gestempelt:\n%s", s)
	}
	if strings.Contains(s, "<Projektname>") {
		t.Error("<Projektname>-Platzhalter blieb stehen")
	}
	if strings.Contains(s, "Template-Hinweis") {
		t.Error("Template-Hinweis-Block nicht gestrippt")
	}
}

// TestTemplates_RecurringVerbatim: wiederkehrende Templates werden verbatim
// emittiert — ihr Template-Hinweis-Block bleibt stehen (Singletons bekommen ihn
// gestrippt, siehe TestTemplates_StampAndStrip). Byte-Gleichheit mit dem vendored
// Baum prueft zusaetzlich der bats-Drift-Waechter (sieht den ganzen Baum).
func TestTemplates_RecurringVerbatim(t *testing.T) {
	dir := t.TempDir()
	if err := emit.Templates(dir, "X", true); err != nil {
		t.Fatalf("Templates: %v", err)
	}
	got, err := os.ReadFile(filepath.Join(dir, "docs/plan/adr/NNNN-titel.template.md"))
	if err != nil {
		t.Fatalf("NNNN-titel lesen: %v", err)
	}
	if !strings.Contains(string(got), "Template-Hinweis") {
		t.Error("wiederkehrendes Template transformiert (Hinweis-Block gestrippt) — nicht verbatim")
	}
}

func TestTemplates_ForceBoundary(t *testing.T) {
	dir := t.TempDir()
	if err := os.MkdirAll(filepath.Join(dir, "spec"), 0o755); err != nil {
		t.Fatalf("Setup: %v", err)
	}
	const sentinel = "# vorhanden\n"
	target := filepath.Join(dir, "spec/lastenheft.md")
	if err := os.WriteFile(target, []byte(sentinel), 0o644); err != nil {
		t.Fatalf("Setup: %v", err)
	}
	// ohne force -> Fehler, Original unveraendert, nichts geschrieben (Pre-Flight).
	if err := emit.Templates(dir, "X", false); err == nil {
		t.Fatal("ohne force: kein Fehler trotz vorhandener Datei")
	}
	before, err := os.ReadFile(target)
	if err != nil {
		t.Fatalf("lesen: %v", err)
	}
	if string(before) != sentinel {
		t.Errorf("Datei ohne force veraendert: %q", string(before))
	}
	// mit force -> ueberschrieben.
	if err := emit.Templates(dir, "X", true); err != nil {
		t.Fatalf("mit force: %v", err)
	}
	after, err := os.ReadFile(target)
	if err != nil {
		t.Fatalf("lesen: %v", err)
	}
	if string(after) == sentinel {
		t.Error("mit force: Datei nicht ueberschrieben")
	}
}

func TestStripHintBlock(t *testing.T) {
	in := "# Titel\n\n> **Template-Hinweis.** Zeile eins.\n> Zeile zwei.\n\n**Inhalt**\n"
	want := "# Titel\n\n**Inhalt**\n"
	if got := emit.StripHintBlock(in); got != want {
		t.Errorf("StripHintBlock = %q, want %q", got, want)
	}
	no := "# Titel\n\nkein Hinweis\n"
	if got := emit.StripHintBlock(no); got != no {
		t.Errorf("StripHintBlock ohne Marker veraenderte den Text: %q", got)
	}
}
