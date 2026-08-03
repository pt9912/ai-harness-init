# ADR-0012: Der Haupt-Kontext bleibt ohne Token-Bilanz — die Abweichung ist permanent, nicht temporär

**Status:** Proposed

**Datum:** 2026-07-31

**Autor:** ai-harness-init-Team (pt9912)

**Bezug:**
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (kein
Gate über leerem Prüfbereich — **die Anforderung gilt der emittierten Ebene**, *„jeder
**emittierte** Gate-Target läuft auf frischem Checkout"* mit Messmethode Bootstrap in ein
tmp-Repo; für den Dogfood steht dieselbe Regel als [`AGENTS.md`](../../../AGENTS.md) §3.1.
**Berührt ist hier keine von beiden** — das Kriterium dafür steht bei der Fitness Function
unten),
[`AGENTS.md`](../../../AGENTS.md) §3.6 (**der tragende Grund**: eine Zusage ohne rot gesehenes
Gegenbeispiel ist keine — sie entscheidet, welche der beiden Festlegungen einen Wächter bekommt
und welche nicht),
[ADR-0011](0011-telemetrie-erfassung-policy.md) (**Accepted** — Festlegung 1 Punkt 5 verlangt,
das nach der Ableitung Unerreichbare *begründet zu dokumentieren*; **ob** dokumentiert wird, ist
dort entschieden, **in welcher Artefakt-Klasse** — temporäre Ausnahme oder
Architekturentscheidung — entscheidet diese ADR)

**Schärft:** [`spezifikation.md §5 Metriken und Tracing-Felder`](../../../spec/spezifikation.md#5-metriken-und-tracing-felder)
— die erklärten Abweichungen vom Pflicht-Minimum und die Nenner-Pflicht aus Festlegung 2.
Aufwärts-Deklaration: wer diese ADR ändert, zieht diesen Abschnitt nach — er ist der von
[ADR-0013](0013-technik-stratum-als-zielort.md) entschiedene **Zielort** dieser Begründungen,
und die Deklaration greift ab der ersten Zeile, die dort steht. Die **emittierte** Ebene wird hier nicht
**entschieden** — Gegenstand ist der Dogfood-Bestand dieses Repos, und das **Ob** der Emission
bleibt dem Slice, der die Tool-Ebene entscheidet, samt Change Request
([ADR-0011](0011-telemetrie-erfassung-policy.md) Festlegung 5). **Berührt** ist sie sehr wohl,
und zwar als Folgepflicht 3 unten: wird je emittiert, gilt diese Grenze im Ziel und gehört dort
genannt.

---

## Kontext

`.harness/baseline/v3.5.2/regelwerk/modul-15-observability.md` §Token-Attributions-Regeln
verlangt eine Token-Bilanz **je Rolle**.
[`spec/spezifikation.md`](../../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5 führt
sechs erklärte Abweichungen, und sie kommen aus **drei** Regelblöcken des Moduls — von den
Token-Attributions-Regeln weichen **zwei** ab, die fünfte und die sechste. Die sechste ist die
härteste und der
Gegenstand hier: **der Haupt-Kontext hat keine Zahl** — und er ist der Ort, an dem auch
Rollen-Arbeit anfällt: an der Arbeit an der Rollen-Achse dieses Repos ist belegt, dass Planner
und Implementation über weite Strecken in **einem** Kontextfenster liefen. **Wie viele Token**
das sind, weiß niemand — und genau das ist der Gegenstand.

**Was gemessen ist** (im Einzelnen in
[`spec/spezifikation.md`](../../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5
Abweichung 6):
die vier `usage`-Zähler und die drei `total*`-Werte stehen ausschließlich in der `tool_response`
eines `Agent`-Aufrufs. Den Haupt-Kontext umschließt **kein** `Agent`-Aufruf; es gibt kein
Ereignis, an dem seine Token anfielen, und keine Payload, die sie trüge. Aus den erfassten
Feldern folgt keine Zahl: `result_bytes` und `duration_ms` messen **einen** Aufruf, und eine
Umrechnung wäre die Schätzung, die [ADR-0011](0011-telemetrie-erfassung-policy.md) Festlegung 1
Punkt 4 ausschließt (*leer und als leer erkennbar*, nicht geraten). Selbst eine gelöste
Rollen-Ableitung gäbe dem Haupt-Kontext ein **Etikett**, aber keinen Zähler — Rolle und Zahl
sind zwei Größen, und nur die zweite steht hier zur Entscheidung.

**Warum die Entscheidung jetzt fällt.** Die Abweichung stand als *temporäre*: mit einem
Auflösungs-Trigger — *„eine Quelle innerhalb des Repos, die Haupt-Kontext-Token trägt"* — und
**ohne Folge-Slice**. Über die lebenden Plandateien — `open/`, `next/`, `in-progress/` samt
Roadmap und der flach liegende Welle-Plan — führt kein Slice diese Bedingung; wo überhaupt von
Token die Rede ist, geht es um andere Fragen — unter ihnen die Splitting-Regel des
Sammelpostens, die Berichtsgröße, die Cache-Rechnung und die Wächter-Bindung; **keine** von
ihnen führt diese Bedingung —, und der eine Slice, der sie einmal trug, hat seinen DoD-Punkt
ausdrücklich an die Schema-Festlegung abgegeben, die heute in
[`spec/spezifikation.md`](../../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5
steht. `.harness/baseline/v3.5.2/regelwerk/modul-07-carveouts.md:26-29` beschreibt genau
diesen Zustand: *„Fehlt der Folge-Slice, ist der Carveout de facto permanent — dann gehört er
nicht in `carveouts/`, sondern über den Trichter unten in eine ADR."* **Der Satz greift hier nach
seiner Logik, nicht nach seinem Buchstaben, und das gehört gesagt:** Abweichung 6 ist **kein**
Carveout und liegt nicht unter `docs/plan/carveouts/` — sie ist eine erklärte Abweichung in
[`spec/spezifikation.md`](../../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5.
Bindend ist deshalb der **Trichter** (`:46-93`), und der spricht ausdrücklich von *Diskrepanzen*,
bevor eine als Carveout festgeschrieben wird (`:48`).

**Der Trichter, beide Fragen, in der Reihenfolge des Moduls** (`:48-67` — Granularität **vor**
Temporalität):

1. **Granularität — einzelne Diskrepanz oder Cluster?** *Einzelne.* Die Nachbar-Abweichung 5
   (Hintergrund-Läufe tragen keine Verbrauchs-Achse) betrifft dieselbe Achse, aber es gibt
   **keine gemeinsame Auflösung**: ihre Bedingung ist erfüllt, sobald die `tool_response` eines
   Hintergrund-Laufs Zähler trägt — und träte sie ein, bliebe der Haupt-Kontext unberührt, denn
   ihn umschließt überhaupt kein solcher Aufruf. Sie ist zudem durch einen `PreToolUse`-Guard
   **verkleinert** (er schließt die Lücke nicht, aber er bewegt sie); an dieser hier bewegt kein
   Aufwand dieses Repos etwas — das ist Frage 2. Ein gemeinsamer Geltungsbereich mit gemeinsamer
   Auflösung besteht damit nicht. **Wohl aber teilen die zwei die Antwort auf Frage 2**, und das
   gehört gesagt statt verschwiegen: auch der Trigger von Abweichung 5 wirkt nur, wenn ihn
   jemand nachsieht. Ob sie deshalb denselben Pfad nehmen müsste, ist hier **nicht**
   mitentschieden — Gegenstand dieser ADR ist die sechste. Auch
   keines der beiden Symptome für eine **BF-Sub-Area-Markierung** liegt vor (`:130`): dieses
   Repo führt genau **einen** Carveout, und mit dem teilt diese Abweichung keinen
   Geltungsbereich; und sie folgt nicht aus dem Muster *„Code existiert vor Doku"* — die Doku
   ist hier vollständig, es fehlt eine **Quelle**. → Frage 2.
2. **Temporalität — Trigger ernst zu erreichen?** **Nein.** Kein Aufwand dieses Repos bringt die
   Bedingung herbei: die Hook-Oberfläche gehört dem Werkzeug, das Transkript ist als Quelle
   ausgeschlossen (fremder Besitz, außerhalb des Repos, voller Gesprächsinhalt), und Schätzen
   ist verboten. `:63-67` beantwortet das ohne Rest: *„Nein (‚nichts davon werden wir in
   absehbarer Zeit tun') → permanent, übergeführt in eine ADR."*

   **Die Grenze dieser Antwort:** *herbeiführen* kann die Bedingung niemand — *nachsehen*, ob sie längst gilt, sehr wohl. Die
   Payloads aller Ereignisse außer `PostToolUse`/`PostToolUseFailure` und der `tool_response` des
   `Agent`-Werkzeugs sind hier **nie vermessen** worden; dass keines von ihnen ein Nutzungsfeld
   trägt, ist **gelesen** (die vendored Werkzeug-Doku), nicht gemessen — und die Regel dieses
   Repos lautet *„die Payload ist die Quelle, die Doku ist Herkunft"*. An der **Antwort** ändert
   das nichts: eine Sonde **beobachtet** den Trigger, sie führt ihn nicht herbei (Alternative C),
   und Frage 2 fragt nach dem Erreichen, nicht nach dem Bemerken. Am **Status** der Antwort ändert
   es etwas: sie ist eine Entscheidung unter benannter Unsicherheit, und die Fläche steht unten
   als Re-Evaluierungs-Trigger.

**Ein Zustand ohne Träger ist nach Modul 7 kein temporärer** (`:129`): *„Gegen ‚Wenn der
Trigger eintritt, lösen wir den Carveout auf': Realität: er bleibt liegen. Deshalb braucht jeder
temporäre Carveout einen Folge-Slice mit ID, der das Auflösen plant. Slice schlägt Memo."*

**Annahmen, auf denen diese ADR steht** — kippt eine, kippt die Entscheidung: (a) die
Hook-Oberfläche des Werkzeugs trägt für den Haupt-Kontext keine Zähler; (b) das Transkript
bleibt als Quelle ausgeschlossen; (c) dieses Repo betreibt keinen eigenen Telemetrie-Empfänger.
Alle drei stehen unten als Re-Evaluierungs-Trigger, jeder mit seiner ehrlichen Wirksamkeit.

## Entscheidung

**Wir wählen Option F: die Abweichung ist permanent.** Der Token-Verbrauch des Haupt-Kontexts
wird nicht erfasst — nicht als Aufschub, sondern als **Grenze**, die wir mit der Wahl dieser
Erfassungs-Mechanik angenommen haben. Drei Festlegungen folgen:

1. **Kein Auflösungs-Trigger und kein Folge-Slice.** Beides gehört zum temporären Werkzeug. Was
   ein Folge-Slice hier enthielte, wäre „abwarten" — genau das Memo, das
   `.harness/baseline/v3.5.2/regelwerk/modul-07-carveouts.md:129` durch einen Slice ersetzt
   sehen will. An die Stelle des Triggers tritt die Re-Evaluierung unten: sie sagt, **wer**
   diese Entscheidung wieder aufmacht und **woran** er es merkt — und sie behauptet nicht, dass
   das jemand tun wird.
2. **Jede Token-Bilanz aus diesen Spans ist eine Bilanz über SUBAGENTEN-Läufe und nennt ihren
   Nenner.** Das ist die positive Hälfte: nicht messen ist entschieden, den fehlenden Anteil
   verschweigen nicht. Ein Prozentsatz aus diesen Zahlen ist ein Anteil an der **erfassten
   Teilmenge**; wer ihn schreibt, schreibt das dazu. Die Pflicht ist **nicht neu** — sie steht
   in [`spec/spezifikation.md`](../../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5
   Abweichung 6; diese ADR begründet sie und bindet sie an einen Wächter (unten), sie führt sie
   nicht ein (eine zweite Formulierung derselben Pflicht wäre eine zweite Wahrheit).
3. **Die Rollen-Frage bleibt offen und ist hier nicht mitentschieden.** Der Haupt-Strom bleibt
   der Sammelposten, und die von Modul 15 verlangte begründete Splitting-Regel bleibt fällig —
   sie verteilt **Etiketten** auf gemessene Token, sie erzeugt keine. Wer diese ADR als
   Erledigung der Sammelposten-Pflicht liest, liest sie falsch.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — **nichts tun**: die Abweichung bleibt als temporäre stehen | kein Aufwand; der Text ist bereits geschrieben | ein temporärer Carveout ohne Folge-Slice ist nach `modul-07-carveouts.md:26-29` *de facto* permanent — und behauptet dabei das Gegenteil. Der zuvor benannte Entscheidungs-Ort (das Wellen-Closure-Audit) hat über diesen Absatz **keinen Prüfbereich**: sein Gegenstand sind nach `:105-110` die Carveouts, die nach `:21` unter `docs/plan/carveouts/` liegen, und der Closure-Trigger dieser Welle setzt genau diesen Umfang. Beide Prüfungen gingen durch, keine sähe die Sache |
| B — **Folge-Slice, der das Auflösen plant** | die Form, die Modul 7 für temporäre Ausnahmen verlangt (*„Slice schlägt Memo"*) | er hat keinen Gegenstand. Die Bedingung ist nicht durch Arbeit herbeizuführen: wir bestimmen weder die Payload noch die Erlaubnis, das Transkript zu lesen. Ein Slice mit dem Inhalt „abwarten" ist das Memo unter anderem Namen |
| C — **Mess-Slice**: Sonde auf die hier nie vermessenen Ereignis-Payloads | planbar, endlich, und er machte aus gelesener Doku eine Messung — die Lehre dieses Repos lautet *„die Payload ist die Quelle, die Doku ist Herkunft"* | er **löst nichts auf**: er beobachtet, ob der Trigger schon eingetreten ist, er führt ihn nicht herbei. Sein Erwartungswert ist negativ — die vendored `docs/user/claude-hooks-referenz.md` nennt in ihrer ganzen Länge ein `usage`-Objekt und ein `totalTokens` **nur** für die `tool_response` des `Agent`-Werkzeugs (`:1571-1574`), für kein anderes Ereignis ein Nutzungsfeld. Danach stünde dieselbe Frage erneut, und die Abweichung wäre um eine Runde älter. Das Wissen, das er brächte, ist unten als **benannte ungemessene Fläche** aufgehoben, ohne einen WIP-Platz zu belegen |
| D — **Transkript als Quelle** | es trägt die Zähler und liegt auf derselben Maschine | auf Entscheidung des Auftraggebers ausgeschlossen: fremder Besitz, außerhalb des Repos, voller Gesprächsinhalt. [ADR-0011](0011-telemetrie-erfassung-policy.md) hat dieselbe Option bereits als Alternative D verworfen; ein Zeiger darauf legte eine Auflösung nahe, die niemand genehmigt hat |
| E — **eigener Telemetrie-Empfänger**, der die Nutzungs-Telemetrie des Werkzeugs annimmt | er bekäme Zahlen, die kein Hook trägt | [ADR-0011](0011-telemetrie-erfassung-policy.md) hat den Stack als Option B verworfen ([`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten): neue Laufzeit-Abhängigkeit; ein Backend ohne Betreiber). Dazu ein Detail aus der vendored Werkzeug-Doku: das Werkzeug **entfernt die Exporter-Variablen aus jedem Unterprozess, den es spawnt, einschließlich Hooks** — die Erfassungsstelle, die wir haben, käme an diese Achse ohnehin nicht heran |
| G — **Rollen-Arbeit in Subagenten verlagern**, damit weniger im Haupt-Kontext anfällt | die einzige Option, die die **Größe** des unerfassten Anteils bewegt statt seiner Messbarkeit; sie läuft bereits — die **Berichtsgröße**, an der sie ablesbar ist, steht geliefert als Festlegung im Technik-Stratum; **erzeugt** wird die Zahl erst von der Auswertung, und die ist geplant | sie beantwortet die Frage dieser ADR **nicht**: der Haupt-Kontext bekäme keine Zahl, sondern nur weniger Arbeit — und **wie viel weniger, misst niemand**: die verschobene Menge liegt vor der Verschiebung in genau der Größe, die keine Payload trägt. Ablesbar ist allein, was auf der anderen Seite ankommt. Sie ist deshalb keine Alternative zu F, sondern das, was **neben** F läuft. Sie steht hier, damit die Konsequenz unten nicht als *„daran ist nichts zu machen"* gelesen wird |
| **F — permanent, als ADR (gewählt)** | die Abweichung hört auf, auf einen Träger zu warten, den es nicht gibt; die Einordnung steht dort, wo Architekturentscheidungen stehen, und die Nenner-Pflicht bekommt ihre Begründung und ihren Zahn | eine ADR ist ab *Accepted* immutabel ([`AGENTS.md`](../../../AGENTS.md) §3.4): wird die Quelle doch erreichbar, entsteht eine neue ADR mit *Supersedes*, kein Federstrich. Und sie schließt keine Lücke — sie benennt sie dauerhaft |

## Konsequenzen

- **Positiv:** der Zustand ist entschieden statt aufgeschoben. Wer
  [`spec/spezifikation.md`](../../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5
  Abweichung 6 liest, findet keine Zusage mehr, die auf einen Träger zeigt, den es nicht gibt.
- **Positiv:** die Pflicht, den Nenner zu nennen, hat ab hier eine **Begründung** statt nur einen
  Ort — und einen Wächter, sobald die Bilanz entsteht (Fitness Function unten; heute existiert
  er nicht). Sie ist der Teil dieser Entscheidung, der **überprüfbar wird** — an jeder Bilanz,
  die entsteht.
- **Negativ, und das ist der Preis:** keine Zahl aus diesem Bestand beantwortet *„was hat dieser
  Lauf gekostet?"*. Modul 15 §Token-Attributions-Regeln bleibt für den Haupt-Kontext
  **unerfüllt** — als erklärte Abweichung, nicht als Erfüllung.
- **Negativ:** eine Auswertung muss ihren Nenner selbst führen. Kein Feld im Span sagt ihr, wie
  groß der nicht erfasste Teil war — die Größe ist nicht klein, sie ist **unbekannt**. **Und sie
  bleibt es:** solange die Annahmen (a)–(c) gelten, beziffert keine Auswertung sie — sie liest
  Spans, und kein Span trägt diese Token. Was die Auswertung beziffert, ist eine **andere**
  Größe: den Sammelposten-Anteil **innerhalb** der erfassten Teilmenge (unten abgegrenzt). Eine
  Größenangabe an dieser Stelle wäre die Schätzung, die der Kontext oben ausschließt
  ([ADR-0011](0011-telemetrie-erfassung-policy.md) Festlegung 1 Punkt 4).
- **Folgepflicht 1 — eingelöst, und zwar anders als zuerst vorgesehen.**
  [`spec/spezifikation.md`](../../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5
  Abweichung 6 trägt die Beschreibung **ohne Auflösungs-Trigger**; Modul 7 §Werkzeug-Wahl sieht
  genau das vor: auf dem ADR-Pfad **fällt der Trigger weg**, die Beschreibung bleibt. Das
  **Verdikt** steht dort nicht daneben, sondern allein hier —
  [`MR-021`](../../../harness/conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben)
  hat es beim Umzug ins Technik-Stratum ausdrücklich als **ersatzlos** verzeichnet, mit dem
  Grund *„Ein zweiter Ort driftet"*. Wer das Verdikt am Ort der Abweichung sucht, findet es
  nicht dort, sondern hier; diese ADR ist sein einziger Träger.
- **Folgepflicht 2 — eingelöst, und sie verlangte eine Ergänzung des Vokabulars, nicht nur eine
  ausgefüllte Zelle.** Die Matrix-Zelle *Token-Attribution × Repo* des Wellen-Closure führt für
  den Haupt-Kontext **nicht** „deklarierte Entscheidung mit Auflösungs-Trigger", sondern den
  Verweis auf diese ADR. Ein Closure-Vokabular, das *deklariert* als bewusste Nicht-Umsetzung
  **mit Auflösungs-Trigger** definiert — genau das, was Modul 7 auf dem ADR-Pfad wegfallen lässt
  —, ließe dafür nur die Wahl zwischen einem Trigger, den es nicht mehr gibt, und einer offenen
  Zelle; und eine offene Zelle ist ein offener Closure-Trigger. Der Welle-Plan führt die
  Belegart **ADR-Verdikt** inzwischen als eigenen Wert mit dieser ADR als erstem Fall,
  eingetragen von dem Slice, der die Rollen-Konvention schreibt, und mit dem Welle-Plan in
  dessen Plan-Tabelle.
- **Folgepflicht 3:** wird der Span-Emitter je emittiert (die Tool-Ebene, eigener Slice mit
  Change Request), gilt diese Grenze im Ziel unverändert — sie ist keine Eigenschaft unseres
  Aufbaus, sondern der Mechanik. Sie gehört dort **genannt**, nicht stillschweigend
  mitgeliefert.
- **Folgepflicht 4 — sie geht der Annahme dieser ADR voraus, sie folgt ihr nicht.** Der Slice,
  der die Bilanz baut, führt die Nenner-Angabe als **eigenen** Punkt seiner Definition of Done:
  die erzeugte Bilanz benennt, worüber sie rechnet, und ein Fall in `test/mutations/` entfernt
  die Angabe wieder. Sie ist **weder** der Sammelposten-Anteil **noch** die Abdeckungszahl
  (unten abgegrenzt) — ein DoD-Punkt, der eine dieser beiden Größen bindet, bindet die
  Nenner-Angabe nicht. Ohne ihn zeigen die zwei Zeilen der Fitness Function auf einen Slice, der
  sie nicht führt: er liefe plan-konform ab, `make gates` und `make mutate` blieben grün, und
  Festlegung 2 bliebe ohne Zahn — ein nie angelegter Fall erzeugt kein Rot. Der Slice-Plan gehört
  dem Planner; diese ADR benennt die Bedingung, sie schreibt ihn nicht.

## Fitness Function (falls maschinell prüfbar)

**Die zwei Hälften dieser Entscheidung sind verschieden prüfbar, und sie zusammenzufassen wäre
die Aussage, die zu weit reicht.**

**Festlegung 1 — keine, und das ist eine Aussage, kein Auslassen.** Entschieden ist hier die
**Abwesenheit einer Quelle**: der Haupt-Kontext hat keine Zahl, es gibt keinen Trigger und keinen
Folge-Slice. Dafür kann es keinen Wächter geben, weil es kein Gegenbeispiel gibt, das rot werden
könnte ([`AGENTS.md`](../../../AGENTS.md) §3.6) — ein Wächter über einer Unmessbarkeit ist genau
die Zusage ohne Abdeckung, gegen die diese Regel steht. Und der Text, der die Festlegung trägt,
ist Markdown: `make comment-claims` prüft vier Pfad-Muster (`internal/**/*.go`, `cmd/**/*.go`,
`harness/tools/*.sh`, `.claude/hooks/*.sh`) und damit **kein** Markdown; `make docs-check` prüft
Links, Anker, Kennungen, Matrix, Codepfade und Spans — **keine Behauptungen**. Eine Tabellenzeile
für diese Hälfte nennte damit ein Tooling, dessen Prüfbereich diesen Text nicht enthält — eine
Zusage ohne Gegenbeispiel, kein Wächter.

**Festlegung 2 — eine, fällig mit der Bilanz.** Die Bilanz ist **kein Prosa-Bericht**: der Slice,
der sie baut, baut sie als eigenes Go-Kommando, Docker-only wie jedes Binary dieses Repos
([ADR-0003](0003-go-native-binaries.md)), und führt `test/` samt `test/mutations/`. Ihre Ausgabe
ist damit genau die Fläche, die dieses Repo überall sonst bewacht — ein Go-Test auf die erzeugte
Zeile plus ein Fall, der sie entfernt. Für die **Nachbargröße** in derselben Ausgabe ist derselbe
Zahn bereits verlangt (*„fällt der Sammelposten-Anteil aus dem Bericht, muss ein Fall rot
werden"*); die Nenner-Angabe daneben ohne Zahn zu lassen, wäre zweierlei Maß.

| Tooling | Regel | Make-Target |
|---|---|---|
| Go-Test (`make test`) — **fällig mit der Bilanz (Folgepflicht 4), existiert heute nicht** | Die erzeugte Bilanz **benennt ihren Nenner**: dass sie über **Subagenten-Läufe** rechnet und nicht über den Lauf. Fehlt die Angabe in der Ausgabe, fällt der Test | `make test` |
| `test/mutations/` — **fällig mit der Bilanz (Folgepflicht 4), existiert heute nicht** | Die Nenner-Angabe wird aus dem Auswerter **entfernt** — der Wächter darüber muss rot werden; ohne diesen Fall wäre Festlegung 2 eine Absicht | `make mutate` |

**Was die zwei Zeilen nicht leisten.** Sie binden die
**Anwesenheit** der Nenner-Angabe, nicht ihre **Wahrheit**: ob die genannte Teilmenge die
tatsächlich gerechnete ist, prüft kein Sensor — dieselbe Grenze, die
[`spec/spezifikation.md`](../../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5 für
seine eigene Sensor-Spalte ausspricht — dort *„kein Gate prüft, ob ein … genannter Wächter noch
existiert oder noch so heißt"*, und `make comment-claims` lässt jede Markdown-Datei außen vor. Und der Nenner ist **keine** der beiden Nachbargrößen in derselben Ausgabe: der
**Sammelposten-Anteil** misst, wie viel der Bilanz auf der Splitting-Regel ruht; die
**Abdeckungszahl** zählt Spawns **innerhalb** der erfassten Teilmenge; der Nenner benennt die
Teilmenge selbst. Drei Größen, drei Angaben — wer zwei davon zusammenlegt, verliert eine. Die
zwei Zeilen oben binden **allein** die Nenner-Angabe.

**Die Zeilen nennen einen Sensor, den es noch nicht gibt** —
[ADR-0011](0011-telemetrie-erfassung-policy.md) wurde mit **fünf**
`test/mutations/`-Zeilen angenommen, deren Dateien erst der umsetzende Slice anlegte — zum
Zeitpunkt der Annahme trug das Verzeichnis **102** Fälle mit 106 als höchster Nummer (die Folge
hat Lücken und Doppelvergaben), und die Span-Fälle beginnen bei 107. **Die
Präzedenz trägt eine Hälfte:** dass die Datei fehlen darf. Die zweite trägt sie nicht — dort
nannte der **umsetzende** Slice die Zähne in seiner eigenen Definition of Done (*„Zwei Zähne, rot
gesehen"*) und dieselben zwei in seiner Plan-Tabelle. Genau das verlangt Folgepflicht 4 hier.
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) ist
dadurch nicht berührt: hier wird kein Gate in `make gates`, [`AGENTS.md`](../../../AGENTS.md) §4
oder [`harness/README.md`](../../../harness/README.md) **behauptet** — hier steht eine Zusage an
den Slice, der die Bilanz baut. Dasselbe Kriterium gilt für Festlegung 1: auch ihre fehlende
Zeile behauptet keinen Gate an einem dieser drei Orte.

## Re-Evaluierungs-Trigger

- **Wenn das Agenten-Werkzeug seine Hook-Oberfläche ändert** (neue Ereignisse, andere Payload)
  *(feedforward — die Quelle ist nicht gepinnt, kein Gate prüft sie; wirkt nur, wenn jemand sie
  liest)*: dann ist Annahme (a) neu zu messen. Die Payload-Fläche wächst belegbar — vier
  gemessene Aufrufe zeigten fünf undokumentierte Schlüssel. Es ist derselbe Trigger, den
  [ADR-0011](0011-telemetrie-erfassung-policy.md) §Re-Evaluierungs-Trigger führt, hier nur
  zugeordnet.
- **Die benannte ungemessene Fläche** *(feedforward — niemand fährt sie, bis er ein Ereignis
  verdrahtet)*: dieses Repo hat die Schlüsselmengen von `PostToolUse`/`PostToolUseFailure` und
  die `tool_response` des `Agent`-Werkzeugs vermessen — **sonst nichts**. Die Payloads der
  übrigen Ereignisse sind hier nie vermessen worden, auch die des verdrahteten `Stop`-Hooks
  nicht: der greift genau ein Feld heraus und protokolliert nichts. Gelesen ist für sie nur die
  vendored Werkzeug-Doku, und die ist **Herkunft, keine Messung**. Wer eines dieser Ereignisse
  verdrahtet, misst seine Schlüsselmenge mit und trägt sie in
  [`spec/spezifikation.md`](../../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5 nach;
  zeigt sie eine Nutzungs-Achse für den Haupt-Kontext, ist diese ADR abzulösen.
- **Wenn die Transkript-Entscheidung kippt** *(feedforward — eine Erlaubnis des Auftraggebers,
  kein Sensor)*: dann ist Annahme (b) hinfällig, und mit ihr Alternative D. Zu entscheiden wäre
  dann zuerst, was aus einer Quelle mit vollem Gesprächsinhalt überhaupt in einen Span darf —
  das ist eine Sicherheitsfrage, keine Erfassungsfrage.
- **Wenn dieses Repo Agentenläufe selbst betreibt** *(feedforward — kein Sensor)*: dann kippt
  die Annahme *„Audit, kein Betriebs-Monitoring"* aus
  [ADR-0011](0011-telemetrie-erfassung-policy.md), Annahme (c) fällt mit ihr, und Alternative E
  ist neu zu bewerten.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-08-03 | Überarbeitet, weiter **Proposed** | **Neun Verweise zeigten auf einen Eintrag, der seinen Rumpf abgegeben hat.** Der Span-Schema-Eintrag des Adaptions-Blocks ist vollständig aufgehoben ([`MR-021`](../../../harness/conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben), Bedingungen in [ADR-0014](0014-aufgehobener-eintrag-kopf-statt-rumpf.md)); er behält Nummer, Überschrift **wörtlich**, das `Datum` und eine Zeiger-Zeile, die sechs erklärten Abweichungen stehen im Technik-Stratum. Die Links lösten weiter auf — der Kopf ist genau als Anker erhalten —, aber jede Aussage darüber, was der Eintrag *führt*, *trägt* oder *ausspricht*, war seit dem Umzug im Präsens falsch, und **kein Gate liest sie**: `codepaths` prüft Pfade, nicht Sätze. Ab *Accepted* wären sie nach [`AGENTS.md`](../../../AGENTS.md) §3.4 nur noch per Supersedes zu korrigieren. Sie zeigen jetzt auf den Zielort, den der `Schärft`-Kopf dieser ADR ohnehin nennt. **Folgepflicht 1 war zudem sachlich überholt:** sie verlangte das Verdikt *permanent* am Ort der Abweichung — jener Umzug hat es dort als **ersatzlos** verzeichnet (*„Ein zweiter Ort driftet"*), womit diese ADR sein einziger Träger ist; die Folgepflicht sagt das jetzt. Die **unterste** Zeile dieser Tabelle — die, die diese ADR eröffnet — bleibt unverändert: sie datiert einen Zustand, in dem der Eintrag den Rumpf noch trug. **Nachgetragen in derselben Runde** (Bestätigungsrunde `docs/reviews/2026-08-03-adr-0012-bestaetigungsrunde.md`, drei MEDIUM): der Nachzug hatte die Verweise geprüft, nicht die Sätze um sie herum — die Trichter-Antwort auf Frage 1 stützte sich auf einen *„ernst erreichbaren"* Trigger der Nachbar-Abweichung, den der Zielort nicht mehr führt (sie teilt die Antwort auf Frage 2, was jetzt dasteht statt zu fehlen); die sechs Abweichungen wurden pauschal **einem** Pflicht-Minimum zugeschrieben, obwohl der Zielort sie ausdrücklich auf drei Regelblöcke verteilt; und Folgepflicht 2 verlangte im Präsens eine Vokabular-Ergänzung, die längst steht. Dazu vier kleinere: die Fallzahl bei Annahme der Vorgänger-ADR (**102**, nicht die höchste Nummer 106), die umgekehrte Wortstellung in einem Zitat, die Frageliste des Plan-Bestands und die Berichtsgröße, die nicht mehr geplant, sondern geliefert ist |
| 2026-08-01 | Überarbeitet, weiter **Proposed** | `Schärft` von `—` auf den Abschnitt gesetzt, den diese ADR verbindlich macht. Die Begründung *„ohne Spec-Stratum"* traf zu, solange das Repo nur Vertrag und Sicht führte; mit dem Technik-Stratum ([ADR-0013](0013-technik-stratum-als-zielort.md), [`MR-019`](../../../harness/conventions.md#mr-019--technik-stratum-als-rang-2-der-source-precedence)) existiert das Ziel |
| 2026-07-31 | Überarbeitet, weiter **Proposed** | **Die Verpflichtungen waren an Slice-Kennungen adressiert und veralteten damit schneller, als die ADR gelesen wird:** die Zuschreibung an die Definition of Done der Auswertung beschrieb einen Schnitt, den derselbe Tag schon abgelöst hatte, und die Aussage über das Vokabular des Welle-Plans ebenso. Eine ADR ist dauerhaft, ein Slice ist ein Lifecycle-Artefakt — die Bindung des einen an das andere erzeugt die Lüge nur mit Verzögerung. Die Pflichten hängen jetzt an der **Funktion** (der Slice, der die Bilanz baut; der Slice, der die Rollen-Konvention schreibt), nicht an einer Nummer; ein Re-Schnitt verschiebt damit den Träger, nicht die Pflicht. Die Abgrenzung der Nenner-Angabe ist auf **drei** Größen ausgeschrieben (Nenner · Sammelposten-Anteil · Abdeckungszahl), weil die zweite Grenze bisher nur behauptet und nirgends gezogen war. Die zwei Mengenangaben über den Plan-Bestand sind entfallen — sie zählten Lifecycle-Dateien und waren beim Zählen bereits überholt. Slice-Kennungen führt allein die Verweis-Spalte dieser Tabelle |
| 2026-07-31 | Überarbeitet, weiter **Proposed** | **Die Konsequenz schrieb dem Auswertungs-Slice eine Messung zu, die er nicht leisten kann:** er liest ausschließlich Spans, und kein Span trägt Haupt-Kontext-Token; dieselbe Zuschreibung stand in Alternative G. Beide Stellen sagen jetzt, dass die Größe unbeziffert bleibt, solange die Annahmen (a)–(c) gelten. Der Wächter der Nenner-Pflicht steht nicht mehr im Präsens, sondern als fällig. Der Beleg-Verweis auf die Risiken des Auswertungs-Slice ist entfallen — dort steht die Pflicht zur Größe des aufgeteilten Anteils, die diese ADR gegen den Nenner abgrenzt; die Abgrenzung sagt das jetzt selbst. [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) trägt nur noch **eine** Rolle: die emittierte Ebene, hier nicht berührt, mit einem Kriterium an einer Stelle; die fehlende Fitness Function für Festlegung 1 steht allein auf [`AGENTS.md`](../../../AGENTS.md) §3.6. Neu ist **Folgepflicht 4** — der Slice, der die Bilanz baut, nimmt die Nenner-Angabe in seine DoD auf, sonst zeigen die zwei Wächter-Zeilen auf einen Slice, der sie nicht führt; die Präzedenz aus [ADR-0011](0011-telemetrie-erfassung-policy.md) deckt nur das Fehlen der Datei, nicht das Fehlen des DoD-Punktes. Folgepflicht 2 nennt jetzt die Stellen des überholten Welle-Vokabulars und die fehlende Zeile in der Plan-Tabelle des Slice, der die Rollen-Konvention schreibt. Die Mengenaussage *„bisher überwiegend"* über den Ort der Rollen-Arbeit ist auf die eine belegte Beobachtung zurückgenommen |
| 2026-07-31 | Überarbeitet nach Proposed-Review, weiter **Proposed** | **Der blockierende Befund lag in der Fitness Function:** sie erklärte **beide** Hälften für nicht prüfbar, weil die Nenner-Pflicht „in Prosa eines Berichts" lebe, und prüfte das gegen `comment-claims` und `docs-check`. Die Bilanz entsteht aber als Docker-only gebautes Go-Kommando mit `test/`- und `test/mutations/`-Zeile in seiner Plan-Tabelle, und für die Nachbargröße in derselben Ausgabe ist bereits ein Fall gebunden. Die Sensor-Klasse war damit die falsche. Festlegung 2 trägt jetzt zwei Zeilen, Festlegung 1 weiter keine — mit [`AGENTS.md`](../../../AGENTS.md) §3.6 statt [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) als tragendem Grund. Dazu: zwei Größenaussagen über den Haupt-Kontext-Anteil gestrichen (dieselbe ADR führt die Größe wenige Zeilen weiter als **unbekannt**, und die geplante Rollen-Konvention arbeitet daran, sie zu verschieben); die Antwort auf Trichter-Frage 2 um ihre benannte Unsicherheit ergänzt (die ungemessene Payload-Fläche ist *gelesen*, nicht gemessen); Alternative **G** aufgenommen (Arbeit in Subagenten verlagern — bewegt die Größe, nicht die Messbarkeit); Folgepflicht 2 um die im Welle-Vokabular fehlende Belegart ergänzt; `Schärft` von *nicht berührt* auf *nicht entschieden* präzisiert (Folgepflicht 3 berührt die emittierte Ebene sehr wohl); Modul-7-Zitat `:26-29` als Analogie gekennzeichnet, weil Abweichung 6 kein Carveout ist |
| 2026-07-31 | **Proposed** | Die Werkzeug-Wahl nach Modul 7 zu [`MR-018`](../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung) Abweichung 6. Anlass war ein Review-Befund: die Abweichung stand als temporäre da, ohne Folge-Slice und mit einem Entscheidungs-Ort, dessen Prüfbereich sie nicht umfasst |
