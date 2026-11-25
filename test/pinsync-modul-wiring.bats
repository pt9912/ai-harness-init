#!/usr/bin/env bats
# pinsync-modul-wiring.bats — haelt das d-check-Modul `pinsync` an seine Config-Entscheidung
# gebunden: genau ein Pin (`d-check`), zwei Quellen (`d-check.mk` ueber `DCHECK_IMAGE ?=`,
# `internal/emit/emit.go` ueber `DefaultImage`), je Quelle ein Ausdruck mit GENAU EINER
# Fanggruppe; verglichen wird byte-genau die Tag-Referenz. Der Verhaltens-Zahn — `docs-check`
# faerbt einen verfaelschten Pin-Wert an genau einer Quelle mit dem Grund-Code
# `pinsync-mismatch` rot — ist am realen Bestand gemessen (Mutations-Fall unter `test/mutations/`,
# Beleg in harness/sensors/docs-check.md §Grenze, Modul pinsync); dieser Wächter hält die
# Config-Entscheidung ohne Docker-Lauf.
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
