#!/usr/bin/env bats
# slice-mv.bats — Zaehne fuer harness/tools/slice-mv.sh (slice-144).
#
# Der Selbsttest der Ersetzung laeuft OHNE ein Repo zu bewegen: er sourced das
# Skript (BASH_SOURCE-Waechter unterdrueckt main()/git mv) und ruft
# rewrite_incoming_in_file/rewrite_outgoing_bare_in_file direkt auf Proben —
# sonst misst der Selbsttest sich selbst statt der Ersetzung (Slice-Plan §6).
#
# EINE Ausnahme: "main() haelt sich an seine eigene Ausnahme-Liste" spannt eine
# echte, aber SYNTHETISCHE Fixture-Repo auf (git init in $BATS_TEST_TMPDIR) —
# das ist kein Repo im Sinne der obigen Regel (das PRODUKTIV-Repo dieses Slice
# selbst), sondern ein Wegwerf-Fixture fuer main()s Ausschluss-Pfadspec.

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  SCRIPT="$REPO/harness/tools/slice-mv.sh"
  TMP="$BATS_TEST_TMPDIR"
}

# Laedt die reinen Funktionen in DIESE Shell (kein Subshell-Pipe — sonst
# verschwinden die Definitionen wieder, real beim ersten Entwurf erlebt).
load_functions() {
  # shellcheck source=/dev/null
  source "$SCRIPT"
}

@test "eingehend: die Wortgrenzen-Regel ersetzt jede Praefix-Tiefe und jeden Kontext (Stichprobe, keine feste Formenliste — Vollstaendigkeit gegen den Bestand misst make docs-check, nicht dieser Test)" {
  load_functions
  cat > "$TMP/probe.md" <<'EOF'
../../docs/plan/planning/open/slice-999-x.md
../docs/plan/planning/open/slice-999-x.md
docs/plan/planning/open/slice-999-x.md
../open/slice-999-x.md
(open/slice-999-x.md)
`open/slice-999-x.md`
open/slice-999-x.md
../../planning/open/slice-999-x.md
../planning/open/slice-999-x.md
EOF
  rewrite_incoming_in_file "$TMP/probe.md" "slice-999-x.md" "open" "ZIEL"
  # Keine der neun Zeilen zeigt danach noch auf "open/" ...
  ! grep -q 'open/slice-999-x\.md' "$TMP/probe.md"
  # ... und jede zeigt jetzt auf "ZIEL/", in derselben Zeilenzahl (9).
  [ "$(grep -c 'ZIEL/slice-999-x\.md' "$TMP/probe.md")" -eq 9 ]
}

@test "eingehend: fremde Datei im selben Verzeichnis bleibt unberuehrt (Gegenprobe)" {
  load_functions
  printf '[b](../open/slice-998-y.md)\n' > "$TMP/probe.md"
  rewrite_incoming_in_file "$TMP/probe.md" "slice-999-x.md" "open" "ZIEL"
  grep -qF '../open/slice-998-y.md' "$TMP/probe.md"
}

@test "eingehend: dieselbe Datei in einem ANDEREN Verzeichnis bleibt unberuehrt (Gegenprobe)" {
  load_functions
  printf '[c](../done/slice-999-x.md)\n' > "$TMP/probe.md"
  rewrite_incoming_in_file "$TMP/probe.md" "slice-999-x.md" "open" "ZIEL"
  grep -qF '../done/slice-999-x.md' "$TMP/probe.md"
}

@test "eingehend: verklebtes Wort bleibt unberuehrt — Bindestrich zaehlt als Wortzeichen" {
  load_functions
  printf 'sibling-open/slice-999-x.md\n' > "$TMP/probe.md"
  rewrite_incoming_in_file "$TMP/probe.md" "slice-999-x.md" "open" "ZIEL"
  grep -qF 'sibling-open/slice-999-x.md' "$TMP/probe.md"
}

@test "eingehend: Teilstring-Falle — Move von slice-13 aendert slice-130 NICHT (AGENTS 3.6, Slice-Plan §6)" {
  load_functions
  cat > "$TMP/probe.md" <<'EOF'
[a](../open/slice-13-x.md)
[b](../open/slice-130-y.md)
EOF
  rewrite_incoming_in_file "$TMP/probe.md" "slice-13-x.md" "open" "ZIEL"
  grep -qF '../ZIEL/slice-13-x.md' "$TMP/probe.md"
  grep -qF '../open/slice-130-y.md' "$TMP/probe.md"
  ! grep -q 'slice-130-y\.md' <(grep 'ZIEL' "$TMP/probe.md")
}

@test "ausgehend: praefixloses Ziel zu einem verbliebenen Geschwister bekommt ../from/" {
  load_functions
  mkdir -p "$TMP/docs/plan/planning/open"
  : > "$TMP/docs/plan/planning/open/slice-998-sibling.md"
  cd "$TMP"
  printf '[a](slice-998-sibling.md)\n' > moved.md
  run rewrite_outgoing_bare_in_file moved.md open
  [ "$status" -eq 0 ]
  [ "$output" = "1" ]
  grep -qF '[a](../open/slice-998-sibling.md)' moved.md
}

@test "ausgehend: welle-Ziel bleibt unberuehrt (Grenze 2 — nur slice-Dateien)" {
  load_functions
  mkdir -p "$TMP/docs/plan/planning/open"
  : > "$TMP/docs/plan/planning/open/welle-01-x.md"
  cd "$TMP"
  printf '[a](welle-01-x.md)\n' > moved.md
  run rewrite_outgoing_bare_in_file moved.md open
  [ "$status" -eq 0 ]
  [ "$output" = "0" ]
  grep -qF '[a](welle-01-x.md)' moved.md
}

@test "ausgehend: Ziel ohne existierende Datei bleibt unberuehrt (kein Rateversuch)" {
  load_functions
  mkdir -p "$TMP/docs/plan/planning/open"
  cd "$TMP"
  printf '[a](slice-nicht-vorhanden.md)\n' > moved.md
  run rewrite_outgoing_bare_in_file moved.md open
  [ "$status" -eq 0 ]
  [ "$output" = "0" ]
  grep -qF '[a](slice-nicht-vorhanden.md)' moved.md
}

# main()s Ausschluss-Pfadspec selbst (.harness/baseline/** und docs/reviews/**
# eingefroren, docs/plan/planning/done/** NICHT) braeuchte fuer einen
# bats-Fall ein echtes `git`-Repo — main() ruft `git mv`/`git grep`, und das
# gepinnte BATS_IMAGE fuehrt kein `git`-Binary mit. Der Beleg dafuer ist darum
# einmalig im Bericht (AGENTS.md 3.6 "wo sie einmalig ist, in den Bericht"),
# nicht als bats-Fall.
