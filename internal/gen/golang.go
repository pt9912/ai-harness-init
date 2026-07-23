package gen

import "strings"

// DefaultGoVersion ist der gepinnte Go-Toolchain-Default des generierten Skeletts
// (LH-QA-02: kein floating). An das Repo-Dockerfile gekoppelt
// (TestGoProfile_PinsMatchRepo), damit ein Bump nicht die eine Haelfte bewegt und
// die andere vergisst. Ueberschreibbar beim Bootstrap (SKEL_GO_VERSION, cmd) — der
// Generator selbst bleibt deterministisch: gleiche version -> byte-identische
// Ausgabe.
const DefaultGoVersion = "1.26.4"

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
func goProfile(version string) map[string]string {
	return map[string]string{
		"go.mod":          "module app\n\ngo " + majorMinor(version) + "\n",
		"Dockerfile":      render(goDockerfileTmpl, version),
		".golangci.yml":   goGolangci,
		"cmd/app/main.go": goMain,
	}
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
