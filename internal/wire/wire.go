// Package wire verdrahtet das generierte Sprachskelett (slice-023, gestaged unter
// .harness/skeleton/) in den Ziel-Root: es platziert die Skelett-Dateien und
// bindet d-check.mk ins generierte Makefile ein (MR-010) — sodass im Zielrepo EIN
// make gates-Einstiegspunkt entsteht statt zweier Gate-Quellen (slice-004b,
// LH-FA-04 Verdrahten-Teil). Einen Merge gibt es nicht (ADR-0005: der Generator
// besitzt Makefile/Dockerfile/go.mod, es gibt keine Konfliktdateien).
//
// Warum Phase-4-Placement aus dem Staging und nicht direkt an den Root: die
// slice-025-Garantie „Kollision -> kein Teil-Bootstrap" haelt nur, wenn das
// Root-Skelett ERST in Phase 4 erscheint (nach allen Pre-Flights). Targets() liefert
// dem Phase-3-Pre-Flight die Root-Ziele; Place() schreibt sie in Phase 4.
package wire

import (
	"bytes"
	"errors"
	"fmt"
	"io/fs"
	"os"
	"path/filepath"
	"sort"
)

const skeletonMakefile = "Makefile"

// dCheckInclude wird ans generierte Makefile angehaengt: `include d-check.mk`
// bringt das Doc-Gate-Target docs-check herein, und `gates: docs-check` haengt es
// an das bestehende `gates: lint build test` — Make KOMBINIERT die Prerequisites,
// solange hoechstens eine Regel ein Recipe traegt (die gen-gates-Regel hat keins).
// So haengen Code- und Doc-Gate an EINEM make gates (MR-010, DoD slice-004b).
const dCheckInclude = "\n# Doc-Gate (d-check.mk) einbinden — ein make gates statt zweier Quellen\n" +
	"# (MR-010, verdrahtet von ai-harness-init, slice-004b).\ninclude d-check.mk\ngates: docs-check\n"

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

// Place platziert die gestagten Skelett-Dateien in targetDir (Ziel-Root) und bindet
// d-check.mk ins Makefile ein. Danach wird stagingDir entfernt (transientes
// Staging — sonst traegt das Zielrepo zwei Makefiles). Ohne force wird eine
// vorhandene Zieldatei nicht ueberschrieben (LH-FA-01 Boundary; der Phase-3-
// Pre-Flight prueft das bereits, hier als Verteidigung).
func Place(stagingDir, targetDir string, force bool) error {
	rels, err := Targets(stagingDir)
	if err != nil {
		return err
	}
	// Vorbedingung: das Skelett MUSS ein Makefile mit gates-Target tragen — sonst
	// haengt sich `gates: docs-check` an nichts und definiert gates OHNE die
	// Go-Gates (still leere Verdrahtung statt „ein make gates"). Laut abbrechen.
	mk, err := os.ReadFile(filepath.Join(stagingDir, skeletonMakefile))
	if err != nil {
		return fmt.Errorf("skelett-Makefile lesen: %w", err)
	}
	if !bytes.Contains(mk, []byte("\ngates:")) && !bytes.HasPrefix(mk, []byte("gates:")) {
		return errors.New("skelett-Makefile hat kein gates-Target — d-check.mk-Include haette nichts zu verdrahten (MR-010)")
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
		if rel == skeletonMakefile {
			content = append(content, dCheckInclude...)
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
