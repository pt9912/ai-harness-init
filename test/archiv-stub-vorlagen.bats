#!/usr/bin/env bats
# archiv-stub-vorlagen.bats — koppelt die Stub-Erzeugung des Traegers an die
# ECHTEN Vorlagen (ADR-0033 Festlegung 3).
#
# WARUM HIER UND NICHT IN GO. `.dockerignore` haelt `.harness/baseline` aus dem
# Build-Kontext der Go-Test-Stufe; die Go-Tests von internal/archive fahren
# darum ueber synthetischen Vorlagen. Der bats-Host-Lauf sieht die echten
# (ADR-0109); ohne diese Datei kaeme eine Form-Aenderung der Baseline erst beim
# naechsten Archivierungslauf ans Licht — als Stub mit einem stehengebliebenen
# Platzhalter.
#
# JE VORLAGE EINZELN, nicht ueber ihrer Vereinigung. Es gibt vier Stub-Vorlagen
# und vier Bloecke, und der Block fuellt GENAU EINE davon: `sliceStub` die
# Slice-Vorlage, `welleStub` die Welle-Vorlage, `reportStub` den Report-Stub
# (ADR-0061), `umzugStub` die Umzugs-Stub-Vorlage (ADR-0112). Ein Platzhalter,
# den mehrere Bloecke ersetzen, steht auch in den zugehoerigen Vorlagen — eine
# Umbenennung in genau einer bliebe unter einer Vereinigungs-Frage gruen,
# waehrend der Lauf dort einen Stub mit stehengebliebenem Platzhalter schriebe.
# Die Zuordnung Block -> Datei kommt aus den Konstanten, die der Code selbst
# benutzt, nicht aus einer zweiten Liste hier.
#
# Die Umzugs-Vorlage traegt bewusst KEINEN Archiv-Zeiger: ihr Volltext liegt an
# der neuen Arbeitsbaum-Adresse, nicht im Archiv-Zip (ADR-0112 Festlegung 2).
# Darum tritt sie nicht in den Archiv-Zeiger-Test der drei ADR-0061-FASSUNGEN
# (ARCHIV_BLOECKE); ihr eigener Testsatz haelt Umzugs-Zeiger, die Abwesenheit
# des Archiv-Zeigers und die byte-gleiche mitgetragene Fassung fest.
#
# GRENZE, benannt statt verschwiegen: geprueft wird die Richtung
# Code -> Vorlage. Ein Platzhalter, den die Vorlage traegt und der Code nicht
# ersetzt, faellt hier nicht auf; er faellt im Stub auf, wo er stehen bleibt.
# NETZLOS (nur Datei-Vergleich), laeuft in `make gates`.

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  QUELLE="$REPO/internal/archive/anwenden.go"
  KONST="$REPO/internal/archive/collect.go"
  VORLAGEN_KONST="$REPO/internal/archive/stub.go"
  TDIR="$(echo "$REPO"/.harness/baseline/*/templates/docs/plan/planning)"
  PLANNING="$REPO/docs/plan/planning"
  # Die vier Bloecke, benannt ueber die Konstante, mit der der Code seine Vorlage
  # waehlt. Wer eine fuenfte Stub-Art baut, ohne sie hier zu ergaenzen, faellt
  # am Deckungs-Fall unten auf.
  BLOECKE="stubVorlageSlice stubVorlageWelle stubVorlageReport stubVorlageUmzug"
  # Die drei Klassen mit Archiv-Zeiger (ADR-0061-Fassungen); der Umzugs-Stub
  # traegt den Umzugs-Zeiger statt dessen und hat seinen eigenen Test.
  ARCHIV_BLOECKE="stubVorlageSlice stubVorlageWelle stubVorlageReport"
}

# ersetzungs_zeilen <konstante> liefert die Ersetzungs-Literale GENAU DES Blocks,
# der die mit dieser Konstante benannte Vorlage fuellt — die Bezugsmenge, ueber
# die die Faelle unten quantifizieren. Sie ist die Zeilen-Menge dieses Blocks,
# nicht eine Auswahl daraus und nicht die Vereinigung mehrerer. Der Start-Anker
# ermoeglicht das Zwischenargument (die Umzugs-Marke steht im selben Ruf).
ersetzungs_zeilen() {
  sed -n "/$1), .*Ersetzung{\$/,/^\t})\$/p" "$QUELLE" | grep -E '^[[:space:]]+\{'
}

# vorlage_pfad <konstante> loest den Dateinamen auf, den der Code unter dieser
# Konstante fuehrt, und ordnet ihm seinen Ort zu — vendored ($TDIR) oder
# repo-eigen ($PLANNING, ADR-0061 Festlegung 2). Ein Dateiname, der an keinem der
# beiden Orte liegt, ist leer — der Fall unten faellt laut statt still. Ohne diese
# Aufloesung stuende die Zuordnung Block -> Ort hier ein zweites Mal und koennte
# gegen den Code driften.
vorlage_pfad() {
  local datei
  datei="$(vorlage_datei "$1")" || return 1
  if [ -f "$TDIR/$datei" ]; then
    printf '%s\n' "$TDIR/$datei"
  elif [ -f "$PLANNING/$datei" ]; then
    printf '%s\n' "$PLANNING/$datei"
  else
    echo "Vorlage '$datei' (aus '$1') liegt weder unter $TDIR noch unter $PLANNING" >&2
    return 1
  fi
}

# vorlage_datei <konstante> loest den Dateinamen auf, den der Code unter dieser
# Konstante fuehrt. Ohne diese Aufloesung stuende die Zuordnung Block -> Datei
# hier ein zweites Mal und koennte gegen den Code driften.
vorlage_datei() {
  local datei
  datei="$(sed -n "s/^[[:space:]]*$1[[:space:]]*= \"\(.*\)\"\$/\1/p" "$VORLAGEN_KONST")"
  printf '%s\n' "$datei"
}

# platzhalter <konstante> loest jedes Literal des Blocks in seinen ERSTEN
# Ausdruck auf — den Platzhalter. Zwei Formen kommen vor, und beide werden
# getroffen:
#
#   {"<NNN>", nummer},                        -> der Zeichenketten-Literal
#   {"done/<wave-id>/" + archivName, zipRel} -> Literal + Konstante, aufgeloest
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
        wert="$(sed -n "s/^[[:space:]]*${konst}[[:space:]]*= \"\(.*\)\"\$/\1/p" "$KONST")"
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

@test "die zwei vendored Stub-Vorlagen liegen im vendored Baum" {
  [ -f "$TDIR/archive-stub-slice.template.md" ]
  [ -f "$TDIR/archive-stub-wave.template.md" ]
}

@test "die Report-Stub-Vorlage liegt repo-eigen unter docs/plan/planning" {
  [ -f "$PLANNING/archive-stub-report.template.md" ]
}

@test "die Umzugs-Stub-Vorlage liegt repo-eigen unter docs/plan/planning" {
  [ -f "$PLANNING/archive-stub-umzug.template.md" ]
}

# Die Kopplung der beiden Faesser derselben Form: der Bootstrap traegt die
# Report-Stub-Vorlage in das Ziel-Repo (internal/emit/templates/planning/),
# der Träger liest sie dort am selben Pfad — byte-gleich zur repo-eigenen
# Vorlage dieses Repos. Treibt eine Seite die Form auseinander, faellt der Fall.
@test "die Report-Stub-Vorlage ist byte-gleich zur mitgetragenen des Bootstraps" {
  cmp "$PLANNING/archive-stub-report.template.md" \
      "$REPO/internal/emit/templates/planning/archive-stub-report.template.md"
}

@test "die Umzugs-Stub-Vorlage ist byte-gleich zur mitgetragenen des Bootstraps" {
  cmp "$PLANNING/archive-stub-umzug.template.md" \
      "$REPO/internal/emit/templates/planning/archive-stub-umzug.template.md"
}

# Die Deckungs-Aussage des Falls darunter, jetzt je Block: die Extraktion loest
# JEDES Ersetzungs-Literal auf, nicht eine Teilmenge — und der Block ist nicht
# leer. Beides ist noetig: ein sed-Bereich, der ins Leere liefe, machte den
# Vorlagen-Fall unten zu einer Quantifizierung ueber die leere Menge, und die ist
# immer wahr.
@test "die Extraktion loest jedes Ersetzungs-Literal aller Bloecke auf" {
  for k in $BLOECKE; do
    zeilen="$(ersetzungs_zeilen "$k" | grep -c . || true)"
    [ "$zeilen" -ge 1 ] || {
      echo "Block '$k': keine Ersetzungs-Literale gefunden — der Bereich greift nicht (nicht-leer ist genug: die Aufloesung unten zaehlt jedes)" >&2
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
    vorlage="$(vorlage_pfad "$k")" || false
    while IFS= read -r p; do
      [ -n "$p" ] || continue
      grep -qF -- "$p" "$vorlage" || fehlend="$fehlend
  $vorlage: $p"
    done < <(platzhalter "$k" | sort -u)
  done
  [ -z "$fehlend" ] || {
    echo "Platzhalter ohne Entsprechung in der Vorlage, die ihr Block fuellt:$fehlend" >&2
    false
  }
}

# Die drei Teile, aus denen die Kuerzung (internal/archive/stub.go, Kuerze) die
# drei ARCHIV-Stub-Arten baut: H1 in Zeile 1, der Archiv-Zeiger-Block, der
# Feld-Block als LETZTER Absatz. Faellt einer weg, schreibt der Lauf einen Stub
# ohne Zeiger oder ohne Felder — und FormOK meldet nur den fehlenden Zeiger,
# nicht die leeren Felder. Der Umzugs-Stub tritt an derselben Kuerzung an
# (kuerzeAn, Marke des Umzugs) — der eigene Fall unten.
@test "alle Archiv-Stub-Vorlagen tragen H1, Archiv-Zeiger und einen Feld-Block als letzten Absatz" {
  for k in $ARCHIV_BLOECKE; do
    vorlage="$(vorlage_pfad "$k")" || false
    head -n 1 "$vorlage" | grep -q '^# '
    grep -q '^> \*\*ARCHIVIERT\*\*' "$vorlage"
    grep -q 'archive.zip' "$vorlage"
    tail -n 1 "$vorlage" | grep -q '^\*\*'
  done
}

# Die Form der Umzugs-Stub-Vorlage (ADR-0112 Festlegung 2, Stillgelegt-Fassung
# des planning-Moduls): H1, Umzugs-Zeiger, Zustand, und die §7-Closure-Notiz mit
# der Gegenstand-Zeile als letztem Absatz — der Absatz, den die Kuerzung traegt.
# KEINEN Archiv-Zeiger, denn ihr Volltext liegt byte-genau an der neuen
# Arbeitsbaum-Adresse, nicht im Archiv-Zip.
@test "die Umzugs-Stub-Vorlage trägt H1, Umzugs-Zeiger, Zustand und die Stillgelegt-Fassung, keinen Archiv-Zeiger" {
  vorlage="$(vorlage_pfad stubVorlageUmzug)" || false
  head -n 1 "$vorlage" | grep -q '^# '
  grep -q '^> \*\*UMZUGEZOGEN\*\*' "$vorlage"
  grep -q 'done/<wave-id>/<pfad-im-arbeitsbaum>' "$vorlage"
  grep -q '^## 2. Definition of Done' "$vorlage"
  grep -q '^## 7. Closure-Notiz' "$vorlage"
  grep -q '^- \*\*Gegenstand:\*\* <wave-id | altbestand> — der Volltext dieses Slices liegt byte-genau an der Adresse, die der Umzugs-Zeiger nennt' "$vorlage"
  tail -n 1 "$vorlage" | grep -q '^- \*\*Gegenstand:\*\*'
  if grep -q '^> \*\*ARCHIVIERT\*\*' "$vorlage" || grep -q 'archive.zip' "$vorlage"; then
    echo "die Umzugs-Stub-Vorlage traegt einen Archiv-Zeiger — ihr Volltext liegt an der neuen Adresse, nicht im Zip" >&2
    false
  fi
}
