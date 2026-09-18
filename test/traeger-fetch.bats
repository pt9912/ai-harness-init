#!/usr/bin/env bats
# traeger-fetch.bats — Zaehne fuer den Traeger-Fetch (ADR-0058) und fuer die
# Pin-Kopplung, die ihn traegt.
#
# HERMETISCH: kein Docker, kein Netz, kein Download — die zwei Grenzen des Transports
# (docker-Daemon, curl im Bild) sind im bats-Image durch Stubs ersetzt, und ALLES
# DAHINTER laeuft real: das Skript entscheidet Plattform, Asset, Pin und Ablageort, und
# das Payload des Transport-Bilds — Verifizierung VOR Ablage, Ablage erst nach dem
# Digest — wird als derselbe String gefahren, den der echte Lauf dem gepinnten Bild
# uebergibt (dieselbe Bauart wie test/commit-msg-hook.bats: der Aufruf laeuft ueber den
# Hook, ohne git). Dass auch die Grenzen real sind, misst die E2E-Stufe in
# harness/tools/full-smoke.sh am gebootstrappten Ziel (traeger_fetch_im_ziel).
#
# DIE KOPPLUNG (ADR-0058 Festlegung 1, Klasse test/sources-pin.bats): die kanonische
# Pin-Stelle ist das Makefile-Paar (TRAEGER_TAG + die sechs sha256 der Assets, LH-QA-04);
# das emittierte Fragment spiegelt dieselben Werte als ueberschreibbare Variablen. Ein
# Sprung, der eine Stelle stehen laesst, faerbt hier rot.
#
# ROT-GEGENPROBEN (AGENTS.md 3.6), je Fall der benannte Grund:
#   - Umgeht die Verifizierung den Digest (Abweichung bricht, Traeger bleibt liegen),
#     faerbt der Negative-Fall rot — der Fall verdreht den Pin gegen dasselbe Asset und
#     braucht keinen zweiten Download.
#   - Faellt eine Pin-Stelle im Makefile oder Fragment weg, faerbt die Kopplung rot.
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
# der echte Lauf das Asset laedt, und protokolliert den angeforderten URL.
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
cp "$TRAEGER_SHIM_FIXTURE" "$dest"
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
}

# pin_wert <datei> <name> — liest eine Pin-Zeile `NAME ?= wert`.
pin_wert() {
  grep "^$2" "$1" | head -1 | sed 's/.*=[ ]*//'
}

@test "pin-kopplung: Makefile und emittiertes Fragment tragen dieselben Pin-Werte (ADR-0058 Festlegung 1)" {
  # Die Pin-Stellen sind da und tragen 64 Hex-Zeichen — eine Stelle ohne Wert waere
  # still gruen (LH-QA-01).
  [ "$(pin_wert "$MK" 'TRAEGER_TAG')" = "v0.1.1" ]
  [ "$(pin_wert "$FRAG" 'TRAEGER_TAG')" = "v0.1.1" ]
  for p in LINUX_AMD64 LINUX_ARM64 DARWIN_AMD64 DARWIN_ARM64 WINDOWS_AMD64 WINDOWS_ARM64; do
    mk="$(pin_wert "$MK" "TRAEGER_SHA256_$p")"
    fr="$(pin_wert "$FRAG" "TRAEGER_SHA256_$p")"
    [ -n "$mk" ] && [ -n "$fr" ]
    [ "${#mk}" -eq 64 ] && [ "${#fr}" -eq 64 ]
    [ "$mk" = "$fr" ]
  done
}

@test "transport-skript: der Dogfood-Zwilling ist byte-gleich mit dem emittierten" {
  cmp "$SKRIPT" "$SKRIPT_EMITT"
  # Der Transport ist ein gepinntes Bild (ADR-0058 Festlegung 4): der Default des
  # Skripts traegt einen Image-Digest, kein floatingen Tag.
  grep -q 'TRAEGER_IMAGE:-curlimages/curl@sha256:' "$SKRIPT"
}

@test "happy: der Fetch legt den Traeger ab, ausfuehrbar und lauffaehig, Digest verifiziert" {
  run env TRAEGER_TAG=v0.1.1 \
    TRAEGER_SHA256_LINUX_AMD64="$FIXTURE_SHA" \
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
  # Genau EIN Transport-Aufruf, und er fragt das Asset des gepinnten Tags an.
  [ "$(grep -c . "$TRAEGER_SHIM_LOG")" -eq 1 ]
  grep -qF 'releases/download/v0.1.1/ai-harness-init-linux-amd64' "$TRAEGER_SHIM_LOG"
}

@test "negative: Digest-Abweichung bricht fail-closed, ohne den Traeger zu legen (kein zweiter Download)" {
  # Der Pin ist VERDREHT gegen dasselbe Asset — der Lauf laedt EINMAL und legt
  # nichts ab; der Träger des richtigen Laufs bliebe unangetastet.
  verdreht="$(printf '0%.0s' $(seq 64))"
  run env TRAEGER_TAG=v0.1.1 \
    TRAEGER_SHA256_LINUX_AMD64="$verdreht" \
    TRAEGER_CARRIER="$TMP/ablage/ai-harness-init" \
    bash "$SKRIPT"
  [ "$status" -ne 0 ]
  # Die Meldung nennt die behauptete Ursache, nicht irgendeine (AGENTS.md 3.6).
  printf '%s' "$output" | grep -qF 'Digest-Abweichung'
  [ ! -e "$TMP/ablage/ai-harness-init" ]
  # Kein zweiter Download: derselbe Aufruf hat den Transport genau einmal gefahren.
  [ "$(grep -c . "$TRAEGER_SHIM_LOG")" -eq 1 ]
}

@test "fail-closed vor dem Transport: fehlt der sha256-Pin seiner Plattform, bricht der Lauf, ohne den Transport zu rufen" {
  # Der Ablageort wird auf ein Verzeichnis gesetzt, das NUR der Transport haette
  # anlegen duerfen — nach dem Lauf darf es nicht existieren.
  run env TRAEGER_TAG=v0.1.1 \
    TRAEGER_SHA256_DARWIN_AMD64="$FIXTURE_SHA" \
    TRAEGER_CARRIER="$TMP/ablage/ai-harness-init" \
    bash "$SKRIPT"
  [ "$status" -eq 2 ]
  printf '%s' "$output" | grep -qF 'TRAEGER_SHA256_LINUX_AMD64'
  [ "$(grep -c . "$TRAEGER_SHIM_LOG")" -eq 0 ]
  [ ! -d "$TMP/ablage" ]
}

@test "fail-closed vor dem Transport: unbekannte Plattform und Architektur brechen laut (Asset-Matrix, LH-QA-04)" {
  run env TRAEGER_TAG=v0.1.1 \
    TRAEGER_SHA256_LINUX_AMD64="$FIXTURE_SHA" \
    TRAEGER_OS=SunOS \
    TRAEGER_CARRIER="$TMP/ablage/ai-harness-init" \
    bash "$SKRIPT"
  [ "$status" -eq 2 ]
  printf '%s' "$output" | grep -qF 'unbekannte Plattform'
  [ "$(grep -c . "$TRAEGER_SHIM_LOG")" -eq 0 ]
  run env TRAEGER_TAG=v0.1.1 \
    TRAEGER_SHA256_LINUX_AMD64="$FIXTURE_SHA" \
    TRAEGER_ARCH=sparc64 \
    TRAEGER_CARRIER="$TMP/ablage/ai-harness-init" \
    bash "$SKRIPT"
  [ "$status" -eq 2 ]
  printf '%s' "$output" | grep -qF 'unbekannte Architektur'
}

@test "plattform-matrix: das windows-Asset traegt .exe, und der Traeger liegt als ai-harness-init.exe (LH-QA-04)" {
  run env TRAEGER_TAG=v0.1.1 \
    TRAEGER_SHA256_WINDOWS_AMD64="$FIXTURE_SHA" \
    TRAEGER_OS='MINGW64_NT-10.0' \
    TRAEGER_CARRIER="$TMP/ablage/ai-harness-init" \
    bash "$SKRIPT"
  [ "$status" -eq 0 ]
  grep -qF 'releases/download/v0.1.1/ai-harness-init-windows-amd64.exe' "$TRAEGER_SHIM_LOG"
  [ -x "$TMP/ablage/ai-harness-init.exe" ]
  run env TRAEGER_TAG=v0.1.1 \
    TRAEGER_SHA256_LINUX_ARM64="$FIXTURE_SHA" \
    TRAEGER_ARCH=aarch64 \
    TRAEGER_CARRIER="$TMP/ablage/ai-harness-init" \
    bash "$SKRIPT"
  [ "$status" -eq 0 ]
  grep -qF 'releases/download/v0.1.1/ai-harness-init-linux-arm64' "$TRAEGER_SHIM_LOG"
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