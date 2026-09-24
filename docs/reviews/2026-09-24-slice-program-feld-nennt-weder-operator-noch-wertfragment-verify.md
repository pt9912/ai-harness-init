# Verifikationsbericht: slice-program-feld-nennt-weder-operator-noch-wertfragment — 2026-09-24

**Rolle:** Verifier (Modul 8/11) — Frage: *Bauen wir es richtig?* gegen Plan, DoD und Spec. Nicht die
Frage des Reviewers (Diff gegen Plan, ADR, Hard Rules) und nicht die des Validators.

**Gegenstand:** `docs/plan/planning/in-progress/slice-program-feld-nennt-weder-operator-noch-wertfragment.md`
am Stand `main` = `1e3b83b3`; Implementer-Commits `2efaa979` und `fb1ca361`, Reviewer-Reports Runde 1
(`68f35541`) und Runde 2 (`1e3b83b3`, freigabefähig). Nichts gepusht. Der Slice ist **nicht** geschlossen;
dieser Bericht setzt kein DoD-Häkchen und ändert weder Slice noch Code noch ADR (`AGENTS.md` §3.10).

**Bezug:** `LH-FA-10` · `ADR-0011` (Wert-Grenze: Werte nie im Span) · `ADR-0022` (Träger) · `MR-019` ·
`SPEC-031` / `SPEC-021` (`spec/spezifikation.md` §5) · `MR-071` (sed-Anker) · `AGENTS.md` §3.6.

**Methode:** Alle Läufe hermetisch über Docker (`make test-go`, Dockerfile-`test`- und `build`-Stage), alle
Mutationen in einer `git archive`-Kopie von `HEAD` im Scratchpad — nie im Repo-Baum. Kein Host-Go.

---

## Gesamturteil

**Die DoD ist in allen drei Liefer-Punkten inhaltlich erfüllt; ein Punkt ist von mir nicht am Endstand
belegbar: `make mutate` → `0 Befund(e)` (Befund V-1, MEDIUM).** Der Reviewer-Befund F-6 berührt **keinen**
DoD-Punkt (der Plan verlangt nirgends, dass Zeilen ohne Zuweisung unverändert bleiben); er gehört als
Beobachtung ins Register. Die drei DoD-Gegenbeispiele (a)(b)(c) sind gegen den realen Vorzustand und gegen
reale Mutationen rot gesehen, mit gelesener Meldung. Kein Wert-Leck gefunden.

Damit ist die Verifikation **grün mit einer Auflage an den Planner**: vor der Closure braucht Closure-Trigger 1
(§5: „`make mutate` meldet `0 Befund(e)`") einen frischen `make mutate`-Lauf am Endstand (V-1).

---

## Gelaufene Sensoren (Kommando und Ausgang)

| Sensor | Ergebnis |
|---|---|
| `git diff --stat fb1ca361 HEAD -- internal spec test harness` | leer — seit `fb1ca361` kam nur Doku dazu (`git diff --name-only 2efaa979~1 HEAD` nennt außerhalb von `internal/span/`, `spec/`, `test/mutations/404–408` nur `docs/reviews/*` und `docs/plan/planning/open/slice-emittierte-dateien-behalten-lf-im-autocrlf-klon.md`, einen fremden Slice) |
| `make test-go` | `ok  …/internal/span`, Exit 0 |
| Working-Tree-Stempel: `cut -c1-12 .harness/state/gates-passed.diffsha` gegen `bash harness/tools/working-tree-hash.sh` | beide `914455120302` — der Stempel deckte den Baum **vor** diesem Bericht (Nachlauf: Ende des Berichts) |
| Fälle 404, 405, 406, 407, 408 einzeln in der Kopie (`bash test/mutations/<n>-*.sh`, dann Docker-`test`-Stage) | je rot, s. §Bewusstes Brechen |
| Die vier Altfälle auf `internal/span/` (108, 132, 133, 135) einzeln in der Kopie | je rot im erwarteten Test (`TestUnknownToolStaysSilent`, `TestAgentGetsNoArgumentFields` ×2, `TestOnlyAgentToolGetsResponseValues`) — die Anker sind durch den Diff nicht verrutscht |
| `grep -c` der fünf sed-Anker aus 404–408 gegen `internal/span/span.go` der Kopie | `1 1 1 1 1` (MR-071) |
| Realer Vorzustand: `span.go` aus `2efaa979~1` + `span_test.go` von `HEAD` | rot in `TestCommandProgramNamesAProgramNotAnOperator`, `…NeverEmitsAssignmentValueFragments`, `…WithholdsProgramForEachUnsureValueChar`; `TestCommandProgramSkipsAssignments` bleibt grün |
| Eigene Mutation (c) (s. unten) | rot in `…NeverEmitsAssignmentValueFragments` mit Meldung „Wert oder Wert-Bruchstueck im Span" |
| F-7-Mutanten (`&` bzw. `)` aus `shellMetaStart` entfernt), volle Suite | beide `rc=0` — grün (bestätigt den Reviewer) |
| Träger: `make`-äquivalenter Bau (`docker build --target build`, Host-Plattform) und `span-emit` in einem Temp-Repo im Scratchpad | s. §Träger-Beleg |
| **`make mutate`** | **nicht am Endstand belegt — s. V-1** (mein Versuch, den Beleg-Übersprung zu bestätigen, hat den Beleg-Slot gelöscht) |

---

## DoD, Punkt für Punkt

### Liefer-Punkt 1 — `commandProgram()` nennt ein Programm oder nichts

| DoD-Aussage | Urteil | Beleg |
|---|---|---|
| Tabelle aus §1 als Tests, nach der Eigenschaft benannt, über `span.Derive` **und** die geschriebene Zeile | **erfüllt** | Jede der 13 Tabellenzeilen ist ein Fall: `TestCommandProgramNamesAProgramNotAnOperator` (Segment-Zeilen, `A=b \|\| cmd`, `A=b &&`, `A=b ;`, `(A=b; cmd)`, `TOKEN=x && gh pr create`), `TestCommandProgramNeverEmitsAssignmentValueFragments` (`TOKEN="abc SECRET" gh pr create`, `A="x && SECRET" cmd`, `T=$(date SECRET); make`, `` A=`x SECRET` cmd ``) — die Wert-Fälle tragen `SECRET` statt `def`/`y`, gleiche Klasse. Beide laufen über `span.Derive` **und** `bashSpanLine` → `span.Emit` (`Parse`/`Build`/`Append`, derselbe Weg wie `span-emit`), Prüfung an der geschriebenen Zeile (`strings.Contains(line, "SECRET")`, `"program"`, `"argc"`). |
| `TestCommandProgramSkipsAssignments` grün und unverändert | **erfüllt** | `git diff 2efaa979~1 fb1ca361 -- internal/span/span_test.go` enthält nur Additionen; im Vorzustand-Lauf bleibt der Test grün. |
| Was bricht die Zusage, rot gesehen (a)(b)(c) | **erfüllt, mit Nuance zu (a)** | s. §Bewusstes Brechen |
| Kommentar über `commandProgram()` beschreibt die jetzige Zusage und nennt seine Wächter beim Namen | **erfüllt** | Der Kommentar nennt Segment-Grenze, Wert-Grenze, `argc` und vier Tests; alle vier existieren (`grep -n '^func TestCommandProgram' internal/span/span_test.go`). |

### Liefer-Punkt 2 — Fälle in `test/mutations/`

| DoD-Aussage | Urteil | Beleg |
|---|---|---|
| Ein Fall Segment-Grenze, ein Fall Wert-Grenze, mit `# files: internal/span/span.go` und `# expect:` = Test aus LP 1 | **erfüllt** (404 Segment, 405 Wert) | Kopfzeilen gelesen; `expect:` nennt `…NamesAProgramNotAnOperator` bzw. `…NeverEmitsAssignmentValueFragments` — beide Namen existieren. Gebaut sind **fünf** Fälle statt zwei (406–408), s. Plan-vs-Code. |
| sed-Muster nach der Implementierung gegen den Quell-Bestand gemessen; trifft genau eine Stelle; färbt die Zeile des erwarteten Tests | **erfüllt** | `grep -c` je Anker → 1 (Endstand, `git archive HEAD`); Mutation wirksam (`cmp` gegen das Original) und der **benannte** Test wird rot (unten). |
| Gegenprobe (geschwächte Zusicherung) steht in der Closure-Notiz | **offen — Planner/Closure** | §7 ist leer, wie vorgesehen (§3.10). Die stärkere Richtung habe ich selbst gefahren: der Quelltext wird geschwächt, der benannte Test wird rot. |
| Fall der Wert-Grenze trifft den stillen Pfad | **erfüllt** | Fall 405 entfernt die Prüfung; nichts stürzt, das Programm wird falsch (`SECRET"`); rot wird der Wächter, der die geschriebene Zeile liest. |
| `make mutate` läuft mit den neuen Fällen und meldet `0 Befund(e)` | **nicht belegbar durch mich am Endstand** | V-1. Die fünf neuen und vier benachbarte Fälle habe ich einzeln rot gesehen; das ersetzt den Gesamtlauf über die übrigen Fälle nicht. |

### Liefer-Punkt 3 — `SPEC-031`

| DoD-Aussage | Urteil | Beleg |
|---|---|---|
| Die `Bash`-Zeile nennt Zuweisungs-Segmente, den Wert mit unbestimmbarem Rand (dann kein Feld), die unveränderte Bedeutung von `argc` | **erfüllt** (mit V-3) | `grep -n 'SPEC-031' spec/spezifikation.md` → Zeile 132; `git diff 2efaa979~1 HEAD --stat -- spec` → 1 Datei, 1 Zeile geändert. |
| `SPEC-021` gegengelesen, bleibt wahr | **erfüllt** | Zeile unverändert (`git diff … -- spec` berührt sie nicht); *erstes Token / Argument-Anzahl / nie die Kommandozeile* bleibt wahr; die Spannung *erstes Token* gegen *erstes Wort* ist F-5 (bewusst, Plan §1, `slice-109`). |
| Lastenheft nicht angefasst | **erfüllt** | `git diff --name-only 2efaa979~1 HEAD` nennt keine Lastenheft-Datei. |
| §7 benennt, dass für das Stratum keine schreibende Rolle benannt ist (`slice-151`), leitet keine Zuständigkeit ab | **offen — Planner/Closure**; Diff leitet nichts ab | Die geänderte Zeile trägt keinen Rollen- oder Zuständigkeitsbezug; die Commit-Messages nennen nur `Rolle Implementer`. |

### Pro-Slice-konstant

| Punkt | Urteil | Beleg |
|---|---|---|
| `make gates` grün | **erfüllt am Stand vor diesem Bericht** | Stempel deckte den Baum (`914455120302`); Nachlauf am Ende dieses Berichts. |
| Review durchgeführt, Report unter `docs/reviews/` | **erfüllt** | zwei Reports (Runde 1, Runde 2), beide committet, Rolle Reviewer. |
| Closure-Notiz, Register, Risiko-Ausgänge, Paarungen | **offen — Planner** (§3.10); Eingaben unten |

---

## Bewusstes Brechen (Modul 11)

Die Zusage ist korrektheits- **und** sicherheitskritisch (Wert-Leck, `ADR-0011`); der Rot-Beleg ist darum von
mir gefahren, nicht aus dem Implementer-Bericht übernommen.

**Realer Vorzustand** (`span.go` von `2efaa979~1`, Tests von `HEAD`): rot in den drei neuen Tests. Gelesene
Meldung, Beispiel: `Derive: program = "&&", erwartet "gh" (Zeile "TOKEN=x && gh pr create")`. Die Ausgabe
zeigt Operatoren und Wert-Bruchstücke im Feld (`grep -oE '"program":"[^"]*"'` über das Build-Log: `"&&"` ×12
(JSON `&&`), `SECRET` ×9, `;`, `>f`, `<<<SECRET`, `SECRET}`, `` SECRET` ``).

**(a) Operator wird nicht übersprungen** — Fall 404, gegen die reale Mutation:
`Derive: program = "", erwartet "cmd" (Zeile "A=b && cmd x")`, dazu `;`, `|`, `&`-Zeilen; Test
`TestCommandProgramNamesAProgramNotAnOperator` — der benannte. **Nuance:** die DoD-Formulierung *„liefert
`&&`"* stellt die Mutation 404 **nicht** mehr her: seit `namesProgram` (Runde-1-F-2-Fix) fängt eine zweite
Sperre das Feld `&&` ab, die Mutation liefert *nichts* statt `&&`. Die wörtliche Aussage belegt der reale
Vorzustand (oben, `&&` im Feld). Der Test bindet die Segment-Grenze aus dem richtigen Grund (erwartet `cmd`,
bekommt nichts) — kein Widerspruch zur DoD, aber eine Wortlaut-Differenz (V-2).

**(b) Wert-Prüfung fehlt** — Fall 405: rot in `TestCommandProgramNeverEmitsAssignmentValueFragments` mit
`Wert oder Wert-Bruchstueck im Span fuer "TOKEN=\"abc SECRET\" gh pr create"`, ebenso
`'abc SECRET'`, `"x && SECRET"`, `$(date SECRET)`, `` `x SECRET` ``, `x\ SECRET`. Nachweis an der
**geschriebenen Zeile**, nicht an `Derive`.

**(c) Wert-Schutz `TOKEN=x && gh …`** — eigene Mutation, nicht die eines Falls: im `default`-Zweig gibt
`commandProgram` bei vorausgegangener Zuweisung `fields[0]` zurück (der Wert läuft in `program`). Rot in
`…NeverEmitsAssignmentValueFragments`: `Wert oder Wert-Bruchstueck im Span fuer "TOKEN=SECRETVALUE && gh pr
create"` sowie `…; gh pr create` und `A=1 TOKEN=SECRETVALUE B=2 gh pr create` (`program = "A=1"`).
Zusätzlich rot in `NamesAProgramNotAnOperator` und `SkipsAssignments` (Programm falsch).

**Fälle 406–408** (Zusatz, Runde 2): 406 (`strings.Fields` statt `splitWords`) rot in `NamesAProgramNotAnOperator`
(`A=b<NBSP>SECRET cmd x`: `program = "SECRET"`, argc 2) und `NeverEmitsAssignmentValueFragments` (sieben
Leerraum-Fälle) — `expect:` nennt den zweiten, korrekt; 407 (`namesProgram` ohne Zeichenprüfung) rot mit
`program = "|&"`, `";;"`, `"!"`, `"(cmd"`; 408 (Ziffernregel entfernt) rot **genau** in `2>&1`, `12>f`,
`3<f`. Polarität stimmt in allen: Mutation färbt rot, der benannte Test trägt das Rot.

---

## Spec-Konformität (Schwerpunkt 3)

- **`SPEC-031` gegen den Code:** Wert-Menge im Text `"` `'` `` ` `` `\` `(` `)` `{` `}` `;` `&` `|` `<` `>`
  (13) gegen `unsureValueChars = "\"'`\\(){};&|<>"` (13): deckungsgleich. Metazeichen im Text `|` `&` `;` `(` `)`
  `<` `>` `#` `!` `{` `}` (11) gegen `shellMetaStart = "|&;()<>#!{}"` (11): deckungsgleich. Wortgrenzen
  (Leerzeichen, Tab, Zeilenende) gegen `splitWords`: gleich. Ziffernfolge vor `<`/`>`: gleich. „Kein Feld bei
  unbestimmbarem Wert": gleich (`argc` entfällt mit; Tabellentests prüfen beide Felder).
- **Eine Lücke der Spec-Aussage (V-3):** die Aufzählung nennt `;` unter den Zeichen, bei denen der Rand *im Wert*
  nicht bestimmbar ist, und sagt nichts zu einem **einzelnen `;` am Wertende** (`A=b; cmd x` → `cmd`).
  Code (`valueEdgeKnown` trimmt ein Suffix-`;`), Plan-Tabelle (Zeile 2) und Test sagen `cmd`; ein Leser der
  Spec-Zeile folgert *nichts*.
- **`SPEC-021`** bleibt wahr; unverändert.
- **Rollen-Eigentum am Spec-Stratum:** der Diff leitet nichts ab (`slice-151` bleibt die Adresse).

---

## Plan-vs-Code-Diff

**Gewahrt (Nicht-Gegenstand):** `git diff --name-only 2efaa979~1 HEAD` — kein `internal/emit/`, kein `cmd/`, kein
`Makefile`, kein `harness/`, kein `internal/span/fieldlist.go`, kein `internal/span/emit.go` (JSON-`&`-Schreibweise
unberührt), keine `slice-204`-Datei; kein `cd`/`set`-Überspringen, kein Tokenizer (keine Quote-/Klammer-Tiefe),
`argc` weiter `len(fields) - i - 1`. Slice-Datei unverändert, kein DoD-Häkchen gesetzt (`AGENTS.md` §3.10).

**Gebaut, aber nicht geplant** (Planner soll es in §7 festhalten; kein DoD-Verstoß, ein Plan-Delta):

1. **Drei Fälle mehr als „zwei"** (406, 407, 408) plus der Tabellentest `…WithholdsProgramForEachUnsureValueChar`.
   Ursache: Runde-1-Befunde F-1 (HIGH, Unicode-Leerraum im Wert leckte `SECRET` als `program`), F-2, F-3.
2. **Verhalten über die Plan-Tabelle hinaus:** `splitWords` (Wortgrenze nur Leerzeichen/Tab/Zeilenende, für
   **jede** Zeile), `namesProgram` + `shellMetaStart` (nach einer Zuweisung ist ein Wort mit Metazeichen oder
   Redirect kein Programm → nichts). Der Plan-Rahmen (§1 „fail-closed", Wert-Grenze) trägt es; die Tabelle
   listet es nicht.
3. **`SPEC-031` ist länger als geplant** (Zeichenmengen, Wortgrenzen) — folgt aus 2.

**Geplant, nicht gebaut:** nichts gefunden. Alle Tabellenzeilen des Plans sind Tests.

---

## Findings

| ID | Schwere | Befund | Berührt DoD? |
|---|---|---|---|
| V-1 | MEDIUM | **`make mutate` → `0 Befund(e)` ist von mir am Endstand nicht bestätigt.** Der Beleg des Implementers (`396 ok, 0 Befund(e)`, `.harness/state/mutate-passed.key`, Stand 09:03) ist eine Aussage, die ich nicht nachprüfen konnte: `git diff --stat fb1ca361 HEAD -- internal spec test harness` ist leer, aber der Beleg-Schlüssel hängt am **ganzen** Baum (`isolation_key`, `harness/tools/mutate.sh`), und zwei Klone von `fb1ca361` und `1e3b83b3` (`git clone` im Scratchpad, dann `bash -c 'source harness/tools/mutate.sh; isolation_key'`) geben verschiedene Schlüssel — ein Doku-Commit (hier der Reviewer-Report) entwertet den Übersprung. **Eigener Fehler, benannt:** ich habe versucht, den Übersprung mit `make mutate` unter `timeout 120` zu bestätigen. Der Schlüssel stimmte nicht; das Skript begann einen echten Lauf, löschte den Beleg-Slot (`clear_belief`, ADR-0035, so gebaut) und wurde von meinem `timeout` per SIGINT beendet (Exit 130, kein `mutate.lock` zurück, `git status` sauber). **Folge:** der nächste unerzwungene `make mutate` fährt voll (~50 min); die Aussage des Implementers steht nur noch als Aussage. Ersatzbeleg von mir: 404–408 und die vier Altfälle auf `internal/span/` einzeln rot mit erwartetem Test (oben). | ja — LP 2, Haken 4, und Closure-Trigger 1 (§5). **Auflage:** ein `make mutate`-Lauf am Endstand vor der Closure. Wahrscheinlich grün, aber von mir nicht gesehen. |
| V-2 | INFO | DoD (a) sagt *„liefert `&&`"*; die Mutation 404 liefert nach dem F-2-Fix *nichts*. Der Test bindet die Segment-Grenze aus dem richtigen Grund; der wörtliche Zustand ist nur im realen Vorzustand herstellbar (belegt). | nein — Wortlaut-Differenz, Zusage gehalten |
| V-3 | LOW | `SPEC-031` nennt `;` in der Zeichenmenge der unbestimmbaren Wert-Ränder und sagt nichts zum Wert-Ende `A=b;` (→ `cmd`). Die Spec-Zeile ist an dieser Stelle **enger als der Code** und stimmt für `A=b; cmd x` nicht mit Plan-Tabelle und Test überein. Korrektur ist Spec-Text (Rolle offen, `slice-151`), kein Code. | nein — LP 3 verlangt die Nennung der Mechanik; die Zeile ist in einem Fall ungenau, kein DoD-Wortlaut bricht |
| F-6 (Review) | LOW | `make\r` → `program="make\r"`, `ls<NBSP>-l` → `program="ls<NBSP>-l"` (argc 0). **Selbst gemessen** mit dem gebauten Träger: `make\r` → `"program":"make\r","argc":0`; `ls<NBSP>-l` → `"program":"ls<NBSP>-l","argc":0`; `make gates\r` → `make`/1 (unverändert); `A=b\r&& ls` → nichts. | **nein.** Der Plan verlangt an keiner Stelle, dass Zeilen ohne Zuweisung unverändert bleiben (§1 Ziel und Tabelle sprechen von *Zeilen mit Zuweisung*; DoD nennt nur `SkipsAssignments` „grün und unverändert" — er ist es). `SPEC-031` beschreibt die Wortgrenze wörtlich als für alle Zeilen geltend. Der Zahn: `splitWords` ist **eine** Funktion; Fall 406 mutiert sie und färbt rot — die Aussage über Zeilen ohne Zuweisung hat keinen *eigenen* Fall, wird aber von derselben Mutation getroffen. **Beobachtung:** Register-Eintrag bei der Closure (Sub-Area `*`, Belege: dieser Slice); Folge-Slice nur, falls jemand die Wortgrenze für Zeilen ohne Zuweisung zurücknehmen will. |
| F-5 (Review) | INFO | `SPEC-021` *erstes Token* gegen `SPEC-031` *erstes Wort nach Zuweisungen*. | nein — Plan §1 benennt es, `slice-109` führt die Feldliste |
| F-7 (Review) | LOW | **Bestätigt:** entfällt `&` oder `)` aus `shellMetaStart`, bleibt die volle Suite grün (`rc=0` in beiden Mutanten, wirksam gemessen). `<`/`>` sind äquivalente Mutanten (die Ziffernregel deckt dieselben Wörter). | nein — `shellMetaStart` ist Plan-Delta (oben); die DoD-Zusagen (Segment-/Wert-Grenze, `TOKEN=x && gh`) berührt es nicht. Beobachtung, Zahn nachziehen. |
| F-8 (Review) | INFO | Der Kommentar sagt *„nennt ein Programm oder NICHTS"*; Wörter mit `$`, `"`, `` ` `` in Programm-Position (`A=b $(echo SECRET) cmd` → `$(echo`) bleiben `program`. Kein Zuweisungs-Wert, Bestand ohne Zuweisung. | nein — die Wert-Grenze des Plans hält |
| F-9 (Review) | INFO | `…WithholdsProgramForEachUnsureValueChar` ist in `test/mutations/` nicht gelistet (405 färbt ihn nur mittelbar). | nein — Haltbarkeit, nicht Entstehung; §3.6-Feedback |

**Kernfrage F-6 gegen die DoD:** ausdrücklich **nicht** DoD-berührend. Ich habe die DoD wörtlich gelesen (§2 LP 1–3
und die Konstant-Punkte): keine Zeile verlangt Unverändertheit außerhalb von Zuweisungs-Zeilen, und die eine
Regressions-Zusage (`SkipsAssignments` grün und unverändert) ist gehalten.

---

## Träger-Beleg (Closure-Trigger 2)

Temp-Repo im Scratchpad (`git init`), Träger aus `docker build --target build` am Stand `HEAD`
(`ai-harness-init span-emit`, Payload per Here-String, `CLAUDE_PROJECT_DIR` auf das Temp-Repo):

| Payload `command` | Zeile im Strom |
|---|---|
| `A=b && ls` | `"program":"ls","argc":0` |
| `TOKEN="abc SECRET" gh pr create` | Span geschrieben (`"tool":"Bash"`, 1 Zeile), `grep -cE 'program\|argc\|SECRET'` → **0** |
| `A=b \|\| ls` | kein `program`, kein `argc` |

Damit gilt Closure-Trigger 2 als gemessen an der geschriebenen Zeile.

---

## Eingaben für die Closure (Planner entscheidet)

Ausgänge der Risiken aus §6 — **Vorschläge mit Beleg**, keine Zuweisung:

1. *Nenner verkleinert:* eingetreten in der geplanten Größe, **und** durch `namesProgram` etwas mehr (Wörter
   nach Zuweisung mit Metazeichen/Redirect → nichts). Preis gewollt → *entfallen* (mit Begründung) oder
   Register.
2. *Wert-Prüfung zu grob/fein:* nicht entfallen. Der HIGH der Runde 1 (Unicode-Leerraum) *ist* dieser Fall
   gewesen und behoben; Stichprobe bleibt Stichprobe → *weiter offen* (Register), Beleg F-8.
3. *Bestand mischt zwei Bedeutungen:* *weiter offen* (Register) — kein Feld trägt die Fassung.
4. *Zwei Slices an einer Funktion:* endet mit dem `git mv` dieses Slice (Start-Trigger von `slice-204`).
5. *Kein Rollen-Eigentum am Spec-Stratum:* *weiter offen* → `slice-151`.

Register-Kandidaten aus dieser Verifikation: F-6, F-7, F-8/F-9 (letztere zwei können unter einer
Bezeichnung laufen); `mutations-fall-deckt-den-lauten-statt-den-stillen-pfad` (Zähler 2× laut §8) — Fall 405/406
decken den **stillen** Pfad, also kein dritter Beleg für die Lücke.

---

## Nachlauf `make gates`

Der Stempel deckte den Baum vor diesem Bericht (`914455120302`). Nach dem Ablegen dieser Datei ändert sich der
Hash; der Nachlauf steht in der Commit-Message.
