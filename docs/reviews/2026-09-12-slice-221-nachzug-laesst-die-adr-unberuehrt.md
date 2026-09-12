# Review slice-221 — Der Verweis-Nachzug lässt die `Accepted`-ADR unberührt

**Rolle:** Reviewer · **Datum:** 2026-09-12 · **Commit:** `3fb64279` (11 Dateien, +227/−59) · **Plan:** [`slice-221`](../plan/planning/done/slice-221-nachzug-laesst-die-adr-unberuehrt.md) · **Constraint:** [`ADR-0042`](../plan/adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 2/5, Folgepflicht 1 · **Hard Rules:** [`AGENTS.md`](../../AGENTS.md) §3.6, §3.7 · [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)

## Findings

### HIGH-1 — Die Trennung der zwei Suchräume ist von keinem Test und keinem Mutations-Fall gehalten

`quelle` [`AGENTS.md`](../../AGENTS.md) §3.6, [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) · `pfad` `internal/archive/scan.go:168` · `verifizierbar` ja · `klasse` Trennung zweier Suchräume ohne Wächter auf die Trennung
`befund` Zieht man `Haenger` auf den verengten Nachzug-Suchraum — der Fehler, den §1 des Plans als *„und der Lauf bliebe grün"* benennt —, bleibt die gesamte Go-Suite grün; kein Fall in `test/mutations/` deckt die Trennung. Der Kommentar `scan.go:80–89` sagt das Gegenteil zu (*„`Haenger` … behaelt seinen vollen Suchraum … auch einen aus einer ADR"*) und nennt `TestHaengerFindetVerweisAusReviewReport` und `test/mutations/233-…` als wirksam — beide messen `docs/reviews/**`, das in **beiden** Suchräumen liegt und darum unter dieser Mutation nicht rot werden kann. Wirkung: die drei `ADR → Report`-Zeilen der `[haenger]`-Sperre verschwinden lautlos, und der schreibende Lauf archiviert einen Report, den eine eingefrorene ADR noch verlinkt. Beleg: `sed -i '168s/Suchraum(/SuchraumNachzug(/' internal/archive/scan.go && make test-go` → alle acht Pakete `ok` (gemessen, danach zurückgesetzt).

### MEDIUM-1 — Der Shell-Zahn misst die Funktion, und der benannte Ersatz-Beleg deckt die neue Hälfte nicht

`quelle` [`AGENTS.md`](../../AGENTS.md) §3.6 · `pfad` `test/slice-mv.bats:116`, `harness/tools/slice-mv.sh:229` · `verifizierbar` ja · `klasse` Zahn misst die reine Funktion statt der Verdrahtung; benannter Ersatz-Beleg deckt die neue Hälfte nicht
`befund` Ersetzt man in `main()` `"${in_pathspec[@]}"` wieder durch die harte Pathspec, bleibt `make test-bats` grün (272 Fälle, 0 `not ok`) — die Funktion wird dann nicht mehr gelesen. Für diese Hälfte verweist die Datei auf den Skriptkopf-BELEG; der misst einen `slice-069`-Move aus slice-144 über einer Ausnahmeliste, die allein `.harness/baseline` führte — `docs/plan/adr` kommt darin nicht vor.

### LOW-1 — Punkt 6 des Sensor-Dokuments erzählt den Übergang statt den Zustand

`quelle` [`AGENTS.md`](../../AGENTS.md) §3.7 (dessen Geltungsbereich Sensor-Prosa nicht erreicht — darum LOW) · `pfad` `harness/sensors/archive-welle.md:88–92` · `verifizierbar` nein · `klasse` Lebendes Artefakt trägt die Entstehung seiner eigenen Änderung
`befund` *„band den ersten Archiv-Move zusätzlich daran … ; mit dem Ausschluss … ist diese Bedingung erfüllt"* steht im Präteritum über eine Bedingung, die heute steht. Sachlich ist die Aussage richtig.

## Negativbefunde

- **Trennung und echte Aufrufer (Go)** — ohne Befund: `Haenger` (`scan.go:168`) ruft `Suchraum`, `VerweisFund`/`Nachziehen` (`refs.go:92,230`) rufen `SuchraumNachzug`; die gemeinsame Liste ist unverändert, und `vorschau.go:45,48`/`anwenden.go:164` rufen genau diese drei — ein vierter Leser existiert nicht.
- **Beide gelieferten Gegenbeispiele selbst gefahren** — ohne Befund: `312-…` → `--- FAIL: TestVerweisFundUndNachziehenUebergehenAcceptedADR` (plus `TestZuStagenNenntNurArchivStubsUndNachgezogene`); `313-…` → `not ok 248`; beide zurückgesetzt, Baum sauber.
- **Kalibrierung `docs/reviews/**`** — ohne Befund: `TestVerweisFundUndNachziehenUebergehenAcceptedADR` hält ADR-Ausschluss und Report-Aufnahme im selben Lauf über **beide** Leser (Fund-Zahl, geschriebene Datei, beide Datei-Inhalte); der bats-Fall hält dieselbe Nicht-Mitgliedschaft.
- **Sperre fällt, `[haenger]` bleibt** — ohne Befund: `--vorschau altbestand` führt **0** `docs/plan/adr`-Zeilen als Nachzugs-Ziel und weiter **3** `ADR → Report`-Zeilen unter `[haenger]`; die zwei sind nicht verwechselt.
- **Sensor-Dokumente gegen die Ziel-Form** — ohne Befund: `archive-welle.md` trägt alle fünf Abschnitte, `slice-mv.md` die drei nicht-bedingten (die zwei fehlenden sind Bestand, von diesem Diff nicht berührt); beide Aussagen zur neuen Ausnahme stimmen gegen den Code, Punkt 6 auch sachlich.
- **§3.7 am Kommentar `cmd/ai-harness-init/archive_welle.go:279–285`** — **REFUTED**: *„`Haenger` filtert sie ueber archive.AusgenommenePfade, `VerweisFund`/`Nachziehen` zusaetzlich ueber archive.AusgenommenePfadeNachzug (docs/plan/adr, ADR-0042 Festlegung 2)"* — Indikativ Präsens über den Zustand, Herkunft als **ein** auflösbares Feld, kein abwesender Text, kein Lauf-Protokoll.
- **Aliasing / dritter Träger** — ohne Befund: `AusgenommenePfade()` liefert je Aufruf ein frisches Literal, `append` teilt kein Backing-Array; ein dritter mechanischer Verweis-Umschreiber existiert nicht (`refs.go:243` schreibt Nachzug, `anwenden.go:233` Stubs).

## Kategorie-Summary

1 HIGH · 1 MEDIUM · 1 LOW · 0 INFO. Wiederkehrende Klasse: **Zusage ohne rot gesehenes Gegenbeispiel an der Stelle, die die Zusage trägt** — HIGH-1 und MEDIUM-1 sind dieselbe Klasse an zwei Trägern, Kandidat für das Beobachtungs-Register bei der Closure.

## Verdikt

**Blockierend.** HIGH-1: Die Eigenschaft, für die dieser Slice existiert — die Trennung von Hänger-Suchraum und Nachzug-Suchraum —, ist nachweislich unbewacht und damit eine Zusage in zwei Kommentaren statt einer gemessenen Eigenschaft. Was **geliefert** ist, trägt: beide Ausschlüsse sitzen richtig, beide gelieferten Gegenbeispiele sind real rot, die Sperre aus Festlegung 5 ist nachweislich gehoben und `[haenger]` unberührt.
