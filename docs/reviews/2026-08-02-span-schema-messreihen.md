# Messreihen zum Span-Schema — die datierten Belege

**Rolle:** Implementation (Modul 9). **Datum:** 2026-08-02. **Autor:** ai-harness-init-Team (pt9912).

**Gegenstand:** die datierten Messungen, rot-gesehen-Nachweise und Gegenproben, auf denen die
Festlegungen zur Span-Erfassung ruhen. Sie sind Zeitdokument: jede Zahl gilt an ihrem Datum und
altert mit dem nächsten Commit — deshalb stehen sie hier und nicht im bindenden Text.

**Was hier NICHT steht:** die Festlegungen selbst. Die stehen in
`spec/spezifikation.md` §3 und §5, und wo eine Messung eine Regel trägt, steht die Regel dort und
die Messung hier.

---

## 1. Die Payload — was sie trägt (2026-07-29)

Eine echte Hook-Payload wurde auf ihre **Schlüsselnamen** hin vermessen (nur Namen und
Wertlängen, nie Werte):

`cwd · duration_ms · effort · hook_event_name · permission_mode · prompt_id · session_id ·
tool_input · tool_name · tool_response · tool_use_id · transcript_path`

Zwei Lehren daraus: `duration_ms` liegt bereit — die Annahme, dafür brauche es einen zweiten
Hook auf `PreToolUse`, war falsch. Und das Ergebnis heißt **`tool_response`**, nicht
`tool_output`.

**`tool_input` über vier echte Aufrufe** — darunter den per @-Erwähnung angeforderten —: die
Schlüssel `subagent_type`, `prompt`, `description` und `run_in_background`. Das dokumentierte
Eingabe-Schema in `docs/user/claude-hooks-referenz.md` nennt darüber hinaus nur `model`. Die
Messung erfasste ausdrücklich **nur Feldnamen und Wertlängen, nie Werte**.

**`tool_response` eines Hintergrund-Laufs** (2026-07-29, an einem echten Aufruf): `agentId`,
`isAsync`, `outputFile`, `canReadOutputFile`, `resolvedModel`, `status`, `prompt`,
`description`; **keiner** der vier `usage`-Zähler, kein
`totalTokens`/`totalDurationMs`/`totalToolUseCount`, kein `agentType`.

**Vier gemessene Aufrufe zeigten fünf undokumentierte Schlüssel** — die Fläche wächst erkennbar
weiter; das ist der Messbefund, auf dem die Wahl *Positiv-Liste statt Negativ-Liste* ruht.

## 2. Die Cache-Zähler (2026-07-29 gemessen, seit 2026-07-30 erfasst)

`cache_creation_input_tokens` und `cache_read_input_tokens` liegen im `usage`-Objekt der
`tool_response` eines Vordergrund-`Agent`-Aufrufs vor — ohne Transkript und ohne Zugriff
außerhalb des Repos. Bis zum 2026-07-29 galt der Cache-Status als nicht erreichbar; die
Abweichung ist seither verkleinert, nicht aufgehoben.

## 3. Die zwei Bedingungen der Start-Konvention sind unabhängig (2026-07-29)

Ein per @-Erwähnung angeforderter Lauf **ohne** ausdrücklichen Schalter lief im
**Hintergrund**: sein Span trug `duration_ms: 3` bei **4.184 ms** tatsächlicher Laufzeit des
Subagenten. Der Hook feuert **nach** dem Aufruf (`PostToolUse`), die drei Millisekunden sind
also die Dauer des **Aufrufs** — das Werkzeug gab sofort nach dem Start zurück.

**Diese 4.184 ms gehören nur zu diesem Aufruf.** Er lief im Hintergrund und trägt gar kein
`totalDurationMs`. Wer sie mit dem `duration_ms` eines Vordergrund-Laufs paart, fügt zwei
Beobachtungen zu einer Messung zusammen, die niemand gemacht hat.

**Der Guard, an einem echten Aufruf rot gesehen** — nicht nur am Test: ein Rollen-Typ mit
`run_in_background: true` wurde abgelehnt, der Ablehnungsgrund kam wörtlich als Fehler beim
Aufrufer an, der Subagent lief nicht; derselbe Typ mit `false` lief unmittelbar davor durch.

## 4. `agent_type` über alle Ströme (2026-07-29)

Bei Review- **und** Verify-Läufen steht in `agent_type` derselbe Wert (`general-purpose`); die
beiden Rollen sind in den Daten ununterscheidbar. Die **kanonischen Namen der Agenten-Typen**
sind eine Festlegung vom 2026-07-29 (slice-060 Frage A): `planner` · `architect` ·
`implementer` · `reviewer` · `verifier` · `validator`.

## 5. Die Strom-Identität: doppelt vergebene Nummern (2026-07-29)

Die Korrektur der Namensbildung am 2026-07-29 (Trenner `-` innerhalb der Teile zu `_`, gegen
Strom-Kollisionen) hat den **laufenden** Strom jener Sitzung in zwei Dateien mit **identischem
`(session, agent)`** und zwei Zählerkreisen zerlegt — **58 doppelt vergebene Nummern**.

Dieselbe Klasse trat schon einmal auf (awk→Go, **16 Duplikate**); beide Male war der Auslöser
ein Wechsel der Mechanik bei laufendem Strom.

## 6. Die Wächter der Erfassung aus `tool_response`

### 6.1 Warum die Bindung Zusicherung für Zusicherung geführt wird (2026-07-30)

Die Vorgängerin dieser Liste stellte Namen und Zahlen nebeneinander und wurde als
1:1-Abbildung gelesen (Verifier-Befund V-1 vom 2026-07-30). Dort standen sieben Wächter und
**sieben** Zähne (123–129). Gezählt nach *„irgendein Fall nennt ihn"* hatten **fünf** der
sieben einen Zahn; gezählt nach *„ein Zahn bindet die Zusicherung, die dieser Absatz ihm
zuschreibt"* waren es **vier**.

Die Differenz ist genau `TestAgentGetsNoArgumentFields`:
`test/mutations/131-span-werkzeugname-leer.sh` nennt ihn, bindet aber seine Gegenprobe
`"tool":"Agent"` — nicht die Zusicherung, für die es ihn gibt. **Gemessen, nicht geschlossen**
(2026-07-30, einzeln über den `run_case`-Pfad des Treibers): streicht man seine beiden
B1-Zusicherungen — das `"spawned_role"` im `mustNotContain` und die `s.SpawnedRole != ""`-Prüfung
—, bleibt `make test-go` **grün** und Fall 131 meldet weiter „ok". Die Grenze, auf der das
Architect-Verdikt vom 2026-07-30 ruht
(`docs/reviews/2026-07-30-slice-060-dod2-adr-0011-architect.md`), durfte damit lautlos
verschwinden.

Die vier Fälle 132–135 schließen das; 136 und 137 kamen am selben Tag aus den Review-Befunden
MEDIUM-1 und MEDIUM-2 dazu, 138 am 2026-07-31. **Jeder ist einzeln über den `run_case`-Pfad
des Treibers gefahren** (Grün-Vorlauf und -Nachlauf grün, Host-Baum unberührt), und **fünf der
sieben färben genau EINEN Wächter an genau der Zeile ihrer Zusicherung**; 137 und 138 färben
bauartbedingt **zwei**, weil die Draht-Form von `spawned_role` in zwei Wächtern zugesagt ist —
ihre Köpfe sagen welche, und ihre `# expect:`-Zeilen binden je einen der zwei Einträge.
Mehrfach-Rot verdeckt seinen eigenen Grund — die Lehre aus Review-Befund MEDIUM-4 —, deshalb
steht die Zahl je Fall auch in seinem Kopf.

### 6.2 Die Zählregel: „ein Wächter" heißt eine Test-FUNKTION

Nicht eine `--- FAIL:`-Zeile — bei 133 fallen **vier** Zeilen an: die Funktion
`TestOnlyAgentToolGetsResponseValues` und ihre drei Untertests `Bash`, `Read`, `Write`, alle an
derselben Zeile. Wer am `--- FAIL:` abzählt, bekommt eine andere Zahl; gezählt wird die
Funktion.

### 6.3 Wo genau die Wächter fielen (2026-07-30 und 2026-07-31)

**Gemessen am 2026-07-31** (Roh-Läufe, alle `--- FAIL:`-Zeilen ausgezählt): 132 fiel an
`response_test.go:207`, 133 an `:169`, 135 an `:221`, 134 an `:343`, 136 an `:343`, 137 an
`:207` **und** `:343`, 138 ebenso an `:207` **und** `:343` — 134/136/137/138 an derselben
`mustNotContain`-Zeile `:343`, je an einem anderen **Eintrag** (134 an `input_tokens`, 136 an
`output_tokens`, 137 und 138 an `spawned_role`), 137 und 138 zusätzlich an `:207`, der
gleichlautenden Zusicherung des ersten Wächters.

Die Vorgänger-Messung vom 2026-07-30 nannte `:209`/`:171`/`:223`/`:347` — dieselben
Zusicherungen, um zwei bis vier Zeilen verschoben. **Genau das ist der Grund, warum diese
Nummern ein Zeitdokument sind und keine lebende Zusage.**

**Kein Sensor prüft sie**, und der Grund ist **nicht** die Form der Referenz, sondern ihr Ort:
`codepaths` — und mit ihm die Zeilen-Prüfung `check-lines` — arbeitet nur unter
`roots: [spec, docs, harness]` (`.d-check.yml`), und `internal/` steht dort nicht.
**Gemessen am 2026-07-31** (drei `make docs-check`-Läufe gegen eine isolierte Kopie, alle
Sonden in **derselben** Datei, damit das referenzierende Dokument konstant bleibt): eine
Zeilen-Referenz auf `internal/span/response_test.go` weit jenseits seiner Zeilenzahl bleibt
**still** — als Bereich **und** als Einzelzeile, mit voller Verzeichnis-Komponente (259
Datei(en), 0 Befund(e)) —, während dieselbe Form auf `harness/tools/mutate.sh` **einen** Befund
`citation-out-of-range` meldet. Die Verzeichnis-Komponente ist also weder notwendig noch
hinreichend; bindend ist `roots`.

**Was daraus für die zurückgestellte Sensor-Arbeit folgt:** sie ist eine **Erweiterung von
`codepaths.roots` um `internal`** — eine Gate-Anhebung, ab der **jeder** Inline-Code-Pfad unter
`internal/` mitvalidiert wird, mit entsprechender Sprengweite — und damit ein Steering-Loop,
**nicht** ein Weiten von `check-lines` auf Referenzen ohne Verzeichnis-Komponente.

**Nachmessung 2026-08-02, dieselbe Frage für `test/`:** fünf Sonden in **einer** Datei einer
isolierten Kopie (`spec/spezifikation.md`), ein `make docs-check` je Lauf, gepinntes Image,
`--network none`. Ohne Sonden: 281 Datei(en), **0** Befund(e). Mit Sonden: ein nicht
existierender Pfad `test/mutations/999-gibt-es-nicht.sh` bleibt **still**, derselbe Fehler als
`harness/tools/999-gibt-es-nicht.sh` meldet `codepath-missing`; eine Zeilen-Referenz
`test/mutations/123-span-ergebnis-content.sh:9000-9001` bleibt **still**, dieselbe Form auf
`harness/tools/mutate.sh:9000-9001` meldet `citation-out-of-range`. **Kein Gate prüft also, ob
ein namentlich genannter Mutations-Fall noch existiert oder noch so heißt.**

### 6.4 Zusicherung 8: genannt ist nicht gedeckt (2026-07-30)

Die `mustNotContain`-Liste von `TestFailedAgentCallCapturesNothing` nennt seit dem 2026-07-30
**alle neun** Werte namentlich. Vorher trennten sich zwei Zählungen: *namentlich* standen
**sechs** der neun da (`spawned_role`, `input_tokens`, `total_tokens`, `total_duration_ms`,
`total_tool_use_count`, `model_version`), *gedeckt* waren **acht** — die zwei Cache-Zähler
fielen als Teilstring unter `"input_tokens"`. **Acht** ist also die Abdeckungs-, nicht die
Nennungs-Zahl. (Das Literal selbst trug zehn Argumente: die sechs Namen, `result_bytes` — das
**keiner** der neun ist — und drei Nicht-Feld-Proben.)

`output_tokens` war weder genannt noch gedeckt und stand repo-weit in keiner Negativ-Prüfung
(Review-Befund MEDIUM-1). **Gemessen, nicht geschlossen:** mit `json:"output_tokens"` statt
`json:"output_tokens,omitempty"` blieb `make test-go` bei **Exit 0** mit **null**
`--- FAIL:`-Zeilen, während jede geschriebene Zeile — auch ein reiner `Bash`-Span —
`"output_tokens":null` trug (beides in isolierter Kopie gefahren, die Span-Zeile aus dem
gebauten Emitter gelesen).

134 (`input_tokens`), 136 (`output_tokens`) und 137 (`spawned_role`) sind in der
Kipp-Richtung **gefahren**, nicht abgeleitet. Dass die übrigen sechs Einträge ungebunden sind,
ist aus der Bauart der Fälle **abgeleitet**, nicht einzeln gefahren.

### 6.5 Die `mustContain`-Gegenproben haben keinen Zahn (2026-07-30)

**Gemessen, nicht geschlossen:** macht man `mustContain` in der isolierten Kopie wirkungslos,
bleibt `make test-go` grün, und die Fälle 123 und 127 melden weiter „ok" — sie färben ihre
Wächter über die `mustNotContain`-Hälfte und merken vom Verlust der anderen nichts.

### 6.6 Fall 127, der tragende (2026-07-30)

Seine Grenz-Zusicherung ist eindeutig an ihn gebunden: mit entferntem
`mustNotContain`-Block meldet der Treiber ihn als **Befund** (*„rot, aber … fällt nicht —
falscher Grund"*), nicht als „ok" — bis zum 2026-07-30 blieb er dort „ok", weil die Gegenprobe
desselben Wächters `model_version` mitprüfte und die Senke des Falls genau dieses Feld ist
(Review-Befund MEDIUM-4).

### 6.7 Fall 128 und 129 rot gesehen (2026-07-30)

Beide sind am 2026-07-30 einzeln über den `run_case`-Pfad des Treibers gefahren und **rot
gesehen** (Grün-Vorlauf und -Nachlauf grün, Host-Baum unberührt); sie wiederholen die Messung
bei jedem `make mutate`. Damit haben die Normalisierung von `spawned_role` und die Schranke um
`model_version` erstmals einen **Dauer**-Sensor. (Der zuvor genannte Beleg, ein
*Implementations-Bericht vom 2026-07-30*, war ein Artefakt, das im Repo **nie existierte** —
Review-Befund MEDIUM-3.)

### 6.8 Die Draht-Form von `spawned_role`, zweiseitig gemessen (2026-07-31)

Isolierte Kopie, Grün-Vorlauf und -Nachlauf grün, alle `--- FAIL:`-Zeilen ausgezählt: mit
intakten Wächtern melden 137 und 138 „ok" und färben je **zwei** Wächter
(`response_test.go:207` und `:343`); streicht man `"spawned_role"` aus der Liste des **ersten**
Wächters, meldet **138 Befund** (*„rot, aber … faellt nicht — falscher Grund"* — es fällt nur
noch der Fehlschlag-Wächter), während **137 „ok"** meldet; streicht man ihn aus der Liste des
**Fehlschlag**-Wächters, kehrt es sich um (**137 Befund**, **138 „ok"**).

**Bis 2026-07-31 war der Eintrag im ersten Wächter von keinem Fall gebunden** — man konnte ihn
streichen, und `make gates` wie `make mutate` blieben still. **Das ist eine
Vollständigkeits-Aussage und darum ausgezählt statt behauptet:** kippen kann nur ein Fall,
dessen `# expect:`-Zeile genau diesen Wächter nennt; das sind über alle Fälle genau **vier** —
131, 132, 135 und der neue 138. Mit gestrichenem Eintrag melden 131, 132 und 135 weiter „ok"
(gemessen 2026-07-31, ein Lauf), weil sie an der Gegenprobe `"tool":"Agent"`, an der
Strukt-Prüfung bzw. an der Gattungszeile fallen — **nur 138** meldet Befund.

Vor dem 2026-07-30 hatte die Draht-Form **überhaupt** keinen Zahn — der Code-Kommentar an
`intoSpawnedRole` nannte dafür Fall 134, der `json:"input_tokens,omitempty"` mutiert und
`spawned_role` nirgends berührt (Review-Befund MEDIUM-2; gemessen: mit gestrichenem
`"spawned_role"` in der `mustNotContain`-Liste des Fehlschlag-Wächters meldet 134 weiter „ok").

**Fall 132 trägt sie nicht:** er bindet die *Herkunft* und nur im ersten der beiden Wächter —
der zweite führt `subagent_type: "nope"`, das zu leer normalisiert, und bleibt unter 132
absichtlich grün (gemessen 2026-07-31: 132 färbt **genau einen** Wächter, alle
`--- FAIL:`-Zeilen ausgezählt).

**Auch Fall 132 selbst ist zweiseitig gemessen** (2026-07-30, derselbe Pfad): mit intaktem
Wächter meldet er „ok" (`-> TestAgentGetsNoArgumentFields rot`, gefallen an der B1-Zeile — am
2026-07-31 `response_test.go:207` —, als einziger Wächter des ganzen Laufs); mit gestrichenen
B1-Zusicherungen meldet er **Befund** (*„make test-go blieb GRUEN — … hat keine Zaehne mehr"*),
**während 131 im selben Lauf weiter „ok" meldet**. Was er bindet, ist die **Eigenschaft** B1,
nicht der `mustNotContain`-Eintrag: streicht man nur diesen, fällt der Wächter weiter über die
Strukt-Prüfung und 132 meldet „ok" (gemessen 2026-07-31). Den Eintrag bindet 138.

### 6.9 Die Voraussetzung: Fall 130 und 131, zweiseitig gemessen (2026-07-30)

Einzeln über den `run_case`-Pfad des Treibers; Grün-Vorlauf und -Nachlauf grün,
Host-Fingerabdruck vor/nach gleich: mit intakten Wächtern melden sie „ok"; mit gestrichener
Listen-Zeile meldet 130 **Befund** (*„blieb GRUEN — … hat keine Zaehne mehr"*), mit gestrichener
Zeilen-Gegenprobe meldet 131 **Befund** (*„rot, aber … faellt nicht — falscher Grund"*).

Zuvor hingen beide Hälften an einer falschen Fundstelle: `TestMandatoryFieldsAlwaysPresent`
sollte sie *„mit dem Zahn `test/mutations/110-span-pflichtfeld-verschwindet.sh`"* bewachen. Fall
110 mutiert aber `tool_use_id` und Fall 111 `branch`; **kein** Fall berührte `tool`
(Review-Befund R2-MEDIUM-1 vom 2026-07-30). Gemessen statt geschlossen: streicht man `"tool":`
aus der Pflicht-Liste in `internal/span/span_test.go`, meldet 110 weiter „ok".

### 6.10 Die Zählung der Zähne, gewachsen statt korrigiert

Die **vierzehn** Zähne der **Erfassung** sind 123–129 und 132–138; die **zwei** Zähne ihrer
**Voraussetzung** sind 130 und 131 — zwei Zählungen über zwei Eigenschaften, keine Korrektur
der ersten. Die erste Zahl war bis 2026-07-30 **sieben**, wuchs mit den vier Fällen aus
Verifier-Befund V-1 auf **elf**, mit den zwei Fällen aus den Review-Befunden MEDIUM-1 und
MEDIUM-2 (136, 137) auf **dreizehn** und am 2026-07-31 mit 138 auf **vierzehn**.
