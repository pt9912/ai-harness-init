package gen

import "strings"

// DefaultGoVersion ist der gepinnte Go-Toolchain-Default des generierten Skeletts
// (LH-QA-02: kein floating). An das Repo-Dockerfile gekoppelt
// (TestGoProfile_PinsMatchRepo), damit ein Bump nicht die eine Haelfte bewegt und
// die andere vergisst. Ueberschreibbar beim Bootstrap (SKEL_GO_VERSION, cmd) — der
// Generator selbst bleibt deterministisch: gleiche version -> byte-identische
// Ausgabe.
const DefaultGoVersion = "1.27.0"

// golangciVersion ist der gepinnte golangci-lint-Tag des generierten Skeletts.
const golangciVersion = "v2.13.1"

// goProfile ist das Go-SKELETT fuer die gegebene Go-Version (ADR-0003 Docker-only):
// Go-Gates als Dockerfile-Stages; dazu go.mod + .golangci.yml und ein baubares
// cmd/app/main.go. Das Code-Gate-Fragment (harness/mk/<modul>.mk) gehoert seit
// slice-037 NICHT mehr ins Skelett — es ist <pfad>-aware (Build-Kontext + modul-scoped
// Targets fuer Mono-Repo) und kommt aus gen.CodeGateFragment, das der Emitter am
// Zielort platziert; das Skelett selbst ist ortsunabhaengig. Die Root-Makefile (der
// sprach-agnostische Aggregator) emittiert seit slice-035 emit.Makefile, NICHT das
// Skelett — der Aggregator gehoert in die Init-Phase.
//
// Die Images sind TAG-gepinnt (golang:<ver>, golangci-lint:<ver>) — kein floating
// (LH-QA-02), aber bewusst OHNE Digest: ein Digest wuerde die Go-Version
// festnageln und den GO_VERSION-Knopf wirkungslos machen. go (major.minor) in
// go.mod leitet sich aus version ab, damit die Sprachversion zur Toolchain passt.
func goProfile(version, arch string) map[string]string {
	return composeSkeleton(goScaffolding, goRole, version, arch)
}

// goScaffolding — die arch-INVARIANTE Go-Bau-/Toolchain-Gerueestung: Modul-Manifest,
// Dockerfile (die Gate-Stages test/lint/build) und Lint-Config. Immer praesent,
// unabhaengig vom Arch-Layout (sonst braeche der Code-Gate-Lauf mangels Stages).
func goScaffolding(version string) map[string]string {
	return map[string]string{
		"go.mod":        "module app\n\ngo " + majorMinor(version) + "\n",
		"Dockerfile":    render(goDockerfileTmpl, version),
		".golangci.yml": goGolangci,
	}
}

// goRole rendert eine Code-Rolle als Go-Datei(en). Flach: Entry-Point -> cmd/app/main.go,
// Test-Rolle -> nil (main.go ist trivial). hexSlice (slice-045a, ADR-0009): die vier
// Schicht-Rollen + der Composition Root rendern in die kanonischen Verzeichnisse
// (internal/hexagon/{domain,application}, internal/adapters/{driving,driven}, cmd/app).
// Die Import-Richtungen sind inward-only (app->domain, app->ports_inbound,
// app->ports_outbound, ports_outbound->domain, driving_adapters->ports_inbound,
// driven_adapters->domain); die getriebenen Adapter (driven) erfuellen die Ports
// strukturell (kein Import), verdrahtet im Composition Root.
//
// hexagonal (slice-058, ADR-0010): die vier Schicht-Rollen + ein EIGENER Composition Root
// rendern in die Pfade der gelebten Familien-Konvention (internal/hexagon/{core,port},
// internal/adapter/{driven,driving}, cmd/app) — NICHT in das `--print-config`-Geruest
// (internal/core …). Die Kanten sind core->ports, driven->ports, driven->core,
// driving->core; die Ports bleiben importfrei (ports->core waere mit core->ports ein
// Import-Zyklus), und die beiden Adapter-Schichten sehen einander nie (lateral-adapter).
// Verdrahtet wird ausschliesslich im Composition Root. Eine nicht unterstuetzte Rolle -> nil.
func goRole(r codeRole) map[string]string {
	switch r {
	case roleEntrypoint:
		return map[string]string{"cmd/app/main.go": goMain}
	case roleDomain:
		return map[string]string{
			"internal/hexagon/domain/example/greeting.go":      goHexDomain,
			"internal/hexagon/domain/example/greeting_test.go": goHexDomainTest,
		}
	case rolePorts:
		return map[string]string{
			"internal/hexagon/application/example/greet/ports/inbound/greet.go":          goHexInboundPort,
			"internal/hexagon/application/example/greet/ports/outbound/notifier.go":      goHexSlicePort,
			"internal/hexagon/application/example/ports/outbound/greeting_repository.go": goHexAreaPort,
		}
	case roleAppSlice:
		return map[string]string{
			"internal/hexagon/application/example/greet/handler.go":      goHexHandler,
			"internal/hexagon/application/example/greet/handler_test.go": goHexHandlerTest,
			"internal/hexagon/application/example/greet/validator.go":    goHexValidator,
		}
	case roleAdapters:
		return map[string]string{
			"internal/adapters/driving/cli/example/cli.go":            goHexDrivingCLI,
			"internal/adapters/driven/memory/example/repository.go": goHexDrivenRepo,
			"internal/adapters/driven/notify/stdout.go":             goHexDrivenNotify,
		}
	case roleCompositionRoot:
		return map[string]string{"cmd/app/main.go": goHexMain}
	case roleHexagonalCore:
		return map[string]string{
			"internal/hexagon/core/greeting.go": goHexagonalGreeting,
			"internal/hexagon/core/greet.go":    goHexagonalService,
			"internal/hexagon/core/greet_test.go": goHexagonalServiceTest,
		}
	case roleHexagonalPort:
		return map[string]string{"internal/hexagon/port/greeting_repository.go": goHexagonalPort}
	case roleHexagonalDriven:
		return map[string]string{"internal/adapter/driven/memory/repository.go": goHexagonalDriven}
	case roleHexagonalDriving:
		return map[string]string{"internal/adapter/driving/cli/cli.go": goHexagonalDriving}
	case roleHexagonalRoot:
		return map[string]string{"cmd/app/main.go": goHexagonalMain}
	}
	return nil
}

// goFragment liefert das Go-Code-Gate-Fragment (harness/mk/<modul>.mk-Inhalt): am Root
// (context ".") die bestehende UNSCOPED Fassung (Targets test/lint/build, `docker build
// .`) byte-identisch — rueckwaertskompatibel mit dem --lang-One-Shot, smoke.sh und
// full-smoke; im Subdir die MODUL-SCOPED Fassung (test-<modul>/lint-<modul>/build-<modul>,
// `docker build <context>`), kollisionsfrei wenn ein Mono-Repo mehrere Module gleicher
// Sprache traegt. Jedes `docker build --target <stage>` referenziert eine gleichnamige
// Dockerfile-Stage (test/lint/build) — kein halluziniertes Gate (LH-QA-01),
// TestCodeGateFragment_TargetsMatchStages haelt die Kopplung fest.
func goFragment(modul, context, version string) string {
	if context == "." {
		return render(goMkFragmentTmpl, version)
	}
	return renderScoped(goScopedMkFragmentTmpl, modul, context, version)
}

// goFragmentMixed liefert die gemischte Root-Fassung des Go-Code-Gate-Fragments: ein
// zweites Sprach-Fragment liegt am Root (harness/mk/<andere>.mk), darum tragen die
// unscoped Ziele test/lint/build hier nur Praezedenz-Erweiterungen ohne eigenes Rezept
// (goMixedMkFragmentTmpl) — make haengt die Praezedenz-Listen zusammen.
func goFragmentMixed(modul, context, version string) string {
	return renderScoped(goMixedMkFragmentTmpl, modul, context, version)
}

// renderScoped setzt Modul-Name, Build-Kontext, version + golangci-Pin in das
// modul-scoped Fragment-Template ein (Einzelpass, strings.Replacer — die Muster
// ueberlappen nicht).
func renderScoped(tmpl, modul, context, version string) string {
	return strings.NewReplacer(
		"{{MODULE}}", modul,
		"{{CONTEXT}}", context,
		"{{GO_VERSION}}", version,
		"{{GOLANGCI_VERSION}}", golangciVersion,
	).Replace(tmpl)
}

// majorMinor liefert "1.26" aus "1.26.4" (die go.mod-Sprachversion). Passt die
// Eingabe nicht ins major.minor(.patch)-Schema, kommt sie unveraendert zurueck.
func majorMinor(v string) string {
	parts := strings.SplitN(v, ".", 3)
	if len(parts) < 2 {
		return v
	}
	return parts[0] + "." + parts[1]
}

// render setzt version + den golangci-Pin in ein Template ein ({{…}}-Platzhalter,
// eine Stelle je Wert). strings.Replacer statt fmt.Sprintf, weil die Templates
// literale %-Verben tragen (das awk im Makefile-help-Target).
func render(tmpl, version string) string {
	return strings.NewReplacer(
		"{{GO_VERSION}}", version,
		"{{GOLANGCI_VERSION}}", golangciVersion,
	).Replace(tmpl)
}

const goMain = `// Command app — vom ai-harness-init generiertes Go-Skelett.
package main

import (
	"fmt"
	"os"
)

func main() {
	if _, err := fmt.Fprintln(os.Stdout, "Hallo vom generierten ai-harness-init-Skelett."); err != nil {
		os.Exit(1)
	}
}
`

// --- hexSlice-Go-Rollen (slice-045a, ADR-0009) ---------------------------------
// Minimal-kompilierendes, a-check-konformes HexSlice-Skelett (eine example-Area, eine
// greet-Use-Case-Slice). Die Struktur — Schichten + inward-only-Importe — ist der
// Vertrag, nicht die Domaene; der Adopter ersetzt example/greet durch seine Slices.

// goHexDomain — Domain-Schicht (importiert nur die Standardbibliothek).
const goHexDomain = `// Package example ist die Domain des generierten hexSlice-Skeletts (Domain-Schicht:
// importiert nur sich selbst).
package example

import "errors"

// Greeting ist ein Domain-Value-Object mit nicht-leerer Nachricht.
type Greeting struct {
	// Message ist der validierte Gruss-Text.
	Message string
}

// NewGreeting konstruiert ein Greeting und erzwingt die Domain-Invariante (nicht-leere
// Nachricht).
func NewGreeting(message string) (Greeting, error) {
	if message == "" {
		return Greeting{}, errors.New("empty greeting message")
	}
	return Greeting{Message: message}, nil
}
`

// goHexDomainTest — Domain-Test (external Test-Package, testpackage-konform).
const goHexDomainTest = `package example_test

import (
	"testing"

	"app/internal/hexagon/domain/example"
)

func TestNewGreeting(t *testing.T) {
	g, err := example.NewGreeting("hi")
	if err != nil {
		t.Fatalf("unerwarteter Fehler: %v", err)
	}
	if g.Message != "hi" {
		t.Errorf("Message = %q, want hi", g.Message)
	}
	if _, err := example.NewGreeting(""); err == nil {
		t.Error("leere Nachricht muss einen Fehler liefern")
	}
}
`

// goHexAreaPort — Business-Area-Port (Port-Schicht: importiert nur die Domain).
const goHexAreaPort = `// Package outbound deklariert die Business-Area-Ports der example-Area (Port-Schicht:
// importiert nur die Domain).
package outbound

import "app/internal/hexagon/domain/example"

// GreetingRepository persistiert Greetings (Outbound-Port; ein Adapter erfuellt ihn
// strukturell, verdrahtet im Composition Root).
type GreetingRepository interface {
	// Save persistiert ein Greeting.
	Save(greeting example.Greeting) error
}
`

// goHexSlicePort — slice-lokaler Port (Port-Schicht: importiert nur die Domain).
const goHexSlicePort = `// Package outbound deklariert den slice-lokalen Outbound-Port der greet-Use-Case
// (Port-Schicht: importiert nur die Domain).
package outbound

import "app/internal/hexagon/domain/example"

// Notifier annonciert ein Greeting (slice-lokaler Outbound-Port).
type Notifier interface {
	// Notify annonciert das Greeting.
	Notify(greeting example.Greeting) error
}
`

// goHexInboundPort — der inbound-Port der greet-Use-Case (Use-Case-Entrypoint): das
// Port-Paket traegt Eingabe-/Ausgabe-Typen und das Interface, damit ein driving
// Adapter am Port haengt und nie an der Slice (driving_adapters -> ports_inbound).
const goHexInboundPort = `// Package inbound deklariert den inbound-Port der greet-Use-Case: den Vertrag,
// ueber den die Welt die Use-Case ruft. Das Port-Paket importiert nichts — der
// Vertrag steht in schlichten Typen und haelt beide Seiten draussen.
package inbound

// Command ist die Eingabe der greet-Use-Case: rohe, adapter-neutrale Daten; der
// Handler der Slice wandelt sie in Domain-Objekte.
type Command struct {
	// Message ist der rohe Gruss-Text.
	Message string
}

// Result ist die Ausgabe der greet-Use-Case.
type Result struct {
	// Message ist der bestaetigte Gruss-Text.
	Message string
}

// Greet ist der inbound-Port der greet-Use-Case. Ein driving Adapter ruft ihn;
// der Handler der Slice implementiert ihn.
type Greet interface {
	// Handle fuehrt die Use-Case aus.
	Handle(cmd Command) (Result, error)
}
`

// goHexValidator — Application-Slice: Roh-Eingabe -> Domain (app -> domain).
const goHexValidator = `package greet

import (
	"app/internal/hexagon/application/example/greet/ports/inbound"
	"app/internal/hexagon/domain/example"
)

// Validate wandelt die Port-Eingabe in ein Domain-Greeting (app -> domain).
func Validate(cmd inbound.Command) (example.Greeting, error) {
	return example.NewGreeting(cmd.Message)
}
`

// goHexHandler — Application-Slice: der Use-Case-Handler implementiert den inbound-
// Port (app -> ports_inbound) und konsumiert seine outbound-Ports (app -> ports_outbound).
const goHexHandler = `// Package greet ist die greet-Use-Case-Slice (Application-Schicht: importiert die
// Domain und ihre Ports, nie Adapter).
package greet

import (
	"app/internal/hexagon/application/example/greet/ports/inbound"
	"app/internal/hexagon/application/example/greet/ports/outbound"
	areaoutbound "app/internal/hexagon/application/example/ports/outbound"
)

// Handler fuehrt die greet-Use-Case aus und implementiert den inbound-Port
// (app -> ports_inbound); seine Beduerfnisse traegt er als outbound-Ports.
type Handler struct {
	repo     areaoutbound.GreetingRepository
	notifier outbound.Notifier
}

// NewHandler verdrahtet den Handler mit seinen Ports.
func NewHandler(repo areaoutbound.GreetingRepository, notifier outbound.Notifier) *Handler {
	return &Handler{repo: repo, notifier: notifier}
}

// Handle implementiert den inbound-Port: validiert die Eingabe zu einem
// Domain-Greeting und persistiert/annonciert es.
func (h *Handler) Handle(cmd inbound.Command) (inbound.Result, error) {
	greeting, err := Validate(cmd)
	if err != nil {
		return inbound.Result{}, err
	}
	if err := h.repo.Save(greeting); err != nil {
		return inbound.Result{}, err
	}
	if err := h.notifier.Notify(greeting); err != nil {
		return inbound.Result{}, err
	}
	return inbound.Result{Message: greeting.Message}, nil
}
`

// goHexHandlerTest — Handler-Test mit Stub-Ports (external Test-Package).
const goHexHandlerTest = `package greet_test

import (
	"testing"

	"app/internal/hexagon/application/example/greet"
	"app/internal/hexagon/application/example/greet/ports/inbound"
	"app/internal/hexagon/domain/example"
)

type stubRepo struct{}

func (stubRepo) Save(example.Greeting) error { return nil }

type stubNotifier struct{}

func (stubNotifier) Notify(example.Greeting) error { return nil }

func TestHandlerHandle(t *testing.T) {
	h := greet.NewHandler(stubRepo{}, stubNotifier{})
	res, err := h.Handle(inbound.Command{Message: "hi"})
	if err != nil {
		t.Fatalf("unerwarteter Fehler: %v", err)
	}
	if res.Message != "hi" {
		t.Errorf("Message = %q, want hi", res.Message)
	}
}
`

// goHexDrivingCLI — treibender Adapter (driving): er haengt am inbound-Port der
// Use-Case (driving_adapters -> ports_inbound), nie an der Slice selbst.
const goHexDrivingCLI = `// Package cli ist der treibende CLI-Adapter (driving) der example-Area: er haengt
// an den inbound-Ports der Slices, nie an den Slices selbst.
package cli

import (
	"fmt"
	"io"

	"app/internal/hexagon/application/example/greet/ports/inbound"
)

// Runner treibt die greet-Use-Case von der Kommandozeile ueber ihren inbound-Port.
type Runner struct {
	usecase inbound.Greet
	out     io.Writer
}

// NewRunner verdrahtet den CLI-Adapter mit dem inbound-Port und der Ausgabe.
func NewRunner(usecase inbound.Greet, out io.Writer) *Runner {
	return &Runner{usecase: usecase, out: out}
}

// Run fuehrt die Use-Case ueber den inbound-Port aus und schreibt das Ergebnis.
func (r *Runner) Run(message string) error {
	res, err := r.usecase.Handle(inbound.Command{Message: message})
	if err != nil {
		return err
	}
	_, err = fmt.Fprintln(r.out, res.Message)
	return err
}
`

// goHexDrivenRepo — getriebener Adapter (driven), erfuellt den GreetingRepository-Port
// strukturell (driven -> domain; kein Port-Import).
const goHexDrivenRepo = `// Package memory ist ein getriebener In-Memory-Adapter (driven) der example-Area
// (erfuellt den GreetingRepository-Port strukturell; verdrahtet im Composition Root).
package memory

import "app/internal/hexagon/domain/example"

// Repository haelt Greetings im Speicher.
type Repository struct {
	saved []example.Greeting
}

// NewRepository konstruiert ein leeres In-Memory-Repository.
func NewRepository() *Repository {
	return &Repository{}
}

// Save haengt das Greeting an den Speicher an.
func (r *Repository) Save(greeting example.Greeting) error {
	r.saved = append(r.saved, greeting)
	return nil
}

// Count liefert die Anzahl gespeicherter Greetings.
func (r *Repository) Count() int {
	return len(r.saved)
}
`

// goHexDrivenNotify — getriebener Adapter (driven), erfuellt den Notifier-Port
// strukturell (driven -> domain; kein Port-Import).
const goHexDrivenNotify = `// Package notify ist ein getriebener Adapter (driven), der Greetings auf einen io.Writer
// annonciert (erfuellt den Notifier-Port strukturell; verdrahtet im Composition Root).
package notify

import (
	"fmt"
	"io"

	"app/internal/hexagon/domain/example"
)

// Writer annonciert Greetings auf einen io.Writer.
type Writer struct {
	out io.Writer
}

// NewWriter konstruiert einen Writer.
func NewWriter(out io.Writer) *Writer {
	return &Writer{out: out}
}

// Notify schreibt die Gruss-Nachricht.
func (w *Writer) Notify(greeting example.Greeting) error {
	_, err := fmt.Fprintln(w.out, greeting.Message)
	return err
}
`

// goHexMain — Composition Root (cmd/app/main.go): verdrahtet Adapter, Ports und die
// Use-Case-Slice. a-check-exempt (cmd/**). Ersetzt im hexSlice-Layout den flachen goMain.
const goHexMain = `// Command app — vom ai-harness-init generiertes hexSlice-Skelett. Composition Root:
// verdrahtet Adapter, Ports und Use-Case-Slices (a-check-exempt, cmd/**).
package main

import (
	"os"

	cli "app/internal/adapters/driving/cli/example"
	memory "app/internal/adapters/driven/memory/example"
	"app/internal/adapters/driven/notify"
	"app/internal/hexagon/application/example/greet"
)

func main() {
	repo := memory.NewRepository()
	notifier := notify.NewWriter(os.Stdout)
	handler := greet.NewHandler(repo, notifier)
	runner := cli.NewRunner(handler, os.Stdout)
	if err := runner.Run("Hallo vom generierten hexSlice-Skelett."); err != nil {
		os.Exit(1)
	}
}
`

// goHexArchConfig — die `.a-check.yml` des hexSlice-Go-Moduls (slice-046, LH-FA-07).
// Sie bildet GENAU die Schichten ab, die goRole oben generiert; die Kopplung haelt
// TestArchGateConfig_MatchesSkeleton fest (ADR-0009 Fitness-Function). MODUL-RELATIV:
// der Gate-Lauf mountet das Modul-Verzeichnis, darum kein <pfad>-Praefix — ein Mono-Repo
// mit zwei hexSlice-Modulen bekommt zwei eigene Configs statt einer geteilten.
//
// Die Slice- und Port-Globs tragen LITERALE Verzeichnis-Praefixe (…/greet/**, nicht
// …/**/ports/**), wie es die kanonische hexslice-Referenz verlangt: nur an einem solchen
// Praefix haengen die beiden Vertical-Slice-Regeln (lateral-slice, port-locality); ein
// Wildcard-in-der-Mitte laesst sie still inert.
//
// Was das fuer den Adopter heisst — praezise, nicht beschoenigt (Review F-3): die Globs
// zaehlen die EINE generierte Slice literal auf, und die Config ist skip-if-present, das
// Tool zieht also nie nach. Wer eine zweite Slice anlegt, MUSS sie in app/ports aufnehmen.
// Unterbleibt das, faellt ihr Code unter keine Schicht. Wie sich das zeigt, haengt vom
// Code ab — hier die Grenze der Aussage, nicht die bequeme Fassung (Review-Runde 2, N-2):
//
//	- Die neue Slice importiert eine Schicht (Domain/Ports — der Normalfall, denn eine
//	  Use-Case-Slice ohne Domain-Bezug ist keine): a-check meldet `wrong-direction` und
//	  faellt (Exit 1). Einmal so gemessen (a-check v0.15.0, Wegwerf-Skelett mit nicht
//	  eingetragener zweiter Slice) — im Repo liegt dafuer KEIN Sensor, es ist eine
//	  Hand-Messung, keine bewachte Zusage.
//	- Die neue Slice importiert KEINE Schicht (rein interner Code): sie faellt unter
//	  keine Regel und bleibt still gruen. Diesen Fall faengt niemand.
//
// Der Gate-Lauf ist also ein wahrscheinlicher, kein garantierter Hinweis. Die emittierte
// Datei unten sagt dem Adopter genau das — nicht mehr.
//
// Mit nur EINER Slice koennen lateral-slice/port-locality noch nicht feuern (dafuer
// braucht es zwei). Was hier und heute REAL rot gesehen wurde, ist `core-impurity`
// (verbotener Domain->Adapter-Import, full-smoke) — `wrong-direction` in der oben
// genannten Messung.
const goHexArchConfig = `# .a-check.yml — Architektur-Gate (HexSlice = hexagonal + vertical slice),
# emittiert von ai-harness-init. Bildet die Schichten des generierten hexSlice-
# Skeletts ab; a-check laeuft netzlos + read-only (make a-check).
#
# Streng dekodiert: ein unbekannter Schluessel ist Exit 2.
#
# Die Slice-Globs (.../greet/**) und Port-Globs (.../ports/<richtung>/**) tragen
# bewusst literale Verzeichnis-Praefixe. Nur daran haengen die beiden Vertical-
# Slice-Regeln: lateral-slice (eine Slice importiert keine andere derselben
# Schicht) und port-locality (ein slice-lokaler Port bleibt in seiner Slice). Ein
# Wildcard-in-der-Mitte (.../**/ports/**) traegt keinen solchen Praefix und
# liesse beide Regeln still inert.
#
# Der Port-Glob endet an der Richtung, die dieselbe Schicht deklariert
# (…/ports/outbound/**). Erst seit a-check v0.20.0 ist diese Form lebendig:
# portScope schneidet die deklarierte Richtung aus dem Glob-Praefix mit ab —
# zuvor verengte ein Richtungs-Glob den Geltungsbereich auf ".../ports" und
# port-locality meldete bei einem echten Uebergreifen nichts. Behalte jede
# Port-Glob-Endung auf ihrer Richtung: die Schicht deklariert sie, und der
# a-check-Adivsory meldet einen Port-Glob, dessen abgeleiteter Bereich den
# app-Baum nicht mehr erreicht.
#
# DIESE DATEI IST DEINE: sie wird beim Re-Bootstrap nicht ueberschrieben, also
# waechst sie nur, wenn du sie pflegst. Zwei Faelle:
#   - Area/Slice UMBENANNT  -> die Globs mitziehen.
#   - Slice HINZUGEFUEGT    -> je einen app-Glob (.../<neue-slice>/**) und, falls
#     sie Ports traegt, je einen ports-Glob (.../<neue-slice>/ports/<richtung>/**)
#     ERGAENZEN. Vergisst du es, faellt der neue Code unter keine Schicht: importiert
#     er eine (Domain/Ports), meldet a-check wrong-direction und faellt — importiert
#     er keine, bleibt er still gruen und ungeprueft. Verlass dich also nicht darauf,
#     dass der Gate-Lauf dich erinnert; die Globs gehoeren zum Anlegen einer Slice.
version: 1

languages:
  go: ["**/*.go"]

layers:
  domain:
    globs: ["internal/hexagon/domain/**"]
    role: domain
  ports_inbound:
    globs:
      - "internal/hexagon/application/example/greet/ports/inbound/**"   # use-case-lokal
    role: port
    direction: inbound      # von der Use-Case angeboten; ein driving Adapter ruft ihn
  ports_outbound:
    globs:
      - "internal/hexagon/application/example/greet/ports/outbound/**"   # use-case-lokal
      - "internal/hexagon/application/example/ports/outbound/**"         # business-area-geteilt
    role: port
    direction: outbound     # von der Use-Case gebraucht; ein driven Adapter erfuellt ihn
  app:
    globs:
      - "internal/hexagon/application/example/greet/**"         # Slice: greet
    role: app
  driving_adapters:
    globs: ["internal/adapters/driving/**"]
    role: adapter
    direction: driving      # ruft den Anwendungskern
  driven_adapters:
    globs: ["internal/adapters/driven/**"]
    role: adapter
    direction: driven       # wird vom Anwendungskern gerufen

# Erlaubte gerichtete Abhaengigkeiten (nur nach innen). Ein Cross-Layer-Import
# ohne passende Kante ist ein Befund (wrong-direction).
edges:
  - {from: app,              to: domain}
  - {from: app,              to: ports_inbound}    # die Slice importiert ihren inbound-Port
  - {from: app,              to: ports_outbound}   # die Slice importiert ihre outbound-Ports
  - {from: ports_outbound,   to: domain}
  - {from: driving_adapters, to: ports_inbound}    # der treibende Adapter spricht die inbound-Ports
  - {from: driven_adapters,  to: domain}           # Adapter bilden auf/von Domain-Objekten ab
# Bewusst abwesend:
# * Keine driven_adapters->ports_outbound-Kante: die getriebenen Adapter ERFUELLEN
#   die Ports ueber Go-Interface-Erfuellung (strukturell, kein Import); verdrahtet
#   wird im Composition Root (cmd/**). Der treibende Adapter ist der Gegenfall: er
#   importiert den inbound-Port, weil der Port die Request-/Result-Typen traegt,
#   die er baut und liest.
# * Keine ports_inbound->domain-Kante: kein inbound-Port importiert die Domain —
#   der Vertrag steht in schlichten Typen und haelt beide Seiten draussen.
# * Keine driving_adapters->app-Kante: der treibende Adapter erreicht die Use-Case
#   ausschliesslich ueber ihre inbound-Ports. Die Kante gehoert in denselben Commit
#   wie ein treibender Adapter, der eine Slice direkt importiert.
#
# port-direction-mismatch ist hier lebendig: ein driving Adapter an einem inbound-
# Port ist das Paar (driving <-> inbound), ein driven Adapter an einem inbound-Port
# ist ein Befund — die Richtung wird per Injektion verifiziert, nicht deklariert.

# Der Composition Root verdrahtet Adapter und Slices — von den Schichtregeln befreit.
composition_root: ["cmd/**"]

# Tests gehoeren nicht zum Produktions-Abhaengigkeitsgraphen.
exclude:
  - "**/*_test.go"
`

// --- hexagonal-Go-Rollen (slice-058, ADR-0010) ---------------------------------
// Minimal-kompilierendes, a-check-konformes hexagonales Skelett: EIN Kern (Domaene und
// Use-Case zusammen, `role: app`), EINE importfreie Port-Schicht, je ein getriebener und
// ein treibender Adapter, verdrahtet im Composition Root. Die Struktur — Schichten +
// Kanten — ist der Vertrag, nicht die Domaene; der Adopter ersetzt greet durch seine
// Use-Cases. Der Unterschied zum hexSlice-Layout ist NICHT die Strenge, sondern das
// Vokabular: core/port/adapter statt domain/application/ports/adapters (ADR-0010
// Festlegung 2 — die Verzeichnisnamen sind disjunkt).

// goHexagonalPort — die Port-Schicht: IMPORTFREI. Darum sprechen ihre Signaturen
// Standardtypen und keine Kern-Typen: eine Kante ports->core waere zusammen mit
// core->ports ein Import-Zyklus, den die Sprache selbst ausschliesst (ADR-0010).
const goHexagonalPort = `// Package port deklariert die getriebenen Ports des Kerns (Port-Schicht: IMPORTFREI —
// darum sprechen die Signaturen Standardtypen, nicht Kern-Typen; eine Kante zurueck in
// den Kern waere ein Import-Zyklus).
package port

// GreetingRepository persistiert eine Gruss-Nachricht (getriebener Port; ein Adapter
// unter internal/adapter/driven erfuellt ihn, verdrahtet im Composition Root).
type GreetingRepository interface {
	// Save persistiert die Gruss-Nachricht.
	Save(message string) error
}
`

// goHexagonalGreeting — der Kern, Domaenen-Teil (importiert nur die Standardbibliothek).
const goHexagonalGreeting = `// Package core ist der Kern des generierten hexagonalen Skeletts: Domaene UND Use-Case
// in EINER geprueften Schicht (role: app). Er importiert seine getriebenen Ports und nie
// einen Adapter — ein Adapter-Import hier ist ein app-impurity-Befund.
package core

import "errors"

// Greeting ist ein Domaenen-Value-Object mit nicht-leerer Nachricht.
type Greeting struct {
	// Message ist der validierte Gruss-Text.
	Message string
}

// NewGreeting konstruiert ein Greeting und erzwingt die Domaenen-Invariante (nicht-leere
// Nachricht).
func NewGreeting(message string) (Greeting, error) {
	if message == "" {
		return Greeting{}, errors.New("empty greeting message")
	}
	return Greeting{Message: message}, nil
}
`

// goHexagonalService — der Kern, Use-Case-Teil (core -> ports). Die Use-Case bleibt im
// KERN, nicht im Composition Root: sonst wanderte mit der Verdrahtung auch die Logik in
// den ungeprueften Bereich (ADR-0010 §Konsequenzen).
const goHexagonalService = `package core

import "app/internal/hexagon/port"

// GreetService ist die Use-Case des Kerns (core -> ports).
type GreetService struct {
	repo port.GreetingRepository
}

// NewGreetService verdrahtet die Use-Case mit ihrem getriebenen Port.
func NewGreetService(repo port.GreetingRepository) *GreetService {
	return &GreetService{repo: repo}
}

// Greet validiert die Roh-Eingabe zu einem Greeting und persistiert sie ueber den Port.
func (s *GreetService) Greet(message string) (Greeting, error) {
	greeting, err := NewGreeting(message)
	if err != nil {
		return Greeting{}, err
	}
	if err := s.repo.Save(greeting.Message); err != nil {
		return Greeting{}, err
	}
	return greeting, nil
}
`

// goHexagonalServiceTest — Kern-Test mit Stub-Port (external Test-Package).
const goHexagonalServiceTest = `package core_test

import (
	"testing"

	"app/internal/hexagon/core"
)

type stubRepo struct {
	saved []string
}

func (r *stubRepo) Save(message string) error {
	r.saved = append(r.saved, message)
	return nil
}

func TestGreetServiceGreet(t *testing.T) {
	repo := &stubRepo{}
	svc := core.NewGreetService(repo)
	greeting, err := svc.Greet("hi")
	if err != nil {
		t.Fatalf("unerwarteter Fehler: %v", err)
	}
	if greeting.Message != "hi" {
		t.Errorf("Message = %q, want hi", greeting.Message)
	}
	if len(repo.saved) != 1 {
		t.Errorf("Save-Aufrufe = %d, want 1", len(repo.saved))
	}
	if _, err := svc.Greet(""); err == nil {
		t.Error("leere Nachricht muss einen Fehler liefern")
	}
}
`

// goHexagonalDriven — getriebener Adapter: erfuellt den Port (driven -> ports) und bildet
// auf Kern-Typen ab (driven -> core). Die zweite Kante sieht wie ein Ueberschuss aus — sie
// ist im `--print-config`-Geruest nur auskommentiert, in der Familie real gefuehrt
// (ADR-0010 Festlegung 1); test/mutations/100 bewacht sie.
const goHexagonalDriven = `// Package memory ist ein getriebener In-Memory-Adapter (driven): er erfuellt den
// GreetingRepository-Port (driven -> ports) und bildet die gespeicherten Nachrichten auf
// Kern-Objekte ab (driven -> core). Verdrahtet wird er im Composition Root.
package memory

import (
	"app/internal/hexagon/core"
	"app/internal/hexagon/port"
)

// Repository haelt Gruss-Nachrichten im Speicher.
type Repository struct {
	saved []string
}

// Der Compiler haelt fest, dass der Adapter seinen Port erfuellt (driven -> ports).
var _ port.GreetingRepository = (*Repository)(nil)

// NewRepository konstruiert ein leeres In-Memory-Repository.
func NewRepository() *Repository {
	return &Repository{}
}

// Save haengt die Nachricht an den Speicher an.
func (r *Repository) Save(message string) error {
	r.saved = append(r.saved, message)
	return nil
}

// Greetings bildet die gespeicherten Nachrichten auf Kern-Objekte ab (driven -> core).
func (r *Repository) Greetings() ([]core.Greeting, error) {
	out := make([]core.Greeting, 0, len(r.saved))
	for _, message := range r.saved {
		greeting, err := core.NewGreeting(message)
		if err != nil {
			return nil, err
		}
		out = append(out, greeting)
	}
	return out, nil
}
`

// goHexagonalDriving — treibender Adapter (driving -> core). Er importiert KEINEN
// getriebenen Adapter: zwei Schichten mit role: adapter duerfen einander nicht sehen
// (lateral-adapter — kategorisch, keine Kante hebt das auf).
const goHexagonalDriving = `// Package cli ist der treibende Adapter (driving): er nimmt die Eingabe entgegen und
// ruft die Use-Case des Kerns (driving -> core). Er importiert KEINEN getriebenen Adapter
// — zwei Adapter-Schichten sehen einander nie (lateral-adapter); verdrahtet wird in cmd/**.
package cli

import (
	"fmt"
	"io"

	"app/internal/hexagon/core"
)

// Runner treibt die Greet-Use-Case von der Kommandozeile.
type Runner struct {
	svc *core.GreetService
	out io.Writer
}

// NewRunner verdrahtet den treibenden Adapter mit der Use-Case und der Ausgabe.
func NewRunner(svc *core.GreetService, out io.Writer) *Runner {
	return &Runner{svc: svc, out: out}
}

// Run fuehrt die Use-Case aus und schreibt das Ergebnis.
func (r *Runner) Run(message string) error {
	greeting, err := r.svc.Greet(message)
	if err != nil {
		return err
	}
	_, err = fmt.Fprintln(r.out, greeting.Message)
	return err
}
`

// goHexagonalMain — Composition Root (cmd/app/main.go) des hexagonalen Layouts. HIER —
// und nur hier — entsteht der getriebene Adapter, wird in die Use-Case injiziert und
// diese an den treibenden Adapter uebergeben (ADR-0010 §Wo verdrahtet wird; die eine
// Stelle, an der wir der Familien-Konvention bewusst NICHT folgen, weil die treibende
// Seite bei uns eine gepruefte Schicht ist). a-check-exempt (cmd/**) — darum steht hier
// ausschliesslich Konstruktion, keine Logik.
const goHexagonalMain = `// Command app — vom ai-harness-init generiertes hexagonales Skelett. Composition Root:
// hier entsteht der getriebene Adapter, wird in die Use-Case injiziert und diese an den
// treibenden Adapter uebergeben. a-check-exempt (cmd/**), darum steht hier ausschliesslich
// Konstruktion — Logik gehoert in den Kern.
package main

import (
	"os"

	"app/internal/adapter/driven/memory"
	"app/internal/adapter/driving/cli"
	"app/internal/hexagon/core"
)

func main() {
	repo := memory.NewRepository()
	svc := core.NewGreetService(repo)
	runner := cli.NewRunner(svc, os.Stdout)
	if err := runner.Run("Hallo vom generierten hexagonalen Skelett."); err != nil {
		os.Exit(1)
	}
}
`

// goHexagonalArchConfig — die `.a-check.yml` des hexagonalen Go-Moduls (slice-058,
// ADR-0010, LH-FA-07). Sie bildet GENAU die Schichten ab, die goRole oben generiert; die
// Kopplung halten TestArchGateConfig_HexagonalMatchesSkeleton (Schichten) und
// TestArchGateConfig_HexagonalEdgesMatchSkeleton (Kanten). MODUL-RELATIV: der Gate-Lauf
// mountet das Modul-Verzeichnis, darum kein <pfad>-Praefix.
//
// Vier Eigenschaften, die beim Lesen wie Fehler aussehen und keine sind:
//
//	(1) die PFADE weichen vom `a-check --print-config`-Geruest ab (internal/hexagon/core
//	    statt internal/core) — emittiert wird die gelebte Konvention der Werkzeug-Familie,
//	    nicht das Minimalbeispiel der Werkzeug-Doku (ADR-0010 Festlegung 1). Der Kopf der
//	    emittierten Datei sagt dem Adopter genau das (ADR-0010 Folgepflicht 4).
//	(2) jede Schicht traegt ihre Rolle EXPLIZIT: `driven`/`driving` inferieren keine
//	    (die Inferenz kennt core/ports/adapters/application/app), und der Kern traegt
//	    bewusst `app` statt des inferierten `domain` — sonst duerfte er seine eigenen
//	    Ports nicht importieren und die Use-Case muesste in den befreiten cmd/**-Bereich.
//	(3) die Kante driven->core steht real da (im Geruest nur auskommentiert).
//	(4) es gibt KEINE Kante ports->core: zusammen mit core->ports waere das in einer
//	    einzigen Kern-Schicht ein Import-Zyklus.
//
// Was hier und heute REAL rot gesehen wurde: app-impurity (core -> driven) und
// lateral-adapter (driving -> driven), beide in harness/tools/full-smoke.sh.
const goHexagonalArchConfig = `# .a-check.yml — Architektur-Gate (hexagonal: core / port / adapter), emittiert von
# ai-harness-init. Bildet die Schichten des generierten hexagonalen Skeletts ab;
# a-check laeuft netzlos + read-only (make a-check).
#
# Streng dekodiert: ein unbekannter Schluessel ist Exit 2.
#
# WARUM DIE PFADE VOM STANDARD-GERUEST ABWEICHEN: 'a-check --print-config' schlaegt
# internal/core / internal/ports / internal/adapters vor. Emittiert wird stattdessen
# die Form, die in dieser Werkzeug-Familie real gebaut und real geprueft wird
# (internal/hexagon/core, internal/hexagon/port, internal/adapter/{driven,driving}).
# Das ist Absicht, kein Werkzeug-Fehler.
#
# WARUM JEDE SCHICHT IHRE ROLLE EXPLIZIT TRAEGT: die Namens-Inferenz kennt nur
# core/ports/adapters/application/app — 'driven' und 'driving' inferieren nichts und
# waeren ohne role: bloss kanten-geprueft. Der Kern traegt bewusst 'app' und nicht
# 'domain': eine domain-Schicht darf keinen Port importieren, dann muesste die
# Use-Case in den befreiten cmd/**-Bereich ausweichen.
#
# DIE TREIBENDE SEITE IST HIER STRENGER als in den Referenz-Repos: dort ist sie
# Composition Root (ungeprueft), hier eine Schicht mit eigenen Kanten. Wer die
# Prueffreiheit will, traegt "internal/adapter/driving/**" unten in composition_root
# ein — eine Zeile, in DIESER Datei, die beim Re-Bootstrap nie ueberschrieben wird.
version: 1

languages:
  go: ["**/*.go"]

layers:
  core:
    globs: ["internal/hexagon/core/**"]
    role: app
  ports:
    globs: ["internal/hexagon/port/**"]
    role: port
  driven:
    globs: ["internal/adapter/driven/**"]
    role: adapter
  driving:
    globs: ["internal/adapter/driving/**"]
    role: adapter

# Erlaubte gerichtete Abhaengigkeiten. Ein Cross-Layer-Import ohne passende Kante ist
# ein Befund (wrong-direction). KEINE Kante ports->core: zusammen mit core->ports waere
# das ein Import-Zyklus. KEINE Kante driving->driven: zwei adapter-Schichten sehen
# einander nie (lateral-adapter, kategorisch — eine Kante wuerde das nicht aufheben).
edges:
  - {from: core,    to: ports}
  - {from: driven,  to: ports}   # der Adapter erfuellt den Port explizit
  - {from: driven,  to: core}    # Adapter bilden auf/von Kern-Objekten ab
  - {from: driving, to: core}    # die treibende Seite ruft die Use-Case

# Der Composition Root verdrahtet Adapter und Use-Case — von den Schichtregeln befreit.
composition_root: ["cmd/**"]

# Tests gehoeren nicht zum Produktions-Abhaengigkeitsgraphen.
exclude:
  - "**/*_test.go"
`

const goDockerfileTmpl = `# syntax=docker/dockerfile:1.7
# Dockerfile — generiert von ai-harness-init (Go-Skelett). Jede Go-Gate ist eine
# Stage (docker build --target <stage>); die Images sind TAG-gepinnt (LH-QA-02,
# kein floating). Digest bewusst weggelassen, damit GO_VERSION ein echter Knopf
# bleibt; wer Digest-Pinning will, haengt @sha256:… an.
ARG GO_VERSION={{GO_VERSION}}
ARG GOLANGCI_LINT_VERSION={{GOLANGCI_VERSION}}

FROM golang:${GO_VERSION} AS deps
WORKDIR /src
ENV GOFLAGS="-mod=readonly -buildvcs=false" \
    GOMODCACHE=/go/pkg/mod \
    GOCACHE=/root/.cache/go-build
COPY go.mod ./
COPY go.su[m] ./
RUN mkdir -p "$GOMODCACHE" && go mod download

FROM deps AS test
COPY . .
RUN CGO_ENABLED=0 go test ./...

FROM golangci/golangci-lint:${GOLANGCI_LINT_VERSION} AS lint
WORKDIR /src
ENV GOFLAGS="-buildvcs=false"
COPY --from=deps /go/pkg/mod /go/pkg/mod
COPY . .
RUN golangci-lint run ./...

FROM deps AS build
COPY . .
RUN CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /out/app ./cmd/app
`

// goMkFragmentTmpl — das Go-Code-Gate-Fragment (harness/mk/go.mk): lint/build/test als
// Dockerfile-Stages, an GATE_CHECKS gehaengt. Die Recipe-Zeilen sind TAB-eingerueckt.
const goMkFragmentTmpl = `# harness/mk/go.mk — Go-Code-Gate-Fragment, generiert von ai-harness-init. Die
# Go-Gates sind Dockerfile-Stages (Docker-only, ADR-0003); dieses Fragment haengt
# lint/build/test an GATE_CHECKS, der Root-Aggregator faehrt sie via make gates.
GO_VERSION ?= {{GO_VERSION}}
GOLANGCI_LINT_VERSION ?= {{GOLANGCI_VERSION}}
IMAGE ?= app

.PHONY: test lint build

test: ## Go-Unit-Tests (Dockerfile test-Stage) — Docker-only
	docker build --no-cache-filter test --build-arg GO_VERSION=$(GO_VERSION) --target test -t $(IMAGE):test .

lint: ## Go-Lint (golangci-lint, Dockerfile lint-Stage) — Docker-only
	docker build --build-arg GOLANGCI_LINT_VERSION=$(GOLANGCI_LINT_VERSION) --target lint -t $(IMAGE):lint .

build: ## Go-Binary bauen (Dockerfile build-Stage) — Docker-only
	docker build --build-arg GO_VERSION=$(GO_VERSION) --target build -t $(IMAGE):build .

GATE_CHECKS += lint build test
`

// goMixedMkFragmentTmpl — die Go-Fassung fuer den GEMISCHTEN Root (harness/mk/go.mk, wenn
// ein zweites Sprach-Fragment am Root liegt): modul-scoped Targets ({{MODULE}}), Build-Kontext
// {{CONTEXT}}, und die unscoped Ziele test/lint/build NUR als Praezedenz-Erweiterung ohne
// eigenes Rezept — make haengt die Praezedenz-Listen mehrerer Regeln zusammen, das Rezept
// bleibt bei dem Fragment, das die unscoped Targets am Root zuerst geschrieben hat, und
// make test/lint/build bedient beide Sprach-Kontexte ohne Rezept-Ueberschreibung. GATE_CHECKS
// haengt die UNSCOPED Namen an (record-gates dedupliziert Praezedenz-Listen); die scoped
// Namen stehen NICHT daneben — sonst liefe der Go-Kontext in gates doppelt.
const goMixedMkFragmentTmpl = `# harness/mk/{{MODULE}}.mk — Go-Code-Gate-Fragment (Modul {{MODULE}}), generiert von
# ai-harness-init. Go-Gates als Dockerfile-Stages (Docker-only, ADR-0003); modul-scoped
# Targets, Build-Kontext {{CONTEXT}} — ein zweites Sprach-Fragment liegt am Root, darum
# traegt dieses Fragment die unscoped Ziele test/lint/build nur als Praezedenz-Erweiterung
# ohne eigenes Rezept: make haengt Praezedenz-Listen mehrerer Regeln zusammen, das Rezept
# bleibt bei dem Fragment, das sie am Root zuerst geschrieben hat.
GO_VERSION ?= {{GO_VERSION}}
GOLANGCI_LINT_VERSION ?= {{GOLANGCI_VERSION}}

.PHONY: test lint build test-{{MODULE}} lint-{{MODULE}} build-{{MODULE}}

test-{{MODULE}}: ## Go-Unit-Tests Modul {{MODULE}} (test-Stage) — Docker-only
	docker build --no-cache-filter test --build-arg GO_VERSION=$(GO_VERSION) --target test -t {{MODULE}}:test {{CONTEXT}}

lint-{{MODULE}}: ## Go-Lint Modul {{MODULE}} (golangci-lint, lint-Stage) — Docker-only
	docker build --build-arg GOLANGCI_LINT_VERSION=$(GOLANGCI_LINT_VERSION) --target lint -t {{MODULE}}:lint {{CONTEXT}}

build-{{MODULE}}: ## Go-Binary Modul {{MODULE}} bauen (build-Stage) — Docker-only
	docker build --build-arg GO_VERSION=$(GO_VERSION) --target build -t {{MODULE}}:build {{CONTEXT}}

test: test-{{MODULE}}
lint: lint-{{MODULE}}
build: build-{{MODULE}}

GATE_CHECKS += test lint build
`

// goScopedMkFragmentTmpl — das MODUL-SCOPED Go-Code-Gate-Fragment (harness/mk/<modul>.mk)
// fuer ein Mono-Repo-Submodul unter {{CONTEXT}}: die Targets tragen den Modul-Namen
// ({{MODULE}}, kollisionsfrei bei mehreren Modulen), der Build-Kontext ist {{CONTEXT}}
// (nicht `.`), der Image-Tag ist der Modul-Name (inline, kein IMAGE-Var-Kollisionsrisiko).
// Recipe-Zeilen sind TAB-eingerueckt.
const goScopedMkFragmentTmpl = `# harness/mk/{{MODULE}}.mk — Go-Code-Gate-Fragment (Modul {{MODULE}}), generiert von
# ai-harness-init. Go-Gates als Dockerfile-Stages (Docker-only, ADR-0003); modul-scoped
# Targets (kollisionsfrei im Mono-Repo), Build-Kontext {{CONTEXT}}. Haengt an GATE_CHECKS,
# der Root-Aggregator faehrt sie via make gates.
GO_VERSION ?= {{GO_VERSION}}
GOLANGCI_LINT_VERSION ?= {{GOLANGCI_VERSION}}

.PHONY: test-{{MODULE}} lint-{{MODULE}} build-{{MODULE}}

test-{{MODULE}}: ## Go-Unit-Tests Modul {{MODULE}} (test-Stage) — Docker-only
	docker build --no-cache-filter test --build-arg GO_VERSION=$(GO_VERSION) --target test -t {{MODULE}}:test {{CONTEXT}}

lint-{{MODULE}}: ## Go-Lint Modul {{MODULE}} (golangci-lint, lint-Stage) — Docker-only
	docker build --build-arg GOLANGCI_LINT_VERSION=$(GOLANGCI_LINT_VERSION) --target lint -t {{MODULE}}:lint {{CONTEXT}}

build-{{MODULE}}: ## Go-Binary Modul {{MODULE}} bauen (build-Stage) — Docker-only
	docker build --build-arg GO_VERSION=$(GO_VERSION) --target build -t {{MODULE}}:build {{CONTEXT}}

GATE_CHECKS += lint-{{MODULE}} build-{{MODULE}} test-{{MODULE}}
`

// goGolangci — kuratiert reiche Config: die volle Linter-Enable-Liste unseres
// Dogfood-.golangci.yml + Settings + _test.go-Exclusions, ABER ohne die
// repo-EIGENEN Meinungen forbidigo (fmt.Print-Verbot; wir schreiben ueber
// injizierte io.Writer — ein fremdes Skelett muss das nicht) und gomodguard
// (logrus/zap-Block). Der GENERIERTE Code lintet erst im Ziel (slice-024).
const goGolangci = `version: "2"

linters:
  default: none
  enable:
    - errcheck
    - govet
    - ineffassign
    - staticcheck
    - unused
    - containedctx
    - contextcheck
    - cyclop
    - dupl
    - fatcontext
    - funlen
    - gochecknoglobals
    - gochecknoinits
    - gocognit
    - gocyclo
    - iface
    - inamedparam
    - interfacebloat
    - ireturn
    - maintidx
    - nestif
    - noctx
    - reassign
    - revive
    - testpackage
    - unparam

  settings:
    errcheck:
      exclude-functions:
        - fmt.Fprintln
        - fmt.Fprintf
        - fmt.Fprint
    cyclop:
      max-complexity: 15
    dupl:
      threshold: 150
    funlen:
      lines: 100
      statements: 60
    gocognit:
      min-complexity: 20
    gocyclo:
      min-complexity: 15
    interfacebloat:
      max: 10
    ireturn:
      allow:
        - error
        - empty
        - anon
        - stdlib
        - generic
    maintidx:
      under: 20
    nestif:
      min-complexity: 5
    revive:
      rules:
        - name: blank-imports
        - name: context-as-argument
        - name: context-keys-type
        - name: dot-imports
        - name: empty-block
        - name: error-naming
        - name: error-return
        - name: error-strings
        - name: errorf
        - name: exported
        - name: if-return
        - name: increment-decrement
        - name: indent-error-flow
        - name: package-comments
        - name: range
        - name: receiver-naming
        - name: redefines-builtin-id
        - name: superfluous-else
        - name: time-naming
        - name: unexported-return
        - name: unused-parameter
        - name: var-declaration
        - name: var-naming
        - name: unused-receiver

  exclusions:
    generated: lax
    rules:
      - linters:
          - cyclop
          - gocognit
          - gocyclo
          - nestif
          - funlen
        path: _test\.go$
      - linters:
          - noctx
          - unparam
        path: _test\.go$
      - linters:
          - revive
        path: _test\.go$
        text: ^unused-parameter
      - linters:
          - revive
        path: _test\.go$
        text: ^unused-receiver
`
