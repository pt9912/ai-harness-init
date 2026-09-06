#!/usr/bin/env bats
# planning-modul-wiring.bats — haelt das d-check-Modul `planning` (DC-FA-PLAN-001) aktiv und auf
# den Abschnitt "## Offene Wellen" der Roadmap gebunden. `docs-check` selbst faellt fail-closed,
# wenn `heading` auf eine im Dokument fehlende Ueberschrift zeigt (Grund-Code planning-drift) —
# dieser Waechter haelt dieselbe Kopplung ohne einen Docker-Lauf. Eine Ueberschrift, die zwar
# existiert, aber nie den Ruhe-Marker traegt und die Invariante darum trivial machen wuerde, bleibt
# fuer `docs-check` unsichtbar; dieser Waechter faengt sie ueber den exakten heading-Wert ab
# (Zusicherung unten, gepinnt von test/mutations/272-planning-heading-auf-marker-lose-sektion.sh).
# Was das Modul damit deckt und was nicht (die `waves`-Faehigkeit bleibt aus), steht in
# harness/README.md.
#
# NETZLOS (nur Datei-Lesen), laeuft in `make gates` ueber `make test` -> `test-bats`.

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  YML="$REPO/.d-check.yml"
  ROADMAP="$REPO/docs/plan/planning/in-progress/roadmap.md"
}

# block gibt die Zeilen des TOP-LEVEL-planning:-Blocks aus (Schluessel in Spalte 0) — dieselbe
# Extraktions-Form wie in test/ignore-refs-restbreite.bats.
block() {
  awk '
    /^planning:[[:space:]]*$/ { inblk = 1; next }
    inblk && /^[^[:space:]]/   { inblk = 0 }
    inblk                      { print }
  ' "$YML"
}

# field liest den Wert eines Skalar-Feldes im planning:-Block, Anfuehrungszeichen entfernt.
field() {
  block | grep -E "^[[:space:]]+$1:" | head -1 \
    | sed -E "s/^[[:space:]]+$1:[[:space:]]*//" \
    | sed -E 's/^"(.*)"$/\1/'
}

@test "planning ist in modules: aktiviert" {
  grep -E '^modules:.*\bplanning\b' "$YML"
}

@test "planning: roadmap zeigt auf docs/plan/planning/in-progress/roadmap.md" {
  [ "$(field roadmap)" = "docs/plan/planning/in-progress/roadmap.md" ]
}

@test "planning: heading zeigt auf den Abschnitt 'Offene Wellen', nicht auf den Modul-Default" {
  [ "$(field heading)" = "## Offene Wellen" ]
}

@test "planning: marker traegt den Ruhe-Marker dieses Repos, nicht den Modul-Default" {
  [ "$(field marker)" = "Nichts in Arbeit." ]
}

@test "der konfigurierte heading existiert wortgleich als Abschnitt in der Roadmap" {
  grep -qxF "$(field heading)" "$ROADMAP"
}

@test "planning: waves bleibt aus (Entscheidung dokumentiert in harness/README.md)" {
  content="$(block)"
  # Ein leerer planning:-Block macht die Negation darunter ueber der leeren Menge wahr, ohne
  # dass die Faehigkeit gemessen wurde; diese Pruefung faengt genau diesen Fall vor der
  # Negation ab.
  [ -n "$content" ] || {
    echo "planning:-Block ist leer — die Zusicherung liefe ins Leere" >&2
    false
  }
  ! printf '%s\n' "$content" | grep -qE '^[[:space:]]+waves:'
}
