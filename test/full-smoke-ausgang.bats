#!/usr/bin/env bats
# full-smoke-ausgang.bats — zwei Gegenstaende, beide zu slice-106:
#   (1) die EINORDNUNG eines roten Abschnitts (harness/tools/full-smoke-ausgang.sh),
#   (2) die ABDECKUNGS-ZUSAGE dieser Einordnung, die im Kopf von
#       harness/tools/full-smoke.sh und in harness/README.md steht.
#
# HERMETISCH: gemessen werden der Einordner ueber AUSSCHNITTEN ECHTER LAEUFE und der
# TEXT des Prueflauf-Sensors — kein Docker, kein Netz, kein Lauf. Der Test laeuft im
# gepinnten bats-Image mit --network none.
#
# DIE AUSSCHNITTE SIND ZITATE, KEINE NACHBAUTEN. Woher jeder stammt, steht an ihm.
# Ein erfundener Fehlertext prueft die Vorstellung des Autors davon, wie ein
# Registry-Ausfall aussieht — und genau die ist der Gegenstand, nicht der Massstab.
#
# ZU (1) — ZWEI RICHTUNGEN, ZWEI BRUCHSTELLEN: dass LEITUNG erkannt wird, und dass BAUM
# NICHT zu LEITUNG wird. Ein Einordner, der immer LEITUNG sagt, bestuende die erste
# Haelfte und machte jedes rote Gate zur Umgebungsfrage.
#
# ZU (2) — die Zusage nennt ein Kriterium und eine Gleichung als Probe darauf. Beides
# driftet ohne Waechter lautlos, und zwar in zwei Richtungen: ein ENTFERNTER
# Einordnungs-Aufruf faellt in keinem Gate auf, und eine NEU eingefuegte Stufe ohne
# Einordnung ebensowenig. Ein gruener full-smoke-Lauf kann das nicht zeigen — er ruft
# die Einordnung nie. Deshalb misst (2) den Text und nicht den Lauf.

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  AUSGANG="$REPO/harness/tools/full-smoke-ausgang.sh"
  SMOKE="$REPO/harness/tools/full-smoke.sh"

  # (L1) CI-Job 97824094857 vom 2026-08-25, Protokollzeilen 5836-5851, mit dem
  # Zeitstempel-Praefix des Aktionslaufs. Die Registry antwortete auf die
  # Manifest-Anfrage nach dem gepinnten golang-Bild mit 502.
  LEITUNG_CI="$(cat <<'ENDE'
2026-08-25T13:44:57.7529000Z #4 [internal] load metadata for docker.io/library/golang:1.27.0
2026-08-25T13:44:57.7529983Z #4 ERROR: unexpected status from HEAD request to https://registry-1.docker.io/v2/library/golang/manifests/1.27.0: 502 Bad Gateway
2026-08-25T13:44:57.7531021Z ------
2026-08-25T13:44:57.7531442Z  > [internal] load metadata for docker.io/library/golang:1.27.0:
2026-08-25T13:44:57.7531945Z ------
2026-08-25T13:44:57.7535783Z ERROR: failed to build: failed to solve: golang:1.27.0: unexpected status from HEAD request to https://registry-1.docker.io/v2/library/golang/manifests/1.27.0: 502 Bad Gateway
2026-08-25T13:44:57.7536952Z make[1]: *** [harness/mk/apps-hex.mk:11: test-apps-hex] Error 1
ENDE
)"

  # (L2) Lokaler Lauf vom 2026-08-27:
  # make full-smoke GO_VERSION=9.99.9-gibt-es-nicht
  # Derselbe Schritt, anderer Antwortcode — der Tag ist nicht vergeben.
  LEITUNG_TAG="$(cat <<'ENDE'
#4 ERROR: docker.io/library/golang:9.99.9-gibt-es-nicht: not found
------
 > [internal] load metadata for docker.io/library/golang:9.99.9-gibt-es-nicht:
------
Dockerfile:9
--------------------
   9 | >>> FROM golang:${GO_VERSION} AS deps
--------------------
ERROR: failed to build: failed to solve: golang:9.99.9-gibt-es-nicht: docker.io/library/golang:9.99.9-gibt-es-nicht: not found
make[1]: *** [harness/mk/go.mk:11: test] Fehler 1
ENDE
)"

  # (L3) Lokaler Lauf vom 2026-08-27:
  # make ci-lint ACTIONLINT_IMAGE=ghcr.io/pt9912/gibt-es-diesen-namen-nicht:v0
  # Der andere Weg zur Registry: der Daemon holt beim Container-Start.
  LEITUNG_DAEMON="$(cat <<'ENDE'
docker run --rm -v "/Development/KI/ai-harness-init":/repo:ro -w /repo ghcr.io/pt9912/gibt-es-diesen-namen-nicht:v0
Unable to find image 'ghcr.io/pt9912/gibt-es-diesen-namen-nicht:v0' locally
docker: Error response from daemon: Head "https://ghcr.io/v2/pt9912/gibt-es-diesen-namen-nicht/manifests/v0": denied
make: *** [Makefile:142: ci-lint] Fehler 125
ENDE
)"

  # (L4) Lokaler Lauf vom 2026-08-27:
  # make ci-lint ACTIONLINT_IMAGE=rhysd/actionlint:gibt-es-diesen-tag-nicht
  # Repository und Host stimmen, der Tag fehlt.
  LEITUNG_MANIFEST="$(cat <<'ENDE'
Unable to find image 'rhysd/actionlint:gibt-es-diesen-tag-nicht' locally
docker: Error response from daemon: manifest for rhysd/actionlint:gibt-es-diesen-tag-nicht not found: manifest unknown: manifest unknown
make: *** [Makefile:142: ci-lint] Fehler 125
ENDE
)"

  # (B1) Lokaler Lauf vom 2026-08-27: make build ueber einem Baum mit eingesetztem
  # Syntaxfehler. DER SCHWERE FALL — die Ausgabe traegt denselben Kontextblock-Marker
  # und dieselbe failed-to-solve-Zeile wie (L1) und (L2); nur der genannte Schritt ist
  # ein anderer.
  BAUM_BUILD="$(cat <<'ENDE'
#14 [build 2/2] RUN CGO_ENABLED=0 GOOS= GOARCH=     go build -trimpath -ldflags="-s -w" -o /out/ai-harness-init ./cmd/ai-harness-init
#14 4.534 # github.com/pt9912/ai-harness-init/cmd/ai-harness-init
#14 4.534 cmd/ai-harness-init/main.go:513:33: syntax error: unexpected {, expected )
#14 ERROR: process "/bin/sh -c CGO_ENABLED=0 GOOS=${TARGET_OS} GOARCH=${TARGET_ARCH}     go build -trimpath -ldflags=\"-s -w\" -o /out/ai-harness-init ./cmd/ai-harness-init" did not complete successfully: exit code: 1
------
 > [build 2/2] RUN CGO_ENABLED=0 GOOS= GOARCH=     go build -trimpath -ldflags="-s -w" -o /out/ai-harness-init ./cmd/ai-harness-init:
4.534 cmd/ai-harness-init/main.go:513:33: syntax error: unexpected {, expected )
------
ERROR: failed to build: failed to solve: process "/bin/sh -c CGO_ENABLED=0 GOOS=${TARGET_OS} GOARCH=${TARGET_ARCH}     go build -trimpath -ldflags=\"-s -w\" -o /out/ai-harness-init ./cmd/ai-harness-init" did not complete successfully: exit code: 1
make: *** [Makefile:64: build] Fehler 1
ENDE
)"

  # (B2) Lokaler Lauf vom 2026-08-27: make docs-check, nachdem der gitignorierte
  # Traeger beiseitegelegt wurde — derselbe Befund, mit dem die CI am 2026-08-26 rot
  # war. Ein Doku-Gate-Befund ohne jede Registry-Zeile.
  BAUM_DCHECK="$(cat <<'ENDE'
docker run --rm --network none -v "/Development/KI/ai-harness-init:/repo:ro" ghcr.io/pt9912/d-check@sha256:3996a593b9cb71aa3bcb4f3ddf8f637e7409db31b3a2dac7eedc28d65814cacf
docs/plan/planning/done/slice-098-feldliste-ist-ausdruck-des-traegers.md:198	../../../../.harness/state/bin	target-missing
d-check: 406 Datei(en) geprueft, 1 Befund(e)
make: *** [d-check.mk:32: docs-check] Fehler 1
ENDE
)"
}

# ordne faehrt den Einordner mit dem Ausschnitt auf stdin. Der Text geht als Argument
# in die Sub-Shell, nicht in ihren Quelltext — sonst entschiede die Anfuehrungszeichen-
# Lage des Ausschnitts ueber das Ergebnis.
ordne() {
  run bash -c 'bash "$1" "$2" <<<"$3"' _ "$AUSGANG" "$1" "$2"
}

@test "ausgang: 502 der Registry auf ein gepinntes Bild -> LEITUNG" {
  ordne "make gates im Ziel" "$LEITUNG_CI"
  [ "$status" -eq 0 ]
  printf '%s' "$output" | grep -q 'AUSGANG LEITUNG'
  # Die Kennung des Abschnitts steht in der Meldung: ohne sie sagt der Ausgang nicht,
  # WELCHE Stufe die Anfrage stellte.
  printf '%s' "$output" | grep -q 'make gates im Ziel'
  # Der Beleg steht dabei — ein Ausgang ohne die Zeile, die ihn traegt, ist eine
  # Behauptung (AGENTS.md 3.6).
  printf '%s' "$output" | grep -q '502 Bad Gateway'
}

@test "ausgang: nicht vergebener Tag des gepinnten Bildes -> LEITUNG" {
  ordne "make gates im Ziel" "$LEITUNG_TAG"
  [ "$status" -eq 0 ]
  printf '%s' "$output" | grep -q 'AUSGANG LEITUNG'
  printf '%s' "$output" | grep -q 'load metadata for'
}

@test "ausgang: Daemon-Antwort auf die Registry-Anfrage beim Container-Start -> LEITUNG" {
  ordne "make ci-lint" "$LEITUNG_DAEMON"
  [ "$status" -eq 0 ]
  printf '%s' "$output" | grep -q 'AUSGANG LEITUNG'
}

@test "ausgang: unbekanntes Manifest bei stimmendem Host -> LEITUNG" {
  ordne "make ci-lint" "$LEITUNG_MANIFEST"
  [ "$status" -eq 0 ]
  printf '%s' "$output" | grep -q 'AUSGANG LEITUNG'
}

@test "ausgang: Uebersetzungsfehler im Baum -> BAUM (trotz Kontextblock und failed to solve)" {
  ordne "make build" "$BAUM_BUILD"
  [ "$status" -eq 0 ]
  printf '%s' "$output" | grep -q 'AUSGANG BAUM'
  # Ausdruecklich NICHT LEITUNG: dieser Ausschnitt traegt die Marker, an denen ein zu
  # weites Muster haengenbliebe.
  ! printf '%s' "$output" | grep -q 'AUSGANG LEITUNG'
}

@test "ausgang: Doku-Gate-Befund -> BAUM" {
  ordne "make docs-check" "$BAUM_DCHECK"
  [ "$status" -eq 0 ]
  printf '%s' "$output" | grep -q 'AUSGANG BAUM'
  ! printf '%s' "$output" | grep -q 'AUSGANG LEITUNG'
}

@test "ausgang: ohne Kennung endet der Einordner mit 2 und sagt, was fehlt" {
  ordne "" "$BAUM_DCHECK"
  [ "$status" -eq 2 ]
  printf '%s' "$output" | grep -q 'genau ein Argument'
}

# --- (2) die Abdeckungs-Zusage im Kopf von harness/tools/full-smoke.sh ---------------
#
# DREI FORMEN OHNE BILD-ANFORDERUNG, in derselben Gestalt wie im Kopf des Sensors und in
# harness/README.md: der Trockenlauf (make -n fuehrt kein Rezept aus), make span-clean
# (Rezept im Ziel: rm -rf plus echo) und der Hook-Wrapper (ein Shell-Skript, das das
# Host-Binaer startet und docker nicht nennt).
OHNE_BILD=' -n |span-clean|bash "\$wrapper"'

# abschnitte druckt "<zeile>:<inhalt>" jedes Abschnitts, der seinen eigenen Exit-Code
# fuehrt — das ist die Menge, ueber der das Kriterium gilt. EIN Ausdruck, hier und im
# Kopf des Sensors; zwei getrennt gepflegte waeren die Drift-Konstruktion selbst.
abschnitte() { grep -nE '\|\| [a-z_0-9]+=\$\?$' "$SMOKE"; }

@test "abdeckung: jede make-Stufe mit eigenem Exit-Code traegt eine Einordnung" {
  nummern="$(abschnitte | cut -d: -f1)"
  fehlend=""
  geprueft=0
  while IFS= read -r nr; do
    if [ -z "$nr" ]; then continue; fi
    zeile="$(sed -n "${nr}p" "$SMOKE")"
    case "$zeile" in
      *' -n '*|*span-clean*|*'bash "$wrapper"'*|*tmpbin/ai-harness-init*) continue ;;
    esac
    geprueft=$((geprueft + 1))
    # Das Fenster reicht bis zum naechsten Abschnitt: der Fehlschlag-Zweig eines
    # Abschnitts liegt zwischen ihm und dem folgenden. Die Deckelung bei 70 Zeilen
    # haelt das Fenster auch dort eng, wo der naechste Abschnitt weit entfernt ist.
    naechste="$(printf '%s\n' "$nummern" | awk -v n="$nr" '$1 > n { print $1; exit }')"
    if [ -z "$naechste" ]; then naechste=$((nr + 71)); fi
    ende=$((naechste - 1))
    if [ "$ende" -gt "$((nr + 70))" ]; then ende=$((nr + 70)); fi
    if ! sed -n "${nr},${ende}p" "$SMOKE" | grep -qE '^[[:space:]]*einordnen "'; then
      fehlend="$fehlend [Zeile $nr]"
    fi
  done <<<"$nummern"

  # Ein leerer Pruefbereich waere ein gruener Lauf ohne Aussage (LH-QA-01). Wie GROSS er
  # ist, haelt der Gleichungs-Fall unten fest; hier genuegt, dass er nicht leer ist.
  if [ "$geprueft" -lt 1 ]; then
    echo "abdeckung: keine einzige make-Stufe gefunden — der Ausdruck trifft den Sensor nicht mehr"
    false
  fi
  if [ -n "$fehlend" ]; then
    echo "abdeckung: $geprueft make-Stufen geprueft, ohne Einordnung:$fehlend"
    echo "  Der Kopf von harness/tools/full-smoke.sh sagt zu, dass jeder Abschnitt, der ein"
    echo "  Bild anfordern kann, seinen Ausgang selbst nennt. An diesen Stellen tut er es"
    echo "  nicht: ein Registry-Ausfall dort saehe aus wie ein roter Baum."
    false
  fi
}

@test "abdeckung: die Gleichung des Kriteriums haelt (Abschnitte - ohne Bild - Werkzeug == Einordnungen - 2)" {
  a="$(abschnitte | wc -l | tr -d ' ')"
  b="$(abschnitte | grep -cE "$OHNE_BILD" || true)"
  c="$(abschnitte | grep -c 'tmpbin/ai-harness-init' || true)"
  # Mit Zeilenanfangs-Anker: ohne ihn zaehlte der Kopf des Sensors seine eigene
  # Erwaehnung des Kommandos mit.
  d="$(grep -cE '^[[:space:]]*einordnen "' "$SMOKE" || true)"
  links=$((a - b - c))
  rechts=$((d - 2))

  # DIE ZWEI sind die Werkzeug-Aufrufe mit Erstbezug (d-check beim ersten Bootstrap,
  # a-check beim ersten --arch-Modul). Die Zahl steht hier UND im Text; wer einen
  # dritten Werkzeug-Aufruf einordnet, faerbt diesen Fall rot und zieht den Text nach.
  if [ "$links" -ne "$rechts" ]; then
    echo "abdeckung: A=$a B=$b C=$c D=$d  ->  A-B-C=$links gegen D-2=$rechts"
    if [ "$links" -gt "$rechts" ]; then
      echo "  Links groesser: es gibt make-Stufen ohne Einordnung — welche, sagt der Fall darueber."
    else
      echo "  Rechts groesser: es gibt mehr Einordnungen als make-Stufen plus zwei. Entweder"
      echo "  steht eine an einem Abschnitt, der kein Bild anfordert, oder ein dritter"
      echo "  Werkzeug-Aufruf ist eingeordnet — dann gehoert der Text nachgezogen."
    fi
    false
  fi
}
