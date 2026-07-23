// Command ai-harness-init bootstrappt ein bestehendes Git-Repo mit dem
// AI-Harness-Prozess. bootstrap() fuehrt die Kette in drei Phasen aus:
// (1) Sprachskelett deterministisch generieren (slice-023) -> (2) Baseline
// vendoren (slice-022a) -> (3) emittieren (Doc-Gate, Verifier, Template-Baseline,
// Durchsetzung, Commands, Aggregator, Skelett-Verdrahtung).
//
// IDEMPOTENZ-KLASSIFIKATION (slice-038, ADR-0007): das Pre-Flight-refuse-Modell
// (slice-025) ist gefallen. Jede emittierte Datei traegt genau eine Klasse —
// KONVERGENT (tool-eigene Infrastruktur: bei jedem Lauf kanonisch neu geschrieben,
// heilt Drift/Baseline-Bump, prunt nie) oder SKIP-IF-PRESENT (Adopter-Boden:
// Doc-Chain/README/Skelett-Code, nur geschrieben wenn abwesend, nie clobbern). Ein
// zweiter Lauf ist damit IDEMPOTENT (Exit 0), ohne --force und ohne Refuse. Die
// Klassen leben in den Emittern (internal/emit, internal/wire, internal/fetch).
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
	"strings"
	"time"

	"github.com/pt9912/ai-harness-init/internal/emit"
	"github.com/pt9912/ai-harness-init/internal/fetch"
	"github.com/pt9912/ai-harness-init/internal/gen"
	"github.com/pt9912/ai-harness-init/internal/wire"
)

const usage = `ai-harness-init — bootstrappt ein Git-Repo mit dem AI-Harness-Prozess.

Verwendung:
  ai-harness-init [--lang <sprache>] [--name <name>]
  ai-harness-init add-lang <sprache> <pfad>

Der Init-Lauf ist IDEMPOTENT (ADR-0007): ein zweiter Lauf ist Exit 0 — tool-eigene
Infrastruktur wird kanonisch neu geschrieben (heilt Drift), adopter-gefuellte Dateien
(Doc-Chain, README, Skelett-Code) bleiben unberuehrt. Kein --force noetig, kein Refuse.

Init-Flags:
  --lang        Zielsprache (optional; ohne → sprach-agnostischer Init, doc-only-Gate).
                --lang <X> = Init + ein add-lang(<X>, .) als One-Shot-Kurzform.
  --name        Projektname (optional)
  -h, --help    diese Hilfe anzeigen

Subkommando add-lang <sprache> <pfad>:
  Fuegt einem bereits gebootstrappten Repo ein Sprachmodul hinzu (WIEDERHOLBAR, Mono-Repo):
  Skelett unter <pfad> + Code-Gate-Fragment harness/mk/<modul>.mk + blocked/<sprache>.
  <pfad>=. verortet am Repo-Root.

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
	// Subkommando-Dispatch (slice-037): `add-lang <sprache> <pfad>` ist der wiederholbare
	// Mono-Repo-Pfad; alles andere ist der Default-Init. Die Unterscheidung steht VOR dem
	// Flag-Parsing, weil add-lang Positionsargumente traegt, der Init nur Flags.
	if len(args) > 0 && args[0] == "add-lang" {
		return runAddLang(args[1:], targetDir, stdout, stderr)
	}

	fs := flag.NewFlagSet("ai-harness-init", flag.ContinueOnError)
	fs.SetOutput(io.Discard) // Ausgabe/Streams steuern wir selbst

	lang := fs.String("lang", "", "Zielsprache (optional)")
	name := fs.String("name", "", "Projektname")

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
	return bootstrap(targetDir, *lang, *name, src, stdout, stderr)
}

const addLangUsage = `ai-harness-init add-lang <sprache> <pfad>

Fuegt einem bereits gebootstrappten Repo ein Sprachmodul hinzu (WIEDERHOLBAR, Mono-Repo):
generiert das Skelett unter <pfad>, dropt das Code-Gate-Fragment harness/mk/<modul>.mk
(Build-Kontext <pfad>) und das blocked/<sprache>-Fragment. Mehrere Aufrufe ergeben ein
Mono-Repo. <pfad>=. verortet am Repo-Root. Idempotent (ADR-0007): das Fragment/blocked
wird konvergent kanonisch geschrieben, vorhandener Skelett-Code bleibt unberuehrt.

Argumente:
  <sprache>   Zielsprache (gen-Profil; z.B. go)
  <pfad>      Zielort des Moduls (. = Repo-Root)
`

// runAddLang parst `add-lang <sprache> <pfad>` und liefert den Exit-Code (0 = Erfolg,
// 2 = Aufruf-Fehler, 1 = Laufzeit-Fehler). Genau zwei Positionsargumente, keine Flags.
func runAddLang(args []string, targetDir string, stdout, stderr io.Writer) int {
	if len(args) == 1 && (args[0] == "-h" || args[0] == "--help") {
		fmt.Fprint(stdout, addLangUsage)
		return 0
	}
	if len(args) != 2 || strings.HasPrefix(args[0], "-") || strings.HasPrefix(args[1], "-") {
		fmt.Fprintln(stderr, "Fehler: add-lang braucht genau <sprache> und <pfad>")
		fmt.Fprint(stderr, addLangUsage)
		return 2
	}
	// add-lang <sprache> <pfad>: args[0]=sprache(lang), args[1]=pfad(path). addLang
	// nimmt (targetDir, path, lang, …) — daher path=args[1], lang=args[0].
	return addLang(targetDir, args[1], args[0], stdout, stderr)
}

// addLang fuehrt das add-lang-Subkommando aus (slice-037/038, wiederholbar/Mono-Repo,
// idempotent): Skelett generieren -> platzieren (skip-if-present) + Fragment + blocked
// (beide konvergent). Kein Pre-Flight-refuse mehr (slice-038): die Idempotenz-Klassen
// erledigen das Kollisions-Handling je Datei. Netzlos: add-lang setzt einen bereits
// gebootstrappten Aggregator voraus (Root-Makefile mit include harness/mk/*.mk).
func addLang(targetDir, path, lang string, stdout, stderr io.Writer) int {
	// Containment (Review-M-1): <pfad> ist das erste nutzer-kontrollierte Ziel, das
	// wire.Place erreicht. Ein absoluter Pfad oder ein `..`-Ausbruch schriebe Skelett-
	// Dateien AUS dem Ziel-Repo heraus. Fail-fast mit Exit 2, bevor etwas generiert wird.
	if clean := filepath.ToSlash(filepath.Clean(path)); filepath.IsAbs(path) || clean == ".." || strings.HasPrefix(clean, "../") {
		fmt.Fprintln(stderr, "Fehler: <pfad> muss innerhalb des Repos liegen (kein absoluter Pfad, kein ..).")
		return 2
	}
	// Vorbedingung: der Aggregator (Root-Makefile) muss existieren — sonst wird das
	// Fragment nicht verdrahtet (kein `make gates`). Freundlicher Abbruch statt Halbstand.
	switch _, err := os.Stat(filepath.Join(targetDir, emit.MakefilePath)); {
	case errors.Is(err, fs.ErrNotExist):
		fmt.Fprintln(stderr, "Fehler: kein Aggregator ("+emit.MakefilePath+") — zuerst `ai-harness-init` (Init) im Repo laufen lassen.")
		return 1
	case err != nil:
		fmt.Fprintln(stderr, "Fehler:", err)
		return 1
	}

	goVersion := envOr("SKEL_GO_VERSION", gen.DefaultGoVersion)
	skelDir := filepath.Join(targetDir, ".harness", "skeleton")
	// Skelett generieren — fail-fast Sprach-Validierung (unbekannt -> Exit 2 mit Liste).
	if err := gen.Generate(skelDir, lang, goVersion); err != nil {
		fmt.Fprintln(stderr, "Fehler:", err)
		return langExitCode(err)
	}
	if err := wireLang(targetDir, skelDir, path, lang, goVersion); err != nil {
		fmt.Fprintln(stderr, "Fehler:", err)
		return 1
	}
	fmt.Fprintf(stdout, "ai-harness-init: add-lang %s nach %s — Skelett + harness/mk/%s.mk + %s.\n",
		lang, path, gen.ModuleName(path, lang), emit.BlockedFragmentPath(lang))
	return 0
}

// wireLang platziert das gestagte Skelett am Zielort <pfad> (skip-if-present: Skelett-Code
// ist Adopter-Boden) und ergaenzt sein Code-Gate-Fragment (harness/mk/<modul>.mk, konvergent
// — kanonisch neu geschrieben) + das blocked/<lang>-Fragment (konvergent). Gemeinsamer Kern
// des --lang-One-Shots (Phase 4, <pfad>=".") und des add-lang-Subkommandos (beliebiger <pfad>).
func wireLang(targetDir, skelDir, path, lang, goVersion string) error {
	if err := wire.Place(skelDir, filepath.Join(targetDir, filepath.FromSlash(path))); err != nil {
		return err
	}
	frag, err := gen.CodeGateFragment(lang, path, goVersion)
	if err != nil {
		return err
	}
	// Das Code-Gate-Fragment ist KONVERGENT (slice-038): kanonisch neu schreiben
	// (os.WriteFile ueberschreibt), kein Refuse, 0644 (kein Exec-Bit -> kein Chmod noetig).
	fragRel := filepath.Join("harness", "mk", gen.ModuleName(path, lang)+".mk")
	dst := filepath.Join(targetDir, fragRel)
	if err := os.MkdirAll(filepath.Dir(dst), 0o755); err != nil {
		return fmt.Errorf("%s anlegen: %w", filepath.ToSlash(filepath.Dir(fragRel)), err)
	}
	if err := os.WriteFile(dst, []byte(frag), 0o644); err != nil {
		return fmt.Errorf("%s schreiben: %w", filepath.ToSlash(fragRel), err)
	}
	return emit.BlockedFragment(targetDir, lang)
}

// bootstrap fuehrt die Kette in drei Phasen aus (Ueberblick im Package-Doc): (1) Skelett
// generieren, (2) Baseline holen (konvergent), (3) emittieren (jede Datei mit ihrer
// Idempotenz-Klasse). Seit slice-038 gibt es keinen Pre-Flight-refuse mehr; die
// Fehlerpfade DRUCKEN UND RETURNEN im selben Block (der Beobachtungswert ist an die
// Wirkung gebunden — eine Mutation, die nur den Abbruch entfernt, entfernt auch die Meldung).
func bootstrap(targetDir, lang, name string, src sources, stdout, stderr io.Writer) int {
	tag := envOr("COURSE_TAG", fetch.DefaultTag)
	skelDir := filepath.Join(targetDir, ".harness", "skeleton")
	goVersion := envOr("SKEL_GO_VERSION", gen.DefaultGoVersion)
	baseDir := baselineDir(targetDir)
	ctx, cancel := context.WithTimeout(context.Background(), 120*time.Second)
	defer cancel()

	// --lang optional (slice-035, ADR-0007): ohne Sprache laeuft der Bootstrap
	// sprach-agnostisch — kein Skelett (gen/wire entfallen), aber Aggregator + die
	// sprach-agnostischen Fragmente + Durchsetzung werden emittiert, `make gates` ist
	// doc-only gruen (docs-check + baseline-verify + record-gates).
	hasLang := lang != ""

	// Phase 1 — Skelett ZUERST deterministisch generieren (ADR-0005 Tool-als-Quelle;
	// kein Netz) — das validiert die Sprache fail-fast (unbekannt -> Exit 2 mit Profil-
	// Liste; die --lang-Validierung hing bis slice-023 am Skelett-Fetch und darf nicht
	// ersatzlos verschwinden). Kein Pre-Flight-refuse mehr (slice-038): die Idempotenz-
	// Klassen erledigen das Kollisions-Handling je Datei, ein Re-Lauf ist idempotent.
	//
	// Go-Version: gepinnter Default, per SKEL_GO_VERSION explizit ueberschreibbar
	// (deterministisch — der Nutzer nennt den Wert).
	if hasLang {
		if err := gen.Generate(skelDir, lang, goVersion); err != nil {
			fmt.Fprintln(stderr, "Fehler:", err)
			return langExitCode(err)
		}
	}

	// Phase 2 — Baseline holen (LH-FA-09, sha256-Pin vor dem Entpacken). KONVERGENT
	// (slice-038): ein vorhandenes <tag>-Verzeichnis wird durch die kanonische Fassung
	// ersetzt (heilt Baseline-Bump), kein Refuse.
	if err := fetch.Baseline(ctx, baseDir, tag, src.baselineSHA, src.baseline); err != nil {
		fmt.Fprintln(stderr, "Fehler:", err)
		return 1
	}

	// Phase 3 — Emit. DocGate ZUERST (Docker-Lauf = reales Fehlerrisiko), dann Verifier,
	// Templates usw. Jede Datei traegt ihre Idempotenz-Klasse (slice-038, ADR-0007):
	// konvergent (tool-Infra, kanonisch neu) oder skip-if-present (Adopter-Boden, nie
	// clobbern). Ein zweiter Lauf ist damit idempotent (Exit 0), ohne Pre-Flight-refuse.
	opts := emit.Options{
		Image:  envOr("DCHECK_IMAGE", emit.DefaultImage),
		Digest: envOr("DCHECK_DIGEST", emit.DefaultDigest),
	}
	if err := emitAll(targetDir, skelDir, tag, name, lang, goVersion, hasLang, opts); err != nil {
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

// emitAll fuehrt die Emit-Schritte (Phase 3) aus: Doc-Gate, Verifier, Templates, README,
// Durchsetzung, Commands und den Aggregator (immer) — und nur mit Sprache die Skelett-
// Verdrahtung. Jeder Emitter traegt seine Idempotenz-Klasse (slice-038): konvergent
// (Enforce/Makefile/BaselineVerify/DocGate-Fragmente) oder skip-if-present (Templates/
// README/Commands/Skelett). Erste fehlgeschlagene Stufe gewinnt; bootstrap druckt den
// Fehler einmal. DocGate zuerst (Docker-Lauf = reales Fehlerrisiko).
func emitAll(targetDir, skelDir, tag, name, lang, goVersion string, hasLang bool, opts emit.Options) error {
	if err := emit.DocGate(context.Background(), targetDir, opts); err != nil {
		return err
	}
	if err := emit.BaselineVerify(targetDir); err != nil {
		return err
	}
	if err := emit.Templates(os.DirFS(templatesDir(targetDir, tag)), targetDir, name); err != nil {
		return err
	}
	// Root-README (slice-005): eigenes Ziel README.md, aus dem Templates-Emit ausgeschlossen.
	if err := emit.RootReadme(os.DirFS(templatesDir(targetDir, tag)), targetDir, name); err != nil {
		return err
	}
	// Durchsetzung (slice-031/032): Gate-Nachweis + Stop-Hook + Command-Guard + awk +
	// .harness/.gitignore. SPRACH-AGNOSTISCH (slice-037): der Guard traegt den Boden
	// gebacken; das Sprach-Set (blocked/<lang>) droppt wireLang unten, nicht Enforce.
	if err := emit.Enforce(targetDir); err != nil {
		return err
	}
	// Workflow-Commands (slice-033): die Slash-Command-Anleitung, sprach-agnostisch.
	if err := emit.Commands(targetDir); err != nil {
		return err
	}
	// Aggregator-Root-Makefile (slice-035, Init-Emitter) — IMMER, auch sprachlos: sie
	// bindet die Gate-Fragmente per Glob ein (`make gates`).
	if err := emit.Makefile(targetDir); err != nil {
		return err
	}
	// Verdrahten (slice-037): das gestagte Skelett am Root platzieren + sein Code-Gate-
	// Fragment (harness/mk/<lang>.mk) + blocked/<lang> droppen — der --lang-One-Shot ist
	// Init + ein addLang(<pfad>="."). NUR mit Sprache; ohne --lang gibt es kein Skelett.
	if hasLang {
		if err := wireLang(targetDir, skelDir, ".", lang, goVersion); err != nil {
			return err
		}
	}
	return nil
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
