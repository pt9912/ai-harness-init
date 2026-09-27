# Verifikations-Report: slice-204-das-programm-feld-nennt-das-programm — 2026-09-27

**Rolle:** Verifier (Modul 11) — DoD-/ADR-Konformität und Plan-vs-Code-Diff an den Planner. Frischer Kontext, kein Selbst-Verifizieren. Nicht der Reviewer-Maßstab (Diff gegen Plan, ADR, Hard Rules) und nicht der Validator.

**Gegenstand:** Slice `slice-204-das-programm-feld-nennt-das-programm` (Kennung, nicht Pfad: die Datei wandert mit dem Lifecycle, `AGENTS.md` §3.11), Stand HEAD `ed4eedcf`, Baum sauber. Diff-Basis `5acbc97d~1..HEAD` (Claim-Move, Ruhe-Marker, 17 Implementer-Commits, zwei Reviewer-Commits).

**Prozess-Lücke, ausgewiesen:** Der Reviewer-Report Runde 2 bezieht sich auf `e1ad8ccf`. Danach hat der Implementer noch Code, Tests, Fälle und Spec geändert: `658b2138` (Tests), `588397a4` (Tests), `aa905f04` (`internal/span/span.go`: der Zweig `case navigated && !plainNavigationWord(f)`), `ac09c100` (Fälle 483 bis 487), `ead7fa0f` und `ed4eedcf` (SPEC-031). **Kein Reviewer hat diese Commits gesehen.** Der Zweig ist sicherheitsrelevant (`ADR-0011`, fail-closed). Er ist hier **nicht reviewt, vom Verifier gemessen** — die Messung steht unten; sie ersetzt keine Review-Runde, sie belegt, dass der Zweig bindet.

**Maßstab:** DoD und Plan des Slice (Ziel, §1 Abgrenzung, §2 Liefer-Punkte samt „Bricht, wenn", §3, §4, §5, §6, §8), `ADR-0011` (Festlegung 2: erstes Token statt Kommandozeile, fail-closed), `ADR-0022`, `LH-FA-10`, `SPEC-021`, `SPEC-031`, `AGENTS.md` §3.6, §3.7, §3.10, §3.11, `MR-071`, Baseline-Regelwerk Modul 11 §Bewusstes Brechen.

**Eingang:** Der Bericht des Implementers (Behauptung, unten je einzeln nachgefahren) und die zwei Review-Reports (`6bddaaef`: ein HIGH, zwei MEDIUM, ein LOW, vier INFO; `e1ad8ccf`: kein HIGH, zwei MEDIUM, zwei LOW, drei INFO) — gelesen, keine Zahl von dort übernommen.

**Eigene Läufe** (Scratchpad-Kopien von `git archive HEAD`, nie im Repo-Baum; kein `go`, kein `python3` auf dem Host; Go nur über `make test-go` im gepinnten Docker-Bild; ein Lauf 6 bis 8 Sekunden):

1. **Zwölf Fälle, je zwei Läufe** (Kontrolle: Mutation des Falls aktiv, nichts übersprungen; Gegenprobe: Mutation aktiv, **genau** der `# expect:`-Test durch `t.Skip` übersprungen, Skip-Zähler je Lauf auf 1 geprüft).
2. **45 Whitelist-Erweiterungen** (jedes ASCII-Zeichen 0 bis 127 außer Buchstaben, Ziffern, Whitelist, Leerzeichen, Tab, Zeilenende, je ein Lauf) und **18 Whitelist-Verkürzungen** (jedes der 18 schlichten Zeichen einzeln).
3. **21 weitere Schwächungen** des neuen Codes (Tabelle unten), je ein Lauf.
4. **Formen-Probe:** 101 + 27 + 19 Kommandozeilen (`span.Derive` und die geschriebene Zeile) gegen **drei Stände** von `internal/span/span.go` — HEAD, den Vorzustand des Slice (`5acbc97d~1`), und die HEAD-Tests gegen `490f2daa` (Runde 1) und `e1ad8ccf` (Runde 2); dazu sieben große Zeilen (Latenz).
5. **Träger real:** `make host-bin` in einer Kopie mit eigenem git-Repo, `span-emit` gegen fünf Payloads, die geschriebene Zeile gelesen (Closure-Trigger 2).
6. **Teillauf im Repo** `make mutate MUTATE_JOBS=1 MUTATE_CASES=<476 bis 487>`; **kein** voller `make mutate`.
7. `make docs-check` vor dem Commit dieses Reports, `make gates` nach dem Commit — Ergebnisse stehen in der Übergabe-Nachricht, nicht hier (der Report ist Teil des Prüfgegenstands).

**Beleg-Slot** `.harness/state/mutate-passed.key`: **vorher nicht vorhanden, nachher nicht vorhanden**; der Teillauf hat ihn nicht berührt.

## Ergebnis

| Punkt | Verdikt |
|---|---|
| Liefer-Punkt 1 — `commandProgram()` überspringt führende Navigations-Segmente (vier Gegenbeispiele, Wert-Schutz, Ränder, Fall 476) | **bestätigt** |
| Liefer-Punkt 2 — `argc` zählt bis zum Segment-Ende (Test, Fälle 477, 480, 481, 482) | **bestätigt** |
| Liefer-Punkt 3, erster Punkt — `SPEC-021` und `SPEC-031` nachgezogen | **bestätigt mit Vorbehalt** (V-4: die Whitelist steht in der Spec als Kopie, kein Sensor hält sie gegen den Code) |
| Liefer-Punkt 3, zweiter Punkt — Eigentumsfrage in §7 benannt, nicht entschieden | **offen, Planner-Arbeit** (§7 steht leer; siehe Übergaben, DoD-Wortlaut und `AGENTS.md` §3.10 stehen zueinander quer) |
| `make gates` grün | Lauf nach dem Commit dieses Reports; Ergebnis und Stempel in der Übergabe-Nachricht |
| Review durchgeführt, Report liegt vor | **bestätigt mit Vorbehalt** (zwei Runden liegen vor; die Nachrunde 2 ist ungesehen, V-1) |
| Closure-Trigger 1 — Gegenbeispiele rot gesehen, Fälle liegen in `test/mutations/`, `make mutate` meldet `0 Befund(e)`, `make gates` grün | **bestätigt mit Vorbehalt** (Teillauf `12 ok, 0 Befund(e)`; der **volle** Lauf ist nicht gefahren — verboten — und trägt der Nachtlauf `mutate.yml`) |
| Closure-Trigger 2 — frischer Strom zeigt das Programm und `argc` 1 an der geschriebenen Zeile | **bestätigt** (Träger real, Zeile gelesen, unten) |
| §1 Abgrenzung (kein `internal/emit/`, keine Vorlage, kein `span-report`, keine Zuweisungs-Regel neu) | **bestätigt** (`git diff --stat`: `internal/span/span.go`, `span_test.go`, `spec/spezifikation.md`, zwölf Fälle, zwei Reports, Roadmap, Slice-Move, drei Verweis-Nachzüge) |
| Größe (≤ 3 Liefer-Punkte, eine Review-Sitzung prüfbar) | Liefer-Punkte: drei, in der Zahl konform. **Prüfbarkeit in einer Sitzung: nicht getragen** (V-7 — ein Schnitt-Befund für die Closure, keine Entscheidung des Verifiers) |
| Closure-Pflichten (Notiz §7, Risiko-Ausgänge §6, DoD-Häkchen, Register, Paarungen) | **offen, Planner-Arbeit** (`AGENTS.md` §3.10; §7 leer, kein Häkchen gesetzt — richtig so) |

**0 HIGH · 0 MEDIUM · 3 LOW (V-2 bis V-4) · 4 INFO (V-1, V-5 bis V-7).** Kein Befund ist eine DoD-Verletzung. Kein Wort eines Kommentars, Here-Doc-Körpers, einer Folgezeile oder eines Zuweisungs-Werts erreicht `program` hinter einem Navigations-Segment (101 Formen, drei Stände).

## Liefer-Punkt 1 — Navigations-Segmente: bestätigt

**Zusage** (Slice §2): `cd /x && make gates` → `make`, `set -e; make gates` → `make`; `cd /x && TOKEN=abc gh pr create` → `gh`, weder `TOKEN` noch `abc` in der geschriebenen Zeile; `cd /x && TOKEN="abc def" gh pr create` → nichts; `cd /x`, `cd /x &&` → `cd`, `cd /x || exit 1` → `cd`, `cd a && cd b && make` → `make`; jedes über `Derive` **und** die geschriebene Zeile; `TestCommandProgramSkipsAssignments` und die Tests des ersten Slice grün und unverändert; ein Fall nimmt der Navigations-Grenze die Zähne, sein `sed`-Muster ist gegen den Quell-Bestand gemessen.

**Gemessen (HEAD, Formen-Probe; Vorzustand in Klammern):**

| Zeile | `program` / `argc` |
|---|---|
| `cd /x && make gates` | `make` / 1 (Vorz. `cd` / 4) |
| `set -e; make gates` | `make` / 1 (Vorz. `set` / 3) |
| `cd /x && TOKEN=abc gh pr create` | `gh` / 2 (Vorz. `cd` / 6) |
| `cd /x && TOKEN="abc def" gh pr create` | nichts (Vorz. `cd`) |
| `cd /x` · `cd /x &&` · `cd` · `set` | `cd`/1 · `cd`/1 · `cd`/0 · `set`/0 |
| `cd /x || exit 1` | `cd` / 1 (Vorz. 4) |
| `cd a && cd b && make` (im Test, Tabelle) | `make` |

Die Test-Tabellen führen jede Zeile des DoD-Wortlauts (`grep -cF` je Zeile ≥ 1). Jede der zwölf Test-Funktionen ruft `Derive` **und** `bashSpanLine`, außer `TestCommandProgramFirstWordKeepsItsGluedRest` (Ist-Verhalten, nur `Derive`). Gelöschte Zeilen in `internal/span/span_test.go` gegen den Vorzustand: **0** (`git diff 5acbc97d~1..HEAD -- internal/span/span_test.go | grep -c '^-[^-]'`); die Suite ist am HEAD grün (`make test-go` Exit 0).

**Vorzustand rot (Modul 11):** HEAD-Tests gegen `span.go` aus `5acbc97d~1`: rot `TestCommandProgramSkipsNavigationSegments` und `TestCommandArgcEndsWithItsSegment` (65 Teilfälle), Meldung z. B. `program = "cd", erwartet "make"`. **Die übrigen neuen Tests sind gegen den Vorzustand grün** — er nannte dort `cd`, und ihre Zusage ist gerade dieses `cd`. Sie binden nicht am Vorzustand, sondern an Zwischenstände und Mutationen: gegen `490f2daa` (Stand der Runde 1) rot `TestCommandProgramKeepsNavigationOnMultilineCommands`, `TestCommandProgramKeepsNavigationWhenItsEdgeIsUnsure`, `TestCommandProgramBehindNavigationIsAPlainWord`, `TestCommandArgcEndsWithItsSegment` (72 Teilfälle) — das ist der Beleg, dass die Nachrunde H-1 schließt; gegen `e1ad8ccf` (Stand der Runde 2) rot `TestCommandProgramBehindNavigationIsAPlainWord` (15 Teilfälle) — das ist der Beleg für den **nicht reviewten** Zweig.

**Closure-Trigger 2, am Träger gemessen** (`make host-bin` in einer Kopie, `span-emit` gegen je eine Payload, die geschriebene Zeile gelesen): `cd /x && make gates` → `"program":"make","argc":1`; `cd /x && TOKEN=abc gh pr create` → `"program":"gh","argc":2`, in der Zeile kommt weder `TOKEN` noch `abc` vor (`grep -c` → 0); `set -e; make gates` → `make`/1; `make gates && echo x` → `make`/1; `cd /x && "secret token" x` → **kein** `program`, kein `argc`, `secret` nicht in der Zeile.

## Liefer-Punkt 2 — `argc`: bestätigt

Zusage: Felder nach dem Programm bis zum Ende **seines Segments**; `cd /x && make gates` → 1, `make gates && echo x` → 1; der Wächter ist der Test dieses Liefer-Punkts, **nicht** der aus Liefer-Punkt 1.

Gemessen: `make gates && echo x` → `make`/1; `make; echo x y` → `make;`/0; `make gates\necho x y` → `make`/1; `make\necho x y` → `make`/0; `make gates \<Zeilenende> x` → `make`/2. Die Gegenprobe der Fälle 477, 480, 481, 482 (Tabelle unten): Mutation aktiv, `TestCommandArgcEndsWithItsSegment` übersprungen → **grün**; der Test ist der einzige Träger, kein Nachbar-Test deckt die argc-Grenze mit. Die Mutationen sind entflochten: 477 trifft die Operator-Felder, 480 das Feld auf `;`, 481 das Zeilenende, 482 die Fortsetzung — je eine Zeile im Quell-Bestand.

## Die zwölf Fälle 476 bis 487 — Kontrolle und Gegenprobe

Polarität ausgeschrieben. **Kontrolle:** „rot" = die Mutation färbt genau den benannten Test, der Fall trägt Zähne. **Gegenprobe** (Mutation aktiv, **Skip-Menge = genau der `# expect:`-Test**): „grün" = der benannte Test ist der **einzige** Träger des Rots, der Fall **bindet**; „rot" hieße: ein Nachbar-Test deckt dieselbe Stelle mit, der Fall ist entflochten verletzt.

| Fall | `# expect:` | geänderte Zeilen im Quell-Bestand (`MR-071`) | Kontrolle | Gegenprobe |
|---|---|---|---|---|
| 476 | `TestCommandProgramSkipsNavigationSegments` | 1 | rot, genau dieser Test | **grün** — bindet |
| 477 | `TestCommandArgcEndsWithItsSegment` | 1 | rot, genau dieser Test | **grün** — bindet |
| 478 | `TestCommandProgramKeepsNavigationWhenItsEdgeIsUnsure` | 1 | rot, genau dieser Test | **grün** — bindet |
| 479 | `TestCommandProgramKeepsNavigationOnMultilineCommands` | 1 | rot, genau dieser Test | **grün** — bindet |
| 480 | `TestCommandArgcEndsWithItsSegment` | 1 | rot, genau dieser Test | **grün** — bindet |
| 481 | `TestCommandArgcEndsWithItsSegment` | 1 | rot, genau dieser Test | **grün** — bindet |
| 482 | `TestCommandArgcEndsWithItsSegment` | 1 | rot, genau dieser Test | **grün** — bindet |
| 483 | `TestCommandWordsSplitAtTab` | 1 | rot, genau dieser Test | **grün** — bindet |
| 484 | `TestCommandBackslashBeforeBlankIsAWord` | 1 | rot, genau dieser Test | **grün** — bindet |
| 485 | `TestCommandProgramBehindNavigationIsAPlainWord` | 1 | rot, genau dieser Test | **grün** — bindet |
| 486 | `TestCommandProgramKeepsNavigationWhenItsEdgeIsUnsure` | 1 | rot, genau dieser Test | **grün** — bindet |
| 487 | `TestCommandProgramSkipsNavigationSegments` | 1 | rot, genau dieser Test | **grün** — bindet |

„Rot, genau dieser Test" gelesen an der Liste der Top-Level-`--- FAIL:`-Zeilen je Lauf: ein Name, der benannte. Die Meldung des Rots ist die behauptete Ursache, nicht irgendeine: 483 färbt `git<TAB>commit<TAB>-m<TAB>x`, `ls<TAB>-l<TAB>/tmp` und die zwei Zeilen mit Zuweisung/Navigation; 484 die Zeilen `A=b \ SECRETWORD` und `make gates \ x y`; 485 die zehn Zeilen mit Anführungszeichen, Substitution, maskiertem Leerzeichen und anhängendem Operator hinter `cd /x &&`; 486 den einen Teilfall `cd x<NUL>y && make`; 487 den einen Teilfall `cd x%y && make`.

**Kopf und Anker:** je Fall `# files:` und `# expect:` wie die Nachbarn (`408`, `475`); `# verify:` fehlt wie bei `408`, den Sensor `test-go` wählt der Treiber aus der Datei (`narrow_sensor`); `failure_form test-go` ist `--- FAIL:` und trifft. Modus **100644**, wie 470 bis 475 (`git ls-files -s`).

**Teillauf im Repo:** `12 ok, 0 Befund(e)`, `TEILLAUF 12 von 475 — kein Beleg`, `ok`-Zeile je Fall mit dem roten Test-Namen; Exit 0.

## Weitere Schwächungen (Tabelle)

Bei einer Schwächung des **Codes**: „rot" = die Suite färbt, die Schwächung ist erkannt, der Zahn **bindet**; „grün" = die Suite bleibt grün, die Stelle ist **unbewacht** (oder die Mutation ist äquivalent, dann benannt).

| Schwächung am HEAD-Code | Ergebnis |
|---|---|
| **(i)** der neue Zweig entfällt: `case navigated && !plainNavigationWord(f) && false:` | **rot**, `TestCommandProgramBehindNavigationIsAPlainWord` (10 Teilfälle, Fall 485) |
| `navigated = true` wird nicht gesetzt | **rot**, derselbe Test |
| **(ii)** Whitelist um je **ein** Zeichen erweitert: alle 44 Zeichen 0x01 bis 0x7f außer Buchstaben, Ziffern, Whitelist, Leerzeichen, Tab, Zeilenende, darunter `"` `'` `` ` `` `\` `(` `)` `;` `#` `<` `\|` `&` `{` `}` `!` und CR, DEL, VT | **je rot**, `TestCommandProgramKeepsNavigationWhenItsEdgeIsUnsure`; an acht Zeichen (`"` `'` `` ` `` `\` `&` `(` `;` CR) färbt zusätzlich `TestCommandProgramBehindNavigationIsAPlainWord` |
| **(v)** NUL in die Whitelist (Fall 486) | **rot** — der Sweep beginnt bei 0 |
| **(v)** jedes der 18 schlichten Zeichen `$%*+,-./:=>?@[]^_~` einzeln aus der Whitelist (18 Läufe), darunter `%` (Fall 487) | **je rot**, `TestCommandProgramSkipsNavigationSegments` |
| **(iii)** Tab ist keine Wortgrenze (Fall 483) | **rot**, `TestCommandWordsSplitAtTab` |
| **(iv)** `&& c == '\n'` entfällt (Fall 484) | **rot**, `TestCommandBackslashBeforeBlankIsAWord` |
| **(vi)** Einzeiligkeit: `singleLine := true` (Fall 479) · Rand-Ausnahme `k+1 < len(w.eol)` → `k < len(w.eol)` | **rot** · **rot** (`TestCommandProgramSkipsNavigationSegments`) |
| **(vi)** Schlichtheit: Prüfung aus (Fall 478) | **rot** |
| **(vi)** Ende: `j+1 < len(fields)` → `true` (kein Feld dahinter) · `body != f` aus · `isNavigation` erkennt nur `cd` · nur `set` · `skipNavigation` ohne Navigations-Prüfung | **je rot** |
| Feld dahinter / Sprung: `i = next` statt `next - 1` (Off-by-one) · `skipped = true` nach Navigation entfällt | **rot** (drei Tests) · **rot** |
| Nicht-ASCII nicht mehr schlicht · `&` hinter `>` nicht mehr schlicht · `prev` nicht mitgeführt | **je rot** |
| `eol` nicht markiert · argc-0-Zweig (`closesSegment(w, i)`) aus · Abbruch an `closesSegment(w, k)` aus · `return n + 1` | **je rot** |
| `namesProgram` gilt überall (auch ohne vorausgehendes Segment) | **rot**, `TestCommandProgramFirstWordKeepsItsGluedRest` — die Grenze des Programm-Felds ist gebunden (kein Fall, siehe V-5) |
| die Schlichtheits-Prüfung hinter Navigation gilt auch hinter einer Zuweisung | **rot**, nur `TestCommandBackslashBeforeBlankIsAWord` an `A=b \ SECRETWORD` — das Ist-Verhalten „hinter einer Zuweisung nennt das Feld das erste Wort, wo es steht" ist an dieser Zeile gebunden, für ein Wort in Anführungszeichen (`A=b "a b" x`) ist es **keine** Zeile (V-3) |
| Tab als schlichtes Zeichen des Wortes | **grün — äquivalent**: ein Tab kommt in keinem Wort vor, die Zerlegung trennt an ihm |
| `\n`, Leerzeichen, Tab in die Whitelist | nicht gefahren, äquivalent aus demselben Grund |
| Zwei erste Fassungen (`case false:`, `case … && prev == '>'` → `case false:`) | Compilefehler (`declared and not used`), keine Messung; als (i) und `&`-hinter-`>` neu gefasst, beide rot |

## Formen-Probe (Auszug; Ergebnis je Zeile am HEAD, Vorzustand in Klammern)

**Kein Fragment hinter Navigation** — jede Zeile mit `SECRETWORD`, `ghp_abc`, Wert oder Kommentar-Rest:

- `cd /x # note; SECRETWORD` → `cd` (Vorz. `cd`) · `cd /x\ncat <<EOF\nline;\nSECRETWORD\nEOF` → `cd` · `cd /x <<-EOF …` → `cd` · `cd /x <<EOF …` → `cd` · `cd /x <<< SECRETWORD` → `cd` · `cd /x && cat <<EOF …` → `cd` · `cd /x\necho hi; SECRETWORD` → `cd`.
- `cd /x\r\n&& make` → `cd` · `cd /x\x00 && make` → `cd` · `cd /x && make` → `cd` · `cd /x && make\nSECRETWORD` → `cd` · `cd /x && make;\nSECRETWORD` → `cd` · `TOKEN=abc\ncd /x && make` → `cd` · `cd /x &> f && SECRETWORD` → `cd` · `cd /x || SECRETWORD`, `cd /x | SECRETWORD`, `cd /x & SECRETWORD` → je `cd`.
- `cd /x&&SECRETWORD y`, `cd /x ;SECRETWORD`, `cd /x &&SECRETWORD`, `cd /x;make`, `cd "a && b" && make`, `cd /x # a; b`, `cd /x | make` → je `cd`.
- Anführungszeichen, Substitution, Wert hinter Navigation: `cd /x && "secret token" x`, `cd /x && 'a b' x`, `cd /x && $(cmd) x`, `` cd /x && `cmd` x ``, `cd /x && $'a b' x`, `cd /x && a\ b`, `cd /x && "$TOOL" x`, `cd /x && $TOOL=x y`, `cd /x && A=b "secret token" x`, `cd /x && TOKEN="abc def" gh pr create`, `cd /x && FOO=$(cat f) make`, `cd /x && (SECRETWORD)`, `cd /x && f() { SECRETWORD; }`, `cd /x && make; echo z`, `cd /x && make\r\n`, `cd /x &&  "secret token" x`, `cd /x && make\x00SECRETWORD` → je **nichts** (Vorz. je `cd`).
- Wert hinter Navigation: `cd /x && TOKEN=abc gh pr create` → `gh` / 2, `cd /x && FOO=bar make` → `make`, `cd /x && export TOKEN=ghp_abc && make` → `export` (der Wert steht nur in `argc`, nie im Feld), `cd /x && echo ghp_abc > f` → `echo` / 3, `cd /x && make # ghp_abc` → `make` / 2, `cd /x && make&&TOKEN=abc gh pr`, `make&&TOKEN=abc gh pr`, `make;TOKEN=abc gh pr` → nichts (das `=` im ersten Wort schaltet ab).

**Ein Wort, das ein Programm-Name in Befehlsposition ist** (kein Fund, nur die Probe-Marke `SECRETWORD` als Programm): `cd /x; SECRETWORD`, `cd /x && cd /y && SECRETWORD`, `cd /x && \<Zeilenende>SECRETWORD z` (die Fortsetzung verbindet die Zeile; in der Shell ein echter Befehl) → `SECRETWORD`. `cd /x && $SECRET` → `$SECRET` (der **Name**, nie der Wert). `cd /x && ~/bin/tool x`, `cd -- /x && make`, `cd $HOME/x && make`, `cd ../x && make`, `cd /x >& f && make`, `cd /x 2>&1 && make`, `cd\t/x\t&&\tmake\tgates` → `make`. Ein Unicode-Leerraum bleibt Teil seines Wortes, wie `SPEC-031` es sagt: `cd /x && make\u00a0gates` → `make\u00a0gates` / 0 (ein Wort, wie die Shell es liest; kein Fragment einer Folgezeile, trägt aber an einem NBSP-Zeichen mehr als den Namen).

**Preis der Whitelist (benannt, nicht Fund):** `cd "$DIR" && make` → `cd` (Vorz. `cd`) · `cd /x && make\r\n` → nichts (Vorz. `cd`) · `cd /x && make; echo z` → nichts · jede mehrzeilige Kommandozeile mit Navigations-Segment → `cd`.

**Ohne Navigation, Ist-Verhalten der Vorgänger-Regel** (HEAD und Vorzustand gleich; im Kommentar und in `SPEC-031` benannt): `"a b" x` → `"a` · `my\ tool secret` → `my\` · `>f make` → `>f` · `<<EOF cat …` → `<<EOF` · `# comment SECRETWORD` → `#` · `make;ls` → `make;ls` · `make; echo x y` → `make;` / 0 · `A=b\nSECRETWORD` → `SECRETWORD` · `A=b "secret token" x` → `"secret` · `A=b && "secret token" x` → `"secret`. **Neu erreichbar ist davon nichts hinter Navigation** — dort ist es jetzt „nichts" oder `cd`.

**Große Zeilen** (Latenz, `Derive`, gemessen im Test-Prozess): 1 MB Wörter 25 ms · 100 000 Wörter hinter `cd` 5,6 ms · `cd` ohne Ende 6,3 ms · 100 000-fache Kette `cd a && …` 34 ms · 100 000-faches `set -e; …` 27 ms · 1 MB binär (NUL, 0xff, Zeilenenden) 32 ms · 1 MB in einem Wort 2,5 ms. Linear; kein Panic, keine Quadratik (der Vorzustand liegt bei 3 bis 18 ms).

## Vergleich mit dem Plan (Plan-vs-Code-Diff)

**Plan → Code (geplant, gebaut):** §3 nennt `internal/span/span.go`, `internal/span/span_test.go`, zwei Fälle, `spec/spezifikation.md` §5. Gebaut: alle vier, dazu zehn weitere Fälle. `SPEC-021` (argc segment-begrenzt) und `SPEC-031` (Navigations-Segmente) sind nachgezogen; das Lastenheft ist unberührt; `internal/emit/` unberührt; Bestand nicht nachgezogen.

**Code → Plan (gebaut, nicht geplant, in Reihenfolge der Größe):**

1. **Zwölf Fälle statt zwei.** Jede Nachrunde hat die Fälle wachsen lassen (476 bis 478, 479 bis 482, 483 bis 487). Plan-Kopf und §3 sagen „zwei".
2. **Eine Whitelist statt einer Regel.** `plainNavigationWord` samt `plainNavigationChars` (18 Zeichen plus Buchstaben, Ziffern, `&` hinter `>`, Nicht-ASCII) ist die Bedingung, unter der ein Navigations-Segment übersprungen wird; der Plan kennt „Rand-Zeichen lassen `cd` stehen", nicht eine Menge.
3. **Einzeiligkeit** (`singleLine`, der Typ `words` mit `eol`) — der Plan kennt keine Zeilengrenze; sie ist die Antwort auf das HIGH der Runde 1.
4. **`argc` endet mit dem Zeilenende, ein einzelner Backslash vor dem Zeilenende setzt die Zeile fort** — der Plan nennt als Segment-Ende „Operator-Feld oder ein Feld auf `;`". Das Zeilenende ist eine dritte Grenze und ändert `argc` für jede mehrzeilige Zeile, nicht nur für Navigations-Zeilen.
5. **Hinter einem übersprungenen Navigations-Segment nennt das Feld nur ein schlichtes Wort** (`plainNavigationWord` am Programm-Wort) — der Plan kennt nur die Wert-Grenze der Zuweisung.
6. **`SPEC-031` wächst von 1174 auf 3821 Byte in einer Tabellenzelle** (`grep '^| `SPEC-031`' spec/spezifikation.md | wc -c` am HEAD und am Vorzustand).
7. Nicht im Plan und nicht gebaut: nichts, was der Plan verlangt, fehlt bis auf den zweiten Punkt von Liefer-Punkt 3 (§7, Planner).

Der Plan sagt im Kopf: *„Der Slice ändert **eine** Funktion und zwei Spec-Zeilen; sein Beleg sind … zwei Mutations-Fälle"*. Der Ist-Stand: neun Funktionen und Typen in `internal/span/span.go` (`commandProgram`, `isNavigation`, `plainNavigationWord`, `skipNavigation`, `closesSegment`, `segmentArgc`, `words`, `singleLine`, `splitWords`), `git diff --numstat`: `span.go` +201/−16, `span_test.go` +406, zwölf Fälle je 13 bis 18 Zeilen, `spec/spezifikation.md` 2/2. Der Verifier schreibt den Plan nicht um (`AGENTS.md` §3.10); die Differenz ist eine Übergabe.

## Review-Findings beider Runden

| Finding | Stand | Beleg |
|---|---|---|
| **R1 H-1** Kommentar-, Here-Doc- und Folgezeilen-Wörter erreichen `program` hinter `cd` | **behoben** | alle Formen der Runde 1 liefern `cd` (Formen-Probe, HEAD); HEAD-Tests gegen `490f2daa` rot (72 Teilfälle); Einzeiligkeit (479) und Schlichtheit (478) binden je einzeln, Gegenproben grün |
| **R1 M-1** drei Guards in `skipNavigation` ungebunden | **behoben** | in `plainNavigationWord` aufgegangen; jede Erweiterung und Verkürzung der Whitelist rot (45 + 18 Läufe) |
| **R1 M-2** argc-0-Zweig bei Programm auf `;` ungebunden | **behoben** | Fall 480, Gegenprobe grün; Schwächung „argc-0-Zweig aus" rot |
| **R1 L-1** Grenzen-Aufzählung ohne die gefahrenen Formen | **behoben** | Kommentar und `SPEC-031` nennen `make;`, `make&`, `make;ls`, `make\r`, `"a`, `my\`, `>f`, `<<EOF`, `#`; jede in der Probe gefahren, Ergebnis wie genannt |
| **R1 I-1** `fieldlist.go` sagt „das erste Token der Kommandozeile" | **offen** (Übergabe) | `internal/span/fieldlist.go` Zeile 94 unverändert; die Aussage ist mit diesem Slice falsch (V-6) |
| **R1 I-2** Fall 476 nennt einen Test, die Mutation färbt zwei | **behoben** | Gegenprobe 476 grün |
| **R1 I-3** Bestand mischt zwei Bedeutungen (`program` und `argc`) | **offen** (Übergabe) | kein Schreiber-Diff berührt einen Leser; Register `span-feld-bedeutung-wechselt-ohne-fassungs-angabe` trägt eine Evidence-Datei (`ls … | wc -l` → **1**) |
| **R1 I-4** Nachzug berührt zwei geschlossene Slice-Dateien | **offen** (Übergabe) | `1348b67b` schreibt in `done/` an drei plus einer Zeile Adressen um; in einer trägt der Satz hinter dem Link weiter `(`next/`)` (V-6) |
| **R2 M-1** Tab-Wortgrenze ungebunden | **behoben** | Fall 483 und `TestCommandWordsSplitAtTab`; Kontrolle rot, Gegenprobe grün |
| **R2 M-2** `c == '\n'` in der Fortsetzung ungebunden | **behoben** | Fall 484 und `TestCommandBackslashBeforeBlankIsAWord`; Kontrolle rot, Gegenprobe grün |
| **R2 L-1** Sweep ab 1, NUL ungebunden; Test trägt eine Kopie der Whitelist | **behoben** | Sweep ab 0, Fall 486 (Erweiterung um NUL) und Fall 487 (Verkürzung um `%`); die Kopie im Test ist die **erwartete Zusage**, gegen die der Code gemessen wird, Änderung im Code färbt rot (45 + 18 Läufe) |
| **R2 L-2** `cd /x && "secret token" x` nennt `"secret` | **behoben** | nichts, Fall 485; der Zweig ist **nicht reviewt** und hier gemessen (Schwächung (i) rot, Gegenprobe 485 grün) |
| **R2 I-1** Grenzen-Aufzählung nennt zwei gefahrene Formen nicht | **behoben** | die Aufzählung nennt sie (siehe R1 L-1) |
| **R2 I-2** der Preis der Whitelist ist nicht beziffert | **offen** (Übergabe) | `cd "$DIR" && make`, `cd $(dirname $0) && make`, `make\r\n` und jede mehrzeilige Zeile bleiben `cd` bzw. entfallen; ein Häufigkeits-Beleg besteht nicht (V-5) |
| **R2 I-3** Asymmetrie Zuweisung/Navigation für die Folgezeile | **behoben durch Benennung** | Kommentar: *„Hinter einer Zuweisung nennt das Feld das erste Wort, wo es steht, auch auf einer Folgezeile"*; Vorzustand gleich (Probe) |

## Befunde

### V-1 — INFO — die Nachrunde 2 ist von keinem Reviewer-Lauf gesehen, und sie trägt sicherheitsrelevanten Code

- `Befund`: `aa905f04` (Zweig `navigated`), `658b2138`, `588397a4` (Tests), `ac09c100` (Fälle 483 bis 487), `ead7fa0f` und `ed4eedcf` (SPEC-031) liegen nach dem Reviewer-Report Runde 2. Der Code-Anteil ist klein (`git diff --stat e1ad8ccf..HEAD -- internal/span/span.go`: 25 Einfügungen, 9 Löschungen), der Test-Anteil größer.
- `Wirkung`: Vom Verifier gemessen, nicht gelesen-und-gefragt: der Zweig fällt mit Schwächung (i) rot, die fünf Fälle binden (Kontrolle und Gegenprobe), 101 Formen zeigen kein Fragment im Feld. **Das ersetzt keinen zweiten Blick auf die Wahl** — dass die Whitelist am Programm-Wort dieselbe ist wie am Segment, ist eine Entscheidung des Implementers, die kein Reviewer bewertet hat. Ob der Planner eine dritte Runde will, ist seine Abnahme-Entscheidung.

### V-2 — LOW — `program` hat keine Längengrenze; hinter Navigation neu erreichbar

- `Zusage`: `ADR-0011` Festlegung 2 — das Programm-Token, nicht die Zeile.
- `Gemessen`: `cd /x && ` + 1 000 000 Zeichen `a` in einem Wort → `program` trägt alle 1 000 000 Zeichen (`aaaaaaaaaaaa…`, HEAD); ohne Navigation und im Vorzustand gilt dasselbe (`aaaa` → `aaaa`), hinter Navigation nannte der Vorzustand `cd`. Ein Span mit einem solchen Feld ist ebenso lang.
- `Wirkung`: Kein Wert einer Zuweisung, kein Fragment eines Strings — ein einzelnes schlichtes Wort in Befehlsposition. Die Zusage „ein Token" ist an der Länge unbewacht; ein Wort aus 2 000 Zeichen ist ein Wort. LOW, weil die Quelle eine Programm-Position ist und die Eingabe unwahrscheinlich; Regel-Kandidat, kein Fehler dieses Slice.

### V-3 — LOW — das Fragment eines Strings bleibt ohne Navigation erreichbar: `"secret` hinter einer Zuweisung und am Zeilenanfang

- `Zusage`: Slice §1 „wichtigstes Kriterium": kein Wert und kein Fragment hinter Navigation; `ADR-0011` Festlegung 2: erstes Token.
- `Gemessen`: `A=b "secret token" x` → `"secret`, `A=b && "secret token" x` → `"secret`, `"secret token" x` → `"secret` (HEAD und Vorzustand gleich). Hinter Navigation ist die Klasse geschlossen (`cd /x && "secret token" x` → nichts); die Schlichtheits-Prüfung gilt dort nur, weil `navigated` sie auslöst. Mit der Schwächung „gilt auch hinter einer Zuweisung" färbt nur die Zeile `A=b \ SECRETWORD`; für ein Wort in Anführungszeichen hinter einer Zuweisung steht **keine** Zeile in einer Tabelle. `SPEC-031` und der Kommentar benennen das Ist-Verhalten (*„das erste Wort, wie es dasteht"*, `"a b" x` → `"a`), für die Zuweisung nicht ausdrücklich.
- `Wirkung`: **Kein ADR-Verstoß** — `ADR-0011` verlangt das erste Token, und ein Wort in Anführungszeichen ist eines. Aber die Begründung, mit der der Slice hinter Navigation ein schlichtes Wort verlangt (das Bruchstück eines Strings ist kein Programm-Name), gilt eine Zeile weiter links unverändert; die Regel ist nur dort geschlossen, wo dieser Slice sie gebraucht hat. Die Reviewerin hat die Klasse als LOW gestuft; hier dieselbe Stufe.

### V-4 — LOW — die Whitelist steht in `SPEC-031` als handgeschriebene Kopie; kein Sensor hält sie gegen den Code

- `Zusage`: `SPEC-031`: *„eines der Zeichen `$%*+,-./:=>?@[]^_~`"* und *„Bewacht von … die schlichten Zeichen selbst: Fälle 486 und 487"*.
- `Gemessen`: Die Liste in der Spec ist am HEAD gleich `plainNavigationChars` im Code (gelesen, Zeichen für Zeichen). Kein Test liest `spec/spezifikation.md` (`grep -n 'spezifikation' internal/span/*_test.go` findet nur Kommentare), kein Modul des Doku-Gates hält die Liste gegen den Code. Die Fälle 486 und 487 binden **Code gegen die erwartete Menge im Test**, nicht gegen die Spec.
- `Wirkung`: Ändert der Code die Menge und zieht den Test mit, bleibt die Spec-Zeile still falsch. Die Zusage „Bewacht von … Fälle 486 und 487" ist breiter als ihr Sensor; das Gegenstück ist `slice-109-feldliste-jede-aussage-hat-ihre-quelle` (Kopplung Tabelle ↔ Träger), dort steht die Zeile nicht.

### V-5 — INFO — Nutzen der Änderung ist nicht beziffert, der Preis ist es

- `Befund`: Der Plan begründet den Slice mit **38 %** der `Bash`-Spans (`cd` allein häufiger als `git`, `make`, `grep` zusammen). Der Bestand trägt nur `program` und `argc`, nie die Zeile; ein Anteil der Zeilen, die die Regel **auflöst**, lässt sich daraus nicht messen. Bekannt sind die Formen, die sie **nicht** auflöst: jedes Argument in Anführungszeichen (`cd "$DIR" && make`), jede Substitution, jedes Zeilenende zwischen Wörtern (etwa in einer `git commit -m`-Nachricht hinter dem `cd`), CRLF. Für den Closure-Trigger 2 genügt ein frischer Strom (gemessen, s. o.); ob die 38 % tatsächlich fallen, zeigt erst ein Strom über die Zeit.
- `Wirkung`: Keine DoD-Verletzung. Für den Lerneintrag: die Schließung eines Lecks (H-1) hat den Nutzen verengt, die Größe der Verengung ist ungemessen.
- Außerdem: `TestCommandProgramFirstWordKeepsItsGluedRest` (die Grenze des Programm-Felds ohne Navigation) trägt **keinen** Fall in `test/mutations/`; eine Schwächung färbt ihn (gemessen), aber `make mutate` bewacht ihn nicht — Ist-Verhalten, nicht Zusage; benannt statt verschwiegen.

### V-6 — INFO — Zustandsaussagen, die durch den Slice falsch werden oder schon falsch sind

`git grep -n 'erste Token\|erstes Token' -- docs/user README.md harness/README.md internal/span/fieldlist.go` findet **einen** Treffer: `internal/span/fieldlist.go` Zeile 94, *„das erste Token der Kommandozeile, nie die Zeile"* — falsch seit diesem Slice (`SPEC-021` sagt jetzt *„das erste Wort des ausgeführten Segments"*). `docs/user/`, `README.md` und `harness/README.md` nennen `program` nicht. `ADR-0011` (Accepted, Zeile der Tabelle mit *„erstes Token + Argument-Anzahl"*) bleibt unangetastet (`AGENTS.md` §3.4). Die Adresse `slice-109-feldliste-jede-aussage-hat-ihre-quelle` (`next/`) führt `fieldlist.go` als Änderungs-Objekt, **nennt** aber die `program`-Zeile nicht. In den zwei angefassten `done/`-Dateien (Verweis-Nachzug `1348b67b`) steht hinter einem nachgezogenen Link weiter `(`next/`)`; das ist ein Zeitdokument, hier nur gemeldet.

### V-7 — INFO — der Schnitt trägt die Prüfbarkeit in einer Sitzung nicht

- Zahl der Liefer-Punkte: drei, konform. Aber: `span.go` +201/−16 (der Plan sah eine Funktion), `span_test.go` +406, zwölf Fälle (der Plan sah zwei), `SPEC-031` auf das 3,3-fache, **zwei Review-Runden und eine Nachrunde ohne Review** (17 Implementer-Commits nach dem Claim). Jede Runde hat dieselbe Klasse in der nächsten Fassung gefunden: die Rand-Menge eines Textscanners (H-1: Kommentar, Here-Doc, Folgezeile → Runde 2: Tab, Fortsetzung, Anführungszeichen am Programm-Wort → Verifier: Fragment hinter Zuweisung, Länge, Kopie in der Spec).
- Die Rückführungs-Bedingung `in-progress → next` in §4 lautet: *„Die Segment-Trennung lässt sich nicht textuell ziehen … eine tragfähige Fassung verlangt eine Zerlegung der Zeile statt einer Übersprung-Regel. Dann ist es ein anderer Slice."* Die Bedingung ist an Kommentar, Here-Doc, Anführungszeichen und Zeilenende **berührt** worden; der Implementer hat mit einer engeren Übersprung-Regel geantwortet (Whitelist, Einzeiligkeit, fail-closed), nicht mit einer Zerlegung. Ob das Trigger eingetreten ist, ist eine Abnahme-Entscheidung des Planners; der Verifier benennt: die Regel trägt an 101 gefahrenen Formen und an 84 Schwächungen (ohne die zwölf Fälle), ihr Nutzen ist ungemessen (V-5), ihr Preis steht in `SPEC-031`.

## Übergaben an den Planner

**§6-Risiken-Ausgänge** (Vorschlag; gesetzt vom Planner): (a) *Das Navigations-Überspringen umgeht die Wert-Grenze* — **entfallen**: `cd /x && TOKEN=abc gh pr create` → `gh` ohne `TOKEN`/`abc` in der Zeile (Träger real), `cd /x && TOKEN="abc def" gh pr create` → nichts, kein Zweig liest den Rest der Zeile an der Wert-Prüfung vorbei (`grep -rn 'commandProgram\|segmentArgc\|Derive(' internal/ cmd/`: `Derive` nur in `emit.go`, `commandProgram` nur in `Derive`, `segmentArgc` nur in `commandProgram`). (b) *`&&` und `;` sind Text, nicht Struktur* — **eingetreten, aufgefangen im Slice**: die Whitelist und die Einzeiligkeit sind die Antwort; `a&&b` ist kein Feld und beendet nichts (SPEC-031 sagt es); der Preis steht in V-5. (c) *Der Bestand mischt zwei Bedeutungen, an zwei Feldern* — **weiter offen**, ins Register: `span-feld-bedeutung-wechselt-ohne-fassungs-angabe` bekommt eine Evidence-Datei mit Vorgang `slice-204-das-programm-feld-nennt-das-programm` (der Zähler ist die Dateizahl, heute **1**). (d) *Der erste Slice liefert den Begriff anders* — **entfallen**: der Vorgänger-Slice liegt in `done/`, die Wert-Grenze und das Segment ohne Programm tragen (Test des Vorgängers unverändert grün, 0 gelöschte Zeilen). (e) *Kein Rollen-Eigentum am Spec-Stratum* — **weiter offen** an `slice-151-spec-straten-haben-eine-schreibende-rolle` (`open/`): die zwei Zeilen wurden von einem Lauf mit der Rolle Implementer geschrieben (die Commit-Messages nennen sie), aus Zweckmäßigkeit wird keine Zuständigkeit abgeleitet.

**Zu Liefer-Punkt 3, zweiter Punkt (§7):** Der Plan legt die Eigentums-Zeile in §7 in die Hand *„des Laufs, der die Spec-Zeilen schreibt"*; `AGENTS.md` §3.10 legt die Closure-Notiz in die des Planners, ausdrücklich nicht in den ausführenden Lauf. Beide Aussagen stehen quer; der Implementer hat §7 richtig leer gelassen. Der Planner schreibt die Zeile bei der Closure.

**Register-Kandidaten** (die Entscheidung liegt bei der Closure; keine Zahl ohne Kommando): (1) `zusage-ohne-herstellbares-gegenbeispiel` / *Grenzen-Aufzählung ohne Formen-Probe* — die Reviewerin nennt die Klasse zweimal in beiden Runden. (2) Neu: **Textscanner ohne Rand-Menge** — je Runde eine weitere Rand-Klasse (Kommentar, Here-Doc, Folgezeile; Tab, Fortsetzung, Anführungszeichen am Programm-Wort; Fragment hinter Zuweisung, Länge). (3) `regel-rand-ohne-benannte-luecke` — V-3 und V-2. (4) Eine Spec-Zeile, die eine Menge nennt, die ein Test als eigene Kopie führt, ohne dass ein Sensor Spec und Code verbindet (V-4).

**Lerneintrag-Vorschlag** (der Planner schreibt): *geschärfte Regel* — eine Regel, die Text an Leerraum zerlegt und daraus ein Feld liest, führt für ihr **Wort** (nicht nur für ihr Segment) dieselbe Schlichtheits-Prüfung; und ein Slice, dessen Rückführungs-Bedingung „nicht textuell ziehbar" lautet, hält bei der ersten Berührung dieser Bedingung an und entscheidet, statt sie in Runden zu verengen. Oder *neuer Sensor* — ein Test, der die Zeichenliste der `SPEC-031`-Zeile gegen `plainNavigationChars` liest (V-4).

**Zustandsaussagen zum Nachziehen** (V-6): `internal/span/fieldlist.go` Zeile 94; die `(`next/`)`-Klammer in der `done/`-Datei des Vorgänger-Slice; eine Nutzerdoku nennt `program` nicht (`docs/user/`: kein Treffer).

**Kein Befund geht zurück an den Implementer als DoD-Verletzung.** V-2 bis V-4 sind Beobachtungen für die Closure; ob eines davon ein Folge-Slice ist, entscheidet der Planner. Eine dritte Review-Runde über `e1ad8ccf..HEAD` ist eine Abnahme-Entscheidung (V-1).

## Was gelesen und was gemessen ist

**Gemessen (selbst gefahren):** zwölf Fälle je Kontrolle und Gegenprobe (24 Läufe); 45 Whitelist-Erweiterungen; 18 Verkürzungen; 21 weitere Schwächungen samt der Neufassungen; HEAD-Tests gegen `5acbc97d~1`, `490f2daa`, `e1ad8ccf`; 147 Kommandozeilen der Formen-Probe gegen HEAD, 101 davon auch gegen den Vorzustand; sieben große Zeilen; `span-emit` am realen Träger (fünf Payloads); der Teillauf im Repo (`12 ok, 0 Befund(e)`); Anker je Fall gegen den Quell-Bestand; Modus der zwölf Fälle; `failure_form()`; Beleg-Slot vorher und nachher.

**Nur gelesen, nicht gemessen:** das Verhalten anderer Shells (`zsh`: `!`, `^`), Nicht-ASCII-Wortzeichen in fremden Locales, die bats-Suite und `make hook-overhead` unter geschwächtem `span.go` (die Schwächungen liefen gegen `make test-go`, den Sensor der Fälle 476 bis 487), Bestands-Spans (sie tragen keine Zeile), die emittierten Vorlagen unter `internal/emit/templates/`, `make lint` einzeln (läuft in `make gates`), ein **voller** `make mutate` (Nachtlauf `mutate.yml`), die Gate-Ergebnisse (stehen in der Übergabe-Nachricht).

## Gate-Lauf

`make docs-check` vor und `make gates` nach dem Commit dieses Reports — die Ergebnisse stehen in der Übergabe-Nachricht an den Aufrufer (Exit-Code, Stempel-Vergleich, Baum sauber), nicht in diesem Zeitdokument: der Report ist Teil des Prüfgegenstands, und ein Lauf-Protokoll darin wäre ein Stand, den der nächste Commit überholt.
