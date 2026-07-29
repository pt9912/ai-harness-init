# Slice slice-060: Rollen-Achse — rollen-benannte Agenten-Typen und die Nutzungstelemetrie der Subagenten

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-09](../welle-09-modul-15-konformitaet.md) — Vorbedingung von
[slice-066](../open/slice-066-telemetrie-auswertung.md).

**Bezug:** [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) (Baseline ohne
inhaltliche Adaption),
[`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
(das Span-Schema, das dieser Slice **erweitert**),
[`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) (**Accepted** — Festlegung 2, der
fail-closed Default am Werkzeug-Namen, wird um genau ein Werkzeug erweitert),
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) — und zwar der
Satz *„Der **Tool-Build** läuft reproduzierbar im gepinnten Image … kein Host-`go`"*,
nicht der Satz über die Ziel-Repos. **Die Kennung deckt beide Ebenen**, und der geschlossene
Vorgänger slice-059 zitiert denselben Bezug über den *anderen* Satz („die Zusage für die
emittierte Seite"). Wer die Ebene statt des Satzes nennt, erzeugt genau diesen Widerspruch.
Regelwerk-Quelle:
`.harness/baseline/v3.5.2/regelwerk/modul-15-observability.md` §Kernidee und
§Token-Attributions-Regeln sowie `modul-08-agentenrollen.md`.

**Bewusst NICHT im Bezug:**
[`LH-FA-08`](../../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren) — die
Anforderung betrifft die **emittierten** Workflow-Commands, dieser Slice emittiert nichts (§6).
Die Kennung dort zu führen füllte die `requirement`-Achse **falsch**, und gefüllt-und-falsch ist
schlechter als leer-und-erkennbar; die Nachbarschaft steht als Frage B. **Dieser Absatz steht
absichtlich unterhalb der Leerzeile:** `references()` in `internal/span/emit.go` liest den Block
**mechanisch** bis zur ersten Leerzeile und unterscheidet nicht zwischen einer geführten und einer
ausdrücklich ausgeschlossenen Kennung — eine Ausschluss-Notiz *im* Block trüge genau das ein, was
sie ausschließt.

**Autor:** ai-harness-init-Team (pt9912). **Datum:** 2026-07-29.

---

## 1. Ziel

**Die Rollen-Achse hört auf, leer zu sein.** `agent_role` steht seit slice-059 in jedem Span und
ist in jedem Span leer, weil alle Subagenten unter `general-purpose` laufen. Dieser Slice füllt
sie und erfasst die Nutzungstelemetrie, die im selben Payload eintrifft.

**Warum ein eigener Slice:** die Begründung des Schnitts steht in
[welle-09 §4](../welle-09-modul-15-konformitaet.md) — kurz: ohne gefüllte Rollen wäre die
Token-Bilanz eine Summe, keine Rechnung.
[slice-066](../open/slice-066-telemetrie-auswertung.md) setzt hier auf.

## 2. Definition of Done

- [ ] **(1) Rollen-benannte Agenten-Typen, im VORDERGRUND gestartet — und die Rolle steht im
  Span.** Je Harness-Rolle eine Datei `.claude/agents/<name>.md` mit Frontmatter (`name`,
  `description`, `tools`, `model`; der Body wird zum Systemprompt). **Zwei Bedingungen, und sie
  ruhen auf verschiedenen Belegen — das gehört auseinandergehalten:**
  1. **WELCHE Rolle läuft, entscheidet der Aufrufer per @-Erwähnung.** Die Subagenten-Doku
     (Herstellerseite `/docs/de/sub-agents`, im Repo **nicht** vorliegend) nennt sie als den
     Weg, der die Ausführung *garantiert*, während natürliche Sprache die Delegation dem Modell
     überlässt.
  2. **WIE sie läuft, entscheidet der Werkzeug-Aufruf** — `run_in_background: false`. **Beide
     Richtungen gemessen** (§3): im Hintergrund kommt weder ein Zähler noch `agentType` an.
     **Gemessen ist auch die Trennung selbst** (2026-07-29): ein per @-Erwähnung angeforderter
     Lauf ohne ausdrücklichen Schalter lief im **Hintergrund** — der Span zeigt `duration_ms: 3`
     bei 4.184 ms tatsächlicher Laufzeit des Subagenten. Die @-Erwähnung wählt also den Typ,
     nicht die Betriebsart.

  **Das verschiebt die Zuständigkeit — und macht die Bedingung ERZWINGBAR.** Sie ist keine
  Nutzer-Konvention, sondern eine **Aufruf-Konvention**, und ihr Durchsetzungsort ist **weder**
  das Frontmatter (die vier Felder oben kennen keine Betriebsart) **noch** ein Kommando (eine
  Prompt-Datei ist dasselbe Gedächtnis), sondern ein **`PreToolUse`-Guard** mit
  `"matcher": "Agent"`. Was daran **belegt** ist und was **nicht**, gehört getrennt:

  | | Aussage | Stand |
  |---|---|---|
  | a | `PreToolUse` kann einen Tool-Call verweigern | **läuft** — `.claude/hooks/pretooluse-command-guard.sh` tut es täglich |
  | b | Der `PreToolUse`-Matcher filtert auf den **Werkzeug-Namen**, `Agent` ist einer | **dokumentiert** — `docs/user/claude-hooks-referenz.md` §Matcher-Tabelle |
  | c | `run_in_background` liegt in `tool_input` | **gemessen** — §3 Zeile 5 |
  | d | Ein `PreToolUse`-Hook feuert für `Agent` **in dieser Version**, und sein Deny greift dort | **UNGEMESSEN** |

  **(d) ist der erste Schritt der Umsetzung, nicht der letzte** — die Messung braucht einen
  Eintrag in `.claude/settings.json` und einen Sitzungs-Neustart, ist also im Plan-Review nicht
  billig zu haben. Verschärfend: `run_in_background` **fehlt im dokumentierten Eingabe-Schema**
  von `Agent`, obwohl die Messung es zeigt. Der Guard behandelt deshalb *fehlend* wie
  *Hintergrund* — fail-closed, wie der bestehende bei Parse-Zweifel.

  **Die Rollen-Liste wird ABGELEITET, nicht kopiert:** ein Typ ist genau dann eine Rolle, wenn
  `.claude/agents/<name>.md` existiert. Damit entsteht keine dritte Kopie neben
  [`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
  und `roleFromAgentType`, und der Guard kann nicht gegen das Verzeichnis veralten, das er bewacht.

  **Vorbild ist der MECHANISMUS, nicht das Ausgabeformat.** Der bestehende Guard antwortet mit
  einem `decision`-Feld auf oberster Ebene — für `PreToolUse` **veraltet** (Referenz: *„diese sind
  jedoch für dieses Ereignis veraltet"*); er funktioniert nur, weil der alte Wert auf `"deny"`
  abgebildet wird. Der neue Guard schreibt `hookSpecificOutput.permissionDecision: "deny"`. Dass
  der alte auf dem veralteten Pfad liegt, ist ein eigener Befund und **nicht** Gegenstand dieses
  Slice.

  **Nicht geeignet: `SubagentStart`.** Das Ereignis filtert seinen Matcher direkt auf den
  Agenten-Typ und wäre der bequemere Ort — aber es **kann die Erstellung nicht blockieren**
  (Referenz, §SubagentStart). Als *Zähler* ist es dennoch wertvoll, und zwar für
  [slice-066](../open/slice-066-telemetrie-auswertung.md).

  **Der Zahn ist ein Gegenbeispiel, kein Testfall** ([`AGENTS.md`](../../../../AGENTS.md) §3.6):
  ein **echter** Aufruf eines Rollen-Typs mit `run_in_background: true`, der **rot abgelehnt**
  wird — einmal gesehen, nicht behauptet. Ein Guard ist dabei schwer zu mutieren; deshalb gehört
  hierher der Lauf, nicht nur ein `test/mutations/`-Fall.

  Beide Bedingungen gehören als Konvention in
  [`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung),
  nicht in ein Gedächtnis. **Belegt an einem echten Lauf**, nicht am Test.
- [ ] **(2) `Agent` wird ein namentlich gelistetes Werkzeug — mit einer POSITIV-Liste.**
  Erfasst wird aus `tool_response` **ausschließlich, was hier steht**: die vier Zähler aus
  `usage`, `totalTokens`, `totalDurationMs`, `totalToolUseCount`, dazu die *tatsächlich
  gelaufene* Rolle (aus `agentType` — nicht `tool_input.subagent_type`, das nur die Anforderung
  ist) und `resolvedModel` (das Label `model.version` aus Modul 15 §Cache-Counter-Regeln).
  **Alles andere fällt heraus, ohne genannt zu werden** — das ist der konstruktive Ausschluss
  aus [`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) Festlegung 2. Eine frühere
  Fassung dieses Punktes zählte stattdessen vier verbotene Felder auf; eine **Negativ**-Liste
  altert mit jedem neuen Antwortfeld, und die Messung hat allein in zwei Aufrufen vier
  undokumentierte Schlüssel gezeigt.
  **Die Rolle bekommt einen eigenen Feldnamen** (`spawned_role`) — der Span führt bereits
  `agent_type` mit anderer Bedeutung (der Typ des *laufenden* Agenten). Unbekannte Werte werden
  wie in `roleFromAgentType` zu **leer** normalisiert; `general-purpose` ist keine Rolle, und
  eine Zeile `general-purpose: 62 %` wäre genau das, was die Lesevorschrift in
  [`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
  verbietet.
  Jedes erfasste Feld mit Incident-Frage in [`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung).
  **Zwei Sorten Zähne** ([`AGENTS.md`](../../../../AGENTS.md) §3.6): je eine Mutation für
  `content`, `prompt`, `description` und `outputFile` — **und einen für die GRENZE selbst**. Vier
  namentliche Fälle unterscheiden eine Positiv-Liste nämlich nicht von einer Implementierung, die
  genau diese vier ausfiltert; sie belegen die Zusage, nicht die Eigenschaft. Der Grenz-Zahn
  füttert eine Antwort mit einem **ungelisteten, erfundenen** Feld und prüft, dass es den Span
  nicht erreicht. Ohne ihn ist die Eigenschaft, mit der §6 die Umstellung begründet (*hält auch
  beim fünften Feld*), unbelegt.

  **Damit dieser Zahn einzeilig mutierbar bleibt, legt der Plan die FORM fest:** die Auswahl der
  erfassten Schlüssel steht als **eine benannte Liste an einer Stelle**, über die die Erfassung
  iteriert — nicht als Feldliste eines geschlossenen Structs. Der Unterschied entscheidet, ob es
  den Zahn gibt: bei einem Struct wäre „alles außer den vier" ein Wechsel der Datenstruktur auf
  eine offene Map, während **jede** bestehende Span-Mutation einzeilig ist. Die Mutation lautet
  dann: einen Eintrag aus der Liste **entfernen** und stattdessen alles Nicht-Gelistete
  durchlassen.
- [ ] **(3) Was die Erfassung nicht abdeckt, steht als erklärte Abweichung.** **Gemessen:**
  Hintergrund-Läufe liefern weder Zähler noch `agentType`; und der Haupt-Kontext wird von keinem
  `Agent`-Aufruf umschlossen. Beides gehört benannt, nicht weggelassen
  ([`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) Festlegung 1 Punkt 5).
- [ ] `make gates` grün, `make mutate` ohne Befund.
- [ ] Doku-Update, falls ein öffentlicher Vertrag berührt ist.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

**Ist-Messung (2026-07-29, an **vier** echten Agenten-Aufrufen dieses Repos — Vordergrund,
Hintergrund, @-Erwähnung, Fehlschlag; erfasst wurden nur Feldnamen und Wertlängen, nie Werte):**

| # | Aufruf | `tool_response` enthält |
|---|---|---|
| 1 | **Vordergrund** (`run_in_background: false`) | `usage` (543 B) mit `input_tokens`, `output_tokens`, `cache_creation_input_tokens`, `cache_read_input_tokens` · `totalTokens` · `totalDurationMs` · `totalToolUseCount` · **`agentType`** · `resolvedModel` · `status` · **`content`**, **`prompt`** |
| 2 | **Hintergrund** (`run_in_background: true`) | `agentId` · `isAsync` · `outputFile` · `canReadOutputFile` · `resolvedModel` · `status` · **`prompt`**, **`description`** — **keine Zähler, kein `agentType`** |
| 3 | **@-Erwähnung ohne ausdrücklichen Schalter** | lief im **Hintergrund**: Span `duration_ms: 3` bei 4.184 ms echter Laufzeit. Die @-Erwähnung wählt den **Typ**, nicht die **Betriebsart** |
| 4 | **Fehlschlag** (unbekannter Agenten-Typ) | Ereignis `PostToolUseFailure`; `tool_response` **fehlt ganz** — nicht leer, sondern nicht vorhanden. `error` steht auf oberster Ebene, dazu ein bis dahin ungesehenes `is_interrupt`. **Die Positiv-Liste greift hier konstruktiv:** es ist nichts zu erfassen, weil nichts Gelistetes existiert |
| 5 | alle vier | `tool_input` trägt `subagent_type`, `prompt`, `description`, `run_in_background` |
| 6 | zwei verschiedene Dauern | `duration_ms` der Payload war **4 ms** (der Hook feuert beim Start), `totalDurationMs` trägt die Laufzeit des Subagenten |
| 7 | die Rollen-Achse ist heute leer (Bestands-Auszählung, nicht Teil der A/B-Erhebung) | alle Subagenten-Ströme tragen `agent_type: "general-purpose"`, `agent_role: ""` |

**Was daraus folgt:** die Zähler sind erreichbar, **aber nur im Vordergrund**. Daraus wird eine
**Prozess-Bedingung**, keine Erfassungs-Frage — und sie passt zum seriellen Betrieb, den dieses
Repo seit dem 2026-07-29 ohnehin fährt. Die Rolle kommt aus `tool_response.agentType`, **nicht**
aus dem `agent_role` des Spans: der `Agent`-Aufruf ist ein Tool-Call des **Aufrufers**, sein
`agent_role` ist dessen Rolle (im Haupt-Kontext leer).

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `.claude/agents/` | neu | je Harness-Rolle ein Typ. Der Reviewer hat mit `.harness/skills/reviewer.md` bereits seinen Anweisungssatz — der Typ zeigt darauf, eine Quelle |
| `internal/span/` | update | `Agent` in die Werkzeug-Klasse; die Positiv-Liste samt neuem Feld `spawned_role`. **Auch der Kommentar** bei `span.go` („vom Ergebnis darf nur die Länge in den Span") — er wird durch DoD (2) falsch, sobald sieben benannte Werte aus `tool_response` gelesen werden |
| `.claude/settings.json` + `.claude/hooks/` | update + neu | der `PreToolUse`-Guard mit `"matcher": "Agent"` aus DoD (1) |
| [`harness/conventions.md`](../../../../harness/conventions.md) | update | in [`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung): Werkzeug- und Feldtabelle (**inkl. `spawned_role`**), die Umstellung auf die **Positiv-Liste**, die Start-Konvention (@-Erwähnung + Vordergrund + Guard), die zwei Abweichungen aus DoD (3) — und §Bewacht, das heute dasselbe sagt wie der Emitter-Kommentar |
| `test/` | neu | die bats-Fälle zur Erfassung: dass die Positiv-Liste greift, dass `spawned_role` normalisiert, dass der Fehlerfall keinen halben Span erzeugt |
| `test/mutations/` | neu + update | **fünf** Zähne aus DoD (2): vier Freitext-Felder plus der Grenz-Zahn. **Update**: `test/mutations/115` behauptet heute, vom Ergebnis dürfe ausschließlich die Größe erfasst werden — ab DoD (2) ist das falsch. `make comment-claims` fängt es **nicht**, weil es die Existenz des Sensors prüft, nicht die Wahrheit des Satzes |

**Angrenzende Fragen — bewusst NICHT in diesem Slice entschieden.** Keine ist eine
Vorbedingung: der Trigger `next → in-progress` ist allein das WIP-Limit. Sie stehen hier, damit
sie nicht als vergessen gelten:

| # | Frage | Wo sie hingehört |
|---|---|---|
| B | Bekommen **Ziel-Repos** dieselben Agenten-Typen? | `.claude/commands/` wird emittiert ([`LH-FA-08`](../../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren), `internal/emit/templates/commands/`). Ob `.claude/agents/` mitgeht, entscheidet slice-062 — **hier** ist nur zu vermeiden, dass die Dogfood-Fassung eine Form bekommt, die den Umzug erschwert |
| C | Bekommt der **Haupt-Kontext** eine Rolle — abgeleitet aus dem Prompt? | `UserPromptSubmit` trägt das Feld `prompt` (gemessen an der Referenz). Der Text ist Freitext, aber **ihn zu lesen ist nicht dasselbe wie ihn zu übernehmen**: derselbe Emitter liest bei `Bash` die volle Kommandozeile und schreibt daraus ein einziges Token. Analog ließe sich der Prompt gegen die **geschlossene Liste der sechs Rollennamen** halten und **nur die Zuordnung** schreiben — einer von sieben Werten, kein Teilstring. **Die Reste, und sie sind größer als zuerst notiert:** (a) **Mehrfach-Treffer** — nennt eine Anweisung zwei Rollennamen, muss die Ableitung entscheiden, welcher gilt oder ob keiner gilt. [`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) Festlegung 1 Punkt 4 verlangt genau das: *„Die Ableitung muss ihre Randfälle mitentscheiden, sonst ist sie keine"* — und entscheidet den gleichgelagerten Fall dort zugunsten von **alle tragen** (mehrere `LH-*`-IDs im Bezug ergeben alle im Span), was hier gerade **nicht** geht, weil ein Span **eine** Rolle trägt. Ohne die Festlegung liefert die Ableitung keinen der sieben Werte, sondern eine Vermutung, und das Argument oben („einer von sieben Werten, kein Teilstring") trägt nicht mehr. (b) **Die Zustands-Brücke** — `UserPromptSubmit` feuert **einmal je Anweisung**, die Spans entstehen **je Tool-Call**; das Etikett muss den Weg dazwischen überleben, und das ist der aufwendige Teil, nicht die Zuordnung selbst. (c) Ein **Falsch-Treffer** bei beiläufiger Erwähnung („der reviewer hat gesagt…"), weshalb nur die @-Erwähnungs-Form taugt und nicht das bloße Wort. (d) Ein **neues Hook-Ereignis** mit eigener Fehlerfläche. **Was es nicht löst:** die Token des Haupt-Kontexts — die stehen in keiner Payload. Es löst die **Splitting-Regel** (slice-066 Frage A), indem der Sammelposten je Anweisung ein Etikett bekäme, statt geschätzt zu werden. Bewusst **kein** vierter DoD-Punkt: Modul 5 setzt die Grenze bei drei |

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

- **`Agent` zu listen erweitert den fail-closed Default**, und die Antwort trägt mindestens
  **vier** gemessene Freitext-Felder (`content`, `prompt`, `description`, `outputFile`) — in nur
  zwei Aufrufen. Ein Prompt ist in
  [`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) Festlegung 2 namentlich als das
  benannt, was nie ins Log darf. Deshalb die **Positiv**-Liste in DoD (2): sie hält auch, wenn
  eine künftige Antwort ein fünftes Freitext-Feld bringt. Der **Fehlerfall ist inzwischen gemessen** (§3 Zeile 4):
  dort fehlt `tool_response` ganz — die Positiv-Liste erfasst folglich nichts, ohne dass es
  einer Sonderregel bedarf. Gefunden wurde dabei ein fünfter undokumentierter Schlüssel
  (`is_interrupt`) in nun vier gemessenen Aufrufen; die Fläche wächst erkennbar weiter, was die
  Wahl der Positiv-Liste stützt.
- **Die Vordergrund-Bedingung kostet Parallelität** — ein Rollen-Lauf blockiert die
  Hauptschleife. Das ist der Preis der Telemetrie.
- **Ohne den Guard aus DoD (1) fehlen die Zähler lautlos.** Ein Hintergrund-Start erzeugt einen
  Span, nur ohne Telemetrie; die Bilanz rechnet dann über weniger Läufen, ohne es zu melden.
  Verschärfend: der Hintergrund ist der **Standard**, die Vordergrund-Bedingung also eine aktive
  Abweichung, die bei jedem Aufruf neu herzustellen ist. **Eine frühere Fassung dieses Punktes
  behauptete, die Bedingung habe *keinen* Sensor** — eine Vollständigkeitsaussage, für die ich
  nie nachgesehen habe. Alle drei Teile lagen im Repo bereit: ein laufender `PreToolUse`-Guard,
  Filterung feiner als der Tool-Name, und `run_in_background` in `tool_input`. Der Sensor steht
  jetzt in DoD (1).
- **Zweite Verteidigungslinie bleibt nötig:** ein Guard kann fehlen, abgeschaltet oder umgangen
  sein. Deshalb verlangt [slice-066](../open/slice-066-telemetrie-auswertung.md) eine **Abdeckungszahl**
  — wie viele `Agent`-Spans überhaupt Zähler trugen — und nicht nur die Größe des Sammelpostens.
- **Eine Rolle, die niemand unter ihrem Typ startet, füllt kein Feld.** Ein Versehen liefert
  `general-purpose` — ein ehrliches „unbekannt", kein falsches Etikett, aber eben keine Rolle.
  Deshalb @-Erwähnung statt natürlicher Sprache.
- **Nicht geeignet: Kommandos, die den Kontext vererben.** `/fork <directive>` startet laut
  Kommando-Referenz der Herstellerseite (`/docs/de/commands`, im Repo **nicht** vorliegend) *„einen Hintergrund-Subagenten, der das vollständige Gespräch erbt"*;
  `/subtask` beschreibt sich in der CLI-Hilfe als *„Send a subagent off with your full context"*.
  (Ob beide dasselbe Kommando sind, ist **nicht belegt** — für den Ausschluss gleichgültig.)
  Kontext-Vererbung ist das Gegenteil dessen, was Modul 8 für Reviewer und Verifier verlangt —
  *Rollen-Trennung ist Kontext-Trennung*.
- **Nicht in diesem Slice:** die Rechnung ([slice-066](../open/slice-066-telemetrie-auswertung.md)) und
  die Emission (slice-062/063).

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `.claude/`, `internal/`
und `test/` gehören zum Greenfield-Bestand; der Modus steht in der Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md).
