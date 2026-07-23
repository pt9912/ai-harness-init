# Welle welle-05: Bootstrap-Phasen

**Lifecycle:** Die aktive Welle liegt flach unter `docs/plan/planning/`; bei
Closure wandert diese Datei per `git mv` nach `done/` (neben ihre
`welle-<NN>-results.md`). Der Zustand ist die Verzeichnis-Position — kein
Status-Feld. Ob eine flache Welle *aktuell* oder *geplant* ist, sagt die Roadmap.

**Zielmeilenstein:** kein Meilenstein-Bezug — die Welle liefert die
[`ADR-0007`](../../adr/0007-bootstrap-phasen.md)-Fähigkeit („doc führt" gilt auch für die Zielsprache);
M1/M2 sind bereits erreicht.

**Verantwortlich:** Claude (Pair-Session). **Datum:** 2026-07-23.

---

## 1. Welle-Ziel

Die Welle setzt [`ADR-0007`](../../adr/0007-bootstrap-phasen.md) um: den **phasierten Bootstrap**. Danach
läuft `ai-harness-init` **sprach-agnostisch** (Init → `make gates` grün auf reinen Docs), die
Zielsprache ist eine **Adopter-ADR-Entscheidung** statt eines Init-Arguments, und `add-lang` ist
**wiederholbar** (Mono-Repo). Die Emission wird **idempotent** (konvergent / skip-if-present, prunt
nie), und der Command-Guard behält einen **gebackenen universellen Boden** (nie fail-open). Gemessen
wird das Ergebnis an den `make full-smoke`-Fitness-Functions aus
[`ADR-0007`](../../adr/0007-bootstrap-phasen.md).

## 2. Trigger (Welle startet)

- [`ADR-0007`](../../adr/0007-bootstrap-phasen.md) **Accepted** (2026-07-22, nach zwei Proposed-Review-Runden).
- Doc-Folgepflichten aus [`ADR-0007`](../../adr/0007-bootstrap-phasen.md) erledigt: CR
  [`lastenheft.md`](../../../../spec/lastenheft.md) 0.10.0 ([`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen)
  gesplittet, [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) auf `add-lang`
  gehoben) **und** der [`architecture.md`](../../../../spec/architecture.md)-Nachzug (Bootstrap-Phasen ·
  Fragment-Assembly · Commands-/Skills-Emitter).
- welle-04 (Durchsetzung & Emission) in `done/` — die `.claude/`-Emission, auf der die Phasierung aufsetzt, steht.

## 3. Closure-Trigger (Welle schließt)

- Alle Slices (034–038) in `done/`.
- `make gates` grün.
- `make full-smoke` grün über den [`ADR-0007`](../../adr/0007-bootstrap-phasen.md)-Fitness-Functions:
  **doc-only-Init** grün ohne Skelett · **`add-lang`** → `make -j gates` inkl. Code-Gates grün,
  `record-gates` strikt zuletzt · **Idempotenz + kein Prune** (2. Init-Lauf Exit 0, keine
  `skip-if-present`-Datei berührt, ein gedropptes `blocked/<sprache>` bzw. `harness/mk/<sprache>.mk`
  überlebt den sprachlosen Re-Lauf) · **Guard-Boden + Union** (blockt `pip`/`apt` sprachlos, nach
  `add-lang go` zusätzlich `go`/`golangci-lint`; fail-safe bei geleertem/fehlendem `blocked/`).
- `make mutate` grün (die Klassifikations- und Guard-Wächter tragen Zähne).
- Closure-Notiz `welle-05-results.md` + Carveout-Audit der Welle.

## 4. Slices in dieser Welle

<!-- Zustand jedes Slice = sein Lifecycle-Verzeichnis (open/next/in-progress/
done), hier NICHT gespiegelt — eine Status-Spalte driftete gegen die
Verzeichnisse (dieselbe zweite Wahrheit, die beim Slice retired wurde). -->

| Slice | Titel | Bezug |
|---|---|---|
| slice-034 | Gate-Fragment-Assembly (Aggregator + `include harness/mk/*.mk` + `GATE_CHECKS +=` + Ordnungskante) | [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen), [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) |
| slice-035 | CLI-Phasierung: `--lang` optional, Init sprach-agnostisch, doc-only-Gate grün | [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen), [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) |
| slice-036 | Guard-BLOCKED-Union: universeller Boden gebacken + `tools/harness/blocked/*`-Union + Regression-Wächter | [`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren), [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) |
| slice-037 | `add-lang`-Subkommando: Skelett + Code-Gate-/`blocked`-Fragment-Drop, wiederholbar (Mono-Repo) | [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) |
| slice-038 | Idempotenz-Klassifikation (konvergent / skip-if-present; ersetzt Pre-Flight-refuse/`--force`) | [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen), [`LH-FA-03`](../../../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7), [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) |

## 5. Abhängigkeiten

- **Wird blockiert von:** welle-04 (done) — die `.claude/`-Durchsetzungs-/Commands-Emission, die diese
  Welle phasiert und um die Fragment-Assembly erweitert.
- **Blockiert:** keine geplante Folge-Welle direkt; die Backlog-Cluster B/C/D bleiben unabhängig.
- **Intern (Reihenfolge):** slice-034 → slice-035 → { slice-036 · slice-037 } → slice-038. 034 legt die
  Fragment-Assembly als Fundament; 035 macht Init sprachlos darauf; 036/037 setzen Guard-Union bzw.
  `add-lang` obendrauf; 038 klassifiziert die Idempotenz über **alle** emittierten Dateien und läuft
  daher zuletzt.

## 6. Out-of-Scope für diese Welle

- **a-check / [`LH-FA-07`](../../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren)** — bleibt
  aufgeschoben (hängt an hexagonalen Schichten, die weder Dogfood noch Skelett tragen).
- **git-Repo-Vorbedingung der emittierten `make gates` (INFO I-1)** — bleibt benannter
  `open/`-Folgepunkt: `make full-smoke` git-init'et das Ziel bereits, der reale Nicht-git-Init-Fall ist
  ein separater Wartungs-/Doku-Slice.
- **Interaktives TTY-Frontend** ([`ADR-0007`](../../adr/0007-bootstrap-phasen.md) Entscheidung 4: optional,
  nie tragend) — nicht in dieser Welle.
- **Weitere Sprach-BLOCKED-Sets** über das im Test belegte Set (Go) hinaus.

## 7. Closure-Notiz

Welle **geschlossen 2026-07-23** (beobachtbarer Trigger: alle Slices 034–038 in `done/`,
`make gates`/`make full-smoke`/`make mutate` grün). Ergebnisse, Steering-Loop-Einträge und
Carveout-Audit: [welle-05-results.md](welle-05-results.md).
