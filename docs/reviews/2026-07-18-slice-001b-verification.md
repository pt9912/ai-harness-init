# Verifikation slice-001b — Go-Gates build/lint + Promotion

**Rolle:** Verifier (Modul 11, Verification Harness) — unabhängig, frischer Kontext,
NICHT Implementer, NICHT Reviewer.
**Datum:** 2026-07-18.
**Eingabe:** DoD + Spec + Plan (Modul 11) —
`docs/plan/planning/in-progress/slice-001b-go-gates.md` §2 (DoD) / §3 (Plan-Tabelle) /
§1 (Ziel) / §6 (Risiken); `spec/lastenheft.md` `LH-QA-01` (keine halluzinierten Gates /
offline-grün), `LH-QA-02` (Reproduzierbarkeit / Pin), `LH-QA-03` (minimale Abhängigkeiten —
kein Host-`go`), `LH-FA-07` (arch-Gate, bewusst aufgeschoben — Bezugspunkt der „Nicht
behauptet"-Zeile); `ADR-0003` (Go + Docker-only Cross-Compile, Accepted/aktiv). Realer Stand
aus Working-Tree-Diff (5 tracked Sach-Dateien + 2 untracked, davon 1 Review-Artefakt) **plus**
dem committeten Eintritts-Move `f8e8672` (slice-001b → `in-progress/`).
**Frage:** „Hat das Gebaute umgesetzt, was Plan/DoD/Spec verlangt?" (nicht „ist es gut?" = Review).
**Mittel:** ausgeführte Gates/Docker/`git`/`grep` — jede Aussage mit Beleg. Kein Host-`go`/
`golangci-lint` (Guard-Falle). Der Verifier committet/verschiebt nichts.

**Vorbemerkung zum Abhak-Zustand.** Die DoD-Kästchen in §2 stehen im Working Tree auf `[ ]`
(unabgehakt), §7 trägt den Platzhalter `<!-- Erst nach Abschluss füllen. -->`. Es liegt also
**keine** positive Implementer-Behauptung „`[x]`" vor — der Verifier prüft die **Substanz** jedes
DoD-Punkts gegen den realen Stand. §2 listet **fünf** Kästchen; das letzte („Closure-Notiz") ist
ein Planner-Schritt **nach** der Verifikation (wie in der Aufgabe vorgegeben).

**Nachtrag zu den Impl-Review-Befunden (`docs/reviews/2026-07-18-slice-001b-impl-review.md`).**
Der aktuelle Working Tree hat die dort notierten offenen Punkte bereits **geschlossen**:
LOW-1 (a-checks generische `unused-receiver`-Test-Ausnahme fehlte) ist in `.golangci.yml:161-166`
nachgezogen (Kommentar „a-check-Parität (Review-LOW-1)"); INFO-1 (fehlendes `make compile`) ist
in `Makefile:51-52` als eigenes Target ergänzt (a-check-Parität, ausdrücklich „NICHT in gates").
Der geprüfte Stand ist damit neuer als der Review-Snapshot.

---

## DoD-Punkt für DoD-Punkt (§2)

### DoD-1 — `make build` cross-compiliert `cmd/ai-harness-init` in der Dockerfile-`build`-Stage im digest-gepinnten Go-Image; kein Host-`go` — **CONFIRMED (ausgeführt)**
- **Dockerfile-`build`-Stage real (`Dockerfile:42-46`):** `FROM deps AS build` · `COPY . .` ·
  `RUN CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /out/ai-harness-init ./cmd/ai-harness-init`
  — statischer Cross-Compile (a-check-Muster), Ziel ist genau `./cmd/ai-harness-init`.
- **Digest-Pin über `deps`:** `deps` = `FROM golang:${GO_VERSION}@sha256:792443b89f65105abba56b9bd5e97f680a80074ac62fc844a584212f8c8102c3`
  (`Dockerfile:14`), `GO_VERSION ?= 1.26.4` (`Makefile:14`), durchgereicht via `--build-arg
  GO_VERSION=$(GO_VERSION)` (`Makefile:49`). Byte-identisch zum Schwester-Repo
  (`grep golang: /Development/a-check/Dockerfile` → derselbe `@sha256:792443b8…`) — LH-QA-02.
- **Ausgeführt (Exit 0):** `make build` lief im `make gates`-Lauf grün
  (`#13 [build 2/2] RUN CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /out/ai-harness-init
  ./cmd/ai-harness-init` → CACHED, `writing image … naming to ai-harness-init:build`). CACHED ist
  hier belastbar: der `COPY . .`-Cache-Key bindet den vollen Quellstand → identischer Inhalt ist
  bereits grün gebaut.
- **Binary funktioniert (unabhängig gegenbelegt):**
  `docker run --rm --network none ai-harness-init:build /out/ai-harness-init --help` → **Exit 0**,
  volle Usage; **ohne** `--lang` → `Fehler: --lang ist erforderlich.` + Usage, **Exit 2**. Das
  Kompilat spiegelt den aktuellen `cmd/`-Stand (kein Stale-Binary).
- **Kein Host-`go`:** der go-build-Aufruf lebt im **Dockerfile-`RUN`**, getrieben vom Makefile via
  `docker build --target build` — der PreToolUse-Guard (blockt Host-Go/-golangci-lint) greift nicht,
  weil er nur Bash scannt; Docker-only, ADR-0003 / LH-QA-03 gewahrt.

### DoD-2 — `make lint` (golangci-lint, gepinntes Image, Dockerfile-`lint`-Stage) grün; keine Inline-Suppression; `.golangci.yml` zentrale Config — **CONFIRMED (ausgeführt)**
- **Dockerfile-`lint`-Stage real (`Dockerfile:34-40`):** `FROM golangci/golangci-lint:${GOLANGCI_LINT_VERSION}@sha256:5cceeef04e53efe1470638d4b4b4f5ceefd574955ab3941b2d9a68a8c9ad5240 AS lint`
  · `COPY --from=deps /go/pkg/mod /go/pkg/mod` · `COPY . .` · `RUN golangci-lint run ./...`.
  `GOLANGCI_LINT_VERSION ?= v2.12.2` (`Makefile:15`).
- **Image digest-gepinnt + byte-identisch zu a-check:** `grep golangci /Development/a-check/Dockerfile`
  → `@sha256:5cceeef04e53efe1470638d4b4b4f5ceefd574955ab3941b2d9a68a8c9ad5240` — **byte-identisch**
  (LH-QA-02, bewusster Schwester-Repo-Spiegel).
- **Grün, frisch (kein Stale-Green):** im `make gates`-Lauf lief `lint` mit `--no-cache-filter lint`
  **frisch**: `#17 [lint 5/5] RUN golangci-lint run ./...` → `#17 4.599 0 issues.` (mit Timing,
  nicht CACHED). „0 issues." wörtlich belegt.
- **Keine Inline-Suppression (Hard Rule 3.2):** `grep -rn nolint cmd/` → **leer** (Exit 1);
  `grep -rn nolint --include=*.go .` → **leer** (Exit 1). Kein `//nolint` im Go-Code.
- **`.golangci.yml` trägt die zentrale Config:** valides `version: "2"`-Profil (`default: none` +
  5 Default- + ~23 SOLID-nahe Linter, `revive`-Regelblock); alle `exclusions` zentral **und mit
  `Why:`-Kommentar** (u. a. `errcheck`-`Fprint*`, `testpackage`-`cmd/`, Test-Komplexität,
  `unused-parameter`/`unused-receiver` für `_test.go`). Dass die Config wirkt (nicht Deko), beweist
  der grüne Lauf — ein invalides Profil bräche `golangci-lint run` mit Config-Fehler ab.

### DoD-3 — `build`/`lint` im Makefile UND in `gates` UND in AGENTS §4 + harness/README §Sensors promotet — erst nach grünem Target — **CONFIRMED (ausgeführt)**
- **Im Makefile angelegt:** `lint:` (`Makefile:45-46`) und `build:` (`Makefile:48-49`) als eigene
  Targets (`docker build --target lint`/`build`, build-args gepinnt); beide in `.PHONY`
  (`Makefile:36`: `… test lint build compile shell-lint …`).
- **In `gates`:** `gates: baseline-verify docs-check lint build test shell-lint record-gates`
  (`Makefile:112`) — `lint` **und** `build` gelistet.
- **In AGENTS.md §4 + harness/README.md §Sensors promotet (git diff belegt):** beide Doku-Tabellen
  tragen jetzt neue Zeilen `make lint` (Go-Lint, Dockerfile-`lint`-Stage) und `make build`
  (Cross-Compile, Dockerfile-`build`-Stage); die harness/README-Zeilen zitieren `ADR-0003`.
- **„Nicht behauptet"-Zeile ist ehrlich (LH-QA-01 / Hard Rule 3.1):** die alte Zeile „Nicht
  behauptet (folgt mit slice-001b): `build`/`lint`" ist **entfernt** und durch „Der Dogfood-Go-
  Gate-Stack ist **vollständig** … **Nicht behauptet**: das Architektur-Gate (a-check, `LH-FA-07`)
  — bewusst aufgeschoben" ersetzt. Das arch-Gate fehlt **genuin**: `ls .a-check.yml a-check.mk` →
  „Datei oder Verzeichnis nicht gefunden". Die Promotion behauptet nur, was real grün läuft; kein
  halluziniertes Gate.
- **Promotion erst nach grünem Target:** `make lint` (`0 issues.` frisch) und `make build`
  (Exit 0 + laufendes Binary) sind **verifiziert grün**, bevor die Doku sie führt. Da der gesamte
  Diff uncommitted im selben Working Tree liegt, landen Target-Anlage, `gates`-Aufnahme und
  Doku-Promotion im **selben Commit** (DoD-Wortlaut „im selben Commit") — der Eintritts-Move
  `f8e8672` ist davon getrennt (reiner Rename, s. u.).

### DoD-4 — `make gates` grün (Exit 0) — **CONFIRMED (ausgeführt)**
- `make gates` → **Exit 0**. Reihenfolge und Teilläufe alle grün:
  - `baseline-verify: v3.1.0 OK — 42 Dateien` (Integrität + Vollständigkeit, netzlos).
  - `docs-check` (d-check, `--network none`, Digest-Ref `sha256:9c317bf1…36a1`):
    `53 Datei(en) geprüft, 0 Befund(e)` — der neue Go-Gate-Diff erzeugt keinen toten Referenz-/
    Anchor-/Codepath-Befund.
  - `lint`: `#17 4.599 0 issues.` (frisch, `--no-cache-filter lint`).
  - `build`: `docker build --target build` → `naming to ai-harness-init:build` (Exit 0).
  - `test`: bats `1..50 … ok 50` (50/50, `--network none`) + go-test frisch
    (`#13 3.311 ok github.com/pt9912/ai-harness-init/cmd/ai-harness-init`).
  - `shell-lint` (shellcheck über `.claude/hooks/*.sh harness/tools/*.sh`): ohne Befund.
  - `record-gates`: als letzter Prerequisite (Nachweis nur nach grünen Gates) — Gesamt-Exit 0.
- **Nuance (wie slice-001a / slice-016..018):** Lauf auf dem Working Tree, nicht auf frischem Klon
  — der Frisch-Klon-Beweis (LH-QA-01-Smoke im Wortsinn) bleibt die bekannte MR-003-CI-Restlücke
  nach Commit; kein Blocker.

### DoD-5 — Closure-Notiz mit Steering-Loop-Lerneintrag — **AUSSTEHEND (Planner-Schritt, kein VIOLATED)**
- `slice-001b-go-gates.md` §7 (`:71-73`) trägt weiter den Platzhalter
  „`<!-- Erst nach Abschluss füllen. -->`". Die Closure-Notiz wird per Prozess **nach** der
  Verifikation in der Planner-Rolle geschrieben (wie in der Aufgabe vorgegeben) — daher **erwartet
  leer**, kein VIOLATED. Vor `git mv → done/` mit echtem Steering-Loop-Lerneintrag nachzutragen
  (Modul 5).

---

## Plan-vs-Code-Diff (Verifier-spezifisch)

**Plan-Tabelle §3 vollständig gedeckt (4 Zeilen):**
- `Dockerfile` (update): `compile`/`lint`/`build`-Stages ergänzt (die `test`-Stage stand aus
  slice-001a); Bases digest-gepinnt, `GOLANGCI_LINT_VERSION`-ARG. ✓
- `.golangci.yml` (neu): zentrale Lint-Config (Suppressions nur dort, mit `Why:`, kein inline
  `//nolint`). ✓
- `Makefile` (update): `build`/`lint` (`docker build --target`, `GOLANGCI_LINT_VERSION` build-arg)
  neu, beide in `gates` **und** `.PHONY`; `d-check.mk` unberührt (Go-Gate lebt im Makefile). ✓
- `AGENTS.md` §4 / `harness/README.md` §Sensors (update): Promotion `build`/`lint` aus „Nicht
  behauptet" — plus `README.md` (konsistente Gate-Aufzählung). ✓

**Scope-Prüfung — `compile`-Target/-Stage (nicht namentlich in der Plan-§3-Tabelle):** die
`compile`-Stage (`Dockerfile:28-32`) + das `make compile`-Target (`Makefile:51-52`) sind eine
begründete, a-check-treue Beigabe („Schnelles Compile-Feedback ohne Tests/Lint", ausdrücklich
**NICHT in gates**). Kein halluziniertes Gate: `compile` steht **nicht** in `gates:` und wird
nirgends als Gate behauptet; es kann nicht unabhängig brechen (echte Teilmenge dessen, was
`build`/`test` ohnehin kompilieren). Es schließt zudem den Impl-Review-Befund INFO-1 (a-check hat
`make compile`, hier fehlte es). **Kein problematischer Scope-Creep.**

**Untracked:** `.golangci.yml` (geplant, §3 „neu"); `docs/reviews/2026-07-18-slice-001b-impl-review.md`
(Modul-10-Review-Artefakt). Keine ungeplante Sach-Datei. `git diff --stat` = 5 tracked
(`AGENTS.md`, `Dockerfile`, `Makefile`, `README.md`, `harness/README.md`), +44/-9 Zeilen —
alles innerhalb §3.

## ADR-Konformität

- **Keine ADR berührt:** `git status docs/plan/adr/` → leer; der Diff trifft kein
  `docs/plan/adr/000*.md`. Keine Accepted-ADR verändert.
- **ADR-0003 (Go + Docker-only Build) gewahrt und vervollständigt:** die go-/golangci-Literale
  (`go build`, `golangci-lint run`) leben **im Dockerfile-`RUN`** (`:40`/`:46`), getrieben vom
  **Makefile** via `docker build --target` — **nicht** in `d-check.mk` (unberührt). Kein
  Host-`go`/-`golangci-lint`. Die in ADR-0003 §Fitness Function als „*(folgt)*" markierten Gates
  `make lint` / `make build` sind mit diesem Slice **real angelegt und grün** — die Fitness
  Function ist damit komplett (neben `make test` aus slice-001a). Kein Verstoß.

## Reproduzierbarkeit / minimale Abhängigkeiten (LH-QA-02 / LH-QA-03)

- **LH-QA-02:** golangci-lint-Base **und** golang-Base per `@sha256:` digest-gepinnt und
  **byte-identisch** zu a-check (`5cceeef0…` bzw. `792443b8…`); Tool-Images
  (`BATS_IMAGE`/`SHELLCHECK_IMAGE`/d-check-Digest) unverändert. Digest autoritativ → zwei Läufe =
  identisches Image. (Fortführung slice-001a INFO-1: `GOLANGCI_LINT_VERSION`-Tag ↔ `@sha256`-Digest
  können still divergieren, **Digest gewinnt** — Repro bleibt gewahrt, nur das Label ist
  informativ; bewusster a-check-Spiegel, kein DoD-Bruch.)
- **LH-QA-03:** natives Go-Binary; der Tool-Build (`go build`/`go test`/`golangci-lint`) läuft im
  gepinnten Image, **kein Host-`go`/`golangci-lint`/`pip`/`npm`/`cargo`** (Guard erzwungen — bats
  24/25/27/33 grün). golangci-lint-clean (`0 issues.`), `gomodguard_v2` hält die Dependency-Fläche
  minimal (Vorwärts-Guard). Die neuen go-Stages tragen kein `--network none` (Impl-Review INFO-3) —
  konsistent mit a-check und dem Einmal-Pull-Muster; offline-grün per leerer Dependency-Fläche, kein
  aktueller Bruch (`make gates` Exit 0).

---

## Verdikt

- **DoD substanziell bestätigt: JA** — **4 CONFIRMED, 0 VIOLATED, 1 AUSSTEHEND** (DoD-5
  Closure-Notiz = erwarteter Planner-Schritt nach der Verifikation). Jede Behauptung mit
  ausgeführtem Beleg: `make build` cross-compiliert `cmd/ai-harness-init` in der digest-gepinnten
  `build`-Stage (Exit 0, laufendes Binary via `docker run … --help` Exit 0 / ohne `--lang` Exit 2),
  `make lint` grün (`0 issues.` frisch, kein `//nolint` in `cmd/`, zentrale `.golangci.yml`),
  `lint`/`build` in Makefile **und** `gates:` **und** beiden Doku-Tabellen — Promotion nach grünem
  Target, „Nicht behauptet" ehrlich auf das genuin fehlende arch-Gate a-check (`LH-FA-07`)
  verschoben —, `make gates` **Exit 0**.
- **Plan-vs-Code:** §3-Tabelle (4 Zeilen) vollständig gedeckt; `compile`-Target/-Stage ist eine
  begründete a-check-treue Beigabe (ausdrücklich NICHT in gates, kein halluziniertes Gate) und
  schließt Impl-Review-INFO-1; die Impl-Review-LOW-1 (`unused-receiver`-Test-Ausnahme) ist im
  aktuellen Stand ebenfalls nachgezogen. Kein problematischer Scope-Creep.
- **ADR-Konformität:** keine ADR berührt; ADR-0003 Docker-only gewahrt (go-/golangci-Literale im
  Dockerfile, Gates im Makefile, kein Host-`go`); die Fitness-Function-Gates `lint`/`build` sind
  jetzt real grün.
- **`make gates`:** **Exit 0**, netzlos grün (baseline-verify 42 Dateien · d-check 53 Dateien/0
  Befunde `--network none` · lint `0 issues.` frisch · build Exit 0 · bats 50/50 `--network none` +
  go-test frisch · shell-lint clean · record-gates).
- **Reif für `done/`:** **NOCH NICHT — zwei Buchführungs-Schritte offen:** (1) die DoD-Kästchen in
  §2 abhaken (Implementer), (2) §7 Closure-Notiz mit echtem Steering-Loop-Lerneintrag füllen
  (Planner). Die **Substanz** aller inhaltlichen DoD-Punkte (1-4) ist erfüllt; sobald Abhakung +
  Closure-Notiz stehen, ist der `git mv → done/` frei (der Verifier verschiebt nichts). Die
  Working-Tree-vs-Frisch-Klon-Nuance bleibt als MR-003-CI-Restlücke nach Commit offen, kein Blocker.
