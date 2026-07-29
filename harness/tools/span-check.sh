#!/usr/bin/env bash
# span-check.sh — Gate zum FEHLT-FALL der Telemetrie-Erfassung (slice-059).
#
# WARUM ES DIESES GATE GIBT. Der Emitter ist ein KOMPILIERTES Artefakt, und ein
# solches kann fehlen — auf einem frischen Checkout, nach `make clean`, nach einem
# Wechsel der Plattform. Dann entsteht GAR KEIN Strom, und genau das sieht die
# Folgenummer prinzipiell nicht: sie macht Luecken sichtbar, indem eine Nummer
# beansprucht und die Zeile dann vermisst wird — wo nie ein Emitter lief, wird auch
# nie eine beansprucht. Der stille TOTALausfall ist damit schlimmer als der
# Teilverlust, gegen den die Nummern eingefuehrt wurden. Dieses Gate macht aus ihm
# ein rotes Gate.
#
# ES PRUEFT DREI DINGE, und das dritte ist der Grund, warum es hier und nicht in
# einem Go-Test steht:
#   1. Das Binary ist da und ausfuehrbar.
#   2. Es erzeugt fuer eine synthetische Payload einen Span mit den Pflichtfeldern,
#      endet mit 0 und schreibt nichts auf stdout (ADR-0011 Festlegung 6).
#   3. Der real geschriebene Pfad ist von git IGNORIERT — gemessen mit
#      `git check-ignore` am echten Repo, nicht an einer Textstelle. Ein Span im
#      getrackten Baum verschoebe den working-tree-hash bei jedem Tool-Call, und der
#      Stop-Hook blockierte sich selbst (MR-003, Review-Befund MEDIUM-4). Die andere
#      Haelfte dieser Eigenschaft — dass der Emitter nur dorthin schreibt — misst
#      TestSpansLandInStateDir.
#
# PLATTFORM: das Binary kommt aus dem gepinnten Linux-Build-Image; auf einem
# Nicht-Linux-Host laeuft es nicht. Dieselbe Grenze wie bei `make artifact` und den
# Smokes, hier nur benannt statt umgangen.
set -euo pipefail

BIN="${1:-}"
[ -n "$BIN" ] || { echo "span-check: Aufruf: span-check.sh <pfad-zum-emitter>" >&2; exit 2; }

cd "$(git rev-parse --show-toplevel)"

fail() { echo "span-check: BEFUND — $*" >&2; exit 1; }

# --- 1. Vorhanden ------------------------------------------------------------
[ -x "$BIN" ] || fail "der Emitter fehlt oder ist nicht ausfuehrbar: $BIN (make span-emit-build)"

# --- 2. Funktionsfaehig ------------------------------------------------------
# Eigener Strom-Name, damit der Gate-Lauf keinen echten Sitzungs-Strom anfasst.
stream="span-check-$$"
payload="{\"hook_event_name\":\"PostToolUse\",\"tool_name\":\"Bash\",\"tool_use_id\":\"tu_gate\",\"session_id\":\"$stream\",\"tool_input\":{\"command\":\"make gates\"}}"

file=".harness/state/spans/$stream.jsonl"
trap 'rm -f "$file" ".harness/state/spans/$stream.seq"' EXIT

# Here-String statt Pipe: schluepft der Emitter vor dem Lesen heraus, kostete eine
# Pipe unter `pipefail` ein EPIPE und damit eine irrefuehrende Fehlermeldung.
out="$("$BIN" <<<"$payload")" || fail "der Emitter endete mit Exit $? (ein Hook blockt damit den Tool-Call)"
[ -z "$out" ] || fail "der Emitter schrieb auf stdout — dort liegt der Entscheidungs-Kanal: $out"

[ -s "$file" ] || fail "kein Span geschrieben ($file fehlt oder ist leer)"

line="$(cat "$file")"
for feld in '"seq":1' '"tool":"Bash"' '"tool_use_id":"tu_gate"' '"status":"ok"' \
            '"slice":' '"requirement":' '"program":"make"'; do
  grep -qF "$feld" <<<"$line" || fail "Pflichtfeld fehlt im Span: $feld — $line"
done

# --- 3. Der geschriebene Pfad ist ignoriert ----------------------------------
git check-ignore -q "$file" ||
  fail "der Span liegt im GETRACKTEN Baum ($file) — jeder Tool-Call verschoebe den working-tree-hash"

echo "span-check: Emitter vorhanden, ein Span geschrieben, Ablageort git-ignoriert"
