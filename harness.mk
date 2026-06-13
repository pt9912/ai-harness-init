# harness.mk — generischer Doku-Referenz-Gate via d-check (Digest-Pin v0.8.0).
# Einbinden mit `include harness.mk`. Kandidat fürs Template-Set (templates-v4).
D_CHECK_IMAGE ?= ghcr.io/pt9912/d-check@sha256:871751f9ed13cec8fadb610c538d735ad6c77a838a0384f645da916e829e4550

.PHONY: docs-check
docs-check: ## Doku-Referenzen prüfen (links/anchors; ids/codepaths laut .d-check.yml)
	docker run --rm -v "$(CURDIR)":/repo:ro $(D_CHECK_IMAGE)
