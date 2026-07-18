package main

import (
	"bytes"
	"os"
	"path/filepath"
	"strings"
	"testing"
)

// TestRun deckt die Arg-Parser-Pfade von LH-FA-01 ab (Exit-Codes + korrekter
// Stream). Der ERFOLGREICHE Emit ruft `docker run <d-check> --print-mk` und ist
// darum kein Unit-Fall (der go-test-Container hat kein Docker) — er wird in Tier 2
// (`make smoke`) end-to-end verifiziert. Der Emit-FEHLER ohne Docker steht in
// TestRun_EmitFehler (die Existenz-Pruefung greift vor dem docker-Lauf).
func TestRun(t *testing.T) {
	tests := []struct {
		name     string
		args     []string
		wantCode int
		wantOut  string // Substring, der in stdout stehen muss ("" = egal)
		wantErr  string // Substring, der in stderr stehen muss ("" = egal)
	}{
		{"fehlendes --lang -> Exit 2 + Usage stderr", []string{}, 2, "", "--lang ist erforderlich"},
		{"--help -> Exit 0 + Usage stdout", []string{"--help"}, 0, "Verwendung:", ""},
		{"-h -> Exit 0 + Usage stdout", []string{"-h"}, 0, "Verwendung:", ""},
		{"unbekanntes Flag -> Exit 2 + Usage stderr", []string{"--bogus"}, 2, "", "Fehler"},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			var out, errb bytes.Buffer
			code := run(tt.args, t.TempDir(), &out, &errb)

			if code != tt.wantCode {
				t.Errorf("Exit-Code = %d, want %d", code, tt.wantCode)
			}
			if tt.wantOut != "" && !strings.Contains(out.String(), tt.wantOut) {
				t.Errorf("stdout = %q, soll %q enthalten", out.String(), tt.wantOut)
			}
			if tt.wantErr != "" && !strings.Contains(errb.String(), tt.wantErr) {
				t.Errorf("stderr = %q, soll %q enthalten", errb.String(), tt.wantErr)
			}
			// Stream-Disziplin: Exit 0 lässt stderr leer; Fehler (Exit 2) legt
			// die Usage auf stderr und stdout bleibt leer.
			if tt.wantCode == 0 && errb.Len() > 0 {
				t.Errorf("Exit 0, aber stderr nicht leer: %q", errb.String())
			}
			if tt.wantCode == 2 && !strings.Contains(errb.String(), "Verwendung:") {
				t.Errorf("Exit 2, aber Usage fehlt auf stderr: %q", errb.String())
			}
			if tt.wantCode == 2 && out.Len() > 0 {
				t.Errorf("Exit 2, aber stdout nicht leer: %q", out.String())
			}
		})
	}
}

// TestRun_EmitFehler deckt den Emit-Fehlerpfad (Exit 1): eine vorhandene Datei
// ohne --force bricht in der Existenz-Pruefung ab — VOR dem docker-Lauf, darum
// ohne Docker testbar. Fehler auf stderr, stdout bleibt leer, kein Usage-Dump.
func TestRun_EmitFehler(t *testing.T) {
	dir := t.TempDir()
	if err := os.WriteFile(filepath.Join(dir, ".d-check.yml"), []byte("# vorhanden\n"), 0o644); err != nil {
		t.Fatalf("Setup: %v", err)
	}
	var out, errb bytes.Buffer
	code := run([]string{"--lang", "go"}, dir, &out, &errb)

	if code != 1 {
		t.Errorf("Exit-Code = %d, want 1", code)
	}
	if !strings.Contains(errb.String(), "existiert bereits") {
		t.Errorf("stderr = %q, soll den Emit-Fehler nennen", errb.String())
	}
	if out.Len() > 0 {
		t.Errorf("Exit 1, aber stdout nicht leer: %q", out.String())
	}
}
