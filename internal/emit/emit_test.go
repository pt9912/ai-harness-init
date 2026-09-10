package emit_test

import (
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/pt9912/ai-harness-init/internal/emit"
)

// TestDCheckConfig_EntschiedeneModulListe haelt die entschiedene Modul-Liste fest: die
// eingebettete .d-check.yml aktiviert genau [links, anchors, ids, matrix, spans] — nicht
// "mindestens zwei Module". Jedes der drei neu aktivierten ist im frischen Ziel gemessen gruen UND
// faengt sein Gegenbeispiel (harness/tools/full-smoke.sh); dieser Test bindet nur die
// LISTE, nicht das Verhalten (das braucht Docker und liegt in full-smoke). codepaths
// bleibt aus: im frischen Ziel fehlt docs/plan/planning/observations/README.md, und drei
// mitemittierte Workflow-Commands referenzieren den Ort per Inline-Code — aktiv waere es
// ein brechendes Gate (LH-QA-01). Das Requirement-Muster von ids bleibt auskommentiert:
// das Praefix gehoert dem Adopter und ist in einem frischen Ziel nicht bekannt. Die
// spec-straten-Klasse traegt order:/direction: no-downward: die Baseline-Vorlage fuehrt
// beide im auskommentierten matrix-Block, und die Entscheidungsregel fuer emittierte
// Module bindet auf Modul-, nicht auf Positions-Ebene. exclude-sections traegt genau
// [Geschichte], nicht die weitere Dogfood-Liste und nicht leer.
func TestDCheckConfig_EntschiedeneModulListe(t *testing.T) {
	yml := emit.DCheckConfig()
	if !strings.Contains(yml, "modules: [links, anchors, ids, matrix, spans]") {
		t.Errorf("eingebettete .d-check.yml aktiviert nicht genau [links, anchors, ids, matrix, spans]:\n%s", yml)
	}
	sawPrefixPattern := false
	for _, line := range strings.Split(yml, "\n") {
		if strings.HasPrefix(line, "codepaths:") {
			t.Errorf("codepaths unkommentiert aktiv im frischen Repo (halluziniertes Gate): %q", line)
		}
		trimmed := strings.TrimSpace(line)
		if strings.Contains(trimmed, "<PREFIX>") {
			sawPrefixPattern = true
			if !strings.HasPrefix(trimmed, "#") {
				t.Errorf("das Requirement-Muster von ids ist unkommentiert aktiv, obwohl das Praefix in einem frischen Ziel nicht bekannt ist: %q", line)
			}
		}
	}
	if !sawPrefixPattern {
		t.Errorf("das auskommentierte Requirement-Muster von ids fehlt ganz (kein <PREFIX> mehr in der Vorlage):\n%s", yml)
	}
	if !strings.Contains(yml, "regex: 'ADR-\\d{4}'") || !strings.Contains(yml, "link-policy: always") {
		t.Errorf("das ADR-Muster von ids fehlt oder traegt nicht link-policy: always:\n%s", yml)
	}
	if !strings.Contains(yml, "{from: adr, to: slice, allow: false}") || !strings.Contains(yml, "{from: adr, to: welle, allow: false}") {
		t.Errorf("die beiden neuen matrix-Regeln (adr->slice, adr->welle) fehlen:\n%s", yml)
	}
	if !strings.Contains(yml, "order: [spec/lastenheft.md, spec/spezifikation.md, spec/architecture.md]") || !strings.Contains(yml, "direction: no-downward") {
		t.Errorf("die Richtungspruefung (order:/direction: no-downward) auf spec-straten fehlt:\n%s", yml)
	}
	// exclude-sections traegt exakt [Geschichte] — weder leer (dann faengt
	// {from: adr, to: slice} auch die legitime, im Zeilen-Marker deklarierte
	// Provenance-Zeile der ADR-Geschichte-Tabelle) noch die weitere Dogfood-Liste
	// [Historie, "7. Historie", Geschichte] (die Spec-Straten-Vorlagen fuehren dort keine
	// Ausnahme, s. internal/emit/templates/d-check.yml Kopfkommentar).
	if !strings.Contains(yml, "exclude-sections: [Geschichte]") {
		t.Errorf("exclude-sections traegt nicht genau [Geschichte]:\n%s", yml)
	}
}

// TestDefaultDigest_MatchesCanonical haelt DoD-3/LH-QA-02 fest: der Default-Pin des
// Tools ist identisch zur kanonischen Pin-Quelle des Repos (./d-check.mk). Faengt
// Drift, wenn ./d-check.mk bei einem d-check-Bump neu gepinnt, das Tool aber vergessen wird.
func TestDefaultDigest_MatchesCanonical(t *testing.T) {
	canonical := mkVar(t, filepath.Join("..", "..", "d-check.mk"), "DCHECK_DIGEST")
	if !strings.HasPrefix(emit.DefaultDigest, "sha256:") {
		t.Errorf("emit.DefaultDigest nicht sha256-gepinnt: %q", emit.DefaultDigest)
	}
	if emit.DefaultDigest != canonical {
		t.Errorf("emit.DefaultDigest %q != kanonische Pin-Quelle %q (Drift)", emit.DefaultDigest, canonical)
	}
}

// TestDefaultImage_MatchesCanonical koppelt auch die Tag-Referenz an die kanonische
// ./d-check.mk (nicht nur den Digest) — Tag-Drift bliebe sonst unbemerkt (Review-L3).
func TestDefaultImage_MatchesCanonical(t *testing.T) {
	canonical := mkVar(t, filepath.Join("..", "..", "d-check.mk"), "DCHECK_IMAGE")
	if emit.DefaultImage != canonical {
		t.Errorf("emit.DefaultImage %q != kanonische Quelle %q (Tag-Drift)", emit.DefaultImage, canonical)
	}
}

// TestRunRef deckt die pure Referenz-Berechnung ab (die gepinnte repo@digest-Achse,
// LH-QA-02) — ohne Docker, also Tier-1 statt nur make smoke (Review-M1).
func TestRunRef(t *testing.T) {
	tests := []struct {
		name, image, digest, want string
	}{
		{"digest sticht tag", "ghcr.io/pt9912/d-check:v0.46.0", "sha256:abc", "ghcr.io/pt9912/d-check@sha256:abc"},
		{"ohne digest -> tag-referenz", "ghcr.io/pt9912/d-check:v0.46.0", "", "ghcr.io/pt9912/d-check:v0.46.0"},
		{"registry-port bleibt, nur tag entfernt", "reg.example:5000/d-check:v1", "sha256:xyz", "reg.example:5000/d-check@sha256:xyz"},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := emit.Options{Image: tt.image, Digest: tt.digest}.RunRef()
			if got != tt.want {
				t.Errorf("RunRef() = %q, want %q", got, tt.want)
			}
		})
	}
}

// TestAdaptMK_Fixture prueft die vier MR-010-Handgriffe an einer echten
// --print-mk-Ausgabe (testdata/raw-print-mk.txt, v0.46.0): docs-check-Rename,
// Digest-Pin, doc-help-Grep, Adopter-Header — advisory doc-*-Targets unberuehrt.
func TestAdaptMK_Fixture(t *testing.T) {
	raw, err := os.ReadFile(filepath.Join("testdata", "raw-print-mk.txt"))
	if err != nil {
		t.Fatalf("Fixture lesen: %v", err)
	}
	const digest = "sha256:deadbeef"
	got, err := emit.AdaptMK(raw, digest)
	if err != nil {
		t.Fatalf("AdaptMK: %v", err)
	}
	mk := string(got)

	wantContains := []string{
		"Emittiert von ai-harness-init",          // Adopter-Header ersetzt
		".PHONY: docs-check",                     // Rename (.PHONY)
		"docs-check: ## Doku-Referenzen",         // Rename (Target)
		"DCHECK_DIGEST ?= " + digest,             // Digest gepinnt
		"'^docs?-[a-z-]+:",                        // doc-help-Grep erweitert
		".PHONY: doc-trace",                      // advisory verbatim
		".PHONY: doc-help",                       // advisory verbatim
	}
	for _, w := range wantContains {
		if !strings.Contains(mk, w) {
			t.Errorf("adaptiertes Fragment enthaelt %q nicht:\n%s", w, mk)
		}
	}
	wantAbsent := []string{
		".PHONY: doc-check\n", // altes Befund-Gate-Target darf weg sein
		"DCHECK_DIGEST ?=\n",  // leere Pin-Zeile darf weg sein
		"d-check --print-mk (DC-FA-CLI-010)", // d-checks eigener Kopf ersetzt
	}
	for _, w := range wantAbsent {
		if strings.Contains(mk, w) {
			t.Errorf("adaptiertes Fragment enthaelt unerwartet noch %q", w)
		}
	}
}

// TestDocGate_FragmentWiresDocsCheck: das Doc-Gate-Fragment haengt docs-check an
// GATE_CHECKS und bindet d-check.mk ein — der netzlose Waechter auf die Verdrahtung
// (DocGate selbst braucht Docker; ersetzt zusammen mit full-smoke die Deckung des
// entfernten Mutations-Falls 21, Review-Befund slice-034 F-1). test/mutations/40 bricht
// die GATE_CHECKS-Zeile -> dieser Test wird rot.
func TestDocGate_FragmentWiresDocsCheck(t *testing.T) {
	frag := emit.DocGateMk()
	for _, want := range []string{"include d-check.mk", "GATE_CHECKS += docs-check"} {
		if !strings.Contains(frag, want) {
			t.Errorf("Doc-Gate-Fragment enthaelt %q nicht (docs-check nicht in gates verdrahtet):\n%s", want, frag)
		}
	}
}

func TestAdaptMK_MissingAnchor(t *testing.T) {
	if _, err := emit.AdaptMK([]byte("# voellig anderes Format\n"), "sha256:x"); err == nil {
		t.Error("AdaptMK: kein Fehler trotz fehlendem DCHECK_IMAGE-Anker")
	}
}

// mkVar zieht den Wert einer `<name> ?= <wert>`-Zuweisung aus einem d-check.mk.
func mkVar(t *testing.T, mkPath, name string) string {
	t.Helper()
	data, err := os.ReadFile(mkPath)
	if err != nil {
		t.Fatalf("mk lesen (%s): %v", mkPath, err)
	}
	prefix := name + " ?= "
	for _, line := range strings.Split(string(data), "\n") {
		if strings.HasPrefix(line, prefix) {
			return strings.TrimSpace(strings.TrimPrefix(line, prefix))
		}
	}
	t.Fatalf("%s nicht gefunden in %s", name, mkPath)
	return ""
}
