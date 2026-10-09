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
# JDKs fallen heraus. latest = hoechster Kandidat nach `sort -V`, der Pin selbst
# zaehlt mit, sobald ein Kandidat gefunden ist — ein Pin, der neuer ist als jeder
# gelieferte Tag, meldet sich damit als aktuell, nicht als VERALTET.
# Grenze: eine neuere JDK-Achse (jdk25 neben jdk21) beurteilt der Sensor nicht.
# Grenze: gelesen wird EINE Seite (page_size=100, Docker-Hub-Default-Sortierung
# last_updated); ein neuerer Tag ausserhalb dieser Seite bleibt unsichtbar.
#
# Den Vergleich traegt `component-freshness.sh --compare`; dieser Wrapper macht
# Pin-Lesen, Fetch und Kandidaten-Filter (Arbeitsteilung wie cpp-freshness.sh).
#
# NETZ-Operation, NICHT in gates (LH-QA-01). Der Sensor MUTIERT nichts — den Pin
# hebt eine eigene Operation.
#
# Exit (wie cpp-/component-freshness): 0 = aktuell, 1 = VERALTET, 2 = kein Urteil
# (Fetch-/Parse-Fehler, kein Kandidat, Pin leer oder nicht in der Form
# `X.Y.Z-jdk<NN>`). Netzlos aufrufbar: `--pinned`, `--latest <pin> <roh>`,
# `--compare <pin> <latest>` und der Pin-Abbruch des vollen Laufs. bash + coreutils
# + grep + sed + sort + curl.
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
# hoechsten Tag `X.Y.Z<suffix>` des Pins; ohne Kandidat leer.
extract_latest() {
  local pin="$1" suffix found
  suffix="$(jdk_suffix "$pin")"
  [ -n "$suffix" ] || return 0
  found="$({ grep -oE "\"name\": ?\"[0-9]+\.[0-9]+\.[0-9]+${suffix}\"" \
      | grep -oE "[0-9]+\.[0-9]+\.[0-9]+${suffix}" ; } || true)"
  [ -n "$found" ] || return 0
  printf '%s\n%s\n' "$found" "$pin" | sort -V | tail -n 1
}

if [ "${1:-}" = "--pinned" ]; then
  read_pin
  exit 0
fi

if [ "${1:-}" = "--latest" ]; then
  printf '%s' "${3:-}" | extract_latest "${2:-}"
  exit 0
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
latest="$(printf '%s' "$raw" | extract_latest "$pinned")"
exec env COMPONENT_ADVICE="$ADVICE" bash "$GENERIC" --compare "$NAME" "$pinned" "$latest"
