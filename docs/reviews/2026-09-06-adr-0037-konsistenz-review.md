# Review: ADR-0037 — Konsistenz-Review, Runde 1

**Review-Art:** Plan-Review gegen Spec/ADR (Modul 10 §Drei Review-Arten) — geprüft wird die
Entscheidung gegen ihre zitierten Quellen, **nicht** DoD-Konformität (Verifier-Rolle, getrennter
Kontext).

**Gegenstand:** [`docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md`](../plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md)
Status `Proposed`, Commit `dab5028` (Diff `dab5028^..dab5028` = zwei Dateien, die ADR und der
ADR-Index).

**Skill:** `.harness/skills/reviewer.md` @ 1.7.0 · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-5[1m] · **Datum:** 2026-09-06

**Reviewer:** frischer Kontext. Keines der geprüften Artefakte selbst geschrieben, an keinem etwas
geändert. **Jede Zahl und jedes Kommando dieses Reports ist in diesem Lauf selbst gefahren**;
nichts ist aus der Commit-Message, aus dem Slice-Plan oder aus der ADR übernommen.

---

## Eingangs-Kontext (fünf Pflicht-Punkte + Plan)

- **Diff-Range:** `dab5028` gegen `dab5028^` = `ee69247`. `dab5028` ist zugleich `HEAD`, der
  Arbeitsbaum trägt beim Abschluss dieses Laufs drei fremde, nicht committete Änderungen aus der
  slice-123-Nacharbeit (`harness/README.md`, `harness/tools/history-range-guard.sh`,
  `test/history-range-guard.bats`) — von diesem Report **nicht** angefasst und **nicht**
  mitcommittet. Kein Commit liegt zwischen
  Gegenstand und Prüfung.
- **`LH-*`:** [`LH-FA-01`](../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen),
  [`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) (Rang 1, der
  ausgelegte Satz), [`LH-FA-03`](../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7),
  [`LH-FA-09`](../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren),
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6).
- **Referenzierte aktive ADRs**, Status in diesem Lauf gemessen
  (`for f in 0005 0006 0007 0016 0034; do grep -m1 '^\*\*Status:\*\*' docs/plan/adr/$f-*.md; done`):
  ADR-0005 `Accepted`, ADR-0006 `Accepted`, ADR-0007 `Accepted`, ADR-0016 `Accepted`,
  ADR-0034 `Accepted`. Keine `Superseded`/`Deprecated` unter den zitierten.
- **Hard Rules:** [`AGENTS.md`](../../AGENTS.md) §3, insbesondere §3.4 (ADR ab `Accepted`
  immutabel — die Kosten-Asymmetrie, die diesen Report trägt), §3.5, §3.6, §3.8 (Architect-
  Commit-Zuschnitt), §3.9 (Docker-only), §3.11 (Eigenschaft statt Aufzählung). Dazu
  [`MR-000`](../../harness/conventions.md#mr-000--baseline-aussage),
  [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert),
  [`MR-033`](../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
  und [`MR-051`](../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung).
- **Vorherige Findings am gleichen Modul:** **keine** — `ls docs/reviews/ | grep -iE '0037|slice-190|slice-191'`
  ist leer. Dies ist Runde 1. Als Muster herangezogen: die drei ADR-0036-Runden, zuletzt
  [Runde 3](2026-09-05-adr-0036-konsistenz-bestaetigung-runde-3.md).
- **Slice-Plan:** [`slice-190`](../plan/planning/in-progress/slice-190-bootstrap-legt-die-versprochenen-orte-an.md)
  (in `open/`) — das Übergabe-Artefakt, dessen zwei Fragen die ADR beantwortet.

**Gate-Lauf.** `make docs-check` in diesem Lauf **zweimal** gefahren (Docker-only, §3.9) — vor dem
Schreiben dieses Reports `d-check: 838 Datei(en) geprüft, 0 Befund(e)`, danach
`d-check: 840 Datei(en) geprüft, 0 Befund(e)`, EXIT 0. Jeder Link und jeder Anker der ADR, der
Index-Zeile und dieses Reports löst auf.

**`make gates` steht in diesem Lauf auf EXIT 2, und der Bruch liegt außerhalb dieses
Gegenstands.** `shell-lint` meldet zwei `SC2016` in `test/mutations/266-history-range-guard-decide-ganzzahl-wache-entfernt.sh`
und `test/mutations/267-history-range-guard-decide-staged-ganzzahl-wache-entfernt.sh`. Beide Dateien sind **untrackt** und stammen aus
der gleichzeitig laufenden slice-123-Arbeit (`git status --porcelain -- test/mutations/` → drei
`??`-Zeilen); dieser Report hat keine Shell-Datei angefasst und keine davon mitcommittet. Über den
**Gegenstand** dieses Reports sagt das Rot nichts — die ADR und der ADR-Index liegen in keinem
Prüfbereich von `shell-lint`. Über den **Baum** sagt es, dass er gerade nicht ruht; das ist hier
benannt statt weggelassen.

---

## Findings

Jedes Finding folgt dem §Output-Schema des Reviewer-Skills.

### M-1 — Der Grund, aus dem die derivativen Indexe an der neuen Eigenschaft scheitern sollen, hält am heutigen Emit-Pfad nicht

- `kategorie`: **MEDIUM** (blockierend)
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 (die zitierte rote Messung deckt den Satz nicht
  mehr) · Maintainability
- `pfad`: `docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md:261–263` (Festlegung 4,
  erster Spiegelstrich) und `:285` (Alternative E, Pro-Zelle)
- `befund`: Die ADR schreibt *„Die **derivativen Index-Sichten** (ADR-Index, Carveout-Index)
  bleiben *Fülle-wenn-Inhalt-da* — sie scheitern an Bedingung (c) der Festlegung 1, und genau
  daran hat sie der Voll-Smoke einmal gemessen."* Bedingung (c) lautet *„sein Anlegen keinen
  Platzhalter-Link erzeugt, der das Doku-Gate des Ziels rot färbt"* — sie ist an der **Wirkung**
  formuliert, nicht am Vorlagen-Text. Der Emit-Pfad neutralisiert seit `f979b59` (2026-08-29,
  slice-133) jeden Markdown-Link, dessen Ziel-**Pfad** einen `<…>`-Platzhalter trägt, **vor** dem
  Schreiben (`NeutralizePlaceholderLinks`, aufgerufen in `planTemplates` für jedes Singleton).
  Beide Index-Vorlagen tragen genau **einen** solchen Link und sonst keinen —
  `[<NNNN>](<NNNN>-<titel>.md)` bzw. `[CO-<NNN>](CO-<NNN>-<titel>.md)`. Der Voll-Smoke, den die
  Zelle als Messung anführt, stammt aus `f4922de` (2026-07-22) und liegt damit **fünf Wochen vor**
  dem Mechanismus, der genau diesen Defekt entfernt. Zweite Achse desselben Satzes: Festlegung 1
  bindet ausdrücklich *„Ein **Ort**"*, und ihre Bedingung (b) begründet sich mit *„weil `git` ein
  leeres Verzeichnis nicht führt"*. ADR-Index und Carveout-Index sind **Dateien** in Verzeichnissen,
  die der Bootstrap ohnehin per `.gitkeep` anlegt; die Bedingung, an der sie tatsächlich scheitern,
  ist damit (a) bzw. die Subjekt-Grenze der Eigenschaft — nicht (c).
- **Failure-Szenario:** Das Ergebnis (die Indexe bleiben draußen) stimmt, der genannte Grund nicht.
  Ab `Accepted` sperrt [`AGENTS.md`](../../AGENTS.md) §3.4 den Satz. Der nächste Lauf, der die
  Eigenschaft nach Konsequenz 2 (*„der nächste Ort derselben Klasse braucht keine eigene Runde,
  sondern nur die drei Bedingungen"*) auf einen neuen Fall anwendet, prüft (c) gegen einen
  Emit-Pfad, der Platzhalter-Links längst tilgt — und bekommt für jeden Vorlagen-Fall ein „(c)
  erfüllt". Damit fällt genau die Enge weg, die Alternative E in ihrer Pro-Zelle zusagt (*„sie
  bleibt eng, weil … die zwei bekannten Gegenbeispiele … an ihr scheitern statt ausgenommen zu
  werden"*).
- `verifizierbar`: **nein** — kein Gate liest, welche Bedingung ein ADR-Satz einer anderen Datei
  zuschreibt. Reproduzierbar:
  ```sh
  git log --oneline --reverse -S'func NeutralizePlaceholderLinks' -- internal/emit/templates.go
  # -> f979b59 slice-133: Platzhalter-Links neutralisieren …
  git log -1 --format=%ad --date=short f979b59            # 2026-08-29
  git log -1 --format=%ad --date=short f4922de            # 2026-07-22  (slice-024 Voll-E2E-Smoke)
  grep -c 'NeutralizePlaceholderLinks(body)' internal/emit/templates.go                       # 1
  grep -cE '\]\(<?(NNNN|CO-<NNN>)' .harness/baseline/v6.0.0/templates/docs/plan/adr/README.template.md \
        .harness/baseline/v6.0.0/templates/docs/plan/carveouts/README.template.md
  # -> je 1 Platzhalter-Link, und es ist der einzige Markdown-Link der jeweiligen Vorlage
  grep -c '\.gitkeep' internal/emit/templates.go          # die Struktur-Liste, die docs/plan/adr/ ohnehin anlegt
  ```
- `klasse`: *Ausschluss-Grund benennt eine Bedingung, die der heutige Code nicht mehr erzeugt*

### M-2 — Die Antwort auf Frage 2 ist eine Behauptung ohne die Prüfung, die dieselbe Festlegung vom umsetzenden Lauf verlangt

- `kategorie`: **MEDIUM** (blockierend)
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 · [`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)
- `pfad`: `docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md:237–238` (Festlegung 1,
  letzter Satz)
- `befund`: Der Satz lautet *„**`harness/conventions/` erfüllt die drei** und ist damit gedeckt."*
  Er ist die **vollständige** Antwort auf die zweite der zwei Fragen, die der Commit für sich
  reklamiert, und er nennt für keine der drei Bedingungen eine Fundstelle. Für Bedingung (a) —
  *„das mitemittierte Regelwerk oder ein mitemittierter Text ihn für ein frisches Repo im
  Indikativ als vorhanden führt"* — steht in der ganzen Datei kein Kommando und kein Zitat; der
  §Kontext-Abschnitt darüber begründet nur, dass die Aufzählung nicht geschlossen ist, nicht, dass
  die drei Bedingungen zutreffen. Dieselbe Festlegung verlangt in Folgepflicht 1 vom umsetzenden
  Lauf genau das Gegenteil dieser Form: *„die drei Bedingungen aus Festlegung 1 je Ort **einzeln**
  im Slice-Plan oder Commit benennen — nicht pauschal."* **Die Aussage ist inhaltlich richtig** —
  in diesem Lauf nachgemessen, siehe Negativbefunde —, aber sie steht ohne den Beleg, den ihr
  eigenes Kriterium fordert, und ab `Accepted` ist sie nicht mehr nachzutragen.
- **Failure-Szenario:** Ein späterer Lauf, der `harness/conventions/` gegen die drei Bedingungen
  hält, findet in der ADR keine Fundstelle für (a) und muss die Prüfung neu führen — genau die
  Runde, die Konsequenz 2 zu sparen verspricht. Fällt seine Messung anders aus, steht Aussage
  gegen Aussage, und die ADR-Seite ist eingefroren.
- `verifizierbar`: **nein**. Reproduzierbar:
  ```sh
  grep -n 'erfüllt die drei' docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md   # 237
  grep -c 'grundlagen-harness-dateien' docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md   # 0
  grep -c 'Verzeichniskonvention' docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md        # 0
  # die Fundstelle, die (a) trägt und die die ADR nicht nennt:
  grep -n '^harness/conventions/' .harness/baseline/v6.0.0/regelwerk/grundlagen-harness-dateien.md
  # -> 22: harness/conventions/        # ein MR je Datei; done/ = aufgelöst
  ```
- `klasse`: *Schluss ohne die Messung, die derselbe Text von anderen verlangt*

### M-3 — „Die zwei Struktur-Aufzählungen" ist ein Gegenstand, den die Datei nicht bestimmt

- `kategorie`: **MEDIUM** (blockierend)
- `quelle`: Maintainability · [`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)
  (Rang 1 — der ausgelegte Text)
- `pfad`: `docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md:221–223` (Festlegung 1,
  Kopfsatz), `:151` (Abschnittsüberschrift) und `:1` (Titel)
- `befund`: Festlegung 1 setzt *„Die zwei Struktur-Aufzählungen in `LH-FA-02` sind beispielhaft,
  nicht abschließend"*, und die Überschrift darüber heißt *„Die zwei Aufzählungen in `LH-FA-02` —
  was sie zählen und was nicht"*. **Welche zwei**, sagt die Datei an keiner Stelle. Der
  §Kontext-Abschnitt zitiert genau **eine** (*„Der tragende Satz lautet: …"* — die
  `.gitkeep`-Klammer) und führt seine drei Messungen ausschließlich gegen sie.
  [`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) trägt in diesem
  Lauf gemessen **vier** Klassen-Aufzählungen in Klammern, und eine davon — die derivativen
  Index-Sichten — erklärt Festlegung 4 gerade **nicht** für beispielhaft. Der Umfang der Setzung
  ist damit nicht aus der Datei bestimmbar.
- **Failure-Szenario:** Ein späterer Ort, der unter die Wiederkehrenden oder unter die Singletons
  fällt, lässt sich nicht entscheiden: fällt er unter eine der „zwei", gilt Festlegung 1; fällt er
  unter die derivativen Indexe, gilt Festlegung 4. Ab `Accepted` ist die Klärung eine Folge-ADR.
- `verifizierbar`: **nein**. Reproduzierbar:
  ```sh
  sed -n '/^### LH-FA-02/,/^### LH-FA-03/p' spec/lastenheft.md | tr '\n' ' ' \
    | grep -oE '\([^()]*\)' | grep -cE 'authored-once|ADR ·|Carveout-Index|Lifecycle-'   # 4
  grep -c 'Der tragende Satz lautet' docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md   # 1
  ```
- `klasse`: *Normsatz nennt eine Menge, die sein eigener Text nicht identifiziert*

### M-4 — Die Geschichte-Zeile beschreibt den Anlass mit einer Zahl und einer Eigenschaft, die der Slice-Plan nicht trägt

- `kategorie`: **MEDIUM** (blockierend)
- `quelle`: Maintainability · [`AGENTS.md`](../../AGENTS.md) §3.10 (die ADR ist das
  Übergabe-Artefakt, aus dem der Planner beim `open → next`-Schritt schöpft — so sagt es ihre
  eigene Folgepflicht 3)
- `pfad`: `docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md:360` (§Geschichte)
- `befund`: Die Zeile lautet *„Architect-Lauf zu den zwei offenen Risiken aus `slice-190` §6, die
  dessen `open → next`-Trigger sperren."* Gemessen trägt
  [`slice-190`](../plan/planning/in-progress/slice-190-bootstrap-legt-die-versprochenen-orte-an.md) §6
  **sechs** Risiken mit `**Ausgang:** <offen>`, und §4 nennt für `open → next` **eine** Bedingung
  neben dem WIP-Limit — *„die Change-Request-Frage aus §3 ist beantwortet"*. Das zweite von der ADR
  behandelte Risiko (der Register-Ort) sagt in seinem eigenen Text *„Der Ausgang ist eine
  **Entscheidung des Architect**, kein Code-Zug"*, ohne den Trigger zu binden. Beide Bestandteile
  des Satzes — die Zahl **zwei** und die Eigenschaft *sperrt den Trigger* — sind damit am Plan
  nicht belegt.
- **Failure-Szenario:** Der Planner, den Folgepflicht 3 auf diese Datei verweist, liest sie als
  Aussage darüber, welche Risiken §6 noch ohne Ausgang lässt, und schließt den Slice mit vier
  Risiken ohne Ausgang ab — was Modul 5 §Offene Risiken ausdrücklich verbietet.
- `verifizierbar`: **nein**. Reproduzierbar:
  ```sh
  sed -n '/^## 6\. Risiken/,/^## 7\./p' \
    docs/plan/planning/in-progress/slice-190-bootstrap-legt-die-versprochenen-orte-an.md \
    | grep -c '\*\*Ausgang:\*\* <offen>'                     # 6
  sed -n '/^## 4\. Trigger/,/^## 5\./p' \
    docs/plan/planning/in-progress/slice-190-bootstrap-legt-die-versprochenen-orte-an.md \
    | grep -A1 '^\*\*`open` → `next`'
  # -> "WIP-Limit frei und die Change-Request-Frage aus §3 ist beantwortet."
  ```
- `klasse`: *Aussage über den Stand eines fremden Artefakts ohne Messung an ihm*

### M-5 — Zwei Messwert-Zahlen stehen ohne das Kommando, das sie liefert; eine davon ist ein Register-Zähler

- `kategorie`: **MEDIUM** (blockierend)
- `quelle`: [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 1 und 2 · [`MR-051`](../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
  Setzung 2 (Cutoff 2026-09-05; diese Datei trägt das Datum 2026-09-06)
- `pfad`: `docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md:158` und `:360`
- `befund`: **Fundmenge, nicht Fundort — zwei Stellen.** (1) `:158` — *„«Lifecycle-Ordner» ist
  eine Klassen-Bezeichnung ohne Namen — sie deckt heute **drei** Verzeichnisse"*, als erste der
  *„drei Messungen"* geführt, ohne Kommando. Die Zahl ist zudem zweideutig: die Lifecycle-Ebenen,
  die dieselbe Baseline führt, sind **vier** (`open`, `next`, `in-progress`, `done`); **drei** ist
  die Zahl der Lifecycle-Einträge in `structureGitkeeps()`, weil `in-progress/` die Roadmap trägt.
  (2) `:360` — *„der **dritte** Eintritt der Klasse `BEO-ALL/emittierte-vorlagen-klassifikation-ohne-traeger`"*.
  Der Zähler dieses Registers ist **abgeleitet**, und er steht in diesem Lauf bei **2**; die
  Zeile nennt weder das ableitende Kommando noch kennzeichnet sie den Wert als keinen
  Erwartungswert, obwohl
  [`MR-051`](../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
  Setzung 2 beides für jede Zitierung außerhalb des Registers verlangt. Der Slice-Plan §8 macht es
  an derselben Klasse vor (Kommando plus *„Keine Erwartungswerte"*).
- **Failure-Szenario:** Ein Leser schlägt den Zähler nach, findet **2**, und kann nicht
  entscheiden, ob die ADR einen Beleg unterschlägt, ob das Register unvollständig ist oder ob der
  dritte Beleg noch aussteht — die Antwort (er entsteht erst mit der Closure von `slice-190`)
  steht nirgends. Bei `:158` zählt derselbe Leser die Lifecycle-Ordner nach und findet vier.
- `verifizierbar`: **nein** — kein Modul der [`.d-check.yml`](../../.d-check.yml)
  (`links, anchors, ids, matrix, codepaths, spans`) liest Zahlen, und `make comment-claims` hat
  keine Markdown-Datei im Prüfbereich. Reproduzierbar:
  ```sh
  ls docs/plan/planning/observations/BEO-ALL/emittierte-vorlagen-klassifikation-ohne-traeger/evidence/*.md | wc -l   # 2
  sed -n '/^func structureGitkeeps/,/^}/p' internal/emit/templates.go | grep -c 'planning/'                          # 3
  grep -oE '^docs/plan/planning/(open|next|in-progress|done)/' \
    .harness/baseline/v6.0.0/regelwerk/grundlagen-harness-dateien.md | sort -u | wc -l                               # 4
  ```
- `klasse`: *Zahl neben nie gefahrenem Kommando* (bestehende Register-Klasse
  `BEO-ALL/zahl-neben-nie-gefahrenem-kommando`), Unterfall *Register-Zähler außerhalb des
  Registers zitiert*

### L-1 — Festlegung 3 begründet die Idempotenz-Klasse positiv aus einem Umgang, den der Baum nicht zeigt

- `kategorie`: LOW
- `quelle`: [ADR-0007](../plan/adr/0007-bootstrap-phasen.md) Entscheidung 3 · Maintainability
- `pfad`: `docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md:252–255`
- `befund`: Die Festlegung schreibt *„Sie ist Adopter-Boden: er schreibt sie fort, sobald sein
  Register lebt — dieses Repo hat es getan. Die Klasse folgt damit nicht aus dem Zweifels-Default,
  sondern positiv aus dem beobachteten Umgang mit derselben Datei."* Gemessen hat
  `docs/plan/planning/observations/README.md` **zwei** Commits, beide aus `slice-177`, dem Slice,
  der sie anlegte; nach ihm keinen. Und die Datei kann per Konstruktion nicht mit dem Register
  wachsen: [ADR-0034](../plan/adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
  Festlegung 1 verbietet den Index, und dieselbe ADR-0037 stellt weiter oben in §Kontext fest, die Datei
  *„listet keine Beobachtung"*. Der Ausgang (skip-if-present) ist richtig; die
  [ADR-0007](../plan/adr/0007-bootstrap-phasen.md)-Regel *„im Zweifel gilt `skip-if-present`"*
  trägt ihn — nur wird sie hier ausdrücklich als Grund abgelehnt.
- `verifizierbar`: **nein**. Reproduzierbar:
  ```sh
  git log --oneline --follow -- docs/plan/planning/observations/README.md   # 2 Zeilen, beide slice-177
  grep -c 'listet keine Beobachtung' docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md   # 1
  ```
- `klasse`: *Bestand als Norm* — eine Klassen-Zuweisung wird aus beobachtetem Umgang statt aus der
  Regel abgeleitet

### L-2 — Zwei Sätze der Datei sagen Verschiedenes darüber, wer die Handbuch-Zeile 1.13 nachzieht

- `kategorie`: LOW
- `quelle`: Maintainability
- `pfad`: `docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md:136–138` (§Kontext) gegen
  `:307–310` (§Konsequenzen)
- `befund`: §Kontext sagt über die Änderungshistorie-Zeile 1.13 *„ihre Korrektur ist Sache des
  Slice, der den Bestandsbaum des Handbuchs schreibt (`slice-191`)"*. §Konsequenzen sagt über
  dieselbe Zeile *„Ein Historie-Eintrag beschreibt einen vergangenen Stand und wird nicht
  rückwirkend umgeschrieben; was das Handbuch **im Präsens** über den Bestand sagt, zieht der Slice
  nach."* Die erste Stelle weist die Korrektur **dieser** Zeile zu, die zweite nimmt sie
  ausdrücklich aus und verlegt den Nachzug auf andere Stellen.
- `verifizierbar`: **nein**. Reproduzierbar:
  ```sh
  sed -n '136,138p;307,310p' docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md
  ```
- `klasse`: *Zwei Sätze desselben Artefakts weisen dieselbe Folgepflicht verschieden zu*

### L-3 — Eine Regelwerks-Aussage trägt keinen Beleg in der Form, die der Accept-Übergang verlangt

- `kategorie`: LOW
- `quelle`: [ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 2 und
  Träger (a) (*„Bevor der Status eines ADR auf Accepted wechselt, werden seine Baseline-Belege in
  die Form aus Festlegung 2 gebracht"*)
- `pfad`: `docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md:266–267` (Festlegung 4,
  zweiter Spiegelstrich)
- `befund`: Der Satz *„Das Regelwerk legt es im Rückbau an, nicht im Skelett-Schritt"* ist eine
  Aussage über das Baseline-Regelwerk und trägt keinen der drei von
  [ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 2 verlangten Teile:
  keinen Regelwerks-Dateinamen, keinen Abschnittsnamen, kein Zitat. Die einzige Adresse daneben
  ist ein Markdown-Link auf die **Vorlage** unter dem lokalen Präfix
  `.harness/baseline/v6.0.0/templates/…`. **Die Aussage ist inhaltlich richtig** — in diesem Lauf
  an `modul-02-harness-bootstrap.md` §Brownfield-Bootstrap: Schritt-Sequenz, Schritt 8, und an
  `grundlagen-harness-dateien.md` §Verzeichniskonvention (*„nur im Brownfield-Bootstrap"*)
  nachgemessen.
- `verifizierbar`: **nein**. Reproduzierbar:
  ```sh
  grep -n 'reconciliation' .harness/baseline/v6.0.0/regelwerk/grundlagen-harness-dateien.md
  # -> 15: docs/plan/planning/reconciliation.md   # Reconciliation-Register: nur im Brownfield-Bootstrap
  grep -c 'modul-02-harness-bootstrap' docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md   # 0
  ```
- `klasse`: *Regelwerks-Aussage ohne dreiteiligen Beleg vor dem Accept-Übergang*

### L-4 — Der dritte Ort desselben Slice bleibt außerhalb, und an ihm ist (a) bestritten

- `kategorie`: LOW
- `quelle`: Maintainability · [`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)
- `pfad`: `docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md:291–292` (Konsequenz 2)
- `befund`: Konsequenz 2 sagt zu, *„der nächste Ort derselben Klasse braucht keine eigene Runde,
  sondern nur die drei Bedingungen"*. Der nächste Ort steht bereits im selben Slice-Plan:
  `docs/plan/carveouts/done/` (slice-190 §1, Tabelle, und §6 Risiko 3). An ihm ist Bedingung (a)
  **bestritten** — die vendored `carveout.template.md` schaltet ihre eigene Zeile mit einem Marker
  stumm und begründet das mit *„done/ entsteht erst bei erster Carveout-Auflösung"*, während die
  emittierte `docs/plan/planning/README.md` den Ort nennt. Die Eigenschaft entscheidet den Fall
  also nicht, sondern verlagert ihn in ein Urteil über zwei sich widersprechende mitemittierte
  Texte. Die ADR erwähnt den Ort nicht.
- `verifizierbar`: **nein**. Reproduzierbar:
  ```sh
  grep -n 'done/ entsteht erst' .harness/baseline/v6.0.0/templates/docs/plan/carveouts/carveout.template.md   # 77
  grep -n 'docs/plan/carveouts/done/' .harness/baseline/v6.0.0/templates/docs/plan/planning/README.template.md # 47
  grep -c 'carveouts/done' docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md                        # 0
  ```
- `klasse`: *Kriterium sagt eine Runde ab, die sein erster Anwendungsfall doch braucht*

### INFO-1 — „Im ganzen Go-Code" gegen einen Prüfbereich `internal/`

- `kategorie`: INFO
- `pfad`: `:103` und `:107`
- `befund`: Der Satz *„Im ganzen Go-Code steht der Name dreimal"* steht neben einem Kommando, das
  nur `internal/` liest. Die Aussage **hält** — die Erweiterung auf `cmd/` ändert nichts (in
  diesem Lauf gemessen: 0 Treffer) —, aber das abgedruckte Kommando belegt seinen eigenen
  Geltungsbereich nicht.
- `verifizierbar`: nein. `grep -rn 'observations' cmd/ --include='*.go' | wc -l` → **0**;
  `grep -rn 'observations' internal/ cmd/ --include='*.go' | grep -v '_test.go' | wc -l` → **3**.
- `klasse`: *Kommando misst einen engeren Bereich als der Satz behauptet*

### INFO-2 — Die zwei „verbatim" zitierten Kommentar-Absätze stehen in umgekehrter Quell-Reihenfolge

- `kategorie`: INFO
- `pfad`: `:56–64`
- `befund`: Beide Absätze sind wortgleich (Whitespace normalisiert, `// ` entfernt) — in der Quelle
  steht jedoch *„Im Adaptions-Block steht zu dieser Weiche kein Eintrag …"* **vor** *„GRENZE:
  LH-FA-02 fuehrt diese Disposition nicht …"*, im Zitat umgekehrt. Beide gehören zum Doc-Kommentar
  von `isBrownfieldOnly`; das Demonstrativum *„dieser Weiche"* verliert durch die Umstellung seinen
  vorangehenden Bezug.
- `verifizierbar`: nein. `grep -n 'Im Adaptions-Block steht zu dieser Weiche\|GRENZE: LH-FA-02' internal/emit/templates.go`
  → **133**, **143**.
- `klasse`: *Zitat-Reihenfolge weicht von der Quelle ab*

### INFO-3 — Zwei Bezugs-Auffälligkeiten im Kopf

- `kategorie`: INFO
- `pfad`: `:22` (Bezug) und Festlegung 1
- `befund`: [ADR-0005](../plan/adr/0005-ziel-repo-distribution.md) steht im `Bezug`-Feld und kommt
  im Rumpf kein zweites Mal vor. Umgekehrt fehlen
  [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
  und [`MR-036`](../../harness/conventions.md#mr-036--die-change-request-regel-bei-personalunion-steht-jetzt-in-der-adoptierten-baseline)
  im `Bezug`, obwohl Festlegung 1 die Frage *Erfüllung oder Change Request* entscheidet und die
  Commit-Message beide namentlich nennt.
- `verifizierbar`: nein. `grep -c 'ADR-0005' docs/plan/adr/0037-*.md` → **1**;
  `grep -c 'MR-015\|MR-036' docs/plan/adr/0037-*.md` → **0**.
- `klasse`: *Bezugsliste deckt die entschiedene Frage nicht*

---

## Negativbefunde (geprüft, ohne Befund)

**Alle elf Kommandos der ADR nachgefahren — jedes liefert den abgedruckten Wert.** In diesem Lauf
selbst gefahren, Reihenfolge wie in der Datei: `1` (GRENZE-Kommentar), `1` (Architect-Kommentar),
`1` / `1` (die zwei Baseline-Zitate in `modul-06-roadmap.md`), `3` (Anweisungssätze nennen den
Ort), `2` (davon namentlich die Datei), `3` (Go-Fundstellen), `2` (davon Kommentare),
`| 0.8.0 | 2026-07-21`, `2026-09-03` (MR-045-Datum), `0` (keine vendored Vorlage für die
Register-README). **Keine Abweichung.**

- **Die Kern-Argumentation zu [ADR-0007](../plan/adr/0007-bootstrap-phasen.md) trägt.** Im
  Volltext gelesen: Entscheidung 3 ist eine **Idempotenz**-Klassifikation — *„jede emittierte
  Datei ist genau einer Klasse zugeordnet; im Zweifel gilt `skip-if-present`"* —, und ihre Tabelle
  beantwortet ausschließlich, wie eine Datei beim **Re-Lauf** behandelt wird (*„Re-Lauf
  repariert/hebt die tool-eigene Infrastruktur ohne ein skip-if-present-Artefakt anzufassen"*).
  Kein Satz der ADR-0007 sagt, **ob** eine Datei beim ersten Lauf entsteht; das Register kommt in
  ihr nicht vor. Die Behauptung *„beantwortet damit eine andere Frage als ob sie beim ersten Lauf
  entsteht"* ist damit belegt.
- **Die Kern-Argumentation zu [ADR-0034](../plan/adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
  trägt, und beide Zitate sind verbatim.** Festlegung 1 lautet im Original *„Die stehende
  Register-Datei entfällt, und keine Index-Datei tritt an ihre Stelle. Die Ablage ist die der
  Ziel-Fassung: ein Verzeichnis `observations` unter `docs/plan/planning/` mit `README.md` und je
  Beobachtung einem Verzeichnis."* Sie schreibt die `README.md` also als **Bestandteil der Ablage**
  vor und spricht damit für die Anlage, nicht gegen sie. Festlegung 5 bestätigt das auf der
  zweiten Achse (*„Ortsfest … sind nach dem Sprung die **Ablage** `observations` … und die
  Verzeichnisse darin"*). Dass ADR-0034 über die **emittierte** Ebene nichts sagt, ist in diesem
  Lauf über den Volltext geprüft: das Wort *emittiert* fällt dort nur in der Aufzählung der 74
  nachzuziehenden Quell-Dateien, nie als Gegenstand einer Festlegung.
- **Die zwei Gegenbeispiele fallen tatsächlich nicht unter die Eigenschaft — das war die Frage,
  und die Antwort ist ja.** Für das **Reconciliation-Register** scheitert (a) belastbar, und zwar
  an **zwei** Stellen statt der einen, die die ADR nennt: die emittierte
  `docs/plan/planning/README.md` sagt *„Greenfield-Repos haben die Datei nicht"*, und die
  Verzeichniskonvention des Regelwerks führt sie mit dem Zusatz *„nur im Brownfield-Bootstrap"*.
  Für die **derivativen Indexe** ist das Ergebnis dasselbe — sie bleiben draußen —, nur nicht aus
  dem genannten Grund (M-1). **Ein Widerspruch der Art «die Eigenschaft trifft auch auf die zwei
  zu» liegt nicht vor.**
- **Die Antwort auf Frage 2 ist inhaltlich richtig** (der Beleg fehlt nur in der Datei, M-2):
  (a) — `grundlagen-harness-dateien.md` §Verzeichniskonvention führt `harness/conventions/` im
  Indikativ in derselben Baumdarstellung wie `observations/`, und die emittierte
  `harness/conventions.md` sagt *„Jede Adaption ist eine eigene Datei unter `harness/conventions/`"*;
  (b) — ein leeres Verzeichnis führt `git` nicht; (c) — ein `.gitkeep` erzeugt keinen Link.
  Gegengeprüft an slice-190 §1, das für den Ort **2** Fundstellen misst.
- **`LH-FA-02`-Zitat verbatim.** *„Leere Struktur-Verzeichnisse (Lifecycle-Ordner, ADR-/Carveout-/
  Reviews-Ordner) werden mit `.gitkeep` gehalten"* steht so im Lastenheft (Zeilenumbruch nach
  *Lifecycle-*, nach [ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 2
  zulässig).
- **Handbuch-Zitat verbatim.** Die 1.13-Zeile stimmt Zeichen für Zeichen bis auf die entfallene
  Auszeichnung um *selbst* — zulässig.
- **`AGENTS.md` §3.11-Zitat verbatim**, Auslassung markiert.
- **Die §5-Herkunfts-Aussage trägt.** [`spec/lastenheft.md §5`](../../spec/lastenheft.md#5-globale-out-of-scope-punkte)
  nennt als Tool-als-Quelle genau `LH-FA-06`, `LH-FA-08` und `LH-FA-10`; `LH-FA-03` steht dort
  nicht. Der Emitter sagt über `.d-check.yml` tatsächlich *„vom Tool AUTORIERTE minimale Config"*
  (`internal/emit/emit.go:7`). Die Präzedenz ist damit belegt.
- **Der emittierte Selbstwiderspruch besteht real.** Alle **drei** Anweisungssätze unter
  `internal/emit/templates/commands/` nennen den Ort, **zwei** davon namentlich die Datei
  (`plan-welle.md:46`, `close-welle.md:60`), und kein Emissionspfad legt sie an — die dritte
  Go-Fundstelle (`internal/archive/stub.go:224`) setzt einen Link, kein Verzeichnis.
- **Fitness Function — kein halluziniertes Gate.** `TestTemplates_EmittierterBestandVollstaendig`
  existiert (`internal/emit/templates_test.go:264`) und vergleicht den emittierten Baum per
  Mengengleichheit gegen `want`; beide Richtungen färben rot. `make full-smoke` existiert und ist
  korrekt als Nicht-Gate ausgewiesen. Die zwei *nicht gebauten* Deckungen sind benannt statt
  behauptet — und beide Voraussetzungen stimmen: die emittierte
  [`d-check.yml`](../../internal/emit/templates/d-check.yml) führt `modules: [links, anchors]`
  (kein `codepaths`), und der Dogfood-`codepaths` hat `roots: [spec, docs, harness]`, also den
  emittierten Bestand außerhalb. [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
  gewahrt.
- **`MR-000` — kein Adaptions-Eintrag fällig.** Festlegung 2 stellt Baseline-Konformität
  **her**; Festlegung 1 legt einen Rang-1-Satz dieses Repos aus, zu dem die Baseline nichts sagt.
  Keine der vier Festlegungen weicht von einer Baseline-Regel ab.
- **`AGENTS.md` §3.5 — keine Gate-Lockerung**, also kein zusätzlicher ADR-Bedarf. Kein Schwellwert,
  kein `ignore`-Eintrag, keine Modul-Abschaltung berührt.
- **`AGENTS.md` §3.8 — Commit-Zuschnitt korrekt.** `git show --pretty=format: --name-only dab5028`
  gibt **zwei** Dateien: die ADR und `docs/plan/adr/README.md`. Der ADR-Index gehört nach
  [ADR-0024](../plan/adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md) dem
  Architect; die Message nennt die Rolle im Präfix.
- **`AGENTS.md` §3.10 — die Rollen-Grenze ist gewahrt.** Der Commit setzt weder die
  Risiko-Ausgänge in slice-190 §6 noch die Trigger-Zeile §4; Folgepflicht 3 sagt das ausdrücklich.
- **ADR-Index gepflegt.** `docs/plan/adr/README.md:44` führt ADR-0037 mit Titel (deckungsgleich
  mit der `# `-Überschrift), Status `Proposed` und derselben Bezugs-Liste in derselben Reihenfolge
  wie der Kopf der Datei.
- **Ziel-Form vollständig.** Gegen
  [`NNNN-titel.template.md`](../../.harness/baseline/v6.0.0/templates/docs/plan/adr/NNNN-titel.template.md)
  geprüft: Status · Datum · Autor · Bezug · Schärft · Regeln · Kontext · Entscheidung ·
  Verglichene Alternativen (fünf Optionen, gefordert sind mindestens drei, *nichts tun* ist
  dabei) · Konsequenzen (positiv, negativ, Folgepflichten) · Fitness Function ·
  Re-Evaluierungs-Trigger (fünf, jeder mit beobachtbarer Ablesestelle in Klammern) · Geschichte
  (eine Zeile, `Proposed` — die zweite entsteht beim Umschlag). Der Schluss-Satz zur
  Immutabilität steht.
- **`Schärft:`-Feld korrekt.** `ARC-003` existiert
  ([`spec/architecture.md`](../../spec/architecture.md#1-komponenten-übersicht), Zeile 75) und
  heißt *Idempotente Ablage*; die Aufwärts-Deklaration nennt die zwei nachzuziehenden Stellen.
- **`MR-033` gewahrt.** Jede Baseline-Aussage nennt den Tag `v6.0.0` — in der
  Abschnittsüberschrift und in jedem Pfad-Operanden.
- **[ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 2, Präfix-Achse — kein
  Befund.** Von den vier Vorkommen von `.harness/baseline/v…` stehen drei in Codeblöcken
  (Kommando-Operanden), das vierte ist ein Zeiger auf eine **Vorlage**, kein Beleg einer
  Regelwerks-Aussage. Dieselbe Form führen **15** ADRs dieses Repos, darunter ADR-0016 selbst
  (`awk`-Lauf mit Codeblock-Zähler über `docs/plan/adr/[0-9]*.md`). Kein Zeilennummer-Locator in
  der Datei (`grep -cE '\.md:[0-9]+'` → 0). Die verbleibende Lücke ist L-3 und betrifft die
  Zitat-Achse, nicht die Präfix-Achse.
- **[ADR-0030](../plan/adr/0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) Festlegung 3 /
  [`AGENTS.md`](../../AGENTS.md) §3.11 — kein Befund.** Die Datei nennt `slice-190`, `slice-191`,
  `slice-073` und `slice-177` als **Kennung** in Inline-Code, ohne Pfad-Adresse in den
  Planning-Lifecycle; die zwei Markdown-Links in den Planning-Baum zeigen auf
  `observations/BEO-ALL/…/observation.md`, und diese Ablage ist nach
  [ADR-0034](../plan/adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
  Festlegung 5 ausdrücklich **ortsfest**.
- **Doku-Gate grün.** `make docs-check` → `838` bzw. nach diesem Report `840 Datei(en) geprüft, 0 Befund(e)`. Jeder Link und
  jeder Anker der ADR und der Index-Zeile löst auf; die relativen Tiefen (`../../../spec/`,
  `../planning/`, `../../user/`) stimmen.
- **Docker-only (§3.9).** Kein Host-Paketmanager, keine Host-Toolchain in diesem Lauf; alles über
  `make`, `git`, `grep`, `sed`, `awk`, `ls`, `find`.
- **Nicht geprüft (fremde Rolle):** DoD-Abhakung und Plan-vs-Code-Konformität — Verifikation,
  getrennter Kontext, anderes Prüf-Artefakt. Ebenso **nicht** Gegenstand: der tote Link in
  `internal/archive/stub.go:224` auf die abgelöste `../../observations.md` — er liegt außerhalb des
  Diffs `dab5028^..dab5028` und außerhalb dieser ADR.

---

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 5 |
| LOW | 4 |
| INFO | 3 |

**Finding-Klassen dieses Laufs:** *Ausschluss-Grund benennt eine Bedingung, die der heutige Code
nicht mehr erzeugt* · *Schluss ohne die Messung, die derselbe Text von anderen verlangt* ·
*Normsatz nennt eine Menge, die sein eigener Text nicht identifiziert* · *Aussage über den Stand
eines fremden Artefakts ohne Messung an ihm* · *Zahl neben nie gefahrenem Kommando* · *Bestand als
Norm* · *Zwei Sätze desselben Artefakts weisen dieselbe Folgepflicht verschieden zu* ·
*Regelwerks-Aussage ohne dreiteiligen Beleg vor dem Accept-Übergang* · *Kriterium sagt eine Runde
ab, die sein erster Anwendungsfall doch braucht* · *Kommando misst einen engeren Bereich als der
Satz behauptet* · *Zitat-Reihenfolge weicht von der Quelle ab* · *Bezugsliste deckt die
entschiedene Frage nicht*

**Wiederkehrendes Muster dieses Laufs, dreimal in verschiedenen Sektionen:** *der genannte Grund
ist nicht der Grund, der trägt* (M-1 Festlegung 4, L-1 Festlegung 3, L-3 Festlegung 4). Jedes Mal
stimmt der **Ausgang**, und jedes Mal benennt die Datei eine Stütze, die eine Messung nicht
hergibt. Nach der Kontext-Eskalation des Reviewer-Skills ist die dritte Wiederholung ein
Steering-Loop-Signal; die Vergabe eines Register-Belegs gehört in die Closure, nicht in diesen
Report.

---

## Verdikt

**Konsistenz NICHT BESTÄTIGT — fünf blockierende MEDIUM, kein HIGH.**

**Was trägt, und es ist der größere Teil.** Die **Entscheidung selbst ist tragfähig** und in
diesem Lauf breiter belegt als in der Datei: Alle elf abgedruckten Kommandos reproduzieren ohne
Abweichung. Die zwei Kern-Argumentationen, nach denen ausdrücklich gefragt war, halten dem
Volltext stand — [ADR-0007](../plan/adr/0007-bootstrap-phasen.md) beantwortet *wie* und nicht
*ob*, und [ADR-0034](../plan/adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
Festlegung 1 schreibt die `README.md` als Bestandteil der Ablage **vor**. Der emittierte
Selbstwiderspruch ist real und gemessen. Die Antwort auf Frage 2 ist **inhaltlich richtig**. Und
die geprüfte Kohärenz-Frage hat eine klare Antwort: **die zwei Gegenbeispiele fallen nicht unter
die Eigenschaft** — ein Widerspruch der Art *„die Bedingungen sind so weit, dass sie auch die zwei
treffen"* liegt **nicht** vor.

**Was blockiert, ist durchweg dieselbe Bauart: die Datei nennt Stützen, die die Messung nicht
hergibt.** M-1 (der (c)-Grund ist am heutigen Emit-Pfad hinfällig, und er trägt die
Enge-Zusage der gewählten Alternative), M-2 (Frage 2 ohne die Prüfung, die dieselbe Festlegung
vom umsetzenden Lauf verlangt), M-3 (der Gegenstand *„die zwei Struktur-Aufzählungen"* ist nicht
bestimmt, gemessen sind es vier Klassen-Aufzählungen), M-4 (die Geschichte-Zeile beschreibt den
Slice-Plan-Stand falsch — sechs offene Risiken, eine Trigger-Bedingung) und M-5 (zwei
Messwert-Zahlen ohne ihr Kommando, eine davon ein Register-Zähler unter
[`MR-051`](../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
Setzung 2).

**Warum das vor der Annahme zählt und nicht danach.** Vier der fünf sind je ein bis drei Sätze.
Ab `Accepted` sperrt [`AGENTS.md`](../../AGENTS.md) §3.4 jede davon, und der Preis steigt von
einer Zeile auf eine Folge-ADR mit `Supersedes` — dieselbe Kosten-Asymmetrie, mit der
[ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 3 (a) ihren
Accept-Übergang begründet.

**Übergabe.** Die Findings gehen an den **Architect** — er hält die ADR
([`AGENTS.md`](../../AGENTS.md) §3.8), und dieser Report hat kein Artefakt außer sich selbst
angefasst. **Über den `Accepted`-Übergang entscheidet dieser Report nicht**; er stellt fest, dass
der Baseline-Trigger *„ADR-Review-Runde abgeschlossen → bindend"* mit **diesem** Verdikt nicht
feuert. Die Finding-Klassen gehen zusätzlich in die Slice-Closure §7 und von dort in den Zähler;
die Zuordnung zu einer `BEO-ALL/<slug>` fällt beim Schreiben der Closure, nicht hier.

Dieser Report ist ein **Lauf-Beleg** und ersetzt keine Verifikation — DoD-/Spec-Konformität prüft
der Verifier separat (Modul 11, anderes Prüf-Artefakt, anderer Eingabe-Kontext).
