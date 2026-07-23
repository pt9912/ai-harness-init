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
// reiner Placer (kein Makefile-Rewrite, keine Makefile-Vorbedingung mehr: die Root-
// Makefile kommt seit slice-035 aus emit.Makefile, nicht aus dem Skelett). Danach wird
// stagingDir entfernt (transientes Staging). Ohne force wird eine vorhandene Zieldatei
// nicht ueberschrieben (LH-FA-01 Boundary; der Phase-3-Pre-Flight prueft das bereits).
func Place(stagingDir, targetDir string, force bool) error {
	rels, err := Targets(stagingDir)
	if err != nil {
		return err
	}
	// Kollisions-VORPASS: alle Ziele pruefen, BEVOR eines geschrieben wird — kein
	// Teil-Placement bei Kollision (konsistent mit emit.Templates/slice-025).
	if !force {
		for _, rel := range rels {
			switch _, statErr := os.Stat(filepath.Join(targetDir, filepath.FromSlash(rel))); {
			case statErr == nil:
				return fmt.Errorf("%s existiert bereits (--force zum Ueberschreiben)", rel)
			case !errors.Is(statErr, fs.ErrNotExist):
				return fmt.Errorf("%s pruefen: %w", rel, statErr)
			}
		}
	}
	for _, rel := range rels {
		content, readErr := os.ReadFile(filepath.Join(stagingDir, filepath.FromSlash(rel)))
		if readErr != nil {
			return fmt.Errorf("%s lesen: %w", rel, readErr)
		}
		dst := filepath.Join(targetDir, filepath.FromSlash(rel))
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
