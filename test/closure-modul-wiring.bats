#!/usr/bin/env bats
# closure-modul-wiring.bats — haelt die zweite Faehigkeit des d-check-Moduls `planning`
# (`closure`, DC-FA-PLAN-001) auf ihre Config-Entscheidung gebunden: aktiviert ueber `dir`,
# Kandidaten-Filter bleibt der Modul-Default `slice-glob` (kein eigenes `glob:`), `placeholder`
# bleibt aus. `docs-check` selbst faellt fail-closed, wenn eine `done/`-Datei unter `slice-glob`
# eine zu duenne oder fehlende Closure-Notiz traegt (Grund-Codes
# closure-note-missing/-thin/-ambiguous) — dieser Waechter haelt die Kopplung an die getroffene
# Filter- und Bedingungs-Entscheidung ohne einen Docker-Lauf. Was die Faehigkeit deckt, was sie
# absichtlich ausserhalb laesst (die Welle-Ebene) und der reale Docker-Beleg (Kontrolle:
# gekuerztes Abschnitt 7 faerbt rot) stehen in harness/README.md.
#
# NETZLOS (nur Datei-Lesen), laeuft in `make gates` ueber `make test` -> `test-bats`.

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  YML="$REPO/.d-check.yml"
}

# planning_block gibt die Zeilen des TOP-LEVEL-planning:-Blocks aus (Schluessel in Spalte 0) —
# dieselbe Extraktionsform wie test/planning-modul-wiring.bats.
planning_block() {
  awk '
    /^planning:[[:space:]]*$/ { inblk = 1; next }
    inblk && /^[^[:space:]]/   { inblk = 0 }
    inblk                      { print }
  ' "$YML"
}

# closure_block gibt die Zeilen des `closure:`-Unterblocks aus (Schluessel bei genau zwei
# Einrueckungs-Ebenen, vier Leerzeichen) — eine Ebene tiefer als planning_block.
closure_block() {
  planning_block | awk '
    /^  closure:[[:space:]]*$/ { inblk = 1; next }
    inblk && /^  [^[:space:]]/  { inblk = 0 }
    inblk                       { print }
  '
}

# closure_field liest den Wert eines Skalar-Feldes im closure:-Block, Anfuehrungszeichen entfernt.
closure_field() {
  closure_block | grep -E "^[[:space:]]+$1:" | head -1 \
    | sed -E "s/^[[:space:]]+$1:[[:space:]]*//" \
    | sed -E 's/^"(.*)"$/\1/'
}

@test "planning: closure ist ueber dir aktiviert" {
  content="$(closure_block)"
  [ -n "$content" ] || {
    echo "closure:-Block ist leer oder fehlt" >&2
    false
  }
}

@test "planning: closure.dir zeigt auf docs/plan/planning/done" {
  [ "$(closure_field dir)" = "docs/plan/planning/done" ]
}

@test "der konfigurierte closure.dir existiert als Verzeichnis" {
  local d
  d="$(closure_field dir)"
  [ -n "$d" ] || {
    echo "closure.dir ist leer — die Existenz-Pruefung liefe ins Leere" >&2
    false
  }
  [ -d "$REPO/$d" ]
}

@test "planning: closure setzt kein eigenes glob (Filter bleibt der Modul-Default slice-glob)" {
  ! printf '%s\n' "$(closure_block)" | grep -qE '^[[:space:]]+glob:'
}

@test "planning: closure.placeholder bleibt aus (kein escapter Vorlagen-Fund als Befund)" {
  ! printf '%s\n' "$(closure_block)" | grep -qE '^[[:space:]]+placeholder:[[:space:]]*true'
}

@test "planning: closure.boilerplate bleibt unbesetzt (keine deklarierte Floskel)" {
  ! printf '%s\n' "$(closure_block)" | grep -qE '^[[:space:]]+boilerplate:'
}
