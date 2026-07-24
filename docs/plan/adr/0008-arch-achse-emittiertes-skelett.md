# ADR-0008: Architektur-Achse (`--arch`) für das emittierte Skelett

**Status:** Proposed

**Datum:** 2026-07-24

**Autor:** Claude (Pair-Session)

**Bezug:** [`LH-FA-07`](../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren), [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), [`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen), [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [ADR-0003](0003-go-native-binaries.md), [ADR-0005](0005-ziel-repo-distribution.md), [ADR-0007](0007-bootstrap-phasen.md)

**Schärft:** [`architecture.md`](../../../spec/architecture.md) (die Skelett-Generierung / Emitter-Komposition). Aufwärts-Deklaration: wer diese ADR ändert, zieht die betroffenen Anforderungen ([`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), [`LH-FA-07`](../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren)) und den Generierungs-Ablauf in `architecture.md` nach.

---

## Kontext

[`LH-FA-07`](../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren) verlangt, dass der Bootstrap ein **Architektur-Gate** ins Zielrepo emittiert:
`.a-check.yml` + `a-check.mk` (per-Tool-Fragment via `a-check --print-mk`, analog dem Doc-Gate
[`MR-010`](../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)). a-check ist ein **reales Schwester-Tool** (a-check/d-check, gleiche Build-Familie —
im `Dockerfile`-Kopf benannt) und prüft **hexagonale Schichten** (`domain/ports/adapters`) im
emittierten Sprachskelett — read-only, netzlos.

**Der Blocker (seit M2 aufgeschoben):** Es existiert **kein geschichtetes Skelett**. Der Generator
([`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4)) trägt heute **ein flaches Layout-Profil je Sprache** (`go` → `main.go`,
`cpp` → `src/main.cpp`; `profiles()` in `internal/gen/gen.go` mappt `lang → func(version) → {relpfad:
inhalt}`). Ein a-check über einer **flachen** Struktur wäre ein **halluziniertes Gate über leerem
Prüfbereich** — [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) verbietet das ausdrücklich, und [`LH-FA-07`](../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren)s
Negative-AC macht es zur Regel: „trägt das Skelett keine hexagonalen Schichten, wird das Gate
begründet **nicht** emittiert".

**Der Kern — Architektur ⟂ Sprache.** Hexagonale Schichtung ist ein **quer-schneidender
Struktur-Belang**, der über Sprachen hinweg gilt. Ihn in die Sprach-Profile zu backen (`go-flach`,
`go-hexagonal`, `cpp-flach`, `cpp-hexagonal`, …) ergäbe eine **kombinatorische Explosion** (N Sprachen
× M Architekturen volle Profile) und widerspräche [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4)s „ein Profil je Sprache,
sprach-agnostischer Generator".

**Abgrenzung (Nutzer-Korrektur 2026-07-24): dies betrifft die ZIELREPOS, nicht ai-harness-init
selbst.** ai-harness-init bleibt in seinem Go-idiomatischen Flach-Layout (`internal/{emit,fetch,gen,
wire}` + `cmd/`); es wird **nicht** hexagonal umstrukturiert. a-check ist ein **emittiertes** Gate
(ins Zielrepo), nicht ein Dogfood-Gate auf dem Tool. `--lang` (die Sprach-Achse) existiert bereits
([`ADR-0007`](0007-bootstrap-phasen.md): `--lang` optional, `add-lang <sprache> <pfad>` wiederholbar/Mono-Repo) — die Architektur
ist die **analoge, parallele Achse**.

**Einbettung in [`ADR-0007`](0007-bootstrap-phasen.md).** Dessen drei Phasen sind Init → **Architecture** → Prog. Languages.
Die **Architecture-Phase** ist genau die, in der der Adopter seinen Architektur-ADR schreibt — dort
entscheidet er die Schichtung. `add-lang` emittiert das Skelett **gemäß ADR**; die Arch-Achse ist der
Mechanismus, mit dem diese Entscheidung ins generierte Skelett fließt.

**Tragende Annahmen** (kippen sie, kippt die Entscheidung):

1. **a-check ist ein reales, gepinntes Tool** mit `--print-mk` (wie d-check) — der Emitter erzeugt ein
   Fragment, baut das Gate nicht selbst.
2. **Das `profiles()`-Muster trägt eine zweite Dimension** — der Generator kann `lang × arch`
   komponieren, ohne die Sprach-Agnostik ([`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4)) aufzugeben.
3. **`flat` bleibt Default und gültig** — ein sprachliches Ziel ohne Arch-Wahl bekommt das heutige
   flache Skelett und **kein** a-check; nichts an der bestehenden Emission bricht.

## Entscheidung

Wir führen eine **Architektur-Achse `--arch`** ein — eine **eigene, zu `--lang` parallele Achse**, die
die Struktur des **emittierten** Skeletts bestimmt. Fünf Festlegungen:

1. **`--arch <arch>` als Wert-Achse, Default `flat`.** Werte zunächst `flat` (heutiges Verhalten) und
   `hexagonal` (`domain/ports/adapters`). Sie reiht sich parallel zu `--lang`/`add-lang` ein:
   `ai-harness-init add-lang <sprache> <pfad> [--arch <arch>]` — **je Modul** (ein Mono-Repo kann
   `apps/api --arch hexagonal` und `apps/tool --arch flat` mischen). `--arch` beim Init ist die
   **One-Shot-Kurzform** neben `--lang` (Init + ein `add-lang(<lang>, ., <arch>)`), rückwärtskompatibel:
   fehlt `--arch`, gilt `flat` und alles bleibt wie heute.
2. **Komposition `lang-renderer × arch-layout`, nicht N×M-Profile.** Die **Arch-Schicht** liefert das
   **Layout** (welche Verzeichnisse — `domain/ports/adapters` — und welche Datei-Rollen je Schicht);
   die **Sprach-Schicht** **rendert** die Dateien je Rolle in ihrer Sprache. Der Generator komponiert
   beide: **N Sprach-Renderer + M Arch-Layouts**, statt N×M volle Profile. `flat` ist das degenerierte
   Layout (eine Rolle: „Entry-Point" → `main.go`/`src/main.cpp` wie heute). So bleibt „eine neue
   Sprache = ein neuer Renderer" **und** „eine neue Architektur = ein neues Layout" je linear.
3. **a-check konditional emittieren ([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).** Nur bei einem **schichten-tragenden**
   Layout (`hexagonal`) emittiert `add-lang` `.a-check.yml` (bildet die realen Schichten des Skeletts
   ab) + `a-check.mk` (aus `a-check --print-mk`, Image digest-gepinnt) und hängt `a-check` als
   Gate-Fragment an. Bei `flat` wird **kein** a-check emittiert — das Ziel bleibt gültig (Doc-Gate +
   Code-Gates), `make gates` grün ohne a-check.
4. **a-check ist emitted-only; verifiziert via `full-smoke`.** ai-harness-init wird **nicht**
   umstrukturiert. Der Nachweis läuft über den E2E-Smoke: Bootstrap eines `--arch hexagonal`-Skeletts →
   im Ziel `make a-check` Exit 0 (und ein `--arch flat`-Lauf emittiert **kein** a-check). Dogfood-Parität
   (a-check auf dem Tool selbst) ist **bewusst ausgeklammert** — der volle hexagonale Umbau eines
   ~5-Paket-CLI wäre Over-Engineering; falls je gefordert, ist er ein eigener Folge-ADR.
5. **Idempotenz-Klasse nach [`ADR-0007`](0007-bootstrap-phasen.md) Entscheidung 3.** Der geschichtete Skelett-**Code**
   (`domain/…`, `ports/…`, `adapters/…`) ist **skip-if-present** (Adopter-Boden, wächst); das
   `a-check.mk`-Fragment + der Aggregator-Anschluss sind **konvergent** (tool-eigene Infrastruktur);
   `.a-check.yml` ist **skip-if-present** (der Adopter passt die Schicht-Config an seine reale Struktur
   an — wie `.d-check.yml`).

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — **Layered-Profile je Sprache** (`go-hexagonal`, `cpp-hexagonal` neben `go`/`cpp`) | einfachster Dispatch (ein Map-Eintrag mehr); keine Kompositions-Schicht | **N×M-Kombinatorik** (jede Sprache × Architektur = volles Profil); widerspricht „ein Profil je Sprache" ([`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4)); Architektur nicht als Achse wählbar |
| B — **Architektur in die Sprach-Profile backen** (jedes Profil legt selbst Schichten an) | keine neue CLI-Oberfläche | Schichtung wird **nicht wählbar** (flat vs. hexagonal); der quer-schneidende Belang ist in N Profilen dupliziert; a-check-Konditionalität schwer je Sprache konsistent zu halten |
| C — **nichts tun** (a-check weiter aufschieben) | kein Aufwand | [`LH-FA-07`](../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren) bleibt dauerhaft offen; **M4 unerreichbar**; die Spec trägt eine nie eingelöste Anforderung |
| **D — gewählt: `--arch`-Achse, `lang-renderer × arch-layout`-Komposition, a-check emitted-only konditional** | orthogonal (linear statt N×M); Architektur ist bewusste Adopter-Wahl (ADR-0007-Architecture-Phase); `flat`-Default bricht nichts; entsperrt [`LH-FA-07`](../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren)/M4 | verlangt eine Kompositions-Schicht im Generator (mehr Struktur als die flache `profiles()`-Map); je Sprache ein Schicht-Renderer (Aufwand, aber linear); a-check läuft nicht auf dem Dogfood |

## Konsequenzen

- **Positiv:** [`LH-FA-07`](../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren) / **M4** entsperrt — ein `--arch hexagonal`-Skelett gibt a-check einen
  **realen Prüfbereich**. Architektur wird eine **bewusste Adopter-Entscheidung** (ADR in der
  ADR-0007-Architecture-Phase), nicht ein Tool-Default. Die **orthogonale Komposition** hält Sprachen
  und Architekturen je **linear** wachsend. `flat` bleibt Default → **keine** Regression der heutigen
  Emission.
- **Negativ:** Der Generator braucht eine **Kompositions-Schicht** (`lang-renderer × arch-layout`) statt
  der heutigen flachen `profiles()`-Map — mehr Struktur, und die Sprach-Profile müssen von „ein
  Datei-Satz" auf „rendere Rolle X" umgestellt werden (Migrations-Bruch, kein rein additiver Schritt).
  Je Sprache ist ein **Schicht-Renderer** zu schreiben (Aufwand, aber linear und opt-in — nur wo
  `hexagonal` gewünscht). **a-check läuft nicht auf dem Dogfood** (emitted-only) — die Parität, die
  d-check hat, ist hier bewusst nicht gegeben; der Nachweis trägt `full-smoke`.
- **Folgepflicht:**
  - **CR an [`lastenheft.md`](../../../spec/lastenheft.md):** [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) um die **Arch-Achse** ergänzen
    (`add-lang … [--arch <arch>]`, `lang × arch`-Komposition); [`LH-FA-07`](../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren)s Happy-Path auf
    „`--arch hexagonal` → Skelett trägt Schichten → a-check emittiert + Exit 0" schärfen.
  - **[`architecture.md`](../../../spec/architecture.md)-Nachzug:** die Kompositions-Schicht (Arch-Layout ⟂ Sprach-Renderer),
    `--arch`, die konditionale a-check-Emission.
  - **Fitness Functions** (unten) + eine **Welle „Arch-Achse"** (Slices: erstes Arch-Layout
    `hexagonal` + Go-Schicht-Renderer · Generator-Komposition `lang × arch` · konditionaler
    a-check-Emitter `.a-check.yml`/`a-check.mk` · `full-smoke`-Erweiterung).

## Fitness Function (falls maschinell prüfbar)

| Tooling | Regel | Make-Target |
|---|---|---|
| `make full-smoke` | **hexagonal → a-check aktiv:** nach `add-lang go <pfad> --arch hexagonal` trägt das Skelett `domain/ports/adapters`, `.a-check.yml` + `a-check.mk` liegen im Ziel, `make a-check` ist Exit 0 | `make full-smoke` |
| `make full-smoke` | **flat → kein a-check ([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)):** nach `add-lang go <pfad>` (ohne `--arch`/`--arch flat`) liegt **kein** `.a-check.yml`/`a-check.mk` im Ziel; `make gates` grün **ohne** a-check | `make full-smoke` |
| `go test` / `make mutate` | **Emissions-Kopplung:** der a-check-Emitter feuert **genau dann**, wenn das Layout schichten-tragend ist — ein Test koppelt Arch-Wert ↔ a-check-Präsenz; eine Fehl-Emission (a-check bei `flat` **oder** fehlend bei `hexagonal`) färbt rot | `make test` |
| `go test` | **Komposition deterministisch ([`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)):** gleiche `(lang, arch, version)` → byte-identisches Skelett | `make test` |

## Re-Evaluierungs-Trigger

- Wenn a-check **sprach-abhängige** Schicht-Configs braucht, die die Orthogonalität (`arch-layout ⟂
  lang-renderer`) brechen — dann trägt Annahme 2 nicht mehr.
- Wenn **mehr als eine** geschichtete Architektur gefragt ist (clean/onion/…): `--arch` wird ein Enum
  mit >2 Werten — die Achse trägt das, aber die Layout-Menge wächst (dann je Layout ein Nutzen-Beleg,
  kein spekulatives Profil).
- Wenn **Dogfood-Parität** (a-check auf ai-harness-init selbst) doch gefordert wird — eigener
  Folge-ADR (Repo-Restrukturierung), hier bewusst ausgeklammert.
- Wenn der **Mono-Repo-/Per-Modul-Bedarf** wegfällt (nur je ein Repo mit einer Architektur) — dann wäre
  `--arch` am Init genug und der Per-`add-lang`-Parameter Überbau.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-07-24 | Proposed (nach Design-Dialog: Achsen-Trennung `--arch` ⟂ `--lang`; **Nutzer-Korrektur: Zielrepo-Fokus, nicht Repo-Architektur**; a-check emitted-only konditional) | dieser ADR |

<!--
Nach Accepted: NICHT mehr inhaltlich überschreiben (Hard Rule 3.4). Spätere Schärfungen als neue ADR
mit „Supersedes ADR-0008".
-->
