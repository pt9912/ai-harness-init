#!/usr/bin/env bats
# mutate-auswahl.bats — Waechter fuer harness/tools/mutate-auswahl.sh (LH-QA-03, MR-014):
# Fallauswahl ueber den Claim-Commit, Abbruch ohne ihn, Zuteilung auf Shards und die
# Schwelle zwischen lokalem Lauf und CI-Branch.
#
# Das bats-Image fuehrt weder `git` noch `make`. Beide stehen hier als Attrappen auf dem
# PATH: `git` antwortet auf `log` mit FAKE_CLAIM und auf `diff` mit dem Inhalt von
# FAKE_DIFF; `make -n full-smoke` liefert einen Plan, der in ein Skript abbiegt (serielle
# Spur), jeder andere Modus einen reinen `docker build`. Gemessen wird damit das Skript,
# nicht git; die Fall-Koepfe liegen in einem eigenen Verzeichnis (MUTATE_AUSWAHL_FAELLE).

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  TOOL="$REPO/harness/tools/mutate-auswahl.sh"
  BIN="$BATS_TEST_TMPDIR/bin"
  FAELLE="$BATS_TEST_TMPDIR/faelle"
  mkdir -p "$BIN" "$FAELLE"
  cat >"$BIN/git" <<'EOF'
#!/usr/bin/env bash
[ "$1" = "-C" ] && shift 2
case "$1" in
  log) [ -n "${FAKE_CLAIM:-}" ] && printf '%s\n' "$FAKE_CLAIM"; exit 0 ;;
  diff) cat "$FAKE_DIFF" ;;
  *) exit 1 ;;
esac
EOF
  cat >"$BIN/make" <<'EOF'
#!/usr/bin/env bash
mode="${*: -1}"
if [ "$mode" = "full-smoke" ]; then echo "bash harness/tools/full-smoke.sh"; else echo "docker build -t x ."; fi
EOF
  chmod +x "$BIN/git" "$BIN/make"
  export PATH="$BIN:$PATH"
  export MUTATE_AUSWAHL_FAELLE="$FAELLE"
  export FAKE_CLAIM="c1a1m"
  export FAKE_DIFF="$BATS_TEST_TMPDIR/diff"
  : >"$FAKE_DIFF"
}

# fall <name> <files> <modus>
fall() {
  printf '#!/usr/bin/env bash\n# files: %s\n# expect: x\n# verify: %s\n' "$2" "$3" >"$FAELLE/$1.sh"
}

@test "auswahl: ein Fall mit geaenderter files-Datei ist gewaehlt" {
  fall 01-a src/a.sh test-bats
  printf 'src/a.sh\n' >"$FAKE_DIFF"
  run bash "$TOOL" faelle slice-x
  [ "$status" -eq 0 ]
  [ "$output" = "01-a" ]
}

@test "auswahl: ein unberuehrter Fall ist nicht gewaehlt" {
  fall 01-a src/a.sh test-bats
  fall 02-b src/b.sh test-bats
  printf 'src/a.sh\n' >"$FAKE_DIFF"
  run bash "$TOOL" faelle slice-x
  [ "$status" -eq 0 ]
  [ "$output" = "01-a" ]
}

@test "auswahl: eine geaenderte Fall-Datei ist gewaehlt" {
  fall 01-a src/a.sh test-bats
  fall 02-b src/b.sh test-bats
  printf 'test/mutations/02-b.sh\n' >"$FAKE_DIFF"
  run bash "$TOOL" faelle slice-x
  [ "$status" -eq 0 ]
  [ "$output" = "02-b" ]
}

@test "auswahl: ein fehlender Claim-Commit bricht ab" {
  fall 01-a src/a.sh test-bats
  printf 'src/a.sh\n' >"$FAKE_DIFF"
  FAKE_CLAIM="" run bash "$TOOL" urteil slice-x
  [ "$status" -eq 2 ]
  [[ "$output" == *"ABBRUCH — kein Claim-Commit fuer slice-x"* ]]
}

@test "zuteilung: schwere Faelle liegen auf verschiedenen Shards" {
  local i s
  for i in 1 2 3; do fall "1$i-schwer" src/a.sh full-smoke; done
  for i in 1 2 3 4 5 6; do fall "2$i-leicht" src/a.sh test-bats; done
  printf 'src/a.sh\n' >"$FAKE_DIFF"
  for s in 0 1 2; do
    run bash "$TOOL" shard slice-x 3 "$s"
    [ "$status" -eq 0 ]
    [ "$(grep -o 'schwer' <<<"$output" | wc -l)" -eq 1 ]
  done
}

@test "zuteilung: leichte Faelle gehen auf den Shard mit der geringsten Last" {
  fall 11-schwer src/a.sh full-smoke
  fall 21-leicht src/a.sh test-bats
  fall 22-leicht src/a.sh test-bats
  fall 23-leicht src/a.sh test-bats
  printf 'src/a.sh\n' >"$FAKE_DIFF"
  run bash "$TOOL" shard slice-x 2 0
  [ "$status" -eq 0 ]
  [ "$output" = "11-schwer" ]
  run bash "$TOOL" shard slice-x 2 1
  [ "$output" = "21-leicht 22-leicht 23-leicht" ]
}

@test "zuteilung: --alle verteilt den realen Fall-Bestand, jeden Fall genau einmal" {
  unset MUTATE_AUSWAHL_FAELLE
  local s alle=""
  for s in 0 1 2 3 4 5 6 7 8 9; do
    run bash "$TOOL" shard --alle 10 "$s"
    [ "$status" -eq 0 ]
    [ -n "$output" ]
    alle="$alle $output"
  done
  diff <(tr ' ' '\n' <<<"$alle" | sed '/^$/d' | LC_ALL=C sort) \
    <(cd "$REPO/test/mutations" && for f in *.sh; do echo "${f%.sh}"; done | LC_ALL=C sort)
}

@test "grenze: 8 Faelle ergeben den lokalen Weg" {
  local i
  for i in 1 2 3 4 5 6 7 8; do fall "0$i" src/a.sh test-bats; done
  printf 'src/a.sh\n' >"$FAKE_DIFF"
  run bash "$TOOL" urteil slice-x
  [ "$status" -eq 0 ]
  [[ "$output" == *"lokal — make mutate MUTATE_CASES='01 02 03 04 05 06 07 08'"* ]]
}

@test "grenze: 9 Faelle ergeben den CI-Weg" {
  local i
  for i in 1 2 3 4 5 6 7 8 9; do fall "0$i" src/a.sh test-bats; done
  printf 'src/a.sh\n' >"$FAKE_DIFF"
  run bash "$TOOL" urteil slice-x
  [ "$status" -eq 10 ]
  [[ "$output" == *"git push -f origin HEAD:refs/heads/mutate/slice-x"* ]]
  [[ "$output" != *"make mutate MUTATE_CASES"* ]]
}
