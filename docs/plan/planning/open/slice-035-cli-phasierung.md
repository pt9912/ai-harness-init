# Slice slice-035: CLI-Phasierung — `--lang` optional, Init sprach-agnostisch

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.0/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** welle-05.

**Bezug:** [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen), [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`ADR-0007`](../../adr/0007-bootstrap-phasen.md).

**Autor:** Claude (Pair-Session). **Datum:** 2026-07-23.

---

## 1. Ziel

Init wird **sprach-agnostisch**: `--lang` wird **optional** ([`ADR-0007`](../../adr/0007-bootstrap-phasen.md)
Entscheidung 1). Ohne `--lang` emittiert der Bootstrap die Harness + Durchsetzung + den **Aggregator** +
die sprach-agnostischen Fragmente (doc-gate/baseline/enforce), und `make gates` ist **grün auf reinen
Docs** (docs-check + baseline-verify + record-gates, **ohne** Skelett/Code-Gates). Dazu wird der
Aggregator vom `gen` in einen **Init-Emitter** relocatet (der slice-034-Option-A-Deferral): `gen`
emittiert die Root-Makefile nicht mehr, nur noch das Code-Gate-Fragment + Skelett. Mit `--lang go` bleibt
das Verhalten wie slice-034 (Skelett + Code-Gate-Fragment via `gen`/`wire`) — der One-Shot.

## 2. Definition of Done

<!--
Was muss erfüllt sein, damit der Slice in done/ wandert?
Liste mit jeweils prüfbarem Kriterium.
-->

- [ ] `--lang` ist **optional**: fehlt es, **kein Exit 2** mehr; der Bootstrap läuft sprachlos
  ([`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen)). Rot gesehen: eine Mutation,
  die das Exit-2-Refuse wieder einbaut, färbt einen CLI-Test rot.
- [ ] Der Aggregator wird von einem **Init-Emitter** (`emit`) emittiert — **immer**, auch sprachlos;
  `gen.goProfile` trägt **keine** Root-`Makefile` mehr, nur `harness/mk/<lang>.mk` + Skelett
  ([`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4): Skelett ≠ Aggregator).
- [ ] `make full-smoke` **doc-only**: nach sprachlosem Init läuft `make gates` grün (docs-check +
  baseline-verify + record-gates, **kein** lint/build/test), ohne Skelett — kein halluziniertes
  Code-Gate ohne Sprache ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- [ ] `make full-smoke` mit `--lang go` bleibt grün (One-Shot, wie slice-034).
- [ ] `make gates` grün (Dogfood).
- [ ] Doku: [`architecture.md`](../../../../spec/architecture.md) §1/§4.1 (Init sprachlos) trägt es
  bereits; prüfen, ob eine `conventions.md`-MR nötig wird.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

<!--
Welche Änderungen sind geplant? Datei- oder Komponenten-Ebene reicht.
Der Implementation-Agent erweitert diese Liste in seinem ersten Lauf.
-->

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/emit/makefile.go` | neu | `emit.Makefile` (Init-Emitter) + Aggregator-Const (aus `gen` relocatet) + `MakefilePath` — Aggregator wird sprach-agnostisch/immer emittiert |
| `internal/gen/golang.go` | refactor | Root-`Makefile` aus `goProfile` raus (nur `harness/mk/<lang>.mk` + Skelett); Aggregator-Const entfernt (→ `emit`) |
| `internal/wire/wire.go` | refactor | Makefile-Vorbedingung raus — das Skelett trägt keine Root-Makefile mehr (die kommt aus dem Init-Emitter) |
| `cmd/ai-harness-init/main.go` | update | `--lang` optional (kein Exit 2, Usage angepasst); `emit.Makefile` **immer**, `gen.Generate`/`wire.Place` nur bei gesetztem `--lang`; `emitTargets` konditional |
| go-Tests (gen/emit/wire/cmd) + `make full-smoke` | update | Aggregator-Wächter von `gen` nach `emit`; sprachloser CLI-Pfad; neuer doc-only-`full-smoke`-Lauf |
| `test/mutations` | update | Fall 38 (Aggregator-Ordnungskante) auf `emit` umziehen; neuer Fall: `--lang`-optional (Exit-2-Reintro → rot) |

## 4. Trigger

**Start** (`next` → `in-progress`): slice-034 in `done/` (Aggregator + Fragment-Assembly grün — der
Aggregator existiert zum Relocaten). Der Implementer beginnt, sobald der Slice nach `next/` gezogen ist.

**Rückführungen:**
- `in-progress` → `next`: CLI-Umbau + Aggregator-Relocation + gen/wire-Änderung + doc-only-full-smoke +
  Test-/Mutations-Umzug sprengen eine Session → neu zerlegen (z. B. Relocation von der CLI-Optionalität
  trennen).
- `in-progress` → `open`: blockiert, falls der sprachlose `make gates` unerwartetes Gate-Verhalten zeigt
  (Carveout, Modul 7).

## 5. Closure-Trigger

DoD vollständig · `make gates` grün · `make full-smoke` (doc-only **und** `--lang go`) + `make mutate`
grün · Slice per `git mv` nach `done/` · Closure-Notiz geschrieben.

## 6. Risiken und offene Punkte

- **Sprachloser `make gates`:** der Glob `include harness/mk/*.mk` matcht ohne Sprache nur drei Fragmente
  (baseline/doc-gate/enforce) → `GATE_CHECKS` = baseline-verify + docs-check, **kein** lint/build/test.
  `make full-smoke` doc-only muss belegen, dass die drei Marker da sind und die Code-Gate-Marker
  **fehlen** (kein halluziniertes Gate, kein stiller Verlust).
- **Guard sprachlos:** `emit.Enforce(targetDir, "", force)` liefert `blockedSet("")` = **universeller
  Boden** (apt/pip/npm/cargo, kein Sprach-Set) — der emittierte Guard blockt sprachlos die Paketmanager.
  Der gebackene Boden + `blocked/*`-Union ist slice-036; hier genügt der Boden via Substitution.
- **Aggregator-Relocation `gen`→`emit`:** der Const-Move **und** die Verlagerung des Aggregator-Wächters
  (`TestGenerate_AggregatorHasOrderEdge` → emit-Test) + der Mutation 38 muss vollständig sein, sonst prüft
  ein Test tote `gen`-Ausgabe (die Klasse „Wächter am toten Code" aus slice-034-F-1).

## 7. Closure-Notiz (nach `done/`)

*Erst nach Abschluss füllen — was funktionierte · was anders lief · Steering-Loop-Eintrag ·
Folge-Slices.*

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas sind **GF** (Greenfield) — siehe Kurs Modul 5 §Worked Mini-Example und die
Modus-Deklaration in [`harness/conventions.md`](../../../../harness/conventions.md) (`*` = Greenfield).
Kein BF/Hybrid, daher genügt dieser Hinweis.
