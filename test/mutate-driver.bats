#!/usr/bin/env bats
# mutate-driver.bats — Waechter fuer den Mutations-Treiber selbst.
#
# Warum: `make mutate` bewacht jeden gelisteten Waechter, aber bis slice-026
# NICHT sich selbst — harness/tools/mutate.sh stand in keinem `# files:`-Kopf
# (Review-Befund N-2). Ein Treiber ohne Waechter kann still seine Zaehne
# verlieren, und dann meldet der zweite Quadrant zu AGENTS 3.6 nur noch gruen.
#
# Selbst-Mutation waere der falsche Weg (das Skript liefe waehrend seiner eigenen
# Aenderung). Stattdessen: seine Einheiten hermetisch pruefen — und diese Datei
# ist dann per test/mutations/09 mutierbar wie jeder andere Waechter.

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  DRIVER="$REPO/harness/tools/mutate.sh"
}

# failure_form ist die EINZIGE Quelle der erlaubten `# verify:`-Modi. Ein leeres
# Muster waere fatal: `grep -E ''` matcht jede Zeile, Bedingung 4 faellt damit in
# den F-1-Zustand zurueck (rot aus falschem Grund wird als Beleg akzeptiert).
@test "driver: failure_form liefert fuer jeden erlaubten Modus ein NICHT-leeres Muster" {
  local m
  for m in test smoke; do
    run bash -c "source '$DRIVER' 2>/dev/null || true; failure_form $m"
    [ -n "$output" ]
  done
}

@test "driver: failure_form lehnt einen unbekannten Modus AB (statt leer zu liefern)" {
  run bash -c "source '$DRIVER' 2>/dev/null || true; failure_form voellig-unbekannt"
  [ "$status" -ne 0 ]
  [ -z "$output" ]
}

# Die Muster duerfen ausschliesslich bei FEHLSCHLAG greifen — sonst ist
# Bedingung 4 wirkungslos. Genau das war F-1: bats druckt Testnamen auch beim
# Bestehen, und das damalige Muster war der blosse Name.
@test "driver: das test-Muster trifft Fehlschlag-Zeilen, NICHT Erfolgs-Zeilen" {
  local form
  form="$(bash -c "source '$DRIVER' 2>/dev/null || true; failure_form test")"
  printf 'ok 21 emittiert: eingelegter SYMLINK\n'      | grep -Eq -- "$form" && return 1
  printf 'not ok 21 emittiert: eingelegter SYMLINK\n'  | grep -Eq -- "$form"
  printf -- '--- FAIL: TestIrgendwas (0.00s)\n'        | grep -Eq -- "$form"
}

@test "driver: das smoke-Muster trifft Fehlschlag-Zeilen, NICHT Fortschritts-Zeilen" {
  local form
  form="$(bash -c "source '$DRIVER' 2>/dev/null || true; failure_form smoke")"
  printf 'smoke: 3/4 Skelett gestaged? ...\n'          | grep -Eq -- "$form" && return 1
  printf 'smoke: OK — Bootstrap laeuft\n'              | grep -Eq -- "$form" && return 1
  printf 'smoke: FEHLER — out-of-scope-Artefakt\n'     | grep -Eq -- "$form"
}
