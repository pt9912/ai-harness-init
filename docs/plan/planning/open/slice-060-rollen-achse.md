# Slice slice-060: Rollen-Achse — rollen-benannte Agenten-Typen und die Nutzungstelemetrie der Subagenten

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-09](../welle-09-modul-15-konformitaet.md) — Vorbedingung von
[slice-066](slice-066-telemetrie-auswertung.md).

**Bezug:** [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) (Baseline ohne
inhaltliche Adaption),
[`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
(das Span-Schema, das dieser Slice **erweitert**),
[`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) (**Accepted** — Festlegung 2, der
fail-closed Default am Werkzeug-Namen, wird um genau ein Werkzeug erweitert),
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (der Emitter
bleibt ein Docker-only gebautes Go-Binary),
[`LH-FA-08`](../../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren)
(die Rollen-Typen sind das **Dogfood**-Gegenstück zu den emittierten Workflow-Commands; ob sie
mitgehen, entscheidet slice-062). Regelwerk-Quelle:
`.harness/baseline/v3.5.2/regelwerk/modul-15-observability.md` §Kernidee und
§Token-Attributions-Regeln sowie `modul-08-agentenrollen.md`.

**Autor:** ai-harness-init-Team (pt9912). **Datum:** 2026-07-29.

---

## 1. Ziel

**Die Rollen-Achse hört auf, leer zu sein.** `agent_role` steht seit slice-059 in jedem Span und
ist in jedem Span leer, weil alle Subagenten unter `general-purpose` laufen. Dieser Slice füllt
sie und erfasst die Nutzungstelemetrie, die im selben Payload eintrifft.

**Warum ein eigener Slice:** ohne gefüllte Rollen hätte eine Token-Bilanz genau zwei namenlose
Eimer — `general-purpose` und den Haupt-Kontext. Das ist eine Summe, keine Rechnung.
[slice-066](slice-066-telemetrie-auswertung.md) setzt hier auf.

## 2. Definition of Done

- [ ] **(1) Rollen-benannte Agenten-Typen, im VORDERGRUND gestartet — und `agent_role` füllt
  sich ohne Änderung an der Erfassung.** Je Harness-Rolle eine Datei `.claude/agents/<name>.md`
  mit Frontmatter (`name`, `description`, `tools`, `model`; der Body wird zum Systemprompt).
  Gestartet wird **per @-Erwähnung** — der Weg, den die Werkzeug-Doku als *„garantiert"* führt,
  während natürliche Sprache die Delegation dem Modell überlässt — **und im Vordergrund**, weil
  im Hintergrund gemessen keine Telemetrie ankommt (§3 Zeile 2). Beides gehört als Konvention in
  [`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung),
  nicht in ein Gedächtnis. **Belegt an einem echten Lauf**, nicht am Test.
- [ ] **(2) `Agent` wird ein namentlich gelistetes Werkzeug — für Zahlen und zwei Kennungen,
  nie für Freitext.** Erfasst werden aus `tool_response`: die vier Zähler aus `usage`,
  `totalTokens`, `totalDurationMs`, `totalToolUseCount`, dazu **`agentType`** (die *tatsächlich
  gelaufene* Rolle — nicht `tool_input.subagent_type`, das nur die Anforderung ist) und
  `resolvedModel` (das Label `model.version`, das Modul 15 §Cache-Counter-Regeln verlangt).
  **Niemals erfasst:** `content`, `prompt`, `description`, `outputFile` — die vier gemessenen
  Freitext-Felder. Jedes erfasste Feld mit Incident-Frage in [`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung); der Zahn ist eine
  Mutation, die **eines dieser vier** in den Span wandern lässt.
- [ ] **(3) Was die Erfassung nicht abdeckt, steht als erklärte Abweichung.** **Gemessen:**
  Hintergrund-Läufe liefern weder Zähler noch `agentType`; und der Haupt-Kontext wird von keinem
  `Agent`-Aufruf umschlossen. Beides gehört benannt, nicht weggelassen
  ([`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) Festlegung 1 Punkt 5).
- [ ] `make gates` grün, `make mutate` ohne Befund.
- [ ] Doku-Update, falls ein öffentlicher Vertrag berührt ist.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

**Ist-Messung (2026-07-29, A/B an zwei echten Agenten-Aufrufen dieses Repos; erfasst wurden nur
Feldnamen und Wertlängen, nie Werte):**

| # | Aufruf | `tool_response` enthält |
|---|---|---|
| 1 | **Vordergrund** (`run_in_background: false`) | `usage` (543 B) mit `input_tokens`, `output_tokens`, `cache_creation_input_tokens`, `cache_read_input_tokens` · `totalTokens` · `totalDurationMs` · `totalToolUseCount` · **`agentType`** · `resolvedModel` · `status` · **`content`**, **`prompt`** |
| 2 | **Hintergrund** (`run_in_background: true`) | `agentId` · `isAsync` · `outputFile` · `canReadOutputFile` · `resolvedModel` · `status` · **`prompt`**, **`description`** — **keine Zähler, kein `agentType`** |
| 3 | beide | `tool_input` trägt `subagent_type`, `prompt`, `description`, `run_in_background` |
| 4 | zwei verschiedene Dauern | `duration_ms` der Payload war **4 ms** (der Hook feuert beim Start), `totalDurationMs` trägt die Laufzeit des Subagenten |
| 5 | die Rollen-Achse ist heute leer | alle Subagenten-Ströme tragen `agent_type: "general-purpose"`, `agent_role: ""` |

**Was daraus folgt:** die Zähler sind erreichbar, **aber nur im Vordergrund**. Daraus wird eine
**Prozess-Bedingung**, keine Erfassungs-Frage — und sie passt zum seriellen Betrieb, den dieses
Repo seit dem 2026-07-29 ohnehin fährt. Die Rolle kommt aus `tool_response.agentType`, **nicht**
aus dem `agent_role` des Spans: der `Agent`-Aufruf ist ein Tool-Call des **Aufrufers**, sein
`agent_role` ist dessen Rolle (im Haupt-Kontext leer).

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `.claude/agents/` | neu | je Harness-Rolle ein Typ. Der Reviewer hat mit `.harness/skills/reviewer.md` bereits seinen Anweisungssatz — der Typ zeigt darauf, eine Quelle |
| `internal/span/` | update | `Agent` in die Werkzeug-Klasse; Zahlen und die zwei Kennungen aus `tool_response` |
| [`harness/conventions.md`](../../../../harness/conventions.md) | update | Werkzeug- und Feldtabelle in [`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung), die Start-Konvention (@-Erwähnung + Vordergrund), die zwei Abweichungen aus DoD (3) |
| `test/` + `test/mutations/` | neu | der Zahn aus DoD (2) |

**Offen, vor dem Code zu entscheiden:**

| # | Frage | Warum sie den Schnitt entscheidet |
|---|---|---|
| B | Bekommen **Ziel-Repos** dieselben Agenten-Typen? | `.claude/commands/` wird emittiert ([`LH-FA-08`](../../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren), `internal/emit/templates/commands/`). Ob `.claude/agents/` mitgeht, entscheidet slice-062 — **hier** ist nur zu vermeiden, dass die Dogfood-Fassung eine Form bekommt, die den Umzug erschwert |

*Entschieden: die **Namen** (`planner` · `architect` · `implementer` · `reviewer` · `verifier` ·
`validator`; Festlegung in [`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung) vom 2026-07-29) und die **Aufnahme von `Agent`** in die
Werkzeug-Tabelle — sie ist Gegenstand dieses Slice, nicht seine Vorfrage.*

## 4. Trigger

**`open` → `next`:** Schnitt steht, Ist-Messung liegt vor, Namen entschieden.

**`next` → `in-progress`:** WIP-Limit — kein anderer Slice in `in-progress/`.

Rückführungen:

- `in-progress` → `next`: falls sich zeigt, dass rollen-benannte Typen die **emittierte** Seite
  zwingend mitziehen. Dann trennt ein Re-Slice die Dogfood-Konvention von der Emission.
- `in-progress` → `open`: falls die Vordergrund-Bedingung den Betrieb spürbar behindert. Dann
  ist erst zu entscheiden, ob die Telemetrie diesen Preis wert ist.

## 5. Closure-Trigger

DoD vollständig; Review konform (Modul 10) mit **ausgestelltem** Verdikt; Verifikation bestätigt
(Modul 11); `make gates` und `make mutate` grün; `git mv` nach `done/` (eigener Move-Commit,
eingehende Links im Zug danach); Closure-Notiz mit Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **`Agent` zu listen erweitert den fail-closed Default**, und die Antwort trägt **vier**
  gemessene Freitext-Felder (`content`, `prompt`, `description`, `outputFile`). Ein Prompt ist in
  [`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) Festlegung 2 namentlich als das
  benannt, was nie ins Log darf. Die Erweiterung trägt nur, wenn der Zahn aus DoD (2) **alle
  vier** abdeckt — eine frühere Fassung dieses Plans deckte nur `content`.
- **Die Vordergrund-Bedingung kostet Parallelität.** Ein Rollen-Lauf blockiert die Hauptschleife.
  Das ist der Preis der Telemetrie und gehört ausgesprochen, nicht versteckt.
- **Eine Rolle, die niemand unter ihrem Typ startet, füllt kein Feld.** Ein Versehen liefert
  `general-purpose` — ein ehrliches „unbekannt", kein falsches Etikett, aber eben keine Rolle.
  Deshalb @-Erwähnung statt natürlicher Sprache.
- **Nicht geeignet: Kommandos, die den Kontext vererben.** `/fork <directive>` startet laut
  Kommando-Referenz *„einen Hintergrund-Subagenten, der das vollständige Gespräch erbt"*;
  `/subtask` beschreibt sich in der CLI-Hilfe als *„Send a subagent off with your full context"*.
  (Ob beide dasselbe Kommando sind, ist **nicht belegt** — für den Ausschluss gleichgültig.)
  Kontext-Vererbung ist das Gegenteil dessen, was Modul 8 für Reviewer und Verifier verlangt —
  *Rollen-Trennung ist Kontext-Trennung*.
- **Nicht in diesem Slice:** die Rechnung ([slice-066](slice-066-telemetrie-auswertung.md)) und
  die Emission (slice-062/063).

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `.claude/`, `internal/`
und `test/` gehören zum Greenfield-Bestand; der Modus steht in der Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md).
