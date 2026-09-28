#!/usr/bin/env bats
# dockerfile-teststufe.bats — Waechter fuer die test-Stufe und den Ressourcen-Deckel
# des Testlaufs.
#
# Die Vorwaerm-Stufe macht den Kompilat-Cache ueber Builds hinweg wiederverwendbar.
# Damit ist eine Zusage angreifbar, die sonst bauartbedingt hielte: "die Tests sind
# wirklich gelaufen". Mit warmem Cache ueberspringt das Test-Werkzeug unveraenderte
# Pakete, wenn -count=1 fehlt — der Lauf bliebe schnell und gruen und meldete gecachte
# Ergebnisse als bestandene Tests. Der Testlauf selbst ist kein `RUN` im Dockerfile,
# sondern ein `docker run` (Makefile-Ziel test-go) — ein Run wird nie gecacht, das
# traegt die erste Haelfte der Zusage; -count=1 im Makefile-Rezept die zweite.

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
}

@test "makefile: der Go-Testlauf (docker run) erzwingt die Test-Ausfuehrung (-count=1)" {
  run grep -A 2 "^test-go:" "$REPO/Makefile"
  [ "$status" -eq 0 ]
  [[ "$output" == *"-count=1"* ]]
}

@test "makefile: der Go-Testlauf laeuft per docker run, nicht mehr als RUN im Dockerfile-Build" {
  run grep -A 2 "^test-go:" "$REPO/Makefile"
  [ "$status" -eq 0 ]
  [[ "$output" == *"docker run"* ]]
}

@test "makefile: der Go-Testlauf traegt einen Prozess-Deckel (--pids-limit)" {
  run grep -A 2 "^test-go:" "$REPO/Makefile"
  [ "$status" -eq 0 ]
  [[ "$output" == *"--pids-limit"* ]]
}

@test "makefile: der Go-Testlauf traegt einen Speicher-Deckel (--memory)" {
  run grep -A 2 "^test-go:" "$REPO/Makefile"
  [ "$status" -eq 0 ]
  [[ "$output" == *"--memory"* ]]
}

@test "dockerfile: die test-Stufe fuehrt go test NICHT mehr im Build aus" {
  run grep -A 3 "^FROM warm AS test" "$REPO/Dockerfile"
  [ "$status" -eq 0 ]
  [[ "$output" != *"go test"* ]]
}

@test "dockerfile: es gibt eine Vorwaerm-Stufe, von der die test-Stufe erbt" {
  run grep -c "^FROM deps AS warm" "$REPO/Dockerfile"
  [ "$output" = "1" ]
  run grep -c "^FROM warm AS test" "$REPO/Dockerfile"
  [ "$output" = "1" ]
}
