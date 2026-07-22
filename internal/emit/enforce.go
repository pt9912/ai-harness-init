package emit

import (
	"embed"
	"errors"
	"fmt"
	"io/fs"
	"os"
	"path/filepath"
)

// enforceFS traegt die tool-AUTORIERTE Durchsetzungs-Mechanik (LH-FA-06,
// ADR-0006): Gate-Nachweis (record-gates + working-tree-hash) und Stop-Hook
// (stop-require-gates + settings.json + .harness/.gitignore). Sie ist
// eingebettet, nicht gefetcht — die Mechanik gehoert der Generator-Klasse aus
// ADR-0005/ADR-0006 ("Tool-als-Quelle"), genau wie baseline-verify.sh und die
// minimale .d-check.yml.
//
// SPRACH-AGNOSTISCH: die Skripte sind reine git/sha256/Hook-Infrastruktur, ohne
// --lang-Zweig — anders als der Command-Guard (slice-032), dessen BLOCKED-Set je
// Sprache variiert. all: bettet auch die dot-lose gitignore-Quelle sicher ein.
//
//go:embed all:templates/enforce
var enforceFS embed.FS

// enforceFile bildet eine eingebettete Quelle auf ihren Ziel-Relpfad + Modus ab.
type enforceFile struct {
	src  string      // Pfad in enforceFS
	dst  string      // Ziel-Relpfad (slash), relativ zu targetDir
	mode fs.FileMode // 0755 fuer ausfuehrbare Hooks/Tools, 0644 sonst
}

// enforceFiles ist die emittierte Durchsetzungs-Mechanik. Die Tool-Skripte liegen
// unter tools/harness/ (emittiertes Layout, LH-FA-06/ADR-0004 — NICHT das lokal
// adaptierte harness/tools/, MR-005). Die Claude-Hooks/-Config liegen an ihren
// von Claude Code fixierten .claude/-Pfaden. settings.json verdrahtet NUR den
// Stop-Hook — der PreToolUse-Guard ist slice-032 (er kommt mit seinem Skript,
// sonst liefe im Ziel ein Hook auf ein fehlendes Skript).
func enforceFiles() []enforceFile {
	return []enforceFile{
		{"templates/enforce/working-tree-hash.sh", "tools/harness/working-tree-hash.sh", 0o755},
		{"templates/enforce/record-gates.sh", "tools/harness/record-gates.sh", 0o755},
		{"templates/enforce/stop-require-gates.sh", ".claude/hooks/stop-require-gates.sh", 0o755},
		{"templates/enforce/settings.json", ".claude/settings.json", 0o644},
		{"templates/enforce/gitignore", ".harness/.gitignore", 0o644},
	}
}

// EnforcePaths liefert die Ziel-Relpfade der Durchsetzungs-Mechanik — fuer den
// Bootstrap-Pre-Flight (cmd, Phase 3). Ohne sie faende eine Kollision (z.B. eine
// vorhandene .claude/settings.json) erst mitten in Phase 4 statt (Teil-Bootstrap).
func EnforcePaths() []string {
	paths := make([]string, len(enforceFiles()))
	for i, f := range enforceFiles() {
		paths[i] = f.dst
	}
	return paths
}

// Enforce schreibt die Durchsetzungs-Mechanik nach targetDir. Kollisions-VORPASS
// (ohne force): existiert EINES der Ziele, schreibt KEINES — kein Teil-Emit
// (konsistent mit emit.Templates/wire.Place, slice-025). Ausfuehrbare Skripte
// bekommen 0755 per Chmod NACH dem Write: WriteFile wendet den Modus nur beim
// Anlegen an — ueber eine vorhandene 0644-Datei geschrieben (--force) bliebe der
// richtige Inhalt in einer nicht ausfuehrbaren Datei zurueck (Befund slice-022a L2).
func Enforce(targetDir string, force bool) error {
	if !force {
		for _, f := range enforceFiles() {
			dst := filepath.Join(targetDir, filepath.FromSlash(f.dst))
			switch _, err := os.Stat(dst); {
			case err == nil:
				return fmt.Errorf("%s existiert bereits (--force zum Ueberschreiben)", f.dst)
			case !errors.Is(err, fs.ErrNotExist):
				return fmt.Errorf("%s pruefen: %w", f.dst, err)
			}
		}
	}
	for _, f := range enforceFiles() {
		content, err := enforceFS.ReadFile(f.src)
		if err != nil {
			return fmt.Errorf("%s einbetten: %w", f.src, err)
		}
		dst := filepath.Join(targetDir, filepath.FromSlash(f.dst))
		if err := os.MkdirAll(filepath.Dir(dst), 0o755); err != nil {
			return fmt.Errorf("%s anlegen: %w", filepath.Dir(f.dst), err)
		}
		if err := os.WriteFile(dst, content, f.mode); err != nil {
			return fmt.Errorf("%s schreiben: %w", f.dst, err)
		}
		if err := os.Chmod(dst, f.mode); err != nil {
			return fmt.Errorf("%s Modus setzen: %w", f.dst, err)
		}
	}
	return nil
}

// EnforceFile liefert den eingebetteten Inhalt einer Mechanik-Quelle an ihrem
// Ziel-Relpfad (fuer Tests/Inspektion). Leerer slice, falls dst unbekannt.
func EnforceFile(dst string) []byte {
	for _, f := range enforceFiles() {
		if f.dst == dst {
			content, err := enforceFS.ReadFile(f.src)
			if err != nil {
				return nil
			}
			return content
		}
	}
	return nil
}
