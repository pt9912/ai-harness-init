# Slice slice-go-und-golangci-pin-ziehen-auf-127-1-und-v2140: Go-Toolchain auf 1.27.1 und golangci-lint auf v2.14.0

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle. Nach dem Test aus Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit
eine Welle braucht beobachtet keine Closure-Bedingung mehr als diese DoD.

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (gepinnte, digest-feste Toolchain),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (die Freshness-Sensoren melden den Drift),
[`MR-048`](../../../../harness/conventions.md#mr-048) (Reproduzierbarkeits-Anker: Rezept-Form, Skelette pinnen per Tag).

**Berührte Spec-Stellen:** —

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-10-05.

---

## 1. Ziel und Abgrenzung

**Ziel:** `make freshness-go` und `make freshness-golangci` melden `aktuell`: Die Pins stehen auf Go
`1.27.1` und golangci-lint `v2.14.0`, an jeder Stelle, die sie trägt, mit belegten Manifest-Digests.

**Anlass:** das nächtliche `upstream-drift` (Lauf `37272629154`) ist rot. Im selben Lauf meldet auch
`baseline-freshness` (v6.14.0) rot — das ist hier ausgeschlossen (unten).

**Warum kein ADR/MR:** ein Pin-Anheben auf den Nachfolger derselben Linie senkt keine Schwelle
([`AGENTS.md`](../../../../AGENTS.md) §3.5) und setzt keine Abweichung von der Baseline; der letzte Sprung
(`cf3b5b81`) lief ohne beides.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Kein Baseline-Sprung auf `v6.14.0`.** *Anderer Vorgang:* Re-Baseline mit Vendoring und fünf Pins
  ([`MR-007`](../../../../harness/conventions.md#mr-007)), eigener Slice-Schnitt; der Lauf wird erst nach
  ihm vollständig grün.
- **Kein d-check-Sprung.** *Bestand bleibt bewusst stehen:* `make freshness-dcheck` steht im Lauf `37272629154`
  auf grün (`✓ Run make freshness-dcheck`), es gibt keinen Drift zu beheben; `freshness-cpp` ebenso.
- **Kein Funktionsinhalt.** *Schicht-Abgrenzung:* nur Pin-Werte und die an sie gekoppelten Fallbacks.
  `go.mod` (`go 1.27`) bleibt, ein Patch-Sprung ändert die Minor nicht.
- **Keine Lockerung der Lint-Konfiguration und keine Suppression.** *Gate-Regel:* neue Befunde von
  v2.14.0 werden im Code behoben ([`AGENTS.md`](../../../../AGENTS.md) §3.2, §3.5); `.golangci.yml` wird nicht
  geschwächt.
- **Kein neuer Sensor für Digest und Fallbacks.** *Folge-Slice nicht nötig, Lücke benannt:* §3.6 unten;
  ob ein Wächter dafür trägt, entscheidet der Register-Zähler, nicht dieser Slice.

## 2. Definition of Done

Drei Liefer-Punkte, jeder mit dem Kommando, das ihn rot färbt ([`AGENTS.md`](../../../../AGENTS.md) §3.6).

- [ ] **1 — Go steht auf `1.27.1` an jeder Pin-Stelle, mit belegtem Digest.** Makefile `GO_VERSION`,
      Dockerfile `ARG GO_VERSION` und der `golang`-`@sha256`, `internal/gen/golang.go` `DefaultGoVersion`,
      Fallbacks in `harness/tools/smoke.sh` und `full-smoke.sh`. Der Digest ist der Manifest-Digest
      des Tags `golang:1.27.1`, mit Kommando im Commit. Rot: `make freshness-go` (Exit 1) und
      `TestGoProfile_PinsMatchRepo` bei Halbstand Dockerfile/`DefaultGoVersion`.
- [ ] **2 — golangci-lint steht auf `v2.14.0` an jeder Pin-Stelle, mit belegtem Digest.** Makefile
      `GOLANGCI_LINT_VERSION`, Dockerfile `ARG GOLANGCI_LINT_VERSION` und der `golangci-lint`-`@sha256`,
      `golangciVersion` in `internal/gen/golang.go`. Rot: `make freshness-golangci` und
      `TestGoProfile_PinsMatchRepo`.
- [ ] **3 — `make lint` und `make gates` laufen unter den neuen Images ohne Befund, ohne Suppression.**
      Brachte v2.14.0 neue Befunde, sind sie im Code behoben; `git diff` enthält kein `//nolint` und
      keine Abschwächung von `.golangci.yml`. Rot: `make lint` (Befund) bzw. `make gates` (Exit ≠ 0).
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `Makefile` (Z. 14–15) | update | `GO_VERSION`/`GOLANGCI_LINT_VERSION`: Pin-Quellen der Freshness-Sensoren und `--build-arg`-Wert aller Go-Stages |
| `Dockerfile` (Z. 10–11, 14, 59) | update | beide `ARG`s und beide `@sha256`-Manifest-Digests |
| `internal/gen/golang.go` (Z. 11, 14) | update | `DefaultGoVersion`, `golangciVersion` — das Skelett pinnt Tag-only, ohne Digest |
| `harness/tools/smoke.sh` (Z. 27), `harness/tools/full-smoke.sh` (Z. 156) | update | wert-hardcodende Fallbacks `${GO_VERSION:-…}` |

**Pin-Menge, am Bestand gelesen** (`grep -rnE '1\.27\.0|v2\.13\.1' .` ohne `.git`, `docs/reviews`, `done/`,
`.harness/baseline`): die Zeilen oben. Übrige Treffer sind Fixture oder Prosa und bleiben:
`test/mutate-driver.bats:489` (Fixture-String eines Plan-Urteils), `test/full-smoke-ausgang.bats` (archivierter
CI-Logauszug), `harness/tools/full-smoke-ausgang.sh:37` (Prosa über einen Ausfall). `go.mod` trägt `go 1.27` und
bleibt. `docs/user/` und `.github/` führen keinen der Werte.

**Welcher Wächter koppelt welche Stelle** (gelesen in `internal/gen/gen_test.go` und `test/mutations/18-gen-pin-drift.sh`):

| Stelle | Gekoppelt durch |
|---|---|
| `DefaultGoVersion`/`golangciVersion` ↔ Dockerfile-`ARG` | `TestGoProfile_PinsMatchRepo` liest das **reale** Repo-Dockerfile und das generierte Skelett und vergleicht `ARG GO_VERSION`, `ARG GOLANGCI_LINT_VERSION` und die `go.mod`-major.minor; Mutation 18 (`DefaultGoVersion` → `9.9.9`) färbt ihn rot |
| Makefile-Pin | nur die Freshness-Sensoren (Netz, nicht in `make gates`) |
| `@sha256`-Digest | **kein Wächter** |
| Fallbacks in `smoke.sh`/`full-smoke.sh` | **kein Wächter** |

**§3.6 — was real gebrochen werden kann.** Der Test hält keine Fixture, sondern die reale Quelle (das
repo-eigene Dockerfile), und die Mutation verfälscht den echten Wert. Grenzen, benannt statt verdeckt:
(a) ein vergessener **Digest** lässt den Build still auf dem alten Toolchain-Stand laufen, weil `@sha256`
den Tag übersteuert — alles grün; (b) ein vergessenes Makefile-`GO_VERSION` ist für den Test unsichtbar,
nur der nächtliche Sensor meldet es; (c) ein vergessener Fallback ist unsichtbar. Der Implementer belegt (a)
einmal real (alten Digest stehen lassen, zeigen, dass kein Sensor in `make gates` rot wird) und (b)
(Makefile-Wert zurückdrehen, `make freshness-go` rot sehen). Kein Sensor-Neubau in diesem Slice.

**Digests ermitteln** (Netz an genau diesem Schritt, `docker`, keine Host-Toolchain; kein `make`-Target dafür):
wie im letzten Sprung `docker buildx imagetools inspect golang:1.27.1` und
`docker buildx imagetools inspect golangci/golangci-lint:v2.14.0`, Manifest-Digest in die Dockerfile-Zeilen,
Kommandos in die Commit-Message. **Ohne Netz** fahrbar: `make test` (koppelt die Pins), `make docs-check`,
`make shell-lint`; `make lint`/`make build` brauchen die neuen Images (nach dem Ziehen im lokalen Cache). Bei
Netzausfall hält der Slice; ein geratener Digest ist ausgeschlossen.

## 4. Trigger

**Start** (`next` → `in-progress`): priorisiert; Netz für das Ziehen der Digests verfügbar.

**Rückführungen:**

- `in-progress` → `next`: v2.14.0 bringt Lint-Befunde in einer Zahl, die den Diff über eine Review-Sitzung
  hebt, oder verlangt Konfigurationswechsel. Dann golangci in einen eigenen Slice.
- `in-progress` → `open`: ein Digest ist nicht ermittelbar, oder `1.27.1`/`v2.14.0` wird upstream zurückgezogen.

## 5. Closure-Trigger

`make freshness-go` und `make freshness-golangci` Exit 0; `make gates` Exit 0 unter den neuen Images; Review- und
Verifikations-Report liegen vor; Closure-Notiz mit Lerneintrag.

## 6. Risiken und offene Punkte

- v2.14.0 bringt neue Lint-Befunde — **Ausgang:** weiter offen bis zur Umsetzung; tritt es ein, werden sie im Code
  behoben, nie per `//nolint` ([`AGENTS.md`](../../../../AGENTS.md) §3.2) oder Konfig-Senkung (§3.5); zu groß → §4.
- Ein vergessener Digest färbt nichts rot (§3) — **Ausgang:** weiter offen → Register, Beobachtung
  `BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle` falls der Lauf es real belegt, sonst neue Beobachtung.
- Upstream veröffentlicht vor der Umsetzung einen neueren Stand — **Ausgang:** entfallen: der Lauf zieht auf den
  Stand, den `make freshness-go`/`-golangci` dann melden.

## 7. Closure-Notiz

- **Was hat funktioniert:** —
- **Was ging anders als geplant:** —
- **Steering-Loop-Eintrag:** —
- **Beobachtungs-Register (`../observations/`):** —
- **Folge-Slices:** —
- **Risiken aus §6:** —
- **Drei Paarungen:** —

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist `*` (gesamtes Repo, Kürzel `ALL`); die zwei Fallback-Werte in
`harness/tools/` sind kein eigenes Inklusionskriterium, die Zeile bleibt bei `ALL`.

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen. Treffer:
[`BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle`](../observations/BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle/observation.md),
Zähler 5 (`ls docs/plan/planning/observations/BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle/evidence | wc -l`),
Stand verkörpert. Der Slice berührt die Klasse an Digest und Fallbacks (Lücke ohne Wächter, keine Fixture); der Zähler
steigt nur, wenn der Lauf eine Fixture gegen eine reale Quelle belegt.

**Alle berührten Sub-Areas GF.**
