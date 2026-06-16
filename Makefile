# ai-harness-init — Gates. Doc-Gate generisch (harness.mk); test (bats
# Command-Guard) und shell-lint (shellcheck) sind da; Go-lint/build
# (golangci-lint/go build) kommen mit dem Go-Code (keine halluzinierten Gates).
include harness.mk

# Tool-Images digest-gepinnt (Reproduzierbarkeit, LH-QA-02; Docker-only, ADR-0003).
BATS_IMAGE ?= bats/bats@sha256:e8f18e0acd4ea933bf019130b85033be75e8ce081db299e93578de83d7874e33
SHELLCHECK_IMAGE ?= koalaman/shellcheck@sha256:bb596a0d169b85ddd81d8b6d3a2ff6d5baf5fca10b97f575ebc647c3dff62b3d

# Regelwerk-Quelle: Split-Modul-ZIP vom Release-Tag, ZIP-sha256-gepinnt
# (Reproduzierbarkeit, LH-QA-02; MR-006). regelwerk-fetch ist Maintenance (Netz,
# curl+unzip) und NICHT in gates (LH-QA-01 / offline-grün). Cache = Verzeichnis.
REGELWERK_URL ?= https://github.com/pt9912/ai-harness-course/releases/download/v1.2.0/lab-regelwerk.zip
REGELWERK_SHA256 ?= ef61f8a7386dcc3b967b7653962d558521b284eb33e481e26b98a32f2db97e43
REGELWERK_CACHE ?= .harness/cache/agents-regelwerk

.PHONY: help gates record-gates test shell-lint regelwerk-fetch
help: ## Targets anzeigen
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  %-14s %s\n", $$1, $$2}'

test: ## Command-Guard-Tests (bats) im gepinnten Image — Docker-only (ADR-0004)
	docker run --rm -v "$(CURDIR)":/code:ro -w /code $(BATS_IMAGE) test/

# shellcheck über die harness-eigenen Shell-Hooks/-Helfer. .bats ist
# ausgenommen (shellcheck parst die @test-Syntax nicht); .awk ist kein Shell.
shell-lint: ## Shell-Hooks/-Helfer linten (shellcheck) im gepinnten Image — Docker-only (ADR-0003)
	docker run --rm -v "$(CURDIR)":/mnt:ro -w /mnt $(SHELLCHECK_IMAGE) \
		.claude/hooks/*.sh harness/tools/*.sh

# Holt das WORTGLEICHE Regelwerk (Split-Modul-ZIP) in den lokalen, gitignorierten
# Cache (Verzeichnis), dessen Index der SessionStart-Hook injiziert (MR-006,
# ergänzt MR-004). ZIP-sha256-Pin VOR jeder Cache-Mutation = Drift-Erkennung;
# Replace via temp -> mv (mv atomar, Gesamt-Replace nicht), Cache bei
# Fehler/Drift UNVERAENDERT.
regelwerk-fetch: ## Regelwerk-ZIP verbatim holen + sha256 prüfen + entpacken — Maintenance, NICHT in gates
	@mkdir -p "$(dir $(REGELWERK_CACHE))"
	@tmp="$$(mktemp)"; tmpd="$$(mktemp -d "$(dir $(REGELWERK_CACHE)).fetch.XXXXXX")"; \
	curl -fsSL "$(REGELWERK_URL)" -o "$$tmp" \
		&& printf '%s  %s\n' "$(REGELWERK_SHA256)" "$$tmp" | sha256sum -c - >/dev/null \
		&& unzip -oq "$$tmp" -d "$$tmpd" \
		&& rm -rf "$(REGELWERK_CACHE)" \
		&& mv "$$tmpd" "$(REGELWERK_CACHE)" \
		&& rm -f "$$tmp" \
		&& echo "Regelwerk-Cache aktuell: $(REGELWERK_CACHE)/ ($$(find "$(REGELWERK_CACHE)" -maxdepth 1 -type f | wc -l) Dateien)" \
		|| { rm -rf "$$tmp" "$$tmpd"; echo "FEHLER/DRIFT: Fetch fehlgeschlagen oder Upstream != gepinnter sha256 — Cache UNVERAENDERT; REGELWERK_SHA256 ggf. neu pinnen"; exit 1; }

record-gates: ## Gate-Nachweis schreiben (Working-Tree-Hash für den Stop-Hook)
	@bash harness/tools/record-gates.sh

# record-gates läuft als LETZTER Prerequisite — der Nachweis entsteht nur
# nach grünen Gates (harness/conventions.md MR-002).
gates: docs-check test shell-lint record-gates ## alle aktuell lauffähigen Gates + Nachweis
