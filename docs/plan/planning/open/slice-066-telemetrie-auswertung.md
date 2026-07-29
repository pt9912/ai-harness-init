# Slice slice-066: Telemetrie-Auswertung — Token-Bilanz je Rolle und getrennte Cache-Zähler

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-09](../welle-09-modul-15-konformitaet.md) — Blöcke 2–3, setzt auf
[slice-060](slice-060-rollen-achse.md) auf.

**Bezug:** [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) (Baseline ohne
inhaltliche Adaption — Modul 15 ist adoptiert und in den Blöcken 2–3 unumgesetzt),
[`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
(das Span-Schema, das dieser Slice **liest**, samt der dort bindenden Lesevorschrift zum
Sammelposten),
[`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) (**Accepted** — die Policy, unter
der der ausgewertete Bestand entstanden ist; die ADR nennt den Auswerter dreimal „slice-060",
gemeint ist seit dem Schnitt **dieser** Slice, verankert in
[`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)),
[`ADR-0003`](../../adr/0003-go-native-binaries.md) (**Accepted** — die Auswertung ist ein
Go-Binary, Docker-only gebaut),
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (dieselbe Zusage
auf der **Dogfood-Ebene**: das Werkzeug dieses Repos, nicht das emittierte Zielprojekt).
Regelwerk-Quelle:
`.harness/baseline/v3.5.2/regelwerk/modul-15-observability.md`
§Token-Attributions-Regeln und §Cache-Counter-Regeln.

**Autor:** ai-harness-init-Team (pt9912). **Datum:** 2026-07-29.

---

## 1. Ziel

**Aus den erfassten Spans wird eine Rechnung:** wer hat wie viel verbraucht, und was hat der
Cache getragen. Kein Dashboard, kein Zeitreihen-Speicher — eine Auswertung über den vorhandenen
Bestand, aufrufbar als `make`-Ziel.

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
  `validator` **sechs** ([`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)).
  Ein Verifier, der die Zahl gegen den Modul-Text prüft, soll die Differenz hier finden und nicht
  als Abweichung melden. Spans mit leerem `spawned_role` werden nach der
  in [`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
  bindenden Lesevorschrift **aufgeteilt**, nicht als eigene Zeile geführt — und **wie groß der
  aufgeteilte Anteil war, steht im Ergebnis**. Ohne diese Zahl ruht die Bilanz auf einer Regel,
  ohne dass der Leser es sieht. **Dazu die Abdeckungszahl:** wie viele `Agent`-Spans überhaupt
  Zähler trugen. **Nicht**, weil die Vordergrund-Konvention aus slice-060 sensorlos wäre — sie
  bekommt dort einen `PreToolUse`-Guard —, sondern weil ein Guard **fehlen, abgeschaltet oder
  umgangen** sein kann und ein Hintergrund-Start dann lautlos ausfällt. Ohne diese Zahl liest
  sich eine unvollständige Erhebung wie eine vollständige. (Eine frühere Fassung behauptete hier
  das Gegenteil von slice-060 — der Satz war in slice-060 zurückgezogen und hier stehen
  geblieben.)
  **Der Nenner kommt aus einer anderen Quelle als der Zähler.** Zählte die Abdeckungszahl beide
  Größen aus denselben Spans, prüfte sie sich selbst. Das Ereignis **`SubagentStart`** feuert je
  Spawn und trägt `agent_type` (Referenz, §SubagentStart) — es kann nicht blockieren, aber es
  **zählt**, unabhängig davon, ob der `Agent`-Span Telemetrie trug. Erst diese zwei Quellen
  machen aus der Abdeckungszahl eine Messung statt einer Selbstauskunft.
- [ ] **(2) Cache-Zähler getrennt — mit allen vier Angaben, die die Regel je Counter verlangt.**
  `cache_creation_input_tokens` und `cache_read_input_tokens` werden **nie** zu einer Zahl
  verrechnet. Modul 15 §Cache-Counter-Regeln stellt **vier** Fragen je Counter, und alle vier
  gehören beantwortet — eine frühere Fassung dieses Plans nahm nur die **Labels** auf:
  1. **Name** — `prompt_cache_hits_total`, `prompt_cache_misses_total`,
     `prompt_cache_input_tokens_total`. Ausgeschrieben, damit die Bilanz und eine spätere
     Metrik-Ausleitung denselben Namen führen.
  2. **Unit/Cardinality** — alle drei **Counter** (monoton, Einheit Token), nicht Gauge und nicht
     Histogram: sie summieren einen Bestand, sie messen keinen Momentanwert und keine Verteilung.
  3. **Labels** — mindestens `slice.id`, `agent.role`, **`model.version`**; letzteres liegt als
     `resolvedModel` in denselben Spans.
  4. **Aggregation** — `hits / (hits + misses)`, und **wo die Division läuft**. Hier: im
     Auswerter, weil dieses Repo weder Metrik-DB noch Dashboard hat. Das ist zu **sagen**, nicht
     stillschweigend zu tun. **Und welcher Zähler welcher ist, steht hier und nicht nur in der
     Welle:** `hits` = `cache_read_input_tokens` (aus dem Cache gelesen),
     `misses` = `cache_creation_input_tokens` (in den Cache geschrieben, also gerade **nicht**
     getroffen).

  **Und die Zahl stimmt nicht:** das Modul spricht von **drei** Countern, die Payload liefert
  **zwei** (`cache_creation_input_tokens`, `cache_read_input_tokens`). Der dritte ist die
  Token-Eingabe-Metrik, gegen die das Modul den Miss-Spike erkennt (*„Anstieg der
  Token-Eingabe-Metrik ohne Anstieg der Cache-Hit-Rate"*) — sie liegt als `input_tokens` in
  derselben `usage`. **Deklarierte Entscheidung:** alle drei werden geführt; eine einzelne
  `cache.hit_ratio` reicht ausdrücklich nicht, weil sie Kosten- und Sicherheits-Indikator
  vermischt.
  **Auflösungs-Trigger je Deklaration** (welle-09 verlangt ihn für jede): die Namen und die
  Counter-Form werden neu entschieden, **sobald dieses Repo eine Metrik-Senke bekommt** — dann
  wandert die Division dorthin und die Namen müssen deren Konvention folgen. Bis dahin gilt die
  Festlegung unverändert.
- [ ] **(3) Die Splitting-Regel des Sammelpostens steht als Festlegung, nicht im Code.** Welche
  Regel gilt (Frage A) und **wie groß** der aufgeteilte Anteil war, gehört nach
  [`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
  bzw. in jedes Ergebnis. Eine Regel, die nur im Auswertungs-Code lebt, ist für den Leser der
  Bilanz unsichtbar.
- [ ] `make gates` grün, `make mutate` ohne Befund.
- [ ] Doku-Update, falls ein öffentlicher Vertrag berührt ist.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

**Voraussetzung, die [slice-060](slice-060-rollen-achse.md) liefert:** die `Agent`-Spans tragen
`spawned_role` (normalisiert), `resolvedModel` und die Nutzungstelemetrie (`usage` mit vier Zählern, `totalTokens`,
`totalDurationMs`, `totalToolUseCount`). **Gemessen am 2026-07-29:** diese Felder kommen **nur
bei Vordergrund-Läufen** an; im Hintergrund trägt die Antwort weder Zähler noch `agentType`, das Feld bleibt also leer. Die
Bilanz deckt damit genau die Läufe ab, die der Konvention aus slice-060 folgen — und **die
Auswertung liest ausschließlich Spans**, kein Zugriff außerhalb des Repos, kein Transkript.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| Auswertung (Go, eigenes Kommando) | neu | Aggregation über die Span-Ströme; dieselbe Linie wie der Emitter — Docker-only gebaut ([`ADR-0003`](../../adr/0003-go-native-binaries.md)), **kein** Subkommando des Produkt-Binaries, damit slice-062 nicht vorweggenommen wird |
| `Makefile` | update | ein `make`-Ziel. **Kein Gate:** eine Bilanz prüft nichts, und ein Gate über einem Bericht wäre eines über leerem Prüfbereich ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)) |
| [`harness/conventions.md`](../../../../harness/conventions.md) | update | die **Splitting-Regel** des Sammelpostens gehört als Festlegung dorthin, nicht in den Code |
| `test/` + `test/mutations/` | neu | die Zähne aus DoD (1) und (2) |

**Offen, vor dem Code zu entscheiden:**

| # | Frage | Warum sie den Schnitt entscheidet |
|---|---|---|
| A | Welche **Splitting-Regel** für den Haupt-Strom? | Er trägt kein `spawned_role` und wird von keinem `Agent`-Aufruf umschlossen — er bleibt der Sammelposten, auch nach slice-060. Modul 15 nennt zwei Kandidaten (anteilig nach Tool-Calls; dem auslösenden Slice zugeschlagen); zwei Signale liegen im Span (`slice`, Schreibziel). Die Wahl ist zu **begründen**, nicht bloß zu treffen |
| B | Summiert die Bilanz **eine Sitzung** oder den **Bestand**? | Im Ablageort liegen Ströme mehrerer Sitzungen. Die Antwort ändert jede Zahl — und `make span-clean` ändert sie erneut |

## 4. Trigger

**`open` → `next`:** [slice-060](slice-060-rollen-achse.md) ist **done** — vorher trägt kein Span
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
  jedes Ergebnis — sonst liest sich eine Regel wie eine Messung.
- **Nicht in diesem Slice:** die Rollen-Achse ([slice-060](slice-060-rollen-achse.md)), die
  Doku-Konsistenz (slice-061) und die Tool-Ebene (slice-062/063).

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `cmd/`, `internal/`,
`Makefile` und `test/` gehören zum Greenfield-Bestand; der Modus steht in der
Modus-Deklaration von [`harness/conventions.md`](../../../../harness/conventions.md).
