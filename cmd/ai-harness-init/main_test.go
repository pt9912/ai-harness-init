package main

import (
	"archive/tar"
	"bytes"
	"compress/gzip"
	"context"
	"errors"
	"io"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/pt9912/ai-harness-init/internal/fetch"
)

// goFixture liefert einen netzlosen Fetcher mit einem minimalen go-Skelett (Marker
// Makefile). Damit sind die run()-Pfade ohne echtes Netz testbar (Review-M2).
func goFixture(t *testing.T) fetch.TarballFetch {
	t.Helper()
	var buf bytes.Buffer
	gz := gzip.NewWriter(&buf)
	tw := tar.NewWriter(gz)
	for name, content := range map[string]string{
		"c-3.1.0/lab/example/go/Makefile": "m",
		"c-3.1.0/lab/example/go/go.mod":   "module x",
	} {
		hdr := &tar.Header{Name: name, Mode: 0o644, Size: int64(len(content)), Typeflag: tar.TypeReg}
		if err := tw.WriteHeader(hdr); err != nil {
			t.Fatalf("WriteHeader: %v", err)
		}
		if _, err := tw.Write([]byte(content)); err != nil {
			t.Fatalf("Write: %v", err)
		}
	}
	if err := tw.Close(); err != nil {
		t.Fatalf("tar Close: %v", err)
	}
	if err := gz.Close(); err != nil {
		t.Fatalf("gzip Close: %v", err)
	}
	data := buf.Bytes()
	return func(context.Context, string) (io.ReadCloser, error) {
		return io.NopCloser(bytes.NewReader(data)), nil
	}
}

// TestRun deckt die Arg-Parser-Pfade von LH-FA-01 ab (Exit-Codes + korrekter Stream).
// Der erfolgreiche Bootstrap ruft `docker run <d-check>` (Doc-Gate) — kein Unit-Fall;
// er wird in Tier 2 (`make smoke`) verifiziert. Diese Fälle kehren vor dem Fetch/Emit zurück.
func TestRun(t *testing.T) {
	tests := []struct {
		name     string
		args     []string
		wantCode int
		wantOut  string
		wantErr  string
	}{
		{"fehlendes --lang -> Exit 2 + Usage stderr", []string{}, 2, "", "--lang ist erforderlich"},
		{"--help -> Exit 0 + Usage stdout", []string{"--help"}, 0, "Verwendung:", ""},
		{"-h -> Exit 0 + Usage stdout", []string{"-h"}, 0, "Verwendung:", ""},
		{"unbekanntes Flag -> Exit 2 + Usage stderr", []string{"--bogus"}, 2, "", "Fehler"},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			var out, errb bytes.Buffer
			code := run(tt.args, t.TempDir(), goFixture(t), &out, &errb)

			if code != tt.wantCode {
				t.Errorf("Exit-Code = %d, want %d", code, tt.wantCode)
			}
			if tt.wantOut != "" && !strings.Contains(out.String(), tt.wantOut) {
				t.Errorf("stdout = %q, soll %q enthalten", out.String(), tt.wantOut)
			}
			if tt.wantErr != "" && !strings.Contains(errb.String(), tt.wantErr) {
				t.Errorf("stderr = %q, soll %q enthalten", errb.String(), tt.wantErr)
			}
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

// TestRun_UnknownLang: unbekannte Sprache -> Exit 2 (Fetch-first, netzlos via Fixture).
func TestRun_UnknownLang(t *testing.T) {
	var out, errb bytes.Buffer
	code := run([]string{"--lang", "rust"}, t.TempDir(), goFixture(t), &out, &errb)
	if code != 2 {
		t.Errorf("Exit-Code = %d, want 2 (unbekannte Sprache)", code)
	}
	if !strings.Contains(errb.String(), "unbekannte Sprache") {
		t.Errorf("stderr = %q, soll die unbekannte Sprache melden", errb.String())
	}
}

// TestRun_EmitFehler: der Fetch (Fixture) staged erfolgreich, dann bricht DocGate an der
// vorhandenen .d-check.yml ohne --force ab (Pre-Flight vor Docker) -> Exit 1, stdout leer.
func TestRun_EmitFehler(t *testing.T) {
	dir := t.TempDir()
	if err := os.WriteFile(filepath.Join(dir, ".d-check.yml"), []byte("# vorhanden\n"), 0o644); err != nil {
		t.Fatalf("Setup: %v", err)
	}
	var out, errb bytes.Buffer
	code := run([]string{"--lang", "go"}, dir, goFixture(t), &out, &errb)

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

// TestFetchExitCode deckt die Exit-Abbildung netzlos ab (Review-M2).
func TestFetchExitCode(t *testing.T) {
	if got := fetchExitCode(nil); got != 0 {
		t.Errorf("nil -> %d, want 0", got)
	}
	if got := fetchExitCode(&fetch.UnknownLangError{Lang: "rust"}); got != 2 {
		t.Errorf("UnknownLangError -> %d, want 2", got)
	}
	if got := fetchExitCode(errors.New("netz weg")); got != 1 {
		t.Errorf("Netz-/Extrakt-Fehler -> %d, want 1", got)
	}
}
