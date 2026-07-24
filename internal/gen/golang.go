package gen

import "strings"

// DefaultGoVersion ist der gepinnte Go-Toolchain-Default des generierten Skeletts
// (LH-QA-02: kein floating). An das Repo-Dockerfile gekoppelt
// (TestGoProfile_PinsMatchRepo), damit ein Bump nicht die eine Haelfte bewegt und
// die andere vergisst. Ueberschreibbar beim Bootstrap (SKEL_GO_VERSION, cmd) — der
// Generator selbst bleibt deterministisch: gleiche version -> byte-identische
// Ausgabe.
const DefaultGoVersion = "1.26.5"

// golangciVersion ist der gepinnte golangci-lint-Tag des generierten Skeletts.
const golangciVersion = "v2.12.2"

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
// (internal/hexagon/{domain,application}, internal/adapters/{inbound,outbound}, cmd/app).
// Die Import-Richtungen sind inward-only (app->domain, app->ports, ports->domain,
// adapters->app, adapters->domain); Outbound-Adapter erfuellen die Ports strukturell
// (kein Import), verdrahtet im Composition Root. Eine nicht unterstuetzte Rolle -> nil.
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
			"internal/hexagon/application/example/ports/greeting_repository.go": goHexAreaPort,
			"internal/hexagon/application/example/greet/ports/notifier.go":      goHexSlicePort,
		}
	case roleAppSlice:
		return map[string]string{
			"internal/hexagon/application/example/greet/command.go":     goHexCommand,
			"internal/hexagon/application/example/greet/result.go":      goHexResult,
			"internal/hexagon/application/example/greet/validator.go":   goHexValidator,
			"internal/hexagon/application/example/greet/handler.go":     goHexHandler,
			"internal/hexagon/application/example/greet/handler_test.go": goHexHandlerTest,
		}
	case roleAdapters:
		return map[string]string{
			"internal/adapters/inbound/cli/example/cli.go":            goHexInboundCLI,
			"internal/adapters/outbound/memory/example/repository.go": goHexOutboundRepo,
			"internal/adapters/outbound/notify/stdout.go":             goHexOutboundNotify,
		}
	case roleCompositionRoot:
		return map[string]string{"cmd/app/main.go": goHexMain}
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
const goHexAreaPort = `// Package ports deklariert die Business-Area-Ports der example-Area (Port-Schicht:
// importiert nur die Domain).
package ports

import "app/internal/hexagon/domain/example"

// GreetingRepository persistiert Greetings (Outbound-Port; ein Adapter erfuellt ihn
// strukturell, verdrahtet im Composition Root).
type GreetingRepository interface {
	// Save persistiert ein Greeting.
	Save(greeting example.Greeting) error
}
`

// goHexSlicePort — slice-lokaler Port (Port-Schicht: importiert nur die Domain).
const goHexSlicePort = `// Package ports deklariert die slice-lokalen Ports der greet-Use-Case (Port-Schicht:
// importiert nur die Domain).
package ports

import "app/internal/hexagon/domain/example"

// Notifier annonciert ein Greeting (slice-lokaler Outbound-Port).
type Notifier interface {
	// Notify annonciert das Greeting.
	Notify(greeting example.Greeting) error
}
`

// goHexCommand — Application-Slice: die Eingabe (traegt das Package-Kommentar).
const goHexCommand = `// Package greet ist die greet-Use-Case-Slice (Application-Schicht: importiert Domain
// und Ports, nie Adapter).
package greet

// Command ist die Eingabe der greet-Use-Case.
type Command struct {
	// Message ist der rohe Gruss-Text.
	Message string
}
`

// goHexResult — Application-Slice: die Ausgabe.
const goHexResult = `package greet

// Result ist die Ausgabe der greet-Use-Case.
type Result struct {
	// Message ist der bestaetigte Gruss-Text.
	Message string
}
`

// goHexValidator — Application-Slice: Roh-Eingabe -> Domain (app -> domain).
const goHexValidator = `package greet

import "app/internal/hexagon/domain/example"

// Validate wandelt die Roh-Eingabe in ein Domain-Greeting (app -> domain).
func Validate(cmd Command) (example.Greeting, error) {
	return example.NewGreeting(cmd.Message)
}
`

// goHexHandler — Application-Slice: der Use-Case-Handler (app -> domain, app -> ports).
const goHexHandler = `package greet

import (
	areaports "app/internal/hexagon/application/example/ports"
	sliceports "app/internal/hexagon/application/example/greet/ports"
)

// Handler fuehrt die greet-Use-Case aus (app -> domain, app -> ports).
type Handler struct {
	repo     areaports.GreetingRepository
	notifier sliceports.Notifier
}

// NewHandler verdrahtet den Handler mit seinen Ports.
func NewHandler(repo areaports.GreetingRepository, notifier sliceports.Notifier) *Handler {
	return &Handler{repo: repo, notifier: notifier}
}

// Handle validiert die Eingabe zu einem Domain-Greeting und persistiert/annonciert es.
func (h *Handler) Handle(cmd Command) (Result, error) {
	greeting, err := Validate(cmd)
	if err != nil {
		return Result{}, err
	}
	if err := h.repo.Save(greeting); err != nil {
		return Result{}, err
	}
	if err := h.notifier.Notify(greeting); err != nil {
		return Result{}, err
	}
	return Result{Message: greeting.Message}, nil
}
`

// goHexHandlerTest — Handler-Test mit Stub-Ports (external Test-Package).
const goHexHandlerTest = `package greet_test

import (
	"testing"

	"app/internal/hexagon/application/example/greet"
	"app/internal/hexagon/domain/example"
)

type stubRepo struct{}

func (stubRepo) Save(example.Greeting) error { return nil }

type stubNotifier struct{}

func (stubNotifier) Notify(example.Greeting) error { return nil }

func TestHandlerHandle(t *testing.T) {
	h := greet.NewHandler(stubRepo{}, stubNotifier{})
	res, err := h.Handle(greet.Command{Message: "hi"})
	if err != nil {
		t.Fatalf("unerwarteter Fehler: %v", err)
	}
	if res.Message != "hi" {
		t.Errorf("Message = %q, want hi", res.Message)
	}
}
`

// goHexInboundCLI — Inbound-Adapter (adapter -> app).
const goHexInboundCLI = `// Package cli ist der Inbound-CLI-Adapter der example-Area (treibt die Use-Case;
// Adapter-Schicht -> Application).
package cli

import (
	"fmt"
	"io"

	"app/internal/hexagon/application/example/greet"
)

// Runner treibt die greet-Use-Case von der Kommandozeile (adapter -> app).
type Runner struct {
	handler *greet.Handler
	out     io.Writer
}

// NewRunner verdrahtet den CLI-Adapter mit dem Handler und der Ausgabe.
func NewRunner(handler *greet.Handler, out io.Writer) *Runner {
	return &Runner{handler: handler, out: out}
}

// Run fuehrt die Use-Case aus und schreibt das Ergebnis.
func (r *Runner) Run(message string) error {
	res, err := r.handler.Handle(greet.Command{Message: message})
	if err != nil {
		return err
	}
	_, err = fmt.Fprintln(r.out, res.Message)
	return err
}
`

// goHexOutboundRepo — Outbound-Adapter, erfuellt den GreetingRepository-Port
// strukturell (adapter -> domain; kein Port-Import).
const goHexOutboundRepo = `// Package memory ist ein In-Memory-Outbound-Adapter der example-Area (erfuellt den
// GreetingRepository-Port strukturell; verdrahtet im Composition Root).
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

// goHexOutboundNotify — Outbound-Adapter, erfuellt den Notifier-Port strukturell
// (adapter -> domain; kein Port-Import).
const goHexOutboundNotify = `// Package notify ist ein Outbound-Adapter, der Greetings auf einen io.Writer annonciert
// (erfuellt den Notifier-Port strukturell; verdrahtet im Composition Root).
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

	cli "app/internal/adapters/inbound/cli/example"
	memory "app/internal/adapters/outbound/memory/example"
	"app/internal/adapters/outbound/notify"
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
