package main

import (
	"context"
	"errors"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"testing"

	"github.com/pt9912/ai-harness-init/internal/fetch"
)

// TestParseVendorBaseline haelt die Parser-Haelfte allein: aus zwei
// Positionsargumenten werden Tag und sha256, sonst ist der Aufruf ein
// Aufruf-Fehler (Exit 2) mit Usage — dieselbe Form wie
// TestParseArchiveWelleGewinntDenSchalterAusDemArgument.
func TestParseVendorBaseline(t *testing.T) {
	tests := []struct {
		name     string
		args     []string
		wantTag  string
		wantSha  string
		wantCode int
	}{
		{"tag und sha256", []string{"v6.5.0", "deadbeef"}, "v6.5.0", "deadbeef", -1},
		{"ohne Argument", []string{}, "", "", 2},
		{"nur ein Argument", []string{"v6.5.0"}, "", "", 2},
		{"drei Argumente", []string{"v6.5.0", "deadbeef", "extra"}, "", "", 2},
		{"--help", []string{"--help"}, "", "", 0},
		{"-h", []string{"-h"}, "", "", 0},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			var out, errb strings.Builder
			tag, sha, code := parseVendorBaseline(tt.args, &out, &errb)
			if code != tt.wantCode {
				t.Fatalf("Exit %d, want %d (stderr: %q)", code, tt.wantCode, errb.String())
			}
			if code == -1 && (tag != tt.wantTag || sha != tt.wantSha) {
				t.Errorf("tag=%q sha=%q, want tag=%q sha=%q", tag, sha, tt.wantTag, tt.wantSha)
			}
			if tt.wantCode == 2 && !strings.Contains(errb.String(), "vendor-baseline <tag> <sha256>") {
				t.Errorf("Usage fehlt auf stderr: %q", errb.String())
			}
			if tt.wantCode == 0 && !strings.Contains(out.String(), "vendor-baseline <tag> <sha256>") {
				t.Errorf("Usage fehlt auf stdout: %q", out.String())
			}
		})
	}
}

// TestVendorBaselineMit_Erfolg deckt die Verdrahtung: der geschriebene Baum
// liegt unter baselineDir(root) — NICHT unter root selbst —, mit dem Tag als
// Unterverzeichnis, und die Erfolgsmeldung nennt den Zielpfad.
func TestVendorBaselineMit_Erfolg(t *testing.T) {
	asset, sum := baselineFixture(t)
	root := t.TempDir()
	var out, errb strings.Builder
	code := vendorBaselineMit([]string{"v6.5.0", sum}, func() (string, error) { return root, nil }, asset, &out, &errb)
	if code != 0 {
		t.Fatalf("Exit %d, want 0 (stderr: %q)", code, errb.String())
	}
	if errb.Len() != 0 {
		t.Errorf("Exit 0, aber stderr nicht leer: %q", errb.String())
	}
	got := filepath.Join(baselineDir(root), "v6.5.0")
	if _, err := os.Stat(filepath.Join(got, "regelwerk", "README.md")); err != nil {
		t.Errorf("vendorter Baum fehlt unter %s: %v", got, err)
	}
	if !strings.Contains(out.String(), got) {
		t.Errorf("Erfolgsmeldung nennt den Zielpfad %q nicht: %q", got, out.String())
	}
}

// TestVendorBaselineMit_ErsetztVorhandenenBaum ist die Closure-Trigger-1-Probe
// (slice-200 §5): ein VORHANDENES <tag>-Verzeichnis wird durch die aus dem
// Asset entpackte Fassung ersetzt — genau der Fall, den der eigene Baum
// dieses Repos bei jedem Lauf traegt (die Baseline liegt schon vor).
func TestVendorBaselineMit_ErsetztVorhandenenBaum(t *testing.T) {
	asset, sum := baselineFixture(t)
	root := t.TempDir()
	alt := filepath.Join(baselineDir(root), "v6.5.0", "regelwerk")
	if err := os.MkdirAll(alt, 0o755); err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(filepath.Join(alt, "alt.md"), []byte("aus dem git-Baum kopiert"), 0o644); err != nil {
		t.Fatal(err)
	}
	var out, errb strings.Builder
	code := vendorBaselineMit([]string{"v6.5.0", sum}, func() (string, error) { return root, nil }, asset, &out, &errb)
	if code != 0 {
		t.Fatalf("Exit %d, want 0 (stderr: %q)", code, errb.String())
	}
	root2 := filepath.Join(baselineDir(root), "v6.5.0")
	if _, err := os.Stat(filepath.Join(root2, "regelwerk", "alt.md")); !os.IsNotExist(err) {
		t.Errorf("der alte, aus dem git-Baum kopierte Stand ueberlebt den Lauf: %v", err)
	}
	if _, err := os.Stat(filepath.Join(root2, "regelwerk", "README.md")); err != nil {
		t.Errorf("die aus dem Asset entpackte Fassung fehlt: %v", err)
	}
}

// TestVendorBaselineMit_SHA256MismatchNichtsVeraendert ist das ROT GESEHENE
// Gegenbeispiel aus slice-200 §5 Kriterium 2 (AGENTS.md §3.6): ein falscher
// sha256 bricht den Lauf VOR jedem Schreibzugriff ab, ein vorhandener Baum
// bleibt byte-gleich stehen.
func TestVendorBaselineMit_SHA256MismatchNichtsVeraendert(t *testing.T) {
	asset, _ := baselineFixture(t)
	root := t.TempDir()
	marker := filepath.Join(baselineDir(root), "v6.5.0", "regelwerk", "README.md")
	if err := os.MkdirAll(filepath.Dir(marker), 0o755); err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(marker, []byte("unveraendert"), 0o644); err != nil {
		t.Fatal(err)
	}
	wrong := strings.Repeat("0", 64)
	var out, errb strings.Builder
	code := vendorBaselineMit([]string{"v6.5.0", wrong}, func() (string, error) { return root, nil }, asset, &out, &errb)
	if code != 1 {
		t.Fatalf("Exit %d, want 1 (sha256-Mismatch)", code)
	}
	if !strings.Contains(errb.String(), "sha256") {
		t.Errorf("stderr nennt den sha256-Mismatch nicht: %q", errb.String())
	}
	got, err := os.ReadFile(marker)
	if err != nil {
		t.Fatalf("Marker verschwunden: %v", err)
	}
	if string(got) != "unveraendert" {
		t.Errorf("Marker veraendert trotz Mismatch: %q", got)
	}
	if out.Len() != 0 {
		t.Errorf("stdout nicht leer trotz Fehler: %q", out.String())
	}
}

// TestVendorBaselineMit_AndererTagBrichtAbOhneSchreibzugriff: liegt unter
// baselineDir(root) ein Verzeichnis, das NICHT dem angeforderten Tag
// entspricht (Tag-Bump), bricht der Lauf VOR jedem Netz-Zugriff und VOR jedem
// Schreibzugriff ab — kein zweites <tag>-Verzeichnis legt sich daneben
// (MR-007 Setzung 4), der vorhandene fremde Tag bleibt byte-gleich, und
// v6.5.0 wird nicht angelegt.
func TestVendorBaselineMit_AndererTagBrichtAbOhneSchreibzugriff(t *testing.T) {
	root := t.TempDir()
	alt := filepath.Join(baselineDir(root), "v6.0.0", "regelwerk")
	if err := os.MkdirAll(alt, 0o755); err != nil {
		t.Fatal(err)
	}
	marker := filepath.Join(alt, "README.md")
	if err := os.WriteFile(marker, []byte("alter tag, unveraendert"), 0o644); err != nil {
		t.Fatal(err)
	}
	angefragt := false
	fetchFn := fetch.AssetFetch(func(context.Context, string) (io.ReadCloser, error) {
		angefragt = true
		return nil, errors.New("darf nicht laufen")
	})
	var out, errb strings.Builder
	code := vendorBaselineMit([]string{"v6.5.0", "deadbeef"}, func() (string, error) { return root, nil }, fetchFn, &out, &errb)
	if code != 1 {
		t.Fatalf("Exit %d, want 1 (anderer Tag vorhanden)", code)
	}
	if angefragt {
		t.Error("Asset-Fetch lief trotz anderem Tag-Verzeichnis")
	}
	if out.Len() != 0 {
		t.Errorf("stdout nicht leer trotz Abbruch: %q", out.String())
	}
	if !strings.Contains(errb.String(), "v6.0.0") {
		t.Errorf("stderr nennt den gefundenen fremden Tag nicht: %q", errb.String())
	}
	if _, err := os.Stat(filepath.Join(baselineDir(root), "v6.5.0")); !os.IsNotExist(err) {
		t.Errorf("v6.5.0 wurde trotz Abbruch angelegt: %v", err)
	}
	got, err := os.ReadFile(marker)
	if err != nil || string(got) != "alter tag, unveraendert" {
		t.Errorf("der fremde Tag wurde veraendert: %v, %q", err, got)
	}
}

// TestVendorBaselineMit_WurzelFehler: findet der Lauf keine Repo-Wurzel, ist
// das ein Laufzeit-Fehler (Exit 1) — kein Netz-Fetch wird versucht.
func TestVendorBaselineMit_WurzelFehler(t *testing.T) {
	angefragt := false
	fetchFn := fetch.AssetFetch(func(context.Context, string) (io.ReadCloser, error) {
		angefragt = true
		return nil, errors.New("darf nicht laufen")
	})
	var out, errb strings.Builder
	code := vendorBaselineMit([]string{"v6.5.0", "deadbeef"}, func() (string, error) { return "", errors.New("keine Repo-Wurzel") }, fetchFn, &out, &errb)
	if code != 1 {
		t.Fatalf("Exit %d, want 1", code)
	}
	if angefragt {
		t.Error("Asset-Fetch lief trotz fehlender Repo-Wurzel")
	}
}

// TestVendorBaselineAufrufFehler haelt den testbaren Kern (Argumente rein,
// Exit-Code raus) fuer die Fehlerfaelle, dieselbe Form wie
// TestArchiveWelleAufrufFehler.
func TestVendorBaselineAufrufFehler(t *testing.T) {
	tests := []struct {
		name string
		args []string
	}{
		{"ohne Argument", []string{}},
		{"nur ein Argument", []string{"v6.5.0"}},
		{"drei Argumente", []string{"v6.5.0", "deadbeef", "extra"}},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			var out, errb strings.Builder
			code := vendorBaseline(tt.args, &out, &errb)
			if code != 2 {
				t.Fatalf("Exit %d, want 2 (stderr: %q)", code, errb.String())
			}
			if !strings.Contains(errb.String(), "vendor-baseline <tag> <sha256>") {
				t.Errorf("Usage fehlt auf stderr: %q", errb.String())
			}
		})
	}
}

func TestVendorBaselineHelp(t *testing.T) {
	var out, errb strings.Builder
	if code := vendorBaseline([]string{"--help"}, &out, &errb); code != 0 {
		t.Fatalf("Exit %d, want 0", code)
	}
	if !strings.Contains(out.String(), "vendor-baseline <tag> <sha256>") {
		t.Fatalf("Usage fehlt auf stdout: %q", out.String())
	}
}

// TestSubkommandoRouting_VendorBaselineFaelltNichtInDenInitPfad misst den
// main()-Zweig als PROZESS: ohne <tag>/<sha256> endet der Traeger mit Exit 2
// (Aufruf-Fehler), schreibt nichts auf stdout und laesst das Arbeitsverzeichnis
// unberuehrt — dieselbe Zusage wie
// TestSubkommandoRouting_ArchiveWelleFaelltNichtInDenInitPfad. Die Sperre in
// run() (main.go:176) beantwortet JEDES Positionsargument gleich (Exit 2,
// leeres stdout, kein Schreibzugriff) — dieser Fall unterscheidet darum NICHT,
// ob der `case` im Dispatch steht oder fehlt; das haelt
// test/unterkommando-kopplung.bats, das faerbt rot, wenn der `case` fehlt.
func TestSubkommandoRouting_VendorBaselineFaelltNichtInDenInitPfad(t *testing.T) {
	root := newRoot(t)
	stdout, err := runChild(t, root, "vendor-baseline", "")

	var ee *exec.ExitError
	if !errors.As(err, &ee) || ee.ExitCode() != 2 {
		t.Fatalf("Exit %v, want 2 (Aufruf-Fehler ohne <tag> <sha256>)", err)
	}
	if stdout != "" {
		t.Errorf("stdout nicht leer: %q", stdout)
	}
	eintraege, lerr := os.ReadDir(root)
	if lerr != nil {
		t.Fatal(lerr)
	}
	if len(eintraege) != 1 || eintraege[0].Name() != ".git" {
		namen := make([]string, 0, len(eintraege))
		for _, e := range eintraege {
			namen = append(namen, e.Name())
		}
		t.Fatalf("Arbeitsverzeichnis nach dem Lauf = %v, want nur .git — der Aufruf ist in den schreibenden Init-Pfad durchgefallen", namen)
	}
}
