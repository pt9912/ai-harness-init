package emit_test

import (
	"context"
	"errors"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/pt9912/ai-harness-init/internal/emit"
)

// printedPin ist der Pin, den die --print-mk-Attrappe DRUCKT — bewusst ein anderer als
// der, mit dem sie „erzeugt" wurde. Genau diese Lage hat a-check v0.15.0 real: der im
// Binary gebackene Pin hinkt dem laufenden Image nach.
const printedPin = "sha256:1111111111111111111111111111111111111111111111111111111111111111"

const rawArchMK = `# a-check.mk — Architektur-Gate via a-check, zum ` + "`include`" + ` in das
# Makefile des konsumierenden Repos. Erzeugt von ` + "`a-check --print-mk`" + `.
#
# A_CHECK_IMAGE wird beim Release auf ` + "`@sha256:…`" + ` digest-gepinnt.
A_CHECK_IMAGE ?= ghcr.io/pt9912/a-check@` + printedPin + `

.PHONY: a-check a-check-graph
a-check: ## Architektur: Hexagon-Regeln via a-check (netzlos, read-only).
	docker run --rm --network none -v "$(CURDIR)":/src:ro $(A_CHECK_IMAGE) /src
`

func fakePrintMK(raw string, err error) emit.PrintMK {
	return func(context.Context, string) ([]byte, error) {
		if err != nil {
			return nil, err
		}
		return []byte(raw), nil
	}
}

// TestAdaptArchMK_PinsProducingRef (slice-046, LH-QA-02): das emittierte Fragment traegt
// den Digest, der es ERZEUGT hat — nicht den gedruckten. Ohne dieses Umpinnen emittierte
// der Bootstrap eine stille Unwahrheit („dieses Fragment stammt von Image X", waehrend
// Y lief). Rot-Gegenbeispiel: test/mutations laesst die Pin-Zeile unveraendert.
func TestAdaptArchMK_PinsProducingRef(t *testing.T) {
	ref := "ghcr.io/pt9912/a-check@" + emit.DefaultArchDigest
	got, err := emit.AdaptArchMK([]byte(rawArchMK), ref)
	if err != nil {
		t.Fatalf("AdaptArchMK: %v", err)
	}
	s := string(got)
	if !strings.Contains(s, "A_CHECK_IMAGE ?= "+ref+"\n") {
		t.Errorf("Fragment nicht auf die erzeugende Referenz gepinnt:\n%s", s)
	}
	if strings.Contains(s, printedPin) {
		t.Errorf("Fragment traegt weiter den GEDRUCKTEN Pin:\n%s", s)
	}
	if !strings.Contains(s, "Emittiert von ai-harness-init") {
		t.Errorf("Adopter-Kopf fehlt:\n%s", s)
	}
	if !strings.Contains(s, ".PHONY: a-check a-check-graph") {
		t.Errorf("Tool-Targets nicht verbatim uebernommen:\n%s", s)
	}
}

// TestAdaptArchMK_UnknownFormat (slice-046): aendert a-check sein --print-mk-Format so,
// dass der Anker fehlt, bricht die Adaption HART ab — statt ein halb adaptiertes (also
// falsch gepinntes) Fragment zu emittieren.
func TestAdaptArchMK_UnknownFormat(t *testing.T) {
	if _, err := emit.AdaptArchMK([]byte("# nur ein Kommentar\n"), "ref"); err == nil {
		t.Error("AdaptArchMK ohne Anker = nil, want Fehler")
	}
}

// TestArchGateMk_RootAndScoped (slice-046): am Root haengt das Fragment das Tool-eigene
// Target an GATE_CHECKS; im Unterverzeichnis definiert es ein modul-scoped Target, das
// NUR das Modul mountet — sonst liefe a-check mit der Modul-Config ueber dem ganzen Repo.
// Beide tragen den include-once-Waechter (zwei hexSlice-Module -> sonst `overriding recipe`).
func TestArchGateMk_RootAndScoped(t *testing.T) {
	root := emit.ArchGateMk("go", ".")
	if !strings.Contains(root, "GATE_CHECKS += a-check\n") {
		t.Errorf("Root-Fragment haengt a-check nicht an GATE_CHECKS:\n%s", root)
	}
	if strings.Contains(root, "a-check-go:") {
		t.Errorf("Root-Fragment definiert ein modul-scoped Target:\n%s", root)
	}
	scoped := emit.ArchGateMk("apps-hex", "apps/hex")
	for _, want := range []string{
		"\na-check-apps-hex: ##",
		"-v \"$(CURDIR)/apps/hex\":/src:ro",
		"GATE_CHECKS += a-check-apps-hex\n",
	} {
		if !strings.Contains(scoped, want) {
			t.Errorf("scoped Fragment ohne %q:\n%s", want, scoped)
		}
	}
	if strings.Contains(scoped, "GATE_CHECKS += a-check\n") {
		t.Errorf("scoped Fragment haengt das UNSCOPED Target an GATE_CHECKS (Kollision):\n%s", scoped)
	}
	for _, frag := range []string{root, scoped} {
		if !strings.Contains(frag, "ifndef ARCH_GATE_MK_INCLUDED\nARCH_GATE_MK_INCLUDED := 1\ninclude a-check.mk\nendif\n") {
			t.Errorf("Fragment ohne include-once-Waechter:\n%s", frag)
		}
	}
}

// TestArchGateMk_WaechterKeytNichtAufNutzerVariable (slice-046, Review F-1 / Verifier R-1):
// der include-once-Waechter darf NICHT auf A_CHECK_IMAGE keyen. make importiert die
// Umgebung, und A_CHECK_IMAGE ist der dokumentierte Adopter-Override (a-check.mk bietet
// sie per `?=` an): wer ihn benutzt, verlöre sonst den `include`, und im ROOT-Fragment
// zeigte `GATE_CHECKS += a-check` auf ein undefiniertes Target — der Override schaltete
// das Gate ab. Rot-Gegenbeispiel: test/mutations 70 setzt den Waechter auf A_CHECK_IMAGE
// zurueck. Das VERHALTEN unter gesetzter Variable belegt zusaetzlich make full-smoke.
func TestArchGateMk_WaechterKeytNichtAufNutzerVariable(t *testing.T) {
	for _, frag := range []string{emit.ArchGateMk("go", "."), emit.ArchGateMk("apps-hex", "apps/hex")} {
		if strings.Contains(frag, "ifndef A_CHECK_IMAGE") {
			t.Errorf("include-once-Waechter keyt auf den Adopter-Override A_CHECK_IMAGE:\n%s", frag)
		}
	}
}

// TestArchGate_WritesArtifacts (slice-046, LH-FA-07): der Emitter schreibt die drei
// Artefakte an ihre Plaetze — Config IM MODUL, Tool-Fragment im Ziel-Root, Gate-Fragment
// unter harness/mk/.
func TestArchGate_WritesArtifacts(t *testing.T) {
	dir := t.TempDir()
	opts := emit.Options{Image: emit.DefaultArchImage, Digest: emit.DefaultArchDigest}
	if err := emit.ArchGate(context.Background(), dir, "apps/hex", "apps-hex", "layers: …\n", opts, fakePrintMK(rawArchMK, nil)); err != nil {
		t.Fatalf("ArchGate: %v", err)
	}
	for _, rel := range []string{
		"apps/hex/" + emit.ArchConfigName,
		emit.ArchMkPath,
		emit.ArchGateMkPath("apps-hex"),
	} {
		if _, err := os.Stat(filepath.Join(dir, filepath.FromSlash(rel))); err != nil {
			t.Errorf("%s nicht emittiert: %v", rel, err)
		}
	}
}

// TestArchGate_IdempotenzKlassen (slice-046, ADR-0007/slice-038): die Schicht-Config ist
// SKIP-IF-PRESENT (der Adopter ersetzt example/greet durch seine Areas — ein Re-Lauf darf
// das nie clobbern), das tool-generierte Fragment KONVERGENT (heilt Drift/Digest-Bump).
func TestArchGate_IdempotenzKlassen(t *testing.T) {
	dir := t.TempDir()
	opts := emit.Options{Image: emit.DefaultArchImage, Digest: emit.DefaultArchDigest}
	src := fakePrintMK(rawArchMK, nil)
	if err := emit.ArchGate(context.Background(), dir, ".", "go", "kanonisch\n", opts, src); err != nil {
		t.Fatalf("ArchGate (1. Lauf): %v", err)
	}
	cfgPath := filepath.Join(dir, emit.ArchConfigName)
	if err := os.WriteFile(cfgPath, []byte("adopter-eigene Schichten\n"), 0o644); err != nil {
		t.Fatalf("setup: %v", err)
	}
	mkPath := filepath.Join(dir, emit.ArchMkPath)
	if err := os.WriteFile(mkPath, []byte("# drift\n"), 0o644); err != nil {
		t.Fatalf("setup: %v", err)
	}
	if err := emit.ArchGate(context.Background(), dir, ".", "go", "kanonisch\n", opts, src); err != nil {
		t.Fatalf("ArchGate (2. Lauf): %v", err)
	}
	if got := readFileT(t, cfgPath); got != "adopter-eigene Schichten\n" {
		t.Errorf(".a-check.yml wurde geclobbert (skip-if-present verletzt): %q", got)
	}
	if got := readFileT(t, mkPath); strings.Contains(got, "# drift") {
		t.Errorf("a-check.mk heilte die Drift nicht (konvergent verletzt): %q", got)
	}
}

// TestArchGate_PrintFehlerSchreibtNichts (slice-046): faellt die Fragment-Quelle, wird
// NICHTS geschrieben — kein halb emittiertes Gate (dieselbe Reihenfolge-Disziplin wie
// bei DocGate: erst die fallierbaren Schritte, dann die Schreibvorgaenge).
func TestArchGate_PrintFehlerSchreibtNichts(t *testing.T) {
	dir := t.TempDir()
	opts := emit.Options{Image: emit.DefaultArchImage, Digest: emit.DefaultArchDigest}
	err := emit.ArchGate(context.Background(), dir, ".", "go", "cfg\n", opts, fakePrintMK("", errors.New("kein docker")))
	if err == nil {
		t.Fatal("ArchGate mit fallierender Quelle = nil, want Fehler")
	}
	entries, readErr := os.ReadDir(dir)
	if readErr != nil {
		t.Fatalf("ReadDir: %v", readErr)
	}
	if len(entries) != 0 {
		t.Errorf("Zielverzeichnis nicht leer nach Fehlschlag: %v", entries)
	}
}

func readFileT(t *testing.T, path string) string {
	t.Helper()
	b, err := os.ReadFile(path)
	if err != nil {
		t.Fatalf("%s lesen: %v", path, err)
	}
	return string(b)
}
