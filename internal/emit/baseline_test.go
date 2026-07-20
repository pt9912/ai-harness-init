package emit_test

import (
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/pt9912/ai-harness-init/internal/emit"
)

func TestBaselineVerify_EmittedExecutable(t *testing.T) {
	dir := t.TempDir()
	if err := emit.BaselineVerify(dir, false); err != nil {
		t.Fatalf("BaselineVerify: %v", err)
	}
	dst := filepath.Join(dir, filepath.FromSlash(emit.BaselineVerifyPath))
	info, err := os.Stat(dst)
	if err != nil {
		t.Fatalf("%s fehlt: %v", emit.BaselineVerifyPath, err)
	}
	// Ein nicht ausfuehrbares Verifikations-Skript waere eine leere Zusage.
	if info.Mode().Perm()&0o111 == 0 {
		t.Errorf("Mode %v — Skript ist nicht ausfuehrbar", info.Mode().Perm())
	}
}

// TestBaselineVerify_BothAxes ist ein GROB-Waechter, kein Beleg: er prueft nur,
// dass beide Achsen ueberhaupt noch im Skript stehen.
//
// Der eigentliche Beleg liegt in `test/emitted-baseline-verify.bats`, das das
// Skript AUSFUEHRT. Warum das noetig wurde: diese Funktion war urspruenglich als
// LH-FA-09-Beleg gedacht und auf den Marker `find . -type f` gepinnt — also exakt
// auf das Implementierungsdetail, das den H1-Fehler ENTHIELT (ein eingelegter
// Symlink blieb unsichtbar, beide Achsen meldeten gruen). Ein Marker-Test kann
// konstruktionsbedingt nicht sehen, ob eine Achse ihre Eigenschaft auch erfuellt.
func TestBaselineVerify_BothAxes(t *testing.T) {
	script := string(emit.BaselineVerifyScript())
	for _, marker := range []struct{ axis, want string }{
		{"Integritaet (geaendert/geloescht)", "sha256sum -c SHA256SUMS"},
		{"Vollstaendigkeit: Ist-Bestand (Nicht-Verzeichnisse, nicht nur -type f)", "find . ! -type d"},
		{"Vollstaendigkeit: Soll-Liste", "cut -d' ' -f3- SHA256SUMS"},
		{"Vollstaendigkeit: Vergleich", `[ "$listed" != "$actual" ]`},
	} {
		if !strings.Contains(script, marker.want) {
			t.Errorf("Achse %q fehlt im emittierten Skript (Marker %q nicht gefunden)", marker.axis, marker.want)
		}
	}
}

// TestBaselineVerify_Netzlos: das Skript laeuft im Ziel in dessen Gates — ein
// Netz-Aufruf darin braeche die Offline-Zusage von LH-FA-09/LH-QA-01.
func TestBaselineVerify_Netzlos(t *testing.T) {
	script := string(emit.BaselineVerifyScript())
	for _, forbidden := range []string{"curl", "wget", "http://", "https://"} {
		if strings.Contains(script, forbidden) {
			t.Errorf("emittiertes Skript enthaelt %q — es muss netzlos laufen (LH-FA-09)", forbidden)
		}
	}
}

func TestBaselineVerify_NoOverwriteWithoutForce(t *testing.T) {
	dir := t.TempDir()
	dst := filepath.Join(dir, filepath.FromSlash(emit.BaselineVerifyPath))
	if err := os.MkdirAll(filepath.Dir(dst), 0o755); err != nil {
		t.Fatalf("vorbereiten: %v", err)
	}
	// Bewusst 0644: --force muss den Modus MITziehen, nicht nur den Inhalt
	// (Review-Befund slice-022a L2 — os.WriteFile setzt Perm nur beim Anlegen).
	if err := os.WriteFile(dst, []byte("eigenes Skript"), 0o644); err != nil {
		t.Fatalf("vorbereiten: %v", err)
	}
	err := emit.BaselineVerify(dir, false)
	if err == nil {
		t.Fatal("vorhandene Datei wurde ohne --force ueberschrieben")
	}
	if got := mustReadString(t, dst); got != "eigenes Skript" {
		t.Errorf("Inhalt veraendert: %q", got)
	}
	if err := emit.BaselineVerify(dir, true); err != nil {
		t.Fatalf("BaselineVerify mit force: %v", err)
	}
	if got := mustReadString(t, dst); got == "eigenes Skript" {
		t.Error("--force hat nicht ueberschrieben")
	}
	info, err := os.Stat(dst)
	if err != nil {
		t.Fatalf("stat: %v", err)
	}
	if info.Mode().Perm()&0o111 == 0 {
		t.Errorf("nach --force Mode %v — richtiger Inhalt in nicht ausfuehrbarer Datei (L2)", info.Mode().Perm())
	}
}

func mustReadString(t *testing.T, path string) string {
	t.Helper()
	data, err := os.ReadFile(path)
	if err != nil {
		t.Fatalf("lesen %s: %v", path, err)
	}
	return string(data)
}
