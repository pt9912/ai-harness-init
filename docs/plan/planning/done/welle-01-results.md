# welle-01 — Closure-Notiz (Ergebnisse)

**Welle:** [welle-01-offline-kern](../welle-01-offline-kern.md). **Meilenstein:** M1 (lauffähiger Offline-Kern).
**Abschluss:** 2026-07-18 (beobachtbarer Trigger, kein Kalendertag).

Lerneintrag zur Wellen-Closure (Modul 6, Schritt 3): *was gelernt wurde*, nicht nur *dass sie weg ist*.

---

## 1. Geliefert

Ein lauffähiges `cmd/ai-harness-init`, das **ohne Netz** seinen Kern leistet — Argumente
parsen mit korrekten Fehlerpfaden, die Doc-Gate-Baseline emittieren und die Template-Baseline
zweiklassig ablegen:

- **slice-001a** — CLI-Skeleton (Arg-Parser, injizierbare Streams/Ziel) + go-test-Gate (Dockerfile-Stage).
- **slice-001b** — Go-Gates `build`/`lint` (Dockerfile-Stages, digest-gepinnt) + Promotion nach grünem Target.
- **slice-002** — Doc-Gate-Emit ([`LH-FA-03`](../../../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7)): `.d-check.yml` (embedded-minimal) + `d-check.mk` per **Runtime-Codegen** (`docker run <d-check> --print-mk` + Adaption).
- **slice-003** — Zweiklassige Template-Ablage ([`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)): Singletons → gestempelte `.md`, Wiederkehrende → verbatim `.template.md`, Set-Index nie.

Netto: `ai-harness-init --lang go --name X` emittiert offline 17 Dateien (Doc-Gate + 15 Templates);
der Dogfood-Gate-Stack (`docs-check`/`lint`/`build`/`test`/`shell-lint`/`baseline-verify`) ist grün.

## 2. Was funktionierte

- **Rollen-treuer Lifecycle je Slice** (Modul 8/10/11): Reviewer **und** Verifier in *frischem
  Kontext* (Subagenten) — nicht der Kontext, der den Code schrieb. Fing, was Tests übersehen
  (DoD-Behauptung vs. Bestätigung) und der Reviewer nicht sieht.
- **Messen vor Implementieren** (Modul 9): fand echte Plan-Drift, bevor Code entstand — DoD-4
  (nicht als Unit lauffähig) und die `.dockerignore`-Grenze des Drift-Wächters.
- **Schwester-Tool a-check als Vorbild** für das Go-Setup (Toolchain-Pins, Dockerfile-Stages, `.golangci.yml`).

## 3. Was anders lief

- **slice-001 war zu groß** → re-sliced in 001a/001b (Modul-5-Rücksprungkante `in-progress → next`,
  bewusst genutzt statt durchgedrückt).
- **DoD-4 (slice-002)** war als „Go-Test: docs-check Exit 0" formuliert, im Docker-only-Build aber
  nicht als Unit lauffähig (kein Docker-in-Docker) → 3-Tier-Test-Architektur.
- **Emit-Quelle** für `d-check.mk`: Runtime-Codegen statt eingebettetes Fragment (Nutzer-Entscheid) —
  eliminiert die Embed-Drift-Klasse ganz.

## 4. Steering-Loop-Einträge (wellen-übergreifend)

1. **3-Tier-Test-Architektur** für Gate-*emittierende* Slices: der Green-Run eines emittierten Gates
   braucht selbst Docker → **nicht** als go-test-Unit prüfbar (kein DinD im Build-Container). Muster:
   Tier 1 (Unit, ohne Docker) · Tier 2 (`make smoke`, Host-Docker, Nicht-Gate) · Tier 3 (Voll-E2E).
2. **Runtime-Codegen statt Embed** für tool-generierte Fragmente. **Forward:** [`LH-FA-07`](../../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren) (`a-check.mk`)
   sollte analog `a-check --print-mk` runtime-generieren, nicht einbetten.
3. **Test-Platzierung:** ein Test, der ein **dockerignoriertes** Artefakt (`.harness/…`) braucht,
   gehört in den **bats-Mount** (sieht den ganzen Repo), nicht in die go-test-Stage.
4. **Subset-Embed-Drift-Wächter** braucht ZWEI Achsen — *Gleichheit* (Embed == Quelle) UND
   *Vollständigkeit* (jede in-scope-Quelle hat ein Embed-Twin).
5. **Benannte Spec-Grenze:** welle-01 lieferte den **Emit**, nicht den End-to-End-Grün-Beweis. Dass
   das *emittierte* Repo sein eigenes `make gates` grün fährt (Voll-Smoke, [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) Happy-Path
   [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen)), ist bewusst auf welle-02/slice-005 verschoben.

## 5. Folge-Slices

Keine offenen aus welle-01. welle-02 (Fetch & README): slice-004 Sprachskelett-Picker
([`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4)), slice-005 Root-README ([`LH-FA-05`](../../../../spec/lastenheft.md#lh-fa-05--root-readme-emittieren-f1-f2)) + der oben benannte Voll-Smoke.

## 6. Verifikation (Belege, Modul 6 Schritt 1)

- **Trigger:** alle Slices (001a/001b/002/003) in `done/`; `make gates` grün (d-check 56/0, `lint`
  0 issues, `build`/`test` grün, `shell-lint` sauber, `baseline-verify` 42 Dateien).
- **Leicht-Smoke:** Bootstrap in tmp-Repo (`--lang go --name WelleSmoke`) offline → Exit 0, alle
  erwarteten Dateien vorhanden (Doc-Gate + Singletons + Wiederkehrende + roadmap unter `in-progress/`),
  keine Set-Index-README, 17 Dateien. Voller E2E-`make gates`-Smoke bleibt slice-005.
- **Carveout-Audit:** kein `carveouts/`-Verzeichnis, 0 offene Carveouts → belegte „0 offen",
  kein stilles rotes Gate.
- **Pro Slice:** frischer-Kontext-Reviewer (je nicht merge-blockierend) + Verifier (je alle DoD
  CONFIRMED, 0 VIOLATED); Berichte unter [`docs/reviews/`](../../../reviews/).
