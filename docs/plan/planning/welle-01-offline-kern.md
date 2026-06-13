# Welle welle-01: Offline-Kern

**Status:** in-progress

**Zielmeilenstein:** M1 (lauffähiger Offline-Kern)

**Verantwortlich:** Demo. **Datum:** 2026-06-13.

---

## 1. Welle-Ziel

Ein lauffähiges `bin/ai-harness-init`, das **ohne Netz** seinen Kern
leistet: Argumente parsen mit korrekten Fehlerpfaden, die
Doc-Gate-Baseline emittieren und Templates zweiklassig ablegen. Spiegelt
die Negative-/Boundary-Akzeptanzkriterien von [`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) sowie [`LH-FA-02`](../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)
und [`LH-FA-03`](../../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7).

## 2. Trigger (Welle startet)

- Harness-Bootstrap abgeschlossen ([`ADR-0001`](../../../docs/plan/adr/0001-skelett-distribution.md) accepted, `make docs-check` grün).

## 3. Closure-Trigger (Welle schließt)

- slice-001, slice-002, slice-003 done.
- `make gates` grün — inkl. der in slice-001 promoteten `lint`/`test`.
- Smoke: Bootstrap in tmp-Repo offline → erwartete Dateien vorhanden
  ([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)-Vorstufe, voller Smoke erst nach welle-02).
- Closure-Notiz in `welle-01-results.md`.

## 4. Slices in dieser Welle

| Slice | Titel | Status | Bezug |
|---|---|---|---|
| [slice-001](open/slice-001-cli-skeleton.md) | CLI-Skeleton + Gate-Promotion | open | [`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen), [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) |
| [slice-002](open/slice-002-doc-gate-emit.md) | Doc-Gate-Baseline emittieren | open | [`LH-FA-03`](../../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7), [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) |
| [slice-003](open/slice-003-template-ablage.md) | Zweiklassige Template-Ablage | open | [`LH-FA-02`](../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) |

## 5. Abhängigkeiten

- Blockiert: welle-02 (Picker/README setzen auf dem CLI-Skeleton auf).
- Wird blockiert von: keine (erste Welle).
- Intern: slice-002 und slice-003 setzen auf dem Arg-Parser/Skeleton aus
  slice-001 auf.

## 6. Out-of-Scope für diese Welle

- Netz-Zugriff jeder Art (Sprachskelett-Fetch → welle-02, [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4)).
- Root-README-Emit (→ welle-02, [`LH-FA-05`](../../../spec/lastenheft.md#lh-fa-05--root-readme-emittieren-f1-f2)).
- **Happy-Path-Voll-Smoke von [`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen)** (`make gates` grün end-to-end nach
  Bootstrap) → welle-02/slice-005. welle-01 deckt von [`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) nur die
  Negative-/Boundary-AC und das Argument-Parsen ab.
- Inhaltliche Urteilsschritte (Spec/ADR/Modus) — global out-of-scope.

## 7. Closure-Notiz

<!-- Erst nach Welle-Abschluss füllen. Verweis auf welle-01-results.md. -->
