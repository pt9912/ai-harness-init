# Slice slice-071: Die Bilanz sagt, worüber sie gerechnet hat — fehlender Ablageort und leerer Bestand sind zweierlei

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (reaktiv — vier Posten aus zwei Läufen: einer Closure-Notiz und einer
Verifikation) — gegen
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1 geprüft, alle drei Fragen samt Antwort in §3.

**Bezug:**
[`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) (**Accepted** — Festlegung 1 Punkt 4
verlangt für das, was die Ableitung nicht hergibt, *leer und als leer erkennbar*, nicht geraten;
daran hängt DoD (1)),
[`ADR-0012`](../../adr/0012-haupt-kontext-ohne-token-bilanz.md) (**Accepted** — Festlegung 2 setzt
die Pflicht, dass die Ausgabe nennt, worüber sie rechnet, und ihre Fitness Function trennt die
Größen der Ausgabe voneinander: *„Drei Größen, drei Angaben — wer zwei davon zusammenlegt,
verliert eine"*; daran hängt DoD (3)),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (eine
wohlgeformte Ausgabe über einem Ort, den es nicht gibt, behauptet eine Rechnung, die nicht lief —
dieselbe Klasse eine Ebene neben dem Gate),
[`ADR-0003`](../../adr/0003-go-native-binaries.md) (**Accepted** — der Auswerter ist ein
Go-Binary und wird Docker-only gebaut),
[`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) (§Leser: *„Die
Auswertung nennt ihre **Abdeckung zuerst** und meldet damit ihre eigene Leere"* — dieselbe Ausgabe
läuft seit [slice-099](../done/slice-099-leser-und-aufraeum-kommando.md) im Ziel).

**Die `LH-FA`-Kennung stand hier zuerst als ausdrücklicher Ausschluss, und der ist widerlegt.** Der
Grund war, die Ausgabe sei die eines Dogfood-Berichts, der nichts emittiert. Das gilt nicht mehr:
das gebootstrappte Ziel ruft **dasselbe** Programm über sein eigenes `make`-Fragment
(`grep -n 'exec .*span-report' internal/emit/templates/enforce/erfassung.mk` → **eine** Zeile,
mitwandernd), und der Pfad dorthin führt durch `cmd/ai-harness-init/span_report.go` in
[`internal/report`](../../../../internal/report). Jede Änderung an dieser Ausgabe ändert also die
Ausgabe eines Adopters — die `requirement`-Achse ist damit **besetzt**, nicht leer. **Was
unverändert gilt:** eine Kennung, die nicht trägt, füllt die Achse falsch, und leer schlägt
gefüllt und falsch. Geändert hat sich der Bestand, nicht die Regel.

**Verantwortlich:** Implementer (pt9912).

**Autor:** Planner. **Datum:** 2026-08-25.

---

## 1. Ziel

**`make span-report` gibt über einem Ablageort, den es nicht gibt, dieselbe wohlgeformte leere
Bilanz aus wie über einem leeren — und seine Bestandszeile nennt eine Zahl, ohne zu sagen, worüber
sie spricht.** Dieser Slice macht die Aussagen dieser Ausgabe eindeutig: sie trennt *nichts
gefunden* von *nichts zu finden*, sie begründet jede ihrer Leeren mit einer Ursache, die auf den
gemeldeten Zustand zutrifft, und ihre Bestandszeile benennt die Menge, die sie zählt.

**Gemessen, je mit dem Kommando neben der Aussage:**

- [`internal/report/report.go`](../../../../internal/report/report.go) liest den Bestand mit
  `filepath.Glob` (`grep -c 'filepath.Glob' internal/report/report.go` → **1**). Über einem
  fehlenden Verzeichnis meldet der Aufruf weder Treffer noch Fehler: `Aggregiere` kehrt mit einer
  leeren Bilanz zurück, `Schreibe` formt sie zu *„Keine Rolle traegt Token."*, und
  `cmd/ai-harness-init/span_report.go` endet über den Erfolgs-Zweig.
  Der Ablageort ist ein **Argument** (`grep -c 'return args\[0\], nil' cmd/ai-harness-init/span_report.go` → **1**),
  also ein Wert, den ein Aufrufer vertippen kann; das vorangestellte `mkdir -p` des `make`-Ziels
  (`grep -c 'mkdir -p .harness/state/spans' Makefile` → **1**) deckt allein den einen Pfad, den es
  selbst mountet, und maskiert den Fall dort.
- Dieselbe Ausgabe schreibt `Bestand: %d Sitzung(en), %s bis %s`
  (`grep -c 'Bestand: %d Sitzung' internal/report/report.go` → **1**). Gezählt werden die
  verschiedenen `session`-Werte der **lesbaren** Zeilen — eine Menge über den Span-Feldern, nicht
  über der Summe. Wie sich die Summe über diese Ströme verteilt, sagt die Zeile nicht, und beide
  Größen fallen auseinander, sobald ein Strom keine Zähler trägt oder einer die Summe dominiert.

**Beide Angaben sind dieselbe Frage an dieselbe Ausgabe: worüber wurde gerechnet?** Der **Nenner**
steht in der ersten Zeile und beantwortet sie für die Grundmenge — gerechnet wird über
Subagenten-Läufe, nicht über den Lauf.
[`ADR-0012`](../../adr/0012-haupt-kontext-ohne-token-bilanz.md) hat für die drei Größen daneben
festgehalten, dass jede ihre eigene Angabe braucht. Die Bestandszeile ist keine der drei; sie
steht unter derselben Linie und trägt sie heute nicht, und die leere Ausgabe trägt sie überhaupt
nicht.

### Zwei Lagen kamen dazu, und sie liegen in derselben Ausgabe

Die Verifikation von [slice-099](../done/slice-099-leser-und-aufraeum-kommando.md) hat an einem
selbst gebootstrappten Ziel zwei weitere Stellen gemessen, an denen dieselbe Ausgabe über ihren
eigenen Fall etwas sagt, das für ihn nicht gilt. Beide gehören hierher, weil sie dieselbe Datei,
dieselbe Frage und dieselbe Lagen-Trennung betreffen.

- **Die Meldung des leeren Bestands begründet ihn mit dem fehlenden Träger.** Sie sagt, das
  Programm könne fehlen — *„ein frischer Klon hat es nicht"*, *„ein Aufraeum-Lauf nimmt es weg"* —,
  und beides kann in dem Zustand, in dem diese Zeilen erscheinen, nicht zutreffen: fehlte das
  Programm, hätte das `make`-Fragment eine Ebene höher die Träger-Meldung gedruckt und den Leser
  nie gestartet; und `span-clean` nimmt den **Bestand**, nicht das Programm — das Fragment sagt es
  zwei Zeilen weiter selbst (`grep -n 'Traeger daneben bleibt liegen'
  internal/emit/templates/enforce/erfassung.mk`). Ein Adopter, der gerade selbst aufgeräumt hat,
  sucht danach ein Programm, das da ist.
- **Über einem Bestand mit Zeilen, aber ohne einen einzigen Agent-Lauf gibt die Ausgabe der
  Mechanik die Schuld.** `Zeilen > 0 ∧ AgentLaeufe == 0` ist eine eigene Lage: es ist kein Subagent
  gelaufen, die Mechanik kam nicht zum Zuge. Die Ausgabe fasst sie mit der Lage *„Bestand ohne
  Zähler"* zusammen und begründet beide mit demselben Satz. Die **Zahl** ist dabei ehrlich — der
  Nenner steht daneben —, der **kausale Anschluss** ist es nicht.

**Beide sind dieselbe Klasse wie DoD (1), eine Lage weiter:** zwei Zustände, eine Meldung. Der
Unterschied ist, dass sie nicht schweigt, sondern eine Ursache nennt — und eine genannte Ursache
ist eine Zusage, die geprüft werden kann.

**Was dieser Slice nicht ist: eine Rechnung über die Cache-Zähler.** Der Emitter erfasst beide
(`grep -c 'cache_.*_input_tokens' internal/span/response.go` → **4**), und eine Auswertung über
sie hat dauerhaft keinen Eingang — entschieden in
[`ADR-0021`](../../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md), ohne Auflösungs-Trigger.
Was daraus für die **Erfassung** folgt, steht dort als Festlegung 2 und ist bewacht
(`test/mutations/151-span-positivliste-eintrag-entfernt.sh`); eine **Rechnung** darüber hat keinen
Gegenstand und bekommt hier keinen.

## 2. Definition of Done

Drei slice-eigene Punkte, jeder mit dem Kommando, das ihn **rot** färbt (Modul 5 §Ziel-Form: ≤ 3;
[`AGENTS.md`](../../../../AGENTS.md) §3.6).

- [x] **(1) Jede Leere-Lage der Ausgabe ist von den anderen unterscheidbar, und jede Begründung
      trifft ihren eigenen Fall.** Die Lagen sind: **Ablageort existiert nicht** · **Ablageort
      existiert und ist leer** · **Bestand ohne Verbrauchs-Zähler**. Welche vorliegt, steht im
      **Text**, den `span-report` schreibt; und wo der Text eine **Ursache** nennt, ist es eine, die
      in genau diesem Zustand vorliegen kann — die zwei Träger-Ursachen gehören in die
      Träger-Meldung eine Ebene höher, nicht in die des leeren Bestands.
      **Nicht im Exit-Code, und das ist eine Setzung:** welche Zahl welche Bedeutung
      trägt, ist der Gegenstand von
      [slice-079](../open/slice-079-exit-code-vertrag.md); eine zweite Festlegung daneben driftete von ihr
      weg, noch bevor die erste steht.
      **Rot:** ein Go-Test über [`internal/report`](../../../../internal/report/report.go) und
      `cmd/ai-harness-init/span_report.go` mit einem Pfad, den es nicht gibt —
      er fällt, sobald die Ausgabe wieder die eines leeren Bestands ist; dazu je ein
      `test/mutations/`-Fall, der die Unterscheidung entfernt und der die Träger-Ursachen in die
      Bestands-Meldung zurückschreibt, beide mit diesem Rot.
- [x] **(2) `Zeilen > 0` ohne einen einzigen Agent-Lauf ist eine eigene Lage.** Ein Bestand, in dem
      nichts von einem Subagenten stammt, bekommt eine Meldung, die das sagt — statt der Mechanik
      des Agenten-Werkzeugs die Schuld an einer Leere zu geben, die sie nicht verursacht hat. Der
      Grund-Satz zur Mechanik bleibt, wo er trägt: über einem Bestand **mit** Agent-Läufen und ohne
      Zähler — **und er behält einen Ort, an dem er gemessen wird.** `harness/tools/full-smoke.sh`
      prüft ihn in Schritt (b) über einem Bestand, den derselbe Lauf aus einer einzigen
      `"tool_name":"Bash"`-Zeile erzeugt — also über genau der Lage, die dieser Punkt abtrennt; und
      `test/mutations/176-leser-grund-satz-weg.sh` führt diesen Lauf als **einzigen** Verify-Pfad
      (`verify: full-smoke`). Beide ziehen mit (§3): ohne das nimmt dieser Punkt einem fremden
      Wächter die Zähne, statt eine Lage zu trennen.
      **Rot:** ein Go-Test über `report.Schreibe` mit einem Bestand aus reinen Werkzeug-Zeilen —
      er fällt, sobald die Ausgabe wieder den Mechanik-Satz trägt; dazu ein `test/mutations/`-Fall,
      der die Lagen zusammenlegt, und `test/mutations/176` fällt weiterhin über seinem eigenen
      Verify-Pfad.
      **Warum das kein vierter Punkt ist:** die Lage sitzt in derselben Verzweigung wie (1) und
      wird mit ihr entschieden; sie steht getrennt, weil ihr Gegenbeispiel ein anderer Bestand ist,
      nicht ein anderer Pfad.
- [x] **(3) Die Bestandszeile nennt die Menge, die sie zählt — und die genannte ist die gezählte.**
      Die Angabe steht neben der Zahl, nicht in einer Fußnote und nicht im Kopf-Kommentar der
      Funktion. **Der Wortlaut ist damit nicht mitentschieden, seine Wahrheitsbedingung schon:**
      gezählt werden die verschiedenen `session`-Werte der Zeilen, die sich parsen lassen
      (`b.Sitzungen = len(sitzungen)`, gefüllt nur bei nicht-leerem `s.Session`; eine nicht
      parsende Zeile erreicht die Stelle nicht, und bei `Sitzungen == 0` wird die Zeile gar nicht
      gedruckt). Eine Angabe wie *„die Sitzungs-Ströme des Ablageorts"* greift darüber hinaus und
      wäre selbst die Klasse, die dieser Slice behebt.
      **Was nicht dazukommt, ist eine zweite Zahl:** die Streuung der Summe über diese Ströme ist
      eine eigene Größe mit eigenem Zahn; sie hier mitzudrucken legte zwei Größen in eine Angabe
      zusammen (§6).
      **Rot:** ein Go-Test auf die erzeugte Zeile, der fällt, sobald die Bezugsmenge aus ihr
      verschwindet **oder** über die gezählte Menge hinausgreift; dazu ein `test/mutations/`-Fall,
      der sie entfernt.
- [ ] `make gates` grün, `make mutate` ohne Befund. **Teilweise:** `make gates` grün (§7); `make
      mutate` lief nur als Teillauf über den fünf neuen Fällen (491–495, `5 ok, 0 Befund(e)`,
      Beleg-Slot `.harness/state/mutate-passed.key` nicht vorhanden) — kein voller Lauf, dieser
      Punkt bleibt bewusst uneingehakt (§7).
- [x] Doku-Update, falls ein öffentlicher Vertrag berührt ist. Keiner berührt — `Makefile` und
      `spec/spezifikation.md` unverändert (Verifikations-Bericht).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

**Ohne Welle — der Schnitt-Test aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1, alle drei Fragen beantwortet.** (1) *Bündel?* Nein — ein Liefergegenstand, eine
Ausgabe; kein zweiter Slice muss mitlanden, damit die Aussage stimmt. (2) *Gemeinsames
Closure-Kriterium?* Nein — was hier wahr wird, wird mit der Definition of Done wahr; ein
Wellen-Trigger schriebe sie ab. (3) *Auslöser reaktiv oder gewollt?* **Reaktiv:** die ersten zwei
Angaben sind beim Bau des Auswerters aufgefallen und stehen in dessen Closure-Notiz unter *Offen,
mit Träger* ([slice-066](../done/slice-066-telemetrie-auswertung.md) §7); die zwei Lagen aus §1 hat
die Verifikation von [slice-099](../done/slice-099-leser-und-aufraeum-kommando.md) an einem
gebootstrappten Ziel gemessen. Nach Setzung 2 bekommt dieser Slice deshalb **keinen**
Roadmap-Eintrag; sein Zustand ist das Verzeichnis.

**Kein Eintrag im Technik-Stratum, und das ist eine Aussage, kein Auslassen.** Die
**Nenner**-Pflicht steht dort bereits
([`spec/spezifikation.md`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5
Abweichung 6, begründet von
[`ADR-0012`](../../adr/0012-haupt-kontext-ohne-token-bilanz.md) Festlegung 2) — eine zweite
Fassung daneben wäre der zweite Ort, der driftet. Die Angaben aus §2 sind **Eigenschaften
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
| [`internal/report/report.go`](../../../../internal/report/report.go) | update | die Angaben aus §2: der fehlende Ablageort wird vom leeren getrennt, und die Bestandszeile nennt ihre Bezugsmenge |
| `cmd/ai-harness-init/span_report.go` | update | der Ablageort kommt hier als Argument herein; ob die Unterscheidung dort oder im Paket ausgesprochen wird, entscheidet der Zuschnitt (oben) |
| `internal/report/report_test.go`, `cmd/ai-harness-init/span_report_test.go` | update | die Zähne aus §2, je einer je Angabe |
| `test/mutations/` | neu | zwei Fälle, je einer je Angabe — ohne sie wären beide Punkte eine Absicht ([`AGENTS.md`](../../../../AGENTS.md) §3.6) |
| [`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh) | update | Schritt (b) misst den Grund-Satz aus DoD (2) über einem Bestand ohne Agent-Lauf, Schritt (d) die Leere-Meldung aus DoD (1) über das `grep`-Literal `Kein Bestand:` — und zwar über dem Zustand nach `span-clean`, also über dem **fehlenden** Ablageort. Beide Prüfungen ziehen mit, sonst misst der Lauf Lagen, die es nicht mehr gibt |
| `test/mutations/176-leser-grund-satz-weg.sh` | update | sein einziger Verify-Pfad ist dieser Lauf (`verify: full-smoke`) — ohne Nachzug verliert der Fall seinen Gegenstand |
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
- `in-progress` → `open`: falls [slice-079](../open/slice-079-exit-code-vertrag.md) den Exit-Code-Vertrag
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
  der Ausgabe, nicht die Häufigkeit des Falls — und das ist die Grenze, nicht der Zweck. —
  **Ausgang (Closure, Planner): weiter offen → Beobachtungs-Register.** Die Nachrunde (Commits
  `9fecf85a`/`848f7bf0`) hat die **Abdeckung der Eigenschaft** verstärkt — der Zahn bindet jetzt
  beide im DoD-Rot-Kriterium genannten Pakete (`internal/report` **und**
  `cmd/ai-harness-init/span_report.go`), nicht nur eines —, aber die im Risiko benannte Grenze
  selbst bleibt unverändert: beide Tests konstruieren ihren fehlenden Pfad, keiner reproduziert
  einen realen, auf einer fremden Maschine vertippten Mount. Neue Beobachtung angelegt:
  [`BEO-ALL/test-bindet-konstruierten-pfad-nicht-den-realen-fehlgriff`](../observations/BEO-ALL/test-bindet-konstruierten-pfad-nicht-den-realen-fehlgriff/observation.md)
  (1×, Beleg dieser Closure).
- **Die Streuung der Summe bleibt ungemessen, benannt statt geschlossen.** DoD (3) macht die
  Bestandszeile eindeutig; sie beantwortet nicht, ob ein einzelner Strom die Summe dominiert. Wer
  diese Zahl will, schneidet sie als **eigene** Größe mit eigenem Zahn — die Linie dafür zieht
  [`ADR-0012`](../../adr/0012-haupt-kontext-ohne-token-bilanz.md) in ihrer Fitness Function: zwei
  Größen in eine Angabe zu legen verliert eine. — **Ausgang (Closure, Planner): entfallen.** Keine
  eigenständige offene Frage, sondern dieselbe Abgrenzung, die DoD (3) selbst schon nennt (§2:
  *„Was nicht dazukommt, ist eine zweite Zahl … sie hier mitzudrucken legte zwei Größen in eine
  Angabe zusammen (§6)"*) und die [`ADR-0012`](../../adr/0012-haupt-kontext-ohne-token-bilanz.md)
  mit ihrer Fitness Function bereits als Norm trägt. Der Punkt wiederholt eine bereits gedeckte
  Grenze, statt eine neue zu benennen; kein Register-Eintrag.
- **Nicht in diesem Slice:** die **Cache-Rechnung** — sie hat nach
  [`ADR-0021`](../../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md) dauerhaft keinen Eingang
  und keinen Auflösungs-Trigger (§1); der **verlorene Lauf ohne Span**, den die Abdeckungszahl
  nicht sehen kann ([slice-077](../open/slice-077-verlorener-lauf-sichtbar.md)); die Bedeutung der
  **Exit-Codes** ([slice-079](../open/slice-079-exit-code-vertrag.md)); jede Emission ins Ziel und jede
  Ausweitung des Span-Schemas. — **Ausgang (Closure, Planner): entfallen.** Eine
  Abgrenzungsliste, keine eigenständige offene Frage: Jeder Punkt hat bereits eine Adresse — die
  Cache-Rechnung ist durch [`ADR-0021`](../../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md)
  dauerhaft und ohne Auflösungs-Trigger ausgeschlossen, der verlorene Lauf und die Exit-Codes
  stehen als eigene, bereits existierende Slices in `open/`
  ([`slice-077`](../open/slice-077-verlorener-lauf-sichtbar.md),
  [`slice-079`](../open/slice-079-exit-code-vertrag.md)). Diese Closure ändert an keinem der vier
  etwas; kein neuer Folge-Slice, kein Register-Eintrag.

## 7. Closure-Notiz (nach `done/`)

Geschrieben von der Rolle Planner in frischem Kontext ([`AGENTS.md`](../../../../AGENTS.md) §3.10),
nach Review (`f408950f`) und Verifikation (`ed1e8536`). Alle Kommandos gemessen am 2026-09-27,
keine Erwartungswerte
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)).

- **Was hat funktioniert:** Der Schnitt hielt — drei DoD-Punkte über derselben Ausgabe und
  demselben Aufrufweg, keine der beiden Rückführungen aus §4 ausgelöst. Reviewer (0 HIGH,
  1 MEDIUM, 1 LOW) und Verifier bestätigten alle drei DoD-Rot-Kriterien unabhängig real
  rot-vor-grün, exakt mit dem im Plan genannten Test, nicht durch Übernahme der
  Implementer-Angabe.
- **Was ging anders als geplant:** Der erste Anlauf (Commit `be0751b8`) deckte DoD (1) nur über
  `internal/report`, nicht über `cmd/ai-harness-init/span_report.go`, obwohl das Rot-Kriterium in
  §2 wörtlich beide Pakete nennt — der Reviewer fing das als MEDIUM. Die Nachrunde
  (`9fecf85a`/`848f7bf0`) hat die Lücke geschlossen: ein CLI-Ebenen-Test plus Mutations-Fall 495.
  Der Verifier hat den Fix eigenständig rot-vor-grün nachvollzogen, nicht nur gelesen.
- **`make mutate`: Teilmessung, keine Gesamtaussage.** Real gefahren (Reviewer und Verifier,
  unabhängig): `make mutate MUTATE_JOBS=1 MUTATE_CASES='491-… 492-… 493-… 494-… 495-…'` →
  `5 ok, 0 Befund(e)`, `TEILLAUF 5 von 482 — kein Beleg`. Beleg-Slot
  `.harness/state/mutate-passed.key` existiert vorher wie nachher nicht — kein voller `make
  mutate` gefahren, keine Aussage über das grüne Ganze wird hier behauptet.
- **`make full-smoke`: real gefahren, kein Nachlauf nötig.** Anders als bei mehreren
  Vorgänger-Slices wurde der Voll-E2E-Sensor hier tatsächlich einmal real gefahren (Implementer,
  Exit 0, ~3 Minuten) — Schritt (b)/(d) von `harness/tools/full-smoke.sh` wurden im selben Zug
  nachgezogen (Commit `10e54f68`), Reviewer und Verifier haben den Diff dazu gelesen und als
  sachlich notwendig statt kosmetisch eingeordnet, ohne den teuren Lauf selbst zu wiederholen.
  Diese Closure fährt ihn aus demselben Grund nicht erneut.
- **Redundanz-Frage zu Fall 495 — geklärt, kein Befund.** Der Implementer meldete selbst, dass
  Fall 495 an seiner konkreten Mutation (Writer-Tausch) nicht exklusiv bindet — drei ältere Tests
  fangen dieselbe Mutation kollateral mit. Der Verifier hat das empirisch nachvollzogen (isolierte
  Gegenprobe mit nur einem älteren, bereits bestehenden Test) und zwei Fragen sauber getrennt:
  bindet der Sensor exklusiv? Nein — `make mutate` verlangt das nicht (`harness/tools/mutate.sh`
  prüft nur Anwesenheit des genannten Fehlschlags). Ist der **neue Test** redundant zu einem
  bereits bestehenden? Nein — kein vorhandener Test vor der Nachrunde prüfte den
  `args[0]`-Passthrough eines fehlenden Pfades. Kein Befund; siehe Register unten.
- **LOW (Commit-Granularität `be0751b8`) bleibt offen, kein Blocker.** Die Begründung „geteilter
  switch-Block" trägt für DoD (1)/(2), nicht für DoD (3) (eigener Codeblock, eigener Test, eigener
  Mutations-Fall 494) — vom Reviewer selbst am `git diff`-Hunk nachgewiesen. Kein
  Hard-Rule-Verstoß (Modul 5 stellt die Commit-Granularität pro DoD-Punkt ins Ermessen), nicht
  merge-blockierend. Register-Eintrag unten.
- **Steering-Loop-Eintrag.** Kein Norm-Artefakt entsteht direkt aus diesem Slice. Drei neue
  Beobachtungen wandern unter der Schwelle (1×) ins Beobachtungs-Register; eine bereits bei 3×
  stehende Klasse (`mutations-fall-nennt-einen-test-die-mutation-faerbt-mehrere`,
  Architect-Übergabe seit `slice-fall-406-trifft-die-umgebaute-zerlegung` fällig) trägt einen
  vierten, die Übergabe nicht verändernden Beleg. Form: **benannte Spec-Lücke** — jede der drei
  neuen Klassen ist benannt, kein Wächter fängt sie, und keine erreicht mit diesem Slice die
  Verkörperungs-Schwelle.
- **Beobachtungs-Register (`../observations/`):**
  - Neu:
    [`BEO-ALL/dod-rot-kriterium-nennt-zwei-pakete-implementierung-deckt-nur-eines`](../observations/BEO-ALL/dod-rot-kriterium-nennt-zwei-pakete-implementierung-deckt-nur-eines/observation.md)
    (1×, Beleg dieser Closure — Review-MEDIUM: ein Rot-Kriterium, das zwei Pakete nennt, ist erst
    eingelöst, wenn beide real getestet sind, auch wenn die fachliche Entscheidung nur in einem
    liegt).
  - Neu:
    [`BEO-ALL/commit-granularitaet-pauschalbegruendung-deckt-nicht-alle-zusammengelegten-punkte`](../observations/BEO-ALL/commit-granularitaet-pauschalbegruendung-deckt-nicht-alle-zusammengelegten-punkte/observation.md)
    (1×, Beleg dieser Closure — Review-LOW: eine pauschale Commit-Begründung für zusammengelegte
    DoD-Punkte, die nur für einen Teil von ihnen zutrifft).
  - Neu:
    [`BEO-ALL/test-bindet-konstruierten-pfad-nicht-den-realen-fehlgriff`](../observations/BEO-ALL/test-bindet-konstruierten-pfad-nicht-den-realen-fehlgriff/observation.md)
    (1×, Beleg dieser Closure — §6-Risiko 1: ein Rot-vor-Grün-Test bindet die Eigenschaft über
    einem konstruierten Fall, nicht den realen Fehlgriff auf einer fremden Maschine).
  - Fortgeschrieben:
    [`BEO-ALL/mutations-fall-nennt-einen-test-die-mutation-faerbt-mehrere`](../observations/BEO-ALL/mutations-fall-nennt-einen-test-die-mutation-faerbt-mehrere/observation.md)
    (4. Beleg dieser Closure; Klasse bereits seit `slice-fall-406-trifft-die-umgebaute-zerlegung`
    bei 3×, Architect-Übergabe unverändert offen, von dieser Closure nicht neu ausgelöst).
- **Register-Paarung (c), zweite Hälfte — wird nach dem Move gemessen** (Paarung setzt auf
  `done/`-Pfaden auf; Nachtrag folgt im Move-Anschluss-Commit).
- **Offene Risiken (§6):** drei Ausgänge — 1 *weiter offen → Register* (Zahn bindet konstruierten
  Pfad, nicht den realen Fehlgriff), 2 *entfallen* (Streuung der Summe — Wiederholung der
  DoD-3-/ADR-0012-Abgrenzung), 3 *entfallen* (Abgrenzungsliste — jeder Punkt hat bereits eine
  Adresse: ADR-0021, `slice-077`, `slice-079`). Details direkt bei den Risiken in §6.

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `internal/`, `cmd/` und
`test/` gehören zum Greenfield-Bestand; der Modus steht in der
Modus-Deklaration von [`harness/conventions.md`](../../../../harness/conventions.md).
