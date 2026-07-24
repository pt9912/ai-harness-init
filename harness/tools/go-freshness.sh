#!/usr/bin/env bash
# go-freshness — read-only Freshness-Sensor fuer die Go-Toolchain (slice-041,
# MR-007). Go ist eine SONDERQUELLE: anders als die GitHub-releases/latest-Achsen
# (component-freshness.sh, slice-040) publiziert golang/go keine GitHub-Release-
# Objekte — `github.com/golang/go/releases/latest` redirected auf `.../releases`
# (kein `/releases/tag/<tag>`). Die aktuelle stabile Version kommt daher von
# go.dev: `https://go.dev/VERSION?m=text` liefert sie als PLAINTEXT (erste Zeile,
# z. B. `go1.26.5`) — kein jq/JSON noetig (LH-QA-03).
#
# Der VERGLEICHER wird NICHT dupliziert: `compare_tags` ist in component-freshness.sh
# quellen-agnostisch (vergleicht zwei Strings). Dieser Wrapper macht nur das
# Go-Eigene — Fetch + Normalisierung — und ruft dann `component-freshness.sh
# --compare`. Das ist dieselbe Arbeitsteilung wie baseline-freshness.sh, nur mit
# eigenem Fetch statt der GitHub-Mechanik.
#
# NORMALISIERUNG: go.dev sagt `go1.26.5`, der Pin (GO_VERSION, Makefile) ist bar
# `1.26.4`. Auf EIN Format bringen: erste Zeile nehmen, `go`-Praefix strippen.
# Der Vergleich ist Gleich/Ungleich (wie slice-040) — kein Semver-Sort; eine
# monotone Toolchain-Reihe kennt keinen "neuer, aber aelterer" Fall.
#
# NETZ-Operation, NICHT in gates (LH-QA-01: make gates bleibt offline-gruen). Der
# Sensor MUTIERT nichts — der GO_VERSION-Bump bleibt eine separate, bewusste
# Operation (inkl. Dockerfile-Digest; out-of-scope der Welle, wie der Baseline-Bump).
#
# Exit (wie component-/baseline-freshness): 0 = aktuell, 1 = VERALTET, 2 = Fetch-/
# Parse-Fehler. Fetch<->Normalisierung<->Vergleich getrennt: `--normalize <roh>`
# ruft NUR die Normalisierung (hermetisch, kein Netz) — so testet der bats-Test in
# gates sie mit Fixture-Strings. bash + coreutils + curl.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GENERIC="$HERE/component-freshness.sh"
NAME="go-toolchain"
ADVICE="GO_VERSION (Makefile) bumpen; Dockerfile-golang-Digest + gen-Skelett-Pin ziehen mit (TestGoProfile_PinsMatchRepo)."
GO_VERSION_URL="https://go.dev/VERSION?m=text"

# Normalisierung (rein, netzlos): rohe go.dev-Ausgabe -> bares Pin-Format.
# Erste Zeile (`go1.26.5`), `go`-Praefix strippen -> `1.26.5`. Leere Eingabe ->
# leer (der Vergleicher behandelt leer als Fetch-Fehler, Exit 2 — eine Quelle
# fuer die Fehler-Klasse, nicht zwei).
normalize_version() {
  local raw="$1" first
  first="$(printf '%s\n' "$raw" | head -n 1)"
  # `go`-Praefix nur am Zeilenanfang entfernen (nicht mitten im String).
  printf '%s' "${first#go}"
}

# Fetch (Netz): go.dev/VERSION?m=text holen. Bei curl-Fehler: leer (der Aufrufer
# macht daraus Exit 2 ueber den leeren-latest-Zweig des Vergleichers).
fetch_go_version() {
  curl -fsSL "$GO_VERSION_URL" || return 1
}

# --normalize <roh>: nur die Normalisierung (hermetisch, fuer den Test).
if [ "${1:-}" = "--normalize" ]; then
  normalize_version "${2:-}"
  exit 0
fi

# --compare <gepinnt> <latest>: der Go-Name + Advice, delegiert an den generischen
# Vergleicher (2-arg-Schnittstelle wie baseline-freshness, Name injiziert).
if [ "${1:-}" = "--compare" ]; then
  exec env COMPONENT_ADVICE="$ADVICE" bash "$GENERIC" --compare "$NAME" "${2:-}" "${3:-}"
fi

# Voller Lauf: gepinnt aus GO_VERSION (kanonische Quelle, Makefile-Build-Arg),
# latest per Netz -> normalisieren -> generischer Vergleicher. Der --compare-Pfad
# nimmt Name/gepinnt/latest POSITIONAL; nur COMPONENT_ADVICE liest der Vergleicher
# aus der Umgebung (die VERALTET-Handlungszeile).
pinned="${GO_VERSION:?GO_VERSION nicht gesetzt — via Makefile durchreichen}"
raw="$(fetch_go_version)" || raw=""
latest="$(normalize_version "$raw")"
exec env COMPONENT_ADVICE="$ADVICE" bash "$GENERIC" --compare "$NAME" "$pinned" "$latest"
