# Slice slice-zitat-pruefung-liest-statt-greppt: Eine Zitat-Prüfung liest, statt zu greppen

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. (1) Bündel? Nein. (2) Gemeinsames Closure-Kriterium? Nein.
(3) **Reaktiv:** eine Register-Beobachtung über der Schwelle. Begründet gegen die drei Fragen aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird);
damit nicht in der Roadmap geführt.

**Bezug:** [`MR-011`](../../../../harness/conventions.md#mr-011--zitat-verifikation-via-d-check-adoptiert-check-lines)
(die Zitat-Verifikation über `codepaths.check-lines`),
[`MR-033`](../../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
(eine Aussage über die Baseline nennt ihren Mess-Tag).

**Berührte Spec-Stellen:** `—`.

**Verantwortlich:** — bis zur Priorisierung.

**Autor:** Planner. **Datum:** 2026-09-14.

---

## 1. Ziel und Abgrenzung

**Ziel:** Eine Zitat-Prüfung liest den zitierten Abschnitt an seiner Quelle, statt ihn über ein
Muster zu suchen — ein Zeilenumbruch oder Inline-Markup trennt das Muster, ohne dass der Satz fort
ist. Die Regel steht an einem Norm-Artefakt.

Die Klasse hat keinen Zielort: Kein Modul aus `modules:` der
[`.d-check.yml`](../../../../.d-check.yml) hält ein Zitat gegen seine Quelle. Beleg:
[`BEO-ALL/zitat-grep-uebersieht-zeilenumbruch-und-markup`](../observations/BEO-ALL/zitat-grep-uebersieht-zeilenumbruch-und-markup/observation.md)
(3 Belege).

**Ausdrücklich NICHT in diesem Slice:**

- **Die Zitat-Verifikation als Mechanik.** `codepaths.check-lines` ist eine bestehende Fähigkeit;
  dieser Slice schreibt die Regel für den **prüfenden Lauf**, er baut kein Modul (Schicht-Abgrenzung).
- **Eine Räumung bestehender Zitate.** Gebunden ist der Lauf, der prüft, nicht der Bestand.
- **Der Baseline-Pin.** Er ist nicht Gegenstand dieses Slice.

## 2. Definition of Done

- [ ] Die Regel steht an einem Norm-Artefakt: eine Prüfung eines zitierten Satzes liest ihn und
      sucht ihn nicht über ein Muster.
- [ ] Der Zielort nennt die zwei Trenn-Fälle (Zeilenumbruch, Inline-Markup) und die Fehlerrichtung
      *der Satz ist fort* statt *der Satz steht*.
- [ ] Rot gesehen: ein zitiertes Artefakt mit umgebrochenem Satz färbt die benannte Prüfung rot
      **oder** die Zusage ist auf das eingeschränkt, was der Lauf hält.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| Anweisungssatz bzw. `AGENTS.md` §3 | update | Träger der Prüf-Regel |
| [`harness/sensors/`](../../../../harness/sensors) | update | Grenze, wo die Prüfung mechanisch ist und wo nicht |
| [`test/`](../../../../test) | neu | Rot-Beleg über einem Zitat mit Zeilenumbruch |

## 4. Trigger

**Start** (`next` → `in-progress`): Priorisierung durch den Planner.

**Rückführungen:**

- `in-progress` → `next` (zu groß): wenn Regel und Mechanik zusammen kommen.
- `in-progress` → `open` (blockiert): wenn der Träger eine Gate-Senkung verlangt.

## 5. Closure-Trigger

DoD vollständig, Review ohne blockierenden Befund, Closure-Notiz geschrieben.

## 6. Risiken und offene Punkte

- Die Prüfung bleibt ein Urteil und bekommt keinen Sensor — **Ausgang:** weiter offen →
  `BEO-ALL/zitat-grep-uebersieht-zeilenumbruch-und-markup`.
- Die Regel greift nur für die Baseline, nicht für repo-eigene Zitate — **Ausgang:** weiter offen →
  `BEO-ALL/zitat-grep-uebersieht-zeilenumbruch-und-markup`.

## 7. Closure-Notiz

- **Was hat funktioniert:** —
- **Was ging anders als geplant:** —
- **Steering-Loop-Eintrag:** —
- **Beobachtungs-Register (`../observations/`):** —
- **Folge-Slices:** —

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührte Sub-Area `*`; Schwelle erfüllt.

**Vorgelagert — offene Beobachtungen sichten:** Treffer
[`BEO-ALL/zitat-grep-uebersieht-zeilenumbruch-und-markup`](../observations/BEO-ALL/zitat-grep-uebersieht-zeilenumbruch-und-markup/observation.md)
über der Schwelle — er ist der Gegenstand dieses Slice.

**Modus-Begründungsblock — Umfang:** alle berührten Sub-Areas GF.
