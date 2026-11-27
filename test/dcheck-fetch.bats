#!/usr/bin/env bats
# dcheck-fetch.bats — Zaehne am docker-losen d-check-Zugang (anonymer OCI-Pull
# nach DCHECK_DIGEST, harness/tools/dcheck-fetch.sh).
#
# HERMETISCH: kein Docker, kein Netz — der Registry-Zug steht als curl-Stub vor
# PATH; ALLES DAHINTER laeuft real: die Digest-Kette Index(=Pin) ↔ Plattform-
# Manifest ↔ Layer-Blobs wird je Blob byte-verifiziert, das tar-Member wird aus
# dem geprueften Layer extrahiert und an die Ablage gelegt (ausfuehrbar). Die
# Fixtures bauen die Byte-Kette selbst: Blob -> Manifest-Digest -> Index-Digest,
# der Index-Digest ist der Pin des Tests (derselbe Referenz-Artikel wie
# DCHECK_DIGEST aus d-check.mk am realen Pin).
#
# ROT-GEGENPROBEN (AGENTS.md 3.6), je Fall der benannte Grund:
#   - Umgeht verifiziere() die Byte-Summe (Index, Manifest oder Blob), faerbt der
#     Negative-Fall rot — der Fall serviert abweichende Bytes an derselben Stelle
#     der Kette; der Lauf bricht, ohne den Ablagepfad anzulegen.
#   - Geht der Lauf ohne Digest-Pin an (fehlende Pruefsumme, falsche Pruefform),
#     faerbt der Vorab-Fall rot — die Ablage duerfte ohne Pin entstehen.
#   - Faellt die Member-Zuordnung (kein gepruefter Layer traegt d-check), faerbt
#     der Fall rot — sonst legen gepruefte Blobs still nichts ab.
#
# NETZLOS, laeuft in `make gates`. Laeuft am bats-Host (kein Docker-Bild noetig).

setup() {
  bats_require_minimum_version 1.5.0
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  SKRIPT="$REPO/harness/tools/dcheck-fetch.sh"
  TMP="$BATS_TEST_TMPDIR"
  SHIM="$TMP/bin"
  mkdir -p "$SHIM"

  # Blob-Fixture: tar.gz mit dem Member d-check — der Happy-Fall misst, dass der
  # abgelegte Binary STARTET, nicht nur liegt.
  printf '#!/usr/bin/env sh\necho dcheck-echo-ok\n' >"$TMP/d-check"
  (cd "$TMP" && tar -czf "$TMP/blob.bin" d-check)
  blob_sha="$(sha256sum "$TMP/blob.bin" | awk '{print $1}')"

  # Blob ohne das Member (fuer den Zuordnungs-Fall): ein gepruefter Layer, der
  # kein d-check traegt.
  printf 'kein member\n' >"$TMP/leer"
  (cd "$TMP" && tar -czf "$TMP/blob2.bin" leer)
  blob2_sha="$(sha256sum "$TMP/blob2.bin" | awk '{print $1}')"

  # Verfaelschte Blob-Bytes (fuer den Blob-Mismatch-Fall): andere Bytes, als der
  # Manifest-Eintrag des Tests behauptet.
  printf 'verfaelscht' >"$TMP/blob-falsch.bin"

  # Plattform-Manifest-Bytes: traegt den Layer-Digest des Blob.
  build_manifest() {
    local blob_digest="$1" out="$2"
    printf '{"schemaVersion":2,"mediaType":"application/vnd.oci.image.manifest.v1+json","config":{"mediaType":"application/vnd.oci.image.config.v1+json","digest":"sha256:%064d","size":100},"layers":[{"mediaType":"application/vnd.oci.image.layer.v1.tar+gzip","digest":"%s","size":100}]}' \
      1 "$blob_digest" >"$out"
  }
  build_manifest "sha256:$blob_sha" "$TMP/manifest-amd64.json"
  manifest_sha="$(sha256sum "$TMP/manifest-amd64.json" | awk '{print $1}')"
  build_manifest "sha256:$blob2_sha" "$TMP/manifest-leer.json"
  manifest_leer_sha="$(sha256sum "$TMP/manifest-leer.json" | awk '{print $1}')"

  # Index-Bytes: traegt den Manifest-Digest der Plattform-Eintraege; der
  # Index-Digest ist DER Pin (DCHECK_DIGEST) des Tests.
  build_index() {
    local manifest_digest="$1" out="$2"
    printf '{"schemaVersion":2,"mediaType":"application/vnd.oci.image.index.v1+json","manifests":[{"mediaType":"application/vnd.oci.image.manifest.v1+json","digest":"%s","size":100,"platform":{"architecture":"amd64","os":"linux"}},{"mediaType":"application/vnd.oci.image.manifest.v1+json","digest":"%s","size":100,"platform":{"architecture":"arm64","os":"linux"}}]}' \
      "$manifest_digest" "$manifest_digest" >"$out"
  }
  build_index "sha256:$manifest_sha" "$TMP/index.json"
  index_sha="$(sha256sum "$TMP/index.json" | awk '{print $1}')"
  build_index "sha256:$manifest_leer_sha" "$TMP/index-leer.json"
  index_leer_sha="$(sha256sum "$TMP/index-leer.json" | awk '{print $1}')"

  # curl-Stub: Registry-Zug ohne Netz — Token-Handshake auf stdout, Index/
  # Manifest/Blob je Digest aus einer Byte-Map an die Zielstelle.
  cat >"$SHIM/curl" <<'ENDE'
#!/usr/bin/env bash
set -eu
dest=""
url=""
while [ $# -gt 0 ]; do
  case "$1" in
    -o) dest="$2"; shift 2 ;;
    -*) shift ;;
    *) url="$1"; shift ;;
  esac
done
printf '%s\n' "$url" >>"$DCHK_SHIM_LOG"
digest=""
case "$url" in
  */token?*) printf '{"token":"stub-token"}'; exit 0 ;;
  */manifests/*) digest="${url##*/manifests/}" ;;
  */blobs/*) digest="${url##*/blobs/}" ;;
  *) printf 'unknown URL' >&2; exit 1 ;;
esac
[ -n "$dest" ] || exit 1
quelle="$(awk -F'\t' -v key="$digest" '$1 == key { print $2; exit }' "$DCHK_SHIM_MAP")"
[ -n "$quelle" ] || {
  printf '404' >&2
  exit 22
}
if [ "${DCHK_SHIM_VERFAELSCHT_BLOB:-}" = "1" ] && [ "${digest:+x}" = "x" ] && case "$url" in */blobs/*) true ;; *) false ;; esac; then
  printf 'andere-bytes' >"$dest"
else
  cp "$quelle" "$dest"
fi
ENDE
  chmod 0755 "$SHIM/curl"
  export PATH="$SHIM:$PATH"
  export DCHK_SHIM_LOG="$TMP/shim.log"
  : >"$DCHK_SHIM_LOG"
  printf '%s\t%s\n%s\t%s\n%s\t%s\n%s\t%s\n' \
    "sha256:$blob_sha" "$TMP/blob.bin" \
    "sha256:$blob2_sha" "$TMP/blob2.bin" \
    "sha256:$manifest_sha" "$TMP/manifest-amd64.json" \
    "sha256:$manifest_leer_sha" "$TMP/manifest-leer.json" >"$TMP/map"
  printf 'sha256:%s\t%s\n' "$index_leer_sha" "$TMP/index-leer.json" >>"$TMP/map"
  printf 'sha256:%s\t%s\n' "$index_sha" "$TMP/index.json" >>"$TMP/map"
  export DCHK_SHIM_MAP="$TMP/map"
}

@test "fail-closed vor dem Registry-Zug: fehlende Pruefsumme und falsche Pruefform brechen, ohne abzulegen" {
  run env DCHK_SHIM_MAP="$DCHK_SHIM_MAP" DCHK_SHIM_LOG="$DCHK_SHIM_LOG" \
    DCHECK_IMAGE='ghcr.io/pt9912/d-check:v0.99.0' \
    DCHECK_CARRIER="$TMP/ablage/d-check" \
    bash "$SKRIPT"
  [ "$status" -eq 2 ]
  printf '%s' "$output" | grep -qF 'fehlende Prüfsumme an gepinntem Tag'
  [ "$(grep -c . "$DCHK_SHIM_LOG")" -eq 0 ]
  [ ! -d "$TMP/ablage" ]
  run env DCHECK_IMAGE='ghcr.io/pt9912/d-check:v0.99.0' DCHECK_DIGEST='nur-ein-wort' \
    DCHECK_CARRIER="$TMP/ablage/d-check" \
    bash "$SKRIPT"
  [ "$status" -eq 2 ]
  printf '%s' "$output" | grep -qF 'Pruefform sha256'
  [ "$(grep -c . "$DCHK_SHIM_LOG")" -eq 0 ]
}

@test "happy: die Kette Pin↔Index↔Manifest↔Blobs traegt, das Member wird gelegt und startet, docker-los" {
  run env DCHECK_IMAGE='ghcr.io/pt9912/d-check:v0.99.0' \
    DCHECK_DIGEST="sha256:$index_sha" \
    DCHECK_ARCH=amd64 \
    DCHECK_CARRIER="$TMP/ablage/d-check" \
    bash "$SKRIPT"
  [ "$status" -eq 0 ]
  printf '%s' "$output" | grep -qF "Pull nach sha256:$index_sha"
  printf '%s' "$output" | grep -qF 'docker-los'
  [ -x "$TMP/ablage/d-check" ]
  run "$TMP/ablage/d-check"
  [ "$status" -eq 0 ]
  [ "$output" = "dcheck-echo-ok" ]
  # Die Kette: Token, Index, Manifest, Blob — je nach Digest; der Blob des
  # Binary-Layers und die 12 Leichtgewichte der Fixtures sind in der Byte-Map.
  grep -qF '/token?' "$DCHK_SHIM_LOG"
  grep -qF "/manifests/sha256:$index_sha" "$DCHK_SHIM_LOG"
  grep -qF "/manifests/sha256:$manifest_sha" "$DCHK_SHIM_LOG"
  grep -qF "/blobs/sha256:$blob_sha" "$DCHK_SHIM_LOG"
}

@test "negative: abweichende Index-Bytes gegen den Pin brechen fail-closed, ohne abzulegen" {
  # Die Byte-Map serviert fuer den gepinnten Digest ANDERE Bytes als die, die der
  # Pin hasht — die erste Stelle der Kette faerbt.
  printf '%s\t%s\n' "sha256:$index_sha" "$TMP/blob-falsch.bin" >>"$TMP/map2"
  run env DCHK_SHIM_MAP="$TMP/map2" DCHK_SHIM_LOG="$TMP/shim2.log" \
    DCHECK_IMAGE='ghcr.io/pt9912/d-check:v0.99.0' \
    DCHECK_DIGEST="sha256:$index_sha" \
    DCHECK_ARCH=amd64 \
    DCHECK_CARRIER="$TMP/ablage/d-check" \
    bash "$SKRIPT"
  [ "$status" -eq 1 ]
  printf '%s' "$output" | grep -qF 'Abweichung bei Index-Bytes gegen den Digest-Pin'
  [ ! -d "$TMP/ablage" ]
  # Kein Blob geladen, bevor die Stelle geprueft war.
  run ! grep -qF '/blobs/' "$TMP/shim2.log"
}

@test "negative: abweichende Layer-Blob-Bytes gegen den Manifest-Eintrag brechen fail-closed, ohne abzulegen" {
  run env DCHK_SHIM_MAP="$DCHK_SHIM_MAP" DCHK_SHIM_LOG="$TMP/shim3.log" \
    DCHK_SHIM_VERFAELSCHT_BLOB=1 \
    DCHECK_IMAGE='ghcr.io/pt9912/d-check:v0.99.0' \
    DCHECK_DIGEST="sha256:$index_sha" \
    DCHECK_ARCH=amd64 \
    DCHECK_CARRIER="$TMP/ablage/d-check" \
    bash "$SKRIPT"
  [ "$status" -eq 1 ]
  printf '%s' "$output" | grep -qF 'Abweichung bei Layer-Blob-Bytes'
  [ ! -d "$TMP/ablage" ]
}

@test "negative: kein gepruefter Layer traegt ein Member d-check — bricht laut, ohne abzulegen" {
  run env DCHK_SHIM_MAP="$DCHK_SHIM_MAP" DCHK_SHIM_LOG="$TMP/shim4.log" \
    DCHECK_IMAGE='ghcr.io/pt9912/d-check:v0.99.0' \
    DCHECK_DIGEST="sha256:$index_leer_sha" \
    DCHECK_ARCH=amd64 \
    DCHECK_CARRIER="$TMP/ablage/d-check" \
    bash "$SKRIPT"
  [ "$status" -eq 1 ]
  printf '%s' "$output" | grep -qF 'kein gepruefter Layer'
  printf '%s' "$output" | grep -qF 'd-check'
  [ ! -d "$TMP/ablage" ]
}

@test "fail-closed vor dem Registry-Zug: nicht-tragende Host-Plattform und unbekannte Architektur brechen laut" {
  run env DCHECK_IMAGE='ghcr.io/pt9912/d-check:v0.99.0' DCHECK_DIGEST="sha256:$index_sha" \
    DCHECK_ARCH=sparc64 DCHECK_CARRIER="$TMP/ablage/d-check" bash "$SKRIPT"
  [ "$status" -eq 2 ]
  printf '%s' "$output" | grep -qF 'unbekannte Architektur'
}
