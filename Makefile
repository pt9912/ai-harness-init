# ai-harness-init — Gates. Doc-Gate via d-check-Fragment (d-check.mk, aus
# `d-check --print-mk`, MR-010); test (bats
# Command-Guard) und shell-lint (shellcheck) sind da; Go-lint/build
# (golangci-lint/go build) kommen mit dem Go-Code (keine halluzinierten Gates).
include d-check.mk

# Tool-Images digest-gepinnt (Reproduzierbarkeit, LH-QA-02; Docker-only, ADR-0003).
BATS_IMAGE ?= bats/bats@sha256:e8f18e0acd4ea933bf019130b85033be75e8ce081db299e93578de83d7874e33
SHELLCHECK_IMAGE ?= koalaman/shellcheck@sha256:bb596a0d169b85ddd81d8b6d3a2ff6d5baf5fca10b97f575ebc647c3dff62b3d
ACTIONLINT_IMAGE ?= rhysd/actionlint@sha256:b1934ee5f1c509618f2508e6eb47ee0d3520686341fec936f3b79331f9315667

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
BASELINE_TAG ?= v3.5.0
# Kein BASELINE_DIR: baseline-verify und der Injektor ENTDECKEN das <tag>-
# Verzeichnis per Glob (Setzung "ein Tag zur Zeit"), lesen es also nicht aus
# einer Variablen — ein solcher Pfad-Override wäre stiller No-op.
# Upstream-PROVENIENZ (nicht lokale Integrität — die trägt SHA256SUMS im Baum):
# sha256 des Release-Assets, aus dem der Baum stammt. SHA256SUMS ist selbst
# erzeugt und beweist die Herkunft NICHT; diese Kette hängt allein hier.
# regelwerk-check vergleicht Upstream gegen diesen Pin (MR-007).
BASELINE_URL ?= https://github.com/pt9912/ai-harness-course/releases/download/$(BASELINE_TAG)/lab-regelwerk.zip
BASELINE_ZIP_SHA256 ?= 123e3383261102e6be6465e1f4bade08a474c00edc4fff89f5c4b11bd640f8ff

.PHONY: help gates record-gates test lint build compile artifact smoke full-smoke shell-lint ci-lint baseline-verify regelwerk-check baseline-freshness mutate
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

# Natives Release-Binary auf den Host ziehen (DEST=<dir>). Baut EINMAL (Prereq build,
# taggt ai-harness-init:build) und KOPIERT dann GETRENNT aus einem Wegwerf-Container —
# Build und Copy entkoppelt (kein --output-Fusion). Kein OCI-Image als Vertriebsmittel
# (ADR-0003); die Smokes lassen die Binary auf dem Host laufen (sie ruft selbst docker).
# Der Container wird immer aufgeraeumt (trap), auch wenn `docker cp` scheitert.
artifact: build ## Natives Release-Binary auf den Host ziehen (DEST=<dir>) — für die Smokes, Docker-only
	@test -n "$(DEST)" || { echo "artifact: DEST=<dir> ist Pflicht (Zielverzeichnis)"; exit 2; }
	@cid="$$(docker create ai-harness-init:build true)"; \
	trap 'docker rm -f "$$cid" >/dev/null 2>&1' EXIT; \
	docker cp "$$cid:/out/ai-harness-init" "$(DEST)/ai-harness-init"

compile: ## Schnelles Compile-Feedback (Dockerfile compile-Stage, ohne Tests/Lint) — Docker-only; NICHT in gates
	docker build --build-arg GO_VERSION=$(GO_VERSION) --target compile -t ai-harness-init:compile .

# Tier-2 Emit-Smoke (slice-002): der ehrliche Green-Run des EMITTIERTEN Doc-Gates.
# Extrahiert das Binary auf den Host (die Binary ruft selbst docker run d-check
# --print-mk), emittiert in ein tmp-Repo und laesst dort docs-check real laufen.
# Host-Docker + ggf. Netz-Pull -> NICHT in gates (make gates bleibt offline-schlank,
# LH-QA-01); gehoert an DoD-Verify/CI/Wellen-Closure. Logik in harness/tools/ (shell-lint).
smoke: ## Emit-Smoke: Doc-Gate in tmp-Repo emittieren + emittiertes docs-check real gruen (Host-Docker) — NICHT in gates
	@GO_VERSION='$(GO_VERSION)' bash harness/tools/smoke.sh

# Voll-E2E-Smoke (slice-024, LH-FA-01 Happy-Path): Bootstrap in ein tmp-Repo, dann
# dort der ZUSAMMENGEFUEHRTE `make gates` (MR-010: docs-check + Go-Gates kombiniert)
# — die Sicht des echten Nutzers, die der Tier-2 `make smoke` bewusst nicht nimmt.
# Host-Docker + ggf. Netz-Pull -> NICHT in gates (offline-schlank, LH-QA-01).
full-smoke: ## Voll-E2E: Bootstrap in tmp-Repo -> dort make gates out-of-the-box gruen (Host-Docker) — NICHT in gates
	@GO_VERSION='$(GO_VERSION)' bash harness/tools/full-smoke.sh

mutate: ## Mutations-Sensor fuer AGENTS 3.6: faerbt jede Mutation ihren Waechter rot? — NICHT in gates
	@bash harness/tools/mutate.sh

# shellcheck über die harness-eigenen Shell-Hooks/-Helfer. .bats ist
# ausgenommen (shellcheck parst die @test-Syntax nicht); .awk ist kein Shell.
shell-lint: ## Shell-Hooks/-Helfer linten (shellcheck) im gepinnten Image — Docker-only (ADR-0003)
	docker run --rm -v "$(CURDIR)":/mnt:ro -w /mnt $(SHELLCHECK_IMAGE) \
		.claude/hooks/*.sh harness/tools/*.sh internal/emit/templates/*.sh internal/emit/templates/enforce/*.sh test/mutations/*.sh

# GitHub-Actions-Workflows syntaktisch pruefen (actionlint, gepinntes Image) —
# Docker-only. IN gates, weil .github/workflows/ ein reales committetes Artefakt
# ist (kein leerer Pruefbereich, LH-QA-01) und ein Workflow-Syntaxfehler LOKAL
# vor dem Push fangbar ist, statt erst im ersten Actions-Lauf (slice-027; das
# lokale Gegenbeispiel-Gate zur Zusage "die CI laeuft", AGENTS 3.6).
# KEIN -color: die Ausgabe wird gegatet, geloggt und vom Mutations-Sensor
# gegrept — ANSI-Escapes zerstueckeln das `file:line:col:`-Praefix (real
# vorgefuehrt beim Bau von test/mutations/10). actionlint faerbt ohne TTY ohnehin
# nicht; das explizite -color war schaedlich.
ci-lint: ## GitHub-Actions-Workflows linten (actionlint) im gepinnten Image — Docker-only, IN gates
	docker run --rm -v "$(CURDIR)":/repo:ro -w /repo $(ACTIONLINT_IMAGE)

# Verifiziert die vendored Baseline NETZLOS: sha256sum -c über SHA256SUMS
# (fängt geänderte/gelöschte Dateien) PLUS Vollständigkeits-Check (fängt
# zusätzlich eingelegte — dafür ist sha256sum -c blind, es prüft nur Gelistetes).
# Ohne den zweiten Schritt wäre "prüft die Integrität der Arbeitskopie"
# überdehnt. Läuft IN gates: kein curl/unzip, kein Netz -> offline-grün bleibt
# (LH-QA-01/02/03; MR-007). Logik in harness/tools/, damit shell-lint sie deckt.
baseline-verify: ## Vendored Baseline netzlos verifizieren (Integrität + Vollständigkeit) — IN gates
	@bash harness/tools/baseline-verify.sh

# Upstream-Content-Drift des Baseline-ZIP via d-check `sources` (MR-013): d-check holt
# das per sha256 gepinnte Asset, hasht es (unpack: none = Roh-Bytes) und meldet Abweichung
# (source-drift, mit vollem Ist-Hash zum Re-Pinnen) bzw. Netzfehler (source-unreachable).
# Loest den frueheren Eigenbau (curl+sha256sum) ab — "Tool statt Skript". Der Pin lebt
# kanonisch im Makefile (BASELINE_ZIP_SHA256, MR-007) und dupliziert in .d-check.yml
# `sources:`; test/sources-pin.bats koppelt beide (fail-closed bei Divergenz, in gates).
# Auf `sources` isoliert (die Doku-Module deckt docs-check ab). Netz (kein --network none),
# Maintenance/CI, NICHT in gates (LH-QA-01). baseline-verify prueft nur die Arbeitskopie;
# baseline-freshness die Tag-Achse. d-check-Exit: 0 = kein Drift, !=0 = Alarm.
regelwerk-check: ## Upstream-Content-Drift des Baseline-ZIP (d-check sources, Netz) — Maintenance/CI, NICHT in gates
	docker run --rm -v "$(CURDIR):/repo:ro" $(DCHECK_REF) --enable sources --disable links --disable anchors --disable ids --disable matrix --disable codepaths --disable spans
	@echo "Hinweis: prueft NUR das Asset von $(BASELINE_TAG). Ein NEUER Tag upstream bleibt hier unsichtbar — 'make baseline-freshness' prueft die Release-Liste (slice-018, MR-007)."

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
gates: baseline-verify docs-check lint build test shell-lint ci-lint record-gates ## alle aktuell lauffähigen Gates + Nachweis
