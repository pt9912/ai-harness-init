# Slice slice-zusammenfassung-bleibt-innerhalb-ihrer-quelle: Eine Zusammenfassung bleibt innerhalb ihrer Quelle

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Begründet gegen die drei Fragen aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird):
(1) Bündel? Nein. (2) Gemeinsames Closure-Kriterium? Nein — es wäre die Abschrift der DoD.
(3) **Reaktiv:** eine Register-Beobachtung über der Schwelle. Damit nicht in der Roadmap geführt
([`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 2).

**Bezug:** [`AGENTS.md`](../../../../AGENTS.md) §3.7 (was ein Artefakt trägt),
[`AGENTS.md`](../../../../AGENTS.md) §3.2 (Source Precedence — die Quelle sticht, nicht ihre
Wiedergabe), [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert).

**Berührte Spec-Stellen:** `—`.

**Verantwortlich:** — bis zur Priorisierung.

**Autor:** Planner. **Datum:** 2026-09-14.

---

## 1. Ziel und Abgrenzung

**Ziel:** Die Regel, dass die Zusammenfassung eines referenzierten Artefakts nicht mehr zusagt als
ihre Quelle, steht an einem Norm-Artefakt — oder ihre fehlende Trägerschaft steht dort benannt.

Die Klasse hat heute keinen Zielort: Kein Modul aus `modules:` der
[`.d-check.yml`](../../../../.d-check.yml) hält eine Zusammenfassung gegen das Artefakt, auf das sie
zeigt — `links` prüft die Auflösbarkeit, nicht die Aussage. Beleg:
[`BEO-ALL/zusammenfassung-staerker-als-ihre-quelle`](../observations/BEO-ALL/zusammenfassung-staerker-als-ihre-quelle/observation.md)
(8 Belege).

**Ausdrücklich NICHT in diesem Slice:**

- **Die Auflösbarkeit der Verweise.** Sie ist `links` und bleibt dort — dieser Slice urteilt über
  die Aussage, nicht über die Adresse (Schicht-Abgrenzung).
- **Eine semantische Prüfung über den ganzen Bestand.** Ein Sensor, der Aussagen gegen Quellen
  hält, ist ein Urteil und kein Muster; die Regel ist zuerst zu schreiben, eine Mechanisierung wäre
  ein anderer Vorgang.
- **Der Bestand.** Geschriebene Zusammenfassungen werden nicht rückwirkend geprüft; gebunden ist
  der Satz, der geschrieben oder geändert wird.

## 2. Definition of Done

- [ ] Die Regel steht an einem Norm-Artefakt und nennt die Fehlerrichtung: die Wiedergabe sagt
      nicht mehr zu als ihre Quelle.
- [ ] Der Zielort trägt daneben die Aussage über die fehlende Bewachung — oder der Slice schneidet
      die fehlende Bewachung als benannte Lücke aus.
- [ ] Rot gesehen: ein Artefakt mit einer überzeichnenden Zusammenfassung färbt den benannten
      Träger rot **oder** die Zusage ist auf das eingeschränkt, was der Lauf hält.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`AGENTS.md`](../../../../AGENTS.md) §3 | update | Träger der Regel, wenn sie eine Hard Rule wird |
| [`.d-check.yml`](../../../../.d-check.yml) | update | Modul-Aktivierung, falls ein Modul die Form halten kann |
| [`test/`](../../../../test) | neu | Rot-Beleg über einer überzeichnenden Zusammenfassung |

## 4. Trigger

**Start** (`next` → `in-progress`): Priorisierung durch den Planner.

**Rückführungen:**

- `in-progress` → `next` (zu groß): wenn die Regel und eine Mechanisierung zusammen kommen sollen.
- `in-progress` → `open` (blockiert): wenn der Träger ohne eine Gate-Senkung nicht erreichbar wäre
  ([`AGENTS.md`](../../../../AGENTS.md) §3.5).

## 5. Closure-Trigger

DoD vollständig, Review ohne blockierenden Befund, Closure-Notiz geschrieben.

## 6. Risiken und offene Punkte

- Die Klasse ist ein Urteil und bekommt darum keinen Sensor — **Ausgang:** weiter offen →
  `BEO-ALL/zusammenfassung-staerker-als-ihre-quelle`.
- Die Regel greift nur für einen Artefakt-Typ — **Ausgang:** weiter offen →
  `BEO-ALL/zusammenfassung-staerker-als-ihre-quelle`.

## 7. Closure-Notiz

- **Was hat funktioniert:** —
- **Was ging anders als geplant:** —
- **Steering-Loop-Eintrag:** —
- **Beobachtungs-Register (`../observations/`):** —
- **Folge-Slices:** —

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührte Sub-Area `*` (gesamtes Repo,
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area));
Schwelle erfüllt.

**Vorgelagert — offene Beobachtungen sichten:** Treffer
[`BEO-ALL/zusammenfassung-staerker-als-ihre-quelle`](../observations/BEO-ALL/zusammenfassung-staerker-als-ihre-quelle/observation.md)
über der Schwelle — er ist der Gegenstand dieses Slice. Kein weiterer Treffer.

**Modus-Begründungsblock — Umfang:** alle berührten Sub-Areas GF.
