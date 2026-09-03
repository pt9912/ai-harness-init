#!/usr/bin/env bats
# archive-welle.bats — Zaehne fuer harness/tools/archive-welle.sh.
#
# Alle Faelle sourcen das Skript (BASH_SOURCE-Waechter unterdrueckt main()) und
# rufen die reinen Funktionen ueber synthetischen Proben auf. main() selbst
# braucht ein echtes `git`-Repo UND Docker — das gepinnte BATS_IMAGE fuehrt
# keins von beiden; sein Beleg steht darum im Skriptkopf, nicht hier (siehe
# Dateiende).

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  SCRIPT="$REPO/harness/tools/archive-welle.sh"
  TMP="$BATS_TEST_TMPDIR"
}

load_functions() {
  # shellcheck source=/dev/null
  source "$SCRIPT"
}

kopf() {  # $1=datei $2=welle-feld-inhalt
  printf '# Slice slice-901: Ein Titel\n\n**Welle:** %s\n' "$2" > "$1"
}

# ---- Einsammel-Regel: die drei Klassen ------------------------------------

@test "Klasse mitglied: das Welle-Feld nennt die Welle" {
  load_functions
  kopf "$TMP/a.md" '[welle-42](welle-42-titel.md).'
  [ "$(klasse_von "$TMP/a.md" welle-42)" = "mitglied" ]
}

@test "Klasse wellenlos: das Welle-Feld sagt 'ohne Welle'" {
  load_functions
  kopf "$TMP/a.md" 'ohne Welle — die Closure-Bedingung ist die DoD.'
  [ "$(klasse_von "$TMP/a.md" welle-42)" = "wellenlos" ]
}

@test "Klasse fremd: das Welle-Feld nennt eine ANDERE Welle — sie bleibt liegen" {
  load_functions
  kopf "$TMP/a.md" '[welle-43](../welle-43-offen.md).'
  [ "$(klasse_von "$TMP/a.md" welle-42)" = "fremd" ]
}

@test "Klasse fremd: ein leeres Welle-Feld ist keine Wellenlosigkeit" {
  load_functions
  kopf "$TMP/a.md" '—'
  [ "$(klasse_von "$TMP/a.md" welle-42)" = "fremd" ]
}

@test "Ziffern-Grenze: welle-1 trifft welle-14 nicht, welle-14 trifft die Langform" {
  load_functions
  kopf "$TMP/a.md" '[welle-14](welle-14-re-baseline.md).'
  [ "$(klasse_von "$TMP/a.md" welle-1)" = "fremd" ]
  [ "$(klasse_von "$TMP/a.md" welle-14)" = "mitglied" ]
}

@test "Ziffern-Grenze: die Kurzform trifft die Langform des Welle-Felds" {
  load_functions
  kopf "$TMP/a.md" '[welle-02-fetch-und-readme](welle-02-fetch-und-readme.md).'
  [ "$(klasse_von "$TMP/a.md" welle-02)" = "mitglied" ]
}

# ---- Einsammel-Regel: die Review-Reports -----------------------------------

@test "Nummer: der Buchstaben-Suffix eines Re-Schnitts gehoert zur Identitaet" {
  load_functions
  [ "$(slice_nummer slice-170-titel.md)" = "170" ]
  [ "$(slice_nummer slice-001a-cli-skeleton.md)" = "001a" ]
  [ "$(slice_nummer slice-001b-cli-flags.md)" = "001b" ]
}

@test "Review-Reports: die Suffix-Grenze — slice-001 zieht slice-001a NICHT mit" {
  load_functions
  mkdir -p "$TMP/rev"
  : > "$TMP/rev/2026-01-01-slice-001-review.md"
  : > "$TMP/rev/2026-01-02-slice-001a-review.md"
  : > "$TMP/rev/2026-01-03-slice-001b-review.md"
  run reviews_zu_nummer 001 "$TMP/rev"
  [ "$status" -eq 0 ]
  [ "$(printf '%s\n' "$output" | grep -c .)" -eq 1 ]
  [[ "$output" == *"slice-001-review.md"* ]]
  run reviews_zu_nummer 001a "$TMP/rev"
  [ "$(printf '%s\n' "$output" | grep -c .)" -eq 1 ]
  [[ "$output" == *"slice-001a-review.md"* ]]
}

# ---- Vorbedingung: der saubere Arbeitsbaum --------------------------------

@test "Arbeitsbaum: ein leeres Porcelain nennt keinen Grund" {
  load_functions
  # Ueber `run`, nicht ueber eine Kommando-Ersetzung: die verschluckt den
  # Status, und ein Fall, der eine LEERE Ausgabe erwartet, waere sonst auch
  # dann gruen, wenn es die Funktion gar nicht gibt.
  run bash -c "printf '' | { source '$SCRIPT'; unsauber_grund; }"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "Arbeitsbaum: UNTRACKTE Dateien allein sind schon ein Grund" {
  load_functions
  run bash -c "printf '?? FREMDE-UNTRACKED-DATEI.txt\n?? scratch/notiz.md\n' | { source '$SCRIPT'; unsauber_grund; }"
  [ "$status" -eq 0 ]
  [ "$output" = "2 untrackte Datei(en)" ]
}

@test "Arbeitsbaum: getrackte und untrackte Klasse werden getrennt genannt" {
  load_functions
  run bash -c "printf ' M harness/tools/x.sh\nA  neu.md\n?? scratch.txt\n' | { source '$SCRIPT'; unsauber_grund; }"
  [ "$status" -eq 0 ]
  [ "$output" = "2 Aenderung(en) an getrackten Dateien und 1 untrackte Datei(en)" ]
}

# ---- Haenger-Vorpruefung: Suchraum und Filter -----------------------------

@test "Haenger-Suchraum: docs/reviews ist NICHT ausgenommen, die vendored Baseline schon" {
  load_functions
  run grep_suchraum
  [ "$status" -eq 0 ]
  [[ "$output" == *':!.harness/baseline'* ]]
  # Ein Report verlinkt den anderen; links/anchors pruefen das Verzeichnis.
  [[ "$output" != *'docs/reviews'* ]]
}

@test "Haenger-Filter: ein BLEIBENDER Report, der auf einen verschwindenden zeigt, ist ein Haenger" {
  load_functions
  weg="docs/reviews/2026-07-22-slice-032-review.md docs/plan/planning/done/slice-032-x.md"
  run bash -c "printf 'docs/reviews/2026-07-23-slice-034-review.md\n' | { source '$SCRIPT'; haenger_filtern 2026-07-22-slice-032-review.md '$weg'; }"
  [ "$status" -eq 0 ]
  [ "$output" = "docs/reviews/2026-07-23-slice-034-review.md -> 2026-07-22-slice-032-review.md" ]
}

@test "Haenger-Filter: wer selbst verschwindet, ist kein Haenger (Gegenprobe)" {
  load_functions
  weg="docs/reviews/a.md docs/reviews/b.md docs/plan/planning/done/slice-032-x.md"
  run bash -c "printf 'docs/reviews/a.md\ndocs/plan/planning/done/slice-032-x.md\n' | { source '$SCRIPT'; haenger_filtern b.md '$weg'; }"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

# ---- Stub-Form ------------------------------------------------------------

@test "Stub-Form: Zeiger da und keine Abschnittsueberschrift -> gruen" {
  load_functions
  printf '# slice-901 — T\n\n> **ARCHIVIERT** — Volltext:\n> `unzip -p x/archiv.zip y`\n\n**Welle:** ohne Welle\n' > "$TMP/s.md"
  run stub_form_ok "$TMP/s.md"
  [ "$status" -eq 0 ]
}

@test "Stub-Form: fehlender Archiv-Zeiger faerbt rot" {
  load_functions
  printf '# slice-901 — T\n\n**Welle:** ohne Welle\n' > "$TMP/s.md"
  run stub_form_ok "$TMP/s.md"
  [ "$status" -eq 1 ]
  [[ "$output" == *"keinen Archiv-Zeiger"* ]]
}

@test "Stub-Form: stehengebliebene Abschnittsueberschrift faerbt rot — die tragende Haelfte" {
  load_functions
  printf '# slice-901 — T\n\n> **ARCHIVIERT** — Volltext:\n> `unzip -p x/archiv.zip y`\n\n## 1. Ziel\n\nVolltext.\n' > "$TMP/s.md"
  run stub_form_ok "$TMP/s.md"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Abschnittsueberschriften"* ]]
}

# ---- Verweis-Nachzug, beide Formen ---------------------------------------

@test "eingehend mit Praefix: jede Aufstiegstiefe und jeder Kontext wandert nach done/<welle-id>/" {
  load_functions
  cat > "$TMP/probe.md" <<'EOF'
../../docs/plan/planning/done/slice-901-x.md
../done/slice-901-x.md
(done/slice-901-x.md)
`done/slice-901-x.md`
done/slice-901-x.md
EOF
  rewrite_incoming_in_file "$TMP/probe.md" "slice-901-x.md" "done" "done/welle-42"
  [ "$(grep -c 'done/welle-42/slice-901-x\.md' "$TMP/probe.md")" -eq 5 ]
}

@test "eingehend mit Praefix: Teilstring-Falle — slice-90 bewegt slice-901 nicht" {
  load_functions
  printf '[a](../done/slice-90-x.md)\n[b](../done/slice-901-y.md)\n' > "$TMP/probe.md"
  rewrite_incoming_in_file "$TMP/probe.md" "slice-90-x.md" "done" "done/welle-42"
  grep -qF '../done/welle-42/slice-90-x.md' "$TMP/probe.md"
  grep -qF '../done/slice-901-y.md' "$TMP/probe.md"
}

@test "eingehend geschwister-relativ: ein Ziel OHNE Verzeichnis-Segment bekommt das Praefix" {
  load_functions
  printf '[a](slice-901-x.md) und [b](slice-901-x.md)\n' > "$TMP/probe.md"
  run rewrite_bare_sibling_in_file "$TMP/probe.md" "slice-901-x.md" "welle-42/"
  [ "$status" -eq 0 ]
  [ "$output" = "2" ]
  [ "$(grep -c 'welle-42/slice-901-x\.md' "$TMP/probe.md")" -eq 1 ]
}

@test "eingehend geschwister-relativ: ein Ziel MIT Verzeichnis-Segment bleibt unberuehrt (Gegenprobe)" {
  load_functions
  printf '[a](../done/slice-901-x.md)\n' > "$TMP/probe.md"
  run rewrite_bare_sibling_in_file "$TMP/probe.md" "slice-901-x.md" "welle-42/"
  [ "$status" -eq 0 ]
  [ "$output" = "0" ]
  grep -qF '[a](../done/slice-901-x.md)' "$TMP/probe.md"
}

@test "eingehend aufsteigend: '](../<datei>)' im Stub bekommt das Welle-Segment" {
  load_functions
  # Genau die Form, die feld_hervorgegangen() fuer einen flach in done/
  # liegenden Folge-Slice selbst in den Stub schreibt.
  printf '**Hervorgegangen:** [slice-901](../slice-901-x.md)\n' > "$TMP/stub.md"
  run rewrite_parent_relative_in_file "$TMP/stub.md" "slice-901-x.md" "welle-42"
  [ "$status" -eq 0 ]
  [ "$output" = "1" ]
  grep -qF '[slice-901](../welle-42/slice-901-x.md)' "$TMP/stub.md"
}

@test "eingehend aufsteigend: Geschwister-Form und Praefix-Form bleiben unberuehrt (Gegenprobe)" {
  load_functions
  printf '[a](slice-901-x.md)\n[b](../../done/slice-901-x.md)\n' > "$TMP/probe.md"
  run rewrite_parent_relative_in_file "$TMP/probe.md" "slice-901-x.md" "welle-42"
  [ "$status" -eq 0 ]
  [ "$output" = "0" ]
  grep -qF '[a](slice-901-x.md)' "$TMP/probe.md"
  grep -qF '[b](../../done/slice-901-x.md)' "$TMP/probe.md"
}

# ---- Stub-Felder ----------------------------------------------------------

@test "Titel und Nummer kommen aus H1 und Dateiname" {
  load_functions
  printf '# Slice slice-901: Ein Mitglied der Welle\n' > "$TMP/a.md"
  [ "$(titel_von "$TMP/a.md")" = "Ein Mitglied der Welle" ]
  [ "$(slice_nummer slice-901-mitglied.md)" = "901" ]
}

@test "Titel: die Welle-Plan-Form wird ebenso abgeraeumt" {
  load_functions
  printf '# Welle welle-42: Der Titel der Welle\n' > "$TMP/a.md"
  [ "$(titel_von "$TMP/a.md")" = "Der Titel der Welle" ]
}

@test "Titel: die zwei Gedankenstrich-Formen tragen auch unter LC_ALL=C" {
  load_functions
  printf '# slice-901 — Ein Titel mit Gedankenstrich\n' > "$TMP/s.md"
  printf '# welle-42 — Der Titel der Welle\n' > "$TMP/w.md"
  run bash -c "export LC_ALL=C; source '$SCRIPT'; titel_von '$TMP/s.md'; titel_von '$TMP/w.md'"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Ein Titel mit Gedankenstrich" ]
  [ "${lines[1]}" = "Der Titel der Welle" ]
}

@test "Geschlossen: das Datum der Closure-Notiz sticht den Ersatzwert" {
  load_functions
  printf '# x\n\n**Rolle:** Planner. **Datum:** 2026-08-01.\n' > "$TMP/a.md"
  [ "$(geschlossen_datum "$TMP/a.md" 2026-09-03)" = "2026-08-01" ]
}

@test "Geschlossen: ohne Closure-Notiz-Datum gilt der Ersatzwert (Grenze 4)" {
  load_functions
  printf '# x\n\n**Autor:** Planner. **Datum:** 2026-07-01.\n' > "$TMP/a.md"
  [ "$(geschlossen_datum "$TMP/a.md" 2026-09-03)" = "2026-09-03" ]
}

@test "Hervorgegangen: die Kennungen der zwei Ausgangs-Zeilen werden Anker-Links" {
  load_functions
  mkdir -p "$TMP/r/docs/plan/adr" "$TMP/r/docs/plan/planning/open"
  : > "$TMP/r/docs/plan/adr/0028-anweisungssatz.md"
  : > "$TMP/r/docs/plan/planning/open/slice-902-x.md"
  cat > "$TMP/r/n.md" <<'EOF'
- **Beobachtungs-Register (`../observations.md`):** `BEO-003` auf 5× erhöht, `ADR-0028` gilt.
- **Folge-Slices:** [slice-902](../open/slice-902-x.md) (Titel).
EOF
  cd "$TMP/r"
  run feld_hervorgegangen n.md welle-42
  [ "$status" -eq 0 ]
  [[ "$output" == *'[`BEO-003`](../../observations.md)'* ]]
  [[ "$output" == *'[`ADR-0028`](../../../adr/0028-anweisungssatz.md)'* ]]
  [[ "$output" == *'[slice-902](../../open/slice-902-x.md)'* ]]
}

@test "Hervorgegangen: ohne Ausgangs-Zeilen steht '— keine —', kein leeres Feld" {
  load_functions
  printf '# x\n\nKein Ausgang.\n' > "$TMP/a.md"
  [ "$(feld_hervorgegangen "$TMP/a.md" welle-42)" = "— keine —" ]
}

# ---- Kopplung an die vendored Vorlage ------------------------------------

@test "Stub entsteht aus der vendored Vorlage und besteht die Form-Pruefung" {
  load_functions
  cd "$REPO"
  tdir="$(templates_dir)"
  ziel="$TMP/slice-901-x.md"
  stub_aus_vorlage "$tdir/archiv-stub-slice.template.md" "$ziel" welle-42 \
    "d/welle-42/archiv.zip" "d/welle-42/slice-901-x.md" \
    "s#<NNN>#901#g" "s#<Titel>#Ein Titel#g" \
    "s#<welle-id | ohne Welle>#ohne Welle#g" \
    "s#<JJJJ-MM-TT>#2026-08-01#g" \
    "s#<BEO-\*, ADR-\*, Folge-Slice — oder .— keine —.>#— keine —#g"
  run stub_form_ok "$ziel"
  [ "$status" -eq 0 ]
  # Kein Platzhalter und kein Bedienhinweis der Vorlage bleibt stehen.
  ! grep -q '<' "$ziel"
  ! grep -q 'Template-Hinweis' "$ziel"
  ! grep -q 'BEDIENHINWEIS' "$ziel"
  grep -qF '**Archiviert mit:** welle-42 · **Geschlossen:** 2026-08-01' "$ziel"
}

@test "Welle-Stub entsteht aus der vendored Vorlage und besteht die Form-Pruefung" {
  load_functions
  cd "$REPO"
  tdir="$(templates_dir)"
  ziel="$TMP/welle-42-titel.md"
  stub_aus_vorlage "$tdir/archiv-stub-welle.template.md" "$ziel" welle-42 \
    "d/welle-42/archiv.zip" "d/welle-42/welle-42-titel.md" \
    "s#<Titel>#Ein Titel#g" "s#<JJJJ-MM-TT>#2026-09-01#g" \
    "s#<welle-id>-results\.md#[welle-42-results.md](../welle-42-results.md)#g" \
    "s#<N Slices, M Reviews>#2 Slices, 1 Reviews#g"
  run stub_form_ok "$ziel"
  [ "$status" -eq 0 ]
  ! grep -q '<' "$ziel"
  grep -qF '**Archivierte Vorgänge:** 2 Slices, 1 Reviews' "$ziel"
}

# main() — Einsammeln ueber dem echten Baum, die Zwei-Commit-Sequenz, das
# Packen im gepinnten Bild, das Loeschen der Review-Reports und JEDER
# fail-closed-Ausgang brauchen `git` und `docker`; das gepinnte BATS_IMAGE
# fuehrt beides nicht. Der Beleg dafuer steht darum im Skriptkopf
# (harness/tools/archive-welle.sh, Abschnitt BELEG) als Lauf ueber einem
# eigenen Scratch-Repo; dort steht auch die Aufzaehlung der Ausgaenge samt dem
# Kommando, das sie zaehlt — eine zweite Auszaehlung hier driftete gegen sie.
# Was die Faelle oben pruefen, sind die reinen Funktionen, auf denen die
# Ausgaenge urteilen: unsauber_grund (Vorbedingung), grep_suchraum und
# haenger_filtern (Haenger-Vorpruefung), stub_form_ok (Stub-Form).
