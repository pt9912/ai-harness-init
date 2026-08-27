#!/usr/bin/env bats
# full-smoke-ausgang.bats — Tests fuer die Einordnung eines roten full-smoke-
# Abschnitts (harness/tools/full-smoke-ausgang.sh, slice-106).
#
# HERMETISCH: gemessen wird ausschliesslich der Einordner ueber AUSSCHNITTEN ECHTER
# LAEUFE. Kein Docker, kein Netz — der Test laeuft im gepinnten bats-Image mit
# --network none.
#
# DIE AUSSCHNITTE SIND ZITATE, KEINE NACHBAUTEN. Woher jeder stammt, steht an ihm.
# Ein erfundener Fehlertext prueft die Vorstellung des Autors davon, wie ein
# Registry-Ausfall aussieht — und genau die ist der Gegenstand, nicht der Massstab.
#
# ZWEI RICHTUNGEN, ZWEI BRUCHSTELLEN: dass LEITUNG erkannt wird, und dass BAUM NICHT
# zu LEITUNG wird. Ein Einordner, der immer LEITUNG sagt, bestuende die erste Haelfte
# und machte jedes rote Gate zur Umgebungsfrage.

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  AUSGANG="$REPO/harness/tools/full-smoke-ausgang.sh"

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
