# Welle welle-02-fetch-und-readme: Fetch & README

**Lifecycle:** Die aktive Welle liegt flach unter `docs/plan/planning/`; bei
Closure wandert diese Datei per `git mv` nach `done/` (neben ihre
`welle-<NN>-results.md`). Der Zustand ist die Verzeichnis-Position — kein
Status-Feld. Ob eine flache Welle *aktuell* oder *geplant* ist, sagt die Roadmap.

**Zielmeilenstein:** M2 (vollständiger Bootstrap) — **beitragend**; erreicht wird M2 in
welle-03.

**Verantwortlich:** Demo. **Datum:** 2026-07-18, **umgeplant 2026-07-20.**

---

> **Umplanung 2026-07-20 ([`ADR-0005`](../../../docs/plan/adr/0005-ziel-repo-distribution.md)-Pivot).** Diese Welle wurde **nicht geschlossen**,
> sondern **umgeplant**: ihr ursprüngliches Ziel („holt das Sprachskelett vom gepinnten
> Kurs-Tag") ist durch [`ADR-0005`](../../../docs/plan/adr/0005-ziel-repo-distribution.md) ungültig — das Skelett wird jetzt **generiert**, und
> gefetcht werden Regelwerk + Templates. Sie fokussiert damit auf den
> **Distributions-Umbau**; Root-README und der Voll-E2E-Smoke wandern nach welle-03,
> M2 mit ihnen. slice-004b ist re-gescopet (nicht aufgelöst), slice-005 umgehängt.
> Vorbild für den Umgang: die Re-Scope-Spur von
> [slice-015](done/slice-015-zitat-sensor.md). Drift-Log: Roadmap
> §Historische Trigger-Verschiebungen.

## 1. Welle-Ziel

Der **Distributions-Umbau** aus [`ADR-0005`](../../../docs/plan/adr/0005-ziel-repo-distribution.md): das Tool bezieht Regelwerk und
Doc-Templates per **Fetch** aus der Kurs-SSoT (das Embed-Duplikat entfällt), **generiert**
das Sprachskelett deterministisch aus tool-eigenem Wissen und **verdrahtet** beides zu
einem kohärenten Zielrepo. Das löst [`LH-FA-09`](../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren) ein (das Zielrepo erhält
erstmals ein Regelwerk) und [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) nach dem CR (Picker → Generator).

## 2. Trigger (Welle startet)

- welle-01 done (Offline-Kern: `cmd/ai-harness-init` parst `--lang`, emittiert die
  Doc-Gate-Baseline und legt die Template-Baseline zweiklassig ab). **Erfüllt 2026-07-18**
  ([welle-01-results](done/welle-01-results.md)).

## 3. Closure-Trigger (Welle schließt)

Beobachtbare Bedingungen (kein Kalendertag); die Closure folgt den fünf Modul-6-Schritten:

- slice-022a, slice-022b, slice-025, slice-023 und slice-004b liegen in `done/`
  (slice-004a liegt bereits dort).
- `make gates` grün.
- **Tier-2-Emit-Smoke grün** (`make smoke`, seit slice-002): die Emit-Baseline läuft im
  tmp-Repo real durch. Der **Voll**-E2E-Smoke ist bewusst welle-03s Closure-Kriterium —
  er braucht die Root-README und wäre hier ein Beweis über unvollständigem Ziel.
- Carveout-Audit ([Modul 7](https://github.com/pt9912/ai-harness-course/blob/v3.5.0/kurs/de/02-planung/modul-07-carveouts.md)): 0 offen oder dokumentiert.
- Closure-Notiz in `done/welle-02-results.md` (Steering-Loop-Lerneintrag).

## 4. Slices in dieser Welle

<!-- Zustand jedes Slice = sein Lifecycle-Verzeichnis; hier NICHT als Status-Spalte
gespiegelt (welle.template.md §4 — eine zweite Wahrheit driftet). -->

| Slice | Titel | Bezug |
|---|---|---|
| [slice-004a](done/slice-004a-skeleton-fetch.md) | Sprachskelett-Fetch *(geliefert unter dem abgelösten Modell)* | [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) |
| [slice-022a](done/slice-022a-baseline-fetch.md) | Baseline-Fetch ins Zielrepo (additiv) | [`LH-FA-09`](../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren), [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) |
| [slice-022b](in-progress/slice-022b-embed-raus.md) | Embed raus — gefetchte Baseline ist einzige Template-Quelle | [`LH-FA-02`](../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3), [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) |
| [slice-025](open/slice-025-bootstrap-preflight.md) | Bootstrap-Kette absichern (Pre-Flight statt Teil-Emit) | [`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen), [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) |
| [slice-023](open/slice-023-skelett-generator.md) | Go-Skelett-Generator (deterministisch) | [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) |
| [slice-004b](open/slice-004b-skeleton-wire.md) | Sprachskelett verdrahten (Gerüst + Init-Flow) | [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), [`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) |

## 5. Abhängigkeiten

- Wird blockiert von: welle-01 (Offline-Kern) — **done**.
- Blockiert: welle-03 (README & Voll-Smoke) — ohne den umgebauten Bootstrap hat deren
  Voll-Smoke kein vollständiges Ziel.
- Intern **strikt sequenziell**: slice-022a → slice-022b → **slice-025** → slice-023 →
  slice-004b. **022a ist additiv** (Baseline-Fetch neben dem bestehenden Embed), **022b räumt
  ab** — der Zwischenzustand zweier Template-Quellen ist bewusst kurz und bleibt von
  `test/skel-drift.bats` bewacht, bis das Embed fällt. Die Teilung entstand aus der
  Ist-Messung vor der Implementierung (Re-Slice 2026-07-20, s. 022a §1).
- **slice-025 sitzt bewusst VOR 023/004b:** es sichert die Bootstrap-Kette ab, und jeder
  Slice danach hängt sonst einen weiteren ungeschützten Schritt an. Genau so ist der Befund
  viermal entstanden (slice-002 → 003 → 004a → 022a), während seine Lösung dreimal einem
  Folge-Slice zugewiesen und nie geliefert wurde.
- **slice-004a ist ein Sonderfall:** es liegt in `done/`, lieferte aber den
  Skelett-Fetch-Pfad, den [`ADR-0005`](../../../docs/plan/adr/0005-ziel-repo-distribution.md) ablöst. `done/` wird **nicht** zurückgesetzt
  (Modul 5: der Zustand ist die Verzeichnis-Position, Historie liegt in git); der Rückbau
  passiert in slice-022a/022b. Die Closure-Notiz führt das als Lerneintrag.

## 6. Out-of-Scope für diese Welle

- **Root-README** ([`LH-FA-05`](../../../spec/lastenheft.md#lh-fa-05--root-readme-emittieren-f1-f2)) und **Voll-E2E-Smoke** — nach welle-03
  verschoben (Umplanung 2026-07-20), samt M2.
- **Air-gapped Bootstrap** (netzloser Bootstrap) — Re-Evaluierungs-Trigger von
  [`ADR-0005`](../../../docs/plan/adr/0005-ziel-repo-distribution.md), nicht Scope hier: der Bootstrap darf **einmalig** Netz brauchen.
- **Weitere Sprach-Profile** über `go` hinaus ([`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) nennt sechs) — eigene Slices.
- **Durchsetzungsschicht-Emit** ([`LH-FA-06`](../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren)/[`ADR-0004`](../../../docs/plan/adr/0004-durchsetzungs-emission.md)),
  **Arch-Gate-Emit** ([`LH-FA-07`](../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren)) und **Workflow-Command-Emit**
  ([`LH-FA-08`](../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren)) — eigene, spätere Wellen.
- Inhaltliche Urteilsschritte (Spec/ADR/Modus) — global out-of-scope.

## 7. Closure-Notiz

<!-- Erst nach Welle-Abschluss füllen. Verweis auf done/welle-02-results.md. -->
