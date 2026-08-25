package main

import (
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/pt9912/ai-harness-init/internal/span"
)

func TestSpanReport_SchreibtBilanzUndGibtNullZurueck(t *testing.T) {
	t.Parallel()
	dir := t.TempDir()
	zeile := `{"ts":"2026-08-08T10:00:00Z","event":"PostToolUse","tool":"Agent","session":"s1",` +
		`"spawned_role":"planner","input_tokens":10,"output_tokens":5}`
	if err := os.WriteFile(filepath.Join(dir, "s.jsonl"), []byte(zeile+"\n"), 0o600); err != nil {
		t.Fatalf("Bestand anlegen: %v", err)
	}

	var out, errOut strings.Builder
	if code := spanReport([]string{dir}, &out, &errOut); code != 0 {
		t.Fatalf("Exit = %d, erwartet 0; stderr: %s", code, errOut.String())
	}
	if !strings.Contains(out.String(), "planner") {
		t.Fatalf("Bilanz ohne Rolle:\n%s", out.String())
	}
}

// Ein leeres Verzeichnis ist kein Fehler: der Bestand kann nach `make span-clean`
// leer sein, und eine Bilanz ueber nichts ist eine gueltige Aussage.
func TestSpanReport_LeererBestandIstKeinFehler(t *testing.T) {
	t.Parallel()
	var out, errOut strings.Builder
	if code := spanReport([]string{t.TempDir()}, &out, &errOut); code != 0 {
		t.Fatalf("Exit = %d, erwartet 0; stderr: %s", code, errOut.String())
	}
	if !strings.Contains(out.String(), "Subagenten-Laeufe") {
		t.Fatalf("auch die leere Bilanz nennt ihren Nenner; Ausgabe:\n%s", out.String())
	}
}

// TestSpanDir_OhneArgumentDerAblageortDerWurzel belegt den Wechsel vom Container auf
// den Host (ADR-0022 Festlegung 2): ohne Argument liest der Bericht den Ablageort
// unter der Repo-Wurzel des Arbeitsverzeichnisses — denselben, an den das
// Schreiber-Unterkommando anhaengt —, nicht einen im Container gemounteten Pfad.
// Geprueft wird die ENDUNG, nicht der absolute Pfad: t.TempDir() liegt je nach
// Plattform hinter einem Symlink, und die Wurzel selbst ist hier nicht der Gegenstand.
func TestSpanDir_OhneArgumentDerAblageortDerWurzel(t *testing.T) {
	t.Chdir(newRoot(t))

	dir, err := spanDir(nil)
	if err != nil {
		t.Fatalf("Ablageort nicht aufloesbar: %v", err)
	}
	if !strings.HasSuffix(filepath.ToSlash(dir), "/"+span.Dir) {
		t.Fatalf("Ablageort = %q, erwartet eine Endung auf %q", dir, span.Dir)
	}
	if !filepath.IsAbs(dir) {
		t.Fatalf("Ablageort ist nicht absolut: %q", dir)
	}
}
