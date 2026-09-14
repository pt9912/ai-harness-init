# Slice slice-zaehler-label-nennt-seine-einheit: Ein Zähler-Label nennt seine Einheit

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. (1) Bündel? Nein. (2) Gemeinsames Closure-Kriterium? Nein.
(3) **Reaktiv:** eine Register-Beobachtung über der Schwelle. Begründet gegen die drei Fragen aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird).

**Bezug:** [`AGENTS.md`](../../../../AGENTS.md) §3.1 (ein Gate darf nicht mehr behaupten, als es
misst), [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2 (eine Zahl misst ihren Gegenstand), [`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung).

**Berührte Spec-Stellen:** `—`.

**Verantwortlich:** — bis zur Priorisierung.

**Autor:** Planner. **Datum:** 2026-09-14.

---

## 1. Ziel und Abgrenzung

**Ziel:** Ein Zähler-Label nennt die Einheit, die der Zähler zählt — der Aufrufer zählt seine Zahl
sonst gegen den falschen Gegenstand ab. Die Regel steht an einem Norm-Artefakt.

Die Klasse hat keinen Zielort: Kein Modul aus `modules:` der
[`.d-check.yml`](../../../../.d-check.yml) hält ein Label gegen seinen Zähler. Die beiden bekannten
Träger sind repariert, die Klasse bleibt es nicht. Beleg:
[`BEO-ALL/zaehler-label-nennt-falsche-einheit`](../observations/BEO-ALL/zaehler-label-nennt-falsche-einheit/observation.md)
(3 Belege).

**Ausdrücklich NICHT in diesem Slice:**

- **Ein Sensor über allen Ausgabe-Labels.** Ob ein Label seine Einheit nennt, ist an der Form
  entscheidbar, nicht am Inhalt; eine Mechanik wäre ein anderer Vorgang.
- **Der Bestand.** Reparierte Träger werden nicht nachgezogen; gebunden ist die Ausgabe, die
  geschrieben oder geändert wird.
- **Die Zähler-Semantik selbst.** Dieser Slice regelt die Beschriftung, nicht was gezählt wird.

## 2. Definition of Done

- [ ] Die Regel steht an einem Norm-Artefakt: ein Label nennt die Einheit, die sein Zähler zählt.
- [ ] Der Zielort nennt die Fehlerrichtung: der Aufrufer zählt gegen den falschen Gegenstand.
- [ ] Rot gesehen: ein Label mit falscher Einheit färbt den benannten Träger rot **oder** die
      Zusage ist auf das eingeschränkt, was der Lauf hält.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`AGENTS.md`](../../../../AGENTS.md) §3 bzw. Anweisungssatz | update | Träger der Regel |
| [`harness/tools/`](../../../../harness/tools) | update | die Ausgabe, die ihr Label trägt |
| [`test/`](../../../../test) | neu | Rot-Beleg über einem Label mit falscher Einheit |

## 4. Trigger

**Start** (`next` → `in-progress`): Priorisierung durch den Planner.

**Rückführungen:**

- `in-progress` → `next` (zu groß): wenn die Regel mehrere Ausgabe-Träger zugleich umbaut.
- `in-progress` → `open` (blockiert): wenn der Träger eine Gate-Senkung verlangt.

## 5. Closure-Trigger

DoD vollständig, Review ohne blockierenden Befund, Closure-Notiz geschrieben.

## 6. Risiken und offene Punkte

- Die Regel bleibt ohne Sensor und wirkt nur über den Schreibenden — **Ausgang:** weiter offen →
  `BEO-ALL/zaehler-label-nennt-falsche-einheit`.
- Die Klasse tritt an einem Träger wieder auf, den dieser Slice nicht kennt — **Ausgang:** weiter
  offen → `BEO-ALL/zaehler-label-nennt-falsche-einheit`.

## 7. Closure-Notiz

- **Was hat funktioniert:** —
- **Was ging anders als geplant:** —
- **Steering-Loop-Eintrag:** —
- **Beobachtungs-Register (`../observations/`):** —
- **Folge-Slices:** —

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührte Sub-Area `*`; Schwelle erfüllt.

**Vorgelagert — offene Beobachtungen sichten:** Treffer
[`BEO-ALL/zaehler-label-nennt-falsche-einheit`](../observations/BEO-ALL/zaehler-label-nennt-falsche-einheit/observation.md)
über der Schwelle.

**Modus-Begründungsblock — Umfang:** alle berührten Sub-Areas GF.
