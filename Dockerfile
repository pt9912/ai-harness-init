# syntax=docker/dockerfile:1.7
# Dockerfile — ai-harness-init (Muster: a-check/d-check, gleiche Build-Familie).
# Jede Go-Gate ist eine Stage (`docker build --target …`); die Bases sind
# digest-gepinnt (LH-QA-02, Reproduzierbarkeit). Hier (slice-001a): deps + test
# (go test, slice-001a) und compile / lint / build (slice-001b).
#
# GO_VERSION + GOLANGCI_LINT_VERSION spiegeln das Schwester-Repo a-check (1.26.4 /
# v2.12.2); die Base-Digests sind dieselben wie dort. Kein Host-go/-golangci-lint
# (Docker-only, ADR-0003) — die Aufrufe leben hier im Dockerfile, nicht im Bash.
ARG GO_VERSION=1.26.5
ARG GOLANGCI_LINT_VERSION=v2.12.2

# ---- deps ------------------------------------------------------------------
FROM golang:${GO_VERSION}@sha256:3aff6657219a4d9c14e27fb1d8976c49c29fddb70ba835014f477e1c70636647 AS deps
WORKDIR /src
ENV GOFLAGS="-mod=readonly -buildvcs=false" \
    GOMODCACHE=/go/pkg/mod \
    GOCACHE=/root/.cache/go-build
COPY go.mod ./
COPY go.su[m] ./
RUN mkdir -p "$GOMODCACHE" && go mod download

# ---- test ------------------------------------------------------------------
# ---- warm ------------------------------------------------------------------
# Vorwaerm-Stufe (slice-057): uebersetzt die Standardbibliothek EINMAL in den
# Kompilat-Cache DIESER SCHICHT. Das Modul hat keine externen Abhaengigkeiten, die
# Standardbibliothek ist also der gesamte teilbare Anteil; die eigenen Pakete aendern
# sich pro Lauf und bleiben ausserhalb.
#
# Warum eine Schicht und kein --mount=type=cache: der Mount ist in dieser Umgebung
# zwar aktiv (eigenes Dateisystem im Build), aber sein Inhalt erreicht den naechsten
# Build nicht — vier Erklaerungen wurden gemessen und ausgeschlossen, die Ursache
# liegt tiefer (Messreihe in docs/plan/planning/done/slice-057-go-kompilat-cache.md).
# Eine Schicht dagegen cacht Docker hier nachweislich; sie haengt nur am Basis-Image
# und an go.mod, waehrend --no-cache-filter nur die test-Stufe neu ausfuehrt.
FROM deps AS warm
RUN CGO_ENABLED=0 go build std

# ---- test ------------------------------------------------------------------
# -count=1 gehoert zum Vorwaermen und ist NICHT redundant: mit warmem Kompilat-Cache
# wuerde das Test-Werkzeug unveraenderte Pakete mit "(cached)" ueberspringen. Fuer ein
# Gate waere das eine Zusage, die der Lauf nicht mehr einloest. --no-cache-filter
# (Makefile) erzwingt, dass die SCHICHT neu ausgefuehrt wird; -count=1, dass die TESTS
# neu laufen. Zwei Ebenen, nicht eine — test/dockerfile-teststufe.bats prueft es,
# test/mutations/98 nimmt es weg.
FROM warm AS test
COPY . .
RUN CGO_ENABLED=0 go test -count=1 ./...

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
# Release-Binary. TARGET_OS/TARGET_ARCH waehlen die Zielplattform (LH-QA-04);
# LEER gelassen bauen sie fuer die Plattform des Build-Images — der bisherige
# Default-Pfad bleibt damit byte-identisch (`make build`, `artifact`, beide Smokes
# haengen daran). Leere GOOS/GOARCH sind fuer die Toolchain dasselbe wie ungesetzt.
# Bewusst NICHT die BuildKit-eigenen TARGETOS/TARGETARCH: die haengen an der
# --platform des Builds und wuerden zusaetzlich das Base-Image emulieren; hier soll
# nur cross-kompiliert werden, im selben gepinnten Image (LH-QA-02).
FROM deps AS build
ARG TARGET_OS=
ARG TARGET_ARCH=
COPY . .
RUN CGO_ENABLED=0 GOOS=${TARGET_OS} GOARCH=${TARGET_ARCH} \
    go build -trimpath -ldflags="-s -w" -o /out/ai-harness-init ./cmd/ai-harness-init

# ---- span ------------------------------------------------------------------
# Der Span-Emitter (slice-059). EIGENE Stage und EIGENES Binary, KEIN Subkommando
# von ai-harness-init: ob der EMITTIERTE Harness einen Emitter bekommt, entscheidet
# slice-062 — ein Subkommando haette diese Entscheidung vorweggenommen, weil es mit
# dem Produkt-Binary beim Adopter landete (welle-09 §4). Der Hook laesst das Binary
# auf dem HOST laufen; `make span-check` holt es hier heraus.
FROM deps AS span
COPY . .
RUN CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /out/span-emit ./cmd/span-emit
