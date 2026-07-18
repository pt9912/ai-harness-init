# Verifikation slice-001a — CLI-Skeleton (Go) + go-test-Gate

**Rolle:** Verifier (Modul 11, Verification Harness) — unabhängig, frischer Kontext,
NICHT Implementer, NICHT Reviewer.
**Datum:** 2026-07-18.
**Eingabe:** DoD + Spec + Plan (Modul 11) —
`docs/plan/planning/in-progress/slice-001a-cli-skeleton.md` §2 (DoD) / §3 (Plan-Tabelle) /
§1 (Ziel) / §6 (Risiken); `spec/lastenheft.md` `LH-FA-01` (Repo bootstrappen — Negative-/
Boundary-AC), `LH-QA-01` (keine halluzinierten Gates / offline-grün), `LH-QA-02`
(Reproduzierbarkeit / Pin), `LH-QA-03` (minimale Abhängigkeiten — kein Host-`go`); realer Stand
aus Working-Tree-Diff (4 tracked Sach-Dateien + 5 untracked, davon 1 Review-Artefakt) **plus**
dem committeten Eintritts-Move `b445049` (slice-001a → `in-progress/`).
**Frage:** „Hat das Gebaute umgesetzt, was Plan/DoD/Spec verlangt?" (nicht „ist es gut?" = Review).
**Mittel:** ausgeführte Gates/Docker/`git`/`grep` — jede Aussage mit Beleg. Kein Host-`go`
(Guard-Falle). Der Verifier committet/verschiebt nichts.

**Vorbemerkung zum Abhak-Zustand.** Die DoD-Kästchen in §2 stehen im Working Tree auf `[ ]`
(unabgehakt), §7 trägt den Platzhalter. Es liegt also **keine** positive Implementer-Behauptung
„`[x]`" vor — der Verifier prüft die **Substanz** jedes DoD-Punkts gegen den realen Stand. §2
listet **sechs** Kästchen; das letzte („Closure-Notiz") ist ein Planner-Schritt **nach** der
Verifikation (wie in der Aufgabe vorgegeben).

---

## DoD-Punkt für DoD-Punkt (§2)

### DoD-1 — LH-FA-01 Negative-AC: fehlendes `--lang` → Exit 2 + Usage auf **stderr** (Go-Unit-Test) — **CONFIRMED (ausgeführt)**
- **Test-Fall existiert und deckt die AC ab:** `main_test.go:20` —
  `{"fehlendes --lang -> Exit 2 + Usage stderr", []string{}, 2, "", "--lang ist erforderlich"}`.
  Der Fall prüft Exit-Code **2** UND den Substring auf **stderr** (`wantErr`), nicht nur den Code.
- **Doppelte Verriegelung greift für diesen Fall:** die generischen Invarianten decken zusätzlich
  ab, dass die **volle Usage** auf stderr landet (`wantCode==2 && !Contains(errb,"Verwendung:")` →
  `t.Errorf`, `main_test.go:46-48`) und dass **stdout leer** bleibt
  (`wantCode==2 && out.Len()>0` → `t.Errorf`, `main_test.go:51-53`). Die im Impl-Review als LOW-1
  notierte einseitige Lücke (Exit 2 ⇒ stdout ungeprüft) ist im vorliegenden Stand bereits
  **geschlossen** (`main_test.go:49-53`).
- **Code-Pfad:** `main.go:48-53` — `if *lang == "" { Fprintln(stderr,"Fehler: --lang ist
  erforderlich."); Fprint(stderr, usage); return 2 }`. Fehlermeldung + Usage ausschließlich nach
  stderr, Exit 2. Deckt die AC „Given fehlendes `--lang`, then Exit 2 + Usage" exakt.
- **Ausgeführt:** `make test` → **Exit 0**, der go-test-Layer lief **frisch** (nicht CACHED:
  `#13 [test 2/2] RUN CGO_ENABLED=0 go test ./... … 3.354 ok
  github.com/pt9912/ai-harness-init/cmd/ai-harness-init 0.002s … DONE 3.5s`). Kein Stale-Green.

### DoD-2 — LH-FA-01 Boundary: `--help`/`-h` → Exit 0 + Usage auf **stdout**; `--lang`/`--name`/`--force` geparst; unbekanntes Flag → Exit 2 + Usage — **CONFIRMED (ausgeführt)**
- **Test-Fälle existieren (alle 6, `main_test.go:20-25`):** `--help` → Exit 0 + stdout
  „Verwendung:"; `-h` → Exit 0 + stdout „Verwendung:"; `--lang go` → Exit 0 + stdout Stub „noch
  nicht implementiert"; `--lang go --name demo --force` → Exit 0 + stdout „--lang=go" (belegt, dass
  `--name`/`--force` **geparst** werden, kein Parse-Fehler); `--bogus` → Exit 2 + stderr „Fehler".
- **`run()`-Logik (`main.go:36-57`):** `flag.ErrHelp` → `Fprint(stdout, usage); return 0`
  (Zeile 37-40) — greift für **beide** `--help` und `-h`, da weder `h` noch `help` als Flag
  definiert ist, sodass das flag-Paket `ErrHelp` liefert; `err != nil` (unbekanntes Flag u. a.) →
  `Fprint(stderr, usage); return 2` (Zeile 41-45); `--name`/`--force` sind definiert
  (`main.go:33-34`, per `_ =` verworfen — im Skeleton bewusst, Wirkung folgt slice-002/003);
  Stub-Pfad Exit 0 (Zeile 56). `flag.ContinueOnError` + `SetOutput(io.Discard)` verwirft die
  flag-Eigenausgabe, alle Streams steuert `run()` selbst.
- **Ausgeführt:** dieselbe grüne `go test`-Ausführung wie DoD-1 (Package `ok`, alle Subtests grün).

### DoD-3 — `make test` deckt **beide**: Go-Unit-Tests (Dockerfile-`test`-Stage) UND bats — **CONFIRMED (ausgeführt)**
- **Makefile-`test`-Recipe (`Makefile:40-42`)** trägt **zwei** Zeilen:
  `docker run --rm --network none … $(BATS_IMAGE) test/` (bats) **und**
  `docker build --no-cache-filter test --build-arg GO_VERSION=$(GO_VERSION) --target test -t
  ai-harness-init:test .` (go-test via Dockerfile-`test`-Stage). Die `go test`-Literale leben im
  **Dockerfile** (`Dockerfile:25`), nicht im Bash-Command → guard-sicher.
- **Kein Stealth-Green:** bats läuft als **erste** Recipe-Zeile; ein rotes bats bricht `make` ab,
  bevor der go-Build startet. Ein rotes go-test → `docker build` nonzero → `make` rot. Beide Wege
  decken real ab.
- **Ausgeführt:** `make test` → **Exit 0**. bats: `1..50 … ok 50` (50/50, `--network none`); danach
  der go-test-Build frisch (`#13 … ok …/cmd/ai-harness-init`). Beide Suiten liefen im selben Lauf.

### DoD-4 — Go-Toolchain-Base **digest-gepinnt** (`GO_VERSION` build-arg, `@sha256:`); kein Host-`go` — **CONFIRMED (ausgeführt + unabhängig gegenbelegt)**
- **Digest-Pin real:** `Dockerfile:10` `ARG GO_VERSION=1.26.4`; `Dockerfile:13`
  `FROM golang:${GO_VERSION}@sha256:792443b89f65105abba56b9bd5e97f680a80074ac62fc844a584212f8c8102c3
  AS deps`. `Makefile:14` `GO_VERSION ?= 1.26.4`, durchgereicht via `--build-arg
  GO_VERSION=$(GO_VERSION)`. `go.mod` `go 1.26`.
- **Unabhängig gegenbelegt (a-check-Spiegel, Plan §6):** `grep golang /Development/a-check/Dockerfile`
  → `FROM golang:${GO_VERSION}@sha256:792443b89f65105abba56b9bd5e97f680a80074ac62fc844a584212f8c8102c3`
  — **byte-identisch** zum hiesigen Base-Digest. Der Pin ist der bewusste Schwester-Repo-Spiegel,
  nicht frei erfunden.
- **Pin funktioniert im Build:** der Build-Log zeigt die Auflösung über den Digest
  (`#4 [internal] load metadata for docker.io/library/golang:1.26.4@sha256:792443b8…` ·
  `#6 [deps 1/5] FROM …@sha256:792443b8…`) — reproduzierbar (LH-QA-02, zwei Läufe = derselbe Base).
- **Kein Host-`go`:** die go-Aufrufe (`go mod download` `Dockerfile:20`, `go test` `Dockerfile:25`)
  laufen **im Image**; der PreToolUse-Guard blockt Host-Go **erzwungen** — bats grün:
  `ok 24 guard: go build blockt`, `ok 25 guard: pip/npm/cargo/golangci-lint blocken`,
  `ok 27 guard: go in Subshell/Pipe/Command-Substitution blockt`, `ok 33 guard: bash -c "go build"
  blockt`. Docker-only, konform zu ADR-0003 / LH-QA-03.
- **Nuance (nicht DoD-widrig, = Impl-Review INFO-1):** Docker löst `FROM golang:${GO_VERSION}@sha256:…`
  über den **Digest** auf; ein `GO_VERSION`-Bump ohne neuen Digest baut still weiter 1.26.4. Die
  **Reproduzierbarkeit selbst bleibt gewahrt** (Digest autoritativ) — das Risiko ist nur ein
  irreführendes Versions-Label, kein Repro-Bruch, und der bewusste a-check-Spiegel. Kein VIOLATED.

### DoD-5 — `make gates` grün auf frischem Checkout (LH-QA-01-Smoke) — **CONFIRMED (ausgeführt)**
- `make gates` → **Exit 0**. Teilläufe alle grün:
  - `baseline-verify: v3.1.0 OK — 42 Dateien (Integritaet + Vollstaendigkeit, netzlos)`.
  - `docs-check` (d-check, `--network none`, Digest-Ref `sha256:9c317bf1…36a1`):
    `51 Datei(en) geprüft, 0 Befund(e)` — der neue go-Code + Dockerfile hat **keinen** toten
    Referenz-/Anchor-/Codepath-Befund erzeugt.
  - `test`: bats `1..50 … ok 50` (`--network none`) + go-test-Build frisch
    (`#13 … ok …/cmd/ai-harness-init 0.002s`).
  - `shell-lint` (shellcheck über `.claude/hooks/*.sh harness/tools/*.sh`): **ohne Befund**.
  - `record-gates`: Gate-Nachweis geschrieben (Stop-Hook-Deckung).
- **Nuance (wie slice-016/017/018):** Lauf auf dem Working Tree, nicht auf frischem Klon — der
  Frisch-Klon-Beweis bleibt die bekannte MR-003-CI-Restlücke nach Commit; kein Blocker.

### DoD-6 — Closure-Notiz mit Steering-Loop-Lerneintrag — **AUSSTEHEND (Planner-Schritt, kein VIOLATED)**
- `slice-001a-cli-skeleton.md` §7 (`:79-81`) trägt weiter den Platzhalter
  „`<!-- Erst nach Abschluss füllen. -->`". Die Closure-Notiz wird per Prozess **nach** der
  Verifikation in der Planner-Rolle geschrieben (wie in der Aufgabe vorgegeben) — daher **erwartet
  leer**, kein VIOLATED. Vor `git mv → done/` mit echtem Steering-Loop-Lerneintrag nachzutragen
  (Modul 5).

---

## Plan-vs-Code-Diff (Verifier-spezifisch)

**Plan-Tabelle §3 vollständig gedeckt (5 Zeilen):**
- `cmd/ai-harness-init/main.go` (neu): Arg-Parser + Usage + Exit-Codes, Bootstrap-Stub. ✓
- `cmd/ai-harness-init/main_test.go` (neu): LH-FA-01 Negative-/Boundary-AC als Go-Test (Exit-Code
  **und** Stream, 6 Fälle + generische Invarianten). ✓
- `go.mod` (neu): Modul `github.com/pt9912/ai-harness-init`, `go 1.26` (Version fixiert). ✓
- `Dockerfile` (neu): Multi-Stage `deps` + `test`, Base digest-gepinnt (a-check-Muster). **Kein**
  `compile`/`lint`/`build` (Plan-Abgrenzung: slice-001b) — im Dockerfile bestätigt (nur `deps`/`test`). ✓
- `Makefile` (update): `GO_VERSION`-build-arg (`:14`) + `test` um `docker build --target test`
  erweitert (`:42`); `d-check.mk` **unberührt** (Go-Gate lebt im Makefile). ✓

**Scope-Prüfung — `.dockerignore` (untracked, NICHT in der Plan-§3-Tabelle):** minimale ungeplante
Beigabe, aber **technisch begründet und dem geplanten Dockerfile dienend** — schließt `.git`
(History) und `.harness` (vendored Baseline, ~240 KB) aus dem Build-Kontext aus, den die
`COPY . .` der `test`-Stage sonst mitzöge. Keine Feature-/Verhaltens-Ausweitung, sondern Hygiene
des geplanten Builds. Der Build-Log bestätigt die Wirkung (`#5 load .dockerignore … transferring
context: 249B`). **Kein problematischer Scope-Creep.**

**Doku-Updates (tracked, plan-konsistent):** `AGENTS.md` §4 / `README.md` / `harness/README.md`
spiegeln die Realität — `make test` = bats **+** Go-Unit-Tests (verifiziert); `build`/`lint`
bleiben ausdrücklich „**Nicht behauptet** (folgt mit slice-001b)". Die harness/README-Tabelle
zitiert für den `test`-Row beide **aktiven** ADRs (0004 + 0003). Kein halluziniertes Gate: die
`gates:`-Zeile (`Makefile:102`) = `baseline-verify docs-check test shell-lint record-gates` —
**kein** build/lint-Target; das Dockerfile trägt **keine** build/lint-Stage (LH-QA-01 / §3.1).

**Realer Änderungs-Umfang:** tracked-modified = `AGENTS.md`, `Makefile`, `README.md`,
`harness/README.md`; untracked = `.dockerignore`, `Dockerfile`, `cmd/` (main.go + main_test.go),
`go.mod`, `docs/reviews/2026-07-18-slice-001a-impl-review.md` (Modul-10-Review-Artefakt);
committet = `b445049` (Eintritts-Move). **Alles innerhalb §3** (plus die begründete
`.dockerignore` und das Review-Artefakt). Bewusst **ausgelagert** (Plan-Abgrenzung §Ziel/§6):
`compile`/`lint`/`build`-Stages + deren Gate-Promotion = slice-001b.

## ADR-Konformität

- **Keine ADR berührt:** `git diff --name-only` = `AGENTS.md`, `Makefile`, `README.md`,
  `harness/README.md`; untracked trifft kein `docs/plan/adr/000*.md`. Keine Accepted-ADR verändert;
  der `matrix`-Sensor lief im `make gates`-Lauf ohne Befund.
- **ADR-0003 (Go + Docker-only Build) gewahrt:** die go-Literale (`go mod download`/`go test`)
  leben **im Dockerfile** (`:20`/`:25`), das Go-`test`-Gate im **Makefile** (`test:` treibt
  `docker build --target test`), **nicht** in `d-check.mk` (unberührt). Kein Host-`go`; der Guard
  erzwingt es (bats 24/25/27/33 grün). Die in ADR-0003 §Fitness Function als „(folgt)" markierten
  Gates `lint`/`build` sind **noch nicht** behauptet (korrekt slice-001b). Kein Verstoß.

## Reproduzierbarkeit / minimale Abhängigkeiten (LH-QA-02 / LH-QA-03)

- **LH-QA-02:** golang-Base per `@sha256:` digest-gepinnt und byte-identisch zu a-check;
  Tool-Images (`BATS_IMAGE`/`SHELLCHECK_IMAGE`/d-check-Digest) unverändert; `go.mod` `go 1.26`
  fixiert. Digest autoritativ → zwei Läufe = identisches Image.
- **LH-QA-03:** natives Go-Binary geplant; der Tool-**Build** (go test) läuft im gepinnten Image,
  **kein Host-`go`/`pip`/`npm`/`cargo`** (Guard erzwungen). Die Gates bleiben Docker-only, `test`
  (bats-Teil) und `docs-check` zusätzlich `--network none`. Der go-test-`docker build` trägt kein
  `--network none` — konsistent mit dem etablierten Einmal-Pull-Muster (bats/shellcheck/d-check) und
  a-check (Impl-Review INFO-2); offline-grün per Test-Reinheit, kein neuer Content-Fetch pro Lauf.
  Kein aktueller Bruch (`make gates` Exit 0).

---

## Verdikt

- **DoD substanziell bestätigt: JA** — **5 CONFIRMED, 0 VIOLATED, 1 AUSSTEHEND** (DoD-6
  Closure-Notiz = erwarteter Planner-Schritt nach der Verifikation). Jede Behauptung mit
  ausgeführtem Beleg: Negative-AC (fehlendes `--lang` → Exit 2 + Usage/stderr, Test + Code +
  grüner `go test`), Boundary-AC (`--help`/`-h` → Exit 0 + Usage/stdout via `flag.ErrHelp`;
  `--name`/`--force` geparst; unbekanntes Flag → Exit 2 — alle 6 Test-Fälle grün), `make test`
  deckt bats **und** go-test (Exit 0, go-Layer frisch), Base digest-gepinnt (`@sha256:792443b8…`,
  byte-identisch zu a-check gegenbelegt, kein Host-`go` — Guard 24/25/27/33 grün), `make gates`
  **Exit 0**.
- **Plan-vs-Code:** §3-Tabelle vollständig gedeckt; `.dockerignore` ist eine begründete, dem
  geplanten Dockerfile dienende Hygiene-Beigabe (kein problematischer Scope-Creep); `compile`/`lint`/
  `build` bleiben bewusst slice-001b.
- **ADR-Konformität:** keine ADR berührt; ADR-0003 Docker-only gewahrt (go-Literale im Dockerfile,
  Gate im Makefile, kein Host-`go`).
- **`make gates`:** **Exit 0**, netzlos grün (baseline-verify 42 Dateien · d-check 51 Dateien/0
  Befunde `--network none` · bats 50/50 `--network none` · go-test frisch · shell-lint clean ·
  record-gates).
- **Reif für `done/`:** **NOCH NICHT — zwei Buchführungs-Schritte offen:** (1) die DoD-Kästchen in
  §2 abhaken (Implementer), (2) §7 Closure-Notiz mit echtem Steering-Loop-Lerneintrag füllen
  (Planner). Die **Substanz** aller inhaltlichen DoD-Punkte (1-5) ist erfüllt; sobald Abhakung +
  Closure-Notiz stehen, ist der `git mv → done/` frei (der Verifier verschiebt nichts). Die
  Working-Tree-vs-Frisch-Klon-Nuance bleibt als MR-003-CI-Restlücke nach Commit offen, kein Blocker.
