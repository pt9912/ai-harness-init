#!/usr/bin/env bash
# stop-require-gates — das Handoff-Gate am Stop von Claude Code (ADR-0083). Nutzt
# dieselbe inhaltsbasierte Hash-Funktion wie record-gates (keine Logik-Dopplung; harness/conventions.md MR-002/MR-003).
#
# DEFAULT — BINDUNG AN DEN COMMIT. Der Hook blockiert nur, wenn BEIDES gilt: HEAD ist
# ein anderer als der, den der letzte grüne `make gates`-Lauf gestempelt hat
# (.harness/state/gates-passed.head), UND der Inhalts-Hash des Arbeitsbaums weicht vom
# Nachweis ab (.harness/state/gates-passed.diffsha). Ein Turn-Ende ohne neuen HEAD geht
# frei, auch mit ungedeckter Änderung; ein Commit, dessen Inhalt der letzte grüne Lauf
# deckt, ebenso.
#
# MISCHFORM (ADR-0108 Festlegung 5) — die je-Check-Deckung tritt NEBEN die zwei
# Kanten der Fassung oben: Ein Turn-Ende, das nach der HEAD-Kante über der Hash-
# Gleichheit freiginge, blockt zusätzlich, wenn ein je-Check-Key
# (.harness/state/gates-passed-<check>.key) den Prüfgegenstand nicht deckt — die
# Satzerzeuger-Formen liest der Hook über denselben Aufruf wie den Fast-Pfad
# (harness/tools/gates-keys.sh, EINE Definition, keine zweite). Fail-closed in beide
# Richtungen: fehlender oder unformaler Key und Satzerzeuger-Fehler blocken. Die
# zweite Kante wird dort gelesen, wo die ADR-0083-Fassung ohnehin urteilt; die zwei
# Ablagen liegen in derselben .harness/state/-Klasse — der Record-Konsum rotiert nichts
# (ADR-0103): der Commit, der allein .harness/stamp/mutate/ bewegt, bleibt über der
# Hash-Gleichheit frei, und kein je-Check-Key rotiert mit.
#
# STRENG — jedes Turn-Ende mit ungedecktem Inhalt blockiert —, wenn die Datei
# .harness/stop-gate-streng existiert (versioniert, Inhalt bedeutungslos; dieses
# Werkzeug schreibt und löscht sie nie) ODER STOP_GATE_STRENG genau `1` ist. Jeder
# andere Wert der Variablen sagt nichts und hebt die Datei nicht auf. Ohne HEAD-Stempel
# gilt ebenfalls der strenge Zweig, bis ein grüner Lauf ihn schreibt.
#
# FAIL-CLOSED. Jeder unerwartete Fehler endet mit Exit 2 (blockierend), nie mit einem
# anderen Code (Trap unten). Den HEAD-Wert ermittelt head_wert genauso wie
# record-gates.sh — Kopplung: beide Fassungen gleich halten.
#
# GRENZEN. Zugesagt ist "HEAD gleich geblieben", nicht "kein Commit": wer nach einem
# Commit auf die gestempelte SHA zurückgeht, kommt frei durch. Eine "fertig"-Meldung
# ohne neuen HEAD geht ohne Gate-Lauf durch; das Netz dort ist CI auf dem Push. Ein
# frischer Klon ohne Nachweis und mit sauberem Baum geht frei (kein Nachweis prüfbar) —
# die je-Check-Deckung wird in diesem Zweig nicht gelesen, es gibt keinen Fundort
# dafür; die Mischform hält exakt den ADR-0083-Zweig, der auch der Tier-1 hat.
set -euo pipefail
rc=0
trap 'rc=$?; [ "$rc" -eq 0 ] || exit 2' EXIT
cd "$(git rev-parse --show-toplevel)"

state_file=".harness/state/gates-passed.diffsha"
head_file=".harness/state/gates-passed.head"

approve() {
  printf '%s\n' '{"decision":"approve"}'
  exit 0
}

block() {
  printf '{\n  "decision": "block",\n  "reason": "%s"\n}\n' "$1"
  exit 0
}

# head_wert — die aufgelöste SHA von HEAD; `kein-commit` nur auf einem ungeborenen
# Zweig in einem Repo ohne einzigen Commit; jede andere Lage ist ein Git-Fehler (Exit 1).
head_wert() {
  local sha alle
  if sha="$(git rev-parse --verify -q HEAD)"; then
    printf '%s\n' "$sha"
    return 0
  fi
  git symbolic-ref -q HEAD >/dev/null || return 1
  alle="$(git rev-list -n1 --all)" || return 1
  [ -z "$alle" ] || return 1
  printf '%s\n' kein-commit
}

# je_check_nicht_gedeckt — die Mischform-Kante (ADR-0108 Festlegung 5). Liest je Check
# der Kante seinen Key-Stempel und vergleicht ihn gegen den Satzerzeuger; druckt die
# nicht deckenden Checks (mit ihrer Klasse) zeilenweise auf stdout. Exit 0 heißt:
# ALLE decken (die Mischform gibt frei). Exit 1 heißt: mindestens einer deckt nicht —
# fehlender, unformaler oder gedrifteter Key wie Satzerzeuger-Fehler, alle blocken.
je_check_nicht_gedeckt() {
  local check stamp ist drifts="" fehler=0
  local checks
  if ! checks="$(bash harness/tools/gates-keys.sh liste 2>/dev/null)"; then
    printf '%s\n' "Satzerzeuger: die Kanten-Checks sind nicht lesbar"
    return 1
  fi
  while IFS= read -r check; do
    [ -n "$check" ] || continue
    stamp="$(cat ".harness/state/gates-passed-${check}.key" 2>/dev/null || true)"
    if ! ist="$(bash harness/tools/gates-keys.sh key "$check" 2>/dev/null)"; then
      drifts="${drifts}${check} — Satzerzeuger-Fehler"$'\n'
      fehler=1
      continue
    fi
    if [ "$stamp" != "$ist" ]; then
      drifts="${drifts}${check} — Key fehlt, unformal oder gedriftet"$'\n'
      fehler=1
    fi
  done <<<"$checks"
  if [ "$fehler" -eq 0 ]; then return 0; fi
  printf '%s' "$drifts"
  return 1
}

# mischform_gedeckt — die Deckungs-Alternative der Mischform (ADR-0108 Festlegung 5):
# ALLE je-Check-Keys decken UND der Bauch liegt ganz in der Tafel-Vereinigung; ein
# Rest ausserhalb jeder Menge entzieht der Alternative die Basis und fuehrt fail-
# closed (MR-017) zum vollen Lauf. Exit 0 = gedeckt, Exit 1 = nicht gedeckt.
mischform_gedeckt() {
  je_check_nicht_gedeckt >/dev/null 2>&1 || return 1
  bash harness/tools/gates-keys.sh rest >/dev/null 2>&1
}

# Schleifen-Schutz: Hat dieser Hook den Stop bereits einmal blockiert
# (stop_hook_active), nicht erneut blockieren — sonst Endlosschleife bei
# dauerhaft rotem Gate.
input="$(cat || true)"
if grep -q '"stop_hook_active"[[:space:]]*:[[:space:]]*true' <<<"$input"; then
  approve
fi

# TEMPORÄRE AUSSETZUNG (Auftraggeber-Beschluss 2026-11-27, bis welle-ohne-docker
# geschlossen ist): Die Gates fahren im gepinnten Docker-Image; mit ausgeschaltetem
# Daemon blockt sonst jedes Turn-Ende mit Arbeitsbaum-Änderung. Existiert die Datei
# .harness/state/stop-gate-ausgesetzt (nicht-committete .harness/state/-Klasse),
# gibt dieser Hook frei UND sagt es — in keinem anderen Zweig verhält er sich anders.
# Die Aussetzung ist lokal und endet mit dem Löschen der Datei; das Netz dort bleibt
# CI auf dem Push (ADR-0083).
if [ -e .harness/state/stop-gate-ausgesetzt ]; then
  printf '%s\n' "stop-gate: AUSGESETZT (.harness/state/stop-gate-ausgesetzt) — der Inhalt ist NICHT durch einen make gates-Lauf gedeckt und wird nicht verdeckt; Ende mit dem Schliessen von welle-ohne-docker." >&2
  approve
fi

current_head="$(head_wert)"

streng=0
if [ -e .harness/stop-gate-streng ]; then streng=1; fi
if [ "${STOP_GATE_STRENG:-}" = 1 ]; then streng=1; fi

if [ "$streng" -eq 0 ] && [ -e "$head_file" ]; then
  recorded_head="$(cat "$head_file")"
  if [ "$current_head" = "$recorded_head" ]; then
    # ADR-0108 Festlegung 5: auch über HEAD-Gleichheit erst die je-Check-Deckung.
    if mischform_gedeckt; then approve; fi
    if nicht_gedeckt="$(je_check_nicht_gedeckt)"; then
      block "HEAD unchanged: the per-check keys cover their sets, but files outside every declared Menge leave the coverage basis incomplete. Run \`make record-gates\` again (fail-closed, ADR-0108)."
    fi
    block "HEAD unchanged, but per-check gate keys do not cover the working tree (ADR-0108). Run \`make gates\` again. Not covered: ${nicht_gedeckt//$'\n'/; }"
  fi
fi

if [ ! -f "$state_file" ]; then
  status="$(git status --porcelain=v1)"
  # Frischer Klon ohne lokale Änderungen: kein Nachweis prüfbar.
  if [ -z "$status" ]; then approve; fi
  block "There are working tree changes, but no recorded successful make gates run. Run \`make gates\`."
fi

current="$(bash harness/tools/working-tree-hash.sh)"
recorded="$(cat "$state_file")"

if [ "$current" != "$recorded" ]; then
  # Mischform: ist die Hash-Kante offen, deckt die je-Check-Deckung statt — genau der
  # Teil, den der letzte Fast-Pfad-Lauf nach den gedrifteten Checks nachgestempelt
  # hat (ADR-0108 Festlegung 5). Fehlt, unformal oder driftet ein Key, blockt.
  if mischform_gedeckt; then approve; fi
  if nicht_gedeckt="$(je_check_nicht_gedeckt)"; then
    block "Repo content is not covered by the last recorded gates run: the per-check keys cover their sets, but files outside every declared Menge leave the coverage basis incomplete. Run \`make record-gates\` again (fail-closed, ADR-0108)."
  fi
  block "Repo content is not covered by the last recorded gates run, and the per-check gate keys do not cover it either (a new HEAD without a gates run, or strict mode via .harness/stop-gate-streng / STOP_GATE_STRENG=1). Run \`make gates\` again. Not covered: ${nicht_gedeckt//$'\n'/; }"
fi

approve

