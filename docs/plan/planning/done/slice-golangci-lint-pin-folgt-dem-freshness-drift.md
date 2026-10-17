# Slice slice-golangci-lint-pin-folgt-dem-freshness-drift: golangci-lint-Pin folgt dem Freshness-Drift

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

**Ziel:** `make freshness-golangci` meldet `aktuell`: Der golangci-lint-Pin steht auf `v2.15.0` an jeder Stelle, die ihn trägt, mit belegtem Manifest-Digest, und `make lint` läuft ohne Befund und ohne Suppression.

**Anlass:** das nächtliche `upstream-drift` (Lauf `39005560489`, 2026-10-17) ist rot; `make freshness-golangci` meldet
`gepinnt: v2.14.0`, `latest: v2.15.0` (Exit 1).

**Warum kein ADR/MR:** ein Pin-Anheben auf den Nachfolger derselben Linie senkt keine Schwelle
([`AGENTS.md`](../../../../AGENTS.md) §3.5) und setzt keine Abweichung von der Baseline; die früheren Sprünge
(`slice-go-und-golangci-pin-ziehen-auf-127-1-und-v2140`, davor `cf3b5b81`) trugen weder ADR noch MR.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Kein Go-Sprung.** *Anderer Slice, vorgelagert:* `slice-go-toolchain-pin-folgt-dem-freshness-drift` führt ihn und liegt vor
  diesem Slice in `done/`; die zwei Pins sind unabhängig, nur die Reihenfolge ist gesetzt.
- **Kein Release des Werkzeugs.** *Anderer Vorgang:* `golangciVersion` ist der Pin, den `ai-harness-init` ins Ziel schreibt
  (Emission); ein Ziel bekommt `v2.15.0` erst mit dem nächsten Release, dessen Zeitpunkt der Auftraggeber entscheidet.
- **Keine Lockerung der Lint-Konfiguration und keine Suppression.** *Gate-Regel:* neue Befunde von v2.15.0 werden im Code
  behoben ([`AGENTS.md`](../../../../AGENTS.md) §3.2, §3.5); `.golangci.yml` wird nicht geschwächt.
- **Kein Sensor für Digest.** *Folge-Slice:* `slice-doppelt-gefuehrte-werte-bekommen-ihren-kopplungs-sensor` (`open/`).

## 2. Definition of Done

Drei Liefer-Punkte, jeder mit dem Kommando, das ihn rot färbt ([`AGENTS.md`](../../../../AGENTS.md) §3.6).

- [x] **1 — golangci-lint steht auf `v2.15.0` an jeder Pin-Stelle, mit belegtem Digest.** Makefile
      `GOLANGCI_LINT_VERSION`, Dockerfile `ARG GOLANGCI_LINT_VERSION` und der `golangci-lint`-`@sha256`,
      `golangciVersion` in `internal/gen/golang.go`. Digest: Manifest-Digest des Tags `golangci/golangci-lint:v2.15.0`,
      Kommando im Commit. Rot: `make freshness-golangci` (Exit 1 bei zurückgedrehtem Makefile-Pin) und
      `TestGoProfile_PinsMatchRepo` bei Halbstand.
- [x] **2 — `make lint` läuft unter dem neuen Image ohne Befund und ohne Suppression.** Neue Befunde sind im Code behoben;
      `git diff` enthält kein `//nolint` und keine Abschwächung von `.golangci.yml`. Rot: `make lint` (Befund).
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
| `Makefile` (Z. 15) | update | `GOLANGCI_LINT_VERSION`: Pin-Quelle von `freshness-golangci` und Build-Arg von `make lint` |
| `Dockerfile` (Z. 11, 59) | update | `ARG GOLANGCI_LINT_VERSION` und der `golangci-lint`-`@sha256`-Manifest-Digest |
| `internal/gen/golang.go` (Z. 14) | update | `golangciVersion` — das Skelett pinnt Tag-only; Emission ins Ziel |

**Pin-Menge, am Bestand gelesen:** `git grep -nE 'v2\.14\.0' -- . ':!.harness/baseline' ':!docs/reviews' ':!docs/plan/planning/done'`
nennt genau Dockerfile:11, Makefile:15 und `golang.go`:14; der Digest in Dockerfile:59 trägt den Wert nicht im Text.

**Welcher Wächter koppelt welche Stelle:** `TestGoProfile_PinsMatchRepo` (`internal/gen/gen_test.go`) liest das reale
Repo-Dockerfile und vergleicht `ARG GOLANGCI_LINT_VERSION` mit `golangciVersion`; Makefile-Pin: nur `freshness-golangci`;
`@sha256`-Digest: **kein Wächter** (`BEO-ALL/pin-digest-ohne-waechter`). Der Implementer bricht die reale Quelle.

**Digest ermitteln** (Netz an genau diesem Schritt, `docker`, keine Host-Toolchain):
`docker buildx imagetools inspect golangci/golangci-lint:v2.15.0`, Manifest-Digest in die Dockerfile-Zeile, Kommando in die
Commit-Message. Ein geratener Digest ist ausgeschlossen.

## 4. Trigger

**Start** (`next` → `in-progress`) — erfüllt: `slice-go-toolchain-pin-folgt-dem-freshness-drift` liegt in `done/`
(`ls docs/plan/planning/done/slice-go-toolchain-pin-folgt-dem-freshness-drift.md`; WIP-Limit 1 frei, die Toolchain steht vor dem Linter); der Drift ist gemessen (`make freshness-golangci`: `v2.14.0`
gegen `v2.15.0`).

**Rückführungen:**

- `in-progress` → `next`: v2.15.0 bringt Lint-Befunde in einer Zahl, die den Diff über eine Review-Sitzung hebt, oder
  verlangt Konfigurationswechsel.
- `in-progress` → `open`: der Digest ist nicht ermittelbar, oder `v2.15.0` wird upstream zurückgezogen.

## 5. Closure-Trigger

`make freshness-golangci` Exit 0; `make lint` und `make gates` Exit 0 unter dem neuen Image; Review- und
Verifikations-Report liegen vor; Closure-Notiz mit Lerneintrag, die den Release-Hinweis (Emission) nennt.

## 6. Risiken und offene Punkte

- v2.15.0 bringt neue Lint-Befunde — **Ausgang:** weiter offen bis zur Umsetzung; tritt es ein, werden sie im Code behoben,
  nie per `//nolint` ([`AGENTS.md`](../../../../AGENTS.md) §3.2) oder Konfig-Senkung (§3.5); zu groß → §4.
- Ein vergessener Digest färbt nichts rot — **Ausgang:** weiter offen → `BEO-ALL/pin-digest-ohne-waechter` im Register.
- Upstream veröffentlicht vor der Umsetzung einen neueren Stand — **Ausgang:** entfallen: der Lauf zieht auf den Stand,
  den `make freshness-golangci` dann meldet.

## 7. Closure-Notiz

- **Was hat funktioniert:** golangci-lint steht auf `v2.15.0` an jeder Pin-Stelle des Plans (Makefile, Dockerfile-`ARG` und Manifest-Digest `sha256:fbfcfd12…c481`, `golangciVersion`); `make freshness-golangci` meldet `aktuell`, `make lint` liest `0 issues.` ohne `//nolint` und ohne Änderung an `.golangci.yml`, `make gates` grün, `make full-smoke-host` Exit 0 mit demselben Pin im Ziel. Review: 0 HIGH/0 MEDIUM/0 LOW/1 INFO; Verifikation bestätigt DoD 1 und 2 und fuhr den Rot-Beleg selbst (`golangciVersion` bzw. Dockerfile-`ARG` auf `v2.14.0` → `TestGoProfile_PinsMatchRepo` rot, richtiger Grund, beide Richtungen) (`docs/reviews/2026-10-17-slice-golangci-lint-pin-folgt-dem-freshness-drift.md`, `…-verify.md`).
- **Was ging anders als geplant:** nichts am Umfang, keine Lint-Befunde aus v2.15.0. Messgrenzen der Verifikation: der Makefile-Pin ist nur per `make -n` in der `.git`-losen Kopie geprüft (kein voller `make gates` mit gebrochenem Pin); der falsche, real existierende Digest wurde diesmal nicht gebrochen gefahren. Nicht belegt: CI auf anderem Host (erst nächster Push oder Nacht-Lauf); kein Mutations-Fall in `test/mutations/`, keine Mutations-Probe.
- **Steering-Loop-Eintrag:** benannte Lücke, kein neuer Sensor: der Test hält allein `ARG GOLANGCI_LINT_VERSION` gegen `golangciVersion`; Makefile-Pin (nur `freshness-golangci`, Netz, nicht in `make gates`) und `@sha256`-Digest haben weiter keinen Wächter. Zum achten Mal fällt dieselbe Klasse an, jetzt für den zweiten Pin desselben Sprungs; neu ist nichts, den schärferen Fall (falscher, existierender Digest) belegt bereits der Vorgänger-Slice. Träger ist der Folge-Slice `slice-doppelt-gefuehrte-werte-bekommen-ihren-kopplungs-sensor`; bis dahin der Lauf, der den Pin zieht.
- **Trigger-Audit:** keine ADR und kein Eintrag verlangt eine Änderung: ADR-0003, ADR-0007, ADR-0008, ADR-0009, ADR-0088 und MR-002, MR-007, MR-014, MR-048, MR-050 nennen golangci-lint nur als Werkzeug oder Kontext, keiner nennt einen Pin-Wert. Der Fall von `BEO-ALL/pin-sprung-feuert-adr-trigger-ohne-nennung` ist hier nicht aufgetreten.
- **Beobachtungs-Register (`../observations/`):** [`BEO-ALL/pin-digest-ohne-waechter`](../observations/BEO-ALL/pin-digest-ohne-waechter/observation.md): weitere Evidence-Datei (achter Beleg, ein weiterer Vorgang), Stand bleibt `geplant`. [`BEO-ALL/pin-sprung-feuert-adr-trigger-ohne-nennung`](../observations/BEO-ALL/pin-sprung-feuert-adr-trigger-ohne-nennung/observation.md): nicht aufgetreten, keine Datei. [`BEO-ALL/kennung-traegt-den-stand-den-ein-release-ueberholt`](../observations/BEO-ALL/kennung-traegt-den-stand-den-ein-release-ueberholt/observation.md): die Kennung trägt bewusst keine Version, kein Auftreten, keine Datei. [`BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle`](../observations/BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle/observation.md): der Slice brach an der realen Quelle (Dockerfile-`ARG`, `golangciVersion`), kein Beleg.
- **Release-Hinweis (kein Beschluss):** `golangciVersion` wird ins Ziel emittiert; gebootstrappte Ziele bekommen `v2.15.0` erst mit dem nächsten Release. Zusammen mit dem Go-Pin `1.27.2` aus dem Vorgänger-Slice ist die Emission zweier Pins gegenüber `v0.8.0` verändert. Ob und wann geschnitten wird, entscheidet der Auftraggeber.
- **Folge-Slices:** `slice-doppelt-gefuehrte-werte-bekommen-ihren-kopplungs-sensor` (Abgrenzung §1 und Ausgang des Registers).
- **Risiken aus §6:** 1 entfallen (v2.15.0 bringt keinen Lint-Befund: `0 issues.`, kein Code geändert) · 2 weiter offen → Register `BEO-ALL/pin-digest-ohne-waechter` · 3 entfallen (kein neuerer Stand erschienen, `make freshness-golangci` meldet `aktuell`).
- **Drei Paarungen:** Anker: kein `liegt in`-Feld, nichts zu paaren; Folge-Slice: der genannte liegt im Planning-Lifecycle; Register: die zitierten Pfade existieren (nach dem Move geprüft).

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

**Stand nach der Closure:** `BEO-ALL/pin-digest-ohne-waechter` — Zähler 8, Stand `geplant` (Ausgang unverändert);
`pin-sprung-feuert-adr-trigger-ohne-nennung` und `kennung-traegt-den-stand-den-ein-release-ueberholt` — Zähler 1, `offen`.

**Alle berührten Sub-Areas GF.**
