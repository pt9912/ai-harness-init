package gen

import "strings"

// DefaultGoVersion ist der gepinnte Go-Toolchain-Default des generierten Skeletts
// (LH-QA-02: kein floating). An das Repo-Dockerfile gekoppelt
// (TestGoProfile_PinsMatchRepo), damit ein Bump nicht die eine Haelfte bewegt und
// die andere vergisst. Ueberschreibbar beim Bootstrap (SKEL_GO_VERSION, cmd) — der
// Generator selbst bleibt deterministisch: gleiche goVersion -> byte-identische
// Ausgabe.
const DefaultGoVersion = "1.26.4"

// golangciVersion ist der gepinnte golangci-lint-Tag des generierten Skeletts.
const golangciVersion = "v2.12.2"

// goProfile ist das Go-Layout fuer die gegebene Go-Version (ADR-0003 Docker-only):
// Go-Gates als Dockerfile-Stages; die Root-Makefile ist ein sprach-agnostischer
// Aggregator (include harness/mk/*.mk), und das Code-Gate-Fragment harness/mk/go.mk
// traegt die --target-Aufrufe + haengt lint/build/test an GATE_CHECKS (slice-034,
// Fragment-Assembly). Dazu go.mod + .golangci.yml und ein baubares cmd/app/main.go.
//
// Die Images sind TAG-gepinnt (golang:<ver>, golangci-lint:<ver>) — kein floating
// (LH-QA-02), aber bewusst OHNE Digest: ein Digest wuerde die Go-Version
// festnageln und den GO_VERSION-Knopf wirkungslos machen. go (major.minor) in
// go.mod leitet sich aus goVersion ab, damit die Sprachversion zur Toolchain passt.
//
// Jedes Target im Code-Gate-Fragment (harness/mk/go.mk), das `docker build
// --target <stage>` ruft, hat eine gleichnamige Dockerfile-Stage (test/lint/build)
// — kein halluziniertes Gate (LH-QA-01); TestGenerate_GoMkTargetsMatchStages haelt
// die Kopplung fest.
func goProfile(goVersion string) map[string]string {
	return map[string]string{
		"go.mod":           "module app\n\ngo " + majorMinor(goVersion) + "\n",
		"Dockerfile":       render(goDockerfileTmpl, goVersion),
		"Makefile":         aggregatorMakefile,
		"harness/mk/go.mk": render(goMkFragmentTmpl, goVersion),
		".golangci.yml":    goGolangci,
		"cmd/app/main.go":  goMain,
	}
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

// render setzt goVersion + den golangci-Pin in ein Template ein ({{…}}-Platzhalter,
// eine Stelle je Wert). strings.Replacer statt fmt.Sprintf, weil die Templates
// literale %-Verben tragen (das awk im Makefile-help-Target).
func render(tmpl, goVersion string) string {
	return strings.NewReplacer(
		"{{GO_VERSION}}", goVersion,
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

// aggregatorMakefile — die sprach-agnostische Root-Makefile: ein duenner Aggregator,
// der die Gate-Fragmente (harness/mk/*.mk) einbindet. KEIN {{…}}-Platzhalter (die
// GO_VERSION lebt im Code-Gate-Fragment); die Recipe-Zeile ist TAB-eingerueckt.
// slice-034: ersetzt das fruehere gates: lint build test + die wire-Inline-Anhaenge;
// slice-035 zieht diese Datei in einen Init-Emitter um (Phasierung, Relocation).
const aggregatorMakefile = `# Makefile — generiert von ai-harness-init (Aggregator, slice-034). Die Gate-Belange
# leben als Fragmente unter harness/mk/*.mk; jedes haengt seine Checks an GATE_CHECKS.
# Der Gate-Nachweis (record-gates) laeuft strikt ZULETZT via Ordnungskante auf
# GATE_CHECKS — waehrend make -j die Checks parallelisiert; .NOTPARALLEL ist bewusst
# NICHT gewaehlt (das serialisierte das ganze Makefile).
GATE_CHECKS :=

.PHONY: gates help

# Gate-Fragmente je Belang (baseline/doc-gate/enforce + Sprach-Code-Gates) einbinden.
# Alphabetisch (baseline < doc-gate < enforce < <lang>); die Ordnungskante unten steht
# NACH dem Include und sieht GATE_CHECKS damit vollstaendig.
include harness/mk/*.mk

help: ## Diese Hilfe
	@grep -hE '^[a-z-]+:.*##' $(MAKEFILE_LIST) | sort | awk 'BEGIN{FS=":.*##"}{printf "  %-14s %s\n",$$1,$$2}'

# gates haengt allein an record-gates; record-gates haengt an ALLEN akkumulierten
# Checks — der Nachweis laeuft strikt nach den Checks (Ordnungskante), waehrend make
# -j die Checks parallel faehrt. Das record-gates-Rezept liefert harness/mk/enforce.mk.
gates: record-gates ## Alle Gates (Checks parallel, Nachweis zuletzt)
record-gates: $(GATE_CHECKS)
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
