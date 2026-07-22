# Slice slice-030: Reviewer-/Closure-Skill emittieren

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.0/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-04-durchsetzung-und-emission](../welle-04-durchsetzung-und-emission.md).

**Bezug:** [`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren), [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`ADR-0006`](../../../../docs/plan/adr/0006-durchsetzung-commands-tool-als-quelle.md).

**Autor:** Claude (Pair-Session). **Datum:** 2026-07-22.

---

## 1. Ziel

Der Emit legt die **Reviewer-/Closure-Skills** ins Zielrepo (`.harness/skills/reviewer.md`,
`.harness/skills/closure-note-reviewer.md`) — aus dem gepinnten Kurs-Template-Satz (Fetch; die
Skills bleiben laut [`ADR-0006`](../../../../docs/plan/adr/0006-durchsetzung-commands-tool-als-quelle.md)
bei Fetch, nur Guard/Commands wechseln auf Tool-als-Quelle). Das ist der **de-riskende erste Schritt**
der Durchsetzungs-Emission: er öffnet den `.harness/skills/`-Emit-Pfad (heute in `emit.inScope`
bewusst ausgeschlossen), auf dem slice-031–033 aufsetzen.

## 2. Definition of Done

- [ ] [`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) (Skill-Teil): der Emit legt `.harness/skills/reviewer.md` **und** `.harness/skills/closure-note-reviewer.md` ins Ziel (aus den vendored `.template.md`, Hinweis-Block gestrippt + `<Projektname>` gestempelt, wie ein Singleton). Test belegt: emittiert.
- [ ] `emit.inScope` schließt `.harness/skills/` **nicht mehr** aus — der frühere Ausschluss-Kommentar („eigener Emit-Schritt" der Durchsetzungsschicht) ist mit diesem Slice eingelöst.
- [ ] Emit-Tests (`TestTemplates_EmittierterBestandVollstaendig`) + `test/courseset-fixture.bats` an die neue Zielmenge (jetzt inkl. der 2 Skills) angeglichen — Fixture und Emit koppeln denselben Bestand.
- [ ] [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6): `make smoke`/`make full-smoke` belegen die Skills real im Ziel (nicht nur behauptet).
- [ ] `make gates` grün; `make mutate` deckt die neuen Wächter (rot gesehen).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

<!--
Welche Änderungen sind geplant? Datei- oder Komponenten-Ebene reicht.
Der Implementation-Agent erweitert diese Liste in seinem ersten Lauf.
-->

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/emit/templates.go` | refactor | `inScope`: den `.harness/skills/`-Ausschluss entfernen, sodass die beiden Skill-Vorlagen als Singletons emittiert werden (StripHintBlock + Stempel) |
| `internal/emit/templates_test.go`, `test/courseset-fixture.bats` | update | Zielmenge um `.harness/skills/{reviewer,closure-note-reviewer}.md`; Emit-Tests |
| `harness/tools/smoke.sh` | update | Skill-Präsenz im emittierten Ziel prüfen (positiver Vertreter) |
| `test/mutations/` | neu | rot färbender Wächter je neuer Zusage (§3.6) |

## 4. Trigger

welle-04 aktiv (welle-03 in `done/`, [`ADR-0006`](../../../../docs/plan/adr/0006-durchsetzung-commands-tool-als-quelle.md) accepted). Erster Slice der Welle — de-riskt den Emit-Pfad.

Rückführungen: `in-progress → next`, falls der Skill-Emit doch mehr trägt als erwartet (z. B. eine
Transform-Sonderbehandlung nötig ist) und getrennt gehört. `in-progress → open`, falls sich die
Skill-Emission als blockiert erweist (unerwartet) — Carveout nach Modul 7.

## 5. Closure-Trigger

DoD vollständig + Review konform + Verifikation bestätigt + Closure-Notiz → nach `done/`. Öffnet den
`.harness/skills/`-Emit-Pfad für slice-031–033.

## 6. Risiken und offene Punkte

- **Gate-Neutralität im Ziel (günstig, aber prüfen):** die emittierten Skills landen unter
  `.harness/skills/`, und die emittierte `.d-check.yml` ignoriert `.harness/**` — sie sind im frischen
  Repo also gate-neutral (anders als slice-028s Indexe/Roadmap). Der Voll-Smoke soll das bestätigen, nicht
  annehmen.
- **Singleton vs. wiederkehrend:** `reviewer`/`closure-note-reviewer` sind **Singletons** (ein Skill pro
  Repo), nicht in `isRecurring` gelistet → korrekt als transformierte `.md` (StripHintBlock + Stempel), nicht
  co-located. Falls der Kurs sie je als wiederkehrend führt, fällt das in `courseset-fixture.bats` auf.
- **Zielmenge/Pre-Flight-Kopplung:** den `inScope`-Ausschluss zu entfernen bewegt die emittierte Zielmenge —
  Emit-Tests, `courseset-fixture.bats` **und** der cmd-Pre-Flight (`emit.TemplateTargets`) müssen dieselbe
  neue Menge sehen (Muster slice-028: sonst falsch-grün).
- **Größe:** klein (eine `inScope`-Zeile + Tests). Falls wider Erwarten eine Transform-Sonderbehandlung
  nötig wird, `in-progress → next`.

## 7. Closure-Notiz (nach `done/`)

**Abgeschlossen:** 2026-07-22. Review [KONFORM](../../../reviews/2026-07-22-slice-030-review.md)
(0 Findings, 7 Negativbefunde), Verifikation bestätigt die DoD (getrennter Kontext; `make gates` +
`make mutate` + `make full-smoke` selbst gefahren, Skills real im gebootstrappten Repo gesehen).

**Ergebnis:** Der `.harness/skills/`-Emit-Pfad ist geöffnet — der Reviewer-/Closure-Skill wird als
Singleton emittiert (bleibt **Fetch**, [`ADR-0006`](../../../../docs/plan/adr/0006-durchsetzung-commands-tool-als-quelle.md)).
Erster, de-riskender welle-04-Slice; slice-031–033 (Mechanik/Guard/Commands, Tool-als-Quelle) setzen darauf auf.

**Steering-Loop-Eintrag:**

- **Wo ein emittiertes Artefakt landet, bestimmt seine Gate-Exposition.** Anders als slice-028s Indexe/
  Roadmap (unter `docs/`, vom Ziel-`docs-check` gescannt → mussten gate-sicher gemacht werden) liegen die
  Skills unter `.harness/` — und die emittierte `.d-check.yml` ignoriert `.harness/**`. Sie sind damit
  **gate-neutral** im Ziel (per Voll-Smoke belegt, nicht angenommen). Nützlicher Kontrast für die
  Folge-Slices: Durchsetzung/Commands landen teils in `.claude/` (ebenfalls nicht im Standard-Scan) —
  Gate-Exposition je Zielpfad prüfen.
- **Der Smoke fing seinen eigenen Selbstwiderspruch.** `.harness/skills/reviewer.md` stand kurzzeitig in
  **beiden** smoke.sh-Loops (Positiv „muss existieren" + Negativ „darf nicht") — der `make smoke`-Lauf
  wurde sofort rot und zeigte es. Die Zielmengen-Kopplung (Emit-Test want / Fixture-Zahl / Pre-Flight)
  aus slice-028 trug: alle drei Achsen zusammen bewegt, kein falsch-grün.
- **Benannt (Planner-Nachzug bei welle-04-Closure):** welle-04 §1 nennt `CLAUDE.md` noch als
  Durchsetzung (die ADR-0006-Überarbeitung stufte es auf **autort** um) und §6 nennt den
  architecture.md-Nachzug „nicht Scope" (ist inzwischen erledigt) — zwei kleine Welle-Plan-Stale-Stellen
  aus der ADR-0006-Evolution.

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (`internal/emit/`, `test/`, `harness/tools/` — siehe Kurs Modul 5
§Worked Mini-Example): adoptierte Emit-Mechanik, reiner Zusatz einer bereits vorhandenen
Template-Quelle zur Zielmenge, niedriges Evidenz-/Diskrepanz-Risiko.
