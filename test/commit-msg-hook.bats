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
# Beleg, und fuer eine Kennung ausserhalb der Liste verlangt sie die Ablehnung.
# Der Uebersetzungsschritt darin ist echt und nicht kosmetisch: .d-check.yml
# schreibt \d, bash kennt diese Kurzform nicht.

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

@test "kopplung: jedes Muster aus .d-check.yml wird angenommen" {
  local -a pats=()
  local p e t hit f
  while IFS= read -r p; do
    [ -n "$p" ] && pats+=("$p")
  done < <(sed -n '/^commits:/,/^[^[:space:]#]/p' "$REPO/.d-check.yml" \
           | sed -n "s/^[[:space:]]*-[[:space:]]*'\(.*\)'[[:space:]]*$/\1/p")
  [ "${#pats[@]}" -gt 0 ]
  for p in "${pats[@]}"; do
    e="$(printf '%s' "$p" | sed 's/\\d/[0-9]/g')"
    hit=""
    for t in ADR-0001 LH-QA-01 MR-001 slice-1; do
      if [[ "$t" =~ ^($e)$ ]]; then hit="$t"; break; fi
    done
    [ -n "$hit" ] || { echo "kein Beispiel-Token fuer das Muster '$p' — Kopplung angefasst?"; return 1; }
    f="$(write_msg "Betreff ohne Kennung\n\nBezug: $hit\n")"
    run bash "$HOOK" "$f"
    [ "$status" -eq 0 ] || { echo "Muster '$p' mit '$hit' wurde abgelehnt: $output"; return 1; }
  done
}

@test "kopplung: eine Kennung ausserhalb der Config-Liste wird abgelehnt" {
  f="$(write_msg 'Betreff ohne Kennung\n\nBezug: DC-0001\n')"
  run bash "$HOOK" "$f"
  [ "$status" -eq 1 ]
}
