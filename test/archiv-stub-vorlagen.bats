#!/usr/bin/env bats
# archiv-stub-vorlagen.bats — koppelt die Stub-Erzeugung des Traegers an die
# ECHTEN vendored Vorlagen (ADR-0033 Festlegung 3).
#
# WARUM HIER UND NICHT IN GO. `.dockerignore` haelt `.harness` aus dem
# Build-Kontext der Go-Test-Stufe; die Go-Tests von internal/archive fahren
# darum ueber synthetischen Vorlagen. Das bats-Bild bekommt den Baum
# read-only gemountet und sieht die echten. Ohne diese Datei kaeme eine
# Form-Aenderung der Baseline erst beim naechsten Archivierungslauf ans Licht —
# als Stub mit einem stehengebliebenen Platzhalter.
#
# GRENZE, benannt statt verschwiegen: geprueft wird die Richtung
# Code -> Vorlage. Ein Platzhalter, den die Vorlage traegt und der Code nicht
# ersetzt, faellt hier nicht auf; er faellt im Stub auf, wo er stehen bleibt.
# NETZLOS (nur Datei-Vergleich), laeuft in `make gates`. Docker-only (bats-Image).

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  QUELLE="$REPO/internal/archive/anwenden.go"
  TDIR="$(echo "$REPO"/.harness/baseline/*/templates/docs/plan/planning)"
}

# Die Platzhalter kommen aus der Go-Quelle selbst, nicht aus einer zweiten
# Liste: `{"<…>",` ist die Form, in der sliceStub und welleStub sie fuehren.
platzhalter() {
  grep -oE '\{"<[^"]+>"' "$QUELLE" | sed -e 's/^{"//' -e 's/"$//' | sort -u
}

@test "beide Stub-Vorlagen liegen im vendored Baum" {
  [ -f "$TDIR/archiv-stub-slice.template.md" ]
  [ -f "$TDIR/archiv-stub-welle.template.md" ]
}

@test "die Go-Quelle fuehrt ueberhaupt Platzhalter (sonst prueft der Fall darunter nichts)" {
  n="$(platzhalter | grep -c . || true)"
  [ "$n" -ge 5 ]
}

@test "jeder Platzhalter der Stub-Erzeugung steht in einer der zwei Vorlagen" {
  fehlend=""
  while IFS= read -r p; do
    [ -n "$p" ] || continue
    if ! grep -qF -- "$p" "$TDIR/archiv-stub-slice.template.md" \
      && ! grep -qF -- "$p" "$TDIR/archiv-stub-welle.template.md"; then
      fehlend="$fehlend $p"
    fi
  done < <(platzhalter)
  [ -z "$fehlend" ] || {
    echo "Platzhalter ohne Entsprechung in den Vorlagen:$fehlend" >&2
    false
  }
}

# Die drei Teile, aus denen die Kuerzung (internal/archive/stub.go, Kuerze) den
# Stub baut: H1 in Zeile 1, der Archiv-Zeiger-Block, der Feld-Block als LETZTER
# Absatz. Faellt einer weg, schreibt der Lauf einen Stub ohne Zeiger oder ohne
# Felder — und FormOK meldet nur den fehlenden Zeiger, nicht die leeren Felder.
@test "beide Vorlagen tragen H1, Archiv-Zeiger und einen Feld-Block als letzten Absatz" {
  for f in "$TDIR/archiv-stub-slice.template.md" "$TDIR/archiv-stub-welle.template.md"; do
    head -n 1 "$f" | grep -q '^# '
    grep -q '^> \*\*ARCHIVIERT\*\*' "$f"
    grep -q 'archiv\.zip' "$f"
    tail -n 1 "$f" | grep -q '^\*\*'
  done
}
