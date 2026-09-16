package emit

import (
	"embed"
	"fmt"
	"io"
)

// commandsFS traegt die tool-AUTORIERTEN Agenten-Workflow-Commands (LH-FA-08,
// ADR-0006): die Slash-Command-ANLEITUNG, mit der ein Agent die Harness-Rollen
// faehrt (Slice implementieren, Welle planen/schliessen). Anders als die
// Durchsetzungsschicht (LH-FA-06, enforce.go — was den Prozess ERZWINGT) sind die
// Commands die BESCHREIBUNG des Prozesses. Beide sind .claude/-Inhalt, aber
// verschiedene Klassen — darum eine eigene Funktion.
//
// SPRACH-AGNOSTISCH: die Commands sind der harness-Prozess (Lifecycle/Rollen/
// Review/Verifikation), kein --lang-Zweig. Das einzige sprach-nahe Detail (die
// Host-Toolchain im Guard) steht als adaptierbarer Marker, nicht hart kodiert —
// LH-FA-08s „je --lang parametriert" ist so trivial erfuellt (Tool-als-Quelle +
// adaptierbare Marker, LH-FA-02 zweiklassig).
//
//go:embed all:templates/commands
var commandsFS embed.FS

// commandFiles bildet jede eingebettete Command-Quelle auf ihren Ziel-Relpfad ab.
// Ziel ist .claude/commands/ (von Claude Code fixiert), die Commands sind reine
// .md-Anleitung (0644) und darum skip-if-present wie der uebrige Adopter-Boden.
func commandFiles() []enforceFile {
	return []enforceFile{
		{src: "templates/commands/implement-slice.md", dst: ".claude/commands/implement-slice.md", mode: 0o644, class: SkipIfPresent},
		{src: "templates/commands/plan-welle.md", dst: ".claude/commands/plan-welle.md", mode: 0o644, class: SkipIfPresent},
		{src: "templates/commands/close-welle.md", dst: ".claude/commands/close-welle.md", mode: 0o644, class: SkipIfPresent},
	}
}

// CommandPaths liefert die Ziel-Relpfade der Workflow-Commands — fuer den
// Bootstrap-Pre-Flight (cmd, Phase 3). Ohne sie faende eine Kollision (z.B. ein
// vorhandenes .claude/commands/implement-slice.md) erst mitten in Phase 4 statt.
func CommandPaths() []string {
	paths := make([]string, len(commandFiles()))
	for i, f := range commandFiles() {
		paths[i] = f.dst
	}
	return paths
}

// Commands schreibt die Workflow-Commands nach targetDir — SKIP-IF-PRESENT (ADR-0007
// Festlegung 3: die Commands tragen den ANPASSEN-Marker, der Adopter adaptiert sie). Ein
// idempotenter Re-Lauf clobbert eine adopter-adaptierte Command-Anleitung NIE; Prozess-
// Updates zieht der Adopter aus dem vendored regelwerk, nicht per Auto-Clobber. Keine
// --lang-Substitution — die Commands sind sprach-agnostisch.
//
// Ein liegender Command wird nicht gemeldet: dieses Ziel kennt keinen notice-Kanal, und eine
// Anleitung, die der Adopter ohnehin selbst pflegt, braucht keine Zeile pro Lauf.
func Commands(targetDir string) error {
	for _, f := range commandFiles() {
		content, err := commandsFS.ReadFile(f.src)
		if err != nil {
			return fmt.Errorf("%s einbetten: %w", f.src, err)
		}
		if err := writeEnforceFile(targetDir, f, content, io.Discard); err != nil {
			return err
		}
	}
	return nil
}

// CommandFile liefert den eingebetteten Inhalt einer Command-Quelle an ihrem
// Ziel-Relpfad (fuer Tests/Inspektion). Leerer slice, falls dst unbekannt.
func CommandFile(dst string) []byte {
	for _, f := range commandFiles() {
		if f.dst == dst {
			content, err := commandsFS.ReadFile(f.src)
			if err != nil {
				return nil
			}
			return content
		}
	}
	return nil
}
