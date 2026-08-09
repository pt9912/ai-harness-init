# ADR-0015: `AGENTS.md` §3 und der Adaptions-Block gehören dem Architect

**Status:** Proposed

**Datum:** 2026-08-09

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[`MR-015`](../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
(die Konstruktion, die hier auf zwei weitere Artefakte reicht),
[ADR-0014](0014-aufgehobener-eintrag-kopf-statt-rumpf.md) (die Schwester-Entscheidung über die
**Form** desselben Konventionsdokuments; diese hier entscheidet, **wer** es schreibt),
[ADR-0016](0016-verweis-traegt-tag-und-zitat.md) (die Form, in der die Belege unten stehen)

**Schärft:** — Prozess-ADR ohne Spec-Stratum.

---

## Kontext

### Was die Baseline regelt — und was sie nicht regelt

Das Regelwerk benennt die schreibende Rolle für **ADRs** namentlich (Regelwerk `v3.5.2`,
`modul-08-agentenrollen.md` §Rollen-Regeln: *„ADR-Änderung: Architect schreibt; Reviewer prüft
auf Konsistenz; Implementer liest als Constraint"*) und setzt die Übergabe-Pflicht
(§Rollen-Sequenz für einen Slice: *„keine Rolle springt rückwärts in eine vorhergehende, ohne
Übergabe-Artefakt"*). Für `AGENTS.md` und `harness/conventions.md` tut es das nicht.

**Gemessen gegen den Ziel-Stand, über alle 26 Regelwerk-Dateien** (`v5.3.1`,
`git grep -nEi 'auftraggeber|anweisung|weisung|change request' … lab/regelwerk` sowie dieselbe
Suche über `commit` und über `AGENTS\.md` mit Rollen-Filter):

- **Keine Datei benennt eine schreibende Rolle für `AGENTS.md` oder `harness/conventions.md`.**
- Die eine Stelle, die `AGENTS.md` einer Rolle zuordnet, tut es auf einer **anderen Achse**:
  `modul-08-agentenrollen.md` §Welche Rolle braucht welche Artefaktklasse führt
  *„**Briefing** (`AGENTS.md` + 8-Schritt-Workflow) … Implementer"* — die Tabelle sagt, welche
  Artefaktklasse eine Rolle **führt**, nicht wer sie **schreibt**. Sie als Eigentums-Aussage zu
  lesen kehrte die Frage genau um.
- §Rollen-Sequenz für eine Welle, Closure-Schritt 3b (*„Verkörperung | Planner → Architect →
  Planner"*) regelt den **Steering-Loop-Weg** in eine verkörperte Regel. Er stand bereits bei
  `v5.3.0` und ist zu `v5.3.1` byte-gleich. Eine Norm-Änderung, die **außerhalb** dieses Wegs
  entsteht — etwa ein Eintrag des Adaptions-Blocks aus dem Freshness-Audit nach Modul 2 —, fällt
  nicht darunter; jene Prozedur nennt **keine** Rolle.

### Was die Baseline dagegen sehr wohl regelt

`grundlagen-source-precedence.md` §Spec-Stratifizierung (`v5.3.1`) trägt die Konstruktion, auf der
[`MR-015`](../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
in diesem Repo beruht, im Wortlaut:

> *„Fallen Auftraggeber- und Entwickler-Rolle zusammen, fehlt nicht der Vorgang, sondern nur seine
> Ticket-Form … der annehmende Akt ist die Entscheidung, die vor der Umsetzung fällt. Was die
> Regel trägt, ist nicht die Externalität, sondern die Trennung von Entscheidung und Umsetzung —
> und die ist auch ohne Ticket herstellbar. Der Träger ist dann der Commit: Ein angenommener
> Change Request ändert in einem eigenen Commit ausschließlich das Lastenheft und liegt vor dem
> Slice, der ihn umsetzt … Nachträglich ablesbar an `git log -- spec/lastenheft.md`."*

**Damit ist beides schon gesetzt:** dass die Anweisung eine legitime Quelle ist, deren annehmender
Akt der Umsetzung vorausgeht — und dass der Commit ihr Träger ist. Auch die fehlende Mechanik
steht dort: *„Ein Sensor dafür existiert nicht (kein d-check-Modul prüft, welche Dateien ein
Commit zusammen anfasst); es bleibt ein Review-Griff."*

**Der Geltungsbereich ist aber `spec/lastenheft.md`** — das einzige Artefakt mit einem externen
Change-Request-Weg. Für die übrigen Norm-Artefakte sagt die Baseline nichts.

### Der Anlass, gemessen

In einem einzigen Slice wurde dreimal ein Artefakt einer anderen Rolle im
Implementations-Kontext geändert — Definition of Done des laufenden Slice (`95952b1`),
Kandidaten-Tabelle der Roadmap (`4aa910a`), Hard Rule in [`AGENTS.md`](../../../AGENTS.md) §3
**und** ein Eintrag des Adaptions-Blocks (`f7f086e`), alle 2026-08-08. Die Klasse bewegte sich
dabei **aufwärts**: DoD → Roadmap → repo-weite Norm.

**Der Schaden des dritten Falls ist materialisiert, nicht hypothetisch.** Er setzte eine Norm samt
Adaptions-Eintrag in Kraft, die eine **Abweichung von der Baseline behauptet, die es nicht
gibt**: gegen den Upstream-Tag `v5.3.0` selbst gemessen
(`git show v5.3.0:lab/templates/AGENTS.template.md`) trägt Zeile 150 dort die Überschrift
`### 3.7 Ein Kommentar beschreibt, was da ist` — identische Nummer, identischer Titel, im
Hard-Rules-Block. Gemessen worden war gegen `v5.1.0` (dort **0** Treffer für `^### 3.7`);
zwischen Messung und Niederschrift erschienen `v5.2.0` und `v5.3.0`, und die Aussage nannte ihre
Mess-Version nicht. Ein zweiter Kontext hätte das in einem `git show`-Lauf gefunden — genau die
Eigenschaft, für die Rollen-Trennung existiert.

**Der Auslöser war in allen drei Fällen legitim, der Weg war es nicht:** jede Änderung erfolgte
auf ausdrückliche Anweisung des Auftraggebers.

## Entscheidung

**Wir wählen Option C: die zwei Norm-Artefakte, für die keine Quelle eine schreibende Rolle
benennt, bekommen eine — und die Commit-Konstruktion der Baseline gilt für sie wie für das
Lastenheft.** Zwei Festlegungen:

**1. `AGENTS.md` §3 (Hard Rules) und der Adaptions-Block in `harness/conventions.md` werden vom
Architect geschrieben.** Über die übrigen Norm-Artefakte trifft diese ADR **keine** Aussage —
sie bestätigt keine fremde Zuordnung und setzt keine neue. Wo eine Quelle die schreibende Rolle
benennt, gilt sie unverändert; wo keine sie benennt, bleibt das eine offene Frage, die diese
Verengung ausdrücklich stehen lässt. Eine abgeschriebene Übersicht wäre eine zweite Fassung, die
driftet.

**Begründung für genau diese zwei:** Der Adaptions-Block ist das Abweichungs-Register; ob eine
Abweichung von der Baseline *besteht*, ist eine Architektur-Frage, und der gemessene Fall belegt,
was ihre Beantwortung in einer anderen Rolle kostet. Die Hard Rules sind derselbe Gegenstand eine
Ebene allgemeiner. Beide sind normativ wie eine ADR, nur ohne deren Immutabilität — und für die
ADR spricht Modul 8 genau diese Dreiteilung aus.

**2. Die Commit-Konstruktion der Baseline gilt für diese zwei Artefakte.** Eine Änderung an ihnen
landet in einem **eigenen Commit**, der **ausschließlich** Artefakte derselben schreibenden Rolle
berührt und die Rolle in seiner Message nennt; die Anweisung, die sie auslöst, bleibt legitime
**Quelle**, ihr Ausgang im laufenden Kontext ist ein **Übergabe-Artefakt**, nicht der Norm-Text.
Das ist kein neuer Mechanismus, sondern der Satz aus `grundlagen-source-precedence.md`
§Spec-Stratifizierung, angewandt auf zwei Artefakte, für die die Baseline ihn nicht ausspricht.

**Cutoff: geprüft wird ab dem Commit, der diese ADR annimmt.** Die Historie wird nicht
nachgezogen — dieselbe Begründung wie in
[`MR-015`](../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler):
ein Maßstab, der den Bestand mitprüfte, wäre dauerhaft rot und entwertete die Setzung.

**Was hier NICHT entschieden ist:** der Wortlaut der Hard Rule (Folgepflicht 1); ob eine Rolle
ein fremdes Artefakt **lesen** darf — sie darf, uneingeschränkt; und eine Eigentums-Aussage über
irgendein drittes Artefakt.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — **nichts tun**, die Klasse als viertes Einzel-Finding führen | kein neuer Mechanismus | Modul 10 §Pflege verlangt nach der dritten Wiederholung einen Träger. Der Preis steht schon im Pflicht-Lesepfad: eine erfundene Baseline-Abweichung in [`AGENTS.md`](../../../AGENTS.md) §3 und in einem Adaptions-Eintrag |
| B — **Verbot**: kein rollen-fremdes Artefakt im Implementations-Kontext | kürzest formulierbar | alle drei Fälle entstanden aus realem Bedarf auf ausdrückliche Anweisung. Eine Regel, die nur verbietet und keinen Weg nennt, wird unter Druck ein viertes Mal gebrochen |
| **C — schreibende Rolle für die zwei unbesetzten Artefakte + Commit-Konstruktion (gewählt)** | schließt genau die Lücke, die über alle 26 Regelwerk-Dateien gemessen offen ist; übernimmt eine Konstruktion, die die Baseline für das Lastenheft schon formuliert, statt eine zu erfinden; die Einhaltung ist an `git` ablesbar | kostet pro Norm-Änderung einen Kontext-Wechsel und einen eigenen Commit; und die Baseline selbst sagt, dass kein Sensor das prüft |
| D — Träger als **Lerneintrag** in der Closure-Notiz | billigster Weg | gemessen wirkungslos: die drei kanonischen Lehr-Formen stehen 57-mal in 32 Dateien unter `docs/plan/planning/done/`, und das Wort *Lerneintrag* kommt in [`AGENTS.md`](../../../AGENTS.md), [`harness/conventions.md`](../../../harness/conventions.md), [`harness/README.md`](../../../harness/README.md) und `.harness/skills/reviewer.md` **nullmal** vor (eigene Zählung, alle vier bestätigt) |
| E — **auf die Baseline warten**, weil Closure-Schritt 3b die Frage streift | kein eigener Norm-Text; die Baseline pflegt sich selbst | 3b deckt nur den Steering-Loop-Weg; der Freshness-Audit nach Modul 2, aus dem Adaptions-Einträge entstehen, nennt **keine** Rolle. Und die Tabelle, die `AGENTS.md` einer Rolle zuordnet, führt eine **andere Achse** — sie als Eigentum zu lesen kehrte die Frage um |

## Konsequenzen

- **Positiv:** die Frage *„durfte dieser Lauf das schreiben?"* ist für die zwei bisher
  unbesetzten Artefakte vor der Änderung beantwortbar statt danach als Finding.
- **Positiv:** eine Norm, die eine Aussage über die Baseline trifft, entsteht künftig im Kontext,
  dessen Aufgabe das Nachmessen ist.
- **Negativ, und das ist der Preis:** eine Norm-Änderung unterbricht den laufenden Slice. Wer sie
  sofort will, bekommt sie nicht sofort — er bekommt ein Übergabe-Artefakt und einen zweiten Lauf.
- **Negativ:** Festlegung 2 hat **keinen Wächter**, und das sagt schon die Baseline: *„kein
  d-check-Modul prüft, welche Dateien ein Commit zusammen anfasst"*. Die Regel liegt im
  Feedforward-Quadranten — benannt, nicht geschlossen.
- **Folgepflicht 1 — der Hard-Rule-Text.** Mit der Annahme schreibt der **Architect** die Regel
  als Hard Rule nach [`AGENTS.md`](../../../AGENTS.md) §3, in der Modul-9-Form (Falsch/Richtig
  plus Begründung), in einem eigenen Commit — nach der Regel, die sie selbst setzt. Diese ADR
  trägt die Abwägung, die Hard Rule den Wortlaut.
- **Folgepflicht 2 — kein Eintrag im Adaptions-Block.** Die Regel weicht von der Baseline nicht
  ab, sie füllt eine Lücke; ein Eintrag dort wäre eine erfundene Abweichung und verstieße gegen
  den Zweck, den [`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage) dem Block
  gibt — derselbe Fehler, den der dritte gemessene Fall gemacht hat.
- **Folgepflicht 3 — die emittierte Ebene bleibt unberührt, und das ist eine Entscheidung.** Ob
  ein erzeugtes Repo eine Eigentums-Aussage bekommt, entscheidet der Slice, der die Tool-Ebene
  entscheidet — nicht diese ADR.

## Fitness Function (falls maschinell prüfbar)

| Tooling | Regel | Make-Target |
|---|---|---|
| — | **keine.** Festlegung 2 ist mechanisierbar (ein Commit, der eines der zwei Artefakte gemeinsam mit Artefakten einer anderen Rolle ändert, ist der Befund), **gebaut ist sie nicht** | — |

**Was hier bewusst NICHT steht.** Ein Sensor über Festlegung 2 müsste **Commits** lesen; kein
Modul der heutigen `.d-check.yml`-Konfiguration tut das, und die Baseline stellt dieselbe Lücke
für ihren eigenen Fall fest. Ein Fall in `test/mutations/` ebenfalls nicht: der Mutations-Treiber
kennt zwei Fehlschlag-Formen (`--- FAIL:` der Go-Stufe, `not ok N` der bats-Stufe) und keine, in
der ein Commit-Zuschnitt rot wird. Behauptet wird hier **kein** Gate
([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).

## Re-Evaluierungs-Trigger

- **Wenn die Klasse ein viertes Mal auftritt, obwohl der Träger steht** *(feedforward — am
  Review-Bestand ablesbar)*: dann trägt der Ort nicht, und die Trägerwahl ist der Befund, nicht
  die Wiederholung.
- **Wenn eine künftige Baseline eine schreibende Rolle für `AGENTS.md` oder den Konventionsspeicher
  benennt** *(feedforward — eine Textänderung upstream, kein Sensor)*: dann ist diese ADR
  gegenstandslos und wird durch eine Nachfolge-ADR mit *Supersedes* auf den Baseline-Abschnitt
  zurückgeführt. `v5.3.1` benennt keine (siehe Kontext).
- **Wenn ein externer Auftraggeber entsteht** *(feedforward)*: dann führt der Weg über den
  Change Request, und Festlegung 2 ist gegen
  [`MR-015`](../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
  neu zu schneiden.
- **Wenn ein Commit-Sensor gebaut wird** *(feedforward)*: dann ist die Cutoff-Begründung neu zu
  prüfen — sie ruht darauf, dass der Bestand ungemessen bleibt.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-08-09 | **Proposed** | Architect-Verdikt auf eine Reviewer-Eskalation nach Modul 10 §Pflege; Anlass war die dritte gemessene Instanz derselben Rollen-Klasse in einem einzigen Slice, die zweite davon mit einer falschen Baseline-Aussage als materialisiertem Schaden |
| 2026-08-09 | Verengt, weiter **Proposed** | Gegenprüfung über **alle 26** Regelwerk-Dateien von `v5.3.1` statt nur `modul-08`: zwei der drei angenommenen Reste sind **gefallen** — die Anweisung als Quelle und der Commit als Träger stehen wörtlich in `grundlagen-source-precedence.md` §Spec-Stratifizierung, samt der Feststellung, dass kein Sensor sie prüft. Offen bleibt allein ihr **Geltungsbereich**: die Baseline sagt beides für `spec/lastenheft.md` und benennt für `AGENTS.md` und den Konventionsspeicher **keine** schreibende Rolle; die eine Tabelle, die `AGENTS.md` einer Rolle zuordnet, führt die Achse *„welche Artefaktklasse führt welche Rolle"*, nicht Eigentum. Die neunzeilige Eigentums-Karte ist damit entfallen — sieben ihrer Zeilen schrieben fremde Quellen ab, und mit ihr entfällt die Alterungs-Last, die sie selbst als Negativ-Konsequenz führte. Der Beleg in §Kontext steht in der Form aus [ADR-0016](0016-verweis-traegt-tag-und-zitat.md) Festlegung 2 |
