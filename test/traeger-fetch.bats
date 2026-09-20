#!/usr/bin/env bats
# traeger-fetch.bats — Zaehne fuer den Traeger-Fetch (ADR-0058) und fuer die
# Pin-Kopplung, die ihn traegt.
#
# HERMETISCH: kein Docker, kein Netz, kein Download — die zwei Grenzen des Transports
# (docker-Daemon, curl im Bild) sind im bats-Image durch Stubs ersetzt, und ALLES
# DAHINTER laeuft real: das Skript entscheidet Plattform, Asset, Digest-Quelle und
# Ablageort, und das Payload des Transport-Bilds — Verifizierung VOR Ablage, Ablage
# erst nach dem Digest — wird als derselbe String gefahren, den der echte Lauf dem
# gepinnten Bild uebergibt (dieselbe Bauart wie test/commit-msg-hook.bats: der Aufruf
# laeuft ueber den Hook, ohne git). Dass auch die Grenzen real sind, misst die E2E-Stufe
# in harness/tools/full-smoke.sh am gebootstrappten Ziel (traeger_fetch_im_ziel).
#
# DIE KOPPLUNG (ADR-0058 Festlegung 1, Dogfood-Haelfte; ADR-0059 Festlegung 2 und
# Folgepflicht 2, Klasse test/sources-pin.bats): die kanonische Pin-Stelle ist das
# Makefile-Paar (TRAEGER_TAG + die sechs sha256 der Assets, LH-QA-04) — NICHT embedded,
# zur Schnitt-Zeit schreibbar, ohne die Binary zu bewegen. Das emittierte Fragment
# fuehrt NUR den Tag: das Binary traegt keinen Wert, der vom Bau-Ergebnis abhaengt;
# sein Fetch verifiziert gegen die SHA256SUMS desselben Releases (ADR-0059 Festlegung 1).
# Die Kopplung Makefile-Digests↔SHA256SUMS haelt der Release-Schnitt — wo ein Lauf das
# Release erreicht (CI mit Netz); im netzlosen Gate unpruefbar, benannt.
#
# ROT-GEGENPROBEN (AGENTS.md 3.6), je Fall der benannte Grund:
#   - Umgeht die Verifizierung den Digest — gegen den Makefile-Pin oder gegen den
#     Manifest-Eintrag (Abweichung bricht, Traeger bleibt liegen) —, faerbt der
#     Negative-Fall rot; der Fall verdreht den Pin bzw. das Manifest gegen dasselbe
#     Asset und braucht keinen echten Download.
#   - Traegt das emittierte Fragment einen Digest-Wert, faerbt der Fragment-Fall rot —
#     das Binary duerfte dann einen Wert fuehren, der vom Bau-Ergebnis abhaengt
#     (ADR-0059 Festlegung 2, die Selbstreferenz-Wand).
#   - Laesst die Kopplung im Dogfood eine Digest-Stelle stehen, waehrend andere
#     exportiert sind, faerbt der Teilweise-Fall rot — der Lauf bricht, statt still
#     in den Manifest-Kanal zu fallen (ADR-0059 Festlegung 3).
#   - Haengt der Fetch als Prerequisite an archive-welle oder an GATE_CHECKS, faerbt
#     der Fehlt-Fall-Zahn rot — die Zusage "Exit 0, nennt das Fehlende, schreibt
#     nichts" wuerde still zu einem Netz-Download-Versuch (ADR-0058 Festlegung 3).
#
# Der Transport-Skript-Zwilling (Dogfood harness/tools/ vs. emittiert tools/harness/)
# ist byte-gekoppelt — dieselbe Linie wie test/commit-msg-emission.bats.
#
# NETZLOS, laeuft in `make gates`. Docker-only (bats-Image).

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  MK="$REPO/Makefile"
  FRAG="$REPO/internal/emit/templates/enforce/traeger.mk"
  SKRIPT="$REPO/harness/tools/traeger-fetch.sh"
  SKRIPT_EMITT="$REPO/internal/emit/templates/enforce/traeger-fetch.sh"
  ARCHIV="$REPO/internal/emit/templates/enforce/archivierung.mk"
  TMP="$BATS_TEST_TMPDIR"
  # Stub-Grenzen: ein docker, der nur die -e-Umgebung an das Payload durchreicht und
  # dieses faehrt, und ein curl, der statt zu laden die Fixture ablegt. Beide liegen
  # vor PATH; der echte Lauf im Bild sieht sie nie.
  SHIM="$TMP/bin"
  mkdir -p "$SHIM"
  cat >"$SHIM/docker" <<'ENDE'
#!/usr/bin/env bash
# Stub des Transport-Bilds (bats-Image ohne docker): reicht die -e-Umgebung an das
# Payload durch und faehrt dieses als dasselbe sh -c, das der echte Lauf bekommt.
set -eu
payload=""
envs=()
while [ $# -gt 0 ]; do
  case "$1" in
    -e) envs+=("$2"); shift 2 ;;
    -c) payload="$2"; shift 2 ;;
    *) shift ;;
  esac
done
for e in "${envs[@]}"; do export "$e"; done
exec sh -c "$payload"
ENDE
  cat >"$SHIM/curl" <<'ENDE'
#!/usr/bin/env bash
# Stub des Downloads (bats-Image ohne Netz): legt die Fixture an die Stelle, an die
# der echte Lauf das Asset laedt, und protokolliert den angeforderten URL. Ein URL
# auf SHA256SUMS legt das Manifest ab, alles andere das Asset.
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
printf '%s\n' "$src" >>"$TRAEGER_SHIM_LOG"
case "$src" in
  */SHA256SUMS) cp "$TRAEGER_SHIM_SUMS" "$dest" ;;
  *) cp "$TRAEGER_SHIM_FIXTURE" "$dest" ;;
esac
ENDE
  chmod 0755 "$SHIM/docker" "$SHIM/curl"
  export PATH="$SHIM:$PATH"
  export TRAEGER_SHIM_LOG="$TMP/shim.log"
  : >"$TRAEGER_SHIM_LOG"
  # Fixture: ein lauffaehiges Programm als Asset-Ersatz — der Happy-Fall misst, dass
  # der abgelegte Traeger STARTET, nicht nur liegt.
  printf '#!/usr/bin/env bash\necho traeger-echo-ok\n' >"$TMP/fixture"
  chmod 0755 "$TMP/fixture"
  export TRAEGER_SHIM_FIXTURE="$TMP/fixture"
  FIXTURE_SHA="$(sha256sum "$TMP/fixture" | awk '{print $1}')"
  # Manifest-Fixture: ein Eintrag je Asset der Faelle unten, alle gegen dieselbe
  # Fixture-Datei — der Happy-Fall im Manifest-Modus verifiziert gegen sie.
  printf '%s  ai-harness-init-linux-amd64\n%s  ai-harness-init-windows-amd64.exe\n%s  ai-harness-init-linux-arm64\n' \
    "$FIXTURE_SHA" "$FIXTURE_SHA" "$FIXTURE_SHA" >"$TMP/sums"
  export TRAEGER_SHIM_SUMS="$TMP/sums"
}

# pin_wert <datei> <name> — liest eine Pin-Zeile `NAME ?= wert`.
pin_wert() {
  grep "^$2" "$1" | head -1 | sed 's/.*=[ ]*//'
}

@test "pin-kopplung: der Tag haelt an beiden Stellen, das Fragment fuehrt keinen Digest (ADR-0059 Festlegung 2 und Folgepflicht 3)" {
  # Eine Stelle ohne Wert waere still gruen (LH-QA-01); ein Digest im Fragment
  # bettete einen Wert ins Binary, der vom Bau-Ergebnis abhaengt — die
  # Selbstreferenz-Wand aus ADR-0059.
  [ "$(pin_wert "$MK" 'TRAEGER_TAG')" = "v0.2.1" ]
  [ "$(pin_wert "$FRAG" 'TRAEGER_TAG')" = "v0.2.1" ]
  [ "$(grep -c 'TRAEGER_SHA256' "$FRAG")" -eq 0 ]
  # Die Dogfood-Haelfte traegt weiter: sechs Einzeldigests, je 64 Hex (ADR-0059
  # Festlegung 3 — zwei Kanaele).
  for p in LINUX_AMD64 LINUX_ARM64 DARWIN_AMD64 DARWIN_ARM64 WINDOWS_AMD64 WINDOWS_ARM64; do
    mk="$(pin_wert "$MK" "TRAEGER_SHA256_$p")"
    [ -n "$mk" ]
    [ "${#mk}" -eq 64 ]
  done
}

@test "transport-skript: der Dogfood-Zwilling ist byte-gleich mit dem emittierten" {
  cmp "$SKRIPT" "$SKRIPT_EMITT"
  # Der Transport ist ein gepinntes Bild (ADR-0058 Festlegung 4): der Default des
  # Skripts traegt einen Image-Digest, kein floatingen Tag.
  grep -q 'TRAEGER_IMAGE:-curlimages/curl@sha256:' "$SKRIPT"
}

@test "happy im Ziel-Modus: ohne Digest-Pin verifiziert der Lauf gegen die SHA256SUMS und legt den Traeger ab, lauffaehig" {
  # Manifest und Asset kommen vom selben Release — zwei Transport-Aufrufe, und der
  # Asset-Digest steht im Manifest-Eintrag (ADR-0059 Festlegung 1).
  # Plattform fest verdrahtet (statt uname des Bats-Hosts): sonst waere der Fall auf
  # einem arm64-Host nicht hermetisch — die Assertion unten nennt das amd64-Asset.
  run env TRAEGER_TAG=v0.2.1 \
    TRAEGER_OS=Linux \
    TRAEGER_ARCH=x86_64 \
    TRAEGER_CARRIER="$TMP/ablage/ai-harness-init" \
    bash "$SKRIPT"
  [ "$status" -eq 0 ]
  printf '%s' "$output" | grep -qF 'Digest verifiziert'
  [ -x "$TMP/ablage/ai-harness-init" ]
  # Der Traeger STARTET — er liegt nicht nur (LH-QA-01: ein Traeger, der nur aussieht
  # wie einer, ist keiner).
  run "$TMP/ablage/ai-harness-init"
  [ "$status" -eq 0 ]
  [ "$output" = "traeger-echo-ok" ]
  # Genau zwei Transport-Aufrufe: das Manifest und das Asset, beide vom gepinnten Tag.
  [ "$(grep -c . "$TRAEGER_SHIM_LOG")" -eq 2 ]
  grep -qF 'releases/download/v0.2.1/SHA256SUMS' "$TRAEGER_SHIM_LOG"
  grep -qF 'releases/download/v0.2.1/ai-harness-init-linux-amd64' "$TRAEGER_SHIM_LOG"
}

@test "happy im Dogfood-Modus: mit exportiertem Pin verifiziert der Lauf gegen den Makefile-Pin (zwei Kanaele, ADR-0059 Festlegung 3)" {
  # Plattform fest verdrahtet (statt uname des Bats-Hosts) — derselbe Grund wie im
  # Ziel-Modus-Fall darueber: der Pin- und der Asset-Name unten sind LINUX_AMD64.
  run env TRAEGER_TAG=v0.2.1 \
    TRAEGER_OS=Linux \
    TRAEGER_ARCH=x86_64 \
    TRAEGER_SHA256_LINUX_AMD64="$FIXTURE_SHA" \
    TRAEGER_CARRIER="$TMP/ablage/ai-harness-init" \
    bash "$SKRIPT"
  [ "$status" -eq 0 ]
  printf '%s' "$output" | grep -qF 'Digest verifiziert'
  [ -x "$TMP/ablage/ai-harness-init" ]
  # Genau EIN Transport-Aufruf — das Asset; das Manifest wird im Pin-Modus nicht
  # angefragt (dieselbe Zusage wie vor ADR-0059).
  [ "$(grep -c . "$TRAEGER_SHIM_LOG")" -eq 1 ]
  ! grep -qF 'SHA256SUMS' "$TRAEGER_SHIM_LOG"
  grep -qF 'releases/download/v0.2.1/ai-harness-init-linux-amd64' "$TRAEGER_SHIM_LOG"
}

@test "negative im Ziel-Modus: eine Abweichung vom Manifest-Eintrag bricht fail-closed, ohne den Traeger zu legen" {
  # Das Manifest nennt einen fremden Digest, das gelieferte Asset hasht zur Fixture —
  # dieselbe Klasse wie ein gegen das gemessene Manifest falsch hochgeladenes Asset
  # (ADR-0059 Festlegung 1).
  fremd="$(printf 'f%.0s' $(seq 64))"
  printf '%s  ai-harness-init-linux-amd64\n' "$fremd" >"$TMP/sums-fremd"
  # Plattform fest verdrahtet (statt uname des Bats-Hosts) — die Fixture-Zeile oben
  # und die Assertion unten nennen das amd64-Asset.
  run env TRAEGER_TAG=v0.2.1 \
    TRAEGER_OS=Linux \
    TRAEGER_ARCH=x86_64 \
    TRAEGER_SHIM_SUMS="$TMP/sums-fremd" \
    TRAEGER_CARRIER="$TMP/ablage/ai-harness-init" \
    bash "$SKRIPT"
  [ "$status" -ne 0 ]
  # Die Meldung nennt die behauptete Ursache und ihre Quelle, nicht irgendeine
  # (AGENTS.md 3.6).
  printf '%s' "$output" | grep -qF 'Digest-Abweichung'
  printf '%s' "$output" | grep -qF 'SHA256SUMS'
  [ ! -e "$TMP/ablage/ai-harness-init" ]
  # Das Asset laedt der Lauf EINMAL — Manifest einmal, Asset einmal, kein zweiter
  # Versuch.
  asset_aufrufe="$(grep -cF 'ai-harness-init-linux-amd64' "$TRAEGER_SHIM_LOG")"
  [ "$asset_aufrufe" -eq 1 ]
}

@test "negative im Dogfood-Modus: Digest-Abweichung vom Pin bricht fail-closed, ohne den Traeger zu legen (kein zweiter Download)" {
  # Der Pin ist VERDREHT gegen dasselbe Asset — der Lauf laedt EINMAL und legt
  # nichts ab; der Traeger des richtigen Laufs bliebe unangetastet.
  verdreht="$(printf '0%.0s' $(seq 64))"
  # Plattform fest verdrahtet (statt uname des Bats-Hosts) — der Pin unten ist LINUX_AMD64.
  run env TRAEGER_TAG=v0.2.1 \
    TRAEGER_OS=Linux \
    TRAEGER_ARCH=x86_64 \
    TRAEGER_SHA256_LINUX_AMD64="$verdreht" \
    TRAEGER_CARRIER="$TMP/ablage/ai-harness-init" \
    bash "$SKRIPT"
  [ "$status" -ne 0 ]
  # Die Meldung nennt die behauptete Ursache, nicht irgendeine (AGENTS.md 3.6).
  printf '%s' "$output" | grep -qF 'Digest-Abweichung'
  printf '%s' "$output" | grep -qF 'Pin'
  [ ! -e "$TMP/ablage/ai-harness-init" ]
  # Kein zweiter Download: derselbe Aufruf hat den Transport genau einmal gefahren.
  [ "$(grep -c . "$TRAEGER_SHIM_LOG")" -eq 1 ]
}

@test "fail-closed vor dem Transport: fehlt bei TEILWEISE exportierten Pins der eigene der Plattform, bricht der Lauf, ohne den Transport zu rufen (ADR-0059 Festlegung 3)" {
  # Der Ablageort wird auf ein Verzeichnis gesetzt, das NUR der Transport haette
  # anlegen duerfen — nach dem Lauf darf es nicht existieren.
  # Plattform fest verdrahtet (statt uname des Bats-Hosts): die fehlende Pin-Stelle
  # unten ist LINUX_AMD64, waehrend DARWIN_AMD64 gesetzt ist.
  run env TRAEGER_TAG=v0.2.1 \
    TRAEGER_OS=Linux \
    TRAEGER_ARCH=x86_64 \
    TRAEGER_SHA256_DARWIN_AMD64="$FIXTURE_SHA" \
    TRAEGER_CARRIER="$TMP/ablage/ai-harness-init" \
    bash "$SKRIPT"
  [ "$status" -eq 2 ]
  printf '%s' "$output" | grep -qF 'TRAEGER_SHA256_LINUX_AMD64'
  [ "$(grep -c . "$TRAEGER_SHIM_LOG")" -eq 0 ]
  [ ! -d "$TMP/ablage" ]
}

@test "fail-closed vor dem Transport: unbekannte Plattform und Architektur brechen laut (Asset-Matrix, LH-QA-04)" {
  run env TRAEGER_TAG=v0.2.1 \
    TRAEGER_OS=SunOS \
    TRAEGER_CARRIER="$TMP/ablage/ai-harness-init" \
    bash "$SKRIPT"
  [ "$status" -eq 2 ]
  printf '%s' "$output" | grep -qF 'unbekannte Plattform'
  [ "$(grep -c . "$TRAEGER_SHIM_LOG")" -eq 0 ]
  run env TRAEGER_TAG=v0.2.1 \
    TRAEGER_ARCH=sparc64 \
    TRAEGER_CARRIER="$TMP/ablage/ai-harness-init" \
    bash "$SKRIPT"
  [ "$status" -eq 2 ]
  printf '%s' "$output" | grep -qF 'unbekannte Architektur'
}

@test "plattform-matrix: das windows-Asset traegt .exe, und der Traeger liegt als ai-harness-init.exe (LH-QA-04)" {
  # Plattform fest verdrahtet (statt uname des Bats-Hosts) — die Assertion nennt das
  # amd64-Windows-Asset.
  run env TRAEGER_TAG=v0.2.1 \
    TRAEGER_OS='MINGW64_NT-10.0' \
    TRAEGER_ARCH=x86_64 \
    TRAEGER_CARRIER="$TMP/ablage/ai-harness-init.exe" \
    bash "$SKRIPT"
  [ "$status" -eq 0 ]
  grep -qF 'releases/download/v0.2.1/ai-harness-init-windows-amd64.exe' "$TRAEGER_SHIM_LOG"
  [ -x "$TMP/ablage/ai-harness-init.exe" ]
  run env TRAEGER_TAG=v0.2.1 \
    TRAEGER_OS=Linux \
    TRAEGER_ARCH=aarch64 \
    TRAEGER_CARRIER="$TMP/ablage/ai-harness-init" \
    bash "$SKRIPT"
  [ "$status" -eq 0 ]
  grep -qF 'releases/download/v0.2.1/ai-harness-init-linux-arm64' "$TRAEGER_SHIM_LOG"
}

@test "fehlt-fall: der Fetch ist kein Prerequisite und kein Automatismus (ADR-0058 Festlegung 3)" {
  # KEIN Prerequisite an archive-welle — im emittierten Fragment steht das Ziel ohne
  # Voraussetzung, und sein Rezept ruft den Fetch nicht; die Exit-0-Meldung des
  # Fehlt-Falls bleibt stehen.
  grep -qE '^archive-welle: ##' "$ARCHIV"
  ! grep -qF 'traeger-fetch' "$ARCHIV"
  grep -qF 'der Traeger liegt nicht' "$ARCHIV"
  grep -qF 'ein erneuter Lauf des Werkzeugs legt ihn wieder ab' "$ARCHIV"
  # Dasselbe im emittierten Fragment des Fetch: Ziel ohne Voraussetzung, nichts an
  # GATE_CHECKS — kein Gate.
  grep -qE '^traeger-fetch: ##' "$FRAG"
  ! grep -qF 'GATE_CHECKS' "$FRAG"
  # Und im Dogfood: archive-welle und gates nennen den Fetch nicht.
  grep -qE '^traeger-fetch: ##' "$MK"
  ! grep -E '^(gates|archive-welle):' "$MK" | grep -qF 'traeger-fetch'
}