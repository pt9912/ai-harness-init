#!/usr/bin/env bats
# ci-stempel-committed.bats — Waechter der committeten Stempel-Klasse (ADR-0111,
# Festlegung 6): die gitignore-Formen je Klasse, die CI-Verdrahtung des
# push-main-Konsults und die hermetische Klassifikation des E2E-Skip-Griffs.
#
# GITIGNORE-FORMEN: gemessen `git check-ignore` in einem tmp-Repo ueber der
# REAL committeten .gitignore (die reale Quelle; das tmp-Repo traegt nur die
# Verdrahtung dazu). Der Host-Lauf von `make test` faehrt git; der opt-in Lauf
# im gepinnten bats-Image fuehrt kein git und wird von diesen Faellen nicht
# gedeckt — die Grenze des opt-in Wegen.
#
# ROT FARBENDE MUTATIONEN (AGENTS.md §3.6):
#   - die gitignore-Ausnahme der je-Check-Keys faellt still weg → der
#     check-ignore-Fall rot (test/mutations/821-gitignore-ausnahme-faellt-still-weg.sh);
#   - der push-main-Job konsultiert die transportierten Keys nicht mehr →
#     der gates-Verdrahtungs-Fall rot (822, je LP 2);
#   - der E2E-Skip liest ein fremdes Feld → der SKIP-Fall rot (823, je LP 3).
#
# WAS HIER NICHT GEMESSEN WIRD: der reale CI-Lauf am frischen Klon — die
# Verdrahtung der Workflows belegt der CI-Lauf selbst (MR-003-Form: die CI ist
# dort das Netz), dieser Waechter haelt die Form-Verdrahtung davor.

REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"

# tmp_gitignore_repo kopiert die reale .gitignore in ein frisches git-Repo:
# check-ignore liest nur die Regeln, Commit-Stand und Index bleiben unbeachtet.
tmp_gitignore_repo() {
  local root
  root="$(mktemp -d)"
  git init -q "$root"
  cp "$REPO/.gitignore" "$root/.gitignore"
  printf '%s' "$root"
}

@test "gitignore: die committete Key-Klasse und der E2E-Stempel sind nicht ignoriert, die Gesamt-Dateien und die uebrigen state-Klassen sind es (ADR-0111 Festlegung 1/3)" {
  local root f
  root="$(tmp_gitignore_repo)"
  mkdir -p "$root/.harness/state/spans" "$root/.harness/state/bin"
  for f in \
    .harness/state/gates-passed-lint.key \
    .harness/state/gates-passed-span-check.key \
    .harness/state/full-smoke-passed.key \
    ; do
    : > "$root/$f"
    run git -C "$root" check-ignore -q "$f"
    [ "$status" -eq 1 ]
  done
  for f in \
    .harness/state/gates-passed.diffsha \
    .harness/state/gates-passed.head \
    .harness/state/spans/run.jsonl \
    .harness/state/bin/ai-harness-init \
    ; do
    : > "$root/$f"
    run git -C "$root" check-ignore -q "$f"
    [ "$status" -eq 0 ]
  done
  rm -rf "$root"
}
