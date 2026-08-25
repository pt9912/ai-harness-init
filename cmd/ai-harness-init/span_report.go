// Das Unterkommando `span-report` rechnet aus dem Span-Bestand eine Token-Bilanz je
// Rolle. Es laeuft auf dem HOST (ADR-0022 Festlegung 2) ueber dem gitignorierten
// Zustands-Bereich des Repos, in dem es aufgerufen wird.
//
// Es ist KEIN Gate — eine Bilanz prueft nichts, sie rechnet (LH-QA-01).

package main

import (
	"fmt"
	"io"
	"os"
	"path/filepath"

	"github.com/pt9912/ai-harness-init/internal/report"
	"github.com/pt9912/ai-harness-init/internal/span"
)

// spanReport ist der testbare Kern: Argumente rein, Text raus, Exit-Code zurueck.
func spanReport(args []string, out, errOut io.Writer) int {
	dir, err := spanDir(args)
	if err != nil {
		fmt.Fprintf(errOut, "span-report: %v\n", err)
		return 1
	}
	b, err := report.Aggregiere(dir)
	if err != nil {
		fmt.Fprintf(errOut, "span-report: %v\n", err)
		return 1
	}
	fmt.Fprint(out, report.Schreibe(b))
	return 0
}

// spanDir loest den Ablageort auf: ein Argument sticht, sonst der Ablageort unter der
// Repo-Wurzel des Arbeitsverzeichnisses — derselbe Ort, an den das
// Schreiber-Unterkommando anhaengt (span.Dir).
//
// Ohne Wurzel MELDET der Bericht, waehrend der Schreiber am selben Punkt still
// zurueckkehrt. Der Unterschied ist der Aufrufer: den Schreiber ruft ein Hook, der
// nicht gestoert werden darf; den Bericht ruft ein Mensch, der sonst eine leere
// Bilanz fuer eine Aussage haelt.
func spanDir(args []string) (string, error) {
	if len(args) > 0 && args[0] != "" {
		return args[0], nil
	}
	wd, err := os.Getwd()
	if err != nil {
		return "", err
	}
	root, ok := span.FindRoot(wd)
	if !ok {
		return "", fmt.Errorf("keine Repo-Wurzel ueber %s — Ablageort als Argument nennen", wd)
	}
	return filepath.Join(root, span.Dir), nil
}
