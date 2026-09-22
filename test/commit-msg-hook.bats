#!/usr/bin/env bats
# commit-msg-hook.bats — Zaehne fuer den git-eigenen Traeger der
# Traceability-Regel: .githooks/commit-msg ueber
# harness/tools/commit-msg-traceability.sh (AGENTS.md §5, harness/README.md
# §Traceability).
#
# HERMETISCH: der Traeger ist bash + coreutils, er liest eine Message-Datei und
# braucht kein git — der Lauf findet darum im gepinnten bats-Image statt (make
# test-bats). Was hier NICHT gemessen wird, ist der Aufruf DURCH git (der Pfad
# mit gesetztem core.hooksPath) und die Umgehung --no-verify: der Beleg dafuer
# ist ein realer Commit-Versuch und steht in harness/README.md §Traceability.
#
# ZWEI GRUPPEN. Die erste faehrt das Urteil des Traegers ueber eine
# Message-Datei. Die zweite haelt die zwei Fassungen derselben Regel zusammen —
# die Muster im Traeger, die Liste in .d-check.yml `commits:` — und zwar in
# beide Richtungen: fuer JEDES Muster der Config braucht sie einen angenommenen
# Beleg, und die Muster-Mengen beider Fassungen muessen einander gleich sein.
# Der Uebersetzungsschritt darin ist echt und nicht kosmetisch: .d-check.yml
# schreibt \d, bash kennt diese Kurzform nicht.
#
# WARUM DIE GLEICHHEIT UND NICHT NUR DER BELEG: ein Beleg je Config-Muster
# misst nur eine Richtung — waechst der Traeger um ein Muster, das die Config
# nicht fuehrt, bleibt er gruen. Gelesen wird darum die ausfuehrende Zeile
# selbst (genau eine `^patterns=`-Zeile, sonst rot), nicht Prosa daneben.

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  HOOK="$REPO/.githooks/commit-msg"
  TMP="$(mktemp -d)"
}

teardown() {
  rm -rf "$TMP"
}

# write_msg <inhalt mit \n> — schreibt die Datei und gibt ihren Pfad aus.
write_msg() {
  printf '%b' "$1" > "$TMP/msg.txt"
  printf '%s' "$TMP/msg.txt"
}

# config_patterns / hook_patterns — die Kennungs-Muster der zwei Fassungen, je
# Muster eine Zeile, auf EINEN Dialekt normalisiert ([0-9] -> \d). Die
# Traeger-Seite wird aus der ausfuehrenden Zeile gelesen: gibt es sie nicht
# genau einmal, steht die Stoerung als Zeile in der Ausgabe und der Vergleich
# faellt (fail-closed statt still gruen).
config_patterns() {
  sed -n '/^commits:/,/^[^[:space:]#]/p' "$REPO/.d-check.yml" \
    | sed -n "s/^[[:space:]]*-[[:space:]]*'\(.*\)'[[:space:]]*$/\1/p"
}

hook_patterns() {
  local n line
  n="$(grep -c '^patterns=' "$REPO/harness/tools/commit-msg-traceability.sh")"
  if [ "$n" -ne 1 ]; then
    echo "STORUNG: der Traeger traegt $n '^patterns='-Zeilen statt einer"
    return 1
  fi
  line="$(sed -n 's/^patterns=//p' "$REPO/harness/tools/commit-msg-traceability.sh")"
  line="${line#\'}"; line="${line%\'}"
  line="${line#(}"; line="${line%)}"
  printf '%s\n' "$line" | tr '|' '\n' | sed -e '/^$/d' -e 's/\[0-9\]/\\d/g'
}

# config_exempt / hook_exempt — die Betreff-Ausnahme beider Fassungen.
config_exempt() {
  sed -n '/^commits:/,/^[^[:space:]#]/p' "$REPO/.d-check.yml" \
    | sed -n "s/^[[:space:]]*exempt-pattern:[[:space:]]*'\(.*\)'[[:space:]]*$/\1/p"
}

hook_exempt() {
  local n line
  n="$(grep -c '^exempt=' "$REPO/harness/tools/commit-msg-traceability.sh")"
  if [ "$n" -ne 1 ]; then
    echo "STORUNG: der Traeger traegt $n '^exempt='-Zeilen statt einer"
    return 1
  fi
  line="$(sed -n 's/^exempt=//p' "$REPO/harness/tools/commit-msg-traceability.sh")"
  line="${line#\'}"; line="${line%\'}"
  printf '%s' "$line"
}

# ---------- Urteil des Traegers ----------

@test "traeger: Message ohne Kennung wird abgelehnt" {
  f="$(write_msg 'Betreff ohne jede Kennung\n\nFliesstext ohne Kennung\n')"
  run bash "$HOOK" "$f"
  [ "$status" -eq 1 ]
  [[ "$output" == *"keine Traceability-Kennung"* ]]
}

@test "traeger: Message mit Kennung wird angenommen" {
  f="$(write_msg 'Bezug: ADR-0004\n\nFliesstext\n')"
  run bash "$HOOK" "$f"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "traeger: Merge-Betreff ohne Kennung wird angenommen" {
  f="$(write_msg 'Merge branch main into feature\n\nnichts weiter\n')"
  run bash "$HOOK" "$f"
  [ "$status" -eq 0 ]
}

@test "traeger: Revert-Betreff ohne Kennung wird angenommen" {
  f="$(write_msg 'Revert "etwas"\n\nnichts weiter\n')"
  run bash "$HOOK" "$f"
  [ "$status" -eq 0 ]
}

@test "traeger: ein Betreff 'Merge' ohne Leerzeichen wird abgelehnt" {
  f="$(write_msg 'Merge\n\nnichts weiter\n')"
  run bash "$HOOK" "$f"
  [ "$status" -eq 1 ]
}

@test "traeger: Kennung im Rumpf genuegt" {
  f="$(write_msg 'Betreff ohne Kennung\n\nBezug: ADR-0004\n')"
  run bash "$HOOK" "$f"
  [ "$status" -eq 0 ]
}

@test "traeger: Kennung nur in einer Kommentarzeile genuegt nicht" {
  f="$(write_msg 'Betreff ohne Kennung\n\n# Please enter the commit message. ADR-0004\n')"
  run bash "$HOOK" "$f"
  [ "$status" -eq 1 ]
}

@test "traeger: ohne Message-Datei bricht der Aufruf ab (fail-closed)" {
  run bash "$HOOK"
  [ "$status" -eq 2 ]
}

@test "traeger: nicht lesbare Message-Datei bricht den Aufruf ab (fail-closed)" {
  run bash "$HOOK" "$TMP/gibt-es-nicht.txt"
  [ "$status" -eq 2 ]
}

# ---------- Kopplung an die Liste der Gate-Config ----------

@test "kopplung: Traeger und Config tragen dieselbe Muster-Menge" {
  local -a a=() b=()
  local p
  while IFS= read -r p; do
    [ -n "$p" ] && a+=("$p")
  done < <(config_patterns | sort -u)
  while IFS= read -r p; do
    [ -n "$p" ] && b+=("$p")
  done < <(hook_patterns | sort -u)
  if [ "$(printf '%s\n' "${a[@]}")" != "$(printf '%s\n' "${b[@]}")" ]; then
    echo "die Muster-Mengen weichen ab:"
    echo "  .d-check.yml: ${a[*]}"
    echo "  Traeger     : ${b[*]}"
    return 1
  fi
  [ "${#a[@]}" -gt 0 ]
}

@test "kopplung: Traeger und Config tragen dieselbe Betreff-Ausnahme" {
  local c h
  c="$(config_exempt)"
  h="$(hook_exempt)"
  [ -n "$c" ]
  if [ "$c" != "$h" ]; then
    echo "die Betreff-Ausnahmen weichen ab:"
    echo "  .d-check.yml: $c"
    echo "  Traeger     : $h"
    return 1
  fi
}

@test "kopplung: jedes Muster aus .d-check.yml wird angenommen" {
  local p e t hit f
  while IFS= read -r p; do
    [ -n "$p" ] || continue
    e="$(printf '%s' "$p" | sed 's/\\d/[0-9]/g')"
    hit=""
    for t in ADR-0001 LH-QA-01 MR-001 slice-1; do
      if [[ "$t" =~ ^($e)$ ]]; then hit="$t"; break; fi
    done
    [ -n "$hit" ] || { echo "kein Beispiel-Token fuer das Muster '$p' — Kopplung angefasst?"; return 1; }
    f="$(write_msg "Betreff ohne Kennung\n\nBezug: $hit\n")"
    run bash "$HOOK" "$f"
    [ "$status" -eq 0 ] || { echo "Muster '$p' mit '$hit' wurde abgelehnt: $output"; return 1; }
  done < <(config_patterns)
}

@test "kopplung: eine Kennung ausserhalb der Config-Liste wird abgelehnt" {
  f="$(write_msg 'Betreff ohne Kennung\n\nBezug: DC-0001\n')"
  run bash "$HOOK" "$f"
  [ "$status" -eq 1 ]
}
