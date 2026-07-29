# Review-Report: slice-060 + slice-066 (Plan) — 2026-07-29

**Review-Art:** **Plan** — geprüft wird der **Plan** gegen Spec, aktive ADRs, Hard Rules und das
adoptierte Regelwerk, *bevor* implementiert wird (Modul 10 §Drei Review-Arten). Es gibt keinen
Produktiv-Diff der beiden Slices; Eingabe sind die Plan-Artefakte selbst. **Nicht** geprüft: Code
(nur gelesen, soweit er eine Plan-Aussage belegt oder widerlegt), DoD-Abhakung (Modul 11,
getrennter Kontext).

**Gegenstand:**

- `docs/plan/planning/open/slice-060-rollen-achse.md` (neu, aus `2775ef9`/`2284189`)
- `docs/plan/planning/open/slice-066-telemetrie-auswertung.md` (neu, aus `2775ef9`)
- der Umfeld-Zug derselben Sitzung: `1118a6c` · `37bb973` · `96508ff` · `e76bc90` · `1c8b556` ·
  `73a4d86` · `2775ef9` · `2284189`

**Skill:** `.harness/skills/reviewer.md` @ 1.4.0 · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-5[1m] · **Datum:** 2026-07-29

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde):

- Plan-Artefakte: die zwei Slice-Dateien, dazu
  `docs/plan/planning/welle-09-modul-15-konformitaet.md` und der geschlossene Vorgänger
  `docs/plan/planning/done/slice-059-telemetrie-erfassung-hook.md` samt Closure-Notiz
- Regelwerk (Baseline v3.5.2, vendored): `modul-15-observability.md` (der Gegenstand),
  `modul-05-planning-harness.md` §Ziel-Form: Slice, `modul-06-roadmap.md`
- Vorlagen: `.harness/baseline/v3.5.2/templates/docs/plan/planning/slice.template.md`,
  `.harness/baseline/v3.5.2/templates/docs/reviews/review-report.template.md`
- ADR: [`ADR-0011`](../plan/adr/0011-telemetrie-erfassung-policy.md) (**Accepted**, immutabel)
- Adaptionen: [`MR-000`](../../harness/conventions.md#mr-000--baseline-aussage), [`MR-005`](../../harness/conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption), [`MR-007`](../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache), [`MR-018`](../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
- Hard Rules: [`AGENTS.md`](../../AGENTS.md) §3, besonders §3.1/§3.4/§3.5/§3.6
- Werkzeug-Doku (extern, **nicht** repo-autoritativ, committet vendored):
  `docs/user/claude-hooks-referenz.md`
- Belege aus dem Code, soweit sie eine Plan-Aussage tragen: `internal/span/emit.go`,
  `test/mutations/115-span-ergebnis-inhalt.sh`
- **Keine Gate-Läufe in dieser Sitzung** (Ressourcen-Schranke des Auftrags: die Maschine ist
  heute zweimal an Ressourcenmangel abgestürzt). Jeder Befund unten ist deshalb an einer
  **lesbaren Quelle** belegt, nicht an einem Lauf; die `verifizierbar`-Zeile nennt jeweils, was
  ein Lauf zusätzlich zeigen würde.

---

## Findings

### F-1 — Hintergrund-Subagenten sind der DEFAULT, nicht der Rand: die Datenquelle beider Slices fehlt im Normalfall

- `kategorie`: **HIGH**
- `quelle`: `docs/user/claude-hooks-referenz.md:1572` und `:1581` (die Quelle, auf die
  slice-060 §3 Zeile 4 seine gesamte Herkunfts-Antwort stützt) ·
  [`ADR-0011`](../plan/adr/0011-telemetrie-erfassung-policy.md) Festlegung 1 Punkt 5 ·
  [`AGENTS.md`](../../AGENTS.md) §3.6
- `pfad`: `docs/plan/planning/open/slice-060-rollen-achse.md:46-50` ·
  `docs/plan/planning/open/slice-066-telemetrie-auswertung.md:31-39` und `:46-49`
- `befund`: Die zitierte Referenz sagt in derselben Tabelle, aus der der Plan seine Feldliste
  zieht: *„`"completed"` für Vordergrund-Subagenten, `"async_launched"` für
  Hintergrund-Subagenten. Ab v2.1.198 werden Subagenten **standardmäßig im Hintergrund
  ausgeführt**, daher erzeugt ein weggelassenes `run_in_background` auch `"async_launched"`"*
  (`:1572`), und eine Zeile weiter: *„Für Hintergrund-Subagenten … trägt `tool_response` **keine
  Nutzungsfelder**"* (`:1581`). slice-060 DoD (3) führt diesen Fall als eine von zwei erklärten
  Abweichungen — aber als **Rand** („**Hintergrund**-Subagenten liefern laut Werkzeug-Doku keine
  Nutzungsfelder"), nicht als **Regelfall**. Damit steht die Abweichung über der Zusage: die vier
  `usage`-Zähler, `totalTokens`, `totalDurationMs` und `totalToolUseCount` aus DoD (2) treffen im
  Default-Aufruf gar nicht ein. slice-066 baut darauf seine **beiden** slice-eigenen DoD-Punkte
  (`:31-39`) und schreibt die Voraussetzung als erfüllt fest (`:46-49`: „die Spans tragen …
  sowie die Nutzungstelemetrie der `Agent`-Aufrufe"). Die Aussage der Ist-Messung ist damit
  richtig zitiert und im Umfang falsch gewichtet — dieselbe Klasse wie die Verallgemeinerung aus
  flacher Messung, die derselbe Zug am 2026-07-29 schon einmal produziert hat (`73a4d86`:
  *„Zwei Verallgemeinerungen auf einer flachen Messung"*).
- `failure-szenario`: slice-060 geht nach `done/`, `Agent` ist gelistet, `MR-018` trägt sechs neue
  Felder mit Incident-Fragen — und im Bestand ist keines davon je gefüllt, weil kein Aufruf im
  Vordergrund lief. slice-066 summiert anschließend eine Token-Bilanz über eine leere Menge,
  meldet „0 Token je Rolle" oder wirft alles in den Sammelposten und ist **grün**, weil kein
  Wächter die Population misst, die er zählt. Das ist [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
  eine Ebene weiter: ein Bericht über leerem Prüfbereich.
- `verifizierbar`: ja, ohne Gate — `sed -n '1570,1582p' docs/user/claude-hooks-referenz.md`.
  Zusätzlich messbar am realen Bestand: ein `Agent`-Span, dessen `tool_response` auf `status`
  hin vermessen wird (nur Schlüsselnamen, wie am 2026-07-29 für die übrige Payload geschehen —
  `MR-018` §„Was die Payload sonst noch trägt").

### F-2 — Die Zahlen liegen auf dem Span des AUFRUFERS, die Rolle auf den Spans des Subagenten: slice-066 nennt den falschen Gruppierungs-Schlüssel

- `kategorie`: **HIGH**
- `quelle`: [`MR-018`](../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
  Feldtabelle (`agent_type`/`agent_role`) und §Lesevorschrift · Modul 15
  §Token-Attributions-Regeln · `internal/span/emit.go:96` und `:173-180`
- `pfad`: `docs/plan/planning/open/slice-066-telemetrie-auswertung.md:31-33` ·
  `docs/plan/planning/open/slice-060-rollen-achse.md:40-43` und `:62-64`
- `befund`: `agent_role` wird aus `agent_type` **der Payload des laufenden Agenten** abgeleitet
  (`roleFromAgentType(p.AgentType)`, `emit.go:96`). Ein `Agent`-**Aufruf** ist aber ein Tool-Call
  des **Aufrufers**: sein Span trägt den `agent_type` des Aufrufers — im Regelfall der
  Haupt-Kontext, dort strukturell leer (`MR-018` Abweichung 3). Die Nutzungstelemetrie des
  Subagenten landet damit auf einem Span mit **leerem** `agent_role`. slice-066 DoD (1) summiert
  aber „**je `agent_role`**" und schickt leere Rollen in die Sammelposten-Aufteilung. Der
  Schlüssel, der die Zahlen mit der Rolle des Subagenten verbindet, ist `subagent_type` (bzw.
  `agentId`) aus dem `Agent`-Span — slice-060 DoD (2) erfasst `subagent_type` genau dafür, aber
  **keiner der beiden Pläne benennt den Join**. slice-060 §1 behauptet stattdessen, Zähler und
  Rolle träfen „im **selben** Payload" ein (`:62`) — das stimmt für `subagent_type` + `usage`,
  gilt aber nicht für `agent_role`, das aus einem **anderen** Feld eines **anderen** Spans kommt.
  Die Begründung, warum DoD (1) und DoD (2) in einen Slice gehören, ruht auf dieser Gleichsetzung.
- `failure-szenario`: Die Auswertung läuft, gruppiert nach `agent_role` wie zugesagt, findet die
  gesamte Subagenten-Telemetrie unter `agent_role: ""`, teilt sie nach der Splitting-Regel des
  Haupt-Kontexts auf — und weist damit **die einzigen Zahlen, deren Rolle tatsächlich bekannt
  ist**, als geschätzten Sammelposten aus. Der Bericht sieht korrekt aus, die Prozentsätze aus
  Modul 15 §Token-Attributions-Regeln sind systematisch falsch, und die Zahl „wie groß war der
  aufgeteilte Anteil" (DoD (1), zweite Hälfte) meldet ausgerechnet die Vollständigkeit, die nicht
  besteht.
- `verifizierbar`: ja — `sed -n '90,100p;155,181p' internal/span/emit.go` zeigt die Herkunft von
  `agent_role`; die Payload-Seite steht in `docs/user/claude-hooks-referenz.md:1558-1580`
  (`subagent_type` in `tool_input`, `usage`/`agentId` in `tool_response`). Kein Gate deckt es —
  die Auswertung existiert noch nicht.

### F-3 — Der zugesagte Zahn deckt eine von drei neu geöffneten Freitext-Flächen, und die Grenze „Zahlen ja, Text nein" wird von DoD (2) selbst gebrochen

- `kategorie`: **HIGH**
- `quelle`: [`ADR-0011`](../plan/adr/0011-telemetrie-erfassung-policy.md) Festlegung 2
  (*„Damit wandert kein Byte fremden Inhalts ins Log: Massen-Abfluss … ist **konstruktiv**
  ausgeschlossen, nicht per Regel verboten"*) · [`AGENTS.md`](../../AGENTS.md) §3.6 ·
  `docs/user/claude-hooks-referenz.md:1558-1581`
- `pfad`: `docs/plan/planning/open/slice-060-rollen-achse.md:40-45`
- `befund`: DoD (2) trägt die Regel im Titel — *„für ZAHLEN, nie für Text"* — und bricht sie im
  eigenen Satz: `subagent_type` aus `tool_input` ist eine **Zeichenkette**. Die Referenz zeigt
  drei Freitext-Flächen, die mit dem Listen von `Agent` erreichbar werden, und der Plan benennt
  **eine**: (a) `tool_response.content` — der Antworttext, für den der Zahn zugesagt ist;
  (b) `tool_input.prompt` und `tool_input.description` — der Auftrag an den Subagenten, den
  [`ADR-0011`](../plan/adr/0011-telemetrie-erfassung-policy.md) Festlegung 2 ausdrücklich als
  Grund für den fail-closed Default nennt (*„Betrifft heute u. a. das Agenten-Werkzeug mit seinem
  **Freitext-Prompt**"*); (c) im Hintergrund-Fall trägt `tool_response` laut `:1581` statt der
  Zähler `description`, `prompt` und `outputFile` — also **denselben** Freitext, an der Stelle,
  an der der Emitter nach Zahlen sucht. Ein Zahn, der nur „der Antworttext wandert in den Span"
  rot färbt, lässt (b) und (c) unbewacht. Das ist wörtlich die Klasse, die der Vorgänger-Slice
  dreimal produziert hat („ein Wächter zählt eine Teilmenge dessen, was die Regel fordert",
  Closure-Notiz slice-059, Steering-Loop-Eintrag 1) — hier bereits im Plan angelegt.
  Zusätzlich: der Plan sagt nicht, **wie** die Grenze konstruktiv wird (Typ-Prüfung auf Zahl,
  Feld-Allowlist innerhalb `tool_response`), sondern nur, dass ein Test sie hält — womit die
  Eigenschaft von *konstruktiv ausgeschlossen* auf *durch Disziplin verboten* absinkt, genau die
  Bewegung, die Festlegung 2 begründet ablehnt.
- `failure-szenario`: Die Implementierung liest `tool_response` generisch, extrahiert die
  bekannten Zahlen-Schlüssel und schreibt bei einem Hintergrund-Aufruf `status` plus das, was der
  Parser als „Rest" mitnimmt — `prompt` landet im Span. Der Zahn aus DoD (2) bleibt grün, weil er
  auf den Antworttext eines abgeschlossenen Aufrufs zielt. Der Auftrags-Prompt eines Subagenten
  ist der längste Freitext, den dieses Repo an ein Werkzeug übergibt.
- `verifizierbar`: ja — `sed -n '1558,1582p' docs/user/claude-hooks-referenz.md` zeigt die drei
  Flächen; `test/mutations/115-span-ergebnis-inhalt.sh` zeigt die heutige Zusage, gegen die die
  Erweiterung läuft. Ein Gate deckt es nicht, solange kein Mutations-Fall je Fläche existiert.

### F-4 — `ADR-0011` „Festlegung 5" ist die falsche Fundstelle: gemeint ist Festlegung 1, Punkt 5

- `kategorie`: **MEDIUM**
- `quelle`: [`ADR-0011`](../plan/adr/0011-telemetrie-erfassung-policy.md) Festlegung 1 Punkt 5
  gegen Festlegung 5 · [`AGENTS.md`](../../AGENTS.md) §3.4 (immutable ADR — Verweise darauf
  müssen tragen, weil der Text sich nicht mehr an sie anpasst)
- `pfad`: `docs/plan/planning/open/slice-060-rollen-achse.md:49-50`
- `befund`: DoD (3) begründet die erklärten Abweichungen mit
  „[`ADR-0011`](../plan/adr/0011-telemetrie-erfassung-policy.md) Festlegung 5". **Festlegung 5**
  der ADR entscheidet *„das OB der Emission entscheidet der Change Request, das WIE entscheidet
  diese ADR"* — sie sagt zu Abweichungen nichts. Die tragende Regel ist der **fünfte Punkt der
  numerierten Liste in Festlegung 1**: *„Was auch nach der Ableitung nicht erreichbar ist, wird
  begründet dokumentiert, nicht weggelassen."* Dieselbe Verwechslung steht in der Commit-Message
  zu `1c8b556` (*„Festlegung 5 verlangt nur, das Nicht-Erreichbare BEGRUENDET zu
  dokumentieren"*), ist also kein Tippfehler, sondern eine geführte Lesart.
- `failure-szenario`: Der Implementer folgt dem Verweis, landet bei der Emissions-Festlegung,
  findet dort keine Deckung für DoD (3) — und schließt entweder, die Abweichung sei ungedeckt
  (unnötige Rückkante), oder er übernimmt Festlegung 5 als Begründung und schiebt damit eine
  CR-pflichtige Emissions-Aussage in einen Dogfood-Slice.
- `verifizierbar`: ja — `grep -n "^\*\*Festlegung" docs/plan/adr/0011-telemetrie-erfassung-policy.md`
  gegen `grep -n "Festlegung 5" docs/plan/planning/open/slice-060-rollen-achse.md`. Kein Gate:
  `docs-check` prüft die Existenz der ADR-Datei, nicht die Stelle darin.

### F-5 — Modul 15 §Cache-Counter-Regeln ist auf eine seiner vier Fragen verengt, ohne erklärte Abweichung — und das Label `model.version` hat keine Quelle im Schema

- `kategorie`: **MEDIUM**
- `quelle`: `.harness/baseline/v3.5.2/regelwerk/modul-15-observability.md` §Cache-Counter-Regeln ·
  `docs/plan/planning/welle-09-modul-15-konformitaet.md:97-108` (Closure: je Block **Sensor ODER
  deklarierte Abweichung mit Auflösungs-Trigger**, „nichts dazwischen") ·
  [`ADR-0011`](../plan/adr/0011-telemetrie-erfassung-policy.md) Festlegung 1 Punkt 5
- `pfad`: `docs/plan/planning/open/slice-066-telemetrie-auswertung.md:38-39` ·
  `docs/plan/planning/open/slice-060-rollen-achse.md:40-43` (Feldliste ohne `resolvedModel`)
- `befund`: Der Modul-Abschnitt verlangt **pro Counter** vier Angaben — Name, Unit/Cardinality,
  Labels (*„mindestens `slice.id`, `agent.role`, `model.version`"*) und den Ort der Aggregation —
  plus die Trennung von Hits und Misses. slice-066 DoD (2) übernimmt **nur** die Trennung
  („werden **nie** zu einer Zahl verrechnet"). Die übrigen drei Fragen fallen weg, ohne dass eine
  der beiden Plandateien sie als bewusst nicht umgesetzt führt. Für `model.version` ist der
  Ausfall konkret: die Payload trägt `resolvedModel` (`claude-hooks-referenz.md:1575`), slice-060
  §3 Zeile 2 misst es mit — DoD (2) erfasst es **nicht**. Die Welle verlangt für Block 3 aber
  genau eines von beidem, Sensor oder Deklaration.
- `failure-szenario`: welle-09 wird geschlossen, die 4 × 2-Matrix trägt für Block 3 „Sensor", und
  belegt ist davon ein Drittel einer Regel. Die Lücke ist danach nicht mehr auffindbar — sie steht
  in keinem `MR`, in keinem Trigger und in keinem Plan, weil beide Slices `done/` sind.
- `verifizierbar`: ja — `sed -n '/### Cache-Counter-Regeln/,/### Doku-Konsistenz/p' .harness/baseline/v3.5.2/regelwerk/modul-15-observability.md`
  gegen slice-066 §2. Kein Gate.

### F-6 — Beide Slices tragen keine `LH-*`-ID im Bezug-Block: ihre eigenen Spans führen `requirement` (und bei slice-066 auch `adr`) leer

- `kategorie`: **MEDIUM**
- `quelle`: [`ADR-0011`](../plan/adr/0011-telemetrie-erfassung-policy.md) Festlegung 1 Punkt 4
  (*„`requirement.id` aus der `**Bezug:**`-Zeile der Slice-Datei — gemessen: jeder Slice führt
  seine `LH-*`-IDs maschinenlesbar"*) · [`MR-018`](../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
  Feldtabelle (`requirement`, `adr` — **Pflicht**) · Modul 15 §Kernidee (vier Korrelations-IDs) ·
  `.harness/baseline/v3.5.2/templates/docs/plan/planning/slice.template.md` §2 (die DoD-Punkte der
  Vorlage sind an `LH-*` verankert)
- `pfad`: `docs/plan/planning/open/slice-060-rollen-achse.md:11-18` ·
  `docs/plan/planning/open/slice-066-telemetrie-auswertung.md:11-17` ·
  `internal/span/emit.go:405-425`
- `befund`: `references()` liest Anforderungs- und ADR-Kennungen **ausschließlich** aus dem
  `**Bezug:**`-Block bis zur nächsten Leerzeile. slice-060 nennt dort `MR-000`, `MR-018`,
  `ADR-0011` — **keine** `LH-*`-ID; slice-066 nennt `MR-000`, `MR-018` — **keine** `LH-*`-ID und
  **keinen** ADR (`ADR-0003` steht in §3, außerhalb des Blocks). Der Vorgänger slice-059 führte
  `LH-QA-03` im Bezug und lieferte damit ein gefülltes Feld. Die Entfernung von `LH-QA-01`
  (`96508ff`) ist als Einzelentscheidung **richtig** — die Anforderung spricht von emittierten
  Gate-Targets, nicht von Berichten —, aber sie wurde ohne Ersatz und ohne die Folge für die
  Telemetrie getroffen. Ergebnis: die Welle, die Modul 15 schließt, erzeugt für ihre eigenen zwei
  Slices Spans mit zwei leeren der vier Korrelations-Achsen.
- `failure-szenario`: slice-066 wertet den Bestand aus und findet für den gesamten
  Umsetzungszeitraum von 060/066 `requirement: []` — die Frage „auf wessen Rechnung lief der
  Zugriff" ist für genau die Arbeit unbeantwortbar, die die Antwort bauen sollte. Schlimmer: der
  Befund sieht wie ein Emitter-Defekt aus, obwohl er ein Plan-Defekt ist.
- `verifizierbar`: ja — `sed -n '405,425p' internal/span/emit.go` (Ableitungsregel) gegen
  `sed -n '11,18p'` der beiden Slice-Dateien. Gate-frei belegbar; kein Sensor prüft, ob ein
  Slice-Bezug eine `LH-*`-ID führt.

### F-7 — welle-09 §4 ist mit dem Schnitt nicht nachgezogen: der „Zu slice-060"-Absatz begründet die Datenlage aus Transkripten, die beide Slices ausschließen

- `kategorie`: **MEDIUM**
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §2 (Source Precedence — die Welle steht über dem
  Slice) · [`MR-018`](../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
  Abweichung 1
- `pfad`: `docs/plan/planning/welle-09-modul-15-konformitaet.md:110` und `:144-147`
- `befund`: Zwei Stellen der Welle sind vom Schnitt überholt. (a) `:110` sagt weiter *„Nur der
  erste Slice ist geschnitten … ein leeres `open/` ist ehrlicher als eine driftende
  Vorplanung"*, während `open/` zwei geschnittene Slices trägt. (b) `:144-147` („**Zu
  slice-060:**") begründet die Datenlage der Auswertung mit *„die Sitzungs-Transkripte tragen
  getrennte Hit-/Miss-Zähler … Hit-Rate 96,9 %"* — die Transkript-Brücke ist am 2026-07-29
  entfernt (`1c8b556`), und beide Slices schließen den Zugriff ausdrücklich aus
  (slice-066:48-49). Der Absatz beschreibt zudem inhaltlich slice-**066**, trägt aber die
  Überschrift slice-060. Die Slice-Tabelle selbst (`:129-131`) ist korrekt nachgezogen.
- `failure-szenario`: Der nächste Leser der Welle — Closure-Autor oder der Planner von slice-062 —
  entnimmt der höherrangigen Quelle, die Cache-Zähler kämen aus Transkripten, und baut darauf
  entweder eine Emissions-Entscheidung oder einen Closure-Eintrag. Es ist dieselbe Klasse, die
  der welle-09-Plan-Review vom 2026-07-28 bereits als F-1 gefunden hat („derselbe Stand an zwei
  Orten, einer altert").
- `verifizierbar`: ja — `sed -n '108,112p;143,148p' docs/plan/planning/welle-09-modul-15-konformitaet.md`.
  `make docs-check` deckt es nicht (beide Fassungen sind link-gültig).

### F-8 — `ADR-0011` nennt den Auswerter dreimal „slice-060"; das ist seit dem Schnitt slice-066, und die ADR ist immutabel

- `kategorie`: **MEDIUM**
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.4 · [`ADR-0011`](../plan/adr/0011-telemetrie-erfassung-policy.md)
  Festlegung 1 Punkt 3, Re-Evaluierungs-Trigger 2 und 6
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:78`, `:361`, `:375` gegen
  `docs/plan/planning/open/slice-066-telemetrie-auswertung.md:1-9`
- `befund`: Die ADR verankert drei Aussagen an der Slice-**ID** 060: *„der Auswerter
  (slice-060)"* (`:78`), *„sobald ein Auswertungs-Slice (060) eine Zahl je Rolle ausweisen soll,
  ist die Abbildung zu entscheiden"* (`:361`) und *„wenn nach dem ersten Auswertungs-Slice (060)
  kein Werkzeug über den Default hinaus erfasst wird … ist das Audit faktisch Alternative E"*
  (`:375`). Nach dem Schnitt ist slice-060 die **Rollen-Achse** und slice-066 der Auswerter. Die
  ADR darf nicht nachgezogen werden (§3.4) — die Umdeutung müsste also an genau einer
  auffindbaren Stelle stehen (`MR-018` oder welle-09 §4). Sie steht in keiner der beiden. Der
  dritte Trigger wird durch slice-060 sogar **ausgelöst** (er nimmt `Agent` in die Liste auf),
  nur unter einer anderen ID als der, an die er geknüpft ist.
- `failure-szenario`: Ein späterer Leser prüft Re-Evaluierungs-Trigger 6, liest „slice-060",
  findet dort die Rollen-Achse, sieht ein gelistetes Werkzeug und hakt den Trigger ab — oder er
  findet slice-066 nicht und hält die Auswertung für nie geschnitten. In beiden Fällen wird eine
  Wiederholungs-Entscheidung, die die ADR ausdrücklich erzwingen wollte, durch Nichtstun
  getroffen.
- `verifizierbar`: ja — `grep -n "slice-060\|Auswertungs-Slice" docs/plan/adr/0011-telemetrie-erfassung-policy.md`.
  Kein Gate: `docs-check` prüft ID-Links, nicht Slice-IDs im Fließtext.

### F-9 — Die Doc-Gate-Ausnahme ist Scoping, nicht Lockerung — aber sie steht in keinem Slice-Plan und in keinem `MR`

- `kategorie`: **MEDIUM**
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.5 (geprüft und **nicht** verletzt) ·
  [`MR-001`](../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
  (Geltungsbereich `.d-check.yml`) · [`MR-007`](../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
  (der Präzedenzfall, der die Baseline-Ausnahme trägt) · Modul 5 §Ziel-Form: Slice
- `pfad`: `.d-check.yml:11-17` · `docs/plan/planning/open/slice-060-rollen-achse.md:66-71`
  (Datei-/Komponenten-Tabelle **ohne** `.d-check.yml`)
- `befund`: Zur gestellten Frage zuerst das Ergebnis: die Aufnahme von
  `docs/user/claude-hooks-referenz.md` in `scan.ignore` ist **kein** Fall von §3.5. Kein Modul
  wurde deaktiviert, keine Schwelle gesenkt; ausgenommen wird ein Artefakt, das dieses Repo nicht
  **schreibt** — dieselbe Klasse und dieselbe Begründung wie `.harness/baseline/**`
  (`MR-007`-Linie: committet, damit netzlos zitierbar; extern, nicht repo-autoritativ). Ein ADR
  ist dafür nicht nötig. Der Befund liegt woanders: die Änderung wurde unter dem Namen von
  slice-060 committet (`73a4d86`), erscheint aber in **keiner** der beiden Plandateien — weder in
  der DoD noch in der Datei-/Komponenten-Tabelle —, und ihre Begründung lebt ausschließlich als
  YAML-Kommentar. Die Baseline-Ausnahme daneben ist in `MR-004`/`MR-007` verankert
  (`harness/conventions.md:130`: *„vom Doc-Gate ausgenommen (`.d-check.yml` `scan.ignore`)"*);
  die neue ist es nicht. Damit steht eine Gate-Geltungsbereichs-Entscheidung außerhalb der
  Struktur, die dieses Repo dafür führt. Zweiter, kleinerer Punkt derselben Änderung: die Datei
  liegt unter `docs/user/` — dem Adopter-Baum —, während
  [`ADR-0011`](../plan/adr/0011-telemetrie-erfassung-policy.md) Folgepflicht 3 sagt, die
  Nutzer-Doku bleibe unberührt, solange nicht emittiert wird.
- `failure-szenario`: Der nächste Autor einer vendored Fremd-Doku sucht die Regel in
  `harness/conventions.md`, findet nur die Baseline-Zeile und entscheidet neu — mal Ausnahme, mal
  nicht. Oder umgekehrt: jemand räumt die Ignore-Liste auf, sieht einen Eintrag ohne
  `MR`-Rückhalt und entfernt ihn; `make docs-check` fällt mit 70 `target-missing` aus einer Datei,
  die niemand geschrieben hat.
- `verifizierbar`: ja — `sed -n '4,18p' .d-check.yml` gegen `grep -n "scan.ignore" harness/conventions.md`.
  Ein Gate-Lauf zeigt nur, dass es grün ist, nicht dass es verankert ist.

### F-10 — Ist-Messung Zeile 4 behauptet die Brücke `agentId` → Strom; gemessen ist sie nicht, und DoD (2) erfasst das Feld gar nicht

- `kategorie`: **MEDIUM**
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 · Memory-Regel „grep ist keine Messung" ·
  [`MR-018`](../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
  §„Der Strom ist `(session, agent)` — die FELDER, nicht der Dateiname"
- `pfad`: `docs/plan/planning/open/slice-060-rollen-achse.md:64` und `:40-43`
- `befund`: Die Tabelle ist mit „**Ist-Messung (2026-07-29)**" überschrieben. Zeile 4 lautet
  *„`agentId` verknüpft die Zahlen mit dem **Strom** des Subagenten"*, Beleg-Spalte: *„der
  Strom-Name ist `(session, agent)`; `agentId` aus der Antwort ist dieselbe Kennung"*. Die
  Beleg-Spalte wiederholt die Aussage, statt sie zu belegen — dass die `agentId` aus
  `tool_response` mit dem `agent_id` der Subagenten-Hook-Payload identisch ist, ist plausibel und
  **ungemessen**; die vendored Referenz nennt sie nur *„Kennung für die Subagenten-Ausführung"*
  (`:1573`). Zugleich steht `agentId` **nicht** in der Feldliste von DoD (2). Der Plan begründet
  also mit einer Brücke, die er weder misst noch baut. Es ist die einzige der vier Zeilen, deren
  Beleg kein Artefakt nennt.
- `failure-szenario`: slice-066 versucht die Zuordnung Subagenten-Strom → Zahlen über `agentId`,
  findet das Feld im Span nicht (nie erfasst) oder findet es und es passt nicht auf den
  Strom-Namen — und die Verifikation des Vorgänger-Slice hat genau diese Klasse schon einmal
  bezahlt (`3a1a86d`: „Verifikations-Reste — `agent_type`, `BashOutput`, und ein Artefakt, das
  mir gehört").
- `verifizierbar`: ja, billig — ein `Agent`-Span des Bestands neben dem Strom-Namen des
  zugehörigen Subagenten; beides liegt im gitignorierten Zustands-Bereich. Kein Gate.

### F-11 — Die Feldliste von DoD (2) ruht allein auf der Doku, gegen die bindende Lehre aus `MR-018`

- `kategorie`: **MEDIUM**
- `quelle`: [`MR-018`](../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
  §„Was die Payload sonst noch trägt" (`harness/conventions.md:882`: *„**Die Payload ist die
  Quelle, die Doku ist Herkunft**"*) · [`ADR-0011`](../plan/adr/0011-telemetrie-erfassung-policy.md)
  Re-Evaluierungs-Trigger 1 (die Quelle ist **nicht gepinnt**, kein Gate prüft sie)
- `pfad`: `docs/plan/planning/open/slice-060-rollen-achse.md:62` (Ist-Messung Zeile 2) ·
  `:40-43` (DoD (2))
- `befund`: `MR-018` hält als gemessene Lehre fest, dass der Slice-Plan schon einmal den
  **richtigen** Payload-Namen trug und ihn *„anhand der Doku zum falschen korrigierte"*. Die
  Feldliste in DoD (2) — sechs Felder plus `subagent_type` — stammt vollständig aus derselben
  Doku und ist an keiner realen Payload verifiziert; die Beleg-Spalte nennt ausschließlich
  `docs/user/claude-hooks-referenz.md`. Die Referenz führt zudem Versions-Vorbehalte
  (`resolvedModel`: *„erfordert v2.1.174 oder später"*; `status`: *„ab v2.1.198"*), die der Plan
  nicht mitnimmt — welche Werkzeug-Version hier läuft, steht nirgends.
- `failure-szenario`: Der Implementer baut den Parser gegen die dokumentierte Form, die reale
  Payload weicht in einem Schlüssel ab (Schreibweise, Verschachtelung, Version), die Felder
  bleiben still leer — und weil sie als **Optional** ins Schema gehen, färbt kein
  Pflichtfeld-Wächter rot. Das ist die Fehlerklasse, die diesen Slice am 2026-07-29 bereits einmal
  umgeworfen hat, nur mit umgekehrtem Vorzeichen.
- `verifizierbar`: ja — dieselbe Sonde wie am 2026-07-29, diesmal **eine Ebene tiefer** auf
  `tool_response` eines `Agent`-Spans (nur Schlüsselnamen und Wertlängen). Kein Gate deckt es.

### F-12 — DoD (2) hebt eine Zusage auf, die heute von `test/mutations/115` und `MR-018` getragen wird; kein Plan nennt sie

- `kategorie`: **MEDIUM**
- `quelle`: `test/mutations/115-span-ergebnis-inhalt.sh:5-11` · [`MR-018`](../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
  §Bewacht (`harness/conventions.md:1014`) · `make comment-claims` (Kommentar-Behauptungen nennen
  ihren Sensor)
- `pfad`: `docs/plan/planning/open/slice-060-rollen-achse.md:40-45` und `:66-71`
- `befund`: Der bestehende Mutations-Fall trägt die Zusage *„Vom Ergebnis darf ausschliesslich die
  GROESSE erfasst werden (ADR-0011 Festlegung 2, dieselbe Linie wie bei `tool_input`)"*, und
  `MR-018` führt ihn mit derselben Formulierung („vom Ergebnis darf nur die Länge in den Span").
  DoD (2) macht diesen Satz falsch — künftig werden aus dem Ergebnis auch Zahlen erfasst. Die
  Datei-/Komponenten-Tabelle des Slice führt `test/` + `test/mutations/` ausschließlich als
  **neu**; weder der Fall 115 noch die `Bewacht`-Zeile in `MR-018` sind als **update** vorgesehen.
- `failure-szenario`: Nach der Umsetzung steht im Repo ein Wächter, dessen Kommentar eine Regel
  behauptet, die nicht mehr gilt — und `make comment-claims` bleibt grün, weil es die **Existenz**
  des genannten Sensors prüft, nicht die Wahrheit des Satzes. Der nächste Leser leitet aus 115 ab,
  `tool_response` werde nirgends inhaltlich gelesen, und übersieht die Fläche aus F-3.
- `verifizierbar`: ja — `sed -n '1,14p' test/mutations/115-span-ergebnis-inhalt.sh` gegen
  slice-060 §2 DoD (2). Ein Gate-Lauf zeigt es nicht.

### F-13 — Frage F wurde beim Schnitt zur DoD-Zusage befördert, ohne die Entscheidungs-Notiz, die Frage A bekam

- `kategorie`: **MEDIUM**
- `quelle`: Modul 5 §Ziel-Form: Slice (offene Fragen sind Trigger-Bedingungen) ·
  [`ADR-0011`](../plan/adr/0011-telemetrie-erfassung-policy.md) Festlegung 2 und
  §Konsequenzen (*„jedes Werkzeug, dessen Argumente erfasst werden sollen, muss namentlich
  aufgenommen werden — der Preis von fail-closed, und er ist gewollt"*)
- `pfad`: `docs/plan/planning/open/slice-060-rollen-achse.md:40-45` (DoD (2)), `:73-78`
  (Fragetabelle **ohne** F), `:84-85` (Trigger: „Frage A ist entschieden, damit ist dies die
  einzige verbleibende Bedingung"), `:91-92` (Rückführung `in-progress → open`), `:102-105`
  (§6 führt F weiter als Risiko)
- `befund`: In der Fassung vom 2026-07-29 (`73a4d86`) stand *„**F** — Darf `Agent` ein gelistetes
  Werkzeug werden?"* als offene Frage. Der Schnitt (`2775ef9`) hat sie in eine DoD-Zusage
  überführt und aus der Fragetabelle gestrichen — **ohne** die Notiz „entschieden am … weil …",
  die Frage A ausdrücklich bekommen hat (`:77`). Übrig ist ein Trigger-Satz, der behauptet, nach
  A sei „dies die einzige verbleibende Bedingung", während §6 dieselbe Frage weiter als
  ungelöstes Risiko mit eigener Rückführungskante führt. Die größere der beiden Entscheidungen ist
  damit die undokumentierte. Zur gestellten Frage nach der ADR-Konformität: das **Listen** von
  `Agent` ist ADR-konform — Festlegung 2 knüpft den Default an den Werkzeug-**Namen**, und die
  Konsequenzen sehen die namentliche Aufnahme ausdrücklich vor, der Eintragungsort ist `MR-018`
  (Folgepflicht 1/2). Eine Supersedes-ADR ist **nicht** nötig. Was fehlt, ist die
  Entscheidungs-Spur.
- `failure-szenario`: Der Implementer liest §6 („die Erweiterung trägt nur, wenn der Zahn aus
  DoD (2) sie hält") und §4 („einzige verbleibende Bedingung: WIP-Limit") und muss selbst
  entscheiden, ob F offen ist. Entscheidet er „offen", geht der Slice zurück nach `open/`;
  entscheidet er „geschlossen", implementiert er eine Default-Erweiterung, deren Begründung
  nirgends steht — und der Review dieser Änderung hat nichts, wogegen er prüft.
- `verifizierbar`: ja — `git show 73a4d86 -- docs/plan/planning/open/slice-060-telemetrie-auswertung.md`
  (Frage F angelegt) gegen die heutige Fragetabelle. Kein Gate.

### F-14 — „Zwei namenlose Eimer" steht dreimal: Welle, slice-060 §1, slice-066 §4

- `kategorie`: **LOW**
- `quelle`: Modul 5 §Ziel-Form: Slice (der Plan referenziert, was anderswo entschieden ist) ·
  Closure-Notiz slice-059 (die Wiederholungs-Klasse trat dort dreimal auf)
- `pfad`: `docs/plan/planning/welle-09-modul-15-konformitaet.md:113-116` ·
  `docs/plan/planning/open/slice-060-rollen-achse.md:30-32` ·
  `docs/plan/planning/open/slice-066-telemetrie-auswertung.md:67-68`
- `befund`: Dieselbe Begründung des Schnitts — „genau zwei namenlose Eimer … eine Summe, keine
  Rechnung" — steht wortnah an drei Orten. Die Welle ist die höherrangige Quelle; die Slices
  könnten auf sie zeigen. Zwei weitere Doppelungen derselben Art: slice-060 §6 erster Punkt
  wiederholt DoD (2) („Erweiterung des fail-closed Defaults"), und slice-066 §6 zweiter Punkt
  wiederholt Frage A („der Haupt-Kontext bleibt unerfasst").
- `failure-szenario`: Eine der drei Fassungen wird korrigiert (etwa nach F-2, weil die Rolle sehr
  wohl über `subagent_type` bekannt ist), die anderen bleiben stehen — die im Repo dokumentierte
  Klasse „derselbe Stand an zwei Orten, einer altert".
- `verifizierbar`: ja — `grep -rn "namenlose Eimer" docs/plan/`.

### F-15 — slice-060 Frage B steht unter „vor dem Code zu entscheiden", ist aber ausdrücklich die Entscheidung von slice-062

- `kategorie`: **LOW**
- `quelle`: Modul 5 §Ziel-Form: Slice · welle-09 §4 (slice-062 entscheidet die Tool-Ebene)
- `pfad`: `docs/plan/planning/open/slice-060-rollen-achse.md:73` (Tabellen-Überschrift) und `:78`
- `befund`: Die Tabelle ist überschrieben mit *„Offen, vor dem Code zu entscheiden"*; Frage B sagt
  in ihrer eigenen Zelle, sie sei *„eine Entscheidung von slice-062 — **hier** ist nur zu
  vermeiden, dass die Dogfood-Fassung eine Form bekommt, die den Umzug erschwert"*. Das ist eine
  **Randbedingung** des Slice, keine offene Entscheidung. Der Trigger-Abschnitt behandelt sie
  konsequenterweise auch nicht als Bedingung (`:84-85`).
- `failure-szenario`: Der Implementer hält B für blockierend und wartet auf slice-062 — oder er
  liest die Überschrift als Erlaubnis, die Emissions-Frage hier zu entscheiden, und greift dem CR
  aus [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) vor.
- `verifizierbar`: ja — `sed -n '73,78p' docs/plan/planning/open/slice-060-rollen-achse.md`.

### F-16 — slice-066 zitiert Modul 15 „wörtlich"; die Rollen-Aufzählung des Moduls hat fünf Einträge, `MR-018` sechs

- `kategorie`: **LOW**
- `quelle`: `.harness/baseline/v3.5.2/regelwerk/modul-15-observability.md`
  §Token-Attributions-Regeln (*„Planner · Architect · Implementer · Reviewer · Verifier"*) ·
  [`MR-018`](../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
  (sechs kanonische Typen inkl. `validator`)
- `pfad`: `docs/plan/planning/open/slice-066-telemetrie-auswertung.md:31-33`
- `befund`: DoD (1) beruft sich auf „Modul 15 §Token-Attributions-Regeln, **wörtlich**". Wörtlich
  nennt das Modul fünf Rollen; die Erfassung kennt sechs. Der Bericht wird also über eine Menge
  summieren, die das zitierte Original nicht führt — harmlos, aber das Wort „wörtlich" deckt es
  nicht, und `MR-018` hat die sechste Rolle bewusst gesetzt.
- `failure-szenario`: Ein Verifier prüft DoD (1) gegen den zitierten Modul-Text, findet
  `validator` nicht und meldet eine Abweichung, die keine ist — oder umgekehrt: `validator` fehlt
  im Bericht, weil der Implementer „wörtlich" ernst nimmt.
- `verifizierbar`: ja — `grep -n "Planner · Architect" .harness/baseline/v3.5.2/regelwerk/modul-15-observability.md`
  gegen `harness/conventions.md:840`.

### F-17 — slice-066 trägt drei Liefergegenstände nur in §3, nicht in der DoD; der Schnitt selbst hält

- `kategorie`: **INFO**
- `quelle`: Modul 5 §Ziel-Form: Slice (*„≤ 3 DoD-Punkte"*, *„einzeln lieferbar"*, *„Schnitt nach
  Lieferwert, nicht nach Schichten"*)
- `pfad`: `docs/plan/planning/open/slice-066-telemetrie-auswertung.md:29-42` und `:51-56`
- `befund`: Zur gestellten Frage nach dem Schnitt: er hält. slice-060 hat **drei** slice-eigene
  DoD-Punkte, slice-066 **zwei** — beide innerhalb der Modul-5-Grenze; die drei Standard-Punkte
  (Gates, Doku, Closure) stammen aus der Vorlage und zählen nicht mit. Beide Slices sind einzeln
  lieferbar: slice-060 liefert die gefüllte Rollen-Achse plus die erfasste Subagenten-Telemetrie
  (für sich ein Audit-Gewinn), slice-066 die Rechnung. Die Trennlinie verläuft entlang des
  Lieferwerts (Achse ⇄ Auswertung), nicht entlang von Schichten — die sequentielle Abhängigkeit
  ist in der Welle als **Vorbedingung** benannt und in slice-066 §4 als Trigger verdrahtet.
  *Nicht* zu wenig ist die Zahl **zwei**; zu dünn ist ihre **Deckung**: drei Dinge, die dieser
  Slice liefern muss, stehen ausschließlich in der Tabelle §3 und in keinem prüfbaren DoD-Punkt —
  (a) das `make`-Ziel als Aufrufweg, (b) die **Splitting-Regel als Festlegung in
  `harness/conventions.md`** (die `MR-018`-Lesevorschrift verlangt sie begründet, DoD (1) verlangt
  nur ihre Anwendung), (c) die Antwort auf Frage B (Sitzung oder Bestand), die „jede Zahl ändert"
  und deshalb im Ergebnis stehen müsste, um es lesbar zu machen. Zusammen mit F-5 wäre das eher
  ein dritter DoD-Punkt als eine vierte Tabellenzeile.
- `failure-szenario`: Der Verifier hakt zwei DoD-Punkte ab; die Splitting-Regel steht im Code, der
  Geltungsbereich der Zahlen nirgends. Ein halbes Jahr später ist nicht mehr entscheidbar, über
  welchen Bestand eine archivierte Bilanz gerechnet hat.
- `verifizierbar`: ja — `sed -n '29,56p' docs/plan/planning/open/slice-066-telemetrie-auswertung.md`.

### F-18 — Die Entfernung des Transkript-Zeigers ist ADR-konform; die Begründung in `MR-018` trägt

- `kategorie`: **INFO**
- `quelle`: [`ADR-0011`](../plan/adr/0011-telemetrie-erfassung-policy.md) Festlegung 1 Punkt 4
  und Punkt 5 · [`AGENTS.md`](../../AGENTS.md) §3.4
- `pfad`: `harness/conventions.md:900-915` · `docs/plan/planning/open/slice-060-rollen-achse.md:46-50`
- `befund`: Am Original geprüft, weil der Auftrag die Lesung anzweifelt. Festlegung 1 Punkt 4
  schließt mit: *„ob ein Span, der den `transcript_path` trägt und die Auflösung dem Auswerter
  überlässt, den Mindestsatz **erfüllt oder von ihm abweicht**, entscheidet der umsetzende Slice —
  mit Beleg, nicht per Vorab-Freistellung."* Die ADR **delegiert** diese Wahl also ausdrücklich,
  statt sie zu entscheiden; sie trifft keine Setzung, die eine Supersedes-ADR bräuchte. Die
  getroffene Wahl („abweichen", und zwar samt Entfernung des Zeigers) ist die strengere Seite der
  delegierten Alternative und liegt damit innerhalb der Delegation. Sie ist begründet
  dokumentiert, wie Punkt 5 es verlangt (`conventions.md:900-911`: das Transkript liegt außerhalb
  des Repos, in fremdem Besitz, mit vollem Gesprächsinhalt; ein Zeiger legt eine Auflösung nahe,
  die niemand genehmigt hat) — inklusive der unbequemen Folge im selben Absatz. **Zwei
  Einschränkungen**, die die Konformität nicht kippen: die Fundstelle ist falsch bezeichnet (F-4),
  und die Folge-Zusage *„welche [Quelle] es geben kann, klärt slice-060, bevor er etwas
  verspricht"* (`:912`) ist mit DoD (2) faktisch eingelöst, ohne dass einer der beiden Pläne den
  Satz nachzieht — Abweichung 1 behauptet danach weiter, der Cache-Status sei *„auch nicht
  auflösbar"*, während für Subagenten-Aufrufe zwei Cache-Zähler erfasst werden. Der Satz ist dann
  für den Haupt-Kontext richtig und für Subagenten falsch, und keiner der beiden Pläne plant seine
  Korrektur (slice-060 §3 listet für `conventions.md` nur *„Werkzeug-Tabelle und Feldtabelle …
  die zwei Abweichungen aus DoD (3)"*).
- `failure-szenario`: slice-066 wird gegen `MR-018` Abweichung 1 geprüft, dort steht „nicht
  auflösbar", und DoD (2) des Vorgängers wird als Regelverletzung gelesen — oder umgekehrt: der
  Satz bleibt stehen und ein späterer Slice leitet daraus ab, Cache-Zähler gebe es nirgends.
- `verifizierbar`: ja — `sed -n '898,915p' harness/conventions.md` gegen slice-060 §2 DoD (2).

## Negativbefunde

- geprüft, ohne Befund: **Hard Rule §3.5** (Gate-Lockerung ohne ADR) gegen `.d-check.yml` — die
  Ausnahme ist Scoping eines nicht selbst geschriebenen Artefakts, kein Modul wurde deaktiviert
  und keine Schwelle gesenkt; die Präzedenz `.harness/baseline/**` trägt (der verbleibende Punkt
  ist die fehlende Verankerung, F-9).
- geprüft, ohne Befund: **Hard Rule §3.4** (ADR nach Accepted immutabel) gegen die
  Transkript-Entfernung — die ADR delegiert die Wahl, eine Supersedes-ADR ist nicht nötig (F-18).
- geprüft, ohne Befund: **Hard Rule §3.4** gegen das Listen von `Agent` — Festlegung 2 knüpft den
  Default an den Werkzeug-**Namen**, und die Konsequenzen der ADR sehen die namentliche Aufnahme
  als vorgesehenen Pflege-Vorgang in `MR-018` vor (der Befund liegt beim Zahn, F-3, und bei der
  Entscheidungs-Spur, F-13).
- geprüft, ohne Befund: **Modul 5 §Größen-/Schnitt-Regeln** — 3 bzw. 2 slice-eigene DoD-Punkte,
  beide Slices einzeln lieferbar, Schnitt nach Lieferwert (F-17 ist eine Deckungs-, keine
  Größen-Bemerkung).
- geprüft, ohne Befund: **Ziel-Form Slice** (Vorlage `slice.template.md`) — Lifecycle-Block,
  Welle-Bezug, Bezug, Autor/Datum, §1–§8 vollständig und in der Vorlagen-Reihenfolge; §8
  Sub-Area-Modus-Begründung in beiden Slices vorhanden und plausibel (alle berührten Sub-Areas GF).
- geprüft, ohne Befund: **cp-from-template-Disziplin** — beide Dateien tragen die
  Vorlagen-Struktur einschließlich der Kommentar-Platzhalter in §7.
- geprüft, ohne Befund: **`MR-005`** (Harness-Tools unter `harness/tools/`) — keiner der beiden
  Slices legt Werkzeuge außerhalb dieses Pfades an; slice-066 platziert die Auswertung unter
  `cmd/`/`internal/` (Go, Docker-only, [`ADR-0003`](../plan/adr/0003-go-native-binaries.md)).
- geprüft, ohne Befund: **`MR-000`** — beide Slices führen die Baseline-Aussage in der
  eingegrenzten Fassung („Modul 15 ist adoptiert und in den Blöcken 2–3 unumgesetzt"), nicht in
  der am 2026-07-28 als über-gelesen protokollierten pauschalen Form.
- geprüft, ohne Befund: **`ADR-0011` Festlegung 3/4/6** (Ablageort, Randbedingung, fail-open) —
  keiner der beiden Slices berührt sie; slice-066 liest nur, slice-060 ändert die Feldmenge, nicht
  den Betrieb.
- geprüft, ohne Befund: **welle-09 §4 Slice-Tabelle** — Zeilen für slice-060 und slice-066
  vorhanden, Titel und Reihenfolge stimmen mit den Plänen überein (F-7 betrifft den Fließtext
  daneben, nicht die Tabelle).
- geprüft, ohne Befund: **Lifecycle** — beide Dateien liegen in `open/`, die Trigger benennen die
  Bedingungen für `next`/`in-progress` und beide Rückführungskanten; das WIP-Limit ist in beiden
  genannt.
- **Nicht geprüft** (Ressourcen-Schranke, ausdrücklich benannt statt verschwiegen): kein
  `make gates`, kein `make docs-check`, kein `make mutate`, keine Payload-Messung an einem realen
  `Agent`-Aufruf. Die Befunde F-1, F-10 und F-11 verlangen genau diese Messung — sie ist der
  nächste Schritt, nicht das Ergebnis dieses Reviews.

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 3 |
| MEDIUM | 10 |
| LOW | 3 |
| INFO | 2 |

Zuordnung: **slice-060** trägt F-1 (mit), F-3, F-4, F-6 (mit), F-9, F-10, F-11, F-12, F-13, F-15;
**slice-066** trägt F-1, F-2, F-5, F-6 (mit), F-16, F-17; **welle-09/ADR-Umfeld** trägt F-7, F-8,
F-14, F-18.

## Verdikt

**Merge-blockierend:** **ja** — für beide Slices.

**slice-060 (Rollen-Achse): NICHT KONFORM.** Blockierend ist F-3: die Erweiterung des fail-closed
Defaults aus [`ADR-0011`](../plan/adr/0011-telemetrie-erfassung-policy.md) Festlegung 2 ist im
Grundsatz zulässig — das Listen eines Werkzeugs ist der von der ADR vorgesehene Weg, und eine
Supersedes-ADR braucht es nicht —, aber der zugesagte Zahn deckt eine von drei neu geöffneten
Freitext-Flächen, und die Grenze „Zahlen ja, Text nein" ist im selben DoD-Satz gebrochen
(`subagent_type` ist eine Zeichenkette). In dieser Form ist die Zusage nicht implementierbar, ohne
dass der Implementer die Grenze selbst zieht — genau die Klasse, die der Vorgänger dreimal bezahlt
hat. Dazu F-1 (die erklärte Randabweichung ist der Default-Fall), F-6 (der Slice entzieht seinen
eigenen Spans die `requirement`-Achse) und F-13 (die größte Entscheidung des Slice hat keine
Entscheidungs-Spur).

**slice-066 (Telemetrie-Auswertung): NICHT KONFORM.** Blockierend ist F-2: der in DoD (1) genannte
Gruppierungs-Schlüssel `agent_role` liegt nicht auf den Spans, die die Zahlen tragen — die Bilanz
würde die einzige Telemetrie, deren Rolle bekannt ist, in den Sammelposten schieben. Dazu F-1 (die
Datenquelle fehlt im Default-Fall) und F-5 (Block 3 ist auf eine von vier Modul-Vorgaben verengt,
ohne erklärte Abweichung — was die Welle-Closure später als „Sensor" verbuchen würde). Die Zahl von
**zwei** DoD-Punkten ist dabei **nicht** das Problem; die fehlende Deckung der in §3 versprochenen
Liefergegenstände ist es (F-17).

**Zur Trennlinie selbst: sie liegt richtig.** Rollen-Achse und Auswertung sind zwei
Liefergegenstände mit verschiedenen Vertragsflächen, jeder für sich prüfbar, beide innerhalb der
Modul-5-Grenze. Was zu reparieren ist, sind Zusagen und Belege — nicht der Schnitt.

**Übergabe:** Findings gehen an die Planung (Rückkante Review → Plan bei Plan-Defekt). Der Report
ersetzt keine Verifikation — DoD-/Spec-Konformität prüft der Verifier separat (Modul 11; anderes
Prüf-Artefakt, anderer Eingabe-Kontext). Für F-1, F-10 und F-11 ist die nächste Handlung eine
**Messung an einer realen `Agent`-Payload**, keine weitere Plan-Runde.
