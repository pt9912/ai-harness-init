# ADR-0040: Der Accept-Übergang nennt den Beleg, den der eigene Acceptance-Trigger verlangt — und der Kontext, der den blockierenden Befund auflöste, ist keiner

**Status:** Proposed

**Datum:** 2026-09-07

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[ADR-0018](0018-ziel-fassung-regiert-die-migration.md) (ihre §Geschichte trägt die Messung, dass
**keine** Quelle dieses Repos und keine der vendored Baseline einen annehmenden Akteur benennt —
diese Entscheidung füllt die Lücke, die dort benannt ist),
[ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) (dieselbe Bauart: eine Zuständigkeit, die
keine Quelle benennt, wird entschieden statt weiter offen gelassen),
[ADR-0038](0038-ziel-fassung-regiert-den-sprung-v650.md) (`Accepted`, der gemessene Anlass; sie
wird von dieser Entscheidung **nicht** abgelöst),
[ADR-0036](0036-ziel-fassung-regiert-den-sprung-v600.md) (dieselbe Klasse, an derselben Stelle
richtig belegt — die Form, die Festlegung 1 verallgemeinert),
[ADR-0016](0016-verweis-traegt-tag-und-zitat.md) (Träger (a) bindet die Verweis-Prüfung an genau
diesen Übergang),
[ADR-0027](0027-tote-adresse-in-eingefrorener-adr.md),
[ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) (beide binden ihren Träger
ebenfalls an den Accept-Übergang; diese Entscheidung sagt, wann er stattgefunden hat),
[`MR-015`](../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
(Change Request bei Personalunion — der Grund, warum ein zweiter Kontext hier überhaupt gebraucht
wird),
[`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert),
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)

**Schärft:** — Prozess-ADR ohne Spec-Stratum: sie entscheidet über die Bedingungen eines
Status-Übergangs, nicht über den Inhalt eines Spec-Dokuments.

**Kopplung:** [`AGENTS.md`](../../../AGENTS.md) §3.4 bleibt **unberührt** — sie sagt, was **nach**
`Accepted` gilt; diese Entscheidung sagt, was den Übergang **dorthin** trägt. Die zwei greifen
ineinander, und genau deshalb ist die zweite ohne die erste folgenlos: Ein Widerspruch, der beim
Übergang entsteht, ist danach eingefroren.

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md`
§Ziel-Form: ADR (MADR).

---

## Kontext

### Was gemessen ist

Die Rollen-Teilung für ADRs steht in der Baseline — `v6.5.0`, `modul-08-agentenrollen.md`
§Rollen-Regeln: *„ADR-Änderung: Architect schreibt; Reviewer prüft auf Konsistenz; Implementer
liest als Constraint; Accepted-ADRs überschreibt **niemand**"*. Was dort **nicht** steht, ist der
**Akt** dazwischen: wer den Status umlegt und woran er sich dabei hält.

Diese Lücke ist nicht neu und nicht geschätzt. [ADR-0018](0018-ziel-fassung-regiert-die-migration.md)
§Geschichte hat sie am 2026-08-28 über die gerankten Quellen, das Briefing, den Harness-Einstieg,
den ADR-Index und den vendored Baum gemessen und als Negativ ausgewiesen; das
Beobachtungs-Register führt sie als `BEO-ALL/proposed-adr-annahme-ohne-repo-internen-traeger`.
Die gelebte Form ist überall dieselbe Zeile: *„Entscheidung des Auftraggebers vom `<Datum>`,
vollzogen in der Architect-Rolle."*

### Der Anlass — dieselbe Klasse, zweimal verschieden ausgegangen

Zwei Entscheidungen tragen einen Acceptance-Trigger in der Datei. Beide sind angenommen, und ihre
§Geschichte-Zeilen unterscheiden sich in genau einem Punkt:

| ADR | Trigger verlangt | Was die Accept-Zeile nennt |
|---|---|---|
| [ADR-0036](0036-ziel-fassung-regiert-den-sprung-v600.md) | Reviewer-Konsistenzrunden | **drei Reports namentlich**, ihre Befundzahl, und dass die dritte Runde keinen Rest feststellt |
| [ADR-0038](0038-ziel-fassung-regiert-den-sprung-v650.md) | *„ihr Report ohne blockierenden Befund in `docs/reviews/`"* | **keinen Beleg** — die Zeile nennt die Entscheidung und eine eingelöste Planner-Folgepflicht |

Der einzige Report zu [ADR-0038](0038-ziel-fassung-regiert-den-sprung-v650.md)
(`docs/reviews/2026-09-07-adr-0038-ziel-fassung-v650-review.md`) schließt mit *„Nicht annahmefähig
in dieser Runde — zwei HIGH"* und stellt selbst fest, er sei der verlangte Report nicht:

```sh
git grep -lF '0038-ziel-fassung-regiert-den-sprung-v650' -- 'docs/reviews/*.md'   # 2 Dateien
```

**Kein Erwartungswert**
([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — die zweite ist der Review-Report zu `slice-193`, der Anlass dieses Laufs, und
keine zweite Runde zu jener Entscheidung. Zwischen
dem Report und dem Accept-Commit liegt allein der Architect-Commit, der die zwei HIGH auflöst.
Die Rolle, deren Artefakt geprüft wurde, hat den Prüfbefund für erledigt erklärt und danach
angenommen; die Bestätigung, die der Trigger verlangt, ist eine **Nachmessung desselben
Kontexts**.

Seit `Accepted` ist die Datei nach [`AGENTS.md`](../../../AGENTS.md) §3.4 eingefroren. Der
Widerspruch zwischen ihrer Statuszeile und ihrem Trigger-Abschnitt ist damit **in ihr nicht mehr
behebbar** — das ist der Schaden, und er ist dauerhaft.

### Warum das keine Formalie ist

Der Acceptance-Trigger ist die einzige Stelle, an der eine ADR ihre eigene Prüfbedingung
formuliert. Wird er beim Übergang nicht gehalten, verliert der Statuswert seine Aussage: Ein
nachfolgender Lauf, der `Accepted` als Start-Bedingung liest — so wie es der Tausch-Slice tat —
liest dann eine Behauptung ohne Deckung, und §3.4 friert sie ein.

Und die Ursache ist der blinde Fleck, für den Rollen-Trennung überhaupt existiert: `v6.5.0`,
`modul-08-agentenrollen.md` §Kernidee — *„Rollentrennung verhindert, dass derselbe Kontext zweimal
denselben Fehler macht. Wer geplant hat, prüft nicht; wer geschrieben hat, reviewt nicht."* Der
Kontext, der einen Befund auflöst, ist derselbe, der ihn übersehen hat.

## Entscheidung

**Drei Festlegungen. Sie binden den Lauf, der den Status auf `Accepted` setzt.**

**1. Die Accept-Zeile der §Geschichte nennt den Beleg, den der Acceptance-Trigger der Datei
verlangt — als auflösbaren Zeiger, in der Form, die
[ADR-0027](0027-tote-adresse-in-eingefrorener-adr.md) für ein einfrierendes Artefakt vorschreibt
(Kennung, nicht Pfad-Link).** Trägt die Datei **keinen** Acceptance-Trigger, sagt die Zeile das
ausdrücklich; ein fehlender Trigger ist eine Aussage, kein Freibrief.

**2. Hat eine prüfende Runde einen blockierenden Befund gemeldet, ist der Beleg eine **erneute
Runde derselben prüfenden Rolle**.** Die Nachmessung durch den Kontext, der den Befund aufgelöst
hat, ist keiner — gleich wie sorgfältig sie ist und gleich ob ihr Ergebnis stimmt. Was sie belegt,
ist die Behebung; was der Trigger verlangt, ist die **Bestätigung**, und die ist ein
Übergabe-Artefakt einer anderen Rolle (`v6.5.0`, `modul-08-agentenrollen.md` §Die neun Übergaben
und ihre Artefakte).

**3. Soll ein **anderer** Beleg genügen als der, den der Trigger nennt, wird der Trigger geändert
— und zwar, solange die Datei `Proposed` ist.** Danach steht der Widerspruch fest: §3.4 friert
Statuszeile und Trigger-Abschnitt gemeinsam ein, und keine spätere Fassung repariert die Datei.

**Was diese Festlegungen nicht tun.**

- **Kein `Supersedes` auf [ADR-0038](0038-ziel-fassung-regiert-den-sprung-v650.md).** Ihr *Inhalt*
  ist geprüft und trägt — der Report bestätigt die Entscheidung und beanstandet den **Akt**. Eine
  Folge-ADR mit `Supersedes` entschiede eine richtige Sache neu; was defekt war, ist ein Vorgang,
  und Vorgänge werden nicht supersedet. Der Statuswert bleibt, wie er steht.
- **Sie benennen keinen annehmenden Akteur.** Wer entscheidet, bleibt offen wie bisher; entschieden
  ist, **woran** der annehmende Lauf sich hält. Die Setzung des Auftraggebers wird dadurch nicht
  eingeschränkt — sie wird nur nicht mehr als Ersatz für einen Beleg gelesen, den die Datei selbst
  verlangt. Weicht die Setzung vom Trigger ab, greift Festlegung 3.
- **Sie werden nicht zusätzlich Hard Rule.** [`AGENTS.md`](../../../AGENTS.md) §3 bindet **jeden**
  Lauf; dies bindet allein den Lauf, der eine ADR annimmt, und der liest ADRs von Berufs wegen.
  Eine zweite Fassung derselben Aussage in §3 driftete gegen diese hier.
- **Cutoff — ab dieser Entscheidung, kein Nachrüsten.** Gebunden ist der Übergang, der vollzogen
  wird; der Bestand der angenommenen ADRs ist kein Arbeitsauftrag und ohnehin eingefroren. Die
  Annahme **dieser** Datei fällt unter die alte Lage — ihr eigener Trigger unten sagt darum, was
  sie verlangt.

### Der Acceptance-Trigger

Diese Entscheidung steht auf `Proposed`. Sie wird `Accepted`, **wenn eine Reviewer-Runde sie gegen
[ADR-0018](0018-ziel-fassung-regiert-die-migration.md),
[ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) und
[ADR-0036](0036-ziel-fassung-regiert-den-sprung-v600.md) auf Konsistenz geprüft hat und ihr Report
ohne blockierenden Befund in `docs/reviews/` liegt.** Meldet eine Runde einen blockierenden
Befund, ist der Beleg nach Festlegung 2 die **nächste** Runde derselben Rolle, nicht die
Nachmessung des auflösenden Laufs.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — nichts tun, den Fall als Einzelfall notieren | keine neue Norm; der Zähler des Beobachtungs-Registers läuft weiter und entscheidet bei 3× | der Zähler ist der richtige Weg für eine **beobachtete** Klasse, nicht für eine, die den nächsten Schritt blockiert: [ADR-0039](0039-eingefrorene-adresse-in-den-vendored-baum.md) braucht heute einen Accept-Übergang, und ohne Regel wiederholte ihn derselbe Lauf, der sie geschrieben hat |
| B — Folge-ADR mit `Supersedes ADR-0038` | die Statuszeile bekäme eine Entscheidung, die ihren Trigger hält | entschiede eine inhaltlich geprüfte Sache neu, nur um einen Vorgang zu heilen. Der Report beanstandet den Akt, nicht die Festlegung; ein `Supersedes` behauptete das Gegenteil |
| C — einen annehmenden Akteur benennen | schlösse die Lücke, die [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) misst, an ihrer Wurzel | löste den beobachteten Fall **nicht**: der Akteur war benannt (Auftraggeber, vollzogen in der Architect-Rolle) und der Beleg fehlte trotzdem. Und sie griffe in eine Frage ein, die bei Personalunion dem Auftraggeber gehört ([`MR-015`](../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)) |
| D — Hard Rule in [`AGENTS.md`](../../../AGENTS.md) §3 statt ADR | §3 wird von jedem Lauf gelesen | §3 bindet jeden Lauf; dies bindet einen. Und die Regel spricht über die Innenform einer ADR — sie gehört in die Artefaktklasse, über die sie urteilt |
| **E — gewählt: drei Festlegungen an den Übergang, kein `Supersedes`, kein Akteur** | trifft genau den Defekt: der Beleg fehlte, und der vorhandene stammte aus dem falschen Kontext. Kostet keine bestehende Entscheidung, keine Rolle und keine Prüffläche; die Form, die Festlegung 1 verlangt, existiert bereits gelebt in [ADR-0036](0036-ziel-fassung-regiert-den-sprung-v600.md) | eine Regel ohne Sensor mehr. Sie hängt am Rollen-Wechsel vor dem Übergang, und der ist nicht mechanisch erzwingbar |

## Konsequenzen

- **Positiv:** Der Statuswert `Accepted` bekommt wieder eine Aussage. Ein Lauf, der ihn als
  Start-Bedingung liest, liest ab hier eine Bedingung mit benanntem Beleg.
- **Positiv:** Der zweite Blick liegt **vor** dem Einfrieren statt danach. Genau das ist die
  Eigenschaft, für die Rollen-Trennung existiert, und der Accept-Übergang ist der letzte Moment,
  in dem sie noch etwas kostet statt nichts mehr zu nützen.
- **Positiv:** Drei angenommene Entscheidungen hängen ihren Träger bereits an den
  Accept-Übergang ([ADR-0016](0016-verweis-traegt-tag-und-zitat.md) Träger (a),
  [ADR-0027](0027-tote-adresse-in-eingefrorener-adr.md),
  [ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md)). Sie setzen voraus, dass
  dieser Übergang ein benennbarer Moment ist; ab hier ist er einer.
- **Negativ, und es ist der Preis:** Jede Annahme kostet eine weitere Runde, wenn eine vorige
  blockierend war. Bei einer Kette von Befunden ist das eine Kette von Runden — der Fall
  [ADR-0037](0037-bootstrap-stellt-den-tag-0-zustand-her.md) zeigt, dass solche Ketten hier
  vorkommen.
- **Negativ:** Die Regel kann eine Entscheidung **blockieren**, deren Inhalt niemand bestreitet,
  weil ihre Bestätigungsrunde aussteht. Das ist gewollt und trotzdem Reibung.
- **Negativ /
  [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6):**
  **Kein Sensor.** Sie liegt im Feedforward-Quadranten; Träger ist der Rollen-Wechsel vor dem
  Übergang, nicht ein Gate danach.
- **Folgepflicht (Planner), fällig unabhängig von dieser Entscheidung:** Der beobachtete Fall
  gehört als Beleg in `BEO-ALL/proposed-adr-annahme-ohne-repo-internen-traeger` oder in eine
  eigene Beobachtung — das Register ist Planner-Eigentum und wird von dieser Entscheidung nicht
  angefasst.
- **Darüber hinaus ändert diese ADR keine Datei außer sich selbst und dem ADR-Index.**

## Fitness Function (falls maschinell prüfbar)

**Gebaut: keine** — und die Kandidaten sind einzeln geprüft, statt die Lücke zu verschweigen.

| Kandidat | Warum er die Regel nicht misst |
|---|---|
| `make docs-check` mit der heutigen Modul-Liste (`grep -n '^modules:' .d-check.yml`) | keines der geführten Module liest einen Statuswert, eine Status-**Änderung** oder ein Report-Verdikt |
| Modul `reviews` des gepinnten d-check (verfügbar, **nicht** aktiviert) | es prüft die **Deckung** zwischen einer Review-Zusage und einem Report, nicht, ob der Report *nach* dem Befund und *vor* dem Statuswechsel entstand |
| Modul `vcs`/`commits` (verfügbar, kein Aufrufer) | sie lesen Historie, aber die Frage ist eine **Reihenfolge zweier Commits gegen ein Report-Verdikt** — dieselbe Lücke, die [ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) für sich benennt |
| `make mutate` | kennt zwei Fehlschlag-Formen, `--- FAIL:` und `not ok N`; keine, in der ein Status-Übergang rot wird |

**Was ein Sensor könnte, wenn er gebaut würde:** die Existenz eines auflösbaren Belegs in der
Accept-Zeile prüfen — Form und Auflösbarkeit sind urteilsfrei. **Was er nicht könnte:** ob der
Beleg aus dem richtigen Kontext stammt. Das bleibt Urteil, wie beim Beobachtungs-Register.

## Re-Evaluierungs-Trigger

- **Wenn eine Quelle einen annehmenden Akteur benennt** *(beobachtbar an einer Baseline-Fassung
  oder einer Änderung an [ADR-0018](0018-ziel-fassung-regiert-die-migration.md)s Messung)*: Dann
  ist Option C wieder offen und diese Entscheidung gegen sie zu halten.
- **Wenn eine ADR angenommen wird, deren Accept-Zeile keinen Beleg nennt** *(feedforward, kein
  Gate meldet es)*: Festlegung 1 ist gebrochen, und der Vorgang gehört zurück in dieses Gefäß.
- **Wenn das Modul `reviews` aktiviert wird** *(beobachtbar an `modules:` in
  [`.d-check.yml`](../../../.d-check.yml))*: Die Fitness-Tabelle oben ist neu zu halten — die
  Deckungs-Hälfte hätte dann einen Sensor.
- **Wenn eine Bestätigungsrunde eine Entscheidung länger als eine Welle blockiert**
  *(beobachtbar an einer `Proposed`-ADR, deren Trigger seit der letzten Welle-Closure offen
  steht)*: Der Preis aus §Konsequenzen ist eingetreten und die Regel gegen ihn zu halten.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-09-07 | **Proposed** | Architect-Lauf; Anlass ist HIGH-1 des Review-Reports zu `slice-193` |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0040` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).
