#!/usr/bin/env bats
# history-range-guard.bats — Tests fuer den Vorlauf-Waechter
# (harness/tools/history-range-guard.sh, slice-123).
# Docker-only im gepinnten bats-Image (make test).
#
# HERMETISCH: getestet wird ausschliesslich die REINE Entscheidung ueber
# `--decide <range> <count>` mit Fixture-Zahlen. Der `git rev-list`-Aufruf des
# vollen Laufs ist davon getrennt und wird hier NIE aufgerufen — das gepinnte
# bats-Image fuehrt kein `git` (s. harness/tools/slice-mv.sh Kopf, Abschnitt
# ZUSAGE). Der echte flache Klon steht als BELEG im Kopf des Skripts, nicht
# hier (dieselbe Trennung wie component-freshness.bats/component-freshness.sh
# zwischen Fetch und Vergleich).
#
# Die Klon-Tiefen-Zeile ("Klon-Tiefe: ...") wird NICHT auf einen konkreten
# Wert geprueft — ihr Inhalt haengt vom Arbeitsverzeichnis ab (voller Checkout
# hier, potenziell ein Shallow-Klon in CI), nur ihre Anwesenheit ist die
# Zusage.

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  GUARD="$REPO/harness/tools/history-range-guard.sh"
}

@test "history-range-guard: leere Range (0 Commits) -> exit 1, LEER + Tiefe + Range + Advice" {
  run bash "$GUARD" --decide "HEAD..HEAD" 0
  [ "$status" -eq 1 ]
  printf '%s' "$output" | grep -q "Range 'HEAD..HEAD' ist aufloesbar, aber LEER"
  printf '%s' "$output" | grep -q "Klon-Tiefe:"
  printf '%s' "$output" | grep -q "Angeforderte Range: HEAD..HEAD"
  printf '%s' "$output" | grep -q "fetch-depth: 0"
}

@test "history-range-guard: nicht-leere Range (>0 Commits) -> exit 0, OK" {
  run bash "$GUARD" --decide "HEAD~3..HEAD" 3
  [ "$status" -eq 0 ]
  printf '%s' "$output" | grep -q "aufgeloest, 3 Commit(s) — OK"
  # Der OK-Zweig nennt NICHT die Leer-Diagnose (keine falsche Doppel-Meldung).
  ! printf '%s' "$output" | grep -q "LEER"
}

@test "history-range-guard: --staged reicht durch, exit 0, OHNE Range-Pruefung" {
  run bash "$GUARD" --staged
  [ "$status" -eq 0 ]
}

@test "history-range-guard: ohne Argument -> exit != 0, Usage-Meldung" {
  run bash "$GUARD"
  [ "$status" -ne 0 ]
  printf '%s' "$output" | grep -q "Usage:"
}
