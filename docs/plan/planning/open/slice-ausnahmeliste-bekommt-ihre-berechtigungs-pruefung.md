# Slice slice-ausnahmeliste-bekommt-ihre-berechtigungs-pruefung: Die Ausnahmeliste bekommt ihren Ausgang

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. (1) Bündel? Nein. (2) Gemeinsames Closure-Kriterium? Nein.
(3) **Reaktiv:** eine Register-Beobachtung über der Schwelle. Begründet gegen die drei Fragen aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird).

**Bezug:** [`ADR-0035`](../../../../docs/plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
Festlegung 3 (Deklaration am Ort der Definition, genannter Grund, Zählung als **Rest**) — heute
`Proposed` und darum nicht bindend;
[`AGENTS.md`](../../../../AGENTS.md) §3.5 (eine Senkung ist ein ADR);
[`MR-029`](../../../../harness/conventions.md#mr-029--der-scanignore-zensus-wandert-und-sein-dritter-grund-ist-keine-scoping-aussage)
(dieselbe Klasse an einer benannten Ausnahmeliste, mit ihrer Grenze).

**Berührte Spec-Stellen:** `—`.

**Verantwortlich:** — bis zur Priorisierung.

**Autor:** Planner. **Datum:** 2026-09-14.

---

## 1. Ziel und Abgrenzung

**Ziel:** Die Regel, die eine deklarierte Ausnahmeliste jenseits von Existenz und Form schuldet,
hat einen tragenden Ort — oder die Entscheidung, die sie heute nur als `Proposed` führt, hat einen
Ausgang.

Die Klasse hat keinen Zielort: [`ADR-0035`](../../../../docs/plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
Festlegung 3 verlangt Deklaration, Grund und Zählung als Rest, steht aber auf `Proposed`, führt
keinen Acceptance-Trigger und hat keinen Träger-Slice. Beleg:
[`BEO-ALL/ausnahmeliste-nur-auf-form-geprueft`](../observations/BEO-ALL/ausnahmeliste-nur-auf-form-geprueft/observation.md)
(3 Belege).

**Ausdrücklich NICHT in diesem Slice:**

- **Die Ausnahmen selbst.** Kein Eintrag wird entfernt oder begründet; dieser Slice gibt ihrer
  Prüfung einen Ort.
- **`scan.ignore`.** Für diese eine Liste trägt [`MR-029`](../../../../harness/conventions.md#mr-029--der-scanignore-zensus-wandert-und-sein-dritter-grund-ist-keine-scoping-aussage)
  die Aussage bereits; ein Umbau dort wäre ein anderer Vorgang.
- **Der Bestand.** Bestehende Ausnahmen werden nicht rückwirkend geprüft.

## 2. Definition of Done

- [ ] [`ADR-0035`](../../../../docs/plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
      hat einen Ausgang: eine Reviewer-Runde führt sie nach
      [`ADR-0040`](../../../../docs/plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md)
      **oder** sie wird mit Begründung zurückgezogen; ein dritter Ausgang entsteht nicht.
- [ ] Der Ausgang nennt den tragenden Ort der Regel *Deklaration · Grund · Zählung als Rest*.
- [ ] Die Klasse ist damit entweder **verkörpert** oder als **gestrichen** mit Begründung im
      Register eingetragen — beides ist ein Ergebnis, ein stehengebliebenes `offen` ist keines.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`ADR-0035`](../../../../docs/plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) | update | Acceptance-Trigger nachtragen bzw. Status führen (§3.4: kein inhaltliches Überschreiben) |
| [`docs/plan/adr/README.md`](../../../../docs/plan/adr/README.md) | update | ADR-Index-Fortschreibung |
| [`docs/reviews/`](../../../../docs/reviews) | neu | die Reviewer-Runde, die den Übergang belegt |
| [`harness/conventions/`](../../../../harness/conventions) | neu | Adaptions-Eintrag, falls der Ausgang eine Abweichung setzt |

## 4. Trigger

**Start** (`next` → `in-progress`): Priorisierung durch den Planner.

**Rückführungen:**

- `in-progress` → `next` (zu groß): wenn der Ausgang den ganzen Adaptions-Block umbaut.
- `in-progress` → `open` (blockiert): wenn der Ausgang eine Senkung verlangt, für die eine eigene
  Entscheidung fehlt ([`AGENTS.md`](../../../../AGENTS.md) §3.5).

## 5. Closure-Trigger

DoD vollständig, Review ohne blockierenden Befund, Closure-Notiz geschrieben, Register-Zeile mit
Ausgang.

## 6. Risiken und offene Punkte

- Der Ausgang bleibt aus und die Zeile steht weiter `offen` — **Ausgang:** weiter offen →
  `BEO-ALL/ausnahmeliste-nur-auf-form-geprueft`.
- Die Runde blockiert und der Ausgang wird zur zweiten Runde — **Ausgang:** weiter offen →
  `BEO-ALL/ausnahmeliste-nur-auf-form-geprueft` (kein neuer Eintrag: derselbe Vorgang).

## 7. Closure-Notiz

- **Was hat funktioniert:** —
- **Was ging anders als geplant:** —
- **Steering-Loop-Eintrag:** —
- **Beobachtungs-Register (`../observations/`):** —
- **Folge-Slices:** —

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührte Sub-Area `*`; Schwelle erfüllt.

**Vorgelagert — offene Beobachtungen sichten:** Treffer
[`BEO-ALL/ausnahmeliste-nur-auf-form-geprueft`](../observations/BEO-ALL/ausnahmeliste-nur-auf-form-geprueft/observation.md)
über der Schwelle — er ist der Gegenstand dieses Slice.

**Modus-Begründungsblock — Umfang:** alle berührten Sub-Areas GF.
