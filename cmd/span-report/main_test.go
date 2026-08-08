package main

import (
	"os"
	"path/filepath"
	"strings"
	"testing"
)

func TestLauf_SchreibtBilanzUndGibtNullZurueck(t *testing.T) {
	t.Parallel()
	dir := t.TempDir()
	zeile := `{"ts":"2026-08-08T10:00:00Z","event":"PostToolUse","tool":"Agent","session":"s1",` +
		`"spawned_role":"planner","input_tokens":10,"output_tokens":5}`
	if err := os.WriteFile(filepath.Join(dir, "s.jsonl"), []byte(zeile+"\n"), 0o600); err != nil {
		t.Fatalf("Bestand anlegen: %v", err)
	}

	var out, errOut strings.Builder
	if code := lauf([]string{dir}, &out, &errOut); code != 0 {
		t.Fatalf("Exit = %d, erwartet 0; stderr: %s", code, errOut.String())
	}
	if !strings.Contains(out.String(), "planner") {
		t.Fatalf("Bilanz ohne Rolle:\n%s", out.String())
	}
}

// Ein leeres Verzeichnis ist kein Fehler: der Bestand kann nach `make span-clean`
// leer sein, und eine Bilanz ueber nichts ist eine gueltige Aussage.
func TestLauf_LeererBestandIstKeinFehler(t *testing.T) {
	t.Parallel()
	var out, errOut strings.Builder
	if code := lauf([]string{t.TempDir()}, &out, &errOut); code != 0 {
		t.Fatalf("Exit = %d, erwartet 0; stderr: %s", code, errOut.String())
	}
	if !strings.Contains(out.String(), "Subagenten-Laeufe") {
		t.Fatalf("auch die leere Bilanz nennt ihren Nenner; Ausgabe:\n%s", out.String())
	}
}
