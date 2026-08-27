# Slice slice-105: `make mutate` wird erst gemessen, dann geteilt — Zeit je Fall vor jeder Parallelität

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (Sensor-Wartung, reaktiv). Die drei Fragen aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1, hier beantwortet: **(1) Bündel?** Nein — Messung und Teilung landen in **einem** Schnitt,
in dieser Reihenfolge; kein zweiter Slice muss mit ihm landen, damit die Aussage stimmt. **(2)
Gemeinsames Closure-Kriterium?** Nein — jedes denkbare wäre die Abschrift seiner eigenen DoD. **(3)
Auslöser reaktiv oder gewollt?** Reaktiv: eine **gemessene Laufzeit** ist der Anlass, keine neue
Fähigkeit. Der Treiber kann hinterher nichts, was er vorher nicht konnte — er sagt dieselbe Sache
schneller und sagt zusätzlich, wo seine Zeit liegt. Nach
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 2 steht wellenlose Arbeit **nicht** in der Roadmap; ihr Zustand ist das Verzeichnis.

**Ebene: Dogfood, nicht emittiert — gemessen, nicht behauptet.**
`grep -rln 'mutate' internal/emit/templates/ | wc -l` → **0**;
[`harness/tools/mutate.sh`](../../../../harness/tools/mutate.sh) geht in kein Zielrepo. Was hier
entsteht, ändert am Adopter-Vertrag nichts.

**Bezug:**
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (`make mutate` **ist** der Feedback-Teil dieser Regel — er
prüft die Haltbarkeit der Zähne. Ein Sensor, der seine eigene Aussage verliert, nimmt jede darauf
gestützte Zusage mit),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (die
Klasse, gegen die die Auflage in §1 gerichtet ist: eine parallele Fassung, die einen Shard verliert
und **still grün** meldet, ist der behauptete Gate in Reinform — hier auf der Dogfood-Ebene,
weshalb die Anforderung als **Analogie** benannt und nicht als Bezug beansprucht wird),
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (dieselbe Fall-Menge muss
dasselbe Verdikt liefern, gleich über wie viele Shards sie läuft),
[`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions) (CI fährt
`make mutate` pro Push auf frischem Klon — die Laufzeit wird **je Push** bezahlt, und das ist der
Grund, aus dem sie überhaupt ein Gegenstand ist),
[`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks) (die
Sensor-Mechanik dieses Repos),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben ihrem Kommando und wandert mit ihrem Bestand),
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
(Verortung).

**Autor:** Planner. **Datum:** 2026-08-25.

---

## 1. Ziel

**`make mutate` sagt, wo seine Zeit liegt — je Fall und gruppiert nach Sensor —, und erst diese
Messung entscheidet, ob geteilt oder die Sensor-Stufe korrigiert wird.**

Der Umbau ist nicht der Lieferwert; die Aufschlüsselung ist es. Ohne sie ist jede Wahl zwischen
*Sharding* und *Tier-Korrektur* geraten.

### Was heute gemessen vorliegt — und was nicht

**Vorliegend, eigen erhoben** (jede Zahl mit ihrem Kommando, alle mitwandernd):

| Größe | Wert | Kommando |
|---|---|---|
| Fälle insgesamt | **176** | `ls -1 test/mutations/*.sh \| wc -l` |
| Fälle mit **eigenem** `# verify:`-Kopf | **27** | `grep -l '^# verify:' test/mutations/*.sh \| wc -l` |
| davon auf `full-smoke` | **4** | `grep -l '^# verify: full-smoke' test/mutations/*.sh \| wc -l` |
| Modi des Grün-Vorlaufs | **6** (`ci-lint`, `full-smoke`, `smoke`, `test`, `test-bats`, `test-go`) | `{ echo test; sed -n 's/^# verify: //p' test/mutations/*.sh; } \| LC_ALL=C sort -u` |
| Zeilen des Treibers | **566** | `wc -l < harness/tools/mutate.sh` |

**Die übrigen 149 Fälle bekommen ihren Sensor zur Laufzeit** aus dem `# expect:`-Kopf
(`narrow_sensor` in [`harness/tools/mutate.sh`](../../../../harness/tools/mutate.sh): leer oder
mehrzeilig → `test`, `Test[A-Z]*` → `test-go`, sonst → `test-bats`). Die Abbildung ist **statisch
nachrechenbar**, und nachgerechnet ergibt sie die Fall-Verteilung: **132** `test-go` · **38**
`test-bats` · **4** `full-smoke` · **1** `smoke` · **1** `ci-lint` (Summe **176**; die Schleife über
`test/mutations/*.sh`, die je Fall den eigenen `# verify:`-Kopf nimmt und sonst `narrow_sensor`
nachbildet, steht in §3 als Ausgangspunkt der Messung).

**Die Zeit je Sensor liegt vor, die Zeit je Fall nicht.** Der Stückpreis jedes Sensors ist eigen
erhoben — jedes Ziel zweimal hintereinander im Repo gefahren und der **zweite** Wert genommen, weil
`mutate` denselben Sensor wiederholt in derselben Kopie ruft und damit den eingeschwungenen Preis
mit warmem Docker-Cache zahlt, nicht den ersten mit kaltem Build:

| Sensor | s je Lauf | Kommando |
|---|---|---|
| `ci-lint` | **0,5** | `for i in 1 2; do s=$(date +%s%N); make ci-lint >/dev/null 2>&1; echo $(( ($(date +%s%N)-s)/1000000 ))ms; done` |
| `test-go` | **5,5** | dasselbe mit `make test-go` |
| `test-bats` | **8,7** | dasselbe mit `make test-bats` |
| `smoke` | **10,1** | `/usr/bin/time -f '%e' make smoke` |
| `full-smoke` | **88,3** | `/usr/bin/time -f '%e' make full-smoke` (81,78 und 94,91; Mittel) |

Über die Fall-Verteilung ergibt das die **Zeit-Verteilung**, und sie beantwortet die Frage, die
dieser Abschnitt stellt:

| Sensor | Fälle | Summe s | Anteil |
|---|---|---|---|
| `test-go` | 132 | 726 | **51 %** |
| `full-smoke` | 4 | 353 | **25 %** |
| `test-bats` | 38 | 331 | **23 %** |
| `smoke` | 1 | 10 | 1 % |
| `ci-lint` | 1 | 0 | 0 % |

**Vier von 176 Fällen tragen ein Viertel der Zeit** — ein `full-smoke`-Fall kostet so viel wie
sechzehn `test-go`-Fälle. Damit ist Frage A entschieden: **Teilung nach Sensor allein genügt
nicht**, denn 132 Fälle blieben in einem Shard. Und Tier-Korrektur allein genügt ebenso wenig, denn
die 132 `test-go`-Fälle tragen die andere Hälfte. Der Hebel ist die **dynamische Zuweisung an
Worker** mit einer Warteschlange, die **absteigend nach Stückpreis** sortiert ist — was hier
dasselbe ist wie nach Sensor gruppiert, weil der Preis je Sensor konstant ist. Die teuersten Fälle
starten zuerst und hängen nicht am Ende nach.

Das Modell trifft den realen Lauf auf **88 %**: modelliert **1420** s gegen gemessene **1252,6** s
(`/usr/bin/time -f 'MUTATE_SECONDS=%e' make mutate` über **176** Fälle). Die Differenz ist die
Sicherung und Wiederherstellung je Fall plus der wärmere Cache in der isolierten Kopie. Die frühere
Angabe von **1166,43** s galt für **157** Fälle und ist fremdbelegt aus der
[Verifikation zu slice-097](../../../reviews/2026-08-25-slice-097-verify.md) §1.1 — beide Zahlen
sind Maschinen- und Cache-Zustände, keine Erwartungswerte.

**Was weiterhin fehlt: die Zeit je *Fall*.** Der Stückpreis ist je Sensor erhoben, nicht je Fall —
ein einzelner Ausreißer **innerhalb** eines Sensors bliebe darin unsichtbar. DoD (1) baut die
Zeitnahme in den Treiber, und wer sie baut, prüft zuerst, ob die gemessene Verteilung mit dieser
modellierten übereinstimmt; tut sie es nicht, ist eine der beiden falsch, und das ist ein Befund
vor jeder Teilung.

### Die Reihe über die Worker-Zahlen — gemessen an einem Prototyp

Erhoben an einer Wegwerf-Kopie des Repos auf dem Stand `1213edb` (**165** Fälle), mit einem
Treiber, der die Fälle **dynamisch** aus einer gemeinsamen Warteschlange an N Worker gibt.
Alle vier Punkte aus **einem** Fenster; jeder Punkt ist ein vollständiger Lauf und endete
`165 ok, 0 Befund(e)`.

| N | Wanduhr | Beschleunigung | Load Mittel/Max | Fremdlast-Proben | Exit |
|---|---|---|---|---|---|
| 1 | **1164,0 s** | 1,00× | 8,7 / 15,9 | 4/73 | 0 |
| 4 | **438,3 s** | **2,66×** | 26,4 / 38,6 | 11/27 | 0 |
| 6 | **406,5 s** | 2,86× | 40,1 / 55,0 | 19/25 | 0 |
| 8 | **381,6 s** | 3,05× | 43,9 / 69,9 | 19/23 | 0 |

Kommando je Punkt: `/usr/bin/time -f '%e' make mutate` mit gesetzter Worker-Zahl, die
Fremdlast-Proben über das Arbeitsverzeichnis fremder Prozesse
(`readlink -f /proc/<pid>/cwd`). Die Fremdlast war durchweg ein anderes Repo auf demselben
Docker-Daemon; sie wächst über die Reihe und bremst die **späteren** Punkte, verkleinert die
gezeigte Beschleunigung also.

**Die Empfehlung ist N=4.** N=6 und N=8 liegen 6–7 % darunter, und das ist die Größenordnung
zweier Wiederholbarkeiten; N=8 bringt bei doppelter Worker-Zahl **13 %**.

**Warum die Beschleunigung bei 2,66× steht und nicht bei 4:** die Arbeit war nie sequentiell.
Ein *einzelner* Worker erzeugt schon Load **8,7** auf **20** Kernen (`nproc` → 20), denn
`make test-go` fährt `go test ./...` über **7** Pakete
(`find . -name '*.go' -not -path './.harness/*' -printf '%h\n' | sort -u | wc -l` → 7), und
die Go-Werkzeugkette übersetzt und testet nebenläufig. Daraus folgt die Sättigungsgrenze
direkt: 20 ÷ 8,7 ≈ **2,3** Worker. Wir fügen keine Parallelität hinzu, wir verteilen
vorhandene um.

**Die Fall-Arbeit wächst dabei um Faktor 2,5** (1048,7 s bei N=1 auf 2611,7 s bei N=8);
`test-go` steigt je Fall von 5,34 s auf 16,96 s. Die Effizienz fällt auf **34 %**.

| Sensor | N=1 | N=4 | N=6 | N=8 |
|---|---|---|---|---|
| `test-go` (122 Fälle) | 5,34 | 8,92 | 12,91 | 16,96 |
| `test-bats` (38) | 8,92 | 9,87 | 10,60 | 10,48 |
| `full-smoke` (3) | 18,65 | 24,08 | 38,75 | 46,21 |
| Fall-Arbeit gesamt | 1048,7 | 1540,3 | 2100,0 | 2611,7 |
| Vorlauf-Summe | 104,2 | 164,9 | 251,5 | 311,3 |

**Der Umbau selbst kostet nichts.** N=1 mit dem neuen Treiber: 1164,0 s über 165 Fälle =
**7,05 s je Fall**. Der alte sequentielle Treiber: 1252,6 s über 176 Fälle = **7,12 s je
Fall**. Warteschlange, Mutex und Zeitnahme sind innerhalb der Messgenauigkeit gratis — dafür
war der N=1-Punkt als Kontrolle da.

**Zwei untere Schranken, und die zweite bindet früher.** Der längste Einzelfall dauert
**46,00 s** (`152-cpp-lint-schichtfilter`) — nicht die 88 s eines *grünen* `full-smoke`-Laufs,
weil ein Fall, der rot werden soll, am getroffenen Wächter abbricht. Die härtere Schranke ist
die **serielle Spur**: 152,8 s bei N=1, 290,5 s bei N=8 — dort sind das **76 %** der Wanduhr.

**Die serielle Spur ist eine Korrektheits-Auflage, keine Bequemlichkeit.** `smoke`,
`full-smoke` und `gates` laufen über `make artifact`, und `artifact-copy.sh` holt das Binär
mit `docker create`/`docker cp` **aus** dem Tag `ai-harness-init:build`, also **nach** dem Bau.
Zwei gleichzeitige Läufe über verschieden mutierten Bäumen könnten einander das Binär
unterschieben — stilles Grün. Diese Modi laufen darum seriell.

**Ein Trockenlauf-Kriterium dafür genügt nicht**, und das ist gemessen:
`make -n smoke | grep -c artifact-copy.sh` → **0**, obwohl `smoke.sh:37` `make artifact`
**innen** ruft; `make -n` endet bei `bash harness/tools/smoke.sh`. Das Kriterium meldete
ausgerechnet für die zwei gefährlichsten Modi „sicher". Die Zuordnung muss den
Treiberskripten eine Ebene tief folgen und fail-closed sein.

**Offen, nicht gemessen: die Begrenzung je Worker.** Weder `GOMAXPROCS` noch `--cpus`/`cpuset`
noch `-p` an `go test` sind gesetzt (`grep -rn 'GOMAXPROCS' Dockerfile Makefile harness/mk/*.mk`
→ leer) — jeder Container sieht alle 20 Kerne und verhält sich, als gehöre ihm die Maschine.
Ob eine Begrenzung auf 20 ÷ N Kerne die Wanduhr senkt oder nur die Last glättet, ist offen; die
Gesamtarbeit bleibt gleich.

**Ein flakiger Fall wird durch Parallelisierung flakiger.** In einem verworfenen Fenster meldete
N=8 `152-cpp-lint-schichtfilter` als *„make full-smoke blieb GRUEN — hat keine Zaehne mehr"*.
Kein Tag-Rennen, sondern der bekannte Nichtdeterminismus unter Last verschärft; im sauberen
Fenster grün. Das schärft die Reihenfolge-Bedingung aus §4: Parallelität macht den offenen
Befund nicht nur schwerer zuordenbar, sondern **häufiger**.

**Ein zweiter Störer neben der Fremdlast: die Cache-Verdrängung.** Der Docker-Zustand am Ende
der Reihe: **372** Images / **109,9 GB** (76 % verwaist), Build-Cache **2161** Einträge /
**63,91 GB** (`docker system df`). Ein gestörter `full-smoke`-Lauf verlor **91** `CACHED`-Treffer
bei *weniger* gebauten Bildern (315 → 224 bei 52 → 50) — BuildKits Garbage Collection verdrängt
unter Druck. Messpunkte unter verschiedenem Cache-Zustand sind darum nicht ohne Weiteres
vergleichbar; für diese Reihe wurde derselbe N in zwei Fenstern gegengeprüft und der Unterschied
lag bei 3–4 %, also weit unter dem N=1→N=4-Effekt.

### Der Aufschlag ist Verdrängung, nicht Aufteilung — und damit ist die Begrenzung je Worker die nächste Frage

Rechnet man aus Wanduhr je Fall und mittlerer Last die **Kern-Sekunden je Fall** zurück
(Last ÷ Worker-Zahl als Verbrauch je Worker, mal Wanduhr je Fall), ergibt die Reihe:

| N | s/Fall (`test-go`) | Load Mittel | Load je Worker | Kern-s je Fall | Aufschlag |
|---|---|---|---|---|---|
| 1 | 5,34 | 8,7 | 8,70 | **46,5** | 0 % |
| 4 | 8,92 | 26,4 | 6,60 | **58,9** | **+27 %** |
| 6 | 12,91 | 40,1 | 6,68 | **86,3** | **+86 %** |
| 8 | 16,96 | 43,9 | 5,49 | **93,1** | **+100 %** |

**Das unterscheidet zwei Erklärungen, die bis hierher gleich aussahen.** Wäre der
Effizienzverlust bloße **Aufteilung** — dieselbe Arbeit, auf mehr Worker verteilt —, blieben
die Kern-Sekunden je Fall konstant bei 46,5. Sie tun es nicht: Bei N=8 kostet derselbe Fall
**doppelt so viel Rechenzeit** wie bei N=1. Der Aufschlag ist also **Verdrängung** —
CPU-Caches, Kontextwechsel, Speicherbandbreite —, und Verdrängung ist im Gegensatz zu
Aufteilung angreifbar.

**Die obere Schranke des Gewinns**, falls eine Begrenzung den Aufschlag vollständig beseitigte:

| N | heute | Schranke | weiterer Gewinn |
|---|---|---|---|
| 4 | 438,3 s | 345,9 s | 21 % |
| 6 | 406,5 s | 218,9 s | 46 % |
| 8 | 381,6 s | 190,5 s | 50 % |

**Drei Vorbehalte, die diese Rechnung nicht trägt** — sie ist ein Modell aus gemessenen Zahlen,
keine Messung:

1. **Die Load ist kein CPU-Verbrauch.** Sie zählt auch Prozesse im ununterbrechbaren Warten auf
   Ein-/Ausgabe, und Docker-Builds tun viel davon. „Kern-Sekunden" ist hier ein Schätzer nach
   oben.
2. **Eine Kern-Begrenzung beseitigt nur einen Teil.** Speicherbandbreite teilen sich die Worker
   weiterhin; `GOMAXPROCS` ändert daran nichts.
3. **Sie kostet auch etwas.** Zwischen zwei Fällen sichert und stellt ein Worker wieder her — in
   dieser Zeit läge Kapazität brach, die er heute an die Nachbarn abgibt.

**Das Experiment ist billig und gehört zu DoD (1):** ein Build-Argument, das `GOMAXPROCS` auf
20 ÷ N setzt (heute ist nichts gesetzt — `grep -rn 'GOMAXPROCS' Dockerfile Makefile harness/mk/*.mk`
ist leer, jeder Container sieht alle Kerne), dann dieselbe Reihe erneut. Vier Läufe, und die
Kern-Sekunden-Spalte sagt danach, welcher Anteil wirklich Verdrängung war.

### Messprotokoll — jeder Lauf mit seiner Zeit

Eine Momentaufnahme sagt nicht, ob die Laufzeit wächst. Diese Tabelle wird bei **jedem**
gemessenen `mutate`-Lauf um eine Zeile ergänzt; jede Zeile nennt ihre Quelle, damit sie
nachprüfbar bleibt. Die Zeiten sind Maschinen- und Cache-Zustände, **keine Erwartungswerte** —
eine wachsende Zahl ist erst dann ein Befund, wenn die Fall-Zahl nicht mitgewachsen ist.

| Datum | Fälle | Treiber | N | Wanduhr | s/Fall | Quelle |
|---|---|---|---|---|---|---|
| 2026-08-25 | 157 | sequentiell | 1 | 1166,43 s | 7,43 | Verifikation `slice-097` §1.1 |
| 2026-08-26 | 176 | sequentiell | 1 | 1252,55 s | 7,12 | Umsetzung `slice-098` |
| 2026-08-26 | 176 | sequentiell | 1 | 1199 s | 6,81 | Verifikation `slice-098` |
| 2026-08-26 | 165 | sequentiell | 1 | 1214,5 s | 7,36 | Prototyp-Quervergleich (Fremdlast, nicht Teil der Reihe) |
| 2026-08-26 | 165 | **dynamisch** | 1 | **1164,0 s** | 7,05 | Prototyp, Reihe, Kontrollpunkt |
| 2026-08-26 | 165 | **dynamisch** | 4 | **438,3 s** | 2,66 | Prototyp, Reihe |
| 2026-08-26 | 165 | **dynamisch** | 6 | 406,5 s | 2,46 | Prototyp, Reihe |
| 2026-08-26 | 165 | **dynamisch** | 8 | 381,6 s | 2,31 | Prototyp, Reihe |
| 2026-08-26 | 179 | sequentiell | 1 | 1326,26 s | 7,41 | Verifikation `slice-099` §1.1 |

Kommando für jede Zeile: `/usr/bin/time -f 'MUTATE_SECONDS=%e' make mutate`, die Fall-Zahl aus
`ls -1 test/mutations/*.sh | wc -l`. Die Spalte `s/Fall` ist Wanduhr ÷ Fälle und dient nur dem
Vergleich zwischen Läufen verschiedener Bestandsgröße.

**Was die Reihe über die Zeit zeigt und eine Momentaufnahme nicht gezeigt hätte:** Der Preis
**je Fall** liegt bei allen sequentiellen Läufen zwischen 6,81 und 7,43 s — er ist über zwei
Tage und **vier** Bestandsgrößen **stabil**. Die Wanduhr wuchs von 1166 über 1253 auf 1326 s
allein deshalb, weil der Bestand von 157 über 176 auf 179 Fälle wuchs. Ohne diese Tabelle wäre das
Wachstum als Verschlechterung lesbar gewesen; mit ihr ist es die erwartete Folge von mehr
Abdeckung.

**Die jüngste Zeile prüft die Aussage, statt sie zu bestätigen — und sie trägt.** 7,41 s je Fall
liegt **innerhalb** des seit zwei Tagen genannten Bandes, nicht an seiner Kante darüber hinaus:
das Band bleibt **unverändert** 6,81 bis 7,43 s, seine Obergrenze steht weiter beim ältesten Lauf
(2026-08-25, 157 Fälle). **Was die Zeile nicht liefert, ist die Aufschlüsselung nach Sensor** —
der Treiber protokolliert je Fall nur `ok <name> -> <expect> rot`, keine Dauer; die Klippe aus
§Der Bauplan bleibt damit ungemessen und die Teilung nach Sensor eine Konstruktions-Entscheidung,
keine Messfolge.

**Und der Kontrollpunkt trägt:** der dynamische Treiber bei N=1 kostet 7,05 s je Fall und liegt
damit mitten im Band der sequentiellen Läufe. Der Umbau ist gratis, die Beschleunigung kommt
allein aus der Parallelität.

### Der Bauplan, soweit er gemessen ist

Aus [`harness/tools/mutate.sh`](../../../../harness/tools/mutate.sh) selbst gelesen:

- **Die Isolation existiert schon.** `prepare_isolation` kopiert den Baum per `tar` **außerhalb**
  des Repos (`--exclude=./.harness/state`), `require_isolated` bricht fail-closed ab, wenn `WORK`
  leer ist oder im Repo liegt. Eine zweite Kopie kostet dieselbe Mechanik, keine neue.
- **`run_case` ist unabhängig.** Sicherung → Mutation → Fingerabdruck-Prüfung, dass sie griff →
  `make $verify` → Abgleich gegen das Fehlschlag-Muster → `restore`. Zwischen zwei Fällen wandert
  kein Zustand; die Reihenfolge ist ohne Bedeutung.
- **Die Klippe ist `green_prerun`.** Er belegt: *der Sensor war grün, **bevor** mutiert wurde* —
  ohne ihn wäre ein rot gewordener Fall nicht von einem ohnehin roten Baum zu unterscheiden, und
  genau das sagt seine Abbruch-Meldung. Teilt man **nach Fall-Anzahl**, zahlt jeder Shard den
  Vorlauf für jeden Sensor, den seine Fälle brauchen — oder man glaubt ihn über Kopien hinweg,
  und dann ist die Aussage nur noch ungefähr richtig. **Nach Sensor teilen hält sie exakt:** ein
  Vorlauf je Shard, für genau dessen Sensor, in genau dessen Kopie. Die Zahl der Vorläufe bleibt
  dabei die heutige.
- **Docker ist die geteilte Ressource, und der Treiber weiß das bereits.** Sein `LOCK` in `main()`
  trägt genau diese Begründung: zwei Läufe *„bauen dieselben Docker-Image-Tags … und würden
  einander die Tags und den Build-Cache unter den Füßen wegziehen"*. Eine parallele Fassung, die
  den Bau **nicht einmal vor dem Fork** erledigt, tauscht Laufzeit gegen Tag-Rennen — der Lock ist
  die vorweggenommene Diagnose, nicht ein Hindernis.
- **Der Treiber verweigert schon heute das leere Set.** `main()` bricht ab, wenn `test/mutations/`
  leer ist: *„ein leeres Set ist kein gruener Lauf"*. Genau diese Eigenschaft muss auf **Shards**
  ausgedehnt werden — sonst entsteht sie neu, eine Ebene höher.

### Die Auflage, die nicht verhandelbar ist

**`make mutate` ist der Sensor der Sensoren.** Eine parallele Fassung, die still grün meldet, wäre
der schlimmste Fehler in diesem Repo: sie entwertete jede Zusage, die auf einem rot gesehenen
Gegenbeispiel ruht ([`AGENTS.md`](../../../../AGENTS.md) §3.6). Daraus folgen zwei Bedingungen, und
sie stehen **vor** jeder Laufzeit-Aussage:

1. **Der zusammengeführte Bericht belegt, dass er jeden Fall gefahren hat** — die berichtete
   Fall-Zahl gegen `ls -1 test/mutations/*.sh | wc -l`, fail-closed bei Abweichung.
2. **Ein absichtlich kaputter Shard ist einmal rot gesehen worden**, bevor die parallele Fassung
   als Sensor gilt. Ein Shard, der abstürzt, hängt oder nichts meldet, muss den Gesamtlauf **rot**
   färben — nicht ihn verkürzen.

## 2. Definition of Done

Drei slice-eigene Punkte, jeder mit dem Kommando, das ihn **rot** färbt (Modul 5 §Ziel-Form: ≤ 3;
[`AGENTS.md`](../../../../AGENTS.md) §3.6). **Der erste ist die Messung, nicht der Umbau** — er
liegt vor den anderen beiden, und die Reihenfolge ist Teil der Zusage.

- [ ] **(1) Der Lauf schlüsselt seine Zeit auf: je Fall, gruppiert nach Sensor — und er nennt
      seinen Nenner.** Die Ausgabe trägt je Fall eine Dauer und je Sensor eine Summe samt Anteil an
      der Gesamtzeit; die Zahl der aufgeschlüsselten Fälle steht neben der Zahl der Fälle auf der
      Platte.
      **Rot:** der Lauf selbst — weicht die Summe der aufgeschlüsselten Fälle von
      `ls -1 test/mutations/*.sh | wc -l` ab, bricht er ab, statt eine unvollständige Bilanz
      auszugeben. Dazu ein `test/mutations/`-Fall, der die Aufschlüsselung um einen Fall kürzt.
- [ ] **(2) Geteilt wird nach Sensor, und der Grün-Vorlauf bleibt exakt.** Je Shard **ein** Vorlauf,
      für genau dessen Sensor, in genau dessen Kopie; das Docker-Bild entsteht **einmal vor** dem
      Fork. Kein Shard glaubt einer fremden Kopie ihr Grün.
      **Rot:** ein Shard, dessen Sensor in seiner eigenen Kopie **ohne** Mutation rot ist, bricht
      ab und sagt es — nachgestellt, indem in der Kopie eines Shards der Sensor vorab rot gemacht
      wird. Der Gesamtlauf darf das nicht als Befund eines Falls ausgeben.
- [ ] **(3) Der zusammengeführte Bericht ist vollständig oder rot — nie still grün.** Die berichtete
      Fall-Zahl steht gegen `ls -1 test/mutations/*.sh | wc -l`; ein Shard, der abstürzt, hängt oder
      nichts meldet, färbt den Gesamtlauf rot.
      **Rot:** ein absichtlich kaputter Shard, **einmal gefahren und rot gesehen** — die Bedingung
      aus §1, ohne die die parallele Fassung nicht als Sensor gilt. Dazu ein `test/mutations/`-Fall,
      der die Zusammenführung um einen Shard bringt.

Standard-Punkte der Vorlage (nicht slice-eigen): `make gates` grün · `make mutate` ohne Befund ·
Doku-Update, falls ein öffentlicher Vertrag berührt ist · Closure-Notiz mit
Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`harness/tools/mutate.sh`](../../../../harness/tools/mutate.sh) | update | Zeitnahme je Fall und Bilanz je Sensor (DoD 1); danach die Teilung (DoD 2) und die Zusammenführung mit Vollständigkeits-Nachweis (DoD 3). **Der `LOCK` in `main()` wird nicht entfernt, sondern verstanden:** seine Begründung ist die geteilte Docker-Ressource, und die verschwindet durch Parallelität nicht — sie wird zur Bedingung *„Bild einmal vor dem Fork"* |
| [`Makefile`](../../../../Makefile) | update, **falls** Frage B so ausgeht | nur wenn die Shard-Zahl von außen gesetzt werden soll. Ein Ziel ohne Vorgabe muss weiter laufen und dasselbe Verdikt liefern ([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)) |
| [`test/mutate-driver.bats`](../../../../test/mutate-driver.bats) | update | der Treiber hat bereits eine bats-Ebene über seinen Funktionen (sie sourct die Datei); die neuen Funktionen — Zeitnahme, Shard-Bildung, Zusammenführung — gehören dorthin, nicht in einen zweiten Sensor |
| `test/mutations/` <!-- d-check:ignore (geplante Dateien) --> | neu | die drei Zähne aus DoD (1)–(3); Nummern im Anschluss an die höchste vergebene (`ls -1 test/mutations/*.sh \| wc -l` → **157**, beim Anlegen neu auszuzählen) |
| [`.github/workflows/ci.yml`](../../../../.github/workflows/ci.yml) | update, **falls** Frage C so ausgeht | die CI ruft ausschließlich `make`-Targets ([`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions)); eine zweite Gate-Definition im Workflow wäre der Defekt, nicht die Lösung |
| [`harness/README.md`](../../../../harness/README.md) und [`AGENTS.md`](../../../../AGENTS.md) | update | beide beschreiben `make mutate` als **einen** Lauf gegen **eine** isolierte Kopie. Nach diesem Slice ist das falsch, und der Satz wird gezogen, nicht danebengestellt. **Der Hard-Rules-Block und der Adaptions-Block bleiben unberührt** — sie gehören dem Architect ([`AGENTS.md`](../../../../AGENTS.md) §3.8, [`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1); berührt ist §4, die Gate-Beschreibung |
| [`docs/plan/adr`](../../adr) | **unverändert** | die Änderung **hebt** keine Schwelle und senkt keine: dieselbe Fall-Menge, dasselbe Verdikt, andere Anordnung. Zeigt der Lauf, dass die Aussage des Grün-Vorlaufs schwächer wird, ist das eine **Senkung** und braucht ein ADR ([`AGENTS.md`](../../../../AGENTS.md) §3.5) — dann greift die Rückführung aus §4 |
| [`docs/plan/planning/in-progress/roadmap.md`](../in-progress/roadmap.md) | **unverändert** | wellenlose Arbeit wird dort nicht geführt ([`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird) Setzung 2/3) |

**Der Ausgangspunkt der Messung steht hier, nicht im Lauf.** Die statische Sensor-Zuordnung je Fall
ist heute schon berechenbar — je Fall der eigene `# verify:`-Kopf, sonst die Nachbildung von
`narrow_sensor` über dem `# expect:`-Kopf; das Ergebnis (115 · 38 · 2 · 1 · 1) steht in §1. Was
DoD (1) hinzufügt, ist die **Dauer**. Wer die Aufschlüsselung baut, prüft zuerst, ob seine
Laufzeit-Zuordnung mit dieser statischen übereinstimmt; tut sie es nicht, ist eine der beiden
falsch, und das ist ein Befund vor jeder Teilung.

**Offen, vor dem Code zu entscheiden:**

| # | Frage | Warum sie den Schnitt entscheidet |
|---|---|---|
| A | **Wird innerhalb eines Sensors weiter geteilt?** | Nach Sensor allein ergibt Shards von **115** und von **1** — die Teilung wäre exakt und **unausgewogen**; der größte Shard bestimmte die Laufzeit weiter. Eine zweite Ebene *innerhalb* eines Sensors kostet je Unter-Shard einen weiteren Vorlauf **desselben** Sensors — die Aussage bleibt exakt, der Preis ist zählbar. Ob er sich lohnt, sagt die Messung aus DoD (1) und **nur** sie |
| B | **Woher kommt die Shard-Zahl?** | Fest im Skript, aus einer `make`-Variablen oder aus der Kern-Zahl der Maschine. Eine Vorgabe von außen macht das Ergebnis von der Umgebung abhängig — dann muss DoD (3) auch für die Ein-Shard-Einstellung gelten, sonst gibt es eine Konfiguration, in der der Sensor nie vollständig geprüft wurde |
| C | **Fährt die CI dieselbe Aufteilung wie ein lokaler Lauf?** | Vier Runner mit je einem Kern verhalten sich anders als ein Host. Zwei Aufteilungen heißen zwei Verhalten und damit zwei Sensoren — [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) verlangt dasselbe Verdikt, nicht dieselbe Laufzeit; die Frage ist, wo die Grenze zwischen beidem gezogen wird |

## 4. Trigger

**Beginn (`open` → `next`): nichts blockiert die Messung.** DoD (1) fügt dem Treiber Zeitnahme und
Bilanz hinzu und ändert an seiner Anordnung nichts; sie ist ohne Vorbedingung lieferbar, und sie ist
der Grund, aus dem dieser Slice existiert.

### Die Reihenfolge-Bedingung — sie steht hier, nicht als Nebensatz

**DoD (2) und (3) beginnen erst, wenn der offene Befund an `make full-smoke` einen Ausgang hat.**
Der Befund: `make full-smoke` ist in der CI rot geworden, während derselbe Sensor im **selben** Lauf
an anderer Stelle grün war — am 2026-08-25 im Job `full-smoke` rot und im Grün-Vorlauf des
`mutate`-Jobs grün, am 2026-08-25 zuvor genau umgekehrt. **Getroffen hat das Go-Hexagonal-Modul**
(`test-apps-hex` und `lint-apps-hex`), nicht das C++-Modul; dessen Bilder wurden im selben Protokoll
fertig gebaut. Die Ursache im belegten Fall ist eine ausgehende Anfrage, die nicht mit 2xx
beantwortet wurde. Träger des Befundes ist
[slice-106](../done/slice-106-rotes-ci-traegt-seinen-ausgang.md); dort stehen die Messungen mit ihren
Kommandos.

**Warum das die Reihenfolge bestimmt und nicht bloß unangenehm ist.** Parallelität fügt diesem
Werkzeug eine zweite Quelle von Fehlschlägen hinzu, die nicht am geprüften Baum liegen. Zieht man
sie hinein, bevor die erste einen Ausgang hat, ist der nächste Fehlschlag nicht mehr zuordenbar: er
kann aus einer fremden Leitung kommen oder aus einem Shard-Rennen, und beide Hypothesen kosten dann
je einen eigenen Diagnose-Lauf über einem Sensor, der über **20** Minuten braucht. Ein Sensor,
dessen Fehlschläge niemand mehr zuordnen kann, wird abgeschaltet oder ignoriert — beides ist teurer
als das Warten.

**Beobachtbar, ohne Rückfrage entscheidbar: der Befund trägt einen der vier Ausgänge** —
**diagnostiziert** (Ursache benannt, mit Sensor oder Grenze) · **als Umgebungs-Eigenschaft
ausgewiesen** (nicht der Baum, sondern der Runner; mit dem Beleg dafür) · **abgelehnt** mit Grund ·
**aufgeschoben** mit einem Auflösungs-Trigger, der ein beobachtbares Ereignis nennt. Dieselbe
Ausgangs-Menge, die [slice-101](slice-101-norm-postens-bekommen-einen-termin.md) für offene Postens
setzt — und aus demselben Grund: *„genannt"* ist keiner davon.

**Delta zum Abnahme-Kriterium (2026-08-26), ausgewiesen statt eingearbeitet.** Der Ausgang
*„als Umgebungs-Eigenschaft ausgewiesen"* ist oben mit *„nicht der Baum, sondern der Runner"*
erläutert. Gemessen ist die Umgebung im belegten Fall **nicht der Runner**, sondern eine
**ausgehende HTTP-Abhängigkeit**: die Jobs `gates` und `smoke` desselben Laufs lösten dasselbe
gepinnte Bild fehlerfrei auf, also lag es nicht an der Maschine. Der **Umfang** des Ausgangs bleibt
unverändert — er verlangt weiterhin den Beleg statt der Plausibilität; verschoben ist nur, worauf
der Beleg zeigen darf. Wer das Kriterium anwendet, wendet die weitere Fassung an:
*nicht der geprüfte Baum, sondern die Umgebung des Laufs — Maschine oder Leitung —, mit dem Beleg
dafür.* Die Messungen stehen in
[slice-106](../done/slice-106-rotes-ci-traegt-seinen-ausgang.md) §1.

**Ist die Bedingung beim Erreichen von DoD (1) nicht erfüllt, greift `in-progress` → `next`:** der
Slice wird in Messung und Teilung zerschnitten, die Messung landet in `done/`, die Teilung wartet.
Das ist die reguläre Rückführung, kein Scheitern — und sie ist der Grund, warum die Messung als
**erster** DoD-Punkt steht und nicht als Vorarbeit im Fließtext.

**Die zweite Rückführung, `in-progress` → `open` (blockiert):** wenn sich zeigt, dass eine tragfähige
Teilung die Aussage des Grün-Vorlaufs **schwächen** müsste — etwa weil sie ihn über Kopien hinweg
glauben muss. Das ist eine Schwellen-**Senkung** und braucht ein ADR
([`AGENTS.md`](../../../../AGENTS.md) §3.5); der Slice wartet darauf, statt die Schwäche im Skript
zu verstecken.

## 5. Closure-Trigger

DoD (1)–(3) erfüllt mit gefahrenen Kommandos; die Aufschlüsselung liegt vor und ihr Nenner steht
neben `ls -1 test/mutations/*.sh | wc -l`; der absichtlich kaputte Shard ist **einmal rot gesehen**;
Frage A, B und C sind mit ihrer Begründung im Plan beantwortet; `make mutate` liefert über der
vollen Fall-Menge dasselbe Verdikt wie die serielle Fassung; die Beschreibungen in
[`harness/README.md`](../../../../harness/README.md) und [`AGENTS.md`](../../../../AGENTS.md) §4 sind
gezogen; Review konform (Modul 10); Verifikation bestätigt (Modul 11); `make gates` grün; `git mv`
nach `done/` als eigener Move-Commit; Closure-Notiz mit Steering-Loop-Eintrag in einer der drei
Formen (geschärfte Regel · neuer Sensor · benannte Spec-Lücke).

**Ausdrücklich nicht Teil des Closure-Triggers: eine Laufzeit-Schwelle.** Eine Zahl als Kriterium
wäre auf einem geteilten Runner rot ohne Befund und grün ohne Deckung — dieselbe Begründung, aus
der `make hook-overhead` eine Messung ist und kein Gate
([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). Was
zählt, ist die **Aufschlüsselung** und die **Vollständigkeit**, nicht die erreichte Sekundenzahl.

## 6. Risiken und offene Punkte

- **Der teuerste Fehler ist eine parallele Fassung, die still grün meldet.** Sie entwertete jede
  Zusage, die auf einem rot gesehenen Gegenbeispiel ruht. Deshalb steht der absichtlich kaputte
  Shard in DoD (3) und nicht in einer Risiko-Zeile: er ist Abnahme-Bedingung, kein Vorsatz.
- **Teilung nach Sensor ist exakt, aber unausgewogen.** **115** von **157** Fällen fahren `test-go`;
  ein Shard mit 115 Fällen bestimmt die Laufzeit weiter. Frage A hängt daran, und die Antwort darf
  nicht vor der Messung fallen — sonst baut der Slice die zweite Ebene für einen Hebel, den es
  vielleicht nicht gibt.
- **Der Grün-Vorlauf kann leise ungenau werden.** Sobald ein Shard das Grün eines anderen
  übernimmt, sagt der Sensor nicht mehr, was seine Abbruch-Meldung behauptet. Das ist keine
  Optimierung, sondern eine Senkung — §4 führt sie als Blocker, nicht als Abwägung.
- **Zwei Quellen für ein Rot, das nicht am geprüften Baum liegt, sind in der Diagnose nicht
  additiv, sondern multiplikativ.** Das ist der ganze Inhalt der Reihenfolge-Bedingung; sie hier zu
  wiederholen wäre eine zweite Fassung, die driftet — sie steht in §4.
- **Der Treiber wird länger, und seine Sensor-Ebene ist bats.** `wc -l < harness/tools/mutate.sh` →
  **566** heute. Wächst er deutlich, ohne dass
  [`test/mutate-driver.bats`](../../../../test/mutate-driver.bats) mitwächst, entsteht genau die
  Klasse, gegen die dieses Werkzeug gerichtet ist: ein Wächter ohne Wächter.
- **Die Zeit-Aufschlüsselung ist eine Messung, kein Sensor.** Sie prüft nichts und färbt nichts rot
  — außer ihrer eigenen Vollständigkeit (DoD 1). Ein Gate über Sekundenwerten stünde auf geteilter
  Hardware, und das ist keine Lücke dieses Schnitts, sondern die Grenze der Ebene.

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
Gegenstand, eine Frage. Die berührten `make`-Ziele und die CI-Zeile sind Aufrufer, keine eigene
Sub-Area.

- **Modus:** GF. Der Treiber ist in diesem Repo entstanden (slice-026) und seither gegen den Kurs
  geführt; es gibt keinen vorgefundenen Bestand, gegen den zu inventarisieren wäre.
- **Konventionen-Dichte:** hoch. [`AGENTS.md`](../../../../AGENTS.md) §3.6 definiert, wofür der
  Treiber da ist, §3.5 bindet die Frage *Anhebung oder Senkung*,
  [`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions) bindet
  seinen Auslöser, und
  [`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks)
  seine Einbettung in die Sensor-Mechanik.
- **Phase-Reife:** Phase 5 (Betrieb). Der Treiber läuft pro Push, über **157** Fällen, mit
  Isolation, Lock und fünf fail-closed Bedingungen. Was fehlt, ist nicht Reife, sondern Sichtbarkeit
  seiner eigenen Kosten.
- **Evidenz-/Diskrepanz-Risiko:** niedrig für die Struktur (aus dem Skript gelesen, §1), **offen für
  die Zeit** — und das ist der Gegenstand. Ein zweites Risiko liegt daneben: die statische
  Sensor-Zuordnung (§1) und die Laufzeit-Zuordnung müssen übereinstimmen; tun sie es nicht, ist die
  Diskrepanz ein Befund vor der Teilung, keine Randnotiz.
- **Reconciliation-Aufwand:** gering für DoD (1), **nicht abschätzbar vor der Messung** für DoD (2)
  und (3) — genau darum steht die Messung zuerst und die Rückführung `in-progress` → `next` in §4
  bereit. Graduation-Trigger entfällt; die Sub-Area ist bereits GF.
