# Slice slice-002: Doc-Gate-Baseline emittieren

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem die Datei liegt
(`open/` · `next/` · `in-progress/` · `done/`), Wechsel nur per `git mv` —
v3.1.0-Konvention (`modul-05`).

**Welle:** [welle-01-offline-kern](welle-01-offline-kern.md).

**Bezug:** [`LH-FA-03`](../../../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7), [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6).

**Autor:** Demo. **Datum:** 2026-06-13.

---

## 1. Ziel

`cmd/ai-harness-init` schreibt die Doc-Gate-Baseline ins Zielrepo:
`.d-check.yml` (vom Tool autorierte Minimal-Config, nur `links`/`anchors`) und
`d-check.mk` (zur **Bootstrap-Zeit** via `docker run <d-check> --print-mk` erzeugt
und mechanisch adaptiert, Image per Digest gepinnt). `ids`/`codepaths` bleiben im
frischen Repo inaktiv — kein halluziniertes bzw. brechendes Gate.

## 2. Definition of Done

- [x] [`LH-FA-03`](../../../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7) erfüllt: `.d-check.yml` (embedded-minimal) + `d-check.mk` (Runtime-Codegen via `d-check --print-mk` + Adaption) werden emittiert.
- [x] [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6): die emittierte `.d-check.yml` aktiviert nur `links`/`anchors` (Tier-1-Unit) **und** das emittierte `make docs-check` läuft im tmp-Repo real grün (Tier-2 `make smoke`) — kein halluziniertes Gate.
- [x] Digest aus der kanonischen Pin-Quelle (`d-check.mk` / `harness/conventions.md` §Baseline): `emit.DefaultDigest` == Pin in `d-check.mk`, nicht floating (Tier-1-Unit; [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)).
- [x] Green-Run (DoD-Präzisierung): `make smoke` emittiert in ein tmp-Repo und fährt `docs-check` real auf Exit 0 — host-orchestriert, weil der go-test-Gate kein Docker hat (Tier 2 statt Unit). Voller E2E-`make gates`-Smoke bleibt slice-005 ([welle-01 §6](welle-01-offline-kern.md)).
- [x] `make gates` grün.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

Test-Architektur (Nutzer-Entscheid): **3 Tiers**, weil ein Docker-only-Build den
Green-Run nicht als Unit erlaubt (kein Docker-in-Docker im go-test-Container). Emit-
Quelle für `d-check.mk` (Nutzer-Entscheid): **Runtime-Codegen** via `d-check --print-mk`
zur Bootstrap-Zeit (Docker ist da, [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)) — eliminiert das driftende Embed-Fragment;
das Tool trägt nur Pin + Adaptions-Transform. `.d-check.yml` bleibt embedded-minimal
(ihre Minimalität ist die [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)-Garantie, die `--print-config` nicht gäbe).

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `cmd/ai-harness-init` | update | Emit verdrahten: `emit.DocGate` aus dem `--lang`-Erfolgspfad; Pin per Env (`DCHECK_IMAGE`/`DCHECK_DIGEST`) überschreibbar (Opt-in) |
| `internal/emit/` | neu | `DocGate` (Orchestrierung: Pre-Flight → `--print-mk` → Adaption → Schreiben) + `AdaptMK` (reine Transform) + embedded `.d-check.yml` |
| `internal/emit/emit_test.go`, `internal/emit/testdata/` | neu | Tier 1 (ohne Docker): Config-Minimalität, `DefaultDigest`==kanonisch, `AdaptMK` am `--print-mk`-Fixture |
| `harness/tools/smoke.sh` + `Makefile` `smoke` | neu | Tier 2 (Host-Docker, NICHT in `gates`): Binary extrahieren → emittieren → emittiertes `docs-check` real Exit 0 |
| `Dockerfile` | update | `artifact`-Stage (scratch) für die Host-Extraktion des Binaries (die Binary ruft selbst Docker) |

## 4. Trigger

slice-001 done (Arg-Parser/Skeleton vorhanden).

## 5. Closure-Trigger

DoD vollständig + Review konform + Closure-Notiz → nach `done/`.

## 6. Risiken und offene Punkte

- Gate-Config wächst mit den Artefakten: `ids`/`codepaths` dürfen im
  emittierten Zielrepo nur aktiv sein, wo Targets existieren — sonst
  bricht `docs-check` im frischen Repo (Anti-Ziel von [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- docker muss im Zielrepo-Kontext verfügbar sein — laut `architecture.md` §3
  nicht-substituierbare Abhängigkeit für den Gate-Lauf ([`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)). Beim
  **Runtime-Codegen** gilt das schon zur Bootstrap-Zeit (`--print-mk` läuft in Docker) —
  konsistent, da docker die geforderte Bootstrap-Abhängigkeit ist.
- Fixture-Grenze: das Tier-1-`AdaptMK`-Fixture (`testdata/raw-print-mk.txt`) ist ein
  Snapshot der v0.46.0-`--print-mk`-Ausgabe. Ändert d-check das Format, altert das
  Fixture still — die reale Ausgabe fängt **Tier 2** (`make smoke`), das echtes
  `d-check --print-mk` fährt; `AdaptMK` bricht bei nicht greifenden Handgriffen bewusst ab.

## 7. Closure-Notiz (nach `done/`)

**Geliefert:** `internal/emit.DocGate` emittiert die Doc-Gate-Baseline. `.d-check.yml`
embedded-minimal (`links`/`anchors`); `d-check.mk` per **Runtime-Codegen** (`docker run
<d-check> --print-mk` zur Bootstrap-Zeit + `AdaptMK`-Transform), Pin per Env
(`DCHECK_IMAGE`/`DCHECK_DIGEST`) Opt-in-überschreibbar. Commits: Eintritts-Move · Inhalt
`5fd3e19` · Review-Fix `3ffdf3f` · Exit-Move.

**Was funktionierte:** Runtime-Codegen eliminiert die Embed-Drift-Klasse — das Tool trägt
kein Fragment, nur Pin + Transform; das emittierte `d-check.mk` ist stets das aktuelle
d-check-Target-Set mit exakt dem erzeugenden Digest. Der Host-`make smoke` beweist den
Green-Run ehrlich (emittiertes `docs-check` real: `0 Befund(e), Exit 0`).

**Was anders lief:** DoD-4 („Go-Test: `docs-check` im tmp-Repo Exit 0") war im Docker-only-Build
nicht als Unit lauffähig (kein Docker-in-Docker im go-test-Container) — reconciled zur
3-Tier-Test-Architektur: der Green-Run ist Tier 2 (`make smoke`, Nicht-Gate), kein Skip, real belegt.

**Steering-Loop-Einträge:**

1. **Neues Test-/Sensor-Muster (wiederverwendbar):** Ein Slice, der ein Gate *emittiert*,
   dessen Green-Run selbst Docker braucht, kann diesen Green-Run **nicht** als go-test-Unit
   verifizieren (kein DinD im Build-Container). Muster: **3 Tiers** — Tier 1 (Unit: reine
   Transform/Config, ohne Docker), Tier 2 (`make smoke`, Host-Docker, Nicht-Gate: echter
   Emit→Gate-Lauf), Tier 3 (Voll-E2E, slice-005). Gilt direkt für slice-003 (Template-Ablage)
   und [`LH-FA-07`](../../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren) (arch-Gate a-check).
2. **Geschärfte Design-Regel (Runtime-Codegen):** Tool-generierte Fragmente (`d-check.mk`,
   künftig `a-check.mk`) **nicht** als eingebettete Kopie tragen (driftet), sondern zur
   Bootstrap-Zeit vom autoritativen Tool erzeugen (`<tool> --print-mk`) + mechanisch adaptieren
   — die Docker-Abhängigkeit ist zur Bootstrap-Zeit ohnehin gefordert ([`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)).
   **Forward:** [`LH-FA-07`](../../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren) (`a-check.mk`) sollte analog `a-check --print-mk` runtime-generieren, nicht einbetten.

**Folge-Slices:** keine neuen; slice-003 erbt das Tier-2-Muster.

**Verifikation (Beleg):** Verifier (Modul 11, frischer Kontext): 5/5 DoD CONFIRMED, 0 VIOLATED,
[`ADR-0003`](../../adr/0003-go-native-binaries.md) konform — belegt über `make smoke` (`0 Befund(e), Exit 0`), `emit.DefaultDigest` ==
kanonischer Pin, `make gates` grün. Reviewer (Modul 10): nicht merge-blockierend (0 HIGH);
M1/L1/L2/L3 in `3ffdf3f` aufgelöst, INFO I1–I4 als dokumentierte Kanten akzeptiert.

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example).
