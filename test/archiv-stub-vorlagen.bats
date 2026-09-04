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
# JE VORLAGE EINZELN, nicht ueber ihrer Vereinigung. Es gibt zwei Bloecke und
# zwei Vorlagen, und der Block fuellt GENAU EINE davon: `sliceStub` die
# Slice-Vorlage, `welleStub` die Welle-Vorlage. Ein Platzhalter, den beide
# Bloecke ersetzen, steht auch in beiden Vorlagen — eine Umbenennung in genau
# einer bliebe unter einer Vereinigungs-Frage gruen, waehrend der Lauf dort einen
# Stub mit stehengebliebenem Platzhalter schriebe. Die Zuordnung Block -> Datei
# kommt aus den Konstanten, die der Code selbst benutzt, nicht aus einer zweiten
# Liste hier.
#
# GRENZE, benannt statt verschwiegen: geprueft wird die Richtung
# Code -> Vorlage. Ein Platzhalter, den die Vorlage traegt und der Code nicht
# ersetzt, faellt hier nicht auf; er faellt im Stub auf, wo er stehen bleibt.
# NETZLOS (nur Datei-Vergleich), laeuft in `make gates`. Docker-only (bats-Image).

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  QUELLE="$REPO/internal/archive/anwenden.go"
  KONST="$REPO/internal/archive/collect.go"
  VORLAGEN_KONST="$REPO/internal/archive/stub.go"
  TDIR="$(echo "$REPO"/.harness/baseline/*/templates/docs/plan/planning)"
  # Die zwei Bloecke, benannt ueber die Konstante, mit der der Code seine Vorlage
  # waehlt — dieselbe Zeichenkette traegt den Block-Anfang und die Aufloesung des
  # Dateinamens. Wer eine dritte Stub-Art baut, ohne sie hier zu ergaenzen, faellt
  # am Deckungs-Fall unten auf.
  BLOECKE="stubVorlageSlice stubVorlageWelle"
}

# ersetzungs_zeilen <konstante> liefert die Ersetzungs-Literale GENAU DES Blocks,
# der die mit dieser Konstante benannte Vorlage fuellt — die Bezugsmenge, ueber
# die die Faelle unten quantifizieren. Sie ist die Zeilen-Menge dieses Blocks,
# nicht eine Auswahl daraus und nicht die Vereinigung beider.
ersetzungs_zeilen() {
  sed -n "/$1), \[\]Ersetzung{\$/,/^\t})\$/p" "$QUELLE" | grep -E '^[[:space:]]+\{'
}

# vorlage_datei <konstante> loest den Dateinamen auf, den der Code unter dieser
# Konstante fuehrt. Ohne diese Aufloesung stuende die Zuordnung Block -> Datei
# hier ein zweites Mal und koennte gegen den Code driften.
vorlage_datei() {
  sed -n "s/^[[:space:]]*$1[[:space:]]*= \"\(.*\)\"\$/\1/p" "$VORLAGEN_KONST"
}

# platzhalter <konstante> loest jedes Literal des Blocks in seinen ERSTEN
# Ausdruck auf — den Platzhalter. Zwei Formen kommen vor, und beide werden
# getroffen:
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
  done < <(ersetzungs_zeilen "$1")
}

@test "beide Stub-Vorlagen liegen im vendored Baum" {
  [ -f "$TDIR/archiv-stub-slice.template.md" ]
  [ -f "$TDIR/archiv-stub-welle.template.md" ]
}

# Die Deckungs-Aussage des Falls darunter, jetzt je Block: die Extraktion loest
# JEDES Ersetzungs-Literal auf, nicht eine Teilmenge — und der Block ist nicht
# leer. Beides ist noetig: ein sed-Bereich, der ins Leere liefe, machte den
# Vorlagen-Fall unten zu einer Quantifizierung ueber die leere Menge, und die ist
# immer wahr.
@test "die Extraktion loest jedes Ersetzungs-Literal beider Bloecke auf" {
  for k in $BLOECKE; do
    zeilen="$(ersetzungs_zeilen "$k" | grep -c . || true)"
    [ "$zeilen" -ge 5 ] || {
      echo "Block '$k': nur $zeilen Ersetzungs-Literale gefunden — der Bereich greift nicht" >&2
      false
    }
    aufgeloest="$(platzhalter "$k" | grep -c . || true)"
    [ "$aufgeloest" -eq "$zeilen" ] || {
      echo "Block '$k': $aufgeloest von $zeilen Ersetzungs-Literalen aufgeloest" >&2
      false
    }
  done
}

@test "jeder Platzhalter steht in genau der Vorlage, die sein Block fuellt" {
  fehlend=""
  for k in $BLOECKE; do
    datei="$(vorlage_datei "$k")"
    [ -n "$datei" ] || {
      echo "Konstante '$k' ist in ${VORLAGEN_KONST##*/} nicht aufloesbar" >&2
      false
    }
    [ -f "$TDIR/$datei" ] || {
      echo "Vorlage '$datei' (aus '$k') liegt nicht unter $TDIR" >&2
      false
    }
    while IFS= read -r p; do
      [ -n "$p" ] || continue
      grep -qF -- "$p" "$TDIR/$datei" || fehlend="$fehlend
  $datei: $p"
    done < <(platzhalter "$k" | sort -u)
  done
  [ -z "$fehlend" ] || {
    echo "Platzhalter ohne Entsprechung in der Vorlage, die ihr Block fuellt:$fehlend" >&2
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
