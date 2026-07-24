#!/usr/bin/env bats
# cpp-freshness.bats — Tests fuer die C++/ubuntu-Base-Tag-Freshness-Achse
# (harness/tools/cpp-freshness.sh, slice-042 / MR-007 / LH-QA-01).
# Docker-only im gepinnten bats-Image (make test).
#
# HERMETISCH: getestet werden ausschliesslich der `--latest-lts <roh>`-Pfad
# (Fixture-Strings statt Docker-Hub-Fetch) und der `--compare`-Pfad (der an den
# quellen-agnostischen Vergleicher aus component-freshness.sh delegiert). Der Fetch
# (Docker Hub, Netz) ist davon getrennt und wird hier NIE aufgerufen — sonst braeche
# `make test` (in gates) die offline-gruen-Zusage (LH-QA-01).
#
# Die NEUE Logik gegenueber slice-040/041 ist die LTS-EXTRAKTION: „latest" heisst
# hoechstes LTS (gerades NN.04), NICHT der numerisch hoechste Tag — 25.04 (Interim)
# darf 24.04 (LTS) nicht schlagen.

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  CPP_FRESH="$REPO/harness/tools/cpp-freshness.sh"
  # Roher Docker-Hub-Tags-Text (JSON-Ausschnitt); nur "name":"NN.04" zaehlt.
  FIX_REAL='"name":"latest","name":"26.04","name":"25.04","name":"24.04","name":"22.04","name":"20.04","name":"noble"'
  # Faenger fuer den Gerade-Jahr-Filter: 25.04 ist der numerisch hoechste, aber
  # Nicht-LTS (ungerade) -> das LTS ist 24.04.
  FIX_INTERIM='"name":"25.04","name":"24.04","name":"22.04"'
  # Nur Interims (ungerade .04) + .10 -> kein LTS.
  FIX_NO_LTS='"name":"25.04","name":"23.04","name":"24.10"'
}

@test "cpp-freshness: latest-lts nimmt hoechstes LTS (gerades NN.04)" {
  run bash "$CPP_FRESH" --latest-lts "$FIX_REAL"
  [ "$status" -eq 0 ]
  [ "$output" = "26.04" ]
}

@test "cpp-freshness: latest-lts schliesst Nicht-LTS-Interim aus (25.04 < 24.04-LTS)" {
  # Der Fänger: ohne den Gerade-Jahr-Filter waere 25.04 (Interim) das Ergebnis.
  run bash "$CPP_FRESH" --latest-lts "$FIX_INTERIM"
  [ "$status" -eq 0 ]
  [ "$output" = "24.04" ]
}

@test "cpp-freshness: latest-lts ohne LTS -> leer (-> Fetch-Fehler-Klasse)" {
  run bash "$CPP_FRESH" --latest-lts "$FIX_NO_LTS"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "cpp-freshness: compare aktuell (gepinnt == latest-LTS -> exit 0)" {
  run bash "$CPP_FRESH" --compare "24.04" "24.04"
  [ "$status" -eq 0 ]
  printf '%s' "$output" | grep -q 'aktuell'
  printf '%s' "$output" | grep -q 'cpp-ubuntu'
}

@test "cpp-freshness: compare VERALTET (neueres LTS -> exit 1, beide genannt)" {
  run bash "$CPP_FRESH" --compare "24.04" "26.04"
  [ "$status" -eq 1 ]
  printf '%s' "$output" | grep -q 'VERALTET'
  printf '%s' "$output" | grep -q '24.04'
  printf '%s' "$output" | grep -q '26.04'
}

@test "cpp-freshness: compare leerer latest -> Fetch-Fehler (exit 2, NICHT veraltet)" {
  run bash "$CPP_FRESH" --compare "24.04" ""
  [ "$status" -eq 2 ]
  printf '%s' "$output" | grep -q 'FETCH-FEHLER'
  ! printf '%s' "$output" | grep -q 'VERALTET'
}

@test "cpp-freshness: latest-lts speist compare (Integration, offline)" {
  # Realer Fluss ohne Netz: LTS aus Tag-Liste extrahieren, dann vergleichen.
  # FIX_INTERIM -> 24.04; gepinnt 24.04 -> aktuell. Bricht der LTS-Filter (25.04
  # gewinnt), stimmt der Vergleich nicht mehr -> dieser Test faellt.
  latest="$(bash "$CPP_FRESH" --latest-lts "$FIX_INTERIM")"
  run bash "$CPP_FRESH" --compare "24.04" "$latest"
  [ "$status" -eq 0 ]
  printf '%s' "$output" | grep -q 'aktuell'
}
