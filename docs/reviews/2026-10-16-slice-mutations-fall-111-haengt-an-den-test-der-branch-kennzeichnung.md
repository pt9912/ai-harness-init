# Review: slice-mutations-fall-111-haengt-an-den-test-der-branch-kennzeichnung

**Range:** Implementer `bc86f4ed` (`test/mutations/111-span-korrelationsfeld-verschwindet.sh`) und `9f9985bd` (`spec/spezifikation.md`) · **Plan:** `slice-mutations-fall-111-haengt-an-den-test-der-branch-kennzeichnung` (§1 Architect-Entscheidung, §3, §4) · **Bezug:** LH-FA-15, LH-FA-13, SPEC-061, SPEC-014, SPEC-087, MR-071, MR-075, AGENTS.md §3.3/§3.6/§3.7/§3.8/§3.10 · Reviewer-Skill (Stand HEAD). Nicht geprüft: DoD (Verifier).

**Summary:** 0 HIGH · 0 MEDIUM · 1 LOW · 2 INFO — annahmefähig; Ergebnis zu (b): kein Fehler im Fall 111, der beobachtete Ausfall liegt im Treiber/Docker-Raum (INFO-2).

## Findings

### LOW-1 — Fall-Kopf nennt als Zahn den „Satz der Feldliste“; rot färbt die Pflichtfeld-Prüfung gegen den Träger

- `kategorie`: LOW
- `quelle`: AGENTS.md §3.6 (das Rot muss die behauptete Ursache tragen), §3.7
- `pfad`: `test/mutations/111-span-korrelationsfeld-verschwindet.sh:6-8`; `internal/span/fieldlist_test.go:267-270`
- `befund`: Der Kopf sagt, „den Zahn traegt der Satz der Feldliste, der `branch` als Feld mit Kennzeichnung nennt“. Unter der Mutation fällt der Test aber an der Schleife über `span.SchemaFields()` (`Required` von `branch` ist durch `omitempty` false): Meldung „die Feldliste nennt \"branch\" als Feld mit Kennzeichnung, der Traeger fuehrt es nicht als Pflichtfeld“. Der Satz bleibt unverändert; gebunden ist die Deklaration des Trägers (`json`-Tag), nicht die Wortlaut-Hälfte.
- `verifizierbar`: ja (Kopie, Mutation angewandt, `make test-go`: genau diese Zeile 269)
- `klasse`: Fall-Kopf nennt die Ursache ungenau

### INFO-1 — Die Mutation ändert kein Draht-Verhalten, nur die Pflicht-Deklaration

- `kategorie`: INFO
- `quelle`: AGENTS.md §3.6
- `pfad`: `internal/span/emit.go:481-490` (`gitRef`), `test/mutations/111-…sh:6-9`
- `befund`: `gitRef()` liefert nie `""`, `omitempty` lässt `branch` darum nie aus der Zeile fallen; der Fall bindet die Deklaration „Pflichtfeld“ (Schema), nicht ein Verschwinden auf dem Draht. Der Kopf sagt das (`kann den Wert also nicht mehr verschwinden lassen`); die Aussage ist wahr, die Reichweite des Zahns ist damit enger als der Fall-Name `…verschwindet`. Zuständig für eine Umbenennung: Planner/Architect, kein Mangel dieses Diffs.
- `verifizierbar`: nein
- `klasse`: Fall-Name weiter als sein Zahn

### INFO-2 — (b) Fünfer-Lauf: Worker-Ausfälle sind Treiber/Docker-Last, nicht Fall 111

- `kategorie`: INFO
- `quelle`: `harness/sensors/mutate.md`; Slices `slice-roter-gruen-vorlauf-des-mutate-treibers-zeigt-sein-log`, `slice-span-sperre-haelt-den-test-unter-last` (beide §1 benannt)
- `pfad`: `harness/tools/mutate.sh` (Grün-Vorlauf je Worker)
- `befund`: `MUTATE_CASES='111 501 502 608 609' make mutate` viermal gefahren (die ersten drei gegen einen parallel laufenden Lauf des Verifiers, der den Lock hielt; ich wartete ihn ab): in **jedem** der vier Läufe starb mindestens ein Worker am roten Grün-Vorlauf der Kopie ohne Mutation; Anteile 3 von 5 ok, nie ein Fall mit „rot, aber … fällt nicht — falscher Grund“. Fall 111 meldete, wenn er lief (Lauf 1 und 3 und der Einzellauf), jedes Mal `ok … -> TestFeldliste_KennzeichnungNenntGenauDieFaelleDerSpezifikation rot`. In Lauf 4 ist der Grund im Log gelesen: `docker: Error response from daemon: No such image: sha256:195ad…` (`make[1]: *** [test-go] Error 125`) — mehrere Worker bauen dasselbe Tag `ai-harness-init:test`, ein Worker verliert das Image eines anderen; kein Test fällt. Die Gründe der Läufe 1-3 sind nicht gelesen (Ausgabe gefiltert). Ein einzelner „falscher Grund“ bleibt damit nicht reproduziert und nicht widerlegt; die Mutation in der Kopie färbt deterministisch allein den benannten Test (Schwerpunkt a).
- `verifizierbar`: ja (Kommando oben)
- `klasse`: Worker-Grün-Vorlauf scheitert unter paralleler Docker-Last

## Schwerpunkte, Negativbefund

- **(a) Eigenschaft statt Implementierung:** gefahren, außer LOW-1/INFO-1 ohne Befund. `MUTATE_CASES=111-… make mutate` → `1 ok, 0 Befund(e)`, Meldung gelesen. In einer Kopie unter `~/.colima-tmp` (nach Gebrauch entfernt) die Mutation angewandt, `make test-go`: **nur** `TestFeldliste_KennzeichnungNenntGenauDieFaelleDerSpezifikation` rot, alle anderen Pakete `ok` (u. a. `TestMandatoryFieldsAlwaysPresent`). Gegenprobe: `t.Skip` ausschließlich in diesem Test, Mutation weiter angewandt → Suite grün; der benannte Test bindet allein, der Kopf behauptet keine Exklusivität. Der Anker `json:"branch"` trifft die eine Stelle in `emit.go`.
- **(c) Spec-Nachzug:** geprüft, ohne Befund. `SPEC-061` nennt `tool_use_id` und `tool`, passend zu den Fällen 110 und 130 in der Bindung; kein weiterer Verweis auf 111 im Baum außer `SPEC-014` (`grep` über `spec internal harness docs/user test`). `SPEC-014`: `gitRef()` setzt `NotKnown(SourceGitHead)` für `branch` und `commit`, die Spalte nennt den Test der Feldliste mit „(Fall 111)“ und 598, 599. `SPEC-087` führt die Tabelle `ID | Festlegung | Präzisiert` ohne Bindungs-Spalte: die Abweichung vom Auftrag („SPEC-087“) ist durch die Form der Tabelle und durch die Planer-Formulierung „bzw. `SPEC-014`“ gedeckt, `SPEC-087` nennt `branch`/`commit` selbst abschließend. Historienzeile 2026-10-16 trägt Datum und Zustand, `MR-075` (Präzisiert-Spalte) unberührt (Spalten und Zellen der Zeile unverändert). §3.7: der Fall-Kopf beschreibt die geltende Eigenschaft im Indikativ, keine Befund-Kennung, keine verworfene Alternative.
- **(d) Commit-Zuschnitt:** geprüft, ohne Befund. `bc86f4ed` berührt nur die Fall-Datei, `9f9985bd` nur `spec/spezifikation.md`; kein Move (§3.3), keine Hard Rule und kein MR-Eintrag (§3.8), Slice-Datei unverändert, DoD-Häkchen und §7 leer (§3.10); beide Messages tragen Rolle und Kennungen.
- **Sensoren:** `make mutate-greift` → `653 Fall/Faelle, 653 greifen, 0 Befund(e)`; `make gates` Exit 0 (Ende bei `span-check`); `git status` nach den Läufen sauber, keine Bruchprobe im Baum.
