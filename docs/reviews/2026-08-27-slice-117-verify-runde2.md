# Verifikation slice-117, zweite Runde — hält die Fix-Runde, was sie behebt?

> `docs/reviews/**` ist doc-gate-exempt (MR-009 `codepaths.exempt-paths`, MR-011 `ids.exempt-paths`,
> gelesen in `.d-check.yml`) — bare IDs und Pfade stehen hier ohne Link-Pflicht. Dieser Bericht setzt
> bewusst **keine** Markdown-Links: der Slice liegt zur Berichtszeit in `in-progress/` und wandert mit
> der Closure.

**Rolle:** Verification (Modul 11), **zweite Runde**, frischer Kontext. **Datum:** 2026-08-27.
**Autor:** ai-harness-init-Team (pt9912).

**Gegenstand:** der committete Diff `9b9866bf4e781d41e11ec75db5749ae60e9b8a37`
(*„slice-117: die Fix-Runde"*) gegen `docs/plan/planning/in-progress/slice-117-lauf-ohne-ende-faerbt-rot.md`
§2 DoD (1)–(3) und §5 Closure-Trigger.
`git show 9b9866b --stat --format= | tail -1` → **9 files changed, 1689 insertions(+), 41 deletions(-)**.
HEAD war während **aller** Läufe dieses Berichts `9b9866bf4e781d41e11ec75db5749ae60e9b8a37`
(`git rev-parse HEAD`, vor und nach dem letzten Gate-Lauf gemessen).

**Was diese Rolle prüft:** ob das Gebaute die DoD erfüllt — nicht, ob es das Richtige ist (Validator),
und nicht den Diff gegen Plan, ADR und Hard Rules (Reviewer). Die Aussagen der schreibenden Rolle sind
hier **Eingabe**, nicht Ergebnis. **Jede Zahl unten ist selbst erhoben**, mit dem Kommando daneben. Der
einzige fremde Messwert ist das `make mutate`-Protokoll des aufrufenden Kontextes
(`…/scratchpad/mutate-fix3.log`, `wc -l` → **615**) — und aus ihm habe ich mit eigenen Kommandos
gezogen, statt seine Zusammenfassung zu übernehmen (§7).

**Der Review-Durchgang derselben Runde lief parallel** und liegt als
`docs/reviews/2026-08-27-slice-117-review-runde2.md` untrackt im Baum (mtime 17:19). **Ich habe ihn
nicht gelesen** — Rollen-Trennung ist Kontext-Trennung. Vier Zeilen daraus sind mir bei einer
repo-weiten `grep`-Messung über `MUTATE_STALL_SECONDS` unbeabsichtigt in die Ausgabe gelaufen; sie
haben keinen der Befunde unten ausgelöst, die alle aus eigenen Läufen stammen. Das offenzulegen ist
billiger, als es zu verschweigen.

---

## Ergebnis

| DoD | Runde 1 | Runde 2 | Kurz |
|---|---|---|---|
| **(1)** ein hängender Worker färbt den Lauf von selbst rot | TEILWEISE | **ERFÜLLT** | selbst gefahren: Exit 1 nach **17,27 s** ohne `timeout` von außen, Worker zweimal benannt (§2.1) |
| **(2)** der Bericht widerspricht nicht der eigenen Ausgabe | TEILWEISE | **TEILWEISE** | drei von vier Lagen sauber; in der vierten steht **`800 ok` über 400 Fällen** und die Vollständigkeits-Zeile **zweimal** (§3.4) |
| **(3)** jede Zeitschranke trägt einen Zahn | ERFÜLLT | **TEILWEISE** | die zwei **benannten** Schranken: ja, sechsmal rot gesehen. Die in dieser Runde **neu hinzugekommene** dritte: nein — ohne sie bleiben **187 von 187** bats-Fällen grün (§4.2) |

**Der Closure-Trigger aus §5 ist heute NICHT erfüllt.** Drei der zehn Zeilen halten nicht (§8).

**Die sechs Befunde der ersten Runde:** B-1 **behoben**, B-3 **behoben**, B-5 **behoben**,
B-2 **behoben**, B-4 **behoben (in der Aussage, nicht im Verhalten — so gewollt)**,
B-6 **nur zum kleineren Teil behoben**. B-7 (LOW) ist **unverändert** und im Treiber nicht
angefasst worden.

**Neun eigene Befunde** (§6): 6 MEDIUM, 3 LOW. Der rote Faden durch sie: **drei der sechs Fixes
dieser Runde haben keinen Zahn**, und der Zahn eines vierten misst nicht das, was sein Kommentar
zusagt. Das ist Prüfung 2 dieser Rolle — *deckt der Sensor die Zusage?* —, und sie greift hier
härter als in Runde 1.

---

## 1. Läufe — Kommando und Ergebnis

Alle Läufe Docker-only über `make` bzw. über `bash` (AGENTS.md §3.9, ADR-0003). **Kein
Produktionscode geändert, nichts committet.** Jede Manipulation lag ausschließlich in Kopien
**außerhalb** des Repos (`…/scratchpad/r2work/`, `…/scratchpad/r2bats/`).

**Arbeitsbaum, mit Uhrzeit.** `git status --porcelain | wc -l`:

| Zeitpunkt | Wert | Inhalt |
|---|---|---|
| vor dem ersten Gate-Lauf (16:43:56) | **0** | — |
| nach dem ersten Gate-Lauf | **0** | — |
| nach den sechs Mutations-Läufen und allen Treiber-Läufen | **0** | — |
| vor dem abschließenden Gate-Lauf | **1** | `?? docs/reviews/2026-08-27-slice-117-review-runde2.md` |
| nach dem abschließenden Gate-Lauf | **1** | dieselbe Datei |

Der eine Eintrag ist **fremd**: er stammt vom parallel laufenden Review-Durchgang (mtime 17:19), ich
habe den Pfad nicht angefasst. Alles, was ich selbst geschrieben habe, liegt im Scratchpad — bis auf
diesen Bericht, der als Werkstück dieser Rolle ausdrücklich angefordert ist und **untrackt** bleibt.

### 1.1 Bestands-Läufe über dem committeten Baum

| # | Kommando | Ergebnis |
|---|---|---|
| L1 | `/usr/bin/time -f 'GATES_SECONDS=%e' make gates` (16:44) | **EXIT=0**, **GATES_SECONDS=48.67**; `baseline-verify: v3.5.2 OK — 42 Dateien`; `d-check: 417 Datei(en) geprüft, 0 Befund(e)`; `comment-claims: 46 Datei(en) geprueft, 0 Befund(e)`; bats `grep -c '^ok '` → **187**, `grep -c '^not ok'` → **0**; `span-check` grün |
| L2 | dasselbe, am Ende (17:2x) | **EXIT=0**, **GATES_SECONDS=48.15**, `d-check: 418 Datei(en)` (die eine fremde untrackte Datei mehr), sonst identisch, bats **187 / 0** |
| L3 | `make test-bats` in unmutierter Kopie außerhalb des Repos | **EXIT=0**, **187 ok / 0 not ok**, **BATS_SECONDS=23.48** — die Grün-Kontrolle für alle Rot-Nachweise unten |

**Kein voller `make mutate`** (Auflage 1). Bestandszahlen selbst erhoben:
`ls -1 test/mutations/*.sh | wc -l` → **196** · `grep -c '^@test' test/mutate-driver.bats` → **46**
(Plan §3 nannte **39**) · `wc -l < harness/tools/mutate.sh` → **1496** (Plan §3 nannte **1252**).

### 1.2 Fixture

Eine Kopie des Repos außerhalb (`tar -cf - --exclude=./.harness/state --exclude=./.git .`,
`du -sh` → **13M**), darin drei synthetische Fälle mit `# verify: test-go`, dazu ein `make`-Stub auf
`$PATH`. Der Stub unterscheidet Trockenlauf (`-n` → `docker build .`), Grün-Vorlauf und Fall-Lauf am
`# mN`-Marker, den die Mutation in Zeile 1 des `Makefile` schreibt, und kann an jeder der drei Stellen
hängen. **Kontroll-Lauf Q0** (nichts hängt): `3 ok, 0 Befund(e)`, **EXIT=0** — gegen ihn stehen alle
hergestellten Lagen.

Für die bats-Rot-Nachweise eine zweite Kopie **mit** `.git` (`du -sh` → **52M**); ohne `.git` fällt
`driver: die Kopie traegt den Sensor-Bedarf inklusive .git` — eigener Fixture-Fehler, korrigiert, hier
nur genannt, damit die Zahl **187** nachvollziehbar bleibt.

---

## 2. DoD (1) — färbt ein Worker, der nicht zurückkommt, den Lauf von selbst rot?

**Urteil: ERFÜLLT.**

### 2.1 Der Rot-Nachweis in genau der Form, die der Punkt verlangt

Ein `make`-Stub, der für **genau einen** Fall nie zurückkehrt (`sleep 3600`), `MUTATE_STALL_SECONDS=10`,
`MUTATE_JOBS=2`, **kein `timeout` von außen**:

```
EXIT=1  DAUER=17.27 s
mutate: BEFUND  zeitschranke   seit 10 s hat kein Worker einen Fall gezogen oder abgeschlossen
                               — der Lauf steht. Noch laufend: Worker 2
mutate: BEFUND  worker-2       Worker endete mit Status 137 OHNE Abschluss-Marke …
mutate: BEFUND  vollstaendigkeit  ohne Ergebnis geblieben: 01-a …
mutate: 2 ok, 5 Befund(e)
```

Vier Zusagen des Punktes, jede geprüft:

| Zusage | Beleg |
|---|---|
| endet **ohne** Signal von außen | **EXIT=1 nach 17,27 s**; kein äußeres `timeout` im Kommando |
| Bericht benennt den **Worker** | *„Noch laufend: Worker 2"* und *„BEFUND worker-2"* |
| Bericht benennt die **überschrittene Schranke** | *„seit 10 s … der Lauf steht"* |
| Schranke an **einer** Stelle im Treiber, keine zweite Vorgabe im `Makefile` | `grep -n 'STALL_SECONDS=' harness/tools/mutate.sh` → **eine** Zeile (855); `grep -c 'MUTATE_STALL_SECONDS' Makefile` → **0**; `grep -c 'timeout-minutes' .github/workflows/ci.yml` → **0** |

### 2.2 B-1 — der Vorwärmlauf vor dem Fork: behoben, gemessen

Derselbe Stub, aber der Hänger sitzt im Vorwärmlauf vor dem Fork, `MUTATE_STALL_SECONDS=8`,
äußeres `timeout --foreground -k 10 90` **nur als Detektor**:

```
EXIT=1  DAUER=8.14 s
mutate: ABBRUCH — der Gruen-Vorlauf 'make test-go' hat die Zeitschranke von 8 s ueberschritten.
  Gemessen ist die Ueberschreitung, nicht ihr Grund.
```

**Der Lauf endet von selbst** (Exit 1, nicht 124/137), und er meldet die **Überschreitung**, nicht
*„der Baum ist rot"*. In Runde 1 stand derselbe Aufbau bei **Exit 137 nach 45 s** ohne jeden Bericht.

**Gegenprobe, selbst gefahren:** dieselbe Kopie mit `sed -i 's|timeout "$STALL_SECONDS" make |make |'`
→ **EXIT=137 nach 50,01 s**, Protokoll bleibt bei *„Gruen-Vorlauf make test-go"* stehen. Die Zeile
trägt also wirklich. **Was daran fehlt, steht in §4.2:** sie hat keinen Sensor.

### 2.3 B-5 — die Vorgabe ist geprüft, sieben Werte gemessen

`for v in abc 0 -5 1.5 "3 4" "" 42 900; do env MUTATE_STALL_SECONDS="$v" bash <kopie>/mutate.sh; done`
über einer nackten Treiber-Kopie:

| Vorgabe | EXIT | erste Zeile |
|---|---|---|
| `abc`, `0`, `-5`, `1.5`, `3 4` | **1** | `mutate: ABBRUCH — MUTATE_STALL_SECONDS ist keine Sekundenzahl >= 1 (gelesen: '…')` |
| `""`, `42`, `900`, ungesetzt | **1** | `mutate: … /test/mutations fehlt` — die Prüfung ist **passiert**, es fällt erst das fehlende Fall-Verzeichnis |

Die leere Vorgabe fällt also auf **900** zurück, statt bestraft zu werden — genau wie `MUTATE_JOBS`,
dessen Gegenprobe (`abc`, `0`, `-5`, `1.5`) dieselbe Meldung mit dem anderen Namen liefert. **Eine
Quelle, zwei Aufrufer** — `require_positive_int`. In Runde 1 ergab `abc` **null**
Zeitschranken-Befunde und einen Lauf, der nur von außen endete.

### 2.4 Der 124-Zweig: die Überschreitung ist von einem eigenen 124 **nicht** unterscheidbar

Derselbe Aufbau, aber der Stub kehrt **sofort** mit Status 124 zurück (`STUB_RC=124`),
`MUTATE_STALL_SECONDS=900`:

```
EXIT=1  DAUER=0.15 s
mutate: ABBRUCH — der Gruen-Vorlauf 'make test-go' hat die Zeitschranke von 900 s ueberschritten.
  Gemessen ist die Ueberschreitung, nicht ihr Grund.
```

**Nach 0,15 s meldet der Lauf eine überschrittene 900-Sekunden-Schranke.** `timeout` liefert 124 für
die eigene Zeitüberschreitung **und** reicht einen fremden 124 durch; der Zweig kann beides nicht
trennen, weil er nur den Status liest und keine Dauer misst. Die Meldung sagt ausdrücklich *„Gemessen
ist die Ueberschreitung"* — gemessen ist sie nicht. Das ist **B-8 unten** und dieselbe Klasse, die
derselbe Zweig auf der anderen Seite vermeidet.

**Wie wahrscheinlich das ist, ist gemessen und heute klein:** `grep -rn 'timeout' Makefile *.mk` → **0**
Fundstellen, kein Ziel dieses Repos endet heute mit 124. Der Zweig ist damit eine Zusage, die weiter
reicht als das, was ihn heute auslösen kann — nicht eine Fehldiagnose, die schon geschieht.

**Nebenbefund derselben Stelle:** beide Läufe drucken *„Die letzten Zeilen von make test-go:"* und
danach **nichts** — `show_tail` über einer leeren Datei schweigt. Über einem echten Hänger stünde dort
Ausgabe; über einem Stub, der nichts schreibt, kündigt die Zeile Zeilen an, die es nicht gibt.

### 2.5 Was `timeout` dort mit den Kindern macht — der Kommentar sagt das Gegenteil des Gemessenen

Der Kommentar über der Zeile: *„`timeout` schickt TERM an `make`; dessen Kinder ueberleben es,
dieselbe benannte Grenze wie bei stop_workers."*

Zwei Sonden mit demselben Skript (ein bash-Skript, das `sleep 300` im Vordergrund fährt):

```
timeout 2 bash sonde.sh              -> exit 124; ps: KEINE sleep-300-Instanz mehr
timeout --foreground 2 bash sonde.sh -> exit 124; ps: 3478349 sleep 300 (ppid 5511) LEBT
```

**GNU `timeout` ohne `--foreground` legt sich mit dem Kind in eine eigene Prozessgruppe und
signalisiert die ganze Gruppe** — die Kinder von `make` überleben es also gerade **nicht**. Der Code
benutzt die Form ohne `--foreground`; der Kommentar beschreibt die andere. Das ist die günstigere
Richtung, aber es ist nicht, was da steht (AGENTS.md §3.7: ein Kommentar beschreibt, was da ist).

**Was ich damit nicht behaupte:** dass ein hängender `docker build` dadurch endet. Container sind
Kinder des Daemons, nicht der Prozessgruppe; das habe ich **nicht gemessen** und sage es darum nicht.
Der Kommentar müsste genau diese Grenze nennen — nicht die, die er heute nennt.

### 2.6 Die Bemessung: die neue Herleitung ist von ihrem eigenen Beleg-Protokoll überholt

Die Arithmetik des Kommentars stimmt (selbst nachgerechnet):
`110,83 + 56,20 = 167,03`; `900 ÷ 167,03 = 5,39`.

**Ihre Eingangswerte stammen aber aus dem Lauf VOR dem Commit.** Gemessen über beiden Protokollen im
Scratchpad, je mit `sed -n '/Gruen-Vorlaeufe/,/Zeit je Fall/p'` (Maximum der dritten Spalte),
`grep 'untere Schranke'` und `grep MUTATE_SECONDS`:

| Protokoll | Fälle | längster Grün-Vorlauf | teuerster Fall | Gesamtlaufzeit |
|---|---|---|---|---|
| `mutate-117.log` (Stand `6020941`) | 193 | **110,83 s** (full-smoke) | **56,20 s** (152-cpp-lint-schichtfilter) | **648,70 s** |
| `mutate-fix3.log` (der Lauf, den **dieser** Commit als Beleg nennt) | 196 | **95,26 s** (full-smoke) | **80,24 s** (199-mutate-zeitschranke-greift-nie) | **744,07 s** |

Der Kommentar an HEAD führt **110,83 · 56,20 · 648,70 · 0,73** — vier Zahlen aus der linken Spalte.
Gegen die rechte gerechnet: `95,26 + 80,24 = 175,50 s`, `900 ÷ 175,50 = **5,13**`. Der teuerste Fall
ist **80,24 s**, nicht 56,20 s — und diese Zahl steht in der **Commit-Message desselben Commits**
(*„Mit eigenen Deskriptoren: 80,24 s und 62,04 s"*). Der ci-lint-**Fall** kostet **0,64 s**
(`grep 'ci-lint' <Zeit-je-Sensor-Block>`); die **0,73 s** im Kommentar sind der ci-lint-**Vorlauf**.

**Zweitens rechnet die Regel selbst über eine Paarung, die nicht auftreten kann.** Der Zug wird
protokolliert, dann läuft der Grün-Vorlauf **des gezogenen Modus**, dann der Fall **desselben Modus**
(`worker_main`). Vorlauf und Fall in einer Stille sind also **modus-gleich**. Modus-treu gerechnet über
`mutate-fix3.log`:

```
full-smoke: 95.26 + 53.71 = 148.97 s -> 900 / 148.97 = 6.04
test-bats:  24.34 + 80.24 = 104.58 s -> 900 / 104.58 = 8.61
test-go:     9.40 + 12.15 =  21.55 s
```

Die längste **mögliche** legitime Stille ist **148,97 s**, der Faktor **6,04**. Die Kreuz-Addition
zweier Maxima aus verschiedenen Modi ist konservativ und darum ungefährlich — aber sie ist nicht das,
was der Mechanismus erzeugt, und der Kommentar gibt sie als Messung aus.

**Die Schranke selbst bleibt tragfähig:** 900 s liegen in jeder der drei Rechnungen weit über der
gemessenen legitimen Stille, und der teuerste Fall (80,24 s) ist von 900 s weit entfernt.

---

## 3. DoD (2) — sagt der Bericht eines abgebrochenen Laufs nichts, was seine eigene Ausgabe widerlegt?

**Urteil: TEILWEISE ERFÜLLT.** Das mechanische Kriterium des Punktes hält in **allen vier** von mir
gefahrenen Lagen. Der **Satz** des Punktes hält in der vierten nicht.

### 3.1 Das Kriterium, das der Punkt selbst nennt — vier eigene Läufe

`grep -cE '^mutate: \[w[0-9]+\] .* (OK|BEFUND) \('` gegen die Ergebnis-Zeile desselben Protokolls:

| Lauf | Fortschrittszeilen | Bericht |
|---|---|---|
| Zeitschranke greift mitten in `run_case` (3 Fälle) | **0** | *„0 von 3 Fall-Dateien haben ein Ergebnis"* ✓ |
| Hänger ohne äußeres `timeout` (3 Fälle) | **2** | *„2 von 3 Fall-Dateien haben ein Ergebnis"* ✓ |
| `kill -INT` während der Fall-Phase (400 Fälle) | **352** | *„352 von 400 Fall-Dateien haben ein Ergebnis"*, `352 ok` ✓ |
| `kill -INT` während `report_times` (400 Fälle) | **400** | *„400 von 400 …"* — **zweimal** —, und `800 ok` ✗ |

### 3.2 B-3 — das falsche Fall-Urteil im Abbruch-Pfad: behoben, mit Kontroll-Arm gefahren

Die Lage aus Runde 1 hergestellt: die Zeitschranke greift, **während** ein Worker mitten in `run_case`
sitzt. Fixture: `SLOW_CASE=1 SLOW_SECONDS=6 MUTATE_STALL_SECONDS=2 MUTATE_JOBS=1`, drei Fälle, der
erste braucht 6 s. Beide Arme über **derselben** Fixture, Kontrolle Q0 meldet für alle drei `ok`.

**Arm A (HEAD):** EXIT=1 nach **6,42 s**

```
mutate: BEFUND  zeitschranke   … Noch laufend: Worker 1
mutate: BEFUND  worker-1       Worker endete mit Status 143 OHNE Abschluss-Marke …
mutate: BEFUND  vollstaendigkeit  ohne Ergebnis geblieben: 01-a 02-b 03-c
mutate: 0 ok, 5 Befund(e)
```

Stub-Aufrufe: `prerun`, `case1` — **zwei**. Kein Fall-Urteil, kein weiterer Zug.

**Arm B (dieselbe Fixture, Worker-Traps auf `worker_cleanup` zurückgesetzt = Mutation 201):**
EXIT=1 nach **6,44 s**

```
mutate: [w1] 01-a   BEFUND (6.06 s)
mutate: [w1] 02-b   OK (0.05 s)
mutate: [w1] 03-c   OK (0.05 s)
grep: …/verify.log: Datei oder Verzeichnis nicht gefunden
mutate: BEFUND  01-a   rot, aber 'TestFall1' faellt nicht — falscher Grund
tail: …/verify.log kann nicht zum Lesen geöffnet werden …
mutate: 2 ok, 2 Befund(e)
```

Stub-Aufrufe: `prerun`, `case1`, `case2`, `case3` — **vier**.

**Damit sind beide Fragen des Auftrags beantwortet und nicht erschlossen:** der Fall meldet an HEAD
**kein** Urteil, und der Worker zieht **keinen** weiteren Fall. Der Kontroll-Arm zeigt daneben, dass
die Fixture den Defekt wirklich auslöst — inklusive der zwei rohen `grep`/`tail`-Zeilen aus Runde 1.

### 3.3 B-4 — das zweite Ctrl-C: das Verhalten ist gleich, die Ausgabe stimmt jetzt

INT #1 bei t=2,47 s (Worker sitzt in einem 20-Sekunden-`make`, `stop_workers` wartet seine fünf
Sekunden ab), INT #2 1,5 s später:

```
EXIT=130  DAUER=4.63 s
mutate: ABBRUCH — INT empfangen. Berichtet wird, was bis hierher gemessen ist.
mutate: zweites INT waehrend des Berichts — Abbruch OHNE Bericht.
```

Der Bericht wird weiterhin verworfen — aber die Ausgabe sagt es jetzt, statt die Zusage der Zeile
darüber stillschweigend zu brechen. **Für DoD (2) ist das die richtige Sorte Antwort:** die Ausgabe
widerspricht ihrer eigenen nicht mehr. Dass die Frist von fünf Sekunden dem Nutzer nicht genannt wird,
bleibt eine offene Nutzer-Frage — aber keine DoD-(2)-Verletzung.

### 3.4 B-6 — der Doppel-Bericht ist an HEAD reproduziert

Der Guard `BERICHT_GEFAHREN=1` steht **hinter** `report_times`. Runde 1 hatte das Fenster als *„die
Zeit zwischen dem **Beginn** des regulären Berichts und dem Prozess-Ende"* benannt; geschlossen ist
davon nur das Ende.

Fixture: 400 synthetische Fälle, `MUTATE_JOBS=1`. Fensterbreite selbst gestoppt (Polling 0,02 s,
`date +%s.%N` an beiden Rändern):

```
letzte Fortschrittszeile -> Vollstaendigkeit: 6.79 s
Vollstaendigkeit        -> Prozess-Ende:      0.95 s
ganzes Berichtsfenster:                       7.74 s
```

`kill -INT`, sobald die Zeile *„Vollstaendigkeit —"* im Protokoll steht:

```
EXIT=130
Fortschrittszeilen: 400        (grep -cE '^mutate: \[w1\] .* (OK|BEFUND) \(')
'Vollstaendigkeit —'-Zeilen: 2 (grep -c)
'mutate: ok'-Zeilen: 800       (grep -cE '^mutate: ok ')
mutate: Vollstaendigkeit — 400 von 400 Fall-Dateien mit Ergebnis, jede Fall-ID genau einmal gezogen.
mutate: ABBRUCH — INT empfangen. Berichtet wird, was bis hierher gemessen ist.
mutate: Vollstaendigkeit — 400 von 400 Fall-Dateien mit Ergebnis, jede Fall-ID genau einmal gezogen.
mutate: 800 ok, 0 Befund(e) — ABGEBROCHEN, keine vollstaendige Messung.
```

**`800 ok` über 400 Fällen, der ganze Bericht zweimal.** Das ist der Befund aus Runde 1 in
größerem Maßstab und an HEAD — dieselbe Klasse, gegen die DoD (2) geschnitten ist. Die
Commit-Message sagt *„ein Signal nach dem Bericht wiederholt ihn nicht mehr"*; das stimmt für die
**letzten rund 0,2 s** eines **7,74 s** breiten Fensters.

**Zur Fairness zweierlei:** erstens hält das **wörtliche** Rot-Kriterium von DoD (2) auch hier — die
*Fälle mit Ergebnis* sind 400, und 400 Fortschrittszeilen stehen darüber. Zweitens skaliert das
Fenster mit der Fall-Zahl; über den echten 196 Fällen ist es kleiner als über 400. Beides ändert
nichts daran, dass **`800 ok` von der eigenen Ausgabe widerlegt wird**.

---

## 4. DoD (3) — trägt jede Zeitschranke einen Zahn?

**Urteil: TEILWEISE ERFÜLLT.**

### 4.1 Die zwei benannten Schranken: ja, sechsmal rot gesehen

`grep -rln 'QUEUE_LOCK_TRIES' test/ | wc -l` → **2** (`test/mutate-driver.bats`,
`test/mutations/198-…`). Je Mutation eine `make test-bats`-Runde in der isolierten Kopie, danach
zurückgespielt; Kontrolle **187 ok / 0 not ok**:

| Fall | EXIT | ok / not ok | Sekunden | gefallener Test == `# expect:` |
|---|---|---|---|---|
| `198` Mutex-Schranke | 2 | 186 / 1 | 23,54 | ✓ |
| `199` Stille rechnet zu null | 2 | 185 / **2** | 79,21 | ✓ (der benannte **und** *„das Einsammeln endet OHNE Hilfe von aussen"*) |
| `200` Signal räumt vor dem Bericht | 2 | 186 / 1 | 24,61 | ✓ |
| `201` Worker-Trap kehrt zurück | 2 | 186 / 1 | 23,75 | ✓ |
| `202` Einsammeln ohne Schranke | 2 | 186 / 1 | 62,55 | ✓ |
| `203` Zeit-Vorgabe ungeprüft | 2 | 186 / 1 | 23,74 | ✓ |

**Sechsmal fällt genau der Test, den die `# expect:`-Zeile nennt.** Bei `199` fällt ein Nachbar mit —
`collect_workers` hängt an `await_workers`, das ist die Kopplung selbst und kein Fehler; der Treiber
prüft ohnehin nur, ob der benannte Test in der Fehlschlag-Ausgabe steht. In Runde 1 riss noch keine
Mutation einen Nachbarn mit; das ist der Preis dafür, dass die zwei Zusagen jetzt in **einer**
Funktion liegen, und er ist billig.

### 4.2 Die dritte, in dieser Runde neu hinzugekommene Schranke: kein Zahn

`green_prerun` trägt seit diesem Commit `timeout "$STALL_SECONDS" make "$m"`. Selbst gefahren, in der
isolierten Kopie, mit `sed -i 's|timeout "$STALL_SECONDS" make |make |'`:

```
make test-bats  ->  EXIT=0, 187 ok / 0 not ok, 23.26 s
```

**Kein einziger Test fällt.** Dass die Zeile trägt, ist in §2.2 gemessen (mit ihr: Exit 1 nach
8,14 s; ohne sie: Exit 137 nach 50,01 s, kein Bericht). Es gibt weder einen bats-Fall
(`grep -n 'ueberschritten\|Zeitschranke von\|Ueberschreitung' test/mutate-driver.bats` → **keine
Zeile**) noch einen Mutations-Fall (`grep -rln 'timeout' test/mutations/` → **keine Datei**).

**Zwei Lesarten von DoD (3), und der Planner soll die Wahl sehen:** die **Aufzählung** (*„Beide —
`QUEUE_LOCK_TRIES` und die aus (1)"*) ist erfüllt; die **Überschrift** (*„Jede Zeitschranke des
Treibers trägt einen Zahn"*) ist es nicht mehr, weil dieser Slice selbst eine dritte angelegt hat.
Ich werte nach der Überschrift, weil sie die Zusage ist und die Aufzählung nur der Stand bei
Planungsschluss war.

### 4.3 Zwei weitere neue Wächter dieses Commits, beide ohne Zahn

Dieselbe Methode, je eine `make test-bats`-Runde:

| entfernt | Ergebnis |
|---|---|
| `BERICHT_GEFAHREN=1` (der B-6-Guard) | **187 ok / 0 not ok** |
| `echo "mutate: zweites $sig waehrend des Berichts …"` (der B-4-Fix) | **187 ok / 0 not ok** |

Zusammen mit §4.2: **drei der sechs Fixes dieser Runde sind unbewacht.** Der Commit sagt zu
*„jeder der acht Zaehne dieses Slice faerbt seinen benannten Test rot"* — das ist wahr für die acht,
die es gibt, und sagt nichts über die drei Zusagen, für die keiner existiert.

### 4.4 Der Zahn zum *Enden* misst nicht, was sein Kommentar zusagt

`collect_workers` und der bats-Fall *„driver: das Einsammeln endet OHNE Hilfe von aussen"* führen
beide dieselbe Begründung: *„`timeout` ist hier DETEKTOR … Status 124 heisst, der Lauf haette ohne
Hilfe von aussen nicht geendet."*

**Im gepinnten bats-Image gibt es keinen Status 124.** Selbst gemessen im Image, das `make test-bats`
fährt:

```
docker run --rm --network none --entrypoint /bin/sh \
  bats/bats@sha256:e8f18e0acd4ea933bf019130b85033be75e8ce081db299e93578de83d7874e33 \
  -c 'ls -l $(command -v timeout); timeout 1 sleep 5; echo exit=$?'

/usr/bin/timeout -> /bin/busybox
BusyBox v1.36.1
Terminated
exit=143
```

Und im Lauf selbst: eine Sonde in der **Kopie** (`echo "# SONDE-STATUS=$status" >&3` vor der
Assertion) unter Mutation 202 meldet

```
# SONDE-STATUS=143 SONDE-OUT=[]
not ok 151 driver: das Einsammeln endet OHNE Hilfe von aussen
# (in test file test/mutate-driver.bats, line 800)
#   `grep -qF 'worker-beendet' <<<"$output"' failed
```

**Zeile 799 ist `[ "$status" -ne 124 ]` und sie hält; rot wird Zeile 800.** Der Zahn beißt — aber
nicht mit dem Zahn, den zwei Kommentare und der Commit ihm zuschreiben. Die Eigenschaft *„endet ohne
Hilfe von außen"* wird hier über die **leere Ausgabe** eines getöteten Prozesses gemessen, nicht über
einen Status, den dieses Image nie liefert. Das ist die Klasse aus AGENTS.md §3.6 — ein Test, dessen
Name und Begründung eine Eigenschaft führen, während die benannte Messung unter keiner Mutation
greifen kann.

### 4.5 Derselbe Statuswert 143 ist auch die Zusage des Nachbar-Tests — und der Sensor kann selbst hängen

*„driver: ein Worker unter TERM meldet KEIN Fall-Urteil"* prüft `[ "$status" -eq 143 ]` unter
`timeout 25`. Da BusyBox-`timeout` bei Ablauf **ebenfalls 143** liefert, sind *„der Worker ist auf TERM
ausgestiegen"* und *„der Test lief in seine Zeitschranke"* über den Status nicht trennbar.

Sonde in der Kopie: `worker_on_signal` so verändert, dass der TERM-Zweig **hängt** statt zu beenden
(`*) sleep 300 ;;`). `make test-bats`:

```
ok 152 driver: eine unsinnige MUTATE_STALL_SECONDS-Vorgabe BRICHT AB …
make: *** [Makefile:55: test-bats] Beendet          <- nach 600 s vom Aufrufer abgebrochen
ok=152 notok=0
```

Der Lauf blieb bei Test **153** stehen und war nach **600 s** nicht fertig; die Kontrolle braucht
**23,48 s**. Das eigene `timeout 25` des Tests hat ihn nicht begrenzt — es schickt TERM, und ein
Prozess, dessen TERM-Handler blockiert, ist davon nicht zu beenden (kein `-k`). **Der Sensor dieses
Slice kann damit genau die Lage erzeugen, gegen die der Slice geschnitten ist:** ein Lauf ohne Ende.
Ich habe danach `docker ps` geprüft (leer) und die Kopie zurückgespielt.

---

## 5. B-7 — die verwaiste Enkel-Instanz: unverändert

Der Auftrag fragt, ob das noch gilt. **Es gilt.**

Hänger im Fall (`SLOW_SECONDS=300`), `MUTATE_STALL_SECONDS=4`, Ausgabe durch eine **Pipe**
(`… 2>&1 | cat > datei`), wie es `make mutate 2>&1 | tee` oder eine CI-Schritt-Ausgabe tut. Der
Treiber schreibt seinen vollständigen Bericht bis `mutate: 0 ok, 5 Befund(e)` — und **25,00 s später
lebt die Pipeline noch**. Direkt belegt:

```
/proc/4146694/fd/   (verwaister make-Stub, Kind des beendeten Workers)
  1 -> …/verify.log (deleted)
  2 -> …/verify.log (deleted)
  3 -> pipe:[39414713]

/proc/4146555/fd/   (das wartende cat)
  0 -> pipe:[39414713]
```

Dieselbe Pipe-Inode auf beiden Seiten. Nach dem gezielten Beenden genau dieser zwei Prozesse
(4146694 und sein Kind 4146698) war die Pipeline **sofort** beendet — die Kausalität ist damit
gemessen, nicht erschlossen.

**Im Treiber ist nichts dagegen unternommen worden.** Der neue README-Satz nennt die Grenze
(*„beendet wird der Worker, nicht dessen Kinder"*), aber weder er noch der Kommentar an
`stop_workers` nennt die **Folge für den Aufrufer**: der Lauf endet, sein Ausgabe-Kanal nicht. Ein
`3>&-` am `make`-Aufruf im Worker — dieselbe Zeile, die der Implementer in seinen eigenen bats-Fällen
gerade eingezogen hat — schlösse es.

---

## 6. Eigene Befunde

| # | Schwere | Kurz | Beleg |
|---|---|---|---|
| **V-1** | MEDIUM | die neue Vorlauf-Schranke hat **keinen Zahn** | §4.2 — ohne sie **187/187** grün; Gegenbeispiel gefahren |
| **V-2** | MEDIUM | der B-6-Guard schließt nur das Ende eines **7,74 s** breiten Fensters; `800 ok` über 400 Fällen an HEAD reproduziert | §3.4 |
| **V-3** | MEDIUM | der als **Detektor** benannte Status 124 kann im gepinnten Image nie auftreten (BusyBox → 143) | §4.4 |
| **V-4** | MEDIUM | `[ "$status" -eq 143 ]` ist auch der Status einer Zeitüberschreitung; der Sensor kann selbst hängen (**> 600 s** gegen **23,48 s**) | §4.5 |
| **V-5** | MEDIUM | der 124-Zweig meldet nach **0,15 s** eine überschrittene **900 s**-Schranke, wenn `make` selbst 124 liefert | §2.4 |
| **V-6** | MEDIUM | die Herleitung der Schranke steht auf den Zahlen des **vorigen** Laufs; das vom Commit selbst zitierte Protokoll sagt 95,26 / 80,24 / 744,07 | §2.6 |
| **V-7** | LOW | zwei neue Guards (B-4-Meldung, `BERICHT_GEFAHREN`) ohne Zahn | §4.3 |
| **V-8** | LOW | *„`timeout` schickt TERM an `make`; dessen Kinder ueberleben es"* — gemessen falsch für die Form, die dort steht | §2.5 |
| **V-9** | LOW | rohe Job-Control-Meldung der Shell mitten im Bericht: `mutate.sh: Zeile 921: 3085 Getötet ( worker_main … )` — in **zwei** meiner Läufe, nach dem harten `kill` in `stop_workers` | §2.1, §5 |

**Vier davon sind Verifier-only** im Sinne von Modul 11 — sie treten nur beim **Fahren** hervor und
sind im Diff nicht zu sehen: V-2 (das Fenster), V-3 und V-4 (das Verhalten des `timeout` **im
gepinnten Image**), V-9. V-1 und V-7 sind es ebenfalls, wenn man das Entfernen-und-Fahren als Fahren
zählt.

---

## 7. Plan-vs-Code-Diff, in beide Richtungen

### 7.1 Geplant und gebaut

| Plan §3 | Ist |
|---|---|
| `harness/tools/mutate.sh` update | ✓ **+173/−41** Zeilen |
| `test/mutate-driver.bats` update | ✓ **+110** Zeilen, **46** `@test` (Plan: 39) |
| `test/mutations/` neu | ✓ **201, 202, 203**; **198** inhaltlich verankert statt an einer Zeilennummer |
| `.github/workflows/ci.yml` **unverändert** | ✓ `grep -c 'timeout-minutes' .github/workflows/ci.yml` → **0** |
| `docs/plan/adr/` **unverändert** | ✓ nicht im Diff |
| `roadmap.md` **unverändert** | ✓ nicht im Diff |

### 7.2 Geplant, aber nicht gebaut

- **`CO-003` — weder `git mv` noch update.** Der Plan §3 lässt beides zu, §5 verlangt eines von
  beiden. Die Datei trägt weiter `**Status:** Aktiv.` und `**Letzte Prüfung:** 2026-08-27 (Anlage)`.
  Ausführlich in §8.2.
- **Mitnahme 3 des Plans ist rückwärts gegangen.** Der Plan listet *„drei Stellen erzählen die
  Geschichte eines Vorgängers"* mit der Auflage *„wer sie ohnehin anfasst, zieht sie nach"*. Die
  Plan-Zahl ist bestätigt (`grep -cE 'erste[rn]? Entwurf|Vorgaenger'` an `82d2ed7`: mutate.sh **1**,
  bats **2**). An HEAD: mutate.sh **2**, bats **3**. Über die weitere Familie
  (`'erste[rn]? Entwurf|frueheste[rn]? Entwurf|Vorgaenger|frueher hier stehende|die frueher'`):
  **6 → 10**, also **vier neue** — darunter `mutate.sh:844` (*„die frueher hier stehende Herleitung
  mass die kleinere der beiden Groessen"*), `mutate.sh:909`, `bats:780`, `bats:848`. Es sind
  **neu geschriebene** Kommentare, also vom Cutoff aus AGENTS.md §3.7 gebunden. Die Norm-Wertung ist
  Reviewer-Achse; hier zählt, dass ein ausdrücklicher Plan-Posten in die Gegenrichtung gelaufen ist.
- Mitnahme 1, 2 und 4 sind unberührt geblieben — plan-konform, weil die Stellen nicht angefasst
  wurden (`mode_rank` kommt im Diff nicht vor; die vierte `merge_report`-Begründung steht unverändert
  in `:1144`; die Kopfzeile *„aus einer gemeinsamen Warteschlange"* in `:1443`).

### 7.3 Gebaut, aber nicht geplant

- **`harness/README.md`** — in §3 nicht gelistet, in §5 aber verlangt. Kein Widerspruch, nur ein
  Posten, den die Tabelle nicht führt.
- **Die Vorlauf-Schranke ist eine `Dauer`-Schranke, und Frage A des Plans hat Dauer-Schranken
  ausdrücklich verworfen.** §3 A: *„Beide angebotenen Orte haben denselben Fehler: sie bemessen eine
  **Wanduhr**"*, und weiter: um `run_case` *„müsste sie je Modus verschieden sein … und jede dieser
  Zahlen wäre auf einem langsamen Runner eine eigene Fehlschlag-Quelle"*. Genau eine solche Schranke
  steht jetzt um `make "$m"` im Vorlauf — mit dem Wert, der für **Stille** hergeleitet wurde. Heute
  ohne Risiko (längster Vorlauf **95,26 s** gegen **900 s**), aber der Plan sagt etwas anderes als
  der Code, und die Begründung dafür steht in keinem der beiden.
- `require_positive_int` als gemeinsame Prüfung auch für `MUTATE_JOBS` (Refactor über den DoD hinaus,
  fachlich sauber und getestet).
- `collect_workers` als eigene Funktion (Umbau über den DoD hinaus, mit Zahn 202).
- **Zwei Berichte fremder Rollen** (`docs/reviews/2026-08-27-slice-117-review.md`,
  `…-verify.md`, zusammen **1404** Zeilen) liegen im selben Commit wie der Produktionscode. Kein
  Regelverstoß, den ich benennen könnte — AGENTS.md §3.8 bindet nur Hard Rules und Adaptions-Block —,
  aber es macht `git log --stat` für diesen Commit unschärfer.

---

## 8. Closure-Trigger aus Plan §5 — Zeile für Zeile

| # | Zeile | Urteil |
|---|---|---|
| 1 | DoD (1)–(3) erfüllt mit gefahrenen Kommandos | **NEIN** — (1) ja, (2) und (3) teilweise (§2–§4) |
| 2 | der hergestellte Hänger ist einmal **ohne Signal von außen** rot gesehen | **JA** — EXIT=1 nach 17,27 s, selbst gefahren (§2.1) |
| 3 | der abgebrochene Lauf ist einmal gefahren, Bericht gegen sein Protokoll gehalten | **JA** — vier Läufe (§3.1) |
| 4 | Frage A, B, C mit Begründung im Plan beantwortet | **JA für den Plan-Text** — aber der Code weicht bei **A** ab und die Zahlen zu **B** sind im Kommentar überholt (§7.3, §2.6). Ob das den Plan ändert, entscheidet der Planner |
| 5 | `CO-003` aufgelöst **oder** mit neuem Trigger und Prüfdatum bestätigt | **NEIN** — unangetastet (§8.2) |
| 6 | `harness/README.md` trägt die Schranke | **JA, mit zwei Nuancen** (§8.1) |
| 7 | Review konform (Modul 10) | **nicht meine Achse** — läuft parallel |
| 8 | Verifikation bestätigt (Modul 11) | **NEIN** — dieser Bericht |
| 9 | `make gates` grün | **JA** — EXIT=0, 48,15 s, bats 187/0 |
| 10 | `git mv` nach `done/` als eigener Move-Commit, Closure-Notiz mit Steering-Loop-Eintrag | offen (nach 1–8) |

### 8.1 `harness/README.md` — hält die Aussage, was der Code hält?

Der neue Satz, drei Behauptungen, alle gegen eigene Läufe geprüft:

| Behauptung | Beleg |
|---|---|
| *„vergehen `MUTATE_STALL_SECONDS` … ohne dass ein Worker einen Fall zieht oder abschließt, beendet der Lauf **sich selbst**, benennt die noch laufenden Worker und wird rot"* | ✓ §2.1 — *„Noch laufend: Worker 2"*, EXIT=1 |
| *„Die Schranke deckt auch den Grün-Vorlauf, einschließlich des Vorwärmlaufs vor dem Fork."* | ✓ §2.2 — aber sie deckt ihn als **Dauer**-Schranke, während der Satz davor von **Stille** spricht. Ein Vorlauf, der Fortschritt macht und trotzdem > 900 s braucht, fiele ihr zum Opfer; heute gibt es keinen (95,26 s) |
| *„beendet wird der **Worker**, nicht dessen Kinder — ein hängendes `make` überlebt ihn"* | ✓ §5 — der Stub lebte nach dem Lauf weiter. **Unerwähnt bleibt die Folge:** dieses Kind hält Deskriptor 3 und damit die Pipeline des Aufrufers offen (B-7) |

*„Vorgabe im Treiber"* ist belegt: `grep -c 'MUTATE_STALL_SECONDS' Makefile` → **0**.

### 8.2 `CO-003` — der Auflösungs-Trigger misst seinen Gegenstand nicht

Der im Auftrag genannte Befund ist **nachgeprüft und trifft zu.**

**Bedingung 1** lautet: *„`grep -c 'timeout' harness/tools/mutate.sh` liefert **> 0**, und die
Fundstelle ist die Schranke, die das Warten auf die Worker begrenzt (nicht der
Warteschlangen-Mutex)."*

```
an HEAD (9b9866b): grep -c 'timeout' harness/tools/mutate.sh              -> 4
an 6020941:        git show 6020941:harness/tools/mutate.sh | grep -c …   -> 0
an 82d2ed7:        git show 82d2ed7:harness/tools/mutate.sh | grep -c …   -> 0
```

Die vier Fundstellen an HEAD, mit ihrer Funktion (`awk '/^[a-z_]+\(\) \{/{fn=$1} /timeout/{…}'`):

```
622  green_prerun  # … endete NUR durch ein `timeout` von aussen …      (Kommentar)
625  green_prerun  # `timeout` schickt TERM an `make` …                  (Kommentar)
628  green_prerun  ( cd "$WORK" && timeout "$STALL_SECONDS" make "$m" )  (CODE — der Gruen-Vorlauf)
912  (vor collect_workers)  # faehrt diese Funktion unter `timeout` …    (Kommentar)
```

Und die tatsächliche Warte-Schranke enthält das Wort nicht:
`sed -n '/^await_workers()/,/^}/p' harness/tools/mutate.sh | grep -c 'timeout'` → **0**;
dasselbe über `collect_workers` → **0**.

**Damit misst Bedingung 1 in beide Richtungen falsch.** An `6020941` sagte sie **0**, obwohl die
Reparatur da war und der hergestellte Hänger von selbst rot wurde (Runde 1, §2.2). An HEAD sagt sie
**4** — aus drei Kommentarzeilen und **einer** Code-Zeile, die den **Grün-Vorlauf** begrenzt und
nicht das Warten auf die Worker. Sie prüft die Anwesenheit eines **Wortes**, ihr Gegenstand ist eine
**Eigenschaft**. Das ist dieselbe Klasse wie AGENTS.md §3.6 und wie die Lehre *„ADR nennt keine
Slices"*: eine Adresse statt einer Eigenschaft.

**Bedingung 2** — *„Ein Lauf über einer Kopie mit einem `make`-Stub, der für genau einen Fall nicht
zurückkehrt, endet ohne `timeout` von außen mit Exit ≠ 0 und benennt den Worker"* — **misst richtig
und ist erfüllt** (§2.1: EXIT=1 nach 17,27 s, *„Noch laufend: Worker 2"*).

**Bedingung 3** — `grep -rln 'QUEUE_LOCK_TRIES' test/ | wc -l` → **2** ≥ 1 — **erfüllt**.

**Was daraus für die Closure folgt.** Der Carveout kann heute **nicht** über seinen eigenen Trigger
aufgelöst werden, ohne dass jemand eine Bedingung anwendet, die ihren Gegenstand nicht misst — und
ihn deshalb aufzulösen wäre genau die stille Grün-Meldung, gegen die der Carveout angelegt wurde.
Drei Wege stehen offen, und die Wahl gehört nicht mir:

1. **Bedingung 1 durch eine Eigenschaft ersetzen** und den Carveout dann auflösen. Eine Formulierung,
   die messen würde, was gemeint ist: *„das Warten auf die Worker steht unter einer Schranke, die den
   Lauf ohne Zutun von außen beendet — belegt durch Bedingung 2 und durch einen `test/mutations/`-Fall,
   der die Verdrahtung entfernt und den benannten bats-Fall rot färbt"*. Beides existiert heute
   (`202` → *„das Einsammeln endet OHNE Hilfe von aussen"*, §4.1). Eine solche Änderung ist eine
   **Trigger-Änderung** am Carveout und damit dieselbe Entscheidung wie der zweite Ausgang, den
   `CO-003` selbst dem **Architect** zuweist.
2. **Den Carveout mit neuem Trigger und neuem Prüfdatum bestätigen** — der zweite Ausgang, den Plan
   §5 ausdrücklich als gleichwertig zulässt. Das ist der kleinste Schritt und schließt Zeile 5 des
   Closure-Triggers.
3. **Nichts tun** — dann bleibt Zeile 5 offen und die Closure blockiert.

**Nicht haltbar ist**, Bedingung 1 an ihrer Zahl abzuhaken: die **4** kommt aus einer Zeile, die
nicht die Reparatur ist, plus drei Kommentaren. Ein Haken darauf wäre ein grüner Beleg für etwas
anderes als die geprüfte Sache.

---

## 9. Aufräumen — was ich beendet habe

Auflage 4 des Auftrags. **Vor jedem `kill` habe ich die Kandidaten mit `ps -o args=`/`ps -o ppid=`
identifiziert und je PID gehandelt; kein `pkill`, kein Muster über die Prozessliste.**

| PID | Was | Herkunft |
|---|---|---|
| 3478349 | `sleep 300` | verwaistes Enkelkind meiner `timeout --foreground`-Sonde (§2.5) |
| 4146694, 4146698 | `bash …/r2work/bin/make test-go`, `sleep 300` | verwaister Stub der B-7-Messung (§5) |
| 3213, 3230 | `bash …/r2work/bin/make test-go`, `sleep 3600` | verwaister Stub des `CO-003`-Bedingung-2-Laufs |
| 20842 + Kind | `bash …/r2work/bin/make test-go` | verwaister Stub des Gegenbeispiel-Laufs (§2.2) |

**Ausdrücklich NICHT beendet:** PID **3421050**, `sleep 3600`, PPID **3921** =
`/bin/sh /snap/cups/1238/scripts/run-cups-browsed`. Er lief schon vor meinem ersten Lauf
(`etimes` 280 s zu einem Zeitpunkt, an dem meine Fixture 30 s alt war) und gehört nicht zu diesem
Repo. Er ist beim ersten Blick auf die Prozessliste aufgefallen und stehen geblieben — das ist der
Fehler aus Runde 1, hier bewusst vermieden.

Ein `make test-bats` der Sonde aus §4.5 musste vom Aufrufer nach 600 s beendet werden. Danach
geprüft: `docker ps` → leer, `docker ps -a --filter ancestor=bats/bats` → leer, die Kopie
zurückgespielt (`diff -q` gegen den Repo-Stand: gleich).

**Alle Kopien liegen außerhalb des Repos** (`…/scratchpad/r2work/`, `…/scratchpad/r2bats/`); der
Arbeitsbaum trägt am Ende dieselbe eine fremde untrackte Datei wie am Anfang dieses Abschnitts
(§1).

---

## 10. Gesamturteil

**DoD (1) ERFÜLLT · DoD (2) TEILWEISE ERFÜLLT · DoD (3) TEILWEISE ERFÜLLT.
Der Closure-Trigger aus §5 ist NICHT erfüllt** (Zeilen 1, 5 und 8).

Die Fix-Runde hat den härtesten Befund der ersten Runde — B-3, das falsche Fall-Urteil im
Abbruch-Pfad — vollständig geschlossen, und der zentrale Nachweis von DoD (1) steht jetzt in der
Form, die der Punkt beschreibt: der Hänger endet von selbst, und er sagt, was er gemessen hat. Was
neben dem Nachweis stand, ist in fünf von sechs Fällen abgeräumt.

**Wo sie nicht trägt, trägt sie an derselben Stelle wie beim letzten Mal.** Der Commit nennt zwei
Befunde gegen sich selbst — *„mein Zahn zu B-3 biss nicht"* und *„meine Tests starteten
Hintergrund-Prozesse, die die Ausgabe-Pipe erben"* —, beide gefunden von `make mutate`, nicht von der
schreibenden Rolle. Diese Runde findet **fünf weitere derselben Familie**: drei Fixes ohne jeden
Zahn (V-1, V-7), ein Zahn, dessen benannter Mechanismus im gepinnten Image nicht existieren kann
(V-3), und ein Sensor, der unter der richtigen Mutation selbst hängt (V-4). Die Klasse ist nicht die
Nachlässigkeit, sondern die **Reihenfolge**: der Fix entsteht, und die Frage *was müsste passieren,
damit er bricht* kommt danach — wenn sie kommt.

Für die Schließung ist der kürzeste Weg schmal und benennbar:

1. **Einen Zahn für die Vorlauf-Schranke** (bats-Fall + `test/mutations/`-Fall). Das schließt V-1 und
   hebt DoD (3) auf ERFÜLLT — der Aufbau steht schon in §2.2 und ist in acht Zeilen nachzubauen.
2. **Den B-6-Guard vor `merge_report` ziehen** statt hinter `report_times`, und einen Zahn dazu. Das
   schließt V-2 und hebt DoD (2) auf ERFÜLLT.
3. **`CO-003`** entweder mit korrigierter Bedingung 1 auflösen oder mit neuem Trigger und Prüfdatum
   bestätigen (§8.2) — Architect-Entscheidung.
4. **Die vier Zahlen der Bemessung** auf `mutate-fix3.log` ziehen (V-6) und die Kinder-Aussage im
   Vorlauf-Kommentar auf das einschränken, was gemessen ist (V-8).

V-3, V-4, V-5, V-7 und B-7 sind damit noch offen; keiner von ihnen färbt heute einen Lauf falsch,
und jeder von ihnen ist eine Zusage, die weiter reicht als ihr Sensor. Sie gehören in denselben
Zug oder in einen benannten Folge-Schnitt — nicht in eine Closure, die sie unerwähnt lässt.

---

## 11. Abschließender Gate-Lauf über dem Baum mit diesem Bericht

`/usr/bin/time -f 'GATES_SECONDS=%e' make gates` → **EXIT=0**, **GATES_SECONDS=57.99**;
`baseline-verify: v3.5.2 OK — 42 Dateien` · `d-check: 419 Datei(en) geprüft, 0 Befund(e)` ·
`comment-claims: 46 Datei(en) geprueft, 0 Befund(e)` · bats **187 ok / 0 not ok** · `span-check` grün.
`git rev-parse HEAD` → **9b9866bf4e781d41e11ec75db5749ae60e9b8a37**, unverändert.

`git status --porcelain` führt danach **zwei** untrackte Dateien: den Bericht des parallelen
Review-Durchgangs und diesen. **Nichts committet, kein Produktionscode geändert** — die
`git diff --stat`-Ausgabe über getrackte Dateien ist leer.
