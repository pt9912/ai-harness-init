package main

import (
	"archive/tar"
	"archive/zip"
	"bytes"
	"compress/gzip"
	"context"
	"crypto/sha256"
	"encoding/hex"
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

// baselineFixture liefert ein minimales Bundle (beide Baeume) samt seinem
// sha256 — so traegt der Test denselben Pin, den run() prueft, ohne Netz.
func baselineFixture(t *testing.T) (fetch.AssetFetch, string) {
	t.Helper()
	var buf bytes.Buffer
	zw := zip.NewWriter(&buf)
	for _, e := range []struct{ name, content string }{
		{"regelwerk/README.md", "index"},
		// Zwei Root-Marker: emit.TemplateTargets (Phase-3-Pre-Flight) verlangt via
		// checkRoot mindestens zwei, damit ein einzelnes Upstream-Rename den
		// Bootstrap nicht bricht (minRootMarkers). Ein Marker liesse den Pre-Flight
		// schon an checkRoot scheitern, nicht an der zu testenden Kollision.
		{"templates/AGENTS.template.md", "agents"},
		{"templates/spec/lastenheft.template.md", "lastenheft"},
	} {
		w, err := zw.Create(e.name)
		if err != nil {
			t.Fatalf("zip Create %s: %v", e.name, err)
		}
		if _, err := w.Write([]byte(e.content)); err != nil {
			t.Fatalf("zip Write %s: %v", e.name, err)
		}
	}
	if err := zw.Close(); err != nil {
		t.Fatalf("zip Close: %v", err)
	}
	data := buf.Bytes()
	sum := sha256.Sum256(data)
	return func(context.Context, string) (io.ReadCloser, error) {
		return io.NopCloser(bytes.NewReader(data)), nil
	}, hex.EncodeToString(sum[:])
}

// testSources buendelt beide netzlosen Fixtures fuer run().
func testSources(t *testing.T) sources {
	t.Helper()
	asset, sum := baselineFixture(t)
	return sources{skeleton: goFixture(t), baseline: asset, baselineSHA: sum}
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
			code := run(tt.args, t.TempDir(), testSources(t), &out, &errb)

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
	code := run([]string{"--lang", "rust"}, t.TempDir(), testSources(t), &out, &errb)
	if code != 2 {
		t.Errorf("Exit-Code = %d, want 2 (unbekannte Sprache)", code)
	}
	if !strings.Contains(errb.String(), "unbekannte Sprache") {
		t.Errorf("stderr = %q, soll die unbekannte Sprache melden", errb.String())
	}
}

// TestRun_EmitFehler: der Fetch (Fixture) staged erfolgreich, dann faengt der
// Phase-3-Emit-Pre-Flight die vorhandene .d-check.yml ohne --force ab (vor Docker)
// -> Exit 1, stdout leer.
func TestRun_EmitFehler(t *testing.T) {
	dir := t.TempDir()
	if err := os.WriteFile(filepath.Join(dir, ".d-check.yml"), []byte("# vorhanden\n"), 0o644); err != nil {
		t.Fatalf("Setup: %v", err)
	}
	var out, errb bytes.Buffer
	code := run([]string{"--lang", "go"}, dir, testSources(t), &out, &errb)

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

// TestRun_EmitKollisionSchreibtKeinEmit ist der Kern von slice-025 und ERSETZT
// den frueheren TestRun_BaselineUndVerifierLanden: der behauptete, dass Baseline
// UND Verifier bei einem an DocGate gescheiterten Lauf bereits im Ziel liegen —
// genau der Teil-Bootstrap-Zustand, den dieser Slice VERHINDERT.
//
// Jetzt kollidiert ein TEMPLATE-Ziel (AGENTS.md). Der Phase-3-Pre-Flight faengt
// das VOR dem ersten Emit-Write: kein Verifier, kein Doc-Gate. Die gefetchte
// Baseline (Phase 2) bleibt bewusst liegen — retry-freundlich (slice-025 §6).
//
// ROT-Gegenbeispiel (AGENTS 3.6): ohne den Phase-3-Pre-Flight liefe der Lauf in
// Phase 4, DocGate riefe docker (im netzlosen Test nicht vorhanden) und der
// Fehler waere KEIN "existiert bereits" — die Assertion unten wuerde rot.
// test/mutations/12-preflight-emit.sh mutiert genau das.
func TestRun_EmitKollisionSchreibtKeinEmit(t *testing.T) {
	dir := t.TempDir()
	if err := os.WriteFile(filepath.Join(dir, "AGENTS.md"), []byte("# vorhanden\n"), 0o644); err != nil {
		t.Fatalf("Setup: %v", err)
	}
	var out, errb bytes.Buffer
	code := run([]string{"--lang", "go"}, dir, testSources(t), &out, &errb)
	if code != 1 {
		t.Fatalf("Exit-Code = %d, want 1 (Emit-Pre-Flight bricht ab)", code)
	}
	if !strings.Contains(errb.String(), "existiert bereits") {
		t.Errorf("stderr = %q, soll die Kollision als Pre-Flight-Abbruch melden", errb.String())
	}
	if out.Len() > 0 {
		t.Errorf("Exit 1, aber stdout nicht leer: %q", out.String())
	}
	// KEIN Emit-Write: der Slice sagt zu, dass bei einer Emit-Kollision KEIN
	// Emit-Schritt schreibt, nicht nur der kollidierende.
	for _, rel := range []string{filepath.Join("tools", "harness", "baseline-verify.sh"), "d-check.mk"} {
		if _, err := os.Stat(filepath.Join(dir, rel)); !errors.Is(err, os.ErrNotExist) {
			t.Errorf("%s wurde trotz Emit-Kollision geschrieben (Teil-Emit): %v", rel, err)
		}
	}
	// Die gefetchte Baseline bleibt aber liegen — Phase 2 ist retry-freundlich.
	base := filepath.Join(dir, ".harness", "baseline", fetch.DefaultTag)
	if _, err := os.Stat(filepath.Join(base, "SHA256SUMS")); err != nil {
		t.Errorf("gefetchte Baseline fehlt — Phase 2 soll retry-freundlich bestehen bleiben: %v", err)
	}
}

// TestRun_FetchKollisionSchreibtNichts belegt den Phase-1-Pre-Flight (die andere
// Halbzeit von slice-025): kollidiert ein FETCH-Ziel (die vendored Baseline),
// wird gar nichts geholt — auch das Skelett nicht.
//
// ROT-Gegenbeispiel (AGENTS 3.6): ohne Phase 1 liefe fetch.Skeleton (Phase 2)
// zuerst und legte das Skelett ab, EHE fetch.Baseline die vorhandene Baseline
// bemerkt — .harness/skeleton/ waere dann da. test/mutations/14-preflight-fetch.sh
// mutiert genau das.
func TestRun_FetchKollisionSchreibtNichts(t *testing.T) {
	dir := t.TempDir()
	base := filepath.Join(dir, ".harness", "baseline", fetch.DefaultTag)
	if err := os.MkdirAll(base, 0o755); err != nil {
		t.Fatalf("Setup: %v", err)
	}
	if err := os.WriteFile(filepath.Join(base, "vorhanden.md"), []byte("alt\n"), 0o644); err != nil {
		t.Fatalf("Setup: %v", err)
	}
	var out, errb bytes.Buffer
	code := run([]string{"--lang", "go"}, dir, testSources(t), &out, &errb)
	if code != 1 {
		t.Fatalf("Exit-Code = %d, want 1 (Fetch-Pre-Flight bricht ab)", code)
	}
	if !strings.Contains(errb.String(), "existiert bereits") {
		t.Errorf("stderr = %q, soll die Baseline-Kollision melden", errb.String())
	}
	if _, err := os.Stat(filepath.Join(dir, ".harness", "skeleton")); !errors.Is(err, os.ErrNotExist) {
		t.Errorf(".harness/skeleton wurde trotz Fetch-Kollision angelegt (Teil-Fetch): %v", err)
	}
}

// TestPreflightAbsent nagelt die Pre-Flight-LOGIK direkt fest: freie Ziele
// liefern nil, ein vorhandenes meldet einen Fehler, der Pfad UND Ausweg nennt.
func TestPreflightAbsent(t *testing.T) {
	dir := t.TempDir()
	if err := preflightAbsent(dir, []string{"a", "b/c"}); err != nil {
		t.Errorf("freie Ziele: %v, want nil", err)
	}
	if err := os.MkdirAll(filepath.Join(dir, "b"), 0o755); err != nil {
		t.Fatalf("Setup: %v", err)
	}
	if err := os.WriteFile(filepath.Join(dir, "b", "c"), []byte("x"), 0o644); err != nil {
		t.Fatalf("Setup: %v", err)
	}
	err := preflightAbsent(dir, []string{"a", "b/c"})
	if err == nil {
		t.Fatal("vorhandenes Ziel wurde nicht gemeldet")
	}
	if !strings.Contains(err.Error(), "b/c") || !strings.Contains(err.Error(), "--force") {
		t.Errorf("Meldung nennt Pfad+Ausweg nicht: %v", err)
	}
}

// TestTemplatesDir_ZeigtAufDieGefetchteQuelle koppelt die Wurzelung, die
// emit.Templates bekommt, an das, was fetch.Baseline tatsaechlich schreibt.
//
// Bis zum Review hatte sie NULL Zusicherung (Befund slice-022b F-3). Der Lauf
// bricht seit slice-025 am Phase-3-Emit-Pre-Flight ab (vorhandene .d-check.yml) —
// aber ERST nach dem Baseline-Fetch (Phase 2). Deshalb liegt die gefetchte
// templates/-Wurzel bereits im Ziel, und templatesDir muss genau dorthin zeigen.
func TestTemplatesDir_ZeigtAufDieGefetchteQuelle(t *testing.T) {
	dir := t.TempDir()
	if err := os.WriteFile(filepath.Join(dir, ".d-check.yml"), []byte("# vorhanden\n"), 0o644); err != nil {
		t.Fatalf("Setup: %v", err)
	}
	var out, errb bytes.Buffer
	if code := run([]string{"--lang", "go"}, dir, testSources(t), &out, &errb); code != 1 {
		t.Fatalf("Exit-Code = %d, want 1 (Emit-Pre-Flight bricht ab)", code)
	}
	// Die Baseline liegt jetzt im Ziel. Genau dorthin muss templatesDir zeigen —
	// und dort muss der Wurzel-Anker liegen, den emit.Templates prueft.
	src := templatesDir(dir, fetch.DefaultTag)
	if _, err := os.Stat(filepath.Join(src, "AGENTS.template.md")); err != nil {
		t.Errorf("templatesDir zeigt nicht auf die gefetchte templates/-Wurzel (%s): %v", src, err)
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
