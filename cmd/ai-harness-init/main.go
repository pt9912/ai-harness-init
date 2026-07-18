// Command ai-harness-init bootstrappt ein bestehendes Git-Repo mit dem
// AI-Harness-Prozess. Dieser Skeleton-Stand (slice-001a) implementiert den
// Arg-Parser mit den korrekten Fehlerpfaden; die Bootstrap-Wirkung (Templates,
// Doc-Gate, Sprachskelett) folgt in slice-002/003.
package main

import (
	"flag"
	"fmt"
	"io"
	"os"
)

const usage = `ai-harness-init — bootstrappt ein Git-Repo mit dem AI-Harness-Prozess.

Verwendung:
  ai-harness-init --lang <sprache> [--name <name>] [--force]

Flags:
  --lang        Zielsprache (Pflicht)
  --name        Projektname (optional)
  --force       bestehende Dateien überschreiben (optional)
  -h, --help    diese Hilfe anzeigen
`

// run parst die Argumente und liefert den Exit-Code. Ein-/Ausgabe sind
// injiziert, damit die Fehlerpfade ohne Prozess-Exit testbar sind (slice-001a).
func run(args []string, stdout, stderr io.Writer) int {
	fs := flag.NewFlagSet("ai-harness-init", flag.ContinueOnError)
	fs.SetOutput(io.Discard) // Ausgabe/Streams steuern wir selbst

	lang := fs.String("lang", "", "Zielsprache (Pflicht)")
	_ = fs.String("name", "", "Projektname")
	_ = fs.Bool("force", false, "bestehende Dateien überschreiben")

	switch err := fs.Parse(args); {
	case err == flag.ErrHelp:
		// --help / -h → Usage auf stdout, Exit 0.
		fmt.Fprint(stdout, usage)
		return 0
	case err != nil:
		// unbekanntes Flag u. a. → Usage auf stderr, Exit 2.
		fmt.Fprintln(stderr, "Fehler:", err)
		fmt.Fprint(stderr, usage)
		return 2
	}

	if *lang == "" {
		// fehlendes --lang → Usage auf stderr, Exit 2 (LH-FA-01 Negative-AC).
		fmt.Fprintln(stderr, "Fehler: --lang ist erforderlich.")
		fmt.Fprint(stderr, usage)
		return 2
	}

	// Stub: die Bootstrap-Wirkung folgt in slice-002/003.
	fmt.Fprintf(stdout, "ai-harness-init: --lang=%s — Bootstrap noch nicht implementiert (slice-002/003).\n", *lang)
	return 0
}

func main() {
	os.Exit(run(os.Args[1:], os.Stdout, os.Stderr))
}
