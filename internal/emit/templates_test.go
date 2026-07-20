package emit_test

import (
	"io/fs"
	"os"
	"path/filepath"
	"strings"
	"testing"
	"testing/fstest"

	"github.com/pt9912/ai-harness-init/internal/emit"
)

// courseSet bildet den Kurs-Template-Satz nach, wie ihn die gefetchte Baseline
// traegt — inklusive der Dateien, die NICHT emittiert werden duerfen. Seit
// slice-022b liest emit.Templates aus einem fs.FS statt aus einem eingebetteten
// Baum; die Tests bleiben damit hermetisch (der reale Baum liegt unter .harness/,
// das der Docker-Build-Kontext ausschliesst).
func courseSet() fs.FS {
	hint := "> **Template-Hinweis.** Vorlage.\n\n"
	body := "# <Projektname>\n\nInhalt.\n"
	f := func(s string) *fstest.MapFile { return &fstest.MapFile{Data: []byte(s)} }
	return fstest.MapFS{
		// in scope — Singletons
		"AGENTS.template.md":                    f(hint + body),
		"spec/lastenheft.template.md":           f(hint + body),
		"spec/architecture.template.md":         f(hint + body),
		"spec/spezifikation.template.md":        f(hint + body),
		"harness/README.template.md":            f(hint + body),
		"harness/conventions.template.md":       f(hint + body),
		"docs/plan/adr/README.template.md":      f(hint + body),
		"docs/plan/carveouts/README.template.md": f(hint + body),
		"docs/plan/planning/README.template.md": f(hint + body),
		"docs/plan/planning/roadmap.template.md": f(hint + body),
		// in scope — Wiederkehrende (verbatim, Hinweis bleibt)
		"docs/plan/adr/NNNN-titel.template.md":       f(hint + body),
		"docs/plan/planning/slice.template.md":       f(hint + body),
		"docs/plan/planning/welle.template.md":       f(hint + body),
		"docs/plan/carveouts/carveout.template.md":   f(hint + body),
		"docs/reviews/review-report.template.md":     f(hint + body),
		// AUSSER Scope — jede Zeile ein eigener Grund, s. emit.inScope
		"README.md":                                    f("# Set-Index\n"),
		"project-readme.template.md":                   f(hint + body),
		".harness/skills/reviewer.template.md":         f(hint + body),
		".harness/skills/closure-note-reviewer.template.md": f(hint + body),
		".d-check.yml":                                 f("modules: [links]\n"),
		"Makefile":                                     f("all:\n\t@true\n"),
	}
}

func TestTemplates_Layout(t *testing.T) {
	dir := t.TempDir()
	if err := emit.Templates(courseSet(), dir, "X", true); err != nil {
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
	if err := emit.Templates(courseSet(), dir, name, true); err != nil {
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
// gestrippt, siehe TestTemplates_StampAndStrip). Byte-Gleichheit mit dem REALEN
// Kurs-Satz belegt seit slice-022b `make smoke` (Tier 2, echter Bootstrap) — der
// frueher hier genannte bats-Drift-Waechter ist mit dem Embed entfallen.
func TestTemplates_RecurringVerbatim(t *testing.T) {
	dir := t.TempDir()
	if err := emit.Templates(courseSet(), dir, "X", true); err != nil {
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

// TestTemplates_AusserScopeNichtEmittiert ist der Kern von slice-022b. Die
// gefetchte Quelle traegt den VOLLEN Kurs-Satz (21 Dateien); der eingebettete
// Baum war von Hand vorgefiltert (15). Diese Regel stand vorher NUR im geloeschten
// Drift-Waechter — jede Zeile hier hat einen eigenen Grund, und keiner davon ist
// "war halt nicht im Embed".
func TestTemplates_AusserScopeNichtEmittiert(t *testing.T) {
	dir := t.TempDir()
	if err := emit.Templates(courseSet(), dir, "X", true); err != nil {
		t.Fatalf("Templates: %v", err)
	}
	for _, c := range []struct{ rel, warum string }{
		{"README.md", "Set-Index des Satzes, nie ein Ziel-Artefakt"},
		{"project-readme.template.md", "Root-README ist LH-FA-05 (slice-005)"},
		{"readme.md", "Root-README auch nicht kleingeschrieben"},
		{".harness/skills/reviewer.template.md", "Durchsetzungsschicht ist LH-FA-06"},
		{".harness/skills/closure-note-reviewer.template.md", "Durchsetzungsschicht ist LH-FA-06"},
		{".d-check.yml", "das Tool autoriert seine eigene minimale Config (emit.DocGate)"},
		{"Makefile", "Ziel-Form gehoert zum Skelett-Generator (slice-023)"},
	} {
		if _, err := os.Stat(filepath.Join(dir, filepath.FromSlash(c.rel))); err == nil {
			t.Errorf("%s wurde emittiert — %s", c.rel, c.warum)
		}
	}
}

// TestTemplates_NeuesUpstreamTemplateFliesstMit ist der strukturelle Ersatz fuer
// die Vollstaendigkeits-Achse des geloeschten Drift-Waechters. Die bewachte
// "Baseline gebumpt, Embed nicht re-synct". Mit einer REGEL statt einer
// aufgezaehlten Allowlist kann die Klasse nicht mehr entstehen — dieser Test
// haelt genau das fest: ein Template, das niemand kennt, kommt trotzdem an.
func TestTemplates_NeuesUpstreamTemplateFliesstMit(t *testing.T) {
	src := courseSet().(fstest.MapFS)
	src["spec/glossar.template.md"] = &fstest.MapFile{Data: []byte("> **Template-Hinweis.** X\n\n# <Projektname>\n")}
	dir := t.TempDir()
	if err := emit.Templates(src, dir, "X", true); err != nil {
		t.Fatalf("Templates: %v", err)
	}
	if _, err := os.Stat(filepath.Join(dir, "spec", "glossar.md")); err != nil {
		t.Errorf("neu hinzugekommenes Template wurde nicht emittiert: %v", err)
	}
}

// TestTemplates_LeereQuelle: eine falsch gewurzelte oder leere Quelle darf nicht
// still nichts emittieren und Erfolg melden (LH-QA-01).
func TestTemplates_LeereQuelle(t *testing.T) {
	err := emit.Templates(fstest.MapFS{"irgendwas.txt": &fstest.MapFile{Data: []byte("x")}}, t.TempDir(), "X", true)
	if err == nil {
		t.Fatal("leere Quelle wurde als Erfolg gemeldet")
	}
	if !strings.Contains(err.Error(), "in-scope") {
		t.Errorf("Fehlermeldung benennt die Ursache nicht: %v", err)
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
	if err := emit.Templates(courseSet(), dir, "X", false); err == nil {
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
	if err := emit.Templates(courseSet(), dir, "X", true); err != nil {
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
