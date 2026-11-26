#!/usr/bin/env bash
# files: harness/tools/working-tree-hash.sh
# expect: stamp-ausnahme: Inhalt unter .harness/stamp ausserhalb der deklarierten Liste endet rot
#
# BEGRADIGT den fail-closed-Zweig der Hash-Ausnahme (ADR-0103 Festlegung 2,
# MR-017-Form): Inhalt unter .harness/stamp/ ausserhalb der deklarierten Liste wird
# danach still ausgenommen, statt den Lauf mit Meldung zu brechen — ein nicht
# deklarierter Baum wuerde stumm aus dem Nachweis verschwinden. Faerbt genau den
# Fall `stamp-ausnahme: Inhalt unter .harness/stamp ausserhalb der deklarierten
# Liste endet rot` in test/working-tree-hash-abnahme.bats rot; die Entleerung der
# Ausnahme-Liste (Fall 791) trifft diesen Zweig nicht.
set -euo pipefail
sed -i "s@if ! ausnahme \"\$f\"; then@if false \&\& ! ausnahme \"\$f\"; then@" harness/tools/working-tree-hash.sh
