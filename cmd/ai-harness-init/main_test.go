package main

import (
	"archive/zip"
	"bytes"
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
	"github.com/pt9912/ai-harness-init/internal/gen"
)

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

// testSources buendelt die netzlose Baseline-Fixture fuer run(). Das Sprachskelett
// braucht keine Fixture mehr — internal/gen erzeugt es lokal (slice-023).
func testSources(t *testing.T) sources {
	t.Helper()
	asset, sum := baselineFixture(t)
	return sources{baseline: asset, baselineSHA: sum}
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

// TestRun_SprachlosKeinExit2 belegt LH-FA-01/ADR-0007: --lang ist OPTIONAL. Fehlt es,
// gibt es KEINEN Exit 2 mehr — der Bootstrap laeuft sprach-agnostisch und bricht (netzlos,
// via kollidierender .d-check.yml) erst am Phase-3-Emit-Pre-Flight ab (Exit 1). Ein Exit 2
// hier hiesse, das alte --lang-Refuse ist zurueck. Rot-Gegenbeispiel: test/mutations/41
// macht hasLang immer true -> sprachlos laeuft gen.Generate("") -> UnknownLangError -> Exit 2.
func TestRun_SprachlosKeinExit2(t *testing.T) {
	dir := t.TempDir()
	if err := os.WriteFile(filepath.Join(dir, ".d-check.yml"), []byte("# vorhanden\n"), 0o644); err != nil {
		t.Fatalf("Setup: %v", err)
	}
	var out, errb bytes.Buffer
	code := run([]string{}, dir, testSources(t), &out, &errb) // KEIN --lang
	if code == 2 {
		t.Fatalf("Exit 2 ohne --lang — das --lang-Refuse ist zurueck (soll optional sein). stderr: %q", errb.String())
	}
	if code != 1 {
		t.Fatalf("Exit-Code = %d, want 1 (sprachlos -> Phase-3-Emit-Pre-Flight-Abbruch)", code)
	}
	if !strings.Contains(errb.String(), "existiert bereits") {
		t.Errorf("stderr = %q, soll den Pre-Flight-Abbruch (Kollision) melden", errb.String())
	}
	// Sprachlos: KEIN Skelett generiert (gen/wire entfallen).
	if _, err := os.Stat(filepath.Join(dir, ".harness", "skeleton")); !errors.Is(err, os.ErrNotExist) {
		t.Errorf(".harness/skeleton trotz sprachlosem Init angelegt: %v", err)
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
// ROT-Gegenbeispiel (AGENTS 3.6): ohne Phase 1 liefe gen.Generate (Phase 2)
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

// TestRun_SkelGoVersionOverride belegt die Verdrahtung env -> generiertes Skelett:
// SKEL_GO_VERSION faedelt bis ins Dockerfile des generierten Skeletts. Der Lauf
// bricht bewusst am Phase-3-Emit-Pre-Flight ab (vorhandene AGENTS.md), aber das
// Skelett ist da (Phase 2) schon generiert.
func TestRun_SkelGoVersionOverride(t *testing.T) {
	t.Setenv("SKEL_GO_VERSION", "1.29.9")
	dir := t.TempDir()
	if err := os.WriteFile(filepath.Join(dir, "AGENTS.md"), []byte("# vorhanden\n"), 0o644); err != nil {
		t.Fatalf("Setup: %v", err)
	}
	var out, errb bytes.Buffer
	if code := run([]string{"--lang", "go"}, dir, testSources(t), &out, &errb); code != 1 {
		t.Fatalf("Exit-Code = %d, want 1 (Emit-Pre-Flight bricht ab)", code)
	}
	df, err := os.ReadFile(filepath.Join(dir, ".harness", "skeleton", "Dockerfile"))
	if err != nil {
		t.Fatalf("generiertes Dockerfile lesen: %v", err)
	}
	if !strings.Contains(string(df), "ARG GO_VERSION=1.29.9") {
		t.Errorf("SKEL_GO_VERSION=1.29.9 nicht ins generierte Dockerfile gefaedelt:\n%s", df)
	}
}

// TestRun_SkeletonKollisionSchreibtKeinEmit belegt, dass die Skelett-ROOT-Ziele
// (slice-004b) im Phase-3-Pre-Flight liegen: eine vorhandene go.mod am Ziel-Root bricht
// VOR jedem Emit-Write ab (kein Teil-Bootstrap, slice-025). go.mod ist ein REINES
// Skelett-Ziel — nur wire.Targets faengt es (die Root-Makefile kaeme seit slice-035 aus
// emit.MakefilePath, nicht aus dem Skelett; sie waere ein schwaecheres Beispiel).
//
// ROT-Gegenbeispiel (AGENTS 3.6): fehlt wire.Targets im Phase-3-Pre-Flight, prueft er die
// go.mod-Kollision nicht -> Phase 4, DocGate scheitert netzlos an docker, die Meldung ist
// KEIN "go.mod existiert bereits". test/mutations/23 mutiert das.
func TestRun_SkeletonKollisionSchreibtKeinEmit(t *testing.T) {
	dir := t.TempDir()
	if err := os.WriteFile(filepath.Join(dir, "go.mod"), []byte("module vorhanden\n"), 0o644); err != nil {
		t.Fatalf("Setup: %v", err)
	}
	var out, errb bytes.Buffer
	code := run([]string{"--lang", "go"}, dir, testSources(t), &out, &errb)
	if code != 1 {
		t.Fatalf("Exit-Code = %d, want 1 (Pre-Flight bricht an der go.mod-Kollision ab)", code)
	}
	if !strings.Contains(errb.String(), "go.mod existiert bereits") {
		t.Errorf("stderr = %q, soll die go.mod-Kollision melden", errb.String())
	}
	if _, err := os.Stat(filepath.Join(dir, "tools", "harness", "baseline-verify.sh")); !errors.Is(err, os.ErrNotExist) {
		t.Errorf("Verifier trotz Pre-Flight-Abbruch geschrieben (Teil-Emit): %v", err)
	}
}

// TestRun_ReadmeKollisionSchreibtKeinEmit belegt, dass das Root-README-Ziel
// (slice-005, LH-FA-05) im Phase-3-Pre-Flight liegt: eine vorhandene README.md am
// Ziel-Root bricht VOR jedem Emit-Write ab (kein Teil-Bootstrap, slice-025).
//
// ROT-Gegenbeispiel (AGENTS 3.6): fehlt emit.RootReadmePath in emitTargets, prueft
// der Pre-Flight die README-Kollision nicht -> Phase 4, DocGate scheitert netzlos an
// docker, die Meldung ist KEIN "README.md existiert bereits". test/mutations/25.
func TestRun_ReadmeKollisionSchreibtKeinEmit(t *testing.T) {
	dir := t.TempDir()
	if err := os.WriteFile(filepath.Join(dir, "README.md"), []byte("# vorhanden\n"), 0o644); err != nil {
		t.Fatalf("Setup: %v", err)
	}
	var out, errb bytes.Buffer
	code := run([]string{"--lang", "go"}, dir, testSources(t), &out, &errb)
	if code != 1 {
		t.Fatalf("Exit-Code = %d, want 1 (Pre-Flight bricht an der README-Kollision ab)", code)
	}
	if !strings.Contains(errb.String(), "README.md existiert bereits") {
		t.Errorf("stderr = %q, soll die README-Kollision melden", errb.String())
	}
	if _, err := os.Stat(filepath.Join(dir, "tools", "harness", "baseline-verify.sh")); !errors.Is(err, os.ErrNotExist) {
		t.Errorf("Verifier trotz Pre-Flight-Abbruch geschrieben (Teil-Emit): %v", err)
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

// TestLangExitCode deckt die Exit-Abbildung netzlos ab: unbekannte Sprache
// (gen.UnknownLangError) -> 2, sonstiger Fehler -> 1, nil -> 0.
func TestLangExitCode(t *testing.T) {
	if got := langExitCode(nil); got != 0 {
		t.Errorf("nil -> %d, want 0", got)
	}
	if got := langExitCode(&gen.UnknownLangError{Lang: "rust"}); got != 2 {
		t.Errorf("UnknownLangError -> %d, want 2", got)
	}
	if got := langExitCode(errors.New("emit weg")); got != 1 {
		t.Errorf("sonstiger Fehler -> %d, want 1", got)
	}
}

// initializedRepo legt ein minimal "gebootstrapptes" Ziel an: nur der Aggregator
// (Root-Makefile) muss existieren, damit add-lang das Fragment verdrahtet sieht
// (kein Baseline-Fetch noetig — add-lang ergaenzt nur ein Sprachmodul).
func initializedRepo(t *testing.T) string {
	t.Helper()
	dir := t.TempDir()
	if err := os.WriteFile(filepath.Join(dir, "Makefile"), []byte("include harness/mk/*.mk\n"), 0o644); err != nil {
		t.Fatalf("Aggregator anlegen: %v", err)
	}
	return dir
}

// TestRun_AddLangDropsModule (slice-037, LH-FA-04): `add-lang go apps/api` dropt das
// <pfad>-verortete Skelett + das modul-scoped Code-Gate-Fragment (Build-Kontext apps/api)
// + blocked/go und raeumt das Staging auf. Rot-Gegenbeispiel: test/mutations entfernt den
// add-lang-Dispatch -> der Init-Pfad laeuft, das Modul fehlt -> rot.
func TestRun_AddLangDropsModule(t *testing.T) {
	dir := initializedRepo(t)
	var out, errb bytes.Buffer
	if code := run([]string{"add-lang", "go", "apps/api"}, dir, testSources(t), &out, &errb); code != 0 {
		t.Fatalf("add-lang exit %d, stderr: %q", code, errb.String())
	}
	for _, rel := range []string{
		"apps/api/go.mod", "apps/api/Dockerfile", "apps/api/cmd/app/main.go", "apps/api/.golangci.yml",
		"harness/mk/apps-api.mk", "tools/harness/blocked/go",
	} {
		if _, err := os.Stat(filepath.Join(dir, filepath.FromSlash(rel))); err != nil {
			t.Errorf("%s nicht gedroppt: %v", rel, err)
		}
	}
	frag := readFile(t, filepath.Join(dir, filepath.FromSlash("harness/mk/apps-api.mk")))
	for _, want := range []string{"test-apps-api:", "--target test -t apps-api:test apps/api", "GATE_CHECKS += lint-apps-api build-apps-api test-apps-api"} {
		if !strings.Contains(frag, want) {
			t.Errorf("apps-api.mk enthaelt %q nicht:\n%s", want, frag)
		}
	}
	// wire.Place raeumt das transiente Staging auf.
	if _, err := os.Stat(filepath.Join(dir, ".harness", "skeleton")); !os.IsNotExist(err) {
		t.Errorf(".harness/skeleton nicht aufgeraeumt: %v", err)
	}
}

// TestRun_AddLangRoot: `add-lang go .` verortet am Root und liefert die UNSCOPED Fassung
// (harness/mk/go.mk, test/lint/build, docker build .) — dieselbe wie der --lang-One-Shot.
func TestRun_AddLangRoot(t *testing.T) {
	dir := initializedRepo(t)
	var out, errb bytes.Buffer
	if code := run([]string{"add-lang", "go", "."}, dir, testSources(t), &out, &errb); code != 0 {
		t.Fatalf("add-lang go . exit %d: %q", code, errb.String())
	}
	for _, rel := range []string{"go.mod", "Dockerfile", "cmd/app/main.go", "harness/mk/go.mk", "tools/harness/blocked/go"} {
		if _, err := os.Stat(filepath.Join(dir, filepath.FromSlash(rel))); err != nil {
			t.Errorf("%s nicht gedroppt (Root): %v", rel, err)
		}
	}
	if frag := readFile(t, filepath.Join(dir, filepath.FromSlash("harness/mk/go.mk"))); !strings.Contains(frag, "GATE_CHECKS += lint build test") {
		t.Errorf("Root-Fragment nicht unscoped:\n%s", frag)
	}
}

// TestRun_AddLangRepeatable (slice-037, Mono-Repo-Kern): zwei add-lang-Aufrufe (apps/api +
// apps/web) legen ZWEI Module an; das geteilte blocked/go wird beim zweiten Lauf NICHT
// clobbert und ist KEIN Fehler (skip-if-present). Rot-Gegenbeispiel: macht blocked
// refuse-if-present, bricht der zweite Lauf ab.
func TestRun_AddLangRepeatable(t *testing.T) {
	dir := initializedRepo(t)
	var out, errb bytes.Buffer
	if code := run([]string{"add-lang", "go", "apps/api"}, dir, testSources(t), &out, &errb); code != 0 {
		t.Fatalf("erstes add-lang exit %d: %q", code, errb.String())
	}
	out.Reset()
	errb.Reset()
	if code := run([]string{"add-lang", "go", "apps/web"}, dir, testSources(t), &out, &errb); code != 0 {
		t.Fatalf("zweites add-lang (Mono-Repo) exit %d: %q", code, errb.String())
	}
	for _, rel := range []string{"apps/api/go.mod", "apps/web/go.mod", "harness/mk/apps-api.mk", "harness/mk/apps-web.mk", "tools/harness/blocked/go"} {
		if _, err := os.Stat(filepath.Join(dir, filepath.FromSlash(rel))); err != nil {
			t.Errorf("%s fehlt nach zwei add-lang: %v", rel, err)
		}
	}
}

// TestRun_AddLangNoAggregator: ohne Root-Makefile (Repo nicht initialisiert) bricht
// add-lang mit Hinweis ab (Exit 1), statt ein unverdrahtetes Fragment zu droppen.
func TestRun_AddLangNoAggregator(t *testing.T) {
	var out, errb bytes.Buffer
	code := run([]string{"add-lang", "go", "apps/api"}, t.TempDir(), testSources(t), &out, &errb)
	if code != 1 {
		t.Fatalf("add-lang ohne Aggregator exit %d, want 1", code)
	}
	if !strings.Contains(errb.String(), "kein Aggregator") {
		t.Errorf("kein Aggregator-Hinweis: %q", errb.String())
	}
}

// TestRun_AddLangMissingArgs: add-lang braucht zwei Positionsargumente -> Exit 2.
func TestRun_AddLangMissingArgs(t *testing.T) {
	var out, errb bytes.Buffer
	if code := run([]string{"add-lang", "go"}, initializedRepo(t), testSources(t), &out, &errb); code != 2 {
		t.Fatalf("add-lang mit einem Arg exit %d, want 2", code)
	}
}

// TestRun_AddLangUnknownLang: eine Sprache ohne gen-Profil -> Exit 2 (fail-fast, wie Init).
func TestRun_AddLangUnknownLang(t *testing.T) {
	var out, errb bytes.Buffer
	if code := run([]string{"add-lang", "rust", "apps/api"}, initializedRepo(t), testSources(t), &out, &errb); code != 2 {
		t.Fatalf("add-lang unbekannte Sprache exit %d, want 2", code)
	}
}

func readFile(t *testing.T, path string) string {
	t.Helper()
	b, err := os.ReadFile(path)
	if err != nil {
		t.Fatalf("lesen %s: %v", path, err)
	}
	return string(b)
}
