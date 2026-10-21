# Slice slice-go-toolchain-pin-zieht-auf-1-27-3: Go-Toolchain-Pin zieht auf 1.27.3

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
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (der Freshness-Sensor meldet den Drift),
[`MR-048`](../../../../harness/conventions.md#mr-048) (Rezept-Form, Skelette pinnen per Tag),
[`ADR-0003`](../../../../docs/plan/adr/0003-go-native-binaries.md) (Docker-only).

**Berührte Spec-Stellen:** —

**Verantwortlich:** dburkard

**Autor:** Planner. **Datum:** 2026-10-21.

---

## 1. Ziel und Abgrenzung

**Ziel:** `make freshness-go` meldet `aktuell`: der Go-Pin steht auf `1.27.3` an jeder Stelle, die ihn trägt, mit belegtem Manifest-Digest, und das emittierte Skelett zieht mit.

**Anlass:** das nächtliche `upstream-drift` (2026-10-20, 05:36 UTC, Stand `0f5d67c0`) ist rot:
`go-toolchain: VERALTET — gepinnt 1.27.2, latest 1.27.3`; alle anderen Freshness-Achsen sind aktuell.

**Warum kein ADR/MR:** ein Patch-Sprung derselben Linie senkt keine Schwelle ([`AGENTS.md`](../../../../AGENTS.md) §3.5) und setzt
keine Abweichung von der Baseline; die Vorgänger-Sprünge (`slice-go-toolchain-pin-folgt-dem-freshness-drift`,
`slice-go-und-golangci-pin-ziehen-auf-127-1-und-v2140`) trugen weder ADR noch MR, und keine ADR nennt `GO_VERSION`
(`grep -rl GO_VERSION docs/plan/adr` nennt keine; [`MR-048`](../../../../harness/conventions.md#mr-048) und
[`MR-092`](../../../../harness/conventions.md#mr-092)/[`MR-093`](../../../../harness/conventions.md#mr-093) nennen die Version nur datiert).
**Architect-Bedarf: keiner.**

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Kein Release und keine Änderung der `TRAEGER_*`-Pins.** *Anderer Vorgang:* `TRAEGER_TAG` und `TRAEGER_SHA256_*` im `Makefile`
  gelten dem veröffentlichten `v0.10.0`-Asset und bleiben stehen; ein Neubau mit Go `1.27.3` weicht von diesem Asset ab
  (Binär und emittiertes Skelett ändern sich), und das ist kein Defekt dieses Slice. Ziele bekommen `1.27.3` erst mit dem
  nächsten Release; ob und wann geschnitten wird, entscheidet der Auftraggeber.
- **Kein Pin einer anderen Achse.** *Bestand bleibt bewusst stehen:* golangci-lint, d-check, a-check, Baseline, C++- und
  Kotlin-Skelett sind aktuell gemeldet; ein Sprung wäre ein anderer Gegenstand.
- **Kein `go.mod`-Wechsel, kein Funktionsinhalt.** *Schicht-Abgrenzung:* `go.mod` trägt `go 1.27`; ein Patch-Sprung ändert die Minor nicht.
- **Kein neuer Wächter für Digest oder Fallbacks.** *Bestand bleibt bewusst stehen:* `test/pin-fallbacks.bats` und
  `make freshness-digest` tragen sie bereits ([`BEO-ALL/pin-digest-ohne-waechter`](../observations/BEO-ALL/pin-digest-ohne-waechter/observation.md), verkörpert).
- **Keine Korrektur der Handbuch-Beispielwerte.** *Bestand bleibt bewusst stehen:* `docs/user/benutzerhandbuch.md` nennt `SKEL_GO_VERSION=1.26.4`
  (Z. 416, 497) als Beispiel-Eingabe, nicht als Pin; der Sprung berührt sie nicht.

## 2. Definition of Done

Drei Liefer-Punkte, je mit dem Kommando, das ihn rot färbt ([`AGENTS.md`](../../../../AGENTS.md) §3.6).

- [ ] **1 — Go steht auf `1.27.3` an jeder Pin-Stelle, mit belegtem Digest.** `Makefile` `GO_VERSION`, `Dockerfile` `ARG GO_VERSION` und
      `golang`-`@sha256`, `internal/gen/golang.go` `DefaultGoVersion`, die Fallbacks in `harness/tools/smoke.sh` und `full-smoke.sh`.
      Der Digest ist der Manifest-Digest des Tags `golang:1.27.3`, Kommando in der Commit-Message; kein geratener Wert.
      Rot: `make freshness-go` (Exit 1 bei zurückgedrehtem Makefile-Pin) und `make freshness-digest` (Digest eines anderen Tags, Netz).
- [ ] **2 — Das emittierte Skelett trägt `1.27.3` und bleibt gekoppelt.** `make test` grün. Rot, an der realen Quelle gebrochen:
      `DefaultGoVersion` bzw. Dockerfile-`ARG` auf `1.27.2` → `TestGoProfile_PinsMatchRepo`; ein Fallback auf `1.27.2` → `test/pin-fallbacks.bats`.
      Ursache der Meldung lesen, nicht nur „rot".
- [ ] **3 — `make build`, `make test` und `make gates` laufen unter dem neuen Image ohne Befund.** Kein `//nolint`, keine Abschwächung von
      `.golangci.yml`. Rot: `make gates` (Exit ≠ 0).
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
| `Makefile` (`GO_VERSION ?=`) | update | Pin-Quelle von `freshness-go` und `--build-arg`-Wert der Go-Stages |
| `Dockerfile` (`ARG GO_VERSION`, `FROM golang:…@sha256`) | update | Version und Manifest-Digest |
| `internal/gen/golang.go` (`DefaultGoVersion`) | update | das Skelett pinnt Tag-only; Emission ins Ziel |
| `harness/tools/smoke.sh`, `harness/tools/full-smoke.sh` (`${GO_VERSION:-…}`) | update | wert-hardcodende Fallbacks |

**Pin-Menge, am Bestand gelesen:** `git grep -nE '1\.27\.2' -- . ':!.harness/baseline' ':!docs/reviews' ':!docs/plan/planning'` nennt
genau diese fünf Stellen plus die datierte Prosa in `MR-092`/`MR-093` (bleibt) und die Literale `golang:1.27.2` in
`test/digest-freshness.bats` (Fixture-Strings der Vergleichs-Fälle, kein Pin; der Implementer nimmt sie nicht mit, es sei denn, ein Fall liest den Repo-Pin).
`go.mod` bleibt. **Kopplung:** `TestGoProfile_PinsMatchRepo` (`internal/gen`) hält Dockerfile-`ARG` gegen `DefaultGoVersion`;
`test/pin-fallbacks.bats` hält die Fallbacks gegen den Makefile-Pin; Makefile-Pin gegen Upstream nur `freshness-go`, Digest gegen Tag nur
`freshness-digest` (beide Netz, nicht in `make gates`).

**Digest beschaffen** (Netz an genau diesem Schritt, Docker-only, keine Host-Toolchain): `docker buildx imagetools inspect golang:1.27.3`,
Manifest-Digest in die Dockerfile-Zeile, Kommando in die Commit-Message; danach `make freshness-digest` als Gegenprobe (Hub-Rate-Limit möglich,
siehe §8). Ohne Netz fahrbar: `make test`, `make docs-check`, `make shell-lint`.

## 4. Trigger

**Start** (`next` → `in-progress`): Auftrag des Auftraggebers liegt vor; der Drift ist gemessen (`go-toolchain: VERALTET`, Nacht-Lauf 2026-10-20);
WIP-Limit frei (`in-progress/` trägt nur die Roadmap).

**Rückführungen:**

- `in-progress` → `next` (zu groß): das neue Image bringt Test- oder Lint-Befunde in einer Zahl, die den Diff über eine Review-Sitzung hebt.
- `in-progress` → `open` (blockiert): `golang:1.27.3` ist auf Docker Hub nicht ermittelbar oder wird zurückgezogen.

## 5. Closure-Trigger

`make freshness-go` Exit 0; `make gates` Exit 0 unter dem neuen Image; Review- und Verifikations-Report liegen vor; Closure-Notiz mit
Lerneintrag, die den Release-Hinweis (Emission, `TRAEGER_*` unverändert) nennt.

## 6. Risiken und offene Punkte

- Das Image `golang:1.27.3` fehlt noch auf Docker Hub (go.dev meldet vor dem Image) — **Ausgang:** entfallen, sobald der Manifest-Digest ermittelt und belegt ist; sonst Rückführung nach `open/`.
- Ein vergessener Digest oder Fallback färbt nichts — **Ausgang:** entfallen: `make freshness-digest` und `test/pin-fallbacks.bats` tragen ihn (Register `pin-digest-ohne-waechter`, verkörpert); der Implementer führt beide.
- Ein Neubau weicht vom veröffentlichten `v0.10.0`-Asset ab und färbt einen `TRAEGER_*`-Wächter — **Ausgang:** entfallen: die Pins gelten dem Release-Asset und werden nicht angefasst (§1); `traeger-pins-check` läuft am Release, nicht am Neubau.
- Das emittierte Lint-Rezept reicht `GO_VERSION` nicht weiter, ein Ziel läuft nach dem Sprung gemischt — **Ausgang:** weiter offen → `BEO-ALL/emittiertes-lint-rezept-uebergibt-die-go-version-nicht` im Register (hier nicht behoben, anderer Gegenstand).

## 7. Closure-Notiz


- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Gegenstand:** <übernommen von `slice-<Kennung>` | entfallen: <Grund>>
  *(nur beim Ausgang ohne Arbeit; sonst Zeile löschen)*
- **Steering-Loop-Eintrag:** <Guide oder Sensor> <geschärft/ergänzt>: <was genau>
  — liegt in `<AGENTS.md §X | Makefile:<target> | .harness/skills/…>`.
  Auslöser: `BEO-<KUERZEL>/<slug>` (<slice-kennung-a>, <slice-kennung-b>, <slice-kennung-c> — 3×).
  *(Wurde mit diesem Slice nichts verkörpert — der Normalfall —, entfällt die
  Teil-Zeile `— liegt in …` ersatzlos. Der Eintrag ist dann gezählt, nicht
  verkörpert.)*
- **Beobachtungs-Register (`../observations/`):** <`BEO-<KUERZEL>/<slug>/` neu angelegt, Beleg `evidence/slice-<Kennung>.md` | `evidence/slice-<Kennung>.md` in `BEO-<KUERZEL>/<slug>/` ergaenzt — Zaehler steht damit bei <N>x | keine Beobachtung angefallen>
- **Folge-Slices:** <slice-<Kennung> (<Titel>) — ist eine Datei in `open/`>
- **Risiken aus §6:** <jedes mit genau einem Ausgang — siehe §6>
- **Drei Paarungen:** <nur im Repo ohne Wellen-Betrieb — Anker · Folge-Slice · Register, Ergebnis>

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist `*` (gesamtes Repo, Kürzel `ALL`); die Fallbacks in `harness/tools/` sind kein eigenes Inklusionskriterium.

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen (`ls docs/plan/planning/observations/BEO-ALL/`), Zähler je
`ls <slug>/evidence | wc -l` am gemergten Stand: [`pin-digest-ohne-waechter`](../observations/BEO-ALL/pin-digest-ohne-waechter/observation.md) — 8, verkörpert;
[`anonymes-hub-rate-limit-faerbt-den-nacht-lauf-der-digest-achse`](../observations/BEO-ALL/anonymes-hub-rate-limit-faerbt-den-nacht-lauf-der-digest-achse/observation.md) — 1, `offen`, berührt die Gegenprobe `make freshness-digest`;
[`emittiertes-lint-rezept-uebergibt-die-go-version-nicht`](../observations/BEO-ALL/emittiertes-lint-rezept-uebergibt-die-go-version-nicht/observation.md) — 1, `offen`, der Sprung ändert das emittierte Skelett;
[`pin-sprung-feuert-adr-trigger-ohne-nennung`](../observations/BEO-ALL/pin-sprung-feuert-adr-trigger-ohne-nennung/observation.md) — 1, `offen`, Träger ist das Trigger-Audit der Closure (Ergebnis oben: keine ADR nennt `GO_VERSION`).
Zahlen neben dem Kommando, das sie liefert ([`MR-025`](../../../../harness/conventions.md#mr-025)). Keiner erreicht mit diesem Slice 3×.

**Alle berührten Sub-Areas GF.**


