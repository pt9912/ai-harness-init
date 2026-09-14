# Slice slice-offene-plaene-gegen-den-neuen-stand: Die offenen Pläne werden gegen den neuen Stand gehalten

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. (1) Bündel? Nein. (2) Gemeinsames Closure-Kriterium? Nein.
(3) **Reaktiv:** eine Register-Beobachtung über der Schwelle. Begründet gegen die drei Fragen aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird);
damit nicht in der Roadmap geführt (Setzung 2).

**Bezug:** [`ADR-0018`](../../../../docs/plan/adr/0018-ziel-fassung-regiert-die-migration.md)
(die Migrations-Prozedur und ihre Schritte),
[`ADR-0031`](../../../../docs/plan/adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md)
(Festlegung 2 — Ort und Form der Zielstand-Setzung),
[`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer).

**Berührte Spec-Stellen:** `—`.

**Verantwortlich:** — bis zur Priorisierung.

**Autor:** Planner. **Datum:** 2026-09-14.

---

## 1. Ziel und Abgrenzung

**Ziel:** Nach einem Baseline-Sprung wird der Bestand offener Slice-Pläne gegen den neuen Stand
gehalten, und ein Plan, dessen **Pflicht** sich verschoben hat, wird sichtbar, statt
weitergeschoben zu werden. Der Schritt steht an einem Norm-Artefakt.

Die Klasse hat keinen Zielort: kein Schritt dieses Repos liest die offenen Pläne gegen das
getauschte Regelwerk. Beleg:
[`BEO-ALL/folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht`](../observations/BEO-ALL/folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht/observation.md)
(6 Belege).

**Ausdrücklich NICHT in diesem Slice:**

- **Der Sprung selbst.** Pin und Baum-Tausch sind eigene Vorgänge mit eigener Entscheidung; dieser
  Slice hängt sich an einen vollzogenen Sprung, er vollzieht keinen.
- **Die Form-Nachzüge.** Zitate, Pfade und Platzhalter ziehen andere Träger nach; dieser Slice
  liest die **Pflicht**, nicht die Form (Schicht-Abgrenzung).
- **Der Bestand als Auftrag.** Kein Plan wird rückwirkend umgeschrieben; gebunden ist die
  Sichtung, die der nächste Sprung auslöst.

## 2. Definition of Done

- [ ] Der Schritt steht an einem Norm-Artefakt (Migrations-Prozedur oder Nachbar-Regel) und nennt
      ihn beobachtbar: welche Menge wird gegen welchen Stand gehalten.
- [ ] Die Menge ist benannt und messbar — die offenen Slice-Pläne über ihren Lifecycle-Verzeichnissen.
- [ ] Rot gesehen: ein offener Plan mit verschobener Pflicht fällt in der Sichtung auf **oder** die
      Zusage ist auf das eingeschränkt, was der Lauf hält.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| Migrations-Prozedur ([`ADR-0018`](../../../../docs/plan/adr/0018-ziel-fassung-regiert-die-migration.md) folgend) bzw. `AGENTS.md` §3 | update | Träger des Schritts |
| [`harness/tools/`](../../../../harness/tools) | neu | Träger, wenn die Sichtung mechanisch wird |
| [`test/`](../../../../test) | neu | Rot-Beleg über einem Plan mit verschobener Pflicht |

## 4. Trigger

**Start** (`next` → `in-progress`): Priorisierung durch den Planner.

**Rückführungen:**

- `in-progress` → `next` (zu groß): wenn die Sichtung und eine Mechanisierung zusammen kommen.
- `in-progress` → `open` (blockiert): wenn der Schritt ohne Eingriff in die Migrations-Prozedur
  nicht erreichbar ist.

## 5. Closure-Trigger

DoD vollständig, Review ohne blockierenden Befund, Closure-Notiz geschrieben.

## 6. Risiken und offene Punkte

- Ob ein Plan durch den Sprung anders **verpflichtet** ist, bleibt Urteil je Plan —
  **Ausgang:** weiter offen → `BEO-ALL/folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht`.
- Die Sichtung läuft nur, wenn ein Sprung stattfindet — **Ausgang:** weiter offen →
  `BEO-ALL/re-baseline-ohne-inventur-slice`.

## 7. Closure-Notiz

- **Was hat funktioniert:** —
- **Was ging anders als geplant:** —
- **Steering-Loop-Eintrag:** —
- **Beobachtungs-Register (`../observations/`):** —
- **Folge-Slices:** —

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührte Sub-Area `*`; Schwelle erfüllt
([`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area)).

**Vorgelagert — offene Beobachtungen sichten:** Treffer
[`BEO-ALL/folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht`](../observations/BEO-ALL/folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht/observation.md)
über der Schwelle. Daneben steht
[`BEO-ALL/re-baseline-ohne-inventur-slice`](../observations/BEO-ALL/re-baseline-ohne-inventur-slice/observation.md)
unter der Schwelle und bleibt dort.

**Modus-Begründungsblock — Umfang:** alle berührten Sub-Areas GF.
