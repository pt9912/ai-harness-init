#!/usr/bin/env bats
# courseset-fixture.bats — haelt die Test-Fixture courseSet() am REALEN
# Kurs-Template-Satz fest (.harness/baseline/<tag>/templates/).
#
# Warum es diese Datei gibt (slice-022b, Review-Befunde F-3/F-4):
# Mit dem Embed fiel test/skel-drift.bats — und damit die EINZIGE Stelle in
# `make gates`, die den realen Template-Satz ueberhaupt anfasste. Die Emit-Tests
# laufen seither gegen courseSet(), einen handgeschriebenen Nachbau in
# internal/emit/templates_test.go. Damit ist ein NEUES Drift-Paar entstanden:
# Fixture gegen Wirklichkeit. Strukturell dieselbe Klasse, die der Slice
# abschaffen wollte — nur mit milderer Folge (Testtreue statt Auslieferung).
#
# Warum bats und nicht go-test: .harness/ liegt nicht im Docker-Build-Kontext
# (.dockerignore), die go-test-Stage sieht den realen Baum also gar nicht. Genau
# der Grund, aus dem schon der geloeschte Waechter hier lag.
#
# Zwei Achsen: der DATEIBESTAND (jede Vorlage des realen Satzes liegt in der
# Fixture) und vom INHALT genau eine — die Platzhalter-Pfad-FORM. Weiter geht der
# Abgleich nicht: einen WORTLAUT vergleicht er nicht, und die Transformationen
# (Hinweis-Strip, Namens-Stempel, verbatim) pruefen die Emit-Tests gegen die
# Fixture — die dieser Test ehrlich haelt.

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  FIXTURE_SRC="$REPO/internal/emit/templates_test.go"
  # vendored Baseline: genau ein <tag>-Verzeichnis (MR-007 "ein Tag zur Zeit").
  REAL="$(echo "$REPO"/.harness/baseline/*/templates)"
}

# fixture_body schneidet den Rumpf von courseSet() aus der Test-Datei. Die
# Begrenzung ist tragend fuer beide Leser unten: ohne sie zoegen sie Map-Schluessel
# und Link-Formen aus anderen Test-Funktionen derselben Datei mit — und ein
# Beispiel-Link aus einem Testfall zaehlte als Fixture-Eintrag.
fixture_body() {
  awk '/^func courseSet\(\)/ { infn=1 } infn && /^}/ { infn=0 } infn' "$FIXTURE_SRC"
}

# fixture_paths liest die Pfad-SCHLUESSEL aus dem courseSet()-MapFS-Literal.
# Gematcht wird der SCHLUESSEL, nicht die Schreibweise des Werts: eine Bedingung
# auf `: f(` uebergaeht einen Eintrag im `&fstest.MapFile{…}`-Stil (steht in
# derselben Datei mehrfach), der Waechter waere dort falsch-negativ.
fixture_paths() {
  fixture_body \
    | awk -F'"' '/^[ \t]*"[^"]+"[ \t]*:/ { print $2 }' \
    | LC_ALL=C sort
}

real_paths() {
  ( cd "$REAL" && find . -type f | sed 's|^\./||' | LC_ALL=C sort )
}

# in_scope filtert nach derselben Regel wie emit.inScope: *.template.md, minus
# project-readme (LH-FA-05). Die .harness/skills/-Skills sind seit slice-030 in-scope.
in_scope() {
  grep '\.template\.md$' \
    | grep -v '^project-readme\.template\.md$'
}

@test "fixture: courseSet() bildet den realen Template-Satz vollstaendig ab" {
  [ -d "$REAL" ] || { echo "vendored templates/ fehlt: $REAL"; return 1; }
  # Eine leere Extraktion waere ein falsch-negativer Waechter, der nur zufaellig
  # rot faerbt (weil dann alles als fehlend erscheint). Lieber hier laut sein.
  [ "$(fixture_paths | wc -l)" -gt 0 ] || {
    echo "courseSet() nicht gefunden oder keine Schluessel extrahiert — Parser gebrochen?"
    return 1
  }
  diff <(fixture_paths) <(real_paths) || {
    echo "DRIFT: courseSet() in $FIXTURE_SRC weicht vom realen Satz ab."
    echo "  '<' nur in der Fixture, '>' nur im realen Baum."
    echo "  Ein neuer Eintrag rechts ist die Frage, die der geloeschte"
    echo "  skel-drift-Waechter stellte: gehoert er in scope, und wenn ja,"
    echo "  ist er Singleton oder wiederkehrend (emit.isRecurring)?"
    return 1
  }
}

@test "fixture: der reale Satz liefert genau 17 in-scope-Templates" {
  # Die Zahl ist kein Selbstzweck: von 17 in-scope-Templates emittiert der Tool genau
  # 10 als Singletons (8 + die 2 Durchsetzungs-Skills seit slice-030); 2 derivative Indexe
  # (emit.isDerivativeIndex) und 5 wiederkehrende (emit.isRecurring) bleiben ununemittiert.
  # Bewegt sich die Zahl, hat upstream etwas hinzugefuegt oder entfernt — und die
  # Aufzaehlungen brauchen dann eine Entscheidung, statt das Neue still als Singleton
  # zu behandeln.
  local n
  n="$(real_paths | in_scope | wc -l | tr -d ' ')"
  [ "$n" -eq 17 ] || {
    echo "in-scope-Templates: $n, erwartet 17"
    real_paths | in_scope
    return 1
  }
}

@test "fixture: die fuenf wiederkehrenden Templates existieren real" {
  # emit.isRecurring zaehlt sie namentlich auf (LH-FA-02). Ab 0.8.0 werden sie NICHT
  # emittiert, sondern aus der vendored Baseline je Artefakt kopiert (ADR-0005) —
  # verschwindet einer upstream, bricht genau dieses referenzierte Modell (der Nutzer
  # findet die Vorlage nicht mehr im vendored Satz).
  local rel
  for rel in \
    docs/plan/adr/NNNN-titel.template.md \
    docs/plan/planning/slice.template.md \
    docs/plan/planning/welle.template.md \
    docs/plan/carveouts/carveout.template.md \
    docs/reviews/review-report.template.md
  do
    [ -f "$REAL/$rel" ] || { echo "wiederkehrendes Template fehlt real: $rel"; return 1; }
  done
}

# platzhalter_formen liest aus stdin die FORMEN der Links, deren ZIEL-PFAD (der
# Teil vor dem `#`) einen <…>-Platzhalter fuehrt. Zwei Formen, die ein
# Markdown-Parser verschieden liest:
#   spitz       — das GANZE Ziel steht in spitzen Klammern, `](<pfad>)`. Das ist
#                 eine Angle-Bracket-Destination; ihr Inhalt IST der Pfad.
#   eingebettet — der Platzhalter steht im Ziel-Text, `](../<welle-NN-titel>.md)`.
#                 Das Ziel wird Zeichen fuer Zeichen gelesen.
# Die Bedingung liest das GANZE Ziel, nicht sein erstes Zeichen: `](<NNNN>-<titel>.md)`
# beginnt mit `<` und endet dort nicht — keine Angle-Bracket-Destination, also
# eingebettet. Der Fall test/mutations/209 haelt diese Bedingung fest.
#
# Der Anker bleibt aussen vor: ueber die Aufloesbarkeit eines Links entscheidet
# der Pfad, und emit.NeutralizePlaceholderLinks zieht dieselbe Grenze.
platzhalter_formen() {
  grep -oE '\]\([^()[:space:]]*\)' \
    | awk '{
        ziel = substr($0, 3, length($0) - 3)
        sub(/#.*$/, "", ziel)
        if (ziel !~ /<[^<>]*>/) next
        print (ziel ~ /^<[^<>]*>$/) ? "spitz" : "eingebettet"
      }' \
    | LC_ALL=C sort -u
}

real_formen() {
  find "$REAL" -type f -name '*.md' -exec cat {} + | platzhalter_formen
}

fixture_formen() {
  fixture_body | platzhalter_formen
}

# Die INHALTS-Achse dieses Waechters, und die einzige. Sie haelt fest, dass
# courseSet() jede Platzhalter-Pfad-Form fuehrt, die der reale Satz fuehrt: die
# Emit-Tests laufen gegen die Fixture, und ueber eine Form, die dort fehlt, sagen
# sie nichts — waehrend das gebootstrappte Repo den Link traegt.
#
# Die Richtung ist real ⊆ Fixture, mit Absicht. Eine Form, die die Fixture fuehrt
# und der reale Satz nicht (mehr), ist Ueber-Deckung: die Emit-Tests sagen dann
# mehr als noetig, nicht weniger. Sie faellt hier deshalb nicht auf.
#
# Neben TestTemplates_KeinPlatzhalterLinkImEmittiertenSatz steht er nicht umsonst:
# dessen Leerlauf-Sperre feuert erst, wenn die Fixture JEDEN Platzhalter-Link
# verliert; dieser Test feuert schon beim Verlust EINES der zwei Eimer.
#
# GRENZE, und sie ist eng. Verglichen wird ein Vokabular aus GENAU ZWEI Formen,
# nicht die Links selbst: fuehrt die Fixture beide, kann keine Hinzufuegung upstream
# diesen Test mehr roeten, denn jeder <…>-Pfad-Link faellt in einen der zwei Eimer.
# Ein Platzhalter in einer anderen Schreibweise ({{…}}, @@…@@) faellt schon
# durch den <…>-Filter, ein Link mit Leerraum oder Klammern im Ziel durch den
# Scanner. OB emit.NeutralizePlaceholderLinks einen realen Link ERREICHT, misst
# dieser Test nicht — und kein Gate misst es: dafuer braeuchte EIN Lauf den realen
# Satz UND die Emit-Regel, und keiner in `make gates` hat beides (die go-test-Stufe
# sieht .harness/ nicht, s. .dockerignore; diese Stufe sieht die Regel nicht).
# Diese Reste sieht allein `make smoke`, ausserhalb von `make gates`.
@test "fixture: courseSet() fuehrt jede Platzhalter-Pfad-Form des realen Satzes" {
  [ -d "$REAL" ] || { echo "vendored templates/ fehlt: $REAL"; return 1; }
  local real fix fehlend form
  real="$(real_formen)"
  # Ohne Gegenstand misst der Waechter nichts. Das ist kein Grund, gruen zu sein:
  # faellt die Form upstream weg, gehoert die Neutralisierung geprueft, nicht
  # stillschweigend behalten.
  [ -n "$real" ] || {
    echo "der reale Satz fuehrt keinen Link mehr, dessen ZIEL-PFAD einen"
    echo "<…>-Platzhalter traegt. Dann misst dieser Waechter nichts, und"
    echo "emit.NeutralizePlaceholderLinks steht ohne Gegenstand — beides"
    echo "gehoert entschieden, nicht still gruen gelassen."
    return 1
  }
  fix="$(fixture_formen)"
  fehlend=""
  for form in $real; do
    grep -qxF "$form" <<<"$fix" || fehlend="$fehlend $form"
  done
  [ -z "$fehlend" ] || {
    echo "DRIFT: courseSet() in $FIXTURE_SRC fuehrt die Form(en) nicht:$fehlend"
    echo "  real:    $(echo "$real" | tr '\n' ' ')"
    echo "  Fixture: $(echo "$fix" | tr '\n' ' ')"
    echo "  Die Emit-Tests messen gegen die Fixture. Fehlt dort eine Form, die"
    echo "  der reale Satz fuehrt, sagen sie ueber sie nichts — gesehen haette"
    echo "  den toten Link im Ziel dann nur noch make smoke, ausserhalb der Gates."
    return 1
  }
}
