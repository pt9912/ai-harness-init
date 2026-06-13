# ai-harness-init — Gates. Doc-Gate generisch (harness.mk); Code-Gates
# (lint/test) kommen mit dem Code, nicht vorher (keine halluzinierten Gates).
include harness.mk

.PHONY: help gates record-gates
help: ## Targets anzeigen
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  %-14s %s\n", $$1, $$2}'

record-gates: ## Gate-Nachweis schreiben (Working-Tree-Hash für den Stop-Hook)
	@bash tools/harness/record-gates.sh

# record-gates läuft als LETZTER Prerequisite — der Nachweis entsteht nur
# nach grünen Gates (harness/conventions.md MR-002).
gates: docs-check record-gates ## alle aktuell lauffähigen Gates + Nachweis
