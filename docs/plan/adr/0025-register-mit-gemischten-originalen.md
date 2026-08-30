# ADR-0025: Ein Register mit gemischten Originalen hat keinen Eigentümer, aber jede seiner Änderungen eine Rolle

**Status:** Proposed

**Datum:** 2026-08-30

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md) (deren Festlegung 2
diese Frage ausdrücklich offen lässt und deren Re-Evaluierungs-Trigger sie fällig stellt),
[ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) (der Commit-Zuschnitt, den beide
mitführen), [ADR-0016](0016-verweis-traegt-tag-und-zitat.md) (die Form, in der die Belege unten
stehen),
[`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben dem Kommando, das sie liefert)

**Schärft:** — Prozess-ADR ohne Spec-Stratum.

---

## Kontext

### Der Trigger ist eingetreten, gemessen

[ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md) nennt als
Re-Evaluierungs-Trigger *„der erste Lauf, der `docs/plan/carveouts/README.md` anfasst"*. Seit
ihrer Annahme ist das dreimal geschehen, und kein einziges Mal in einem benannten Rollen-Kontext:

```sh
git log --format=%h b1b1ab7..722e272 -- docs/plan/carveouts/README.md | wc -l          # 3
git log --format=%s b1b1ab7..722e272 -- docs/plan/carveouts/README.md | grep -c '^Rolle '  # 0
```

**Beide Enden der Spanne stehen im Kommando**
([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 1): `b1b1ab7` ist der Commit, der
[ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md) annimmt, `722e272`
der Stand, gegen den dieser Text gemessen ist; über `HEAD` wanderten beide Zahlen mit jedem
weiteren Commit an der Datei — auch mit dem, der diese ADR anlegt. Die **0** ist der eigentliche
Befund: Das Register wurde geschrieben, weil es gerade nötig war, nicht weil eine Quelle es
zuwies. Genau diesen Zustand hat
[ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md) für den ADR-Index
beendet und für diese Datei ausdrücklich offen gelassen.

### Die Naht, an der die Vorgänger-Entscheidung stehen bleibt

Ihre Festlegung 1 hängt die Ableitung an die **Aussage**: *„Derivativ ist eine Eigenschaft der
Aussage, nicht der Datei"*. Ihre Festlegung 2 fällt für den offenen Fall auf die **Datei**
zurück: *„Projiziert ein Register Originale, die verschiedene schreibende Rollen haben, liefert
die Ableitung keine eindeutige Antwort."* Der Sprung liegt in der Bezugsgröße, nicht im Ergebnis.
Wer je Aussage fragt, bekommt je Aussage genau **ein** Original — gemischt ist die Datei, nie die
einzelne Zeile. Die Frage ist also nicht offen, weil die Ableitung versagt, sondern weil sie eine
Ebene zu hoch angesetzt wird.

### Was die Baseline über Carveouts sagt — und was sie nicht sagt

`v5.12.0`, `modul-07-carveouts.md` §Carveout-Audit-Slice verteilt die Originale über drei Rollen:

> *„Rollen (Modul 8): Planner identifiziert die fälligen Carveouts, Architect entscheidet bei
> „permanent" über die ADR-Überführung, Implementer führt `git mv` und Config-Updates aus.
> Verteilung über drei Rollen ist Absicht, kein Defekt"*

Nachprüfbar über den Zeilenumbruch hinweg:
`tr '\n' ' ' < .harness/baseline/v5.12.0/regelwerk/modul-07-carveouts.md | grep -o 'Verteilung über *drei Rollen ist Absicht' | wc -l`
→ **1**.

**Diese Aufzählung gilt dem Audit, nicht dem Anlegen.** Wer einen Carveout *anlegt*, benennt das
Regelwerk nirgends; es benennt nur die Gattung. `modul-08-agentenrollen.md` §Rollen-Sequenz für
einen Slice führt ihn unter den Übergabe-Artefakten eines Rück-Sprungs — *„keine Rolle springt
rückwärts in eine vorhergehende, ohne Übergabe-Artefakt (Findings, Folge-ADR-Vorschlag,
Carveout)"*
(`tr '\n' ' ' < .harness/baseline/v5.12.0/regelwerk/modul-08-agentenrollen.md | grep -o 'Übergabe-Artefakt\* (Findings, Folge-ADR-Vorschlag, Carveout)' | wc -l`
→ **1**). Die anlegende Rolle ist damit **je Fall** bestimmt und nicht je Klasse: Es schreibt ihn,
wer zurückgibt.

Über den ganzen vendored Baum nennen **zwei** Zeilen einen Carveout gemeinsam mit einer der sechs
Rollen. Sein **Register** wird im Baum ebenfalls zweimal genannt — und **keine** dieser
Nennungen steht in einer Zeile mit einer Rolle; das Modul, das den Carveout-Mechanismus
trägt, nennt es gar nicht:

```sh
grep -rniE 'carveout' .harness/baseline/v5.12.0/regelwerk/ \
  | grep -cE '\b(Architect|Planner|Implementer|Reviewer|Verifier|Validator)\b'   # 2
grep -rniE 'carveout-index|carveouts/README' .harness/baseline/v5.12.0/regelwerk/ | wc -l                # 2
grep -rniE 'carveout-index|carveouts/README' .harness/baseline/v5.12.0/regelwerk/ \
  | grep -cE '\b(Architect|Planner|Implementer|Reviewer|Verifier|Validator)\b'                          # 0
grep -ciE 'carveout-index|carveouts/README' .harness/baseline/v5.12.0/regelwerk/modul-07-carveouts.md  # 0
```

**Die Wortgrenze im ersten Kommando ist tragend, nicht kosmetisch:** ohne sie zählt
`architecture.md` als Rollen-Nennung mit, und die erste Zahl wäre **3**. Alle vier wandern mit dem
gepinnten Baum ([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2); tragend ist, dass die Rollen-Zahl **beim Register** null ist — die Baseline nennt es
und ordnet es keiner Rolle zu.

**Und Modul 8 setzt jeder Antwort eine Bedingung, die einen zusätzlichen Rollenwechsel kostet:**
*„Mehrfachzuweisung einer Tätigkeit an zwei Rollen ist nur dann sauber, wenn jede beteiligte Rolle
einen anderen Eingabe-Kontext hat. Sonst ist es keine Mehrfachzuweisung, sondern doppelte Arbeit
(und blinde Flecken)."* Über den Zeilenumbruch hinweg nachprüfbar:
`tr '\n' ' ' < .harness/baseline/v5.12.0/regelwerk/modul-08-agentenrollen.md | grep -o 'nur dann\* *sauber, wenn jede beteiligte Rolle einen \*anderen Eingabe-Kontext\*' | wc -l`
→ **1**. An dieser Regel muss sich jede Lösung messen lassen, die eine Zeile von einer Rolle
nachtragen lässt, die den Übergang nicht vollzogen hat: Ihr zweiter Kontext liest dieselbe
Eingabe wie der erste.

### Der Index projiziert, und seine Prosa projiziert ebenfalls

`docs/plan/carveouts/README.md` führt drei Abschnitte
(`grep -c '^## ' docs/plan/carveouts/README.md` → **3**, wandert mit dem Bestand), und jeder
entspricht einem der drei Status-Übergänge aus Modul 7: *aktiv*, *permanent — in eine ADR
übergeführt*, *aufgelöst*. Die Zellen geben Kopffelder der `CO-`-Dateien wieder — Titel,
betroffenes Gate, Datum, und den Status über die Abschnitts-Zugehörigkeit. Ein Register nach
Festlegung 1 der Vorgänger-Entscheidung, unstrittig.

Seine Prosa ist **nicht einheitlich**: der Kopf-Absatz gibt Modul 7 wieder (Zweck, Vorlage,
`git mv` nach `done/`), der Absatz über den permanenten Abschnitt regelt, was die Zelle
*Übergeführt in* zeigt und wo die Begründung steht, und ein Satz über die Rückkehr des
Verzeichnisses gibt einen Roadmap-Beschluss wieder. Drei Aussagen, drei verschiedene Originale —
in **einer** Datei. Das ist keine Besonderheit dieses Registers, sondern der Normalfall, sobald
die Originale gemischt sind.

## Entscheidung

**Wir wählen Option C: Bei gemischten Originalen wird die Ableitung eine Ebene tiefer angesetzt —
je Aussage statt je Datei. Die Datei bekommt keinen Eigentümer; jede Änderung an ihr bekommt eine
Rolle.** Drei Festlegungen:

**1. Eine Register-Zeile gehört der Rolle, die ihr Original schreibt, und entsteht im selben Lauf
wie dessen Änderung.** Das ist Festlegung 1 der Vorgänger-Entscheidung, wörtlich genommen, plus ihre
Festlegung 3 als Prüfform. Wer eine Zeile anlegt, verschiebt oder streicht, ohne im selben Commit
das Original zu berühren, dessen Feld sie wiedergibt, schreibt entweder Drift nach — oder ohne
Quelle. **Angewandt auf `docs/plan/carveouts/README.md`:** die Zeile im aktiven Abschnitt entsteht
mit der `CO-`-Datei und gehört der Rolle, die sie als Übergabe-Artefakt zurückgibt (§Kontext); die
Zeile wandert in den permanenten Abschnitt mit der ADR, die den Carveout überführt — **Architect**;
sie wandert in den aufgelösten Abschnitt mit dem `git mv` und der Rücknahme der Gate-Ausnahme —
**Implementer**. Die letzten beiden stehen namentlich in Modul 7, die erste folgt aus Modul 8 —
beide oben zitiert. Diese Festlegung erfindet keine Zuordnung, sie liest die vorhandene je Zeile
statt je Datei.

**Der Commit ist die Prüfform, nicht die Setzung.** Wo [`AGENTS.md`](../../../AGENTS.md) §3.3 den
Vorgang in einen reinen Move und eine Inhaltsänderung teilt, trägt die Zeile im Inhalts-Commit;
die Rolle ist in beiden dieselbe, und sie ist das Gebundene.

**2. Prosa im Register folgt derselben Ableitung, Aussage für Aussage.** Eine Projektionsregel
gehört der Rolle des Originals, das sie wiedergibt: gibt sie eine **Baseline-Regel** wieder,
gehört sie dem **Architect** — ob eine Abweichung von der Baseline besteht, ist eine
Architektur-Frage ([`AGENTS.md`](../../../AGENTS.md) §3.8,
[ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md)); gibt sie eine **Zeilenklasse** wieder,
gehört sie deren Rolle nach Festlegung 1; gibt sie ein **anderes Repo-Artefakt** wieder, gehört
sie der Rolle jenes Artefakts. **Welcher Fall vorliegt, ist ein Urteil und kein Muster**
([`AGENTS.md`](../../../AGENTS.md) §3.6) — es wird am Text gelesen, nicht gezählt.

**3. Die Grenze der Vorgänger-Entscheidung gilt unverändert fort.** Trägt eine Aussage im
Register eine bindende Setzung über den **Gegenstand**, die kein Original hat, greift die Grenze
aus deren Festlegung 1; ihre Rolle bleibt offen, und der erste Griff ist nicht diese ADR, sondern
die Frage, ob die Aussage überhaupt im Register stehen darf.

**Was diese ADR NICHT ändert.** Für Register mit **einheitlichen** Originalen bleibt Festlegung 1
der Vorgänger-Entscheidung die Antwort, und der ADR-Index bleibt beim **Architect** — hier wird
nichts abgelöst, sondern der von ihr benannte offene Punkt gefüllt. Kein `Supersedes`.

**Was diese ADR ebenfalls nicht entscheidet:** ob `docs/plan/carveouts/README.md` in seiner
heutigen Form die richtige ist, welche Zelle er führen sollte und ob eine seiner Aussagen unter
Festlegung 3 fällt. Das ist eine Frage an den Text, nicht an die Rolle.

**Cutoff: geprüft wird ab dem Commit, der diese ADR annimmt.** Die **3** Berührungen aus §Kontext
werden nicht nachgezogen — dieselbe Begründung wie in
[ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) und
[ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md): ein Maßstab, der den
Bestand mitprüfte, wäre dauerhaft rot und entwertete die Setzung.

**Ein Wort zur Referenz-Richtung.** `grundlagen-referenz-richtung.md` §Referenz-Richtung (SDP) stellt
die Zelle *ADR → Carveout* auf ❌. Diese ADR nennt `docs/plan/carveouts/README.md` als **Gegenstand
einer Regel** und zieht aus keinem Carveout eine Begründung; sie nennt den Pfad deshalb als
Inline-Code und nie als Verweis. Mechanisch prüft das nichts — die `matrix`-Klassen in
`.d-check.yml` führen Spec-Straten, ADRs und Slices, keine Carveouts.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — **nichts tun**, die Frage bleibt offen wie in [ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md) Festlegung 2 | kein neuer Norm-Text; der Fall ist benannt statt still | der Trigger ist **eingetreten** und hat schon **3** Berührungen ohne Quelle erzeugt (§Kontext, dasselbe Kommando). Weiter offen heißt: der nächste Lauf schreibt wieder, weil es nötig ist — die Klasse, gegen die die Vorgänger-Entscheidung angetreten ist |
| B — den Carveout-Index dem **Planner** zuschreiben, weil er die Closure trägt | eine Zeile Regeltext; der Planner sieht das Register beim Trigger-Audit ohnehin | zwei der drei Übergänge vollzieht er nicht. Jede Auflösung bräuchte nach dem `git mv` einen zweiten Lauf, der nur die Zeile nachzieht — ein Rollenwechsel ohne anderen Eingabe-Kontext, den Modul 8 ausdrücklich als *„doppelte Arbeit (und blinde Flecken)"* verwirft (§Kontext). Und die Lücke zwischen Move und Zeile ist genau die *„zweite Lüge"*, vor der Modul 7 beim Auflösen warnt |
| **C — je Aussage ableiten (gewählt)** | beantwortet **jede** Änderung eindeutig, ohne die Datei zuzuweisen und ohne Liste; die Zuordnung ist am Artefakt ablesbar; sie liest die Rollen, die Modul 7 schon namentlich verteilt, statt sie zu überschreiben; der Commit-Zuschnitt aus [ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) bleibt erfüllbar, weil Zeile und Original ohnehin zusammen wandern | die Vorfrage ist je Aussage zu stellen und ist ein Urteil — genauer, nicht billiger; und für eine Aussage ohne Original liefert sie weiterhin nichts (Festlegung 3) |
| D — dem **Architect** zuschreiben, analog zum ADR-Index | kürzeste Analogie; der Architect trägt schon die Norm-Artefakte | er vollzieht **einen** der drei Übergänge. Die Analogie trägt gerade nicht: beim ADR-Index sind die Originale einheitlich, hier sind sie es messbar nicht (§Kontext) |
| E — dem **Implementer** zuschreiben, weil Modul 7 ihm `git mv` und Config-Updates gibt | deckt den häufigsten Übergang und passt zum Commit, der die Datei bewegt | Modul 7 gibt ihm die **Ausführung**, nicht die Entscheidung; die Überführung in eine ADR steht dort ausdrücklich beim Architect. Wer sie dem Implementer gäbe, hebt die Rollen-Trennung an genau der Stelle auf, für die Modul 7 sie *„Absicht, kein Defekt"* nennt |
| F — das Register **aufteilen**, je Rolle eine Datei; dann greift [ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md) Festlegung 1 wieder | löst die Gemischtheit strukturell statt per Regel auf | drei Dateien für ein Register, dessen Ziel-Form die Baseline als **einen** Index führt; die Zugehörigkeit einer Zeile ist der Status, und der ändert sich — jede Auflösung würde zum Datei-Wechsel. Und die Klasse bliebe ungelöst: das nächste gemischte Register beginnt von vorn |

## Konsequenzen

- **Positiv:** die Frage *„durfte dieser Lauf das schreiben?"* ist auch für gemischte Register vor
  der Änderung beantwortbar — nicht als Eigentum an einer Datei, sondern als Zuordnung je Änderung.
- **Positiv:** die Regel kostet keinen zusätzlichen Rollenwechsel. Zeile und Original wandern im
  selben Lauf; wo eine Zeile ohne ihr Original entsteht, ist genau das der Befund.
- **Positiv:** die Naht zwischen Festlegung 1 und 2 der Vorgänger-Entscheidung — *je
  Aussage* gegen *je Datei* — ist geschlossen, ohne dass eine `Accepted`-ADR angefasst wird
  ([`AGENTS.md`](../../../AGENTS.md) §3.4).
- **Negativ, und das ist der Preis:** die Datei hat weiterhin keinen Eigentümer. Wer wissen will,
  wer sie *insgesamt* pflegt, bekommt keine Antwort — nur je Änderung eine.
- **Negativ:** die Vorfrage wächst. Sie ist jetzt nicht nur je Aussage zu stellen, sondern bei
  gemischten Registern auch je **Original**, und in Festlegung 2 mit drei Zweigen.
- **Negativ:** **kein Wächter**, siehe unten.
- **Folgepflicht 1 — der ADR-Index.** Er wird mit dieser Datei fortgeschrieben
  ([`AGENTS.md`](../../../AGENTS.md) §5); er ist ein Register mit einheitlichen Originalen und
  gehört nach [ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md)
  Festlegung 1 dem **Architect** — also derselben Rolle wie diese Datei, im selben Commit.
- **Folgepflicht 2 — der Zeiger im Briefing, fällig erst mit der Annahme.**
  [`AGENTS.md`](../../../AGENTS.md) §3.8 zeigt heute auf die Vorgänger-Entscheidung und endet dort,
  wo diese ihre Grenze zieht; ein Leser findet den gemischten Fall nicht. Der **Architect** setzt
  den Zeiger — keine zweite Fassung dieses Textes —, **wenn diese ADR angenommen ist**, nicht
  vorher: eine Hard Rule, die auf eine `Proposed`-Entscheidung zeigt, behauptet Bindung, die nicht
  besteht. Bis dahin trägt der ADR-Index die Auffindbarkeit; das ist seine Aufgabe.
- **Folgepflicht 3 — kein Eintrag im Adaptions-Block.** Die Regel weicht von der Baseline nicht
  ab, sie füllt eine Lücke: die Baseline nennt das Register und keine Rolle dazu (§Kontext, das
  zweite und dritte Kommando). Ein Eintrag dort wäre eine erfundene Abweichung
  ([`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage)); dieselbe Folgepflicht
  führen [ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) und
  [ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md) aus demselben Grund.
- **Folgepflicht 4 — die emittierte Ebene bleibt unberührt.** Ob ein erzeugtes Repo eine
  Eigentums-Aussage über seine Register bekommt, entscheidet der Slice, der die Tool-Ebene
  entscheidet — nicht diese ADR.

## Fitness Function (falls maschinell prüfbar)

| Tooling | Regel | Make-Target |
|---|---|---|
| — | **keine.** Der prüfbare Teil wäre *„eine Register-Zeile ändert sich, ohne dass derselbe Lauf ihr Original berührt"* — eine **Commit**-Bedingung mit einer bekannten Unschärfe (dem Move/Inhalts-Split aus [`AGENTS.md`](../../../AGENTS.md) §3.3), und sie ist hier so wenig gebaut wie bei [ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 2 und [ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md) | — |

**Was hier bewusst NICHT steht.** Ein Sensor müsste Commits lesen; kein Modul der heutigen
`.d-check.yml` tut das (`grep -m1 '^modules:' .d-check.yml` führt `links, anchors, ids, matrix,
codepaths, spans`), und `make mutate` kennt zwei Fehlschlag-Formen — `--- FAIL:` der Go-Stufe,
`not ok N` der bats-Stufe —, keine, in der ein Commit-Zuschnitt rot wird. Die Vorfrage aus
Festlegung 2 ist ohnehin unbewacht: welches Original eine Prosa-Aussage wiedergibt, sieht kein
`grep`. Behauptet wird hier **kein** Gate
([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). Träger
ist der Rollen-Wechsel vor der Änderung.

## Re-Evaluierungs-Trigger

- **Wenn ein künftiger Baseline-Stand eine schreibende Rolle für den Carveout-Index oder für
  derivative Register allgemein benennt** *(feedforward — eine Textänderung upstream, kein
  Sensor)*: dann ist diese ADR gegenstandslos und wird durch eine Nachfolge-ADR mit *Supersedes*
  auf den Baseline-Abschnitt zurückgeführt. `v5.12.0` benennt keine (§Kontext, drittes Kommando).
- **Wenn eine Register-Zeile ohne ihr Original geschrieben wird, obwohl diese Entscheidung
  angenommen ist** *(feedforward — am Commit-Bestand ablesbar)*: dann trägt der Ort nicht, und die
  Trägerwahl ist der Befund, nicht die Wiederholung — dieselbe Probe, die
  [ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) und
  [ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md) an sich selbst
  anlegen.
- **Wenn eine Prosa-Aussage in einem Register in keinen der drei Zweige aus Festlegung 2 fällt**
  *(feedforward — beim Lesen, nicht durch ein Kommando)*: dann ist entweder der vierte Zweig fällig
  oder die Aussage fällt unter Festlegung 3. Welches von beidem, ist die erste Frage.
- **Wenn ein Register entsteht, dessen Zeilen ihr Original außerhalb dieses Repos haben**
  *(feedforward)*: dann greift die Ableitung ins Leere, weil keine Rolle dieses Repos das Original
  schreibt. Der Fall ist heute nicht real und wird hier nicht auf Vorrat entschieden.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-08-30 | **Proposed** | Architect-Lauf; Anlass ist der eingetretene Re-Evaluierungs-Trigger aus [ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md) — *„der erste Lauf, der `docs/plan/carveouts/README.md` anfasst"*. Der Acceptance-Trigger der Baseline (`grundlagen-bootstrap.md` §Vier Trigger-Klassen: *„ADR-Review-Runde abgeschlossen → bindend"*) hat **nicht** stattgefunden; er ist die Bedingung für den Umschlag. Die Vorgänger-Entscheidung wurde in derselben Frage mit der Begründung *„Repo-Praxis"* als `Accepted` geboren und im Review zurückgestuft — der Bestand begründet keinen Status |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-NNNN` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).
