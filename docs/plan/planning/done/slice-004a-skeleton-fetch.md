# Slice slice-004a: Sprachskelett-Fetch

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.1.0/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-02-fetch-und-readme](../welle-02-fetch-und-readme.md).

**Bezug:** [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), `ADR-0001`. <!-- d-check:ignore (Verweis auf die superseded Skelett-Distributions-ADR; done/-Slice eingefroren) -->

**Autor:** Demo. **Datum:** 2026-07-18.

---

## 1. Ziel

`cmd/ai-harness-init --lang <X>` holt `lab/example/<X>/` vom **gepinnten Kurs-Tag**
(`ADR-0001`, Variante C) als Tag-Tarball und extrahiert den Teilbaum in den <!-- d-check:ignore (Verweis auf die superseded Skelett-Distributions-ADR; done/-Slice eingefroren) -->
**Staging-Bereich** `.harness/skeleton/` (der Merge in den Root ist [slice-004b](../in-progress/slice-004b-skeleton-wire.md)).
Unbekannte Sprache → Exit 2 + Liste verfügbarer Skelette.

## 2. Definition of Done

- [x] [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) (Fetch-Teil): Skelett für `--lang` wird vom gepinnten Tag geholt und extrahiert.
- [x] [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit): Tag/Pin aus `harness/conventions.md` §Baseline (`BASELINE_TAG`); zwei Läufe, gleicher Tag → identische Ausgabe.
- [x] Unbekannte Sprache → Exit 2 + Liste verfügbarer Skelette (kein stiller Fehlschlag).
- [x] Go-Test (Fetch **gemockt**/Fixture, kein echtes Netz): Extrakt korrekt, Unknown-Lang-Pfad, Reproduzierbarkeit. Der echte Netz-Fetch ist ein Tier-2-Smoke (Nicht-Gate; [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6): `make gates` bleibt offline-grün).
- [x] `make gates` grün.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

Scope: **nur Fetch + Picker**; das Verdrahten (Merge Skelett-Gates ↔ Doc-Gate, `AGENTS.md`/`Makefile`-
Konflikt) ist [slice-004b](../in-progress/slice-004b-skeleton-wire.md) (+ Layering-ADR). Transport (gemessen): Tag-Tarball
(codeload; kein separates Release-Asset) + reines Go-`archive/tar`+`compress/gzip`-Extrakt — keine neue
Dependency ([`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)).

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/fetch` | neu | Skelett-Fetch (injizierbarer Fetcher) + Tarball-Extrakt des `lab/example/<lang>/`-Teilbaums |
| `cmd/ai-harness-init` | update | `--lang`-Pfad: Skelett holen; unbekannte Sprache → Exit 2 + Liste |
| `internal/fetch`-Tests | neu | Tier 1 (Fetch gemockt): Extrakt, Unknown-Lang, Reproduzierbarkeit |

## 4. Trigger

welle-02 in-progress; `cmd/ai-harness-init` parst `--lang` und emittiert offline (slice-001a/002/003 done).
Rückführungen: zu groß → `in-progress → next`; blockiert (Kurs-Tag unerreichbar / air-gapped, `ADR-0001` <!-- d-check:ignore (Verweis auf die superseded Skelett-Distributions-ADR; done/-Slice eingefroren) -->
Re-Eval) → `in-progress → open` (Carveout, Modul 7).

## 5. Closure-Trigger

DoD vollständig + Review konform + Closure-Notiz → nach `done/`.

## 6. Risiken und offene Punkte

- **Netz beim Bootstrap nötig** (`ADR-0001` Konsequenz). Air-gapped ist Re-Evaluierungs-Trigger von <!-- d-check:ignore (Verweis auf die superseded Skelett-Distributions-ADR; done/-Slice eingefroren) -->
  `ADR-0001`, nicht Scope hier. <!-- d-check:ignore (Verweis auf die superseded Skelett-Distributions-ADR; done/-Slice eingefroren) -->
- Test ohne echtes Netz: Fetch **injizieren/mocken** oder Fixture-Tarball — sonst flakey / [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)-Verstoß.
- Reproduzierbarkeit: der Tag ist der Pin (`ADR-0001`); ein sha-Pin des Tarballs (wie <!-- d-check:ignore (Verweis auf die superseded Skelett-Distributions-ADR; done/-Slice eingefroren) -->
  `BASELINE_ZIP_SHA256`) wäre eine Härtung, ist aber von `ADR-0001` nicht verlangt (offener Punkt für slice-004b/ADR). <!-- d-check:ignore (Verweis auf die superseded Skelett-Distributions-ADR; done/-Slice eingefroren) -->
- **Surfaced (nicht von diesem Slice verursacht):** `--lang` emittiert seit slice-003 Templates
  mit Vorwärts-Verweisen/Platzhaltern → das emittierte `docs-check` ist rot (5 `target-missing`,
  u. a. auf die noch fehlende Root-README). `make smoke` prüft daher jetzt „Bootstrap läuft +
  Skelett gestaged + Doc-Gate-Config valide"; der 0-Befunde-Voll-Green-Run ist [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen)
  Happy-Path = slice-005. Der emittierte `.d-check.yml` nimmt zusätzlich `.harness/**`
  (Skelett-Staging) aus.

## 7. Closure-Notiz (nach `done/`)

**Geliefert:** `internal/fetch.Skeleton` holt `lab/example/<lang>/` vom gepinnten Kurs-Tag
(Tag-Tarball + gzip/tar-Extrakt, Präfix gestrippt, Traversal via `filepath.IsLocal` abgewiesen)
in den Staging-Bereich `.harness/skeleton/`; unbekannte Sprache → Exit 2 + gefilterte Liste.
Reines Go, keine neue Dep. Commits: Entry-Move `8660124` · Inhalt `a364d91` · Review-Fix `7fa9619` · Exit-Move.

**Was funktionierte:** Injizierbarer Fetcher → Tier 1 ohne Netz (Extrakt, Unknown-Lang, Determinismus,
Traversal, Fetch-Fehler); Tier 2 `make smoke` fährt den echten Fetch (21 Dateien gestaged).

**Was anders lief:** Der echte Bootstrap legte offen, dass `make smoke` seit slice-003 still rot war
(Templates mit Vorwärts-Verweisen ins `--lang` verdrahtet) — der emittierte-docs-check-Voll-Grün ist
[`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) Happy-Path = slice-005. Smoke ehrlich gemacht (Bootstrap läuft + Skelett gestaged + Config valide).

**Steering-Loop-Einträge:**

1. **Drift-Guard-Regel (wiederverwendbar):** jeder im Tool eingebettete Pin, der einen repo-kanonischen
   Wert spiegelt, braucht einen Tier-1-Drift-Test — `DefaultDigest`==`d-check.mk` (slice-002), jetzt
   `DefaultTag`==`BASELINE_TAG` (Review-M1). Ein Emit-Binary kann die Makefile-Quelle zur Laufzeit nicht
   lesen, also koppelt der Test statt der Mechanik.
2. **Teil-Emit-Signal (3. Wiederholung):** slice-002 I1 → slice-003 I1 → 004a L3 — mehrere Emit-Schritte
   ohne gemeinsamen Pre-Flight hinterlassen bei einem Schritt-Fehler Teil-Zustände. 004a mildert es
   (Fetch-first: der realistische Netz-Fehler lässt keinen Doc-Gate-Teil-Emit stehen), aber das Muster
   recurrt: ein **gemeinsamer Pre-Flight über alle Bootstrap-Schritte** (oder ein Staging→Commit-Modell)
   ist die eigentliche Lösung — Kandidat für slice-004b/005 (der volle Bootstrap-Pfad).

**Folge-Slices:** keine neuen; slice-004b (Merge + Layering-ADR) erbt den Gemeinsam-Pre-Flight-Punkt.

**Verifikation (Beleg):** Verifier (Modul 11, frischer Kontext): 5/5 DoD CONFIRMED, 0 harte VIOLATED —
echter Fetch (21 Dateien, zwei Läufe byte-identisch), `--lang rust` → Exit 2 + Liste, `DefaultTag` ==
`BASELINE_TAG` == conventions §Baseline, `make gates`/`test`/`smoke` grün. Reviewer (Modul 10):
merge-blockierend behoben (M1/M2 + R1/L1/L3 in `7fa9619`); L2 + INFO als dokumentierte Grenzen akzeptiert.

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example).
