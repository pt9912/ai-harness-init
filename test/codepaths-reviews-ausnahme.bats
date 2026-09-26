#!/usr/bin/env bats
# codepaths-reviews-ausnahme.bats — koppelt die Form-Regel des Verweis-Nachzugs an eine Zeile der
# .d-check.yml (ADR-0070). Der Nachzug schreibt unter docs/reviews/** nur die Adresse hinter `](`
# um, nie einen Pfad im reinen Code-Span; das ist tragfaehig, solange `codepaths` in diesem Baum
# keinen Code-Span-Pfad prueft, und das haelt die Zeile `exempt-paths: ["docs/reviews/**"]` im
# Block `codepaths:` (ADR-0042). Faellt sie, prueft das Doku-Gate jeden Pfad-Span in den Reports,
# und die Form-Regel ist nach dem Re-Evaluierungs-Trigger 1 der ADR zu streichen.
#
# Gehalten wird die ZEILE, nicht die Wahrheit der Gate-Begruendung: ob `codepaths` einen Pfad-Span
# in einem Report tatsaechlich nicht prueft, ist ein Lauf des Doku-Gates und hier nicht Gegenstand.
# Gehalten wird ebenso die BEDINGUNG, nicht die Implikation Regel => Zeile: der Fall faerbt rot,
# sobald die Zeile fehlt, gleichgueltig ob die Traeger die Regel noch fuehren.
#
# Andere Bloecke der Datei tragen `docs/reviews/**` in eigenen `exempt-paths`-Zeilen, und die
# Kommentarzeilen im Block `codepaths:` nennen beide Woerter ebenfalls; gebunden ist allein eine
# Nicht-Kommentar-Zeile unter `codepaths:`. Den Blockanfang deckt
# test/mutations/474-codepaths-reviews-ausnahme-entfaellt.sh, das Blockende
# test/mutations/475-codepaths-reviews-ausnahme-wandert-in-einen-nachbar-block.sh.
#
# Grenze der Form: gehalten wird die einzeilige Flow-Liste mit doppelten Anfuehrungszeichen, wie
# die Datei sie fuehrt. Dieselbe Ausnahme als Block-Liste, als mehrzeilige Liste, mit einfachen
# Anfuehrungszeichen oder ohne Anfuehrungszeichen ist aequivalentes YAML und faerbt den Fall rot;
# die Meldung sagt dann, die Zeile im Test mitzuziehen.
#
# NETZLOS (nur Datei-Lesen), laeuft in `make gates` ueber `make test` -> `test-bats`.

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  YML="$REPO/.d-check.yml"
}

# block gibt die Nicht-Kommentar-Zeilen des TOP-LEVEL-codepaths:-Blocks aus (Schluessel in Spalte
# 0, Ende beim naechsten Top-Level-Schluessel). Kommentarzeilen fallen VOR der Block-Erkennung
# heraus: ein Kommentar in Spalte 0 beendet den Block nicht. Dass eine Kommentarzeile mit dem
# Zielwert keine Zeile vortaeuscht, haelt das Muster der Zusicherung (Zeile beginnt mit
# Einrueckung und `exempt-paths:`), nicht dieser Filter; fuer den Filter besteht kein Fall.
block() {
  awk '
    /^[[:space:]]*#/                  { next }
    /^codepaths:[[:space:]]*(#.*)?$/  { inblk = 1; next }
    inblk && /^[^[:space:]]/          { inblk = 0 }
    inblk                             { print }
  ' "$YML"
}

@test "codepaths fuehrt die Zeile exempt-paths mit docs/reviews/** — die Bedingung der Form-Regel des Nachzugs (ADR-0070)" {
  local zeile='^[[:space:]]+exempt-paths:[[:space:]]*\[[^]#]*"docs/reviews/\*\*"'
  if ! block | grep -Eq "$zeile"; then
    echo "Im Block codepaths: der .d-check.yml steht die Zeile exempt-paths: [\"docs/reviews/**\"]" >&2
    echo "(einzeilige Liste, doppelte Anfuehrungszeichen) nicht. Die Form-Regel des Verweis-Nachzugs" >&2
    echo "(ADR-0070) setzt die Ausnahme voraus: ohne sie prueft codepaths jeden Pfad-Span in" >&2
    echo "docs/reviews/**. Fehlt die Ausnahme, ist das Re-Evaluierungs-Trigger 1 der ADR — die Regel" >&2
    echo "ist zu streichen (Folge-ADR), die Zeile nicht still zu entfernen. Steht sie in anderer" >&2
    echo "Schreibform, ist die Zeile in diesem Test mitzuziehen." >&2
    return 1
  fi
}
