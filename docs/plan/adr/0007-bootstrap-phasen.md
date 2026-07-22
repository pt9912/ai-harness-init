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
2. **Die Emit-Schicht ist bis auf EINE Stelle sprach-agnostisch** (AGENTS/regelwerk/templates/
   Stop-Hook/record-gates/Commands — belegt in slice-031/033). Die **Ausnahme**: das
   **BLOCKED-Set des Command-Guards** ist per `--lang` (slice-032, `emit.Enforce(…, lang, …)`
   substituiert die Sprach-Toolchain). Diese eine Stelle wird darum **fragment-komponiert**
   (Entscheidung 2): der Guard-Skript-Kern bleibt sprachlos, das BLOCKED-Set liest er aus
   `blocked/*`-Fragmenten — **universell bei Init** (apt/pip/npm/cargo), **je Sprache aus
   `add-lang`**. So hat Init einen funktionsfähigen (universell blockenden) Guard, und `add-lang`
   erweitert ihn ohne In-Place-Edit. `gen.Generate` (Skelett) + `wire.Place` brauchen weiter `--lang`.
3. **Das `.mk`-Fragment-Muster trägt** — das Repo bindet das Doc-Gate heute schon als `d-check.mk`
   ein ([`MR-010`](../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)); Gate-Belange sind über includebare Fragmente komponierbar.

## Entscheidung

Wir **phasieren den Bootstrap** und **koppeln die Sprachwahl aus dem Init ab**. Fünf verbindliche
Festlegungen:

1. **Drei Phasen, Sprache deferred.** `--lang` wird **optional**.
   - **Init** (`ai-harness-init [--name X]`, ohne Sprache): emittiert die sprach-agnostische Harness
     (regelwerk, AGENTS, Doc-Chain-Templates, `docs/plan`-Struktur, Commands) + die Durchsetzung
     **inklusive eines funktionsfähigen Guards** (Guard-Skript + `blocked/universal` — blockt
     apt/pip/npm/cargo sofort, sprachlos) + ein **sprach-agnostisches Gate**. `make gates` ist
     **grün auf reinen Docs**.
   - **Architecture** (Adopter-Arbeit über die emittierten Commands): lastenheft → spezifikation →
     architecture + ein **Sprach-ADR** verfassen.
   - **Prog. Languages** (`ai-harness-init add-lang <sprache> <pfad>`, **wiederholbar**): generiert das
     Skelett je Sprache/Modul **gemäß ADR** und ergänzt dessen Code-Gates. Mono-Repo fällt heraus
     (mehrere `add-lang`-Aufrufe). `--lang <X>` beim Init bleibt als **One-Shot-Kurzform**
     (Init + ein `add-lang`) rückwärtskompatibel erhalten.
2. **Fragment-Emission zweier Art — Gate-Fragmente UND Guard-BLOCKED-Fragmente** (verallgemeinert
   `d-check.mk`/[`MR-010`](../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)).
   - **Gate-`.mk`-Fragmente je Belang/Sprache:** die Root-Makefile wird ein **dünner Aggregator**
     mit einem **benannten Glob-Include** (`include harness/mk/*.mk`) — so ist `add-lang` ein reiner
     **Fragment-Drop** (`harness/mk/<modul>.mk` mit lint/build/test), **kein** In-Place-Edit. Init
     legt `harness/mk/{doc-gate,baseline,enforce}.mk`. Die Fragmente **akkumulieren in eine Variable**
     (`GATE_CHECKS += …`), das Ziel ist `gates: $(GATE_CHECKS) record-gates` — order-robust über
     beliebig viele Fragmente. **`record-gates` zuletzt hält nur seriell:** das `gates`-Ziel wird
     `.NOTPARALLEL` markiert (bzw. record-gates als eigener Nachlauf), sonst röte `make -j` den
     Nachweis (parallele Prerequisites). **Migrations-Bruch benannt:** heute hängt der `wire`-Schritt
     `gates: docs-check` + `gates: record-gates` **direkt** an (kein `$(GATE_CHECKS)`) — die Umstellung
     auf Variable-Akkumulation + Glob-Include ist Teil des Umbaus, nicht additiv.
   - **Guard-BLOCKED-Fragmente:** der Command-Guard liest sein BLOCKED-Set aus `blocked/*`
     (statt hart substituiert) — Init legt `blocked/universal`, `add-lang` droppt `blocked/<sprache>`.
     Der Guard-Skript-Kern bleibt sprachlos; das löst H2 (Durchsetzung wird phasierbar, ohne
     In-Place-Edit, ohne Clobber beim Re-Lauf).
3. **Idempotenz über eine Artefakt-Klassifikation** (ersetzt den Zwei-Wege-Pre-Flight
   refuse/`--force`). **Prinzip:** jede emittierte Datei ist **genau einer** Klasse zugeordnet; im
   **Zweifel gilt `skip-if-present`** (nie Adopter-Inhalt clobbern — der sichere Default). „konvergent"
   ist die bewusste Ausnahme für **rein tool-eigene Infrastruktur, die der Adopter nicht editieren
   soll**.

   | Datei/Gruppe | Klasse | Warum |
   |---|---|---|
   | `.harness/baseline/<tag>/` (regelwerk + templates), `harness/mk/*.mk` (Aggregator + Fragmente), `d-check.mk`, `.claude/hooks/*.sh`, `.claude/settings.json`, `tools/harness/*` (record-gates, working-tree-hash, extract-command.awk, Guard-Skript), `blocked/*` | **konvergent** | reine tool-erzeugte Infrastruktur; Re-Lauf schreibt kanonisch ([`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) byte-identisch), heilt Drift + Baseline-Upgrade |
   | `spec/{lastenheft,spezifikation,architecture}.md`, `docs/plan/adr/*`, roadmap/slices/carveouts, `README.md`, `CLAUDE.md`, `AGENTS.md`, `harness/conventions.md` (MR-Block!), `harness/README.md`, `.d-check.yml` | **skip-if-present** | Adopter füllt/adaptiert/wächst sie ([`LH-FA-03`](../../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7)); nie überschreiben |
   | **Skelett aufgeteilt:** `Makefile`-Aggregator + `harness/mk/*.mk` → **konvergent**; `main.go`, adopter-editierbarer Skelett-Code, `.golangci.yml` → **skip-if-present** | gemischt | H1: eine *Datei* ist eine Klasse — der Aggregator ist tool-eigen, der Code ist Adopter-Boden |
   | **Commands** (`.claude/commands/*.md`) | **skip-if-present** (Default) | sie tragen den ANPASSEN-Marker (slice-033) → der Adopter adaptiert sie; Prozess-Updates zieht er aus dem vendored regelwerk, nicht per Auto-Clobber. *Als bewusste Abweichung vom „Infrastruktur=konvergent" — beim implementierenden Slice final zu bestätigen.* |

   Jede Phase ist damit **idempotent + konvergent**: Re-Lauf repariert/hebt die tool-eigene
   Infrastruktur **ohne** ein `skip-if-present`-Artefakt anzufassen.
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
- **Klassifikation je Datei, nicht je Verzeichnis** (Auflösung des Skelett-Grenzfalls, Entscheidung 3):
  Aggregator + `harness/mk/*.mk` sind konvergent, `main.go` + adopter-editierbarer Code sind
  skip-if-present. Eine Datei ist genau eine Klasse; im Zweifel skip-if-present. Die eine bewusste
  Grauzone — die **Commands** (adopter-adaptiert vs. tool-aktualisiert) — ist beim implementierenden
  Slice final zu bestätigen (Default: skip-if-present).
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
| `make full-smoke` | **Guard bei Init:** der emittierte Guard blockt ohne Sprache schon `pip`/`apt` (`blocked/universal`); nach `add-lang go` zusätzlich `go`/`golangci-lint` (Union `blocked/*`) | `make full-smoke` |
| `make full-smoke` | **Idempotenz:** `init` zweimal → 2. Lauf Exit 0, **keine** `skip-if-present`-Datei (`spec/*.md` mit Testinhalt) geändert; konvergente Artefakte byte-identisch | `make full-smoke` |
| `make full-smoke` | **add-lang + Reihenfolge:** nach `add-lang go <pfad>` läuft `make gates` grün **inkl.** Go-Gates; `record-gates` bleibt letztes Prerequisite **auch unter `make -j`** (`.NOTPARALLEL`) | `make full-smoke` |
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
| 2026-07-22 | Proposed überarbeitet nach unabhängigem Review (H1 Makefile-Klassen-Split · H2 Guard per `--lang` → BLOCKED-Fragmente · `.d-check.yml`/`conventions.md` reklassifiziert · Fragment-Migration + `make -j` benannt) | [Review](../../reviews/2026-07-22-adr-0007-proposed-review.md) |
