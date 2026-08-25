package emit

import (
	"embed"
	"fmt"
)

// agentsFS traegt die tool-AUTORIERTEN Rollen-Typen (LH-FA-10, ADR-0022 Festlegung 3):
// je eine Datei fuer die sechs kanonischen Rollen des Harness-Prozesses. Sie sind der
// Typ, unter dem eine Rolle startbar ist — die Workflow-Commands (commands.go) sagen,
// WIE eine Rolle laeuft, diese Dateien sagen, WER laeuft.
//
// GENERISCH, NICHT KOPIERT: der emittierte Text beschreibt einen KONTEXT-ZUSCHNITT
// (Eingang, Ausgang, Abgrenzung, Grenze), keinen Inhalt dieses Repos. Kennungen und
// Pfade, die nur hier existieren, waeren im Ziel Falschaussagen; die fuenf Klassen, in
// denen das auftritt, misst TestAgents_KeineRepoEigenenBezuege.
//
// SPRACH-AGNOSTISCH: eine Rolle ist ein Prozess-Zuschnitt, kein --lang-Zweig.
//
//go:embed all:templates/agents
var agentsFS embed.FS

// canonicalRoles sind die sechs Rollen der Rollen-Sequenz (Modul 8: Planner →
// Architect → Implementation → Reviewer → Verifier → Validator) in ihrer Reihenfolge.
// Der Name IST der Vertrag: die Erfassungsschicht fuellt die Rollen-Achse eines Laufs
// aus dem Agenten-Typ, und nur diese sechs Werte ergeben ein besetztes Feld (ADR-0022
// Festlegung 3). Ein Typ unter anderem Namen laeuft, traegt aber ein leeres Feld —
// leer heisst unbekannt, nie rollenlos.
func canonicalRoles() []string {
	return []string{"planner", "architect", "implementer", "reviewer", "verifier", "validator"}
}

// CanonicalRoles liefert die sechs Rollen-Namen in der Reihenfolge der Rollen-Sequenz
// (fuer Tests/Inspektion).
func CanonicalRoles() []string { return canonicalRoles() }

// agentFiles bildet jede eingebettete Typ-Quelle auf ihren Ziel-Relpfad ab. Ziel ist
// .claude/agents/ (vom Agenten-Werkzeug fixiert), die Typen sind reine .md-Dateien
// mit Frontmatter (0644). Quell- und Ziel-Basisname sind der Rollen-Name selbst.
func agentFiles() []enforceFile {
	roles := canonicalRoles()
	files := make([]enforceFile, 0, len(roles))
	for _, role := range roles {
		files = append(files, enforceFile{
			src:  "templates/agents/" + role + ".md",
			dst:  ".claude/agents/" + role + ".md",
			mode: 0o644,
		})
	}
	return files
}

// AgentPaths liefert die Ziel-Relpfade der Rollen-Typen — dieselbe Rolle wie
// CommandPaths fuer die Workflow-Commands: eine Liste, die den Ziel-Layout-Vertrag an
// EINER Stelle haelt, statt ihn ueber die Aufrufer zu verteilen.
func AgentPaths() []string {
	files := agentFiles()
	paths := make([]string, 0, len(files))
	for _, f := range files {
		paths = append(paths, f.dst)
	}
	return paths
}

// Agents schreibt die Rollen-Typen nach targetDir — SKIP-IF-PRESENT (ADR-0007
// Festlegung 3, ADR-0022 Festlegung 4): ein Rollen-Typ ist ein Text, den der Adopter an
// sein Repo anpasst, und ein Re-Lauf setzt eine angepasste Datei nicht zurueck. Die
// fehlenden Typen schreibt derselbe Lauf.
//
// UNBEDINGT: die Typen haengen an keinem Laufzeit-Ausgang — anders als Traeger, Wrapper
// und Hook-Eintrag (ADR-0022 Festlegung 5). Ein Ziel ohne Erfassungsschicht bekommt sie
// trotzdem; sie machen die Rollen startbar, und das gilt auch ohne Traeger.
//
// Kein --lang-Zweig: die Rollen-Sequenz ist in jedem Ziel dieselbe.
func Agents(targetDir string) error {
	for _, f := range agentFiles() {
		content, err := agentsFS.ReadFile(f.src)
		if err != nil {
			return fmt.Errorf("%s einbetten: %w", f.src, err)
		}
		if err := writeSkipIfPresent(targetDir, f.dst, content, f.mode); err != nil {
			return err
		}
	}
	return nil
}

// AgentFile liefert den eingebetteten Inhalt einer Typ-Quelle an ihrem Ziel-Relpfad
// (fuer Tests/Inspektion). Leerer slice, falls dst unbekannt.
func AgentFile(dst string) []byte {
	for _, f := range agentFiles() {
		if f.dst == dst {
			content, err := agentsFS.ReadFile(f.src)
			if err != nil {
				return nil
			}
			return content
		}
	}
	return nil
}
