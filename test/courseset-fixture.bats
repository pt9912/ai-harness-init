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
# Drei Achsen. Zwei messen die Fixture gegen den realen Satz: der DATEIBESTAND
# (jede Vorlage des realen Satzes liegt in der Fixture) und vom INHALT genau eine
# — die Platzhalter-Pfad-FORM. Weiter geht dieser Abgleich nicht: einen WORTLAUT
# vergleicht er nicht, und die Transformationen (Hinweis-Strip, Namens-Stempel,
# verbatim) pruefen die Emit-Tests gegen die Fixture — die dieser Test ehrlich
# haelt.
#
# Die dritte Achse misst nicht die Fixture, sondern die KLASSIFIKATION: die
# namentliche Aufzaehlung in emit.isRecurring gegen die Definition, die ihr
# Kommentar ausspricht (Ziel-Ort mit <…>-Platzhalter). Gegenstand ist der reale
# Satz und internal/emit/templates.go, die Fixture kommt darin nicht vor.

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  FIXTURE_SRC="$REPO/internal/emit/templates_test.go"
  EMIT_SRC="$REPO/internal/emit/templates.go"
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

@test "fixture: der reale Satz liefert genau 23 in-scope-Templates" {
  # Die Zahl ist kein Selbstzweck: von 23 in-scope-Templates emittiert der Tool genau
  # 11 als Singletons (inkl. der 2 Durchsetzungs-Skills und des
  # Beobachtungs-Registers); ununemittiert bleiben 2 derivative Indexe
  # (emit.isDerivativeIndex), 9 wiederkehrende (emit.isRecurring) und 1 modus-gebundenes
  # Register (emit.isBrownfieldOnly). Bewegt sich die Zahl, hat upstream etwas
  # hinzugefuegt oder entfernt — und die Aufzaehlungen brauchen dann eine Entscheidung,
  # statt das Neue still als Singleton zu behandeln.
  local n
  n="$(real_paths | in_scope | wc -l | tr -d ' ')"
  [ "$n" -eq 23 ] || {
    echo "in-scope-Templates: $n, erwartet 23"
    real_paths | in_scope
    return 1
  }
}

@test "fixture: die neun wiederkehrenden Templates existieren real" {
  # emit.isRecurring zaehlt sie namentlich auf (LH-FA-02). Ab 0.8.0 werden sie NICHT
  # emittiert, sondern aus der vendored Baseline je Artefakt kopiert (ADR-0005) —
  # verschwindet einer upstream, bricht genau dieses referenzierte Modell (der Nutzer
  # findet die Vorlage nicht mehr im vendored Satz).
  #
  # Die Liste spiegelt emit.isRecurring, nicht die Menge der ununemittierten Vorlagen:
  # die derivativen Indexe und das Reconciliation-Register stehen bewusst nicht hier,
  # sie haengen an eigenen Weichen. Faellt eine Vorlage upstream ganz weg, faengt das
  # ohnehin schon der Satz-Abgleich oben — diese Liste faengt den Fall, dass Fixture
  # und realer Satz sie GEMEINSAM verlieren.
  local rel
  for rel in \
    docs/plan/adr/NNNN-titel.template.md \
    docs/plan/planning/slice.template.md \
    docs/plan/planning/welle.template.md \
    docs/plan/carveouts/carveout.template.md \
    docs/reviews/review-report.template.md \
    docs/plan/planning/welle-results.template.md \
    harness/conventions/MR-NNN-titel.template.md \
    docs/plan/planning/archiv-stub-slice.template.md \
    docs/plan/planning/archiv-stub-welle.template.md
  do
    [ -f "$REAL/$rel" ] || { echo "wiederkehrendes Template fehlt real: $rel"; return 1; }
  done
}

# ziel_ort liest den Ziel-Ort aus dem Template-Hinweis einer Vorlage: im
# fuehrenden Blockquote den ersten Backtick-Ausdruck hinter einem der zwei Anker,
# die den Ort EINFUEHREN.
#
#   Kopiere-Satz  — "Kopiere … nach `<pfad>.md`": das Ziel ist eine Datei. So
#                   nennen ihn sieben der neun wiederkehrenden Vorlagen.
#   Verbleib-Satz — "… liegen bleibt (`<verzeichnis>/`)": das Ziel ist das
#                   Verzeichnis, in dem die Kopie liegen bleibt. So nennen ihn die
#                   zwei Archiv-Stubs, die nirgendwohin kopiert werden.
#
# Beide Zweige verlangen vom gelesenen Ausdruck eine ENDUNG — .md hier, / dort.
# Ein Backtick-Ausdruck, der kein Ort ist, ist damit kein Treffer, und ein
# upstream umgeschriebener Ort faellt als OHNE-ZIEL auf, statt als falscher Wert
# durchzugehen.
#
# Die Anker sitzen dort, wo der Satz den Ort EINFUEHRT, und darauf ruht der
# Unterschied zwischen leer und falsch. Ein Template-Hinweis kann vor dem Ziel
# einen zweiten Inline-Code-Ausdruck fuehren:
#
#   Kopiere per `git mv` nach `docs/plan/planning/<bereich>/observations.md`
#
# Dort ist der erste Backtick-Ausdruck hinter "Kopiere" nicht der Ort. Wer die
# Anker lockert, liest `git mv`, findet darin keinen Platzhalter und haelt die
# Vorlage still fuer nicht wiederkehrend — die OHNE-ZIEL-Zeile bleibt aus, weil die
# Extraktion ja etwas geliefert hat. Mit den Ankern liefert diese Wortstellung
# KEINEN Treffer, wiederkehrend_real macht daraus OHNE-ZIEL, und der Vergleich
# faellt rot. test/mutations/220 faehrt genau diese Umformulierung.
#
# Die Wortstellung ist nicht konstruiert: der Hinweis von
# harness/conventions/MR-NNN-titel.template.md fuehrt "wandert die Datei per
# `git mv` nach `done/`" im selben Blockquote — dort steht sie hinter dem Ziel-Pfad
# statt davor.
#
# Was die Anker nicht koennen: sie lesen einen SATZ, kein Datenfeld. Steht zwischen
# "nach" und dem Ziel ein anderer Backtick-Ausdruck auf .md, liest die Extraktion
# diesen — dann ist sie wieder falsch statt leer. Und ein Satz, der den Ort anders
# einleitet ("Kopiere in `…`", "steht unter `…`"), roetet den Test, obwohl an ihm
# nichts falsch ist. Beides ist der Preis dafuer, dass der Ort im Blockquote als
# Prosa steht; die zweite Richtung ist die guenstigere, weil sie laut ist.
#
# Das `> `-Praefix faellt ZEILENWEISE weg, bevor die Zeilen zusammenlaufen. Ohne
# das stuende es mitten im Pfad, sobald der Satz umbricht — bei
# .harness/skills/closure-note-reviewer.template.md tut er das. Aus demselben
# Grund laesst der Verbleib-Anker Leerraum vor der Klammer zu: bei beiden
# Archiv-Stubs bricht der Satz genau dort um.
ziel_ort() {
  awk '/^>/ { inb = 1; sub(/^>[ \t]?/, ""); buf = buf " " $0; next }
       inb  { exit }
       END  { print buf }' "$1" \
    | grep -oE 'Kopiere[^`]* nach [^`]*`[^`]+\.md`|liegen bleibt[[:space:]]*\([[:space:]]*`[^`]+/`' \
    | head -1 \
    | sed 's/.*`\(.*\)`/\1/'
}

# wiederkehrend_real leitet die wiederkehrenden Vorlagen aus dem REALEN Satz ab:
# wiederkehrend ist, wessen Ziel-Ort einen <…>-Platzhalter fuehrt (mehr als ein
# Ziel je Repo). Ausgegeben wird der BASENAME — emit.isRecurring schaltet auf ihm
# (planTemplates ruft sie mit path.Base(rel)).
#
# Findet ziel_ort in einer Vorlage keinen Ziel-Ort, gibt wiederkehrend_real
# fuer sie die Zeile OHNE-ZIEL:<pfad> aus statt gar nichts: eine leere Ableitung
# ist von einem "nicht wiederkehrend" nicht zu unterscheiden, die Zeile dagegen
# faellt dem Vergleich unten auf — laut statt still.
wiederkehrend_real() {
  local rel ziel
  while read -r rel; do
    ziel="$(ziel_ort "$REAL/$rel")"
    if [ -z "$ziel" ]; then
      echo "OHNE-ZIEL:$rel"
    else
      case "$ziel" in *'<'*'>'*) echo "${rel##*/}" ;; esac
    fi
  done < <(real_paths | in_scope) | LC_ALL=C sort
}

# wiederkehrend_code liest die namentliche Aufzaehlung aus dem RUMPF von
# emit.isRecurring. Die Begrenzung auf den Rumpf ist tragend: der Kommentar
# darueber nennt dieselben Dateinamen im Fliesstext, und ohne sie zaehlte der
# Waechter die Begruendung als Eintrag.
wiederkehrend_code() {
  awk '/^func isRecurring\(/ { infn = 1 } infn && /^}/ { infn = 0 } infn' "$EMIT_SRC" \
    | grep -oE '"[^"]+\.template\.md"' \
    | tr -d '"' \
    | LC_ALL=C sort
}

# Die dritte Achse. Der Kommentar an emit.isRecurring spricht eine DEFINITION aus
# ("die Vorlage nennt ihren Ziel-Pfad mit einem Platzhalter darin"), der Code haelt
# daneben eine NAMENSLISTE. Dieser Test haelt beide aneinander, und zwar gegen den
# realen Satz statt gegen die Fixture.
#
# Was ohne ihn durchginge: ein Baseline-Bump, der in einem Template-Hinweis den
# Ziel-Ort von fest auf platzhalterhaltig aendert (oder umgekehrt), laesst
# Datei-Bestand und in-scope-Zahl unberuehrt — die zwei Achsen oben bleiben gruen,
# und der Emitter liefe still gegen seine eigene Definition. Die Faelle
# test/mutations/219 (Kopiere-Satz) und test/mutations/224 (Verbleib-Satz) fahren
# genau das, je an einer der zwei Satzformen.
#
# GRENZE: verglichen werden BASENAMEN, weil emit.isRecurring auf dem Basenamen
# schaltet (internal/emit/templates.go ruft isRecurring(path.Base(rel))). Vier
# in-scope-Vorlagen teilen sich heute den Basenamen README.template.md — sie liegen
# unter docs/plan/adr/, docs/plan/carveouts/, docs/plan/planning/ und harness/
# (find "$REAL" -type f -name 'README.template.md' | wc -l gibt die Zahl aus). Wird
# eine davon wiederkehrend, traegt die Aufzaehlung ihren Basenamen, und der Emitter
# nimmt alle vier gemeinsam aus dem Emit — darunter harness/README.md. Dieser Test
# sieht es nicht, denn er vergleicht dieselben Basenamen: die Grenze liegt in der
# Signatur, nicht hier.
#
# GRENZE: gelesen wird der Quelltext der Aufzaehlung, nicht das Verhalten von
# isRecurring — die go-test-Stufe sieht .harness/ nicht (.dockerignore), ein Lauf
# mit realem Satz UND Emit-Regel existiert in `make gates` nicht. Dieselbe
# Begruendung traegt schon die Fixture-Achse oben.
@test "fixture: emit.isRecurring fuehrt genau die Vorlagen mit Platzhalter im Ziel-Pfad" {
  [ -d "$REAL" ] || { echo "vendored templates/ fehlt: $REAL"; return 1; }
  local real code
  code="$(wiederkehrend_code)"
  # Eine leere Extraktion waere ein Waechter, der nur zufaellig rot faerbt.
  [ -n "$code" ] || {
    echo "isRecurring-Rumpf in $EMIT_SRC nicht gefunden oder keine Namen extrahiert —"
    echo "Parser gebrochen? Ohne die Liste misst dieser Test nichts."
    return 1
  }
  real="$(wiederkehrend_real)"
  diff <(printf '%s\n' "$real") <(printf '%s\n' "$code") || {
    echo "DRIFT: emit.isRecurring und die Ziel-Pfade des realen Satzes sagen Verschiedenes."
    echo "  '<' nur aus dem realen Satz abgeleitet, '>' nur in der Aufzaehlung."
    echo "  Eine Zeile OHNE-ZIEL:<pfad> heisst: ziel_ort findet in dieser Vorlage"
    echo "  keinen Ziel-Ort — Kopiere- wie Verbleib-Satz fehlen, oder einer fuehrt den"
    echo "  Ort in einer Wortstellung, die ziel_ort nicht liest. Die Ableitung steht"
    echo "  fuer diese Vorlage dann ohne Grundlage da."
    echo "  Ein Treffer links ist die Frage: ist die Vorlage jetzt wiederkehrend"
    echo "  (Eintrag in emit.isRecurring) oder hat upstream ihren Ziel-Ort geaendert?"
    return 1
  }
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
