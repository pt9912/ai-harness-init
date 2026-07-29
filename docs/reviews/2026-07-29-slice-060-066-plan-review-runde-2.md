# Review-Report: slice-060 + slice-066 (Plan, Runde 2) — 2026-07-29

**Review-Art:** **Plan** — geprüft wird die **Antwort des Planers** auf den Report vom selben Tag
(`docs/reviews/2026-07-29-slice-060-066-plan-review.md`, 3 HIGH · 10 MEDIUM · 3 LOW · 2 INFO),
nicht der Plan zum zweiten Mal von vorn. Neu auffallende Defekte sind aufgenommen. **Nicht**
geprüft: Code (nur gelesen, soweit er eine Plan-Aussage belegt oder widerlegt), DoD-Abhakung
(Modul 11, getrennter Kontext).

**Gegenstand:**

- `docs/plan/planning/open/slice-060-rollen-achse.md` (Stand `a68c72d`)
- `docs/plan/planning/open/slice-066-telemetrie-auswertung.md` (Stand `a68c72d`)
- die Antwort-Commits `2284189` · `7dc03f2` · `8bdd009` · `a68c72d`

**Skill:** `.harness/skills/reviewer.md` @ 1.4.0 · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-5[1m] · **Datum:** 2026-07-29

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde):

- der Report der Runde 1 (`docs/reviews/2026-07-29-slice-060-066-plan-review.md`) — die
  Befund-Liste, gegen die die Antwort gemessen wird
- Plan-Artefakte: die zwei Slice-Dateien, dazu
  `docs/plan/planning/welle-09-modul-15-konformitaet.md` und der geschlossene Vorgänger
  `docs/plan/planning/done/slice-059-telemetrie-erfassung-hook.md`
- Regelwerk (Baseline v3.5.2, vendored): `modul-15-observability.md`
  §Token-Attributions-Regeln und §Cache-Counter-Regeln, `modul-05-planning-harness.md`
  §Größen-/Schnitt-Regeln, `modul-08-agentenrollen.md`
- ADR: [`ADR-0011`](../plan/adr/0011-telemetrie-erfassung-policy.md) (**Accepted**, immutabel —
  Festlegung 1 Punkt 5, Festlegung 2)
- Adaptionen: [`MR-000`](../../harness/conventions.md#mr-000--baseline-aussage),
  [`MR-005`](../../harness/conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption),
  [`MR-007`](../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache),
  [`MR-018`](../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
- Hard Rules: [`AGENTS.md`](../../AGENTS.md) §3, besonders §3.1/§3.4/§3.5/§3.6
- Werkzeug-Doku (extern, **nicht** repo-autoritativ, committet vendored):
  `docs/user/claude-hooks-referenz.md`
- Belege aus dem Code: `internal/span/emit.go`, `test/mutations/115-span-ergebnis-inhalt.sh`
- **Keine Gate-Läufe in dieser Sitzung** (Ressourcen-Schranke des Auftrags). Jeder Befund ist an
  einer **lesbaren Quelle** belegt; die `verifizierbar`-Zeile nennt, was ein Lauf zusätzlich
  zeigen würde.

**Vorab, weil es die Runde trägt:** die A/B-Messung ist der richtige Zug. Die Prämisse beider
Slices ruhte auf einer Doku-Annahme; sie ruht jetzt auf zwei echten Aufrufen, mit einer Sonde, die
nur Feldnamen und Wertlängen sah und wieder entfernt wurde. Das ist genau die Bewegung, die
[`MR-018`](../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
§„Was die Payload sonst noch trägt" als Lehre führt (*„Die Payload ist die Quelle, die Doku ist
Herkunft"*). Sie hat auch geliefert: `agentType` steht in **keiner** Zeile der vendored Referenz
(`docs/user/claude-hooks-referenz.md:1570-1581`) und ist trotzdem da — ohne Messung wäre der
Schlüssel aus HIGH-2 nicht gefunden worden. Die Befunde unten betreffen, was die Messung **nicht**
abdeckt und was aus ihr **nicht** in die DoD durchgeschlagen ist.

---

## Findings

### F-1 — Der Zahn aus HIGH-3 ist halbiert: DoD (2) verlangt „**eines** dieser vier", §6 desselben Slice verlangt „**alle vier**"

- `kategorie`: **HIGH**
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 (*„Eine Zusage … ist erst fertig, wenn benannt
  ist, was passieren müsste, damit sie bricht, und das einmal rot gesehen wurde"*; *„gelistet
  heißt: wer keinen Fall in `test/mutations/` hat, ist unbewacht"*) ·
  [`ADR-0011`](../plan/adr/0011-telemetrie-erfassung-policy.md) Festlegung 2
- `pfad`: `docs/plan/planning/open/slice-060-rollen-achse.md:54-56` gegen `:122-126`
- `befund`: DoD (2) schließt mit *„der Zahn ist eine Mutation, die **eines dieser vier** in den
  Span wandern lässt"* — Singular, ein Fall für vier Zusagen. §6 erster Punkt sagt zur selben
  Sache: *„Die Erweiterung trägt nur, wenn der Zahn aus DoD (2) **alle vier** abdeckt — eine
  frühere Fassung dieses Plans deckte nur `content`."* Die beiden Sätze widersprechen sich in
  genau der Zahl, um die der Befund HIGH-3 ging. Bindend ist der abhakbare DoD-Punkt, nicht der
  Risiko-Absatz: die Fassung, die der Verifier prüft, ist die schwächere. §3.6 misst je **Zusage**
  — „niemals `content`", „niemals `prompt`", „niemals `description`", „niemals `outputFile`" sind
  vier Zusagen, und drei davon hätten keinen Fall in `test/mutations/`, also nach der Regel des
  Repos den Status **unbewacht**.
- `failure-szenario`: Der Implementer schreibt einen Mutations-Fall auf `content` — den
  naheliegenden, weil er den bestehenden Fall 115 nachahmt —, `make mutate` ist grün, DoD (2) ist
  buchstäblich erfüllt, der Slice geht nach `done/`. Der Auftrags-`prompt` eines Subagenten, den
  [`ADR-0011`](../plan/adr/0011-telemetrie-erfassung-policy.md) Festlegung 2 namentlich als das
  benennt, was nie ins Log darf, ist danach unbewacht — und der Plan hat es in seinem eigenen
  §6 vorhergesagt.
- `verifizierbar`: ja, ohne Gate — `sed -n '54,56p;122,126p' docs/plan/planning/open/slice-060-rollen-achse.md`.
  Ein `make mutate`-Lauf nach der Umsetzung zeigt die Lücke **nicht**: er meldet nur gelistete
  Wächter, die ihre Zähne verloren haben, nicht fehlende Fälle.

### F-2 — DoD (1) koppelt zwei Eigenschaften, die auf **verschiedenen** Pfaden belegt sind: @-Erwähnung (Quelle unauffindbar) und Vordergrund (gemessen am `run_in_background`-Parameter des Werkzeugs)

- `kategorie`: **HIGH**
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 · Memory-Regel *„grep ist keine Messung"* ·
  `docs/user/claude-hooks-referenz.md:1572` (*„Ab v2.1.198 werden Subagenten standardmäßig im
  Hintergrund ausgeführt"*) · [`MR-007`](../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
  (die Linie, aus der die vendored Werkzeug-Doku überhaupt zitierbar ist) · `.d-check.yml:11-17`
  (*„damit die Plaene sie NETZLOS zitieren koennen"*)
- `pfad`: `docs/plan/planning/open/slice-060-rollen-achse.md:41-48` · `:72-74` (Ist-Messung
  Zeilen 1–3) · `:132-135`
- `befund`: DoD (1) verlangt zweierlei in einem Satz: Start **per @-Erwähnung** — *„der Weg, den
  die Werkzeug-Doku als **garantiert** führt"* — **und im Vordergrund**, *„weil im Hintergrund
  gemessen keine Telemetrie ankommt (§3 Zeile 2)"*. Beide Belege tragen die Kopplung nicht.
  (a) Die zitierte Doku-Stelle ist im Repo **nicht auffindbar**: `docs/user/claude-hooks-referenz.md`
  enthält weder den Satz noch einen Abschnitt zum Starten von Subagenten (die Datei verweist auf
  `/docs/de/sub-agents`, das nicht vendored ist); dieselbe Klasse gilt für die zwei Belege in §6
  (*„Kommando-Referenz"*, *„CLI-Hilfe"*) — drei Zitate ohne Fundstelle in einem Repo, das die
  Hooks-Referenz eigens committet hat, damit Pläne netzlos zitieren können. (b) Die Ist-Messung
  ist an **`run_in_background`** gefahren (Zeile 3: *„`tool_input` trägt … `run_in_background`"*),
  also am Parameter des Agenten-**Werkzeugs**. Ob eine @-Erwähnung diesen Parameter auf `false`
  setzt, ist ungemessen — sie geht durch den Haupt-Kontext, und laut derselben Referenz ist der
  weggelassene Parameter seit v2.1.198 **Hintergrund**. Die Prozess-Bedingung, auf der beide
  Slices ruhen, ist damit an ihrem Übergabepunkt unbelegt. Dass der Planer in derselben Sitzung
  eine Quellen-Verschmelzung zurückziehen musste (`8bdd009`), ist dieselbe Klasse eine Datei
  weiter.
- `failure-szenario`: Ein Reviewer wird per `@reviewer` gestartet, der Aufruf läuft nach dem
  Default im Hintergrund, `tool_response` trägt `agentId`/`prompt`/`outputFile` statt Zählern und
  **kein** `agentType`. `agent_role` bleibt leer, der Span sieht normal aus, und slice-066 rechnet
  später über die Teilmenge der Läufe, bei denen es zufällig anders war — ohne dass irgendwo
  steht, wie groß diese Teilmenge ist. Das ist HIGH-1 aus Runde 1, eine Ebene tiefer verschoben.
- `verifizierbar`: ja, billig und ohne Gate — `grep -n "garantiert" docs/user/claude-hooks-referenz.md`
  (die zitierte Formulierung fehlt) und ein einziger realer Lauf: eine Rolle per @-Erwähnung
  starten und im entstehenden `Agent`-Span nachsehen, ob `status` `completed` oder
  `async_launched` lautet. Genau diese eine Messung schließt den Befund.

### F-3 — `agentType` ist ein roher String aus einer Werkzeug-Antwort; kein Plan sagt, was bei einem unbekannten Wert geschieht — und die bindende Lesevorschrift bricht dann eine Ebene höher

- `kategorie`: **MEDIUM**
- `quelle`: [`MR-018`](../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
  §Lesevorschrift (*„Falsch ist nur das eine: den Sammelposten ungeteilt als Rolle führen … das
  erfindet eine Kostenstelle, die es nicht gibt"*) · `internal/span/emit.go:173-180`
  (`roleFromAgentType` kennt sechs Namen, jeder andere Wert ergibt **leer**) ·
  `docs/user/claude-hooks-referenz.md:2114-2116` (Agenten-Typen sind auch `general-purpose`,
  `Explore`, `Plan` und plugin-präfigierte Namen wie `my-plugin:reviewer`)
- `pfad`: `docs/plan/planning/open/slice-066-telemetrie-auswertung.md:33-35` ·
  `docs/plan/planning/open/slice-060-rollen-achse.md:51-53`
- `befund`: slice-066 DoD (1) gruppiert *„je Rolle — die Rolle steht in den `Agent`-Spans als
  `agentType`"*. `agentType` ist der Frontmatter-Name des tatsächlich gelaufenen Agenten, roh und
  unnormalisiert; er trägt bei jedem nicht-rollen-benannten Lauf `general-purpose`, `Explore`,
  `Plan` oder eine Plugin-Kennung. Der Emitter löst denselben Fall heute ausdrücklich auf
  (`roleFromAgentType`: unbekannt ⇒ leer, damit die Lesevorschrift greift); für den **neuen**
  Schlüssel sagt keiner der beiden Pläne, ob dieselbe Ableitung gilt. Die Korrektur aus HIGH-2 ist
  damit an der richtigen Stelle angesetzt und auf halbem Weg stehengeblieben: der Schlüssel stimmt,
  seine Wertemenge ist offen.
- `failure-szenario`: Die Bilanz führt eine Zeile `general-purpose: 62 %` neben
  `reviewer: 8 %`. Das ist wörtlich das, was die Lesevorschrift verbietet — ein ungeteilter
  Sammelposten als Kostenstelle —, nur unter einem Namen, der wie eine Rolle aussieht und deshalb
  keinem Leser auffällt. Der Sammelposten-Anteil aus DoD (1) meldet daneben eine kleine Zahl und
  bestätigt die Vollständigkeit, die nicht besteht.
- `verifizierbar`: ja — `sed -n '155,180p' internal/span/emit.go` gegen slice-066 §2 DoD (1).
  Kein Gate; die Auswertung existiert noch nicht.

### F-4 — DoD (2) nennt die erfassten Werte, nicht ihre Span-Feldnamen — und `agent_type` ist im Schema bereits vergeben, mit anderer Bedeutung

- `kategorie`: **MEDIUM**
- `quelle`: [`MR-018`](../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
  Feldtabelle (*„`agent_type` | Pflicht | … der **Subagent-Typ der Payload**, roh"*) und
  §„Das Schema ist GESCHLOSSEN"
- `pfad`: `docs/plan/planning/open/slice-060-rollen-achse.md:49-56` ·
  `docs/plan/planning/open/slice-066-telemetrie-auswertung.md:33-35`
- `befund`: Der Span führt bereits ein Pflichtfeld `agent_type` — den Typ des Agenten, **in dem**
  der Tool-Call lief. DoD (2) nimmt zusätzlich `agentType` aus `tool_response` auf: den Typ des
  Agenten, **den der Call gestartet hat**. Zwei verschiedene Größen, deren Namen sich um einen
  Unterstrich unterscheiden; der Plan legt für die neue keinen Feldnamen fest, obwohl das Schema
  geschlossen ist und jedes Feld dort namentlich mit Incident-Frage einzutragen ist. slice-066
  DoD (1) verschärft es, indem es den Payload-Namen als Span-Namen verwendet (*„steht in den
  `Agent`-Spans als `agentType`"*).
- `failure-szenario`: Der Implementer schreibt den Wert nach `agent_type` (der Name passt) und
  überschreibt damit die Achse, die für den **Aufrufer** Pflicht ist — im Haupt-Kontext ist sie
  strukturell leer, der Überschreiber fällt niemandem auf. Danach ist an keinem Span mehr
  entscheidbar, ob `agent_type` den laufenden oder den gestarteten Agenten meint, und die
  Lesevorschrift „leer heißt unbekannt" gilt für zwei verschiedene Dinge.
- `verifizierbar`: ja — `grep -n "agent_type" harness/conventions.md` gegen slice-060 §2 DoD (2).
  Kein Gate: `test/mutations/110` bewacht die **Anwesenheit** der Pflichtfelder, nicht die
  Bedeutung ihrer Werte.

### F-5 — Die „Niemals erfasst"-Liste ist an zwei Aufrufen geschlossen worden; die Messung selbst zeigt, dass `tool_response` mehr trägt als jede Liste kennt

- `kategorie`: **MEDIUM**
- `quelle`: [`ADR-0011`](../plan/adr/0011-telemetrie-erfassung-policy.md) Festlegung 2
  (*„Massen-Abfluss … ist **konstruktiv** ausgeschlossen, nicht per Regel verboten"*; die
  Werkzeug-Tabelle definiert je Zeile, **was erfasst wird**) ·
  `docs/user/claude-hooks-referenz.md:1570-1581`
- `pfad`: `docs/plan/planning/open/slice-060-rollen-achse.md:49-56` · `:72-73`
- `befund`: Die Messung ergab in **beide** Richtungen Abweichungen von der Doku: `agentType` ist
  dokumentiert **nicht** vorhanden und real da; `isAsync` und `canReadOutputFile` stehen in der
  Referenz-Aufzählung für Hintergrund-Antworten (`:1581`) ebenfalls nicht. Zwei Aufrufe, beide
  offenbar erfolgreich, und schon vier undokumentierte Schlüssel. Fehlerfälle sind gar nicht
  gemessen — `status` kennt laut Referenz mindestens `completed` und `async_launched`, und was
  eine abgebrochene, verweigerte oder fehlgeschlagene Ausführung zurückgibt, weiß niemand. Der
  Plan schließt die Freitext-Fläche trotzdem mit einer **Negativ**-Liste (*„Niemals erfasst:
  `content`, `prompt`, `description`, `outputFile` — die vier gemessenen Freitext-Felder"*). Die
  Positiv-Liste steht zwar im selben Punkt (*„Erfasst werden aus `tool_response`: …"*), aber der
  Plan sagt an keiner Stelle, dass **sie** die Grenze ist. Genau diese Aussage hatte Runde 1
  verlangt: die Eigenschaft *konstruktiv ausgeschlossen* gegen *durch Disziplin verboten*.
- `failure-szenario`: Der Parser liest `tool_response` generisch und filtert die vier bekannten
  Textfelder heraus. Ein Fehlerlauf liefert `error`/`message`/`stderr` mit dem Ausgabetext eines
  fremden Programms; keiner der vier Namen passt, der Wert wandert in den Span. Der Zahn aus
  DoD (2) bleibt grün, weil er auf die benannten Felder zielt — ein Sensor, der die Liste prüft,
  statt die Grenze.
- `verifizierbar`: ja — `sed -n '1570,1582p' docs/user/claude-hooks-referenz.md` gegen die
  Ist-Messung `sed -n '70,76p' docs/plan/planning/open/slice-060-rollen-achse.md`; die vier
  undokumentierten Schlüssel stehen dort nebeneinander. Ein dritter Sonden-Lauf auf einen
  **fehlgeschlagenen** `Agent`-Aufruf schließt die Lücke.

### F-6 — Die Vordergrund-Bedingung hat keinen Sensor, und das ist nirgends als Grenze benannt; die Bilanz nennt keine Abdeckungszahl

- `kategorie`: **MEDIUM**
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 ·
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (ein
  Bericht über leerem Prüfbereich — dieselbe Klasse eine Ebene weiter) ·
  [`MR-018`](../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
  §Lesevorschrift Punkt 2 (*„wie **groß** der aufgeteilte Anteil war"* als Pflicht, weil dieses
  Repo Annahmen benennt)
- `pfad`: `docs/plan/planning/open/slice-060-rollen-achse.md:41-48` und `:127-131` ·
  `docs/plan/planning/open/slice-066-telemetrie-auswertung.md:58-63` und `:33-41`
- `befund`: Zur ausdrücklich gestellten Frage: die Prozess-Bedingung ist **benannt** (DoD (1),
  §3, §6 zweiter Punkt, Rückführungskante `in-progress → open`) und gehört laut Plan als
  Konvention nach [`MR-018`](../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
  — das ist der richtige Ort. Was fehlt, ist die **Grenze dieser Konvention**: kein Satz in
  beiden Plänen sagt, dass ein Hintergrund-Start **lautlos** durchgeht. §6 behandelt zwei
  verwandte Fälle (Parallelitäts-Kosten; ein falsch benannter Typ liefert `general-purpose` als
  *„ehrliches unbekannt"*) — der dritte, der die Datenlage kippt, fehlt: ein im Hintergrund
  gestarteter Rollen-Lauf erzeugt einen Span **ohne** Zähler und **ohne** `agentType`, und nichts
  färbt rot. Zugleich verlangt slice-066 DoD (1) den aufgeteilten Anteil des Sammelpostens, aber
  **keine** Zahl darüber, wie viele `Agent`-Spans überhaupt Zähler trugen. Für die
  Splitting-Regel ist die Offenlegungspflicht übernommen, für die Erfassungslücke, die die neue
  Prozess-Bedingung erzeugt, nicht.
- `failure-szenario`: Nach drei Wochen Betrieb sind 40 % der Rollen-Läufe versehentlich im
  Hintergrund gestartet. Die Bilanz weist `reviewer: 12 %` aus, rechnet über die restlichen 60 %,
  und weder der Bericht noch ein Gate sagt, dass 40 % der Grundgesamtheit fehlen. Der Leser hält
  eine Stichprobe für eine Messung.
- `verifizierbar`: ja — `sed -n '31,54p' docs/plan/planning/open/slice-066-telemetrie-auswertung.md`
  zeigt, dass keine Abdeckungszahl verlangt wird. Messbar am Bestand: Zahl der `Agent`-Spans
  gegen Zahl der `Agent`-Spans mit Zählern.

### F-7 — `MR-018` Abweichung 1 sagt weiter, der Cache-Status sei *„auch nicht auflösbar"* — slice-066 DoD (2) baut auf ihm auf, und kein Plan zieht den Satz nach

- `kategorie`: **MEDIUM**
- `quelle`: [`MR-018`](../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
  Abweichung 1 (*„die Cache-Zähler aus Modul 15 Block 3 haben ohne eine andere Quelle **keine
  Datengrundlage**; welche es geben kann, klärt slice-060, bevor er etwas verspricht"*) ·
  [`AGENTS.md`](../../AGENTS.md) §2 (Source Precedence)
- `pfad`: `harness/conventions.md:898-916` gegen
  `docs/plan/planning/open/slice-060-rollen-achse.md:49-53` und `:88` ·
  `docs/plan/planning/open/slice-066-telemetrie-auswertung.md:42-46`
- `befund`: Runde 1 hat den Punkt als zweite Einschränkung von F-18 benannt; er ist unverändert.
  slice-060 DoD (2) erfasst `cache_creation_input_tokens` und `cache_read_input_tokens` — damit
  ist die Frage, die Abweichung 1 an slice-060 delegiert, **beantwortet**, aber der Satz in der
  bindenden Adaption bleibt stehen und sagt das Gegenteil. Die Datei-/Komponenten-Tabelle des
  Slice führt für `harness/conventions.md` drei Änderungen auf (Werkzeug- und Feldtabelle,
  Start-Konvention, die zwei Abweichungen aus DoD (3)) — die Korrektur von Abweichung 1 ist
  **nicht** darunter. slice-066 DoD (2) verspricht zugleich getrennte Cache-Zähler, deren
  Datengrundlage die höherrangige Quelle bestreitet.
- `failure-szenario`: Ein Verifier prüft slice-066 DoD (2) gegen
  [`MR-018`](../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung),
  liest *„keine Datengrundlage"* und meldet eine Regelverletzung, die keine ist — oder er glaubt
  dem Satz und streicht den DoD-Punkt. In beiden Fällen entscheidet eine veraltete Zeile über
  einen umgesetzten Slice.
- `verifizierbar`: ja — `sed -n '898,915p' harness/conventions.md` gegen slice-060 §2 DoD (2).
  Kein Gate: `docs-check` prüft Links, nicht Widersprüche.

### F-8 — Modul 15 §Cache-Counter-Regeln bleibt auf zwei von vier Fragen verengt (Runde 1 F-5, halb geschlossen)

- `kategorie`: **MEDIUM**
- `quelle`: `.harness/baseline/v3.5.2/regelwerk/modul-15-observability.md` §Cache-Counter-Regeln
  (*„Die **drei** OTel-Counter … pro Counter:"* Name · Unit/Cardinality · Labels · Aggregation) ·
  `docs/plan/planning/welle-09-modul-15-konformitaet.md:97-108` (je Block **Sensor ODER**
  deklarierte Abweichung, *„nichts dazwischen"*)
- `pfad`: `docs/plan/planning/open/slice-066-telemetrie-auswertung.md:42-46`
- `befund`: DoD (2) hat die **Labels** aufgenommen (`slice.id`, `agent.role`, `model.version` über
  `resolvedModel`) — das war der konkrete Teil des Runde-1-Befunds und ist geschlossen. Die
  übrigen zwei Fragen des Modul-Abschnitts stehen weiter in keinem der beiden Pläne: **Name** und
  **Unit/Cardinality** je Counter, und **wo die Division `hits / (hits + misses)` ausgeführt
  wird**. Der Modul-Abschnitt spricht zudem von **drei** Countern; die DoD nennt zwei Zähler.
  Weder Sensor noch deklarierte Abweichung — die Lage, die die Welle-Closure ausdrücklich
  ausschließt.
- `failure-szenario`: welle-09 wird geschlossen, die Matrix trägt für Block 3 „Sensor", belegt ist
  die Hälfte einer Regel. Danach steht die Lücke in keinem `MR`, keinem Trigger und keinem Plan,
  weil beide Slices `done/` sind.
- `verifizierbar`: ja — `sed -n '/### Cache-Counter-Regeln/,/### Doku-Konsistenz/p' .harness/baseline/v3.5.2/regelwerk/modul-15-observability.md`
  gegen slice-066 §2. Kein Gate.

### F-9 — slice-066 führt weiterhin **keinen** ADR im Bezug-Block; sein `adr`-Pflichtfeld bleibt leer (Runde 1 F-6, halb geschlossen)

- `kategorie`: **MEDIUM**
- `quelle`: [`MR-018`](../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
  Feldtabelle (*„`adr` | Pflicht | … die dritte Korrelations-Achse aus Modul 15 §Kernidee, aus
  demselben `Bezug:`-Block wie `requirement`"*) · `internal/span/emit.go:405-425`
- `pfad`: `docs/plan/planning/open/slice-066-telemetrie-auswertung.md:11-19` (Bezug-Block) gegen
  `:67` ([`ADR-0003`](../plan/adr/0003-go-native-binaries.md) steht in §3, außerhalb des Blocks)
- `befund`: `references()` liest bis zur ersten Leerzeile nach `**Bezug:**`. slice-060 führt jetzt
  `LH-QA-03`, `LH-FA-08` und [`ADR-0011`](../plan/adr/0011-telemetrie-erfassung-policy.md) — dort
  sind beide Achsen gefüllt, der Runde-1-Befund ist für diesen Slice geschlossen. slice-066 führt
  `LH-QA-03`, aber **keinen** ADR; die einzige ADR-Kennung des Slice steht in der
  Datei-Tabelle in §3 und wird von der Ableitung nicht gesehen. Ergebnis unverändert: eine der
  vier Korrelations-Achsen bleibt für den gesamten Umsetzungszeitraum leer — bei dem Slice, der
  die Auswertung dieser Achsen baut.
- `failure-szenario`: slice-066 wertet den eigenen Bestand aus, findet `adr: []` für seine
  gesamte Laufzeit, und der Befund sieht wie ein Emitter-Defekt aus, obwohl er ein Plan-Defekt
  ist — genau die Verwechslung, die Runde 1 beschrieben hat.
- `verifizierbar`: ja — `sed -n '405,425p' internal/span/emit.go` gegen
  `sed -n '11,20p' docs/plan/planning/open/slice-066-telemetrie-auswertung.md`. Kein Sensor prüft
  die Vollständigkeit eines Bezug-Blocks.

### F-10 — welle-09 §4 ist unverändert und steht damit an zwei Stellen gegen die zwei Slices (Runde 1 F-7, offen)

- `kategorie`: **MEDIUM**
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §2 (Source Precedence — die Welle steht über dem Slice)
- `pfad`: `docs/plan/planning/welle-09-modul-15-konformitaet.md:110-111` und `:144-147`
- `befund`: Unverändert seit Runde 1. (a) *„Nur der erste Slice ist geschnitten … ein leeres
  `open/` ist ehrlicher als eine driftende Vorplanung"*, während `open/` zwei geschnittene Slices
  trägt. (b) Der Absatz *„**Zu slice-060:**"* begründet die Datenlage weiter mit
  *„die Sitzungs-Transkripte tragen getrennte Hit-/Miss-Zähler … Hit-Rate 96,9 %"* — die
  Transkript-Brücke ist entfernt, beide Slices schließen den Zugriff aus
  (`slice-066:62-63`), und der Absatz beschreibt inhaltlich slice-**066**. Nach der A/B-Messung
  ist er zusätzlich sachlich überholt: die Zähler kommen aus der Payload.
- `failure-szenario`: Der Closure-Autor oder der Planner von slice-062 entnimmt der
  höherrangigen Quelle, die Cache-Zähler kämen aus Transkripten, und baut darauf eine
  Emissions-Entscheidung.
- `verifizierbar`: ja — `sed -n '108,112p;143,148p' docs/plan/planning/welle-09-modul-15-konformitaet.md`.
  `make docs-check` deckt es nicht.

### F-11 — Die ADR nennt den Auswerter dreimal „slice-060"; die Umdeutung ist nirgends verankert (Runde 1 F-8, offen)

- `kategorie`: **MEDIUM**
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.4 ·
  [`ADR-0011`](../plan/adr/0011-telemetrie-erfassung-policy.md) Festlegung 1 Punkt 3,
  Re-Evaluierungs-Trigger 2 und 6
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:78`, `:361`, `:375` ·
  `harness/conventions.md` (kein Treffer auf `slice-066`) ·
  `docs/plan/planning/welle-09-modul-15-konformitaet.md:131` (nur die Tabellenzeile)
- `befund`: Unverändert. Die ADR ist immutabel und verankert drei Aussagen an der Slice-**ID**
  060, die seit dem Schnitt die Rollen-Achse ist. Die Umdeutung müsste an genau einer
  auffindbaren Stelle stehen ([`MR-018`](../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
  oder welle-09 §4); `grep -n "slice-066"` findet in beiden nur die Slice-Tabellenzeile, die die
  Frage nicht beantwortet. Der dritte Trigger wird von slice-060 sogar **ausgelöst** (er nimmt
  `Agent` in die Liste auf), unter einer anderen ID als der, an die er geknüpft ist.
- `failure-szenario`: Ein späterer Leser prüft Re-Evaluierungs-Trigger 6, liest „slice-060",
  findet die Rollen-Achse, sieht ein gelistetes Werkzeug und hakt ab — eine
  Wiederholungs-Entscheidung, die die ADR erzwingen wollte, wird durch Nichtstun getroffen.
- `verifizierbar`: ja — `grep -n "slice-060\|Auswertungs-Slice" docs/plan/adr/0011-telemetrie-erfassung-policy.md`
  gegen `grep -rn "slice-066" harness/conventions.md docs/plan/planning/welle-09-modul-15-konformitaet.md`.

### F-12 — `test/mutations/115` und die `Bewacht`-Zeile in `MR-018` werden durch DoD (2) falsch; keine Plandatei führt sie als `update` (Runde 1 F-12, offen)

- `kategorie`: **MEDIUM**
- `quelle`: `test/mutations/115-span-ergebnis-inhalt.sh:8-9` (*„Vom Ergebnis darf ausschliesslich
  die GROESSE erfasst werden"*) · [`MR-018`](../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
  §Bewacht (*„vom Ergebnis darf nur die Länge in den Span"*) · `make comment-claims`
- `pfad`: `docs/plan/planning/open/slice-060-rollen-achse.md:84-89` (Datei-/Komponenten-Tabelle:
  `test/` + `test/mutations/` ausschließlich **neu**)
- `befund`: Unverändert. Nach DoD (2) werden aus `tool_response` auch **Zahlen** erfasst; die
  beiden Sätze, die heute das Gegenteil zusagen, stehen in einem Mutations-Fall und in der
  bindenden Adaption. Beide sind als zu ändernde Artefakte in keinem der zwei Pläne genannt.
- `failure-szenario`: Nach der Umsetzung behauptet ein Wächter-Kommentar eine Regel, die nicht
  mehr gilt, und `make comment-claims` bleibt grün, weil es die **Existenz** des genannten Sensors
  prüft, nicht die Wahrheit des Satzes. Der nächste Leser leitet aus 115 ab, `tool_response` werde
  nirgends inhaltlich gelesen.
- `verifizierbar`: ja — `sed -n '1,14p' test/mutations/115-span-ergebnis-inhalt.sh` gegen
  slice-060 §2 DoD (2).

### F-13 — Die Doc-Gate-Ausnahme für die vendored Werkzeug-Doku steht weiter in keinem Plan und in keiner Adaption (Runde 1 F-9, offen)

- `kategorie`: **MEDIUM**
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.5 (geprüft und **nicht** verletzt) ·
  [`MR-001`](../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids) ·
  [`MR-007`](../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
- `pfad`: `.d-check.yml:11-17` · `docs/plan/planning/open/slice-060-rollen-achse.md:84-89`
- `befund`: Unverändert, und die Bewertung aus Runde 1 gilt weiter: die Aufnahme von
  `docs/user/claude-hooks-referenz.md` in `scan.ignore` ist **Scoping**, kein Fall von §3.5 — sie
  braucht kein ADR. Der Befund bleibt die fehlende Verankerung: die Änderung wurde unter dem Namen
  von slice-060 committet, erscheint in keiner der zwei Plandateien, und ihre Begründung lebt
  ausschließlich als YAML-Kommentar, während die Baseline-Ausnahme daneben in
  [`MR-007`](../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
  verankert ist. F-2 dieses Reports zeigt die praktische Folge: derselbe Kommentar begründet die
  Ausnahme mit *„damit die Plaene sie NETZLOS zitieren koennen"*, und der Plan zitiert daneben
  drei Quellen, die **nicht** vendored sind.
- `failure-szenario`: Jemand räumt die Ignore-Liste auf, sieht einen Eintrag ohne Adaptions-
  Rückhalt und entfernt ihn; `make docs-check` fällt mit 70 `target-missing` aus einer Datei, die
  niemand in diesem Repo geschrieben hat.
- `verifizierbar`: ja — `sed -n '4,18p' .d-check.yml` gegen `grep -n "scan.ignore" harness/conventions.md`.

### F-14 — Die zwei `LH-*`-Kennungen sind der **emittierten** Ebene entnommen, während beide Slices Dogfood sind

- `kategorie`: **LOW**
- `quelle`: [`LH-FA-08`](../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren)
  (*„Der Bootstrap **emittiert** die Agenten-Workflow-Commands ins Zielrepo"*) ·
  [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) ·
  [`MR-018`](../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
  Feldtabelle (`requirement`: *„Gegen welche Anforderung?"*) · Memory-Regel
  *„Dogfood vs. emittiert"* · der Vorgänger `slice-059:16-17`
- `pfad`: `docs/plan/planning/open/slice-060-rollen-achse.md:17-21` ·
  `docs/plan/planning/open/slice-066-telemetrie-auswertung.md:16-17`
- `befund`: Der Runde-1-Befund (leeres `requirement`) ist behoben — beide Slices führen jetzt eine
  `LH-*`-Kennung. Die gewählten Kennungen gehören aber zur **Emissions**-Seite:
  [`LH-FA-08`](../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren) verlangt,
  dass der Bootstrap `.claude/commands/` ins Zielrepo emittiert, während slice-060 §6 die Emission
  ausdrücklich ausschließt (*„Nicht in diesem Slice: … die Emission (slice-062/063)"*);
  [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) ist die
  Abhängigkeits-Zusage für das **Tool** und seine Ziel-Repos, nicht für einen
  Dogfood-Auswerter. Der Vorgänger hat dieselbe Kennung geführt und die Ebene **dazugesagt**
  (*„die Zusage für die **emittierte** Seite: ‚Ziel-Repos bleiben make/docker-getrieben'"*); die
  zwei neuen Bezug-Zeilen lesen sie stattdessen als Aussage über das eigene Binary.
- `failure-szenario`: Jeder Tool-Call der beiden Slices wird gegen
  [`LH-FA-08`](../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren) gebucht.
  Wer später fragt „was hat die Workflow-Command-Emission gekostet", bekommt die Kosten einer
  Telemetrie-Arbeit, die diese Anforderung nicht berührt — die Achse ist gefüllt und falsch, was
  schlechter ist als leer und erkennbar.
- `verifizierbar`: ja — `sed -n '199,206p' spec/lastenheft.md` gegen slice-060 §6 letzter Punkt.

### F-15 — Frage B steht weiter unter „Offen, vor dem Code zu entscheiden", ist aber Entscheidung von slice-062 (Runde 1 F-15, offen)

- `kategorie`: **LOW**
- `quelle`: Modul 5 §Ziel-Form: Slice · welle-09 §4
- `pfad`: `docs/plan/planning/open/slice-060-rollen-achse.md:91-95` gegen `:101-105`
- `befund`: Unverändert. Die Tabelle heißt *„Offen, vor dem Code zu entscheiden"*; B sagt in der
  eigenen Zelle, die Entscheidung treffe slice-062, *„**hier** ist nur zu vermeiden, dass die
  Dogfood-Fassung eine Form bekommt, die den Umzug erschwert"* — eine Randbedingung. Der
  Trigger-Abschnitt behandelt sie konsequent nicht als Bedingung (`next → in-progress`: nur
  WIP-Limit). Nach dem Wegfall von A ist B der einzige Eintrag der Tabelle, was die Fehl-Lesung
  wahrscheinlicher macht, nicht unwahrscheinlicher.
- `failure-szenario`: Der Implementer hält B für blockierend und wartet auf slice-062 — oder liest
  die Überschrift als Erlaubnis, die Emissions-Frage hier zu entscheiden, und greift dem CR aus
  [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) vor.
- `verifizierbar`: ja — `sed -n '91,105p' docs/plan/planning/open/slice-060-rollen-achse.md`.

### F-16 — slice-066 zitiert Modul 15 weiter „wörtlich"; der neue Schlüssel verschärft die Abweichung (Runde 1 F-16, offen)

- `kategorie`: **LOW**
- `quelle`: `.harness/baseline/v3.5.2/regelwerk/modul-15-observability.md`
  §Token-Attributions-Regeln (fünf Rollen) ·
  [`MR-018`](../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
  (sechs kanonische Typen inkl. `validator`)
- `pfad`: `docs/plan/planning/open/slice-066-telemetrie-auswertung.md:36-37`
- `befund`: Unverändert: DoD (1) beruft sich auf Modul 15 *„wörtlich"*, das Modul nennt fünf
  Rollen, die Festlegung sechs. Durch die Umstellung auf `agentType` (F-3) ist die Wertemenge
  jetzt sogar unbegrenzt — „wörtlich" deckt weder die sechste Rolle noch die Fremd-Typen.
- `failure-szenario`: Ein Verifier prüft DoD (1) gegen den zitierten Modul-Text, findet
  `validator` nicht und meldet eine Abweichung, die keine ist — oder `validator` fehlt im Bericht,
  weil der Implementer „wörtlich" ernst nimmt.
- `verifizierbar`: ja — `.harness/baseline/v3.5.2/regelwerk/modul-15-observability.md:38`
  (fünf Rollen) gegen `harness/conventions.md:933-937` (sechs kanonische Namen).

### F-17 — „Zwei namenlose Eimer" steht weiter dreimal (Runde 1 F-14, offen)

- `kategorie`: **LOW**
- `quelle`: Modul 5 §Ziel-Form: Slice (der Plan referenziert, was anderswo entschieden ist)
- `pfad`: `docs/plan/planning/welle-09-modul-15-konformitaet.md:113-116` ·
  `docs/plan/planning/open/slice-060-rollen-achse.md:35-36` ·
  `docs/plan/planning/open/slice-066-telemetrie-auswertung.md:81-82`
- `befund`: Unverändert. Dieselbe Begründung des Schnitts steht wortnah an drei Orten; die Welle
  ist die höherrangige Quelle.
- `failure-szenario`: Eine der drei Fassungen wird nachgezogen, die anderen altern — die im Repo
  dokumentierte Klasse „derselbe Stand an zwei Orten, einer altert".
- `verifizierbar`: ja — `grep -rn "namenlose" docs/plan/`.

### F-18 — Modul 5 ist eingehalten; beide Slices stehen jetzt exakt auf der Grenze, und zwei Liefergegenstände aus §3 haben weiter keinen DoD-Punkt

- `kategorie`: **INFO**
- `quelle`: `.harness/baseline/v3.5.2/regelwerk/modul-05-planning-harness.md:71` und `:79`
  (*„Zu groß, wenn eines zutrifft: mehr als drei DoD-Punkte"*; *„hat ≤ 3 DoD-Punkte"*)
- `pfad`: `docs/plan/planning/open/slice-060-rollen-achse.md:41-60` ·
  `docs/plan/planning/open/slice-066-telemetrie-auswertung.md:33-51` und `:65-70`
- `befund`: Zur ausdrücklich gestellten Frage: **eingehalten**. Beide Slices haben genau **drei**
  slice-eigene DoD-Punkte; die drei Standard-Punkte (Gates, Doku, Closure) stammen aus der Vorlage
  und zählen nicht mit. slice-066 hat den dritten für die Splitting-Regel als Festlegung bekommen
  — der Punkt, den Runde 1 als (b) verlangt hatte. Damit ist die Grenze erreicht: die zwei
  übrigen Liefergegenstände aus Runde 1 F-17 haben keinen Platz mehr in der DoD und stehen weiter
  nur in Tabellen — (a) das `make`-Ziel als Aufrufweg (§3) und (c) die Antwort auf Frage B
  (Sitzung oder Bestand, §3), die *„jede Zahl ändert"* und deshalb ins Ergebnis gehörte. Dass die
  Grenze erreicht ist, ist ein Schnitt-Signal, kein Formfehler: F-6 und F-8 verlangen weitere
  prüfbare Zusagen desselben Slice.
- `failure-szenario`: Der Verifier hakt drei DoD-Punkte ab; der Geltungsbereich der Zahlen steht
  nirgends. Ein halbes Jahr später ist nicht mehr entscheidbar, über welchen Bestand eine
  archivierte Bilanz gerechnet hat.
- `verifizierbar`: ja — `sed -n '33,54p' docs/plan/planning/open/slice-066-telemetrie-auswertung.md`.

### F-19 — Die Ist-Messung ist als Messung ausgewiesen und von Behauptung getrennt; eine Zeile der Tabelle stammt aus einer anderen Erhebung

- `kategorie`: **INFO**
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 · Memory-Regel *„grep ist keine Messung"* ·
  [`MR-018`](../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
  §„Was die Payload sonst noch trägt"
- `pfad`: `docs/plan/planning/open/slice-060-rollen-achse.md:67-82` ·
  `docs/plan/planning/open/slice-066-telemetrie-auswertung.md:60-61`
- `befund`: Zur ausdrücklich gestellten Frage: **ja**, mit einer Einschränkung. Die Tabelle nennt
  Datum, Methode (*„A/B an zwei echten Agenten-Aufrufen"*), Umfang (*„nur Feldnamen und
  Wertlängen, nie Werte"*) und trennt in §3 sauber die Folgerung (*„Was daraus folgt"*) vom
  Befund; slice-066 §3 markiert die übernommene Aussage mit *„Gemessen am 2026-07-29"*. Die
  Zeile, die Runde 1 als einzige unbelegte gerügt hatte (`agentId` → Strom), ist **zurückgezogen**
  statt umformuliert. Einschränkung: die Tabellen-Überschrift schreibt alle fünf Zeilen der A/B-
  Erhebung zu; Zeile 5 (*„alle Subagenten-Ströme tragen `agent_type: general-purpose`"*) ist eine
  Bestands-Auszählung über alle Ströme, nicht Teil der zwei Aufrufe — dieselbe Aussage steht in
  [`MR-018`](../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
  Abweichung 3 mit ihrer eigenen Herkunft.
- `failure-szenario`: Ein Leser prüft die A/B-Messung nach, findet zwei Aufrufe und eine Aussage
  über „alle Ströme" in derselben Tabelle, und hält entweder die Bestands-Zahl für unbelegt oder
  die A/B-Zeilen für breiter erhoben, als sie sind.
- `verifizierbar`: ja — `sed -n '67,77p' docs/plan/planning/open/slice-060-rollen-achse.md` gegen
  `grep -n "über alle Ströme" harness/conventions.md`.

## Bilanz der Runde-1-Befunde

| # | Titel (Kurzform) | Kat. | Status | Beleg |
|---|---|---|---|---|
| F-1 | Hintergrund ist Default, Datenquelle fehlt im Normalfall | HIGH | **halb** | Prämisse gemessen, Bedingung in DoD (1) + slice-066 §3; offen: Start-Mechanik ungemessen (F-2), kein Sensor und keine Abdeckungszahl (F-6) |
| F-2 | Falscher Gruppierungs-Schlüssel (`agent_role`) | HIGH | **vollständig** | beide Pläne nennen `tool_response.agentType` und begründen, warum nicht `agent_role`; Restpunkt ist die Wertemenge, nicht der Schlüssel (F-3) |
| F-3 | Zahn deckt eine von drei Freitext-Flächen | HIGH | **halb** | vier Flächen namentlich benannt; DoD (2) verlangt aber nur „eines dieser vier", §6 „alle vier" (F-1 dieses Reports); Allowlist nicht als Mechanik ausgesprochen (F-5) |
| F-4 | Falsche ADR-Fundstelle („Festlegung 5") | MEDIUM | **vollständig** | `slice-060:60` nennt Festlegung 1 Punkt 5; kein Treffer mehr auf „Festlegung 5" |
| F-5 | Cache-Counter-Regeln auf eine von vier Fragen verengt | MEDIUM | **halb** | Labels inkl. `model.version`/`resolvedModel` in DoD (2); Name, Unit/Cardinality, Aggregationsort weiter offen (F-8) |
| F-6 | Kein `LH-*` im Bezug, `requirement`/`adr` leer | MEDIUM | **halb** | `requirement` in beiden Slices gefüllt; slice-066 führt weiter keinen ADR (F-9), und die Ebene der gewählten Kennungen passt nicht (F-14) |
| F-7 | welle-09 §4 nicht nachgezogen | MEDIUM | **offen** | `:110-111` und `:144-147` unverändert (F-10) |
| F-8 | ADR nennt den Auswerter dreimal „slice-060" | MEDIUM | **offen** | keine Umdeutung in der Adaption oder in welle-09 (F-11) |
| F-9 | Doc-Gate-Ausnahme ohne Verankerung | MEDIUM | **offen** | `.d-check.yml` in keiner Plandatei, in keiner Adaption (F-13) |
| F-10 | Unbelegte Brücke `agentId` → Strom | MEDIUM | **vollständig** | Aussage zurückgezogen; `agentId` erscheint nur noch als gemessenes Hintergrund-Feld |
| F-11 | Feldliste ruht allein auf der Doku | MEDIUM | **vollständig** | A/B-Messung an zwei echten Aufrufen, Sonde entfernt; die Messung widerlegt die Doku in vier Schlüsseln |
| F-12 | `test/mutations/115` + `MR-018` §Bewacht werden falsch | MEDIUM | **offen** | Datei-Tabelle führt `test/` weiter nur als **neu** (F-12 dieses Reports) |
| F-13 | Frage F ohne Entscheidungs-Spur | MEDIUM | **vollständig** | `slice-060:97-99` weist die Aufnahme von `Agent` als **Gegenstand** aus, die Namen als datierte Festlegung |
| F-14 | „Zwei namenlose Eimer" dreimal | LOW | **offen** | unverändert (F-17) |
| F-15 | Frage B unter „vor dem Code zu entscheiden" | LOW | **offen** | unverändert (F-15 dieses Reports) |
| F-16 | „wörtlich" gegen fünf/sechs Rollen | LOW | **offen** | unverändert, durch `agentType` verschärft (F-16 dieses Reports) |
| F-17 | Drei Liefergegenstände nur in §3 | INFO | **halb** | (b) Splitting-Regel ist DoD (3) von slice-066; (a) `make`-Ziel und (c) Frage-B-Antwort weiter ohne DoD (F-18) |
| F-18 | Transkript-Entfernung ADR-konform, zwei Einschränkungen | INFO | **halb** | Fundstelle korrigiert (= F-4); Abweichung 1 („auch nicht auflösbar") unverändert (F-7) |

**Summe:** vollständig **5** · halb **6** · offen **7**.

## Negativbefunde

- geprüft, ohne Befund: **HIGH-2 aus Runde 1** — der Gruppierungs-Schlüssel ist in **beiden**
  Plänen korrigiert, mit Begründung an beiden Orten (`slice-060:80-82`, `slice-066:33-35`). Die
  Korrektur ist nicht nur eingetragen, sondern hergeleitet: der `Agent`-Aufruf ist ein Tool-Call
  des Aufrufers.
- geprüft, ohne Befund: **Modul 5 §Größen-/Schnitt-Regeln** — je 3 slice-eigene DoD-Punkte, Grenze
  eingehalten, Schnitt nach Lieferwert unverändert tragfähig (F-18 ist eine Deckungs-, keine
  Größen-Bemerkung).
- geprüft, ohne Befund: **Ziel-Form Slice** — Lifecycle-Block, Welle-Bezug, Bezug, Autor/Datum,
  §1–§8 vollständig und in der Vorlagen-Reihenfolge; §8 Sub-Area-Modus-Begründung in beiden
  Slices vorhanden.
- geprüft, ohne Befund: **[`AGENTS.md`](../../AGENTS.md) §3.4** gegen die Aufnahme von `Agent` in
  die Werkzeug-Liste — [`ADR-0011`](../plan/adr/0011-telemetrie-erfassung-policy.md)
  Festlegung 2 knüpft den Default an den Werkzeug-**Namen** und sieht die namentliche Aufnahme in
  [`MR-018`](../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung) als
  vorgesehenen Pflege-Vorgang vor. Eine Supersedes-ADR ist nach wie vor **nicht** nötig.
- geprüft, ohne Befund: **[`AGENTS.md`](../../AGENTS.md) §3.5** — keine der Änderungen dieser
  Runde senkt eine Schwelle oder deaktiviert ein Modul.
- geprüft, ohne Befund: **[`MR-005`](../../harness/conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption)**
  — keiner der zwei Slices legt Werkzeuge außerhalb der vorgesehenen Pfade an.
- geprüft, ohne Befund: **[`MR-000`](../../harness/conventions.md#mr-000--baseline-aussage)** —
  beide Slices führen die Baseline-Aussage in der eingegrenzten Fassung.
- geprüft, ohne Befund: **Rückzug der Quellen-Verschmelzung** (`8bdd009`) — die Gleichsetzung von
  `/fork` und `/subtask` ist zurückgenommen, beide Belege stehen getrennt bei ihrer Quelle, und
  der Ausschluss ist von der Gleichsetzung unabhängig begründet (Modul 8: Rollen-Trennung ist
  Kontext-Trennung). Der verbleibende Punkt ist die Auffindbarkeit der Quellen, nicht die
  Schlussfolgerung (F-2).
- geprüft, ohne Befund: **Sonden-Disziplin** — die Messung erfasste nach eigener Angabe nur
  Feldnamen und Wertlängen, und die Sonde ist wieder entfernt (`a68c72d`); der Umfang steht in der
  Tabellen-Überschrift, nicht nur in der Commit-Message.
- **Nicht geprüft** (Ressourcen-Schranke, ausdrücklich benannt statt verschwiegen): kein
  `make gates`, kein `make docs-check`, kein `make mutate`, keine eigene Payload-Messung. Die
  Befunde F-2 und F-5 verlangen je **eine** billige Messung — sie sind der nächste Schritt, nicht
  das Ergebnis dieses Reviews.

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 2 |
| MEDIUM | 11 |
| LOW | 4 |
| INFO | 2 |

Zuordnung: **slice-060** trägt F-1, F-2, F-4, F-5, F-6 (mit), F-7 (mit), F-12, F-13, F-14 (mit),
F-15, F-19; **slice-066** trägt F-3, F-6 (mit), F-7 (mit), F-8, F-9, F-14 (mit), F-16, F-18;
**welle-09/ADR-Umfeld** trägt F-10, F-11, F-17.

## Verdikt

**Merge-blockierend:** **ja** — für beide Slices, aber deutlich näher an der Linie als in Runde 1.

**Vorbemerkung zur Bewegung.** Von drei HIGH ist eines **vollständig** geschlossen (HIGH-2, der
Gruppierungs-Schlüssel), und die Doku-Annahme, an der die Runde hing, ist durch eine echte Messung
ersetzt — die Bewegung, die dieses Repo als Regel führt. Fünf der zehn MEDIUM sind erledigt. Die
zwei verbleibenden HIGH sind **Halbierungen**, nicht Ablehnungen: in beiden Fällen ist der richtige
Gegenstand benannt und die Zusage darüber eine Nummer zu klein geraten.

**slice-060 (Rollen-Achse): NICHT KONFORM.** Blockierend sind zwei Punkte, beide klein im Umfang
und groß in der Wirkung. (1) **F-1:** DoD (2) verlangt einen Zahn für *„eines dieser vier"*
Freitext-Felder, §6 desselben Slice verlangt *„alle vier"*. Bindend ist die DoD; ein Verifier hakt
sie mit einem Fall auf `content` ab — der Fassung, die Runde 1 ausdrücklich zurückgewiesen hat.
Nach [`AGENTS.md`](../../AGENTS.md) §3.6 sind es vier Zusagen und damit vier
`test/mutations/`-Fälle. (2) **F-2:** DoD (1) bindet die Telemetrie an eine Start-Mechanik, deren
zwei Hälften auf verschiedenen Pfaden belegt sind — die @-Erwähnung an einer Quelle, die in diesem
Repo nicht auffindbar ist, der Vordergrund am `run_in_background`-Parameter des Werkzeugs. Ob eine
@-Erwähnung im Vordergrund läuft, ist ungemessen, und der dokumentierte Default ist Hintergrund.
Das ist HIGH-1 der Runde 1 an seinem Übergabepunkt. Beide Befunde schließen sich mit **einem**
realen Lauf und einer Zahlenkorrektur, nicht mit einer Plan-Runde. Dazu die MEDIUM F-4 (Feldname
`agentType` gegen das vergebene `agent_type`), F-5 (die Grenze ist als Negativ-Liste formuliert,
obwohl die Messung selbst vier undokumentierte Schlüssel fand), F-6, F-7, F-12, F-13.

**slice-066 (Telemetrie-Auswertung): NICHT KONFORM.** Kein HIGH mehr — der blockierende Befund der
Runde 1 ist geschlossen. Es bleiben MEDIUM, von denen zwei die Zusagen des Slice direkt betreffen:
**F-3** (der neue Schlüssel `agentType` ist ein roher String; für unbekannte Werte sagt kein Plan
etwas, und eine Zeile `general-purpose: 62 %` ist wörtlich das, was die bindende Lesevorschrift
verbietet) und **F-8** (Block 3 bleibt auf zwei von vier Modul-Vorgaben verengt, ohne erklärte
Abweichung — was die Welle-Closure später als „Sensor" verbuchen würde). Dazu F-6 (die Bilanz nennt
den Sammelposten-Anteil, aber nicht die Abdeckung der Grundgesamtheit), F-7 (die höherrangige
Adaption bestreitet die Datengrundlage von DoD (2)), F-9 (`adr` bleibt leer), F-14, F-16, F-18.
Der Slice hängt zusätzlich am Ergebnis von F-2, weil seine Datenlage die Prozess-Bedingung von
slice-060 voraussetzt.

**Zu den drei Fragen des Auftrags, ausdrücklich beantwortet.** *Trägt die Prozess-Bedingung?* Sie
ist benannt und am richtigen Ort verankert, aber ihre **Grenze** ist es nicht: ein
Hintergrund-Start geht lautlos durch, und keine Zahl im Bericht macht die entstehende Lücke
sichtbar (F-6). *Ist `agentType` der richtige Schlüssel?* Ja — er ist die einzige Größe, die die
tatsächlich gelaufene Rolle trägt; was bei einem unbekannten Wert geschieht, ist offen (F-3).
*Deckt die Freitext-Liste alles ab?* Nein, und die Messung beweist es selbst: vier in der
vendored Referenz nicht dokumentierte Schlüssel in zwei Aufrufen, Fehlerfälle ungemessen — eine
Negativ-Liste kann diese Fläche nicht schließen, eine Positiv-Liste schon (F-5).

**Zur Trennlinie: sie liegt weiter richtig.** Beide Slices bleiben einzeln lieferbar und innerhalb
der Modul-5-Grenze; dass beide jetzt exakt auf drei DoD-Punkten stehen, ist ein Signal für den
nächsten Schnitt, kein Formfehler (F-18).

**Übergabe:** Findings gehen an die Planung (Rückkante Review → Plan bei Plan-Defekt). Der Report
ersetzt keine Verifikation — DoD-/Spec-Konformität prüft der Verifier separat (Modul 11; anderes
Prüf-Artefakt, anderer Eingabe-Kontext). Für F-2 und F-5 ist die nächste Handlung je **eine
Messung** (ein Rollen-Start per @-Erwähnung; ein fehlgeschlagener `Agent`-Aufruf), keine weitere
Plan-Runde.
