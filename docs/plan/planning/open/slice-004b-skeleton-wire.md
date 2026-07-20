# Slice slice-004b: Sprachskelett verdrahten (Gerüst + Init-Flow)

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.1.0/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-02-fetch-und-readme](../welle-02-fetch-und-readme.md).

**Bezug:** [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen), [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`ADR-0005`](../../../../docs/plan/adr/0005-ziel-repo-distribution.md), [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert).

**Autor:** Demo. **Datum:** 2026-07-18, **re-gescopet 2026-07-20.**

---

## 1. Ziel

> **Re-Scope 2026-07-20.** Dieser Slice hieß ursprünglich „Sprachskelett verdrahten
> (**Merge**)" und wollte ein **gefetchtes** Skelett mit der Harness-Emit-Schicht
> verschmelzen — samt Merge-Regel für die Konfliktdateien `AGENTS.md`/`Makefile` und einer
> **Layering-ADR als DoD-Vorbedingung**. [`ADR-0005`](../../../../docs/plan/adr/0005-ziel-repo-distribution.md) hat beides erledigt: die ADR
> ist **Accepted** (Vorbedingung entfällt), und einen **Merge gibt es nicht mehr** — der
> Generator *besitzt* `Makefile`/`Dockerfile`/`go.mod`, es gibt also keine Konfliktdateien.
> Übrig bleibt, was der Titel immer meinte: **verdrahten**. Der Voll-E2E-Smoke wandert
> nach [slice-024](slice-024-voll-smoke.md) (welle-03), weil er den vollständigen
> Bootstrap inklusive Root-README braucht.

Das **generierte** Sprachskelett (slice-023) mit der Harness-Emit-Schicht **verdrahten**:
Verzeichnis-Gerüst anlegen, den Init-Flow verbinden und `d-check.mk` ins generierte
`Makefile` einbinden ([`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)) — sodass im Zielrepo **ein** kohärenter
`make gates`-Einstiegspunkt entsteht statt zweier Gate-Quellen.

## 2. Definition of Done

- [ ] [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) (Verdrahten-Teil): die generierten Code-Gates sind verdrahtet, **nur lauffähige** Targets ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- [ ] Das generierte `Makefile` **bindet `d-check.mk` ein** ([`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)); Doc-Gate und Code-Gates hängen an **einem** `make gates`, nicht an zwei konkurrierenden.
- [ ] [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen): das Verzeichnis-Gerüst des Zielrepos steht vollständig (Doc-Struktur aus slice-022, Skelett aus slice-023, Gerüst hier), der Init-Flow durchläuft alle Herkunftsklassen aus [`ADR-0005`](../../../../docs/plan/adr/0005-ziel-repo-distribution.md).
- [ ] Emit-Test belegt die Verdrahtung struktur-seitig (Include vorhanden, Targets aufrufbar). **Der Voll-E2E-Beweis ist ausdrücklich [slice-024](slice-024-voll-smoke.md)** — hier wird er *nicht* behauptet.
- [ ] `make gates` grün.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `cmd/ai-harness-init` | update | Init-Flow: Fetch (slice-022) → Generator (slice-023) → Gerüst → Verdrahtung |
| `internal/` | update | Verzeichnis-Gerüst + `d-check.mk`-Include ins generierte `Makefile` ([`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)) |
| Emit-Tests | update | Gerüst-Vollständigkeit, Include vorhanden, Targets aufrufbar |

## 4. Trigger

slice-023 in `done/` (das Skelett wird generiert) — und damit implizit slice-022. Die
frühere Vorbedingung „Layering-ADR akzeptiert" ist **erfüllt** ([`ADR-0005`](../../../../docs/plan/adr/0005-ziel-repo-distribution.md),
Accepted 2026-07-19) und damit kein Blocker mehr.

Rückführungen: `in-progress → next`, wenn Gerüst und Init-Flow getrennt gehören.
`in-progress → open`, wenn die Verdrahtung eine Ownership-Frage aufwirft, die
[`ADR-0005`](../../../../docs/plan/adr/0005-ziel-repo-distribution.md) offen lässt (Carveout, Modul 7).

## 5. Closure-Trigger

DoD vollständig + Review konform + Closure-Notiz → nach `done/`. Schließt als **letzter**
Slice die welle-02.

## 6. Risiken und offene Punkte

- **Zwei Gate-Quellen in einem `Makefile`** bleibt die Kern-Reibung: das generierte
  Code-Gate-Set und das tool-generierte `d-check.mk` müssen an *einem* `make gates` hängen.
  Die Datei-Ownership ist durch [`ADR-0005`](../../../../docs/plan/adr/0005-ziel-repo-distribution.md) entschieden (Generator besitzt den
  `Makefile`) — offen ist die **Include-Mechanik**, nicht mehr die Zuständigkeit.
- **`AGENTS.md` ist nicht mehr Konfliktdatei, sondern Fremd-Artefakt:** sie kommt aus der
  gefetchten Vorlage und wird von Agent/Mensch autort ([`ADR-0005`](../../../../docs/plan/adr/0005-ziel-repo-distribution.md), Klasse
  „tool-fremd"). Das Tool darf sie **nicht** generieren — sonst entsteht genau die
  halluzinierte Autorschaft, die [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) ausschließt.
- Abhängig von slice-023 (Generator); ohne Skelett nichts zu verdrahten.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example).
