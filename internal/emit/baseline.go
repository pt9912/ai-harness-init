package emit

import (
	_ "embed" // fuer die //go:embed-Direktive (baselineVerify)
	"io/fs"
)

// baselineVerify ist das tool-AUTORIERTE Verifikations-Skript fuer die vendored
// Baseline des Zielrepos (LH-FA-09). Es ist eingebettet, nicht gefetcht — anders
// als Regelwerk und Templates gehoert es der Generator-Klasse aus ADR-0005
// ("Tool-als-Quelle"), genau wie die minimale .d-check.yml. Der Embed-Abbau aus
// ADR-0005 betrifft das Kurs-DUPLIKAT (internal/emit/skel), nicht tool-eigene
// Artefakte: fuer die gibt es keine zweite Quelle, von der sie driften koennten.
//
//go:embed templates/baseline-verify.sh
var baselineVerify []byte

// BaselineVerifyPath ist der Zielpfad des Skripts. tools/harness/ (nicht das
// lokal adaptierte harness/tools/ dieses Repos): fuer die EMITTIERTE Struktur
// gilt LH-FA-06/ADR-0004, und MR-005 haelt ausdruecklich fest, dass die lokale
// Layout-Adaption NICHT auf die Emission generalisiert.
const BaselineVerifyPath = "tools/harness/baseline-verify.sh"

// BaselineMkPath ist der Zielpfad des Baseline-Fragments (slice-034). Es haengt
// baseline-verify an GATE_CHECKS an und traegt das Rezept, das das Verifikations-
// Skript ruft; der Root-Aggregator faehrt es via make gates. Damit ist das Skript
// nicht mehr orphaned (vor slice-034 emittiert, aber in keinem gates-Lauf gefahren).
const BaselineMkPath = "harness/mk/baseline.mk"

// baselineMk ist der Inhalt des Baseline-Fragments. Die Recipe-Zeile ist TAB-eingerueckt.
const baselineMk = `# harness/mk/baseline.mk — Baseline-Fragment, emittiert von ai-harness-init (slice-034).
# Verifiziert die vendored Baseline netzlos und haengt baseline-verify an GATE_CHECKS;
# der Root-Aggregator faehrt es via make gates.
.PHONY: baseline-verify

baseline-verify: ## Vendored Baseline netzlos verifizieren
	@bash tools/harness/baseline-verify.sh

GATE_CHECKS += baseline-verify
`

// BaselineVerify schreibt das Verifikations-Skript (0755, ausfuehrbar — ein nicht
// ausfuehrbares Gate-Skript waere eine leere Zusage) UND das Baseline-Fragment
// harness/mk/baseline.mk (0644, slice-034) nach targetDir. KONVERGENT (slice-038):
// tool-eigene Gate-Infrastruktur, bei jedem Lauf kanonisch neu geschrieben, kein Refuse.
func BaselineVerify(targetDir string) error {
	files := []struct {
		path    string
		content []byte
		mode    fs.FileMode
	}{
		{BaselineVerifyPath, baselineVerify, 0o755},
		{BaselineMkPath, []byte(baselineMk), 0o644},
	}
	for _, f := range files {
		if err := writeFileMode(targetDir, f.path, f.content, f.mode); err != nil {
			return err
		}
	}
	return nil
}

// BaselineVerifyScript liefert das eingebettete Skript (fuer Tests/Inspektion).
func BaselineVerifyScript() []byte { return baselineVerify }
