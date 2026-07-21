package gen

// goProfile ist das Go-Layout (ADR-0003 Docker-only): die Go-Gates leben als
// Dockerfile-Stages, das Makefile faehrt sie, dazu eine minimale go.mod +
// .golangci.yml und ein baubares cmd/app/main.go. Alle Werte STATISCH
// (Determinismus, LH-QA-02). Die Base-/Lint-Pins spiegeln den Tool-Stand
// (Wartungslast, ADR-0005 §Konsequenzen — bewusst klein gehalten).
//
// Jedes Makefile-Target, das `docker build --target <stage>` ruft, hat eine
// gleichnamige Dockerfile-Stage (test/lint/build) — kein halluziniertes Gate
// (LH-QA-01); TestGenerate_MakefileTargetsMatchStages haelt die Kopplung fest.
func goProfile() map[string]string {
	return map[string]string{
		"go.mod":          goMod,
		"Dockerfile":      goDockerfile,
		"Makefile":        goMakefile,
		".golangci.yml":   goGolangci,
		"cmd/app/main.go": goMain,
	}
}

const goMod = `module app

go 1.26
`

const goMain = `// Command app — vom ai-harness-init generiertes Go-Skelett.
package main

func main() {}
`

const goDockerfile = `# syntax=docker/dockerfile:1.7
# Dockerfile — generiert von ai-harness-init (Go-Skelett). Jede Go-Gate ist eine
# Stage (docker build --target <stage>); die Bases sind digest-gepinnt (LH-QA-02).
ARG GO_VERSION=1.26.4
ARG GOLANGCI_LINT_VERSION=v2.12.2

FROM golang:${GO_VERSION}@sha256:792443b89f65105abba56b9bd5e97f680a80074ac62fc844a584212f8c8102c3 AS deps
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

FROM golangci/golangci-lint:${GOLANGCI_LINT_VERSION}@sha256:5cceeef04e53efe1470638d4b4b4f5ceefd574955ab3941b2d9a68a8c9ad5240 AS lint
WORKDIR /src
ENV GOFLAGS="-buildvcs=false"
COPY --from=deps /go/pkg/mod /go/pkg/mod
COPY . .
RUN golangci-lint run ./...

FROM deps AS build
COPY . .
RUN CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /out/app ./cmd/app
`

// goMakefile — die Recipe-Zeilen sind TAB-eingerueckt (Makefile-Pflicht).
const goMakefile = `# Makefile — generiert von ai-harness-init (Go-Skelett). Go-Gates als
# Dockerfile-Stages (Docker-only, ADR-0003); der Doc-Gate-Include (d-check.mk)
# wird beim Init-Flow verdrahtet.
GO_VERSION ?= 1.26.4
GOLANGCI_LINT_VERSION ?= v2.12.2
IMAGE ?= app

.PHONY: gates test lint build help

help: ## Diese Hilfe
	@grep -hE '^[a-z-]+:.*##' $(MAKEFILE_LIST) | sort | awk 'BEGIN{FS=":.*##"}{printf "  %-10s %s\n",$$1,$$2}'

test: ## Go-Unit-Tests (Dockerfile test-Stage) — Docker-only
	docker build --no-cache-filter test --build-arg GO_VERSION=$(GO_VERSION) --target test -t $(IMAGE):test .

lint: ## Go-Lint (golangci-lint, Dockerfile lint-Stage) — Docker-only
	docker build --build-arg GOLANGCI_LINT_VERSION=$(GOLANGCI_LINT_VERSION) --target lint -t $(IMAGE):lint .

build: ## Go-Binary bauen (Dockerfile build-Stage) — Docker-only
	docker build --build-arg GO_VERSION=$(GO_VERSION) --target build -t $(IMAGE):build .

gates: lint build test ## Alle Go-Gates
`

const goGolangci = `version: "2"
linters:
  default: none
  enable:
    - errcheck
    - govet
    - ineffassign
    - staticcheck
    - unused
`
