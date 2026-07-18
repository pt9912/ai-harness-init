package main

import (
	"bytes"
	"strings"
	"testing"
)

// TestRun deckt die LH-FA-01-Akzeptanzkriterien des Arg-Parsers ab: die
// Exit-Codes UND dass die Usage auf dem richtigen Stream landet (stdout bei
// --help, stderr bei Fehlern).
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
		{"--lang go -> Exit 0 + Stub stdout", []string{"--lang", "go"}, 0, "noch nicht implementiert", ""},
		{"--lang/--name/--force geparst -> Exit 0", []string{"--lang", "go", "--name", "demo", "--force"}, 0, "--lang=go", ""},
		{"unbekanntes Flag -> Exit 2 + Usage stderr", []string{"--bogus"}, 2, "", "Fehler"},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			var out, errb bytes.Buffer
			code := run(tt.args, &out, &errb)

			if code != tt.wantCode {
				t.Errorf("Exit-Code = %d, want %d", code, tt.wantCode)
			}
			if tt.wantOut != "" && !strings.Contains(out.String(), tt.wantOut) {
				t.Errorf("stdout = %q, soll %q enthalten", out.String(), tt.wantOut)
			}
			if tt.wantErr != "" && !strings.Contains(errb.String(), tt.wantErr) {
				t.Errorf("stderr = %q, soll %q enthalten", errb.String(), tt.wantErr)
			}
			// Stream-Disziplin: Exit 0 lässt stderr leer; jeder Fehler (Exit 2)
			// legt die Usage auf stderr.
			if tt.wantCode == 0 && errb.Len() > 0 {
				t.Errorf("Exit 0, aber stderr nicht leer: %q", errb.String())
			}
			if tt.wantCode == 2 && !strings.Contains(errb.String(), "Verwendung:") {
				t.Errorf("Exit 2, aber Usage fehlt auf stderr: %q", errb.String())
			}
			// Symmetrisch (Review-LOW-1): der Fehlerpfad lässt stdout leer — Usage
			// und Fehlermeldung gehören auf stderr, nie auf stdout.
			if tt.wantCode == 2 && out.Len() > 0 {
				t.Errorf("Exit 2, aber stdout nicht leer: %q", out.String())
			}
		})
	}
}
