#!/usr/bin/env bash
# span-check.sh — Gate zum FEHLT-FALL der Telemetrie-Erfassung (slice-059).
#
# WARUM ES DIESES GATE GIBT. Der Schreiber ist ein KOMPILIERTES Artefakt, und ein
# solches kann fehlen — auf einem frischen Checkout, nach `make clean`, nach einem
# Wechsel der Plattform. Dann entsteht GAR KEIN Strom, und genau das sieht die
# Folgenummer prinzipiell nicht: sie macht Luecken sichtbar, indem eine Nummer
# beansprucht und die Zeile dann vermisst wird — wo nie ein Schreiber lief, wird auch
# nie eine beansprucht. Der stille TOTALausfall ist damit schlimmer als der
# Teilverlust, gegen den die Nummern eingefuehrt wurden. Dieses Gate macht aus ihm
# ein rotes Gate.
#
# GEPRUEFT WIRD DER TRAEGER MIT SEINEM UNTERKOMMANDO. Der Schreiber ist
# `<traeger> span-emit` (ADR-0022 Festlegung 2) — derselbe Einstiegspunkt, den der Hook
# dieses Repos ruft und den ein Zielrepo bekommt. Das Argument ist deshalb der Pfad des
# TRAEGERS; das Unterkommando steht hier, weil es der Gegenstand der Pruefung ist und
# nicht die Wahl des Aufrufers.
#
# WAS ES ZUSICHERT, GENAU. Einzeln gefahren (`make span-check`) meldet es einen
# fehlenden Traeger rot — das ist der Fehlt-Fall. In `make gates` steht `host-bin` als
# eigenes Glied DAVOR; die Zusicherung dort lautet also: nach einem Gate-Lauf ist der
# Schreiber vorhanden UND belegt funktionsfaehig. Sie lautet NICHT "ein Gate-Lauf
# meldet den fehlenden Schreiber" — das kann er nicht, weil er ihn unmittelbar vorher
# baut. Die frueher hier stehende Fassung liess das Gate von seinem eigenen Bau
# abhaengen und behauptete trotzdem das Melden (Review-Befund MEDIUM-1).
#
# ES PRUEFT DREI DINGE, und das dritte ist der Grund, warum es hier und nicht in
# einem Go-Test steht:
#   1. Das Binary ist da und ausfuehrbar.
#   2. Sein Unterkommando `span-emit` erzeugt fuer eine synthetische Payload einen
#      Span mit den Pflichtfeldern, endet mit 0 und schreibt nichts auf stdout
#      (ADR-0011 Festlegung 6).
#   3. Der real geschriebene Pfad ist von git IGNORIERT — gemessen mit
#      `git check-ignore` am echten Repo, nicht an einer Textstelle. Ein Span im
#      getrackten Baum verschoebe den working-tree-hash bei jedem Tool-Call, und der
#      Stop-Hook blockierte sich selbst (MR-003, Review-Befund MEDIUM-4). Die andere
#      Haelfte dieser Eigenschaft — dass der Schreiber nur dorthin schreibt — misst
#      TestSpansLandInStateDir.
#      GRENZE, benannt statt verschwiegen: diese dritte Pruefung ist selbst UNBEWACHT.
#      Ein Mutations-Fall kann sie nicht fangen, weil das ENTFERNEN einer Pruefung den
#      Gate GRUEN laesst, nicht rot — Mutation misst, ob ein Waechter Zaehne hat, nicht
#      ob er existiert. Fall 113 faerbt `TestSpansLandInStateDir` rot und deckt damit
#      die Code-Haelfte; die `git check-ignore`-Haelfte haengt an dieser Datei allein
#      (Review Runde 2 zu HIGH-4). Ein echter Waechter braeuchte einen Lauf gegen ein
#      Repo, dessen .gitignore den Ablageort NICHT deckt — Kandidat, kein Bestand.
#
# PLATTFORM: der Traeger wird FUER DEN HOST gebaut (`make host-bin` leitet GOOS/GOARCH
# aus `uname` ab und reicht sie ins gepinnte Linux-Image). Eine fruehere Fassung baute
# ohne die Schalter, erzeugte also immer ein Linux-ELF, und dieses Gate waere auf einem
# macOS-Host mit "exec format error" rot gewesen — ohne inhaltlichen Defekt
# (Review-Befund MEDIUM-2). Die Meldung unten nennt diesen Fall trotzdem ausdruecklich:
# bleibt eine Plattform-Kombination uebrig, soll der Lauf nicht raten.
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
[ -n "$BIN" ] || { echo "span-check: Aufruf: span-check.sh <pfad-zum-traeger>" >&2; exit 2; }

cd "$(git rev-parse --show-toplevel)"

fail() { echo "span-check: BEFUND — $*" >&2; exit 1; }

# --- 1. Vorhanden ------------------------------------------------------------
[ -x "$BIN" ] || fail "der Traeger fehlt oder ist nicht ausfuehrbar: $BIN (make host-bin)"

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
# Alle DREI Artefakte, die der Emitter je Strom anlegt — Daten, Sequenz und Sperre
# (internal/span/emit.go). Die Sperre traegt einen fuehrenden Punkt.
#
# Die Sperre hier zu loeschen ist sicher, und zwar NUR weil der Strom-Name die PID
# traegt: die Loesch-Race, vor der emit.go warnt, setzt zwei Emitter auf DEMSELBEN
# Strom voraus (zwei Inodes unter einem Pfad), und diesen Strom kann kein zweiter
# Prozess haben. Wer den Namen konstant macht, muss diese Zeile zurueckbauen.
#
# GRENZE, benannt statt verschwiegen: dass der Gate-Lauf nichts hinterlaesst, ist
# UNBEWACHT. Der bats-Lauf mountet das Repo read-only (`make test-bats`), dieses
# Skript aber schreibt in den Zustands-Baum und ermittelt seinen Ort ueber
# `git rev-parse --show-toplevel` — ein Zahn braucht also ein eigenes Repo im
# Testlauf, nicht eine Zusatz-Zeile hier. Bis dahin haelt die Eigenschaft an dieser
# Zeile allein.
trap 'rm -f "$file" ".harness/state/spans/$stream.seq" ".harness/state/spans/.$stream.lock"' EXIT

# Here-String statt Pipe: schluepft der Emitter vor dem Lesen heraus, kostete eine
# Pipe unter `pipefail` ein EPIPE und damit eine irrefuehrende Fehlermeldung.
rc=0
out="$("$BIN" span-emit <<<"$payload")" || rc=$?
if [ "$rc" = 126 ]; then
  fail "der Traeger laesst sich nicht ausfuehren (Exit 126) — gebaut fuer eine andere Plattform als diesen Host? '$(uname -s)/$(uname -m)'"
elif [ "$rc" != 0 ]; then
  fail "der Traeger endete mit Exit $rc (ein Hook blockt damit den Tool-Call)"
fi
[ -z "$out" ] || fail "der Schreiber schrieb auf stdout — dort liegt der Entscheidungs-Kanal: $out"

[ -s "$file" ] || fail "kein Span geschrieben ($file fehlt oder ist leer)"

# Die VOLLE Pflicht-Spalte aus spec/spezifikation.md §5, nicht eine Auswahl. Die Vorgaenger-Fassung
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

echo "span-check: Traeger vorhanden, span-emit hat einen Span geschrieben, Ablageort git-ignoriert"
