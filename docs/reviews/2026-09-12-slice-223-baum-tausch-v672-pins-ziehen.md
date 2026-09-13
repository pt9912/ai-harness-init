# Review slice-223 — Der vendored Baum steht auf `v6.7.2`, die fünf Pins ziehen mit

**Rolle:** Reviewer · **Datum:** 2026-09-12 · **Commits:** `e488119c` · `f603136b` · `30508fc1` · `38174544` (79 Dateien außerhalb von `.harness/baseline/`) · **Plan:** [`slice-223`](../plan/planning/done/slice-223-baum-tausch-v672-pins-ziehen.md) · **Constraints:** [`ADR-0044`](../plan/adr/0044-ziel-fassung-regiert-den-sprung-v672.md) · [`ADR-0031`](../plan/adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) Festlegung 2 · [`ADR-0039`](../plan/adr/0039-eingefrorene-adresse-in-den-vendored-baum.md) · [`ADR-0042`](../plan/adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md) · [`ADR-0028`](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) · **Hard Rules:** [`AGENTS.md`](../../AGENTS.md) §3.4 · §3.5 · §3.7 · §3.8 · §3.11 · **Bezug:** [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) · [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) · [`MR-033`](../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist) · [`MR-040`](../../harness/conventions.md#mr-040--drei-ausgänge-für-eine-präsens-aussage-über-den-vendored-baum)

Alle Zahlen unten stehen neben dem Kommando, das sie liefert, und sind über dem Stand `38174544`
gefahren; sie wandern mit dem Baum und sind **keine Erwartungswerte**.

## Findings

### MEDIUM-1 — Zwei ausführbare Vorlagen-Adressen im Planner-Anweisungssatz sind tot, und kein Slice nimmt sie an

`quelle` [`slice-223`](../plan/planning/done/slice-223-baum-tausch-v672-pins-ziehen.md) §3 (Zeile *„24 Inline-Code-Pfade in lebenden Artefakten | update"*), Baseline-Regelwerk `modul-05-planning-harness.md` §Ziel-Form: Slice (*„Die Adresse muss die Sendung annehmen"*) · `pfad` `.claude/commands/close-welle.md:25`, `.claude/commands/close-welle.md:46` · `verifizierbar` nein durch ein Gate, ja durch `git grep` · `klasse` Ausführbare Adresse im Anweisungssatz stirbt beim Tag-Wechsel ohne Adressaten

`befund` Beide Zeilen weisen den Planner an, die Ergebnisnotiz per `cp` aus
`.harness/baseline/v6.5.0/templates/docs/plan/planning/welle-results.template.md` zu erzeugen. Das
Verzeichnis existiert nicht mehr. Das ist keine Mess-Aussage, sondern eine **Handlungsanweisung**:
Die nächste Welle-Closure fährt `cp` ins Leere, und der dokumentierte Ausweichpfad ist genau der,
den slice-083 mit der `cp`-Pflicht ausgeschlossen hat — eine hand-geschriebene Notiz statt der
Vorlage. Kein Gate sieht es (`codepaths.roots: [spec, docs, harness]` erreicht weder `.harness`
noch `.claude`), und kein lebender Plan nennt den Posten:
[slice-224](../plan/planning/done/slice-224-delta-nachweis-und-planungs-nachzug.md) nimmt die Datei
für die **Kennungs-Notation**, [slice-153](../plan/planning/open/slice-153-wellen-commands-nennen-die-roadmap-abschnitte.md)
für die **Roadmap-Abschnitte**; das Tag-Segment steht in keinem von beiden. Die
Auslassungs-Begründung des Implementer-Commits — *„Inline-Code ohne Markdown-Link, damit für
docs-check unsichtbar — keine Gate-Wirkung durch das Auslassen"* — steht gegen §1 des eigenen
Plans, der für genau diese Klasse sagt: *„gate-unsichtbar; Träger ist dieser Plan, nicht ein
Sensor"*. Die zweite Begründung (fremdes Rollen-Eigentum nach [`ADR-0028`](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md))
trägt; sie verlangt dann aber ein Übergabe-Artefakt, und das fehlt.

```sh
git grep -nE '`[^`]*\.harness/baseline/v6\.5\.0[^`]*`' -- .claude/commands/close-welle.md   # 2
git grep -ln 'baseline/v6\.5\.0' -- docs/plan/planning/open docs/plan/planning/next          # 0 Adressat
```

### MEDIUM-2 — Zehn Präsens-Mess-Aussagen über den vendored Baum haben keinen der drei Ausgänge aus `MR-040`

`quelle` [`MR-040`](../../harness/conventions.md#mr-040--drei-ausgänge-für-eine-präsens-aussage-über-den-vendored-baum) §Adaption · `pfad` `AGENTS.md:232,234,239,382`; `harness/conventions/MR-054-drei-kriterien-fuer-ein-modul-im-emittierten-doc-gate.md:23,31,84`; `harness/conventions/MR-055-eine-stellen-messung-traegt-keine-folgerung-ueber-eine-eigenschaft.md:15,33,35` · `verifizierbar` nein (`MR-040` §Kein Wächter: kein Modul aus `modules:` prüft, was ein Satz neben einem Pfad behauptet) · `klasse` Mess-Aussage über den vendored Baum übersteht den Sprung ohne einen der drei Ausgänge

`befund` `MR-040` ordnet an, dass beim Baum-Wechsel **jede** Präsens-Aussage über ihn in einem
lebenden Artefakt **genau einen** von drei Ausgängen bekommt — *nachgemessen* · *Tree-Operand*
(`git show <ref>:…`, Grund daneben) · *entfallen mit Begründung* — und benennt seinen Träger:
*„Träger ist der Durchgang beim Sprung, nicht ein Gate danach."* Das ist dieser Slice. Zehn
Aussagen haben keinen: Die Adresse blieb auf dem alten Tag, ohne Tree-Operand-Form und ohne den
Grund daneben. Der Plan zitiert `MR-040` in seinem Bezug-Block nicht.

Die Wirkung ist an einer Stelle bereits eingetreten und **still**:

```sh
grep -rn 'Adopter' .harness/baseline/v6.5.0/regelwerk/ | wc -l   # 0, EXIT 0 — der Eintrag nennt 7
git grep -c 'Adopter' e488119c^ -- '.harness/baseline/v6.5.0/regelwerk/' \
  | awk -F: '{s+=$NF} END{print s}'                              # 7 — Tree-Operand, Ausgang 2
```

`MR-054:23` führt **7** neben einem Kommando, das heute `0` bei EXIT 0 liefert; das Fork-Verdikt
des Eintrags ruht auf dieser Zahl. `MR-055:15` sagt *„leer (Exit 1)"* — die Zeile endet heute mit
EXIT 2. Beide Aussagen sind in der Sache unverändert richtig und über `git` vollständig
wiederherstellbar; falsch ist allein die Form, die `MR-040` vorschreibt.

**Einordnung, damit die Schwere stimmt:** Die Klasse ist nicht mit diesem Slice entstanden. Im
lebenden Ausschnitt (ohne ADRs, ohne die vier eingefrorenen Bäume) stehen Adressen in **fünf**
abgelöste Tags, und nur 7 von 55 tragen die Tree-Operand-Form:

```sh
PS=( '*.md' ':!.harness/baseline' ':!docs/reviews' ':!docs/plan/planning/done' \
     ':!docs/plan/carveouts/done' ':!docs/plan/planning/observations' ':!docs/plan/adr' )
git grep -ohE '\.harness/baseline/v[0-9]+\.[0-9]+\.[0-9]+' -- "${PS[@]}" | sort | uniq -c
# 15 v3.5.2 · 39 v5.12.0 · 35 v5.18.0 · 8 v6.0.0 · 12 v6.5.0 · 141 v6.7.2
git grep -hE '\.harness/baseline/v(5\.18\.0|6\.0\.0|6\.5\.0)' -- "${PS[@]}" \
  | grep -cE 'git (show|grep|diff)'                                          # 7 von 55
```

Der Ausgang gehört deshalb in den Steering Loop (Register + Folge-Slice) und nicht in eine
Reparatur-Auflage an diesen Lauf allein.

### LOW-1 — Das Inventur-Instrument des Plans sucht den abgehenden Tag, nicht den Baum

`quelle` [`slice-223`](../plan/planning/done/slice-223-baum-tausch-v672-pins-ziehen.md) §1 · `pfad` `docs/plan/planning/done/slice-223-baum-tausch-v672-pins-ziehen.md:84–86` · `verifizierbar` nein · `klasse` Sprung-Inventur keilt auf den abgehenden Tag statt auf das Baseline-Präfix

`befund` Alle drei Erhebungs-Kommandos des Plans filtern auf `v6\.5\.0`. Adressen, die schon vor
diesem Sprung tot waren, sind für das Instrument unsichtbar — **43** Stück allein auf `v5.18.0` und
`v6.0.0` (Kommando in MEDIUM-2). Zwei davon stehen in `AGENTS.md` selbst und tragen Zahlen:
`AGENTS.md:22` (`cat .harness/baseline/v6.0.0/regelwerk/*.md | wc -c` → **351125**) und
`AGENTS.md:34` (`ls .harness/baseline/v6.0.0/regelwerk/*.md | wc -l` → **26**). Ein Präfix-Filter
auf `\.harness/baseline/v` statt auf den abgehenden Tag hätte sie mitgesehen. Bestand, von diesem
Diff nicht verursacht.

### INFO-1 — `<NNN>` → `<Kennung>` macht den Platzhalter in der Slice-Stub-Vorlage mehrdeutig; die 1:1-Eigenschaft hängt jetzt an `Kuerze`

`quelle` Maintainability · `pfad` `internal/archive/anwenden.go:251`, `.harness/baseline/v6.7.2/templates/docs/plan/planning/archiv-stub-slice.template.md:1,10` · `verifizierbar` nein · `klasse` Platzhalter-Umbenennung macht einen eindeutigen Treffer mehrdeutig

`befund` `<NNN>` stand genau einmal in der Vorlage; `<Kennung>` steht zweimal — in der H1 und im
Zitier-Form-Block, der sich selbst als *„bleibt stehen — Norm"* bezeichnet. `AusVorlage` fährt
`strings.ReplaceAll`, also wäre der Norm-Satz mitbetroffen, **wenn** der Block das Kürzen
überlebte. Er überlebt es nicht: `Kuerze` läuft vor der Ersetzung und behält nur H1,
Archiv-Zeiger-Block und letzten Absatz. Die Eigenschaft *eine Ersetzung, ein Treffer* ruht damit
nicht mehr auf Eindeutigkeit, sondern auf der Reihenfolge zweier Funktionen — latent, heute nicht
auslösbar.

### INFO-2 — Der Kopf-Pin des Reviewer-Skills steht auf `v6.0.0`, sein Rumpf zeigt auf `v6.7.2`

`quelle` [`ADR-0028`](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) · `pfad` `.harness/skills/reviewer.md:4` gegen `:67` · `verifizierbar` nein · `klasse` Anweisungssatz führt zwei Baseline-Stände

`befund` Der Nicht-Bump ist **richtig**, nicht versäumt: `§Ziel-Form: Reviewer-Skill` hat sich über
`v6.5.0 → v6.7.2` real bewegt (Herkunfts-Anker `(seit welle-<NN>)` → `(seit welle-<Kennung>)`), und
ein Kopf-Bump ohne diesen Nachzug wäre eine Behauptung ohne Messung. Die Ziel-Form-Vorlage ist über
denselben Tausch byte-gleich. Der Posten liegt bei
[slice-224](../plan/planning/done/slice-224-delta-nachweis-und-planungs-nachzug.md), das den
Kennungs-Notations-Nachzug und diese Datei ausdrücklich führt.

### INFO-3 — Der Reviewer-Anweisungssatz liegt im Prüfgegenstand des Reviewers

`quelle` Baseline-Regelwerk `modul-08-agentenrollen.md` §Kernidee · `pfad` `30508fc1` · `verifizierbar` nein · `klasse` Rollen-eigener Anweisungssatz wird zum Liefergegenstand derselben Rolle

`befund` `.harness/skills/reviewer.md` gehört nach `ADR-0028` der ausführenden Rolle; jede Änderung
daran landet damit im Diff, den genau diese Rolle danach prüft. Für **diesen** Lauf trägt die
Trennung (frischer Kontext, ich habe `30508fc1` nicht geschrieben, und seine Messung ist unten
unabhängig nachgefahren). Strukturell bleibt: Eine Änderung, die die HIGH-Liste abschwächte, hätte
keinen fremden Prüfer. Kein Befund am Diff, eine benannte Eigenschaft der Zuordnung.

## Negativbefunde

- **Punkt 1 — fünf Pins** — ohne Befund: `BASELINE_TAG`/`BASELINE_ZIP_SHA256` (`Makefile:25,34`), `sources`-`url`/`sha256` (`.d-check.yml:383,384`) und `DefaultTag`/`DefaultBaselineSHA256` (`internal/fetch/baseline.go:48,54`) tragen alle `v6.7.2` und denselben sha256 `ff1f7a58…`.
- **Punkt 1 — fail-closed, rot gesehen** — ohne Befund: `.d-check.yml` auf `v6.7.1`/Null-Hash gesetzt → `make test-bats` `not ok 249` *und* `not ok 250` (`test/sources-pin.bats:22,28`); `internal/fetch/baseline.go` ebenso → `make test-go` `--- FAIL: TestDefaultBaselineSHA256_MatchesMakefile` *und* `--- FAIL: TestDefaultTag_MatchesBaseline`, beide Meldungen lesen den **Makefile**-Wert zur Laufzeit (`"v6.7.1" != … "v6.7.2" (Drift bei Re-Baseline)`), koppeln also an die kanonische Quelle und nicht an ein zweites Literal. Beide Mutationen zurückgesetzt, `git status --porcelain` leer.
- **Provenienz Pin → Asset** — ohne Befund: `make regelwerk-check` (Netz, kein Gate) → `1210 Datei(en) geprüft, 0 Befund(e)`, EXIT 0. Der gepinnte sha256 ist damit **am realen Release-Asset** von `v6.7.2` geprüft und nicht aus einer Erwartung übernommen. Der in `ADR-0043` genannte Wert `5d3dba9c…` (v6.7.1) ist nachweislich **nicht** verwendet; `ADR-0044` führt keinen sha256.
- **Provenienz Asset → vendored Baum** (die von `harness/conventions.md` §Adoptierte Konventions-Quellen als unbewacht benannte Hälfte) — ohne Befund, hier **geschlossen**: gegen den lokalen Kurs-Klon `v6.7.2` (`54d344b`, *Welle 134*) differieren **28** Dateien in **58** Zeilen — exakt die Zahlen, die `ADR-0044` §Kontext für denselben Vorgang nennt —, und **jede** Differenz ist die Quell-URL-Umschreibung des Release-Packagings (`../../kurs/de/…` → `https://…/blob/v6.7.2/…`, `releases/latest/download` → `releases/download/v6.7.2/`). Alle **29** umgeschriebenen URLs tragen `v6.7.2`; Dateizahl 54 = 54; die `Stand:`-Zeile ist auf beiden Seiten identisch. Kein inhaltliches Delta.
- **`make baseline-verify`** — ohne Befund: `baseline-verify: v6.7.2 OK — 54 Dateien (Integritaet + Vollstaendigkeit, netzlos)`, EXIT 0. Die im Plan (DoD 1) benannte Lücke ist real: `harness/tools/baseline-verify.sh:50` **entdeckt** den Tag aus dem Verzeichnis und liest `BASELINE_TAG` nie — Baum ↔ Pin bleibt ungekoppelt, wie angesagt.
- **Punkt 3 — `internal/archive/anwenden.go`** — ohne Befund, **die 1:1-Aussage trägt**: Kürzung und Ersetzung über der alten Vorlage (`<NNN>`) und der neuen (`<Kennung>`) nachgebaut und gegeneinander gehalten → `diff` leer, EXIT 0. Erzwungen ist der Nachzug ohnehin: `test/archiv-stub-vorlagen.bats:123` hält jeden Code-Platzhalter gegen genau die Vorlage, die sein Block füllt, entdeckt das Vorlagen-Verzeichnis per Glob (`*/templates/…`, keine zweite Tag-Quelle) und wäre bei stehengebliebenem `<NNN>` rot geworden. `welleStub` führt kein `<Kennung>`; die fünf berührten `test/mutations/*.sh` sind reine Pfad-Umschreibungen.
- **Punkt 5 — eingefrorene Bäume** — ohne Befund: `git diff --name-only e488119c^..38174544` liefert **0** Treffer unter `docs/reviews/`, `docs/plan/planning/done/`, `docs/plan/carveouts/done/`, `docs/plan/planning/observations/`, `docs/plan/adr/`, `harness/conventions/done/`; `--name-status --find-renames` zeigt außerhalb von `.harness/baseline/` **keine** Umbenennung und **keine** Löschung.
- **Punkt 5 — tote Adressen in eingefrorenen Bäumen** — ohne Befund: Repo-weit bleibt **ein** Markdown-Link in den `v6.5.0`-Baum (`docs/plan/planning/observations/BEO-ALL/beleg-nach-dem-ausgang-findet-keinen-leser/observation.md:7`), und er liegt im Ventil aus `ADR-0039` Festlegung 1 (`in: docs/plan/planning/observations/**`, `refs: .harness/baseline/**`). `docs/plan/carveouts/done/` trägt **0** Markdown-Links in den Baum und braucht das dort fehlende Ventil nicht. Die `# Deckung:`-Zahlen 33/3/2 sind unberührt, weil kein eingefrorener Baum angefasst wurde.
- **Kein neues Referenz-Ventil** — ohne Befund: `grep -c '^  - in: ' .d-check.yml` → **7**, unverändert über alle vier Commits; keine `§3.5`-Senkung.
- **Punkt 2 — die Trennung selbst** — ohne Befund für die **Klassifikation**: von den **12** verbleibenden Inline-Pfaden im lebenden Ausschnitt sind **10** echte Mess-Aussagen (Kommando + zitiertes Ergebnis, Tag nach `MR-033` benannt) und **2** echte Adressen (MEDIUM-1). Keine Mess-Aussage ist in Wahrheit ein Navigations-Zeiger, und keine Adresse ist als Messung fehlklassifiziert. Der Architect hat die 104 Markdown-Links in 50 `MR-*`-Dateien vollständig gezogen (`git grep -oE '\]\([^)]*\.harness/baseline/v6\.5\.0[^)]*\)' 38174544^ -- harness/conventions.md harness/conventions/ | wc -l` → 104, heute 0) und daneben 9 Präsens-Aussagen nachgemessen; von 123 Vorkommen stehen **10**.
- **`ADR-0031` Festlegung 2** — ohne Befund: Die Buchung trägt Ziel-Tag, Datum und den Slice mit dem Delta-Nachweis; `slice-224` steht in **beiden** offenen Nachweis-Feldern, und `ADR-0044` §Konsequenzen sowie `slice-224` §1 decken genau diese Doppel-Zuweisung. Kein Konformitäts-Urteil, keine Ausgangs-Liste, keine Begründung der Setzung — kein vierter Teil. Der Zusatz *„ausstehend"* ist Zustand, nicht Chronik (`AGENTS.md` §3.7).
- **`AGENTS.md` §3.8 — Commit-Zuschnitt** — ohne Befund: `38174544` berührt **0** Dateien außerhalb von `AGENTS.md`/`harness/conventions*`/`docs/plan/adr/` und nennt die Rolle in der Message; `e488119c` und `f603136b` berühren **kein** Architect- oder Reviewer-Artefakt; `30508fc1` berührt genau eine Datei. Alle vier Messages tragen mindestens eine `LH-`/`ADR-`/`MR-`-Kennung (2 · 1 · 1 · 10).
- **`30508fc1` — die Messung unabhängig nachgefahren** — ohne Befund: `§Template-Schichtung` in `grundlagen-harness-dateien.md` ist über `v6.5.0 → v6.7.2` byte-gleich (`diff` leer, EXIT 0); der HIGH-Eintrag *„Norm nur im Template-Kommentar"* hängt unverändert an ihr. Die Adress-Berichtigung ändert keine Aussage.
- **Symlinks im Auto-Kontext** — ohne Befund: `find . -xtype l` liefert **0** kaputte Links; alle **5** Baseline-Symlinks unter `.claude/rules/` zeigen auf `v6.7.2`.
- **Doku-Gate über dem Ergebnis-Stand** — ohne Befund: `make docs-check` → `1210 Datei(en) geprüft, 0 Befund(e)`; `git grep` nach Markdown-Links in den `v6.5.0`-Baum im lebenden Ausschnitt → **0**, Dateien → **0**.
- **Go-Fixturen mit `v6.5.0`** — **REFUTED** als Befund: `internal/archive/scan_test.go:13` und die 17 Zeilen in `cmd/ai-harness-init/vendor_baseline_test.go` sind tag-agnostisch — `archive.Ausgenommen` vergleicht gegen das Präfix `.harness/baseline`, und die Kommando-Tests bauen ihre Tag-Verzeichnisse in einem tmp-Root. Ein Nachzug änderte am Prüfgegenstand nichts.
- **Arbeitsbaum nach dem Review** — ohne Befund: `git status --porcelain` leer; beide Mutations-Proben aus Punkt 1 zurückgesetzt, der Gate-Stempel über `38174544` bleibt gültig.

## Was ich nicht geprüft habe

- **Die DoD-Abhakung** — Verifier-Rolle, anderes Prüf-Artefakt. Ein Posten gehört dorthin und ist hier nur als Zahl notiert: DoD 3 sagt *„0 Treffer"* für die drei §1-Kommandos; gemessen sind **0 · 0 · 12**.
- **`make gates`** — fährt der Auftraggeber; Stempel liegt über `38174544`.
- **`make mutate`, `make smoke`, `make full-smoke`** — nicht gefahren. Die fünf berührten Mutations-Fälle sind gelesen, nicht ausgeführt.
- **Das inhaltliche Delta von `v6.7.2`** — welche Regel welches Artefakt trifft, ist ausdrücklich Gegenstand von [slice-224](../plan/planning/done/slice-224-delta-nachweis-und-planungs-nachzug.md) und [slice-225](../plan/planning/in-progress/slice-225-gate-index-steht-einmal.md). Geprüft ist hier nur, **dass** der Baum dem Kurs-Tag entspricht, nicht, **was** er sagt.
- **Die emittierte Inhalts-Ebene** (`internal/emit/templates/`) — eigener Prüfbereich, eigener Beleg (`make full-smoke`).
- **Die Prozedur, mit der der Baum entstand** — ob `make vendor-baseline` gefahren wurde, ist an git nicht ablesbar. Geprüft ist das **Ergebnis** (identisch zum Kurs-Tag, Pin am Asset verifiziert).
- **Kontext-Trennung zwischen den vier Läufen** — aus `git` nicht beobachtbar; die Rollen-Labels und der Commit-Zuschnitt sind es, und beide stimmen.

## Kategorie-Summary

0 HIGH · 2 MEDIUM · 1 LOW · 3 INFO. Wiederkehrende Klasse: **eine Aussage oder Anweisung über den
vendored Baum überlebt den Tag-Wechsel in einer Form, die kein Gate sieht** — MEDIUM-1 (Anweisung),
MEDIUM-2 (Messung) und LOW-1 (das Instrument, das beide finden sollte) sind drei Träger derselben
Klasse. Kandidaten im Beobachtungs-Register: `gate-modul-erreicht-den-vendored-baum-nicht` (2×),
`baseline-aussage-ohne-mess-tag` (2×), `verweis-nachzug-bricht-tree-operand` (1×).

## Verdikt

**Nicht blockierend — der Gegenstand des Slice trägt.** Baum und Pins sind in beide Richtungen
belegt: der sha256 am realen Release-Asset (`regelwerk-check`, EXIT 0), der Baum gegen den Kurs-Tag
(28/58, ausschließlich Packaging-URLs), die vier nicht-kanonischen Pins fail-closed **rot gesehen**.
Die eingefrorenen Bäume sind unberührt, die Ventil-Breiten unverändert, der Commit-Zuschnitt je
Rolle sauber, und die 1:1-Aussage zum Vorlagen-Nachzug ist gemessen, nicht geglaubt.

**Abweichung vom Regelfall, begründet** (`.harness/skills/reviewer.md` §Ablage: HIGH und MEDIUM
blockieren typischerweise): Beide MEDIUM betreffen **Rest-Adressen**, nicht den Liefergegenstand.
MEDIUM-1 ist zwei Zeilen in einem Planner-Anweisungssatz und braucht entweder einen Planner-Commit
oder eine Adresse; MEDIUM-2 ist eine repo-weite Klasse mit 43 älteren Fällen, die eine
Reparatur-Auflage an diesen Lauf nicht schlösse und die in den Steering Loop gehört. Der Slice
sollte nicht daran hängen bleiben.

**Zwei Auflagen an den Planner, vor der Closure:**

1. MEDIUM-1 bekommt einen Ausgang — Planner-Commit in diesem Slice oder eine benannte Slice-ID, die
   die Sendung annimmt. „Gate-unsichtbar" ist keiner.
2. MEDIUM-2 und LOW-1 gehen als Beleg ins Beobachtungs-Register; `MR-040` hat seinen Träger beim
   Sprung nicht gefunden, und das ist eine Trägerschafts-Lücke, kein Einzelfall.
