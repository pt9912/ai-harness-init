# harness.mk — generischer Doku-Referenz-Gate via d-check (Digest-Pin v0.10.0).
# Einbinden mit `include harness.mk`. Kandidat fürs Template-Set (templates-v4).
D_CHECK_IMAGE ?= ghcr.io/pt9912/d-check@sha256:ca49d33f22ecadfd08db03e4487b52b3f2a70dec01a41f2d0f472bfc2012797c

.PHONY: docs-check
docs-check: ## Doku-Referenzen prüfen (links/anchors; ids/codepaths laut .d-check.yml)
	docker run --rm -v "$(CURDIR)":/repo:ro $(D_CHECK_IMAGE)
