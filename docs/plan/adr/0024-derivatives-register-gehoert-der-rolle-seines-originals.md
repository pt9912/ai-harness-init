# ADR-0024: Ein derivatives Register gehört der Rolle, die sein Original schreibt

**Status:** Proposed

**Datum:** 2026-08-29

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) (dieselbe Lücke eine Stelle weiter — jene
Entscheidung besetzt zwei Norm-Artefakte und lässt die Frage für alle übrigen ausdrücklich offen),
[ADR-0016](0016-verweis-traegt-tag-und-zitat.md) (die Form, in der die Belege unten stehen),
[`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben dem Kommando, das sie liefert)

**Schärft:** — Prozess-ADR ohne Spec-Stratum.

---

## Kontext

### Was die Baseline regelt — und was sie nicht regelt

Das Regelwerk `v5.12.0` kennt die Klasse und benennt sie namentlich. Es führt sie in
`grundlagen-harness-dateien.md` §Jedes Artefakt hat einen Konsumenten:

> *„**Derivative Artefakte** (ADR-Index, Carveout-Index, *Folge-Slices* in der Closure-Notiz)
> brauchen keinen eigenen Leser, wohl aber eine **Deckung**: das Original muss existieren. Als
> *derivativ* kennzeichnen, sonst schlägt die Probe falschen Alarm."*

Die Klasse ist damit **definiert**, ihre schreibende Rolle **nicht**. Über den ganzen vendored
Regelwerks-Baum gemessen: zwei Dateien nennen einen der beiden Indizes überhaupt
(`grep -rlEi 'ADR-Index|Carveout-Index' .harness/baseline/v5.12.0/regelwerk/ | wc -l` → **2**),
und keine dieser Nennungen steht in einer Zeile, die eine der sechs Rollen nennt
(`grep -rniE '(ADR|Carveout)-Index' .harness/baseline/v5.12.0/regelwerk/ | grep -ciE 'architect|planner|implementer|reviewer|verifier|validator'`
→ **0**). Die einzige Rollen-Aussage über ein ADR-Artefakt gilt der **Entscheidung**, nicht ihrem
Register — `v5.12.0`, `modul-08-agentenrollen.md` §Rollen-Regeln: *„ADR-Änderung: Architect schreibt;
Reviewer prüft auf Konsistenz; Implementer liest als Constraint"*.

Für die zwei Norm-Artefakte, bei denen dieselbe Lücke klaffte, hat
[ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) sie geschlossen — und dabei ihren
Geltungsbereich bewusst verengt: *„Über die übrigen Norm-Artefakte trifft diese ADR **keine**
Aussage … wo keine sie benennt, bleibt das eine offene Frage, die diese Verengung ausdrücklich
stehen lässt."* Diese ADR nimmt genau eine dieser offenen Fragen auf.

### Der Anlass, gemessen

`docs/plan/adr/README.md` wird geschrieben, ohne dass eine Quelle sagt, von wem. **Faktisch**
schreiben ihn Architect-Läufe, und das ist keine Auswahl aus vielen: von den Commits, die die
Datei berühren, tragen die mit Rollen-Präfix **ausnahmslos** denselben —

```sh
git log --format='%s' -- docs/plan/adr/README.md | wc -l                     # 65
git log --format='%s' -- docs/plan/adr/README.md | grep -oE '^Rolle [A-Za-zÄÖÜäöü]+' | sort | uniq -c   # 26 Rolle Architect
git log --format='%s' -- docs/plan/adr/README.md | grep -cv '^Rolle '        # 39
```

**Keine Erwartungswerte** ([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2): alle drei wandern mit jedem Commit, und die **39** ohne Präfix sind kein Gegenbeleg —
die Rollen-Benennung in der Message ist jünger als die Datei. Tragend ist, dass unter den
benannten **keine zweite Rolle** vorkommt.

**Praxis ist keine Zuständigkeit.** Genau das ist der Fehler, den
[ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) §Der Anlass an drei Fällen gemessen hat:
ein Lauf ändert ein Artefakt, für das ihn nichts autorisiert, weil es gerade nötig ist. Der
offene Slice, der den ADR-Index an seine vendored Ziel-Form heranführt, stellt die Frage vor der
ersten Zeile und benennt als einen seiner Ausgänge die *„Übergabe an den Architect, mit
Adresse"*; seine eigene Plan-Tabelle sagt dazu, der Slice könne sie **nicht selbst setzen**, denn
*„wer sie setzt, setzt sie für eine Klasse von Artefakten, nicht für eine Datei"*.

### Warum die Frage nicht mit einer Liste zu beantworten ist

[ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) verwirft die naheliegende Form mit einem
Satz, der hier weitergilt: *„Eine abgeschriebene Übersicht wäre eine zweite Fassung, die
driftet."* Eine Tabelle *Artefakt → Rolle* müsste bei jedem neuen Register nachgezogen werden und
wäre bei jedem vergessenen Nachzug still falsch. Was nicht driftet, ist eine **Ableitung**: Sie
braucht keinen Eintrag pro Artefakt, weil sie die Antwort aus einer Eigenschaft des Artefakts
gewinnt.

### Kein reales Register besteht nur aus Tabellenzeilen

Die Vorfrage muss an der **Aussage** hängen und nicht an der Datei, sonst beantwortet sie sich
über den Bestand dieses Repos mit *nichts*. Beide Register, die es führt, tragen neben ihrer
Tabelle Text:

```sh
grep -c '^| ' docs/plan/adr/README.md            # 25   von   wc -l < docs/plan/adr/README.md            # 74
grep -c '^| ' docs/plan/carveouts/README.md      #  8   von   wc -l < docs/plan/carveouts/README.md      # 36
```

**Keine Erwartungswerte** ([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — alle vier wandern mit dem Bestand; tragend ist, dass in **beiden** Dateien die
Tabellenzeilen die Minderheit sind. Eine Bedingung, die ein Register schon dann ausschlösse, wenn
neben der Tabelle etwas steht, träfe damit **jedes** Register dieses Repos und beantwortete keinen
einzigen Fall. Was dieser Text tut, entscheidet — nicht, dass er da ist.

## Entscheidung

**Wir wählen Option C: die schreibende Rolle eines derivativen Registers wird nicht zugewiesen,
sondern aus seinen Originalen abgeleitet.** Drei Festlegungen:

**1. Ein derivatives Register wird von der Rolle geschrieben, die seine Originale schreibt.**
*Derivativ* ist eine Eigenschaft der **Aussage**, nicht der Datei: eine Register-Zeile gibt Felder
eines Originals wieder, und das Original muss existieren — so führt das Regelwerk die Klasse
(oben zitiert). Daneben trägt jedes reale Register **Text über sich selbst**: wozu es da ist, was
seine Spalten projizieren, wann eine Zelle einen Zusatz trägt, welcher Sensor sie hält, wo eine
Zeile hinwandert. Das ist keine zweite Aussage über die Sache, sondern die **Projektionsregel** —
und wer beurteilt, ob eine Zelle ihr Original richtig wiedergibt, entscheidet auch, was Wiedergabe
heißt. Sie fällt darum unter dieselbe Rolle wie die Zeilen, die sie regelt.

**Die Ableitung endet dort, wo ein Artefakt eine bindende Aussage über den Gegenstand trägt, die
kein Original hat.** Über **diesen Teil** sagt diese ADR nichts; die Datei bleibt im Übrigen ein
Register. Die Probe ist in beide Richtungen benannt: eine Projektionsregel sagt, *wie* eine Zeile
ihr Original wiedergibt, eine gegenstandsbezogene Setzung sagt etwas über die Sache selbst und
gehörte dann in eine ADR, eine Spec-Stelle oder den Adaptions-Block.

**Angewandt:** `docs/plan/adr/README.md` projiziert `docs/plan/adr/0*.md` — Titel aus deren
`# `-Überschrift, Status aus deren Kopffeld, Bezug aus deren `**Bezug:**`-Zeile; der Index sagt
das über sich selbst (*„**Derivativ:** was eine Entscheidung sagt, sagt ihre Datei; dieser Index
zeigt auf sie."*). Sein Abschnitt `## Konventionen`
(`awk '/^## Konventionen/{f=1} f' docs/plan/adr/README.md | wc -l` → **42** von
`wc -l < docs/plan/adr/README.md` → **74**, beide wandern) ist gelesen und trägt **keine**
gegenstandsbezogene Setzung: er sagt, was Titel- und Status-Zelle wörtlich wiedergeben, wann eine
Zelle einen Zusatz trägt und was der Zusatz nennt, dass eine Verfeinerung keine Revision ist, dass
`Bezug` voll verlinkt wird — und dass kein Sensor die Titel- und die Status-Regel hält. Alles davon
regelt die Projektion; die Immutabilitäts-Zeile gibt
[`AGENTS.md`](../../../AGENTS.md) §3.4 wieder und setzt nichts daneben. **Diese Zuordnung ist ein
Urteil, kein Muster** ([`AGENTS.md`](../../../AGENTS.md) §3.6) — sie ist am Text gelesen, nicht
gezählt. ADRs schreibt der **Architect** (`modul-08-agentenrollen.md` §Rollen-Regeln, oben
zitiert). Also schreibt der Architect auch den Index.

**2. Bei gemischten Originalen entscheidet diese ADR nicht.** Projiziert ein Register Originale,
die **verschiedene** schreibende Rollen haben, liefert die Ableitung keine eindeutige Antwort;
dann bleibt die Frage offen und braucht eine eigene Entscheidung. Das ist kein Schlupfloch,
sondern ein gemessener Fall: `docs/plan/carveouts/README.md` ist nach Festlegung 1 ein Register —
sein Text neben der Tabelle nennt Zweck, Vorlage und den Ort, an den eine aufgelöste Zeile wandert,
und sagt für die Spalte *Übergeführt in* ausdrücklich, dass die Begründung **nicht** hier steht,
sondern in der ADR: Projektionsregeln. Die Ableitung greift also — und **liefert nichts**, weil
Carveouts das Regelwerk ausdrücklich über drei Rollen verteilt,
`modul-07-carveouts.md` §Carveout-Audit-Slice (Modul 7):
*„Rollen (Modul 8): Planner identifiziert die fälligen Carveouts, Architect entscheidet bei
„permanent" über die ADR-Überführung, Implementer führt `git mv` und Config-Updates aus.
Verteilung über drei Rollen ist Absicht, kein Defekt"*
(`grep -c 'Planner. identifiziert die fälligen Carveouts' .harness/baseline/v5.12.0/regelwerk/modul-07-carveouts.md`
→ **1**). Der offene Fall fällt damit an der Stelle heraus, an der er hingehört — an den
Originalen, nicht an der Dateiform.

**3. Die Commit-Konstruktion aus [ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md)
Festlegung 2 gilt mit.** Eine Änderung am Register liegt im Commit-Zuschnitt seiner Rolle. Für
den ADR-Index kostet das nichts: Er wandert ohnehin mit der ADR, die ihn auslöst, und die ist
schon ein Architect-Commit ([`AGENTS.md`](../../../AGENTS.md) §5: *„Neue ADRs aktualisieren den
ADR-Index."*).

**Cutoff: geprüft wird ab dem Commit, der diese ADR annimmt.** Die **39** Commits ohne
Rollen-Präfix aus §Kontext werden nicht nachgezogen — dieselbe Begründung wie in
[ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md): ein Maßstab, der den Bestand mitprüfte,
wäre dauerhaft rot und entwertete die Setzung.

**Was hier NICHT entschieden ist:** der **Inhalt** des ADR-Index — welche Posten seiner
vendored Ziel-Form er übernimmt, trägt der Slice, der ihn dorthin führt, und nicht diese ADR; die
Rolle für eine bindende Aussage ohne Original, falls eine in ein Register gerät (Festlegung 1
grenzt sie ab und beantwortet sie nicht); die Rolle für ein Register mit gemischten Originalen
(Festlegung 2); und die emittierte Ebene.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — **nichts tun**, die Frage bleibt offen wie in [ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) | kein neuer Mechanismus; die Lücke ist benannt statt still | der offene Slice zum ADR-Index führt sie unter seinen Risiken mit dem Ausgang *„Übergabe an den Architect, mit Adresse"* — ohne Adresse bleibt er blockiert oder schreibt ohne Quelle. Und der Bestand zeigt, wohin das führt: **26** Läufe haben die Datei mit Rollen-Namen geschrieben, ohne dass eine Quelle sie autorisierte |
| B — den **ADR-Index namentlich** dem Architect zuschreiben | kürzest formulierbar; deckt den einzigen akuten Fall | die nächste Register-Frage beginnt von vorn, und die Antwort wäre eine Liste — genau die *„zweite Fassung, die driftet"*, die [ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) verwirft |
| **C — Ableitung aus den Originalen (gewählt)** | beantwortet die Klasse mit **einer** Regel und ohne Liste; die Antwort ist am Artefakt selbst ablesbar, nicht in einer Tabelle nachzuschlagen; der offene Fall (gemischte Originale) fällt sichtbar heraus, statt still falsch beantwortet zu werden | die Ableitung braucht eine Vorfrage — *ist diese Aussage Projektion oder Projektionsregel, oder ist sie gegenstandsbezogen?* —, und die ist ein Urteil; für gemischte Originale liefert sie nichts |
| D — dem **Planner** zuschreiben, weil der Index unter `docs/plan/` liegt | der Pfad ist ohne Nachdenken ablesbar | der Pfad ist keine Rolle. Die Zellen projizieren `# `-Überschrift und `Status:`-Kopffeld von ADR-Dateien; ob eine solche Zelle stimmt, beurteilt die Rolle, die die ADR schreibt. Und **kein** Commit des Bestands trägt diesen Rollen-Namen |
| E — **auf die Baseline warten** | kein eigener Norm-Text; die Baseline pflegt sich selbst | gemessen: `v5.12.0` nennt die Klasse und keine Rolle dazu (§Kontext, **0** Treffer). [ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) hat denselben Zweig für die Schwester-Artefakte schon geprüft und verworfen |
| F — die Vorfrage an der **Datei** aufhängen (*trägt sie neben der Tabelle Text, ist sie kein Register*) | eine Zeile Regeltext, mechanisch anmutend | über den Bestand gemessen leer: in beiden Registern dieses Repos sind die Tabellenzeilen die Minderheit, daneben steht Text (§Kontext), die Regel schlösse also beide aus und beantwortete keinen Fall. Und sie schlüge am ADR-Index gerade wegen des Abschnitts fehl, der seine Projektion **beschreibt** |

## Konsequenzen

- **Positiv:** die Frage *„durfte dieser Lauf das schreiben?"* ist für eine ganze Klasse vor der
  Änderung beantwortbar, ohne dass ein Register von Zuordnungen entsteht, das driftet.
- **Positiv:** das Zuständigkeits-Risiko des offenen Slice zum ADR-Index bekommt seinen Ausgang
  *entfallen* — die Antwort steht in einer Quelle, nicht in der Praxis. **Fällig wird das mit der
  Annahme, nicht mit dieser Fassung:** solange diese ADR auf `Proposed` steht, ist sie keine
  Quelle, auf die ein Slice sich stützt.
- **Negativ, und das ist der Preis:** für ein Register mit gemischten Originalen liefert die
  Ableitung nichts (Festlegung 2). Der `docs/plan/carveouts/README.md` ist gemessen einer; wer
  ihn anfasst, steht vor derselben offenen Frage wie vor dieser ADR.
- **Negativ:** die Vorfrage aus Festlegung 1 ist ein Urteil, und sie ist jetzt **je Aussage** zu
  stellen statt einmal je Datei — das ist genauer und nicht billiger. Ein Artefakt, das sich selbst
  *derivativ* nennt und seine Projektionsregel ausschreibt, macht sie leicht; eines ohne beides
  macht sie schwer.
- **Negativ:** **kein Wächter**, siehe unten.
- **Folgepflicht 1 — der Zeiger im Briefing, fällig mit der Annahme.** Der **Architect** setzt in
  [`AGENTS.md`](../../../AGENTS.md) §3.8 einen Zeiger auf diese ADR, keine zweite Fassung ihres
  Textes — die Hard Rule bleibt der Ort für *wer schreibt die Hard Rules*, diese ADR der Ort für
  *wer schreibt ein derivatives Register*. Eine neue Hard-Rule-Nummer entsteht dafür **nicht**:
  eine Aussage hat einen Ort, und der Zeiger kostet eine Zeile statt einer Nummer, die
  [`MR-026`](../../../harness/conventions.md#mr-026--die-hard-rule-nummer-ist-eine-adresse-keine-baseline-entsprechung)
  Setzung 2 anhängen müsste. **Heute ist er nicht gesetzt** (`grep -c 'ADR-0024' AGENTS.md` → **0**,
  Exit 1) — eine Hard Rule, die auf ein `Proposed`-Artefakt zeigt, machte es über die Hintertür
  bindend.
- **Folgepflicht 2 — kein Eintrag im Adaptions-Block.** Die Regel weicht von der Baseline nicht
  ab, sie füllt eine Lücke; ein Eintrag dort wäre eine erfundene Abweichung und verstieße gegen
  den Zweck, den [`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage) dem Block
  gibt — dieselbe Folgepflicht führt
  [ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) aus demselben Grund.
- **Folgepflicht 3 — die emittierte Ebene bleibt unberührt.** Ob ein erzeugtes Repo eine
  Eigentums-Aussage über seine Register bekommt, entscheidet der Slice, der die Tool-Ebene
  entscheidet — nicht diese ADR.

## Fitness Function (falls maschinell prüfbar)

| Tooling | Regel | Make-Target |
|---|---|---|
| — | **keine.** Der prüfbare Teil wäre derselbe wie bei [ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 2 — ein Commit, der ein derivatives Register gemeinsam mit Artefakten einer anderen Rolle ändert —, und er ist dort wie hier **nicht gebaut** | — |

**Was hier bewusst NICHT steht.** Ein Sensor müsste **Commits** lesen; kein Modul der heutigen
`.d-check.yml` tut das (`grep -m1 '^modules:' .d-check.yml` führt `links, anchors, ids, matrix,
codepaths, spans`), und `make mutate` kennt zwei Fehlschlag-Formen — `--- FAIL:` der Go-Stufe,
`not ok N` der bats-Stufe —, keine, in der ein Commit-Zuschnitt rot wird. Auch die Vorfrage aus
Festlegung 1 ist unbewacht: ob eine Aussage Projektionsregel oder gegenstandsbezogene Setzung ist,
sieht kein `grep`. Behauptet wird hier
**kein** Gate ([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
Träger ist der Rollen-Wechsel vor der Änderung.

## Re-Evaluierungs-Trigger

- **Wenn ein künftiger Baseline-Stand eine schreibende Rolle für derivative Register benennt**
  *(feedforward — eine Textänderung upstream, kein Sensor)*: dann ist diese ADR gegenstandslos
  und wird durch eine Nachfolge-ADR mit *Supersedes* auf den Baseline-Abschnitt zurückgeführt.
  `v5.12.0` benennt keine (§Kontext).
- **Wenn ein Register mit gemischten Originalen praktisch geschrieben werden soll** *(feedforward
  — der erste Lauf, der `docs/plan/carveouts/README.md` anfasst)*: dann ist Festlegung 2 der
  Befund, und die offene Frage braucht ihre eigene Entscheidung. Diese ADR beantwortet sie nicht
  nachträglich.
- **Wenn in einem Register eine bindende Aussage ohne Original auftaucht** *(feedforward — beim
  Lesen, nicht durch ein Kommando)*: dann greift die Grenze aus Festlegung 1, und die Rolle für
  jenen Teil ist offen. Der erste Griff ist dann nicht diese ADR, sondern die Frage, ob die
  Aussage überhaupt im Register stehen darf.
- **Wenn ein derivatives Register ein zweites Mal ohne Quelle geschrieben wird, obwohl der Träger
  steht** *(feedforward — am Commit-Bestand ablesbar)*: dann trägt der Ort nicht, und die
  Trägerwahl ist der Befund, nicht die Wiederholung — dieselbe Probe, die
  [ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) an sich selbst anlegt.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-08-29 | **Proposed** | Architect-Lauf; Anlass ist die offene Zuständigkeits-Frage aus slice-134 §3/§6 |
| 2026-08-29 | Überarbeitet, weiter **Proposed** | Reviewer-Runde [`2026-08-29-adr-0024-mr-031-032-review.md`](../../reviews/2026-08-29-adr-0024-mr-031-032-review.md), Verdikt *NICHT KONFORM*. Zwei Befunde treffen diese Datei. Der **Status** stand auf `Accepted`, ohne dass der Acceptance-Trigger der Baseline (`grundlagen-bootstrap.md` §Trigger-Klassen: *„Phase-Übergang via Sign-off"*) stattgefunden hatte; die Begründung *„Repo-Praxis"* ist gegen den Bestand messbar falsch — von **24** ADRs tragen **19** eine `Proposed`-Zeile, die fünf ohne sie sind der Bootstrap-Tag und diese Datei (`ls docs/plan/adr/0*.md \| wc -l`, `grep -lE '^\| [0-9]{4}-[0-9]{2}-[0-9]{2} \| \*{0,2}Proposed' docs/plan/adr/0*.md \| wc -l`, beide wandern). Und **Festlegung 1 schloss ihren eigenen Anwendungsfall aus**: die Ausschluss-Bedingung hing an der Datei (*„Trägt ein Artefakt daneben eigene Setzungen, ist es kein derivatives Register"*), und beide Register dieses Repos tragen Prosa neben der Tabelle. Die Bedingung hängt jetzt an der **Aussage**, die Vorfrage-Antwort für den ADR-Index ist am Text gelesen und benannt, die Datei-Variante steht als verworfene Option F. Der Zeiger in [`AGENTS.md`](../../../AGENTS.md) §3.8 ist zurückgenommen und mit der Annahme fällig |
