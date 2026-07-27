#!/usr/bin/env bats
# dockerfile-teststufe.bats — Waechter fuer die test-Stufe (slice-057).
#
# Die Vorwaerm-Stufe macht den Kompilat-Cache ueber Builds hinweg wiederverwendbar.
# Damit wird eine Zusage angreifbar, die vorher bauartbedingt hielt: "die Tests sind
# wirklich gelaufen". Mit warmem Cache ueberspringt das Test-Werkzeug unveraenderte
# Pakete, wenn -count=1 fehlt — der Lauf bliebe schnell und gruen und meldete gecachte
# Ergebnisse als bestandene Tests. Genau diese stille Regression faengt dieser Waechter.

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
}

@test "dockerfile: die test-Stufe erzwingt die Test-Ausfuehrung (-count=1)" {
  run grep -A 3 "^FROM warm AS test" "$REPO/Dockerfile"
  [ "$status" -eq 0 ]
  [[ "$output" == *"-count=1"* ]]
}

@test "dockerfile: es gibt eine Vorwaerm-Stufe, von der die test-Stufe erbt" {
  run grep -c "^FROM deps AS warm" "$REPO/Dockerfile"
  [ "$output" = "1" ]
  run grep -c "^FROM warm AS test" "$REPO/Dockerfile"
  [ "$output" = "1" ]
}
