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

# HASH_AUSNAHMEN (ADR-0103 Festlegung 2, erweitert um die committeten
# Ablage-Klassen je ADR-0111 Festlegung 1/4) — deklarierte Ausnahme obenauf auf der
# ls-files-Menge: Eintraege mit Globs lesen case-seitig als Muster, reine Pfade als
# Verzeichnis mit Kindern. Zwei Klassen fallen aus der Hashmenge heraus:
#   .harness/stamp/mutate             — die Mutations-Records sind Ausgaben jedes
#                                       Konsum-Laufs und Pruefgegenstand keines
#                                       Gates; nichts, worüber geurteilt wird, liegt
#                                       darunter (ADR-0103 Festlegung 2).
#   .harness/state/gates-passed-*.key — die committeten je-Check-Keys (ADR-0111
#                                       Festlegung 1): ein Stempel-Commit rotiert
#                                       damit keinen Baum-Hash und keinen Key, und
#                                       das Rezept `record-gates` haelt denselben
#                                       Nachweis ueber dem Transport-Konsum.
#   .harness/state/full-smoke-passed.key — der committete E2E-Stempel (ADR-0111
#                                       Festlegung 4), dieselbe Klasse.
# Der Grund ist derselbe wie MENGE_AUSSCHLUESS im Satzerzeuger
# (harness/tools/gates-keys.sh: "ein Key deckt sich nicht selbst"). Wächst diese
# Liste, ist DAS der sichtbare Ort (Form wie ISOLATION_KEY_EXEMPT in
# harness/tools/mutate.sh, ADR-0035 Festlegung 3). FAIL-CLOSED (MR-017-Form):
# getrackter oder untracked Inhalt unter `.harness/stamp/` oder
# `.harness/state/` außerhalb dieser Liste beendet den Lauf mit Meldung — er wird
# weder still ausgenommen, noch bewegt er den Hash und damit entwertet jeden
# nachfolgenden Nachweis. Die gitignored Gesamt-Dateien
# (.harness/state/gates-passed.diffsha/.head, ADR-0111 Festlegung 3) und die
# übrigen state-Ablagen erscheinen im ls-files-Walk nicht.
HASH_AUSNAHMEN=(
  .harness/stamp/mutate
  '.harness/state/gates-passed-*.key'
  '.harness/state/full-smoke-passed.key'
)

# ausnahme — 0, wenn der Pfad auf einen deklarierten Eintrag passt (Glob oder
# Verzeichnis mit Kindern), 1 sonst.
ausnahme() {
  local p="$1" e
  for e in "${HASH_AUSNAHMEN[@]}"; do
    case "$p" in
      $e | "$e"/*) return 0 ;;
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
        .harness/state/*)
          if ! ausnahme "$f"; then
            printf 'working-tree-hash: FEHLER — %s liegt unter .harness/state/ ausserhalb der deklarierten Hash-Ausnahmen (%s): ADR-0111 Festlegung 1 — Ausnahme deklarieren oder den Pfad aus dem Baum nehmen.\n' "$f" "${HASH_AUSNAHMEN[*]}" >&2
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
