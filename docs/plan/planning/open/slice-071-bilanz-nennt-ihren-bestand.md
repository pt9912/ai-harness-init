# Slice slice-071: Die Bilanz sagt, worüber sie gerechnet hat — fehlender Ablageort und leerer Bestand sind zweierlei

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (reaktiv — zwei Posten aus einer Closure-Notiz) — gegen
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1 geprüft, alle drei Fragen samt Antwort in §3.

**Bezug:**
[`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) (**Accepted** — Festlegung 1 Punkt 4
verlangt für das, was die Ableitung nicht hergibt, *leer und als leer erkennbar*, nicht geraten;
daran hängt DoD (1)),
[`ADR-0012`](../../adr/0012-haupt-kontext-ohne-token-bilanz.md) (**Accepted** — Festlegung 2 setzt
die Pflicht, dass die Ausgabe nennt, worüber sie rechnet, und ihre Fitness Function trennt die
Größen der Ausgabe voneinander: *„Drei Größen, drei Angaben — wer zwei davon zusammenlegt,
verliert eine"*; daran hängt DoD (2)),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (eine
wohlgeformte Ausgabe über einem Ort, den es nicht gibt, behauptet eine Rechnung, die nicht lief —
dieselbe Klasse eine Ebene neben dem Gate),
[`ADR-0003`](../../adr/0003-go-native-binaries.md) (**Accepted** — der Auswerter ist ein
Go-Binary und wird Docker-only gebaut).

**Bewusst KEINE `LH-FA`-Kennung.** Geprüft: die funktionalen Anforderungen betreffen das
**emittierte** Zielprojekt; hier ändert sich die Ausgabe eines Dogfood-Berichts, der nichts
emittiert (§3). Eine von ihnen zu führen füllte die `requirement`-Achse falsch — leer und
erkennbar schlägt gefüllt und falsch. **Dieser Absatz steht unterhalb der Leerzeile:** der
Bezugs-Block wird bis zur ersten Leerzeile mechanisch gelesen, und eine Ausschluss-Notiz darin
trüge ein, was sie ausschließt.

**Autor:** Planner. **Datum:** 2026-08-25.

---

## 1. Ziel

**`make span-report` gibt über einem Ablageort, den es nicht gibt, dieselbe wohlgeformte leere
Bilanz aus wie über einem leeren — und seine Bestandszeile nennt eine Zahl, ohne zu sagen, worüber
sie spricht.** Dieser Slice macht beide Aussagen eindeutig: die Ausgabe trennt *nichts gefunden*
von *nichts zu finden*, und die Bestandszeile benennt die Menge, die sie zählt.

**Gemessen, je mit dem Kommando neben der Aussage:**

- [`internal/report/report.go`](../../../../internal/report/report.go) liest den Bestand mit
  `filepath.Glob` (`grep -c 'filepath.Glob' internal/report/report.go` → **1**). Über einem
  fehlenden Verzeichnis meldet der Aufruf weder Treffer noch Fehler: `Aggregiere` kehrt mit einer
  leeren Bilanz zurück, `Schreibe` formt sie zu *„Keine Rolle traegt Token."*, und
  `cmd/span-report/main.go` endet über den Erfolgs-Zweig.
  Der Ablageort ist ein **Argument** (`grep -c 'dir = args\[0\]' cmd/span-report/main.go` → **1**),
  also ein Wert, den ein Aufrufer vertippen kann; das vorangestellte `mkdir -p` des `make`-Ziels
  (`grep -c 'mkdir -p .harness/state/spans' Makefile` → **1**) deckt allein den einen Pfad, den es
  selbst mountet, und maskiert den Fall dort.
- Dieselbe Ausgabe schreibt `Bestand: %d Sitzung(en), %s bis %s`
  (`grep -c 'Bestand: %d Sitzung' internal/report/report.go` → **1**). Gezählt werden die
  **Sitzungs-Ströme des Ablageorts** — eine Menge über den Span-Feldern, nicht über der Summe. Wie
  sich die Summe über diese Ströme verteilt, sagt die Zeile nicht, und beide Größen fallen
  auseinander, sobald ein Strom keine Zähler trägt oder einer die Summe dominiert.

**Beide Angaben sind dieselbe Frage an dieselbe Ausgabe: worüber wurde gerechnet?** Der **Nenner**
steht in der ersten Zeile und beantwortet sie für die Grundmenge — gerechnet wird über
Subagenten-Läufe, nicht über den Lauf.
[`ADR-0012`](../../adr/0012-haupt-kontext-ohne-token-bilanz.md) hat für die drei Größen daneben
festgehalten, dass jede ihre eigene Angabe braucht. Die Bestandszeile ist keine der drei; sie
steht unter derselben Linie und trägt sie heute nicht, und die leere Ausgabe trägt sie überhaupt
nicht.

**Was dieser Slice nicht ist: eine Rechnung über die Cache-Zähler.** Der Emitter erfasst beide
(`grep -c 'cache_.*_input_tokens' internal/span/response.go` → **4**), und eine Auswertung über
sie hat dauerhaft keinen Eingang — entschieden in
[`ADR-0021`](../../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md), ohne Auflösungs-Trigger.
Was daraus für die **Erfassung** folgt, steht dort als Festlegung 2 und ist bewacht
(`test/mutations/151-span-positivliste-eintrag-entfernt.sh`); eine **Rechnung** darüber hat keinen
Gegenstand und bekommt hier keinen.

## 2. Definition of Done

Zwei slice-eigene Punkte, jeder mit dem Kommando, das ihn **rot** färbt (Modul 5 §Ziel-Form: ≤ 3;
[`AGENTS.md`](../../../../AGENTS.md) §3.6).

- [ ] **(1) Ein nicht existierender Ablageort ist an der Ausgabe von einem leeren zu
      unterscheiden.** Welche der beiden Lagen vorliegt, steht im **Text**, den `span-report`
      schreibt. **Nicht im Exit-Code, und das ist eine Setzung:** welche Zahl welche Bedeutung
      trägt, ist der Gegenstand von
      [slice-079](slice-079-exit-code-vertrag.md); eine zweite Festlegung daneben driftete von ihr
      weg, noch bevor die erste steht.
      **Rot:** ein Go-Test über [`internal/report`](../../../../internal/report/report.go) und
      `cmd/span-report/main.go` mit einem Pfad, den es nicht gibt —
      er fällt, sobald die Ausgabe wieder die eines leeren Bestands ist; dazu ein
      `test/mutations/`-Fall, der die Unterscheidung entfernt und dieses Rot erwartet.
- [ ] **(2) Die Bestandszeile nennt die Menge, die sie zählt.** `Bestand: <n> Sitzung(en)` sagt,
      dass die Zahl die **Sitzungs-Ströme des Ablageorts** zählt — die Angabe steht neben der Zahl,
      nicht in einer Fußnote und nicht im Kopf-Kommentar der Funktion.
      **Was nicht dazukommt, ist eine zweite Zahl:** die Streuung der Summe über diese Ströme ist
      eine eigene Größe mit eigenem Zahn; sie hier mitzudrucken legte zwei Größen in eine Angabe
      zusammen (§6).
      **Rot:** ein Go-Test auf die erzeugte Zeile, der fällt, sobald die Bezugsmenge aus ihr
      verschwindet; dazu ein `test/mutations/`-Fall, der sie entfernt.
- [ ] `make gates` grün, `make mutate` ohne Befund.
- [ ] Doku-Update, falls ein öffentlicher Vertrag berührt ist.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

**Ohne Welle — der Schnitt-Test aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1, alle drei Fragen beantwortet.** (1) *Bündel?* Nein — ein Liefergegenstand, eine
Ausgabe; kein zweiter Slice muss mitlanden, damit die Aussage stimmt. (2) *Gemeinsames
Closure-Kriterium?* Nein — was hier wahr wird, wird mit der Definition of Done wahr; ein
Wellen-Trigger schriebe sie ab. (3) *Auslöser reaktiv oder gewollt?* **Reaktiv:** beide Angaben
sind beim Bau des Auswerters aufgefallen und stehen in dessen Closure-Notiz unter *Offen, mit
Träger* ([slice-066](../done/slice-066-telemetrie-auswertung.md) §7). Nach Setzung 2 bekommt
dieser Slice deshalb **keinen** Roadmap-Eintrag; sein Zustand ist das Verzeichnis.

**Kein Eintrag im Technik-Stratum, und das ist eine Aussage, kein Auslassen.** Die
**Nenner**-Pflicht steht dort bereits
([`spec/spezifikation.md`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5
Abweichung 6, begründet von
[`ADR-0012`](../../adr/0012-haupt-kontext-ohne-token-bilanz.md) Festlegung 2) — eine zweite
Fassung daneben wäre der zweite Ort, der driftet. Die zwei Angaben aus §2 sind **Eigenschaften
einer Ausgabe**, und für die führt dieses Repo einen anderen Träger: den Go-Test und den
Kopf-Kommentar der schreibenden Funktion, der seinen Wächter namentlich nennt
(`make comment-claims`). Ein Spec-Satz ohne Zahn stünde daneben und sagte dasselbe schwächer.

**Wo die Unterscheidung aus DoD (1) entsteht, entscheidet der Implementer — die Grenze steht
hier.** `Aggregiere` bekommt den Ablageort als Pfad und ist die Stelle, die ihn zuerst berührt;
`Schreibe` formt, was daraus wird. Welche der beiden die Lage feststellt und welche sie
ausspricht, ist eine Frage des Zuschnitts der Funktionen, keine des Slice. **Was der Slice setzt:
der Exit-Code bleibt unberührt** (§2), und `make span-report` bleibt **kein Gate** — es steht
nicht in der Zielliste von `gates` (`grep -m1 '^gates:' Makefile | grep -c 'span-report'` → **0**),
und ein Bericht, der nichts prüft, wird durch eine ehrlichere Ausgabe kein Wächter
([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`internal/report/report.go`](../../../../internal/report/report.go) | update | die zwei Angaben aus §2: der fehlende Ablageort wird vom leeren getrennt, und die Bestandszeile nennt ihre Bezugsmenge |
| `cmd/span-report/main.go` | update | der Ablageort kommt hier als Argument herein; ob die Unterscheidung dort oder im Paket ausgesprochen wird, entscheidet der Zuschnitt (oben) |
| `internal/report/report_test.go`, `cmd/span-report/main_test.go` | update | die zwei Zähne aus §2, je einer je Angabe |
| `test/mutations/` | neu | zwei Fälle, je einer je Angabe — ohne sie wären beide Punkte eine Absicht ([`AGENTS.md`](../../../../AGENTS.md) §3.6) |
| [`Makefile`](../../../../Makefile) | **unverändert** | das `mkdir -p` bleibt: es legt den Pfad an, den das Ziel gleich darauf als Volume mountet. Es zu entfernen bräche den Mount, statt den Fall sichtbar zu machen — der Fall entsteht am **Argument**, nicht an diesem einen Pfad (§1) |
| [`spec/spezifikation.md`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) | **unverändert** | Begründung oben |

## 4. Trigger

**`open` → `next`:** priorisiert. **Eine fachliche Vorbedingung gibt es nicht** — beide Angaben
hängen an Code, der läuft, und an keinem Span-Bestand: die vorhandenen Tests legen ihre Fixtures
selbst an (`grep -c 'func schreibeBestand' internal/report/report_test.go` → **1**). Damit wartet
dieser Slice auf keinen anderen (Modul 5 §Ziel-Form).

**`next` → `in-progress`:** WIP-Limit — kein anderer Slice in `in-progress/`.

Rückführungen:

- `in-progress` → `next`: falls die zwei Angaben zusammen nicht in **einer** Review-Sitzung
  prüfbar sind. Sie berühren dieselbe Ausgabe und denselben Aufrufweg; fällt das auseinander,
  werden sie einzeln geschnitten — jede trägt ihren Zahn schon getrennt.
- `in-progress` → `open`: falls [slice-079](slice-079-exit-code-vertrag.md) den Exit-Code-Vertrag
  vorher setzt **und** darin die Lage *„Ablageort fehlt"* einem Code zuweist. Dann ist DoD (1) an
  zwei Orten festgelegt, und zuerst ist zu entscheiden, welcher der bindende ist; dieser Slice
  trägt bis dahin nur noch (2).

## 5. Closure-Trigger

DoD vollständig; Review konform (Modul 10) mit **ausgestelltem** Verdikt; Verifikation bestätigt
(Modul 11); `make gates` und `make mutate` grün; `git mv` nach `done/` (eigener Move-Commit,
eingehende Links im Zug danach); Closure-Notiz mit Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **Der Zahn aus DoD (1) bindet die Ausgabe über einem konstruierten Pfad, nicht den realen
  Fehlgriff.** Der Span-Bestand ist gitignoriert und maschinenlokal; was ein vertippter Mount auf
  einer fremden Maschine erzeugt, sieht kein Test dieses Repos. Gebunden ist die **Eigenschaft**
  der Ausgabe, nicht die Häufigkeit des Falls — und das ist die Grenze, nicht der Zweck.
- **Die Streuung der Summe bleibt ungemessen, benannt statt geschlossen.** DoD (2) macht die
  Bestandszeile eindeutig; sie beantwortet nicht, ob ein einzelner Strom die Summe dominiert. Wer
  diese Zahl will, schneidet sie als **eigene** Größe mit eigenem Zahn — die Linie dafür zieht
  [`ADR-0012`](../../adr/0012-haupt-kontext-ohne-token-bilanz.md) in ihrer Fitness Function: zwei
  Größen in eine Angabe zu legen verliert eine.
- **Nicht in diesem Slice:** die **Cache-Rechnung** — sie hat nach
  [`ADR-0021`](../../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md) dauerhaft keinen Eingang
  und keinen Auflösungs-Trigger (§1); der **verlorene Lauf ohne Span**, den die Abdeckungszahl
  nicht sehen kann ([slice-077](slice-077-verlorener-lauf-sichtbar.md)); die Bedeutung der
  **Exit-Codes** ([slice-079](slice-079-exit-code-vertrag.md)); jede Emission ins Ziel und jede
  Ausweitung des Span-Schemas.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `internal/`, `cmd/` und
`test/` gehören zum Greenfield-Bestand; der Modus steht in der
Modus-Deklaration von [`harness/conventions.md`](../../../../harness/conventions.md).
