# Review-Report — slice-140: Der emittierte Stand trägt keine Vorlagen-Hilfen mehr

**Rolle:** Reviewer · **Datum:** 2026-09-10 · **Runde:** 2

## Eingangs-Kontext (die fünf Pflicht-Punkte, Modul 10, plus die Repo-Ergänzung)

- **Diff/Commit-Range:** `3fd42cc4..7377f9ba` — ein Commit, die Behebungs-Runde zu
  [Runde 1](2026-09-09-slice-140-vorlagen-hilfen-review.md). Umfang exakt drei Dateien
  (`git diff --stat 3fd42cc4 HEAD` → `internal/emit/templates.go`,
  `internal/emit/templates_test.go`,
  `test/mutations/292-strip-comment-hints-readme-nicht-verdrahtet.sh`).
- **Betroffene `LH-*`:**
  [`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3),
  [`LH-FA-08`](../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren),
  [`LH-FA-09`](../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren),
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit).
- **Referenzierte aktive ADRs:** [ADR-0005](../plan/adr/0005-ziel-repo-distribution.md)
  (`Accepted`, Slice-Kopf), [ADR-0035](../plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
  (`Accepted`, für den `mutate`-Beleg unten).
- **Aktive `MR-*`:** [`MR-008`](../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert),
  [`MR-017`](../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed),
  [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert).
- **Hard Rules:** [`AGENTS.md`](../../AGENTS.md) §3 — namentlich §3.6, §3.7, §3.9, §3.10.
- **Vorherige Findings am gleichen Modul:**
  [Runde 1](2026-09-09-slice-140-vorlagen-hilfen-review.md) (3 HIGH / 1 MEDIUM / 2 LOW / 2 INFO)
  sowie [2026-09-08 · slice-201](2026-09-08-slice-201-codepaths-vendored-baum-review.md) und
  [2026-09-06 · slice-190](2026-09-06-slice-190-bootstrap-orte-review.md).
- **Slice-Plan (Repo-Ergänzung):** `slice-140`, gelesen in `in-progress/`; §7 unberührt, §6 vier
  Risiken ohne Ausgang — beides korrekt, der Abschluss ist Planner-Arbeit
  ([`AGENTS.md`](../../AGENTS.md) §3.10).

**Zustand des Baums vor dem Lauf:** `git status --porcelain` leer.

**Instrumente dieses Laufs.** Docker-only ([`AGENTS.md`](../../AGENTS.md) §3.9): `make host-bin`,
`make test-go`, `make comment-claims`. Dazu **ein realer Emit-Lauf** des gebauten Trägers in ein
frisches `git init`-Repo außerhalb des Arbeitsbaums. **Jede Mutation dieses Laufs lief in einer
Kopie außerhalb des Repos**; der Arbeitsbaum ist nach dem Lauf unverändert
(`git status --porcelain` leer).

**Keine Erwartungswerte** ([`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — jede Zahl unten wandert mit dem Vorlagen-Satz.

## Nachprüfung der Runde-1-Befunde

Jeder der sechs behaupteten Fixes ist **selbst gemessen**, nicht aus der Commit-Message übernommen.

### HIGH-1 — behoben, rot gesehen

Die Fixture injiziert jetzt einen eigenen Kommentar in `project-readme.template.md`, die einzige
Quelle von `RootReadme()`. Gegenprobe in einer Kopie außerhalb des Repos, `readme.go:44` auf den
Stand vor dem Slice zurückgesetzt (`test/mutations/292-…sh` angewandt), dann `make test-go`:

```text
--- FAIL: TestTemplates_KeineKommentarHilfenImEmittiertenSatz (0.00s)
    templates_test.go:672: emittiertes Dokument README.md traegt noch eine Kommentar-Hilfe:
    "<!-- Bedienhinweis in der Root-README, faellt beim Kopieren weg. -->"
```

Die Meldung nennt `README.md` und genau den injizierten Kommentar — die Hälfte fällt für den
richtigen Grund, nicht als Kollateralschaden der lastenheft-Ergänzung. Mit Verdrahtung grün (der
Gate-Stempel deckt den aktuellen Baum, s. Negativbefunde).

### HIGH-2 — behoben, und die neue Aussage ist nachgeprüft

Der Kommentar an `StripCommentHints` schreibt `make smoke` keine Deckung mehr zu, sondern nennt die
Blindheit. Seine drei prüfbaren Behauptungen sind einzeln gemessen:

```sh
grep -n 'modules' "$P/.d-check.yml"                      # modules: [links, anchors]
grep -c 'Kommentar\|<!--\|StripComment' harness/tools/smoke.sh   # 0
grep -c '<!--\|StripComment' test/courseset-fixture.bats          # 0
```

Und die universelle Hälfte („keine Zusage, die ein Sensor dieses Repos trägt") hält: von den neun
bats-Dateien, die den realen Vorlagen-Satz überhaupt lesen
(`grep -rln '\.harness/baseline\|BASELINE_TAG' test/*.bats`), nennt **keine** eine Kommentar-Hilfe
(je Datei `grep -c '<!--\|StripComment'` → 0). `harness/tools/full-smoke.sh` trägt zwar vier
Treffer desselben Musters, aber alle vier gehören zur KONVERGENT-Probe an
`harness/erfassung-feldliste.md` (`grep -n 'Kommentar\|<!--' harness/tools/full-smoke.sh` →
Zeilen 1043, 1080, 1267, 1286); sie greppen nach dem Literal `<!-- von Hand geaendert -->` und
sind gegen eine unverdrahtete `StripCommentHints` unempfindlich.

### HIGH-3 — Symptom behoben; zwei Folgebefunde bleiben

Am **realen** vendored Satz nachgemessen, nicht nur an der Fixture. Über dem real emittierten Baum
`$P` ist der Zitat-Block byte-gleich zur Vorlage:

```sh
grep -n 'Norm nur im Template-Kommentar' -A 3 .harness/baseline/v6.5.0/templates/.harness/skills/reviewer.template.md
grep -n 'Norm nur im Template-Kommentar' -A 3 "$P/.harness/skills/reviewer.md"
# beide: "… eine Regel steht im `<!-- -->`-Block / eines `.template.md` und nirgends sonst. …"
grep -rn '``[^`]' "$P" --include='*.md' | grep -v '/.harness/baseline/'   # nur ```mermaid/```json-Fences
```

Zusätzlich habe ich mit einem **eigenen**, vom Prüfgegenstand unabhängigen Kommentar-Entferner
(awk-Zustandsautomat) für jede der zehn emittierten Vorlagen geprüft, dass **kein** Nicht-Kommentar
verschwunden ist: die einzigen Abweichungen sind der `Template-Hinweis`-Blockquote (Schritt 4), der
`<Projektname>`-Stempel und `NeutralizePlaceholderLinks` — plus die *beschädigte* Zitatform, die
mein eigener Stripper erzeugt und die im emittierten Text korrekt **nicht** vorkommt.

Die Folgebefunde stehen unten als MEDIUM-1 und MEDIUM-2.

### MEDIUM-1 — behoben, aber unvollständig

`StripCommentHints` nennt jetzt zwei Grenzen. Beide sind von mir am Satz nachgemessen und treffen
zu: die Zwischenraum-Form kommt nicht vor (`grep -rn '``[^`]*<!--' <templates>` leer), und die
Fence-Bilanz stimmt — `spec/architecture.template.md` trägt 5 Öffner und 14 `-->`, emittiert
bleiben 9 Pfeile; `docs/plan/planning/roadmap.template.md` 3 gegen 7, emittiert 4. Genau die
Differenz, kein Pfeil zu viel oder zu wenig. Eine **dritte** Form derselben Familie fehlt — unten
MEDIUM-2.

### LOW-1 — behoben, rot gesehen

`dcheckIgnoreMarkerPattern` (`^<!--\s*d-check:ignore\b`) ersetzt den Substring-Test. Gegenprobe in
einer Kopie außerhalb des Repos, Bedingung auf `strings.Contains` zurückgesetzt, `make test-go`:

```text
--- FAIL: TestStripCommentHints (0.00s)
    templates_test.go:595: StripCommentHints liess einen erklaerenden Bedienhinweis stehen
    (Substring statt Marker-Form)
```

Am realen Satz ist der Fix **verhaltensneutral** und damit eine reine Härtung: kein Kommentar des
Vorlagen-Satzes erwähnt `d-check:ignore`, ohne Marker zu sein (je Fundstelle
`grep -n 'd-check:ignore' <datei> | grep -v '<!-- *d-check:ignore'` → leer), und alle Marker
überleben den Emit.

### LOW-2 — behoben, rot gesehen

`test/mutations/292-…sh` nennt `internal/emit/readme.go` und färbt
`TestTemplates_KeineKommentarHilfenImEmittiertenSatz` rot (Beleg oben unter HIGH-1). Der `sed`
trifft die reale Zeile — ich habe ihn in der Kopie angewandt und das Ergebnis gelesen; verfehlte
er sie, bliebe der Wächter grün und `make mutate` meldete den Fall als BEFUND, also fail-closed.

### INFO-1 und INFO-2 — die Abgrenzung ist zulässig

Der Implementer hat beide ausdrücklich nicht angefasst. Das ist **korrekt** und keine Auslassung:
[`AGENTS.md`](../../AGENTS.md) §3.10 bindet *„die Ausgänge der offenen Risiken"* und *„die
Fortschreibung des Beobachtungs-Registers"* namentlich an den Planner-Abschluss, und
`modul-06-roadmap.md` §Das Beobachtungs-Register sagt *„Eingetragen wird bei der
Slice-Closure"*. Gegenprobe, dass er sie wirklich nicht vorweggenommen hat: die zwei Zähler
stehen unverändert bei

```sh
ls docs/plan/planning/observations/BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt/evidence/*.md | wc -l          # 6
ls docs/plan/planning/observations/BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch/evidence/*.md | wc -l      # 7
```

**Keine Erwartungswerte** — beide wandern mit dem Register. Eine der beiden gehörte auch nicht in
den Implementierungs-Umfang: INFO-1 verlangt einen der drei Risiko-Ausgänge, und die sind eine
Closure-Entscheidung; INFO-2 verlangt Beleg-Dateien, die ab Merge unveränderlich sind — genau die
Klasse, für die §3.10 den zweiten Blick vor dem Einfrieren verlangt.

## Findings (neu in dieser Runde)

### MEDIUM-1 — Die Behebung von HIGH-3 verschiebt DoD (1) und den Closure-Trigger, und nichts übergibt das

- **kategorie:** MEDIUM
- **quelle:** Slice-Plan §2 DoD (1) und §5 Closure-Trigger; [`AGENTS.md`](../../AGENTS.md) §3.10
  (*„ist sie kein Closure-Schritt, sondern ein **Übergabe-Artefakt** an den Planner"*);
  Reviewer-Skill-Anker *Spec-Treue-Lücke einer Messmethode*
- **pfad:** `docs/plan/planning/done/slice-140-emittierter-stand-ohne-vorlagen-hilfen.md`
  §2 DoD (1) und §5 · Wirkung aus `internal/emit/templates.go:868-870`
- **befund:** DoD (1) bindet die Abnahme ausdrücklich an ein Kommando — *„die
  `grep -vc '/\.claude/'`-Zeile fällt auf **0**"*, und *„**Vorher-Nachher über dasselbe
  Kommando**, nicht gegen eine notierte Zahl"*; §5 wiederholt denselben Zielwert als
  Closure-Trigger. Über dem real emittierten Baum liefert genau dieses Kommando jetzt **1**, nicht
  0 — die eine Zeile ist das von `isBacktickQuoted` bewusst geschonte Zitat
  (`.harness/skills/reviewer.md:30`). In Runde 1 stand dort noch 0, weil die Regel das Zitat
  zerstörte; die richtige Reparatur hat den Messwert bewegt. Die Überschrift von DoD (1) ist damit
  erfüllt (das Zitat ist keine Kommentar-**Hilfe**), das Instrument darunter nicht — es zählt
  `<!--`-Vorkommen und kann Zitat und Hilfe nicht trennen. Weder die Commit-Message noch ein
  anderes Artefakt des Range benennt die Verschiebung; der Slice-Plan ist unverändert (der Range
  berührt drei Dateien, keine davon der Plan). Der Verifier, dessen Prüfgrundlage genau diese DoD
  ist, bekommt eine rote Messung ohne die Auskunft, ob sie Defekt oder gewollte Folge ist — und
  die einzige Rolle, die das Kriterium umschreiben darf, erfährt nichts davon.
- **verifizierbar:** ja — `make host-bin`, Emit in ein frisches Repo `$P`, dann das §1-Kommando:
  `find "$P" -name '*.md' -not -path '*/.git/*' -not -path '*/.harness/baseline/*' -print0 | xargs -0 grep -n '<!--' | grep -v 'd-check:ignore' | grep -vc '/\.claude/'` → 1.
- **klasse:** `Zusage-neben-geaenderter-Ableitung-bleibt-stehen`
  ([`BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen`](../plan/planning/observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md),
  Stand `offen`)

### MEDIUM-2 — Die Grenzen-Aufzählung lässt die Form aus, die Inhalt verschluckt

- **kategorie:** MEDIUM
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.7 (Klasse *Grenze*);
  [`MR-017`](../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed);
  Reviewer-Skill-Anker *fehlende Negativtests bei neuem öffentlichen Vertrag*
- **pfad:** `internal/emit/templates.go:818-827` (die zwei genannten Grenzen) und `:864-870`
  (`isBacktickQuoted`)
- **befund:** Die Funktion nennt zwei Grenzen: das Zitat **mit Zwischenraum** zum Backtick und die
  Fence-Blindheit bei einem *Kommentar* vor einem Mermaid-Pfeil. Eine dritte Form derselben
  Familie ist ungenannt und die einzige der drei, die **stillschweigend Inhalt löscht**: ein
  Inline-Code-Zitat, das nur den **Öffner** trägt (`` `<!--` ``). `isBacktickQuoted` prüft, ob
  *hinter dem Treffer-Ende* ein Backtick steht — bei einem Öffner-Zitat endet der Treffer erst am
  nächsten `-->` irgendwo später im Dokument, die Ausnahme greift nicht, und alles dazwischen
  fällt. Real gemessen an einem Sonden-Test in einer Kopie außerhalb des Repos:

  ```text
  EINGANG : "Der Oeffner `<!--` leitet ein.\n\nTRAGENDER SATZ A.\n\n```mermaid\nA --> B\n```\n\nTRAGENDER SATZ B.\n"
  AUSGANG : "Der Oeffner ` B\n```\n\nTRAGENDER SATZ B.\n"
  ```

  Ein tragender Satz und der Fence-Anfang sind weg. Die Form ist **heute nicht im Satz**
  (`grep -rn '`<!--' <templates> | grep -v -- '-->`'` → leer), aber der Vorlagen-Satz zitiert
  seine eigene Kommentar-Syntax bereits an **vier** Stellen
  (`grep -rn '`<!--' .harness/baseline/v6.5.0/templates --include='*.md' | wc -l` → 4) — genau der
  Boden, auf dem HIGH-3 gewachsen ist. Dazu kommt: der Beleg, den der Kommentar für sein *„heute
  geht das gut"* anführt, ist der Öffner-/Schließer-Zählstand je Vorlage. Der ist für diese Form
  **unempfindlich** — die Sonde oben trägt einen Öffner und einen `-->`, also einen ausgeglichenen
  Stand, und verschluckt trotzdem. Kein Test deckt die Form, und kein Sensor sieht sie (oben unter
  HIGH-2 als repo-weit abwesend gemessen).
- **verifizierbar:** ja — ein `emit.StripCommentHints`-Sondenfall mit dem Eingang oben über
  `make test-go` in einer Kopie außerhalb des Repos.
- **klasse:** `Neue-oeffentliche-Funktion-ohne-benannte-Grenze` (die Klasse aus Runde 1 MEDIUM-1,
  zu zwei Dritteln geschlossen)

### LOW-1 — Die zwei neuen Ausnahmen haben keinen Fall in `test/mutations/`

- **kategorie:** LOW
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 (*„wer keinen Fall in `test/mutations/` hat, ist
  unbewacht"*); Beobachtung
  [`BEO-ALL/neuer-waechter-ohne-mutations-fall`](../plan/planning/observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/observation.md)
  (Stand `offen`)
- **pfad:** `test/mutations/291-strip-comment-hints-nicht-verdrahtet.sh` und
  `test/mutations/292-strip-comment-hints-readme-nicht-verdrahtet.sh`
- **befund:** Der Commit führt zwei neue Zusagen ein — das Backtick-Zitat bleibt stehen
  (`isBacktickQuoted`), der erklärende Bedienhinweis fällt (`dcheckIgnoreMarkerPattern`) — und
  keine der beiden hat einen Fall im Mutations-Satz. Beide `files:`-Zeilen der zwei vorhandenen
  Fälle nennen die **Verdrahtung** (`internal/emit/templates.go` bzw. `internal/emit/readme.go`),
  keiner die Ausnahme-Logik; `grep -ln 'isBacktickQuoted\|dcheckIgnoreMarkerPattern' test/mutations/*.sh`
  ist leer. Ihre Zähne existieren — ich habe beide in Kopien außerhalb des Repos rot gesehen
  (Belege oben unter HIGH-3 und LOW-1) —, aber `make mutate` urteilt nur über **gelistete**
  Wächter: verlöre eine der zwei Ausnahmen später ihre Zähne, spräche kein Lauf davon. Das ist das
  **dritte** Auftreten derselben Klasse in diesem Slice — Runde 1 LOW-2 war der erste, und er ist
  behoben, während derselbe Commit zwei neue erzeugt.
- **verifizierbar:** ja — `grep -ln 'isBacktickQuoted\|dcheckIgnoreMarkerPattern' test/mutations/*.sh`
  (leer) gegen `grep -c 'isBacktickQuoted' internal/emit/templates.go` (nicht null).
- **klasse:** `Neuer-Waechter-ohne-Mutations-Fall`

### LOW-2 — Der Integrations-Wächter klassifiziert die Ausnahme per Substring, den LOW-1 verworfen hat

- **kategorie:** LOW
- **quelle:** Maintainability; [`AGENTS.md`](../../AGENTS.md) §3.6
- **pfad:** `internal/emit/templates_test.go:668`
- **befund:** `TestTemplates_KeineKommentarHilfenImEmittiertenSatz` entscheidet mit
  `strings.Contains(m, "d-check:ignore")`, ob ein überlebender Kommentar die erlaubte Ausnahme ist
  — genau die Substring-Form, die derselbe Commit in der Produktion durch
  `dcheckIgnoreMarkerPattern` ersetzt hat. Der Wächter ist damit **permissiver** als der Code, den
  er bewacht: ließe die Produktion später wieder einen Kommentar stehen, der `d-check:ignore` nur
  im Fließtext trägt, zählte der Test ihn als Marker und meldete nichts. Erreichbar ist der Pfad
  heute nicht — die Fixture trägt keinen solchen Kommentar, und `TestStripCommentHints` fängt die
  Regression auf der Ebene der puren Funktion —, aber es ist eine zweite, driftfähige Definition
  derselben Ausnahme neben der benannten Konstante.
- **verifizierbar:** ja — die Fixture um `<!-- erklaert d-check:ignore -->` ergänzen und die
  Marker-Form in der Produktion auf `strings.Contains` zurücksetzen: `make test-go` bleibt grün.
- **klasse:** `Ausnahme-auf-Substring-statt-auf-Form` (die Klasse aus Runde 1 LOW-1, in der
  Produktion geschlossen, im Wächter offen)

### INFO-1 — Der vorformulierte Ausgang von §6 Risiko 1 passt nicht mehr auf den eingetretenen Fall

- **kategorie:** INFO
- **quelle:** Slice-Plan §6 Risiko 1; Baseline-Regelwerk `modul-05-planning-harness.md`
  §Offene Risiken werden bei Closure aufgelöst
- **pfad:** `docs/plan/planning/done/slice-140-emittierter-stand-ohne-vorlagen-hilfen.md` §6
- **befund:** Das Risiko bietet zwei vorformulierte Ausgänge an: *„entfallen: jede Fundstelle des
  Kommandos einzeln geprüft, keine trägt"* oder *„eingetreten: CO-NNN"*. Eingetreten ist keiner von
  beiden — der beschädigte Text stand nicht **in** einem Kommentar, sondern war ein Inline-Code-Zitat
  der Kommentar-Syntax, das das Muster für einen Kommentar hielt. Damit ist auch die §4-Rückführung
  `in-progress → open` nicht ausgelöst: ihre Bedingung ist *„wenn ein entfernter Kommentar tragenden
  Inhalt hält"* und ihre Begründung *„dann ist die Frage … keine Emit-Frage mehr, sondern eine an
  die Vorlage"* — die Vorlage ist hier unverändert richtig, der Emitter war es nicht. Die
  Vorwärts-Korrektur des Implementers ist damit die passendere Antwort als der Rückweg, und die
  INFO-1-Lesart der Runde 1 ist insoweit zu eng. Notiert wird nur, dass der Planner für den
  Risiko-Ausgang eine dritte Formulierung braucht; welche, entscheidet die Closure
  ([`AGENTS.md`](../../AGENTS.md) §3.10).
- **verifizierbar:** nein (Plan-Auslegung, kein Gate-Gegenstand).
- **klasse:** `Vorformulierter-Risiko-Ausgang-passt-nicht-auf-den-eingetretenen-Fall`

## Negativbefunde (geprüft, ohne Befund)

- **Diff-Umfang.** `git diff --stat 3fd42cc4 HEAD` nennt genau die drei angekündigten Dateien,
  103 Insertions / 17 Deletions. Nichts anderes ist hineingerutscht — insbesondere kein
  Slice-Plan, keine `AGENTS.md`, kein `harness/conventions.md`, keine ADR und keine Datei unter
  `.harness/baseline/`.
- **Gate-Stempel.** `cat .harness/state/gates-passed.diffsha` und
  `bash harness/tools/working-tree-hash.sh` liefern denselben Wert
  (`c9e08cdc…`) — der aufgezeichnete `make gates`-Lauf deckt den aktuellen Baum
  ([`MR-003`](../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung):
  der Nachweis ist inhaltsbasiert, ein Commit ohne Inhaltsänderung entwertet ihn nicht).
- **`make mutate`-Beleg — er trägt, und warum.** `cat .harness/state/mutate-passed.key` und
  `bash -c 'source harness/tools/mutate.sh 2>/dev/null||true; isolation_key'` liefern denselben
  Wert (`fa50272d…`). Ich habe den ~28-Minuten-Lauf **nicht** wiederholt, und das ist begründet
  statt bequem: `finalize_belief` schreibt den Beleg ausschließlich bei `fail_count == 0` und
  löscht ihn sonst (`harness/tools/mutate.sh:163-170`), die Bezugsmenge ist nach
  [ADR-0035](../plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) die
  Isolationskopie ohne `.git` — deshalb überlebt der Beleg den Commit, ohne dass sich am
  Prüfgegenstand etwas geändert hätte. Die Fall-Zahl **278** aus der Commit-Message trägt der
  Beleg allerdings nicht (er speichert nur den Schlüssel); sie ist unabhängig plausibel, weil
  `ls test/mutations/*.sh | wc -l` → 278 liefert und 291 wie 292 darin liegen. Der benannte Rest
  bleibt der von [ADR-0035](../plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
  selbst genannte: lokaler Docker-Cache-Zustand und Host-Werkzeuge.
- **Kern-Zusage des Slice, am realen Satz.** Außerhalb `.claude/` bleibt genau **1** `<!--`-Zeile
  stehen, und die ist das geschonte Zitat; unter `.claude/` bleiben **10** unverändert
  (dasselbe §1-Kommando, `grep -c` gegen `grep -vc`). Die 45 Kommentar-Hilfen des vendored Satzes
  sind weg. Für die Zahl 1 siehe MEDIUM-1 — die Regel greift, das Instrument der DoD trennt nicht.
- **[`LH-FA-08`](../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren) —
  `ANPASSEN`-Marker unberührt.** Neun Dateien unter `.claude/` tragen ihre Marker
  (`grep -rc 'ANPASSEN' "$P/.claude/" | grep -v ':0$'`), unverändert gegenüber Runde 1.
- **`d-check:ignore`-Marker überleben.** Sechs Dateien im emittierten Baum tragen sie
  (`grep -rc 'd-check:ignore' "$P" --include='*.md' | grep -v ':0$'` ohne den Baseline-Baum),
  darunter `AGENTS.md`, `harness/README.md` und beide Skill-Dateien.
- **[`LH-FA-09`](../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren) /
  [`MR-008`](../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert) —
  der vendored Baum ist unverändert.** `diff -rq` zwischen dem mitemittierten
  `.harness/baseline/v6.5.0/templates` und dem des Repos: identisch.
- **Kein Nicht-Kommentar verloren.** Unabhängig nachgerechnet mit einem eigenen awk-Stripper über
  alle zehn emittierten Vorlagen (Methode oben unter HIGH-3). Die Mermaid-Diagramme sind
  vollständig: `spec/architecture.md` behält 9 von 14 `-->` (5 Kommentar-Schließer verbraucht),
  `docs/plan/planning/in-progress/roadmap.md` 4 von 7 (3 verbraucht) — exakt die Differenz.
- **Semantik-Erhalt der Umstellung.** `ReplaceAllStringFunc` → `FindAllStringIndex` mit
  `strings.Builder` liefert dieselbe, nicht-überlappende Treffermenge; der Frühausstieg bei
  `locs == nil` hält die Zusage *„Ohne einen Kommentar unveraendert"*. Die Randbedingungen von
  `isBacktickQuoted` (`start > 0`, `end < len(s)`) fallen fail-open **zugunsten des Entfernens**,
  also in Richtung der Slice-Zusage.
- **`make comment-claims`.** Grün: `57 Datei(en) geprueft, 0 Befund(e)`. Jeder in den neuen
  Kommentaren genannte Sensor existiert — `TestStripCommentHints`,
  `TestTemplates_KeineKommentarHilfenImEmittiertenSatz`, `test/courseset-fixture.bats`.
- **[`AGENTS.md`](../../AGENTS.md) §3.9 — Docker-only.** Kein Host-Toolchain-Aufruf im Diff; alle
  meine Läufe gingen über `make`-Ziele.
- **[`AGENTS.md`](../../AGENTS.md) §3.8 / §3.10 — keine fremden Rollen-Artefakte.** Der Range
  berührt weder Norm-Artefakte noch den Slice-Plan; §7 unverändert, kein DoD-Häkchen gesetzt, kein
  Register-Beleg geschrieben, kein `git mv` nach `done/`.
- **Traceability.** `7377f9ba` nennt `slice-140` und verweist auf den Report der Runde 1.
- **Arbeitsbaum unberührt.** `git status --porcelain` ist vor **und** nach diesem Lauf leer; jede
  Mutation lief in einer Kopie außerhalb des Repos.

## Kategorie-Summary

| Kategorie | Anzahl | Klassen |
|---|---|---|
| HIGH | 0 | — |
| MEDIUM | 2 | `Zusage-neben-geaenderter-Ableitung-bleibt-stehen` · `Neue-oeffentliche-Funktion-ohne-benannte-Grenze` |
| LOW | 2 | `Neuer-Waechter-ohne-Mutations-Fall` · `Ausnahme-auf-Substring-statt-auf-Form` |
| INFO | 1 | `Vorformulierter-Risiko-Ausgang-passt-nicht-auf-den-eingetretenen-Fall` |

**Wiederkehrende Klasse in diesem Slice.** `Neuer-Waechter-ohne-Mutations-Fall` erreicht mit LOW-1
das **dritte** Auftreten innerhalb von slice-140 (Runde 1 LOW-2 behoben, zwei neue im
Behebungs-Commit). Das Register führt die Klasse mit
`ls docs/plan/planning/observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/evidence/*.md | wc -l`
→ **2** Belegen (kein Erwartungswert); ein Beleg aus diesem Slice hebt sie auf die Schwelle. Das
ist ein Steering-Loop-Signal für die Closure, kein bloßer Einzelbefund — und es gehört dorthin,
nicht in diesen Report ([`AGENTS.md`](../../AGENTS.md) §3.10).

## Verdikt

**Kein blockierender HIGH — aber zwei blockierende MEDIUM.**

Die drei HIGH der Runde 1 sind **alle geschlossen**, und zwar belegt: HIGH-1 färbt die
`RootReadme()`-Hälfte nachweislich rot und nennt in der Meldung den richtigen Grund; HIGH-2 nennt
jetzt die tatsächliche — nämlich fehlende — Deckung, und diese Aussage habe ich über neun
bats-Dateien und beide Smokes nachgeprüft statt sie zu glauben; HIGH-3 ist am **realen** vendored
Satz behoben, das Zitat ist byte-gleich, und ein unabhängiger Stripper bezeugt, dass kein
Nicht-Kommentar verloren ging. Auch MEDIUM-1, LOW-1 und LOW-2 der Runde 1 sind erledigt, und die
zwei INFO sind zu Recht dem Planner überlassen.

Blockierend bleibt, was die Behebung selbst erzeugt hat. Die richtige Reparatur von HIGH-3 hat den
Messwert der eigenen Abnahme von 0 auf 1 bewegt, und nichts im Range sagt das — der Verifier
bekäme ein rotes DoD-Kriterium ohne Deutung, und die einzige Rolle, die es umschreiben darf, weiß
nichts davon (MEDIUM-1). Und die Grenzen-Aufzählung, die MEDIUM-1 der Runde 1 einlösen sollte,
lässt ausgerechnet die Form aus, die still Inhalt löscht — gemessen an einer Sonde, nicht
vermutet, und von dem Zählstand, den der Kommentar als Beleg anführt, nicht erfassbar (MEDIUM-2).
Beide sind Ränder, keine Kern-Defekte; beide sind billig zu schließen; keiner der laufenden Gates
sieht einen davon.

**Reif für den Verifier: noch nicht.** Genau sein Prüf-Artefakt — die DoD — ist die Stelle, an der
MEDIUM-1 sitzt.
