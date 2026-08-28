# Slice slice-117: Ein Lauf, der nicht zu Ende kommt, färbt sich selbst rot — und ein abgebrochener sagt nichts, was seine eigene Ausgabe widerlegt

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (Sensor-Wartung, reaktiv). Die drei Fragen aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1, hier beantwortet: **(1) Bündel?** Nein — ein Treiber, seine bats-Ebene, sein
Fall-Verzeichnis; kein zweiter Slice muss mit ihm landen. **(2) Gemeinsames Closure-Kriterium?**
Nein — jedes denkbare wäre die Abschrift seiner eigenen DoD. **(3) Auslöser reaktiv oder gewollt?**
Reaktiv: zwei hergestellte Zustände aus der [Verifikation zu
slice-105](../../../reviews/2026-08-27-slice-105-verify.md) sind der Anlass, keine neue Fähigkeit.
Der Treiber kann hinterher nichts, was er vorher nicht konnte — er hört auf, in zwei Lagen zu
schweigen bzw. das Falsche zu sagen. Nach
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 2 steht wellenlose Arbeit **nicht** in der Roadmap; ihr Zustand ist das Verzeichnis.

**Ebene: Dogfood, nicht emittiert — gemessen, nicht behauptet.**
`grep -rln 'mutate' internal/emit/templates/ | wc -l` → **0**;
[`harness/tools/mutate.sh`](../../../../harness/tools/mutate.sh) geht in kein Zielrepo. Was hier
entsteht, ändert am Adopter-Vertrag nichts.

**Bezug:**
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (der Gegenstand: eine Zusage ist erst fertig, wenn ihr
Gegenbeispiel rot gesehen ist — die Zusage *„ein Shard, der **hängt**, färbt den Gesamtlauf rot"*
hat heute kein Gegenbeispiel, weil nichts rot wird),
[`AGENTS.md`](../../../../AGENTS.md) §3.7 (die zweite Hälfte: eine Meldung sagt, was gemessen ist —
drei der fünf Befunde eines abgebrochenen Laufs sind unwahr),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (ein
Sensor, dessen Fehlschlag-Text auf einen Defekt zeigt, den es nicht gibt, schickt den nächsten
Leser in die falsche Richtung — dieselbe Klasse eine Ebene tiefer, auf der Dogfood-Ebene),
[`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions) (der
Pro-Push-Auslöser: der hängende Lauf wird dort von GitHubs Job-Voreinstellung beendet, lokal von
niemandem),
[`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks) (die
Sensor-Mechanik dieses Repos),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben ihrem Kommando und wandert mit ihrem Bestand),
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
(Verortung).

**Autor:** Planner. **Datum:** 2026-08-27.

---

## 1. Ziel

**`make mutate` endet in jeder Lage von selbst — und was er am Ende sagt, deckt sich mit dem, was
er unterwegs ausgegeben hat.**

Zwei Lagen, in denen das heute nicht gilt. Beide sind hergestellt und gemessen worden, keine ist
erschlossen.

### Lage 1: ein Worker, der nicht zurückkommt, hält den Lauf für immer

Der Treiber wartet auf seine Worker mit `wait "$pid"`
(`grep -c 'wait "$pid"' harness/tools/mutate.sh` → **1**) und **ohne jede Zeitschranke**:
`grep -c 'timeout' harness/tools/mutate.sh` → **0**,
`grep -c 'timeout-minutes' .github/workflows/ci.yml` → **0**.

Die einzige Zeitschranke im Treiber ist `QUEUE_LOCK_TRIES`
(`grep -n 'QUEUE_LOCK_TRIES=' harness/tools/mutate.sh` → **eine** Zeile). Sie deckt einen Worker,
der am **Warteschlangen-Mutex** wartet — und dieser Mutex wird freigegeben, **bevor** der Fall
läuft. Der realistische Hänger hält keinen Mutex: er steht **in** `make`, weil ein Docker-Build,
ein Pull oder eine Registry-Anfrage nicht zurückkommt. Die übrigen Worker leeren die Schlange und
beenden sich, und der Elternprozess bleibt in `wait` stehen.

**Zweimal hergestellt und gemessen**, fremdbelegt aus der
[Verifikation zu slice-105](../../../reviews/2026-08-27-slice-105-verify.md) §4.3 (dort mit den
Kommandos): ein Lauf endete nach 90 s nur an einem `timeout` von außen (Exit 124), ein zweiter
stand nach 1:49 min noch, mit einem Protokoll, das seit seiner vierten Zeile unverändert war.

**Die Richtung ist nicht *still grün*, und das ist der Grund, warum dieser Slice keine Sperre für
andere ist.** Ein hängender Lauf liefert **kein** Ergebnis, also auch kein falsches. Der Preis ist
Wartezeit und ein blockierter Lock. In der CI beendet GitHubs Job-Voreinstellung (360 Minuten) den
Job und meldet ihn als Fehlschlag — **dokumentiert, von diesem Repo nicht gemessen**; lokal endet
er nie. Getragen wird die Zusage damit heute von der Umgebung, nicht vom Treiber, und genau das ist
[`CO-003`](../../carveouts/done/CO-003-mutate-ohne-zeitschranke.md).

### Lage 2: unter Ctrl-C widerspricht der Bericht seiner eigenen Fortschritts-Ausgabe

`cleanup()` hängt an `trap 'cleanup' EXIT INT TERM`
(`grep -n "^trap 'cleanup' EXIT INT TERM" harness/tools/mutate.sh` → **eine** Zeile), entfernt
`$ISO_ROOT` — und das Laufverzeichnis liegt **darin** —, kehrt mit `0` zurück, und `main()` läuft
danach weiter in `merge_report`, das nun über ein gelöschtes Verzeichnis rechnet.

Fremdbelegt aus derselben [Verifikation](../../../reviews/2026-08-27-slice-105-verify.md) §6.4, ein
Lauf mit `kill -INT` nach 9 s: der Bericht meldet *„kein einziger Worker hat ein Zug-Protokoll
hinterlassen — der Lauf hat nichts gemessen"* und *„0 von 3 Fall-Dateien haben ein Ergebnis"*
**vier Zeilen unter** zwei Fällen mit Urteil; die letzte Fortschrittszeile steht **hinter** dem
Schlussstrich, weil auch die Worker-Traps zurückkehren statt zu beenden.

**Fail-closed ist die Richtung** — der Lauf wird rot, nicht grün. Unwahr ist der **Text**: drei von
fünf Befunden sagen etwas über eine Messung, die so nicht stattgefunden hat, und wer sie liest,
sucht einen Defekt in der Warteschlange, den es nicht gibt
([`AGENTS.md`](../../../../AGENTS.md) §3.7).

### Was daneben liegt und mit derselben Hand erledigt wird

Der Treiber trägt heute **zwei** ausdrückliche fail-closed-Zeitschranken-Zusagen und **eine**
davon hat einen Zahn: der Abschluss-Marken-Zweig ist seit `0e76c77` bewacht
(`grep -c 'MARKE-FEHLT' test/mutate-driver.bats` → **2**), `QUEUE_LOCK_TRIES` nicht
(`grep -rln 'QUEUE_LOCK_TRIES' test/ | wc -l` → **0**), obwohl ihr Kommentar sie ausdrücklich als
*„FAIL-CLOSED-Schranke, kein Komfort"* führt. Wer die Zeitschranken anfasst, fasst beide an.

## 2. Definition of Done

Drei slice-eigene Punkte, jeder mit dem Kommando, das ihn **rot** färbt (Modul 5 §Ziel-Form: ≤ 3;
[`AGENTS.md`](../../../../AGENTS.md) §3.6).

- [x] **(1) Ein Worker, der nicht zurückkommt, färbt den Lauf von selbst rot — innerhalb einer
      Schranke, die der Treiber nennt.** Der Lauf endet ohne Signal von außen, der Bericht benennt
      den Worker und die überschrittene Schranke, und die Schranke steht an **einer** Stelle im
      Treiber (keine zweite Vorgabe im `Makefile` — dieselbe Begründung wie bei `MUTATE_JOBS`).
      **Rot:** ein hergestellter Hänger — ein `make`-Stub, der für genau einen Fall nicht
      zurückkehrt — muss **ohne** `timeout` von außen mit Exit ≠ 0 enden und den Worker benennen.
      Dazu ein `test/mutations/`-Fall, der die Schranke entfernt und den benannten bats-Fall rot
      färbt.
- [x] **(2) Der Bericht eines abgebrochenen Laufs sagt nichts, was seine eigene
      Fortschritts-Ausgabe widerlegt.** Ein Lauf, der ein Signal bekommt, meldet über die Fälle mit
      Urteil, was gemessen ist, und über die übrigen, dass sie kein Ergebnis haben — nicht *„der
      Lauf hat nichts gemessen"*, während zwei Urteile darüberstehen.
      **Rot:** ein Lauf mit `kill -INT` nach dem ersten Urteil; die Zahl der Fälle mit Ergebnis im
      Bericht steht gegen die Zahl der `OK`/`BEFUND`-Fortschrittszeilen desselben Protokolls.
      Weicht sie ab, ist der Lauf rot. Dazu ein `test/mutations/`-Fall über der Trennung von
      Signal- und EXIT-Zweig.
- [x] **(3) Jede Zeitschranke des Treibers trägt einen Zahn.** Beide — `QUEUE_LOCK_TRIES` und die
      aus (1) — haben einen bats-Fall **und** einen `test/mutations/`-Fall; keine steht mehr allein
      auf ihrem Kommentar.
      **Rot:** `grep -rln 'QUEUE_LOCK_TRIES' test/ | wc -l` → heute **0**; nach diesem Slice ≥ 1,
      und der Mutations-Fall dazu färbt genau den benannten bats-Fall rot.

Standard-Punkte der Vorlage (nicht slice-eigen): `make gates` grün · `make mutate` ohne Befund ·
Doku-Update, falls ein öffentlicher Vertrag berührt ist · Closure-Notiz mit
Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`harness/tools/mutate.sh`](../../../../harness/tools/mutate.sh) | update | Zeitschranke um das Warten auf die Worker (DoD 1); Trennung von Signal- und EXIT-Zweig im `trap`, damit der Bericht vor dem Wegräumen entsteht (DoD 2). `wc -l < harness/tools/mutate.sh` → **1252** heute; wächst er, wächst die bats-Ebene mit |
| [`test/mutate-driver.bats`](../../../../test/mutate-driver.bats) | update | die Sensor-Ebene des Treibers; `grep -c '^@test' test/mutate-driver.bats` → **39** heute. Die neuen Fälle gehören dorthin, nicht in einen zweiten Sensor |
| `test/mutations/` <!-- d-check:ignore (geplante Dateien) --> | neu | die Zähne aus DoD (1)–(3); Nummern im Anschluss an die höchste vergebene (`ls -1 test/mutations/*.sh \| sed -n 's#.*/\([0-9]*\)-.*#\1#p' \| sort -n \| tail -1` → **197**, beim Anlegen neu auszuzählen) |
| [`docs/plan/carveouts/done/CO-003-mutate-ohne-zeitschranke.md`](../../carveouts/done/CO-003-mutate-ohne-zeitschranke.md) | `git mv` nach `done/` **oder** update | DoD (1) ist sein Auflösungs-Trigger; der Move ist ein eigener Commit ([`AGENTS.md`](../../../../AGENTS.md) §3.3), und der Index in [`docs/plan/carveouts/README.md`](../../carveouts/README.md) zieht mit |
| [`.github/workflows/ci.yml`](../../../../.github/workflows/ci.yml) | **unverändert**, sofern (1) im Treiber liegt | eine `timeout-minutes`-Zeile im Workflow wäre eine **zweite** Schranke an einem Ort, den ein lokaler Lauf nicht sieht — die CI ruft ausschließlich `make`-Targets ([`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions)) |
| [`docs/plan/adr`](../../adr) | **unverändert** | die Änderung **hebt** eine Zusage an und senkt keine Schwelle; eine Anhebung braucht kein ADR ([`AGENTS.md`](../../../../AGENTS.md) §3.5) |
| [`docs/plan/planning/in-progress/roadmap.md`](../in-progress/roadmap.md) | **unverändert** | wellenlose Arbeit wird dort nicht geführt ([`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird) Setzung 2/3) |

**Mitnahme — vier Kommentar-Aussagen im selben Treiber, die der nächste Leser mitliest.** Sie sind
**kein** DoD-Punkt und werden **nicht** nachgerüstet, wenn die Stelle unberührt bleibt; wer sie
ohnehin anfasst, zieht sie nach ([`AGENTS.md`](../../../../AGENTS.md) §3.7 Cutoff). Alle vier sind
in der [Review-](../../../reviews/2026-08-27-slice-105-review.md) bzw.
[Verifikations-Runde](../../../reviews/2026-08-27-slice-105-verify.md) zu slice-105 gemessen
worden:

1. **`mode_rank` hat ihre eigene Nachzieh-Zusage ausgelöst.** Ihr Kommentar nennt `report_times`
   als ihren Sensor; dessen Lesungen setzen `smoke` hinter `test-bats`, der Rang davor. Folgenlos,
   weil die Ränge nur **innerhalb** einer Spur wirken und dort in beiden gemessenen Läufen richtig
   sortieren — und weil ein Modus mit `n=1` zwischen zwei Läufen desselben Tages um Faktor **6,7**
   streut (`smoke` 1,91 s gegen 12,88 s, beide aus der `mittel=`-Spalte von `report_times`). Was
   nachzuziehen ist, ist deshalb eher die **Zusage** als die Zahl.
2. **Die Begründung, warum die vierte `merge_report`-Prüfung nicht redundant sei, trifft nicht
   zu.** Der Kommentar sagt *„1 bis 3 messen gegen die Warteschlange, 4 gegen das Verzeichnis"*;
   die Schleife von 1 und 2 läuft `for ((i = 1; i <= total; i++))`, und `total` kommt aus
   `cases=("$CASES_DIR"/*.sh)` — also aus dem Verzeichnis. Gegen die Warteschlange misst allein die
   Zug-Protokoll-Achse.
3. **Drei Stellen erzählen die Geschichte eines Vorgängers, den dieses Repo nie getragen hat**
   (`grep -cE 'erste[rn]? Entwurf|Vorgaenger' harness/tools/mutate.sh test/mutate-driver.bats` →
   **1** bzw. **2**). Die tragende Abgrenzung steht jeweils im Satz davor und kommt ohne die
   Erzählung aus.
4. **Die Anteils-Zeile nennt ihren Nenner zwei Blöcke später.** `anteil=` rechnet gegen die
   Fall-Arbeit, die Überschrift darüber nennt nur die Fall-**Zahl**; ein Wort in der Überschrift
   schlösse das. Ebenso sagt die Kopfzeile *„aus einer gemeinsamen Warteschlange"*, während
   dasselbe Protokoll eine Zeile darüber eine serielle Spur meldet und der Code zwei Schlangen
   anlegt.

**Vor dem Code entschieden — die Antworten stehen hier, nicht im Kommentar.** Dass sie hier stehen,
ist die Lehre aus [slice-105](../done/slice-105-mutate-messen-dann-teilen.md): dort lagen die
Begründungen zu B und C im `Makefile`- und Skript-Kommentar, und der Closure-Trigger, der sie *„mit
ihrer Begründung im Plan"* verlangte, war damit nicht erfüllt.

**A — die Schranke sitzt um `wait`, misst aber Fortschritt statt Dauer.** Beide angebotenen Orte
haben denselben Fehler: sie bemessen eine **Wanduhr**. Um `run_case` müsste sie je Modus verschieden
sein (der längste Einzelfall kostet **67,84 s**, ein `ci-lint`-Fall **1,15 s** — beide aus
`sed -n '/Zeit je Sensor/,/Gruen-Vorlaeufe/p'` über dem Protokoll zu `0e76c77`), und jede dieser
Zahlen wäre auf einem langsamen Runner eine eigene Fehlschlag-Quelle. Um `wait` müsste sie die
**Gesamtlaufzeit** decken, und die schwankt zwischen **570,37 s** hier und **1299 s** in der CI
(derselbe Bestand, `0e76c77`). Gemessen wird darum **Stille**: vergeht mehr als die Schranke, ohne
dass irgendein Worker einen Fall zieht oder abschließt, ist der Lauf hängengeblieben. Ein
langsamer Runner macht **langsamer** Fortschritt, aber er macht welchen; ein Hänger macht keinen.
Damit ist die Schranke eine Aussage über den **Lauf** (sie kennt alle Worker und benennt den
schuldigen), ohne je Modus bemessen zu sein.

**B — ihr Wert kommt aus der längsten *legitimen* Stille, mal einem Sicherheitsfaktor.** Die
längste Lücke ohne Fortschritts-Ereignis ist **kein** Fall, sondern ein Grün-Vorlauf: `full-smoke`
brauchte **123,84 s** (`sed -n '/Gruen-Vorlaeufe/,/Zeit je Fall/p'` über demselben Protokoll,
Maximum der dritten Spalte; im Lauf davor 102,28 s). Die CI ist je Fall **2,4×** langsamer
(6,74 gegen 2,80 s je Fall, beide Zahlen mit ihren Kommandos in
[slice-105](../done/slice-105-mutate-messen-dann-teilen.md) §1), was dort rund **300 s** erwarten
lässt. Die Schranke steht auf **900 s** — das **7,3-fache** der hier gemessenen und rund das
**3-fache** der in der CI erwarteten legitimen Stille. Sie ist mit Absicht großzügig: ein Hänger
ist **unbegrenzt**, also löst jede endliche Schranke ihn aus, während eine knappe Schranke einen
langsamen Runner rötet — und ein Sensor, der ohne Befund rot wird, senkt seine eigene Aussage
([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
**Was diese Bemessung nicht deckt:** einen Fall, der *langsamer als die Schranke, aber endlich* ist.
Ein solcher Fall existiert heute nicht (der teuerste ist 67,84 s); wer den ersten schreibt, fällt
hierunter.

**C — die Fälle mit Urteil werden berichtet, aber als Meldung, nicht als Bilanz.** Verschweigen wäre
eine Ausgabe, die weniger sagt, als der Lauf gemessen hat; eine **Bilanz** über ihnen wäre der
Anteils-Nenner über einer Teilmenge, den [slice-105](../done/slice-105-mutate-messen-dann-teilen.md)
DoD (1) ausschließt. Beides ist schon gebaut und bleibt: `merge_report` nennt je Fall sein Urteil
und die übrigen als *„ohne Ergebnis geblieben"*, `report_times` verweigert die Bilanz mit einem
Befund. Dieser Slice ändert daran nichts — er sorgt nur dafür, dass beide **überhaupt laufen**,
bevor das Aufräumen ihre Datenbasis löscht.

Die Fragen im Wortlaut, gegen die oben entschieden wurde:

| # | Frage | Warum sie den Schnitt entscheidet |
|---|---|---|
| A | **Wo sitzt die Schranke — um `wait` oder um den Sensor-Lauf in `run_case`?** Um `wait` ist sie eine Aussage über den **Lauf** und braucht einen Wächter-Prozess neben dem Warten; um `run_case` ist sie eine Aussage über den **Fall** und liegt näher an der Ursache, muss dann aber je Modus verschieden bemessen sein — der längste gemessene Einzelfall kostet **67,84 s** (`sed -n 's/.*laengster Einzelfall: \([0-9.]*\) s.*/\1/p'` über einem `make mutate`-Protokoll) |
| B | **Woher kommt ihr Wert, und was passiert auf einem langsamen Runner?** Eine Schranke, die auf 20 Kernen großzügig ist, ist auf vier vCPU eine Fehlschlag-Quelle ohne Befund — genau das, wogegen [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) steht. Der CI-Lauf desselben Sensors braucht gemessen **6,74 s je Fall** gegen **2,80 s** auf diesem Host, beide über denselben 188 Fällen bei N=4 (beide Zahlen mit ihren Kommandos in [slice-105](../done/slice-105-mutate-messen-dann-teilen.md) §1) |
| C | **Was tut der Lauf mit den Fällen, die beim Abbruch schon ein Urteil hatten?** Sie zu berichten ist ehrlicher als sie zu verschweigen — aber ein Bericht über einer Teilmenge ist genau das, was slice-105 DoD (1) ausschließt. Die Antwort entscheidet, ob DoD (2) eine **Meldung** oder eine **Bilanz** verlangt |

## 4. Trigger

**Beginn (`open` → `next`): nichts blockiert.** Der Gegenstand liegt vollständig in einer Datei und
ihrer bats-Ebene; keine fremde Sperre steht davor.

**Die Reihenfolge gegenüber [slice-115](../open/slice-115-jeder-sensor-sagt-seinen-ausgang.md):** beide
fassen [`harness/tools/mutate.sh`](../../../../harness/tools/mutate.sh) an, und beide handeln
davon, dass ein Lauf seinen Ausgang **selbst** nennt. Das ist eine Beobachtung, keine Reihenfolge —
wer zuerst läuft, entscheidet die Priorisierung, nicht dieser Plan. **Was hier ausdrücklich nicht
behauptet wird:** dass die zwei zusammengehören. Sie teilen eine Datei, nicht ein
Closure-Kriterium.

**Rückführung `in-progress` → `next`:** wenn sich zeigt, dass die Schranke aus (1) je Modus
verschieden bemessen sein muss und damit eine eigene Messreihe braucht — dann ist die Messung ein
eigener Schnitt und die Schranke wartet auf sie.

**Rückführung `in-progress` → `open` (blockiert):** wenn eine tragfähige Schranke nur um den Preis
zu haben wäre, dass ein langsamer Runner sie regelmäßig auslöst. Ein Sensor, der ohne Befund rot
wird, ist eine Senkung seiner eigenen Aussage — dann wartet der Slice auf die Bemessungs-Messung,
statt die Zahl zu raten.

## 5. Closure-Trigger

DoD (1)–(3) erfüllt mit gefahrenen Kommandos; der hergestellte Hänger ist **einmal ohne Signal von
außen rot gesehen**; der abgebrochene Lauf ist **einmal gefahren** und sein Bericht gegen sein
eigenes Protokoll gehalten; Frage A, B und C sind mit ihrer Begründung im Plan beantwortet;
[`CO-003`](../../carveouts/done/CO-003-mutate-ohne-zeitschranke.md) ist aufgelöst (`git mv` nach `done/`,
Index gezogen) **oder** mit neuem Trigger und neuem Prüfdatum ausdrücklich bestätigt;
[`harness/README.md`](../../../../harness/README.md) trägt die Schranke, falls sie den
Nicht-Gate-Verify-Absatz berührt; Review konform (Modul 10); Verifikation bestätigt (Modul 11);
`make gates` grün; `git mv` nach `done/` als eigener Move-Commit; Closure-Notiz mit
Steering-Loop-Eintrag in einer der drei Formen (geschärfte Regel · neuer Sensor · benannte
Spec-Lücke).

**Ausdrücklich nicht Teil des Closure-Triggers: eine Laufzeit-Schwelle für `make mutate` selbst.**
Die Schranke aus (1) ist eine **Obergrenze gegen das Nicht-Enden**, keine Erwartung an die Dauer —
eine Zahl als Abnahme-Kriterium wäre auf einem geteilten Runner rot ohne Befund
([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).

## 6. Risiken und offene Punkte

- **Eine Schranke, die zu eng bemessen ist, erzeugt genau die Klasse, gegen die dieser Sensor
  steht:** ein Rot ohne Befund. Sie ist deshalb als **Obergrenze gegen das Nicht-Enden** zu
  bemessen und nicht als Erwartungswert — Frage B entscheidet das, und sie darf nicht vor der
  Messung fallen.
- **Der Signal-Zweig ist schwer zu testen, ohne ihn zu fahren.** Ein bats-Fall über einer Funktion
  belegt nicht, was ein Signal an den Prozess tut. Die zwei Zustände aus §1 sind beide durch
  **Fahren** entstanden; wer sie nur nachbaut, prüft seinen Nachbau.
- **Der Treiber wächst weiter**, und seine Sensor-Ebene ist bats. `wc -l < harness/tools/mutate.sh`
  → **1252**, `grep -c '^@test' test/mutate-driver.bats` → **39**. Wächst die eine ohne die andere,
  entsteht die Klasse, gegen die dieses Werkzeug gerichtet ist: ein Wächter ohne Wächter.
- **Das Ende des Laufs ist nicht dasselbe wie das Ende der Worker.** Eine Schranke, die den
  Elternprozess befreit, lässt einen hängenden Kind-Prozess möglicherweise stehen — dann wandert
  das Problem vom Warten in das Aufräumen, und der nächste Lauf findet ein Lock-Verzeichnis vor.
  Das ist Gegenstand von DoD (1) und nicht seine Randnotiz.

## 7. Closure-Notiz (nach `done/`)

**Was gilt.** `make mutate` endet in beiden Lagen aus §1 von selbst, und was er am Ende sagt,
deckt sich mit dem, was er unterwegs ausgegeben hat. Der Bestand ist über neun Commits gewachsen
(`git log --oneline be87307..ed81e21 | wc -l` → **9**): `ls -1 test/mutations/*.sh | wc -l`
**190 → 198**, `grep -c '^@test' test/mutate-driver.bats` **39 → 48**,
`wc -l < harness/tools/mutate.sh` **1252 → 1512** (die drei Ausgangswerte je über
`git show be87307:<datei>`, dem Plan-Commit und direkten Elternteil des ersten Code-Commits). Der
letzte Sensor-Lauf meldet **198 ok, 0 Befund(e)** bei `MUTATE_SECONDS=751.98`
(`tail -3` über dem Protokoll des Umsetzungs-Laufs), und alle acht Fälle dieses Slice stehen darin
mit Urteil (`grep -E '^mutate: \[w[0-9]+\] (198|199|200|201|202|203|204|205)-'` → **8** Zeilen, alle
`OK`) — jeder hat also seinen benannten Wächter rot gefärbt, sonst wäre er ein Befund.

### DoD-Verdikt, Punkt für Punkt

**(1) ERFÜLLT.** Der Rot-Nachweis in der Form, die der Punkt beschreibt — ein `make`-Stub, der für
genau einen Fall nicht zurückkehrt, endet **ohne** `timeout` von außen mit Exit 1 und benennt
Worker und Schranke — ist in der zweiten Verifikations-Runde gegen `9b9866b` gefahren worden
(Exit 1 nach 17,27 s). Dass er für diesen Baum weiter gilt, ist nicht angenommen, sondern
gemessen: die drei Funktionen, die das Enden tragen, sind seither **byte-gleich**
(`for fn in await_workers collect_workers stop_workers; do diff <(git show 9b9866b:harness/tools/mutate.sh | sed -n "/^${fn}() {/,/^}/p") <(sed -n "/^${fn}() {/,/^}/p" harness/tools/mutate.sh); done`
→ leere Ausgabe für alle drei), und `main()` unterscheidet sich von jenem Stand ausschließlich in
der Bericht-Flagge (`git diff 9b9866b ed81e21 -- harness/tools/mutate.sh` → zwei Hunks in `main`,
beide die Flagge). Die Schranke steht an **einer** Stelle im Treiber
(`grep -cE '^STALL_SECONDS=' harness/tools/mutate.sh` → **1**) und hat keine zweite Vorgabe
daneben (`grep -c 'MUTATE_STALL_SECONDS' Makefile` → **0**,
`grep -c 'timeout-minutes' .github/workflows/ci.yml` → **0**). Ihre Zähne sind die Fälle `199`
(nimmt der Stille ihre Messgröße) und `202` (nimmt dem Einsammeln die Schranke); beide stehen im
Protokoll mit `OK`.

**(2) ERFÜLLT, und das Gegenbeispiel ist rot gesehen.** Der Punkt verlangt, dass der Bericht eines
abgebrochenen Laufs nichts sagt, was seine eigene Fortschritts-Ausgabe widerlegt. Beide Runden der
Verifikation haben genau eine Verletzung gefunden — ein Signal **innerhalb** des Berichtsfensters
startete den Bericht ein zweites Mal, mit `4 ok` über zwei bzw. `800 ok` über 400 Fällen. Zwei
Arme über **derselben** Fixture (zwei Fälle mit Urteil, `merge_report 2`, `report_times 2`, dann
`kill -INT $$`), die sich allein in der Reihenfolge unterscheiden, die `main()` an der jeweiligen
Revision fährt:

| Arm | Treiber, Reihenfolge wie sein `main()` | `grep -c 'Vollstaendigkeit — '` | Schlusszeile |
|---|---|---|---|
| A | dieser Stand: Flagge **vor** dem ersten Bericht-Kommando | **1** | `ABBRUCH — INT waehrend oder nach dem Bericht; er wird nicht wiederholt und kann unvollstaendig sein.` |
| B | `9b9866b`: Flagge **nach** `report_times`, Signal davor | **2** | `mutate: 4 ok, 0 Befund(e) — ABGEBROCHEN, keine vollstaendige Messung.` |

Arm B ist das Rot, Arm A die Grün-Kontrolle, beide auf diesem Host gefahren. Der Zahn dazu ist
Fall `204`; er steht im Protokoll mit `OK`. **Was der Zahn nicht deckt**, sagt der Treiber neben der
Flagge selbst: er prüft den **Zweig**, nicht den **Ort** der Flagge in `main()` — der ist an
gefahrenen Läufen gemessen. Das ist ein Posten mit Ausgang unten, keine stille Lücke.

**(3) ERFÜLLT.** Der Treiber trägt zwei benannte Zeitschranken, und beide haben einen bats-Fall
**und** einen `test/mutations/`-Fall: `QUEUE_LOCK_TRIES`
(`grep -rln 'QUEUE_LOCK_TRIES' test/ | wc -l` → **2**, im Plan als **0** gemessen; Fall `198`) und
`STALL_SECONDS` (Fälle `199` und `202`). Die **dritte**, die die zweite Verifikations-Runde gezählt
und als unbewacht gemeldet hat — eine Wanduhr-Schranke um den Grün-Vorlauf —, existiert nicht mehr:
`grep -n 'timeout' harness/tools/mutate.sh` liefert **4** Zeilen (630, 635, 922, 924), **keine**
davon in Befehlsposition. Die Überschrift des Punktes und seine Aufzählung sagen damit dasselbe.

### Der Closure-Trigger aus §5, Zeile für Zeile

| Bedingung | Stand | Beleg |
|---|---|---|
| DoD (1)–(3) mit gefahrenen Kommandos | **erfüllt** | oben |
| der hergestellte Hänger einmal **ohne Signal von außen** rot gesehen | **erfüllt** | Verifikations-Runde 2, Exit 1 nach 17,27 s; der Pfad seither byte-gleich (Kommando oben) |
| der abgebrochene Lauf einmal gefahren, Bericht gegen sein eigenes Protokoll gehalten | **erfüllt** | vier Läufe in Runde 2; dazu die zwei Arme oben |
| Frage A, B, C mit Begründung **im Plan** | **erfüllt** | `be87307`, direkter Elternteil des ersten Code-Commits |
| [`CO-003`](../../carveouts/done/CO-003-mutate-ohne-zeitschranke.md) aufgelöst **oder** mit neuem Trigger bestätigt | **weder noch — und der Grund ist ein Befund** | seine Bedingung 1 misst ihren Gegenstand nicht (unten); der Carveout bleibt **aktiv**, mit Prüfdatum und Folge-Slice |
| [`harness/README.md`](../../../../harness/README.md) trägt die Schranke | **erfüllt** | `grep -c 'MUTATE_STALL_SECONDS' harness/README.md` → **1**; der Absatz nennt die Schranke, ihre Stellschraube und ihre zwei Grenzen |
| Review konform (Modul 10) · Verifikation bestätigt (Modul 11) | **zwei Runden je** | vier Berichte unter `docs/reviews/`, alle vier als Eingabe gelesen |
| `make gates` grün | **erfüllt** | eigener Lauf, unten |
| `git mv` nach `done/` als eigener Move-Commit · Closure-Notiz mit Steering-Loop-Eintrag | **dieser Zug** | — |

**Die fünfte Zeile ist nicht abgehakt, und sie wird auch nicht umgeschrieben.** Beide Ausgänge, die
sie anbietet, sind Trigger-Entscheidungen am Carveout; über die entscheidet nicht die Rolle, die
den Folge-Slice schließt. Was dieser Zug leistet, ist der Modul-7-Übergang *weiterhin aktiv*:
Prüfdatum nachgetragen, Ergebnis in der Geschichte, Folge-Slice benannt. Die Trigger-Änderung ist
eine Übergabe (unten).

### Was anders lief als geplant

**Drei Runden statt einer, und zweimal dieselben zwei Klassen.** Der Umsetzungs-Commit fiel an
einem HIGH und sechs MEDIUM, die Fix-Runde an einem HIGH und sieben MEDIUM. In beiden Runden trugen
die Befunde dieselben zwei Formen: **(a)** eine Reparatur ohne rot gesehenes Gegenbeispiel und
**(b)** ein Kommentar oder eine Zahl, die einen Mechanismus behauptet, den es nicht gibt — der
*„Detektor Status 124"*, den das gepinnte bats-Bild nie liefert (dort ist `timeout` BusyBox und
liefert 143), die Zusage über überlebende Kinder eines `timeout`, und zweimal eine Herleitung, die
über eine kleinere Größe rechnet als die, die der Code misst. **Gefunden hat sie jedes Mal ein
Sensor oder eine zweite Rolle, nie der schreibende Lauf beim Schreiben.** Das trägt den
Steering-Loop-Eintrag unten.

**Der Rückbau, und er gehört in diesen Plan.** Die Fix-Runde hat den Hänger im Vorwärmlauf mit
`timeout "$STALL_SECONDS" make "$m"` im Grün-Vorlauf geschlossen; der Folge-Commit hat die Zeile
wieder entfernt. Der Grund ist nicht Geschmack, sondern **§3 Frage A dieses Plans**: dort sind
Wanduhr-Schranken **vor dem Code** verworfen worden, weil sie je Modus verschieden bemessen sein
müssten und auf einem langsamen Runner rot ohne Befund werden. Die Zeile war genau eine solche
Schranke, mit der Zahl, die für **Stille** hergeleitet ist. Dazu kamen drei gemessene Posten: eine
Regression (`timeout` legt sich in eine eigene Prozessgruppe, worauf der erste Docker-Build dem
Ctrl-C des Aufrufers entkam — gegen den Vorstand geprüft, dort lag `make` in der Treiber-PGID und
starb), ein Kommentar, der das Gegenteil des Gemessenen sagte (*„dessen Kinder ueberleben es"* —
sie sterben mit), und eine neue Host-Abhängigkeit gegen
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten). Einen Zahn hatte
sie nicht. **Der Hänger im Vorwärmlauf ist damit wieder offen**, steht als benannte Grenze im
Treiber und in [`harness/README.md`](../../../../harness/README.md) und hat einen Träger
([slice-118](../open/slice-118-vorwaermlauf-endet-von-selbst.md)).

**Was der Plan über den Code sagt und der Code enger hält.** §3 Frage A spricht von einer Schranke,
die *„den schuldigen"* Worker benennt; die Meldung sagt *„Noch laufend"* und der Kommentar sagt,
warum: gemessen ist die Stille, nicht ihr Grund. Der Code ist an dieser Stelle ehrlicher als der
Plan — festgehalten, nicht geglättet.

### Die offenen Posten und ihr Ausgang

§4 dieses Plans lässt vier Ausgänge zu; *„genannt"* ist keiner. Jede Zeile trägt ihren Stand an
diesem Baum mit dem Kommando, das ihn liefert.

| Posten | Stand (Kommando) | Ausgang |
|---|---|---|
| Ein Hänger im **Vorwärmlauf vor dem Fork** endet nicht von selbst | benannte Grenze im Treiber (`sed -n '629,642p' harness/tools/mutate.sh`) und in [`harness/README.md`](../../../../harness/README.md); gemessen Exit 137 nach 50,01 s, ohne Bericht | **aufgeschoben.** Träger [slice-118](../open/slice-118-vorwaermlauf-endet-von-selbst.md); Auflösungs-Trigger ist dessen DoD (1) |
| Die verwaiste **Enkel-Instanz erbt Deskriptor 3** und hält die Ausgabe-Pipeline des Aufrufers offen | im Treiber unbehoben (`grep -c '3>&-' harness/tools/mutate.sh` → **0**), in den bats-Fällen behoben (`grep -c '3>&- 4>&-' test/mutate-driver.bats` → **4**); gemessen 25,00 s bzw. 135,85 s nach der Schlusszeile | **diagnostiziert** (Ursache: `exec 3>&2` in `main()`, über den Worker an dessen Kind vererbt) und **aufgeschoben**. Träger [slice-118](../open/slice-118-vorwaermlauf-endet-von-selbst.md): dessen DoD (2) entscheidet die Prozessgruppen-Frage für die Kinder des Treibers, und dieselbe Entscheidung schliesst den offenen Kanal |
| Die **bats-Stufe ist teurer geworden** | `docker run … bats/bats@sha256:e8f1… test/` mit Wanduhr: **16,18 s** am Plan-Commit (`git worktree` auf `be87307`) gegen **24,53 s** hier; im Protokoll trägt `test-bats` **52,6 %** der Fall-Arbeit bei n=56 (`sed -n '/Zeit je Sensor/,/Gruen-Vorlaeufe/p'`) | **diagnostiziert und aufgeschoben**, s. den eigenen Abschnitt unten |
| §3.7-**Prosa über abwesenden Text** ist gewachsen | `grep -cE 'erste[rn]? Entwurf\|frueheste[rn]? Entwurf\|Vorgaenger\|frueher hier stehende\|die frueher' harness/tools/mutate.sh test/mutate-driver.bats` → **6** an `be87307`, **10** hier; dazu eine Stelle derselben Klasse, die kein Muster fasst (`grep -n 'Hier stand' harness/tools/mutate.sh` → **1**) | **diagnostiziert und aufgeschoben.** Mitnahme 3 dieses Plans ist in die Gegenrichtung gelaufen: der Cutoff bindet die neu geschriebene Zeile, und geschrieben wurden vier. Auflösungs-Trigger ist der nächste Zug an diesem Block — [slice-118](../open/slice-118-vorwaermlauf-endet-von-selbst.md) fasst ihn an |
| [`CO-003`](../../carveouts/done/CO-003-mutate-ohne-zeitschranke.md) **Bedingung 1 misst ihren Gegenstand nicht** | `grep -c 'timeout' harness/tools/mutate.sh` → **4**, `grep -n` zeigt alle vier als Kommentar (630, 635, 922, 924); `sed -n '/^await_workers()/,/^}/p' harness/tools/mutate.sh \| grep -c 'timeout'` → **0**, dasselbe über `collect_workers` → **0** | **Übergabe an den Architect** (unten). Der Carveout bleibt aktiv; ein Haken auf dieser Zahl wäre ein grüner Beleg für eine andere Sache |
| Der Wächter *„Fortschritt setzt die Zeitschranke zurueck"* hat keinen Zahn | `grep -rl '^# expect: driver: Fortschritt setzt die Zeitschranke zurueck$' test/mutations/ \| wc -l` → **0** | **aufgeschoben.** Träger [slice-119](../open/slice-119-zusage-ohne-fall-wird-sichtbar.md) — er macht genau diese Klasse zählbar |
| Die **Fünf-Sekunden-Frist** in `stop_workers` und der harte `kill` danach haben keinen Fall | `grep -rn 'k < 20\|kill -KILL' test/mutations/ \| wc -l` → **0** | **aufgeschoben.** Träger [slice-119](../open/slice-119-zusage-ohne-fall-wird-sichtbar.md); die Frist trägt im Kommentar eine fail-closed-Zusage (*„haelt den Lauf nicht auf"*) und ist damit dieselbe Klasse |
| Der **Ort** der Bericht-Flagge in `main()` ist von keinem Sensor gehalten | `grep -rn 'BERICHT_BEGONNEN' test/` → **2** Zeilen: der bats-Fall setzt die Flagge selbst, der Mutations-Fall nimmt den Zweig — keine misst, wo `main()` sie setzt | **aufgeschoben.** Träger [slice-119](../open/slice-119-zusage-ohne-fall-wird-sichtbar.md) |
| Fall `199` färbt **zwei** Wächter rot und benennt einen | `# expect:` nennt einen; `collect_workers` hängt an derselben Schranke | **aufgeschoben.** Träger [slice-069](../open/slice-069-zahn-bindet-zusicherung.md) — dort ist die Zuordnung Fall → Zusicherung der Gegenstand |
| `[ "$status" -eq 143 ]` trennt *„der Worker ist ausgestiegen"* nicht von *„der Test lief in seine Zeitschranke"*; der Sensor kann selbst hängen | `grep -n 'timeout ' test/mutate-driver.bats` → **2** Zeilen, beide ohne `-k`; gemessen > 600 s gegen 23,48 s Kontrolle | **aufgeschoben.** Träger [slice-119](../open/slice-119-zusage-ohne-fall-wird-sichtbar.md) — ein Sensor ohne Ende ist derselbe Gegenstand wie ein Lauf ohne Ende, eine Ebene höher |
| `progress_count` degradiert bei einem I/O-Fehler still | die Funktion entsteht in diesem Slice und ist seit dem ersten Code-Commit unverändert (`git diff 6020941 ed81e21 -- harness/tools/mutate.sh \| grep -c 'progress_count'` → **0**) | **als Umgebungs-Eigenschaft ausgewiesen.** Auslöser ist ein Datei-Zugriffsfehler (volle Platte, entzogene Rechte), nicht der Normalbetrieb; die Richtung ist ein Befund, kein stilles Grün |
| Eine Kommentar-Passage steht doppelt in der bats-Datei | `grep -c 'Der Worker-Trap hatte denselben Defekt' test/mutate-driver.bats` → **2** | **diagnostiziert.** Die erste Kopie steht über einem Test, den sie nicht beschreibt; der Zug gehört an die Stelle, die sie anfasst ([`AGENTS.md`](../../../../AGENTS.md) §3.7 Cutoff) |
| `stop_workers` signalisiert auch bereits eingesammelte PIDs | der Bericht-Zweig ruft es genau in diesem Fenster (`sed -n '347,351p' harness/tools/mutate.sh`) | **als Eigenschaft ausgewiesen.** `kill -0` bricht die Frist sofort ab, solange keine PID existiert; die Wirkung einer Wiederverwendung liegt außerhalb dieses Repos und ist nicht herstellbar, ohne sie zu erzwingen |
| Rohe Job-Control-Meldungen der Shell im Bericht (`… Getötet ( worker_main … )`) | erscheint nach dem harten `kill` in `stop_workers` | **als Umgebungs-Eigenschaft ausgewiesen.** Die Zeile schreibt die Shell, nicht der Treiber; sie zu unterdrücken hieße, den harten Kill unsichtbar zu machen |

### Die Laufzeit des Sensors — diagnostiziert, mit Trigger

Ein Sensor, der langsamer wird, senkt seine eigene Auslöse-Häufigkeit; die Zahl steht deshalb neben
ihrem Vorgänger. Nach der Reihe, die [slice-105](../done/slice-105-mutate-messen-dann-teilen.md)
§Messprotokoll führt, kostete der Lauf zuletzt **570,37 s** über **190** Fällen — **3,00 s** je
Fall. Dieser Lauf kostet **751,98 s** (`tail -1` über dem Protokoll) über **198** Fällen
(`ls -1 test/mutations/*.sh | wc -l`) — **3,80 s** je Fall. **Die Fall-Zahl ist mitgewachsen, die
Zeit je Fall nicht mit ihr**, und genau das ist nach jener Tabelle das Kriterium, ab dem eine
wachsende Zahl ein Befund ist.

**Die Ursache ist gemessen und liegt in einer Stufe.** Im Protokoll trägt `test-bats` **52,6 %**
der Fall-Arbeit (n=**56**, Summe **1436,2 s** von **2729,5 s**; beides aus
`sed -n '/Zeit je Sensor/,/Gruen-Vorlaeufe/p'` bzw. `tail -2`), und jeder `test-bats`-Fall fährt die
Stufe vollständig. Die Stufe kostet an diesem Baum **24,53 s** gegen **16,18 s** am Plan-Commit —
beide `docker run --rm --network none -v <baum>:/code:ro -w /code bats/bats@sha256:e8f1… test/` mit
Wanduhr über `date +%s.%N`, der zweite über einem `git worktree` auf `be87307`, **189** gegen
**180** bestandene Fälle. Das sind **+8,35 s** je `test-bats`-Fall und über n=56 rund **468 s**
zusätzliche Fall-Arbeit. Drei der neun neuen bats-Fälle warten auf Wanduhr-Ereignisse, und die zwei
teuersten Fälle des ganzen Laufs sind Fälle dieses Slice: `199` mit **71,87 s** und `202` mit
**52,42 s** (`sed -n '/Zeit je Fall/,$p'` über dem Protokoll). Die zwei Wanduhr-Werte sind
Maschinen- und Cache-Zustände, keine Erwartungswerte
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2); tragend ist die Anteils-Zahl aus dem Protokoll, weil sie beide Seiten im selben Lauf
misst.

**Ausgang: aufgeschoben, mit einem beobachtbaren Auflösungs-Trigger** — nicht abgelehnt und nicht in
diesen Slice zurückgeholt. **Der Trigger: ein `make mutate`-Lauf, dessen Wanduhr geteilt durch seine
Fall-Zahl wieder bei oder unter 3,00 s liegt** — dem Wert, den die Reihe in
[slice-105](../done/slice-105-mutate-messen-dann-teilen.md) §Messprotokoll zuletzt führt. Ein
eigener Schnitt steht dafür heute **nicht**, und das ist eine Entscheidung: schneidbar wird der
Posten erst mit einer Ursache-Hypothese, und die naheliegende ist eine Konstruktions-Frage am
Treiber — ob ein `test-bats`-Fall die **ganze** Stufe fahren muss oder nur die Datei, deren Wächter
seine `# expect:`-Zeile nennt. Wer sie stellt, schneidet gegen die Zahl oben; wer sie nicht stellt,
hat den Posten wenigstens nicht verloren.
### Steering-Loop-Eintrag — neuer Sensor

**Eine neue fail-closed Zusage im Treiber, die kein Fall in `test/mutations/` adressiert, ist heute
von keinem Sensor zu sehen — und genau diese Lage ist in diesem Slice dreimal eingetreten.**

**Der gemessene Anlass.** Die Fix-Runde schloss sechs Befunde durch neuen Code; **drei** der
Reparaturen hatten keinen Fall. Jede einzeln neutralisiert, und die bats-Ebene blieb jedes Mal
vollständig grün (Review-Runde 2: 187 ok / 0 not ok für alle drei; Verifikations-Runde 2 dieselbe
Messung unabhängig). Zwei davon haben in der zweiten Fix-Runde Zähne bekommen (`204`, `205`), die
dritte ist mit dem Rückbau entfallen. **Kein `make mutate`-Lauf hätte das gefunden** — er prüft die
Haltbarkeit der Zähne, die in `test/mutations/` **gelistet** sind, und über eine Stelle ohne Fall
sagt er nichts. [`AGENTS.md`](../../../../AGENTS.md) §3.6 sagt das selbst (*„wer keinen Fall in
`test/mutations/` hat, ist unbewacht"*) — die Regel steht, ihr **Träger** fehlt.

**Warum ein Sensor und keine geschärfte Regel.** Die Regel gibt es. Was fehlt, ist die Stelle, an
der ihre Verletzung sichtbar wird, ohne dass eine zweite Rolle sie sucht. Alle drei Instanzen
dieses Slice sind von einer zweiten Rolle gefunden worden, keine vom schreibenden Lauf.

**Die Fläche, mit ihrer Eigenschaft vor der Zahl.** Die Eigenschaft: *ein bats-Titel, den keine
`# expect:`-Zeile eines Falls nennt*. Über den Bestand gezählt (bats-Titel aus
`grep -h '^@test' test/*.bats | sed 's/^@test *"//; s/" *{ *$//' | sort -u`, `# expect:`-Ziele aus
`grep -h '^# expect:' test/mutations/*.sh | sed 's/^# expect: *//' | sort -u`, verglichen mit
`comm -23`): **167** von **189** Titeln haben keinen Fall, davon **33** von **48** allein in
`test/mutate-driver.bats`. **Ein Maßstab über diesem Bestand wäre dauerhaft rot** und entwertete
die Regel, statt sie zu tragen — dieselbe Begründung, mit der
[`AGENTS.md`](../../../../AGENTS.md) §3.7 seinen Cutoff trägt. Der Sensor braucht deshalb einen
Schnitt, und den zu **entscheiden** ist die Sache des Slice, nicht dieser Notiz.

**Träger: [slice-119](../open/slice-119-zusage-ohne-fall-wird-sichtbar.md)**, neu in `open/`, mit
der Zählung oben als Ausgangslage und dem Schnitt als eigenem DoD-Punkt. Ein Lerneintrag, der nur
hier stünde, würde nie wieder gelesen; der Träger ist der Grund, aus dem dieser Eintrag ein Eintrag
ist und keine Beobachtung.

### Übergabe an den Architect — eine

**[`CO-003`](../../carveouts/done/CO-003-mutate-ohne-zeitschranke.md) Bedingung 1 prüft die Anwesenheit
eines Wortes; ihr Gegenstand ist eine Eigenschaft.** Sie lautet *„`grep -c 'timeout'
harness/tools/mutate.sh` liefert > 0, und die Fundstelle ist die Schranke, die das Warten auf die
Worker begrenzt"*. Gemessen liefert sie an diesem Baum **4** — aus vier Kommentarzeilen, von denen
keine die Schranke ist —, und am Stand des ersten Umsetzungs-Commits lieferte sie **0**, obwohl die
Reparatur da war und der hergestellte Hänger von selbst rot wurde. Die tragende Schranke nennt das
Wort nie: `sed -n '/^await_workers()/,/^}/p' harness/tools/mutate.sh | grep -c 'timeout'` → **0**,
dasselbe über `collect_workers` → **0**. Bedingung 2 misst richtig und ist erfüllt, Bedingung 3
ebenfalls (`grep -rln 'QUEUE_LOCK_TRIES' test/ | wc -l` → **2**).

**Was übergeben wird, ist die Entscheidung, nicht der Text.** Eine Trigger-Änderung an einem
Carveout ist dieselbe Klasse wie der zweite Ausgang, den `CO-003` selbst dem Architect zuweist
(*„Über diesen Ausgang entscheidet der **Architect**"*). Vorbereitet ist sie so weit, dass sie ohne
neue Messung entschieden werden kann: eine Formulierung, die den Gegenstand misst, wäre *„das
Warten auf die Worker steht unter einer Schranke, die den Lauf ohne Zutun von außen beendet —
belegt durch Bedingung 2 und durch einen `test/mutations/`-Fall, der die Verdrahtung entfernt und
den benannten bats-Fall rot färbt"*; beides existiert an diesem Baum (Fall `202`, Wächter
*„driver: das Einsammeln endet OHNE Hilfe von aussen"*). Ob der Carveout danach aufgelöst wird oder
als permanent in eine ADR wandert, entscheidet dieselbe Rolle.

### Folge-Slices und Register

**Zwei neue `open/`-Einträge**, beide ohne Welle
([`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 2 — ihr Zustand ist das Verzeichnis, nicht die Roadmap):

- [slice-118](../open/slice-118-vorwaermlauf-endet-von-selbst.md) — der Hänger im Vorwärmlauf vor
  dem Fork bekommt seinen Träger, mit den zwei Grenzen des Rückbaus als Auflagen: die Schranke misst
  **Fortschritt**, nicht Wanduhr, und der Vorlauf bleibt in der Prozessgruppe des Treibers.
- [slice-119](../open/slice-119-zusage-ohne-fall-wird-sichtbar.md) — der Steering-Loop-Eintrag oben.

**Ein Register-Eintrag.** [`CO-003`](../../carveouts/done/CO-003-mutate-ohne-zeitschranke.md) bleibt
**aktiv** und trägt den Modul-7-Übergang *weiterhin aktiv*: Prüfdatum, Ergebnis in der Geschichte,
Folge-Slice auf [slice-118](../open/slice-118-vorwaermlauf-endet-von-selbst.md) umgestellt. Was der
Slice an seinem Gegenstand geschlossen hat, steht dort mit seinem Kommando; was offen bleibt, ist
die Bedingung, nicht die Sache.

### Gates

Eigener Lauf über dem Baum, den diese Closure hinterlässt: `make gates` **EXIT=0**. Der
Sensor-Lauf, der diesen Baum deckt, meldet **198 ok, 0 Befund(e)** bei `MUTATE_SECONDS=751.98`
(`tail -3` über dem Protokoll) — die Zahl ist eine Messung, keine Schwelle
([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).

## 8. Sub-Area-Modus-Begründung

**Status:** Pflicht-Sektion bei mindestens einer berührten Sub-Area
in BF oder Hybrid. Bei reinem GF genügt der Hinweis
*"alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked
Mini-Example)"*. Optional bei reinem Refactor ohne neue
Sub-Area-Berührung. Die vier Pflichtkriterien (Konventionen-Dichte ·
Phase-Reife · Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand)
stehen in
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Worked Mini-Example](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#worked-mini-example-bootstrap-modus-pro-sub-area-für-einen-slice-begründen).

### Sub-Area: Mutations-Treiber (`harness/tools/` + seine bats-Ebene)

Eine Sub-Area, kein zweiter Block: ein Skript, sein Sensor und sein Fall-Verzeichnis — ein
Gegenstand, eine Frage. Der Carveout und die CI-Zeile sind Register bzw. Aufrufer, keine eigene
Sub-Area.

- **Modus:** GF. Der Treiber ist in diesem Repo entstanden (slice-026) und seither gegen den Kurs
  geführt; es gibt keinen vorgefundenen Bestand, gegen den zu inventarisieren wäre.
- **Konventionen-Dichte:** hoch. [`AGENTS.md`](../../../../AGENTS.md) §3.6 definiert, wofür der
  Treiber da ist, §3.7 bindet den Text seiner Meldungen, §3.5 die Frage *Anhebung oder Senkung*,
  [`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions) seinen
  Auslöser und
  [`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks)
  seine Einbettung in die Sensor-Mechanik.
- **Phase-Reife:** Phase 5 (Betrieb). Der Treiber läuft pro Push über **190** Fällen
  (`ls -1 test/mutations/*.sh | wc -l`), verteilt auf Worker, mit Isolation, Lock und fünf
  fail-closed Bedingungen. Was fehlt, ist keine Reife, sondern ein Ende in zwei Lagen.
- **Evidenz-/Diskrepanz-Risiko:** niedrig. Beide Lagen sind hergestellt und gemessen, nicht
  erschlossen; was offen ist, ist die **Bemessung** der Schranke (Frage B), und das ist eine
  Konstruktions-Entscheidung, keine Inventur-Frage.
- **Reconciliation-Aufwand:** gering für DoD (2) und (3), **offen für DoD (1)** — daran hängt die
  Rückführung `in-progress` → `next` in §4. Graduation-Trigger entfällt; die Sub-Area ist bereits
  GF.
