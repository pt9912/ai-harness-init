# Verifier-Report: slice-bats-ruempfe-erreichen-shell-lint

Rolle Verifier, Stand HEAD cfee9ab7 (Basis 0de95bfb), 2026-10-21. Gegen DoD (§2), Spec LH-QA-01 und
das Architect-Verdikt. Gemessen auf macOS (AGENTS.md 3.9: kein Normbeleg, Beleg ist die CI nach dem Push).

## Verdikte je DoD-Punkt

- **(1) Verkettung steht, Erweiterung rot gesehen: bestaetigt.**
  - `make shell-lint` -> zweiter Aufruf `bats-lint.sh` mit gepinnten Images, Exit 0: `bats-lint: OK — 50 test/*.bats`;
    `git ls-files 'test/*.bats' | wc -l` -> 50. Das Skript allein, ohne `BATS_IMAGE`/`SHELLCHECK_IMAGE`, bricht mit
    Exit 1 und der Meldung der `:?`-Pruefung ab (Pins nur ueber `make`; das ist die Zusage des Skriptkopfs).
  - Rot-Beleg (i): `cd /tmp` hinter dem ersten @test von test/guard.bats -> `make shell-lint`:
    `test/guard.bats:31:3: warning: Use 'cd ... || exit' ... [SC2164]`, danach `bats-lint: FEHLER — shellcheck ueber 50 test/*.bats meldet Befunde (Exit 1)`.
    Zeile 31 = die eingefuegte Zeile im Original (Rueck-Zuordnung auf Datei und Zeile stimmt). `git checkout --` danach, Baum sauber.
  - Rot-Beleg (ii) F-1 fail-open: Symlink ins Leere `test/{a,m,z}-dangling.bats`, einzeln: je Exit 2, Text
    `bats-preprocess scheitert an test/<x>-dangling.bats` + `der Extrakt ist unvollstaendig`; Reihenfolge unerheblich. Symlinks entfernt, `git status` sauber.
  - Pruefung des Skripts gelesen: Container beendet die Schleife erst nach der letzten Datei (`rc=1` merken), Extrakt-Anzahl wird gegen `${#dateien[@]}` gehalten, kein `:rw`.
- **(2) Bestand gruen ohne Inline-Suppression und ohne Pfad-Ausnahme: bestaetigt.**
  - `git grep -c 'shellcheck disable' -- 'test/*.bats'` -> leer; `git grep -n 'shellcheck disable' -- test harness` -> nur die Verneinung im Skriptkopf (bats-lint.sh:32); `nolint` nur in Regel-/Doku-Texten, kein Code.
  - `git ls-files | grep -i shellcheckrc` -> leer. `grep -n ':rw' harness/tools/bats-lint.sh` -> leer.
  - `git diff 0de95bfb..HEAD -- Makefile`: erster `shell-lint`-Aufruf byte-gleich (nur Kommentar und Hilfetext davor geaendert), zweiter Aufruf neu. Der erste Aufruf schloss bats nie als Pfad aus (die Ausnahme war eine Auslassung); sie ist jetzt durch den zweiten Aufruf geschlossen.
  - Die Behebung (0dec6426, 12 Dateien, +66/-57) gelesen als Stichprobe der Diff-Zeilen: `cd` -> `cd ... || return 1`, `bs='\'` -> `bs=$'\\'` (selber Wert), Subshell-`( PATH=...; f ) || st=$?` -> Praefix-Zuweisung am Funktionsaufruf (gleiche Wirkung; `make test-bats` bestaetigt). Keine entfernte Zusicherung gefunden.
  - (e) `make test-bats`: 569 ok, 0 not ok (`1..569`); `make test` komplett gruen (Go-Pakete ok). Die geaenderten Dateien messen weiter, was ihr Name sagt, soweit die Stichprobe der Diff-Zeilen und die vollstaendig gruene Suite tragen; keine Mutation je Datei gefahren.
- **(3) Zwei Mutations-Faelle: bestaetigt (ein dritter Fall zusaetzlich).**
  - `MUTATE_CASES='777-… 778-… 779-…' MUTATE_JOBS=1 make mutate`: `ok 777 -> SC2154 rot`, `ok 778 -> SC2016 rot`, `ok 779 -> SC2034 rot`; `3 ok, 0 Befund(e)`; Teillauf 3 von 765, kein Beleg-Slot. Die Ursachen sind die gepinnten (`expect:`), kein anderes Rot.
  - `make mutate-greift` -> `765 Fall/Faelle, 765 greifen, 0 Befund(e)`.
  - Grenze (Zusage-Satz) steht im Skriptkopf (bats-lint.sh:36-39) und in Fall 778; als Wirkung nicht behauptet. Bestaetigt.

## Plan-vs-Code, beide Richtungen

- Plan -> Code: alle sechs Zeilen von Plan §3 vorhanden (Makefile, Skript, test/*.bats, Fuss/--exclude im Skript, Faelle, README-Vertragszeile); `internal/emit/` und Baseline unveraendert (`git diff --stat` ohne Treffer).
- **Code ohne Plan (Planner zieht §3 nach):**
  1. `harness/tools/mutate.sh` `failure_form`: neuer Modus `shell-lint` (`\[SC[0-9]+\]`) und `mode_rank` `shell-lint`=4 — noetig, damit Faelle 777-779 `verify: shell-lint` fahren koennen.
  2. `harness/tools/mutate-auswahl.sh` `fall_gewicht` `shell-lint`=27 (Lastverteilung).
  3. `test/mutate-driver.bats`: Schleife in `failure_form`-Test um `shell-lint` erweitert (Sensor fuer 1.); Testname und `expect:` von Fall 635 umformuliert (`98bfab0b^` -> `aus dem Vorgaenger-Stand von 98bfab0b`, weil bats-Rumpf-Lint das `^`-Muster nicht trug) sowie ein Kommentar in mutate.sh. `MUTATE_CASES=635-… make mutate` -> `ok … rot` (Name und expect stimmen ueberein).
  4. Fall 779 (`SC2034`) ueber die zwei Faelle von DoD (3) hinaus; das Verdikt nennt den `:`-Teil.
  - Plan ohne Code: nichts. Die Plan-Aussage ‚Dateinamen-Rueckabbildung' ist umgesetzt (sed auf `test/`), V1 (Host teilt, kein :rw) ebenso.
- Plan-Luecke: §6 traegt drei Risiken mit Ausgang `<…>` (Skript ungetestet, Befund-Menge, SC2016-Umbau) — Planner traegt sie bei Closure ein (Verifier schliesst nicht).

## Grenzen (benannt, nicht als Wirkung belegt)

- Kein bats-Test fuer bats-lint.sh; der Exit-2-Pfad ist nur von Hand rot gesehen (Beleg oben, kein Mutations-Fall).
- Begrenzung der Ausnahme auf den bats-Aufruf nicht rot faerbbar (im Skript benannt).
- Fuss/--exclude: `status`/`output`/`lines` ohne `run` und ein versehentlich in Einzelquotes stehendes `$var` bleiben unbemerkt (im Skript benannt).
- Skript globbt `test/*.bats` statt `git ls-files`: eine untracked Datei wird mitgelesen, eine getrackte nur bei Anwesenheit; Zahl 50 stimmt zu `git ls-files` im Ist.
- macOS-Lauf kein Normbeleg; Mutations-CI-Probe (CI-Branch) nicht gefahren, kein `mutate-ergebnis.txt` gelesen.

## Befunde

Keine blockierenden. Offen fuer den Planner: §3 nachziehen (Punkte 1-4), §6-Ausgaenge, Register-Sichtung (negation-mitten…, marker-pruefung…, §8). Kein Rot-Beleg-Rest.
