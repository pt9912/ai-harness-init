#!/usr/bin/env bash
# dcheck-fetch.sh — das d-check-Binary docker-los ziehen: anonymer OCI-Pull nach
# dem digest-gepinnten Manifest (ADR-0109, docker-los Pflicht-Weg, Image-Weg opt-in).
#
# WEG: anonymer OCI-Pull nach dem gesetzten DCHECK_DIGEST (d-check.mk) über
# ghcr.io — Registry und Repo stehen an derselben DCHECK_IMAGE-Stelle wie beim
# Image-Weg; der Token-Handshake dieses Zugangs ist gegen ghcr.io gepragt, andere
# Registrys traegt er nicht (hartes Pruefen unten, fail-closed).
# Pin-Form Tag + Prüfsumme je ADR-0059 (LH-QA-02), fail-closed vor der Ablage.
#
# HERKUNFT: Kopie der Lab-Fassung des erzeugenden Werkzeugs (dcheck-fetch.sh
# unter harness/tools/) — ab der ersten Anweisungs-Zeile (`set -euo pipefail`)
# Zeile fuer Zeile identisch mit ihr, gehalten vom Emissions-Waechter in
# internal/emit/environment_test.go; die Pin-Quelle ist im Ziel dieselbe Stelle
# (DCHECK_IMAGE/DCHECK_DIGEST aus d-check.mk, vom Make-Rezept gesetzt), die
# Ablage dasselbe Verzeichnis.
#
# FAIL-CLOSED: fehlt der Digest-Pin, haftet die Pruefform sha256:<64-hex> nicht,
# weicht Index, Manifest oder ein Blob von seiner Summe ab, nennt der Index kein
# linux-Manifest der Host-Architektur, traegt ein Layer eine nicht gepinnte
# Medienform — der Lauf bricht, ohne den Ablagepfad anzulegen. Ohne
# curl/sha256sum/tar bricht er laut am Aufruf: der docker-lose Zug braucht diese
# Werkzeuge an genau diesem Aufruf (Inventar: tar optional — die Gates tragen es
# nicht, dieser Fetch schon).
#
# NETZ an genau diesem Aufruf; kein Gate, keine Prerequisite-Kette.
set -euo pipefail

DCHECK_IMAGE="${DCHECK_IMAGE:-}"
DCHECK_DIGEST="${DCHECK_DIGEST:-}"
ablage="${DCHECK_CARRIER:-.harness/state/bin/d-check}"

brauch() {
	command -v "$1" >/dev/null 2>&1 || {
		echo "dcheck-fetch: $1 fehlt am Host — der docker-lose Zug braucht es an diesem Aufruf." >&2
		exit 2
	}
}
brauch curl
brauch sha256sum
brauch tar

[ -n "$DCHECK_IMAGE" ] || {
	echo "dcheck-fetch: DCHECK_IMAGE ist nicht gesetzt — kein Tag-Pin." >&2
	exit 2
}
[ -n "$DCHECK_DIGEST" ] || {
	echo "dcheck-fetch: DCHECK_DIGEST ist nicht gesetzt — fehlende Prüfsumme an gepinntem Tag (d-check.mk); fail-closed." >&2
	exit 2
}
# Pruefform exakt sha256:<64-hex> — 63- oder 65-hex tragen sie nicht (fail-closed).
if ! [[ "$DCHECK_DIGEST" =~ ^sha256:[0-9a-f]{64}$ ]]; then
	echo "dcheck-fetch: DCHECK_DIGEST trägt nicht die Pruefform sha256:<64-hex> ($DCHECK_DIGEST) — fail-closed." >&2
	exit 2
fi

# Ref-Zerlegung aus dem Tag-Pin: ghcr.io/pt9912/d-check:v0.93.0 -> Registry ghcr.io,
# Repo pt9912/d-check. Die Registry wird HARD gegen die gepragte Quelle gehalten:
# Image-Weg und dieser Zug ziehen dieselbe Summe, und ein DCHECK_IMAGE mit
# fremdem Registry-Praefix liesse die zwei Wege denselben Pin aus verschiedenen
# Urspruengen lesen — der Lauf bricht, statt das Praefix still durchzulassen.
ref="${DCHECK_IMAGE%:*}"
registry="${ref%%/*}"
repo="${ref#*/}"
if [ "$registry" != "ghcr.io" ]; then
	echo "dcheck-fetch: Registry '$registry' aus DCHECK_IMAGE ist nicht die gepraegte Quelle (ghcr.io) — der Zug zieht keine Summe aus einem anderen Ursprung; fail-closed." >&2
	exit 2
fi
case "$DCHECK_IMAGE" in
*:* | */*) ;;
*)
	echo "dcheck-fetch: DCHECK_IMAGE traegt keine Registry/Repo-Form ($DCHECK_IMAGE)." >&2
	exit 2
	;;
esac

# Host-Plattform: der docker-lose Weg laeuft am Linux-Host (AGENTS.md 3.9); die
# Image-Index-Plattform-Menge des Pins ist linux/amd64 + linux/arm64.
os="$(uname -s)"
if [ "$os" != "Linux" ]; then
	echo "dcheck-fetch: Host-OS ist $os — der docker-lose Zug fuer d-check traegt linux (Index-Plattform-Menge); der Image-Weg bleibt Weg fuer die uebrige Plattform." >&2
	exit 2
fi
arch="${DCHECK_ARCH:-$(uname -m)}"
case "$arch" in
x86_64 | amd64) a="amd64" ;;
aarch64 | arm64) a="arm64" ;;
*)
	echo "dcheck-fetch: unbekannte Architektur (uname -m: $arch) — der Index des Pins fuehrt amd64, arm64." >&2
	exit 2
	;;
esac

tmp="$(mktemp -d "${TMPDIR:-/tmp}/dcheck-fetch.XXXXXXXX")"
trap 'rm -rf "$tmp"' EXIT

verifiziere() {
	# verifiziere <datei> <erwartet-hex> <gegenstand> — eine Abweichung bricht
	# fail-closed, ohne abzulegen.
	local ist
	ist="$(sha256sum "$1")" && ist="${ist%% *}"
	if [ "$ist" != "$2" ]; then
		echo "dcheck-fetch: Abweichung bei $3 — ist $ist, erwartet $2 (Pin $DCHECK_DIGEST). Nichts abgelegt." >&2
		exit 1
	fi
}

token="$(curl -fsS --max-time 60 "https://$registry/token?scope=repository:$repo:pull" \
	| sed -n 's/.*"token":"\([^"]*\)".*/\1/p')"
[ -n "$token" ] || {
	echo "dcheck-fetch: kein Pull-Token vom Token-Handshake — anonym gegen $registry nicht durchkommen." >&2
	exit 2
}

index_media='application/vnd.oci.image.manifest.v1+json, application/vnd.oci.image.index.v1+json, application/vnd.docker.distribution.manifest.v2+json, application/vnd.docker.distribution.manifest.list.v2+json'
curl -fsS --max-time 60 -H "Authorization: Bearer $token" -H "Accept: $index_media" \
	-o "$tmp/index.json" "https://$registry/v2/$repo/manifests/$DCHECK_DIGEST"
verifiziere "$tmp/index.json" "${DCHECK_DIGEST#sha256:}" "Index-Bytes gegen den Digest-Pin"

# Plattform-Manifest SUCHEN AM INDEX-EINTRAG (das Manifest selbst traegt keine
# architecture — nur sein Eintrag im Index); die Manifest-Bytes werden danach
# IMMER gegen ihren Index-Digest geprueft.
index_flat="$(tr -d '[:space:]' <"$tmp/index.json")"
manifest_digest="$(printf '%s' "$index_flat" \
	| grep -oE '"mediaType":"(application/vnd\.oci\.image\.manifest\.v1\+json|application/vnd\.docker\.distribution\.manifest\.v2\+json)","digest":"sha256:[a-f0-9]{64}","size":[0-9]+,"platform":\{"architecture":"'"$a"'","os":"linux"\}' \
	| grep -oE 'sha256:[a-f0-9]{64}' | head -n1 || true)"
[ -n "$manifest_digest" ] || {
	echo "dcheck-fetch: der Index des Pins traegt kein linux/$a-Plattform-Manifest." >&2
	exit 2
}
curl -fsS --max-time 60 -H "Authorization: Bearer $token" -H "Accept: $index_media" \
	-o "$tmp/platform.json" "https://$registry/v2/$repo/manifests/$manifest_digest"
verifiziere "$tmp/platform.json" "${manifest_digest#sha256:}" "Plattform-Manifest-Bytes gegen den Index-Eintrag"

# Layer-Zuordnung: die Medienform steht JE LAYER im Manifest (an den Content
# gebunden, dessen Digest der Manifest-Eintrag traegt) und entscheidet gzip
# oder plain — ein plain-Layer faehrt denselben Weg ohne das z-Glied.
platform_flat="$(tr -d '[:space:]' <"$tmp/platform.json")"
geladen=0
layereintraege="$(printf '%s' "$platform_flat" \
	| grep -oE '"mediaType":"[^"]*image\.layer[^"]*","digest":"sha256:[a-f0-9]{64}"' || true)"
[ -n "$layereintraege" ] || {
	echo "dcheck-fetch: das Plattform-Manifest nennt keinen tar-Layer — Medienform nicht getragen." >&2
	exit 2
}
gefunden=""
for eintrag in $layereintraege; do
	media="$(printf '%s' "$eintrag" | sed -n 's/.*"mediaType":"\([^"]*\)".*/\1/p')"
	d="$(printf '%s' "$eintrag" | sed -n 's/.*"digest":"\(sha256:[a-f0-9]*\)".*/\1/p')"
	case "$media" in
	*+gzip) zflag="z" ;;
	*v1.tar) zflag="" ;;
	*)
		echo "dcheck-fetch: Layer-Medienform '$media' ist nicht getragen (tar oder tar+gzip) — fail-closed, nichts abgelegt." >&2
		exit 2
		;;
	esac
	blob="$tmp/layer.tar"
	curl -fsSL --max-time 120 -H "Authorization: Bearer $token" -o "$blob" \
		"https://$registry/v2/$repo/blobs/$d"
	verifiziere "$blob" "${d#sha256:}" "Layer-Blob-Bytes gegen den Manifest-Eintrag"
	member="$(tar -t${zflag}f "$blob" | grep -E '(^|/)d-check$' | head -n1 || true)"
	if [ -n "$member" ]; then
		extract="$tmp/extract"
		mkdir -p "$extract"
		tar -x${zflag}f "$blob" -C "$extract" "$member"
		gefunden="$extract/$member"
		geladen=$((geladen + 1))
		break
	fi
	geladen=$((geladen + 1))
done
if [ -z "$gefunden" ]; then
	echo "dcheck-fetch: kein gepruefter Layer traegt ein Member d-check — die Zuordnung Pin zu Binary ist entfallen; nichts abgelegt." >&2
	exit 1
fi

mkdir -p "$(dirname "$ablage")"
cp "$gefunden" "$ablage"
chmod 0755 "$ablage"

echo "dcheck-fetch: d-check abgelegt ($(cd "$(dirname "$ablage")" && pwd)/$(basename "$ablage")) — Pull nach $DCHECK_DIGEST, $geladen Layer geprueft (anonymer OCI-Zug, docker-los)."
