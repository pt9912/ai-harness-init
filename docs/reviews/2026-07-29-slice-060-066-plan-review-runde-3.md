# Review-Report: slice-060 + slice-066 (Plan, Runde 3) — 2026-07-29

**Review-Art:** **Plan** — geprüft wird die **Antwort des Planers** auf den Report der Runde 2
(`docs/reviews/2026-07-29-slice-060-066-plan-review-runde-2.md`, 2 HIGH · 11 MEDIUM · 4 LOW ·
2 INFO), nicht der Plan zum dritten Mal von vorn. Neu auffallende Defekte sind aufgenommen.
**Nicht** geprüft: Code (nur gelesen, soweit er eine Plan-Aussage belegt oder widerlegt),
DoD-Abhakung (Modul 11, getrennter Kontext).

**Gegenstand:**

- `docs/plan/planning/open/slice-060-rollen-achse.md` (Stand `ed815f3`)
- `docs/plan/planning/open/slice-066-telemetrie-auswertung.md` (Stand `ed815f3`)
- die Antwort-Commits `c6b9023` · `4be1918` · `8f4aa87` · `ed815f3`
  (dazu `3201042`, das die vendored Werkzeug-Doku netzlos macht)

**Skill:** `.harness/skills/reviewer.md` @ 1.4.0 · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-5[1m] · **Datum:** 2026-07-29

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde):

- der Report der Runde 2 — die Befund-Liste, gegen die die Antwort gemessen wird
- Plan-Artefakte: die zwei Slice-Dateien, dazu
  `docs/plan/planning/welle-09-modul-15-konformitaet.md` und der geschlossene Vorgänger
  `docs/plan/planning/done/slice-059-telemetrie-erfassung-hook.md`
- Regelwerk (Baseline v3.5.2, vendored): `modul-05-planning-harness.md` §Ziel-Form: Slice,
  `modul-15-observability.md` §Token-Attributions-Regeln und §Cache-Counter-Regeln,
  `modul-08-agentenrollen.md`
- ADR: [`ADR-0011`](../plan/adr/0011-telemetrie-erfassung-policy.md) (**Accepted**, immutabel —
  Festlegung 1 Punkt 3/4/5, Festlegung 2)
- Adaptionen: [`MR-000`](../../harness/conventions.md#mr-000--baseline-aussage),
  [`MR-005`](../../harness/conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption),
  [`MR-018`](../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
- Hard Rules: [`AGENTS.md`](../../AGENTS.md) §3, besonders §3.1/§3.4/§3.5/§3.6
- Werkzeug-Doku (extern, **nicht** repo-autoritativ, committet vendored):
  `docs/user/claude-hooks-referenz.md`
- Belege aus dem Code: `internal/span/span.go` (`Payload`, `Parse`, `failed`, `commandProgram`),
  `internal/span/emit.go` (`roleFromAgentType`), `test/mutations/115-span-ergebnis-inhalt.sh`,
  `.claude/settings.json`
- **Keine Gate-Läufe in dieser Sitzung** (Ressourcen-Schranke des Auftrags). Jeder Befund ist an
  einer **lesbaren Quelle** belegt; die `verifizierbar`-Zeile nennt, was ein Lauf zusätzlich
  zeigen würde.

**Vorab, weil es die Runde trägt.** Beide HIGH der Runde 2 sind **an ihrem Gegenstand
geschlossen**, und zwar auf dem Weg, den der Report als nächsten Schritt genannt hatte: nicht
durch eine Plan-Runde, sondern durch **zwei weitere Messungen**. Die Trennung „@-Erwähnung wählt
den Typ, `run_in_background` die Betriebsart" ist jetzt belegt statt behauptet — und sie ist
belegt **gegen** die eigene Erwartung des Planers, was die teurere und richtige Richtung ist.
Die Umstellung von der Negativ- auf die **Positiv**-Liste ist die Bewegung, die
[`ADR-0011`](../plan/adr/0011-telemetrie-erfassung-policy.md) Festlegung 2 mit *„konstruktiv
ausgeschlossen, nicht per Regel verboten"* verlangt; der Fehlerfall (`tool_response` fehlt ganz)
bestätigt sie konstruktiv. Die Befunde unten betreffen (a) **eine neue Behauptung**, die die
Antwort selbst eingeführt hat, (b) die Fläche, die die Positiv-Liste **sensorisch** nicht deckt,
und (c) slice-066, das von der Antwort **fast nicht angefasst** wurde, obwohl sie seinen zentralen
Feldnamen ändert.

---

## Findings

### F-1 — Die neue „Aufruf-Konvention" ruht auf zwei Durchsetzungsorten, von denen einer im selben DoD-Punkt widerlegt wird — und die Sensor-Verneinung ist eine Vollständigkeitsaussage ohne Prüfung

- `kategorie`: **HIGH**
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 · Memory-Regel *„grep ist keine Messung"* ·
  [`ADR-0011`](../plan/adr/0011-telemetrie-erfassung-policy.md) §Geschichte-Eintrag 2026-07-28
  (Runde 6: *„die Runde-5-Korrektur ersetzte eine falsche Sensor-**Zusage** durch eine falsche
  Sensor-**Verneinung**"*, als HIGH geführt) · `docs/user/claude-hooks-referenz.md:192`
  (`matcher` filtert Tool-Aufrufe), `:1615` (*„`deny` verhindert den Tool-Aufruf"*) ·
  `.claude/settings.json:3-13` (dieses Repo betreibt einen `PreToolUse`-Hook, `matcher: "Bash"`) ·
  `docs/plan/planning/welle-09-modul-15-konformitaet.md:142` (*„der `PreToolUse`-Guard sieht jeden
  Bash-Aufruf samt Argumenten"*)
- `pfad`: `docs/plan/planning/open/slice-060-rollen-achse.md:56-60` gegen `:42-43` · `:164-170`
- `befund`: Die Antwort verschiebt die Vordergrund-Bedingung von der Nutzer- auf die
  **Aufruf**-Ebene und begründet das als Verbesserung: *„sie liegt dort, wo eine
  `.claude/agents/`-Definition oder ein Kommando sie festschreiben kann"*. Beide genannten Orte
  sind unbelegt, und der erste wird **14 Zeilen darüber vom selben DoD-Punkt widerlegt**: dort
  steht das Frontmatter namentlich als `name`, `description`, `tools`, `model` — kein Feld, das
  eine Betriebsart festlegt. Der zweite Ort („ein Kommando") ist eine Prompt-Datei und damit
  genau das Gedächtnis, dem die Bedingung entzogen werden sollte. §6 zieht daraus die
  unbedingte Aussage *„Und sie hat keinen Sensor."* Diese Aussage ist an keiner Stelle geprüft,
  und die drei Teile eines Sensors liegen im Repo **einzeln belegt** nebeneinander: der
  `PreToolUse`-Guard existiert und läuft (`.claude/settings.json`), sein `matcher` filtert nach
  Tool-Namen (`:192` der vendored Referenz), sein `permissionDecision: "deny"` verhindert den
  Aufruf (`:1615`), und das Feld, um das es geht, liegt in `tool_input` — **vom Planer selbst
  gemessen** (§3 Zeile 5). Ob ein solcher Guard hier gewollt ist, ist eine Planungsfrage; dass
  „kein Sensor" bestehe, ist eine Messaussage und ist nicht gemessen.
- `failure-szenario`: Der Implementer liest §6 *„sie hat keinen Sensor"* als Feststellung, prüft
  die Durchsetzung nicht, legt `.claude/agents/*.md` an und trägt die Konvention in
  [`MR-018`](../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung) ein. Der
  dokumentierte Default bleibt Hintergrund (`docs/user/claude-hooks-referenz.md:1567`), die
  Konvention ist eine aktive Abweichung, die bei **jedem** Aufruf neu hergestellt werden muss.
  Nach vier Wochen meldet die Abdeckungszahl aus slice-066 DoD (1) einen Wert wie 55 % — der
  Befund ist dann korrekt ausgewiesen und **nicht mehr reparabel**, weil die fehlenden Läufe
  vorbei sind. Genau die Klasse, die die Memory-Regel *„Zusage vs. Abdeckung"* führt.
- `verifizierbar`: ja, ohne Gate —
  `sed -n '42,43p;56,60p;164,170p' docs/plan/planning/open/slice-060-rollen-achse.md` gegen
  `sed -n '1,13p' .claude/settings.json` und `sed -n '192p;1615p' docs/user/claude-hooks-referenz.md`.
  Ein `make gates`-Lauf zeigt es **nicht**: die Aussage steht in einem Plan-Absatz.

### F-2 — Die Positiv-Liste ist als Regel richtig gesetzt, aber ihre tragende Zusage („sie hält auch bei einem fünften Feld") hat kein Gegenbeispiel; die vier Zähne bewachen vier **Namen**, nicht die Grenze

- `kategorie`: **MEDIUM**
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 (*„Eine Zusage … ist erst fertig, wenn benannt
  ist, was passieren müsste, damit sie bricht, und das einmal rot gesehen wurde"*) ·
  [`ADR-0011`](../plan/adr/0011-telemetrie-erfassung-policy.md) Festlegung 2 (*„konstruktiv
  ausgeschlossen"*) · `internal/span/span.go:25-34` (der Payload-Kommentar formuliert exakt die
  Eigenschaft, um die es geht: *„Ein neues Feld einer kuenftigen Werkzeug-Version wird NICHT
  still mitgeschrieben"*)
- `pfad`: `docs/plan/planning/open/slice-060-rollen-achse.md:81-83` gegen `:156-158`
- `befund`: Zur ausdrücklich gestellten Frage, ob die Positiv-Liste trägt: **als Regel ja** — sie
  ist eindeutig umsetzbar (sieben namentlich genannte Werte, *„alles andere fällt heraus, ohne
  genannt zu werden"*), und der gemessene Fehlerfall bestätigt sie. **Als Zusage nein.** §6
  begründet die Umstellung mit *„sie hält auch, wenn eine künftige Antwort ein fünftes
  Freitext-Feld bringt"* — das ist die Eigenschaft, für die die Runde-2-Rüge stand. Der Zahn-Satz
  aus DoD (2) prüft sie nicht: er verlangt *„je eine Mutation, die `content`, `prompt`,
  `description` bzw. `outputFile` in den Span wandern lässt"* — vier Fälle auf vier **bekannte
  Namen**. Ein fünfter, ungenannter Schlüssel hat keinen Fall, und nach §3.6 ist damit die
  Eigenschaft, die die ganze Umstellung begründet, **unbewacht**. Die vier Zähne sind zudem die
  alte Negativ-Liste in Sensor-Form: sie unterscheiden eine Positiv-Liste nicht von einer
  Implementierung, die generisch liest und genau diese vier Namen ausfiltert.
- `failure-szenario`: Der Implementer liest `tool_response` in eine offene Map, filtert
  `content`/`prompt`/`description`/`outputFile` heraus und schreibt den Rest. Alle vier Zähne
  sind rot zu bekommen, `make mutate` ist grün, DoD (2) ist buchstäblich abgehakt. Bringt die
  nächste Werkzeug-Version ein `summary` oder ein `errorDetail` in `tool_response`, wandert es
  still in den Span — der Fall, den
  [`ADR-0011`](../plan/adr/0011-telemetrie-erfassung-policy.md) Festlegung 1 Punkt 3 als *„eine
  ungepinnte Quelle"* beschreibt, und den der Plan in §6 ausdrücklich ausgeschlossen zu haben
  glaubt.
- `verifizierbar`: ja, ohne Gate —
  `sed -n '81,83p;156,158p' docs/plan/planning/open/slice-060-rollen-achse.md`. Ein
  `make mutate`-Lauf nach der Umsetzung zeigt die Lücke **nicht**: er meldet gelistete Wächter
  ohne Zahn, nicht fehlende Fälle.

### F-3 — slice-066 ist von der Antwort nicht nachgezogen: sein Gruppierungs-Schlüssel heißt weiter `agentType`, während slice-060 das Span-Feld in `spawned_role` umbenannt hat

- `kategorie`: **MEDIUM**
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §2 (Source Precedence — die zwei Slices derselben
  Welle dürfen sich nicht widersprechen) ·
  [`MR-018`](../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
  §„Das Schema ist GESCHLOSSEN" und §Lesevorschrift · `internal/span/emit.go:173-180`
- `pfad`: `docs/plan/planning/open/slice-066-telemetrie-auswertung.md:33-35` · `:45-48` gegen
  `docs/plan/planning/open/slice-060-rollen-achse.md:75-80`
- `befund`: Die Antwort hat an slice-066 **genau eine** Änderung vorgenommen (die
  Abdeckungszahl, `c6b9023`). Drei Folgen der übrigen Antwort sind nicht angekommen. (a) DoD (1)
  sagt weiter *„die Rolle steht in den `Agent`-Spans als `agentType`"* — slice-060 legt für
  dasselbe Feld jetzt den Namen **`spawned_role`** fest, ausdrücklich, weil `agent_type` bereits
  vergeben ist. Der Auswerter-Slice liest damit ein Feld, das der Erfasser-Slice nicht schreibt.
  (b) Die Normalisierung unbekannter Werte zu leer steht nur in slice-060; slice-066 gruppiert
  weiter über den rohen Wert. (c) DoD (1) wendet die Sammelposten-Aufteilung auf *„Spans mit
  leerem `agent_role`"* an, gruppiert aber über `agentType`/`spawned_role` — zwei Achsen in einem
  Satz. Bei einem `Agent`-Span ist `agent_role` die Rolle des **Aufrufers** und im Haupt-Kontext
  strukturell leer; nach dem Wortlaut fiele damit **jeder** `Agent`-Span in den Sammelposten und
  gleichzeitig in seine Rollen-Zeile. Dieselbe Unklarheit trifft das Label `agent.role` aus
  DoD (2).
- `failure-szenario`: Der Implementer von slice-066 baut die Aggregation auf `agentType`, findet
  das Feld im Bestand nicht (es heißt `spawned_role`), und entweder bleibt die Bilanz leer — oder
  er greift auf das vorhandene `agent_type` zurück, das den **laufenden** Agenten trägt. Dann
  weist die Rechnung `general-purpose` als größte Rolle aus: wörtlich das, was die Lesevorschrift
  verbietet, aus einem reinen Namensversatz zwischen zwei Slices derselben Welle.
- `verifizierbar`: ja — `grep -n "spawned_role\|agentType" docs/plan/planning/open/*.md`; der
  Treffer `spawned_role` steht ausschließlich in slice-060.

### F-4 — Frage C nennt „zwei Reste" und liest sich damit abschließend; die von [`ADR-0011`](../plan/adr/0011-telemetrie-erfassung-policy.md) Festlegung 1 Punkt 4 verlangte Randfall-Entscheidung fehlt, und die Zustands-Brücke vom Prompt-Ereignis zum Tool-Call-Span ist nicht benannt

- `kategorie`: **MEDIUM**
- `quelle`: [`ADR-0011`](../plan/adr/0011-telemetrie-erfassung-policy.md) Festlegung 1 Punkt 4
  (*„**Die Ableitung muss ihre Randfälle mitentscheiden, sonst ist sie keine**"* — mit dem
  Mehrdeutigkeits-Fall als Beispiel: *„liegen **mehrere** `LH-*`-IDs im Bezug …, trägt der Span
  sie **alle**"*) ·
  [`MR-018`](../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
  §„Was auch dann nicht abgedeckt ist" (der Haupt-Strom *„wechselt innerhalb einer Sitzung
  zwischen Planer und Implementation"*) · `internal/span/span.go:75-105` (`Parse` läuft je
  Tool-Call und hält keinen Zustand)
- `pfad`: `docs/plan/planning/open/slice-060-rollen-achse.md:124`
- `befund`: Zur ausdrücklich gestellten Frage: die **Mechanik** ist
  [`ADR-0011`](../plan/adr/0011-telemetrie-erfassung-policy.md)-konform — den Prompt gegen eine
  geschlossene Liste zu halten und ausschließlich die Zuordnung zu schreiben ist strukturell
  `commandProgram` (`internal/span/span.go:210-232`), also *abgeleitet statt roh* aus
  Festlegung 2; *„einer von sieben Werten, kein Teilstring"* schließt den Abfluss konstruktiv
  aus. Die **Restliste** trägt nicht. Sie ist mit *„Zwei Reste"* abschließend formuliert, und
  zwei weitere stehen nicht darin. (a) **Mehrfach-Treffer**: eine Anweisung, die zwei Rollen
  @-erwähnt (*„@reviewer, danach @verifier"*), hat keine Zuordnung — genau die Randfall-Klasse,
  die Festlegung 1 Punkt 4 als Bedingung dafür nennt, dass eine Ableitung überhaupt eine ist;
  der Emitter hat denselben Fall für `requirement.id` bereits entschieden. (b) **Die
  Zustands-Brücke**: `UserPromptSubmit` feuert einmal, die Spans entstehen je Tool-Call in einem
  Prozess, der keinen Zustand hält. Wie der beim Prompt abgeleitete Wert die späteren Spans
  erreicht — und bis wann er gilt —, steht nicht in der Zelle. Das ist der aufwendige Teil, nicht
  die Zuordnung.
- `failure-szenario`: Frage C wird als entscheidbar in den Slice getragen, weil die Restliste
  vollständig aussieht. Beim Umsetzen zeigt sich die Zustands-Frage, sie wird ad hoc über eine
  Datei in `.harness/state/` gelöst, und der Emitter bekommt Zustand zwischen Aufrufen — ein
  Bauteil, das [`ADR-0011`](../plan/adr/0011-telemetrie-erfassung-policy.md) Festlegung 6
  (klemmender, zustandsloser Hook) nie bewertet hat. Der Rückweg `in-progress → next` wird dann
  aus einem Grund gezogen, der in der Frage schon hätte stehen können.
- `verifizierbar`: ja — `sed -n '124p' docs/plan/planning/open/slice-060-rollen-achse.md` gegen
  `sed -n '82,92p' docs/plan/adr/0011-telemetrie-erfassung-policy.md`.

### F-5 — Modul 15 §Cache-Counter-Regeln bleibt auf zwei von vier Fragen verengt (Runde 2 F-8, unverändert)

- `kategorie`: **MEDIUM**
- `quelle`: `.harness/baseline/v3.5.2/regelwerk/modul-15-observability.md`
  §Cache-Counter-Regeln (*„Die **drei** OTel-Counter … pro Counter:"* Name · Unit/Cardinality ·
  Labels · Aggregation) · `docs/plan/planning/welle-09-modul-15-konformitaet.md:17-18` (je Block
  *„entweder einen laufenden Sensor oder eine deklarierte Entscheidung mit Auflösungs-Trigger,
  und nichts dazwischen"*)
- `pfad`: `docs/plan/planning/open/slice-066-telemetrie-auswertung.md:45-49`
- `befund`: Unverändert seit Runde 2. Aufgenommen sind allein die **Labels**. Offen bleiben
  **Name** und **Unit/Cardinality** je Counter sowie der Ort der Division
  `hits / (hits + misses)`; der Modul-Abschnitt spricht von **drei** Countern, die DoD nennt zwei
  Zähler. Weder Sensor noch deklarierte Abweichung.
- `failure-szenario`: welle-09 wird geschlossen, die Matrix trägt für Block 3 „Sensor", belegt ist
  die Hälfte einer Regel. Danach steht die Lücke in keinem `MR`, keinem Trigger und keinem Plan.
- `verifizierbar`: ja — `sed -n '/### Cache-Counter-Regeln/,/### Doku-Konsistenz/p' .harness/baseline/v3.5.2/regelwerk/modul-15-observability.md`
  gegen slice-066 §2. Kein Gate.

### F-6 — slice-066 führt weiterhin **keinen** ADR im Bezug-Block (Runde 2 F-9, unverändert)

- `kategorie`: **MEDIUM**
- `quelle`: [`MR-018`](../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
  Feldtabelle (`adr` ist Pflicht, *„aus demselben `Bezug:`-Block wie `requirement`"*) ·
  `internal/span/emit.go:409` (`references()` liest bis zur ersten Leerzeile nach `**Bezug:**`)
- `pfad`: `docs/plan/planning/open/slice-066-telemetrie-auswertung.md:11-19` gegen `:70`
- `befund`: Unverändert. Der Bezug-Block führt
  [`MR-000`](../../harness/conventions.md#mr-000--baseline-aussage),
  [`MR-018`](../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung) und
  [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) — keinen ADR. Die
  einzige ADR-Kennung des Slice ([`ADR-0003`](../plan/adr/0003-go-native-binaries.md)) steht in
  der Datei-Tabelle in §3 und wird von der Ableitung nicht gesehen. Eine der vier
  Korrelations-Achsen bleibt für den gesamten Umsetzungszeitraum leer — bei dem Slice, der die
  Auswertung dieser Achsen baut.
- `failure-szenario`: slice-066 wertet den eigenen Bestand aus, findet `adr: []` für seine
  gesamte Laufzeit, und der Befund sieht wie ein Emitter-Defekt aus, obwohl er ein Plan-Defekt
  ist.
- `verifizierbar`: ja — `sed -n '11,20p' docs/plan/planning/open/slice-066-telemetrie-auswertung.md`
  gegen `sed -n '409,432p' internal/span/emit.go`.

### F-7 — welle-09 §4 ist zur Hälfte nachgezogen: der Absatz „Zu slice-060:" begründet die Datenlage weiter mit Sitzungs-Transkripten und beschreibt inhaltlich slice-066

- `kategorie`: **MEDIUM**
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §2 (Source Precedence — die Welle steht über dem
  Slice) · `docs/plan/planning/open/slice-066-telemetrie-auswertung.md:66` (*„kein Zugriff
  außerhalb des Repos, kein Transkript"*) · `harness/conventions.md:910-916` (die andere Quelle
  ist inzwischen die **Payload**)
- `pfad`: `docs/plan/planning/welle-09-modul-15-konformitaet.md:145-148`
- `befund`: Teil (a) des Runde-2-Befunds ist geschlossen: `:110-112` nennt jetzt drei
  geschnittene Slices. Teil (b) ist unverändert: *„die Sitzungs-Transkripte tragen getrennte
  Hit-/Miss-Zähler … Hit-Rate 96,9 %"* steht weiter als Begründung der Datenlage in der
  **höherrangigen** Quelle, während beide Slices den Transkript-Zugriff ausschließen und die
  A/B-Messung die Zähler in der Payload gefunden hat. Der Absatz beschreibt zudem inhaltlich
  slice-**066**. Bemerkenswert: derselbe Sachverhalt wurde in
  [`MR-018`](../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
  Abweichung 1 in dieser Runde korrigiert — die Welle ist bei der Korrektur übersprungen worden.
- `failure-szenario`: Der Closure-Autor oder der Planner von slice-062 entnimmt der
  höherrangigen Quelle, die Cache-Zähler kämen aus Transkripten, und baut darauf eine
  Emissions-Entscheidung.
- `verifizierbar`: ja — `sed -n '145,148p' docs/plan/planning/welle-09-modul-15-konformitaet.md`
  gegen `sed -n '908,916p' harness/conventions.md`. `make docs-check` deckt es nicht.

### F-8 — Die ADR nennt den Auswerter dreimal „slice-060"; die Umdeutung ist nirgends verankert (Runde 2 F-11, unverändert)

- `kategorie`: **MEDIUM**
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.4 ·
  [`ADR-0011`](../plan/adr/0011-telemetrie-erfassung-policy.md) Festlegung 1 Punkt 3,
  Re-Evaluierungs-Trigger 2 und 6
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:78`, `:361`, `:375` ·
  `harness/conventions.md` (kein Treffer auf `slice-066`)
- `befund`: Unverändert. Die ADR ist immutabel und verankert drei Aussagen an der Slice-**ID**
  060, die seit dem Schnitt die Rollen-Achse ist (*„der Auswerter (slice-060)"*, *„sobald ein
  Auswertungs-Slice (060) eine Zahl je Rolle ausweisen soll"*, *„nach dem ersten
  Auswertungs-Slice (060)"*). Die Umdeutung müsste an genau einer auffindbaren Stelle stehen;
  `grep -n "slice-066"` findet in
  [`MR-018`](../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung) und
  welle-09 §4 nur die Slice-Tabellenzeile.
- `failure-szenario`: Ein späterer Leser prüft Re-Evaluierungs-Trigger 6, liest „slice-060",
  findet die Rollen-Achse, sieht ein gelistetes Werkzeug und hakt ab — eine
  Wiederholungs-Entscheidung, die die ADR erzwingen wollte, wird durch Nichtstun getroffen.
- `verifizierbar`: ja — `grep -n "slice-060" docs/plan/adr/0011-telemetrie-erfassung-policy.md`
  gegen `grep -rn "slice-066" harness/conventions.md`.

### F-9 — `test/mutations/115` und die `Bewacht`-Zeile in [`MR-018`](../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung) werden durch DoD (2) falsch; keine Plandatei führt sie als `update` (Runde 2 F-12, unverändert)

- `kategorie`: **MEDIUM**
- `quelle`: `test/mutations/115-span-ergebnis-inhalt.sh:8-9` (*„Vom Ergebnis darf ausschliesslich
  die GROESSE erfasst werden"*) · `harness/conventions.md:1017` (*„vom Ergebnis darf nur die
  Länge in den Span"*) · `internal/span/span.go:98-101` (derselbe Satz als Code-Kommentar) ·
  `make comment-claims`
- `pfad`: `docs/plan/planning/open/slice-060-rollen-achse.md:117-118`
- `befund`: Unverändert, und durch die Positiv-Liste geschärft: DoD (2) liest aus
  `tool_response` künftig **sieben benannte Werte**, nicht nur dessen Länge. Drei Stellen sagen
  heute das Gegenteil (Mutations-Kommentar,
  [`MR-018`](../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
  §Bewacht, Emitter-Kommentar). Die Datei-/Komponenten-Tabelle führt `test/` + `test/mutations/`
  weiterhin ausschließlich als **neu**, und die `harness/conventions.md`-Zeile nennt drei zu
  ändernde Stellen, von denen §Bewacht keine ist.
- `failure-szenario`: Nach der Umsetzung behauptet ein Wächter-Kommentar eine Regel, die nicht
  mehr gilt, und `make comment-claims` bleibt grün, weil es die **Existenz** des genannten
  Sensors prüft, nicht die Wahrheit des Satzes. Der nächste Leser leitet aus 115 ab,
  `tool_response` werde nirgends inhaltlich gelesen.
- `verifizierbar`: ja — `sed -n '1,14p' test/mutations/115-span-ergebnis-inhalt.sh` gegen
  slice-060 §2 DoD (2).

### F-10 — Die Doc-Gate-Ausnahme für die vendored Werkzeug-Doku steht weiter in keinem Plan und in keiner Adaption (Runde 2 F-13, unverändert)

- `kategorie`: **MEDIUM**
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.5 (geprüft und **nicht** verletzt) ·
  [`MR-001`](../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids) ·
  [`MR-007`](../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
- `pfad`: `.d-check.yml:11-17` · `docs/plan/planning/open/slice-060-rollen-achse.md:113-118`
- `befund`: Unverändert. Die Aufnahme von `docs/user/claude-hooks-referenz.md` in `scan.ignore`
  ist **Scoping**, kein Fall von §3.5 — sie braucht kein ADR. Der Befund bleibt die fehlende
  Verankerung: die Änderung erscheint in keiner der zwei Plandateien, und ihre Begründung lebt
  ausschließlich als YAML-Kommentar, während die Baseline-Ausnahme daneben in
  [`MR-007`](../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
  verankert ist. Der Commit `3201042` (Bilder lokal statt CDN) hat die Datei in dieser Runde
  erneut angefasst, ohne die Verankerung nachzuziehen.
- `failure-szenario`: Jemand räumt die Ignore-Liste auf, sieht einen Eintrag ohne
  Adaptions-Rückhalt und entfernt ihn; `make docs-check` fällt mit 70 `target-missing` aus einer
  Datei, die niemand in diesem Repo geschrieben hat.
- `verifizierbar`: ja — `sed -n '4,18p' .d-check.yml` gegen
  `grep -n "scan.ignore\|claude-hooks-referenz" harness/conventions.md`.

### F-11 — Der Kopf der Ist-Messung sagt weiter „A/B an **zwei** echten Agenten-Aufrufen"; die Tabelle darunter führt inzwischen **vier** Aufrufe, und §6 spricht von „drei"

- `kategorie`: **LOW**
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 · Memory-Regel *„grep ist keine Messung"* ·
  [`MR-018`](../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
  §„Was die Payload sonst noch trägt"
- `pfad`: `docs/plan/planning/open/slice-060-rollen-achse.md:94-95` gegen `:99-105` und `:159-161`
- `befund`: Die Runde-2-Einschränkung zur Zeile „alle Ströme" ist behoben (Zeile 7 ist jetzt als
  Bestands-Auszählung markiert) — dafür ist der **Umfang** im Kopf veraltet. Er nennt *„A/B an
  zwei echten Agenten-Aufrufen"*, während die Tabelle vier Aufrufe führt (Zeilen 1–4) und Zeile 5
  ausdrücklich *„alle vier"* sagt. §6 nennt für dieselbe Erhebung *„nun drei gemessene Aufrufe"*.
  Drei Zahlen für eine Erhebung, in einer Tabelle, deren Wert genau darin liegt, dass ihr Umfang
  ausgewiesen ist.
- `failure-szenario`: Ein Leser prüft die Messung nach, zählt vier Aufrufe gegen einen Kopf, der
  zwei behauptet, und weiß nicht, welche Zeilen zur ausgewiesenen Sonde gehören — dieselbe
  Unsicherheit, die die Markierung von Zeile 7 gerade beseitigt hat.
- `verifizierbar`: ja —
  `sed -n '94,105p;159,161p' docs/plan/planning/open/slice-060-rollen-achse.md`.

### F-12 — Die Datei-/Komponenten-Tabelle ist der DoD-Änderung nicht gefolgt: „**der** Zahn aus DoD (2)" im Singular, und die `conventions.md`-Zeile kennt weder die Positiv-Liste noch `spawned_role`

- `kategorie`: **LOW**
- `quelle`: Modul 5 §Ziel-Form: Slice (die Tabelle sagt, was angefasst wird) ·
  [`MR-018`](../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
  §„Das Schema ist GESCHLOSSEN" (jedes Feld namentlich mit Incident-Frage)
- `pfad`: `docs/plan/planning/open/slice-060-rollen-achse.md:117-118` gegen `:65-83`
- `befund`: DoD (2) verlangt seit dieser Runde **vier** Zähne; die Tabelle nennt weiter *„der
  Zahn aus DoD (2)"*. Die `harness/conventions.md`-Zeile führt *„Werkzeug- und Feldtabelle, die
  Start-Konvention, die zwei Abweichungen aus DoD (3)"* — der neue Feldname `spawned_role` und
  die Umstellung auf eine Positiv-Liste, die beide in
  [`MR-018`](../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung) landen
  müssen, stehen nicht darin.
- `failure-szenario`: Der Implementer arbeitet die Tabelle ab (sie ist die kürzere Liste),
  schreibt einen Mutations-Fall und trägt drei Dinge in die Adaption ein. Die Differenz zur DoD
  fällt erst dem Verifier auf, wenn der Code steht.
- `verifizierbar`: ja — `sed -n '113,118p' docs/plan/planning/open/slice-060-rollen-achse.md`.

### F-13 — [`MR-018`](../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung) Abweichung 1 ist korrigiert, sagt aber im Präsens „slice-060 erfasst ihn" über einen Slice in `open/`

- `kategorie`: **LOW**
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.1 (nichts behaupten, was nicht läuft) ·
  Memory-Regel *„Zusage vs. Abdeckung"*
- `pfad`: `harness/conventions.md:910-916`
- `befund`: Der Runde-2-Befund (*„keine Datengrundlage"*) ist geschlossen, und die Korrektur ist
  sauber begrenzt (*„Nicht erreichbar bleibt er für den Haupt-Kontext und für
  Hintergrund-Läufe"*). Die Klammer *„(slice-060 erfasst ihn)"* steht im Präsens in einer
  **bindenden** Adaption, während slice-060 in `open/` liegt und keine Zeile Code existiert. Die
  Messung (*„ein `Agent`-Aufruf im Vordergrund trägt … ein `usage`-Objekt"*) ist belegt; die
  Erfassung ist es nicht.
- `failure-szenario`: slice-060 wird re-geschnitten oder verschoben. Die Adaption sagt weiter,
  der Cache-Status werde erfasst; ein Auswerter sucht ein Feld, das es nicht gibt, und hält die
  Lücke für einen Emitter-Defekt.
- `verifizierbar`: ja — `sed -n '908,916p' harness/conventions.md` gegen
  `ls docs/plan/planning/open/`.

### F-14 — Die Tabelle „Offen, vor dem Code zu entscheiden" enthält nach wie vor keine Frage, die vor dem Code zu entscheiden wäre — jetzt zwei statt einer (Runde 2 F-15, verschärft)

- `kategorie`: **LOW**
- `quelle`: Modul 5 §Ziel-Form: Slice · welle-09 §4
- `pfad`: `docs/plan/planning/open/slice-060-rollen-achse.md:120-125` gegen `:133-135`
- `befund`: Unverändert und um einen Eintrag gewachsen. B sagt in der eigenen Zelle, die
  Entscheidung treffe slice-062; C sagt in der eigenen Zelle *„Bewusst **kein** vierter
  DoD-Punkt"* — also gerade, dass hier nichts entschieden wird. Der Trigger-Abschnitt behandelt
  konsequent keine der beiden als Bedingung (`next → in-progress`: nur WIP-Limit). Nebenbei steht
  C **vor** B, ohne dass die Reihenfolge etwas bedeutet.
- `failure-szenario`: Der Implementer hält C für blockierend und baut die Prompt-Ableitung mit —
  einen vierten Liefergegenstand ohne DoD-Punkt, an dem kein Zahn hängt.
- `verifizierbar`: ja — `sed -n '120,135p' docs/plan/planning/open/slice-060-rollen-achse.md`.

### F-15 — slice-066 zitiert Modul 15 weiter „wörtlich"; die Rollenzahl stimmt nicht (Runde 2 F-16, unverändert)

- `kategorie`: **LOW**
- `quelle`: `.harness/baseline/v3.5.2/regelwerk/modul-15-observability.md`
  §Token-Attributions-Regeln (fünf Rollen) ·
  [`MR-018`](../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
  (sechs kanonische Typen inkl. `validator`)
- `pfad`: `docs/plan/planning/open/slice-066-telemetrie-auswertung.md:36-37`
- `befund`: Unverändert: DoD (1) beruft sich auf Modul 15 *„wörtlich"*, das Modul nennt fünf
  Rollen, die Festlegung in der Adaption sechs.
- `failure-szenario`: Ein Verifier prüft DoD (1) gegen den zitierten Modul-Text, findet
  `validator` nicht und meldet eine Abweichung, die keine ist.
- `verifizierbar`: ja — `.harness/baseline/v3.5.2/regelwerk/modul-15-observability.md:38` gegen
  `harness/conventions.md:936-939`.

### F-16 — „Zwei namenlose Eimer" steht weiter dreimal (Runde 2 F-17, unverändert)

- `kategorie`: **LOW**
- `quelle`: Modul 5 §Ziel-Form: Slice (der Plan referenziert, was anderswo entschieden ist)
- `pfad`: `docs/plan/planning/welle-09-modul-15-konformitaet.md:114-119` ·
  `docs/plan/planning/open/slice-060-rollen-achse.md:35-37` ·
  `docs/plan/planning/open/slice-066-telemetrie-auswertung.md:84-85`
- `befund`: Unverändert. Dieselbe Begründung des Schnitts steht wortnah an drei Orten; die Welle
  ist die höherrangige Quelle. In dieser Runde wurde der Absatz in welle-09 **direkt darüber**
  angefasst (`c6b9023`), ohne die Dreifachung zu berühren.
- `failure-szenario`: Eine der drei Fassungen wird nachgezogen, die anderen altern.
- `verifizierbar`: ja — `grep -rn "namenlose" docs/plan/`.

### F-17 — Die zwei `LH-*`-Kennungen bleiben der **emittierten** Ebene entnommen (Runde 2 F-14, unverändert)

- `kategorie`: **LOW**
- `quelle`: [`LH-FA-08`](../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren) ·
  [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) ·
  Memory-Regel *„Dogfood vs. emittiert"* · der Vorgänger `slice-059:16-17`
- `pfad`: `docs/plan/planning/open/slice-060-rollen-achse.md:17-21` ·
  `docs/plan/planning/open/slice-066-telemetrie-auswertung.md:16-17`
- `befund`: Unverändert. slice-060 benennt die Ebene immerhin (*„das **Dogfood**-Gegenstück"*),
  bucht seine Tool-Calls aber weiter gegen
  [`LH-FA-08`](../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren), während
  §6 die Emission ausdrücklich ausschließt; slice-066 führt
  [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) ohne Ebenen-Angabe.
- `failure-szenario`: Wer später fragt „was hat die Workflow-Command-Emission gekostet", bekommt
  die Kosten einer Telemetrie-Arbeit, die diese Anforderung nicht berührt — die Achse ist gefüllt
  und falsch, was schlechter ist als leer und erkennbar.
- `verifizierbar`: ja — `sed -n '199,206p' spec/lastenheft.md` gegen slice-060 §6 letzter Punkt.

### F-18 — Modul 5 ist eingehalten; beide Slices stehen weiter exakt auf drei DoD-Punkten, und Frage C verzichtet ausdrücklich deshalb auf einen vierten

- `kategorie`: **INFO**
- `quelle`: `.harness/baseline/v3.5.2/regelwerk/modul-05-planning-harness.md:71` und `:79-81`
  (*„Zu groß, wenn eines zutrifft: mehr als drei DoD-Punkte"*; *„hat ≤ 3 DoD-Punkte"*)
- `pfad`: `docs/plan/planning/open/slice-060-rollen-achse.md:41-90` ·
  `docs/plan/planning/open/slice-066-telemetrie-auswertung.md:33-57`
- `befund`: Zur ausdrücklich gestellten Frage: **eingehalten**. Beide Slices haben genau **drei**
  slice-eigene DoD-Punkte; die drei Standard-Punkte (Gates, Doku, Closure) stammen aus der
  Vorlage. Die Antwort hat den Umfang **innerhalb** der Punkte vergrößert (DoD (1) trägt jetzt
  zwei nummerierte Unterbedingungen, DoD (2) Positiv-Liste + Feldname + Normalisierung + vier
  Zähne) — das ist formal kein Verstoß, aber die Grenze ist nicht nur erreicht, sie ist gefüllt.
  Frage C zieht daraus ausdrücklich die richtige Konsequenz (*„Bewusst kein vierter DoD-Punkt:
  Modul 5 setzt die Grenze bei drei"*) — womit ein entschiedenes C keinen DoD-Platz hätte und
  einen eigenen Slice bräuchte. Die übrigen Modul-5-Kriterien (einzeln lieferbar, ≤ zwei
  Schichten, in einer Review-Sitzung prüfbar) sind erfüllt.
- `failure-szenario`: Frage C wird bejaht und ohne DoD-Punkt mitgebaut; die Zusage hat keinen
  abhakbaren Ort und keinen Zahn.
- `verifizierbar`: ja — `grep -c "^- \[ \]" docs/plan/planning/open/slice-06*.md` (je 6, davon
  3 aus der Vorlage).

### F-19 — Die zwei neuen Messungen sind sauber ausgewiesen, und die Fehlerfall-Messung trägt mehr, als der Plan aus ihr zieht

- `kategorie`: **INFO**
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 ·
  [`ADR-0011`](../plan/adr/0011-telemetrie-erfassung-policy.md) Festlegung 1 Punkt 3
  (geschlossenes Schema) · `internal/span/span.go:25-34`, `:120-140` (`failed()` liest das
  Top-Level-`error` als **Vorhandensein**, nie als Wert)
- `pfad`: `docs/plan/planning/open/slice-060-rollen-achse.md:101-102` · `:156-161`
- `befund`: Zur ausdrücklich gestellten Frage nach der Fehlerfall-Messung: die Folgerung des
  Plans (*„es ist nichts zu erfassen, weil nichts Gelistetes existiert"*) ist für `tool_response`
  richtig. Was der Plan **nicht** sagt, obwohl es seine These stützt: die zwei neu gesehenen
  Top-Level-Schlüssel (`error`, `is_interrupt`) sind schon heute konstruktiv erledigt — das
  `Payload`-Struct ist geschlossen, `is_interrupt` fällt heraus, und `error` wird von `failed()`
  ausschließlich auf *vorhanden und nicht leer* geprüft, nie übernommen. Die Positiv-Liste aus
  DoD (2) ist auf `tool_response` **beschränkt**; dass die obere Ebene bereits durch das Struct
  geschlossen ist, steht in keinem der zwei Pläne. Das ist keine Lücke, aber der Beleg fehlt an
  der Stelle, an der die These aufgestellt wird.
- `failure-szenario`: Ein Verifier prüft die Positiv-Liste, sieht in der Messung ein 141 Byte
  großes `error` auf oberster Ebene, findet dafür keine Regel im Plan und meldet eine Lücke, die
  im Code seit slice-059 geschlossen ist.
- `verifizierbar`: ja — `sed -n '120,140p' internal/span/span.go` gegen slice-060 §3 Zeile 4.

## Bilanz der Runde-2-Befunde

| # | Titel (Kurzform) | Kat. | Status | Beleg |
|---|---|---|---|---|
| F-1 | Zahn halbiert: DoD „eines dieser vier" gegen §6 „alle vier" | HIGH | **vollständig** | DoD (2) verlangt *„je Freitext-Fläche ein eigener Zahn … je eine Mutation, die `content`, `prompt`, `description` bzw. `outputFile`"* (`:81-83`); §6 trägt den Widerspruch nicht mehr. Restpunkt ist die Grenze, nicht die Zahl (F-2 dieses Reports) |
| F-2 | DoD (1) koppelt zwei verschieden belegte Bedingungen | HIGH | **vollständig** | Bedingungen getrennt nummeriert (`:45-54`); die fehlende Messung ist gefahren und widerlegt die eigene Erwartung (`duration_ms: 3` bei 4.184 ms); die drei nicht-vendored Zitate sind als *„im Repo nicht vorliegend"* markiert. Die **Folge**-Behauptung ist neu und unbelegt (F-1 dieses Reports) |
| F-3 | `agentType` roh, unbekannte Werte ungeklärt | MEDIUM | **halb** | Normalisierung zu leer in slice-060 (`:76-80`); slice-066 unverändert (F-3) |
| F-4 | Feldname fehlt, `agent_type` ist vergeben | MEDIUM | **halb** | `spawned_role` in slice-060 festgelegt (`:75-76`); slice-066 nennt das Span-Feld weiter `agentType` (F-3) |
| F-5 | Negativ-Liste schließt die Freitext-Fläche nicht | MEDIUM | **halb** | Polarität gedreht, Fehlerfall gemessen, konstruktiver Ausschluss ausgesprochen; kein Zahn auf der Grenze (F-2) |
| F-6 | Vordergrund-Bedingung ohne benannte Grenze, keine Abdeckungszahl | MEDIUM | **vollständig** | §6 dritter Punkt benennt den lautlosen Ausfall (`:164-170`); slice-066 DoD (1) verlangt die Abdeckungszahl (`:41-44`) |
| F-7 | `MR-018` Abweichung 1 sagt „keine Datengrundlage" | MEDIUM | **vollständig** | `harness/conventions.md:910-916` korrigiert und **begrenzt** (Haupt-Kontext/Hintergrund bleiben ausgenommen); Restpunkt ist das Präsens (F-13, LOW) |
| F-8 | Cache-Counter-Regeln auf zwei von vier Fragen | MEDIUM | **offen** | slice-066 `:45-49` unverändert (F-5) |
| F-9 | slice-066 ohne ADR im Bezug | MEDIUM | **offen** | `:11-19` unverändert (F-6) |
| F-10 | welle-09 §4 nicht nachgezogen | MEDIUM | **halb** | (a) `:110-112` korrigiert; (b) *„Zu slice-060:"* `:145-148` unverändert (F-7) |
| F-11 | ADR nennt den Auswerter dreimal „slice-060" | MEDIUM | **offen** | keine Umdeutung in Adaption oder Welle (F-8) |
| F-12 | `test/mutations/115` + `MR-018` §Bewacht werden falsch | MEDIUM | **offen** | Datei-Tabelle führt `test/` weiter nur als **neu** (F-9) |
| F-13 | Doc-Gate-Ausnahme ohne Verankerung | MEDIUM | **offen** | `.d-check.yml` in keiner Plandatei, in keiner Adaption (F-10) |
| F-14 | `LH-*`-Kennungen der emittierten Ebene entnommen | LOW | **offen** | unverändert (F-17) |
| F-15 | Frage B unter „vor dem Code zu entscheiden" | LOW | **offen, verschärft** | jetzt zwei Einträge, keiner blockierend (F-14) |
| F-16 | „wörtlich" gegen fünf/sechs Rollen | LOW | **offen** | unverändert (F-15) |
| F-17 | „Zwei namenlose Eimer" dreimal | LOW | **offen** | unverändert (F-16) |
| F-18 | Modul 5 eingehalten, zwei Liefergegenstände ohne DoD | INFO | **halb** | Grenze weiter eingehalten; Punkte innerhalb gewachsen (F-18) |
| F-19 | Ist-Messung ausgewiesen, eine Zeile aus anderer Erhebung | INFO | **halb** | Zeile 7 markiert; dafür ist der Umfang im Tabellenkopf veraltet (F-11) |

**Summe:** vollständig **4** · halb **6** · offen **9**.
Nach Kategorie: von 2 HIGH **beide vollständig**; von 11 MEDIUM drei vollständig, drei halb, fünf
offen; von 4 LOW keiner geschlossen; die 2 INFO je halb.

## Negativbefunde

- geprüft, ohne Befund: **die zwei neuen Messungen** — Ereignis, Feldnamen und Wertlängen sind
  ausgewiesen, die Sonde ist nach eigener Angabe wieder entfernt, und die
  @-Erwähnungs-Messung widerlegt die Erwartung des Planers, statt sie zu bestätigen. Das ist der
  teure Ausgang, und er ist übernommen worden: DoD (1) Punkt 1 sagt jetzt *„wählt den Typ"*,
  nicht mehr, die @-Erwähnung garantiere den Vordergrund.
- geprüft, ohne Befund: **die Positiv-Liste als Regel** — sieben namentlich genannte Werte,
  *„alles andere fällt heraus, ohne genannt zu werden"*, mit der ADR-Fundstelle daneben. Ein
  Implementer kann das eindeutig umsetzen; die offene Frage ist der Sensor, nicht die
  Formulierung (F-2).
- geprüft, ohne Befund: **die Mechanik hinter Frage C** — gegen eine geschlossene Liste prüfen und
  nur die Zuordnung schreiben ist strukturell `commandProgram`, also
  [`ADR-0011`](../plan/adr/0011-telemetrie-erfassung-policy.md) Festlegung 2 (*abgeleitet statt
  roh*); der Präzedenzfall stützt sie sogar schärfer, als der Plan sagt: `commandProgram` musste
  wegen `GITHUB_TOKEN=… gh pr create` **fail-closed** nachgezogen werden und gibt bei Zweifel gar
  nichts aus. Beanstandet ist die Restliste, nicht der Weg (F-4).
- geprüft, ohne Befund: **die §3-Zeilennummerierung und ihr einziger Querverweis** — die Tabelle
  ist auf 1–7 durchnummeriert, die neuen Zeilen 3 und 4 sind eingeordnet, und der einzige Verweis
  im Dokument (§6: *„§3 Zeile 4"*) zeigt korrekt auf die Fehlerfall-Zeile. Ein weiterer Verweis
  auf Zeilennummern dieser Tabelle existiert im Repo nicht (`grep -rn "§3 Zeile" docs/`).
  Beanstandet ist der Tabellen**kopf**, nicht die Nummerierung (F-11).
- geprüft, ohne Befund: **Modul 5 §Größen-/Schnitt-Regeln** — je 3 slice-eigene DoD-Punkte,
  einzeln lieferbar, ≤ zwei Schichten (F-18 ist eine Dichte-, keine Größenbemerkung).
- geprüft, ohne Befund: **Ziel-Form Slice** — Lifecycle-Block, Welle-Bezug, Bezug, Autor/Datum,
  §1–§8 vollständig und in der Vorlagen-Reihenfolge; §8 Sub-Area-Modus-Begründung in beiden
  Slices vorhanden.
- geprüft, ohne Befund: **[`AGENTS.md`](../../AGENTS.md) §3.4** — die Aufnahme von `Agent` in die
  Werkzeug-Liste bleibt ein von
  [`ADR-0011`](../plan/adr/0011-telemetrie-erfassung-policy.md) Festlegung 2 vorgesehener
  Pflege-Vorgang in
  [`MR-018`](../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung); eine
  Supersedes-ADR ist weiterhin **nicht** nötig. Auch Frage C wäre keine: ein zusätzliches
  Hook-Ereignis ist von der ADR ausdrücklich vorgesehen (*„die Abdeckung hängt an dem, was das
  Werkzeug an Ereignissen hergibt"*).
- geprüft, ohne Befund: **[`AGENTS.md`](../../AGENTS.md) §3.5** — keine der Änderungen dieser
  Runde senkt eine Schwelle oder deaktiviert ein Modul.
- geprüft, ohne Befund:
  **[`MR-005`](../../harness/conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption)**
  und **[`MR-000`](../../harness/conventions.md#mr-000--baseline-aussage)** — keine Werkzeuge
  außerhalb der vorgesehenen Pfade, Baseline-Aussage in beiden Slices in der eingegrenzten
  Fassung.
- geprüft, ohne Befund: **die drei nicht-vendored Zitate** — sie sind nicht entfernt, aber jetzt
  je an Ort und Stelle als *„im Repo nicht vorliegend"* markiert (`:46`, `:175`). Das ist die
  ehrliche Form: die Aussage bleibt zitierbar, und der Leser weiß, dass er sie hier nicht
  nachschlagen kann.
- **Nicht geprüft** (Ressourcen-Schranke, ausdrücklich benannt statt verschwiegen): kein
  `make gates`, kein `make docs-check`, kein `make mutate`, keine eigene Payload-Messung.

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 1 |
| MEDIUM | 9 |
| LOW | 7 |
| INFO | 2 |

Zuordnung: **slice-060** trägt F-1, F-2, F-4, F-9, F-10, F-11, F-12, F-14, F-17 (mit), F-19;
**slice-066** trägt F-3, F-5, F-6, F-15, F-16 (mit), F-17 (mit); **welle-09/Adaptions-Umfeld**
trägt F-7, F-8, F-13, F-16 (mit).

## Verdikt

**Merge-blockierend:** **ja** — für beide Slices. Die Bewegung ist deutlich: **beide HIGH der
Runde 2 sind an ihrem Gegenstand geschlossen**, und zwar durch Messungen statt durch
Umformulierung. Der verbleibende HIGH ist **nicht** einer der alten; er ist mit der Antwort
entstanden.

**slice-060 (Rollen-Achse): NICHT KONFORM.**

Blockierend ist **F-1**. Die Antwort auf HIGH-1 endet in einer neuen, unbelegten Behauptung: die
Vordergrund-Bedingung sei *„keine Nutzer-Konvention, sondern eine Aufruf-Konvention … sie liegt
dort, wo eine `.claude/agents/`-Definition oder ein Kommando sie festschreiben kann"*. Von den
zwei genannten Orten wird der erste vom selben DoD-Punkt widerlegt (das dort aufgezählte
Frontmatter kennt keine Betriebsart), der zweite ist eine Prompt-Datei und damit dasselbe
Gedächtnis, dem die Bedingung entzogen werden sollte. Darauf folgt in §6 die unbedingte
Feststellung *„Und sie hat keinen Sensor."* — eine Vollständigkeitsaussage über Sensoren, die
niemand geprüft hat, in einem Repo, dessen eigener `PreToolUse`-Guard läuft, dessen `matcher` laut
der vendored Referenz nach Tool-Namen filtert, dessen `deny` den Aufruf verhindert, und dessen
Eingabe das fragliche `run_in_background` trägt — vom Planer selbst gemessen. Das ist die Klasse,
die [`ADR-0011`](../plan/adr/0011-telemetrie-erfassung-policy.md) in ihrer eigenen Geschichte als
Runde-5-HIGH führt: *eine falsche Sensor-Zusage durch eine falsche Sensor-Verneinung ersetzt*. Zur
Auftragsfrage, ob die Aufruf-Konvention besser ist als eine Nutzer-Konvention: **die Verschiebung
der Zuständigkeit ist richtig, ihre Begründung ist Hoffnung** — belegt ist an ihr bisher nichts,
und ein Ort, an dem sie erzwungen werden könnte, ist im Repo vorhanden, aber ungeprüft.

Dazu die MEDIUM **F-2** (die Positiv-Liste ist als Regel richtig gesetzt und als Zusage
unbewacht — die vier Zähne prüfen vier Namen, während §6 die Eigenschaft *„hält auch bei einem
fünften Feld"* verspricht; ein fünfter Fall auf einen ungelisteten Schlüssel schließt es),
**F-4** (Frage C: die Mechanik ist ADR-konform, die Restliste ist als vollständig geschrieben und
lässt den Mehrfach-Treffer und die Zustands-Brücke aus), **F-9**, **F-10**.

**slice-066 (Telemetrie-Auswertung): NICHT KONFORM.**

Kein HIGH. Der Slice hat in dieser Runde **eine** Zeilengruppe bekommen (die Abdeckungszahl, und
die schließt den Runde-2-Befund sauber). Alles andere steht unverändert — mit der Folge, dass die
Antwort ihn an einer Stelle **verschlechtert** hat: slice-060 hat das Span-Feld in `spawned_role`
umbenannt, slice-066 DoD (1) liest weiter `agentType` (**F-3**). Dazu die drei unveränderten
MEDIUM **F-5** (Block 3 auf zwei von vier Modul-Vorgaben, weder Sensor noch Abweichung — was die
Welle-Closure als „Sensor" verbuchen würde), **F-6** (`adr` bleibt leer bei dem Slice, der die
Korrelations-Achsen auswertet) und **F-7** (die höherrangige Welle begründet die Datenlage weiter
mit Transkripten, obwohl beide Slices den Zugriff ausschließen).

**Zu den Auftragsfragen, ausdrücklich beantwortet.**
*Sind die zwei HIGH geschlossen?* **Ja, beide** — HIGH-3 durch vier statt einem Zahn und eine
widerspruchsfreie §6; HIGH-1 durch die Messung, die die Kopplung auflöst. Der neue HIGH betrifft,
was der Planer aus der Messung **gefolgert** hat, nicht die Messung.
*Trägt die Positiv-Liste?* **Als Regel ja, als Zusage nein** — eindeutig umsetzbar, aber „je
Freitext-Fläche ein eigener Zahn" bewacht vier bekannte Namen und nicht die Grenze; genau die
Eigenschaft, mit der §6 die Umstellung begründet, hat kein Gegenbeispiel.
*Ist die Aufruf-Konvention besser?* **Die Richtung ja, die Begründung nein** — siehe F-1.
*Ist Frage C ADR-konform?* **Die Ableitung ja** (geschlossene Liste, kein Teilstring, nur die
Zuordnung — dieselbe Bauart wie `commandProgram`); **die Restliste nein** (F-4).
*Modul 5 ≤ 3 DoD-Punkte?* **Eingehalten**, 3 und 3 (F-18).
*§3-Nummerierung und Querverweise?* **Korrekt** — Zeilen 1–7 durchnummeriert, der einzige
Verweis (*„§3 Zeile 4"*) trifft; falsch ist der Tabellen**kopf**, der weiter zwei Aufrufe nennt
(F-11).

**Übergabe:** Findings gehen an die Planung (Rückkante Review → Plan bei Plan-Defekt). Der Report
ersetzt keine Verifikation — DoD-/Spec-Konformität prüft der Verifier separat (Modul 11; anderes
Prüf-Artefakt, anderer Eingabe-Kontext). Für **F-1** ist die nächste Handlung eine Prüfung, keine
Umformulierung: ob ein `PreToolUse`-Hook auf `Agent` die Bedingung durchsetzen kann — und wenn ja,
ob dieses Repo sie durchsetzen **will**. Für **F-3** genügt ein Nachzug in slice-066; er ist
mechanisch und schließt drei Halb-Befunde auf einmal.
