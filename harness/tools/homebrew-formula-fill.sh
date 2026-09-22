#!/usr/bin/env bash
# homebrew-formula-fill.sh — befuellt das Homebrew-Formel-Skeleton mit den Werten eines
# Release-Schnitts (slice-tap-verteilt-die-release-assets, LH-QA-04). Dieselbe Kopplung wie
# release-sums.sh: die Mechanik liegt in einem eigenen, direkt testbaren Skript statt inline
# im Workflow-Rezept.
#
# FAIL-CLOSED VOR DEM SCHREIBEN: fehlt einer der vier brew-relevanten Plattform-Digests
# (darwin/linux x amd64/arm64 — Homebrew traegt kein Windows) in der SHA256SUMS, bricht der
# Lauf, statt eine Formel mit leerem Digest zu schreiben, die erst beim ersten Tap-Abzug
# auffiele.
#
# AUFRUF: homebrew-formula-fill.sh <tag> <sums-datei> <skeleton> <ziel>
#   tag         der Release-Tag (z. B. v0.2.1) -> __TAG__, ohne fuehrendes "v" -> __VERSION__
#   sums-datei  Pfad zur SHA256SUMS des Schnitts (Format: sha256sum, "<hash>  <name>")
#   skeleton    Pfad zum Formel-Skeleton (harness/tools/homebrew-formula.rb.tmpl)
#   ziel        Pfad, an den die befuellte Formel geschrieben wird
#
# KEIN GATE: das Skript prueft nichts am Baum, haengt an keiner gates-Kette. Aufrufer ist
# der `artifacts`-Job in .github/workflows/release.yml, direkt nach `make release-artifacts`.
set -euo pipefail

tag="${1:-}"
sums="${2:-}"
skeleton="${3:-}"
ziel="${4:-}"
[ -n "$tag" ] && [ -n "$sums" ] && [ -n "$skeleton" ] && [ -n "$ziel" ] || {
	echo "homebrew-formula-fill: Aufruf: homebrew-formula-fill.sh <tag> <sums-datei> <skeleton> <ziel>" >&2
	exit 2
}
[ -f "$sums" ] || {
	echo "homebrew-formula-fill: $sums existiert nicht — ohne SHA256SUMS gibt es keine Digests." >&2
	exit 2
}
[ -f "$skeleton" ] || {
	echo "homebrew-formula-fill: $skeleton existiert nicht." >&2
	exit 2
}

version="${tag#v}"
digest() { awk -v n="ai-harness-init-$1" '$2 == n {print $1}' "$sums"; }

for plat in darwin-amd64 darwin-arm64 linux-amd64 linux-arm64; do
	d="$(digest "$plat")"
	[ -n "$d" ] || {
		echo "homebrew-formula-fill: kein SHA256SUMS-Eintrag fuer ai-harness-init-$plat — Abbruch vor dem Schreiben." >&2
		exit 1
	}
done

sed \
	-e "s/__VERSION__/${version}/g" \
	-e "s/__TAG__/${tag}/g" \
	-e "s/__SHA256_DARWIN_AMD64__/$(digest darwin-amd64)/g" \
	-e "s/__SHA256_DARWIN_ARM64__/$(digest darwin-arm64)/g" \
	-e "s/__SHA256_LINUX_AMD64__/$(digest linux-amd64)/g" \
	-e "s/__SHA256_LINUX_ARM64__/$(digest linux-arm64)/g" \
	"$skeleton" >"$ziel"
echo "homebrew-formula-fill: $ziel geschrieben (Tag $tag, vier Plattform-Digests befuellt)."
