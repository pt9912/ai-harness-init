#!/usr/bin/env bats
# neutralisierung-marker.bats — LH-FA-02: jede Wortlaut-Neutralisierung in
# internal/emit/templates.go trifft ihren Marker in der Vorlage des gepinnten Kurs-Stands.
#
# Gelesen wird die reale Quelle, nicht die Fixture: der Marker-Wert steht als Go-Konstante
# in templates.go, der Pin als DefaultTag in internal/fetch/baseline.go, die Vorlage im
# vendored Baum .harness/baseline/<DefaultTag>/templates/. Der Fall steht in bats und nicht
# in go test, weil .dockerignore .harness aus dem Build-Kontext der Go-Stufe nimmt.
#
# Zusage: je Marker genau ein Treffer in seiner Vorlage. Ein Marker, den der Kurs-Stand
# nicht (mehr) traegt, macht strings.ReplaceAll zum stillen No-op — dieser Fall wird rot.
# Zweite Zusage: die Tabelle unten nennt jede String-Konstante (`const <name> = "…"`), die
# templates.go als Such-Argument an strings.ReplaceAll(s, <konstante>, …) gibt; eine neue
# Wortlaut-Neutralisierung ohne Tabellen-Zeile wird ebenfalls rot.
# Grenze: eine Neutralisierung, deren Marker kein benannter Bezeichner ist (ein
# String-Literal direkt im Aufruf), sieht die Vollstaendigkeits-Pruefung nicht.

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  SRC="$REPO/internal/emit/templates.go"
  TAG="$(sed -n 's/^const DefaultTag = "\(.*\)"$/\1/p' "$REPO/internal/fetch/baseline.go")"
  TREE="$REPO/.harness/baseline/$TAG/templates"
  # Marker-Konstante -> Konstante, die den Quell-Relpfad ihrer Vorlage traegt.
  MARKER_TABELLE="conventionsPathRefOld:conventionsTemplate
carveoutsDoneRefOld:planningReadmeTemplate"
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
}

@test "jeder Wortlaut-Marker trifft seine Vorlage am gepinnten Stand genau einmal (LH-FA-02)" {
  fehler=""
  while IFS=: read -r marker vorlage; do
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
    [ "$n" = 1 ] || fehler+="$marker: $n Treffer in $rel ($TAG) — erwartet genau 1"$'\n'
  done <<<"$MARKER_TABELLE"
  if [ -n "$fehler" ]; then
    printf '%s' "$fehler"
    false
  fi
}

@test "die Marker-Tabelle nennt jede Konstante, die templates.go an strings.ReplaceAll gibt (LH-FA-02)" {
  ist=""
  for id in $(grep -oE 'strings\.ReplaceAll\(s, [A-Za-z_][A-Za-z0-9_]*,' "$SRC" \
    | sed -E 's/.*\(s, ([A-Za-z0-9_]+),/\1/' | sort -u); do
    grep -qE "^const $id = \"" "$SRC" && ist+="$id"$'\n'
  done
  ist="${ist%$'\n'}"
  [ -n "$ist" ]
  soll="$(cut -d: -f1 <<<"$MARKER_TABELLE" | sort -u)"
  if [ "$ist" != "$soll" ]; then
    printf 'templates.go: %s\nTabelle:      %s\n' "$(tr '\n' ' ' <<<"$ist")" "$(tr '\n' ' ' <<<"$soll")"
    false
  fi
}
