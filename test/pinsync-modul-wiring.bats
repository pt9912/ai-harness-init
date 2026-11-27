#!/usr/bin/env bats
# pinsync-modul-wiring.bats — haelt das d-check-Modul `pinsync` an seine Config-Entscheidung
# gebunden: zwei Pins — der d-check-Werkzeug-Pin (`d-check.mk` ueber `DCHECK_IMAGE ?=`,
# `internal/emit/emit.go` ueber `DefaultImage`) und, seit
# slice-environment-check-fuehrt-die-gates, das Pin `go` (Inventar-Soll-Zeile
# `abgeleitet:<wert>` in harness/tools/environment-inventory.txt gegen die
# `GO_VERSION ?=`-Stelle des Makefile) — je Quelle ein Ausdruck mit GENAU EINER
# Fanggruppe; verglichen wird byte-genau. Der Verhaltens-Zahn — `docs-check`
# faerbt einen verfaelschten Pin-Wert an genau einer Quelle mit dem Grund-Code
# `pinsync-mismatch` rot — ist am realen Bestand gemessen (Mutations-Faelle unter
# `test/mutations/`, Beleg in harness/sensors/docs-check.md §Grenze, Modul pinsync);
# dieser Wächter hält die Config-Entscheidung ohne Docker-Lauf.
#
# NETZLOS (nur Datei-Lesen), laeuft in `make gates` ueber `make test` -> `test-bats`.

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  YML="$REPO/.d-check.yml"
}

pinsync_block() {
  awk '
    /^pinsync:[[:space:]]*$/  { inblk = 1; next }
    inblk && /^[^[:space:]]/  { inblk = 0 }
    inblk                     { print }
  ' "$YML"
}

@test "pinsync steht in der Modul-Liste" {
  grep -qE '^modules: \[[^]]*pinsync' "$YML"
}

@test "pinsync: genau ein Pin namens d-check" {
  local block pin
  block="$(pinsync_block)"
  [ -n "$block" ] || {
    echo "pinsync:-Block ist leer oder fehlt — das Modul liefe leer oder inert" >&2
    false
  }
  pin="$(grep -c '^    - name: d-check$' <<<"$block")"
  [ "$pin" -eq 1 ]
}

@test "pinsync: das Pin d-check paart d-check.mk ueber DCHECK_IMAGE und internal/emit/emit.go ueber DefaultImage" {
  local block
  block="$(pinsync_block)"
  grep -qF '^DCHECK_IMAGE \?= (ghcr\.io/pt9912/d-check:v[0-9]+\.[0-9]+\.[0-9]+)$' <<<"$block"
  grep -qF 'DefaultImage\s*=\s*"(ghcr\.io/pt9912/d-check:v[0-9]+\.[0-9]+\.[0-9]+)"' <<<"$block"
  grep -qF '{file: d-check.mk,' <<<"$block"
  grep -qF '{file: internal/emit/emit.go,' <<<"$block"
}

@test "pinsync: das Pin go paart die Inventar-Soll-Zeile abgeleitet gegen die GO_VERSION-Stelle des Makefile" {
  local block
  block="$(pinsync_block)"
  grep -qF '^GO_VERSION \?= ([0-9]+\.[0-9]+\.[0-9]+)$' <<<"$block"
  grep -qF '^go\|exakt\|pflicht\|abgeleitet:([0-9]+\.[0-9]+\.[0-9]+)\|' <<<"$block"
  grep -qF '{file: Makefile,' <<<"$block"
  grep -qF '{file: harness/tools/environment-inventory.txt,' <<<"$block"
  local wert Quelle
  # GNU-portable Lesung (seit slice-labor-gates-host-rezepte): die vormals
  # geformte Lesung 'GO_VERSION \?= ' liest GNU-sed als BRE-QUANTIFIKATOR
  # (\? = optional) — am gepinnten BusyBox-bats-Image las es literal '?'. Der
  # byte-gleiche Vergleich misst den Wert, nicht die sed-Dialekt-Form.
  wert="$(grep -oE '^GO_VERSION \?= [0-9]+\.[0-9]+\.[0-9]+' "$REPO/Makefile" | sed 's/^GO_VERSION .= //')"
  Quelle="$(grep -E '^go\|exakt\|pflicht\|abgeleitet:' "$REPO/harness/tools/environment-inventory.txt" | sed -E 's/^go\|exakt\|pflicht\|abgeleitet:([0-9]+\.[0-9]+\.[0-9]+)\|.*/\1/')"
  echo "Pin-Stelle Makefile: [$wert]; Inventar-Soll: [$Quelle] (Zusage: byte-gleich)"
  [ -n "$wert" ] && [ "$wert" = "$Quelle" ]
}

@test "pinsync: jeder pattern-Ausdruck traegt GENAU EINE Fanggruppe" {
  local block line
  block="$(pinsync_block | grep 'pattern:')"
  [ -n "$block" ] || {
    echo "keine pattern-Zeile im pinsync-Block — die Paarung haette keine Quelle" >&2
    false
  }
  while IFS= read -r line; do
    awk -v s="$line" 'BEGIN{ gsub(/\\[()]/, "", s); if (gsub(/\(/, "", s) != 1) { print "GENAU EINE Fanggruppe verlangt: " s; exit 1 } }' \
      || {
        false
      }
  done <<<"$block"
}

@test "pinsync: das Pin golangci-lint paart die Inventar-Soll-Zeile abgeleitet gegen die GOLANGCI_LINT_VERSION-Stellen" {
  local block wert quelle
  block="$(pinsync_block)"
  grep -qF '^GOLANGCI_LINT_VERSION \?= v(2\.[0-9]+\.[0-9]+)$' <<<"$block"
  grep -qF '^ARG GOLANGCI_LINT_VERSION=v(2\.[0-9]+\.[0-9]+)$' <<<"$block"
  grep -qF '^golangci-lint\|exakt\|pflicht\|abgeleitet:(2\.[0-9]+\.[0-9]+)\|' <<<"$block"
  grep -qF '{file: Makefile,' <<<"$block"
  grep -qF '{file: Dockerfile,' <<<"$block"
  grep -qF '{file: harness/tools/environment-inventory.txt,' <<<"$block"
  # byte-gleich über der gelebten Pin-Stelle: beide Quellen tragen v-Prefix, das
  # Inventar den Zahl-Wert — die Paarung liest die Fanggruppe (ohne v).
  wert="$(grep -oE '^GOLANGCI_LINT_VERSION \?= v2\.[0-9]+\.[0-9]+' "$REPO/Makefile" | sed 's/^GOLANGCI_LINT_VERSION .= v//')"
  quelle="$(grep -E '^golangci-lint\|exakt\|pflicht\|abgeleitet:' "$REPO/harness/tools/environment-inventory.txt" | sed -E 's/^golangci-lint\|exakt\|pflicht\|abgeleitet:(2\.[0-9]+\.[0-9]+)\|.*/\1/')"
  echo "Pin-Stelle Makefile: [$wert]; Inventar-Soll: [$quelle] (Zusage: byte-gleich)"
  [ -n "$wert" ] && [ "$wert" = "$quelle" ]
}
