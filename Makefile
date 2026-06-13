# ai-harness-init — Gates. Doc-Gate generisch (harness.mk); Code-Gates
# (lint/test) kommen mit dem Code, nicht vorher (keine halluzinierten Gates).
include harness.mk

.PHONY: help gates
help: ## Targets anzeigen
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  %-14s %s\n", $$1, $$2}'

gates: docs-check ## alle aktuell lauffähigen Gates
