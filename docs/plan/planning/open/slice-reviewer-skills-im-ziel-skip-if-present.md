# Slice slice-reviewer-skills-im-ziel-skip-if-present: Die Reviewer-Skills liegen im Ziel skip-if-present

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle — die Closure-Bedingung ist die DoD dieses Slice; Baseline-Regelwerk
`modul-06-roadmap.md` §Wann Arbeit eine Welle braucht. Ziel-Release: `v0.5.0` (minor: der Re-Lauf
ändert sein Verhalten).

**Bezug:**
[`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3),
[ADR-0084](../../adr/0084-reviewer-skills-im-ziel-skip-if-present.md) (Festlegungen 1–4,
§Fitness Function, Folgepflicht), [ADR-0007](../../adr/0007-bootstrap-phasen.md) (bleibt byte-gleich),
[ADR-0054](../../adr/0054-emittierter-commit-traeger-skip-if-present.md) (Form der Meldung).

**Berührte Spec-Stellen:** [`spec/architecture.md`](../../../../spec/architecture.md) §5.

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-10-07.

---

## 1. Ziel und Abgrenzung

**Ziel:** `.harness/skills/reviewer.md` und `.harness/skills/closure-note-reviewer.md` entstehen im
Ziel nur an einem freien Pfad; der Lauf nennt je abweichend stehengelassenem Skill Pfad und
mitgelieferte Vorlage ([ADR-0084](../../adr/0084-reviewer-skills-im-ziel-skip-if-present.md)
Festlegungen 1–3).

**Lage** (keine Erwartungswerte): `grep -n 'skills' internal/emit/templates.go` nennt die heutige
konvergente Klasse; `grep -n 'func Templates' internal/emit/*.go` die Funktion ohne Meldeweg.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **[ADR-0007](../../adr/0007-bootstrap-phasen.md) und ihre Index-Marke.** *Bestand bleibt:* die ADR
  bleibt byte-gleich, die Marke setzte der Accept-Übergang.
- **Heilen veralteter Skills beim Baseline-Sprung.** *Bestand bleibt:* akzeptiertes Negativ
  ([ADR-0084](../../adr/0084-reviewer-skills-im-ziel-skip-if-present.md) Festlegung 4); der Abgleich ist Handarbeit des Adopters.
- **Trennung in tool-eigenen und Adopter-Teil.** *Anderer Vorgang:* Re-Evaluierungs-Trigger der ADR.
- **Die übrigen konvergenten Pfade der Zeile aus [ADR-0007](../../adr/0007-bootstrap-phasen.md).** *Schicht-Abgrenzung:* allein
  `.harness/skills/*` wechselt die Klasse.

## 2. Definition of Done

- [ ] **1 — Klasse und Meldung:** `internal/emit/templates.go` legt beide Skills skip-if-present ab;
      `Templates()` bekommt einen Meldeweg, die Meldung folgt der Form des Commit-Trägers
      ([ADR-0054](../../adr/0054-emittierter-commit-traeger-skip-if-present.md)) und erscheint nur bei
      Abweichung von der Lieferfassung. Go-Test ersetzt `TestTemplates_SkillsConvergent`: veränderter
      Skill überlebt den zweiten Lauf byte-gleich und wird gemeldet, unveränderter meldet nichts,
      fehlender wird angelegt. **Rot gesehen** ([`AGENTS.md`](../../../../AGENTS.md) §3.6):
      `test/mutations/53-skills-konvergent.sh` umgekehrt (Skills wieder konvergent → der Go-Test rot),
      `make mutate MUTATE_CASES=…` meldet ihn gebunden.
- [ ] **2 — Ziel:** `make selbstpruefung` mit den drei Fällen der §Fitness Function (gefüllt →
      unverändert und gemeldet · unverändert → keine Meldung · fehlend → angelegt), gefahren von
      `make full-smoke` (EXIT 0); die Stufen-Deklaration nennt, was sie misst.
- [ ] **3 — Texte:** `internal/emit/baumaussage.go` zählt die zwei Skills zu den genannten Pfaden,
      der Satz *„Einen einzigen solchen Pfad nennt der Lauf"* fällt;
      [`spec/architecture.md`](../../../../spec/architecture.md) §5 und das Benutzerhandbuch (falls es
      die Klasse nennt) im Ist-Zustand.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Reconciliation-Register: entfällt — kein Brownfield-Bootstrap.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben, oder „keine Beobachtung" in §7.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen prüft die nächste Welle-Closure (das Repo fährt Wellen).

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/emit/templates.go`, Aufrufer von `Templates()` | update | Klasse und Meldeweg (Liefer-Punkt 1) |
| `internal/emit/*_test.go`, `test/mutations/53-skills-konvergent.sh` | update | Fitness-Zeilen 1 und 3 |
| `internal/emit/templates/enforce/selbstpruefung.sh`, `harness/tools/full-smoke.sh` | update | Liefer-Punkt 2 |
| `internal/emit/baumaussage.go`, `spec/architecture.md`, Benutzerhandbuch | update | Liefer-Punkt 3 |

## 4. Trigger

**Start** (`next` → `in-progress`): [ADR-0084](../../adr/0084-reviewer-skills-im-ziel-skip-if-present.md) `Accepted` (erfüllt); WIP-Limit frei.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next`: der Meldeweg für `Templates()` zieht mehr Aufrufer nach, als eine
  Review-Sitzung trägt — dann wird der Meldeweg als eigener Slice geschnitten.
- `in-progress` → `open`: die Lieferfassung ist für den Vergleich nicht eindeutig (z. B. sie hängt am
  Tag) — Übergabe an den Architect.

## 5. Closure-Trigger

1. `make full-smoke` EXIT 0 mit den drei Fällen der Selbstprüfung.
2. `make gates` grün und der umgekehrte Fall 53 als gebunden gemeldet.

**Lerneintrag** in einer der drei Formen, §7; die Closure schreibt der Planner
([`AGENTS.md`](../../../../AGENTS.md) §3.10).

## 6. Risiken und offene Punkte

- **Meldung erreicht den Nutzer nicht** — ein Aufrufer verwirft den neuen Rückgabewert, der Skill
  bleibt still stehen. — **Ausgang:** offen bis zur Closure.

## 7. Closure-Notiz

- **Was hat funktioniert:** —
- **Was ging anders als geplant:** —
- **Steering-Loop-Eintrag:** —
- **Beobachtungs-Register (`../observations/`):** —
- **Folge-Slices:** —
- **Risiken aus §6:** —

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist `*` (`internal/emit`, `spec/architecture.md`,
`docs/user/`); `TOOLS` nur über `full-smoke.sh`, dessen Aussage dem Produkt gilt; `CODEX` nicht.

**Vorgelagert — offene Beobachtungen sichten:** Register am gemergten Stand gesichtet
(`grep -l 'Skill\|skip-if-present\|reviewer.md' docs/plan/planning/observations/BEO-ALL/*/observation.md`):
`BEO-ALL/idempotente-anlage-erreicht-den-bestand-nicht` (2, offen) — tritt die Klasse in diesem
Vorgang auf, steht er bei 3 und braucht beim Lese-Schritt einen Ausgang;
`BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht` (8, verkörpert in `AGENTS.md`
§3.6) — die Meldung nennt genau, was der Lauf stehen lässt.

**Alle berührten Sub-Areas GF** ([`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area).
