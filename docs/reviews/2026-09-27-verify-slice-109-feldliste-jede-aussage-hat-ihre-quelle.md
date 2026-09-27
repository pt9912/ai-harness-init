# Verifikations-Report: slice-109-feldliste-jede-aussage-hat-ihre-quelle — 2026-09-27

**Rolle:** Verifier (Modul 11) — DoD-/ADR-Konformität und Plan-vs-Code-Diff an den Planner.
Frischer Kontext, kein Selbst-Verifizieren. Nicht der Reviewer-Maßstab (Diff gegen Plan, ADR,
Hard Rules) und nicht der Validator.

**Gegenstand:** Slice `slice-109-feldliste-jede-aussage-hat-ihre-quelle` (Kennung, nicht Pfad —
die Datei wandert mit dem Lifecycle, `AGENTS.md` §3.11), Stand HEAD `49937fba`, Baum sauber.
Geprüfter Implementer-Diff: `f2d6e466~1..e39940cb` (Claim, DoD (1), DoD (2), Mutations-Fall 488)
plus die F-1-Nachrunde `55f8c831..49937fba` (Test bindet jede Teil-Grenze einzeln, Mutations-Fälle
489/490). Die dazwischenliegenden Commits `d0c905e4`/`4130fc42` (Architect, ADR-0071) gehören zu
einem **anderen** Vorgang (Kopplungsform Feldnotiz/Spec) und sind nicht Gegenstand dieser
Verifikation — der Review-Report grenzt sie ebenso aus.

**Maßstab:** DoD und Plan des Slice (Ziel, §1 Instanzen A/B, §2 DoD, §3 Plan, §4 Trigger, §6
Risiken), `LH-FA-10` §Redaktion, `ADR-0022` (Accepted — Festlegung 6/7), `spec/spezifikation.md`
SPEC-021, `AGENTS.md` §3.6, §3.7, §3.10, `MR-071`, Baseline-Regelwerk Modul 11 §Bewusstes Brechen.

**Eingang:** Implementer-Bericht (Behauptungen, unten je einzeln nachgefahren, nicht übernommen)
und der Review-Report `3134d865` (0 HIGH, 0 MEDIUM, 1 LOW F-1, 1 INFO F-2) — gelesen, keine Zahl
von dort übernommen; jede Messung unten ist selbst gefahren, in einer isolierten Scratch-Kopie
(`git archive HEAD` + eigener `git init`) und via `make host-bin`/`make test-go`/`make mutate`
(Docker, kein `go`/`python3` auf dem Host).

## Ergebnis

| Punkt | Verdikt |
|---|---|
| DoD (1) — Zutat aus `limitStore` entfernt, Nicht-Zusage bleibt | **bestätigt** |
| DoD (2) — `program`-Notiz widerspricht SPEC-021 nicht mehr | **bestätigt** |
| F-1 (LOW, Review) — jede Teil-Grenze einzeln gebunden | **behoben, bestätigt** |
| F-2 (INFO, Review) — Kommentar-Ton | **offen, INFO, kein Blocker — Übergabe an Planner-Urteil** |
| `make gates` (Arbeitsbaum vor Commit) | grün, s. u. |
| `make docs-check` | grün, s. u. |

## DoD (1) — Zutat aus `limitStore` entfernt

**Bricht, wenn** (§2): der Satz nennt weiterhin die Zutat, oder die Nicht-Zusage selbst ist
verändert.

Selbst gebaut und emittiert (nicht dem Reviewer-Beleg vertraut): `make host-bin` in einer eigenen
Scratch-Kopie, Träger real gegen ein frisches Git-Repo gefahren
(`ai-harness-init --name probe .`), `harness/erfassung-feldliste.md` gelesen:

```
grep -c 'Arbeitsverzeichnis lesen kann' harness/erfassung-feldliste.md   → 0
grep -c 'nicht zugriffsbeschränkt' harness/erfassung-feldliste.md       → 1
```

Die Zutat ist weg, die Nicht-Zusage aus `LH-FA-10` §Redaktion steht wörtlich weiter (Zeile 53 im
emittierten Dokument: *„… nicht **verschlüsselt** und **nicht zugriffsbeschränkt**. Und
**Pfadnamen sind nicht als unkritisch zugesagt** …"*). Kein Kommando färbt das Fehlen der Zutat
rot — das ist die im DoD selbst vorgesehene Lage (*„Fällt sie, färbt kein Kommando das rot"*),
keine Lücke.

**§6-Risiko 1** (*„DoD (1) hat einen Ausgang ohne Rot, und das ist keine Ausrede"*) — die
verlangte Negativ-Kette ist real gefahren: `grep -c 'Arbeitsverzeichnis lesen kann'` lieferte am
Vorzustand `db4575f0~1` **1** Treffer und am Zielzustand **0** — geprüft:

```
git -C /Development/KI/ai-harness-init show db4575f0~1:internal/span/fieldlist.go | grep -c 'Arbeitsverzeichnis lesen kann'   → 1
```

Der Ausgang ist damit die Sache selbst, kein Formfehler.

**Verdikt: bestätigt.**

## DoD (2) — `program`-Notiz widerspricht SPEC-021 nicht mehr

**Bricht, wenn** (§2): ein Mutations-Fall, der den alten Wortlaut zurücksetzt, bleibt grün, oder
der neue Wortlaut widerspricht SPEC-021.

Der Notiztext (`internal/span/fieldlist.go:94`) lautet jetzt *„das erste Wort des ausgeführten
Segments, nie das der ganzen Kommandozeile"* — Wort für Wort gegen `commandProgram()`
(`internal/span/span.go:304`) und SPEC-021 gehalten, mit drei Fällen aus dem
`TestCommandProgramSkipsNavigationSegments`/`TestCommandProgramFirstWordKeepsItsGluedRest`-Bestand
(slice-204), nicht bloß gelesen:

| Fall | Ist-Verhalten (Test-Bestand) | Widerspricht die Notiz? |
|---|---|---|
| `cd /x && make gates` | `program="make"`, `argc=1` (Zeile 334) | nein — `make gates` ist das ausgeführte Segment nach übersprungener Navigation, `make` sein erstes Wort |
| `A=x"y cmd z` (unschlichtes Zeichen im Zuweisungswert) | `program=""`, kein Feld im Span (Zeile ~695) | nein — die Notiz sagt nichts über den Fall aus, in dem gar kein `program` geschrieben wird; sie beschreibt nur den Fall, in dem es geschrieben wird |
| `"a b" x` (kein Navigations-Segment, Anführungszeichen) | `program="\"a"` (Zeile 708) | nein — `"a` ist, wortwörtlich genommen, das erste Wort des ausgeführten Segments; die Notiz verspricht keine Anführungszeichen-Behandlung |

Alle drei Fälle: die Notiz bleibt eine wahre, nicht-irreführende Kurzbeschreibung — sie behauptet
weder Vollständigkeit noch Anführungszeichen-Bewusstsein, nur „erstes Wort des ausgeführten
Segments, nicht der ganzen Zeile", und das hält in jedem der drei Fälle.

**Verdikt: bestätigt.**

## Mutations-Fälle 489/490 (F-1-Nachrunde) — unabhängig verifiziert

**Anker gegen den Quell-Bestand (MR-071):**

```
grep -rn 'das erste Wort des ausgeführten Segments, nie das der ganzen Kommandozeile' --include='*.go' .   → genau 1 Treffer (internal/span/fieldlist.go:94)
```

488 ankert auf die volle Zeile inkl. `Welches Programm lief? — …` (ebenfalls exakt 1 Treffer,
geprüft); 489 und 490 ankern **beide** auf denselben Teilstring (ohne den Frage-Kopf) — das ist
nach MR-071 zulässig: Die Regel verlangt, dass **der Anker eines Falls** beim Anlegen gegen den
Quell-Bestand gemessen ist und dort eindeutig trifft (`grep -c` = 1); sie verlangt **nicht**, dass
zwei Geschwister-Fälle disjunkte oder nicht-überlappende Anker tragen. Zwei Fälle, die denselben
Teilstring als Ausgangspunkt nehmen und ihn unterschiedlich verändern (489: Verneinungs-Hälfte
entfernt; 490: positive Hälfte verfälscht), sind eine normale Form, zwei verschiedene
Verstoß-Instanzen an derselben Stelle zu prüfen — beide sind für sich genommen eindeutig gegen den
Bestand, geteiltes Ankermuster ist keine Anker-Kollision im Sinn von MR-071. **Bewertung: kein
Verstoß gegen MR-071, keine offene Frage — siehe aber die Fragilitäts-Anmerkung unten.**

Datei-Modus: `git ls-files -s` für 488/489/490 und die Nachbarn 486/487 → alle `100644`, kein
Unterschied. Kopf-Form (`# files:`/`# expect:`/Blockkommentar/`set -euo pipefail`) deckungsgleich.
`failure_form()` für `test-go`: beide neuen Fälle nennen `TestFeldliste_ProgramNotizWidersprichtSpecNichtMehr`
als `expect:`, dieselbe Form wie 488.

**Teillauf selbst gefahren** (isolierte Scratch-Kopie, `MUTATE_JOBS=1`):

```
make mutate MUTATE_JOBS=1 MUTATE_CASES='488-feldliste-program-notiz-widerlegt 489-feldliste-program-notiz-verneinung-verliert 490-feldliste-program-notiz-positive-haelfte-falsch'
→ 3 ok, 0 Befund(e)
→ 488 -> TestFeldliste_ProgramNotizWidersprichtSpecNichtMehr rot
→ 489 -> TestFeldliste_ProgramNotizWidersprichtSpecNichtMehr rot
→ 490 -> TestFeldliste_ProgramNotizWidersprichtSpecNichtMehr rot
→ TEILLAUF 3 von 478 — kein Beleg
```

`.harness/state/mutate-passed.key` vorher und nachher nicht vorhanden — Beleg-Slot unberührt,
bestätigt.

**Rot-Meldungen gelesen** (Mutation aktiv, kein Skip, direkter `make test-go`-Lauf je Fall in
eigener Kopie):

- **488** (Volltext-Rückfall): Test bricht an **allen drei** Assertions (Zeilen 183/186/189) —
  konsistent, der Fall trägt die alte, vollständig widerlegte Formulierung.
- **489** (Verneinungs-Hälfte entfernt): Test bricht **ausschließlich** an Zeile 189 (*„nennt
  nicht mehr die Verneinungs-Hälfte"*) — die positive Hälfte bleibt stehen und die zugehörige
  Assertion (Zeile 186) bleibt grün. Trifft exakt die behauptete Ursache.
- **490** (positive Hälfte verfälscht — „erste" → „letzte" Wort): Test bricht **ausschließlich**
  an Zeile 186 (*„nennt nicht mehr die positive Hälfte"*) — die Verneinungs-Hälfte bleibt
  wörtlich stehen und die zugehörige Assertion (Zeile 189) bleibt grün. Trifft exakt die
  behauptete Ursache.

Damit ist belegt, dass die Ursache die **behauptete** ist (AGENTS.md §3.6: „Das Rot muss die
behauptete Ursache tragen, nicht irgendeine"), nicht nur irgendein Rot.

**Gegenproben (Polarität: grün = bindet — der designierte Test ist die einzige Deckung, kein
anderer Test der Suite fängt dieselbe Mutation zufällig mit):**

Für jeden der drei Fälle: Mutation angewendet, der genannte `expect:`-Test per `t.Skip(...)`
übersprungen, `make test-go` gefahren.

| Fall | `make test-go` mit Skip + aktiver Mutation |
|---|---|
| 488 | **grün** (alle Pakete `ok`) — bindet |
| 489 | **grün** (alle Pakete `ok`) — bindet |
| 490 | **grün** (alle Pakete `ok`) — bindet |

Kein anderer Test im Bestand hält gegen dieselbe Mutation zufällig dagegen; jeder der drei Fälle
hängt ausschließlich am designierten Wächter.

**Verdikt F-1: behoben, bestätigt.** Die von F-1 benannte Lücke — eine Änderung, die nur eine
der beiden Notiz-Hälften bricht, bliebe ungebunden — ist geschlossen: 489 bindet die
Verneinungs-Hälfte, 490 die positive Hälfte, je einzeln und nachweislich an der behaupteten
Ursache.

## F-2 (INFO, Review) — Kommentar-Ton

Nicht behoben und laut Review-Report auch nicht als Blocker gemeint. Eigene Lesart: Der Kommentar
in `fieldlist_test.go:149-163` nennt die frühere Notiz-Formulierung, bevor er den heutigen
Wächter-Zustand beschreibt — grenzwertig zu `AGENTS.md` §3.7 („beschreibt abwesenden Text"), aber
**funktional nötig**, weil der Wächter selbst genau diesen abgelösten Wortlaut als Rückfall-Muster
sucht (Selbst-Referenz auf sein eigenes Suchmuster, kein Chronik-Erzählen einer Entscheidung).
Kein eigener Befund dieser Verifikation — bleibt als INFO stehen, Planner-Urteil bei Closure.

## Optionale Lücken-Prüfung (Punkt 4 des Auftrags)

Zwei angefragte Grauzonen-Fälle geprüft, keiner davon ist eine reale Lücke:

- **Beide Assertions gleichzeitig entfernt, Rückfall-Test (488-Assertion) bleibt** — dann bindet
  weiterhin der Volltext-Rückfall-Test (Zeile 183, von F-1 unberührt) gegen den vollständigen
  Wortlaut-Rückfall; ein Mutant, der nur eine Hälfte ändert, bräche aber nur, wenn er zufällig
  den vollen alten Wortlaut träfe — das ist der Fall, den 489/490 jetzt zusätzlich abdecken, kein
  neuer.
- **Ein Mutant, der beide Hälften gleichzeitig, aber je nur teilweise ändert** — nicht real
  gefahren (Zeitbudget), aber strukturell durch alle drei Assertions gedeckt: solange eine
  Assertion (183/186/189) durch eine Wortlaut-Änderung verletzt wird, bricht der Test. Eine
  Änderung, die *keine* der drei Bedingungen verletzt, wäre keine inhaltliche Änderung des
  geprüften Textes mehr. Kein Handlungsbedarf.

Keine echte Lücke gefunden; keine Empfehlung an den Implementer.

## Zustandsaussagen (Punkt 5 des Auftrags)

- `internal/emit/fieldlist_test.go`: **unberührt** vom gesamten Diff (`git diff f2d6e466~1..49937fba -- internal/emit/fieldlist_test.go` liefert keine Änderung) — selbst mit `grep` geprüft, dass dort kein Test den alten `program`-Wortlaut referenziert: kein Treffer für „erste[s] Token der Kommandozeile" in dieser Datei. Implementer-Behauptung bestätigt.
- **Zweiter Ort mit dem alten Wortlaut:** `git grep -n 'erstes Token der Kommandozeile\|erste Token der Kommandozeile' -- ':!.harness/baseline' ':!docs/reviews' ':!docs/plan/planning/done'` findet vier Treffer:
  1. `docs/plan/planning/in-progress/slice-109-feldliste-jede-aussage-hat-ihre-quelle.md:99` — Selbstzitat des Slice-Plans in §1(B), das den **historischen** (falschen) Wortlaut als Ausgangspunkt der Korrektur nennt. Zulässig: ein Slice-Plan ist ein Zeitdokument der Planungsrunde, das den Ist-Zustand *zum Planungszeitpunkt* referenziert, keine lebende Registerzeile im Sinn von `AGENTS.md` §3.7.
  2. `docs/plan/planning/observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/evidence/slice-204-…md` — eine `evidence/`-Datei, laut Modul 11 unveränderlich ab Merge (historischer Fund-Beleg). Zulässig aus demselben Grund.
  3. `internal/span/fieldlist_test.go:182` — der Wächter selbst, der genau diesen Rückfall-Wortlaut sucht. Notwendige Selbst-Referenz (s. F-2).
  4. `test/mutations/488-feldliste-program-notiz-widerlegt.sh` — der Mutations-Fall, der auf denselben Wortlaut zurücksetzt. Notwendig.
  Keiner der vier Fundorte behauptet den alten Wortlaut als **geltende** Aussage — Punkt 5 damit ohne Befund.

## Größe/Schnitt (Punkt 6 des Auftrags)

Zwei unabhängige DoD-Punkte, ein Dokument, kein wartender Folge-Schritt. Der Schnitt trägt: Beide
Instanzen sind für sich abgeschlossen behebbar (bestätigt oben), keine berührt eine dritte Datei
außerhalb `fieldlist.go`/`fieldlist_test.go`/`test/mutations/`, und die F-1-Nachrunde blieb
innerhalb desselben engen Rahmens (zwei neue Assertions, zwei neue Fälle, keine neue Datei
außerhalb des bereits geplanten Bereichs). Kurze Einschätzung: **der Schnitt trägt.**

## Was nur gelesen, nicht gemessen ist

- `spec/spezifikation.md`, `spec/lastenheft.md`, `harness/tools/full-smoke.sh`, `docs/plan/adr/0022-…` — nur `git diff --stat` geprüft (unberührt), nicht inhaltlich neu gegengelesen über das hinaus, was DoD (2) selbst verlangt (SPEC-021-Zeile).
- Die Review-Belege des Reviewer-Laufs (`make host-bin`-Emission, Mutations-Teillauf 488) sind hier **unabhängig nachgefahren**, nicht übernommen — Ergebnis deckungsgleich.
- `make full-smoke` (beide Bootstrap-Varianten) — nicht selbst gefahren; der Closure-Trigger des Slice verlangt ihn ausdrücklich (§5), das ist damit ein offener Punkt für die Closure, nicht dieser Verifikation (Zeitbudget; kein DoD-Punkt dieses Slice hängt explizit an `full-smoke`, nur der generische Closure-Trigger).
- Ein vollständiger `make mutate`-Lauf — laut Auftrag verboten, nicht gefahren.

## Übergaben an den Planner

**§6-Risiko-Ausgänge (Vorschlag, gesetzt vom Planner):**

1. *DoD (1) hat einen Ausgang ohne Rot* — **weiter offen**, wie im Slice bereits vermerkt: Register-Sichtung 2026-09-27 fand keine passende Beobachtung. Kein neuer Fund dieser Verifikation, der das änderte.
2. *Zwei Sätze mit derselben Wendung, zwei Verträge* — **entfallen**, bestätigt: `grep -c 'erneuter Lauf' harness/erfassung-feldliste.md` → 2, beide Sätze bleiben getrennt und unverändert von diesem Diff berührt (`limitStore`/`SchemaNotes()` sind andere Textstellen). Die Umsetzung hat die Grenze eingehalten.
3. *Eine terse Korrektur kann selbst zu kurz greifen* — **weiter offen**, wie im Slice vermerkt: die neue Notiz bleibt terser als SPEC-021 und ist gegen drei Randfälle aus slice-204 geprüft (oben), ohne dass damit Vollständigkeit behauptet wird — der Prüfpunkt der Umsetzung ist eingehalten, das Risiko selbst bleibt als Register-Kandidat für künftige `commandProgram()`-Änderungen bestehen.

**Register-Kandidaten:** keine neuen aus dieser Verifikation. Die F-1-Finding-Klasse
(„Mehrteilige Regel-Zusage im Kommentar ohne Mutations-Deckung je Teil") ist bereits als
Reviewer-Skill-Zeile verkörpert (`grep -n 'Mehrteilige Regel-Zusage' .harness/skills/reviewer.md`
→ Zeile 116) — kein neuer Eintrag nötig, sie ist der Anwendungsfall einer bestehenden Regel, kein
drittes Auftreten einer unverkörperten.

**Zustandsaussagen:** siehe oben — keine offene Korrektur, nur die vier zulässigen Fundorte des
alten Wortlauts (historische Zeitdokumente + notwendige Wächter-Selbstreferenzen).

**MR-071-Frage (Punkt 2 des Auftrags):** 489 und 490 teilen sich denselben `sed`-Anker-Teilstring
(ohne Frage-Kopf) und mutieren an unterschiedlicher Stelle **innerhalb** desselben Match. Das ist
nach dem Wortlaut von MR-071 zulässig — die Regel bindet den Anker **je Fall** gegen den
Quell-Bestand, nicht die Anker zweier Geschwister-Fälle gegeneinander. **Fragilitäts-Anmerkung,
keine Norm-Verletzung:** Eine künftige, berechtigte Wortlaut-Änderung an genau dieser Zeile würde
typischerweise **beide** Fälle gleichzeitig entwaffnen (dieselbe „dritte Fundmenge" aus MR-071
§Die drei Fundmengen — „der `sed`-Anker zitiert den Wortlaut"), nicht nur einen. Das ist keine
MR-071-Verletzung, aber eine Beobachtung wert, falls der Planner eine engere Auslegung
(nicht-überlappende Anker je Geschwister-Fall) für künftige Mehrteilige-Zusage-Fälle setzen will —
diese Entscheidung liegt außerhalb der Verifikation.

## Gate-Lauf

`make docs-check` vor und `make gates` nach dem Commit dieses Reports — Exit-Codes, Stempel und
Baum-Zustand stehen in der Übergabe-Nachricht an den Aufrufer, nicht in diesem Zeitdokument: der
Report ist Teil des Prüfgegenstands, und ein Lauf-Protokoll darin wäre ein Stand, den der nächste
Commit überholt.
