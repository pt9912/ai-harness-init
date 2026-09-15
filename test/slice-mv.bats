#!/usr/bin/env bats
# slice-mv.bats — Zaehne fuer die Ersetzungs-Funktionen des Lifecycle-Werkzeugs.
#
# Der Selbsttest der Ersetzung laeuft OHNE ein Repo zu bewegen: er sourced das
# Skript (BASH_SOURCE-Waechter unterdrueckt main()/git mv) und ruft
# rewrite_incoming_in_file/rewrite_outgoing_bare_in_file direkt auf Proben —
# sonst misst der Selbsttest sich selbst statt der Ersetzung. Diese Datei fuehrt
# ALLE ihre Faelle so, ohne Ausnahme — die EINGEHEND-Ausnahmeliste
# (eingehend_ausgenommene_pfade) ist eine reine Funktion und darum
# bats-gedeckt; was main() daraus MACHT (Zwei-Commit-Sequenz, realer
# `git grep`-Aufruf) braucht ein echtes `git`-Repo und ist darum NICHT hier,
# sondern in harness/tools/full-smoke.sh belegt — dort an einem echten Move im
# gebootstrappten Ziel.
#
# ZWEI FASSUNGEN, EINE PRUEFUNG: dieselbe Ersetzungs-Logik liegt als
# ausgeführte Fassung dieses Repos (harness/tools/slice-mv.sh) und als
# Emissions-Vorlage (internal/emit/templates/enforce/slice-mv.sh) vor. Jeder
# Fall unten faehrt BEIDE: eine einseitige Aenderung liesse die eine Haelfte
# gruen und die andere still falsch werden. Die zwei unterscheiden sich in ihrer
# Verankerung — Repo-Pfade, Kommentare, die Ausnahmeliste als Konstante bzw. als
# setzbare Variable —, nicht in der Ersetzung.

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  DOGFOOD="$REPO/harness/tools/slice-mv.sh"
  EMITTIERT="$REPO/internal/emit/templates/enforce/slice-mv.sh"
  FASSUNGEN=("$DOGFOOD" "$EMITTIERT")
  TMP="$BATS_TEST_TMPDIR"
}

# Laedt die reinen Funktionen EINER Fassung in DIESE Shell (kein Subshell-Pipe —
# sonst verschwinden die Definitionen wieder, real beim ersten Entwurf erlebt).
load_functions() {  # $1=skript
  # shellcheck source=/dev/null
  source "$1"
}

@test "eingehend: die Wortgrenzen-Regel ersetzt jede Praefix-Tiefe und jeden Kontext (Stichprobe, keine feste Formenliste — Vollstaendigkeit gegen den Bestand misst make docs-check, nicht dieser Test)" {
  for fassung in "${FASSUNGEN[@]}"; do
  load_functions "$fassung"
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
  done
}

@test "eingehend: fremde Datei im selben Verzeichnis bleibt unberuehrt (Gegenprobe)" {
  for fassung in "${FASSUNGEN[@]}"; do
  load_functions "$fassung"
  printf '[b](../open/slice-998-y.md)\n' > "$TMP/probe.md"
  rewrite_incoming_in_file "$TMP/probe.md" "slice-999-x.md" "open" "ZIEL"
  grep -qF '../open/slice-998-y.md' "$TMP/probe.md"
  done
}

@test "eingehend: dieselbe Datei in einem ANDEREN Verzeichnis bleibt unberuehrt (Gegenprobe)" {
  for fassung in "${FASSUNGEN[@]}"; do
  load_functions "$fassung"
  printf '[c](../done/slice-999-x.md)\n' > "$TMP/probe.md"
  rewrite_incoming_in_file "$TMP/probe.md" "slice-999-x.md" "open" "ZIEL"
  grep -qF '../done/slice-999-x.md' "$TMP/probe.md"
  done
}

@test "eingehend: verklebtes Wort bleibt unberuehrt — Bindestrich zaehlt als Wortzeichen" {
  for fassung in "${FASSUNGEN[@]}"; do
  load_functions "$fassung"
  printf 'sibling-open/slice-999-x.md\n' > "$TMP/probe.md"
  rewrite_incoming_in_file "$TMP/probe.md" "slice-999-x.md" "open" "ZIEL"
  grep -qF 'sibling-open/slice-999-x.md' "$TMP/probe.md"
  done
}

@test "eingehend: Teilstring-Falle — Move von slice-13 aendert slice-130 NICHT (AGENTS 3.6, Slice-Plan §6)" {
  for fassung in "${FASSUNGEN[@]}"; do
  load_functions "$fassung"
  cat > "$TMP/probe.md" <<'EOF'
[a](../open/slice-13-x.md)
[b](../open/slice-130-y.md)
EOF
  rewrite_incoming_in_file "$TMP/probe.md" "slice-13-x.md" "open" "ZIEL"
  grep -qF '../ZIEL/slice-13-x.md' "$TMP/probe.md"
  grep -qF '../open/slice-130-y.md' "$TMP/probe.md"
  ! grep -q 'slice-130-y\.md' <(grep 'ZIEL' "$TMP/probe.md")
  done
}

@test "ausgehend: praefixloses Ziel zu einem verbliebenen Geschwister bekommt ../from/" {
  for fassung in "${FASSUNGEN[@]}"; do
  load_functions "$fassung"
  mkdir -p "$TMP/docs/plan/planning/open"
  : > "$TMP/docs/plan/planning/open/slice-998-sibling.md"
  cd "$TMP"
  printf '[a](slice-998-sibling.md)\n' > moved.md
  run rewrite_outgoing_bare_in_file moved.md open
  [ "$status" -eq 0 ]
  [ "$output" = "1" ]
  grep -qF '[a](../open/slice-998-sibling.md)' moved.md
  done
}

@test "ausgehend: benannte Slice-Kennung ohne Ziffern-Praefix bekommt ../from/ ebenso wie eine nummerierte" {
  for fassung in "${FASSUNGEN[@]}"; do
  load_functions "$fassung"
  mkdir -p "$TMP/docs/plan/planning/open"
  : > "$TMP/docs/plan/planning/open/slice-woertlich-benannt.md"
  cd "$TMP"
  printf '[a](slice-woertlich-benannt.md)\n' > moved.md
  run rewrite_outgoing_bare_in_file moved.md open
  [ "$status" -eq 0 ]
  [ "$output" = "1" ]
  grep -qF '[a](../open/slice-woertlich-benannt.md)' moved.md
  done
}

@test "ausgehend: zwei benannte Kennungen mit gemeinsamem Praefix bleiben getrennt (kein Teilstring-Uebergriff)" {
  for fassung in "${FASSUNGEN[@]}"; do
  load_functions "$fassung"
  mkdir -p "$TMP/docs/plan/planning/open"
  : > "$TMP/docs/plan/planning/open/slice-abc.md"
  : > "$TMP/docs/plan/planning/open/slice-abc-erweitert.md"
  cd "$TMP"
  cat > moved.md <<'EOF'
[a](slice-abc.md)
[b](slice-abc-erweitert.md)
EOF
  run rewrite_outgoing_bare_in_file moved.md open
  [ "$status" -eq 0 ]
  [ "$output" = "2" ]
  grep -qF '[a](../open/slice-abc.md)' moved.md
  grep -qF '[b](../open/slice-abc-erweitert.md)' moved.md
  done
}

@test "ausgehend: welle-Ziel bleibt unberuehrt (Grenze 2 — nur slice-Dateien)" {
  for fassung in "${FASSUNGEN[@]}"; do
  load_functions "$fassung"
  mkdir -p "$TMP/docs/plan/planning/open"
  : > "$TMP/docs/plan/planning/open/welle-01-x.md"
  cd "$TMP"
  printf '[a](welle-01-x.md)\n' > moved.md
  run rewrite_outgoing_bare_in_file moved.md open
  [ "$status" -eq 0 ]
  [ "$output" = "0" ]
  grep -qF '[a](welle-01-x.md)' moved.md
  done
}

@test "ausgehend: Ziel ohne existierende Datei bleibt unberuehrt (kein Rateversuch)" {
  for fassung in "${FASSUNGEN[@]}"; do
  load_functions "$fassung"
  mkdir -p "$TMP/docs/plan/planning/open"
  cd "$TMP"
  printf '[a](slice-nicht-vorhanden.md)\n' > moved.md
  run rewrite_outgoing_bare_in_file moved.md open
  [ "$status" -eq 0 ]
  [ "$output" = "0" ]
  grep -qF '[a](slice-nicht-vorhanden.md)' moved.md
  done
}

@test "eingehend_ausgenommene_pfade: .harness/baseline und docs/plan/adr drin, docs/reviews NICHT (ADR-0042 Festlegung 2, ADR-0033 Abnahme-Kriterium 1)" {
  for fassung in "${FASSUNGEN[@]}"; do
  load_functions "$fassung"
  run eingehend_ausgenommene_pfade
  [ "$status" -eq 0 ]
  printf '%s\n' "$output" | grep -qF ':!.harness/baseline'
  printf '%s\n' "$output" | grep -qF ':!docs/plan/adr'
  ! printf '%s\n' "$output" | grep -q 'docs/reviews'
  done
}

# Die LISTE selbst ist damit bats-gedeckt (oben). Was main() daraus MACHT — sie
# an `git grep` uebergeben, im Zwei-Commit-Ablauf, Zeitdokumente real
# nachziehen — braucht ein echtes `git`-Repo: main() ruft `git mv`/`git grep`,
# und das gepinnte BATS_IMAGE fuehrt kein `git`-Binary mit. Der Beleg dafuer
# steht darum NICHT hier, sondern an zwei anderen Orten: im Skriptkopf
# (harness/tools/slice-mv.sh) und, fuer BEIDE Richtungen an einem echten Move im
# gebootstrappten Ziel, in harness/tools/full-smoke.sh.
