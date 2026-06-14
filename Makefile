# ai-harness-init — Gates. Doc-Gate generisch (harness.mk); test (bats
# Command-Guard) und shell-lint (shellcheck) sind da; Go-lint/build
# (golangci-lint/go build) kommen mit dem Go-Code (keine halluzinierten Gates).
include harness.mk

# Tool-Images digest-gepinnt (Reproduzierbarkeit, LH-QA-02; Docker-only, ADR-0003).
BATS_IMAGE ?= bats/bats@sha256:e8f18e0acd4ea933bf019130b85033be75e8ce081db299e93578de83d7874e33
SHELLCHECK_IMAGE ?= koalaman/shellcheck@sha256:bb596a0d169b85ddd81d8b6d3a2ff6d5baf5fca10b97f575ebc647c3dff62b3d

.PHONY: help gates record-gates test shell-lint
help: ## Targets anzeigen
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  %-14s %s\n", $$1, $$2}'

test: ## Command-Guard-Tests (bats) im gepinnten Image — Docker-only (ADR-0004)
	docker run --rm -v "$(CURDIR)":/code:ro -w /code $(BATS_IMAGE) test/

# shellcheck über die harness-eigenen Shell-Hooks/-Helfer. .bats ist
# ausgenommen (shellcheck parst die @test-Syntax nicht); .awk ist kein Shell.
shell-lint: ## Shell-Hooks/-Helfer linten (shellcheck) im gepinnten Image — Docker-only (ADR-0003)
	docker run --rm -v "$(CURDIR)":/mnt:ro -w /mnt $(SHELLCHECK_IMAGE) \
		.claude/hooks/*.sh tools/harness/*.sh

record-gates: ## Gate-Nachweis schreiben (Working-Tree-Hash für den Stop-Hook)
	@bash tools/harness/record-gates.sh

# record-gates läuft als LETZTER Prerequisite — der Nachweis entsteht nur
# nach grünen Gates (harness/conventions.md MR-002).
gates: docs-check test shell-lint record-gates ## alle aktuell lauffähigen Gates + Nachweis
