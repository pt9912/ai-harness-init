# Slice slice-060: Telemetrie-Auswertung — Token-Bilanz je Rolle und getrennte Cache-Zähler

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-09](../welle-09-modul-15-konformitaet.md) — zweiter Slice, Blöcke 2–3.

**Bezug:** [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) (Baseline ohne
inhaltliche Adaption — Modul 15 ist adoptiert und in den Blöcken 2–3 unumgesetzt),
[`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
(das Span-Schema, das dieser Slice **liest** — samt der dort bindenden Lesevorschrift zum
Sammelposten),
[`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) (**Accepted** — Festlegung 1.4
*„Ableiten schlägt deklarieren"* gilt auch hier),
Regelwerk-Quelle: `.harness/baseline/v3.5.2/regelwerk/modul-15-observability.md`
§Token-Attributions-Regeln und §Cache-Counter-Regeln.

**Autor:** ai-harness-init-Team (pt9912). **Datum:** 2026-07-29.

---

## 1. Ziel

**Aus den erfassten Spans wird eine Rechnung.** slice-059 hat die Erfassung gebaut; sie liegt
seit dem 2026-07-28 produktiv vor. Dieser Slice beantwortet die zwei Fragen, für die sie da
ist: **wer hat wie viel verbraucht** (Token je Rolle) und **was hat der Cache getragen**
(Erzeugung und Treffer, getrennt).

Kein Dashboard, kein Zeitreihen-Speicher. Eine Auswertung über den vorhandenen Bestand,
aufrufbar als `make`-Ziel.

## 2. Definition of Done

- [ ] **(1) Token-Bilanz je Rolle, mit ausgesprochenem Sammelposten.** Input- und Output-Token
  summiert **je `agent.role`**, die größte Rolle als **Zahl und Prozentsatz** der Gesamtsumme
  (Modul 15 §Token-Attributions-Regeln, wörtlich). Die Spans mit leerem `agent_role` werden
  nach der in
  [`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
  bindenden Lesevorschrift **aufgeteilt**, nicht als eigene Zeile geführt — und **wie groß der
  aufgeteilte Anteil war, steht im Ergebnis**. Ohne diese Zahl ruht die Bilanz auf einer Regel,
  ohne dass der Leser es sieht.
- [ ] **(2) Cache-Zähler getrennt.** `cache_creation_input_tokens` und
  `cache_read_input_tokens` werden **nie** zu einer Zahl verrechnet. Der Grund ist gemessen und
  nicht formal: im Ist-Bestand steht `cache_read` bei 711 Mio. gegen 2.715 `input` — wer sie
  zusammenwirft, verliert genau die Struktur, die die Regel sichtbar machen will.
- [ ] **(3) Die Rollen-Achse füllt sich, ohne die Erfassung zu ändern.** Rollen-benannte
  Agenten-Typen (`reviewer`, `verifier`, …) statt `general-purpose`; `agent_role` wird dann von
  `roleFromAgentType` **abgeleitet** — kein neues Feld, kein zweiter Mechanismus. Belegt an einem
  echten Lauf, nicht am Test.
- [ ] `make gates` grün, `make mutate` ohne Befund.
- [ ] Doku-Update, falls ein öffentlicher Vertrag berührt ist.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

**Ist-Messung (2026-07-29, an den realen Transkripten dieses Repos):**

| # | Aussage | Beleg |
|---|---|---|
| 1 | Das Transkript trägt **alle vier** benötigten Zähler | `usage`-Schlüssel gemessen: `input_tokens`, `output_tokens`, `cache_creation_input_tokens`, `cache_read_input_tokens` (dazu `service_tier`, `speed`, `iterations`, `server_tool_use`) |
| 2 | Die Größenordnung im Haupt-Transkript | 1.447 Nachrichten mit `usage`: `input` 2.715 · `output` 1.978.731 · `cache_creation` 14.604.976 · **`cache_read` 711.785.260** |
| 3 | Subagenten haben **eigene** Transkripte | 18 Dateien unter `…/subagents/agent-<id>.jsonl`, je mit eigenen Zählern (Stichprobe: 28k–77k Output, 5–12 Mio. Cache-Treffer) |
| 4 | Die Zähler stehen in `tool_response` eines **`Agent`**-Aufrufs | vendored Werkzeug-Doku `docs/user/claude-hooks-referenz.md`: `usage` mit den vier Zählern, dazu `totalTokens`, `totalDurationMs`, `totalToolUseCount`, `agentId`, `resolvedModel` |
| 5 | Eine Brücke Span → Transkript gibt es **nicht mehr** | der Zeiger `transcript` ist am 2026-07-29 aus dem Schema entfernt worden, samt dem Lesen des Feldes (Entscheidung des Auftraggebers; [`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung) Abweichung 1). Die Strom-Kennung `(session, agent)` entspräche zwar weiterhin dem Dateinamen — aber das ist eine Ableitung über eine Datei, die zu lesen nicht genehmigt ist |
| 6 | Die Rollen-Achse ist heute **leer** | alle Subagenten-Ströme tragen `agent_type: "general-purpose"`, `agent_role: ""` — Reviewer und Verifier sind in den Daten ununterscheidbar |

**Was daraus für den Schnitt folgt:** die Zähler kommen **aus der Payload** — genauer aus
`tool_response` der `Agent`-Aufrufe (Frage D). Die Auswertung braucht damit **keinen Zugriff
außerhalb des Repos**, und `agentId` verknüpft die Zahlen mit dem Strom des Subagenten. Zusammen
mit DoD (3) ist die Bilanz **je Rolle** für alle Subagenten-Rollen rechenbar. Offen bleiben zwei
Ränder: der Haupt-Kontext (Frage E) und die Schema-Erweiterung, die den Zugriff überhaupt
erlaubt (Frage F).

Der zweite Arbeitsanteil bleibt unabhängig davon bestehen: DoD (3) — ohne gefüllte Rollen-Achse
wäre jede Bilanz eine Summe über einen einzigen Sammelposten, und Modul 15 verlangt die
Aufteilung, nicht die Summe.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| Auswertung (Go, eigenes Kommando) | neu | Aggregation über zwei JSONL-Quellen (Spans + Transkripte); dieselbe Linie wie der Emitter — Docker-only gebaut ([`ADR-0003`](../../adr/0003-go-native-binaries.md)), **kein** Subkommando des Produkt-Binaries, damit slice-062 nicht vorweggenommen wird |
| `Makefile` | update | ein `make`-Ziel für die Auswertung. **Kein Gate:** eine Bilanz prüft nichts, und ein Gate über einem Bericht wäre ein Gate über leerem Prüfbereich ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)) |
| Rollen-benannte Agenten-Typen | neu | DoD (3). Betrifft die Art, wie Rollen **gestartet** werden — eine Prozess-Entscheidung, die sich in den Daten niederschlägt, ohne die Erfassung anzufassen |
| [`harness/conventions.md`](../../../../harness/conventions.md) | update | die **Splitting-Regel** des Sammelpostens gehört als Festlegung dorthin, nicht in den Code der Auswertung |
| `test/` + `test/mutations/` | neu | die Zähne aus DoD (1) und (2) |

**Offen, vor dem Code zu entscheiden:**

| # | Frage | Warum sie den Schnitt entscheidet |
|---|---|---|
| A | Welche **Splitting-Regel** für den Haupt-Strom? | Modul 15 nennt zwei Kandidaten (anteilig nach Tool-Calls; dem auslösenden Slice zugeschlagen). Zwei Signale liegen bereits im Span: das `slice`-Feld (Lifecycle-Verzeichnis, WIP-Limit 1) und das Schreibziel (`docs/plan/**` gegen Code-Pfade). Die Wahl ist zu **begründen**, nicht zu treffen. **DoD (3) löst diese Frage nicht mit:** der Haupt-Strom trägt strukturell keinen `agent_type`, bleibt also auch mit rollen-benannten Agenten-Typen ein Sammelposten |
| B | Token je **Span** oder je **Nachricht**? | Die Zähler hängen an Transkript-Nachrichten, die Rollen an Strömen. Eine Zuordnung Token→Tool-Call gibt es nicht — ob sie geschätzt wird (und wie sichtbar) oder ob die Bilanz auf Strom-Ebene bleibt, ist eine Genauigkeits-Zusage |
| C | Was passiert mit **fremden** Transkripten? | Der Bestand enthält 18 Subagenten-Transkripte aus mehreren Sitzungen. Ob die Bilanz eine Sitzung oder den Bestand summiert, ändert jede Zahl |
| **D** | **Woher kommen die Token- und Cache-Zähler überhaupt?** | **Beantwortet am 2026-07-29 an der vendored Werkzeug-Doku** (`docs/user/claude-hooks-referenz.md`): sie liegen **in der Hook-Payload**, nicht im Transkript — aber nicht auf oberster Ebene, sondern **in `tool_response` eines `Agent`-Aufrufs**: *„In `PostToolUse` trägt `tool_response` für einen abgeschlossenen Agent-Aufruf den abschließenden Text des Subagenten zusammen mit Nutzungstelemetrie."* Dort stehen `usage` (`input_tokens`, `output_tokens`, `cache_creation_input_tokens`, `cache_read_input_tokens`), dazu `totalTokens`, `totalDurationMs`, `totalToolUseCount`, `agentId` und `resolvedModel`. **Damit braucht die Auswertung keinen Zugriff außerhalb des Repos.** Meine erste Messung sah es nicht, weil sie nur die **obersten** Schlüssel zählte — `tool_response` erschien als Größe, nicht als Struktur |
| **E** | **Was fehlt trotzdem?** | Der **Haupt-Kontext**. Ihn umschließt kein `Agent`-Aufruf; seine Token erscheinen in keiner Payload. Er bleibt der Sammelposten — Frage A wird dadurch nicht kleiner, betrifft aber nur noch diese eine Lücke. Für **Hintergrund**-Subagenten gilt dasselbe: die Doku sagt, `tool_response` trage dann *keine* Nutzungsfelder, sondern nur `status: "async_launched"` |
| **F** | **Darf `Agent` ein gelistetes Werkzeug werden?** | Für (D) muss der Emitter **in** `tool_response` hineinlesen — heute nimmt er davon nur die Länge. `Agent` würde damit ein namentlich gelistetes Werkzeug in der [`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)-Tabelle, das **Zahlen** aus seiner Antwort zieht, nie Text. Das ist die gewohnte Linie (abgeleitete Werte statt roher), aber eine **Erweiterung des fail-closed Defaults** — also eine Entscheidung mit eigener Incident-Frage und eigenem Zahn |

## 4. Trigger

**`open` → `next`:** der Schnitt steht und die Ist-Messung liegt vor (beides seit 2026-07-29);
die Fragen A–C sind benannt und im Plan verortet.

**`next` → `in-progress`:** WIP-Limit — kein anderer Slice in `in-progress/`. Dazu **Frage D
beantwortet**: solange die Herkunft der Zähler offen ist, hat der Slice keinen Gegenstand. Und
**Frage A entschieden** (die Splitting-Regel ist eine Festlegung, keine Implementierungs-Wahl).

Rückführungen:

- `in-progress` → `next`: falls DoD (3) sich als eigener Zuschnitt erweist — rollen-benannte
  Agenten-Typen berühren die Art, wie **alle** Rollen gestartet werden, und damit die emittierten
  Kommandos. Dann trennt ein Re-Slice die Auswertung (rechnen) von der Rollen-Achse (Konvention).
- `in-progress` → `open`: falls sich zeigt, dass Token nicht ohne Schätzung auf Rollen abbildbar
  sind. Dann ist erst zu entscheiden, welche Genauigkeit die Bilanz zusagen darf — eine
  Normativ-Frage, kein Rechen-Detail.

## 5. Closure-Trigger

DoD vollständig; Review konform (Modul 10) mit **ausgestelltem** Verdikt; Verifikation bestätigt
die DoD (Modul 11); `make gates` und `make mutate` grün; `git mv` nach `done/` (eigener
Move-Commit, eingehende Links im Zug danach); Closure-Notiz mit Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **Der Bericht muss eine Aussage treffen, nicht nur Zahlen drucken.** Eine Tabelle aus
  Summen — ohne die größte Rolle als **Zahl und Prozentsatz** und ohne die Größe des
  aufgeteilten Sammelpostens — erfüllt die Token-Attributions-Regeln nicht, sie sieht nur so
  aus. Die Frage, die der Bericht bedienen soll, benennt Modul 15 selbst: *„lässt er sich durch
  Caching, Vorab-Filter oder Kontext-Verdichtung billiger machen?"*

- **Nicht in diesem Slice:** die Tool-Ebene (slice-062/063 entscheiden und emittieren) und der
  vierte Modul-15-Block (Doku-Konsistenz, slice-061).

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `cmd/`, `internal/`,
`Makefile` und `test/` gehören zum Greenfield-Bestand dieses Repos; der Modus steht in der
Modus-Deklaration von [`harness/conventions.md`](../../../../harness/conventions.md).
