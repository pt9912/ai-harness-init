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
GO_VERSION ?= 1.27.0
GOLANGCI_LINT_VERSION ?= v2.13.1

# Vendored Baseline (MR-007): Regelwerk UND Templates liegen committet unter
# .harness/baseline/$(BASELINE_TAG)/{regelwerk,templates}/ + SHA256SUMS —
# netzlos auf jedem Checkout präsent, kein Fetch pro Lauf.
#
# BASELINE_TAG ist die EINZIGE Quelle des Tag-Strings in der Mechanik: der
# Injektor und baseline-verify ENTDECKEN das Verzeichnis (Setzung: ein Tag zur
# Zeit), .d-check.yml nutzt einen Glob. Ein Tag-Bump ändert damit diese Zeile,
# BASELINE_ZIP_SHA256 und den Baum — keinen repo-weiten Grep (LH-QA-02).
BASELINE_TAG ?= v3.5.2
# Kein BASELINE_DIR: baseline-verify und der Injektor ENTDECKEN das <tag>-
# Verzeichnis per Glob (Setzung "ein Tag zur Zeit"), lesen es also nicht aus
# einer Variablen — ein solcher Pfad-Override wäre stiller No-op.
# Upstream-PROVENIENZ (nicht lokale Integrität — die trägt SHA256SUMS im Baum):
# sha256 des Release-Assets, aus dem der Baum stammt. SHA256SUMS ist selbst
# erzeugt und beweist die Herkunft NICHT; diese Kette hängt allein hier.
# regelwerk-check vergleicht Upstream gegen diesen Pin (MR-007).
BASELINE_URL ?= https://github.com/pt9912/ai-harness-course/releases/download/$(BASELINE_TAG)/lab-regelwerk.zip
BASELINE_ZIP_SHA256 ?= 2af45aad2777cadf26127066c9a2dc43f7111ee2687e44fe2eceb95c6c0a1925

.PHONY: help gates record-gates test test-bats test-go lint build compile artifact release-artifacts smoke full-smoke shell-lint ci-lint comment-claims host-bin span-check span-clean span-report baseline-verify regelwerk-check baseline-freshness freshness-golangci freshness-dcheck freshness-go freshness-cpp mutate

# d-check-Tag aus DCHECK_IMAGE (d-check.mk) fuer die Freshness-Achse: der Tag
# steht rechts vom LETZTEN ':' (ghcr.io/pt9912/d-check:v0.62.0 -> v0.62.0). Aus
# DCHECK_IMAGE, NICHT DCHECK_REF — letzteres traegt bei gesetztem Digest keinen Tag.
DCHECK_TAG := $(lastword $(subst :, ,$(DCHECK_IMAGE)))
# -h unterdrueckt den Dateinamen-Praefix: MAKEFILE_LIST traegt mehrere Dateien,
# und ohne -h trennt awk am Doppelpunkt des Praefixes statt am Zielnamen.
help: ## Targets anzeigen
	@grep -hE '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | LC_ALL=C sort -t: -k1,1 | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  %-18s %s\n", $$1, $$2}'

test: test-bats test-go ## Harness-Tests (bats) + Go-Unit-Tests (go test in Docker) — Docker-only (ADR-0003/0004)

# Die zwei Stufen sind einzeln aufrufbar, damit `make mutate` je Fall nur die
# Stufe faehrt, deren Rot er erwartet. `test` bleibt die Summe beider, in
# derselben Reihenfolge.
test-bats: ## Nur die Harness-Tests (bats) — Docker-only
	docker run --rm --network none -v "$(CURDIR)":/code:ro -w /code $(BATS_IMAGE) test/

test-go: ## Nur die Go-Unit-Tests (Dockerfile test-Stage) — Docker-only
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
	@bash harness/tools/artifact-copy.sh ai-harness-init:build "$(DEST)" ai-harness-init

# Plattform-Matrix (LH-QA-04): ein natives Binary je GOOS/GOARCH, cross-kompiliert
# im GEPINNTEN Image (kein Host-Toolchain, ADR-0003). Die Liste ist eine Variable,
# damit ein Teil-Lauf (z. B. nur linux) ohne Recipe-Aenderung moeglich ist; der
# Default ist die vollstaendige Matrix aus dem Lastenheft.
#
# Namensschema: ai-harness-init-<os>-<arch>, windows zusaetzlich mit .exe — der
# Dateiname traegt die Plattform, weil alle sechs im selben DEST landen.
#
# --no-cache-filter build: die build-Stage wird JEDES MAL neu uebersetzt. Sonst
# liefert ein zweiter Lauf denselben Layer zurueck, und ein Vergleich zweier
# Laeufe belegte den Cache statt der Reproduzierbarkeit (LH-QA-02). Dieselbe
# Begruendung wie beim `--no-cache-filter test` des test-Targets: ein
# Cache-Treffer darf ein Ergebnis nicht ersetzen.
RELEASE_PLATFORMS ?= linux/amd64 linux/arm64 darwin/amd64 darwin/arm64 windows/amd64 windows/arm64

release-artifacts: ## Alle Release-Binaries der Plattform-Matrix nach DEST=<dir> (LH-QA-04) — Docker-only
	@test -n "$(DEST)" || { echo "release-artifacts: DEST=<dir> ist Pflicht (Zielverzeichnis)"; exit 2; }
	@set -e; for p in $(RELEASE_PLATFORMS); do \
		os="$${p%%/*}"; arch="$${p##*/}"; ext=""; \
		[ "$$os" = "windows" ] && ext=".exe"; \
		tag="ai-harness-init:build-$$os-$$arch"; \
		echo "release-artifacts: $$os/$$arch ..."; \
		docker build --no-cache-filter build --build-arg GO_VERSION=$(GO_VERSION) \
			--build-arg TARGET_OS="$$os" --build-arg TARGET_ARCH="$$arch" \
			--target build -t "$$tag" . ; \
		bash harness/tools/artifact-copy.sh "$$tag" "$(DEST)" "ai-harness-init-$$os-$$arch$$ext"; \
	done
	@echo "release-artifacts: OK — $(words $(RELEASE_PLATFORMS)) Binaries in $(DEST)"

compile: ## Schnelles Compile-Feedback (Dockerfile compile-Stage, ohne Tests/Lint) — Docker-only; NICHT in gates
	docker build --build-arg GO_VERSION=$(GO_VERSION) --target compile -t ai-harness-init:compile .

# Emittiert die Doc-Gate-Baseline in ein tmp-Repo und laesst dort das emittierte
# docs-check real laufen. Braucht Host-Docker und ggf. einen Netz-Pull, deshalb
# NICHT in gates (die bleiben offline-schlank, LH-QA-01). Die Logik liegt in
# harness/tools/, damit shell-lint sie deckt — der Rezeptkoerper hier liegt
# ausserhalb von dessen Pruefbereich.
smoke: ## Emit-Smoke: Doc-Gate in tmp-Repo emittieren + emittiertes docs-check real gruen (Host-Docker) — NICHT in gates
	@GO_VERSION='$(GO_VERSION)' bash harness/tools/smoke.sh

# Bootstrappt ein tmp-Repo und faehrt dort den zusammengefuehrten `make gates`
# (docs-check + Go-Gates in einem Lauf, MR-010) — der Happy-Path aus Nutzersicht
# (LH-FA-01). Host-Docker und ggf. Netz-Pull, deshalb NICHT in gates (LH-QA-01).
full-smoke: ## Voll-E2E: Bootstrap in tmp-Repo -> dort make gates out-of-the-box gruen (Host-Docker) — NICHT in gates
	@GO_VERSION='$(GO_VERSION)' bash harness/tools/full-smoke.sh

mutate: ## Mutations-Sensor fuer AGENTS 3.6: faerbt jede Mutation ihren Waechter rot? — NICHT in gates
	@bash harness/tools/mutate.sh

# shellcheck über die harness-eigenen Shell-Hooks/-Helfer. .bats ist
# ausgenommen (shellcheck parst die @test-Syntax nicht); .awk ist kein Shell.
shell-lint: ## Shell-Hooks/-Helfer linten (shellcheck) im gepinnten Image — Docker-only (ADR-0003)
	docker run --rm -v "$(CURDIR)":/mnt:ro -w /mnt $(SHELLCHECK_IMAGE) \
		.claude/hooks/*.sh harness/tools/*.sh internal/emit/templates/*.sh internal/emit/templates/enforce/*.sh test/mutations/*.sh

# Haelt Kommentar-Behauptungen gegen ihre Sensoren (AGENTS.md 3.6). Hermetisch —
# reines bash+awk auf dem Arbeitsbaum, kein Docker, kein Netz —, deshalb IN gates.
# Geprueft werden echte Kommentare; Roh-String-Literale (emittierter Inhalt) nicht.
comment-claims: ## Kommentar-Behauptungen nennen ihren Sensor (AGENTS.md 3.6) — hermetisch
	@bash harness/tools/comment-claims.sh $$(git ls-files 'internal/*.go' 'internal/**/*.go' 'cmd/**/*.go' | grep -v '_test[.]go') $$(git ls-files 'harness/tools/*.sh' '.claude/hooks/*.sh')

# Prueft die GitHub-Actions-Workflows syntaktisch. IN gates: .github/workflows/
# ist ein reales committetes Artefakt (kein leerer Pruefbereich, LH-QA-01), und
# ein Syntaxfehler ist so lokal vor dem Push fangbar statt erst im Actions-Lauf.
# Ohne -color: die Ausgabe wird geloggt und gegrept, ANSI-Escapes zerstueckeln
# das `file:line:col:`-Praefix.
ci-lint: ## GitHub-Actions-Workflows linten (actionlint) im gepinnten Image — Docker-only, IN gates
	docker run --rm -v "$(CURDIR)":/repo:ro -w /repo $(ACTIONLINT_IMAGE)

# Verifiziert die vendored Baseline netzlos, in zwei Schritten: `sha256sum -c`
# über SHA256SUMS fängt geänderte und gelöschte Dateien, ein Vollständigkeits-
# Check zusätzlich eingelegte — für die ist `sha256sum -c` blind, es prüft nur
# Gelistetes. Kein curl, kein Netz, deshalb IN gates (MR-007). Die Logik liegt in
# harness/tools/, damit shell-lint sie deckt — dieses Ziel laeuft in gates, sein
# Skript darf also nicht ungeprueft sein.
baseline-verify: ## Vendored Baseline netzlos verifizieren (Integrität + Vollständigkeit) — IN gates
	@bash harness/tools/baseline-verify.sh

# Meldet Content-Drift des gepinnten Baseline-ZIP: d-check holt das per sha256
# gepinnte Asset, hasht die Roh-Bytes und meldet Abweichung (source-drift, mit
# Ist-Hash zum Re-Pinnen) oder Netzfehler (source-unreachable). Der Pin lebt
# kanonisch als BASELINE_ZIP_SHA256 und dupliziert in .d-check.yml; beide koppelt
# test/sources-pin.bats fail-closed. Braucht Netz, deshalb NICHT in gates
# (LH-QA-01). Prueft NUR das Asset des gepinnten Tags — die Tag-Achse prueft
# baseline-freshness. Exit: 0 = kein Drift, !=0 = Alarm. Die sechs --disable-Flags
# isolieren den Lauf auf `sources`: sie nennen genau die sechs Module, die
# .d-check.yml fuer docs-check aktiviert — dort laufen sie netzlos und in gates.
regelwerk-check: ## Upstream-Content-Drift des Baseline-ZIP (d-check sources, Netz) — Maintenance/CI, NICHT in gates
	docker run --rm -v "$(CURDIR):/repo:ro" $(DCHECK_REF) --enable sources --disable links --disable anchors --disable ids --disable matrix --disable codepaths --disable spans
	@echo "Hinweis: prueft NUR das Asset von $(BASELINE_TAG). Ein NEUER Tag upstream bleibt hier unsichtbar — 'make baseline-freshness' prueft die Release-Liste (slice-018, MR-007)."

# Meldet einen neueren Upstream-Tag als BASELINE_TAG: folgt dem
# releases/latest-Redirect und vergleicht die Release-LISTE — die Achse, die
# regelwerk-check (Asset-Hash) nicht sieht. Read-only, mutiert nichts. Braucht
# Netz, deshalb NICHT in gates (LH-QA-01). Skript-Exit: 0 = aktuell, 1 =
# veraltet, 2 = Fetch-Fehler; `make` kollabiert jeden Nonzero auf sein Exit 2 —
# welcher Fall vorliegt, sagt die Meldung. Die Logik liegt in harness/tools/
# (shell-lint deckt sie), Fetch und Vergleich sind getrennt — der Vergleicher ist
# damit ohne Netz testbar.
baseline-freshness: ## Neueren Upstream-Tag als BASELINE_TAG melden (read-only) — Maintenance/CI, NICHT in gates
	@BASELINE_TAG='$(BASELINE_TAG)' RELEASES_LATEST_URL='https://github.com/pt9912/ai-harness-course/releases/latest' bash harness/tools/baseline-freshness.sh

# Die freshness-*-Ziele nutzen denselben generischen Sensor, je Achse mit einer
# kanonischen Pin-Quelle gegen Upstream-releases/latest. Read-only, Netz, NICHT
# in gates (LH-QA-01).
#
# Pin-Quelle hier: GOLANGCI_LINT_VERSION — derselbe Var, den `make lint` als
# Build-Arg reicht. Verglichen wird nur gegen Upstream, nie Pin gegen Pin, sonst
# entstuende Falsch-Drift. Weitere golangci-lint-Pins (Dockerfile-ARG, Skelett)
# nennt die Advice-Zeile; TestGoProfile_PinsMatchRepo koppelt Skelett und ARG.
freshness-golangci: ## Neueren golangci-lint-Release als GOLANGCI_LINT_VERSION melden (read-only) — Maintenance/CI, NICHT in gates
	@COMPONENT_NAME='golangci-lint' COMPONENT_PINNED='$(GOLANGCI_LINT_VERSION)' \
	  COMPONENT_ADVICE='GOLANGCI_LINT_VERSION (Makefile) bumpen; Dockerfile-lint-Digest + gen-Skelett-Pin ziehen mit (TestGoProfile_PinsMatchRepo).' \
	  RELEASES_LATEST_URL='https://github.com/golangci/golangci-lint/releases/latest' \
	  bash harness/tools/component-freshness.sh

# Pin-Quelle: der Tag in DCHECK_IMAGE, via DCHECK_TAG extrahiert. Ein neuer
# Release verlangt `d-check --print-mk` neu zu erzeugen und DCHECK_DIGEST neu zu
# pinnen (MR-010/MR-012) — das nennt die Advice-Zeile.
freshness-dcheck: ## Neueren d-check-Release als DCHECK_IMAGE-Tag melden (read-only) — Maintenance/CI, NICHT in gates
	@COMPONENT_NAME='d-check' COMPONENT_PINNED='$(DCHECK_TAG)' \
	  COMPONENT_ADVICE='d-check --print-mk neu erzeugen + DCHECK_IMAGE/DCHECK_DIGEST in d-check.mk neu pinnen (MR-010/MR-012).' \
	  RELEASES_LATEST_URL='https://github.com/pt9912/d-check/releases/latest' \
	  bash harness/tools/component-freshness.sh

# Go-Achse mit Sonderquelle go.dev — golang/go hat kein GitHub-releases/latest,
# deshalb ein eigener Wrapper (Fetch + Normalisierung go1.x.y -> 1.x.y), der den
# Vergleicher wiederverwendet. Pin-Quelle: GO_VERSION, derselbe Build-Arg wie in
# make build/test; das Skelett-Pin koppelt TestGoProfile_PinsMatchRepo.
freshness-go: ## Neuere stabile Go-Version als GO_VERSION melden (read-only, Quelle go.dev) — Maintenance/CI, NICHT in gates
	@GO_VERSION='$(GO_VERSION)' bash harness/tools/go-freshness.sh

# C++/ubuntu-Achse mit Sonderquelle Docker Hub; „latest" ist hier das hoechste
# LTS (gerades NN.04). Pin-Quelle: DefaultCppVersion in internal/gen/cpp.go — der
# emittierte Skelett-Tag. Dies Repo baut kein C++, es gibt also keinen
# Makefile-Var dafuer; der Wert wird per sed gelesen.
freshness-cpp: ## Neueres ubuntu-LTS als DefaultCppVersion melden (read-only, Quelle Docker Hub) — Maintenance/CI, NICHT in gates
	@pinned=$$(sed -n 's/.*DefaultCppVersion = "\([0-9.]*\)".*/\1/p' internal/gen/cpp.go); \
	  CPP_PINNED="$$pinned" bash harness/tools/cpp-freshness.sh

# Der Traeger ist ein HOST-Binary: der Hook ruft ihn je Tool-Call, ein Container-Start
# je Aufruf waere um zwei Groessenordnungen teurer als der Schreiber selbst. Gebaut
# wird er trotzdem Docker-only im gepinnten Image (ADR-0003) und danach herausgeholt,
# wie bei `make artifact`. Er liegt im gitignorierten Zustands-Bereich, damit er den
# working-tree-hash nicht verschiebt (MR-003).
#
# Es ist das PRODUKT-Binary, nicht ein zweites daneben (ADR-0022 Festlegung 2):
# Schreiber und Auswertung sind seine Unterkommandos, und der Hook dieses Repos ruft
# damit denselben Einstiegspunkt, den ein Zielrepo bekommt.
HOST_BIN := .harness/state/bin/ai-harness-init

# Plattform des Aufrufers, abgeleitet fuer den Bau des Traegers: er laeuft auf dem
# HOST, gebaut wird er im gepinnten Linux-Image. Ohne diese Ableitung entstuende
# immer ein Linux-ELF, und `make gates` waere auf einem macOS-Host rot ohne
# inhaltlichen Defekt. Dieselben Schalter wie die Plattform-Matrix (LH-QA-04), nur
# auf genau eine Plattform gerichtet.
HOST_OS   := $(shell uname -s | tr 'A-Z' 'a-z')
HOST_ARCH := $(shell uname -m | sed -e 's/^x86_64$$/amd64/' -e 's/^aarch64$$/arm64/')

host-bin: ## Traeger (Produkt-Binary) fuer die HOST-Plattform in den Zustands-Bereich legen — Docker-only (ADR-0003)
	docker build --build-arg GO_VERSION=$(GO_VERSION) \
		--build-arg TARGET_OS=$(HOST_OS) --build-arg TARGET_ARCH=$(HOST_ARCH) \
		--target build -t ai-harness-init:host .
	@bash harness/tools/artifact-copy.sh ai-harness-init:host "$(dir $(HOST_BIN))" "$(notdir $(HOST_BIN))"

# OHNE Prerequisite auf host-bin, und das ist tragend: mit ihm koennte das Ziel den
# Fehlt-Fall, den es prueft, nie melden — der Bau liefe unmittelbar davor. Einzeln
# gefahren misst es wirklich, ob der Traeger da ist. In `gates` steht der Bau als
# eigenes Glied davor, dort gilt also beides: vorhanden UND funktionsfaehig.
span-check: ## `span-emit` vorhanden UND funktionsfaehig (der Fehlt-Fall) — IN gates
	@bash harness/tools/span-check.sh "$(HOST_BIN)"

# Aufgeraeumt wird ausdruecklich, nie nebenbei (ADR-0011 Festlegung 3): ob eine
# andere Sitzung noch laeuft, ist nicht entscheidbar — also raeumt niemand fremden
# Bestand automatisch weg.
span-clean: ## Span-Bestaende entfernen (ausdruecklich, kein Automatismus)
	@rm -rf .harness/state/spans && echo "span-clean: .harness/state/spans entfernt"

# Rechnet die Token-Bilanz je Rolle aus dem Span-Bestand. Bericht, kein Gate.
#
# Laeuft auf dem HOST als Unterkommando des Traegers (ADR-0022 Festlegung 2), nicht
# mehr im Container ueber einem gemounteten Bestand: es gibt keine Bau-Stufe mehr, aus
# der er laufen koennte, und fuer einen Bericht soll niemand einen Container starten
# muessen. Netzlos ist er dadurch nicht weniger — er liest nur den Bestand. Das
# vorangestellte `mkdir -p` ist mit dem Container-Mount entfallen; ohne Bestand nennt
# der Bericht seinen leeren Nenner.
span-report: host-bin ## Token-Bilanz je Rolle aus dem Span-Bestand — NICHT in gates (Bericht, kein Sensor)
	@$(HOST_BIN) span-report

record-gates: ## Gate-Nachweis schreiben (Working-Tree-Hash für den Stop-Hook)
	@bash harness/tools/record-gates.sh

# Die Reihenfolge ist tragend: baseline-verify als ERSTER Prerequisite — steht die
# vendored Baseline nicht, ist jede Aussage der Folge-Gates über sie wertlos.
# record-gates als LETZTER — der Nachweis entsteht nur nach grünen Gates (MR-002).
gates: baseline-verify docs-check lint build test shell-lint ci-lint comment-claims host-bin span-check record-gates ## alle aktuell lauffähigen Gates + Nachweis
