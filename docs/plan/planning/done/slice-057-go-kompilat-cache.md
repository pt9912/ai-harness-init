# Slice slice-057: Der Go-Kompilat-Cache wird geteilt — die Test-Ergebnisse nicht

> **Vehikel-Wechsel (2026-07-27, während der Umsetzung).** Geplant war ein
> BuildKit-`--mount=type=cache`; geliefert ist eine **Vorwärm-Stufe** im Dockerfile.
> Das Ziel dieses Slice ist unverändert — *Übersetzung teilen, Ergebnisse nicht* —,
> das Mittel nicht. Warum, steht in §5a und in der Closure-Notiz; die DoD-Punkte
> unten nennen noch das geplante Mittel und werden gegen die **Eigenschaft**
> abgenommen, nicht gegen das Wort „Cache-Mount".

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

- [x] **(1) Der Kompilat-Cache wird geteilt, die Ergebnisse nicht.** Die `test`-Stufe bekommt
  `--mount=type=cache` auf `GOCACHE` **und** `-count=1`. Beleg für beides getrennt: ein zweiter
  Build übersetzt nachweislich weniger (Zeit), **und** die Tests laufen nachweislich erneut — im
  Ausgabe-Text steht **kein** `(cached)`.
- [x] **(2) `-count=1` ist bewacht.** Ein `test/mutations/`-Fall entfernt es und muss rot werden.
  Ohne diesen Wächter wäre die Regression **still**: der Lauf bliebe schnell und grün und meldete
  gecachte Ergebnisse als bestandene Tests — die gefährlichste Form, weil sie wie ein Erfolg
  aussieht.
- [x] **(3) Vorher/Nachher gemessen, unter denselben Bedingungen wie in slice-056** (allein auf dem
  Docker-Daemon, Gates vorher grün): `make mutate` als Ganzes **und** `make test-go` einzeln,
  jeweils zweimal hintereinander (der zweite Lauf zeigt den Cache-Effekt). Alle Zahlen in die
  Closure-Notiz; bleibt der Gewinn aus, ist das ein Befund und der Umbau wird zurückgenommen.
- [x] `make gates` grün, `make mutate` ohne Befund.
- [x] Doku-Update: die `mutate`/`test`-Beschreibung in [`AGENTS.md`](../../../../AGENTS.md) §4 und
  [`harness/README.md`](../../../../harness/README.md) nennt Cache und `-count=1`.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.

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

## 5a. Messreihe zum verworfenen Vehikel

Damit ein späterer Anlauf sie nicht wiederholt: der geplante `--mount=type=cache` wurde
**gemessen und ausgeschlossen**. Der Lauf schreibt **2060** Cache-Einträge an den Mount-Pfad,
der nächste Build startet bei **0**. Vier Erklärungen, vier Widerlegungen:

| Hypothese | Messung | Ergebnis |
|---|---|---|
| Cache-Mounts persistieren hier nicht | busybox-Probe, mehrere Builds | **widerlegt** — 3 → 4 → 5 → 6 Dateien |
| `--no-cache-filter` verwirft den Mount | dieselbe Probe **mit** dem Flag | **widerlegt** — 5 → 6 |
| Die abgeleitete Cache-**ID** wechselt je Build | Build mit explizitem `id=` | **widerlegt** — weiterhin 0 |
| Der Mount ist gar nicht aktiv | Geräte-Nummer + `/proc/mounts` **im** Build | **widerlegt** — eigenes Dateisystem (`66308` gegen `133`), ein Mount-Eintrag |

Die Ursache liegt unterhalb dieser vier Ebenen und ist **offen**. Für dieses Repo ist sie
folgenlos: die Vorwärm-Stufe liefert dasselbe Ziel ohne den Mount.

**Eine Korrektur an der eigenen Beweisführung**, weil sie sonst als Methode durchginge:
zwischenzeitlich stand hier „`go test` schreibt in den Mount — ja". Gezählt wurden Dateien **am
Pfad**, und das unterscheidet einen aktiven Mount nicht von einer Overlay-Schicht. Erst die
Geräte-Nummer entschied es.

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

**Was funktioniert hat.**

| | vorher | nachher |
|---|---|---|
| `make test-go` | 7,6 / 7,2 s | **3,1 s** (erster Lauf 9,8 s inkl. Vorwärmen) |
| `make mutate` | 10m54s / 93 Fälle | **7m18s / 94 Fälle** |
| `(cached)` im Testlauf | 0 | **0** |

Über beide Laufzeit-Slices: **19m01s → 10m54s → 7m18s** (−62 %), bei 92 → 94 Fällen. Der Gewinn ist
nicht durch übersprungene Arbeit erkauft — `(cached)` kommt nicht vor, und der Mutations-Lauf meldet
jeden Wächter unverändert als rot gefärbt.

**Was anders lief als geplant — das Vehikel.** Der geplante Cache-Mount ist hier **aktiv**, reicht
seinen Inhalt aber nicht an den nächsten Build weiter; vier Erklärungen wurden gemessen und
widerlegt (§5a). Der Slice stand vor der Rückführung nach `open`. Der Wechsel auf eine
**Vorwärm-Stufe** kam als **Nutzer-Vorschlag** („können wir nicht eine weitere Stage einbauen?") —
und trug sofort: die Standardbibliothek wird einmal in eine Image-Schicht übersetzt, und Schichten
cacht Docker hier belegbar (die `deps`-Stufe meldet seit jeher `CACHED`).

**Steering-Loop-Eintrag: wenn ein Mechanismus nicht liefert, prüfe erst, ob er überhaupt greift —
und trenne dabei Messgröße von Schlussfolgerung.** Ich habe früh gezählt, wie viele Dateien am
Mount-Pfad liegen, und daraus „der Mount wird beschrieben" geschlossen. Diese Zählung kann einen
aktiven Mount nicht von einer Overlay-Schicht unterscheiden; erst die Geräte-Nummer im laufenden
Build entschied es. Die Frage des Nutzers („wird der Cache gemountet?") war genau die fehlende.
**Merksatz:** eine Messung, die zwei Zustände nicht trennen kann, ist kein Beleg — auch wenn ihre
Zahlen plausibel aussehen.

**Zweiter Eintrag: ein Umbau, der eine bauartbedingte Sicherheit aufhebt, schuldet im selben Zug
den Wächter.** Vor diesem Slice war „die Tests sind wirklich gelaufen" ohne Zutun wahr — jeder Build
startete mit kaltem Cache. Jetzt trägt `-count=1` die Zusage. Ohne ihn bliebe der Lauf schnell und
grün und meldete gecachte Ergebnisse als bestandene Tests: eine Regression, die wie ein Erfolg
aussieht. Deshalb zwei bats-Fälle und Mutation 98, nicht später, sondern mit dem Umbau.

**Folge-Slices.** `lint` und `build` erben weiterhin direkt von `deps` und übersetzen die
Standardbibliothek je Lauf neu — für `make gates` ein realer, ungenutzter Rest (Review-F-4), für
den Mutations-Sensor irrelevant. Eigener Zuschnitt, wenn der Bedarf gemessen ist.

## 8. Sub-Area-Modus-Begründung

**Alle berührten Sub-Areas GF** (siehe Kurs Modul 5 §Worked Mini-Example): die Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md) führt `*` (gesamtes Repo) als
**Greenfield**. Der Vollblock entfällt damit laut Template.
