#!/usr/bin/env bats
# dockerfile-teststufe.bats — Waechter fuer die test-Stufe und den Ressourcen-Deckel
# des Testlaufs.
#
# Die Vorwaerm-Stufe macht den Kompilat-Cache ueber Builds hinweg wiederverwendbar.
# Damit ist eine Zusage angreifbar, die sonst bauartbedingt hielte: "die Tests sind
# wirklich gelaufen". Mit warmem Cache ueberspringt das Test-Werkzeug unveraenderte
# Pakete, wenn -count=1 fehlt — der Lauf bliebe schnell und gruen und meldete gecachte
# Ergebnisse als bestandene Tests (am Host teilt go den Kompilat-Cache ueber Laeufe,
# im Image tut es die warm-Stufe). Seit slice-labor-gates-host-rezepte traegt der
# Pflicht-Weg die Rezept-Zeile `go test -count=1 ./...` (Makefile-Ziel test-go,
# ADR-0109) und der opt-in Weg denselben Lauf per `docker run` (test-go-image) —
# ein Run wird nie gecacht, das traegt die erste Haelfte der Zusage; -count=1 im
# Rezept je Weg die zweite. Die Ressourcen-Decken --pids-limit/--memory sind eine
# Eigenschaft des Image-Wegs: sie fallen mit den docker-Flags, die der
# Container-Kontext durchsetzt; der Host-Weg traegt sie NICHT (benannte Grenze,
# Kommentar bei TEST_PIDS_LIMIT) — gemessen gegen test-go-image, nicht gegen
# test-go.

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
}

@test "makefile: der Go-Testlauf am Host erzwingt die Test-Ausfuehrung (-count=1)" {
  run grep -A 2 "^test-go:" "$REPO/Makefile"
  [ "$status" -eq 0 ]
  [[ "$output" == *"go test -count=1 ./..."* ]]
}

@test "makefile: der Go-Testlauf im Image laeuft per docker run mit -count=1" {
  run grep -A 3 "^test-go-image:" "$REPO/Makefile"
  [ "$status" -eq 0 ]
  [[ "$output" == *"docker run"* ]]
  [[ "$output" == *"-count=1"* ]]
}

@test "makefile: der Image-Testlauf traegt einen Prozess-Deckel (--pids-limit)" {
  run grep -A 3 "^test-go-image:" "$REPO/Makefile"
  [ "$status" -eq 0 ]
  [[ "$output" == *"--pids-limit"* ]]
}

@test "makefile: der Image-Testlauf traegt einen Speicher-Deckel (--memory)" {
  run grep -A 3 "^test-go-image:" "$REPO/Makefile"
  [ "$status" -eq 0 ]
  [[ "$output" == *"--memory"* ]]
}

@test "makefile: der Host-Testlauf traegt den Ressourcen-Deckel NICHT (benannte Grenze)" {
  run make -n test-go
  [ "$status" -eq 0 ]
  [[ "$output" == *"go test -count=1 ./..."* ]]
  [[ "$output" != *"--pids-limit"* ]]
  [[ "$output" != *"--memory"* ]]
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
