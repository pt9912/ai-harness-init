// Package wire platziert das generierte Sprachskelett (slice-023, gestaged unter
// .harness/skeleton/) in den Ziel-Root. REINER Placer (slice-034/035): es schreibt die
// Skelett-Dateien (Code-Gate-Fragment harness/mk/<lang>.mk, Dockerfile, go.mod,
// .golangci.yml, cmd/app/main.go) VERBATIM. Die Root-Makefile (der Aggregator) und die
// sprach-agnostischen Fragmente (doc-gate/baseline/enforce) kommen aus den Init-Emittern
// (emit.Makefile/DocGate/BaselineVerify/Enforce), NICHT aus wire — seit slice-035 traegt
// das Skelett keine Root-Makefile mehr. Einen Merge gibt es nicht (ADR-0005).
//
// Warum Phase-4-Placement aus dem Staging und nicht direkt an den Root: die
// slice-025-Garantie „Kollision -> kein Teil-Bootstrap" haelt nur, wenn das
// Root-Skelett ERST in Phase 4 erscheint (nach allen Pre-Flights). Targets() liefert
// dem Phase-3-Pre-Flight die Root-Ziele; Place() schreibt sie in Phase 4.
package wire

import (
	"errors"
	"fmt"
	"io/fs"
	"os"
	"path/filepath"
	"sort"
)

// Targets liefert die Ziel-Relpfade, die Place() in den Ziel-Root schreiben wuerde
// — die Skelett-Dateien in stagingDir, relativ zu stagingDir, sortiert. Fuer den
// Bootstrap-Pre-Flight (cmd, Phase 3): eine Kollision faellt so VOR dem Platzieren
// auf, und die slice-025-Garantie „kein Teil-Bootstrap" haelt.
func Targets(stagingDir string) ([]string, error) {
	var rels []string
	err := filepath.WalkDir(stagingDir, func(p string, d fs.DirEntry, walkErr error) error {
		if walkErr != nil {
			return walkErr
		}
		if d.IsDir() {
			return nil
		}
		rel, relErr := filepath.Rel(stagingDir, p)
		if relErr != nil {
			return relErr
		}
		rels = append(rels, filepath.ToSlash(rel))
		return nil
	})
	if err != nil {
		return nil, err
	}
	sort.Strings(rels)
	return rels, nil
}

// Place platziert die gestagten Skelett-Dateien VERBATIM in targetDir (Ziel-Root) —
// reiner Placer. SKIP-IF-PRESENT (slice-038, ADR-0007): Skelett-Code (main.go, go.mod,
// Dockerfile, .golangci.yml) ist Adopter-Boden — eine vorhandene (adopter-gewachsene)
// Datei wird beim idempotenten Re-Lauf NIE ueberschrieben, nur fehlende geschrieben.
// Danach wird stagingDir entfernt (transientes Staging, nicht ein Ziel-Verzeichnis —
// kein Prune von Adopter-Inhalt).
func Place(stagingDir, targetDir string) error {
	rels, err := Targets(stagingDir)
	if err != nil {
		return err
	}
	for _, rel := range rels {
		dst := filepath.Join(targetDir, filepath.FromSlash(rel))
		// skip-if-present: vorhandene Skelett-Datei nie clobbern.
		switch _, statErr := os.Stat(dst); {
		case statErr == nil:
			continue
		case !errors.Is(statErr, fs.ErrNotExist):
			return fmt.Errorf("%s pruefen: %w", rel, statErr)
		}
		content, readErr := os.ReadFile(filepath.Join(stagingDir, filepath.FromSlash(rel)))
		if readErr != nil {
			return fmt.Errorf("%s lesen: %w", rel, readErr)
		}
		if err := os.MkdirAll(filepath.Dir(dst), 0o755); err != nil {
			return fmt.Errorf("%s anlegen: %w", filepath.Dir(rel), err)
		}
		if err := os.WriteFile(dst, content, 0o644); err != nil {
			return fmt.Errorf("%s schreiben: %w", rel, err)
		}
	}
	if err := os.RemoveAll(stagingDir); err != nil {
		return fmt.Errorf("staging %s aufraeumen: %w", stagingDir, err)
	}
	return nil
}
