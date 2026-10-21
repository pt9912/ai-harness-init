# Verifier-Report: slice-extraktor-meldet-parse-zweifel-bei-zwei-strings-und-resttext

Rolle Verifier, Stand HEAD `91833454` (Basis `0181e351`). Bezug: LH-FA-06 (Guard, fail-closed bei Parse-Zweifel), LH-QA-03, ADR-0004 Festlegung 2. Der Mutations-Lauf ging lokal (7 Faelle unter der Schwelle), kein CI-Branch.

## Verdikte je DoD-Punkt

- **Extraktor: bestaetigt.**
  - Kommando: die Dateien beider Staende unter `.harness/state/probe/` (danach entfernt), `awk -f` im BATS_IMAGE (Pin `bats/bats@sha256:e8f18e0a…` aus dem Makefile, `--network none`, busybox-awk).
  - Vorher-Stand (`0181e351`, beide Fassungen): `{"tool_input":{"command":"pip x""make gates"}}` gibt Ausgabe `make gates`, Exit 0. `{"tool_input":{"command":"a" garbage }}` gibt `a`, Exit 0. Die Ausgabe `make gates` zeigt das Fail-open: der Guard haette `pip x` nie gesehen.
  - HEAD (Fassung dieses Repos und Vorlage): beide Eingaben geben Exit 3 und leere Ausgabe. Zusaetzlich gemessen: `"a" "b"` (Leerzeichen dazwischen) und `"a"x` geben Exit 3.
  - Regressionsproben (10 eigene Eingaben), je beide Fassungen: Exit 0 mit dem richtigen Text.

    | Probe | Ergebnis |
    |---|---|
    | Folgefelder `description`/`timeout` | `ls -la` |
    | Escapes `\"`, `\\`, `\n`, command nicht erster Key | `echo "hi" \ done⏎next` |
    | Unicode (`äöü 日本`) | unveraendert |
    | verschachtelte Objekte und Arrays, Folgefeld | `x` |
    | CRLF und Leerraum um `:` und `,` | `ls` |
    | `\t` und `/` | `a/b⇥c` |
    | Leerraum um Klammern | `q` |
    | Literale `null`, `true`, Zahl `-1.5e3`, verschachteltes Array | `ls` |
    | Array vor `tool_input` | `keep` |
    | `\"a\"\"b\"` im Wert (escapte Quotes) | `say "a""b"` |

    Die Vorher-Fassungen geben dieselben Ausgaben, es gibt keine Regression.
  - Rot-Beleg (korrektheitskritisch): der Vorher-Stand ist der reale Rot-Zustand, die Eingaben geben dort Exit 0. Die Mutationsfaelle 780 bis 783 brechen die Ursache einzeln (siehe Punkt Probenmenge). Der benannte Test faerbt mit der behaupteten Ursache.
- **Code-Gleichheit: bestaetigt.** `diff <(grep -v '^[[:space:]]*#' harness/tools/extract-command.awk) <(grep -v '^[[:space:]]*#' internal/emit/templates/enforce/extract-command.awk)` ist leer. Das ist eine Einmalmessung, kein Sensor (so im Plan benannt).
- **Probenmenge: bestaetigt, mit Grenze.**
  - `make test-bats BATS_TARGET=test/guard.bats` gibt `1..32`, alle ok. Neu sind 8 bis 11: zwei Strings, Resttext, Regression und der Guard-Fall `block`. Die Faelle 1 bis 7 und 28 bis 32 sind unveraendert gruen.
  - Die Schleife laeuft ueber `$EXTRACT` und `$EMIT_EXTRACT`. Der Vorlagen-Pfad ist die reale Quelle der emittierten Fassung (go:embed).
  - `make mutate` mit `MUTATE_CASES='780 781 782 783'`, `MUTATE_JOBS=1`: 4 ok, 0 Befund(e), je rot gegen den `expect`-Test (Teillauf, kein Beleg-Slot).
    - 780 und 781 (Zeile `if (c != ":" …) exit 3` geloescht, lokal und Vorlage): rot, Test 8 und 9.
    - 782 und 783 (`afterstr = 0` geloescht): rot, die Regressionsprobe (Test 10), Meldung `<pfad>: rc=3`.
  - `make mutate-greift`: `769 Fall/Faelle, 769 greifen, 0 Befund(e)`.
  - Anker gegen den Quell-Bestand gemessen (`grep -cF`): die `exit 3`-Zeile kommt je Datei genau 1-mal vor. `^      afterstr = 0$` kommt je Datei genau 1-mal vor, die Initialisierung traegt dahinter einen Kommentar.
  - Grenze (Plan-konform): der Guard-Fall prueft nur den Guard dieses Repos. Der emittierte Guard hat im Repo keinen Extraktor am erwarteten Pfad. Fuer die emittierte Fassung traegt allein der Vorlagen-Extraktor ueber Fall 781, 783 und die Schleife.
- **Nachzug: bestaetigt.**
  - Beide Guard-Koepfe nennen die zwei Klassen.
  - Beide Extraktor-Koepfe nennen sie ebenfalls (Zeilen 4 bis 6).
  - Der Vorlagen-Guard-Kopf sagt: *„die Guard-Entscheidung auf eine solche Eingabe ist am emittierten Guard nicht gemessen"*. Das deckt sich mit dem Befund oben.
  - `git grep extract-command docs/user` gibt nur `benutzerhandbuch.md:578` (Baumzeile) und keine Aufzaehlung der Klassen. Kein Nachzug noetig.
- **`make gates`: bestaetigt.** Lauf auf HEAD `91833454`, Ausgang gruen (letzte Zeile `span-check: …`), `.harness/state/gates-passed.head` = `91833454b19bd51f301524da3d9f1163cc371a41` = HEAD. Das Stempel-Ergebnis nach dem Report-Commit steht im Abschluss des Laufs, nicht hier.
- **Review, Closure-Notiz, Register, Risiko-Ausgaenge, Paarungen: nicht Gegenstand der Verifikation.** Der Review-Report liegt vor (0 HIGH/MEDIUM). Die Haken setzt der Planner.

## Plan-vs-Code (beide Richtungen)

- Plan → Code: alle vier §3-Zeilen sind im Diff (Extraktor x2, `guard.bats`, Faelle, Guard-Koepfe). Die Out-of-Scope-Punkte bleiben unberuehrt, `git diff 0181e351..HEAD --stat` zeigt nur: beide Extraktoren, beide Guard-Skripte, `test/guard.bats`, die Faelle 780 bis 783 und die Plan-Datei. AGENTS.md, conventions, ADRs und Register sind nicht beruehrt. Resttext hinter dem Wurzelobjekt, `\u`-Pruefung, Interpreter-Sperre, Sub-Shell, Exit-Riegel und PATH sind unveraendert.
- Code → Plan (Gebautes ohne Plan): die Faelle 782 und 783 (Falsch-Positiv-Richtung, `afterstr`-Reset) stehen nicht im Plan §3. Sie stammen aus Review-Befund F3. Sie sind ein Mehr an Zaehnen, keine Scope-Ausweitung. Der Plan sagt „zwei Faelle", gebaut sind vier. Die Plan-Aussage ist damit unvollstaendig, der Planner soll sie bei der Closure nachfuehren. Ebenso F1 (Grenze am Ort, Guard-Fall-Kommentar und Vorlagen-Kopf): Das war im Plan als Nachzug nur allgemein angelegt.
- Falsch-Positiv-Risiko aus Plan §6: durch Test 10 und die Faelle 782/783 mechanisch gehalten, durch meine 10 Proben bestaetigt.

## Findings

Keine HIGH/MEDIUM. Zwei Hinweise, kein Blocker:

- INFO: der Extraktor-Kopf behauptet weiterhin „POSIX-awk (busybox/gawk/BSD)". Gemessen sind busybox 1.36.1 (BATS_IMAGE) und BWK 20200816 (Host, kein Normbeleg). gawk und mawk sind ungemessen. Die Aussage stammt aus dem Bestand und ist im Plan §6 als offen benannt (Register `BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht`). Nicht neu in diesem Slice.
- INFO (Grenze, nicht Mangel): Es gibt keinen Lauf-Zahn im Ziel. `full-smoke` hat keine Stufe, die einen realen emittierten Guard mit Parse-Zweifel-Eingabe faehrt. Die emittierte Zusage ist nur ueber den Vorlagen-Extraktor gedeckt, und der Vorlagen-Guard-Kopf nennt diese Grenze am Ort. Die beiden Fassungen haengen nur an der Einmalmessung der Code-Zeilen. Ein Sensor dafuer ist per Plan der Folge-Slice `slice-zwei-fassungen-eines-waechters-bekommen-ihren-vergleichenden-sensor`.

## Offene Punkte fuer Planner

- Beleg-Ort fuer die Wirkung im frischen Klon: die CI nach dem Push. Ich habe sie nicht gelesen.
- §7 soll die Faelle 782/783 und F1 nennen, und das Register soll fuer „neuer Waechter ohne Mutationsfall" oder „Waechter-Satz ohne Fall" einen Beleg tragen, falls der Planner das so urteilt.
- macOS-Laeufe sind unter §3.9 kein Normbeleg. Normbeleg sind die containerisierten Messungen dieses Reports.
