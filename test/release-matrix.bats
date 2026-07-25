#!/usr/bin/env bats
# release-matrix.bats — Waechter fuer die Release-Artefakte (slice-048, LH-QA-04).
#
# Warum hier und nicht als Lauf: die Matrix real zu bauen kostet sechs
# Docker-Builds; der bats-Container traegt weder Docker noch make. Geprueft wird
# darum die KOPPLUNG — dieselbe Linie wie test/sources-pin.bats, das die zwei
# Baseline-Pins fail-closed aneinander bindet. Der reale Bau ist Sache des
# Release-Laufs und der Pre-completion-Messung, nicht dieses Gates.
#
# Die vier Zusagen, die hier haengen:
#   1. Die Plattform-Liste im Makefile deckt GENAU die Matrix des Lastenhefts.
#   2. Windows-Artefakte tragen .exe (sonst laesst sich das Binary dort nicht
#      ohne Umbenennen starten).
#   3. Die build-Stage nimmt eine Zielplattform ENTGEGEN ...
#   4. ... und der Default-Pfad (`make build`) reicht KEINE durch — nur so bleibt
#      das bestehende Artefakt byte-identisch, woran artifact/smoke/full-smoke
#      haengen.

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  MK="$REPO/Makefile"
  DF="$REPO/Dockerfile"
  LH="$REPO/spec/lastenheft.md"
}

# Die Anforderung ist die Quelle, nicht eine zweite Liste im Test: Betriebssysteme
# und Architekturen werden aus der LH-QA-04-Anforderungszeile gelesen. Faellt dort
# eine Plattform weg oder kommt eine hinzu, ohne dass das Makefile mitzieht, ist
# das ein Befund — in beide Richtungen.
lh_platforms() {
  local zeile
  # Der Anforderungssatz laeuft ueber ZWEI Zeilen (Betriebssysteme, dann
  # Architekturen) — beide einsammeln und zu einer Zeichenkette verbinden, sonst
  # sucht die Arch-Pruefung im halben Satz.
  zeile="$(grep -A4 'LH-QA-04 — Plattform-Matrix' "$LH" | tr '\n' ' ')"
  local os arch
  for os in linux macos windows; do
    case "$zeile" in *"$os"*) ;; *) return 1 ;; esac
  done
  for arch in amd64 arm64; do
    case "$zeile" in *"$arch"*) ;; *) return 1 ;; esac
  done
  # macos heisst in der Toolchain darwin — die Uebersetzung ist der einzige Punkt,
  # an dem Anforderung und Bau-Vokabular auseinandergehen.
  printf '%s\n' linux/amd64 linux/arm64 darwin/amd64 darwin/arm64 windows/amd64 windows/arm64
}

mk_platforms() {
  sed -n 's/^RELEASE_PLATFORMS ?= //p' "$MK" | tr ' ' '\n' | sed '/^$/d'
}

@test "release: die Plattform-Liste deckt GENAU die Matrix des Lastenhefts" {
  local erwartet ist
  erwartet="$(lh_platforms | sort)"
  [ -n "$erwartet" ]
  ist="$(mk_platforms | sort)"
  [ "$ist" = "$erwartet" ]
}

@test "release: die Matrix traegt sechs Kombinationen" {
  [ "$(mk_platforms | wc -l)" -eq 6 ]
}

# Ohne .exe waere das Windows-Artefakt dort nicht startbar, ohne dass es beim Bau
# auffiele — ein Fehler, der erst beim Anwender sichtbar wuerde.
@test "release: Windows-Artefakte tragen .exe" {
  grep -q 'ext=".exe"' "$MK"
  grep -q '\[ "\$\$os" = "windows" \]' "$MK"
}

@test "release: die build-Stage nimmt eine Zielplattform entgegen" {
  grep -q '^ARG TARGET_OS' "$DF"
  grep -q '^ARG TARGET_ARCH' "$DF"
  grep -q 'GOOS=\${TARGET_OS} GOARCH=\${TARGET_ARCH}' "$DF"
}

# Der Kern der Byte-Identitaet: `make build` (und damit artifact, smoke,
# full-smoke) darf KEINE Zielplattform durchreichen. Leer gelassen baut die
# Toolchain fuer die Plattform des Build-Images — genau wie vor slice-048.
@test "release: der Default-Pfad reicht KEINE Zielplattform durch" {
  local rezept
  rezept="$(sed -n '/^build:/,/^$/p' "$MK")"
  [ -n "$rezept" ]
  # NICHT `! cmd` fuer eine Assertion, die nicht die letzte ist: `set -e` greift bei
  # einem mit `!` negierten Kommando NICHT, der Fehlschlag wird also verschluckt und
  # das Ergebnis haengt allein an der letzten Zeile. Real gemessen — Mutation 80 setzt
  # nur TARGET_OS ein und lief dadurch gruen durch. Explizites return statt Negation.
  if printf '%s' "$rezept" | grep -q 'TARGET_OS'; then
    echo "build-Recipe reicht TARGET_OS durch: $rezept" >&2
    return 1
  fi
  if printf '%s' "$rezept" | grep -q 'TARGET_ARCH'; then
    echo "build-Recipe reicht TARGET_ARCH durch: $rezept" >&2
    return 1
  fi
}

# DEST ist Pflicht: ohne Zielverzeichnis liefe das Recipe ins Leere bzw. schriebe
# an einen unbeabsichtigten Ort. Exit 2 = Aufruf-Fehler, wie beim bestehenden
# artifact-Target.
@test "release: DEST ist Pflicht (Exit 2 ohne)" {
  local rezept
  rezept="$(sed -n '/^release-artifacts:/,/^$/p' "$MK")"
  [ -n "$rezept" ]
  printf '%s' "$rezept" | grep -q 'test -n "\$(DEST)"'
  printf '%s' "$rezept" | grep -q 'exit 2'
}
