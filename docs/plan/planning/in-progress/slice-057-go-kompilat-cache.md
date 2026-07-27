# Slice slice-057: Der Go-Kompilat-Cache wird geteilt — die Test-Ergebnisse nicht

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (reaktive Wartung, Fortsetzung von slice-056 — Hebel B; die drei
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)-Schnittfragen
antworten alle „nein").

**Bezug:** [`AGENTS.md`](../../../../AGENTS.md) §3.6 (`make mutate` ist der Sensor zu dieser Regel)
und §3.1 (kein Gate, das weniger prüft, als es meldet),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (ein
grünes `make test`, das Ergebnisse aus dem Cache meldet, wäre genau der stille Gate-Fall),
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (der Cache darf die
Ausgabe nicht beeinflussen), [`ADR-0003`](../../adr/0003-go-native-binaries.md) (Docker-only).

**Autor:** ai-harness-init-Team (pt9912). **Datum:** 2026-07-27.

---

## 1. Ziel

Die **Übersetzung** wird zwischen Builds geteilt, die **Test-Ausführung** nicht: ein
BuildKit-Cache-Mount auf `GOCACHE` **plus `-count=1`**. Der zweite Teil ist keine Beigabe — ohne
ihn cachte `go test` auch Ergebnisse, und „die Tests sind wirklich gelaufen" wäre nicht mehr wahr.

## 2. Definition of Done

- [ ] **(1) Der Kompilat-Cache wird geteilt, die Ergebnisse nicht.** Die `test`-Stufe bekommt
  `--mount=type=cache` auf `GOCACHE` **und** `-count=1`. Beleg für beides getrennt: ein zweiter
  Build übersetzt nachweislich weniger (Zeit), **und** die Tests laufen nachweislich erneut — im
  Ausgabe-Text steht **kein** `(cached)`.
- [ ] **(2) `-count=1` ist bewacht.** Ein `test/mutations/`-Fall entfernt es und muss rot werden.
  Ohne diesen Wächter wäre die Regression **still**: der Lauf bliebe schnell und grün und meldete
  gecachte Ergebnisse als bestandene Tests — die gefährlichste Form, weil sie wie ein Erfolg
  aussieht.
- [ ] **(3) Vorher/Nachher gemessen, unter denselben Bedingungen wie in slice-056** (allein auf dem
  Docker-Daemon, Gates vorher grün): `make mutate` als Ganzes **und** `make test-go` einzeln,
  jeweils zweimal hintereinander (der zweite Lauf zeigt den Cache-Effekt). Alle Zahlen in die
  Closure-Notiz; bleibt der Gewinn aus, ist das ein Befund und der Umbau wird zurückgenommen.
- [ ] `make gates` grün, `make mutate` ohne Befund.
- [ ] Doku-Update: die `mutate`/`test`-Beschreibung in [`AGENTS.md`](../../../../AGENTS.md) §4 und
  [`harness/README.md`](../../../../harness/README.md) nennt Cache und `-count=1`.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

**Ist-Messung (2026-07-27, live):**

| # | Aussage | Kommando / Beleg |
|---|---|---|
| 1 | Nach slice-056 fahren noch **60** Fälle die Go-Stufe | Schleife über `test/mutations/*.sh` mit `narrow_sensor` → 60 × `test-go` |
| 2 | Ein `test`-Build dauert **~5,9 s**, davon **0,33 s** Test-Ausführung | Lauf-Log der `test`-Stufe: `#13 DONE 5.9s` gegen die Summe der `ok`-Zeilen (0,025 + 0,023 + 0,034 + 0,249 + 0,003) |
| 3 | Der Kompilat-Cache überlebt keinen Build | Dockerfile: `GOCACHE` nur als `ENV`; die `deps`-Stufe füllt per `go mod download` nur `GOMODCACHE` (lädt, übersetzt nicht), und `COPY . .` invalidiert die Schicht bei jeder Mutation |
| 4 | `--no-cache-filter test` ist **nicht** der Verschwender, sondern die Zusage | `grep -n "no-cache-filter" Makefile` — es erzwingt den echten Lauf; genau diese Zusage muss `-count=1` künftig tragen |

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `Dockerfile` (`test`-Stufe) | update | `RUN --mount=type=cache,target=/root/.cache/go-build … go test -count=1 ./...` |
| `test/mutations/` | neu | ein Fall entfernt `-count=1` und muss rot werden |
| `test/` (bats) | update/neu | der Wächter braucht einen Sensor, den die Mutation röten kann: eine Prüfung, dass die `test`-Stufe `-count=1` trägt |
| [`AGENTS.md`](../../../../AGENTS.md), [`harness/README.md`](../../../../harness/README.md) | update | Cache und `-count=1` benennen |
| `Makefile` | **voraussichtlich unberührt** | `--no-cache-filter test` bleibt; es erzwingt die Schicht-Neuausführung, `-count=1` die Test-Neuausführung — zwei verschiedene Ebenen |

## 4. Trigger

**`open` → `in-progress`:** [slice-056](../done/slice-056-mutate-laufzeit.md) liegt in `done/` —
Hebel A ist gemessen (19m01s → 10m54s), und was übrig bleibt, ist der Übersetzungsanteil der 60
Go-Fälle. Erst jetzt misst sich B sauber: solange die bats-Fälle noch Go-Builds bezahlten,
überlagerte das jeden Cache-Effekt.

Rückführungen:

- `in-progress` → `next`: falls der Cache-Mount weitere Stufen betrifft (`lint`, `build` haben
  dieselbe Struktur) — dann trennt ein Re-Slice die `test`-Stufe von den übrigen.
- `in-progress` → `open`: falls die Messung zeigt, dass der Cache im Mutations-Fall kaum greift
  (jede Mutation ändert eine Datei; wieviel dadurch neu übersetzt wird, ist **nicht** vorab bekannt).
  Dann wird der Umbau **zurückgenommen** und die Messung als Befund abgelegt — ein Cache, der nichts
  spart, ist zusätzliche Fläche ohne Gegenwert.

## 5. Closure-Trigger

DoD vollständig; Review konform (Modul 10) mit ausgestelltem Verdikt; Verifikation bestätigt die
DoD (Modul 11) — **insbesondere, dass kein `(cached)` im Testlauf steht**; `make gates` und
`make mutate` grün; `git mv` nach `done/` (eigener Move-Commit, Link-Reconciliation im
Folge-Commit); Closure-Notiz mit allen Zahlen und einem Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **Das eigentliche Risiko ist ein grüner Lauf, der nichts ausgeführt hat.** Ein warmer `GOCACHE`
  lässt `go test` unveränderte Pakete mit `(cached)` überspringen. Für den Mutations-Lauf wäre das
  sogar semantisch vertretbar (was sich nicht geändert hat, kann die Mutation nicht röten) — für
  `make gates` ist es das **nicht**: dort ist die Zusage „die Tests sind gelaufen". `-count=1`
  trennt beides sauber, und DoD (2) bewacht es.
- **Wieviel der Cache im Mutations-Fall wirklich spart, ist offen.** Jede Mutation ändert eine
  Datei; Pakete, die davon abhängen, werden neu übersetzt. Der Gewinn kann deutlich unter dem
  Zwei-Lauf-Vergleich („zweiter Build derselben Quellen") liegen. Deshalb misst DoD (3) den
  **Mutations-Lauf** und nicht nur zwei aufeinanderfolgende Builds.
- **Cache-Mounts sind Zustand außerhalb des Repos.** Ein voller oder korrupter BuildKit-Cache darf
  das Ergebnis nie verändern — nur die Dauer ([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)).
  Ein Lauf mit leerem Cache muss dasselbe Ergebnis liefern; das gehört in die Verifikation.
- **`--no-cache-filter test` bleibt.** Es erzwingt, dass die Schicht neu **ausgeführt** wird;
  `-count=1`, dass die Tests neu **laufen**. Wer eines für redundant hält, entfernt die falsche
  Hälfte — der Mutations-Fall aus DoD (2) ist die Antwort darauf.
- **Kein Carveout absehbar.** Greift der Cache nicht, wird zurückgebaut statt gelockert.

## 7. Closure-Notiz (nach `done/`)

<!--
Wird *nach* Abschluss ergänzt. Inhalt:
- Was hat funktioniert?
- Was ging anders als geplant?
- Steering-Loop-Eintrag: welcher Guide/Sensor sollte verbessert werden?
  (kanonische Definition: [`/kurs/de/grundlagen/klassifikation.md` §Steering Loop](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/grundlagen/klassifikation.md#steering-loop))
- Folge-Slices: welche neuen open/-Einträge?
-->

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

**Alle berührten Sub-Areas GF** (siehe Kurs Modul 5 §Worked Mini-Example): die Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md) führt `*` (gesamtes Repo) als
**Greenfield**. Der Vollblock entfällt damit laut Template.
