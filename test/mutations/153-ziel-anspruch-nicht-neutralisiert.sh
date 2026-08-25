#!/usr/bin/env bash
# files: internal/emit/templates.go
# expect: TestEmittierteDokumente_NurInitInvarianteZiele
#
# Die Stern-Ausnahme von NeutralizeMakeClaims kippt: statt der MUSTER-Nennung
# (`make verify-*`) bleibt jede Nennung OHNE Stern unveraendert — also genau der
# Anspruch. Der Emit schreibt die Gate-Tische und die Prosa-Nennung des
# Closure-Note-Reviewer-Skills dann wieder mit Zielen, die im gebootstrappten Repo
# in keiner Variante existieren (LH-QA-01, ADR-0020 Festlegung 4(e)).
#
# Die Bedingung bleibt syntaktisch gueltig, der Code uebersetzt: der Fehlschlag
# kommt aus dem Waechter, nicht aus dem Compiler.
set -euo pipefail
sed -i 's/if g\[2\] != "" || known\[g\[1\]\] {/if g[2] == "" || known[g[1]] {/' internal/emit/templates.go
