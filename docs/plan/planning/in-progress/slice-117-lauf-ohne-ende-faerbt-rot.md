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
[`CO-003`](../../carveouts/CO-003-mutate-ohne-zeitschranke.md).

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

- [ ] **(1) Ein Worker, der nicht zurückkommt, färbt den Lauf von selbst rot — innerhalb einer
      Schranke, die der Treiber nennt.** Der Lauf endet ohne Signal von außen, der Bericht benennt
      den Worker und die überschrittene Schranke, und die Schranke steht an **einer** Stelle im
      Treiber (keine zweite Vorgabe im `Makefile` — dieselbe Begründung wie bei `MUTATE_JOBS`).
      **Rot:** ein hergestellter Hänger — ein `make`-Stub, der für genau einen Fall nicht
      zurückkehrt — muss **ohne** `timeout` von außen mit Exit ≠ 0 enden und den Worker benennen.
      Dazu ein `test/mutations/`-Fall, der die Schranke entfernt und den benannten bats-Fall rot
      färbt.
- [ ] **(2) Der Bericht eines abgebrochenen Laufs sagt nichts, was seine eigene
      Fortschritts-Ausgabe widerlegt.** Ein Lauf, der ein Signal bekommt, meldet über die Fälle mit
      Urteil, was gemessen ist, und über die übrigen, dass sie kein Ergebnis haben — nicht *„der
      Lauf hat nichts gemessen"*, während zwei Urteile darüberstehen.
      **Rot:** ein Lauf mit `kill -INT` nach dem ersten Urteil; die Zahl der Fälle mit Ergebnis im
      Bericht steht gegen die Zahl der `OK`/`BEFUND`-Fortschrittszeilen desselben Protokolls.
      Weicht sie ab, ist der Lauf rot. Dazu ein `test/mutations/`-Fall über der Trennung von
      Signal- und EXIT-Zweig.
- [ ] **(3) Jede Zeitschranke des Treibers trägt einen Zahn.** Beide — `QUEUE_LOCK_TRIES` und die
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
| [`docs/plan/carveouts/CO-003-mutate-ohne-zeitschranke.md`](../../carveouts/CO-003-mutate-ohne-zeitschranke.md) | `git mv` nach `done/` **oder** update | DoD (1) ist sein Auflösungs-Trigger; der Move ist ein eigener Commit ([`AGENTS.md`](../../../../AGENTS.md) §3.3), und der Index in [`docs/plan/carveouts/README.md`](../../carveouts/README.md) zieht mit |
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
[`CO-003`](../../carveouts/CO-003-mutate-ohne-zeitschranke.md) ist aufgelöst (`git mv` nach `done/`,
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

<!-- Erst nach Abschluss füllen. -->

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
