# Slice slice-108: Die Feldlisten-Wächter tragen ihren Fall oder ihre ausgesprochene Grenze — und jeder Fall die schmalste Stufe, die seine Eigenschaft verlangt

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (Sensor-Wartung, reaktiv). Die drei Fragen aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1, hier beantwortet: **(1) Bündel?** Nein — ein Durchgang über eine abgeschlossene, in §1
aufgezählte Menge von Wächtern; einzeln lieferbar. **(2) Gemeinsames Closure-Kriterium?** Nein —
jedes denkbare wäre die Abschrift seiner eigenen DoD. **(3) Auslöser reaktiv oder gewollt?**
Reaktiv: acht gebaute Wächter ohne Fall (§1). **Auch nicht in
[welle-12](../welle-12-erfassungsschicht-emittieren.md):** er liefert **kein** Akzeptanzkriterium
von [`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) — die
Zeilen *„Redaktion"* und *„Benannte Grenze"* sind mit
[slice-098](../done/slice-098-feldliste-ist-ausdruck-des-traegers.md) geliefert, und die
**Haltbarkeit** eines Dogfood-Zahns ist kein Kriterium jener Anforderung. Nach
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 2 steht wellenlose Arbeit **nicht** in der Roadmap; ihr Zustand ist das Verzeichnis.

**Ebene: Dogfood, nicht emittiert.** Gegenstand sind Go-Wächter dieses Repos und die Fälle in
`test/mutations/`. Was hier entsteht, geht **nicht** mit: `test/` liegt in keinem emittierten
Satz, und das Ziel bekommt keine Datei, die es nicht schon bekommt.

**Bezug:**
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (die Regel, an der die Menge hängt — *„gelistet heißt:
wer keinen Fall in `test/mutations/` hat, ist unbewacht"*; und ihr zweiter Satz, dass eine Zusage
erst fertig ist, wenn ihr Gegenbeispiel **rot gesehen** wurde),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (die
Klasse, gegen die die Stufen-Frage in DoD (2) gerichtet ist: ein Wächter, dessen Rot niemand
prüft, ist ein Gate über einer Behauptung),
[`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) (**Accepted** —
Festlegung 7 ist der Vertrag, den diese Wächter messen; dieser Slice ändert an ihm nichts, er
belegt ihn),
[`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks) (die
Sensor-Mechanik, in der ein Fall zählt),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben dem Kommando, das genau sie liefert, und wandert mit ihrem Bestand),
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
(Verortung).

**Autor:** Planner. **Datum:** 2026-08-26.

---

## 1. Ziel

**Jeder Wächter über der Feldliste im Ziel ist entweder von einem `test/mutations/`-Fall rot zu
sehen oder mit Grund als unbewacht ausgesprochen — und jeder neue Fall läuft auf der schmalsten
Stufe, die seine Eigenschaft verlangt, nicht auf der, die sein Nachbar gewählt hat.**

### Die Ausgangslage: acht von fünfzehn, aufgezählt statt beziffert

Die Eigenschaft, über die gezählt wird: *ein `func Test…` in
[`internal/span/fieldlist_test.go`](../../../../internal/span/fieldlist_test.go) oder
[`internal/emit/fieldlist_test.go`](../../../../internal/emit/fieldlist_test.go), dessen Name in
keinem `# expect:`-Kopf unter `test/mutations/` steht.* Kommando und Stand:

```
comm -23 \
  <(grep -h '^func Test' internal/span/fieldlist_test.go internal/emit/fieldlist_test.go \
      | sed 's/^func \([A-Za-z_0-9]*\)(.*/\1/' | sort) \
  <(sed -n 's/^# expect: //p' test/mutations/*.sh | sort -u)
```

→ **8**, von `grep -c '^func Test' internal/span/fieldlist_test.go internal/emit/fieldlist_test.go`
→ **6** und **9**, zusammen **15**. Beide Zahlen wandern mit ihrem Bestand und sind **kein**
Erwartungswert
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). Die acht, aufgezählt, weil eine Zahl allein keine Arbeitsliste ist:

| Wächter | was er hält | woran der Fall hängt |
|---|---|---|
| `TestFeldliste_LiegtVerbatimImZiel` | die Datei im Ziel **ist** der Ausdruck des Trägers, Byte für Byte | ein Zeichen wandert vor das Dokument |
| `TestFeldliste_LiegtMitDemTraeger` | im Gelingens-Zweig entsteht sie | der Gelingens-Zweig legt sie nicht ab |
| `TestFeldliste_LiegtImGeprueftenBereich` | ihr Pfad fällt in **keinen** `scan.ignore`-Eintrag der emittierten Config | derselbe Eingriff wie Fall 171, eine Stufe schmaler — s. DoD (2) |
| `TestFeldliste_OhneMarkdownLink` | sie trägt keinen Markdown-Verweis, der im fremden Repo tot wäre | ein relativer Verweis in den Kopf |
| `TestSchemaFields_PflichtIstDieDrahtform` | die Pflicht-Spalte ist die Draht-Form, gemessen an `encoding/json` | ein `omitempty` fällt oder kommt hinzu |
| `TestFieldList_TabelleTraegtJedesErfassteFeldEinmal` | jedes erfasste Feld steht **einmal** in der Tabelle | ein Feld erscheint zweimal |
| `TestRenderFieldList_FeldOhneEintragBrichtAb` | ein Feld ohne Frage ist ein **Abbruch**, keine stille Lücke | der Abbruch wird zur Auslassung |
| `TestRenderFieldList_EintragOhneFeldBrichtAb` | eine Frage ohne Feld ebenso | dieselbe Richtung, andere Seite |

**Vier davon sind einmal rot gesehen worden, und das ist die andere Hälfte der Regel.** Die
[Verifikation](../../../reviews/2026-08-26-slice-098-verify.md) §1.3 hat mit eigenen Sonden
`TestFeldliste_LiegtVerbatimImZiel`, `TestFeldliste_LiegtMitDemTraeger`,
`TestFeldliste_OhneMarkdownLink` und `TestFeldliste_LiegtImGeprueftenBereich` fallen sehen —
**fremdbelegt**, nicht von diesem Schnitt. Damit ist für sie die **Entstehungs**-Seite von
[`AGENTS.md`](../../../../AGENTS.md) §3.6 belegt und die **Haltbarkeits**-Seite nicht: ein späterer
Umbau, der ihnen die Zähne nimmt, fällt niemandem auf, weil kein Lauf sie wiederholt. Die übrigen
vier sind in keiner Runde rot gesehen worden.

### Die zweite Achse: die Stufe ist keine Gewohnheit, sondern eine Eigenschaft

Der eine Fall, der heute die teuerste Stufe fährt
(`sed -n 's/^# verify: //p' test/mutations/171-feldliste-ausserhalb-des-geprueften-bereichs.sh`
→ `full-smoke`), begründet sie mit *„die schmalste ausreichende Stufe"*. Das trifft die Frage
*„liest das Doku-Gate des Ziels sie wirklich"* — und **nicht** die Frage *„trifft ein
`scan.ignore`-Eintrag den Pfad"*, die derselbe Eingriff eine Stufe tiefer beantwortet: die
Verifikation hat den Go-Wächter unter genau diesem `sed` fallen sehen (§1.3, Sonde p171,
**fremdbelegt**). Zwei Eigenschaften, zwei Stufen — und die Kosten sind nicht nebensächlich:
`grep -l '^# verify: full-smoke' test/mutations/*.sh | wc -l` → **3** Fälle tragen heute den
teuren Modus, und die Gesamtdauer des Treibers ist der Gegenstand von
[slice-105](slice-105-mutate-messen-dann-teilen.md). Die zwei Slices sind voneinander unabhängig:
keiner wartet auf den anderen.

### Die Abgrenzung: was hier **nicht** entschieden wird

- **Der Durchgang über die Wächter der Träger-Ablage.** Assertions in
  [`internal/emit/enforce_test.go`](../../../../internal/emit/enforce_test.go) über
  [`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 1
  und 5 gehören [slice-103](slice-103-traeger-waechter-decken-was-sie-sagen.md). Verschieden ist
  der **Vertrag**: dort die Ablage des Trägers, hier das Dokument aus Festlegung 7. Gemeinsam ist
  ihnen allein das Verzeichnis `test/mutations/`, in dem beide **eigene** Dateien anlegen — die
  Nummern werden beim Anlegen neu ausgezählt (`ls -1 test/mutations/*.sh | wc -l` → **165**,
  mitwandernd), nicht aus einem Plan übernommen.
- **Die Kopf-Granularität der Fälle.** Ob ein `# expect:` die **Zusicherung** statt des
  **Wächter-Namens** trägt, ist [slice-069](slice-069-zahn-bindet-zusicherung.md) DoD (1). Dieser
  Slice legt Fälle in der heute geltenden Form an und migriert nichts.
- **Die Laufzeit des Treibers.** Sie gehört
  [slice-105](slice-105-mutate-messen-dann-teilen.md); hier wird die **Stufe je Fall** begründet,
  nicht die Aufteilung des Laufs.

## 2. Definition of Done

Zwei slice-eigene Punkte, jeder mit dem Kommando, das ihn **rot** färbt (Modul 5 §Ziel-Form: ≤ 3;
[`AGENTS.md`](../../../../AGENTS.md) §3.6).

- [ ] **(1) Jeder der acht Wächter aus §1 trägt einen `test/mutations/`-Fall — oder eine an der
      Assertion ausgesprochene Grenze mit Grund.** Nach dem Lauf liefert das Kommando aus §1
      genau die Namen, für die eine Grenze ausgesprochen ist, und keinen weiteren. **Eine
      ausgesprochene Grenze ist ein vollwertiger Ausgang; ein Fall, der irgendetwas rot färbt,
      ist es nicht** — wo ein Eingriff mehrere Wächter zugleich reißt, bindet er keinen, und das
      gehört an die Assertion geschrieben statt in einen Fall gepresst.
      **Rot:** `make mutate` — jeder neue Fall erscheint als `ok` mit seinem erwarteten Wächter
      rot; nimmt man die Assertion heraus, die er binden soll, meldet derselbe Lauf einen Befund.
- [ ] **(2) Die Stufe je Fall ist an der Eigenschaft begründet, nicht an der Nachbarschaft.**
      `TestFeldliste_LiegtImGeprueftenBereich` bekommt seinen Fall auf der **`test-go`**-Stufe;
      der bestehende `full-smoke`-Fall bleibt daneben stehen, weil er eine **andere** Eigenschaft
      misst (*„liest das Doku-Gate des Ziels sie wirklich"* gegen *„trifft ein `scan.ignore`-Eintrag
      den Pfad"*). Wer für einen der acht die teure Stufe wählt, schreibt in den Fall-Kopf, welche
      Eigenschaft die schmalere **nicht** trifft.
      **Rot:** `make mutate` mit dem neuen `test-go`-Fall; heute liefert
      `grep -l '^# verify: full-smoke' test/mutations/*.sh | wc -l` → **3**, und
      `sed -n 's/^# verify: //p' test/mutations/171-feldliste-ausserhalb-des-geprueften-bereichs.sh`
      → `full-smoke` ist der einzige Zugang zu diesem Wächter.

Standard-Punkte der Vorlage (nicht slice-eigen): `make gates` grün · Doku-Update, falls ein
öffentlicher Vertrag berührt ist · Closure-Notiz mit Steering-Loop-Lerneintrag. **Der Doku-Punkt
ist hier voraussichtlich leer:** berührt sind Fall-Dateien und höchstens Kommentare an
Assertions — kein emittiertes Artefakt und keine Schnittstelle.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `test/mutations/` — bis zu acht Fälle, einer je Wächter aus §1 <!-- d-check:ignore (geplante Dateien) --> | neu | DoD (1): [`AGENTS.md`](../../../../AGENTS.md) §3.6 — wer keinen Fall hat, gilt als unbewacht |
| [`internal/span/fieldlist_test.go`](../../../../internal/span/fieldlist_test.go) | update, **nur wo eine Grenze ausgesprochen wird** | DoD (1): die Grenze steht an der Assertion, nicht in einer Aufzählung daneben ([`AGENTS.md`](../../../../AGENTS.md) §3.7 — der Kommentar schreibt an den, der die Stelle ändert) |
| [`internal/emit/fieldlist_test.go`](../../../../internal/emit/fieldlist_test.go) | update, derselbe Vorbehalt | dieselbe Begründung; hier liegen sechs der acht |
| [`internal/span/fieldlist.go`](../../../../internal/span/fieldlist.go), [`internal/emit/fieldlist.go`](../../../../internal/emit/fieldlist.go), [`internal/emit/enforce.go`](../../../../internal/emit/enforce.go) | **unverändert** | der Vertrag stimmt; gemessen wird seine Bewachung, nicht sein Verhalten. Ändert der Lauf hier etwas, ist die Rückführung aus §4 fällig |
| [`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh) — **nur die Ausgabe der zwei Feldlisten-Zähne**, kein Zahn wird verschoben | update | Die Zähne bleiben, wo sie sind: DoD (2) fügt eine **schmalere** Stufe hinzu und nimmt keine weg. Was sich ändert, ist das, was sie **sagen**, und beide Male ist die Grenze gemessen. **(a) `feldliste_im_ziel`:** die Bedingung `[ ! -f "$doc" ]` hat zwei Ursachen — der Pfad zieht aus dem geprüften Bereich (Fall `171`), oder das Dokument entsteht gar nicht —, die Meldung begründet den Treffer nur mit der ersten. **(b) der Idempotenz-Zahn:** er liest vom zweiten Init-Lauf **nur** den Exit-Code, und der ist im Fehlerzweig **0**; seine Meldung nennt dann *„konvergent verletzt"*, obwohl das Ausbleiben des Neuschreibens dort **richtig** ist. Der Unterscheider ist gemessen — `grep -c 'Erfassungsschicht nicht abgelegt'` über der Ausgabe des zweiten Laufs → **0** (grüner Lauf) · **0** (mutiert) · **1** (Grenzfall) —, die Go-Schwester hat die Abtrennung bereits (`notice.Len() != 0` → eigene Meldung). **Dazu (c):** derselbe Block misst *„die Marke ist weg"* statt *„der kanonische Stand"*; eine Kopie vor der Drift plus ein `cmp` danach macht daraus dieselbe Aussage, die das OK-Echo dem Leser ohnehin anbietet. Der Text eines Wächters ist Teil des Wächters. **Kein eigener DoD-Punkt und kein Rot:** ob eine Begründung auf ihren Treffer zutrifft, ist ein Urteil über Prosa — dieselbe Absage, die [slice-101](slice-101-norm-postens-bekommen-einen-termin.md) §1 ihrem Weg (C) erteilt. Mechanisch bleibt der **Zeitpunkt**: DoD (1) verlangt, jeden neuen Fall rot zu sehen, und genau dann ist die Meldung lesbar |
| `docs/plan/planning/done/` | **unverändert** | Zeitdokumente ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) §Geltungsbereich) |
| [`docs/plan/planning/in-progress/roadmap.md`](../in-progress/roadmap.md) | **unverändert** | wellenlose Arbeit wird dort nicht geführt ([`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird) Setzung 2/3) |

**Die Ist-Messung gehört vor die Fälle, nicht hinter sie.** Für jeden der acht ist **vor** dem
Schreiben zu messen, welche Wächter der Eingriff **sonst noch** reißt: zwei der Sonden der
[Verifikation](../../../reviews/2026-08-26-slice-098-verify.md) §1.3 färbten **14** Tests zugleich,
weil die Erzeugung abbricht und `emit.Enforce` insgesamt scheitert (**fremdbelegt**). Ein Fall,
dessen Eingriff die halbe Emission reißt, ist kein Zahn für **einen** Wächter — er ist der Anlass,
statt seiner eine Grenze auszusprechen.

## 4. Trigger

**Beginn (`open` → `next` → `in-progress`): nichts blockiert ihn außer dem WIP-Limit — und das ist
der Termin, den dieser Slice trägt.** Die acht Wächter liegen im Baum, die Messung in §1 gilt über
ihm, und keine Entscheidung und keine Anforderung ist zu klären. Er wartet insbesondere **nicht**
auf die Closure von [welle-12](../welle-12-erfassungsschicht-emittieren.md) und nicht auf
[slice-099](../in-progress/slice-099-leser-und-aufraeum-kommando.md).

**Was dieser Slice ausdrücklich nicht ist: eine Nennung.** Acht unbewachte Wächter sind in einer
Verifikation gemessen und benannt worden; ein Träger ohne Termin ist in diesem Repo dreimal
vergeben und nullmal eingelöst worden
([slice-101](slice-101-norm-postens-bekommen-einen-termin.md) §1, dort mit Kommando). Der Termin
ist dieser Schnitt.

Die zwei Rückführungen, vorab benannt:

- **`in-progress` → `next` (zu groß):** wenn mehr als zwei der acht nur über einen Umbau der
  Wächter erreichbar sind. Dann trägt der Slice Produktionsnähe statt Fällen, und der Umbau ist ein
  eigener Schnitt mit eigener Begründung — dieselbe Schwelle, die
  [slice-103](slice-103-traeger-waechter-decken-was-sie-sagen.md) für seinen zweiten Punkt zieht.
- **`in-progress` → `open` (blockiert):** wenn sich beim Bauen zeigt, dass eine Assertion selbst
  falsch geschnitten ist — etwa weil sie zwei Eigenschaften in einem Vergleich hält. Dann ist erst
  der Wächter zu entscheiden und dann sein Fall; ein Fall über einer unklaren Zusicherung bindet
  nichts.

## 5. Closure-Trigger

DoD (1) und (2) erfüllt mit gefahrenen Kommandos; das Kommando aus §1 liefert nur noch die Namen
mit ausgesprochener Grenze; `make gates` grün; `make mutate` grün einschließlich jedes neuen Falls;
Review konform (Modul 10); Verifikation bestätigt (Modul 11); `git mv` nach `done/` als eigener
Move-Commit; Closure-Notiz mit Steering-Loop-Eintrag in einer der drei Formen (geschärfte Regel ·
neuer Sensor · benannte Spec-Lücke).

**Ausdrücklich nicht Teil des Closure-Triggers: dass alle acht einen Fall bekommen.** Ein
Durchgang, dessen Erfolgskriterium der Fall ist, baut auch dort einen, wo der Eingriff aus zwei
Gründen rot wird — und ein Fall, der aus zwei Gründen rot wird, bindet keinen davon.

## 6. Risiken und offene Punkte

- **Acht Fälle sind acht Läufe mehr in einem Treiber, der ohnehin die teuerste Stufe des Repos
  fährt.** Die Gesamtdauer ist gemessen und **fremdbelegt**: **1199 s** über **164** Fälle
  ([Verifikation](../../../reviews/2026-08-26-slice-098-verify.md) §1.1, Lauf L3). Dass das teuer
  ist, ist **kein** Grund für eine schmalere Stufe — es ist der Gegenstand von
  [slice-105](slice-105-mutate-messen-dann-teilen.md). Umgekehrt gilt DoD (2): eine teure Stufe
  ohne Eigenschaft, die sie verlangt, ist bezahlte Gewohnheit.
- **Ein Fall kann die Zusage verschieben, statt sie zu binden.** Wer für
  `TestFeldliste_LiegtVerbatimImZiel` den Ausdruck **und** die Datei zugleich mutiert, hält beide
  Seiten aus derselben Funktion gegeneinander und bleibt grün — die Bauart, die
  [slice-096](../done/slice-096-traeger-liegt-im-ziel.md) §7 schon einmal gemessen hat. Der
  Prüfpunkt: **an welchen zwei verschiedenen Artefakten** der Eingriff angreift.
- **Eine ausgesprochene Grenze kann zur Ausrede werden.** Sie ist der richtige Ausgang, wo ein
  Eingriff nichts bindet — und der falsche, wo er nur unbequem ist. Der Unterschied steht in der
  Ist-Messung aus §3 und gehört ins Review, nicht in die Selbsteinschätzung des Laufs.
- **`make gates` sieht den Gegenstand nicht.** `make mutate` steht nicht in `make gates`
  ([`AGENTS.md`](../../../../AGENTS.md) §4); wer nach diesem Slice nur `make gates` fährt, sieht
  keinen der neuen Zähne. Das ist eine Eigenschaft der Stufe, keine Lücke des Schnitts.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `internal/span/`,
`internal/emit/` und `test/` gehören zum Greenfield-Bestand; der Modus steht in der
Modus-Deklaration von [`harness/conventions.md`](../../../../harness/conventions.md).
