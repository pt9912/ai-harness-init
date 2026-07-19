# Slice slice-004b: Sprachskelett verdrahten (Merge)

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.1.0/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-02-fetch-und-readme](../welle-02-fetch-und-readme.md).

**Bezug:** [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen), `ADR-0001`. <!-- d-check:ignore (Verweis auf die superseded Skelett-Distributions-ADR; slice-004b wird mit der Umsetzungs-Welle re-skopt) -->

**Autor:** Demo. **Datum:** 2026-07-18.

> **Status 2026-07-19 (Re-Entry).** Die **Layering-ADR-Vorbedingung ist gelöst**:
> [`ADR-0005`](../../../../docs/plan/adr/0005-ziel-repo-distribution.md) entscheidet die Datei-Ownership (Generator besitzt
> `Makefile`/`Dockerfile`/`go.mod`; die gefetchte Vorlage die `AGENTS.md`). Dieser Slice wird damit aus
> dem neuen Distributionsmodell **re-skopt** (nicht mehr „Merge eines gefetchten Skeletts", sondern
> Generator + Fetch) — der neue Schnitt entsteht in der Umsetzungs-Welle. Bis dahin bleibt er `open/`.

---

## 1. Ziel

Das von [slice-004a](../done/slice-004a-skeleton-fetch.md) gefetchte Sprachskelett mit der Harness-Emit-Schicht
(Doc-Gate, Templates) **verschmelzen**: eine Merge-Regel für die Konfliktdateien (`AGENTS.md`, `Makefile`),
`d-check.mk`-Include ins Skelett-`Makefile`, sodass `make gates` im Zielrepo **bootstrap-aware grün** läuft
(Voll-Smoke von [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen)).

## 2. Definition of Done

- [ ] **Layering-ADR** akzeptiert: welche Schicht besitzt welche Datei (Skelett- vs. Harness-Emit-Schicht), Merge-Regel für `AGENTS.md`/`Makefile`. **Vorbedingung — vor Code.**
- [ ] [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) (Verdrahten-Teil): Skelett-Code-Gates sind verdrahtet, nur lauffähige Targets ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)); das emittierte `Makefile` bindet `d-check.mk` ein.
- [ ] Voll-E2E-Smoke ([`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen)/[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)): Bootstrap in tmp-Repo → `make gates` grün **out-of-the-box** — der Beweis, den welle-01 aufschob.
- [ ] `make gates` grün.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

**Blockiert bis:** slice-004a done (Fetch) **und** Layering-ADR akzeptiert. Der Merge *ist* die
Layering-Entscheidung — welche Schicht bei `AGENTS.md`/`Makefile` gewinnt, wie das Skelett-`Makefile`
`d-check.mk` einbindet, wie „bootstrap-aware grün" mit dem emittierten Doc-Gate zusammenspielt.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `docs/plan/adr/` | neu | Layering-ADR: Datei-Ownership Skelett- vs. Harness-Emit-Schicht + Merge-Regel |
| `cmd/ai-harness-init`, `internal/` | update | Verdrahten: Skelett-Gates + `d-check.mk`-Include; Konflikt-Merge nach ADR |
| Emit-Tests | neu/update | Merge-Regel + Voll-Smoke |

## 4. Trigger

slice-004a done (Skelett wird gefetcht) **und** die Layering-ADR akzeptiert. Bis dahin **blockiert**
(`in-progress → open`, Modul 7). Rückführung zu groß → `in-progress → next`.

## 5. Closure-Trigger

DoD vollständig + Review konform + Closure-Notiz → nach `done/`. Schließt mit slice-005 die welle-02
(voller [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)-Smoke).

## 6. Risiken und offene Punkte

- **Layering ist die Kern-Unsicherheit:** wer besitzt `AGENTS.md` (Harness-Prozess vs. Sprach-Guidance)
  und den `Makefile`? Ohne klare ADR-Regel driftet der Merge — darum ist die ADR DoD-Vorbedingung.
- „bootstrap-aware grün" des Skeletts muss mit dem emittierten Doc-Gate koexistieren (zwei Gate-Quellen
  in einem `Makefile`).
- Abhängig von slice-004a (Fetch); ohne es kein Skelett zum Verdrahten.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example).
