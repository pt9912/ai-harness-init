# Slice slice-034: Gate-Fragment-Assembly

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.0/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** welle-05.

**Bezug:** [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen), [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`ADR-0007`](../../adr/0007-bootstrap-phasen.md).

**Autor:** Claude (Pair-Session). **Datum:** 2026-07-23.

---

## 1. Ziel

Die **emittierte** Makefile-Verdrahtung wird **verhaltens-erhaltend** von „Skelett besitzt Root-Makefile
+ `wire` hängt inline an" auf **Aggregator + Fragmente** umgestellt — **ohne CLI-Änderung** (`--lang`
bleibt Pflicht; die Phasierung/Init-sprachlos ist slice-035). Konkret (Ist-Messung, Option A gewählt):

- Der Skelett-Generator (`gen`) emittiert die Root-`Makefile` als **dünnen Aggregator** (`include
  harness/mk/*.mk`, `GATE_CHECKS`-Akkumulation, `gates: record-gates` + Ordnungskante
  `record-gates: $(GATE_CHECKS)` **nach** dem Include) sowie das Code-Gate-Fragment
  `harness/mk/<lang>.mk` (Go: lint/build/test).
- Die drei sprach-agnostischen Emitter droppen je ihr `harness/mk/<belang>.mk`-Fragment: `emit.DocGate`
  (`GATE_CHECKS += docs-check`, `include d-check.mk`); `emit.BaselineVerify` (`GATE_CHECKS +=
  baseline-verify` + Rezept — **neu verdrahtet**, das Skript ist heute orphaned); `emit.Enforce`
  (`record-gates`-Rezept).
- `wire.Place` lässt den Inline-Anhang (`dCheckInclude`/`enforceWiring`) fallen und wird **reiner
  Placer**.

`make gates` fährt danach lint/build/test/docs-check **verhaltens-identisch** und **zusätzlich
`baseline-verify`** (bis hier orphaned emittiert, jetzt verdrahtet), `record-gates` strikt zuletzt — der
Gate-Ablauf wächst also **additiv** um baseline-verify. Die **Verdrahtung** selbst ist dagegen ein
**Migrations-Bruch, nicht additiv** (wire-Inline-Anhang → Aggregator + Fragmente). slice-035 relocatet
den Aggregator vom Generator in einen Init-Emitter (Phasierung).

## 2. Definition of Done

- [ ] Die emittierte Root-Makefile ist ein Aggregator mit `include harness/mk/*.mk`; **kein** direktes
  `gates:`-Prereq-Anhängen mehr — der Migrations-Bruch der heutigen `wire`-Verdrahtung ist vollzogen
  ([`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen)).
- [ ] Der Bootstrap emittiert `harness/mk/{go,doc-gate,baseline,enforce}.mk`; jedes Fragment hängt seine
  Checks via `GATE_CHECKS += …` an; jedes referenzierte Target existiert (kein halluziniertes Gate,
  [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)) — inkl. der
  **neu verdrahteten** `baseline-verify` (Skript heute orphaned).
- [ ] `record-gates: $(GATE_CHECKS)` **und** `gates: record-gates`: `record-gates` läuft strikt nach
  allen Checks, `make -j gates` parallelisiert die Checks (`.NOTPARALLEL` **nicht** gewählt). Rot
  gesehen: eine Mutation, die die Ordnungskante entfernt, färbt einen Reihenfolge-Wächter rot
  ([`AGENTS.md` §3.6](../../../../AGENTS.md), via `make mutate`).
- [ ] `make full-smoke` grün: das emittierte `make -j gates` läuft im Ziel-Repo grün, der
  `record-gates`-Stempel matcht — byte-identische, reproduzierbare Emission
  ([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)).
- [ ] `make gates` grün (Dogfood).
- [ ] Doku: [`architecture.md`](../../../../spec/architecture.md) §5 (Fragment-Assembly) trägt den Umbau
  bereits; prüfen, ob eine `conventions.md`-MR-Adaption für die Assembly-Form nötig wird.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

<!--
Welche Änderungen sind geplant? Datei- oder Komponenten-Ebene reicht.
Der Implementation-Agent erweitert diese Liste in seinem ersten Lauf.
-->

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/gen/golang.go` | refactor | `goMakefileTmpl` → Aggregator-Root-`Makefile` (Glob-Include + `GATE_CHECKS` + Ordnungskante) + neues Code-Gate-Fragment `harness/mk/<lang>.mk` (lint/build/test) |
| `internal/emit/emit.go` (`DocGate`) | update | zusätzlich das `harness/mk/<belang>.mk`-Doc-Gate-Fragment (`GATE_CHECKS += docs-check`, `include d-check.mk`) |
| `internal/emit/baseline.go` (`BaselineVerify`) | update | zusätzlich das Baseline-Fragment (`GATE_CHECKS += baseline-verify` + Rezept) — verdrahtet das heute orphaned `baseline-verify.sh` |
| `internal/emit/enforce.go` (`Enforce`) | update | zusätzlich das Enforce-Fragment (`record-gates`-Rezept); `gates:`/Ordnungskante leben im Aggregator |
| `internal/wire/wire.go` (`Place`) | refactor | `dCheckInclude`/`enforceWiring`-Anhang entfernen → reiner Placer (kein Makefile-Rewrite) |
| `cmd/ai-harness-init/main.go` (`emitTargets`) | update | die neuen `harness/mk/*.mk`-Ziele in den Phase-3-Pre-Flight aufnehmen |
| go-Tests (gen/emit/wire/cmd) + `make full-smoke` | update | Fragment-Emission byte-identisch; `make -j gates` grün, `record-gates` strikt zuletzt |
| `test/mutations` | neu | Mutation „Ordnungskante entfernt" (`record-gates: $(GATE_CHECKS)` → `record-gates:`) → Reihenfolge-Wächter rot |

## 4. Trigger

**Start** (`next` → `in-progress`): erster Slice der welle-05; ihr Trigger ist erfüllt
([`ADR-0007`](../../adr/0007-bootstrap-phasen.md) Accepted, Doc-Folgepflichten erledigt). Der Implementer
beginnt, sobald der Slice nach `next/` gezogen ist.

**Rückführungen:**
- `in-progress` → `next`: Aggregator-Umbau + Fragment-Emit + `wire`-Migration + Mutations-Wächter
  sprengen eine Session → neu zerlegen (z. B. Assembly-Umbau von der Fragment-Emission trennen).
- `in-progress` → `open`: blockiert, falls das `make -j`-Ordnungskanten-Verhalten einen Carveout braucht
  (Modul 7).

## 5. Closure-Trigger

DoD vollständig · `make gates` grün · `make full-smoke` + `make mutate` grün · Slice per `git mv` nach
`done/` · Closure-Notiz geschrieben.

## 6. Risiken und offene Punkte

- **Migrations-Bruch nicht additiv:** die heutige `wire`-Verdrahtung (`gates: docs-check` +
  `gates: record-gates` direkt) muss **vollständig** auf Variable-Akkumulation umgestellt werden — ein
  Parallel-Betrieb beider Wege driftet und untergräbt die Ordnungskante.
- **`make -j`-Parallelität:** die Ordnungskante muss `record-gates` strikt nach allen Checks halten,
  **ohne** die Checks zu serialisieren; `.NOTPARALLEL` ist per [`ADR-0007`](../../adr/0007-bootstrap-phasen.md)
  ausgeschlossen.
- **Glob-Include-Reihenfolge (gelöst):** `include harness/mk/*.mk` bindet alphabetisch ein
  (baseline < doc-gate < enforce < go) — die Ordnungskante `record-gates: $(GATE_CHECKS)` steht deshalb
  im **Root-Aggregator NACH dem Include** (nicht in einem Fragment), sonst sähe sie `GATE_CHECKS`
  unvollständig (go.mk kommt zuletzt). `GATE_CHECKS +=` selbst ist reihenfolge-invariant.
- **Aggregator vorübergehend im Generator (Option A):** der sprach-agnostische Aggregator wird bis
  slice-035 vom `gen` (Go-Skelett) emittiert; slice-035 zieht ihn in einen Init-Emitter um. Der Umzug
  ist eine Relocation (Inhalt stabil), kein Rewrite — bewusst akzeptiert, um green-before-extend zu
  halten (kein Regressionsrisiko am `--lang go`-Pfad).

## 7. Closure-Notiz (nach `done/`)

**Geliefert:** die emittierte Makefile-Verdrahtung als **Aggregator + `harness/mk/*.mk`-Fragmente**
(Option A, verhaltens-erhaltend unter `--lang go`); `wire.Place` ist reiner Placer; `baseline-verify` im
Ziel **neu verdrahtet** (vorher orphaned); `record-gates` läuft strikt zuletzt via Ordnungskante. Review
konform (F-1 aufgelöst), DoD bestätigt (`docs/reviews/2026-07-23-slice-034-review.md`,
`docs/reviews/2026-07-23-slice-034-verify.md`).

**Was funktionierte:** die Ordnungskante ist **load-bearing** — ohne sie fährt `make gates` nur
record-gates, die Checks entfallen; ein starkes, testbares Property (`make full-smoke`-Marker +
`TestGenerate_AggregatorHasOrderEdge`). `make full-smoke` mit `make -j gates` belegte Parallelität +
Nachweis-zuletzt real.

**Was anders lief:** die Ist-Messung (Modul 9 §4) deckte auf, dass der Plan slice-035s Init-Phase
voraussetzte → Nutzer-Entscheid **Option A** (Re-Scope **vor** Code, wie slice-022→022a/b). Der Reviewer
fing **F-1** (die von der entfernten Mutation 21 getragene Doc-Gate-Deckung war nur behavioral migriert),
das ich als Restrisiko nur benannt statt geschlossen hatte.

**Steering-Loop:**
1. **Ein Slice-Plan, der die Lieferung eines Folge-Slices voraussetzt** (hier „Init emittiert" = slice-035),
   **ist ein Re-Slice-Signal — die Ist-Messung (Modul 9 §4) fängt es vor Code.** Der verfeinerte Plan
   (Option A) scoped die Verengung explizit.
2. **Eine entfernte Mutation ist entfernte Deckung.** 33 → 38/39 migriert, 21 zunächst nur „behavioral via
   full-smoke" → Reviewer-F-1. Lehre: beim Löschen eines Mutations-Falls die bewachte **Eigenschaft**
   benennen und ihr neues Zuhause (Test **und** Mutation) prüfen; „behavioral gedeckt" ist im §3.6-Sinn
   keine gelistete rot-gesehene Zusage. → jetzt Fall 40 + `TestDocGate_FragmentWiresDocsCheck`.
3. **Mutations-Seds müssen shellcheck-clean sein** (§3.2, kein Inline-Suppress): `$(...)` in Single-Quotes
   triggert SC2016 → anker-`.*` statt Literal-Muster.

**Folge-Slices:** keine neuen `open/` nötig (035–038 der welle-05 bereits geplant). **slice-035** relocatet
den Aggregator vom `gen` in einen Init-Emitter (der Option-A-Deferral) und macht Init sprachlos.

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas sind **GF** (Greenfield) — siehe Kurs Modul 5 §Worked Mini-Example und die
Modus-Deklaration in [`harness/conventions.md`](../../../../harness/conventions.md) (`*` = Greenfield,
`harness/tools/` = Greenfield). Kein BF/Hybrid, daher genügt dieser Hinweis.
