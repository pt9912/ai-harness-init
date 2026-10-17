# Slice slice-go-toolchain-pin-folgt-dem-freshness-drift: Go-Toolchain-Pin folgt dem Freshness-Drift

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
[`MR-048`](../../../../harness/conventions.md#mr-048) (Reproduzierbarkeits-Anker: Rezept-Form, Skelette pinnen per Tag),
[`ADR-0003`](../../../../docs/plan/adr/0003-go-native-binaries.md) (Docker-only).

**Berührte Spec-Stellen:** —

**Verantwortlich:** Implementer (pt9912)

**Autor:** Planner. **Datum:** 2026-10-17.

---

## 1. Ziel und Abgrenzung

**Ziel:** `make freshness-go` meldet `aktuell`: Der Go-Pin steht auf `1.27.2` an jeder Stelle, die ihn trägt, mit belegtem Manifest-Digest, und das emittierte Skelett zieht mit.

**Anlass:** das nächtliche `upstream-drift` (Lauf `39005560489`, 2026-10-17) ist rot; `make freshness-go` meldet
`gepinnt: 1.27.1`, `latest: 1.27.2` (Exit 1).

**Warum kein ADR/MR:** ein Pin-Anheben auf den Nachfolger derselben Linie senkt keine Schwelle
([`AGENTS.md`](../../../../AGENTS.md) §3.5) und setzt keine Abweichung von der Baseline; die früheren Go-Sprünge
(`slice-go-und-golangci-pin-ziehen-auf-127-1-und-v2140`, davor `cf3b5b81`) trugen weder ADR noch MR.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Kein golangci-lint-Sprung.** *Folge-Slice:* `slice-golangci-lint-pin-folgt-dem-freshness-drift` übernimmt ihn; ein
  Lint-Befund aus v2.15.0 darf den Toolchain-Sprung nicht blockieren, und beide sind einzeln lieferbar.
- **Kein Release des Werkzeugs.** *Anderer Vorgang:* `DefaultGoVersion` ist der Pin, den `ai-harness-init` ins Ziel schreibt
  (Emission); ein Ziel bekommt `1.27.2` erst mit dem nächsten Release. Ob und wann geschnitten wird, entscheidet der
  Auftraggeber; die Closure-Notiz nennt es als Hinweis.
- **Kein Funktionsinhalt, kein `go.mod`-Wechsel.** *Schicht-Abgrenzung:* nur Pin-Werte und die an sie gekoppelten
  Fallbacks; `go.mod` trägt `go 1.27`, ein Patch-Sprung ändert die Minor nicht.
- **Kein Sensor für Digest und Fallbacks.** *Folge-Slice:* `slice-doppelt-gefuehrte-werte-bekommen-ihren-kopplungs-sensor`
  (`open/`) führt beide Teile; dieser Slice belegt die Lücke nur erneut.
- **Keine Änderung an d-check, a-check oder Baseline.** *Bestand bleibt bewusst stehen:* ihre Sensoren sind nicht Gegenstand
  des Auftrags; frühere Prosa ([`MR-092`](../../../../harness/conventions.md#mr-092): `go1.27.1`) ist datiert und eingefroren.

## 2. Definition of Done

Drei Liefer-Punkte, jeder mit dem Kommando, das ihn rot färbt ([`AGENTS.md`](../../../../AGENTS.md) §3.6).

- [x] **1 — Go steht auf `1.27.2` an jeder Pin-Stelle, mit belegtem Digest.** Makefile `GO_VERSION`, Dockerfile
      `ARG GO_VERSION` und der `golang`-`@sha256`, `internal/gen/golang.go` `DefaultGoVersion`, Fallbacks in
      `harness/tools/smoke.sh` und `full-smoke.sh`. Der Digest ist der Manifest-Digest des Tags `golang:1.27.2`,
      Kommando im Commit. Rot: `make freshness-go` (Exit 1 bei zurückgedrehtem Makefile-Pin) und
      `TestGoProfile_PinsMatchRepo` bei Halbstand Dockerfile/`DefaultGoVersion`.
- [x] **2 — Das emittierte Skelett trägt `1.27.2` und bleibt gekoppelt.** `make test` grün, darunter
      `TestGoProfile_PinsMatchRepo`; ein stehengebliebener Skelett-Wert färbt ihn rot (Mutation: `DefaultGoVersion`
      zurückdrehen). Kein Release in diesem Slice.
- [x] **3 — `make build`, `make test` und `make gates` laufen unter dem neuen Image ohne Befund.** Kein `//nolint`,
      keine Abschwächung von `.golangci.yml`. Rot: `make gates` (Exit ≠ 0).
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `Makefile` (Z. 14) | update | `GO_VERSION`: Pin-Quelle von `freshness-go` und `--build-arg`-Wert der Go-Stages |
| `Dockerfile` (Z. 10, 14) | update | `ARG GO_VERSION` und der `golang`-`@sha256`-Manifest-Digest |
| `internal/gen/golang.go` (Z. 11) | update | `DefaultGoVersion` — das Skelett pinnt Tag-only; Emission ins Ziel |
| `harness/tools/smoke.sh` (Z. 27), `harness/tools/full-smoke.sh` (Z. 156) | update | wert-hardcodende Fallbacks `${GO_VERSION:-…}` |

**Pin-Menge, am Bestand gelesen:** `git grep -nE '1\.27\.1' -- . ':!.harness/baseline' ':!docs/reviews' ':!docs/plan/planning/done'`
nennt Makefile:14, Dockerfile:10, `smoke.sh`:27, `full-smoke.sh`:156, `golang.go`:11 und die datierte Prosa in [`MR-092`](../../../../harness/conventions.md#mr-092) (bleibt).
`go.mod` trägt `go 1.27` und bleibt.

**Welcher Wächter koppelt welche Stelle:** `TestGoProfile_PinsMatchRepo` (`internal/gen/gen_test.go`) liest das reale
Repo-Dockerfile und vergleicht `ARG GO_VERSION` mit `DefaultGoVersion`; der Makefile-Pin: nur `freshness-go` (Netz, nicht in
`make gates`); `@sha256`-Digest und Fallbacks: **kein Wächter** (Beobachtung `BEO-ALL/pin-digest-ohne-waechter`). Der
Implementer bricht die reale Quelle (Makefile-Wert, Dockerfile-Wert), nicht eine Fixture, und liest die Ursache der Rot-Meldung.

**Digests ermitteln** (Netz an genau diesem Schritt, `docker`, keine Host-Toolchain; kein `make`-Target dafür):
`docker buildx imagetools inspect golang:1.27.2`, Manifest-Digest in die Dockerfile-Zeile, Kommando in die Commit-Message.
Ohne Netz fahrbar: `make test`, `make docs-check`, `make shell-lint`. Ein geratener Digest ist ausgeschlossen.

## 4. Trigger

**Start** (`next` → `in-progress`): Auftrag des Auftraggebers liegt vor; der Drift ist gemessen (`make freshness-go`
meldet `1.27.1` gegen `1.27.2`); WIP-Limit frei (`in-progress/` trägt nur die Roadmap). Dieser Slice läuft vor dem
golangci-lint-Slice: der Toolchain-Sprung trägt Emission und Sicherheitsfixes der Linie, und ein Lint-Befund darf ihn nicht aufhalten.

**Rückführungen:**

- `in-progress` → `next`: das neue Image bringt Test- oder Lint-Befunde in einer Zahl, die den Diff über eine
  Review-Sitzung hebt.
- `in-progress` → `open`: `golang:1.27.2` ist auf Docker Hub nicht ermittelbar (go.dev meldet vor dem Image) oder
  wird upstream zurückgezogen.

## 5. Closure-Trigger

`make freshness-go` Exit 0; `make gates` Exit 0 unter dem neuen Image; Review- und Verifikations-Report liegen vor;
Closure-Notiz mit Lerneintrag, die den Release-Hinweis (Emission) nennt.

## 6. Risiken und offene Punkte

- Das Docker-Hub-Image `golang:1.27.2` fehlt noch — **Ausgang:** entfallen: das Image existiert, der Manifest-Digest ist ermittelt und belegt (§7).
- Ein vergessener Digest oder Fallback färbt nichts rot — **Ausgang:** weiter offen → `BEO-ALL/pin-digest-ohne-waechter` im Register (siebter Beleg).
- Das Ziel bekommt `1.27.2` erst mit einem Release — **Ausgang:** entfallen für diesen Slice: Release ist ein anderer Vorgang
  (§1); der Hinweis steht in der Closure-Notiz.

## 7. Closure-Notiz

- **Was hat funktioniert:** Go steht auf `1.27.2` an jeder Pin-Stelle des Plans (Makefile, Dockerfile-`ARG` und Manifest-Digest, `DefaultGoVersion`, beide Fallbacks); `make freshness-go` meldet `aktuell`, `make gates` grün, kein `//nolint`, keine Lockerung. Review: 0 HIGH/0 MEDIUM/0 LOW/1 INFO; Verifikation bestätigt DoD 1-3 und fuhr beide Rot-Belege selbst (`DefaultGoVersion` bzw. Dockerfile-`ARG` auf `1.27.1` → `TestGoProfile_PinsMatchRepo` rot, richtiger Grund); der Digest `sha256:820153…62d8` gehört zum Tag `golang:1.27.2`, `1.27.1` trägt einen anderen (`docs/reviews/2026-10-17-slice-go-toolchain-pin-folgt-dem-freshness-drift.md`, `…-verify.md`).
- **Was ging anders als geplant:** nichts am Umfang. Messgrenze der Verifikation: in der Kopie lief `make test` statt `make gates`; ein roter bats-Fall dort ist ein Artefakt der `.git`-losen Kopie. Nicht belegt: CI auf anderem Host (erst nächster Push oder Nacht-Lauf); keine Mutations-Fälle.
- **Steering-Loop-Eintrag:** benannte Lücke, kein neuer Sensor: Digest und Fallbacks haben weiter keinen Wächter, und der Verifier belegte erstmals den schärferen Fall — ein real existierender, aber falscher Digest (der von `1.27.1` an dem Tag `1.27.2`) baut und färbt nichts; der Makefile-Pin färbt nur `freshness-go` (Netz, nicht in `make gates`). Die Fallbacks `${GO_VERSION:-…}` wirken nur bei direktem Skript-Aufruf, denn alle vier `make`-Rezepte übergeben `GO_VERSION` (Review INFO-1). Träger ist der Folge-Slice `slice-doppelt-gefuehrte-werte-bekommen-ihren-kopplungs-sensor`; bis dahin der Lauf, der den Pin zieht.
- **Trigger-Audit:** keine ADR und kein Eintrag verlangt eine Änderung: [`MR-092`](../../../../harness/conventions.md#mr-092) und [`MR-093`](../../../../harness/conventions.md#mr-093) nennen die Go-Version nur datiert, und keine Datei unter `docs/plan/adr` nennt `GO_VERSION` oder `1.27`. Der Fall von `BEO-ALL/pin-sprung-feuert-adr-trigger-ohne-nennung` (ein Sprung feuert den Trigger einer ADR) ist hier nicht aufgetreten.
- **Beobachtungs-Register (`../observations/`):** [`BEO-ALL/pin-digest-ohne-waechter`](../observations/BEO-ALL/pin-digest-ohne-waechter/observation.md): weitere Evidence-Datei (siebter Beleg, dasselbe Muster mit belegtem Fall des falschen, aber existierenden Digests), Stand bleibt `geplant`. [`BEO-ALL/pin-sprung-feuert-adr-trigger-ohne-nennung`](../observations/BEO-ALL/pin-sprung-feuert-adr-trigger-ohne-nennung/observation.md): nicht aufgetreten, keine Datei. [`BEO-ALL/kennung-traegt-den-stand-den-ein-release-ueberholt`](../observations/BEO-ALL/kennung-traegt-den-stand-den-ein-release-ueberholt/observation.md): die Kennung trägt bewusst keine Version, kein Auftreten, keine Datei. [`BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle`](../observations/BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle/observation.md): der Slice brach an der realen Quelle, kein Beleg.
- **Release-Hinweis (kein Beschluss):** `DefaultGoVersion` wird ins Ziel emittiert; gebootstrappte Ziele bekommen `1.27.2` erst mit dem nächsten Release. Ob und wann geschnitten wird, entscheidet der Auftraggeber.
- **Folge-Slices:** `slice-golangci-lint-pin-folgt-dem-freshness-drift` (Abgrenzung §1); `slice-doppelt-gefuehrte-werte-bekommen-ihren-kopplungs-sensor` (Ausgang des Registers).
- **Risiken aus §6:** 1 entfallen (Image existiert, Digest belegt) · 2 weiter offen → Register `BEO-ALL/pin-digest-ohne-waechter` · 3 entfallen (Release ist ein anderer Vorgang, Hinweis oben).
- **Drei Paarungen:** Anker: kein `liegt in`-Feld, nichts zu paaren; Folge-Slice: beide genannten liegen im Planning-Lifecycle; Register: die zitierten Pfade existieren.

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist `*` (gesamtes Repo, Kürzel `ALL`); die Fallbacks in
`harness/tools/` sind kein eigenes Inklusionskriterium, die Zeile bleibt bei `ALL`.

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen (`ls docs/plan/planning/observations/BEO-ALL/`).
Treffer, Zähler je `ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence | wc -l`:
[`BEO-ALL/pin-digest-ohne-waechter`](../observations/BEO-ALL/pin-digest-ohne-waechter/observation.md) — Zähler 6,
Stand `geplant` (Folge-Slice `slice-doppelt-gefuehrte-werte-bekommen-ihren-kopplungs-sensor`, liegt in `open/`); der Slice
berührt Digest und Fallbacks erneut, ein weiterer Beleg ist zu erwarten, die Schwelle ist überschritten und hat ihren Ausgang.
[`BEO-ALL/pin-sprung-feuert-adr-trigger-ohne-nennung`](../observations/BEO-ALL/pin-sprung-feuert-adr-trigger-ohne-nennung/observation.md) — Zähler 1,
`offen`; Träger ist das Trigger-Audit der Closure.
[`BEO-ALL/kennung-traegt-den-stand-den-ein-release-ueberholt`](../observations/BEO-ALL/kennung-traegt-den-stand-den-ein-release-ueberholt/observation.md) —
Zähler 1, `offen`; die Kennung dieses Slice nennt darum keinen Versionsstand.
[`BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle`](../observations/BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle/observation.md) — verkörpert;
der Slice berührt die Klasse nur, wo der Implementer die reale Quelle (Dockerfile, Makefile) bricht.

**Stand nach der Closure:** `BEO-ALL/pin-digest-ohne-waechter` — Zähler 7, Stand `geplant` (Ausgang unverändert);
`pin-sprung-feuert-adr-trigger-ohne-nennung` und `kennung-traegt-den-stand-den-ein-release-ueberholt` — Zähler 1, `offen`.

**Alle berührten Sub-Areas GF.**
