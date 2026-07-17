#!/usr/bin/env bash
# baseline-verify — prueft die committet vendored Baseline
# (.harness/baseline/<tag>/{regelwerk,templates}/ + SHA256SUMS) NETZLOS.
#
# Zwei Pruefungen, beide noetig (MR-007):
#   1. Integritaet   — sha256sum -c ueber SHA256SUMS: erkennt GEAENDERTE und
#                      GELOESCHTE Dateien.
#   2. Vollstaendigkeit — Dateibestand == SHA256SUMS-Liste: erkennt ZUSAETZLICH
#                      EINGELEGTE Dateien. Ohne diesen Schritt bliebe das Gate
#                      dabei gruen (sha256sum -c prueft nur, was gelistet ist) —
#                      "prueft die Integritaet der Arbeitskopie" waere dann
#                      ueberdehnt (LH-QA-01).
#
# Laeuft IN gates: kein curl, kein unzip, kein Netz -> offline-gruen bleibt
# erhalten (LH-QA-01/LH-QA-02). Upstream-Drift ist NICHT Gegenstand dieses
# Gates — das ueberwacht `make regelwerk-check` (Maintenance/Netz, NICHT in
# gates). SHA256SUMS ist selbst erzeugt und belegt daher nur, dass der Baum
# sich seit dem Vendoring nicht bewegt hat, NICHT seine Herkunft; die
# Upstream-Provenienz haengt an BASELINE_ZIP_SHA256 (Makefile, MR-007).
#
# Kein node/jq/python (LH-QA-03): bash + coreutils.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
base="$here/../../.harness/baseline"

# <tag>-Politik (MR-007): ein Tag zur Zeit (Ersetzen), Historie liegt in git.
# Das Verzeichnis wird ENTDECKT, nicht geraten — so steht der Tag-String nur in
# BASELINE_TAG (Makefile) und nirgends sonst in der Mechanik. Mehr als ein
# <tag>-Verzeichnis verletzt die Setzung und schlaegt hier an, statt still zu
# passieren.
shopt -s nullglob
dirs=("$base"/*/)
shopt -u nullglob

if [ "${#dirs[@]}" -eq 0 ]; then
  echo "FEHLER: keine vendored Baseline unter .harness/baseline/<tag>/." >&2
  echo "  Die Baseline ist committet — ein leeres Verzeichnis bedeutet einen kaputten Checkout," >&2
  echo "  keinen fehlenden Fetch (es gibt kein 'make regelwerk-fetch' mehr, MR-007)." >&2
  exit 1
fi
if [ "${#dirs[@]}" -gt 1 ]; then
  echo "FEHLER: mehr als ein <tag>-Verzeichnis unter .harness/baseline/:" >&2
  printf '  %s\n' "${dirs[@]}" >&2
  echo "  Setzung (MR-007): ein Tag zur Zeit (Ersetzen), Historie liegt in git." >&2
  exit 1
fi

dir="${dirs[0]%/}"
tag="$(basename "$dir")"
cd "$dir"

if [ ! -f SHA256SUMS ]; then
  echo "FEHLER: $tag/SHA256SUMS fehlt — die Baseline ist ohne Pruefsummen nicht verifizierbar." >&2
  exit 1
fi

# 1) Integritaet der gelisteten Dateien (geaendert/geloescht).
if ! sha256sum -c --quiet SHA256SUMS; then
  echo "FEHLER: Baseline $tag weicht von SHA256SUMS ab (geaenderte oder fehlende Datei)." >&2
  exit 1
fi

# 2) Vollstaendigkeit (zusaetzlich eingelegte Datei). SHA256SUMS selbst ist
# ausgenommen — sie kann sich nicht selbst hashen; ihre Integritaet traegt git.
listed="$(cut -d' ' -f3- SHA256SUMS | LC_ALL=C sort)"
actual="$(find . -type f ! -path ./SHA256SUMS | sed 's|^\./||' | LC_ALL=C sort)"
if [ "$listed" != "$actual" ]; then
  echo "FEHLER: Dateibestand von $tag weicht von SHA256SUMS ab (ungelistete oder fehlende Pfade):" >&2
  diff <(printf '%s\n' "$listed") <(printf '%s\n' "$actual") >&2 || true
  exit 1
fi

echo "baseline-verify: $tag OK — $(wc -l < SHA256SUMS) Dateien (Integritaet + Vollstaendigkeit, netzlos)"
