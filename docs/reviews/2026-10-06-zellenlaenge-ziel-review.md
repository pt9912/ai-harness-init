# Review — slice-zellenlaenge-sensor-geht-ins-ziel

Rolle: Reviewer · Range `4657caef..HEAD` (b81fbc47, 6a521d46, 41ace78c) · Bezug: LH-QA-01, MR-054/055/071, AGENTS.md §3.6/§3.7

## Findings

1. **LOW** · quelle AGENTS.md §3.7 (Kommentar beschreibt, was da ist) · pfad `internal/emit/templates/d-check.yml:66-67` ·
   befund: Der Kopfkommentar sagt, die Dogfood-Fassung wähle „einen Unterabschnitt, den die Vorlage nicht führt". Die
   Dogfood-`.d-check.yml:144` führt denselben Selektor `section: "## Sensors (Feedback-Gates)"`; der Unterschied liegt in den
   Schwellen (150/260) und im Kommentar, nicht im Selektor. Die Aussage ist falsch. · verifizierbar: nein ·
   klasse: Kommentar-Aussage über Nachbar-Konfiguration ungemessen

2. **INFO** · quelle AGENTS.md §3.6 · pfad `test/mutations/` (kein Fall mit `expect: … (Tut was)`) ·
   befund: Die E2E-Stufe führt die Spalte „Tut was" mit Gegenbeispiel und Gegenprobe (Deklaration sagt „je Spalte"; das trifft zu),
   aber nur der Go-Test (Fall 517) hält die Schwelle dieser Spalte als Mutation. Ein Fall, der die Stufen-Meldung der Spalte
   „Tut was" erwartet, fehlt, daher ist dieser Zweig der Stufe nicht „gelistet". Die Deklaration sagt nichts Falsches. ·
   verifizierbar: ja (`make mutate`) · klasse: Stufen-Zweig ohne eigenen Mutations-Fall

## Gegenproben (selbst gefahren)

- `make mutate MUTATE_CASES="514-… 515-… 295-… 516-… 517-…"` → `5 ok, 0 Befund(e)`.
- **515**: Mutation (Vertrag 2000) angewandt, Zweige „Gegenbeispiel Vertrag" in `zellenlaenge_im_ziel` ausschließlich für
  `spalte=Vertrag` ausgeschaltet → `make full-smoke` EXIT 0 (grün = der Zweig bindet allein). Zwischenlauf mit einem
  Plumbing-Fehler meiner Schwächung (`grep|sed` unter `set -e`) war rot, danach korrigiert.
- **514**: Mutation (Modul fehlt) + dieselbe Schwächung → EXIT 2, rot durch den Zweig „Tut was" (`Zellenlaenge-Gegenbeispiel
  (Tut was)`). Das ist ein struktureller Nebeneffekt der gemeinsamen Stelle (Modul-Liste färbt beide Spalten); der `expect`
  behauptet keine Exklusivität. Kein Befund.
- Gegenprobe-Schwächung der Stufe (`^(structure:|modules:.*structure)` plus `cmp -s`): beide Wege (Modul-Liste, Block) werden
  vom Prüfsatz erfasst; der Lauf 515 zeigt „Gegenprobe (Vertrag/Tut was) belegt". Bäume zurückgesetzt (`git status` sauber).

## Geprüft, ohne Befund

- (a) `structure` in `modules`, Block: Selektor, beide Spalten, 200, kein `exempt-paths`; `modules`-Zeile in 295/514/emit_test konsistent;
  Zahl 80 des längsten Vorlagen-Zellsatzes gemessen (80); keine Chronik im Kommentar außer Finding 1.
- (b) sed-Muster 295/514/515/516/517 treffen den Quellbestand (alle fünf Fälle rot, d. h. Mutation wirksam).
- (c) Stufe misst, was Deklaration und `docs/user/e2e-abdeckung.md` behaupten (sprachloses Ziel, zwei Spalten, grüner Start,
  Gegenbeispiel, Gegenprobe, Rücknahme); die NICHT-gemessen-Grenze steht am selben Ort (Deklaration und Stufen-Kopf).
- (d) `modul_zahn_alte_module_gruen`: das `sed` ersetzt weiterhin die ganze Liste durch `[links, anchors]` (die alte Menge);
  die Zähne messen unverändert „ERST das neue Modul findet es". Ein Nicht-Treffer des Musters bliebe fail-closed (Verletzung bliebe rot
  → FEHLER). Alle sechs Aufrufer (matrix, matrix-downward, matrix-aussen, ids, matrix-MR, spans) unberührt. Keine Gate-Senkung.
- (e) `.dockerignore` schließt `.harness` aus → Go-Test kann die Vorlage nicht lesen; die bats-Fassung hält Spaltennamen
  gegen Kopfzeilen der vendorten Vorlage und den Selektor (zwei Tests, Fall 516 rot) — nicht schwächer als die Plan-Zusage.
