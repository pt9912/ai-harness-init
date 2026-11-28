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

# --- CI-Verdrahtung (LP 2/LP 3, ADR-0111 Festlegung 2/4) --------------------

gates_job_block() {
  awk '/^  gates:/{p=1;next} p&&/^  [a-z]/{p=0} p' "$REPO/.github/workflows/ci.yml"
}

full_smoke_job_block() {
  awk '/^  full-smoke:/{p=1;next} p&&/^  [a-z]/{p=0} p' "$REPO/.github/workflows/ci.yml"
}

@test "ci-verdrahtung: der push-main-Gates-Job konsultiert die transportierten Keys unforced, die uebrigen Klassen fahren GATES_FORCE=1 (ADR-0111 Festlegung 2)" {
  local block
  block="$(gates_job_block)"
  # push-main: der unforced Aufruf — der Fast-Pfad entscheidet ueber den
  # committeten Keys selbst (kein zweiter Massstab, Festlegung 2).
  [ "$(grep -cE '^[[:space:]]+make gates$' <<<"$block")" -eq 1 ]
  # alle uebrigen Klassen (pull_request, Nicht-main-Push, Tags): erzwungen voll.
  grep -qF 'GATES_FORCE=1 make gates' <<<"$block"
  grep -qF 'github.event_name' <<<"$block"
  grep -qF 'refs/heads/main' <<<"$block"
}

@test "ci-verdrahtung: der E2E-Skip-Griff laeuft nur am push-main-Job, die uebrigen Klassen fahren make full-smoke voll (ADR-0111 Festlegung 2/4)" {
  local block
  block="$(full_smoke_job_block)"
  # push-main: die Konsult-Umgebung schaltet den Griff im Rezept an — der Lauf
  # bleibt derselbe make-Aufruf, die CI traegt keine zweite Definition.
  [ "$(grep -cE '^[[:space:]]+make full-smoke$' <<<"$block")" -eq 1 ]
  grep -qF 'FULL_SMOKE_SKIP_KONSULT=1 make full-smoke' <<<"$block"
  grep -qF 'github.event_name' <<<"$block"
  grep -qF 'refs/heads/main' <<<"$block"
}

@test "rezept-verdrahtung: full-smoke rechnet den Baum-Hash am Lauf-Start und faehrt den Griff nur bei gesetzter Konsult-Umgebung (ADR-0111 Festlegung 2/4)" {
  local skript="$REPO/harness/tools/full-smoke.sh"
  # der Lauf-Start-Wert ist derselbe, den der Stempel am Gruen-Ende traegt
  grep -qF 'E2E_BAUM_HASH_START="$(bash "$HIER/working-tree-hash.sh")"' "$skript"
  # der Griff hoert auf GENAU die eine Lesung (gezaehlt ausserhalb der Kommentare);
  # jede andere Umgebung laeuft unberuehrt voll
  [ "$(grep -vE '^[[:space:]]*#' "$skript" | grep -cF 'FULL_SMOKE_SKIP_KONSULT')" -eq 1 ]
  grep -qF '[ "${FULL_SMOKE_SKIP_KONSULT:-}" = "1" ]' "$skript"
  grep -qF -- '--entscheide .harness/state/full-smoke-passed.key "$E2E_BAUM_HASH_START"' "$skript"
}

# --- die hermetische Klassifikation des Skip-Griffs (harness/tools/full-smoke-skip.sh,
# dieselbe --entscheide-Form wie test/gates-fastpfad.bats) -------------------

SKIP="$REPO/harness/tools/full-smoke-skip.sh"
STAPEL="$(mktemp)"

teardown() {
  [ -f "${STAPEL:-}" ] && rm -f "$STAPEL"
  return 0
}

H1="1111111111111111111111111111111111111111111111111111111111111111"
H2="2222222222222222222222222222222222222222222222222222222222222222"

@test "e2e-skip: deckender Stempel in der Zwei-Zeilen-Form -> SKIP, Meldung nennt Rest und Konservierungs-Form" {
  printf 'baum-hash %s\nvarianten 24\n' "$H1" > "$STAPEL"
  run bash "$SKIP" --entscheide "$STAPEL" "$H1"
  [ "$status" -eq 0 ]
  [[ "$output" == *"SKIP"* ]]
  [[ "$output" == *"Traeger-Releases"* ]]
  [[ "$output" == *"Runner-Fassung"* ]]
  [[ "$output" == *"Runner-Verdikt"* ]]
}

@test "e2e-skip: fehlender Stempel -> voller Lauf (fail-closed)" {
  run bash "$SKIP" --entscheide "$STAPEL" "$H1"
  [ "$status" -eq 1 ]
}

@test "e2e-skip: baum-hash fehlt in der Zwei-Zeilen-Form -> voller Lauf (fail-closed)" {
  printf 'varianten 24\n' > "$STAPEL"
  run bash "$SKIP" --entscheide "$STAPEL" "$H1"
  [ "$status" -eq 1 ]
}

@test "e2e-skip: unformaler baum-hash -> voller Lauf (fail-closed, MR-017)" {
  printf 'baum-hash %s\nvarianten 24\n' "${H1:0:40}" > "$STAPEL"
  run bash "$SKIP" --entscheide "$STAPEL" "$H1"
  [ "$status" -eq 1 ]
}

@test "e2e-skip: fremder baum-hash -> voller Lauf (fail-closed)" {
  printf 'baum-hash %s\nvarianten 24\n' "$H2" > "$STAPEL"
  run bash "$SKIP" --entscheide "$STAPEL" "$H1"
  [ "$status" -eq 1 ]
}

@test "e2e-skip: unformale Frisch-Rechnung -> voller Lauf (fail-closed)" {
  printf 'baum-hash %s\n' "$H1" > "$STAPEL"
  run bash "$SKIP" --entscheide "$STAPEL" "fremd"
  [ "$status" -eq 1 ]
}

@test "e2e-skip: fremde Aufruf-Form -> Exit 2" {
  run bash "$SKIP" --entscheide "$STAPEL"
  [ "$status" -eq 2 ]
  run bash "$SKIP"
  [ "$status" -eq 2 ]
}
