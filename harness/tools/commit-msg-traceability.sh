#!/usr/bin/env bash
# commit-msg-traceability.sh — prueft eine Commit-Message-DATEI gegen die
# Traceability-Zusage (AGENTS.md §5, harness/README.md §Traceability).
#
# ZUSAGE. Exit 0, wenn die Message mindestens eine Kennung aus der Menge
# {ADR-, LH-, MR-, slice-} traegt oder ihr Betreff mit "Merge " bzw. "Revert "
# beginnt; Exit 1, wenn keines von beidem zutrifft; Exit 2, wenn die Datei fehlt
# oder nicht lesbar ist. Betreff ist die erste nicht-leere Zeile ohne
# Kommentarzeichen; die Kennung darf auch im Rumpf stehen, eine Kommentarzeile
# zaehlt dagegen nicht.
#
# ABGRENZUNG. Kein Gate und kein Ersatz fuer `make commit-msg-check`: dieser
# Aufruf steht im Commit-Pfad und setzt darum nichts voraus, was der Host nicht
# hat (LH-QA-03) — kein Docker, kein d-check-Image, kein Netz, nur bash und
# coreutils. Der Aufrufer ist der git-eigene Traeger .githooks/commit-msg.
#
# KOPPLUNG. .d-check.yml fuehrt dieselbe Kennungs-Menge als
# `commits.id-patterns` samt `exempt-pattern`; `make commit-msg-check` liest sie
# ueber d-check. test/commit-msg-hook.bats haelt beide Fassungen in beide
# Richtungen gegen dieselbe Liste.
#
# GRENZE. Geprueft wird die ANWESENHEIT einer Kennung, nicht ihre Wahrheit
# (dieselbe Grenze wie bei `make commit-msg-check`). Als Kommentarzeile gilt die
# fuehrende Raute; ein abweichendes core.commentChar liest dieses Skript nicht.
set -euo pipefail

msg_file="${1:-}"
if [ -z "$msg_file" ]; then
  echo "commit-msg-traceability: keine Message-Datei uebergeben (Aufruf: $0 <datei>)." >&2
  exit 2
fi
if [ ! -r "$msg_file" ]; then
  echo "commit-msg-traceability: '$msg_file' ist nicht lesbar." >&2
  exit 2
fi

# Betreff: erste Zeile, die weder leer noch eine Kommentarzeile ist, ohne
# fuehrende Leerzeichen. An ihr haengt die Merge-/Revert-Ausnahme.
subject=""
while IFS= read -r line || [ -n "$line" ]; do
  trimmed="${line#"${line%%[![:space:]]*}"}"
  [ -n "$trimmed" ] || continue
  case "$trimmed" in
    '#'*) continue ;;
  esac
  subject="$trimmed"
  break
done < "$msg_file"

exempt='^(Merge |Revert )'
if [[ "$subject" =~ $exempt ]]; then
  exit 0
fi

# Kennung: ERE ueber die ganze Datei, Kommentarzeilen ausgenommen. Der Dialekt
# ist POSIX-ERE ([0-9] statt \d) — bash kennt die \d-Kurzform des d-check-Moduls
# nicht, die Uebersetzung steht in test/commit-msg-hook.bats.
patterns='(ADR-[0-9]{4}|LH-[A-Z]{2}-[0-9]{2}|MR-[0-9]{3}|slice-[0-9]+)'
while IFS= read -r line || [ -n "$line" ]; do
  trimmed="${line#"${line%%[![:space:]]*}"}"
  case "$trimmed" in
    '#'*) continue ;;
  esac
  if [[ "$line" =~ $patterns ]]; then
    exit 0
  fi
done < "$msg_file"

echo "commit-msg-traceability: keine Traceability-Kennung in der Commit-Message (AGENTS.md §5):" >&2
echo "            ${subject}" >&2
exit 1
