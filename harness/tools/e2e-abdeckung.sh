#!/usr/bin/env bash
# e2e-abdeckung.sh — erzeugt die Abdeckungs-Tabelle aus den Deklarationen, die jede
# Stufe von harness/tools/full-smoke.sh an sich selbst traegt.
#
# AUFRUF: e2e-abdeckung.sh <quelle> <ziel>
#   <quelle>  der TEXT des E2E-Skripts (Regelfall: harness/tools/full-smoke.sh)
#   <ziel>    die zu schreibende Tabelle (Regelfall: docs/user/e2e-abdeckung.md)
# Quelle UND Ziel sind Argumente, damit ein Test denselben Erzeuger ueber einer KOPIE
# fahren kann, ohne den geprueften Baum zu beruehren.
#
# WAS ER LIEST — TEXT, KEIN LAUF: die Quelle wird Zeile fuer Zeile als Text gelesen.
# Kein Docker, kein E2E, keine Ausfuehrung der Quelle. Die Tabelle aendert sich damit
# mit den DEKLARATIONEN, nicht mit jedem Lauf. Das Werkzeug ist darum kein Gate: es
# urteilte ueber den Quelltext eines Skripts, nicht ueber den Zustand des Baums
# (LH-QA-01). Dass die committete docs/user/e2e-abdeckung.md der aktuelle Ausgang dieses
# Erzeugers ist, prueft der Halter in test/e2e-abdeckung.bats (Fall "halter: die committete
# Tabelle ist der aktuelle Ausgang des Erzeugers"): er faehrt diesen Erzeuger ueber einer
# Kopie des geprueften E2E-Skripts und haelt das Ergebnis byte-gleich gegen die committete
# Datei. `make docs-check` prueft an der Tabelle nur ihre Verweise, nicht ihre
# Uebereinstimmung mit diesem Erzeuger.
#
# DIE STUFEN-MENGE IST EIN KRITERIUM, KEINE AUFZAEHLUNG: eine Zeile der Form
#   echo "full-smoke: … ..."
# eroeffnet eine Stufe, ihre Region reicht bis zur naechsten solchen Zeile — die letzte
# bis zum Dateiende. Dasselbe Muster liest der Aufruf `e2e_abdeckung` in der Quelle zur
# Laufzeit. Es steht an zwei Stellen, weil dieses Werkzeug die Quelle nicht ausfuehrt;
# eine Stufe, deren Kopfzeile die Form nicht trifft, ist fuer beide keine, und diese
# Grenze steht in harness/sensors/full-smoke.md.
#
# DIE ZWEI LUECKEN-RICHTUNGEN, beide laut:
#   (a) DEKLARATION OHNE STUFE — der Anker eines Aufrufs loest in der Region SEINER
#       Stufe nicht woertlich auf, oder der Aufruf steht vor der ersten Stufe.
#   (b) STUFE OHNE DEKLARATION — eine Region traegt keinen Aufruf.
# Beide enden mit Exit 1 und nennen Stufe, Region und bei (a) den Anker; die
# Gegenbeispiele fahren test/e2e-abdeckung.bats ueber mutierten Kopien, und
# test/mutations/ nimmt dafuer einer Stufe des geprueften Baums ihre Deklaration.
#
# WAS ER NICHT PRUEFT: ob die genannte Anforderung noch ZU ihrer Stufe gehoert. Der
# Anker kann aufloesen, waehrend die Stufe ihre Aussage aendert — die Zuordnung bleibt
# ein Urteil, das der Review haelt.
#
# DER ANKER-SLUG der Kennungsspalte wird aus der Ueberschrift im Lastenheft ABGELEITET
# statt gepflegt; eine deklarierte Kennung ohne Ueberschrift bricht darum ab, statt
# einen Link ohne Ziel zu schreiben. Dass der abgeleitete Link aufloest, haelt das
# Modul `anchors` von `make docs-check`.
#
# NICHT UEBERNOMMEN WIRD DIE BESCHRIFTUNG DER KOPFZEILE SELBST: sie kann Kennungen
# fuehren, die im geprueften Doku-Bereich linkpflichtig waeren, und diesen Link leitet
# dieses Werkzeug nicht ab. Die Spalte `Kurzbeschreibung` sagt stattdessen, was die
# Stufe traegt, und die Spalte `Ort` adressiert sie.
#
# SCHREIBEN NUR BEI ABWEICHUNG: gerendert wird in eine Temp-Datei, danach verglichen.
# Ueber identischem Inhalt meldet der Lauf "unverändert" und laesst das Ziel stehen.
set -euo pipefail

HIER="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STUFEN_MUSTER='^echo "full-smoke: .* \.\.\."$'
# Das Muster gilt ueber den Zeilen-ANGABEN von `grep -n` (Praefix `<zeile>:`), damit
# dieselbe Zeichenkette die Form prueft, die spaeter zerlegt wird.
RUF_MUSTER='^[0-9]+:[[:space:]]*e2e_abdeckung "[^"]*" "[^"]*" "[^"]*"[[:space:]]*$'
# Dieselbe Zeile OHNE die Zeilen-Angabe: sie erkennt eine Deklarations-Zeile dort, wo
# ueber Text gelaufen wird.
RUF_TEIL='^[[:space:]]*e2e_abdeckung "'
# Die typografischen Zeichen, die der Anker-Slug fallen laesst, und der Backtick der
# Orts-Spalte stehen als VARIABLE: woertlich in einem Kommando liest shellcheck das ’
# als Unicode-Anfuehrungszeichen (SC1112) und den Backtick im printf-Format als
# Kommando-Substitution (SC2016), und eine Inline-Suppression ist nach AGENTS.md §3.2
# gesperrt. Die Anfuehrungszeichen entstehen darum aus ihren UTF-8-BYTES statt aus einer
# Zeichenkodierung der Umgebung: \342\200\231 ist ’, \342\200\236 ist „, \342\200\234
# ist “, \342\200\235 ist ”.
TYPOGRAFIE='—–…·→'
ANFUEHRUNGEN="$(printf '\342\200\231\342\200\236\342\200\234\342\200\235')"
# Die ASCII-Satzzeichen, die der Slug fallen laesst: eine WOERTLICHE AUFZAEHLUNG, kein
# Bereich. Ein Bereich wie [.-@] wird von glibc-sed und busybox-sed VERSCHIEDEN gelesen —
# busybox-sed fallen darin auch die Ziffern heraus, glibc-sed nicht —, und der Anker haengt
# dann an der sed-Fassung der Laufzeitumgebung statt an der Ueberschrift. '-', '_' und
# alles ab 0x80 stehen nicht in der Aufzaehlung und bleiben damit stehen.
SATZZEICHEN='!"#$%&'"'"'()*+,./:;<=>?@'
BT='`'
LASTENHEFT_REL="spec/lastenheft.md"

if [ "$#" -ne 2 ]; then
	echo "Aufruf: e2e-abdeckung.sh <quelle> <ziel>" >&2
	exit 2
fi
quelle="$1"
ziel="$2"
lastenheft="$HIER/../../$LASTENHEFT_REL"

if [ ! -f "$quelle" ]; then
	echo "e2e-abdeckung: FEHLER — die Quelle liegt nicht: $quelle" >&2
	exit 1
fi
if [ ! -f "$lastenheft" ]; then
	echo "e2e-abdeckung: FEHLER — das Lastenheft liegt nicht: $lastenheft — die Kennungsspalte leitet ihre Anker daraus ab" >&2
	exit 1
fi

# slug_fuer <Kennung> — der Anker-Slug der Ueberschrift, aus der Ueberschrift selbst.
# Leere Ausgabe heisst: es gibt keine solche Ueberschrift; der Aufrufer bricht dann ab.
#
# Die Abbildung ist die des Markdown-Ankers: kleinschreiben, Leerzeichen zu '-', und
# Satzzeichen fallen weg. Geloescht werden genau die ASCII-Satzzeichen AUSSER '-' und
# '_'; alles ab 0x80 BLEIBT STEHEN, damit ein Umlaut im Slug erhalten bleibt (der Anker
# einer Ueberschrift mit Umlaut traegt ihn). Beide Regeln sind auf die Ueberschriften
# des Lastenhefts gemessen; das Modul `anchors` von `make docs-check` prueft das
# Ergebnis gegen die realen Anker und faerbt einen Fehlgriff rot.
slug_fuer() {
	local titel
	titel="$(awk -v k="$1" '
		/^### / {
			t = $0
			sub(/^### /, "", t)
			kurz = t
			sub(/[[:space:]].*$/, "", kurz)
			if (kurz == k) { print t; exit }
		}
	' "$lastenheft")"
	[ -n "$titel" ] || return 0
	printf '%s' "$titel" \
		| tr '[:upper:]' '[:lower:]' \
		| sed -e 's/Ä/ä/g' -e 's/Ö/ö/g' -e 's/Ü/ü/g' \
		| sed -e "s/[$TYPOGRAFIE$ANFUEHRUNGEN]//g" \
		| sed -e "s/[$SATZZEICHEN]//g" \
		| sed -e 's/\[//g' -e 's/\\//g' -e 's/\]//g' -e 's/\^//g' \
		| sed -e 's/`//g' -e 's/[{-~]//g' \
		| sed -e 's/ /-/g'
}

stufen="$(grep -nE "$STUFEN_MUSTER" "$quelle" || true)"
if [ -z "$stufen" ]; then
	echo "e2e-abdeckung: FEHLER — $quelle fuehrt keine Zeile der Form $STUFEN_MUSTER — die Tabelle hat ohne Stufen keine Zeile, und ihr Grün sagt dann nichts (LH-QA-01)." >&2
	exit 1
fi

aufrufe="$(grep -nE '^[[:space:]]*e2e_abdeckung ' "$quelle" || true)"
unleserlich="$(grep -vE "$RUF_MUSTER" <<<"$aufrufe" || true)"
if [ -n "$unleserlich" ]; then
	echo "e2e-abdeckung: FEHLER — Deklarations-Zeile in unleserlicher Form; erwartet wird e2e_abdeckung \"<Kennungen>\" \"<Kurzbeschreibung>\" \"<Anker>\":" >&2
	printf '%s\n' "$unleserlich" >&2
	exit 1
fi

# Alles VOR der ersten Stufe ist eine Deklaration ohne Stufe; danach kacheln die
# Regionen der Stufen die Datei lueckenlos.
erste_stufe="$(sed -n '1p' <<<"$stufen" | cut -d: -f1)"
davor="$(awk -F: -v z="$erste_stufe" '$1 < z { print }' <<<"$aufrufe")"
if [ -n "$davor" ]; then
	echo "e2e-abdeckung: FEHLER — Deklaration ohne Stufe: der Aufruf steht VOR der ersten Stufen-Kopfzeile ($quelle:$erste_stufe):" >&2
	printf '%s\n' "$davor" >&2
	exit 1
fi

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

# Der Link auf das Lastenheft steht relativ zum ZIEL: die Tabelle liegt tiefer als es.
rel_prefix=""
tiefe="$(printf '%s' "$ziel" | tr -dc '/' | wc -c)"
i=0
while [ "$i" -lt "$tiefe" ]; do
	rel_prefix="$rel_prefix../"
	i=$((i + 1))
done

cat <<'KOPF' >"$tmp"
# E2E-Abdeckung der Stufen des Voll-E2E

Erzeugt von `make e2e-abdeckung` aus den Deklarationen, die jede Stufe von
`harness/tools/full-smoke.sh` an sich selbst trägt. Diese Datei ist eine **stabile
Abdeckungs-Deklaration, kein Lauf-Beleg**: der Erzeuger liest den Quelltext der Stufen,
er führt den E2E nicht aus, und er schreibt sie nur bei inhaltlicher Abweichung. Sie
ändert sich mit den Deklarationen und mit dem Ort ihrer Quellen — eine Einfügung
oberhalb einer Stufe verschiebt deren Zeile in der Spalte `Ort`.

Die Spalten stehen in der Folge `Spec-Kennung`, `Kurzbeschreibung`, `Stufe`, `Ort`.
Die Spalte `Spec-Kennung` nennt die Anforderung, die diese Stufe trägt, als klickbaren
Verweis in `spec/lastenheft.md`; die Spalte `Kurzbeschreibung` trägt keine Kennung. Die
Spalte `Stufe` zählt die Stufen-Kopfzeilen in der Reihenfolge des Skripts — eine Stufe
eröffnet mit ihrer Ausgabe-Kopfzeile und reicht bis zur nächsten. Ob eine hier fehlende
Anforderung eine Lücke ist, urteilt der Leser gegen `spec/lastenheft.md`; ein
Waisen-Urteil fällt nicht hier.

| Spec-Kennung | Kurzbeschreibung | Stufe | Ort |
| --- | --- | --- | --- |
KOPF

zeilen_gesamt="$(wc -l <"$quelle")"
stufen_gesamt=0
deklarationen=0
while IFS=: read -r start _rest; do
	stufen_gesamt=$((stufen_gesamt + 1))
	naechste="$(awk -F: -v z="$start" '$1 > z { print $1; exit }' <<<"$stufen")"
	if [ -n "$naechste" ]; then
		ende=$((naechste - 1))
	else
		ende="$zeilen_gesamt"
	fi
	titel="$(sed -n "${start}p" "$quelle" | sed -e 's/^echo "full-smoke: //' -e 's/ \.\.\."$//')"

	region_aufrufe="$(awk -F: -v s="$start" -v e="$ende" '$1 >= s && $1 <= e' <<<"$aufrufe")"
	if [ -z "$region_aufrufe" ]; then
		echo "e2e-abdeckung: FEHLER — Stufe ohne Deklaration: in der Region dieser Stufe steht kein Aufruf von e2e_abdeckung." >&2
		echo "  Stufe $stufen_gesamt: $titel" >&2
		echo "  Region: $quelle:$start-$ende" >&2
		echo "  Nachweis: sed -n '${start},${ende}p' $quelle" >&2
		exit 1
	fi

	while IFS=: read -r rufzeile ruftext; do
		kennungen="$(sed -n 's/^[[:space:]]*e2e_abdeckung "\([^"]*\)" "[^"]*" "[^"]*"[[:space:]]*$/\1/p' <<<"$ruftext")"
		kurz="$(sed -n 's/^[[:space:]]*e2e_abdeckung "[^"]*" "\([^"]*\)" "[^"]*"[[:space:]]*$/\1/p' <<<"$ruftext")"
		anker="$(sed -n 's/^[[:space:]]*e2e_abdeckung "[^"]*" "[^"]*" "\([^"]*\)"[[:space:]]*$/\1/p' <<<"$ruftext")"
		case "$kurz" in
		*"|"*)
			echo "e2e-abdeckung: FEHLER — die Kurzbeschreibung fuehrt ein '|', das die Tabellen-Zelle zerlegte ($quelle:$rufzeile)." >&2
			exit 1
			;;
		esac
		# Die Deklarations-Zeilen sind von der Anker-Suche AUSGENOMMEN: der Anker steht
		# wortwoertlich im dritten Argument des Aufrufs. Die Ausnahme ist der Grund, warum
		# der Ort auf eine Zeile der STUFE zeigt und nicht auf die Deklaration, und warum
		# die Pruefung an einem gebrochenen Anker nicht still vorbeilaeuft.
		ort="$(awk -v s="$start" -v e="$ende" -v a="$anker" -v rufmuster="$RUF_TEIL" \
			'NR >= s && NR <= e && $0 !~ rufmuster && index($0, a) { print NR; exit }' "$quelle")"
		if [ -z "$ort" ]; then
			echo "e2e-abdeckung: FEHLER — Deklaration ohne Stufe: der Anker loest in der Region der Stufe, die sie deklariert, nicht woertlich auf." >&2
			echo "  Deklaration: $quelle:$rufzeile (Stufe $stufen_gesamt: $titel)" >&2
			echo "  Anker: [$anker]" >&2
			echo "  Region: $quelle:$start-$ende" >&2
			echo "  Nachweis: sed -n '${start},${ende}p' $quelle" >&2
			exit 1
		fi
		links=""
		for k in $kennungen; do
			slug="$(slug_fuer "$k")"
			if [ -z "$slug" ]; then
				echo "e2e-abdeckung: FEHLER — die deklarierte Kennung $k hat keine Ueberschrift in $lastenheft; die Kennungsspalte bekaeme einen Link ohne Ziel ($quelle:$rufzeile)." >&2
				exit 1
			fi
			if [ -n "$links" ]; then
				links="$links, "
			fi
			links="${links}[\`$k\`](${rel_prefix}${LASTENHEFT_REL}#${slug})"
		done
		printf '| %s | %s | Stufe %s | %s%s:%s%s |\n' "$links" "$kurz" "$stufen_gesamt" "$BT" "$quelle" "$ort" "$BT" >>"$tmp"
		deklarationen=$((deklarationen + 1))
	done <<<"$region_aufrufe"
done <<<"$stufen"

if [ "$deklarationen" -ne "$stufen_gesamt" ]; then
	echo "e2e-abdeckung: FEHLER — $stufen_gesamt Stufen, aber $deklarationen Deklarationen geschrieben; jede Stufe traegt genau die ihre." >&2
	exit 1
fi

if [ -f "$ziel" ] && cmp -s "$tmp" "$ziel"; then
	echo "e2e-abdeckung: unverändert — $ziel ($stufen_gesamt Stufen, $deklarationen Deklarationen)."
else
	ziel_dir="$(dirname "$ziel")"
	if [ ! -d "$ziel_dir" ]; then
		mkdir -p "$ziel_dir"
	fi
	# Der Modus steht EXPLIZIT: `mktemp` legt die Temp-Datei mit 0600 an, und die Tabelle
	# wird vom Doku-Gate gelesen — der d-check-Container laeuft als Nicht-Root und kommt an
	# eine 0600-Datei nicht heran.
	rm -f "$ziel"
	cat "$tmp" >"$ziel"
	chmod 0644 "$ziel"
	echo "e2e-abdeckung: geschrieben — $ziel ($stufen_gesamt Stufen, $deklarationen Deklarationen aus $quelle)."
fi
