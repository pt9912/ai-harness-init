# Implementation-Review slice-059 (2. Runde) — Span-Emitter in Go

**Datum:** 2026-07-29 · **Rolle:** Reviewer (Modul 10) · **Reviewer-Skill:** 1.4.0 ·
**Baseline:** v3.5.2

## Kopf-Metadaten

| Feld | Wert |
|---|---|
| **Prüfgegenstand** | Commit `01fe699` — „slice-059: Span-Emitter in Go — mit einem Gate fuer den Fehlt-Fall" |
| **Commit-Range** | `7da54f4..01fe699` = genau ein Commit |
| **Neue Dateien** | `cmd/span-emit/main.go`, `cmd/span-emit/main_test.go`, `internal/span/span.go`, `internal/span/emit.go`, `internal/span/span_test.go`, `harness/tools/span-check.sh`, `test/mutations/109-span-folgenummer-eingefroren.sh`, `test/mutations/110-span-pflichtfeld-verschwindet.sh` |
| **Entfernte Dateien** | `harness/tools/span-emit.sh`, `harness/tools/span-fields.awk`, `test/span-emit.bats` |
| **Geänderte Dateien** | `.claude/settings.json`, `Dockerfile`, `Makefile`, `harness/conventions.md` (`MR-018`), `harness/tools/artifact-copy.sh`, `test/mutations/107`, `108`, der Slice-Plan |
| **Slice-Plan** | `docs/plan/planning/in-progress/slice-059-telemetrie-erfassung-hook.md` |
| **Referenzierte aktive ADRs** | `ADR-0011` (Accepted, immutabel), `ADR-0003`, `ADR-0004` |
| **Betroffene Anforderungen** | `LH-QA-01`, `LH-QA-02`, `LH-QA-03` |
| **Hard Rules** | `AGENTS.md` §3.1, §3.2, §3.3, §3.4, §3.5, §3.6 |
| **Konventionen** | `MR-002`, `MR-003`, `MR-005`, `MR-017`, `MR-018` |
| **Vorherige Findings derselben Klasse** | `docs/reviews/2026-07-28-slice-059-impl-review.md` (7 HIGH, 5 MEDIUM, 3 LOW) und die sechs `ADR-0011`-Proposed-Runden |
| **Nicht geprüft (andere Rolle)** | DoD-Abhakung, Gate-Lauf-Bestätigung → Verifikation (Modul 11) |

**Selbst gefahrene Sensoren (nur `make`-Targets, Docker-only):** `make span-check`
(grün, Ausgabe *„Emitter vorhanden, ein Span geschrieben, Ablageort git-ignoriert"*).
Dazu Live-Messungen am realen Zustand: der Hook ist in dieser Sitzung aktiv und schreibt
Spans (`.harness/state/spans/*.jsonl`, alle `-rw-------`); das Mutations-Log
`.harness/state/mutate-slice059.log` weist `106 ok, 0 Befund(e)` mit 107–110 als
`ok … rot` aus; `git rev-parse HEAD` gegen das `commit`-Feld eines Live-Spans geprüft
(`50f398d18818` — die Ableitung inklusive Vorrang der losen Ref vor dem **veralteten**
`packed-refs`-Eintrag hält).

**Ausdrücklich NICHT gemessen** (und deshalb unten je Befund als *abgeleitet* markiert):
`make mutate` (Auftragslage: nicht erneut fahren) und einzelne Go-Testläufe — die
Host-Go-Toolchain ist per Guard geblockt (`ADR-0003`), und ein einzelner Go-Test ist
kein `make`-Target. Wo ein Befund aus dem Lesen des Codes stammt, steht das dort.

**Wiederkehrende Fehlerklasse dieses Autors** (aus sechs ADR-Runden und der ersten
Impl-Runde): *eine Abdeckung wird behauptet, die an ihrer Quelle nicht hält.* Dieser
Review hat deshalb jede „bewacht/belegt/stellt sicher"-Aussage des Diffs gegen den
Sensor gelegt, den sie nennt. Ergebnis: die Klasse ist **kleiner geworden, aber nicht
verschwunden** — drei der vier HIGH unten sind Reste genau der Befunde, die die
Commit-Message als geschlossen führt.

---

## Findings

### HIGH-1 — die Werkzeug-Namen-Liste steht nur im Code; `MR-018` verweist auf eine Liste, die es dort nicht gibt

- **Kategorie:** HIGH (Verstoß gegen eine aktive ADR; Vorgänger-HIGH-1 nur zur Hälfte
  geschlossen)
- **Quelle:** `ADR-0011` Festlegung 2 (*„die Zeilen oben sind auf konkrete Namen
  abzubilden"*), Folgepflicht 1 (*„es ist eine Strukturregel, kein
  Implementierungsdetail, und der nächste Leser muss es ohne Code finden"*),
  Folgepflicht 2
- **Pfad:** `internal/span/span.go:131-144` (die einzige Liste), Kommentar-Verweise
  `internal/span/span.go:140-141` und `:154-155`, Gegenstelle
  `harness/conventions.md:829-846` (Feldtabelle) und `:844`
- **Befund:** Die **Erfassungs-Achse** ist korrekt auf den Werkzeug-Namen umgestellt —
  das war die Code-Hälfte von HIGH-1. Die **Doku-Hälfte** ist offen: die Namen
  (`Write`, `Edit`, `MultiEdit`, `NotebookEdit`, `Read`, `Bash`, `BashOutput`) stehen
  ausschließlich in `toolClass`. `MR-018` enthält keine einzige davon, sagt aber in
  `:844` *„nur bei namentlich gelisteten Datei-Werkzeugen"* zu, und der Code verweist
  zweimal zurück auf eine „MR-018-Tabelle", die diese Zuordnung nicht führt. Der
  Vorgänger-Review hat genau diesen Satz als Teil von HIGH-1 zitiert; die
  Commit-Message führt HIGH-1 unter „geschlossen".
- **Failure-Szenario:** Ein Auswerter oder ein Folge-Slice (060/062) soll entscheiden,
  ob ein neues Werkzeug Argumente preisgeben darf. Er liest `MR-018` — die von
  `ADR-0011` Folgepflicht 1 dafür bestimmte Stelle —, findet dort *„namentlich
  gelistet"* ohne Liste, und trifft die Sicherheitsentscheidung entweder am Code
  (`internal/span/span.go`, wo sie laut ADR nicht leben soll) oder rät. Konkret: fügt
  jemand `Grep` der Gattung „Lese-Werkzeuge" hinzu, gibt es keine normative Stelle,
  an der die Erweiterung als Entscheidung erkennbar wird — der fail-closed Default
  erodiert unbemerkt.
- **Verifizierbar:** ja — `grep -n "MultiEdit\|NotebookEdit\|BashOutput" harness/conventions.md`
  ist leer (selbst gefahren, repoweit außerhalb `docs/reviews/`); kein Gate färbt das rot.

### HIGH-2 — `branch` und `commit` sind in `MR-018` **Pflicht**, tragen aber `omitempty` und fehlen im Pflichtfeld-Wächter

- **Kategorie:** HIGH (Verstoß gegen eine aktive ADR und gegen `MR-018`; §3.6-Muster im
  Sensorpfad; Vorgänger-HIGH-6 unvollständig geschlossen)
- **Quelle:** `MR-018:840` (Spalte **Pflicht**), `MR-018:860-861` (*„dann sind beide
  Felder leer und als leer erkennbar"*), `ADR-0011` Festlegung 1.5, `AGENTS.md` §3.6
- **Pfad:** `internal/span/emit.go:57-58` (`json:"branch,omitempty"` /
  `json:"commit,omitempty"`), Zusage `internal/span/emit.go:308-313`, Wächter
  `internal/span/span_test.go:416-433` (Feldliste `:425-428`)
- **Befund:** Die zwei Felder wurden als Antwort auf HIGH-6 eingeführt und in `MR-018`
  ausdrücklich als **Pflicht** markiert. Im Struct tragen sie `omitempty` — bei leerem
  Wert verschwinden sie aus der Zeile, statt leer dazustehen. Genau diese Klasse
  bewacht `TestMandatoryFieldsAlwaysPresent` („ein `omitempty` an der falschen Stelle
  liesse es lautlos verschwinden") und mutiert Fall 110 — aber die Feldliste des Tests
  führt `branch`/`commit` **nicht** auf, obwohl `MR-018` sie als Pflicht ausweist. Der
  Test läuft dabei gegen `t.TempDir()`, also gegen eine Wurzel ohne `.git`: er erzeugt
  bei jedem Lauf genau die Zeile, in der beide Felder fehlen, und meldet grün.
  Der Doc-Kommentar `emit.go:312-313` sagt für denselben Fall *„dann bleiben beide
  Felder leer, als leer erkennbar"* zu — das hält der Code nicht.
- **Failure-Szenario:** Ein Lauf in einem `git worktree` (dort ist `.git` eine **Datei**;
  das Agenten-Werkzeug dieses Repos bietet `isolation: "worktree"` an) erzeugt Spans
  ohne `branch`- und ohne `commit`-Schlüssel. Der Auswerter aus slice-060 kann
  „Branch nicht ableitbar" nicht von „Feld gab es nie" unterscheiden — der Unterschied
  zwischen *unbekannt* und *nicht vorhanden*, den die Pflicht-Spalte laut Fall 110
  gerade tragen soll. Dieselbe Zeile entsteht bei unlesbarem `.git/HEAD`; bei
  fehlender loser Ref **und** fehlendem `packed-refs`-Eintrag verschwindet `commit`
  allein, `branch` bleibt.
- **Verifizierbar:** ja — `"branch":` und `"commit":` in die Feldliste von
  `TestMandatoryFieldsAlwaysPresent` aufnehmen und `make test-go` fahren (wird rot);
  alternativ einen Span aus einem `git worktree` erzeugen. *Abgeleitet aus dem Code,
  nicht gefahren (Host-Go geblockt).*

### HIGH-3 — die stdout-Hälfte von Festlegung 6 hat kein rot gesehenes Gegenbeispiel; der Kommentar sagt eines zu

- **Kategorie:** HIGH (§3.6-Verstoß im Sicherheits-/Sensorpfad; `ADR-0011` Folgepflicht 5
  unerfüllt; Vorgänger-HIGH-5 nur zur Hälfte geschlossen)
- **Quelle:** `AGENTS.md` §3.6, `ADR-0011` Festlegung 6 Setzung 1, `ADR-0011`
  Folgepflicht 5 (*„die stdout-Setzung aus Festlegung 6 bekommt ihren Mutations-Fall"*)
- **Pfad:** `cmd/span-emit/main.go:11-17`, Mutation
  `test/mutations/107-span-klemme-entfernt.sh:19`, Wächter
  `cmd/span-emit/main_test.go:60-68`
- **Befund:** `main.go:16-17` sagt zu: *„Beides bewacht
  test/mutations/107-span-klemme-entfernt.sh gegen TestClampSurvivesBrokenPayload"* —
  „beides" meint Exit-Code **und** stdout. Mutation 107 entfernt `defer clamp()`; der
  Emitter endet dann über den Go-Panic-Pfad, und dessen Ausgabe geht auf **stderr**,
  der Exit-Code auf 2. Rot wird `TestClampSurvivesBrokenPayload` damit ausschließlich
  an seiner Exit-Code-Zusicherung (`main_test.go:62-64`); die stdout-Zusicherung
  (`:65-67`) kann unter dieser Mutation gar nicht feuern. Für die stdout-Setzung
  existiert kein Mutations-Fall — `ADR-0011` Folgepflicht 5 verlangt genau ihn und
  nennt ihn als die Hälfte, die *„ihre Zähne lautlos verliert"*. Das ist strukturell
  derselbe Befund wie HIGH-5 der Vorrunde („107 nimmt die Klemme nicht weg, behauptet
  es aber"), nur eine Ebene weiter: die Mutation greift jetzt, die Zusage über ihre
  Reichweite bleibt zu weit.
- **Failure-Szenario:** Jemand fügt dem Emitter eine Diagnose-Ausgabe auf stdout hinzu
  (`os.Stdout.Write`, `fmt.Fprintln(os.Stdout, …)`, `println`). `make test-go` bleibt
  grün, solange die Zeile nicht in den zwei Payloads der beiden Tests auftaucht;
  `make mutate` meldet weiterhin 106 ok, weil kein Fall diese Eigenschaft angreift;
  `make lint` greift nur bei `fmt.Print*` (siehe MEDIUM-4). Der Telemetrie-Hook steht
  damit wieder auf dem Entscheidungs-Kanal, gegen den Festlegung 6 konstruktiv gebaut
  ist.
- **Verifizierbar:** ja — 107 auf eine Kopie außerhalb des Repos anwenden und
  Exit-Code/stdout/stderr **getrennt** messen (die Methode, mit der die Vorrunde
  HIGH-5 belegt hat). *Abgeleitet aus dem Code und dem Panic-Verhalten der
  Go-Laufzeit, nicht selbst gefahren.*

### HIGH-4 — die Fitness-Function-Zeile „Ablageort auf einen nicht-ignorierten Pfad ziehen" hat keinen Mutations-Fall

- **Kategorie:** HIGH (Verstoß gegen eine aktive ADR — eine Zeile ihrer Fitness
  Function ist unumgesetzt und nirgends als Abweichung benannt)
- **Quelle:** `ADR-0011` Fitness Function, Zeile 3 (*„**Der Ablageort wird auf einen
  nicht-ignorierten Pfad gezogen** — der Wächter muss rot werden"*, Target
  `make mutate`), `AGENTS.md` §3.6 (*„wer keinen Fall in `test/mutations/` hat, ist
  unbewacht"*)
- **Pfad:** `test/mutations/` (106 Fälle; `grep -l "span" test/mutations/*.sh` liefert
  genau 107–110, keiner davon zieht den Ablageort), betroffene Wächter
  `internal/span/span_test.go:287-296` und `harness/tools/span-check.sh:62-63`
- **Befund:** Die ADR listet vier Mutations-Zeilen; umgesetzt sind drei (110, 108,
  109). Zeile 3 fehlt. Sie ist die Zeile, die `ADR-0011` selbst als **Ersatz** für die
  gestrichene Working-Tree-Hash-Zusage eingeführt hat (*„Was die Eigenschaft wirklich
  bewacht, ist die dritte Zeile oben"*) — sie trägt damit die `MR-003`-Kopplung
  allein. Weder `MR-018` noch die Commit-Message nennen die Auslassung.
  **Zur Fairness:** die *Eigenschaft* ist gemessen — `TestSpansLandInStateDir` prüft
  die Konstante, und `span-check.sh` misst den real geschriebenen Pfad mit
  `git check-ignore` am echten Repo (von mir gefahren, grün). Offen ist nicht die
  Eigenschaft, sondern die **Haltbarkeit ihrer zwei Wächter**.
- **Failure-Szenario:** Jemand entschärft `TestSpansLandInStateDir` (etwa indem die
  Konstanten-Zusicherung `:288-290` entfällt und nur noch „irgendeine Datei entsteht"
  geprüft wird) und passt `span-check.sh` im selben Zug auf den neuen Pfad an — beide
  Änderungen sehen lokal harmlos aus. `make mutate` meldet unverändert 106 ok, weil
  kein Fall diese Achse angreift. Danach kann der Ablageort wandern, ohne dass ein
  Sensor fällt; ein Span im getrackten Baum verschiebt den `working-tree-hash` bei
  jedem Tool-Call und der Stop-Hook blockiert sich selbst.
- **Verifizierbar:** ja — die Fitness-Function-Tabelle der ADR gegen
  `ls test/mutations/` legen (selbst gefahren: 106 Fälle, kein Ablageort-Fall).

### MEDIUM-1 — `make span-check` kann den Fehlt-Fall, den es benennt, nicht rot melden

- **Kategorie:** MEDIUM (Abdeckungslücke einer Zusage im Gate-Pfad; §3.6)
- **Quelle:** `AGENTS.md` §3.6, `LH-QA-01`
- **Pfad:** `Makefile:237-238` (`span-check: span-emit-build`),
  `harness/tools/span-check.sh:4-11` (Begründung), `:37-38` (Prüfung 1)
- **Befund:** Der Kopf des Skripts begründet das Gate mit dem **fehlenden** Binary
  (*„auf einem frischen Checkout, nach `make clean`, nach einem Wechsel der Plattform
  … Dieses Gate macht aus ihm ein rotes Gate"*). Im einzigen Aufrufpfad — `make gates`
  → `span-check` → Prerequisite `span-emit-build` — wird das Binary unmittelbar vorher
  **gebaut**. Prüfung 1 (`[ -x "$BIN" ]`) kann damit nur fehlschlagen, wenn schon der
  `docker build`/`docker cp` davor fehlgeschlagen ist, was den Lauf ohnehin abbricht.
  Das Gate *verhindert* den benannten Zustand, es *meldet* ihn nicht. Die Prüfungen 2
  und 3 sind substanziell (nicht-leerer Prüfbereich, `LH-QA-01` gewahrt) — bemängelt
  ist die Zusage, nicht das Gate.
- **Failure-Szenario:** Ein Entwickler klont frisch, arbeitet eine Sitzung lang, ohne
  `make gates` gefahren zu haben. Der Hook zeigt bei jedem Tool-Call auf ein nicht
  existierendes Binary, es entsteht kein Span — genau der stille Totalausfall, gegen
  den das Gate gebaut wurde. Kein roter Gate-Lauf meldet das, weil erst der Gate-Lauf
  selbst den Zustand behebt.
- **Verifizierbar:** ja — `rm -rf .harness/state/bin && make span-check` läuft grün
  (das Prerequisite baut neu); nur `bash harness/tools/span-check.sh .harness/state/bin/span-emit`
  **ohne** vorherigen Bau wird rot.

### MEDIUM-2 — `make gates` ist nicht mehr host-portabel: es führt jetzt ein Linux-Binary auf dem Host aus

- **Kategorie:** MEDIUM (Reproduzierbarkeits-/Betriebsrisiko, `LH-QA-02`; Hard Rule
  §3.1 „muss auf frischem Checkout laufen")
- **Quelle:** `AGENTS.md` §3.1, `ADR-0003` (Docker-only), `harness/tools/span-check.sh:25-27`
- **Pfad:** `Makefile:252` (`gates: … span-check …`), `harness/tools/span-check.sh:50`
- **Befund:** Bis zu diesem Commit bestand `make gates` aus Docker-Läufen und
  POSIX-Shell; kein Gate führte ein kompiliertes Artefakt auf dem Host aus (das taten
  nur `make artifact` und die beiden Smokes — **Nicht**-Gate-Targets). `span-check.sh`
  startet das aus dem gepinnten Linux-Image geholte Binary direkt. Der Skript-Kommentar
  benennt die Grenze („auf einem Nicht-Linux-Host laeuft es nicht"), begründet sie aber
  mit einer falschen Analogie: *„Dieselbe Grenze wie bei `make artifact` und den
  Smokes"* — die stehen nicht in `make gates`, dieses Gate schon.
- **Failure-Szenario:** Ein Maintainer auf macOS (die Plattform-Matrix `LH-QA-04` führt
  macOS als erstklassiges Ziel des Produkts) fährt `make gates`. `docker build` erzeugt
  ein linux-ELF, `[ -x ]` ist erfüllt, der Aufruf scheitert mit „exec format error", und
  das Gate meldet *„der Emitter endete mit Exit 126"*. Der Gate-Lauf ist rot ohne
  inhaltlichen Defekt; der Stop-Hook lässt keinen Abschluss zu. Die CI ist nicht
  betroffen (`ubuntu-24.04`, selbst geprüft).
- **Verifizierbar:** ja — `make gates` auf einem Nicht-Linux-Host; oder
  `file .harness/state/bin/span-emit` gegen die Host-Plattform legen.

### MEDIUM-3 — das neue Gate fehlt in beiden kanonischen Gate-Tabellen

- **Kategorie:** MEDIUM (Doku-/Vertragslücke; `AGENTS.md` §5 und §6 Schritt 7)
- **Quelle:** `AGENTS.md` §4 (Gate-Tabelle, `AGENTS.md:116-127`), `harness/README.md:40-48`
- **Pfad:** `Makefile:252` gegenüber `AGENTS.md:116-127` und `harness/README.md:40-48`
- **Befund:** `make gates` hat ein Mitglied bekommen (`span-check`). Beide Tabellen, die
  den Inhalt von `make gates` normativ auflisten — bis hin zu `comment-claims` —,
  führen es nicht. `MR-018` nennt es unter „Bewacht", das ist aber die Schema-Regel,
  nicht die Gate-Liste.
- **Failure-Szenario:** Ein Agent oder Mensch liest `AGENTS.md` §4, um zu wissen, was
  `make gates` abdeckt, und schließt daraus, dass der Emitter von keinem Gate berührt
  wird — etwa beim Zuschnitt von slice-062 (Emission) oder beim Debuggen eines roten
  `make gates` auf einem fremden Host (MEDIUM-2), dessen Ursache in der Tabelle nicht
  vorkommt.
- **Verifizierbar:** ja — `grep -n span AGENTS.md harness/README.md` ist leer (selbst
  gefahren).

### MEDIUM-4 — die `forbidigo`-Zusage greift weiter als der Linter

- **Kategorie:** MEDIUM (Spec-Treue-Lücke einer Messmethode; §3.6)
- **Quelle:** `AGENTS.md` §3.6, `ADR-0011` Festlegung 6 Setzung 1
- **Pfad:** `cmd/span-emit/main.go:13-14`, Gegenstelle `.golangci.yml` (`forbidigo.forbid`:
  genau ein Muster, `^fmt\.Print.*$`)
- **Befund:** Der Kommentar sagt zu: *„`forbidigo` (make lint) verbietet fmt.Print*
  repo-weit, haelt die Eigenschaft also auf Gate-Ebene."* Die **Eigenschaft** ist
  „stdout bleibt leer"; der Linter deckt davon eine einzige syntaktische Form ab.
  `os.Stdout.Write`, `fmt.Fprintln(os.Stdout, …)`, `fmt.Fprintf(os.Stdout, …)` und die
  eingebauten `print`/`println` passieren ihn — `fmt.Fprintln`/`Fprintf`/`Fprint` sind
  in `.golangci.yml` sogar ausdrücklich von `errcheck` ausgenommen.
- **Failure-Szenario:** Eine spätere Diagnose-Zeile `fmt.Fprintln(os.Stdout, "span: …")`
  im Emitter passiert `make lint` und `make test-go` (beide Wächter fahren nur zwei
  Payloads) und `make comment-claims`. Der Hook schreibt ab da bei jedem Tool-Call auf
  den Entscheidungs-Kanal.
- **Verifizierbar:** ja — `.golangci.yml` `forbidigo.forbid` gegen die Zusage legen;
  eine `fmt.Fprintln(os.Stdout, …)`-Zeile einfügen und `make lint` fahren (bleibt grün).

### MEDIUM-5 — zwei Emitter können dasselbe liegengebliebene Schloss brechen und beide weiterlaufen

- **Kategorie:** MEDIUM (Integritätsrisiko, `LH-QA-02`; die Doppelvergabe, die
  `ADR-0011` Folgepflicht 4 ausdrücklich als „sieht aus wie Vollständigkeit" benennt)
- **Quelle:** `ADR-0011` Folgepflicht 4, `AGENTS.md` §3.6
- **Pfad:** `internal/span/emit.go:242-257` (`acquire`), Wächter
  `internal/span/span_test.go:231-256` und `:385-403`
- **Befund:** Das Brechen eines veralteten Schlosses ist nicht atomar:
  `Stat` → „älter als 60 s" → `Remove` → `continue` → `Mkdir`. Zwei Emitter, die
  denselben veralteten Lock sehen, können beide auf „stale" entscheiden; der zweite
  `Remove` trifft dann den **frisch angelegten** Lock des ersten, und beide gelangen in
  den kritischen Abschnitt. Der Kommentar über der Funktion nennt
  `TestConcurrentEmittersGetDistinctSeq` als Wächter — dieser Test legt nie ein
  veraltetes Schloss an und kann den Pfad nicht erreichen; `TestStaleLockIsBroken`
  fährt nur einen einzigen Emitter.
- **Failure-Szenario:** Ein Emitter wird zwischen `Mkdir` und `Remove` hart getötet
  (der Fall, für den `lockStale` gebaut ist). 60 s später feuern zwei Tool-Calls
  desselben Stroms nahezu gleichzeitig; beide brechen das Schloss, beide lesen
  `nextSeq` denselben Wert und schreiben ihn — der Strom trägt eine Nummer doppelt.
  Eine Doppelvergabe erzeugt **keine** Lücke, der Leser sieht Vollständigkeit; und der
  `defer os.Remove(lock)` des ersten entfernt anschließend das Schloss des zweiten.
- **Verifizierbar:** ja — ein veraltetes Lock-Verzeichnis anlegen und n Emitter
  gleichzeitig auf denselben Strom laufen lassen, dann `seq` auf Duplikate prüfen.
  *Abgeleitet aus dem Code, nicht gefahren.*

### MEDIUM-6 — der Kommandozeilen-Kanarienvogel ist mit der bats-Fassung ersatzlos entfallen

- **Kategorie:** MEDIUM (Abdeckungslücke im Sicherheitspfad; die vom Auftrag
  ausdrücklich gesuchte „still verschwundene Zusage")
- **Quelle:** `ADR-0011` Festlegung 2 (*„Damit wandert **kein Byte fremden Inhalts** ins
  Log"*), `AGENTS.md` §3.6
- **Pfad:** entfallen: `test/span-emit.bats` Fall *„span: von einer Kommandozeile bleibt
  nur das Programm, nie die Argumente"* (in `7da54f4` Zeilen 78-84); Ersatzkandidaten
  `internal/span/span_test.go:117-150` und `:190-208`
- **Befund:** Die alte Fassung hatte einen Kanarienvogel für **Bash-Argumente**: eine
  Payload mit `curl -H AUTHORIZATION-TOKEN-XYZ …`, geprüft gegen die **geschriebene
  Span-Zeile**. In der Go-Fassung prüft `TestCommandProgramSkipsAssignments` nur
  `Derived.Program` (also den Rückgabewert einer Funktion, nicht die Zeile), und der
  verbliebene Kanarienvogel `TestNoPayloadContentReachesSpan` fährt eine
  **`Write`**-Payload. Kein Wächter misst mehr, dass die Argumente eines *gelisteten*
  Kommando-Werkzeugs nicht in der Span-Zeile landen.
- **Failure-Szenario:** Jemand nimmt für die Auswertung ein Feld `args` (oder eine
  gekürzte Kommandozeile) in `Derived`/`Span` auf — eine plausible Erweiterung, die
  `MR-018` als Optional-Zeile bekäme. `make test-go` bleibt grün: die drei
  Sicherheits-Wächter prüfen Program-Token, Write-Inhalte und unbekannte Werkzeuge, nie
  die Argumente eines bekannten. Ab dem nächsten Tool-Call steht
  `gh auth login --with-token <wert>` im Audit-Log und überlebt jede Rotation
  (Grund 1 der drei in Festlegung 2 benannten).
- **Verifizierbar:** ja — `git show 7da54f4:test/span-emit.bats` gegen
  `internal/span/span_test.go` legen; die Zusicherung „kein Argument in der Zeile"
  hat keine Entsprechung.

### MEDIUM-7 — `adr.id` als Korrelations-ID ist weder erfasst noch als Abweichung erklärt

- **Kategorie:** MEDIUM (Bezugslücke gegenüber der Regelwerk-Quelle; dieselbe Klasse wie
  Vorgänger-HIGH-6, aber schwächer belegt)
- **Quelle:** `.harness/baseline/v3.5.2/regelwerk/modul-15-observability.md`
  §Kernidee (*„Der teuerste Span trägt Korrelations-IDs (`slice.id`, `requirement.id`,
  `adr.id`, `agent.role`)"*), `ADR-0011` Festlegung 1.4/1.5
- **Pfad:** `harness/conventions.md:829-865` (Feldtabelle und die drei Abweichungen)
- **Befund:** `MR-018` führt `slice`, `requirement`, `agent_type` (als Sammelposten für
  `agent.role`) und jetzt `branch`/`commit`. `adr.id` fehlt in der Tabelle **und** in
  der Abweichungs-Liste. Es wäre auf demselben Weg ableitbar wie `requirement` — der
  `**Bezug:**`-Block eines Slices nennt seine ADR-Kennungen maschinenlesbar (slice-059
  selbst nennt `ADR-0011`, `ADR-0003`, `ADR-0004`), und `requirements()` liest genau
  diesen Block bereits. Festlegung 1.4 verlangt, Ableitbarkeit **vor** einer
  Abweichungs-Erklärung zu prüfen; 1.5 verlangt, das Nicht-Erreichbare zu begründen.
  Weder das eine noch das andere ist geschehen. **Einordnung, ehrlich:** `adr.id` steht
  in der Kernidee-Passage von Modul 15, nicht in einer der zwei Listen, die `ADR-0011`
  Festlegung 1.1 bindet — deshalb MEDIUM und nicht HIGH.
- **Failure-Szenario:** Eine Auswertung soll Kosten je Architekturentscheidung
  ausweisen („was hat ADR-0011 uns gekostet?"). Der Span trägt keinen Anker, und
  `MR-018` liest sich als vollständige Umsetzung der Korrelations-Achsen — der nächste
  Leser hält die Lücke für eine bewusste Entscheidung, die nirgends getroffen wurde.
- **Verifizierbar:** ja — `MR-018` gegen `modul-15-observability.md` §Kernidee legen.

### LOW-1 — die Abweichungs-Liste in `MR-018` ist in der Quelle `1., 3., 2.` nummeriert

- **Kategorie:** LOW (Doku-Drift)
- **Quelle:** Maintainability
- **Pfad:** `harness/conventions.md:850`, `:855`, `:862`
- **Befund:** Die neue Abweichung 3 wurde zwischen 1 und 2 eingefügt. Markdown
  renumeriert beim Rendern, die Quelle liest sich aber falsch — und `:840` verweist mit
  *„s. Abweichung 3"* auf den **zweiten** gerenderten Listenpunkt.
- **Failure-Szenario:** Ein Leser folgt dem Verweis „Abweichung 3" in der gerenderten
  Fassung und landet bei `agent_type` statt bei der PR-Nummer.
- **Verifizierbar:** ja — `sed -n '848,866p' harness/conventions.md`.

### LOW-2 — der Slice-Plan widerspricht sich nach dem Update selbst

- **Kategorie:** LOW (Doku-Drift)
- **Quelle:** `AGENTS.md` §6 Schritt 7
- **Pfad:** `docs/plan/planning/in-progress/slice-059-telemetrie-erfassung-hook.md:194-197`
  gegen `:148-149` (im selben Commit geändert)
- **Befund:** §3 wurde auf `cmd/span-emit/main.go` + `internal/span/` gezogen, §6 sagt
  weiterhin *„das Span-Skript gehört nach `harness/tools/`"*. Die Abweichung ist in der
  Commit-Message ausführlich begründet — aber nicht dort, wo der nächste Leser sie
  sucht. (Pläne sind nicht immutabel; §3.4 ist nicht berührt.)
- **Failure-Szenario:** Der Verifier (Modul 11) prüft die DoD gegen den Plan und findet
  zwei einander widersprechende Ablage-Aussagen in derselben Datei.
- **Verifizierbar:** ja — beide Stellen lesen.

### LOW-3 — `MR-005` ist nicht um die Ausnahme ergänzt

- **Kategorie:** LOW (Doku-Drift)
- **Quelle:** `MR-005` (*„Die ausführbaren Harness-Tools … liegen unter
  `harness/tools/`"*)
- **Pfad:** `harness/conventions.md:156-174`
- **Befund:** Der Emitter ist ein ausführbares Harness-Tool und liegt in `cmd/` +
  `internal/`. `MR-005` benennt diese Ausnahme nicht; `harness/tools/span-check.sh`
  liegt korrekt.
- **Failure-Szenario:** Beim Zuschnitt von slice-062 (Emission nach `tools/harness/`)
  wird `MR-005` als vollständige Ortsregel gelesen und der Emitter übersehen.
- **Verifizierbar:** ja — `MR-005` gegen den Diff legen.

### LOW-4 — die Usage-Meldung von `artifact-copy.sh` nennt den vierten Parameter nicht

- **Kategorie:** LOW (Doku-Drift)
- **Quelle:** Maintainability
- **Pfad:** `harness/tools/artifact-copy.sh:35` gegen den Kopf `:24-26`
- **Befund:** Der Kopf dokumentiert `[<quell-pfad>]`, die Fehlermeldung des Skripts
  weiterhin nur drei Parameter.
- **Failure-Szenario:** Ein Aufrufer mit falschem Quell-Pfad bekommt eine Meldung, die
  den Parameter, den er falsch gesetzt hat, gar nicht erwähnt.
- **Verifizierbar:** ja — `bash harness/tools/artifact-copy.sh` ohne Argumente.

### LOW-5 — `ADR-0011` Festlegung 3 („beim ersten Span einer Sitzung ältere Bestände entfernen") ist nicht umgesetzt und nicht als Abweichung benannt

- **Kategorie:** LOW (Umsetzungs-Drift gegen eine aktive ADR; praktisch folgenlos)
- **Quelle:** `ADR-0011` Festlegung 3 Auflage 2
- **Pfad:** `internal/span/emit.go:223-236` (`appendLine`, `O_CREATE|O_APPEND`, nie
  `O_TRUNC`)
- **Befund:** Die ADR verlangt, dass der Emitter beim ersten Span einer Sitzung ältere
  Bestände **seiner eigenen** Datei entfernt. Die Go-Fassung hängt ausschließlich an;
  einen „erster Span"-Zweig gibt es nicht. Praktisch folgenlos, weil der Strom-Name
  eine UUID trägt — genau die Beobachtung, mit der die Vorrunde denselben Zweig der
  bash-Fassung als LOW geführt hat. Neu ist nur, dass er jetzt ganz fehlt, ohne dass
  `MR-018` das als vierte Abweichung führt.
- **Failure-Szenario:** Ein Werkzeug, das Sitzungs-Kennungen wiederverwendet (oder ein
  Test/Skript mit fester `session_id`), hängt an einen fremden Altbestand an; der
  Nummernkreis läuft aus der `.seq`-Datei weiter, der Bestand mischt zwei Läufe.
- **Verifizierbar:** ja — zweimal mit derselben `session_id` emittieren und die Datei
  ansehen (selbst beobachtbar an `span-check`, das genau deshalb einen PID-Strom nutzt).

### LOW-6 — der Makefile-Kommentar vergleicht gegen die Zahl der abgelösten Fassung

- **Kategorie:** LOW (Doku-Drift)
- **Quelle:** Maintainability, `AGENTS.md` §3.6 (Zahlen sind Messungen)
- **Pfad:** `Makefile:225-230`
- **Befund:** *„gemessen: docker run 388 ms gegen 24 ms fuer den ganzen Emitter"* — die
  24 ms sind der Wert der **bash+awk**-Fassung; die Commit-Message nennt für die
  Go-Fassung 2,5 ms. Das Argument wird durch die richtige Zahl stärker, nicht schwächer.
- **Failure-Szenario:** Ein späterer Leser hält 24 ms für die Kosten des heutigen
  Emitters und leitet daraus eine falsche Marge zur 50-ms-Schwelle der ADR ab.
- **Verifizierbar:** ja — Kommentar gegen die Commit-Message legen.

### LOW-7 — `StreamName` kann zwei Ströme zusammenlegen

- **Kategorie:** LOW (latente Wartungsfalle)
- **Quelle:** `ADR-0011` Festlegung 3 Auflage 2 (*„Je (Sitzung, Agent) ein eigener
  Strom"*)
- **Pfad:** `internal/span/emit.go:167-171`
- **Befund:** Nach der Zeichen-Reduktion wird auf 120 Zeichen **gekürzt**. Zwei Paare
  (Sitzung, Agent), die sich erst jenseits davon unterscheiden, teilen sich einen Strom
  und damit einen Nummernkreis. Heute unerreichbar (UUID + Agent-ID ≈ 55 Zeichen); die
  Zusicherung des Wächters `TestStreamNameCannotEscapeDirectory` betrifft die
  Pfad-Flucht, nicht die Eindeutigkeit.
- **Failure-Szenario:** Ein Werkzeug mit längeren Kennungen (oder ein zusammengesetzter
  Agent-Name) führt zu zwei Läufen in einem Strom; die Nummern sind dann zwar dicht,
  aber die Zuordnung zum Lauf ist verloren.
- **Verifizierbar:** ja — `StreamName` mit zwei >120 Zeichen langen Kennungen aufrufen.

### LOW-8 — die Fitness-Function-Zeilen der ADR nennen als Tooling „bats", umgesetzt sind sie in Go

- **Kategorie:** LOW (Doku-Drift gegen eine immutable ADR — nicht behebbar durch
  Überschreiben, §3.4)
- **Quelle:** `ADR-0011` Fitness Function, Zeilen mit Tooling `bats (make test)`
- **Pfad:** `internal/span/span_test.go`, `cmd/span-emit/main_test.go`
- **Befund:** Drei Zeilen (Modus 0600, Klemme greift, Emitter schweigt) nennen bats als
  Tooling. Umgesetzt sind sie als Go-Tests. Das **Make-Target** (`make test`) und die
  **Regel** sind unverändert erfüllt; abweichend ist nur die Tooling-Spalte. Da die ADR
  immutabel ist, gehört die Klarstellung nach `MR-018` — dort steht sie nicht.
- **Failure-Szenario:** Jemand prüft die Fitness Function ab und sucht die Wächter in
  `test/*.bats`; `git ls-files 'test/*.bats' | xargs grep -l span` ist leer, und die
  Zeile sieht unerfüllt aus.
- **Verifizierbar:** ja — Fitness-Function-Tabelle gegen `MR-018` „Bewacht" legen.

### INFO-1 — der Emitter liest payload-gesteuerte Pfade auch außerhalb des Repos

- **Kategorie:** INFO (dokumentationswürdige, undokumentierte Annahme; Fortschreibung
  von INFO-1 der Vorrunde)
- **Quelle:** `ADR-0011` Festlegung 2 (*„im Repo zusätzlich ein Inhalts-Hash"*)
- **Pfad:** `internal/span/emit.go:121-144`
- **Befund:** Für Schreib-Werkzeuge werden `os.Stat` und `io.Copy` auf den Pfad aus der
  Payload angewandt; die einzige Prüfung ist `Mode().IsRegular()`. Der Pfad kann
  absolut und außerhalb des Arbeitsverzeichnisses liegen. Die Fläche ist gegenüber der
  Vorrunde **kleiner** geworden (Lese-Werkzeuge bekommen keinen Fingerabdruck mehr,
  MEDIUM-1 der Vorrunde ist geschlossen), und `maxHash` deckelt die Kosten — dass der
  Emitter fremde Dateien liest, ist weiterhin nirgends ausgesprochen.
- **Verifizierbar:** ja — `Write`-Payload mit `file_path` außerhalb des Repos.

### INFO-2 — zwischen zwei `make gates`-Läufen läuft am Hook ein veraltetes Binary

- **Kategorie:** INFO
- **Pfad:** `Makefile:233-238`, `.claude/settings.json:20`, `:32`
- **Befund:** Der Hook zeigt auf ein gebautes Artefakt. Wer `internal/span/` ändert und
  nicht `make gates`/`make span-check` fährt, misst weiter mit der alten Fassung. Der
  Stop-Hook erzwingt den Gate-Lauf vor dem Abschluss, also ist das Fenster begrenzt —
  aber es ist eines.
- **Verifizierbar:** ja — Quelle ändern, ohne zu bauen, und einen Span erzeugen.

### INFO-3 — vor dem ersten `make gates` erzeugt jeder Tool-Call einen Hook-Fehler

- **Kategorie:** INFO (Fortschreibung von MEDIUM-1 auf die Nutzer-Sicht)
- **Pfad:** `.claude/settings.json:20`, `:32` (Ziel unter `.harness/state/bin/`,
  gitignored)
- **Befund:** Auf einem frischen Checkout existiert das Ziel nicht; die Shell des Hooks
  endet mit 127. Fail-open bleibt gewahrt (kein blockierender Exit-Code), aber die
  Erfassung ist still weg und der Lauf zeigt bei jedem Tool-Call einen Hook-Fehler.
- **Verifizierbar:** ja — `rm -rf .harness/state/bin` und einen Tool-Call fahren.

### INFO-4 — `make comment-claims` (35/0) trägt keinen der drei Kommentar-Befunde

- **Kategorie:** INFO
- **Quelle:** `harness/tools/comment-claims.sh:19-20` (die Grenze steht im Gate-Kopf
  selbst)
- **Befund:** Das Gate prüft Nennung und Existenz des Sensors, nicht seine inhaltliche
  Deckung. HIGH-3 („Beides bewacht … 107"), MEDIUM-4 (forbidigo) und der
  `acquire`-Kommentar aus MEDIUM-5 passieren es. Keine Schwäche des Diffs — hier
  festgehalten, weil 35/0 leicht als Bestätigung der Zusagen gelesen wird.
- **Verifizierbar:** ja — der Gate-Lauf ist grün, die drei Befunde bestehen.

---

## Status der 15 Befunde der Vorrunde

Die Commit-Message führt alle 15 als geschlossen. Nachgeprüft:

| Vorrunde | Status | Beleg / Rest |
|---|---|---|
| HIGH-1 (Achse Feldname statt Werkzeugname) | **teilweise** | Code geschlossen (`toolClass`, Mutation 108 → `TestUnknownToolStaysSilent` rot im Log); Doku-Hälfte offen → **HIGH-1** |
| HIGH-2 (Wächter maß die Implementierung) | geschlossen | `TestUnknownToolStaysSilent` füttert fremde Werkzeuge **mit** `command`/`file_path` |
| HIGH-3 (Folgenummer abgeleitet) | geschlossen | eigene `.seq`-Datei, VOR dem Schreiben erhöht; Mutation 109 im Log rot |
| HIGH-4 (kein Hook-Timeout) | geschlossen | `"timeout": 5` an beiden Einträgen |
| HIGH-5 (Mutation 107 ohne Zähne) | **teilweise** | Exit-Klemme jetzt echt bewacht; stdout-Hälfte weiter unbewacht → **HIGH-3** |
| HIGH-6 (Modul-15-Pflichtfeld PR) | **teilweise** | `branch`/`commit` + erklärte Abweichung 3 vorhanden; `omitempty` an Pflichtfeldern → **HIGH-2** |
| HIGH-7 (Env-Präfix als „Programm") | geschlossen | `commandProgram` + `isAssignment`, `TestCommandProgramSkipsAssignments` |
| MEDIUM-1 (Hash für Lese-Werkzeuge) | geschlossen | `fingerprint` nur bei `classFileWrite`; `TestReadToolGetsPathOnly` |
| MEDIUM-2 (`requirement` aus ganzer Datei) | geschlossen | `requirements()` liest den `**Bezug:**`-Block; Live-Span trägt genau `LH-QA-03` |
| MEDIUM-3 (Nebenläufigkeit) | geschlossen (Rest) | Sperre um Nummer **und** Anhängen; Rest im Stale-Pfad → **MEDIUM-5** |
| MEDIUM-4 (`SPAN_DIR` setzbar) | geschlossen | `Dir` ist Konstante; `span-check` misst `git check-ignore` am realen Repo (selbst gefahren, grün) |
| MEDIUM-5 (`error`-Formen) | geschlossen | `failed()` + `TestFailedStatusFromErrorShapes`; Live-Span mit `PostToolUseFailure` trägt `"status":"error"` |
| LOW-1 (kein Aufräum-Ziel) | geschlossen | `make span-clean` |
| LOW-2 (`argc` zählt Felder) | geschlossen | `strings.Fields`, Testfall `"  ls -l"` → 1 |
| LOW-3 (`chmod` nach dem Anlegen) | geschlossen | `O_CREATE` mit `0600`; bestehender Modus wird korrigiert; `TestModeIsOwnerOnly` |

**12 von 15 vollständig, 3 zur Hälfte.** Die drei Reste sind keine neuen Fehler,
sondern jeweils die **Doku-** bzw. **Wächter-Hälfte** eines Befunds, dessen
Code-Hälfte sauber behoben ist — dieselbe Klasse, die die Vorrunde als Muster benannt
hat, nur eine Stufe kleiner.

---

## Negativbefunde (geprüft, ohne Befund)

- **Die Kern-Konstruktion aus Festlegung 6 hält.** `main()` besteht aus `defer clamp()`
  + `emit()`; `clamp()` verwirft jeden Panic und endet unbedingt in `os.Exit(0)`. Kein
  Pfad des Binaries schreibt nach stdout (gelesen: `main.go`, `span.go`, `emit.go` —
  kein `fmt`-Import in den Nicht-Test-Dateien, kein `os.Stdout`). `make span-check`
  misst beides an einer echten Payload und war grün.
- **Kein Payload-Inhalt im Span, konstruktiv.** `ToolInput` trägt genau drei Felder;
  `content`/`new_string`/`old_string`/`prompt` werden nie gelesen. `bytes`/`sha256_16`
  stammen aus `os.Stat`/`io.Copy`, nie aus der Payload. Bemängelt ist nur der fehlende
  Wächter für Bash-**Argumente** (MEDIUM-6), nicht die Eigenschaft.
- **Der fail-closed Default steht auf der richtigen Achse.** `toolClass` entscheidet am
  Werkzeug-Namen; `Task`, `Grep`, `Glob`, MCP-Werkzeuge und die leere Kennung fallen auf
  `classNone`. `TestUnknownToolStaysSilent` fährt genau die Payloads, an denen die
  Vorrunde HIGH-1 belegt hat.
- **Ableitungen samt Randfällen.** `slice` und `requirement` sind `[]string{}` und
  serialisieren als `[]` (`TestCorrelationEmptyIsRecognisable`); mehrere Slices und
  mehrere `LH-*` ergeben Listen; der `**Bezug:**`-Block begrenzt korrekt. Am Live-Span
  geprüft: `"slice":["slice-059-…"],"requirement":["LH-QA-03"]`.
- **`branch`/`commit`-Ableitung selbst ist korrekt.** Lose Ref hat Vorrang vor
  `packed-refs` — in diesem Repo real relevant: `packed-refs` führt einen **veralteten**
  `refs/heads/main`, der Live-Span trägt trotzdem den aktuellen `50f398d18818`
  (gegen `git rev-parse HEAD` gemessen). Detached HEAD und `packed-refs`-Fallback sind
  abgedeckt. Bemängelt ist nur `omitempty` (HIGH-2).
- **Modus und Strom-Trennung.** Live gemessen: alle Dateien in
  `.harness/state/spans/` stehen auf `-rw-------`, das Verzeichnis auf `700`; Haupt-
  und Subagenten-Ströme sind getrennte Dateien mit eigenem `.seq`.
- **`MR-003`/Gate-Nachweis.** `.gitignore:5` führt `.harness/state/`; `span-check`
  bestätigt mit `git check-ignore` den real geschriebenen Pfad. Das gebaute Binary
  liegt ebenfalls unter `.harness/state/` und geht nicht in den `working-tree-hash` ein.
- **`make mutate` ist nicht betroffen.** `mutate.sh` schließt `./.harness/state` aus der
  Kopie aus (Zusicherung in `test/mutate-driver.bats` unverändert); die vier neuen Fälle
  wählen über `narrow_sensor` korrekt `test-go` (Präfix `Test[A-Z]`), und alle vier
  stehen im Log als `ok … rot`. Fall 98 (Cache-Zusage) und die Artefakt-Fälle 86–90
  sind trotz der `artifact-copy.sh`-Erweiterung grün geblieben.
- **Mutations-Fälle sind fail-closed gebaut.** Alle vier `sed`-Ausdrücke sind eng an
  den heutigen Text gebunden; greift einer nicht mehr, meldet Bedingung 2 des Treibers
  einen Befund statt „Wächter intakt".
- **`AGENTS.md` §3.2.** Kein `//nolint`, kein `# shellcheck disable` in den neuen
  Dateien (repoweit gegriffen); `.golangci.yml` unverändert.
- **`AGENTS.md` §3.3.** Kein `git mv` im Diff — die bash-Fassung ist gelöscht, die
  Go-Fassung neu; git erkennt keinen Rename, es gibt also keinen zu trennenden Move.
- **`AGENTS.md` §3.4.** `git show --stat 01fe699 -- docs/plan/adr/ spec/` ist leer:
  `ADR-0011` und die Spec sind nicht angefasst.
- **`AGENTS.md` §3.5.** Keine Schwelle gesenkt, kein Modul deaktiviert; `make gates`
  wurde **erweitert**. Der Rückgang der bats-Fälle (138 → 127) ist der Umzug der elf
  `span:`-Wächter nach Go, kein Verlust.
- **`AGENTS.md` §3.1 / `LH-QA-01`.** `span-check` hat einen nicht-leeren Prüfbereich
  (Funktion + `git check-ignore`); der Fehlt-Fall selbst ist der Vorbehalt aus
  MEDIUM-1, nicht ein leerer Prüfbereich.
- **`ADR-0011` Festlegung 4 (keine Installations-Abhängigkeit).** Der Emitter ist ein
  statisch gelinktes Go-Binary ohne Laufzeit-Abhängigkeit, gebaut Docker-only im
  gepinnten Image; **kein** Container-Start je Tool-Call. Die Festlegung bindet für die
  Dogfood-Seite ohnehin nicht (Plan §3, Mechanik-Entscheidung).
- **`ADR-0011` Festlegung 5 (Emission).** `internal/emit/` ist im Diff nicht berührt;
  `grep -rn span internal/emit/` trifft nur d-checks eigenes `spans`-Modul in
  Testdaten. Das **Ob** der Emission bleibt bei slice-062 samt CR.
- **Keine Quell-Repo-Identität, keine Umzugs-Hürde.** Die neuen Dateien nennen weder
  `ai-harness-init` als Repo-Namen noch `pt9912`/`github.com` (außer dem Modulpfad im
  Import) — die Lehre aus slice-031/032/033 ist eingehalten.
- **Keine toten Verweise auf die abgelöste Fassung.** `span-emit.sh`, `span-fields.awk`
  und `span-emit.bats` kommen außerhalb von `docs/reviews/**` (doc-gate-ausgenommen)
  nirgends mehr vor.
- **`MR-017`.** Nicht berührt — er gilt für emittierte Prüfbereiche, hier wird nichts
  emittiert.
- **Der Emitter läuft real.** In dieser Sitzung liegen sechs Ströme mit vierstelligen
  Zeilenzahlen; `Read` erzeugt Spans mit `path` ohne Fingerabdruck, `Bash` mit
  `program`/`argc`, ein `PostToolUseFailure` mit `"status":"error"` — die Abdeckung
  über `matcher: ""` ist belegt, nicht behauptet.

---

## Kategorie-Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | **4** |
| MEDIUM | 7 |
| LOW | 8 |
| INFO | 4 |
| **Gesamt** | **23** |

**Verteilung nach Quelle:** `ADR-0011` Festlegung 2 / Folgepflicht 1 → HIGH-1,
MEDIUM-6 · `ADR-0011` Festlegung 1 + `MR-018` → HIGH-2, MEDIUM-7 · `ADR-0011`
Festlegung 6 / Folgepflicht 5 → HIGH-3, MEDIUM-4 · `ADR-0011` Fitness Function →
HIGH-4, LOW-8 · `ADR-0011` Folgepflicht 4 → MEDIUM-5 · `AGENTS.md` §3.1/§3.6 →
MEDIUM-1, MEDIUM-2, MEDIUM-3.

**Muster, und es hat sich verschoben.** Die Vorrunde fand sieben HIGH, davon fünf
„behauptete, aber nicht gemessene Sensorlage". Diese Runde findet vier, davon **drei
Reste genau derselben Befunde** — jeweils die Hälfte, die nicht im Code steckt: die
Werkzeug-Liste, die in `MR-018` stehen müsste (HIGH-1); das `omitempty` an einem als
Pflicht deklarierten Feld samt dem Wächter, der es nicht mit prüft (HIGH-2); die
stdout-Zusage, deren Mutations-Fall die ADR ausdrücklich verlangt (HIGH-3). Die
Code-Qualität ist deutlich gestiegen — die **Zusagen über den Code** greifen weiterhin
etwas weiter als das, was sie tragen. Das ist die dritte Wiederholung dieser Klasse
über zwei Rollen-Durchgänge und damit ein Steering-Loop-Signal: die drei falschen
Zusagen hier sind je durch **ein** Gegenbeispiel widerlegbar, das der Autor selbst
hätte formulieren können.

**Gegenläufig, und es soll benannt sein:** der Umbau auf Go hat die Fehlerfläche real
verkleinert — der Typ ersetzt eine Sonderfall-Kette, die Sperre umschließt jetzt
Nummernvergabe **und** Anhängen, der Fingerabdruck ist auf Schreib-Werkzeuge
eingeengt, der Ablageort ist eine Konstante statt einer Umgebungsvariable, und das
neue Gate misst die `MR-003`-Kopplung mit `git check-ignore` am echten Repo statt an
zwei Textstellen. Die Selbstanzeige des Fork-Bombers und der nachgemessenen
Falschaussage zur „Einhegung" in der Commit-Message ist die Sorte Ehrlichkeit, die
dieses Repo von seinen Rollen verlangt.

---

## Verdikt

**BLOCKIEREND — nicht konform.**

Vier HIGH: drei davon Verstöße gegen die **Accepted und damit immutable** `ADR-0011`
(HIGH-1 Folgepflicht 1/Festlegung 2, HIGH-2 Festlegung 1.5 + `MR-018`, HIGH-4 Fitness
Function Zeile 3), einer ein §3.6-Verstoß im Sensorpfad samt unerfüllter Folgepflicht 5
(HIGH-3). Dazu sieben MEDIUM. Nach dem Reviewer-Skill blockieren HIGH und MEDIUM
typischerweise; hier gibt es keinen Grund, davon abzuweichen.

**Der schwerste Punkt ist HIGH-2:** `branch` und `commit` sind als Antwort auf einen
HIGH der Vorrunde eingeführt, in `MR-018` als **Pflicht** markiert — und tragen
`omitempty`. Der Wächter, der genau diese Klasse bewachen soll
(`TestMandatoryFieldsAlwaysPresent`, mit eigenem Mutations-Fall 110), führt die beiden
Felder nicht in seiner Liste und läuft dabei gegen eine Wurzel ohne `.git`, erzeugt also
bei jedem Lauf genau die Zeile, in der sie fehlen, und meldet grün. Die Behebung eines
HIGH hat damit dieselbe Fehlerklasse an einer neuen Stelle eingeführt.

**Der zweitschwerste ist HIGH-1:** `ADR-0011` Folgepflicht 1 hat die Feldtabelle
ausdrücklich deshalb nach `MR-018` gelegt, weil *„der nächste Leser sie ohne Code
finden muss"*. Die sicherheitsentscheidende Hälfte — welche Werkzeug-Namen überhaupt
Argumente preisgeben dürfen — steht ausschließlich in `internal/span/span.go`, während
`MR-018` und zwei Code-Kommentare auf eine „namentlich gelistete" Tabelle verweisen,
die es nicht gibt. Genau dieser Satz war Teil des Vorrunden-HIGH-1 und wird als
geschlossen geführt.

**Nicht Gegenstand dieses Reviews** (Modul 11): ob die DoD-Punkte abgehakt sind und ob
`make gates`/`make mutate` reproduzieren. Die von mir nachgemessenen Zahlen und
Live-Beobachtungen stehen in den Negativbefunden und halten durchweg — die Befunde
oben betreffen nicht die Ehrlichkeit der Zahlen, sondern das, was die grünen Zahlen
abdecken.
