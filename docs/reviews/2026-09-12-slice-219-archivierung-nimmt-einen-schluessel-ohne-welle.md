# Review slice-219 — Die Archivierung nimmt einen Schlüssel, der keine Welle ist

**Rolle:** Reviewer · **Datum:** 2026-09-12 · **Gegenstand:** `f9ef00e2` (5 Dateien, +173/−15) · **Plan:** [`slice-219`](../plan/planning/done/slice-219-archivierung-nimmt-einen-schluessel-ohne-welle.md)
**Constraint:** [`ADR-0041`](../plan/adr/0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md) (Accepted), [`ADR-0033`](../plan/adr/0033-wellen-archivierung-als-unterkommando.md) · **Hard Rules:** [`AGENTS.md`](../../AGENTS.md) §3.6, §3.7 · **Vorrunden:** `2026-09-12-adr-0041-*` (r1–r3)
**Gefahren:** `make test-go` (Basis grün), vier Mutationen einzeln angewandt und zurückgesetzt, `make comment-claims`, `make host-bin` + `--vorschau altbestand`

## Findings

**HIGH-1** · [`AGENTS.md`](../../AGENTS.md) §3.7 · `internal/archive/vorschau_test.go:155-156` — Der neue Doc-Kommentar trägt keine der fünf Kommentar-Klassen, sondern den Konjunktiv über die verworfene Alternative: *„Ein Test, der stattdessen archive.AltbestandSchluessel an beiden Enden verglichen haette, waere gegen eine Aenderung des Werts blind."* Das ist wörtlich die Form, die §3.7 als **Falsch** ausschreibt; dieselbe Klasse ein zweites Mal in `:170` (*„unter einer Welle-Kennung waere das 'mehrdeutiger-plan'"*).
*verifizierbar:* nein — `make comment-claims` prüft nur genannte Sensoren (58 Datei(en), 0 Befund(e)) und nimmt `_test.go` aus. *klasse:* Kommentar im Konjunktiv über die verworfene Alternative.

**MEDIUM-1** · [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) · `internal/archive/anwenden.go:89` gegen `harness/sensors/archive-welle.md:33-34` — Die Sensor-Datei sagt *„die Vorschau ist die Vorprüfung des schreibenden Laufs, und was sie an Sperren nennt, sind genau die Ausgänge, an denen er abbricht"*, und der neue Abschnitt nennt `haenger` als einzigen verbleibenden Halt. Für `altbestand` gilt beides nicht mehr: `Anwenden` beginnt mit `if len(b.Plaene) != 1 { return … "genau ein Welle-Plan erwartet, %d vorhanden" }`, und `planName` findet unter `done/` kein `altbestand*.md` → 0. Fällt `haenger`, druckt der Lauf *„Sperren: keine — der schreibende Lauf liefe."* und bricht dennoch mit Exit 1 ab; `schreibeStubs` liest daneben `b.Ergebnis`, das für diesen Schlüssel leer ist. Die ABGRENZUNG in `vorschau.go:58-60` führt weiterhin nur die Stub-Form und das fehlende Wellen-Argument als vorschau-lose Ausgänge.
*verifizierbar:* ja — Go-Test über einem synthetischen Baum ohne `haenger` mit Schlüssel `altbestand`. *klasse:* Sensor-Zusage weiter als der Code (wie r1 LOW-2).

**LOW-1** · [`MR-051`](../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung) · Commit-Message `f9ef00e2` — *„Sieben neue Go-Tests in vorschau_test.go"*; gemessen sind es sechs (`git show f9ef00e2 -- internal/archive/vorschau_test.go | grep -c '^+func Test'` → **6**). *verifizierbar:* ja (dasselbe Kommando). *klasse:* Zahl in der Commit-Message nicht am Beleg gemessen.

**LOW-2** · Ziel-Form `gate.template.md` §Sperren (*„ihr Name, wie ihn die Abbruch-Meldung nennt"*) · `harness/sensors/archive-welle.md:104-121` — Der neue Abschnitt benennt die vier Aufgehobenen als Kennungen (`ergebnisnotiz`, `kein-plan`, `mehrdeutiger-plan`), die `†`-Liste drei davon in Prosa („fehlende Ergebnisnotiz", „fehlender Welle-Plan"); die Zuordnung geht nur über die Zahl vier auf. *verifizierbar:* nein — `structure` steht nicht in `modules:`. *klasse:* zwei Namenssysteme für dieselbe Sperre in einer Datei.

**INFO-1** · `harness/sensors/archive-welle.md:37` — „## Ein Schlüssel ohne Welle" ist der einzige Abschnitt außerhalb der fünf der Ziel-Form über alle 15 Sensor-Dateien (`grep -h '^## ' harness/sensors/*.md | sort | uniq -c`).

## Negativbefunde

- **Aufgehobene Menge (Prüfpunkt 1):** `welleGebunden` gattert genau `ergebnisnotiz`, `planSperre` (`kein-plan`/`mehrdeutiger-plan`) und `untergrenzeSperre` — vier von acht; `unsauber`, `archiviert`, `kein-slice` und `haenger` liegen außerhalb beider `if`-Blöcke. Kein Befund.
- **Gegenbeispiel (Prüfpunkt 2):** `310` selbst angewandt → einziger Fehlschlag `--- FAIL: TestAltbestandBehaeltHaengerSperre`; `311` → `--- FAIL: TestAltbestandSperrtBeiKeinSlice`. Beide rot gesehen, per `git checkout` zurückgesetzt. Kein Befund.
- **Schlüssel (Prüfpunkt 3):** `TestAltbestandSchluesselTraegtDenWertAusADR0041` vergleicht gegen das Literal `"altbestand"`, nicht gegen sich selbst; die Konstante hat genau eine Definition (`vorschau.go:13`, kein zweites Vorkommen außerhalb der Tests). Kein Befund.
- **Kalibrierung und Stub-Form (Prüfpunkt 4):** zwei eigene Sonden — `welleGebunden := true` rötet `TestAltbestandHebtWelleUndUntergrenzeSperrenAuf`, `unsauber`/`archiviert` am Schlüssel gattert rötet beide zugehörigen Tests; `anwenden.go`/Stub-Vorlagen sind vom Diff nicht berührt. Kein Befund.
- **Stiller Pfad:** der Zweig hängt an Gleichheit mit einer Konstante — jeder Tippfehler (`altbestan`, `Altbestand`) fällt in den welle-gebundenen Zweig und sperrt vollständig. Kein Befund.
- **Kein Vollzug:** `archiveWelleLauf` bricht unverändert bei `len(bericht.Sperren) > 0` mit Exit 3 ab; `--vorschau altbestand` meldet am Baum `[unsauber]` (Fremd-Lauf) und `[haenger]`, Zahlen 0/58/91/144. Kein Befund.
- **Doku-Ort und Links:** `harness/README.md:76` ist die Index-Zeile auf die Sensor-Datei; beide neuen Ziele (`ADR-0041`, `slice-216`) lösen auf. Kein Befund.

## Kategorie-Summary

1 HIGH · 1 MEDIUM · 2 LOW · 1 INFO.

## Verdikt

**Blockierend.** HIGH-1 ist eine Hard-Rule-Verletzung an neu geschriebenem Text. MEDIUM-1 blockiert den Merge nicht zwingend — der Slice eröffnet den schreibenden Lauf ausdrücklich nicht —, aber die Zusage der Sensor-Datei ist seit diesem Commit falsch und gehört benannt, bevor `slice-216` `haenger` auflöst. Der tragende Punkt des Slice — `haenger` bleibt stehen, mit echtem rotem Gegenbeispiel — ist gehalten.
