# Welle welle-03-readme-und-smoke: README & Voll-Smoke

**Lifecycle:** Die aktive Welle liegt flach unter `docs/plan/planning/`; bei
Closure wandert diese Datei per `git mv` nach `done/` (neben ihre
`welle-<NN>-results.md`). Der Zustand ist die Verzeichnis-Position — kein
Status-Feld. Ob eine flache Welle *aktuell* oder *geplant* ist, sagt die Roadmap.

**Zielmeilenstein:** M2 (vollständiger Bootstrap) — **erreicht durch diese Welle**;
welle-02 trägt den Distributions-Umbau dorthin bei.

**Verantwortlich:** Claude (Pair-Session). **Datum:** 2026-07-20.

---

## 1. Welle-Ziel

Der Bootstrap wird **vollständig und bewiesen**: die Root-README kommt hinzu
([`LH-FA-05`](../../../spec/lastenheft.md#lh-fa-05--root-readme-emittieren-f1-f2)), und der **Voll-E2E-Smoke** zeigt, dass ein frisch gebootstrapptes
Zielrepo `make gates` **out-of-the-box grün** fährt ([`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) Happy-Path,
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). Das ist der Beweis, den welle-01 aufschob und welle-02 aus
Schnitt-Gründen weitergab — und mit ihm ist **M2** erreicht.

## 2. Trigger (Welle startet)

- welle-02 (Distributions-Umbau: Fetch · Generator · Verdrahtung) liegt in `done/`.
  **Beobachtbar**, nicht terminiert: ohne den umgebauten Bootstrap hätte der Voll-Smoke
  kein vollständiges Ziel zu prüfen.

## 3. Closure-Trigger (Welle schließt)

Beobachtbare Bedingungen (kein Kalendertag); die Closure folgt den fünf Modul-6-Schritten:

- slice-005, slice-028 und slice-024 liegen in `done/`.
- `make gates` grün.
- **Voll-E2E-Smoke grün:** Bootstrap in tmp-Repo → `make gates` dort Exit 0 **ohne
  Nacharbeit**, mit echter Ausgabe belegt ([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) — kein Erfolg ohne Gate-Lauf).
- **Mutations-Sensor grün** (`make mutate`, seit slice-026) — dasselbe Muster wie in welle-02:
  ein Nicht-Gate-Target ohne Trigger läuft nie.
- Carveout-Audit ([Modul 7](https://github.com/pt9912/ai-harness-course/blob/v3.5.0/kurs/de/02-planung/modul-07-carveouts.md)): 0 offen oder dokumentiert.
- Closure-Notiz in `done/welle-03-results.md` (Steering-Loop-Lerneintrag).

## 4. Slices in dieser Welle

| Slice | Titel | Bezug |
|---|---|---|
| [slice-005](done/slice-005-root-readme.md) | Root-README emittieren | [`LH-FA-05`](../../../spec/lastenheft.md#lh-fa-05--root-readme-emittieren-f1-f2), [`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) |
| [slice-028](done/slice-028-emit-gate-sicher.md) | Emit out-of-the-box gate-sicher (Spec 0.8.0) | [`LH-FA-02`](../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3), [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) |
| [slice-024](in-progress/slice-024-voll-smoke.md) | Voll-E2E-Smoke des Bootstraps | [`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen), [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) |

## 5. Abhängigkeiten

- Wird blockiert von: welle-02 (Distributions-Umbau) — der Voll-Smoke braucht den
  vollständigen Bootstrap-Pfad.
- Blockiert: keine geplante Folge-Welle. Durchsetzungsschicht-Emit
  ([`LH-FA-06`](../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren)), Arch-Gate-Emit ([`LH-FA-07`](../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren)) und
  Workflow-Command-Emit ([`LH-FA-08`](../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren)) sind eigene, noch ungeplante Wellen (§6).
- Intern **strikt sequenziell**: slice-005 (README) → **slice-028** (Emit gate-sicher) →
  slice-024 (Voll-Smoke). slice-024 setzt slice-028 voraus: slice-024s eigener Smoke deckte auf,
  dass der emittierte `docs-check` **nicht** out-of-the-box grün ist (3 Befunde: 2 fehlklassifizierte
  Indexe + 1 Roadmap-Zeile, plus Co-Location-Redundanz zur emittierten `AGENTS.md`). slice-028 zieht
  den Emit an [`LH-FA-02`](../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) 0.8.0 nach; vorher meldete der Smoke über einem nicht-gate-sicheren Ziel rot.

## 6. Out-of-Scope für diese Welle

- **Durchsetzungsschicht-Emit** ([`LH-FA-06`](../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren)/[`ADR-0004`](../../../docs/plan/adr/0004-durchsetzungs-emission.md)),
  **Arch-Gate-Emit** ([`LH-FA-07`](../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren)) und **Workflow-Command-Emit**
  ([`LH-FA-08`](../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren)) — eigene, spätere Wellen.
- **Air-gapped Bootstrap** (netzloser Bootstrap) — Re-Evaluierungs-Trigger von
  [`ADR-0005`](../../../docs/plan/adr/0005-ziel-repo-distribution.md), nicht Scope hier: der Bootstrap darf **einmalig** Netz brauchen.
- **Weitere Sprach-Profile** über `go` hinaus ([`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) nennt sechs) — der
  Generator bleibt sprach-agnostisch, die Profile folgen als eigene Slices.
- Inhaltliche Urteilsschritte (Spec/ADR/Modus) — global out-of-scope.

## 7. Closure-Notiz

<!-- Erst nach Welle-Abschluss füllen. Verweis auf done/welle-03-results.md. -->
