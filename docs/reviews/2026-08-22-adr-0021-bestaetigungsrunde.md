# ADR-0021 (Proposed) — Bestätigungsrunde vor der Annahme

**Rolle:** Reviewer (Modul 10). **Datum:** 2026-08-22. **Lauf:** frischer Kontext, Subagent
`reviewer`, erster Durchgang zu dieser ADR.

**Review-Art:** Design-Review — geprüft wird die ADR **gegen die ADR-Lage und ihre Quellen**
(Modul 10 §Drei Review-Arten), nicht gegen einen Slice-Plan. Der Zeitpunkt ist der Punkt, an dem
[`AGENTS.md`](../../AGENTS.md) §3.4 die Aussagen unumkehrbar macht.

**Gegenstand:** `d95ed83` — `docs/plan/adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md`
(*Proposed*, 421 Zeilen, fünf Festlegungen) plus die Index-Zeile `docs/plan/adr/README.md:29`.
Repo-Stand `9a98811`, Arbeitsbaum vor und nach dem Lauf sauber.

**Skill:** `.harness/skills/reviewer.md` @ 1.4.0 · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-5[1m] · **Datum:** 2026-08-22

**Eingangs-Kontext (die fünf Pflicht-Punkte plus Plan-Bezug, Modul 10 §Eingangs-Kontext):**

- **Diff/Range:** `d95ed83` (ADR + Index-Zeile); Gegenlage `9a98811`.
- **Übergabe, die die ADR entgegennimmt:** `docs/reviews/2026-08-21-updatedinput-messung.md` §5–§8
  (Zeitdokument der Messung, negativer Ausgang) und
  `docs/plan/planning/done/slice-086-vordergrund-per-updatedinput.md` §7.
- **Betroffene `LH-*`:** `LH-QA-01`, `LH-QA-02`, `LH-QA-03` (in `spec/lastenheft.md`, selbst
  gelesen).
- **Referenzierte aktive ADRs (Status je selbst am Index und am Kopf geprüft):** `ADR-0011`
  (Accepted), `ADR-0012` (Accepted), `ADR-0016` (Accepted), `ADR-0017` (Accepted), `ADR-0019`
  (Accepted), `ADR-0020` (Accepted); dazu `docs/plan/carveouts/CO-002-token-achse-je-rolle.md`
  (Status *Aktiv*), `docs/plan/carveouts/CO-001-bats-shell-lint.md` (Status *Aktiv*),
  `spec/spezifikation.md` §5 (Abweichungen 1, 4, 5, 6 und die fünf `CO-002`-Zeiger),
  `docs/plan/planning/welle-09-modul-15-konformitaet.md` §3.
- **Hard Rules:** `AGENTS.md` §3.1–§3.8 vollständig gelesen.
- **Vorherige Findings am gleichen Modul:** `docs/reviews/2026-08-16-adr-0020-bestaetigungsrunde.md`
  (ganz gelesen — HIGH-1 *„der tragende Beleg nennt eine andere Hook-Payload"*, HIGH-2 *„der
  Datei-Satz lässt echte Targets als Phantome melden"*), dazu
  `docs/reviews/2026-08-15-adr-0019-bestaetigungsrunde{,-runde-2}.md` (HIGH-1 zweimal in Folge:
  *eine Ableitung im Indikativ als Prämisse*) und `2026-08-16-adr-0019-0020-konvergenzrunde.md`.
  Die dort wiederkehrenden Klassen — *Zusage weiter als ihr Sensor*, *Status-Schnappschuss, den ein
  gemeinsamer Accept falsch macht*, *Adresse statt Eigenschaft* — sind hier gezielt gesucht worden;
  zwei davon treffen wieder, eine nicht (Negativbefunde unten).
- **Plan-Bezug (Repo-Ergänzung):** `docs/plan/planning/open/slice-089-carveout-co-002-ueberfuehren.md`
  (der Slice, der die Folgepflichten vollziehen soll) und `welle-09` §3/§4.

**Nicht meine Rolle, und darum nicht getan:** die DoD-Abhakung, die Gate-Lauf-Bestätigung als
Erfolgsmeldung, Lösungsvorschläge und jede Änderung an der ADR (Modul 10 §Anti-Pattern). **Ich habe
nichts committet und außer diesem Report nichts geschrieben** — `git status --porcelain` zeigt nur
diese Datei. Alle Mutations-Sonden liefen in Wegwerf-Kopien **außerhalb** des Repos.

**Eine Selbstbeschränkung, die zum Gegenstand gehört:** Ich habe den Span-Bestand
(`.harness/state/spans/`) **nicht** gelesen — [ADR-0011](../plan/adr/0011-telemetrie-erfassung-policy.md)
Festlegung 3 dritter Punkt sagt *„Ein Span ist kein Review-Gegenstand"*, und ADR-0021 Festlegung 3
erklärt genau diesen Satz für fortgeltend. Wo ich eine Zahl aus dem Bestand brauchte, habe ich das
`make`-Ziel gefahren, das ihn auswertet (`make span-report`, nach
[`AGENTS.md`](../../AGENTS.md) §4 ein *Bericht, kein Sensor*), und die **Berichtszeile** zitiert.
Dass diese Unterscheidung nötig war, ist selbst ein Befund (MEDIUM-1).

**Selbst gefahren — Kommando und Ergebnis, nichts davon übernommen:**

| Kommando | Ergebnis |
|---|---|
| `make docs-check` (Ist-Stand, `9a98811`) | `d-check: 337 Datei(en) geprüft, 0 Befund(e)`, Exit 0 |
| `git grep -ln 'updatedInput' -- . ':!docs' ':!spec'` | **leer, Exit 1** — die Zahl der ADR trägt |
| `grep -n 'CO-002' spec/spezifikation.md .claude/hooks/pretooluse-agent-guard.sh` | **6 Zeilen in 2 Dateien** (spec `:166,211,242,370,492`; Guard `:14`) — trägt |
| `ls docs/plan/carveouts/CO-*.md \| wc -l` | **2** — trägt |
| `.claude/settings.json` maschinell ausgelesen (Ereignis/Matcher/Kommando je Eintrag) | `PreToolUse:Bash` → command-guard · `PreToolUse:Agent` → agent-guard (**genau einer**) · `PostToolUse`/`PostToolUseFailure`/`SubagentStart` (leerer Matcher) → `span-emit` · `Stop` → stop-require-gates. **`SubagentStop` nicht verdrahtet** — trägt |
| `git grep -ln 'span-emit\|spawned_role\|pretooluse-agent-guard' -- internal/emit/` | **leer, Exit 1** — trägt |
| `cat internal/emit/templates/enforce/settings.json` | genau **ein** `matcher`-Schlüssel, Wert `Bash` (daneben ein `Stop`-Eintrag ohne Matcher) — trägt |
| `grep -rn 'settings\.json' test/ Makefile harness/tools/ internal/` | **5 Prüfstellen in 3 Dateien** (`test/mutations/32`, `harness/tools/smoke.sh` ×2, `internal/emit/enforce_test.go` ×2), alle über den **emittierten** Pfad — trägt |
| `git show --pretty=format: --name-only d95ed83` | genau zwei Dateien, beide Architect-Artefakte (`AGENTS.md` §3.8) — Message beginnt mit *„Rolle Architect:"* |
| **Sonde A** — Wegwerf-Kopie, `docs/plan/carveouts/CO-002-…md` nach `docs/plan/carveouts/done/` verschoben (reiner Move = Folgepflicht 1), dann d-check gegen dasselbe gepinnte Image | `337 Datei(en) geprüft, **79 Befund(e)**`, Exit 1 — alle `target-missing`. Verteilung: `docs/plan/carveouts/done/CO-002…` 13 · **`docs/plan/adr/0019-…` 13** · `slice-071` 10 · `slice-086` 8 · `slice-062` 6 · **`docs/plan/adr/0021-…` 6** · `spec/spezifikation.md` 5 · **`docs/plan/adr/0020-…` 5** · `welle-09` 4 · `slice-089` 3 · `docs/plan/adr/README.md` 3 · `slice-074` 1 · `roadmap.md` 1 · `docs/plan/carveouts/README.md` 1 |
| **Sonde B** — Wegwerf-Kopie, `spec/spezifikation.md:166` zeigt statt auf den Carveout auf ADR-0021 (Festlegung 5 wörtlich) | `337 Datei(en) geprüft, 1 Befund(e)`, Exit 1 — `spec/spezifikation.md:166 … matrix-forbidden` |
| **Sonde C** — dieselbe Stelle mit **barer** Kennung `` `ADR-0021` `` statt Link | `337 Datei(en) geprüft, 1 Befund(e)`, Exit 1 — `spec/spezifikation.md:166 ADR-0021 id-unlinked` |
| **Sonde D** — Wegwerf-Kopie, die zwei Cache-Zähler aus `responseKeys()` in `internal/span/response.go` entfernt, dann `make test-go` | `--- FAIL: TestNoResponseFreetextReachesSpan` (Meldung: `"cache_creation_input_tokens":33 fehlt in der Span-Zeile`). **`TestOnlyAgentToolGetsResponseValues` — der Wächter der Fitness Function — bleibt GRÜN** |
| `make span-report` (Ist-Stand) | `Abdeckung: **90** von **159** Agent-Laeufen trugen Zaehler`; fünf Rollen mit Summen, `Sammelposten: 227 Token` |
| `docker run … d-check@sha256:3996a59… ` (dasselbe Digest wie `make docs-check`) | für alle vier Sonden identisch verwendet — kein zweites Werkzeug, kein zweiter Maßstab |

**Gelesen, nicht gefahren** (Fundort statt Messung): `.harness/baseline/v3.5.2/regelwerk/modul-07-carveouts.md`
§Ziel-Form / §Werkzeug-Wahl bei Diskrepanz / §Carveout-Audit-Slice ·
`docs/plan/adr/0011-…:148-175` (Festlegung 3), `:100-147` (Festlegung 2), `:270-276` (Alternativen) ·
`docs/plan/adr/0012-…:104-152`, `:184-215`, `:217-250`, `:252-280` ·
`docs/plan/adr/0016-…:220-280` (Festlegung 1/2) · `docs/plan/adr/0017-…:1-50` ·
`docs/plan/adr/0019-…:212-262`, `:264-330`, `:388-453` ·
`docs/plan/adr/0020-…:30-45`, `:275-290`, `:430-455`, `:752-765` ·
`docs/plan/carveouts/CO-002-…` ganz · `docs/plan/carveouts/CO-001-…:1-30` ·
`spec/spezifikation.md:150-260`, `:355-395`, `:460-540` · `spec/lastenheft.md` §LH-QA-01..03 ·
`.d-check.yml` ganz · `internal/span/response_test.go:65-215` ·
`internal/span/response.go:55-90` · `internal/report/report.go:280-290` ·
`test/mutations/132`, `test/mutations/133` · `harness/tools/mutate.sh` (Bedingungen 3/4) ·
`harness/conventions.md` §MR-025 · `docs/user/claude-hooks-referenz.md:1565-1580`.

---

## Findings

### HIGH-1 — Folgepflicht 1 ordnet einen Move an, dessen gemessene Folge 79 tote Links sind — 24 davon in Artefakten, die §3.4 einfriert, sechs davon in dieser ADR selbst

- **kategorie:** HIGH
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.4 (*„ADRs sind nach Accepted immutable"*);
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) in der
  Lesart, die [ADR-0017](../plan/adr/0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) selbst
  führt (*„ein Gate, der dauerhaft rot steht, ist so wenig wert wie einer, den es nicht gibt"*);
  [ADR-0017](../plan/adr/0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) §Entscheidung
  (*„jeder zusätzliche Eintrag ist eine neue Senkung und löst `AGENTS.md` §3.5 erneut aus"*)
- **pfad:** `docs/plan/adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md:268-274` (Festlegung 5),
  `:329-334` (Folgepflicht 1), `:387` (die Gegenaussage) gegen
  `docs/plan/adr/0019-agent-guard-prueft-die-aufrufform.md` (13 Links),
  `docs/plan/adr/0020-emittierte-modul-15-regeln.md` (5 Links) und
  `docs/plan/adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md:47,70,112,128,152,213` (6 Links)
- **befund:** Festlegung 5 und Folgepflicht 1 ordnen den `git mv` des Carveouts nach
  `docs/plan/carveouts/done/` an. Sonde A misst die Folge dieses **reinen** Moves: `make docs-check`
  springt von `0` auf **79 Befunde**, alle `target-missing`. **24 davon liegen in Dateien, die
  niemand mehr ändern darf:** 13 in ADR-0019 und 5 in ADR-0020 (beide *Accepted*, §3.4) sowie 6 in
  ADR-0021 selbst, die mit dem hier zur Debatte stehenden Accept in denselben Zustand tritt. Die
  ADR nennt diese Folge an keiner Stelle; Folgepflicht 2 führt ausschließlich die **sechs**
  `CO-002`-Zeiger in `spec/spezifikation.md` und im Guard-Kopf. Im Gegenteil sagt `:387` ausdrücklich
  *„Festlegung 5 ist ein Datei-Zustand, den `git` hält und kein Modul von `.d-check.yml` bewertet"* —
  gemessen bewertet das `links`-Modul ihn 79-fach. Der Slice, der die Pflicht vollziehen soll, führt
  `docs/plan/adr/` in seiner Datei-Tabelle als **unverändert** und verlangt zugleich
  `make docs-check` grün nach jedem Move; beides zusammen ist nicht erfüllbar.
- **gegenbeispiel:** Der Implementer fährt Folgepflicht 1 wie geschrieben. `make docs-check` ist
  rot mit 79 Befunden und damit `make gates`, der Stop-Hook lässt keinen Abschluss zu. Ihm bleiben
  drei Wege, und alle drei sind durch eine Regel dieses Repos versperrt: die Links in ADR-0019/0020
  nachziehen (§3.4), die Links in ADR-0021 nachziehen (dieselbe Regel, ab dem Accept), oder eine
  `scan.ignore`-Aufnahme für drei ADRs — die nach ADR-0017 *„eine neue Senkung"* und damit nach
  §3.5 eine **eigene ADR** ist, die ADR-0021 nirgends benennt. Die Entscheidung, die den Zustand
  *„entschieden statt aufgeschoben"* herstellen soll, ist dann selbst nicht vollziehbar.
- **verifizierbar:** ja — Sonde A ist in drei Kommandos reproduzierbar: Repo-Kopie außerhalb des
  Baums, `mkdir docs/plan/carveouts/done && mv docs/plan/carveouts/CO-002-*.md
  docs/plan/carveouts/done/`, dann dasselbe Digest-gepinnte d-check-Image wie in `make docs-check`.
  Im Repo selbst würde `make docs-check` den Zustand nach dem Move bestätigen.

### HIGH-2 — Festlegung 5 verlangt für die fünf Spec-Stellen etwas, das das Doc-Gate in beiden Ausführungsformen rot färbt — und die einzige grüne Ausführung erzeugt genau den zweiten Verdikt-Ort, den derselbe Satz verbietet

- **kategorie:** HIGH
- **quelle:** [ADR-0012](../plan/adr/0012-haupt-kontext-ohne-token-bilanz.md) Folgepflicht 1
  (*„Ein zweiter Ort driftet"*; *„Wer das Verdikt am Ort der Abweichung sucht, findet es nicht dort,
  sondern hier"*); [`MR-001`](../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
  (Kennungs-Link-Pflicht); `.d-check.yml` `matrix.rules: {from: spec-straten, to: adr, allow: false}`
- **pfad:** `docs/plan/adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md:272-274` (Festlegung 5),
  `:300-302` (erste Positiv-Konsequenz), `:335-344` (Folgepflicht 2) gegen `.d-check.yml:44-46`
  und `.d-check.yml:22-27`
- **befund:** Festlegung 5 sagt: *„Ein zweiter Ort für das Verdikt entsteht nicht: die Stellen, die
  heute auf den Carveout zeigen, ziehen auf diese ADR"*, und die erste Positiv-Konsequenz sagt, wer
  die fünf Spec-Stellen liest, finde nach dem Nachzug *„keinen Zeiger mehr auf eine offene Frage,
  sondern das Verdikt"*. Für die fünf Stellen im Technik-Stratum ist beides versperrt. Sonde B: ein
  Link von `spec/spezifikation.md` auf ADR-0021 erzeugt `matrix-forbidden`, Exit 1. Sonde C: die
  bare Kennung `` `ADR-0021` `` ohne Link erzeugt `id-unlinked`, Exit 1. Bleibt, das **Verdikt
  selbst** in die Spec zu schreiben — genau der zweite Ort, den derselbe Satz und die zitierte
  ADR-0012-Folgepflicht ausschließen. Die Vorlage, auf die sich die ADR beruft, hat es umgekehrt
  gelöst: bei ADR-0012 trägt die Spec-Stelle **weder** Verdikt **noch** Zeiger, und die ADR sagt das
  ausdrücklich. `grep -n 'ADR-0' spec/spezifikation.md` liefert genau **einen** Treffer, und der
  steht in §7 Historie — dem einzigen von `matrix.exclude-sections` ausgenommenen Abschnitt.
- **gegenbeispiel:** Der Nachzug wird nach der höherrangigen Quelle ausgeführt — Source Precedence
  stellt die ADR (Rang 4) über den Slice-Plan (Rang 5), und der Plan liest die Stelle
  gegenteilig. Der Implementer setzt an den fünf Stellen den Link auf ADR-0021:
  `make docs-check` ist rot (`matrix-forbidden`, gemessen). Er weicht auf die bare Kennung aus:
  wieder rot (`id-unlinked`, gemessen). Er schreibt stattdessen den Kern des Verdikts hin: das Gate
  ist grün, und das Repo hat zwei Fassungen derselben Entscheidung — die Drift, gegen die
  Festlegung 5 in ihrem eigenen Satz argumentiert. Ab dem Accept ist keine der drei Lesarten mehr
  korrigierbar (§3.4).
- **verifizierbar:** ja — Sonden B und C sind je ein `sed` auf eine Zeile plus derselbe
  d-check-Lauf; im Repo bestätigte `make docs-check` den Befund am fertigen Nachzug.

### HIGH-3 — Die Fitness Function nennt für Festlegung 2 einen Wächter, der gemessen vier der neun Werte hält; der Wächter, der alle neun hält, kommt in der ADR nicht vor

- **kategorie:** HIGH
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 (*„Falsch: „Byte-Gleichheit belegt `make smoke`",
  ohne `smoke` gelesen zu haben. Richtig: benennen, was wirklich deckt — oder dass nichts deckt."*);
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
- **pfad:** `docs/plan/adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md:228-233` (Festlegung 2),
  `:367-368`, `:372` (Fitness-Function-Zeile), `:375-378` (*„Was die zwei Zeilen NICHT leisten"*)
  gegen `internal/span/response_test.go:158-184` und `internal/span/response_test.go:94-110`
- **befund:** Festlegung 2 sagt zu: *„Die neun Werte bleiben in der Positiv-Liste"*, und *„Das ist
  die Hälfte dieser Entscheidung, die einen Wächter hat (unten)"*. Die Fitness Function nennt genau
  einen: `TestOnlyAgentToolGetsResponseValues`, mit der Regel *„Wer die Erfassung entfernt, weil
  heute keine ankommt, färbt den Test rot"*. Dessen Gegenprobe prüft vier Größen —
  `SpawnedRole`, `TotalTokens`, `InputTokens`, `ModelVersion`. Sonde D entfernt die zwei
  Cache-Zähler aus `responseKeys()` — also genau die Werte, um die es in `spec/spezifikation.md` §5
  **Abweichung 1** und in der zweiten von ADR-0021 selbst beanspruchten Matrix-Zelle
  (*Cache-Counter × Repo*) geht — und `make test-go` meldet **`--- FAIL:
  TestNoResponseFreetextReachesSpan`**; der in der ADR genannte Wächter bleibt **grün**. Der Test,
  der die neun Werte wirklich hält (`response_test.go:104-110`, Kommentar *„Die neun gelisteten Werte
  MUESSEN dastehen"*), steht in der ADR nirgends. Der Absatz *„Was die zwei Zeilen NICHT leisten"*
  grenzt eine andere Lücke ab (kein Lauf trägt je Zähler) und nennt diese nicht.
- **gegenbeispiel:** Folgepflicht 5 ist eingelöst, der neue `test/mutations/`-Fall ist an
  `TestOnlyAgentToolGetsResponseValues` gebunden (so schreibt es die ADR), `make mutate` ist grün.
  Jemand entfernt später `cache_creation_input_tokens`/`cache_read_input_tokens` aus der
  Positiv-Liste — die genau richtige Fehlhandlung nach dem Muster, das Festlegung 2 benennt
  (*„Wer sie entfernt, weil heute keine ankommt"*). Der Wächter, den die ADR als Beleg führt, bleibt
  grün; dass ein anderer Test rot wird, ist Glück des Bestands und keine Aussage dieser
  Entscheidung. Der Satz *„Prüfbar ist genau eine — Festlegung 2"* trägt dann für fünf der neun
  Werte nicht, und die ADR kann es nicht mehr sagen.
- **verifizierbar:** ja, gefahren — Repo-Kopie außerhalb des Baums,
  `sed -i '/usage", "cache_creation_input_tokens/d; /usage", "cache_read_input_tokens/d'
  internal/span/response.go`, dann `make test-go`. Ausgabe oben.

### MEDIUM-1 — Festlegung 3 löst zwei der drei Aussagen von ADR-0011 Festlegung 3 auf; die dritte („kein Review-Gegenstand") bleibt stehen und trifft die neue Konstruktion

- **kategorie:** MEDIUM
- **quelle:** [ADR-0011](../plan/adr/0011-telemetrie-erfassung-policy.md) Festlegung 3 dritter Punkt
  (verbatim: *„**Kein Beleg-Status.** Ein Span ist kein Review-Gegenstand und keine Quelle für eine
  Zusage im Sinne von `AGENTS.md` §3.6. Was belegt werden muss, wird gemessen — nicht aus dem Log
  gelesen."*); [`AGENTS.md`](../../AGENTS.md) §3.4
- **pfad:** `docs/plan/adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md:235-254` (Festlegung 3),
  besonders `:239-247` und `:252-254`
- **befund:** Die ADR zitiert den Punkt vollständig und erklärt ihn für wörtlich fortgeltend, zieht
  dann aber eine **zweiklassige** Grenze: *Zusage* (nie aus einem Span) gegen *Annahme einer ADR*
  (aus einem Span zulässig). Der zitierte Satz ist **dreiteilig**: er spricht neben der Zusage und
  neben dem „belegt werden muss" auch aus, dass ein Span **kein Review-Gegenstand** ist. Dieser
  dritte Teil wird an keiner Stelle aufgelöst — das Wort taucht in der ADR nur im Zitat auf
  (`:130`) —, während die neue Regel den Span ausdrücklich zum **benannten Ablese-Ort** einer
  ADR-Annahme macht und dazu ein Kommando verlangt, dessen einziger Zweck das Nachsehen ist. Der
  Schlusssatz *„die zwei Stellen widersprechen sich nicht, sobald benannt ist, worüber jede
  spricht"* reicht damit weiter als die Unterscheidung, die er zusammenfasst.
- **gegenbeispiel:** Ein Reviewer prüft eine künftige ADR, deren Annahme nach ADR-0021 am Span
  abgelesen ist. Folgt er ADR-0021 und sieht nach, macht er den Span zum Review-Gegenstand — was
  ADR-0011 nach ADR-0021s eigener Aussage weiterhin verbietet. Folgt er ADR-0011 und sieht nicht
  nach, ist die zweite Bedingung von Festlegung 3 (*Ablese-Ort samt Kommando*) Dekoration: sie
  richtet sich an niemanden. Derselbe Konflikt ist in diesem Lauf real geworden — er ist oben im
  Kopf als Selbstbeschränkung ausgewiesen. Da beide ADRs dann *Accepted* sind, führt der Weg zur
  Klärung wieder über §3.4, also über eine dritte ADR.
- **verifizierbar:** nein, nicht maschinell — `.d-check.yml` führt `links, anchors, ids, matrix,
  codepaths, spans`, kein Modul liest Behauptungen; `make comment-claims` lässt Markdown außen vor
  (beides von der ADR selbst so benannt). Belegbar am Text: `grep -n 'Review-Gegenstand'
  docs/plan/adr/0021-*.md` → **ein** Treffer, und der steht im Zitat.

### MEDIUM-2 — Die erste Anwendung von Festlegung 3 erfüllt deren zweite Bedingung nicht im Text der ADR: Annahme (d) nennt den Ablese-Ort, nicht das Kommando

- **kategorie:** MEDIUM
- **quelle:** ADR-0021 Festlegung 3 selbst (*„…den Ablese-Ort samt Kommando nennt…"*);
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit);
  [ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 2 (*Eigenschaft statt
  Adresse* in einem Artefakt, das unveränderlich wird)
- **pfad:** `docs/plan/adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md:204-207` (Annahme (d))
  gegen `:246` (die Bedingung) und `docs/reviews/2026-08-21-updatedinput-messung.md:230-247`
- **befund:** Festlegung 3 macht die Zulässigkeit einer span-gestützten Annahme an drei Bedingungen
  fest, deren Subjekt jeweils *„die ADR"* ist. Annahme (d) erfüllt die erste (sie ist als Annahme
  geführt) und die dritte (dritter Re-Evaluierungs-Trigger). Die zweite erfüllt sie halb: der
  Ablese-Ort ist genannt (*„Abgelesen am Span-Bestand (2026-08-21)"*), das **Kommando** steht nicht
  in der ADR, sondern im verlinkten Zeitdokument — und dort als
  `grep -h '"tool":"Agent"' .harness/state/spans/d3ef8106_bc2d_4a6e_8bd0_72c91c4b813d.jsonl`, also
  über eine Sitzungs-Kennung in einem gitignorierten, maschinenlokalen Bestand. `grep -n 'Kommando'`
  über die ADR liefert zwei Treffer: den repo-lokalen Messblock (`:65`) und die Bedingung selbst
  (`:246`) — keinen für (d).
- **gegenbeispiel:** Jemand will auf einem anderen Checkout prüfen, worauf Annahme (d) steht — der
  Fall, für den die Bedingung geschrieben ist. Er findet in der ADR keinen Ausführungsweg und im
  Zeitdokument einen Pfad, den kein anderer Checkout hat. Damit ist die Bedingung, die ADR-0021 zur
  Voraussetzung erklärt, an ihrem ersten Anwendungsfall nicht nachvollziehbar erfüllt — und die
  Regel wird ab dem nächsten Fall mit diesem Präzedenzfall gelesen.
- **verifizierbar:** nein, nicht maschinell (dieselbe Grenze wie MEDIUM-1). Am Text belegbar mit
  `grep -n 'Kommando' docs/plan/adr/0021-*.md` und `sed -n '204,207p'` derselben Datei.

### MEDIUM-3 — Die Preis-Konsequenz nennt eine Zahl, die das von ihr selbst benannte Werkzeug am Tag der Annahme widerlegt

- **kategorie:** MEDIUM
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 (*„die Zusage auf das einschränken, was der Code
  hält"*); [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit);
  [ADR-0011](../plan/adr/0011-telemetrie-erfassung-policy.md) Festlegung 3 dritter Punkt
- **pfad:** `docs/plan/adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md:308-311` gegen
  `internal/report/report.go:287` und die Ausgabe von `make span-report`
- **befund:** Die Konsequenz lautet: *„die Token-Bilanz je Rolle hat für Subagenten-Läufe dauerhaft
  keinen Eingang. `internal/report/report.go` schreibt `Abdeckung: %d von %d Agent-Laeufen trugen
  Zaehler`, und die erste Zahl bleibt 0."* `make span-report` auf diesem Checkout gibt heute
  `Abdeckung: 90 von 159 Agent-Laeufen trugen Zaehler` aus, dazu eine Bilanz über fünf Rollen mit
  373 000 Token. Zutreffend ist die Aussage nur für **neue** Läufe und nur auf einem Bestand ohne
  Altbestände — und der wird nach `spec/spezifikation.md` §5 **Abweichung 4** ausdrücklich nicht
  aufgeräumt (*„Altbestände werden beim ersten Span einer Sitzung NICHT entfernt"*). Der Satz macht
  damit eine Aussage über ein gitignoriertes, maschinenlokales Artefakt, deren Wahrheitswert von
  der Maschine abhängt — dieselbe Klasse, die Festlegung 3 zwei Absätze weiter oben zum Anlass für
  eine Rangregel nimmt.
- **gegenbeispiel:** Jemand liest die eingefrorene ADR, fährt `make span-report` und liest `90 von
  159`. Entweder hält er die ADR für überholt (sie ist es nicht — die 90 sind Altbestand vom
  2026-08-09 und früher), oder er liest die Zahl als Zeichen dafür, dass die Achse wieder trägt.
  Genau davor warnt der Auflösungs-Trigger von `CO-002`: *„steht sie über 0, ist am Span
  nachzusehen, ob beide Teile da sind"*. Der Carveout, der diese Warnung trägt, wird von derselben
  ADR nach `done/` geschickt.
- **verifizierbar:** ja, ohne Änderung am Baum — `make span-report`, letzte Zeile. Kein Gate prüft
  die Aussage: `make span-report` ist nach `AGENTS.md` §4 ein **Bericht, kein Sensor**.

### LOW-1 — Drei der fünf Regelwerks-Belege tragen weder Tag noch Regelwerks-Dateinamen, einer auch keinen Abschnittsnamen

- **kategorie:** LOW
- **quelle:** [ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 2 (ein
  Artefakt, das unveränderlich wird, belegt eine Regelwerks-Aussage mit **Tag**, **Dateiname und
  Abschnittsname** und **Zitat verbatim**); ADR-0016 §Cutoff (*„ein Artefakt auf Proposed wird noch
  geschrieben und fällt unter Festlegung 3, nicht unter diesen Cutoff"*)
- **pfad:** `docs/plan/adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md:118` (§Ziel-Form),
  `:268` (ADR-Pfad, ohne Abschnittsnamen), `:291` (Alternative A, Dateiname ohne Tag, ohne
  Abschnitt, ohne Zitat), `:329` (§Carveout-Audit-Slice); sauber dagegen `:90-91`
- **befund:** Der Kopf des Trichter-Abschnitts belegt vorbildlich (*„Regelwerk `v3.5.2`,
  `modul-07-carveouts.md` §Werkzeug-Wahl bei Diskrepanz"* plus Zitat). Vier weitere Belege
  desselben Moduls stehen in anderen Abschnitten und verkürzen auf *„Modul 7"* bzw. auf den
  Dateinamen ohne Tag; `:268` — der Beleg, der Festlegung 5 trägt — nennt weder Tag noch Datei noch
  Abschnitt, nur *„Modul 7 für den ADR-Pfad"*. Zitiert wird jeweils korrekt; geprüft habe ich alle
  fünf Zitate gegen `.harness/baseline/v3.5.2/regelwerk/modul-07-carveouts.md` — sie sind verbatim.
- **gegenbeispiel:** Beim nächsten Baseline-Sprung (die offene `ADR-0018`-Runde entscheidet ihn)
  zerfällt `modul-07-carveouts.md` in eine andere Datei-Aufteilung. Wer dann `:268` nachschlagen
  will, hat weder Tag noch Dateinamen und muss die Quelle raten — genau der Zustand, gegen den
  ADR-0016 geschrieben wurde. Die ADR ist dann nicht mehr änderbar.
- **verifizierbar:** nein, nicht maschinell — kein `.d-check.yml`-Modul liest Beleg-Form. Am Text
  belegbar mit `grep -n 'Modul 7\|modul-07' docs/plan/adr/0021-*.md`. **Präzedenz spricht teilweise
  dagegen:** ADR-0019 (Accepted, drei Runden) verkürzt an zwei Stellen genauso; deshalb LOW und
  nicht höher.

### LOW-2 — Eine d-check-Unterdrückung mit selbst verfallender Begründung wird mit der ADR eingefroren

- **kategorie:** LOW
- **quelle:** Maintainability; [`AGENTS.md`](../../AGENTS.md) §3.4
- **pfad:** `docs/plan/adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md:334`
- **befund:** Die Zeile trägt `<!-- d-check:ignore (entsteht erst mit dieser Überführung) -->` für
  den Pfad `docs/plan/carveouts/done/`. Die Begründung ist heute wahr und wird mit dem Vollzug von
  Folgepflicht 1 falsch; entfernen lässt sie sich danach nicht mehr (§3.4).
- **gegenbeispiel:** Nach der Überführung liest ein Lauf in einer eingefrorenen ADR eine
  Unterdrückung, deren Grund *„entsteht erst mit dieser Überführung"* nicht mehr zutrifft, und
  kann weder prüfen noch aufräumen, ob sie noch nötig ist.
- **verifizierbar:** ja, negativ — `make docs-check` bleibt in beiden Zuständen grün; genau darum
  fällt die veraltete Direktive keinem Sensor auf.

### INFO-1 — Zahlen außerhalb des datierten Messblocks stehen ohne ihr Kommando (MR-025, vor dem Cutoff entstanden)

- **kategorie:** INFO
- **quelle:** [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 1
- **pfad:** `docs/plan/adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md:157-158` (*„drei Zeilen
  eines gitignorierten … Bestands"*), `:217-220` (*„acht der neun"*), `:310` (*„bleibt 0"*),
  `:322-324` (*„fünf Prüfstellen in drei Dateien"*)
- **befund:** Der Messblock `:64-81` hält seine eigene Zusage (*„jede Zahl mit ihrem Kommando"*) —
  alle vier Zahlen dort sind hier nachgefahren und tragen. Außerhalb des Blocks stehen vier Zahlen
  ohne Kommando; drei sind aus `CO-002` bzw. `spec/spezifikation.md` §5 übernommen und dort
  begründet, eine (`:310`) ist gemessen falsch (MEDIUM-3). **Kein Regelbruch:** `MR-025` datiert
  auf `04067d7` (2026-08-22 12:16), die ADR auf `d95ed83` (2026-08-22 07:46) — der Cutoff greift
  *ab Einführung*, und die ADR entstand davor. Der Verweis geht an die Rolle, die den
  Adaptions-Block führt, nicht an diesen Gegenstand.
- **verifizierbar:** ja, ohne Gate — `git log -1 --format=%ad --date=iso 04067d7` gegen dieselbe
  Abfrage für `d95ed83`.

### INFO-2 — Die Präzedenz für eine noch nicht existierende `test/mutations/`-Zeile trägt nach ADR-0012 nur eine Hälfte; die zweite fordert ADR-0021 nicht ein

- **kategorie:** INFO
- **quelle:** [ADR-0012](../plan/adr/0012-haupt-kontext-ohne-token-bilanz.md) §Fitness Function
  (*„Die Präzedenz trägt eine Hälfte: dass die Datei fehlen darf. Die zweite trägt sie nicht — dort
  nannte der umsetzende Slice die Zähne in seiner eigenen Definition of Done"*) und deren
  Folgepflicht 4
- **pfad:** `docs/plan/adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md:356-359` (Folgepflicht 5),
  `:373` (zweite Fitness-Zeile)
- **befund:** ADR-0012 hat für denselben Fall — eine Fitness-Zeile, deren Datei noch nicht existiert
  — verlangt, dass der umsetzende Slice den Zahn als **eigenen DoD-Punkt** führt, und diese Pflicht
  als Folgepflicht formuliert. ADR-0021 Folgepflicht 5 benennt die Bedingung als Eigenschaft
  (korrekt, keine Adresse), verlangt den DoD-Punkt aber nicht. Praktisch geschlossen ist die Lücke:
  `slice-089` DoD (3) führt ihn. Die Aussage der ADR reicht dafür nicht.
- **verifizierbar:** ja, ohne Gate — `sed -n '356,359p'` der ADR gegen
  `docs/plan/planning/open/slice-089-carveout-co-002-ueberfuehren.md:84-93`.

---

## Negativbefunde

Eine Zeile je betrachtetem Bereich — ohne diesen Block ist „keine Findings" nicht von „nicht
geprüft" zu unterscheiden.

- **geprüft, ohne Befund — der Modul-7-Trichter, Frage 1:** *einzelne Diskrepanz, unverändert* ist
  an der Quelle belegt. Die Faustregel des Moduls (*„Kein harter Schwellwert für „Cluster" —
  Faustregel (gemeinsamer Geltungsbereich), keine Carveout-Zahl"*) ist verbatim getroffen; der
  zweite geführte Carveout (`CO-001`, Geltungsbereich `.bats`-Dateien unter `test/`, Gate
  `shell-lint`) teilt mit diesem keinen Geltungsbereich; das invertierte BF-Symptom (*Doku
  vollständig, Quelle fehlt*) ist korrekt zugeordnet. Dass sich die Carveout-**Zahl** seit ADR-0019
  von eins auf zwei bewegt hat, ist offen gesagt und richtig aufgelöst.
- **geprüft, ohne Befund — der Modul-7-Trichter, Frage 2:** der Kipp auf *Nein* ist an ADR-0019
  §Kontext belegt (*„Ja, für genau einen Weg, und der liegt in unserer Hand"*, und für die zwei
  fremden Wege *„für sie allein wäre die Antwort Nein"*). Das Modul-Zitat *„Nein („nichts davon
  werden wir in absehbarer Zeit tun") → permanent, übergeführt in eine ADR"* ist verbatim. Die
  Folge — `Status: Permanent — übergeführt in ADR-<NNNN>` und `done/` — steht so im Modul (Frage 2
  bzw. §Werkzeug-Wahl) **und** im Auflösungs-Trigger von `CO-002`; der Formulierungs-Weg ist
  korrekt, nur sein Vollzug trägt HIGH-1.
- **geprüft, ohne Befund — die vier span-unabhängigen Glieder:** alle vier sind selbst gefahren
  oder an einer nicht-Span-Quelle belegt. (1) Schema-Änderung: `docs/reviews/2026-08-15-agent-guard-tool-vertrag.md:35-45`
  trägt sie. (2) Hintergrund-Start doppelt beobachtet: `docs/reviews/2026-08-21-updatedinput-messung.md`
  §5/§6 (sofortige Rückkehr, *„Backgrounded agent"*) — und die Folge *ein Hintergrund-Lauf trägt
  keine Zähler* steht unabhängig in `spec/spezifikation.md` §5 Abweichung 5 und in der vendored
  Hooks-Referenz (`usage` kommt dort insgesamt **dreimal** vor, im `Agent`-`tool_response`-Block).
  (3) Beide fremden Wege unverändert. (4) `git grep -ln 'updatedInput' -- . ':!docs' ':!spec'` →
  leer, Exit 1 — selbst gefahren. Die Entscheidung steht ohne die Span-Lektüre.
- **geprüft, ohne Befund — ADR-0012-Konformität:** kein Auflösungs-Trigger, kein Folge-Slice, und
  kein Trigger in Trigger-Form. Alle vier Re-Evaluierungs-Trigger sagen, **woran** etwas bemerkt
  würde und welche Annahme fällt; keiner behauptet, dass jemand es tun wird; zwei nennen ausdrücklich
  ein *„Wer es merkt"*. Die Quadranten-Kennzeichnung (feedforward/feedback) ist gesetzt. Der dritte
  Trigger nennt zusätzlich, dass Festlegung 4 mit Annahme (d) fällt — das ist eine Ergänzung, keine
  Verengung, weil der Annahmen-Block *„Kippt eine, kippt die Entscheidung"* darüber steht.
- **geprüft, ohne Befund — Status-Schnappschüsse:** die vier Status-Angaben im Bezugs-Block
  (`ADR-0011`, `0012`, `0019`, `0020` je *Accepted*) sind am Index und an den Datei-Köpfen selbst
  geprüft und richtig; keine wird durch diesen Accept oder durch die parallel offene `ADR-0018`
  falsch. Der einzige Zustands-Wert, den die eigene Umsetzung bewegt (`ls … | wc -l` → 2), steht im
  datierten Messblock und wird in Folgepflicht 4 ausdrücklich fortgeschrieben. Die ADR-0020-Klasse
  trifft hier **nicht**.
- **geprüft, ohne Befund — Slices als Adresse:** `grep -n 'slice-[0-9]'` über die ADR liefert
  **null** Treffer. Folge-Slice, Folgepflichten und der fällige Mutations-Fall sind durchgängig als
  Eigenschaft formuliert (*„ein Fall in `test/mutations/`, der …"*, *„Der Folge-Slice existierte,
  hat seinen Gegenstand geliefert"*). Auch die Index-Zeile nennt keinen Slice.
- **geprüft, ohne Befund — Hard Rule §3.8:** `git show --pretty=format: --name-only d95ed83` zeigt
  genau zwei Dateien, beide Architect-Artefakte (die ADR und der ADR-Index), und die
  Commit-Message beginnt mit *„Rolle Architect:"*.
- **geprüft, ohne Befund — Ziel-Form/Template:** alle Kopf-Felder und alle sieben Pflicht-Abschnitte
  des vendored Templates (`.harness/baseline/v3.5.2/templates/docs/plan/adr/NNNN-titel.template.md`)
  sind in der Reihenfolge der Vorlage vorhanden; die vier `###`-Unterabschnitte im Kontext sind
  additiv.
- **geprüft, ohne Befund — die emittierte Ebene:** beide Messungen des `Schärft`-Kopfes sind selbst
  nachgefahren und tragen (`internal/emit/` führt weder Emitter noch Guard; das emittierte
  `settings.json` führt genau einen Matcher, `Bash`). Die Abgrenzung zu
  [ADR-0020](../plan/adr/0020-emittierte-modul-15-regeln.md) ist korrekt: dort ist `CO-002`
  **Vorbedingung** des Zähler-Glieds und ausdrücklich **kein** Auflösungs-Trigger, und sein Maßstab
  wird nicht importiert — ADR-0021 importiert ihn seinerseits nicht in die Tool-Spalte.
- **geprüft, ohne Befund — die Grenze „kein Sensor prüft die Verdrahtung dieses Repos":** selbst
  nachgezählt — 5 Prüfstellen in 3 Dateien (`test/mutations/32`, `harness/tools/smoke.sh` ×2,
  `internal/emit/enforce_test.go` ×2), alle über den emittierten Pfad; `Makefile` steuert nichts
  bei. Die Zahl und ihre Zuordnung stimmen mit `spec/spezifikation.md` §5 Abweichung 5(3)(b)
  überein.
- **geprüft, ohne Befund — Zitat-Treue:** alle geprüften Zitate sind verbatim gegen ihre Quelle —
  `ADR-0011` Festlegung 3 dritter Punkt · `ADR-0012` (*„eine Entscheidung unter benannter
  Unsicherheit …"*, *„Ein zweiter Ort driftet"*, Alternative B) · `ADR-0019` Festlegung 4 (Preis
  der zwei Permission-Kombinationen) · `CO-002` §Auflösungs-Trigger (zweiter Ausgang, *„Ein
  Carveout, der nach einer negativen Messung stehen bliebe …"*, zweite Hälfte der Schwelle) ·
  `spec/spezifikation.md` §5 Abweichung 1 (*„der `transcript_path` wird deshalb weder erfasst noch
  gelesen"*) · `internal/report/report.go:287` · Modul 7 (fünf Stellen). **Kein Zitat ist
  kondensiert oder umformuliert.**
- **geprüft, ohne Befund — Verweise auf verworfene Alternativen:** `ADR-0011` Alternative D
  (*„nur Transkripte auswerten"*) und `ADR-0019` Alternative B (`SubagentStop` + Transkript)
  existieren und tragen den zugeschriebenen Inhalt; `ADR-0012` Alternative C/D ebenso.
- **geprüft, ohne Befund — Folgepflicht 3 und 4 gegen den Welle-Plan:** `welle-09` §3 macht den Wert
  der zwei Repo-Zellen ausdrücklich vom Zustand des Carveouts abhängig, führt *ADR-Verdikt* als
  eigenen Vokabular-Wert und nimmt die Tool-Spalte davon aus; der Closure-Trigger nennt
  *„`CO-001` **und** `CO-002` geprüft"*. Beide Folgepflichten treffen den Plan exakt.
- **geprüft, ohne Befund — `LH-QA-01`:** die ADR behauptet keinen Gate. Beide Fitness-Zeilen nennen
  vorhandene Targets mit korrekter Einordnung (`make test` in `make gates`, `make mutate` nicht,
  CI pro Push nach `MR-014`); die Beschreibungen von `make comment-claims` (vier Pfad-Muster, kein
  Markdown) und `make docs-check` (sechs Module) stimmen mit `AGENTS.md` §4 bzw. `.d-check.yml`
  überein.
- **geprüft, ohne Befund — Index-Zeile `docs/plan/adr/README.md:29`:** Status *Proposed* stimmt mit
  dem Datei-Kopf überein; Titel, Geltungsbereich (*acht der neun*), die fünf Festlegungen, die
  Klassen-Unterscheidung, der Preis (Wiedervorlage entfällt) und die Nicht-Berührung der emittierten
  Ebene sind deckungsgleich mit dem Fließtext. Die Bezugs-Spalte lässt `AGENTS.md` §3.6 weg — das
  entspricht der Form aller anderen Zeilen (auch ADR-0012 führt es nur im Fließtext) und ist keine
  Abweichung. **Die Index-Zeile erbt allerdings HIGH-3** (*„der vorhandene Go-Test bindet sie"*)
  und wird mit demselben Befund falsch.
- **geprüft, ohne Befund — Ist-Zustand des Doc-Gates:** `make docs-check` auf `9a98811` ist
  `337 Datei(en) geprüft, 0 Befund(e)`. Die ADR und ihre Index-Zeile tragen heute keine toten
  Links, Anker oder Kennungen; alle Befunde oben betreffen den Zustand **nach** dem Vollzug ihrer
  eigenen Folgepflichten.
- **geprüft, nicht bewertet (fremde Rolle):** die DoD-Abhakung von `slice-089`, der Wortlaut des
  Welle-Closure-Kriteriums und der fehlende Folge-Slice von `CO-001`. Die zwei Widersprüche in
  `slice-089` (Datei-Tabelle *„`docs/plan/adr/` unverändert"* gegen §5 *„jeder eingehende
  Verweis"*) sind hier nur als Beleg für HIGH-1 zitiert, nicht als Befund gegen den Plan — der
  gehört in ein Plan-Review.

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 3 |
| MEDIUM | 3 |
| LOW | 2 |
| INFO | 2 |

## Verdikt

**Nicht frei für die Annahme — blockiert.**

Drei HIGH und drei MEDIUM stehen offen; nach dem Reviewer-Skill blockieren beide Kategorien
typischerweise, und hier kommt der Grund hinzu, der diese Runde überhaupt trägt: ab *Accepted* ist
die ADR nach [`AGENTS.md`](../../AGENTS.md) §3.4 unumkehrbar. Jeder der sechs Befunde beschreibt
einen Satz, der danach nur noch über eine **weitere** ADR mit *Supersedes* zu bewegen wäre.

Die drei HIGH sind verschiedener Art und deshalb einzeln zu wiegen:

- **HIGH-1** ist der schwerste, weil er den **Vollzug** trifft, nicht die Begründung: die
  Entscheidung, die den Zustand *„entschieden statt aufgeschoben"* herstellen soll, ordnet einen
  Schritt an, den keine Rolle dieses Repos regelkonform zu Ende bringen kann. 79 gemessene
  `target-missing`-Befunde, 24 davon in Dateien, die §3.4 einfriert — sechs davon in dieser ADR.
- **HIGH-2** trifft die **operative Anweisung** an das Spec-Stratum: beide wörtlichen
  Ausführungsformen färben `make docs-check` rot (gemessen), und die dritte erzeugt genau den
  zweiten Verdikt-Ort, den derselbe Satz verbietet.
- **HIGH-3** trifft die **einzige** Hälfte, die die ADR selbst als überprüfbar ausgibt: der genannte
  Wächter hält vier der neun zugesagten Werte, und die fünf, die er nicht hält, schließen die zwei
  Cache-Zähler ein — dieselben, für die die ADR eine eigene Matrix-Zelle beansprucht.

**Was ausdrücklich NICHT beanstandet ist**, damit die Rückkante nicht zu breit gelesen wird: der
Trichter nach Modul 7 trägt an beiden Fragen und ist an der Quelle belegt; die Entscheidung steht
gemessen auf vier span-unabhängigen Gliedern; die Konformität zum Bauplan aus
[ADR-0012](../plan/adr/0012-haupt-kontext-ohne-token-bilanz.md) (kein Auflösungs-Trigger, kein
Folge-Slice, Re-Evaluierung statt Frist) ist eingehalten; die Zitat-Treue ist über alle geprüften
Stellen vollständig; die Abgrenzung zur emittierten Ebene und zu
[ADR-0020](../plan/adr/0020-emittierte-modul-15-regeln.md) ist gemessen und richtig; **Slices als
Adresse kommen nicht vor**, und §3.8 ist am Commit-Zuschnitt erfüllt. **Die Sache selbst — der
Ausfall ist permanent — ist von keinem Befund angegriffen.** Angegriffen sind die Sätze, mit denen
sie vollzogen und belegt wird.

**Zur Klassen-Frage aus dem Auftrag, ausdrücklich beantwortet:** Festlegung 3 ist **keine stille
Aufweichung** von [ADR-0011](../plan/adr/0011-telemetrie-erfassung-policy.md) — sie nennt die
Quelle, zitiert sie vollständig, benennt die Grenze offen und stellt die Entscheidung ausdrücklich
**nicht** auf die Span-Lektüre. Sie ist aber auch keine vollständige Klarstellung: von den drei
Aussagen des zitierten Punktes löst sie zwei auf und lässt die dritte (*kein Review-Gegenstand*)
stehen, obwohl die neue Konstruktion genau sie berührt (MEDIUM-1); und ihre erste Anwendung erfüllt
ihre eigene zweite Bedingung nur per Verweis auf ein sitzungsgebundenes Zeitdokument (MEDIUM-2).

**Übergabe:** Die Findings gehen an den **Architect** — die ADR ist ein Architect-Artefakt
([`AGENTS.md`](../../AGENTS.md) §3.8, [ADR-0015](../plan/adr/0015-rollen-eigentum-an-norm-artefakten.md)),
und solange sie *Proposed* steht, ist sie änderbar. HIGH-1 berührt zusätzlich den **Planner**
(`slice-089` trägt denselben Widerspruch in seiner Datei-Tabelle). Dieser Report ersetzt keine
Verifikation: DoD- und Plan-Konformität prüft der Verifier in getrenntem Kontext (Modul 11). Der
Eintritts-Trigger von `slice-089` (*ADR-0021 ist Accepted*) ist nach diesem Verdikt **nicht**
erfüllt.
