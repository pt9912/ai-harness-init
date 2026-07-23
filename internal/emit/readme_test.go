package emit_test

import (
	"io/fs"
	"os"
	"path/filepath"
	"regexp"
	"strings"
	"testing"
	"testing/fstest"

	"github.com/pt9912/ai-harness-init/internal/emit"
)

// projectReadmeSet bildet project-readme.template.md nach, wie der reale Kurs-Satz
// sie traegt: Template-Hinweis-Block MIT externem Kurs-URL (muss gestrippt werden),
// <Projektname>-Platzhalter und ein Pointer-/Trust-Abschnitt, dessen Links auf
// co-emittierte Singletons (AGENTS.md/harness/README.md/spec/lastenheft.md) zeigen —
// NICHT auf noch fehlende Ziele. Dediziert statt courseSet(), damit der reale
// Fixture-Bestand (test/courseset-fixture.bats) unberuehrt bleibt.
//
// Die TREUE dieser Link-Menge zum realen Template deckt Tier 2 (`make smoke` faehrt
// docs-check ueber die REAL emittierte README) — dieser Tier-1-Test belegt, dass die
// Emit-Transformation (Strip + Stempel) die Gate-Sicherheit erhaelt, nicht dass die
// Kurs-Vorlage sie hat.
func projectReadmeSet() fs.FS {
	return fstest.MapFS{
		"project-readme.template.md": &fstest.MapFile{Data: []byte(
			"> **Template-Hinweis.** Kopiere nach README.md, ersetze <Platzhalter>.\n" +
				"> Hintergrund: [Kurs Modul 2](https://example.com/modul-02.md).\n\n" +
				"# <Projektname>\n\n" +
				"## Was macht es vertrauenswuerdig?\n\n" +
				"- **Prozess:** [`AGENTS.md`](AGENTS.md), [`harness/README.md`](harness/README.md).\n" +
				"- **Vertraege:** [`spec/lastenheft.md`](spec/lastenheft.md).\n")},
	}
}

// TestRootReadme_StampStrip: die Root-README entsteht aus project-readme.template.md
// mit <Projektname> gestempelt und dem Template-Hinweis-Block (samt externem
// Kurs-URL) gestrippt — sie ist ein echtes Repo-README, keine Vorlage mehr.
func TestRootReadme_StampStrip(t *testing.T) {
	dir := t.TempDir()
	const name = "MeinProjekt"
	if err := emit.RootReadme(projectReadmeSet(), dir, name); err != nil {
		t.Fatalf("RootReadme: %v", err)
	}
	got, err := os.ReadFile(filepath.Join(dir, "README.md"))
	if err != nil {
		t.Fatalf("README.md lesen: %v", err)
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
	if strings.Contains(s, "https://") {
		t.Error("externer Kurs-URL (im Hinweis-Block) nicht mitgestrippt")
	}
}

// TestRootReadme_LinksGateSicher belegt DoD-2/LH-QA-01: die emittierte README
// verlinkt KEIN noch fehlendes Ziel. Nach vollem Emit (Templates + RootReadme in
// denselben Ziel-Root) muss jeder lokale Markdown-Link der README auf eine real
// existierende Datei zeigen — sonst braeche docs-check im frischen Repo.
func TestRootReadme_LinksGateSicher(t *testing.T) {
	dir := t.TempDir()
	if err := emit.Templates(courseSet(), dir, "X"); err != nil {
		t.Fatalf("Templates: %v", err)
	}
	if err := emit.RootReadme(projectReadmeSet(), dir, "X"); err != nil {
		t.Fatalf("RootReadme: %v", err)
	}
	readme, err := os.ReadFile(filepath.Join(dir, emit.RootReadmePath))
	if err != nil {
		t.Fatalf("README.md lesen: %v", err)
	}
	// Lokale Markdown-Link-Ziele: [text](ziel), ohne Schema/Anker.
	linkRe := regexp.MustCompile(`\]\(([^)]+)\)`)
	checked := 0
	for _, m := range linkRe.FindAllStringSubmatch(string(readme), -1) {
		target := m[1]
		if strings.Contains(target, "://") || strings.HasPrefix(target, "#") || strings.HasPrefix(target, "mailto:") {
			continue // externer/Anker-Link, kein lokales Ziel
		}
		checked++
		if _, err := os.Stat(filepath.Join(dir, filepath.FromSlash(target))); err != nil {
			t.Errorf("README verlinkt ein fehlendes Ziel %q (braeche docs-check im frischen Repo): %v", target, err)
		}
	}
	// Ein Test ohne geprueften Link waere wirkungslos (Zusage vs. Abdeckung).
	if checked == 0 {
		t.Fatal("kein lokaler Link geprueft — Fixture ohne Pointer-Abschnitt?")
	}
}

// TestRootReadme_SkipIfPresent (slice-038): README.md ist Adopter-Boden (ADR-0007
// skip-if-present) — ein vorhandenes (adopter-gewachsenes) README ueberlebt einen
// Re-Lauf UNBERUEHRT. Kein Fehler, kein Clobber.
func TestRootReadme_SkipIfPresent(t *testing.T) {
	dir := t.TempDir()
	const sentinel = "# adopter-gewachsen\n"
	target := filepath.Join(dir, emit.RootReadmePath)
	if err := os.WriteFile(target, []byte(sentinel), 0o644); err != nil {
		t.Fatalf("Setup: %v", err)
	}
	if err := emit.RootReadme(projectReadmeSet(), dir, "X"); err != nil {
		t.Fatalf("RootReadme (skip-if-present darf nicht fehlschlagen): %v", err)
	}
	after, err := os.ReadFile(target)
	if err != nil {
		t.Fatalf("lesen: %v", err)
	}
	if string(after) != sentinel {
		t.Errorf("vorhandenes README clobbert (skip-if-present verletzt): %q", string(after))
	}
}
