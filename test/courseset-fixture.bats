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
# Was er NICHT leistet: Inhalts-Gleichheit. Er vergleicht den DATEIBESTAND. Die
# Transformationen (Hinweis-Strip, Namens-Stempel, verbatim) pruefen die
# Emit-Tests gegen die Fixture — die dieser Test ehrlich haelt.

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  FIXTURE_SRC="$REPO/internal/emit/templates_test.go"
  # vendored Baseline: genau ein <tag>-Verzeichnis (MR-007 "ein Tag zur Zeit").
  REAL="$(echo "$REPO"/.harness/baseline/*/templates)"
}

# fixture_paths liest die Pfad-SCHLUESSEL aus dem courseSet()-MapFS-Literal.
#
# Zwei Praezisierungen aus Review-Befund N-2: (a) der Bereich ist auf den
# courseSet()-Rumpf begrenzt, sonst zoege der Scan Map-Schluessel aus anderen
# Test-Funktionen mit; (b) gematcht wird der SCHLUESSEL, nicht die Schreibweise
# des Werts. Die Vorgaenger-Fassung verlangte `: f(` — ein Eintrag im
# `&fstest.MapFile{…}`-Stil (steht in derselben Datei bereits mehrfach) waere
# still uebergangen worden, der Waechter also falsch-negativ.
fixture_paths() {
  awk '/^func courseSet\(\)/ { infn=1 } infn && /^}/ { infn=0 } infn' "$FIXTURE_SRC" \
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
