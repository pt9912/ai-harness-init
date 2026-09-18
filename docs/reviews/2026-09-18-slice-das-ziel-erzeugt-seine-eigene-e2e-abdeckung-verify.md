# Verifikations-Report: `slice-das-ziel-erzeugt-seine-eigene-e2e-abdeckung` — 2026-09-18

**Rolle:** Verifier (Modul 11). **Die Frage ist „Bauen wir es richtig?"** — gegen **DoD,
Spec und Plan**. Nicht die des Reviewers (Diff gegen Plan, ADR und Hard Rules) und nicht
die des Validators (realer Bedarf).

**Eingang:** DoD-Bestätigung des Implementers plus seine Sensor-Belege. Der Implementer
**behauptet**, dieser Lauf **bestätigt** — oder eben nicht. Die Review-Reports der vier
Runden sind **nicht** Grundlage dieses Laufs; sie sind Lauf-Belege einer anderen Rolle
mit einem anderen Prüf-Artefakt.

**Gegenstand:** die acht Umsetzungs-Commits `c7b5e90b`, `6d1f4b9a`, `0048110e`,
`4d2db9de`, `fc611ea3`, `321210de`, `93dc8bec`, `ac814e63` gegen die geltende Fassung des
Slice-Plans (nachgezogen in `76552faa` und `fcb98336`) und gegen `LH-FA-12`.

**Kontext:** frischer Kontext, kein Selbst-Verifizieren — dieser Lauf hat den Code nicht
geschrieben. **Modell:** claude-opus-5 · **Datum:** 2026-09-18 · **Baseline:** `v6.9.0`,
`regelwerk/modul-11-verification.md`.

> **Zitier-Form** *(Norm, kein Ausfüll-Hinweis)*. Dieser Report friert ein; was er
> zitiert, bewegt sich weiter. Deshalb **Kennung, nicht Adresse** — `slice-<Kennung>`
> statt seines Lifecycle-Pfads, `make <target>` statt eines Links auf die Sensor-Datei,
> `LH-*`/`ADR-*`/`MR-*` als Inline-Code. Ortsfeste Ablagen (`test/mutations/`,
> `docs/plan/planning/observations/`) stehen als Pfad, weil der Prozess sie nicht bewegt
> (`AGENTS.md` §3.11).

---

## 1. Was dieser Lauf selbst gefahren hat

Keine Zahl und kein Verdikt unten stammt aus einem fremden Bericht. Alle Läufe über dem
gepushten Stand `ac814e63`, Arbeitsbaum sauber.

| Lauf | Ergebnis |
|---|---|
| `make gates` | **Exit 0** |
| `make full-smoke` | **Exit 0**; die neue Stufe 18 meldet `full-smoke: OK — E2E-ABDECKUNG IM ZIEL` |
| Bootstrap **sprachlos** im Scratchpad, dann `make e2e-abdeckung` | Exit 0, Sicht entsteht, **1 Stufe / 1 Deklaration / 1 ohne Kennung** |
| Bootstrap **`--lang go`** im Scratchpad, dann `make e2e-abdeckung` | Exit 0, Byte-gleiche Sicht (`md5` identisch zur sprachlosen) |
| zweiter Lauf, beide Ziele | `e2e-abdeckung: unveraendert — docs/user/e2e-abdeckung.md`, `md5` unverändert |
| Verweise in der emittierten Sicht | **0** (`grep -c '](' docs/user/e2e-abdeckung.md`) |
| `make docs-check` des sprachlosen Ziels | **Exit 0** — `d-check: 21 Datei(en) geprüft, 0 Befund(e)` |
| Marker `E2E_ABDECKUNG_ZIEL` | lenkt: `docs/user/anderswo.md` **entsteht** |
| Marker `E2E_ABDECKUNG_QUELLE` + `E2E_ABDECKUNG_PRAEFIX` | lenken: Sicht über `tools/harness/mein-e2e.sh` mit dem Wort `meinE2E` |
| Marker `E2E_ABDECKUNG_SPEC` auf einen Pfad, den das Ziel nicht führt | Hinweis **im Lauf** *und* im **Kopf** der geschriebenen Sicht (`**diese Datei liegt in diesem Repo derzeit nicht**`) |
| Lücken-Richtung (a) Stufe ohne Deklaration, im Ziel | Exit ≠ 0, `FEHLER — Stufe ohne Deklaration`, mit Stufe, Region und `Nachweis:`-Kommando |
| Lücken-Richtung (b) Quell-Skript ohne Stufen-Kopfzeile, im Ziel | Exit ≠ 0, `FEHLER — … fuehrt keine Stufen-Kopfzeile`, mit der erwarteten Form |
| `make help` des Ziels nennt `e2e-abdeckung` | ja (1 Treffer) |
| `gates`-Kette des Ziels nennt `e2e-abdeckung` | nein — kein Gate |

**Drei Rot-Belege, jeder mit gelesener Meldung** (`AGENTS.md` §3.6 — das Rot muss die
behauptete Ursache tragen, nicht irgendeine). Gefahren in isolierten Kopien außerhalb des
Repos, der Arbeitsbaum blieb unberührt:

| Fall | erwartet rot | gemessen |
|---|---|---|
| `test/mutations/362-e2e-stufe-ohne-deklaration.sh` | `happy path: der Erzeuger rendert je Stufe eine Zeile aus dem geprueften Skript` | `not ok 112` — genau dieser Fall. Ursache gelesen: `e2e-abdeckung: FEHLER — Stufe ohne Deklaration … Stufe 3 … Region: harness/tools/full-smoke.sh:388-1791`, Exit 1 |
| `test/mutations/363-ziel-e2e-stufe-ohne-deklaration.sh` | `emittiert: die mitgelieferte Selbstpruefung traegt eine Stufe mit ihrer Deklaration` | `not ok 122` — genau dieser Fall, Assertion `grep -cE "$RUF_MUSTER" tools/harness/selbstpruefung.sh -eq 1` gefallen; kollateral fällt `not ok 125`, die andere Lücken-Richtung über derselben Datei |
| LP3 (c), von Hand: einer Deklaration eine Kennung ohne Überschrift geben | unsere Fassung bricht ab | `e2e-abdeckung: FEHLER — die deklarierte Kennung LH-XX-99 hat keine Ueberschrift in spec/lastenheft.md; die Kennungsspalte bekaeme einen Link ohne Ziel`, Exit 1 |

**Ein Rot ist meines, nicht ihres:** `not ok 204 driver: die Kopie traegt den
Sensor-Bedarf inklusive .git` fiel in **beiden** Mutations-Kopien. Ursache ist meine
Isolations-Methode (`git archive` legt kein `.git` ab), nicht die Mutation. Es zählt
nicht gegen den Slice.

## 2. Verdikt je DoD-Punkt

| DoD-Punkt | Verdikt | Beleg |
|---|---|---|
| **LP1 — Der Erzeuger reist ins Ziel und läuft dort** | **bestätigt** | Paar liegt in beiden Bootstrap-Varianten, Modus `755`/`644`, Klasse `Konvergent`; `include harness/mk/*.mk` bindet das Fragment; Lauf Exit 0, Sicht am deklarierten Zielort. Alle vier Marker **an dem gemessen, was entsteht** — nicht an der `Marker —`-Zeile. Der Spec-Hinweis steht an beiden zugesagten Stellen. Zweiter Lauf: `unveraendert`, Datei-Hash gleich. Keine neue Abhängigkeit: das Rezept ist `bash tools/harness/e2e-abdeckung.sh`, ohne Container und ohne Netz — meine Läufe brauchten für `e2e-abdeckung` kein Docker |
| **LP2 — Sicht aus den Deklarationen, beide Lücken-Richtungen laut** | **bestätigt** | Sicht des Ziels hat **eine** Zeile mit Ort `tools/harness/selbstpruefung.sh:153`; Kennungs-Zelle trägt den Gedankenstrich, keine geratene Kennung; keine mitgelieferte Kennungs-Liste. Beide Richtungen selbst im Ziel gefahren, beide Exit ≠ 0 mit der **richtigen** Richtung in der Meldung |
| **LP3 — Tabellen-Form und Kennungs-Zelle** | **bestätigt** | `\| Spec-Kennung \| Kurzbeschreibung \| Stufe \| Ort \|` steht wörtlich in **allen drei** Stellen: unser Erzeuger, die Vorlage und die committete Sicht. Kopf-Prosa beider Fassungen erklärt die gedrehte Folge. Emittierte Sicht: **0** Verweise. Unsere Fassung bricht bei einer Kennung ohne Überschrift ab — selbst rot gesehen |
| `make gates` grün | **bestätigt** | eigener Lauf, Exit 0 |
| Review durchgeführt, Report liegt vor | **bestätigt** | vier Runden-Reports unter `docs/reviews/` zu dieser Slice-Kennung; kein Self-Review (getrennte Rollen-Läufe) |
| Doku-Update | **bestätigt** | `harness/README.md` §Werkzeuge nennt die geteilte Mechanik, die Code-Span-Regel der emittierten Fassung und die Marker; die Sensor-Datei zu `make full-smoke` führt die neue Stufe samt Spaltenfolge und zweitem Lauf |
| Closure-Notiz mit Lerneintrag | **nicht fällig** | Planner-Arbeit in frischem Kontext (`AGENTS.md` §3.10); der Slice liegt in `in-progress/` |
| Beobachtungs-Register fortgeschrieben | **nicht fällig** | dito — heute trägt kein `evidence/`-Verzeichnis eine Datei dieser Slice-Kennung (gemessen) |
| Jedes Risiko aus §6 mit Ausgang | **nicht fällig** | dito; §6 trägt noch die Platzhalter. Belege je Ausgang in Abschnitt 6 dieses Reports |
| Die drei Paarungen | **nicht fällig** | dito, sie prüfen die erst bei der Closure entstehenden Einträge |

**Keine DoD-Verletzung.** Die vier offenen Punkte sind **Closure-Pflichten**, nicht
Liefer-Punkte; sie sind zum Zeitpunkt dieser Verifikation nicht fällig und gehören
ausdrücklich in einen anderen Lauf.

## 3. Die acht Akzeptanzkriterien von `LH-FA-12`

Die DoD behauptet: *„Die acht Akzeptanzkriterien gehen in diesen drei Punkten auf …
Keines steht daneben."* Geprüft, einzeln:

| Akzeptanzkriterium | geht auf in | Verdikt |
|---|---|---|
| Happy Path | LP1 | **bestätigt**, selbst gefahren |
| Aus den Deklarationen des Ziels (Gedankenstrich statt geratener Kennung) | LP2 | **bestätigt**, selbst gefahren |
| Beide Lücken-Richtungen fallen laut | LP2 | **bestätigt**, beide selbst im Ziel gefahren |
| Adaptierbar (`LH-FA-02`), gemessen an dem was entsteht | LP1 | **bestätigt** — alle vier Marker einzeln gelenkt und am Ergebnis gemessen |
| Stabile Deklaration, kein Lauf-Artefakt | LP1 | **bestätigt** — zweiter Lauf meldet `unveraendert`, Datei-Hash unverändert |
| Kein aus dem Nichts (`LH-QA-01`) | LP3 | **bestätigt** — unsere Sicht ist mit derselben Mechanik erzeugt, und `make full-smoke` fährt sie im gebootstrappten Ziel real durch |
| Minimal (`LH-QA-03`) | LP1 | **bestätigt** — bash + coreutils, kein Docker, kein Netz |
| **Benannte Grenze** | LP3 | **wörtlich erfüllt**, siehe V-3 |

Kein Kriterium steht daneben, und keines geht doppelt auf. Die Zuordnung der DoD trifft.

## 4. Befunde

### V-3 — `LH-FA-12` §Benannte Grenze: wörtlich wahr, Implikatur überholt — **LOW, Adresse für den Architect, keine DoD-Verletzung**

Der Satz lautet: *„Löst eine genannte Kennung in der Spec des Ziels nicht auf, steht sie
als Code-Span ohne Verweis **statt als Befund**."*

**Zwei Lesarten, und beide gehören in dieselbe Zeile.** Die **Kontrast-Achse des Satzes
selbst** ist Code-Span gegen *Befund* — also: der Lauf fällt nicht. Auf dieser Achse ist
der Satz vollständig wahr und auch seine Implikatur stimmt: die ausgelieferte Fassung
schreibt eine nicht auflösende Kennung als Code-Span und bricht nicht ab. Die **zweite
Lesart** hängt am Konditional *„Löst … nicht auf"*: Wer es als Fallunterscheidung liest,
erwartet für den anderen Fall etwas anderes — einen Verweis. Den gibt es nicht; die
ausgelieferte Fassung schreibt **jede** Kennung als Code-Span und leitet nie einen Anker
ab.

**Warum das keine DoD-Verletzung ist.** Eine DoD-Verletzung ist eine Differenz zwischen
DoD-Punkt und Artefakt-Stand. LP3 **sagt genau das, was der Code tut** — *„Die
ausgelieferte Fassung schreibt jede Kennung als Code-Span und leitet keinen Anker ab"* —
und nennt auch den Grund (kein kalibrierbarer Renderer im fremden Repo). Der Code deckt
die DoD, die DoD deckt den Code. Was überholt ist, ist eine **Lesart des
Vertrags-Stratums**, und das ist eine Spec-Frage.

**Warum sie trotzdem dasteht.** Ein Leser, der nur `LH-FA-12` liest, nimmt aus dem Satz
eine Zusage mit, die kein Lauf einlöst. Das ist die Klasse *Zusage neben geänderter
Ableitung* — der Eintrag steht im Register und zählt heute **30** Belege
(`ls docs/plan/planning/observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/evidence/*.md | wc -l`;
**kein Erwartungswert**).

**Ausgang:** Der Slice-Plan §1 schließt jede Lastenheft-Änderung ausdrücklich aus (anderer
Vorgang, Change Request nach `MR-036`), und §7 führt die Adresse bereits. Der Befund
bestätigt diese Einordnung: **Adresse für den Architect**, kein Rückweisungsgrund für
diesen Slice. Empfohlene Fassung: den Konditional durch eine Feststellung ersetzen — *die
Kennungsspalte der emittierten Sicht trägt Code-Spans; ein Verweis entsteht dort nie.*

### V-1 — `make mutate` hält genau **einen** der neuen Wächter — **MEDIUM**

§6 Risiko 4 lautet *„Der neue Wächter bekommt keinen Mutations-Fall"*, Singular. Gemessen
sind es mehrere. Der Slice fügt in `test/e2e-abdeckung.bats` zwölf neue Fälle hinzu
(`emittiert: …`, `kopplung: …`, `trennlinie: …`, `anker (unsere Fassung): …`); in
`test/mutations/` liegt davon **einer** — `363-ziel-e2e-stufe-ohne-deklaration.sh`:

```sh
grep -l 'e2e-abdeckung\|e2e_abdeckung' test/mutations/*.sh | wc -l   # 2 (362 = unsere Fassung, 363 = die emittierte)
grep -c '^@test' test/e2e-abdeckung.bats                             # 17
```

**Keine Erwartungswerte** (`MR-025`) — beide wandern.

**Was das kostet.** Die Wächter laufen und sind heute grün; unbewacht ist ihre
**Haltbarkeit**. Ungelistet bleiben namentlich: der Hinweis auf die fehlende Spec-Datei
(der Fall, den `ac814e63` überhaupt erst herstellte), die Marker-Lenkung, die Trennlinie
Code-Span/Verweis und der Halter auf die Spaltenfolge. Verliert einer davon seine Zähne,
meldet `make mutate` nichts — *gelistet* heißt: wer keinen Fall in `test/mutations/` hat,
ist unbewacht (`AGENTS.md` §3.6).

**Warum es kein Liefer-Befund ist.** Kein Liefer-Punkt sagt „für jeden neuen Wächter ein
Mutations-Fall" zu; §6 Risiko 4 führt genau diesen Posten als **Risiko**. Der Befund
bindet darum an den Risiko-Ausgang, nicht an die DoD — siehe Abschnitt 6.

### V-2 — §3 nennt vier der berührten Dateien nicht — **LOW**

Der Plan-vs-Code-Diff in Abschnitt 5. Keine der vier verletzt §1; der Plan ist
unvollständig, nicht der Code falsch.

### V-4 — die emittierte Sicht steht in einem Scan-Bereich, den dieser Lauf nicht vermessen hat — **INFO**

`make docs-check` des Ziels ist Exit 0 über 21 Dateien. Ob `docs/user/e2e-abdeckung.md`
zu diesen 21 gehört, habe ich **nicht** gemessen. Für die Zusage ist es folgenlos: die
emittierte Fassung schreibt **null** Verweise (selbst gezählt), das Doku-Gate hätte dort
nichts zu finden. Ein grünes `docs-check` des Ziels ist damit **kein** Beleg für die
Kennungs-Zelle — der Beleg dafür ist der Zähl-Lauf, nicht das Gate. Genannt, damit die
Zusage nicht breiter gelesen wird als ihr Sensor.

## 5. Plan gegen Code — beide Richtungen

**Geplant und gebaut:** alle zwölf Zeilen der §3-Tabelle sind angefasst; die
`<NNN>`-Platzhalterzeile löst auf `test/mutations/363-ziel-e2e-stufe-ohne-deklaration.sh`
auf.

**Gebaut, aber nicht geplant** — vier Dateien aus Implementer-Commits, gemessen als
Differenz der berührten Dateien gegen die §3-Tabelle:

| Datei | was daran geschah | Urteil |
|---|---|---|
| `Makefile` und `internal/emit/makefile.go` | der `help`-Filter akzeptiert jetzt Ziffern im Target-Namen (`^[a-zA-Z_-]+` → `^[a-zA-Z0-9_-]+`) | **notwendige Folge**: `e2e-abdeckung` trägt eine Ziffer und wäre sonst in `make help` unsichtbar — genau die Zusage, die die neue `full-smoke`-Stufe misst. Kein Scope-Bruch, aber eine eigene Aussage über ein bestehendes Ziel |
| `internal/emit/baumaussage_test.go` | zwei Pfade in die erwartete Baum-Aussage aufgenommen | **notwendige Folge** der Emission |
| `test/full-smoke-ausgang.bats` | die Ausnahmeliste *ohne Bild-Anforderung* wächst von drei auf vier Formen und nimmt `e2e-abdeckung` auf | **notwendige Folge**: das Rezept im Ziel ist bash + coreutils und nennt Docker nicht |

**§1-Abgrenzung: nicht verletzt.** Alle fünf Ausschlüsse halten — keine zweite Fassung
unserer Kennungs-Menge im Ziel (die emittierte Fassung kennt kein `LH-*`), kein Gate
weder hier noch im Ziel (die `gates`-Kette des Ziels nennt `e2e-abdeckung` nicht,
selbst geprüft), keine weiteren Stufen im ziel-eigenen E2E (genau eine Deklaration kam
hinzu), keine Sicht-Datei im Ziel-Baum committet (der Bootstrap legt sie nicht ab, sie
entsteht erst beim Aufruf).

**Zur fünften ungenannten Datei, und warum sie keine ist.** Ein Diff über die
Commit-Range weist `spec/lastenheft.md` als berührt aus. Der Commit ist `4c033b4e`,
*Rolle Architect: LH-FA-12 im Lastenheft — angenommener Change Request*. Das ist der
**andere Vorgang**, den §1 Punkt 2 ausdrücklich benennt, in einem eigenen Commit einer
anderen Rolle. Kein Befund — genannt, weil ein Range-Diff ihn sonst als Scope-Bruch
liest.

## 6. Belege für die fünf Risiko-Ausgänge

Den Ausgang **wählt der Planner**; dieser Abschnitt liefert nur, was gemessen ist.

| § 6 Risiko | Beleg dieses Laufs | trägt welchen Ausgang |
|---|---|---|
| **1 — Die Leistung entsteht vor ihrem Vertrag** | `LH-FA-12` steht im Lastenheft, gesetzt durch den Architect-Commit `4c033b4e` als angenommener Change Request; alle acht Akzeptanzkriterien gehen in den drei Liefer-Punkten auf (Abschnitt 3) | *eingetreten* — der Change Request fängt es auf |
| **2 — Die Spaltenfolge ändert die Ableitung, Zusagen daneben bleiben stehen** | Alle vier Stellen tragen die neue Folge: unser Erzeuger, die Vorlage, die Kopf-Prosa der erzeugten Datei (*„Die Spalten stehen in der Folge `Spec-Kennung`, `Kurzbeschreibung`, `Stufe`, `Ort`"*) und die Sensor-Datei zu `make full-smoke` (*„Anforderung · Kurzbeschreibung · Stufe · Ort"*). **Aber**: V-3 ist ein Treffer derselben Klasse an einer fünften Stelle, die §6 nicht aufzählte — im Lastenheft | *eingetreten* — Beleg nach `BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/`, mit V-3 als Fundstelle |
| **3 — Zwei Fassungen derselben Mechanik driften** | Zwei Kopplungs-Träger liegen und sind grün: `kopplung: die zwei Fassungen teilen die Form und trennen sich in EINER Sache — dem Verweis` und `trennlinie: die ausgelieferte Fassung schreibt nie einen Verweis, unsere immer einen aufloesenden`, dazu `TestE2eAbdeckung_DieMarkerStehenInBeidenDateienUndSonstKeiner` (eine Umbenennung in nur einer der zwei Dateien fällt) | *entfallen* — der Kopplungs-Test deckt beide Fassungen; **Grenze**: keiner der beiden Träger steht in `test/mutations/`, seine Haltbarkeit ist also ungemessen (V-1) |
| **4 — Der neue Wächter bekommt keinen Mutations-Fall** | `363-ziel-e2e-stufe-ohne-deklaration.sh` liegt und färbt rot — von mir gefahren, Meldung gelesen. Für **die übrigen** neuen Wächter liegt kein Fall (V-1) | **gespalten**: *entfallen* für den Stufe-ohne-Deklaration-Wächter, *eingetreten* für die übrigen → Beleg nach `BEO-ALL/neuer-waechter-ohne-mutations-fall/`. Ein einzelnes *entfallen* über beide wäre breiter als sein Beleg |
| **5 — Der emittierte Erzeuger schreit den Adopter an** | Selbst gefahren: die Null-Stufen-Meldung nennt die **Form** der Kopfzeile wörtlich, die Form der Deklaration, die Funktion, die dazugehört (samt `command not found`-Warnung), und die zwei Marker mit einem lauffähigen Aufruf. Die Stufe-ohne-Deklaration-Meldung nennt Stufe, Region und ein `Nachweis:`-Kommando zum Nachsehen | *entfallen* — die Meldung nennt Form und Ort |

## 7. Grenze dieses Laufs

Benannt, damit sein Grün nicht breiter gelesen wird als der Ausschnitt, den es misst:

- **Zwei der drei Rot-Belege sind Mutations-Fälle, der dritte ist von Hand.** Die
  Rot-Zusagen von LP1 (Spec-Hinweis herausnehmen) und LP3 (a)/(b) habe ich **nicht**
  selbst gefahren; für sie steht die Behauptung des Implementers. Sie sind der Kern von
  V-1.
- **`make mutate` ist nicht gelaufen.** Der volle Satz kostet eine Größenordnung mehr als
  das Budget dieses Laufs; gefahren sind die zwei Fälle, die diesen Slice betreffen.
- **Der Scan-Bereich des ziel-eigenen `docs-check` ist ungemessen** (V-4).
- **Ob eine Stufe die genannte Anforderung wirklich prüft, misst auch dieser Lauf nicht** —
  das schließt `LH-FA-12` §Benannte Grenze ausdrücklich aus, und es bleibt ausgeschlossen.
- **Die Review-Reports waren nicht Eingabe.** Wo dieser Report eine Aussage mit einer
  Review-Runde teilt, ist sie hier unabhängig gemessen.

## 8. Verdikt

**Die DoD ist erfüllt, soweit sie heute fällig ist.** Alle drei Liefer-Punkte sind
bestätigt, `make gates` und `make full-smoke` sind in eigenen Läufen grün, die acht
Akzeptanzkriterien von `LH-FA-12` gehen in den drei Liefer-Punkten auf, und keines steht
daneben. **Keine DoD-Verletzung.**

**Vier Befunde gehen an den Planner weiter:** V-1 (MEDIUM) bindet an den Ausgang von §6
Risiko 4 und gehört als Beleg ins Register — er ist kein Grund, den Slice aufzuhalten,
aber ein Grund, den Ausgang nicht als *entfallen* zu schreiben. V-3 (LOW) ist die Adresse
an den Architect, die §7 bereits führt, hier bestätigt und mit einer Fassung versehen.
V-2 (LOW) gehört in die Closure-Notiz. V-4 (INFO) ist eine Grenz-Aussage, keine Aufgabe.

**Für die Closure freigegeben.** Was noch fehlt — Closure-Notiz, Register-Beleg,
Risiko-Ausgänge, die drei Paarungen —, ist Planner-Arbeit in frischem Kontext
(`AGENTS.md` §3.10), nicht Rest-Arbeit dieses Slice.
