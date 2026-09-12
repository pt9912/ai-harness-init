#!/usr/bin/env bash
# files: d-check.mk
# expect: doc-*: C-Menge (kein .d-check.yml-Block) == Ziele mit Hilfetext-Marke == Ziele mit Ausgabe-Marke
#
# Setzt ein DRITTES `docs?-*`-Ziel ein, das ein Modul per `--enable` zuschaltet, fuer das
# `.d-check.yml` keinen Top-Level-Block fuehrt (`citations`, wie `doc-tracked`/`doc-structure`
# heute) — aber ohne die Marke im Hilfetext oder in der Ausgabe. Das ist die
# Auspraegung-statt-Eigenschaft-Falle in Reinform (AGENTS.md 3.6): ein Waechter, der die
# C-Menge als feste Namensliste statt als abgeleitete Eigenschaft haelt, bliebe hier gruen.
set -euo pipefail
cat >> d-check.mk <<'EOF'

.PHONY: doc-citations-probe
doc-citations-probe: ## Sonden-Ziel ohne Marke, nur fuer diesen Mutations-Fall
	docker run --rm --network none -v "$(CURDIR):/repo:ro" $(DCHECK_REF) --enable citations --disable links --disable anchors --disable ids --disable matrix --disable external --disable codepaths --disable spans --disable hostpaths --disable diagrams --disable versions --disable pins --disable immutable --disable vcs --disable commits --disable planning --disable tracked --disable targets --disable structure --disable sources --disable workflows --disable reviews
EOF
