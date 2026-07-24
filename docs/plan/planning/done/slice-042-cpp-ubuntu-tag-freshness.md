# Slice slice-042: C++/ubuntu-Base-Tag-Freshness (Sonderquelle Docker Hub, LTS)

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.0/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-06-freshness](welle-06-freshness.md).

**Bezug:** [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) (Freshness-Achse), [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (Netz-Sensor **nicht** in gates), [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (bash+curl, kein jq/node).

**Autor:** ai-harness-init-Team (pt9912). **Datum:** 2026-07-24.

---

## 1. Ziel

Der ubuntu-Base-Tag des emittierten C++-Skeletts bekommt eine Freshness-Achse: der
gepinnte `DefaultCppVersion` wird gegen das aktuelle **LTS** von **Docker Hub** verglichen,
verdrahtet in den nächtlichen `upstream-drift`-Job — read-only, außerhalb `make gates`.
Docker Hub ist eine **Sonderquelle** (weder GitHub noch go.dev): der Vergleicher aus
slice-040 wird wiederverwendet, neu ist Fetch + **LTS-Extraktion**. Damit ist jede
gepinnte Achse der Welle abgedeckt (welle-06 schließt nach diesem Slice).

## 2. Definition of Done

- [x] **Docker-Hub-Fetch + Wrapper** (`harness/tools/cpp-freshness.sh` <!-- d-check:ignore (geplante Datei — entsteht in diesem Slice) -->): holt die
  ubuntu-Tags von `https://hub.docker.com/v2/repositories/library/ubuntu/tags/?page_size=100`,
  **extrahiert das aktuelle LTS** (höchstes `NN.04` mit **geradem** `NN`; `23.04`/`25.04` sind
  Nicht-LTS-Interims und werden ausgefiltert) und ruft für den Vergleich
  `component-freshness.sh --compare` (kein dupliziertes compare). bash+curl+coreutils+awk,
  **kein jq/node** ([`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)).
- [x] **Hermetischer `--latest-lts <roh>`-Pfad**: die LTS-Extraktion (Tag-Liste → höchstes
  gerades `NN.04`) ist netzlos mit Fixture-Strings testbar, getrennt vom Fetch (analog
  `--normalize`/`--compare` aus slice-040/041).
- [x] **Make-Target `freshness-cpp`:** extrahiert den gepinnten `DefaultCppVersion` aus
  [`internal/gen/cpp.go`](../../../../internal/gen/cpp.go) (kanonische Quelle; leer → Exit 2, kein Falsch-Urteil) und
  vergleicht ihn gegen das Docker-Hub-LTS.
- [x] **Nachtlauf verdrahtet:** die cpp-Achse im `upstream-drift`-Job
  ([`.github/workflows/upstream-drift.yml`](../../../../.github/workflows/upstream-drift.yml)), mit `if: '!cancelled()'`. **Nicht** in
  `make gates` (offline-grün, [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- [x] `make gates` grün: die `--latest-lts`- + `--compare`-Fixture-Tests (LTS-Filter /
  Interim-Ausschluss / max / leer / aktuell / veraltet / fetch-fehler) laufen **offline**.
- [x] `make mutate` grün: eine Mutation, die den LTS-Filter bricht (gerade↔ungerade), färbt
  einen Fixture-Test rot (Fixture mit Interim > höchstem LTS als Fänger).
- [x] Doku: `make help`-Zeile + `harness/conventions.md`-Freshness-Notiz um die cpp/Docker-Hub-Achse.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

**Ist-Messung (2026-07-24, live belegt):** `DefaultCppVersion = "24.04"` ([`internal/gen/cpp.go`](../../../../internal/gen/cpp.go),
kanonisch — der ubuntu-Base-Tag des emittierten C++-Skeletts; **kein** Dogfood-Build-Pin, dies
Repo baut kein C++). Docker Hub `library/ubuntu` `NN.04`-Tags: `20.04, 22.04, 24.04, 25.04, 26.04`.
**LTS = gerades Jahr + `.04`** (20/22/24/26.04); `23.04`/`25.04` sind Nicht-LTS-Interims. Latest LTS
= `26.04` > gepinnt `24.04` → der Sensor meldet ab Tag 1 real Drift (korrekt, detect-not-fix; die
Auflösung = `DefaultCppVersion`-Bump, out-of-scope, s. §6).

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness/tools/cpp-freshness.sh` <!-- d-check:ignore (geplante Datei — entsteht in diesem Slice) --> | neu | Docker-Hub-Fetch + LTS-Extraktion (gerades `NN.04`, max) + `--compare`-Delegation an `component-freshness.sh`. Hermetischer `--latest-lts <roh>`-Pfad. |
| `Makefile` | update | Target `freshness-cpp`: Pin per `sed` aus `cpp.go`, dann Wrapper. Netz, nicht in gates |
| `.github/workflows/upstream-drift.yml` | update | cpp-Achse in den `upstream-drift`-Job (`if: '!cancelled()'`) |
| `test/cpp-freshness.bats` | neu | `--latest-lts` (Fixtures: Interim-Ausschluss, max, leer) + `--compare`-Klassen offline |
| `test/mutations/` | neu | LTS-Filter-Wächter (gerade↔ungerade), Fixture mit Interim > höchstem LTS |
| `harness/conventions.md` | update | die [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)-Freshness-Notiz um die cpp/Docker-Hub-Achse ergänzt |

**Wiederverwendung statt Duplikat:** `component-freshness.sh`s `compare_tags` ist quellen-agnostisch
— `cpp-freshness.sh` ruft dessen `--compare`-Pfad. Neu sind allein Docker-Hub-Fetch und die
LTS-Extraktion (die eigentliche Docker-Hub-Besonderheit).

**LTS-Extraktion (Kern):** aus dem rohen Tags-Text `"name":"NN.04"` grep'en → `NN.04` → mit
`awk -F.` auf gerades `NN` filtern (LTS) → `sort -V | tail -1` (höchstes). Kein jq — grep/awk/sort
auf dem JSON-Text ([`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)).

## 4. Trigger

**`open` → `in-progress` (Implementer beginnt):** Welle [welle-06-freshness](welle-06-freshness.md)
ist aktiv; slice-040 (generischer Vergleicher) und slice-041 (Sonderquellen-Wrapper-Muster) sind
**done**. Kein Vorgänger blockiert; letzter Welle-Slice.

Rückführungen:
- `in-progress` → `next`: falls Fetch + LTS-Extraktion + Pin-Extraktion + Wiring zusammen die
  Ein-Sitzungs-Review-Linie sprengen (dann LTS-Logik und Pin-Extraktion trennen).
- `in-progress` → `open`: falls Docker Hub kein stabil parsebares Tag-Format liefert (Carveout, Modul 7).

## 5. Closure-Trigger

DoD vollständig; Review konform (Modul 10); Verifikation bestätigt die DoD (Modul 11);
`make gates` + `make mutate` grün; Slice per `git mv` nach `done/` (eigener Move-Commit);
Closure-Notiz mit Steering-Loop-Eintrag. **Danach: welle-06-Closure** (alle drei Slices done).

## 6. Risiken und offene Punkte

- **LTS-Regel-Robustheit:** „gerades Jahr + `.04`" ist die etablierte ubuntu-LTS-Konvention
  (20/22/24/26.04). Interims (`.10`, ungerades `.04`) werden ausgefiltert. Der Vergleich ist
  Gleich/Ungleich auf dem höchsten LTS (kein „neuer, aber älterer" bei einer monotonen Reihe).
- **Docker-Hub-Pagination:** `page_size=100`, Default-Ordering (`last_updated` desc) — die aktiven
  LTS-Tags stehen auf Seite 1 (live belegt: 20/22/24/25/26.04 alle da). Ein LTS auf einer Folgeseite
  ist unrealistisch (ein neu erschienenes LTS ist frisch aktualisiert → Seite 1). Dokumentierte Grenze.
- **Sofortige reale Drift:** `24.04` < `26.04` — der Nachtlauf meldet die cpp-Achse ab dem ersten
  Lauf rot. Korrektes detect-not-fix; die Auflösung (`DefaultCppVersion`-Bump) ist eine bewusste
  separate Operation, **out-of-scope** ([`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)-Klasse, wie der Baseline-/Go-Bump).
- **Pin-Extraktion aus Go-Quelle:** `DefaultCppVersion` ist ein Go-Konstant, kein Makefile-Var —
  der `sed`-Extrakt ist Wiring (wie die go.dev-URL bei slice-041), leer → Exit 2 als Schutz.

## 7. Closure-Notiz (nach `done/`)

<!--
Wird *nach* Abschluss ergänzt. Inhalt:
- Was hat funktioniert?
- Was ging anders als geplant?
- Steering-Loop-Eintrag: welcher Guide/Sensor sollte verbessert werden?
  (kanonische Definition: [`/kurs/de/grundlagen/klassifikation.md` §Steering Loop](https://github.com/pt9912/ai-harness-course/blob/v3.5.0/kurs/de/grundlagen/klassifikation.md#steering-loop))
- Folge-Slices: welche neuen open/-Einträge?
-->

**Was hat funktioniert.** Die dritte Sonderquelle fügte sich ins Muster: der
quellen-agnostische Vergleicher (slice-040) + das hermetische Sub-Kommando (slice-041,
hier `--latest-lts`) trugen unverändert; neu war nur Docker-Hub-Fetch + LTS-Extraktion.
Der **Fänger-Fixture** (`FIX_INTERIM` = 25.04/24.04/22.04 → erwartet **24.04**) bewacht die
eigentliche Docker-Hub-Besonderheit — dass ein numerisch höheres **Nicht-LTS-Interim**
(25.04) das echte LTS (24.04) nicht schlagen darf; ohne den Gerade-Jahr-Filter fiele der
Test. Real gegen Docker Hub belegt: LTS = 26.04 (25.04 live vorhanden, korrekt ausgefiltert),
gepinnt 24.04 → VERALTET (detect-not-fix). **Damit deckt der Nachtlauf jede versions-gepinnte
Komponente ab** — welle-06 ist inhaltlich komplett.

**Was anders lief als geplant.** **Beide** nachgelagerten Rollen (Review MEDIUM-1, Verifier
DoD-3) fanden **dasselbe** Finding: der Leer-Pin-Pfad nutzte `${CPP_PINNED:?}` (Exit 1 =
VERALTET-Klasse), während der von diesem Slice **neu hinzugefügte** Header-Satz („Exit 2 …
auch: kein gepinnter Wert") und die DoD Exit 2 zusagen. Gefixt: expliziter Leer-Check vor dem
Fetch → Exit 2 (kann-nicht-urteilen), + eigener Fixture-Test + Mutation 50. Nebenher fiel im
mutate-Lauf ein **Go-Bump-Nachhall** auf (Mutation 18 hardcodete den alten Pin-String → BEFUND
nach 1.26.4→1.26.5), separat generisch re-verankert (`736dbf7`).

**Steering-Loop-Eintrag** (kanonische Definition:
[`/kurs/de/grundlagen/klassifikation.md` §Steering Loop](https://github.com/pt9912/ai-harness-course/blob/v3.5.0/kurs/de/grundlagen/klassifikation.md#steering-loop)):

- **Ein NEU hinzugefügter Contract-Satz braucht sofort seine rot gesehene Gegenprobe (§3.6).**
  Der Slice erweiterte den Datei-Header um „Exit 2 auch: kein gepinnter Wert" — eine *neue*
  Zusage —, ohne dass der Code sie hielt (`${VAR:?}` = Exit 1) und ohne Test. Die §3.6-Klasse
  „Zusage weiter als Abdeckung" tritt genau dort auf, wo ein Kommentar **mehr** verspricht als
  die Schwester-Datei (`go-freshness.sh` erhob den Anspruch bewusst nicht). Regel: wer einen
  Contract-Kommentar **verschärft**, liefert im selben Zug Code + Test + Mutation, sonst ist der
  Kommentar eine Halb-Zusage. **Zwei unabhängige Rollen fingen es** — erneut der Beleg für die
  Kontext-Trennung der Rollen.
- **Ein Pin-Bump muss `make mutate` nachziehen, nicht nur `make gates`.** Der Go-Bump lief nur
  gegen `gates`; wert-hardcodende Mutationen (Fall 18) veralteten still und flogen erst im
  nächsten `mutate`-Lauf auf. `gates` enthält `mutate` bewusst **nicht** (mutiert den Baum) —
  darum gehört zu jedem Wert-Bump ein expliziter `make mutate`-Lauf in die Pre-completion.

**Folge-Slices.** Keine neuen `open/`-Einträge. **welle-06 ist bereit zur Closure** (alle drei
Slices 040/041/042 done, jede Achse im Nachtlauf verdrahtet). Offen als bewusste
[`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)-Folgeoperationen (out-of-scope, vom Sensor **gemeldet**): Baseline-Bump v3.5.1
und ubuntu-LTS-Bump 24.04→26.04.

## 8. Sub-Area-Modus-Begründung

### Sub-Area: harness-Freshness-Sensoren (`harness/tools/*-freshness.sh` + Nachtlauf)

- **Modus:** BF — die Sub-Area existiert (`component-freshness.sh`, `baseline-`/`go-freshness.sh`, der
  `upstream-drift`-Job, die Freshness-Fixture-Tests aus slice-018/027/040/041); dieser Slice
  **erweitert** sie um die dritte Sonderquellen-Achse.
- **Konventionen-Dichte:** hoch. slice-040/041 fixieren das Muster (quellen-agnostischer `--compare`;
  Wrapper je Achse; hermetisches Sub-Kommando für die neue Logik; Exit 0/1/2; bash+curl ohne jq,
  [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten); Netz-Sensor außerhalb `make gates`,
  [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). Neu ist allein Fetch + LTS-Extraktion.
- **Phase-Reife:** Phase 4 (reif/produktiv). Additive Erweiterung.
- **Evidenz-/Diskrepanz-Risiko:** niedrig-mittel. Die Ist-Messung ist gemacht (Docker-Hub-Format +
  LTS-Regel live belegt). Die neue Logik (LTS-Filter) ist hermetisch testbar; der Fänger-Fixture
  (Interim > höchstem LTS) bewacht die gerade↔ungerade-Regel.
- **Reconciliation-Aufwand:** klein (ein Slice). Graduation-Trigger: falls Fetch + LTS + Pin-Extraktion
  die Review-Linie sprengen, LTS-Logik von der Pin-Extraktion trennen.
