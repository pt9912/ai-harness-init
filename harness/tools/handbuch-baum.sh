#!/usr/bin/env bash
# handbuch-baum.sh — haelt einen Baum aus docs/user/benutzerhandbuch.md §6 gegen den
# Bestand eines frisch gebootstrappten Ziels, als PFAD-MENGE in beide Richtungen.
#
#   handbuch-baum.sh <handbuch> <variante> <ziel> [<basis-ziel>]
#
# <variante> waehlt den Baum: den umzaeunten ```text-Block direkt unter der Zeile
# `<!-- baum: <variante> -->`. Die erste Blockzeile ist die Wurzel; jede weitere traegt
# Baum-Zeichen (│ ├── └──), vier Spalten je Ebene, dann den Namen als erstes Wort —
# ein Verzeichnis endet auf `/`. Was hinter dem Namen steht, ist Etikett und wird nicht
# geprueft.
#
# Der Bestand ist `find` ueber dem Ziel, ohne `.git/`; `.harness/baseline/` zaehlt als
# EIN Eintrag, sein Inhalt nicht.
#
# OHNE <basis-ziel> (Phase 1): Baum-Menge == Bestand. Dazu haelt der Lauf die Zahl hinter
# `find .harness/baseline -type f | wc -l    # <N>` im Handbuch gegen dieselbe Zaehlung
# im Ziel — die eine Zahl, mit der der zusammengefasste Eintrag im Text steht.
#
# MIT <basis-ziel> (Phase 2, ein Sprachmodul): der Baum nennt das DELTA. Jeder genannte
# Pfad liegt im Ziel; jeder Pfad, den das Ziel ueber der Basis traegt, ist genannt; ein
# genannter Pfad, den schon die Basis traegt, ist ein Verzeichnis (Einordnung, kein
# Delta); und die Basis liegt vollstaendig im Ziel — das "zusaetzlich" aus §6.
#
# Exit 0 = deckungsgleich; Exit 1 = Abweichung, EINE Zeile auf stdout, je Richtung die
# Pfade in eckigen Klammern; Exit 2 = Aufruf- oder Formfehler (Block fehlt, Zeile ohne
# Baum-Zeichen, Einrueckung kein Vielfaches von vier).
#
# Rot-Gegenbeispiele: test/mutations/614-handbuch-baum-gitkeep-ohne-emission.sh (ein
# Eintrag fehlt in der Emission), 615-handbuch-baum-feldliste-ohne-emission.sh (die
# Erfassungs-Stufe schreibt die Feldliste nicht), 616-handbuch-baum-erfundener-pfad.sh
# (ein Pfad im Handbuch, den kein Lauf anlegt); gefahren von harness/tools/full-smoke.sh.
#
# GRENZE: geprueft ist die Pfad-Menge eines Laufs, dessen Traeger-Ablage gelingt, und
# fuer Phase 2 die Wurzel-Variante (--lang). Ein Laufzeit-Zweig ohne Ablage, add-lang
# unter einem Unterpfad und die --arch-Varianten stehen in §6 als Prosa und sind hier
# nicht gehalten; ebenso wenig die Etiketten.
set -euo pipefail
export LC_ALL=C

if [ "$#" -lt 3 ] || [ "$#" -gt 4 ]; then
	echo "Aufruf: handbuch-baum.sh <handbuch> <variante> <ziel> [<basis-ziel>]" >&2
	exit 2
fi
handbuch="$1" variante="$2" ziel="$3" basis="${4:-}"

baum_pfade() {
	awk -v v="<!-- baum: $variante -->" '
		$0 == v { m = 1; next }
		m == 1 { if ($0 != "```text") exit 3; m = 2; next }
		m == 2 { if ($0 == "```") { m = 3; exit } print }
		END { if (m != 3) exit 3 }
	' "$handbuch" | sed -e 's/│/|/g' -e 's/├──/+--/g' -e 's/└──/+--/g' | awk '
		NR == 1 { if ($0 !~ /\/$/) exit 4; next }
		{
			i = index($0, "+-- ")
			if (i == 0 || (i - 1) % 4 != 0) { print "Zeile ohne Baum-Form: " $0 > "/dev/stderr"; exit 4 }
			d = (i - 1) / 4
			split(substr($0, i + 4), w, " ")
			if (d > 0 && stapel[d - 1] !~ /\/$/) { print "Eintrag unter einer Datei: " $0 > "/dev/stderr"; exit 4 }
			stapel[d] = w[1]
			p = ""
			for (k = 0; k < d; k++) p = p stapel[k]
			print p w[1]
		}
	' | sort
}

bestand() {
	local p
	(cd "$1" && find . \( -path ./.git -prune \) -o \( -path ./.harness/baseline -prune -print \) -o -print) |
		while IFS= read -r p; do
			[ "$p" = . ] && continue
			p="${p#./}"
			if [ -d "$1/$p" ]; then printf '%s/\n' "$p"; else printf '%s\n' "$p"; fi
		done | sort
}

klammern() { sed 's/.*/[&]/' | tr '\n' ' ' | sed 's/ $//'; }

if ! soll="$(baum_pfade)" || [ -z "$soll" ]; then
	echo "Formfehler: kein auswertbarer Baum unter <!-- baum: $variante --> in $handbuch" >&2
	exit 2
fi
ist="$(bestand "$ziel")"
befund=""

if [ -z "$basis" ]; then
	nur_handbuch="$(comm -23 <(printf '%s\n' "$soll") <(printf '%s\n' "$ist"))"
	nur_ziel="$(comm -13 <(printf '%s\n' "$soll") <(printf '%s\n' "$ist"))"
	zahl_text="$(sed -nE 's/^find \.harness\/baseline -type f \| wc -l +# ([0-9]+)$/\1/p' "$handbuch")"
	zahl_ziel="$(find "$ziel/.harness/baseline" -type f | wc -l | tr -d ' ')"
	if [ "$zahl_text" != "$zahl_ziel" ]; then
		befund="$befund .harness/baseline/ traegt im Ziel $zahl_ziel Dateien, das Handbuch nennt [${zahl_text:-keine Zahl}];"
	fi
else
	vorhanden="$(bestand "$basis")"
	delta="$(comm -13 <(printf '%s\n' "$vorhanden") <(printf '%s\n' "$ist"))"
	nur_handbuch="$(comm -23 <(printf '%s\n' "$soll") <(printf '%s\n' "$ist"))"
	nur_ziel="$(comm -23 <(printf '%s\n' "$delta") <(printf '%s\n' "$soll"))"
	kein_delta="$(comm -12 <(printf '%s\n' "$soll") <(printf '%s\n' "$vorhanden") | grep -v '/$' || true)"
	fehlt_basis="$(comm -23 <(printf '%s\n' "$vorhanden") <(printf '%s\n' "$ist"))"
	[ -z "$kein_delta" ] || befund="$befund als Delta genannt, liegt schon ohne Sprachmodul: $(klammern <<<"$kein_delta");"
	[ -z "$fehlt_basis" ] || befund="$befund ohne Sprachmodul angelegt, mit Sprachmodul nicht: $(klammern <<<"$fehlt_basis");"
fi
[ -z "$nur_handbuch" ] || befund="$befund im Handbuch genannt, vom Lauf nicht angelegt: $(klammern <<<"$nur_handbuch");"
[ -z "$nur_ziel" ] || befund="$befund vom Lauf angelegt, im Handbuch nicht genannt: $(klammern <<<"$nur_ziel");"

if [ -n "$befund" ]; then
	echo "${befund# }"
	exit 1
fi
echo "$(wc -l <<<"$soll") Pfade im Baum <!-- baum: $variante --> decken den Bestand${basis:+ ueber der Basis}."
