#!/usr/bin/env bash
# hook-overhead.sh — misst den Aufschlag je Tool-Call, den der Hook dieses Repos
# kostet: die Wanduhr-Zeit EINES Aufrufs des Traegers, von seinem Start bis zu seinem
# Ende. Das ist die Zeit, die das Agenten-Werkzeug nach jedem Tool-Call wartet.
#
# EINE MESSUNG, KEIN GATE. Das Ziel `make hook-overhead` steht in keiner Gate-Kette und
# faerbt nichts rot: ein Latenz-Gate misst auf einem geteilten Runner die Auslastung des
# Nachbarn mit — es waere rot ohne Befund und gruen ohne Deckung. Verbindlich ist die
# Messung durch ADR-0022 Folgepflicht 9, gegen die Schwelle aus ADR-0011 (50 ms im
# Median je Tool-Call).
#
# WAS GEMESSEN WIRD, GENAU: der Prozess des Traegers — nicht der Tool-Call, den er
# beobachtet. Die zwei sind verschiedene Gegenstaende: die Laufzeit eines `make gates`
# sagt ueber den Aufschlag nichts.
#
# DIE FOLGE IST ECHT, DIE PAYLOAD IST NACHGEBAUT. Ereignis-Art, Werkzeug-Mischung,
# Reihenfolge und Ergebnis-GROESSE stammen aus einem realen Strom unter
# .harness/state/spans/ — der Emitter liest die Ergebnis-Groesse als Laenge des rohen
# `tool_response`, und die traegt jeder Span als `result_bytes`. Nachgebaut, weil der
# Span sie nicht traegt, sind:
#   * der KOMMANDO-TEXT — der Span haelt `program` und `argc` fest, nicht die Zeile
#     (ADR-0011 Festlegung 2). Ersetzt durch `program` plus argc kurze Platzhalter:
#     die Feld-ZAHL stimmt, die Zeilen-LAENGE nicht.
#   * der INHALT des Ergebnisses — ersetzt durch Fuellzeichen exakt der gemessenen
#     Laenge. Fuer den Parser ist das eine JSON-Zeichenkette derselben Groesse; die
#     Positiv-Liste aus internal/span/response.go greift darin auf nichts zu.
# Was daraus folgt, gilt fuer beide Richtungen: eine echte `Agent`-Payload kostet etwas
# mehr (dort laeuft die Positiv-Liste ueber ein Objekt), eine echte `Bash`-Payload mit
# langer Kommandozeile ebenfalls. Die Zahl unten ist damit eine UNTERGRENZE fuer die
# Payload-Achse, keine Rundum-Aussage.
#
# WAS DER MESSWERT SONST NOCH TRAEGT: der Emitter liest bei jedem Aufruf den Repo-
# Zustand (internal/span/emit.go, correlation() ueber
# docs/plan/planning/in-progress/slice-*.md und gitRef() ueber .git). Wie viele Slices
# dort liegen, geht in die Zahl ein — die Ausgabe nennt es deshalb mit.
#
# EIGENER STROM, wie in span-check.sh und aus demselben Grund: die Messung schreibt
# echte Spans, und sie sollen keinen Sitzungs-Strom anfassen. Der Name traegt die PID,
# die drei Artefakte raeumt der EXIT-trap weg.
#
# GEMESSEN AM 2026-08-25 — der Stand, den ADR-0022 Folgepflicht 9 schuldet. KEIN
# ERWARTUNGSWERT: die Zahl gilt dem Host, auf dem sie entstand, und ein anderer Host
# liefert eine andere. Bedingungen: Linux x86_64, 20 Kerne, loadavg 1.5 bis 3.8 — der
# Host war nie ausgelastet. Quelle war der zeilenreichste Strom mit 815 Spans, je Zeile
# ein Aufruf; NEUN Laeufe je Programm (sieben a 200 Aufrufe, zwei a 815), die zwei
# Programme abwechselnd gefahren, damit Hintergrund-Last nicht auf eine Seite faellt.
#
#   SPAN_SOURCE=<strom> make hook-overhead
#     -> der Traeger, 7561376 Byte: Median 2.7 bis 2.8 ms; p90 3.0 bis 4.0 ms;
#        p99 3.3 bis 4.5 ms; max 3.7 bis 10.1 ms
#
#   SPAN_SOURCE=<strom> HOOK_OVERHEAD_CMD=<baum>/.harness/state/bin/span-emit make hook-overhead
#     -> der Vergleichspunkt, 3199136 Byte: der GETRENNTE Emitter, der lief, bevor
#        Schreiber und Auswertung Unterkommandos des Traegers wurden. Gebaut mit
#        `git worktree add --detach <baum> d686787 && make -C <baum> span-emit-build`.
#        Median 2.3 bis 2.5 ms; p90 2.5 bis 3.9 ms; p99 3.0 bis 4.4 ms; max 3.1 bis 9.5 ms
#
# Der Umbau auf den einen Traeger kostet damit rund 0.3 ms je Tool-Call, waehrend das
# Programm um Faktor 2.4 waechst (7561376 / 3199136). Der Median liegt bei beiden um
# mehr als Faktor 17 unter den 50 ms aus ADR-0011, und selbst der groesste gesehene
# Einzelwert — 10.1 ms — bleibt unter einem Viertel der Schwelle.
#
# DIE SCHLEIFE OBEN RUFT DICHT AUF, DER HOOK NICHT: im Betrieb liegen Sekunden zwischen
# zwei Tool-Calls, und der Traeger findet den Seiten-Cache dann nicht so warm vor. Dafuer
# der EINZEL-Aufruf, zehnmal mit Pause und unter echter Last (loadavg 6.6 bis 9.9,
# paralleler `make mutate`):
#
#   for i in $(seq 1 10); do SAMPLES=1 SPAN_SOURCE=<strom> make hook-overhead; sleep 3; done
#     -> 2.5 2.7 2.6 3.4 3.6 2.8 3.5 3.5 3.5 3.8 ms (die Zeile "erster Aufruf");
#        Median 3.4 ms, groesster Wert 3.8 ms — auch das mehr als Faktor 13 unter der
#        Schwelle.
#
# WAS DAS NICHT SAGT: was ein Adopter-Host kostet — dort laeuft dasselbe Programm auf
# fremder Hardware — und was ein bis zur Saettigung ausgelasteter Runner kostet; loadavg
# 9.9 auf 20 Kernen ist Last, keine Saettigung.
set -euo pipefail

# LC_ALL=C ist hier tragend, nicht Hygiene: EPOCHREALTIME traegt den Dezimaltrenner der
# LOCALE. Auf einem de_DE-Host liefert es `1787658745,377743`, und die Ersetzung unten
# sucht einen Punkt, der dort nicht steht. Das Komma bleibt stehen und wird in der
# Shell-Arithmetik zum Komma-OPERATOR: der Ausdruck liefert dann still das
# Mikrosekunden-Feld von t0 als angebliche Differenz. Gemessen ueber einem `sleep 0.05`:
# 377743 statt 50907 — eine Zahl, die plausibel aussieht und nichts misst.
export LC_ALL=C

usage() {
	cat >&2 <<'EOF'
Aufruf: hook-overhead.sh <programm> [<argument>...]
  z. B. hook-overhead.sh .harness/state/bin/ai-harness-init span-emit

Umgebung:
  SPAN_SOURCE  Strom-Datei mit echten Spans (Default: die zeilenreichste unter
               .harness/state/spans/)
  SAMPLES      Zahl der gemessenen Aufrufe (Default 200)
EOF
	exit 2
}

[ "$#" -ge 1 ] || usage
[ -x "$1" ] || {
	echo "hook-overhead: BEFUND — kein ausfuehrbares Programm: $1 (make host-bin)" >&2
	exit 1
}

cd "$(git rev-parse --show-toplevel)"

SAMPLES="${SAMPLES:-200}"
SPANS_DIR=.harness/state/spans

# Quelle waehlen: die zeilenreichste Strom-Datei ist der laengste reale Lauf, den dieser
# Baum kennt. Ohne Bestand bricht die Messung ab, statt eine Folge zu erfinden — eine
# erfundene Folge haette eine Verteilung, die niemand kennt, und die Zahl darueber waere
# eine Genauigkeit, die es nicht gibt.
#
# Je Datei EIN `wc -l < datei` statt eines `wc -l` ueber den Glob: dessen Summenzeile
# traegt ein uebersetztes Wort ("total"/"insgesamt") und muesste weggefiltert werden.
source_file="${SPAN_SOURCE:-}"
if [ -z "$source_file" ]; then
	source_file="$(for f in "$SPANS_DIR"/*.jsonl; do
		[ -f "$f" ] || continue
		printf '%s %s\n' "$(wc -l < "$f")" "$f"
	done | sort -rn | head -1 | cut -d' ' -f2-)"
fi
[ -n "$source_file" ] && [ -s "$source_file" ] || {
	echo "hook-overhead: BEFUND — kein Span-Bestand unter $SPANS_DIR/ (SPAN_SOURCE=<datei>)." >&2
	echo "hook-overhead: Die Folge kommt aus einem REALEN Lauf; ohne Bestand gibt es keine zu messen." >&2
	exit 1
}

stream="hookoverhead$$"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp" "$SPANS_DIR/$stream.jsonl" "$SPANS_DIR/$stream.seq" "$SPANS_DIR/.$stream.lock"' EXIT

# --- Payload-Folge aus den echten Spans bauen --------------------------------
# Die Zeichenketten werden RAW aus der Span-Zeile uebernommen, zwischen ihren
# Anfuehrungszeichen heraus und zwischen neue hinein: die Quelle ist gueltiges JSON,
# also ist der Ausschnitt bereits korrekt maskiert.
awk -v out="$tmp" -v stream="$stream" -v n="$SAMPLES" '
function field(key,   pat) {
	pat = "\"" key "\":\"[^\"]*\""
	if (!match($0, pat)) return ""
	return substr($0, RSTART + length(key) + 4, RLENGTH - length(key) - 5)
}
function number(key,   pat) {
	pat = "\"" key "\":-?[0-9]+"
	if (!match($0, pat)) return ""
	return substr($0, RSTART + length(key) + 3, RLENGTH - length(key) - 3)
}
NR > n { exit }
{
	event = field("event"); tool = field("tool"); tuid = field("tool_use_id")
	path = field("path");   prog = field("program")
	argc = number("argc");  dur = number("duration_ms"); rb = number("result_bytes")

	input = "{}"
	if (path != "") input = "{\"file_path\":\"" path "\"}"
	else if (prog != "") {
		cmd = prog
		for (i = 0; i < argc + 0; i++) cmd = cmd " a"
		input = "{\"command\":\"" cmd "\"}"
	}

	line = "{\"hook_event_name\":\"" event "\",\"tool_name\":\"" tool "\"" \
	       ",\"tool_use_id\":\"" tuid "\",\"session_id\":\"" stream "\"" \
	       ",\"tool_input\":" input
	if (dur != "") line = line ",\"duration_ms\":" dur
	# Der rohe `tool_response` misst inklusive seiner zwei Anfuehrungszeichen; die
	# Fuellung ist entsprechend zwei Zeichen kuerzer. Unter 3 Byte gibt es nichts zu
	# fuellen — dann bleibt das Feld weg.
	if (rb + 0 > 2) line = line ",\"tool_response\":\"" sprintf("%*s", rb - 2, "") "\""
	line = line "}"

	file = sprintf("%s/%06d.payload", out, NR)
	print line > file
	close(file)
	count++
}
END { print count }
' "$source_file" > "$tmp/count"

built="$(cat "$tmp/count")"
[ "${built:-0}" -gt 0 ] || {
	echo "hook-overhead: BEFUND — aus $source_file entstand keine Payload." >&2
	exit 1
}

# --- Messen ------------------------------------------------------------------
# Kein Fork zwischen den zwei Zeitnahmen: EPOCHREALTIME ist eine Shell-Variable, `date`
# waere ein Prozess-Start und laege damit in derselben Groessenordnung wie der
# Gegenstand der Messung. Der Punkt faellt per Ersetzung heraus, gerechnet wird in
# ganzen Mikrosekunden.
#
# stdout und stderr des Traegers laufen in Dateien statt in eine Kommando-Substitution:
# eine Substitution kostet eine Subshell je Aufruf. Was dort landet, prueft die Ausgabe
# unten — stdout ist bei Hooks der Entscheidungs-Kanal (ADR-0011 Festlegung 6).
us_list="$tmp/us"
: > "$us_list"
worst_rc=0
for payload in "$tmp"/*.payload; do
	t0=$EPOCHREALTIME
	rc=0
	"$@" < "$payload" >> "$tmp/stdout" 2>> "$tmp/stderr" || rc=$?
	t1=$EPOCHREALTIME
	[ "$rc" -eq 0 ] || worst_rc="$rc"
	echo "$(( ${t1/./} - ${t0/./} ))" >> "$us_list"
done

if [ "$worst_rc" -ne 0 ]; then
	echo "hook-overhead: BEFUND — der Traeger endete mindestens einmal mit Exit $worst_rc;" >&2
	echo "hook-overhead: eine Zeitmessung ueber einem fehlschlagenden Lauf misst den Fehlschlag." >&2
	exit 1
fi

[ ! -s "$tmp/stdout" ] || {
	echo "hook-overhead: BEFUND — der Traeger schrieb auf stdout (dort liegt der Entscheidungs-Kanal)." >&2
	exit 1
}

written="$(wc -l < "$SPANS_DIR/$stream.jsonl" 2>/dev/null || echo 0)"

# --- Auswerten ---------------------------------------------------------------
# Quantile nach nearest-rank ueber der sortierten Liste: der Wert an Rang ceil(p*n),
# nicht ein interpolierter Zwischenwert. Bei geradem n faellt der Median damit auf den
# UNTEREN der zwei mittleren Werte (gemessen ueber 1 2 3 4: q(0.5) = 2). Der Unterschied
# zum Mittel der beiden liegt hier bei Bruchteilen einer Millisekunde und weit unter der
# Streuung, die die Ausgabe unten ohnehin mitnennt.
quant="$(sort -n "$us_list" | awk '
{ v[NR] = $1 }
function q(p,   r) { r = int(NR * p); if (r < NR * p) r++; if (r < 1) r = 1; return v[r] }
END { printf "%d %d %d %d %d %d\n", v[1], q(0.5), q(0.9), q(0.99), v[NR], NR }
')"
read -r v_min v_p50 v_p90 v_p99 v_max v_n <<<"$quant"
first="$(head -1 "$us_list")"

ms() { awk -v us="$1" 'BEGIN { printf "%.1f", us / 1000 }'; }

in_progress="$(find docs/plan/planning/in-progress -name 'slice-*.md' 2>/dev/null | wc -l)"

cat <<EOF
hook-overhead: $* — $(ms "$v_p50") ms im Median je Tool-Call

  Gemessen        : Wanduhr-Zeit EINES Traeger-Aufrufs (nicht des Tool-Calls)
  Programm        : $*
  Groesse         : $(wc -c < "$1") Byte
  Quelle          : $source_file
  Payloads        : $built gebaut, $v_n gemessen, $written Spans geschrieben
  Slices im Bezug : $in_progress unter docs/plan/planning/in-progress/
  Host            : $(uname -s -m), $(getconf _NPROCESSORS_ONLN) Kerne, loadavg $(cut -d' ' -f1-3 /proc/loadavg 2>/dev/null || echo n/a)

  erster Aufruf   : $(ms "$first") ms   (kalt: Seiten-Cache und Strom noch leer)
  min             : $(ms "$v_min") ms
  Median (p50)    : $(ms "$v_p50") ms
  p90             : $(ms "$v_p90") ms
  p99             : $(ms "$v_p99") ms
  max             : $(ms "$v_max") ms
EOF
