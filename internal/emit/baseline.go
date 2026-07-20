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

// BaselineVerify schreibt das Verifikations-Skript nach targetDir. Ausfuehrbar
// (0755) — ein nicht ausfuehrbares Gate-Skript waere eine leere Zusage. Ohne
// force wird eine vorhandene Datei nicht ueberschrieben (LH-FA-01 Boundary-AC).
func BaselineVerify(targetDir string, force bool) error {
	dst := filepath.Join(targetDir, filepath.FromSlash(BaselineVerifyPath))
	if !force {
		switch _, err := os.Stat(dst); {
		case err == nil:
			return fmt.Errorf("%s existiert bereits (--force zum Ueberschreiben)", BaselineVerifyPath)
		case !errors.Is(err, fs.ErrNotExist):
			return fmt.Errorf("%s pruefen: %w", BaselineVerifyPath, err)
		}
	}
	if err := os.MkdirAll(filepath.Dir(dst), 0o755); err != nil {
		return fmt.Errorf("%s anlegen: %w", filepath.Dir(BaselineVerifyPath), err)
	}
	if err := os.WriteFile(dst, baselineVerify, 0o755); err != nil {
		return fmt.Errorf("%s schreiben: %w", BaselineVerifyPath, err)
	}
	// os.WriteFile wendet das Perm-Argument nur beim ANLEGEN an: ueber eine
	// vorhandene 0644-Datei geschrieben (--force) bliebe der richtige Inhalt in
	// einer nicht ausfuehrbaren Datei zurueck (Review-Befund slice-022a L2).
	if err := os.Chmod(dst, 0o755); err != nil {
		return fmt.Errorf("%s ausfuehrbar machen: %w", BaselineVerifyPath, err)
	}
	return nil
}

// BaselineVerifyScript liefert das eingebettete Skript (fuer Tests/Inspektion).
func BaselineVerifyScript() []byte { return baselineVerify }
