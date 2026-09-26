#!/usr/bin/env bats
bats_require_minimum_version 1.5.0
# tap-nachzug.bats — Zaehne fuer `make tap-check` und `make tap-nachzug` (ADR-0064,
# LH-QA-02): das Skript harness/tools/tap-nachzug.sh und seine Nutzlast
# harness/tools/tap-nachzug-nutzlast.sh, beide Modi (check, sync).
#
# HERMETISCH: kein Docker, kein Netz. Die zwei Grenzen — docker und curl — sind im
# bats-Image durch Stubs ersetzt; ALLES DAHINTER laeuft real: das Skript entscheidet
# Tag-Form, Feldform, Vorab-Regel und Pin auf dem Host, und die Nutzlast laeuft als
# dieselbe Datei, die der echte Lauf ins gepinnte Bild mountet. Die Stubs sind eine
# Fixture: sie bilden curl, Statuscodes und Antwortform nach. Ob das reale Tap und die
# reale Download-Adresse dieselbe Form liefern, misst allein der Lauf gegen den realen
# Zustand (`make tap-check TAG=<tag>`, Netz an diesem Aufruf) — kein Gate. Der
# Schreib-Pfad von `sync` laeuft hier nur gegen die nachgebildete Schnittstelle des
# curl-Stubs; kein Fall schreibt ins reale Tap, und ein Token dieser Datei ist ein
# Sentinel-Wert.
#
# Nicht abgedeckt, weil das bats-Image kein make traegt: `make tap-check TAG=…` und
# `make tap-nachzug TAG=…` selbst. Der lokale Weg ist hier durch den Wert gedeckt, den make
# dem Skript uebergibt (`TAG='v1.0.0$$(id)'` kommt als `v1.0.0$(id)` an), und durch den
# Text der Rezepte.
#
# Stub-Protokolle: STUB_LOG_DOCKER (eine Zeile je docker-Aufruf), STUB_LOG_CURL (eine
# Zeile je curl-Aufruf, seine Argumentliste), STUB_LOG_SLEEP (eine Zeile je Wartezeit),
# STUB_LOG_HDR (Modus und Bearer-Marke jeder `-H @<Datei>`-Kopfdatei), STUB_LOG_HDR_PUT (dieselbe
# Zeile, nur fuer die Kopfdateien des Schreibaufrufs `-X PUT`), STUB_HDR_PATH
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
  export STUB_LOG_SLEEP="$TMP/sleep.log" STUB_LOG_HDR="$TMP/hdr.log" STUB_LOG_HDR_PUT="$TMP/hdr-put.log"
  export STUB_HDR_PATH="$TMP/hdr.path" STUB_COUNT="$TMP/tapzaehler"
  export STUB_LOG_SHA="$TMP/sha.log" STUB_BODY="$TMP/body.json" STUB_WRITTEN="$TMP/geschrieben"
  export STUB_APPLIED="$TMP/angewendet"
  : >"$STUB_LOG_DOCKER"; : >"$STUB_LOG_CURL"; : >"$STUB_LOG_SLEEP"; : >"$STUB_LOG_HDR"; : >"$STUB_LOG_HDR_PUT"; : >"$STUB_LOG_SHA"
  export TAP_WAIT=0
  unset TAP_TOKEN
  SENTINEL="TOKSENTINEL-9f3a71c2"
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
# Schreiben (`-X PUT` an die Contents-Adresse): Code STUB_PUT_CODE (Vorgabe 200; 000 ist
# keine Antwort, Exit 7); der Body wandert nach STUB_BODY, der mitgesandte Stand nach
# STUB_LOG_SHA, der dekodierte Inhalt nach STUB_WRITTEN; nach einem Schreibaufruf (STUB_WRITTEN
# liegt vor) tragen die Lesevorgaenge den Code STUB_TAP_CODE_NACH_PUT, sofern gesetzt; bei Code 200 und STUB_PUT_APPLY=1
# liefern die folgenden Lesevorgaenge den geschriebenen Inhalt (STUB_APPLIED). Die Antwort
# traegt STUB_ECHO, damit ein Fall pruefen kann, dass keine Antwort ausgegeben wird.
set -eu
dest=""; wfmt=""; url=""; method=GET; body=""; hdrs=()
printf '%s\n' "$*" >>"$STUB_LOG_CURL"
while [ $# -gt 0 ]; do
  case "$1" in
    -o) dest="$2"; shift 2 ;;
    -w) wfmt="$2"; shift 2 ;;
    -X) method="$2"; shift 2 ;;
    --data-binary) body="${2#@}"; shift 2 ;;
    --max-time) shift 2 ;;
    -H) case "$2" in @*) hdrs+=("${2#@}") ;; esac; shift 2 ;;
    -*) shift ;;
    *) url="$1"; shift ;;
  esac
done
for h in "${hdrs[@]}"; do
  bearer=0; grep -q '^Authorization: Bearer ' "$h" && bearer=1
  zeile="modus=$(stat -c %a "$h") bearer=$bearer"
  printf '%s\n' "$zeile" >>"$STUB_LOG_HDR"
  if [ "$method" = PUT ]; then printf '%s\n' "$zeile" >>"$STUB_LOG_HDR_PUT"; fi
  printf '%s' "$h" >"$STUB_HDR_PATH"
done
case "$url" in
  */releases/download/*)
    code="${STUB_ASSET_CODE:-200}"
    [ "$code" = 200 ] && cp "$STUB_ASSET" "$dest"
    ;;
  */contents/*)
    if [ "$method" = PUT ]; then
      code="${STUB_PUT_CODE:-200}"
      cp "$body" "$STUB_BODY"
      sed -n 's/.*"sha":"\([^"]*\)".*/\1/p' "$body" >>"$STUB_LOG_SHA"
      sed -n 's/.*"content":"\([^"]*\)".*/\1/p' "$body" | base64 -d >"$STUB_WRITTEN" || :
      if [ "$code" != 000 ]; then printf '{"message":"antwort","echo":"%s"}' "${STUB_ECHO:-}" >"$dest"; fi
      if [ "$code" = 200 ] && [ "${STUB_PUT_APPLY:-}" = 1 ]; then cp "$STUB_WRITTEN" "$STUB_APPLIED"; fi
    else
      n=0; [ -f "$STUB_COUNT" ] && n="$(cat "$STUB_COUNT")"
      n=$((n + 1)); printf '%s' "$n" >"$STUB_COUNT"
      f="$STUB_TAP_1"; [ "$n" -gt 1 ] && [ -n "${STUB_TAP_2:-}" ] && f="$STUB_TAP_2"
      [ -f "$STUB_APPLIED" ] && f="$STUB_APPLIED"
      code="${STUB_TAP_CODE:-200}"
      if [ -f "$STUB_WRITTEN" ] && [ -n "${STUB_TAP_CODE_NACH_PUT:-}" ]; then code="$STUB_TAP_CODE_NACH_PUT"; fi
      if [ "$code" = 200 ]; then cp "$f" "$dest"
      else printf '{"message":"abgelehnt","echo":"%s"}' "${STUB_ECHO:-}" >"$dest"; fi
    fi
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

# lauf_getrennt <modus> <tag> [VAR=wert ...] — wie lauf, aber stdout und stderr getrennt:
# $output ist stdout, ${stderr_lines[@]} die Zeilen von stderr.
lauf_getrennt() {
  local modus="$1" tag="$2"; shift 2
  cd "$CWD"
  run --separate-stderr env TAG="$tag" "$@" bash "$SKRIPT" "$modus"
}

# nirgends <muster> <datei>... — gelingt nur, wenn keine der Dateien das Muster traegt.
# Ein Fund (grep 0) und ein Fehler von grep (2) brechen. Ein `!` vor grep mitten im Fall
# bricht unter `set -e` nicht, darum steht hier der Status.
nirgends() {
  local muster="$1" rc=0 treffer
  shift
  treffer="$(grep -lF -- "$muster" "$@")" || rc=$?
  if [ "$rc" -ne 1 ]; then
    echo "nirgends: grep Status $rc (0 = Fund, 2 = Fehler) fuer '$muster'; Fund in: $treffer" >&2
    return 1
  fi
}

# exit_zeilen — Zahl der Exit-Zeilen `tap-<modus>: Exit <N>` in $stderr des letzten lauf_getrennt.
exit_zeilen() { grep -c '^tap-[a-z]*: Exit ' <<<"$stderr" || true; }

docker_aufrufe() { grep -c . "$STUB_LOG_DOCKER" || true; }
tap_lesungen() { grep -c '/contents/' "$STUB_LOG_CURL" || true; }
digest() { sha256sum "$1" | awk '{print $1}'; }

# lauf_sync <tag> [VAR=wert ...] — der Modus sync mit dem Sentinel-Token, stdout und stderr getrennt.
lauf_sync() {
  local tag="$1"; shift
  lauf_getrennt sync "$tag" TAP_TOKEN="$SENTINEL" "$@"
}

# zuruecksetzen — Protokolle und Stub-Zustand leeren, fuer Faelle mit mehreren Laeufen.
zuruecksetzen() {
  : >"$STUB_LOG_DOCKER"; : >"$STUB_LOG_CURL"; : >"$STUB_LOG_SLEEP"; : >"$STUB_LOG_HDR"; : >"$STUB_LOG_HDR_PUT"; : >"$STUB_LOG_SHA"
  rm -f "$STUB_COUNT" "$STUB_APPLIED" "$STUB_BODY" "$STUB_WRITTEN"
}

schreibaufrufe() { grep -c -- '-X PUT' "$STUB_LOG_CURL" || true; }

# lesungen_gesamt — Lese-Aufrufe des Tap-Kopfs (ohne die Schreibaufrufe, die dieselbe Adresse tragen).
lesungen_gesamt() { grep /contents/ "$STUB_LOG_CURL" | grep -vc -- "-X PUT" || true; }

# lesungen_vor_schreiben — Lese-Aufrufe des Tap-Kopfs bis zum ersten Schreibaufruf.
lesungen_vor_schreiben() { awk '/-X PUT/ {exit} /\/contents\// {n++} END {print n+0}' "$STUB_LOG_CURL"; }

# blob <datei> — der Blob-Stand der Bytes: SHA-1 ueber `blob <Laenge>\0<Bytes>`.
blob() { { printf 'blob %s\0' "$(wc -c <"$1")"; cat "$1"; } | sha1sum | awk '{print $1}'; }

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

@test "check liest keine Version: ungleiche Bytes mit groesserer Tap-Version enden mit Exit 1, Formel-Unterschied und der Zeile tap-check: Exit 1" {
  # Gebunden ist diese eine Form: das Tap traegt eine GROESSERE version-Zeile als der Tag und
  # ungleiche Bytes. Eine kleinere Tap-Version (Fall "vorfall nachgestellt") und eine gleiche
  # version-Zeile bei sonst ungleichen Bytes sind andere Formen und nicht Gegenstand dieses Falls.
  formel 0.2.4 >"$TMP/tap024"
  [ "$(digest "$TMP/asset")" != "$(digest "$TMP/tap024")" ]
  lauf_getrennt check v0.2.3 STUB_TAP_1="$TMP/tap024"
  echo "Exit $status, stdout: $output, stderr: $stderr"
  [ "$status" -eq 1 ]
  [[ "$stderr" == *"Formel-Unterschied"* ]]
  [[ "$stderr" == *"Tap [  version \"0.2.4\"]"* ]]
  [ "${stderr_lines[-1]}" = "tap-check: Exit 1" ]
  [ "$(tap_lesungen)" -eq 2 ]
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

@test "tag-form: jedes Zeichen ausserhalb von [0-9A-Za-z.-] im Vorab- oder Build-Feld, ein leeres Feld und ein Praefix vor dem v enden mit Exit 2 und der Meldung der Tag-Form, ohne docker" {
  # Die Tags gehen nicht durch die Feldform-Stufe (Vorab-Zweig oder Kern gueltig): nur die
  # Tag-Form haelt sie auf. Zeichenmenge, Anfangs- und Endanker sind je Tag ein Zahn.
  for t in 'v1.0.0-rc$(touch${IFS}marker)' 'v1.0.0-rc;x' 'v1.0.0-rc$(id)' 'v1.0.0-rc.1+b;x' 'v1.0.0+b$(id)' \
    'v1.0.0-rc x' 'v1.0.0+b`id`' 'v1.0.0-' 'v1.0.0+' 'v1.0.0-rc+' 'xv1.0.0' 'x-v1.0.0-rc.1' ' v1.0.0' 'v1.0.0-rc.1
x'; do
    : >"$STUB_LOG_DOCKER"
    lauf check "$t"
    echo "Tag $(printf %q "$t"): Exit $status, Ausgabe: $output"
    [ "$status" -eq 2 ]
    [[ "$output" == *"Tag-Form falsch"* ]]
    [ ! -e "$CWD/marker" ]
    [ "$(docker_aufrufe)" -eq 0 ]
  done
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
  [[ "$rezept" != *'$(TAG)'* ]]
  [[ "$rezept" != *'${TAG}'* ]]
}

@test "uebergabe ohne text: die Rezeptzeilen von tap-nachzug nennen weder Tag noch Token als make-Referenz" {
  rezept="$(awk '/^tap-nachzug:/ {f=1; next} f && /^\t/ {print; next} f {exit}' "$MK")"
  [ -n "$rezept" ]
  [[ "$rezept" == *"tap-nachzug.sh sync"* ]]
  [[ "$rezept" != *'$(TAG)'* ]]
  [[ "$rezept" != *'${TAG}'* ]]
  [[ "$rezept" != *'$(TAP_TOKEN)'* ]]
  [[ "$rezept" != *'${TAP_TOKEN}'* ]]
}

@test "kein gate: tap-check und tap-nachzug stehen weder in gates noch in record-gates noch in einer Prerequisite-Kette" {
  grep -q '^tap-check:' "$MK"
  grep -q '^tap-nachzug:' "$MK"
  zeilen="$(grep -E '^(gates|record-gates):' "$MK")"
  [ "$(grep -c . <<<"$zeilen")" -eq 2 ]
  [[ "$zeilen" != *tap-check* ]]
  [[ "$zeilen" != *tap-nachzug* ]]
  # Eine Regelzeile `<ziel>: <prerequisites>`, die tap-nachzug vor einem Kommentar nennt, machte es
  # zur Prerequisite; die Regelzeile von tap-nachzug selbst nennt es nur vor dem Doppelpunkt.
  [ "$(grep -cE '^[a-z][A-Za-z0-9_%-]*:[^#=]*tap-nachzug' "$MK" || true)" -eq 0 ]
}

@test "token: ein Sentinel-Token steht in keiner Argumentliste und keiner Ausgabe, der Header liegt in einer 0600-Datei, die nach dem Lauf fehlt" {
  S="TOKSENTINEL-9f3a71c2"
  lauf check v0.2.3 TAP_TOKEN="$S"
  [ "$status" -eq 0 ]
  [[ "$output" != *"$S"* ]]
  nirgends "$S" "$STUB_LOG_CURL" "$STUB_LOG_DOCKER"
  grep -q -- '-H @' "$STUB_LOG_CURL"
  # Jede Kopfdatei, die curl bekommen hat, ist 0600 und traegt den Bearer; wie viele Lesungen
  # es waren, ist Sache der Cache-Fenster-Faelle.
  [ -s "$STUB_LOG_HDR" ]
  [ "$(grep -vcx 'modus=600 bearer=1' "$STUB_LOG_HDR" || true)" = 0 ]
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
  nirgends "$S" "$STUB_LOG_CURL" "$STUB_LOG_DOCKER"
  [ ! -e "$(cat "$STUB_HDR_PATH")" ]
  [ -z "$(ls -A "$TMP/work")" ]
}

@test "token: ohne Token liest der Lauf anonym, ohne Kopfdatei" {
  lauf check v0.2.3
  [ "$status" -eq 0 ]
  nirgends '-H @' "$STUB_LOG_CURL"
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

@test "modus: ein unbekannter oder fehlender Modus endet mit Exit 2 ohne docker" {
  for m in nachzug ''; do
    lauf "$m" v0.2.3 TAP_TOKEN="$SENTINEL"
    [ "$status" -eq 2 ]
    [[ "$output" == *"Aufruf: tap-nachzug.sh check|sync"* ]]
  done
  [ "$(docker_aufrufe)" -eq 0 ]
}

@test "transport: ein docker-Aufruf ohne Ergebnis der Nutzlast (Status 1, 3, 125, 127, 137, 143) endet mit Exit 2 statt 1, mit einer Meldung, die kein Ergebnis des Vergleichs behauptet" {
  # Status 1 ist der Ausgang des docker-Clients bei nicht erreichbarem Daemon; die Nutzlast
  # lief dann nicht. Klasse 1 kommt allein aus dem Ergebnis "Unterschied" der Nutzlast.
  # Die Meldung nennt den Status und sagt, dass das Ergebnis unbekannt ist; jede Aussage ueber
  # einen Zustand des Vergleichs ("verglichen", "Formel-Unterschied") steht nirgends in ihr —
  # geprueft ueber nirgends() auf einer Datei, weil ein `!` vor einem Test mitten im Fall unter
  # `set -e` nicht bricht.
  for s in 1 3 125 127 137 143; do
    lauf_getrennt check v0.2.3 STUB_DOCKER_EXIT="$s"
    echo "docker Status $s: Exit $status, stderr: $stderr"
    [ "$status" -eq 2 ]
    [[ "$stderr" == *"Transport im Bild endete ohne Ergebnis der Nutzlast (docker Exit $s)"* ]]
    [[ "$stderr" == *"Ergebnis des Vergleichs ist unbekannt"* ]]
    printf '%s\n' "$stderr" >"$TMP/stderr-$s"
    nirgends 'Formel-Unterschied' "$TMP/stderr-$s"
    nirgends 'verglichen' "$TMP/stderr-$s"
    [ "${stderr_lines[-1]}" = "tap-check: Exit 2" ]
  done
}

@test "aufruf: ohne TAG endet der Lauf mit Exit 2 und nennt die Variable" {
  cd "$CWD"
  run env -u TAG bash "$SKRIPT" check
  [ "$status" -eq 2 ]
  [[ "$output" == *"TAG"* ]]
  [[ "$output" == *"make tap-check TAG="* ]]
  [ "$(docker_aufrufe)" -eq 0 ]
  run env -u TAG TAP_TOKEN="$SENTINEL" bash "$SKRIPT" sync
  [ "$status" -eq 2 ]
  [[ "$output" == *"TAG"* ]]
  [[ "$output" == *"make tap-nachzug TAG="* ]]
  [ "$(docker_aufrufe)" -eq 0 ]
}

@test "nutzlast: die Datei ist ein POSIX-sh-Skript und ruft nur Programme des Bild-Bestands" {
  head -1 "$NUTZLAST" | grep -qx '#!/bin/sh'
  code="$(grep -v '^#' "$NUTZLAST")"
  [ -n "$code" ]
  for p in jq bash git gh python3; do
    if grep -qE "(^|[^[:alnum:]_./-])$p( |$)" <<<"$code"; then
      echo "die Nutzlast ruft $p, das das Bild nicht traegt" >&2
      return 1
    fi
  done
}

@test "exit-zeile: bei Exit 1 und Exit 2 ist die letzte stderr-Zeile des Skripts tap-<modus>: Exit <N> und steht genau einmal, bei Exit 0 fehlt sie" {
  # Exit 1: der Formel-Unterschied der Nutzlast.
  formel 0.2.2 >"$TMP/tap022"
  lauf_getrennt check v0.2.3 STUB_TAP_1="$TMP/tap022"
  [ "$status" -eq 1 ]
  [ "${stderr_lines[-1]}" = "tap-check: Exit 1" ]
  [ "$(exit_zeilen)" -eq 1 ]
  # Exit 2 aus sechs Herkuenften: Nutzlast (Tap nicht lesbar), Host (Tag-Form, Pin,
  # docker nicht gelaufen: Status 125 und 1) und der Modus sync (ohne TAP_TOKEN).
  lauf_getrennt check v0.2.3 STUB_TAP_CODE=403
  [ "$status" -eq 2 ]
  [ "${stderr_lines[-1]}" = "tap-check: Exit 2" ]
  [ "$(exit_zeilen)" -eq 1 ]
  lauf_getrennt check 'v1.0.0;x'
  [ "$status" -eq 2 ]
  [ "${stderr_lines[-1]}" = "tap-check: Exit 2" ]
  [ "$(exit_zeilen)" -eq 1 ]
  lauf_getrennt check v0.2.3 TAP_IMAGE=curlimages/curl:latest
  [ "$status" -eq 2 ]
  [ "${stderr_lines[-1]}" = "tap-check: Exit 2" ]
  [ "$(exit_zeilen)" -eq 1 ]
  lauf_getrennt check v0.2.3 STUB_DOCKER_EXIT=125
  [ "$status" -eq 2 ]
  [ "${stderr_lines[-1]}" = "tap-check: Exit 2" ]
  [ "$(exit_zeilen)" -eq 1 ]
  lauf_getrennt check v0.2.3 STUB_DOCKER_EXIT=1
  [ "$status" -eq 2 ]
  [ "${stderr_lines[-1]}" = "tap-check: Exit 2" ]
  [ "$(exit_zeilen)" -eq 1 ]
  lauf_getrennt sync v0.2.3
  [ "$status" -eq 2 ]
  [ "${stderr_lines[-1]}" = "tap-sync: Exit 2" ]
  [ "$(exit_zeilen)" -eq 1 ]
  # Exit 0 (gleich, Vorab-Tag): keine Exit-Zeile, auch nicht auf stdout.
  lauf_getrennt check v0.2.3
  [ "$status" -eq 0 ]
  [ "$(exit_zeilen)" -eq 0 ]
  [[ "$stderr" != *"Exit"* ]]
  [[ "$output" != *": Exit "* ]]
  lauf_getrennt check v1.0.0-rc.1
  [ "$status" -eq 0 ]
  [ "$(exit_zeilen)" -eq 0 ]
  [[ "$stderr" != *"Exit"* ]]
  [[ "$output" != *": Exit "* ]]
}

@test "stderr nicht beschreibbar: ein Schreibfehler des Skripts aendert seinen Exit nicht, nur die Zeile fehlt" {
  # Zugesagt ist der Exit des Skripts, nicht die Zeile: ein Schreibfehler seiner eigenen Ausgabe
  # macht aus Exit 2 weder 1 noch etwas anderes. Geschlossen (&-) und voll (/dev/full) sind zwei
  # Formen. Nicht gedeckt: eine nicht beschreibbare stderr des aufrufenden docker-Clients bei einem
  # Container, der auf seine stderr schreibt — docker ist hier ein Stub, der reale Client endet
  # dort mit Status 1 statt mit dem der Nutzlast (ADR-0066); eine im Container nicht beschreibbare
  # stderr aendert seinen Status nicht.
  printf 'pwd() { return 127; }\n' >"$TMP/defekt.sh"
  cd "$CWD"
  for ziel in '/dev/full' '&-'; do
    # Exit 2 in fehler(): falsche Tag-Form.
    run bash -c 'TAG="$1" exec bash "$2" check 2>'"$ziel" _ 'v1.0.0;x' "$SKRIPT"
    echo "Ziel $ziel, Tag-Form: Exit $status"
    [ "$status" -eq 2 ]
    # Exit 2 aus dem EXIT-Trap: ein Kommando des Skripts endet mit Status 127.
    run bash -c 'TAG="$1" BASH_ENV="$3" exec bash "$2" check 2>'"$ziel" _ v0.2.3 "$SKRIPT" "$TMP/defekt.sh"
    echo "Ziel $ziel, Status 127: Exit $status"
    [ "$status" -eq 2 ]
    # Exit 2 aus dem docker-Zweig: docker endet mit 125, ohne Ergebnis der Nutzlast.
    run bash -c 'TAG="$1" STUB_DOCKER_EXIT=125 exec bash "$2" check 2>'"$ziel" _ v0.2.3 "$SKRIPT"
    echo "Ziel $ziel, docker 125: Exit $status"
    [ "$status" -eq 2 ]
  done
}

@test "interner fehler: scheitert mktemp in der Nutzlast, endet der Lauf mit Exit 2 statt 1 und meldet keinen Unterschied" {
  mkdir "$TMP/kaputt-mktemp"
  printf '#!/bin/sh\necho "mktemp: kaputt" >&2\nexit 1\n' >"$TMP/kaputt-mktemp/mktemp"
  chmod 0755 "$TMP/kaputt-mktemp/mktemp"
  lauf_getrennt check v0.2.3 PATH="$TMP/kaputt-mktemp:$PATH"
  [ "$status" -eq 2 ]
  [[ "$stderr" == *"interner Fehler der Nutzlast"* ]]
  [[ "$stderr" == *"nichts verglichen"* ]]
  [[ "$stderr" != *"Formel-Unterschied"* ]]
  [[ "$stderr" != *"Transport im Bild"* ]]
  [ "${stderr_lines[-1]}" = "tap-check: Exit 2" ]
  [ "$(docker_aufrufe)" -eq 1 ]
}

# nutzlast_direkt <stub-status> — die Nutzlast ohne Host-Skript, mit einem mktemp, das mit dem
# Status endet: $status ist ihr Exit, $stderr ihre Meldung.
nutzlast_direkt() {
  mkdir -p "$TMP/mktemp-$1"
  printf '#!/bin/sh\nexit %s\n' "$1" >"$TMP/mktemp-$1/mktemp"
  chmod 0755 "$TMP/mktemp-$1/mktemp"
  cd "$CWD"
  run --separate-stderr env PATH="$TMP/mktemp-$1:$PATH" TAP_MODE=check TAP_TAG=v0.2.3 TAP_WAIT=0 \
    TAP_ASSET_URL=https://x.invalid/releases/download/v0.2.3/a TAP_URL=https://x.invalid/contents/a \
    sh "$NUTZLAST"
}

@test "interner fehler: ein Kommando der Nutzlast mit Status 1 oder ab 3 endet mit Exit 2 statt dem Status" {
  for s in 1 3 127; do
    nutzlast_direkt "$s"
    echo "mktemp Status $s: Exit $status, stderr: $stderr"
    [ "$status" -eq 2 ]
    [[ "$stderr" == *"interner Fehler der Nutzlast"* ]]
    [[ "$stderr" == *"nichts verglichen"* ]]
  done
}

@test "interner fehler: ein Kommando der Nutzlast mit dem Status des Unterschieds (10) endet mit Exit 2, ohne dass der Vergleich es gemeldet hat" {
  nutzlast_direkt 10
  [ "$status" -eq 2 ]
  [[ "$stderr" == *"interner Fehler der Nutzlast (ein Kommando endete mit 10)"* ]]
}

@test "unterschied: die Nutzlast meldet den Formel-Unterschied mit Status 10, nur er" {
  # Das Host-Skript bildet 10 auf seinen Exit 1 ab; der Status, den docker selbst liefert (1), ist es nicht.
  cd "$CWD"
  formel 0.2.2 >"$TMP/tap022"
  run env PATH="$TMP/bin:$PATH" TAP_MODE=check TAP_TAG=v0.2.3 TAP_WAIT=0 STUB_TAP_1="$TMP/tap022" \
    TAP_ASSET_URL=https://x.invalid/releases/download/v0.2.3/a TAP_URL=https://x.invalid/contents/a \
    sh "$NUTZLAST"
  [ "$status" -eq 10 ]
  run env PATH="$TMP/bin:$PATH" TAP_MODE=check TAP_TAG=v0.2.3 TAP_WAIT=0 \
    TAP_ASSET_URL=https://x.invalid/releases/download/v0.2.3/a TAP_URL=https://x.invalid/contents/a \
    sh "$NUTZLAST"
  [ "$status" -eq 0 ]
}

@test "interner fehler: liefert cmp in der Nutzlast Status 2, endet der Lauf mit Exit 2 statt 1 und meldet keinen Unterschied" {
  mkdir "$TMP/kaputt-cmp"
  printf '#!/bin/sh\nexit 2\n' >"$TMP/kaputt-cmp/cmp"
  chmod 0755 "$TMP/kaputt-cmp/cmp"
  lauf_getrennt check v0.2.3 PATH="$TMP/kaputt-cmp:$PATH"
  [ "$status" -eq 2 ]
  [[ "$stderr" == *"cmp Exit 2"* ]]
  [[ "$stderr" == *"nichts verglichen"* ]]
  [[ "$stderr" != *"Formel-Unterschied"* ]]
  [ "${stderr_lines[-1]}" = "tap-check: Exit 2" ]
}

@test "interner fehler: scheitert ein Kommando des Skripts selbst, endet der Lauf mit Exit 2 statt 1, ohne docker" {
  # BASH_ENV legt eine pwd-Funktion vor, die scheitert: das Skript ruft pwd fuer den Pfad der Nutzlast.
  printf 'pwd() { return 1; }\n' >"$TMP/defekt.sh"
  lauf_getrennt check v0.2.3 BASH_ENV="$TMP/defekt.sh"
  [ "$status" -eq 2 ]
  [[ "$stderr" == *"interner Fehler des Skripts"* ]]
  [[ "$stderr" == *"nichts verglichen"* ]]
  [ "${stderr_lines[-1]}" = "tap-check: Exit 2" ]
  [ "$(docker_aufrufe)" -eq 0 ]
}

@test "interner fehler: scheitert ein Kommando des Skripts selbst mit einem Status ab 3, endet der Lauf mit Exit 2 statt dem Status, ohne docker" {
  printf 'pwd() { return 127; }\n' >"$TMP/defekt.sh"
  lauf_getrennt check v0.2.3 BASH_ENV="$TMP/defekt.sh"
  [ "$status" -eq 2 ]
  [[ "$stderr" == *"interner Fehler des Skripts (Exit 127)"* ]]
  [[ "$stderr" == *"nichts verglichen"* ]]
  [ "${stderr_lines[-1]}" = "tap-check: Exit 2" ]
  [ "$(docker_aufrufe)" -eq 0 ]
}

# ---- sync: die Faelle der Fitness Function von ADR-0064, soweit sie den Modus sync betreffen ----

@test "sync fehlt-nachweis: ohne TAP_TOKEN endet der Lauf mit Exit 2 vor docker und vor jedem Netz-Zugriff, auch fuer einen Vorab-Tag, und nennt make tap-nachzug" {
  for t in v0.2.3 v1.0.0-rc.1; do
    for form in fehlt leer; do
      zuruecksetzen
      if [ "$form" = fehlt ]; then lauf_getrennt sync "$t"; else lauf_getrennt sync "$t" TAP_TOKEN=; fi
      echo "Tag $t, Token $form: Exit $status, stderr: $stderr"
      [ "$status" -eq 2 ]
      [[ "$stderr" == *"TAP_TOKEN ist nicht gesetzt"* ]]
      [[ "$stderr" == *"make tap-nachzug"* ]]
      [ "${stderr_lines[-1]}" = "tap-sync: Exit 2" ]
      [ "$(exit_zeilen)" -eq 1 ]
      [ "$(docker_aufrufe)" -eq 0 ]
      [ ! -s "$STUB_LOG_CURL" ]
    done
  done
  # Die Nutzlast fuehrt den Nachweis ein zweites Mal, falls sie ohne das Host-Skript laeuft: Exit 2, kein Schreibaufruf.
  zuruecksetzen
  cd "$CWD"
  run --separate-stderr env TAP_MODE=sync TAP_TAG=v0.2.3 TAP_WAIT=0 \
    TAP_ASSET_URL=https://x.invalid/releases/download/v0.2.3/a TAP_URL=https://x.invalid/contents/a sh "$NUTZLAST"
  [ "$status" -eq 2 ]
  [[ "$stderr" == *"TAP_TOKEN ist nicht gesetzt"* ]]
  [ "$(schreibaufrufe)" -eq 0 ]
}

@test "sync vorab-tag: Exit 0 mit Vorab-Tag, Tap bleibt — mit Token, ohne docker und ohne curl" {
  for t in v1.0.0-RC v1.0.0-rc.1+x v1.0.0-rc.1; do
    zuruecksetzen
    lauf_sync "$t"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Vorab-Tag, Tap bleibt"* ]]
    [ "$(docker_aufrufe)" -eq 0 ]
    [ ! -s "$STUB_LOG_CURL" ]
  done
}

@test "sync: ein Tap ohne Formel-Datei (404) und ein nicht auffindbares Asset enden mit Exit 2 ohne Schreibaufruf" {
  lauf_sync v0.2.3 STUB_TAP_CODE=404
  [ "$status" -eq 2 ]
  [[ "$stderr" == *"keine Formel-Datei"* ]]
  [ "${stderr_lines[-1]}" = "tap-sync: Exit 2" ]
  [ "$(schreibaufrufe)" -eq 0 ]
  zuruecksetzen
  lauf_sync v0.2.3 STUB_ASSET_CODE=404
  [ "$status" -eq 2 ]
  [[ "$stderr" == *"Asset nicht auffindbar"* ]]
  [ "$(schreibaufrufe)" -eq 0 ]
  [ "$(tap_lesungen)" -eq 0 ]
}

@test "sync wiederholt das Lesen bis zum Schreiben nicht: ein Lese-Aufruf des Tap-Kopfs vor dem einen Schreibaufruf, keine Wartezeit" {
  formel 0.2.2 >"$TMP/tapalt"
  lauf_sync v0.2.3 STUB_TAP_1="$TMP/tapalt" STUB_TAP_2="$TMP/asset"
  echo "Exit $status, stdout: $output, stderr: $stderr"
  [ "$status" -eq 0 ]
  [ "$(lesungen_vor_schreiben)" -eq 1 ]
  [ "$(schreibaufrufe)" -eq 1 ]
  [ ! -s "$STUB_LOG_SLEEP" ]
}

@test "sync idempotenz: gleiche Bytes enden mit Exit 0 ohne Schreibaufruf, mit einem Lese-Aufruf und ohne Wartezeit" {
  lauf_sync v0.2.3
  [ "$status" -eq 0 ]
  [[ "$output" == *"gleich"* ]]
  [[ "$output" == *"$(digest "$TMP/asset")"* ]]
  [ "$(schreibaufrufe)" -eq 0 ]
  [ "$(tap_lesungen)" -eq 1 ]
  [ ! -s "$STUB_LOG_SLEEP" ]
  [ "$(exit_zeilen)" -eq 0 ]
}

@test "sync vorwaerts-schutz: ein Tag mit kleinerem Kern als der Tap-Stand endet mit Exit 2 ohne Schreibaufruf, numerisch je Feld" {
  # Tap 0.2.3 gegen den aelteren Stabil-Tag v0.1.2; Tap 0.10.0 gegen v0.9.0 (numerisch je Feld ist 0.10.0
  # spaeter als 0.9.0); Tap 1.0.0 gegen v0.9.9.
  for paar in 0.2.3:v0.1.2 0.10.0:v0.9.0 1.0.0:v0.9.9 0.2.3:v0.2.2; do
    zuruecksetzen
    formel "${paar%%:*}" >"$TMP/tap"
    formel "${paar##*:v}" >"$TMP/asset"
    lauf_sync "${paar##*:}" STUB_TAP_1="$TMP/tap"
    echo "Tap ${paar%%:*}, Tag ${paar##*:}: Exit $status, stderr: $stderr"
    [ "$status" -eq 2 ]
    [[ "$stderr" == *"Vorwärts-Schutz"* ]]
    [[ "$stderr" == *"Tap-Stand ${paar%%:*}"* ]]
    [ "${stderr_lines[-1]}" = "tap-sync: Exit 2" ]
    [ "$(exit_zeilen)" -eq 1 ]
    [ "$(schreibaufrufe)" -eq 0 ]
  done
}

@test "sync vorwaerts-schutz: ein groesserer Kern (numerisch je Feld) und der Gleichstand schreiben" {
  # Tap 0.2.9 gegen v0.2.10: numerisch groesser, lexikografisch kleiner. Gleichstand: Tap und Tag
  # tragen 0.2.3, die Bytes sind verschieden.
  formel 0.2.9 >"$TMP/tap"
  formel 0.2.10 >"$TMP/asset"
  lauf_sync v0.2.10 STUB_TAP_1="$TMP/tap" STUB_PUT_APPLY=1
  echo "Exit $status, stderr: $stderr"
  [ "$status" -eq 0 ]
  [ "$(schreibaufrufe)" -eq 1 ]
  zuruecksetzen
  formel 0.2.3 >"$TMP/asset"
  sed '2s/.*/  desc "anderer Text"/' "$TMP/asset" >"$TMP/tap"
  lauf_sync v0.2.3 STUB_TAP_1="$TMP/tap" STUB_PUT_APPLY=1
  echo "Exit $status, stderr: $stderr"
  [ "$status" -eq 0 ]
  [ "$(schreibaufrufe)" -eq 1 ]
  [[ "$output" == *"nachgezogen"* ]]
}

@test "sync version-zeile: fehlende, mehrfache und der Feldform nicht genuegende Zeile enden mit Exit 2 ohne Schreibaufruf und nennen die Zeile, nie 0.0.0" {
  formel 0.2.3 | sed '/^  version/d' >"$TMP/tap-ohne"
  formel 0.2.3 | sed '11p' >"$TMP/tap-doppelt"
  for f in 0.08.3 0.2.99999999999999999999 0.2 0.2.3.4 0.2. ''; do formel "$f" >"$TMP/tap-form-$f"; done
  for fall in ohne:fehlt doppelt:mehrfach form-0.08.3:Feldform form-0.2.99999999999999999999:Feldform form-0.2:Feldform form-0.2.3.4:Feldform form-0.2.:Feldform form-:Feldform; do
    zuruecksetzen
    lauf_sync v0.2.3 STUB_TAP_1="$TMP/tap-${fall%%:*}"
    echo "Fall ${fall%%:*}: Exit $status, stderr: $stderr"
    [ "$status" -eq 2 ]
    [[ "$stderr" == *"version-Zeile"* ]]
    [[ "$stderr" == *"${fall##*:}"* ]]
    [[ "$stderr" != *"0.0.0"* ]]
    [[ "$stderr" != *"arithmetic"* ]]
    [ "${stderr_lines[-1]}" = "tap-sync: Exit 2" ]
    [ "$(exit_zeilen)" -eq 1 ]
    [ "$(schreibaufrufe)" -eq 0 ]
  done
  # Schritt d geht Schritt e voraus: auch gleiche Bytes mit einer Zeile ausserhalb der Feldform enden mit Exit 2.
  zuruecksetzen
  cp "$TMP/tap-form-0.08.3" "$TMP/asset"
  lauf_sync v0.2.3 STUB_TAP_1="$TMP/tap-form-0.08.3"
  [ "$status" -eq 2 ]
  [[ "$stderr" == *"Feldform"* ]]
  [ "$(schreibaufrufe)" -eq 0 ]
}

@test "sync token: ein Sentinel-Token steht in keiner Argumentliste und keiner Ausgabe — bei Erfolg, Konflikt, Ablehnung, Serverfehler und ohne Antwort; der Header liegt in einer 0600-Datei, die nach dem Lauf fehlt" {
  formel 0.2.2 >"$TMP/tapalt"
  for fall in 200 409 401 500 000; do
    zuruecksetzen
    lauf_sync v0.2.3 STUB_TAP_1="$TMP/tapalt" STUB_PUT_CODE="$fall" STUB_PUT_APPLY=1 STUB_ECHO="$SENTINEL"
    echo "Schreib-Code $fall: Exit $status, stdout: $output, stderr: $stderr"
    [ "$(schreibaufrufe)" -eq 1 ]
    [[ "$output$stderr" != *"$SENTINEL"* ]]
    nirgends "$SENTINEL" "$STUB_LOG_CURL" "$STUB_LOG_DOCKER" "$STUB_BODY"
    grep -q -- '-e TAP_TOKEN' "$STUB_LOG_DOCKER"
    nirgends 'TAP_TOKEN=' "$STUB_LOG_DOCKER"
    [ -s "$STUB_LOG_HDR" ]
    [ "$(grep -vcx 'modus=600 bearer=1' "$STUB_LOG_HDR" || true)" = 0 ]
    # Der Schreibaufruf traegt den Zugangs-Header als Kopfdatei (0600, Bearer); sein Token steht nach den Zeilen oben in keiner Argumentliste.
    [ "$(cat "$STUB_LOG_HDR_PUT")" = 'modus=600 bearer=1' ]
    [ ! -e "$(cat "$STUB_HDR_PATH")" ]
    [ -z "$(ls -A "$TMP/work")" ]
  done
}

@test "sync schreiben: die geschriebenen Bytes sind die des Assets (Nicht-ASCII-Byte, mit und ohne Endzeilenumbruch), der Body ist eine Zeile, die Commit-Message nennt den Tag und sagt keine Pruefung zu" {
  formel 0.2.2 >"$TMP/tapalt"
  for variante in ohne mit; do
    zuruecksetzen
    formel 0.2.3 >"$TMP/asset"
    if [ "$variante" = mit ]; then printf '\n' >>"$TMP/asset"; fi
    lauf_sync v0.2.3 STUB_TAP_1="$TMP/tapalt" STUB_PUT_APPLY=1
    echo "Variante $variante: Exit $status, stdout: $output, stderr: $stderr"
    [ "$status" -eq 0 ]
    [[ "$output" == *"nachgezogen"* ]]
    [[ "$output" == *"v0.2.3"* ]]
    [[ "$output" == *"$(digest "$TMP/asset")"* ]]
    [ "$(exit_zeilen)" -eq 0 ]
    [ -s "$STUB_WRITTEN" ]
    cmp "$STUB_WRITTEN" "$TMP/asset"
    [ "$(wc -l <"$STUB_BODY")" -eq 1 ]
    msg="$(sed -n 's/.*"message":"\([^"]*\)".*/\1/p' "$STUB_BODY")"
    [[ "$msg" == *"v0.2.3"* ]]
    [[ "$msg" == *"Asset"* ]]
    [[ "$msg" != *igest* ]]
    [[ "$msg" != *"geprüft"* ]]
    [[ "$msg" != *sha256* ]]
  done
}

@test "sync optimistisch: das Schreiben traegt den Blob-Stand der gelesenen Bytes, ein Konflikt endet mit Exit 2 ohne zweiten Versuch und meldet Tap unveraendert" {
  formel 0.2.2 >"$TMP/tapalt"
  formel 0.2.1 >"$TMP/tapneuer"
  # Erfolg: der mitgesandte Stand ist der Blob-Stand der Bytes des ersten Lesens.
  lauf_sync v0.2.3 STUB_TAP_1="$TMP/tapalt" STUB_PUT_APPLY=1
  [ "$status" -eq 0 ]
  [ "$(cat "$STUB_LOG_SHA")" = "$(blob "$TMP/tapalt")" ]
  # Konflikt: ein Versuch, derselbe Stand, kein Wiederholungslesen und kein zweiter Schreibaufruf.
  zuruecksetzen
  lauf_sync v0.2.3 STUB_TAP_1="$TMP/tapalt" STUB_TAP_2="$TMP/tapneuer" STUB_PUT_CODE=409
  echo "Exit $status, stderr: $stderr"
  [ "$status" -eq 2 ]
  [ "$(schreibaufrufe)" -eq 1 ]
  [ "$(cat "$STUB_LOG_SHA")" = "$(blob "$TMP/tapalt")" ]
  [ "$(lesungen_gesamt)" -eq 1 ]
  [[ "$stderr" == *"Tap unverändert"* ]]
  [[ "$stderr" != *"ungewiss"* ]]
  [ "${stderr_lines[-1]}" = "tap-sync: Exit 2" ]
  [ "$(exit_zeilen)" -eq 1 ]
}

@test "sync abgelehnt: 401, 403 und 409 melden Tap unveraendert, jede andere oder keine Antwort meldet Ausgang ungewiss mit make tap-check und nie unveraendert" {
  formel 0.2.2 >"$TMP/tapalt"
  for code in 401 403 409; do
    zuruecksetzen
    lauf_sync v0.2.3 STUB_TAP_1="$TMP/tapalt" STUB_PUT_CODE="$code"
    echo "Code $code: Exit $status, stderr: $stderr"
    [ "$status" -eq 2 ]
    [[ "$stderr" == *"HTTP $code"* ]]
    [[ "$stderr" == *"Tap unverändert"* ]]
    [[ "$stderr" != *"ungewiss"* ]]
    [ "$(schreibaufrufe)" -eq 1 ]
    [ "${stderr_lines[-1]}" = "tap-sync: Exit 2" ]
    [ "$(exit_zeilen)" -eq 1 ]
  done
  for code in 000 500 502 201 204 404 422 429; do
    zuruecksetzen
    lauf_sync v0.2.3 STUB_TAP_1="$TMP/tapalt" STUB_PUT_CODE="$code"
    echo "Code $code: Exit $status, stderr: $stderr"
    [ "$status" -eq 2 ]
    [[ "$stderr" == *"Ausgang des Schreibens ungewiss"* ]]
    [[ "$stderr" == *"make tap-check TAG=v0.2.3"* ]]
    printf '%s\n' "$stderr" >"$TMP/stderr-$code"
    nirgends 'unverändert' "$TMP/stderr-$code"
    [ "$(schreibaufrufe)" -eq 1 ]
    [ "${stderr_lines[-1]}" = "tap-sync: Exit 2" ]
    [ "$(exit_zeilen)" -eq 1 ]
  done
}

@test "sync nachkontrolle: bestaetigt die Schnittstelle das Schreiben und liefert das Lesen beide Male den alten Stand, endet der Lauf mit Exit 1, den Digests und der Zeile tap-sync: Exit 1" {
  formel 0.2.2 >"$TMP/tapalt"
  lauf_sync v0.2.3 STUB_TAP_1="$TMP/tapalt"
  echo "Exit $status, stderr: $stderr"
  [ "$status" -eq 1 ]
  [[ "$stderr" == *"Formel-Unterschied nach dem Schreiben"* ]]
  [[ "$stderr" == *"$(digest "$TMP/asset")"* ]]
  [[ "$stderr" == *"$(digest "$TMP/tapalt")"* ]]
  [ "${stderr_lines[-1]}" = "tap-sync: Exit 1" ]
  [ "$(exit_zeilen)" -eq 1 ]
  [ "$(schreibaufrufe)" -eq 1 ]
  [ "$(lesungen_gesamt)" -eq 3 ]
  [ "$(cat "$STUB_LOG_SLEEP")" = "0" ]
}

@test "sync teilerfolg: ist das Tap nach einem erfolgreichen Schreiben nicht lesbar, endet der Lauf mit Exit 2, sagt dass das Schreiben bereits erfolgt ist und nennt make tap-check — vor dem Schreiben bleibt es bei nichts verglichen" {
  formel 0.2.2 >"$TMP/tapalt"
  # Vor dem Schreiben: kein Schreibaufruf, die Meldung sagt, dass nichts verglichen wurde.
  lauf_sync v0.2.3 STUB_TAP_1="$TMP/tapalt" STUB_TAP_CODE=404
  echo "vor dem Schreiben: Exit $status, stderr: $stderr"
  [ "$status" -eq 2 ]
  [ "$(schreibaufrufe)" -eq 0 ]
  [[ "$stderr" == *"es wurde nichts verglichen"* ]]
  [[ "$stderr" != *"bereits erfolgt"* ]]
  # Nach dem Schreiben (HTTP 200): jede Lesung der Nachkontrolle, die scheitert.
  for code in 404 401 403 429 500 000; do
    zuruecksetzen
    lauf_sync v0.2.3 STUB_TAP_1="$TMP/tapalt" STUB_PUT_CODE=200 STUB_TAP_CODE_NACH_PUT="$code"
    echo "Lesecode nach dem Schreiben $code: Exit $status, stderr: $stderr"
    [ "$status" -eq 2 ]
    [ "$(schreibaufrufe)" -eq 1 ]
    [[ "$stderr" == *"das Schreiben ist bereits erfolgt"* ]]
    [[ "$stderr" == *"make tap-check TAG=v0.2.3"* ]]
    printf '%s\n' "$stderr" >"$TMP/stderr-$code"
    nirgends 'nichts verglichen' "$TMP/stderr-$code"
    [ "${stderr_lines[-1]}" = "tap-sync: Exit 2" ]
    [ "$(exit_zeilen)" -eq 1 ]
  done
}
