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
while [ "$1" = "-C" ] || [ "$1" = "-c" ]; do shift 2; done
case "$1" in
  log) [ -n "${FAKE_CLAIM:-}" ] && printf '%s\n' "$FAKE_CLAIM"; exit 0 ;;
  rev-parse) printf '%s\n' "$FAKE_HEAD" ;;
  diff)
    if [[ " $* " == *" HEAD^ "* ]]; then printf '%s\n' "${FAKE_DIFF_TIP:-src/a.sh}"; else cat "$FAKE_DIFF"; fi ;;
  add | commit) exit 0 ;;
  push) printf '%s\n' "$*" >>"$FAKE_PUSH_LOG" ;;
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
  export FAKE_HEAD="0123abcd4567ef890123abcd4567ef890123abcd"
  export FAKE_DIFF="$BATS_TEST_TMPDIR/diff"
  export FAKE_PUSH_LOG="$BATS_TEST_TMPDIR/push.log"
  : >"$FAKE_DIFF"
}

# kopie legt Skript und Treiber in einen beschreibbaren Baum ($KOPIE) — der Ergebnis-Schritt
# schreibt mutate-ergebnis.txt an die Wurzel seines REPO, und /code ist read-only gemountet.
kopie() {
  KOPIE="$BATS_TEST_TMPDIR/repo"
  mkdir -p "$KOPIE/harness/tools"
  cp "$REPO/harness/tools/mutate-auswahl.sh" "$REPO/harness/tools/mutate.sh" "$KOPIE/harness/tools/"
}

# beleg <dir> <shard> <rc> "<faelle>" — ein Shard-Beleg, jeder genannte Fall mit `ok` im Log.
beleg() {
  local d="$1/shard-$2" f
  mkdir -p "$d"
  echo "$3" >"$d/rc"
  printf '%s\n' "$4" >"$d/faelle"
  echo 100 >"$d/start"
  echo 160 >"$d/ende"
  : >"$d/log"
  for f in $4; do printf 'mutate: ok   %s (test-bats)\n' "$f" >>"$d/log"; done
}

# rezept <ziel> gibt den Shelltext eines Makefile-Rezepts so aus, wie make ihn der Shell
# uebergibt: `@` entfernt, `$(VAR)` durch den Wert aus der Umgebung ersetzt (die Expansion eines
# Kommandozeilen-Werts), `$$` zu `$`. Grenze: das ist die Make-Expansion fuer genau diese zwei
# Formen, nicht make selbst — das bats-Image fuehrt kein make.
rezept() {
  local text v
  text="$(awk -v z="$1:" 'index($0, z) == 1 { f = 1; next } f && /^\t/ { sub(/^\t@?/, ""); print; next } f { exit }' "$REPO/Makefile")"
  text="${text//\$\$/$'\001'}"
  for v in SCHRITT REF SLICE SHARDS SHARD ERGEBNIS_DIR; do text="${text//\$($v)/${!v:-}}"; done
  printf '%s\n' "${text//$'\001'/\$}"
}

# Der Ref aus dem Review-Befund, mit dem Tip-Praefix des Stubs: ein gueltiger git-Branch-Name,
# der aus einem '…'-Literal ausbricht und eine Marken-Datei anlegt.
injektions_ref() {
  printf '%s' "mutate/x';touch\${IFS}$BATS_TEST_TMPDIR/INJIZIERT-AUS-DEM-REF;'-0123abcd"
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
  [[ "$output" == *"git push origin HEAD:refs/heads/mutate/slice-x-0123abcd"* ]]
  [[ "$output" != *"make mutate MUTATE_CASES"* ]]
}

@test "grenze: das Urteil gibt nie einen Force-Push aus" {
  local i
  for i in 1 2 3 4 5 6 7 8 9; do fall "0$i" src/a.sh test-bats; done
  printf 'src/a.sh\n' >"$FAKE_DIFF"
  run bash "$TOOL" urteil slice-x
  [ "$status" -eq 10 ]
  [[ "$output" == *"git push "* ]]
  [[ "$output" != *"push -f"* ]]
  [[ "$output" != *"--force"* ]]
  [[ "$output" != *"HEAD:refs/heads/+"* && "$output" != *" +HEAD"* ]]
}

@test "lauf: ein Ref ohne Praefix mutate/ bricht ab" {
  run bash "$TOOL" lauf main
  [ "$status" -eq 2 ]
  [[ "$output" == *"ABBRUCH — Ref 'main' hat nicht die Form mutate/<kennung>-<sha8>"* ]]
}

@test "lauf: mutate/<kennung>-<sha8> liefert die Kennung und laeuft auf seinem Commit" {
  printf 'src/a.sh\n' >"$FAKE_DIFF"
  run bash "$TOOL" lauf mutate/slice-x-0123abcd
  [ "$status" -eq 0 ]
  [ "$output" = $'kennung=slice-x\nshards=10\nmatrix=[0,1,2,3,4,5,6,7,8,9]\nlaufen=true' ]
  run bash "$TOOL" lauf mutate/slice-x-deadbeef
  [ "$status" -eq 2 ]
}

@test "lauf: Shard-Zahl und Matrix kommen aus einer Quelle" {
  run bash "$TOOL" lauf mutate/slice-x-0123abcd
  [ "$status" -eq 0 ]
  local n m
  n="$(sed -n 's/^shards=//p' <<<"$output")"
  m="$(sed -n 's/^matrix=//p' <<<"$output")"
  [ "$m" = "[$(seq 0 $((n - 1)) | paste -sd,)]" ]
}

@test "lauf: ein Tip, der allein die Ergebnisdatei aendert, startet keinen Lauf" {
  FAKE_DIFF_TIP=mutate-ergebnis.txt run bash "$TOOL" lauf mutate/slice-x-0123abcd
  [ "$status" -eq 0 ]
  [[ "$output" == *"laufen=false"* ]]
  [[ "$output" != *"laufen=true"* ]]
}

@test "lauf: ein Ref mit Shell-Zeichen bricht mit Exit 2 ab und fuehrt nichts aus" {
  run bash "$TOOL" lauf "$(injektions_ref)"
  [ "$status" -eq 2 ]
  [[ "$output" == *"ABBRUCH — Ref 'mutate/x'"*"hat nicht die Form mutate/<kennung>-<sha8>"* ]]
  [[ "$output" != *"kennung="* ]]
  [ ! -e "$BATS_TEST_TMPDIR/INJIZIERT-AUS-DEM-REF" ]
}

@test "rezept: mutate-branch reicht den Ref als Wert durch, nicht als Shelltext" {
  kopie
  SCHRITT=lauf REF="$(injektions_ref)" run bash -c "cd '$KOPIE' && $(SCHRITT=lauf REF="$(injektions_ref)" rezept mutate-branch)"
  [ ! -e "$BATS_TEST_TMPDIR/INJIZIERT-AUS-DEM-REF" ]
  [ "$status" -eq 2 ]
}

@test "ergebnis: jeder Fall ok und jeder Shard Exit 0 ergibt gruen" {
  kopie
  fall 01-a src/a.sh test-bats
  fall 02-b src/a.sh test-bats
  printf 'src/a.sh\n' >"$FAKE_DIFF"
  beleg "$BATS_TEST_TMPDIR/s" 0 0 "01-a"
  beleg "$BATS_TEST_TMPDIR/s" 1 0 "02-b"
  run bash "$KOPIE/harness/tools/mutate-auswahl.sh" ergebnis mutate/slice-x-0123abcd 2 "$BATS_TEST_TMPDIR/s"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Urteil: gruen"* ]]
}

@test "ergebnis: ein Shard mit Exit ungleich 0 ergibt BEFUND, auch wenn seine Faelle ok sind" {
  kopie
  fall 01-a src/a.sh test-bats
  printf 'src/a.sh\n' >"$FAKE_DIFF"
  beleg "$BATS_TEST_TMPDIR/s" 0 1 "01-a"
  run bash "$KOPIE/harness/tools/mutate-auswahl.sh" ergebnis mutate/slice-x-0123abcd 1 "$BATS_TEST_TMPDIR/s"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Urteil: BEFUND"* ]]
  [[ "$output" != *"Urteil: gruen"* ]]
}

@test "ergebnis: ein Fall der Fallmenge ohne Shard-Beleg ergibt BEFUND" {
  kopie
  fall 01-a src/a.sh test-bats
  fall 02-b src/a.sh test-bats
  printf 'src/a.sh\n' >"$FAKE_DIFF"
  # zwei Shards in der Matrix, das Ergebnis liest einen: 02-b liegt ausserhalb
  beleg "$BATS_TEST_TMPDIR/s" 0 0 "01-a"
  beleg "$BATS_TEST_TMPDIR/s" 1 0 "02-b"
  run bash "$KOPIE/harness/tools/mutate-auswahl.sh" ergebnis mutate/slice-x-0123abcd 1 "$BATS_TEST_TMPDIR/s"
  [ "$status" -eq 1 ]
  [[ "$output" == *"FEHLT    02-b"* ]]
  [[ "$output" != *"Urteil: gruen"* ]]
}

@test "grenze: der Ergebnis-Schritt pusht ohne Force auf genau seinen Ref" {
  kopie
  fall 01-a src/a.sh test-bats
  printf 'src/a.sh\n' >"$FAKE_DIFF"
  beleg "$BATS_TEST_TMPDIR/s" 0 0 "01-a"
  run bash "$KOPIE/harness/tools/mutate-auswahl.sh" ergebnis mutate/slice-x-0123abcd 1 "$BATS_TEST_TMPDIR/s"
  [ "$status" -eq 0 ]
  [ "$(cat "$FAKE_PUSH_LOG")" = "push origin HEAD:refs/heads/mutate/slice-x-0123abcd" ]
}
