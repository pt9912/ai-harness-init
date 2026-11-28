#!/usr/bin/env bash

# working-tree-hash-abnahme.bats — die Fitness Function der Hash-Ausnahme in
# harness/tools/working-tree-hash.sh (ADR-0103 Festlegung 2, Mess-Form wie die
# ISOLATION_KEY_EXEMPT-Zeilen in test/mutate-driver.bats). GEMESSEN wird das REALE
# Skript ueber eine Werkstatt-Eingabe (tmp-Verzeichnis mit Stub-`git`), weil der
# bats-Lauf des Baums read-only mountet und im BATS-Image keine git-Toolchain fuehrt
# (MR-049) — die Ausnahme-Liste und die case-Zweige des Skripts sind die reale Quelle,
# die Werkstatt hier baut nur die Eingabe an.
#
# GRENZE, je Stub-Form wie test/mutate-auswahl.bats: der Stub implementiert GENAU die
# zwei git-Aufrufe des Skripts (`rev-parse --show-toplevel`, `ls-files -z --cached
# --others --exclude-standard` als getrackte-plus-untracked-Wanderung, `.git` und
# nichts sonst ausgeschlossen). DIE REALE git-Seite des Hashs — das Listing, das
# record-gates stoppt — traegt der Lauf am Gate-Nachweis selbst und die
# E2E-Messung im gebootstrappen Ziel (full-smoke, reale Werkstatt mit git); gegen
# einen Verfaelschten Anruf schweigt dieser Stub-Waechter.
#
# ROT FARBENDE MUTATIONEN (AGENTS.md 3.6):
#   - Fall 1 und Fall 2 faerben rot, sobald das Skript seine Zwei-Zuege verliert:
#     Fall 1 (die Ausnahme deckt nicht mehr), gemessen im Fall
#     test/mutations/791-working-tree-stamp-ausnahme-ohne-zaehne.sh
#     (`make mutate MUTATE_CASES=791-working-tree-stamp-ausnahme-ohne-zaehne.sh`,
#     Anker am Commit je MR-090); Fall 2 (der fail-closed-Zweig weicht dem stillen
#     Ausnehmen), gemessen im Fall
#     test/mutations/792-working-tree-stamp-ausnahme-schweigt-still.sh.
#   - Fall 3 (enge) und Fall 4 (Determinismus) tragen die Umkehrung gegen den
#     unveränderten Baum. Das gemeinsame rot färbende Gegenbeispiel beider ist
#     der fremd-Bruch-Fall — die fremd-Prüfung von Fall 2 über den Stamp-Baum
#     hinaus ausgeweitet, bricht beide mit Exit 2; einen kuratierten Fall
#     trägt die Ausweitung nicht, sie ist benannt, nicht gebaut. Der Fall 791
#     selbst färbt nur die Stamp-Form-Fälle: Fall 3 bleibt unter 791 grün —
#     die Stamp-Form-Mutation wirkt im Stamp-Inneren, der enge Fall misst
#     außerhalb von .harness/stamp/ — und Fall 4 färbt rot, sein Setup
#     enthält Stamp-Inhalt, der unter der entleerten Liste über denselben
#     fail-closed-Zweig bricht (denselben Bruch-Fall in der
#     Determinismus-Fassung).

REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
WTH="$REPO/harness/tools/working-tree-hash.sh"

# tmp_repo legt eine Werkstatt mit Stub-`git` an und kopiert das reale Skript
# hinein: das Skript loest seinen Topelevel aus dem cwd, nicht aus dem eigenen Pfad,
# und misst so genau den Werkstatt-Baum.
tmp_repo() {
  local root
  root="$(mktemp -d)"
  mkdir -p "$root/.bin"
  cat >"$root/.bin/git" <<'STUB'
#!/usr/bin/env bash
# Stub-`git` fuer working-tree-hash-abnahme.bats: genau die zwei Anrufe des
# realen Skripts. rev-parse --show-toplevel liefert das cwd (die Werkstatt);
# ls-files -z --cached --others --exclude-standard liest die getrackte plus
# untracked Datei-Menge als Wanderung mit .git/ ausgeschlossen — die
# real-git-Semantik dahinter tragen record-gates und full-smoke.
set -euo pipefail
case "$1" in
  rev-parse)
    pwd
    ;;
  ls-files)
    # Der Strip von "./" pro NUL-Record, nicht per sed-Anker: sed ohne -z
    # teilt nach NEWLINE — mit -print0-Eingabe traefe der ^-Anker nur den
    # ERSTEN Record, und spaetere Pfaede behielten ihr "./"-Praefix (dann
    # liest die Ausnahme-Klammer der realen Skripts die Stamp-Pfade nicht
    # und der Hash bewegte sie mit). Die Bash-Loop ist weg-agnostisch
    # (GNU- und BusyBox-sed; seit slice-labor-gates-host-rezepte laeuft
    # make test-bats am Host).
    while IFS= read -r -d '' p; do
      printf "%s\0" "${p#./}"
    done < <(find . \( -name .git -prune \) -o \( -type f -o -type l \) -print0)
    ;;
  *)
    echo "stub-git: Anruf nicht gedeckt: $*" >&2
    exit 64
    ;;
esac
STUB
  chmod +x "$root/.bin/git"
  cp "$WTH" "$root/wth.sh"
  printf '%s' "$root"
}

@test "stamp-ausnahme: ein Pfad unter .harness/stamp/mutate bewegt den Hash nicht (ADR-0103 Festlegung 2)" {
  local root a b
  root="$(tmp_repo)"
  printf 'basis\n' >"$root/docs.md"
  a="$(cd "$root" && PATH="$root/.bin:$PATH" bash wth.sh)"
  [ -n "$a" ] # fail-closed: ein leerer Hash macht die Gleichheit vakuaer
  mkdir -p "$root/.harness/stamp/mutate"
  printf 'run-456\n' >"$root/.harness/stamp/mutate/slice-x-abc-befund.txt"
  b="$(cd "$root" && PATH="$root/.bin:$PATH" bash wth.sh)"
  rm -rf "$root"
  [ "$a" = "$b" ]
}

@test "stamp-ausnahme: Inhalt unter .harness/stamp ausserhalb der deklarierten Liste endet rot (fail-closed, MR-017-Form)" {
  local root out status
  root="$(tmp_repo)"
  printf 'basis\n' >"$root/docs.md"
  mkdir -p "$root/.harness/stamp/fremd"
  printf 'undeclared\n' >"$root/.harness/stamp/fremd/form.txt"
  status=0
  out="$(cd "$root" && PATH="$root/.bin:$PATH" bash wth.sh 2>&1)" || status=$?
  rm -rf "$root"
  [ "$status" -ne 0 ]
  grep -qF 'ausserhalb der deklarierten Hash-Ausnahmen' <<<"$out"
}

@test "stempel-ausnahme: ein committeter je-Check-Key und der E2E-Stempel unter .harness/state/ bewegen den Hash nicht (ADR-0111 Festlegung 1/4)" {
  local root a b c
  root="$(tmp_repo)"
  printf 'basis\n' >"$root/docs.md"
  a="$(cd "$root" && PATH="$root/.bin:$PATH" bash wth.sh)"
  [ -n "$a" ]
  mkdir -p "$root/.harness/state"
  printf '9fe6c0c9d0fde3e6ea2c25f6dfa8fbd3a9ea1dcbdd8e5fa2c4b56fd0a9e0f1a2\n' >"$root/.harness/state/gates-passed-lint.key"
  b="$(cd "$root" && PATH="$root/.bin:$PATH" bash wth.sh)"
  [ "$a" = "$b" ]
  printf '0a1b2c3d4e5f60718293a4b5c6d7e8f90a1b2c3d4e5f60718293a4b5c6d7e8f9\n' >"$root/.harness/state/full-smoke-passed-kotlin.key"
  c="$(cd "$root" && PATH="$root/.bin:$PATH" bash wth.sh)"
  rm -rf "$root"
  [ "$b" = "$c" ]
}

@test "stempel-ausnahme: Inhalt unter .harness/state ausserhalb der deklarierten Klassen endet rot (fail-closed, MR-017-Form, ADR-0111 Festlegung 1)" {
  local root out status
  root="$(tmp_repo)"
  printf 'basis\n' >"$root/docs.md"
  mkdir -p "$root/.harness/state"
  printf 'undeclared\n' >"$root/.harness/state/gates-passed.fremd"
  status=0
  out="$(cd "$root" && PATH="$root/.bin:$PATH" bash wth.sh 2>&1)" || status=$?
  rm -rf "$root"
  [ "$status" -ne 0 ]
  grep -qF 'ausserhalb der deklarierten Hash-Ausnahmen' <<<"$out"
  grep -qF '.harness/state/gates-passed.fremd' <<<"$out"
}

@test "enge: ausserhalb .harness/stamp bewegt sich der Hash weiter" {
  local root a b
  root="$(tmp_repo)"
  printf 'eins\n' >"$root/docs.md"
  a="$(cd "$root" && PATH="$root/.bin:$PATH" bash wth.sh)"
  printf 'zwei\n' >"$root/datum.md"
  b="$(cd "$root" && PATH="$root/.bin:$PATH" bash wth.sh)"
  rm -rf "$root"
  [ "$a" != "$b" ]
}

@test "determinismus: der unveraenderte Baum liest denselben Hash ueber wiederholte Laeufe" {
  local root a b
  root="$(tmp_repo)"
  printf 'x\n' >"$root/docs.md"
  mkdir -p "$root/.harness/stamp/mutate"
  printf 'y\n' >"$root/.harness/stamp/mutate/record.txt"
  a="$(cd "$root" && PATH="$root/.bin:$PATH" bash wth.sh)"
  b="$(cd "$root" && PATH="$root/.bin:$PATH" bash wth.sh)"
  rm -rf "$root"
  [ -n "$a" ]
  [ "$a" = "$b" ]
}
