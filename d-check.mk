# harness.mk — generischer Doku-Referenz-Gate via d-check (Digest-Pin v0.46.0).
# Einbinden mit `include harness.mk`. Kandidat fürs Template-Set (v3.1.0).
D_CHECK_IMAGE ?= ghcr.io/pt9912/d-check@sha256:9c317bf116a614a00f417871da4ca6057bdbabf0ca53af24c6d8e8b776de36a1

.PHONY: docs-check
docs-check: ## Doku-Referenzen prüfen (links/anchors; ids/codepaths laut .d-check.yml)
	docker run --rm -v "$(CURDIR)":/repo:ro $(D_CHECK_IMAGE)
