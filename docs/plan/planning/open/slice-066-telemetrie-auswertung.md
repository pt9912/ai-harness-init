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
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (die Auswertung
bleibt ein Docker-only gebautes Go-Binary). Regelwerk-Quelle:
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
  summiert **je Rolle** — die Rolle steht in den `Agent`-Spans als `agentType` (die *tatsächlich
  gelaufene*), nicht im `agent_role` desselben Spans, das die Rolle des **Aufrufers** trägt.
  Die größte Rolle als **Zahl und Prozentsatz** der Gesamtsumme
  (Modul 15 §Token-Attributions-Regeln, wörtlich). Spans mit leerem `agent_role` werden nach der
  in [`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
  bindenden Lesevorschrift **aufgeteilt**, nicht als eigene Zeile geführt — und **wie groß der
  aufgeteilte Anteil war, steht im Ergebnis**. Ohne diese Zahl ruht die Bilanz auf einer Regel,
  ohne dass der Leser es sieht.
- [ ] **(2) Cache-Zähler getrennt, mit den Labels, die die Regel verlangt.**
  `cache_creation_input_tokens` und `cache_read_input_tokens` werden **nie** zu einer Zahl
  verrechnet. Modul 15 §Cache-Counter-Regeln verlangt als Labels mindestens `slice.id`,
  `agent.role` und **`model.version`** — letzteres liegt als `resolvedModel` in denselben Spans;
  eine frühere Fassung dieses Plans hatte die Achse übersehen.
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
`agentType`, `resolvedModel` und die Nutzungstelemetrie (`usage` mit vier Zählern, `totalTokens`,
`totalDurationMs`, `totalToolUseCount`). **Gemessen am 2026-07-29:** diese Felder kommen **nur
bei Vordergrund-Läufen** an; im Hintergrund trägt die Antwort weder Zähler noch `agentType`. Die
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
| A | Welche **Splitting-Regel** für den Haupt-Strom? | Er trägt keinen `agent_type` und wird von keinem `Agent`-Aufruf umschlossen — er bleibt der Sammelposten, auch nach slice-060. Modul 15 nennt zwei Kandidaten (anteilig nach Tool-Calls; dem auslösenden Slice zugeschlagen); zwei Signale liegen im Span (`slice`, Schreibziel). Die Wahl ist zu **begründen**, nicht bloß zu treffen |
| B | Summiert die Bilanz **eine Sitzung** oder den **Bestand**? | Im Ablageort liegen Ströme mehrerer Sitzungen. Die Antwort ändert jede Zahl — und `make span-clean` ändert sie erneut |

## 4. Trigger

**`open` → `next`:** [slice-060](slice-060-rollen-achse.md) ist **done** — vorher trägt kein Span
eine Rolle, und die Bilanz hätte zwei namenlose Eimer.

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
