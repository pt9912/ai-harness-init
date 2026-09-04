# Review slice-180 — Runde 3: Nachprüfung der Runde-2-Findings

**Rolle:** Reviewer (Modul 8, frischer Kontext) · **Datum:** 2026-09-04 ·
**Skill:** `.harness/skills/reviewer.md` 1.6.0 · **Baseline:** `v5.18.0`

**Gegenstand:** schmale Nachprüfungs-Runde, kein Voll-Review. Geprüft wird Commit
`7290352` („Rolle Implementer: slice-180 Runde 3") gegen `65b5b3e` — der Arbeitsbaum ist
sauber (`git status --porcelain` leer), Commit-Inhalt und Baum sind deckungsgleich.
`git show --stat 7290352` → 8 Dateien, 628 Einfügungen, 52 Löschungen. Weil die zwei
Reviewer-Commits (`8ae359b`, `9f01ff2`) **nur Reports** tragen, enthält `7290352` die
Implementer-Arbeit der Runden 2 **und** 3 in einem Commit.

**Bezugs-Report:** [`2026-09-04-slice-180-mutations-sensor-verify-runde-2.md`](2026-09-04-slice-180-mutations-sensor-verify-runde-2.md)
(1 HIGH, 3 MEDIUM, 1 LOW, blockiert) — davor
[`2026-09-04-slice-180-mutations-sensor-verify.md`](2026-09-04-slice-180-mutations-sensor-verify.md).

**Eingangs-Kontext (fünf Pflicht-Punkte + Slice-Plan):** unverändert —
[`slice-180`](../plan/planning/done/slice-180-mutations-sensor-beleg-statt-lauf.md),
[`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
[`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten),
[ADR-0035](../plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) (Status
`Proposed`, nicht superseded — Index-Zeile deckungsgleich),
[ADR-0003](../plan/adr/0003-go-native-binaries.md),
[`AGENTS.md`](../../AGENTS.md) §3.1/§3.2/§3.5/§3.6/§3.7/§3.8/§3.9 — plus als *vorherige Findings
am gleichen Modul* die zwei Reports oben.

**Methode:** jede der fünf behaupteten Behebungen ist mit einer **eigenen Sonde** gemessen, keine
aus der Behauptung übernommen. Sonden liegen als Wegwerf-Bäume unter `mktemp -d` außerhalb des
Repos und benutzen nur `bash`, `sed`, `grep`, `find`, `tar`, `comm`, `diff` — keine Host-Toolchain
([`AGENTS.md`](../../AGENTS.md) §3.9). `make gates` ist selbst gefahren.

**Nicht geprüft (Rollen-Grenze):** die DoD-Abhakung, die Vollständigkeit der berichteten Läufe und
die Wanduhr-Zahlen als Verifikations-Gegenstand — das ist Verifier-Arbeit in getrenntem Kontext.

---

## A. Nachprüfung der Runde-2-Findings

| Runde-2 | Status | Womit gemessen |
|---|---|---|
| **N-1** (HIGH) Schlüssel-Vergleich unbewacht | **behoben** | Fall 264 unabhängig rot-dann-grün gefahren; `exit 0`-Pfade neu abgezählt |
| **N-2** (MEDIUM) Runden-Kennung + überholte Zeilennummer | **behoben** | Volltext-Sonde über bats-Datei und die drei neuen Fälle |
| **N-3** (MEDIUM) Register-Selbstwiderspruch | **behoben** | `observations.md` gegen den Stand **vor** slice-180 gehalten |
| **N-4** (MEDIUM) Ein-Slot-Grenze fehlt in zwei Zusagen | **behoben** | beide Stellen gelesen |
| **N-5** (LOW) Zahl ohne Kommando, überholt | **behoben im Plan**, **eine dritte Stelle blieb stehen** | beide Kommandos gefahren; siehe R3-1 |

### N-1 — behoben, mit eigener Sonde bestätigt

**Der Fall trifft genau den Vergleich.** Der `sed`-Anker von
`test/mutations/264-mutate-uebersprung-ohne-schluesselvergleich.sh` in einer Wegwerf-Kopie
angewandt, `diff` gegen das Original:

```
1475c1475
<   elif [ -z "${MUTATE_FORCE:-}" ] && [ -f "$BELIEF" ] && [ "$(cat "$BELIEF" 2>/dev/null)" = "$belief_key" ]; then
---
>   elif [ -z "${MUTATE_FORCE:-}" ] && [ -f "$BELIEF" ]; then
```

Genau eine Zeile, genau der dritte Teil der Bedingung — Teil 1 (`MUTATE_FORCE`) und Teil 2
(`-f "$BELIEF"`) bleiben stehen.

**Der Wächter färbt sich rot.** Rumpf des neuen bats-Tests (`test/mutate-driver.bats:1061`) als
Skript nachgefahren, gegen beide Fassungen:

| Fassung | Ergebnis |
|---|---|
| unmutiert | `GRUEN` — Exit 1, `unbekannter '# verify:'`, kein Übersprung |
| mit Fall 264 | **ROT** an allen drei Zusicherungen: `status=0 statt 1` · `Uebersprung gemeldet` · `erwartete Meldung fehlt` |

Die Übersprung-Meldung des mutierten Laufs nennt dabei einen echten Schlüssel
(`baf44c4f1c…`) über einer Beleg-Datei mit Inhalt `VOELLIG-FALSCHER-SCHLUESSEL` — das stille
Grün aus Runde 2, jetzt von einem Fall gehalten.

**Der Zweig ist der einzige seiner Art, und das ist abgezählt statt behauptet:**
`grep -n "exit 0" harness/tools/mutate.sh` → **eine** Zeile (`:1478`), der Übersprung selbst; der
zweite Weg zu Exit 0 ist `[ "$fail_count" -eq 0 ]` am Ende von `main()` (`:1658`), also **nach**
der Messung. Alle drei Teile seiner Bedingung tragen jetzt einen Wächter: Teil 1 über den
`main()`-Test `:1030` (der erste Aufruf läuft unter `MUTATE_FORCE=1` bei vorliegendem, passendem
Beleg — fiele die Bedingung weg, spränge er über und der Test fiele an `status -eq 1`), Teil 3
über `:1061` und Fall 264. Teil 2 (`-f "$BELIEF"`) ist ohne Wächter, aber auch ohne Fehlermodus:
fehlt die Datei, liefert `cat` den leeren String, der Vergleich schlägt fehl, es wird nicht
übersprungen — sein Wegfall ist konservativ.

**Kopplung Fall ↔ Wächter ist intakt:** `# expect:` von 264 ist wortgleich der `@test`-Name
(mechanisch geprüft für 262/263/264, alle drei treffen); `# verify:` fehlt, `narrow_sensor`
liefert damit `test-bats`, Fehlschlag-Form `not ok [0-9]+` — die Form, in der bats den Namen
ausgibt.

### N-2 — behoben

Volltext-Sonde über die in diesem Diff **neu geschriebenen** Kommentare und Namen: keine
Runden-Kennung, keine Zeilennummer mehr.

- `grep -n "1633\|Zeile ~" test/mutate-driver.bats` → **keine Treffer**; der Kommentar bei `:988`
  sagt jetzt *„dass `main()` an ihrem einzigen Aufrufort, als dessen letzte Anweisung,
  tatsaechlich genauso aufruft … prueft dieser Test-Block nicht"* — Stelle statt Zeilenzahl, und
  ohne `(Review-Fund MEDIUM-1)`.
- Der Testname bei `:1030` und die `# expect:`-Zeile von Fall 263 tragen kein `HIGH-1` mehr; beide
  sind wortgleich und damit über `make mutate` weiter aneinander gebunden.
- Was an Runden-Kennungen **bleibt**, liegt außerhalb dieses Diffs und außerhalb des Cutoffs:
  `test/mutate-driver.bats:6` (*„Review-Befund N-2"*) und `:161`/`:166` (*„Runde 2 F-1, Runde 3
  F-1"*). Der Diff ist an dieser Datei rein additiv (`@@ -923,3 +923,154 @@`) —
  [`AGENTS.md`](../../AGENTS.md) §3.7 bindet den Kommentar, *der geschrieben oder geändert wird*;
  der Bestand ist kein Arbeitsauftrag.

### N-3 — behoben; der Selbstwiderspruch ist weg, das Register ist unberührt

**Ist-Zustand gegen den Original-Stand vor slice-180 gehalten, nicht nur gegen diesen Commit:**

- `git diff 65b5b3e -- docs/plan/planning/observations.md` → leer (Exit 0);
  `git diff 15a01bd -- …` ebenso (0 Zeilen).
- `git status --porcelain docs/plan/planning/observations.md` → leer.
- Letzter Commit an der Datei ist `6b3f61d` („Rolle Planner: slice-175 Closure") — kein
  slice-180-Commit.
- `BEO-031`…`BEO-034` stehen **nicht** im Register; die höchste vergebene Kennung ist `BEO-030`.

Die Rücknahme ist damit vollständig, nicht nur diff-lokal.

**Der Widerspruch ist aufgelöst, und zwar in beide Richtungen.** §7 sagt jetzt ausdrücklich
*„**nicht fortgeschrieben in diesem Lauf**"* (`:562`), das DoD-Häkchen `:162` steht auf `[ ]` mit
dem Zusatz *„Vorbereitet, nicht eingetragen"*, der neue Unterabschnitt *Kandidaten für das
Beobachtungs-Register* (`:603-610`) nennt Kennung, Zähler und Beleg ausdrücklich als **Vorschläge**
und die Vergabe als Planner-Arbeit, und §8 (`:758-760`) sagt dasselbe wie zuvor. Ich finde im Plan
keine Aussage mehr, die eine nicht stattgefundene Handlung behauptet — die Risiko-Ausgänge
(`:569-573`) sprechen konsequent von *Kandidat* `BEO-031`/`032`/`033`, und die Register-Paarung ist
als *nicht anwendbar* begründet (`:598-601`).

### N-4 — behoben, beide Stellen

- `harness/tools/mutate.sh:70-74`: *„EIN Beleg-Slot, nicht einer je Schluessel: ein Lauf ueber
  einem ANDEREN Pruefgegenstand entwertet ihn (siehe clear_belief), auch wenn der vorige
  Schluessel nie widerlegt wurde — kehrt der Baum danach zu diesem frueheren, tatsaechlich
  gruenen Stand zurueck, faehrt der naechste Lauf trotzdem wieder voll."*
- `harness/README.md:73`: *„**Der Beleg-Slot ist einer, nicht einer je Schlüssel:** ein Lauf über
  einem anderen Prüfgegenstand entwertet ihn, auch wenn der vorige Schlüssel nie widerlegt wurde
  — kehrt der Baum zu einem früher grünen Stand zurück, fährt der nächste Lauf trotzdem wieder
  voll."*

Beide Sätze stehen **im selben Absatz** wie die hinreichend klingende Formulierung, die Runde 2
beanstandete, und schränken sie ein. Das deckt sich mit dem Code: `clear_belief` (`:1494`) räumt
den einen Slot bei jedem nicht übersprungenen Lauf, unabhängig vom Schlüssel.

### N-5 — im Plan behoben, an einer dritten Stelle nicht

**Nachgerechnet, beide Kommandos selbst gefahren:**

```sh
sed -n 's/^# files: //p' test/mutations/*.sh | tr ' ' '\n' | sed '/^$/d' | LC_ALL=C sort -u | wc -l   # 57
bash -c "source harness/tools/mutate.sh 2>/dev/null||true; isolation_key_files | wc -l"               # 1058
```

Die zwei Plan-Stellen sind korrekt: `:534` sagt *„**57** von **1058** Pfaden gedeckt — dieselben
zwei Kommandos wie in §8, `BEO-025`; keine Erwartungswerte"*, und §8 `:720-725` führt **beide
Kommandos verbatim** samt Nicht-Erwartungswert-Marke und
[`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)-Verweis.
Die Zahlen stimmen auf den gemessenen Wert. Die dritte Stelle blieb stehen — siehe **R3-1**.

---

## B. Neue Findings dieser Runde

### R3-1 — Dieselbe Messzahl steht im Treiber weiter ohne Kommando und ist dort um drei daneben

- **kategorie:** LOW
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.7 (*Ein Kommentar beschreibt, was da ist*) ·
  [`AGENTS.md`](../../AGENTS.md) §3.6 (*die Zusage auf das einschränken, was der Code hält*) ·
  dem Sinn nach [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2, dessen Geltungsbereich Shell-Skripte allerdings **nicht** umfasst
- **pfad:** `harness/tools/mutate.sh:1466`
- **befund:** Der in diesem Diff **neu geschriebene** Kommentar am `isolation_key`-Aufrufpunkt
  sagt *„nicht die volle Schluessel-Bezugsmenge aus `isolation_key_files` — 57 gegen 1055 Pfade,
  gemessen"*. Der gemessene Wert über dem ausgelieferten Baum ist **1058** (Kommando oben) — die
  Differenz sind exakt die drei Fall-Dateien `262`/`263`/`264`, die derselbe Commit anlegt; die
  Zahl war also schon beim Schreiben falsch. Sie wandert außerdem mit **jeder** neuen Datei im
  Baum, auch mit jedem Review-Report: `isolation_key_files` ist ein `tar` über den ganzen Baum
  minus `.harness/state` minus `.git`. Der Kopf **derselben Datei** (`:76-79`) formuliert die
  Gegenregel — *„Was der Lauf HEUTE kostet, sagt er selbst am Ende (`report_times`), statt es
  hier als Zahl zu behaupten, die mit dem Bestand wandert."* Der Plan behandelt diese Stelle als
  erledigt: `:554` spricht von *„die beiden `57 von 1055`-Stellen"*, es waren drei.
- **verifizierbar:** ja — das Kommando oben gegen die Zahl im Kommentar. Kein Gate deckt es:
  `make comment-claims` prüft die **Existenz** eines genannten Sensors, nicht den **Wert** einer
  Zahl (Kopf des Skripts, §*Was er weiterhin NICHT kann*), und kein Modul aus `modules:` der
  `.d-check.yml` liest ein Shell-Skript.
- **klasse:** *Mitwandernde Messzahl in einem Kommentar, ohne ihr Kommando und schon beim
  Schreiben überholt.* (Dieselbe Klasse wie Runde-2-N-5 — die Korrektur folgte dem genannten
  Fundort statt der Fundmenge.)

### R3-2 — Die Closure-Notiz erklärt die tragende Probe (c) für erbracht durch ein Ereignis auf der anderen Achse

- **kategorie:** MEDIUM
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 (*„Falsch: ‚Byte-Gleichheit belegt `make smoke`',
  ohne `smoke` gelesen zu haben. Richtig: benennen, was wirklich deckt — oder dass nichts
  deckt."*) · Slice-Plan §5 Closure-Trigger 2 (c) ·
  [ADR-0035](../plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
  Festlegung 2 (*gezeigt, nicht angenommen*)
- **pfad:** `docs/plan/planning/in-progress/slice-180-…md:584-593` (§7) gegen `:302-319` (§5)
- **befund:** §5 definiert Probe (c) als *„eine Änderung an einem Pfad, den die **Kopie trägt** und
  `git ls-files --cached --others --exclude-standard` **nicht** führt → der Lauf fährt wieder
  voll"* und nennt sie zweimal ausdrücklich die tragende (*„Probe (c) ist genau der Punkt, an dem
  ein Schlüssel aus `working-tree-hash.sh` fälschlich überspränge"*, *„Probe (c) ist keine
  Zugabe"*). §7 führt als Beleg zwei unabsichtliche Zwischen-Edits an, benennt deren Gegenstand
  selbst als *„getrackte Dateien dieses Diffs"* (die Plan-Datei, `../observations.md`,
  `test/mutations/74-…`) und schreibt dann: *„derselbe Beleg, den Closure-Trigger 2 (a)/(c)
  verlangt (eine Änderung an einer im Schlüssel geführten Datei bewegt ihn)"*. Der Klammersatz
  ist die Definition von **(a)**, nicht von (c): eine getrackte Datei bewegt **beide** Schlüssel —
  den gewählten *und* den abgelehnten aus `working-tree-hash.sh` —, also genau die Fläche, auf der
  §5 die zwei nicht auseinanderlaufen sieht. Ein (c)-Lauf ist im Plan nirgends verzeichnet
  (`grep -n "Probe (c)\|(a)/(c)" …` → `:305`, `:318`, `:591`; die ersten zwei sind die
  Definition). Der Pfad dafür existiert und ist genau einer:
  `comm -23 <(isolation_key_files | sort -u) <(git ls-files --cached --others --exclude-standard | sort -u)`
  → `.claude/settings.local.json`, Gegenrichtung 0 (selbst gemessen, keine Erwartungswerte).
- **verifizierbar:** ja — die zwei Textstellen nebeneinander und das `comm` oben. Kein Sensor
  liest eine Closure-Notiz.
- **klasse:** *Ein Beleg wird einer Prüfung zugeschrieben, deren definierende Achse er nicht
  berührt.*

---

## Negativbefunde (geprüft, ohne Befund)

- **`make gates` selbst gefahren, EXIT 0.** Darin `baseline-verify: v5.18.0 OK — 53 Dateien`,
  `d-check: 598 Datei(en) geprüft, 0 Befund(e)` (deckt die berichtete Zahl),
  `comment-claims: 55 Datei(en) geprueft, 0 Befund(e)`, bats bis `ok 218` mit
  `grep -c '^not ok'` → **0**, `span-check` grün. Die Datei-Zahlen wandern mit dem Bestand und
  sind keine Erwartungswerte
  ([`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2).
- **Die sieben Wächter dieses Slice sind im gepinnten Bild grün gelaufen**, nicht nur auf dem
  Host: `ok 127 driver: die Kopie traegt den Sensor-Bedarf inklusive .git` ·
  `ok 169`…`ok 174` (die sechs neuen `driver:`-Tests, darunter `main() ueberspringt NUR bei einem
  Beleg, der dem aktuellen Schluessel entspricht`). Das schließt die Risiko-8-Klasse aus Runde 1
  (GNU-only Optionen, die im Alpine/BusyBox-Bild lautlos scheitern) für die neuen Zusicherungen
  aus.
- **`make mutate`-Beleg passt zum ausgelieferten Baum — deshalb kein Neu-Lauf.**
  `.harness/state/mutate-passed.key` trägt `c58120c7d94fb8d1…`, und
  `bash -c "source harness/tools/mutate.sh …; isolation_key"` liefert **denselben** Wert. Was der
  Beleg trägt, ist scharf umrissen und mehr als es scheint: `finalize_belief` schreibt nur bei
  `fail_count -eq 0`, und die Vollständigkeits-Prüfung von `merge_report` erhöht `fail_count` über
  `report_fail` (`:1311`, `:1315`, `:1335`, `:1342`, `:1348`). Ein Beleg impliziert also einen
  Lauf **über allen** Fall-Dateien dieses Baums, und `test/mutations/` liegt selbst im Schlüssel —
  die berichteten `250 ok` sind damit gedeckt (`ls test/mutations/*.sh | wc -l` → **250**). Was er
  **nicht** trägt: eine Fall-Zahl im Wortlaut und den benannten Rest (Docker-Cache, Host-Werkzeuge).
- **Der Beleg überlebt einen `make gates`-Lauf** — nach meinem eigenen Lauf ist er unverändert
  gültig. Das ist die Zusage aus DoD (1), dass `.harness/state/` außerhalb der Bezugsmenge liegt,
  gemessen statt behauptet. **Er überlebt diesen Report nicht:** `docs/reviews/` liegt im
  Schlüssel; mit dem Schreiben dieser Datei fällt der Übersprung weg. Das ist erwartetes
  Verhalten (§7 hat es zweimal unabsichtlich ausgelöst), aber der Verifier sollte es wissen,
  bevor er den nächsten Lauf startet.
- **Die drei geänderten/neuen Fälle treffen jeder genau eine Zeile, und jeder färbt seinen
  Wächter rot** — unabhängig gefahren gegen den *jetzigen* Code, nicht gegen den von Runde 2:
  - **74** — Anker trifft `ISOLATION_EXCLUDES=(./.harness/state)` (`:278`), sonst nichts; Testrumpf
    mit korrekt gesetztem `REPO` unmutiert `GRUEN`, mutiert `ROT: fehlt in Kopie: .git` — und nur
    `.git`, also präzise die Zusage des Tests.
  - **262** — Anker trifft die `tar`-Zeile in `isolation_key_files` (`:331`); Testrumpf gegen ein
    Mini-Repo unmutiert `GRUEN`, mutiert `ROT: unerklaerter Pfad: harness/tools/mutate.sh`.
  - **263** — Anker trifft `clear_belief` in `main()` (`:1494`), nicht die Definition (`:155`) und
    nicht den Aufruf in `finalize_belief` (`:168`); Testrumpf unmutiert `GRUEN`, mutiert `ROT` an
    allen vier Zusicherungen (`Beleg ueberlebt`, `Lauf2 status=0`, `Uebersprung in Lauf2`,
    `Meldung fehlt`).
- **Die zweite Instanz der N-1-Klasse gesucht und geprüft:** `isolation_key` (`:339-344`) trägt
  eine fail-closed-Zusage (*„eine leere Liste liefert KEINEN Hash — zwei leere Hashes waeren
  gleich"*), für die weder ein bats-Test noch ein Mutations-Fall existiert
  (`grep -rln 'isolation_key' test/mutations/` → nur 262/263/264, keiner trifft `[ -n "$files" ]`).
  **Kein Finding:** die Eigenschaft ist doppelt getragen — `isolation_key_files` endet auf
  `grep -v '/$'`, das unter `pipefail` bei leerer Ausgabe selbst `1` liefert, und `mutate.sh` liegt
  im eigenen Prüfbereich, die Liste kann im Betrieb also nie leer sein. Der Vergleichsfall
  `test/mutations/73-mutate-fingerprint-leer.sh` bewacht die analoge Stelle bei
  `target_fingerprint`; dort ist die Liste steuerbar, hier nicht.
- **`AGENTS.md` §3.2/§3.5/§3.8:** kein Verstoß. Keine neue Inline-Suppression
  (`git show 7290352 | grep -E '^\+.*(nolint|shellcheck disable)'` → leer), keine
  Gate-Lockerung, und **kein Architect-Artefakt im Commit** —
  `git show --pretty=format: --name-only 7290352 | grep -E '^(AGENTS|harness/conventions)\.md$|^docs/plan/adr/'`
  ist leer; die acht Dateien sind Plan, `harness/README.md`, `harness/tools/mutate.sh`,
  `test/mutate-driver.bats` und vier Fall-Dateien.
- **`AGENTS.md` §3.9:** die neuen Tests und Fälle fahren `bash`, `mktemp`, `printf`, `cp`, `find`,
  `comm`, `tar`, `sed`, `grep` — keine Host-Toolchain in Befehlsposition. (Der PreToolUse-Guard
  hat während dieser Sitzung ein *Prüf*-Kommando von mir fail-closed geblockt, weil es die Namen
  der Toolchains als `grep`-Muster trug; die Prüfung ist ohne diese Literale wiederholt.)
- **`AGENTS.md` §3.7, neue Kommentare:** die drei neu geschriebenen Blöcke
  (`mutate.sh:52-74`, `:1459-1470`, `:1481-1493`) tragen Zusage, Kopplung, Abgrenzung und Grenze
  im Indikativ; die einzige Herkunftsnennung ist `BEO-025` → `docs/plan/planning/observations.md`,
  ein **lebendes** Register, das §3.7 selbst als solches führt. Kein Verweis auf ein Zeitdokument,
  keine verworfene Alternative im Konjunktiv, kein abwesender Text. Die Formulierung *„Ohne dieses
  Loeschen HIER ueberlebt …"* (`:1483`) ist Indikativ über die Kopplung der Stelle und folgt der
  Hausform, die dieselbe Datei bei `require_isolated` (`:368-372`) außerhalb des Cutoffs führt.
- **`ADR-0035` Fitness Function:** alle drei Zeilen haben einen Träger, und alle drei liefen grün
  (bats `ok 169`, `ok 171`/`ok 172`; Fall 262 unter `make mutate`). Der Slice liefert mit 263/264
  **zwei Träger mehr**, als die ADR verlangt — eine Verschärfung, für die §3.5 kein ADR fordert.
  §*Was kein Wächter hält* zählt drei Lücken auf; die aus Runde-2-N-1 ist keine davon, sie ist
  jetzt geschlossen statt aufgelistet.
- **Reihenfolge im Treiber unverändert korrekt:** Lock (`mkdir "$LOCK"`, `:1428`) → `HAVE_LOCK=1`
  (`:1434`) → Worker-/Zeit-Schranken (`:1440`, `:1450`) → Fall-Verzeichnis (`:1457`) →
  Beleg-Block (`:1471-1479`) → `clear_belief` (`:1494`). Der Übersprung sitzt hinter dem Mutex,
  und `finalize_belief` (`:1657`) steht unmittelbar vor dem Status-Ausdruck (`:1658`), wo
  `fail_count` endgültig ist.
- **Datei-Modus von Fall 264** ist `100644` (nicht ausführbar) wie bei 262; die Fälle laufen über
  `bash "$case_file"` (`:627`), der Modus trägt nichts.
- **Was ich als Bestand stehen lasse:** DoD (3) (`:152-153`) sagt *„führt heute fünf
  fail-closed-Bedingungen"*, während der Kopf jetzt sechs führt — der Satz ist Planner-Text von
  vor der Umsetzung und in diesem Diff **nicht** angefasst
  (`git show 65b5b3e:…slice-180-….md` trägt ihn wortgleich); der Cutoff bindet die Zahl, die
  geschrieben oder geändert wird.

---

## Kategorie-Summary

| Kategorie | Anzahl | Klassen |
|---|---|---|
| HIGH | 0 | — |
| MEDIUM | 1 | Beleg einer Prüfung zugeschrieben, deren Achse er nicht berührt (R3-2) |
| LOW | 1 | Mitwandernde Messzahl ohne Kommando, an einer dritten Stelle stehengeblieben (R3-1) |
| INFO | 0 | — |

**Erledigt aus Runde 2:** 1 HIGH, 3 MEDIUM, 1 LOW (letzteres an zwei von drei Stellen — der Rest
ist R3-1). **Offen aus Runde 1:** INFO-1 (Metadaten-Grenze), unverändert nicht adressiert.

**Wiederkehrende Klassen für den Steering-Loop-Zähler:** R3-1 ist die
`BEO-009`-Klasse (*ein Fix ändert die Ableitung, die Zusage daneben bleibt stehen* — hier: die
Korrektur folgte dem genannten Fundort statt der Fundmenge). R3-2 liegt der `BEO-025`-Klasse nahe
(*eine Zusage nennt einen Geltungsbereich, den der Beleg darunter nicht hält*), diesmal an einer
Closure-Notiz statt an einem Skript-Kopf. Nach der Vorgangs-Regel (*„Ein Vorgang zählt einmal"*)
sind beide **kein** zusätzlicher Zählerschritt gegenüber den Runden 1 und 2: `slice-180` ist
derselbe Vorgang. Ob sie einen Beleg begründen, entscheidet der Closure-Schritt, nicht dieser
Report.

## Verdikt

**Freigegeben für Verifikation — mit einer Auflage, die vor der Closure fällt.**

Alle fünf Runde-2-Findings sind behoben und mit eigenen Sonden bestätigt. Der blockierende
HIGH ist substanziell geschlossen, nicht nur behauptet: der Fall trifft genau den
Gleichheits-Vergleich, entfernt nichts sonst, und der neue `main()`-Test wird unter der Mutation
an allen drei Zusicherungen rot — gemessen, nicht abgeleitet. Der einzige Zweig, der Exit 0 ohne
Messung liefert, ist abgezählt (`grep -c "exit 0"` → 1) und in allen wirksamen Teilen seiner
Bedingung bewacht. Der Register-Selbstwiderspruch ist beidseitig aufgelöst, und
`observations.md` ist gegen den Stand **vor** slice-180 byte-gleich.

**Ich blockiere nicht auf R3-2**, obwohl ein MEDIUM das typischerweise tut — und begründe die
Abweichung ([`.harness/skills/reviewer.md`](../../.harness/skills/reviewer.md) §Ablage lässt sie
ausdrücklich zu): Der Befund betrifft **keinen Code**, sondern einen Satz in der Closure-Notiz,
und die *Sache*, die Probe (c) zeigen soll, ist an anderer Stelle desselben Plans bereits
gemessen — §3 `:192-204` führt genau die `comm`-Differenz, die belegt, dass die gewählte
Bezugsmenge die abgelehnte echt enthält, und der bats-Test *„isolation_key bewegt sich mit dem
Inhalt, den er hasht"* (`ok 170`) trägt die Verhaltens-Hälfte. Was fehlt, ist der **Lauf** und
die richtige Zuordnung des Belegs — beides ist Gegenstand des Closure-Trigger-Abgleichs, den
Verifier und Planner ohnehin führen, und beides ist dort mit weniger Aufwand zu erledigen als in
einer weiteren Implementer-Runde. **Die Auflage:** Closure-Trigger 2 (c) wird entweder real
gefahren (der Pfad ist eindeutig bestimmt und liegt **nicht** in meiner Hand — er ist eine
Konfigurationsdatei) oder der Satz in §7 `:591` sagt, was der Beleg wirklich deckt, nämlich (a)
und (b). Ein Übergang nach `done/` mit dem heutigen Wortlaut wäre die Klasse, gegen die dieser
Slice selbst gebaut ist.

**R3-1 ist ein Einzeiler** und braucht keine Runde; er gehört in denselben Zug wie die Auflage
oben.

**Was ich nicht geprüft habe:** die DoD-Abhakung, die Vollständigkeit und die Wanduhr-Zahlen der
berichteten `make mutate`-Läufe und die Closure-Notiz als Verifikations-Gegenstand.
`make mutate` habe ich **nicht** neu gefahren — der hinterlegte Beleg passt zum ausgelieferten
Baum, und genau das ist die Zusage dieses Slice; stattdessen sind die vier neuen bzw. geänderten
Fälle einzeln als Stichprobe rot-dann-grün gemessen.
