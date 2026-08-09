# ADR-0015: Norm-Artefakte haben eine schreibende Rolle, und der Commit zeigt sie

**Status:** Proposed

**Datum:** 2026-08-09

**Autor:** ai-harness-init-Team (pt9912)

**Bezug:**
[`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) (die emittierte
Doc-Chain — die Ebene, an der diese Entscheidung ausdrücklich nichts ändert),
[ADR-0012](0012-haupt-kontext-ohne-token-bilanz.md) (die einzige bisherige Zuweisung
eines Artefakts an eine Rolle: *„Der Slice-Plan gehört dem Planner"*),
[ADR-0014](0014-aufgehobener-eintrag-kopf-statt-rumpf.md) (die Schwester-Entscheidung
über die Form desselben Konventionsdokuments)

**Schärft:** — Prozess-ADR ohne Spec-Stratum: sie regelt, wer welches Dokument schreibt,
nicht was in einem Dokument steht.

---

## Kontext

Das Regelwerk gibt die Rollen-Sequenz und ihre neun Übergaben
(`.harness/baseline/v3.5.2/regelwerk/modul-08-agentenrollen.md`, §Rollen-Sequenz:
*„keine Rolle springt rückwärts in eine vorhergehende, ohne Übergabe-Artefakt"*;
§Rollen-Regeln: *„Rollen-Trennung ist Kontext-Trennung … aber nicht im selben
Kontextfenster"*). Für **ADRs** benennt es die schreibende Rolle namentlich
(*„Architect schreibt; Reviewer prüft auf Konsistenz; Implementer liest als Constraint"*).
Für die übrigen normativen Artefakte dieses Repos tut es das nicht — es kennt sie nicht,
weil sie repo-lokal sind.

**Die Klasse, dreimal gemessen, jedes Mal eine Ebene höher.** In einem einzigen Slice
wurde dreimal ein Artefakt einer anderen Rolle im Implementations-Kontext geändert:

| # | Artefakt | Commit | Befund-Stufe |
|---|---|---|---|
| 1 | Definition of Done des laufenden Slice | `95952b1` (2026-08-08) | HIGH (Plan-Review) |
| 2 | Kandidaten-Tabelle der Roadmap | `4aa910a` (2026-08-08) | MEDIUM (Code-Review) |
| 3 | Hard Rule in [`AGENTS.md`](../../../AGENTS.md) §3 **und** ein Eintrag des Adaptions-Blocks | `f7f086e` (2026-08-08) | MEDIUM (Bestätigungsrunde) |

`git log -S'### 3.' -- AGENTS.md` liefert **drei** Commits (Bootstrap `d30db38`, `c0e9955`,
`f7f086e`), selbst gezählt.

**Der Schaden ist nicht hypothetisch, er ist materialisiert.** Der dritte Fall setzte eine
repo-weite Norm samt Adaptions-Eintrag in Kraft, die eine **Abweichung von der Baseline
behauptet, die es nicht gibt**: gegen den Upstream-Tag `v5.3.0` selbst gemessen
(`git show v5.3.0:lab/templates/AGENTS.template.md`) trägt Zeile 150 dort die Überschrift
`### 3.7 Ein Kommentar beschreibt, was da ist` — identische Nummer, identischer Titel, im
Hard-Rules-Block —, und `lab/regelwerk/grundlagen-harness-dateien.md:100` nennt sie
ausdrücklich *„Hard Rule"*. Gemessen worden war gegen `v5.1.0` (dort **0** Treffer für
`^### 3.7`); zwischen Messung und Niederschrift erschienen `v5.2.0` und `v5.3.0`, und die
Aussage nannte ihre Mess-Version nicht. Ein zweiter Kontext hätte das in einem
`git show`-Lauf gefunden — genau die Eigenschaft, für die Rollen-Trennung existiert.

**Der Auslöser ist in allen drei Fällen legitim, der Weg war es nicht.** Jede der drei
Änderungen erfolgte auf ausdrückliche Anweisung des Auftraggebers. Diese Lage ist im Repo
bereits einmal entschieden worden, für ein anderes Artefakt:
[`MR-015`](../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
hält fest, dass dieses Repo keinen externen Auftraggeber hat — *„es ist sein eigener. Die
Auftraggeber-**Rolle** ist besetzt (der Nutzer), nur die **Ticket-Form** fehlt"* —, und
löst das nicht durch ein Verbot, sondern durch **Ablesbarkeit**: der annehmende Akt geht
der Umsetzung voraus, und die Trennung steht im Commit, nicht in der Prosa.

**Warum die Träger-Frage mitentschieden werden muss.** Modul 10 §Ziel-Form ¶Pflege verlangt
bei dreimaligem gleichem Finding *„Klassifikation schärfen / Folge-ADR bzw.
`AGENTS.md`-Update / Gate"* — einen Träger, kein viertes Einzel-Finding. Wo dieser Träger
**nicht** liegen darf, ist gemessen: die drei kanonischen Lehr-Formen stehen 57-mal in 32
Dateien unter `docs/plan/planning/done/`, und das Wort *Lerneintrag* kommt in
[`AGENTS.md`](../../../AGENTS.md), [`harness/conventions.md`](../../../harness/conventions.md),
[`harness/README.md`](../../../harness/README.md) und `.harness/skills/reviewer.md`
**nullmal** vor (eigene Zählung, alle vier bestätigt). Wo er liegen darf, ist ebenfalls
gemessen, und zwar als **falsifizierbare Vorhersage des Repos an sich selbst**: die
Commit-Message von `c0e9955` begründet, warum Hard Rule 3.6 **nicht** dupliziert wurde
(*„weder in `.claude/commands/implement-slice.md` noch in `conventions.md` noch im
Reviewer-Skill … Ob der eine Ort trägt, ist damit selbst prüfbar"*). Die Klasse dieser ADR
ist seither nicht in [`AGENTS.md`](../../../AGENTS.md) gelandet — sie steht allein im
vendored Modul 8, das on-demand gelesen wird, und in **einer** Zeile des Implementer-Kommandos.

**Annahme, auf der diese Entscheidung steht:** die Auftraggeber-Anweisung bleibt eine
legitime Quelle einer Norm, und der Preis der Rollen-Trennung ist ein Kontext-Wechsel, kein
Verzicht. Kippt sie — etwa weil ein externer Auftraggeber entsteht und der Weg über den
Change Request führt —, kippt Festlegung 2.

## Entscheidung

**Wir wählen Option C: jedes Norm-Artefakt bekommt eine schreibende Rolle, die Anweisung
bleibt erlaubt, und die Trennung von Entscheidung und Umsetzung wird am Commit ablesbar.**
Vier Festlegungen:

1. **Eigentums-Karte.** Jedes normative Artefakt dieses Repos hat genau **eine** schreibende
   Rolle. Wo eine Quelle sie bereits benennt, wird sie zitiert, nicht neu gesetzt:

   | Artefakt | schreibende Rolle | Quelle |
   |---|---|---|
   | [`spec/lastenheft.md`](../../../spec/lastenheft.md) | Auftraggeber (Change Request) | [`MR-015`](../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) |
   | [`spec/spezifikation.md`](../../../spec/spezifikation.md), [`spec/architecture.md`](../../../spec/architecture.md) | Architect | [ADR-0013](0013-technik-stratum-als-zielort.md), Modul 4 |
   | `docs/plan/adr/` | Architect | Modul 8 §Rollen-Regeln |
   | [`AGENTS.md`](../../../AGENTS.md) §3 (Hard Rules) | **Architect** | **hier entschieden** |
   | [`harness/conventions.md`](../../../harness/conventions.md) §Adaptions-Block | **Architect** | **hier entschieden** |
   | `docs/plan/planning/` (Slice-Plan, DoD, Roadmap, Closure-Notiz) | Planner | [ADR-0012](0012-haupt-kontext-ohne-token-bilanz.md), Modul 5/6 |
   | `.harness/skills/` | Reviewer | Modul 8 §Konflikt-Pfad (*„R aktualisiert Skill-Datei"*) |
   | Code, Tests, `Makefile`, [`harness/tools/`](../../../harness/tools/) | Implementer | Modul 9 |
   | `.harness/baseline/` | **keine** — vendored Fremd-Blob | [`MR-007`](../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) |

   **Begründung der zwei hier entschiedenen Zeilen:** Der Adaptions-Block ist das
   Abweichungs-Register; ob eine Abweichung von der Baseline *besteht*, ist eine
   Architektur-Frage, und der oben gemessene Fall belegt, was ihre Beantwortung in einer
   anderen Rolle kostet. Die Hard Rules sind derselbe Gegenstand eine Ebene allgemeiner.
   Modul 8 spricht für ADRs genau diese Dreiteilung aus — *Architect schreibt, Reviewer
   prüft auf Konsistenz, Implementer liest als Constraint* —, und beide Artefakte sind
   normativ wie eine ADR, nur ohne deren Immutabilität.

2. **Die Anweisung des Auftraggebers ist eine legitime Quelle, aber nie die Ausführung.**
   Entsteht der Bedarf mitten in einem Lauf, ist der **Ausgang** der Rolle, die gerade läuft,
   ein **Übergabe-Artefakt** — ein benannter Posten im Plan, ein Finding, ein
   ADR-Vorschlag —, nicht der Norm-Text. Formuliert wird die Norm im Kontext der
   schreibenden Rolle. Das ist kein neuer Mechanismus: es ist
   [`MR-015`](../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
   Setzung 1 (*„die Trennung der Entscheidung von der Umsetzung"*), angewandt auf die
   übrigen Norm-Artefakte.

3. **Ablesbar am Commit, nicht an der Prosa.** Eine Änderung an einem Artefakt aus der
   Karte landet in einem **eigenen Commit**, der **ausschließlich** Artefakte derselben
   schreibenden Rolle berührt und die Rolle in seiner Message nennt. Damit ist die Frage
   *„aus welchem Kontext stammt diese Norm?"* nachträglich mechanisch beantwortbar
   (`git log --format='%h %s' -- <pfad>` + `git show --stat`) statt nur behauptet.
   **Cutoff: geprüft wird ab dem Commit, der diese ADR annimmt.** Die Historie wird nicht
   nachgezogen — dieselbe Begründung wie in
   [`MR-015`](../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler):
   ein Maßstab, der den Bestand mitprüfte, wäre dauerhaft rot und entwertete die Setzung,
   statt sie zu tragen.

4. **Der Träger liegt an genau einem Ort im Lauf-Kontext.** Die Regel wird als Hard Rule in
   [`AGENTS.md`](../../../AGENTS.md) §3 verkörpert — dem einzigen Norm-Ort, den jede Rolle
   in jedem Lauf liest — und **nicht** zusätzlich in `.claude/commands/`, in
   [`harness/conventions.md`](../../../harness/conventions.md) oder in `.harness/skills/`
   dupliziert. Der Adaptions-Block ist für sie **nicht** das Gefäß: sie weicht von der
   Baseline nicht ab, sie konkretisiert Modul 8 für die Artefakt-Menge dieses Repos, und ein
   Eintrag über eine Nicht-Abweichung ist genau der Fehler, den der dritte gemessene Fall
   gemacht hat.

**Was hier NICHT entschieden ist:** der Wortlaut der Hard Rule (Folgepflicht 1), und ob eine
Rolle ein fremdes Artefakt **lesen** darf — sie darf, uneingeschränkt; die Karte regelt das
Schreiben.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — **nichts tun**, die Klasse als viertes Einzel-Finding führen | kein neuer Mechanismus; jeder Fall wird einzeln abgewogen | Modul 10 §Pflege verlangt nach der dritten Wiederholung ausdrücklich einen Träger. Der gemessene Preis steht schon im Pflicht-Lesepfad: eine erfundene Baseline-Abweichung in [`AGENTS.md`](../../../AGENTS.md) §3 und in einem Adaptions-Eintrag, entstanden ohne zweiten Kontext |
| B — **Verbot**: kein rollen-fremdes Artefakt im Implementations-Kontext, ohne Ausgang | kürzest formulierbar; keine Karte zu pflegen | Alle drei gemessenen Fälle entstanden aus einem realen Bedarf auf ausdrückliche Anweisung. Eine Regel, die nur verbietet und keinen Weg nennt, wird unter Druck ein viertes Mal gebrochen — und die Klasse hat sich bereits **aufwärts** bewegt (DoD → Roadmap → repo-weite Norm) |
| **C — Eigentums-Karte + Anweisung bleibt Quelle + Ablesbarkeit am Commit (gewählt)** | benennt für jedes Artefakt eine Rolle, statt nur eine Bewegungsrichtung zu verbieten; übernimmt eine im Repo bereits bewährte Konstruktion ([`MR-015`](../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)) statt eine neue zu erfinden; die Einhaltung ist an `git` ablesbar, nicht nur behauptbar | kostet pro Norm-Änderung einen Kontext-Wechsel und einen eigenen Commit. Die Karte ist Pflege-Gegenstand: ein neues Norm-Artefakt ohne Zeile ist eine Lücke, die kein Sensor meldet |
| D — Träger als **Lerneintrag** in der Closure-Notiz | billigster Weg; der vorgesehene Ort für geschärfte Regeln nach Modul 5 | gemessen wirkungslos: 57 Lehr-Einträge in 32 `done/`-Dateien, und keines der vier sitzungsfesten Live-Artefakte kennt das Wort. Dieselbe Beobachtung stand schon in der Commit-Message von `c0e9955` (*„Dort liest sie niemand wieder"*) |
| E — Träger im **Implementer-Kommando** (`.claude/commands/implement-slice.md`) | trifft die Rolle, die dreimal betroffen war, an ihrem Anweisungssatz | Die Regel bindet **alle** Rollen, nicht nur eine — und die Datei trägt die Sequenz-Zeile bereits, ohne dass sie die drei Fälle verhindert hätte. Eine zweite Kopie neben [`AGENTS.md`](../../../AGENTS.md) ist die Drift-Fläche, die `c0e9955` ausdrücklich vermieden hat |

## Konsequenzen

- **Positiv:** die Frage *„durfte dieser Lauf das schreiben?"* ist vor der Änderung
  beantwortbar statt danach als Finding. Für die zwei bisher unbesetzten Artefakte steht
  eine Rolle da, wo vorher nichts stand.
- **Positiv:** eine Norm, die eine Aussage über die Baseline trifft, entsteht künftig im
  Kontext, dessen Aufgabe das Nachmessen ist. Der gemessene Fehlerfall (`v5.1.0` gemessen,
  `v5.3.0` behauptet, Version nicht genannt) ist genau die Klasse, die ein zweiter
  Eingabe-Kontext fängt.
- **Negativ, und das ist der Preis:** eine Norm-Änderung unterbricht den laufenden Slice.
  Wer sie sofort will, bekommt sie nicht sofort — er bekommt ein Übergabe-Artefakt und einen
  zweiten Lauf.
- **Negativ:** Festlegung 3 hat **keinen Wächter**. `.d-check.yml` führt
  `modules: [links, anchors, ids, matrix, codepaths, spans]` — keines davon liest Commits;
  `make comment-claims` prüft Sensor-Namen und lässt jede Markdown-Datei außen vor. Die Regel
  liegt damit im Feedforward-Quadranten, wie
  [`MR-015`](../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
  Setzung 2 auch — das ist benannt, nicht geschlossen.
- **Negativ:** die Eigentums-Karte altert. Entsteht ein neues Norm-Artefakt, fehlt seine
  Zeile still; kein Gate zählt die Menge der Norm-Artefakte gegen die Menge der Zeilen.
- **Folgepflicht 1 — der Hard-Rule-Text.** Mit der Annahme schreibt der **Architect** die
  Regel als Hard Rule nach [`AGENTS.md`](../../../AGENTS.md) §3, in der Modul-9-Form
  (Falsch/Richtig plus Begründung), in einem eigenen Commit. Diese ADR trägt die Abwägung,
  die Hard Rule den Wortlaut.
- **Folgepflicht 2 — kein Eintrag im Adaptions-Block.** Die Regel weicht von der Baseline
  nicht ab; ein Eintrag dort wäre eine erfundene Abweichung und verstieße gegen den Zweck,
  den [`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage) dem Block gibt.
- **Folgepflicht 3 — die emittierte Ebene bleibt unberührt, und das ist eine Entscheidung.**
  Ein Zielrepo erhält `AGENTS.md` und die Workflow-Commands aus den vendored Vorlagen; ob
  ein erzeugtes Repo eine Eigentums-Karte bekommt, entscheidet der Slice, der die Tool-Ebene
  entscheidet — nicht diese ADR. Die Karte nennt Artefakte, die es dort teils nicht gibt.

## Fitness Function (falls maschinell prüfbar)

| Tooling | Regel | Make-Target |
|---|---|---|
| — | **keine.** Festlegung 3 ist mechanisierbar (ein Commit, der ein Artefakt der Karte gemeinsam mit Artefakten einer anderen Rolle ändert, ist der Befund), **gebaut ist sie nicht** | — |

**Was hier bewusst NICHT steht.** Erstens ein Gate über die Eigentums-Karte: die Zuordnung
Rolle→Artefakt ist keine Eigenschaft, die ein Doc-Gate liest. Zweitens ein Sensor über
Festlegung 3 — er müsste **Commits** lesen, und kein Modul der heutigen `.d-check.yml`-Konfiguration
tut das; ein Sensor dafür ist ein Roadmap-Kandidat, keine Zusage dieser ADR. Drittens ein Fall in
`test/mutations/`: der Mutations-Treiber kennt zwei Fehlschlag-Formen (`--- FAIL:` der Go-Stufe,
`not ok N` der bats-Stufe) und keine Form, in der ein Commit-Zuschnitt rot wird. Behauptet wird
hier also **kein** Gate ([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).

## Re-Evaluierungs-Trigger

- **Wenn die Klasse ein viertes Mal auftritt, obwohl der Träger steht** *(feedforward — am
  Review-Bestand ablesbar)*: dann trägt der Ort nicht, und Festlegung 4 ist falsch — nicht
  die Wiederholung ist dann der Befund, sondern die Trägerwahl. Das ist dieselbe
  falsifizierbare Form, die `c0e9955` für Hard Rule 3.6 aufgestellt hat.
- **Wenn ein externer Auftraggeber entsteht** *(feedforward)*: dann führt der Weg über den
  Change Request, und Festlegung 2 ist gegen
  [`MR-015`](../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
  Setzung 3 neu zu schneiden.
- **Wenn die Re-Baseline eine eigene Eigentums- oder Rollen-Aussage mitbringt**
  *(feedforward — eine Textänderung upstream, kein Sensor)*: dann ist gegen die
  Upstream-Fassung zu halten; deckt sie sich, wird diese ADR durch eine Nachfolge-ADR mit
  *Supersedes* auf den Baseline-Abschnitt zurückgeführt.
- **Wenn ein Commit-Sensor gebaut wird** *(feedforward)*: dann ist die Cutoff-Begründung aus
  Festlegung 3 neu zu prüfen — sie ruht darauf, dass der Bestand ungemessen bleibt.
- **Wenn ein neues Norm-Artefakt ohne Zeile in der Karte entsteht** *(feedforward — die
  Entscheidung fällt beim Anlegen)*: dann ist die Karte unvollständig, und die Zeile gehört
  in eine Nachfolge-ADR, nicht in eine Nachbesserung dieser hier
  ([`AGENTS.md`](../../../AGENTS.md) §3.4).

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-08-09 | **Proposed** | Architect-Verdikt auf eine Reviewer-Eskalation nach Modul 10 §Pflege; Anlass war die dritte gemessene Instanz derselben Rollen-Klasse in einem einzigen Slice, die zweite davon mit einer falschen Baseline-Aussage als materialisiertem Schaden |
