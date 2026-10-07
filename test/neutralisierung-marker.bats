#!/usr/bin/env bats
# neutralisierung-marker.bats — LH-FA-02: jede Wortlaut-Neutralisierung in
# internal/emit/templates.go trifft ihren Marker in der Vorlage des gepinnten Kurs-Stands
# so oft, wie ERWARTUNG unten nennt.
#
# Gelesen wird die reale Quelle, nicht die Fixture: die Neutralisierungen stehen in der
# Tabelle WortlautNeutralisierungen in templates.go (je Zeile Vorlage- und Marker-Konstante),
# der Pin als DefaultTag in internal/fetch/baseline.go, die Vorlage im vendored Baum
# .harness/baseline/<DefaultTag>/templates/. Der Fall steht in bats und nicht in go test,
# weil .dockerignore .harness aus dem Build-Kontext der Go-Stufe nimmt.
#
# Dass jede Ersetzung in templates.go ueber diese Tabelle laeuft und dass jede Zeile die
# Form hat, die setup() liest (einzeilig, Vorlage und Alt als Bezeichner einzeiliger
# `const X = "…"`), haelt TestWortlautNeutralisierungen_EineTabelle (go/ast).
#
# Zusage: je Tabellen-Zeile die Trefferzahl aus ERWARTUNG — 1 heisst, die Ersetzung wirkt
# am Pin; 0 heisst, sie gilt aelteren Kurs-Staenden (COURSE_TAG) und ist am Pin ein No-op.
# Zweite Zusage: ERWARTUNG und Tabelle nennen dieselben Marker, in beide Richtungen.

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  SRC="$REPO/internal/emit/templates.go"
  TAG="$(sed -n 's/^const DefaultTag = "\(.*\)"$/\1/p' "$REPO/internal/fetch/baseline.go")"
  TREE="$REPO/.harness/baseline/$TAG/templates"
  # Marker-Konstante:Vorlage-Konstante je Zeile der Go-Tabelle.
  TABELLE="$(sed -n 's/^\t*{Vorlage: \([A-Za-z0-9_]*\), Alt: \([A-Za-z0-9_]*\), Neu: .*},$/\2:\1/p' "$SRC")"
  # Marker-Konstante:erwartete Treffer in ihrer Vorlage am gepinnten Stand.
  ERWARTUNG="carveoutsDoneRefOld:1
conventionsPathRefOld:1
roadmapDoneLink:0"
}

# go_const <name> — Wert einer einzeiligen Go-String-Konstante aus templates.go, mit `\n`
# als Zeilenumbruch.
go_const() {
  local v
  v="$(sed -n "s/^const $1 = \"\(.*\)\"\$/\1/p" "$SRC")"
  printf '%s' "${v//\\n/$'\n'}"
}

# treffer <nadel> <datei> — Anzahl der Vorkommen, auch ueber Zeilengrenzen.
treffer() {
  local rest n=0
  rest="$(cat "$2")"
  while [[ $rest == *"$1"* ]]; do
    rest="${rest#*"$1"}"
    n=$((n + 1))
  done
  printf '%s' "$n"
}

@test "der gepinnte Kurs-Stand liegt vendored vor (Vorbedingung, LH-FA-02)" {
  [ -n "$TAG" ]
  [ -d "$TREE" ]
  [ -n "$TABELLE" ]
}

@test "jeder Wortlaut-Marker trifft seine Vorlage am gepinnten Stand so oft wie erwartet (LH-FA-02)" {
  fehler=""
  while IFS=: read -r marker vorlage; do
    soll="$(sed -n "s/^$marker:\([0-9]*\)$/\1/p" <<<"$ERWARTUNG")"
    nadel="$(go_const "$marker")"
    rel="$(go_const "$vorlage")"
    if [ -z "$nadel" ] || [ -z "$rel" ]; then
      fehler+="$marker/$vorlage: keine einzeilige Go-String-Konstante in templates.go"$'\n'
      continue
    fi
    if [ ! -f "$TREE/$rel" ]; then
      fehler+="$marker: Vorlage $rel fehlt im vendored Baum ($TAG)"$'\n'
      continue
    fi
    n="$(treffer "$nadel" "$TREE/$rel")"
    [ "$n" = "$soll" ] || fehler+="$marker: $n Treffer in $rel ($TAG) — erwartet ${soll:-?}"$'\n'
  done <<<"$TABELLE"
  if [ -n "$fehler" ]; then
    printf '%s' "$fehler"
    false
  fi
}

@test "Erwartung und Tabelle WortlautNeutralisierungen nennen dieselben Marker (LH-FA-02)" {
  ist="$(cut -d: -f1 <<<"$TABELLE" | sort -u)"
  soll="$(cut -d: -f1 <<<"$ERWARTUNG" | sort -u)"
  if [ "$ist" != "$soll" ]; then
    printf 'Tabelle:   %s\nErwartung: %s\n' "$(tr '\n' ' ' <<<"$ist")" "$(tr '\n' ' ' <<<"$soll")"
    false
  fi
}
