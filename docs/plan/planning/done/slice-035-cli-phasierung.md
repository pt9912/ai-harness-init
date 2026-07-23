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

**Geliefert:** Init ist sprach-agnostisch — `--lang` optional. Sprachloser Bootstrap → `make gates`
grün auf reinen Docs (docs-check + baseline-verify + record-gates, **kein** Code-Gate/Skelett). Der
Aggregator ist vom `gen` in einen **Init-Emitter** (`emit.Makefile`) relocatet (der Option-A-Deferral aus
slice-034). Review **KONFORM** (0 HIGH/MEDIUM, 1 INFO), DoD **bestätigt**
(`docs/reviews/2026-07-23-slice-035-review.md`, `docs/reviews/2026-07-23-slice-035-verify.md`).

**Was funktionierte:** die **Relocation** war chirurgisch — der Aggregator-Const **und** sein
Ordnungskanten-Wächter (`TestGenerate_AggregatorHasOrderEdge` → `TestMakefile_HasOrderEdge`) **und** die
Mutation 38 (`# files` → `emit/makefile.go`) wanderten **zusammen**; Reviewer + Verifier bestätigten:
**kein Wächter an toter `gen`-Ausgabe** (die slice-034-F-1-Klasse trat nicht auf). Der doc-only-Lauf im
`full-smoke` belegt sprachlos grün **und** die Abwesenheit von Code-Gate-Markern/Skelett
([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).

**Was anders lief:** die neuen `hasLang`-Conditionals hoben `bootstrap` über die gocognit-Schwelle
(23 > 20) — die lineare Emit-Sequenz wurde in `emitAll` ausgelagert (die Pre-Flights blieben in
`bootstrap`, weil ihr Print+Return an die Wirkung gebunden ist, slice-025).

**Steering-Loop:**
1. **Relocation = Code + Wächter + Mutation zusammen bewegen.** Wandert eine geprüfte Eigenschaft in ein
   anderes Paket, MUSS der Wächter-Test und sein `test/mutations`-Fall mit — sonst prüft der Test tote
   Ausgabe (die slice-034-F-1-Klasse). Hier korrekt vorweggenommen; der Reviewer bestätigte es explizit.
2. **Phasieren eines Monolithen hebt die kognitive Komplexität.** Die lineare Fehler-Kette (`if err …`)
   in einen Helfer auslagern — aber die Pre-Flights (mit §3.6-Print+Return-Bindung) am Ort lassen.
3. **Refactor-Mutations-Reconciliation:** entfernter Code obsoletet **beides** — seine Mutation UND
   seinen Test (Fall 22 + `TestPlace_NoGatesTarget` zusammen raus). Eine Kollisions-Zusage, die auf ein
   umgezogenes Artefakt (Makefile → `emit.MakefilePath`) zielte, muss auf ein noch-treffendes Ziel
   (`go.mod`, reines `wire.Targets`-Ziel) umgestellt werden, sonst bewacht sie den falschen Pfad.

**Folge-Slices:** keine neuen `open/` nötig (036–038 der welle-05 geplant). Das Review-INFO (der
Aggregator nutzt den Kollisions-**Refuse**, während [`ADR-0007`](../../adr/0007-bootstrap-phasen.md) ihn
als **konvergent** klassifiziert) ist
**slice-038** (Idempotenz-Klassifikation) — dort wird die konvergente Emission umgesetzt. **slice-036**
(Guard-BLOCKED-Union) ist der nächste.

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas sind **GF** (Greenfield) — siehe Kurs Modul 5 §Worked Mini-Example und die
Modus-Deklaration in [`harness/conventions.md`](../../../../harness/conventions.md) (`*` = Greenfield).
Kein BF/Hybrid, daher genügt dieser Hinweis.
