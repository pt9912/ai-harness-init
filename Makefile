# ai-harness-init — Gates. Doc-Gate generisch (harness.mk); test (bats
# Command-Guard) ist da; lint/build (Go-Toolchain) kommen mit dem Go-Code,
# nicht vorher (keine halluzinierten Gates).
include harness.mk

# bats-Image digest-gepinnt (Reproduzierbarkeit, LH-QA-02; Docker-only, ADR-0003).
BATS_IMAGE ?= bats/bats@sha256:e8f18e0acd4ea933bf019130b85033be75e8ce081db299e93578de83d7874e33

.PHONY: help gates record-gates test
help: ## Targets anzeigen
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  %-14s %s\n", $$1, $$2}'

test: ## Command-Guard-Tests (bats) im gepinnten Image — Docker-only (ADR-0004)
	docker run --rm -v "$(CURDIR)":/code:ro -w /code $(BATS_IMAGE) test/

record-gates: ## Gate-Nachweis schreiben (Working-Tree-Hash für den Stop-Hook)
	@bash tools/harness/record-gates.sh

# record-gates läuft als LETZTER Prerequisite — der Nachweis entsteht nur
# nach grünen Gates (harness/conventions.md MR-002).
gates: docs-check test record-gates ## alle aktuell lauffähigen Gates + Nachweis
