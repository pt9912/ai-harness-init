# Review slice-bats-ruempfe-erreichen-shell-lint

**Rolle:** Reviewer (frischer Kontext) · **Datum:** 2026-10-21 ·
**Diff:** Basis `0de95bfb` bis `db6e09a8` (`0dec6426`, `e637cb21`, `db6e09a8`) · **Plan:** Slice
`slice-bats-ruempfe-erreichen-shell-lint` (wellenlos, `in-progress/`) · **Verdikt-Bezug:** Architect-Verdikt
`2026-10-21-slice-bats-ruempfe-erreichen-shell-lint-architect-verdikt` (Config-Ausnahme §3.2, keine ADR),
`CO-001`.

**Summary:** 0 HIGH · 1 MEDIUM · 3 LOW · 3 INFO. Die Verkettung trägt, der Rot-Beleg ist real gesehen, beide
Mutations-Fälle sind real rot gelaufen. Offen ist ein Fail-open-Pfad im Extrakt-Schritt (F-1).

## Findings

### F-1 MEDIUM — ein scheiternder `bats-preprocess` mitten im Strom wird nicht gemeldet, die Datei gilt als geprüft
- `quelle`: Maintainability; Berührung der HIGH-Klasse *Stilles-Grün-Pfad in einem Gate-Skript* (s. Einstufung)
- `pfad`: `harness/tools/bats-lint.sh:59` (Schleife `for f in "$@"; do … bats-preprocess "$f"; done`), `:73` (Zählprüfung)
- `befund`: Der Exit-Status der Schleife ist der der **letzten** Datei; scheitert `bats-preprocess` für eine
  frühere, bleibt der Extrakt leer, der Host hängt ihm trotzdem den Fuß an, die Zählprüfung (`:73`) zählt die
  Trennzeilen und stimmt, shellcheck liest nur den Fuß — Ergebnis `OK`. Gefahren: ein baumfremder Eintrag
  `test/m-dangling.bats` (Symlink ins Leere, sortiert mitten in den Glob) → Stderr
  `bats-preprocess: line 121: test/m-dangling.bats: No such file or directory`, dann
  `bats-lint: OK — 51 test/*.bats`, make-Exit 0. Liegt der gleiche Eintrag als **letzte** Datei, bricht der Lauf
  (Exit 1) — das Verhalten hängt an der Reihenfolge.
- Einstufung: nach dem Wortlaut der Skill-Liste fällt das unter *Stilles Grün* (HIGH); ich stufe MEDIUM, weil
  der Auslöser eine unlesbare/ins Leere zeigende `test/*.bats` ist (git-geführte Dateien lesen sich im
  `:ro`-Mount, `bats-preprocess` ist ein reiner Textfilter) und kein realer Bestand ihn trägt. Der Planner/Verifier
  kann die Einstufung anheben; die Abhilfe ist am Skript, nicht am Befund zu entscheiden.
- `verifizierbar`: ja (Probe oben, Rücksetzen: Symlink entfernt, Baum sauber)
- `klasse`: Fehlerstatus einer Schleife über Eingaben geht im Gate-Skript verloren

### F-2 LOW — der Gegenstands-Kommentar von SC2016 nennt nur `$`, die Regel meldet auch Backticks
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.5 Absatz 2 (Ausnahme nennt ihren ganzen Gegenstand), §3.7
- `pfad`: `harness/tools/bats-lint.sh:20-24`
- `befund`: Der Kommentar beschreibt SC2016 als „`$` in Einzelquotes" und die Grenze als „ein versehentlich in
  Einzelquotes stehendes `$var`". Von den 60 Treffern tragen mehrere nur Backticks ohne `$` auf der Zeile
  (`test/e2e-abdeckung.bats:161`, `:352`, `test/register-ausgang.bats:41`, `test/slice-mv.bats:249`); ein
  versehentlich einfach gequotetes `` `cmd` `` wird damit ebenfalls nicht gemeldet, und das steht nicht da.
  Zahl und Dateizahl stimmen: ohne `--exclude` gefahren → 60 × SC2016 in 16 Dateien.
- `verifizierbar`: ja (Skript-Kopie ohne `--exclude`, Treffer auflisten)
- `klasse`: Ausnahme-Begründung nennt weniger als die Regel schaltet

### F-3 LOW — `mode_rank` ordnet `shell-lint` als billigsten Modus, die Messung sagt das Gegenteil
- `quelle`: Maintainability; Zusage im Kopfkommentar von `mode_rank` („Weicht die dortige Reihenfolge … ab, gehört diese Funktion nachgezogen")
- `pfad`: `harness/tools/mutate.sh:1128` (Rang 7 hinter `ci-lint`), `harness/tools/mutate-auswahl.sh:124` (Gewicht 40)
- `befund`: Der Lauf von 777/778 misst `shell-lint` mit Mittel 27,46 s (`mutate: Zeit je Sensor`); die Rang-Zusage
  stellt ihn hinter `ci-lint` (Fall-Kosten dort Sekundenbruchteile). Die zwei Tabellen widersprechen sich
  zusätzlich: Gewicht 40 liegt über `test-bats` (25) und `ci-lint` (10), der Rang darunter. Wirkung nur auf
  die Verteilung (LPT-Reihenfolge), nicht auf ein Urteil.
- `verifizierbar`: ja (`MUTATE_CASES=… make mutate`, Zeile `Zeit je Sensor`)
- `klasse`: Kosten-Rang und Messung auseinander

### F-4 LOW — Änderungen außerhalb der Plan-Tabelle §3
- `quelle`: Plan §3; [`AGENTS.md`](../../AGENTS.md) §3.10 (Abnahme schreibt der Planner)
- `pfad`: `harness/tools/mutate.sh` (`failure_form`, `mode_rank`), `harness/tools/mutate-auswahl.sh` (`fall_gewicht`), `test/mutate-driver.bats` (Schleife), `test/mutations/635-…sh` (Pin des Titels)
- `befund`: §3 nennt diese Dateien nicht; sie folgen aus DoD (3) (AGENTS.md §3.8-Absatz: ein Fall ist nur für eine
  Stufe mit `failure_form()`-Muster zulässig) und sind in sich stimmig: Muster `\[SC[0-9]+\]` färbt nur die
  gcc-Ausgabe des bats-Aufrufs (der erste Aufruf nutzt das Standardformat ohne `[SCnnnn]`, der Grün-Vorlauf blieb
  grün), `# expect:`-Pin 635 und Kommentar in `mutate.sh` tragen den gleichen neuen Titel, der Treiber meldet
  `make -n shell-lint` wegen `bash harness/tools/bats-lint.sh` als nicht selbstgenügsam und fährt den Modus
  seriell (fail-closed, wie vorgesehen). Die Plan-Tabelle ist nicht nachgeführt; kein Test hält `mode_rank` oder
  `fall_gewicht` (Bestand, `grep` in `test/*.bats` → 0 Treffer).
- `verifizierbar`: nein
- `klasse`: Folgeänderung am Treiber nicht in der Plan-Tabelle

### F-5 INFO — der Fuß-Teil `: "$status" …` hat keinen Mutations-Fall, Fall 777 bindet nur die Deklaration
- `pfad`: `harness/tools/bats-lint.sh:15-17` (Zusage „Der `:`-Teil verhindert SC2034"), `test/mutations/777-bats-lint-ohne-fuss.sh`
- `befund`: Bruchprobe: Fuß ohne `:`-Teil → 84 × SC2034, `make shell-lint` rot (Gate hält es), aber kein
  Mutations-Fall führt diese Teil-Zusage; Fall 777 ersetzt den ganzen Fuß und erwartet SC2154. Fuß ohne `output`
  → 42 × SC2154 (gebunden durch 777 nur als Gesamtmutation). Fuß ohne `lines` → 2 × SC2154 (nur zwei Dateien
  verwenden `lines`).
- `verifizierbar`: ja
- `klasse`: mehrteilige Zusage ohne Mutations-Deckung je Teil

### F-6 INFO — für `bats-lint.sh` selbst existiert weder ein bats-Fall noch ein Eintrag im Kopf, dass keiner existiert
- `pfad`: `harness/tools/bats-lint.sh` (Fehlerzweige `:51`, `:73`, `:84-88`), Plan §3 Zeile 2 (nannte „zwei bats-Fälle")
- `befund`: Die Fehlerklassen (keine Dateien → Exit 2, Extrakt-Zahl ≠ Datei-Zahl → Exit 2, shellcheck-Exit
  weitergereicht) sind ungetestet; der Kopf nennt als Lücke nur den Kommentar-gegen-Flags-Wächter und die
  nicht rot färbbare Begrenzung, nicht das Fehlen jedes Tests am Skript. Über `make` endet jede Variante mit
  make-Exit 2 (`make: *** [shell-lint] Error 1|2`); der Kopf sagt keinen Exit-Satz zu, §3.6 (Exit-Satz) ist
  nicht berührt. Die Zählprüfung (`:73`) fängt den Fall aus F-1 nicht, weil die Trennzeile je Datei immer
  gedruckt wird.
- `verifizierbar`: ja
- `klasse`: Gate-Skript ohne eigenen Test, Lücke nicht am Ort benannt

### F-7 INFO — Zusatz-Grenzen am Ort ehrlich, eine fehlt
- `pfad`: `harness/tools/bats-lint.sh:23-30`
- `befund`: Benannt sind: `status`/`output`/`lines` ohne `run` unbemerkt, versehentliches `$var` in Einzelquotes
  unbemerkt, Begrenzung auf den bats-Aufruf nicht rot färbbar. Nicht benannt: der Fuß schaltet SC2154 für diese
  drei Namen auch in Hilfsfunktionen außerhalb jedes `@test`, und die Backtick-Form (F-2).
- `verifizierbar`: nein
- `klasse`: Ausnahme-Grenze unvollständig

## Geprüft, ohne Befund

- **Container-Aufruf:** beide `docker run` mit `:ro`, erster zusätzlich `--network none`, Pins nur als Umgebung
  (`:?`-Prüfung, kein zweiter Pin im Skript); `git grep` auf `-v …:rw` → 0.
- **Teilung/Fuß:** Fuß steht hinter jedem Extrakt; Zeilennummern des Originals stimmen (alle 60 SC2016-Zeilen
  gegen die Originale gelesen, Rot-Probe unten bildet die eingefügte Zeile 31 exakt ab); Rück-Mapping auf
  `test/<name>.bats` gesehen.
- **Rot-Beleg real (Schwerpunkt 5):** `cd /tmp` unter dem ersten `@test` von `test/guard.bats` → `make shell-lint`
  rot: `test/guard.bats:31:3: warning: Use 'cd ... || exit' … [SC2164]`, `bats-lint: FEHLER … (Exit 1)`,
  `make: *** [shell-lint] Error 1`; per `git checkout --` zurückgesetzt, Baum sauber.
- **Mutations-Fälle 777/778:** `make mutate-greift` → `764 Fall/Faelle, 764 greifen, 0 Befund(e)`;
  `MUTATE_CASES='777-bats-lint-ohne-fuss 778-bats-lint-ohne-exclude-sc2016' MUTATE_JOBS=1 make mutate` →
  `ok 777 -> SC2154 rot`, `ok 778 -> SC2016 rot`, `2 ok, 0 Befund(e)`; `# expect:` pinnt die Ursache, `# verify:
  shell-lint` gesetzt, sed-Anker greifen im Quell-Bestand (MR-071). Mutations-CI-Probe (`mutate-auswahl` →
  Branch) nicht gefahren.
- **Behebungen 0dec6426 (Schwerpunkt 2):** keine Suppression (`git grep 'shellcheck disable' -- test harness …`
  trifft nur den Satz im Skriptkopf, der sie verneint; `nolint` nur in `.golangci.yml` als Verbotstext); die
  PATH-Präfix-Umbauten in `test/slice-mv.bats` messen weiter (die Stubs `sed`/`cat` wirken: Status 2 ist erwartet
  und tritt ein), `SHA256SUMS.neu` + `mv` hält die Datei-Reihenfolge der Prüfsummen, `tr -s '[:blank:]'` liefert
  nach `sed '/^$/d'` dieselben Tokens, `bs=$'\\'` ist ein Backslash, `cd … || return 1` ändert nichts am Erfolgspfad.
  Einzeln gefahren: `make test-bats BATS_TARGET=test/slice-mv.bats`, `…baseline-verify.bats`,
  `…gate-nachweis-kante.bats` → ohne `not ok`. Der Titel-Umbau stimmt zwischen `test/mutate-driver.bats`, Fall 635
  und dem Kommentar in `mutate.sh`.
- **Makefile (Schwerpunkt 7):** der erste Aufruf ist byte-gleich, der zweite folgt nach ihm; `make shell-lint`
  endet bei Befund mit make-Exit 2 (Rezept-Fehler), bei Grün mit `bats-lint: OK — 50 test/*.bats`.
- **Docker-only/Host (Schwerpunkt 6):** nur `bash`/`awk`/`sed`/`find`/`wc`/`tr` auf dem Host, `docker` für beide
  Images; keine neue Host-Toolchain.
- **Ehrlichkeit lokal (Schwerpunkt 9):** alle Läufe auf macOS (Darwin) mit GNU-sed im PATH und Docker Desktop —
  das ist kein Normbeleg im Sinn von AGENTS.md §3.9; Belegt ist der Lauf mit gepinntem Image, nicht die
  Linux-CI.

## Sensoren

Gefahren (engste): `make shell-lint` (rot/grün), `make mutate-greift`, `make mutate` (777/778), drei
`make test-bats BATS_TARGET=…`. `make gates` einmal am Ende nach dem Report-Commit (Ausgabe im Handoff).
