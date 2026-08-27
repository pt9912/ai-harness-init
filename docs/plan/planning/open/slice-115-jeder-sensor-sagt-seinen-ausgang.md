# Slice slice-115: Jeder Sensor, der ein gepinntes Bild anfordert, nennt seinen Ausgang — und der Wächter misst, welche Ausgabe eingeordnet wird

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (Sensor-Wartung, reaktiv). Die drei Fragen aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1, hier beantwortet: **(1) Bündel?** Nein — ein Gegenstand, ein Skript und sein Wächter; er
ist einzeln lieferbar, und seine Aussage stimmt ohne einen zweiten Slice. **(2) Gemeinsames
Closure-Kriterium?** Nein — jedes denkbare wäre die Abschrift seiner eigenen DoD. **(3) Auslöser
reaktiv oder gewollt?** Reaktiv: ein Ausfall ist gemessen an einem Sensor vorbeigelaufen, der ihn
hätte benennen können. Kein Fähigkeits-Sprung — `make mutate` kann hinterher nichts, was es vorher
nicht konnte; es sagt nur, welcher Art sein Rot ist. Nach
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 2 steht wellenlose Arbeit **nicht** in der Roadmap; ihr Zustand ist das Verzeichnis.

**Ebene: Dogfood, nicht emittiert.** Gegenstand sind
[`harness/tools/mutate.sh`](../../../../harness/tools/mutate.sh),
[`harness/tools/full-smoke-ausgang.sh`](../../../../harness/tools/full-smoke-ausgang.sh) und der
Wächter über deren Zusage. Keines der drei geht in ein Zielrepo
(`grep -rl 'mutate.sh\|full-smoke-ausgang' internal/emit/templates/ | wc -l` → **0**). Was ein
Adopter an einer solchen Unterscheidung bekommt, entscheidet der Slice, der die Tool-Ebene
entscheidet — mit eigener Abwägung, nicht als Nebenwirkung.

**Bezug:**
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (die
Klasse: ein Sensor, der rot meldet, ohne dass am Prüfgegenstand etwas rot ist — und, eine Ebene
weiter, ein Wächter, der grün bleibt, weil er die schwächere Frage stellt),
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (ein Verdikt, das von der
Erreichbarkeit eines fremden Hosts abhängt, ist über derselben Fall-Menge zweierlei),
[`AGENTS.md`](../../../../AGENTS.md) §3.5 (beide Ausgänge behalten denselben Exit-Code; ein eigener
wäre die Senkung, die ein ADR verlangt),
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (rot gesehenes Gegenbeispiel — und die Ausgabe des
Wächters ist Teil des Wächters),
[`AGENTS.md`](../../../../AGENTS.md) §3.7 (der Kopf des Einordners trägt seine **Grenze**; für einen
der zwei Ausgänge fehlt sie),
[`ADR-0003`](../../adr/0003-go-native-binaries.md) (Docker-only ist der Grund, aus dem diese Läufe
fremde Hosts befragen),
[`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions) (die CI
ruft nur `make`-Targets; sie ist der Ort, an dem der gemessene Ausfall auftrat),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben dem Kommando, das genau sie ausgibt),
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
(Verortung).

**Autor:** Planner. **Datum:** 2026-08-27.

---

## 1. Ziel

**Ein rotes `make mutate` sagt in seiner eigenen Ausgabe, ob eine ausgehende Anfrage nach einem
gepinnten Artefakt unbeantwortet blieb oder der geprüfte Baum brach — und der Wächter über dieser
Zusage prüft, *welche* Ausgabe eingeordnet wird, nicht nur *dass* eingeordnet wird.**

Der Lieferwert ist nicht ein zweiter Einordner. Er existiert bereits, er ist gemessen richtig, und
er hat einen Aufrufer: `grep -rl 'full-smoke-ausgang.sh' --include='*.sh' harness/ | grep -v 'full-smoke-ausgang.sh' | wc -l`
→ **1**. Der Lieferwert ist, dass seine **Reichweite** dort endet, wo sie enden soll — an der Menge
der Läufe, die fremde Bilder anfordern —, und nicht dort, wo sie heute endet.

### Der gemessene Anlass: derselbe Ausfall, zwei Sensoren, ein Ausgang

Am 2026-08-26 antwortete die Docker-Registry auf die Auflösung des gepinnten
`docker/dockerfile:1.7` mit `502 Bad Gateway`. Der Ausfall traf `make mutate` mitten in einem Fall,
und die Ausgabe des Laufs nannte ihn einen **Befund über einen Wächter**:

```
mutate: BEFUND  169-feldliste-grenze-bestand-weg   rot, aber 'TestFeldliste_GrenzeUeberDenBestand' faellt nicht — falscher Grund
    |  > resolve image config for docker-image://docker.io/docker/dockerfile:1.7:
    | ERROR: failed to build: failed to solve: failed to resolve source metadata for docker.io/docker/dockerfile:1.7: unexpected status from HEAD request to https://registry-1.docker.io/v2/docker/dockerfile/manifests/1.7: 502 Bad Gateway
```

**Die vorhandenen Muster hätten ihn erkannt** — dieselbe Protokolldatei
(`gh api repos/:owner/:repo/actions/jobs/98219369372/logs`) durch
`grep -cE '(^|[[:space:]])> (\[internal\] load metadata for|resolve image config for )'` → **1**
und durch `grep -cE 'unexpected status from [A-Z]+ request to https?://'` → **1**: Muster 1 **und**
Muster 2 greifen. **Aufgerufen wird der Einordner dort nicht:**
`grep -c 'einordnen\|full-smoke-ausgang' harness/tools/mutate.sh` → **0** (Exit 1).

**Das ist dieselbe Fehlzuschreibung eine Ebene höher.** Der Lauf sagte, ein Wächter habe seine Zähne
verloren; verloren war die Verbindung zur Registry. Wer diesem Befund folgt, sucht in
`internal/emit` nach einem Fehler, den es nicht gibt.

### Die zwei Anschlussstellen liegen fertig da, mit ihrer Ausgabe in einer Variablen

| Pfad | Zeile | was dort schon vorliegt |
|---|---|---|
| Grün-Vorlauf bricht ab | `harness/tools/mutate.sh:453` | `log="$(prepare_prerun_log)"`, und der Abbruch druckt seit `241db77` die letzten Zeilen des roten Modus (`grep -c 'show_tail' harness/tools/mutate.sh` → **4**) |
| ein Fall wird rot, aber aus dem falschen Grund | `harness/tools/mutate.sh:412` | `out="$BACKUP/verify.log"` — dieselbe Datei, aus der die `BEFUND`-Zeile ihre Begründung zieht |

`grep -c 'ABBRUCH —' harness/tools/mutate.sh` → **11** Abbruch-Stellen und
`grep -c '^\s*report_fail ' harness/tools/mutate.sh` → **11** Befund-Stellen; **nicht** jede von
ihnen hat einen Lauf hinter sich, dessen Ausgabe eingeordnet werden könnte — welche es sind, gehört
gemessen, nicht angenommen (Frage A). Beide Zahlen wandern mit dem Skript und sind **kein**
Erwartungswert
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2).

### Der zweite Befund: der Wächter prüft Anwesenheit, nicht Identität

Seit `ae00252` hat die Abdeckungs-Zusage von
[slice-106](../done/slice-106-rotes-ci-traegt-seinen-ausgang.md) einen Wächter. Er zählt die
Abschnitte aus dem Sensor-Text auf und verlangt je Abschnitt eine Einordnung im Fenster bis zum
nächsten. **Was er prüft, ist die Anwesenheit der Zeile** — nicht, welche Ausgabe sie übergibt:
`grep -n 'einordnen \"' test/full-smoke-ausgang.bats` zeigt das Prüfmuster als
`grep -qE '^[[:space:]]*einordnen "'`.

**Gemessen auf einer isolierten Kopie außerhalb des Repos** (Mechanik von
[`harness/tools/mutate.sh`](../../../../harness/tools/mutate.sh): `tar` in ein Verzeichnis außerhalb,
Host-Baum unberührt): eine Einordnung bekommt die Ausgabe eines **anderen** Abschnitts —
`einordnen "make -j gates im Ziel (--lang go)"` mit `$artefakt_out` statt `$gates_out`. Ergebnis:
`make test-bats` **EXIT=0**, `make shell-lint` **EXIT=0**,
`make comment-claims` `46 Datei(en) geprueft, 0 Befund(e)`. Dieselbe Kopie mit der **entfernten**
Zeile fällt dagegen sofort und lesbar (`not ok 71 … ohne Einordnung: [Zeile 217]` und
`not ok 72 … A=33 B=5 C=6 D=23 -> A-B-C=22 gegen D-2=21`).

**Der Wächter deckt beide Drift-Richtungen der Menge und keine Drift innerhalb eines Abschnitts.**
Die stärkere Prüfung ist schon einmal gefahren worden: die
[Verifikation](../../../reviews/2026-08-27-slice-106-verify.md) §3.3 nimmt je Abschnitt den Namen
der Ausgabe-Variablen von der linken Seite der Zuweisung und hält ihn gegen das Argument der
`einordnen`-Zeile — **22 Abschnitte geprüft, 0 ohne Einordnung**. Sie steht dort als Gegenprobe
eines Laufs und an keiner Stufe.

### Der dritte Befund: LEITUNG trägt seine Grenze nicht, BAUM trägt sie

Der Kopf von
[`harness/tools/full-smoke-ausgang.sh`](../../../../harness/tools/full-smoke-ausgang.sh) schreibt
für den BAUM-Ausgang aus, was er **nicht** sagt
(`grep -c 'WAS DER BAUM-AUSGANG NICHT SAGT' harness/tools/full-smoke-ausgang.sh` → **1**), und die
Meldung selbst sagt *„wird zugerechnet"* statt *„ist"*. Für LEITUNG steht dieselbe Grenze nirgends
(dieselbe Datei durch `grep -c 'WAS DER LEITUNG-AUSGANG NICHT SAGT'` → **0**, Exit 1).

**Und die Asymmetrie ist nicht theoretisch.** `test/mutations/189` schreibt einen nicht vergebenen
Tag in das emittierte Fragment; der Fehler liegt vollständig im Baum, und der Sensor sagt LEITUNG —
zu Recht, denn die Anfrage wurde nicht mit 2xx beantwortet. Genau dieser Fall ist zugleich der
**einzige** End-zu-Ende-Beleg, den die Unterscheidung hat. Ein falsch getippter Pin liest sich damit
für den nächsten Leser als Registry-Aussetzer — die Ausrede, die
[slice-106](../done/slice-106-rotes-ci-traegt-seinen-ausgang.md) §6 als Risiko benennt.

### Die Abwägung: drei Wege, einer gewählt

- **(A) Denselben Einordner an den Anschlussstellen von `mutate.sh` rufen — gewählt.** Er ist
  gemessen richtig, hermetisch (kein Docker, kein Netz) und liegt als eigenes Skript vor; ein
  zweiter Einordner wäre die Drift-Konstruktion selbst. Der Preis ist eine Verzweigung in einem
  zweiten Treiber.
- **(B) Den Einordner in `mutate.sh` nachbauen.** Verworfen: zwei getrennt gepflegte Muster-Sätze
  über denselben fremden Text altern verschieden, und der Unterschied fällt niemandem auf, weil
  beide nur im Rot gelesen werden.
- **(C) Den Ausgang über den Exit-Code tragen.** Verworfen aus
  [`AGENTS.md`](../../../../AGENTS.md) §3.5 heraus, mit derselben Begründung wie in
  [slice-106](../done/slice-106-rotes-ci-traegt-seinen-ausgang.md): ein eigener Code lädt
  dazu ein, den Leitungs-Fall durchzuwinken, und das ist eine Schwellen-Senkung.

## 2. Definition of Done

Drei slice-eigene Punkte (Modul 5 §Ziel-Form: ≤ 3). Wo kein Kommando einen Punkt rot färbt, steht
das dabei und wird begründet, statt ein Kommando zu erfinden
([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) gilt auch
für Plan-Texte).

- [ ] **(1) Ein rotes `make mutate` nennt seinen Ausgang in der eigenen Ausgabe, an jeder Stelle,
      an der eine Sensor-Ausgabe vorliegt.** Welche Stellen das sind, ist gemessen und im Skript
      benannt — als **Kriterium** wie in
      [slice-106](../done/slice-106-rotes-ci-traegt-seinen-ausgang.md), nicht als
      Fundstellen-Liste. Der Exit-Code bleibt in beiden Fällen ungleich null.
      **Rot:** `make mutate ACTIONLINT_IMAGE=ghcr.io/pt9912/gibt-es-diesen-namen-nicht:v0` über einer
      isolierten Kopie — der Grün-Vorlauf des Modus `ci-lint` scheitert dann an der Auflösung
      (`grep -c '^# verify: ci-lint' test/mutations/*.sh | grep -vc ':0$'` → **1** Fall verlangt
      diesen Modus, `grep -n 'ACTIONLINT_IMAGE' Makefile` → Zeile **10** ist die überschreibbare
      Pin-Variable). Der Abbruch muss `AUSGANG LEITUNG` samt Beleg tragen und weiterhin mit
      Exit ≠ 0 enden. **Der Abbruch geschieht im Vorlauf, vor dem ersten Fall** — der Rot-Beleg
      kostet damit nicht den vollen Lauf.
- [ ] **(2) Der Abdeckungs-Wächter prüft, welche Ausgabe eingeordnet wird.** Je Abschnitt wird der
      Name der Ausgabe-Variablen von der linken Seite der Zuweisung genommen und gegen das Argument
      der zugehörigen `einordnen`-Zeile gehalten; die Prüfschleife existiert bereits als Gegenprobe
      eines Laufs ([Verifikation](../../../reviews/2026-08-27-slice-106-verify.md) §3.3).
      **Rot:** eine Einordnung übergibt die Ausgabe eines anderen Abschnitts —
      `sed -i '221s|"\$gates_out"|"$artefakt_out"|' harness/tools/full-smoke.sh` auf einer
      isolierten Kopie. Heute bleibt `make test-bats` dabei **EXIT=0** (§1, selbst gemessen); nach
      diesem Punkt muss es fallen, und die Meldung muss den Abschnitt nennen, dessen Ausgabe nicht
      ankommt.
- [ ] **(3) Der LEITUNG-Ausgang trägt seine Grenze dort, wo der BAUM-Ausgang sie trägt.** Gemessen
      ist die **Form** des Fehlschlags, nicht seine Zurechnung: ein von uns gesetzter, nicht
      auflösbarer Pin fällt in diesen Ausgang, und das gehört im Kopf des Einordners und in der
      Meldung ausgesprochen.
      **Kein Kommando färbt diesen Punkt rot, und das ist der Befund, keine Vertagung.** Ob eine
      Grenze zutrifft, ist ein Urteil über Prosa; ein Wächter über der **Anwesenheit** des Satzes
      belegt die Zeichenkette und nicht ihre Wahrheit — dieselbe Absage, die der sechste Posten von
      [slice-101](slice-101-norm-postens-bekommen-einen-termin.md) für seine Klasse ausspricht.
      Diese Hälfte trägt das Review.

Standard-Punkte der Vorlage (nicht slice-eigen): `make gates` grün · `make mutate` ohne Befund ·
Doku-Update, falls ein öffentlicher Vertrag berührt ist · Closure-Notiz mit
Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`harness/tools/mutate.sh`](../../../../harness/tools/mutate.sh) | update | Träger von DoD (1): die Anschlussstellen rufen den Einordner mit der Ausgabe, die dort ohnehin in einer Variablen liegt |
| [`harness/tools/full-smoke-ausgang.sh`](../../../../harness/tools/full-smoke-ausgang.sh) | update | Träger von DoD (3) und Mit-Träger von DoD (1): der Kopf spricht heute von **einem** Aufrufer und von **einem** der zwei Ausgänge; beides wird **gezogen**, nicht danebengestellt |
| `test/full-smoke-ausgang.bats` | update | Träger von DoD (2): die Identitäts-Prüfung tritt an die Stelle der Anwesenheits-Prüfung. Der Ausdruck, der die Abschnitte aufzählt, steht bereits an drei Orten identisch — ein vierter wäre die Drift |
| `test/mutations/` <!-- d-check:ignore (geplante Dateien) --> | neu | die Zähne zu DoD (1) und (2). Nummern im Anschluss an die höchste **vergebene**, nicht an die Anzahl — beide gehen auseinander: `ls -1 test/mutations/*.sh \| sed -n 's#.*/\([0-9]*\)-.*#\1#p' \| sort -n \| tail -1` → **190** bei `ls -1 test/mutations/*.sh \| wc -l` → **183** (2026-08-27). Beim Anlegen neu zu erheben |
| [`harness/README.md`](../../../../harness/README.md) | update | dort steht, was `make mutate` und `make full-smoke` aussagen. Nach DoD (1) sagt `make mutate` etwas Zusätzliches, und der bestehende Satz wird **gezogen**. **Abhängigkeit:** [slice-114](slice-114-jede-aussage-hat-einen-abschnitt.md) fasst dieselbe Datei an ihrer Gliederung an — wer zuerst läuft, hinterlässt dem anderen den Stand, gegen den er misst |
| [`AGENTS.md`](../../../../AGENTS.md) | **unverändert** | §3.5 entscheidet über den Exit-Code, §3.6 über den Rot-Beleg, §3.7 über die Kommentar-Klasse *Grenze* — alle drei gehören dem Architect ([`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1). Berührt wäre höchstens §4, und ob sie es ist, entscheidet die Ausgabe |
| [`.github/workflows/ci.yml`](../../../../.github/workflows/ci.yml) | **unverändert** | die CI ruft ausschließlich `make`-Targets ([`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions)) |
| [`internal/`](../../../../internal) und die emittierte Ebene | **unverändert** | die Unterscheidung wandert nicht mit (Kopfzeile *Ebene*) |
| [`docs/plan/planning/done/`](../done) | **unverändert** | Zeitdokumente ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) §Geltungsbereich) |
| [`docs/plan/planning/in-progress/roadmap.md`](../in-progress/roadmap.md) | **unverändert** | wellenlose Arbeit wird dort nicht geführt ([`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird) Setzung 2/3) |

**Vor dem Code zu entscheiden:**

| # | Frage | Warum sie den Schnitt entscheidet |
|---|---|---|
| A | **Welche der Abbruch- und Befund-Stellen von `mutate.sh` haben überhaupt eine Sensor-Ausgabe hinter sich?** | `grep -c 'ABBRUCH —' harness/tools/mutate.sh` → **11** und `grep -c '^\s*report_fail ' harness/tools/mutate.sh` → **11**; ein Teil davon meldet Kopf-Fehler und Isolations-Brüche, hinter denen kein fremder Host steht. Eine Einordnung dort wäre eine Aussage über eine Leitung, die niemand befragt hat — dieselbe Klasse Fehlzuschreibung, nur in die andere Richtung |
| B | **Trägt die Identitäts-Prüfung auch dort, wo ein Abschnitt seine Ausgabe umbenennt?** | Die Gegenprobe der Verifikation liest den Variablennamen aus der Zuweisung. Ein Abschnitt, der seine Ausgabe vor der Einordnung in eine zweite Variable kopiert, wäre nach ihr rot, ohne dass etwas falsch ist. Ob dieser Fall im Bestand vorkommt, gehört gemessen, bevor die Prüfung schärft |
| C | **Bekommt `make smoke` dieselbe Behandlung?** | Er fordert ebenfalls fremde Bilder an. Die Antwort entscheidet, ob der Einordner ein Helfer für zwei Treiber ist oder für alle — und damit, ob sein Kopf von *Aufrufern* im Plural spricht |

## 4. Trigger

**Beginn (`open` → `next` → `in-progress`): nichts blockiert ihn außer dem WIP-Limit.** Der
Gegenstand liegt vollständig in diesem Repo, er berührt die emittierte Ebene nicht und hängt an
keiner Welle. Die Messungen aus §1 sind gefahren.

**Eine Beobachtung zur Reihenfolge, kein Zuständiger.**
[slice-105](slice-105-mutate-messen-dann-teilen.md) fasst dasselbe Skript an, und
[slice-114](slice-114-jede-aussage-hat-einen-abschnitt.md) dieselbe
[`harness/README.md`](../../../../harness/README.md). Keiner der drei ist Vorbedingung des anderen —
wer zweiter läuft, misst gegen den Stand, den der erste hinterlässt, und das ist eine Tatsache über
den Baum, keine Freigabe.

Die zwei Rückführungen, vorab benannt:

- **`in-progress` → `next` (zu groß):** wenn Frage A ergibt, dass die Einordnung in `mutate.sh`
  nicht an zwei Stellen, sondern an jeder der elf Abbruch-Stellen einzeln zu entscheiden ist. Dann
  sind es zwei Slices — einer für die Reichweite, einer für den Wächter.
- **`in-progress` → `open` (blockiert):** wenn sich zeigt, dass die Einordnung in `mutate.sh` nur
  mit einem eigenen Exit-Code trennscharf wird. Das ist eine Schwellen-Senkung
  ([`AGENTS.md`](../../../../AGENTS.md) §3.5) und verlangt ein ADR; der Slice wartet darauf, statt
  sie im Skript zu verstecken.

## 5. Closure-Trigger

DoD (1)–(3) erfüllt mit gefahrenen Kommandos; der Ausgang `LEITUNG` ist in `make mutate` **einmal
rot gesehen** und hat seinen Beleg getragen; die falsch verdrahtete Einordnung ist **einmal rot
gesehen**; Frage A, B und C sind mit ihrer Begründung beantwortet; die Beschreibung in
[`harness/README.md`](../../../../harness/README.md) ist gezogen; Review konform (Modul 10);
Verifikation bestätigt (Modul 11); `make gates` grün; `make mutate` ohne Befund; `git mv` nach
`done/` als eigener Move-Commit; Closure-Notiz mit Steering-Loop-Eintrag in einer der drei Formen
(geschärfte Regel · neuer Sensor · benannte Spec-Lücke).

**Ausdrücklich nicht Teil des Closure-Triggers: dass die CI danach grün ist.** Was zählt, ist die
Einordnung und die Unterscheidbarkeit, nicht die Farbe des nächsten Laufs.

## 6. Risiken und offene Punkte

- **Eine Einordnung, die zu weit reicht, wird zur Ausrede.** Wird sie an eine Abbruch-Stelle
  gehängt, hinter der kein fremder Host steht, sagt der Lauf *„die Leitung"* über einen Zustand, den
  er nicht gemessen hat. Deshalb Frage A **vor** dem Code.
- **Der Einordner bekommt einen zweiten Aufrufer, und sein Kopf spricht heute von einem.** Wer die
  Zeile nicht mitzieht, hinterlässt eine Beschreibung, die nur noch zur Hälfte gilt — genau die
  Klasse, gegen die [`AGENTS.md`](../../../../AGENTS.md) §3.7 steht.
- **Die Identitäts-Prüfung kann falsch rot werden.** Sie liest zwei Namen aus zwei Zeilen und
  vergleicht sie; jede Form, die dazwischen liegt, ist für sie ein Fehler. Ein falsches Rot an einem
  korrekten Abschnitt kostet mehr als das stille Grün, das sie ersetzt — Frage B hängt daran.
- **Der Rot-Beleg zu DoD (1) hängt an einem fremden Registry-Namen.** Er wird über ein nicht
  vergebenes Bild geführt; wird eines Tages eines unter diesem Namen veröffentlicht, misst das
  Rezept etwas anderes. Der Name gehört so gewählt, dass er das nicht kann.
- **`make gates` deckt den Gegenstand nicht.** Was dort grün wird, ist die **Form**; die Reichweite
  trägt der Rot-Beleg, und die Grenze trägt das Review.

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Jede hier aufgeführte Sub-Area
muss das Inklusionskriterium erfüllen (drei Achsen, Schwelle ≥ 2; siehe
[`/kurs/de/grundlagen/konventionen.md` §Was ist eine Sub-Area?](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/grundlagen/konventionen.md#was-ist-eine-sub-area)).

### Sub-Area: Einordner und seine Aufrufer (`harness/tools/full-smoke-ausgang.sh`, `harness/tools/mutate.sh` und ihre Fall-Ebene)

Eine Sub-Area, kein zweiter Block: ein Helfer, seine Aufrufer, sein Wächter und die Beschreibung,
die beide in [`harness/README.md`](../../../../harness/README.md) tragen — ein Gegenstand, eine
Frage. Die CI-Zeile ist Aufrufer, keine eigene Sub-Area.

- **Modus:** GF. Beide Skripte sind in diesem Repo entstanden und seither gegen den Kurs geführt; es
  gibt keinen vorgefundenen Bestand, gegen den zu inventarisieren wäre.
- **Konventionen-Dichte:** hoch. [`AGENTS.md`](../../../../AGENTS.md) §3.5 entscheidet über den
  Exit-Code, §3.6 über den Rot-Beleg, §3.7 über die Kommentar-Klasse *Grenze*,
  [`ADR-0003`](../../adr/0003-go-native-binaries.md) begründet die Abhängigkeit von fremden Hosts,
  und [`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions)
  bindet den Auslöser.
- **Phase-Reife:** Phase 5 (Betrieb). Beide Treiber laufen pro Push; ihre Fehlermeldungen sind
  ausgeschrieben (`grep -c 'FEHLER —' harness/tools/full-smoke.sh` → **115**,
  `grep -c 'ABBRUCH —' harness/tools/mutate.sh` → **11**; beide mitwandernd). Was fehlt, ist nicht
  Reife, sondern die gleiche Aussage an der zweiten Stelle.
- **Evidenz-/Diskrepanz-Risiko:** niedrig für den Bestand (aus dem Protokoll und den Skripten
  gelesen, §1), **offen für die Reichweite** — welche Abbruch-Stelle eine Sensor-Ausgabe hinter sich
  hat, ist Frage A und gehört gemessen, bevor DoD (1) als erfüllt gilt.
- **Reconciliation-Aufwand:** gering. Berührt sind zwei Skripte, ein Testfall, ein bis zwei
  Mutations-Fälle und ein Absatz in [`harness/README.md`](../../../../harness/README.md).
  Graduation-Trigger entfällt; die Sub-Area ist bereits GF.
