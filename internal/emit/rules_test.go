package emit_test

import (
	"io/fs"
	"os"
	"path/filepath"
	"testing"

	"github.com/pt9912/ai-harness-init/internal/emit"
	"github.com/pt9912/ai-harness-init/internal/fetch"
)

// erwarteteZielpfade haelt die drei Zielpfad-Formen als LITERAL des Tests — die
// Zielpfad-Entscheidung ist ein Werkzeug-Beschluss (§1 des Slice-Plans), nicht ein
// Wert, den die Emission selbst liefern darf: haette der Waechter seine Erwartung aus
// derselben Quelle wie die Emission, bliebe eine verschobene Ziel-Form still gruen
// (gemessen an der Quelle in der Rot-Belegung, Bericht des Laufs).
func erwarteteZielpfade() map[string]string {
	return map[string]string{
		"AGENTS.md":           "../../AGENTS.md",
		"harness-README.md":   "../../harness/README.md",
		"regelwerk-README.md": "../../.harness/baseline/" + fetch.DefaultTag + "/regelwerk/README.md",
	}
}

// pruefeRulesPointer haelt je der drei Pointer den Symlink-Modus und den Readlink-Wert
// byte-gleich gegen den literalen Zielpfad — dieselbe Lesestelle wie
// internal/archive/scan.go lies(): ein Ziel, hinter dem kein Pointer steht (fehlender
// Eintrag, regular file), faellt hier rot. Ein Byte-Vergleich "Pointer-Text" gibt es
// nicht — ein Symlink hat keinen Text, sein git-Blob ist sein Zielpfad.
func pruefeRulesPointer(t *testing.T, targetDir string, ziele map[string]string) {
	t.Helper()
	for name, ziel := range ziele {
		rel := filepath.Join(targetDir, ".claude", "rules", name)
		st, err := os.Lstat(rel)
		if err != nil {
			t.Errorf("%s: Pointer nicht aufloesbar (%v) — der Emit hat ihn nicht angelegt", rel, err)
			continue
		}
		if st.Mode()&fs.ModeSymlink == 0 {
			t.Errorf("%s: kein Symlink (Modus %s) — statt des Pointers steht ein Eintrag anderer Klasse", rel, st.Mode())
			continue
		}
		steht, err := os.Readlink(rel)
		if err != nil {
			t.Errorf("%s: Zielpfad nicht lesbar (%v)", rel, err)
			continue
		}
		if steht != ziel {
			t.Errorf("%s: Zielpfad weicht ab — steht %q, erwartet %q", rel, steht, ziel)
		}
	}
}

// TestRules_PointerJeZiel misst die Emission ueber dem Ziel-Baum: nach dem Lauf steht je
// exaktem Name unter .claude/rules/ ein Symlink mit dem erwarteten literalen Zielpfad,
// der Tag im Baseline-Zielpfad aus fetch.DefaultTag (DoD 1 und 2 des Slices
// slice-rules-pointer-emission-v1, MR-035/LH-FA-01). Die Menge misst
// emit.PointerZiele gegen die literalen Erwartung beidseitig — ein viertes oder
// fehlendes Element auf nur einer Seite faellt. Rot faellt der Waechter, wenn der Emit
// einen Pointer nicht anlegt (Lstat), statt eines Pointers einen Eintrag anderer Klasse
// hinterlaesst (Modus-Pruefung) oder einen anderen Zielpfad schreibt (byte-gleich).
func TestRules_PointerJeZiel(t *testing.T) {
	targetDir := t.TempDir()
	if err := emit.Rules(targetDir, fetch.DefaultTag); err != nil {
		t.Fatalf("Rules: %v", err)
	}
	ziele := emit.PointerZiele(fetch.DefaultTag)
	if len(ziele) != len(erwarteteZielpfade()) {
		t.Errorf("Pointer-Menge weicht ab: Emission fuehrt %d Namen, Erwartung %d", len(ziele), len(erwarteteZielpfade()))
	}
	for name := range erwarteteZielpfade() {
		if _, inEmission := ziele[name]; !inEmission {
			t.Errorf("%s: in der Erwartung, aber die Emission fuehrt ihn nicht", name)
		}
	}
	for name := range ziele {
		if _, inErwartung := erwarteteZielpfade()[name]; !inErwartung {
			t.Errorf("%s: von der Emission emittiert, ohne erwarteten Zielpfad", name)
		}
	}
	pruefeRulesPointer(t, targetDir, erwarteteZielpfade())
}

// TestRules_RegularFileBleibtUnberuehrt misst die Grenze gegen fremden Wortlaut: liegt
// am exakten Name eine regular file, bleibt sie byte-gleich stehen und der Lauf endet
// ohne Fehler — der Emit ueberschreibt Adopter-Boden nicht (MR-035 Setzung 5).
func TestRules_RegularFileBleibtUnberuehrt(t *testing.T) {
	targetDir := t.TempDir()
	rel := filepath.Join(targetDir, ".claude", "rules", "AGENTS.md")
	if err := os.MkdirAll(filepath.Dir(rel), 0o755); err != nil {
		t.Fatalf("MkdirAll: %v", err)
	}
	fremd := []byte("Adopter-Wortlaut\n")
	if err := os.WriteFile(rel, fremd, 0o644); err != nil {
		t.Fatalf("WriteFile: %v", err)
	}
	if err := emit.Rules(targetDir, fetch.DefaultTag); err != nil {
		t.Fatalf("Rules: %v", err)
	}
	steht, err := os.ReadFile(rel)
	if err != nil {
		t.Fatalf("ReadFile: %v", err)
	}
	if string(steht) != string(fremd) {
		t.Errorf("regular file wurde veraendert: steht %q, gelegt %q", steht, fremd)
	}
}

// TestRules_AndererPointerZielWirdUmgesetzt misst die Pointer-Reparatur: ein bestehender
// Pointer mit anderem Zielpfad (der Stand nach einem Baseline-Sprung) wird auf die
// aktuelle Fassung umgesetzt — der Re-Lauf heilt die tote Adresse.
func TestRules_AndererPointerZielWirdUmgesetzt(t *testing.T) {
	targetDir := t.TempDir()
	rel := filepath.Join(targetDir, ".claude", "rules", "regelwerk-README.md")
	if err := os.MkdirAll(filepath.Dir(rel), 0o755); err != nil {
		t.Fatalf("MkdirAll: %v", err)
	}
	if err := os.Symlink("../../.harness/baseline/v6.0.0/regelwerk/README.md", rel); err != nil {
		t.Fatalf("Symlink: %v", err)
	}
	if err := emit.Rules(targetDir, fetch.DefaultTag); err != nil {
		t.Fatalf("Rules: %v", err)
	}
	steht, err := os.Readlink(rel)
	if err != nil {
		t.Fatalf("Readlink: %v", err)
	}
	erwartet := "../../.harness/baseline/" + fetch.DefaultTag + "/regelwerk/README.md"
	if steht != erwartet {
		t.Errorf("Pointer nicht umgesetzt: steht %q, erwartet %q", steht, erwartet)
	}
}

// TestRules_TagKommtAusDemAufruf haelt den Baseline-Zielpfad an die eine Pin-Quelle: der
// Tag steht nicht hart in der Emission — ein Aufruf mit anderem Tag loest dessen
// Zielpfad. Eine gebackene zweite Tag-Quelle neben fetch.DefaultTag liefe bei einem
// Baseline-Bump auseinander.
func TestRules_TagKommtAusDemAufruf(t *testing.T) {
	targetDir := t.TempDir()
	const tag = "v0.0.0-testpin"
	if err := emit.Rules(targetDir, tag); err != nil {
		t.Fatalf("Rules: %v", err)
	}
	steht, err := os.Readlink(filepath.Join(targetDir, ".claude", "rules", "regelwerk-README.md"))
	if err != nil {
		t.Fatalf("Readlink: %v", err)
	}
	erwartet := "../../.harness/baseline/" + tag + "/regelwerk/README.md"
	if steht != erwartet {
		t.Errorf("Tag nicht aus dem Aufruf: steht %q, erwartet %q", steht, erwartet)
	}
}
