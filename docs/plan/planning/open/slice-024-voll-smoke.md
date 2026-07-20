# Slice slice-024: Voll-E2E-Smoke des Bootstraps

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.0/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-03-readme-und-smoke](../welle-03-readme-und-smoke.md).

**Bezug:** [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen), [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`ADR-0005`](../../../../docs/plan/adr/0005-ziel-repo-distribution.md).

**Autor:** Claude (Pair-Session). **Datum:** 2026-07-20.

---

## 1. Ziel

Der **Voll-E2E-Smoke**: Bootstrap in ein tmp-Repo → dort läuft `make gates`
**out-of-the-box grün**. Das ist der Happy-Path-Beweis von
[`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen), den welle-01 aufschob und welle-02 aus Schnitt-Gründen weitergab —
über den vollen Bootstrap aus Fetch (slice-022), Generator (slice-023), Verdrahtung
(slice-004b) und Root-README (slice-005).

## 2. Definition of Done

- [ ] [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) Happy-Path belegt: `ai-harness-init --lang go --name <X>` in ein leeres tmp-Repo → `make gates` dort **Exit 0 ohne Nacharbeit**, echte Ausgabe im Closure-Beleg.
- [ ] [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6): jedes im emittierten Repo behauptete Target läuft dort wirklich — der Smoke ist genau der Sensor gegen halluzinierte Gates.
- [ ] Der Smoke ist als **Nicht-Gate-Verify** verdrahtet (eigenes Target, **nicht** in `make gates`) — er braucht Host-Docker und ggf. Netz-Pull, `make gates` bleibt offline-schlank. Dieselbe Trennung wie beim Tier-2-`make smoke` aus slice-002.
- [ ] [`AGENTS.md`](../../../../AGENTS.md) §4 und [`harness/README.md`](../../../../harness/README.md) §Sensors nennen ihn in der Nicht-Gate-Verify-Zeile — behauptet wird nur, was läuft.
- [ ] `make gates` grün.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `Makefile` | update | Voll-Smoke-Target neben dem bestehenden Tier-2-`smoke` |
| `test/` | neu | E2E-Smoke: tmp-Repo, Bootstrap, `make gates` im Ziel |
| [`AGENTS.md`](../../../../AGENTS.md), [`harness/README.md`](../../../../harness/README.md) | update | Nicht-Gate-Verify dokumentieren ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)) |

## 4. Trigger

slice-005 in `done/` (Root-README ist das letzte Emit-Stück) — und damit implizit die
ganze welle-02. Vorher ist der Smoke **nicht ehrlich fahrbar**: er würde über einem
unvollständigen Bootstrap grün melden.

Rückführungen: `in-progress → next`, wenn Smoke-Harness und Doku-Nachzug getrennt gehören.
`in-progress → open`, wenn der Smoke einen Defekt in einem der Vorgänger-Slices aufdeckt,
der dort behoben werden muss (Blocker, ggf. Carveout nach Modul 7) — der Smoke ist der
erste Punkt, an dem die Teile **zusammen** laufen.

## 5. Closure-Trigger

DoD vollständig + Review konform + Closure-Notiz → nach `done/`. Schließt zusammen mit
slice-005 die welle-03 und erreicht **M2**.

## 6. Risiken und offene Punkte

- **Der Smoke ist der erste Integrations-Punkt.** Fetch, Generator, Verdrahtung und README
  liefen bis hier nur je einzeln getestet. Realistisch deckt er Defekte in den
  Vorgänger-Slices auf — das ist sein Zweck, aber es ist auch das Termin-Risiko der Welle.
- **Grüner Smoke ≠ gutes Zielrepo:** er belegt `make gates` Exit 0, nicht die inhaltliche
  Qualität des emittierten Repos. Kein Rückfall auf stilles Grün — was er *nicht* prüft,
  gehört benannt (Architektur-Gate a-check ist bewusst nicht Teil davon, [`LH-FA-07`](../../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren)).
- Host-Docker + ggf. Netz-Pull machen ihn CI-/DoD-gebunden, nicht `gates`-tauglich.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example).
