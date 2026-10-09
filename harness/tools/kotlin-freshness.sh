#!/usr/bin/env bash
# kotlin-freshness — read-only Freshness-Sensor fuer den gradle-Image-Tag des
# emittierten Kotlin-Skeletts (LH-FA-04, LH-QA-02, ADR-0088 Festlegung 2). Quelle
# ist die Docker-Hub-Registry-API (`hub.docker.com/v2/repositories/library/gradle/tags`),
# gefiltert auf die JDK-Achse des Pins.
#
# PIN-QUELLE: `DefaultKotlinVersion` in internal/gen/kotlin.go, Form
# `<gradle>-jdk<NN>` (z. B. `9.8.1-jdk21`). Das Skript liest sie selbst (`--pinned`
# gibt sie aus); KOTLIN_PINNED ersetzt sie, wenn gesetzt und nicht leer.
#
# ACHSEN-REGEL: verglichen wird nur die Gradle-Achse bei FESTER JDK-Achse. Kandidat
# ist jeder Tag `X.Y.Z-jdk<NN>` mit dem <NN> des Pins; Varianten mit Suffix
# (`-alpine`, `-noble`, `-graal`, …), Kurz-Tags (`9.8-jdk21`, `jdk21`) und andere
# JDKs fallen heraus. latest = hoechster GELIEFERTER Kandidat nach `sort -V`; der Pin
# geht nicht als Kandidat ein (Gleichlauf mit cpp-freshness.sh).
#
# URTEILS-REGEL (`judge`): latest == Pin -> aktuell (Exit 0) · latest > Pin ->
# VERALTET (Exit 1) · latest < Pin -> KEIN URTEIL (Exit 2): der Pin liegt ueber jedem
# gelieferten Kandidaten, steht also nicht auf der gelesenen Seite, und ein hoeherer
# Tag ist dort auch nicht. Begruendung der dritten Klasse: die Seite ist nach
# last_updated sortiert, nicht nach Version (`name=jdk21` liefert 657 Tags auf 7
# Seiten; Seite 1 trug 8.14.6/9.8.1, Seite 2 9.6.0-9.8.0). Ein Pin ausserhalb von
# Seite 1 ist darum entweder upstream nicht vorhanden oder seit laengerem nicht neu
# gebaut — VERALTET mit einem NIEDRIGEREN latest riete eine Herabstufung, aktuell
# behauptete einen latest-Wert, den keine Quelle geliefert hat. Kein Urteil allein
# fuer "Pin fehlt" waere zu weit: ein gealterter Pin faellt von Seite 1, waehrend
# sein Nachfolger dort steht — das ist der VERALTET-Fall, und er bleibt einer.
# Grenze: eine neuere JDK-Achse (jdk25 neben jdk21) beurteilt der Sensor nicht.
# Grenze: gelesen wird EINE Seite (page_size=100), sortiert nach last_updated
# (Docker-Hub-Default), nicht nach Version; ein neuerer Tag, den mehr als 100
# juenger aktualisierte Tags derselben JDK-Achse verdraengen, bleibt unsichtbar.
#
# Den Vergleich traegt `component-freshness.sh --compare`; dieser Wrapper macht
# Pin-Lesen, Fetch und Kandidaten-Filter (Arbeitsteilung wie cpp-freshness.sh).
#
# NETZ-Operation, NICHT in gates (LH-QA-01). Der Sensor MUTIERT nichts — den Pin
# hebt eine eigene Operation.
#
# Exit (wie cpp-/component-freshness): 0 = aktuell, 1 = VERALTET, 2 = kein Urteil
# (Fetch-/Parse-Fehler, kein Kandidat, Pin ueber jedem gelieferten Kandidaten, Pin
# leer oder nicht in der Form `X.Y.Z-jdk<NN>`). Netzlos aufrufbar: `--pinned`,
# `--latest <pin> <roh>`, `--judge <pin> <roh>` (dieselbe Funktion, die der volle
# Lauf nach dem Fetch ruft), `--compare <pin> <latest>` und der Pin-Abbruch des
# vollen Laufs. bash + coreutils + grep + sed + sort + curl.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
GENERIC="$HERE/component-freshness.sh"
PIN_FILE="$REPO/internal/gen/kotlin.go"
NAME="kotlin-gradle"
ADVICE="DefaultKotlinVersion (internal/gen/kotlin.go) auf den neuen gradle-Tag heben (emittiertes Kotlin-Skelett)."
TAGS_URL_BASE="https://hub.docker.com/v2/repositories/library/gradle/tags/?page_size=100&name="

# Pin aus der Quelle lesen (netzlos). Keine Fundstelle -> leer.
read_pin() {
  sed -n 's/^const DefaultKotlinVersion = "\([^"]*\)"$/\1/p' "$PIN_FILE" 2>/dev/null || true
}

# JDK-Suffix des Pins (`-jdk21`); Pin nicht in der Form X.Y.Z-jdkNN -> leer.
jdk_suffix() {
  { grep -oE '^[0-9]+\.[0-9]+\.[0-9]+-jdk[0-9]+$' <<<"$1" | grep -oE -- '-jdk[0-9]+$' ; } || true
}

# Kandidaten-Filter (netzlos): $1 = Pin, stdin = roher Tags-Text. Liefert den
# hoechsten gelieferten Tag `X.Y.Z<suffix>` mit dem JDK des Pins; ohne Kandidat leer.
extract_latest() {
  local pin="$1" suffix found
  suffix="$(jdk_suffix "$pin")"
  [ -n "$suffix" ] || return 0
  found="$({ grep -oE "\"name\": ?\"[0-9]+\.[0-9]+\.[0-9]+${suffix}\"" \
      | grep -oE "[0-9]+\.[0-9]+\.[0-9]+${suffix}" ; } || true)"
  [ -n "$found" ] || return 0
  printf '%s\n' "$found" | sort -V | tail -n 1
}

# Urteil (netzlos): $1 = Pin, $2 = roher Tags-Text. URTEILS-REGEL im Kopf; latest
# < Pin endet hier mit Exit 2, alles andere urteilt der gemeinsame Vergleicher.
judge() {
  local pin="$1" latest
  latest="$(printf '%s' "$2" | extract_latest "$pin")"
  if [ -n "$latest" ] && [ "$latest" != "$pin" ] \
      && [ "$(printf '%s\n%s\n' "$latest" "$pin" | sort -V | tail -n 1)" = "$pin" ]; then
    echo "$NAME: KEIN URTEIL: gepinnt $pin steht nicht unter den gelieferten Tags, und keiner liegt darueber (hoechster gelieferter: $latest) — gelesen wird eine Seite, sortiert nach last_updated." >&2
    exit 2
  fi
  exec env COMPONENT_ADVICE="$ADVICE" bash "$GENERIC" --compare "$NAME" "$pin" "$latest"
}

if [ "${1:-}" = "--pinned" ]; then
  read_pin
  exit 0
fi

if [ "${1:-}" = "--latest" ]; then
  printf '%s' "${3:-}" | extract_latest "${2:-}"
  exit 0
fi

if [ "${1:-}" = "--judge" ]; then
  judge "${2:-}" "${3:-}"
fi

if [ "${1:-}" = "--compare" ]; then
  exec env COMPONENT_ADVICE="$ADVICE" bash "$GENERIC" --compare "$NAME" "${2:-}" "${3:-}"
fi

pinned="${KOTLIN_PINNED:-}"
[ -n "$pinned" ] || pinned="$(read_pin)"
suffix="$(jdk_suffix "$pinned")"
if [ -z "$suffix" ]; then
  echo "$NAME: KEIN URTEIL: kein gepinnter Wert in der Form X.Y.Z-jdk<NN> — gelesen: '${pinned}' (DefaultKotlinVersion in internal/gen/kotlin.go)." >&2
  exit 2
fi
raw="$(curl -fsSL "${TAGS_URL_BASE}${suffix#-}")" || raw=""
judge "$pinned" "$raw"
