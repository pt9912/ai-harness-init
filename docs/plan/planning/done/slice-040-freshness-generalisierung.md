# Slice slice-040: Freshness-Generalisierung + GitHub-Release-Achsen (golangci-lint · d-check)

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.0/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-06-freshness](../welle-06-freshness.md).

**Bezug:** [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) (Freshness-Achse), [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (Netz-Sensor **nicht** in gates), [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (bash+curl, kein jq/node).

**Autor:** ai-harness-init-Team (pt9912). **Datum:** 2026-07-23.

---

## 1. Ziel

Die `releases/latest`-Freshness-Mechanik aus `baseline-freshness.sh` wird zu einem
**parametrierten** Komponenten-Sensor verallgemeinert; **golangci-lint** und **d-check**
bekommen je eine Freshness-Achse (gepinnte Version vs. upstream `releases/latest`),
verdrahtet in den nächtlichen `upstream-drift`-Job — read-only, außerhalb `make gates`.

## 2. Definition of Done

- [x] **Generischer Sensor** (`harness/tools/component-freshness.sh` <!-- d-check:ignore (geplante Datei — entsteht in diesem Slice) -->): parametriert über
  `name · pinned · releases-latest-url`, mit hermetischem `--compare <pinned> <latest>`-Pfad
  (netzlos testbar), bash+curl+coreutils ohne jq/node ([`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)). `baseline-freshness.sh`
  nutzt ihn (kein dupliziertes fetch/compare).
- [x] **golangci-lint-Achse:** Make-Target vergleicht den gepinnten `GOLANGCI_LINT_VERSION`
  (kanonische Quelle benannt) gegen `golangci/golangci-lint` `releases/latest`.
- [x] **d-check-Achse:** Make-Target vergleicht den gepinnten d-check-Tag (aus `DCHECK_IMAGE`
  in [`d-check.mk`](../../../../d-check.mk)) gegen `pt9912/d-check` `releases/latest`.
- [x] **Nachtlauf verdrahtet:** beide Achsen (+ die bestehende baseline-Achse) im
  `upstream-drift`-Job (`schedule`), je mit `if: '!cancelled()'` (alle Achsen laufen, auch
  wenn eine rot meldet) — belegt im Workflow-Diff. **Nicht** in `make gates` (offline-grün,
  [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- [x] `make gates` grün: die `--compare`-Fixture-Tests (aktuell / veraltet / fetch-fehler)
  je Achse laufen **offline**.
- [x] `make mutate` grün: eine Mutation, die den Vergleicher bricht (z. B. veraltet↔aktuell
  invertiert oder der leere-latest-Zweig entfernt), färbt einen Fixture-Test rot.
- [x] Doku: `make help`-Zeilen + `harness/conventions.md`-Freshness-Notiz nachziehen, falls
  neue öffentliche Targets.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

Die Ist-Messung vor Code steht aus (der Implementer verfeinert). Grober Datei-Plan:

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness/tools/component-freshness.sh` <!-- d-check:ignore (geplante Datei — entsteht in diesem Slice) --> | neu | generische `(name, pinned, releases-latest-url)`-Mechanik (fetch-latest-tag + compare + `--compare`), aus `baseline-freshness.sh` extrahiert |
| `harness/tools/baseline-freshness.sh` | refactor | ruft den generischen Sensor (kein dupliziertes fetch/compare); Verhalten + Exit-Codes unverändert |
| `Makefile` | update | Targets `freshness-golangci` / `freshness-dcheck` (+ ggf. Sammel-Target); Pin je aus seiner kanonischen Quelle extrahieren |
| `.github/workflows/ci.yml` | update | die zwei neuen Achsen in den `upstream-drift`-Job (`if: '!cancelled()'`) |
| Freshness-Fixture-Test (bats, wie baseline-freshness) | update | `--compare`-Semantik je Achse offline |
| `test/mutations/` | neu | Vergleicher-Wächter (veraltet↔aktuell / leerer-latest-Zweig) |

**Kanonische Pin-Quelle je Achse (vor Code klären):** golangci-lint hängt an
`ARG GOLANGCI_LINT_VERSION` (`Dockerfile`) **und** `golangciVersion` (`internal/gen/golang.go`,
für das emittierte Skelett) — der Sensor muss die **eine** benennen, gegen die er prüft
(sonst driftet er gegen den echten Build-Pin). d-check: der Tag in `DCHECK_IMAGE` (`d-check.mk`).

## 4. Trigger

**`next` → `in-progress` (Implementer beginnt):** Welle [welle-06-freshness](../welle-06-freshness.md)
ist aktiv (Trigger v3.5.1-Drift gefeuert); dieser Slice ist der erste der Welle. Kein
Vorgänger-Slice blockiert (die Mechanik existiert aus slice-018/027).

Rückführungen:
- `in-progress` → `next`: falls die drei Achsen zusammen über eine Ein-Sitzungs-Review-Linie
  gehen (dann golangci-lint und d-check auf zwei Slices trennen).
- `in-progress` → `open`: falls eine Upstream-Quelle wider Erwarten kein `releases/latest`
  mit Tag liefert (Carveout, Modul 7).

## 5. Closure-Trigger

DoD vollständig; Review konform (Modul 10); Verifikation bestätigt die DoD (Modul 11);
`make gates` + `make mutate` grün; Slice per `git mv` nach `done/` (eigener Move-Commit);
Closure-Notiz mit Steering-Loop-Eintrag geschrieben.

## 6. Risiken und offene Punkte

- **Pin-Quellen-Divergenz:** golangci-lint ist an zwei Stellen gepinnt (Root-`Dockerfile` +
  `gen`-Skelett) — der Sensor darf nur **eine** als Wahrheit nehmen, sonst meldet er Drift,
  wo keine ist. Vor Code die kanonische Quelle festlegen (analog `TestGoProfile_PinsMatchRepo`,
  das die zwei Go-Pins bereits koppelt).
- **Netz-Flakiness im Nachtlauf:** ein Fetch-Fehler ist Exit 2 (**kein** Veraltet-Urteil,
  wie `baseline-freshness`) — der Job wird rot, aber die Semantik unterscheidet Drift von
  Netzfehler. Das muss der `--compare`-Fixture-Test festhalten.
- **Kein Auto-Bump:** der Sensor meldet nur; die Auflösung bleibt [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)-Handarbeit
  (Out-of-Scope, s. Welle §6).

## 7. Closure-Notiz (nach `done/`)

<!--
Wird *nach* Abschluss ergänzt. Inhalt:
- Was hat funktioniert?
- Was ging anders als geplant?
- Steering-Loop-Eintrag: welcher Guide/Sensor sollte verbessert werden?
  (kanonische Definition: [`/kurs/de/grundlagen/klassifikation.md` §Steering Loop](https://github.com/pt9912/ai-harness-course/blob/v3.5.0/kurs/de/grundlagen/klassifikation.md#steering-loop))
- Folge-Slices: welche neuen open/-Einträge?
-->

**Was hat funktioniert.** Die Verallgemeinerung war eine additive Extraktion, kein
Neubau: die `releases/latest`-Mechanik wanderte 1:1 in `component-freshness.sh`,
`baseline-freshness.sh` wurde zum dünnen Wrapper. Der **bestehende**
`test/baseline-freshness.bats` blieb ohne Änderung grün — der Wrapper hält die 2-arg
`--compare`-Schnittstelle und schreibt Output, dessen Substrings (`aktuell` / `VERALTET`
/ `FETCH-FEHLER` / die Tags) der Alt-Test greppt. So diente der unveränderte Alt-Test als
Regressions-Anker für die Verhaltens-Erhaltung. golangci-lint-Pin kanonisch geklärt:
`GOLANGCI_LINT_VERSION` (Makefile) = der Build-Arg, den `make lint` reicht — der Sensor
liest dieselbe Quelle, kann also nicht gegen den echten Build-Pin driften (Plan-§6-Risiko
vermieden, kein neuer Kopplungstest nötig). Rollen-Sequenz voll durchlaufen: Review
**KONFORM** (0 HIGH/MEDIUM/LOW, 3 INFO), Verifikation **DoD BESTÄTIGT**; Sensoren real:
`make gates` Exit 0, `make mutate` 51 ok / 0 Befunde (Fall 46 rot gesehen).

**Was anders lief als geplant.** Der Plan listete „Freshness-Fixture-Test (bats)" als
*Update* der bestehenden Datei; tatsächlich war eine **neue** `test/component-freshness.bats`
richtig (der generische Sensor ist ein neues Artefakt; der Alt-Test bewacht weiter den
Wrapper). Kein Sammel-Target gebaut (YAGNI: der Nachtlauf verdrahtet jede Achse einzeln,
`if: '!cancelled()'`). Review-INFO-1 bei Closure aufgelöst: ein Makefile-Kommentar sagte
„kein zweiter Pin" zu, während weitere golangci-lint-Pins existieren — auf das eingeschränkt,
was gilt (der *Sensor* liest eine Quelle; weitere Pins existieren, Advice nennt sie).

**Steering-Loop-Eintrag** (kanonische Definition:
[`/kurs/de/grundlagen/klassifikation.md` §Steering Loop](https://github.com/pt9912/ai-harness-course/blob/v3.5.0/kurs/de/grundlagen/klassifikation.md#steering-loop)):

- **Neuer Sensor-Fall (`test/mutations/46`): erste Mutation mit literalem `$` im
  sed-Muster → SC2016.** `shell-lint` (in `make gates`) deckt `test/mutations/*.sh` mit;
  ein `sed 's/… "$var" …/…/'` mit `$` in Single-Quotes löst SC2016 aus (die Seds sind
  bewusst SC2016-clean, gemessen mehrfach). **Regel für künftige Mutations-Autoren:** das
  Ersetz-Muster auf einen **`$`-freien, eindeutigen Substring** der Zielzeile ankern
  (hier `latest" = "`), nicht auf die volle `$var`-tragende Bedingung. Ein Muster mit `$`
  ist entweder shellcheck-rot oder braucht eine Suppression — beides unnötig, wenn ein
  eindeutiger `$`-freier Anker existiert.
- **Wiederkehr der Doc-Overclaim-Klasse (§3.6):** ein neu geschriebener Makefile-Kommentar
  überschritt erneut, was der Code hält („kein zweiter Pin"). Vom Review als INFO gefangen,
  bei Closure präzisiert. Die Klasse „Zusage weiter als Abdeckung" tritt bei **neuen
  begründenden Kommentaren** auf, nicht nur bei Test-Namen — beim Schreiben eines
  „warum-kanonisch"-Kommentars zuerst prüfen, was der Code *nicht* garantiert.

**Folge-Slices.** Keine neuen `open/`-Einträge aus diesem Slice. Nächste Welle-Slices stehen
schon (welle §4): slice-041 (Go-Version-Freshness, Quelle go.dev/dl), slice-042 (ubuntu-Base-Tag).
Review-INFO-2 (d-check Tag↔Digest) und INFO-3 (make-Exit-Kollaps 1↔2) sind **dokumentiert-akzeptiert**,
kein Trigger (green-before-extend): eine Exit-Code-Verzweigung Drift↔Fetch-Fehler wird erst
geschnitten, wenn der Nachtlauf real auf den Code verzweigen muss.

## 8. Sub-Area-Modus-Begründung

**Status:** Pflicht-Sektion bei mindestens einer berührten Sub-Area
in BF oder Hybrid. Bei reinem GF genügt der Hinweis
*"alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked
Mini-Example)"*. Optional bei reinem Refactor ohne neue
Sub-Area-Berührung. Die vier Pflichtkriterien (Konventionen-Dichte ·
Phase-Reife · Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand)
stehen in
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Worked Mini-Example](https://github.com/pt9912/ai-harness-course/blob/v3.5.0/kurs/de/02-planung/modul-05-planning-harness.md#worked-mini-example-bootstrap-modus-pro-sub-area-für-einen-slice-begründen).

**Vorgelagert — Sub-Area-Wahl prüfen:** Jede hier aufgeführte Sub-Area
muss das Inklusionskriterium erfüllen (drei Achsen, Schwelle ≥ 2; siehe
[`/kurs/de/grundlagen/konventionen.md` §Was ist eine Sub-Area?](https://github.com/pt9912/ai-harness-course/blob/v3.5.0/kurs/de/grundlagen/konventionen.md#was-ist-eine-sub-area)).
Zu grobe Sub-Areas (*"Backend"*) vorher ausdifferenzieren — sonst trägt
der Begründungsblock mehrere Modi vermischt.

### Sub-Area: harness-Freshness-Sensoren (`harness/tools/*-freshness.sh` + Nachtlauf)

- **Modus:** BF — die Sub-Area existiert (`baseline-freshness.sh`, der `upstream-drift`-Job,
  die Freshness-Fixture-Tests aus slice-018/027); dieser Slice **verallgemeinert** sie, statt
  auf grüner Wiese zu bauen.
- **Konventionen-Dichte:** hoch. `baseline-freshness.sh` fixiert das Muster (getrennter
  `--compare`-Pfad für netzlose Tests; Exit 0/1/2 = aktuell/veraltet/fetch-fehler; bash+curl
  ohne jq, [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)); der Nachtlauf trennt Netz-Sensoren von `make gates`
  ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). Der neue Sensor muss diese Konventionen **erben**, nicht neu erfinden.
- **Phase-Reife:** Phase 4 (reif/produktiv) — die Mechanik läuft nächtlich in CI. Die
  Verallgemeinerung ist eine additive Extraktion, kein Neubau.
- **Evidenz-/Diskrepanz-Risiko:** niedrig-mittel. Die Inventur kann sichtbar machen, dass
  eine Komponente an **mehreren** Stellen gepinnt ist (golangci-lint: Root-`Dockerfile` +
  `gen`-Skelett) — der Sensor muss die kanonische Quelle wählen, sonst meldet er Falsch-Drift.
- **Reconciliation-Aufwand:** klein (ein Slice). Graduation-Trigger zu einem Folge-Slice:
  falls golangci-lint + d-check zusammen die Review-Linie sprengen, auf zwei Slices trennen.
