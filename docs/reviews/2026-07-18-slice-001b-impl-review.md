# Review-Report: slice-001b Implementierung (Go-Gates build/lint + Promotion) — 2026-07-18

**Review-Art:** Code — unabhängiger Reviewer (kein Selbst-Review). Zweite Hälfte des re-slicten
slice-001: die verbleibenden Go-Gates `build` (Cross-Compile) und `lint` (golangci-lint) als
Dockerfile-Stages (a-check-Muster, `docker build --target`), ins `gates`-Target aufgenommen und in
AGENTS.md §4 / harness/README.md §Sensors aus „Nicht behauptet" **promotet**. Geprüft gegen Plan
(slice-001b DoD + §6-Risiken), `LH-QA-01`/`LH-QA-02`/`LH-QA-03` (+ `LH-FA-07` für die „Nicht
behauptet"-Zeile), Hard Rules `AGENTS.md` §3, `ADR-0003` (Docker-only — Verstoß = HIGH).

**Gegenstand (uncommitteter Working-Tree-Diff):**
- **neu** `.golangci.yml` (Lint-Profil, a-check gespiegelt + adaptiert; zentrale Suppressions),
- **update** `Dockerfile` (`compile`/`lint`/`build`-Stages ergänzt; `GOLANGCI_LINT_VERSION`-ARG +
  golangci-lint-Base digest-gepinnt),
- **update** `Makefile` (`GOLANGCI_LINT_VERSION`, `lint`/`build`-Targets, beide in `.PHONY` und in
  `gates:`),
- **update** `AGENTS.md` §4 / `README.md` / `harness/README.md` (Promotion `build`/`lint`; „Nicht
  behauptet" auf das arch-Gate a-check / `LH-FA-07` umgestellt).

Der committete Eintritts-Move (`f8e8672`, slice-001b → `in-progress/`) ist **nicht** Review-Gegenstand.

**Skill:** `.harness/skills/reviewer.md` @ 1.1.0 · **Modell:** claude-opus-4-8[1m] (unabhängiger
Reviewer-Agent) · **Datum:** 2026-07-18

**Eingangs-Kontext (nach reviewer.md v1.1.0 — sechs Elemente):**
1. **Diff/Range:** `git diff` (Working Tree: AGENTS.md, Dockerfile, Makefile, README.md,
   harness/README.md) + die neue untracked Datei `.golangci.yml`.
2. **Betroffene LH:** [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
   (keine halluzinierten Gates / Promotion erst nach grünem Target),
   [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (Reproduzierbarkeit / Pin),
   [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (minimale Abhängigkeiten /
   golangci-clean, kein Host-`go`); für die „Nicht behauptet"-Zeile
   [`LH-FA-07`](../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren) (arch-Gate,
   bewusst aufgeschoben).
3. **Referenzierte ADRs:** `ADR-0003` (Go + native Binaries, Docker-only Cross-Compile — Accepted,
   **aktiv**; Verstoß = HIGH). Keine superseded ADR herangezogen (`ADR-0002` superseded — korrekt
   **nicht** referenziert).
4. **Hard Rules:** `AGENTS.md` §3.1 (halluzinierte Gates), §3.2 (Lint-Suppression: kein `//nolint`;
   zentrale Ausnahmen mit Begründung), §3.3 (Eintritts-Move separater Commit), §3.5 (Gate-Lockerung
   nur per ADR).
5. **Vorherige Findings am gleichen Modul:** `docs/reviews/2026-07-18-slice-001a-impl-review.md`
   (INFO-1: `GO_VERSION`-Tag ↔ `@sha256`-Digest können still divergieren, Digest gewinnt; INFO-2:
   go-Stage ohne `--network none`, offline-grün per Konvention; LOW-1: Stream-Disziplin einseitig
   verriegelt).
6. **Slice-Plan:** `docs/plan/planning/in-progress/slice-001b-go-gates.md` (Diff gegen Plan geprüft;
   DoD-Abhakung NICHT bewertet — Verifier-Rolle).

**Ausgeführte Verifikationsmittel (Belege, guard-sicher):**
- `make lint` → **Exit 0**: die `lint`-Stage lief **frisch** (`--no-cache-filter lint`, nicht CACHED):
  `#17 [lint 5/5] RUN golangci-lint run ./...` → `#17 5.775 0 issues.` — kein Stale-Green.
- `make build` → **Exit 0**: `#13 [build 2/2] RUN CGO_ENABLED=0 go build -trimpath -ldflags="-s -w"
  -o /out/ai-harness-init ./cmd/ai-harness-init` (content-adressiert CACHED; der `COPY . .`-Cache-Key
  bindet den vollen Quellstand → das aktuelle `cmd/` kompiliert). Das gebaute Binary läuft:
  `docker run --rm --network none ai-harness-init:build /out/ai-harness-init --help` → Usage; ohne
  `--lang` → `Fehler: --lang ist erforderlich.` — funktionierendes Executable.
- `make gates` → **Exit 0**: Reihenfolge `baseline-verify → docs-check → lint → build → test →
  shell-lint → record-gates`. `lint` frisch (`#17 4.797 0 issues.`), `test`-Stage frisch
  (`#13 3.513 ok  github.com/pt9912/ai-harness-init/cmd/ai-harness-init 0.002s`), bats **50 ok /
  0 not-ok**, `baseline-verify: v3.1.0 OK — 42 Dateien` (netzlos).
- **Digest-/Byte-Abgleich a-check** (`/Development/a-check/Dockerfile`, `/Development/a-check/.golangci.yml`):
  golangci-lint-Base `golangci/golangci-lint:v2.12.2@sha256:5cceeef04e53efe1470638d4b4b4f5ceefd574955ab3941b2d9a68a8c9ad5240`
  — **byte-identisch** gespiegelt; die **gesamte `lint`-Stage** (WORKDIR/ENV/COPY --from=deps/COPY/RUN)
  ist byte-identisch; die `build`-Stage differiert nur im Binary-Namen (`ai-harness-init` statt
  `a-check`). `GOLANGCI_LINT_VERSION=v2.12.2` = a-check.
- **§3.2-Beleg:** `grep -rn nolint cmd/` → **kein Treffer** (Exit 1). Alle `.golangci.yml`-`exclusions`
  tragen einen `Why:`-Kommentar.
- **Promotion-Ehrlichkeit:** `.a-check.yml` und `a-check.mk` existieren im Repo **nicht** (`ls` →
  „nicht gefunden") — das arch-Gate ist genuin aufgeschoben, die verschobene „Nicht behauptet"-Zeile
  ist ehrlich.
- **§3.3-Beleg:** `git show --stat f8e8672` = reiner Rename (`{open => in-progress}`, 0-Zeilen-Delta)
  + 1-Zeilen-Link in `welle-01-offline-kern.md` (**anderes** File); die Implementierung ist uncommitted
  → Move und Inhalt getrennt.

---

## Findings

### LOW-1 — a-checks `unused-receiver`-Test-Ausnahme wurde nicht mitgespiegelt (latente Lint-Rot-Falle)

- **kategorie:** LOW
- **quelle:** Maintainability (a-check-Spiegel-Treue; latente Wartungsfalle) / `LH-QA-03`
- **pfad:** `.golangci.yml:156-159` (nur `unused-parameter`-Ausnahme für `_test.go`)
- **befund:** Die Config aktiviert `revive`-Regel `unused-receiver` (Zeile 117) und schließt für
  `_test.go` nur `revive/^unused-parameter` aus (Zeile 156-159). a-checks Vorbild
  (`/Development/a-check/.golangci.yml:167-170`) trägt **zusätzlich** eine
  `revive/^unused-receiver`-Ausnahme für `_test.go`. Anders als die bewusst entfernten
  a-check-**spezifischen** Einträge (ireturn-Port-Pfad, yaml.v2-gomodguard — genuin irrelevant) ist
  `unused-receiver` ein **generisches** Go-Test-Muster ohne a-check-Bezug; seine Auslassung ist eine
  inkonsistente Abweichung von der im Datei-Header behaupteten „a-check gespiegelt"-Treue. Aktuell
  ohne Wirkung: `main_test.go` trägt keine Methode mit Receiver → `make lint` grün (verifiziert).
- **failure-szenario:** Ein späterer Slice führt in einem `_test.go` einen Fake/Mock mit
  Receiver-Methode ein, die den Receiver nicht nutzt (`func (f fakeX) M() {…}`) — ein legitimes
  Test-Muster. `make lint` wird hier **rot** (revive `unused-receiver`), während derselbe Test in
  a-check grün bliebe; der Implementer trifft die Suppression-Falle (§3.2 verbietet inline `//nolint`)
  und muss die Ausnahme dann erst nachziehen.
- **verifizierbar:** ja — ein `_test.go` mit ungenutztem Receiver lässt `make lint` fehlschlagen;
  `diff <(grep -A3 unused-receiver /Development/a-check/.golangci.yml) .golangci.yml` zeigt die
  fehlende Test-Ausnahme.

### INFO-1 — `compile`-Stage im Dockerfile ohne treibendes make-Target (undokumentierte Dev-Bequemlichkeit)

- **kategorie:** INFO
- **quelle:** Maintainability (bewusste, aber undokumentierte Design-Notiz)
- **pfad:** `Dockerfile:28-32` (`FROM deps AS compile … RUN CGO_ENABLED=0 go build -o /tmp/…`)
- **befund:** Der Diff ergänzt neben `lint`/`build` eine `compile`-Stage („Schnelles Compile-Feedback
  ohne Tests/Lint"). Kein `make`-Target treibt sie (`grep "target compile\|compile:" Makefile` →
  kein Treffer), keine Doku nennt sie — anders als a-check, das ein `make compile` besitzt. Die
  Stage wird von keinem Gate gebaut; sie kann jedoch nicht unabhängig brechen (sie ist eine echte
  Teilmenge dessen, was `build`/`test` auf demselben Quellstand ohnehin kompilieren), ist also
  harmlose Redundanz — kein halluziniertes Gate (nirgends als Gate behauptet), kein `LH-QA-01`-Bruch.
- **failure-szenario:** Ein Maintainer erwartet nach dem a-check-Muster `make compile` als schnelles
  Feedback-Target und findet es nicht; die Stage bleibt toter Ballast, der bei einem künftigen
  Dockerfile-Refactor unbemerkt verrottet, weil kein Gate ihn baut.
- **verifizierbar:** ja — `grep -c "target compile" Makefile` → 0, während `Dockerfile` die Stage trägt.

### INFO-2 — Version-Tag ↔ `@sha256`-Digest können still divergieren (gilt jetzt auch für `GOLANGCI_LINT_VERSION`)

- **kategorie:** INFO
- **quelle:** `LH-QA-02` (Reproduzierbarkeit) / Maintainability (Fortführung slice-001a INFO-1)
- **pfad:** `Dockerfile:10-11,35` (`ARG GOLANGCI_LINT_VERSION=v2.12.2` + `FROM golangci/golangci-lint:${GOLANGCI_LINT_VERSION}@sha256:5cceeef…`)
- **befund:** Wie bei `GO_VERSION` (slice-001a INFO-1) löst Docker `FROM …:${GOLANGCI_LINT_VERSION}@sha256:…`
  über den **Digest** auf; der Tag-Teil ist faktisch informativ. Ein Bump des `GOLANGCI_LINT_VERSION`
  ohne neuen Digest lintet still weiter mit v2.12.2. **Reproduzierbarkeit bleibt gewahrt** (Digest
  autoritativ → identisches Image je Lauf, `LH-QA-02` erfüllt); das Risiko ist ein irreführendes
  Versions-Label, kein Repro-Bruch — und es ist der **bewusste, byte-genaue a-check-Spiegel**.
- **failure-szenario:** Ein Maintainer setzt `GOLANGCI_LINT_VERSION ?= v2.13.0` zum Linter-Upgrade,
  vergisst den Digest → der Lint läuft weiter mit v2.12.2, meldet aber „v2.13.0"; eine neue Regel des
  Upgrades greift nicht, obwohl das Label sie annonciert.
- **verifizierbar:** ja — `GOLANGCI_LINT_VERSION=9.9.9 make lint` lintet trotzdem grün mit dem
  gepinnten v2.12.2-Layer (Digest gewinnt), obwohl der Tag nicht existiert.

### INFO-3 — Go-Stages (`lint`/`build`/`test`) ohne `--network none`; offline-grün per Konvention, nicht erzwungen

- **kategorie:** INFO
- **quelle:** `LH-QA-01` (offline-grün) / Maintainability (Fortführung slice-001a INFO-2 / slice-018 INFO-1)
- **pfad:** `Makefile:46,49` (`docker build … --target lint`/`--target build`); `Dockerfile:35-40,44-46`
- **befund:** `baseline-verify`/`docs-check`/bats behalten ihre Netz-Isolation; die neuen go-Stages
  (`lint`, `build`, wie schon `test`) sind `docker build` **ohne** `--network none`. Base-Pull
  (einmalig) und `go mod download` (No-op bei leerer go.mod) laufen mit verfügbarem Netz. Die
  offline-grün-Zusage für den go-Pfad ruht damit auf (a) leerer Dependency-Fläche und (b) dem
  Einmal-Pull-Muster (identisch für bats/shellcheck/d-check/golang) — **nicht** auf einer erzwungenen
  Grenze. Konsistent mit a-check (dessen `lint`/`build`-Stages ebenfalls kein `--network none` tragen)
  und der Vorbefund-Klasse. Kein aktueller Bruch: `make gates` lief hier grün (Bases gecacht, keine
  Netz-Content-Fetches).
- **failure-szenario:** Ein späteres Go-Paket zieht eine externe Dependency (`go mod download` würde
  dann netzen) oder ein golangci-lint-Plugin lädt zur Laufzeit — auf einem Checkout ohne diese Grenze
  wird `make gates` netz-abhängig, ohne dass eine Isolationsschicht es abfängt.
- **verifizierbar:** ja — `grep -n "network none" Makefile` zeigt das Flag nur auf den bats-/d-check-/
  baseline-`run`s, nicht auf den go-`build`-Stages.

---

## Negativbefunde (geprüft, ohne blockierenden Befund)

- **Promotion-Reihenfolge / halluziniertes Gate (LH-QA-01, §3.1 — HIGH-Anker):** `make lint` und
  `make build` laufen **real grün** (verifiziert: lint `0 issues.` frisch, build Exit 0, gates Exit 0)
  — die Promotion in AGENTS §4 / README / harness/README erfolgt gegen **existierende, grüne**
  Targets, nicht davor. Beide sind in `gates:` (`baseline-verify docs-check lint build test shell-lint
  record-gates`) **und** in AGENTS §4 + harness/README §Sensors gelistet. Die verschobene „Nicht
  behauptet"-Zeile zeigt jetzt auf das arch-Gate a-check (`LH-FA-07`), das im Repo genuin fehlt
  (`.a-check.yml`/`a-check.mk` nicht vorhanden) — ehrlich, kein halluziniertes Gate.
- **Lint-Suppression-Verbot (§3.2 — HIGH-Anker):** Kein `//nolint` im Go-Code (`grep -rn nolint cmd/`
  → Exit 1). Alle `.golangci.yml`-`exclusions` sind zentral und tragen `Why:`-Kommentare. Die
  `testpackage`-`cmd/`-Ausnahme ist legitim: `main_test.go` ist `package main` (White-Box, testet das
  unexportierte `run()`); `testpackage` verlangt ein separates `_test`-Paket, das die paket-internen
  Fehlerpfade nicht erreicht — die Ausnahme verdeckt kein Problem. Die `errcheck`-Ausnahme
  (`fmt.Fprintln`/`Fprintf`/`Fprint`) ist sachlich: `main.go` schreibt Usage/Fehler über injizierte
  `io.Writer` und ignoriert deren Rückgabe-Fehler bewusst (CLI-Ausgabe).
- **Config-Substanz (nicht Deko):** golangci-lint läuft mit `default: none` **plus** einem realen Satz
  (5 Default- + 23 SOLID-nahe Linter, `revive` mit explizitem Regelblock); die Config ist valide
  (`make lint` bricht sonst mit Config-Fehler ab — sie lief grün mit `0 issues.`). a-check-treu
  adaptiert: `ireturn`-Port-Pfad und `yaml.v2`-gomodguard entfernt (genuin irrelevant, kein
  hexagonaler Port / keine yaml-Dep); `gomodguard_v2`-Vorwärts-Guard, `forbidigo`, `funlen`,
  `cyclop`-Schwellen wie a-check. `gomodguard_v2` (korrekter v2-Linter-Name) konsistent verwendet.
- **`forbidigo` vs. `fmt.Fprint*` (kein Falsch-Positiv):** Das Verbot `^fmt\.Print.*$` trifft
  `fmt.Print/Printf/Println` (direktes Stdout), **nicht** die `fmt.Fprint*`-Aufrufe in `main.go` (das
  `F` nach `fmt.` bricht das Anker-Match) — konsistent mit dem injizierten-Writer-Muster; Lint grün.
- **Dockerfile/Pin (LH-QA-02, ADR-0003 — HIGH-Anker bei Verstoß):** golangci-lint-Base per `@sha256:`
  digest-gepinnt und **byte-identisch** zu a-check; die gesamte `lint`-Stage byte-identisch gespiegelt.
  `build`-Stage cross-compiliert `CGO_ENABLED=0 … -trimpath -ldflags="-s -w"` (statisch, a-check-Muster;
  differiert nur im Binary-Namen). Alle go-/golangci-Aufrufe leben im **Dockerfile-`RUN`**, getrieben
  vom Makefile via `docker build --target` — kein Host-`go`/-`golangci-lint`.
- **Makefile (Stale-Green / gates):** `lint` nutzt `--no-cache-filter lint` (RUN lief frisch,
  `0 issues.` mit Timing, nicht CACHED) → kein stiller Grün-Pfad aus altem Layer. `build` trägt
  bewusst **kein** `--no-cache-filter` (wie a-check) — unbedenklich, da der `COPY . .`-Cache-Key den
  vollen Quellstand bindet: identischer Inhalt = geprüft grün, jede Quelländerung invalidiert →
  Neu-Kompilat. Beide Targets in `.PHONY` (Zeile 36) und in `gates:` (Zeile 109). `make gates`
  → Exit 0.
- **Hard Rule §3.3 (Eintritts-Move):** `f8e8672` ist reiner Rename (0-Zeilen-Delta am Slice-File) +
  1-Zeilen-Link in `welle-01-offline-kern.md` (anderes File); die Implementierung uncommitted → Move
  und Inhalt getrennt. Gewahrt.
- **Diff gegen Plan (§3):** Alle vier Plan-Tabellenzeilen umgesetzt — `.golangci.yml` neu (zentrale
  Suppressions), `Dockerfile` um `compile`/`lint`/`build` ergänzt, `Makefile` `build`/`lint` +
  `GOLANGCI_LINT_VERSION` + beide in `gates`, AGENTS §4 / harness/README §Sensors promotet. §6-Risiken
  adressiert: golangci per build-arg v2.12.2 + Base-Digest (LH-QA-02); golangci-Aufruf im Dockerfile
  (Guard greift nicht); `lint` (golangci) ≠ `shell-lint` (shellcheck), getrennte Targets; Go-Gates im
  Makefile, `d-check.mk` unberührt.

---

## Kategorie-Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 0 |
| LOW | 1 |
| INFO | 3 |

---

## Verdikt

**Nicht merge-blockierend.** 0 HIGH, 0 MEDIUM. Der Go-Gate-Stack ist sauber vervollständigt: die
`lint`-Stage ist **byte-identisch** zu a-check gespiegelt (golangci-lint-Base digest-gepinnt,
v2.12.2), die `.golangci.yml` läuft mit einem substanziellen Regel-Satz (`0 issues.`, frisch via
`--no-cache-filter lint` — kein Stale-Green), die Suppressions sind zentral und begründet (kein
`//nolint` im Code, `testpackage`-`cmd/`- und `errcheck`-`Fprint*`-Ausnahmen sachlich), die
`build`-Stage cross-compiliert statisch im gepinnten Image (kein Host-`go`, ADR-0003 gewahrt), beide
Targets stehen in `gates:` und `.PHONY`, und die Doku-Promotion ist **ehrlich**: `lint`/`build`
laufen real grün, während die verschobene „Nicht behauptet"-Zeile korrekt auf das genuin fehlende
arch-Gate a-check (`LH-FA-07`) zeigt. `make lint`, `make build` und `make gates` liefen bei mir
**grün (Exit 0)** — lint `0 issues.` (frisch), build Exit 0 + laufendes Binary, gates in der
Reihenfolge `baseline-verify → docs-check → lint → build → test → shell-lint → record-gates` (bats
50 ok, test-Stage frisch `ok …/cmd/ai-harness-init`, baseline v3.1.0 OK — 42 Dateien). Die eine LOW
(a-checks generische `unused-receiver`-Test-Ausnahme nicht mitgespiegelt — latente Lint-Rot-Falle,
sobald ein künftiges `_test.go` einen ungenutzten Receiver trägt) und die drei INFO (unbenutzte
`compile`-Stage ohne Target; Tag↔Digest-Divergenz nun auch für `GOLANGCI_LINT_VERSION`, Digest
autoritativ; go-Stages ohne `--network none`, offline-grün per Konvention — beide Fortführungen der
slice-001a-Vorbefunde) sind Spiegel-Treue-Härtung bzw. dokumentationswürdige, aus dem a-check-Muster
geerbte Annahmen ohne aktuellen Gate-, Korrektheits- oder Reproduzierbarkeitsdefekt — sie blockieren
den Merge nicht. Empfehlung: LOW-1 beim nächsten Anfassen der `.golangci.yml` (spätestens wenn ein
Slice Test-Fakes mit Receivern einführt) mit der `unused-receiver`-Test-Ausnahme nachziehen.
