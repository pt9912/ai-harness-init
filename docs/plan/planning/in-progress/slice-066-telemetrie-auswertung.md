# Slice slice-066: Telemetrie-Auswertung — Token-Bilanz je Rolle, mit genanntem Nenner

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-09](../welle-09-modul-15-konformitaet.md) — Block 2, setzt auf
[slice-060](../done/slice-060-rollen-achse.md) auf.

**Bezug:** [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) (Baseline ohne
inhaltliche Adaption — Modul 15 ist adoptiert und in Block 2 unumgesetzt),
[`spec/spezifikation.md`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5
(das Span-Schema, das dieser Slice **liest**, samt der dort bindenden Lesevorschrift zum
Sammelposten, und der Ort der Festlegung aus DoD (3)),
[`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) (**Accepted** — die Policy, unter
der der ausgewertete Bestand entstanden ist; die ADR nennt den Auswerter dreimal „slice-060",
gemeint ist seit dem Schnitt **dieser** Slice — die Umdeutung steht unterhalb der
Modus-Deklaration in [`harness/conventions.md`](../../../../harness/conventions.md)),
[`ADR-0003`](../../adr/0003-go-native-binaries.md) (**Accepted** — die Auswertung ist ein
Go-Binary, Docker-only gebaut),
[`ADR-0012`](../../adr/0012-haupt-kontext-ohne-token-bilanz.md) (**Accepted** — der Haupt-Kontext
bleibt dauerhaft ohne Zahl; daraus folgt DoD (2), und die zwei Wächter-Zeilen ihrer Fitness
Function sind die aus diesem Slice. Ihre **Folgepflicht 4** benennt DoD (2) als Bedingung der
Annahme, nicht als Folgearbeit: ohne diesen Punkt hätte ihre Festlegung 2 keinen Zahn),
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (dieselbe Zusage
auf der **Dogfood-Ebene**: das Werkzeug dieses Repos, nicht das emittierte Zielprojekt).
Regelwerk-Quelle:
`.harness/baseline/v3.5.2/regelwerk/modul-15-observability.md`
§Token-Attributions-Regeln.

**Autor:** ai-harness-init-Team (pt9912). **Datum:** 2026-07-29.

---

## 1. Ziel

**Aus den erfassten Spans wird eine Rechnung:** wer hat wie viel verbraucht — und über welche
Menge von Läufen wird dabei überhaupt gerechnet. Kein Dashboard, kein Zeitreihen-Speicher — eine
Auswertung über den vorhandenen Bestand, aufrufbar als `make`-Ziel.

## 2. Definition of Done

- [x] **(1) Token-Bilanz je Rolle, mit ausgesprochenem Sammelposten.** Input- und Output-Token
  summiert **je Rolle** — die Rolle steht in den `Agent`-Spans im Feld **`spawned_role`** (aus
  `tool_response.agentType`, also die *tatsächlich gelaufene*), **nicht** im `agent_role`
  desselben Spans, das die Rolle des **Aufrufers** trägt. Der Wert ist dort bereits normalisiert
  (slice-060 DoD (2)): Unbekanntes und `general-purpose` sind zu **leer** geworden und bekommen
  keine eigene Zeile.
  Die größte Rolle als **Zahl und Prozentsatz** der Gesamtsumme — beides, nicht eines von
  beiden (Modul 15 §Token-Attributions-Regeln). **Das Modul zählt dort fünf Rollen** (Planner ·
  Architect · Implementer · Reviewer · Verifier); die kanonische Liste dieses Repos führt mit
  `validator` **sechs** ([`spec/spezifikation.md`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5).
  Ein Verifier, der die Zahl gegen den Modul-Text prüft, soll die Differenz hier finden und nicht
  als Abweichung melden. **Diese Differenz stirbt mit der nächsten Baseline** (gemessen
  2026-08-08 gegen den aktuellen Kurs-Stand): die harte Rollen-Liste ist dort entfallen und durch
  *„die Rollen sind die aus Modul 8, festgelegt durch das gestartete Rollen-Artefakt"* ersetzt —
  unser `validator` ist damit gedeckt. Gegen die **gepinnte** Fassung gilt der Satz oben
  unverändert; für den Adaptions-Durchgang der Re-Baseline ist der Ausgang damit vorab benannt:
  *gegenstandslos*. Spans mit leerem `spawned_role` werden nach der
  in [`spec/spezifikation.md`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5
  bindenden Lesevorschrift **aufgeteilt**, nicht als eigene Zeile geführt — und **wie groß der
  aufgeteilte Anteil war, steht im Ergebnis**. Ohne diese Zahl ruht die Bilanz auf einer Regel,
  ohne dass der Leser es sieht. **Dazu die Abdeckungszahl — sie rechnet über dieselbe Menge wie
  die Bilanz:** wie viele der `Agent`-Läufe des Bestands **Zähler trugen**, als Zahl **mit ihrer
  Bezugsmenge** und nicht als nackter Prozentsatz (Momentaufnahme 2026-08-08T14:42Z: **72 von
  95**; die Ziffern wachsen mit dem Bestand, die Aussage ist das Verhältnis). *Gedeckt* heißt
  dabei **Span mit Zählern**, nicht „Span mit irgendeinem erfassten Wert" — die Unterscheidung
  setzt [`spec/spezifikation.md`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder)
  §5 bindend und ausdrücklich *„für jede Abdeckungszahl über diesen Bestand"*. Ohne diese Zahl
  liest sich eine unvollständige Erhebung wie eine vollständige: 23 der 95 Läufe tragen zur
  Bilanz **nichts** bei, und der Leser sähe es nicht.

  **Was diese Zahl nicht sieht, steht neben ihr:** einen Lauf, der **gar keinen** Span
  hinterlassen hat. Zähler und Bezugsmenge stammen aus derselben Quelle; ein fehlender,
  abgeschalteter oder umgangener Guard fällt hier lautlos aus — denselben Zustand hält
  [`spec/spezifikation.md`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5
  Abweichung 5 (3)(b) fest. **Die zweite, unabhängige Quelle liefert dieser Slice nicht**, und der
  Grund ist gemessen statt abgewogen: zwischen dem Start eines Subagenten und dem `Agent`-Span
  seines Aufrufers gibt es **keine Korrelations-Achse** — der `SubagentStart`-Span trägt
  `tool_use_id` **leer** und liegt im Strom des *gestarteten* Agenten, der `Agent`-Span des
  Aufrufers trägt ihn gefüllt und liegt im Haupt-Strom (gemessen 2026-08-08). Ein bloßer
  Mengenvergleich der zwei Quellen unterscheidet den verlorenen Lauf weder vom noch **laufenden**
  noch vom **Hintergrund**-Lauf, der nach §5 Abweichung 5 planmäßig keine Zähler trägt: am
  2026-08-08T14:42Z stünde er bei **2 von 4** — ohne einen einzigen Defekt. Ein Sensor, dessen
  gesunder Stand nicht 100 % ist, meldet nichts. Er gehört samt der Entscheidung über seine Achse
  in [slice-077](../open/slice-077-verlorener-lauf-sichtbar.md).
  Die Abdeckungszahl ist **nicht** der Nenner aus DoD (2): sie misst innerhalb der erfassten
  Teilmenge, jener benennt die Teilmenge selbst.
- [x] **(2) Die Bilanz nennt ihren Nenner — und ein Fall nimmt ihn wieder weg.** Die Ausgabe
  sagt, **worüber** sie rechnet: über **Subagenten-Läufe**, nicht über den Lauf. Der Verbrauch
  des Haupt-Kontexts steht in keiner Payload; ein Prozentsatz aus diesen Zahlen ist damit ein
  Anteil an der **erfassten Teilmenge**, und wer ihn druckt, druckt das dazu. Die Pflicht steht
  in [`spec/spezifikation.md`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5
  Abweichung 6; ihre Begründung und ihre Bindung an einen Wächter stehen in
  [`ADR-0012`](../../adr/0012-haupt-kontext-ohne-token-bilanz.md) — sie gilt unabhängig davon,
  wie über deren Annahme entschieden wird.
  **Zwei Zähne, rot gesehen:** ein Go-Test, der die Angabe in der erzeugten Ausgabe verlangt und
  ohne sie fällt (`make test`), und ein Fall in `test/mutations/`, der die Angabe aus dem
  Auswerter entfernt und diesen Test rot färben muss (`make mutate`). Ein nie angelegter Fall
  erzeugt kein Rot — die Angabe wäre dann eine Absicht.
  **Nicht dasselbe wie der Sammelposten-Anteil aus DoD (1):** der misst, wie viel der Bilanz auf
  der Splitting-Regel ruht; dieser sagt, worüber überhaupt gerechnet wird. Zwei Größen, zwei
  Angaben, zwei Zähne — zusammengelegt geht eine verloren.
- [x] **(3) Die Splitting-Regel des Sammelpostens steht als Festlegung, nicht im Code.** Welche
  Regel gilt (Frage A), gehört nach
  [`spec/spezifikation.md`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5 —
  dort erklärt Abweichung 3 die Regel für den Haupt-Strom als *zu entscheiden* und führt die zwei
  ableitbaren Signale; **wie groß** der aufgeteilte Anteil war, gehört in jedes Ergebnis. Eine
  Regel, die nur im Auswertungs-Code lebt, ist für den Leser der Bilanz unsichtbar. **Der bindende
  Text trägt keine Entscheidungs- und keine Planungs-Kennung** — auch keine nackte
  `slice-`-Kennung, die dort kein Muster trifft und trotzdem verboten ist; ergibt der
  Modul-7-Trichter für die **Wahl** der Regel eine Entscheidung, trägt jene die Begründung und §5
  zeigt aufwärts.
- [x] `make gates` grün, `make mutate` ohne Befund.
- [x] Doku-Update, falls ein öffentlicher Vertrag berührt ist.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

**Voraussetzung, die [slice-060](../done/slice-060-rollen-achse.md) liefert:** die `Agent`-Spans tragen
`spawned_role` (normalisiert), `resolvedModel` und die Nutzungstelemetrie (`usage` mit vier Zählern, `totalTokens`,
`totalDurationMs`, `totalToolUseCount`). **Gemessen am 2026-07-29:** diese Felder kommen **nur
bei Vordergrund-Läufen** an; im Hintergrund trägt die Antwort weder Zähler noch `agentType`, das Feld bleibt also leer. Die
Bilanz deckt damit genau die Läufe ab, die der Konvention aus slice-060 folgen — und **die
Auswertung liest ausschließlich Spans**, kein Zugriff außerhalb des Repos, kein Transkript.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| Auswertung (Go, eigenes Kommando) | neu | Aggregation über die Span-Ströme; dieselbe Linie wie der Emitter — Docker-only gebaut ([`ADR-0003`](../../adr/0003-go-native-binaries.md)), **kein** Subkommando des Produkt-Binaries, damit slice-062 nicht vorweggenommen wird |
| `Makefile` | update | ein `make`-Ziel. **Kein Gate:** eine Bilanz prüft nichts, und ein Gate über einem Bericht wäre eines über leerem Prüfbereich ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)) |
| [`spec/spezifikation.md`](../../../../spec/spezifikation.md) | update | die **Splitting-Regel** des Sammelpostens gehört als Festlegung nach §5, nicht in den Code: technische Festlegung, ohne Vertragsänderung fortschreibbar, mit jedem weiteren Signal wachsend ([Aufnahme-Regel](../../../../spec/spezifikation.md#aufnahme-regel)). **Kein Adaptions-Eintrag:** eine der zwei vom Modul angebotenen Regeln zu wählen weicht von ihm nicht ab |
| `.claude/settings.json` | update | `SubagentStart` ist unter diesem Slice verdrahtet worden: ein Ereignis-Block, dasselbe Binary wie `PostToolUse`, **kein Code** — der Emitter ist ereignis-generisch. **Sein Leser ist nicht DoD (1), sondern [slice-077](../open/slice-077-verlorener-lauf-sichtbar.md)** — die Spans belegen je Spawn den angeforderten Typ und sind die Vorbedingung des dortigen Sensors; die Verdrahtung bleibt deshalb stehen. Ihre Schlüsselmenge ist gemessen und steht in [`spec/spezifikation.md`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5, ihre Herkunft in [`docs/user/claude-hooks-referenz.md`](../../../../docs/user/claude-hooks-referenz.md) §SubagentStart (`agent_type` dort als **Eingabefeld** neben `agent_id`). Berührt die Durchsetzungsschicht ([`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks)) und gehört deshalb in diese Tabelle, nicht in einen stillen Seiteneffekt. **Einen Wächter bekommt die Datei hier nicht:** die Verdrahtung dieses Repos ist in **keinem** Block bewacht — die Lücke ist älter als dieser Slice und breiter als sein Block, und ein Wächter über nur dem neuen wäre die Lücke mit besserem Gewissen. Sie trägt [slice-078](../open/slice-078-verdrahtung-hat-waechter.md) |
| `harness/tools/extract-agent-call.awk` | update | der Kopfkommentar nennt die Abdeckungszahl dieses Slice als *zweite Verteidigungslinie* hinter dem Guard. Das leistet sie nach DoD (1) nicht — sie misst innerhalb derselben Quelle und sieht einen verlorenen Lauf nicht. Der Satz nennt künftig die **Eigenschaft** (ein Sensor über der Erfassung, heute nicht vorhanden) statt einer Planungs-Kennung, die jeder Re-Schnitt falsch macht |
| `test/` + `test/mutations/` | neu | die Zähne aus DoD (1) — Sammelposten-Anteil und Abdeckungszahl — und die zwei aus DoD (2) für die Nenner-Angabe |

**Offen, vor dem Code zu entscheiden:**

| # | Frage | Warum sie den Schnitt entscheidet |
|---|---|---|
| A | ~~Welche **Splitting-Regel** für den Haupt-Strom?~~ **ENTSCHIEDEN (2026-08-03): anteilig nach Tool-Calls**, rollenlose Calls **nicht** im Nenner | Begründung, gegen den realen Bestand gemessen. **Zur Lesart der Zahlen unten: sie sind eine datierte Momentaufnahme, keine Konstanten.** Der Bestand wächst mit jedem Lauf — die Zahlen dieser Zeile haben sich zwischen ihrer Aufnahme und dem Plan-Review bereits bewegt, und das ist kein Defekt, sondern die Natur der Größe. Das Argument hängt an den **Verhältnissen und der Struktur**, nicht an den Ziffern; wer sie prüft, misst neu (`grep` über `.harness/state/spans/*.jsonl`) und erwartet andere Werte. **(1) Die Regel muss Rollen liefern.** Die Lesevorschrift in [`spec/spezifikation.md`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5 setzt als Punkt 1 ihrer Prüfreihenfolge, dass am Ende *jedes Token auf einer der realen Rollen* liegt. *Anteilig nach Tool-Calls* leistet das; *dem auslösenden Slice zugeschlagen* liefert einen **Slice**, und ein Slice läuft durch alle sechs Rollen — das Glied Slice→Rolle liefert das Modul nicht mit. **(2) Das stärkere Signal trägt die schwächere Regel.** Das `slice`-Feld ist gemessen das stärkere Signal — **79/95** über alle `Agent`-Spans, **64/72** unter den zähler-tragenden (Stand 2026-08-08; die Bezugsmenge gehört zur Zahl, beide getrennt genannt, weil sie verschieden sind) —, das Schreibziel deckt nur **176/1012** Haupt-Strom-Spans, und **kein** `Agent`-Span trägt `path`. Es beantwortet trotzdem die falsche Frage: Signal-Stärke ersetzt keine Zuordnung. **(3) Der Schlüssel, Stand 2026-08-08:** implementer 1368 · planner 1323 · reviewer 1093 · architect 449 · verifier 364 Tool-Calls (Summe 4.597). **Rollenlose Calls — zum selben Stand 1.255 — bleiben aus dem Nenner**, sonst verteilte der Sammelposten teilweise auf sich selbst. **(4) Der Sammelposten ist klein, aber nicht mehr leer:** zum Schnitt-Zeitpunkt trug **kein** zähler-tragender `Agent`-Span eine leere Rolle; seit dem 2026-08-08 ist es **einer** — erzeugt ausgerechnet von einem `general-purpose`-Aufruf im **Vordergrund**, also genau der Form, die den Anteil hebt. **Zur Größe dieses Postens gehört die Angabe, WELCHE Größe gemeint ist, und es kommen zwei in Frage:** `total_tokens` enthält die **Cache-Lesungen**, die um Größenordnungen schwerer wiegen als der Rest. Die **Bilanz** summiert dagegen `input_tokens + output_tokens` — so verlangt es DoD (1) und Modul 15 §Token-Attributions-Regeln, und die Cache-Zähler sind Block 3 und damit Gegenstand des Cache-Slice. Derselbe Lauf misst deshalb je nach Größe **21.953** (`total_tokens`) oder **227** (`input+output`); die Bilanz weist die zweite aus und nennt das in ihrer zweiten Ausgabezeile. Die Verhältnis-Aussagen dieser Zeile bleiben gültig, ihre absoluten Beträge sind nicht die der Bilanz. Die Regel hat damit einen realen Gegenstand statt eines gedachten, und die Zahl aus DoD (1) wird von Anfang an ungleich null sein |
| B | ~~Summiert die Bilanz **eine Sitzung** oder den **Bestand**?~~ **ENTSCHIEDEN (2026-08-03): der Bestand** | Gemessen am Ist-Stand (drei Sitzungs-Ströme, 5.624 Spans): **(1) Eine Sitzung trägt keine Rechnung.** Der laufende Strom führt **3** `Agent`-Läufe, ein gemessener Strom führt **2** mit **null** Token — eine Bilanz je Rolle über drei Läufe kann fünf Rollen-Zeilen nicht füllen. Über den Bestand sind es **70** zähler-tragende Läufe. **(2) Eine Sitzung ist kein Arbeitsschnitt:** der größte Strom läuft über fünf Tage und mehrere Commits, die Sitzungs-Grenze ist die Lebensdauer eines Werkzeug-Prozesses, nicht die einer Aufgabe. **(3) Der laufende Strom wächst während der Auswertung** — zwischen zwei Messungen real 5.597 → 5.607 Spans; zwei Aufrufe in derselben Sitzung gäben verschiedene Zahlen. **Der Preis, und er gehört in die Ausgabe:** der weitaus größte Teil der Summe stammt aus **einer** Sitzung, jeder Prozentsatz ist faktisch deren Prozentsatz. **Auch hier gehört die Größe zur Zahl** (Stand 2026-08-08): **96,2 %** gemessen in `input_tokens + output_tokens` — der Größe, die die Bilanz summiert — und **90,8 %** in `total_tokens`. Die Ausgabe nennt deshalb **Sitzungszahl und Zeitraum** — das fällt unter die Nenner-Pflicht aus DoD (2) und ist keine zusätzliche Zusage. `make span-clean` setzt die Basis zurück; auch das macht die Zeitraum-Angabe nötig, nicht optional. **Bindet [slice-071](../open/slice-071-cache-zaehler-getrennt.md) mit:** dort ist es Frage A, und der Plan sieht ausdrücklich vor, dass der zuerst laufende Slice sie für beide entscheidet |

## 4. Trigger

**`open` → `next`:** [slice-060](../done/slice-060-rollen-achse.md) ist **done** — vorher trägt kein Span
eine Rolle (Begründung des Schnitts: [welle-09 §4](../welle-09-modul-15-konformitaet.md)).

**`next` → `in-progress`:** WIP-Limit; dazu **Frage A entschieden**.

Rückführungen:

- `in-progress` → `next`: falls die Splitting-Regel sich als eigene Festlegung mit eigenem
  Wächter erweist.
- `in-progress` → `open`: falls der Bestand Frage B nicht stabil beantwortbar macht (Ströme ohne
  Sitzungs-Grenze).

## 5. Closure-Trigger

DoD vollständig; Review konform (Modul 10) mit **ausgestelltem** Verdikt; Verifikation bestätigt
(Modul 11); `make gates` und `make mutate` grün; `git mv` nach `done/` (eigener Move-Commit,
eingehende Links im Zug danach); Closure-Notiz mit Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **Der Bericht muss eine Aussage treffen, nicht nur Zahlen drucken.** Eine Tabelle aus Summen —
  ohne die größte Rolle als **Zahl und Prozentsatz** und ohne die Größe des aufgeteilten
  Sammelpostens — erfüllt die Token-Attributions-Regeln nicht, sie sieht nur so aus. Die Frage,
  die der Bericht bedienen soll, benennt Modul 15 selbst: *„lässt er sich durch Caching,
  Vorab-Filter oder Kontext-Verdichtung billiger machen?"*
- **Der Haupt-Kontext bleibt unerfasst.** Seine Token erscheinen in keiner Payload; die Bilanz
  kann ihn nur über die Splitting-Regel behandeln. Wie groß dieser Anteil ist, gehört deshalb in
  jedes Ergebnis — sonst liest sich eine Regel wie eine Messung. **Wie groß der Haupt-Kontext
  selbst war, sagt auch dieser Slice nicht:** er liest ausschließlich Spans, und kein Span trägt
  diese Token. Der Sammelposten-Anteil misst den aufgeteilten Teil **innerhalb** der erfassten
  Teilmenge, nicht die Teilmenge gegen den ganzen Lauf.
- **Nicht in diesem Slice:** der Sensor, der einen **verlorenen** Lauf sichtbar macht
  ([slice-077](../open/slice-077-verlorener-lauf-sichtbar.md) — er braucht eine
  Korrelations-Achse, die der Bestand heute nicht trägt); die Cache-Zähler
  ([slice-071](../open/slice-071-cache-zaehler-getrennt.md)),
  die Rollen-Achse ([slice-060](../done/slice-060-rollen-achse.md)), die
  Doku-Konsistenz (slice-061) und die Tool-Ebene (slice-062/063).

## 7. Closure-Notiz (nach `done/`)

**Was gilt.** Aus dem Span-Bestand wird eine Rechnung. `make span-report` schreibt eine
Token-Bilanz je Rolle über `input_tokens + output_tokens`, mit der größten Rolle als Zahl **und**
Prozentsatz. Drei Größen stehen als drei Zeilen nebeneinander und tragen je einen eigenen, rot
gesehenen Zahn: der **Nenner** (gerechnet über Subagenten-Läufe, nicht über den Lauf), der
**Anteil des Sammelpostens** an der Summe und die **Abdeckungszahl mit ihrer Bezugsmenge**. Die
Splitting-Regel des Sammelpostens — anteilig nach Tool-Calls, rollenlose Calls nicht im Nenner,
der Ganzzahl-Rest absteigend weitergegeben, und die Ausnahme, wenn keine reale Rolle Tool-Calls
trägt — steht als Festlegung in
[`spec/spezifikation.md`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5 und
nicht im Auswertungs-Code; ihr bindender Text trägt keine Kennung.

Die Bilanz ist ein **Bericht, kein Sensor**: sie prüft nichts und färbt nichts rot. Deshalb steht
sie in keiner der beiden Gate-Tabellen — ein Gate über ihr wäre eines über leerem Prüfbereich
([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)) —,
sondern im Nicht-Gate-Verify-Absatz von [`AGENTS.md`](../../../../AGENTS.md) §4 und
[`harness/README.md`](../../../../harness/README.md). Sie liest ausschließlich Spans, read-only
und netzlos.

**Sensoren.** `make mutate` läuft mit `145 ok, 0 Befund(e)` über den Baum, den der Abschluss-Commit erzeugt;
zehn seiner Fälle (`test/mutations/140`–`149`) zielen auf den Auswerter, jeder färbt seinen
namentlich erwarteten Wächter rot. **Die Deckung reicht bis an den Move, und das ist eine
Eigenschaft, kein Zufall:** was seit dem Lauf noch angefasst wurde, sind Plan-Artefakte, und
**kein** Mutations-Fall trägt einen `docs/`-Pfad in seiner `# files:`-Zeile — der Prüfbereich des
Sensors und die geänderten Dateien sind disjunkt. Welche Fälle ein Lauf nach einer **Code**-
Änderung mindestens tragen muss, sagt dieselbe Schnittmenge, dann nicht leer: der Prüfumfang aus
dem zweiten Steering-Loop-Eintrag unten. `make gates` grün.

**Was anders lief.**

1. **Geliefert ist mehr, als §3 vorsieht — an fünf Positionen.** Die `report`-Stage im
   `Dockerfile` folgt zwingend aus *Auswertung als eigenes Kommando* plus Docker-only, hat aber
   eine eigene Begründung und keine Plan-Zeile. Drei der fünf `Makefile`-Hunks betreffen
   `span-report` nicht, sondern kürzen Kommentare und reparieren `make help`. Statt der vier
   geplanten Zähne stehen zehn Mutations-Fälle und zehn Go-Tests. Zwei Planner-Artefakte liegen
   im selben Commit-Bereich. Und eine **neue Hard Rule** ([`AGENTS.md`](../../../../AGENTS.md)
   §3.7) samt ihrem Adaptions-Eintrag
   ([`MR-022`](../../../../harness/conventions.md#mr-022--kommentar-regel-als-vorgriff-auf-eine-neuere-baseline))
   ist unter diesem Slice entstanden — eine repo-weite Setzung ohne DoD-Zeile und ohne Übergabe
   an eine zweite Rolle. Wem ein solches Artefakt gehört, entscheidet
   [`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) (Proposed).
   **§3 bleibt der Stand vor dem Code und wird nicht nachgezogen:** eine Tabelle, die im
   Nachhinein zur Lieferung passend gemacht wird, sagt nichts mehr darüber, was geplant war.

2. **Vier Korrekturen an einem Tag landeten an einem von mehreren Fundorten.** Ein Grep-Muster
   nach einem Lifecycle-Move kannte eine der zwei Pfadformen nicht und fand 5 von 15 gebrochenen
   Links; eine Fehlzuschreibung überlebte im Verzeichnis der Entscheidungen; dieselbe
   Ereignis-Menge stand an drei Stellen und wurde an einer gezogen; und die Angabe, in welcher
   Größe ein Prozentsatz gemessen ist, kam an die eine der zwei Stellen, an denen sie fehlte.
   Vier Rollen fanden je eine Instanz — keine fand die eigene.

3. **Ein bestehender Wächter wurde durch eine Code-Korrektur zahnlos.** Die Bedingung, auf die
   `test/mutations/145` mit seinem `sed`-Muster zielt, hat im selben Zug ein zweites Konjunkt
   bekommen; das Muster traf danach nicht mehr. Gegengeprüft worden waren nur die **neu
   angelegten** Fälle.

**Steering-Loop-Einträge.**

1. **Benannte Spec-Lücke — ein Lerneintrag hat keinen vorgeschriebenen Träger und bleibt darum
   liegen, wo ihn niemand liest.** Gemessen über die Notizen unter `done/`, Stand 2026-08-09: die
   drei kanonischen Formen (*geschärfte Regel* · *neuer Sensor* · *benannte Spec-Lücke*) kommen
   dort **57**-mal vor, verteilt auf **32** Dateien — der Bestand wächst mit jedem Abschluss. Das Wort *Lerneintrag* kommt in
   [`AGENTS.md`](../../../../AGENTS.md), [`harness/conventions.md`](../../../../harness/conventions.md),
   [`harness/README.md`](../../../../harness/README.md) und dem Reviewer-Skill **null**mal vor,
   und die Vor-jeder-Änderung-Leseliste aus `CLAUDE.md` führt an `done/` vorbei. Der Beleg steht
   in diesem Slice: die zwei Regeln, gegen die er am häufigsten verstoßen hat — *eine Zahl
   braucht die Größe, in der sie gemessen ist* und *ein Befund nennt einen Fundort, nie die
   Fundmenge* — standen bereits ausformuliert in einer früheren Closure-Notiz
   ([slice-060](../done/slice-060-rollen-achse.md) §7) und hatten keinen lebenden Träger. Der
   Gegenfall steht daneben: eine Regel, die in derselben Sitzung dreimal mündlich durchgesetzt
   wurde, hat einen bekommen — Hard Rule plus Adaptions-Eintrag — und stufte noch am selben Tag
   einen offenen Befund dieses Slice neu ein. **Die Lücke ist nicht die einzelne Regel, sondern
   die fehlende Festlegung, welchen Träger ein Lerneintrag bekommt** (Hard Rule ·
   Adaptions-Eintrag · Skill-Zeile · Zahn) und woran man erkennt, dass er keinen braucht.

2. **Geschärfte Regel — nach einer Code-Änderung ist der Prüfumfang die Menge der Fälle, die auf
   die geänderte Zeile zielen, nicht die Menge der neu angelegten.** Ein Mutations-Fall bindet
   eine **Zeile in ihrer Wortform**; wer die Zeile anfasst, ändert damit stillschweigend das
   Muster jedes Falls, der auf sie zeigt. Die Prüfung ist billig, weil der Sensor dafür schon
   fail-closed ist: `harness/tools/mutate.sh` meldet eine Mutation, die nicht greift, als
   **Befund** statt als *ok* — die Regel kostet einen Lauf, keinen Bau. Sie greift über diesen
   Slice hinaus: jeder Fix an einer bewachten Zeile erbt sie.

**Offen, mit Träger.**

| Posten | Träger |
|---|---|
| Eine repo-weite Hard Rule und ihr Adaptions-Eintrag sind im Implementations-Kontext dieses Slice in Kraft gesetzt worden, ohne Übergabe an eine zweite Rolle | [`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md), Proposed |
| Zwei Mengenangaben in einer Commit-Message treffen den Baum nicht (die Zeilenzahlen der `Makefile`-Kürzung und die Zahl der `make help`-Einträge vor der Reparatur). Die Historie wird nicht umgeschrieben; die gemessenen Werte stehen im Review-Bericht | verfallen, mit Beleg |
| Ein nicht existierender Ablageort liefert dieselbe wohlgeformte leere Bilanz wie ein leerer — `filepath.Glob` unterscheidet beides nicht, und unter `make span-report` maskiert das vorangestellte `mkdir -p` den Fall | [slice-071](../open/slice-071-cache-zaehler-getrennt.md) |
| *„Bestand: 3 Sitzung(en)"* nennt die Ströme des Ablageorts, nicht die Streuung der Summe — zwei tragen Zähler, und der weitaus größte Teil stammt aus einer | [slice-071](../open/slice-071-cache-zaehler-getrennt.md) |
| Der Sensor, der einen Lauf **ohne** Span sichtbar macht — die Abdeckungszahl kann ihn nicht sehen, weil Zähler und Bezugsmenge aus derselben Quelle stammen | [slice-077](../open/slice-077-verlorener-lauf-sichtbar.md) |
| Die Hook-Verdrahtung dieses Repos ist in keinem Block bewacht; `SubagentStart` ist unter diesem Slice dazugekommen und erbt die Lücke | [slice-078](../open/slice-078-verdrahtung-hat-waechter.md) |

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `cmd/`, `internal/`,
`Makefile`, `spec/` und `test/` gehören zum Greenfield-Bestand; der Modus steht in der
Modus-Deklaration von [`harness/conventions.md`](../../../../harness/conventions.md).
