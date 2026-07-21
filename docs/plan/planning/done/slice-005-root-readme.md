# Slice slice-005: Root-README emittieren

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem die Datei liegt
(`open/` · `next/` · `in-progress/` · `done/`), Wechsel nur per `git mv` —
v3.1.0-Konvention (`modul-05`).

**Welle:** [welle-03-readme-und-smoke](../welle-03-readme-und-smoke.md) *(umgehängt
2026-07-20 von welle-02 — [`ADR-0005`](../../../../docs/plan/adr/0005-ziel-repo-distribution.md)-Pivot; Inhalt unberührt)*. Einordnung
*(Kontext, nicht normativ)*: [roadmap](../in-progress/roadmap.md).

**Bezug:** [`LH-FA-05`](../../../../spec/lastenheft.md#lh-fa-05--root-readme-emittieren-f1-f2), [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen).

**Autor:** Demo. **Datum:** 2026-06-13.

---

## 1. Ziel

`cmd/ai-harness-init` emittiert die Root-`README.md` aus der
project-readme-Vorlage; der Pointer-/Trust-Abschnitt steht als
**gate-sichere Vorwärts-Verweise**, bis die Ziele existieren.

## 2. Definition of Done

- [x] [`LH-FA-05`](../../../../spec/lastenheft.md#lh-fa-05--root-readme-emittieren-f1-f2) erfüllt: Root-README aus Vorlage, Projektname gestempelt.
- [x] Vorwärts-Verweise gate-sicher: kein Markdown-Link auf noch fehlende Ziele (Inline-Code/Plain-Text), `make docs-check` im Zielrepo grün.
- [x] Der emittierte Stand ist smoke-fähig — der **Voll-E2E-Beweis** selbst ist [slice-024](../open/slice-024-voll-smoke.md) ([`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen)/[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)) und wird hier **nicht** behauptet.
- [x] Go-Test: README vorhanden, gestempelt, `docs-check` grün.
- [x] `make gates` grün.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `cmd/ai-harness-init` | update | README-Emit-Schritt + Stempelung |
| `cmd/ai-harness-init/readme_test.go` | neu | Existenz, Stempelung, gate-sichere Verweise |

## 4. Trigger

welle-02 in `done/` (der umgebaute Emit-Pfad steht) — damit startet welle-03. slice-005
ist deren **erster** Slice; [slice-024](../open/slice-024-voll-smoke.md) setzt auf ihm auf.

## 5. Closure-Trigger

DoD vollständig + Review konform + Closure-Notiz → nach `done/`.
Schließt zusammen mit [slice-024](../open/slice-024-voll-smoke.md) die welle-03 und erreicht **M2**.

## 6. Risiken und offene Punkte

- Gate-Sicherheit der Vorwärts-Verweise ist der kritische Punkt: ein
  versehentlicher Link auf ein noch fehlendes Ziel bricht `docs-check`
  im frischen Repo (Anti-Ziel [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).

## 7. Closure-Notiz (nach `done/`)

**Abschluss 2026-07-21** (beobachtbarer Trigger). Review konform (0 HIGH/MEDIUM,
2 INFO), Verifikation **DoD bestätigt** (5/6 erfüllt; Punkt 6 = diese Notiz),
Sensoren selbst gefahren + grün: `make gates` (100/0), `make mutate` (25/25),
`make smoke` (README am Ziel-Root, docs-check 5→3).

**Geliefert:** `emit.RootReadme` emittiert die Root-`README.md` aus der
project-readme-Vorlage (`StripHintBlock` + Projektname-Stempel, wie ein Singleton),
gate-sicher — die Vorlage verweist nach Strip nur auf co-emittierte Ziele, der
externe Kurs-URL steht im entfernten Hinweisblock ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). `README.md` liegt
im Phase-3-Pre-Flight (slice-025 — Kollision → kein Teil-Bootstrap).

**Steering-Loop-Eintrag:**
- **Neuer Sensor:** die §3.6-Disziplin auf den README-Emit ausgedehnt — Mutationen
  24/25 in `test/mutations/` färben `TestRootReadme_StampStrip` bzw.
  `TestRun_ReadmeKollisionSchreibtKeinEmit` rot (Strip · Pre-Flight).
- **Belegte Emit-Eigenschaft:** ein emittiertes Ziel löst *eingehende* Verweise
  darauf auf — die README senkte die Ziel-docs-check-Befunde real von 5 auf 3 (zwei
  vorher tote README-Links) und fügte **0** hinzu. Gate-Sicherheit gemessen, nicht
  behauptet; der Voll-0-out-of-the-box-Run bleibt slice-024.
- **Benannte Grenze (Reviewer-F-2):** die Tier-1-Fixture `projectReadmeSet` hat —
  anders als `courseSet`/`test/courseset-fixture.bats` — keinen Offline-Drift-Wächter
  gegen die reale Vorlage; reale Link-Drift fängt nur `make smoke` (Tier-2/CI).
  Ehrliche Tier-Teilung, kein stilles Grün — Kandidat für einen Fixture-Drift-Wächter
  (Roadmap-Backlog Cluster C).

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example).
