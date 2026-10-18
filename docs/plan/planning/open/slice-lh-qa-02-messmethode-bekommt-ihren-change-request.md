# Slice slice-lh-qa-02-messmethode-bekommt-ihren-change-request: Die Messmethode von LH-QA-02 bekommt ihren Change Request

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese Datei liegt — eines von
`open/`, `next/`, `in-progress/`, `done/`. Er wechselt nur durch `git mv`, siehe Baseline-Regelwerk
`modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Eine Closure-Bedingung, die über die DoD hinaus etwas beobachtet, gibt es nicht
(`modul-06-roadmap.md` §Wann Arbeit eine Welle braucht): der Slice liefert einen Entwurf, keinen repo-weiten Beleg.

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) ·
[`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) (die sechs Skelette, an denen die
Messmethode gemessen wird).

**Berührte Spec-Stellen:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), Feld *Messmethode*.
Der Slice schreibt sie nicht um (§1).

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-10-18.

---

## 1. Ziel und Abgrenzung

**Ziel:** Ein Entwurf liegt vor, der die Messmethode von [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
so fasst, dass die Skelette (`go`, `cpp`, `kotlin`, `java`, `python`, `csharp`) sie erfüllen: die Generator-Ausgabe
zweier Läufe mit gleichem Tag ist byte-identisch, das Image ist per Tag gepinnt, und die Drift der Image- und
Paket-Feeds (Inhalt eines Tags, transitive Pakete) steht als **benannte Grenze** statt als Zusage. Der Nutzer
entscheidet über den Entwurf; der Ausgang von
[`BEO-ALL/cpp-skelett-erfuellt-die-messmethode-von-lh-qa-02-nicht`](../observations/BEO-ALL/cpp-skelett-erfuellt-die-messmethode-von-lh-qa-02-nicht/observation.md)
ist damit *geplant*.

**Ausdrücklich NICHT in diesem Slice:**
- **Der Change Request selbst.** Eine Änderung von `spec/lastenheft.md` ist ein Change Request nach
  [`MR-015`](../../../../harness/conventions.md#mr-015), [`MR-036`](../../../../harness/conventions.md#mr-036) und
  [`MR-042`](../../../../harness/conventions.md#mr-042): ein eigener Commit, der ausschließlich das Lastenheft
  ändert, vor dem Slice, der ihn umsetzt, mit einer Zeile in §7 *Historie* (Verweis auf die Auftraggeber-Anweisung,
  Form der Zeilen 0.25.0 bis 0.26.0) und dem Anlass nur in der Closure-Notiz. Der Slice bereitet vor; die Annahme
  bleibt beim Nutzer als Auftraggeber. Welche Rolle den Lastenheft-Text schreibt, benennt keine Quelle:
  [`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) gibt für das Lastenheft den Commit-Zuschnitt, nicht die
  Rolle, und `slice-151-spec-straten-haben-eine-schreibende-rolle` in `next/` schließt die Lücke für Spezifikation und
  Architektur, nicht für das Lastenheft. Der Slice entscheidet das nicht.
- **Ein Digest-Pin in den Skeletten.** Der Nutzer hat ihn verworfen; er wäre ein anderer Vorgang (Pflege von Digests,
  [`BEO-ALL/pin-digest-ohne-waechter`](../observations/BEO-ALL/pin-digest-ohne-waechter/observation.md)), kein Wortlaut.
- **Ein Eingriff in die Profile** (`internal/gen/`, Fragmente, Dockerfiles) — der Slice liest sie, ändert sie nicht;
  ein Skelett, das die neue Messmethode nicht trägt, wäre ein Befund für den Architect, kein Mitnahme-Gegenstand.
- **Die Nachzüge nach einer Annahme** (Abdeckungs-Sicht, Doku, Wächter auf die neue Zusage) — anderer Vorgang, der erst
  mit dem angenommenen Wortlaut einen Gegenstand hat.

## 2. Definition of Done

- [ ] §7 trägt je Sprache die Pin-Form von Image und Paketen und das Ergebnis zweier Generator-Läufe über demselben
      Tag (byte-gleich ja oder nein), gelesen am realen Binär und an der emittierten Quelle, nicht an einer Fixture
      ([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)).
- [ ] §7 trägt den Wortlaut-Entwurf für `LH-QA-02` (Anforderung, Messmethode, Drift als benannte Grenze) und den Entwurf
      der Historie-Zeile; jede Zusage des Entwurfs nennt, was sie brechen müsste, und die Messung dazu ist einmal rot gesehen
      ([`AGENTS.md`](../../../../AGENTS.md) §3.6). Der Vermerk *Entscheidung des Nutzers ausstehend* steht dabei.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor (`.harness/skills/reviewer.md`), kein Self-Review.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen, nach dem Move geprüft, §7.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/gen/`, emittierte `Makefile`/`Dockerfile` je Sprache | gelesen | Pin-Form von Image und Paketen je Skelett |
| `docs/plan/planning/` §7 dieses Slice | update | Befund-Tabelle und Entwurf; kein Artefakt außerhalb davon |

## 4. Trigger

**Start** (`next` → `in-progress`): WIP-Slot frei; der Ausgang *geplant* des Beobachtungs-Eintrags steht.

**Rückführungen — vorab benennen:**
- `in-progress` → `next`: die Messung je Sprache braucht mehr als einen Lauf-Vergleich (etwa einen Registry-Zugriff) —
  zurück zur Zerlegung.
- `in-progress` → `open`: ein Skelett erfüllt auch die engere Messmethode nicht (Generator-Ausgabe nicht byte-gleich) —
  Befund für den Architect, kein Eingriff in dem Slice.

## 5. Closure-Trigger

DoD vollständig, Entwurf in §7, Closure-Notiz mit Lerneintrag. Der Wechsel des Eintrags auf *verkörpert* hängt am
Commit des Change Requests und ist kein Closure-Trigger dieses Slice.

## 6. Risiken und offene Punkte

- Der Nutzer nimmt den Entwurf nicht an oder wählt eine andere Linie — **Ausgang:** bei der Closure.
- Zwei Generator-Läufe sind für eine Sprache nicht byte-gleich — **Ausgang:** bei der Closure; eingetreten hieße Folge-Slice.

## 7. Closure-Notiz

<!-- Erst bei der Closure füllen. -->

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** `*` (`ALL`); der Slice schreibt Planungs-Text, für den die
Modus-Deklaration keine eigene Sub-Area führt.

**Vorgelagert — offene Beobachtungen sichten** (gelesen 2026-10-18):
`cpp-skelett-erfuellt-die-messmethode-von-lh-qa-02-nicht` — 3, geplant; dieser Slice ist der Ausgang ·
`pin-digest-ohne-waechter` — 8, verkörpert; der Digest-Pin ist hier ausgeschlossen.

**Modus:** alle berührten Sub-Areas GF.
