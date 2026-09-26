#!/usr/bin/env bats
# slice-mv.bats — Zaehne fuer die Ersetzungs-Funktionen des Lifecycle-Werkzeugs.
#
# Der Selbsttest der Ersetzung laeuft OHNE ein Repo zu bewegen: er sourced das
# Skript (BASH_SOURCE-Waechter unterdrueckt main()/git mv) und ruft
# die Ersetzungs-Funktionen direkt auf Proben —
# sonst misst der Selbsttest sich selbst statt der Ersetzung. Diese Datei fuehrt
# ALLE ihre Faelle so, ohne Ausnahme — die EINGEHEND-Ausnahmeliste
# (eingehend_ausgenommene_pfade) ist eine reine Funktion und darum
# bats-gedeckt; was main() daraus MACHT (Zwei-Commit-Sequenz, realer
# `git grep`-Aufruf) braucht ein echtes `git`-Repo und ist darum NICHT hier,
# sondern in harness/tools/full-smoke.sh belegt — dort an einem echten Move im
# gebootstrappten Ziel.
#
# ZWEI FASSUNGEN, EINE PRUEFUNG: dieselbe Ersetzungs-Logik liegt als
# ausgeführte Fassung dieses Repos (harness/tools/slice-mv.sh) und als
# Emissions-Vorlage (internal/emit/templates/enforce/slice-mv.sh) vor. Zwei
# Pruefungen tragen die Kopplung, und die zweite traegt sie breiter:
#   (1) jeder Fall unten faehrt BEIDE Fassungen — das deckt die Entscheidungen,
#       die ein Fall ausloest; ausgenommen sind die Faelle zur Form-Regel unter
#       docs/reviews/ (ADR-0070), s. dort;
#   (2) der Kopplungs-Fall am Dateiende vergleicht die RUEMPFE der Funktionen
#       in KERN — das deckt auch eine einseitig entfernte
#       Entscheidung, die kein Fall trifft (etwa das /g-Flag des Eingehend-sed).
# Die zwei unterscheiden sich in ihrer Verankerung — Repo-Pfade, Kommentare, die
# Ausnahmeliste als Konstante bzw. als setzbare Variable —, nicht in der
# Ersetzung; genau diesen Kern haelt (2) zusammen.

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  DOGFOOD="$REPO/harness/tools/slice-mv.sh"
  EMITTIERT="$REPO/internal/emit/templates/enforce/slice-mv.sh"
  FASSUNGEN=("$DOGFOOD" "$EMITTIERT")
  TMP="$BATS_TEST_TMPDIR"
}

# Laedt die reinen Funktionen EINER Fassung in DIESE Shell (kein Subshell-Pipe —
# sonst verschwinden die Definitionen wieder, real beim ersten Entwurf erlebt).
load_functions() {  # $1=skript
  # shellcheck source=/dev/null
  source "$1"
}

@test "eingehend: die Wortgrenzen-Regel ersetzt jede Praefix-Tiefe und jeden Kontext (Stichprobe, keine feste Formenliste — Vollstaendigkeit gegen den Bestand misst make docs-check, nicht dieser Test)" {
  for fassung in "${FASSUNGEN[@]}"; do
  load_functions "$fassung"
  cat > "$TMP/probe.md" <<'EOF'
../../docs/plan/planning/open/slice-999-x.md
../docs/plan/planning/open/slice-999-x.md
docs/plan/planning/open/slice-999-x.md
../open/slice-999-x.md
(open/slice-999-x.md)
`open/slice-999-x.md`
open/slice-999-x.md
../../planning/open/slice-999-x.md
../planning/open/slice-999-x.md
EOF
  rewrite_incoming_in_file "$TMP/probe.md" "slice-999-x.md" "open" "ZIEL"
  # Keine der neun Zeilen zeigt danach noch auf "open/" ...
  ! grep -q 'open/slice-999-x\.md' "$TMP/probe.md"
  # ... und jede zeigt jetzt auf "ZIEL/", in derselben Zeilenzahl (9).
  [ "$(grep -c 'ZIEL/slice-999-x\.md' "$TMP/probe.md")" -eq 9 ]
  done
}

@test "eingehend: fremde Datei im selben Verzeichnis bleibt unberuehrt (Gegenprobe)" {
  for fassung in "${FASSUNGEN[@]}"; do
  load_functions "$fassung"
  printf '[b](../open/slice-998-y.md)\n' > "$TMP/probe.md"
  rewrite_incoming_in_file "$TMP/probe.md" "slice-999-x.md" "open" "ZIEL"
  grep -qF '../open/slice-998-y.md' "$TMP/probe.md"
  done
}

@test "eingehend: dieselbe Datei in einem ANDEREN Verzeichnis bleibt unberuehrt (Gegenprobe)" {
  for fassung in "${FASSUNGEN[@]}"; do
  load_functions "$fassung"
  printf '[c](../done/slice-999-x.md)\n' > "$TMP/probe.md"
  rewrite_incoming_in_file "$TMP/probe.md" "slice-999-x.md" "open" "ZIEL"
  grep -qF '../done/slice-999-x.md' "$TMP/probe.md"
  done
}

@test "eingehend: verklebtes Wort bleibt unberuehrt — Bindestrich zaehlt als Wortzeichen" {
  for fassung in "${FASSUNGEN[@]}"; do
  load_functions "$fassung"
  printf 'sibling-open/slice-999-x.md\n' > "$TMP/probe.md"
  rewrite_incoming_in_file "$TMP/probe.md" "slice-999-x.md" "open" "ZIEL"
  grep -qF 'sibling-open/slice-999-x.md' "$TMP/probe.md"
  done
}

@test "eingehend: Teilstring-Falle — Move von slice-13 aendert slice-130 NICHT (AGENTS 3.6, Slice-Plan §6)" {
  for fassung in "${FASSUNGEN[@]}"; do
  load_functions "$fassung"
  cat > "$TMP/probe.md" <<'EOF'
[a](../open/slice-13-x.md)
[b](../open/slice-130-y.md)
EOF
  rewrite_incoming_in_file "$TMP/probe.md" "slice-13-x.md" "open" "ZIEL"
  grep -qF '../ZIEL/slice-13-x.md' "$TMP/probe.md"
  grep -qF '../open/slice-130-y.md' "$TMP/probe.md"
  ! grep -q 'slice-130-y\.md' <(grep 'ZIEL' "$TMP/probe.md")
  done
}

@test "eingehend praefixlos: jeder Link auf die bewegte Datei bekommt ../ZIEL/ — gleichnamiger Code-Span, Tree-Operand, Praefix-Verweis und laengerer Name bleiben (ganzer Dateiinhalt)" {
  for fassung in "${FASSUNGEN[@]}"; do
  load_functions "$fassung"
  cat > "$TMP/geschwister.md" <<'EOF'
[a](slice-999-x.md) und [b](slice-999-x.md#7-closure-notiz)
`slice-999-x.md`
`git show 1a2b3c4:slice-999-x.md`
[c](../open/slice-999-x.md)
[d](slice-999-x.mdx)
[e](slice-998-y.md)
[f](slice-999-x.md)
EOF
  run rewrite_incoming_bare_in_file "$TMP/geschwister.md" "slice-999-x.md" "ZIEL"
  [ "$status" -eq 0 ]
  [ "$output" = "3" ] || { echo "Zaehler ($fassung): $output"; return 1; }
  erwartet='[a](../ZIEL/slice-999-x.md) und [b](../ZIEL/slice-999-x.md#7-closure-notiz)
`slice-999-x.md`
`git show 1a2b3c4:slice-999-x.md`
[c](../open/slice-999-x.md)
[d](slice-999-x.mdx)
[e](slice-998-y.md)
[f](../ZIEL/slice-999-x.md)'
  ist="$(cat "$TMP/geschwister.md")"
  [ "$ist" = "$erwartet" ] || { echo "Ist-Bestand ($fassung) weicht ab:"; echo "$ist"; return 1; }
  done
}

@test "ausgehend: praefixloses Ziel zu einem verbliebenen Geschwister bekommt ../from/" {
  for fassung in "${FASSUNGEN[@]}"; do
  load_functions "$fassung"
  mkdir -p "$TMP/docs/plan/planning/open"
  : > "$TMP/docs/plan/planning/open/slice-998-sibling.md"
  cd "$TMP"
  printf '[a](slice-998-sibling.md)\n' > moved.md
  run rewrite_outgoing_bare_in_file moved.md open
  [ "$status" -eq 0 ]
  [ "$output" = "1" ]
  grep -qF '[a](../open/slice-998-sibling.md)' moved.md
  done
}

@test "ausgehend: benannte Slice-Kennung ohne Ziffern-Praefix bekommt ../from/ ebenso wie eine nummerierte" {
  for fassung in "${FASSUNGEN[@]}"; do
  load_functions "$fassung"
  mkdir -p "$TMP/docs/plan/planning/open"
  : > "$TMP/docs/plan/planning/open/slice-woertlich-benannt.md"
  cd "$TMP"
  printf '[a](slice-woertlich-benannt.md)\n' > moved.md
  run rewrite_outgoing_bare_in_file moved.md open
  [ "$status" -eq 0 ]
  [ "$output" = "1" ]
  grep -qF '[a](../open/slice-woertlich-benannt.md)' moved.md
  done
}

@test "ausgehend: zwei benannte Kennungen mit gemeinsamem Praefix bleiben getrennt (kein Teilstring-Uebergriff)" {
  for fassung in "${FASSUNGEN[@]}"; do
  load_functions "$fassung"
  mkdir -p "$TMP/docs/plan/planning/open"
  : > "$TMP/docs/plan/planning/open/slice-abc.md"
  : > "$TMP/docs/plan/planning/open/slice-abc-erweitert.md"
  cd "$TMP"
  cat > moved.md <<'EOF'
[a](slice-abc.md)
[b](slice-abc-erweitert.md)
EOF
  run rewrite_outgoing_bare_in_file moved.md open
  [ "$status" -eq 0 ]
  [ "$output" = "2" ]
  grep -qF '[a](../open/slice-abc.md)' moved.md
  grep -qF '[b](../open/slice-abc-erweitert.md)' moved.md
  done
}

@test "ausgehend: welle-Ziel bleibt unberuehrt (Grenze 2 — nur slice-Dateien)" {
  for fassung in "${FASSUNGEN[@]}"; do
  load_functions "$fassung"
  mkdir -p "$TMP/docs/plan/planning/open"
  : > "$TMP/docs/plan/planning/open/welle-01-x.md"
  cd "$TMP"
  printf '[a](welle-01-x.md)\n' > moved.md
  run rewrite_outgoing_bare_in_file moved.md open
  [ "$status" -eq 0 ]
  [ "$output" = "0" ]
  grep -qF '[a](welle-01-x.md)' moved.md
  done
}

@test "ausgehend: Ziel ohne existierende Datei bleibt unberuehrt (kein Rateversuch)" {
  for fassung in "${FASSUNGEN[@]}"; do
  load_functions "$fassung"
  mkdir -p "$TMP/docs/plan/planning/open"
  cd "$TMP"
  printf '[a](slice-nicht-vorhanden.md)\n' > moved.md
  run rewrite_outgoing_bare_in_file moved.md open
  [ "$status" -eq 0 ]
  [ "$output" = "0" ]
  grep -qF '[a](slice-nicht-vorhanden.md)' moved.md
  done
}

# Die Faelle zur Form-Regel unter docs/reviews/ (ADR-0070 Festlegung 1) fahren nur
# die Dogfood-Fassung: die Regel gilt fuer dieses Repo, und die emittierte Fassung
# fuehrt weder rewrite_incoming_links_in_file noch rewrite_incoming_nach_baum.
# Beide liegen ausserhalb der Liste KERN. Die Proben tragen den bewegten Pfad in
# fuenf Formen — Link, reiner Pfad-Span, Operand in einem Kommando-Span, Code-Block,
# Fliesstext — in EINER Datei, je einmal.

form_probe() {  # $1=datei
  cat > "$1" <<'EOF'
Link: [Slice](../plan/planning/open/slice-999-x.md#7-closure-notiz)
Span: `docs/plan/planning/open/slice-999-x.md`
Operand: `git show 1a2b3c4:docs/plan/planning/open/slice-999-x.md`
```sh
cat docs/plan/planning/open/slice-999-x.md
```
Fliesstext: Der Slice lag in docs/plan/planning/open/slice-999-x.md und wurde bewegt.
EOF
}

@test "docs/reviews: der Link auf den bewegten Slice wird nachgezogen, die vier Nicht-Link-Formen (Span, Operand, Block, Fliesstext) bleiben Byte fuer Byte (ADR-0070 Fitness 1)" {
  load_functions "$DOGFOOD"
  cd "$TMP"
  mkdir -p docs/reviews
  form_probe docs/reviews/probe.md
  run rewrite_incoming_nach_baum docs/reviews/probe.md "slice-999-x.md" "open" "next"
  [ "$status" -eq 0 ]
  erwartet='Link: [Slice](../plan/planning/next/slice-999-x.md#7-closure-notiz)
Span: `docs/plan/planning/open/slice-999-x.md`
Operand: `git show 1a2b3c4:docs/plan/planning/open/slice-999-x.md`
```sh
cat docs/plan/planning/open/slice-999-x.md
```
Fliesstext: Der Slice lag in docs/plan/planning/open/slice-999-x.md und wurde bewegt.'
  ist="$(cat docs/reviews/probe.md)"
  [ "$ist" = "$erwartet" ] || { echo "Ist-Bestand weicht ab:"; echo "$ist"; return 1; }
}

@test "docs/reviews: eine Datei ohne Link auf den Slice bleibt unveraendert und gehoert nicht zum Nachzug (Status 1)" {
  load_functions "$DOGFOOD"
  cd "$TMP"
  mkdir -p docs/reviews
  printf '%s\n' '`docs/plan/planning/open/slice-999-x.md` und open/slice-999-x.md' > docs/reviews/nur-span.md
  cp docs/reviews/nur-span.md vorher.md
  run rewrite_incoming_nach_baum docs/reviews/nur-span.md "slice-999-x.md" "open" "next"
  [ "$status" -eq 1 ]
  [ "$(cat docs/reviews/nur-span.md)" = "$(cat vorher.md)" ]
}

@test "docs/reviews: jede Link-Tiefe, mit und ohne Anker und mit Code-Span als Link-Text, wird nachgezogen — verklebtes Wort, laengerer Name und anderes Verzeichnis bleiben" {
  load_functions "$DOGFOOD"
  cd "$TMP"
  mkdir -p docs/reviews
  cat > docs/reviews/tiefen.md <<'EOF'
[a](../../docs/plan/planning/open/slice-999-x.md)
[b](../open/slice-999-x.md)
[c](open/slice-999-x.md)
[`slice-999-x`](../open/slice-999-x.md#anker)
[d](../sibling-open/slice-999-x.md)
[e](../open/slice-999-x.mdx)
[f](../done/slice-999-x.md)
[g](../open/slice-998-y.md)
EOF
  run rewrite_incoming_links_in_file docs/reviews/tiefen.md "slice-999-x.md" "open" "next"
  [ "$status" -eq 0 ]
  [ "$output" = "4" ] || { echo "Zaehler: $output"; return 1; }
  erwartet='[a](../../docs/plan/planning/next/slice-999-x.md)
[b](../next/slice-999-x.md)
[c](next/slice-999-x.md)
[`slice-999-x`](../next/slice-999-x.md#anker)
[d](../sibling-open/slice-999-x.md)
[e](../open/slice-999-x.mdx)
[f](../done/slice-999-x.md)
[g](../open/slice-998-y.md)'
  ist="$(cat docs/reviews/tiefen.md)"
  [ "$ist" = "$erwartet" ] || { echo "Ist-Bestand weicht ab:"; echo "$ist"; return 1; }
}

@test "docs/reviews: Link-Syntax als Zitat in einem Code-Span wird mitersetzt, der reine Pfad daneben nicht (benannte Grenze, ADR-0070 Festlegung 1 — bekommt ein Traeger eine Kontext-Erkennung, faellt dieser Fall: Trigger 6 der ADR)" {
  load_functions "$DOGFOOD"
  cd "$TMP"
  mkdir -p docs/reviews
  printf '%s\n' '`[a](../plan/planning/open/slice-999-x.md)` und `docs/plan/planning/open/slice-999-x.md`' > docs/reviews/zitat.md
  run rewrite_incoming_nach_baum docs/reviews/zitat.md "slice-999-x.md" "open" "next"
  [ "$status" -eq 0 ]
  erwartet='`[a](../plan/planning/next/slice-999-x.md)` und `docs/plan/planning/open/slice-999-x.md`'
  [ "$(cat docs/reviews/zitat.md)" = "$erwartet" ] || { echo "Ist-Bestand:"; cat docs/reviews/zitat.md; return 1; }
}

@test "done: jede Form wird weiter ersetzt — Link, reiner Pfad-Span, Operand, Block und Fliesstext derselben Datei (ADR-0070 Fitness 5, die Form-Regel gilt nur unter docs/reviews/)" {
  load_functions "$DOGFOOD"
  cd "$TMP"
  mkdir -p docs/plan/planning/done
  form_probe docs/plan/planning/done/probe.md
  run rewrite_incoming_nach_baum docs/plan/planning/done/probe.md "slice-999-x.md" "open" "next"
  [ "$status" -eq 0 ]
  ! grep -q 'open/slice-999-x\.md' docs/plan/planning/done/probe.md
  [ "$(grep -c 'next/slice-999-x\.md' docs/plan/planning/done/probe.md)" -eq 5 ]
}

@test "docs/reviews: dieselbe Probe unter dem Ersetzer fuer jede Form faerbt alle fuenf Vorkommen um (Kontrolle: die Probe trennt Link-Form von den vier anderen)" {
  load_functions "$DOGFOOD"
  cd "$TMP"
  form_probe probe.md
  rewrite_incoming_in_file probe.md "slice-999-x.md" "open" "next"
  [ "$(grep -c 'next/slice-999-x\.md' probe.md)" -eq 5 ]
}

@test "eingehend_ausgenommene_pfade: .harness/baseline und docs/plan/adr drin, docs/reviews NICHT (ADR-0042 Festlegung 2, ADR-0070 Festlegung 2)" {
  for fassung in "${FASSUNGEN[@]}"; do
  load_functions "$fassung"
  run eingehend_ausgenommene_pfade
  [ "$status" -eq 0 ]
  printf '%s\n' "$output" | grep -qF ':!.harness/baseline'
  printf '%s\n' "$output" | grep -qF ':!docs/plan/adr'
  ! printf '%s\n' "$output" | grep -q 'docs/reviews'
  done
}

# Die LISTE selbst ist damit bats-gedeckt (oben). Was main() daraus MACHT — sie
# an `git grep` uebergeben, im Zwei-Commit-Ablauf, Zeitdokumente real
# nachziehen — braucht ein echtes `git`-Repo: main() ruft `git mv`/`git grep`,
# und das gepinnte BATS_IMAGE fuehrt kein `git`-Binary mit. Der Beleg dafuer
# steht darum NICHT hier, sondern an zwei anderen Orten: im Skriptkopf
# (harness/tools/slice-mv.sh) und, fuer BEIDE Richtungen an einem echten Move im
# gebootstrappten Ziel, in harness/tools/full-smoke.sh.

# Der Ersetzungs-KERN, den beide Fassungen teilen MUESSEN. Ein Fall trifft nur die
# Entscheidungen, die er ausloest; eine einseitig entfernte Entscheidung bliebe
# ueber jedem Fall gruen. Verglichen werden darum die Funktionsruempfe.
KERN=(re_escape rewrite_incoming_in_file rewrite_incoming_bare_in_file rewrite_outgoing_bare_in_file)

# funktions_rumpf liest den Rumpf EINER Funktion: von der Definitionszeile in
# Spalte 0 bis zur ersten schliessenden Klammer in Spalte 0. Die Funktionen
# des Kerns tragen keine inneren Kommentare und keine Verschachtelung auf
# Spalte 0 — die zwei Grenzen des Lesers stehen hier, statt still zu gelten.
funktions_rumpf() {  # $1=datei $2=funktion
  awk -v f="$2" '
    $0 ~ "^" f "\\(\\) \\{" { im = 1 }
    im { print }
    im && /^}/ { exit }
  ' "$1"
}

@test "kopplung: die Funktionen der Liste KERN sind in beiden Fassungen wortgleich (weissraum-normalisiert)" {
  for fn in "${KERN[@]}"; do
    a="$(funktions_rumpf "$DOGFOOD" "$fn" | tr -s '[:space:]' ' ')"
    b="$(funktions_rumpf "$EMITTIERT" "$fn" | tr -s '[:space:]' ' ')"
    # Vorbedingung: ueber einem leeren Rumpf waere "beide gleich" still gruen.
    [ -n "$a" ] || { echo "Rumpf von $fn in $DOGFOOD nicht gelesen — der Vergleich misst dann nichts"; return 1; }
    [ -n "$b" ] || { echo "Rumpf von $fn in $EMITTIERT nicht gelesen — der Vergleich misst dann nichts"; return 1; }
    # Weissraum-normalisiert: WO der Rumpf umbricht, ist gleichgueltig; WAS er
    # entscheidet, nicht. Ein entferntes /g oder eine verengte Zeichenklasse
    # fallen hier, auch wenn kein Fall sie trifft.
    [ "$a" = "$b" ] || { echo "Rumpf von $fn weicht zwischen den zwei Fassungen ab:"; echo "  Dogfood:   $a"; echo "  emittiert: $b"; return 1; }
  done
}
