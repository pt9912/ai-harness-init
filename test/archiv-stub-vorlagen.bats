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
  KONST="$REPO/internal/archive/collect.go"
  TDIR="$(echo "$REPO"/.harness/baseline/*/templates/docs/plan/planning)"
}

# ersetzungs_zeilen liefert JEDES Ersetzungs-Literal aus den []Ersetzung-Bloecken
# von sliceStub und welleStub — die Bezugsmenge, ueber die der Fall unten
# quantifiziert. Sie ist die Zeilen-Menge, nicht eine Auswahl daraus.
ersetzungs_zeilen() {
  sed -n '/\[\]Ersetzung{$/,/^\t})$/p' "$QUELLE" | grep -E '^[[:space:]]+\{'
}

# platzhalter loest jedes dieser Literale in seinen ERSTEN Ausdruck auf — den
# Platzhalter. Zwei Formen kommen vor, und beide werden getroffen:
#
#   {"<NNN>", nummer},                        -> der Zeichenketten-Literal
#   {"done/<welle-id>/" + archivName, zipRel} -> Literal + Konstante, aufgeloest
#
# ZUSAGE: eine Zeile, die keine der zwei Formen trifft, laesst die Funktion
# FALLEN statt sie zu ueberspringen. Ein Extraktions-Muster, das enger ist als
# die Menge, ueber die der Test-Name quantifiziert, ist ein Waechter, der
# schweigt — die Platzhalter, die dabei durchfallen, sind gerade die
# zusammengesetzten und die, deren Text nicht auf `>` endet.
platzhalter() {
  local zeile rest kopf nach konst wert
  while IFS= read -r zeile; do
    # Alles ab `{"`, dann der Literal-Text bis zum SCHLIESSENDEN Anfuehrungszeichen.
    # Was danach kommt, entscheidet die Form — nicht ein Muster ueber der ganzen
    # Zeile: der Wert-Ausdruck traegt selbst Anfuehrungszeichen und Pluszeichen.
    rest="${zeile#*\{\"}"
    kopf="${rest%%\"*}"
    nach="${rest#"$kopf"\"}"
    case "$nach" in
      ", "*)
        printf '%s\n' "$kopf" ;;
      " + "*)
        konst="${nach# + }"; konst="${konst%%,*}"
        case "$konst" in
          *[!A-Za-z0-9_]*|"")
            echo "kein einfacher Konstanten-Name: '$konst' in: $zeile" >&2
            return 1 ;;
        esac
        wert="$(sed -n "s/^[[:space:]]*$konst[[:space:]]*= \"\(.*\)\"\$/\1/p" "$KONST")"
        if [ -z "$wert" ]; then
          echo "Konstante '$konst' nicht in ${KONST##*/} aufloesbar: $zeile" >&2
          return 1
        fi
        printf '%s%s\n' "$kopf" "$wert" ;;
      *)
        echo "unbekannte Ersetzungs-Form, nicht aufloesbar: $zeile" >&2
        return 1 ;;
    esac
  done < <(ersetzungs_zeilen)
}

@test "beide Stub-Vorlagen liegen im vendored Baum" {
  [ -f "$TDIR/archiv-stub-slice.template.md" ]
  [ -f "$TDIR/archiv-stub-welle.template.md" ]
}

# Die Deckungs-Aussage des Falls darunter: die Extraktion loest JEDES
# Ersetzungs-Literal auf, nicht eine Teilmenge. Ohne diesen Vergleich kann das
# Muster still enger werden als die Quelle, und „jeder Platzhalter" waere dann
# eine Quantifizierung ueber eine Menge, die der Test gar nicht sieht.
@test "die Extraktion loest jedes Ersetzungs-Literal der Go-Quelle auf" {
  zeilen="$(ersetzungs_zeilen | grep -c . || true)"
  [ "$zeilen" -ge 5 ]
  aufgeloest="$(platzhalter | grep -c . || true)"
  [ "$aufgeloest" -eq "$zeilen" ] || {
    echo "$aufgeloest von $zeilen Ersetzungs-Literalen aufgeloest" >&2
    false
  }
}

@test "jeder Platzhalter der Stub-Erzeugung steht in einer der zwei Vorlagen" {
  fehlend=""
  while IFS= read -r p; do
    [ -n "$p" ] || continue
    if ! grep -qF -- "$p" "$TDIR/archiv-stub-slice.template.md" \
      && ! grep -qF -- "$p" "$TDIR/archiv-stub-welle.template.md"; then
      fehlend="$fehlend|$p"
    fi
  done < <(platzhalter | sort -u)
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
