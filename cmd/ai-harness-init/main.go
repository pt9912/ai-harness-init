// Command ai-harness-init bootstrappt ein bestehendes Git-Repo mit dem
// AI-Harness-Prozess. Der Arg-Parser (slice-001a) tragt die korrekten
// Fehlerpfade; slice-002 verdrahtet den ersten Emit-Schritt (Doc-Gate-Baseline).
// Weitere Bootstrap-Wirkung (Templates, Sprachskelett) folgt in slice-003 ff.
package main

import (
	"context"
	"flag"
	"fmt"
	"io"
	"os"

	"github.com/pt9912/ai-harness-init/internal/emit"
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

// run parst die Argumente und liefert den Exit-Code. Ein-/Ausgabe und das
// Zielverzeichnis sind injiziert, damit die Fehler- und Emit-Pfade ohne
// Prozess-Exit und ohne CWD-Mutation testbar sind. Exit-Codes: 0 = Erfolg,
// 2 = Aufruf-/Argument-Fehler (Usage), 1 = Emit-Fehler zur Laufzeit.
func run(args []string, targetDir string, stdout, stderr io.Writer) int {
	fs := flag.NewFlagSet("ai-harness-init", flag.ContinueOnError)
	fs.SetOutput(io.Discard) // Ausgabe/Streams steuern wir selbst

	lang := fs.String("lang", "", "Zielsprache (Pflicht)")
	name := fs.String("name", "", "Projektname")
	force := fs.Bool("force", false, "bestehende Dateien überschreiben")

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

	// Erster Bootstrap-Schritt (slice-002): Doc-Gate-Baseline emittieren. d-check.mk
	// wird zur Laufzeit via `docker run <d-check> --print-mk` erzeugt (Docker ist die
	// geforderte Bootstrap-Abhaengigkeit); der Pin ist per Env ueberschreibbar (Opt-in).
	// Emit-Fehler (vorhandene Datei ohne --force, docker/d-check nicht verfuegbar) →
	// Exit 1 auf stderr, kein Usage-Dump (kein Aufruf-Fehler).
	opts := emit.Options{
		Image:  envOr("DCHECK_IMAGE", emit.DefaultImage),
		Digest: envOr("DCHECK_DIGEST", emit.DefaultDigest),
		Force:  *force,
	}
	if err := emit.DocGate(context.Background(), targetDir, opts); err != nil {
		fmt.Fprintln(stderr, "Fehler:", err)
		return 1
	}
	// Template-Baseline zweiklassig ablegen (slice-003): Singletons -> .md
	// (gestempelt), Wiederkehrende -> co-located .template.md.
	if err := emit.Templates(targetDir, *name, *force); err != nil {
		fmt.Fprintln(stderr, "Fehler:", err)
		return 1
	}

	fmt.Fprintf(stdout, "ai-harness-init: Bootstrap emittiert (Doc-Gate + Template-Baseline) — --lang=%s.\n", *lang)
	return 0
}

// envOr liefert den Wert der Umgebungsvariable key oder def, wenn sie leer/ungesetzt ist.
func envOr(key, def string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return def
}

func main() {
	wd, err := os.Getwd()
	if err != nil {
		fmt.Fprintln(os.Stderr, "Fehler: Arbeitsverzeichnis nicht bestimmbar:", err)
		os.Exit(1)
	}
	os.Exit(run(os.Args[1:], wd, os.Stdout, os.Stderr))
}
