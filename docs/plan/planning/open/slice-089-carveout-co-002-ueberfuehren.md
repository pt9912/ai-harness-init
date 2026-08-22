# Slice slice-089: Der Carveout wird übergeführt — der Status trägt den Übergang, die Adresse bleibt

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (reaktiver Nachzug einer Entscheidung) — gegen
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1 geprüft, alle drei Fragen samt Antwort in §3. Er ist **kein Mitglied** von
[welle-09](../welle-09-modul-15-konformitaet.md) und ändert an ihrem Plan nichts; was ihn mit ihr
verbindet, ist eine **Reihenfolge**, und die steht in §6.

**Bezug:**
[`ADR-0021`](../../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md) — die Entscheidung, deren
Folgepflichten dieser Slice vollzieht: Festlegung 5 lässt den Carveout an seiner Adresse und legt
den Übergang in seinen **Status**. Von den sieben Folgepflichten trägt dieser Slice **drei** — den
geschriebenen Übergang in Stub und Index, die sechs Zeiger, den fälligen Mutations-Fall; die zwei
weiteren Planner-Posten liegen ausdrücklich außerhalb (§3). **Der Slice nennt die ADR; die ADR
nennt ihn nicht.**
[`CO-002`](../../carveouts/CO-002-token-achse-je-rolle.md) — der Gegenstand: ein Carveout, dessen
Trigger nach der Messung nur noch im fremden Vertrag liegt und der damit *de facto* permanent ist.
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) — der
fällige Mutations-Fall ist ein **Zahn**, kein neuer Gate-Name: er läuft in `make mutate`, nicht in
`make gates`, und behauptet nichts Neues.
[`AGENTS.md`](../../../../AGENTS.md) §3.3 (Move und Inhaltsänderung sind zwei Commits — die Auflage
greift hier allein für die Lifecycle-Moves **dieser Plan-Datei**, denn der Carveout wird nicht
bewegt), §3.4 (die ADR ist ab *Accepted* immutabel) und §3.7 (der Kommentar im Hook beschreibt,
was da ist).

**Autor:** Planner. **Datum:** 2026-08-22.

---

## 1. Ziel

**Nach diesem Slice steht der Ausfall der Verbrauchs-Achse je Rolle an genau einem Ort entschieden
— in der ADR —, und der Carveout sagt an seiner eigenen Adresse, dass er dorthin übergeführt ist.
Keine Stelle im Repo führt die Messung noch als ausstehend.**

Ein Carveout sagt zu, temporär zu sein; seinen Trigger führt er als erreichbare Bedingung. Nach der
Messung ist der eine erreichbare Weg ausgefallen, und was bleibt, liegt im fremden Vertrag. Ein
Carveout, der so stehen bliebe, wäre die permanente Ausnahme, die behauptet, temporär zu sein —
genau die Doku-Drift, die Carveouts verhindern sollen. **Träger dieser Aussage ist ab hier der
Status, nicht das Verzeichnis:** der Stub bleibt liegen, wo er liegt, und wird zur **Weiche** auf
das Verdikt.

**Was er ausdrücklich NICHT tut: entscheiden.** Er ändert keine ADR, er formuliert keine neue
Begründung und er importiert das Verdikt nicht an einen zweiten Ort — *„ein zweiter Ort driftet"*
([`ADR-0012`](../../adr/0012-haupt-kontext-ohne-token-bilanz.md) Folgepflicht 1). Er schreibt einen
Übergang, zieht Aussagen nach und baut einen Zahn.

## 2. Definition of Done

Jeder Punkt nennt das Kommando, das ihn rot färbt — und wo keines existiert, steht **das** dabei.
Eine Zusage reicht nur so weit wie ihr Sensor
([slice-086](../done/slice-086-vordergrund-per-updatedinput.md) §7).

- [ ] **(1) Der Übergang ist geschrieben, nicht verschoben — vier Änderungen am Stub, eine am
      Index, ein Commit.** An [`CO-002`](../../carveouts/CO-002-token-achse-je-rolle.md): der Status
      aus Festlegung 5 (`Status: Permanent — übergeführt in` gefolgt von der Kennung
      [`ADR-0021`](../../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md)); ein aktuelles
      `Letzte Prüfung`-Datum samt Geschichte-Zeile; im Abschnitt `## Auflösungs-Trigger` fällt die
      Handlungs-Anweisung *„und nach `done/` zu verschieben"*, und der Abschnitt bekommt einen
      Vorspann-Satz, der auf den Status im Kopf zeigt — **der Abschnitt selbst bleibt**; der
      Abschnitt `## Verifikation (nach Auflösung)` fällt **als Ganzes**, mit allen Haken (heute
      **5**:
      `awk '/^## Verifikation/,/^## Geschichte/' docs/plan/carveouts/CO-002-token-achse-je-rolle.md | grep -c '^- \[ \]'`).
      An [`docs/plan/carveouts/README.md`](../../carveouts/README.md) eine Stelle: der Eintrag
      verlässt §Aktiv und steht in einem eigenen Abschnitt für den permanenten Übergang.
      **Kein `git mv`, ein Commit** — ein `carveouts/done/` entsteht nicht.

      **Rot färbt ihn** — drei Kommandos über
      `docs/plan/carveouts/CO-002-token-achse-je-rolle.md`, jedes deckt genau die Änderung, neben
      der es steht, und jedes trifft heute genau **1** Zeile (`grep -c` mit demselben Muster):
      `grep -n 'zu verschieben'` → **leer (Exit 1)**; `grep -n '^## Verifikation'` → **leer
      (Exit 1)**; `grep -n 'd-check:ignore'` → **leer (Exit 1)** als Gegenprobe, weil die Direktive
      in der letzten Zeile des gestrichenen Abschnitts steht. Dazu `make docs-check` →
      `0 Befund(e)`, Exit 0; die Datei-Zahl derselben Ausgabezeile wandert mit dem
      Markdown-Bestand und ist **kein** Erwartungswert
      ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
      Setzung 2).

      **Kein Kommando deckt** den Vorspann-Satz, den Status im Kopf und den Abschnitt im Index:
      kein Modul von `.d-check.yml` liest, ob ein Satz **ergänzt** wurde oder welchen Status ein
      Kopf trägt. Ein Gate, das den Stub an seiner Adresse duldet, sagt nichts darüber, dass er
      dort richtig steht. Träger ist die Verifikation am Text (Modul 11).
- [ ] **(2) Die sechs Zeiger behalten ihre Adresse; gezogen wird ihre Aussage.** Fünf stehen in
      [`spec/spezifikation.md`](../../../../spec/spezifikation.md) §5 (fünfter Punkt der
      Erfassungs-Liste, START-KONVENTION, Wächter-Absatz zu deren Bedingung 2, Abweichung 1,
      Abweichung 5), der sechste im Kopf von
      [`.claude/hooks/pretooluse-agent-guard.sh`](../../../../.claude/hooks/pretooluse-agent-guard.sh).
      Es fällt **jeder Satz, der eine Messung als ausstehend führt** oder den Ausfall als offene
      Frage beschreibt; was bleibt, ist der Zustand im Indikativ und ein Zeiger, der auf einen Stub
      mit Verdikt-Status führt.

      **Zwei Formen sind versperrt, und die Schranke ist vorher zu lesen (§3, *Warum die Spec nicht
      auf die ADR zeigt*):** die Stellen ziehen **nicht** auf die ADR (ein Link aus dem
      Spec-Stratum ist `matrix-forbidden`, die bare Kennung `id-unlinked`), und das Verdikt wird
      nicht ausgeschrieben — das wäre der zweite Ort. Der Hook-Kommentar ist kein Spec-Stratum;
      dort bindet [`AGENTS.md`](../../../../AGENTS.md) §3.7, dass der Kommentar beschreibt, was da
      ist.

      **Rot färbt ihn:**
      `grep -n 'CO-002' spec/spezifikation.md .claude/hooks/pretooluse-agent-guard.sh` → weiter
      **sechs Zeilen in zwei Dateien**; heute gemessen mit `grep -c` je Datei: **5** in
      `spec/spezifikation.md`, **1** in `.claude/hooks/pretooluse-agent-guard.sh`. Verschwindet
      eine, ist eine Aussage **entfernt** statt nachgezogen. Dazu `make docs-check` grün — er ist
      es nach dem Nachzug, weil sich keine Adresse bewegt, und rot, sobald eine der zwei
      versperrten Formen im Spec-Stratum steht.

      **Kein Kommando deckt**, ob ein Satz seine Aussage wirklich nachgezogen hat: `grep` zählt
      Zeilen, keine Tempora. Träger ist die Verifikation am Text.
- [ ] **(3) Der fällige Mutations-Fall färbt den Wächter rot, der die neun Werte hält.**
      Beschrieben als **Eigenschaft, nicht als Adresse**: ein Fall unter `test/mutations/`, der
      einen Eintrag der Positiv-Liste aus `responseKeys()` in `internal/span/response.go`
      **entfernt** und dabei `TestNoResponseFreetextReachesSpan` in
      `internal/span/response_test.go` rot färbt. **Nicht** `TestOnlyAgentToolGetsResponseValues`:
      der hält die **Werkzeug-Achse** und in seiner Gegenprobe vier der neun Werte — die zwei
      Cache-Zähler gehören nicht dazu, und ihr Entfernen lässt ihn grün. Die vorhandenen Fälle
      decken diese Richtung nicht: `grep -ln 'responseKeys' test/mutations/*.sh` → **leer
      (Exit 1)**, und `test/mutations/133-span-werkzeugachse-geweitet.sh` **weitet** die
      Werkzeug-Achse, statt aus der Liste zu entfernen. Die Nummer ist beim Anlegen die nächste
      freie.

      **Rot färbt ihn:** `make mutate` — ein Fall, dessen Mutation grün durchläuft, wird dort als
      Befund gemeldet. **Kein Kommando meldet seine Abwesenheit:** `make mutate` prüft die Fälle,
      die da sind; ohne diesen Fall bleibt alles grün, und Festlegung 2 der ADR bleibt eine Absicht
      ([`AGENTS.md`](../../../../AGENTS.md) §3.6). Genau deshalb steht er als **eigener** DoD-Punkt
      und nicht als Nebensatz von (1).
- [ ] `make gates` grün, `make mutate` ohne Befund.
- [ ] Doku-Update, falls ein öffentlicher Vertrag berührt ist.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

### Was der Schnitt aus der Ort-Entscheidung übernimmt — und was er nicht wiederholt

Der Ort ist entschieden: der Stub bleibt liegen, der **Status** trägt den Übergang. Die Begründung
steht in der ADR und wird hier **nicht zweitgeschrieben**. Für den Schnitt folgt daraus dreierlei,
und alles drei ist mechanisch: **kein `git mv`** am Carveout; **ein** Commit statt zwei
([`AGENTS.md`](../../../../AGENTS.md) §3.3 greift bei Move **und** Rewrite — hier gibt es nur den
Rewrite); und ein `carveouts/done/` entsteht nicht, also auch keine `d-check:ignore`-Direktive
dafür.

**Und eine vierte Folge, die man beim Statuswechsel übersieht: die zwei Ort-Anweisungen im Stub
selbst müssen mit.** Sein Auflösungs-Trigger ordnet den Move an, seine Verifikations-Checkliste
führt ihn als Haken. Beides ist kein Regelwerks-Satz, sondern die Erwartung, die der Carveout an
seinen eigenen Ausgang schrieb, als der Ausgang noch offen war. Bleiben sie stehen, trägt die
Weiche die Anweisung, die die Entscheidung verbietet — und **kein Sensor sieht das**, weil sie
keinen Link bricht. Dafür stehen die drei `grep`-Kommandos in DoD (1).

Der Abschnitt `## Auflösungs-Trigger` selbst **bleibt**: die ADR zitiert ihn zweimal verbatim, und
eine Löschung machte Zitate zweier immutabler ADRs quellenlos. Was den Leser trennt, ist der Status
im Kopf desselben Dokuments — und damit er dort nicht erst gesucht werden muss, zeigt der
Vorspann-Satz auf ihn.

### Warum die Spec nicht auf die ADR zeigt — die Schranke, die den Nachzug formt

Die naheliegende Ausführung wäre, die fünf Spec-Stellen auf die ADR zu **verlinken**. Sie ist
versperrt, und zwar mechanisch:

- Das Doku-Gate führt eine **Referenz-Richtung** (SDP): `spec-straten` → `adr` ist **nicht erlaubt**
  ([`.d-check.yml`](../../../../.d-check.yml), `matrix.rules`). Ein Link von
  [`spec/spezifikation.md`](../../../../spec/spezifikation.md) auf die ADR färbt `make docs-check`
  rot.
- Die Kennungs-Regel ([`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids))
  verlangt für jedes `ADR-`-Token einen Link — **auch in Inline-Code**. Die Kennung dort bar zu
  nennen, ist also ebenfalls rot.
- **Gemessen, nicht angenommen:** `grep -n 'ADR-0' spec/spezifikation.md` liefert genau **einen**
  Treffer, und der steht in §7 Historie — einem der drei Abschnitte, die
  `matrix.exclude-sections` ausnimmt. Die Spec hält die Richtung heute ein.

**Folge für DoD (2):** die fünf Stellen behalten ihren Zeiger und verlieren die **offene Frage** —
der Ausfall im Indikativ, adressiert über den Stub, der mit diesem Slice den Verdikt-Status trägt.
Wer die Begründung sucht, findet sie über den ADR-Index, nicht über einen Abwärts-Link. Das ist
keine Verlegenheit, sondern dieselbe Regel, aus der die Richtung stammt: das Vertrags-Stratum sagt,
**was gilt**, nicht **warum entschieden wurde**.

### Welle oder nicht — der Test aus [`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird) Setzung 1

1. **Bündel?** Nein. Die drei Folgepflichten, die dieser Slice trägt, sind **eine** Bewegung an
   einem Gegenstand: der Stub trägt den Übergang, seine Zeiger verlieren die offene Frage, sein
   Zahn entsteht. Kein zweiter Slice muss mitlanden, damit die Aussage stimmt — im Gegenteil:
   getrennt gelandet, hinterließe jeder Teil einen Zwischenzustand, in dem eine Stelle eine
   entschiedene Frage als offen führt.
2. **Gemeinsames Closure-Kriterium?** Nein. Das Kriterium wäre *„keine Stelle führt die Messung
   mehr als ausstehend"* — und das ist DoD (2), nicht mehr.
3. **Auslöser reaktiv oder gewollt?** **Reaktiv.** Eine Entscheidung ist gefallen und das Repo
   hinkt ihr nach; wiederhergestellt wird Konsistenz, nicht eine neue Fähigkeit. Der fällige
   Mutations-Fall sieht wie ein Zuwachs aus, ist aber der Zahn zu einer **bestehenden** Zusage.

Dreimal *ohne Welle*. **Folge nach Setzung 2 und 3:** kein Roadmap-Eintrag, weder jetzt noch beim
Abschluss.

### Die zwei Planner-Posten, die NICHT in diesen Slice gehören — und wohin sie gehen

Die Entscheidung verteilt zwei weitere Folgepflichten an den **Planner**: die zwei Matrix-Zellen der
Repo-Spalte (*Token-Attribution × Repo*, Hintergrund-Teil, und *Cache-Counter × Repo*) tragen
künftig **ADR-Verdikt** statt *deklariert*, und das Carveout-Audit muss den **Status** lesen statt
des Verzeichnisses — sonst zählt es weiter zwei aktive Carveouts und bestätigte eine entschiedene
Sache als offene Frage. Beide liegen **außerhalb** dieses Slice, aus drei Gründen, die je für sich
tragen:

- **Die Zellen haben heute keinen Gegenstand.** Sie entstehen mit der Ergebnis-Notiz der Welle, und
  die gibt es nicht: `ls docs/plan/planning/done/ | grep -c 'welle-09-results'` → **0**. Ein
  DoD-Punkt darauf zwänge diesen Slice, die Closure einer fremden Welle zu eröffnen — oder er wäre
  nicht prüfbar.
- **Ihr Auslöser ist nicht dieser Slice, sondern die Annahme der ADR.** Der Satz im Wellen-Plan,
  der für **beide** Carveout-Ausgänge `done/` voraussetzt, ist mit dem Statuswechsel falsch
  geworden — vor diesem Slice und unabhängig von ihm. Ein Nachzug daran gehört dem Wellen-Plan als
  lebendem Planner-Artefakt, nicht einem Slice, der einen anderen Gegenstand vollzieht.
- **Der Slice wäre sonst Quelle und Sensor derselben Aussage.** Das Audit **liest** den Status, den
  DoD (1) **schreibt**. Wer beides in einen Slice legt, prüft seine eigene Änderung mit ihr selbst.

Dazu die harte Schranke aus Modul 5: dieser Slice trägt bereits **drei** slice-eigene DoD-Punkte,
jeder mit seinem Rot-Kommando. Ein vierter hieße nicht, dass die DoD länger sein muss, sondern dass
der Schnitt falsch ist.

**Wo sie landen, mit Träger statt bloßer Ablage:** die zwei Zellen und die Audit-Regel gehören in
die **Closure von [welle-09](../welle-09-modul-15-konformitaet.md)** — dort entstehen die Zellen,
dort läuft das Audit. Der Nachzug des Satzes, der `done/` voraussetzt, ist **Planner-Arbeit am
lebenden Wellen-Plan** und seit der Annahme der ADR fällig; spätestens die Closure zieht ihn, sonst
prüft sie gegen einen Satz, den die Entscheidung aufgehoben hat. Die Reihenfolge, die daraus für
**diesen** Slice folgt, steht in §6.

### Berührte Dateien

| Datei / Komponente | Änderungs-Art | Wer schreibt | Begründung |
|---|---|---|---|
| [`CO-002`](../../carveouts/CO-002-token-achse-je-rolle.md) | update (vier Stellen), **kein** `git mv` | Implementer | Status · `Letzte Prüfung` und Geschichte-Zeile · Handlungs-Anweisung raus und Vorspann-Satz rein · Abschnitt *Verifikation* ganz raus. **Ein** Commit — es gibt nur den Rewrite |
| [`docs/plan/carveouts/README.md`](../../carveouts/README.md) | update (eine Stelle) | Implementer | §Aktiv verliert die Zeile, ein eigener Abschnitt für den permanenten Übergang bekommt sie — der Index ist die Übersicht, nicht eine zweite Quelle |
| [`spec/spezifikation.md`](../../../../spec/spezifikation.md) | update (fünf Stellen in §5), Adresse **unverändert** | Spec-Eigentümer + Implementer | die offene Frage fällt, der Zustand bleibt im Indikativ; keine ADR-Verlinkung (s. o.) |
| [`.claude/hooks/pretooluse-agent-guard.sh`](../../../../.claude/hooks/pretooluse-agent-guard.sh) | update (Kopf-Kommentar), Zeiger **unverändert** | Implementer | ein Kommentar beschreibt, was da ist ([`AGENTS.md`](../../../../AGENTS.md) §3.7): die Messung ist gefahren, nicht ausstehend |
| `test/mutations/` (ein neuer Fall) | neu | Implementer | der Zahn zu Festlegung 2; Eigenschaft in DoD (3), Nummer beim Anlegen die nächste freie |
| `internal/span/response.go`, `internal/span/response_test.go` | **unverändert** | — | der neue Fall mutiert sie zur Laufzeit; wer sie ändert, verschiebt die Zusage, statt ihren Zahn zu bauen |
| [`docs/plan/adr/`](../../adr/) | **unverändert** | — | eine ADR ist ab *Accepted* immutabel ([`AGENTS.md`](../../../../AGENTS.md) §3.4); dieser Slice vollzieht, er entscheidet nicht |
| [welle-09](../welle-09-modul-15-konformitaet.md) | **unverändert** | — | die zwei Matrix-Zellen und die Audit-Regel gehören der Closure jener Welle (s. o.), nicht diesem Slice |

## 4. Trigger

**`open` → `next`: erfüllt.**
[`ADR-0021`](../../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md) ist **Accepted** —
`grep -n '^\*\*Status:' docs/plan/adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md` gibt
`3:**Status:** Accepted` aus, und die Zeile in
[`docs/plan/adr/README.md`](../../adr/README.md) führt dieselbe Angabe. Solange sie *Proposed*
stand, vollzöge dieser Slice eine Entscheidung, die noch zur Debatte steht; sie steht es nicht
mehr. Dieser Slice ändert an der ADR nichts, auch nicht ihren Status.

**`next` → `in-progress`: WIP-Limit prüfen.** `ls docs/plan/planning/in-progress/` zeigt heute
außer der Roadmap keinen Slice. Die Belegung wandert mit dem Bestand — sie ist beim Eintritt neu zu
fahren, nicht aus dieser Zeile abzuschreiben.

Rückführungen:

- `in-progress` → `open`: die fünf Spec-Stellen lassen sich **nicht** ohne Verweis auf das Verdikt
  formulieren, weil eine von ihnen die Begründung mitträgt statt nur den Zustand. Dann ist zuerst
  zu entscheiden, was das Vertrags-Stratum an dieser Stelle überhaupt sagen soll — eine Frage an
  den Spec-Eigentümer, kein Nachzug.
- `in-progress` → `next`: der fällige Mutations-Fall erweist sich als eigener Gegenstand (die
  Mutation trifft mehr als einen Eintrag der Positiv-Liste, oder der Test hält sie nicht). Dann
  trennt ein Re-Schnitt den **geschriebenen Übergang samt Zeigern** vom **Zahn**; beide sind
  einzeln lieferbar und einzeln prüfbar.

## 5. Closure-Trigger

DoD vollständig; Review konform (Modul 10) mit ausgestelltem Verdikt; Verifikation (Modul 11)
bestätigt die DoD; `make gates` und `make mutate` grün; Closure-Notiz mit Steering-Loop-Eintrag.

**Der Link-Zug gehört zu den Moves dieses Slice — und das sind seine eigenen.** Der Carveout wird
nicht bewegt; nach dem Vollzug zeigt kein Verweis auf eine andere Adresse als vorher. Diese
Plan-Datei dagegen wandert dreimal: `open` → `next`, `next` → `in-progress` und am Ende nach
`done/`. Jeder ist ein eigener, **reiner** Move-Commit
([`AGENTS.md`](../../../../AGENTS.md) §3.3); **nach jedem** folgt der
Link-Reconciliation-Commit. Der Eintritts-Move braucht ihn genauso wie der Abgang — dieselbe Lehre,
die [slice-086](../done/slice-086-vordergrund-per-updatedinput.md) §7 als Plan-Defekt benannt hat,
nachdem sein §5 den Zug nur für `done/` schrieb und er zweimal gebraucht wurde.

**Betroffen ist die eingehende Menge**, denn sie nennt das Quellverzeichnis im Pfad:
`grep -rn ']([^)]*open/slice-089-carveout-co-002-ueberfuehren\.md)' --include='*.md' docs` → heute
**5** Zeilen in **2** Dateien, beide unter `docs/plan/planning/done/`. Das ist eine
**Bestandsaufnahme, kein Erwartungswert** — jedes neue Dokument, das auf diesen Slice zeigt, hebt
die Zahl
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2); vor jedem Move ist das Kommando mit dem dann geltenden Quellverzeichnis neu zu fahren.
Die eigenen `../`-Links dieser Datei liegen in allen vier Verzeichnissen auf gleicher Tiefe; ob
deshalb wirklich keiner bricht, entscheidet nicht dieser Satz, sondern **`make docs-check` nach
jedem Move** — solange er rot ist, ist der Zug nicht fertig.

**Der Vollzug selbst hat drei Kommandos und eine Lücke.** Die vier Inhaltsänderungen am Stub
brechen keinen Link und werden von keinem Gate gesehen; die drei `grep`-Kommandos aus DoD (1) sind
ihr einziger Sensor, und der Vorspann-Satz hat auch den nicht. Der Closure-Trigger ist deshalb
nicht mit *grün* erfüllt, sondern erst mit dem Abgleich am Text.

## 6. Risiken und offene Punkte

- **Der Nachzug erzeugt leicht einen zweiten Ort für das Verdikt.** Wer beim Ziehen der fünf
  Spec-Stellen die Begründung mitschreibt, hat die ADR abgeschrieben — und zwei Fassungen driften.
  Die Probe ist eine Frage an den Satz: sagt er, **was gilt**, oder sagt er, **warum**? Das Zweite
  gehört nicht ins Vertrags-Stratum. Derselbe Fehler in der anderen Richtung wäre, den Zeiger
  selbst zu entfernen: dann verliert die Stelle ihre Weiche, und DoD (2) ist rot.
- **Der Stub verliert leicht mehr als die Anweisung.** Ein breites Muster trifft zu viel:
  `grep -c 'done/' docs/plan/carveouts/CO-002-token-achse-je-rolle.md` → heute **5** Zeilen, davon
  **drei** Verweise auf ein abgeschlossenes Planungs-Artefakt, die **bleiben**. Nur das schmale
  Muster aus DoD (1) trifft die Handlungs-Anweisung; und der Abschnitt `## Auflösungs-Trigger`
  bleibt stehen, weil die ADR ihn zitiert.
- **Der Vorspann-Satz ist die eine Zusage ohne Sensor.** Alle drei `grep`-Kommandos können leer
  sein, während er fehlt, und `make docs-check` bleibt dabei grün. Träger ist die Verifikation am
  Text — hier benannt, statt vom Gate erwartet.
- **Reihenfolge gegenüber [welle-09](../welle-09-modul-15-konformitaet.md), nicht
  Mitgliedschaft.** Deren Carveout-Audit liest den Zustand des Stubs. Schlösse die Welle, bevor
  dieser Slice gelandet ist, läse es *Aktiv* und schriebe die zwei Zellen als *deklariert* — falsch
  gegen eine angenommene ADR. Die Bedingung ist prüfbar und schmal: der Kopf des Stubs trägt den
  Verdikt-Status, bevor die Ergebnis-Notiz der Welle die Zellen setzt. Sie gehört dem Planner jener
  Closure, nicht diesem Slice.
- **`test/mutations/` ist kein Gate.** Der neue Fall läuft in `make mutate`, nicht in `make gates`;
  er behauptet keinen neuen Wächter, sondern prüft die Zähne eines vorhandenen
  ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
  `make mutate` läuft pro Push in CI
  ([`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions)).
- **Nicht in diesem Slice:** jede Änderung an
  [`ADR-0021`](../../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md) selbst (immutabel ab
  *Accepted*); die zwei Planner-Posten aus §3 (Matrix-Zellen und Audit-Regel — welle-09-Closure);
  der Eintrag im Adaptions-Block, den die Entscheidung ausdrücklich **nicht** anordnet (Architect —
  nichts zu tun); die Erlaubnis-Frage zum Transkript als Quelle (Auftraggeber); und der
  Geltungsbereich von [`AGENTS.md`](../../../../AGENTS.md) §3.7 für verbatim abgelegten
  Skript-Text (Architect, eigener Lauf).

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example):
[`docs/plan/carveouts/`](../../carveouts/), das Technik-Stratum
([`spec/spezifikation.md`](../../../../spec/spezifikation.md)), `.claude/hooks/` und
`test/mutations/` gehören zum Greenfield-Bestand; der Modus steht in der Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md).
