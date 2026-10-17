#!/usr/bin/env bash
# digest-freshness — read-only Sensor: gehoert der `@sha256`-Digest jedes Image-Pins noch zu
# dem Tag, neben dem er steht? Ein Digest uebersteuert den Tag; ein Pin-Zug, der nur den Tag
# bewegt (oder nur den Digest), baut still auf dem alten Stand weiter (LH-QA-02 ·
# seit slice-doppelt-gefuehrte-werte-bekommen-ihren-kopplungs-sensor).
#
# NETZ-Operation, NICHT in gates (LH-QA-01: make gates bleibt offline-gruen). Der Sensor
# mutiert nichts; die Aufloesung ist `docker buildx imagetools inspect <ref> --format
# '{{.Manifest.Digest}}'`, der Manifest-Digest des Tags, den die Pins fuehren.
#
# Gelesen werden die REALEN Pin-Stellen (Repo-Wurzel relativ zu diesem Skript), je Pin Tag
# und Digest aus derselben Quelle:
#   golang           Makefile `GO_VERSION ?=`            + Dockerfile `FROM golang:…@sha256:…`
#   golangci-lint    Makefile `GOLANGCI_LINT_VERSION ?=` + Dockerfile `FROM golangci/…@sha256:…`
#   d-check          d-check.mk `DCHECK_IMAGE ?=` / `DCHECK_DIGEST ?=`
#   d-check (emit)   internal/emit/emit.go `DefaultImage` / `DefaultDigest`
#   a-check (emit)   internal/emit/archgate.go `DefaultArchImage` / `DefaultArchDigest`
# Eine Pin-Stelle, aus der Tag oder Digest nicht lesbar ist, endet mit Exit 2 und nennt die
# Stelle, statt aus dem Vergleich zu fallen.
#
# GRENZE: Pins ohne Tag neben dem Digest (bats, shellcheck, actionlint im Makefile; curl in
# harness/tools/tap-nachzug.sh und traeger-fetch.sh) hat der Sensor nicht in seiner Liste —
# ihr Tag ist nirgends gefuehrt, gegen den er den Digest halten koennte. Die Skelett-
# Dockerfiles der Vorlage fuehren keinen Digest.
#
# Exit: 0 = jeder Digest gehoert zu seinem Tag, 1 = mindestens einer nicht, 2 = Pin nicht
# lesbar oder Aufloesung fehlgeschlagen (KEIN Urteil; ein Befund 1 geht vor 2). Diese
# Abbildung der Hauptschleife haelt test/digest-freshness.bats ueber einen PATH-Stub `docker`
# gegen die realen Pin-Dateien; die Aufloesung gegen die Registry fuehrt allein
# `make freshness-digest`. Ein anonymes Hub-Rate-Limit (429) endet je Hub-Pin als FETCH-FEHLER
# mit Exit 2 und faerbt den Nacht-Lauf auch ohne Digest-Defekt.
# `--pins` gibt die gelesenen Pins aus (netzlos), `--compare <name> <ref> <pinned> <actual>`
# ruft nur den Vergleicher. bash + sed + docker.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Vergleicher (rein, netzlos). Die Meldung nennt die gebrochene Stelle: Komponente, Tag-
# Referenz, den gefuehrten und den aufgeloesten Digest sowie die Datei, die den Digest fuehrt.
compare_digest() {
  local name="$1" ref="$2" pinned="$3" actual="$4" stelle="${5:-}"
  if [ -z "$actual" ]; then
    echo "$name: FETCH-FEHLER (kein Urteil): $ref liess sich nicht aufloesen." >&2
    return 2
  fi
  if [ "$actual" = "$pinned" ]; then
    echo "$name: aktuell — $ref traegt den gepinnten Digest $pinned."
    return 0
  fi
  echo "$name: DIGEST WEICHT AB — der Digest gehoert nicht (mehr) zum Tag."
  echo "  tag:       $ref"
  echo "  gepinnt:   $pinned${stelle:+  ($stelle)}"
  echo "  aufgeloest: $actual"
  return 1
}

# wert <datei> <sed-ausdruck>: erste Treffer-Zeile, leer wenn keiner.
wert() {
  sed -n "$2" "$ROOT/$1" | head -1
}

# pins: je Zeile `name|ref|digest|stelle`; Exit 2 bei einer nicht lesbaren Stelle.
pins() {
  local rc=0 name ref digest stelle
  emit() {
    name="$1"; ref="$2"; digest="$3"; stelle="$4"
    if [ -z "$ref" ] || [ -z "$digest" ]; then
      echo "digest-freshness: Pin '$name' nicht lesbar ($stelle) — kein Urteil." >&2
      rc=2
      return
    fi
    printf '%s|%s|%s|%s\n' "$name" "$ref" "$digest" "$stelle"
  }
  local gv gl
  gv="$(wert Makefile 's/^GO_VERSION ?= \([^ ]*\).*/\1/p')"
  gl="$(wert Makefile 's/^GOLANGCI_LINT_VERSION ?= \([^ ]*\).*/\1/p')"
  emit go-toolchain "${gv:+golang:$gv}" \
    "$(wert Dockerfile 's/^FROM golang:[^@ ]*@\(sha256:[0-9a-f]\{64\}\) .*/\1/p')" \
    "Dockerfile FROM golang"
  emit golangci-lint "${gl:+golangci/golangci-lint:$gl}" \
    "$(wert Dockerfile 's/^FROM golangci\/golangci-lint:[^@ ]*@\(sha256:[0-9a-f]\{64\}\) .*/\1/p')" \
    "Dockerfile FROM golangci-lint"
  emit d-check "$(wert d-check.mk 's/^DCHECK_IMAGE ?= \([^ ]*\).*/\1/p')" \
    "$(wert d-check.mk 's/^DCHECK_DIGEST ?= \(sha256:[0-9a-f]\{64\}\).*/\1/p')" \
    "d-check.mk DCHECK_DIGEST"
  emit d-check-emit "$(wert internal/emit/emit.go 's/^[[:space:]]*DefaultImage[[:space:]]*=[[:space:]]*"\([^"]*\)".*/\1/p')" \
    "$(wert internal/emit/emit.go 's/^[[:space:]]*DefaultDigest[[:space:]]*=[[:space:]]*"\(sha256:[0-9a-f]\{64\}\)".*/\1/p')" \
    "internal/emit/emit.go DefaultDigest"
  emit a-check-emit "$(wert internal/emit/archgate.go 's/^[[:space:]]*DefaultArchImage[[:space:]]*=[[:space:]]*"\([^"]*\)".*/\1/p')" \
    "$(wert internal/emit/archgate.go 's/^[[:space:]]*DefaultArchDigest[[:space:]]*=[[:space:]]*"\(sha256:[0-9a-f]\{64\}\)".*/\1/p')" \
    "internal/emit/archgate.go DefaultArchDigest"
  return "$rc"
}

# --compare <name> <ref> <pinned> <actual> [<stelle>]: nur der Vergleicher (hermetisch).
if [ "${1:-}" = "--compare" ]; then
  rc=0
  compare_digest "${2:-}" "${3:-}" "${4:-}" "${5:-}" "${6:-}" || rc=$?
  exit "$rc"
fi

# --pins: nur das Lesen der Pin-Stellen (netzlos).
if [ "${1:-}" = "--pins" ]; then
  pins
  exit $?
fi

# Voller Lauf: je Pin aufloesen und vergleichen.
list="$(pins)" || list_rc=$?
befund=0
fehler="${list_rc:-0}"
while IFS='|' read -r name ref digest stelle; do
  [ -n "$name" ] || continue
  actual="$(docker buildx imagetools inspect "$ref" --format '{{.Manifest.Digest}}' 2>/dev/null)" || actual=""
  rc=0
  compare_digest "$name" "$ref" "$digest" "$actual" "$stelle" || rc=$?
  case "$rc" in
    1) befund=1 ;;
    2) fehler=2 ;;
  esac
done <<<"$list"
if [ "$befund" -ne 0 ]; then
  echo "digest-freshness: mindestens ein Digest gehoert nicht zu seinem Tag." >&2
  exit 1
fi
exit "$fehler"
