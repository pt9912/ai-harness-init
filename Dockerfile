# syntax=docker/dockerfile:1.7
# Dockerfile — ai-harness-init (Muster: a-check/d-check, gleiche Build-Familie).
# Jede Go-Gate ist eine Stage (`docker build --target …`); die Bases sind
# digest-gepinnt (LH-QA-02, Reproduzierbarkeit). Hier (slice-001a): deps + test
# (go test). Die Stages compile / lint / build folgen in slice-001b.
#
# GO_VERSION spiegelt das Schwester-Repo a-check (1.26.4); der golang-Base-Digest
# ist derselbe wie dort (offizielles golang:1.26.4). Kein Host-go (Docker-only,
# ADR-0003) — die go-Aufrufe leben hier im Dockerfile, nicht im Bash-Command.
ARG GO_VERSION=1.26.4

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
