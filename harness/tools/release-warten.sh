#!/usr/bin/env bash
# release-warten.sh — wartet begrenzt, bis das gepinnte Release (TRAEGER_TAG) die
# Assets fuehrt, die `make traeger-fetch` holt: SHA256SUMS (ADR-0059) und das
# Linux-amd64-Asset des CI-Runners. Der ci-Job `full-smoke` faehrt es vor
# `make full-smoke` (MR-014: die CI ruft nur make-Ziele).
#
# EIN KOMMANDO, KEIN GATE — ES URTEILT NICHT: ueber die Abrufbarkeit endet der Lauf
# immer mit Exit 0 — beim ersten Versuch, der beide Assets erreicht, oder nach der
# Grenze mit der Zeile "release-warten: GRENZE ERREICHT …". Das Urteil faellt danach
# in `make full-smoke`, das bei weiter fehlendem Asset mit `AUSGANG LEITUNG` bricht
# (ADR-0058 Festlegung 2: laut-Bruch statt Ausweichen). Exit 2 nur, wenn die eigenen
# Vorbedingungen fehlen (TRAEGER_TAG leer, Bild nicht digest-gepinnt, Grenze oder
# Intervall keine Zahl).
#
# GRENZE: TRAEGER_WARTEN_GRENZE Sekunden (Default 900 = 15 Minuten), Abstand der
# Versuche TRAEGER_WARTEN_INTERVALL Sekunden (Default 30). Jeder Versuch bekommt die
# Restzeit bis zur Grenze als Budget (mindestens 1 s, damit auch Grenze 0 einen
# Versuch faehrt): `timeout` um den docker-Aufruf (Bild-Pull eingeschlossen), nach
# dem Budget TERM, 5 s spaeter KILL; im Bild traegt curl dasselbe Budget als
# --max-time. Die Pause wird auf die Restzeit gekuerzt. Damit endet der Lauf
# hoechstens 7 s nach der Grenze: 1 s Rundung von SECONDS, 1 s Mindestbudget, 5 s
# Nachfrist bis KILL. Ein per KILL beendeter docker-Client kann einen Container
# zuruecklassen; den haelt das Budget von curl, nicht dieser Lauf.
#
# DIE GRENZ-ZEILE NENNT DEN AUSGANG DES LETZTEN VERSUCHS — Exit-Code und erste
# stderr-Zeile (124, 137 oder 143: Budget abgelaufen) —, ohne ihn zu deuten.
#
# DER TRANSPORT LAEUFT IM GEPINNTEN BILD, NICHT AUF DEM HOST (AGENTS.md 3.9): das
# Bild ist dasselbe wie das von harness/tools/traeger-fetch.sh, und sein Pin wird
# dort gelesen, nicht hier ein zweites Mal gefuehrt. Findet der Lauf die Zeile
# nicht, bricht er mit Exit 2. TRAEGER_IMAGE ueberschreibt den gelesenen Wert.
#
# GRENZE DES SCHRITTS: ein falsch gesetzter Pin bricht erst nach der Grenze statt
# sofort; die Kopplung der Pin-Stellen haelt test/traeger-fetch.bats ohne Warten.
# Abgefragt wird je Asset das erste Byte (GET mit Range), nicht der Inhalt — ob es
# der Digest traegt, entscheidet erst der Fetch.
set -euo pipefail

hier="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fetch_skript="$hier/traeger-fetch.sh"

bild="${TRAEGER_IMAGE:-}"
if [ -z "$bild" ]; then
	zeile="$(grep -m1 '^TRAEGER_IMAGE="' "$fetch_skript" 2>/dev/null || true)"
	bild="${zeile#*:-}"
	bild="${bild%\}\"}"
fi
case "$bild" in
*@sha256:*) ;;
*)
	echo "release-warten: kein digest-gepinntes Transport-Bild (gelesen aus $fetch_skript: '${bild}') — der Transport laeuft im gepinnten Bild." >&2
	exit 2
	;;
esac

tag="${TRAEGER_TAG:-}"
if [ -z "$tag" ]; then
	echo "release-warten: TRAEGER_TAG ist nicht gesetzt — der Release-Pin fehlt." >&2
	exit 2
fi
grenze="${TRAEGER_WARTEN_GRENZE:-900}"
intervall="${TRAEGER_WARTEN_INTERVALL:-30}"
case "$grenze$intervall" in
'' | *[!0-9]*)
	echo "release-warten: TRAEGER_WARTEN_GRENZE ('$grenze') und TRAEGER_WARTEN_INTERVALL ('$intervall') muessen ganze Sekunden sein." >&2
	exit 2
	;;
esac

basis="https://github.com/pt9912/ai-harness-init/releases/download/${tag}"
asset="ai-harness-init-linux-amd64"

# Ein Versuch: beide Assets, je das erste Byte. Exit 0 genau dann, wenn beide
# abrufbar sind; sonst der curl-Exit des ersten, der fehlt.
payload="$(cat <<'ENDE'
set -eu
for u in "$WARTEN_SUMS_URL" "$WARTEN_ASSET_URL"; do
	curl -fsSL --connect-timeout "$WARTEN_BUDGET" --max-time "$WARTEN_BUDGET" -r 0-0 -o /dev/null "$u"
done
ENDE
)"

fehler_datei="$(mktemp)"
trap 'rm -f "$fehler_datei"' EXIT

versuch=0
SECONDS=0
while :; do
	versuch=$((versuch + 1))
	budget=$((grenze - SECONDS))
	[ "$budget" -ge 1 ] || budget=1
	rc=0
	timeout -k 5 "$budget" docker run --rm \
		-e WARTEN_SUMS_URL="$basis/SHA256SUMS" \
		-e WARTEN_ASSET_URL="$basis/$asset" \
		-e WARTEN_BUDGET="$budget" \
		"$bild" sh -c "$payload" >/dev/null 2>"$fehler_datei" || rc=$?
	if [ "$rc" -eq 0 ]; then
		echo "release-warten: Release $tag fuehrt SHA256SUMS und $asset — abrufbar beim Versuch $versuch nach ${SECONDS}s."
		exit 0
	fi
	rest=$((grenze - SECONDS))
	if [ "$rest" -le 0 ]; then
		meldung="$(sed -n '1p' "$fehler_datei")"
		echo "release-warten: GRENZE ERREICHT — Release $tag fuehrt SHA256SUMS oder $asset nach ${SECONDS}s und $versuch Versuch(en) nicht abrufbar (Grenze ${grenze}s); letzter Versuch: Exit $rc${meldung:+, stderr: $meldung}; das Warten urteilt nicht, das Urteil faellt in make full-smoke."
		exit 0
	fi
	if [ "$intervall" -lt "$rest" ]; then sleep "$intervall"; else sleep "$rest"; fi
done
