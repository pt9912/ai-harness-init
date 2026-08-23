# Slice slice-093: Der Mutations-Treiber erreicht den Voll-E2E-Sensor — ein Wächter, der allein in `make full-smoke` lebt, bekommt seinen Fall

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (Harness-Wartung, reaktiv). Die drei Fragen aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1, hier beantwortet: **(1) Bündel?** Nein — der Slice ist einzeln lieferbar und wartet auf
keinen zweiten; der Gegenstand ist eine Funktion in einer Datei plus ihr Beleg. **(2) Gemeinsames
Closure-Kriterium?** Nein — jedes denkbare wäre die Abschrift seiner eigenen DoD. **(3) Auslöser
reaktiv oder gewollt?** Reaktiv: eine Zusage ließ sich nicht listen, und drei Artefakte mussten um
die Lücke herumschreiben (§1). Kein Fähigkeits-Sprung des Werkzeugs — die emittierte Ebene bleibt
unberührt. Die zwei bisherigen Erweiterungen desselben Treibers liefen ebenso wellenlos
(`grep -h '^\*\*Welle:' docs/plan/planning/done/slice-02{6,7}-*.md`). Nach
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 2 steht wellenlose Arbeit **nicht** in der Roadmap; ihr Zustand ist das Verzeichnis.

**Bezug:**
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (dieselbe
Klasse eine Ebene tiefer: nicht ein Gate ohne Lauf, sondern ein Sensor, dessen Wächter kein
Gegenbeispiel kennen kann),
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (*ungelistet heißt unbewacht* — die Regel, die den
Gegenstand überhaupt zu einem macht),
[`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) (die Grenze über
ihrer Fitness-Tabelle nennt die Lücke und macht sie zur Schuld des Einlösenden — **gelesen als
Constraint, nicht angefasst**, sie ist *Accepted*),
[`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
(Gate-**Anheben** braucht kein ADR, sondern einen Steering-Loop-Eintrag — die Einordnung dieses
Slice),
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
(Verortung),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben dem Kommando, das genau sie ausgibt).

**Autor:** Planner. **Datum:** 2026-08-23.

---

## 1. Ziel

**Ein Wächter, der allein in `make full-smoke` lebt, kann einen Fall in `test/mutations/`
bekommen — der Treiber führt `full-smoke` als Modus, und ein Fall belegt im Standard-Lauf, dass
dieser Modus wirklich rot färbt.**

### Bestandsaufnahme — gemessen am 2026-08-23, Kommando neben der Aussage

Keine dieser Zahlen ist ein Erwartungswert: sie wandern mit den Dateien, über die sie sprechen
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). Sie beschreiben die Ausgangslage, gegen die geschnitten wird.

| Aussage | Wert | Kommando |
|---|---|---|
| Der Treiber kennt `full-smoke` nicht | **0** | `grep -c 'full-smoke' harness/tools/mutate.sh` |
| Zulassungs-Arme in `failure_form`, inklusive Ablehnungs-Arm `*)` | **6** | `sed -n '/^failure_form()/,/^}/p' harness/tools/mutate.sh \| grep -cE '^[[:space:]]+[a-z*-]+\)'` |
| Fälle in `test/mutations/` | **144** | `ls test/mutations/*.sh \| wc -l` |
| davon mit `# verify: full-smoke` | **0** | `grep -l '^# verify: full-smoke' test/mutations/*.sh \| wc -l` |
| Fehlschlag-Stellen in `harness/tools/full-smoke.sh` | **73**, dazu ebenso viele `exit 1` | `grep -c 'full-smoke: FEHLER' harness/tools/full-smoke.sh`; `grep -c '^[[:space:]]*exit 1' harness/tools/full-smoke.sh` |
| dieselbe Konstruktion im Vorbild `harness/tools/smoke.sh`, dessen Muster der Treiber bereits führt | **16** | `grep -c 'smoke: FEHLER' harness/tools/smoke.sh` |

Ein Fall mit einem unbekannten Modus läuft nicht etwa still durch: `failure_form` ist die
**einzige** Zulassungs-Quelle, ihr Ablehnungs-Arm liefert Exit 1, und `run_case` meldet dann
*„unbekanntes `# verify:` — kein Fehlschlag-Muster definiert"*. Damit ist die Lücke keine
Nachlässigkeit im Fall, sondern eine Schranke im Treiber.

### Warum die Lücke besteht — Absicht oder Versehen?

**Keines von beiden.** Die Zulassungs-Liste ist **bedarfsgetrieben** gewachsen, und einen ersten
Fall für `full-smoke` gab es nie.

- **Kein Arm ohne Fall, kein Fall ohne Arm — zweimal so entstanden.** Der `smoke`-Arm und
  `test/mutations/08-smoke-out-of-scope.sh` stehen in **einem** Commit
  (`git show --stat 5d13404`), der `ci-lint`-Arm und `test/mutations/10-ci-workflow-syntax.sh`
  ebenso (`git show --stat 0cea417`). Die Liste ist nie auf Vorrat gewachsen. `full-smoke`
  existierte zu beiden Zeitpunkten bereits — es fehlte die Nachfrage, nicht die Gelegenheit.
- **Eine Auslassungs-Begründung existiert nicht.** Der Kopf von `harness/tools/mutate.sh`
  begründet Kosten dort, wo sie eine Entscheidung tragen: warum der Sensor **nicht** in
  `make gates` steht, und warum je Fall nur die schmalste ausreichende Stufe läuft
  (`grep -c 'LAUFZEIT' harness/tools/mutate.sh` → **1**;
  `grep -c 'Ein schnellerer Lauf, der weniger prueft' harness/tools/mutate.sh` → **1**). Zu
  `full-smoke` steht dort nichts. Eine Grenze, die niemand ausspricht, ist keine
  ([`AGENTS.md`](../../../../AGENTS.md) §3.7).
- **Und die Kosten, die eine Absicht hätten tragen können, sind zu klein dafür.** Ein
  unmutierter `make full-smoke` bei warmem Docker-Cache: **91.36 s**, Exit 0
  (`/usr/bin/time -f 'FULLSMOKE_SECONDS=%e' make full-smoke`, gefahren am 2026-08-23). Der
  Vergleichs-Lauf: `make mutate` über die 144 Fälle in **913.21 s** (`144 ok, 0 Befund(e)`,
  Exit 0) — `/usr/bin/time -f 'MUTATE_SECONDS=%e' make mutate`, derselbe Tag, derselbe warme
  Cache. Ein `full-smoke`-Lauf ist damit **kein** Größenordnungs-Sprung gegenüber dem Sensor, den
  er erweitert, sondern rund ein Zehntel von dessen heutiger Gesamtlaufzeit.
  Beide Zahlen gelten für **diese** Maschine und diesen Cache-Zustand; sie sind eine
  Größenordnung, kein Vertrag.

**Die Lücke wird darum geschlossen; offen ist nur, auf welchem Weg.**

### Die Abwägung: vier Wege, einer gewählt

- **(A) Den Modus zulassen, sonst nichts — gewählt.** Der Preis ist proportional und wird nur von
  Fällen gezahlt, deren Wächter dort lebt: der Grün-Vorlauf fährt jeden Modus, den irgendein Fall
  benutzt, **einmal**, dann jeder Fall seinen eigenen Lauf. Der erste `full-smoke`-Fall kostet also
  zwei Läufe, jeder weitere einen — abzulesen an `for m in test $modes` im Grün-Vorlauf und am
  Sensor-Aufruf in `run_case`. Beide Faktoren stehen oben mit ihrem Kommando; wer den Aufschlag
  gegen die Gesamtlaufzeit halten will, rechnet ihn aus **diesen zwei gemessenen Werten**, statt
  eine dritte Zahl zu notieren, die niemand nachfährt.
- **(B) Den Modus zulassen, `full-smoke`-Fälle aber aus dem Standard-Lauf ausklammern.**
  Verworfen. Das wäre eine **zweite Liste** neben `failure_form` — genau die Konstruktion, die der
  Treiber einmal beseitigt hat und deren Beseitigung sein Kopf begründet
  (`grep -c 'Zwei Listen, die getrennt gepflegt werden' harness/tools/mutate.sh` → **1**). Und ein
  Lauf, der bestehen kann, ohne die teuren Fälle zu fahren, ist das stille Grün, gegen das dieser
  Sensor antritt: ungelistet mit Zwischenschritt bleibt ungelistet.
- **(C) Die betroffenen Zusagen an einen billigeren Sensor hängen.** Verworfen, und zwar nicht aus
  Bequemlichkeit. Die zwei Zeilen aus
  [`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) sprechen über
  das **gebootstrappte Ziel**; ein Go-Test darüber prüfte den Emitter statt des Ziels — die erste
  Falsch-Klasse aus [`AGENTS.md`](../../../../AGENTS.md) §3.6, ein Test, der die Eigenschaft im
  Namen führt und ein Implementierungsdetail misst. Unabhängig davon ist die ADR *Accepted* und
  damit immutabel (§3.4); ihre Zeilen umzuhängen wäre eine Folge-ADR, kein Slice.
- **(D) Die Lücke stehen lassen und an einer Stelle statt an dreien benennen.** Verworfen, weil es
  das Problem nicht anfasst. Von den drei Stellen ist eine *Accepted* und unveränderlich — und
  ausgerechnet sie ist die, die die Pflicht ausspricht (*„schuldet darum beides: den Wächter und
  ein Fehlschlag-Muster"*). „An einer Stelle" ist damit der heutige Zustand minus zwei Zeilen:
  dieselbe Schranke, weniger Buchhaltung, und die Zusage bleibt unlistbar.

**Was der gewählte Weg ausdrücklich nicht mitentscheidet:** dass jede der 73 Fehlschlag-Stellen
einen Fall bekommt. Der Arm macht den **ersten** möglich; welche Zusage einen verdient, bleibt eine
Schnitt-Entscheidung je Zusage — und der gemessene Preis gehört dorthin, wo sie getroffen wird
(DoD 3).

## 2. Definition of Done

Drei slice-eigene Punkte, jeder mit dem Kommando, das ihn **rot** färbt (Modul 5 §Ziel-Form: ≤ 3;
[`AGENTS.md`](../../../../AGENTS.md) §3.6). Wo kein Kommando existiert, steht das dabei.

- [ ] **(1) Ein Fall in `test/mutations/` mit `# verify: full-smoke` läuft im Standard-`make
      mutate` mit und meldet seinen Wächter als rot gesehen.** Der Punkt ist selbstbezüglich —
      der Slice erweitert den Sensor, mit dem er belegt wird —, deshalb hängen **zwei** Rot-Läufe
      daran, und beide gehören mit ihrer Ausgabe in die Verify-Notiz, nicht nur ihr Ergebnis.
      **Rot (der Wächter hat Zähne):** den Wächter, auf den der Fall zielt, in
      [`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh) zahnlos machen
      (seine Bedingung auf wahr setzen) → `make mutate` meldet *„make full-smoke blieb GRUEN —
      '<expect>' hat keine Zaehne mehr"*.
      **Rot (Gegenprobe: ohne die Erweiterung bricht es ab, es läuft nicht durch):** den
      `full-smoke)`-Arm aus `failure_form` entfernen → der Lauf endet **vor dem ersten Fall** mit
      *„mutate: ABBRUCH — unbekannter `# verify: full-smoke` in test/mutations/."*, weil der
      Grün-Vorlauf jeden benutzten Modus vorab gegen `failure_form` hält. Ohne diese zweite
      Richtung wäre nur belegt, dass irgendetwas rot wird, nicht dass die Erweiterung es trägt.
- [ ] **(2) Das Fehlschlag-Muster trifft ausschließlich bei Fehlschlag — gemessen an der Ausgabe
      eines grünen Laufs, nicht behauptet.** Bedingung 4 des Treibers (*rot aus dem falschen Grund
      ist kein Beleg*) ist sonst wirkungslos; genau daran hing das bats-Muster einmal, weil `ok`
      auch im Bestehen gedruckt wird.
      **Rot:** ein Treffer des Musters in der Ausgabe eines **grünen** Laufs — die **0** ist hier
      der Erwartungswert, der Umfang des Laufs nicht. Gefahren am 2026-08-23 mit
      `make full-smoke >fs.log 2>&1` (Exit 0; `wc -l <fs.log` → **3016** Zeilen):
      `grep -cE 'full-smoke: FEHLER' fs.log` → **0**, aber
      `grep -cEi 'full-smoke.*fehler' fs.log` → **3** Treffer. Der grüne Lauf färbt Teil-Gates
      **absichtlich** rot und druckt ihre Ausgabe; eine dieser Zeilen trägt wörtlich
      `full-smoke: absichtlicher Schicht-Fehler`. Groß-/Kleinschreibung und der exakte Präfix sind
      hier also tragend, nicht kosmetisch — ein weiter gefasstes Muster wäre über einem grünen Lauf
      erfüllt und machte Bedingung 4 wirkungslos.
      **Ein stehender Sensor dafür existiert nicht** — für das bereits geführte `smoke: FEHLER`
      ebensowenig; die Prüfung ist einmalig und gehört in die Verify-Notiz. Das steht hier statt
      einer Zusage.
- [ ] **(3) Der teure Sensor wird nur auf ausdrückliche Nennung gefahren — und sein Preis steht
      dort, wo die nächste Nennung geschrieben wird.** Ein Fall ohne `# verify:`-Kopf bekommt
      seinen Sensor aus der `# expect:`-Zeile; lieferte diese Wahl je `full-smoke`, zahlten
      schlagartig alle Fälle ohne eigenen Kopf einen Preis, den niemand geschrieben hat
      (`grep -L '^# verify: ' test/mutations/*.sh | wc -l` → **142** von 144, Stand 2026-08-23 —
      Bestandsaufnahme, kein Erwartungswert).
      **Rot:** ein Fall in `test/mutate-driver.bats` über den **Wertebereich** von
      `narrow_sensor` (∈ {`test`, `test-go`, `test-bats`}), einmal rot gesehen, indem
      `narrow_sensor` probeweise `full-smoke` zurückgeben darf. Die Eigenschaft, nicht die heutige
      Verzweigung.
      **Ohne eigenen Sensor, und darum hier benannt:** der Kopf von `harness/tools/mutate.sh`
      nennt den gemessenen Preis eines `full-smoke`-Falls (ein Lauf für den Grün-Vorlauf, einer je
      Fall) an der Stelle, an der die übrigen Laufzeit-Begründungen stehen. `make comment-claims`
      prüft, ob ein **genannter Sensor existiert**, nicht ob eine Laufzeit-Angabe stimmt — diese
      Hälfte des Punktes färbt kein Kommando rot.


## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`harness/tools/mutate.sh`](../../../../harness/tools/mutate.sh) | update | der `full-smoke)`-Arm in `failure_form` — der einzigen Zulassungs-Quelle; dazu der Preis-Satz im Kopf, an der Stelle, an der die übrigen Laufzeit-Begründungen stehen (DoD 1, DoD 3) |
| `test/mutations/` | neu (eine Datei) | der Fall aus DoD 1 — Kopf `# verify: full-smoke`, `# expect:` als Teilstück der Fehlschlag-Zeile, gegen die er zielt; Nummerierung nach dem Bestand des Verzeichnisses |
| `test/mutate-driver.bats` | update | der **Wertebereich** von `narrow_sensor` aus DoD 3. Dort liegen bereits **4** Fälle über dieselbe Funktion (`grep -c '^@test "driver: narrow_sensor' test/mutate-driver.bats`) — sie prüfen die einzelnen Zuordnungen, keiner den Bereich |
| [`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh) | **unverändert** | der Wächter, gegen den der Fall zielt, existiert bereits; ihn zu bauen wäre ein anderer Slice. Er wird nur **vorübergehend** zahnlos gemacht, um DoD 1 rot zu sehen, und danach zurückgenommen |
| [`docs/plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) | **unverändert** | *Accepted*, immutabel ([`AGENTS.md`](../../../../AGENTS.md) §3.4). Sie wird als Constraint gelesen, nicht nachgezogen |
| [`docs/plan/planning/open/slice-092-traeger-inventur.md`](slice-092-traeger-inventur.md), [`docs/plan/planning/welle-11-traeger-aussage.md`](../welle-11-traeger-aussage.md) | **unverändert in diesem Lauf** | beide beschreiben heute einen wahren Zustand; sie werden zur Closure dieses Slice nachgezogen, und zwar vom Planner, dem sie gehören (§6) |
| [`docs/plan/planning/in-progress/roadmap.md`](../in-progress/roadmap.md) | **unverändert** | wellenlose Arbeit wird dort nicht geführt ([`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird) Setzung 2/3) |

**Die Wahl des Wächters ist nicht frei — sie hat ein Kriterium und eine mechanische Probe.** Der
Fall muss auf eine Eigenschaft zielen, die in `make test` **und** in `make smoke` keinen Wächter
hat; sonst ist `full-smoke` nicht die schmalste ausreichende Stufe und der Fall zahlte den höheren
Preis ohne Grund — dieselbe Regel, die `narrow_sensor` je Fall anwendet. **Probe, bevor der Fall
geschrieben wird:** die Mutation anwenden, dann `make test` und `make smoke` fahren — beide müssen
**grün** bleiben, `make full-smoke` rot. Bleibt einer der beiden rot, gehört der Fall dorthin und
nicht hierher.

Kandidaten, deren Gegenstand es nur im gebootstrappten Ziel und nur unter einem echten `make`-Lauf
gibt (`grep -n 'overriding recipe' harness/tools/full-smoke.sh`;
`grep -n 'record-gates schrieb keinen' harness/tools/full-smoke.sh`;
`grep -n 'VERBOTENEN Import' harness/tools/full-smoke.sh`): der include-once-Wächter des
emittierten `a-check.mk` bei zwei Modulen, der Gate-Nachweis-Stempel im Ziel, und das emittierte
Arch-Gate unter einem verbotenen Import. Die Auswahl trifft der Implementer mit der Probe oben —
diese drei sind Ausgangspunkte, keine Vorgabe.

## 4. Trigger

**Beginn (`open` → `next` → `in-progress`): sofort möglich, nichts blockiert ihn.** Der Gegenstand
liegt vollständig in diesem Repo — Treiber, Sensor und Fall-Verzeichnis —, er berührt die
emittierte Ebene nicht und hängt an keiner Welle. Insbesondere wartet er **nicht** auf
[welle-10](../welle-10-re-baseline.md) oder [welle-11](../welle-11-traeger-aussage.md): deren
Trigger stehen auf dem vendored Baum, den dieser Slice nicht liest.

Die zwei Rückführungen, vorab benannt:

- **`in-progress` → `next` (zu groß):** wenn sich kein Wächter finden lässt, der die Probe aus §3
  besteht, ohne dass zuvor
  [`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh) selbst erweitert werden
  müsste. Dann sind es zwei Slices — einer, der den Wächter baut, und dieser.
- **`in-progress` → `open` (blockiert):** wenn `make full-smoke` auf der isolierten Kopie außerhalb
  des Repos nicht reproduzierbar grün wird. Dann ist der Blocker die Isolation, nicht der Arm, und
  gehört als Carveout nach Modul 7 dokumentiert — mit dem Grün-Vorlauf als Trigger, denn ohne ihn
  ist jeder Fall dieses Modus bedeutungslos.

## 5. Closure-Trigger

DoD (1)–(3) erfüllt, jeder mit gefahrenem Kommando; die **beiden** Rot-Läufe aus DoD 1 mit ihrer
Ausgabe in der Verify-Notiz; `make gates` grün; `make mutate` grün **einschließlich** des neuen
Falls; `make full-smoke` grün; Closure-Notiz mit Steering-Loop-Lerneintrag in einer der drei Formen
(geschärfte Regel · neuer Sensor · benannte Spec-Lücke).

## 6. Risiken und offene Punkte

- **Die zwei `full-smoke`-Zeilen aus
  [`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) werden
  einlösbar, nicht eingelöst.**
  *„Der Träger schreibt im Ziel"* und *„Die Auswertung meldet ihre Leere — und nennt die Grenze"*
  sind dort **Geschuldet, nicht geliefert**; ihr Gegenstand — Träger, Wrapper, Auswertung —
  existiert noch nicht und gehört dem Umsetzungs-Slice. Was dieser Slice ändert, ist die andere
  Hälfte der Schuld: die Grenze über der Fitness-Tabelle verlangt vom Einlösenden **beides**, den
  Wächter *und* ein Fehlschlag-Muster. Danach schuldet er nur noch den Wächter.
- **Drei Stellen sprechen heute über die Lücke; nach diesem Slice beschreiben zwei einen Zustand,
  den es nicht mehr gibt.** Die Menge ist vollständig aufgezählt, jeder Ort mit seiner Behandlung:
  die Grenze in
  [`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) **bleibt
  stehen** (*Accepted*, [`AGENTS.md`](../../../../AGENTS.md) §3.4; eine Korrektur wäre eine
  Folge-ADR mit Supersedes, kein Slice-Nebenprodukt); die Zeilen in
  [slice-092](slice-092-traeger-inventur.md) (DoD 2 und §6) und in
  [welle-11](../welle-11-traeger-aussage.md) (§3, Closure-Trigger) sind **lebende Plan-Artefakte**
  und werden zur Closure dieses Slice nachgezogen. Sie jetzt zu ändern hieße, eine heute wahre
  Aussage vorab falsch zu machen.
- **Der gemessene Preis ist eine Untergrenze.** Die 91.36 s stammen aus einem **unmutierten**
  Lauf bei warmem Docker-Cache — das ist exakt der Preis des Grün-Vorlaufs. Der Fall selbst
  mutiert eine Quelldatei und erzwingt damit den Neubau, den `make artifact` in `full-smoke`
  anstößt; sein Lauf ist teurer. Um wieviel, misst der Implementer
  am fertigen Fall — eine Schätzung dazu stünde hier ohne Kommando.
- **Der kalte Cache ist der ungünstige Fall, und er trifft CI.** Dort laufen `full-smoke` und
  `mutate` als **getrennte** Jobs (`grep -n 'full-smoke\|mutate' .github/workflows/ci.yml`), die
  Wanduhr des Workflows wächst also nur um das, was der `mutate`-Job zulegt — nicht um die Summe.
- **Was der Arm nicht leistet.** 73 Fehlschlag-Stellen in
  [`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh) stehen 0 Fällen
  gegenüber (§1, mit Kommando). Der Arm macht den **ersten** möglich; er inventarisiert nicht, und
  aus *ungelistet* folgt **nicht**, dass die jeweilige Eigenschaft anderswo ungeprüft wäre — viele
  dieser Stellen prüfen dieselbe Eigenschaft wie ein `make test`- oder `make smoke`-Wächter, der
  seinen Fall längst hat. Eine Regel *„jede Stelle bekommt einen Fall"* wäre eine andere
  Entscheidung mit einem anderen Preis und gehört, wenn überhaupt, in einen eigenen Schnitt.
- **Der Slice bewacht seinen eigenen Sensor — und kann sich deshalb selbst täuschen.** Fiele die
  Gegenprobe aus DoD 1 weg, bliebe offen, ob der Fall rot wird, *weil* der neue Arm trägt, oder aus
  einem anderen Grund. Sie ist darum kein Zusatz, sondern die Hälfte, die den Punkt zu einer Zusage
  macht ([`AGENTS.md`](../../../../AGENTS.md) §3.6).

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `harness/tools/` und `test/`
gehören zum Greenfield-Bestand; der Modus steht in der Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md).
