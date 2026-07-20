#!/usr/bin/env bats
# baseline-verify.bats — Tests fuer den netzlosen Baseline-Verifier
# (harness/tools/baseline-verify.sh). Docker-only im gepinnten bats-Image
# (make test; slice-011 / MR-007 / LH-QA-01).
#
# Kern der Absicherung: der VOLLSTAENDIGKEITS-Check. sha256sum -c allein prueft
# nur Gelistetes und bleibt bei einer ZUSAETZLICH eingelegten Datei gruen — ein
# stilles Gruen. Diese Suite fixiert, dass baseline-verify beide
# Manipulations-Arten faengt, damit ein spaeterer Rueckbau auf reines
# sha256sum -c nicht unbemerkt durchrutscht (Review-Finding slice-011).

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  VERIFY="$REPO/harness/tools/baseline-verify.sh"
  # Synthetische Baseline in einem tmp-Repo — der echte Baum wird nie beruehrt.
  TMP="$(mktemp -d)"
  mkdir -p "$TMP/harness/tools" "$TMP/.harness/baseline/vTESTTAG-1a2b/regelwerk" \
    "$TMP/.harness/baseline/vTESTTAG-1a2b/templates"
  cp "$VERIFY" "$TMP/harness/tools/"
  printf '# Index\n' > "$TMP/.harness/baseline/vTESTTAG-1a2b/regelwerk/README.md"
  printf '# Modul\n' > "$TMP/.harness/baseline/vTESTTAG-1a2b/regelwerk/modul.md"
  printf '# Template\n' > "$TMP/.harness/baseline/vTESTTAG-1a2b/templates/slice.md"
  ( cd "$TMP/.harness/baseline/vTESTTAG-1a2b" \
      && find . -type f -not -name SHA256SUMS | sed 's|^\./||' | LC_ALL=C sort \
         | xargs sha256sum > SHA256SUMS )
}

teardown() { rm -rf "$TMP"; }

run_verify() { run bash "$TMP/harness/tools/baseline-verify.sh"; }

@test "verify: unveraenderte Baseline -> gruen (exit 0)" {
  run_verify
  [ "$status" -eq 0 ]
  printf '%s' "$output" | grep -q 'OK'
}

@test "verify: GEAENDERTE Datei -> rot (Integritaet)" {
  echo "manipuliert" >> "$TMP/.harness/baseline/vTESTTAG-1a2b/regelwerk/modul.md"
  run_verify
  [ "$status" -eq 1 ]
}

@test "verify: GELOESCHTE Datei -> rot" {
  rm "$TMP/.harness/baseline/vTESTTAG-1a2b/regelwerk/modul.md"
  run_verify
  [ "$status" -eq 1 ]
}

# Der Kern-Test: sha256sum -c allein bliebe hier GRUEN. Faengt nur der
# Vollstaendigkeits-Check.
@test "verify: ZUSAETZLICH eingelegte Datei -> rot (Vollstaendigkeit) — sha256sum -c waere blind" {
  echo "schmuggel" > "$TMP/.harness/baseline/vTESTTAG-1a2b/regelwerk/eingeschmuggelt.md"
  # Beleg, dass sha256sum -c allein die neue Datei NICHT sieht (kein --quiet;
  # busybox kennt es nicht — Output unterdruecken reicht):
  run bash -c "cd '$TMP/.harness/baseline/vTESTTAG-1a2b' && sha256sum -c SHA256SUMS >/dev/null 2>&1"
  [ "$status" -eq 0 ]
  # baseline-verify dagegen faengt sie:
  run_verify
  [ "$status" -eq 1 ]
  printf '%s' "$output" | grep -q 'eingeschmuggelt.md'
}

# Delete+Add bei gleicher Dateizahl: ein reiner Zaehl-Check wuerde durchrutschen.
@test "verify: Datei getauscht (delete+add, Zahl gleich) -> rot" {
  rm "$TMP/.harness/baseline/vTESTTAG-1a2b/regelwerk/modul.md"
  echo "ersatz" > "$TMP/.harness/baseline/vTESTTAG-1a2b/regelwerk/anderes.md"
  run_verify
  [ "$status" -eq 1 ]
}

@test "verify: fehlende SHA256SUMS -> rot (nicht verifizierbar)" {
  rm "$TMP/.harness/baseline/vTESTTAG-1a2b/SHA256SUMS"
  run_verify
  [ "$status" -eq 1 ]
}

@test "verify: keine Baseline -> rot (kaputter Checkout)" {
  rm -rf "$TMP/.harness/baseline/vTESTTAG-1a2b"
  run_verify
  [ "$status" -eq 1 ]
  # Die Meldung erklaert den Fall als kaputten Checkout (die Baseline ist
  # committet), nicht als fehlenden Fetch.
  printf '%s' "$output" | grep -q 'Checkout'
}

@test "verify: zwei <tag>-Verzeichnisse -> rot (Setzung: ein Tag zur Zeit)" {
  cp -r "$TMP/.harness/baseline/vTESTTAG-1a2b" "$TMP/.harness/baseline/vTESTTAG-alt"
  run_verify
  [ "$status" -eq 1 ]
  printf '%s' "$output" | grep -q 'ein Tag zur Zeit'
}

# GNU-escapte Pfade (Backslash im Namen): GNU sha256sum setzt einen fuehrenden
# Backslash an den ZEILENANFANG als Escape-Marker. Der Vollstaendigkeits-
# Vergleich dekodiert das nicht -> baseline-verify bricht LAUT ab (Format-
# Vorbedingung, vor jedem Urteil), statt falsch-positiv/still-gruen zu werden
# (Review-Finding slice-011).
@test "verify: GNU-escapter Pfad in SHA256SUMS (fuehrender Backslash) -> lauter Abbruch" {
  printf '\\%s  %s\n' "0000000000000000000000000000000000000000000000000000000000000000" 'weird\name' \
    >> "$TMP/.harness/baseline/vTESTTAG-1a2b/SHA256SUMS"
  run_verify
  [ "$status" -eq 1 ]
  printf '%s' "$output" | grep -q 'escapte'
}

# Eingelegter SYMLINK: bis slice-022a meldete auch dieser Verifier "OK" (exit 0),
# weil `find -type f` ihn nie fand und sha256sum -c ihn nicht listete — beide
# Achsen blind fuer dieselbe Manipulation. Der Befund kam aus dem Review des
# EMITTIERTEN Zwillings (H1) und traf diesen hier vorbestehend mit.
@test "verify: eingelegter SYMLINK -> rot (Vollstaendigkeit, H1 geschlossen)" {
  ln -s /etc/hostname "$TMP/.harness/baseline/vTESTTAG-1a2b/regelwerk/modul-99.md"
  run_verify
  [ "$status" -eq 1 ]
}
