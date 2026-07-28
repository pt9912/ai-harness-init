# Review-Report: ADR-0011 (Proposed, **Runde 5**) — Telemetrie-Erfassung, Policy für Agenten-Spans — 2026-07-28

**Review-Art:** **Proposed-Review einer ADR, fünfte Runde** — geprüft wird die **vierte
Überarbeitung** einer noch nicht angenommenen Entscheidung ([`AGENTS.md`](../../AGENTS.md) §3.4
greift erst ab *Accepted*). Kein Produktiv-Diff. **Nicht** geprüft: Code, DoD-Abhakung (Modul 11,
getrennter Kontext, anderes Prüf-Artefakt).

**Leitfrage dieser Runde — zweigeteilt.** (1) *Was hat die fünfte Fassung neu eingebaut?* Die
Eingriffe sind diesmal: zusammengeführte Regel 1.4/1.5 · Randfälle der Ableitung · fail-closed
Default-Zeile für unbekannte Werkzeuge · kein Inhalts-Hash auf der emittierten Ebene · Aufräumen
nur der eigenen Datei · Nummernkreis je (Sitzung, Agent) · vier neue Fitness-Function-Zeilen ·
Folgepflicht 5 · korrigierte Aggregations-Aussage · Bedrohungsmodell mit benannter Lücke.
(2) *Konvergiert das — ist noch etwas blockierend?* **Ergebnis vorab:** ja, es konvergiert, und
Runde 4 hatte recht — die **Entscheidung** ist in keinem Punkt strittig, auch nach dieser Runde
nicht. Was blockiert, sind **zwei Defekte an genau der Stelle, die Runde 4 als schwerste benannt
hat**: der Reparatur-Absatz zu R4-1 stellt eine Behauptung über die Sensor-Lage auf, die an drei
eigenen Messungen scheitert, und die Fitness-Function-Zeile, die sie einlösen soll, ist im realen
`make mutate`-Harness **nicht rot zu bekommen**. Beide sind neu; keiner verlangt, eine Festlegung
zu ändern.

**Ein besonderer Prüfauftrag dieser Runde.** Der Autor hat in dieser ADR zweimal etwas als
*gemessen* ausgegeben, das nicht gemessen war (R4-1, R4-4). Ich habe daher **jede** Behauptung,
die im Text als gemessen, belegt oder verbatim zitiert auftritt, an ihrer Quelle geprüft — die
Ergebnisse stehen gebündelt unter [Beleg-Prüfung](#beleg-prüfung-jede-gemessen-aussage-an-ihrer-quelle).
Kurzfassung: **von elf geprüften Belegen halten neun**; die zwei, die nicht halten, sind beide
neu in dieser Fassung, und beide betreffen wieder die Sensor-Lage.

**Gegenstand:** [`docs/plan/adr/0011-telemetrie-erfassung-policy.md`](../plan/adr/0011-telemetrie-erfassung-policy.md)
(Status **Proposed**, 406 Zeilen), im Kontext von
[`docs/plan/planning/welle-09-modul-15-konformitaet.md`](../plan/planning/welle-09-modul-15-konformitaet.md)
und `docs/plan/planning/open/slice-059-telemetrie-erfassung-hook.md` <!-- d-check:ignore (Lifecycle-Pfad: die Slice-Datei wandert durch open/next/in-progress/done) -->
sowie [`docs/plan/adr/README.md`](../plan/adr/README.md).

**Diff:** `git show 5bebbb4` — vier Dateien, 954+/51−: die ADR (108 Zeilen), der ADR-Index
(1 Zeile), slice-059 (33 Zeilen) und der Runde-4-Report als neue Datei (862 Zeilen).
**Gemessen** (`git show 5bebbb4 --stat`): **weder** `spec/lastenheft.md` **noch**
`.claude/settings.json` **noch** `test/mutations/` **noch**
`docs/plan/planning/welle-09-modul-15-konformitaet.md` sind berührt. Die letzte Nicht-Berührung
trägt einen eigenen Befund (R5-4).

**Skill:** [`.harness/skills/reviewer.md`](../../.harness/skills/reviewer.md) @ 1.4.0 ·
**Modell:** claude-opus-5[1m] · **Datum:** 2026-07-28

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde):

- Regelwerk (Baseline v3.5.2, vendored, Index zuerst): `modul-04-architektur-adrs.md`
  §Ziel-Form: ADR (Wortlaut gelesen, inkl. *„Jede Entscheidung mit Architektur-Wirkung bekommt
  eine Fitness Function — sonst ist sie Absichtserklärung"*), `modul-15-observability.md`
  **vollständig** gelesen (§Span-/Audit-Attribut-Regeln, §Token-Attributions-Regeln,
  §Cache-Counter-Regeln), `grundlagen-klassifikation.md` (§2×2-Matrix, §Steering Loop),
  `grundlagen-durchsetzungsschicht.md` (die Quadranten-Tabelle selbst)
- Ziel-Form-Vorlage: `.harness/baseline/v3.5.2/templates/docs/plan/adr/NNNN-titel.template.md`
  (Block-Reihenfolge gegen die ADR abgeglichen)
- Spec: [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
  [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten),
  [`LH-QA-04`](../../spec/lastenheft.md#lh-qa-04--plattform-matrix) — **verbatim** gelesen
  (`spec/lastenheft.md:258-300`), nicht aus der ADR oder den Vorrunden übernommen
- Aktive ADRs auf Kollision geprüft: [`ADR-0003`](../plan/adr/0003-go-native-binaries.md),
  [`ADR-0004`](../plan/adr/0004-durchsetzungs-emission.md)
- Adaptionen: [`MR-002`](../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks),
  [`MR-003`](../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung),
  [`MR-005`](../../harness/conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption),
  [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler),
  [`MR-017`](../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
- Hard Rules: [`AGENTS.md`](../../AGENTS.md) §3, besonders §3.4 und §3.6
- **Vorherige Findings am gleichen Modul:** [Runde 1](2026-07-28-adr-0011-proposed-review.md)
  (2 HIGH / 6 MEDIUM / 3 LOW), [Runde 2](2026-07-28-adr-0011-proposed-review-runde-2.md)
  (3 HIGH / 7 MEDIUM / 3 LOW / 2 INFO), [Runde 3](2026-07-28-adr-0011-proposed-review-runde-3.md)
  (1 HIGH / 4 MEDIUM / 6 LOW / 1 INFO), [Runde 4](2026-07-28-adr-0011-proposed-review-runde-4.md)
  (3 HIGH / 8 MEDIUM / 5 LOW / 1 INFO), dazu der vorgelagerte
  [welle-09-Plan-Review](2026-07-28-welle-09-plan-review.md)
- **Eigene Messungen dieser Sitzung** (nichts aus der ADR oder aus den Vorrunden übernommen):
  `make docs-check` → **d-check 233 Dateien / 0 Befunde**; `make test-bats` **vollständig
  gefahren** (127 Tests, alle grün — u. a. `ok 89 driver: die Kopie traegt den Sensor-Bedarf
  inklusive .git`); [`test/mutate-driver.bats`](../../test/mutate-driver.bats) gelesen;
  [`harness/tools/mutate.sh`](../../harness/tools/mutate.sh) **vollständig** gelesen
  (`prepare_isolation`, `run_case`, `narrow_sensor`, `failure_form`, die fünf
  fail-closed-Bedingungen); **die tar-Zeile der Isolation real ausgeführt und ihr Archiv
  gelistet**; `.claude/settings.json` gelesen (zwei Hooks: `PreToolUse`/`Bash` → Guard, **`Stop`
  ohne Matcher** → `stop-require-gates.sh`); `grep -E "log|tee|>>"` über den Guard → **leer**;
  `test/mutations/` durchgezählt (**102** Fälle) und alle acht mit `files: harness/tools/mutate.sh`
  gelesen; `ls -la .harness/state/` → Verzeichnis **0775**, Stempeldatei **0664**, sonst leer;
  `git ls-files .harness/state` → **leer**; `.gitignore` gelesen; `Makefile` §`gates`/`test-bats`
  gelesen; `docs/plan/planning/in-progress|open|next/` gelistet; die `**Bezug:**`-Blöcke von
  slice-046/048/059 ausgewertet; **die Hook-Doku (<https://code.claude.com/docs/de/hooks>) am
  2026-07-28 dreimal gezielt abgerufen** — zur Antwort-Aggregation, zu `session_id`/`agent_id`,
  zum leeren Matcher, zum Timeout-Default und zur Exit-Code-/`decision`-Tabelle je Ereignis

---

## Findings

### R5-1 — Der Reparatur-Absatz zu R4-1 ersetzt eine falsche Sensor-Zusage durch eine falsche Sensor-**Verneinung**: der Zustands-Ausschluss **ist** bewacht, und zwar von einem Gate

- `kategorie`: **HIGH** (Verstoß gegen eine Hard Rule —
  [`AGENTS.md`](../../AGENTS.md) §3.6 verlangt, *„zu benennen, was wirklich deckt — oder dass
  nichts deckt"*; hier ist die zweite Hälfte falsch behauptet, ohne den deckenden Sensor gelesen
  zu haben)
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 (*„Falsch: ‚Byte-Gleichheit belegt `make smoke`',
  ohne `smoke` gelesen zu haben"*) ·
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (die ADR
  ruft sie im selben Satz an) · Vorbefund R4-1
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:122-128`
- `befund`: Der neue Absatz lautet: *„**Diese Ausnahme ist allerdings UNBEWACHT** … Wer den
  Ausschluss entfernt, kopiert Spans in die Mutations-Kopie, und **kein Sensor meldet es** — genau
  die Klasse, gegen die `LH-QA-01` steht."* Die Korrektur an `test/mutations/74` ist richtig (ich
  habe den Fall gelesen und bestätige: er benutzt den Ausschluss als *sed-Anker* und bewacht, dass
  `.git` mitkopiert wird). Der **Schluss** daraus ist falsch, weil er von „kein **Mutations-Fall**"
  auf „kein **Sensor**" springt. Gemessen: [`test/mutate-driver.bats`](../../test/mutate-driver.bats)
  enthält im Test *„driver: die Kopie traegt den Sensor-Bedarf inklusive .git"* die Zeile
  `[ ! -e "$dest/.harness/state" ]` — eine unbedingte Assertion **genau auf diese Eigenschaft**,
  mit dem erklärenden Kommentar *„Nur der Laufzustand (.harness/state, gitignored) bleibt
  drausen."* Ich habe den Test dieser Sitzung real gefahren: `make test-bats` → `ok 89`. `make
  test` ist Bestandteil von `make gates` (`Makefile:231`), und `.harness/state/` existiert im
  Arbeitsbaum (Verzeichnis 0775, `gates-passed.diffsha`) — ein entfernter Ausschluss kopierte es
  in den `$dest`, und die Assertion fiele. Der Ausschluss ist also **nicht** unbewacht, sondern
  **durch ein Gate** bewacht; unbewacht ist allein die *Haltbarkeit* dieses Zahns, weil kein
  `test/mutations/`-Fall ihn absichtlich rot färbt.
  Failure-Szenario: die ADR wird *Accepted*. Der Implementer von Folgepflicht 5 liest „unbewacht,
  kein Sensor meldet es" und baut, was die Folgepflicht verlangt — einen Wächter für eine
  Eigenschaft, die schon einen hat. Weil der Mutations-Treiber in Bedingung 4 (*„Rot aus dem
  falschen Grund ist kein Beleg"*) verlangt, dass die `# expect:`-Zeile **den** roten Wächter
  nennt, muss er sich für einen entscheiden; nennt er den neuen, steht die Eigenschaft danach an
  zwei Orten und driftet — die Klasse, die dieses Repo mehrfach beseitigt hat (`mutate.sh`
  §`failure_form`: *„Zwei Listen, die getrennt gepflegt werden, sind genau die
  Drift-Konstruktion"*). Zugleich trägt der bindende Teil der ADR nach *Accepted* dauerhaft eine
  **falsche Aussage über die Gate-Lage dieses Repos** — die Richtung ist zwar konservativ (die ADR
  unterschätzt ihre Deckung, sie täuscht keine vor), aber [`AGENTS.md`](../../AGENTS.md) §3.6
  unterscheidet nicht nach Richtung: eine Deckungsaussage ohne gelesenen Sensor ist in beiden
  Richtungen unbelegt, und §3.4 macht sie ab *Accepted* unkorrigierbar. Verschärfend: es ist die
  **dritte** als „gemessen"/„falsch" ausgegebene Aussage dieser ADR, die an der Quelle nicht hält,
  und die **zweite in Folge über denselben Gegenstand**.
- `verifizierbar`: ja, ohne Umsetzung — `grep -n "harness/state" test/mutate-driver.bats` → `:92`
  (Kommentar) und `:104` (Assertion); `make test-bats` → `ok 89`; `ls -la .harness/state/` zeigt
  den Inhalt, der ohne Ausschluss mitkopiert würde. Kein Gate deckt den Befund selbst
  (`docs-check` prüft Links/Anker/IDs, nicht ob eine Verneinung über einen Sensor stimmt).

### R5-2 — Die neue Fitness-Function-Zeile zum Zustands-Ausschluss ist im realen `make mutate`-Harness **nicht rot zu bekommen**: die Mutation maskiert sich selbst

- `kategorie`: **HIGH** (halluziniertes Gate —
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6);
  wörtlich dieselbe Klasse wie H-1 aus [Runde 1](2026-07-28-adr-0011-proposed-review.md), die die
  ADR im Abschnitt *„Was hier bewusst NICHT steht"* als ihre eigene Lehre führt)
- `quelle`: [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) ·
  [`AGENTS.md`](../../AGENTS.md) §3.6 · `modul-04-architektur-adrs.md` §Ziel-Form ·
  [`harness/tools/mutate.sh`](../../harness/tools/mutate.sh) §`prepare_isolation`/§`run_case`
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:353`
- `befund`: Die Zeile lautet: *„`test/mutations/` | **Der Zustands-Ausschluss der Mutations-Kopie
  wird entfernt** — der Wächter muss rot werden (heute unbewacht, s. Festlegung 2 / Folgepflicht 5)
  | `make mutate`"*. Sie ist die Einlösung von R4-1 und lässt sich in der beschriebenen Form nicht
  bauen. Gemessen am Treiber: `run_case` fährt den Sensor mit `( cd "$WORK" && make "$verify" )` —
  **innerhalb der isolierten Kopie**; `make test-bats` mountet `$(CURDIR)` (also `$WORK`)
  read-only in den bats-Container, und `mutate-driver.bats` setzt `REPO="$BATS_TEST_DIRNAME/.."`,
  arbeitet also gegen die Kopie. Die Kopie entsteht ihrerseits über
  `tar -cf - --exclude=./.harness/state .` — sie enthält `.harness/state` **nicht**. Ich habe
  genau diese tar-Zeile ausgeführt und ihr Archiv gelistet: **0** Einträge unter `harness/state`,
  **1930** Einträge unter `./.git/`. Entfernt eine Mutation den Ausschluss in
  `$WORK/harness/tools/mutate.sh`, dann tart der Test in der Kopie einen Baum, in dem es nichts zu
  kopieren gibt — die Assertion `[ ! -e "$dest/.harness/state" ]` bleibt **wahr**, der Sensor
  bleibt **grün**. Das ist der exakte Gegensatz zu Fall 74, der funktioniert, weil `.git` in der
  Kopie vorhanden **ist**. Die Eigenschaft ist im Host-Baum messbar (R5-1) und in der Kopie
  strukturell unmessbar; die Zeile verlangt aber `make mutate`.
  Failure-Szenario: slice-059 (oder der Implementer von Folgepflicht 5) legt den Fall an, wie die
  Zeile ihn beschreibt. `make mutate` läuft in Bedingung 3 (*„der Sensor bleibt GRUEN → Befund"*)
  und meldet dauerhaft `mutate: BEFUND … '<Wächter>' hat keine Zaehne mehr` — ein Sensor, der bei
  korrektem Code rot meldet. Die naheliegende Reaktion auf einen dauerhaft roten Nicht-Gate-Sensor
  ist, den Fall wieder zu entfernen oder seine Erwartung so lange zu verbiegen, bis er grün wird;
  in beiden Ausgängen steht in der *Accepted*-ADR eine Fitness Function, der kein Fall entspricht
  — [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) eine
  Ebene tiefer, und nach §3.4 nicht mehr streichbar. Genau dafür hat Runde 1 zwei Zeilen streichen
  lassen.
- `verifizierbar`: ja, ohne Umsetzung —
  `tar -cf - --exclude=./.harness/state . | tar -tf - | grep -c "harness/state"` → **0** (und
  `grep -c "^\./\.git/"` → 1930); `sed -n '143,153p' harness/tools/mutate.sh` (die tar-Zeile) und
  `sed -n '355,360p' harness/tools/mutate.sh` (`cd "$WORK" && make "$verify"`);
  `sed -n '14,17p;93,106p' test/mutate-driver.bats` (Kopie-relative `REPO`-Wurzel + Assertion).
  Kein Gate deckt es.

### R5-3 — Die neu als „dokumentiert" eingesetzte Aggregations-Regel verschweißt zwei Mechanismen, die die Quelle auf **disjunkte** Ereignis-Mengen legt — und ihre Existenz war an der Quelle nicht reproduzierbar

- `kategorie`: **MEDIUM** (Kategorie bewusst wie beim identischen Vorbefund R4-4 gehalten; die
  Eskalation in den Gate-Pfad ist erwogen und **nicht** vorgenommen, weil die Schluss-Richtung des
  Absatzes unberührt bleibt — s. u.)
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 · ADR-0011 §Kontext (*„an der Werkzeug-Doku
  gemessen"*) · ADR-0011 §Festlegung 6 (*„Der Grund ist gemessen, nicht vermutet"*) ·
  Vorbefund R4-4
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:239-245`
- `befund`: Der Absatz sagt jetzt: *„Wie das Werkzeug widersprüchliche Antworten aggregiert, ist
  dokumentiert … ein `block` **eines** Hooks setzt sich durch (ODER-Verknüpfung, in der Rangfolge
  `deny > ask > defer > allow`)"* — mit der Klammer, die Runde-4-Fassung habe hier fälschlich
  „nicht dokumentiert" geführt. Zwei getrennte Probleme.
  (a) **Der Satz ist in sich falsch, unabhängig davon, was die Seite sagt.** An der Quelle am
  2026-07-28 gemessen: `decision: "block"` ist ein **Top-Level**-Feld und wird von
  `UserPromptSubmit`, `PostToolUse`, `PostToolUseFailure`, `Stop`, `SubagentStop` u. a.
  entgegengenommen; `PreToolUse` nimmt es ausdrücklich **nicht** — dort heißt das Feld
  `hookSpecificOutput.permissionDecision` mit den Werten `allow`/`deny`/`ask`/`defer`. Die
  Rangfolge `deny > ask > defer > allow` ist die Ordnung **dieser vier Werte** und existiert damit
  nur auf einem Ereignis, das `block` gar nicht kennt. Die ADR schreibt beide Regeln in **eine**
  Klammer und stellt die Rangfolge als die Ordnung *des* ODER dar — ein `block` steht in dieser
  Rangfolge nie, weil kein Ereignis beide Formen annimmt. Das ist die Kondensations-Klasse: zwei
  autoritative Regeln zu einer verkürzt, die keine von beiden korrekt wiedergibt.
  (b) **Die Existenz der Aggregations-Regeln war nicht reproduzierbar.** Ich habe die Seite
  zweimal gezielt danach abgefragt, beim zweiten Mal mit ausdrücklicher Bitte, die
  Abschnitts-Überschriften zu nennen, falls nichts gefunden wird. Beide Abrufe liefern: zur
  Konfliktauflösung steht dort **nur** *„Alle passenden Hooks werden parallel ausgeführt, und
  identische Handler werden automatisch dedupliziert"* sowie — als einzige Aggregations-Aussage —
  *„Wenn mehrere Hooks `additionalContext` für das gleiche Ereignis zurückgeben, erhält Claude
  alle Werte."* Ein Abschnitt „Response Aggregation" wurde nicht gefunden. Ich kann daraus nicht
  schließen, dass er nicht existiert (die Seite ist lang, mein Abruf geht über eine
  zusammenfassende Zwischenstufe) — ich kann aber feststellen, dass eine als **gemessen**
  ausgegebene Aussage in zwei gezielten Nachmessungen nicht auffindbar war, während die
  ADR im selben Abschnitt festhält, dass die Quelle **nicht gepinnt** ist und **kein Gate** sie
  prüft.
  **Ausdrücklich nicht beanstandet:** die *Richtung* des Arguments. Ob die Aggregation ODER-artig,
  restriktiv oder undokumentiert ist — ein Telemetrie-Hook, der versehentlich auf dem
  Entscheidungs-Kanal spricht, ist in allen drei Welten gefährlich, und Festlegung 6 zieht daraus
  dieselbe Konsequenz. Der Befund richtet sich allein gegen die Behauptung, nicht gegen den
  Schluss.
  Failure-Szenario: slice-059 nimmt die ADR beim Wort und modelliert seine Messung gegen die
  angegebene Semantik — etwa indem er prüft, ob sein Hook in der Rangfolge unterhalb von `deny`
  landet, ein Konzept, das auf dem gewählten Nach-Ereignis gar nicht existiert. Er belegt dann eine
  Eigenschaft gegen ein Modell, das die Quelle so nicht hergibt. Nach *Accepted* steht die
  verschweißte Regel unkorrigierbar in einer Rang-3-Quelle, und der Re-Evaluierungs-Trigger 1
  (*„wenn das Werkzeug seine Hook-Oberfläche ändert"*) löst nicht aus, weil sich nichts geändert
  hat — die Aussage war von Anfang an schief.
- `verifizierbar`: ja — erneuter Abruf von <https://code.claude.com/docs/de/hooks>, Abschnitte zur
  JSON-Ausgabe je Ereignis (`decision` vs. `hookSpecificOutput.permissionDecision`), gegen
  `docs/plan/adr/0011-telemetrie-erfassung-policy.md:239-245`. Kein Gate deckt es (`docs-check`
  läuft `--network none`).

### R5-4 — Die `Geschichte` führt die fünfte Fassung **nicht**: Index sagt „Runde 5", die Welle „nach der vierten Runde", und die ADR selbst dokumentiert ihre eigene jüngste Überarbeitung überhaupt nicht

- `kategorie`: **MEDIUM** (Basis LOW wie bei den Vorbefunden F-10/R2-11/R3-8/R4-13; eine Stufe,
  weil diesmal nicht ein Index-Etikett altert, sondern ein **Pflicht-Block der Ziel-Form** eine
  Überarbeitung auslässt, die die Fitness-Function-Tabelle und das Bedrohungsmodell geändert hat —
  und weil [`AGENTS.md`](../../AGENTS.md) §3.4 den Block ab *Accepted* einfriert) —
  **fünfte Runde derselben Klasse ⇒ Steering-Loop-Signal** nach §Kontext-Eskalation des
  Reviewer-Skills
- `quelle`: `modul-04-architektur-adrs.md` §Ziel-Form + Vorlage
  `templates/docs/plan/adr/NNNN-titel.template.md` (Block `Geschichte`) ·
  [`AGENTS.md`](../../AGENTS.md) §5 (*„Neue ADRs aktualisieren den ADR-Index"*) · §3.4 ·
  Vorbefunde F-10, R2-11, R3-8, R4-13 · Drift-Klasse „derselbe Stand an drei Orten"
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:399-406` gegen
  [`docs/plan/adr/README.md`](../plan/adr/README.md):19 und
  `docs/plan/planning/welle-09-modul-15-konformitaet.md:173`
- `befund`: Die vier bisherigen Fassungen sind in der `Geschichte` lückenlos geführt — die
  jüngste Zeile lautet *„Überarbeitet (Runde 4), weiter **Proposed**"* und verweist auf den
  Runde-3-Report. Für die mit `5bebbb4` entstandene **fünfte** Fassung gibt es **keine Zeile**;
  `grep -n "Überarbeitet (Runde" …` liefert genau drei Treffer (`:404`, `:405`, `:406`). Der
  ADR-Index ist dagegen gezogen (`:19` → *„**Proposed** (Runde 5)"*), welle-09 nicht (`:173` →
  *„Status **Proposed**, nach der vierten Runde"*). Drei Artefakte, drei verschiedene Stände —
  und diesmal ist das schwächste Glied die ADR selbst: gerade die Runde, die den schwersten
  Vorbefund (R4-1) reparieren wollte, vier Fitness-Function-Zeilen ergänzt, Folgepflicht 5
  eingeführt und das Bedrohungsmodell umgeschrieben hat, hinterlässt im Dokument keine Spur ihrer
  Herkunft. Die vier vorhandenen Zeilen sind vorbildlich (sie benennen die eigenen Fehler
  inhaltlich, statt sie zu glätten) — genau deshalb fällt die fehlende fünfte auf.
  Failure-Szenario: die ADR geht auf *Accepted*. Ein späterer Leser — etwa der CR-Autor von
  slice-062 oder ein Verifier, der `Geschichte` gegen die Review-Reports abgleicht — findet vier
  dokumentierte Überarbeitungen und einen Report-Korpus mit fünf Runden. Er kann nicht entscheiden,
  ob Runde 5 stattgefunden hat, ob ihre Befunde eingearbeitet sind, und warum die
  Fitness-Function-Tabelle vier Zeilen mehr trägt, als die letzte dokumentierte Zeile erklärt.
  Nach §3.4 lässt sich der Block nicht mehr ergänzen; die Rekonstruktion geht nur noch über
  git-Archäologie. Für welle-09 gilt zusätzlich die Fehlleitung aus R3-8/R4-13 unverändert: wer
  über das Planungs-Artefakt einsteigt, hält den Runde-4-Stand für den aktuellen.
- `verifizierbar`: ja, am Artefakt — `grep -n "Überarbeitet (Runde" docs/plan/adr/0011-telemetrie-erfassung-policy.md`
  → drei Treffer, keiner für Runde 5; `grep -n "Runde 5" docs/plan/adr/README.md` → `:19`;
  `grep -n "vierten Runde" docs/plan/planning/welle-09-modul-15-konformitaet.md` → `:173`. Kein
  Gate deckt es (`docs-check` prüft die Existenz der Index-Zeile, nicht ihren Inhalt, und keine
  Block-Vollständigkeit).

### R5-5 — „Lebensdauer: die Sitzung" ist nach der Aufräum-Änderung die Überschrift eines Absatzes, der das Gegenteil entscheidet; das benannte `make`-Ziel hat weder Folgepflicht noch Sensor

- `kategorie`: **MEDIUM** — **Ersatz für R4-8**, dessen Fix die Frage sauber entscheidet, aber
  eine Überschrift und eine Folgekante stehen lässt
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 (*„die Zusage auf das einschränken, was der Code
  hält"*) · ADR-0011 §Bedrohungsmodell Grund 1 und Grund 2 (`:131-135`) ·
  `modul-07-carveouts.md` §Ziel-Form (ein Kriterium, das ein anderer ohne Rückfrage anwenden kann)
  · Vorbefunde R2-5, R3-4, R4-8
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:163-174`
- `befund`: Die Entscheidung selbst ist richtig und war der offene Punkt aus R4-8: der Emitter
  fasst **nur seine eigene Datei** an, weil *„läuft die noch?"* nicht entscheidbar ist. Der Preis
  ist ausgesprochen — *„alte Bestände bleiben liegen, bis jemand sie **ausdrücklich** entfernt
  (ein `make`-Ziel, kein Automatismus)"*. Zwei Reste bleiben. (a) **Die Überschrift desselben
  Aufzählungspunkts lautet weiter „Lebensdauer: die Sitzung"** — und das ist nach der Änderung
  keine verkürzte, sondern eine **gegenteilige** Aussage: die Lebensdauer eines Bestands ist jetzt
  unbegrenzt und endet erst durch einen manuellen Aufruf. Die Überschrift ist zugleich der Satz,
  den Festlegung 5 unverändert in emittierte Ziele zieht, und der Satz, auf den sich die
  Zeitkritik der Cache-Status-Auflösung stützt (Vorbefund R4-16). (b) **Das benannte `make`-Ziel
  existiert in keiner Folgepflicht und in keiner Fitness Function.** Die ADR führt fünf
  Folgepflichten (Schema-`MR`, Abweichungs-Dokumentation, Nutzer-Doku, Folgenummer,
  Zustands-Ausschluss-Wächter) und neun Fitness-Function-Zeilen; keine nennt das Aufräum-Ziel. Es
  ist damit das einzige Artefakt der ADR, das der Text für nötig erklärt und niemandem aufträgt.
  Failure-Szenario: nach einigen Wochen Parallelbetrieb (dieses Repo führt Review-, Verifikations-
  und Implementer-Sitzungen ausdrücklich getrennt) liegen in `.harness/state/` Dutzende
  Span-Dateien mit Pfaden, Kommando-Tokens und — auf der Repo-Ebene ausdrücklich erlaubt —
  Inhalts-**Hashes**. Damit reproduziert sich im Repo genau das Bestätigungs-Orakel, das dieselbe
  Runde für die emittierte Ebene abgeschafft hat: Grund 1 des eigenen Bedrohungsmodells
  (*„ein rotiertes Secret ist aus der Quelle raus und stünde im Log weiter"*) ist ein **Zeit**-,
  kein Grenz-Argument, und er greift, sobald die Lebensdauer nicht mehr die Sitzung ist. Grund 2
  (*„wer sein Zustands-Verzeichnis an einen Fehlerbericht hängt"*) wird mit jeder liegengebliebenen
  Datei wahrscheinlicher. Ein Leser, der nur die Überschrift liest — und Überschriften werden
  gelesen —, hält den Bestand für sitzungsflüchtig.
- `verifizierbar`: ja, am Artefakt — `:163` (Überschrift) gegen `:169-172` (Entscheidung);
  Volltextsuche nach einem Aufräum-Ziel in den Folgepflichten (`:311-339`) und in der
  Fitness-Function-Tabelle (`:341-353`) → kein Treffer. Kein Gate deckt es.

### R5-6 — Der Nummernkreis je (Sitzung, Agent) ist mit Festlegung 3 nicht zusammengeführt, und unter beiden möglichen Auslegungen entsteht eine Lücke, die der eigene Detektor gerade nicht sieht

- `kategorie`: **MEDIUM** — **Ersatz für R4-9**, dessen Fix die Doppelvergabe beseitigt und dafür
  die Vollständigkeits-Frage eine Ebene höher schiebt
- `quelle`: ADR-0011 Folgepflicht 4 (die Sichtbarkeits-Zusage *„sonst entsteht ein Log, das
  lückenhaft ist und vollständig aussieht"*) · ADR-0011 Festlegung 3, zweiter Punkt
  (*„ihre eigene, **sitzungs-benannte** Datei"*) · [`AGENTS.md`](../../AGENTS.md) §3.6
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:331-339` gegen `:163-165`
- `befund`: Die Korrektur ist an der Quelle richtig hergeleitet — ich habe sie nachgemessen:
  `agent_id` ist *„Nur vorhanden, wenn der Hook innerhalb eines Subagenten-Aufrufs ausgelöst
  wird"*, ausdrücklich mit dem Zweck *„Verwenden Sie dies, um Subagenten-Hook-Aufrufe von
  Main-Thread-Aufrufen zu unterscheiden"*. Ein Kreis je (Sitzung, Agent) ist damit **umsetzbar**:
  der Hauptkontext ist der Strom ohne `agent_id`. Unaufgelöst bleibt das Verhältnis zu Festlegung
  3. Dort schreibt *„jede Sitzung … in ihre eigene, **sitzungs**-benannte Datei"*, und der Emitter
  *„fasst ausschließlich seine EIGENE Datei an"*; Folgepflicht 4 sagt *„Je Agent ein eigener
  **Strom**, je Strom ein eigener Zähler"*. Ob „Strom" eine Datei oder ein Abschnitt in der
  Sitzungs-Datei ist, entscheidet die ADR nicht — und die beiden Lesarten sind nicht gleichwertig.
  Bei **einer** Datei je Sitzung schreiben mehrere Emitter parallel in dieselbe Datei, und das
  Interleaving ist nicht entschieden (die ADR trifft für gleichzeitige Schreiber keine Aussage,
  während sie den Zähler ausdrücklich wegen Parallelität aufteilt). Bei **einer Datei je
  (Sitzung, Agent)** ist „sitzungs-benannt" falsch, das Aufräumen greift ins Leere (die Datei
  eines frisch gestarteten Subagenten hat nie ältere Bestände), und vor allem: **die Anzahl der
  erwarteten Ströme steht nirgends**. Das Werkzeug, das Subagenten startet, fällt nach der neuen
  Default-Zeile von Festlegung 2 auf *„nur Name und Status"* — der Span des `Task`-Aufrufs trägt
  also **keine** `agent_id` und damit keinen Schlüssel auf den Strom, den er erzeugt hat.
  Failure-Szenario: eine Sitzung startet drei Subagenten (in diesem Repo der Normalfall —
  slice-059 §Messung E zählt für **eine** Sitzung 189 Calls im Hauptkontext plus 49 und 66 in
  Subagenten). Einer davon läuft in den Emitter-Timeout, bevor er seinen ersten Span schreibt.
  Es existieren zwei Subagenten-Ströme statt drei; jeder ist für sich lückenlos, der Hauptstrom
  ist lückenlos, und nichts im Bestand sagt, wie viele Ströme es geben müsste. Der Leser, dem
  Folgepflicht 4 die Erkennung zusagt, sieht Vollständigkeit — genau der Zustand *„lückenhaft und
  sieht vollständig aus"*, den sie wörtlich ausschließen will, nur eine Ebene über der Folgenummer.
  Der Absatz *„Ehrlich zu den Grenzen"* benennt allein den Tod **vor** der Vergabe innerhalb eines
  Stroms, nicht den fehlenden Strom.
- `verifizierbar`: ja — <https://code.claude.com/docs/de/hooks>, Abschnitt zu `agent_id`
  (*„Nur vorhanden, wenn der Hook innerhalb eines Subagenten-Aufrufs ausgelöst wird"*), gegen
  `docs/plan/adr/0011-telemetrie-erfassung-policy.md:331-339`; `:163-165` (sitzungs-benannte
  Datei) und `:111` (Default-Zeile ohne Argumente für das Agenten-Werkzeug). Kein Gate deckt es.

### R5-7 — Die fail-closed Default-Zeile trägt nur, wenn „steht in der Tabelle" entscheidbar ist; die drei anderen Zeilen sind Gattungen, die Eingabe des Emitters ist ein Name

- `kategorie`: **MEDIUM** — **Rest von R4-6**, dessen Hauptteil (kein Default) gelöst ist
- `quelle`: [`MR-017`](../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
  · `modul-07-carveouts.md` §Ziel-Form (ein Kriterium, das ein anderer ohne Rückfrage anwenden
  kann) · [`AGENTS.md`](../../AGENTS.md) §3.6 (*„die Zusage auf das einschränken, was der Code
  hält"*) · Vorbefund R4-6
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:106-114`
- `befund`: Die neue Zeile *„**jedes andere, auch künftige** … **nur** Name und Status — **keine**
  Argumente. Das ist der Default, und er ist fail-closed: ein Werkzeug, das hier nicht steht, gibt
  nichts preis"* schließt die von R4-6 benannte Lücke für den benannten Fall (das Agenten-Werkzeug
  ist ausdrücklich genannt). Ihre Auslösebedingung ist aber *„steht hier nicht"*, und die drei
  Zeilen, gegen die geprüft wird, führen **Gattungen** — *Schreib-Werkzeuge*, *Kommando-Werkzeug*,
  *Lese-Werkzeuge* —, keine Namen. Der Emitter hat als Eingabe den Werkzeug-**Namen** und sein
  Argument-Objekt; ob ein unbekannter Name in eine Gattung fällt, ist eine Auslegung, keine
  Prüfung. Die ADR entscheidet nicht, welche der beiden Konstruktionen gilt, und nur eine davon
  ist fail-closed: eine **namentliche** Zuordnungsliste löst den Default zuverlässig aus, eine
  **gattungsweise** Einordnung praktisch nie, weil sich fast jedes Werkzeug in eine der drei
  Klassen argumentieren lässt. Die Folge ist genau die Kehrseite des Satzes zwei Zeilen weiter:
  *„Damit wandert **kein Byte fremden Inhalts** ins Log"* ist über alle Werkzeuge quantifiziert.
  Failure-Szenario: slice-059 registriert wie vorgesehen mit leerem Matcher. Ein Werkzeug mit
  einem Nicht-Pfad-Argument taucht auf — ein MCP-Werkzeug mit Query- oder URL-Parameter, ein
  Notebook-Editor, ein Web-Abruf. Der Fall-Autor ordnet es der nächstliegenden Gattung zu
  (*„das liest ja etwas"* → Zeile 3, *„worauf wurde zugegriffen? → Pfad"*) und schreibt das
  Argument, das dort steht, in das Pfad-Feld; der Default feuert nie. Auf der emittierten Ebene,
  für die [`MR-017`](../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
  gerade die strengere Seite verlangt und die Werkzeug-Landschaft eines fremden Adopters unbekannt
  ist, ist die Zuordnung reine Auslegung — und die ADR hat für diesen Fall
  *„konstruktiv ausgeschlossen"* zugesagt.
- `verifizierbar`: ja, am Artefakt — die Tabelle (`:106-111`) führt drei Gattungen und eine
  Default-Zeile, aber keine Zuordnungsregel; `:113-114` quantifiziert über alle Werkzeuge. Kein
  Gate deckt es.

### R5-8 — Der Allowlist-Rest aus R4-10 ist halb gezogen: die beiden inhaltlichen Stellen sind repariert, eine **Fitness-Function-Zeile** und eine Konsequenz stehen weiter auf der abgeschafften Konstruktion — und die Konsequenz sagt sachlich das Gegenteil von Festlegung 2

- `kategorie`: **MEDIUM** — **aus Vorrunden offen** (Rest von R4-10)
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.4 · Vorbefund R4-10 · Drift-Klasse „derselbe Stand
  an zwei Orten, einer altert"
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:346` und `:307-310`, dazu `:287`
  und `:297`
- `befund`: Runde 5 zieht die beiden von R4-10 als *„nicht Wortwahl, sondern Inhalt"* markierten
  Stellen sauber nach (Festlegung 5 `:222-224` nennt jetzt *„geschlossenes Schema mit fail-closed
  Default … ohne Inhalts-Hash"*; Alternative E `:288` beschreibt E korrekt als Cs **Default**).
  Von den fünf als Drift markierten Stellen bleiben vier, und zwei davon sind mehr als ein Wort.
  (a) **Die zweite Fitness-Function-Zeile** (`:346`): *„Ein Feld, das **nicht** auf der Allowlist
  steht, wird nicht durchgelassen"* — die Allowlist ist nach Festlegung 1.3 durch das geschlossene
  Schema ersetzt, und seit Runde 5 gibt es mit der Default-Zeile eine **zweite** Konstruktion, die
  ein Leser „Allowlist" nennen könnte (Werkzeuge statt Felder). Die Zeile steht in der
  normativen Sensor-Tabelle, also dort, wo der Fall-Autor nachschlägt.
  (b) **Die Konsequenz** (`:307-310`): *„volle Abdeckung heißt, der Hook sieht auch
  `Write`/`Edit`-Payloads — also **Datei-Inhalte**. Die Erfassungsfläche wächst damit genau um das,
  was am ehesten Secrets trägt. Festlegung 2 (Allowlist) ist deshalb nicht Beiwerk …"* Das ist
  nach Festlegung 2 sachlich falsch: der Hook *sieht* die Payload, die **Erfassungs**-Fläche
  wächst gerade **nicht** um Datei-Inhalte (Pfad + Länge, im Repo zusätzlich ein Hash), und genau
  das ist der Satz, mit dem dieselbe ADR 200 Zeilen vorher wirbt (*„Damit wandert kein Byte
  fremden Inhalts ins Log"*). Die beiden restlichen Stellen (`:287` Cs Contra-Spalte, `:297`
  Konsequenz „Negativ") sind reine Benennung.
  Failure-Szenario: der Fall-Autor von slice-059 arbeitet die Fitness-Function-Tabelle von oben
  nach unten ab — die vorgesehene Reihenfolge, weil sie die Sensor-Liste ist. Zeile 2 verlangt
  einen Fall gegen „die Allowlist"; er findet in Festlegung 1.3 ein Feld-Schema und in Festlegung 2
  eine Werkzeug-Tabelle mit Default und baut den Fall gegen die falsche der beiden. Die Konsequenz
  `:307-310` bestätigt ihn zusätzlich in der Annahme, es gehe um durchgelassene **Inhalte**. Der
  entstehende Fall bewacht dann eine Eigenschaft, die die Entscheidung nicht mehr trifft — und
  nach *Accepted* lässt sich keine der beiden Stellen mehr korrigieren.
- `verifizierbar`: ja — `grep -n "Allowlist" docs/plan/adr/0011-telemetrie-erfassung-policy.md`
  → vier Treffer außerhalb der `Geschichte` (`:287`, `:297`, `:309`, `:346`; `:148-149` ist die
  historische Klammer und korrekt). Kein Gate deckt es.

### R5-9 — Die stdout-Setzung bekommt eine bats-Zeile, aber keinen Mutations-Fall — ausgerechnet ihre „Kindprozesse"-Hälfte ist der von R4-3 benannte konkrete Leckpfad

- `kategorie`: **LOW**
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 (*„`make mutate` … meldet jeden gelisteten
  Wächter, der seine Zähne verloren hat"*) · ADR-0011 Festlegung 6, Setzung 1 · Vorbefund R4-3
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:351` gegen `:352`
- `befund`: Runde 5 löst R4-3 in der Sache: beide Setzungen haben jetzt eine Zeile
  (`:350` Klemme, `:351` stdout), und die schiefe Aufrufer-Zeile ist ersetzt. Die Behandlung ist
  aber asymmetrisch — die **Klemme** bekommt zusätzlich einen Mutations-Fall (`:352`, mit der
  ausdrücklichen Begründung *„ohne diesen Fall wäre Festlegung 6 eine Absicht"*), die
  **stdout-Setzung** nicht. Das trifft ausgerechnet die Hälfte, die R4-3 als konkreten hausgemachten
  Leckpfad beschrieben hat: *„jeder Kindprozess des Emitters erbt dessen stdout (ein `tee -a`
  statt `>>`, ein vergessenes `echo`, ein bares `git rev-parse` genügt)"*. Die bats-Zeile ist
  messbar (ich habe geprüft, dass sie es ist — s. Negativbefunde), aber ihre **Haltbarkeit** ist
  es nicht: wird die Umleitung eines Kindprozesses später entfernt, meldet `make mutate` nichts,
  weil kein gelisteter Fall die Eigenschaft anfasst.
  Failure-Szenario: ein späterer Slice ergänzt im Emitter eine Diagnose-Ausgabe oder ersetzt ein
  `>>` durch ein `tee -a` (ein in diesem Repo real vorkommendes Muster). Die bats-Zeile prüft
  *„unter allen geprüften Fehlerfällen"* — der neue Pfad ist keiner davon —, `make test` bleibt
  grün, `make mutate` meldet nichts, und der Emitter spricht ab dann bei jedem Aufruf auf dem
  Entscheidungs-Kanal, auf dem `stop-require-gates.sh` seinen Gate-Nachweis abgibt.
- `verifizierbar`: ja, am Artefakt — die Fitness-Function-Tabelle (`:341-353`) führt für die
  Klemme eine bats- **und** eine Mutations-Zeile, für stdout nur die bats-Zeile. Kein Gate deckt es.

### R5-10 — Der Rest von R3-5/R4-15: die GNU/BSD-Dialektfrage der Erlaubt-Liste ist unverändert offen, während Festlegung 5 die Liste in emittierte Ziele zieht

- `kategorie`: **LOW** — **aus Vorrunden offen** (R3-5 → R4-15 → hier)
- `quelle`: [`LH-QA-04`](../../spec/lastenheft.md#lh-qa-04--plattform-matrix) (macOS und Windows
  sind erstklassig) · Vorbefunde R3-5, R4-15 · ADR-0011 Festlegung 5
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:184-195`
- `befund`: Der Diff `5bebbb4` fasst Festlegung 4 nicht an. „POSIX-System" beantwortet weiterhin
  *„vorhanden wo"*, nicht *„in welchem Dialekt"*; der Bestand, den derselbe Absatz für „nicht
  betroffen" erklärt, deklariert im eigenen Kopf das Gegenteil —
  [`harness/tools/mutate.sh`](../../harness/tools/mutate.sh) (gelesen, `:32-36`): *„Die Faelle
  nutzen `sed -i` und GNU-BRE-Escapes, sind also **NICHT strikt POSIX**"*.
  [`LH-QA-04`](../../spec/lastenheft.md#lh-qa-04--plattform-matrix) führt macOS erstklassig, und
  Festlegung 5 zieht die Liste unverändert ins Ziel.
  Failure-Szenario: unverändert das aus R4-15 — der Emitter wird mit GNU-Semantik gebaut, greift
  auf einem BSD-Ziel anders, und betroffen ist die **Ableitung der Argument-Werte**, also der
  sicherheitstragende Teil dieser ADR.
- `verifizierbar`: ja — `sed -n '30,36p' harness/tools/mutate.sh` gegen
  `docs/plan/adr/0011-telemetrie-erfassung-policy.md:184-190`. Kein Gate deckt es.

### R5-11 — Der Rest von R4-16: die angebotene Auflösung des einzigen offenen Feldes importiert die Schwäche, mit der die ADR Alternative D verwirft — und die Zeitkritik hat sich mit R5-5 verschoben

- `kategorie`: **LOW** — **aus Vorrunden offen** (Rest von R4-16)
- `quelle`: ADR-0011 §Verglichene Alternativen, Zeile D (`:289`) · `modul-15-observability.md`
  §Cache-Counter-Regeln · Vorbefund R4-16
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:89-92` gegen `:289`
- `befund`: Regel 1.4 lässt den Cache-Status offen und bietet als Auflösung an, der Span trage den
  `transcript_path` und überlasse die Auflösung dem Auswerter. Der Diff hat den Satz nur
  umformuliert, nicht die Spannung aufgelöst: dieselbe ADR verwirft Alternative D mit *„die
  Datenquelle liegt **außerhalb** des Repos, gehört uns nicht und kann sich mit dem Werkzeug
  ändern"*. Die Frage bleibt für den Slice **entscheidbar** (Modul 15 verlangt für eine Abweichung
  verbatim nur *„jede Abweichung davon begründest du"*, keinen Sensor — gegen den Modul-Wortlaut
  geprüft), also kein blockierender Mangel. Neu ist nur, dass die von R4-16 benannte Zeitkritik
  ihre Richtung gewechselt hat: sie stützte sich darauf, dass der Span-Bestand nur die Sitzung
  lebt — was nach R5-5 nicht mehr gilt.
  Failure-Szenario: slice-059 wählt den `transcript_path`-Weg; slice-060 wertet später aus und
  findet das Transkript rotiert oder in geändertem Format. Der Cache-Status ist dann weder erfasst
  noch als Abweichung dokumentiert — die Lücke, die Regel 1.5 verhindern soll, entsteht durch die
  von Regel 1.4 angebotene Auflösung.
- `verifizierbar`: ja, am Artefakt — `:89-92` gegen `:289`. Kein Gate deckt es.

### R5-12 — Das Zustands-Verzeichnis bleibt gruppenschreibbar; entschieden ist weiterhin nur der Datei-Modus

- `kategorie`: **INFO** — **aus Vorrunden offen** (unveränderter Rest von R2-14/R3-12/R4-17)
- `quelle`: Vorbefunde R2-14, R3-12, R4-17 · ADR-0011 Festlegung 3, erster Punkt (`:160-162`)
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:160-162`
- `befund`: Eigene Messung 2026-07-28 bestätigt die Zahlen der ADR erneut: `.harness/state/` ist
  `drwxrwxr-x` (0775), die Stempeldatei `-rw-rw-r--` (0664). Der Diff ändert daran nichts. Ein
  0600-Span in einem 0775-Verzeichnis ist gegen Mitlesen geschützt, gegen Entfernen und
  Unterschieben nicht. Bleibt INFO, weil Festlegung 3 dritter Punkt („Kein Beleg-Status") die
  Integritäts-Anforderung ausdrücklich absenkt. **Neu relevant** im Verbund mit R5-5: je länger
  Bestände liegen bleiben, desto länger stehen sie in einem gruppenschreibbaren Verzeichnis.
- `verifizierbar`: ja — `ls -ld .harness/state/`. Kein Gate deckt es.

## Negativbefunde

### Runde-4-Befunde, die **sauber gelöst** sind

- geprüft, ohne Befund: **R4-2 (die zwei Regeln „4.") ist restlos gelöst.** Die alte Regel ist
  nicht stehen geblieben, sondern **zusammengeführt**: `grep -n "^4\."` liefert nur noch `:82`,
  die Nachfolgeregel ist als `5.` nummeriert (`:98`) und trägt die Restaussage
  (*„Was auch nach der Ableitung nicht erreichbar ist, wird begründet dokumentiert"*) **ohne** den
  widersprechenden Halbsatz über `requirement.id`. Die Liste zählt sauber 1–5, und der
  Widerspruch, dem slice-059 in seiner Frage G noch folgte, existiert an beiden Orten nicht mehr.
- geprüft, ohne Befund: **R4-5 (die Ableitung ohne Randfälle) ist mustergültig gelöst — und ich
  habe beide Randfälle nachgemessen.** (a) `ls docs/plan/planning/in-progress/` liefert am
  2026-07-28 **genau `roadmap.md`**, keinen Slice — die ADR benennt diesen Zustand jetzt
  ausdrücklich als *„den Zustand heute"* und entscheidet ihn (*„leer und als leer erkennbar, nicht
  geraten"*). (b) Die Vielzahl stimmt: `slice-048-release-artefakte.md:11` führt vier `LH-*`-IDs,
  `slice-046-arch-gate-emitter.md:10` ebenfalls vier — die ADR entscheidet jetzt *„trägt der Span
  sie **alle**"* statt eine Auswahl offenzulassen. Beide Entscheidungen sind so getroffen, dass
  ein Dritter sie ohne Rückfrage umsetzen kann.
- geprüft, ohne Befund: **R4-7 (der Fingerabdruck als Bestätigungs-Orakel auf der emittierten
  Ebene) ist an der Wurzel gelöst.** Der Hash ist auf der emittierten Ebene **gestrichen**
  (`:141-146`), und die Begründung nennt genau die beiden Punkte des Befunds: Bestätigungs-Orakel
  gegenüber einem Verdacht, und Grund 1 (Rotation) trifft den Hash wie den Klartext. Die Länge
  bleibt und beantwortet *„hat sich etwas geändert"*, ohne etwas zu bestätigen — und
  `tool.arguments` bleibt damit auch emittiert **nicht leer**, der Modul-15-Mindestsatz also
  erfüllt. Die Incident-Frage *„was wurde wohin geschrieben?"* bleibt in ihrer „wohin"-Hälfte
  vollständig und in ihrer „was"-Hälfte auf „wie viel" reduziert; Modul 15 verlangt das Feld, nicht
  eine Fidelität. Die emittierte Fassung wird dadurch **nicht** wertlos.
- geprüft, ohne Befund: **R4-6 ist in seinem Hauptteil gelöst.** Die Tabelle hat eine
  Default-Zeile, sie ist ausdrücklich fail-closed, und sie benennt das Agenten-Werkzeug mit seinem
  Freitext-Prompt als heutigen Hauptfall — genau die Lücke, die R4-6 beschrieben hat. Beanstandet
  wird nur noch die Entscheidbarkeit der Auslösebedingung (→ R5-7).
- geprüft, ohne Befund: **R4-8 ist entschieden, nicht verschoben.** Die ADR wählt jetzt eine der
  beiden von R4-8 benannten Auslegungen ausdrücklich („nur die eigene Datei") und begründet sie
  mit der Nicht-Entscheidbarkeit von „läuft die noch?" — der Punkt, den R4-8 als das eigentliche
  Hindernis benannt hatte. Der Preis steht im Text statt in einer Fußnote. Beanstandet werden nur
  die Überschrift und die fehlende Folgekante (→ R5-5), nicht die Wahl.
- geprüft, ohne Befund: **R4-9 ist an der Quelle richtig repariert.** Ich habe die
  Doppelvergabe-Prämisse nachgemessen: `agent_id` ist laut Quelle *„Nur vorhanden, wenn der Hook
  innerhalb eines Subagenten-Aufrufs ausgelöst wird"*, mit dem ausdrücklichen Zweck
  *„Verwenden Sie dies, um Subagenten-Hook-Aufrufe von Main-Thread-Aufrufen zu unterscheiden"*.
  **Die von der Prüffrage aufgeworfene Sorge, es gebe im Hauptkontext gar keine Agenten-Kennung,
  trägt nicht:** die Abwesenheit ist selbst der Diskriminator, und die Quelle nennt genau diese
  Verwendung. Der Nummernkreis je (Sitzung, Agent) ist damit **umsetzbar**. Beanstandet wird
  ausschließlich die nicht zusammengeführte Ablage-Frage (→ R5-6).
- geprüft, ohne Befund: **R4-11 ist gelöst, und der neue Trigger ist erreichbar.** Der Trigger
  hängt jetzt an *„kein Werkzeug über den Default hinaus erfasst"* statt an einer leeren
  Allowlist, und die Klammer benennt den eigenen Fehlgriff. Ich habe ausdrücklich geprüft, ob
  hier dieselbe Tautologie eine Runde später wiederkehrt — sie tut es **nicht**: Festlegung 1.2
  (*„Ein Feld ohne Incident-Frage wird nicht erfasst"*) lässt einen konformen Zustand zu, in dem
  der Umsetzer für alle Werkzeuge beim Default bleibt (etwa aus den Latenz-Gründen, die derselbe
  Abschnitt nennt). Die Bedingung kann eintreten, ohne dass jemand eine Festlegung bricht.
- geprüft, ohne Befund: **R4-12 (slice-059) ist vollständig gezogen.**
  `grep -n "Allowlist\|begründete Abweichung\|keine neue Abhängigkeit"` über
  `docs/plan/planning/open/slice-059-telemetrie-erfassung-hook.md` → **kein Treffer**. DoD (1)
  führt jetzt „Ableiten schlägt deklarieren" samt Randfällen, DoD (3) den fail-closed Default
  statt der Feld-Allowlist, Frage G ist auf die Randfälle umgestellt, und die Randbedingung heißt
  „nichts, das installiert werden muss" mit Verweis auf Festlegung 4. Die Nachzieh-Kante ist
  für den Slice zum ersten Mal in fünf Runden ganz gelaufen. Nebenbei repariert der Diff einen
  echten Markdown-Defekt (ein unbalanciertes Backtick in `:49`).
- geprüft, ohne Befund: **R4-13 (ADR-Index) ist gelöst.** `docs/plan/adr/README.md:19` führt jetzt
  *„geschlossenes Schema mit fail-closed Default, **abgeleitete** Argument-Werte je Ebene … fail-**open**
  im Betrieb mit sprech-unfähigem Emitter"* und den Rundenstand 5. Der Index beschreibt, was die
  ADR entscheidet. Dass die `Geschichte` ihm nicht folgt, ist der umgekehrte Fall und steht als
  R5-4.
- geprüft, ohne Befund: **R4-14 ist nach vier Runden gelöst — und ohne Kosmetik.**
  `grep -n "LH-QA-01" docs/plan/adr/0011-telemetrie-erfassung-policy.md` liefert jetzt **zwei**
  Treffer: `:11` (Bezug-Feld) und `:127` im Body — und zwar an der inhaltlich richtigen Stelle,
  im Absatz über den unbewachten Sensor. Die Anforderung wirkt damit im Text, statt nur im Kopf zu
  stehen. (Dass die Aussage, an der sie hängt, sachlich falsch ist, steht als R5-1 und ändert an
  der Auflösung dieses Vorbefunds nichts.)

### Beleg-Prüfung: jede „gemessen"-Aussage an ihrer Quelle

Der besondere Prüfauftrag dieser Runde. Geprüft wurde **jede** Stelle, die im Text als *gemessen*,
*belegt*, *verbatim* oder *dokumentiert* auftritt — an der Quelle, nicht an der ADR.

**Halten (9):**

- geprüft, ohne Befund: **`LH-QA-03` verbatim.** `spec/lastenheft.md:268-277` gelesen: *„die
  Laufzeit **beim Bootstrap** braucht nur **git + docker**"*, Messmethode *„Smoke: Binary auf
  frischem System mit nur git + docker → Bootstrap grün"*, und für die emittierte Seite wörtlich
  *„Emittierte Ziel-Repos bleiben make/docker-getrieben."* Beide Zitate der ADR (`:204-206`,
  `:211`) sind wortgleich, und die Lesart „Bootstrap-Klausel meint die Nutzer-Laufzeit" ist am
  Wortlaut korrekt.
- geprüft, ohne Befund: **das `ADR-0004`-Zitat.**
  [`ADR-0004`](../plan/adr/0004-durchsetzungs-emission.md)`:33` verbatim: *„`awk` ist POSIX-Basis
  (überall vorhanden, wo die bash-Hooks laufen) — kein neuer Dep"*. Die Linie, auf die Festlegung 4
  sich beruft, existiert dort und in dieser Bedeutung.
- geprüft, ohne Befund: **der Modul-15-Mindestsatz.** `modul-15-observability.md`
  §Span-/Audit-Attribut-Regeln verbatim: *„`tool.name`, `tool.arguments` (redacted),
  `tool.result.status` plus Korrelations-IDs zu Slice/PR/Agent-Rolle"* und *„Pflicht-Minimum:
  Slice-ID, Agent-Rolle, Cache-Status, `requirement.id` — jede Abweichung davon begründest du"*.
  Die Incident-Frage `tool.arguments.redacted` → *„was wurde wohin geschrieben — ohne Secrets im
  Log?"* deckt sich wörtlich mit der ersten Tabellenzeile von Festlegung 2. Beide Listen der ADR
  sind korrekt wiedergegeben, keine ist verkürzt.
- geprüft, ohne Befund: **„der Guard behält nichts".** `grep -E "log|tee|>>"` über
  `.claude/hooks/pretooluse-command-guard.sh` → **leer**. Die Kontext-Aussage stimmt.
- geprüft, ohne Befund: **die 16 Host-Skripte.** `ls harness/tools/ | wc -l` → **16**, dazu die
  zwei Hooks in `.claude/hooks/`. Die Zahl der ADR stimmt.
- geprüft, ohne Befund: **das Zustands-Verzeichnis 0775 / die Stempeldatei 0664.** Eigene Messung
  bestätigt beide Zahlen (s. R5-12).
- geprüft, ohne Befund: **„ein leerer Matcher trifft alle Tools".** An der Quelle am 2026-07-28:
  Matcher-Tabelle *„`"*"`, `""` oder weggelassen → Alle treffen"*. Die Kontext-Aussage und die
  Konsequenz *„Die Enge ist unsere Registrierung, keine Grenze des Werkzeugs"* halten.
- geprüft, ohne Befund: **„dokumentiert sind 600 s".** An der Quelle: Default-Timeout für
  `command`-Hooks **600 Sekunden**, je Hook per `timeout`-Feld überschreibbar. Die Zahl in
  Festlegung 6 stimmt, und die Bewertung *„als Grenze für ein Audit-Skript unbrauchbar"* ist eine
  Wertung, keine Messung.
- geprüft, ohne Befund: **„es gibt kein entscheidungsfreies Ereignis, auf das man ausweichen
  könnte" und „`Stop`/`SubagentStop` sind blockierbar".** An der Quelle bestätigt:
  `PostToolUse`/`PostToolUseFailure`/`Stop`/`SubagentStop` nehmen ein Top-Level-`decision: "block"`
  entgegen; Exit 2 heißt für `Stop` *„Prevents Claude from stopping"*, für `SubagentStop`
  *„Prevents the subagent from stopping"*. Zusätzlich bestätigt: ein Timeout ist ein
  *nicht-blockierender* Fehler — die Klemme aus Festlegung 6 ist mit *„unabhängig davon, was
  **intern** geschieht"* korrekt begrenzt, und `test/mutations/74` ist in seiner Wirkung
  zutreffend beschrieben (sed-Anker, bewacht `.git`).

**Halten nicht (2):**

- **„Diese Ausnahme ist UNBEWACHT … kein Sensor meldet es"** → widerlegt durch
  `test/mutate-driver.bats:104` und den eigenen Lauf `make test-bats` → `ok 89` (→ **R5-1**).
- **„Wie das Werkzeug widersprüchliche Antworten aggregiert, ist dokumentiert … ODER-Verknüpfung,
  in der Rangfolge `deny > ask > defer > allow`"** → an der Quelle verschweißt die Aussage zwei
  Mechanismen auf disjunkten Ereignis-Mengen, und die Aggregations-Regeln waren in zwei gezielten
  Nachmessungen nicht auffindbar (→ **R5-3**).

**Bewertung des Musters.** Beide Fehlgriffe liegen in derselben Klasse wie R4-1/R4-4 und betreffen
beide die **Sensor-/Werkzeug-Lage** — also genau die Aussagen, die dieses Repo sonst misst statt
behauptet. Nach §Kontext-Eskalation des Reviewer-Skills ist die dritte Wiederholung derselben
Klasse ein **Steering-Loop-Signal**: die Übergabe sollte nicht nur die zwei Stellen benennen,
sondern die Regel, die sie erzeugt hat — eine Aussage über einen Sensor gehört vor dem Schreiben
**gelaufen**, nicht gegrept. Beide Fehlgriffe dieser Runde entstanden aus einem `grep`, dessen
Trefferliste als Vollständigkeitsaussage gelesen wurde.

### Was ich sonst geprüft und **nicht** beanstandet habe (mit Beleg)

- geprüft, ohne Befund: **Die vier neuen Fitness-Function-Zeilen — drei sind rot zu bekommen, mit
  einem Sensor, den dieses Repo hat.** (a) `:350` *„Die Klemme greift … endet trotzdem mit Exit 0"*
  ist hermetisch in bats messbar (`run bash emitter.sh; [ "$status" -eq 0 ]`), einschließlich der
  ausdrücklich getrennten `awk`-Fatalvariante. (b) `:351` *„stdout leer — auch das seiner
  Kindprozesse"* ist **prüfbar**, und zwar ohne Zusatzmechanik: ein Kindprozess erbt fd 1 des
  Emitters, ein Test, der den stdout des Emitter-Prozesses erfasst, erfasst damit auch den seiner
  Kinder. Die Zeile ist zudem ehrlich begrenzt (*„unter allen geprüften Fehlerfällen"*) statt über
  alle Pfade quantifiziert. (c) `:352` *„Die Klemme wird entfernt … der Wächter muss rot werden"*
  ist ein regulärer `test/mutations/`-Fall in der Form dieses Repos: `# files:` auf das
  Emitter-Skript, `# expect:` auf den bats-Titel aus (a) — `narrow_sensor` bildet einen bats-Titel
  korrekt auf `test-bats` ab (gemessen: `mutate.sh:211-225`, `Test[A-Z]*` → `test-go`, sonst
  `test-bats`), und `failure_form test-bats` liefert `not ok [0-9]+`. Beanstandet ist allein die
  vierte Zeile (→ R5-2) und die fehlende Mutations-Absicherung von (b) (→ R5-9).
- geprüft, ohne Befund: **Die fünf Zeilen aus den Vorrunden sind unverändert und weiterhin
  tragfähig**, und der Abschnitt *„Was hier bewusst NICHT steht"* (`:355-362`) führt beide in
  Runde 1 gestrichenen Tautologien samt `--exclude-standard`-Mechanismus unverändert fort. Es ist
  **keine** neue tautologische Zeile hinzugekommen; der Defekt bei `:353` ist kein Tautologie-,
  sondern ein Ausführbarkeits-Defekt.
- geprüft, ohne Befund: **Form nach Modul 4 und Vorlage.** Gegen
  `.harness/baseline/v3.5.2/templates/docs/plan/adr/NNNN-titel.template.md` abgeglichen: die
  Block-Reihenfolge (Kontext · Entscheidung · Verglichene Alternativen · Konsequenzen · Fitness
  Function · Re-Evaluierungs-Trigger · Geschichte) ist **exakt** eingehalten; alle Kopf-Felder
  vorhanden (Status · Datum · Autor · Bezug · Schärft); **fünf** Alternativen (≥ 3 nach
  §Ziel-Form), jede mit Pro **und** Contra; die Listen-Nummerierung von Festlegung 1 ist repariert;
  kein Template-Hinweis-Block; das Dokument endet sauber ohne Fremd-Markup. **Zwei Formsachen**,
  die ich ausdrücklich nicht als Finding führe, weil ihnen ein Failure-Szenario fehlt: die
  Konsequenzen führen **Folgepflicht 5 vor Folgepflicht 4** (`:318` vor `:322`), und Alternative E
  steht in der Tabelle vor D. Der einzige Form-**Mangel** mit Wirkung ist die fehlende
  `Geschichte`-Zeile (→ R5-4).
- geprüft, ohne Befund: **Doc-Gate-Regeln.** Eigener Lauf dieser Sitzung: `make docs-check` →
  **d-check 233 Dateien, 0 Befunde** — die Zahl der Commit-Message ist damit unabhängig bestätigt.
  Alle `LH-`/`ADR-`/`MR-`-Kennungen der neuen Abschnitte sind als Link geführt, die relativen
  Tiefen aus `docs/plan/adr/` stimmen, die neu genannten Inline-Pfade existieren. Der im
  Commit beschriebene Backtick-Defekt ist real behoben (slice-059 `:49`).
- geprüft, ohne Befund: **[`AGENTS.md`](../../AGENTS.md) §3.4 und §3.5.** Die Überarbeitung
  betrifft eine *Proposed*-ADR, überschreibt keine *Accepted*-ADR, beansprucht kein *Supersedes*
  und lockert kein Gate. `.claude/settings.json` ist im Diff **nicht** enthalten (gemessen an
  `git show 5bebbb4 --stat`); Guard und Stop-Hook sind unverändert. Status ist im Dokument (`:3`),
  im Index und in welle-09 **Proposed**; slice-059 liegt in `open/`, `next/` ist leer (gemessen).
- geprüft, ohne Befund:
  **[`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler).**
  `git show 5bebbb4 --stat` → vier Dateien, **kein** `spec/lastenheft.md`. Die ADR ändert kein
  `LH-*`, sie referenziert nur. Festlegung 5 hält die Ob/Wie-Teilung sauber und ist mit der neuen
  Formulierung (*„geschlossenes Schema mit fail-closed Default … ohne Inhalts-Hash"*) erstmals
  deckungsgleich mit dem, was die ADR im Repo entscheidet.
- geprüft, ohne Befund:
  **[`MR-002`](../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks),
  [`MR-003`](../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)
  und [`MR-005`](../../harness/conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption).**
  Die Herleitung von Festlegung 3 (ein Span im getrackten Baum bräche den inhaltsbasierten
  Nachweis, der Stop-Hook blockierte sich selbst) ist unverändert und in drei Vorrunden bestätigt;
  der gitignorierte Zustands-Bereich ist der korrekte Ablageort (`.gitignore:5` führt
  `.harness/state/`, `git ls-files .harness/state` ist leer). Der Ablageort für den Emitter selbst
  bleibt der ADR überlassen; slice-059 verortet ihn unter `harness/tools/`.
- geprüft, ohne Befund: **Kollision mit aktiven ADRs — weiterhin keine.**
  [`ADR-0003`](../plan/adr/0003-go-native-binaries.md) bindet den Tool-Build und wird von einem
  Hook-Skript nicht berührt; [`ADR-0004`](../plan/adr/0004-durchsetzungs-emission.md) trägt die
  bash/awk-Bauart, an die Festlegung 4 in korrekt eingegrenzter Weise anknüpft.
- geprüft, ohne Befund: **Quadranten-Kennzeichnung der Re-Evaluierungs-Trigger.** Gegen
  `grundlagen-klassifikation.md` §2×2-Matrix und `grundlagen-durchsetzungsschicht.md` §Quadranten-
  Tabelle geprüft: alle sechs Trigger tragen eine ehrliche *feedforward*-Kennzeichnung, keiner
  behauptet einen Sensor, den es nicht gibt. Die Latenz-Schwelle (50 ms im Median) ist vom Diff
  nicht berührt, nennt ihre Herkunft (*„eine Setzung, keine Messung"*) und ihre Änderungsregel.
- geprüft, ohne Befund: **Die Entscheidung selbst.** Ich habe sie ergebnisoffen erneut gegen die
  Alternativen gelesen: lokale Erfassung mit Policy, abgeleitete Werte mit benanntem Gegner,
  Ablage außerhalb des versionierten Baums, fail-open im Betrieb bei fail-closed Umfang,
  Randbedingung „vorhanden statt zu installieren", Ob/Wie-Teilung. **Kein Punkt davon ist
  strittig**, und keiner der zwölf Befunde dieser Runde verlangt, eine Festlegung zu ändern —
  alle betreffen Belege, Sensoren, Nachzieh-Kanten und Randfälle der Umsetzung.

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 2 |
| MEDIUM | 6 |
| LOW | 3 |
| INFO | 1 |

**Herkunft der Befunde.** **7** von 12 existieren erst seit der fünften Fassung (R5-1, R5-2, R5-3,
R5-4, R5-5, R5-6, R5-9) — darunter **beide HIGH**. **5** sind Reste aus den Vorrunden
(R5-7 = Rest von R4-6, R5-8 = Rest von R4-10, R5-10 = R3-5/R4-15, R5-11 = Rest von R4-16,
R5-12 = R2-14/R3-12/R4-17).

**Trend über fünf Runden:** HIGH 2 → 3 → 1 → 3 → **2**; Gesamtbefunde 11 → 15 → 12 → 17 → **12**.
Zehn der siebzehn Runde-4-Befunde sind in der Sache gelöst, keiner wurde umformuliert statt
behoben, und zwei Dauerbrenner sind nach vier bzw. fünf Runden erledigt (R4-14/`LH-QA-01` im Body,
R4-12/slice-059). Die Fehlerklasse bleibt dort, wo Runde 4 sie verortet hat — **Ausführung der
Überarbeitung, nicht Entscheidung** —, und sie ist enger geworden: beide HIGH dieser Runde sitzen
in **demselben** Reparatur-Absatz.

## Verdikt

**Kann ADR-0011 in dieser Fassung auf *Accepted* gesetzt werden: nein.** Der Abstand ist der
kleinste aller fünf Runden, und er ist auf eine einzige Reparatur zusammengeschrumpft.

**Blockierend (2) — beide im selben Absatz, beide ohne Änderung einer Festlegung behebbar:**

1. **R5-1:** Der Absatz, der die falsche Sensor-Zusage aus R4-1 ersetzt, stellt die falsche
   Sensor-**Verneinung** an ihre Stelle. Gemessen: `test/mutate-driver.bats:104` assertiert
   `[ ! -e "$dest/.harness/state" ]`, `make test-bats` liefert `ok 89`, und `make test` läuft in
   `make gates`. Der Zustands-Ausschluss ist durch ein **Gate** bewacht; unbewacht ist allein die
   Haltbarkeit dieses Zahns. Die ADR sagt „kein Sensor meldet es" und stützt darauf eine
   Folgepflicht.
2. **R5-2:** Die Fitness-Function-Zeile, die R4-1 einlösen soll, ist im realen `make mutate`
   nicht rot zu bekommen. Der Sensor läuft in der isolierten Kopie, und die Kopie enthält
   `.harness/state` nicht — die Mutation maskiert sich selbst. Real gemessen: das Archiv der
   Isolations-tar trägt 0 Einträge unter `harness/state` und 1930 unter `./.git/`; genau deshalb
   funktioniert Fall 74 und dieser nicht. Es ist die Klasse, wegen der Runde 1 zwei Zeilen streichen
   ließ und die die ADR selbst als ihre Lehre führt.

**Vor der Umsetzung zu erledigen (6 MEDIUM) — blockierend für *Accepted*, weil
[`AGENTS.md`](../../AGENTS.md) §3.4 den Text danach einfriert, aber nicht für die Entscheidung:**
die verschweißte Aggregations-Regel (R5-3), die fehlende `Geschichte`-Zeile samt Drei-Wege-Drift
(R5-4), die Überschrift „Lebensdauer: die Sitzung" und das Aufräum-Ziel ohne Folgepflicht (R5-5),
die nicht zusammengeführte Ablage der Ströme (R5-6), die Entscheidbarkeit der Default-Auslösung
(R5-7) und der Allowlist-Rest in Fitness Function und Konsequenzen (R5-8).

**Formsache (3 LOW / 1 INFO):** die fehlende Mutations-Absicherung der stdout-Setzung (R5-9), die
GNU/BSD-Dialektfrage (R5-10), die Transkript-Abhängigkeit des Cache-Status (R5-11), die
Verzeichnis-Rechte (R5-12). Dazu die zwei benannten Reihenfolge-Formsachen ohne Failure-Szenario.

**Antwort auf Leitfrage 1 — tragen die zehn Eingriffe?** Acht ja, zwei mit Rest, einer trägt nicht:

- **Zusammengeführte Regel 1.4/1.5:** trägt vollständig. R4-2 ist restlos erledigt.
- **Randfälle der Ableitung:** trägt. Beide Randfälle sind an meinem eigenen Bestand nachgemessen
  und so entschieden, dass ein Dritter sie ohne Rückfrage umsetzen kann.
- **Fail-closed Default-Zeile:** trägt für den benannten Fall (Agenten-Werkzeug mit Freitext-Prompt)
  — und **schließt nicht alles ein**: die Auslösebedingung „steht hier nicht" ist gegen Gattungen
  geprüft, nicht gegen Namen, und auf diesem Pfad gehen Argumente doch durch (→ R5-7).
- **Kein Inhalts-Hash auf der emittierten Ebene:** trägt, und die Incident-Frage bleibt dort
  beantwortbar — „wohin" vollständig, „was" als Länge. Die emittierte Fassung wird **nicht**
  wertlos; R4-7 ist an der Wurzel gelöst.
- **Aufräumen nur der eigenen Datei:** die Entscheidung trägt und ist die richtige Antwort auf die
  Nicht-Entscheidbarkeit von „läuft die noch?". Der Preis ist **tragbar**, aber er **widerspricht**
  der eigenen Überschrift „Lebensdauer: die Sitzung", und das dafür benannte `make`-Ziel hat weder
  Folgepflicht noch Sensor (→ R5-5).
- **Nummernkreis je (Sitzung, Agent):** ist mit den dokumentierten Payload-Feldern **umsetzbar**
  (die Abwesenheit von `agent_id` ist im Hauptkontext selbst der Diskriminator, und die Quelle
  nennt genau diese Verwendung) — und **schafft** eine neue Lücke: mehrere Ströme, deren
  Vollständigkeit einzeln, aber nicht gemeinsam prüfbar ist (→ R5-6).
- **Vier neue Fitness-Function-Zeilen:** drei sind rot zu bekommen, mit Sensoren, die dieses Repo
  hat; *„stdout leer, auch das der Kindprozesse"* ist prüfbar und ehrlich begrenzt. Die vierte ist
  der Blocker R5-2.
- **Folgepflicht 5:** die Konstruktion *„benannte Lücke statt Zusage"* wäre **tragfähig** —
  [`AGENTS.md`](../../AGENTS.md) §3.6 erlaubt ausdrücklich, zu benennen, *dass nichts deckt*, und
  eine so benannte Lücke ist keine Zusage mit Zeitverzug. Sie trägt hier nur deshalb nicht, weil
  ihre Tatsachengrundlage falsch ist (→ R5-1): sie beauftragt Arbeit für eine Lücke, die es in
  dieser Form nicht gibt, und benennt die Lücke nicht, die es gibt (die fehlende
  Haltbarkeits-Messung).
- **Korrigierte Aggregations-Aussage:** die Richtung ist richtig und stärkt das Argument; die
  Formulierung verschweißt zwei Mechanismen, die die Quelle auf disjunkte Ereignisse legt (→ R5-3).
- **Bedrohungsmodell mit benannter Lücke:** methodisch weiter der beste Teil dieser ADR; zwei
  seiner drei Messungen sind erneut bestätigt, die dritte ist der Blocker.

**Antwort auf Leitfrage 2 — konvergiert das?** **Ja, und sichtbarer als in jeder Vorrunde.** Die
Entscheidung ist nach fünf Runden unverändert unstrittig; die Zahl der Befunde fällt von 17 auf 12,
die HIGH von 3 auf 2, und beide verbleibenden HIGH stehen in **einem** Absatz von sieben Zeilen
plus **einer** Tabellenzeile. Zwei Befunde, die vier bzw. fünf Runden überlebt hatten, sind
erledigt. Was bleibt, ist keine Architekturfrage mehr, sondern eine Messung, die vor dem Schreiben
hätte laufen müssen.

**Trägt die ADR jetzt genug, um slice-059 zu entsperren? Nein** — aber der Grund ist eng geworden:
der Slice würde heute einen Mutations-Fall bauen, der dauerhaft als Befund meldet (R5-2), und einen
Wächter für eine Eigenschaft, die schon einen hat (R5-1). Sein eigener Plan ist dagegen zum ersten
Mal vollständig nachgezogen (R4-12 erledigt).

**Was ausdrücklich trägt und nicht anzufassen ist.** Die abgeleitete Redaktion mit benanntem
Bedrohungsmodell und jetzt ebenen-abhängigem Hash-Verzicht; Festlegung 4 als Kriterium statt Liste;
die Ob/Wie-Teilung, die mit dieser Runde erstmals in beiden Richtungen deckungsgleich ist; die
Ehrlichkeit über die Restlücken der Folgenummer; die Klammern, die die eigenen widerlegten
Fassungen benennen statt sie zu glätten. Form nach Modul 4 vollständig, Status nirgends
vorgreifend, keine Kollision mit einer aktiven ADR, `make docs-check` 233/0, `make test-bats`
127/127 grün.

**Übergabe:** an den **ADR-Autor** (Rückkante Review → Architektur/Planung; die ADR bleibt
*Proposed*); die Anteile R5-4 (welle-09) zusätzlich an die **Planung**; R5-1/R5-2 zusätzlich an die
**Implementation** als Sensor-Bedarf — nicht als neuer Wächter, sondern als
Haltbarkeits-Messung für den vorhandenen, und mit der in R5-2 gemessenen Grenze des
Mutations-Harness. Als **Steering-Loop-Eintrag** (dritte Wiederholung derselben Klasse): eine
Aussage über einen Sensor gehört vor dem Schreiben gelaufen, nicht gegrept. Es gibt keinen
Produktiv-Diff. slice-059 bleibt in `open/`. Der Report ersetzt keine Verifikation —
DoD-Konformität prüft der Verifier separat (Modul 11; anderes Prüf-Artefakt, anderer
Eingabe-Kontext).
