#!/usr/bin/env bash
# comment-claims.sh — Gate zu AGENTS.md §3.6, eine Ebene unter den Tests.
#
# Ein Kommentar, der eine ABDECKUNG behauptet ("bewacht", "belegt", "garantiert",
# "verhindert", "stellt sicher", "sorgt dafuer"), muss den Sensor NENNEN, der sie
# traegt: einen Testnamen (Test…/@test/bats-Fall), ein make-Target, `full-smoke`,
# `smoke` oder `test/mutations`. Sonst faellt der Gate.
#
# Warum ueberhaupt: in slice-053 behauptete ein Kommentar, clang-tidy linte die
# Schicht-Header mit — gemessen liess ein Verstoss den Gate gruen. Der Kommentar war
# die einzige Stelle, an der die Zusage stand, und er trug sie nicht. Diese Klasse
# hat kein Test gefangen, weil sie unter der Test-Ebene liegt.
#
# Zwei Pruefungen, weil eine nicht reicht:
#   (a) Behauptung ohne Sensor-Nennung -> Befund.
#   (b) Genannter Testname existiert nicht -> Befund. Ohne (b) besteht eine ERFUNDENE
#       Nennung den Gate — real passiert, beim Bau dieses Skripts, vom Autor selbst
#       (zwei erfundene Testnamen in einem Zug).
# Was er weiterhin NICHT kann (benannt, nicht wegdefiniert): pruefen, ob der genannte
# Sensor die Behauptung inhaltlich TRAEGT. Das bleibt Review-Arbeit.
#
# Geprueft wird der Kommentar-BLOCK, nicht die Einzelzeile: die Behauptung darf in
# Zeile 3 stehen und der Testname in Zeile 5. Ein Block endet an der ersten
# Nicht-Kommentar-Zeile.
#
# ROH-STRING-AUSNAHME (der nicht-triviale Teil): Go-Dateien tragen emittierten Inhalt
# in `…`-Literalen — das sind Adopter-Artefakte, nicht unsere Zusagen. Zeilen innerhalb
# eines Roh-Strings werden uebersprungen; der Zustand haengt an der Backtick-Paritaet.
set -euo pipefail

CLAIM='garantiert|stellt sicher|bewacht|belegt|sorgt dafuer|sorgt dafür|verhindert'
# VERNEINUNG ist keine Behauptung: "ein gruener Gate belegt NICHT, dass er greift" ist die
# Warnung vor der Zusage, nicht die Zusage. Ohne diese Ausnahme roetet der Gate genau die
# Kommentare, die die Regel erklaeren (real gemessen: full-smoke.sh:370).
NEGATION='(garantiert|stellt sicher|bewacht|belegt|verhindert)[^.]{0,12}(nicht|kein|nie)'
SENSOR='Test[A-Z][A-Za-z0-9_]*|@test|[.]bats|make [a-z][a-z-]*|full-smoke|smoke[.]sh|test/mutations|d-check|a-check'

scan_file() {
	awk -v claim="$CLAIM" -v sensor="$SENSOR" -v negation="$NEGATION" -v file="$1" '
	function flush_block() {
		if (block_claim && !block_sensor) {
			printf "%s:%d\t%s\n", file, claim_line, claim_text
			found++
		}
		block_claim = 0; block_sensor = 0; claim_line = 0; claim_text = ""
	}
	{
		line = $0
		# Roh-String-Zustand VOR der Kommentar-Erkennung: eine ungerade Zahl an
		# Backticks in der Zeile kippt ihn. Zeilen im Literal sind emittierter
		# Inhalt und gehen den Gate nichts an.
		ticks = gsub(/`/, "`", line)
		was_raw = raw
		if (ticks % 2 == 1) raw = !raw
		if (was_raw || raw) { flush_block(); next }

		is_comment = ($0 ~ /^[ \t]*\/\// || $0 ~ /^[ \t]*#/)
		if (!is_comment) { flush_block(); next }

		if ($0 ~ claim && $0 !~ negation && !block_claim) {
			block_claim = 1; claim_line = NR
			claim_text = $0
			sub(/^[ \t]*(\/\/|#)[ \t]*/, "", claim_text)
		}
		if ($0 ~ sensor) block_sensor = 1
		# Genannte Testnamen einsammeln — die Existenz prueft die Shell (awk kennt das
		# Repo nicht).
		tmp = $0
		while (match(tmp, /Test[A-Z][A-Za-z0-9_]*/)) {
			# Wortgrenze links: ein Buchstabe davor heisst, der Treffer steckt in einem
			# Bezeichner (cppTestCMakeLists) und ist kein Testname.
			pre = (RSTART > 1) ? substr(tmp, RSTART - 1, 1) : " "
			if (pre !~ /[A-Za-z0-9_]/) printf "NAME\t%s\n", substr(tmp, RSTART, RLENGTH)
			tmp = substr(tmp, RSTART + RLENGTH)
		}
	}
	END { flush_block(); exit 0 }
	' "$1"
}

status=0
findings=""
names=""
for f in "$@"; do
	[ -f "$f" ] || continue
	out="$(scan_file "$f")"
	[ -n "$out" ] || continue
	claims="$(grep -v $'^NAME\t' <<<"$out" || true)"
	if [ -n "$claims" ]; then
		findings="$findings$claims"$'\n'
		status=1
	fi
	named="$(grep $'^NAME\t' <<<"$out" | cut -f2 || true)"
	[ -n "$named" ] && names="$names$named"$'\n'
done

# (b) Existiert jeder genannte Test wirklich? Ein erfundener Name ist eine Zusage auf
# einen Sensor, den es nicht gibt — schlimmer als gar keine Nennung, weil sie beruhigt.
for n in $(printf '%s' "$names" | sort -u); do
	# Gesucht wird die DEFINITION (`func <name>(`), nicht die Erwaehnung: eine blosse
	# Erwaehnung faende sich auch in der Test-Fixture, die den erfundenen Namen als
	# Gegenbeispiel benutzt — der Check haette sich selbst bestaetigt (real gesehen).
	# find+grep statt `grep --include`, damit der Gate auch im Alpine-basierten
	# bats-Image laeuft (busybox-grep kennt die Option nicht, ebenfalls real gesehen).
	if ! find . -name '*_test.go' -print0 | xargs -0 grep -lE "^func ${n}\(" 2>/dev/null | grep -q .; then
		findings="${findings}(erfundener Sensor)"$'\t'"${n} — kein solcher Test im Repo"$'\n'
		status=1
	fi
done

if [ "$status" -ne 0 ]; then
	echo "comment-claims: Behauptung ohne Sensor-Nennung (AGENTS.md §3.6):" >&2
	printf '%s' "$findings" >&2
	echo "comment-claims: Nenne den Sensor (Testname, make-Target, full-smoke, test/mutations) oder streiche die Behauptung." >&2
	exit 1
fi

echo "comment-claims: $# Datei(en) geprueft, 0 Befund(e)"
