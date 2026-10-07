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

- [x] **1 — Klasse und Meldung:** `internal/emit/templates.go` legt beide Skills skip-if-present ab;
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
- [x] **2 — Ziel:** neue Stufe in `harness/tools/full-smoke.sh` neben *„Klasse des
      Commit-Traegers"*: Re-Lauf des Bootstrap über `tmprepo_doc` mit drei Fällen (gefüllter
      Skill → byte-gleich und gemeldet · unverändert emittierter → keine Meldung · gelöschter →
      angelegt); `make full-smoke` EXIT 0, die Stufen-Deklaration (`e2e_abdeckung`) nennt, was sie
      misst, `make e2e-abdeckung` zieht `docs/user/e2e-abdeckung.md` nach. **Rot gesehen:** der
      `sed` aus Fall 53 von Hand auf `internal/emit/templates.go` angewandt → `make full-smoke` rot
      mit der FEHLER-Zeile der neuen Stufe (gelesen), danach `git checkout -- internal/emit/templates.go`.
- [x] **3 — Texte:** `internal/emit/baumaussage.go` nennt jeden Pfad, den ein Re-Lauf meldet —
      die Skip-if-present-Pfade der Durchsetzungsschicht abgeleitet aus den Listen von `Enforce`
      (`gemeldetePfade`) und die zwei Skills bei Abweichung —, der Satz *„Einen einzigen solchen
      Pfad nennt der Lauf"* fällt (`TestBaumAussage_NenntDieGemeldetenPfade` hält ihn gegen die
      Meldungen eines realen Re-Laufs, `make test`); [`spec/architecture.md`](../../../../spec/architecture.md) §5 und
      `ARC-006` sowie `docs/user/benutzerhandbuch.md` (Skills aus der Zeile *kanonisch*, damit unter
      *nur bei fehlender Datei*) im Ist-Zustand.
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Reconciliation-Register: entfällt — kein Brownfield-Bootstrap.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben, oder „keine Beobachtung" in §7.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen prüft die nächste Welle-Closure (das Repo fährt Wellen); nach dem Move gefahren, §7.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/emit/templates.go`, `cmd/ai-harness-init/main.go` (`emitAll`) | update | Klasse und Meldeweg (Liefer-Punkt 1) |
| `internal/emit/*_test.go` (Aufrufe von `emit.Templates`), `test/mutations/53-skills-konvergent.sh` | update | Fitness-Zeilen 1 und 3 |
| `harness/tools/full-smoke.sh`, `docs/user/e2e-abdeckung.md` (erzeugt) | update | Liefer-Punkt 2 |
| `internal/emit/baumaussage.go` samt Test, `spec/architecture.md`, `docs/user/benutzerhandbuch.md` | update | Liefer-Punkt 3; die Pfad-Liste der Baum-Aussage aus den `Enforce`-Listen abgeleitet (`gemeldetePfade`, Review M-1) |

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
  bleibt still stehen. — **Ausgang:** entfallen — der einzige Produkt-Aufrufer `emitAll` reicht
  `notice` (stderr) durch, die Meldung steht im `make full-smoke`-Log der Stufe *„Klasse der
  Reviewer-Skills"* ([Verifikation](../../../reviews/2026-10-07-skills-verifikation.md)).

## 7. Closure-Notiz

Geschrieben vom Planner in eigenem Kontext ([`AGENTS.md`](../../../../AGENTS.md) §3.10).
**Rolle:** Planner · **Datum:** 2026-10-07

- **Was hat funktioniert:** DoD 1 und 2 bestätigt, Rot-Belege vom Verifier nachgetragen;
  `make full-smoke` EXIT 0 mit der Stufe *„Klasse der Reviewer-Skills"*
  ([Verifikation](../../../reviews/2026-10-07-skills-verifikation.md)). Review 0 HIGH; M-1 behoben
  in `8c107d59` und `ee02d31e`; M-2 per [Architect-Verdikt](../../../reviews/2026-10-07-skills-architect-verdikt.md)
  ohne Folge-ADR, Messort in `make full-smoke` statt `make selbstpruefung` (§1 Lage); INFO-1:
  `d66451f5` allein nicht grün, gemeinsam gepusht
  ([Review](../../../reviews/2026-10-07-skills-review.md)). DoD 3 nach Verifikations-Befund V-1
  (Handbuch) mit `27452ecb` erfüllt, gegen einen doppelten Bootstrap geprüft.
- **Was ging anders als geplant:** Die Baum-Aussage nennt jeden gemeldeten Pfad, abgeleitet aus
  `Enforce` (`gemeldetePfade`), nicht nur die zwei Skills; DoD 3 und §3 im Closure-Commit
  nachgezogen. Commit `ee02d31e` trägt die Message von `3f068403` (*„full-smoke ordnet den
  Welle-1-Lauf der Grenze ein"*, Kennung [ADR-0081](../../adr/0081-altbestand-grenze-aus-der-commit-abstammung.md)), sein Inhalt ist der funlen-Nachzug zu M-1 in
  `internal/emit/baumaussage.go`; Herkunft ungeklärt, bleibt stehen (Auftraggeber-Entscheidung).
- **Steering-Loop-Eintrag:** *Benannte Sensor-Lücke*: kein Träger hält die Message eines Commits
  gegen seinen Inhalt — die Kennungs-Träger prüfen Anwesenheit, nicht Zugehörigkeit. Nicht
  verkörpert, gezählt im Register (unten).
- **Beobachtungs-Register (`../observations/`):**
  [`BEO-ALL/commit-traegt-die-message-eines-fremden-vorgangs`](../observations/BEO-ALL/commit-traegt-die-message-eines-fremden-vorgangs/observation.md)
  neu (1×); nicht `amend-committet-fremde-index-eintraege-mit` — dort reist fremder Inhalt unter
  eigener Message, hier eigener Inhalt unter fremder.
  [`BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht`](../observations/BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht/observation.md)
  Beleg ergänzt (M-1 und V-1, ein Vorgang), Stand verkörpert unverändert.
  `BEO-ALL/idempotente-anlage-erreicht-den-bestand-nicht` nicht aufgetreten — die Stufe misst den
  Re-Lauf am bestehenden Ziel; bleibt bei 2.
- **Folge-Slices:** keiner.
- **Trigger-Audit:** Carveouts: keiner berührt. Bootstrap-aware Gates: keines berührt. ADR:
  [ADR-0084](../../adr/0084-reviewer-skills-im-ziel-skip-if-present.md) umgesetzt, kein
  Re-Evaluierungs-Trigger eingetreten. Hard Rules: keine mit Auflösungs-Trigger aus diesem Vorgang.
- **Risiken aus §6:** Jede Zeile in §6 trägt ihren Ausgang.
- **Paarungen geprüft am 2026-10-07** (nach dem Move): (a) *Anker*: §7 trägt kein Feld `liegt in`,
  nichts zu prüfen. (b) *Folge-Slice*: keiner genannt. (c) *Register*: die zwei genannten Pfade
  existieren, `evidence/` trägt 1 und 9 Dateien. Zweite Hälfte über das ganze Register: 3
  Verzeichnisse ohne Beleg, namentlich `BEO-ALL/cpp-skelett-erfuellt-die-messmethode-von-lh-qa-02-nicht`,
  `BEO-ALL/einstiegs-datei-weicht-von-der-pflichtgliederung-ab`,
  `BEO-ALL/planungs-bestand-waechst-schneller-als-er-abgebaut-wird`; sie gelten nicht als getragen
  ([`ADR-0069`](../../adr/0069-beleglose-register-verzeichnisse-sind-ein-befund-der-paarung-keine-ausnahme.md)
  Festlegung 2).

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
