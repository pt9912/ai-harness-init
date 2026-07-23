package emit_test

import (
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/pt9912/ai-harness-init/internal/emit"
)

// TestMakefile_HasOrderEdge ist der Reihenfolge-Waechter (slice-034, in slice-035 aus
// gen nach emit relocatet): der Aggregator MUSS die Fragmente per Glob einbinden UND die
// Ordnungskante `record-gates: $(GATE_CHECKS)` tragen. Ohne die Kante haengt gates nur an
// record-gates (ohne Prereqs) -> die Checks liefen GAR NICHT (stilles Teilmengen-Gate,
// LH-QA-01). Rot-Gegenbeispiel: test/mutations entfernt die Kante -> dieser Test wird rot.
func TestMakefile_HasOrderEdge(t *testing.T) {
	mk := emit.AggregatorMakefile()
	for _, want := range []string{"GATE_CHECKS :=", "include harness/mk/*.mk", "gates: record-gates", "record-gates: $(GATE_CHECKS)"} {
		if !strings.Contains(mk, want) {
			t.Errorf("Aggregator enthaelt %q nicht (Reihenfolge-Waechter):\n%s", want, mk)
		}
	}
}

// TestMakefile_Emits (slice-038): emit.Makefile schreibt den Aggregator (Init-Emitter,
// sprach-agnostisch, immer) — KONVERGENT: ein Re-Lauf ueber eine adopter-modifizierte
// Fassung schreibt sie kanonisch neu (heilt Drift), kein Refuse.
func TestMakefile_Emits(t *testing.T) {
	dir := t.TempDir()
	if err := emit.Makefile(dir); err != nil {
		t.Fatalf("Makefile: %v", err)
	}
	if got := mustReadString(t, filepath.Join(dir, emit.MakefilePath)); got != emit.AggregatorMakefile() {
		t.Errorf("emittierte Makefile != AggregatorMakefile():\n%s", got)
	}
	// konvergent: Re-Lauf ueber eine adopter-modifizierte Fassung heilt sie.
	if err := os.WriteFile(filepath.Join(dir, emit.MakefilePath), []byte("adopter-modifiziert"), 0o644); err != nil {
		t.Fatalf("vorbereiten: %v", err)
	}
	if err := emit.Makefile(dir); err != nil {
		t.Fatalf("Makefile (konvergent darf nicht refusen): %v", err)
	}
	if got := mustReadString(t, filepath.Join(dir, emit.MakefilePath)); got != emit.AggregatorMakefile() {
		t.Error("konvergenter Re-Lauf hat die Makefile nicht kanonisch neu geschrieben")
	}
}
