package emit_test

import (
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

// TestMakefile_Emits: emit.Makefile schreibt die Aggregator-Root-Makefile (Init-Emitter,
// sprach-agnostisch, immer) und ueberschreibt ohne force nicht (LH-FA-01 Boundary).
func TestMakefile_Emits(t *testing.T) {
	dir := t.TempDir()
	if err := emit.Makefile(dir, false); err != nil {
		t.Fatalf("Makefile: %v", err)
	}
	if got := mustReadString(t, filepath.Join(dir, emit.MakefilePath)); got != emit.AggregatorMakefile() {
		t.Errorf("emittierte Makefile != AggregatorMakefile():\n%s", got)
	}
	if err := emit.Makefile(dir, false); err == nil {
		t.Error("vorhandene Makefile ohne --force ueberschrieben")
	}
	if err := emit.Makefile(dir, true); err != nil {
		t.Errorf("Makefile mit force: %v", err)
	}
}
