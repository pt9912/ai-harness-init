# ADR-0020 (Proposed) — Bestätigungsrunde, Runde 2

**Rolle:** Reviewer (Modul 10). **Datum:** 2026-08-16. **Lauf:** frischer Kontext, Subagent
`reviewer`, zweiter Durchgang zu dieser ADR.

**Gegenstand:** die zwei Commits **nach** Runde 1 — `07fe9b7` (Architect:
`docs/plan/adr/0020-emittierte-modul-15-regeln.md` +402/−160, `docs/plan/adr/README.md`) und
`af73707` (Planner: `docs/plan/planning/open/slice-062-emittierte-modul-15-regeln.md`,
`docs/plan/planning/open/slice-087-emittierte-doku-tische-init-invariant.md` **neu**,
`docs/plan/planning/welle-09-modul-15-konformitaet.md`,
`docs/plan/planning/in-progress/roadmap.md`). Beide Diffs gelesen, nicht nur die Endfassungen.
**Auftrag dieser Runde:** was der Fix eingeführt hat — nicht noch einmal, was Runde 1 geprüft hat.

**Eingangs-Kontext (die fünf Pflicht-Punkte plus Plan, Modul 10 §Eingangs-Kontext):**
Commit-Range oben · betroffene Anforderungen `LH-FA-01`, `LH-FA-02`, `LH-FA-03`, `LH-FA-06`,
`LH-FA-07`, `LH-QA-01`, `LH-QA-02`, `LH-QA-03` · referenzierte **aktive** ADRs `0003`, `0007`,
`0011`, `0012`, `0013`, `0016` (alle Accepted) · Hard Rules `AGENTS.md` §3.1–§3.8 ·
**vorherige Findings am gleichen Modul:**
`docs/reviews/2026-08-16-adr-0020-bestaetigungsrunde.md` (Runde 1: 2 HIGH, 6 MEDIUM, 3 LOW,
1 INFO, blockiert) sowie
`docs/reviews/2026-08-15-adr-0019-bestaetigungsrunde{,-runde-2}.md` (dort das Muster, das diese
Runde ausdrücklich sucht: die Überarbeitung erklärte zwei Aussagen für ungemessen und benutzte
eine davon als Prämisse) · Plan-Bezug: `slice-062`, `slice-087`, `welle-09`, Roadmap, `CO-002`.

**Nicht meine Rolle, und darum nicht getan:** die DoD-Abhakung und die Gate-Lauf-Bestätigung
(Modul 10 §Anti-Pattern). Ich habe **nichts geändert und nichts committet**;
`git status --porcelain` war vor und nach dem Lauf leer. Alle Sonden liefen in einer
Wegwerf-Kopie **außerhalb** des Repos, danach gelöscht.

## Selbst gefahren — Kommando und Ergebnis, nichts davon übernommen

Nachbau der sprachlosen Init-Emission außerhalb des Repos (Aggregator aus
`internal/emit/makefile.go`, `d-check.mk`, `harness/mk/{baseline,doc-gate,enforce}.mk`, dazu
`harness/mk/go.mk` aus `internal/gen/golang.go` für die `--lang go`-Variante), Doku-Tische aus
`.harness/baseline/v3.5.2/templates/AGENTS.template.md` und `…/harness/README.template.md`,
`makefiles:` immer der Satz aus Festlegung 4(a), Modul `targets` allein, gepinntes Image
`ghcr.io/pt9912/d-check@sha256:fede3d02…`, `--network none`:

| Sonde | Fassung | Variante | Ergebnis (selbst gemessen) |
|---|---|---|---|
| A | Doku-Tisch wie heute emittiert | `--lang go` | `2 Datei(en) geprüft, 13 Befund(e)`, **Exit 1** — davon **4 falsch** (`lint`, `test` existieren in `harness/mk/go.mk`) |
| B | dieselbe | sprachlos | `13 Befund(e)`, Exit 1 — `diff` gegen A: **byte-gleich**, diesmal alle 13 wahr |
| C | Teil-Reparatur (nur die 5 nirgends existierenden Ansprüche entfernt) | `--lang go` | `4 Befund(e)`, Exit 1 — **alle vier falsch** |
| D | dieselbe | sprachlos | `4 Befund(e)`, Exit 1 — `diff` gegen C: **byte-gleich**, alle vier wahr |
| E | nur Init-invariante Ansprüche (`gates`, `help`) | `--lang go` | `0 Befund(e)`, **Exit 0** |
| F | dieselbe | sprachlos | `0 Befund(e)`, **Exit 0** |
| G/H | E/F **plus** Ansprüche auf `docs-check`, `baseline-verify`, `record-gates`, `doc-targets`, `doc-doctor` | beide | `0 Befund(e)`, Exit 0 — die Eigenschaft aus 4(e) ist **nicht** auf `gates`/`help` verengt |
| — | Teil-Reparatur mit `exempt-targets: [lint, test]` | sprachlos | unverändert `4 Befund(e)`, Exit 1 — die Ausnahmeliste greift nicht auf Richtung 1 |
| — | Annahme (b): `d-check.mk` aus `makefiles:` entfernt, `make docs-check` behauptet | `--lang go` | `AGENTS.md:176 docs-check gate-phantom` — das Modul folgt `include` **nicht** |
| — | Annahme (b): `makefiles: [Makefile, "harness/mk/*.mk"]` | — | `d-check: error: das Modul targets kann das Makefile "harness/mk/*.mk" nicht lesen (DC-FA-TGT-001, fail-closed)` |

Weiter selbst gefahren:

| Kommando | Ergebnis |
|---|---|
| `make docs-check` | `d-check: 322 Datei(en) geprüft, 0 Befund(e)`, Exit 0 |
| `docker run --rm --network none <d-check@digest> --print-config` | der `targets:`-Block ist Zeichen für Zeichen der in der ADR (`:228-232`) zitierte |
| `grep -hoE '\`make [a-z][a-z0-9-]*\`' <die zwei Doku-Vorlagen>` | **20 Nennungen**, **9 verschiedene** Ziele; `gates` 5×, `help` 1× — die Zählung `20/9/2/7` der ADR und von `slice-087` ist korrekt |
| `grep -rnoE '^(coverage-gate\|fullbuild\|ci\|arch-check):' internal/gen internal/emit` | kein Treffer — **mit Positivkontrolle**: derselbe Ausdruck mit `(test\|lint\|build)` findet `internal/gen/golang.go:918,921,924` und `internal/gen/cpp.go:617,620,623` |
| `grep -rn "verify-closure-notes" --include='*.go' --include='*.mk' --include='*.sh' --include='Makefile' .` | **0 Zeilen**, rc 1 |
| `grep -rn "claude/agents" --include=*.go .` bzw. über beide Vorlagen-Bäume | je **null** Treffer |
| `grep -n "targets" internal/emit/templates/d-check.yml` | rc 1 — die emittierte Konfiguration führt keinen Block |

**Gelesen, nicht gefahren** (Fundort statt Messung): `internal/span/span.go:1-30,76-90,136-163` ·
`internal/span/span_test.go:53-56` · `internal/span/emit.go:184` · `internal/span/response.go:55-90` ·
`.claude/settings.json:3-53` · `harness/tools/extract-agent-call.awk:21,73,86,109-120` ·
`harness/tools/full-smoke.sh:42-43,155-205,211-213` · `internal/emit/templates.go:12-24,140-200,322-350` ·
`internal/emit/templates_test.go:114,246` · `internal/emit/makefile.go:1-50` ·
`internal/emit/baseline.go:28-40` · `internal/emit/enforce.go:40-58` ·
`internal/emit/enforce_test.go:20-58` · `internal/emit/archgate.go:55-84` ·
`internal/gen/golang.go:907-928` · `docs/plan/adr/0011-telemetrie-erfassung-policy.md:58-62,100-112,176-196,223-262` ·
`docs/plan/adr/0012-haupt-kontext-ohne-token-bilanz.md:1-60` ·
`docs/plan/carveouts/CO-002-token-achse-je-rolle.md:1-125` ·
`docs/plan/planning/done/slice-059-telemetrie-erfassung-hook.md:149-157` ·
`.harness/baseline/v3.5.2/regelwerk/modul-07-carveouts.md:46-93` ·
`…/modul-13-quality-gates.md:51-57` · `…/modul-15-observability.md:75-85` · `AGENTS.md:81-114`.

---

## Findings

### HIGH-1 — Ausgang 3 der neuen Fünfer-Abzählung ist im selben Repo widerlegt, und die Gegenaussage steht als Kommentar über der Funktion, um die es geht

- **kategorie:** HIGH
- **quelle:** `AGENTS.md` §3.6 (*„Richtig: die Zusage auf das einschränken, was der Code hält"*);
  `LH-QA-02`; Regelwerk `v3.5.2`, `modul-07-carveouts.md` §Werkzeug-Wahl bei Diskrepanz (Frage 2)
- **pfad:** `docs/plan/adr/0020-emittierte-modul-15-regeln.md:173-177`, mitgetragen von
  `:327-328`, `:522` (Option F), `docs/plan/adr/README.md:28`,
  `docs/plan/planning/open/slice-062-emittierte-modul-15-regeln.md:220-222`,
  `docs/plan/planning/welle-09-modul-15-konformitaet.md:246-248` und
  `docs/plan/planning/in-progress/roadmap.md:102` — gegen `internal/span/span.go:140-150` und
  `:82` sowie `.claude/settings.json:35-41`
- **befund:** Ausgang 3 lautet: *„Der polymorphe Wert ist `error` — also genau die Unterscheidung
  gelungen/fehlgeschlagen. Ohne sie meldet der Span `ok` für einen fehlgeschlagenen Aufruf … Ein
  kleineres Schema für das Ziel ist damit **kein** Ausweg: das Feld, das den Parser braucht, ist
  das einzige, das nicht wegfallen kann."* Der Code dieses Repos sagt das Gegenteil, und er sagt
  es ausdrücklich: `func failed(raw map[string]json.RawMessage, event string) bool` beginnt mit
  `if strings.Contains(event, "Failure") { return true }`, und der Kopfkommentar darüber lautet
  verbatim *„failed entscheidet den Status aus ZWEI Quellen … Dazu das Ereignis selbst: ein
  Fehlschlag-Event ist auch ohne `error`-Feld ein Fehlschlag. Bewacht von
  TestFailedStatusFromErrorShapes."* Die zweite Quelle ist `hook_event_name` — ein
  **Top-Level-String** (`Event: rawString(raw, "hook_event_name")`, `span.go:82`), also genau die
  Form, an der die awk-Fassung **nicht** gescheitert ist. Und die Ereignis-Achse existiert real:
  `.claude/settings.json` verdrahtet `PostToolUseFailure` als eigenes Ereignis. Die ADR erklärt
  damit eine Unmöglichkeit, die ihr eigener, testbewachter Code widerlegt.
- **gegenbeispiel:** Jemand nimmt Ausgang 3 beim Wort und baut für die emittierte Ebene ein
  Schema ohne `error`, das den Status aus `hook_event_name` ableitet. Es meldet für einen
  `PostToolUseFailure`-Aufruf **nicht** `ok`; der Ausgang, den die ADR für geschlossen erklärt,
  ist offen. Frage 2 fällt dann nicht mehr an fünf abgezählten Ausgängen auf *Nein* — und die ADR
  hält selbst fest (`:537-538`), dass *„jeder einzelne widerlegbar"* ist, also material. Nach
  `AGENTS.md` §3.4 ist die Zeile ab *Accepted* nicht mehr korrigierbar, und mit ihr die drei
  Matrix-Werte, die auf ihr ruhen.
- **verifizierbar:** ja, ohne Gate-Lauf — `sed -n '140,150p' internal/span/span.go` gegen
  `sed -n '173,177p' docs/plan/adr/0020-emittierte-modul-15-regeln.md`; die Ereignis-Achse an
  `grep -n PostToolUseFailure .claude/settings.json`. **Maschinell nicht bewacht:** `.d-check.yml`
  führt `links, anchors, ids, matrix, codepaths, spans`; kein Modul prüft, ob eine
  Unmöglichkeits-Aussage trägt.

### HIGH-2 — Festlegung 4(e) quantifiziert über *„ein emittiertes Dokument"*, gemessen sind zwei; ein drittes emittiertes Dokument behauptet ein Ziel, das in keiner Bootstrap-Variante existiert

- **kategorie:** HIGH
- **quelle:** `LH-QA-01` (erste Hälfte: *„Jeder emittierte Gate-Target läuft auf frischem
  Checkout"*); `AGENTS.md` §3.6
- **pfad:** `docs/plan/adr/0020-emittierte-modul-15-regeln.md:427-436` (4(e)), `:239-266`
  (Anspruchs-Messung und Sonden A–F), `:560-571` (Folgepflicht 2) und
  `docs/plan/planning/open/slice-087-emittierte-doku-tische-init-invariant.md:46-54,78-96` —
  gegen `.harness/baseline/v3.5.2/templates/.harness/skills/closure-note-reviewer.template.md:15`
  und `:26`, `internal/emit/templates.go:142-149` und `:322-350`,
  `internal/emit/templates_test.go:114,246`
- **befund:** 4(e) formuliert die Eintritts-Bedingung der Emission über **jedes** emittierte
  Dokument (*„solange **ein emittiertes Dokument** ein `make`-Ziel behauptet, das in irgendeiner
  Variante der emittierenden Phase fehlt"*). Gemessen — im Text (`:241-243`), in den sechs Sonden
  und in `slice-087` — sind aber ausschließlich die **zwei** Doku-Tische. Ein drittes emittiertes
  Dokument fällt durch: `.harness/skills/closure-note-reviewer.template.md` ist in-scope
  (`internal/emit/templates.go:142-149`, Zielpfad `.harness/skills/closure-note-reviewer.md` in
  `templates_test.go:114,246`), `StripHintBlock` entfernt nur den führenden
  `> **Template-Hinweis.**`-Blockquote, und die zwei Nennungen **außerhalb** davon überleben:
  Zeile 15 (*„Gilt für: den inferentiellen Nachlauf zu `make verify-closure-notes`"*) und Zeile 26
  (*„das Ergebnis von `make verify-closure-notes` für denselben Stand — was das **Struktur-Gate**
  bereits abgedeckt hat"*, im Abschnitt *Kontext-Eingang (Pflicht)* — *„Was der Reviewer immer
  mitbringt"*). `grep -rn "verify-closure-notes" --include='*.go' --include='*.mk'
  --include='*.sh' --include='Makefile' .` liefert **0 Zeilen**: das Ziel existiert in keiner
  Variante. Damit steht dieselbe Klasse — behauptetes Gate ohne Deckung im emittierten Artefakt —
  außerhalb der Menge, die der Fix vermessen und der Plan geschnitten hat; `slice-087` §3
  listet als einzige Änderung `internal/emit/templates.go` für die zwei Doku-Tische, und sein
  Wächter (DoD (2)) prüft ausdrücklich *„jede `make`-Nennung der **zwei Doku-Tische**"*.
- **gegenbeispiel:** `slice-087` schließt, sein Wächter ist grün, `slice-063` liest 4(e) als
  erfüllt und emittiert den `targets:`-Block. Das gebootstrappte Ziel trägt weiterhin eine
  emittierte Datei, die `make verify-closure-notes` als *Struktur-Gate* benennt und sein Ergebnis
  als Pflicht-Eingang verlangt — ein Kommando, das dort niemals läuft. Entweder war die Bedingung
  aus 4(e) nie erfüllt (dann hätte `slice-063` nicht eintreten dürfen), oder sie sagt mehr, als
  irgendjemand gemessen hat. Beides ist nach `AGENTS.md` §3.4 ab *Accepted* nicht mehr
  korrigierbar. Der Träger selbst schweigt dazu — `doc-tables:` nennt nur die zwei Tische —,
  der Befund ist also **still**: genau die `LH-QA-01`-Falle, gegen die die Vorarbeit geschnitten
  wurde.
- **verifizierbar:** ja, ohne Gate-Lauf —
  `grep -n 'make verify-closure-notes' .harness/baseline/v3.5.2/templates/.harness/skills/closure-note-reviewer.template.md`
  gegen `grep -rn verify-closure-notes --include='*.go' --include='*.mk' --include='*.sh' --include='Makefile' .`;
  die Emissions-Zusage an `internal/emit/templates_test.go:114`.

### MEDIUM-1 — *„keiner steht in unserer Hand"* ist für vier der fünf Ausgänge falsch, und das importierte `CO-002`-Kriterium setzt genau diese Aussage voraus

- **kategorie:** MEDIUM
- **quelle:** `AGENTS.md` §3.6; Regelwerk `v3.5.2`, `modul-07-carveouts.md` §Werkzeug-Wahl
  (Frage 2)
- **pfad:** `docs/plan/adr/0020-emittierte-modul-15-regeln.md:164`, `:212-216` gegen `:166-186`
  und `docs/plan/carveouts/CO-002-token-achse-je-rolle.md:94-108`
- **befund:** Die Abzählung wird eingeleitet mit *„Damit sind die Ausgänge abzählbar, und **keiner
  steht in unserer Hand**"*. Von den fünf steht Ausgang 2 (*„den Emitter fail-closed machen"*,
  eine Änderung an unserer eigenen `ADR-0011` Festlegung 6), Ausgang 3 (Schema-Zuschnitt),
  Ausgang 4 (*„roh speichern"*, unsere `ADR-0011` Festlegung 2) und Ausgang 5 (die von uns
  gesetzte Container-Start-Grenze) sehr wohl in unserer Hand; fremd ist allein, was **nach** der
  Abzählung übrig bleibt. Das ist nicht nur Rhetorik: die Antwort auf Frage 2 wird ausdrücklich
  aus `CO-002` übernommen (*„`CO-002` hält für seinen eigenen Fall fest, dass die Antwort kippt
  auf Nein, sobald **nur noch fremde Wege** übrig sind. Hier sind von Anfang an nur fremde Wege
  übrig"*), und `CO-002` zählt seine drei Wege ausdrücklich danach ab, ob sie *„in unserer Hand"*
  liegen. Die Prämisse des importierten Kriteriums gilt hier nicht. Derselbe Unterschied trennt
  den Fall vom benannten Präzedenzfall: `ADR-0012` ruht auf einer Abwesenheit im fremden Vertrag
  (*„es gibt kein Ereignis, an dem seine Token anfielen, und keine Payload, die sie trüge"*,
  `0012-…:52-56`), diese Entscheidung überwiegend auf eigenen Setzungen.
- **gegenbeispiel:** Ein Folge-Lauf prüft die Permanenz gegen `CO-002`s Maßstab, findet drei
  eigene Wege statt lauter fremder und schließt, das Kriterium sei falsch angewandt — obwohl die
  Entscheidung unter dem *Wortlaut* von Modul 7 (*„nichts davon werden wir in absehbarer Zeit
  tun"*) tragfähig bliebe. Der Satz, der sie tragen soll, ist stärker als die Sache, die er trägt,
  und ab *Accepted* nicht mehr abschwächbar.
- **verifizierbar:** ja, ohne Gate-Lauf — `sed -n '164,186p'` der ADR gegen
  `sed -n '94,108p' docs/plan/carveouts/CO-002-token-achse-je-rolle.md`.

### MEDIUM-2 — Ein sechster Weg fällt durch das Raster: Ausgang 1 und Ausgang 2 sind einzeln geschlossen, ihre Kombination nicht — und die Schließung stammt aus einer Policy, die dieselbe Festlegung nicht auf die emittierte Ebene erstreckt

- **kategorie:** MEDIUM
- **quelle:** `AGENTS.md` §3.6; `LH-QA-02`
- **pfad:** `docs/plan/adr/0020-emittierte-modul-15-regeln.md:166-172` gegen `:333-335` und
  `internal/emit/enforce.go:56-57`, `harness/tools/extract-agent-call.awk:109-120`,
  `docs/plan/planning/done/slice-059-telemetrie-erfassung-hook.md:155-157`
- **befund:** Ausgang 1 (handgeführter Scanner) fällt, weil *„fail-open gegen Stille keine
  Kompensation hat"*; Ausgang 2 (fail-closed) fällt, weil er `ADR-0011` Festlegung 6 änderte. Die
  **Kombination** — ein handgeführter Scanner, der fail-closed läuft — ist von keinem der beiden
  Ausgänge getroffen: der erste scheitert nur *unter* fail-open, der zweite nur an einer Policy,
  von der dieselbe Festlegung 130 Zeilen später sagt: *„Was `ADR-0011` für den Dogfood entschieden
  hat, ist damit **nicht automatisch ein Adopter-Vertrag**"* (`:334-335`). Dieselbe
  Ebenen-Trennung steht bereits in `slice-059` (*„sie schließt Laufzeiten aus, die ein **Adopter**
  installieren müsste — für die Dogfood-Seite bindet sie nicht"*). Der Baum führt die Bauart
  emittiert vor: `internal/emit/enforce.go` emittiert `tools/harness/extract-command.awk`, einen
  handgeführten POSIX-awk-Scanner auf einer Hook-Payload, der bei Zweifel fail-closed endet — die
  ADR nennt diese Betriebsart als **Kontrast** (`:145-149`), prüft sie aber nirgends als
  **Option** für die emittierte Ebene.
- **gegenbeispiel:** Ein Folge-Schnitt schlägt für Ziel-Repos einen minimalen, fail-closed
  awk-Erfassungshook vor und beruft sich darauf, dass `ADR-0011` den Dogfood regelt, nicht das
  Ziel — die Sätze dazu stehen in `ADR-0020` selbst. Er muss dann keinen der fünf Ausgänge
  widerlegen, weil ihn keiner trifft; die Abzählung, die Frage 2 auf *Nein* gebracht hat, war
  nicht vollständig. Ob dieser Weg gewollt ist, ist eine Architektur-Frage — sie ist hier weder
  beantwortet noch gestellt.
- **verifizierbar:** ja, ohne Gate-Lauf — `sed -n '166,172p;333,335p'` der ADR gegen
  `sed -n '40,58p' internal/emit/enforce.go`.

### MEDIUM-3 — Frage 1 ist erstmals zitiert, aber nur einer ihrer zwei Auslöser ist beantwortet, und das Zitat endet vor dem Satz, der den anderen scharf macht

- **kategorie:** MEDIUM
- **quelle:** Regelwerk `v3.5.2`, `modul-07-carveouts.md` §Werkzeug-Wahl bei Diskrepanz (Frage 1
  und die Symptom-Tabelle); `ADR-0016` Festlegung 2/3(a)
- **pfad:** `docs/plan/adr/0020-emittierte-modul-15-regeln.md:196-207` und
  `docs/plan/adr/README.md:28` gegen
  `.harness/baseline/v3.5.2/regelwerk/modul-07-carveouts.md:54-62,69-73`
- **befund:** Frage 1 nennt **zwei** durch *oder* verbundene Auslöser der BF-Markierung:
  *„**Cluster im selben Geltungsbereich** (mehrere Ausnahmen auf denselben Pfad/dieselbe
  Sub-Area) **oder** systemisches „Code existiert vor Doku"-Muster"*. Die ADR entkräftet mit
  ihrem ersten Grund ausschließlich den **zweiten** Auslöser (*„das Symptom-Muster ist
  invertiert — hier existiert die Doku vor dem Code"*), obwohl der Fall genau die Gestalt des
  ersten hat: drei Nicht-Emissionen mit identisch angegebenem Geltungsbereich (*„die emittierte
  Ebene, jede Bootstrap-Variante"*, `:310`). Der Satz, den das Zitat weglässt, ist derjenige, der
  die naheliegende Verteidigung („drei sind kein Cluster") ausschließt: *„**Kein harter
  Schwellwert** für „Cluster" — Faustregel (gemeinsamer Geltungsbereich), keine Carveout-Zahl."*
  Getragen wird die Antwort damit allein vom **zweiten** Grund (der Adaptions-Block registriert
  Abweichungen *dieses* Repos), den der Text jedoch als einen von *„zwei Gründen, die **beide am
  Symptom** hängen"* einführt — er hängt am Träger, nicht am Symptom. Die Index-Zeile verdichtet
  auf dieselbe halbe Antwort (*„Symptom invertiert: Doku vor Code, und die emittierte Ebene ist
  keine Sub-Area dieses Repos"*).
- **gegenbeispiel:** Nach der Re-Baseline liest jemand die dann immutable ADR gegen das Modul und
  fragt, warum drei Ausnahmen desselben Geltungsbereichs kein Cluster sind. Er findet im Artefakt
  keinen Satz dazu — nur die Antwort auf den anderen Auslöser und ein Zitat, das vor der
  Faustregel endet. Genau dieser Fall ist der Grund, aus dem `ADR-0016` das Verbatim-Zitat
  verlangt.
- **verifizierbar:** ja, ohne Gate-Lauf — `sed -n '196,207p'` der ADR gegen
  `sed -n '54,73p' .harness/baseline/v3.5.2/regelwerk/modul-07-carveouts.md`.

### MEDIUM-4 — ADR und Plan nummerieren die zwei Glieder derselben Konjunktion gegenläufig, und die ADR widerspricht dabei ihrer eigenen Aufzählung

- **kategorie:** MEDIUM
- **quelle:** `LH-QA-02`; `AGENTS.md` §3.4 (die Fassung wird unveränderlich)
- **pfad:** `docs/plan/adr/0020-emittierte-modul-15-regeln.md:355-359`, `:361-362`, `:614-619`
  gegen `docs/plan/planning/open/slice-062-emittierte-modul-15-regeln.md:243-246`
- **befund:** Die ADR schreibt die Konjunktion in der Reihenfolge *„**Zähler** und **Erfassung**
  im Ziel"* und fährt fort: *„und ihr **erstes** Glied ist nach Festlegung 1 permanent
  verschlossen"* — Festlegung 1 verschließt aber die **Erfassung**, das zweitgenannte Glied.
  Neun Zeilen später heißt es *„Er [`CO-002`] ist die **Vorbedingung** des **zweiten** Glieds"*,
  und der Re-Evaluierungs-Trigger (`:616-618`) bestätigt diese zweite Zählung (*„trägt ein
  `Agent`-Span wieder Rolle und Zähler, ist das **zweite** Glied … offen — das erste bleibt es
  nach Festlegung 1"*). `slice-062` liest exakt umgekehrt: *„Das **zweite** Glied ist nach dem
  Obigen permanent verschlossen … `CO-002` ist die **Vorbedingung des ersten Glieds**"*. Damit
  gibt es zu derselben Konjunktion drei Zählungen — die Aufzählungsreihenfolge der ADR, ihre
  Ordinalverweise und die des Plans —, und zwei davon widersprechen einander.
- **gegenbeispiel:** `CO-002` löst sich auf, jemand liest die dann immutable ADR wörtlich:
  *Zähler und Erfassung; das erste Glied ist nach Festlegung 1 permanent verschlossen.* Er
  schließt daraus, die **Zähler**-Seite sei permanent entschieden — und hat damit einen aktiven
  Carveout mit ernst erreichbarem Trigger für permanent erklärt, ohne dass eine ADR das je
  entschieden hätte. Genau diese Verwechslung sollte die Trennung *Vorbedingung ≠ Trigger*
  verhindern.
- **verifizierbar:** ja, ohne Gate-Lauf — `sed -n '352,362p;614,619p'` der ADR gegen
  `sed -n '243,251p' docs/plan/planning/open/slice-062-emittierte-modul-15-regeln.md`.

### MEDIUM-5 — `slice-062` §3 begründet den Verzicht auf das Lastenheft weiterhin mit Auflösungs-Triggern, die derselbe Slice zwei Seiten vorher abgeschafft hat

- **kategorie:** MEDIUM
- **quelle:** `LH-QA-02`; `welle-09` §3 (Wert-Tabelle: *ADR-Verdikt* ist *„**ohne**
  Auflösungs-Trigger"*)
- **pfad:** `docs/plan/planning/open/slice-062-emittierte-modul-15-regeln.md:188-193` gegen
  `:81-88`, `:207-232` und `docs/plan/adr/0020-emittierte-modul-15-regeln.md:60-63`
- **befund:** Der Absatz *„Warum die drei Nicht-Emissionen ohnehin nicht ins Lastenheft gehören"*
  lautet unverändert: *„**Jede von ihnen trägt einen Auflösungs-Trigger**; das Lastenheft ist das
  vertraglich abnahmebindende Stratum, und eine Vertragsklausel auf Zeit ist ein Widerspruch in
  sich … eine begründete, **mit Trigger versehene** Nicht-Umsetzung gehört in die ADR."* Nach dem
  Schnitt derselben Datei trägt **keine** der drei einen Auflösungs-Trigger — das ist die
  Definition des Werts, den sie jetzt führen. Der Architect hat genau diesen Satz in der ADR
  nachgezogen (`:60-63`: *„eine **permanente Nicht-Umsetzung** ist in einem abnahmebindenden
  Stratum ein Widerspruch in sich"*), der Planner in `slice-062` nicht.
- **gegenbeispiel:** Der Verifikations-Lauf prüft die DoD-Zusage *„für jede ist der Trichter beide
  Fragen weit beantwortet"* und liest im selben Dokument, jede Nicht-Emission trage einen
  Auflösungs-Trigger. Er kann nicht entscheiden, ob der Slice drei ADR-Verdikte oder drei
  getriggerte Nicht-Emissionen bestellt — und beide Lesarten stehen in derselben Datei.
- **verifizierbar:** ja, ohne Gate-Lauf — `sed -n '188,193p'` gegen `sed -n '81,88p'` derselben
  Datei.

### MEDIUM-6 — Die Fitness Function beschreibt die Messmethode falsch: `full-smoke` fährt heute zwei Bootstrap-Varianten, nicht eine

- **kategorie:** MEDIUM
- **quelle:** `LH-QA-02` (Reproduzierbarkeit einer Messmethode); `LH-QA-01`
- **pfad:** `docs/plan/adr/0020-emittierte-modul-15-regeln.md:596` gegen
  `harness/tools/full-smoke.sh:42-43`, `:155`, `:211-213` und
  `docs/plan/planning/open/slice-087-emittierte-doku-tische-init-invariant.md:171-176`
- **befund:** Die `make full-smoke`-Zeile verlangt *„null Befunde in **beiden**
  Bootstrap-Varianten"* und schließt mit *„heute fährt der Voll-Smoke **eine** Variante"*. Das
  Skript bootstrappt zwei tmp-Repos — `--lang go` (`:42-43`) und sprachlos (`:155`) — und prüft
  den sprachlosen Zustand in `:155-205` ausdrücklich; erst danach fährt es `add-lang go`
  (`:211-213`). Die reale Lücke ist also nicht die fehlende zweite Variante, sondern die
  **Platzierung**: ein Zahn nach `:211` misst die sprachlose Variante nie. Genau so steht es im
  Plan (`slice-087` §6: *„bootstrappt zwei Repos … fährt aber im sprachlosen anschließend
  `add-lang go`"*); die ADR verdichtet es zu einer anderen Aussage.
- **gegenbeispiel:** Der Implementer von `slice-063` liest die Fitness Function, hält eine zweite
  Bootstrap-Variante für fehlend und baut ein drittes tmp-Repo, statt den vorhandenen sprachlosen
  Zweig **vor** `add-lang` zu bezahnen. Der Beleg deckt danach dieselbe Variante zweimal und die
  sprachlose weiterhin nie — die Varianten-Klammer, ohne die wahr und falsch nach Sonde C/D
  byte-gleich sind, fehlt trotz grüner Zusage.
- **verifizierbar:** ja — `grep -n 'tmprepo_doc\|add-lang go' harness/tools/full-smoke.sh` gegen
  `sed -n '596p'` der ADR.

### LOW-1 — `slice-062` §4 verweist auf „T1", eine Kennung, die in keinem lebenden Artefakt mehr definiert ist

- **kategorie:** LOW
- **quelle:** Maintainability; `LH-QA-02`
- **pfad:** `docs/plan/planning/open/slice-062-emittierte-modul-15-regeln.md:294` gegen
  `docs/plan/adr/0020-emittierte-modul-15-regeln.md` (kein Treffer für `T1`/`T2`/`T3`)
- **befund:** Die Rückführung lautet *„falls einer der fünf abgezählten Ausgänge zu **T1**
  währenddessen fällt"*. Der Abschnitt, der T1/T2/T3 definierte, ist mit `07fe9b7` aus der ADR
  entfallen; `grep -rn '\bT1\b'` über ADR, Index, `slice-062`, `slice-087`, `welle-09`, Roadmap
  und `CO-002` liefert genau diese eine Zeile.
- **gegenbeispiel:** Wer die Rückführung auslösen will, sucht die Definition von T1 und findet
  sie nirgends; die Bedingung ist nur noch aus dem Kontext erratbar.
- **verifizierbar:** ja — `grep -rn '\bT1\b' docs/plan/`.

### LOW-2 — Die Abzählung zitiert von zwei gemessenen Gründen gegen die awk-Fassung nur einen

- **kategorie:** LOW
- **quelle:** `AGENTS.md` §3.6 (*„benennen, was wirklich deckt"*)
- **pfad:** `docs/plan/adr/0020-emittierte-modul-15-regeln.md:166-168` gegen
  `docs/plan/planning/done/slice-059-telemetrie-erfassung-hook.md:149-157`
- **befund:** Ausgang 1 stützt sich allein auf das `error`-Fehlerbild. `slice-059` führt einen
  zweiten, unabhängig gemessenen Grund: *„Dazu **21 externe Aufrufe je Span** (gemessen) gegen
  **einen** Prozess-Start."* Er ist von HIGH-1 unberührt und trüge Ausgang 1 auch dann, wenn das
  Schema-Argument fällt — die ADR lässt ihn liegen und macht ihren einzigen Beleg dadurch
  angreifbarer, als die Sache ist.
- **gegenbeispiel:** Fällt das Schema-Argument (HIGH-1), fällt Ausgang 1 in der ADR-Fassung
  vollständig, obwohl der Kostengrund unberührt weitergilt — die Entscheidung sieht schwächer aus,
  als ihr eigenes Quellmaterial hergibt.
- **verifizierbar:** ja, ohne Gate-Lauf — `sed -n '149,157p' docs/plan/planning/done/slice-059-telemetrie-erfassung-hook.md`.

### INFO-1 — Die Eigenschaft aus 4(e) ist weiter als ihre Illustration, und keine Stelle sagt es

- **kategorie:** INFO
- **quelle:** `welle-09` §3; Maintainability
- **pfad:** `docs/plan/adr/0020-emittierte-modul-15-regeln.md:243-245`, `:432-434` und
  `docs/plan/planning/open/slice-087-emittierte-doku-tische-init-invariant.md:53-54`
- **befund:** Alle drei Stellen illustrieren *Init-invariant* an genau zwei Namen (`gates`,
  `help`) — korrekt, denn nur diese zwei stehen unter den neun behaupteten Zielen. Die Menge ist
  jedoch größer: selbst gemessen (Sonden G/H) bleiben auch Ansprüche auf `docs-check`,
  `baseline-verify`, `record-gates`, `doc-targets` und `doc-doctor` in **beiden** Varianten
  befundfrei, weil `Makefile`, `d-check.mk`, `baseline.mk` und `enforce.mk` sie definieren und
  alle vier in 4(a) genannt sind. Die Formulierungen sind als **Eigenschaft** geschrieben und
  driften daher nicht — aber ein Umsetzer, der die Neutralisierung nach den zwei Beispielen baut,
  streicht mehr als nötig.
- **gegenbeispiel:** `slice-087` streicht die Gate-Tabelle auf `gates`/`help` zusammen, obwohl ein
  Verweis auf `make docs-check` dem Adopter mehr sagt und die Invariante nicht verletzt.
- **verifizierbar:** nein (Lesbarkeits-/Vollständigkeits-Befund; die Eigenschaft selbst ist von
  DoD (2) in `slice-087` bewacht).

---

## Status der Runde-1-Befunde — je Befund ausdrücklich

| Runde-1 | Status | Beleg dieser Runde |
|---|---|---|
| **HIGH-1** (Analogie als Prämisse für *nicht emittiert*) | **aufgelöst** — nicht entkräftet, sondern **entschieden** | Die slice-059-Messung steht verbatim (`:139-143`, gegen `internal/span/span.go:5-11` gehalten: wortgleich). Der awk-Extraktor ist als andere Payload **und** andere Betriebsart benannt; `exit 3` an vier Stellen von `extract-agent-call.awk` selbst gelesen. Frage 2 fällt auf *Nein*, drei Zellen tragen *ADR-Verdikt*. **Die Ableitung im Indikativ ist an dieser Stelle weg — sie ist in die neue Abzählung gewandert (HIGH-1 dieser Runde).** |
| **HIGH-2** (Datei-Satz lässt echte Targets als Phantome melden) | **teilaufgelöst** | Der Konflikt ist über den Anspruchs-Weg gelöst, und er trägt: Sonden E/F selbst nachgefahren, `0 Befund(e)`/Exit 0 in **beiden** Varianten; Sonde C/D selbst nachgefahren, `4 Befund(e)` und `diff` byte-gleich — die Messreihe des Architect ist reproduziert. 4(c) erklärt die Werkzeug-Hälfte ausdrücklich zu **unserer** Pflicht (*„kein Adopter-Belang und wird auch nicht als solcher geführt"*), `slice-087` ist geschnitten und Wellen-Mitglied. **Offen:** die Anspruchsmenge ist erneut nur an zwei Dokumenten vermessen (HIGH-2 dieser Runde). |
| **MEDIUM-1** (4(e) variantenblind) | **aufgelöst** | 4(e) quantifiziert jetzt über *„irgendeiner Variante"*, beziffert sieben/fünf und begründet die Zahl mit Sonde C/D. Folgepflicht 2 trägt dieselbe Formel. |
| **MEDIUM-2** (`CO-002` als Auflösungs-Trigger) | **aufgelöst** in der Sache | ADR `:361-371`, `slice-062` `:243-251` und `welle-09` §3 sagen übereinstimmend: **Vorbedingung**, kein Trigger; die Zelle zeigt auf die *Frage*, beide Ausgänge sind Re-Evaluierungs-Trigger. `CO-002` selbst nennt weder `ADR-0020` noch eine Tool-Zelle — der Carveout behauptet nirgends, dass Tool-Zellen an ihm hängen (selbst gelesen, ganze Datei). **Neu entstanden:** die gegenläufige Glied-Nummerierung (MEDIUM-4). |
| **MEDIUM-3** (Beleg ohne Zitat) | **aufgelöst, beide Instanzen** — die „nur an der Kernstelle"-Falle ist vermieden | Frage 1 **und** Frage 2 stehen jetzt mit Tag/Datei/Abschnitt/Zitat (`:196-210`), und der ADR-Pfad-Satz ebenfalls (`:218-219`). Auch die zweite, schwächere Instanz ist repariert: 5(c) trägt `v3.5.2`, `modul-15-observability.md` §Doku-Konsistenz-Drift-Regeln **plus Zitat**. Alle vier Regelwerks-Zitate gegen den vendored Baum gehalten — wortgleich. **Rest:** das Frage-1-Zitat endet vor der Faustregel (MEDIUM-3 dieser Runde). |
| **MEDIUM-4** („der einzige denkbare Sensor … existiert nicht") | **aufgelöst** | Der Satz ist ersetzt: *„heute bewacht kein Sensor die drei Abwesenheiten — **aber ein Sensor ist baubar**"*, mit `internal/emit/enforce_test.go` als Präzedenz (selbst gelesen: `os.Stat` auf `tools/harness/blocked` nach `Enforce`, `t.Errorf`), als **Folgepflicht 6** geführt und in der Fitness Function als *geschuldet, nicht geliefert* geführt. |
| **MEDIUM-5** (Closure hängt an einem Nicht-Mitglied) | **aufgelöst** | `slice-087` ist geschnitten, liegt in `open/`, ist Mitglied von `welle-09` §4, hat einen Eintritts-Trigger (*„keiner"* — ohne Wartestellung hinter `slice-062`) und ist in Roadmap und `welle-09` §6 nachgezogen. Die Reihenfolge 062 → 087 → 063 steht an vier Orten gleichlautend. |
| **MEDIUM-6** (Bau auf einer *Proposed* ADR) | **aufgelöst** | `grep -n 0019` über die ADR liefert genau **eine** Zeile, den neuen Block *„Nicht tragend, und darum ausdrücklich benannt"* (`:48-54`). Folgepflicht 5 nennt `ADR-0019` nicht mehr; die Index-Zeile führt in der Bezug-Spalte jetzt `ADR-0012` statt `ADR-0019`. Die zwei Null-Messungen, auf denen Festlegung 2 steht, habe ich selbst nachgefahren — beide null. |
| **LOW-1** („T3 enthält T1") | **aufgelöst** | Der T1/T2/T3-Abschnitt ist entfallen; die Kopplung steht jetzt als Re-Evaluierungs-Trigger *„auf welchem Weg auch immer"* (`:610-613`). **Rest:** eine verwaiste Kennung im Plan (LOW-1 dieser Runde). |
| **LOW-2** (zwei von drei Argumenten tragen nicht) | **aufgelöst** | Festlegung 6 führt die zwei widerlegten Argumente nicht mehr; es bleiben der Prüfbereichs-Einwand, die Namenslisten-Schrumpfung und das neue `LH-FA-06`-Argument. Auch die Index-Zeile ist nachgezogen (vorher *„die gebrauchte Toolchain ist unsere"*, jetzt der Prüfbereichs-Einwand). |
| **LOW-3** (Lebenszyklus „auf Abruf") | **aufgelöst** | 5(c) setzt **Pre-integration** — einen der drei vom Modul angebotenen Werte — und benennt die Lücke (kein `verify:` im Ziel) samt eigenem Re-Evaluierungs-Trigger. |
| **INFO-1** (Präzedenz der Nachbarspalte nicht unterschieden) | **aufgelöst** | 5(a) nennt das unterscheidende Merkmal ausdrücklich: der ausgeschlossene Kandidat *„kann nichts rot färben"*, `doc-targets` hat Befund-Ausgang und Exit 1. |

---

## Negativbefunde — geprüft, ohne Befund

- **Die sechs Sonden des Architect sind reproduziert.** A/B/C/D/E/F selbst gefahren, dazu die
  `exempt-targets`-Sonde: alle Zahlen und beide Byte-Gleichheiten stimmen. Die Behauptung
  *„13 Befunde, davon 4 falsch · Teil-Reparatur 4 Befunde, alle falsch · byte-gleich ·
  `exempt-targets` wirkungslos · invarianter Tisch 0 in beiden Varianten"* ist gemessen, nicht
  übernommen.
- **Die Init-Invarianz-Definition trägt weiter als ihre Illustration — und die Illustration ist
  richtig.** Von den neun behaupteten Zielen sind genau zwei init-invariant. Andere
  Init-Ziele (`docs-check`, `baseline-verify`, `record-gates`, `doc-targets`, `doc-doctor`) sind
  ebenfalls zulässig (Sonden G/H, `0 Befund(e)` in beiden Varianten) — 4(e) ist als
  **Eigenschaft** formuliert und schließt sie nicht aus. Weder ADR noch `slice-087` verengen auf
  `gates`/`help` (Details als INFO-1).
- **Der Fünfer-Datei-Satz aus 4(a) deckt jedes init-invariante Ziel.** `Makefile` (`gates`,
  `help`, `record-gates`-Kante), `d-check.mk` (`docs-check`, `doc-*`), `baseline.mk`
  (`baseline-verify`), `enforce.mk` (`record-gates`-Rezept), `doc-gate.mk` — aus dem Code gelesen,
  kein sechster Init-Emitter mit Make-Regeln.
- **Annahme (b) ist real.** Selbst gemessen: das Modul folgt `include` nicht (ungenanntes
  `d-check.mk` ⇒ `docs-check gate-phantom`) und nimmt keine Globs (`DC-FA-TGT-001, fail-closed`).
- **Der `targets:`-Block ist verbatim.** Aus dem gepinnten Image gedruckt, Zeichen für Zeichen
  identisch mit `:228-232`, inklusive Kommentarspalte.
- **Die Zählung `20 / 9 / 2 / 7` stimmt.** Selbst nachgezählt, mit und ohne Backtick-Präfix im
  Muster: 20 Nennungen, 9 Ziele, `gates` 5× + `help` 1× = 6 init-invariante Nennungen, 14 übrige.
  (Die Zahl 19 aus Runde 1 war zu niedrig.)
- **`slice-087`s Negativ-Grep hat eine Positivkontrolle.** `^(coverage-gate|fullbuild|ci|arch-check):`
  über `internal/gen internal/emit` findet nichts; derselbe Ausdruck mit `(test|lint|build)`
  findet sechs Treffer. Die Abwesenheitsaussage ist damit belastbar. Auch die Nebenaussage stimmt:
  das Arch-Gate emittiert `a-check` bzw. `a-check-<modul>` (`internal/emit/archgate.go:66-84`),
  nie `arch-check`.
- **`slice-087`s DoD ist mit 4(e) deckungsgleich, keine zweite Fassung.** DoD (1) sagt
  *„nur noch Init-invariante Ziele … in beiden Bootstrap-Varianten"*, DoD (2) prüft
  *„die Eigenschaft, nicht die sieben Namen"* — dieselbe Größe wie 4(e), nicht eine abgeschriebene
  Liste, die driften kann.
- **`CO-002` ist mit seiner neuen Rolle verträglich.** Ganze Datei gelesen: kein Verweis auf
  `ADR-0020`, keine Tool-Zelle, kein Anspruch, Trigger einer Matrix-Zelle zu sein. Sein
  Folge-Slice (`slice-086`) und seine Schwelle betreffen den Span-Bestand dieses Repos — genau
  das, was ADR und Plan als *Vorbedingung* beschreiben.
- **`ADR-0012` trägt als Präzedenz.** Der Wert ist nach `welle-09` §3 in **beiden** Spalten
  zulässig, und die ADR zitiert genau diesen Satz. Der Unterschied (0012 ruht auf einer
  Abwesenheit im fremden Vertrag) ist kein Bruch der Präzedenz, wohl aber der Grund für MEDIUM-1.
- **Alle vier Regelwerks-Zitate und die drei `ADR-0011`-Zitate sind wortgleich.** Modul 7
  (Frage 1, Frage 2, ADR-Pfad), Modul 13 §Hard Rule (Doku-Disziplin), Modul 15
  §Doku-Konsistenz-Drift-Regeln (Lebenszyklus), `ADR-0011` §Entscheidung, Festlegung 4
  (`docker`/300–700 ms), Festlegung 6 (stdout/Exit-Klemme), Festlegung 2 (*„kein Byte fremden
  Inhalts"*) — je gegen die Quelle gehalten. Der ADR-Pfad-Satz trägt eine korrekt markierte
  Klammer-Einfügung (*„fällt [der Trigger] weg"*).
- **Die Beschreibung des Abwesenheits-Wächters ist präzise.** `internal/emit/enforce_test.go:51-57`
  enthält beides wie beschrieben: den `strings.Contains(got, "blocked/")`-Test über der Pfadliste
  und das `os.Stat` auf `tools/harness/blocked` nach `Enforce`, je mit `t.Errorf`.
- **Die Plan-Ebene trägt den gedrehten Zellwert vollständig.** `slice-062` §1-Tabelle, `welle-09`
  §3/§4/§6 und die Roadmap-Zeile vom 2026-08-16 nennen übereinstimmend drei *ADR-Verdikt* und
  eine *emittiert*-Zelle mit Gegen-Ausgang. Keine Stelle trägt noch *nicht emittiert* als Wert
  einer der drei Zellen (die verbliebenen Treffer sind Definitionen, Abgrenzungen oder der
  benannte Gegen-Ausgang der vierten Zelle) — die Ausnahme ist der Trigger-Satz aus MEDIUM-5.
- **`AGENTS.md` §3.8 ist gewahrt.** `07fe9b7` berührt ausschließlich `docs/plan/adr/**`,
  `af73707` ausschließlich `docs/plan/planning/**`; beide nennen ihre Rolle in der Message, keine
  Vermischung.
- **Das Vertrags-Stratum ist unberührt.** `git show --stat` über beide Commits: `spec/**` kommt in
  keinem vor.
- **Doku-Gate über dem neuen Bestand grün.** `make docs-check`: `322 Datei(en) geprüft,
  0 Befund(e)`, Exit 0.
- **Was ich NICHT geprüft habe, und das gehört gesagt:** ein Lauf an einem wirklich
  gebootstrappten Ziel (`make full-smoke` ist Verifier-Arbeit) — die Sonden sind Nachbauten der
  Emission aus dem Code, keine echte Emission; die Repo-Sonde aus `slice-062` §6 (`2 Befund(e)`
  mit Block); der Inhalt der ADRs `0003`, `0007`, `0013` über ihre hier zitierten Stellen hinaus.

---

## Kategorie-Summary

| Kategorie | Anzahl | IDs |
|---|---|---|
| HIGH | 2 | HIGH-1, HIGH-2 |
| MEDIUM | 6 | MEDIUM-1 … MEDIUM-6 |
| LOW | 2 | LOW-1, LOW-2 |
| INFO | 1 | INFO-1 |

---

## Verdikt

**Blockiert.** Die ADR geht in dieser Fassung **nicht** auf *Accepted*.

**Blockierend sind HIGH-1 und HIGH-2**, und beide sind **vom Fix eingeführt**, nicht von Runde 1
stehen gelassen:

- **HIGH-1** ist die Wiederkehr der Klasse, die diese Runde suchen sollte. Die Überarbeitung
  ersetzt eine ungemessene Analogie durch eine Abzählung — und einer der fünf abgezählten Ausgänge
  behauptet eine Unmöglichkeit, die der eigene, testbewachte Code dieses Repos widerlegt und deren
  Widerlegung als Kommentar über der betroffenen Funktion steht. An dieser Abzählung hängt der
  Ausgang von Modul-7-Frage 2 und damit **drei** Matrix-Werte; §3.4 lässt sie ab *Accepted* nicht
  mehr korrigieren.
- **HIGH-2** ist gemessen, nicht abgeleitet: die Bedingung, die den Runde-1-HIGH-2 löst, ist über
  *„ein emittiertes Dokument"* formuliert, vermessen sind zwei — und ein drittes emittiertes
  Dokument behauptet ein `make`-Ziel, das in **keiner** Bootstrap-Variante existiert und das kein
  Plan-Artefakt heute nennt. Der konfigurierte Träger würde es nicht melden; der Befund bliebe
  still.

Die sechs MEDIUM blockieren nach Modul 10 §Ablage ebenfalls typischerweise. Drei von ihnen
(MEDIUM-1, MEDIUM-2, MEDIUM-3) betreffen die Tragfähigkeit des Trichter-Ausgangs selbst, zwei
(MEDIUM-4, MEDIUM-5) sind Konsistenz-Brüche zwischen ADR und Plan, einer (MEDIUM-6) beschreibt die
Messmethode falsch. LOW-1, LOW-2 und INFO-1 blockieren nicht.

**Was ausdrücklich hält:** der Charakterwechsel *„vorerst nicht" → „permanent nicht"* ist als
Entscheidung tragfähig — Modul 7 verlangt für *Nein* nur *„nichts davon werden wir in absehbarer
Zeit tun"*, und das ist hier begründet. Angegriffen sind nicht die drei Zellwerte, sondern **die
Sätze, mit denen sie begründet werden** — und weil §3.4 sie einfriert, ist der Unterschied hier
nicht akademisch. Ebenso hält der Anspruchs-Weg aus 4(e)/4(c): er ist die richtige Antwort auf
Runde-1-HIGH-2, und seine Wirkung ist in dieser Runde unabhängig nachgemessen; unvollständig ist
allein die Menge, über die er quantifiziert.

**Nicht Gegenstand dieses Verdikts:** wie die Befunde aufzulösen sind (Modul 10 §Anti-Pattern), die
DoD-Abhakung, und die Auftraggeber-Setzungen selbst — sie sind Eingangsgröße, nicht Gegenstand;
geprüft ist, ob ADR und Plan sie tragen.
