// Command ai-harness-init bootstrappt ein bestehendes Git-Repo mit dem
// AI-Harness-Prozess. run() fuehrt fuenf schreibende Schritte aus: Sprachskelett
// stagen (slice-004a) -> Baseline vendoren (slice-022a) -> Verifier emittieren
// (slice-022a) -> Doc-Gate emittieren (slice-002) -> Template-Baseline ablegen
// (slice-003).
//
// OFFENER PUNKT (Review-Befund slice-022a I1, vierte Wiederholung der Klasse):
// die Kette hat KEINEN gemeinsamen Pre-Flight. Scheitert Schritt n, bleiben die
// Ergebnisse von 1..n-1 im Zielrepo liegen. Die einzelnen Schritte sind je fuer
// sich atomar (fetch.Baseline via Temp->Rename, emit.DocGate via Pre-Check vor
// dem Schreiben) — die Luecke ist die Kette, nicht das Glied. Aufloesung ist
// slice-004b (Init-Flow) zugewiesen.
package main

import (
	"context"
	"errors"
	"flag"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"time"

	"github.com/pt9912/ai-harness-init/internal/emit"
	"github.com/pt9912/ai-harness-init/internal/fetch"
)

const usage = `ai-harness-init — bootstrappt ein Git-Repo mit dem AI-Harness-Prozess.

Verwendung:
  ai-harness-init --lang <sprache> [--name <name>] [--force]

Flags:
  --lang        Zielsprache (Pflicht)
  --name        Projektname (optional)
  --force       bestehende Dateien überschreiben (optional)
  -h, --help    diese Hilfe anzeigen

Umgebung (bewusster Opt-in-Override der gepinnten Werte — LH-QA-02):
  COURSE_TAG        Kurs-Version für Skelett und Baseline
  BASELINE_SHA256   erwarteter sha256 des Baseline-Assets
  DCHECK_IMAGE      d-check-Tag-Referenz
  DCHECK_DIGEST     d-check-Digest (sticht den Tag)
`

// sources buendelt die injizierbaren Netz-Quellen des Bootstraps samt dem
// erwarteten Baseline-Pin. Als Struct (nicht als Parameter-Liste), damit die
// Folge-Slices die run()-Signatur nicht bei jeder neuen Quelle erneut brechen.
type sources struct {
	skeleton    fetch.TarballFetch // Sprachskelett (slice-004a; loest slice-023 ab)
	baseline    fetch.AssetFetch   // Regelwerk + Templates (LH-FA-09)
	baselineSHA string             // erwarteter sha256 des Baseline-Assets (LH-QA-02)
}

// run parst die Argumente und liefert den Exit-Code. Ein-/Ausgabe, Zielverzeichnis
// und die Netz-Quellen sind injiziert, damit die Fehler- und Emit-Pfade ohne
// Prozess-Exit, ohne CWD-Mutation und ohne Netz testbar sind. Exit-Codes:
// 0 = Erfolg, 2 = Aufruf-/Argument-Fehler (Usage), 1 = Emit-Fehler zur Laufzeit.
func run(args []string, targetDir string, src sources, stdout, stderr io.Writer) int {
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

	// Sprachskelett ZUERST holen (slice-004a, ADR-0001 Variante C): das validiert die
	// Sprache fail-fast und vermeidet einen Doc-Gate-Teil-Emit, falls der Fetch scheitert
	// (Review-L3). Staging nach .harness/skeleton/; der Merge in den Root ist slice-004b.
	// Der Fetcher ist injiziert (netzlose Exit-Pfad-Tests, Review-M2). Braucht Netz
	// (Bootstrap-Abhaengigkeit); unbekannte Sprache -> Exit 2, Netz-/Extrakt-Fehler -> Exit 1.
	tag := envOr("COURSE_TAG", fetch.DefaultTag)
	skelDir := filepath.Join(targetDir, ".harness", "skeleton")
	ctx, cancel := context.WithTimeout(context.Background(), 120*time.Second)
	defer cancel()
	if err := fetch.Skeleton(ctx, skelDir, *lang, tag, src.skeleton); err != nil {
		fmt.Fprintln(stderr, "Fehler:", err)
		return fetchExitCode(err)
	}

	// Baseline (Regelwerk + Templates) als vendored Stand des Ziels ablegen
	// (slice-022a, LH-FA-09; ADR-0005 Herkunftsklasse "Fetch Kurs-SSoT"). Der
	// sha256 wird VOR dem Entpacken geprueft; scheitert er, wird begruendet
	// NICHT emittiert statt eine erfundene Baseline zu schreiben. Danach ist das
	// Zielrepo ueber seine Baseline netzlos (MR-007 fuers Ziel gespiegelt).
	baseDir := filepath.Join(targetDir, ".harness", "baseline")
	if err := fetch.Baseline(ctx, baseDir, tag, src.baselineSHA, *force, src.baseline); err != nil {
		fmt.Fprintln(stderr, "Fehler:", err)
		return 1
	}
	// Der zugehoerige Verifier — ohne ihn waere die Baseline zwar abgelegt, aber
	// nicht netzlos PRUEFBAR (LH-FA-09 Pruefsummen-AC).
	if err := emit.BaselineVerify(targetDir, *force); err != nil {
		fmt.Fprintln(stderr, "Fehler:", err)
		return 1
	}

	// Doc-Gate-Baseline emittieren (slice-002): d-check.mk zur Laufzeit via
	// `docker run <d-check> --print-mk`; Pin per Env ueberschreibbar. Emit-Fehler
	// (vorhandene Datei ohne --force, docker nicht verfuegbar) -> Exit 1.
	opts := emit.Options{
		Image:  envOr("DCHECK_IMAGE", emit.DefaultImage),
		Digest: envOr("DCHECK_DIGEST", emit.DefaultDigest),
		Force:  *force,
	}
	if err := emit.DocGate(context.Background(), targetDir, opts); err != nil {
		fmt.Fprintln(stderr, "Fehler:", err)
		return 1
	}
	// Template-Baseline zweiklassig ablegen (slice-003) — Quelle ist seit
	// slice-022b die eben gefetchte Baseline des Ziels, nicht mehr ein
	// eingebettetes Duplikat (ADR-0005: eine Quelle, der Kurs). Der
	// Baseline-Schritt oben MUSS deshalb vorher gelaufen sein.
	tmplFS := os.DirFS(filepath.Join(baseDir, tag, "templates"))
	if err := emit.Templates(tmplFS, targetDir, *name, *force); err != nil {
		fmt.Fprintln(stderr, "Fehler:", err)
		return 1
	}

	fmt.Fprintf(stdout, "ai-harness-init: Bootstrap (Skelett %q gestaged + Baseline %s vendored + Doc-Gate + Template-Baseline) — --lang=%s.\n", *lang, tag, *lang)
	return 0
}

// envOr liefert den Wert der Umgebungsvariable key oder def, wenn sie leer/ungesetzt ist.
func envOr(key, def string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return def
}

// fetchExitCode bildet einen Fetch-Fehler auf den Exit-Code ab: unbekannte Sprache =
// Aufruf-Fehler (2), sonst Netz-/Extrakt-Fehler (1). Rein/netzlos testbar (Review-M2).
func fetchExitCode(err error) int {
	if err == nil {
		return 0
	}
	var ule *fetch.UnknownLangError
	if errors.As(err, &ule) {
		return 2
	}
	return 1
}

func main() {
	wd, err := os.Getwd()
	if err != nil {
		fmt.Fprintln(os.Stderr, "Fehler: Arbeitsverzeichnis nicht bestimmbar:", err)
		os.Exit(1)
	}
	src := sources{
		skeleton:    fetch.DownloadTarball,
		baseline:    fetch.DownloadBaseline,
		baselineSHA: envOr("BASELINE_SHA256", fetch.DefaultBaselineSHA256),
	}
	os.Exit(run(os.Args[1:], wd, src, os.Stdout, os.Stderr))
}
