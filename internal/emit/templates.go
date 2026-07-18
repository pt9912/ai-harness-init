package emit

import (
	"embed"
	"errors"
	"fmt"
	"io/fs"
	"os"
	"path/filepath"
	"strings"
)

// skel traegt den eingebetteten, in-scope Template-Baum (LH-FA-02). Die
// Set-Index-README des Sets ist bewusst NICHT eingebettet -> wird nie emittiert.
// Quelle (bei Baseline-Bump re-syncen): .harness/baseline/<tag>/templates/ — der
// Drift-Waechter TestEmit_MatchesVendoredSource haelt Embed == vendored fest.
//
//go:embed skel
var skel embed.FS

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

// Templates legt die Template-Baseline zweiklassig in targetDir ab (LH-FA-02):
// Singletons -> <ziel>.md (Template-Hinweis-Block gestrippt, <Projektname>
// gestempelt), Wiederkehrende -> co-located .template.md (verbatim). name leer ->
// <Projektname> bleibt Platzhalter (Content-Urteil des Menschen). Ohne force wird
// eine vorhandene Zieldatei nicht ueberschrieben (LH-FA-01 Boundary-AC).
func Templates(targetDir, name string, force bool) error {
	plan, err := planTemplates(name)
	if err != nil {
		return err
	}
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

// planTemplates klassifiziert den eingebetteten Baum in Ziel-Pfad -> Inhalt.
func planTemplates(name string) (map[string][]byte, error) {
	out := map[string][]byte{}
	err := fs.WalkDir(skel, "skel", func(path string, d fs.DirEntry, walkErr error) error {
		if walkErr != nil {
			return walkErr
		}
		if d.IsDir() {
			return nil
		}
		content, readErr := skel.ReadFile(path)
		if readErr != nil {
			return fmt.Errorf("skel %s lesen: %w", path, readErr)
		}
		rel := strings.TrimPrefix(path, "skel/")
		if isRecurring(filepath.Base(rel)) {
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
