#!/usr/bin/env bats
# skel-drift.bats — Drift-Waechter (slice-003): der eingebettete Template-Baum
# (internal/emit/skel/) muss byte-genau der vendored Baseline
# (.harness/baseline/<tag>/templates/) entsprechen. Faengt eine Embed-Kopie, die
# bei einem Baseline-Bump nicht re-synct wurde (LH-FA-02 / MR-007). Laeuft in bats,
# weil dort der ganze Repo-Mount (skel/ UND .harness/) sichtbar ist — anders als in
# der go-test-Stage, deren Build-Kontext .harness ausschliesst (.dockerignore).
# Hermetisch: reiner Datei-Vergleich, kein Netz (make test / LH-QA-01).

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  SKEL="$REPO/internal/emit/skel"
  # vendored Baseline: genau ein <tag>-Verzeichnis (MR-007 "ein Tag zur Zeit").
  BASE="$(echo "$REPO"/.harness/baseline/*/templates)"
}

@test "skel-Embed == vendored Baseline (kein Drift, slice-003)" {
  [ -d "$SKEL" ] || { echo "skel fehlt: $SKEL"; return 1; }
  [ -d "$BASE" ] || { echo "vendored Baseline fehlt: $BASE"; return 1; }
  local rel
  while IFS= read -r rel; do
    diff -- "$SKEL/$rel" "$BASE/$rel" || { echo "DRIFT: $rel"; return 1; }
  done < <(cd "$SKEL" && find . -type f | sed 's#^\./##' | sort)
}

@test "skel bettet die Set-Index-README NICHT ein (wird nie emittiert)" {
  [ ! -f "$SKEL/README.md" ]
}
