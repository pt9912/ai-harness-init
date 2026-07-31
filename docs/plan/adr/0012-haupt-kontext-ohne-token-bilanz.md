# ADR-0012: Der Haupt-Kontext bleibt ohne Token-Bilanz — die Abweichung ist permanent, nicht temporär

**Status:** Proposed

**Datum:** 2026-07-31

**Autor:** ai-harness-init-Team (pt9912)

**Bezug:**
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (der
Grund, warum unten **keine** Fitness Function steht: kein Gate über leerem Prüfbereich),
[ADR-0011](0011-telemetrie-erfassung-policy.md) (**Accepted** — Festlegung 1 Punkt 5 verlangt,
das nach der Ableitung Unerreichbare *begründet zu dokumentieren*; **ob** dokumentiert wird, ist
dort entschieden, **in welcher Artefakt-Klasse** — temporäre Ausnahme oder
Architekturentscheidung — entscheidet diese ADR)

**Schärft:** `—` (Prozess-/Betriebs-ADR ohne Spec-Stratum, dieselbe Einordnung wie
[ADR-0011](0011-telemetrie-erfassung-policy.md)). Die **emittierte** Ebene ist nicht berührt:
entschieden wird über den Dogfood-Bestand dieses Repos.

---

## Kontext

`.harness/baseline/v3.5.2/regelwerk/modul-15-observability.md` §Token-Attributions-Regeln
verlangt eine Token-Bilanz **je Rolle**.
[`MR-018`](../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung) führt
sechs erklärte Abweichungen von diesem Pflicht-Minimum; die sechste ist die härteste und der
Gegenstand hier: **der Haupt-Kontext hat keine Zahl** — und er ist der Ort, an dem der größte
Teil der Arbeit anfällt.

**Was gemessen ist** (im Einzelnen in
[`MR-018`](../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
Abweichung 6, hier nicht verdoppelt — zwei Stellen mit derselben Messung driften auseinander):
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
abgegeben. `.harness/baseline/v3.5.2/regelwerk/modul-07-carveouts.md:26-29` entscheidet genau
diesen Zustand: *„Fehlt der Folge-Slice, ist der Carveout de facto permanent — dann gehört er
nicht in `carveouts/`, sondern über den Trichter unten in eine ADR."*

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

**Die Gegenposition, die zuvor an dieser Stelle stand, trägt nicht** — und sie gehört genannt,
weil sie bequem ist: der Trigger sei *nur beobachtbar, nicht durch Aufwand erreichbar*, und
brauche deshalb weder Folge-Slice noch ADR. „Aufwand" steht in Modul 7 an genau einer Stelle,
und sie entscheidet *Carveout gegen ADR*, nicht *Träger gegen kein Träger*. Die Haltung selbst
ist dort ausdrücklich beantwortet (`:129`): *„Gegen ‚Wenn der Trigger eintritt, lösen wir den
Carveout auf': Realität: er bleibt liegen. Deshalb braucht jeder temporäre Carveout einen
Folge-Slice mit ID, der das Auflösen plant. Slice schlägt Memo."* Ein Zustand, für den es weder
einen Träger noch etwas zu planen gibt, ist nach diesem Modul kein temporärer.

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
   Abweichung 6 und in den Risiken von slice-066; diese ADR begründet sie, sie führt sie nicht
   ein (eine zweite Formulierung derselben Pflicht wäre eine zweite Wahrheit).
3. **Die Rollen-Frage bleibt offen und ist hier nicht mitentschieden.** Der Haupt-Strom bleibt
   der Sammelposten, und die von Modul 15 verlangte begründete Splitting-Regel bleibt fällig —
   sie verteilt **Etiketten** auf gemessene Token, sie erzeugt keine. Wer diese ADR als
   Erledigung der Sammelposten-Pflicht liest, liest sie falsch.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — **nichts tun**: die Abweichung bleibt als temporäre stehen | kein Aufwand; der Text ist bereits geschrieben | ein temporärer Carveout ohne Folge-Slice ist nach `modul-07-carveouts.md:26-29` *de facto* permanent — und behauptet dabei das Gegenteil. Der zuvor benannte Entscheidungs-Ort (das Wellen-Closure-Audit) hat über diesen Absatz **keinen Prüfbereich**: sein Gegenstand sind nach `:105-110` die Artefakte unter `docs/plan/carveouts/`, und der Closure-Trigger dieser Welle setzt genau diesen Umfang. Beide Prüfungen gingen durch, keine sähe die Sache |
| B — **Folge-Slice, der das Auflösen plant** | die Form, die Modul 7 für temporäre Ausnahmen verlangt (*„Slice schlägt Memo"*) | er hat keinen Gegenstand. Die Bedingung ist nicht durch Arbeit herbeizuführen: wir bestimmen weder die Payload noch die Erlaubnis, das Transkript zu lesen. Ein Slice mit dem Inhalt „abwarten" ist das Memo unter anderem Namen |
| C — **Mess-Slice**: Sonde auf die hier nie vermessenen Ereignis-Payloads | planbar, endlich, und er machte aus gelesener Doku eine Messung — die Lehre dieses Repos lautet *„die Payload ist die Quelle, die Doku ist Herkunft"* | er **löst nichts auf**: er beobachtet, ob der Trigger schon eingetreten ist, er führt ihn nicht herbei. Sein Erwartungswert ist negativ — die vendored `docs/user/claude-hooks-referenz.md` nennt in ihrer ganzen Länge ein `usage`-Objekt und ein `totalTokens` **nur** für die `tool_response` des `Agent`-Werkzeugs (`:1571-1574`), für kein anderes Ereignis ein Nutzungsfeld. Danach stünde dieselbe Frage erneut, und die Abweichung wäre um eine Runde älter. Das Wissen, das er brächte, ist unten als **benannte ungemessene Fläche** aufgehoben, ohne einen WIP-Platz zu belegen |
| D — **Transkript als Quelle** | es trägt die Zähler und liegt auf derselben Maschine | auf Entscheidung des Auftraggebers ausgeschlossen: fremder Besitz, außerhalb des Repos, voller Gesprächsinhalt. [ADR-0011](0011-telemetrie-erfassung-policy.md) hat dieselbe Option bereits als Alternative D verworfen; ein Zeiger darauf legte eine Auflösung nahe, die niemand genehmigt hat |
| E — **eigener Telemetrie-Empfänger**, der die Nutzungs-Telemetrie des Werkzeugs annimmt | er bekäme Zahlen, die kein Hook trägt | [ADR-0011](0011-telemetrie-erfassung-policy.md) hat den Stack als Option B verworfen ([`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten): neue Laufzeit-Abhängigkeit; ein Backend ohne Betreiber). Dazu ein Detail aus der vendored Werkzeug-Doku: das Werkzeug **entfernt die Exporter-Variablen aus jedem Unterprozess, den es spawnt, einschließlich Hooks** — die Erfassungsstelle, die wir haben, käme an diese Achse ohnehin nicht heran |
| **F — permanent, als ADR (gewählt)** | die Abweichung hört auf, auf einen Träger zu warten, den es nicht gibt; die Einordnung steht dort, wo Architekturentscheidungen stehen, und die Nenner-Pflicht bekommt ihre Begründung | eine ADR ist ab *Accepted* immutabel ([`AGENTS.md`](../../../AGENTS.md) §3.4): wird die Quelle doch erreichbar, entsteht eine neue ADR mit *Supersedes*, kein Federstrich. Und sie schließt keine Lücke — sie benennt sie dauerhaft |

## Konsequenzen

- **Positiv:** der Zustand ist entschieden statt aufgeschoben. Wer
  [`MR-018`](../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
  Abweichung 6 liest, findet keine Zusage mehr, die auf einen Träger zeigt, den es nicht gibt.
- **Positiv:** die Pflicht, den Nenner zu nennen, hat ab hier eine Begründung statt nur einen
  Ort. Sie ist der Teil dieser Entscheidung, der **überprüfbar** ist — an jedem Bericht, der
  entsteht.
- **Negativ, und das ist der Preis:** der größte Teil der Arbeit fällt im Haupt-Kontext an. Eine
  Bilanz über Subagenten-Läufe misst damit dauerhaft die kleinere Hälfte, und keine Zahl aus
  diesem Bestand beantwortet *„was hat dieser Lauf gekostet?"*. Modul 15
  §Token-Attributions-Regeln bleibt für den Haupt-Kontext **unerfüllt** — als erklärte
  Abweichung, nicht als Erfüllung.
- **Negativ:** eine Auswertung muss ihren Nenner selbst führen. Kein Feld im Span sagt ihr, wie
  groß der nicht erfasste Teil war — die Größe ist nicht klein, sie ist **unbekannt**.
- **Folgepflicht 1:**
  [`MR-018`](../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
  Abweichung 6 trägt statt eines Auflösungs-Triggers das Verdikt *permanent — übergeführt in
  diese ADR*. Modul 7 §Werkzeug-Wahl sieht das so vor: auf dem ADR-Pfad **fällt der Trigger
  weg**, die Beschreibung bleibt.
- **Folgepflicht 2:** die Matrix-Zelle *Token-Attribution × Repo* des Wellen-Closure führt für
  den Haupt-Kontext **nicht** „deklarierte Entscheidung mit Auflösungs-Trigger", sondern den
  Verweis auf diese ADR. Die Zelle bleibt belegt — die Belegart wechselt. Wer sie ausfüllt, ohne
  das zu bemerken, schreibt einen Trigger hin, den es nicht mehr gibt.
- **Folgepflicht 3:** wird der Span-Emitter je emittiert (die Tool-Ebene, eigener Slice mit
  Change Request), gilt diese Grenze im Ziel unverändert — sie ist keine Eigenschaft unseres
  Aufbaus, sondern der Mechanik. Sie gehört dort **genannt**, nicht stillschweigend
  mitgeliefert.

## Fitness Function (falls maschinell prüfbar)

**Keine — und das ist eine Aussage, kein Auslassen.** Die einzige prüfbare Hälfte dieser
Entscheidung ist Festlegung 2 („jede Bilanz nennt ihren Nenner"), und sie lebt in **Prosa**
eines Berichts. Die zwei Gates, die in diesem Repo überhaupt an Sätze heranreichen könnten,
decken sie nach ihrem **selbst deklarierten** Prüfbereich nicht: `make comment-claims` prüft
vier Pfad-Muster (`internal/**/*.go`, `cmd/**/*.go`, `harness/tools/*.sh`, `.claude/hooks/*.sh`)
und damit kein Markdown, und `make docs-check` prüft Links, Anker, Kennungen, Matrix, Codepfade
und Spans — keine Behauptungen. Eine Tabellenzeile hier wäre ein Gate über leerem Prüfbereich
und damit genau der Fehler, gegen den
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) steht.

**Was stattdessen trägt:** die Bilanz entsteht in einem Slice mit Review und Verifikation, und
die Nenner-Pflicht steht in seinem Plan. Das ist ein menschlicher Träger mit Namen — schwächer
als ein Sensor, aber nicht namenlos.

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
| 2026-07-31 | **Proposed** | slice-060 DoD (3) — die Werkzeug-Wahl nach Modul 7 zu [`MR-018`](../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung) Abweichung 6. Anlass war ein Review-Befund: die Abweichung stand als temporäre da, ohne Folge-Slice und mit einem Entscheidungs-Ort, dessen Prüfbereich sie nicht umfasst |
