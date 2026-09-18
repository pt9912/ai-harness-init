#!/usr/bin/env bash
# traeger-fetch.sh — legt den Traeger per Fetch aus dem gepinnten Release ab
# (ADR-0058 Festlegung 1 und 3). EIN KOMMANDO, KEIN GATE: es prueft nichts am Baum,
# haengt an keiner gates-Kette und steht in keiner Prerequisite-Kette — der Fehlt-Fall
# der Konsumenten (archive-welle, span-report u. a.) bleibt unangetastet
# (ADR-0058 Festlegung 3 und Folgepflicht 5). Es braucht Netz an genau diesem Aufruf
# (MR-007-Muster) und laeuft nur auf ausdruecklichem Aufruf, nie nebenbei.
#
# DER TRANSPORT LAEUFT IM GEPINNTEN BILD, NICHT AUF DEM HOST (ADR-0058 Festlegung 4):
# Download und Digest-Verifizierung fahren in einem Container mit digest-gepinntem
# Image — der Host braucht weiter nur git, docker, make (LH-QA-03); ein curl/wget in
# der Befehlsposition waere eine vierte Abhaengigkeit.
#
# FAIL-CLOSED AN DREI STELLEN, alle VOR der Ablage: fehlt der Release-Pin, fehlt der
# sha256-Pin seiner Plattform (die Kopplung Makefile/Fragment hat eine Stelle stehen
# lassen — dieselbe Klasse wie test/sources-pin.bats), oder weicht der Digest des
# geholten Assets ab, bricht der Lauf, ohne den Traeger abzulegen. Der Digest wird vor
# der Ablage verifiziert; eine abgebrochene Ablage hinterlaesst keinen halben Traeger
# (LH-QA-02).
#
# DIE PINS LEBEN IM MAKEFILE BEZW. IM EMITTIERTEN Fragment (TRAEGER_TAG,
# TRAEGER_SHA256_*, exportiert) — dieses Skript fuehrt keinen zweiten Bestand davon;
# test/traeger-fetch.bats haelt beide Stellen gegen das Makefile-Paar.
set -euo pipefail

# Transport-Bild, digest-gepinnt (LH-QA-02). Der Einzige Pin dieses Skripts: seine
# Konsumenten sind hier und im emittierten Zwilling (byte-gleich, test/traeger-fetch.bats).
TRAEGER_IMAGE="${TRAEGER_IMAGE:-curlimages/curl@sha256:463eaf6072688fe96ac64fa623fe73e1dbe25d8ad6c34404a669ad3ce1f104b6}"
# Ablageort des Traegers — derselbe gitignorierte Zustands-Bereich, den placeCarrier
# des Werkzeugs beschreibt (carrierDir/carrierName, internal/emit/enforce.go).
TRAEGER_CARRIER="${TRAEGER_CARRIER:-.harness/state/bin/ai-harness-init}"

case "$TRAEGER_IMAGE" in
*@sha256:*) ;;
*)
	echo "traeger-fetch: TRAEGER_IMAGE ist nicht digest-gepinnt ($TRAEGER_IMAGE) — der Transport laeuft im gepinnten Bild (ADR-0058 Festlegung 4, LH-QA-02)." >&2
	exit 2
	;;
esac

# Plattform des HOSTS, nicht des Bilds: das Asset muss zur Maschine passen, die den
# Traeger startet. Closed Set je Achse — die Asset-Matrix der Release fuehrt
# linux/darwin/windows x amd64/arm64 (LH-QA-04); alles andere bricht laut, statt ein
# Asset zu raten.
os="${TRAEGER_OS:-$(uname -s)}"
arch="${TRAEGER_ARCH:-$(uname -m)}"
case "$os" in
Linux) plat="linux" ;;
Darwin) plat="darwin" ;;
MINGW* | MSYS* | CYGWIN*) plat="windows" ;;
*)
	echo "traeger-fetch: unbekannte Plattform (uname -s: $os) — die Asset-Matrix fuehrt linux, darwin, windows (LH-QA-04)." >&2
	exit 2
	;;
esac
case "$arch" in
x86_64 | amd64) a="amd64" ;;
aarch64 | arm64) a="arm64" ;;
*)
	echo "traeger-fetch: unbekannte Architektur (uname -m: $arch) — die Asset-Matrix fuehrt amd64, arm64 (LH-QA-04)." >&2
	exit 2
	;;
esac
plat_u="$(printf '%s' "$plat" | tr '[:lower:]' '[:upper:]')"
arch_u="$(printf '%s' "$a" | tr '[:lower:]' '[:upper:]')"

asset="ai-harness-init-${plat}-${a}"
carrier="$TRAEGER_CARRIER"
if [ "$plat" = "windows" ]; then
	asset="${asset}.exe"
	case "$carrier" in
	*.exe) ;;
	*) carrier="${carrier}.exe" ;;
	esac
fi

# Der Pin seiner Plattform: die Kopplung exportiert die sechs Werte; fehlt der
# eigene, ist eine Pin-Stelle stehen geblieben — der Lauf bricht, BEVOR er anfaengt.
sha_var="TRAEGER_SHA256_${plat_u}_${arch_u}"
sha="${!sha_var:-}"
if [ -z "$sha" ]; then
	echo "traeger-fetch: $sha_var ist nicht gesetzt — der sha256-Pin seiner Plattform fehlt; die Kopplung traegt die sechs Werte (ADR-0058 Festlegung 1, LH-QA-02)." >&2
	exit 2
fi
tag="${TRAEGER_TAG:-}"
if [ -z "$tag" ]; then
	echo "traeger-fetch: TRAEGER_TAG ist nicht gesetzt — der Release-Pin fehlt (ADR-0058 Festlegung 1, LH-QA-02)." >&2
	exit 2
fi
url="https://github.com/pt9912/ai-harness-init/releases/download/${tag}/${asset}"

mkdir -p "$(dirname "$carrier")"
carrier_abs="$(cd "$(dirname "$carrier")" && pwd)/$(basename "$carrier")"

# DER TRANSPORT IM BILD. Das Bild mountet den Ablage-Ordner an DERSELBEN absoluten
# Adresse, unter der der Host ihn liest — das Payload referenziert genau diesen Pfad.
# --user haelt die Ablage im Besitz des Host-Nutzers; das Bild laeuft sonst als
# eigener Nutzer und legte fremde Dateien an. Die Plattform-Erkennung steht bewusst
# AUSSERHALB des Bilds: uname im Container nennt die Plattform des Bilds, nicht die
# des Hosts.
#
# Verifiziert wird VOR der Ablage: eine Digest-Abweichung bricht ab, ohne den Traeger
# zu legen — unter der geschwächten Zusicherung (Abweichung bricht, Traeger bleibt
# liegen) bleibt der Negative-Fall von test/traeger-fetch.bats rot.
payload="$(cat <<'ENDE'
set -eu
curl -fsSL -o /tmp/traeger-asset "$TRAEGER_URL"
ist="$(sha256sum /tmp/traeger-asset)" && ist="${ist%% *}"
if [ "$ist" != "$TRAEGER_SHA256" ]; then
	echo "traeger-fetch: Digest-Abweichung — ist $ist, erwartet $TRAEGER_SHA256. Der Traeger wird nicht abgelegt." >&2
	exit 1
fi
cp /tmp/traeger-asset "$TRAEGER_CARRIER_ABS"
chmod 0755 "$TRAEGER_CARRIER_ABS"
ENDE
)"

docker run --rm \
	--user "$(id -u):$(id -g)" \
	-e TRAEGER_URL="$url" \
	-e TRAEGER_SHA256="$sha" \
	-e TRAEGER_CARRIER_ABS="$carrier_abs" \
	-v "$(dirname "$carrier_abs"):$(dirname "$carrier_abs")" \
	"$TRAEGER_IMAGE" sh -c "$payload"

echo "traeger-fetch: Traeger abgelegt ($carrier_abs) — $asset aus Release $tag, Digest verifiziert."