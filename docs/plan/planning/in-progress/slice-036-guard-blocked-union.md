# Slice slice-036: Guard-BLOCKED-Union — gebackener Boden + `blocked/*`

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.0/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** welle-05.

**Bezug:** [`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren), [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten), [`ADR-0007`](../../adr/0007-bootstrap-phasen.md).

**Autor:** Claude (Pair-Session). **Datum:** 2026-07-23.

---

## 1. Ziel

Der emittierte Command-Guard bekommt einen **gebackenen universellen Boden** (apt/pip/npm/cargo …, im
Skript hart) — **nie fail-open**, auch bei fehlendem/leerem `blocked/` ([`ADR-0007`](../../adr/0007-bootstrap-phasen.md)
NEU-H1) — und **liest+vereinigt** zusätzlich `tools/harness/blocked/*` (reines bash+`cat`,
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)). Die bisherige
`@@BLOCKED_SET@@`-Substitution (slice-032) entfällt; das Sprach-Set wandert in ein
`blocked/<sprache>`-Fragment, das `emit.Enforce` beim `--lang`-One-Shot direkt droppt (das
**wiederholbare** `add-lang`-Drop ist slice-037). So blockt der Guard **sprachlos** schon die
Paketmanager (Boden), mit `--lang go` **zusätzlich** die go-Toolchain (via `blocked/go`).

## 2. Definition of Done

<!--
Was muss erfüllt sein, damit der Slice in done/ wandert?
Liste mit jeweils prüfbarem Kriterium.
-->

- [ ] Der emittierte Guard trägt den universellen Boden **gebacken** (im Template hart, keine
  Substitution mehr) und **liest+vereinigt** `tools/harness/blocked/*`. Rot gesehen: eine Mutation, die
  den Boden aus dem Template entfernt, färbt einen Guard-Wächter rot
  ([`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren)/[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)).
- [ ] `emit.Enforce` emittiert `tools/harness/blocked/<lang>` mit der Sprach-Toolchain, wenn `--lang`
  ein gen-Profil hat; **sprachlos kein** `blocked/`-Fragment. Kopplung an `gen.SupportedLangs()` (Test).
- [ ] `make full-smoke`: der emittierte Guard blockt mit `--lang go` **`go build`** (via `blocked/go`)
  **und** `pip` (Boden); **sprachlos** blockt er `pip` (Boden), **nicht** `go`; **fail-safe** — bei
  geleertem `blocked/` blockt der Boden weiter (`pip`, NIE fail-open,
  [`ADR-0007`](../../adr/0007-bootstrap-phasen.md) NEU-H1).
- [ ] `make gates` grün (Dogfood).
- [ ] Doku: [`architecture.md`](../../../../spec/architecture.md) §2/§5 (Guard-Boden + Union) trägt es
  bereits; prüfen, ob eine `conventions.md`-MR nötig wird.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

<!--
Welche Änderungen sind geplant? Datei- oder Komponenten-Ebene reicht.
Der Implementation-Agent erweitert diese Liste in seinem ersten Lauf.
-->

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/emit/templates/enforce/pretooluse-command-guard.sh` | update | `BLOCKED="@@BLOCKED_SET@@"` → gebackener Boden + `blocked/*`-Union-Read (bash+`cat`, nie fail-open) |
| `internal/emit/enforce.go` | refactor | `@@BLOCKED_SET@@`-Substitution + `blockedSet`/`guardDst`/`bytes` raus; `blockedByLang` → `blocked/<lang>`-Fragment-Inhalt; `Enforce` emittiert `blocked/<lang>` bei Profil; `EnforcePaths(lang)`; `BlockedFragmentForLang` |
| `cmd/ai-harness-init/main.go` | update | `emitTargets(…, lang)` → `emit.EnforcePaths(lang)` (blocked/<lang> im Phase-3-Pre-Flight) |
| go-Tests (emit) + `make full-smoke` | update | Guard-Boden gebacken + Union-Read; blocked/<lang>-Emit; Boden-vs-Fragment getrennt; full-smoke sprachlos/`--lang`/fail-safe |
| `test/mutations` | update | Fall 35 (`@@BLOCKED_SET@@`) obsolet; neu: Boden-aus-Template-entfernt / `blocked/<lang>`-nicht-emittiert |

## 4. Trigger

**Start** (`next` → `in-progress`): slice-035 in `done/` (Init sprachlos + Guard sprachlos emittiert,
Boden bisher via Substitution). Der Implementer beginnt, sobald der Slice nach `next/` gezogen ist.

**Rückführungen:**
- `in-progress` → `next`: Guard-Umbau + `blocked/*`-Union + Emit-Änderung + full-smoke-Fail-safe +
  Test-/Mutations-Umzug sprengen eine Session → neu zerlegen.
- `in-progress` → `open`: blockiert, falls der Union-Read-Ansatz ein Guard-Verhaltensproblem zeigt
  (Carveout, Modul 7).

## 5. Closure-Trigger

DoD vollständig · `make gates` grün · `make full-smoke` (sprachlos + `--lang go` + fail-safe) +
`make mutate` grün · Slice per `git mv` nach `done/` · Closure-Notiz geschrieben.

## 6. Risiken und offene Punkte

- **Fail-safe Boden ([`ADR-0007`](../../adr/0007-bootstrap-phasen.md) NEU-H1):** der Guard darf **NIE**
  fail-open sein — der Boden ist im Skript **gebacken**; ein fehlendes/leeres `blocked/` lässt ihn
  unberührt. `make full-smoke` muss das explizit rot-sehen (geleertes `blocked/` → `pip` weiter geblockt).
- **Dogfood-Guard NICHT geändert (bewusst):** `test/guard.bats` testet den **Dogfood**-Guard
  (`.claude/hooks/`, [`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks)) — der behält seinen eigenen BLOCKED-Set. slice-036 ändert nur das **emittierte**
  Template ([`ADR-0007`](../../adr/0007-bootstrap-phasen.md)-Fitness #2). Das Dogfooding des
  Boden+Union-Modells (Dogfood adoptiert `harness/tools/blocked/`) ist ein bewusster Nicht-Inhalt
  (Single-Lang-Dogfood; Adoption bei Multi-Lang oder eigenem Slice).
- **quote-blind-Union / bash+cat (LH-QA-03):** die `blocked/*`-Dateien sind reine Wortlisten
  (space/newline), die der Guard via `in_set` (whitespace-Split) vereinigt — kein Parsing, kein node/jq.
- **`add-lang`-Drop ist slice-037:** hier emittiert nur der `--lang`-One-Shot `blocked/<lang>`; das
  wiederholbare `add-lang`-Drop (Mono-Repo) folgt.

## 7. Closure-Notiz (nach `done/`)

*Erst nach Abschluss füllen — was funktionierte · was anders lief · Steering-Loop-Eintrag ·
Folge-Slices.*

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas sind **GF** (Greenfield) — siehe Kurs Modul 5 §Worked Mini-Example und die
Modus-Deklaration in [`harness/conventions.md`](../../../../harness/conventions.md) (`*` = Greenfield).
Kein BF/Hybrid, daher genügt dieser Hinweis.
