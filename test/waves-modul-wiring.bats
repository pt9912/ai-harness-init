#!/usr/bin/env bats
# waves-modul-wiring.bats — haelt die dritte Faehigkeit des d-check-Moduls `planning`
# (`waves`, DC-FA-PLAN-001) auf ihre Config-Entscheidung gebunden: aktiviert ueber `dir`,
# `mode: many` haelt die Bijektion Zeiger <-> flache Welle-Dateien in beiden Richtungen (Default
# waere `one`, ein Singleton-Praedikat). `docs-check` selbst faellt fail-closed, wenn ein
# flaches Wellendokument ohne Zeiger unter "## Offene Wellen" steht oder umgekehrt (Grund-Code
# wave-drift), sowie bei einer entsprechenden Abweichung zwischen "## Abgeschlossene Wellen" und
# den Ergebnisnotizen im Ruheort (wave-unregistered/wave-results-missing) — dieser Waechter haelt
# die Kopplung an die getroffene Config-Entscheidung ohne einen Docker-Lauf. Was die Faehigkeit
# darueber hinaus deckt (auch Spalte 1 der Vorschau-Tabelle "## Naechste Wellen", Grund-Code
# wave-preview-exists), was ausserhalb ihres Zugriffs bleibt und der reale Docker-Beleg stehen in
# harness/sensors/docs-check.md.
#
# NETZLOS (nur Datei-Lesen), laeuft in `make gates` ueber `make test` -> `test-bats`.

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  YML="$REPO/.d-check.yml"
}

# planning_block gibt die Zeilen des TOP-LEVEL-planning:-Blocks aus (Schluessel in Spalte 0) —
# dieselbe Extraktionsform wie test/planning-modul-wiring.bats und test/closure-modul-wiring.bats.
planning_block() {
  awk '
    /^planning:[[:space:]]*$/ { inblk = 1; next }
    inblk && /^[^[:space:]]/   { inblk = 0 }
    inblk                      { print }
  ' "$YML"
}

# waves_block gibt die Zeilen des `waves:`-Unterblocks aus (Schluessel bei genau zwei
# Einrueckungs-Ebenen, vier Leerzeichen) — eine Ebene tiefer als planning_block, dieselbe Form
# wie closure_block in test/closure-modul-wiring.bats.
waves_block() {
  planning_block | awk '
    /^  waves:[[:space:]]*$/  { inblk = 1; next }
    inblk && /^  [^[:space:]]/ { inblk = 0 }
    inblk                      { print }
  '
}

# waves_field liest den Wert eines Skalar-Feldes im waves:-Block, Anfuehrungszeichen entfernt.
waves_field() {
  waves_block | grep -E "^[[:space:]]+$1:" | head -1 \
    | sed -E "s/^[[:space:]]+$1:[[:space:]]*//" \
    | sed -E 's/^"(.*)"$/\1/'
}

@test "planning: waves ist ueber dir aktiviert" {
  content="$(waves_block)"
  [ -n "$content" ] || {
    echo "waves:-Block ist leer oder fehlt — die Faehigkeit bliebe inert" >&2
    false
  }
}

@test "planning: waves.dir zeigt auf docs/plan/planning" {
  [ "$(waves_field dir)" = "docs/plan/planning" ]
}

@test "der konfigurierte waves.dir existiert als Verzeichnis" {
  local d
  d="$(waves_field dir)"
  [ -n "$d" ] || {
    echo "waves.dir ist leer — die Existenz-Pruefung liefe ins Leere" >&2
    false
  }
  [ -d "$REPO/$d" ]
}

@test "planning: waves.mode ist many (Bijektion statt Singleton-Default)" {
  [ "$(waves_field mode)" = "many" ]
}
