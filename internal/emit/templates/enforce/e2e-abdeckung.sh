#!/usr/bin/env bash
# tools/harness/e2e-abdeckung.sh — Erzeuger der E2E-Abdeckungs-Sicht, emittiert von
# ai-harness-init. EIN KOMMANDO, KEIN GATE.
#
# WAS ER TUT. Er liest den TEXT des E2E-Skripts dieses Repos und schreibt daraus eine
# Tabelle: je Stufe eine Zeile mit der Anforderung, die sie traegt, einer
# Kurzbeschreibung, der Nummer der Stufe und dem Ort, an dem sie steht. Kein Docker,
# kein Netz, kein E2E-Lauf — die Sicht aendert sich mit den DEKLARATIONEN, nicht mit
# jedem Lauf. Darum ist das Kommando kein Gate: es urteilte ueber den Quelltext eines
# Skripts, nicht ueber den Zustand des Baums.
#
# DIE STUFEN-MENGE IST EIN KRITERIUM, KEINE AUFZAEHLUNG: eine Zeile der Form
#   echo "<Praefix>: … ..."
# eroeffnet eine Stufe, ihre Region reicht bis zur naechsten solchen Zeile — die letzte
# bis zum Dateiende. In der Region steht ein Aufruf
#   e2e_abdeckung "<Kennungen>" "<Kurzbeschreibung>" "<Anker>"
# und der Anker ist ein woertlicher Ausschnitt aus einer ANDEREN Zeile derselben Stufe.
#
# DIE ZWEI LUECKEN-RICHTUNGEN, beide laut:
#   (a) DEKLARATION OHNE STUFE — der Anker loest in der Region SEINER Stufe nicht
#       woertlich auf, oder der Aufruf steht vor der ersten Stufe.
#   (b) STUFE OHNE DEKLARATION — eine Region traegt keinen Aufruf.
# Beide enden mit Exit 1 und nennen Stufe, Region und bei (a) den Anker.
#
# VIER MARKER, JE MIT BELEGUNG. Sie sind Variablen, keine Platzhalter zum
# Suchen-und-Ersetzen:
#   E2E_ABDECKUNG_QUELLE   das E2E-Skript, dessen Stufen gelesen werden
#   E2E_ABDECKUNG_PRAEFIX  das Wort, mit dem eine Stufen-Kopfzeile dieses Skripts beginnt
#   E2E_ABDECKUNG_SPEC     die Spec-Datei, aus deren Ueberschriften die Anker stammen
#   E2E_ABDECKUNG_ZIEL     die zu schreibende Sicht
# Der Lauf nennt in seiner ersten Zeile die Werte, mit denen er faehrt.
#
# DIE KENNUNGEN GEHOEREN DIESEM REPO. Der Erzeuger kennt kein Kennungs-SCHEMA: er
# schlaegt jede deklarierte Kennung als erstes Wort einer `### `-Ueberschrift in der
# Spec-Datei nach und leitet den Anker aus DIESER Ueberschrift ab. Loest eine Kennung
# dort nicht auf — oder liegt die Spec-Datei gar nicht —, steht sie als CODE-SPAN ohne
# Link, und der Lauf sagt, welche. Das ist die Wahl gegen einen Verweis, der ins Leere
# zeigt: ein toter Link faerbt ein Doku-Gate rot und behauptet dabei eine Stelle, die es
# nicht gibt; ein Code-Span behauptet nichts.
#
# UND EINE STUFE DARF NOCH KEINE KENNUNG HABEN. Steht im ersten Argument der Deklaration
# allein ein Gedankenstrich, heisst das: dieses Repo fuehrt fuer diese Stufe (noch) keine
# Anforderung. Die Zelle traegt dann denselben Gedankenstrich, und der Lauf nennt die
# Stufe. Das ist der ehrliche Zustand einer mitgelieferten Stufe: eine geratene Kennung
# loeste vielleicht auf und behauptete trotzdem eine Zuordnung, die niemand getroffen hat.
#
# DIESE DATEI IST KONVERGENT: jeder Lauf des Werkzeugs schreibt sie kanonisch neu, und
# ein Edit an ihr ist danach still weg — deshalb sind die vier Stellen oben Variablen.
# Gesetzt wird am Aufruf
#   make e2e-abdeckung E2E_ABDECKUNG_QUELLE=tools/harness/mein-e2e.sh
# oder dauerhaft in einem EIGENEN Fragment unter harness/mk/ mit einem Namen, den dieses
# Werkzeug nicht schreibt — etwa harness/mk/vorgaben.mk:
#   E2E_ABDECKUNG_QUELLE = tools/harness/mein-e2e.sh
# Der Aggregator bindet es ueber `include harness/mk/*.mk` mit ein, und kein Lauf
# entfernt, was er nicht selbst angelegt hat.
#
# SCHREIBEN NUR BEI ABWEICHUNG: gerendert wird in eine Temp-Datei, danach verglichen.
# Ueber identischem Inhalt meldet der Lauf "unveraendert" und laesst das Ziel stehen.
#
# ABHAENGIGKEIT. bash und coreutils (grep/sed/awk/cmp/mktemp). Kein git, kein Docker,
# kein Netz.
set -euo pipefail

E2E_ABDECKUNG_QUELLE="${E2E_ABDECKUNG_QUELLE:-tools/harness/selbstpruefung.sh}"
E2E_ABDECKUNG_PRAEFIX="${E2E_ABDECKUNG_PRAEFIX:-selbstpruefung}"
E2E_ABDECKUNG_SPEC="${E2E_ABDECKUNG_SPEC:-spec/lastenheft.md}"
E2E_ABDECKUNG_ZIEL="${E2E_ABDECKUNG_ZIEL:-docs/user/e2e-abdeckung.md}"

quelle="$E2E_ABDECKUNG_QUELLE"
ziel="$E2E_ABDECKUNG_ZIEL"
spec="$E2E_ABDECKUNG_SPEC"

STUFEN_MUSTER="^echo \"$E2E_ABDECKUNG_PRAEFIX: .* \\.\\.\\.\"\$"
# Das Muster gilt ueber den Zeilen-ANGABEN von `grep -n` (Praefix `<zeile>:`), damit
# dieselbe Zeichenkette die Form prueft, die spaeter zerlegt wird.
RUF_MUSTER='^[0-9]+:[[:space:]]*e2e_abdeckung "[^"]*" "[^"]*" "[^"]*"[[:space:]]*$'
# Dieselbe Zeile OHNE die Zeilen-Angabe: sie erkennt eine Deklarations-Zeile dort, wo
# ueber Text gelaufen wird.
RUF_TEIL='^[[:space:]]*e2e_abdeckung "'
# Die typografischen Zeichen, die der Anker-Slug fallen laesst, und der Backtick der
# Orts-Spalte stehen als VARIABLE: woertlich in einem Kommando liest shellcheck das
# typografische Apostroph als Unicode-Anfuehrungszeichen (SC1112) und den Backtick im
# printf-Format als Kommando-Substitution (SC2016). Die Anfuehrungszeichen entstehen
# darum aus ihren UTF-8-BYTES: \342\200\231 \342\200\236 \342\200\234 \342\200\235.
TYPOGRAFIE='—–…·→'
ANFUEHRUNGEN="$(printf '\342\200\231\342\200\236\342\200\234\342\200\235')"
# Die ASCII-Satzzeichen, die der Slug fallen laesst: eine WOERTLICHE AUFZAEHLUNG, kein
# Bereich. Ein Bereich wie [.-@] wird von glibc-sed und busybox-sed VERSCHIEDEN gelesen,
# und der Anker haengt dann an der sed-Fassung der Laufzeitumgebung statt an der
# Ueberschrift. '-', '_' und alles ab 0x80 stehen nicht darin und bleiben stehen.
SATZZEICHEN='!"#$%&'"'"'()*+,./:;<=>?@'
BT='`'
# Das erste Argument einer Deklaration, das KEINE Kennung ist, sondern die Auskunft,
# dass dieses Repo fuer die Stufe (noch) keine Anforderung fuehrt.
OHNE_KENNUNG='—'

echo "e2e-abdeckung: Marker — Quelle=[$quelle] Praefix=[$E2E_ABDECKUNG_PRAEFIX] Spec=[$spec] Ziel=[$ziel]"

if [ ! -f "$quelle" ]; then
	echo "e2e-abdeckung: FEHLER — die Quelle liegt nicht: $quelle — der Marker E2E_ABDECKUNG_QUELLE nennt das E2E-Skript, dessen Stufen gelesen werden." >&2
	exit 1
fi

# Die Spec-Datei ist KEINE Vorbedingung des Laufs, sondern die Quelle der LINKS. Fehlt
# sie, entsteht die Sicht trotzdem — mit Code-Spans statt Verweisen.
spec_da=1
if [ ! -f "$spec" ]; then
	spec_da=0
	echo "e2e-abdeckung: Hinweis — die Spec-Datei liegt nicht: $spec. Die Kennungsspalte traegt Code-Spans statt Verweise; der Marker E2E_ABDECKUNG_SPEC nennt die Datei, aus deren Ueberschriften die Anker stammen."
fi

# slug_fuer <Kennung> — der Anker-Slug der Ueberschrift, aus der Ueberschrift selbst.
# Leere Ausgabe heisst: es gibt keine solche Ueberschrift; der Aufrufer schreibt dann
# einen Code-Span statt eines Links.
#
# Die Abbildung ist die des Markdown-Ankers: kleinschreiben, Leerzeichen zu '-', und
# Satzzeichen fallen weg. Geloescht werden genau die ASCII-Satzzeichen AUSSER '-' und
# '_'; alles ab 0x80 BLEIBT STEHEN, damit ein Umlaut im Slug erhalten bleibt.
slug_fuer() {
	local titel
	[ "$spec_da" -eq 1 ] || return 0
	titel="$(awk -v k="$1" '
		/^### / {
			t = $0
			sub(/^### /, "", t)
			kurz = t
			sub(/[[:space:]].*$/, "", kurz)
			if (kurz == k) { print t; exit }
		}
	' "$spec")"
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
	echo "e2e-abdeckung: FEHLER — $quelle fuehrt keine Stufen-Kopfzeile, und eine Sicht ueber null Stufen sagt nichts: ihr Gruen belegte eine Abdeckung, die niemand deklariert hat." >&2
	echo "  Erwartete Form einer Kopfzeile (eine Zeile, woertlich so):" >&2
	echo "    echo \"$E2E_ABDECKUNG_PRAEFIX: <was die Stufe tut> ...\"" >&2
	echo "  Und in ihrer Region, auf einer eigenen Zeile, die Deklaration:" >&2
	echo "    e2e_abdeckung \"<Kennungen>\" \"<Kurzbeschreibung>\" \"<Anker aus einer anderen Zeile dieser Stufe>\"" >&2
	echo "  Faehrt dieses Repo sein E2E woanders oder mit einem anderen Wort am Zeilenanfang, nennen es die Marker:" >&2
	echo "    make e2e-abdeckung E2E_ABDECKUNG_QUELLE=<pfad> E2E_ABDECKUNG_PRAEFIX=<wort>" >&2
	echo "  Dauerhaft in einem eigenen Fragment unter harness/mk/, das dieses Werkzeug nicht schreibt (etwa harness/mk/vorgaben.mk)." >&2
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

# Der Link auf die Spec-Datei steht relativ zum ZIEL.
rel_prefix=""
tiefe="$(printf '%s' "$ziel" | tr -dc '/' | wc -c)"
i=0
while [ "$i" -lt "$tiefe" ]; do
	rel_prefix="$rel_prefix../"
	i=$((i + 1))
done

{
	echo "# E2E-Abdeckung der Stufen des Voll-E2E"
	echo
	echo "Erzeugt von \`make e2e-abdeckung\` aus den Deklarationen, die jede Stufe von"
	echo "\`$quelle\` an sich selbst trägt. Diese Datei ist eine **stabile"
	echo "Abdeckungs-Deklaration, kein Lauf-Beleg**: der Erzeuger liest den Quelltext der Stufen,"
	echo "er führt den E2E nicht aus, und er schreibt sie nur bei inhaltlicher Abweichung. Sie"
	echo "ändert sich mit den Deklarationen und mit dem Ort ihrer Quellen — eine Einfügung"
	echo "oberhalb einer Stufe verschiebt deren Zeile in der Spalte \`Ort\`."
	echo
	echo "Die Spalte \`Spec-Kennung\` nennt die Anforderung, die diese Stufe trägt, als Verweis"
	echo "in \`$spec\`; löst die Kennung dort nicht auf, steht sie ohne Link. Die Spalte"
	echo "\`Kurzbeschreibung\` trägt keine Kennung. Die Spalte \`Stufe\` zählt die"
	echo "Stufen-Kopfzeilen in der Reihenfolge des Skripts — eine Stufe eröffnet mit ihrer"
	echo "Ausgabe-Kopfzeile und reicht bis zur nächsten. Die Spalte \`Ort\` adressiert sie."
	echo "Ob eine hier fehlende Anforderung eine Lücke ist, urteilt der Leser gegen"
	echo "\`$spec\`; ein Waisen-Urteil fällt nicht hier."
	echo
	echo "| Spec-Kennung | Stufe | Ort | Kurzbeschreibung |"
	echo "| --- | --- | --- | --- |"
} >"$tmp"

zeilen_gesamt="$(wc -l <"$quelle")"
stufen_gesamt=0
deklarationen=0
ohne_link=0
while IFS=: read -r start _rest; do
	stufen_gesamt=$((stufen_gesamt + 1))
	naechste="$(awk -F: -v z="$start" '$1 > z { print $1; exit }' <<<"$stufen")"
	if [ -n "$naechste" ]; then
		ende=$((naechste - 1))
	else
		ende="$zeilen_gesamt"
	fi
	titel="$(sed -n "${start}p" "$quelle" | sed -e "s/^echo \"$E2E_ABDECKUNG_PRAEFIX: //" -e 's/ \.\.\."$//')"

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
		# der Ort auf eine Zeile der STUFE zeigt und nicht auf die Deklaration.
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
		if [ "$kennungen" = "$OHNE_KENNUNG" ]; then
			# KEINE ZUORDNUNG BEHAUPTEN, WO KEINE GETROFFEN IST: die Zelle traegt den
			# Gedankenstrich der Deklaration weiter, und die Stufe steht trotzdem in der
			# Sicht — sie laeuft ja.
			links="$OHNE_KENNUNG"
			ohne_link=$((ohne_link + 1))
			echo "e2e-abdeckung: Hinweis — Stufe $stufen_gesamt deklariert keine Kennung ($quelle:$rufzeile); die Zelle traegt $OHNE_KENNUNG. Eine Anforderung dieses Repos traegt sie, sobald die Deklaration sie nennt."
			printf '| %s | Stufe %s | %s%s:%s%s | %s |\n' "$links" "$stufen_gesamt" "$BT" "$quelle" "$ort" "$BT" "$kurz" >>"$tmp"
			deklarationen=$((deklarationen + 1))
			continue
		fi
		for k in $kennungen; do
			slug="$(slug_fuer "$k")"
			if [ -n "$links" ]; then
				links="$links, "
			fi
			if [ -z "$slug" ]; then
				# KEIN LINK OHNE ZIEL: die Kennung steht als Code-Span da. Der Lauf zaehlt
				# sie und nennt sie unten — still waere das eine Abdeckung, die einen
				# Verweis behauptet, den sie nicht hat.
				links="${links}\`$k\`"
				ohne_link=$((ohne_link + 1))
				echo "e2e-abdeckung: Hinweis — die Kennung $k hat keine \`### \`-Ueberschrift in $spec ($quelle:$rufzeile); sie steht als Code-Span ohne Verweis."
			else
				links="${links}[\`$k\`](${rel_prefix}${spec}#${slug})"
			fi
		done
		printf '| %s | Stufe %s | %s%s:%s%s | %s |\n' "$links" "$stufen_gesamt" "$BT" "$quelle" "$ort" "$BT" "$kurz" >>"$tmp"
		deklarationen=$((deklarationen + 1))
	done <<<"$region_aufrufe"
done <<<"$stufen"

if [ "$deklarationen" -ne "$stufen_gesamt" ]; then
	echo "e2e-abdeckung: FEHLER — $stufen_gesamt Stufen, aber $deklarationen Deklarationen geschrieben; jede Stufe traegt genau die ihre." >&2
	exit 1
fi

if [ -f "$ziel" ] && cmp -s "$tmp" "$ziel"; then
	echo "e2e-abdeckung: unveraendert — $ziel ($stufen_gesamt Stufen, $deklarationen Deklarationen, $ohne_link ohne Verweis)."
else
	ziel_dir="$(dirname "$ziel")"
	if [ ! -d "$ziel_dir" ]; then
		mkdir -p "$ziel_dir"
	fi
	# Der Modus steht EXPLIZIT: `mktemp` legt die Temp-Datei mit 0600 an, und die Sicht
	# wird von einem Doku-Gate gelesen, das in einem Container als Nicht-Root laeuft.
	rm -f "$ziel"
	cat "$tmp" >"$ziel"
	chmod 0644 "$ziel"
	echo "e2e-abdeckung: geschrieben — $ziel ($stufen_gesamt Stufen, $deklarationen Deklarationen aus $quelle, $ohne_link ohne Verweis)."
fi
