#!/usr/bin/env bats
# smoke-ohne-docker.bats — Zaehne an den environment-check-Paarungs-Proben des
# docker-losen Smokes (harness/tools/smoke.sh, slice-smoke-und-full-smoke-ohne-docker).
#
# HERMETISCH: kein Docker, kein Netz, kein Bootstrap. Die Funktion
# umgebung_paarung_pruefen wird aus der REALEN Quelle extrahiert (sed ueber den
# Funktionskoerper — kein Fixture-Doppel des Codes); die Fixtures bauen die
# EMITTIERTEN Dateien (Singleton-Aussage, Target-Skript, GATE_CHECKS-Verdrahtung)
# je Form.
#
# ROT-GEGENPROBEN (AGENTS.md ##3.6), je Fall der benannte Grund:
#   - Faellt die GATE_CHECKS-Verdrahtung in environment.mk aus, faerbt der Fall
#     "verdrahtung" rot — die make-Anspruch-Aussage staende am Ziel ohne die
#     Verdrahtung dahinter (dieselbe Form, die der Mutations-Fall 817 an der
#     Emissionsquelle ansetzt).
#   - Faellt das Target-Skript, faerbt der Fall "target-skript" rot.
#   - Faellt der make-Anspruch im Singleton, faerbt der Fall "anspruch" rot —
#     ein Target ohne den Anspruch in der Sensor-Doku haette ein stiller Check
#     an der Doku-Vorlage verloren.
#   - Faellt das Singleton selbst, faerbt der Fall "singleton" rot.
#
# Und die Gegenrichtung der Extraktion: fuehrt smoke.sh die Funktion nicht mehr,
# ist die Extraktion leer und der Happy-Fall faerbt rot — kein stiller Test.

setup() {
  bats_require_minimum_version 1.5.0
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  SMOKE="$REPO/harness/tools/smoke.sh"
  TMP="$BATS_TEST_TMPDIR"
  sed -n '/^umgebung_paarung_pruefen() {/,/^}/p' "$SMOKE" >"$TMP/funktion.sh"
  grep -q 'umgebung_paarung_pruefen() {' "$TMP/funktion.sh" \
    || { echo "smoke.sh fuehrt umgebung_paarung_pruefen nicht mehr — Extraktion leer" >&2; return 1; }
}

# _paarung_target <anspruch> <target-skript> <verdrahtung> <singleton> — die
# emittierte Paarung je Form: 1 legt die datei mit der Aussage, 0 laesst sie weg.
_paarung_target() {
  local ziel="$TMP/ziel-$1-$2-$3-$4"
  rm -rf "$ziel"
  mkdir -p "$ziel/harness/sensors" "$ziel/tools/harness" "$ziel/harness/mk"
  if [ "$4" = 1 ]; then
    if [ "$1" = 1 ]; then
      printf '# environment-check\n\nmake environment-check\n' >"$ziel/harness/sensors/environment-check.md"
    else
      printf '# environment-check (ohne Ansprunch)\n' >"$ziel/harness/sensors/environment-check.md"
    fi
  fi
  if [ "$2" = 1 ]; then
    printf '#!/usr/bin/env bash\necho environment-check\n' >"$ziel/tools/harness/environment-check.sh"
  fi
  if [ "$3" = 1 ]; then
    printf '# harness/mk/environment.mk\nGATE_CHECKS := environment-check $(GATE_CHECKS)\n' >"$ziel/harness/mk/environment.mk"
  else
    printf '# harness/mk/environment.mk (ohne Verdrahtung)\n' >"$ziel/harness/mk/environment.mk"
  fi
  printf '%s' "$ziel"
}

@test 'Paarung gruen: Singleton-Aussage, Target-Skript und GATE_CHECKS-Verdrahtung liegen' {
  source "$TMP/funktion.sh"
  ziel="$(_paarung_target 1 1 1 1)"
  run umgebung_paarung_pruefen "$ziel"
  [ "$status" -eq 0 ]
}

@test 'Paarung rot, wenn die GATE_CHECKS-Verdrahtung faellt' {
  source "$TMP/funktion.sh"
  ziel="$(_paarung_target 1 1 0 1)"
  run umgebung_paarung_pruefen "$ziel"
  [ "$status" -eq 1 ]
  grep -q 'Target hinter dem make-Anspruch fehlt' <<<"$output"
}

@test 'Paarung rot, wenn das Target-Skript fehlt' {
  source "$TMP/funktion.sh"
  ziel="$(_paarung_target 1 0 1 1)"
  run umgebung_paarung_pruefen "$ziel"
  [ "$status" -eq 1 ]
  grep -q 'Target hinter dem make-Anspruch fehlt' <<<"$output"
}

@test 'Paarung rot, wenn der make-Anspruch im Singleton fehlt' {
  source "$TMP/funktion.sh"
  ziel="$(_paarung_target 0 1 1 1)"
  run umgebung_paarung_pruefen "$ziel"
  [ "$status" -eq 1 ]
  grep -q 'traegt seinen make-Anspruch nicht' <<<"$output"
}

@test 'Paarung rot, wenn das Singleton fehlt' {
  source "$TMP/funktion.sh"
  ziel="$(_paarung_target 1 1 1 0)"
  run umgebung_paarung_pruefen "$ziel"
  [ "$status" -eq 1 ]
  grep -q 'Singleton fehlt im Ziel-Baum' <<<"$output"
}
