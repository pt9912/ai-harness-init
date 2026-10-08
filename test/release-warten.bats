#!/usr/bin/env bats
# release-warten.bats — Zaehne fuer das begrenzte Warten auf das gepinnte Release
# vor `make full-smoke` im ci-Job (ADR-0058 Festlegung 2, MR-014).
#
# HERMETISCH: docker und curl sind durch Stubs ersetzt; das Payload des Bilds laeuft
# als derselbe String, den der echte Lauf dem gepinnten Bild uebergibt. Dass die
# Grenzen real sind, misst der Lauf am realen Release (Bericht des Umsetzungs-Slice),
# kein Gate.
#
# ROT-GEGENPROBEN (AGENTS.md 3.6):
#   - Endet das Warten nach der Grenze mit Exit != 0, faerbt der Grenz-Fall rot —
#     das Warten urteilte dann selbst, statt full-smoke das Urteil zu lassen.
#   - Fragt ein Versuch nur eines der zwei Assets ab, faerbt der URL-Fall rot.
#   - Faehrt ein Versuch ohne Zeitlimit, haengt der Haenge-Fall bis zum Schlaf des
#     Stubs (30 s) und faerbt rot.
#   - Faellt eine Vorbedingungs-Pruefung weg, faerbt ihr Exit-2-Fall rot.
#   - Fuehrt das Skript einen eigenen Bild-Pin statt des Pins von traeger-fetch.sh,
#     faerbt der Bild-Fall rot, sobald die zwei auseinanderlaufen.
#
# NETZLOS, laeuft in `make gates`. Docker-only (bats-Image).

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  SKRIPT="$REPO/harness/tools/release-warten.sh"
  TMP="$BATS_TEST_TMPDIR"
  SHIM="$TMP/bin"
  mkdir -p "$SHIM"
  # docker-Stub: protokolliert das Bild, reicht -e an das Payload durch und faehrt es.
  cat >"$SHIM/docker" <<'ENDE'
#!/usr/bin/env bash
set -eu
payload=""
envs=()
bild=""
shift # run
while [ $# -gt 0 ]; do
  case "$1" in
    --rm) shift ;;
    -e) envs+=("$2"); shift 2 ;;
    -c) payload="$2"; shift 2 ;;
    sh) shift ;;
    *) bild="$1"; shift ;;
  esac
done
echo "$bild" >>"$STUB_LOG.bild"
for e in "${envs[@]}"; do export "$e"; done
exec sh -c "$payload"
ENDE
  # curl-Stub: protokolliert den URL; scheitert, solange $STUB_FEHLT noch Versuche
  # zaehlt (eine Zeile je fehlschlagendem Versuch in $STUB_LOG.fehlt).
  cat >"$SHIM/curl" <<'ENDE'
#!/usr/bin/env bash
url="${*: -1}"
echo "$url" >>"$STUB_LOG.url"
if [ -n "${STUB_SCHLAF:-}" ]; then exec sleep "$STUB_SCHLAF" >/dev/null 2>&1 </dev/null; fi
n=0
[ -f "$STUB_LOG.fehlt" ] && n="$(wc -l <"$STUB_LOG.fehlt")"
if [ "$n" -lt "${STUB_FEHLT:-0}" ]; then
  echo x >>"$STUB_LOG.fehlt"
  echo "curl: (22) The requested URL returned error: 404" >&2
  exit 22
fi
exit 0
ENDE
  chmod +x "$SHIM/docker" "$SHIM/curl"
  export PATH="$SHIM:$PATH"
  export STUB_LOG="$TMP/log"
  export TRAEGER_TAG=v9.9.9
  export TRAEGER_WARTEN_INTERVALL=0
  unset TRAEGER_IMAGE
}

@test "release-warten: abrufbares Release endet beim ersten Versuch mit Exit 0" {
  run bash "$SKRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Release v9.9.9 fuehrt SHA256SUMS und ai-harness-init-linux-amd64 — abrufbar beim Versuch 1 "* ]]
}

@test "release-warten: fragt je Versuch SHA256SUMS und das Linux-amd64-Asset des Tags ab" {
  run bash "$SKRIPT"
  [ "$status" -eq 0 ]
  run cat "$STUB_LOG.url"
  [ "${lines[0]}" = "https://github.com/pt9912/ai-harness-init/releases/download/v9.9.9/SHA256SUMS" ]
  [ "${lines[1]}" = "https://github.com/pt9912/ai-harness-init/releases/download/v9.9.9/ai-harness-init-linux-amd64" ]
}

@test "release-warten: wiederholt, bis das Release abrufbar ist" {
  export STUB_FEHLT=2 TRAEGER_WARTEN_GRENZE=60
  run bash "$SKRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"abrufbar beim Versuch 3 "* ]]
}

@test "release-warten: nach der Grenze Exit 0 mit der Grenz-Zeile — es urteilt nicht" {
  export STUB_FEHLT=1000 TRAEGER_WARTEN_GRENZE=0
  run bash "$SKRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == "release-warten: GRENZE ERREICHT — Release v9.9.9 "*"1 Versuch(en) nicht abrufbar (Grenze 0s)"* ]]
}

@test "release-warten: das Bild ist der Pin von traeger-fetch.sh" {
  run bash "$SKRIPT"
  [ "$status" -eq 0 ]
  pin="$(sed -n 's/^TRAEGER_IMAGE="\${TRAEGER_IMAGE:-\(.*\)}"$/\1/p' "$REPO/harness/tools/traeger-fetch.sh")"
  [[ "$pin" == *@sha256:* ]]
  [ "$(cat "$STUB_LOG.bild")" = "$pin" ]
}

@test "release-warten: ohne TRAEGER_TAG Exit 2, ohne Abfrage" {
  export TRAEGER_TAG=
  run bash "$SKRIPT"
  [ "$status" -eq 2 ]
  [[ "$output" == *"TRAEGER_TAG ist nicht gesetzt"* ]]
  [ ! -e "$STUB_LOG.url" ]
}

@test "release-warten: Grenze keine ganze Zahl — Exit 2, ohne Abfrage" {
  export TRAEGER_WARTEN_GRENZE=15m
  run bash "$SKRIPT"
  [ "$status" -eq 2 ]
  [[ "$output" == *"TRAEGER_WARTEN_GRENZE ('15m')"*"muessen ganze Sekunden sein"* ]]
  [ ! -e "$STUB_LOG.url" ]
}

@test "release-warten: Intervall keine ganze Zahl — Exit 2, ohne Abfrage" {
  export TRAEGER_WARTEN_GRENZE=60 TRAEGER_WARTEN_INTERVALL=30s
  run bash "$SKRIPT"
  [ "$status" -eq 2 ]
  [[ "$output" == *"TRAEGER_WARTEN_INTERVALL ('30s') muessen ganze Sekunden sein"* ]]
  [ ! -e "$STUB_LOG.url" ]
}

@test "release-warten: Bild ohne Digest — Exit 2, ohne Abfrage" {
  export TRAEGER_IMAGE=curlimages/curl:latest
  run bash "$SKRIPT"
  [ "$status" -eq 2 ]
  [[ "$output" == *"kein digest-gepinntes Transport-Bild"*"'curlimages/curl:latest'"* ]]
  [ ! -e "$STUB_LOG.bild" ]
}

@test "release-warten: ein haengender Versuch endet hoechstens 7 s nach der Grenze" {
  export STUB_SCHLAF=30 TRAEGER_WARTEN_GRENZE=2
  start=$SECONDS
  run bash "$SKRIPT"
  dauer=$((SECONDS - start))
  [ "$status" -eq 0 ]
  [[ "${lines[${#lines[@]}-1]}" == "release-warten: GRENZE ERREICHT — "*"(Grenze 2s); letzter Versuch: Exit "* ]]
  [ "$dauer" -le 9 ]
}

@test "release-warten: die Grenz-Zeile nennt Exit-Code und erste stderr-Zeile des letzten Versuchs" {
  export STUB_FEHLT=1000 TRAEGER_WARTEN_GRENZE=0
  run bash "$SKRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"letzter Versuch: Exit 22, stderr: curl: (22) The requested URL returned error: 404; das Warten urteilt nicht"* ]]
}
