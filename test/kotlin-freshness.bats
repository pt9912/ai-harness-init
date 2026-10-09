#!/usr/bin/env bats
# kotlin-freshness.bats — Tests fuer die gradle-Image-Tag-Freshness-Achse des
# Kotlin-Skeletts (harness/tools/kotlin-freshness.sh, LH-FA-04, LH-QA-02, ADR-0088).
# Docker-only im gepinnten bats-Image (make test).
#
# Gemessen wird netzlos: das Lesen des Pins aus internal/gen/kotlin.go (`--pinned`),
# der Kandidaten-Filter ueber Fixture-Tags (`--latest`), das Urteil, das der volle Lauf
# nach dem Fetch ruft (`--judge`), der Vergleich (`--compare`) und der Abbruch des vollen Laufs bei einem Pin ausserhalb der Form X.Y.Z-jdk<NN>,
# der vor dem Fetch endet. Den Fetch gegen Docker Hub ruft keiner dieser Tests.

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  KT_FRESH="$REPO/harness/tools/kotlin-freshness.sh"
  # Ausschnitt einer Docker-Hub-Tag-Antwort: 9.9.0-jdk21 ist der hoechste Kandidat
  # der JDK-Achse 21; die uebrigen Tags sind Varianten, Kurz-Tags oder andere JDKs.
  FIX_NEUER='{"name":"9.9.0-jdk21"},{"name":"9.8.1-jdk21"},{"name": "9.8.0-jdk21"},{"name":"9.9-jdk21"},{"name":"jdk21"}'
  # Nur Tags ausserhalb der Achse: hoeheres Gradle mit Varianten-Suffix, anderem JDK
  # oder Kurzform. Kandidat ist allein der Pin selbst.
  FIX_FREMD='{"name":"9.8.1-jdk21"},{"name":"9.9.0-jdk21-alpine"},{"name":"9.9.0-jdk25"},{"name":"10.0-jdk21"}'
}

@test "kotlin-freshness: --pinned liest DefaultKotlinVersion aus internal/gen/kotlin.go in der Form X.Y.Z-jdkNN" {
  run bash "$KT_FRESH" --pinned
  [ "$status" -eq 0 ]
  expected="$(sed -n 's/^const DefaultKotlinVersion = "\(.*\)"$/\1/p' "$REPO/internal/gen/kotlin.go")"
  [ -n "$expected" ]
  [ "$output" = "$expected" ]
  [[ "$output" =~ ^[0-9]+\.[0-9]+\.[0-9]+-jdk[0-9]+$ ]]
}

@test "kotlin-freshness: veralteter Pin meldet VERALTET mit beiden Tags (Exit 1)" {
  latest="$(bash "$KT_FRESH" --latest "9.8.1-jdk21" "$FIX_NEUER")"
  [ "$latest" = "9.9.0-jdk21" ]
  run bash "$KT_FRESH" --compare "9.8.1-jdk21" "$latest"
  [ "$status" -eq 1 ]
  grep -q 'kotlin-gradle: VERALTET' <<<"$output"
  grep -q 'gepinnt: 9.8.1-jdk21' <<<"$output"
  grep -q 'latest:  9.9.0-jdk21' <<<"$output"
}

@test "kotlin-freshness: aktueller Pin meldet keinen Drift (Exit 0, kein VERALTET)" {
  latest="$(bash "$KT_FRESH" --latest "9.9.0-jdk21" "$FIX_NEUER")"
  run bash "$KT_FRESH" --compare "9.9.0-jdk21" "$latest"
  [ "$status" -eq 0 ]
  grep -q 'kotlin-gradle: aktuell' <<<"$output"
  ! grep -q 'VERALTET' <<<"$output"
}

@test "kotlin-freshness: Varianten-Suffix, anderes JDK und Kurz-Tag zaehlen nicht als neuerer Tag" {
  run bash "$KT_FRESH" --latest "9.8.1-jdk21" "$FIX_FREMD"
  [ "$status" -eq 0 ]
  [ "$output" = "9.8.1-jdk21" ]
}

@test "kotlin-freshness: latest kommt allein aus den gelieferten Tags, der Pin ist kein Kandidat" {
  run bash "$KT_FRESH" --latest "9.10.0-jdk21" "$FIX_NEUER"
  [ "$status" -eq 0 ]
  [ "$output" = "9.9.0-jdk21" ]
}

@test "kotlin-freshness: Pin ueber jedem gelieferten Kandidaten gibt kein Urteil (Exit 2)" {
  run bash "$KT_FRESH" --judge "9.10.0-jdk21" "$FIX_NEUER"
  [ "$status" -eq 2 ]
  grep -qF 'kotlin-gradle: KEIN URTEIL: gepinnt 9.10.0-jdk21 steht nicht unter den gelieferten Tags, und keiner liegt darueber (hoechster gelieferter: 9.9.0-jdk21)' <<<"$output"
  ! grep -q 'aktuell' <<<"$output"
  ! grep -q 'VERALTET' <<<"$output"
}

@test "kotlin-freshness: Pin nicht geliefert, ein hoeherer Tag schon, meldet VERALTET (Exit 1)" {
  run bash "$KT_FRESH" --judge "9.7.0-jdk21" "$FIX_NEUER"
  [ "$status" -eq 1 ]
  grep -q 'kotlin-gradle: VERALTET' <<<"$output"
  grep -q 'latest:  9.9.0-jdk21' <<<"$output"
}

@test "kotlin-freshness: --judge mit geliefertem Pin als hoechstem Tag meldet aktuell (Exit 0)" {
  run bash "$KT_FRESH" --judge "9.9.0-jdk21" "$FIX_NEUER"
  [ "$status" -eq 0 ]
  grep -q 'kotlin-gradle: aktuell' <<<"$output"
}

@test "kotlin-freshness: ohne Kandidaten kein latest, der Vergleich urteilt nicht (Exit 2)" {
  latest="$(bash "$KT_FRESH" --latest "9.8.1-jdk21" '{"name":"9.9.0-jdk25"}')"
  [ "$latest" = "" ]
  run bash "$KT_FRESH" --compare "9.8.1-jdk21" "$latest"
  [ "$status" -eq 2 ]
  grep -q 'FETCH-FEHLER' <<<"$output"
  ! grep -q 'VERALTET' <<<"$output"
}

@test "kotlin-freshness: Pin ausserhalb der Form X.Y.Z-jdkNN bricht vor dem Fetch mit Exit 2 ab" {
  run env KOTLIN_PINNED="9.8-jdk21" bash "$KT_FRESH" </dev/null
  [ "$status" -eq 2 ]
  grep -q "KEIN URTEIL: kein gepinnter Wert in der Form X.Y.Z-jdk<NN> — gelesen: '9.8-jdk21'" <<<"$output"
  ! grep -q 'VERALTET' <<<"$output"
}
