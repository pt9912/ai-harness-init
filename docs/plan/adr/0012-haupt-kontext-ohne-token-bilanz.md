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

**Schärft:** `—` (Prozess-/Betriebs-ADR ohne Spec-Stratum, dieselbe Einordnung wie
[ADR-0011](0011-telemetrie-erfassung-policy.md)). Die **emittierte** Ebene wird hier nicht
**entschieden** — Gegenstand ist der Dogfood-Bestand dieses Repos, und das **Ob** der Emission
bleibt slice-062 samt Change Request ([ADR-0011](0011-telemetrie-erfassung-policy.md)
Festlegung 5). **Berührt** ist sie sehr wohl, und zwar als Folgepflicht 3 unten: wird je
emittiert, gilt diese Grenze im Ziel und gehört dort genannt.

---

## Kontext

`.harness/baseline/v3.5.2/regelwerk/modul-15-observability.md` §Token-Attributions-Regeln
verlangt eine Token-Bilanz **je Rolle**.
[`MR-018`](../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung) führt
sechs erklärte Abweichungen von diesem Pflicht-Minimum; die sechste ist die härteste und der
Gegenstand hier: **der Haupt-Kontext hat keine Zahl** — und er ist der Ort, an dem auch
Rollen-Arbeit anfällt: an slice-060 ist belegt, dass Planner und Implementation über weite
Strecken in **einem** Kontextfenster liefen. **Wie viele Token** das sind, weiß niemand — und
genau das ist der Gegenstand.

**Was gemessen ist** (im Einzelnen in
[`MR-018`](../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
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
**ohne Folge-Slice**. Über die **neun** lebenden Plandateien — `open/`, `next/`, `in-progress/`
samt Roadmap und der flach liegende Welle-Plan — führt kein Slice diese Bedingung; die fünf, die
überhaupt von Token sprechen, tun es zu anderen Fragen (Splitting-Regel des Sammelpostens,
Berichtsgröße, Wächter-Bindung), und der eine Slice, der die Bedingung einmal trug, hat seinen
DoD-Punkt
ausdrücklich an
[`MR-018`](../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
abgegeben. `.harness/baseline/v3.5.2/regelwerk/modul-07-carveouts.md:26-29` beschreibt genau
diesen Zustand: *„Fehlt der Folge-Slice, ist der Carveout de facto permanent — dann gehört er
nicht in `carveouts/`, sondern über den Trichter unten in eine ADR."* **Der Satz greift hier nach
seiner Logik, nicht nach seinem Buchstaben, und das gehört gesagt:** Abweichung 6 ist **kein**
Carveout und liegt nicht unter `docs/plan/carveouts/` — sie ist eine erklärte Abweichung in
[`MR-018`](../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung).
Bindend ist deshalb der **Trichter** (`:46-93`), und der spricht ausdrücklich von *Diskrepanzen*,
bevor eine als Carveout festgeschrieben wird (`:48`).

**Der Trichter, beide Fragen, in der Reihenfolge des Moduls** (`:48-67` — Granularität **vor**
Temporalität):

1. **Granularität — einzelne Diskrepanz oder Cluster?** *Einzelne.* Die Nachbar-Abweichung 5
   (Hintergrund-Läufe tragen keine Verbrauchs-Achse) betrifft dieselbe Achse, hat aber einen
   eigenen, ernst erreichbaren Trigger und ist durch einen `PreToolUse`-Guard bereits
   verkleinert — ein gemeinsamer Geltungsbereich mit gemeinsamer Auflösung besteht nicht. Auch
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
   in [`MR-018`](../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
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
| G — **Rollen-Arbeit in Subagenten verlagern**, damit weniger im Haupt-Kontext anfällt | die einzige Option, die die **Größe** des unerfassten Anteils bewegt statt seiner Messbarkeit; sie ist bereits geplant (slice-068 schreibt die Konvention und legt die Berichtsgröße fest, slice-066 erzeugt sie) | sie beantwortet die Frage dieser ADR **nicht**: der Haupt-Kontext bekäme keine Zahl, sondern nur weniger Arbeit — und **wie viel weniger, misst niemand**: die verschobene Menge liegt vor der Verschiebung in genau der Größe, die keine Payload trägt. Ablesbar ist allein, was auf der anderen Seite ankommt. Sie ist deshalb keine Alternative zu F, sondern das, was **neben** F läuft. Sie steht hier, damit die Konsequenz unten nicht als *„daran ist nichts zu machen"* gelesen wird |
| **F — permanent, als ADR (gewählt)** | die Abweichung hört auf, auf einen Träger zu warten, den es nicht gibt; die Einordnung steht dort, wo Architekturentscheidungen stehen, und die Nenner-Pflicht bekommt ihre Begründung und ihren Zahn | eine ADR ist ab *Accepted* immutabel ([`AGENTS.md`](../../../AGENTS.md) §3.4): wird die Quelle doch erreichbar, entsteht eine neue ADR mit *Supersedes*, kein Federstrich. Und sie schließt keine Lücke — sie benennt sie dauerhaft |

## Konsequenzen

- **Positiv:** der Zustand ist entschieden statt aufgeschoben. Wer
  [`MR-018`](../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
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
  Spans, und kein Span trägt diese Token. Was slice-066 beziffert, ist eine **andere** Größe: den
  Sammelposten-Anteil **innerhalb** der erfassten Teilmenge (unten abgegrenzt). Eine Größenangabe
  an dieser Stelle wäre die Schätzung, die der Kontext oben ausschließt
  ([ADR-0011](0011-telemetrie-erfassung-policy.md) Festlegung 1 Punkt 4).
- **Folgepflicht 1:**
  [`MR-018`](../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
  Abweichung 6 trägt statt eines Auflösungs-Triggers das Verdikt *permanent — übergeführt in
  diese ADR*. Modul 7 §Werkzeug-Wahl sieht das so vor: auf dem ADR-Pfad **fällt der Trigger
  weg**, die Beschreibung bleibt.
- **Folgepflicht 2 — und sie verlangt eine Ergänzung des Vokabulars, nicht nur eine Zelle.** Die
  Matrix-Zelle *Token-Attribution × Repo* des Wellen-Closure führt für den Haupt-Kontext
  **nicht** „deklarierte Entscheidung mit Auflösungs-Trigger", sondern den Verweis auf diese ADR.
  **Diesen Wert kennt der Welle-Plan bisher nicht:** sein Closure-Trigger definiert *deklariert*
  ausdrücklich als bewusste Nicht-Umsetzung **mit Auflösungs-Trigger** — genau das, was Modul 7
  auf dem ADR-Pfad wegfallen lässt —, und eine leere Zelle liest er als offenen Closure-Trigger.
  Wer sie ausfüllt, ohne das zu bemerken, schreibt entweder einen Trigger hin, den es nicht mehr
  gibt, oder lässt die Zelle offen. Die Zelle bleibt belegt — die **Belegart** wechselt.
  **Das überholte Vokabular steht im Welle-Plan an drei Stellen:** im Welle-Ziel, in der
  Wert-Tabelle des Closure-Triggers und in der Slice-Zeile zu slice-068, die diesem eine
  Festlegung *„deklarierte Entscheidung mit Trigger"* zuschreibt — die er nach seinem DoD (3) so
  nicht mehr trifft. Wer die Belegart ergänzt, zieht den Satz mit, der die Belegarten zählt.
  slice-068 trägt die Festlegung; seine Plan-Tabelle führt den Welle-Plan heute **nicht** als
  berührte Datei, und dorthin gehört die Ergänzung geplant.
- **Folgepflicht 3:** wird der Span-Emitter je emittiert (die Tool-Ebene, eigener Slice mit
  Change Request), gilt diese Grenze im Ziel unverändert — sie ist keine Eigenschaft unseres
  Aufbaus, sondern der Mechanik. Sie gehört dort **genannt**, nicht stillschweigend
  mitgeliefert.
- **Folgepflicht 4 — sie geht der Annahme dieser ADR voraus, sie folgt ihr nicht.** slice-066
  nimmt die Nenner-Angabe in seine Definition of Done auf: die erzeugte Bilanz benennt, worüber
  sie rechnet, und ein Fall in `test/mutations/` entfernt die Angabe wieder. Heute bindet seine
  Plan-Tabelle `test/` und `test/mutations/` ausdrücklich an DoD (1) und (2) — an den
  Sammelposten-Anteil samt Abdeckungszahl und an die getrennten Cache-Zähler. Die Nenner-Angabe
  ist keine von beiden (unten abgegrenzt). Ohne diesen DoD-Punkt zeigen die zwei Zeilen der
  Fitness Function auf einen Slice, der sie nicht führt: er liefe plan-konform ab, `make gates`
  und `make mutate` blieben grün, und Festlegung 2 bliebe ohne Zahn — ein nie angelegter Fall
  erzeugt kein Rot. Der Slice-Plan gehört dem Planner; diese ADR benennt die Bedingung, sie
  schreibt ihn nicht.

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

**Festlegung 2 — eine, fällig mit slice-066.** Die Bilanz ist **kein Prosa-Bericht**: slice-066
baut sie als eigenes Go-Kommando, Docker-only gebaut wie jedes Binary dieses Repos
([ADR-0003](0003-go-native-binaries.md)), und führt `test/` samt `test/mutations/` in seiner
Plan-Tabelle. Ihre Ausgabe ist damit genau die Fläche, die dieses Repo überall sonst bewacht —
ein Go-Test auf die erzeugte Zeile plus ein Fall, der sie entfernt. slice-068 verlangt für die
Nachbargröße bereits dasselbe (*„fällt der Sammelposten-Anteil aus dem Bericht, muss ein Fall rot
werden"*); die Nenner-Angabe in derselben Ausgabe ohne Zahn zu lassen, wäre zweierlei Maß.

| Tooling | Regel | Make-Target |
|---|---|---|
| Go-Test (`make test`) — **fällig mit slice-066 (Folgepflicht 4), existiert heute nicht** | Die erzeugte Bilanz **benennt ihren Nenner**: dass sie über **Subagenten-Läufe** rechnet und nicht über den Lauf. Fehlt die Angabe in der Ausgabe, fällt der Test | `make test` |
| `test/mutations/` — **fällig mit slice-066 (Folgepflicht 4), existiert heute nicht** | Die Nenner-Angabe wird aus dem Auswerter **entfernt** — der Wächter darüber muss rot werden; ohne diesen Fall wäre Festlegung 2 eine Absicht | `make mutate` |

**Was die zwei Zeilen nicht leisten.** Sie binden die
**Anwesenheit** der Nenner-Angabe, nicht ihre **Wahrheit**: ob die genannte Teilmenge die
tatsächlich gerechnete ist, prüft kein Sensor — dieselbe Grenze, die
[`MR-018`](../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung) für
`make comment-claims` ausspricht (*es prüft die Existenz des Sensors, nicht die Wahrheit des
Satzes*). Und der Nenner ist **nicht** der Sammelposten-Anteil aus slice-066 DoD (1): der misst,
wie viel der Bilanz auf der Splitting-Regel ruht; dieser hier sagt, worüber überhaupt gerechnet
wird. Zwei Größen, zwei Angaben, zwei Zähne — wer sie zusammenlegt, verliert eine. Aus demselben
Grund tragen die Risiken von slice-066 die Nenner-Pflicht **nicht**: was dort steht, ist die
Pflicht zur Größe des aufgeteilten Anteils.

**Die Zeilen nennen einen Sensor, den es noch nicht gibt** —
[ADR-0011](0011-telemetrie-erfassung-policy.md) wurde mit **fünf**
`test/mutations/`-Zeilen angenommen, deren Dateien erst der umsetzende Slice anlegte — zum
Zeitpunkt der Annahme trug das Verzeichnis 106 Fälle, die Span-Fälle beginnen bei 107. **Die
Präzedenz trägt eine Hälfte:** dass die Datei fehlen darf. Die zweite trägt sie nicht — dort
nannte der umsetzende Slice die Zähne in seiner eigenen DoD
(`docs/plan/planning/done/slice-059-telemetrie-erfassung-hook.md` DoD (3), *„Zwei Zähne, rot
gesehen"*, und dieselben zwei in seiner Plan-Tabelle). Genau das verlangt Folgepflicht 4 für
slice-066.
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
  [`MR-018`](../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung) nach;
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
| 2026-07-31 | Überarbeitet, weiter **Proposed** | **Die Konsequenz schrieb dem Auswertungs-Slice eine Messung zu, die er nicht leisten kann:** er liest ausschließlich Spans, und kein Span trägt Haupt-Kontext-Token; dieselbe Zuschreibung stand in Alternative G. Beide Stellen sagen jetzt, dass die Größe unbeziffert bleibt, solange die Annahmen (a)–(c) gelten. Der Wächter der Nenner-Pflicht steht nicht mehr im Präsens, sondern als fällig. Der Beleg-Verweis auf die Risiken von slice-066 ist entfallen — dort steht die Pflicht zur Größe des aufgeteilten Anteils, die diese ADR gegen den Nenner abgrenzt; die Abgrenzung sagt das jetzt selbst. [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) trägt nur noch **eine** Rolle: die emittierte Ebene, hier nicht berührt, mit einem Kriterium an einer Stelle; die fehlende Fitness Function für Festlegung 1 steht allein auf [`AGENTS.md`](../../../AGENTS.md) §3.6. Neu ist **Folgepflicht 4** — slice-066 nimmt die Nenner-Angabe in seine DoD auf, sonst zeigen die zwei Wächter-Zeilen auf einen Slice, der sie nicht führt; die Präzedenz aus [ADR-0011](0011-telemetrie-erfassung-policy.md) deckt nur das Fehlen der Datei, nicht das Fehlen des DoD-Punktes. Folgepflicht 2 nennt jetzt alle drei Stellen des überholten Welle-Vokabulars und die fehlende Zeile in der Plan-Tabelle von slice-068. Die Mengenaussage *„bisher überwiegend"* über den Ort der Rollen-Arbeit ist auf die eine belegte Beobachtung zurückgenommen |
| 2026-07-31 | Überarbeitet nach Proposed-Review, weiter **Proposed** | **Der blockierende Befund lag in der Fitness Function:** sie erklärte **beide** Hälften für nicht prüfbar, weil die Nenner-Pflicht „in Prosa eines Berichts" lebe, und prüfte das gegen `comment-claims` und `docs-check`. Die Bilanz entsteht aber als Docker-only gebautes Go-Kommando mit `test/`- und `test/mutations/`-Zeile in seiner Plan-Tabelle, und slice-068 bindet für die Nachbargröße in derselben Ausgabe bereits einen Fall. Die Sensor-Klasse war damit die falsche. Festlegung 2 trägt jetzt zwei Zeilen, Festlegung 1 weiter keine — mit [`AGENTS.md`](../../../AGENTS.md) §3.6 statt [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) als tragendem Grund. Dazu: zwei Größenaussagen über den Haupt-Kontext-Anteil gestrichen (dieselbe ADR führt die Größe wenige Zeilen weiter als **unbekannt**, und slice-068 arbeitet daran, sie zu verschieben); die Antwort auf Trichter-Frage 2 um ihre benannte Unsicherheit ergänzt (die ungemessene Payload-Fläche ist *gelesen*, nicht gemessen); Alternative **G** aufgenommen (Arbeit in Subagenten verlagern — bewegt die Größe, nicht die Messbarkeit); Folgepflicht 2 um die im Welle-Vokabular fehlende Belegart ergänzt; `Schärft` von *nicht berührt* auf *nicht entschieden* präzisiert (Folgepflicht 3 berührt die emittierte Ebene sehr wohl); Modul-7-Zitat `:26-29` als Analogie gekennzeichnet, weil Abweichung 6 kein Carveout ist |
| 2026-07-31 | **Proposed** | slice-060 DoD (3) — die Werkzeug-Wahl nach Modul 7 zu [`MR-018`](../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung) Abweichung 6. Anlass war ein Review-Befund: die Abweichung stand als temporäre da, ohne Folge-Slice und mit einem Entscheidungs-Ort, dessen Prüfbereich sie nicht umfasst |
