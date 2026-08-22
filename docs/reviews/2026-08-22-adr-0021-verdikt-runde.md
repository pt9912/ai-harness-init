# ADR-0021 (Proposed) — Verdikt-Runde (Bestätigungsrunde 3)

**Rolle:** Reviewer (Modul 10). **Datum:** 2026-08-22. **Lauf:** frischer Kontext, Subagent
`reviewer`, **dritte** Runde zu dieser ADR.

**Review-Art:** Design-Review — die überarbeitete ADR gegen die ADR-Lage, gegen das Regelwerk und
gegen die Findings der zweiten Runde, vor dem Statuswechsel, den [`AGENTS.md`](../../AGENTS.md)
§3.4 unumkehrbar macht.

**Gegenstand:** `24d06de` — ein Commit, zwei Dateien:
`docs/plan/adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md` (+139/−53, jetzt 725 Zeilen) und die
Index-Zeile `docs/plan/adr/README.md:29`. Gegenlage: `e401e17` (Runde-2-Report). HEAD `24d06de`,
Arbeitsbaum vor und nach dem Lauf sauber.

**Skill:** `.harness/skills/reviewer.md` @ 1.4.0 · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-5[1m] · **Datum:** 2026-08-22

**Eingangs-Kontext (die fünf Pflicht-Punkte plus Plan-Bezug):**

- **Diff/Range:** `e401e17..24d06de`, beschränkt auf die zwei genannten Dateien (am `--name-only`
  geprüft).
- **Betroffene `LH-*`:** `LH-QA-01`, `LH-QA-02`, `LH-QA-03`.
- **Referenzierte aktive ADRs (Status je selbst geprüft):** `ADR-0011`, `ADR-0012`, `ADR-0016`,
  `ADR-0017`, `ADR-0019`, `ADR-0020` (alle **Accepted**); dazu `CO-002`, `CO-001`,
  `docs/plan/carveouts/README.md`, `spec/spezifikation.md` §5, `welle-09` §3, `.d-check.yml`,
  `harness/conventions.md` §MR-000/§MR-025, `.harness/baseline/v3.5.2/regelwerk/modul-07-carveouts.md`.
- **Hard Rules:** [`AGENTS.md`](../../AGENTS.md) §3.1–§3.8.
- **Vorherige Findings am gleichen Modul:**
  [`2026-08-22-adr-0021-bestaetigungsrunde.md`](2026-08-22-adr-0021-bestaetigungsrunde.md) (3 HIGH,
  3 MEDIUM, 2 LOW, 2 INFO) und
  [`2026-08-22-adr-0021-bestaetigungsrunde-runde-2.md`](2026-08-22-adr-0021-bestaetigungsrunde-runde-2.md)
  (4 MEDIUM, 1 LOW) — jedes unten mit Status und Beleg.
- **Plan-Bezug:** `docs/plan/planning/open/slice-089-carveout-co-002-ueberfuehren.md`.

**Nicht meine Rolle:** DoD-Abhakung, Gate-Lauf als Erfolgsmeldung, Lösungsvorschläge, Änderungen an
der ADR. **Nichts committet, außer diesem Report nichts geschrieben.** Alle Sonden liefen in
Wegwerf-Kopien außerhalb des Repos und sind nach dem Lauf entfernt. Der Span-Bestand wurde
**nicht** geöffnet — Festlegung 3 dritter Punkt deckt diesen Weg ausdrücklich, und N-3 unten ist
ohne ihn belegt.

**Selbst gefahren — Kommando und Ergebnis:**

| Kommando | Ergebnis |
|---|---|
| `make docs-check` (Ist-Stand `24d06de`) | `339 Datei(en) geprüft, 0 Befund(e)`, Exit 0 |
| `grep -n 'nicht erfüllbar'` über ADR **und** Index | **leer, Exit 1** |
| `grep -n 'Bedingung, unter der'` über ADR **und** Index | **leer, Exit 1** |
| `grep -nE '79 Befund\|81 Befund\|82 Befund\|84 Befund\|85 Befund\|von 79 auf'` über ADR und Index | **leer, Exit 1** — keine wandernde Summe mehr im Text |
| **Sonde A** — Wegwerf-Kopie, `git mv` des Stubs nach `done/`, derselbe digest-gepinnte d-check | Exit 1. `awk -F'\t' 'NF>1{print $NF}' <ausgabe> \| sort -u` → **eine Zeile**, `target-missing` (Kommando und Ergebnis wie in der ADR). `grep -cE '^docs/plan/adr/(0019\|0020)-'` → **18**, `…0019-` → **13**, `…0020-` → **5** — **die drei Zahlen der ADR exakt**. Die Summe des Laufs steht heute bei 84 (Runde 1: 79, Runde 2: 81) — genau die Wanderung, die die ADR jetzt als Grund nennt, keine Summe zu drucken |
| **Sonde B** — dieselbe Kopie, `links.resolve-from` mit `dirs: [docs/plan/carveouts, docs/plan/carveouts/done]` | 18er-Filter → **18, unverändert**; `grep -c 'link-position-dependent'` → **3** |
| **Sonde B′** — dieselbe Option **plus** `fixed-dirs: [docs/plan/adr]` | 18er-Filter → **18, unverändert**; lpd → **3**, byte-gleiche Trefferliste wie B |
| Trefferliste der 3 `link-position-dependent` (B und B′) | `CO-001-bats-shell-lint.md:15`, `:58` und `docs/plan/carveouts/README.md:16`; **auf `CO-002` keiner** (`grep -c CO-002` → 0) — wie die ADR sagt |
| **Sonde C** — dieselbe Kopie, `codepaths.ignore-refs: [docs/plan/carveouts/**]` | 18er-Filter → **18, unverändert**, lpd → 0 — die Option ist modul-lokal, wie die ADR sagt |
| `d-check --print-config` gegen denselben Digest | `links` trägt genau eine Options-Sektion, `resolve-from`, verbatim *„Quellen: Dateien hier muessen von JEDEM Ort der Gruppe aufloesen (>= 2)"* plus `fixed-dirs`; **kein** Ausschluss innerhalb `links` |
| **Sonde E** — Wegwerf-Kopie, **vollständiger** Vollzug von Folgepflicht 1 (alle **vier** Änderungen an `CO-002` **und** der Index-Abschnitt) | `339 Datei(en) geprüft, **0 Befund(e)**`, Exit 0; die drei Prüfkommandos danach je **leer (Exit 1)** |
| **Sonde F** — dieselbe Form, aber Änderung (4) nur als **eine gelöschte Zeile** statt als ganzer Abschnitt | alle drei Prüfkommandos **leer**, `make docs-check` **0 Befund(e)** — und der Abschnitt *Verifikation (nach Auflösung)* steht mit vier Haken weiter da (Befund **V-2**) |
| die drei Prüfkommandos aus Folgepflicht 1 über `CO-002` **heute** | `grep -n 'zu verschieben'` → **1 Zeile (`:113`)**; `grep -n 'carveouts/done'` → **1 Zeile (`:142`)**; `grep -n 'd-check:ignore'` → **1 Zeile (`:142`)** — jedes trifft genau die gemeinte Zeile |
| das breitere Muster `grep -n 'done/'` über `CO-002` | **5 Zeilen** (`:26`, `:97`, `:113`, `:142`, `:150`), davon **3** legitime Verweise auf ein abgeschlossenes Planungs-Artefakt — die Untauglichkeits-Aussage der ADR trägt |
| `grep -n 'toolu_0181irqRbg1FHcsrfRaBmpA1'` über das Repo | genau zwei Fundorte: die ADR (`:338`) und `docs/reviews/2026-08-21-updatedinput-messung.md:241` — dort ist es die `tool_use_id` von **Lauf 1**, dem Splice-Lauf mit eingesetztem `run_in_background: false`, `2026-08-21T18:29:51Z` |
| `grep -oE '\]\([^)]+\)' <F> \| wc -l` über `ADR-0019`/`0020`/`0013` | 49 / 66 / **27** — die Zahlen des Weg-2-Preises unverändert exakt |
| `grep -ln 'responseKeys' test/mutations/*.sh` | **leer, Exit 1** |
| `grep -n 'slice-[0-9]'` über die ADR | **leer, Exit 1** |
| `git show --pretty=format: --name-only 24d06de` | genau zwei Architect-Artefakte; Message beginnt mit *„Rolle Architect:"* (§3.8) |

**Nicht wiederholt, weil unverändert und zweimal belegt:** die Mutations-Sonde zu Festlegung 2
(zwei Cache-Zähler aus `responseKeys()` → `TestNoResponseFreetextReachesSpan` rot,
`TestOnlyAgentToolGetsResponseValues` grün). Der Diff berührt an dieser Stelle nur den Kommentar
im Code-Block, nicht die Zusage; die Läufe stehen in den Runden 1 und 2.

**Gelesen, nicht gefahren:** `.harness/baseline/v3.5.2/regelwerk/modul-07-carveouts.md` §Ziel-Form
**vollständig, alle vier Bullets** / §Werkzeug-Wahl / §Carveout-Audit-Slice ·
`docs/plan/carveouts/CO-002-…` ganz · `docs/plan/adr/0012-…` §Kontext ·
`docs/plan/adr/0017-…:95-130` · `docs/plan/adr/0020-…:430-455` ·
`harness/conventions.md` §MR-000 und §MR-025 ganz · `AGENTS.md` §3.8 §Warum diese zwei ·
`docs/reviews/2026-08-21-updatedinput-messung.md:176-247` ·
`docs/plan/planning/open/slice-089-…`.

---

## Status der Findings aus Runde 2

| Runde 2 | Status | Beleg |
|---|---|---|
| **N-1** — die tragende Zahl war 81 statt 79, „6 in dieser ADR" war 8 | **behoben, und besser als korrigiert** | Statt die Summe zu berichtigen, druckt die ADR **keine** Summe mehr und misst stattdessen die Teilmenge, die nicht wandern kann: `grep -cE '^docs/plan/adr/(0019\|0020)-'` → 18, mit zwei Unterfiltern 13 und 5. Selbst gefahren: **18 / 13 / 5**, exakt. Die Wanderung ist damit belegt statt behauptet — dieselbe Sonde liefert heute 84, in Runde 2 lieferte sie 81, in Runde 1 79. Die Begründung nennt `MR-025` Setzung 2 und ist an drei Folgestellen konsistent nachgezogen: Fitness-Block (*„Die Summe des Laufs wandert und steht deshalb nirgends in dieser ADR"*), Geschichte-Zeile (*„Wandernde Summen stehen nicht mehr im Text"*) und Index-Zeile (*„die Summe des Laufs wandert und steht deshalb nirgends"*). **Ist die Teilmenge wandersicher?** Ja, mit der Begründung, die die ADR gibt: beide Dateien sind §3.4-immutabel, ihre ausgehenden Verweise stehen fest. Und die ADR überdehnt es nicht — sie sagt ausdrücklich, dass ein weiterer Teil auf **diese** ADR entfällt, *„die mit ihrer Annahme in denselben Zustand tritt"*, und beziffert ihn nicht |
| **N-2** — die §Ziel-Form-Klammer als Move-Bedingung | **behoben; das Konstrukt trägt, mit einer Lücke im ersten Bein → V-1** | Beide Belegkommandos selbst gefahren: `grep -n 'nicht erfüllbar'` und `grep -n 'Bedingung, unter der'` über ADR **und** Index → **beide leer**. Die Klammer wird jetzt ausdrücklich zurückgewiesen, mit dem Grund, den ich in Runde 2 gemessen hatte (`CO-002` führt als betroffenes Gate *„keines"*), und mit dem Folge-Schaden benannt (*„der nächste, der einen Carveout wirklich auflöst … könnte sie zitieren"*). Die Zwei-Bein-Konstruktion ist sauber getrennt: Bein 1 = **Erlaubnis** aus der Quelle, Bein 2 = **Wahl** aus der Messung. **Bein 2 trägt und überdehnt die 18 nicht:** sie belegen, dass Weg 1 dauerhaft rot bliebe und Weg 2 eine Senkung kaufen müsste; die Weg-Tabelle nennt beide Preise getrennt. **Bein 1 ist unvollständig** — Finding **V-1** |
| **N-3** — das Kommando von Annahme (d) traf die Zeile nicht | **behoben** | Der Fundschlüssel ist jetzt die `tool_use_id`, kein `tail -1`. Ohne Öffnen des Bestands geprüft: `toolu_0181irqRbg1FHcsrfRaBmpA1` ist ausweislich `docs/reviews/2026-08-21-updatedinput-messung.md:241` die Kennung von **Lauf 1** — dem Lauf mit eingespeistem `run_in_background: false`, also genau dem Gegenstand von Annahme (d), nicht dem Kontroll-Lauf. Dasselbe Zeitdokument erklärt die `tool_use_id` zum eindeutigen Fundschlüssel und `seq` zum mehrdeutigen; die ADR gibt beide Gründe wieder und nennt zusätzlich `spec/spezifikation.md` §5 Abweichung 4 (Bestand wird nie aufgeräumt). Die Grenze *„auf einem fremden Checkout gibt dasselbe Kommando nichts aus"* steht ausdrücklich dabei. **Das Kommando ist ordnungs- und zeitunabhängig und trifft die gemeinte Zeile** |
| **N-4** — zwei Ort-Anweisungen im Carveout unadressiert | **behoben** | Das Ort-Inventar führt jetzt **vier** Stellen, die vierte ist der Carveout selbst, und beide Anweisungen sind verbatim zitiert. Festlegung 5 hebt sie namentlich auf; Folgepflicht 1 zählt **vier** Änderungen an `CO-002` und **drei** Prüfkommandos, mit dem ausgesprochenen Grund, dass zwei der Änderungen keinen Link brechen. **Alle drei Kommandos selbst gefahren: jedes trifft heute genau eine Zeile**, und es sind die gemeinten (`:113`, `:142`, `:142`). Die Untauglichkeits-Aussage über das breitere Muster ist ebenfalls exakt: `grep -n 'done/'` trifft 5 Zeilen, davon 3 legitime. **Sonde E** über den vollständigen Vollzug: `0 Befund(e)`, Exit 0. Residual im Prüfumfang → **V-2**; Residual im Zitat → **V-3** |
| **N-5** — der Absatz argumentierte über ein Zahlen-Delta | **behoben** | Der Absatz argumentiert jetzt strukturell: `resolve-from` ist **quellenseitig**, die 18 sind **eingehende** Verweise aus Dateien außerhalb jeder Gruppe. Alle Invarianten selbst gefahren und exakt: `dirs` allein und `dirs` + `fixed-dirs` lassen die 18 **unverändert** (18/18), erzeugen je **3** `link-position-dependent`, und **alle drei** liegen auf `CO-001` und dem Carveout-Index, **keiner** auf `CO-002`; `codepaths.ignore-refs` lässt alles stehen. Der Satz *„Diese Begründung überlebt einen Werkzeug-Sprung; ein Zahlen-Delta täte es nicht"* trifft genau |

**Keine Regression:** kein in Runde 1 oder 2 behobener Punkt ist wieder aufgetaucht. Der Text ist
zwischen Kontext, Festlegung 5, Folgepflicht 1 und Index-Zeile durchgehend konsistent (einzeln
gegengelesen); die Weg-3-Zeile der Alternativen-Tabelle ist auf die neue Begründung nachgezogen.

---

## Findings

### V-1 — Der Erlaubnis-Beleg erklärt sein Inventar für vollständig und lässt den einen Regelwerks-Satz aus, der `carveouts/` und *permanent* in einem Satz nennt — die ADR zitiert ihn sechs Zeilen vorher selbst

- **kategorie:** MEDIUM
- **quelle:** Regelwerk `v3.5.2`, `modul-07-carveouts.md` §Ziel-Form, erster Bullet (verbatim:
  *„Fehlt der Folge-Slice, ist der Carveout de facto permanent — dann gehört er nicht in
  `carveouts/`, sondern über den Trichter unten in eine ADR."*);
  [`AGENTS.md`](../../AGENTS.md) §3.6 (*„benennen, was wirklich deckt — oder dass nichts deckt"*)
  und §3.8 §Warum diese zwei (*„Die Regel füllt damit eine **Lücke**, statt von der Baseline
  abzuweichen — deshalb steht zu ihr **kein** Eintrag im Adaptions-Block
  ([`MR-000`](../../harness/conventions.md#mr-000--baseline-aussage))"*)
- **pfad:** `docs/plan/adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md:128-129` und `:143-146`
  (das Inventar und sein Negativbefund), `:425-430` (Bein 1 in Festlegung 5), `:541-549`
  (Folgepflicht 7) gegen `:120-122` derselben Datei
- **befund:** Das Inventar eröffnet mit *„**Vier Stellen sprechen über den Ort, und keine schreibt
  diesen Fall vor.** Drei stehen im Regelwerk"* und schließt mit dem Negativbefund, der Bein 1
  trägt: *„im Regelwerk steht **kein** Satz, der für einen **gelebten, übergeführten** Carveout ein
  Verzeichnis vorschreibt"*. Von §Ziel-Form ist dabei nur der `git mv`-Bullet gelesen. Der **erste**
  Bullet derselben Sektion nennt `carveouts/` ausdrücklich zusammen mit *permanent* — und die ADR
  druckt ihn **sechs Zeilen vorher** vollständig ab und verwendet seine **Vorbedingung**
  affirmativ, um den ADR-Pfad zu begründen (*„Der Folge-Slice existierte, hat seinen Gegenstand
  geliefert und ist damit verbraucht"*). Damit wird derselbe Satz zur Hälfte benutzt und zur
  Hälfte nicht erwähnt, während das Inventar Vollständigkeit behauptet. **Der Bauplan hat es
  anders gemacht:** [ADR-0012](../plan/adr/0012-haupt-kontext-ohne-token-bilanz.md) §Kontext
  zitiert genau diesen Bullet und stellt sofort klar — *„**Der Satz greift hier nach seiner Logik,
  nicht nach seinem Buchstaben, und das gehört gesagt**"* —, warum sein Buchstabe den eigenen Fall
  nicht trifft. **Und die Lücke wirkt in eine offene Folgepflicht hinein:** trägt Bein 1, ist die
  Ablage-Frage im Regelwerk eine **Lücke**, und nach `AGENTS.md` §3.8/`MR-000` gehört zu einer
  Lücke **kein** Adaptions-Eintrag; Folgepflicht 7 ordnet aber genau einen an und nennt als seinen
  Inhalt *„die Setzung … ihren Anlass … und diese ADR als Entscheidung"*. Ob der Eintrag eine
  Abweichung oder eine Lückenfüllung verzeichnet, entscheidet dieser Satz — und die ADR
  disponiert ihn nicht.
- **gegenbeispiel:** Der Architect-Lauf zu Folgepflicht 7 öffnet `modul-07-carveouts.md`, um die
  Abweichung zu formulieren, und findet im ersten Bullet der §Ziel-Form *„dann gehört er nicht in
  `carveouts/`"*. Entweder er schreibt einen `MR`-Eintrag, der einer eingefrorenen ADR
  widerspricht (sie sagt, kein Satz schreibe etwas vor), oder er schreibt keinen — und dann steht
  eine unerfüllte Folgepflicht in einer immutablen ADR. Dieselbe Stelle trifft jeden späteren
  Leser, der die Vollständigkeits-Behauptung nachprüft: er findet in **einer Sektion**, die die ADR
  gelesen zu haben erklärt, einen vierten Satz und kann nicht entscheiden, ob er übersehen oder
  bewusst verworfen wurde.
- **verifizierbar:** nein, nicht maschinell — kein `.d-check.yml`-Modul liest, ob ein Inventar
  vollständig ist. Am Text belegbar:
  `sed -n '/^### Ziel-Form: Carveout/,/^<a id="werkzeug-wahl"/p' .harness/baseline/v3.5.2/regelwerk/modul-07-carveouts.md`
  (vier Bullets, der erste nennt `carveouts/`) gegen
  `sed -n '120,122p;128,146p' docs/plan/adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md`.

### V-2 — Änderung (4) ist als „der Abschnitt fällt als Ganzes" definiert, ihr Prüfkommando sieht eine von fünf Zeilen — gemessen bleibt der Abschnitt stehen, und alles ist grün

- **kategorie:** LOW
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 (*„benennen, was wirklich deckt"*);
  Regelwerk `v3.5.2`, `modul-07-carveouts.md` §Werkzeug-Wahl bei Diskrepanz (*„ADR: Trigger fällt
  weg, Checkliste reduziert auf die Architektur-Folgen"*)
- **pfad:** `docs/plan/adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md:556-570` (Folgepflicht 1,
  Änderung (4) und ihr Prüfkommando) gegen
  `docs/plan/carveouts/CO-002-token-achse-je-rolle.md:138-146`
- **befund:** Änderung (4) lautet *„der Abschnitt *Verifikation (nach Auflösung)* fällt als
  Ganzes, samt seinem `git mv`-Haken und dessen `d-check:ignore`-Direktive"*. Ihr Prüfkommando ist
  `grep -n 'carveouts/done'` → leer; es prüft **eine** der fünf Zeilen des Abschnitts.
  **Sonde F, gefahren:** wird nur die eine Zeile gelöscht, sind alle drei Prüfkommandos leer und
  `make docs-check` meldet `0 Befund(e)` — während der Abschnitt mit vier unerledigten Haken unter
  einem Kopf steht, der `Permanent — übergeführt in ADR-0021` trägt, darunter *„[ ] `make gates`
  grün ohne Ausnahme"* und *„[ ] Folge-Slice geschlossen oder explizit dokumentiert"*.
- **gegenbeispiel:** Der Implementer vollzieht Folgepflicht 1 und orientiert sich an den drei
  Prüfkommandos, die die ADR ausdrücklich *„statt Erinnerung"* setzt. Alles ist grün, der Verifier
  hakt ab, und die Weiche trägt weiter eine Verifikations-Checkliste für eine Auflösung, die diese
  ADR ausgeschlossen hat — genau die Klasse, die Festlegung 5 für die zwei anderen Zeilen
  beseitigt hat.
- **verifizierbar:** ja, gefahren — Sonde F oben; kein Gate sieht den Unterschied (Sonde E und
  Sonde F liefern dieselbe d-check-Ausgabe).

### V-3 — Festlegung 5 zitiert „Trigger fällt weg, Checkliste reduziert" und vollzieht nur die zweite Hälfte; der Auflösungs-Trigger bleibt im Stub stehen, ohne dass das gesagt wird

- **kategorie:** LOW
- **quelle:** Regelwerk `v3.5.2`, `modul-07-carveouts.md` §Werkzeug-Wahl bei Diskrepanz (*„ADR:
  Trigger fällt weg, Checkliste reduziert auf die Architektur-Folgen"*); ADR-0021 Festlegung 1
  (*„kein Auflösungs-Trigger"*); [ADR-0012](../plan/adr/0012-haupt-kontext-ohne-token-bilanz.md)
  Folgepflicht 1 (*„Ein zweiter Ort driftet"*)
- **pfad:** `docs/plan/adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md:462-470` (Festlegung 5,
  letzter Absatz vor der Weichen-Aussage) gegen
  `docs/plan/carveouts/CO-002-token-achse-je-rolle.md:67-118`
- **befund:** Festlegung 5 belegt das Fallen der Checkliste mit einem Modul-Satz, der **zwei**
  Hälften hat, und vollzieht die zweite. Von der ersten — *„Trigger fällt weg"* — fällt nur die
  Ort-Anweisung **innerhalb** des Auflösungs-Triggers (Änderung (3)); der Abschnitt
  `## Auflösungs-Trigger` selbst bleibt, mit seiner Schwelle (*„ein `Agent`-Span trägt wieder
  `spawned_role` **und** alle vier `usage`-Zähler …"*), den drei Wegen und dem Satz *„Ein Carveout,
  der nach einer negativen Messung stehen bliebe, wäre die permanente Ausnahme, die behauptet,
  temporär zu sein."* Weder wird das vollzogen noch als bewusst nicht vollzogen erklärt. **Es gibt
  einen guten Grund für das Stehenlassen** — die ADR **zitiert** diesen Abschnitt zweimal verbatim
  (`:114-118`), und ADR-0019 verweist darauf; eine Löschung machte ein Zitat einer immutablen ADR
  quellenlos. Genau dieser Grund steht nicht im Text.
- **gegenbeispiel:** Das Carveout-Audit einer späteren Welle folgt Folgepflicht 4 und liest den
  Status statt des Verzeichnisses — findet aber im selben Dokument einen Abschnitt
  *Auflösungs-Trigger* mit messbarer Schwelle, während Festlegung 1 *„kein Auflösungs-Trigger"*
  sagt. Er hat zwei Fassungen derselben Bedingung vor sich (die dritte steht als
  Re-Evaluierungs-Trigger 1–3 in der ADR) und keine Aussage darüber, welche gilt.
- **verifizierbar:** nein, nicht maschinell. Am Text belegbar:
  `grep -n '^## ' docs/plan/carveouts/CO-002-token-achse-je-rolle.md` gegen
  `sed -n '462,470p' docs/plan/adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md`.

---

## Negativbefunde

- **geprüft, ohne Befund — `MR-025` über den gesamten neu geschriebenen Text.** Jede Zahl mit
  Messwert-Rolle trägt ihr Kommando, und ich habe **jedes** nachgefahren: `18`/`13`/`5` (drei
  Filter), *„eine Zeile"* aus dem `awk`-Sortierlauf, `3` `link-position-dependent`, `2` Carveouts,
  `27` / `49` / `66` / `18` / `23` / `21` / `56` / `6` im Weg-2-Preis, `leer (Exit 1)` für
  `responseKeys`, die drei Prüfkommandos, `5`/`3` beim breiteren `done/`-Muster, `0 Befund(e)` für
  Weg 3. **Alle exakt.** Die eine Zahl, deren Kommando in **diesem** Lauf nicht gefahren wurde —
  *„eine Zeile"* in Annahme (d) —, trägt die von `MR-025` Setzung 1 verlangte Offenlegung
  (*„am 2026-08-21 … gefahren und in diesem Architect-Lauf nicht wiederholt, weil ein Subagent das
  `Agent`-Werkzeug nicht führt"*). **Setzung 2 ist zweimal aktiv angewandt** (d-check-Datei-Zahl,
  Lauf-Summe) und einmal implizit (die eigene Verweis-Zahl der ADR bleibt unbeziffert).
- **geprüft, ohne Befund — die Abgrenzung „Aufzählungen sind keine Messwerte" trägt.** `MR-025`
  Setzung 1 nimmt sie wörtlich aus (*„Zahlen ohne Messwert-Rolle (Versionen, Daten, Aufzählungen im
  Fließtext) bindet die Setzung nicht"*). Geprüft an den Kandidaten: *„Vier Stellen"*, *„Drei
  Wege"*, *„vier Änderungen"*, *„drei Prüfkommandos"*, *„zwei Dateien"*, *„Prüfbar sind zwei"* —
  bei jedem sind **alle** Glieder im selben Satz benannt; die Zahl ist ein Etikett auf einer
  sichtbaren Liste, kein Wert über einem Korpus. **Die Abgrenzung wird nicht überdehnt:** die
  Zahlen, die wirklich über einem Korpus messen (18/13/5, 3, 27, 49/66 …), tragen sämtlich ihr
  Kommando.
- **geprüft, ohne Befund — Zahlen aus dem Alt-Bestand.** `drei Zeilen` (`:285`) und
  `fünf Prüfstellen in drei Dateien` (`:543`) stehen ohne Kommando, sind aber vom Diff dieser
  Runde **nicht berührt** (`git diff … | grep` → leer) und fallen damit unter den `MR-025`-Cutoff
  (*„gebunden ist die Zahl, die geschrieben oder geändert wird"*); die zweite trägt zudem ihre
  Quelle (`spec/spezifikation.md` §5 Abweichung 5, dort mit Zählregel).
- **geprüft, ohne Befund — Bein 2 überdehnt die 18 nicht.** Sie belegen genau, was sie sollen:
  Weg 1 bliebe dauerhaft rot, Weg 2 müsste eine datei-weite Senkung kaufen. Die Formulierung
  *„die beiden anderen kosten genau das"* liest sich beim ersten Durchgang so, als koste auch
  Weg 1 eine Senkung; das Bezugswort ist das ganze Prädikat (*grün lassen ohne Senkung*), und die
  Weg-Tabelle darüber nennt beide Preise getrennt und richtig. Kein Failure-Szenario.
- **geprüft, ohne Befund — Zitat-Treue der neuen Zitate.** Verbatim gegen ihre Quelle:
  `CO-002` §Auflösungs-Trigger (*„… und nach `done/` zu verschieben, damit die Werkzeug-Wahl-Spur
  lesbar bleibt"*), `CO-002` §Verifikation (*„Datei wird nach docs/plan/carveouts/done/ bewegt
  (reiner git mv)"*), `CO-002` §Betroffenes Gate (*„keines"*), `d-check --print-config`
  (*„Dateien hier muessen von JEDEM Ort der Gruppe aufloesen (>= 2)"*), Modul 7 §Ziel-Form,
  §Werkzeug-Wahl, §Carveout-Audit-Slice, ADR-0017 Option D und Re-Evaluierungs-Trigger. **Kein
  Zitat ist kondensiert**; beanstandet ist eine **Auslassung** (V-1) und eine **Halb-Ausführung**
  (V-3), kein Zitatfehler.
- **geprüft, ohne Befund — Status-Schnappschüsse.** Kein Satz nennt einen Status, den der eigene
  Accept falsch macht. Die vier `Accepted`-Angaben im Bezugs-Block sind selbst geprüft. Die
  Zahl `2` der geführten Carveouts trägt den Zusatz *„Diese Zahl bewegt sich mit der Umsetzung
  nicht"* samt Zeiger auf Folgepflicht 4. Die vierte Ort-Stelle ist ausdrücklich als *„die
  Erwartung, die der Carveout an seinen eigenen Ausgang schrieb, als der Ausgang noch offen war"*
  markiert und ihre Aufhebung benannt. Die **ADR-0020-Klasse trifft nicht.**
- **geprüft, ohne Befund — Slice-Adressen:** `grep -n 'slice-[0-9]'` über die ADR ist leer; alle
  Zuweisungen sind Rollen oder Eigenschaften.
- **geprüft, ohne Befund — Konsistenz zwischen Kontext, Festlegung 5, Folgepflicht 1 und
  Index-Zeile.** Vier Stellen im Inventar ↔ vier Änderungen in Folgepflicht 1 ↔ zwei namentlich
  aufgehobene Anweisungen in Festlegung 5 ↔ Index-Zeile: durchgehend deckungsgleich. Die
  Weg-3-Zeile der Alternativen-Tabelle ist nachgezogen (sie behauptet nicht mehr, von einer
  §Ziel-Form-Vorschrift abzuweichen, sondern nennt den Ortsträger-Wechsel und die zwei
  aufzuhebenden Anweisungen). Die Zwei-Commit-Auflage entfällt korrekt: §3.3 greift bei Move
  **und** Rewrite, hier gibt es nur den Rewrite.
- **geprüft, ohne Befund — die Fitness Function.** Unverändert gegenüber Runde 2 bis auf den
  Kommentar zur vierten Zeile, der die wandernde Summe durch den 18er-Filter ersetzt. Drei
  vorhandene Wächter, ein fälliger Fall, jede Zeile mit dem, was sie nicht deckt; die zwei
  Mutationen sind in den Runden 1 und 2 rot bzw. grün gesehen.
- **geprüft, ohne Befund — ADR-0012-Konformität und `LH-QA-01`:** kein Auflösungs-Trigger, kein
  Folge-Slice, fünf Re-Evaluierungs-Trigger mit Quadranten-Kennzeichnung, keiner in Trigger-Form;
  kein Gate behauptet, alle genannten Targets existieren und sind richtig eingeordnet. Alle sieben
  Template-Abschnitte in der Reihenfolge der Vorlage. §3.8 am Commit-Zuschnitt erfüllt.
- **geprüft, ohne Befund — die Geschichte-Zeile** ist inhaltlich deckungsgleich mit dem Text und
  nennt beide Gegenlage-Reports. Sie wiederholt die `18` ohne das Filter-Kommando daneben; die
  Index-Zeile tut es mit dem Hinweis *„mit Filter-Kommando"*. Für eine Zusammenfassung im selben
  Dokument, dessen Kontext das Kommando 500 Zeilen vorher führt, ist das kein Verstoß gegen
  `MR-025` Setzung 1 — es gibt kein Szenario, in dem jemand die Zahl von dort aus nachrechnen
  müsste und die Quelle nicht fände.
- **geprüft, nicht bewertet (fremde Rolle):** `slice-089` ist durch die Ort-Entscheidung in vier
  Punkten überholt — DoD (1) verlangt den `git mv` samt `R100`-Nachweis und zwei Commits, DoD (2)
  verlangt `grep -n 'CO-002' …` → **leer** (Folgepflicht 2 verlangt jetzt das genaue Gegenteil:
  weiter sechs Zeilen in zwei Dateien), die Datei-Tabelle führt *„update, **dann** `git mv` nach
  `done/`"*, und §5 organisiert einen Link-Zug für einen Move, den es nicht mehr gibt. Das gehört
  in ein Plan-Review und steht unten in der Offen-Tabelle.

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 1 |
| LOW | 2 |
| INFO | 0 |

Verlauf: **HIGH 3 → 0 → 0**, **MEDIUM 3 → 4 → 1**, **LOW 2 → 1 → 2**, INFO 2 → 0 → 0. Alle fünf
Findings der zweiten Runde sind belegt behoben, vier davon nachgemessen statt nachgelesen.

## Was nach der Annahme offen bleibt — und wem es gehört

| Offener Posten | Eigentümer | Woran fertig |
|---|---|---|
| **Folgepflicht 1** — vier Inhaltsänderungen an `CO-002` (Status · `Letzte Prüfung`/Geschichte · `done/`-Anweisung im Auflösungs-Trigger · Abschnitt *Verifikation* samt `git mv`-Haken und `d-check:ignore`) und eine an `docs/plan/carveouts/README.md`; **kein** `git mv`, **ein** Commit | Implementer | die drei `grep`-Kommandos leer + `make docs-check` `0 Befund(e)`; **V-2 beachten:** das Kommando zu (4) sieht nur eine von fünf Zeilen |
| **Folgepflicht 2** — die sechs Zeiger behalten ihre Adresse, ihre Aussage wird nachgezogen (jeder Satz, der eine Messung als ausstehend führt, fällt) | Spec-Eigentümer + Implementer | `grep -n 'CO-002' spec/spezifikation.md .claude/hooks/pretooluse-agent-guard.sh` → weiter **sechs** Zeilen in zwei Dateien; `make docs-check` grün |
| **Folgepflicht 3** — Matrix-Zellen *Token-Attribution × Repo* (Hintergrund-Teil) und *Cache-Counter × Repo* auf **ADR-Verdikt**; Tool-Spalte unberührt | Planner (welle-09-Ergebnis-Notiz) | die Zellen tragen den Wert; sie entstehen erst mit der Closure |
| **Folgepflicht 4** — das Carveout-Audit liest den **Status**, nicht das Verzeichnis; der welle-09-Closure-Trigger nennt beide Carveouts und ist so nicht mehr erfüllbar | Planner | `ls docs/plan/carveouts/CO-*.md` zeigt weiter **2**; das Audit trennt sie am Status |
| **Folgepflicht 5** — fälliger `test/mutations/`-Fall (Positiv-Listen-Eintrag entfernen → `TestNoResponseFreetextReachesSpan` rot) **als eigener DoD-Punkt** des umsetzenden Slice | Implementer (Fall) · Planner (DoD-Punkt) | `make mutate` ohne Befund, Fall rot gesehen |
| **Folgepflicht 6** — bekommt die emittierte Ebene je Erfassung, gilt die Grenze dort und gehört genannt | der Slice, der die Tool-Ebene entscheidet | — (feedforward, kein Termin) |
| **Folgepflicht 7** — Adaptions-Eintrag in `harness/conventions.md`, **eigener Architect-Lauf, eigener Commit** (§3.8) | Architect | Eintrag steht; **V-1 beachten:** ob er eine Abweichung oder eine Lückenfüllung verzeichnet, hängt am ausgelassenen §Ziel-Form-Bullet |
| **`slice-089` ist überholt** — DoD (1) verlangt den Move samt `R100`, DoD (2) verlangt die Zeiger **leer** (Folgepflicht 2 verlangt sie **stehend**), Datei-Tabelle und §5 planen einen Link-Zug für einen Move, den es nicht gibt | Planner | Re-Schnitt oder Nachzug des Plans, danach Plan-Review |
| **`make gates` / `make mutate` nach dem Vollzug**, DoD-Abhakung, Plan-Konformität | Verifier (getrennter Kontext, Modul 11) | echte Gate-Ausgabe |
| **Residuen aus V-2/V-3**, falls unverändert angenommen: der Abschnitt *Verifikation (nach Auflösung)* und der Abschnitt *Auflösungs-Trigger* im Stub | Träger ist die Rollen-Trennung vor der Änderung, **kein Sensor** | — (benannt, nicht geschlossen) |

## Verdikt

**Noch nicht frei — blockiert an genau einem Punkt, und der liegt in der Begründung, nicht in der
Entscheidung.**

**Was diese Runde geliefert hat, ist substanziell und nachgemessen.** Alle fünf Findings der
zweiten Runde sind behoben, und zwei davon auf eine Weise, die besser ist als die naheliegende:
N-1 wurde nicht durch eine korrigierte Zahl geschlossen, sondern durch ein **Kommando, das eine
nicht wandernde Teilmenge misst** — meine Sonde liefert heute 84, wo Runde 2 81 und Runde 1 79
lieferte, und die 18/13/5 stehen unverändert; N-2 wurde nicht durch Streichen geschlossen, sondern
durch eine Konstruktion, die **sagt, welches Bein was trägt**. N-3, N-4 und N-5 sind mit sieben
eigenen Sonden bestätigt, jede exakt. Die Sache selbst — der Ausfall ist permanent, der Stub
behält seine Adresse — ist in drei Runden von keinem Befund angegriffen worden.

**Was blockiert, ist ein MEDIUM.** Bein 1 trägt die **Erlaubnis** und beruft sich dafür auf ein
Inventar, das sich selbst für vollständig erklärt. Es ist es nicht: der einzige Regelwerks-Satz,
der `carveouts/` und *permanent* in einem Atemzug nennt, steht als erster Bullet derselben Sektion,
die die ADR gelesen zu haben erklärt — und die ADR druckt ihn sechs Zeilen vorher ab und benutzt
seine Vorbedingung affirmativ. Das ist kein Formfehler: er entscheidet, ob die Ablage-Frage eine
**Lücke** oder eine **Abweichung** ist, und davon hängt der Inhalt von Folgepflicht 7 ab — einer
Pflicht, die die ADR selbst anordnet und die nach dem Accept nicht mehr nachgeschärft werden kann
(§3.4). Der Bauplan, auf den sich diese ADR beruft, hat für denselben Satz vorgemacht, wie man ihn
disponiert: [ADR-0012](../plan/adr/0012-haupt-kontext-ohne-token-bilanz.md) §Kontext sagt
ausdrücklich, dass er *„nach seiner Logik, nicht nach seinem Buchstaben"* greift — *„und das gehört
gesagt"*.

**V-2 und V-3 blockieren nicht.** Beide sind LOW, beide betreffen Text im Stub statt in der
Entscheidung, und beide haben einen benennbaren guten Grund auf der Gegenseite. Stünden sie
allein, wäre mein Verdikt **frei mit Auflage**. Sie stehen hier, weil sie mit einem Satz
mitgenommen werden können, wenn V-1 ohnehin angefasst wird.

**Konvergenz, ausdrücklich festgehalten:** 3 HIGH → 4 MEDIUM → 1 MEDIUM. Die blockierende Menge
schrumpft und wandert dabei nach außen — von der Ausführbarkeit über den Nachweis in die
Vollständigkeit eines Belegs. **Dies ist der letzte substanzielle Befund, den ich an diesem
Gegenstand finde;** ich habe in dieser Runde alle drei Sonden-Familien, alle Zahlen, alle Zitate
und alle vier Konsistenz-Achsen gefahren und darüber hinaus nichts mehr gefunden.

**Übergabe:** V-1 und V-3 gehen an den **Architect** (ADR und Index sind Architect-Artefakte,
§3.8 / [ADR-0015](../plan/adr/0015-rollen-eigentum-an-norm-artefakten.md)); V-2 betrifft ein
Prüfkommando in Folgepflicht 1, also ebenfalls den ADR-Text, und in der Ausführung den
**Implementer**. Der **Planner** ist unabhängig von diesen Findings gefordert: `slice-089` ist
durch Festlegung 5 überholt. Dieser Report ersetzt keine Verifikation (Modul 11). Der
Eintritts-Trigger von `slice-089` — *ADR-0021 ist Accepted* — ist nach diesem Verdikt **nicht**
erfüllt.
