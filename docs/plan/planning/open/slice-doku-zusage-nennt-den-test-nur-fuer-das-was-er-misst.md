# Slice slice-doku-zusage-nennt-den-test-nur-fuer-das-was-er-misst: Eine Doku-Zusage nennt den Halter-Test nur für das, was er misst

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle — reaktiv (Register-Ausgang *geplant* bei 3×), keine Closure-Bedingung jenseits der DoD ([`MR-037`](../../../../harness/conventions.md#mr-037)).

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`AGENTS.md`](../../../../AGENTS.md) §3.6.

**Berührte Spec-Stellen:** —.

**Verantwortlich:** — bis zur Priorisierung.

**Autor:** Planner. **Datum:** 2026-10-16.

---

## 1. Ziel und Abgrenzung

**Ziel:** Der Architect entscheidet, ob `AGENTS.md` §3.6 die Klasse *Doku oder Kommentar nennt einen Test als Halter einer Eigenschaft, den der Test nur zum Teil misst* als eigenes Falsch/Richtig-Paar führt, oder benennt, warum kein Sensor sie fängt.

Anlass: der Ausgang *geplant* von `BEO-ALL/doku-zusage-nennt-den-test-dessen-fall-nur-einen-ausschnitt-misst` (3×).

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Ein Sensor über Doku-Prosa gegen die genannten Fälle.** Ein Wächter existiert nicht (`harness/sensors/comment-claims.md`); ob einer baubar ist, ist Teil der Entscheidung, nicht ihres Vorgriffs.
- **Die drei Bestands-Stellen.** Sie sind je in ihrem Slice behoben; Bestand bleibt bewusst stehen.

## 2. Definition of Done

- [ ] Architect-Verdikt als eigener Commit (§3.8): Hard-Rule-Schärfung in `AGENTS.md` §3.6 mit Herkunfts-Anker, oder eine benannte Grenze mit Begründung, warum der Sensor nicht baubar ist.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register fortgeschrieben; `state.md` von `BEO-ALL/doku-zusage-nennt-den-test-dessen-fall-nur-einen-ausschnitt-misst` trägt `verkörpert` mit Zielort und Anker.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang.
- [ ] Die drei Paarungen sind getragen.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `AGENTS.md` §3.6 | update (Architect) | die Klasse als Falsch/Richtig-Paar oder die benannte Grenze |

## 4. Trigger

**Start** (`next` → `in-progress`): Priorisierung durch den Planner; WIP-Limit frei.

**Rückführungen:**

- `in-progress` → `next` (zu groß): wenn die Entscheidung einen Sensor-Bau verlangt.
- `in-progress` → `open` (blockiert): wenn das Verdikt eine ADR statt einer Hard-Rule-Schärfung braucht.

## 5. Closure-Trigger

DoD vollständig; Review ohne blockierenden Befund; Closure-Notiz geschrieben.

## 6. Risiken und offene Punkte

- §3.6 deckt die Klasse mit dem Satz zum Test-Namen bereits ab, und die Schärfung wäre eine zweite Fassung — **Ausgang:** weiter offen → `BEO-ALL/doku-zusage-nennt-den-test-dessen-fall-nur-einen-ausschnitt-misst`.

## 7. Closure-Notiz

- **Was hat funktioniert:** —
- **Was ging anders als geplant:** —
- **Steering-Loop-Eintrag:** —
- **Beobachtungs-Register (`../observations/`):** —
- **Folge-Slices:** —

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührte Sub-Area `*` (gesamtes Repo, [`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area)); Schwelle erfüllt.

**Vorgelagert — offene Beobachtungen sichten:** Treffer: [`BEO-ALL/doku-zusage-nennt-den-test-dessen-fall-nur-einen-ausschnitt-misst`](../observations/BEO-ALL/doku-zusage-nennt-den-test-dessen-fall-nur-einen-ausschnitt-misst/observation.md) (3×, geplant — dieser Slice).

**Modus-Begründungsblock — Umfang:** alle berührten Sub-Areas GF.
