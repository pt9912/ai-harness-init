#!/usr/bin/env bats
# tap-nachzug.bats — Zaehne fuer `make tap-check` (ADR-0064, LH-QA-02): das Skript
# harness/tools/tap-nachzug.sh und seine Nutzlast harness/tools/tap-nachzug-nutzlast.sh.
#
# HERMETISCH: kein Docker, kein Netz. Die zwei Grenzen — docker und curl — sind im
# bats-Image durch Stubs ersetzt; ALLES DAHINTER laeuft real: das Skript entscheidet
# Tag-Form, Feldform, Vorab-Regel und Pin auf dem Host, und die Nutzlast laeuft als
# dieselbe Datei, die der echte Lauf ins gepinnte Bild mountet. Die Stubs sind eine
# Fixture: sie bilden curl, Statuscodes und Antwortform nach. Ob das reale Tap und die
# reale Download-Adresse dieselbe Form liefern, misst allein der Lauf gegen den realen
# Zustand (`make tap-check TAG=<tag>`, Netz an diesem Aufruf) — kein Gate.
#
# Nicht abgedeckt, weil das bats-Image kein make traegt: `make tap-check TAG=…` selbst.
# Der lokale Weg ist hier durch den Wert gedeckt, den make dem Skript uebergibt
# (`TAG='v1.0.0$$(id)'` kommt als `v1.0.0$(id)` an), und durch den Text des Rezepts.
#
# Stub-Protokolle: STUB_LOG_DOCKER (eine Zeile je docker-Aufruf), STUB_LOG_CURL (eine
# Zeile je curl-Aufruf, seine Argumentliste), STUB_LOG_SLEEP (eine Zeile je Wartezeit),
# STUB_LOG_HDR (Modus und Bearer-Marke jeder `-H @<Datei>`-Kopfdatei), STUB_HDR_PATH
# (ihr Pfad, fuer die Frage, ob sie nach dem Lauf fehlt).

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  SKRIPT="$REPO/harness/tools/tap-nachzug.sh"
  NUTZLAST="$REPO/harness/tools/tap-nachzug-nutzlast.sh"
  FETCH="$REPO/harness/tools/traeger-fetch.sh"
  MK="$REPO/Makefile"
  WF="$REPO/.github/workflows/release.yml"
  TMP="$BATS_TEST_TMPDIR"
  CWD="$TMP/cwd"
  mkdir -p "$CWD" "$TMP/work" "$TMP/bin"
  export TMPDIR="$TMP/work"
  export STUB_LOG_DOCKER="$TMP/docker.log" STUB_LOG_CURL="$TMP/curl.log"
  export STUB_LOG_SLEEP="$TMP/sleep.log" STUB_LOG_HDR="$TMP/hdr.log"
  export STUB_HDR_PATH="$TMP/hdr.path" STUB_COUNT="$TMP/tapzaehler"
  : >"$STUB_LOG_DOCKER"; : >"$STUB_LOG_CURL"; : >"$STUB_LOG_SLEEP"; : >"$STUB_LOG_HDR"
  export TAP_WAIT=0
  cat >"$TMP/bin/docker" <<'ENDE'
#!/usr/bin/env bash
# Stub des Transport-Bilds: zaehlt den Aufruf, reicht die -e-Werte durch, bildet den
# Mount der Nutzlast auf die Repo-Datei ab und faehrt sie als `sh <Datei>`.
set -eu
printf '%s\n' "$*" >>"$STUB_LOG_DOCKER"
[ -z "${STUB_DOCKER_EXIT:-}" ] || exit "$STUB_DOCKER_EXIT"
shift
envs=(); src=""; dst=""
while [ $# -gt 0 ]; do
  case "$1" in
    --rm) shift ;;
    -e) envs+=("$2"); shift 2 ;;
    -v) IFS=: read -r src dst _ <<<"$2"; shift 2 ;;
    *) break ;;
  esac
done
shift
for e in "${envs[@]}"; do case "$e" in *=*) export "$e" ;; esac; done
[ "$1" = sh ] && [ "$2" = "$dst" ]
exec sh "$src"
ENDE
  cat >"$TMP/bin/sleep" <<'ENDE'
#!/usr/bin/env bash
printf '%s\n' "$1" >>"$STUB_LOG_SLEEP"
ENDE
  cat >"$TMP/bin/curl" <<'ENDE'
#!/usr/bin/env bash
# Stub von curl: liefert Asset und Tap-Stand aus Fixture-Dateien. Asset: STUB_ASSET,
# Code STUB_ASSET_CODE. Tap: erstes Lesen STUB_TAP_1, jedes weitere STUB_TAP_2 (sonst
# STUB_TAP_1), Code STUB_TAP_CODE; 000 ist ein Verbindungsfehler (Exit 7).
set -eu
dest=""; wfmt=""; url=""; hdrs=()
printf '%s\n' "$*" >>"$STUB_LOG_CURL"
while [ $# -gt 0 ]; do
  case "$1" in
    -o) dest="$2"; shift 2 ;;
    -w) wfmt="$2"; shift 2 ;;
    --max-time) shift 2 ;;
    -H) case "$2" in @*) hdrs+=("${2#@}") ;; esac; shift 2 ;;
    -*) shift ;;
    *) url="$1"; shift ;;
  esac
done
for h in "${hdrs[@]}"; do
  bearer=0; grep -q '^Authorization: Bearer ' "$h" && bearer=1
  printf 'modus=%s bearer=%s\n' "$(stat -c %a "$h")" "$bearer" >>"$STUB_LOG_HDR"
  printf '%s' "$h" >"$STUB_HDR_PATH"
done
case "$url" in
  */releases/download/*)
    code="${STUB_ASSET_CODE:-200}"
    [ "$code" = 200 ] && cp "$STUB_ASSET" "$dest"
    ;;
  */contents/*)
    n=0; [ -f "$STUB_COUNT" ] && n="$(cat "$STUB_COUNT")"
    n=$((n + 1)); printf '%s' "$n" >"$STUB_COUNT"
    f="$STUB_TAP_1"; [ "$n" -gt 1 ] && [ -n "${STUB_TAP_2:-}" ] && f="$STUB_TAP_2"
    code="${STUB_TAP_CODE:-200}"
    if [ "$code" = 200 ]; then cp "$f" "$dest"
    else printf '{"message":"abgelehnt","echo":"%s"}' "${STUB_ECHO:-}" >"$dest"; fi
    ;;
  *) exit 99 ;;
esac
case "$wfmt" in *http_code*) printf '%s' "$code" ;; esac
[ "$code" = 000 ] && exit 7
exit 0
ENDE
  chmod 0755 "$TMP/bin/docker" "$TMP/bin/sleep" "$TMP/bin/curl"
  export PATH="$TMP/bin:$PATH"
  formel 0.2.3 >"$TMP/asset"
  export STUB_ASSET="$TMP/asset" STUB_TAP_1="$TMP/asset"
}

# formel <version> — eine Formel mit Nicht-ASCII-Byte und OHNE Endzeilenumbruch; die
# version-Zeile ist Zeile 11.
formel() {
  printf 'class AiHarnessInit < Formula\n  desc "Caf\xc3\xa9 Harness"\n  homepage "https://example.invalid"\n  license "MIT"\n  on_linux do\n    on_arm do\n      url "https://example.invalid/a"\n      sha256 "aa"\n    end\n  end\n  version "%s"\n  test do\n    true\n  end\nend' "$1"
}

# lauf <modus> <tag> [VAR=wert ...] — das Skript im leeren Arbeitsverzeichnis.
lauf() {
  local modus="$1" tag="$2"; shift 2
  cd "$CWD"
  run env TAG="$tag" "$@" bash "$SKRIPT" "$modus"
}

docker_aufrufe() { grep -c . "$STUB_LOG_DOCKER" || true; }
tap_lesungen() { grep -c '/contents/' "$STUB_LOG_CURL" || true; }
digest() { sha256sum "$1" | awk '{print $1}'; }

@test "vergleich gleich: Exit 0 mit Tag, Tap-Kopf und Digest — auch mit Nicht-ASCII-Byte und ohne Endzeilenumbruch" {
  # Der Fall traegt die Formel aus setup(): ein Nicht-ASCII-Byte, kein Endzeilenumbruch.
  [ "$(tail -c 1 "$TMP/asset" | od -An -c | tr -d ' ')" = "d" ]
  grep -q "$(printf '\xc3\xa9')" "$TMP/asset"
  lauf check v0.2.3
  [ "$status" -eq 0 ]
  [[ "$output" == *"gleich"* ]]
  [[ "$output" == *"v0.2.3"* ]]
  [[ "$output" == *"Tap-Kopf"* ]]
  [[ "$output" == *"$(digest "$TMP/asset")"* ]]
}

@test "vergleich verschieden: Exit 1 mit beiden Digests und der ersten abweichenden Zeile des zweiten Lesens" {
  # Erstes Lesen weicht in Zeile 2 ab, zweites nur in Zeile 5: die Meldung nennt das zweite.
  sed '2s/.*/  desc "erstes Lesen"/' "$TMP/asset" >"$TMP/tap1"
  sed '5s/.*/  on_macos do/' "$TMP/asset" >"$TMP/tap2"
  lauf check v0.2.3 STUB_TAP_1="$TMP/tap1" STUB_TAP_2="$TMP/tap2"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Formel-Unterschied"* ]]
  [[ "$output" == *"$(digest "$TMP/asset")"* ]]
  [[ "$output" == *"$(digest "$TMP/tap2")"* ]]
  [[ "$output" == *"Zeile 5:"* ]]
  [[ "$output" == *"on_macos do"* ]]
  [[ "$output" != *"erstes Lesen"* ]]
}

@test "vorfall nachgestellt: Asset von v0.2.3 gegen die Bytes von v0.2.2 als Tap-Stand endet mit Exit 1 an der version-Zeile" {
  formel 0.2.2 >"$TMP/tap022"
  lauf check v0.2.3 STUB_TAP_1="$TMP/tap022"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Zeile 11: Asset [  version \"0.2.3\"] | Tap [  version \"0.2.2\"]"* ]]
  [ "$(tap_lesungen)" -eq 2 ]
}

@test "vergleich byte-genau: verschieden nur im Endzeilenumbruch endet mit Exit 1" {
  { cat "$TMP/asset"; printf '\n'; } >"$TMP/tapnl"
  lauf check v0.2.3 STUB_TAP_1="$TMP/tapnl"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Endzeilenumbruch"* ]]
}

@test "nicht lesbar: der Tap ist nicht erreichbar oder lehnt ab — Exit 2, nie 1, nie 0" {
  for code in 000 403 429 500; do
    : >"$STUB_LOG_CURL"
    lauf check v0.2.3 STUB_TAP_CODE="$code"
    [ "$status" -eq 2 ]
    [[ "$output" == *"Tap nicht lesbar"* ]]
    [[ "$output" == *"nichts verglichen"* ]]
  done
}

@test "nicht lesbar: das Asset ist nicht auffindbar — Exit 2, nie 1, nie 0" {
  for code in 000 404 500; do
    lauf check v0.2.3 STUB_ASSET_CODE="$code"
    [ "$status" -eq 2 ]
    [[ "$output" == *"Asset nicht auffindbar"* ]]
  done
  # Das Tap wurde nicht einmal gelesen.
  [ "$(tap_lesungen)" -eq 0 ]
}

@test "nicht lesbar: ein Tap ohne Formel-Datei (404) ist Exit 2 und nennt die fehlende Datei" {
  lauf check v0.2.3 STUB_TAP_CODE=404
  [ "$status" -eq 2 ]
  [[ "$output" == *"keine Formel-Datei"* ]]
}

@test "cache-fenster: erst alt, dann neu endet mit Exit 0 nach zwei Lese-Aufrufen und einer Wartezeit" {
  sed '2s/.*/  desc "alt"/' "$TMP/asset" >"$TMP/tapalt"
  lauf check v0.2.3 STUB_TAP_1="$TMP/tapalt" STUB_TAP_2="$TMP/asset"
  [ "$status" -eq 0 ]
  [ "$(tap_lesungen)" -eq 2 ]
  [ "$(cat "$STUB_LOG_SLEEP")" = "0" ]
}

@test "cache-fenster: beide Male alt endet mit Exit 1 nach zwei Lese-Aufrufen" {
  sed '2s/.*/  desc "alt"/' "$TMP/asset" >"$TMP/tapalt"
  lauf check v0.2.3 STUB_TAP_1="$TMP/tapalt"
  [ "$status" -eq 1 ]
  [ "$(tap_lesungen)" -eq 2 ]
}

@test "cache-fenster: sofort gleich liest einmal und wartet nicht" {
  lauf check v0.2.3
  [ "$status" -eq 0 ]
  [ "$(tap_lesungen)" -eq 1 ]
  [ ! -s "$STUB_LOG_SLEEP" ]
}

@test "cache-fenster: die Wartezeit ohne Vorgabe sind 65 Sekunden" {
  sed '2s/.*/  desc "alt"/' "$TMP/asset" >"$TMP/tapalt"
  cd "$CWD"
  run env -u TAP_WAIT TAG=v0.2.3 STUB_TAP_1="$TMP/tapalt" bash "$SKRIPT" check
  [ "$status" -eq 1 ]
  [ "$(cat "$STUB_LOG_SLEEP")" = "65" ]
}

@test "version-zeile: in check kein Gegenstand — gleiche Bytes mit einer version-Zeile ausserhalb der Feldform enden mit Exit 0" {
  formel 0.08.3 >"$TMP/seltsam"
  cp "$TMP/seltsam" "$TMP/asset"
  lauf check v0.2.3
  [ "$status" -eq 0 ]
  formel '' | sed '/^  version/d' >"$TMP/ohne"
  cp "$TMP/ohne" "$TMP/asset"; cp "$TMP/ohne" "$TMP/tap1"
  lauf check v0.2.3 STUB_TAP_1="$TMP/tap1"
  [ "$status" -eq 0 ]
}

@test "vorab-tag: Exit 0 mit Vorab-Tag, Tap bleibt — ohne docker und ohne curl" {
  for t in v1.0.0-RC v1.0.0-rc.1+x v1.0.0-rc.1; do
    : >"$STUB_LOG_DOCKER"; : >"$STUB_LOG_CURL"
    lauf check "$t"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Vorab-Tag, Tap bleibt"* ]]
    [ "$(docker_aufrufe)" -eq 0 ]
    [ ! -s "$STUB_LOG_CURL" ]
  done
}

@test "vorab-tag: die Regel des Skripts entscheidet dieselben Tags wie die Regel des publish-Jobs von release.yml" {
  # Die Regel des Jobs wird aus der Workflow-Datei gelesen; steht sie dort nicht genau
  # einmal in dieser Form, bricht der Fall, statt still gruen zu bleiben.
  muster='^[[:space:]]*case "\$\{tag%%\+\*\}" in \*-\*\) vorab=ja ;; esac$'
  [ "$(grep -cE "$muster" "$WF")" -eq 1 ]
  zeile="$(grep -E "$muster" "$WF")"
  for t in v1.0.0-RC v1.0.0-rc.1+x v1.0.0+build-1 v1.0.0 v0.2.3 v1.0.0-rc.1; do
    publish="$(bash -c 'tag=$1; vorab=nein; '"$zeile"'; printf %s "$vorab"' _ "$t")"
    : >"$STUB_LOG_DOCKER"
    lauf check "$t"
    skript=nein
    if [ "$(docker_aufrufe)" -eq 0 ] && [[ "$output" == *"Vorab-Tag, Tap bleibt"* ]]; then skript=ja; fi
    [ "$publish" = "$skript" ]
    case "$t" in
      v1.0.0-RC | v1.0.0-rc.1+x | v1.0.0-rc.1) [ "$skript" = ja ] ;;
      *) [ "$skript" = nein ] ;;
    esac
  done
}

@test "tag-eingabe: eine Shell-Form im Tag endet mit Exit 2, ohne Ausfuehrung, ohne docker" {
  # Env-Weg: der Wert kommt byte-genau an. Der lokale Weg `make tap-check TAG='v1.0.0$$(id)'`
  # reicht `v1.0.0$(id)` durch, der Fall unten.
  for t in 'v1.0.0$(touch${IFS}marker)' 'v1.0.0;x' 'v1.0.0$(id)' 'v1.0.0`id`' 'v1.0.0 x'; do
    : >"$STUB_LOG_DOCKER"
    lauf check "$t"
    [ "$status" -eq 2 ]
    [ ! -e "$CWD/marker" ]
    [ "$(docker_aufrufe)" -eq 0 ]
    [[ "$output" == *"Tag"* ]]
  done
  lauf check 'v1.0.0$(touch${IFS}marker)'
  [[ "$output" == *"Tag-Form falsch"* ]]
}

@test "feldform: fuehrende Null und mehr als 9 Stellen im Kern enden mit Exit 2 und der Meldung der Feldform, ohne docker" {
  for t in v01.0.0 v1.0.08 v1.0.1234567890 v01.0.0-rc.1; do
    : >"$STUB_LOG_DOCKER"
    lauf check "$t"
    [ "$status" -eq 2 ]
    [[ "$output" == *"Feldform falsch"* ]]
    [ "$(docker_aufrufe)" -eq 0 ]
  done
  lauf check v0.0.0
  [ "$status" -eq 0 ]
  lauf check v999999999.0.1
  [ "$status" -eq 0 ]
}

@test "uebergabe ohne text: die Rezeptzeilen von tap-check nennen den Tag nicht als make-Referenz" {
  rezept="$(awk '/^tap-check:/ {f=1; next} f && /^\t/ {print; next} f {exit}' "$MK")"
  [ -n "$rezept" ]
  [[ "$rezept" == *"tap-nachzug.sh check"* ]]
  ! grep -qE '\$\(TAG\)|\$\{TAG\}' <<<"$rezept"
}

@test "kein gate: tap-check steht weder in gates noch in record-gates" {
  grep -q '^tap-check:' "$MK"
  ! grep -E '^(gates|record-gates):' "$MK" | grep -q 'tap-check'
}

@test "token: ein Sentinel-Token steht in keiner Argumentliste und keiner Ausgabe, der Header liegt in einer 0600-Datei, die nach dem Lauf fehlt" {
  S="TOKSENTINEL-9f3a71c2"
  lauf check v0.2.3 TAP_TOKEN="$S"
  [ "$status" -eq 0 ]
  [[ "$output" != *"$S"* ]]
  ! grep -qF "$S" "$STUB_LOG_CURL" "$STUB_LOG_DOCKER"
  grep -q -- '-H @' "$STUB_LOG_CURL"
  [ "$(cat "$STUB_LOG_HDR")" = "modus=600 bearer=1" ]
  [ ! -e "$(cat "$STUB_HDR_PATH")" ]
  [ -z "$(ls -A "$TMP/work")" ]
}

@test "token: eine abgelehnte Anmeldung beim Lesen endet mit Exit 2 und gibt weder Token noch Antwort aus" {
  S="TOKSENTINEL-9f3a71c2"
  lauf check v0.2.3 TAP_TOKEN="$S" STUB_TAP_CODE=401 STUB_ECHO="$S"
  [ "$status" -eq 2 ]
  [[ "$output" == *"Tap nicht lesbar"* ]]
  [[ "$output" != *"$S"* ]]
  [[ "$output" != *"abgelehnt"* ]]
  ! grep -qF "$S" "$STUB_LOG_CURL" "$STUB_LOG_DOCKER"
  [ ! -e "$(cat "$STUB_HDR_PATH")" ]
  [ -z "$(ls -A "$TMP/work")" ]
}

@test "token: ohne Token liest der Lauf anonym, ohne Kopfdatei" {
  lauf check v0.2.3
  [ "$status" -eq 0 ]
  ! grep -q -- '-H @' "$STUB_LOG_CURL"
  [ ! -s "$STUB_LOG_HDR" ]
}

@test "pin: ein Bild ohne Digest endet mit Exit 2 vor docker" {
  lauf check v0.2.3 TAP_IMAGE=curlimages/curl:latest
  [ "$status" -eq 2 ]
  [[ "$output" == *"nicht digest-gepinnt"* ]]
  [ "$(docker_aufrufe)" -eq 0 ]
}

@test "pin-kopplung: der Digest des Skripts ist der von traeger-fetch.sh" {
  a="$(grep -oE 'curlimages/curl@sha256:[0-9a-f]{64}' "$SKRIPT")"
  b="$(grep -oE 'curlimages/curl@sha256:[0-9a-f]{64}' "$FETCH")"
  [ -n "$a" ]
  [ "$a" = "$b" ]
}

@test "modus: sync ist nicht implementiert und endet mit Exit 2 statt 0, jeder andere Modus ebenso" {
  for m in sync nachzug ''; do
    lauf "$m" v0.2.3
    [ "$status" -eq 2 ]
  done
  lauf sync v0.2.3
  [[ "$output" == *"nicht implementiert"* ]]
  [ "$(docker_aufrufe)" -eq 0 ]
}

@test "transport: ein Bild, das nicht laeuft (docker Exit 125), endet mit Exit 2 statt 1" {
  lauf check v0.2.3 STUB_DOCKER_EXIT=125
  [ "$status" -eq 2 ]
  [[ "$output" == *"Transport im Bild ist nicht gelaufen"* ]]
  [[ "$output" == *"nichts verglichen"* ]]
}

@test "aufruf: ohne TAG endet der Lauf mit Exit 2 und nennt die Variable" {
  cd "$CWD"
  run env -u TAG bash "$SKRIPT" check
  [ "$status" -eq 2 ]
  [[ "$output" == *"TAG"* ]]
  [ "$(docker_aufrufe)" -eq 0 ]
}

@test "nutzlast: die Datei ist ein POSIX-sh-Skript und ruft nur Programme des Bild-Bestands" {
  head -1 "$NUTZLAST" | grep -qx '#!/bin/sh'
  for p in jq bash git gh python3; do
    ! grep -qE "(^|[^[:alnum:]_./-])$p( |$)" <(grep -v '^#' "$NUTZLAST")
  done
}
