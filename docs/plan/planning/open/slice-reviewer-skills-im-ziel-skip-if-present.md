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

**Berührte Spec-Stellen:** [`spec/architecture.md`](../../../../spec/architecture.md) §5, `ARC-006`.

**Verantwortlich:** pt9912 (Implementer)

**Autor:** Planner. **Datum:** 2026-10-07.

---

## 1. Ziel und Abgrenzung

**Ziel:** `.harness/skills/reviewer.md` und `.harness/skills/closure-note-reviewer.md` entstehen im
Ziel nur an einem freien Pfad; der Lauf nennt je abweichend stehengelassenem Skill Pfad und
mitgelieferte Vorlage ([ADR-0084](../../adr/0084-reviewer-skills-im-ziel-skip-if-present.md)
Festlegungen 1–3).

**Lage** (keine Erwartungswerte): `grep -n 'HasPrefix(rel, ".harness/skills/")' internal/emit/templates.go`
nennt die konvergente Weiche in `Templates()`; die Funktion hat keinen Meldeweg, ihr einziger
Produkt-Aufrufer `emitAll` hält schon einen (`grep -n 'emit.Templates(' cmd/ai-harness-init/main.go`,
Parameter `notice io.Writer`), die Test-Aufrufe zählt `grep -rn 'emit.Templates(' --include=*_test.go . | wc -l`.
Vorbild der Meldung ist `writeSkipIfPresentTold` in `internal/emit/enforce.go`; anders als dort
meldet sie nur bei Abweichung — verglichen wird gegen den Inhalt, den `planTemplates` für den Pfad
liefert. Den Tag für den Vorlagen-Pfad der Meldung kennt `Templates()` nicht, nur sein Aufrufer.
Daneben nennen die Skills als kanonisch: [`spec/architecture.md`](../../../../spec/architecture.md)
§5 (`grep -n 'Baseline, Skills' spec/architecture.md`) und das Benutzerhandbuch
(`grep -n 'die Skills unter' docs/user/benutzerhandbuch.md`).

**Werkzeug der Ziel-Fälle.** Die Fitness-Zeile 2 der ADR nennt `make selbstpruefung`; deren Skript
fährt den Bootstrap nicht (`grep -n 'ai-harness-init' internal/emit/templates/enforce/selbstpruefung.sh`
nennt nur den Kopfkommentar), ein Re-Lauf ist dort nicht herstellbar. Die drei Fälle laufen darum
in `make full-smoke`, neben der Stufe *„Klasse des Commit-Traegers"*, die denselben Re-Lauf über
`tmprepo_doc` schon fährt (`grep -n 'Klasse des Commit-Traegers' harness/tools/full-smoke.sh`).
Die Regel der ADR bleibt, das Werkzeug wechselt; der Reviewer prüft den Wechsel gegen die ADR.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **[ADR-0007](../../adr/0007-bootstrap-phasen.md) und ihre Index-Marke.** *Bestand bleibt:* die ADR
  bleibt byte-gleich, die Marke setzte der Accept-Übergang.
- **Heilen veralteter Skills beim Baseline-Sprung.** *Bestand bleibt:* akzeptiertes Negativ
  ([ADR-0084](../../adr/0084-reviewer-skills-im-ziel-skip-if-present.md) Festlegung 4); der Abgleich ist Handarbeit des Adopters.
- **Trennung in tool-eigenen und Adopter-Teil.** *Anderer Vorgang:* Re-Evaluierungs-Trigger der ADR.
- **Die übrigen konvergenten Pfade der Zeile aus [ADR-0007](../../adr/0007-bootstrap-phasen.md).** *Schicht-Abgrenzung:* allein
  `.harness/skills/*` wechselt die Klasse.
- **`selbstpruefung.sh` um einen Bootstrap-Lauf erweitern.** *Anderer Vorgang:* das Skript prüft
  den Commit-Träger im Klon, nicht die Emission; die Fälle liegen in `make full-smoke` (§1 Lage).

## 2. Definition of Done

- [ ] **1 — Klasse und Meldung:** `internal/emit/templates.go` legt beide Skills skip-if-present ab;
      `Templates()` bekommt einen Meldeweg (Writer und Vorlagen-Pfad vom Aufrufer `emitAll`), die
      Meldung folgt der Form des Commit-Trägers
      ([ADR-0054](../../adr/0054-emittierter-commit-traeger-skip-if-present.md)), nennt Pfad und
      `.harness/baseline/<tag>/templates/.harness/skills/<name>.template.md` und erscheint nur, wenn
      die liegende Datei vom Inhalt aus `planTemplates` abweicht. Go-Test in
      `internal/emit/templates_test.go` (Dateisystem über `t.TempDir()`, Lauf in `make test`) ersetzt
      `TestTemplates_SkillsConvergent`: veränderter Skill bleibt byte-gleich und wird gemeldet,
      unveränderter meldet nichts, fehlender wird angelegt. **Rot gesehen**
      ([`AGENTS.md`](../../../../AGENTS.md) §3.6), zwei Wege: (a) `test/mutations/53-skills-konvergent.sh`
      neu geschrieben — `expect:` der neue Test, `sed`-Anker gegen die neue Quelle gemessen
      ([`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)),
      Skills wieder konvergent —, `make mutate MUTATE_CASES=53-skills-konvergent` meldet ihn
      gebunden; (b) Hand-Bruch: Byte-Vergleich entfernt (Meldung immer) → `make test` rot am Fall
      *„unverändert meldet nichts"*, Meldung gelesen, `git checkout -- internal/emit/templates.go`.
- [ ] **2 — Ziel:** neue Stufe in `harness/tools/full-smoke.sh` neben *„Klasse des
      Commit-Traegers"*: Re-Lauf des Bootstrap über `tmprepo_doc` mit drei Fällen (gefüllter
      Skill → byte-gleich und gemeldet · unverändert emittierter → keine Meldung · gelöschter →
      angelegt); `make full-smoke` EXIT 0, die Stufen-Deklaration (`e2e_abdeckung`) nennt, was sie
      misst, `make e2e-abdeckung` zieht `docs/user/e2e-abdeckung.md` nach. **Rot gesehen:** der
      `sed` aus Fall 53 von Hand auf `internal/emit/templates.go` angewandt → `make full-smoke` rot
      mit der FEHLER-Zeile der neuen Stufe (gelesen), danach `git checkout -- internal/emit/templates.go`.
- [ ] **3 — Texte:** `internal/emit/baumaussage.go` zählt die zwei Skills zu den genannten Pfaden,
      der Satz *„Einen einzigen solchen Pfad nennt der Lauf"* fällt (der Go-Test der Baum-Aussage
      zieht mit, `make test`); [`spec/architecture.md`](../../../../spec/architecture.md) §5 und
      `ARC-006` sowie `docs/user/benutzerhandbuch.md` (Skills aus der Zeile *kanonisch*, damit unter
      *nur bei fehlender Datei*) im Ist-Zustand.
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
| `internal/emit/templates.go`, `cmd/ai-harness-init/main.go` (`emitAll`) | update | Klasse und Meldeweg (Liefer-Punkt 1) |
| `internal/emit/*_test.go` (Aufrufe von `emit.Templates`), `test/mutations/53-skills-konvergent.sh` | update | Fitness-Zeilen 1 und 3 |
| `harness/tools/full-smoke.sh`, `docs/user/e2e-abdeckung.md` (erzeugt) | update | Liefer-Punkt 2 |
| `internal/emit/baumaussage.go` samt Test, `spec/architecture.md`, `docs/user/benutzerhandbuch.md` | update | Liefer-Punkt 3 |

## 4. Trigger

**Start** (`next` → `in-progress`): [ADR-0084](../../adr/0084-reviewer-skills-im-ziel-skip-if-present.md) `Accepted` (erfüllt); WIP-Limit frei.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next`: der Meldeweg zieht über die Test-Aufrufe von `emit.Templates` hinaus
  weitere Produkt-Aufrufer nach, als eine Review-Sitzung trägt — dann wird der Meldeweg als eigener
  Slice geschnitten.
- `in-progress` → `open`: die Lieferfassung ist für den Vergleich nicht eindeutig — etwa weil der
  gestempelte Projektname zwischen zwei Läufen wechselt und jeder Re-Lauf meldet — Übergabe an den
  Architect.

## 5. Closure-Trigger

1. `make full-smoke` EXIT 0 mit den drei Fällen der neuen Stufe.
2. `make gates` grün und `make mutate MUTATE_CASES=53-skills-konvergent` meldet den Fall gebunden.

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
