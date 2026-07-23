package emit

import (
	_ "embed" // fuer die //go:embed-Direktive (baselineVerify)
	"errors"
	"fmt"
	"io/fs"
	"os"
	"path/filepath"
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
// harness/mk/baseline.mk (0644, slice-034) nach targetDir. Ohne force wird eine
// vorhandene Datei nicht ueberschrieben (LH-FA-01 Boundary-AC); der Kollisions-
// Vorpass deckt BEIDE Ziele (kein Teil-Emit).
func BaselineVerify(targetDir string, force bool) error {
	files := []struct {
		path    string
		content []byte
		mode    fs.FileMode
	}{
		{BaselineVerifyPath, baselineVerify, 0o755},
		{BaselineMkPath, []byte(baselineMk), 0o644},
	}
	if !force {
		for _, f := range files {
			dst := filepath.Join(targetDir, filepath.FromSlash(f.path))
			switch _, err := os.Stat(dst); {
			case err == nil:
				return fmt.Errorf("%s existiert bereits (--force zum Ueberschreiben)", f.path)
			case !errors.Is(err, fs.ErrNotExist):
				return fmt.Errorf("%s pruefen: %w", f.path, err)
			}
		}
	}
	for _, f := range files {
		dst := filepath.Join(targetDir, filepath.FromSlash(f.path))
		if err := os.MkdirAll(filepath.Dir(dst), 0o755); err != nil {
			return fmt.Errorf("%s anlegen: %w", filepath.Dir(f.path), err)
		}
		if err := os.WriteFile(dst, f.content, f.mode); err != nil {
			return fmt.Errorf("%s schreiben: %w", f.path, err)
		}
		// os.WriteFile wendet den Modus nur beim ANLEGEN an: ueber eine vorhandene
		// 0644-Datei geschrieben (--force) bliebe der richtige Inhalt in einer nicht
		// ausfuehrbaren Datei zurueck (Review-Befund slice-022a L2).
		if err := os.Chmod(dst, f.mode); err != nil {
			return fmt.Errorf("%s Modus setzen: %w", f.path, err)
		}
	}
	return nil
}

// BaselineVerifyScript liefert das eingebettete Skript (fuer Tests/Inspektion).
func BaselineVerifyScript() []byte { return baselineVerify }
