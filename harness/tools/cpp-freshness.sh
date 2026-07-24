#!/usr/bin/env bash
# cpp-freshness — read-only Freshness-Sensor fuer den ubuntu-Base-Tag des
# emittierten C++-Skeletts (slice-042, MR-007). Docker Hub ist eine SONDERQUELLE
# (weder GitHub-releases/latest wie component-freshness.sh noch go.dev wie
# go-freshness.sh): die verfuegbaren Tags kommen aus der Docker-Hub-Registry-API
# (`hub.docker.com/v2/repositories/library/ubuntu/tags`), und „latest" heisst hier
# das hoechste LTS, nicht der numerisch hoechste Tag.
#
# LTS-REGEL (ubuntu-Konvention): `NN.04` mit GERADEM NN ist LTS (20/22/24/26.04);
# `.10` und ungerades `NN.04` (23.04/25.04) sind Nicht-LTS-Interims und werden
# ausgefiltert. Das aktuelle LTS = hoechstes gerades `NN.04` (sort -V | tail -1).
#
# Der VERGLEICHER wird NICHT dupliziert: `compare_tags` ist in component-freshness.sh
# quellen-agnostisch. Dieser Wrapper macht nur das Docker-Hub-Eigene — Fetch +
# LTS-Extraktion — und ruft dann `component-freshness.sh --compare` (dieselbe
# Arbeitsteilung wie go-freshness.sh).
#
# Mechanik ohne jq (LH-QA-03): den JSON-Text mit grep/awk/sort verarbeiten
# (`"name":"NN.04"` grep'en, gerades NN filtern, sort -V | tail -1).
#
# NETZ-Operation, NICHT in gates (LH-QA-01: make gates bleibt offline-gruen). Der
# Sensor MUTIERT nichts — der DefaultCppVersion-Bump bleibt eine separate, bewusste
# Operation (out-of-scope der Detect-Welle).
#
# Exit (wie component-/go-freshness): 0 = aktuell, 1 = VERALTET, 2 = Fetch-/Parse-
# Fehler (auch: kein gepinnter Wert, kein LTS gefunden). Fetch<->LTS-Extraktion<->
# Vergleich getrennt: `--latest-lts <roh>` ruft NUR die Extraktion (hermetisch, kein
# Netz) — so testet der bats-Test in gates sie mit Fixture-Strings. bash + coreutils
# + awk + curl.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GENERIC="$HERE/component-freshness.sh"
NAME="cpp-ubuntu"
ADVICE="DefaultCppVersion (internal/gen/cpp.go) auf das neue LTS bumpen (emittiertes C++-Skelett)."
TAGS_URL="https://hub.docker.com/v2/repositories/library/ubuntu/tags/?page_size=100"

# LTS-Extraktion (rein, netzlos): liest den rohen Docker-Hub-Tags-Text von stdin,
# liefert das hoechste LTS (gerades NN.04). Leere/LTS-lose Eingabe -> leer (der
# Vergleicher macht daraus Exit 2). `|| true`: findet der erste grep nichts, soll
# die Funktion leer/Erfolg zurueckgeben, nicht unter pipefail abbrechen.
extract_latest_lts() {
  { grep -oE '"name":"[0-9]{2}\.04"' \
      | grep -oE '[0-9]{2}\.04' \
      | awk -F. '($1 % 2) == 0' \
      | sort -V | tail -n 1 ; } || true
}

# Fetch (Netz): die ubuntu-Tags von Docker Hub holen. Bei curl-Fehler: leer.
fetch_ubuntu_tags() {
  curl -fsSL "$TAGS_URL" || return 1
}

# --latest-lts <roh>: nur die LTS-Extraktion (hermetisch, fuer den Test).
if [ "${1:-}" = "--latest-lts" ]; then
  printf '%s' "${2:-}" | extract_latest_lts
  exit 0
fi

# --compare <gepinnt> <latest>: der cpp-Name + Advice, delegiert an den generischen
# Vergleicher (2-arg-Schnittstelle wie go-freshness, Name injiziert).
if [ "${1:-}" = "--compare" ]; then
  exec env COMPONENT_ADVICE="$ADVICE" bash "$GENERIC" --compare "$NAME" "${2:-}" "${3:-}"
fi

# Voller Lauf: gepinnt aus CPP_PINNED (das Makefile extrahiert DefaultCppVersion aus
# cpp.go), latest per Netz -> LTS-Extraktion -> generischer Vergleicher.
#
# Leerer Pin (sed-Extrakt aus cpp.go fehlgeschlagen, z. B. Konstant umbenannt) ist
# die KANN-NICHT-URTEILEN-Klasse -> Exit 2 (wie ein Fetch-Fehler), NICHT `${VAR:?}`
# (das braeche mit Exit 1 = VERALTET ab und meldete Drift, wo der Pin nur unlesbar
# ist — der Header oben sagt fuer Exit 2 ausdruecklich "auch: kein gepinnter Wert").
pinned="${CPP_PINNED:-}"
if [ -z "$pinned" ]; then
  echo "$NAME: FETCH-FEHLER (kein Freshness-Urteil): kein gepinnter Wert — CPP_PINNED leer (sed-Extrakt von DefaultCppVersion aus internal/gen/cpp.go fehlgeschlagen?)." >&2
  exit 2
fi
raw="$(fetch_ubuntu_tags)" || raw=""
latest="$(printf '%s' "$raw" | extract_latest_lts)"
exec env COMPONENT_ADVICE="$ADVICE" bash "$GENERIC" --compare "$NAME" "$pinned" "$latest"
