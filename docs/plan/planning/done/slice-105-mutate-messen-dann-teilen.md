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

Über die Fall-Verteilung ergibt das die **modellierte Zeit-Verteilung**. Modelliert, und der Zusatz
trägt: ihr Stückpreis ist der eines **grünen** Laufs. Was ein **mutierter** Fall kostet, misst erst
DoD (1) — und die Messung fällt anders aus (§Der Abgleich, den dieser Abschnitt verlangt hat):

| Sensor | Fälle | Summe s | Anteil |
|---|---|---|---|
| `test-go` | 132 | 726 | **51 %** |
| `full-smoke` | 4 | 353 | **25 %** |
| `test-bats` | 38 | 331 | **23 %** |
| `smoke` | 1 | 10 | 1 % |
| `ci-lint` | 1 | 0 | 0 % |

**Gemessen liegt der Schwerpunkt noch deutlicher bei einem Sensor als modelliert:** **134** der
**190** Fälle (`ls -1 test/mutations/*.sh | wc -l`) fahren `test-go`, und sie tragen **60,9 %** der
Fall-Arbeit — nicht 51 %. Damit ist Frage A entschieden: **Teilung nach Sensor allein genügt
nicht**, denn diese 134 Fälle blieben in **einem** Shard. Und eine Tier-Korrektur der teuersten
Modi allein genügt erst recht nicht — gemessen tragen die sechs `full-smoke`-Fälle **7,3 %** statt
der modellierten 25 %, dort liegt also fast nichts zu holen. Der Hebel ist die **dynamische
Zuweisung an Worker** mit einer Warteschlange, die **absteigend nach Stückpreis** sortiert ist —
was weitgehend dasselbe ist wie nach Sensor gruppiert. **Weitgehend**, nicht genau: der Preis
streut auch **innerhalb** eines Sensors, bei `full-smoke` gemessen von 8,59 s bis 67,84 s
(Faktor **7,9**, aus der Liste *Zeit je Fall, absteigend* desselben Laufs). Die teuersten Fälle
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

### Der Abgleich, den dieser Abschnitt verlangt hat — das Modell trifft die Verteilung nicht

**Sie stimmen nicht überein, und falsch ist das Modell.** Der Anteil an der Fall-Arbeit, aus drei
vollständigen Läufen dieses Tages gezogen (Kommando je Spalte:
`sed -n '/Zeit je Sensor/,/Gruen-Vorlaeufe/p'` über dem Protokoll des jeweiligen Laufs; die Läufe
selbst stehen mit ihrer Quelle im Messprotokoll unten):

| Sensor | modelliert | 188 Fälle, N=1 | 188 Fälle, N=4 | 190 Fälle, N=4 |
|---|---|---|---|---|
| `test-go` | 51 % | **61,4 %** | **64,0 %** | **60,9 %** |
| `test-bats` | 23 % | 33,1 % | 31,0 % | 31,1 % |
| `full-smoke` | **25 %** | **5,3 %** | **4,8 %** | **7,3 %** |
| `smoke` | 1 % | 0,1 % | 0,1 % | 0,6 % |
| `ci-lint` | 0 % | 0,0 % | 0,0 % | 0,1 % |

**Die Ursache steht im Treiber-Kopf, seit es ihn gibt: ein mutierter Fall bricht am getroffenen
Wächter ab und ist darum kürzer als ein vollständiger Lauf.** Das Modell hat mit dem Preis eines
**grünen** `full-smoke`-Laufs gerechnet (88,3 s, oben mit seinem Kommando); gemessen kostet ein
`full-smoke`-**Fall** im Mittel 13,30 s (188/N=1), 15,09 s (188/N=4) und 24,80 s (190/N=4) — die
`mittel=`-Spalte derselben Ausgabe. Der Satz, auf den die Antwort auf Frage A gestützt war — *ein
`full-smoke`-Fall kostet so viel wie sechzehn `test-go`-Fälle* — misst gemessen **1,9**, **1,7**
und **2,7**, je nach Lauf. Nicht 16.

**Zwei Fehler, die einander verdeckt haben.** Die **Summe** des Modells traf: 1420 s modelliert
gegen 1252,6 s gemessen über 176 Fälle, das sind 88 %. Die **Zusammensetzung** traf nicht: zu wenig
`test-go` und `test-bats`, um den Faktor fünf zu viel `full-smoke`. Wer nur die Summe geprüft
hätte, hätte das Modell für belegt gehalten — und genau deshalb verlangt dieser Abschnitt den
Abgleich über die **Verteilung** und nicht über die Gesamtzeit.

**Der Ausgang: die Entscheidung überlebt ihre Begründung, und zwar verstärkt.** Frage A lautete,
ob eine Teilung nach Sensor genügt. Gemessen liegen **134** von **190** Fällen und rund **61 %**
der Arbeit bei einem einzigen Sensor — ein reiner Sensor-Schnitt ließe einen Shard mit 134 Fällen
stehen. Das ist ein **stärkeres** Argument für die dynamische Zuteilung als das modellierte.
Falsch war die Prämisse, nicht der Schluss.

**Was der Befund für den nächsten Hebel ändert, und das ist sein eigentlicher Wert.** Wer nach dem
Modell weitergerechnet hätte, hätte als Nächstes die vier teuren `full-smoke`-Fälle angegriffen —
ein Viertel der Zeit schien dort zu liegen. Gemessen liegen dort **7,3 %**. Der nächste Hebel ist
ein anderer: die **serielle Spur**, die bei N=8 gemessen 98 % der Wanduhr belegt (Commit-Message
`82d2ed7`, fremdbelegt und von dieser Rolle nicht nachgemessen).

**Und eine zweite Modell-Aussage desselben Abschnitts ist gemessen falsch:** *„der Preis je Sensor
ist konstant"*. Innerhalb von `full-smoke` streut er im 190er-Lauf von 8,59 s bis 67,84 s
(Faktor **7,9**), innerhalb von `test-go` um 2,0, innerhalb von `test-bats` um 1,4 — jeweils
`min`/`max` aus der Liste *Zeit je Fall, absteigend* desselben Protokolls. Folgenlos ist es heute,
weil die sechs `full-smoke`-Fälle in der seriellen Spur liegen und dort nur gegen `smoke` sortiert
werden; die Begründung des Sortierschlüssels ist trotzdem schwächer als ihr Text
([slice-117](../in-progress/slice-117-lauf-ohne-ende-faerbt-rot.md) §3 nimmt sie mit).

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
| 2026-08-27 | 188 | **dynamisch** | 1 | **1467,05 s** | 7,80 | Umsetzung `slice-105`, Commit-Message `82d2ed7` |
| 2026-08-27 | 188 | **dynamisch** | 2 | 816,81 s | 4,34 | dieselbe |
| 2026-08-27 | 188 | **dynamisch** | 4 | **497,66 s** | 2,65 | dieselbe |
| 2026-08-27 | 188 | **dynamisch** | 8 | 439,45 s | 2,34 | dieselbe |
| 2026-08-27 | 188 | **dynamisch** | 4 | 526,26 s | 2,80 | Lauf der Review-/Verifikations-Runde, ausgewertet in beiden Berichten |
| 2026-08-27 | 188 | **dynamisch** | 1 | **1625,68 s** | 8,65 | Verifikation `slice-105` §7.1 — der [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)-Kontrollpunkt |
| 2026-08-27 | 190 | **dynamisch** | 4 | **570,37 s** | 3,00 | nach dem Fix `0e76c77`; Verdikt `190 ok, 0 Befund(e)` |

Kommando für jede Zeile: `/usr/bin/time -f 'MUTATE_SECONDS=%e' make mutate` (mit
`MUTATE_JOBS=<N>`, wo N ≠ 4), die Fall-Zahl aus `ls -1 test/mutations/*.sh | wc -l`. Die Spalte
`s/Fall` ist Wanduhr ÷ Fälle und dient nur dem Vergleich zwischen Läufen verschiedener
Bestandsgröße.

**Die zwei N=1-Punkte dieses Tages liegen über dem bisher genannten Band, und das ist kein Befund
über den Treiber.** 7,80 und 8,65 s je Fall gegen 6,81 bis 7,43 der sequentiellen Läufe — der
Grund ist die **Zusammensetzung** des Bestands, nicht sein Umfang: zwischen 176 und 190 Fällen kam
`test-bats` von 38 auf **48** und `full-smoke` von 4 auf **6** (beide Zahlen aus derselben
statischen Zuordnung, deren Rezept unten in §3 steht), und `test-bats` kostet gemessen **13,13 s**
je Fall gegen **9,23 s** bei `test-go`. Der Mix ist teurer geworden. **Wie viel davon Mix ist und
wie viel Maschine, lösen diese Zahlen nicht auf** — sie stehen als offene Differenz hier, statt als
korrigierter Wert. Was die Spalte damit lehrt, ist enger als bisher notiert: `s/Fall` vergleicht
Läufe nur, solange auch die **Fall-Mischung** vergleichbar ist.

**Die zwei fett gesetzten N=1/N=4-Paare sind der
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)-Beleg**, und zwar in
zwei unabhängigen Fenstern über **denselben** 188 Fällen: 1467,05 gegen 497,66 s (**2,95×**,
Umsetzung) und 1625,68 gegen 526,26 s (**3,09×**, Verifikation). Beide Fenster liefern **dasselbe
Verdikt** (`188 ok, 0 Befund(e)`), dieselbe Vollständigkeitszeile, dieselbe Sensor-Verteilung und
dieselbe serielle Spur — die Verifikation hat das Paar mit ihren eigenen Kommandos
gegenübergestellt (§7.2). **Die Beschleunigung ist die Nebenaussage, das gleiche Verdikt die
tragende.**

**Was die Reihe über die Zeit zeigt und eine Momentaufnahme nicht gezeigt hätte:** Der Preis
**je Fall** liegt bei allen sequentiellen Läufen zwischen 6,81 und 7,43 s — er ist über zwei
Tage und **vier** Bestandsgrößen **stabil**. Die Wanduhr wuchs von 1166 über 1253 auf 1326 s
allein deshalb, weil der Bestand von 157 über 176 auf 179 Fälle wuchs. Ohne diese Tabelle wäre das
Wachstum als Verschlechterung lesbar gewesen; mit ihr ist es die erwartete Folge von mehr
Abdeckung.

**Die jüngste Zeile prüft die Aussage, statt sie zu bestätigen — und sie trägt.** 7,41 s je Fall
liegt **innerhalb** des seit zwei Tagen genannten Bandes, nicht an seiner Kante darüber hinaus:
das Band bleibt **unverändert** 6,81 bis 7,43 s, seine Obergrenze steht weiter beim ältesten Lauf
(2026-08-25, 157 Fälle). **Die Aufschlüsselung nach Sensor liefert seit DoD (1) der Lauf selbst** —
je Fall eine Dauer, je Sensor Summe, Anteil, Mittel und längster Fall; sie steht oben im Abgleich,
und mit ihr ist die Teilung eine Messfolge und keine Konstruktions-Entscheidung mehr.

**Was der Kontrollpunkt heute trägt, und was nicht.** Am Prototyp (165 Fälle) kostete der
dynamische Treiber bei N=1 **7,05 s** je Fall und lag damit mitten im Band der sequentiellen Läufe
— dafür war der Punkt da, und für **jenen** Bestand trägt er. Über **188** Fällen liegen die zwei
N=1-Punkte dieses Tages bei 7,80 und 8,65 s je Fall, also darüber; der Absatz unter der Tabelle
nennt die gemessene Mit-Ursache (der Fall-Mix ist teurer geworden) und sagt zugleich, dass diese
Zahlen die Frage *Mix oder Treiber* nicht auflösen. **Was gemessen bleibt, ist die Beschleunigung
innerhalb desselben Fensters:** 2,95× und 3,09× zwischen N=1 und N=4 über derselben Fall-Menge, in
zwei unabhängigen Fenstern.

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
  Vorlauf je Shard, für genau dessen Sensor, in genau dessen Kopie. **Die Zahl der Vorläufe steigt
  dabei** — gemessen **9** bei N=4 gegen **6** der sequentiellen Fassung
  (`{ echo test; sed -n 's/^# verify: //p' test/mutations/*.sh; } | LC_ALL=C sort -u | wc -l` →
  **6**, die Liste, die der sequentielle Treiber an `green_prerun` übergab; die 9 aus der
  Vorlauf-Tabelle des Laufs, `sed -n '/Gruen-Vorlaeufe/,/Zeit je Fall/p' | awk 'NF==3' | wc -l`).
  Bei N=1 sind es **5** — vier protokollierte plus der Vorwärmlauf —, also **weniger** als sechs,
  weil kein Fall den Modus `test` benutzt. Die Deckung wächst mit der Worker-Zahl statt zu
  schrumpfen; das ist die sichere Richtung und keine Senkung
  ([`AGENTS.md`](../../../../AGENTS.md) §3.5).
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

- [x] **(1) Der Lauf schlüsselt seine Zeit auf: je Fall, gruppiert nach Sensor — und er nennt
      seinen Nenner.** Die Ausgabe trägt je Fall eine Dauer und je Sensor eine Summe samt Anteil an
      der Gesamtzeit; die Zahl der aufgeschlüsselten Fälle steht neben der Zahl der Fälle auf der
      Platte.
      **Rot:** der Lauf selbst — weicht die Summe der aufgeschlüsselten Fälle von
      `ls -1 test/mutations/*.sh | wc -l` ab, bricht er ab, statt eine unvollständige Bilanz
      auszugeben. Dazu ein `test/mutations/`-Fall, der die Aufschlüsselung um einen Fall kürzt.
- [x] **(2) Geteilt wird nach Sensor, und der Grün-Vorlauf bleibt exakt.** Je Shard **ein** Vorlauf,
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
Ausgangs-Menge, die [slice-101](../open/slice-101-norm-postens-bekommen-einen-termin.md) für offene Postens
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

**Was gilt.** `make mutate` sagt am Ende jedes Laufs, wo seine Zeit liegt — je Fall eine Dauer, je
Sensor Summe, Anteil, Mittel und längster Fall, und die Überschrift der Bilanz nennt ihren Nenner
gegen die Zahl der Fall-Dateien. Die Fälle laufen dabei **dynamisch aus einer gemeinsamen
Warteschlange** auf `MUTATE_JOBS` Worker, jeder in **seiner eigenen** isolierten Kopie außerhalb
des Repos; die Modi, deren Urteil an einem geteilten Docker-Tag hängt, laufen in **einer** Spur,
und das Kriterium dafür ist die **Delegation** des `make -n`-Plans, nicht die Form seiner Zeilen.
Der Bestand steht bei `ls -1 test/mutations/*.sh | wc -l` → **190**, die höchste vergebene Nummer
bei `ls -1 test/mutations/*.sh | sed -n 's#.*/\([0-9]*\)-.*#\1#p' | sort -n | tail -1` → **197**,
der Treiber bei `wc -l < harness/tools/mutate.sh` → **1252** (vorher **566**) und seine
Sensor-Ebene bei `grep -c '^@test' test/mutate-driver.bats` → **39** (vorher **21**). Alle vier
Zahlen wandern mit ihrem Bestand und sind **kein** Erwartungswert
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2).

**Der Closure-Trigger aus §5, Kriterium für Kriterium.**

1. **DoD (1) und (2) erfüllt, mit gefahrenen Kommandos; DoD (3) für zwei seiner drei Ausfall-Arten.**
   Die [Verifikation](../../../reviews/2026-08-27-slice-105-verify.md) hat (1) und (3) als
   *teilweise* bewertet — beide an derselben fail-open-Auswertung, die `0e76c77` geschlossen hat
   (unten). Was danach offen bleibt, ist **ein Wort**: *hängt*. Der Haken an (3) steht deshalb
   **nicht**, und das ist die Aussage, kein Versäumnis; getragen wird der Rest von
   [`CO-003`](../../carveouts/CO-003-mutate-ohne-zeitschranke.md).
2. **Die Aufschlüsselung liegt vor, ihr Nenner steht neben `ls -1 test/mutations/*.sh | wc -l`.**
   Der Lauf nach dem Fix schreibt `Zeit je Sensor ueber 190 von 190 Fall-Dateien`; der Bestand
   daneben ist **190**. Seit `0e76c77` zählt der Nenner die **Zeilen**, über die die Bilanz
   rechnet, nicht die Dateien im Glob.
3. **Der absichtlich kaputte Shard ist einmal rot gesehen** — fremdbelegt, an **zwei**
   vollständigen Läufen des echten Treibers
   ([Verifikation](../../../reviews/2026-08-27-slice-105-verify.md) §4.4), nicht nur im Test.
4. **Frage A, B und C sind mit ihrer Begründung im Plan beantwortet** — unten in dieser Notiz. §5
   verlangt sie *„im Plan"*; sie stehen damit in der Plan-Datei, aber in ihrem Closure-Abschnitt
   statt in der Vor-Code-Tabelle von §3. Eine Vor-Code-Tabelle nachträglich mit dem Ergebnis zu
   füllen, machte aus einer offenen Frage eine erfundene Voraussicht — dieselbe Grenze, die
   [slice-106](../done/slice-106-rotes-ci-traegt-seinen-ausgang.md) §7 gezogen hat.
5. **`make mutate` liefert über der vollen Fall-Menge dasselbe Verdikt wie die serielle Fassung.**
   Gemessen in **zwei** unabhängigen Fenstern über denselben **188** Fällen (N=1 gegen N=4:
   2,95× und 3,09×), mit gleichem Verdikt, gleicher Vollständigkeitszeile, gleicher
   Sensor-Verteilung und gleicher serieller Spur — die Zeilen stehen im Messprotokoll in §1, die
   Gegenüberstellung in der [Verifikation](../../../reviews/2026-08-27-slice-105-verify.md) §7.2.
6. **Die Beschreibung in [`harness/README.md`](../../../../harness/README.md) ist gezogen.** Der
   Nicht-Gate-Verify-Absatz trägt jetzt die Worker-Verteilung, die eigene Kopie je Worker, die
   serielle Spur, die Vollständigkeits-Zeile und die Zeit-Aufschlüsselung als **Messung** — je eine
   ersetzte Stelle, kein zweiter Satz daneben. **In [`AGENTS.md`](../../../../AGENTS.md) §4 war
   nichts zu ziehen**, und die Plan-§3-Zeile, die es verlangte, stand auf einer falschen Prämisse
   (Delta 1 unten).
7. **Review konform (Modul 10).**
   [Code-Review](../../../reviews/2026-08-27-slice-105-review.md): *nicht formal frei*,
   `grep -c '^### F-' docs/reviews/2026-08-27-slice-105-review.md` → **11** Befunde
   (**1** HIGH · **5** MEDIUM · **5** LOW,
   `grep -oE '^- \*\*Kategorie:\*\* [A-Z]+' … | sort | uniq -c`). F-1, F-2, F-5, F-6 und F-8 sind
   mit `0e76c77` behoben; F-3 und F-4 sind mit dieser Closure erledigt; F-7, F-9, F-10 und F-11
   tragen unten je einen Ausgang.
8. **Verifikation (Modul 11).**
   [Bericht](../../../reviews/2026-08-27-slice-105-verify.md): *Closure-Trigger heute nicht
   erfüllt*, `grep -cE '^### [0-9]+\.[0-9]+ B-' docs/reviews/2026-08-27-slice-105-verify.md` →
   **12** Beobachtungen. B-13 und B-2/B-3/B-6 sind erledigt (Fix bzw. diese Closure), B-1/B-4/B-5/
   B-7 haben einen Träger, B-8 ist halb geschlossen und halb getragen, B-9 ist unten **gemessen**
   statt getragen, B-10 und B-12 tragen unten ihren Ausgang.
9. **`make gates` grün.** Eigener Lauf, Belege unten unter *Gates*.
10. **`git mv` nach `done/` als eigener Move-Commit** und **Closure-Notiz mit Steering-Loop-Eintrag**
    — diese Notiz; der Eintrag steht unten.

**Der Abgleich, den §1 verlangt hat, ist gefahren und steht in §1** — dort, wo das Modell steht,
und nicht hier: eine zweite Fassung würde driften. Kurz: das Modell traf die **Summe** (88 %) und
verfehlte die **Zusammensetzung**; `full-smoke` trägt gemessen 4,8 bis 7,3 % statt der modellierten
25 %, weil ein mutierter Fall am getroffenen Wächter abbricht. **Die Entscheidung überlebt ihre
Begründung verstärkt**, und die falschen Sätze sind **gezogen**, nicht danebengestellt — nach der
Grenze, die [slice-097](../done/slice-097-rollen-typen-gehen-mit.md) §7 gezogen hat: eine
Tatsachenbehauptung über die Welt wird korrigiert, ein Abnahme-Kriterium samt seinem Rot-Kommando
nicht. Deshalb steht die **modellierte** Tabelle unverändert (sie ist die Erhebung, gegen die
gemessen wurde) und die aus ihr gezogenen Behauptungen nicht mehr.

**Frage A, B und C — die Antworten, die der Lauf getroffen hat.**

- **A (Wird innerhalb eines Sensors weiter geteilt?)** **Nein — und die Frage ist damit anders
  beantwortet, als sie gestellt war.** Gebaut ist keine zweite Teilungs-Ebene, sondern eine
  **dynamische Warteschlange**: die Fälle werden absteigend nach `mode_rank` sortiert und einzeln
  gezogen, sobald ein Worker frei ist. Ein Fall ist die kleinste Einheit; wer sie zieht, entscheidet
  der Lauf, nicht der Plan. Damit entfällt der Preis, den eine zweite Ebene gekostet hätte — ein
  weiterer Grün-Vorlauf je Unter-Shard —, und die Ausgewogenheit entsteht trotzdem: gemessen
  bekamen die vier Worker **41 · 49 · 49 · 49** Fälle
  (`grep -oE '^mutate: \[w[0-9]+\]' <protokoll> | sort | uniq -c`). Die Antwort ist **gemessen
  richtiger als ihre ursprüngliche Begründung**: 134 der 190 Fälle liegen bei einem Sensor, ein
  reiner Sensor-Schnitt ließe genau diesen Block stehen. **Was der Preis dafür ist, steht in
  §1:** absteigend nach Stückpreis ist nur **weitgehend** dasselbe wie nach Sensor gruppiert, und
  ein Worker zahlt für jeden Modus-Wechsel einen Vorlauf in seiner Kopie — gemessen **9** Vorläufe
  bei N=4 gegen **6** der sequentiellen Fassung.
- **B (Woher kommt die Shard-Zahl?)** Aus der Umgebungsvariablen `MUTATE_JOBS`, mit **Default 4 im
  Skript, nicht im Makefile**. Zwei Entscheidungen, beide mit Grund. **Erstens: eine Vorgabe, eine
  Quelle.** Das `Makefile` reicht die Variable nur durch (`MUTATE_JOBS='$(MUTATE_JOBS)'`); bei
  nicht gesetzter Variable kommt der leere String an, und `JOBS="${MUTATE_JOBS:-4}"` fängt ihn.
  Ein zweiter Default im Rezept wäre eine zweite Quelle, die driftet — und der Treiber ist auch
  ohne `make` aufrufbar. **Zweitens: fest statt aus `nproc`.** Eine maschinenabhängige Vorgabe
  machte zwei Läufe unvergleichbar, und Vergleichbarkeit ist der Zweck der Zeiten in §1: dieselbe
  Zahl über zwei Maschinen zu fahren ist eine Messung, verschiedene Zahlen sind zwei. **Fail-closed
  ist es auch:** eine nicht-numerische oder leere Vorgabe führt in einen Abbruch mit eigener
  Meldung, **bevor** irgendetwas kopiert wird — nicht erst in der Zusammenführung.
  **[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) hängt nicht an dieser
  Zahl**, und das ist der Punkt: was das Verdikt trägt, ist die Vollständigkeits-Zeile, die **jeder**
  Lauf für sich selbst rechnet — Kriterium 5 oben belegt es über zwei Worker-Zahlen, nicht über
  alle.
- **C (Fährt die CI dieselbe Aufteilung wie ein lokaler Lauf?)** **Ja, und das ist jetzt gemessen
  statt begründet.** `.github/workflows/ci.yml` ruft `make mutate` **bar**
  (`grep -n 'make mutate' .github/workflows/ci.yml` → eine Zeile ohne Vorgabe), die CI fährt also
  denselben Default 4 — auf einem `ubuntu-24.04`-Runner mit vier vCPU statt der **20** Kerne dieses
  Hosts (`nproc` → **20**). Der Bericht der Verifikation führt das als ungemessenes Risiko (B-9);
  es ist inzwischen erhoben, über die Job-Wanduhr von vier CI-Läufen desselben Workflows
  (`gh api "repos/{owner}/{repo}/actions/runs/<id>/jobs" --jq '.jobs[] | select(.name=="mutate") | "\(.started_at)\t\(.completed_at)"'`,
  Fall-Zahl je Commit aus `git ls-tree -r --name-only <commit> test/mutations/ | grep -c '\.sh$'`):

  | Commit | Fälle | Treiber | Job-Wanduhr | s/Fall |
  |---|---|---|---|---|
  | `c4a0c03` | 179 | sequentiell | 1417 s | 7,92 |
  | `ae00252` | 183 | sequentiell | 1559 s | 8,52 |
  | `ba820b3` | 183 | sequentiell | 1507 s | 8,23 |
  | `82d2ed7` | 188 | **dynamisch, N=4** | **1267 s** | **6,74** |

  **Vier vCPU tragen die Aufteilung, aber sie zahlen sie fast auf.** 6,74 s je Fall gegen ein Band
  von 7,92 bis 8,52 der drei sequentiellen Läufe sind **1,18× bis 1,26×** — auf diesem Host sind es
  über dieselben 188 Fälle **3,09×**. Die Zahl ist eine **Job**-Wanduhr, nicht `MUTATE_SECONDS`;
  sie enthält Checkout und Aufräumen und ist damit eine **Obergrenze**. Als Differenz zwischen
  Läufen desselben Workflows trägt sie trotzdem. **Was daraus folgt, ist keine zweite Aufteilung:**
  [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) verlangt dasselbe
  Verdikt, nicht dieselbe Laufzeit, und zwei Aufteilungen wären zwei Sensoren. Es folgt eine
  **Erwartung**: wer den nächsten Zeitgewinn sucht, findet ihn in der CI kaum in einer höheren
  Worker-Zahl.

**Die offenen Befunde und ihr Ausgang — vier Klassen, keine „genannt".** Dieselbe Ausgangs-Menge,
die §4 für den `full-smoke`-Befund gesetzt hat und die
[slice-101](../open/slice-101-norm-postens-bekommen-einen-termin.md) für Norm-Postens führt:
**diagnostiziert** · **als Umgebungs-Eigenschaft ausgewiesen** · **abgelehnt** mit Grund ·
**aufgeschoben** mit einem Auflösungs-Trigger, der ein beobachtbares Ereignis nennt.

| Posten | Ausgang | Träger |
|---|---|---|
| **DoD (3) sagt *„hängt"* zu, und dafür existiert kein Sensor** (B-1). `wait "$pid"` ohne Zeitschranke; `grep -c 'timeout' harness/tools/mutate.sh` → **0**, `grep -c 'timeout-minutes' .github/workflows/ci.yml` → **0**. Zwei Hänger hergestellt, beide endeten nur an einem Signal von außen | **aufgeschoben**, mit dem Auflösungs-Trigger in [`CO-003`](../../carveouts/CO-003-mutate-ohne-zeitschranke.md) §Auflösungs-Trigger (drei prüfbare Bedingungen). **Diagnostiziert ist die Ursache**, offen ist die **Bemessung** — und die zu raten hätte den Sensor beschädigt | [`CO-003`](../../carveouts/CO-003-mutate-ohne-zeitschranke.md) + [slice-117](../in-progress/slice-117-lauf-ohne-ende-faerbt-rot.md) DoD (1) |
| **Unter Ctrl-C widerspricht der Bericht seiner eigenen Ausgabe** (B-4). `cleanup()` löscht `$ISO_ROOT` samt Laufverzeichnis und kehrt mit 0 zurück; `merge_report` rechnet danach über ein gelöschtes Verzeichnis | **aufgeschoben**. Beobachtbarer Auflösungs-Trigger: ein Lauf mit Signal, dessen Bericht dieselbe Zahl an Fällen mit Ergebnis nennt wie sein eigenes Protokoll an `OK`/`BEFUND`-Zeilen. **Nicht blockierend, mit Grund:** die Richtung ist rot, nicht grün — unwahr ist der Text, nicht das Urteil | [slice-117](../in-progress/slice-117-lauf-ohne-ende-faerbt-rot.md) DoD (2) |
| **`mode_rank` ist nicht nachgezogen** (F-7/B-7). Ihr Kommentar nennt `report_times` als ihren Sensor und sagt zu, sie nachzuziehen; gemessen steht `smoke` im Rang vor `test-bats` und `test-go` | **diagnostiziert.** Die Zusage ist an eine Größe gebunden, die sie nicht tragen kann: `smoke` hat **n=1** und streut zwischen zwei Läufen desselben Tages um Faktor **6,7** (1,91 s gegen 12,88 s, `mittel=`-Spalte). Praktisch folgenlos — die Ränge wirken nur **innerhalb** einer Spur, und dort sortieren beide Läufe richtig. Nachzuziehen ist eher die Zusage als die Zahl | [slice-117](../in-progress/slice-117-lauf-ohne-ende-faerbt-rot.md) §3 Mitnahme 1 |
| **Die Begründung zur vierten `merge_report`-Prüfung trifft nicht zu** (B-5). Der Kommentar sagt *„1 bis 3 messen gegen die Warteschlange"*; die Schleife von 1 und 2 läuft `for ((i = 1; i <= total; i++))`, und `total` kommt aus dem Verzeichnis | **diagnostiziert** — statisch nachgelesen, nicht erschlossen. Die Redundanz ist real und harmlos; falsch ist ihre Begründung ([`AGENTS.md`](../../../../AGENTS.md) §3.7) | [slice-117](../in-progress/slice-117-lauf-ohne-ende-faerbt-rot.md) §3 Mitnahme 2 |
| **Entstehungs-Prosa und eine nicht auflösbare Befund-Kennung** (F-9). `grep -cE 'erste[rn]? Entwurf\|Vorgaenger' harness/tools/mutate.sh test/mutate-driver.bats` → **1** bzw. **2**; `grep -cE 'Review F-[0-9]' harness/tools/mutate.sh` → **4**, davon **eine** neu (`git show 82d2ed7 -- harness/tools/mutate.sh | grep -cE '^\+.*Review F-[0-9]'` → **1**; `0e76c77` hat **keine** hinzugefügt) | **diagnostiziert.** Der Bestand liegt unter dem §3.7-Cutoff, die eine neue Zeile nicht; die Regel steht bereits ([`AGENTS.md`](../../../../AGENTS.md) §3.7 verlangt **ein** auflösbares Feld), es fehlt allein der Zug | [slice-117](../in-progress/slice-117-lauf-ohne-ende-faerbt-rot.md) §3 Mitnahme 3 |
| **`anteil=` nennt seinen Nenner erst zwei Blöcke später**, und die Kopfzeile sagt *„aus einer gemeinsamen Warteschlange"*, während der Lauf zwei Schlangen führt (F-10a/c, B-10) | **diagnostiziert**, beide Male ein Wort in einer Zeile | [slice-117](../in-progress/slice-117-lauf-ohne-ende-faerbt-rot.md) §3 Mitnahme 4 |
| **Der Vorwärmlauf fehlt in der Vorlauf-Tabelle** (F-10b) | **abgelehnt, mit Grund.** Die Überschrift der Tabelle sagt *„der Preis der Aufteilung"*. Der Vorwärmlauf ist keiner: er ersetzt den einen `test-go`-Vorlauf, den auch die sequentielle Fassung fuhr, und er läuft in **derselben** Kopie, die Worker 1 danach benutzt. Ihn dort aufzuführen machte aus einem Bestandsposten einen Aufschlag | — |
| **Die Commit-Message von `82d2ed7` nennt „13 neue bats-Faelle"; es sind 14** (F-11/B-12) | **diagnostiziert und hier festgehalten.** `git show 82d2ed7 -- test/mutate-driver.bats \| grep -c '^+@test'` → **14**. Eine Commit-Message ist Historie und wird nicht umgeschrieben ([`AGENTS.md`](../../../../AGENTS.md) §3.4 gilt für ADRs, `git` für den Rest); [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) bindet lebende Artefakte. Die zwei anderen Zahlen derselben Message tragen. **Die Message von `0e76c77` hält:** *„Vier neue bats-Faelle, zwei neue Mutationen"* — `git show 0e76c77 -- test/mutate-driver.bats \| grep -c '^+@test'` → **4** | — |
| **`QUEUE_LOCK_TRIES` trägt keinen Zahn** (B-8, erste Hälfte). `grep -rln 'QUEUE_LOCK_TRIES' test/ \| wc -l` → **0** | **aufgeschoben**, zusammen mit der neuen Schranke — wer die Zeitschranken anfasst, fasst beide an | [slice-117](../in-progress/slice-117-lauf-ohne-ende-faerbt-rot.md) DoD (3) |
| **Der Abschluss-Marken-Zweig trug keinen Zahn** (B-8, zweite Hälfte) | **erledigt** mit `0e76c77`: `grep -c 'MARKE-FEHLT' test/mutate-driver.bats` → **2** | — |
| **Der Default N=4 fährt auf vier vCPU ungemessen** (B-9) | **gemessen und damit erledigt** — vier CI-Läufe, Tabelle oben bei Frage C | — |

**Was `0e76c77` geschlossen hat, und warum es die Sache dieses Slice selbst war.** `merge_report`
prüfte, ob eine Statusdatei **da** ist, nicht ob ein **Urteil** darin steht; `report_times` nahm
seinen Nenner aus demselben Glob. Eine leere Statusdatei ergab damit `OK`, eine bestätigte
Vollständigkeit und eine Bilanz, deren Kopf `3 von 3` sagte, während ihr Rumpf `n=2` summierte —
von zwei Rollen unabhängig hergestellt ([Review](../../../reviews/2026-08-27-slice-105-review.md)
F-1 als HIGH, [Verifikation](../../../reviews/2026-08-27-slice-105-verify.md) §2.5/§4.5 als
DoD-Verletzung). Der Weg dorthin war die **Aufrufform**: `worker_main … || rc=$?` setzt `errexit`
für den ganzen Rumpf aus, bis in `run_case` hinein. Geschlossen ist beides — `status_line_valid`
prüft die Zeile selbst, `collect_status` ist die **eine** Quelle für Vollständigkeit und Bilanz,
und der Worker startet ohne `||`-Kontext. **Zwei neue Mutationen (196, 197) sind die Zähne**, jede
für sich rot gesehen; der Lauf danach: `190 ok, 0 Befund(e)` in **570,37 s**. Das war kein
Nebenbefund: eine parallele Fassung, die still grün meldet, ist genau die Klasse, gegen die §1
dieses Slice *„nicht verhandelbar"* schreibt.

**Vier Plan-vs-Code-Deltas — benannt, nicht geglättet.**

1. **Die §3-Zeile „[`AGENTS.md`](../../../../AGENTS.md) update" stand auf einer falschen Prämisse.**
   Sie begründet sich mit *„beide beschreiben `make mutate` als **einen** Lauf gegen **eine**
   isolierte Kopie"*. Auf `AGENTS.md` trifft das nicht zu — gemessen gegen den Eltern-Commit:
   `git show 82d2ed7^:AGENTS.md | grep -c 'isolierte Kopie'` → **0**, und §4 verweist die
   Ziel-Beschreibungen ausdrücklich an [`harness/README.md`](../../../../harness/README.md)
   (*„Eine Aussage hat einen Ort"*). **Nicht ausgeführt und richtig so;** die Tabelle wird nicht
   nachträglich korrigiert — sie ist die Vor-Code-Aussage.
2. **Ein Bauteil entstand, das der Plan nicht vorzeichnet:** die serielle Spur mit
   `plan_self_contained`/`is_heavy_mode`. Der Plan nennt das **Problem** (§1, *„Docker ist die
   geteilte Ressource"*), nicht diese Lösung. Sie ist die **strengere** Antwort — ein Modus läuft
   nur parallel, wenn **jede** Zeile seines `make -n`-Plans ein `docker build` oder `docker run`
   ist — und trägt zwei eigene Zähne (194, 195). Die §3-Tabelle bekommt dafür **keine** Zeile
   nachgetragen.
3. **Der Plan-Satz „Die Zahl der Vorläufe bleibt dabei die heutige" ist falsifiziert** und in §1
   **gezogen**: gemessen 9 bei N=4 und 5 bei N=1 gegen 6 der sequentiellen Fassung. Die Richtung
   ist die sichere — die Deckung wächst —, der Satz war trotzdem falsch.
4. **Das Messprotokoll war zwischen dem 2026-08-26 und dieser Closure nicht fortgeschrieben**,
   obwohl §1 eine Zeile bei **jedem** gemessenen Lauf verlangt. Sieben Zeilen sind mit dieser
   Notiz nachgetragen. **Der Grund ist derselbe wie beim Nenner in
   [slice-106](../done/slice-106-rotes-ci-traegt-seinen-ausgang.md):** die Tabelle hat kein
   Kommando, das ihre Unvollständigkeit rot färbt. Wo nur eine Rolle nachträgt, trägt sie am Ende
   nach.

**Was der Slice nicht deckt — die Grenzen, die er für sich selbst zieht.**

- **Ein hängender Worker beendet den Lauf nicht.** Oben als Posten, in
  [`CO-003`](../../carveouts/CO-003-mutate-ohne-zeitschranke.md) als Register.
- **[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) ist über *zwei*
  Worker-Zahlen belegt, nicht über alle.** Was die Aussage trägt, ist nicht die Wiederholung,
  sondern die Vollständigkeits-Zeile, die jeder Lauf für sich selbst rechnet — der Unterschied
  gehört benannt, und die Verifikation benennt ihn ebenso.
- **Die Zeit-Aufschlüsselung ist eine Messung, kein Sensor.** Sie urteilt nur über ihre **eigene**
  Vollständigkeit. Ein Schwellenwert über Sekundenwerten stünde auf geteilter Hardware und wäre rot
  ohne Befund ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6))
  — §5 schließt ihn ausdrücklich aus.
- **Die Begrenzung je Worker (`GOMAXPROCS`) ist weiterhin ungemessen**, und §1 hatte sie zu DoD (1)
  gezählt. Sie ist **nicht** gefahren worden. Die Commit-Message von `82d2ed7` nennt ihre obere
  Schranke bei N=4 mit *„rund 120 s"* und bei N=8 mit *null* und verweist auf die serielle Spur als
  den größeren Hebel — **fremdbelegt, von dieser Rolle nicht nachgemessen**. Der Posten hat damit
  **keinen Träger**, und das steht hier, statt einen zu erfinden: wer ihn will, schneidet ihn.
- **Was ein Adopter bekommt, ist nicht berührt.** Der Treiber geht in kein Zielrepo (Kopfzeile
  *Ebene*).

**Steering-Loop-Eintrag — geschärfte Regel.**

**Eine Vollständigkeits-Zusage misst die Menge, über die sie spricht, nicht den Behälter, in dem
diese Menge liegt. Wer „N von M" schreibt, zählt N aus den Einträgen, die er wirklich gelesen hat,
und M aus dem Bestand, gegen den er zusagt — eine Prüfung über der *Existenz* einer Datei ist keine
Prüfung ihres *Inhalts*.**

**Der gemessene Anlass, und er liegt im Sensor der Sensoren.** `merge_report` zählte einen Fall als
bestanden, sobald `[ -f "$RUN_DIR/status.$i" ]` galt; `report_times` nahm `n="${#status_files[@]}"`
aus demselben Glob. Beide Zähler standen neben einer Zusage über eine **Menge** — *jeder Fall hat
ein Ergebnis*, *diese Bilanz umfasst alle Fälle* — und maßen einen **Behälter**. Der Fehler ist
**zweimal in derselben Datei und in demselben Commit** aufgetreten, an zwei Stellen, die getrennt
geschrieben wurden. Gefunden hat ihn **kein Gate**: `make mutate` war grün, weil sein eigener Fall
`191` den Datei-Pfad bewachte statt des Inhalts; gefunden haben ihn zwei Rollen, unabhängig
voneinander, beide durch **Herstellen** des Zustands.

**Warum ausgerechnet dieser Eintrag und nicht der neue Sensor.** `status_line_valid`/
`collect_status` samt den Fällen 196 und 197 wäre die andere zulässige Form — er ist aber die
**Behebung**, nicht die Lehre: er bewacht diese Datei, nicht die Klasse. Die Klasse ist eine
Verschärfung von [`AGENTS.md`](../../../../AGENTS.md) §3.6 um eine Achse, die dort fehlt: **die
Bezugsmenge einer Zusage**. §3.6 verlangt das rot gesehene Gegenbeispiel; es sagt nichts darüber,
dass zwischen dem Gezählten und dem Zugesagten ein Behälter liegen kann und der Zähler dann grün
ist, während die Menge unvollständig bleibt.

**Die Fläche, mit ihrer Eigenschaft vor der Zahl.** Die Eigenschaft: *ein Zähler, der seinen Wert
aus einem Behälter nimmt statt aus der Menge, über die die Zusage daneben spricht*. **Zwei**
Fundorte tragen sie mit Beleg, beide in derselben Datei. Ein Muster darüber liefert
`grep -rn '\${#[a-z_]*\[@\]}' harness/tools/*.sh | wc -l` → **11** Treffer über **3** Dateien — die
meisten sind Ober- oder Untergrenzen-Prüfungen und gar keine Vollständigkeits-Nenner. **Das Muster
trennt die Klasse nicht**, und deshalb ist die Zahl eine **Untergrenze mit Absicht**: ob ein Zähler
den Behälter oder die Menge misst, ist ein Urteil über den Zusammenhang von Zähler und Zusage
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 1 verlangt für eine Mengen-Aussage denselben Beleg wie für eine Zahl).

**Träger: [slice-101](../open/slice-101-norm-postens-bekommen-einen-termin.md) — als elfter Posten,
ausdrücklich nicht *„der Architect"*.** Jener Slice ist für genau diese Klasse geschnitten, trägt
seinen Termin selbst und verlangt in §3, dass ein weiterer Posten **vor** der ersten Entscheidung
aufgenommen wird und dabei steht, woran er erkannt ist. Er ist dort eingetragen, mit seiner Achse
und seinem Anlass; **der Regeltext wird hier nicht vorentschieden**, er entsteht im
Architect-Lauf ([`AGENTS.md`](../../../../AGENTS.md) §3.8,
[`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1). **Warum das kein
Feedforward-Posten ohne Träger ist:** eine Lehre, die nur in einer `done/`-Datei steht, liest kein
Lauf wieder — der Lifecycle bewegt Slices, nicht Nennungen, und
[slice-101](../open/slice-101-norm-postens-bekommen-einen-termin.md) ist der Slice, der diese
Bewegung herstellt.

**Übergabe an den Architect — eine, und sie ist keine Norm-Änderung dieser Rolle.** Der elfte
Posten in [slice-101](../open/slice-101-norm-postens-bekommen-einen-termin.md) ist der **Antrag**;
ob er in [`AGENTS.md`](../../../../AGENTS.md) §3.6 wandert, anders gefasst wird oder mit Grund
fällt, entscheidet der Architect am Text. Diese Closure hat weder §3 von
[`AGENTS.md`](../../../../AGENTS.md) noch den Adaptions-Block in
[`harness/conventions.md`](../../../../harness/conventions.md) angefasst.

**Folge-Slices und Register.** Ein neuer `open/`-Eintrag —
[slice-117](../in-progress/slice-117-lauf-ohne-ende-faerbt-rot.md) (ein Lauf, der nicht zu Ende kommt,
färbt sich selbst rot; und ein abgebrochener sagt nichts, was seine eigene Ausgabe widerlegt) —
und ein neuer Carveout,
[`CO-003`](../../carveouts/CO-003-mutate-ohne-zeitschranke.md), im Index von
[`docs/plan/carveouts/README.md`](../../carveouts/README.md) eingetragen. **Warum ein Carveout und
nicht nur ein Slice:** Modul 5 lässt den Übergang nach `done/` mit einem offenen Posten nur mit
**dokumentiertem Carveout** zu, und der Modul-7-Trichter führt hierher — eine **einzelne**,
abgrenzbare Diskrepanz (Frage 1) mit einem **ernst erreichbaren** Trigger (Frage 2). Der Carveout
ist zugleich das einzige Register dieses Repos, das pro Welle-Closure **wieder gelesen** wird; ein
Posten allein in einer `done/`-Datei wird es nicht. **Der Slice ist wellenlos** — die drei Fragen
aus [`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1 sind in seiner Kopfzeile einzeln beantwortet; die Roadmap bekommt daher keinen Eintrag
(ebenda Setzung 2/3).

**Gates.** Eigener Lauf über dem Baum, den diese Closure hinterlässt — Notiz, Befund und
Messprotokoll in §1, der elfte Posten in
[slice-101](../open/slice-101-norm-postens-bekommen-einen-termin.md),
[slice-117](../in-progress/slice-117-lauf-ohne-ende-faerbt-rot.md),
[`CO-003`](../../carveouts/CO-003-mutate-ohne-zeitschranke.md) und der Carveout-Index eingerechnet:
`make gates` **EXIT=0**, `baseline-verify: v3.5.2 OK — 42 Dateien`,
`d-check: 415 Datei(en) geprüft, 0 Befund(e)`, golangci-lint `0 issues.`, bats
`grep -c '^ok '` → **180** und `grep -c '^not ok'` → **0**,
`comment-claims: 46 Datei(en) geprueft, 0 Befund(e)`, `span-check` grün. Die Dateizahl des
Doku-Gates wandert mit dem Markdown-Bestand und ist **kein** Erwartungswert
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2); jede weitere Zeile an dieser Notiz verschiebt den Gate-Stempel, und der Lauf, der ihn
wieder bindet, gehört zu ihr. **Fremdbelegt und ausdrücklich nicht von dieser Rolle erhoben:**
`make mutate` nach dem Fix (**190 ok, 0 Befund(e)**, `MUTATE_SECONDS=570.37`) und die zwei
Kontrollpunkte zu
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) — sie stehen im
Messprotokoll in §1 mit ihrer Quelle.

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
