# ADR-0007: Bootstrap-Phasen — Sprache via ADR, idempotente Fragment-Emission

**Status:** Proposed

**Datum:** 2026-07-22

**Autor:** Claude (Pair-Session)

**Bezug:** [`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen), [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [ADR-0003](0003-go-native-binaries.md), [ADR-0005](0005-ziel-repo-distribution.md), [ADR-0006](0006-durchsetzung-commands-tool-als-quelle.md)

**Schärft:** [`architecture.md`](../../../spec/architecture.md) (der Bootstrap-Ablauf / die Emitter-Phasen). Aufwärts-Deklaration: wer diese ADR ändert, zieht den Bootstrap-Ablauf in `architecture.md` und die betroffenen Anforderungen ([`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen), [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4)) nach.

---

## Kontext

`ai-harness-init` bootstrappt Repos, die **„doc führt, code folgt"** befolgen
(lastenheft → spezifikation → architecture → ADR → Code). Das Ziel bekommt heute
den **vollständigen Doc-Chain** emittiert (`spec/{lastenheft,spezifikation,architecture}.template.md`
→ gestempelte `.md`). Aber [`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) macht `--lang` zur **Pflicht**
(Negative-AC: fehlt → Exit 2) und backt „`make gates` läuft grün" ein — das verlangt das
Sprachskelett. Folge: **in EINEM Lauf erhält das Ziel den (leeren) Doc-Chain UND ein fertiges
Sprachskelett** — die Sprache steht fest, bevor der Adopter seine eigene
lastenheft→spezifikation→architecture + den **Sprach-ADR** geschrieben hat. Das ist die
**„code führt"-Inversion**, die der Harness verbietet — dem Adopter am Schritt 0 aufgezwungen.
Die Sprachwahl ist normalerweise eine ADR-Entscheidung (wie ai-harness-init seine eigene Sprache
in [ADR-0003](0003-go-native-binaries.md) **nach** den Requirements festlegte).

Verschärfend: das Tool ist **single-lang** (ein `--lang`), aber ein **Mono-Repo** trägt mehrere
Sprachen/Module, jede eine eigene ADR-Entscheidung. Und der Lauf ist **nicht idempotent**: ein
zweiter Lauf kollidiert (Pre-Flight refuse, slice-025), `--force` würde die inzwischen **gefüllten
Adopter-Docs zerstören**.

**Tragende Annahmen** (kippen sie, kippt die Entscheidung):

1. **`docs-check` (d-check) ist sprach-agnostisch** — ein sprachloser Init kann ein grünes
   `make gates` haben (docs-check + baseline-verify + record-gates, alle sprachlos).
2. **Die Emit-Schicht ist bereits sprach-agnostisch** (AGENTS/regelwerk/templates/Durchsetzung/
   Commands) — belegt in slice-031/033; nur `gen.Generate` (Skelett) + `wire.Place` brauchen `--lang`.
3. **Das `.mk`-Fragment-Muster trägt** — das Repo bindet das Doc-Gate heute schon als `d-check.mk`
   ein ([`MR-010`](../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)); Gate-Belange sind über includebare Fragmente komponierbar.

## Entscheidung

Wir **phasieren den Bootstrap** und **koppeln die Sprachwahl aus dem Init ab**. Fünf verbindliche
Festlegungen:

1. **Drei Phasen, Sprache deferred.** `--lang` wird **optional**.
   - **Init** (`ai-harness-init [--name X]`, ohne Sprache): emittiert die sprach-agnostische Harness
     (regelwerk, AGENTS, Doc-Chain-Templates, `docs/plan`-Struktur, Durchsetzung, Commands) + ein
     **sprach-agnostisches Gate**. `make gates` ist **grün auf reinen Docs**.
   - **Architecture** (Adopter-Arbeit über die emittierten Commands): lastenheft → spezifikation →
     architecture + ein **Sprach-ADR** verfassen.
   - **Prog. Languages** (`ai-harness-init add-lang <sprache> <pfad>`, **wiederholbar**): generiert das
     Skelett je Sprache/Modul **gemäß ADR** und ergänzt dessen Code-Gates. Mono-Repo fällt heraus
     (mehrere `add-lang`-Aufrufe). `--lang <X>` beim Init bleibt als **One-Shot-Kurzform**
     (Init + ein `add-lang`) rückwärtskompatibel erhalten.
2. **Gate-Assembly über `.mk`-Fragmente je Belang/Sprache** (verallgemeinert `d-check.mk`/[`MR-010`](../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)).
   Die Root-Makefile wird ein **dünner Aggregator**; jeder Belang ist ein self-contained Fragment
   (Init: Doc-Gate/baseline-verify/record-gates; `add-lang`: `<modul>.mk` mit lint/build/test). Die
   Fragmente **akkumulieren in eine Variable**, `record-gates` steht **fix zuletzt**
   (`gates: $(GATE_CHECKS) record-gates`) — order-robust, egal wie viele Fragmente dazukommen.
   `add-lang` ist ein reiner **Fragment-Drop**, kein In-Place-Makefile-Edit.
3. **Idempotenz über eine Artefakt-Klassifikation**, die den heutigen Zwei-Wege-Pre-Flight
   (refuse / `--force`-overwrite) ersetzt:
   - **Tool-eigen, konvergent** (regelwerk, Gate-Config, Durchsetzung, Commands, Fragmente): beim
     Re-Lauf **auf kanonisch schreiben** — deterministisch ([`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)), byte-identisch, heilt Drift.
   - **Adopter-gefüllt, einmalig** (`spec/*.md`, ADRs, roadmap, `main.go`, `CLAUDE.md`):
     **skip-if-present** — nie überschreiben.
   Jede Phase ist damit **idempotent + konvergent**: Re-Lauf repariert/hebt die Harness (Baseline-Upgrade)
   **ohne** Adopter-Inhalt anzufassen.
4. **Interaktivität optional, nie tragend.** Der Kern bleibt flag-getrieben + deterministisch
   ([`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit); CI headless). Ein optionales TTY-Frontend **sammelt nur Werte** und ruft
   denselben Kern; ein Prompt beeinflusst **nie** die Output-Bytes. Next-Step-Hinweise nach jeder
   Phase sind *Ausgabe*, kein Zustand.
5. **Resume = idempotenter Re-Lauf, kein Zustandsfile.** Der Checkpoint ist das Repo selbst (Dateien +
   git). Eine „welche Phase lief"-Datei wäre eine zweite, driftende Wahrheit — Punkt 3 macht sie
   überflüssig.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — Status quo (`--lang` Pflicht, One-Shot, Pre-Flight refuse/`--force`) | nichts zu bauen; einfacher CLI-Vertrag | erzwingt „code führt" am Ziel (Skelett vor Sprach-ADR); kein Mono-Repo; nicht idempotent; `--force` clobbert Adopter-Docs |
| B — Interaktiver Wizard mit **Checkpoint-State-File** (`.harness/bootstrap-state`) | geführte UX; explizites Resume | State-File = zweite Wahrheit neben der Platte (Drift); Wizard-Prompts brechen CI/Determinismus ([`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)), wenn tragend; komplex |
| D — Phasen, aber **ein monolithisches minimales Makefile**, das `add-lang` **in-place editiert** | ein Makefile, weniger Dateien | In-Place-Edit ist fragil + nicht idempotent (Re-Lauf/Reihenfolge-Drift); Mono-Repo verschmiert ein Makefile mit N Sprachen |
| **C — gewählt: Phasen + idempotente `.mk`-Fragment-Emission, deterministischer flag-Kern, optionale Interaktivität** | doc-führt gilt auch für die Zielsprache; Mono-Repo fällt heraus; idempotenter Re-Lauf heilt Abbrüche + Baseline-Upgrades ohne Doc-Clobber; CI/Determinismus unberührt; baut auf bestehendem `d-check.mk`/[`MR-010`](../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)-Muster | verlangt eine korrekte Artefakt-Klassifikation (Fehl-Klasse clobbert oder driftet); revidiert die slice-025-Transaktions-Garantie; mehr CLI-Oberfläche (`add-lang`) |

## Konsequenzen

- **Positiv:** „doc führt" gilt jetzt auch für die **Zielsprache** — der Adopter entscheidet sie im
  ADR nach seiner Architektur, nicht das Tool am Schritt 0. **Mono-Repo** fällt heraus (ein
  `add-lang` je Sprache/Modul). Der **idempotente Re-Lauf** heilt die heutige „partielles `.harness/`
  nach Abbruch"-Grenze (die EHRLICHE GRENZE aus slice-025) und zieht **Baseline-Upgrades**
  (neuer regelwerk-Tag, koppelt an `baseline-freshness`) — beides **ohne** Adopter-Docs anzufassen.
  CI/Determinismus bleiben unberührt (flag-Kern).
- **Negativ:** revidiert die **slice-025-Transaktions-Garantie** „Kollision → kein Teil-Bootstrap" zu
  **„jede Phase konvergiert das Ziel auf den kanonischen Zustand"** (Teil-Supersede der Pre-Flight-
  Semantik). Verlangt eine **korrekte Artefakt-Klassifikation** (konvergent vs. skip-if-present) — eine
  Fehl-Klasse **clobbert Adopter-Inhalt** (falsch: konvergent) oder **lässt Drift** (falsch:
  skip-if-present). Mehr CLI-Oberfläche (`add-lang`), mehr Fragment-Dateien.
- **Offener Klassifikations-Grenzfall** (der eigentliche Design-Knackpunkt für die Slices): ist das
  generierte **Skelett** (`main.go`/`Makefile`) *konvergent* (Scaffolder-Update, überschreibt) oder
  *skip-if-present* (der Adopter baut darauf)? Vorschlag: der **Aggregator + die Fragmente** sind
  konvergent, `main.go` + adopter-editierbare Skelett-Teile sind skip-if-present — je Datei zu
  entscheiden, nicht je Verzeichnis.
- **Folgepflicht:**
  - **CR an [`lastenheft.md`](../../../spec/lastenheft.md):** [`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) splitten (Init sprach-agnostisch, `--lang`
    optional; Negative-AC „fehlt `--lang` → Exit 2" fällt); [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) von „ein Skelett je
    `--lang`" auf „**wiederholbarer**, ADR-gegateter Skelett-Schritt (Mono-Repo)" heben.
  - **[`architecture.md`](../../../spec/architecture.md)-Nachzug:** Bootstrap-Phasen, `add-lang`, doc-only-Gate, Fragment-Assembly
    (der ohnehin offene architecture.md-Backlog-Punkt aus dem welle-04-Closure fällt hier mit rein).
  - **Fitness Functions** (unten) + Slices (eine neue Welle „Bootstrap-Phasen").

## Fitness Function (falls maschinell prüfbar)

| Tooling | Regel | Make-Target |
|---|---|---|
| `make full-smoke` | **Doc-only-Gate:** nach `init` (ohne Sprache) läuft `make gates` grün (docs-check + baseline-verify + record-gates), **ohne** Skelett | `make full-smoke` |
| `make full-smoke` | **Idempotenz:** `init` zweimal → 2. Lauf Exit 0, **keine** Adopter-Datei (`spec/*.md` mit Testinhalt) geändert; tool-eigene Artefakte byte-identisch | `make full-smoke` |
| `make full-smoke` | **add-lang:** nach `add-lang go <pfad>` läuft `make gates` grün **inkl.** der Go-Gates; `record-gates` bleibt letztes Prerequisite | `make full-smoke` |
| `go test` / `make mutate` | **Klassifikation:** ein Test koppelt jede emittierte Datei an ihre Klasse (konvergent vs. skip-if-present); eine Fehl-Klasse färbt rot | `make test` |

## Re-Evaluierungs-Trigger

- Wenn ein bisher sprach-agnostischer Gate-Belang (v. a. `docs-check`) **sprach-abhängig** würde —
  dann trägt die Annahme „Init grün ohne Sprache" nicht mehr.
- Wenn der **Mono-Repo-Bedarf** wegfällt (nur je ein Repo/eine Sprache) — dann wäre `add-lang`
  Überbau gegenüber optionalem `--lang`.
- Wenn ein Nutzer die **interaktive Ergonomie** über den flag-Kern priorisiert (Prinzipien-Konflikt
  mit [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)).

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-07-22 | Proposed (nach Design-Dialog: Phasen · Idempotenz · Fragment-Gates · Interaktivität · Resume) | dieser ADR |
