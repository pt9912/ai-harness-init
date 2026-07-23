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

Die **emittierte** Root-Makefile wird ein **dünner Aggregator** mit benanntem Glob-Include
(`include harness/mk/*.mk`); die Checks akkumulieren in `GATE_CHECKS`, und der Gate-Nachweis läuft über
eine **Ordnungskante** (`record-gates: $(GATE_CHECKS)`) strikt zuletzt, während `make -j` die Checks
parallel fährt. Init emittiert die sprach-agnostischen Fragmente `harness/mk/{doc-gate,baseline,enforce}.mk`.
Das ersetzt die heutige `wire`-Direkt-Verdrahtung (`gates: docs-check` + `gates: record-gates` angehängt)
— **Migrations-Bruch, nicht additiv**.

## 2. Definition of Done

- [ ] Die emittierte Root-Makefile ist ein Aggregator mit `include harness/mk/*.mk`; **kein** direktes
  `gates:`-Prereq-Anhängen mehr — der Migrations-Bruch der heutigen `wire`-Verdrahtung ist vollzogen
  ([`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen)).
- [ ] Init emittiert `harness/mk/{doc-gate,baseline,enforce}.mk`; jedes Fragment hängt seine Checks via
  `GATE_CHECKS += …` an; jedes referenzierte Target existiert (kein halluziniertes Gate,
  [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
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
| `internal/emit` (Makefile-Emitter) | refactor | Root-Makefile → dünner Aggregator mit `include harness/mk/*.mk` statt Voll-Makefile |
| `internal/emit` Templates (`harness/mk/*.mk`) | neu | `doc-gate`/`baseline`/`enforce` als sprach-agnostische Fragmente, je `GATE_CHECKS += …` |
| `wire.Place` (Verdrahtung) | refactor | direkte `gates:`-Prereq-Anhänge entfernen → Ordnungskante `record-gates: $(GATE_CHECKS)` |
| go-Tests + `make full-smoke` | update | Reihenfolge-Wächter (`record-gates` zuletzt) + byte-identische Fragment-Emission |
| `test/mutations` | neu | Mutation „Ordnungskante entfernt" → der Reihenfolge-Wächter muss rot werden |

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
- **Glob-Include-Reihenfolge:** `include harness/mk/*.mk` bindet alphabetisch ein — kein Fragment darf
  von der Include-Reihenfolge abhängen (`GATE_CHECKS +=` ist reihenfolge-invariant).

## 7. Closure-Notiz (nach `done/`)

*Erst nach Abschluss füllen — was funktionierte · was anders lief · Steering-Loop-Eintrag ·
Folge-Slices.*

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas sind **GF** (Greenfield) — siehe Kurs Modul 5 §Worked Mini-Example und die
Modus-Deklaration in [`harness/conventions.md`](../../../../harness/conventions.md) (`*` = Greenfield,
`harness/tools/` = Greenfield). Kein BF/Hybrid, daher genügt dieser Hinweis.
