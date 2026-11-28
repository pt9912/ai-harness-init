#!/usr/bin/env bats
# release-host-bau.bats — Lauf- und Koppel-Waechter des Host-Release-Baus
# (slice-release-bau-dockerlos-v1, ADR-0115 Festlegung 1/6a).
#
# DER BAU IST REAL (LH-QA-02, AGENTS.md §3.6): die Happy- und Fehlt-Fall-Zusaegen
# laufen `make release-artifacts-host` ueber echtes go — kein Stub, kein Rezept-Abgleich.
# Grenze: die Matrix-Zusaegen (genau die LH-QA-04-Menge, sechs Kombinationen,
# Windows-.exe) haelt test/release-matrix.bats an derselben Tafel; dieser Test liest
# die Tafel nur als Koppelstelle des Rezepts, nicht als zweite Liste.

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  MK="$REPO/Makefile"
  WF="$REPO/.github/workflows/release.yml"
}

# LH-QA-02: zwei Laeufe desselben Baums mit derselben Pin-Fassung liefern
# byte-identische SHA256SUMS. Der zweite Lauf ist konvergent (release-sums.sh
# generate ueberschreibt), nicht kumulativ — sonst misst der Test das
# Wiederholungs-Muster statt der Reproduzierbarkeit.
@test "release-host: der zweite Lauf desselben Baums liefert byte-identische SHA256SUMS (LH-QA-02)" {
  local d
  d="$(mktemp -d)"
  run make -C "$REPO" release-artifacts-host DEST="$d" TRAEGER_VERSION=v0.0.0-bautest
  [ "$status" -eq 0 ]
  [ "$(find "$d" -maxdepth 1 -name 'ai-harness-init-*' | wc -l)" -eq 6 ]
  [ -s "$d/SHA256SUMS" ]
  [ -s "$d/ai-harness-init.rb" ]
  cp "$d/SHA256SUMS" "$d/sums.erstlauf"
  run make -C "$REPO" release-artifacts-host DEST="$d" TRAEGER_VERSION=v0.0.0-bautest
  [ "$status" -eq 0 ]
  cmp "$d/sums.erstlauf" "$d/SHA256SUMS"
  run bash "$REPO/harness/tools/release-sums.sh" verify "$d"
  [ "$status" -eq 0 ]
  rm -rf "$d"
}

@test "release-host: das Binary des Host-Baus traegt TRAEGER_VERSION als Fassung (ADR-0063 Festlegung 1)" {
  local d
  d="$(mktemp -d)"
  run make -C "$REPO" release-artifacts-host DEST="$d" RELEASE_PLATFORMS=linux/amd64 TRAEGER_VERSION=v0.0.0-injektionsprobe
  [ "$status" -eq 0 ]
  [ -s "$d/ai-harness-init-linux-amd64" ]
  run "$d/ai-harness-init-linux-amd64" --version
  [ "$status" -eq 0 ]
  grep -qF 'v0.0.0-injektionsprobe' <<<"$output"
  rm -rf "$d"
}

# Der Formel-Teillauf (ein Plattform-Lauf mit gesetzter Fassung, aber ohne die
# vier brew-Plattformen in der SHA256SUMS) meldet den Formel-Entfall statt den
# Lauf zu brechen (Plan §3-Nachtrag, je Review F-5: die Meldung selbst ist die
# Zusage, nicht nur der Status-0-Ende).
@test "release-host: der Formel-Teillauf meldet den Formel-Entfall im DEST" {
  local d
  d="$(mktemp -d)"
  run make -C "$REPO" release-artifacts-host DEST="$d" RELEASE_PLATFORMS=linux/amd64 TRAEGER_VERSION=v0.0.0-bautest
  [ "$status" -eq 0 ]
  printf '%s' "$output" | grep -qF 'Teillauf ohne die vier brew-Plattformen'
  printf '%s' "$output" | grep -qF 'die Formel entfaellt im DEST'
  [ ! -e "$d/ai-harness-init.rb" ]
  rm -rf "$d"
}

# ADR-0063 Festlegung 2 am realen Bau: ohne uebergebenen Fassungs-Wert injiziert
# das Rezept nicht — der Skelett-Kommentar nennt den Tag, darum entsteht ohne Tag
# auch keine Formel im DEST.
@test "release-host: ohne TRAEGER_VERSION meldet --version den Fehlt-Fall laut und es entsteht keine Formel (ADR-0063 Festlegung 2)" {
  local d
  d="$(mktemp -d)"
  run make -C "$REPO" release-artifacts-host DEST="$d" RELEASE_PLATFORMS=linux/amd64
  [ "$status" -eq 0 ]
  [ -s "$d/ai-harness-init-linux-amd64" ]
  [ ! -e "$d/ai-harness-init.rb" ]
  [ "$(wc -l <"$d/SHA256SUMS")" -eq 1 ]
  run "$d/ai-harness-init-linux-amd64" --version
  [ "$status" -eq 2 ]
  grep -qF 'keine Fassung injiziert' <<<"$output"
  rm -rf "$d"
}

# Ein Binary fehlt im Zielverzeichnis — die reisende SUMS haelt fail-closed BEVOR
# etwas publiziert wird (ADR-0059 Festlegung 1): dieselbe Haltung, die der
# publish-Job in release.yml vor dem Upload faehrt.
@test "release-host: ein Binary fehlt im Zielverzeichnis — die reisende SUMS haelt fail-closed (ADR-0059 Festlegung 1)" {
  local d
  d="$(mktemp -d)"
  run make -C "$REPO" release-artifacts-host DEST="$d" RELEASE_PLATFORMS="linux/amd64 darwin/arm64" TRAEGER_VERSION=v0.0.0-bautest
  [ "$status" -eq 0 ]
  [ "$(wc -l <"$d/SHA256SUMS")" -eq 2 ]
  rm "$d/ai-harness-init-darwin-arm64"
  run bash "$REPO/harness/tools/release-sums.sh" verify "$d"
  [ "$status" -ne 0 ]
  printf '%s' "$output" | grep -qF 'Menge der Eintraege'
  rm -rf "$d"
}

# Die Ziel-Menge im DEST soll die Tafel DES LAUFS tragen — ein Teillauf ueber einem
# vollen (oder sonst fremd gefuellten) Zielverzeichnis wuerde still einen
# Zwischen-Matrix-Stand als OK melden, darum faellt er an dieser Zeile (LH-QA-04).
@test "release-host: ein Teillauf ueber einem gefuellten Zielverzeichnis faellt an der Ziel-Menge" {
  local d
  d="$(mktemp -d)"
  run make -C "$REPO" release-artifacts-host DEST="$d" RELEASE_PLATFORMS=linux/amd64
  [ "$status" -eq 0 ]
  [ -s "$d/ai-harness-init-linux-amd64" ]
  run make -C "$REPO" release-artifacts-host DEST="$d" RELEASE_PLATFORMS=linux/arm64
  [ "$status" -ne 0 ]
  printf '%s' "$output" | grep -qF 'Menge der Binaries ist nicht die Menge der Matrix'
  rm -rf "$d"
}

# Grenze der Koppel-Stelle: das Rezept liest die Plattformen aus genau EINER
# Tafel — dieselbe, deren Sechs-Satz von LH-QA-04 test/release-matrix.bats haelt.
# Faellt das Rezept auf eine eingebettete Liste zurueck, sind zwei Plattform-Quellen
# da, und der Matrix-Waechter haelt nur noch eine davon.
@test "release-host: das Rezept liest die Plattformen aus derselben Tafel, die release-matrix.bats haelt" {
  local rezept
  rezept="$(sed -n '/^release-artifacts-host:/,/^$/p' "$MK")"
  [ -n "$rezept" ]
  printf '%s' "$rezept" | grep -qF 'for p in $(RELEASE_PLATFORMS)'
  printf '%s' "$rezept" | grep -qF 'CGO_ENABLED=0'
  printf '%s' "$rezept" | grep -qF -- '-trimpath'
  printf '%s' "$rezept" | grep -qF -- '-X main.fassung=$(TRAEGER_VERSION)'
  printf '%s' "$rezept" | grep -qF 'release-sums.sh generate "$(DEST)"'
}

# MR-014 Setzung 1 in der Release-Fassung (ADR-0115 Festlegung 6b): die YAML traegt
# keine zweite Bau-Definition — der artifacts-Job ruft das Host-Target, und kein
# Nicht-Kommentar nennt Docker oder einen Inline-Compile.
@test "release-host: der artifacts-Job ruft das Host-Target — kein Docker-Zug, kein Inline-Compile in der YAML (MR-014 Setzung 1)" {
  grep -qF 'make release-artifacts-host' "$WF"
  local koerper treffer
  koerper="$(sed 's/#.*$//' "$WF")"
  treffer="$(printf '%s' "$koerper" | grep -inE 'docker|go build|go install' || true)"
  if [ -n "$treffer" ]; then
    echo "die Workflow-Mechanik nennt Docker oder Inline-Compile (MR-014 Setzung 1): $treffer" >&2
    return 1
  fi
}
