# Review-Report Runde 2: slice-204-das-programm-feld-nennt-das-programm — 2026-09-27

**Review-Art:** Code-, Test-, Mutations-Fall- und Spec-Diff gegen Plan, ADR und Hard Rules (Modul 10), Nachprüfung nach einem blockierenden Befund in frischem Kontext. Nicht gegen die DoD (das ist der Verifier).

**Gegenstand:** `git diff 6bddaaef..HEAD` (Nachrunde des Implementers, 4 Commits: `a51d85b9` Tests gegen den Vorzustand rot, `92f03d31` Code, `39a6dc5f` Fälle 476 bis 482 mit Entflechtung der Tests,
`188fb832` SPEC-031 und Fall 477) und das Gesamtdiff `git diff 5acbc97d~1..HEAD` (Baum vor Beginn sauber). Der Report der Runde 1 liegt im Commit `6bddaaef` (ein HIGH, zwei MEDIUM, ein LOW, vier INFO).

**Plan-Bezug:** Slice `slice-204-das-programm-feld-nennt-das-programm` (§1 Ziel und Abgrenzung mit dem „wichtigsten Kriterium": ein Fragment darf hinter einem Navigations-Segment nie im Feld landen, §2, §3, §4, §6) — Kennung,
nicht Pfad: der Plan wandert mit dem Lifecycle (`AGENTS.md` §3.11). **Constraint:** `ADR-0011` (Festlegung 2: Programm-Token statt Kommandozeile; fail-closed), `ADR-0022`, `LH-FA-10`, `MR-019`, `MR-071`,
`AGENTS.md` §3.6, §3.7, §3.8, §3.9, §3.10, §3.11; `SPEC-021`, `SPEC-031`.

**Skill:** `.harness/skills/reviewer.md` @ Version 2.1.0 (2026-09-26) — die Zeilen „Grenzen-Aufzählung einer erkennenden Regel ohne Formen-Probe" und „Zusicherung über einer Menge, die leer sein kann" sind angewandt.
**Modell:** Sonnet 5 · **Datum:** 2026-09-27

**Eingangs-Kontext:** Diff · Slice-Plan (§1, §2, Rückführungen) · `ADR-0011` Festlegung 2 · `spec/spezifikation.md` (`SPEC-021`, `SPEC-031`) · `internal/span/span.go` und `span_test.go` vollständig gelesen ·
die sieben Fälle 476 bis 482 · der Report der Runde 1 (Form-Muster, Findings) · `AGENTS.md` §3. Der Implementer-Bericht lag als Behauptung vor und ist nicht übernommen; jede Zeile davon ist unten gemessen.

**Eigene Sensor-Läufe dieses Laufs** — Scratchpad-Kopien von `git archive` (kein `.git`), Go nur über `make test-go` (Docker), keine Host-Toolchain, kein Push, keine Änderung am Arbeitsbaum außer diesem Report.
(1) Eine Formen-Tabelle von 146 Kommandozeilen plus 24 weitere gegen **drei Stände** von `span.go`: HEAD, den Stand der Runde 1 (`490f2daa`) und den Vorgänger (`dfa544df~1`); die Kopien von Vorgänger und Runde 1 enthielten nur die
Probe-Tests, die Kopie von HEAD die volle Suite. (2) 20 gemessene Schwächungen des neuen Codes (dazu drei Compilefehler und ein Muster, das nicht traf, nicht mitgezählt) und 18 Erweiterungen der Whitelist, je eine Kopie, je ein `make test-go`. (3) Je Fall 476 bis 482 zwei Läufe: Mutation aktiv ohne Skip (Kontrolle) und Mutation aktiv mit
übersprungenem `expect:`-Test (Gegenprobe). (4) Ein Teillauf `make mutate MUTATE_JOBS=1 MUTATE_CASES=<476 bis 482>` im Repo. (5) `make docs-check`.

## Messbeleg

Polarität ausgeschrieben. Bei einer Schwächung des **Codes**: „rot" = die Suite färbt, die Schwächung ist erkannt, der Zahn **bindet**; „grün" = die Suite bleibt bei geschwächtem Code grün, die Stelle ist **unbewacht**.
Bei einer Gegenprobe (Mutation eines Falls aktiv, der benannte **Test** übersprungen, Skip-Menge genau der `expect:`-Test): „grün" = der benannte Test ist der einzige Träger des Rots, der Fall **bindet**;
„rot" = ein anderer Test deckt dieselbe Mutation mit.

| Lauf | Ergebnis |
|---|---|
| Fälle 476 bis 482, Anker: geänderte Zeilen in `span.go` je Fall (`diff`, gezählt) | je **1** — der `sed`-Anker trifft im Quell-Bestand genau eine Zeile (`MR-071`); Fall 477 (im Nachzug neu gefasst) baut und trifft |
| Kontrolle je Fall, Mutation aktiv, nichts übersprungen | **rot**, je genau der Test aus `# expect:` (476 `TestCommandProgramSkipsNavigationSegments`, 477/480/481/482 `TestCommandArgcEndsWithItsSegment`, 478 `TestCommandProgramKeepsNavigationWhenItsEdgeIsUnsure`, 479 `TestCommandProgramKeepsNavigationOnMultilineCommands`) — und **kein weiterer** Test-Kopf |
| Gegenprobe je Fall, Mutation aktiv, `expect:`-Test übersprungen | **grün** für alle sieben — jeder benannte Test ist der einzige Träger des Rots; 476 ist gegenüber Runde 1 (dort rot, zwei Träger) entflochten |
| `make mutate` Teillauf im Repo | `7 ok, 0 Befund(e)`, `TEILLAUF 7 von 470 — kein Beleg`, Beleg-Slot `mutate-passed.key` vor und nach dem Lauf nicht vorhanden |
| Dateimodus der sieben Fälle im Index | `100644`, wie 470 bis 475; Kopf (`# files:`, `# expect:`) wie Nachbarn |
| V02 `plainNavigationWord`-Prüfung aus (= Fall 478) | rot, `TestCommandProgramKeepsNavigationWhenItsEdgeIsUnsure` mit den Teilfällen jedes Zeichens |
| V01b Einzeiligkeits-Bedingung aus (`if singleLine \|\| true`) | rot, `TestCommandProgramKeepsNavigationOnMultilineCommands` |
| V03a/V03c/V03d/V03e Ende-Bedingung: „Feld dahinter" für `&&` bzw. `;` aus · „kein Ende gefunden → false" aus · `body != f` aus | je rot (`cd /x &&`, `cd /x;`, `cd /x`, `cd; make`, …) |
| V20 Nicht-ASCII nicht mehr schlicht · V21b `&` hinter `>` aus · V22 `prev` nicht mitgeführt | je rot (`cd /tmp/ü && make`, `cd /x 2>&1 && make`) |
| V23 Zeilenende nicht markiert · V24 Rand-Ausnahme von `singleLine` · V34 argc-0-Zweig aus · V35 `closesSegment` nur an `;` | je rot |
| V30 `skipped` nach Navigation nicht gesetzt · V36 `TrimSuffix` an `fields[i]` · V37 `TrimSuffix` an `body` · V38b `namesProgram` nach Sprung aus · V46 `i = next` (Off-by-one) | je rot |
| **V32 Tab ist kein Wort-Trenner mehr** (`c != '\t'` entfernt in `splitWords`) | **grün — unbewacht**, M-1 |
| **V25 Fortsetzung: `&& c == '\n'` entfernt** (ein einzelner `\` vor **jedem** Leerraum entfällt) | **grün — unbewacht**, M-2 |
| Whitelist um je **ein** Zeichen erweitert: `#`, `<`, `\|`, `;`, `'`, `"`, `\`, `` ` ``, `(`, `)`, `{`, `}`, `!`, `&`, CR, DEL | **je rot** (`TestCommandProgramKeepsNavigationWhenItsEdgeIsUnsure`, Teilfall des Zeichens) — der ASCII-Sweep bindet jedes Zeichen einzeln |
| Whitelist um **NUL** erweitert | **grün — unbewacht**, L-1 (`\n` in der Whitelist ist eine äquivalente Mutation: Zeilenende ist nie Wortzeichen) |
| V01, V21, V38 (erste Fassungen) | Compilefehler (`declared and not used`), keine Messung; als V01b, V21b, V38b neu gefasst |
| V48 (führendes Zeilenende ohne Guard) | Muster traf nicht — **nicht gefahren** |
| `make docs-check` vor Anlage dieses Reports | Exit 0, `2012 Datei(en) geprüft, 0 Befund(e)` |

### Formen-Probe (Ergebnis je Zeile: `program` / `argc`, am HEAD; „Vorg." = Stand `dfa544df~1`, „R1" = Stand der Runde 1)

**Die Runde-1-Formen** (Tabelle des Reports der Runde 1, gefahren gegen alle drei Stände): `cd /x` + Zeilenende + Here-Doc mit `line;` und `SECRETWORD` → HEAD `cd` (R1: `SECRETWORD`); `cd /x # note; ghp_abc` → `cd` (R1: `ghp_abc`);
`cd /x` + Zeilenende + `echo hi; SECRETWORD` → `cd` (R1: `SECRETWORD`); `cd /x && cat <<EOF` + Körper → `cd`; `cd /x && A=b` + Zeilenende + `SECRETWORD` → `cd` (R1: `SECRETWORD`); `cd /x <in && make`, `cd /x #a && make`,
`cd /x#a && make`, `cd /x &>f && make` → je `cd` (R1: `make`). **H-1 ist an allen Formen geschlossen**, kein Wort aus Kommentar, Here-Doc-Körper oder Folgezeile erreicht `program` hinter einem Navigations-Segment.

**Eigene Formen, alle `program` = das Programm oder `cd` wie gewollt:** `set -e; cd /x && make` → `make` · `cd /x && cd /y && make` → `make` · `cd /x&&make` → `cd` · `cd /x &&<TAB>make` → `make` · `cd /x &&  make` (mehrere Leerzeichen) → `make` ·
`cd<TAB>/x<TAB>&&<TAB>make` → `make` · `cd ~/x && make`, `cd -P /x && make`, `cd $HOME && make`, `cd [a-z]* && make` → `make` · `cd ${X} && make` → `cd` · `cd /x && make&` → `make&` · `cd /x ;make` → `cd` · `cd /x;` → `cd` ·
leere und leerraum-Kommandozeile → nichts (`false`) · `cd`, `set` → das Wort · `cd && make`, `set -e -o pipefail && make`, `set +e; make` → `make` · `export A=b && make`, `pushd /x && make` → `export`, `pushd` ·
`if cd /x; then make; fi` → `if` · `for i in 1; do cd /x && make; done` → `for` · `while true; do cd /x; make; done` → `while` · `{ cd /x; make; }` → `{` · `time cd /x && make` → `time` · `! cd /x && make` → `!` ·
`builtin cd /x && make`, `command cd /x && make` → `builtin`, `command` · `A=b cd /x && make`, `A=b && cd /x && make` → `make` · `A=b` + Zeilenende + `cd /x && make` → `cd` · `cd /x >&2 && make`, `cd /x 2>&1 && make`, `cd /x >&- && make` → `make` ·
`cd /x &>f && make`, `cd /x >&& make`, `cd /x >f&&make`, `cd /x 2>&1&& make`, `cd /x >&2;make` → `cd` · `cd /x >& file; SECRETWORD` und `cd /x >o; SECRETWORD z` → `SECRETWORD` (der echte nächste Befehl; ein Programm-Name, kein Fremdwort) ·
`cd /x && \` + Zeilenende + `make` → `make` · `cd /x \` + Zeilenende + `&& make` → `make` · `cd /x\` + Zeilenende + `&& make` → `cd` · `cd /x && make \` + Zeilenende + ` gates` → `make`, argc 1 · `cd /x && make gates` + Zeilenende + `echo x y` → `cd`, argc 1 ·
`make gates` + Zeilenende + `echo x y` → `make`, argc 1 · `make; echo x y` → `make;`, argc 0 · `cd /x && make\r\n` → `make\r` · `cd /x && $SECRET` → `$SECRET` (Name, kein Wert) · `cd /x && # comment secret` → nichts ·
`cd /x; ; make`, `cd /x && && make`, `cd /x && ; make` → nichts · `cd /x && TOKEN=abc gh pr create` → `gh` · `cd /x && TOKEN="abc def" gh pr` und `cd /x; TOKEN='abc def' gh pr` → nichts · `cd /x && export TOKEN=abc && make` → `export` ·
`cd /x && (make)`, `cd /x && ! make`, `cd /x && >f make` → nichts (Vorgänger: `cd`).

**Unicode, NUL, Steuerzeichen** (die Frage, ob Nicht-ASCII als „schlicht" ein Segment-Ende oder eine Umleitung simulieren kann): der Code zerlegt byte-weise an Leerzeichen, Tab und Zeilenende, **nicht** über `strings.Fields`.
`cd /x<U+00A0>&& make`, `cd /x <U+00A0>&& make`, `cd /x <U+2028>&& make`, `cd /x<U+3000>&& make`, `cd /x <U+0085>&& make` → je `cd` (das `&` hinter einem Nicht-ASCII-Zeichen ist unschlicht);
`cd<U+00A0>/x && make` → das ganze Wort `cd<U+00A0>/x` als Programm (wie die Shell: ein Wort, kein Navigations-Wort) · `cd /x && make<U+2028>echo` → ein Wort · `cd \xff/x && make` (ungültiges UTF-8) → `make` ·
`cd /x<NUL> && make`, `cd /x<VT>&& make`, `cd /x<CR>&& make`, `cd /x<CR><LF>make` → je `cd`. Ein Nicht-ASCII-Zeichen trägt weder `&` noch `;` noch `#`; es kann keine Grenze vortäuschen.

**Erstes Wort verbatim (nicht durch diesen Diff, benannt oder nicht):** `"a b" x` → `"a` · `cd /x && "secret token" x` → `"secret` (**neu erreichbar hinter Navigation**, Vorgänger `cd`; R1-Restpunkt des Implementers, hier L-2) ·
`<<EOF cat` + Körper → `<<EOF` · `>f make` → `>f` · `# comment secret` → `#` · `make;ls` → `make;ls` · `my\ tool secret` → `my\` · `cd /x && my\ tool secret` → `my\` (Vorgänger `cd`).
`make&&TOKEN=abc gh pr`, `make;TOKEN=abc gh pr`, `make|TOKEN=abc gh`, `cd /x && make&&TOKEN=abc gh`, `A=b;make&&TOKEN=abc gh` → **nichts** (`=` im ersten Wort schaltet fail-closed ab) — der Wert einer Zuweisung erreicht `program` auch nicht über einen
Operator ohne Leerraum. `A=b` + Zeilenende + `SECRETWORD` → `SECRETWORD` (Vorgänger identisch, R2 des Implementers: ein echter Befehl der Folgezeile, kein Kommentar- oder Here-Doc-Wort — eine Zeile hinter einer Zuweisung öffnet kein Here-Doc ohne Programm,
`A=b <<EOF` als Form nicht gefahren).

## Verdikt je Finding der Runde 1

| Finding der Runde 1 | Verdikt | Beleg |
|---|---|---|
| H-1 Kommentar-, Here-Doc- und Folgezeilen-Wörter erreichen `program` hinter einem `cd` | **behoben** | alle Formen der Runde 1 liefern `cd` (Formen-Probe); Bedingungen Einzeiligkeit und Schlichtheit sind einzeln gebunden (V01b rot, V02 rot, je Zeichen rot); Fälle 478 und 479 binden mit genau einem Test; die Sperrliste ist durch eine Whitelist ersetzt |
| M-1 die drei Guards `\|\|`, `\|`, `&` in `skipNavigation` unbewacht | **behoben** | die Guards sind in `plainNavigationWord` aufgegangen (`\|` und `&` als unschlichte Zeichen, `\|\|` über `\|`); Tabellenzeilen `cd /x \|\| exit 1; make`, `cd /x \| make; echo z`, `cd /x & make; echo z` unterscheiden; V02 und die Erweiterungen `\|`/`&` je rot |
| M-2 `segmentArgc`: Programm-Feld auf `;` gibt argc 0 unbewacht | **behoben** | V34 rot an `make; echo x y`; Fall 480 bindet |
| L-1 Grenzen-Aufzählung ohne die gefahrenen Formen | **behoben** | (1) `cd /x;make && echo x` und `cd /x&&make gates && echo x` liefern `cd`; (2) `\` als Programm entfällt (`make`); (3) Zeilenende beendet argc, `make gates` + Zeilenende + `echo x y` → argc 1; (4) SPEC-031 nennt `\|\|` in der Operator-Liste des argc-Satzes. Neue Lücken der Aufzählung unten (L-2, I-2) |
| I-1 `fieldlist.go` sagt „das erste Token der Kommandozeile" | **offen, unverändert** (Übergabe) | `internal/span/fieldlist.go` und `internal/emit/` sind im Diff unberührt; die Adresse trägt der Planner (Feldliste-Slice) — hier nicht bewertet |
| I-2 Fall 476 nennt einen Test, die Mutation färbt zwei | **behoben** | Gegenprobe 476 jetzt grün; die zwei Tests sind entflochten, der benannte ist der einzige Träger |
| I-3 Bestand mischt zwei Bedeutungen | **offen, unverändert** (Übergabe an den Planner, Closure) | der Diff dieser Runde berührt keinen Leser von `program`/`argc` (`grep`: `Derive` nur in `emit.go`, `commandProgram`/`segmentArgc` nur in `span.go`) |
| I-4 Nachzug berührt zwei geschlossene Slice-Dateien | **nicht Gegenstand dieser Runde** | die vier Commits berühren keine Slice-Datei (`git diff --stat 6bddaaef..HEAD`) |

## Findings

### M-1 — die Tab-Wortgrenze in `splitWords` ist ungebunden; ohne sie nennt `program` die ganze Kommandozeile

- `kategorie`: MEDIUM
- `quelle`: AGENTS.md §3.6; ADR-0011 (Festlegung 2: Programm-Token statt Kommandozeile); SPEC-031 („Wortgrenzen sind Leerzeichen, Tab und Zeilenende")
- `pfad`: internal/span/span.go — `splitWords`, die Bedingung `c != ' ' && c != '\t' && c != '\n'`
- `befund`: `c != '\t'` entfernt (V32) lässt `make test-go` grün, und `span_test.go` trägt keinen Fall mit einem Tab zwischen Wörtern (der einzige Tab im Test steht im Körper eines `<<-`-Here-Docs und in der Sweep-Schleife); im Stand `dfa544df~1` war es ebenso.
  `splitWords` ist in diesem Diff neu geschrieben (Schleife statt `FieldsFunc`), und Kommentar und SPEC-031 sagen den Tab ausdrücklich als Wortgrenze. Fiele die Bedingung, wäre `git<TAB>commit<TAB>-m<TAB>Geheimnis` **ein** Wort und
  stünde als `program` im Span — die ganze Zeile, der Weg, den ADR-0011 sperrt. Heute liefert die Zeile `git`, argc 3 (gefahren).
- `verifizierbar`: ja — Tabellenzeile mit Tab zwischen Programm und Argumenten (`git<TAB>commit<TAB>-m<TAB>x` → `git`, argc 3) in `TestCommandProgramSkipsAssignments` oder eine der argc-Tabellen; danach muss V32 rot werden. Fall in `test/mutations/` fehlt ebenfalls.
- `klasse`: Zusage ohne Gegenbeispiel, das den Zweig unterscheidet

### M-2 — die Fortsetzung entfällt nur vor dem Zeilenende; die Bedingung `c == '\n'` ist ungebunden

- `kategorie`: MEDIUM
- `quelle`: AGENTS.md §3.6; ADR-0011; SPEC-031 („ein einzelner Backslash vor dem Zeilenende setzt die Zeile fort und ist kein Wort")
- `pfad`: internal/span/span.go — `splitWords`, `if field == lineContinuation && c == '\n'`
- `befund`: Fall 482 und die Tabelle der argc-Grenze binden den **Wegfall der ganzen Bedingung** (`if false`), nicht ihre zweite Hälfte. Mit `field == lineContinuation` allein (V25) bleibt die Suite grün, obwohl dann ein einzelner `\` vor jedem Leerzeichen und Tab entfällt:
  `A=b \ SECRETWORD` und `cd /x && \ SECRETWORD` nennen heute `\`, mit der Schwächung `SECRETWORD` (aus dem Code gelesen, an der geschwächten Kopie nicht gefahren; gefahren ist nur, dass die Suite grün bleibt) — in der Shell ist `\ ` ein maskiertes Leerzeichen und `SECRETWORD` der Rest **eines Wortes**, nicht ein Programm. Ein Wort, das
  kein Programm-Name in Befehlsposition ist, erreichte den Span; kein Gate meldet es.
- `verifizierbar`: ja — Zeile `A=b \ SECRETWORD` → `\` in eine Tabelle; danach muss V25 rot werden.
- `klasse`: Zusage ohne Gegenbeispiel, das den Zweig unterscheidet

### L-1 — der Sweep-Test trägt eine eigene Kopie der Whitelist und lässt NUL aus; der Test-Kopf sagt „jedes ASCII-Zeichen"

- `kategorie`: LOW
- `quelle`: AGENTS.md §3.6 (ein Test, dessen Kopf eine Eigenschaft behauptet, misst sie); Skill-Zeile „Zusicherung über einer Menge, die leer sein kann"
- `pfad`: internal/span/span_test.go — `TestCommandProgramKeepsNavigationWhenItsEdgeIsUnsure` (lokale Konstante `plainNavigationChars`, Schleife `for c := 1; c < 128; c++`)
- `befund`: (a) Die Schleife beginnt bei 1: NUL in die Whitelist des Codes aufgenommen (Erweiterung `\x00`) lässt die Suite grün; der Kopf sagt „jedes ASCII-Zeichen ausser den schlichten". (b) Die Konstante im Test ist eine **eigene Kopie** der Liste; fällt ein schlichtes Zeichen aus der Konstante
  des Codes, färbt der Sweep nichts, weil er die schlichten Zeichen überspringt — nur die Zeichen mit Tabellenzeile (`~`, `$`, `*`, `>`, `-`, `.`, `/`) binden über andere Tests. Kein Leck (das Programm bliebe `cd`, fail-closed), aber Verlust des Programm-Namens ohne Meldung. Die Menge, die
  der Sweep besorgt, ist nicht leer (die Teilfälle laufen, gemessen an den Namen der roten Läufe); die Sonde fehlt nicht.
- `verifizierbar`: ja — Schleife ab 0; die Liste aus dem Code lesen (Export oder Test im Paket) statt kopieren.
- `klasse`: Test-Kopf behauptet mehr, als die Schleife misst

### L-2 — `cd /x && "a b" x` nennt `"a`, neu erreichbar hinter Navigation, dort ungebunden

- `kategorie`: LOW
- `quelle`: ADR-0011 (fail-closed), Slice §1 (kein Fragment hinter einem Navigations-Segment); SPEC-031 und Code-Kommentar nennen `"a b" x` → `"a` als Ist-Verhalten
- `pfad`: internal/span/span.go — `commandProgram`, Zweig `default` hinter einem übersprungenen Segment (`skipped && !namesProgram(f)` lässt `"` durch); internal/span/span_test.go — `TestCommandProgramFirstWordKeepsItsGluedRest`
- `befund`: Vor dem Slice nannte `cd /x && "secret token" x` das Wort `cd`; jetzt steht `"secret` im Feld — das erste Wort eines Strings, wie es dasteht. Ohne Navigation ist das Verhalten alt, benannt (Grenzen-Absatz, SPEC-031) und für `"a b" x` gebunden; hinter Navigation ist es **neu** und
  nirgends gebunden (die Nav-Tabellen führen kein Wort in Anführungszeichen an Programm-Stelle). Das Feld trägt damit ein Bruchstück eines Strings, den ein Auswerter nie als Programm braucht (`"a` ist kein Name). Kleinste Schließung: hinter einem übersprungenen Segment nur ein
  Wort nehmen, das `plainNavigationWord` besteht — sonst nichts (fail-closed, wie der Zuweisungs-Rand). Das ist die Wahl des Implementers; hier nur die Stufe: LOW, weil der Inhalt ein Programm-Pfad, kein Wert einer Zuweisung ist und die Aussage benannt steht.
- `verifizierbar`: ja — Zeile `cd /x && "a b" x` in eine Tabelle, mit dem erwarteten Ergebnis, das der Implementer wählt (gebunden, nicht bewertet).
- `klasse`: Grenze des Programm-Felds hinter Navigation nicht gebunden

### I-1 — die Aufzählung der Grenzen nennt zwei gefahrene Formen nicht

- `kategorie`: INFO
- `quelle`: Skill-Zeile „Grenzen-Aufzählung einer erkennenden Regel ohne Formen-Probe"
- `pfad`: internal/span/span.go — Kommentar über `commandProgram`, Absatz „Grenzen"; spec/spezifikation.md — `SPEC-031`
- `befund`: Gefahren und nicht genannt: (1) `cd /x && make\r\n` und `cd /x && make&` nennen `make\r` und `make&` (Wort samt anhängendem Steuerzeichen bzw. Operator; „samt anhängendem Rest" deckt es dem Wortlaut nach, die Beispiele nennen nur `;`); (2) `my\ tool`
  (maskiertes Leerzeichen) und ein führendes Redirect-/Here-Doc-Wort (`>f make` → `>f`, `<<EOF cat` → `<<EOF`) stehen als erstes Wort im Feld; `namesProgram` gilt nur hinter einer Zuweisung oder einem Navigations-Segment. Keine der Formen trägt einen Zuweisungs-Wert (`=` im ersten Wort schaltet ab, gemessen) oder
  ein Wort einer Folgezeile; die Aufzählung ist damit unvollständig, nicht irreführend. Gelesen: SPEC-031 sagt „das Feld nennt sonst das erste Wort, wie es dasteht" — die Zusage trägt für alle vier Formen.
- `verifizierbar`: ja
- `klasse`: Grenzen-Aufzählung einer erkennenden Regel ohne Formen-Probe

### I-2 — der Preis der Whitelist ist nicht beziffert, und er ist größer, als die Beispiele in Kommentar und SPEC ahnen lassen

- `kategorie`: INFO
- `quelle`: Slice §1 (Nutzen der Änderung), ADR-0011
- `pfad`: internal/span/span.go — `plainNavigationWord`, `commandProgram` (`singleLine`)
- `befund`: Unschlicht und darum `cd` bleiben nach dem Diff auch die im Alltag häufigen Formen `cd "$DIR" && make`, `cd "$(pwd)" && make`, `cd /pfad\ mit\ leer && make`, `cd $(dirname $0) && make`, `cd /x && make` **mit** einem Zeilenende irgendwo in der Zeile (etwa in einer
  `git commit -m "…"`-Nachricht hinter dem `cd`). Das ist gegenüber dem Vorgänger kein Rückschritt (er nannte auch dort `cd`), sondern ein Nutzen, der kleiner ausfällt, als der Slice-Titel verspricht. Der lokale Bestand trägt keine Zeile (die Spans führen nur `program` und `argc`); eine Häufigkeit ist nicht messbar.
  Plan-Frage an den Planner, kein Befund gegen den Code: ob ein Wort in Anführungszeichen ohne Leerraum (`"$DIR"`) und ein Zeilenende **hinter** dem Segment das Überspringen weiter verbieten müssen.
- `verifizierbar`: nein
- `klasse`: Nutzen einer fail-closed-Grenze nicht beziffert

### I-3 — hinter einer Zuweisung nennt das Feld das erste Wort einer Folgezeile; hinter einem Navigations-Segment nie

- `kategorie`: INFO
- `quelle`: SPEC-031; ADR-0011
- `pfad`: internal/span/span.go — `commandProgram`; Kommentar über der Funktion (Absatz „Grenzen")
- `befund`: `A=b` + Zeilenende + `SECRETWORD` nennt `SECRETWORD` (Vorgänger identisch, im Grenzen-Absatz benannt); `cd /x` + Zeilenende + `SECRETWORD` nennt `cd`. Die Folgezeile hinter einer Zuweisung ist ein echter Befehl (eine Zuweisung öffnet kein Here-Doc ohne Programm; aus `namesProgram` gelesen, nicht gefahren:
  `A=b <<EOF` → nichts, `A=b # c` + Zeilenende + Wort → nichts), also kein Wort eines Kommentars oder Körpers. Die Asymmetrie ist eine benannte Grenze, kein Leck; SPEC-031 sagt „nie ein Wort … einer Folgezeile" nur im Satz über das Navigations-Segment.
- `verifizierbar`: ja
- `klasse`: benannte Grenze, kein Befund

## Entscheidungen des Implementers, die vom Plan abweichen oder ihn ergänzen

- **Whitelist statt Sperrliste.** Der Wechsel von `navigationUnsureChars` zu `plainNavigationChars` ist fail-closed und trägt: jedes Zeichen der Sperrliste und jedes weitere ASCII-Zeichen ist einzeln gebunden (Erweiterungen je rot). Der Preis (I-2) ist die Wahl; die Regel steht in SPEC-031 als Zustand.
- **Einzeiligkeit als eigene Bedingung.** Trägt (V01b rot, Fall 479). Der Rand-Ausschluss (Zeilenende vor dem ersten und hinter dem letzten Wort zählt nicht) ist durch V24 gebunden.
- **`closesSegment` für `;` und Zeilenende, Fälle 480 und 481 statt eines gemeinsamen Falls.** Trägt: je eine Mutation, je ein Träger, beide Gegenproben grün.
- **Entflechtung der Tests.** Eingelöst: sieben Gegenproben grün (Skip-Menge = genau der `expect:`-Test).
- **Restpunkte R1 und R2 des Implementers.** R1 bestätigt und als L-2 gestuft (der Implementer nennt R1 „gelesen, nicht durch Test gedeckt" — richtig); R2 als I-3, kein Befund.

## Geprüft, ohne Befund

- **Vollständigkeit des H-1-Fixes gegen ADR-0011.** `grep -rn 'commandProgram\|segmentArgc\|Derive(' internal/ cmd/` (ohne Tests): `Derive` wird nur in `emit.go` gerufen, `commandProgram` nur in `Derive`, `segmentArgc` nur in `commandProgram`; kein zweiter Pfad durchsucht den Rest der Zeile.
  `internal/emit/` und `internal/span/fieldlist.go` sind im Diff unberührt. Ein Wort aus Kommentar, Here-Doc-Körper oder Folgezeile erreicht `program` auf keinem der gefahrenen Pfade (Navigation, Zuweisung, erstes Wort mit `=`).
- **Latenz und Fehlerverhalten.** `splitWords` ist eine Byte-Schleife, `skipNavigation` bricht am ersten unschlichten Wort ab und schreitet bei einem Sprung vorwärts: linear in der Zeilenlänge; ungültiges UTF-8, NUL und Steuerzeichen führen zu keinem Panic (gefahren). `make hook-overhead` nicht gefahren, der Diff ändert keinen Aufrufer.
  Die Deutung bereits geschriebener Spans ändert der Diff nicht (Schreiber-Seite; der Bestand mischt weiter zwei Bedeutungen, I-3 der Runde 1).
- **§3.7 an Kommentaren, Test-Namen, Spec-Zeilen dieser Runde.** Zustandsform, keine Befund-Kennung, keine verworfene Alternative („Ohne X wäre …" steht nirgends), Herkunft nicht erzählt; Test-Namen behaupten, was ihre Tabellen messen — bis auf L-1. Die Kopfzeilen der Fälle 476 bis 482 beschreiben die Mutation im Indikativ
  („`isNavigation` erkennt weder `cd` noch `set`"), nennen ihren Träger und die Nachbar-Fälle.
- **Anker und Kopf der Fälle (`MR-071`).** Je Fall genau eine geänderte Zeile im Quell-Bestand (gemessen, Tabelle); `# expect:` trifft je genau einen Test-Namen; Modus `100644`; `failure_form test-go` = `--- FAIL:` trifft.
- **§3.8, §3.10, §3.3.** Der Diff dieser Runde schreibt weder Hard Rules noch Adaptions-Block, keine Sensor-Doku unter `harness/sensors/`, keinen Slice-Inhalt, keinen DoD-Haken, kein Register, keine Closure-Notiz, keine ADR (`git diff --stat 6bddaaef..HEAD`: `span.go`, `span_test.go`,
  `spec/spezifikation.md`, sieben Fall-Dateien); die Tests des Vorgänger-Slices sind unverändert (`git diff 959881ef~1..HEAD -- internal/span/span_test.go` trägt keine gelöschte Zeile).
- **Wert hinter Navigation.** `cd /x && TOKEN=abc gh pr create` → `gh`; die Werte `TOKEN`, `abc` stehen in keiner der gefahrenen Zeilen im Feld; die Wert-Grenze der Zuweisungen bleibt unverändert.
- **Gates dieses Laufs.** `make docs-check` Exit 0 vor Anlage dieses Reports; `make gates` und der Stempel stehen im Abschlussbericht, nicht hier (ein Report, der sein eigenes Gate-Ergebnis trägt, ändert den gestempelten Baum).

**Gelesen, nicht gefahren:** V48 (Guard `len(w.eol) > 0` in `splitWords`, das Muster traf nicht); `make hook-overhead`; die bats-Suite unter geschwächtem `span.go` (die Schwächungen liefen nur gegen `make test-go`, den Sensor der Fälle 476 bis 482 — ein bats-Test, der Tab-getrennte Zeilen
schickt, wäre ein weiterer Träger, `grep` nach Tabs in `test/span*.bats` fand nichts); das Verhalten anderer Shells (`zsh`: `!`, `^` als Operator; Nicht-ASCII-Wortzeichen in fremden Locales); Bestands-Spans (kein Zeilentext);
`make lint` einzeln (läuft in `make gates`); die Emissions-Vorlagen unter `internal/emit/templates/`.

## Summary

| Stufe | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 2 (M-1, M-2) |
| LOW | 2 (L-1, L-2) |
| INFO | 3 (I-1 bis I-3) |

Runde 1: H-1, M-1, M-2, L-1, I-2 **behoben**; I-1, I-3 offen und übergeben; I-4 nicht Gegenstand. Wiederkehrende Klassen für die Closure §7: *Zusage ohne Gegenbeispiel, das den Zweig unterscheidet* (M-1, M-2 — in Runde 1 M-1 und M-2, damit **zweite** Runde derselben Klasse, im
selben Slice) · *Grenzen-Aufzählung einer erkennenden Regel ohne Formen-Probe* (I-1, in Runde 1 H-1 und L-1) · `mutations-fall-nennt-einen-test-die-mutation-faerbt-mehrere` (nicht mehr aufgetreten).
