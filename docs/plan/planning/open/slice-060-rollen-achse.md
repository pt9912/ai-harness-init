# Slice slice-060: Rollen-Achse — rollen-benannte Agenten-Typen und die Nutzungstelemetrie der Subagenten

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-09](../welle-09-modul-15-konformitaet.md) — zweiter Slice, Vorbedingung von
[slice-066](slice-066-telemetrie-auswertung.md).

**Bezug:** [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) (Baseline ohne
inhaltliche Adaption),
[`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
(das Span-Schema, das dieser Slice **erweitert** — Werkzeug-Tabelle und Feldtabelle),
[`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) (**Accepted** — Festlegung 2, der
fail-closed Default am Werkzeug-Namen, wird hier um genau ein Werkzeug erweitert).
Regelwerk-Quelle: `.harness/baseline/v3.5.2/regelwerk/modul-15-observability.md`
§Kernidee (die vier Korrelations-IDs) und §Token-Attributions-Regeln.

**Autor:** ai-harness-init-Team (pt9912). **Datum:** 2026-07-29.

---

## 1. Ziel

**Die Rollen-Achse hört auf, leer zu sein.** `agent_role` steht seit slice-059 in jedem Span —
und ist in jedem Span leer, weil alle Subagenten unter `general-purpose` laufen. Dieser Slice
füllt sie und erfasst zugleich die Nutzungstelemetrie, die im selben Payload eintrifft.

**Warum das ein eigener Slice ist:** ohne gefüllte Rollen hätte eine Token-Bilanz genau zwei
namenlose Eimer — `general-purpose` und den Haupt-Kontext. Das ist eine Summe, keine Rechnung.
Die Auswertung ([slice-066](slice-066-telemetrie-auswertung.md)) setzt hier auf.

## 2. Definition of Done

- [ ] **(1) Rollen-benannte Agenten-Typen, und `agent_role` füllt sich ohne Änderung an der
  Erfassung.** Je Harness-Rolle eine Datei `.claude/agents/<name>.md` mit Frontmatter
  (`name`, `description`, `tools`, `model`; der Body wird zum Systemprompt). Gestartet wird
  **per @-Erwähnung** — die Werkzeug-Doku führt sie als den Weg, der *„garantiert, dass der
  Subagent für eine Aufgabe ausgeführt wird"*; natürliche Sprache überlässt die Delegation
  dem Modell. `roleFromAgentType` leitet `agent_role` daraus ab — kein neues Feld, kein
  zweiter Mechanismus. **Belegt an einem echten Lauf**, nicht am Test.
- [ ] **(2) `Agent` wird ein namentlich gelistetes Werkzeug — für ZAHLEN, nie für Text.** Aus
  `tool_response` werden `usage` (vier Zähler), `totalTokens`, `totalDurationMs` und
  `totalToolUseCount` erfasst, aus `tool_input` der `subagent_type`; der Antworttext des
  Subagenten **nicht**. Jedes Feld mit Incident-Frage in
  [`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung),
  dazu ein **rot gesehener** Zahn: eine Mutation, die den Antworttext in den Span wandern lässt.
- [ ] **(3) Was die Erfassung NICHT abdeckt, steht als erklärte Abweichung.** Der Haupt-Kontext
  trägt keinen `agent_type` und wird von keinem `Agent`-Aufruf umschlossen; **Hintergrund**-
  Subagenten liefern laut Werkzeug-Doku keine Nutzungsfelder (`status: "async_launched"`). Beides
  gehört benannt, nicht weggelassen ([`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md)
  Festlegung 5).
- [ ] `make gates` grün, `make mutate` ohne Befund.
- [ ] Doku-Update, falls ein öffentlicher Vertrag berührt ist.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

**Ist-Messung (2026-07-29):**

| # | Aussage | Beleg |
|---|---|---|
| 1 | Die Rollen-Achse ist **leer**, nicht fehlend | alle Subagenten-Ströme tragen `agent_type: "general-purpose"`, `agent_role: ""` — Reviewer und Verifier sind in den Daten ununterscheidbar |
| 2 | Zähler **und** Rolle treffen im **selben** Payload ein | vendored Referenz `docs/user/claude-hooks-referenz.md`: `tool_response` eines abgeschlossenen `Agent`-Aufrufs trägt `usage` (`input_tokens`, `output_tokens`, `cache_creation_input_tokens`, `cache_read_input_tokens`), `totalTokens`, `totalDurationMs`, `totalToolUseCount`, `agentId`, `resolvedModel`; `tool_input` trägt `subagent_type` |
| 3 | Der Emitter nimmt davon heute **nur die Länge** | `result_bytes` ist die Größe der JSON-Kodierung; `Agent` ist kein gelistetes Werkzeug und gibt nur Name und Status preis |
| 4 | `agentId` verknüpft die Zahlen mit dem **Strom** des Subagenten | der Strom-Name ist `(session, agent)`; `agentId` aus der Antwort ist dieselbe Kennung |

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `.claude/agents/` | neu | je Harness-Rolle ein Agenten-Typ. Der Reviewer hat mit `.harness/skills/reviewer.md` bereits seinen Anweisungssatz — der Typ zeigt darauf, eine Quelle |
| `internal/span/` | update | `Agent` in die Werkzeug-Klasse aufnehmen; Zahlen aus `tool_response`, `subagent_type` aus `tool_input` |
| [`harness/conventions.md`](../../../../harness/conventions.md) | update | Werkzeug-Tabelle und Feldtabelle in [`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung); die zwei Abweichungen aus DoD (3) |
| `test/` + `test/mutations/` | neu | der Zahn aus DoD (2): der Antworttext darf den Span nie erreichen |

**Offen, vor dem Code zu entscheiden:**

| # | Frage | Warum sie den Schnitt entscheidet |
|---|---|---|
| ~~A~~ | ~~Welche **Namen** tragen die Agenten-Typen?~~ | **Entschieden am 2026-07-29: `implementer`** — kurz, gleichförmig mit den übrigen fünf und bereits im Code. Modul 8 nennt die Rolle *Implementation*; die Abweichung ist eine **Schreibweise**, keine Rollen-Änderung, und steht als Festlegung in [`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung), nicht im Code |
| B | Bekommen **Ziel-Repos** dieselben Typen? | `.claude/commands/` wird emittiert (`internal/emit/templates/commands/`). Ob `.claude/agents/` mitgeht, ist eine Entscheidung von slice-062 — **hier** ist nur zu vermeiden, dass die Dogfood-Fassung eine Form bekommt, die den Umzug erschwert |

## 4. Trigger

**`open` → `next`:** Schnitt steht, Ist-Messung liegt vor.

**`next` → `in-progress`:** WIP-Limit — kein anderer Slice in `in-progress/`. **Frage A ist
entschieden** (2026-07-29), damit ist dies die einzige verbleibende Bedingung.

Rückführungen:

- `in-progress` → `next`: falls sich zeigt, dass rollen-benannte Typen die **emittierte** Seite
  zwingend mitziehen. Dann trennt ein Re-Slice die Dogfood-Konvention von der Emission.
- `in-progress` → `open`: falls `Agent` als gelistetes Werkzeug eine Sicherheitsfläche öffnet,
  die der Zahn nicht schließt — dann ist erst die Redaktions-Regel zu klären.

## 5. Closure-Trigger

DoD vollständig; Review konform (Modul 10) mit **ausgestelltem** Verdikt; Verifikation bestätigt
(Modul 11); `make gates` und `make mutate` grün; `git mv` nach `done/` (eigener Move-Commit,
eingehende Links im Zug danach); Closure-Notiz mit Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **`Agent` zu listen erweitert den fail-closed Default.** Bisher gibt jedes ungelistete Werkzeug
  nur Name und Status preis; `Agent` bekäme Zugriff auf seine Antwort. Der Antworttext des
  Subagenten ist beliebiger Inhalt — genau das, was nie ins Audit-Log darf. Die Erweiterung
  trägt nur, wenn der Zahn aus DoD (2) sie hält.
- **Eine Rolle, die niemand startet, füllt kein Feld.** Der Mechanismus greift erst, wenn
  Rollen-Läufe wirklich unter ihrem Typ gestartet werden. Ein Versehen liefert
  `general-purpose` — ein ehrliches „unbekannt", kein falsches Etikett, aber eben auch keine
  Rolle. Deshalb die @-Erwähnung und nicht natürliche Sprache.
- **Nicht geeignet: die Fork-artigen Kommandos** (`/fork`, in dieser Fassung `/subtask`). Sie
  starten einen **Hintergrund**-Subagenten, der *„das vollständige Gespräch erbt"* — das ist
  das Gegenteil dessen, was Modul 8 für Reviewer und Verifier verlangt (*Rollen-Trennung ist
  Kontext-Trennung*). Ein Reviewer mit dem Kontext des Implementers wiederholt dessen blinden
  Fleck, statt ihn zu finden. Sie liefern zudem keine Nutzungstelemetrie.
- **Nicht in diesem Slice:** die Rechnung selbst ([slice-066](slice-066-telemetrie-auswertung.md))
  und die Emission (slice-062/063).

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `.claude/`,
`internal/` und `test/` gehören zum Greenfield-Bestand; der Modus steht in der
Modus-Deklaration von [`harness/conventions.md`](../../../../harness/conventions.md).
