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
# WAS ES ZUSICHERT, GENAU. Einzeln gefahren (`make span-check`) meldet es einen
# fehlenden Emitter rot — das ist der Fehlt-Fall. In `make gates` steht
# `span-emit-build` als eigenes Glied DAVOR; die Zusicherung dort lautet also: nach
# einem Gate-Lauf ist der Emitter vorhanden UND belegt funktionsfaehig. Sie lautet
# NICHT "ein Gate-Lauf meldet den fehlenden Emitter" — das kann er nicht, weil er ihn
# unmittelbar vorher baut. Die frueher hier stehende Fassung liess das Gate von seinem
# eigenen Bau abhaengen und behauptete trotzdem das Melden (Review-Befund MEDIUM-1).
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
#      GRENZE, benannt statt verschwiegen: diese dritte Pruefung ist selbst UNBEWACHT.
#      Ein Mutations-Fall kann sie nicht fangen, weil das ENTFERNEN einer Pruefung den
#      Gate GRUEN laesst, nicht rot — Mutation misst, ob ein Waechter Zaehne hat, nicht
#      ob er existiert. Fall 113 faerbt `TestSpansLandInStateDir` rot und deckt damit
#      die Code-Haelfte; die `git check-ignore`-Haelfte haengt an dieser Datei allein
#      (Review Runde 2 zu HIGH-4). Ein echter Waechter braeuchte einen Lauf gegen ein
#      Repo, dessen .gitignore den Ablageort NICHT deckt — Kandidat, kein Bestand.
#
# PLATTFORM: der Emitter wird FUER DEN HOST gebaut (`make span-emit-build` leitet
# GOOS/GOARCH aus `uname` ab und reicht sie ins gepinnte Linux-Image). Eine fruehere
# Fassung baute ohne die Schalter, erzeugte also immer ein Linux-ELF, und dieses Gate
# waere auf einem macOS-Host mit "exec format error" rot gewesen — ohne inhaltlichen
# Defekt (Review-Befund MEDIUM-2). Die Meldung unten nennt diesen Fall trotzdem
# ausdruecklich: bleibt eine Plattform-Kombination uebrig, soll der Lauf nicht raten.
#
# GEMESSEN am 2026-07-29, weil "die Schalter sind gesetzt" auf einem Linux-Host nichts
# beweist — mit und ohne sie entsteht dort dasselbe Binary:
#   Host-Bau                      -> 7f 45 4c 46  (ELF, Linux)
#   TARGET_OS=darwin ARCH=arm64   -> cf fa ed fe  (Mach-O, macOS)
#   dieses Skript auf das darwin-Binary -> BEFUND "Exit 126 ... andere Plattform"
# Der letzte Punkt ist das rot gesehene Gegenbeispiel zum Zweig unten. Was er NICHT
# ist: ein dauerhafter Waechter — auf einem Linux-Host kann keine Mutation den Zweig
# erreichen, weil dort jeder Bau lauffaehig ist. Einmalig gemessen, nicht bewacht.
set -euo pipefail

BIN="${1:-}"
[ -n "$BIN" ] || { echo "span-check: Aufruf: span-check.sh <pfad-zum-emitter>" >&2; exit 2; }

cd "$(git rev-parse --show-toplevel)"

fail() { echo "span-check: BEFUND — $*" >&2; exit 1; }

# --- 1. Vorhanden ------------------------------------------------------------
[ -x "$BIN" ] || fail "der Emitter fehlt oder ist nicht ausfuehrbar: $BIN (make span-emit-build)"

# --- 2. Funktionsfaehig ------------------------------------------------------
# Eigener Strom-Name, damit der Gate-Lauf keinen echten Sitzungs-Strom anfasst.
# OHNE `-`: der Emitter schreibt den Trenner zwischen Sitzung und Agent zu `_` um,
# damit zwei verschiedene Paare nie denselben Strom bekommen (MR-018/LOW-7). Ein
# `span-check-$$` landete deshalb als `span_check_$$.jsonl` — der Gate suchte am
# falschen Pfad und meldete "kein Span geschrieben". Genau dafuer ist er da: er misst
# den REAL geschriebenen Ablageort, nicht den erwarteten.
stream="spancheck$$"
payload="{\"hook_event_name\":\"PostToolUse\",\"tool_name\":\"Bash\",\"tool_use_id\":\"tu_gate\",\"session_id\":\"$stream\",\"tool_input\":{\"command\":\"make gates\"}}"

file=".harness/state/spans/$stream.jsonl"
trap 'rm -f "$file" ".harness/state/spans/$stream.seq"' EXIT

# Here-String statt Pipe: schluepft der Emitter vor dem Lesen heraus, kostete eine
# Pipe unter `pipefail` ein EPIPE und damit eine irrefuehrende Fehlermeldung.
rc=0
out="$("$BIN" <<<"$payload")" || rc=$?
if [ "$rc" = 126 ]; then
  fail "der Emitter laesst sich nicht ausfuehren (Exit 126) — gebaut fuer eine andere Plattform als diesen Host? '$(uname -s)/$(uname -m)'"
elif [ "$rc" != 0 ]; then
  fail "der Emitter endete mit Exit $rc (ein Hook blockt damit den Tool-Call)"
fi
[ -z "$out" ] || fail "der Emitter schrieb auf stdout — dort liegt der Entscheidungs-Kanal: $out"

[ -s "$file" ] || fail "kein Span geschrieben ($file fehlt oder ist leer)"

# Die VOLLE Pflicht-Spalte aus MR-018, nicht eine Auswahl. Die Vorgaenger-Fassung
# pruefte 7 von 14 — und es fehlten ausgerechnet die vier, die derselbe Commit
# einfuehrte oder rettete (`agent_role`, `adr`, `branch`, `commit`). Damit haette
# dieselbe Klasse, die als HIGH-2 im Code gefunden wurde, an der zweiten Sensorstelle
# unbemerkt weitergelebt (Review Runde 2, MEDIUM-2).
line="$(cat "$file")"
for feld in '"seq":1' '"ts":' '"event":' '"tool":"Bash"' '"tool_use_id":"tu_gate"' \
            '"session":' '"agent":' '"agent_type":' '"agent_role":' '"slice":' '"requirement":' \
            '"adr":' '"branch":' '"commit":' '"status":"ok"' '"program":"make"'; do
  grep -qF "$feld" <<<"$line" || fail "Pflichtfeld fehlt im Span: $feld — $line"
done

# --- 3. Der geschriebene Pfad ist ignoriert ----------------------------------
git check-ignore -q "$file" ||
  fail "der Span liegt im GETRACKTEN Baum ($file) — jeder Tool-Call verschoebe den working-tree-hash"

echo "span-check: Emitter vorhanden, ein Span geschrieben, Ablageort git-ignoriert"
