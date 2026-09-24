#!/usr/bin/env bash
# tap-nachzug.sh — haelt die Tap-Formel gegen das veroeffentlichte Asset (ADR-0064,
# LH-QA-02). Ein Skript mit Modus-Argument: `check` ist der lesende Modus und kein Gate
# (Netz an genau diesem Aufruf, in keiner gates-Kette); `sync` ist nicht implementiert
# und endet mit Exit 2.
#
# ABLAUF (ADR-0064 Festlegung 1, Schritte des Modus check): a Tag-Form und Feldform,
# c Vorab-Tag, e Vergleich. Die Entscheidungen a und c laufen hier auf dem Host, vor
# jedem docker-Aufruf; Lesen und Vergleichen (Schritt e) laeuft in der POSIX-sh-Nutzlast
# harness/tools/tap-nachzug-nutzlast.sh im digest-gepinnten Transport-Bild
# (ADR-0058 Festlegung 4). Der Host braucht ueber git, docker, make und bash hinaus
# nichts (LH-QA-03).
#
# EXIT DES SKRIPTS: 0 gleich oder Vorab-Tag, 1 Formel-Unterschied (Nutzlast), 2 nicht ausfuehrbar
# (Aufruf, Tag-Form, Feldform, Pin, Asset oder Tap nicht lesbar, Modus sync, interner Fehler).
# 1 endet nur aus dem Vergleich der Nutzlast; ein Kommando dieses Skripts, das mit 1 scheitert,
# ist ein interner Fehler und endet mit Exit 2.
#
# EXIT-ZEILE: bei jedem Ende mit Exit ungleich 0 ist die letzte stderr-Zeile
# `tap-<modus>: Exit <N>`, <N> der Exit dieses Skripts; bei Exit 0 fehlt sie. Sie traegt die
# Klasse auch dort, wo der Prozess-Exit sie nicht traegt: `make` endet bei jedem Fehlschlag
# mit 2, in einer sprachabhaengigen Zeile (`Error N`, `Fehler N`).
#
# DER TAG IST EINGABE AUS EINER NICHT VERTRAUENSWUERDIGEN QUELLE: er kommt als
# Umgebungsvariable TAG an, nie als Text einer Kommandozeile, und wird nur gegen
# Formen geprueft und als -e-Wert durchgereicht, nie ausgewertet. Beim lokalen Aufruf
# `make tap-check TAG=…` wertet make den Wert aus, bevor dieses Skript laeuft; die
# Formpruefung sieht den Wert nach dieser Auswertung.
#
# TRANSPORT-BILD: der Digest steht hier als eigene Vorgabe, byte-gleich mit TRAEGER_IMAGE
# in harness/tools/traeger-fetch.sh; test/tap-nachzug.bats haelt beide Stellen gleich.
# TAP_IMAGE und TAP_WAIT sind fuer den Test ueberschreibbar.
set -euo pipefail
export LC_ALL=C

TAP_IMAGE="${TAP_IMAGE:-curlimages/curl@sha256:463eaf6072688fe96ac64fa623fe73e1dbe25d8ad6c34404a669ad3ce1f104b6}"
TAP_WAIT="${TAP_WAIT:-65}"

modus="${1:-}"
unterschied=nein

# beende <rc> legt die Exit-Klasse fest und schreibt die Exit-Zeile; fehler() und der EXIT-Trap
# (mit dem Status des Endes) rufen es. 1 gilt nur, wenn die Nutzlast ihn gemeldet hat
# (unterschied=ja); jedes andere Ende ausserhalb von 0 und 2 ist ein interner Fehler und
# wird Exit 2.
beende() {
	local rc="$1"
	trap - EXIT
	case "$rc" in
	0 | 2) ;;
	1)
		if [ "$unterschied" != ja ]; then
			printf 'tap-%s: interner Fehler des Skripts (ein Kommando endete mit 1) — es wurde nichts verglichen\n' "${modus:-nachzug}" >&2
			rc=2
		fi
		;;
	*)
		printf 'tap-%s: interner Fehler des Skripts (Exit %s) — es wurde nichts verglichen\n' "${modus:-nachzug}" "$rc" >&2
		rc=2
		;;
	esac
	if [ "$rc" -ne 0 ]; then
		printf 'tap-%s: Exit %s\n' "${modus:-nachzug}" "$rc" >&2
	fi
	exit "$rc"
}
trap 'beende "$?"' EXIT

fehler() {
	printf 'tap-%s: %s\n' "${modus:-nachzug}" "$1" >&2
	beende 2
}

case "$modus" in
check) ;;
sync) fehler "der Modus sync ist nicht implementiert — dieses Skript fuehrt nur check (ADR-0064 Festlegung 1)" ;;
*) fehler "Aufruf: tap-nachzug.sh check (Tag in der Umgebungsvariable TAG)" ;;
esac

case "$TAP_IMAGE" in
*@sha256:*) ;;
*) fehler "TAP_IMAGE ist nicht digest-gepinnt ($TAP_IMAGE) — der Transport laeuft im gepinnten Bild (ADR-0064 Festlegung 5, LH-QA-02)" ;;
esac

case "$TAP_WAIT" in
'' | *[!0-9]*) fehler "TAP_WAIT ist keine Sekundenzahl" ;;
esac

tag="${TAG:-}"
if [ -z "$tag" ]; then
	fehler "die Umgebungsvariable TAG ist nicht gesetzt — Aufruf: make tap-check TAG=<tag>"
fi

# Schritt a: Tag-Form, danach Feldform der drei Kernfelder (ADR-0064 Festlegung 1).
tag_form='^v[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?(\+[0-9A-Za-z.-]+)?$'
if ! [[ "$tag" =~ $tag_form ]]; then
	fehler "Tag-Form falsch: $(printf '%q' "$tag") — erwartet v<K>.<K>.<K>, optional -<Vorab> und +<Build> aus [0-9A-Za-z.-]"
fi
feld_form='^(0|[1-9][0-9]{0,8})$'
kern="${tag#v}"
kern="${kern%%[-+]*}"
IFS=. read -r k1 k2 k3 <<<"$kern"
for k in "$k1" "$k2" "$k3"; do
	if ! [[ "$k" =~ $feld_form ]]; then
		fehler "Feldform falsch: $(printf '%q' "$tag") — jedes Kernfeld ist 0 oder eine Ziffernfolge ohne fuehrende Null von hoechstens 9 Stellen"
	fi
done

# Schritt c: Vorab-Tag. Das Build-Metadatum wird zuerst abgeschnitten; dieselbe Regel
# steht im publish-Job von .github/workflows/release.yml, test/tap-nachzug.bats haelt
# beide gegen dieselben Tags gleich.
case "${tag%%+*}" in
*-*)
	printf 'tap-%s: Vorab-Tag, Tap bleibt (%s)\n' "$modus" "$tag"
	exit 0
	;;
esac

nutzlast="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/tap-nachzug-nutzlast.sh"
asset_url="https://github.com/pt9912/ai-harness-init/releases/download/${tag}/ai-harness-init.rb"
tap_url="https://api.github.com/repos/pt9912/homebrew-ai-harness-init/contents/Formula/ai-harness-init.rb"

# Ein Ende ausserhalb von 0, 1 und 2 kommt nicht aus der Nutzlast (docker nicht
# startbar, Bild nicht ladbar) und ist ein nicht ausfuehrbarer Lauf, nie ein Unterschied.
rc=0
docker run --rm \
	-e TAP_MODE="$modus" \
	-e TAP_TAG="$tag" \
	-e TAP_WAIT="$TAP_WAIT" \
	-e TAP_ASSET_URL="$asset_url" \
	-e TAP_URL="$tap_url" \
	-e TAP_TOKEN \
	-v "$nutzlast:/nutzlast/tap-nachzug-nutzlast.sh:ro" \
	"$TAP_IMAGE" sh /nutzlast/tap-nachzug-nutzlast.sh || rc=$?
case "$rc" in
0) exit 0 ;;
1)
	unterschied=ja
	exit 1
	;;
2) exit 2 ;;
*) fehler "der Transport im Bild ist nicht gelaufen (docker Exit $rc) — es wurde nichts verglichen" ;;
esac
