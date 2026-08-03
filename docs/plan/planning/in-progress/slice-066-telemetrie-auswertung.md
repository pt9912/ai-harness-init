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

- [ ] **(1) Token-Bilanz je Rolle, mit ausgesprochenem Sammelposten.** Input- und Output-Token
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
  als Abweichung melden. Spans mit leerem `spawned_role` werden nach der
  in [`spec/spezifikation.md`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5
  bindenden Lesevorschrift **aufgeteilt**, nicht als eigene Zeile geführt — und **wie groß der
  aufgeteilte Anteil war, steht im Ergebnis**. Ohne diese Zahl ruht die Bilanz auf einer Regel,
  ohne dass der Leser es sieht. **Dazu die Abdeckungszahl:** wie viele `Agent`-Spans überhaupt
  Zähler trugen. **Nicht**, weil die Vordergrund-Konvention aus slice-060 sensorlos wäre — sie
  bekommt dort einen `PreToolUse`-Guard —, sondern weil ein Guard **fehlen, abgeschaltet oder
  umgangen** sein kann und ein Hintergrund-Start dann lautlos ausfällt. Ohne diese Zahl liest
  sich eine unvollständige Erhebung wie eine vollständige.
  **Die Bezugsgröße der Abdeckungszahl kommt aus einer anderen Quelle als der Zähler.** Zählte
  die Abdeckungszahl beide Größen aus denselben Spans, prüfte sie sich selbst. Das Ereignis
  **`SubagentStart`** feuert je Spawn und trägt `agent_type` (Referenz, §SubagentStart) — es kann
  nicht blockieren, aber es **zählt**, unabhängig davon, ob der `Agent`-Span Telemetrie trug.
  Erst diese zwei Quellen machen aus der Abdeckungszahl eine Messung statt einer Selbstauskunft.
  Diese Bezugsgröße ist **nicht** der Nenner aus DoD (2): sie zählt Spawns innerhalb der
  erfassten Teilmenge, jener benennt die Teilmenge selbst.
- [ ] **(2) Die Bilanz nennt ihren Nenner — und ein Fall nimmt ihn wieder weg.** Die Ausgabe
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
- [ ] **(3) Die Splitting-Regel des Sammelpostens steht als Festlegung, nicht im Code.** Welche
  Regel gilt (Frage A), gehört nach
  [`spec/spezifikation.md`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5 —
  dort erklärt Abweichung 3 die Regel für den Haupt-Strom als *zu entscheiden* und führt die zwei
  ableitbaren Signale; **wie groß** der aufgeteilte Anteil war, gehört in jedes Ergebnis. Eine
  Regel, die nur im Auswertungs-Code lebt, ist für den Leser der Bilanz unsichtbar. **Der bindende
  Text trägt keine Entscheidungs- und keine Planungs-Kennung** — auch keine nackte
  `slice-`-Kennung, die dort kein Muster trifft und trotzdem verboten ist; ergibt der
  Modul-7-Trichter für die **Wahl** der Regel eine Entscheidung, trägt jene die Begründung und §5
  zeigt aufwärts.
- [ ] `make gates` grün, `make mutate` ohne Befund.
- [ ] Doku-Update, falls ein öffentlicher Vertrag berührt ist.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

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
| `test/` + `test/mutations/` | neu | die Zähne aus DoD (1) — Sammelposten-Anteil und Abdeckungszahl — und die zwei aus DoD (2) für die Nenner-Angabe |

**Offen, vor dem Code zu entscheiden:**

| # | Frage | Warum sie den Schnitt entscheidet |
|---|---|---|
| A | ~~Welche **Splitting-Regel** für den Haupt-Strom?~~ **ENTSCHIEDEN (2026-08-03): anteilig nach Tool-Calls**, rollenlose Calls **nicht** im Nenner | Begründung, gegen den realen Bestand gemessen (5.607 Spans, 170 Dateien, drei Sitzungs-Ströme): **(1) Die Regel muss Rollen liefern.** Die Lesevorschrift in [`spec/spezifikation.md`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5 setzt als Punkt 1 ihrer Prüfreihenfolge, dass am Ende *jedes Token auf einer der realen Rollen* liegt. *Anteilig nach Tool-Calls* leistet das; *dem auslösenden Slice zugeschlagen* liefert einen **Slice**, und ein Slice läuft durch alle sechs Rollen — das Glied Slice→Rolle liefert das Modul nicht mit. **(2) Das stärkere Signal trägt die schwächere Regel.** Das `slice`-Feld ist gemessen besser (76/92 der zähler-tragenden `Agent`-Spans, eindeutig, vier Werte ohne Mehrfachbelegung) als das Schreibziel (156/864 Haupt-Strom-Spans, und **kein** `Agent`-Span trägt `path`) — es beantwortet nur die falsche Frage. Signal-Stärke ersetzt keine Zuordnung. **(3) Der Schlüssel ist gemessen:** implementer 1368 · planner 1323 · reviewer 1004 · architect 449 · verifier 364 Tool-Calls (Summe 4.508). **Rollenlose Calls (1.101 = 864 Haupt-Strom + 236 in `general-purpose`-Subagenten) bleiben aus dem Nenner** — sonst verteilte der Sammelposten teilweise auf sich selbst. **(4) Der heutige Effekt ist null, und das gehört in die Ausgabe, nicht in eine Fußnote:** der Sammelposten misst **0 Spans** (jeder zähler-tragende `Agent`-Span trägt eine Rolle), der aufgeteilte Anteil aus DoD (1) ist damit **0,0 %**. Das ist **kein** Beleg, dass der Fall ausbleibt: 236 Tool-Calls liefen real in rollenlosen Typen — ihre Aufrufe waren Hintergrund-Läufe und tragen gar keine Zähler, fallen also unter Abweichung 5 statt in den Sammelposten |
| B | ~~Summiert die Bilanz **eine Sitzung** oder den **Bestand**?~~ **ENTSCHIEDEN (2026-08-03): der Bestand** | Gemessen am Ist-Stand (drei Sitzungs-Ströme, 5.624 Spans): **(1) Eine Sitzung trägt keine Rechnung.** Der laufende Strom führt **3** `Agent`-Läufe, ein gemessener Strom führt **2** mit **null** Token — eine Bilanz je Rolle über drei Läufe kann fünf Rollen-Zeilen nicht füllen. Über den Bestand sind es **70** zähler-tragende Läufe. **(2) Eine Sitzung ist kein Arbeitsschnitt:** der größte Strom läuft über fünf Tage und mehrere Commits, die Sitzungs-Grenze ist die Lebensdauer eines Werkzeug-Prozesses, nicht die einer Aufgabe. **(3) Der laufende Strom wächst während der Auswertung** — zwischen zwei Messungen real 5.597 → 5.607 Spans; zwei Aufrufe in derselben Sitzung gäben verschiedene Zahlen. **Der Preis, und er gehört in die Ausgabe:** **95,1 %** der Summe stammen aus **einer** Sitzung, jeder Prozentsatz ist faktisch deren Prozentsatz. Die Ausgabe nennt deshalb **Sitzungszahl und Zeitraum** — das fällt unter die Nenner-Pflicht aus DoD (2) und ist keine zusätzliche Zusage. `make span-clean` setzt die Basis zurück; auch das macht die Zeitraum-Angabe nötig, nicht optional. **Bindet [slice-071](../open/slice-071-cache-zaehler-getrennt.md) mit:** dort ist es Frage A, und der Plan sieht ausdrücklich vor, dass der zuerst laufende Slice sie für beide entscheidet |

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
- **Nicht in diesem Slice:** die Cache-Zähler ([slice-071](../open/slice-071-cache-zaehler-getrennt.md)),
  die Rollen-Achse ([slice-060](../done/slice-060-rollen-achse.md)), die
  Doku-Konsistenz (slice-061) und die Tool-Ebene (slice-062/063).

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `cmd/`, `internal/`,
`Makefile`, `spec/` und `test/` gehören zum Greenfield-Bestand; der Modus steht in der
Modus-Deklaration von [`harness/conventions.md`](../../../../harness/conventions.md).
