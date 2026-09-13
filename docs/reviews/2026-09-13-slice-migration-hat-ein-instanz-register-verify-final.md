# Verifikations-Report (final): slice-migration-hat-ein-instanz-register — 2026-09-13

**Rolle:** Verifier (Modul 8/11) — „Bauen wir es richtig?" gegen DoD und ADR-Bezüge. Kein
Self-Review: dieser Lauf hat an `harness/migration.md` nichts geschrieben.

**Gegenstand:** `harness/migration.md` @ `369e6e99` (Runde-4-Nacharbeit, letzter Commit vor diesem
Report). Arbeitsbaum leer, `git status --short` ohne Ausgabe.

**Eingangs-Kontext:**

- Slice-Plan `slice-migration-hat-ein-instanz-register` (`in-progress/`), §2 Definition of Done
- Vier Review-Runden: `93c54d1b` (1 HIGH/6 MEDIUM), `8647edd3` (0 HIGH/5 MEDIUM), `0cbb4d7e`
  (0 HIGH/3 MEDIUM), `64c9ae58` (0 HIGH/5 MEDIUM) — je mit Nacharbeits-Commit geschlossen
- Vorheriger Verifikations-Lauf `fe401bc7` (vor Runde 2–4; DoD-2 als „nicht wie geschrieben
  abhakbar" befundet — dieser Befund ist Ausgangspunkt für Prüfung 3 unten)
- [`ADR-0018`](../plan/adr/0018-ziel-fassung-regiert-die-migration.md),
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)

**Rollen-Grenze:** Alle Sonden unten sind lesend (`find`, `grep`, `ls`, `git log`, Hash-Abgleich).
Kein Docker-Ziel selbst gefahren — `make gates` ist der Auftraggeber-Lauf, hier nur nachgeprüft.

---

## Prüfung 1 — Ist der Sensor gelaufen?

`make gates` → `EXIT 0`. Beleg: `.harness/state/gates-passed.diffsha` = `3be1a5c1…` deckt sich mit
`bash harness/tools/working-tree-hash.sh` (identischer Hash, selbst nachgerechnet). `docs-check`
ist reguläres Prerequisite von `gates` und damit mitgedeckt; die Behauptung „zweimal vom
Implementer gefahren" ist an den Commit-Messages ablesbar (`93c54d1b` ff.), nicht separat
nachgemessen — nicht nötig, der Gate-Hash deckt den Endstand ohnehin. **Bestätigt.**

## Prüfung 2 — Deckt der Sensor die Zusage? (DoD-Punkt 3)

Nachgezählt, nicht neu geprüft:

```sh
find .harness/baseline/v6.7.2/templates -name '*.template.md' | wc -l   # 25
```

Registerzeilen in `harness/migration.md` §4: **25** (`awk` über den Abschnitt, Tabellenzeilen
gezählt). Klassifikation nachgerechnet: Buchstabe a (einmalig, vier Ausgänge) **14** — Buchstabe b
(wiederkehrend, append-only, §4 nennt „sieben") **7** — §6 offen (Register-Zeilen ohne Zuordnung:
`welle-results`, `observation`, `gate.template`, `MR-NNN-titel`) **4**. 14+7+4=25, deckungsgleich
mit der Vollständigkeits-Zahl. Die Rechnung aus dem Auftrag geht auf. **Bestätigt — keine
Zeile-für-Zeile-Neuprüfung, das haben die vier Reviewer-Runden geleistet** (zuletzt R4-Findings
N-14/N-15/N-16/N-17/N-18 genau zu dieser Abgrenzung, mit `369e6e99` behoben: „acht" → „sieben",
Ausschluss-Satz in §5b korrigiert, zwei Zeilen nach §6 verschoben).

## Prüfung 3 — Sagt der Plan, was der Code tut? (DoD-Punkt 2)

**Nein, nicht mehr wörtlich.** DoD-Punkt (2) sagt „je Vorlage genau einer von vier Ausgängen …
geschlossene Menge". Das Dokument trägt inzwischen drei Fälle: Buchstabe a (vier Ausgänge, 14
Vorlagen), Buchstabe b (ein Ausgang, append-only, 7 Vorlagen) und vier Vorlagen ohne Zuordnung in
§6. Das ist keine Regression, sondern das Ergebnis von Runde 1 (Finding F-1: die Universal-Vier-
Annahme trug die wiederkehrenden Vorlagen nicht) — der bereits im Verifikations-Lauf `fe401bc7`
benannte Befund, seither durch Inhalt, nicht durch DoD-Text, aufgelöst.

**Korrektur fällig (Planner-Arbeit, `AGENTS.md` §3.10):** DoD-Punkt (2) so umformulieren, dass er
die heute gebaute Form beschreibt — Vorschlag in einem Satz: *„Dasselbe Dokument trägt die
Report-Form für `docs/migrations/<tag>.md` — für jede nicht-wiederkehrende Vorlage einen von vier
Ausgängen (übernommen/schon erfüllt/bewusst abweichend/keine Instanz), für jede wiederkehrende
Vorlage den Ausgang append-only, und für jede noch nicht zugeordnete Vorlage eine offene Frage in
§6 statt einer Regel."*

Das ist eine Text-Korrektur am Slice-Plan, keine Nacharbeit am Dokument — der Implementer schreibt
sein eigenes Abnahmekriterium nicht um (§3.10).

## INFO (kein Blocker)

- §7 Closure-Notiz trägt noch Platzhalter (`<…>`) und die DoD-Checkboxen sind unangehakt — das ist
  an dieser Stelle erwartet: Closure ist Planner-Arbeit (`AGENTS.md` §3.10), nicht Teil dieser
  Verifikation.
- Der einzige Review-Report, der noch „Merge-blockierend: ja" trägt, ist `93c54d1b` (Runde 1);
  Runden 2–4 sind jeweils gegen ihren eigenen Nacharbeits-Commit geschrieben und lösen sich
  historisch ab. Kein Handlungsbedarf — die Kette der vier Reports macht das nachvollziehbar, nur
  keine der vier trägt selbst einen „Runde X löst Runde X-1 ab"-Vermerk.

---

## Verdikt

**DoD erfüllt bis auf eine benannte Korrektur:** Punkt (1) und (3) sind wie geschrieben abhakbar
(Instanz-Register 25/25, ADR-Bezug/§6-Verfahren trägt). `make gates` grün und real gedeckt. Punkt
(2) ist **nicht** wie geschrieben abhakbar — der Planner korrigiert den DoD-Text auf die
Drei-Fälle-Form (Formulierungsvorschlag oben), bevor er ihn abhakt; der gebaute Inhalt selbst ist
nicht zu beanstanden.

**An den Planner, je Punkt ein Satz:**

- (1) Instanz-Register — abhakbar, 25/25 gedeckt.
- (2) Report-Form — **nicht** wie geschrieben abhakbar; DoD-Text erst auf die Drei-Fälle-Form
  korrigieren (Vorschlag oben), dann abhaken.
- (3) ADR-Bezug je normativer Punkt — abhakbar, inklusive der Fälle, die als offene Frage in §6
  stehen statt als Regel.
- `make gates` — abhakbar, Hash-Beleg deckungsgleich.
- Review — abhakbar, vier Runden bis 0 HIGH / letzte Runde 5 MEDIUM behoben.
