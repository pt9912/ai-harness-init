# ADR-0068: Der Nachzug nennt den Zustand des Tap nur, soweit die Antwort der Schnittstelle ihn trägt — die Menge der Ablehnungen ist eine benannte Setzung, und eine Nachkontrolle, die nach dem Schreiben nicht lesen kann, sagt, dass geschrieben ist

**Status:** Proposed

**Datum:** 2026-09-26

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[ADR-0064](0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md)
(**Accepted** — der Gegenstand: Festlegung 3, der Absatz nach Schritt g, und die Meldung der
Nachkontrolle; ihre Festlegung 2 mit den drei Exit-Klassen, ihre Festlegung 6 und ihre §Grenze
bleiben unberührt),
[ADR-0066](0066-exit-klassen-des-tap-werkzeugs-sind-die-des-skripts.md) (**Accepted** — die Klasse
des Skripts und die Zeile `tap-<modus>: Exit <N>`; diese Entscheidung führt keine Klasse ein),
[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (was das Tap nach einem
Schreiben trägt, entscheidet die Kontrolle am veröffentlichten Asset, nicht die Meldung des
Schreibens),
[ADR-0062](0062-eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-nicht-beantwortet.md)
(**Proposed** — welche Rolle den Nachzug fährt, bleibt dort und wird hier nicht berührt),
[ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) (**Accepted** — der Beleg des
Accept-Übergangs),
[`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben dem Kommando, das sie liefert; keine ist ein Erwartungswert)

**Schärft:** — Prozess- und Werkzeug-Entscheidung ohne Spec-Stratum.

**Supersedes:** keine. Diese Entscheidung **schärft**
[ADR-0064](0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md)
Festlegung 3 und löst keine ihrer Festlegungen ab: das *„ausdrücklich abgelehnt (Antwort der
Schnittstelle: Anmeldung, Schutz des Branches, Konflikt)"* und das *„ohne Antwort … ungewiss"* der ADR
bleiben wörtlich wahr. Die Entscheidung legt fest, was die ADR offen lässt — den Status, der weder das
eine noch das andere ist, und die Meldung der Nachkontrolle nach einem vollzogenen Schreiben. Der Status
von ADR-0064 im ADR-Index bekommt darum keinen Zusatz (anders als bei
[ADR-0066](0066-exit-klassen-des-tap-werkzeugs-sind-die-des-skripts.md), die drei Stellen ablöst).

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md`
§Ziel-Form: ADR (MADR) und §Hard Rule für Accepted-ADRs (*„Spätere Korrekturen oder Schärfungen
entstehen als neue ADR mit explizitem Verweis auf die abgelöste oder geschärfte Vorgängerin."*),
gelesen gegen `v6.9.0`; Baseline-Regelwerk `modul-08-agentenrollen.md` §Rollen-Regeln (das
Architect-Verdikt ist ein Artefakt).

---

## Kontext

### Die Lücke, gemessen

[ADR-0064](0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md) Festlegung 3
ordnet dem Schreibvorgang zwei Ausgänge zu, jeden mit dem, was die Meldung sagt: ein **ausdrücklich
abgelehnter** Schreibvorgang (*„Anmeldung, Schutz des Branches, Konflikt"*) endet mit Exit 2 und der
Meldung *„Tap unverändert"*; ein Schreibvorgang **ohne Antwort** endet mit Exit 2 und *„Ausgang
ungewiss"*. Die ADR nennt **Ursachen**, keine Statuscodes. Drei Lagen sind damit nicht gedeckt:

1. **Eine Antwort, die keine der drei Ursachen ist** — ein Serverfehler, ein anderer Erfolgscode, ein
   Status wie 404, 422 oder 429. Sie ist weder *„ohne Antwort"* noch eine der genannten Ablehnungen.
2. **Die Abbildung Ursache → Status.** Welchen Status die Schnittstelle für *„Schutz des Branches"*
   nennt, ist am realen Tap ungemessen; das Tap ist ungeschützt
   ([ADR-0064](0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md) §Lage:
   `protected` ist `false`), der Fall ist dort nicht herstellbar.
3. **Die Meldung nach einem vollzogenen Schreiben, wenn die Nachkontrolle nicht lesen kann.** Die
   Tabelle in Festlegung 2 ordnet ein unlesbares Tap der Klasse 2 zu; welche Aussage über den Zustand des
   Tap die Meldung dabei trägt, steht in keiner Festlegung.

**Der Zustand im Code**, am 2026-09-26 (keine Erwartungswerte, das Werkzeug wandert):

```sh
sed -n '/^schreibe()/,/^}/p' harness/tools/tap-nachzug-nutzlast.sh | grep -E '^\s+[0-9*|" ]+\) ' | cut -c1-60
# 200) return 0 · 401) … 403) … 409) (je „Schreiben abgelehnt … Tap unverändert") · 000) und *) („Ausgang des Schreibens ungewiss …")
grep -nE 'exit (0|10|2)\b|beende 2' harness/tools/tap-nachzug-nutzlast.sh
# die Nutzlast endet mit den Status 0, 10 und 2 — kein weiterer; das Host-Skript bildet 0 auf 0, 10 auf 1, 2 auf 2
```

Der Fall `sync abgelehnt` in `test/tap-nachzug.bats` bindet beide Listen (*„Tap unverändert"* nur für
401, 403 und 409; jede andere oder keine Antwort meldet *„Ausgang ungewiss"* und nie *„unverändert"*), der
Fall `sync teilerfolg` die Meldung der Nachkontrolle nach einem vollzogenen Schreiben, wenn das Lesen des
Tap scheitert. Beide Zuordnungen sind im Code gebunden und in der Prozedur für das Werkzeug wiedergegeben;
**die Norm nennt sie nicht.** Ein Leser der ADR als Constraint kann nicht unterscheiden, ob die Menge
Absicht oder Zufall ist.

**Was der Code nach dem Schreiben nicht über `nicht_lesbar()` führt.** Hat der Schreibaufruf mit 200
geantwortet (`geschrieben=ja`), gibt es außer dem unlesbaren Tap drei weitere Wege zu Exit 2, an denen die
Meldung den Vollzug nicht nennt und **in dieser Lage** kein Fall sie bindet
(`harness/tools/tap-nachzug-nutzlast.sh`: die Funktion `gleich`, der Zweig `*)` in `beende`, der Trap
`trap 'exit 2' HUP INT TERM`). Dieselben Meldungen sind gebunden, wo kein Vollzug vorausging — im Modus
`check` und vor dem Schreibaufruf
(`grep -n 'cmp Exit\|interner Fehler der Nutzlast' test/tap-nachzug.bats`):

- `cmp` endet mit einem Status ≥ 2: *„der Vergleich lief nicht (cmp Exit N) — es wurde nichts verglichen"*;
- ein Kommando der Nutzlast scheitert (etwa das Berechnen eines Digests): *„interner Fehler der Nutzlast …
  es wurde nichts verglichen"*;
- ein Signal (HUP, INT, TERM): Exit 2, keine Meldung.

### Was die Wahl trägt

Eine Meldung *„Tap unverändert"* ist eine Aussage über den Zustand eines Fremd-Repos; sie ist falsch, wenn
ihr Status auch bei einem Vollzug entstehen kann. Eine Meldung *„Ausgang ungewiss"* behauptet nichts über
den Zustand und nennt das Werkzeug, das ihn entscheidet — `make tap-check`, das auch ohne Token liest.
Beide enden mit Exit 2; die Klasse ändert an der Wahl nichts.

Die Kosten sind für einen Status **außerhalb** der Menge aus Festlegung 2 ungleich verteilt, und die
Verteilung entscheidet: **die Enge kostet einen lesenden Aufruf**, den die Prozedur ohnehin verlangt — die
Meldung des vollzogenen Schnitts hängt an `make tap-check`
([ADR-0064](0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md)
Festlegung 6), der Zustand des Tap wird am Tap gelesen, nicht an der Meldung des Schreibens. Eine **zu
weite** Zusage kostet eine Meldung, der der Bediener glaubt und die nicht stimmt. Ohne Messung am realen
Tap fehlt jeder Grund, die Zusage zu weiten. Für 401, 403 und 409 selbst trägt die Annahme aus Festlegung 2:
bricht sie, sagt *„Tap unverändert"* Falsches — das ist die Grenze der Zusage (§Grenze, erster Punkt), keine
Kostenverteilung.

## Entscheidung

**Wir legen fest, dass `sync` über den Zustand des Tap nur spricht, soweit die Antwort der Schnittstelle
ihn trägt, und schließen damit die drei Lagen aus §Kontext, ohne eine Klasse einzuführen und ohne eine
Festlegung von ADR-0064 abzulösen.** Drei Festlegungen.

**1. Der Grundsatz.** Eine Meldung von `sync`, die den Zustand des Tap aus der Antwort der Schnittstelle
bildet, ist eine von vier:

- *unverändert* — die Schnittstelle hat das Schreiben ausdrücklich abgelehnt (Festlegung 2);
- *bereits erfolgt* — der Schreibaufruf wurde mit HTTP 200 beantwortet (Festlegung 3);
- *nichts geschrieben* bzw. *nichts verglichen* — der Lauf endete vor dem Schreibaufruf, ein Schreibaufruf
  hat nicht stattgefunden;
- *ungewiss* — der Schreibaufruf hat keine Antwort, die eine der ersten beiden trägt.

Folgt keine der ersten drei aus der Antwort, lautet die Meldung *„Ausgang des Schreibens ungewiss"* und
nennt `make tap-check TAG=<tag>`. Der Exit ist in allen vier Fällen der des Skripts nach
[ADR-0064](0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md) Festlegung 2 und
[ADR-0066](0066-exit-klassen-des-tap-werkzeugs-sind-die-des-skripts.md) Festlegung 1 (2 bei nicht
ausführbar); es entsteht **kein vierter Status der Nutzlast** und keine vierte Klasse des Skripts.
**Nicht Teil der vier sind die Wege nach dem Schreiben, die keine Antwort der Schnittstelle bilden** —
Festlegung 3, zweiter Absatz.

**2. Die Ablehnungs-Menge ist eine Setzung.** *„Tap unverändert"* sagt `sync` nur bei **HTTP 401**
(Anmeldung), **403** (Anmeldung oder Schutz des Branches) und **409** (Konflikt gegen den Blob-Stand).
**Jeder andere Status** — auch 404, 422, 429, 5xx, 201 und 204 — **und jedes Ende ohne Antwort** endet mit
*„Ausgang des Schreibens ungewiss"*; das Werkzeug wiederholt den Schreibaufruf nicht
([ADR-0064](0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md)
Festlegung 3, Schritt f). Die Abbildung der Ursachen *Anmeldung, Schutz des Branches, Konflikt* auf diese
drei Status ist **eine Annahme dieser Entscheidung, am realen Tap ungemessen**: ob die Schnittstelle für
einen Schutz des Branches einen anderen Status nennt, ist offen. Eine **Erweiterung der Menge** braucht als
Beleg eine Antwort des realen Tap (Status und Ursache), die keinen Vollzug bedeuten kann, und ist eine
Änderung dieser Festlegung.

**3. Die Nachkontrolle nach dem Vollzug sagt, dass geschrieben ist, wenn sie nicht lesen kann.** Hat der
Schreibaufruf mit HTTP 200 geantwortet und kann die Nachkontrolle das Tap **nicht lesen** (das Lesen endet
mit jedem Status außer 200 oder ohne Antwort), sagt die Meldung, dass das Schreiben bereits erfolgt ist,
dass unbekannt bleibt, ob das Tap die Bytes des Assets trägt, und nennt `make tap-check TAG=<tag>`. Sie sagt
**nicht**, es sei nichts verglichen worden, ohne den Vollzug zu nennen: *„nichts verglichen"* ohne
diesen Zusatz liest ein Bediener als *„nichts geschehen"*. Die Klasse bleibt 2 — ein unlesbares Tap ist
kein Unterschied
([ADR-0064](0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md) Festlegung 2). Ein
200 des Schreibaufrufs ist das Wort der Schnittstelle, nicht der Beleg der Bytes; den Beleg führt die
Nachkontrolle bzw. `make tap-check`.

**Der benannte Rest: die Wege nach dem Schreiben, die der Code nicht über die Meldung des unlesbaren Tap
führt.** Die drei Wege aus §Kontext (`cmp` Exit ≥ 2, interner Fehler der Nutzlast, Signal) enden nach dem
Vollzug mit Exit 2 und — soweit sie eine Meldung tragen — mit *„nichts verglichen"*, ohne den Vollzug zu
nennen; ein Signal meldet nichts. Die Festlegung erstreckt sich **nicht** auf sie, aus drei Gründen:
[`AGENTS.md`](../../../AGENTS.md) §3.6 verlangt, die Zusage auf das einzuschränken, was der Code hält; die
Ausdehnung verlangte eine Änderung an `fehler()`, an `beende` und am Signal-Pfad und drei neue Fälle, von
denen der Signal-Fall hermetisch kaum zu binden ist; und der Weg ist gefahrarm: kein Ausgang ist je
*„unverändert"*, der Exit bleibt 2 (nie Grün), und ein weiterer Lauf des Werkzeugs liest und vergleicht
**vor** jedem Schreiben (`sync_lauf`: `lese_tap` und `gleich` stehen vor `schreibe`). **Die Begründung
*„gefahrarm"* ist ein Ist-Zustand, kein Versprechen; kein Fall bindet sie nach dem Schreiben**
(Fitness-Zeile 4). Der erneute Lauf meldet bei geschriebenen Bytes *„gleich"* und schreibt nichts erneut,
**soweit sein Lesen den Stand nach dem Schreiben liefert**: gegen einen Stub tut es das; am realen Tap gilt
es außerhalb des Cache-Fensters aus
[ADR-0064](0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md) (`max-age=60`; dass
ein Lesen nach einem Schreiben den Stand davor liefert, ist dort nicht beobachtet). Innerhalb des Fensters
kann der erneute Lauf den Stand davor lesen, gegen den alten Blob-Stand schreiben und mit 409 und
*„Tap unverändert"* enden — er hat dann nichts geändert, und `make tap-check` nach dem Fenster nennt den
Zustand des Tap. Der Bediener, der *„nichts verglichen"* als *„nichts geschehen"* liest, wiederholt den Lauf
und bekommt den Vollzug außerhalb des Fensters genannt. Der Rest ist **benannt, nicht geschlossen**;
Trigger 3 unten nennt, wann er zu schließen ist.

**Was hier NICHT entschieden ist:** welchen Status das reale Tap für eine Ablehnung nennt (Festlegung 2
benennt die Annahme, sie misst nicht); welche Rolle den Nachzug fährt
([ADR-0062](0062-eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-nicht-beantwortet.md)); der
Release-Job und der Wortlaut der Prozedur.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — nichts tun; die Zuordnung bleibt im Code und in den Fällen | kein Text an der Norm; der Code tut heute das Richtige und ist gebunden | die Norm lässt drei Lagen offen; ein späterer Umbau kann *„unverändert"* auf weitere Status ausdehnen, ohne dass eine Festlegung ihn als Verstoß liest; die Menge steht ohne Aussage, ob sie gemessen oder gesetzt ist |
| B — weitere 4xx (404, 422, 429 oder alle) nach *„unverändert"* | weniger überflüssige Nachkontrollen; eine Meldung mit klarerer Ursache | die Ursache hinter 404, 422 und 429 ist am realen Tap ungemessen; ein Status, der auch bei einem Vollzug entstehen kann, machte die Zusage falsch; der Gewinn — ein gesparter lesender Aufruf — steht in keinem Verhältnis zu einer falschen Zustandsaussage |
| C — jede Antwort außer 200 meldet *„ungewiss"*, auch 401, 403 und 409 | eine Regel ohne Menge, nichts zu messen | [ADR-0064](0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md) Festlegung 3 sagt für die ausdrückliche Ablehnung *„Tap unverändert"*; ein abgelaufenes Token (401) trägt die belastbare Aussage — dass es im Betrieb eine naheliegende Ursache ist, ist eine Annahme, ihre Häufigkeit ungemessen wie die Menge —, und C nähme sie |
| D — die Zuordnung steht nur in der Prozedur | die Prozedur nennt sie schon | die Prozedur ist Nutzer-Doku und trägt Ist-Zustand, keine Festlegung; der Implementer liest sie nicht als Constraint; eine Norm-Lücke bliebe eine |
| **E — eine Schärfung ohne `Supersedes`: der Grundsatz, die Menge als benannte Setzung, die Meldung der Nachkontrolle bei unlesbarem Tap, der Rest benannt (gewählt)** | trifft genau die drei Lagen; löst nichts ab; die Setzung ist als solche benannt und hat ihren Beleg-Weg; der Code und seine Fälle halten schon, was die Festlegungen sagen, und die Zusage reicht nicht weiter als der Code | eine ADR für eine Ebene, die der Code bereits hält; die Menge in einer ADR heißt: eine gemessene Erweiterung ist eine Folge-ADR; der Rest aus Festlegung 3 bleibt stehen, bis Trigger 3 eintritt |
| F — Festlegung 3 gilt für **jeden** Weg nach dem Schreiben, die Nutzlast zieht nach | die Zusage *„jede Meldung nach dem Vollzug"* stünde ohne Rest; ein Signal-Ende ohne Meldung ist geschlossen | eine Änderung an `fehler()`, an `beende` und am Signal-Pfad (der Zustand `geschrieben` muss in jedem Ausgang nach dem Schreiben die Meldung tragen, auch im Trap) und drei neue Fälle — `cmp` und der Nutzlast-Fehler über einen Stub, das Signal hermetisch kaum; der Gewinn gilt einem Weg, der ohne Vorfall ist und dessen Folge ein wiederholter Lauf auffängt (Festlegung 3, benannter Rest) |

**Warum E und nicht A.** A wäre die kleinere Handlung, und der Code hält die Zuordnung. Gegen A spricht,
dass die Setzung dann **unbenannt** bliebe: ein Bediener oder Implementer erführe nirgends, dass 401, 403
und 409 eine Annahme sind und dass jede Erweiterung einen Beleg des realen Tap braucht. Die Norm kostet
einen Absatz.

**Warum E und nicht F.** F ist die sauberere Zusage und die größere Handlung: sie fasst den Fehlerpfad der
Nutzlast an, um Wege zu schließen, die im Betrieb nie beobachtet sind und deren Folge harmlos ist. E sagt,
was der Code hält, und nennt, was er nicht hält; der Trigger holt F nach, wenn ein Weg real auftritt.

## Konsequenzen

- **Positiv:** eine Meldung von `sync`, die den Zustand aus der Antwort bildet, sagt nie mehr über das Tap,
  als die Antwort trägt — mit der Menge aus Festlegung 2 als benannter Setzung; die Setzung ist an einen
  Beleg gebunden; die Meldung der Nachkontrolle bei unlesbarem Tap lässt keinen Bediener einen Teilerfolg
  als *„nichts geschehen"* lesen; keine Klasse und kein Status der Nutzlast kommt hinzu.
- **Negativ:** bei einer Ablehnung mit einem Status außerhalb der Menge kostet die Meldung *„ungewiss"*
  einen überflüssigen `make tap-check` — eine gesparte Nachkontrolle wäre die sichere Richtung nicht mehr;
  die Menge ist bis zum ersten realen Nachzug **ungemessen**; die Menge in einer ADR macht ihre
  gemessene Erweiterung zu einer Folge-ADR.
- **Negativ:** drei Wege nach dem Schreiben (`cmp` Exit ≥ 2, interner Fehler der Nutzlast, Signal) nennen
  den Vollzug nicht; kein Fall bindet sie nach einem 200 des Schreibaufrufs. Die Zusage von Festlegung 3
  reicht nicht bis zu ihnen.
- **Folgepflicht 1 — kein Nachrüsten.** Lebende Artefakte, die die Zuordnung nennen (die Prozedur, die
  Köpfe von Skript und Nutzlast, der Kommentar am Ziel), nennen sie **als Setzung**, wo sie die Menge
  nennen. Der Bestand ist kein Arbeitsauftrag; wer die Stelle ohnehin anfasst, zieht sie nach.
- **Folgepflicht 2 — kein Index-Zusatz an ADR-0064.** Keine Festlegung wird abgelöst; der Eintrag von
  ADR-0064 im ADR-Index bleibt, wie er ist.

### Grenze

Die Festlegungen sagen zu: **welche Aussage über den Zustand des Tap eine Meldung von `sync` trägt, die
ihn aus der Antwort der Schnittstelle bildet.** Sie sagen **nicht** zu:

- **den Status der realen Schnittstelle.** Dass 401, 403 und 409 die Ursachen *Anmeldung, Schutz,
  Konflikt* tragen, ist die Annahme aus Festlegung 2; der erste reale Nachzug misst sie. **Bricht sie, ist
  *„Tap unverändert"* für den betroffenen Status falsch** — die Zusage aus den Konsequenzen, eine Meldung
  sage nie mehr über das Tap, als die Antwort trägt, gilt für die Menge unter dieser Annahme, nicht für
  ihren Rand (Trigger 1 beobachtet den Rand nach außen, Trigger 4 den Bruch innerhalb der Menge).
- **dass ein 200 den Vollzug der richtigen Bytes bedeutet.** Es ist das Wort der Schnittstelle; den Beleg
  führt die Nachkontrolle bzw. `make tap-check`.
- **die Meldungen der drei Wege nach dem Schreiben, die keine Antwort der Schnittstelle bilden** (`cmp`
  Exit ≥ 2, interner Fehler der Nutzlast, Signal): sie nennen den Vollzug nicht (Festlegung 3, benannter
  Rest).
- **die Meldungen des Modus `check`.** Er schreibt nicht; *„nach dem Vollzug"* kommt dort nicht vor.
- **einen Bediener, der die Meldung nicht liest.** Die Norm bindet, was das Werkzeug sagt.

## Fitness Function (falls maschinell prüfbar)

Jeder Fall wird vor dem Accept einmal rot gesehen
([`AGENTS.md`](../../../AGENTS.md) §3.6), die Ausgabe gelesen, nicht nur der Exit. **Schwächung** heißt:
die Zusicherung wird testweise so verändert, dass sie nicht mehr hält. Die Fälle bestehen und werden hier
gebunden, nicht neu geschrieben.

| Zusage | Fall (`bats`, hermetisch; `curl`-Stub) | Rot unter der Schwächung |
|---|---|---|
| *„Tap unverändert"* nur bei 401, 403 und 409; jeder andere Status und keine Antwort meldet *„Ausgang des Schreibens ungewiss"* mit `make tap-check`, nie *„unverändert"*; Exit 2 und die Zeile `tap-sync: Exit 2` genau einmal | `sync abgelehnt` in `test/tap-nachzug.bats` (401, 403, 409 · 000, 500, 502, 201, 204, 404, 422, 429) | 404, 422 und 429 in den Ablehnungs-Zweig der Nutzlast aufgenommen → der Fall wird rot (die Aussage `Ausgang des Schreibens ungewiss` fällt); der ungewiss-Zweig meldet zusätzlich *„unverändert"* → rot |
| Nach einem 200 des Schreibaufrufs sagt jede Meldung der Nachkontrolle, die das Tap nicht lesen kann, dass das Schreiben bereits erfolgt ist, und nennt `make tap-check`; vor dem Schreiben bleibt es bei *„nichts verglichen"*; Exit 2 | `sync teilerfolg` in `test/tap-nachzug.bats` (Lesecode nach dem Schreiben 404, 401, 403, 429, 500, keine Antwort) | der Zweig für den vollzogenen Zustand entfällt → der Fall wird rot (die Aussage *„das Schreiben ist bereits erfolgt"* fehlt, die Meldung lautet *„… es wurde nichts verglichen"*); die Meldung nach dem Vollzug trägt zusätzlich *„nichts verglichen"* → rot |
| Keine neue Klasse: die Nutzlast endet mit genau den Status 0, 10 und 2 | `grep -nE 'exit (0\|10\|2)\b\|beende 2' harness/tools/tap-nachzug-nutzlast.sh` (Sichtprüfung; kein Gate) und die Fälle, die den Exit lesen | — (kein Sensor; benannt, nicht geschlossen) |
| Die drei Wege nach dem Schreiben (`cmp` Exit ≥ 2, interner Fehler der Nutzlast, Signal) nennen den Vollzug **nicht** — das ist der Ist-Zustand, kein Versprechen; ebenso ist die Begründung des Rests (*„nie ‚unverändert', Exit 2"*) kein Versprechen | kein Fall nach einem 200 des Schreibaufrufs (dieselben Meldungen sind im Modus `check` und vor dem Schreiben gebunden) | — (kein Sensor; der Rest ist benannt, nicht geschlossen — Trigger 3) |

**Rot gesehen** im Architect-Lauf dieser Entscheidung, in einer Kopie des Baums, `bats` im gepinnten
Bild: die erste Schwächung (Zweig `404 | 422 | 429` mit *„Tap unverändert"* vor dem `*)`-Zweig) färbt
`sync abgelehnt` rot, die Aussage `Ausgang des Schreibens ungewiss` fällt; die zweite (die Bedingung der
Meldung nach dem Vollzug auf `false`) färbt `sync teilerfolg` rot, die Aussage *„das Schreiben ist bereits
erfolgt"* fällt und die Ausgabe zeigt *„… es wurde nichts verglichen"*. Der unveränderte Baum ist grün.

## Re-Evaluierungs-Trigger

- **Wenn das reale Tap eine Ablehnung mit einem Status außerhalb von 401, 403 und 409 nennt** *(beobachtbar
  an einem Lauf, dessen Meldung *„Ausgang des Schreibens ungewiss: unerwartete Antwort der Schnittstelle
  (HTTP <Status>)"* lautet und dessen nachfolgender `make tap-check` den Stand vor dem Lauf zeigt)*, **oder
  wenn das Tap geschützt wird**
  ([ADR-0064](0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md)
  Re-Evaluierungs-Trigger 2 — der Schutz ist dann erstmals am realen Tap herstellbar): die Menge aus
  Festlegung 2 ist gegen den gemessenen Status neu zu wägen.
- **Wenn eine Meldung von `sync`, die den Zustand des Tap aus der Antwort bildet, ihn in einer fünften Form
  nennt** *(beobachtbar an einer Meldung, die keiner der vier Formen aus Festlegung 1 entspricht)*: der
  Grundsatz trägt nicht.
- **Wenn ein Weg nach dem Schreiben im realen Betrieb auftritt, dessen Meldung den Vollzug nicht nennt**
  *(beobachtbar an einem Lauf, dessen Ausgabe `interner Fehler der Nutzlast` oder `der Vergleich lief nicht`
  nennt und dessen nachfolgender `make tap-check` das Tap als geschrieben zeigt, oder an einem Signal-Ende
  nach `HTTP 200`)*: der Rest aus Festlegung 3 ist geschlossen — Alternative F, Code-Folge in der Nutzlast:
  der Zustand `geschrieben` steht in jeder Meldung nach dem Schreiben, auch in `fehler()`, in `beende` und im
  Signal-Pfad, mit je einem Fall.
- **Wenn eine Meldung *„Tap unverändert"* (Status 401, 403 oder 409) einem Lauf gehört, dessen Schreibaufruf
  das Tap doch geändert hat** *(beobachtbar an einem Lauf, dessen Meldung *„Tap unverändert"* lautet und
  dessen nachfolgender `make tap-check` das Tap mit den Bytes des Assets zeigt, obwohl der Lauf vor dem
  Schreiben ein abweichendes Tap las und kein anderer Schreibvorgang bekannt ist)*: die Annahme aus
  Festlegung 2 ist für den betroffenen Status gebrochen, die Menge ist zu kürzen — eine Folge-ADR.

**Wer diese Trigger beobachtet — und wer nicht.** Ein Sensor, der eine dieser Bedingungen liest, besteht
nicht. **Trigger 1 und 4 haben einen Anlass:** der erste reale Nachzug ist der Beleg der Zuordnung
([ADR-0064](0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md) §Grenze). Wer ihn
liest — der Auftraggeber oder ein Lauf, der die Ausgabe sieht —, trägt einen Status außerhalb der Menge
(Trigger 1) oder eine Meldung *„Tap unverändert"* bei geschriebenem Tap (Trigger 4) als Beobachtung ins
Register; diese Route hat nur eine Closure, ein Lauf außerhalb einer Closure hat keine —
**benannt, nicht geschlossen**. Die Lücke ist begrenzt: der Fehlgriff ist ein überflüssiger lesender
Aufruf für einen Status außerhalb der Menge und nie ein Grün; innerhalb der Menge bricht nur die Annahme
aus Festlegung 2 die Zusage (§Grenze, erster Punkt; Trigger 4).

### Der Acceptance-Trigger

Diese Entscheidung steht auf `Proposed`; bis dahin ist sie ein Architect-Verdikt und als solches das
Übergabe-Artefakt, das der Implementer als Constraint liest. Sie wird `Accepted`, **wenn eine
Reviewer-Runde sie gegen
[ADR-0064](0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md),
[ADR-0066](0066-exit-klassen-des-tap-werkzeugs-sind-die-des-skripts.md) und
[ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) auf Konsistenz geprüft hat und ihr
Report ohne blockierenden Befund an der **Substanz** der drei Festlegungen in `docs/reviews/` liegt.** Ein
blockierender Befund an der **Darstellung** wird behoben und hindert die Annahme nicht. Der Beleg ist eine
Runde der prüfenden Rolle; die Accept-Zeile der §Geschichte nennt ihn als **Kennung**, nicht als Pfad-Link
(ADR-0040 Festlegung 1). **Die Annahme selbst ist die Entscheidung des Auftraggebers.**

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-09-26 | **Proposed** | Architect-Lauf: die Zuordnung der Antworten der Schnittstelle beim Schreiben und die Meldung nach einem vollzogenen Schreiben, beide aus der Review- und Verifikations-Runde der Umsetzung des Modus `sync`. Der Acceptance-Trigger steht oben |
| 2026-09-26 | **Proposed, korrigiert** | Architect-Lauf zum Konsistenz-Review `2026-09-26-review-adr-0035-0068-0069-konsistenz`, Status unverändert: Festlegung 3 gilt für die Nachkontrolle bei unlesbarem Tap, die drei Wege nach dem Schreiben stehen als benannter Rest mit Trigger 3; die Häufigkeitsbehauptung zu 401 entfällt; die Zusage *„nie eine falsche Zustandsaussage"* nennt ihre Reichweite; Verdikt `2026-09-26-architect-verdikt-korrektur-adr-0035-0068-0069` |
| 2026-09-26 | **Proposed, korrigiert** | Architect-Lauf zur Kurzrunde `2026-09-26-review-kurzrunde-adr-0068`, Status unverändert: Trigger 1 zitiert die Meldung, die der Code schreibt; die Wiederholungs-Zusage des benannten Rests nennt das Cache-Fenster als ihre Bedingung, und die Begründung *„gefahrarm"* steht als ungebunden; die Einschränkung in §Grenze führt den Wortlaut der Konsequenz; *„kein Fall"* gilt für die Lage nach einem 200 des Schreibaufrufs; Trigger 4 nennt den Bruch der Annahme innerhalb der Menge (der einzige neue Norm-Inhalt: ein Re-Evaluierungs-Trigger, keine Festlegung); die Alternative E steht vor F |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0068` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).
