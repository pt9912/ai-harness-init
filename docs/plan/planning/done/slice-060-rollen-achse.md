# Slice slice-060: Rollen-Achse — rollen-benannte Agenten-Typen und die Nutzungstelemetrie der Subagenten

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-09](../welle-09-modul-15-konformitaet.md) — Vorbedingung von
[slice-066](../in-progress/slice-066-telemetrie-auswertung.md).

**Bezug:** [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) (Baseline ohne
inhaltliche Adaption),
[`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
(das Span-Schema, das dieser Slice **erweitert**),
[`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) (**Accepted** — Festlegung 2 setzt den
fail-closed Default am Werkzeug-**Namen**; dieser Slice nimmt `Agent` in die **delegierte** Liste
in [`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung) auf
und lässt die ADR unberührt — **Architect-Verdikt vom 2026-07-30**, Artefakt
`docs/reviews/2026-07-30-slice-060-dod2-adr-0011-architect.md`. Erweitert wird die **Adaption**,
nicht die Festlegung: wer es umgekehrt formuliert, sagt eine ADR-Änderung zu, die dieser Slice
nicht vornimmt),
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
[slice-066](../in-progress/slice-066-telemetrie-auswertung.md) setzt hier auf.

## 2. Definition of Done

- [x] **(1) Rollen-benannte Agenten-Typen, im VORDERGRUND gestartet — und die Rolle steht im
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
  | d | Ein `PreToolUse`-Hook feuert für `Agent` **in dieser Version**, und sein Deny greift dort | **GEMESSEN** — §3 Zeilen 8–10 |

  **(d) war der erste Schritt der Umsetzung und ist erledigt** (2026-07-29): der Hook feuert, und
  sein Deny greift — ein `Agent`-Aufruf im Hintergrund wurde **abgelehnt**, der Ablehnungsgrund
  kam wörtlich als Fehler beim Aufrufer an, der Subagent lief nicht. Damit ist der Zahn zu diesem
  DoD-Punkt **rot gesehen**, nicht behauptet.

  **Zwei Annahmen dieses Plans hat die Messung widerlegt:** ein Sitzungs-Neustart war **nicht**
  nötig (die Änderung an `.claude/settings.json` griff sofort), und der Aufwand ist klein. Was
  richtig war: die **Kontrolle** war nötig. Ohne sie hätte ein stiller Hook zwei Ursachen gehabt
  — „feuert nicht für `Agent`" und „Konfiguration nicht gelesen" —, und nur die erste wäre ein
  Befund gewesen.

  `run_in_background` **fehlt im dokumentierten Eingabe-Schema** von `Agent`, obwohl die Messung
  es an beiden Ereignissen zeigt. Der Guard behandelt *fehlend* deshalb wie *Hintergrund* —
  fail-closed, wie der bestehende bei Parse-Zweifel. **Das ist keine Kleinigkeit:** in der
  Kontroll-Messung trugen die `Bash`-Aufrufe das Feld gar nicht, ein weggelassener Schalter ist
  also der Normalfall und nicht der Ausnahmefall. **Dieselbe Antwort gilt dem fehlenden
  `subagent_type`:** der Hook hängt an `"matcher": "Agent"`, was er sieht *ist* ein
  Agenten-Aufruf, und ohne Typ ist nicht entscheidbar, ob eine Rolle startet — Durchlassen
  hieße raten. Dauer-Sensor `test/mutations/139`.

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
  [slice-066](../in-progress/slice-066-telemetrie-auswertung.md).

  **Der Zahn ist ein Gegenbeispiel, kein Testfall** ([`AGENTS.md`](../../../../AGENTS.md) §3.6):
  ein **echter** Aufruf eines Rollen-Typs mit `run_in_background: true`, der **rot abgelehnt**
  wird — einmal gesehen, nicht behauptet. Ein Guard ist dabei schwer zu mutieren; deshalb gehört
  hierher der Lauf, nicht nur ein `test/mutations/`-Fall.

  Beide Bedingungen gehören als Konvention in
  [`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung),
  nicht in ein Gedächtnis. **Belegt an einem echten Lauf**, nicht am Test.
- [x] **(2) `Agent` wird ein namentlich gelistetes Werkzeug — mit einer POSITIV-Liste.**
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

  **Die Grenze, innerhalb der das ADR-konform bleibt, ist geprüft und benannt:** das
  Architect-Artefakt vom 2026-07-30
  (`docs/reviews/2026-07-30-slice-060-dod2-adr-0011-architect.md` §6) führt **fünf** prüfbare
  Bedingungen B1–B5, je mit Gegenbeispiel — darunter, dass `spawned_role` **nie** aus
  `tool_input.subagent_type` kommt (das wäre die Argument-Fläche, die Festlegung 2 schützt) und
  dass `resolvedModel` als **einziger Rohstring** unter den erfassten Werten eine strukturelle
  Schranke braucht. Das ist die Checkliste des Verifiers, kein vierter DoD-Punkt.

  **Damit dieser Zahn einzeilig mutierbar bleibt, legt der Plan die FORM fest:** die Auswahl der
  erfassten Schlüssel steht als **eine benannte Liste an einer Stelle**, über die die Erfassung
  iteriert — nicht als Feldliste eines geschlossenen Structs. Der Unterschied entscheidet, ob es
  den Zahn gibt: bei einem Struct wäre „alles außer den vier" ein Wechsel der Datenstruktur auf
  eine offene Map, während **jede** bestehende Span-Mutation einzeilig ist. Die Mutation lautet
  dann: einen Eintrag aus der Liste **entfernen** und stattdessen alles Nicht-Gelistete
  durchlassen.
  **Abweichung — hier, wo die DoD gelesen wird, und nicht nur im Fall-Kopf:** der gelieferte
  Grenz-Zahn `test/mutations/127-span-positivliste-negiert.sh` entfernt **keinen** Eintrag; er
  hängt hinter die Erfassung eine Negativ-Liste, weil `AgentResult` ein geschlossenes Struct ist
  und „alles Nicht-Gelistete durchlassen" eine Senke braucht — die einzige ist `model_version`.
  Die Zusage „einzeilig mutierbar" hält damit für die vier namentlichen Zähne (123–126),
  **nicht** für 127; die Form-Vorgabe selbst (Auswahl = benannte Liste an einer Stelle) ist
  erfüllt. Die ausführliche Begründung steht im Fall-Kopf, nicht hier — dies ist der Zeiger
  darauf.
- [x] **(3) Was die Erfassung nicht abdeckt, steht als erklärte Abweichung.** **Gemessen:**
  Hintergrund-Läufe liefern weder Zähler noch `agentType`; und der Haupt-Kontext wird von keinem
  `Agent`-Aufruf umschlossen. Beides gehört benannt, nicht weggelassen
  ([`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) Festlegung 1 Punkt 5).
- [x] `make gates` grün, `make mutate` ohne Befund.
- [x] Doku-Update, falls ein öffentlicher Vertrag berührt ist.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.

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
| 6 | zwei verschiedene Dauern | `duration_ms` der Payload misst den **Aufruf**, `totalDurationMs` der `tool_response` die Laufzeit des **Subagenten**. Die Erfassung hängt an `PostToolUse`, der Hook feuert also **nach** dem Aufruf: in einem Vordergrund-Lauf liegt `duration_ms` deshalb **über** `totalDurationMs`, in einem Hintergrund-Lauf weit darunter, weil das Werkzeug sofort nach dem Start zurückgibt. Ein `duration_ms` im Millisekunden-Bereich **neben** einem `totalDurationMs` ist im Span-Bestand nicht auffindbar — die zwei Beobachtungen gehören verschiedenen Aufrufen |
| 7 | die Rollen-Achse ist heute leer (Bestands-Auszählung, nicht Teil der A/B-Erhebung) | alle Subagenten-Ströme tragen `agent_type: "general-purpose"`, `agent_role: ""` |
| 8 | **`PreToolUse` feuert für `Agent`** (2026-07-29, Sonde mit `"matcher": "Agent"`, danach entfernt) | ja — und `tool_input` trägt `subagent_type` und `run_in_background` schon **vor** dem Lauf. **Kontrolle:** dieselbe Sonde war zusätzlich für `Bash` verdrahtet und loggte dessen Aufrufe; ein stiller Hook wäre sonst mehrdeutig gewesen |
| 9 | **Das Deny greift** | ein `Agent`-Aufruf mit `run_in_background: true` wurde **abgelehnt**; der Text aus `permissionDecisionReason` kam **wörtlich** als Fehler beim Aufrufer an, der Subagent lief nicht. Derselbe Typ mit `run_in_background: false` lief unmittelbar davor durch |
| 10 | die Ausgabeform | `hookSpecificOutput.permissionDecision: "deny"` — die **aktuelle**; das `decision`/`reason` des bestehenden Guards ist für `PreToolUse` veraltet. Und: die Änderung an `.claude/settings.json` griff **ohne Sitzungs-Neustart** |

**Was daraus folgt:** die Zähler sind erreichbar, **aber nur im Vordergrund**. Daraus wird eine
**Prozess-Bedingung**, keine Erfassungs-Frage — und sie passt zum seriellen Betrieb, den dieses
Repo seit dem 2026-07-29 ohnehin fährt. Die Rolle kommt aus `tool_response.agentType`, **nicht**
aus dem `agent_role` des Spans: der `Agent`-Aufruf ist ein Tool-Call des **Aufrufers**, sein
`agent_role` ist dessen Rolle (im Haupt-Kontext leer).

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `.claude/agents/` | neu | je Harness-Rolle ein Typ. Der Reviewer hat mit `.harness/skills/reviewer.md` bereits seinen Anweisungssatz — der Typ zeigt darauf, eine Quelle |
| `internal/span/` | update | `Agent` in die Werkzeug-Klasse; die Positiv-Liste samt neuem Feld `spawned_role`. **Auch der Kommentar** bei `span.go` („vom Ergebnis darf nur die Länge in den Span") — er wird durch DoD (2) falsch, sobald **sechs** benannte Schlüssel aus `tool_response` gelesen werden (`usage`, `totalTokens`, `totalDurationMs`, `totalToolUseCount`, `agentType`, `resolvedModel`) — **neun** Werte, wenn man die vier Zähler in `usage` einzeln zählt. „Sieben" stand hier und war unter beiden Zählweisen falsch; die Zahl entsteht, wenn man Rolle und Modell vergisst — genau die zwei Werte, an denen die Verifier-Grenzen B1 und B5 hängen |
| `.claude/settings.json` + `.claude/hooks/` | update + neu | der `PreToolUse`-Guard mit `"matcher": "Agent"` aus DoD (1) |
| [`harness/conventions.md`](../../../../harness/conventions.md) | update | in [`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung): Werkzeug- und Feldtabelle (**inkl. `spawned_role`**), die Umstellung auf die **Positiv-Liste**, die Start-Konvention (@-Erwähnung + Vordergrund + Guard), die zwei Abweichungen aus DoD (3) — und §Bewacht, das heute dasselbe sagt wie der Emitter-Kommentar |
| [`ADR-0012`](../../adr/0012-haupt-kontext-ohne-token-bilanz.md) | neu | die **zweite** Abweichung aus DoD (3) — der Haupt-Kontext — ist nach dem Trichter aus Modul 7 §Werkzeug-Wahl **permanent**: ihr Trigger ist nicht durch Aufwand zu erreichen, also ist sie keine temporäre Ausnahme und gehört in eine ADR statt in einen Auflösungs-Trigger ohne Folge-Slice. Angelegt als *Proposed*; über die Annahme entscheidet der Architect (Modul 7 §Carveout-Audit verteilt die Rollen so). **Kein vierter DoD-Punkt:** DoD (3) verlangt die erklärte Abweichung — dies ist ihre Modul-7-konforme Form, nicht eine zusätzliche Zusage |
| `test/` | neu | die Fälle zur Erfassung: dass die Positiv-Liste greift, dass `spawned_role` normalisiert, dass der Fehlerfall keinen halben Span erzeugt. Alle drei sind **Go**-Wächter in `internal/span/response_test.go`, nicht bats-Fälle — unter demselben Target, denn `make test` umfasst `test-bats` **und** `test-go`. Dieselbe Werkzeug-Verschiebung führt [`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung) für die drei Fitness-Function-Zeilen der ADR. **Neu unter `test/` sind zwei Dinge, nicht eines:** `test/mutations/` und `test/agent-guard.bats` — die Verhaltens- und Parse-Fälle des Guards aus DoD (1), die der einmalige Live-Beleg dort nicht wiederholbar macht |
| `test/mutations/` | neu + update | **fünf** Zähne aus DoD (2): vier Freitext-Felder plus der Grenz-Zahn — geliefert sind mehr, und eine Gesamtzahl steht hier bewusst nicht: sie bezöge sich auf einen Bestand, der weiterwächst, während dieser Plan steht. Dieser Slice legt **lückenlos 117–139** an. Aus DoD (1): 117 (die Rollen-Frage entfernt), 118 (Namensliste statt Ableitung), 119 (fehlender Schalter fail-open), 120–122 (der Extraktor: Zeichensatz, verschachtelter `subagent_type`, `run_in_background` außerhalb `tool_input`) und 139 (fehlender Typ fail-open). Aus DoD (2): 123–127 nach Plan, dazu 128 (`spawned_role` unnormalisiert), 129 (Modell-Schranke kürzt statt zu verwerfen), 130 (`omitempty` an `json:"tool"`), 131 (der Werkzeug-Name erreicht die Zeile nicht mehr), 132 (`spawned_role` fällt auf `tool_input.subagent_type` zurück — **B1**), 133 (die Werkzeug-Achse auf jedes klassifizierte Werkzeug geweitet), 134 (`omitempty` von `input_tokens` genommen — der halbe Span), 135 (`Agent` auf die Kommando-Gattungszeile abgebildet — **B2**), 136 (`omitempty` von `output_tokens` genommen), 137 (`omitempty` von `spawned_role` genommen) und 138 (**dieselbe** Mutation wie 137 mit anderer `# expect:`-Zeile). 137 und 138 gehören zusammen: die Draht-Form von `spawned_role` ist in **zwei** Wächtern zugesagt, jeder mit eigenem `mustNotContain`-Eintrag, und der Treiber bindet je Fall genau **einen** Namen — ein Fall allein ließe den anderen Eintrag ungebunden (gemessen 2026-07-31, beide Richtungen). **Warum es mehr als fünf sind:** jeder Wächter aus DoD (2) braucht einen Dauer-Sensor, der ihn über *seine* Zusicherung rot färbt — 128–138 sind die, die dabei fehlten. Darunter **B1**, die Grenze, auf der das Architect-Verdikt ruht: mit gestrichenen B1-Zusicherungen meldete Fall 131 weiter „ok". Ebenso die Werkzeug-Achse `tool` — kein Fall berührte sie, die **Voraussetzung** der `spawned_role`-Lesart hing an Fall 110, der `tool_use_id` mutiert. Und `output_tokens`, das als `null` in **jeder** Span-Zeile stand, während `make test-go` grün blieb. **Update**: `test/mutations/115` behauptet heute, vom Ergebnis dürfe ausschließlich die Größe erfasst werden — ab DoD (2) ist das falsch. `make comment-claims` fängt es **nicht**, weil es die Existenz des Sensors prüft, nicht die Wahrheit des Satzes |

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
  Abweichung, die bei jedem Aufruf neu herzustellen ist. **Ihr Sensor steht in DoD (1)**, und
  seine drei Teile lagen im Repo bereit: ein laufender `PreToolUse`-Guard, eine Filterung feiner
  als der Tool-Name, und `run_in_background` in `tool_input`. Wer die Bedingung für sensorlos
  hält, hat nicht nachgesehen — die Aussage „hat keinen Sensor" ist eine Vollständigkeitsaussage
  und verlangt denselben Lauf wie ihr Gegenteil.
- **Bedingung 1 (@-Erwähnung) bleibt ohne Sensor — geliefert ist eine erklärte
  Nicht-Durchsetzbarkeit, nicht eine Durchsetzung.** Das ist eine **Substitution**, und sie
  gehört so protokolliert wie die Abweichung in DoD (2), sonst liest sich DoD (1) als „beide
  Bedingungen erzwungen". Der Grund trägt nur zur Hälfte: für die typisierten
  `tool_input`-Schlüssel (`subagent_type`, `run_in_background`, `model`) steht in der Payload
  nichts, worauf ein Guard prüfen könnte; für `prompt` und `description` ist es **ungeprüft**,
  weil die Ist-Messung in §3 ausdrücklich nur **Feldnamen und Wertlängen, nie Werte** erfasst
  hat. Was es entschiede, ist benannt und **nicht gefahren**: eine Werte-Sonde auf
  `tool_input.prompt` bei einem @-erwähnten Aufruf. Bis dahin gilt „nicht nachgesehen", nicht
  „strukturell unmöglich" —
  [`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
  sagt es ebenso.
- **Fünf fail-closed-Zweige, zwei mit Dauer-Sensor — und zwei Pfade, die fail-OPEN sind.** Das
  Kriterium steht hier, weil das Wort *unbewacht* sonst zwei Mengen bezeichnet: nach
  [`AGENTS.md`](../../../../AGENTS.md) §3.6 (*„wer keinen Fall in `test/mutations/` hat, ist
  unbewacht"*) sind **drei** der fünf unbewacht — *awk*, *Extraktor* und der *Parse-Zweifel*.
  Der Parse-Zweifel hat einen bats-Fall, aber keinen Dauer-Sensor; awk und Extraktor erreicht
  **kein** Fall in `test/`. Zähne im Sinne des Dauer-Sensors haben allein *fehlender Typ*
  (`test/mutations/139-agentguard-typ-failopen.sh`) und *fehlender Schalter*
  (`test/mutations/119-agentguard-schalter-failopen.sh`).
  Fail-**open** sind zwei Pfade, die gar kein Zweig sind: fehlt `cat` oder `sed`, endet der
  Guard mit Exit 127 **ohne Ausgabe**; liefert der Extraktor `rc=0` mit leerem oder falschem
  Inhalt, antwortet er PASS. Beide Male läuft der Aufruf, weil jeder Exit außer 0 und 2
  nicht-blockierend ist. **DoD (1) sagt keinen dieser Zweige zu** — der Slice trägt die Grenze,
  er hängt sich die Arbeit nicht an. Die Sensoren sind baubar (`PATH` ohne `awk`, Guard-Kopie
  ohne Nachbarbaum, ein Fall auf den Parse-Zweifel), die zwei fail-open-Pfade sind zu
  **entscheiden**, nicht nur zu besensoren — je eine neue Zusage mit eigenem Zahn
  ([`AGENTS.md`](../../../../AGENTS.md) §3.6). **Eigener Schnitt, noch nicht gelegt.**
- **Zweite Verteidigungslinie bleibt nötig:** ein Guard kann fehlen, abgeschaltet oder umgangen
  sein. Deshalb verlangt [slice-066](../in-progress/slice-066-telemetrie-auswertung.md) eine **Abdeckungszahl**
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
- **Der Abschluss-Gate-Lauf zu DoD (2) deckte `internal/span/response.go` NICHT** — das gehört
  geschrieben, nicht stehengelassen. Die protokollierte Zeile
  *„comment-claims: 37 Datei(en) geprueft, 0 Befund(e)"* entstand, während die Datei noch
  **untrackt** war: der Prüfbereich von `comment-claims` kommt aus dem Index, der Nachweis-Hash von
  `record-gates` deckt Getrackte **und** Untrackte. Die Datei lag damit *innerhalb* des
  bestätigten Baum-Zustands und *außerhalb* des Prüfbereichs — ihre Kommentar-Blöcke mit
  Sensor-Nennungen waren ungeprüft, während der Stop-Hook den Abschluss durchließ. **Deckend
  nachgefahren, sobald die Datei getrackt war:** 38 Datei(en), 0 Befund(e) — die Differenz zu
  37 ist genau diese Datei. Eingeschränkt ist damit die
  **Zusage** (der Prüfbereich steht jetzt in [`harness/README.md`](../../../../harness/README.md)
  und [`AGENTS.md`](../../../../AGENTS.md) §4); der **Mechanismus** ist bewusst **nicht**
  Gegenstand dieses Slice — er betrifft jede künftige neue Datei in den vier Prüfbereichen, nicht
  die Telemetrie, und ein Gate-*Anheben* ist ein Steering-Loop, kein ADR.
  **Drei Verengungen zählen gegen den Gate-Stempel:** (1) Index-only, (2) die vier Pfad-Muster,
  (3) die `_test.go`-Ausnahme. Nur (1) heilt ein `git add`; (2) und (3) sind **permanent**, und
  `Makefile`, `harness/tools/*.awk` (darunter `harness/tools/extract-agent-call.awk` aus
  DoD (1)), `internal/emit/templates/` und `test/` liegen damit dauerhaft ungeprüft. Alle drei
  Achsen stehen in [`harness/README.md`](../../../../harness/README.md), in
  [`AGENTS.md`](../../../../AGENTS.md) §4 und hier.
  **Zum gemessenen Einzeltreffer im `Makefile` (Zeile 83) ausdrücklich entschieden, statt ihn
  mitzunehmen:** er gehört **nicht** in diesen Slice. Der Satz dort verneint eine Abdeckung
  (*„er belegte den Cache, nicht die Reproduzierbarkeit"*) und ist damit die Form, für die
  `harness/tools/comment-claims.sh` seine Negations-Ausnahme führt; sie verfehlt ihn um **ein**
  Zeichen (Fenster zwölf, Abstand dreizehn — gemessen). Der Treffer ist also kein Beleg für eine
  unbewachte Behauptung, sondern für eine zu enge Ausnahme — mithin ein **Mechanismus**-Befund.
  Ihn hier durch Umformulieren des Kommentars stillzulegen, entfernte genau das Gegenbeispiel,
  an dem der Mechanismus-Slice seine Entscheidung misst.
  **Landeplatz, offen und benannt:** den Mechanismus-Schnitt zu legen ist Planner-Arbeit; dieser
  Slice trägt ihn nicht. Bis dahin lebt die Warnung dort, wo sie den Slice überlebt — in
  [`harness/README.md`](../../../../harness/README.md), nicht nur in diesem Plan.
- **Die Werkzeug-Achse sitzt nur in `Parse`, nicht in `Build`** — zurückgestellt, mit Grund.
  `Parse` prüft `Agent` am Werkzeug-Namen; `Build` überträgt die erfassten Werte danach
  bedingungslos. Heute folgenlos, weil `Parse` der einzige Ort ist, an dem ein gefülltes
  `Payload` entsteht. Ein **zweiter** Erzeuger (Nachbearbeitung,
  Transkript-Import, ein Test-Helfer, der zum Produktionspfad wird) könnte die Achse umgehen, und
  `TestOnlyAgentToolGetsResponseValues` fängt es nicht — er geht über `Parse`. Nicht in DoD (2)
  nachgezogen, weil eine zweite Prüfung eine **neue Zusage** ist und nach
  [`AGENTS.md`](../../../../AGENTS.md) §3.6 ihren eigenen rot gesehenen Zahn braucht; das ist ein
  eigener Schnitt, kein Anhang. Der Fingerabdruck-Zweig prüft seine Klasse dagegen in `Build`
  selbst — die zwei Achsen-Prüfungen liegen also auf verschiedenen Ebenen, und das ist der
  eigentliche Befund.
- **Nicht in diesem Slice:** die Rechnung ([slice-066](../in-progress/slice-066-telemetrie-auswertung.md)) und
  die Emission (slice-062/063).

## 7. Closure-Notiz (nach `done/`)

**Was gilt.** Die Rollen-Achse trägt Werte. Über den lokalen Span-Bestand ausgezählt
(`grep -o '"agent_role":"[a-z-]*"' | sort | uniq -c`): **3.151 von 4.069** Spans führen eine
Rolle (`implementer` 976 · `planner` 819 · `reviewer` 681 · `architect` 449 · `verifier` 226),
918 sind leer — Haupt-Kontext und `general-purpose`, beide erklärt. Von **69** `Agent`-Spans
tragen **47** ein `spawned_role`, und als Wert kommt ausschließlich einer der kanonischen
Rollennamen vor; `general-purpose` erscheint dort nie. Der Zustand aus §3 Zeile 7 — alle Ströme
mit leerer Rolle — ist damit abgelöst.

Durchgesetzt wird die Aufrufform, nicht der Ausgang: der `PreToolUse`-Guard verweigert einen
Rollen-Typ ohne `run_in_background: false`, und er leitet die Rollen-Liste aus
`.claude/agents/` ab, statt sie zu kopieren. Erfasst wird aus der Antwort ausschließlich, was
`responseKeys()` nennt — neun Blatt-Werte aus sechs Schlüsseln, mit einem Zahn auf die **Grenze**
selbst und nicht nur auf vier Namen. Was die Erfassung nicht abdeckt, steht als Abweichung 5 und 6
in [`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung),
je mit den Prüfschritten **vor** der Abweichung.

Gates: `make gates` Exit 0 (d-check · 150 bats · sieben Go-Pakete · comment-claims 38/0 ·
span-check); `make mutate` **135 ok, 0 Befund(e)** über die CI auf frischem Runner.

**Was der Slice nicht deckt, steht in §6 und ist mit dieser Closure eingefroren.** Der Kern in
einem Satz: von den fünf fail-closed-Zweigen des Guards haben nach
[`AGENTS.md`](../../../../AGENTS.md) §3.6 **drei** keinen Dauer-Sensor, zwei Pfade sind gar kein
Zweig und antworten fail-**open**, und die Werkzeug-Achse der Erfassung sitzt nur in `Parse`,
nicht in `Build`. Keiner dieser Punkte ist in einer DoD zugesagt; jeder ist eine **neue** Zusage
und braucht darum seinen eigenen rot gesehenen Zahn. Der Schnitt dafür ist **nicht gelegt** —
gemessen an `grep -rn 'fail-open' docs/plan/planning/{open,next}/`: zwei Treffer, beide zu
anderen Gegenständen (Prüfbereichs-Form, ADR-Listenpflege).

**Zwei Sachmängel bleiben stehen, mit Träger und mit Preis.** In
[`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung) sind
zwei Aussagen falsch bzw. leer:

| Mangel | Befund | Träger |
|---|---|---|
| Zahl der `settings.json`-Prüfstellen | über den Umfang, den der Satz selbst deklariert (`test/**` · `Makefile` · `harness/tools/*.sh` · Go-Tests), sind es **fünf** Prüfstellen in drei Dateien mit **zwei** Prüfungen des bloßen Vorhandenseins — der Text sagt *vier Artefakte* mit *einer*. Die zweite Existenz-Prüfung ist die `for rel in …`-Schleife in `harness/tools/smoke.sh`, deren anderer Block als Artefakt mitzählt | [slice-076](slice-076-mr-018-umzug-technik-stratum.md) §1, Posten (c) |
| die zugesagte Werte-Sonde auf die Schlüsselnamen von `tool_input` | sie entscheidet nichts: in beiden offenen Lesarten — der Hook lief und wurde übergangen, oder er feuerte nie — zeigt sie dasselbe | [slice-076](slice-076-mr-018-umzug-technik-stratum.md) §1, Posten (d) — dort **ersatzlos**, weil der trennende Sensor [slice-074](../open/slice-074-agent-vor-aufruf-protokoll.md) ist |

**Der Preis, ungeschönt.** Beide Mängel waren korrigiert und sind **zurückgenommen**: die
adoptierte Vorlagen-Disziplin lässt an einem akzeptierten Eintrag nur *neue Einträge* oder eine
*explizite Aufhebung via neuen MR* zu, und eine gezielte Korrektur im Rumpf ist keines von
beidem. Der Eintrag darf aus demselben Grund auch **nicht** auf seinen Träger zeigen — gemessen
über den Eintrags-Block: `grep -c 'slice-07[0-9]'` → **0**, und das bleibt so. Bis zum Vollzug
von [slice-076](slice-076-mr-018-umzug-technik-stratum.md) steht damit im
Pflicht-Lesepfad (`CLAUDE.md`, Punkt 3 der Vor-jeder-Änderung-Leseliste) eine gemessen falsche
Zahl, und am Ort des Lesens steht nichts, das sie einschränkt.

**Diese Notiz dokumentiert das, sie behebt es nicht** — wer
[`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
liest, kommt hier nicht vorbei. Der einzige Weg, der die Sache am Ort des Lesens erreichte und
die Disziplin wahrte, wäre ein **neuer** Adaptions-Eintrag, der die Zahl richtigstellt; dieser
Slice geht ihn bewusst nicht, weil er einen Eintrag in einen Block schriebe, den
[`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md) und
[`ADR-0014`](../../adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md) gerade auflösen. Die
Behebung ist der Umzug, nicht ein weiterer Satz.

**Steering-Loop-Einträge.**

1. **Geschärfte Regel — eine Zusage reicht so weit wie der Prüfbereich, über den sie gemessen
   wurde, und der Prüfbereich gehört dorthin, wo die Zusage steht.** Dreimal in diesem Slice war
   eine Aussage breiter als ihr Bereich, und jedes Mal fiel es erst durch eine **gefahrene**
   Gegenprobe auf, nie durch Lesen: (a) *„N Datei(en) geprueft, 0 Befund(e)"* deckte den Baum
   nicht — die geprüfte Datei war untrackt und lag außerhalb des Index-Prüfbereichs, während der
   Gate-Stempel sie einschloss (Gegenprobe: derselbe Lauf nach `git add`, 37 → 38);
   (b) der Guard-Kopf sagte *„Zähne haben die letzten drei"* — Gegenprobe: jeden Fall auf eine
   Kopie angewandt und die geänderte Zeile abgelesen; zwei der vier Guard-Fälle treffen die
   Rollen-Frage, keinen fail-closed-Zweig; (c) *„vier Artefakte … eine Prüfung ihres bloßen
   Vorhandenseins"* — Gegenprobe: die vier `grep` über genau den deklarierten Umfang, Ergebnis
   fünf und zwei. **Anwendung:** wer eine Menge behauptet, nennt das Kriterium und fährt es;
   eine Trefferliste ist keine Vollständigkeitsaussage, und *„hat keinen Sensor"* verlangt
   denselben Lauf wie *„hat einen"*.

2. **Geschärfte Regel — ein Wort, das eine Menge bezeichnet, braucht sein Kriterium am Ort des
   Lesens.** *Bewacht* meinte in zwei committeten Artefakten desselben Slice zwei verschiedene
   Mengen: der Guard-Kopf zählte den Parse-Zweifel wegen seines bats-Falls zu den bewachten
   Zweigen, §6 dieses Plans nicht — dieselbe Sache, drei gegen zwei, ohne dass an einer der
   beiden Stellen stand, welches Kriterium gilt.
   [`AGENTS.md`](../../../../AGENTS.md) §3.6 hat eines (*„wer keinen Fall in `test/mutations/`
   hat, ist unbewacht"*), und unter ihm sind es drei. Kein Gate misst das: `comment-claims`
   prüft, ob ein genannter Sensor **existiert**, nie ob er die genannte Menge **trägt**.
   **Anwendung:** Zahl und Kriterium stehen zusammen oder gar nicht; §6 führt sie seit dieser
   Closure zusammen.

3. **Benannte Spec-Lücke — für die Korrektur eines akzeptierten Adaptions-Eintrags gibt es
   keine Regel.** Geregelt ist die **Aufhebung**
   ([`MR-020`](../../../../harness/conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf),
   [`ADR-0014`](../../adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md)) und der **neue
   Eintrag**; der dritte Fall — eine einzelne, gemessen falsche Aussage im Rumpf eines Eintrags,
   der im Übrigen bindet — ist in keinem Artefakt entschieden. Die Folge ist am Bestand
   ablesbar: eine Korrektur wurde geschrieben, als Disziplin-Bruch erkannt und byte-genau
   zurückgenommen (Blob-Hash vor der Korrektur und nach der Rücknahme identisch), und der Mangel
   wandert in einen Slice, dessen Trigger ein WIP-Limit ist. **Die Lücke ist die Regel, nicht der
   Vorgang** — solange sie offen ist, kostet jeder Mangel dieser Klasse dieselbe Wartezeit im
   Pflicht-Lesepfad.

4. **Neuer Sensor — `test/agent-guard.bats` (23 Fälle) und `test/mutations/117`–`139`.** Die
   Verhaltens- und Parse-Fälle machen den einmaligen Live-Beleg wiederholbar; die
   Mutations-Fälle binden ihn dauerhaft. Zwei Eigenschaften daran sind das Übertragbare: die
   Rollen-Liste wird über das **Verzeichnis** geprüft (ein Fall legt eine erfundene Rolle in ein
   Fixture-Verzeichnis und erwartet Deny — eine kopierte Namensliste bestünde ihn nicht), und
   die Positiv-Liste hat einen Zahn auf die **Grenze** (ein erfundenes, ungelistetes Feld darf
   den Span nicht erreichen) statt nur vier Zähne auf vier Namen. Vier namentliche Fälle
   unterscheiden eine Positiv-Liste nicht von einer Implementierung, die genau diese vier
   ausfiltert.

**Offen, mit Träger.**

| Posten | Träger |
|---|---|
| [`ADR-0012`](../../adr/0012-haupt-kontext-ohne-token-bilanz.md) steht auf *Proposed*; die Matrix-Zelle *Token-Attribution × Repo* der Welle verlangt ein **Verdikt** | Architect — Vorbedingung der welle-09-Closure, nicht dieses Slice |
| die zwei Sachmängel in [`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung) | [slice-076](slice-076-mr-018-umzug-technik-stratum.md) (c) und (d) |
| die drei fail-closed-Zweige ohne Dauer-Sensor und die zwei fail-open-Pfade (§6) | kein Schnitt gelegt — Planner-Arbeit |
| `comment-claims`: Index-Verengung, vier Pfad-Muster, `_test.go`-Ausnahme, das Zwölf-Zeichen-Fenster der Verneinungs-Ausnahme | [slice-070](../open/slice-070-comment-claims-pruefbereich.md) |
| ein Fall bindet einen Wächter-**Namen**, nicht seine **Zusicherung** | [slice-069](../open/slice-069-zahn-bindet-zusicherung.md) |
| der veraltete Top-Level-`decision`-Pfad des Nachbar-Guards | [slice-067](../open/slice-067-pretooluse-ausgabeform.md) |
| die Sonde, die „der Hook lief" von „er feuerte nie" trennt | [slice-074](../open/slice-074-agent-vor-aufruf-protokoll.md) |
| die Rechnung über den erfassten Werten (Bilanz, Cache-Zähler, Abdeckungszahl) | [slice-066](../in-progress/slice-066-telemetrie-auswertung.md) · [slice-071](../open/slice-071-cache-zaehler-getrennt.md) · [slice-068](slice-068-rollen-arbeit-laeuft-als-rolle.md) |

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `.claude/`, `internal/`
und `test/` gehören zum Greenfield-Bestand; der Modus steht in der Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md).
