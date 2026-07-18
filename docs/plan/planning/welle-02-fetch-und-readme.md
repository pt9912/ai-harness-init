# Welle welle-02-fetch-und-readme: Fetch & README

**Status:** in-progress

**Zielmeilenstein:** M2 (vollständiger Bootstrap)

**Verantwortlich:** Demo. **Datum:** 2026-07-18.

---

## 1. Welle-Ziel

Ein **vollständiger** Bootstrap: `ai-harness-init --lang <X> --name <Y>` holt das
Sprachskelett vom gepinnten Kurs-Tag, verdrahtet dessen Code-Gates und emittiert die
Root-README — sodass `make gates` im frischen Zielrepo **end-to-end grün** läuft. Das löst
den Happy-Path von [`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) ein
(den Voll-Smoke, den welle-01 aufschob) plus [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4)
und [`LH-FA-05`](../../../spec/lastenheft.md#lh-fa-05--root-readme-emittieren-f1-f2).

## 2. Trigger (Welle startet)

- welle-01 done (Offline-Kern: `cmd/ai-harness-init` parst `--lang`, emittiert die
  Doc-Gate-Baseline und legt die Template-Baseline zweiklassig ab). **Erfüllt 2026-07-18**
  ([welle-01-results](done/welle-01-results.md)).

## 3. Closure-Trigger (Welle schließt)

Beobachtbare Bedingungen (kein Kalendertag); die Closure folgt den fünf Modul-6-Schritten:

- slice-004 und slice-005 liegen in `done/`.
- `make gates` grün.
- **Voll-E2E-Smoke:** Bootstrap in tmp-Repo → `make gates` grün **out-of-the-box** — der
  Happy-Path von [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
  den welle-01 aufschob.
- Carveout-Audit ([Modul 7](https://github.com/pt9912/ai-harness-course/blob/v3.1.0/kurs/de/02-planung/modul-07-carveouts.md)): 0 offen oder dokumentiert.
- Closure-Notiz in `done/welle-02-results.md` (Steering-Loop-Lerneintrag).

## 4. Slices in dieser Welle

| Slice | Titel | Status | Bezug |
|---|---|---|---|
| [slice-004](open/slice-004-skeleton-picker.md) | Sprachskelett-Picker | open | [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), [`ADR-0001`](../../../docs/plan/adr/0001-skelett-distribution.md) |
| [slice-005](open/slice-005-root-readme.md) | Root-README emittieren | open | [`LH-FA-05`](../../../spec/lastenheft.md#lh-fa-05--root-readme-emittieren-f1-f2), [`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) |

## 5. Abhängigkeiten

- Wird blockiert von: welle-01 (Offline-Kern) — **done**.
- Blockiert: keine geplante Folge-Welle (Durchsetzungsschicht- und Arch-Gate-Emit sind
  eigene, noch ungeplante Slices/Wellen — siehe §6).
- Intern: slice-005 (Root-README) setzt auf dem gemeinsamen Emit-/Fetch-Pfad aus slice-004
  auf; der Voll-Smoke wird erst grün, wenn 004/005 mit slice-002/003 zusammen emittieren.

## 6. Out-of-Scope für diese Welle

- **Air-gapped Bootstrap** (netz-loser Fetch) — Re-Evaluierungs-Trigger von
  [`ADR-0001`](../../../docs/plan/adr/0001-skelett-distribution.md), nicht Scope hier
  (welle-02 nutzt Netz beim Fetch, [`ADR-0001`](../../../docs/plan/adr/0001-skelett-distribution.md) Variante C).
- **Durchsetzungsschicht-Emit** ([`LH-FA-06`](../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren)/[`ADR-0004`](../../../docs/plan/adr/0004-durchsetzungs-emission.md))
  und **Arch-Gate-Emit** ([`LH-FA-07`](../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren)) — eigene, spätere Slices/Wellen.
- Inhaltliche Urteilsschritte (Spec/ADR/Modus) — global out-of-scope.

## 7. Closure-Notiz

<!-- Erst nach Welle-Abschluss füllen. Verweis auf done/welle-02-results.md. -->
