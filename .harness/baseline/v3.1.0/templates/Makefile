# Gates. Doc-Gate via d-check (Image per Digest gepinnt); Code-Gates
# (lint/test/build) sind repo-spezifisch — Vorbild: lab/example/<lang> im
# Kurs. Nur existierende, laufende Targets in AGENTS.md / harness/README.md
# eintragen (keine halluzinierten Gates, Modul 13). Code-Gates wachsen mit
# dem Code. Fragment frisch erzeugen: `d-check --print-mk`.
D_CHECK_IMAGE ?= ghcr.io/pt9912/d-check@sha256:718acb28b1992863b0a23b2e172144dccf3ada1c4552fcacc37478bc3e0fddd9

.PHONY: help gates docs-check
help: ## Targets anzeigen
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  %-14s %s\n", $$1, $$2}'

docs-check: ## Doku-Referenzen prüfen (links/anchors; ids/codepaths laut .d-check.yml)
	docker run --rm -v "$(CURDIR)":/repo:ro $(D_CHECK_IMAGE)

gates: docs-check ## alle aktuell lauffähigen Gates (Code-Gates ergänzen)
