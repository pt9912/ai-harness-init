# Review-Report: slice-program-feld-nennt-weder-operator-noch-wertfragment — Runde 2 — 2026-09-24

**Review-Art:** Diff — Nachrunde gegen Plan, ADR und Hard Rules (Modul 10). Nicht gegen die DoD (das ist
der Verifier). Die Runde-1-Datei
(`2026-09-24-slice-program-feld-nennt-weder-operator-noch-wertfragment.md`) bleibt unangetastet.

**Gegenstand:** Commit `fb1ca361` (Rolle Implementer, lokal, nicht gepusht; setzt auf `2efaa979` auf) —
6 Dateien: `internal/span/span.go` (`commandProgram`, neu `splitWords`, `shellMetaStart`,
`namesProgram`), `internal/span/span_test.go`, `test/mutations/406-*.sh`, `407-*.sh`, `408-*.sh`,
`spec/spezifikation.md` (`SPEC-031`).

**Plan-Bezug:** `docs/plan/planning/in-progress/slice-program-feld-nennt-weder-operator-noch-wertfragment.md`
(§1 Ziel und Verhaltenstabelle, §6 Risiken; unverändert durch `fb1ca361`).

**Skill:** `.harness/skills/reviewer.md` @ Version 2.0.0 · **Modell:** Sonnet 5 · **Datum:** 2026-09-24

**Eingangs-Kontext:** Diff `2efaa979..fb1ca361` · Slice-Plan · Runde-1-Report · `LH-FA-10` · `ADR-0011`
(Festlegung 2: Werte nie im Span) · `ADR-0022` · `MR-019` · `MR-071` · `spec/spezifikation.md`
SPEC-021/-031 · `AGENTS.md` §3 · Baseline-Module 5, 8, 10, 11, 13

**Eigene Sensor-Läufe dieses Laufs** (alle hermetisch über Docker; kein Host-Go):

- **Sonde A:** `git archive fb1ca361` im Scratchpad plus eine Test-Datei, die 105 Eingaben durch
  `span.Derive` schickt; gebaut über die Dockerfile-`test`-Stage. **Sonde B:** dieselbe Datei gegen
  `git archive 2efaa979` (Vorher/Nachher). Ausgabe über `t.Errorf`; der Arbeitsbaum des Repos blieb
  unberührt.
- **Mutations-Nachstellung in der Kopie:** die Fälle 406, 407, 408 (`bash test/mutations/<n>-*.sh` in der
  Kopie) je gegen die volle Suite; dazu 13 Mutanten, die je **ein** Zeichen aus `unsureValueChars`
  entfernen, und 11 Mutanten, die je **ein** Zeichen aus `shellMetaStart` entfernen. `make mutate` selbst
  **nicht** gefahren (Auftrag).
- **MR-071:** `grep -c` der drei `sed`-Anker aus 406/407/408 gegen `internal/span/span.go` → je `1`.
- `make test-go` im Repo → `ok internal/span`, EXIT 0.
- `git show --stat fb1ca361`; Diff-Lektüre; Fall-Dateien gegen `404`/`405`/`129`.
- `make gates` — siehe Ende des Reports.

---

## Stand der Runde-1-Findings

| Runde 1 | Kat. | Stand | Beleg |
|---|---|---|---|
| F-1 Unicode-/Steuer-Leerraum im Wert | HIGH | **behoben** | Sonde A: `A=b<U+00A0>SECRET cmd`, `…U+2003…`, `…U+3000…`, `…U+0085…`, `…\r…`, `…\v…`, `…\f…`, dazu `U+2028`, `U+200B`, `U+180E`, `0x1C`, `0x1F` → jeweils `program="cmd"`, argc 0 (Sonde B, Vorstand: `program="SECRET"`). Fall 406 färbt genau diese Zeilen rot (s. u.). |
| F-2 „Programm oder nichts" nach Zuweisung | MEDIUM | **behoben** | Sonde A: `A=b !cmd`, `A=b !SECRET`, `A=b 5>f cmd`, `A=b &>f cmd`, `A=b >&2 cmd`, `A=b <(x) cmd`, `A=b {a,b} cmd`, `A=b }cmd`, `A=b #`, `A=b 2>&1`, `A=b 09<f cmd`, `A=b <<<hunter2 cmd`, `A=b <<EOF cmd` → nichts (`has=false`); Sonde B: alle als `program` ausgegeben. Die Fälle `\|&`, `;;`, `(cmd`, `{`, `#SECRET` stehen in der Tabelle des Segment-/Wert-Wächters und sind mit `make test-go` grün. |
| F-3 sechs Randzeichen ohne eigenen Zahn | LOW | **behoben** | 13 Mutanten (je ein Zeichen aus `unsureValueChars` entfernt): in **jedem** färbt sich `TestCommandProgramWithholdsProgramForEachUnsureValueChar/A=x<c>y_cmd_z` rot; für `)` `}` `&` `\|` `<` `>` ist das der **einzige** rote Test (die Zahl der roten Zeilen: `)` 1, `}` 1, `&` 1, `\|` 1, `<` 1, `>` 1). |
| F-4 SPEC-031 enger als Code | INFO | **behoben** | SPEC-031 nennt 13 Zeichen der Wert-Menge und 11 der Metazeichen-Menge; Wortvergleich mit `unsureValueChars` und `shellMetaStart` deckungsgleich. |
| F-5 SPEC-021 „erstes Token" vs. SPEC-031 | INFO | **offen, bewusst** | Plan §1: `SPEC-021` bleibt, die Feldliste gehört `slice-109`; unverändert. |

---

## Findings (neu, Runde 2)

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-6 | LOW | Die Wortgrenze gilt jetzt für **jede** Zeile, nicht nur für Zeilen mit Zuweisung. Ohne Zuweisung bleibt ein Unicode-Leerraum, `\r`, `\v` oder `\f` Teil des ersten Wortes, und dieses Wort ist `program`. Sonde B → A: `make\r` `"make"` → `"make\r"`; `make\rgates` `"make"` (argc 1) → `"make\rgates"` (argc 0); `ls<NBSP>-l` `"ls"` (1) → `"ls<NBSP>-l"` (0); `make\vgates` ebenso. Das ist Shell-treu (die Shell führt ein solches Wort als **einen** Namen) und vom Implementer benannt. Der Plan sagt dazu weder in §1 noch in §6 etwas (dort geht es um Zuweisungs-Zeilen); es ist ein Nebeneffekt außerhalb des Slice-Gegenstands. Failure-Szenario: ein Kommando, in dem ein Modell NBSP statt Leerzeichen zwischen Programm und erstem Argument schreibt (`curl<NBSP>-sS<NBSP>https://host/?key=abc x`), trägt das Argument bis zum nächsten Leerzeichen im Feld `program` — vorher stand dort `curl`. SPEC-021 verspricht „nie die Kommandozeile"; die Shell lehnt so ein Kommando selbst ab (command not found), die Wahrscheinlichkeit ist gering, darum nicht eskaliert. Die Leser des Felds sind unberührt: `span-check.sh:122` und `full-smoke.sh:1310` prüfen `"program":"make"` an einer selbst erzeugten Zeile; `hook-overhead.sh:152` liest `program` mit `[^"]*` und baut daraus eine Platzhalter-Zeile (ein `\r` steht im JSON als Escape-Text, ein NBSP roh — beides bleibt ein zulässiger Wert). Kein Test bindet das Verhalten in Zeilen **ohne** Zuweisung: 406 mutiert auf `strings.Fields` und wird über Zuweisungs-Zeilen rot; die SPEC-031-Aussage „jedes andere Zeichen bleibt Teil seines Wortes" gilt für die Zeilen ohne Zuweisung ohne eigenen Zahn. | ADR-0011 Festlegung 2 · AGENTS.md §3.6 · Plan §1/§6 | internal/span/span.go:`splitWords`; spec/spezifikation.md SPEC-031 | ja — Sonde: `make\r`, `ls<NBSP>-l` über `Derive` | Verhaltensänderung außerhalb des Plans, ohne Zahn in der Zeilen-Klasse, die sie betrifft |
| F-7 | LOW | Zwei Zeichen aus `shellMetaStart` haben keinen eigenen Zahn: entfällt `&` (Mutant `"\|;()<>#!{}"`) oder `)` (Mutant `"\|&;(<>#!{}"`), bleibt die **gesamte** Suite grün (0 rote Zeilen; gemessen wie oben). Failure-Szenario: `A=b &>f cmd` bzw. `A=b ) cmd` würde `&>f` bzw. `)` als `program` nennen. Für `<` und `>` gilt dasselbe (0 rote Zeilen), aber dort deckt die Ziffernfolge-Regel dieselben Wörter (`rest[0] == '<' \|\| '>'` bei leerer Ziffernfolge) — der Mutant ist äquivalent, kein Befund. Für `\|` `;` `(` `#` `!` `{` `}` färbt jeder Mutant Test-Zeilen rot (2/2/3/4/2/2/4). | AGENTS.md §3.6 | internal/span/span.go:`shellMetaStart`; span_test.go (Tabelle des Segment-Wächters) | ja — Mutation je Zeichen | Zeichensatz-Mitglied ohne eigenes rotes Gegenbeispiel (dieselbe Klasse wie Runde-1 F-3, andere Menge) |
| F-8 | INFO | Der Funktionskommentar sagt „Eine Zeile mit Zuweisung nennt ein Programm oder NICHTS". Nach einer Zuweisung erscheinen als `program` weiter Wörter, die eine Expansion oder ein Quoting einleiten: `A=b $(echo SECRET) cmd` → `$(echo` (argc 2), `` A=b `cmd` `` → `` `cmd` ``, `A=b "x` → `"x`, `A=b $SECRET` → `$SECRET`, `A=b ${X} cmd` → `${X}`. Das ist **kein** Zuweisungs-Wert (er steht in Programm-Position und ist ohne Zuweisung Bestand); die Wert-Grenze des Plans hält (s. Negativbefund). Die Grenz-Zeile nennt „verschachtelte Substitution", nicht das Expansions-Wort in Programm-Position; die Zusage „ein Programm" ist enger im Wort als im Code. | AGENTS.md §3.6/§3.7 | internal/span/span.go: Funktionskommentar | ja — Sonde A | Zusage im Kommentar weiter als der Code |
| F-9 | INFO | Der Tabellentest `TestCommandProgramWithholdsProgramForEachUnsureValueChar` hat keinen Fall in `test/mutations/`; 405 mutiert `valueEdgeKnown` als Ganzes und färbt ihn ebenfalls rot, aber das je-Zeichen-Bindung selbst ist damit nicht **gelistet** (`make mutate` prüft ihre Haltbarkeit nicht). Ein künftiger Umbau, der die Tabelle kürzt, fällt keinem Sensor auf. | AGENTS.md §3.6 (Haltbarkeit) | test/mutations/ | nein | gelistet ≠ vorhanden |

---

## Prüfung der Schwerpunkte

**1. Sonden gegen den neuen Stand.** Ausgabe je Eingabe (`program`, argc; `—` = nichts):

| Eingabe | Ergebnis |
|---|---|
| `A=b\nSECRET` | `SECRET`, 0 — `\n` ist Shell-Grenze; `SECRET` ist ein eigenes Kommando, kein Wert |
| `A=b\tSECRET cmd` | `SECRET`, 1 — Tab ist Shell-Grenze |
| `A=b\<NL>SECRET` | — |
| `A=$'x y' cmd` · `A="x y" cmd` · `A='x y' cmd` · `A=x\ y cmd` · `A=(x y) cmd` | — (alle) |
| `A=b$IFS cmd` | `cmd`, 0 (Wert `b$IFS` ein Wort) |
| `A=b${IFS}SECRET cmd` · `A+=b cmd` | — |
| `A=b;SECRET` · `A=b&SECRET` · `A=b&&SECRET` · `A=b\|SECRET` | — |
| `export A=x y` · `env A=x cmd` | `export`, 2 · `env`, 2 (Programm, nie der Wert) |
| `A=b<<EOF` · `A=b <<EOF cmd` · `A=b <<<hunter2 cmd` | — |
| `A=b $(cmd` · `A=b "x` | `$(cmd`, 0 · `"x`, 0 — Programm-Position, s. F-8; kein Wert-Rest, weil jeder mehrwortige Wert eines der 13 Randzeichen oder Nicht-Shell-Leerraum trägt und dort zurückgehalten wird bzw. ein Wort bleibt |
| `TOKEN=x && gh` · `TOKEN=x; gh` · `TOKEN=x ; gh` · `A=b & gh` | `gh`, 0 (alle) |
| `A=b \|\| cmd` | — |
| `A=b\r\ncmd` | `cmd`, 0 (Wert `b\r`, danach Zeilenende — shell-treu) |
| `A=b<NBSP>; cmd` | `cmd` (Wert `b<NBSP>`, `;` ist Segment-Schluss) |
| `A=b;<NBSP>SECRET cmd` · `A=b<NBSP>&& cmd` | — (fail-closed) |
| `A=b 5 cmd` · `A=b 5>f cmd` | `5`, 1 · — |
| `A=b \<NL>cmd` | `\`, 1 (das Wort `\`; kein Wert) |

Eine neue Umgehung der Wert-Grenze ist nicht gefunden. Die Begründung, warum keine bleibt: ein
Zuweisungs-Wert, der in mehrere Wörter zerfällt, braucht entweder Shell-Leerraum (Leerzeichen, Tab,
Zeilenende) **im** Wert — das setzt Quoting, Backslash, Substitution oder Klammern voraus, alle in der
13er-Menge — oder ein Wort, das die Zerlegung trennt, die Shell aber nicht (behoben, F-1). Die
Randzeichen-Tabelle fährt jedes der 13 einzeln.

**2. Regression durch `splitWords`.** Siehe F-6. Vorher/Nachher an der Stichprobe (Sonde B → A) hat
genau die Klasse „Nicht-Shell-Leerraum im ersten Wort einer Zeile ohne Zuweisung" als Diff, sonst keine
Abweichung in Zeilen ohne Zuweisung (`ls -l`, `  ls -l`, `\tls x`, `make gates\r`, `echo hi\r`, `set -e`,
`(cmd`, `! cmd`, `{ cmd` → gleich). CRLF-Kommandos verlieren nichts: `make gates\r` bleibt `make`/1; nur
ein `\r` **unmittelbar am ersten Wort** (`make\r\n`) wird Teil von `program`. Der Bestand unter
`.harness/state/spans/` trägt die Kommandozeile nie und ist für einen Vorher/Nachher-Vergleich nicht
verwendbar (nur lesend geprüft: 33242 Zeilen mit `"program"`); die Aussage über Bestandsverhalten stützt
sich darum allein auf die Sonden. Der Plan deckt den Nebeneffekt nicht (§1/§6 nennen Zeilen mit
Zuweisung); er ist ungeplant, vom Implementer benannt und in SPEC-031/Kommentar nachgezogen.

**3. `argc`.** `A=b<NBSP>SECRET cmd x` → `cmd`, argc **1** (Sonde B: 2). Die Wörter nach dem Programm
zählen ohne Rücksicht auf den Wert; jede Eingabe, deren Wert mehrwortig wäre, hat kein `argc`
(`HasArgc=false`). SPEC-021/SPEC-031 sagen weiter Verschiedenes zu „erstes Token" gegenüber „erstes Wort"
(F-5, bewusst, Plan §1).

**4. §3.6 — binden die Zähne?** Nachgestellt in der Kopie gegen die volle Suite:

- **406** (`strings.Fields` statt `splitWords`): rot in `TestCommandProgramNeverEmitsAssignmentValueFragments`
  (sieben Fälle `A=b<ws>SECRET cmd`) **und** in `TestCommandProgramNamesAProgramNotAnOperator`
  (`A=b<NBSP>SECRET cmd x`); `expect:` nennt den ersten — richtig.
- **407** (`namesProgram` ohne Zeichen-Prüfung): rot in `TestCommandProgramNamesAProgramNotAnOperator`
  (`\|&`, `;;`, `!`, `(cmd`, `{`, `}`, `&& (cmd`) und in der Literal-Gruppe des Wert-Wächters
  (`#SECRET`, `# SECRET`, `&& #SECRET`). Die Redirect-Fälle `>f`, `<<<x` bleiben grün, weil die
  Ziffernregel dieselben Wörter hält — wie der Kommentar in 407 sagt.
- **408** (Ziffernregel entfernt): rot **genau** in `2>&1`, `12>f`, `3<f`. Polarität stimmt: eine
  Mutation, die den Zahn trifft, färbt rot; die Tabelle bindet die Ziffernfolge, nicht die
  Zeichen-Menge.
- **F-3-Tabelle:** je Zeichen ein rotes Subtest (13/13); die Eingabe `A=x<c>y cmd z` trägt in jedem Fall
  genau ein Zeichen der Menge und keinen Leerraum, ein Zeichen, das die Menge verlässt, lässt `cmd`
  durch. Bindung bestätigt.
- **Gegenproben des Implementers** (geschwächter Test → grün heißt bindet): nicht wiederholt; die
  Mutationen oben prüfen dieselbe Zusicherung in der stärkeren Richtung (der Quelltext wird geschwächt,
  der Test wird rot, und zwar der benannte). Lücken der Bindung: F-7 (`&`, `)`), F-9.
- **MR-071:** die drei `sed`-Anker treffen je genau **eine** Zeile (`grep -c` → 1/1/1); Format wie `129-*`
  und `404`/`405` (`# files:`, `# expect:`, Kopfkommentar, `set -euo pipefail`, ausführbar; die Modi
  `755` bei 404/405 und `775` bei 406–408 sind für den Treiber ohne Belang).

**5. §3.7/§3.2, Nicht-Gegenstand.** Kommentare im Indikativ, keine Befund-Kennung, keine Chronik, kein
Konjunktiv über die verworfene Alternative; die Grenz-Zeile („Here-Doc-Körper, `$(( ))` und
verschachtelte Substitution …") ist eine Klasse „Grenze". Keine `//nolint`/`shellcheck disable` im Diff.
`git show --stat fb1ca361`: sechs Dateien, kein `internal/emit/`, kein `fieldlist.go`, kein Tokenizer,
kein `cd`/`set`, keine Plan-/Register-/Roadmap-Datei, keine DoD-Häkchen (§3.10 gewahrt).

---

## Geprüft, ohne Befund

- **Wert-Grenze:** Sonden oben; alle 13 Randzeichen einzeln rot gesehen; Leerraum-Klassen (Unicode `Zs`,
  `U+0085`, `U+2028`, `U+200B`, `U+180E`, `0x1C`–`0x1F`, `\r`, `\v`, `\f`) bleiben Teil des Worts.
- **Segment-Tabelle aus Plan §1:** Verhalten unverändert gegenüber Runde 1 (`A=b && cmd x` … `A=b B=c`).
  Eine neue Abweichung entsteht nur dort, wo Runde 1 F-2 sie verlangt.
- **Here-Doc:** `A=b <<EOF` (ohne Programm) wird über das Metazeichen-Wort zurückgehalten; ein Körper nach
  einem Programm erreicht das Feld nie (nur `argc` zählt Körper-Wörter, wie die Grenz-Zeile sagt).
- **`argc` als Nebenkanal:** trägt keinen Wert (s. Punkt 3).
- **Emit-Seite:** `Derive` gibt bei `ok=false` `Derived{}`; `program`/`argc` fehlen dann in der Zeile
  (Tabellentest prüft die geschriebene Zeile mit `bashSpanLine`).
- **SPEC-031:** Zeichenmengen deckungsgleich mit dem Code; die Fall-Liste in der Bewacht-Zelle nennt 404,
  407, 408 (Segment-Test), 405, 406 (Wert-Test) und den Tabellentest — alle existieren.
- **Fall-Dateien 406/407/408:** Kopfkommentare beschreiben die Mutation und den stillen Pfad, `expect:`
  stimmt mit dem tatsächlich roten Test überein.
- **Abgrenzung:** `slice-204`-Anteile (`cd`/`set`), Tokenizer, `fieldlist.go`, `internal/emit/` unberührt;
  Slice-Plan unverändert.

## Übergabe

Kein Rollen-Konflikt: keine HIGH/MEDIUM offen. F-6 (Entscheidung, ob die globale Wortgrenze bleibt oder auf
Zeilen mit Zuweisung beschränkt wird) und F-7 gehören dem Implementer, F-8/F-9 nimmt die Slice-Closure
(§7, Beobachtungs-Register) oder der Planner auf; der Reviewer kategorisiert nur.

## Gesamturteil

**Freigabefähig.** F-1 (HIGH) und F-2 (MEDIUM) sind an Sonde und Mutation belegt behoben, F-3/F-4 ebenfalls;
offen bleiben zwei LOW (F-6, F-7) und zwei INFO (F-8, F-9), keines blockiert.

## Gate-Lauf

`make gates` wird nach dem Commit dieses Reports gefahren; das Ergebnis steht im Handback an den Aufrufer,
nicht hier.
