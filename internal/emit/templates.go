package emit

import (
	"errors"
	"fmt"
	"io/fs"
	"os"
	"path"
	"path/filepath"
	"strings"
)

// isRecurring markiert die fuenf wiederkehrenden Templates (LH-FA-02): sie bleiben
// verbatim als co-located .template.md, aus denen der Adopter je Artefakt kopiert.
func isRecurring(base string) bool {
	switch base {
	case "NNNN-titel.template.md", "slice.template.md", "welle.template.md",
		"carveout.template.md", "review-report.template.md":
		return true
	}
	return false
}

// (Bis slice-026 haing checkRoot an dem HART VERDRAHTETEN Namen
// "AGENTS.template.md" — ein Upstream-Rename haette den Bootstrap mit
// irrefuehrender Meldung gebrochen, Review-Befund slice-022b N-4. Die Pruefung
// ist jetzt STRUKTURELL und kommt ohne Dateinamen aus.)

// checkRoot prueft POSITIV, dass src am templates/-Verzeichnis gewurzelt ist.
//
// Der Leer-Guard in Templates reicht dafuer nicht (Review-Befund slice-022b F-2):
// eine VORFAHREN-Wurzelung (etwa `.harness/baseline/<tag>/` statt dessen
// `templates/`) ist nicht leer — sie liefert sogar MEHR Treffer — und umgeht
// zugleich beide Ausschluesse aus inScope, weil die am FS-Root verankert sind
// (`project-readme.template.md` hiesse dann `templates/project-readme.template.md`).
// Das Ergebnis waere ein Emit mit zu vielen Dateien und ohne Fehler. Lieber laut
// abbrechen, als eine plausible Falsch-Wurzelung durchzulassen.
//
// Das Merkmal ist die TIEFE, nicht ein Name: am templates/-Verzeichnis liegt
// mindestens ein in-scope-Template DIREKT an der Wurzel; eine Ebene darueber
// liegt dort keins (dort stehen nur die Verzeichnisse regelwerk/ und templates/).
// Das unterscheidet exakt die Falsch-Wurzelung, um die es geht, und ueberlebt
// jedes Upstream-Rename.
//
// KOPPLUNG, die beim Aendern zaehlt: der Wurzel-Nachweis nutzt dieselbe
// inScope-Regel wie der Emit. Ein bestandener checkRoot garantiert damit
// mindestens einen Plan-Eintrag — der frueher hier stehende `len(plan) == 0`-Guard
// war dadurch UNERREICHBAR und ist entfallen (Review-Befund slice-022b N-1: der
// Test, der ihn zu pruefen behauptete, sicherte im Rumpf das Gegenteil zu).
func checkRoot(src fs.FS) error {
	entries, err := fs.ReadDir(src, ".")
	if err != nil {
		return fmt.Errorf("quell-wurzel lesen: %w", err)
	}
	for _, e := range entries {
		if !e.IsDir() && inScope(e.Name()) {
			return nil
		}
	}
	return errors.New("quelle ist nicht am templates/-Verzeichnis gewurzelt: an ihrer Wurzel liegt kein in-scope-Template (eine Ebene zu hoch?)")
}

// inScope entscheidet, welche Datei des Kurs-Template-Satzes der Bootstrap als
// Doc-Template-Schicht emittiert (LH-FA-02).
//
// Bis slice-022b existierte diese Regel NICHT im Code: der eingebettete Baum war
// beim Einbetten von Hand vorgefiltert, und ihre einzige Formulierung stand im
// Drift-Waechter test/skel-drift.bats. Mit dem Wechsel auf die gefetchte Quelle
// (die den VOLLEN Satz traegt) muss sie explizit sein.
//
// Bewusst als REGEL, nicht als aufgezaehlte Allowlist: ein upstream neu
// hinzugekommenes Template fliesst damit automatisch mit. Genau die Klasse
// "Baseline gebumpt, Emit nicht nachgezogen" bewachte die Vollstaendigkeits-Achse
// des geloeschten Drift-Waechters — sie verschwindet hier strukturell, statt
// einen Ersatz-Sensor zu brauchen.
func inScope(rel string) bool {
	switch {
	case !strings.HasSuffix(rel, ".template.md"):
		// Traegt der Satz auch: .d-check.yml (das Tool AUTORIERT seine eigene,
		// minimale — emit.DocGate), Makefile (Ziel-Form, gehoert zum Skelett-
		// Generator) und die Set-Index-README.md (nie ein Ziel-Artefakt).
		return false
	case rel == "project-readme.template.md":
		return false // Root-README: LH-FA-05, eigener Emit-Schritt (slice-005)
	case strings.HasPrefix(rel, ".harness/skills/"):
		return false // Durchsetzungsschicht: LH-FA-06/ADR-0004, eigener Emit-Schritt
	default:
		return true
	}
}

// Templates legt die Template-Baseline zweiklassig in targetDir ab (LH-FA-02):
// Singletons -> <ziel>.md (Template-Hinweis-Block gestrippt, <Projektname>
// gestempelt), Wiederkehrende -> co-located .template.md (verbatim). name leer ->
// <Projektname> bleibt Platzhalter (Content-Urteil des Menschen). Ohne force wird
// eine vorhandene Zieldatei nicht ueberschrieben (LH-FA-01 Boundary-AC).
//
// src ist der Kurs-Template-Satz, gewurzelt am templates/-Verzeichnis — seit
// slice-022b die vom Bootstrap GEFETCHTE Baseline des Ziels statt eines
// eingebetteten Duplikats (ADR-0005: eine Quelle, der Kurs). Injiziert als fs.FS,
// damit die Tests hermetisch bleiben: der reale Baum liegt unter .harness/, das
// der Docker-Build-Kontext ausschliesst (.dockerignore) — genau der Grund, warum
// der alte Drift-Waechter nach bats musste.
func Templates(src fs.FS, targetDir, name string, force bool) error {
	if err := checkRoot(src); err != nil {
		return err
	}
	plan, err := planTemplates(src, name)
	if err != nil {
		return err
	}
	// Leere Quelle -> laut abbrechen. Ein falsch gewurzeltes src emittierte sonst
	// stillschweigend NICHTS und meldete Erfolg (LH-QA-01: kein stilles Gruen).
	if !force {
		for rel := range plan {
			switch _, statErr := os.Stat(filepath.Join(targetDir, rel)); {
			case statErr == nil:
				return fmt.Errorf("%s existiert bereits (--force zum Ueberschreiben)", rel)
			case !errors.Is(statErr, fs.ErrNotExist):
				return fmt.Errorf("%s pruefen: %w", rel, statErr)
			}
		}
	}
	for rel, content := range plan {
		dst := filepath.Join(targetDir, rel)
		if err := os.MkdirAll(filepath.Dir(dst), 0o755); err != nil {
			return fmt.Errorf("%s anlegen: %w", filepath.Dir(rel), err)
		}
		if err := os.WriteFile(dst, content, 0o644); err != nil {
			return fmt.Errorf("%s schreiben: %w", rel, err)
		}
	}
	return nil
}

// planTemplates klassifiziert den Quell-Baum in Ziel-Pfad -> Inhalt.
func planTemplates(src fs.FS, name string) (map[string][]byte, error) {
	out := map[string][]byte{}
	err := fs.WalkDir(src, ".", func(rel string, d fs.DirEntry, walkErr error) error {
		if walkErr != nil {
			return walkErr
		}
		if d.IsDir() || !inScope(rel) {
			return nil
		}
		content, readErr := fs.ReadFile(src, rel)
		if readErr != nil {
			return fmt.Errorf("template %s lesen: %w", rel, readErr)
		}
		if isRecurring(path.Base(rel)) {
			out[rel] = content // verbatim, co-located
			return nil
		}
		out[singletonTarget(rel)] = []byte(stampName(StripHintBlock(string(content)), name))
		return nil
	})
	if err != nil {
		return nil, err
	}
	return out, nil
}

// singletonTarget bildet einen Singleton-Template-Pfad auf sein .md-Ziel ab.
func singletonTarget(rel string) string {
	// Die Roadmap lebt unter in-progress/ — die emittierte planning/README.md
	// verweist dorthin; ein Ziel in planning/ liesse ihren Link brechen.
	if rel == "docs/plan/planning/roadmap.template.md" {
		return "docs/plan/planning/in-progress/roadmap.md"
	}
	return strings.TrimSuffix(rel, ".template.md") + ".md"
}

// stampName ersetzt den <Projektname>-Platzhalter, falls ein Name gesetzt ist.
func stampName(s, name string) string {
	if name == "" {
		return s
	}
	return strings.ReplaceAll(s, "<Projektname>", name)
}

// StripHintBlock entfernt den `> **Template-Hinweis.** …`-Blockquote (samt einer
// folgenden Leerzeile) aus einem Singleton — die Datei wird ein echtes Repo-File,
// keine Vorlage mehr. Ohne Marker unveraendert. Annahme (Review-L1): der Hinweis ist
// ein eigenstaendiger, blank-getrennter Blockquote (so in allen 10 Singletons) — ein
// ohne Leerzeile angeklebter Content-Blockquote waere markdown-semantisch derselbe
// Block und wuerde mitentfernt; die vendored Vorlagen halten diese Trennung ein.
func StripHintBlock(s string) string {
	lines := strings.Split(s, "\n")
	start := -1
	for i, ln := range lines {
		if strings.HasPrefix(ln, ">") && strings.Contains(ln, "Template-Hinweis") {
			start = i
			break
		}
	}
	if start < 0 {
		return s
	}
	end := start
	for end < len(lines) && strings.HasPrefix(lines[end], ">") {
		end++
	}
	if end < len(lines) && strings.TrimSpace(lines[end]) == "" {
		end++ // die Leerzeile nach dem Block mitnehmen
	}
	out := make([]string, 0, len(lines))
	out = append(out, lines[:start]...)
	out = append(out, lines[end:]...)
	return strings.Join(out, "\n")
}
