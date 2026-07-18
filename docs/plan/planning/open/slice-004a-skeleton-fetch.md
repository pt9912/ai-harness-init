# Slice slice-004a: Sprachskelett-Fetch

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.1.0/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-02-fetch-und-readme](../welle-02-fetch-und-readme.md).

**Bezug:** [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`ADR-0001`](../../../../docs/plan/adr/0001-skelett-distribution.md).

**Autor:** Demo. **Datum:** 2026-07-18.

---

## 1. Ziel

`cmd/ai-harness-init --lang <X>` holt `lab/example/<X>/` vom **gepinnten Kurs-Tag**
([`ADR-0001`](../../../../docs/plan/adr/0001-skelett-distribution.md), Variante C) als Tag-Tarball und extrahiert den Teilbaum ins Zielrepo.
Unbekannte Sprache → Exit 2 + Liste verfügbarer Skelette. **Nicht** das Verdrahten/Merge
(→ [slice-004b](slice-004b-skeleton-wire.md)).

## 2. Definition of Done

- [ ] [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) (Fetch-Teil): Skelett für `--lang` wird vom gepinnten Tag geholt und extrahiert.
- [ ] [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit): Tag/Pin aus `harness/conventions.md` §Baseline (`BASELINE_TAG`); zwei Läufe, gleicher Tag → identische Ausgabe.
- [ ] Unbekannte Sprache → Exit 2 + Liste verfügbarer Skelette (kein stiller Fehlschlag).
- [ ] Go-Test (Fetch **gemockt**/Fixture, kein echtes Netz): Extrakt korrekt, Unknown-Lang-Pfad, Reproduzierbarkeit. Der echte Netz-Fetch ist ein Tier-2-Smoke (Nicht-Gate; [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6): `make gates` bleibt offline-grün).
- [ ] `make gates` grün.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

Scope: **nur Fetch + Picker**; das Verdrahten (Merge Skelett-Gates ↔ Doc-Gate, `AGENTS.md`/`Makefile`-
Konflikt) ist [slice-004b](slice-004b-skeleton-wire.md) (+ Layering-ADR). Transport (gemessen): Tag-Tarball
(codeload; kein separates Release-Asset) + reines Go-`archive/tar`+`compress/gzip`-Extrakt — keine neue
Dependency ([`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)).

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/fetch` | neu | Skelett-Fetch (injizierbarer Fetcher) + Tarball-Extrakt des `lab/example/<lang>/`-Teilbaums |
| `cmd/ai-harness-init` | update | `--lang`-Pfad: Skelett holen; unbekannte Sprache → Exit 2 + Liste |
| `internal/fetch`-Tests | neu | Tier 1 (Fetch gemockt): Extrakt, Unknown-Lang, Reproduzierbarkeit |

## 4. Trigger

welle-02 in-progress; `cmd/ai-harness-init` parst `--lang` und emittiert offline (slice-001a/002/003 done).
Rückführungen: zu groß → `in-progress → next`; blockiert (Kurs-Tag unerreichbar / air-gapped, [`ADR-0001`](../../../../docs/plan/adr/0001-skelett-distribution.md)
Re-Eval) → `in-progress → open` (Carveout, Modul 7).

## 5. Closure-Trigger

DoD vollständig + Review konform + Closure-Notiz → nach `done/`.

## 6. Risiken und offene Punkte

- **Netz beim Bootstrap nötig** ([`ADR-0001`](../../../../docs/plan/adr/0001-skelett-distribution.md) Konsequenz). Air-gapped ist Re-Evaluierungs-Trigger von
  [`ADR-0001`](../../../../docs/plan/adr/0001-skelett-distribution.md), nicht Scope hier.
- Test ohne echtes Netz: Fetch **injizieren/mocken** oder Fixture-Tarball — sonst flakey / [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)-Verstoß.
- Reproduzierbarkeit: der Tag ist der Pin ([`ADR-0001`](../../../../docs/plan/adr/0001-skelett-distribution.md)); ein sha-Pin des Tarballs (wie
  `BASELINE_ZIP_SHA256`) wäre eine Härtung, ist aber von [`ADR-0001`](../../../../docs/plan/adr/0001-skelett-distribution.md) nicht verlangt (offener Punkt für slice-004b/ADR).

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example).
