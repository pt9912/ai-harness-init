# Review-Report — slice-177 (Das Beobachtungs-Register läuft in der Verzeichnis-Form)

**Datum:** 2026-09-05 · **Rolle:** Reviewer (Modul 8, frischer Kontext) ·
**Skill:** [`.harness/skills/reviewer.md`](../../.harness/skills/reviewer.md) 1.7.0
**Runde:** 2 (Nacharbeit zu
[Runde 1](2026-09-05-slice-177-register-verzeichnis-form-review.md))

## Eingangs-Kontext (fünf Pflicht-Punkte + Slice-Plan)

| Punkt | Inhalt |
|---|---|
| **Diff/Commit-Range** | `e417259..c78d3bc` — die sieben Nacharbeits-Commits: `ac801bb` (`.gitignore`), `9292a08` (`BEO-<NNN>` → `BEO-ALL`), `d3490fb` (Verweis-Nachzug), `7555048` (Rollen-Übergriff zurück), `ebcadf7` (HIGH-2/HIGH-3/MEDIUM-1/MEDIUM-3/LOW-1), `b4b39dc` (Plan-Nachzug), `278248f` (Reviewer-Rolle), `c78d3bc` (DoD 3). Bezugsstand für die Vorher/Nachher-Messungen: `ed0a661` (Migrations-Commit aus Runde 1). |
| **`LH-*`** | [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) |
| **Aktive ADRs im Commit-/Plan-Text** | `ADR-0034` (tragend), `ADR-0028`, `ADR-0016`, `ADR-0030`, `ADR-0015`, `ADR-0033`, `ADR-0017`, `ADR-0018` |
| **Hard Rules** | [`AGENTS.md`](../../AGENTS.md) §3.1–§3.9, tragend hier §3.3, §3.5, §3.6, §3.7, §3.8, §3.9 |
| **Vorherige Findings am gleichen Modul** | [Runde 1](2026-09-05-slice-177-register-verzeichnis-form-review.md) — HIGH ×4, MEDIUM ×3, LOW ×3, INFO ×3. Jeder dieser dreizehn Punkte ist unten einzeln nachgemessen. Dazu [`2026-09-05-slice-182-baum-tausch-v600-review.md`](2026-09-05-slice-182-baum-tausch-v600-review.md) (wiederkehrende Klassen des Registers). |
| **Slice-Plan** (Repo-Ergänzung) | [`slice-177`](../plan/planning/done/slice-177-beobachtungs-register-verzeichnis-form.md) |

**Selbst gefahren, nicht aus Commit-Messages übernommen:** `make gates` (EXIT 0) ·
**drei** kontrafaktische `d-check`-Läufe über zwei Kopien im Scratch-Bereich, mit demselben
gepinnten Digest und derselben netzlosen Docker-Form wie `make docs-check`
([`AGENTS.md`](../../AGENTS.md) §3.9; der Arbeitsbaum wurde nicht angefasst) · Slug-Mengen-
und Rename-Messung über dem Umzugs-Commit · Form-Prüfung über alle 41 Verzeichnisse und
84 Beleg-Dateien · Register-Paarung über alle 84 Belege.

Alle Zahlen unten stehen neben dem Kommando, das sie liefert
([`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 1); keine ist ein Erwartungswert.

---

## Status der dreizehn Runde-1-Befunde

| Runde 1 | Status nach Nachmessung | hier |
|---|---|---|
| HIGH-1 `Entschiedene-Ziel-Form-nicht-vollzogen` | **behoben** für die Ablage; ein Rest bleibt | Negativbefund 1 · MEDIUM-4 |
| HIGH-2 `Sensor-Grenze-als-Sensor-Aussage` | **weitgehend behoben**; Aufzählung eine Datei zu kurz | MEDIUM-1 |
| HIGH-3 `Zusage-neben-geaenderter-Ableitung-bleibt-stehen` | **behoben** | Negativbefund 4 |
| HIGH-4 `Fremdes-Rollen-Artefakt-im-Implementations-Kontext` | **halb behoben, halb in die Gegenrichtung aufgelöst** | HIGH-1 |
| MEDIUM-1 `Folge-Slice-traegt-den-Befund-nicht` | **behoben**; eine Stelle der eigenen Hälfte fehlt | Negativbefund 5 · MEDIUM-3 |
| MEDIUM-2 `Gate-Ergebnis-haengt-an-ungeignortem-Pfad` | **nicht behoben**, und der Plan sagt jetzt, es sei behoben | HIGH-2 |
| MEDIUM-3 `Zwei-Konventionen-fuer-dieselbe-Referenzklasse` | **entschieden, nicht vollzogen** | MEDIUM-5 |
| LOW-1 `Label-nennt-abgeloesten-Pfad` | **behoben** | Negativbefund 6 |
| LOW-2 `Zusage-neben-geaenderter-Ableitung-bleibt-stehen` | für DoD 3 behoben, **an zwei anderen Stellen desselben Plans wiederholt** | MEDIUM-2 |
| LOW-3 `Zeitdokument-Klasse-uneinheitlich-behandelt` | **behoben** | Negativbefund 7 |
| INFO-1 `Urteilsbehaftete-Migration-ohne-Sensor` | unverändert, kein Befund | — |
| INFO-2 `Folgepflicht-ohne-Gegenstand` | **hat jetzt einen Gegenstand** und trägt eine Zusage ohne Deckung | MEDIUM-6 |
| INFO-3 (Rename-Messung) | für den neuen Umzugs-Commit nachgemessen | INFO-2 |

---

## Findings

### HIGH-1 — Der Adaptions-Block wurde im Implementations-Kontext geschrieben, nachdem derselbe Lauf denselben Übergriff auf der Skill-Datei zurückgenommen hatte

- **kategorie:** HIGH
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.8 (*Hard Rules und Adaptions-Block schreibt der Architect*), [`ADR-0034`](../plan/adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md) §Festlegung 3 (letzter Absatz) und Folgepflicht 2
- **pfad:** Commit `d3490fb`, darin `harness/conventions/MR-041-*.md`, `harness/conventions/MR-047-*.md`, `harness/conventions/MR-048-*.md`
- **befund:** `d3490fb` trägt die Message *„Rolle Implementation: slice-177 …"* und ändert drei Dateien im Eintrags-Verzeichnis des Adaptions-Blocks. §3.8 sagt dazu wörtlich: *„Die Hard Rules dieser Datei (§3) und der Adaptions-Block — die Index-Datei `harness/conventions.md` samt dem Eintrags-Verzeichnis `harness/conventions/` daneben — werden vom **Architect** geschrieben. … Gebunden ist das **Schreiben**"*. Die Commit-Message stellt dem eine Einschränkung entgegen, die im Regeltext nicht steht: *„AGENTS.md 3.8 bindet die inhaltliche Aenderung, nicht diesen Fall"* — `sed -n '/^### 3\.8 /,/^### 3\.9 /p' AGENTS.md | grep -c 'inhaltlich'` → **0**. Eine Norm-Quelle für die behauptete Ausnahme existiert nicht: `git grep -n -i 'Move-Folge\|reiner Pfad-Nachzug' -- AGENTS.md 'docs/plan/adr/*.md' harness/conventions.md 'harness/conventions/*.md'` → leer, Exit 1. [`ADR-0034`](../plan/adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md) sagt für genau dieses Artefakt das Gegenteil — *„**Das ist ein Architect-Commit** ([`AGENTS.md`] §3.8) und liegt damit neben dem Migrations-Commit aus Festlegung 4, nicht in ihm"*. Der Commit verletzt zusätzlich den Zuschnitt, den derselbe Satz verlangt (*„eigener Commit, der ausschließlich Artefakte derselben schreibenden Rolle berührt"*): `git show --pretty=format: --name-only d3490fb` führt neben den drei Einträgen `docs/plan/planning/done/slice-178-…md` und `docs/reviews/2026-09-05-slice-178-nachtraeglich-review.md`. Der Widerspruch liegt wieder im Lauf selbst: knapp eine Minute später nimmt `7555048` den identisch begründeten Übergriff auf `.harness/skills/reviewer.md` **zurück** — mit der Begründung *„die inhaltliche Korrektur … ist Sache der Reviewer-Rolle im eigenen Kontext"*. Zwei Artefakte, dieselbe Regel-Familie, zwei entgegengesetzte Entscheidungen in einem Lauf.
- **verifizierbar:** nein durch ein Gate — kein Modul aus `modules:` der [`.d-check.yml`](../../.d-check.yml) liest Commits, und `make mutate` kennt keine Fehlschlag-Form für einen Commit-Zuschnitt ([`AGENTS.md`](../../AGENTS.md) §3.8 stellt dieselbe Lage für sich selbst fest). Ja durch Handlauf: `git show --stat d3490fb` gegen `git log --oneline ed0a661..HEAD -- harness/conventions.md harness/conventions/`.
- **klasse:** `Fremdes-Rollen-Artefakt-im-Implementations-Kontext` (unmittelbare Wiederholung von HIGH-4 aus Runde 1, im selben Slice, auf einem anderen Artefakt)

### HIGH-2 — DoD 3 sagt, die Gate-Verunreinigung sei „nicht mehr reproduzierbar"; sie ist reproduziert, und der genannte Mechanismus wirkt auf `docs-check` nicht

- **kategorie:** HIGH
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 (*Keine Zusage ohne rot gesehenes Gegenbeispiel* — ein DoD-Punkt ist dort namentlich als Zusage geführt), [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
- **pfad:** [`slice-177`](../plan/planning/done/slice-177-beobachtungs-register-verzeichnis-form.md) §2 DoD 3 (Zeilen 182–185), `.gitignore` Zeilen 19–24
- **befund:** DoD 3 sagt: *„die zuvor gemeldete externe Verunreinigung durch ein fremdes Orchestrierungs-Artefakt (§6) ist nicht mehr reproduzierbar — das Verzeichnis ist inzwischen ignoriert"*. Gemessen ist beides falsch. In einem vollständigen Klon von `c78d3bc` (mit `.git`, damit der gepinnte d-check den git-Zustand sehen kann) bestätigt `git check-ignore -v .claude/worktrees/agent-probe/probe.md` die Ignorierung (Regel `.gitignore:24`), und derselbe Lauf meldet trotzdem: Kontrolle ohne Probe `774 Datei(en) geprüft, 0 Befund(e)`, mit einer einzigen ignorierten Probe-Datei unter `.claude/worktrees/agent-probe/` `775 Datei(en) geprüft, 2 Befund(e)` — beide Befunde aus der Probe. `.gitignore` verändert die Scan-Fläche von `d-check` nicht; die geprüfte Datei-Zahl **steigt**. Dieselbe Lage auf der zweiten Achse: `harness/tools/comment-claims.sh` schneidet in der Sensor-Existenz-Prüfung mit `find . -name '*_test.go'`, und `find` liest `.gitignore` ebenfalls nicht. Das eigentliche Risiko aus Runde 1 (MEDIUM-2) ist damit unverändert: ein paralleler Agenten-Worktree macht denselben Baum rot, ohne dass sich ein Byte des Repos geändert hat. Verschärfend ist nicht das Risiko, sondern die Zusage darüber — `ac801bb` selbst benennt seine Wirkung korrekt (*„Reine Git-Tracking-Hygiene, keine .d-check.yml-Aenderung"*), der Plan liest daraus eine Wirkung, die die Messung widerlegt. §6 desselben Plans sagt dazu weiter, eine `.gitignore`-Ergänzung gehöre *„nicht zum Liefer-Umfang"* — sie ist gemacht.
- **verifizierbar:** ja — `git clone --no-hardlinks . <kopie> && git -C <kopie> checkout c78d3bc`, dort eine Markdown-Datei mit totem Link unter `.claude/worktrees/<x>/` ablegen, dann `docker run --rm --network none -v "<kopie>:/repo:ro" ghcr.io/pt9912/d-check@sha256:5ea03abe7918381c68203d8ac078a78d0d4ab91b5478e87c66b5a7b4fda41288` → `775 … 2` gegen `774 … 0` ohne die Probe.
- **klasse:** `Zusage-nennt-Mechanismus-ohne-gemessene-Wirkung`

### MEDIUM-1 — Der neu geschriebene `.d-check.yml`-Kommentar zählt acht `open/`-Dateien auf; gemessen sind es neun, und die neunte hat derselbe Commit erzeugt

- **kategorie:** MEDIUM
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.7 (*Ein Kommentar beschreibt, was da ist*), [`MR-009`](../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile)
- **pfad:** `.d-check.yml` Zeile 175
- **befund:** Die Klassen-Aussage des Kommentars hält — das ist die Reparatur zu HIGH-2 aus Runde 1 und sie ist gemessen: über einer `git archive HEAD`-Kopie mit **nur** der `ignore-refs`-Zeile `docs/plan/planning/observations.md` entfernt meldet derselbe gepinnte d-check `774 Datei(en) geprüft, 108 Befund(e)`, verteilt auf `docs/plan/planning/done/` **89**, `docs/plan/planning/open/` **13**, `docs/plan/planning/in-progress/` **5**, `docs/user/` **1** — und **kein** Treffer außerhalb der vier im Kommentar genannten Klassen (`grep -vE '^(docs/plan/planning/(done|open|in-progress)/|docs/user/benutzerhandbuch\.md)'` über der Befundliste → leer). Die drei Treffer in `.claude/commands/` und die drei in `internal/emit/templates/commands/` aus Runde 1 sind fort. Falsch ist die **Aufzählung innerhalb** einer Klasse: der Kommentar nennt `slice-151/152/153/162/168/171/174/181`, die Messung liefert `slice-184` als neunte Datei. Und sie war zum Schreibzeitpunkt schon da: `for c in ed0a661 ebcadf7; do git show "$c:docs/plan/planning/open/slice-184-register-form-im-bestand-nachziehen.md" | grep -c '\.\./observations\.md'; done` → **0**, **1** — der Commit `ebcadf7`, der den Kommentar schreibt, ist derselbe, der den neunten Treffer anlegt. Der Kommentar präsentiert sich ausdrücklich als Messung (*„Gemessen (Eintrag entfernt, docs-check ueber der Kopie)"*), und ein Folgelauf, der die Aufzählung als geschlossene Menge liest, übersieht genau die Datei, die den Nachzug definiert.
- **verifizierbar:** ja — der kontrafaktische Lauf oben, dessen `open/`-Zeilen mit `grep -oE '^docs/plan/planning/open/[^:]+' | sort -u` neun Dateien liefern.
- **klasse:** `Gemessene-Aufzaehlung-am-eigenen-Commit-unvollstaendig`

### MEDIUM-2 — DoD 2 und §6 sagen im Präsens „1 verbleibender `target-missing`-Befund", während DoD 3 desselben Plans „0 Befund(e)" sagt

- **kategorie:** MEDIUM
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.7 (*Ein Kommentar beschreibt, was da ist*, Zustandsfeld-Hälfte), §3.6 (der DoD-Punkt als Zusage), Baseline-Regelwerk `modul-05-planning-harness.md` §Offene Risiken werden bei Closure aufgelöst
- **pfad:** [`slice-177`](../plan/planning/done/slice-177-beobachtungs-register-verzeichnis-form.md) Zeile 174 (DoD 2) und Zeilen 333–336 (§6, sechstes Risiko)
- **befund:** DoD 2 schließt mit *„Belegt durch `make docs-check`: **1** verbleibender `target-missing`-Befund, genau diese eine Zeile, 0 sonst. Der Punkt gilt damit als erfüllt **bis auf** diese eine, bewusst belassene Reviewer-Übergabe."* §6 sagt dazu *„`make docs-check` zeigt dafür bewusst **1** `target-missing`-Befund, bis die Reviewer-Rolle die inhaltliche Korrektur in ihrem eigenen Kontext vornimmt"* und trägt den Ausgang *„weiter offen"*. Die Reviewer-Rolle hat die Korrektur mit `278248f` vorgenommen; mein `make gates` meldet `d-check: 774 Datei(en) geprüft, 0 Befund(e)`, EXIT 0. Beide Stellen behaupten damit einen Befund, den es nicht gibt, und beide stehen neben DoD 3 in derselben Datei, das seit `c78d3bc` *„`d-check: 774 Datei(en) geprüft, 0 Befund(e)`"* sagt — der Plan widerspricht sich in zwei Häkchen, die beide `[x]` tragen. Der Risiko-Ausgang *weiter offen* trägt zusätzlich nicht mehr, was er zu tragen vorgibt: der benannte Träger hat gehandelt, der Ausgang ist damit *entfallen*, nicht *offen* — und ein Slice geht nicht nach `done/`, solange ein Ausgang danebensteht, der nicht trägt.
- **verifizierbar:** ja — `make docs-check` gegen `sed -n '174p;333,336p' docs/plan/planning/done/slice-177-beobachtungs-register-verzeichnis-form.md`.
- **klasse:** `Zusage-neben-geaenderter-Ableitung-bleibt-stehen` — im Register `BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen` (Stand `geplant`). Dritter **Fund** dieser Klasse in diesem Slice nach Runde-1 HIGH-3 und LOW-2; das Register zählt je Vorgang, nicht je Fund, also **ein** Beleg für slice-177.

### MEDIUM-3 — Ein `awk`-Kommando in einem lebenden Plan liest die abgeschaffte Tabelle, liegt in der von diesem Slice beanspruchten Hälfte und ist für den zitierten Sensor unsichtbar

- **kategorie:** MEDIUM
- **quelle:** [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) Setzung 1 (die Zahl steht neben dem Kommando, das **sie** liefert), [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
- **pfad:** `docs/plan/planning/open/slice-181-grenzen-liste-vollstaendig-oder-fail-closed.md` Zeile 205
- **befund:** §8 von slice-181 belegt seinen Sichtungs-Schritt mit `awk -F'|' '/BEO-0(09|22|25)/ {print $2, $5, $6}' docs/plan/planning/observations.md`. Die Datei existiert nicht mehr (`ls docs/plan/planning/observations.md` → *Datei oder Verzeichnis nicht gefunden*), und die Feldstruktur, auf die das Kommando schneidet, gibt es in der Ziel-Form ebenfalls nicht — ein reiner Pfad-Nachzug auf `observations/README.md` ergäbe ein Kommando, das lautlos leer liefert. Die Stelle liegt **innerhalb** der Grenze, die dieser Slice für sich reklamiert: §6 nennt als eigene Hälfte *„die bare Adresse `observations.md` → `observations/README.md`, überall dort, wo sie **unabhängig** von der Vorlagen-Zeile auftritt"*, und Zeile 205 ist keine Vorlagen-Zeile (die zwei Vorlagen-Zeilen derselben Datei stehen auf 87 und 180 und sind korrekt slice-184 zugeschlagen). `docs-check` sieht sie nicht: der Pfad steckt in einem Inline-Code-Span, der ein ganzes Shell-Kommando umfasst, und taucht im kontrafaktischen Lauf ohne den Tombstone nicht unter den 108 Befunden auf. DoD 2 führt `make docs-check` als Beleg für den vollständigen Nachzug an; für diese Klasse belegt er nichts.
- **verifizierbar:** ja — `grep -n 'observations\.md' docs/plan/planning/open/slice-181-*.md` (drei Treffer: 87, 180, 205) gegen die `open/`-Zeilen der 108-Befund-Liste (nur 87 und 180).
- **klasse:** `Sensor-Grenze-als-Sensor-Aussage` — im Register `BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht`

### MEDIUM-4 — Das neue §6-Risiko schätzt seinen Umfang ohne Kommando und trägt einen Ausgang, den der eigene Diff bereits widerlegt hat

- **kategorie:** MEDIUM
- **quelle:** Baseline-Regelwerk `modul-05-planning-harness.md` §Offene Risiken werden bei Closure aufgelöst (drei Ausgänge, geschlossene Menge; *eingetreten* → Carveout oder Folge-Slice **mit ID**), [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) Setzung 1
- **pfad:** [`slice-177`](../plan/planning/done/slice-177-beobachtungs-register-verzeichnis-form.md) Zeilen 337–346 (siebtes Risiko)
- **befund:** Die Scope-Abgrenzung als solche ist tragfähig und wird hier **nicht** beanstandet: die Prosa-Zitate der alten Nummer sind ein eigener Nachzieh-Vorgang, kein Nebenprodukt des Umzugs. Zwei Eigenschaften des Eintrags tragen aber nicht. **Erstens der Umfang:** *„Der Umfang ist zehn bis mehrere Dutzend Dateien"* — eine Spanne ohne Kommando in einem lebenden Plan. Gemessen: `git grep -l 'BEO-[0-9]' -- '*.md' ':!.harness/baseline' ':!docs/reviews' ':!docs/plan/planning/done' ':!docs/plan/planning/observations' | wc -l` → **23** Dateien, dieselbe Suche mit `-o 'BEO-[0-9][0-9][0-9]' … | wc -l` → **134** Vorkommen, verteilt auf `docs/plan/planning/open/` **13** Dateien, `harness/conventions/` **3**, `docs/plan/adr/` **2**, `docs/plan/planning/in-progress/` **2**, `.claude/commands/` **1**, `docs/plan/planning/` **1**, `harness/` **1**. Dazu **7** Vorkommen **innerhalb** von `observations/` selbst (`git grep -c 'BEO-[0-9]' -- 'docs/plan/planning/observations' | awk -F: '{s+=$NF} END{print s+0}'`), sechs davon in `evidence/`-Dateien, die die Ablage-Regel als *unveränderlich ab Merge* führt, und einer in einer `observation.md`, die *unveränderlich ab Anlage* ist: `BEO-ALL/regel-delta-zaehlt-herkunfts-kommentar-mit/observation.md` Zeile 8 verweist auf `BEO-019` — ein Ziel, das seit `9292a08` nirgends mehr auflöst (es war `BEO-019/byte-gleichheit-als-aussage-ueber-die-regel-gelesen`, nur noch über `git ls-tree 9292a08^` erreichbar). **Zweitens der Ausgang:** *„weiter offen"*. Das Risiko ist in diesem Diff eingetreten — `9292a08` hat die 134 Zitate erst tot gemacht —, und der Eintrag lässt offen, wer es aufnimmt (*„ob er in [slice-184] aufgeht oder einen eigenen Folge-Slice bekommt, entscheidet die Planner-Closure"*). Modul 5 lässt für den eingetretenen Fall Carveout oder Folge-Slice **mit ID**; eine Kennung nennt der Eintrag nicht. Die Zuordnung an die Planner-Closure zu delegieren ist eine legitime Übergabe — sie ist nur kein Ausgang aus der geschlossenen Dreiermenge.
- **verifizierbar:** ja — die drei `git grep`-Kommandos oben, dazu `git ls-tree -r --name-only 9292a08^ docs/plan/planning/observations/BEO-019/`.
- **klasse:** `Ausgang-nennt-Traeger-der-nicht-traegt` — im Register `BEO-ALL/ausgang-nennt-traeger-der-nicht-traegt` (Stand `offen`)

### MEDIUM-5 — Die Verweis-Konvention ist jetzt entschieden, und 46 lebende Links widersprechen ihr

- **kategorie:** MEDIUM
- **quelle:** Maintainability, [`MR-045`](../../harness/conventions.md#mr-045--der-adaptions-block-läuft-in-der-verzeichnis-form) (die Präzedenz, die ihren Verweis-Mechanismus vollzogen und nicht nur erklärt hat)
- **pfad:** `docs/plan/planning/observations/README.md` Zeilen 62–68; Beispiele `docs/plan/planning/in-progress/roadmap.md`, `docs/plan/planning/open/slice-151-spec-straten-haben-eine-schreibende-rolle.md`, `docs/plan/planning/open/slice-152-adr-0029-acceptance-trigger.md`
- **befund:** Runde-1-MEDIUM-3 beanstandete, dass keine Quelle entscheidet, ob ein Beobachtungs-Verweis auf die Register-Wurzel oder auf den Eintrag zeigt. `ebcadf7` entscheidet es: *„Ein Verweis auf **eine konkrete Beobachtung** — ihre Bezeichnung, ihr Stand, ihr Zähler — zeigt auf deren eigene `observation.md`"*. Der Bestand folgt der Entscheidung nicht und wird auch nirgends als außerhalb erklärt: ``git grep -o '\[`BEO-[0-9]*`\]([^)]*observations/README\.md)' -- '*.md' ':!.harness/baseline' ':!docs/reviews' ':!docs/plan/planning/done' | wc -l`` → **46** Links, deren Label eine konkrete Beobachtung nennt und die auf die Wurzel zeigen, gegen `git grep -o 'observations/BEO-ALL/[a-z0-9-]*/observation\.md' -- '*.md' ':!.harness/baseline' | wc -l` → **3** in der entschiedenen Form (die drei Adaptions-Einträge aus HIGH-1). Jedes dieser 46 Label nennt zudem eine Kennung, die es nicht mehr gibt — dieselbe Klasse wie LOW-1 aus Runde 1, eine Ebene höher: dort nannte das Label eine gelöschte Datei, hier eine gelöschte Identität. Ein Lauf, der die Konvention liest und den Bestand sieht, hat wieder zwei Formen vor sich, nur ist eine davon jetzt ausdrücklich falsch.
- **verifizierbar:** ja — die zwei `git grep -o … | wc -l` oben.
- **klasse:** `Entschiedene-Konvention-ohne-Vollzug-im-Bestand`

### MEDIUM-6 — Die Register-README verlangt das Nachschlagen des Kürzels in einer Tabelle, die keine Kürzel-Spalte führt

- **kategorie:** MEDIUM
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6, [`ADR-0034`](../plan/adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md) Festlegung 3 und Folgepflicht 2
- **pfad:** `docs/plan/planning/observations/README.md` Zeilen 52–57, `harness/conventions.md` Zeilen 191–195
- **befund:** Die README, die dieser Slice schreibt, sagt: *„Das `<KUERZEL>` im Verzeichnisnamen wird aus derselben Tabelle **nachgeschlagen, nicht erfunden**: Steht in `observation.md` ein Name, den die Modus-Deklaration nicht führt, ist entweder die Zuordnung falsch oder die Deklaration unvollständig."* Die genannte Tabelle führt kein Kürzel: `harness/conventions.md` sagt weiterhin *„**Eine Kürzel-Spalte führt diese Tabelle nicht.**"* und begründet das gegen den **abgelösten** Stand (``grep -c 'adoptierter Stand `v5.18.0`' harness/conventions.md`` → **1**). Runde 1 führte das als INFO-2 mit dem Vorbehalt, es werde erst sinnvoll, wenn die Ablage das Kürzel benutzt — mit `9292a08` benutzt sie es (41 von 41 Verzeichnissen unter `BEO-ALL/`), und die Nachschlage-Zusage steht seither ohne Gegenstück. Der Nachzug ist Architect-Arbeit ([`ADR-0034`](../plan/adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md) Folgepflicht 2, dort ausdrücklich als eigener Commit ausgewiesen) und nicht Sache dieses Laufs; der Befund ist, dass der Plan die Abhängigkeit weder als Übergabe benennt noch die Zusage einschränkt.
- **verifizierbar:** ja — `sed -n '52,57p' docs/plan/planning/observations/README.md` gegen `sed -n '191,195p' harness/conventions.md`.
- **klasse:** `Zusage-verweist-auf-ein-noch-nicht-geschriebenes-Artefakt`

### LOW-1 — Ein neuer `.gitignore`-Kommentar trägt eine Befund-Kennung als Grund und beschreibt eine Kausalität, die die Messung nicht stützt

- **kategorie:** LOW
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.7 (*Beschrieben wird die Stelle, nicht der Vorgang, der sie erzeugt hat*; Cutoff für die Quellen-Klausel ab 2026-08-30, dieser Kommentar ist vom 2026-09-05)
- **pfad:** `.gitignore` Zeilen 19–24
- **befund:** Der Kommentar sagt *„Ungetrackt und ungeignored liess sie docs-check den fremden Baum mitscannen (Review-Befund slice-177, MEDIUM)"*. Zwei Punkte. Die Klammer ist die Form, die §3.7 namentlich verwirft — *„Falsch: „… gebrochen, Review-Befund slice-022b N-4" — eine Befund-Kennung als Grund. Sie löst nach `docs/reviews/**` auf, einem Zeitdokument in keinem Rang."* Und die Kausalität stimmt nicht: `d-check` scannt den Baum unabhängig vom git-Zustand, gemessen in HIGH-2 — *ungetrackt und ungeignored* war nicht der Grund und *geignored* ist nicht die Abhilfe. Der Bestand derselben Datei ist nicht gebunden (eine ältere Zeile trägt dieselbe Form, Cutoff).
- **verifizierbar:** nein durch ein Gate — `make comment-claims` prüft vier Pfad-Muster, `.gitignore` liegt in keinem (`comment-claims: 55 Datei(en) geprueft`). Ja durch Handlauf: die Probe aus HIGH-2.
- **klasse:** `Kommentar-traegt-Herkunft-statt-Zustand`

### LOW-2 — Ein toter Baseline-Pfad in einem lebenden Artefakt, den kein Modul sieht

- **kategorie:** LOW
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.7, [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
- **pfad:** `harness/conventions.md` Zeilen 193–194
- **befund:** Die Begründung der fehlenden Kürzel-Spalte nennt einen Inline-Code-Pfad in den Baseline-Baum des abgelösten Tags `v5.18.0`. Der Baum trägt einen Tag zur Zeit: `ls -d .harness/baseline/*/` → nur `v6.0.0`, und ein `ls` auf den genannten Pfad meldet *nicht gefunden*. `make docs-check` ist grün, obwohl `codepaths.roots` `harness` führt und die zitierende Datei im Prüfbereich liegt — die Klasse hat hier keinen Wächter. Der Gegenstand gehört dem Adaptions-Durchgang gegen `v6.0.0` ([slice-185](../plan/planning/open/slice-185-adaptions-durchgang-gegen-v600.md)) und dem Architect, nicht diesem Slice; die Zeile steht, weil MEDIUM-6 auf denselben Absatz zeigt und beide in dieselbe Übergabe gehören.
- **verifizierbar:** ja — die zwei `ls` oben gegen `make docs-check` (`774 … 0`).
- **klasse:** `Praesens-Aussage-gegen-gepinnten-Stand`

### INFO-1 — `make gates` unabhängig gefahren, die Zahlen des Implementers halten

- **kategorie:** INFO
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §4
- **pfad:** —
- **befund:** `make gates` → **EXIT 0**. `baseline-verify: v6.0.0 OK — 53 Dateien` · `d-check: 774 Datei(en) geprüft, 0 Befund(e)` · bats `1..218`, **218** `ok`, **0** `not ok` · `comment-claims: 55 Datei(en) geprueft, 0 Befund(e)` · `go test -count=1 ./...` grün · `span-check` grün. Die Angabe des Implementers (EXIT 0, `774/0`) ist damit unabhängig bestätigt.
- **verifizierbar:** ja — `make gates`.
- **klasse:** —

### INFO-2 — Der Umzugs-Commit ist ein reiner Rename, §3.3 ist gewahrt

- **kategorie:** INFO
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.3
- **pfad:** Commit `9292a08`
- **befund:** `git diff-tree -r --name-status -M 9292a08 | awk '{print substr($1,1,1)}' | sort | uniq -c` → **166** `R`, sonst nichts; `git diff-tree -r -M --numstat 9292a08 | awk '$1!=0 || $2!=0'` → leer. Move und Inhaltsänderung liegen getrennt: der Pfad-Nachzug steht in `d3490fb` (der aber HIGH-1 auslöst). Die Zerlegung selbst ist durch den Umzug nicht angetastet — die Slug-Mengen vor und nach dem Move sind zeichengleich.
- **verifizierbar:** ja — die zwei Kommandos oben.
- **klasse:** —

### INFO-3 — Eine Hälfte von HIGH-2 ist von mir nicht reproduziert

- **kategorie:** INFO
- **quelle:** — (Grenze der eigenen Prüfung)
- **pfad:** `harness/tools/comment-claims.sh`
- **befund:** §6 des Plans meldet neben der `docs-check`-Verdopplung einen zweiten Effekt: eine `pipefail`/`SIGPIPE`-Interaktion, die bei zwei Treffern ein falsches `NOT FOUND` liefert. In meiner Probe — dieselbe Pipeline, zwei Treffer über einer duplizierten `internal/gen/gen_test.go` — kam `FOUND`. Ich bestätige den Effekt also **nicht** und widerlege ihn auch nicht; was ich messe, ist die unveränderte Schnittfläche: `find .` liest `.gitignore` nicht. Die Zeile steht, damit HIGH-2 nicht als Bestätigung der zweiten Hälfte gelesen wird.
- **verifizierbar:** nein.
- **klasse:** —

---

## Negativbefunde (geprüft, ohne Befund)

1. **HIGH-1 aus Runde 1 — die Ablage steht in der entschiedenen Ziel-Form.** `ls docs/plan/planning/observations/BEO-ALL/ | wc -l` → **41**; `ls docs/plan/planning/observations/ | grep -vE '^(BEO-ALL|README\.md)$'` → leer, Exit 1; `ls docs/plan/planning/observations/BEO-ALL/ | sort | uniq -d` → leer, **keine Slug-Kollision**. Die Slug-Mengen vor und nach dem Move sind identisch (`diff` über beide sortierten Listen, aus `git ls-tree -r --name-only 9292a08^` bzw. `HEAD`, leer). [`ADR-0034`](../plan/adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md) Festlegung 3 vergibt `ALL` für `*` (gesamtes Repo), und alle 41 Einträge führen genau diese Sub-Area (`grep -h '^\*\*Sub-Area:\*\*' …/BEO-ALL/*/observation.md | sort | uniq -c` → **41** × `` `*` (gesamtes Repo) ``).
2. **Form je Datei, nach dem zweiten Umzug erneut geprüft.** 41/41 `observation.md` mit H1 in Zeile 1, 41/41 `state.md` mit `**Stand:**`, 84/84 Evidence-Dateien mit `**Vorgang:**`; kein `Zähler:`-Feld irgendwo (`grep -rc 'Zähler:' docs/plan/planning/observations/` → **0**).
3. **Register-Paarung, maschinelle Hälfte.** Für alle **84** Evidence-Dateien liegt eine `done/`-Datei des benannten Vorgangs vor — **0** ohne Datei, über alle geprüft, keine Stichprobe.
4. **HIGH-3 aus Runde 1 — die Planning-README beschreibt die Verzeichnis-Form.** `sed -n '29,35p' docs/plan/planning/README.md`: *„`observations/` liegt als Verzeichnis in diesem Ordner … je Beobachtung ein eigenes Verzeichnis … Die Regeln stehen in `observations/README.md`."* Vier falsche Aussagen aus Runde 1, vier ersetzt; beide Links lösen auf.
5. **MEDIUM-1 aus Runde 1 — die zirkuläre Zuweisung ist aufgelöst, und die eigene Hälfte ist bis auf MEDIUM-3 vollzogen.** Beide Pläne tragen jetzt dieselbe, symmetrische Grenze (slice-177 §6, slice-184 §1). Die sechs Anweisungssatz-Dateien zeigen auf `observations/README.md` (`git grep -n 'observations' -- .claude/commands internal/emit/templates/commands` → sechs Treffer, alle auf `docs/plan/planning/observations/README.md`), und im kontrafaktischen Lauf erzeugt keine davon mehr einen Befund. Die Form-Hälfte, die slice-184 trägt, misst wie dort angegeben **4** Dateien (`git grep -lE 'BEO-<NNN>|Registerzeile|Zähler erhöhen' -- .claude/commands internal/emit/templates/commands | wc -l`).
6. **LOW-1 aus Runde 1 — die Label sind nachgezogen.** ``git grep -c '\[`observations\.md`\](' -- '*.md' ':!.harness/baseline'`` → genau **1** Treffer, und er liegt im Runde-1-Report selbst, also in einem Zeitdokument, das korrekt unangetastet blieb.
7. **LOW-3 aus Runde 1 — der `done/`-Bestand ist einheitlich.** `git grep -n 'observations' -- 'docs/plan/planning/done/*.md'` liefert keinen Markdown-Link mehr auf die Ablage; `done/slice-178-…` trägt seine zwei Nennungen als reinen Text. Dieselbe Behandlung ist auf `docs/reviews/2026-09-05-slice-178-nachtraeglich-review.md` angewandt (Adresse fällt, Text bleibt), konsistent mit [`ADR-0016`](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 4.
8. **Mein eigener Runde-1-Report ist unangetastet.** `git log --oneline e417259..HEAD -- docs/reviews/2026-09-05-slice-177-register-verzeichnis-form-review.md` → leer. Kein Nacharbeits-Commit hat den Befund-Bestand umgeschrieben.
9. **HIGH-4 aus Runde 1, Skill-Datei-Hälfte — korrekt aufgelöst.** `7555048` setzt die Zeile auf den Vor-Migrations-Wortlaut zurück; `278248f` trägt die Message *„Rolle Reviewer: …"*, ändert **eine** Datei und **eine** Zeile (`git show --stat 278248f` → `.harness/skills/reviewer.md | 2 +-`) und nennt [`ADR-0028`](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Festlegung 1 als Grundlage. Das ist die Sequenz mit Übergabe-Artefakt, die Modul 8 verlangt.
10. **`test/ignore-refs-restbreite.bats` bleibt grün.** Der Restbreiten-Wächter läuft im `make gates`-Lauf mit (218/218 `ok`, `0 not ok`); der siebte `ignore-refs`-Eintrag deckt weiterhin höchstens einen Link je Quelldatei.
11. **Kein Go-, Shell- oder Workflow-Code in der Nacharbeit.** `git diff --name-only e417259 c78d3bc -- '*.go' '*.sh' '*.yml' ':!.d-check.yml'` → leer; `lint`, `build`, `shell-lint`, `ci-lint` haben zu diesem Diff nichts zu sagen außer ihrem Grün.
12. **Keine neue Gate-Zusage, keine Modul-Änderung.** `modules:` in [`.d-check.yml`](../../.d-check.yml) ist unverändert (`links, anchors, ids, matrix, codepaths, spans`), `scan.ignore` und `codepaths.exempt-paths` ebenfalls; der einzige Config-Diff der Nacharbeit ist der Kommentar aus MEDIUM-1.

## Nicht geprüft (Abgrenzung)

- Die **DoD-Abhakung als solche** bleibt Sache der Verifikation (getrennter Kontext). Geprüft habe ich, ob die *Aussagen in* den DoD-Punkten gegen den Baum halten — das trägt HIGH-2 und MEDIUM-2.
- Der **Inhalt** von slice-178, slice-181, slice-184 und [`ADR-0036`](../plan/adr/0036-ziel-fassung-regiert-den-sprung-v600.md) — eigene Gegenstände. Berührt sind sie nur dort, wo slice-177 eine Grenze zu ihnen zieht.
- Die **Kollisions-Zusage** der neuen Ablage: §6 nennt sie weiterhin als hergeleitet, nicht rot gesehen. Ich habe kein Merge-Verhalten gemessen und bestätige sie nicht.
- Ob der **Umfang der Zerlegung** eine Review-Sitzung überschreitet (§6, viertes Risiko): er tut es nicht — beide Runden waren in je einer Sitzung prüfbar. Die Rückführung aus §4 greift nicht.

## Kategorie-Summary

| Kategorie | Anzahl | Kennungen |
|---|---|---|
| HIGH | 2 | HIGH-1 `Fremdes-Rollen-Artefakt-im-Implementations-Kontext` · HIGH-2 `Zusage-nennt-Mechanismus-ohne-gemessene-Wirkung` |
| MEDIUM | 6 | MEDIUM-1 `Gemessene-Aufzaehlung-am-eigenen-Commit-unvollstaendig` · MEDIUM-2 `Zusage-neben-geaenderter-Ableitung-bleibt-stehen` · MEDIUM-3 `Sensor-Grenze-als-Sensor-Aussage` · MEDIUM-4 `Ausgang-nennt-Traeger-der-nicht-traegt` · MEDIUM-5 `Entschiedene-Konvention-ohne-Vollzug-im-Bestand` · MEDIUM-6 `Zusage-verweist-auf-ein-noch-nicht-geschriebenes-Artefakt` |
| LOW | 2 | LOW-1 `Kommentar-traegt-Herkunft-statt-Zustand` · LOW-2 `Praesens-Aussage-gegen-gepinnten-Stand` |
| INFO | 3 | INFO-1 (Gate-Lauf) · INFO-2 (Rename-Messung) · INFO-3 (Grenze der eigenen Prüfung) |

**Wiederkehrende Klassen über Läufe hinweg** — die Zähler sind der Stand **vor** der Closure
dieses Slice und stehen neben dem Kommando, das sie liefert
(`for d in docs/plan/planning/observations/BEO-ALL/*/; do echo "$(ls "$d/evidence" | wc -l) $(basename "$d")"; done | sort -rn`):

| Klasse im Register | Zähler jetzt | Stand | trifft hier |
|---|---|---|---|
| `BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen` | **11** | `geplant` | MEDIUM-2 |
| `BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht` | **5** | `offen` | MEDIUM-3 |
| `BEO-ALL/ausgang-nennt-traeger-der-nicht-traegt` | **1** | `offen` | MEDIUM-4 |

**Ein Vorgang zählt einmal** (Baseline-Regelwerk `modul-06-roadmap.md` §Das Beobachtungs-Register:
*„Zwei Funde **im selben** Vorgang sind dagegen *eine* Gelegenheit, kein zweites Auftreten"*):
slice-177 trägt je Klasse **einen** Beleg, gleich wieviele Funde die zwei Runden geliefert haben.
Die Closure hebt die drei damit auf **12**, **6** und **2**; keine überschreitet mit diesem Slice
eine Schwelle, die sie nicht schon überschritten hatte. Das steht hier ausdrücklich, weil die
naheliegende Lesart *„dritter Fund in drei Runden, also 3×"* genau der Fehler ist, den
`BEO-ALL/sichtungs-schritt-zitiert-falschen-zaehler-stand` (**3**) führt.

**Ohne Kennung, weil neu:** `Fremdes-Rollen-Artefakt-im-Implementations-Kontext` (HIGH-1) tritt
mit Runde 1 und Runde 2 zum zweiten Mal in **einem** Vorgang auf — als Beleg also einmal, als
Signal aber deutlich: nach
[Modul 8](../../.harness/baseline/v6.0.0/regelwerk/modul-08-agentenrollen.md#konflikt-pfad-als-rollen-sequenz-modul-8)
greift die Konflikt-Sequenz bereits ab einem HIGH mit Rollen-Widerspruch, ohne Zähler-Schwelle.
Ob die Klasse einen eigenen Register-Eintrag bekommt, entscheidet die Slice-Closure, nicht dieser
Report.

## Verdikt

**BLOCKIERT.** Zwei HIGH und sechs MEDIUM.

**Was die Nacharbeit erreicht hat, und das ist der größere Teil:** Drei der vier HIGH aus Runde 1
sind sauber und nachmessbar erledigt. Die Ablage steht in der entschiedenen Ziel-Form — 41
Verzeichnisse unter `BEO-ALL/`, keine Nummern-Reste, keine Slug-Kollision, Slug-Mengen vor und
nach dem Move zeichengleich, 166 reine Renames ohne ein Byte Inhaltsänderung. Der
`ignore-refs`-Kommentar beschreibt jetzt die Reichweite, die der Eintrag wirklich hat, und die
sechs Anweisungssatz-Dateien, die er zuvor mitverdeckte, sind nachgezogen — im kontrafaktischen
Lauf liegt **kein** Treffer mehr außerhalb der vier genannten Klassen. Die Planning-README
beschreibt die Verzeichnis-Form. Die zirkuläre Zuweisung zwischen slice-177 und slice-184 ist
durch eine symmetrische, in beiden Plänen stehende Grenze ersetzt. Der Rollen-Übergriff auf die
Skill-Datei ist zurückgenommen und von der Reviewer-Rolle in einem eigenen Ein-Datei-Commit
geschlossen.

**Warum es trotzdem blockiert.** **HIGH-1:** Derselbe Lauf, der den einen Rollen-Übergriff
korrekt zurücknimmt, begeht einen zweiten auf dem Adaptions-Block — mit einer Lesart von §3.8
(*„bindet die inhaltliche Aenderung"*), die im Regeltext nicht steht und der
[`ADR-0034`](../plan/adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
für genau diese Datei ausdrücklich widerspricht. Das ist nicht die Wiederholung einer
Nachlässigkeit, sondern eine Regel-Auslegung, die eine Rolle sich selbst erteilt hat.
**HIGH-2:** Ein `[x]`-DoD-Punkt sagt, ein gemeldetes Reproduzierbarkeits-Risiko sei nicht mehr
reproduzierbar; ich habe es in derselben Sitzung reproduziert, und der als Ursache benannte
Mechanismus (`.gitignore`) wirkt auf den Sensor nachweislich nicht. Ein Folgelauf, der den Plan
liest, hält eine offene Flanke für geschlossen.

**Konflikt-Pfad ([Modul 8](../../.harness/baseline/v6.0.0/regelwerk/modul-08-agentenrollen.md#konflikt-pfad-als-rollen-sequenz-modul-8)):**
HIGH-1 ist ein HIGH mit Rollen-Widerspruch — die Implementation hat ihre Auslegung in der
Commit-Message und in DoD 2 bereits schriftlich vertreten. Der Weg ist damit die Sequenz mit
Übergabe-Artefakten über den Architect, nicht eine Herabstufung; die drei legitimen Verdikte
stehen dort, und keines davon lautet „Finding herabstufen, weil der Implementer widerspricht".
Da die Klasse innerhalb **eines** Slice zum zweiten Mal auftritt, gehört zum Verdikt auch die
Frage, ob der Träger dieser Regel — der Rollen-Wechsel vor der Änderung — hier überhaupt
gegriffen hat.

**Was ausdrücklich nicht beanstandet ist:** die Zerlegungsarbeit. Sie hält auch nach dem zweiten
Umzug jeder Nachmessung stand — 41 Verzeichnisse, 84 Belege, jede Pflichtfeld-Form vollständig,
kein Zähler-Feld, jeder Beleg-Vorgang in `done/` auflösbar, jede `Stand`-Zelle ohne Chronik. Kein
Finding dieser Runde trifft die Zerlegung; alle acht treffen ihre Umgebung.
