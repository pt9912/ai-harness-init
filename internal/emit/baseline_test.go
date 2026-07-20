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

// TestBaselineVerify_BothAxes ist der eigentliche LH-FA-09-Beleg: das emittierte
// Skript muss BEIDE Achsen pruefen. `sha256sum -c` allein bliebe bei einer
// ZUSAETZLICH eingelegten Datei gruen (es prueft nur, was gelistet ist) — ein
// Ziel mit nur dieser Achse haette ein stilles Gruen geerbt. Geprueft wird die
// Eigenschaft, nicht die Byte-Gleichheit mit dem Dogfood-Skript: beide duerfen
// sich unabhaengig entwickeln, solange die Eigenschaft haelt.
func TestBaselineVerify_BothAxes(t *testing.T) {
	script := string(emit.BaselineVerifyScript())
	for _, marker := range []struct{ axis, want string }{
		{"Integritaet (geaendert/geloescht)", "sha256sum -c SHA256SUMS"},
		{"Vollstaendigkeit (eingelegt): Ist-Bestand einlesen", "find . -type f"},
		{"Vollstaendigkeit (eingelegt): Soll-Liste einlesen", "cut -d' ' -f3- SHA256SUMS"},
		{"Vollstaendigkeit (eingelegt): Vergleich", `[ "$listed" != "$actual" ]`},
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
	if err := os.WriteFile(dst, []byte("eigenes Skript"), 0o755); err != nil {
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
}

func mustReadString(t *testing.T, path string) string {
	t.Helper()
	data, err := os.ReadFile(path)
	if err != nil {
		t.Fatalf("lesen %s: %v", path, err)
	}
	return string(data)
}
