# Review-Report: slice-001a Implementierung (CLI-Skeleton Go + go-test-Gate) — 2026-07-18

**Review-Art:** Code — unabhängiger Reviewer (kein Selbst-Review). Erster echter Go-Code des
Repos: Arg-Parser (`run(args, stdout, stderr) int`) mit den LH-FA-01-Fehlerpfaden, Go-Unit-Tests,
Dockerfile (`deps`+`test`-Stage, a-check gespiegelt) und die Erweiterung von `make test` um den
go-test-Pfad. Geprüft gegen Plan (slice-001a DoD + §6-Risiken), `LH-FA-01`/`LH-QA-01`/`LH-QA-02`/
`LH-QA-03`, Hard Rules `AGENTS.md` §3, `ADR-0003` (Docker-only Cross-Compile — Verstoß = HIGH).

**Gegenstand (uncommitteter Working-Tree-Diff):**
- **neu** `go.mod` (Modul `github.com/pt9912/ai-harness-init`, `go 1.26`),
- **neu** `cmd/ai-harness-init/main.go` (Arg-Parser + Usage + Exit-Codes, Bootstrap als Stub),
- **neu** `cmd/ai-harness-init/main_test.go` (LH-FA-01-AC als Go-Test: Exit-Code UND Stream),
- **neu** `Dockerfile` (`deps`+`test`-Stage, golang-Base digest-gepinnt),
- **neu** `.dockerignore` (`.git`, `.harness` aus dem Build-Kontext),
- **update** `Makefile` (`GO_VERSION`-build-arg + `test` um `docker build --target test` erweitert),
- **update** `AGENTS.md` §4 / `README.md` / `harness/README.md` (make-test-Beschreibung + „Nicht behauptet").

Der committete Eintritts-Move (`b445049`, slice-001a → `in-progress/`) ist **nicht** Review-Gegenstand.

**Skill:** `.harness/skills/reviewer.md` @ 1.1.0 · **Modell:** claude-opus-4-8[1m] (unabhängiger
Reviewer-Agent) · **Datum:** 2026-07-18

**Eingangs-Kontext (nach reviewer.md v1.1.0 — sechs Elemente):**
1. **Diff/Range:** `git diff` (Working Tree, 7 Dateien oben) + die neuen untracked Dateien.
2. **Betroffene LH:** [`LH-FA-01`](../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen)
   (Repo bootstrappen — Negative-/Boundary-AC des Arg-Parsers), [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
   (offline-grün / keine halluzinierten Gates), [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
   (Reproduzierbarkeit / Pin), [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)
   (minimale Abhängigkeiten — kein Host-`go`).
3. **Referenzierte ADRs:** `ADR-0003` (Go + native Binaries, Docker-only Cross-Compile — Accepted,
   **aktiv**; ein Verstoß ist HIGH), `ADR-0004` (Durchsetzungs-Emission, für die bats-Suite). Keine
   superseded ADR referenziert (`ADR-0002` ist superseded — korrekt **nicht** herangezogen).
4. **Hard Rules:** `AGENTS.md` §3.1 (halluzinierte Gates), §3.2 (Lint-Suppression — n/a, lint = 001b),
   §3.3 (git mv + Inhaltsänderung = zwei Commits), §3.5 (Gate-Lockerung nur per ADR).
5. **Vorherige Findings am gleichen Modul:** `docs/reviews/2026-07-18-slice-018-impl-review.md`
   (INFO-1: Test-Hermetik durch Code-Pfad statt `--network none`; „behauptet ≠ vorhanden"),
   `docs/reviews/2026-07-18-slice-017-impl-review.md` (Sensor-/Gate-Promotion-Ehrlichkeit).
6. **Slice-Plan:** `docs/plan/planning/in-progress/slice-001a-cli-skeleton.md` (Diff gegen Plan
   geprüft; DoD-Abhakung NICHT bewertet — Verifier-Rolle).

**Ausgeführte Verifikationsmittel (Belege, guard-sicher):**
- `make test` → **Exit 0**: bats-Suite läuft (`--network none` bleibt), dann `docker build
  --no-cache-filter test --target test`. Der go-test-Layer lief **frisch** (nicht CACHED:
  `#14 RUN CGO_ENABLED=0 go test ./... … ok github.com/pt9912/ai-harness-init/cmd/ai-harness-init
  0.002s DONE 3.4s`) — kein Stale-Green aus altem Layer.
- `make gates` → **Exit 0**: `baseline-verify` (`v3.1.0 OK — 42 Dateien`, netzlos) · `docs-check`
  (d-check, `--network none`) · `test` (bats **47 ok** + go-test-Build) · `shell-lint` ·
  `record-gates`. Alle grün.
- **Digest-Abgleich a-check** (`/Development/a-check/Dockerfile`): golang-Base
  `golang:1.26.4@sha256:792443b89f65105abba56b9bd5e97f680a80074ac62fc844a584212f8c8102c3` — **byte-identisch**
  gespiegelt; `ARG GO_VERSION=1.26.4` und `go 1.26` (go.mod) stimmen mit a-check überein.
- **Guard-Selbsttest** (bats, in `make gates`): `ok 24 guard: go build blockt`, `ok 25 guard:
  pip/npm/cargo/golangci-lint blocken`, `ok 27 … Subshell/Pipe`, `ok 33 bash -c "go build" blockt` —
  Host-`go` ist erzwungen blockiert, nicht nur Konvention.
- **§3.3-Beleg:** `git show --stat b445049` = reiner Rename (`{open => in-progress}`, 0-Zeilen-Delta)
  + 1-Zeilen-Link in `welle-01-offline-kern.md` (**anderes** File, tangiert Rename-Detection nicht);
  die Implementierung ist uncommitted → Move und Inhalt getrennt.
- **Dockerfile-Stages:** nur `deps` + `test` vorhanden — **kein** `compile`/`lint`/`build` (die sind
  slice-001b). Kein halluziniertes build/lint-Gate im Makefile (`grep` der `gates:`-Zeile:
  `baseline-verify docs-check test shell-lint record-gates`).

---

## Findings

### LOW-1 — Der Fehlerpfad (Exit 2) prüft die Usage nur *auf* stderr, nicht die *Abwesenheit* auf stdout

- **kategorie:** LOW
- **quelle:** Maintainability (Test-Vollständigkeit / Regressionsschutz der Stream-Disziplin, LH-FA-01)
- **pfad:** `cmd/ai-harness-init/main_test.go:35-48`
- **befund:** Die Stream-Disziplin ist nur einseitig verriegelt. Für Exit 0 wird geprüft, dass
  stderr leer bleibt (`wantCode == 0 && errb.Len() > 0` → Fehler, Zeile 43-45), für Exit 2, dass
  die Usage **auf** stderr landet (Zeile 46-48). Es fehlt die Gegenrichtung: kein Test behauptet,
  dass auf dem Fehlerpfad **stdout leer** bleibt (`wantOut` ist bei allen Exit-2-Fällen `""` =
  „egal", und es gibt keine generische „Exit 2 ⇒ stdout leer"-Assertion). Der Code ist heute
  korrekt (Fehlerpfade schreiben ausschließlich nach stderr, `main.go:43-52`) — die Lücke ist rein
  im Test.
- **failure-szenario:** Ein späterer Refactor legt die Usage bei einem Fehler zusätzlich auf stdout
  (z. B. `fmt.Fprint(stdout, usage)` im `err != nil`-Zweig). Ein den stdout kapernder Konsument
  (Pipe `2>/dev/null`) sähe dann die Usage im Nutzdatenstrom — alle sechs Testfälle blieben grün,
  die Stream-Regression unentdeckt.
- **verifizierbar:** ja — eine Assertion `if tt.wantCode == 2 && out.Len() > 0 { t.Errorf(...) }`
  würde den Fall abdecken; ihre Abwesenheit macht die Regression testblind.

### INFO-1 — `GO_VERSION`-Tag und `@sha256`-Digest können still divergieren (Digest gewinnt)

- **kategorie:** INFO
- **quelle:** `LH-QA-02` (Reproduzierbarkeit) / Maintainability (latente Wartungsfalle; bewusster
  a-check-Spiegel)
- **pfad:** `Dockerfile:10,13` (`ARG GO_VERSION=1.26.4` + `FROM golang:${GO_VERSION}@sha256:792443…`)
- **befund:** Docker löst `FROM golang:${GO_VERSION}@sha256:…` über den **Digest** auf; der
  Tag-Teil (`GO_VERSION`) ist für die Bild-Auswahl faktisch informativ. Ein Bump von `GO_VERSION`
  (Makefile/ARG) **ohne** neuen Digest baut still weiter das 1.26.4-Image, während der `--build-arg`
  eine andere Version annonciert. Die **Reproduzierbarkeit selbst bleibt gewahrt** (der Digest ist
  autoritativ → zwei Läufe = identisches Image, LH-QA-02 erfüllt); das Risiko ist ein irreführendes
  Versions-Label, kein Repro-Bruch. Der Konstrukt ist der **bewusste, byte-genaue a-check-Spiegel**
  (Plan §6, DoD) — der Befund gälte dort gleichermaßen.
- **failure-szenario:** Ein Maintainer setzt `GO_VERSION ?= 1.27.0` zum Go-Upgrade, vergisst den
  Digest → der Build läuft weiter auf 1.26.4, meldet aber „1.27.0"; ein Version-abhängiger Bug bleibt
  unreproduziert, weil die Toolchain faktisch die alte ist.
- **verifizierbar:** ja — `GO_VERSION=9.9.9 make test` baut trotzdem erfolgreich mit dem
  gepinnten 1.26.4-Layer (Digest gewinnt), obwohl der Tag nicht existiert.

### INFO-2 — go-test-Build ohne `--network none`; offline-grün per Test-Reinheit + Einmal-Pull, nicht erzwungen

- **kategorie:** INFO
- **quelle:** `LH-QA-01` (offline-grün) / Maintainability (dokumentationswürdige Annahme)
- **pfad:** `Makefile:42` (`docker build … --target test`); `Dockerfile:20,25`
- **befund:** Der bats-Teil von `make test` behält `--network none` (`Makefile:41`), der go-test-Teil
  ist ein `docker build` **ohne** Netz-Isolation: der Base-Pull (einmalig) und `go mod download`
  (`Dockerfile:20`, mit leerer go.mod ein No-op) sowie das `go test ./...` (`Dockerfile:25`, stdlib,
  `CGO_ENABLED=0`) laufen mit verfügbarem Netz. Die offline-grün-Zusage für den go-Pfad ruht damit
  auf (a) Test-Reinheit (keine Test greift ans Netz) und (b) dem Einmal-Pull-Muster, das für
  bats/shellcheck/d-check/golang identisch gilt — **nicht** auf einer erzwungenen Grenze. Das ist
  konsistent mit dem Schwester-Repo a-check (dessen `test`-Stage ebenfalls kein `--network none`
  trägt) und mit der Vorbefund-Klasse aus slice-018 (INFO-1). Kein aktueller Bruch: `make gates` lief
  hier grün, weil die Bases gecacht waren und die Tests netzlos sind.
- **failure-szenario:** Ein künftiger Test in `cmd/…` (oder ein späteres Paket) greift im
  `go test`-Lauf ans Netz; auf einem Checkout ohne diese Grenze wird `make gates` rot statt der
  impliziten offline-grün-Zusage — ohne dass eine Isolationsschicht das abfängt.
- **verifizierbar:** ja — `grep -n "network none" Makefile` zeigt das Flag nur auf dem bats-`run`,
  nicht auf dem go-test-`build`.

---

## Negativbefunde (geprüft, ohne blockierenden Befund)

- **Arg-Parser-Korrektheit (LH-FA-01, HIGH-Anker):** `run()` erfüllt die AC exakt. Fehlendes
  `--lang` → Exit 2 + Usage auf **stderr** (`main.go:48-53`); `--help`/`-h` → Exit 0 + Usage auf
  **stdout** (`main.go:37-40`; `flag.ErrHelp` greift für **beide**, da weder `h` noch `help`
  definiert ist → das flag-Paket liefert `ErrHelp`); unbekanntes Flag → Exit 2 + Usage auf stderr
  (`main.go:41-45`); `--name`/`--force` werden geparst (`main.go:33-34`); Stub-Pfad Exit 0 mit
  „noch nicht implementiert" (`main.go:56`). `flag.ContinueOnError` + `SetOutput(io.Discard)` kippt
  sauber: die flag-Eigenausgabe ist verworfen, alle Streams steuert `run()` selbst. Alle sechs
  Testfälle grün (Package `ok`).
- **Tests nicht vakuum:** `main_test.go` prüft je Fall Exit-Code **und** Stream-Inhalt (Substring
  auf dem richtigen Buffer) plus zwei generische Stream-Invarianten (Exit 0 ⇒ stderr leer; Exit 2 ⇒
  Usage auf stderr). Die AC sind real abgedeckt, nicht nur der Exit-Code. Die einzige Lücke
  (Exit 2 ⇒ stdout nicht geprüft) ist als LOW-1 notiert.
- **Dockerfile/Pin (LH-QA-02, HIGH-Anker bei ADR-Verstoß):** golang-Base per `@sha256:` digest-gepinnt
  und **byte-identisch** zu a-check; `GO_VERSION` als build-arg; `test`-Stage `CGO_ENABLED=0
  go test ./...` auf stdlib. Reproduzierbarkeit gewahrt (Digest autoritativ). Tag/Digest-Kopplung
  als INFO-1 notiert.
- **Go-Gate-Home + Guard-Sicherheit (ADR-0003, LH-QA-03):** Die go-Literale (`go build`/`go test`)
  leben **im Dockerfile** (`Dockerfile:20,25`), das Go-Gate im **Makefile** (`test:`-Target treibt
  `docker build --target test`), **nicht** in `d-check.mk` (unberührt). Kein Host-`go`; der
  PreToolUse-Guard blockt Host-Go erzwungen (bats 24/25/27/33 grün). ADR-0003 (Docker-only
  Cross-Compile) gewahrt — kein Verstoß.
- **`--no-cache-filter test` (Stale-Green-Schutz, HIGH-Anker):** Die `test`-Stage wird nie gecacht
  (`Makefile:42`, a-check-Muster) — der go-test lief hier frisch (`#14 … DONE 3.4s`, nicht CACHED).
  Rotes Gate kann nicht aus altem Layer grün melden. `deps` ist gecacht (korrekt: Deps ändern das
  Gate-Ergebnis nicht; COPY go.mod invalidiert bei Änderung).
- **Kein Stealth-Green in `make test`:** bats (Zeile 41) läuft vor dem go-Build (Zeile 42) als
  eigene Recipe-Zeile; ein rotes bats bricht `make` ab, bevor der go-Build läuft. Rotes go-test
  → `docker build` nonzero → `make` rot. Kein stiller Grün-Pfad.
- **Offline-grün (LH-QA-01):** `make gates` lief grün (Exit 0), netzlose Gates (`baseline-verify`,
  `docs-check --network none`, bats `--network none`) unberührt. Der go-test-Build nutzt kein
  `--network none` (Base-Pull) — konsistent mit dem etablierten Einmal-Pull-Muster (bats/shellcheck/
  d-check), kein neuer Netz-**Content**-Fetch pro Lauf. Als INFO-2 notiert (Isolation per Konvention,
  wie slice-018 INFO-1).
- **Doku-Ehrlichkeit (LH-QA-01 / §3.1):** AGENTS §4, README und harness/README spiegeln die Realität:
  `make test` = bats **+** go-Unit-Tests (verifiziert), `build`/`lint` bleiben ausdrücklich „**Nicht
  behauptet** (folgt mit slice-001b)". Das Dockerfile trägt **keine** `compile`/`lint`/`build`-Stage,
  die `gates:`-Zeile **kein** build/lint-Target — kein halluziniertes Gate. Die harness/README-Tabelle
  zitiert für den test-Row korrekt beide **aktiven** ADRs (0004 + 0003).
- **Hard Rule §3.3 (Eintritts-Move):** `b445049` ist reiner Rename (0-Zeilen-Delta) + Link-Update in
  anderem File; die Implementierung uncommitted → Move und Inhalt getrennt. Gewahrt.
- **Hard Rule §3.2 (Lint-Suppression):** n/a — lint (golangci-lint) ist slice-001b; kein `//nolint`
  im neuen Go-Code (`grep` clean).
- **`.dockerignore` / Build-Kontext:** schließt `.git` + `.harness` aus; `COPY . .` in der test-Stage
  zieht nur go.mod + cmd/ (+ inerte Root-Dateien) — `go test ./...` sieht nur die `.go`-Dateien.
  `COPY go.su[m]` ist der Optional-Glob (kein go.sum vorhanden, kein Fehler) — Build bestätigt.
- **Diff gegen Plan:** Alle fünf Plan-§3-Tabellenzeilen umgesetzt (main.go/main_test.go/go.mod/
  Dockerfile neu, Makefile-`test` um go-test + `GO_VERSION` erweitert, `d-check.mk` unberührt).
  Bewusst **nicht** in diesem Diff (Plan-Abgrenzung): `compile`/`lint`/`build`-Stages + deren
  Promotion (slice-001b). Konform.

---

## Kategorie-Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 0 |
| LOW | 1 |
| INFO | 2 |

---

## Verdikt

**Nicht merge-blockierend.** 0 HIGH, 0 MEDIUM. Der erste Go-Code des Repos ist sauber: der
Arg-Parser erfüllt die LH-FA-01-AC exakt (fehlendes `--lang` → Exit 2 + Usage/stderr; `--help`/`-h`
→ Exit 0 + Usage/stdout via `flag.ErrHelp` für beide Formen; unbekanntes Flag → Exit 2;
`--name`/`--force` geparst), die Tests prüfen Exit-Code **und** Stream (nicht vakuum), die
golang-Base ist digest-gepinnt und byte-identisch zu a-check gespiegelt (LH-QA-02), die go-Literale
leben im Dockerfile / das Gate im Makefile (ADR-0003, kein Host-`go`, Guard erzwingt es), die
`test`-Stage ist stale-green-fest (`--no-cache-filter test`, frisch gelaufen), und die Doku bleibt
ehrlich (build/lint ausdrücklich „nicht behauptet", kein halluziniertes Gate). `make test` und
`make gates` liefen bei mir **grün (Exit 0)** — bats 47 ok + go-test `ok …/cmd/ai-harness-init`,
plus baseline-verify (42 Dateien) · docs-check · shell-lint · record-gates. Die eine LOW (Fehlerpfad
prüft die Usage-Abwesenheit auf stdout nicht — einseitige Stream-Verriegelung) und die zwei INFO
(Tag/Digest-Divergenz still möglich, Digest bleibt autoritativ; go-test-Build ohne `--network none`,
offline-grün per Konvention wie slice-018 INFO-1) sind Test-Härtung bzw. dokumentationswürdige,
inherit-vom-a-check-Muster-Annahmen ohne aktuellen Gate-, Korrektheits- oder Reproduzierbarkeitsdefekt
— sie blockieren den Merge nicht. Empfehlung: LOW-1 beim Anfassen der Test-Datei (spätestens
slice-001b, wenn build/lint dazukommen) mit der stdout-Clean-Assertion nachziehen.
