// Command ai-harness-init bootstrappt ein bestehendes Git-Repo mit dem
// AI-Harness-Prozess. run() fuehrt die Bootstrap-Kette in vier Phasen aus:
// (1) Pre-Flight der Fetch-Ziele -> (2) Fetch (Sprachskelett stagen slice-004a +
// Baseline vendoren slice-022a) -> (3) Pre-Flight ALLER Emit-Ziele (inkl.
// Template-Plan aus der gefetchten Baseline) -> (4) emittieren (Doc-Gate
// slice-002, Verifier slice-022a, Template-Baseline slice-003).
//
// Der gemeinsame Pre-Flight (slice-025) loest die viermal wiederholte
// Teil-Bootstrap-Klasse (slice-002/003/004a/022a): kollidiert IRGENDEIN
// Kettenziel ohne --force, schreibt der jeweilige Block NICHTS, statt dass ein
// spaeter Schritt mitten in der Kette scheitert und die frueheren Ergebnisse
// liegen bleiben. Gewaehltes Modell: Pre-Flight (Vorbedingungen pruefen), NICHT
// Staging->Commit (Kette atomar machen) — Details und die ehrliche Grenze
// (Runtime-Abbruch WAEHREND eines Fetch/Docker-Laufs) an run().
package main

import (
	"context"
	"errors"
	"flag"
	"fmt"
	"io"
	"io/fs"
	"os"
	"path/filepath"
	"time"

	"github.com/pt9912/ai-harness-init/internal/emit"
	"github.com/pt9912/ai-harness-init/internal/fetch"
	"github.com/pt9912/ai-harness-init/internal/gen"
	"github.com/pt9912/ai-harness-init/internal/wire"
)

const usage = `ai-harness-init — bootstrappt ein Git-Repo mit dem AI-Harness-Prozess.

Verwendung:
  ai-harness-init [--lang <sprache>] [--name <name>] [--force]

Flags:
  --lang        Zielsprache (optional; ohne → sprach-agnostischer Init, doc-only-Gate)
  --name        Projektname (optional)
  --force       bestehende Dateien überschreiben (optional)
  -h, --help    diese Hilfe anzeigen

Umgebung (bewusster Opt-in-Override der gepinnten Werte — LH-QA-02):
  COURSE_TAG        Kurs-Version für die Baseline (Regelwerk + Templates)
  BASELINE_SHA256   erwarteter sha256 des Baseline-Assets
  DCHECK_IMAGE      d-check-Tag-Referenz
  DCHECK_DIGEST     d-check-Digest (sticht den Tag)
  SKEL_GO_VERSION   Go-Version des generierten Skeletts (Default gepinnt, deterministisch)
`

// sources buendelt die injizierbare Netz-Quelle des Bootstraps — nur noch die
// Baseline; das Sprachskelett generiert internal/gen lokal (slice-023, ADR-0005
// Tool-als-Quelle) — samt dem erwarteten Baseline-Pin. Als Struct, damit die
// Folge-Slices die run()-Signatur nicht bei jeder neuen Quelle erneut brechen.
type sources struct {
	baseline    fetch.AssetFetch // Regelwerk + Templates (LH-FA-09)
	baselineSHA string           // erwarteter sha256 des Baseline-Assets (LH-QA-02)
}

// run parst die Argumente und liefert den Exit-Code. Ein-/Ausgabe, Zielverzeichnis
// und die Netz-Quellen sind injiziert, damit die Fehler- und Emit-Pfade ohne
// Prozess-Exit, ohne CWD-Mutation und ohne Netz testbar sind. Exit-Codes:
// 0 = Erfolg, 2 = Aufruf-/Argument-Fehler (Usage), 1 = Emit-Fehler zur Laufzeit.
func run(args []string, targetDir string, src sources, stdout, stderr io.Writer) int {
	fs := flag.NewFlagSet("ai-harness-init", flag.ContinueOnError)
	fs.SetOutput(io.Discard) // Ausgabe/Streams steuern wir selbst

	lang := fs.String("lang", "", "Zielsprache (optional)")
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

	// --lang ist OPTIONAL (slice-035, ADR-0007): fehlt es, laeuft der Bootstrap
	// sprach-agnostisch (doc-only-Gate, kein Skelett). Der fruehere Exit 2 (LH-FA-01
	// Negative-AC „fehlt --lang") ist mit ADR-0007 gefallen. Unbekannte Sprache und
	// unbekannte Flags liefern weiter Exit 2 (via bootstrap/Parse).
	return bootstrap(targetDir, *lang, *name, *force, src, stdout, stderr)
}

// bootstrap fuehrt die Kette in vier Phasen aus (Ueberblick im Package-Doc). Die
// Pre-Flights DRUCKEN UND RETURNEN im selben Block: der Beobachtungswert (die
// Fehlermeldung) ist damit an die Wirkung (der Abbruch) gebunden — eine Mutation,
// die nur den Abbruch entfernt, entfernt auch die Meldung. Ein frueherer
// reportPreflight-Helfer trennte beides und liess den Print auch dann laufen, wenn
// der Abbruch neutralisiert war; die Emit-Pre-Flight-Mutation blieb dadurch still
// gruen (slice-025-Befund, von `make mutate` gefangen — genau sein Zweck).
func bootstrap(targetDir, lang, name string, force bool, src sources, stdout, stderr io.Writer) int {
	tag := envOr("COURSE_TAG", fetch.DefaultTag)
	skelDir := filepath.Join(targetDir, ".harness", "skeleton")
	baseDir := baselineDir(targetDir)
	ctx, cancel := context.WithTimeout(context.Background(), 120*time.Second)
	defer cancel()

	// --lang optional (slice-035, ADR-0007): ohne Sprache laeuft der Bootstrap
	// sprach-agnostisch — kein Skelett (gen/wire entfallen), aber Aggregator + die
	// sprach-agnostischen Fragmente + Durchsetzung werden emittiert, `make gates` ist
	// doc-only gruen (docs-check + baseline-verify + record-gates).
	hasLang := lang != ""

	// Phase 1 — Pre-Flight der Fetch-Ziele. .harness/skeleton nur mit Sprache (sonst
	// generiert Phase 2 kein Skelett). Kollidiert eines ohne --force, wird NICHTS geholt.
	fetchTargets := []string{".harness/baseline/" + tag}
	if hasLang {
		fetchTargets = append([]string{".harness/skeleton"}, fetchTargets...)
	}
	if !force {
		if err := preflightAbsent(targetDir, fetchTargets); err != nil {
			fmt.Fprintln(stderr, "Fehler:", err)
			return 1
		}
	}

	// Phase 2 — Generieren + Fetch: das Sprachskelett ZUERST deterministisch
	// generieren (ADR-0005 Tool-als-Quelle; kein Netz) — das validiert die Sprache
	// fail-fast (unbekannt -> Exit 2 mit Profil-Liste; die --lang-Validierung hing
	// bis slice-023 am Skelett-Fetch und darf nicht ersatzlos verschwinden) —, dann
	// die Baseline holen (LH-FA-09, sha256-Pin vor dem Entpacken). Beide schreiben
	// nach .harness/; der Baseline-Fetch ist retry-freundlich gewollt (s. EHRLICHE
	// GRENZE Phase 4).
	//
	// Go-Version: gepinnter Default, per SKEL_GO_VERSION explizit ueberschreibbar
	// (deterministisch — der Nutzer nennt den Wert). Der Web-"latest"-Lookup und ein
	// go-freshness-Sensor sind bewusst eigene Folge-Slices (Netz/Nicht-Determinismus).
	if hasLang {
		if err := gen.Generate(skelDir, lang, envOr("SKEL_GO_VERSION", gen.DefaultGoVersion)); err != nil {
			fmt.Fprintln(stderr, "Fehler:", err)
			return langExitCode(err)
		}
	}
	if err := fetch.Baseline(ctx, baseDir, tag, src.baselineSHA, force, src.baseline); err != nil {
		fmt.Fprintln(stderr, "Fehler:", err)
		return 1
	}

	// Phase 3 — Pre-Flight ALLER Emit-Ziele (Verifier, Doc-Gate, Templates aus der
	// gefetchten Baseline, dabei wurzel-geprueft). Kollidiert eines ohne --force,
	// schreibt KEIN Emit-Schritt — die Teil-Bootstrap-Klasse ist geschlossen.
	rels, err := emitTargets(targetDir, tag, name, hasLang)
	if err != nil {
		fmt.Fprintln(stderr, "Fehler:", err)
		return 1
	}
	if !force {
		if err := preflightAbsent(targetDir, rels); err != nil {
			fmt.Fprintln(stderr, "Fehler:", err)
			return 1
		}
	}

	// Phase 4 — Emit. DocGate ZUERST (Docker-Lauf = reales Fehlerrisiko, schreibt
	// bei Fehler nichts), dann Verifier, dann Templates (ADR-0005: eine Quelle).
	//
	// EHRLICHE GRENZE (Pre-Flight, slice-025 §6): ein Runtime-Abbruch WAEHREND
	// Fetch/Docker kann das gefetchte .harness/ zuruecklassen — retry-freundlich
	// gewollt, nicht die verworfene Staging->Commit-Atomaritaet. --force
	// ueberschreibt statt zu sichern; ein Fehler danach rollt das nicht zurueck.
	opts := emit.Options{
		Image:  envOr("DCHECK_IMAGE", emit.DefaultImage),
		Digest: envOr("DCHECK_DIGEST", emit.DefaultDigest),
		Force:  force,
	}
	if err := emitAll(targetDir, skelDir, tag, name, lang, hasLang, force, opts); err != nil {
		fmt.Fprintln(stderr, "Fehler:", err)
		return 1
	}

	langNote := "sprach-agnostisch (doc-only Gate)"
	if hasLang {
		langNote = "--lang=" + lang + " (Skelett verdrahtet)"
	}
	fmt.Fprintf(stdout, "ai-harness-init: Bootstrap (Baseline %s vendored + Doc-Gate + Aggregator + Durchsetzung + Template-Baseline) — %s.\n", tag, langNote)
	return 0
}

// emitAll fuehrt die Emit-Schritte (Phase 4) aus: Doc-Gate, Verifier, Templates, README,
// Durchsetzung, Commands und den Aggregator (immer) — und nur mit Sprache die Skelett-
// Verdrahtung. Erste fehlgeschlagene Stufe gewinnt; bootstrap druckt den Fehler einmal.
// Ausgelagert aus bootstrap gegen die gocognit-Schwelle (slice-035); die Pre-Flights
// bleiben bewusst in bootstrap (ihr Print+Return ist an die Wirkung gebunden, slice-025).
// DocGate zuerst (Docker-Lauf = reales Fehlerrisiko, schreibt bei Fehler nichts).
func emitAll(targetDir, skelDir, tag, name, lang string, hasLang, force bool, opts emit.Options) error {
	if err := emit.DocGate(context.Background(), targetDir, opts); err != nil {
		return err
	}
	if err := emit.BaselineVerify(targetDir, force); err != nil {
		return err
	}
	if err := emit.Templates(os.DirFS(templatesDir(targetDir, tag)), targetDir, name, force); err != nil {
		return err
	}
	// Root-README (slice-005): eigenes Ziel README.md, aus dem Templates-Emit ausgeschlossen.
	if err := emit.RootReadme(os.DirFS(templatesDir(targetDir, tag)), targetDir, name, force); err != nil {
		return err
	}
	// Durchsetzung (slice-031/032): Gate-Nachweis + Stop-Hook + Command-Guard + awk +
	// .harness/.gitignore. Der Guard blockt die Host-Toolchain je lang (sprachlos = Boden).
	if err := emit.Enforce(targetDir, lang, force); err != nil {
		return err
	}
	// Workflow-Commands (slice-033): die Slash-Command-Anleitung, sprach-agnostisch.
	if err := emit.Commands(targetDir, force); err != nil {
		return err
	}
	// Aggregator-Root-Makefile (slice-035, Init-Emitter) — IMMER, auch sprachlos: sie
	// bindet die Gate-Fragmente per Glob ein (`make gates`).
	if err := emit.Makefile(targetDir, force); err != nil {
		return err
	}
	// Verdrahten (slice-004b/034): das gestagte Skelett an den Ziel-Root platzieren
	// (reiner Placer). NUR mit Sprache — ohne --lang gibt es kein Skelett (slice-035).
	if hasLang {
		if err := wire.Place(skelDir, targetDir, force); err != nil {
			return err
		}
	}
	return nil
}

// preflightAbsent meldet den ERSTEN rel-Pfad unter targetDir, der bereits
// existiert — der gemeinsame Pre-Flight der Bootstrap-Kette (slice-025). rels
// sind slash-Pfade relativ zu targetDir. Ohne diesen Pre-Flight schreibt ein
// spaeter Kettenschritt in ein Ziel, dessen Kollision erst mitten in der Kette
// auffaellt, und die frueheren Schritte bleiben liegen.
func preflightAbsent(targetDir string, rels []string) error {
	for _, rel := range rels {
		switch _, err := os.Stat(filepath.Join(targetDir, filepath.FromSlash(rel))); {
		case err == nil:
			return fmt.Errorf("%s existiert bereits (--force zum Ueberschreiben)", rel)
		case !errors.Is(err, fs.ErrNotExist):
			return fmt.Errorf("%s pruefen: %w", rel, err)
		}
	}
	return nil
}

// emitTargets sammelt die Ziel-Relpfade aller Emit-Schritte (Verifier, Doc-Gate,
// Templates) fuer den Pre-Flight aus Phase 3. Die Template-Ziele kommen aus der
// gefetchten Baseline; emit.TemplateTargets wurzel-prueft sie zugleich (eine
// falsch gewurzelte Baseline faellt so VOR dem Docker-Lauf auf).
func emitTargets(targetDir, tag, name string, hasLang bool) ([]string, error) {
	rels := []string{emit.BaselineVerifyPath, emit.BaselineMkPath, ".d-check.yml", "d-check.mk", emit.DocGateMkPath, emit.MakefilePath, emit.RootReadmePath}
	// Durchsetzungs-Mechanik (slice-031, LH-FA-06/ADR-0006): Gate-Nachweis +
	// Stop-Hook. In DENSELBEN Pre-Flight — eine vorhandene .claude/settings.json
	// (Adopter hat schon Claude-Hooks) faellt so VOR dem Emit auf, kein Teil-Bootstrap.
	rels = append(rels, emit.EnforcePaths()...)
	// Workflow-Commands (slice-033, LH-FA-08/ADR-0006): die Slash-Command-Anleitung
	// (.claude/commands/). Eigene Klasse (Anleitung ≠ Durchsetzung), aber DERSELBE
	// Pre-Flight — eine vorhandene .claude/commands/… faellt so VOR dem Emit auf.
	rels = append(rels, emit.CommandPaths()...)
	tt, err := emit.TemplateTargets(os.DirFS(templatesDir(targetDir, tag)), name)
	if err != nil {
		return nil, err
	}
	rels = append(rels, tt...)
	// Die Skelett-Ziele (slice-004b) NUR mit Sprache (slice-035): ohne --lang generiert
	// Phase 2 kein Skelett und wire.Place laeuft nicht — seine Ziele gehoeren dann nicht
	// in den Pre-Flight. Mit Sprache in DENSELBEN Pre-Flight, damit eine Kollision
	// (z.B. ein vorhandenes go.mod) nichts Teil-Bootstrappt (slice-025).
	if hasLang {
		st, err := wire.Targets(filepath.Join(targetDir, ".harness", "skeleton"))
		if err != nil {
			return nil, err
		}
		rels = append(rels, st...)
	}
	return rels, nil
}

// baselineDir und templatesDir halten das Ziel-Layout an EINER Stelle: die
// vendored Baseline liegt unter .harness/baseline/<tag>/, der Kurs-Template-Satz
// in deren templates/. Als Funktionen (statt inline zusammengesetzt), damit die
// Wurzelung eine Zusicherung bekommt — sie hatte vorher keine, und ein falsch
// gewurzeltes emit.Templates faellt sonst erst im Ziel auf (Review-Befund
// slice-022b F-3).
func baselineDir(targetDir string) string {
	return filepath.Join(targetDir, ".harness", "baseline")
}

func templatesDir(targetDir, tag string) string {
	return filepath.Join(baselineDir(targetDir), tag, "templates")
}

// envOr liefert den Wert der Umgebungsvariable key oder def, wenn sie leer/ungesetzt ist.
func envOr(key, def string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return def
}

// langExitCode bildet einen Generator-Fehler auf den Exit-Code ab: unbekannte
// Sprache = Aufruf-Fehler (2, gen.UnknownLangError), sonst Emit-Fehler (1).
// Rein/netzlos testbar.
func langExitCode(err error) int {
	if err == nil {
		return 0
	}
	var ule *gen.UnknownLangError
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
		baseline:    fetch.DownloadBaseline,
		baselineSHA: envOr("BASELINE_SHA256", fetch.DefaultBaselineSHA256),
	}
	os.Exit(run(os.Args[1:], wd, src, os.Stdout, os.Stderr))
}
