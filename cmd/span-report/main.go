// Command span-report rechnet aus dem Span-Bestand eine Token-Bilanz je Rolle.
//
// EIGENES Binary, KEIN Subkommando von ai-harness-init: was der emittierte
// Harness bekommt, entscheidet der Slice der Tool-Ebene, nicht dieses Kommando.
//
// Es ist KEIN Gate — eine Bilanz prueft nichts, sie rechnet (LH-QA-01).
package main

import (
	"fmt"
	"io"
	"os"

	"github.com/pt9912/ai-harness-init/internal/report"
)

// spanDir ist der Ablageort im Container; das make-Ziel mountet den Bestand dorthin.
const spanDir = "/spans"

func main() {
	os.Exit(lauf(os.Args[1:], os.Stdout, os.Stderr))
}

// lauf ist der testbare Kern: Argumente rein, Text raus, Exit-Code zurueck.
func lauf(args []string, out, errOut io.Writer) int {
	dir := spanDir
	if len(args) > 0 && args[0] != "" {
		dir = args[0]
	}

	b, err := report.Aggregiere(dir)
	if err != nil {
		fmt.Fprintf(errOut, "span-report: %v\n", err)
		return 1
	}
	fmt.Fprint(out, report.Schreibe(b))
	return 0
}
