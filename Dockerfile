# syntax=docker/dockerfile:1.7
# Dockerfile — ai-harness-init (Muster: a-check/d-check, gleiche Build-Familie).
# Jede Go-Gate ist eine Stage (`docker build --target …`); die Bases sind
# digest-gepinnt (LH-QA-02, Reproduzierbarkeit). Hier (slice-001a): deps + test
# (go test, slice-001a) und compile / lint / build (slice-001b).
#
# GO_VERSION + GOLANGCI_LINT_VERSION spiegeln das Schwester-Repo a-check (1.26.4 /
# v2.12.2); die Base-Digests sind dieselben wie dort. Kein Host-go/-golangci-lint
# (Docker-only, ADR-0003) — die Aufrufe leben hier im Dockerfile, nicht im Bash.
ARG GO_VERSION=1.26.4
ARG GOLANGCI_LINT_VERSION=v2.12.2

# ---- deps ------------------------------------------------------------------
FROM golang:${GO_VERSION}@sha256:792443b89f65105abba56b9bd5e97f680a80074ac62fc844a584212f8c8102c3 AS deps
WORKDIR /src
ENV GOFLAGS="-mod=readonly -buildvcs=false" \
    GOMODCACHE=/go/pkg/mod \
    GOCACHE=/root/.cache/go-build
COPY go.mod ./
COPY go.su[m] ./
RUN mkdir -p "$GOMODCACHE" && go mod download

# ---- test ------------------------------------------------------------------
FROM deps AS test
COPY . .
RUN CGO_ENABLED=0 go test ./...

# ---- compile ---------------------------------------------------------------
# Schnelles Compile-Feedback (ohne Tests/Lint).
FROM deps AS compile
COPY . .
RUN CGO_ENABLED=0 go build -o /tmp/ai-harness-init ./cmd/ai-harness-init

# ---- lint ------------------------------------------------------------------
FROM golangci/golangci-lint:${GOLANGCI_LINT_VERSION}@sha256:5cceeef04e53efe1470638d4b4b4f5ceefd574955ab3941b2d9a68a8c9ad5240 AS lint
WORKDIR /src
ENV GOFLAGS="-buildvcs=false"
COPY --from=deps /go/pkg/mod /go/pkg/mod
COPY . .
RUN golangci-lint run ./...

# ---- build -----------------------------------------------------------------
# Cross-Compile des Binaries im gepinnten Image (LH-QA-02; kein Host-go). Zugleich
# die Extraktions-Quelle: `make artifact DEST=…` kopiert /out/ai-harness-init per
# `docker cp` aus DIESER Stage auf den Host (fuer die Smokes). Der Smoke laesst die
# Binary auf dem HOST laufen, weil sie selbst `docker run <d-check> --print-mk`
# ruft (kein DinD im Container). Kein OCI-Image als Vertriebsmittel (ADR-0003).
FROM deps AS build
COPY . .
RUN CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /out/ai-harness-init ./cmd/ai-harness-init
