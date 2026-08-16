# ADR-0019 und ADR-0020 (beide Proposed) — Konvergenzrunde

**Rolle:** Reviewer (Modul 10). **Datum:** 2026-08-16. **Lauf:** frischer Kontext, Subagent
`reviewer`. **Gegenstand:** zwei Proposed-ADRs zugleich, verengt auf **das, was die jeweils
jüngste Überarbeitung eingeführt hat**, plus ihre Kopplung.

**Commit-Range je Gegenstand:**

| Gegenstand | geprüfte Überarbeitung | vorherige Runden |
|---|---|---|
| `ADR-0019` | `e229690` (Architect; ADR, ADR-Index, `CO-002`) — nie nachgeprüft; dazu `1b3401a` (Spec) und `9ada41d` (Planner) als Umgebung derselben Reparatur | `docs/reviews/2026-08-15-adr-0019-bestaetigungsrunde.md`, `…-runde-2.md` |
| `ADR-0020` | `621fcab` (Architect; ADR + Index) und `0b6c676` (Planner; `slice-062`, `slice-087`, `welle-09`, Roadmap) | `docs/reviews/2026-08-16-adr-0020-bestaetigungsrunde.md`, `…-runde-2.md` |

**Eingangs-Kontext (die fünf Pflicht-Punkte plus Plan, Modul 10 §Eingangs-Kontext):** Commit-Range
oben · betroffene Anforderungen `LH-QA-01`, `LH-QA-02`, `LH-QA-03`, `LH-FA-01`, `LH-FA-03`,
`LH-FA-06`, `LH-FA-07` · referenzierte **aktive** ADRs `0003`, `0004`, `0007`, `0011`, `0012`,
`0013`, `0016` (alle Accepted) · Hard Rules `AGENTS.md` §3.1–§3.8 · **vorherige Findings am
gleichen Modul:** die vier Runden-Reports oben · Plan-Bezug: `CO-002`, `slice-062`, `slice-071`,
`slice-086`, `slice-087`, `welle-09`, Roadmap.

**Auftrag dieser Runde, und was daraus folgt:** re-litigiert wird nichts, was eine frühere Runde
bestätigt hat. Der Status der Runde-1- und Runde-2-Befunde wird nur dort aufgegriffen, wo die
jüngste Überarbeitung ihn verändert hat. Nicht meine Rolle und darum nicht getan: DoD-Abhakung
und Gate-Lauf-Bestätigung (Modul 10 §Anti-Pattern).

**Nicht nachmessbar in diesem Lauf, und das gehört an den Anfang:** ein Subagent führt das
`Agent`-Werkzeug nicht. Alles zum Tool-Vertrag prüft die **Beleg-Kette**, nicht den Vertrag. Der
Span-Bestand liegt gitignored und maschinenlokal; wo ich ihn messe, ist die **Gestalt** die
Aussage, nicht die Zahl.

## Selbst gefahren — Kommando und Ergebnis, nichts davon übernommen

| Kommando | Ergebnis |
|---|---|
| `make docs-check` | `d-check: 323 Datei(en) geprüft, 0 Befund(e)`, Exit 0 |
| `git status --porcelain` vor und nach dem Lauf | leer |
| Python über `.harness/state/spans/*.jsonl`: Gesamtzahl, Sitzungen, Datumsspanne, `(event,status)`-Paare | **9088** Spans · **4** Sitzungen · **2026-07-29 … 2026-08-16** · `PostToolUse/ok` 8971 · `PostToolUseFailure/error` **55** · `SubagentStart/ok` 62 — **kein** `PostToolUse`-Span trägt einen Fehl-Status |
| `grep -n "func failed" -A 20 internal/span/span.go` | `if strings.Contains(event,"Failure") { return true }`, danach wird `raw["error"]` **sehr wohl** ausgewertet — die Null oben ist also keine Tautologie |
| dieselbe Auswertung nach `agent_role`, ganzer Bestand | planner 2329 · reviewer 1746 · implementer 1428 · architect 1166 · verifier 431 · `""` 2007 — **`validator` kommt in keinem Span vor (0)** |
| dieselbe Auswertung, auf `2026-08-15` eingegrenzt | architect 156 · planner 129 · reviewer 127 · `""` 188 — **drei** Rollen |
| `Agent`-Spans und `SubagentStart`-Ereignisse am `2026-08-15`, mit Zeitstempel | **je 10**, sauber gepaart: 15:38:17Z · 16:06:10Z · 16:08:11Z · 16:37:57Z · 16:58:29Z · 17:13:39Z · 17:27:24Z · **17:46:53Z** · 17:56:27Z · 18:02:53Z; alle zehn ohne `spawned_role` |
| Nachbau des emittierten Dokument-Satzes aus `internal/emit` (Templates-Singletons ohne die 5 wiederkehrenden und 2 derivativen Vorlagen, `StripHintBlock` angewandt; dazu `README.md` aus `project-readme.template.md` und die drei `templates/commands/*.md`) und Zählung der `make`-Nennungen | **14** Dokumente im Satz, **7** nennen ein `make`-Ziel: `README.md` (gates 1), `close-welle.md` (gates 4), `plan-welle.md` (gates 4), `implement-slice.md` (gates 5 + das Muster `verify-*`), `AGENTS.md` (9), `harness/README.md` (11), `closure-note-reviewer.md` (verify-closure-notes 2) — **4 unauffällig, 3 verletzend**, exakt wie in 4(e) |
| dieselbe Zählung nur über die zwei Doku-Tische | **20** Nennungen, **9** verschiedene Ziele; init-invariant davon genau `gates` (5×) und `help` (1×) |
| `grep -rn "verify-closure-notes" --include='*.go' --include='*.mk' --include='*.sh' --include='Makefile' .` | **0 Zeilen**, rc 1 · Positivkontrolle `record-gates`: **19** Dateien |
| dieselbe `make`-Zählung über die **vendored** Baseline, die der Bootstrap ins Ziel legt | wiederkehrende Vorlagen: `welle.template.md` → `fullbuild`, `NNNN-titel.template.md` → `arch-check`, `slice`/`carveout` → nur `gates` · `regelwerk/`: **9** Module nennen `make`, darunter `fullbuild`, `arch-check`, `coverage-gate-critical`, `build`, `verify`, `test-determinism` |
| `grep -n 'ai-harness-init"' harness/tools/full-smoke.sh` | **vier** Bootstraps in vier tmp-Repos: `:43` (`--lang go`), `:156` (sprachlos), `:521` (`--lang go --arch hexslice`), `:562` (`--lang cpp --arch hexslice`); `add-lang go` ins sprachlose Repo erst bei `:212` |
| `grep -c "CO-002" .claude/hooks/pretooluse-agent-guard.sh spec/spezifikation.md` | Guard **1**, Spec **5** — die Tabelle in `CO-002` §Geltungs-Konfiguration stimmt weiter |
| `grep -n "lässt keine zusätzlichen Felder zu" spec/ docs/plan/` | genau **zwei** Treffer: `spec/spezifikation.md:164` (als Tatsache) und `docs/plan/adr/0019-…:135` (als **widerlegt**) |
| Verbatim-Abgleich der neuen Regelwerks-Zitate gegen `.harness/baseline/v3.5.2/regelwerk/modul-15-observability.md` | §Span-/Audit-Attribut-Regeln (*Mindestfelder …*) Z. 33 und §Kernidee (*Ein Agenten-Lauf ohne Trace …*) Z. 13–14 — **wortgleich** |
| Verbatim-Abgleich `extract-command.awk` und `internal/span/span.go` Kopf | beide **wortgleich** (`extract-command.awk:5`; `span.go:5-11`) |
| `grep -n "21 " docs/plan/planning/done/slice-059-*.md` | `:155` *„Dazu 21 externe Aufrufe je Span (gemessen) gegen **einen** Prozess-Start."* — die neue Zeile in Ausgang 1 zitiert richtig |
| `internal/emit/readme.go` gelesen | `RootReadme` emittiert `README.md` **aus `project-readme.template.md`** (`StripHintBlock` + Namens-Stempel, *„genau wie ein Singleton"*) |

**Nicht gefahren:** `make gates`, `make test`, `make mutate`, `make full-smoke` (Verifier-Arbeit,
Modul 10 §Anti-Pattern) und die sechs `targets`-Sonden gegen das gepinnte Image (in Runde 2
unabhängig reproduziert; diese Runde greift sie nicht an).

---

## Findings — `ADR-0019`

### HIGH-1 — Die Überarbeitung erklärt die Schema-Selbstauskunft für widerlegt; das Spec-Stratum, das dieselbe ADR zu schärfen erklärt, führt sie acht Zeilen über ihrer eigenen Korrektur weiter als Tatsache

- **kategorie:** HIGH
- **quelle:** `AGENTS.md` §3.6 (*„Richtig: die Zusage auf das einschränken, was der Code hält"*);
  `ADR-0019` §Schärft (*„wer diese ADR ändert, zieht von hier die betroffenen Spec-Stellen nach"*);
  `LH-QA-02`; Modul 10 §Kontext-Eskalation (dritte Runde derselben Klasse)
- **pfad:** `docs/plan/adr/0019-agent-guard-prueft-die-aufrufform.md:134-138` gegen
  `spec/spezifikation.md:163-164` und `:172-175`
- **befund:** `e229690` fügt in die ADR ein: *„**Und eine Auskunft trägt hier gar nichts:** dass
  das Eingabe-Schema *„keine zusätzlichen Felder zulässt"*, ist eine Selbstauskunft, und sie ist
  am 2026-08-15 **widerlegt** — der Aufruf mit dem zusätzlichen Feld wurde angenommen."*
  `spec/spezifikation.md:163-164` behauptet unverändert: *„Am **2026-08-15** führt das
  Eingabe-Schema von `Agent` das Feld nicht mehr **und lässt keine zusätzlichen Felder zu**"* —
  und acht Zeilen tiefer, im **selben** Aufzählungspunkt, steht die Korrektur, die es widerlegt:
  *„**Vom Aufrufer gesendet wirkt es nicht** — ein Aufruf mit dem Feld wird **angenommen** und
  startet dennoch im Hintergrund (2026-08-15 gemessen, Nachtrag §7)"* (`:172-175`). Ein Schema,
  das keine zusätzlichen Felder zulässt, weist einen Aufruf mit einem zusätzlichen Feld ab; der
  gleiche Punkt sagt, er werde angenommen. Der Spec-Commit `1b3401a` (19:58) hat den hinteren
  Teil desselben Punktes und die START-KONVENTION gezogen und diesen Satz stehen lassen;
  `e229690` (20:12) hat 14 Minuten später die Widerlegung in die ADR geschrieben, ohne die
  Änderungskopplung aus §Schärft auszulösen. Der Satz ist zugleich der einzige verbliebene
  Fundort der Aussage außerhalb der ADR — gemessen, nicht vermutet (zwei Treffer im ganzen Baum,
  einer davon die Widerlegung selbst).
- **gegenbeispiel:** `ADR-0019` geht auf *Accepted* und ist nach `AGENTS.md` §3.4 im **Text**
  eingefroren. Jemand prüft die Beleglage von Festlegung 1 gegen das Spec-Stratum — die Stelle,
  auf die `CO-002` §Geltungs-Konfiguration ausdrücklich als eine von fünf zeigt — und findet dort
  die Aussage, die die ADR für widerlegt erklärt, im Indikativ. Er muss entweder die eingefrorene
  ADR für falsch halten oder die Spec-Zeile stillschweigend umdeuten. Genau diese Klasse hat
  Runde 1 als MEDIUM-1 und Runde 2 als HIGH-1 benannt; die Reparatur hat den letzten Fundort
  ausgelassen.
- **verifizierbar:** ja, ohne Gate-Lauf —
  `grep -rn "lässt keine zusätzlichen Felder zu" spec/ docs/plan/` liefert genau die zwei Zeilen.
  **Maschinell nicht bewacht:** `.d-check.yml` führt `links, anchors, ids, matrix, codepaths,
  spans`; kein Modul liest Belegklassen oder vergleicht ADR-Aussagen mit Spec-Aussagen.

### MEDIUM-1 — Dieselbe Überarbeitung fügt einen vierten `Agent`-Span desselben Tages in den Kontext ein und lässt zwei Absätze tiefer „drei Spans, eine saubere Paarung, kein Rest" stehen

- **kategorie:** MEDIUM
- **quelle:** `LH-QA-02` (Reproduzierbarkeit einer Messmethode); `AGENTS.md` §3.6
- **pfad:** `docs/plan/adr/0019-agent-guard-prueft-die-aufrufform.md:177-179` gegen `:114-117`
- **befund:** `e229690` schreibt in `:114-117`: *„derselbe Lauf startet dennoch asynchron, und
  sein `Agent`-Span trägt dieselbe Gestalt wie **jeder andere Hintergrund-Lauf des Tages** —
  `model_version`, `duration_ms: 3` …"*. Das ist der Nachtrag-Span von `17:46:53Z`. Der Absatz
  `:177-179` — von derselben Überarbeitung **nicht** angefasst — sagt: *„**Drei** `Agent`-Spans
  des Tages, dazu drei `SubagentStart`-Ereignisse zu denselben drei Zeitstempeln in derselben
  Sitzung (15:38:17Z · 16:06:10Z · 16:08:11Z) — **eine saubere Paarung, kein Rest**"*, und zählt
  in `:182-184` *„Seine `duration_ms` sind 6 · 3 · 3"*. Selbst gemessen: am 2026-08-15 stehen
  **zehn** `Agent`-Spans und **zehn** `SubagentStart`-Ereignisse im Bestand, darunter der in
  `:117` zitierte. Die Aussage *„kein Rest"* war beim ersten Schnitt (16:26Z) richtig; die
  Überarbeitung hat den Rest selbst hinzugefügt und den Satz stehen lassen.
- **gegenbeispiel:** ein Verifier zieht die Messung nach, findet zehn statt drei Spans und muss
  entscheiden, ob die ADR einen anderen Bestand meint, einen Zeitraum eingrenzt, den sie nicht
  nennt, oder schlicht falsch zählt. Die einzige Stelle, die das auflösen würde — der Zeitstempel
  des Nachtrag-Spans —, steht in der ADR selbst und widerspricht der Zählung. Nach `AGENTS.md`
  §3.4 ist der Absatz ab *Accepted* nicht mehr korrigierbar.
- **Nicht betroffen ist die Entscheidung:** die tragende Aussage des Absatzes — der `Agent`-Span
  trägt von neun erfassten Werten nur `model_version` — hält für **alle zehn** Spans (selbst
  gemessen: `spawned_role` überall leer). Beanstandet ist die Zählung und das Wort *„kein Rest"*,
  nicht die Gestalt.
- **verifizierbar:** ja, ohne Gate-Lauf — die `Agent`-Zeilen des Bestands nach `ts` filtern
  (Bestand gitignored und maschinenlokal; die Gestalt — mehr als drei, sauber gepaart — ist die
  Aussage).

### LOW-1 — „kein Aufruf trug am Hook `run_in_background: false`" quantifiziert über alle Aufrufe; belegt ist eine Rollen-Probe, und der eine Aufruf, der das Feld nachweislich sendete, ist am Hook nie angesehen worden

- **kategorie:** LOW
- **quelle:** `AGENTS.md` §3.6; `LH-QA-02`
- **pfad:** `docs/plan/adr/0019-agent-guard-prueft-die-aufrufform.md:140-144` gegen `:88-91` und
  `:112-117`
- **befund:** Die neue Fassung sagt: *„Für Festlegung 1 reicht, was gemessen ist: **kein Aufruf
  trug am Hook `run_in_background: false`** — jede Rollen-Probe fiel in den letzten Zweig der
  damaligen Guard-Fassung"*. Die ADR selbst beziffert die Rollen-Proben auf **eine**
  (`:88-89`: *„fiel **eine Probe** mit `subagent_type: architect` darauf"*; `:91`: *„**Gemessen
  ist eine Probe**, getroffen sind alle sechs"*). Nicht-Rollen-Typen erreichten den
  Betriebsart-Zweig gar nicht, über ihren Wert ist also nichts bekannt. Und der einzige Aufruf,
  von dem die ADR sagt, er habe `false` gesendet — der Nachtrag-Aufruf vom 17:46:53Z (`:112-114`)
  —, lief **nach** der Senkung `83cf01d` (18:05 Ortszeit / 16:05Z), als der Zweig, der den Wert
  las, schon gefallen war; ob er am Hook ankam, hat niemand angesehen.
- **gegenbeispiel:** Folgepflicht 5 wird gefahren, ein Aufruf sendet `false`, und der Extraktor
  gibt am Hook `false` aus. Dann trug ein Aufruf am Hook den Wert, die Bedingung des alten Guards
  war erfüllbar, und die als *gemessen* eingeführte Universalaussage ist widerlegt — während die
  ADR sie ab *Accepted* im Indikativ führt.
- **verifizierbar:** ja, ohne Gate-Lauf — `:140-144` gegen `:88-91` lesen; abschließend erst durch
  Folgepflicht 5.

### LOW-2 — Die dritte Aussage des tragenden Grundes liest `ABSENT` als „erreicht den Hook nicht"; `ABSENT` unterscheidet nicht zwischen „nicht gesendet" und „gesendet und unterwegs verloren"

- **kategorie:** LOW
- **quelle:** `AGENTS.md` §3.6; `LH-QA-02`
- **pfad:** `docs/plan/adr/0019-agent-guard-prueft-die-aufrufform.md:117-119` und `:145-146`,
  gestützt auf `docs/reviews/2026-08-15-agent-guard-tool-vertrag.md:148`
- **befund:** Der tragende Grund heißt nach der Überarbeitung *„gesendet, ohne Wirkung, und beim
  Hook nicht angekommen"* (`:145-146`); die dritte Hälfte steht als *„Und er **erreicht den Hook
  nicht**: dort stand `ABSENT`"* (`:117`). `ABSENT` ist die Ausgabe des Extraktors für einen
  **fehlenden Schlüssel** in `tool_input` — sie ist mit *„das Modell hat das Feld gar nicht
  gesendet"* genauso verträglich wie mit *„gesendet und vor dem Hook entfernt"*. Dass der
  Hintergrund seit v2.1.198 der **Standard** ist und ein weggelassener Schalter *„kein Versehen
  des Aufrufers"* (`:131-133`, ADR-eigener Satz), macht die erste Lesart sogar zur
  wahrscheinlicheren. Für den 2026-08-10 ist nirgends belegt, dass ein Aufruf das Feld sendete.
  Dieselbe Verkürzung trägt die Nachtrags-Tabelle (*„Der Schalter **erreicht den Hook** | nein |
  2026-08-10 — der Guard las `ABSENT`"*); die ADR übernimmt sie als eine der drei tragenden
  Aussagen.
- **gegenbeispiel:** Folgepflicht 5 läuft mit dem Vor-Aufruf-Protokoll und liefert für jeden
  gewöhnlichen Agenten-Aufruf `ABSENT`, weil das Modell das Feld standardmäßig nicht sendet. Wer
  das als Bestätigung von *„erreicht den Hook nicht"* liest, hat nichts gemessen; wer es als
  Widerlegung liest, ebenso wenig. Die ADR sagt nicht, dass die Beobachtung erst dann etwas
  entscheidet, wenn ein Aufruf das Feld **tatsächlich sendet** — sie sagt nur *„stünde dort
  `false`"* (`:397`).
- **Nicht betroffen ist Festlegung 1:** ob unsendbar, wirkungslos oder unterwegs verloren — die
  Bedingung des alten Guards wurde von keinem realen Aufruf erfüllt, und der Ausfall-Schluss steht
  auf jeder der drei Lesarten.
- **verifizierbar:** nein, mit heutigem Bestand nicht — genau deshalb existiert Folgepflicht 5.

### LOW-3 (Plan) — `slice-071` führt `CO-002`s Auflösungs-Trigger weiter in seiner alten, halben Fassung

- **kategorie:** LOW
- **quelle:** `LH-QA-02`; `CO-002` §Auflösungs-Trigger (*„**eine** Schwelle"*, seit `e229690`
  zweiteilig); `ADR-0020` Festlegung 3 (*„verwiesen, nicht abgeschrieben — eine zweite Fassung
  derselben Schwelle wäre die zweite Wahrheit, die driftet"*)
- **pfad:** `docs/plan/planning/open/slice-071-cache-zaehler-getrennt.md:113-114` gegen
  `docs/plan/carveouts/CO-002-token-achse-je-rolle.md:69-73`
- **befund:** `slice-071` sagt: *„Fällt der Trigger von `CO-002` positiv — **der Bestand trägt
  wieder `spawned_role` und alle vier Zähler** —, wird die Rechnung geschnitten"*. Seit `e229690`
  ist das die halbe Schwelle: `CO-002` verlangt den Span **und** *„die Mechanik, die ihn erzeugt
  hat, liegt committet im Baum"*, und begründet in `:75-81` ausdrücklich, warum die erste Hälfte
  allein vom zurückgenommenen Messaufbau dauerhaft erfüllt würde. `slice-071` ist nach `e229690`
  vom Planner angefasst worden (`9ada41d`), die Zeile blieb.
- **gegenbeispiel:** `slice-086` läuft positiv, die Sonde geht wie geplant zurück, die Folge-ADR
  steht aus. Wer `slice-071` liest, sieht seinen Eintritt erreicht und schneidet die
  Cache-Rechnung, obwohl kein Checkout mehr Zähler herstellt — genau der Fall, den die zweite
  Hälfte der Schwelle verhindern soll.
- **verifizierbar:** ja, ohne Gate-Lauf — die zwei Absätze nebeneinander lesen.

---

## Findings — `ADR-0020`

### MEDIUM-1 — Die Fitness Function beschreibt die Messmethode zum zweiten Mal falsch: `full-smoke` bootstrappt vier tmp-Repos, nicht zwei — und das Plan-Artefakt vom selben Tag sagt es richtig

- **kategorie:** MEDIUM
- **quelle:** `AGENTS.md` §3.6 (*„die Zusage auf das einschränken, was der Code hält"*);
  `LH-QA-02`; Modul 10 §Kontext-Eskalation (zweite Runde derselben Klasse in derselben Zelle)
- **pfad:** `docs/plan/adr/0020-emittierte-modul-15-regeln.md:703` gegen
  `harness/tools/full-smoke.sh:43`, `:156`, `:521`, `:562` und
  `docs/plan/planning/open/slice-087-emittierte-doku-tische-init-invariant.md:220-222`
- **befund:** Die `make full-smoke`-Zeile sagt nach dem Fix: *„die Lücke ist nicht die fehlende
  Variante, sondern die **Platzierung**: `harness/tools/full-smoke.sh` bootstrappt **zwei**
  tmp-Repos (`--lang go` und sprachlos) …"*. Selbst gemessen: das Skript bootstrappt **vier**
  tmp-Repos — `:43` (`--lang go`), `:156` (sprachlos), `:521` (`--lang go --arch hexslice`),
  `:562` (`--lang cpp --arch hexslice`). Der Planner hat dieselbe Stelle 16 Minuten später
  gemessen und in `slice-087:220-222` mit Zeilennummern niedergelegt: *„bootstrappt **vier**
  tmp-Repos; die zwei, die hier zählen, sind `tmprepo` (`--lang go`, `:43`) und `tmprepo_doc`
  (**sprachlos**, `:156`) — die anderen zwei sind `--arch`-Varianten mit Sprache (`:521`,
  `:562`)"*. Runde 2 hat genau diese Zelle als MEDIUM-6 beanstandet, weil sie *„heute fährt der
  Voll-Smoke **eine** Variante"* sagte; der Fix hat eine Zahl durch die nächste falsche ersetzt.
- **gegenbeispiel:** der Implementer von `slice-063` liest die eingefrorene ADR, sucht die zwei
  tmp-Repos, findet vier und muss raten, welche zwei gemeint sind — oder er bezahnt die falschen.
  Die ADR selbst begründet die Varianten-Klammer damit, dass *„ein falscher Befund von einem
  wahren nicht zu unterscheiden ist"*; eine falsche Angabe über den Varianten-Raum ist derselbe
  Fehler eine Ebene höher. Nach `AGENTS.md` §3.4 ist die Zeile ab *Accepted* nicht mehr
  korrigierbar, während `slice-087` daneben die richtige Zahl führt.
- **Zur Einstufung, ausdrücklich:** die operative Anweisung der Zelle — den Zahn **vor**
  `add-lang go` setzen — ist richtig (`:160` fährt `make gates` sprachlos, `:212` zieht
  `add-lang go` nach; selbst gelesen), und der Varianten-Raum ist sachlich abgedeckt (`--lang
  cpp` verhält sich für die neun behaupteten Ziele wie `--lang go`, `internal/gen/cpp.go`
  definiert `test`/`lint`/`build`). Deshalb **keine** Eskalation auf HIGH nach Modul 10
  §Kontext-Eskalation: `make full-smoke` ist ausdrücklich Tier-2 und **nicht** in `make gates`,
  und es ist die zweite, nicht die dritte Wiederholung. MEDIUM blockiert nach Modul 10 §Ablage
  ohnehin.
- **verifizierbar:** ja, ohne Gate-Lauf — `grep -n 'ai-harness-init"' harness/tools/full-smoke.sh`.

### MEDIUM-2 — 4(e) erklärt seinen Dokument-Satz für selbst-vollständig; dieselbe ADR nennt 435 Zeilen früher „emittiert", was der Satz ausschließt — und dort stehen `make`-Ansprüche, die in keiner Variante existieren

- **kategorie:** MEDIUM
- **quelle:** `LH-QA-01`; `AGENTS.md` §3.6; `LH-QA-02`
- **pfad:** `docs/plan/adr/0020-emittierte-modul-15-regeln.md:505-512` gegen `:72-73`, gehalten
  gegen `cmd/ai-harness-init/main.go:384-395` und den vendored Baum
- **befund:** 4(e) quantifiziert über *„den ganzen emittierten Dokument-Satz"* und begründet die
  Tragfähigkeit so: *„**Welcher Satz das ist, ist eine Regel und keine Aufzählung** — darum hält
  die Bedingung sich selbst vollständig, auch wenn ein Dokument hinzukommt: `internal/emit`
  schreibt jede `*.template.md` des vendored Satzes als Singleton ins Ziel (**ohne die
  wiederkehrenden Vorlagen**, die zwei derivativen Indizes und die Root-README-Vorlage), dazu …"*.
  Dieselbe ADR sagt in `:72-73`: *„Das Werkzeug **emittiert das Regelwerk vollständig ins
  Ziel**; ein gebootstrapptes Repo bekommt damit alle vier Regeln"*. Beides zugleich geht nicht:
  entweder zählt der vendored Baum als emittiert — dann fehlt er im Satz —, oder er zählt nicht,
  dann ist `:72-73` falsch. Der Baum landet real im Ziel (`baselineDir`/`templatesDir` wurzeln in
  `targetDir`; `emit.Templates` liest **aus** dem Ziel). Selbst gemessen, was dort an
  `make`-Ansprüchen liegt, die in **keiner** Bootstrap-Variante existieren:
  `welle.template.md` → `make fullbuild`, `NNNN-titel.template.md` → `make arch-check` (das
  emittierte Arch-Gate heißt `a-check`), dazu neun `regelwerk/`-Module mit `fullbuild`,
  `arch-check`, `coverage-gate-critical`, `build`, `verify`, `test-determinism`. Der Ausschluss
  ist **notwendig** — die vendored Baseline gehört dem Kurs und ist nach `AGENTS.md` §3.4 /
  `MR-008` für uns unveränderlich; mit ihr im Satz wäre 4(e) nie erfüllbar und Festlegung 5(e)s
  Gegen-Ausgang der einzig erreichbare. Genannt wird weder der Ausschluss-Grund noch die Tatsache,
  dass dort dieselbe `LH-QA-01`-Klasse liegt, die die ADR für den Closure-Note-Skill ausführlich
  aufmacht.
- **gegenbeispiel:** `slice-087` schließt, `slice-063` liest 4(e) als erfüllt, der `targets:`-Block
  geht mit. Ein Adopter, dem der Prozess sagt, er solle seine Wellen-Pläne aus
  `.harness/baseline/<tag>/templates/docs/plan/planning/welle.template.md` kopieren
  (`MR-008`: *Ausfüll-Templates referenziert statt kopiert*), trägt damit `make fullbuild` in ein
  lebendes Plan-Dokument seines Repos — ein Ziel, das dort in keiner Variante existiert. Wer
  danach 4(e) gegen den Bestand prüft, findet die Bedingung „erfüllt" und den Verstoß daneben,
  und kein Artefakt sagt, warum er außerhalb steht.
- **verifizierbar:** ja, ohne Gate-Lauf — `:72-73` gegen `:505-512` lesen und die
  `make`-Nennungen der vendored Vorlagen/Module zählen.

### MEDIUM-3 (Kopplung) — `ADR-0020` sagt, die Antwort auf `CO-002`s Frage sei an dessen Zustand ablesbar; seit `e229690` erzeugt der positive Ausgang einen dritten Zustand, den keine der beiden genannten Adressen trägt

- **kategorie:** MEDIUM
- **quelle:** `LH-QA-02`; Regelwerk `v3.5.2`, `modul-07-carveouts.md` §Ziel-Form: Carveout
  (*„eine Schwelle, die ein anderer Mensch ohne Rückfrage als erreicht beurteilen kann"*)
- **pfad:** `docs/plan/adr/0020-emittierte-modul-15-regeln.md:440-443` und `:724-729` gegen
  `docs/plan/carveouts/CO-002-token-achse-je-rolle.md:69-73`, `:96-103` und
  `docs/plan/planning/open/slice-086-vordergrund-per-updatedinput.md:57-63`, `:91-95`
- **befund:** `ADR-0020` Festlegung 3 lässt die zwei Zellen *„auf die **Frage** zeigen, die er
  stellt — *trägt ein `Agent`-Span wieder Rolle und Zähler?*"* und schließt: *„**Wo die Antwort
  steht, ist am Zustand ablesbar: im Carveout unter `done/`, oder in der Folge-ADR, die ihn
  überführt.**"* Das waren die zwei Ausgänge, als `CO-002` seine Schwelle noch allein am Span
  festmachte. Seit `e229690` verlangt sie **zusätzlich** *„die Mechanik, die ihn erzeugt hat,
  liegt committet im Baum"*, und `CO-002:96-103` sagt ausdrücklich: *„Weg 1 ist der einzige der
  drei, bei dem zwischen Beobachtung und Schwelle **noch eine Entscheidung liegt**"* — die
  Permission-Folge in einer Folge-ADR. `slice-086` DoD (1) verlangt die Rücknahme der Sonde,
  DoD (3) sagt für den positiven Zweig *„erst danach wird verdrahtet, und erst danach löst sich
  `CO-002` auf"*. Damit ist der positive Ausgang notwendig ein **dritter** Zustand: Frage
  beantwortet, `CO-002` weder in `done/` noch überführt.
- **gegenbeispiel:** `slice-086` läuft positiv, die Sonde geht zurück, die Permission-ADR steht
  aus. Jemand fragt, ob das **Zähler-Glied** aus Festlegung 3 offen ist. Die eingefrorene
  `ADR-0020` verweist ihn auf `CO-002`s Zustand; der steht auf *Aktiv* in `carveouts/`. Er liest
  „Frage unbeantwortet" und feuert den vierten Re-Evaluierungs-Trigger nie — obwohl die Antwort
  gemessen vorliegt und `slice-086`s Zeitdokument sie trägt.
- **verifizierbar:** ja, ohne Gate-Lauf — `:440-443` gegen `CO-002:96-103` und `slice-086:91-95`.

### MEDIUM-4 (Kopplung) — `ADR-0020` friert eine Zustandsangabe über `ADR-0019` ein, die ein gemeinsamer Accept im selben Moment falsch macht

- **kategorie:** MEDIUM
- **quelle:** `AGENTS.md` §3.4 (der **Text** wird mit *Accepted* unveränderlich); `LH-QA-02`
- **pfad:** `docs/plan/adr/0020-emittierte-modul-15-regeln.md:48-54`
- **befund:** Der Block *„Nicht tragend, und darum ausdrücklich benannt"* beginnt mit einer
  Tatsachenbehauptung über ein **nicht terminales** Lebenszyklus-Feld eines anderen Artefakts:
  *„[ADR-0019] steht auf *Proposed*."* Die übrigen Sätze des Blocks sind dauerhaft — *„Diese
  Entscheidung ruht an keiner Stelle auf ihr … Wird jene Entscheidung verworfen oder neu
  geschnitten, fällt aus dieser keine Aussage weg"* —, der erste ist ein Schnappschuss. Der
  Unterschied zu den Statusangaben im Bezug-Block (`**Accepted**` für `0003`, `0007`, `0011`,
  `0012`, `0013`, `0016`) ist, dass *Accepted* terminal ist und *Proposed* nicht. Es ist die
  einzige Stelle in `ADR-0020`, die `ADR-0019` nennt (`grep -n 0019` → genau `:49`).
- **gegenbeispiel:** beide ADRs gehen in derselben Sitzung auf *Accepted* — der Fall, den diese
  Runde ausdrücklich vorbereitet. Ab diesem Moment trägt eine nach §3.4 unveränderliche ADR die
  Aussage, eine andere stehe auf *Proposed*, während sie Accepted ist. Wer `ADR-0020` später als
  Beleg dafür liest, dass die Guard-Entscheidung noch nicht bindend sei, eröffnet sie neu; die
  Korrektur kostet eine Folge-ADR. Dieselbe Klasse regelt dieses Repo für Slice-Adressen bereits
  („Eigenschaft statt Adresse") — hier ist es ein Status statt einer Adresse.
- **verifizierbar:** ja — `grep -n "0019" docs/plan/adr/0020-*.md` gegen die Status-Zeilen beider
  ADRs.

### LOW-1 — 4(e) nennt die Root-`README.md` „tool-autoriert"; sie kommt aus der vendored Vorlage

- **kategorie:** LOW
- **quelle:** `LH-QA-02`; Maintainability
- **pfad:** `docs/plan/adr/0020-emittierte-modul-15-regeln.md:510-512` gegen
  `internal/emit/readme.go:11-15`, `:29-36`
- **befund:** Die Satz-Definition des Dokument-Satzes lautet *„… ohne die wiederkehrenden
  Vorlagen, die zwei derivativen Indizes und die **Root-README-Vorlage**), dazu die
  **tool-autorierte** Root-`README.md` …"*. `internal/emit/readme.go` sagt das Gegenteil:
  `rootReadmeSource = "project-readme.template.md"`, und `RootReadme` *„emittiert die
  Root-README.md aus project-readme.template.md (StripHintBlock + `<Projektname>`-Stempel, **genau
  wie ein Singleton**)"*. Sie ist damit dieselbe vendored Vorlage, nur mit eigenem Ziel-Namen und
  eigenem Emit-Schritt — nicht tool-autoriert wie die drei Workflow-Commands.
- **gegenbeispiel:** jemand prüft die Selbst-Vollständigkeit des Satzes und sucht die
  tool-autorierte Quelle des Root-README im Emit-Baum (`internal/emit/templates/`). Er findet sie
  nicht und muss entscheiden, ob die Regel eine Datei-Klasse meint, die es nicht gibt.
  Set-Zugehörigkeit ändert sich dadurch nicht — die Herkunftsangabe schon.
- **verifizierbar:** ja — `sed -n '11,15p;29,36p' internal/emit/readme.go`.

### LOW-2 (Plan) — `slice-087` DoD (2) verlangt „jedes emittierten Dokuments" und nennt als Quelle `TemplateTargets`, das vier der vierzehn Dokumente nicht führt

- **kategorie:** LOW
- **quelle:** `LH-QA-01`; `ADR-0020` Festlegung 4(e) (der Satz ist breiter als `TemplateTargets`)
- **pfad:** `docs/plan/planning/open/slice-087-emittierte-doku-tische-init-invariant.md:106-116`
  gegen `internal/emit/templates.go:135-171`, `internal/emit/readme.go:8-9`,
  `internal/emit/commands.go:34-43`
- **befund:** DoD (2) sagt: *„Ein Go-Test … hält **jede** `make`-Nennung **jedes emittierten
  Dokuments** gegen die Ziel-Menge"* und nennt als Bezugsquelle: *„`internal/emit/templates.go`
  klassifiziert mit `inScope` und liefert die Ziel-Relpfade über `TemplateTargets` — wer die Menge
  dort abholt, bekommt ein neu hinzugekommenes Dokument automatisch mit"*. `TemplateTargets`
  liefert ausschließlich die Templates-Singletons; die Root-`README.md` (`emit.RootReadmePath`,
  eigener Schritt) und die drei Workflow-Commands (`emit.CommandPaths()`) kommen aus anderen
  Emittern. Das sind vier der vierzehn Dokumente des Satzes und genau vier der sieben, die heute
  ein `make`-Ziel nennen. Heute fällt nichts durch — alle vier nennen nur `make gates` (selbst
  gemessen) —, aber der Wächter deckte die Regel nur zu zehn Vierzehnteln.
- **gegenbeispiel:** ein Workflow-Command bekommt später eine Zeile mit `make coverage-gate`. Der
  Wächter aus DoD (2) ist grün, `doc-tables:` nennt die Datei nicht, der Befund ist still — genau
  das Fehlerbild, gegen das derselbe DoD-Punkt argumentiert (*„das vierte Dokument … liefe still
  an ihm vorbei"*).
- **verifizierbar:** ja, ohne Gate-Lauf — `TemplateTargets` gegen `CommandPaths`/`RootReadmePath`
  lesen.

### INFO-1 — Die Trigger-Art von Ausgang 1 ist „Messung"; sein zweites Bein hängt zusätzlich an `ADR-0011` Festlegung 2, und der Re-Evaluierungs-Trigger für diese Festlegung nennt nur Ausgang 4

- **kategorie:** INFO
- **pfad:** `docs/plan/adr/0020-emittierte-modul-15-regeln.md:189-200` und `:713-719`
- **befund:** Ausgang 1 trägt seit `621fcab` zwei Beine: das gemessene awk-Scheitern (plus die
  21-Aufrufe-Messung) und den Schema-Fall, der *„über die Mindestfelder des Moduls"* geschlossen
  wird — dessen Schadensargument (*„ein Byte fremden Inhalts ins Log"*) aber auf `ADR-0011`
  Festlegung 2 ruht, also auf einer **Entscheidung dieses Repos**. Der Re-Evaluierungs-Trigger
  für F2 nennt nur die Ausgänge 3, 4 und 5. Nichts fällt: das erste Bein trägt Ausgang 1 allein,
  und die ADR sagt es (*„Ein zweiter, unabhängig gemessener Grund trägt denselben Ausgang und ist
  von alledem unberührt"*). Notiert, weil die Trigger-Art-Etiketten sonst als vollständige
  Herkunftsangabe gelesen werden.

### INFO-2 — Die Geschichte von `ADR-0020` trägt nach zwei Überarbeitungen eine Zeile; `ADR-0019` trägt drei

- **kategorie:** INFO
- **pfad:** `docs/plan/adr/0020-emittierte-modul-15-regeln.md:747-749` gegen
  `docs/plan/adr/0019-agent-guard-prueft-die-aufrufform.md:447-451`
- **befund:** `07fe9b7` hat die *Proposed*-Zeile von `ADR-0020` in-place umgeschrieben, `621fcab`
  die Geschichte gar nicht angefasst; `ADR-0019` führt je Überarbeitung eine eigene Zeile
  (*„Überarbeitet, weiter Proposed"*). §3.4 bindet erst ab *Accepted*, hier ist also keine Regel
  verletzt — die zwei ADRs beantworten die Frage *„was hält die Geschichte vor der Annahme
  fest"* aber gegenläufig, und nur eine der beiden Fassungen kann Präzedenz sein. Won't-fix-Notiz,
  kein Auftrag.

---

## Ausdrücklich geprüft und REFUTED — die drei Fragen dieser Runde

**(1) Trägt das Argument gegen den sechsten Weg auch für einen Scanner, der nicht als *Beleg*,
sondern als bloße Erfassung ohne Abdeckungs-Anspruch liefe?** **Ja — auf zwei unabhängigen
Gründen, und der zweite ist von der Variante gar nicht berührt.** Erstens schließt die ADR die
Variante über den Gegenstand, nicht über die Rhetorik: sie zitiert verbatim (gegen den vendored
Baum gehalten, `modul-15-observability.md:13-14`, wortgleich) *„Ein Agenten-Lauf ohne Trace ist
ein Vorgang ohne Beleg"* und folgert *„Diese Erklärung kann eine **Erfassung** nicht abgeben"*.
Ein Scanner, der ausdrücklich auf Abdeckung verzichtet, gibt genau diese Erklärung ab — er
erfüllt den Regelblock dann nicht, sondern liefert etwas anderes; die Zelle bliebe unbelegt, statt
auf *emittiert* zu kippen. Zweitens steht in `:218-220` ein Grund, der von jedem
Abdeckungs-Anspruch unabhängig ist: *„Die zweite Verfügung, den Tool-Call zu verweigern … wiegt
auf der emittierten Ebene schwerer: ein Veto im Repo eines Adopters, aus dem Inneren einer
Telemetrie, die er nicht bestellt hat und für die er keinen Betreiber hat."* Der trifft jeden
fail-closed Scanner im Ziel, ob er Abdeckung behauptet oder nicht. Der Runde-2-MEDIUM-2 ist damit
**aufgelöst**, und zwar ohne `ADR-0011` als Träger — der Nachweis, den der Auftrag verlangte.

**(2) Hat die Regel-Fassung von 4(e) eine Lücke, die die Aufzählung nicht hatte?** **Ja, eine:**
die Aufzählung behauptete keine Vollständigkeit, die Regel tut es (*„darum hält die Bedingung sich
selbst vollständig"*) — und genau diese Behauptung ist es, die an der vendored Baseline scheitert
(MEDIUM-2). Die Regel ist im Übrigen echt und nicht bloß eine getarnte Liste: `inScope` ist als
Regel geschrieben (`templates.go:130-134`, ausdrücklich *„Bewusst als REGEL, nicht als aufgezählte
Allowlist"*), und `CommandPaths()` liefert die Command-Seite ableitbar. Die Reparatur des
Runde-2-HIGH-2 trägt: der Closure-Note-Skill steht als drittes verletzendes Dokument in ADR **und**
Plan, mit Fundort außerhalb des `StripHintBlock`-Bereichs, und die Zahlen sind reproduziert.

**(3) Gibt es bei gemeinsamem Accept eine Aussage, die dann eingefroren falsch wäre, weil die
andere sie inzwischen anders fasst?** **Ja, zwei — MEDIUM-3 und MEDIUM-4.** Beide entstehen erst
durch die Gleichzeitigkeit bzw. durch `e229690`s Umbau von `CO-002` **nach** dem ersten Schnitt
von `ADR-0020`. Ausdrücklich **nicht** betroffen: die Bewertung des Runde-1-M-6 (`ADR-0020` baut
auf `ADR-0019` auf) ist korrekt aufgelöst — `grep -n "0019"` über `ADR-0020` liefert genau eine
Zeile, den Nicht-tragend-Block, und Festlegung 2 steht auf zwei hier selbst nachgefahrenen
Null-Messungen statt auf `ADR-0019`.

---

## Negativbefunde — geprüft, ohne Befund

- **Die 55/55/0-Messung ist reproduziert, und sie ist nicht tautologisch.** Selbst gefahren über
  den ganzen Bestand: 9088 Spans, 4 Sitzungen, 2026-07-29 bis 2026-08-16; 55 Fehl-Status, **alle**
  `PostToolUseFailure`, **kein** `PostToolUse`-Span trägt einen. Die interessante Hälfte ist
  substanziell: `failed()` wertet `raw["error"]` für `PostToolUse`-Spans **sehr wohl** aus
  (`span.go:148-162`), die Null ist also eine Beobachtung und kein Konstruktionsartefakt. Die
  Zahl 8927 der ADR ist eine Momentaufnahme desselben Tages und als solche gekennzeichnet.
  **Ohne Befund** — der Runde-2-HIGH-1 ist damit nicht umformuliert, sondern entschieden.
- **Die 7/3-Messung über den Emit-Pfad ist reproduziert, Dokument für Dokument.** 14 Dokumente im
  Satz, 7 mit `make`-Nennung, 4 unauffällig (Root-README + drei Commands, ausschließlich
  `make gates`), 3 verletzend. Auch die Ausnahme trägt: `implement-slice.md` nennt `make verify-*`
  als **Muster**, nicht als Ziel — die ADR nimmt genau das vorweg. **Ohne Befund.**
- **20 / 9 / 2 / 7 / 5 stimmen.** 20 Nennungen, 9 verschiedene Ziele über die zwei Doku-Tische;
  init-invariant davon genau `gates` (5×) und `help` (1×); ohne `--lang` fehlen sieben, mit
  `--lang go` fünf. **Ohne Befund.**
- **`verify-closure-notes` existiert nirgends, mit Positivkontrolle.** 0 Zeilen / rc 1;
  `record-gates` in 19 Dateien. Die Zahl aus `slice-087` ist reproduziert. **Ohne Befund.**
- **Die neuen Verbatim-Zitate halten.** Modul 15 §Span-/Audit-Attribut-Regeln (Mindestfelder,
  Z. 33) und §Kernidee (Z. 13–14), `extract-command.awk:5`, `internal/span/span.go:5-11`,
  `slice-059:155` (21 externe Aufrufe) — je gegen die Quelle gehalten, wortgleich. Die
  Auszeichnungs-Normalisierung entspricht `ADR-0016` (*Wortlaut ohne Auszeichnung*). **Ohne
  Befund.**
- **`CO-002` hat die Nachtrags-Messung vollständig eingearbeitet — das war die ausdrückliche
  Frage.** §Begründung nennt jetzt den gemessenen Grund (*„nicht deshalb, weil der Schalter
  fehlte: ein Aufruf **mit** dem Feld wird angenommen und startet dennoch im Hintergrund
  (gemessen)"*), Weg 2 des Triggers verlangt eine **WIRKSAME** Vordergrund-Form und schließt die
  bloße Annahme ausdrücklich aus, die Geschichte trägt die Zeile. Der widerlegte Satz *„lässt
  keine zusätzlichen Felder zu"* ist aus `CO-002` **entfernt** (`git show e229690` am Carveout
  gelesen). **Ohne Befund** — die verbliebene Fundstelle liegt im Spec-Stratum (HIGH-1).
- **`CO-002`s Ein-Schwellen-Fassung widerspricht weder der ADR noch `slice-086`.** ADR-0019
  Festlegung 4 schließt seit `e229690` mit *„der Span eines zurückgenommenen Messaufbaus löst
  `CO-002` nicht auf — dessen Schwelle steht dort und verlangt die committete Mechanik dazu"*;
  `CO-002` §Folge-Slice sagt *„Der Messaufbau selbst löst diesen Carveout nicht auf"*;
  `slice-086` DoD (3) sagt *„erst danach wird verdrahtet, und erst danach löst sich `CO-002`
  auf"*. Drei Artefakte, eine Schwelle. Der Runde-2-MEDIUM-2 ist aufgelöst. **Ohne Befund** — der
  einzige Rest ist die halbe Fassung in `slice-071` (LOW-3) und die Zustands-Ablesbarkeit in
  `ADR-0020` (MEDIUM-3), beides außerhalb dieser drei.
- **Die Zeiger der `CO-002`-Geltungs-Konfiguration stehen.** `grep -c "CO-002"` → Guard 1,
  Spec 5 — die Tabelle beschreibt sie weiterhin richtig. **Ohne Befund.**
- **Die Rollen-Zählung der Positiv-Konsequenz ist exakt.** Fünf Rollen im Bestand (architect,
  implementer, planner, reviewer, verifier), `validator` **null**, am 2026-08-15 selbst **drei**
  (architect, planner, reviewer) — jede Zahl selbst gefahren, jede stimmt. Der Runde-2-MEDIUM-1
  ist aufgelöst, ohne eine neue Zusage einzuführen; dass die Ableitung im Emitter und nicht eine
  Beobachtung für alle sechs trägt, steht ausdrücklich daneben. **Ohne Befund.**
- **Die Glied-Benennung ist an allen Fundorten dieselbe.** ADR (`:427-428`, `:434`, `:726-728`),
  `slice-062` (`:41`, `:104`, `:236-241`) und `welle-09:132` sagen übereinstimmend
  *Erfassungs-Glied* / *Zähler-Glied*; keine Ordinalzahl mehr. Der Runde-2-MEDIUM-4 ist aufgelöst.
  **Ohne Befund.**
- **`slice-062` §3 trägt keine zweite Fassung der Abzählung mehr.** Der Absatz ist durch einen
  Verweis ersetzt (*„Die Abzählung selbst schuldet die ADR … verwiesen, nicht abgeschrieben"*);
  die widerlegten Sätze *„keiner steht in unserer Hand"* und *„der polymorphe Wert ist `error`"*
  sind im ganzen Plan-Baum nicht mehr auffindbar. Auch der MEDIUM-5-Satz ist gedreht (*„**Keine**
  von ihnen trägt einen Auflösungs-Trigger"*). **Ohne Befund.**
- **`welle-09`s Carveout-Audit nennt jetzt `CO-002`** (`:126-127`) und `slice-071` sagt
  ausdrücklich *„`CO-002` ist KEINE Eintritts-Bedingung"* (`:137`) — die zwei offenen
  ADR-0019-Runde-2-Punkte (MEDIUM-4, LOW-4) sind auf der Plan-Ebene geschlossen. **Ohne Befund.**
- **Der Doku-Gate über dem geänderten Bestand ist grün.** `make docs-check` →
  `323 Datei(en) geprüft, 0 Befund(e)`, Exit 0; alle neuen Links und Anker halten. **Ohne Befund.**
- **`AGENTS.md` §3.8 ist in allen vier geprüften Commits gewahrt.** `e229690` und `621fcab`
  berühren ausschließlich Architect-Artefakte (ADR, Index, Carveout), `9ada41d` und `0b6c676`
  ausschließlich Plan-Artefakte; `1b3401a` ändert Spec und einen Mutations-Fall und trägt keine
  Rolle im Betreff — für diese Klasse benennt §3.8 keine schreibende Rolle. Keine Vermischung.
  **Ohne Befund.**
- **§3.3 und §3.2.** Kein `git mv` mit Inhaltsänderung, keine neue `# shellcheck disable`- oder
  `//nolint`-Zeile in den geprüften Commits. **Ohne Befund.**
- **§3.4.** Beide ADRs stehen weiter auf *Proposed*; keine Accepted-ADR ist angefasst. **Ohne
  Befund** (die Geschichts-Führung ist INFO-2, keine Regelverletzung vor der Annahme).
- **Das Vertrags-Stratum ist von den zwei ADR-0020-Commits unberührt**; `spec/**` kommt in
  `621fcab` und `0b6c676` nicht vor. Für `ADR-0019` ist es berührt, und dort liegt HIGH-1. **Ohne
  Befund für 0020.**
- **Ist durch die geprüften Commits etwas still durchlässig geworden?** Keiner berührt Guard,
  Extraktor, `Makefile`, `.d-check.yml`, `settings.json`, `internal/emit/**` oder `test/**` —
  die einzige Code-nahe Änderung der Runde ist `test/mutations/120` in `1b3401a`, und dort nur
  Kommentarzeilen. **Ohne Befund.**
- **Was ich NICHT geprüft habe, und das gehört gesagt:** ein Lauf an einem wirklich
  gebootstrappten Ziel (`make full-smoke`, Verifier-Arbeit); die sechs `targets`-Sonden gegen das
  gepinnte Image (Runde 2 hat sie unabhängig reproduziert, diese Runde greift sie nicht an); der
  Inhalt der ADRs `0003`, `0007`, `0012`, `0013` über ihre hier zitierten Stellen hinaus; alles,
  was Runde 1 und Runde 2 bereits bestätigt haben.

---

## Kategorie-Summary

| Kategorie | `ADR-0019` | `ADR-0020` | gesamt | IDs |
|---|---|---|---|---|
| HIGH | 1 | 0 | 1 | 0019-HIGH-1 |
| MEDIUM | 1 | 4 | 5 | 0019-MEDIUM-1 · 0020-MEDIUM-1 … 0020-MEDIUM-4 |
| LOW | 3 | 2 | 5 | 0019-LOW-1 … LOW-3 · 0020-LOW-1, LOW-2 |
| INFO | 0 | 2 | 2 | 0020-INFO-1, INFO-2 |

---

## Verdikt — je ADR getrennt

### `ADR-0019` — **blockiert**

**Blockierend ist HIGH-1.** Die Überarbeitung `e229690` erklärt die Schema-Selbstauskunft
*„keine zusätzlichen Felder"* ausdrücklich für **widerlegt** und macht diese Widerlegung zum
tragenden Grund von Festlegung 1. `spec/spezifikation.md:164` — eine der fünf Stellen, auf die
`CO-002` §Geltungs-Konfiguration namentlich zeigt — führt sie unverändert als Tatsache, acht
Zeilen über ihrer eigenen Korrektur im selben Aufzählungspunkt. Die ADR erklärt in §Schärft die
Änderungskopplung nach oben zur eigenen Pflicht; sie ist an dieser Stelle nicht vollzogen. Mit
*Accepted* friert §3.4 den ADR-Text ein, und die Korrektur der Asymmetrie kostet danach eine
Folge-ADR. Es ist die **dritte Runde** derselben Klasse (Runde 1 MEDIUM-1, Runde 2 HIGH-1) — nach
Modul 10 §Kontext-Eskalation ein Steering-Loop-Signal: die Klasse *„lebendes Artefakt führt eine
Aussage, die eine ADR als widerlegt bezeichnet"* hat in diesem Repo keinen Sensor, und drei
Runden Handarbeit sind der Beleg dafür.

**Ebenfalls vor der Annahme fällig, weil in der ADR selbst und damit ab *Accepted*
unveränderlich:** MEDIUM-1 (der vierte `Agent`-Span desselben Tages steht in der ADR, und zwei
Absätze tiefer heißt es *„drei … kein Rest"*) sowie LOW-1 und LOW-2, beide mit je einem Satz
erledigt. LOW-3 liegt im Plan und blockiert nicht.

**Ausdrücklich nicht beanstandet, und das ist der größere Teil:** die Reparatur trägt. Der
tragende Grund heißt jetzt, was gemessen ist, und die drei Aussagen stehen getrennt und je
datiert; Festlegung 4 hat eine gemessene Prämisse und genau eine offene Frage; Annahme (a) und
der erste Re-Evaluierungs-Trigger verlangen **Wirksamkeit** statt Annahme des Feldes; die
Rollen-Zählung ist auf jede einzelne Zahl nachgemessen und stimmt, samt der ehrlichen Grenze,
dass für alle sechs die Ableitung trägt und nicht eine Beobachtung; `CO-002` hat wieder **eine**
Schwelle, und sie ist mit `ADR-0019` Festlegung 4 und `slice-086` DoD (3) deckungsgleich; Sonde 1
hat mit Folgepflicht 5 einen Träger bekommen. Blockiert ist ein einzelner nicht nachgezogener
Satz im Spec-Stratum, nicht die Entscheidung.

### `ADR-0020` — **blockiert**

**Kein HIGH.** Beide Runde-2-HIGH sind entschieden statt umformuliert, und beide Entscheidungen
habe ich unabhängig nachgemessen: die 55/55/0-Messung trägt und ist nicht tautologisch, die
7/3-Messung über den Emit-Pfad stimmt Dokument für Dokument. Auch der gefährliche MEDIUM (der
sechste Weg) ist geschlossen, auf einem Argument, das auf der emittierten Ebene hält, `ADR-0011`
nicht braucht und die letzte denkbare Variante — Erfassung ohne Abdeckungs-Anspruch — mitträgt.

**Blockierend sind die vier MEDIUM** (Modul 10 §Ablage: HIGH und MEDIUM blockieren typischerweise;
eine Abweichung sehe ich hier nicht, weil §3.4 alle vier einfriert):

- **MEDIUM-1** — die Fitness Function beschreibt zum zweiten Mal in Folge die Messmethode falsch;
  `full-smoke` bootstrappt vier tmp-Repos, und das Plan-Artefakt vom selben Tag sagt es mit
  Zeilennummern richtig. Bei gemeinsamem Accept trägt das Repo zwei lebende, widersprüchliche
  Zahlen über dasselbe Skript, eine davon eingefroren.
- **MEDIUM-2** — die Vollständigkeits-Behauptung von 4(e) steht gegen den eigenen Satz *„Das
  Werkzeug emittiert das Regelwerk vollständig ins Ziel"*; der ausgeschlossene Teil trägt real
  `make`-Ansprüche, die in keiner Variante existieren, und der Ausschlussgrund steht nirgends.
- **MEDIUM-3** und **MEDIUM-4** — die zwei Aussagen, die ein **gemeinsamer** Accept falsch macht
  bzw. seit `e229690` nicht mehr trifft. Sie sind der eigentliche Ertrag der Kopplungs-Prüfung.

LOW-1, LOW-2 und die zwei INFO blockieren nicht.

**Was ausdrücklich hält:** die vier Zellwerte stehen unverändert, und keiner von ihnen ist in
dieser Runde angegriffen worden — beanstandet sind wieder die Sätze, mit denen sie begründet
werden, und weil §3.4 sie einfriert, ist der Unterschied nicht akademisch. Der Trichter-Ausgang
trägt: Frage 1 beantwortet jetzt **beide** Auslöser und schließt den Cluster-Einwand über den
Träger statt über eine Zahl; Frage 2 steht auf dem Wortlaut des Moduls statt auf einem aus
`CO-002` geliehenen Maßstab, und die Abgrenzung gegen `CO-002` ist ausgeschrieben; jeder der fünf
Ausgänge trägt seine Trigger-Art. Der Anspruchs-Weg aus 4(e)/4(c) ist die richtige Antwort auf
Runde-1-HIGH-2, seine Wirkung ist in zwei Runden unabhängig nachgemessen, und die Menge, über die
er quantifiziert, ist gegenüber Runde 2 von zwei auf sieben Dokumente korrekt erweitert.

---

**Übergabe:** 0019-HIGH-1 an den **Eigentümer des Spec-Stratums** (`spec/spezifikation.md:163-164`)
und nachrichtlich an den **Architect** (die ADR-Aussage ist richtig, der Nachzug fehlt);
0019-MEDIUM-1, LOW-1, LOW-2 an den **Architect** (`ADR-0019`); 0019-LOW-3 an den **Planner**
(`slice-071`). 0020-MEDIUM-1, MEDIUM-2, MEDIUM-3, MEDIUM-4 und LOW-1 an den **Architect**
(`ADR-0020`, und für MEDIUM-3 die Frage, ob `CO-002` oder `ADR-0020` den dritten Zustand trägt);
0020-LOW-2 an den **Planner** (`slice-087` DoD (2)). Als Steering-Loop-Kandidat an den
**Auftraggeber**: die Klasse hinter 0019-HIGH-1 hat nach drei Runden noch keinen Sensor.

**In diesem Lauf ist nichts geändert und nichts committet worden;** `git status --porcelain` war
vor und nach der Prüfung leer, die einzige geschriebene Datei ist dieser Report.
