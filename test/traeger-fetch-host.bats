#!/usr/bin/env bats
# traeger-fetch-host.bats — Zaehne am docker-losen Träger-Fetch am Host
# (harness/tools/traeger-fetch-host.sh, Pflicht-Weg je ADR-0109).
#
# HERMETISCH: kein Docker, kein Netz — die einzige Grenze des Host-Transports
# (curl beim Download) steht als Stub vor PATH; ALLES DAHINTER laeuft real: das
# Skript entscheidet Plattform, Asset, Digest-Quelle (Makefile-Pin vs
# SHA256SUMS-Eintrag), Byte-Verifizierung VOR der Ablage und den Ablageort.
# Die dieselbe Pin-Kopplung tragende Image-Fassung des Transports haelt
# test/traeger-fetch.bats; die Kopplung Makefile-Digests↔SHA256SUMS haelt der
# Release-Schnitt (ADR-0059 Folgepflicht 2).
#
# ROT-GEGENPROBEN (AGENTS.md 3.6), je Fall der benannte Grund:
#   - Umgeht die Verifizierung den Byte-Digest gegen den Pin oder den Manifest-
#     Eintrag, faerbt der Negative-Fall rot — der Fall verdreht den Pin bzw. das
#     Manifest gegen dieselbe Fixture und braucht keinen echten Download.
#   - Faellt die fail-closed-Auflage vor dem Transport (teilweise exportierte
#     Pins ohne den eigenen, fehlender Tag, fehlendes curl), faerbt der jeweilige
#     Vorab-Fall rot — der Transport duerfte dann ohne Pruefsumme anfangen.
#
# NETZLOS, laeuft in `make gates`. Laeuft am bats-Host (kein Docker-Bild noetig).

setup() {
  bats_require_minimum_version 1.5.0
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  SKRIPT="$REPO/harness/tools/traeger-fetch-host.sh"
  TMP="$BATS_TEST_TMPDIR"
  SHIM="$TMP/bin"
  mkdir -p "$SHIM"
  cat >"$SHIM/curl" <<'ENDE'
#!/usr/bin/env bash
# Stub des Downloads (kein Netz): legt die Fixture an die Zielstelle und
# protokolliert den angeforderten URL. Ein URL auf SHA256SUMS legt das Manifest
# ab, alles andere das Asset.
set -eu
dest=""
src=""
while [ $# -gt 0 ]; do
  case "$1" in
    -o) dest="$2"; shift 2 ;;
    -*) shift ;;
    *) src="$1"; shift ;;
  esac
done
printf '%s\n' "$src" >>"$TRAEGER_HOST_SHIM_LOG"
case "$src" in
  */SHA256SUMS) cp "$TRAEGER_HOST_SHIM_SUMS" "$dest" ;;
  *) cp "$TRAEGER_HOST_SHIM_FIXTURE" "$dest" ;;
esac
ENDE
  chmod 0755 "$SHIM/curl"
  export PATH="$SHIM:$PATH"
  export TRAEGER_HOST_SHIM_LOG="$TMP/shim.log"
  : >"$TRAEGER_HOST_SHIM_LOG"
  # Fixture: ein lauffaehiges Programm als Asset-Ersatz — der Happy-Fall misst,
  # dass der abgelegte Traeger STARTET, nicht nur liegt.
  printf '#!/usr/bin/env bash\necho traeger-host-echo-ok\n' >"$TMP/fixture"
  chmod 0755 "$TMP/fixture"
  export TRAEGER_HOST_SHIM_FIXTURE="$TMP/fixture"
  FIXTURE_SHA="$(sha256sum "$TMP/fixture" | awk '{print $1}')"
  printf '%s  ai-harness-init-linux-amd64\n%s  ai-harness-init-windows-amd64.exe\n%s  ai-harness-init-linux-arm64\n' \
    "$FIXTURE_SHA" "$FIXTURE_SHA" "$FIXTURE_SHA" >"$TMP/sums"
  export TRAEGER_HOST_SHIM_SUMS="$TMP/sums"
}

@test "happy im Pin-Modus: mit exportiertem Pin verifiziert der Lauf gegen den Makefile-Pin und legt den Traeger ab, lauffaehig" {
  run env TRAEGER_TAG=v0.99.0 \
    TRAEGER_OS=Linux \
    TRAEGER_ARCH=x86_64 \
    TRAEGER_SHA256_LINUX_AMD64="$FIXTURE_SHA" \
    TRAEGER_CARRIER="$TMP/ablage/ai-harness-init" \
    bash "$SKRIPT"
  [ "$status" -eq 0 ]
  printf '%s' "$output" | grep -qF 'Digest verifiziert'
  printf '%s' "$output" | grep -qF 'docker-los am Host'
  [ -x "$TMP/ablage/ai-harness-init" ]
  run "$TMP/ablage/ai-harness-init"
  [ "$status" -eq 0 ]
  [ "$output" = "traeger-host-echo-ok" ]
  # Genau EIN Transport-Aufruf — das Asset; das Manifest wird im Pin-Modus nicht
  # angefragt (zwei Kanaele, ADR-0059 Festlegung 3).
  [ "$(grep -c . "$TRAEGER_HOST_SHIM_LOG")" -eq 1 ]
  run ! grep -qF 'SHA256SUMS' "$TRAEGER_HOST_SHIM_LOG"
  grep -qF 'releases/download/v0.99.0/ai-harness-init-linux-amd64' "$TRAEGER_HOST_SHIM_LOG"
}

@test "happy im Manifest-Modus: ohne Digest-Pin verifiziert der Lauf gegen die SHA256SUMS" {
  run env TRAEGER_TAG=v0.99.0 \
    TRAEGER_OS=Linux \
    TRAEGER_ARCH=x86_64 \
    TRAEGER_CARRIER="$TMP/ablage/ai-harness-init" \
    bash "$SKRIPT"
  [ "$status" -eq 0 ]
  printf '%s' "$output" | grep -qF 'gegen SHA256SUMS'
  [ -x "$TMP/ablage/ai-harness-init" ]
  [ "$(grep -c . "$TRAEGER_HOST_SHIM_LOG")" -eq 2 ]
  grep -qF 'releases/download/v0.99.0/SHA256SUMS' "$TRAEGER_HOST_SHIM_LOG"
}

@test "negative im Pin-Modus: Digest-Abweichung vom Pin bricht fail-closed, ohne den Traeger zu legen" {
  verdreht="$(printf '0%.0s' $(seq 64))"
  run env TRAEGER_TAG=v0.99.0 \
    TRAEGER_OS=Linux \
    TRAEGER_ARCH=x86_64 \
    TRAEGER_SHA256_LINUX_AMD64="$verdreht" \
    TRAEGER_CARRIER="$TMP/ablage/ai-harness-init" \
    bash "$SKRIPT"
  [ "$status" -ne 0 ]
  printf '%s' "$output" | grep -qF 'Digest-Abweichung'
  printf '%s' "$output" | grep -qF 'Pin'
  [ ! -e "$TMP/ablage/ai-harness-init" ]
  [ "$(grep -c . "$TRAEGER_HOST_SHIM_LOG")" -eq 1 ]
}

@test "negative im Manifest-Modus: Abweichung vom SHA256SUMS-Eintrag bricht fail-closed, ohne abzulegen (ADR-0059 Festlegung 1)" {
  fremd="$(printf 'f%.0s' $(seq 64))"
  printf '%s  ai-harness-init-linux-amd64\n' "$fremd" >"$TMP/sums-fremd"
  run env TRAEGER_TAG=v0.99.0 \
    TRAEGER_OS=Linux \
    TRAEGER_ARCH=x86_64 \
    TRAEGER_HOST_SHIM_SUMS="$TMP/sums-fremd" \
    TRAEGER_CARRIER="$TMP/ablage/ai-harness-init" \
    bash "$SKRIPT"
  [ "$status" -ne 0 ]
  printf '%s' "$output" | grep -qF 'Digest-Abweichung'
  printf '%s' "$output" | grep -qF 'SHA256SUMS'
  [ ! -e "$TMP/ablage/ai-harness-init" ]
}

@test "fail-closed vor dem Transport: teilweise exportierte Pins ohne den eigenen brechen, ohne den Transport zu rufen" {
  run env TRAEGER_TAG=v0.99.0 \
    TRAEGER_OS=Linux \
    TRAEGER_ARCH=x86_64 \
    TRAEGER_SHA256_DARWIN_AMD64="$FIXTURE_SHA" \
    TRAEGER_CARRIER="$TMP/ablage/ai-harness-init" \
    bash "$SKRIPT"
  [ "$status" -eq 2 ]
  printf '%s' "$output" | grep -qF 'TRAEGER_SHA256_LINUX_AMD64'
  [ "$(grep -c . "$TRAEGER_HOST_SHIM_LOG")" -eq 0 ]
  [ ! -d "$TMP/ablage" ]
}

@test "fail-closed vor dem Transport: fehlender Tag und fehlendes curl brechen laut am Aufruf" {
  run env TRAEGER_OS=Linux TRAEGER_CARRIER="$TMP/ablage/ai-harness-init" bash "$SKRIPT"
  [ "$status" -eq 2 ]
  printf '%s' "$output" | grep -qF 'TRAEGER_TAG'
  # Ohne curl: ein PATH, der sha256sum traegt, aber curl nicht — der Aufruf bricht
  # fail-closed und nennt den opt-in Image-Weg.
  NUR_SHA="$TMP/ohne-curl-bin"
  mkdir -p "$NUR_SHA"
  ln -sf "$(command -v sha256sum)" "$NUR_SHA/sha256sum"
  # PATH OHNE curl (auch ohne /usr/bin): der Aufruf bricht, bevor ein Download
  # anfaengt; bash absolut, weil der enge PATH bash nicht fuehrt.
  run env PATH="$NUR_SHA" \
    TRAEGER_TAG=v0.99.0 TRAEGER_CARRIER="$TMP/ablage/ai-harness-init" \
    /bin/bash "$SKRIPT"
  [ "$status" -eq 2 ]
  printf '%s' "$output" | grep -qF 'traeger-fetch-image'
  [ ! -d "$TMP/ablage" ]
}

@test "plattform-matrix: windows-Asset mit .exe, arm64-Asset ohne Suffix (LH-QA-04)" {
  run env TRAEGER_TAG=v0.99.0 TRAEGER_OS='MINGW64_NT-10.0' TRAEGER_ARCH=x86_64 \
    TRAEGER_CARRIER="$TMP/ablage/ai-harness-init.exe" bash "$SKRIPT"
  [ "$status" -eq 0 ]
  grep -qF 'releases/download/v0.99.0/ai-harness-init-windows-amd64.exe' "$TRAEGER_HOST_SHIM_LOG"
  [ -x "$TMP/ablage/ai-harness-init.exe" ]
  run env TRAEGER_TAG=v0.99.0 TRAEGER_OS=Linux TRAEGER_ARCH=aarch64 \
    TRAEGER_CARRIER="$TMP/ablage/ai-harness-init" bash "$SKRIPT"
  [ "$status" -eq 0 ]
  grep -qF 'releases/download/v0.99.0/ai-harness-init-linux-arm64' "$TRAEGER_HOST_SHIM_LOG"
}
