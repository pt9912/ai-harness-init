#!/usr/bin/env bats
# skel-drift.bats — Drift-Waechter (slice-003) fuer den eingebetteten Template-Baum
# internal/emit/skel/ gegen die vendored Baseline .harness/baseline/<tag>/templates/.
# Zwei Achsen zusammen halten skel/ == die in-scope-Teilmenge, byte-genau:
#   1. Gleichheit  — jede skel/-Datei == ihr vendored Twin (faengt lokale Aenderung).
#   2. Vollstaendigkeit — jedes in-scope-.template.md der Baseline hat ein skel/-Twin
#      (faengt ein bei einem Bump NEU upstream hinzugekommenes, nicht re-synctes Template).
# Laeuft in bats, weil dort der ganze Repo-Mount (skel/ UND .harness/) sichtbar ist —
# anders als in der go-test-Stage, deren Build-Kontext .harness ausschliesst
# (.dockerignore). Hermetisch: reiner Datei-Vergleich, kein Netz (make test / LH-QA-01).

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  SKEL="$REPO/internal/emit/skel"
  # vendored Baseline: genau ein <tag>-Verzeichnis (MR-007 "ein Tag zur Zeit").
  BASE="$(echo "$REPO"/.harness/baseline/*/templates)"
}

@test "skel-Embed == vendored Baseline (Gleichheit, kein lokaler Drift)" {
  [ -d "$SKEL" ] || { echo "skel fehlt: $SKEL"; return 1; }
  [ -d "$BASE" ] || { echo "vendored Baseline fehlt: $BASE"; return 1; }
  local rel
  while IFS= read -r rel; do
    diff -- "$SKEL/$rel" "$BASE/$rel" || { echo "DRIFT: $rel"; return 1; }
  done < <(cd "$SKEL" && find . -type f | sed 's#^\./##' | sort)
}

@test "skel bettet ALLE in-scope-Templates der Baseline ein (Vollstaendigkeit)" {
  [ -d "$BASE" ] || { echo "vendored Baseline fehlt: $BASE"; return 1; }
  # in-scope = alle .template.md der Baseline MINUS die fremd-besessenen:
  # project-readme (LH-FA-05/slice-005) und die zwei .harness/skills (LH-FA-06).
  local rel
  while IFS= read -r rel; do
    case "$rel" in
      project-readme.template.md|.harness/skills/*) continue ;;
    esac
    [ -f "$SKEL/$rel" ] || { echo "in-scope Template fehlt in skel/ (Bump nicht re-synct?): $rel"; return 1; }
  done < <(cd "$BASE" && find . -name '*.template.md' | sed 's#^\./##' | sort)
}

@test "skel bettet die Set-Index-README NICHT ein (wird nie emittiert)" {
  [ ! -f "$SKEL/README.md" ]
}
