#!/usr/bin/env bash
# working-tree-hash — inhaltsbasierter Hash über alle getrackten und
# untracked Dateien (exclude-standard). Gemeinsame Quelle der Wahrheit
# für `record-gates` und den Stop-Hook.
#
# INHALTSBASIERT statt diff-basiert (harness/conventions.md MR-003):
# Ein Commit ohne Inhaltsänderung lässt den Hash unverändert — der
# Gate-Nachweis bleibt gültig. Ein Commit OHNE vorherigen Gate-Lauf
# erzeugt dagegen keinen passenden Nachweis und wird vom Stop-Hook nicht
# mehr durchgewunken.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

# HASH_AUSNAHMEN (ADR-0103 Festlegung 2) — deklarierte Ausnahme obenauf auf der
# ls-files-Menge: Pfade unter `.harness/stamp/`, die unter einem der hier genannten
# Unterbaeume liegen, fallen aus der Hashmenge heraus — die Mutations-Records sind
# Ausgaben jedes Konsum-Laufs und Prüfgegenstand keines Gates; nichts, worüber geurteilt
# wird, liegt darunter. Eine Änderung allein unter ihnen bewegt den Hash nicht und hält
# den Nachweis gültig. Wächst diese Liste, ist DAS der sichtbare Ort (Form wie
# ISOLATION_KEY_EXEMPT in harness/tools/mutate.sh, ADR-0035 Festlegung 3). FAIL-CLOSED
# (MR-017-Form): Inhalt unter `.harness/stamp/` außerhalb dieser Liste beendet den Lauf
# mit Meldung — er wird weder still ausgenommen, noch bewegt er den Hash und damit
# entwertet jeden nachfolgenden Nachweis.
HASH_AUSNAHMEN=(.harness/stamp/mutate)

# ausnahme — 0, wenn der Pfad unter einer deklarierten Ausnahme liegt, 1 sonst.
ausnahme() {
  local p="$1" e
  for e in "${HASH_AUSNAHMEN[@]}"; do
    case "$p" in
      "$e" | "$e"/*) return 0 ;;
    esac
  done
  return 1
}

git ls-files -z --cached --others --exclude-standard \
  | sort -zu \
  | while IFS= read -r -d '' f; do
      case "$f" in
        .harness/stamp/*)
          if ! ausnahme "$f"; then
            printf 'working-tree-hash: FEHLER — %s liegt unter .harness/stamp/ ausserhalb der deklarierten Hash-Ausnahmen (%s): ADR-0103 Festlegung 2 — Ausnahme deklarieren oder den Pfad aus dem Baum nehmen.\n' "$f" "${HASH_AUSNAHMEN[*]}" >&2
            exit 2
          fi
          continue
          ;;
      esac
      if [ -L "$f" ]; then
        printf 'LINK %s -> %s\n' "$f" "$(readlink -- "$f")"
      elif [ -f "$f" ]; then
        sha256sum -- "$f"
      else
        printf 'GONE %s\n' "$f"
      fi
    done | sha256sum | awk '{print $1}'
