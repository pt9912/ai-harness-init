#!/usr/bin/env bats
# register-ausgang.bats — Wirkungs-Tests fuer harness/tools/register-ausgang.sh
# (docs/plan/planning/observations/README.md, ADR-0069). Docker-only im gepinnten bats-Image.
#
# Die Faelle bauen je ein Register in $BATS_TEST_TMPDIR; der reale Bestand ist der Lauf von
# `make register-ausgang`, nicht dieser Test — er bewegt sich mit jeder Closure.

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  SENSOR="$REPO/harness/tools/register-ausgang.sh"
  R="$BATS_TEST_TMPDIR/observations"
  mkdir -p "$R"
}

# eintrag <slug> <stand-zeile> <zahl der evidence/*.md>
eintrag() {
  local d="$R/BEO-ALL/$1"
  mkdir -p "$d/evidence"
  printf '# %s\n' "$1" >"$d/observation.md"
  printf '%s\n' "$2" >"$d/state.md"
  local i
  for ((i = 1; i <= $3; i++)); do printf 'x\n' >"$d/evidence/slice-v$i.md"; done
}

@test "register-ausgang: offen ueber der Schwelle -> exit 1, Meldung nennt Eintrag, Zahl und Stand" {
  eintrag ueber-ohne-ausgang '**Stand:** offen' 3
  run bash "$SENSOR" "$R"
  [ "$status" -eq 1 ]
  [[ "$output" == *"BEO-ALL/ueber-ohne-ausgang: 3 Belege (evidence/*.md), Stand 'offen' — ueber der 3x-Schwelle ohne Ausgang"* ]]
  [[ "$output" == *"1 ueber der Schwelle, 1 Befund(e)"* ]]
}

@test "register-ausgang: offen unter der Schwelle -> exit 0" {
  eintrag unter '**Stand:** offen' 2
  run bash "$SENSOR" "$R"
  [ "$status" -eq 0 ]
  [[ "$output" == *"1 Eintraege, 0 ueber der Schwelle, 0 Befund(e)"* ]]
}

@test "register-ausgang: die drei Ausgaenge ueber der Schwelle -> exit 0, auch mit Rumpf nach dem Wort" {
  eintrag a '**Stand:** verkörpert — Zielort `AGENTS.md` §3.6' 3
  eintrag b '**Stand:** geplant — slice-x' 4
  eintrag c '**Stand:** gestrichen. Grund: die Ursache entfaellt' 5
  run bash "$SENSOR" "$R"
  [ "$status" -eq 0 ]
  [[ "$output" == *"3 ueber der Schwelle, 0 Befund(e)"* ]]
}

@test "register-ausgang: gezaehlt werden Dateien evidence/*.md, kein Nicht-.md und kein Unterverzeichnis" {
  eintrag zwei-md '**Stand:** offen' 2
  printf 'x\n' >"$R/BEO-ALL/zwei-md/evidence/.gitkeep"
  mkdir -p "$R/BEO-ALL/zwei-md/evidence/slice-dir.md"
  run bash "$SENSOR" "$R"
  [ "$status" -eq 0 ]
  [[ "$output" == *"0 ueber der Schwelle"* ]]
}

@test "register-ausgang: das erste Wort entscheidet — 'offen' mit Ausgangs-Wort im Rumpf bleibt Befund" {
  eintrag rumpf '**Stand:** offen — verkörpert wird es spaeter' 3
  run bash "$SENSOR" "$R"
  [ "$status" -eq 1 ]
  [[ "$output" == *"BEO-ALL/rumpf: 3 Belege"*"Stand 'offen'"* ]]
}

@test "register-ausgang: fehlende Stand-Zeile und fehlende state.md ueber der Schwelle -> Befund" {
  eintrag ohne-zeile 'Stand: verkörpert' 3
  eintrag ohne-datei '**Stand:** geplant' 3
  rm "$R/BEO-ALL/ohne-datei/state.md"
  run bash "$SENSOR" "$R"
  [ "$status" -eq 1 ]
  [[ "$output" == *"BEO-ALL/ohne-zeile: 3 Belege (evidence/*.md), Stand '<keine Stand-Zeile>'"* ]]
  [[ "$output" == *"BEO-ALL/ohne-datei: 3 Belege (evidence/*.md), state.md fehlt"* ]]
  [[ "$output" == *"2 Befund(e)"* ]]
}

@test "register-ausgang: mehr als eine Stand-Zeile ueber der Schwelle -> Befund, auch wenn die erste einen Ausgang nennt" {
  eintrag doppelt '**Stand:** verkörpert — zitiert' 3
  printf '**Stand:** offen\n' >>"$R/BEO-ALL/doppelt/state.md"
  run bash "$SENSOR" "$R"
  [ "$status" -eq 1 ]
  [[ "$output" == *"BEO-ALL/doppelt: 3 Belege (evidence/*.md), 2 Zeilen '**Stand:**' in state.md — Stand nicht eindeutig"* ]]
}

@test "register-ausgang: Wurzel ohne Eintrag unter BEO-*/*/ -> exit 2, kein Gruen ueber leerem Pruefbereich" {
  mkdir -p "$R/beo-all/x/evidence"
  printf '**Stand:** offen\n' >"$R/beo-all/x/state.md"
  run bash "$SENSOR" "$R"
  [ "$status" -eq 2 ]
  [[ "$output" == *"kein Eintrag unter '$R/BEO-*/*/' — leerer Pruefbereich, nichts geprueft"* ]]
}

@test "register-ausgang: Wurzel fehlt -> exit 2" {
  run bash "$SENSOR" "$BATS_TEST_TMPDIR/gibt-es-nicht"
  [ "$status" -eq 2 ]
  [[ "$output" == *"nichts geprueft"* ]]
}
