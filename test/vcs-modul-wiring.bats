#!/usr/bin/env bats
# vcs-modul-wiring.bats — haelt das d-check-Modul `vcs` (DC-FA-VCS-001, AGENTS.md 3.4) auf den
# Bestand dieses Repos gebunden, ohne einen Docker-Lauf. `vcs` steht NICHT in `modules:` (es
# braucht eine Commit-Range; ein hermetischer docs-check-Lauf ohne Range liefe damit ins Leere,
# LH-QA-01) und wird nur ueber `make adr-immutable`/`make doc-immutable` aktiviert. Zwei Felder
# sind gegen den gelebten Bestand gesetzt, nicht gegen den Werkzeug-Vorschlag:
# `exclude-sections` nimmt `Geschichte` aus dem Kern — ohne sie faengt `immutable-when` die
# Kopfzeile nicht, sondern jede Fortschreibung faerbt rot, weil jede ADR dieses Repos mit
# `## Geschichte` endet. `head-allow` traegt die im Bestand gelebte Link-Form des
# Supersede-Uebergangs (`Superseded by [ADR-NNNN](...)`) statt der vom Werkzeug
# vorgeschlagenen baren Kennung — Letztere faerbt den erlaubten Uebergang faelschlich rot
# (gemessen in einem Wegwerf-Klon, harness/README.md traegt das Ergebnis). Dieser Waechter
# haelt nur die KONFIGURATION gegen Regression, nicht das Verhalten des vendored Werkzeugs.
#
# NETZLOS (nur Datei-Lesen), laeuft in `make gates` ueber `make test` -> `test-bats`.

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  YML="$REPO/.d-check.yml"
}

# block gibt die Zeilen des TOP-LEVEL-vcs:-Blocks aus (Schluessel in Spalte 0) — dieselbe
# Extraktions-Form wie in test/planning-modul-wiring.bats.
block() {
  awk '
    /^vcs:[[:space:]]*$/     { inblk = 1; next }
    inblk && /^[^[:space:]]/ { inblk = 0 }
    inblk                    { print }
  ' "$YML"
}

@test "vcs ist NICHT in modules: aktiviert (braucht eine Range, LH-QA-01)" {
  ! grep -E '^modules:.*\bvcs\b' "$YML"
}

@test "vcs: schuetzt genau die ADR-Datei-Klasse" {
  block | grep -qxF '  paths: ["docs/plan/adr/[0-9]*.md"]'
}

@test "vcs: immutable-when trifft die Accepted-Kopfzeile" {
  block | grep -qxF "  immutable-when: '^\\*\\*Status:\\*\\* Accepted'"
}

@test "vcs: exclude-sections nimmt Geschichte aus dem Kern" {
  block | grep -qxF '  exclude-sections: [Geschichte]'
}

@test "vcs: head-allow traegt die gelebte Link-Form, nicht die bare Werkzeug-Vorgabe" {
  block | grep -qxF "  head-allow: '^\\*\\*Status:\\*\\* (Accepted|Superseded by \\[ADR-[0-9]{4}\\])'"
}

@test "vcs: genau eine head-allow-Zeile (kein stilles YAML-Duplikat)" {
  local n
  n="$(block | grep -cE '^[[:space:]]+head-allow:')"
  [ "$n" -eq 1 ]
}
