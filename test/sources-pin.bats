#!/usr/bin/env bats
# sources-pin.bats — koppelt den d-check `sources`-Pin in .d-check.yml an den
# KANONISCHEN Baseline-Pin im Makefile (BASELINE_ZIP_SHA256 / BASELINE_TAG,
# MR-007 / MR-013). `sources` (Modul `make regelwerk-check`) prueft das
# Baseline-Asset gegen den in .d-check.yml gepinnten sha256; das Makefile fuehrt
# denselben Hash als Provenienz-Anker. OHNE diese Kopplung driftet der
# .d-check.yml-Pin bei einer Re-Baseline still vom Makefile weg — `regelwerk-check`
# prueft dann gegen den falschen Hash (falscher Drift oder falsches Gruen).
# NETZLOS (nur Datei-Vergleich), laeuft in `make gates`. Docker-only (bats-Image).

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  MK="$REPO/Makefile"
  YML="$REPO/.d-check.yml"
}

@test "sources-sha256 in .d-check.yml == Makefile BASELINE_ZIP_SHA256 (Kopplung, MR-013)" {
  mk_sha="$(grep '^BASELINE_ZIP_SHA256' "$MK" | head -1 | sed 's/.*=[ ]*//')"
  yml_sha="$(grep 'sha256:' "$YML" | head -1 | sed 's/.*sha256:[ ]*//')"
  [ -n "$mk_sha" ]
  [ -n "$yml_sha" ]
  [ "$yml_sha" = "$mk_sha" ]
}

@test "sources-url in .d-check.yml traegt den aktuellen BASELINE_TAG (Kopplung, MR-013)" {
  mk_tag="$(grep '^BASELINE_TAG' "$MK" | head -1 | sed 's/.*=[ ]*//')"
  [ -n "$mk_tag" ]
  grep 'url:' "$YML" | grep -q "/$mk_tag/"
}
