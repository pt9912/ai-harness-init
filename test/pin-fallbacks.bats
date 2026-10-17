#!/usr/bin/env bats
# pin-fallbacks.bats — koppelt die wert-hardcodenden Fallbacks `GO_VERSION="${GO_VERSION:-<wert>}"`
# in harness/tools/smoke.sh und harness/tools/full-smoke.sh an den Pin `GO_VERSION ?=` im Makefile
# (LH-QA-02 · seit slice-doppelt-gefuehrte-werte-bekommen-ihren-kopplungs-sensor).
# Die Skripte laufen unter `make` mit gesetztem GO_VERSION; der Fallback greift beim direkten
# Aufruf und waere nach einem Pin-Zug still veraltet.
# NETZLOS (nur Datei-Vergleich) und gegen die REALEN Dateien, kein nachgebauter Stellvertreter:
# der Wert wird aus Makefile, smoke.sh und full-smoke.sh selbst gelesen. Grenze: gehalten ist
# der Fallback gegen den Makefile-Pin; das Dockerfile-ARG und die Skelett-Vorlage hält
# TestGoProfile_PinsMatchRepo (internal/gen).

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
}

pin() {
  sed -n 's/^GO_VERSION ?= \([^ ]*\).*/\1/p' "$REPO/Makefile" | head -1
}

fallback() {
  sed -n 's/^GO_VERSION="\${GO_VERSION:-\([^}]*\)}"$/\1/p' "$REPO/harness/tools/$1"
}

@test "pin-fallbacks: der Makefile-Pin GO_VERSION ist lesbar" {
  [ -n "$(pin)" ]
}

@test "pin-fallbacks: smoke.sh fuehrt genau einen GO_VERSION-Fallback" {
  [ "$(fallback smoke.sh | wc -l)" -eq 1 ]
}

@test "pin-fallbacks: full-smoke.sh fuehrt genau einen GO_VERSION-Fallback" {
  [ "$(fallback full-smoke.sh | wc -l)" -eq 1 ]
}

@test "pin-fallbacks: GO_VERSION-Fallback in smoke.sh == Makefile-Pin (LH-QA-02)" {
  [ "$(fallback smoke.sh)" = "$(pin)" ] || {
    echo "smoke.sh: Fallback '$(fallback smoke.sh)' != Makefile GO_VERSION '$(pin)' (Pin-Zug ohne Fallback)" >&2
    return 1
  }
}

@test "pin-fallbacks: GO_VERSION-Fallback in full-smoke.sh == Makefile-Pin (LH-QA-02)" {
  [ "$(fallback full-smoke.sh)" = "$(pin)" ] || {
    echo "full-smoke.sh: Fallback '$(fallback full-smoke.sh)' != Makefile GO_VERSION '$(pin)' (Pin-Zug ohne Fallback)" >&2
    return 1
  }
}
