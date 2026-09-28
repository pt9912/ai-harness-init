#!/usr/bin/env bats
# pre-commit-amend-guard.bats — Zaehne fuer den git-eigenen Traeger gegen
# fremde Index-Eintraege in `git commit --amend`
# (harness/tools/pre-commit-amend-guard.sh, .githooks/pre-commit,
# AGENTS.md §3.10, BEO-ALL/amend-committet-fremde-index-eintraege-mit).
#
# HERMETISCH: getestet werden ausschliesslich die REINEN Funktionen
# `has_amend_flag()` (ueber `--decide-amend`) und `decide()` (ueber
# `--decide`) mit Fixture-Werten. Das gepinnte bats-Image fuehrt kein `git`
# (s. harness/tools/slice-mv.sh Kopf, Abschnitt ZUSAGE) — der volle Lauf
# (PPID-Kommandozeile lesen, `git diff-tree`/`git diff --cached` gegen ein
# echtes Repo) ist darum hier NICHT nachstellbar. Das reale Rot-vor/Gruen-nach
# fuer alle drei Belege der Beobachtung steht als BELEG im Kopf von
# harness/tools/pre-commit-amend-guard.sh und wurde bei der Implementierung
# an einem konstruierten Repo gefahren (dieselbe Grenze wie bei
# test/history-range-guard.bats).

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  GUARD="$REPO/harness/tools/pre-commit-amend-guard.sh"
}

# ---------- has_amend_flag() ----------

@test "has_amend_flag: Kommandozeile ohne --amend -> 0" {
  run bash "$GUARD" --decide-amend "$(printf 'git\ncommit\n-m\nfoo\n')"
  [ "$status" -eq 0 ]
  [ "$output" = "0" ]
}

@test "has_amend_flag: Kommandozeile mit --amend -> 1" {
  run bash "$GUARD" --decide-amend "$(printf 'git\ncommit\n--amend\n-m\nfoo\n')"
  [ "$status" -eq 0 ]
  [ "$output" = "1" ]
}

@test "has_amend_flag: --amend als Teilstring eines anderen Tokens zaehlt nicht" {
  run bash "$GUARD" --decide-amend "$(printf 'git\ncommit\n--amend-something\n')"
  [ "$status" -eq 0 ]
  [ "$output" = "0" ]
}

@test "has_amend_flag: leere Kommandozeile -> 0" {
  run bash "$GUARD" --decide-amend ""
  [ "$status" -eq 0 ]
  [ "$output" = "0" ]
}

# ---------- decide() ----------

@test "decide: keine fremden Pfade -> exit 0, keine Ausgabe" {
  run bash "$GUARD" --decide "" ""
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "decide: ein fremder Pfad, keine Bestaetigung -> exit 1, Pfad genannt" {
  run bash "$GUARD" --decide "$(printf 'fremd.txt\n')" ""
  [ "$status" -eq 1 ]
  [[ "$output" == *"nimmt Pfade mit, die im urspruenglichen Commit HEAD nicht standen"* ]]
  [[ "$output" == *"fremd.txt"* ]]
  [[ "$output" == *"BEO-ALL/amend-committet-fremde-index-eintraege-mit"* ]]
  [[ "$output" == *"AMEND_EXPECTED_PATHS"* ]]
}

@test "decide: fremder Pfad, per AMEND_EXPECTED_PATHS bestaetigt -> exit 0" {
  run bash "$GUARD" --decide "$(printf 'fremd.txt\n')" "fremd.txt"
  [ "$status" -eq 0 ]
  [[ "$output" == *"bestaetigt"* ]]
}

@test "decide: zwei fremde Pfade, nur einer bestaetigt -> exit 1 (fail-closed)" {
  run bash "$GUARD" --decide "$(printf 'a.txt\nb.txt\n')" "a.txt"
  [ "$status" -eq 1 ]
  [[ "$output" == *"a.txt"* ]]
  [[ "$output" == *"b.txt"* ]]
}

@test "decide: zwei fremde Pfade, beide einzeln in AMEND_EXPECTED_PATHS -> exit 0" {
  run bash "$GUARD" --decide "$(printf 'a.txt\nb.txt\n')" "a.txt b.txt"
  [ "$status" -eq 0 ]
}

@test "decide: AMEND_EXPECTED_PATHS mit einem fremden, nicht betroffenen Pfad haelt trotzdem an (kein Blankoscheck)" {
  run bash "$GUARD" --decide "$(printf 'a.txt\nb.txt\n')" "a.txt c.txt"
  [ "$status" -eq 1 ]
  [[ "$output" == *"b.txt"* ]]
}
