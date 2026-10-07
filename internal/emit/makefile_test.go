package emit_test

import (
	"io"
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
	// ADR-0080 Festlegung 3: repo.mk steht als ganze Zeile NACH dem Glob-Include und VOR
	// der Ordnungskante — sonst erreicht ihr GATE_CHECKS += die Kante nicht, oder die
	// ?=-Vorgaben der Fragmente schlagen ihr =. Gemessen wird die Zeilen-Position, nicht
	// das Vorkommen der Zeichenkette.
	zeile := map[string]int{}
	for i, l := range strings.Split(mk, "\n") {
		if _, schon := zeile[l]; !schon {
			zeile[l] = i
		}
	}
	reihe := []string{"include harness/mk/*.mk", "-include " + emit.RepoMkPath, "record-gates: $(GATE_CHECKS)"}
	for i, l := range reihe {
		if _, ok := zeile[l]; !ok {
			t.Fatalf("Aggregator traegt die Zeile %q nicht:\n%s", l, mk)
		}
		if i > 0 && zeile[reihe[i-1]] >= zeile[l] {
			t.Errorf("Zeile %q (Zeile %d) steht nicht vor %q (Zeile %d) — Reihenfolge aus ADR-0080 Festlegung 3 verletzt",
				reihe[i-1], zeile[reihe[i-1]]+1, l, zeile[l]+1)
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

// TestRepoMk_StartinhaltIstKopfOhneTargetsUndOhneWerkzeug haelt den Startinhalt von
// repo.mk gegen ADR-0080 Festlegung 2: nur Kommentarzeilen (keine Targets, keine
// Belegung), die Datei nennt das Einhaengen ueber GATE_CHECKS += und die Zeile in
// harness/README.md, und sie traegt keine Kennung des Werkzeugs — sie gehoert dem Repo.
func TestRepoMk_StartinhaltIstKopfOhneTargetsUndOhneWerkzeug(t *testing.T) {
	dir := t.TempDir()
	if err := emit.Enforce(dir, io.Discard); err != nil {
		t.Fatalf("Enforce: %v", err)
	}
	roh, err := os.ReadFile(filepath.Join(dir, emit.RepoMkPath))
	if err != nil {
		t.Fatalf("%s nicht angelegt: %v", emit.RepoMkPath, err)
	}
	text := string(roh)
	for i, l := range strings.Split(strings.TrimRight(text, "\n"), "\n") {
		if l != "" && !strings.HasPrefix(l, "#") {
			t.Errorf("%s Zeile %d ist keine Kommentarzeile: %q — der Startinhalt traegt keine Targets", emit.RepoMkPath, i+1, l)
		}
	}
	for _, want := range []string{"GATE_CHECKS += <target>", "harness/README.md"} {
		if !strings.Contains(text, want) {
			t.Errorf("%s nennt %q nicht", emit.RepoMkPath, want)
		}
	}
	if strings.Contains(text, "ai-harness-init") {
		t.Errorf("%s traegt die Kennung des Werkzeugs — die Datei gehoert dem Repo", emit.RepoMkPath)
	}
}
