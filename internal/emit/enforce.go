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
// SPRACH-AGNOSTISCH: alle eingebetteten Skripte inkl. des Command-Guards sind verbatim
// (slice-036: der Guard traegt den universellen Boden GEBACKEN und liest blocked/* zur
// Laufzeit; das Sprach-Set kommt als separates blocked/<lang>-Fragment, nicht mehr per
// @@BLOCKED_SET@@-Substitution). all: bettet auch die dot-lose gitignore-Quelle sicher ein.
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
		// Enforce-Gate-Fragment (slice-034): das record-gates-Rezept als
		// harness/mk/enforce.mk. Die Ordnungskante (record-gates: $(GATE_CHECKS)) +
		// `gates: record-gates` leben im Root-Aggregator (gen), weil sie GATE_CHECKS
		// erst nach dem Glob-Include vollstaendig sehen. Sprach-agnostisch, verbatim.
		{"templates/enforce/enforce.mk", "harness/mk/enforce.mk", 0o644},
		// Command-Guard (slice-032): bash+awk, kein node/jq (LH-QA-03). Der Guard
		// (0755) referenziert den awk-Extraktor unter tools/harness/ — beide
		// gehoeren in denselben Emit, sonst laeuft der Guard fail-closed ins Leere.
		{"templates/enforce/pretooluse-command-guard.sh", ".claude/hooks/pretooluse-command-guard.sh", 0o755},
		{"templates/enforce/extract-command.awk", "tools/harness/extract-command.awk", 0o644},
	}
}

// blockedDir ist das Verzeichnis der Sprach-BLOCKED-Fragmente im Ziel (emittiertes
// Layout, MR-005). Der emittierte Guard traegt den universellen Boden GEBACKEN (fail-safe,
// nie fail-open) und liest zusaetzlich blocked/* (Union, reines bash+cat, LH-QA-03).
// add-lang droppt blocked/<sprache> (slice-037); der --lang-One-Shot emittiert es hier.
const blockedDir = "tools/harness/blocked"

// BlockedFragmentPath liefert den Zielpfad des Sprach-BLOCKED-Fragments blocked/<lang>.
func BlockedFragmentPath(lang string) string { return blockedDir + "/" + lang }

// blockedByLang bildet jede von gen unterstuetzte Sprache auf ihre Host-Toolchain ab —
// der Inhalt des blocked/<lang>-Fragments (whitespace-getrennt, mit Zeilenumbruch). An
// gen.SupportedLangs() gekoppelt (Test): ein neues gen-Profil ohne Eintrag hier liesse die
// Sprach-Toolchain im Ziel ungehindert laufen (stille Luecke).
func blockedByLang() map[string]string {
	return map[string]string{
		"go":  "go gofmt golangci-lint staticcheck\n",
		"cpp": "g++ gcc cmake clang-tidy clang clang++\n",
	}
}

// BlockedFragmentForLang exportiert den Fragment-Inhalt fuer Tests (Kopplung an
// gen-Profile); leer, wenn lang kein Profil hat.
func BlockedFragmentForLang(lang string) string { return blockedByLang()[lang] }

// EnforcePaths liefert die Ziel-Relpfade der Durchsetzungs-Mechanik — fuer den
// Bootstrap-Pre-Flight (cmd, Phase 3). Ohne sie faende eine Kollision (z.B. eine
// vorhandene .claude/settings.json) erst mitten in Phase 4 statt (Teil-Bootstrap).
// SPRACH-AGNOSTISCH (slice-037): das blocked/<lang>-Fragment gehoert NICHT mehr hierher
// — es ist skip-if-present (Mono-Repo-Wiederverwendung, mehrere Module gleicher Sprache)
// und wird von add-lang via BlockedFragment gedroppt, nicht vom Kollisions-Pre-Flight
// erfasst.
func EnforcePaths() []string {
	files := enforceFiles()
	paths := make([]string, 0, len(files))
	for _, f := range files {
		paths = append(paths, f.dst)
	}
	return paths
}

// Enforce schreibt die sprach-agnostische Durchsetzungs-Mechanik nach targetDir —
// KONVERGENT (slice-038, ADR-0007 Idempotenz-Klasse): reine tool-eigene Infrastruktur,
// bei jedem Lauf kanonisch neu geschrieben (heilt Drift), kein Refuse, kein --force
// (das Pre-Flight-refuse-Modell aus slice-025 ist mit slice-038 gefallen). Der Guard
// traegt seinen universellen Boden GEBACKEN (slice-036); das Sprach-Set kommt als
// blocked/<lang>-Fragment (BlockedFragment, add-lang), NICHT hier (Enforce ist sprachlos).
func Enforce(targetDir string) error {
	for _, f := range enforceFiles() {
		content, err := enforceFS.ReadFile(f.src)
		if err != nil {
			return fmt.Errorf("%s einbetten: %w", f.src, err)
		}
		if err := writeFileMode(targetDir, f.dst, content, f.mode); err != nil {
			return err
		}
	}
	return nil
}

// BlockedFragment droppt das Sprach-BLOCKED-Fragment blocked/<lang> nach targetDir —
// KONVERGENT (slice-038, Review-I-1-Versoehnung: ADR-0007 Z.100 listet blocked/<sprache>
// als konvergent, nicht mehr skip-if-present wie slice-037). Kanonisch neu schreiben ist
// auch im Mono-Repo idempotent: ein zweites add-lang derselben Sprache schreibt byte-
// identisch (LH-QA-02), kein Clobber-Risiko (der Inhalt ist tool-fixiert). Ohne gen-Profil
// (unbekannte/leere Sprache) ist es ein no-op — sprachlos gibt es kein Fragment, nur den
// gebackenen Guard-Boden. Der emittierte Guard vereinigt es zur Laufzeit mit dem Boden.
func BlockedFragment(targetDir, lang string) error {
	frag, ok := blockedByLang()[lang]
	if !ok {
		return nil
	}
	return writeFileMode(targetDir, BlockedFragmentPath(lang), []byte(frag), 0o644)
}

// writeFileMode ist der KONVERGENTE Writer (slice-038): schreibt content nach targetDir/rel
// (slash) mit mode IMMER (kanonisch, ueberschreibt) — MkdirAll fuer den Elternpfad + Chmod
// NACH dem Write (os.WriteFile wendet den Modus nur beim Anlegen an — ueber eine vorhandene
// 0644-Datei geschrieben bliebe der richtige Inhalt sonst nicht ausfuehrbar zurueck, Befund
// slice-022a L2). Fuer tool-eigene Infrastruktur, die der Adopter nicht editieren soll.
func writeFileMode(targetDir, rel string, content []byte, mode fs.FileMode) error {
	dst := filepath.Join(targetDir, filepath.FromSlash(rel))
	if err := os.MkdirAll(filepath.Dir(dst), 0o755); err != nil {
		return fmt.Errorf("%s anlegen: %w", filepath.Dir(rel), err)
	}
	if err := os.WriteFile(dst, content, mode); err != nil {
		return fmt.Errorf("%s schreiben: %w", rel, err)
	}
	if err := os.Chmod(dst, mode); err != nil {
		return fmt.Errorf("%s Modus setzen: %w", rel, err)
	}
	return nil
}

// writeSkipIfPresent ist der SKIP-IF-PRESENT-Writer (slice-038, ADR-0007): schreibt content
// NUR, wenn targetDir/rel FEHLT — eine vorhandene Datei bleibt unberuehrt (return nil, kein
// Fehler). Fuer Adopter-Boden (Doc-Chain, README, Skelett-Code, .d-check.yml, Commands): der
// idempotente Re-Lauf clobbert adopter-modifizierten Inhalt NIE (der sichere Default der ADR).
func writeSkipIfPresent(targetDir, rel string, content []byte, mode fs.FileMode) error {
	dst := filepath.Join(targetDir, filepath.FromSlash(rel))
	switch _, err := os.Stat(dst); {
	case err == nil:
		return nil // vorhanden -> nie ueberschreiben (skip-if-present)
	case !errors.Is(err, fs.ErrNotExist):
		return fmt.Errorf("%s pruefen: %w", rel, err)
	}
	return writeFileMode(targetDir, rel, content, mode)
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
