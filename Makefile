# ai-harness-init — Gates. Doc-Gate via d-check-Fragment (d-check.mk, aus
# `d-check --print-mk`, MR-010); test (bats
# Command-Guard) und shell-lint (shellcheck) sind da; Go-lint/build
# (golangci-lint/go build) kommen mit dem Go-Code (keine halluzinierten Gates).
include d-check.mk

# Tool-Images digest-gepinnt (Reproduzierbarkeit, LH-QA-02; Docker-only, ADR-0003).
BATS_IMAGE ?= bats/bats@sha256:e8f18e0acd4ea933bf019130b85033be75e8ce081db299e93578de83d7874e33
SHELLCHECK_IMAGE ?= koalaman/shellcheck@sha256:bb596a0d169b85ddd81d8b6d3a2ff6d5baf5fca10b97f575ebc647c3dff62b3d

# Go-Toolchain-Version (Dockerfile-Stages, a-check gespiegelt); der Base-Digest
# steht digest-gepinnt im Dockerfile (LH-QA-02). Go-Gates leben im Makefile
# (NICHT d-check.mk) und treiben Dockerfile-Stages via `docker build --target`.
GO_VERSION ?= 1.26.4
GOLANGCI_LINT_VERSION ?= v2.12.2

# Vendored Baseline (MR-007): Regelwerk UND Templates liegen committet unter
# .harness/baseline/$(BASELINE_TAG)/{regelwerk,templates}/ + SHA256SUMS —
# netzlos auf jedem Checkout präsent, kein Fetch pro Lauf.
#
# BASELINE_TAG ist die EINZIGE Quelle des Tag-Strings in der Mechanik: der
# Injektor und baseline-verify ENTDECKEN das Verzeichnis (Setzung: ein Tag zur
# Zeit), .d-check.yml nutzt einen Glob. Ein Tag-Bump ändert damit diese Zeile,
# BASELINE_ZIP_SHA256 und den Baum — keinen repo-weiten Grep (LH-QA-02).
BASELINE_TAG ?= v3.1.0
# Kein BASELINE_DIR: baseline-verify und der Injektor ENTDECKEN das <tag>-
# Verzeichnis per Glob (Setzung "ein Tag zur Zeit"), lesen es also nicht aus
# einer Variablen — ein solcher Pfad-Override wäre stiller No-op.
# Upstream-PROVENIENZ (nicht lokale Integrität — die trägt SHA256SUMS im Baum):
# sha256 des Release-Assets, aus dem der Baum stammt. SHA256SUMS ist selbst
# erzeugt und beweist die Herkunft NICHT; diese Kette hängt allein hier.
# regelwerk-check vergleicht Upstream gegen diesen Pin (MR-007).
BASELINE_URL ?= https://github.com/pt9912/ai-harness-course/releases/download/$(BASELINE_TAG)/lab-regelwerk.zip
BASELINE_ZIP_SHA256 ?= bd90c721e7583b218d097def8abac42fb0544c7a140e2e649d71e772f7a90220

.PHONY: help gates record-gates test lint build compile smoke shell-lint baseline-verify regelwerk-check baseline-freshness
help: ## Targets anzeigen
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  %-14s %s\n", $$1, $$2}'

test: ## Harness-Tests (bats) + Go-Unit-Tests (go test in Docker) — Docker-only (ADR-0003/0004)
	docker run --rm --network none -v "$(CURDIR)":/code:ro -w /code $(BATS_IMAGE) test/
	docker build --no-cache-filter test --build-arg GO_VERSION=$(GO_VERSION) --target test -t ai-harness-init:test .

lint: ## Go-Lint (golangci-lint, Dockerfile lint-Stage, gepinntes Image) — Docker-only (ADR-0003)
	docker build --no-cache-filter lint --build-arg GO_VERSION=$(GO_VERSION) --build-arg GOLANGCI_LINT_VERSION=$(GOLANGCI_LINT_VERSION) --target lint -t ai-harness-init:lint .

build: ## Go-Binary cross-compilieren (Dockerfile build-Stage, gepinntes Image) — Docker-only (ADR-0003)
	docker build --build-arg GO_VERSION=$(GO_VERSION) --target build -t ai-harness-init:build .

compile: ## Schnelles Compile-Feedback (Dockerfile compile-Stage, ohne Tests/Lint) — Docker-only; NICHT in gates
	docker build --build-arg GO_VERSION=$(GO_VERSION) --target compile -t ai-harness-init:compile .

# Tier-2 Emit-Smoke (slice-002): der ehrliche Green-Run des EMITTIERTEN Doc-Gates.
# Extrahiert das Binary auf den Host (die Binary ruft selbst docker run d-check
# --print-mk), emittiert in ein tmp-Repo und laesst dort docs-check real laufen.
# Host-Docker + ggf. Netz-Pull -> NICHT in gates (make gates bleibt offline-schlank,
# LH-QA-01); gehoert an DoD-Verify/CI/Wellen-Closure. Logik in harness/tools/ (shell-lint).
smoke: ## Emit-Smoke: Doc-Gate in tmp-Repo emittieren + emittiertes docs-check real gruen (Host-Docker) — NICHT in gates
	@GO_VERSION='$(GO_VERSION)' bash harness/tools/smoke.sh

# shellcheck über die harness-eigenen Shell-Hooks/-Helfer. .bats ist
# ausgenommen (shellcheck parst die @test-Syntax nicht); .awk ist kein Shell.
shell-lint: ## Shell-Hooks/-Helfer linten (shellcheck) im gepinnten Image — Docker-only (ADR-0003)
	docker run --rm -v "$(CURDIR)":/mnt:ro -w /mnt $(SHELLCHECK_IMAGE) \
		.claude/hooks/*.sh harness/tools/*.sh

# Verifiziert die vendored Baseline NETZLOS: sha256sum -c über SHA256SUMS
# (fängt geänderte/gelöschte Dateien) PLUS Vollständigkeits-Check (fängt
# zusätzlich eingelegte — dafür ist sha256sum -c blind, es prüft nur Gelistetes).
# Ohne den zweiten Schritt wäre "prüft die Integrität der Arbeitskopie"
# überdehnt. Läuft IN gates: kein curl/unzip, kein Netz -> offline-grün bleibt
# (LH-QA-01/02/03; MR-007). Logik in harness/tools/, damit shell-lint sie deckt.
baseline-verify: ## Vendored Baseline netzlos verifizieren (Integrität + Vollständigkeit) — IN gates
	@bash harness/tools/baseline-verify.sh

# Read-only Drift-Monitor: holt das Upstream-ZIP in eine temp-Datei (der
# vendored Baum bleibt UNBERUEHRT) und vergleicht dessen sha256 mit dem
# Provenienz-Pin (BASELINE_ZIP_SHA256, MR-007). Der einzige Upstream-Sensor —
# baseline-verify prüft nur die eigene Arbeitskopie, nie den Upstream.
# Maintenance/CI (Netz, Host-curl), NICHT in gates (LH-QA-01).
# Recipe-Exit: 0 = kein Drift, 1 = DRIFT, 2 = Fetch-Fehler. Hinweis: `make`
# kollabiert jeden Recipe-Fehler auf Exit 2 (Standard-Make) — fuer CI also
# 0 = OK, !=0 = Alarm; ob Drift oder Fetch-Fehler sagt die echo-Meldung (kanonisch;
# die make-"Fehler N"-Zeile spiegelt den Recipe-Exit, ist aber locale-/stderr-fragil).
regelwerk-check: ## Upstream-Drift des Baseline-ZIP melden (read-only, Baum unberührt) — Maintenance/CI, NICHT in gates
	@tmp="$$(mktemp)"; \
	curl -fsSL "$(BASELINE_URL)" -o "$$tmp" \
		|| { rm -f "$$tmp"; echo "FETCH-FEHLER (kein Drift-Urteil): Upstream nicht erreichbar — $(BASELINE_URL)"; exit 2; }; \
	if printf '%s  %s\n' "$(BASELINE_ZIP_SHA256)" "$$tmp" | sha256sum -c - >/dev/null 2>&1; then \
		rm -f "$$tmp"; echo "Kein Drift: Upstream-ZIP ($(BASELINE_TAG)) == gepinnter BASELINE_ZIP_SHA256."; \
	else \
		got="$$(sha256sum "$$tmp" | cut -d' ' -f1)"; rm -f "$$tmp"; \
		echo "DRIFT: Upstream-ZIP ($(BASELINE_TAG)) != gepinnter BASELINE_ZIP_SHA256 (vendored Baum UNVERAENDERT)."; \
		echo "  gepinnt:  $(BASELINE_ZIP_SHA256)"; \
		echo "  upstream: $$got"; \
		echo "  -> manuell re-reviewen, dann Baum neu vendoren + BASELINE_TAG/BASELINE_ZIP_SHA256 neu setzen."; \
		exit 1; \
	fi
	@echo "Hinweis: prüft NUR das Asset von $(BASELINE_TAG). Ein NEUER Tag upstream bleibt hier unsichtbar — 'make baseline-freshness' prüft die Release-Liste (slice-018, MR-007)."

# Read-only Freshness-Sensor: folgt dem releases/latest-Redirect und meldet einen
# NEUEREN Upstream-Tag als BASELINE_TAG (Release-LISTEN-Achse) — ergaenzt
# regelwerk-checks Asset-Achse (MR-007-Luecke). Maintenance/CI (Netz, Host-curl),
# NICHT in gates (LH-QA-01: make gates bleibt offline-gruen). Skript-Exit: 0 =
# aktuell, 1 = VERALTET, 2 = Fetch-Fehler — aber `make` kollabiert jeden
# Nonzero-Recipe-Exit auf sein Exit 2 (fuer CI: 0 = aktuell, !=0 = Alarm; ob
# veraltet oder Fetch-Fehler sagt die echo-Meldung, wie bei regelwerk-check).
# Mutiert nichts; Logik in harness/tools/ (shell-lint deckt sie),
# Fetch<->Vergleich getrennt (hermetisch testbar).
baseline-freshness: ## Neueren Upstream-Tag als BASELINE_TAG melden (read-only) — Maintenance/CI, NICHT in gates
	@BASELINE_TAG='$(BASELINE_TAG)' RELEASES_LATEST_URL='https://github.com/pt9912/ai-harness-course/releases/latest' bash harness/tools/baseline-freshness.sh

record-gates: ## Gate-Nachweis schreiben (Working-Tree-Hash für den Stop-Hook)
	@bash harness/tools/record-gates.sh

# baseline-verify läuft als ERSTER Prerequisite: steht die vendored Baseline
# nicht, ist jede Aussage der Folge-Gates über sie wertlos. record-gates läuft
# als LETZTER — der Nachweis entsteht nur nach grünen Gates (MR-002).
gates: baseline-verify docs-check lint build test shell-lint record-gates ## alle aktuell lauffähigen Gates + Nachweis
