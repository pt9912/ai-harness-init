#!/usr/bin/env bash
# traeger-fetch-host.sh — docker-lose Fassung des Träger-Fetch (ADR-0109: docker-los
# ist der Pflicht-Weg; der Transport im gepinnten Bild bleibt opt-in als
# `make traeger-fetch-image`). Dieselbe Pin-Kopplung wie der Transport im Bild:
# Tag-Pin + Prüfsumme je Asset, Paarung nach Asset-Name, ADR-0059-Form (LH-QA-02).
#
# TRANSPORT AM HOST: curl + HTTPS + sha256sum — kein Daemon, kein zweiter Kontext.
# Ablageort UNVERÄNDERT: gitignoriertes .harness/state/ (TRAEGER_CARRIER).
#
# FAIL-CLOSED, alle VOR der Ablage (dieselben Punkte wie der Transport im Bild):
# fehlt der Release-Pin, fehlt bei TEILWEISE exportierten Digest-Pins der eigene
# der Plattform, fehlt das Asset im Manifest, oder weicht der Byte-Digest des
# geholten Assets ab — der Lauf bricht, ohne den Träger zu legen, ohne den
# Ablagepfad anzulegen. Ohne curl bricht er laut am Aufruf, statt still zu
# scheitern: der Pflichtgrad `optional` der Inventar-Zeile curl trägt die Gates,
# nicht diesen Fetch.
#
# NETZ an genau diesem Aufruf; kein Gate, keine Prerequisite-Kette (dieselbe
# Ordnung wie der Transport im Bild: der Fehlt-Fall der Konsumenten bleibt).
set -euo pipefail

brauch() {
	command -v "$1" >/dev/null 2>&1 || {
		echo "traeger-fetch: $1 fehlt am Host — der docker-lose Zug braucht es an diesem Aufruf; der Transport im gepinnten Bild ist opt-in (make traeger-fetch-image)." >&2
		exit 2
	}
}
brauch curl
brauch sha256sum

# Plattform des HOSTS — das Asset muss zur Maschine passen, die den Träger
# startet. Closed Set je Achse (Asset-Matrix der Release, LH-QA-04): alles
# andere bricht laut, statt ein Asset zu raten. Overrides wie beim Transport
# im Bild (TRAEGER_OS/TRAEGER_ARCH) für den fest verdrahteten bats-Lauf.
os="${TRAEGER_OS:-$(uname -s)}"
arch="${TRAEGER_ARCH:-$(uname -m)}"
case "$os" in
Linux) plat="linux" ;;
Darwin) plat="darwin" ;;
MINGW* | MSYS* | CYGWIN*) plat="windows" ;;
*)
	echo "traeger-fetch: unbekannte Plattform (uname -s: $os) — die Asset-Matrix fuehrt linux, darwin, windows." >&2
	exit 2
	;;
esac
case "$arch" in
x86_64 | amd64) a="amd64" ;;
aarch64 | arm64) a="arm64" ;;
*)
	echo "traeger-fetch: unbekannte Architektur (uname -m: $arch) — die Asset-Matrix fuehrt amd64, arm64." >&2
	exit 2
	;;
esac
plat_u="$(printf '%s' "$plat" | tr '[:lower:]' '[:upper:]')"
arch_u="$(printf '%s' "$a" | tr '[:lower:]' '[:upper:]')"

asset="ai-harness-init-${plat}-${a}"
carrier="${TRAEGER_CARRIER:-.harness/state/bin/ai-harness-init}"
if [ "$plat" = "windows" ]; then
	asset="${asset}.exe"
	case "$carrier" in
	*.exe) ;;
	*) carrier="${carrier}.exe" ;;
	esac
fi

# Der erwartete Digest: eigener Pin der Plattform, oder Manifest-Eintrag der
# SHA256SUMS desselben Releases. TEILWEISE exportierte Pins ohne den eigenen
# brechen, BEVOR der Lauf anfaengt — eine stehen gebliebene Pin-Stelle fällt
# nicht still in den Manifest-Kanal (ADR-0059 Festlegung 3).
sha_var="TRAEGER_SHA256_${plat_u}_${arch_u}"
sha="${!sha_var:-}"
teilweise=""
for p in LINUX_AMD64 LINUX_ARM64 DARWIN_AMD64 DARWIN_ARM64 WINDOWS_AMD64 WINDOWS_ARM64; do
	name="TRAEGER_SHA256_$p"
	if [ -n "${!name:-}" ]; then teilweise=ja; fi
done
if [ -z "$sha" ] && [ -n "$teilweise" ]; then
	echo "traeger-fetch: $sha_var ist nicht gesetzt, aber andere Digest-Pins sind es — eine Pin-Stelle der Kopplung fehlt; der Lauf bricht, statt still gegen das Manifest zu verifizieren." >&2
	exit 2
fi
tag="${TRAEGER_TAG:-}"
if [ -z "$tag" ]; then
	echo "traeger-fetch: TRAEGER_TAG ist nicht gesetzt — der Release-Pin fehlt." >&2
	exit 2
fi
url="https://github.com/pt9912/ai-harness-init/releases/download/${tag}/${asset}"
sums_url="https://github.com/pt9912/ai-harness-init/releases/download/${tag}/SHA256SUMS"

tmp="$(mktemp -d "${TMPDIR:-/tmp}/traeger-fetch-host.XXXXXXXX")"
trap 'rm -rf "$tmp"' EXIT

# Das erwartete Digest: eigener Pin, oder der Manifest-Eintrag der Plattform —
# Manifest und Asset reisen vom selben Release; ein fehlender Eintrag bricht
# laut, legt nichts ab (ADR-0059 Festlegung 1).
quelle="Pin"
if [ -z "$sha" ]; then
	curl -fsSL -o "$tmp/sums" "$sums_url"
	sha="$(awk -v a="$asset" '$2 == a { print $1; exit }' "$tmp/sums")"
	if [ -z "$sha" ]; then
		echo "traeger-fetch: $asset fehlt im Manifest (SHA256SUMS) — der Manifest-Eintrag seiner Plattform fehlt; der Lauf legt nichts ab." >&2
		exit 1
	fi
	quelle="SHA256SUMS"
fi

curl -fsSL -o "$tmp/asset" "$url"
ist="$(sha256sum "$tmp/asset")" && ist="${ist%% *}"
if [ "$ist" != "$sha" ]; then
	echo "traeger-fetch: Digest-Abweichung — ist $ist, erwartet $sha (aus $quelle). Der Traeger wird nicht abgelegt." >&2
	exit 1
fi

mkdir -p "$(dirname "$carrier")"
cp "$tmp/asset" "$carrier"
chmod 0755 "$carrier"

echo "traeger-fetch: Traeger abgelegt ($(cd "$(dirname "$carrier")" && pwd)/$(basename "$carrier")) — $asset aus Release $tag, Digest verifiziert gegen $quelle (docker-los am Host)."
