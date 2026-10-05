# Review: archive-welle altbestand, schreibender Pfad (b64b75b1..f7583215)

Reviewer-Lauf gegen den Plan `slice-archive-welle-altbestand-hat-einen-schreibenden-pfad`, ADR-0041, ADR-0033, ADR-0077 und `harness/sensors/archive-welle.md`. Nicht geprüft: die DoD (Verifier).

## Findings

| kategorie | quelle | pfad | befund | verifizierbar | klasse |
|---|---|---|---|---|---|
| INFO | Maintainability | `internal/archive/anwenden.go:89-92` | Der Guard am Anfang von `Anwenden` (Plan-Datei unter `altbestand`) wiederholt, was `sperren` vorher abfängt. Keine Mutation und kein Test erreichen ihn allein: der Lauf kommt nur durch `archiveWelleLauf`, und der bricht vorher mit Exit 3 ab. Er ist ein Gürtel, kein Zahn. | nein | Doppel-Guard ohne eigenen Zahn |
| INFO | AGENTS.md §3.6 | `b64b75b1` | Der Commit baut nicht (Backtick im Raw-String des Usage-Textes). `c5870254` repariert das einen Commit später. `git bisect` muss b64b75b1 überspringen (`git bisect skip`). Es gibt keine Folge für den Baum oder die Gates, nur für diesen einen Bisect-Schritt. | ja (Build an b64b75b1) | Commit nicht einzeln baubar |

HIGH, MEDIUM und LOW: keine.

## Geprüft, ohne Befund

1. **Akzeptanzkriterien (1)-(6) am Code.** Vorschau und Lauf teilen ein `Bestand`: `archiveWelleLauf` ruft `Vorschau` einmal und reicht `bericht.Bestand` an `Anwenden` weiter. Die Einsammel-Gleichheit ist damit strukturell und nicht nur per Test gegeben (Test und Fall 506 binden sie zusätzlich). Reviews werden ohne Stub entfernt, der Verweis-Nachzug läuft über denselben `inhaltsSchritt` wie bei der Welle, und es entstehen zwei Commits mit dem reinen Move zuerst (Test `TestArchiveWelleAltbestand…` und die bestehende Mechanik).
2. **Sperren.** `archiveWelleLauf` gibt bei jeder Sperre (`haenger`, `archiviert`, `altbestand-plan`, `unsauber`, `kein-slice`) Exit 3 zurück, bevor `Anwenden` aufgerufen wird. Der Pfad "schon geschrieben, dann gesperrt" existiert nicht, auch `MkdirAll` und `Mv` liegen hinter dem Guard. Die Tests für `archiviert`, `haenger` und `altbestand-plan` belegen das durch einen leeren Git-Aufruf-Log und einen unveränderten Baum-Abdruck. `unsauber` und `kein-slice` laufen über denselben `len(Sperren) > 0`-Zweig und haben nur Vorschau-Tests, keine Lauf-Tests. Das ist strukturell gedeckt.
3. **Welle-Pfad.** `sperren` trägt `altbestand-plan` nur im `else` von `welleGebunden`. `Anwenden` prüft für Welle-Kennungen unverändert `EinPlanVorhanden`, und die Fortschrittszeile bleibt bei vorhandenem Plan gleich. `make test-go` EXIT 0, die Welle-Tests sind unverändert grün.
4. **Gelöschte Mutation 395.** Ihre Eigenschaft war "Vorschau meldet die Sperre, an der der Lauf abbräche". Die Sperre `kein-schreib-pfad` entfällt mit ihrem Gegenstand. Der Nachfolger derselben Kopplung, die geteilte Funktion `altbestandFremdesPlanBild` in `sperren` und `Anwenden`, hält Fall 508 (`TestArchiveWelleAltbestandSperrtImLaufBeiPlanDatei`). Es ist kein Zahn verloren gegangen.
5. **Fälle 504-508.** Alle fünf gefahren: `make mutate MUTATE_CASES=…` ergibt `5 ok, 0 Befund(e)`, `git status` danach sauber. Jeder benannte Test wird rot. 504 und 505 treffen den stillen Pfad (Lauf ohne Sperre, Baum bleibt gültig). 506 und 507 färben beide `…SchreibtDieMengeDerVorschau`; die Doppelung ist gewollt, weil die zwei Mutationen zwei verschiedene Stellen im selben Test bindet (Menge und Stub-Zeile). Die Gegenprobe mit `t.Skip` habe ich nicht gefahren. 507 behauptet keine Exklusivität.
6. **Commit-Nachrichten.** Alle vier nennen `ADR-0041`. Die Laufkommentare für den Schlüssel tragen `, ADR-0041` im Suffix, die Welle-Messages bleiben unverändert.
7. **Doku-Ist-Stand (Grenze 4, 6, 7).** Sie stimmen mit dem Code überein: `altbestand-plan` ist in §Sperren die einzige neue Kennung, `kein-schreib-pfad` ist entfernt, `haenger` bleibt, die Stub-Felder entsprechen `schreibeStubs`. Die benannten Lücken (realer Bestandslauf wegen `haenger`; Stub über nachgebildete Vorlage, echte Zeile nur in `test/archiv-stub-vorlagen.bats`) sind korrekt beschrieben.

## Sensoren

- `make test-go`: EXIT 0.
- `make mutate MUTATE_CASES="504… 505… 506… 507… 508…"`: EXIT 0, 5 ok.
- `make gates`: EXIT 0.
