# Code-Review: slice-060 DoD (2) — `Agent` namentlich gelistet, Positiv-Liste über `tool_response`

**Rolle:** Reviewer (Modul 10, `.harness/skills/reviewer.md` v1.4.0). **Datum:** 2026-07-30.
**Autor:** ai-harness-init-Team (pt9912).

## Kopf-Metadaten (die fünf Pflicht-Punkte + Slice-Plan)

| Punkt | Inhalt |
|---|---|
| **Diff / Commit-Range** | `ff1f1a1..4ae9c98` — `4a9ed3c` (Inhalt) + `4ae9c98` (zwei zurückgenommene Zusagen in `MR-018`). 11 Dateien, +797/−12 |
| **`LH-*`-Anforderungen** | [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (der **Tool-Build**-Satz, nicht der Ziel-Repo-Satz), berührt: [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) |
| **Referenzierte aktive ADRs** | [`ADR-0011`](../plan/adr/0011-telemetrie-erfassung-policy.md) (**Accepted**, immutabel), [`ADR-0003`](../plan/adr/0003-go-native-binaries.md), [`ADR-0004`](../plan/adr/0004-durchsetzungs-emission.md) |
| **Hard Rules** | [`AGENTS.md`](../../AGENTS.md) §3.1 · §3.2 · §3.4 · §3.5 · §3.6 |
| **Vorherige Findings am gleichen Modul** | `docs/reviews/2026-07-29-slice-059-go-emitter-review.md`, `…-runde-2/-runde-3`, `docs/reviews/2026-07-29-slice-060-066-plan-review*.md` (4 Runden), `docs/reviews/2026-07-30-slice-060-dod2-adr-0011-architect.md` §6 (B1–B5) und §7 (Z1–Z5) |
| **Slice-Plan** (Repo-Ergänzung) | `docs/plan/planning/in-progress/slice-060-rollen-achse.md` DoD (2), §3-Änderungstabelle, §6 |

**Nicht Gegenstand dieses Reviews:** die DoD-Abhakung und die Bestätigung von Gate-Läufen
(Modul 11, getrennter Kontext). Wo ich Sensoren gefahren habe, steht die echte Ausgabe im
Befund.

**Gefahrene Sensoren.** `make comment-claims` → `comment-claims: 38 Datei(en) geprueft, 0
Befund(e)`, Exit 0. Lesende Messungen am realen Span-Bestand (`.harness/state/spans/`,
gitignored, nur `grep`/`sed`). `make gates` und `make mutate` habe ich **nicht** erneut
gefahren — die Aufgabenstellung stellt sie als grün bereit, und ihre Bestätigung ist
Verifier-Arbeit.

---

## Findings

### HIGH-1 — `make comment-claims` ist strukturell blind für untrackte Dateien, während der Gate-Stempel sie mitdeckt

- **kategorie:** HIGH
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 (*„benennen, was wirklich deckt — oder dass
  nichts deckt"*) · [`MR-003`](../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung) ·
  Reviewer-Skill HIGH-Anker *„Stilles-Grün-Pfad in einem Gate oder Gate-Skript"*
- **pfad:** `Makefile:135` gegen `harness/tools/working-tree-hash.sh:14`
- **befund:** Der Prüfbereich von `comment-claims` entsteht aus `git ls-files …` — **ohne**
  `--others`, also nur aus dem Index; der Nachweis-Hash, an dem der Stop-Hook die
  Gate-Deckung festmacht, listet dagegen `git ls-files -z --cached --others
  --exclude-standard`. Eine neu angelegte, noch untrackte Datei liegt damit **innerhalb** des
  bestätigten Baum-Zustands und **außerhalb** des Prüfbereichs, und das Gate schließt mit
  einer Vollständigkeits-Zeile („N Datei(en) geprueft, 0 Befund(e)"). In diesem Slice traf es
  `internal/span/response.go` (218 Zeilen, zehn Kommentar-Blöcke mit Sensor-Nennungen): der
  Abschluss-Lauf meldete `37 Datei(en)` (so auch protokolliert in
  `docs/reviews/2026-07-30-slice-060-dod2-adr-0011-architect.md:398`), mein Lauf nach dem
  Commit meldet `38 Datei(en)` — die Differenz ist genau diese Datei.
- **failure-szenario:** Ein Implementer legt eine neue Datei mit einem Kommentar an, der eine
  Abdeckung behauptet und einen **erfundenen** Testnamen nennt. `make gates` läuft grün, der
  Stop-Hook lässt den Abschluss durch (sein Hash deckt die Datei), die Prüfung (b) des Skripts
  — die genau gegen erfundene Sensor-Namen gebaut wurde — sieht die Datei nie. Der Befund
  entsteht erst beim **nächsten** Lauf nach dem Commit, also nachdem die Zusage schon als
  gate-gedeckt gemeldet wurde. Die Reichweite ist jede künftige neue Datei unter
  `internal/**/*.go`, `cmd/**/*.go`, `harness/tools/*.sh`, `.claude/hooks/*.sh`.
- **verifizierbar:** ja. `git stash -u` einer neuen `internal/x/y.go` mit einem
  `// bewacht von TestGibtEsNicht`-Kommentar (untrackt) → `make comment-claims` grün; nach
  `git add` → rot. Gegenprobe schon gefahren: `37 → 38 Datei(en)` allein durch das Committen
  von `response.go`.
- **Ebenen-Zuordnung (Dogfood vs. emittiert):** Dies ist ein **Dogfood**-Befund.
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) ist
  ausweislich seines Wortlauts (*„Jeder **emittierte** Gate-Target…"*) **nicht** der Anker;
  ihn hier zu zitieren wäre genau die Ebenen-Verwechslung, die dieses Repo mehrfach
  korrigiert hat.
- **Zuschnitt:** Der **Mechanismus** gehört in einen eigenen Slice — er betrifft alle
  künftigen Änderungen, nicht die Telemetrie, und ein Gate-*Anheben* ist nach
  [`MR-001`](../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
  ein Steering-Loop, kein ADR (§3.5 gilt für Senkungen). Was **hier** hineingehört, ist die
  **Einschränkung der Zusage**: die Gate-Ausgabe „37 · 0 Befund(e)" deckt `response.go` nicht,
  und das ist zu schreiben, statt es stehen zu lassen.

### MEDIUM-1 — `MR-018` sagt an zwei Stellen Gegenteiliges über den Cache-Status, und der Widerspruch entsteht in diesem Diff

- **kategorie:** MEDIUM
- **quelle:** [`ADR-0011`](../plan/adr/0011-telemetrie-erfassung-policy.md) Festlegung 1
  Punkt 5 + Folgepflicht 2 · [`MR-018`](../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
- **pfad:** `harness/conventions.md:870` gegen `harness/conventions.md:968` und `:981`
- **befund:** Die neue Feldtabellen-Zeile führt `cache_creation_input_tokens` /
  `cache_read_input_tokens` als **erfasst** und verweist zur Erklärung auf „Abweichung 1
  unten". Abweichung 1 trägt weiterhin die Überschrift *„Cache-Status ist **nicht** erfasst —
  und auch nicht auflösbar"* und den Satz *„**Erfasst wird er dadurch noch nicht:** … erfasst
  ist er erst, wenn diese Feldtabelle die Cache-Zähler führt"* — eine Bedingung, die derselbe
  Commit erfüllt hat. Nur der Schluss-Satz der Abweichung (*„Nicht erreichbar bleibt er für
  den Haupt-Kontext und für Hintergrund-Läufe"*) beschreibt noch den Rest-Zustand. Der
  Architect hatte die Prämisse als überholt benannt
  (`docs/reviews/2026-07-30-slice-060-dod2-adr-0011-architect.md:205-212`); nachgezogen wurde
  die Feldtabelle, nicht das Abweichungs-Register.
- **failure-szenario:** slice-066 liest das Abweichungs-Register, um zu entscheiden, welche
  Modul-15-Pflichtgrößen unerreichbar sind, findet „Cache-Status ist nicht erfasst — und auch
  nicht auflösbar" und lässt die Cache-Hit-Rate aus
  (`.harness/baseline/v3.5.2/regelwerk/modul-15-observability.md` §Cache-Counter-Regeln) —
  während `cache_read_input_tokens: 217418` in jedem Vordergrund-`Agent`-Span steht. Die
  Auswertung erklärt eine Größe als unerreichbar, die sie selbst mitliest.
- **verifizierbar:** nein (kein Gate prüft die Wahrheit von Prosa; `docs-check` prüft nur
  Links/Anker/IDs/Codepaths). Prüfbar durch Lesen der beiden Stellen im selben Dokument.

### MEDIUM-2 — `spawned_role` beruft sich auf die `agent_role`-Lesevorschrift, verhält sich aber gegenteilig: leer heißt hier **abwesend**

- **kategorie:** MEDIUM
- **quelle:** [`MR-018`](../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
  (Feldtabelle, Lesevorschrift) · Review-Befund HIGH-2 aus slice-059, der die
  Present-and-empty-Regel gesetzt hat
- **pfad:** `harness/conventions.md:868` gegen `internal/span/response.go:26` und
  `internal/span/response_test.go:189`
- **befund:** Die Feldtabelle sagt zu `spawned_role`: *„Leer heißt unbekannt — dieselbe
  Lesevorschrift wie bei `agent_role`"*. `agent_role` ist **Pflicht** ohne `omitempty`
  (`internal/span/emit.go:51`) und steht deshalb als `"agent_role":""` in jeder Zeile — genau
  das war die Setzung (*„sonst kann ein Auswerter ‚unbekannt' nicht von ‚nicht vorhanden'
  unterscheiden"*, `harness/conventions.md:1000-1005`). `spawned_role` trägt
  `json:"spawned_role,omitempty"` und verschwindet bei leerem Wert vollständig; der eigene
  Wächter belegt es: `response_test.go:189` prüft `mustNotContain(t, line, "spawned_role", …)`.
  Die zitierte Lesevorschrift ist damit auf ein Feld übertragen, dessen Draht-Form ihre
  Voraussetzung nicht erfüllt.
- **failure-szenario:** Ein `Agent`-Aufruf im Vordergrund läuft als `general-purpose` (der
  Normalfall, solange DoD (1) aussteht): der Span trägt alle vier Zähler und **kein**
  `spawned_role`. Ein Auswerter, der der Lesevorschrift folgt und nach `spawned_role: ""`
  sucht, findet nichts und zählt den Lauf nicht in den Sammelposten — der Verbrauch fällt aus
  der Rollen-Bilanz heraus, statt als *unbekannt* dazustehen. Genau die Lücke, die die
  Present-and-empty-Regel für `agent_role` geschlossen hat.
- **verifizierbar:** ja. Eine Payload mit `tool_name: "Agent"`,
  `tool_response.agentType: "general-purpose"` und gefülltem `usage` durch den Emitter
  schicken und die geschriebene Zeile auf `spawned_role` prüfen — der bestehende Wächter
  `TestSpawnedRoleIsNormalised` prüft nur das Struct-Feld, nicht die Zeile.

### MEDIUM-3 — Der einzige §3.6-Beleg für zwei der sieben neuen Wächter zeigt auf ein Artefakt, das es nicht gibt

- **kategorie:** MEDIUM
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 ·
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
- **pfad:** `harness/conventions.md:1107-1111`
- **befund:** `MR-018` §Bewacht schreibt: *„die Normalisierung von `spawned_role` und die
  Schranke um `model_version` sind je einmal rot gesehen worden (**Implementations-Bericht vom
  2026-07-30**)"*. Ein solches Artefakt existiert im Repo nicht — `grep -rn
  "Implementations-Bericht" .` liefert genau diese eine Zeile, und `docs/reviews/` enthält für
  slice-060 nur das Architect-Artefakt. Die Selbstauskunft über die Lücke ist damit
  eingelöst (die zwei Wächter **sind** als unbewacht benannt), der Beleg dafür, dass sie
  überhaupt einmal rot waren, ist es nicht. Die Begründung *„Plan-Vorgabe war fünf Zähne"*
  trägt für den **Mutations**-Fall (der Plan verlangt vier namentliche plus den Grenz-Zahn,
  `slice-060-rollen-achse.md:146-152`), **nicht** für den Rot-Nachweis: §3.6 verlangt ihn für
  *jede* Zusage, und B5 des Architect-Verdikts formuliert sein Gegenbeispiel ausdrücklich als
  eines, das *rot werden muss*.
- **failure-szenario:** Der Verifier will B5 bestätigen und sucht den Rot-Beleg an der
  einzigen Stelle, die ihn nennt; die Fundstelle löst nicht auf. Er kann dann nur
  nachvollziehen, dass ein grüner Test existiert — und genau diese Verwechslung („ein grüner
  Test belegt, dass ein Wächter greift") ist die Klasse, gegen die §3.6 steht.
- **verifizierbar:** ja. `grep -rn "Implementations-Bericht" .` und `ls docs/reviews/` — beide
  gefahren, Ergebnis oben.

### MEDIUM-4 — Fall 127 wird **innerhalb** seines benannten Wächters aus zwei unabhängigen Gründen rot; die Grenz-Zusicherung ist dadurch nicht bewacht

- **kategorie:** MEDIUM
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 · `harness/tools/mutate.sh:38-51`
  (Bedingung 4: *„Rot aus dem falschen Grund ist kein Beleg"*) ·
  Architect-Grenze B3
- **pfad:** `test/mutations/127-span-positivliste-negiert.sh:28-35` gegen
  `internal/span/response_test.go:125-132`
- **befund:** Der Fall-Kopf legt offen, dass **drei** Tests rot werden, und ordnet die zwei
  Mitläufer korrekt als Senken-Folge ein. Nicht offengelegt — und das ist der Teil, der
  Bedingung 4 betrifft — ist die Überdetermination **im benannten Wächter selbst**: weil die
  Senke `model_version` ist, bricht in `TestUnlistedResponseKeyStaysOut` nicht nur der
  `mustNotContain`-Kanarienvogel (`response_test.go:125-129`), sondern auch die Gegenprobe
  `mustContain(…, "model_version":"claude-opus-5[1m]")` (`:130-132`), weil die Senke den Wert
  verlängert und die schließende Anführung verschiebt. Streicht jemand den
  `mustNotContain`-Block — die Zusicherung, die B3 und damit das ADR-Verdikt trägt —, bleibt
  Fall 127 rot, Bedingung 4 findet den erwarteten Namen weiter in der `--- FAIL:`-Zeile, und
  `make mutate` meldet `127 -> TestUnlistedResponseKeyStaysOut rot`.
- **failure-szenario:** Die Grenz-Zusicherung wird entfernt oder aufgeweicht (etwa weil ein
  Kanarienvogel „stört"). `make mutate` bleibt ohne Befund und meldet den Grenz-Zahn als
  intakt, während die Eigenschaft, mit der §6 des Plans die Positiv-Liste begründet
  (*„sie hält auch beim fünften Freitext-Feld"*), unbewacht ist — dieselbe Fehlerform wie
  Befund F-1 des Mutations-Sensors, eine Ebene weiter innen.
- **verifizierbar:** ja. `response_test.go:125-129` entfernen und Fall 127 fahren: der Fall
  bleibt „ok" mit demselben erwarteten Wächter.

### LOW-1 — Die aufgehobene Zusage steht an einer vierten Stelle weiter, ausgerechnet im Wächter, den Fall 115 benennt

- **kategorie:** LOW
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 · Architect-Befund Z4
  (`…-architect.md:357-362`, der drei Stellen nennt)
- **pfad:** `internal/span/span_test.go:319`
- **befund:** Z4 zählte drei Fundstellen der Zusage *„vom Ergebnis darf nur die Länge in den
  Span"*; alle drei sind korrigiert (`internal/span/span.go:103-115`,
  `harness/conventions.md:1087`, `test/mutations/115-…:10-26`). Eine vierte blieb stehen:
  `internal/span/span_test.go:319` — *„Und der Kanarienvogel: vom Ergebnis darf NUR die
  Laenge in den Span."* — und zwar in `TestDurationAndResultSize`, dem Wächter, den Fall 115
  in seiner `# expect:`-Zeile benennt. Für das dort geprüfte `Bash` ist der Satz weiter wahr;
  als unqualifizierte Regel ist er es seit DoD (2) nicht. `make comment-claims` kann es nicht
  fangen: `Makefile:135` schließt `_test.go` per `grep -v '_test[.]go'` aus.
- **failure-szenario:** Wer den „einzigen Zahn dieser Fläche" liest, um die heutige Regel zu
  verstehen, liest die Fassung von vor DoD (2) und hält die Positiv-Liste für einen Verstoß —
  oder „repariert" sie in Richtung der alten Zusage.
- **verifizierbar:** nein (kein Gate deckt Kommentare in `_test.go`). Prüfbar per `grep -rn -i
  "nur die l[äa]enge" --include=*.go .`

### LOW-2 — Die §3-Änderungstabelle des Plans sagt `test/`-**bats**-Fälle zu; geliefert sind Go-Wächter in `internal/span/`

- **kategorie:** LOW
- **quelle:** Slice-Plan §3 · `MR-018` §Tooling-Klarstellung (`harness/conventions.md:1035-1041`)
- **pfad:** `docs/plan/planning/in-progress/slice-060-rollen-achse.md:207` gegen
  `internal/span/response_test.go`
- **befund:** Die Zeile lautet: *„`test/` | neu | die bats-Fälle zur Erfassung: dass die
  Positiv-Liste greift, dass `spawned_role` normalisiert, dass der Fehlerfall keinen halben
  Span erzeugt"*. Alle drei Eigenschaften sind gedeckt — als **Go**-Tests
  (`TestUnlistedResponseKeyStaysOut`, `TestSpawnedRoleIsNormalised`,
  `TestFailedAgentCallCapturesNothing`), nicht als bats unter `test/`. Neu unter `test/` ist
  ausschließlich `test/mutations/`. `MR-018` führt für genau diese Verwechslung schon eine
  Klarstellung (drei Fitness-Function-Zeilen sagen „bats", umgesetzt als Go unter demselben
  Target) — für die Zeile dieses Slice fehlt sie.
- **failure-szenario:** Der Verifier hakt die Änderungstabelle Zeile für Zeile ab, sucht neue
  bats-Fälle unter `test/`, findet keine und muss entscheiden, ob das eine Lücke oder eine
  Werkzeug-Verschiebung ist — ohne Artefakt, das die Frage beantwortet.
- **verifizierbar:** ja. `git diff --stat ff1f1a1..4ae9c98 -- test/` zeigt ausschließlich
  `test/mutations/`.

### LOW-3 — Die Gegenprobe zweier der sieben Wächter schließt eine „Erfassung von nichts" nicht aus, anders als der Datei-Kommentar es liest

- **kategorie:** LOW
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6
- **pfad:** `internal/span/response_test.go:48-50` gegen `:192` und `:302`
- **befund:** Der Helfer-Kommentar setzt: *„`mustContain` traegt die GEGENPROBE. Ohne sie
  bestuende **jeder** Waechter dieser Datei auch bei einer Erfassung von NICHTS"* — und die
  Commit-Message wiederholt es für alle sieben. Bei fünf Wächtern leistet die Gegenprobe genau
  das (`:97-102`, `:130-132`, `:165-167`, `:219-225`, `:249-252`). Bei zweien nicht:
  `TestAgentGetsNoArgumentFields` prüft `mustContain(t, line, "tool":"Agent", "status":"ok")`
  (`:192`) und `TestFailedAgentCallCapturesNothing` prüft `"tool":"Agent"`, `"status":"error"`,
  `"event":"PostToolUseFailure"` (`:302`). Beide Mengen sind unabhängig von der Erfassung —
  die zwei Wächter bleiben grün, wenn `extractAgentResult` **nichts** zurückgibt. Ihre
  Gegenprobe schließt „kein Span" aus, nicht „keine Erfassung".
- **failure-szenario:** Jemand ändert die Erfassung so, dass sie leer läuft (etwa der
  `classAgent`-Zweig in `span.go:118` fällt weg), und zieht sich zur Rückversicherung auf den
  Datei-Kommentar zurück: „jeder Wächter hier fällt bei einer Erfassung von nichts". Für zwei
  von sieben stimmt das nicht — sie sind reine Negativ-Wächter, und der Kommentar sagt es nicht.
- **verifizierbar:** ja. In `span.go:118` die `classAgent`-Bedingung entfernen und nur diese
  zwei Tests fahren — beide bleiben grün.

### LOW-4 — Fall 127 ist nicht die Mutation, die der Plan als Beleg der Form-Vorgabe benannt hat

- **kategorie:** LOW
- **quelle:** Slice-Plan DoD (2) §Form (`slice-060-rollen-achse.md:162-168`)
- **pfad:** `test/mutations/127-span-positivliste-negiert.sh:22-26,35`
- **befund:** Die Form-Vorgabe selbst ist **erfüllt**: die Auswahl steht als benannte Liste an
  einer Stelle (`internal/span/response.go:65-77`), über die die Erfassung iteriert
  (`:189-195`) — kein Struct-Feldliste-Ersatz. Ihre **Begründung** ist es nur halb: der Plan
  sagt, mit einer Liste sei „alles außer den vier" kein Wechsel der Datenstruktur, und
  formuliert die Mutation als *„einen Eintrag aus der Liste **entfernen** und stattdessen alles
  Nicht-Gelistete durchlassen"*. Fall 127 entfernt keinen Eintrag und lässt nichts frei
  durch; er hängt hinter die Erfassung eine Negativ-Liste, die alles in `model_version`
  konkateniert — weil der **Träger** `AgentResult` ein geschlossenes Struct geblieben ist. Der
  Fall-Kopf sagt es selbst: *„`model_version` ist der einzige String, in den sich ungelisteter
  Inhalt überhaupt schreiben lässt, ohne die Datenstruktur zu wechseln"*. Die Zusage
  „einzeilig mutierbar" hält für die vier namentlichen Zähne (je ein Listen-Eintrag), nicht
  für den Grenz-Zahn (ein `sed`, sieben eingefügte Zeilen, plus eine Senken-Wahl).
- **failure-szenario:** Ein späterer Slice nimmt ein Feld auf, das kein String ist, und will
  den Grenz-Zahn nachziehen; er findet keine Senke mehr, weil `model_version` inzwischen
  strenger ist oder wegfällt, und muss die Datenstruktur wechseln — genau der Aufwand, den die
  Form-Vorgabe ausschließen wollte. Ohne diesen Befund liest sich der Plan so, als sei das
  erledigt.
- **verifizierbar:** nein (Aussage über die Form, nicht über einen Lauf). Nachlesbar an
  `response.go:25-35` (geschlossenes Struct als Träger) plus dem Zugeständnis im Fall-Kopf.

### INFO-1 — Die Falsifizierbarkeits-Klausel von B5 ist am realen Bestand geprüft und **positiv**; die Abdeckung liegt heute bei 1 von 22

- **kategorie:** INFO
- **quelle:** [`MR-018`](../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
  Punkt 4 (*„am Bestand ablesbar: trägt kein `Agent`-Span mit Zählern ein `model_version`, ist
  die Schranke zu eng geraten"*) · Architect-Grenze B5
- **pfad:** `.harness/state/spans/*.jsonl` (gitignored), `harness/conventions.md:928-934`
- **befund:** Gemessen am 2026-07-30 (nur `grep`/`sed`, keine Schreibzugriffe): der Bestand
  führt **22** `Agent`-Spans (2026-07-29T09:14Z bis 2026-07-30T07:39Z). Genau **einer**
  (`seq 324`) trägt Zähler — die übrigen entstanden vor dem Code bzw. im Hintergrund. Dieser
  eine trägt `"model_version":"claude-opus-5[1m]"` und `"spawned_role":"implementer"`. Die
  Schranke ist also **nicht** zu eng geraten, und der Weg
  `tool_response.agentType` → `spawned_role` funktioniert am echten Lauf, nicht nur im Test.
  Dokumentationswürdig ist die zweite Zahl: die Abdeckung, die slice-060 §6 von slice-066
  verlangt (*„wie viele `Agent`-Spans überhaupt Zähler trugen"*), steht heute bei **1/22** —
  solange DoD (1) aussteht, ist das der Erwartungswert, nicht eine Anomalie.
- **failure-szenario:** entfällt (Bestätigung). Ohne die Zahl liest slice-066 eine
  Rollen-Bilanz aus einem Span und hält sie für eine Stichprobe.
- **verifizierbar:** ja, wiederholbar: `grep -c '"tool":"Agent"'` und `grep 'total_tokens'`
  über `.harness/state/spans/*.jsonl`.

### INFO-2 — Die Werkzeug-Achse sitzt nur in `Parse`; `Build` überträgt bedingungslos

- **kategorie:** INFO
- **quelle:** [`ADR-0011`](../plan/adr/0011-telemetrie-erfassung-policy.md) Festlegung 2
  (Achse = Werkzeug-Name) · Architect-Grenze B2
- **pfad:** `internal/span/span.go:118` gegen `internal/span/emit.go:114`
- **befund:** Die Bedingung `toolClass(p.Tool) == classAgent` steht ausschließlich in `Parse`;
  `Build` schreibt `AgentResult: p.Spawned` ohne erneute Prüfung. Heute ist das folgenlos:
  `Parse` ist der einzige Ort, an dem ein gefülltes `Payload` entsteht (gemessen: `Payload{`
  mit Feldern kommt nur an `span.go:81` vor). Der Fingerabdruck-Zweig daneben prüft die Klasse
  dagegen in `Build` selbst (`emit.go:135`) — die zwei Achsen-Prüfungen liegen also auf
  verschiedenen Ebenen.
- **failure-szenario:** Ein künftiger zweiter Erzeuger von `Payload` (Nachbearbeitung, Import
  eines Transkripts, ein Test-Helfer, der zum Produktionspfad wird) füllt `Spawned` und setzt
  `Tool` auf etwas anderes — `Build` überträgt es, und `TestOnlyAgentToolGetsResponseValues`
  fängt es nicht, weil er über `Parse` geht.
- **verifizierbar:** ja. `span.Build(span.Payload{Tool: "Bash", Spawned: …}, …)` erzeugt einen
  `Bash`-Span mit `spawned_role`.

### INFO-3 — `total_tokens` **ist** die Addition der vier Zähler; die Messung liegt seit diesem Slice im eigenen Bestand

- **kategorie:** INFO
- **quelle:** [`MR-018`](../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
  Feldtabelle · [`AGENTS.md`](../../AGENTS.md) §3.6
- **pfad:** `harness/conventions.md:871`, `.harness/state/spans/*.jsonl` (`seq 324`)
- **befund:** Die Zeile sagt seit `4ae9c98`: *„**Ob** sie die Addition der vier Zähler ist, ist
  **nicht gemessen**"*. Die Zurücknahme war als Aussage über den Wissensstand **richtig** (die
  Ist-Messung erfasste nur Schlüsselnamen und Wertlängen) — und die vorige Fassung („sie ist
  nicht deren Addition") war zusätzlich sachlich falsch. Der Slice erzeugt die Messung nun
  selbst: `seq 324` trägt `input_tokens 2` + `output_tokens 6040` +
  `cache_creation_input_tokens 427` + `cache_read_input_tokens 217418` = **223887** =
  `total_tokens`. Exakt, n = 1.
- **failure-szenario:** slice-066 addiert alle fünf Zahlen zu einer Rechnung und verdoppelt
  die Bilanz. Die Zeile warnt davor (*„eine Auswertung, die beides gegeneinander rechnet,
  prüft das zuerst"*) — die Prüfung ist damit erledigt und gehört notiert, statt ein zweites
  Mal gemacht zu werden.
- **verifizierbar:** ja, per Nachrechnen an derselben Zeile.

---

## Negativbefunde (geprüft, ohne Befund)

**Plan-Form (die eigentliche Prüffrage).**

- **Geprüft, ohne Befund: die Auswahl der erfassten Schlüssel ist wirklich eine benannte Liste
  an einer Stelle, über die iteriert wird — nicht die Feldliste eines geschlossenen Structs.**
  `responseKeys()` (`internal/span/response.go:65-77`) liefert neun `responseKey`-Einträge aus
  `path []string` + `take func`; `extractAgentResult` (`:181-197`) läuft `for _, k := range
  responseKeys()` und ruft `descend(obj, k.path)`. Es existiert **kein** Zweig, der einen
  Schlüssel außerhalb dieser Liste ansieht: `descend` (`:201-218`) folgt ausschließlich Pfaden
  **aus** der Liste, nie aus der Payload. Der Struct `AgentResult` ist der **Träger**, und das
  ist im Code ausdrücklich getrennt benannt (`:11-16`). Belegt, nicht nur gelesen: Fall 123
  fügt einen Eintrag mit **einem** `sed` hinzu (`123-…:25`) — die Einzeiligkeit für die vier
  namentlichen Zähne hält. Die Einschränkung an der Begründung steht als LOW-4.
- **Geprüft, ohne Befund: `Agent` ist nicht auf eine Gattungszeile gerutscht.** `toolClass`
  bekommt einen eigenen `classAgent`-Zweig (`span.go:193-194`); `Derive` (`:216-229`) hat für
  `classAgent` keinen Arm und fällt in `default: return Derived{}`; `fingerprint` bleibt an
  `classFileWrite` gebunden (`emit.go:135`). Der bestehende Zahn 108 (`sed` auf
  `^\t\treturn classNone$`) bleibt anwendbar — der Anker steht unverändert an `span.go:202`.

**Architect-Grenzen B1–B5.**

- **B1 geprüft, ohne Befund.** `ToolInput` führt weiterhin **genau drei** Felder
  (`span.go:66-70`: `file_path`, `notebook_path`, `command`) — kein `subagent_type`, kein
  `prompt`, kein `description`, kein `run_in_background`. `spawned_role` kommt allein aus
  `tool_response.agentType` (`response.go:74`, `:97-99`). Das von B1 verlangte Gegenbeispiel
  steht als Wächter: `TestAgentGetsNoArgumentFields` (`response_test.go:181-208`) fährt eine
  Payload mit `tool_input.subagent_type: "reviewer"` **ohne** `tool_response` und prüft
  `s.SpawnedRole == ""` plus die Abwesenheit von `spawned_role` in der Zeile.
- **B2 geprüft, ohne Befund.** Derselbe Wächter legt `command` und `file_path` zusätzlich ins
  `tool_input` und prüft `s.Path`, `s.Program`, `s.Argc`, `s.Bytes`, `s.Sha256Prefix` am
  **Struct** — mit der ausdrücklich richtigen Begründung, dass `bytes` ein Teilstring von
  `result_bytes` ist und eine Zeilen-Assertion hier nur zufällig grün wäre
  (`response_test.go:194-196`). Das ist die Art Präzision, die der Befund MEDIUM-6 aus
  slice-059 verlangt hat.
- **B3 geprüft, mit Einschränkung.** Die Liste ist eine Liste (s. o.), und der Grenz-Zahn
  existiert (`test/mutations/127`). Die Zusicherung, die er bewachen soll, ist jedoch nicht
  eindeutig an ihn gebunden → MEDIUM-4.
- **B4 geprüft, ohne Befund für die Vollständigkeit — nachgezählt, nicht übernommen.** Die
  Feldtabelle trägt **sieben** neue Zeilen (`conventions.md:868-874`) und darin **neun** Werte:
  `spawned_role` (1) · `input_tokens`+`output_tokens` (2) ·
  `cache_creation_input_tokens`+`cache_read_input_tokens` (2) · `total_tokens` (1) ·
  `total_duration_ms` (1) · `total_tool_use_count` (1) · `model_version` (1) = **9**. Das
  deckt sich 1:1 mit den neun Feldern von `AgentResult` (`response.go:26-34`) — kein Feld im
  Code ohne Zeile im Artefakt, keine Zeile ohne Feld. Die Werkzeug-Tabelle hat ihre
  `Agent`-Zeile im **selben** Commit (`conventions.md:890`), nicht danach. Zwei Zeilen bündeln
  je zwei Felder unter einer Incident-Frage — das entspricht der bestehenden Bauart derselben
  Tabelle (`program`, `argc`; `bytes`, `sha256_16`; `session`, `agent`) und ist kein Befund.
  Auch die drei Zahlen in `MR-018` Punkt 1 („sechs Schlüssel, neun Blatt-Werte, sieben
  Tabellenzeilen", `:904-906`) und in der `Agent`-Zeile („neun Werte aus sechs Schlüsseln")
  sind nachgezählt und stimmen; ebenso „fünf Zähne" (`:1097`, gezählt 123–127) und „vier
  erklärte Abweichungen" (`:966`, gezählt 4).
- **B5 geprüft, ohne Befund — und die Einschränkung, die der Implementer gemeldet hat, steht
  wirklich an beiden Orten.** Die Schranke ist implementiert (`response.go:138-151`):
  `len(s) > 64` → verworfen, und ein geschlossener Zeichensatz (`a-z`, `A-Z`, `0-9`, `.`, `_`,
  `-`, `[`, `]`) — alles andere → verworfen, **nicht** gekürzt. B5 ließ ausdrücklich
  „Zeichensatz-Normalisierung … **oder** Abgleich gegen ein geschlossenes Muster" zu; die
  gewählte Verwerfung ist die strengere der beiden und begründet (`:118-124`: 64 Byte eines
  Geheimnisses sind auch 64 Byte fremden Inhalts). Der **Nicht-Mess**-Vorbehalt zum
  Zeichensatz steht im Code (`:126-135`) **und** in `MR-018` (`conventions.md:928-934`), der
  **Fehlermodus** ist an beiden Stellen als *fehlendes* Feld benannt, und beide nennen die
  Falsifizierung am Bestand (dazu INFO-1). Das von B5 verlangte Gegenbeispiel ist als Wächter
  da: `TestResolvedModelIsStructurallyBounded` prüft „100 kB Prosa mit Geheimnis" und
  zusätzlich, dass **kein Präfix** des Geheimnisses im marshallten Span steht
  (`response_test.go:281-286`). Was fehlt, ist nur der Dauer-Sensor in `test/mutations/` — als
  Lücke benannt (MEDIUM-3 betrifft den Rot-Beleg, nicht die Benennung).
- **B0 geprüft, ohne Befund: es wird nichts emittiert.** `grep -rln "span"
  internal/emit/templates/` liefert **null** Treffer — der Emitter und die Positiv-Liste sind
  in keiner Vorlage. Damit trägt die Begründung, `make smoke` und `make full-smoke` nicht zu
  fahren: `smoke` emittiert die Doc-Gate-Baseline, `full-smoke` bootstrappt ein tmp-Repo und
  fährt dessen `make gates` — beide berühren `internal/span/` nicht. Die
  ebenen-abhängige Schärfe aus `ADR-0011` Festlegung 2 und Festlegung 5 (CR bei slice-062)
  ist unberührt. **Ebene ausdrücklich benannt:** alle Aussagen dieses Reviews gelten für den
  **Dogfood**.

**Hard Rules.**

- **§3.2 geprüft, ohne Befund.** `grep -rn "nolint\|shellcheck disable" internal/
  test/mutations/12*.sh test/mutations/115*.sh` → keine Treffer. Die Wahl `responseKeys()` als
  **Funktion** statt Paket-Variable ist die Konsequenz daraus und im Code begründet
  (`response.go:58-60`); `gochecknoglobals` ist in `.golangci.yml:27` real aktiv — die
  Begründung zeigt also auf eine existierende Regel, nicht auf eine behauptete.
- **§3.4 geprüft, ohne Befund.** `git diff --stat ff1f1a1..4ae9c98` berührt
  `docs/plan/adr/` **nicht**. Die ADR-Lage ist über `MR-018` bewegt, das `ADR-0011`
  Festlegung 1/Folgepflicht 1 ausdrücklich delegiert — kein Überschreiben, kein fehlendes
  Supersedes. Auch die Bezug-Zeile des Slice ist auf die Adaptions-Änderung umformuliert
  (`slice-060-rollen-achse.md:15-21`), womit der Architect-Befund Z2 eingelöst ist.
- **§3.5 geprüft, ohne Befund.** Keine Schwellen-Senkung: kein Gate wurde entfernt,
  gelockert oder aus `make gates` genommen; `test/mutations/115` ist umformuliert, nicht
  gelöscht, und die Fall-Zahl steigt von 122 auf 127.
- **§3.6, Gegenbeispiel-Seite geprüft: fünf der sieben Wächter tragen eine Gegenprobe, die
  eine Erfassung von nichts ausschließt** (`response_test.go:97-102`, `:130-132`, `:165-167`,
  `:219-225`, `:249-252`). Für die zwei Ausnahmen s. LOW-3.
- **§3.3 nicht anwendbar** — kein `git mv` im Range.

**`test/mutations/115`.**

- **Geprüft, ohne Befund: der Fall beißt weiter, und seine ADR-Fundstelle stimmt jetzt.** Der
  `sed`-Anker `^\t\trb := p.ResultBytes$` existiert unverändert (`emit.go:128`, zwei Tabs im
  `if p.HasResult`-Block); der benannte Wächter `TestDurationAndResultSize` prüft die
  Kanarienvögel `abc123`/`AWS_SECRET`/`noch mehr Ausgabe` gegen den marshallten Span
  (`span_test.go:320-328`) und wird von der Mutation über `s.Path` getroffen. Das Werkzeug ist
  `Bash`, also **kein** gelistetes — der Fall deckt damit weiter die Fläche, die für *jedes*
  Werkzeug gilt, und kollidiert nicht mit der neuen Positiv-Liste. Die Fundstelle ist auf
  `ADR-0011` **Festlegung 1 Punkt 3** plus *„kein Byte fremden Inhalts"* korrigiert
  (`115-…:22-26`) — genau die Korrektur, die Architect-Befund Z3 verlangt; die frühere
  Zuordnung zu Festlegung 2 (Argument-Achse) ist weg. Der Rest-Befund ist LOW-1
  (vierte Fundstelle).

**Die zwei zurückgenommenen Zusagen (`4ae9c98`).**

- **Geprüft, ohne Befund: beide Rücknahmen sind sachlich richtig und gehen in die richtige
  Richtung (Zusage verengen, nicht Lücke verschweigen).** `total_tokens` (`conventions.md:871`)
  behauptet nicht mehr, die Summe sei nicht die Addition — sie war zum Zeitpunkt der
  Ist-Messung tatsächlich nicht gemessen (die Messung erfasste nur Schlüsselnamen und
  Wertlängen). Punkt 5 (`:935-937`) sagt „dafür **u. a.**" statt einer Aufzählung, die als
  vollständig gelesen wurde — richtig, denn `slice-060-rollen-achse.md:185` (Messzeile 2)
  führt zusätzlich `resolvedModel`, `status`, `prompt`, `description`. Nachtrag als INFO-3.

**Mutations-Sensor-Mechanik.**

- **Geprüft, ohne Befund: die fünf neuen Fälle sind treiber-konform.** Je genau ein
  `# files:`- und ein `# expect:`-Kopf (kein Doppelkopf, der nach `mutate.sh:243-253` ein
  Befund wäre); `# expect:` nennt in allen fünf eine Go-Testfunktion, `narrow_sensor`
  (`mutate.sh:211-225`) wählt daraus `test-go`, `failure_form` liefert `--- FAIL:` — kein
  neuer `# verify:`-Modus, also kein neuer Grün-Vorlauf-Arm. Der `sed`-Anker `take:
  intoModelVersion},` kommt in `response.go` **genau einmal** vor (gezählt: 1), die vier Fälle
  123–126 greifen also eindeutig; 127 ankert auf `^\treturn res$` (`response.go:196`,
  ebenfalls eindeutig). `mutation_targets` nimmt `internal/span/response.go` neu auf, und
  `target_fingerprint` ist fail-closed gegen eine fehlende Zieldatei
  (`mutate.sh:118-123`) — kein Hash über der leeren Menge.
- **Geprüft, ohne Befund: die drei Rot-Färbungen von Fall 127 sind nach Bedingung 4
  zulässig.** `mutate.sh:372` verlangt den erwarteten Namen in einer Zeile, die dem
  Fehlschlag-Muster entspricht — mehrere `--- FAIL:`-Zeilen sind unschädlich, solange die
  erwartete darunter ist. Der Fall-Kopf legt die Mitläufer offen (`127-…:28-33`), statt sie
  wegzulassen. Der Rest-Befund betrifft die Überdetermination *innerhalb* des Wächters
  (MEDIUM-4), nicht die drei Tests.

**Werkzeug-Achse und Fehlschlag.**

- **Geprüft, ohne Befund: die Achse ist der Werkzeug-Name, und der Wächter dazu ist nicht
  tautologisch.** `TestOnlyAgentToolGetsResponseValues` (`response_test.go:140-168`) fährt
  **dieselbe** `tool_response` (mit `usage`, `agentType`, `resolvedModel`) durch sieben fremde
  Namen — darunter `Task` und die Kleinschreibung `agent`, also die zwei naheliegenden
  Verwechslungen — prüft je, dass nichts erfasst wird, **und** dass Name/Status/Länge
  erhalten bleiben, und schließt mit einer Gegenprobe unter `Agent`. Damit kann er unter der
  Mutation „Achse auf die Antwort statt den Namen" rot werden — die Fehlerform, die
  Befund HIGH-1 aus slice-059 auf der Argument-Achse hatte (`mcp__db__run` → `"psql"`).
- **Geprüft, ohne Befund: der Fehlschlag erzeugt keinen halben Span.** `Parse` betritt den
  Erfassungs-Zweig nur unter `if v, ok := raw["tool_response"]` (`span.go:116-121`); fehlt der
  Schlüssel ganz — der gemessene Fall (`slice-060-rollen-achse.md:187`, Messzeile 4) —,
  bleiben alle neun Felder abwesend statt `0`. Die Zähler sind `*int64` mit `omitempty`, was
  „nicht gemessen" von „gemessen 0" unterscheidbar hält (`response.go:153-156`,
  `:27-33`); `TestFailedAgentCallCapturesNothing` prüft die Abwesenheit an der geschriebenen
  Zeile, inklusive `is_interrupt` und `result_bytes`.
- **Geprüft, ohne Befund: die Erfassung ist tolerant, nicht span-verlierend.** `count`
  (`:157-163`) und `text` (`:165-171`) verwerfen bei Typ-Abweichung nur das einzelne Feld;
  `descend` bricht bei einem nicht-objektwertigen `usage` sauber ab (`:211-214`).
  `extractAgentResult` gibt bei einer nicht-objektwertigen `tool_response` ein leeres
  `AgentResult` zurück (`:181-187`) — dieselbe fail-open-Linie wie `Parse`, im Einklang mit
  `ADR-0011` Festlegung 6.

**Doku-Mechanik.**

- **Geprüft, ohne Befund: `harness/README.md` und `AGENTS.md` §4 brauchten kein Update.** Der
  Diff fügt kein Gate hinzu und ändert keinen Gate-Vertrag; `make span-check` und `make test`
  behalten ihre Beschreibung. Kein halluziniertes Gate (§3.1).
- **Geprüft, ohne Befund: die Bezug-Kennungen stehen in der Commit-Message.** `4a9ed3c` nennt
  `AGENTS.md 3.6`, `LH-QA-03`, `ADR-0011`, `MR-018`, `slice-060 DoD (2)`; `4ae9c98` nennt
  `AGENTS.md 3.6`, `MR-018`, `slice-060 DoD (2)` (§5, Traceability).
- **Geprüft, ohne Befund: der neue `**Bezug:**`-Block-Mechanismus ist nicht gebrochen.**
  `references()` (`span.go:418-438`) liest bis zur ersten Leerzeile; der Slice-Plan hält seine
  Ausschluss-Notiz zu `LH-FA-08` bewusst darunter (`slice-060-rollen-achse.md:31-39`). Der
  reale Span `seq 324` zeigt die Ableitung im Ergebnis (`agent_role:""`, `spawned_role`
  gefüllt) — die Trennung „`agent_role` ist die Rolle des Aufrufers, `spawned_role` die des
  Subagenten" hält am echten Lauf.

---

## Kategorie-Summary

| Kategorie | Anzahl | IDs |
|---|---|---|
| **HIGH** | 1 | HIGH-1 |
| **MEDIUM** | 4 | MEDIUM-1 · MEDIUM-2 · MEDIUM-3 · MEDIUM-4 |
| **LOW** | 4 | LOW-1 · LOW-2 · LOW-3 · LOW-4 |
| **INFO** | 3 | INFO-1 · INFO-2 · INFO-3 |

---

## Verdikt

**NICHT KONFORM** — ein HIGH und vier MEDIUM blockieren nach der Verdikt-Regel des
Reviewer-Skills.

**Was ausdrücklich hält, damit die Reparatur nicht am falschen Ende ansetzt:** die
Form-Vorgabe des Plans ist im Code **wirklich** erfüllt und nicht nur der Form nach — die
Auswahl ist eine benannte Liste, über die iteriert wird, und es gibt keinen Zweig zu einem
ungelisteten Schlüssel. Alle fünf Architect-Grenzen B1–B5 sind im Code gehalten, B0 (nichts
emittiert) gemessen. Keine Hard Rule ist verletzt: keine Inline-Suppression, keine ADR
berührt, keine Gate-Lockerung. Die Zahlen in `MR-018` sind nachgezählt und stimmen — neun
Werte in sieben Zeilen, sechs Schlüssel, fünf Zähne, vier Abweichungen; die
Zählfehler-Serie dieser Slice-Familie setzt sich hier **nicht** fort.

**Wo die Befunde liegen:** vier von fünf blockierenden Befunden sind Aussagen über die
Abdeckung, nicht Defekte der Erfassung — der Gate-Prüfbereich (HIGH-1), das
Abweichungs-Register gegen die eigene Feldtabelle (MEDIUM-1), eine Lesevorschrift gegen die
Draht-Form (MEDIUM-2), ein Rot-Beleg ohne Fundstelle (MEDIUM-3). Nur MEDIUM-4 betrifft einen
Wächter selbst, und auch dort geht es um die Bindung des Zahns, nicht um die Eigenschaft.

**Rollen-Grenze:** dieses Artefakt prüft den Diff gegen Plan, ADR und Hard Rules. Es hakt
keinen DoD-Punkt ab. Zwei Punkte gehen ausdrücklich als **Eingabe** an die Verifikation
(Modul 11), nicht als Befund von mir, weil Gate-Lauf-Bestätigung nicht meine Rolle ist:
(a) die DoD-Zeile *„`make mutate` ohne Befund"* ist bislang durch einen **gesourcten**
Treiber-Pfad belegt, nicht durch das Make-Target (Grund im Commit dokumentiert, der Deckel ist
`docs/plan/planning/next/slice-065-testlauf-ressourcendeckel.md`); (b) `make gates` ist als
grün berichtet — mit der Einschränkung aus HIGH-1.

**Vorherige Findings, Muster-Abgleich:** die Klasse „Zusage breiter als Sensor" tritt in
diesem Diff dreimal auf (MEDIUM-3, LOW-1, LOW-3) und ist damit nach dem Reviewer-Skill ein
**Steering-Loop-Signal** — die dritte Wiederholung derselben Klasse verlangt, den Guide oder
den Sensor nachzuziehen, statt nur zu melden. Der naheliegende Ort ist HIGH-1: zwei der drei
(LOW-1, LOW-3) liegen in `_test.go`-Dateien, die `Makefile:135` per `grep -v '_test[.]go'`
ausnimmt, und MEDIUM-3 liegt in `conventions.md`, das `comment-claims` gar nicht liest.
