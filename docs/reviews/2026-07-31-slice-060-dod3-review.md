# Code-Review — slice-060 DoD (3) + der nachgelieferte Rest von DoD (1)

## Kopf-Metadaten

| Feld | Wert |
|---|---|
| **Rolle** | Reviewer (Modul 10), `.harness/skills/reviewer.md` v1.4.0 |
| **Datum** | 2026-07-31 |
| **Diff/Commit-Range** | `c53b845..HEAD` = `a4199c9` · `ae33b40` · `0738bc3` · `3533628` (+230/−80, drei Dateien, rein dokumentarisch) |
| **Slice-Plan** | [`docs/plan/planning/done/slice-060-rollen-achse.md`](../plan/planning/done/slice-060-rollen-achse.md) DoD (1) letzte Zeile + DoD (3) |
| **`LH-*`** | [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (Satz *„Der Tool-Build läuft reproduzierbar im gepinnten Image"*) — vom Diff nicht berührt |
| **Aktive ADRs** | [`ADR-0011`](../plan/adr/0011-telemetrie-erfassung-policy.md) (**Accepted**) Festlegung 1 Punkt 4/5, §Re-Evaluierungs-Trigger |
| **Hard Rules** | [`AGENTS.md`](../../AGENTS.md) §3.4 (ADR immutable), §3.6 (keine Zusage ohne rot gesehenes Gegenbeispiel) |
| **Vorherige Findings am gleichen Modul** | `2026-07-30-slice-060-dod2-adr-0011-architect.md` (B1–B5) · `2026-07-30-slice-060-dod2-review.md` · `…-runde-2.md` · `2026-07-30-slice-060-v1-review.md` · `…-runde-2.md` |
| **Gate-Lage des Prüfgegenstands** | `harness/conventions.md` liegt **außerhalb** von `comment-claims` (Prüfbereich = vier Pfad-Muster, keine Markdown-Datei); Klartext-Querverweise wie *„slice-068 DoD (2)"* sind keine Links und damit außerhalb von `d-check`. **Der ganze Diff liegt außerhalb jedes Gates, das Zuschreibungen prüft.** |

**Prüfmethode.** Jede im Diff neu behauptete Fundstelle wurde am Artefakt nachgelesen, jede
Zahl mit Wortgrenzen nachgezählt, jede Vollständigkeitsaussage („nur", „kein", „die einzige")
gegen den vom Text selbst deklarierten Prüfbereich gemessen. Kein `make mutate`-Vollauf
(Nutzer-Ausschluss); die Nicht-Notwendigkeit ist unter Negativbefunde N-10 gemessen.

---

## Findings

### MEDIUM-1 — Der Auflösungs-Trigger von Abweichung 6 zeigt auf einen DoD-Punkt, den derselbe Commit-Range entfernt hat

- **kategorie:** MEDIUM (Closure-Blocker)
- **quelle:** [`MR-018`](../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung); `.harness/baseline/v3.5.2/regelwerk/modul-07-carveouts.md:129` (*„jeder temporäre Carveout einen Folge-Slice mit ID, der das Auflösen plant. Slice schlägt Memo."*); [`ADR-0011`](../plan/adr/0011-telemetrie-erfassung-policy.md) Festlegung 1 Punkt 5
- **pfad:** `harness/conventions.md:1203-1204`
- **befund:** Die Zeile lautet *„**Auflösungs-Trigger:** eine Quelle **innerhalb des Repos**, die Haupt-Kontext-Token trägt — dieselbe Bedingung führt slice-068 DoD (2)."* Der spätere Commit desselben Range (`3533628`) hat slice-068 neu geschnitten: dessen DoD (2) trägt seit dem die **Berichtsgröße** (`docs/plan/planning/open/slice-068-rollen-arbeit-laeuft-als-rolle.md:55-70`), und der Slice protokolliert selbst, dass der frühere DoD (2) **entfallen** ist (`:78-86`). Gemessen über alle lebenden Plandateien (`open/`, `next/`, `in-progress/`, Welle, Roadmap): die Bedingung *„eine Quelle innerhalb des Repos, die Haupt-Kontext-Token trägt"* wird von **keinem** Slice mehr geführt — der einzige verbliebene Treffer ist die Entfallens-Notiz selbst.
- **verifizierbar:** nein — kein Gate-Lauf bestätigt ihn. `d-check` sieht die Stelle nicht (Klartext, kein Link; die einzige Link-Prüfung an slice-068 steht auf `conventions.md:1000` und ist korrekt), `comment-claims` deckt keine Markdown-Datei. Bestätigt ausschließlich durch Lesen der zwei Artefakte.
- **Failure-Szenario:** Wer Abweichung 6 auflösen will, folgt dem Trigger nach slice-068 DoD (2), findet dort die Berichtsgröße und hat zwei Auswege: den Trigger als verwaist fallenlassen — dann ist die Abweichung faktisch permanent, ohne die ADR, die Modul 7 für Permanenz verlangt (`modul-07-carveouts.md:73`) — oder den entfernten DoD-Punkt wieder einzusetzen und damit genau die *„zweite Wahrheit"* zu erzeugen, deren Vermeidung `3533628` als Grund für den Schnitt angibt. Die Selbstauskunft der Abweichung (*„Bleibt er auf absehbare Zeit aus, ist der Ort dieser Abweichung … eine ADR"*, `:1209-1210`) hängt an einem Beobachter, den der Text als *slice-068 DoD (2)* benennt und der nicht existiert.
- **Kategorisierung, offengelegt:** HIGH erwogen und verworfen. Der Präzedenzfall in derselben Familie — *„[`MR-018`] belegte den Rot-Nachweis dieser beiden Wächter mit einem Artefakt, das es nicht gab"* — wurde am 2026-07-30 als **MEDIUM-3** geführt; die Trigger-**Bedingung** selbst steht, nur ihr Slice-Anker ist falsch. MEDIUM blockiert nach Skill ohnehin.

### MEDIUM-2 — „Den Vordergrund herstellen kann **nur** etwas, das den Start verweigert" ist eine Vollständigkeitsaussage ohne Messung, und die Repo-Doku nennt einen zweiten Weg

- **kategorie:** MEDIUM
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 (*„Falsch: ‚Byte-Gleichheit belegt `make smoke`', ohne `smoke` gelesen zu haben"*)
- **pfad:** `harness/conventions.md:938-940`
- **befund:** Der Satz *„Den Vordergrund **herstellen** kann nur etwas, das den Start verweigert"* schließt den Lösungsraum auf Deny-Mechanismen. Die im Repo vendorierte Hooks-Referenz dokumentiert für **dasselbe Ereignis** einen nicht-verweigernden Weg: `docs/user/claude-hooks-referenz.md:894` — *„`PreToolUse`: `updatedInput` direkt unter `hookSpecificOutput` ersetzt die Argumente eines Tools, bevor es ausgeführt wird"* — und `:1617` — *„Ändert die Tool-Eingabeparameter vor der Ausführung … Kombinieren Sie mit `\"allow\"`, um automatisch zu genehmigen"*. Ob das Agenten-Werkzeug ein umgeschriebenes `run_in_background` befolgt, ist **nicht gemessen** — und genau das ist der Punkt: das „nur" ist in keine Richtung belegt.
- **verifizierbar:** nein — kein Gate prüft Prosa-Vollständigkeitsaussagen in `conventions.md`.
- **Failure-Szenario:** slice-060 §4 führt die Rückführungskante `in-progress → open` *„falls die Vordergrund-Bedingung den Betrieb spürbar behindert. Dann ist erst zu entscheiden, ob die Telemetrie diesen Preis wert ist"*, und §6 benennt den Preis (*„kostet Parallelität"*). Wer an dieser Entscheidung steht und `MR-018:938` liest, sieht genau zwei Optionen — verweigern oder aufgeben — und prüft den dritten, repo-lokal dokumentierten Mechanismus nie. **Dieselbe Klasse ist im selben Slice bereits protokolliert** (`slice-060-rollen-achse.md:267-271`): *„Eine frühere Fassung dieses Punktes behauptete, die Bedingung habe keinen Sensor — eine Vollständigkeitsaussage, für die ich nie nachgesehen habe. Alle drei Teile lagen im Repo bereit."* Eine Generation später, dieselbe Datei, dasselbe Hook-Ereignis.

### MEDIUM-3 — „die einzige Verdrahtungs-Prüfung an einer `settings.json`" ist als Messung deklariert und übersieht zwei Artefakte im selbst genannten Prüfbereich

- **kategorie:** MEDIUM
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6; Skill-Anker *„Spec-Treue-Lücke einer Messmethode"*
- **pfad:** `harness/conventions.md:1157-1163`
- **befund:** Der Text sagt: *„**kein Sensor dieses Repos prüft, dass er verdrahtet ist** — gemessen am 2026-07-31 über `test/**`, `Makefile`, `harness/tools/*.sh` und die Go-Tests: die einzige Verdrahtungs-Prüfung an einer `settings.json` steht in `harness/tools/smoke.sh`."* Nachgemessen über denselben deklarierten Umfang gibt es **drei**: `harness/tools/smoke.sh:85`, dazu `internal/emit/enforce_test.go:87` (`TestEnforce_SettingsWiresBothHooks`, prüft `"PreToolUse"`, `"matcher": "Bash"`, `pretooluse-command-guard.sh` in der emittierten `settings.json` — ein **Go-Test**, ausdrücklich im deklarierten Umfang) und sein Dauer-Sensor `test/mutations/32-enforce-settings-wires-guard.sh` (unter `test/**`, ebenfalls im deklarierten Umfang).
- **verifizierbar:** ja, teilweise — `make test` führt `TestEnforce_SettingsWiresBothHooks` aus; seine Existenz widerlegt das „einzige" unmittelbar. Kein Gate meldet die falsche Aufzählung als solche.
- **Failure-Szenario:** Die tragende Schlussfolgerung — kein Sensor prüft die **Dogfood**-Verdrahtung — hält (selbst nachgemessen: alle drei Prüfungen gelten dem emittierten Repo). Falsch ist die Aufzählung, und sie ist als Messung etikettiert. Wer sie als Bestandsaufnahme der vorhandenen Verdrahtungs-Sensoren liest — etwa um für den Dogfood-Guard einen analogen Zahn zu bauen —, übersieht das Vorbild, das es schon gibt, samt seiner Mutation.

### MEDIUM-4 — „Ihre `Agent`-Spans tragen … genau **einen**: `model_version`" / „die Positiv-Liste erfasst es **unbedingt**" — der Code erfasst bedingt, und kein Span belegt es

- **kategorie:** MEDIUM
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6; [`MR-018`](../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung) Positiv-Liste Festlegung 4
- **pfad:** `harness/conventions.md:1154-1156` und `docs/plan/planning/open/slice-068-rollen-arbeit-laeuft-als-rolle.md:65-67`
- **befund:** Beide Stellen behaupten die Erfassung von `model_version` im Hintergrund als unbedingt. `internal/span/response.go:129-131` führt den Wert durch `modelVersion()` (`:168-181`): Länge > 64 oder ein Zeichen außerhalb des geschlossenen Satzes ⇒ Rückgabe `""`, und `AgentResult.ModelVersion` trägt `omitempty` (`:34`) — das Feld **fehlt** dann. `MR-018:929-931` sagt zu genau dieser Schranke selbst: *„die Messung erfasste nur Schlüsselnamen und Wertlängen, nie Werte — die Gestalt eines echten `resolvedModel` ist **nicht** gemessen"*. Die zwei Aussagen stehen 220 Zeilen auseinander im selben Abschnitt und widersprechen sich. **Am Bestand gemessen** (`.harness/state/spans/`, `Agent`-Spans ab dem Landen der Positiv-Liste am 2026-07-30 07:35Z): **13 von 13** tragen `model_version` **und** `input_tokens` **und** `spawned_role` — es existiert **kein einziger** Hintergrund-`Agent`-Span, an dem die Aussage beobachtbar wäre.
- **verifizierbar:** ja — ein Span aus einem Hintergrund-Lauf eines Nicht-Rollen-Typs würde es entscheiden; heute gibt es keinen.
- **Failure-Szenario:** slice-068 DoD (2).2 baut auf diesem Satz die Definition der Abdeckungszahl. Wer ihn als Code-Eigenschaft liest, kann `model_version`-Anwesenheit als Nenner-Ersatz („hier lief ein Agent") verwenden. Greift die Schranke zu eng — der von `MR-018:931-934` selbst benannte Fehlermodus ist ein **fehlendes** Feld —, kollabiert der Nenner lautlos und die Abdeckungszahl meldet 100 %, während sie nichts misst.

### MEDIUM-5 — Die Nicht-Durchsetzbarkeit von Bedingung 1 ist aus Schlüssel**namen** abgeleitet, während zwei der Schlüssel Freitext sind, dessen **Werte** die zitierte Messung ausdrücklich nicht erfasst hat

- **kategorie:** MEDIUM
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6
- **pfad:** `harness/conventions.md:984-993`
- **befund:** Der Absatz ist im Register einer Messung geschrieben: *„Gemessen über vier echte Aufrufe … trägt `tool_input` die Schlüssel `subagent_type`, `prompt`, `description` und `run_in_background` … **Keiner** davon sagt, *wie* der Typ angefordert wurde … Ein Guard hat damit nichts, worauf er prüfen könnte — und **darum** prüft **kein Sensor dieses Repos** Bedingung 1. Die Abwesenheit folgt aus der Payload, nicht aus einer Trefferliste."* Für `subagent_type`, `run_in_background` und `model` trägt der Schluss (typisierte Felder). Für `prompt` und `description` trägt er nicht: das sind Freitext-Felder des Aufrufers (`docs/user/claude-hooks-referenz.md:1559-1560`), und die zitierte Messung sagt über ihren Inhalt nichts — `slice-060-rollen-achse.md:188` hält fest: *„erfasst wurden nur Feldnamen und Wertlängen, **nie Werte**"*. Ob eine @-Erwähnung sich im `prompt` niederschlägt, ist damit in **keine** Richtung gemessen. Der nachfolgende Satz *„ein per @-Erwähnung angeforderter Rollen-Typ und ein sprachlich delegierter kommen am Hook identisch an"* ist eine Aussage über **Werte** und ruht auf einer Erhebung, die keine Werte erfasst hat.
- **verifizierbar:** ja — eine Werte-Sonde auf `tool_input.prompt` bei einem @-erwähnten Aufruf entscheidet es; sie ist nicht gefahren.
- **Failure-Szenario:** Derselbe Text, der die Möglichkeit ausschließt, führt zwölf Zeilen später den Guard vor, dessen Vorgänger-Fassung genau so ausgeschlossen worden war. Wer künftig einen Sensor für Bedingung 1 erwägt, liest hier ein „strukturell unmöglich", wo „nicht nachgesehen" richtig wäre, und die Bedingung bleibt dauerhaft ohne Sensor — mit dem vom Text selbst beschriebenen Ausgang: der Lauf fällt in den Sammelposten.

### LOW-1 — „Wer nur Bedingung 1 einhält, bekommt die Rolle und keine Zahl" gilt für Rollen-Typen nicht mehr

- **kategorie:** LOW
- **quelle:** [`MR-018`](../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung) (Selbstwiderspruch innerhalb des Abschnitts)
- **pfad:** `harness/conventions.md:971`
- **befund:** Fünf Zeilen später steht *„Bedingung 2 ist für Rollen-Typen **erzwungen**. Der `PreToolUse`-Guard … verweigert den Start"* (`:976-978`), und `MR-018:1021-1023` hält fest: *„ein vom PreToolUse-Guard **geblockter** Aufruf hinterlässt keinen Span"*. Für einen Rollen-Typ liefert „nur Bedingung 1" also **weder** Rolle **noch** Zahl — der Lauf findet nicht statt. Der Satz beschreibt den Zustand vor dem Guard (die Messung vom 2026-07-29) im Präsens einer allgemeinen Regel.
- **verifizierbar:** ja — der gemessene Deny-Lauf (slice-060 §3 Zeile 9) plus die Abwesenheit eines Spans dazu.
- **Failure-Szenario:** Eine Auswertung erwartet für verletzte Vordergrund-Bedingung einen rollen-etikettierten, zählerlosen Span und rechnet ihn in den Sammelposten; real fehlt der Span ganz, und die Lücke ist eine Fehlstelle in `seq`, kein Sammelposten-Eintrag.

### LOW-2 — Zwei „gemessene" Paarungen derselben 4.184-ms-Laufzeit mit verschiedenen Payload-Dauern, 97 Zeilen auseinander

- **kategorie:** LOW
- **quelle:** [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (Reproduzierbarkeit einer Messangabe)
- **pfad:** `harness/conventions.md:872` gegen `harness/conventions.md:969`
- **befund:** `:872` (Incident-Zeile für `total_duration_ms`, **vor** diesem Diff entstanden, `4a9ed3c`): *„(gemessen 4 ms gegen 4.184 ms tatsächlicher Laufzeit)"*. `:969` (neu in diesem Diff): *„sein Span trug `duration_ms: 3` … bei 4.184 ms tatsächlicher Laufzeit"*. Beide Zahlen stammen aus `slice-060-rollen-achse.md` §3 — die `4 ms` aus **Zeile 6**, die `4.184 ms` aus **Zeile 3**. Es sind zwei verschiedene Beobachtungen: Zeile 6 stellt `duration_ms` gegen `totalDurationMs`, das nur ein Vordergrund-Lauf trägt; Zeile 3 misst den @-Erwähnungs-Lauf, der laut Zeile 2/3 im **Hintergrund** lief und damit **kein** `totalDurationMs` hat. `:872` fügt also die Payload-Dauer der einen und die Laufzeit der anderen Beobachtung zu **einer** Paarung zusammen — ausgerechnet in der Zeile, die `total_duration_ms` erklärt, mit der Laufzeit eines Aufrufs, der keines erzeugt hat.
- **verifizierbar:** nein.
- **Failure-Szenario:** Wer die Messung zur Re-Validierung des Hook-Oberflächen-Triggers wiederholt, bekommt eine dritte Zahl und kann nicht entscheiden, ob die Plattform sich geändert hat oder das Dokument zwei Aufrufe vermischt. Keine Entscheidung ruht heute darauf; deshalb LOW und nicht MEDIUM.
- **Zur bewussten Nicht-Glättung:** „treu spiegeln statt vereinheitlichen" war für `:969` **richtig** — die zwei Zahlen zu einer zu machen wäre die Fälschung gewesen. Unvollständig ist, dass `:872` unmarkiert blieb: nicht die Zahlen gehören angeglichen, sondern jede Paarung gehört ihrem Aufruf zugeordnet.

### LOW-3 — Eine geschlossene DoD-Beleg-Zeile in `done/` behauptet weiter „vier erklärte Abweichungen"

- **kategorie:** LOW
- **quelle:** Maintainability (Frozen-Doc-Drift; `harness/conventions.md:522-526` benennt die Klasse und entscheidet, sie *„bei Eintritt belegt"* zu behandeln)
- **pfad:** `docs/plan/planning/done/slice-059-telemetrie-erfassung-hook.md:95`
- **befund:** *„**Belegt:** [`MR-018`] (Feldtabelle, …, **vier erklärte Abweichungen**, …)"*. Zum Zeitpunkt der Closure (`01988bd`) war die Zahl richtig; seit `a4199c9` sind es sechs. Die Zeile ist als **Beleg-Zeiger** auf ein lebendes Dokument formuliert, nicht als datierter Schnappschuss, und trägt kein Datum.
- **verifizierbar:** nein — `d-check` prüft Links und Anker, keine Zahlen; kein Gate deckt es.
- **Failure-Szenario:** Ein Auditor der slice-059-Abnahme öffnet `MR-018`, zählt sechs und kann aus der Beleg-Zeile allein nicht entscheiden, ob slice-059 sechs lieferte und zwei später entfielen oder umgekehrt. **Gemildert, aber nicht aufgelöst:** `conventions.md:1027-1029` sagt es von der anderen Seite (*„vier standen hier seit slice-059, die zwei letzten kamen am 2026-07-31 dazu"*) — ein Hop, den der Leser von `done/` aus erst finden muss. Eine geschlossene Beleg-Zeile darf so stehenbleiben, **wenn** sie als datierter Stand erkennbar ist; als undatierter Zeiger auf ein wachsendes Dokument ist sie es nicht.

### LOW-4 — „dieselben drei Prüfschritte" beschreibt die Migration falsch

- **kategorie:** LOW
- **quelle:** Maintainability (Zuschreibung an ein existierendes Artefakt)
- **pfad:** `docs/plan/planning/open/slice-068-rollen-arbeit-laeuft-als-rolle.md:80-84`
- **befund:** Die Entfallens-Notiz sagt, Abweichung 6 trage *„dieselbe Reihenfolge (Prüfung → Abweichung → Trigger), **dieselben drei Prüfschritte**, derselbe Trigger-Wortlaut"*. Reihenfolge und Trigger-Wortlaut stimmen (nachgelesen gegen `git show c53b845:docs/plan/planning/open/slice-068-*.md`). Die drei Prüfschritte sind **nicht** dieselben: der frühere DoD (2) führte (a) Zähler nur in `tool_response`, (b) Transkript ausgeschlossen, (c) `SubagentStart` trägt keine Token; `MR-018:1182-1195` führt (1) = (a), (2) **neu** (Ableitbarkeit aus `result_bytes`/`duration_ms`, mit ADR-0011 Festlegung 1 Punkt 4), (3) = (b)+(c) zusammengefasst. Drei zu drei ist Zufall der Zählung.
- **verifizierbar:** nein.
- **Failure-Szenario:** Wer die Migration auf Vollständigkeit prüft, verlässt sich auf die Gleichheitsbehauptung statt zu vergleichen — und übersieht, dass ein Prüfschritt neu hinzugekommen ist (also **mehr** geliefert wurde, als die Notiz sagt) und zwei verschmolzen sind (also einer weniger einzeln nachvollziehbar ist).

### LOW-5 — „Auflösungs-Trigger, zwei, **beide beobachtbar**" — einer davon ist in der ADR ausdrücklich als sensorlos eingeordnet

- **kategorie:** LOW
- **quelle:** [`ADR-0011`](../plan/adr/0011-telemetrie-erfassung-policy.md) §Re-Evaluierungs-Trigger; [`AGENTS.md`](../../AGENTS.md) §3.6
- **pfad:** `harness/conventions.md:1168` (Klammer), gegen `docs/plan/adr/0011-telemetrie-erfassung-policy.md:349-353`
- **befund:** Trigger (2) wird selbst als *„der Hook-Oberflächen-Trigger aus [`ADR-0011`] §Re-Evaluierungs-Trigger"* ausgewiesen. Die ADR ordnet genau diesen ein: *„Die Quelle … ist **nicht gepinnt** und wird von **keinem Gate** geprüft; dieser Trigger lebt daher im *inferential-feedforward*-Quadranten und wirkt nur, wenn ihn jemand liest."* Trigger (1) ruht auf slice-066 DoD (1), und slice-066 liegt in `open/`. Die Kopfzeile „beide beobachtbar" nimmt beide Einschränkungen zurück.
- **verifizierbar:** nein.
- **Failure-Szenario:** Die Wellen-Closure bucht die Matrix-Zelle *Token-Attribution × Repo* nach der welle-09-Regel (`welle-09-modul-15-konformitaet.md:17-18`: *„entweder einen laufenden Sensor oder eine deklarierte Entscheidung mit Auflösungs-Trigger, und nichts dazwischen"*) als gedeckt, weil zwei „beobachtbare" Trigger dastehen — während einer nur wirkt, wenn ihn jemand liest, und der andere an einem ungeschnittenen Slice hängt. **Bemerkenswert im Kontrast:** Abweichung 6 leistet drei Absätze später genau die Ehrlichkeits-Prüfung, die Abweichung 5 auslässt (*„niemand kann diesen Trigger **herbeiführen**, er wird **beobachtet**"*, `:1206-1207`, korrekt gegen `modul-07-carveouts.md:30`/`:73`).

### INFO-1 — Die Sechser-Liste mischt zwei Abweichungen mit ausgewiesenem Trigger und vier ohne, und nichts markiert die Ungleichbehandlung

- **kategorie:** INFO
- **quelle:** dokumentationswürdige, aber undokumentierte Annahme
- **pfad:** `harness/conventions.md:1026-1029` (Listenkopf) gegen `:1030`, `:1064`, `:1121` (Abweichungen 1, 2, 4)
- **befund:** Abweichungen 5 und 6 tragen je einen ausgewiesenen **Auflösungs-Trigger**; 1, 2 und 4 tragen keinen (Abweichung 3 nennt immerhin einen Auflösungs**weg**, `:1081-1083`). Die Entscheidung, **keine** pauschale Kopfzeile zu schreiben, ist inhaltlich richtig — eine solche wäre falsch gewesen. Sichtbar ist die Asymmetrie im Artefakt trotzdem nicht: der Listenkopf erklärt nur das Wachstum von vier auf sechs, und der Eintrags-Trigger von `MR-018` (`:1509`) lautet *„permanent, solange Spans erfasst werden"* und bezieht sich auf die Feldtabelle, nicht auf die Abweichungen. Normativ verlangt wird ein Trigger je Abweichung weder von `ADR-0011` Festlegung 1 Punkt 5 (dort: *„begründet dokumentiert"*) noch vom Adaptions-Format; deshalb INFO und kein Befund höherer Stufe.
- **verifizierbar:** nein.
- **Failure-Szenario:** Bei der Wellen-Closure muss je Abweichung entschieden werden, ob sie „deklarierte Entscheidung mit Trigger" ist. Für 2 und 4 findet der Entscheider nichts und muss rekonstruieren, ob der Trigger fehlt oder die Abweichung als permanent gemeint ist.

---

## Negativbefunde (geprüft, ohne Befund)

- **N-1 — Arithmetik aller Zahlen im Diff.** Mit Wortgrenzen ausgezählt und je gegen die Quelle geprüft: `neun Werte aus sechs Schlüsseln` (`:890`) gegen `responseKeys()` in `internal/span/response.go:65-77` — neun Einträge, sechs Top-Level-Schlüssel (`usage`, `totalTokens`, `totalDurationMs`, `totalToolUseCount`, `agentType`, `resolvedModel`); `Sechs erklärte Abweichungen` (`:1026`) gegen die Listenpunkte 1–6; `vier + zwei = sechs` (`:1027-1028`); acht Schlüssel der Hintergrund-Antwort (`:1134-1136`) gegen slice-060 §3 Zeile 2, identisch; `4 usage + 3 total* + 1 agentType = acht` (`:1156-1157`); `vier `usage`-Zähler und die drei `total*`-Werte` (`:1182-1183`); `fünf undokumentierte Schlüssel in vier gemessenen Aufrufen` (`:1208-1209`) gegen slice-060 §6. **Keine Zahl im Diff ist falsch.**
- **N-2 — Die Selbstkorrektur `ae33b40` („acht der neun, nicht neun").** Nachgezählt: `resolvedModel` steht laut slice-060 §3 Zeile 2 in der Hintergrund-Antwort, `responseKeys()` liest es, damit fehlen `usage`×4 + `total*`×3 + `agentType` = **acht**. Die Korrektur ist rechnerisch richtig. (Ihre Unbedingtheit ist MEDIUM-4 — die Zahl selbst nicht.)
- **N-3 — Die zwei repo-lokalen Fundstellen für Bedingung 2.** `docs/user/claude-hooks-referenz.md:1567` trägt *„Ab v2.1.198 werden Subagenten standardmäßig im Hintergrund ausgeführt, daher erzeugt ein weggelassenes `run_in_background` auch `\"async_launched\"`"*; `:1576` trägt *„Für Hintergrund-Subagenten … trägt `tool_response` keine Nutzungsfelder. Es hat stattdessen `status: \"async_launched\"`, `agentId`, `description`, `prompt`, `outputFile` und `resolvedModel`."* Beide Sätze decken exakt, was `conventions.md:960-964` ihnen zuschreibt — Standard **und** die sechs Felder, in derselben Reihenfolge.
- **N-4 — Die *negative* Zitat-Behauptung zu Bedingung 1.** *„Die vendored Hooks-Referenz … verweist in ihrem `Agent`-Eintrag **nur** auf diese Seite und trägt den Satz nicht"* (`:953-955`): `claude-hooks-referenz.md:1554` lautet vollständig *„Spawnt einen `[Subagenten](/docs/de/sub-agents)`."* Repo-weit über alle Markdown-Dateien gemessen kommt „Erwähnung" außerhalb von `docs/reviews/`, `slice-060`, `slice-068` und `conventions.md` selbst **null**-mal vor; in `docs/user/` (drei Dateien) null. *„Wer ihn nachprüfen will, findet im Repo nichts, woran"* ist damit gemessen richtig — und die Etikettierung als **fremde Zusage** ist die korrekte Belegklasse.
- **N-5 — Die Trennung der zwei Belegklassen ist im Text durchgehalten.** Bedingung 1 trägt durchgehend „fremde Doku, im Repo NICHT vorliegend"; Bedingung 2 trägt „gemessen + repo-lokal dokumentiert". Der Satz *„Zwei unabhängige Belege für dieselbe Bedingung — und der **einzige** Punkt dieser Konvention, für den das gilt"* (`:964-965`) trifft zu: für Bedingung 1 gibt es genau einen Beleg, und er ist als fremd markiert. Die Vermischung, die in dieser Familie schon HIGH war, ist **nicht** eingetreten. Auch die feine Stelle stimmt: der Text behauptet **nicht**, `run_in_background` sei für `Agent` dokumentiert (es ist es nicht — das Eingabe-Schema `:1558-1563` führt nur `prompt`, `description`, `subagent_type`, `model`), sondern nur, dass die **Folge** dokumentiert sei.
- **N-6 — `tool_input`-Schlüsselliste und „darüber hinaus nur `model`".** `conventions.md:986-989` gegen slice-060 §3 Zeile 5 (`subagent_type`, `prompt`, `description`, `run_in_background`) und gegen `claude-hooks-referenz.md:1558-1563`: die Differenzmenge des dokumentierten Schemas ist tatsächlich genau `{model}`. Korrekt.
- **N-7 — Die in Abweichung 5.2 genannten Sensoren existieren.** `test/agent-guard.bats`, `test/mutations/117-agentguard-rollenpruefung-entfernt.sh`, `…/118-agentguard-namensliste-statt-ableitung.sh`, `…/119-agentguard-schalter-failopen.sh` — alle vier vorhanden. Der Guard selbst (`.claude/hooks/pretooluse-agent-guard.sh`) verhält sich wie beschrieben: Rollen-Liste aus der Existenz von `.claude/agents/<name>.md` **abgeleitet** (`:76`), fehlender Schalter = Hintergrund (`:80-84`), Ausgabe über `hookSpecificOutput.permissionDecision` (`:47-56`). Sechs Rollen-Dateien vorhanden, Frontmatter mit `name`/`description`/`tools`/`model`. In `.claude/settings.json` ist er unter `"matcher": "Agent"` verdrahtet.
- **N-8 — Die Zuschreibung an slice-066 DoD (1).** `conventions.md:1168-1172` (*„Abdeckungszahl … mit einem Nenner aus `SubagentStart` statt aus denselben Spans"*) deckt sich inhaltlich mit `slice-066-telemetrie-auswertung.md:55-66` (*„Der Nenner kommt aus einer anderen Quelle als der Zähler … Das Ereignis **`SubagentStart`** feuert je Spawn"*). Anders als MEDIUM-1 ist **dieser** Querverweis korrekt.
- **N-9 — Die drei ADR- und zwei Regelwerk-Zitate.** *„billiger zu schreiben als eine Lösung"* = `ADR-0011:97-98` ✓ · *„leer und als leer erkennbar"* = `:87` ✓ · §Re-Evaluierungs-Trigger existiert, `:348-354` ✓ · *„Modul 7 verlangt einen ernst erreichbaren Trigger"* = `modul-07-carveouts.md:30` (*„Auflösungs-Trigger als beobachtbare, messbare Bedingung"*) und die ADR-Konsequenz = `:73` (*„Trigger ist ehrlich nie zu erreichen — … Architekturentscheidung"*) ✓. Kein fabriziertes Zitat, keine kondensierte Wiedergabe.
- **N-10 — Die `make mutate`-Vertagung trägt.** Über **alle 134** Fälle in `test/mutations/` die `# files:`-Köpfe ausgewertet: kein Fall nennt `harness/conventions.md`, `slice-060-*.md`, `slice-068-*.md` oder `welle-09-*.md`; die einzige Markdown-Datei überhaupt in einem `# files:`-Kopf ist `internal/emit/templates/commands/implement-slice.md`. Kein Wächter-Quelltext ist im Diff berührt. Das Mutations-Ergebnis kann sich durch diesen Diff konstruktiv nicht ändern. (Die CI fährt `make mutate` beim Push ohnehin.)
- **N-11 — Die welle-09-Zeile ist mit dem Neuschnitt konsistent.** `welle-09-modul-15-konformitaet.md:139` sagt jetzt *„legt für die Matrix-Zelle … fest, dass sie ‚deklarierte Entscheidung mit Trigger' trägt. Die Haupt-Kontext-Abweichung selbst hat slice-060 DoD (3) geliefert"* — deckt sich mit slice-068 DoD (3) und mit dem Entfall des welle-09-Eintrags aus der Plan-Tabelle des Slice.
- **N-12 — Positiv-Liste Punkt 5 erzeugt keine zweite Wahrheit.** Der ersetzte Absatz (`:938-944`) verweist für die Regel auf die Start-Konvention und für die Restlücke auf Abweichung 5, statt beides zu wiederholen; die Abgrenzungs-Notiz `:998-1000` trennt *WIE* (hier) von *DASS* (slice-068 DoD (1)) und ist — anders als `:1204` — korrekt.
- **N-13 — Dogfood vs. emittiert.** Der Diff macht keine Aussage über die emittierte Ebene. slice-068 §6 verweist die Frage korrekt an slice-062. `MR-018:1160-1163` benennt ausdrücklich, dass die gefundene Verdrahtungs-Prüfung dem **emittierten** Repo gilt — die Ebenen-Trennung ist gezogen (dass die Aufzählung unvollständig ist, ist MEDIUM-3, nicht ein Ebenen-Fehler).
- **N-14 — Keine ADR angefasst.** `ADR-0011` ist im Diff unverändert; die Umdeutung „Auswerter (slice-060)" bleibt wie bisher in `conventions.md:1520-1526` und nicht in der ADR ([`AGENTS.md`](../../AGENTS.md) §3.4 gewahrt).
- **N-15 — Neue Links im Diff.** `../docs/plan/adr/0011-telemetrie-erfassung-policy.md`, `../AGENTS.md`, `../in-progress/slice-060-rollen-achse.md`, `slice-066-telemetrie-auswertung.md`, der `#mr-018--…`-Anker — alle Ziele existieren.

---

## Kategorie-Summary

| Kategorie | Anzahl | IDs |
|---|---|---|
| **HIGH** | **0** | — |
| **MEDIUM** | **5** | MEDIUM-1 (Closure-Blocker), MEDIUM-2, MEDIUM-3, MEDIUM-4, MEDIUM-5 |
| **LOW** | **5** | LOW-1, LOW-2, LOW-3, LOW-4, LOW-5 |
| **INFO** | **1** | INFO-1 |
| **Negativbefunde** | **15** | N-1 … N-15 |

**Steering-Loop-Signal (Skill §Kontext-Eskalation, „dritte Wiederholung derselben Klasse").**
MEDIUM-2, MEDIUM-3 und MEDIUM-5 sind **dieselbe** Klasse: eine Vollständigkeitsaussage
(„nur", „die einzige", „keiner davon") im Register einer Messung, deren Prüfbereich enger
war als der Satz. Drei Instanzen in einem 164-Zeilen-Diff. Die zwei dafür geschnittenen
Slices decken die Klasse **nicht**: slice-069 bindet Zahn↔Zusicherung in
`harness/tools/mutate.sh`, slice-070 weitet den **Prüfbereich** von `comment-claims` und
prüft weiterhin nur die *Existenz* des genannten Sensors, nicht die *Wahrheit* des Satzes —
`slice-070-comment-claims-pruefbereich.md:57-58` nennt `harness/conventions.md` selbst als
dauerhaft ungeprüft. Für Prosa-Vollständigkeitsaussagen in den Adaptionen gibt es weder
heute noch nach slice-069/070 einen Sensor.

---

## Verdikt

**NICHT KONFORM.**

Fünf MEDIUM blockieren nach Skill (*„HIGH und MEDIUM blockieren typischerweise"*). Der Diff
ist inhaltlich der beste der Familie — die Arithmetik stimmt durchgehend (N-1/N-2), die
Belegklassen-Trennung, an der diese Familie schon einmal gescheitert ist, hält (N-5), und
die zwei Abweichungen halten die von `ADR-0011` Festlegung 1 Punkt 5 verlangte Reihenfolge
*Prüfung → Abweichung → Trigger*. Er scheitert an einer anderen Achse: an drei
Vollständigkeitsaussagen ohne Messung (MEDIUM-2/3/5), einer Code-Zuschreibung, die der Code
nicht hält (MEDIUM-4), und einem Querverweis, den der letzte Commit des Range selbst
zerbrochen hat (MEDIUM-1).
