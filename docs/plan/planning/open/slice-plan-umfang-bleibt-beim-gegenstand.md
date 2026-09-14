# Slice slice-plan-umfang-bleibt-beim-gegenstand: Der Plan-Umfang bleibt beim Gegenstand

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. (1) Bündel? Nein. (2) Gemeinsames Closure-Kriterium? Nein.
(3) **Reaktiv:** eine Register-Beobachtung über der Schwelle. Begründet gegen die drei Fragen aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird).

**Bezug:** Baseline-Regelwerk `modul-05-planning-harness.md` §Ziel-Form: Slice (Zu-groß-Kriterien,
Ein-Sitzungs-Review), [`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer),
[`AGENTS.md`](../../../../AGENTS.md) §3.7 (die Stelle beschreiben, nicht den Vorgang ihrer
Entstehung).

**Berührte Spec-Stellen:** `—`.

**Verantwortlich:** — bis zur Priorisierung.

**Autor:** Planner. **Datum:** 2026-09-14.

---

## 1. Ziel und Abgrenzung

**Ziel:** Die Beweisführung eines Slice-Plans bleibt beim Gegenstand des Slice und wächst nicht über
das hinaus, was seine Umsetzung liest. Die Regel steht an einem Norm-Artefakt.

Die Klasse hat keinen Zielort: Die Größen-Regel des Baseline-Regelwerks deckelt **Liefer-Punkte**
und die Reviewbarkeit in einer Sitzung, nicht den Umfang der Herleitung. Ein Slice-Plan dieses Repos
trägt ein Vielfaches der Zeilenzahl, die das Schwester-Repo für dieselbe Arbeitsklasse braucht.
Beleg:
[`BEO-ALL/slice-plan-umfang-waechst-ueber-umsetzung-hinaus`](../observations/BEO-ALL/slice-plan-umfang-waechst-ueber-umsetzung-hinaus/observation.md)
(3 Belege).

**Ausdrücklich NICHT in diesem Slice:**

- **Der Bestand.** Geschlossene Pläne werden nicht umgeschrieben — das wäre rückwirkende Historie an
  Zeitdokumenten und ein eigener, größerer Schnitt.
- **Die Liefer-Punkte-Grenze.** Sie steht und bleibt bei drei; dieser Slice regelt die Herleitung
  **neben** ihr (Schicht-Abgrenzung).
- **Die Beweis-Pflicht selbst.** Kommando-Belege bleiben gefordert ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert));
  dieser Slice regelt, wie weit sie sich zum Gegenstand verhält.

## 2. Definition of Done

- [ ] Die Regel steht an einem Norm-Artefakt: die Herleitung eines Slice-Plans bleibt beim
      Gegenstand, den seine Umsetzung liest.
- [ ] Der Zielort nennt eine messbare Form — etwa die Zeilenzahl des Plans gegen die seiner
      Umsetzung —, statt nur ein Gefühl.
- [ ] Rot gesehen: ein Plan über der benannten Grenze färbt den Träger rot **oder** die Zusage ist
      auf das eingeschränkt, was der Lauf hält.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| Anweisungssatz [`plan-welle.md`](../../../../.claude/commands/plan-welle.md) bzw. `AGENTS.md` §3 | update | Träger der Regel für den schreibenden Lauf |
| [`harness/tools/`](../../../../harness/tools) | neu | Träger, wenn die Zeilenzahl gemessen wird |
| [`test/`](../../../../test) | neu | Rot-Beleg über einem Plan über der Grenze |

## 4. Trigger

**Start** (`next` → `in-progress`): Priorisierung durch den Planner.

**Rückführungen:**

- `in-progress` → `next` (zu groß): wenn Regel und Messung zusammen kommen.
- `in-progress` → `open` (blockiert): wenn die Grenze ohne eine Gate-Senkung nicht erreichbar ist.

## 5. Closure-Trigger

DoD vollständig, Review ohne blockierenden Befund, Closure-Notiz geschrieben.

## 6. Risiken und offene Punkte

- Die Grenze ist ein Urteil und wird als Zahl ausgegeben — **Ausgang:** weiter offen →
  `BEO-ALL/eine-stellen-messung-traegt-keine-folgerung-ueber-eine-eigenschaft` (unter der Schwelle).
- Die Regel greift nur für neue Pläne — **Ausgang:** weiter offen →
  `BEO-ALL/slice-plan-umfang-waechst-ueber-umsetzung-hinaus`.

## 7. Closure-Notiz

- **Was hat funktioniert:** —
- **Was ging anders als geplant:** —
- **Steering-Loop-Eintrag:** —
- **Beobachtungs-Register (`../observations/`):** —
- **Folge-Slices:** —

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührte Sub-Area `*`; Schwelle erfüllt.

**Vorgelagert — offene Beobachtungen sichten:** Treffer
[`BEO-ALL/slice-plan-umfang-waechst-ueber-umsetzung-hinaus`](../observations/BEO-ALL/slice-plan-umfang-waechst-ueber-umsetzung-hinaus/observation.md)
über der Schwelle.

**Modus-Begründungsblock — Umfang:** alle berührten Sub-Areas GF.
