#!/usr/bin/env bats
# emitted-baseline-verify.bats — Tests fuer das EMITTIERTE Verifikations-Skript
# (internal/emit/templates/baseline-verify.sh), das der Bootstrap ins Zielrepo
# nach tools/harness/ legt (slice-022a, LH-FA-09).
#
# Warum eine eigene Suite neben baseline-verify.bats: jene testet den DOGFOOD-
# Zwilling (harness/tools/). Das Emittat war bis zum Review nur per
# strings.Contains gegrept — und genau darum passierte H1 (eingelegter Symlink →
# "OK") die Suite unbemerkt. Ein Test, der das Skript AUSFUEHRT, haette den
# Befund sofort geliefert; das holt diese Datei nach.
#
# Der Ziel-Layout-Bezug ist Teil des Vertrags: aus tools/harness/ loest
# $here/../../.harness/baseline auf die Baseline des Zielrepos auf — genau
# dorthin schreibt cmd/ai-harness-init.

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  EMITTED="$REPO/internal/emit/templates/baseline-verify.sh"
  # Synthetisches ZIELrepo (nicht dieses Repo): tools/harness/ statt harness/tools/.
  TMP="$(mktemp -d)"
  BASE="$TMP/.harness/baseline/vTESTTAG-1a2b"
  mkdir -p "$TMP/tools/harness" "$BASE/regelwerk" "$BASE/templates"
  cp "$EMITTED" "$TMP/tools/harness/baseline-verify.sh"
  chmod +x "$TMP/tools/harness/baseline-verify.sh"
  printf '# Index\n' > "$BASE/regelwerk/README.md"
  printf '# Modul\n' > "$BASE/regelwerk/modul.md"
  printf '# Template\n' > "$BASE/templates/slice.template.md"
  # SHA256SUMS in exakt der Form, die writeSums erzeugt (GNU, pfad-sortiert,
  # relativ zu <tag>/, self-excluded).
  ( cd "$BASE" \
      && find . ! -type d -not -name SHA256SUMS | sed 's|^\./||' | LC_ALL=C sort \
         | xargs sha256sum > SHA256SUMS )
}

teardown() { rm -rf "$TMP"; }

run_verify() { run bash "$TMP/tools/harness/baseline-verify.sh"; }

@test "emittiert: unveraenderte Baseline -> gruen (exit 0)" {
  run_verify
  [ "$status" -eq 0 ]
  printf '%s' "$output" | grep -q 'OK'
}

@test "emittiert: GEAENDERTE Datei -> rot (Integritaets-Achse)" {
  echo "manipuliert" >> "$BASE/regelwerk/modul.md"
  run_verify
  [ "$status" -eq 1 ]
}

@test "emittiert: GELOESCHTE Datei -> rot (Integritaets-Achse)" {
  rm "$BASE/regelwerk/modul.md"
  run_verify
  [ "$status" -eq 1 ]
}

@test "emittiert: zusaetzlich eingelegte REGULAERE Datei -> rot (Vollstaendigkeit)" {
  printf 'fremd\n' > "$BASE/regelwerk/eingelegt.md"
  run_verify
  [ "$status" -eq 1 ]
}

# Der H1-Fall. Vor dem Fix meldete das Skript hier "OK - Integritaet +
# Vollstaendigkeit" mit exit 0, waehrend cat Fremdinhalt lieferte: sha256sum -c
# sieht den Symlink nicht (nicht gelistet) und `find -type f` fand ihn nie.
@test "emittiert: eingelegter SYMLINK -> rot (H1, stilles Gruen geschlossen)" {
  ln -s /etc/hostname "$BASE/regelwerk/modul-99.md"
  run_verify
  [ "$status" -eq 1 ]
}

@test "emittiert: Symlink, der eine GELISTETE Datei ersetzt -> rot" {
  rm "$BASE/regelwerk/modul.md"
  ln -s /etc/hostname "$BASE/regelwerk/modul.md"
  run_verify
  [ "$status" -eq 1 ]
}

@test "emittiert: fehlende SHA256SUMS -> rot mit Begruendung" {
  rm "$BASE/SHA256SUMS"
  run_verify
  [ "$status" -eq 1 ]
  printf '%s' "$output" | grep -q 'SHA256SUMS'
}

@test "emittiert: zwei <tag>-Verzeichnisse -> rot (ein Tag zur Zeit)" {
  mkdir -p "$TMP/.harness/baseline/vTESTTAG-2c3d"
  run_verify
  [ "$status" -eq 1 ]
}

@test "emittiert: keine Baseline -> rot (kaputter Checkout, kein fehlender Fetch)" {
  rm -rf "$TMP/.harness/baseline"
  mkdir -p "$TMP/.harness/baseline"
  run_verify
  [ "$status" -eq 1 ]
}

# Der Fall, fuer den die emittierte Suite bis zum Re-Review GAR KEINEN hatte
# (Befund N3): die Escape-Vorbedingung. GNU sha256sum escapt Pfade mit Backslash
# mit einem fuehrenden Backslash; der Vollstaendigkeits-Vergleich dekodiert das
# nicht und wuerde falsch-positiv melden. Das Skript muss LAUT abbrechen, bevor
# es irgendein Urteil faellt.
@test "emittiert: GNU-escapter Pfad in SHA256SUMS -> lauter Abbruch" {
  printf '\\%s  %s\n' "0000000000000000000000000000000000000000000000000000000000000000" 'weird\name' \
    >> "$BASE/SHA256SUMS"
  run_verify
  [ "$status" -eq 1 ]
  printf '%s' "$output" | grep -q 'escapte'
}

@test "emittiert: netzlos — kein curl/wget im Skript" {
  run grep -Eq 'curl|wget' "$TMP/tools/harness/baseline-verify.sh"
  [ "$status" -ne 0 ]
}
