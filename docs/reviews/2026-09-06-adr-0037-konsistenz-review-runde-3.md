# Review: ADR-0037 — Konsistenz-Review, Runde 3

**Review-Art:** Plan-Review gegen Spec/ADR (Modul 10 §Drei Review-Arten) — geprüft wird die
Entscheidung gegen ihre zitierten Quellen, **nicht** DoD-Konformität (Verifier-Rolle, getrennter
Kontext).

**Gegenstand:** [`docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md`](../plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md)
Status `Proposed`, Nacharbeit-Commit `2ded1ca` (Diff `2ded1ca^..2ded1ca` = zwei Dateien, die ADR
und der ADR-Index).

**Skill:** `.harness/skills/reviewer.md` @ 1.7.0 ·
**Modell:** claude-opus-5[1m] · **Datum:** 2026-09-06

**Reviewer:** frischer Kontext. Keines der geprüften Artefakte selbst geschrieben, an keinem etwas
geändert. **Jede Zahl und jedes Kommando dieses Reports ist in diesem Lauf selbst gefahren**;
nichts ist aus der Commit-Message von `2ded1ca`, aus dem Slice-Plan oder aus der ADR übernommen.
Die zwei blockierenden Befunde der Vorrunde und **jeder** übrige Posten beider Vorrunden sind
einzeln am Ist-Stand nachgeprüft, nicht am Änderungsbericht.

---

## Eingangs-Kontext (fünf Pflicht-Punkte + Plan)

- **Diff-Range:** `2ded1ca` gegen `2ded1ca^` = `f603c5d`. `HEAD` steht in diesem Lauf auf
  `09cad1f`; zwischen Gegenstand und Prüfung liegen Commits, aber keiner an einer ADR, und die
  Datei selbst ist unverändert
  (`git log --oneline 2ded1ca..HEAD -- docs/plan/adr/ | wc -l` → **0**;
  `git diff 2ded1ca HEAD -- docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md | wc -l`
  → **0**). Der Arbeitsbaum ruhte beim Beginn dieses Laufs
  (`git status --porcelain | wc -l` → **0**) — anders als in beiden Vorrunden; danach trägt er
  allein diese Datei.
- **`LH-*`:** [`LH-FA-01`](../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen),
  [`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) (Rang 1, der
  ausgelegte Absatz), [`LH-FA-03`](../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7),
  [`LH-FA-09`](../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren),
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6).
- **Referenzierte aktive ADRs**, Status in diesem Lauf gemessen
  (`for f in 0005 0006 0007 0016 0024 0034; do grep -m1 '^\*\*Status:\*\*' docs/plan/adr/$f-*.md; done`):
  alle sechs `Accepted`. Keine `Superseded`/`Deprecated` unter den zitierten.
- **Hard Rules:** [`AGENTS.md`](../../AGENTS.md) §3, insbesondere §3.4 (die Kosten-Asymmetrie, die
  diesen Report trägt), §3.5, §3.6, §3.8, §3.9, §3.10, §3.11. Dazu
  [`MR-000`](../../harness/conventions.md#mr-000--baseline-aussage),
  [`MR-001`](../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids),
  [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler),
  [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert),
  [`MR-033`](../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist),
  [`MR-036`](../../harness/conventions.md#mr-036--die-change-request-regel-bei-personalunion-steht-jetzt-in-der-adoptierten-baseline)
  und [`MR-051`](../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung).
- **Vorherige Findings am gleichen Modul:**
  [Runde 1](2026-09-06-adr-0037-konsistenz-review.md) (0 HIGH · 5 MEDIUM · 4 LOW · 3 INFO) und
  [Runde 2](2026-09-06-adr-0037-konsistenz-review-runde-2.md) (0 HIGH · 2 MEDIUM · 4 LOW ·
  5 INFO), beide *Konsistenz NICHT BESTÄTIGT*.
- **Slice-Plan:** `slice-190` — das Übergabe-Artefakt, dessen zwei Fragen die ADR beantwortet.
  Seine Verzeichnis-Position steht hier bewusst nicht als Pfad
  ([`AGENTS.md`](../../AGENTS.md) §3.11); die Kommandos unten adressieren ihn über den Glob
  `docs/plan/planning/*/slice-190-*.md`, der in diesem Lauf **genau eine** Datei trifft
  (`ls -1 docs/plan/planning/*/slice-190-*.md | wc -l` → **1**, kein Erwartungswert).

**Gate-Lauf, zweimal und Docker-only (§3.9).** `make docs-check` vor dem Schreiben dieses Reports →
`d-check: 867 Datei(en) geprüft, 0 Befund(e)`, EXIT 0. `make gates` **nach** dem Schreiben →
**EXIT 0**, alle Gates grün; dieser Lauf schließt `docs-check` ein und deckt damit auch diese
Datei — jeder Link und jeder Anker der ADR, der Index-Zeile und dieses Reports löst auf.

---

## Findings

Jedes Finding folgt dem §Output-Schema des Reviewer-Skills.

### M-1 — Festlegung 4 schließt einen Ort aus, den die Rang-1-Aufzählung nennt und den die DoD des bedienten Slice namentlich verlangt; keine dieser Stellen steht in der Datei

- `kategorie`: **MEDIUM** (blockiert den Statuswechsel)
- `quelle`: [`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)
  (Rang 1 — der ausgelegte Satz) · [`AGENTS.md`](../../AGENTS.md) §3.10 (die ADR ist das
  Übergabe-Artefakt, aus dem der Planner schöpft — so sagt es ihre eigene Folgepflicht 3)
- `pfad`: `docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md:444–468` (Festlegung 4,
  dritter Spiegelstrich) gegen `:286–295` (Festlegung 1, Erfüllungs-Zusage)
- `befund`: Der in dieser Nacharbeit **neu** entstandene Spiegelstrich stellt fest,
  `docs/plan/carveouts/done/` sei nur *„als **Ziel eines Umzugs** genannt, den ein frisches Repo
  nicht hinter sich hat"*, (a) trage nicht, der Ort bleibe draußen. Der Slice, dessen zwei Fragen
  diese ADR beantwortet, sagt an vier Stellen das Gegenteil: §1 führt ihn unter den *„zwei
  unstrittigen"* Orten (strittig ist dort **nur** der Register-Ort); §3 begründet das an Rang 1
  selbst — *„`docs/plan/carveouts/done` ist ein Carveout-Ordner und damit gedeckt"*, und die
  Klammer, die Festlegung 1 auslegt, nennt *„ADR-/Carveout-/Reviews-Ordner"*; **DoD (1)** verlangt
  ihn namentlich in `structureGitkeeps()`; **DoD (3)** misst *„6 → 3 Befunde"*, eine Zahl, die
  ohne ihn nicht erreichbar ist. Die ADR nennt keine dieser vier Stellen — sie erwähnt `slice-190`
  dreimal und seine DoD kein einziges Mal. Damit nimmt Festlegung 4 für einen Ort genau die Zusage
  zurück, von der Festlegung 1 elf Absätze früher sagt, es werde *„keine Zusage … zurückgenommen"*.
- **Failure-Szenario:** Der Planner, den Folgepflicht 3 auf diese Datei verweist, zieht `slice-190`
  nach `next/`. Der umsetzende Lauf hat zwei einander widersprechende Anweisungen — DoD (1)
  *„`structureGitkeeps()` bekommt … `docs/plan/carveouts/done`"* gegen Festlegung 4 *„bleiben
  draußen"* — und die ADR-Seite ist ab `Accepted` gesperrt. Folgt er der ADR, fällt DoD (3) auf
  vier Rückstände statt drei, und einer davon gehört nicht zum Register-Konflikt, den derselbe
  DoD-Punkt namentlich als die verbleibende Menge zusagt. Folgt er der DoD, legt er einen Ort an,
  den eine `Accepted`-ADR ausschließt. Die Auflösung ist dann eine Folge-ADR plus eine
  Planner-Runde am DoD — beides heute ein Satz.
- **Was dieser Befund nicht bestreitet:** dass der Architect die Plan-Prämisse verwerfen **darf**.
  Bestritten ist, dass er es **stillschweigend** tut: die Prämisse steht in Rang 1 und in einem
  DoD-Punkt, und beides ist in der ADR unerwähnt.
- `verifizierbar`: **nein** — kein Gate hält einen ADR-Satz gegen einen DoD-Punkt. Reproduzierbar:
  ```sh
  sed -n '/^## 2\. Definition of Done/,/^## 3\./p' docs/plan/planning/*/slice-190-*.md \
    | grep -c 'docs/plan/carveouts/done'                                        # 1
  sed -n '/^## 2\. Definition of Done/,/^## 3\./p' docs/plan/planning/*/slice-190-*.md \
    | grep -c '6 → 3 Befunde'                                                   # 1
  sed -n '/^## 1\./,/^## 2\./p' docs/plan/planning/*/slice-190-*.md \
    | grep -c 'Nur die ersten zwei sind unstrittig'                             # 1
  sed -n '/^## 3\./,/^## 4\./p' docs/plan/planning/*/slice-190-*.md | tr '\n' ' ' \
    | grep -oE 'carveouts/done. ist ein Carveout-Ordner und damit +gedeckt'
  # -> carveouts/done` ist ein Carveout-Ordner und damit gedeckt
  grep -c 'DoD\|Definition of Done' \
    docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md                # 0
  grep -c 'keine Zusage wird zurückgenommen' \
    docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md                # 1
  ```
  **Keine Erwartungswerte.**
- `klasse`: *Entscheidung verwirft eine Plan-Prämisse, ohne sie zu nennen*

### M-2 — Die neu geschriebene Auswertungs-Regel zu (a) trägt den Ausschluss von `harness/conventions/done/` nicht, und der tragende Satz beruft sich auf eine dritte, ungeschriebene Formel

- `kategorie`: **MEDIUM** (vor dem Statuswechsel zu klären)
- `quelle`: Maintainability ·
  [`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)
- `pfad`: `docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md:277–284` (die
  Auswertungs-Regel) gegen `:444–455` (ihre Anwendung) und `:326–332` (der (a)-Beleg, dessen Zitat
  denselben Ort mitführt)
- `befund`: Die Regel nennt **zwei** Formen, an denen (a) scheitert — den Modus-/Bedingungs-Zusatz
  und die Wenn-dann-Form — und schließt mit *„ein zweiter Text hilft nur, wenn **er** den Ort
  unbedingt führt"*: eine bedingte Nennung **hilft** danach nicht, sie **entkräftet** nichts. Für
  `harness/conventions/done/` liegt genau der Fall vor, den die Regel nicht regelt. Dieselbe
  Regelwerks-Zeile, die (a) für den Elternort trägt, nennt `done/` ohne jeden Zusatz —
  *„harness/conventions/ # ein MR je Datei; done/ = aufgelöst"* —, und die ADR sagt das selbst
  (*„steht im (a)-Beleg oben mit im Zitat"*). Entkräftet wird diese unbedingte Nennung nicht;
  daneben gesetzt wird eine **zweite**, bedingte Nennung aus der Vorlage. Der Satz, der beide
  `done/`-Orte zusammen trägt, beruft sich zudem auf eine **dritte** Formel — *„als **Ziel eines
  Umzugs** genannt"* —, die in der Auswertungs-Regel kein einziges Mal vorkommt. Eine Regel, die
  eine unbedingte Nennung im eigenen Kronzeugen-Zitat nicht adressiert, unterscheidet die Fälle,
  auf die sie angewandt wird, nicht.
- **Failure-Szenario:** Konsequenz 2 sagt zu, *„ob* der nächste Ort derselben Klasse aufzunehmen
  ist, beantworten die drei Bedingungen samt der Auswertungs-Regel zu (a), ohne eigene Runde"*.
  Ein späterer Lauf misst nach dem **geschriebenen** Text, findet für `harness/conventions/done/`
  die zusatzfreie Regelwerks-Nennung, liest (a) als erfüllt — und steht gegen Festlegung 4, die
  dann eingefroren ist. Dieselbe Lücke trägt der Ausschluss des zweiten `done/`-Ortes, dessen
  Nennung (*„Aufgelöste Carveouts wandern **nicht** hierher, sondern in ihr eigenes
  `docs/plan/carveouts/done/`"*) weder einen Modus-Zusatz noch eine Wenn-dann-Konstruktion trägt.
- `verifizierbar`: **nein** — kein Gate liest, ob ein Kriterium seinen eigenen Anwendungsfall
  erfasst. Reproduzierbar:
  ```sh
  grep -n '^harness/conventions/ ' \
    .harness/baseline/v6.0.0/regelwerk/grundlagen-harness-dateien.md
  # -> 22: harness/conventions/        # ein MR je Datei; done/ = aufgelöst
  grep -c 'Ziel eines Umzugs' \
    docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md                       # 2
  sed -n '277,284p' docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md \
    | grep -c 'Ziel eines Umzugs'                                                      # 0
  sed -n '46,47p' \
    .harness/baseline/v6.0.0/templates/docs/plan/planning/README.template.md
  # -> "Aufgelöste Carveouts wandern **nicht** hierher, / sondern in ihr eigenes
  #     `docs/plan/carveouts/done/` (Baseline-Regelwerk"
  ```
  **Keine Erwartungswerte.** Die **Auswahl** ist im Ergebnis nachvollziehbar — die drei
  ausgeschlossenen Orte entstehen tatsächlich erst durch ein Ereignis; nachvollziehbar ist die
  *Anwendung*, nicht die *geschriebene Regel*.
- `klasse`: *Kriterium wird angewandt, ohne dass seine Auswertungs-Regel den Fall trägt*

### M-3 — Die Datei erklärt eine Abweichung von einem Rang-1-Satz und ordnet sie nicht ein, während sie genau diese Einordnung für einen anderen Gegenstand ausdrücklich trifft

- `kategorie`: **MEDIUM** (vor dem Statuswechsel zu klären)
- `quelle`: [`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)
  (Rang 1) · [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
  / [`MR-036`](../../harness/conventions.md#mr-036--die-change-request-regel-bei-personalunion-steht-jetzt-in-der-adoptierten-baseline)
- `pfad`: `docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md:368–372` (Festlegung 2,
  neu) und `:492–498` (Konsequenz 2, neu) gegen `:286–295` (Festlegung 1)
- `befund`: Die Nacharbeit hat die Träger-Frage aus dem Kriterium herausgenommen und dabei zweimal
  in Worte gefasst, was vorher unausgesprochen blieb: *„**womit** er gehalten wird, sagt
  [`LH-FA-02`] mit `.gitkeep` als Vorgabe. Diese Festlegung **weicht davon** für **einen**
  benannten Ort **ab**"* und *„eine Abweichung davon — wie sie Festlegung 2 für **einen** Ort
  trifft — ist eine eigene Frage mit eigener Begründung"*. Die Datei erklärt damit selbst, dass sie
  von einer Vorgabe des Rang-1-Satzes abweicht. Ob **diese** Abweichung Erfüllung oder
  Vertragsänderung ist, sagt sie nirgends: Festlegung 1 trifft die Einordnung ausdrücklich für
  *„die Aufnahme eines **Ortes**"* und schließt den Träger ebenso ausdrücklich aus (*„die drei
  Bedingungen begründen sie nicht und könnten es nicht"*), Alternative D stellt die CR-Option nur
  für die Aufzählung, und der `Bezug`-Kopf führt
  [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
  mit der Erläuterung *„Festlegung 1 beantwortet sie als Erfüllung"* — also für den Gegenstand, der
  **nicht** abweicht.
- **Failure-Szenario:** Der adoptierte Baseline-Wortlaut, den
  [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
  verbatim führt, lautet *„weder ADR noch Slice dürfen `LH-*` je ändern"*. Ein späterer Lauf fragt,
  ob die eine Abweichung, die diese ADR tatsächlich vollzieht, den externen Vorgang durchlaufen hat
  — und findet in der Datei nur die Einordnung eines anderen Gegenstands. Ab `Accepted` ist die
  Antwort eine Folge-ADR; heute ist sie ein Satz. Der Preis fällt genau dort an, wo diese ADR ihren
  Wert hat: `slice-190` §4 macht die beantwortete Change-Request-Frage zur Bedingung für
  `open → next`.
- **Was dieser Befund nicht bestreitet:** die Wahl der `README.md` gegen das `.gitkeep`. Sie ist in
  Festlegung 2 begründet und in Alternative C gegen ihre Alternative gehalten. Fehlt die
  **Einordnung** der Abweichung, nicht ihre Begründung.
- `verifizierbar`: **nein**. Reproduzierbar:
  ```sh
  grep -c 'weicht davon für \*\*einen\*\* benannten Ort ab' \
    docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md    # 1
  grep -c 'Abweichung davon — wie sie Festlegung 2' \
    docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md    # 1
  sed -n '/^### LH-FA-02/,/^### LH-FA-03/p' spec/lastenheft.md | tr '\n' ' ' \
    | grep -o 'Leere Struktur-Verzeichnisse[^;]*'
  # -> "Leere Struktur-Verzeichnisse (Lifecycle- Ordner, ADR-/Carveout-/Reviews-Ordner)
  #     werden mit `.gitkeep` gehalten"
  ```
  **Keine Erwartungswerte.**
- `klasse`: *Erklärte Abweichung ohne die Einordnung, die dasselbe Dokument für seinen anderen Gegenstand trifft*

### L-1 — Zwei der sieben neuen Zitate enden ohne Auslassungsmarke mitten im Quellsatz, während die Datei die Marke an anderer Stelle setzt

- `kategorie`: LOW
- `quelle`: [ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 2 ·
  Maintainability
- `pfad`: `docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md:432–433` und `:450–451`
- `befund`: *„Diskrepanz-Schock: docs/plan/planning/reconciliation.md anlegen"* bricht dort ab, wo
  die Quelle mit *„(Ziel-Form …) und jeden Fund als Zeile klassifizieren: …"* weitergeht;
  *„Aufgelöste Carveouts wandern **nicht** hierher, sondern in ihr eigenes
  `docs/plan/carveouts/done/`"* bricht vor *„(Baseline-Regelwerk …)"* ab. Beide Auslassungen sind
  unmarkiert. [ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 2 regelt
  Auszeichnung und Whitespace, nicht die Kürzung — die Datei selbst setzt das `…` an anderer
  Stelle (*„wandert sie … nach `conventions/done/`"*), und Runde 1 hat die markierte Auslassung am
  `AGENTS.md`-Zitat derselben Datei als Negativbefund geführt. **Der Sinn ist nicht verschoben** —
  beide gekürzten Fortsetzungen tragen nichts zur belegten Aussage bei; gemessen, nicht angenommen.
- **Failure-Szenario:** Ein späterer Lauf hält das Zitat gegen die Quelle, findet eine längere
  Zeile und muss entscheiden, ob gekürzt oder eine ältere Fassung zitiert wurde. An einer
  eingefrorenen Datei ist das nicht mehr nachzutragen.
- `verifizierbar`: **nein**. Reproduzierbar:
  ```sh
  sed -n '379p' .harness/baseline/v6.0.0/regelwerk/modul-02-harness-bootstrap.md | cut -c1-140
  # -> | 8 | **Diskrepanz-Schock:** `docs/plan/planning/reconciliation.md` anlegen (Ziel-Form …
  sed -n '46,47p' .harness/baseline/v6.0.0/templates/docs/plan/planning/README.template.md
  grep -c 'wandert sie … nach' \
    docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md      # 1 — die markierte Form
  ```
- `klasse`: *Zitat gekürzt ohne Auslassungsmarke*

### INFO-1 — Die Auszeichnungs-Form der Baseline-Zitate folgt dem Dogfood-Bestand, nicht einer Zitier-Regel

- `kategorie`: INFO
- `pfad`: `:429`, `:432` gegen `:332`, `:447–448`, `:451`
- `befund`: Der `codepath-missing`-Fix trägt (siehe Negativbefunde), aber er hinterlässt eine
  Asymmetrie ohne erkennbaren Grund im Text: `docs/plan/planning/reconciliation.md` steht in
  **allen** Zitaten ohne Code-Span, jeder andere Pfad in einem Zitat derselben Datei **mit**
  (`harness/conventions/`, `conventions/done/`, `docs/plan/carveouts/done/`). Das trennende Merkmal
  ist nicht die Zitier-Form, sondern die Existenz im **Dogfood**: `reconciliation.md` ist der
  einzige Pfad dieser Menge, den dieses Repo nicht führt, und `codepaths` mit
  `roots: [spec, docs, harness]` hätte ihn als Code-Span gemeldet. Umgekehrt ist
  `docs/plan/carveouts/done/` hier vorhanden und darum grün — im **emittierten** Repo, über das der
  Satz spricht, fehlt er ebenso. Das Grün des Gates sagt an dieser Stelle nichts über den
  Gegenstand der Aussage.
- `verifizierbar`: nein.
  ```sh
  grep -c '`docs/plan/planning/reconciliation.md`' \
    docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md   # 0 — nie als Code-Span
  grep -c 'docs/plan/planning/reconciliation.md' \
    docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md   # 3 — dreimal als Klartext
  for p in docs/plan/carveouts/done harness/conventions docs/plan/planning/reconciliation.md; do
    printf '%-40s ' "$p"; [ -e "$p" ] && echo EXISTS || echo ABSENT; done
  # -> EXISTS · EXISTS · ABSENT
  ```
- `klasse`: *Gate-Grün einer Pfad-Nennung hängt am Dogfood-Bestand, nicht am beschriebenen Stand*

### INFO-2 — Einer der zwei Belege für den Carveout-Ausschluss lebt in einem `<!-- -->`-Block einer Vorlage

- `kategorie`: INFO
- `pfad`: `:452–454`
- `befund`: Der zweite Beleg gegen `docs/plan/carveouts/done/` ist die Begründung eines
  `d-check:ignore`-Markers — *„done/ entsteht erst bei erster Carveout-Auflösung"* —, und die steht
  in `carveout.template.md` ausschließlich in einem HTML-Kommentar. Die ADR beschreibt das korrekt
  (*„schaltet ihre eigene Zeile mit einem Marker stumm und begründet das mit …"*), sie behauptet
  keinen Rumpf-Text. **Kein HIGH nach der Klasse *Norm nur im Template-Kommentar*:** die Vorlage ist
  *wiederkehrend* und wird nicht gestempelt, sie liegt im Ziel unverändert im vendored Baum, und
  der Adopter entfernt dort keine Kommentare. Wer den Beleg gewichtet, sollte wissen, dass er nur
  in der Kommentar-Schicht existiert.
- `verifizierbar`: nein.
  ```sh
  sed -n '77p' .harness/baseline/v6.0.0/templates/docs/plan/carveouts/carveout.template.md
  # -> - [ ] Datei wird nach `docs/plan/carveouts/done/` bewegt (reiner `git mv`).
  #      <!-- d-check:ignore (done/ entsteht erst bei erster Carveout-Auflösung) -->
  grep -c 'done/ entsteht erst bei erster Carveout-Auflösung' \
    .harness/baseline/v6.0.0/templates/docs/plan/carveouts/carveout.template.md   # 1
  ```
- `klasse`: *Beleg lebt nur in der Kommentar-Schicht einer Vorlage*

---

## Negativbefunde (geprüft, ohne Befund)

**Alle 32 abgedruckten Kommandos in diesem Lauf nachgefahren — jedes liefert den abgedruckten
Wert.** Die Datei trägt **15** ` ```sh `-Zäune (auch eingerückte) mit zusammen **29** Kommandos,
dazu **drei** inline (Festlegung 3 und die zwei Geschichte-Zeilen). Die zwei Zahlen sind gemessen,
nicht gezählt:

```sh
grep -cE '^[[:space:]]*```sh$' docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md   # 15
awk '/^[[:space:]]*```sh$/{inb=1;cont=0;next} /^[[:space:]]*```$/{inb=0;next}
     inb{ l=$0; sub(/^[[:space:]]+/,"",l); if(l==""||l ~ /^#/) next;
          if(cont==0) n++; cont = (l ~ /\\$/) }
     END{print n}' docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md               # 29
```

**Keine Erwartungswerte.** Ergebnisse in der Reihenfolge der Datei: `1` · `1` (die zwei
Emitter-Kommentare, jetzt in Quell-Reihenfolge) · `1` · `1` (die zwei Baseline-Zitate in
`modul-06-roadmap.md`) · `3` · `2` (Anweisungssätze) · `3` · `2` (Go-Fundstellen über
`internal/ cmd/`) · die vierzeilige Klammer-Ausgabe · die einzeilige Lifecycle-Klammer · `4` · `3`
· `| 0.8.0 | 2026-07-21` · `2026-09-03` · `0` (keine vendored Vorlage) · `0` · `3` (die
Singleton-Messung) · `1` · `1` (der (a)-Beleg) · `1` · `0` (die (b)-Gegenprobe) · **2** Zeilen
`git log --follow`, beide `slice-177` · `2` · `1` · die zweizeilige Link-Ausgabe der zwei
Index-Vorlagen · `1` · `1` (Reconciliation) · `1` · `1` · `1` (die zwei `done/`-Ablagen) · `2`
(Register-Zähler) · `6` (Risiken ohne Ausgang). **Keine Abweichung.**

**Die zwei blockierenden Befunde der Vorrunde, einzeln am Ist-Stand nachgeprüft:**

- **M-1 (Runde 2) behoben — die Vorbedingung des Accept-Übergangs ist erfüllt.** Die Aussage über
  das Reconciliation-Register trägt jetzt alle drei Teile aus
  [ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 2, und zwar **zweimal**:
  Tag `v6.0.0` · `grundlagen-harness-dateien.md` §Verzeichniskonvention · Zitat, sowie Tag
  `v6.0.0` · `modul-02-harness-bootstrap.md` §Brownfield-Bootstrap: Schritt-Sequenz,
  Detail-Tabelle Schritte 5–9, Schritt 8 · Zitat. **Beide Abschnittsnamen existieren wörtlich** —
  `### Verzeichniskonvention` (`grundlagen-harness-dateien.md:4`) sowie
  `### Brownfield-Bootstrap: Schritt-Sequenz (Modul 2)` (`modul-02-harness-bootstrap.md:350`) mit
  `#### Detail-Tabelle (Schritte 5–9: Reconciliation-Phase)` und Schritt 8 in ihr (`:379`). Kein
  anderer Baseline-Beleg der Datei liegt unter der Form; damit steht
  [ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 3 (a) dem Statuswechsel
  **nicht mehr** entgegen.
- **M-2 (Runde 2) auf seiner Hauptachse behoben, mit einem Rest.** Der Halbsatz *„Ein Index ist
  eine Datei **in** einem angelegten Ort und fällt nicht unter das Subjekt"* ist **weg**; er steht
  im ganzen Dokument nur noch zweimal — einmal als **ausdrücklich verworfener** Grund (*„Und ein
  Satz der Art … trägt ihn ebenso wenig"*, `:407–411`) und einmal in der Geschichte-Zeile, die die
  Streichung protokolliert. Kein tragender Rest-Verweis
  (`grep -n 'angelegten Ort' …` → genau die Geschichte-Zeile). Der verbliebene
  *gegenstandslos*-Absatz ist **nicht** dieselbe Aussage: er hängt an Bedingung (b) — *„ob der Ort
  ohne den Bootstrap entsteht"* — und **hält der symmetrischen Anwendung stand**, in diesem Lauf
  geprüft: `docs/plan/adr/` und `docs/plan/carveouts/` entstehen bereits
  (`sed -n '/^func structureGitkeeps/,/^}/p' internal/emit/templates.go | grep -cE '"docs/plan/(adr|carveouts)"'`
  → **2**), `docs/plan/planning/observations/` entsteht **nicht**
  (`… | grep -c 'observations'` → **0**) — Festlegung 1 ist für die Indexe gegenstandslos und für
  Festlegung 2s eigenen Gegenstand einschlägig. **Die drei Stellen decken sich**: Festlegung 2
  (`:368–372`), Konsequenz 2 (`:492–498`) und die Contra-Zelle von Alternative E (`:486`) sagen
  übereinstimmend, dass die drei Bedingungen nur das *Ob* entscheiden und der Träger eine zweite
  Frage ist. Was aus dieser Klärung folgt und ungeklärt bleibt, ist M-3.

**Die vollständig beauftragte Prüfung der zwei `done/`-Orte (L-3 und Runde-1-L-4):**

- **Beide sind jetzt in der Datei genannt und entschieden** — Runde-1-L-4 und Runde-2-L-3 hatten
  ihr Fehlen gemeldet; das Fehlen ist behoben
  (`grep -c 'conventions/done' …` → **4**, `grep -c 'carveouts/done' …` → **4**, kein
  Erwartungswert).
- **Die Belege sind je in der dreiteiligen Form und verbatim** — in diesem Lauf gegen die Quelle
  gehalten: `templates/harness/conventions.template.md` §Adaptions-Block (Überschrift `:83`, Zitat
  `:88–89`, im **Rumpf** außerhalb jedes `<!-- -->`-Blocks — der Emit-Pfad strippt nur den
  `> **Template-Hinweis.**`-Blockquote, `StripHintBlock` in `internal/emit/templates.go`),
  `templates/docs/plan/planning/README.template.md` §Slices vs. Wellen (Überschrift `:26`, Zitat
  `:46–47`) und `templates/docs/plan/carveouts/carveout.template.md` §Verifikation (nach Auflösung)
  (Überschrift `:69`, Zitat `:77`; Kommentar-Lage → INFO-2).
- **Ob die Entscheidung trägt, ist zweimal *nein*, und in zwei verschiedenen Richtungen** — M-1
  (Rang-1- und DoD-Konflikt bei `docs/plan/carveouts/done/`) und M-2 (die geschriebene Regel deckt
  `harness/conventions/done/` nicht). **Das Ergebnis** — beide Orte draußen — ist damit **nicht**
  widerlegt; widerlegt ist, dass die Datei es aus dem herleitet, was in ihr steht.

**Die übrigen Posten beider Vorrunden, je am Ist-Stand geprüft:**

- **Runde-2-L-1 behoben (die Regel steht geschrieben), ihre Tragfähigkeit ist M-2.** Der Absatz
  *„Wie (a) ausgewertet wird"* existiert (`:277–284`) und beantwortet die Disjunktions-Frage, die
  L-1 stellte, ausdrücklich.
- **Runde-2-L-2 behoben.** Beide Geschichte-Zeilen datieren ihre Aussage über den fremden
  Plan-Stand (*„die §4 **am 2026-09-06** … führte"*, *„§6 trug **am selben Tag** sechs Risiken"*)
  und keine trägt eine undatierte Zahl darüber.
- **Runde-1-L-1 behoben.** Festlegung 3 zitiert die Zweifels-Regel aus
  [ADR-0007](../plan/adr/0007-bootstrap-phasen.md) verbatim — die Quelle sagt an `:88–89`
  *„jede emittierte Datei ist **genau einer** Klasse zugeordnet; im **Zweifel gilt
  `skip-if-present`** (nie Adopter-Inhalt clobbern — der sichere Default)"* — und stellt der
  Bestands-Messung ausdrücklich voran, dass die Klasse **nicht** aus ihr folgt.
- **Runde-1-L-2 behoben.** §Kontext (`:144–149`) und §Konsequenzen (`:514–517`) weisen den
  Handbuch-Nachzug jetzt gleich zu: der Historie-Eintrag bleibt, die Präsens-Aussage zieht der
  Slice nach.
- **Runde-2-INFO-1 bis INFO-5 behoben.** Das (b)-Kommando ist auf die Funktion des
  Mengen-Vergleichs verengt (beide `sed`-Bereiche jetzt
  `/^func TestTemplates_EmittierterBestandVollstaendig/,/^}/`, gemessen `1` und `0`); die
  Vorlagen-Hälfte des (a)-Belegs nennt Abschnitt und Rumpf-Lage; *„unberührt"* ist erklärt und an
  der Singleton-Klammer gemessen (`0` bzw. `3` — nachgefahren, die drei sind
  `docs/plan/planning/README.md` und die zwei `.harness/skills/*.md`); die widersprüchliche
  Halbaussage über INFO-1 ist aufgelöst (*„L-1 bis L-4 sowie INFO-2 und INFO-3 sind hier nicht
  behoben — **INFO-1 ist mitgezogen**"*); die zwei Emitter-Absätze stehen in Quell-Reihenfolge
  (`grep -n 'Im Adaptions-Block steht zu dieser Weiche\|GRENZE: LH-FA-02' internal/emit/templates.go`
  → **133**, **143**, und das Zitat führt sie in dieser Folge), und der `Bezug` trägt
  [ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md),
  [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
  und [`MR-036`](../../harness/conventions.md#mr-036--die-change-request-regel-bei-personalunion-steht-jetzt-in-der-adoptierten-baseline),
  während [ADR-0005](../plan/adr/0005-ziel-repo-distribution.md) jetzt auch im Rumpf steht
  (`grep -c 'ADR-0005' …` → **3**).
- **Der sechste Re-Evaluierungs-Trigger existiert und ist beobachtbar** (`:555–557`): *„Wenn ein
  Baseline-Sprung eine der zwei `done/`-Ablagen oder das Reconciliation-Register **unbedingt**
  führt *(am vendored Baum ablesbar)*"*. Alle sechs Trigger tragen eine Ablesestelle in Klammern.

**Die ausdrücklich beauftragte Prüfung des `codepath-missing`-Fixes — die Unterscheidung trägt.**
[ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 2 definiert *verbatim*
wörtlich als *„der Wortlaut ohne Auszeichnung, Whitespace normalisiert. Nicht die Quell-Bytes."*
und begründet das an ihrem eigenen ersten Fall, in dem die Quelle `ohne *Übergabe-Artefakt*`
schreibt und das Zitat die Sterne weglässt. Das Entfernen der Backticks ist damit **die** von der
Quelle beschriebene Form, keine Notlösung. Auch die Verwerfung der Kommando-Operand-Form hält: eine
Messung `[ -e docs/plan/planning/reconciliation.md ]` beträfe **diesen** Baum, während der Satz
über den **emittierten** Stand spricht — und die Fitness-Function-Tabelle führt die fehlende
Deckung zwischen emittiertem Text und emittiertem Bestand bereits als *nicht gebaut*. Was bleibt,
ist die Asymmetrie in INFO-1, nicht die Zulässigkeit.

**Sonstiges, geprüft ohne Befund:**

- **Gegen die Entscheidung selbst steht weiterhin kein Befund.** Die zwei Kern-Argumentationen
  ([ADR-0007](../plan/adr/0007-bootstrap-phasen.md) beantwortet *wie*, nicht *ob*;
  [ADR-0034](../plan/adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
  Festlegung 1 schreibt die `README.md` als Bestandteil der Ablage vor) sind unverändert und in
  Runde 1 gegen den Volltext gehalten; der emittierte Selbstwiderspruch ist in diesem Lauf erneut
  gemessen (`3` Anweisungssätze, `2` davon namentlich, `3` Go-Fundstellen, keine schreibend).
- **[`AGENTS.md`](../../AGENTS.md) §3.8 — Commit-Zuschnitt korrekt.**
  `git show --pretty=format: --name-only 2ded1ca` gibt **zwei** Dateien: die ADR und
  [`docs/plan/adr/README.md`](../plan/adr/README.md). Der ADR-Index gehört nach
  [ADR-0024](../plan/adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md) dem
  Architect; die Message nennt die Rolle im Präfix.
- **§3.4 nicht verletzt.** Die Datei steht auf `Proposed`; Überarbeitungen — auch die der zwei
  älteren Geschichte-Zeilen — sind in diesem Fenster zulässig, und
  [ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 3 verlangt die Korrektur
  ausdrücklich hier.
- **§3.10 gewahrt.** Der Commit berührt keine Plandatei; Folgepflicht 3 sagt ausdrücklich, dass
  Risiko-Ausgänge und Trigger-Zeile nicht von dieser ADR gesetzt werden. *(Dass Festlegung 4 die
  **Substanz** eines Risikos vorwegnimmt, das §6 dem Slice zuweist, ist M-1 und kein
  §3.10-Verstoß — die ADR schreibt nichts in den Plan.)*
- **§3.11 gewahrt.** Kein Pfad in den Planning-Lifecycle:
  `grep -noE 'docs/plan/planning/(open|next|in-progress|done)/'` liefert über der Datei **nichts**;
  die Links in den Planning-Baum zeigen auf `observations/…`, nach
  [ADR-0034](../plan/adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
  Festlegung 5 ortsfest.
- **§3.5 — keine Gate-Lockerung**, kein Schwellwert, kein `ignore`-Eintrag, keine
  Modul-Abschaltung berührt; die Datei trägt **null** `d-check:ignore`-Marker
  (`grep -c 'd-check:ignore' …` → **0**).
- **[`MR-001`](../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
  gewahrt.** `LH-FA-02` steht **20**× in der Datei, davon **15**× als Link
  (`grep -o 'LH-FA-02' … | wc -l`, `grep -o '\[`LH-FA-02`\](' … | wc -l`); die fünf übrigen sind
  Kommando-/Zitat-Zeilen in Codeblöcken und die `# `-Überschrift. `make docs-check` ist mit
  `ids: link-policy: always` grün.
- **[`MR-000`](../../harness/conventions.md#mr-000--baseline-aussage) — kein Adaptions-Eintrag
  fällig.** Keine der vier Festlegungen weicht von einer **Baseline**-Regel ab; die in M-3 genannte
  Abweichung betrifft den Rang-1-Satz dieses Repos, nicht die Baseline, und fällt damit nicht unter
  [`MR-000`](../../harness/conventions.md#mr-000--baseline-aussage).
- **[`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  und [`MR-033`](../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
  gewahrt.** Jede Zahl der Datei steht neben ihrem Kommando und ist als kein Erwartungswert
  gekennzeichnet — auch die zwei in dieser Nacharbeit neu hinzugekommenen (`0`/`3` an der
  Singleton-Klammer, `2` am `git log --follow`). Jede Baseline-Aussage nennt den Tag `v6.0.0`.
- **[`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) — kein
  halluziniertes Gate.** Die Fitness-Function-Tabelle ist unverändert;
  `TestTemplates_EmittierterBestandVollstaendig` existiert und vergleicht per Mengengleichheit
  gegen eine `want`-Liste, `make full-smoke` existiert und ist korrekt als Nicht-Gate ausgewiesen,
  und die zwei nicht gebauten Deckungen sind benannt statt behauptet.
- **Ziel-Form vollständig.** Gegen
  [`NNNN-titel.template.md`](../../.harness/baseline/v6.0.0/templates/docs/plan/adr/NNNN-titel.template.md)
  geprüft: Status · Datum · Autor · Bezug · Schärft · Regeln · Kontext · Entscheidung ·
  Verglichene Alternativen (fünf Optionen, *nichts tun* dabei) · Konsequenzen · Fitness Function ·
  Re-Evaluierungs-Trigger (sechs, je mit Ablesestelle) · Geschichte · Immutabilitäts-Schluss.
- **ADR-Index deckungsgleich.** Titel wortgleich mit der `# `-Überschrift, Status `Proposed`,
  Bezugs-Liste in **derselben Reihenfolge** wie der Kopf — die drei neuen Einträge
  ([ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md),
  [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler),
  [`MR-036`](../../harness/conventions.md#mr-036--die-change-request-regel-bei-personalunion-steht-jetzt-in-der-adoptierten-baseline))
  sind an denselben Positionen mitgezogen.
- **Docker-only (§3.9).** Kein Host-Paketmanager, keine Host-Toolchain in diesem Lauf; alles über
  `make`, `git`, `grep`, `sed`, `awk`, `ls`, `find`. Ein Versuch, diesen Report mit einem
  Host-Interpreter zu bearbeiten, ist vom PreToolUse-Guard geblockt worden und wurde nicht
  umgangen — die Korrektur lief über ein Neuschreiben der Datei.
- **Nicht geprüft (fremde Rolle):** DoD-Abhakung und Plan-vs-Code-Konformität — Verifikation,
  getrennter Kontext, anderes Prüf-Artefakt. Ebenso **nicht** Gegenstand: die parallel laufende
  `slice-125`-Arbeit.

---

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 3 |
| LOW | 1 |
| INFO | 2 |

**Finding-Klassen dieses Laufs:** *Entscheidung verwirft eine Plan-Prämisse, ohne sie zu nennen* ·
*Kriterium wird angewandt, ohne dass seine Auswertungs-Regel den Fall trägt* · *Erklärte Abweichung
ohne die Einordnung, die dasselbe Dokument für seinen anderen Gegenstand trifft* · *Zitat gekürzt
ohne Auslassungsmarke* · *Gate-Grün einer Pfad-Nennung hängt am Dogfood-Bestand, nicht am
beschriebenen Stand* · *Beleg lebt nur in der Kommentar-Schicht einer Vorlage*

**Das Muster aus Runde 2 ist nicht geschlossen, sondern versetzt — und das ist die Antwort auf die
ausdrücklich gestellte Frage.** *„Das Kriterium verspricht eine Reichweite, die sein geschriebener
Text nicht hat"* lief in Runde 2 dreimal (Träger-Frage, ungeschriebene Auswertungs-Regel, zweiter
`done/`-Ort). Die Nacharbeit hat zwei der drei Instanzen an ihrer damaligen Stelle beseitigt: die
Träger-Frage ist aus dem Kriterium herausgenommen und an drei deckungsgleichen Stellen benannt, und
die Auswertungs-Regel steht geschrieben. Sie ist damit **nicht mehr abwesend, sondern zu eng**: sie
führt zwei Disqualifikations-Formen und entscheidet die drei Ausschlüsse über eine dritte, in ihr
nicht vorkommende (M-2). Und die Herausnahme der Träger-Frage hat die Abweichung, die vorher
unbenannt in der Zusage steckte, sichtbar gemacht, ohne sie einzuordnen (M-3). Zusammen mit
Runde 1 und Runde 2 ist das die **fünfte und sechste** Wiederholung derselben Klasse über drei
Läufe — nach der Kontext-Eskalation des Reviewer-Skills längst ein Steering-Loop-Signal. Die
Vergabe eines Register-Belegs gehört in die Slice-Closure, nicht in diesen Report
([`AGENTS.md`](../../AGENTS.md) §3.10).

**Was sich gegenüber Runde 2 verschoben hat.** Die **Zahl** der blockierenden Befunde steigt von
zwei auf drei, ihre **Bauart** ändert sich: Runde 2 fand einen liegen gelassenen Alt-Posten und
einen aus der Nacharbeit. Diese Runde findet **keinen** Alt-Posten mehr — jeder Posten beider
Vorrunden ist am Ist-Stand adressiert, und der eine, den eine aktive ADR zur Vorbedingung des
Statuswechsels macht, ist erfüllt. Alle drei MEDIUM sind **aus dieser Nacharbeit entstanden**, zwei
davon (M-1, M-3) an Text, den es vor `2ded1ca` nicht gab. Die Zahl der Befunde gegen die
Entscheidung selbst bleibt **null**.

---

## Verdikt

**Konsistenz NICHT BESTÄTIGT — drei blockierende MEDIUM, kein HIGH.**

**Was trägt, und es ist erneut deutlich mehr als in der Vorrunde.** Alle **32** abgedruckten
Kommandos reproduzieren ohne Abweichung. Der Posten, den
[ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 3 (a) zur **Vorbedingung
des `Accepted`-Übergangs** macht, ist erledigt: die Regelwerks-Aussage über das
Reconciliation-Register trägt Tag, Datei, Abschnitt und Zitat, zweifach und gegen die Quelle
gehalten. Die Streichung des gefallenen Grundes ist sauber — er steht nur noch als ausdrücklich
verworfen und in der Geschichte. Der Ersatz hält der symmetrischen Anwendung stand, die den
Vorgänger zu Fall brachte, und die drei Stellen, die die *Ob*-gegen-*Träger*-Grenze ziehen, decken
sich wörtlich. Der `codepath-missing`-Fix ist an der zitierten Quelle geprüft und zulässig. Und
gegen die **Entscheidung** — der Bootstrap stellt den Tag-0-Zustand her, die Aufzählung nennt
Instanzen — steht in drei Läufen kein einziger Befund.

**Was blockiert, entsteht durchweg aus dieser Nacharbeit, und zwei der drei betreffen Rang 1.**
**M-1:** Der neue Ausschluss von `docs/plan/carveouts/done/` trifft einen Ort, den die
Rang-1-Klammer nennt, den §3 des bedienten Slice ausdrücklich als *„damit gedeckt"* führt und den
seine **DoD (1)** namentlich verlangt — die Datei erwähnt weder die Klammer-Deckung noch die DoD
und sagt an keiner Stelle, dass sie die Plan-Prämisse verwirft, während sie elf Absätze früher
zusagt, es werde keine Zusage zurückgenommen. **M-2:** Die neu geschriebene Auswertungs-Regel führt
zwei Disqualifikations-Formen und entscheidet die Ausschlüsse über eine dritte; für
`harness/conventions/done/` bleibt eine unbedingte Nennung im **eigenen (a)-Kronzeugen-Zitat**
unentkräftet. **M-3:** Die Datei sagt jetzt zweimal, dass sie von der `.gitkeep`-Vorgabe des
Rang-1-Satzes abweicht, und ordnet diese eine Abweichung nirgends als Erfüllung oder
Vertragsänderung ein — während sie genau diese Einordnung für den Gegenstand trifft, der **nicht**
abweicht.

**Warum das vor der Annahme zählt und nicht danach.** Alle drei sind Sätze, keine Entscheidungen:
ein Satz, der die verworfene Plan-Prämisse benennt; eine dritte Zeile in der Auswertungs-Regel;
eine Einordnung der erklärten Abweichung. Ab `Accepted` sperrt
[`AGENTS.md`](../../AGENTS.md) §3.4 jede davon, und der Preis steigt von einer Zeile auf eine
Folge-ADR mit `Supersedes` — dieselbe Kosten-Asymmetrie, mit der
[ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 3 (a) ihren
Accept-Übergang begründet. Bei M-1 kommt hinzu, dass die Gegenseite des Widerspruchs — die DoD —
**Planner**-Arbeit ist ([`AGENTS.md`](../../AGENTS.md) §3.10): Wird sie erst nach dem Einfrieren
sichtbar, muss der Planner sein Abnahmekriterium gegen eine unveränderliche ADR nachziehen, statt
ein Übergabe-Artefakt zu bekommen.

**Über den `Accepted`-Übergang entscheidet dieser Report nicht** — das ist Architect-Arbeit
([`AGENTS.md`](../../AGENTS.md) §3.8). Er stellt fest: **der Übergang ist heute nicht möglich.**
Der Posten, der ihn hält, ist **M-1** — ein Ausschluss gegen den Rang-1-Satz und gegen ein
Abnahmekriterium des Slice, den diese ADR bedient; **M-2** und **M-3** halten ihn daneben, jeder
für sich. Der Posten, der ihn in Runde 2 hielt, hält ihn **nicht mehr**:
[ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 3 (a) ist erfüllt.

**Der Baseline-Trigger feuert mit diesem Verdikt nicht.** *„ADR-Review-Runde abgeschlossen →
bindend"* (Baseline `v6.0.0`, `grundlagen-bootstrap.md` §Vier Trigger-Klassen, Zeile der
Acceptance-Trigger-Klasse,
`grep -c 'ADR-Review-Runde abgeschlossen → bindend' .harness/baseline/v6.0.0/regelwerk/grundlagen-bootstrap.md`
→ **1**, kein Erwartungswert) setzt eine abgeschlossene Runde voraus; diese Runde schließt mit drei
blockierenden Befunden. **`slice-190` kann `open → next` damit weiterhin nicht** — nicht, weil die
Change-Request-Frage aus §3 unbeantwortet wäre (Festlegung 1 beantwortet sie), sondern weil die
Antwort noch nicht bindend ist und M-1 zusätzlich einen DoD-Punkt desselben Slice betrifft.

**Übergabe.** Die Findings gehen an den **Architect** — er hält die ADR
([`AGENTS.md`](../../AGENTS.md) §3.8), und dieser Report hat kein Artefakt außer sich selbst
angefasst. **M-1 trägt zusätzlich eine Kante an den Planner:** Verwirft der Architect die
Plan-Prämisse bewusst, ist die Folge eine Änderung an §1/§3 und an **DoD (1) und (3)** von
`slice-190`, und die schreibt nach [`AGENTS.md`](../../AGENTS.md) §3.10 der Planner — dieser
Report schreibt sie nicht und schlägt sie nicht vor. Die Finding-Klassen gehen in die
Slice-Closure §7 und von dort in den Zähler; die Zuordnung zu einer `BEO-ALL/<slug>` fällt beim
Schreiben der Closure, nicht hier
([`docs/plan/planning/observations/README.md`](../plan/planning/observations/README.md)).

Dieser Report ist ein **Lauf-Beleg** und ersetzt keine Verifikation — DoD-/Spec-Konformität prüft
der Verifier separat (Modul 11, anderes Prüf-Artefakt, anderer Eingabe-Kontext).
