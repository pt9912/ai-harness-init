# Code-Review: slice-060 DoD (2) — die Auflösung der zwei blockierenden MEDIUM (`5cef697..f2829ae`)

**Rolle:** Reviewer (Modul 10, `.harness/skills/reviewer.md` v1.4.0). **Datum:** 2026-07-30.
**Autor:** ai-harness-init-Team (pt9912). Frischer Kontext — weder der Code noch einer der
Vorgänger-Reports stammt aus diesem Lauf.

## Kopf-Metadaten (die fünf Pflicht-Punkte + Slice-Plan)

| Punkt | Inhalt |
|---|---|
| **Diff / Commit-Range** | `5cef697..f2829ae` — **ein** Commit. 8 Dateien, +621/−21 |
| **`LH-*`-Anforderungen** | [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) |
| **Referenzierte aktive ADRs** | [`ADR-0011`](../plan/adr/0011-telemetrie-erfassung-policy.md) (**Accepted**, Folgepflicht 1/4/5, Festlegung 1 Punkt 3, Festlegung 2), [`ADR-0003`](../plan/adr/0003-go-native-binaries.md) |
| **Hard Rules** | [`AGENTS.md`](../../AGENTS.md) §3.1 · §3.2 · §3.3 · §3.4 · §3.5 · **§3.6** |
| **Vorherige Findings am gleichen Modul** | `docs/reviews/2026-07-30-slice-060-dod2-adr-0011-architect.md` (B1–B5), `…-slice-060-dod2-review.md` (R1), `…-slice-060-dod2-review-runde-2.md` (R2: R2-MEDIUM-1, R2-LOW-1/2, R2-INFO-1/2), Verifikations-Befund **V-1**, `…-slice-060-v1-review.md` (**MEDIUM-1/-2, LOW-1/-2, INFO-1** — der Gegenstand dieser Runde) |
| **Slice-Plan** (Repo-Ergänzung) | `docs/plan/planning/in-progress/slice-060-rollen-achse.md` DoD (2), §3-Zeilen `test/mutations/` (`:216`) und `harness/conventions.md` (`:214`) |

**Nicht Gegenstand:** die DoD-Abhakung und die Bestätigung der Gate-Läufe (Modul 11).

**Ebene:** alle Aussagen dieses Reports betreffen den **Dogfood**. Der Diff berührt
`internal/emit/templates/` nicht; emittiert wird nichts.

### Gefahrene Sensoren — echte Ausgabe, nichts übernommen

Kein `make mutate`-Vollauf (Nutzer-Ausschluss). Stattdessen **elf** Docker-Sensor-Läufe gegen
eine isolierte Kopie außerhalb des Repos (`tar`-Kopie des Baums, `cp`-Backups, Grün-Vor- und
-Nachlauf, Host-Baum vor und nach jedem Lauf `git status --porcelain` leer auf `f017941`),
teils roh (`make test-go` mit erhaltenem Log, um `--- FAIL:`-Zeilen **auszuzählen**), teils
über den gesourcten `run_case`-Pfad des Treibers. Dazu vier `make docs-check`-Sonden gegen
dieselbe Kopie und zwei lesende Gate-Läufe am Host.

```
GRUEN-VORLAUF    make test-go exit=0, 0 x "--- FAIL:", 7 Go-Pakete

(A) roh, Waechter AUSGEZAEHLT ueber alle "--- FAIL:"-Zeilen (HEAD-Nummerierung)
    132 -> 1 Waechter  TestAgentGetsNoArgumentFields        response_test.go:207
    133 -> 1 Waechter  TestOnlyAgentToolGetsResponseValues  response_test.go:169
    134 -> 1 Waechter  TestFailedAgentCallCapturesNothing   response_test.go:341
    135 -> 1 Waechter  TestAgentGetsNoArgumentFields        response_test.go:221
    136 -> 1 Waechter  TestFailedAgentCallCapturesNothing   response_test.go:341
                       ("output_tokens" steht in der Span-Zeile: … "output_tokens":null)
    137 -> 2 Waechter  TestAgentGetsNoArgumentFields        response_test.go:207
                       TestFailedAgentCallCapturesNothing   response_test.go:341

(B) run_case, Waechter intakt
    mutate: ok  134 / 136 / 137            SUMMARY: 3 ok, 0 Befund(e)

(C) Gegenprobe: "output_tokens" aus der Liste gestrichen (Gruen-Vorlauf exit 0)
    mutate: ok      134
    mutate: BEFUND  136   "make test-go blieb GRUEN — … hat keine Zaehne mehr"
    mutate: ok      137                    SUMMARY: 2 ok, 1 Befund

(D) Gegenprobe: "spawned_role" aus der Liste des FEHLSCHLAG-Waechters gestrichen
    mutate: ok      134   <- der MEDIUM-2-Beweis, im selben Lauf
    mutate: ok      136
    mutate: BEFUND  137   "rot, aber … faellt nicht — falscher Grund"
    mutate: ok      132                    SUMMARY: 3 ok, 1 Befund

(E) Gegenprobe: "input_tokens" gestrichen
    mutate: BEFUND  134   "blieb GRUEN — … hat keine Zaehne mehr"

(F) Gegenprobe: "total_tokens" UND "model_version" gestrichen
    mutate: ok  127 / 129 / 134 / 136 / 137   SUMMARY: 5 ok, 0 Befund(e)

(G) Gegenprobe: "spawned_role" aus der Liste des ERSTEN Waechters (:207) gestrichen
    mutate: ok      132   (faellt jetzt an :224, der Strukt-Pruefung)
    mutate: ok      137                    SUMMARY: 2 ok, 0 Befund(e)   <- MEDIUM-1 unten

(H) d-check-Sonden gegen dieselbe Kopie
    `internal/span/response_test.go:1-9999`  -> 258 Datei(en), 0 Befund(e)   (still)
    `harness/tools/mutate.sh:1-9999`         -> 1 Befund  citation-out-of-range
    `harness/tools/mutate.sh:9999`           -> 1 Befund  citation-out-of-range (9999-9999)
    `conventions.md:1-9999`                  -> still

GRUEN-NACHLAUF   make test-go exit=0, Kopie sauber, Host-Baum sauber
```

Am Host, lesend: `make docs-check` → `d-check: 258 Datei(en) geprüft, 0 Befund(e)`;
`make comment-claims` → `38 Datei(en) geprueft, 0 Befund(e)`.

### Die nachgezählten Angaben — eigene Zahlen

| Angabe | Fundstelle | nachgezählt | Urteil |
|---|---|---|---|
| „**fünf der sechs** färben genau EINEN Wächter; 137 färbt zwei" | `harness/conventions.md:1124-1126` | Messung (A): 132/133/134/135/136 → je 1, 137 → 2 | **stimmt** |
| „**dreizehn** Zähne oben (123–129 und 132–137)" | `harness/conventions.md:1277-1278` | 7 + 6 = **13**; die nummerierte Liste nennt sie alle | **stimmt** |
| „geliefert sind **fünfzehn** … 123–137" | `docs/plan/planning/in-progress/slice-060-rollen-achse.md:216` | 137−123+1 = **15**, alle Dateien existieren, Gesamtstand 133 Fälle | **stimmt** |
| „**DREI** der neun Einträge sind einzeln gebunden" | `harness/conventions.md:1195-1198` | Messungen (C)/(D)/(E): je BEFUND → **3** | **stimmt, gemessen** |
| „die übrigen **sechs** … kein Fall schreibt einen von ihnen in diese Zeile" | `harness/conventions.md:1198-1202` | Messung (F) für 2 von 6 + statisch: die sechs Namen stehen in **keiner** ausführbaren Zeile der 133 Fälle, nur in Kommentaren | **plausibel, teilbelegt** |
| „`"argc":4` und nicht 5" | `test/mutations/135-…:27` | `commandProgram` = `len(fields)-i-1`, 5 Felder → **4**; `TestCommandProgramSkipsAssignments` misst `"ls -l /tmp"` → 2 | **stimmt** |

---

## Findings

### MEDIUM-1 — Der neue Draht-Form-Absatz nennt Fall 137 als **den** Dauer-Zahn für **zwei** Wächter; gemessen bindet er den Eintrag nur in **einem**

- **kategorie:** MEDIUM
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 ·
  [`MR-018`](../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
  §Bewacht Eigenzusage `:1103` (*„Die Liste unten nennt, **was** ein Zahn bindet"*) ·
  Vorinstanzen R2-MEDIUM-1 und V-1-MEDIUM-2 (identische Fehlerform)
- **pfad:** `harness/conventions.md:1244-1249` gegen `internal/span/response_test.go:207`
- **befund:** Der Absatz lautet: *„**Die Draht-Form von `spawned_role`** … bewachen
  `TestAgentGetsNoArgumentFields` und `TestFailedAgentCallCapturesNothing` an der
  geschriebenen Zeile. **Ihr Dauer-Zahn ist seit dem 2026-07-30
  `test/mutations/137-span-rollenfeld-praesent-leer.sh`**"*. Gemessen (Sonde G): streicht
  man `"spawned_role"` aus der `mustNotContain`-Liste des **ersten** Wächters
  (`response_test.go:207`), melden **137 und 132 beide weiter „ok"** — 137, weil er über
  den zweiten Wächter rot bleibt und dessen Namen in der `# expect:`-Zeile trägt; 132,
  weil er auf die Strukt-Prüfung `response_test.go:224` durchfällt und `run_case`
  Bedingung 4 nur den **Namen**, nicht die Zeile prüft. Der Eintrag des ersten Wächters
  ist damit von **keinem** Fall des Sets gebunden. Derselbe Absatz macht die
  Per-Wächter-Unterscheidung zwei Sätze später **ausdrücklich** — für 132
  (`:1253-1256`: *„er bindet die Herkunft und nur im ersten der beiden Wächter"*) — und
  lässt sie für 137 weg; die Asymmetrie liest sich als Aussage. Der Fall-Kopf selbst ist
  präziser (`test/mutations/137-…:41`: *„GEBUNDEN BLEIBT DER BENANNTE"*) — die normative
  Fassung ist die unpräzisere.
- **failure-szenario:** Jemand räumt `TestAgentGetsNoArgumentFields` auf und streicht
  `"spawned_role"` aus `response_test.go:207` mit der Begründung, die Strukt-Prüfung
  `s.SpawnedRole != ""` zwei Zeilen tiefer decke dasselbe. `make gates` bleibt grün,
  `make mutate` meldet nichts (gemessen). Danach misst dieser Wächter die Draht-Form
  **nicht** mehr — die Strukt-Prüfung kann sie strukturell nicht sehen, denn das
  Struct-Feld ist in beiden Draht-Formen `""`; nur das JSON-Tag entscheidet über
  An- oder Abwesenheit. `MR-018` sagt dem nächsten Leser weiter, dieser Wächter trage die
  Zusage und 137 halte sie am Leben.
- **verifizierbar:** ja, gefahren (Sonde G, Grün-Vorlauf exit 0). Reproduzierbar:
  `sed -i '207s/, "spawned_role",/,/' internal/span/response_test.go` in einer isolierten
  Kopie, dann 132 und 137 über `run_case`.
- **Zur Kategorie, weil sie bestreitbar ist:** für **LOW** spricht, dass die
  *Eigenschaft* nicht still grün wird — der zweite Wächter hält sie weiter, und dessen
  Eintrag ist gemessen gebunden (Sonde D). Für **MEDIUM** spricht, dass §Bewacht sich in
  dieser Runde selbst auf *„was ein Zahn bindet"* verpflichtet hat (`:1103`), dass genau
  diese Zuschreibungs-Klasse jetzt zum **vierten** Mal in dieser Slice-Familie auftritt
  (R2-MEDIUM-1 · V-1-MEDIUM-2 · hier · MEDIUM-2 unten) und dass sie diesmal in dem Satz
  steht, der die dritte Instanz reparieren sollte. Nach dem Reviewer-Skill ist die dritte
  Wiederholung ein **Steering-Loop-Signal**; ich bleibe bei MEDIUM.

### MEDIUM-2 — Die Kommentar-Bereinigung hat aus `intoSpawnedRole` zwei gemessene **Eigenschaften** entfernt, nicht nur Forensik; der Kommentar sagt jetzt nicht mehr dasselbe wie `MR-018`

- **kategorie:** MEDIUM
- **quelle:** Slice-Plan `docs/plan/planning/in-progress/slice-060-rollen-achse.md:214`
  (*„§Bewacht, das heute dasselbe sagt wie der Emitter-Kommentar"*) ·
  [`AGENTS.md`](../../AGENTS.md) §3.6
- **pfad:** `internal/span/response.go:106-112` gegen `harness/conventions.md:1253-1256`
- **befund:** **Außerhalb des Prüf-Range**, aber im Baum: `f017941` hat die zwei
  Klammer-Sätze entfernt, die `f2829ae` gerade erst gesetzt hatte — *„(ein Rückfall auf
  `tool_input.subagent_type` färbt den **ERSTEN** rot; der zweite führt
  `subagent_type: "nope"`, das zu leer normalisiert, und bleibt dort absichtlich grün)"*
  und *„(… färbt **BEIDE**; die `# expect:`-Zeile bindet den zweiten, weil der erste seine
  Zusicherung schon aus 132 hält)"*. Beides sind **Eigenschaften**, keine Befund-IDs, kein
  Datum, kein Runden-Verweis. Übrig bleibt: *„Die Abwesenheit bei fehlendem Ergebnis
  bewachen `TestAgentGetsNoArgumentFields` und `TestFailedAgentCallCapturesNothing`, **je
  ein Dauer-Sensor pro Achse**: 132 … für die HERKUNFT … und 137 … für die DRAHT-FORM."*
  Gemessen (Sonde A): 132 färbt **nur** den ersten Wächter — der zweite trägt
  `subagent_type: "nope"`, normalisiert zu leer und bleibt grün. Die Herkunfts-Achse ist
  im zweiten Wächter also **überhaupt nicht** messbar zugesagt, während der Satz beide
  Wächter und beide Achsen in einem Zug nennt. `MR-018:1253-1256` sagt inzwischen genau
  das Gegenteil (*„Fall 132 trägt sie nicht … nur im ersten der beiden Wächter"*) — womit
  die Plan-Zusage aus §3, dass §Bewacht und der Emitter-Kommentar dasselbe sagen, seit
  `f017941` nicht mehr gilt.
- **failure-szenario:** Der nächste Leser des Emitters nimmt die Zuordnung aus dem
  Kommentar (*je ein Dauer-Sensor pro Achse* für beide Wächter), prüft sie gegen
  `make mutate` und findet für die Herkunfts-Achse des Fehlschlag-Wächters keinen Zahn —
  und meldet V-1-MEDIUM-2 zum zweiten Mal. Genau die Runde, die dieser Diff beenden
  sollte, startet neu, weil die Bereinigung die Präzisierung mitgenommen hat, die sie
  beendete. `make comment-claims` fängt es bauartbedingt nicht: es prüft die **Existenz**
  eines genannten Tests, nie die **Wahrheit** der Zuschreibung
  (`harness/tools/comment-claims.sh:16-20` sagt das selbst).
- **verifizierbar:** ja, gefahren (Sonde A für 132; Sonde D für 137). Der Kommentar-Text
  ist an `git diff f2829ae..f017941 -- internal/span/response.go` ablesbar.

### LOW-1 — Der Grund, warum `check-lines` die vier Zeilennummern nicht prüft, ist gemessen **falsch**; damit ist die zurückgestellte Sensor-Arbeit falsch geschnitten

- **kategorie:** LOW
- **quelle:** [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) ·
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
  (Aussage über den Prüfbereich eines Gates) · V-1-Befund LOW-2, dessen Formulierung hier
  ungeprüft übernommen wurde
- **pfad:** `harness/conventions.md:1131-1135` gegen `.d-check.yml:50`/`:56`
- **befund:** Der neue Satz lautet: *„**kein Sensor prüft sie**: `check-lines`
  (`.d-check.yml`) validiert Zeilen-Referenzen **nur an Pfaden mit
  Verzeichnis-Komponente**, ein bloßes `response_test.go:209` liegt außerhalb seines
  Prüfbereichs (gemessen: `make docs-check` bleibt mit ihnen grün)."* Die **Folgerung**
  stimmt und ist belegt. Der **Grund** stimmt nicht: Sonde H, vier `make docs-check`-Läufe
  gegen dieselbe isolierte Kopie, zeigt, dass auch
  `` `internal/span/response_test.go:1-9999` `` — Verzeichnis-Komponente, Bereichsform,
  Ende weit jenseits der Datei — **still bleibt** (258/0), während
  `` `harness/tools/mutate.sh:1-9999` `` **und** `` `harness/tools/mutate.sh:9999` ``
  (Einzelzeile!) beide `citation-out-of-range` melden. Bindend ist also nicht die
  Verzeichnis-Komponente allein und schon gar nicht die Bereichsform, sondern
  `codepaths.roots: [spec, docs, harness]` (`.d-check.yml:50`) — `internal/` liegt
  außerhalb, was der Konfigurations-Kommentar dort selbst sagt (*„tools/cmd/internal
  folgen mit dem Go-Code (Phase 3)"*). Die Formulierung stammt wörtlich aus dem
  V-1-Report (`docs/reviews/2026-07-30-slice-060-v1-review.md:193-196`) und ist in das
  normative Artefakt übernommen worden, ohne sie zu fahren.
- **failure-szenario:** Der Steering-Loop-Eintrag, auf den die zurückgestellte Hälfte von
  LOW-2 zeigt, wird als *„`check-lines` auf Referenzen ohne Verzeichnis-Komponente
  weiten"* geschnitten (so auch die Commit-Message). Wer das umsetzt, schreibt
  `internal/span/response_test.go:209` in `MR-018`, sieht `make docs-check` grün und hält
  die Lücke für geschlossen — sie ist es nicht. Die reale Arbeit ist eine **Erweiterung
  von `codepaths.roots` um `internal`**, also eine Gate-Anhebung mit ganz anderer
  Sprengweite (jeder Inline-Code-Pfad unter `internal/` würde ab da validiert), und die
  gehört nach [`MR-001`](../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
  in den Steering-Loop mit dieser Beschreibung, nicht mit der falschen.
- **verifizierbar:** ja, gefahren (Sonde H, vier Läufe, beide Richtungen).

### LOW-2 — „bis dahin waren es **acht**" zählt unter dem falschen Prädikat: namentlich waren es **sechs**

- **kategorie:** LOW
- **quelle:** [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) ·
  Muster „Zahlen behauptet statt abgezählt" (sieben Vorinstanzen in dieser Familie)
- **pfad:** `harness/conventions.md:1180-1182`, nachgeordnet
  `internal/span/response_test.go:336-340`
- **befund:** Der Satz lautet: *„Seine `mustNotContain`-Liste nennt sie seit dem
  2026-07-30 **alle neun** namentlich; bis dahin waren es **acht**."* Das Prädikat ist
  *namentlich*; die Ellipse trägt es mit. Ausgezählt an der Vorgänger-Fassung
  (`git show 5cef697:internal/span/response_test.go`, Zeilen 323–326) nannte die Liste
  von den neun Werten **sechs** namentlich — `spawned_role`, `input_tokens`,
  `total_tokens`, `total_duration_ms`, `total_tool_use_count`, `model_version`; die zwei
  Cache-Zähler waren per **Teilstring** gedeckt, `output_tokens` gar nicht. **Acht** ist
  die *Abdeckungs*-Zahl, nicht die *namentlich*-Zahl — und genau diese Verwechslung von
  „genannt" mit „gedeckt" ist der Mechanismus, der `output_tokens` verborgen hat
  (V-1-MEDIUM-1). Der Test-Kommentar wiederholt die Unschärfe milder mit *„statt sieben
  plus einer Teilstring-Überlegung"* (`response_test.go:338-339`): die sieben schließen
  `result_bytes` ein, von dem derselbe Absatz zwei Sätze später sagt, es sei *„KEINER der
  neun"*.
- **failure-szenario:** Wer die Reparatur nachprüft — der nächste Reviewer oder die
  Verifikation — zählt die alte Liste, findet sechs Namen und muss entscheiden, ob
  `MR-018` falsch zählt oder er selbst. An der Stelle, die die Zählfehler-Familie
  beenden soll, kostet das genau die Prüfrunde, die sie erspart haben will.
- **verifizierbar:** ja (Auszählung gegen `git show 5cef697:internal/span/response_test.go`
  Zeilen 323–326; keine Gate-Ausgabe nötig).

### LOW-3 — Die „genau dann"-Definition eines gebundenen Eintrags ist in der Hinlänglichkeits-Richtung falsch, und zwar an genau der Teilstring-Überlappung, die derselbe Absatz kennt

- **kategorie:** LOW
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 ·
  [`MR-018`](../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
  §Bewacht Punkt 8
- **pfad:** `harness/conventions.md:1195-1197`
- **befund:** *„Ein Zahn bindet einen Eintrag **genau dann**, wenn seine Mutation genau
  diesen Namen in die Fehlschlag-Zeile schreibt."* Notwendig ist das; hinreichend nicht.
  `mustNotContain` prüft per `strings.Contains` (`internal/span/response_test.go:41`) und
  bricht beim **ersten** Treffer ab. Ein Fall, der `omitempty` von
  `cache_read_input_tokens` nimmt, schreibt „genau diesen Namen" in die Zeile — und
  bindet den Eintrag trotzdem nicht: streicht man `"cache_read_input_tokens"`, greift
  weiterhin `"input_tokens"` als Teilstring, der Wächter bleibt rot, `make mutate` meldet
  „ok". Genau diese Überlappung steht drei Absätze weiter im Test-Kommentar
  (`response_test.go:336-337`) und ist der Grund, warum die Cache-Zähler bis zum
  2026-07-30 „gedeckt" aussahen.
- **failure-szenario:** Derselbe Absatz lädt ausdrücklich dazu ein, die *„sechs weiteren
  `omitempty`-Kopien"* zu schneiden (`:1203-1206`). Wer eine für einen Cache-Zähler
  schneidet, misst „rot" und trägt nach dieser Definition den Eintrag als gebunden nach —
  er ist es nicht, und die Zähl-Zeile in `MR-018` wächst um eine Zusage ohne Sensor.
  Das ist die Fehlerform aus V-1-MEDIUM-2, regeneriert durch die Definition, die sie
  verhindern soll.
- **verifizierbar:** ja — dieselbe Sonden-Form wie (C)/(E): den Cache-Eintrag streichen
  und den zugehörigen Fall über `run_case` fahren. Heute existiert kein solcher Fall,
  der Befund ist also **latent**, nicht akut.

### LOW-4 — Der Betreff der Bereinigung sagt „null Marker" zu; es sind sechs

- **kategorie:** LOW
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 (*„Eine Zusage — … Commit-Message —
  ist erst fertig, wenn …"*)
- **pfad:** Commit `f017941` (*„span-Paket: Forensik aus allen Kommentaren — sechs
  Dateien, null Marker"*) gegen `cmd/span-emit/main.go:25`,
  `internal/span/span_test.go:118`, `:119`, `:262`, `:472`, `internal/span/emit.go:362`
- **befund:** **Außerhalb des Prüf-Range**, aber im Baum. Ausgezählt über die sechs
  genannten Dateien bleiben sechs Befund-Marker stehen: `(MEDIUM-4)` in
  `main.go:25`, `HIGH-7` und `LOW-2` in `span_test.go:118-119`, `LOW-3` in `:262`,
  `(MEDIUM-7)` in `:472` und `(Verifier-Befund)` in `emit.go:362`. „Null" ist damit als
  Zahl falsch; der Betreff behauptet Vollständigkeit über einen Bestand, der nicht
  ausgezählt wurde.
- **failure-szenario:** Die nächste Sitzung, die diese Bereinigung als erledigt liest,
  lässt die sechs stehen — und die nächste Runde derselben Aufräum-Arbeit zählt sie neu
  als „neu entstandene" Forensik.
- **verifizierbar:** ja (`grep -nE "HIGH-[0-9]|MEDIUM-[0-9]|LOW-[0-9]|Review-Befund|Review
  Runde|Verifier-Befund"` über die sechs Dateien; kein Gate deckt es — `comment-claims`
  prüft Sensor-Nennung, nicht Marker-Freiheit).

### LOW-5 — Die Bereinigung hat einen Kommentar-Satz zerbrochen und vier Satzenden verloren

- **kategorie:** LOW
- **quelle:** Maintainability
- **pfad:** `internal/span/span_test.go:96-98`, dazu `:288`, `:370`, `:555`, `:576`
- **befund:** **Außerhalb des Prüf-Range**, aber im Baum. `span_test.go:96-98` lautet
  jetzt: *„Es gehoert deshalb NICHT in die Tabelle strukturell nie eintreten kann."* — der
  Parenthese-Ersatz ist an die Stelle des Satzendes getreten. Die Eigenschaft, die der
  Satz trug (*„Es zu listen war eine Zusage, die strukturell nie eintreten konnte"*, so
  steht sie weiterhin in `internal/span/span.go:199-201`), ist an dieser Stelle
  unlesbar. Vier weitere Kommentar-Blöcke verloren ihren Satzpunkt und laufen in den
  Folgesatz (`:288`, `:370`, `:555`, `:576`).
- **failure-szenario:** Ein Leser des Wächters `TestUnknownToolStaysSilent` findet an der
  einzigen Stelle, die die `BashOutput`-Auslassung im Test begründet, einen Satz ohne
  Aussage — und listet `BashOutput` „zur Sicherheit" doch, womit `toolClass`
  (`internal/span/span.go:199`) seinen fail-closed Default an einem Werkzeug verliert,
  dessen Eingabe eine Shell-Kennung ist.
- **verifizierbar:** nein (Lesbarkeit). Nachlesbar an den genannten Zeilen.

### INFO-1 — Der committete Übergabe-Report trägt zwei eigene Zählfehler; korrigiert wird hier, weil `docs/reviews/**` eingefroren ist

- **kategorie:** INFO
- **quelle:** [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) ·
  `.d-check.yml:59` (`exempt-paths: ["docs/reviews/**"]` — Zeitdokumente)
- **pfad:** `docs/reviews/2026-07-30-slice-060-v1-review.md:94` und `:99-100`
- **befund:** Der Diff committet den V-1-Report als Übergabe-Artefakt — richtig so. Er
  trägt zwei Zählfehler, die die Aufgabenstellung dieser Runde wiederholt hat und die der
  Implementer gemeldet hat. Nachgeprüft: **(a)** *„`output_tokens` steht nur in
  `response_test.go:80` und `:108`, **beide `mustContain`**"* ist falsch — `:80`
  (Fassung `5cef697`) ist die Payload-Zeile in `agentForegroundPayload`, nur `:108` ist
  ein `mustContain`-Argument. Der Implementer hat **recht**. **(b)** *„Die
  `mustNotContain`-Liste … führt **sieben** Zeichenketten"* ist ebenfalls falsch: das
  Literal (`5cef697`, Zeilen 323–326) trägt **zehn** — sieben Feldnamen plus
  `geheimPrompt`, `"is_interrupt"`, `"not found"`. Auch hier hat der Implementer recht.
  **Nicht** falsch war die Angabe *„prüfte acht"*: sie zählt, wie viele der **neun Werte**
  gedeckt waren (sechs namentlich + zwei per Teilstring), und das stimmt — die
  Zurückweisung „zehn, nicht acht" trifft zwei verschiedene Größen (s. LOW-2). Keiner der
  beiden Fehler berührt die Substanz von V-1-MEDIUM-1.
- **failure-szenario:** Kein technisches. Die Fundstellen-Angabe `:80` würde einen
  Nachprüfer an eine Payload statt an eine Zusicherung schicken.
- **verifizierbar:** nein (Aussage über ein eingefrorenes Zeitdokument). Nachrechenbar an
  `git show 5cef697:internal/span/response_test.go`.

---

## Negativbefunde (geprüft, ohne Befund)

**Die Auflösung von V-1-MEDIUM-1.**

- **Geprüft, ohne Befund: `output_tokens` ist real gebunden, in beide Richtungen im
  selben Sensor-Pfad.** Mit intaktem Wächter meldet 136 „ok" (Sonde B); mit gestrichenem
  Eintrag meldet er **BEFUND** *„make test-go blieb GRUEN — … hat keine Zaehne mehr"*
  (Sonde C), **während 134 und 137 daneben weiter „ok" melden**. Das ist die Konstruktion,
  die V-1 für 132 verlangt hat, hier eine Stelle weiter.
- **Geprüft, ohne Befund: 136 färbt genau EINEN Wächter — selbst ausgezählt, nicht am
  erwarteten Namen abgelesen.** Über alle `--- FAIL:`-Zeilen des Laufs: ein Wächter
  (`TestFailedAgentCallCapturesNothing`), eine Fehlschlag-Zeile (`response_test.go:341`),
  Meldung `"output_tokens" steht in der Span-Zeile: {… "output_tokens":null}`. Die
  Präzedenz aus Fall 127/MEDIUM-4 wiederholt sich nicht.
- **Geprüft, ohne Befund: der `sed`-Anker greift genau einmal.**
  `json:"output_tokens,omitempty"` steht im Go-Code repo-weit genau einmal
  (`internal/span/response.go:28`); die übrigen Treffer sind Fall-Köpfe und Doku. Dasselbe
  für `json:"spawned_role,omitempty"` (`:26`) und `json:"input_tokens,omitempty"` (`:27`).
- **Geprüft, ohne Befund: die Neben-Zusagen im Kopf von 136 stimmen.** `output_tokens`
  steht in `response_test.go` nur an `:79` (Payload), `:107` (Gegenprobe **mit Messwert**
  `"output_tokens":22`), `:318` (Kommentar) und `:342` (die neue Negativ-Zeile) —
  `canReadOutputFile` in `TestUnlistedResponseKeyStaysOut` ist wirklich nur eine optische
  Ähnlichkeit.

**Die Auflösung von V-1-MEDIUM-2.**

- **Geprüft, ohne Befund: der Beweis der falschen Zuschreibung ist im selben Lauf
  reproduzierbar.** Mit gestrichenem `"spawned_role"` in der Liste des
  Fehlschlag-Wächters meldet **134 weiter „ok"** und **137 BEFUND** *„rot, aber … faellt
  nicht — falscher Grund"* (Sonde D). Beide Hälften nebeneinander, ein Lauf — genau die
  Form, die der Report zusagt.
- **Geprüft, ohne Befund: 137 färbt zwei Wächter, und das verdeckt seinen Grund
  nicht.** Ausgezählt über alle `--- FAIL:`-Zeilen: `TestAgentGetsNoArgumentFields`
  (`:207`) und `TestFailedAgentCallCapturesNothing` (`:341`), je mit derselben Meldung
  `"spawned_role" steht in der Span-Zeile: {… "spawned_role":""}`. Dass das Mehrfach-Rot
  hier **nicht** die MEDIUM-4-Falle wiederholt, ist gemessen und nicht argumentiert:
  Sonde D zeigt, dass der Treiber trotz Rot-durch-den-anderen-Wächter **BEFUND** meldet,
  sobald der gebundene Eintrag fehlt. Bedingung 4 des Treibers trägt hier real.
- **Geprüft, ohne Befund: die `# expect:`-Wahl ist die richtige.** Beide neuen Fälle
  nennen `TestFailedAgentCallCapturesNothing`; `narrow_sensor`
  (`harness/tools/mutate.sh:211-225`) leitet daraus `test-go` ab, `failure_form` liefert
  `--- FAIL:`. Kein doppelter `# files:`/`# expect:`-Kopf (Bedingung 0 des Treibers).

**Die drei bindenden Zähne und die sechs unbenannten.**

- **Geprüft, ohne Befund: alle drei als „gebunden" ausgewiesenen Einträge sind es
  wirklich.** `input_tokens` → 134 BEFUND (Sonde E), `output_tokens` → 136 BEFUND
  (Sonde C), `spawned_role` → 137 BEFUND (Sonde D). Die Zahl **drei** ist gemessen, nicht
  behauptet.
- **Geprüft, mit Rest: die Aussage über die übrigen sechs trägt, ist aber nur
  teilbelegt — und das steht so im Artefakt.** `MR-018:1202` weist sie selbst als *„aus
  der Bauart abgeleitet, nicht einzeln gefahren"* aus; das ist nach §3.6 die zulässige
  Form (*„benennen, was wirklich deckt — oder dass nichts deckt"*), weil die Aussage eine
  **Lücke** offenlegt und nicht eine Deckung zusagt. Ich habe sie über die Bauart
  nachgeprüft (die sechs Namen stehen in **keiner** ausführbaren Zeile der 133 Fälle, nur
  in Kommentaren) und für zwei von sechs gefahren (Sonde F: `total_tokens` und
  `model_version` gestrichen → 127/129/134/136/137 alle „ok"). Kein eigener Befund; die
  Restunsicherheit ist benannt, nicht verdeckt.

**Die übrigen V-1-Punkte.**

- **Geprüft, ohne Befund: LOW-1 ist sauber geschlossen.** `"argc":4` stimmt
  (`commandProgram` = `len(fields)-i-1`, `internal/span/span.go:241-254`), die Begründung
  im Kopf (`test/mutations/135-…:32-37`) nennt mit
  `TestCommandProgramSkipsAssignments` einen Wächter, der dieselbe Semantik bei jedem
  `make test-go` misst (`"ls -l /tmp"` → 2, `internal/span/span_test.go:128`) — die Zahl
  ist damit nicht nur korrigiert, sondern an einen laufenden Sensor gehängt.
- **Geprüft, ohne Befund: INFO-1 ist korrekt bestätigt.** `run_case` ruft jeden Fall als
  `bash "$case_file"` (`harness/tools/mutate.sh:301`); das Modus-Bit ist für
  `make mutate` wirkungslos. Die zwei neuen Fälle tragen `100755` — Konsistenz, keine
  Reparatur, wie der Commit sagt.
- **Geprüft, mit Rest-Beobachtung: LOW-2s Artefakt-Hälfte ist geschlossen, und der Befund
  hat sich binnen zweier Commits selbst belegt.** Die vier Nummern stehen jetzt als
  datierte Messung (`:1131-1145`), und sie sind **am Prüf-Commit korrekt** — an `f2829ae`
  fiel 132 an `:209`, 133 an `:171`, 135 an `:223`, 134/136 an `:347`, 137 an `:209`
  **und** `:347`; ich habe alle sechs nachgemessen (Sonde A, HEAD-Nummerierung `:207` /
  `:169` / `:221` / `:341`, also durchweg −2 bzw. −6). Am **Baum-Kopf** `f017941` sind
  alle sechs Nummern bereits veraltet — die Alterung, die der Absatz benennt, ist binnen
  zweier Commits eingetreten. Kein eigener Befund: der Absatz sagt genau das vorher und
  datiert seine Messung.
- **Geprüft, ohne Befund: die Zurückstellung der Sensor-Hälfte trägt der Form nach.** Sie
  steht in `MR-018`, dessen Auflösungs-Trigger *„permanent"* lautet, ist als Lücke
  ausgewiesen und nicht mitgezählt — dieselbe Behandlung, die V-1 für die
  `mustContain`-Lücke akzeptiert hat. Was nicht trägt, ist ihre **Beschreibung**
  (LOW-1 oben), nicht die Zurückstellung selbst.

**Hard Rules.**

- **§3.1 geprüft, ohne Befund.** Kein neues Gate behauptet, kein Gate-Name erfunden;
  `make docs-check` (258/0) und `make comment-claims` (38/0) am Host gefahren, beide mit
  Vollständigkeits-Zeile.
- **§3.2 geprüft, ohne Befund.** `git diff 5cef697..f2829ae | grep -n "nolint\|shellcheck
  disable"` → keine Treffer.
- **§3.3 nicht anwendbar** — kein `git mv` im Range.
- **§3.4 geprüft, ohne Befund.** `docs/plan/adr/` ist unberührt; die ADR-Lage bewegt sich
  ausschließlich über `MR-018`, an das
  [`ADR-0011`](../plan/adr/0011-telemetrie-erfassung-policy.md) Folgepflicht 1 delegiert.
- **§3.5 geprüft, ohne Befund.** Kein Gate entfernt, kein Schwellwert gesenkt; die
  Fallzahl steigt von 131 auf **133**, die Negativ-Liste des Fehlschlag-Wächters von
  sieben auf zehn Einträge. Der Diff ist durchweg **verschärfend**.
- **§3.6 Muster-Abgleich.** Die Klasse „Zusage breiter als Sensor" tritt im Delta
  **einmal** auf (MEDIUM-1), im Baum ein zweites Mal (MEDIUM-2). Nach R2-MEDIUM-1 und
  V-1-MEDIUM-2 ist das die **vierte und fünfte** Instanz derselben Klasse in dieser
  Slice-Familie — nach dem Reviewer-Skill längst ein **Steering-Loop-Signal**: der Sensor
  fehlt, nicht die Sorgfalt. `make comment-claims` prüft Existenz, nie Wahrheit, und ist
  dreifach verengt (Index-only, vier Pfad-Muster, `_test.go` ausgenommen) — die
  Fall-Köpfe unter `test/mutations/`, die Test-Kommentare in `response_test.go` und die
  Zuschreibungen in `harness/conventions.md` liegen **alle** außerhalb.

**Dogfood vs. emittiert.**

- **Geprüft, ohne Befund: es wird weiterhin nichts emittiert.** `internal/emit/templates/`
  ist unberührt; `ADR-0011` Festlegung 5 (das *Ob* der Emission) bleibt unangetastet.

**Architect-Grenzen B1–B5 (als Eingabe, nicht als Erledigung — die Abhakung ist Modul 11).**

- **B1** bleibt an 132 gebunden (Sonde A/D). **B2** an 135 (Sonde A). **B3** an 127
  (Sonde F, „ok" mit intaktem Wächter). **B4** wächst: die Negativ-Liste nennt die neun
  Werte jetzt vollständig, drei davon mit eigenem Zahn. **B5** an 129 (Sonde F). Keine der
  fünf Grenzen ist durch diesen Diff verschlechtert; B4 ist die einzige, die er bewegt —
  nach vorn.

---

## Bilanz über die fünf V-1-Befunde

| V-1-Befund | Ein Wort | Beleg |
|---|---|---|
| **MEDIUM-1** (`output_tokens` ungeprüft) | **geschlossen** | Sonden B/C: 136 zweiseitig, genau ein Wächter, Anker eindeutig |
| **MEDIUM-2** (Fall 134 falsch zugeschrieben) | **halb** | die falsche Nennung ist weg und 137 bindet real (Sonde D) — die Zuschreibungs-Klasse kehrt in derselben Passage wieder (MEDIUM-1) und im Kommentar (MEDIUM-2) |
| **LOW-1** (`argc` 5 statt 4) | **geschlossen** | Zahl korrigiert **und** an `TestCommandProgramSkipsAssignments` gehängt |
| **LOW-2** (Zeilennummern ohne Sensor) | **halb** | Artefakt-Hälfte geschlossen und datiert; Sensor-Hälfte offen **und falsch beschrieben** (LOW-1) |
| **INFO-1** (Modus-Bit wirkungslos) | **geschlossen** | bestätigt an `harness/tools/mutate.sh:301`, ohne Änderung — richtig |

---

## Kategorie-Summary

| Kategorie | Anzahl | IDs |
|---|---|---|
| **HIGH** | 0 | — |
| **MEDIUM** | 2 | MEDIUM-1 (im Range) · MEDIUM-2 (im Baum, `f017941`) |
| **LOW** | 5 | LOW-1 · LOW-2 · LOW-3 (im Range) · LOW-4 · LOW-5 (im Baum) |
| **INFO** | 1 | INFO-1 |

---

## Verdikt

**NICHT KONFORM** — ein MEDIUM im Prüf-Range, ein zweites im Baum. Kein HIGH.

**Was dieser Diff einlöst, und es ist substanziell.** V-1-MEDIUM-1 ist vollständig und
zweiseitig gemessen geschlossen: `output_tokens` steht jetzt in einer Negativ-Prüfung, hat
einen eigenen Dauer-Zahn, der genau einen Wächter färbt, und die Gegenprobe meldet BEFUND,
sobald der Eintrag fällt — im selben Lauf, in dem die Nachbarn „ok" melden. V-1-MEDIUM-2
ist in seiner konkreten Gestalt aufgelöst: die falsche Nennung von Fall 134 ist weg, 137
existiert, bindet real, und der Beweis der alten Falschzuschreibung (134 bleibt „ok") ist
neben dem neuen Zahn im selben Lauf reproduziert. Alle sechs Zahlen, die ich nachgezählt
habe, stimmen — fünf-von-sechs, dreizehn, fünfzehn, drei, argc 4. Die Zählfehler-Serie
setzt sich in `MR-018` **nicht** in der Zahn-Zählung fort; sie setzt sich in einer
Prädikat-Verwechslung fort (LOW-2), das ist eine mildere Form.

**Zu MEDIUM-1 — Entscheidung: kein Formalismus, sondern die Eigenzusage des Absatzes.**
`MR-018` §Bewacht hat sich in der Vorrunde selbst darauf verpflichtet, *„was ein Zahn
bindet"* zu sagen (`:1103`), und Punkt 8 hält das mustergültig durch (drei gebunden, sechs
benannt-statt-mitgezählt). Der Draht-Form-Absatz sechzig Zeilen tiefer hält es nicht:
er nennt zwei Wächter und einen Zahn, macht die Per-Wächter-Einschränkung für 132
ausdrücklich und lässt sie für 137 weg. Gemessen ist der Eintrag des ersten Wächters von
keinem Fall gebunden. Das ist nicht dieselbe Schwere wie V-1-MEDIUM-1 — die Eigenschaft
selbst bleibt über den zweiten Wächter bewacht —, aber es ist dieselbe Klasse an derselben
Stelle, und sie zum vierten Mal ungemeldet zu lassen hieße, den Steering-Loop ein weiteres
Mal zu verschieben.

**Die eine Sache, die einer Closure im Weg steht.** Der Absatz `harness/conventions.md:1244-1249`
schreibt Fall 137 die Draht-Form-Zusicherung *„an der geschriebenen Zeile"* für **beide**
Wächter zu; gemessen bindet er sie in **einem**. Streicht man `"spawned_role"` aus
`internal/span/response_test.go:207`, bleiben `make gates` und `make mutate` still — und
seit `f017941` sagt der Emitter-Kommentar (`internal/span/response.go:106-112`) dasselbe
zu breit noch einmal, womit er der `MR-018`-Fassung zwei Sätze weiter unten widerspricht
und die Plan-Zusage aus §3 (*„§Bewacht, das heute dasselbe sagt wie der
Emitter-Kommentar"*, `slice-060-rollen-achse.md:214`) bricht. Solange diese eine
Zuschreibung steht, sagt das Artefakt, an das `ADR-0011` Folgepflicht 1 die Feldtabelle
delegiert, dem nächsten Leser wieder das, was der Sensor nicht hält — in genau dem Absatz,
der zur Reparatur dieser Fehlerform geschrieben wurde. Die begleitende Empfehlung ist keine
Lösung im Finding, sondern die Rollen-Grenze: das ist Steering-Loop-Material, kein
Formulierungs-Patch.

**Rollen-Grenze.** Dieses Artefakt prüft den Diff gegen Plan, ADR und Hard Rules; es hakt
keinen DoD-Punkt ab. Zwei Punkte gehen als **Eingabe** an die Verifikation (Modul 11), nicht
als Befund: (a) die DoD-Zeile *„`make mutate` ohne Befund"* ist auch hier nur über gesourcte
Einzelläufe belegt — meine Belege umfassen 127, 129, 132–137 in mehreren Varianten, nicht
die 133 Fälle; der CI-Vollauf auf `f2829ae` lag mir nicht vor, der auf `5cef697` meldete
`131 ok` **ohne** 136/137. (b) `make gates` habe ich nicht vollständig gefahren; belegt
sind `make docs-check` (258/0), `make comment-claims` (38/0) und `make test-go` (grün, Vor-
und Nachlauf, in der isolierten Kopie).
