# Slice slice-reviewer-skill-zieht-die-findings-form-nach: Der Reviewer-Skill verortet ein Finding über Datei und Zitat und meldet nichts ohne Failure-Szenario oder Konventions-Anker

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle — die Closure-Bedingung ist die DoD dieses Slice; Baseline-Regelwerk
`modul-06-roadmap.md` §Wann Arbeit eine Welle braucht.

**Ebene: Dogfood.** Gegenstand ist der Reviewer-Skill dieses Repos; im Ziel reisen die Vorlagen-Kopien
mit dem Pin (§1).

**Rollen-Zuschnitt: der Slice läuft im Reviewer-Kontext.** `.harness/skills/reviewer.md` ist der
Anweisungssatz der Reviewer-Rolle und gehört nach
[`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Festlegung 1 der Rolle,
die ihn ausführt (Anwendungs-Tabelle dort: `.harness/skills/reviewer.md` → Reviewer). Der Planner
schneidet, der **Reviewer schreibt**; `Verantwortlich:` bekommt beim `open → next` den
Reviewer-Rolleninhaber.

**Bezug:**
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`ADR-0078`](../../adr/0078-ziel-fassung-regiert-den-sprung-v6160.md) (Festlegung 3, Zeile Wellen
155–156), [`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md),
[`MR-033`](../../../../harness/conventions.md#mr-033).

**Berührte Spec-Stellen:** — (Gegenstand ist ein Rollen-Anweisungssatz).

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-10-06.

---
## 1. Ziel und Abgrenzung

**Ziel:** `.harness/skills/reviewer.md` trägt die Findings-Form der Reviewer-Vorlage am Tag
`v6.16.0` (Baseline-Regelwerk `modul-10-review-harness.md` und
`templates/.harness/skills/reviewer.template.md`, Wellen 155–156): das Feld `pfad` verortet über
**Datei · wörtliches Kurzzitat**, die Zeile ist nur Lesehilfe; **kein HIGH/MEDIUM ohne
Failure-Szenario**; **kein Stil-Finding ohne Konventions-Anker**.

**Lage** (Arbeitsbaum dieses Plans, keine Erwartungswerte):

```sh
grep -n 'pfad`: Datei:Zeile' .harness/skills/reviewer.md | wc -l    # 1
ls .harness/skills/                                                  # reviewer.md
```

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Keine Closure-Note-Reviewer-Datei.** *Anderer Vorgang:* das Repo führt keine ([ADR-0078](../../adr/0078-ziel-fassung-regiert-den-sprung-v6160.md)
  Festlegung 3); sie anzulegen wäre eine neue Skill-Datei mit eigenem Urteilstyp.
- **Der Baseline-Stand im Kopf der Skill-Datei.** *Folge-Slice:*
  [`slice-227`](slice-227-reviewer-skill-nennt-den-vorhandenen-stand.md).
- **Die Vorgangs-Grenze am Welle-Plan.** *Folge-Slice:*
  `slice-die-vorgangs-grenze-erreicht-den-reviewer-skill`.
- **Emittierte Ebene.** *Schicht-Abgrenzung:* Skill-Dateien im Ziel sind Vorlagen-Kopien und reisen
  mit dem Pin; die Rollen-Karte `agents/reviewer.md` trägt kein Output-Schema ([ADR-0078](../../adr/0078-ziel-fassung-regiert-den-sprung-v6160.md) §Emittierte
  Ebene).
- **Vorhandene Review-Reports.** *Bestand bleibt stehen:* Zeitdokumente
  ([`AGENTS.md`](../../../../AGENTS.md) §3.7 Geltungsbereich).

## 2. Definition of Done

- [ ] **1 — `pfad` = Datei · wörtliches Kurzzitat** im Output-Schema der Skill-Datei, die Zeile als
      Lesehilfe; das `grep`-Kommando aus §1 liefert **0**.
- [ ] **2 — Kein HIGH/MEDIUM ohne Failure-Szenario:** die Severity-Regel der Skill-Datei verlangt es
      und nennt den Ausgang eines Findings ohne Szenario.
- [ ] **3 — Kein Stil-Finding ohne Konventions-Anker:** die Kategorien-Regel verlangt den Pfad zur
      Konvention.
- [ ] **Grenze statt Rot-Beleg** ([`AGENTS.md`](../../../../AGENTS.md) §3.6): kein Sensor liest die
      Skill-Datei gegen ihre Vorlage; die Lücke steht im Commit benannt, Träger ist der
      Review-Lauf.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor — in einem anderen Kontext als
      dem schreibenden Reviewer-Lauf, kein Self-Review (Modul 8).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Reconciliation-Register: entfällt — kein Brownfield-Bootstrap.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben, oder „keine Beobachtung" in §7.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen prüft die nächste Welle-Closure (das Repo fährt Wellen).

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `.harness/skills/reviewer.md` | update | Liefer-Punkte 1–3, Commit der Reviewer-Rolle ([ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)) |

## 4. Trigger

**Start** (`next` → `in-progress`): `slice-sprung-auf-v6160-wird-vollzogen` liegt in `done/` — die
Vorlage am Tag `v6.16.0` ist dann vendored. WIP-Limit des Reviewer-Rolleninhabers frei.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next`: Die neue Form verlangt einen Umbau des Report-Formats über die
  Skill-Datei hinaus — dann wird der Umbau ein eigener Slice.
- `in-progress` → `open`: Eine der drei Regeln widerspricht einer Zeile der Skill-Datei, die ein
  Architect-Verdikt trägt — Übergabe an den Architect.

## 5. Closure-Trigger

1. Das `grep`-Kommando aus Liefer-Punkt 1 liefert **0**, und die zwei Ausschlüsse stehen in der
   Skill-Datei.
2. Der Review-Report dieses Slice liegt vor und verortet seine Findings bereits in der neuen Form.

**Lerneintrag** in einer der drei Formen, §7; die Closure schreibt der Planner
([`AGENTS.md`](../../../../AGENTS.md) §3.10).

## 6. Risiken und offene Punkte

- **Findings-Klasse wird neu benannt statt zitiert** — die Umformung des Schemas lädt dazu ein;
  `finding-klasse-wird-neu-benannt-statt-zitiert` steht bei
  1 Belegen. — **Ausgang:** offen bis zur Closure.
- **Überschneidung mit den zwei Reviewer-Slices in `open/` und `next/`** — dieselbe Datei. —
  **Ausgang:** offen bis zur Closure.

## 7. Closure-Notiz

- **Was hat funktioniert:** —
- **Was ging anders als geplant:** —
- **Steering-Loop-Eintrag:** —
- **Beobachtungs-Register (`../observations/`):** —
- **Folge-Slices:** —
- **Risiken aus §6:** —

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist `*` (gesamtes Repo) — `.harness/skills/` liegt in
keiner engeren deklarierten Sub-Area.

**Vorgelagert — offene Beobachtungen sichten:** Register am gemergten Stand gesichtet, nach
Gegenstand; Zähler `ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l`:
`finding-klasse-wird-neu-benannt-statt-zitiert` — 1;
`stand-feld-ausserhalb-des-konventionsspeichers-bleibt-beim-sprung-stehen` —
1 (Kopf der Datei, §1:
Folge-Slice).

**Alle berührten Sub-Areas GF** ([`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area).

