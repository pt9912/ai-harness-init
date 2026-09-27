# Review-Report: slice-204-das-programm-feld-nennt-das-programm — 2026-09-27

**Review-Art:** Code-, Test-, Mutations-Fall- und Spec-Diff gegen Plan, ADR und Hard Rules (Modul 10). Nicht gegen die DoD (das ist der Verifier).

**Gegenstand:** `git diff 5acbc97d~1..490f2daa` (7 Commits, Baum sauber). `5acbc97d` (`make slice-mv`, Claim-Move `next/` → `in-progress/`, reiner Move) und `1348b67b`
(Verweis-Nachzug, drei Dateien), `9ab93032` (Ruhe-Marker der Roadmap entfernt), `959881ef` (vier Tests), `dfa544df` (`internal/span/span.go`), `36345a83`
(Mutations-Fälle 476, 477, 478), `490f2daa` (`SPEC-021`/`SPEC-031` in `spec/spezifikation.md`, ein Zusatzfall im Test).

**Plan-Bezug:** Slice `slice-204-das-programm-feld-nennt-das-programm` (§1 Ziel und Abgrenzung, §2 Liefer-Punkte 1 bis 3, §3, §4 Rückführungen, §6) — Kennung, nicht Pfad: der Plan
wandert mit dem Lifecycle (`AGENTS.md` §3.11). **Constraint:** `ADR-0011` (Festlegung 2: `program` ist das erste Token, nie die Zeile; fail-closed), `ADR-0022`, `LH-FA-10`,
`MR-019`, `MR-071`, `AGENTS.md` §3.3, §3.6, §3.7, §3.8, §3.9, §3.10, §3.11; `SPEC-021`, `SPEC-031`.

**Skill:** `.harness/skills/reviewer.md` @ Version 2.1.0 (2026-09-26)
**Modell:** Sonnet 5 · **Datum:** 2026-09-27

**Eingangs-Kontext:** Diff · Slice-Plan vollständig · `ADR-0011` (Festlegung 2 und 6) · `spec/spezifikation.md` §5 (`SPEC-021`, `SPEC-031`) · `internal/span/` samt Tests · `failure_form()` in
`harness/tools/mutate.sh` · Nachbar-Fälle 470 bis 475 und 404/405 · das Vorgänger-Review (Form-Muster) · `AGENTS.md` §3. Der Implementer-Bericht lag als Behauptung vor
und ist nicht übernommen; jede Zeile davon ist unten gemessen.

**Eigene Sensor-Läufe dieses Laufs** — Scratchpad-Kopien von `git archive HEAD` (kein `.git`, außer der Kopie für `make mutate`), Go nur über `make test-go` (Docker),
keine Host-Toolchain, kein Push. 26 Schwächungen von `internal/span/span.go` je eine Kopie, der Vorzustand des Codes (`dfa544df~1`) gegen die neuen Tests, zwei Probe-Tabellen
(Formen der Shell-Sprache), drei Gegenproben, ein Teillauf `make mutate` in der Kopie.

## Messbeleg

Polarität ausgeschrieben. Bei einer Schwächung des **Codes**: „rot" = die Suite färbt, die Schwächung ist erkannt, der Zahn **bindet**; „grün" = die Suite bleibt bei
geschwächtem Code grün, die Stelle ist **unbewacht**. Bei einer Gegenprobe (Mutation eines Falls aktiv, der benannte **Test** übersprungen): „grün" = der benannte Test ist der
einzige Träger des Rots, der Fall **bindet**; „rot" = ein anderer Test deckt dieselbe Mutation mit.

| Lauf | Ergebnis |
|---|---|
| HEAD, `make test-go` | Exit 0 |
| Vorzustand `dfa544df~1` von `span.go` gegen die neuen Tests | rot: `TestCommandProgramSkipsNavigationSegments`, `TestCommandProgramNeverEmitsValueBehindNavigation`, `TestCommandArgcEndsWithItsSegment`, 32 Teilfälle; Meldung gelesen, z. B. `Derive: program = "cd", erwartet "make" (Zeile "cd /x && make gates")` und `program = "cd;", erwartet "make" (Zeile "cd; make")`. `TestCommandProgramKeepsNavigationWhenItsEdgeIsUnsure` bleibt dort grün (erwartet `cd`) — er bewacht die neue Regel, nicht den Vorzustand |
| (a) je ein Zeichen aus `navigationUnsureChars` entfernt: `"`, `'`, `` ` ``, `\`, `(`, `)`, `{`, `}` | acht Läufe, **je rot**, jedes Mal genau `TestCommandProgramKeepsNavigationWhenItsEdgeIsUnsure` mit dem Teilfall dieses Zeichens — der Test bindet jedes Zeichen einzeln |
| (b1) `HasSuffix(f, ";")` als Ende in `skipNavigation` entfernt | rot (`set -e; make gates`, `cd /x; make gates`, `cd; make`, …) |
| (b2) `HasSuffix(f, ";")` als Ende in `segmentArgc` entfernt | rot (`make gates; echo x y`) |
| (b3) `segmentArgc`: Programm-Feld auf `;` ergibt argc 0 — entfernt | **grün — unbewacht**, M-2 |
| (c) `\|\|` als argc-Ende weggelassen | rot (`make gates \|\| echo x`) |
| (d1) nur `&&`, `;`, `\|\|` als argc-Ende | rot |
| (d2) `\|` weggelassen · (d3) `&` weggelassen · (d4) `&&` weggelassen · (d5) `;` weggelassen | je rot, je an der eigenen Zeile der Tabelle |
| (e1) `skipNavigation`: Guard `\|` entfernt · (e2) Guard `\|\|` entfernt · (e3) Guard `&` entfernt | **je grün — unbewacht**, M-1 |
| (f) `j+1 < len(fields)` → `true` (Operator ohne Folge-Feld) | rot (`cd /x &&`, `cd /x ;`, `cd /x;`) |
| (g1) nur `cd` als Navigation · (g2) nur `set` | je rot |
| (h) `skipped = true` nach dem übersprungenen Segment entfernt | rot (`cd /x && (make)`, `cd /x && >f make`) — die Entscheidung des Implementers trägt |
| (k) `TrimSuffix(fields[i], ";")` entfernt (`cd;` als Navigation) | rot (`cd; make`) |
| (l) `namesProgram` nach dem Sprung ausgeschaltet | rot, an drei Tests |
| Teillauf `make mutate MUTATE_JOBS=1 MUTATE_CASES='476-… 477-… 478-…'` in der Kopie mit `git init` | `3 ok, 0 Befund(e)`, `TEILLAUF 3 von 466 — kein Beleg`, Exit 0; Beleg-Slot `mutate-passed.key` im Repo und in der Kopie vor und nach dem Lauf nicht vorhanden |
| Gegenprobe 477 (Mutation aktiv, `TestCommandArgcEndsWithItsSegment` übersprungen) | **grün** — bindet |
| Gegenprobe 478 (Mutation aktiv, `TestCommandProgramKeepsNavigationWhenItsEdgeIsUnsure` übersprungen) | **grün** — bindet |
| Gegenprobe 476 (Mutation aktiv, `TestCommandProgramSkipsNavigationSegments` übersprungen) | **rot** — `TestCommandProgramNeverEmitsValueBehindNavigation` färbt dieselbe Mutation mit; der Bericht des Implementers („grün = bindet" für 476 bis 478) trägt für 476 nicht, I-2 |

Probe-Tabelle (Ergebnis je Kommandozeile `program` / `argc`, am HEAD): gefahren sind `cd -`, `cd`, `pushd /x && make`, `popd`, `set -euo pipefail` (mit und ohne Folgezeile),
`cd /x; make`, `cd /x&&make gates`, `cd /x && cd /y && make`, `(cd /x && make)`, `cd "a && b" && make`, `cd $(pwd) && make`, Backticks, `cd /x && TOKEN=abc gh pr create`,
`cd /x &&` + Zeilenumbruch + `make`, `cd /x && \` + Zeilenumbruch + `make`, leere und leerraum-Zeile, `cd /x`, `cd /x &&`, `cd ~ && make`, `cd /x || exit 1`, `cd /x || exit 1; make`,
`cd /x | make; echo z`, `cd /x & make; echo z`, `cd /x && ! make`, `if`-/`for`-Körper hinter `cd`, `export TOKEN=abc && make`, `A=b && make`, Redirect-Formen, Kommentar hinter dem
Segment, mehrzeilige Kommandos, unquotiertes und quotiertes Here-Doc, `make; echo x y`. Die auffälligen Ergebnisse stehen bei H-1, L-1 und M-2.

## Findings

### H-1 — `program` nimmt Wörter aus Here-Doc-Körper, Kommentar und Folgezeilen hinter einem `cd` ohne `&&`/`;`

- `kategorie`: HIGH
- `quelle`: ADR-0011 (Festlegung 2: erstes Token, nie die Zeile; fail-closed), AGENTS.md §3.6, Slice §1 („das wichtigste Kriterium": ein Fragment darf hinter einer Navigation nie im Feld landen)
- `pfad`: internal/span/span.go — `skipNavigation` (die Schleife über `fields[j]`), dazu `splitWords` (Zeilenende ist Wortgrenze, kein Segment-Ende)
- `befund`: `skipNavigation` sucht das Ende des Navigations-Segments über den ganzen Rest der Zeile, und ein Zeilenumbruch beendet es nicht; das nächste Wort nach dem ersten `&&` oder
  einem Feld auf `;` wird `program`, gleich wo es steht. Gefahren, jeweils am HEAD: `cd /x` + Zeilenumbruch + `cat <<EOF` + Zeilenumbruch + `line;` + Zeilenumbruch + `SECRETWORD` +
  Zeilenumbruch + `EOF` → `program` = `SECRETWORD`; `cd /x # note; ghp_abc` → `program` = `ghp_abc`; `cd /x` + Zeilenumbruch + `echo hi; SECRETWORD` → `SECRETWORD`. Im Vorzustand nennt
  jede dieser Zeilen `cd`. Ein Wort aus dem Inhalt eines Here-Docs oder eines Kommentars steht damit im Span — der Weg, den ADR-0011 sperrt, und er ist durch diesen Diff neu geöffnet.
  Das quotierte Here-Doc (`<<'EOF'`) bleibt zufällig zu, weil `'` im Feld `<<'EOF'` das Rand-Zeichen ist; das unquotierte nicht.
- `verifizierbar`: ja — ein Test mit diesen Zeilen über `Derive` und die geschriebene Zeile färbt gegen den HEAD rot; heute prüft keiner die Form (die Rand-Zeichen-Tests kennen weder
  Zeilenende noch `<<` noch `#`).
- `klasse`: Segment-Erkennung über Text, in dem Zeilenende, Kommentar und Here-Doc nicht als Grenze vorkommen
- Anmerkung zur Stufe: die Grenzen-Zeile im Kommentar über `commandProgram` nennt „Here-Doc-Körper" und sagt, sie stünden „nur dann nicht im Feld, wenn eine der Regeln oben greift".
  Vor diesem Diff war das für ein Wort **hinter einer Navigation** nicht erreichbar; die Aufzählung nennt weder Zeilenende noch Kommentar. Skill-Zeile „Grenzen-Aufzählung ohne
  Formen-Probe": gefahrene Form fehlt, kein Gate meldet die Folge → HIGH. Bei Widerspruch des Implementers gilt der Konflikt-Pfad aus Modul 8 (Architect-Verdikt als Artefakt), nicht Herabstufung.

### M-1 — die drei Guards `||`, `|`, `&` in `skipNavigation` sind unbewacht

- `kategorie`: MEDIUM
- `quelle`: AGENTS.md §3.6; SPEC-031 (`cd /x || exit 1` und `cd /x | make` nennen `cd`)
- `pfad`: internal/span/span.go — `skipNavigation`, `case f == "||" || f == "|" || f == "&"`; internal/span/span_test.go — Tabelle in `TestCommandProgramSkipsNavigationSegments`
- `befund`: Jeder der drei Guards einzeln entfernt lässt die Suite grün (e1, e2, e3). Die Tabellenzeilen `cd /x || exit 1`, `cd /x | make`, `cd /x & make` tragen kein späteres `&&` oder `;`;
  ohne Guard endet die Schleife ohne Ende und sagt `cd` — dieselbe Antwort. Unterscheiden würde `cd /x || exit 1; make` (mit Guard `cd`, ohne Guard `make`; am HEAD `cd`, gemessen), die
  im Bestand häufigste Form dieser Zeile. Die Zusage der Spec-Zeile ist damit nur an Zeilen gebunden, die den Guard nicht brauchen.
- `verifizierbar`: ja — Zeile `cd /x || exit 1; make` in die Tabelle, dann müssen e1 bis e3 rot werden; Fall in `test/mutations/` fehlt ebenfalls.
- `klasse`: Zusage ohne Gegenbeispiel, das den Zweig unterscheidet

### M-2 — `segmentArgc`: „Programm-Feld auf `;` → argc 0" ist unbewacht

- `kategorie`: MEDIUM
- `quelle`: AGENTS.md §3.6
- `pfad`: internal/span/span.go — `segmentArgc`, erste `if`-Bedingung (`HasSuffix(fields[i], ";")`) und deren Funktionskopf („Endet das Programm-Feld selbst auf `;`, ist das Segment zu Ende und argc 0")
- `befund`: Die Zeile entfernt (b3) lässt die Suite grün. Die einzige Tabellenzeile mit Programm-Feld auf `;` fehlt: `make; echo x y` liefert am HEAD `program` = `make;`, `argc` 0 (gefahren); ohne die Zeile wäre
  `argc` 3. Die Zusage steht im Code-Kommentar, ein Test und ein Fall dazu nicht. Nebenbefund: das Feld `program` trägt dabei das `;` (`make;`, im Vorzustand ebenso `cd;`); SPEC-031 nennt „das erste Wort",
  die Aussage über den Wert mit `;` steht nirgends.
- `verifizierbar`: ja — Tabellenzeile `make; echo x y` → argc 0, danach muss (b3) rot werden.
- `klasse`: Zusage ohne Gegenbeispiel, das den Zweig unterscheidet

### L-1 — Grenzen-Aufzählung nennt `a&&b`, nicht die übrigen gefahrenen Formen; zwei Ergebnisse führen in die Irre

- `kategorie`: LOW
- `quelle`: Skill-Zeile „Grenzen-Aufzählung einer erkennenden Regel ohne Formen-Probe"; SPEC-021, SPEC-031
- `pfad`: internal/span/span.go — Kommentar über `commandProgram` (Absatz „Grenze"); spec/spezifikation.md — `SPEC-031`, `argc`-Satz; internal/span/span_test.go — Zeile `make gates&&echo x`
- `befund`: Gefahren und in keiner der drei Stellen genannt: (1) `cd /x;make && echo x` und `cd /x&&make gates && echo x` → `program` = `echo`, `argc` 1 — das Wort hinter dem **späteren** Operator
  statt eines der beiden Programme, die liefen (Grenze und Test nennen nur den Fall ohne späteren Operator); (2) `cd /x && \` + Zeilenumbruch + `make` → `program` = `\` (kein Programm; das Wort nach dem Sprung
  passiert `namesProgram`); (3) Zeilenumbruch als Kommando-Trenner: `make gates` + Zeilenumbruch + `echo x y` → `argc` 4, obwohl SPEC-021 „die Argumente **dieses** Segments" verspricht und
  „nicht bis zum Zeilenende" sagt; (4) `||` beendet `argc` (Test-Zeile und Fall-Wirkung c bewachen es), die Operator-Liste des `argc`-Satzes in SPEC-031 nennt `||` nicht. (1) bis (3) sind Aussagen über
  den Wert, nicht Lecks. `(cd /x && make)` → `(cd` ist unverändert zum Vorzustand.
- `verifizierbar`: ja
- `klasse`: Grenzen-Aufzählung einer erkennenden Regel ohne Formen-Probe

### I-1 — `fieldlist.go` sagt „das erste Token der Kommandozeile" und wird durch diesen Diff falscher

- `kategorie`: INFO
- `quelle`: SPEC-021; ADR-0011
- `pfad`: internal/span/fieldlist.go:94
- `befund`: Der emittierte Feldtext beschreibt `program` als erstes Token; seit dem Vorgänger-Slice trifft das für Zuweisungen nicht zu, jetzt zusätzlich nicht für Navigations-Segmente. Ein Test, der den Wortlaut gegen den Träger
  hält, existiert nicht (`fieldlist_test.go` misst Feldnamen und die gerenderte Tabelle). `internal/emit/` ist im Diff unberührt, die Slice-Grenze hält. Adresse: `slice-109-feldliste-jede-aussage-hat-ihre-quelle` in `next/`.
- `verifizierbar`: nein — kein Gate
- `klasse`: Emittierter Feldtext bindet nicht an die Träger-Regel

### I-2 — Fall 476 nennt einen Test, die Mutation färbt zwei; der Bericht meldet Gegenprobe „grün" für alle drei Fälle

- `kategorie`: INFO
- `quelle`: AGENTS.md §3.6; Register-Klasse `mutations-fall-nennt-einen-test-die-mutation-faerbt-mehrere`
- `pfad`: test/mutations/476-span-program-navigation-nicht-uebersprungen.sh
- `befund`: `# expect:` nennt `TestCommandProgramSkipsNavigationSegments`; die Mutation färbt auch `TestCommandProgramNeverEmitsValueBehindNavigation`. Der Kopf des Falls sagt das ausdrücklich. Es ist die dokumentierte Klasse, kein neuer Defekt;
  `make mutate` verlangt das Rot des **genannten** Tests, das Weakening des benannten Tests wird damit erkannt. Die Gegenprobe bei übersprungenem Namen ist für 476 rot (gemessen), nicht grün wie berichtet; für 477 und 478 grün.
- `verifizierbar`: ja
- `klasse`: mutations-fall-nennt-einen-test-die-mutation-faerbt-mehrere

### I-3 — Bestand mischt zwei Bedeutungen; kein Leser bricht; die Fassung steht in keinem Feld

- `kategorie`: INFO
- `quelle`: Slice §6 (Risiko 3); ADR-0011
- `pfad`: internal/span/emit.go; harness/tools/hook-overhead.sh
- `befund`: Der Diff schreibt die neue Regel in SPEC-021/SPEC-031 und behauptet für alte Spans nichts. Leser von `program`/`argc` gemessen (`grep`): `emit.go` (Schreiber), `hook-overhead.sh` (baut aus `program` und `argc` eine
  Ersatz-Kommandozeile für einen Replay; tolerant gegen beide Bedeutungen), die Asserts `"program":"make"` in `span-check.sh`, `full-smoke.sh` und `span_emit_test.go` (einfaches `make`, unberührt). `span-report` liest das Feld nicht. Den Ausgang des Risikos
  (weiter offen / Register) trifft der Planner bei der Closure, nicht dieser Diff.
- `verifizierbar`: ja
- `klasse`: Bestand mischt zwei Feld-Bedeutungen ohne Fassungs-Marke

### I-4 — Nachzug berührt zwei geschlossene Slice-Dateien; die Fließtext-Klammer dort ist veraltet

- `kategorie`: INFO
- `quelle`: AGENTS.md §3.11
- `pfad`: `slice-program-feld-nennt-weder-operator-noch-wertfragment` (`done/`), `slice-span-programm-nennt-das-programm` (`done/`), `slice-205-der-strom-traegt-die-zug-grenze` (`open/`)
- `befund`: Der Nachzug (`1348b67b`) ändert nur Link-Ziele und einen Code-Span in drei Slice-Dateien, nichts in `docs/reviews/`, `docs/plan/adr/` oder `.harness/baseline/`; der erste Commit ist ein reiner Move. In der `done/`-Datei des
  Vorgängers steht hinter dem Link weiter „(`next/`)" — Zustandsprosa, die der Nachzug nicht erreicht.
- `verifizierbar`: nein
- `klasse`: Zustandsprosa neben einem Link, den der Nachzug bewegt

## Entscheidungen des Implementers, die vom Plan abweichen oder ihn ergänzen

- **Rand-Zeichen-Wächter (`navigationUnsureChars`).** Fail-closed-konform und im Plan als Rückführung §4 vorgesehen; jedes der acht Zeichen ist einzeln gebunden (Läufe (a)). Nicht erfasst sind `#`, `<` und das Zeilenende (H-1) — die Wahl trägt nicht so weit, wie ihr Kommentar es liest.
  Der Preis (`cd "/pfad" && make` bleibt `cd`) ist gewollt; er verkleinert den Nutzen der Änderung, ohne dass ein Bestand ihn beziffert (Spans tragen die Zeile nicht).
- **`skipped = true` statt `sawAssignment`.** Trägt: (h) und (l) färben rot, der Vorzustand der Wert-Grenze hinter Navigation ist getestet.
- **`||` als argc-Ende.** Sinnvoll (Zeile `make gates || echo x` → 1), bewacht (c); in SPEC-031 nicht in der Operator-Liste (L-1 (4)).

## Geprüft, ohne Befund

- **Reiner Move und Claim:** `5acbc97d` ohne Inhaltsänderung (Similarity 100 %); `9ab93032` (Ruhe-Marker) ist die drei-Zeilen-Löschung des Vorgänger-Claims, byte-gleich.
- **Nachzug-Umfang:** drei Dateien, nur Link-Ziele/Code-Span; nichts in `docs/reviews/`, `docs/plan/adr/`, `.harness/baseline/`.
- **Rollen und Norm-Artefakte (§3.8, §3.10):** der Diff schreibt weder Hard Rules noch Adaptions-Block, keine Sensor-Doku unter `harness/sensors/`, keinen Slice-Inhalt/DoD-Haken (`slice-204` 0 Zeilen Änderung), kein Register, keine Closure-Notiz;
  `internal/emit/` und `internal/span/fieldlist.go` unberührt. Die Commit-Messages nennen die Rolle und Kennungen.
- **Spec-Rang und Rolle:** die zwei Zeilen sind in Liefer-Punkt 3 und §3 dem Lauf zugewiesen; `LH-FA-10` und das Lastenheft treffen keine Aussage über den Inhalt von `program` (`grep` über `spec/lastenheft.md`), SPEC-021 widerspricht dem Lastenheft nicht
  und ist ohne Vertragsänderung fortschreibbar (`MR-019`). Dass `SPEC-021` „das erste Wort des ausgeführten Segments" sagt und `ADR-0011` Festlegung 2 „erstes Token", ist nach Source Precedence zugunsten der Spec entschieden (Rang 2 vor Rang 4).
  Die offene Eigentumsfrage (`slice-151`) trägt der Diff nicht in §7 — das ist Closure und damit Planner-Arbeit; sie geht als Übergabe an den Planner, hier nicht bewertet.
- **Mutations-Fälle 476 bis 478:** Anker `sed -n '/…/p' internal/span/span.go | wc -l` je genau 1 (`isNavigation`-Zeile, `isSegmentEnd(f) || f == "||"`, `case strings.ContainsAny(f, navigationUnsureChars):`); Kopf-Konvention (`# files:`, `# expect:`) wie 404/405; `# verify:` fehlt wie dort
  (`narrow_sensor` wählt `test-go`, der Teillauf zeigt `test-go`); Dateimodus im Index `100644` wie 470 bis 475; `failure_form test-go` = `--- FAIL:` trifft die Test-Namen.
- **§3.7 an Kommentaren, Test-Namen und Spec-Zeilen:** Zustandsform, keine Befund-Kennung, keine verworfene Alternative, Herkunft nirgends erzählt; Test-Namen behaupten, was ihre Tabellen messen (Assignment-Wert-Schutz, Navigations-Grenze, Rand-Zeichen je Zeichen, argc-Grenze) — bis auf die unter M-1/M-2 genannten Zweige.
- **Wert hinter Navigation (`TOKEN=abc`):** `cd /x && TOKEN=abc gh pr create` → `gh`, kein `TOKEN`/`abc` in der Zeile; `cd /x && TOKEN="abc def" gh …` → nichts; `cd /x; TOKEN='abc def' gh …` → nichts; `cd /x && export TOKEN=abc && make` → `export` (argc 1, kein Wert). Die Wert-Grenze der Zuweisungen bleibt unverändert.
- **Gates (Lauf dieses Laufs):** `make docs-check` Exit 0 (`2011 Datei(en) geprüft, 0 Befund(e)`, vor Anlage dieses Reports); `make gates` und der Stempel am Ende des Laufs stehen im Abschlussbericht, nicht hier (ein Report, der sein eigenes Gate-Ergebnis trägt, ändert den gestempelten Baum).

**Gelesen, nicht gefahren:** die Emissions-Vorlagen unter `internal/emit/templates/` (nur Diff-Leere geprüft), `span-report`-Quelltext (nur `grep` auf das Feld), `make lint` einzeln (läuft in `make gates`), Bestands-Spans unter `.harness/state/spans/` (maschinenlokal; eine Häufigkeit von `cd "…" && …`-Zeilen ist nicht gemessen), Tabs und Unicode-Leerraum als Wortgrenze.

## Summary

| Stufe | Anzahl |
|---|---|
| HIGH | 1 (H-1) |
| MEDIUM | 2 (M-1, M-2) |
| LOW | 1 (L-1) |
| INFO | 4 (I-1 bis I-4) |

Wiederkehrende Klassen für die Closure §7: *Grenzen-Aufzählung einer erkennenden Regel ohne Formen-Probe* (H-1, L-1) · *Zusage ohne Gegenbeispiel, das den Zweig unterscheidet* (M-1, M-2) ·
`mutations-fall-nennt-einen-test-die-mutation-faerbt-mehrere` (I-2).
