#!/usr/bin/env bash
# dcheck-fetch.sh — das d-check-Binary docker-los ziehen: anonymer OCI-Pull nach
# dem digest-gepinnten Manifest (ADR-0109, Wegwahl docker-los Pflicht und Image-Weg
# opt-in; Pin-Form Tag + Prüfsumme je ADR-0059 mit LH-QA-02).
#
# WEG-WAHL — an der Messung entschieden (slice-binraire-ziehen-ohne-docker), nicht
# am Wunsch, Kandidaten in dieser Reihenfolge:
#   (a) GitHub-Release der Quelle github.com/pt9912/d-check traegt KEIN Asset —
#       "assets": [] (api.github.com/repos/pt9912/d-check/releases/latest,
#       gemessen am Schnitt des Pins v0.93.0): kein pinierbares Release-Binary.
#   (b) GEWAEHLT — anonymer OCI-Pull nach Digest gegen ghcr.io: Token-Handshake
#       (GET <registry>/token?scope=repository:<repo>:pull), Index/Manifest je nach
#       Digest, Blobs je nach Layer-Digest, tar -x aus dem geprueften Layer. Der
#       Pin ist DER gesetzte DCHECK_DIGEST aus d-check.mk — SELBE Stelle wie der
#       Image-Weg (`docker run …@sha256:` referenziert dieselbe Manifest-/Index-
#       Summe), kein zweiter Pin-Bestand; die pinsync-Paarung d-check.mk gegen
#       internal/emit/emit.go bleibt unberuehrt.
#   (c) Klon am Pin-Commit + `go build` wäre der Fallback — nicht nötig: er haengte
#       an einer zweiten Pin-Stelle (Source-Tarball, der kein Pruefsummen-Asset
#       reist) und an Host-go als Werkzeug-Kette.
#
# DIE ZUORDNUNG DIGEST ↔ BINARY (an DIESER Stelle dokumentiert, an keiner zweiten):
#   1. Die Index-Bytes hashen exakt auf DCHECK_DIGEST — die Summe, die `docker run
#      …@sha256:` referenziert (gemessen als OCI-Index, Mehrplattform).
#   2. Der Index nennt je Plattform deren Manifest-Digest; die Manifest-Bytes
#      hashen auf ihren Eintrag (geprueft hier).
#   3. Das Manifest nennt je Layer ihren Blob-Digest; die Blob-Bytes hashen darauf
#      (geprueft je Blob hier).
#   4. Das Binary wird aus einem geprueften Layer extrahiert (tar). WAS DIE KETTE
#      NICHT EIGEN PINT: das tar-Member selbst — sein Name (d-check) traegt die
#      Zuordnung als Formular-Match, seine Bytes haengen an der Layer-Kette.
#
# FAIL-CLOSED: fehlt der Digest-Pin, haftet die Pruefform sha256: nicht, weicht
# Index, Manifest oder ein Blob von seiner Summe ab, nennt der Index kein linux-
# Manifest der Host-Architektur — der Lauf bricht, ohne den Ablagepfad anzulegen.
# Ohne curl/sha256sum/tar bricht er laut am Aufruf: der docker-lose Zug braucht
# diese Werkzeuge an genau diesem Aufruf (Inventar: tar optional — die Gates
# tragen es nicht, dieser Fetch schon).
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
case "$DCHECK_DIGEST" in
sha256:[0-9a-f][0-9a-f]*) ;;
*)
	echo "dcheck-fetch: DCHECK_DIGEST trägt nicht die Pruefform sha256:<64-hex> ($DCHECK_DIGEST) — fail-closed." >&2
	exit 2
	;;
esac

# Ref-Zerlegung aus dem Tag-Pin: ghcr.io/pt9912/d-check:v0.93.0 -> Registry ghcr.io,
# Repo pt9912/d-check. Der Token-Handshake ist hier fuer ghcr.io gemessen; andere
# Registries traegt dieser Weg nicht.
ref="${DCHECK_IMAGE%:*}"
registry="${ref%%/*}"
repo="${ref#*/}"
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
	| grep -oE 'sha256:[a-f0-9]{64}' | head -n1)"
[ -n "$manifest_digest" ] || {
	echo "dcheck-fetch: der Index des Pins traegt kein linux/$a-Plattform-Manifest." >&2
	exit 2
}
curl -fsS --max-time 60 -H "Authorization: Bearer $token" -H "Accept: $index_media" \
	-o "$tmp/platform.json" "https://$registry/v2/$repo/manifests/$manifest_digest"
verifiziere "$tmp/platform.json" "${manifest_digest#sha256:}" "Plattform-Manifest-Bytes gegen den Index-Eintrag"

# Layer-Zuordnung: Media-Form entscheidet gzip oder plain (gepinnt am Content,
# dessen Form damit an den Manifest-Digest gebunden ist).
platform_flat="$(tr -d '[:space:]' <"$tmp/platform.json")"
geladen=0
layerdigests="$(printf '%s' "$platform_flat" \
	| grep -oE '"mediaType":"[^"]*image\.layer\.v1\.tar(\+gzip)?","digest":"sha256:[a-f0-9]{64}"' \
	| sed -n 's/.*"digest":"\(sha256:[a-f0-9]*\)".*/\1/p')"
[ -n "$layerdigests" ] || {
	echo "dcheck-fetch: das Plattform-Manifest nennt keinen tar-Layer — Medienform nicht getragen." >&2
	exit 2
}
gefunden=""
for d in $layerdigests; do
	blob="$tmp/layer.tar.gz"
	curl -fsSL --max-time 120 -H "Authorization: Bearer $token" -o "$blob" \
		"https://$registry/v2/$repo/blobs/$d"
	verifiziere "$blob" "${d#sha256:}" "Layer-Blob-Bytes gegen den Manifest-Eintrag"
	member="$(tar -tzf "$blob" | grep -E '(^|/)d-check$' | head -n1 || true)"
	if [ -n "$member" ]; then
		extract="$tmp/extract"
		mkdir -p "$extract"
		tar -xzf "$blob" -C "$extract" "$member"
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
