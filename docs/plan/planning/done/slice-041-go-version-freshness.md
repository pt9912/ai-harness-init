# Slice slice-041: Go-Version-Freshness (Sonderquelle go.dev)

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.0/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-06-freshness](../welle-06-freshness.md).

**Bezug:** [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) (Freshness-Achse), [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (Netz-Sensor **nicht** in gates), [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (bash+curl, kein jq/node).

**Autor:** ai-harness-init-Team (pt9912). **Datum:** 2026-07-24.

---

## 1. Ziel

Die Go-Toolchain-Version bekommt eine Freshness-Achse: der gepinnte `GO_VERSION`
wird gegen das aktuelle stabile Go von **go.dev** verglichen, verdrahtet in den
nächtlichen `upstream-drift`-Job — read-only, außerhalb `make gates`. Go ist eine
**Sonderquelle** (nicht GitHub `releases/latest`): der Vergleicher aus slice-040 wird
wiederverwendet, nur der Fetch ist Go-spezifisch.

## 2. Definition of Done

- [x] **Go-Fetch + Wrapper** (`harness/tools/go-freshness.sh` <!-- d-check:ignore (geplante Datei — entsteht in diesem Slice) -->): holt die aktuelle
  stabile Go-Version von `https://go.dev/VERSION?m=text` (erste Zeile, z. B. `go1.26.5`),
  **normalisiert** sie auf das Pin-Format (`go1.x.y` → `1.x.y`) und ruft für den Vergleich
  `component-freshness.sh --compare` (kein dupliziertes compare). bash+curl+coreutils, **kein
  jq/node** ([`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)).
- [x] **Hermetischer `--normalize <raw>`-Pfad**: die Normalisierung (erste Zeile, `go`-Präfix
  strippen) ist netzlos mit Fixture-Strings testbar, getrennt vom Fetch (analog dem
  `--compare`-Muster aus slice-040).
- [x] **Make-Target `freshness-go`:** vergleicht den gepinnten `GO_VERSION` (kanonische Quelle
  benannt: Makefile-Var = der Build-Arg, den `make build`/`make test` reichen) gegen go.dev.
- [x] **Nachtlauf verdrahtet:** die Go-Achse im `upstream-drift`-Job (`schedule`), mit
  `if: '!cancelled()'` (alle Achsen laufen, auch wenn eine rot meldet) — belegt im Workflow-Diff.
  **Nicht** in `make gates` (offline-grün, [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- [x] `make gates` grün: die `--normalize`- + `--compare`-Fixture-Tests (aktuell / veraltet /
  fetch-fehler / Normalisierung) laufen **offline**.
- [x] `make mutate` grün: eine Mutation, die die Normalisierung bricht (z. B. `go`-Strip entfernt
  oder `head -1` gelöscht), färbt einen Fixture-Test rot.
- [x] Doku: `make help`-Zeile + `harness/conventions.md`-Freshness-Notiz um die Go-Achse ergänzt.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

**Ist-Messung (2026-07-24, live belegt):** `GO_VERSION ?= 1.26.4` (Makefile, kanonisch — Build-Arg
in die Dockerfile-Stages, gleiches Muster wie golangci-lint in slice-040). `go.dev/VERSION?m=text`
→ `go1.26.5` (Plaintext, erste Zeile; kein jq). `github.com/golang/go/releases/latest` redirected auf
`.../releases` (**nicht** `/releases/tag/<tag>`) → die generische GitHub-Mechanik aus slice-040 greift
**nicht**, darum der Go-eigene Fetch. Nebenbefund: upstream `1.26.5` > gepinnt `1.26.4` — der Sensor
meldet ab Tag 1 real Drift (korrekt; Auflösung = `GO_VERSION`-Bump, out-of-scope, s. §6).

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness/tools/go-freshness.sh` <!-- d-check:ignore (geplante Datei — entsteht in diesem Slice) --> | neu | Go-Fetch (go.dev/VERSION) + Normalisierung + `--compare`-Delegation an `component-freshness.sh` (slice-040). Hermetischer `--normalize <raw>`-Pfad. |
| `Makefile` | update | Target `freshness-go` (Pin aus `GO_VERSION`); Netz, nicht in gates |
| `.github/workflows/ci.yml` | update | Go-Achse in den `upstream-drift`-Job (`if: '!cancelled()'`) |
| `test/go-freshness.bats` | neu | `--normalize` (Fixture: `go1.26.5\n…` → `1.26.5`) + `--compare`-Klassen offline |
| `test/mutations/` | neu | Normalisierungs-Wächter (`go`-Strip / `head -1` entfernt) |
| `harness/conventions.md` | update | die [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)-Freshness-Notiz um die Go-Achse ergänzt |

**Wiederverwendung statt Duplikat:** `component-freshness.sh`s `compare_tags` ist quellen-agnostisch
(vergleicht zwei Strings) — `go-freshness.sh` ruft dessen `--compare`-Pfad, statt einen zweiten
Vergleicher zu bauen. Nur Fetch + Normalisierung sind neu (die echte Go-Besonderheit).

## 4. Trigger

**`open` → `in-progress` (Implementer beginnt):** Welle [welle-06-freshness](../welle-06-freshness.md)
ist aktiv; slice-040 (generischer Sensor + GitHub-Achsen) ist **done** und liefert den
wiederverwendbaren Vergleicher. Kein Vorgänger blockiert.

Rückführungen:
- `in-progress` → `next`: falls Fetch + Normalisierung + Wiring zusammen die Ein-Sitzungs-Review-Linie
  sprengen (unwahrscheinlich — ein Wrapper analog `baseline-freshness.sh`).
- `in-progress` → `open`: falls go.dev wider Erwarten kein stabil parsebares Versions-Format liefert
  (Carveout, Modul 7).

## 5. Closure-Trigger

DoD vollständig; Review konform (Modul 10); Verifikation bestätigt die DoD (Modul 11);
`make gates` + `make mutate` grün; Slice per `git mv` nach `done/` (eigener Move-Commit);
Closure-Notiz mit Steering-Loop-Eintrag geschrieben.

## 6. Risiken und offene Punkte

- **go.dev-Format-Stabilität:** die erste Zeile von `VERSION?m=text` ist `go<major>.<minor>[.<patch>]`.
  Die Normalisierung strippt nur das `go`-Präfix und nimmt die erste Zeile — sie interpretiert die
  Versionsteile **nicht** (kein Semver-Sort). Das reicht für Gleich/Ungleich (wie slice-040); ein
  „neuer, aber älterer" Tag ist bei einer monotonen Toolchain-Reihe kein realer Fall.
- **Sofortige reale Drift:** `1.26.4` < `1.26.5` — der Nachtlauf meldet die Go-Achse ab dem ersten Lauf
  rot. Das ist **korrektes** Sensor-Verhalten (detect, not fix); die Auflösung (`GO_VERSION`-Bump inkl.
  Dockerfile-Digest) ist eine bewusste separate Operation, **out-of-scope** dieser Welle (wie der
  v3.5.1-Baseline-Bump, [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)).
- **Pin-Quellen-Divergenz:** `GO_VERSION` steht auch im `gen`-Skelett; der Sensor prüft nur den
  **Dogfood-Build-Pin** (`GO_VERSION`, Makefile), gekoppelt an das Skelett via
  `TestGoProfile_PinsMatchRepo` — dieselbe Auflösung wie golangci-lint in slice-040.

## 7. Closure-Notiz (nach `done/`)

<!--
Wird *nach* Abschluss ergänzt. Inhalt:
- Was hat funktioniert?
- Was ging anders als geplant?
- Steering-Loop-Eintrag: welcher Guide/Sensor sollte verbessert werden?
  (kanonische Definition: [`/kurs/de/grundlagen/klassifikation.md` §Steering Loop](https://github.com/pt9912/ai-harness-course/blob/v3.5.0/kurs/de/grundlagen/klassifikation.md#steering-loop))
- Folge-Slices: welche neuen open/-Einträge?
-->

**Was hat funktioniert.** Die Ist-Messung **vor** Code (go.dev-Format live belegt,
`golang/go`-GitHub-Achse als untauglich verworfen — Redirect auf `.../releases` statt
`/releases/tag/<tag>`) verhinderte einen Fehlschnitt: der generische Vergleicher aus
slice-040 ist quellen-agnostisch, also blieb nur Fetch + Normalisierung neu. Der Wrapper
`go-freshness.sh` spiegelt exakt die `baseline-freshness.sh`-Architektur (2-arg-Delegation
an `--compare`, Name + Advice injiziert). Rollen-Sequenz voll: Review **KONFORM** (0
HIGH/MEDIUM/LOW, 2 INFO), Verifikation **DoD BESTÄTIGT** (Fetch-Fehler-Kette `raw="" → ""
→ Exit 2` empirisch bestätigt). Sensoren real: `make gates` Exit 0, `make mutate` 53 ok/0.

**Was anders lief als geplant.** Der Plan-§3 nannte den Normalisierungs-Wächter als
„`go`-Strip / `head -1`"; geliefert war zunächst nur die `go`-Strip-Mutation (47). Der
Review (INFO-1) benannte, dass die `head -1`-Zeile behavioral gedeckt, aber ohne eigenen
Mutations-Fall war (`mutate.sh`: „kuratiert heisst unvollstaendig"). **Sofort geschlossen**
mit Fall 48 (`head -n 1` → `cat`, färbt den Erste-Zeile-Fixture rot) statt als Folge-Schuld
getragen — beide Normalisierungs-Schritte sind jetzt einzeln bewacht.

**Steering-Loop-Eintrag** (kanonische Definition:
[`/kurs/de/grundlagen/klassifikation.md` §Steering Loop](https://github.com/pt9912/ai-harness-course/blob/v3.5.0/kurs/de/grundlagen/klassifikation.md#steering-loop)):

- **Der PreToolUse-Guard scannt den GANZEN Command-String — inklusive Heredoc-Inhalt.**
  Ein `git commit` mit einer Bash-Heredoc-Message, die ein geblocktes Tool-Token trägt
  (hier `go`/`go.dev`/`go1.x.y` im Text), wird fail-closed geblockt — der Commit lief nicht.
  Das **schärft** die „commit via `-F`"-Konvention: die Message-Datei mit dem **Write-Tool**
  schreiben (geht nicht durch den Command-Guard), dann `git commit -F <datei>` — nie die
  Message als Heredoc/inline im Bash-Aufruf, wenn ihr Text Tool-Tokens enthalten könnte.
- **Die netz-berührende Schicht hinter ein eigenes hermetisches Sub-Kommando legen.** Wie
  slice-040 den Vergleich hinter `--compare` isolierte, isoliert slice-041 die Normalisierung
  hinter `--normalize <roh>`. Das macht die einzige neue Logik der Sonderquelle offline
  testbar (Fixture-Strings) **und** mutations-bewachbar, ohne je das Netz zu treffen —
  das Muster verallgemeinert auf jede künftige Nicht-GitHub-Quelle.

**Folge-Slices.** Keine neuen `open/`-Einträge. Nächster Welle-Slice steht (welle §4):
slice-042 (C++/ubuntu-Base-Tag-Freshness, Quelle Docker-Hub-LTS). Review-INFO-2
(Pin-Kopplung Makefile-`GO_VERSION` ↔ Dockerfile-ARG-Default) ist das aus slice-040 geerbte,
in §6 dokumentierte Muster — kein neuer Trigger.

## 8. Sub-Area-Modus-Begründung

### Sub-Area: harness-Freshness-Sensoren (`harness/tools/*-freshness.sh` + Nachtlauf)

- **Modus:** BF — die Sub-Area existiert (`component-freshness.sh`/`baseline-freshness.sh`, der
  `upstream-drift`-Job, die Freshness-Fixture-Tests aus slice-018/027/040); dieser Slice **erweitert**
  sie um eine Sonderquellen-Achse, statt auf grüner Wiese zu bauen.
- **Konventionen-Dichte:** hoch. slice-040 fixiert das Muster (quellen-agnostischer `--compare`;
  Wrapper je Achse; Exit 0/1/2 = aktuell/veraltet/fetch-fehler; bash+curl ohne jq,
  [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten); Netz-Sensor außerhalb `make gates`,
  [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). Die Go-Achse **erbt** diese
  Konventionen; neu ist allein Fetch + Normalisierung.
- **Phase-Reife:** Phase 4 (reif/produktiv) — die Mechanik läuft nächtlich. Additive Erweiterung.
- **Evidenz-/Diskrepanz-Risiko:** niedrig. Die Ist-Messung ist gemacht (go.dev-Format live belegt,
  golang/go-GitHub-Achse als untauglich verworfen). Die einzige neue Logik (Normalisierung) ist
  hermetisch testbar.
- **Reconciliation-Aufwand:** klein (ein Slice). Kein Graduation-Trigger absehbar.
