# Verifikation: slice-span-traegt-die-fassung-seiner-erfassungsregel — 2026-10-08

**Rolle:** Verifier (Modul 11) · **Modell:** claude-opus-5-5 · **Datum:** 2026-10-08

**Gegenstand:** `602a72b0`, `b24e7315` (Stand `HEAD` = `b24e7315`) gegen §2 DoD und §3 Plan des Slice;
`LH-FA-13` (Lastenheft 0.25.1), `spec/spezifikation.md` §5 (`SPEC-088`–`SPEC-095`), `AGENTS.md` §3.6.
Review-Report `2026-10-08-span-fassung-review.md` (0/0/2/2, F-1–F-4 in `b24e7315` bearbeitet).

**Messweg:** Sonden in einer Scratchpad-Kopie per `git archive HEAD`, Host-Baum unberührt, `make test-go`
dort. `make gates` nicht gefahren: der Stempel `.harness/state/gates-passed.head` = `b24e7315` = `HEAD`,
und dieser Lauf ändert nur den Bericht. Die Release-Zuordnung der Fassungen 2–4 hat der Review mit
`git tag --contains` gemessen; hier als Stichprobe nachgefahren (`git describe --contains`, s. u.).

## Verdikte je DoD-Punkt

- **DoD 1 — Form entschieden und in §5 begründet: bestätigt.**
  - `SPEC-089` wählt das Feld, verwirft die datierte Wechsel-Zeile mit Grund (maschinenlokaler Bestand,
    `ts` ordnet eine Zeile einer Fassung zu, die ihr Schreiber nicht führen musste); Zählregel je Release.
  - `SPEC-088` Pflichtfeld `rule_version`, Ganzzahl ab 1; `fieldlist.go` führt die Frage in der emittierten
    Feldliste (`LH-FA-13` „Liste liegt im Zielrepo lesbar").
- **DoD 2 — umgesetzt, Bericht trennt, ohne/falsche Fassung rot gesehen: bestätigt.**
  - `make mutate MUTATE_CASES="592-… 593-… 594-… 595-… 596-…"` (volle Fall-Namen; die bloße Nummer
    bricht mit „unbekannter Fall" ab) → `5 ok, 0 Befund(e)`, je Fall der benannte Test rot:
    592 → `TestSpanCarriesCurrentRuleVersion` (ohne Fassung, Feld `0`), 593 →
    `TestCurrentRuleVersionIsTheLastSpecFassung` (falsche Fassung), 594 → `TestAggregiere_TrenntDieFassungen`,
    595 → `TestSchreibe_OhneLesbareZeileKeineFassungsZeile`, 596 → `TestSchreibe_FassungUnterEinsIstDemLeserUnbekannt`.
  - **Rot an der realen Quelle** (Kopplung an die Spezifikation, nicht an die Konstante): in der Kopie die
    Zeile `SPEC-093` (Fassung 4) aus `spec/spezifikation.md` gestrichen → `make test-go`:
    `ruleversion_test.go:73: die letzte Fassung der Spezifikation ist 3, der Traeger schreibt 4`,
    `--- FAIL` nur in `internal/span` für diesen Test. Meldung trägt die behauptete Ursache.
  - `make span-report` am echten Bestand (2440 Dateien unter `.harness/state/spans/`):
    `Erfassungsregel: Fassung 4: 66 Zeile(n) · Fassung nicht bekannt: 65152 Zeile(n)`; Summe = `gelesen
    wurden 65218 Zeile(n)`. Gegenprobe `grep -ho '"rule_version":[0-9]*' .harness/state/spans/*.jsonl | sort | uniq -c`
    → nur `"rule_version":4` (65 kurz vor dem Report-Lauf, Zuwachs aus diesem Lauf).
- **DoD 3 — bisherige Bedeutungswechsel nachgetragen: bestätigt.**
  - Stichprobe `git describe --contains`: `2efaa979`/`fb1ca361` → `v0.2.4` (Fassung 2, inkl. `argc`-Wortgrenze
    nach F-1), `dfa544df` → `v0.2.5` (Fassung 3), `91af2b67`/`06f7c614` → `v0.3.0` (Fassung 4).
  - `git log --oneline v0.3.0..v0.4.0 -- internal/span/`, `v0.4.0..v0.5.0`, `v0.5.0..257acc61` → leer:
    nach Fassung 4 kein Wechsel offen. `git diff v0.2.5 v0.2.8 -- internal/span/ ':!*_test.go'` ohne
    Kommentarzeilen → leer: `3ab9b2eb` (v0.2.7) ist kein Bedeutungswechsel.
- **DoD 4 — `make gates` grün: bestätigt** über den Stempel (`gates-passed.head` = `HEAD`); CI-Lauf
  `37775749099` auf `HEAD`: siehe letzte Zeile unter *Offene Punkte*.
- **DoD 5 — Review liegt vor: bestätigt** (`docs/reviews/2026-10-08-span-fassung-review.md`).
- **DoD 6–9 (Closure-Notiz, Register, Risiko-Ausgang, Paarungen): nicht Gegenstand** — Planner bei Closure;
  §7 steht auf „— bei Closure", das Risiko in §6 auf „offen bis Closure".

## Lastenheft 0.25.1 — Lesart von `rule_version` beim Altbestand

- **Bestätigt.** `LH-FA-13` „unbekannt ist gekennzeichnet" bindet den **Emitter**; er kennt die Fassung
  immer und schreibt sie in jede Zeile (592 bindet den Wert, `TestMandatoryFieldsAlwaysPresent` die
  Anwesenheit). Altbestand ohne Feld wird nicht umgeschrieben (§1 Abgrenzung, `SPEC-057`), der **Leser**
  führt ihn als *Fassung nicht bekannt*, nie unter der laufenden Fassung (594) — dieselbe Lesart, die
  `LH-FA-15` „Lesevorschrift" für den Bestand vor der Kennzeichnung setzt.
- Ein `rule_version` als Zeichenkette (etwa eine Kennzeichnung) macht die Zeile unlesbar; `SPEC-089`
  sagt das zu, und der Emitter erzeugt keine solche Zeile.

## Findings

- **V-1 (LOW, Zusage ≠ Verhalten):** `SPEC-089` sagt zu, eine Fassung **außerhalb** der Tabelle mit
  *dem Leser unbekannt* zu nennen und nur Zeilen **ohne das Feld** als *Fassung nicht bekannt*. Eine
  Zeile mit explizitem `"rule_version":0` fällt in Go auf denselben Schlüssel 0 wie das fehlende Feld.
  Sonde in der Kopie (`Aggregiere` über eine Zeile `…,"rule_version":0}`, dann `Schreibe`):
  `Erfassungsregel: Fassung nicht bekannt: 1 Zeile(n)` — nach `SPEC-089` wäre `Fassung 0 (dem Leser
  unbekannt)` zu erwarten. Der Testkommentar von `TestSpanCarriesCurrentRuleVersion` liest `0` als
  *nicht bekannt*, `SPEC-088`/`SPEC-089` sagen das nicht. Erreichbar nur über fremd oder von Hand
  geschriebene Zeilen; der Emitter schreibt nie `0` (592). Ausgang: entweder `SPEC-089` nennt `0`
  ausdrücklich als *nicht bekannt*, oder der Leser unterscheidet Abwesenheit (`*int`) — Planner/Implementer.

## Plan-vs-Code

- §3 Plan ↔ Diff deckungsgleich in beide Richtungen: `spezifikation.md` §5, `internal/span/{emit,ruleversion,fieldlist}.go`,
  `internal/report/report.go`, Tests, Fälle (Plan nennt 592–594; 595/596 aus dem Review-Nachlauf, Plan-Zeile
  nicht nachgezogen — kein Verhaltens-Gegenstand), `harness/sensors/span-report.md`, `benutzerhandbuch.md`.
  Zusätzlich `span_test.go` (Pflichtfeld-Liste) — Teil der Zeile „Go-Tests". Kein Gebautes ohne Plan.

## Negativbefunde

- Token-Bilanz: rechnet weiter über den ganzen Bestand, die Fassungs-Zeile zählt nur; kein Befund.
- Unlesbare Zeilen: zählen in keiner Fassung (595-Test, Fall „unlesbar"); kein Befund.
- `SPEC-094` benennt die unbewachte Hälfte (Hochzählen bei einem künftigen Wechsel) selbst; deckt sich mit
  dem Risiko §6.

## Offene Punkte für Planner/Architect

- V-1 einer Route zuweisen (Spec-Satz oder Leser-Änderung).
- Plan §3 nennt Fälle 592–594; 595/596 bei Closure erwähnen.
- CI `37775749099` (gates, smoke, adr-immutable, full-smoke) auf `b24e7315`: `success`, alle vier Jobs `success` (`gh run view 37775749099 --json conclusion,jobs`) — `full-smoke` auf HEAD grün.
