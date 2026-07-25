# Review-Report: slice-047 (mutate gegen isolierte Kopie) — 2026-07-25

**Review-Art:** Code — geprüft wird der fertige Diff gegen Slice-Plan,
aktive ADRs und Konventionen (Modul 10 §Drei Review-Arten). **Nicht**
geprüft: die DoD-Abhakung (Verifier, Modul 11).

**Gegenstand:** slice-047, Commit `3bd554b` (Basis `a6c78b2`)

**Skill:** `.harness/skills/reviewer.md` @ 1.3.0 · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-5[1m] · **Datum:** 2026-07-25

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde — ohne
diese Liste ist der Lauf nicht reproduzierbar):

- Slice-Plan [`slice-047-mutate-host-isolation.md`](../plan/planning/in-progress/slice-047-mutate-host-isolation.md) (DoD §2, Plan-Tabelle §3, Risiken §6)
- aktive ADRs: [ADR-0003](../plan/adr/0003-go-native-binaries.md) (Docker-only)
- berührte IDs: [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)
- [`AGENTS.md`](../../AGENTS.md) (Hard Rules §3.1–§3.6), [`harness/conventions.md`](../../harness/conventions.md) (MR-Block, [`MR-003`](../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung), [`MR-014`](../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions))
- vorherige Findings am gleichen Modul: slice-026 F-1/F-5/F-6/F-7/N-2/N-4/NR-1/NR-2 (derselbe Treiber), slice-026 F-12 (der Auslöser dieses Slice), slice-044 F-1 (Mutations-Deckung), slice-046 (Ist-Behauptung > Code)

**Betriebsmodus:** read-only. Keine `make`-Läufe (mutierender Sensor,
Gate-Stempel/Stop-Hook), keine Host-Toolchain. Sensor-Ausgaben aus dem
Implementer-Lauf übernommen (`make gates` grün, 171 Dateien/0 Befunde ·
`make mutate` 69 ok/0, Fälle 72/73 je rot gesehen · Tree-Hash vor/nach
identisch, 3× · 2× `make gates` parallel zu laufendem `make mutate` grün),
nicht nachgefahren. Eigene Messungen: `git show/diff`, Datei-Lektüre,
`grep`, und eine isolierte `bash`-Sonde zum `cd ""`-Verhalten (F-1).

---

## Findings

Jedes Finding folgt dem **§Output-Schema des Reviewer-Skills** — der
verbindlichen Single Source of Truth. Die Felder unten sind nur
**gespiegelt** (Bequemlichkeit beim Ausfüllen), nicht neu definiert; bei
Abweichung gilt der Skill bzw. dessen Quelle
[Kurs Modul 10 §Output-Schema](https://github.com/pt9912/ai-harness-course/blob/v3.5.1/kurs/de/04-qualitaet/modul-10-review-harness.md#worked-example-eine-reviewer-skill-datei-schreiben).

<!-- Kein Fließtext, kein Lösungsvorschlag im Befund. -->

### F-1 — leeres `$WORK` lässt den Zyklus lautlos wieder auf den Host-Baum laufen

- `kategorie`: MEDIUM
- `quelle`: [`AGENTS.md`](../../AGENTS.md) Hard Rule §3.6 (Zusage > Code), [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (stilles Grün im Sensor)
- `pfad`: `harness/tools/mutate.sh:67-68` (Zusage) · `:230`, `:236`, `:242`, `:258`, `:271`, `:367` (die sechs `cd "$WORK"`-Stellen)
- `befund`: Der Kommentar auf `:68` sagt zu „run_case laeuft NIE gegen `$REPO`"; durchgesetzt wird das ausschließlich durch die Aufruf-Reihenfolge in `main()`, nicht durch eine Prüfung. `cd ""` ist in bash ein Erfolg ohne Wirkung (isoliert gemessen: Exit 0, `$PWD` unverändert), und das Arbeitsverzeichnis des Treibers ist beim Aufruf über `make mutate` genau `$REPO` — ein leeres `$WORK` ließe Backup, Sed, Sensor-Lauf, Grün-Vorlauf und Restore ohne Fehlermeldung auf dem Host-Baum arbeiten. `restore()` (`:79`) fängt genau diesen Fall mit `[ -n "$WORK" ]` ab, die sechs `cd "$WORK"`-Stellen nicht.
- `verifizierbar`: ja — ein Mutationsfall, der die `WORK`-Zuweisung in `main()` (`:336`) auf `WORK=""` dreht, müsste `make mutate` rot färben; heute deckt kein Wächter diesen Pfad ab, und die fünfte Bedingung sieht ihn per Konstruktion nicht (F-2).

### F-2 — die fünfte Bedingung erkennt den symmetrischen Rückfall auf `$REPO` nicht

- `kategorie`: MEDIUM
- `quelle`: [`AGENTS.md`](../../AGENTS.md) Hard Rule §3.6 (Ist-Behauptung > Code), [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
- `pfad`: `harness/tools/mutate.sh:380-382` (Zusage) · `:100-101`, `:383-386` (Mechanik)
- `befund`: Der Kommentar sagt „Sie faellt, sobald ein Pfad wieder gegen `$REPO` statt gegen die Kopie laeuft". Gemessen wird der Fingerabdruck nur VOR und NACH der Fall-Schleife über dieselbe Menge: laufen Sed (`:242`) und `restore()` (`:80`) gemeinsam wieder gegen `$REPO` — exakt das Verhalten vor slice-047 —, ist `host_before == host_after` und die Bedingung bleibt grün, obwohl jeder parallele Leser während des Laufs den mutierten Stand sieht (die F-12-Klasse, um derentwillen der Slice existiert). Auch der Teil-Rückfall „nur `restore -C "$REPO"`" bleibt unentdeckt, obwohl er eine zwischenzeitliche Host-Änderung an einer Zieldatei mit dem Backup-Stand der Kopie überschreibt.
- `verifizierbar`: ja — ein Mutationsfall, der in `restore()` `-C "$WORK"` auf `-C "$REPO"` dreht, ließe `make mutate` grün bleiben.

### F-3 — drei der fünf neuen Wächter ohne Mutationsfall, darunter der `.git`-Kopier-Umfang

- `kategorie`: MEDIUM
- `quelle`: [`AGENTS.md`](../../AGENTS.md) Hard Rule §3.6 („wer keinen Fall in `test/mutations/` hat, ist unbewacht")
- `pfad`: `test/mutate-driver.bats:70`, `:89`, `:124` gegen `test/mutations/72-mutate-isolation-im-repo.sh`, `test/mutations/73-mutate-fingerprint-leer.sh`
- `befund`: Der Diff liefert fünf neue bats-Wächter, aber zwei Mutationsfälle (72 → Wächter `:54`, 73 → Wächter `:107`). Ohne Fall bleiben „die Kopie traegt den Sensor-Bedarf inklusive .git" (`:70`), „der Fingerabdruck ist stabil und reagiert" (`:89`) und „der Fingerabdruck deckt die Mutations-Ziele" (`:124`). Der `.git`-Umfang ist dabei die Eigenschaft, die in genau diesem Slice schon einmal real gebrochen ist (in `harness/tools/mutate.sh:120-124` dokumentiert) und deren Bruch eine Ein-Zeilen-Mutation an `:143` wäre.
- `verifizierbar`: ja — `make mutate` meldet 69 ok/0, ohne dass eine dieser drei Zusagen je rot gesehen wurde.

### F-4 — AGENTS.md schreibt dem Fingerabdruck einen Beleg zu, den er nicht liefert

- `kategorie`: LOW
- `quelle`: [`AGENTS.md`](../../AGENTS.md) Hard Rule §3.6, Maintainability
- `pfad`: `AGENTS.md:129`
- `befund`: „der Arbeitsbaum wird nie verändert, parallele Gate-/Test-Läufe sind unbedenklich, und ein Abbruch lässt kein Residuum zurück (**der Lauf belegt das selbst per Fingerabdruck vor/nach**)" — der Vergleich steht nach der Fall-Schleife (`harness/tools/mutate.sh:383`) und wird bei einem Abbruch nie erreicht; über den Zustand *während* des Laufs sagt er ebenfalls nichts. `harness/README.md:53` formuliert dieselbe Eigenschaft enger und bleibt damit innerhalb dessen, was der Code hält.
- `verifizierbar`: nein — Doku-Aussage; die Grenze folgt aus `harness/tools/mutate.sh:380-386`.

### F-5 — Mutation 72 färbt den Wächter an einer vorgelagerten Assertion rot, nicht an der benannten Schranke

- `kategorie`: LOW
- `quelle`: [`AGENTS.md`](../../AGENTS.md) Hard Rule §3.6 („ein Test … muss die Eigenschaft messen, nicht ihre heutige Implementierung")
- `pfad`: `test/mutations/72-mutate-isolation-im-repo.sh:12` · `test/mutate-driver.bats:58-61`
- `befund`: Unter Mutation 72 verweigert `prepare_isolation` (`harness/tools/mutate.sh:136-141`) und schreibt nichts auf stdout; rot wird `[ -n "$dest" ]` (`:58`), nicht der `case "$dest" in "$REPO"/*)`-Zweig (`:59-61`), der die im Testnamen benannte Eigenschaft prüft. Dieser Zweig ist unter keinem gelisteten Fall erreichbar — dieselbe „die geprüfte Schranke wird im Szenario nicht erreicht"-Klasse, die der Sensor dem Implementer während des Baus zweimal gemeldet hat.
- `verifizierbar`: ja — die `not ok`-Zeile des bats-Laufs unter Fall 72 nennt die auslösende Assertion.

### F-6 — `host_after` ohne Diagnose-Pfad, asymmetrisch zu `host_before`

- `kategorie`: LOW
- `quelle`: Maintainability
- `pfad`: `harness/tools/mutate.sh:383` gegen `:330-334`
- `befund`: `host_before` ist per `if !` mit zwei Erklärzeilen abgesichert, `host_after` ist eine nackte Zuweisung. Scheitert die Berechnung dort — etwa weil eine `# files:`-Zieldatei während des Laufs im Host-Baum verschwindet —, beendet `set -e` `main()`, bevor „N ok, M Befund(e)" gedruckt wird: fail-closed im Exit-Code, aber ohne Meldung, welche Bedingung den Lauf beendet hat.
- `verifizierbar`: ja — ein `# files:`-Ziel während eines Laufs entfernen.

### F-7 — „einmal pro Lauf, nicht pro Fall" gilt für den Gesamtaufwand nicht mehr

- `kategorie`: LOW
- `quelle`: Maintainability, [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
- `pfad`: `harness/tools/mutate.sh:128` · `test/mutate-driver.bats:54-88`
- `befund`: Der Kommentar beziffert die Kopie mit „8,0 MB mit .git — einmal pro Lauf, nicht pro Fall". Zwei der neuen bats-Wächter rufen `prepare_isolation` selbst auf und laufen damit in JEDEM `make test`; `make test` ist die innere Schleife von `make mutate` (69 Fälle + Grün-Vorlauf). Der Baum wird je mutate-Lauf also rund 140× kopiert, nicht einmal — die Aussage gilt nur noch für den Treiber-eigenen Aufruf.
- `verifizierbar`: ja — Laufzeit von `make test` vor/nach dem Commit.

### F-8 — Lifecycle-Prosa widerspricht dem Verzeichnis

- `kategorie`: LOW
- `quelle`: Modul 5 (Lifecycle = Verzeichnis), Doku-Drift
- `pfad`: `docs/plan/planning/in-progress/roadmap.md:21` · `docs/plan/planning/done/welle-07-results.md:104`
- `befund`: Beide Stellen wurden im Link auf `in-progress/` nachgezogen, tragen im Fließtext aber weiter „(`open/`, …)". Der Zustand eines Slice IST das Verzeichnis (Slice-Kopf §Lifecycle); Link und Prosa behaupten damit verschiedene Zustände.
- `verifizierbar`: nein — `make docs-check` prüft Links und Anker, nicht die Zustands-Prosa.

### F-9 — Negativ-Assertion bindet den Wächter an die heutige Ziel-Menge

- `kategorie`: INFO
- `quelle`: Maintainability
- `pfad`: `test/mutate-driver.bats:133`
- `befund`: `! grep -q '^AGENTS.md$'` belegt „nicht der ganze Baum" über die Abwesenheit genau einer Datei; ein künftiger Fall mit `# files: AGENTS.md` färbte den Wächter rot, ohne dass die geprüfte Eigenschaft verletzt wäre. Die grep-Form selbst ist im Kommentar `:129-132` korrekt begründet (negiertes `grep -q` statt `grep -qv`, Implementierungs-Unterschiede zwischen ugrep und dem Container-grep).
- `verifizierbar`: ja

### F-10 — Anker von Fall 73 heute eindeutig, aber breit

- `kategorie`: INFO
- `quelle`: Maintainability (Re-Verankerungs-Klasse aus slice-037/slice-044)
- `pfad`: `test/mutations/73-mutate-fingerprint-leer.sh:16`
- `befund`: `sed -i 's/|| return 1/|| return 0/'` — nachgezählt genau ein Vorkommen in `harness/tools/mutate.sh:115`, die Kommentar-Zusage „kommt genau einmal vor (geprueft)" trifft heute zu. Ein zweites `|| return 1` an beliebiger Stelle würde mit-mutiert und die Mutation unspezifisch machen.
- `verifizierbar`: ja

### F-11 — Abwesenheits-Assertion kann vakuum-grün sein

- `kategorie`: INFO
- `quelle`: [`AGENTS.md`](../../AGENTS.md) Hard Rule §3.6 (Randfall), Maintainability
- `pfad`: `test/mutate-driver.bats:81`
- `befund`: `[ ! -e "$dest/.harness/state" ]` belegt den `--exclude`-Effekt nur, wenn `.harness/state/` im Quellbaum existiert; in einem frischen Klon vor dem ersten `record-gates`-Lauf existiert es nicht und die Assertion passt, ohne den Ausschluss gemessen zu haben. Im mutate-Pfad existiert das Verzeichnis immer (der Lock des laufenden Laufs liegt dort).
- `verifizierbar`: ja — `make test` auf einem frischen Klon ohne vorherigen `record-gates`.

### F-12 — Plan-Drift bestätigt (kein Finding gegen den Diff)

- `kategorie`: INFO
- `quelle`: Slice-Plan §2/§3
- `pfad`: `docs/plan/planning/in-progress/slice-047-mutate-host-isolation.md:38` und `:59` gegen `harness/conventions.md`
- `befund`: Der Plan verlangt einen Nachzug am „MR-Block zu F-12 / mutate" in `harness/conventions.md`. Nachgezählt kommt `mutate` dort nur in den CI-Absätzen vor (`:562`, `:565`, `:573`, `:601`); ein F-12-/mutate-MR-Eintrag existiert nicht. Die Plan-Drift-Meldung des Implementers trifft zu, der Nachzug liegt in `AGENTS.md:129` und `harness/README.md:53`.
- `verifizierbar`: ja — `grep -n 'mutate\|F-12' harness/conventions.md`

## Negativbefunde

<!--
Eine Zeile pro betrachtetem Bereich. Ohne diesen Block ist "keine
Findings" nicht von "nicht geprüft" unterscheidbar (Modul 10
§Reviewer berichtet auch, was er nicht gefunden hat).
-->

- geprüft, ohne Befund: **Semantik-Erhalt der vier Befund-Wege** (Plan §6) — `git show 3bd554b -- harness/tools/mutate.sh` Zeile für Zeile: (1) Mutations-Skript scheitert (`:242-246`), (2) Mutation greift nicht, je gelistete Datei einzeln (`:256-266`), (3) Sensor bleibt grün (`:273-277`), (4) rot am falschen Wächter über `failure_form` + `grep -F "$expect"` (`:287-292`). Alle vier unverändert außer dem Arbeitsverzeichnis `$REPO`→`$WORK`; kein Weg entfernt, keine Reihenfolge getauscht, keine `return`/`restore`-Kante verloren.
- geprüft, ohne Befund: **Header-Vertrag `# files:`/`# expect:`/`# verify:`** — Doppel-Kopf-Prüfung (`:197-203`), Pflichtfelder (`:214-217`), Default `verify=test` (`:213`), Zulassung ausschließlich über `failure_form` (`:219-222`, N-2), Array-Lesung statt Word-Splitting (`:225-226`): Diff-frei.
- geprüft, ohne Befund: **Grün-Vorlauf je `# verify:`-Modus** (`:355-373`) — Modus-Sammlung, Zulassungs-Prüfung vor dem Lauf (N-4) und Abbruch-Meldung unverändert; einzige Änderung ist `cd "$WORK"` statt `cd "$REPO"` (`:367`). Die Nachzieh-Wirkung ist real belegt: der Vorlauf hat den fehlenden `.git`-Umfang beim ersten Lauf gefangen.
- geprüft, ohne Befund: **`main()`-Kapselung und Sourcing-Verträglichkeit** (`:303`, `:393-395`) — der Lock steht weiter IN `main()`, `prepare_isolation`/`fingerprint_of_list`/`mutation_targets`/`target_fingerprint` sind Top-Level-Funktionen ohne Seiteneffekt beim Sourcen; `test/mutate-driver.bats` kann sie weiter über `source` erreichen (alle neun Tests tun genau das).
- geprüft, ohne Befund: **Fall-Skripte greifen die Kopie, nicht den Host** — `grep` über alle 69 `test/mutations/*.sh`: kein `dirname "$0"`, kein `BASH_SOURCE`, kein absoluter Pfad in einem `sed -i`-Ziel; alle Fälle arbeiten relativ zum cwd, den `run_case` auf `$WORK` setzt.
- geprüft, ohne Befund: **`target_fingerprint`-Fail-closed bei fehlender Datei** — `set -o pipefail` gilt in `fingerprint_of_list` (`:91`), ein `sha256sum`-Fehler propagiert über `xargs` in den Pipeline-Status; es entsteht kein Hash über eine unvollständige Menge. Der Sonderfall „leere Liste" ist zusätzlich explizit abgefangen (`:115`) und per Fall 73 rot gesehen.
- geprüft, ohne Befund: **[`MR-003`](../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)-Kollision der Kopie** — die Isolation liegt unter `mktemp -d` außerhalb des Repos (`:335-336`) und wird zusätzlich fail-closed gegen ein Ziel unter `$REPO` verteidigt (`:136-141`); der Lock liegt unter `.harness/state/`, das per `git check-ignore` bestätigt ignoriert ist. `harness/tools/working-tree-hash.sh` zählt `git ls-files --cached --others --exclude-standard` — beide Artefakte sind für den Stop-Hook-Hash unsichtbar. Kein neuer `.gitignore`-Eintrag nötig.
- geprüft, ohne Befund: **Hard Rule 3.2 (Lint-Suppression-Verbot)** — kein `# shellcheck disable`, kein `//nolint` im Diff; `harness/tools/*.sh` und `test/mutations/*.sh` liegen beide im `shell-lint`-Scope (`Makefile:93`), die neuen Fälle sind also mit-gelintet.
- geprüft, ohne Befund: **Hard Rules 3.1 / 3.3 / 3.4 / 3.5** — kein neues Gate versprochen (`make mutate` bleibt Nicht-Gate-Verify), kein `git mv` in diesem Commit (der Move lag in `a6c78b2`), keine ADR berührt, keine Schwellensenkung — die fünfte Bedingung ist eine Verschärfung und braucht darum kein ADR.
- geprüft, ohne Befund: **§3.6-Form der Mutationen 72/73** — beide sind verhaltens-, nicht kompilat-brechend (72 tauscht eine Zuweisungs-Zeichenkette, 73 einen Rückgabewert; das Skript bleibt parsebar und lauffähig); 72 vermeidet SC2016 per Doppelquote mit escaptem `$`, 73 ist dollar-frei; beide `# expect:`-Strings sind echte Teilstrings der bats-`not ok`-Zeilen, Bedingung 4 greift also am benannten Wächter.
- geprüft, ohne Befund: **Fall 73 erreicht die im Namen benannte Schranke** (der zweimal gemeldete Konstruktionsfehler) — das Fall-Verzeichnis mit einer `# expect:`-only-Datei lässt `mutation_targets` mit Exit 0 und leerer Ausgabe durchlaufen, damit ist `[ -n "$targets" ]` (`:115`) die erste greifende Schranke und nicht ein leerlaufendes Glob oder ein `pipefail`-Folgefehler. Die Reparatur trägt.
- geprüft, ohne Befund: **Isolations-Umfang gegen den realen Sensor-Bedarf** — `make test` mountet den Baum read-only ins bats-Image und baut die Go-Stage aus dem Kontext (`Makefile:48-49`); die Kopie trägt `.git` und `.harness` und deckt beide Wege. `.dockerignore` (`.git`, `.harness`) betrifft nur den Build-Kontext, nicht den bats-Mount — die neuen Wächter `[ -e "$dest/.git" ]` / `[ -d "$dest/.harness/baseline" ]` sind im Container erfüllbar und nicht vakuum-grün.
- geprüft, ohne Befund: **kein Rest-Anspruch „mutate verändert den Arbeitsbaum"** — repo-weiter `grep`: die alte Aussage steht nur noch in den historischen Review-Reports zu slice-026 (`docs/reviews/2026-07-20-*`), wo sie als Historie korrekt ist; das entfernte ACHTUNG-Echo hat keinen verwaisten Abwesenheits-Check hinterlassen (die Klasse aus dem `@@BLOCKED_SET@@`-Fall).
- geprüft, ohne Befund: **Lock-Umschreibung** (`:304-321`) — die Begründung wurde ersetzt statt ergänzt (wandernde Grenze umschreiben), die Abbruch-Meldung nennt weiter Pfad und Stale-Ausweg, `mkdir` bleibt der atomare Mutex, die Platzierung in `main()` bleibt begründet. Die neue Begründung (geteilte Docker-Tags/Build-Cache) ist gegen `Makefile:48-55` gedeckt: alle Stages taggen fest `ai-harness-init:test|lint|build`.

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 3 |
| LOW | 5 |
| INFO | 4 |

## Verdikt

**NICHT KONFORM.**

**Merge-blockierend:** ja — F-1, F-2 und F-3 sind MEDIUM und blockieren
nach Skill-Regel typischerweise. Kein HIGH: der Diff hat keinen heute
erreichbaren stillen Grün-Pfad, die Isolation greift real (Tree-Hash 3×
identisch, `make gates` 2× parallel grün), und die vier Befund-Wege sind
1:1 erhalten. Die drei MEDIUM betreffen durchweg dieselbe Klasse — die
**Zusage reicht weiter als die Messung**: `run_case` läuft „nie gegen
`$REPO`" nur kraft Aufruf-Reihenfolge (F-1), die fünfte Bedingung fällt
gerade beim vollständigen Rückfall NICHT (F-2), und drei der fünf neuen
Wächter haben kein rot gesehenes Gegenbeispiel (F-3). Das ist die
`ADR-0007`-H2-Klasse, die dieses Repo bereits zweimal eskaliert hat.

**Übergabe:** Findings gehen an die Implementation (Rückkante
Review → Plan bei Plan-Defekt). Der Report ersetzt keine
Verifikation — DoD-/Spec-Konformität prüft der Verifier separat
(Modul 11; anderes Prüf-Artefakt, anderer Eingabe-Kontext).
