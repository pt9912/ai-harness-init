# syntax=docker/dockerfile:1.7
# Dockerfile — ai-harness-init (Muster: a-check/d-check, gleiche Build-Familie).
# Jede Go-Gate ist eine Stage (`docker build --target …`); die Bases sind
# digest-gepinnt (LH-QA-02, Reproduzierbarkeit). Hier (slice-001a): deps + test
# (go test, slice-001a) und compile / lint / build (slice-001b).
#
# GO_VERSION + GOLANGCI_LINT_VERSION sind die Toolchain-Pins dieses Repos; jeder Base-Tag ist
# per @sha256 auf seinen Manifest-Digest gepinnt (Drift melden make freshness-go/-golangci).
# Kein Host-go/-golangci-lint (Docker-only, ADR-0003) — die Aufrufe leben hier im Dockerfile, nicht im Bash.
ARG GO_VERSION=1.27.0
ARG GOLANGCI_LINT_VERSION=v2.13.1

# ---- deps ------------------------------------------------------------------
FROM golang:${GO_VERSION}@sha256:65b6f280bf050ec5af12716857e8ea8439d694dbba8f31ceeb7630670071f2bb AS deps
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
FROM golangci/golangci-lint:${GOLANGCI_LINT_VERSION}@sha256:d371321370bf2907bd13a8f6f8baff0e0ca7438d76fdf636b281eadf7e2305e3 AS lint
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
# TARGET_OS/TARGET_ARCH wie in der build-Stage (LH-QA-04): der Emitter laeuft am HOOK
# und damit auf dem HOST, nicht im Container. Ohne die zwei Schalter entstuende immer
# ein Linux-ELF, und `make gates` scheiterte auf einem macOS-Host mit "exec format
# error" (Review-Befund MEDIUM-2). Go kann das laengst — der Bau tat es nur nicht.
FROM deps AS span
ARG TARGET_OS=
ARG TARGET_ARCH=
COPY . .
RUN CGO_ENABLED=0 GOOS=${TARGET_OS} GOARCH=${TARGET_ARCH} \
    go build -trimpath -ldflags="-s -w" -o /out/span-emit ./cmd/span-emit

# ---- report ----------------------------------------------------------------
# Die Auswertung (slice-066). EIGENE Stage und EIGENES Binary aus demselben Grund
# wie beim Emitter: kein Subkommando des Produkt-Binaries, sonst landete die
# Entscheidung ueber eine emittierte Auswertung beim Adopter, bevor sie getroffen
# ist.
# KEIN TARGET_OS/TARGET_ARCH und KEIN artifact-copy: anders als der Emitter laeuft
# die Auswertung nicht am Hook auf dem Host, sondern unter `make` IM Container ueber
# einem read-only gemounteten Bestand. Ein Host-Binary waere ein Artefakt ohne
# Leser.
FROM deps AS report
COPY . .
RUN CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /out/span-report ./cmd/span-report
ENTRYPOINT ["/out/span-report"]
