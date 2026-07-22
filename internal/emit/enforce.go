package emit

import (
	"bytes"
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

// enforceFiles ist die emittierte Durchsetzungsschicht. Die Tool-Skripte liegen
// unter tools/harness/ (emittiertes Layout, LH-FA-06/ADR-0004 — NICHT das lokal
// adaptierte harness/tools/, MR-005). Die Claude-Hooks/-Config liegen an ihren
// von Claude Code fixierten .claude/-Pfaden. settings.json verdrahtet BEIDE Hooks —
// den Stop-Hook (slice-031) und den PreToolUse-Command-Guard (slice-032); der Guard
// wird mit seinem awk-Extraktor (tools/harness/) mit-emittiert, sonst liefe der Hook
// im Ziel ins Leere.
func enforceFiles() []enforceFile {
	return []enforceFile{
		{"templates/enforce/working-tree-hash.sh", "tools/harness/working-tree-hash.sh", 0o755},
		{"templates/enforce/record-gates.sh", "tools/harness/record-gates.sh", 0o755},
		{"templates/enforce/stop-require-gates.sh", ".claude/hooks/stop-require-gates.sh", 0o755},
		{"templates/enforce/settings.json", ".claude/settings.json", 0o644},
		{"templates/enforce/gitignore", ".harness/.gitignore", 0o644},
		// Command-Guard (slice-032): bash+awk, kein node/jq (LH-QA-03). Der Guard
		// (0755) referenziert den awk-Extraktor unter tools/harness/ — beide
		// gehoeren in denselben Emit, sonst laeuft der Guard fail-closed ins Leere.
		{"templates/enforce/pretooluse-command-guard.sh", ".claude/hooks/pretooluse-command-guard.sh", 0o755},
		{"templates/enforce/extract-command.awk", "tools/harness/extract-command.awk", 0o644},
	}
}

// guardDst ist der Guard-Zielpfad — die einzige Datei mit --lang-Substitution
// (@@BLOCKED_SET@@ -> blockedSet(lang)); alle anderen werden verbatim geschrieben.
const guardDst = ".claude/hooks/pretooluse-command-guard.sh"

// blockedSet setzt das BLOCKED-Set des emittierten Guards je --lang zusammen
// (ADR-0006): die universellen Host-Paketmanager (sprach-agnostisch) plus die
// Host-Toolchain der Ziel-Sprache. Der Guard erzwingt make/Docker-only, indem er
// genau diese Kommandos in Kopfposition fail-closed blockt.
func blockedSet(lang string) string {
	const universal = "apt apt-get brew pip pip3 pipx npm pnpm yarn npx corepack cargo rustup gem conda"
	if extra, ok := blockedByLang()[lang]; ok {
		return universal + " " + extra
	}
	return universal
}

// blockedByLang bildet jede von gen unterstuetzte Sprache auf ihre Host-Toolchain
// ab. An gen.SupportedLangs() gekoppelt (Test): ein neues gen-Profil ohne Eintrag
// hier liesse die Sprach-Toolchain im Ziel ungehindert laufen (stille Luecke).
func blockedByLang() map[string]string {
	return map[string]string{
		"go": "go gofmt golangci-lint staticcheck",
	}
}

// BlockedSetForLang exportiert blockedSet fuer Tests (Kopplung an gen-Profile).
func BlockedSetForLang(lang string) string { return blockedSet(lang) }

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
func Enforce(targetDir, lang string, force bool) error {
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
		// Nur der Guard traegt eine --lang-Substitution; ein zurueckbleibendes
		// @@BLOCKED_SET@@ waere ein Guard ohne Zaehne (blockt nur SHELLS-Rekursion).
		if f.dst == guardDst {
			content = bytes.ReplaceAll(content, []byte("@@BLOCKED_SET@@"), []byte(blockedSet(lang)))
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
