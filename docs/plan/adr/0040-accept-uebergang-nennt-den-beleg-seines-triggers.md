# ADR-0040: Der Accept-Übergang nennt den Beleg, den der eigene Acceptance-Trigger verlangt — und der Kontext, der den blockierenden Befund auflöste, ist keiner

**Status:** Proposed

**Datum:** 2026-09-07

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[ADR-0018](0018-ziel-fassung-regiert-die-migration.md) (ihre §Geschichte trägt die Messung, dass
**keine** Quelle dieses Repos und keine der vendored Baseline einen annehmenden Akteur benennt —
diese Entscheidung lässt das *Wer* offen und bindet das *Woran*; die Messung trägt Alternative C),
[ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) (benachbarte Bauart auf einer anderen
Achse: dort bekommen zwei Norm-Artefakte eine **schreibende Rolle**, hier bekommt ein
**Status-Übergang** seine Bedingung — die Zuständigkeit bleibt unberührt),
[ADR-0038](0038-ziel-fassung-regiert-den-sprung-v650.md) (`Accepted`, der gemessene Anlass; sie
wird von dieser Entscheidung **nicht** abgelöst),
[ADR-0036](0036-ziel-fassung-regiert-den-sprung-v600.md) (dieselbe Klasse, an derselben Stelle
belegt — die **Sache**, die Festlegung 1 verallgemeinert; ihre Adress-Form führt sie nicht),
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

Der einzige Report zu [ADR-0038](0038-ziel-fassung-regiert-den-sprung-v650.md) — die
Reviewer-Runde vom 2026-09-07 zu jener Entscheidung — schließt mit *„Nicht annahmefähig in dieser
Runde — zwei HIGH"* und stellt selbst fest, er sei der verlangte Report nicht: *„dieser Report ist
es nicht; er blockiert an HIGH-1 und HIGH-2"*.

```sh
git grep -lF '0038-ziel-fassung-regiert-den-sprung-v650' -- 'docs/reviews/*.md'
```

**Neben diesem Kommando steht keine Zahl, und der Grund ist Festlegung 2 unten, auf diese Datei
selbst angewandt.** Der Korpus `docs/reviews/` wächst mit jeder Runde, die jene Festlegung
verlangt; zwischen dem Stand, an dem eine Zahl über ihn in eine `Proposed`-ADR geschrieben wird,
und der Annahme derselben Datei liegt darum mindestens ein weiterer Report. Eine solche Zahl ist im
Moment ihrer eigenen Annahme falsch — nicht gelegentlich, sondern immer. Der Zusatz *„kein
Erwartungswert"*
([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) trägt sie nicht: Er deckt Drift **nach** dem Schreiben, und hier bewegt der schreibende
Vorgang die Zahl selbst. Tragend ist ohnehin eine Eigenschaft und kein Betrag: **Keine** der
ausgegebenen Dateien ist eine zweite Runde zu jener Entscheidung — sie nennen sie als Bezug.
Zwischen dem Report und dem Accept-Commit liegt allein der Architect-Commit, der die zwei HIGH
auflöst. Die Rolle, deren Artefakt geprüft wurde, hat den Prüfbefund für erledigt erklärt und
danach angenommen; die Bestätigung, die der Trigger verlangt, ist eine **Nachmessung desselben
Kontexts**.

**Wogegen die zwei HIGH sich richten, gehört dazu, weil es die Reichweite dieser Entscheidung
begrenzt.** Sie treffen den **Inhalt** — *„Die Festlegung deckt den Sprung nicht, den der abhängige
Plan führt"* und *„Der Zielstand `v6.5.0` ist im Repo nirgends gesetzt"* —, nicht den Akt; den kann
jener Report nicht beanstanden, denn er ist älter als er. Ob die *Festlegung* von
[ADR-0038](0038-ziel-fassung-regiert-den-sprung-v650.md) trägt, ist damit **nach Aktenlage offen**:
Es gibt dazu eine Nachmessung des schreibenden Kontexts und sonst nichts. Was **feststeht**, ist
allein, dass ihr Akt den Beleg übersprang, den ihr eigener Trigger verlangt. Diese Entscheidung
regelt darum den Akt und maßt sich über den Inhalt kein Urteil an.

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
verlangt — als auflösbaren Zeiger, in der Form, die [`AGENTS.md`](../../../AGENTS.md) §3.11 für ein
einfrierendes Artefakt vorschreibt: Kennung, nicht Pfad-Link, über **beide** Adress-Formen.**
Trägt die Datei **keinen** Acceptance-Trigger, sagt die Zeile das ausdrücklich; ein fehlender
Trigger ist eine Aussage, kein Freibrief. Die erste Fassung dieser Adress-Regel steht in
[ADR-0027](0027-tote-adresse-in-eingefrorener-adr.md) Festlegung 3, dort für Carveouts geschnitten;
§3.11 trägt sie für jedes Artefakt, dessen Ort der Prozess bewegt.

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

- **Kein `Supersedes` auf [ADR-0038](0038-ziel-fassung-regiert-den-sprung-v650.md) — und der Grund
  ist Verfügbarkeit, nicht Entbehrlichkeit.** Defekt ist ein **Vorgang**: Der Akt sprang über den
  Beleg, den der eigene Trigger jener Datei verlangt. Ob ihre *Festlegung* trägt, ist damit nicht
  entschieden (§Kontext). Ein `Supersedes` setzt jedoch eine **neue Entscheidung über denselben
  Gegenstand** voraus — über den Sprung `v6.0.0` → `v6.5.0` —, und dieser Lauf hat sie nicht: Er
  entscheidet über den Übergang, nicht über den Sprung, und der einzige Beleg, der ihm für den
  Inhalt zur Verfügung stünde, ist die Nachmessung, die Festlegung 2 gerade verwirft. Ein
  `Supersedes` auf dieser Grundlage wiederholte den Fehler eine Ebene höher. Es reparierte den
  Schaden auch nicht: Statuszeile und Trigger-Abschnitt jener Datei sind nach
  [`AGENTS.md`](../../../AGENTS.md) §3.4 eingefroren, gleich was daneben beschlossen wird. Der
  Statuswert bleibt, wie er steht; was aussteht, ist die Runde — sie steht unten als Folgepflicht.
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
  sie verlangt. **Sind zwei Übergänge gleichzeitig fällig, ordnet der annehmende Lauf sie
  ausdrücklich**, statt sie der Reihenfolge zweier Commits zu überlassen: Ein Commit trägt keine
  Ordnung, und beide Accept-Zeilen frieren ein. Für
  [ADR-0039](0039-eingefrorene-adresse-in-den-vendored-baum.md) ist der Übergang **nach** diesem
  vollzogen; ihre Accept-Zeile trägt Festlegung 1 damit vollständig, einschließlich der
  ausdrücklichen Aussage über den fehlenden Acceptance-Trigger.

### Der Acceptance-Trigger

Diese Entscheidung steht auf `Proposed`. Sie wird `Accepted`, **wenn eine Reviewer-Runde sie gegen
[ADR-0018](0018-ziel-fassung-regiert-die-migration.md),
[ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) und
[ADR-0036](0036-ziel-fassung-regiert-den-sprung-v600.md) auf Konsistenz geprüft hat und ihr Report
ohne blockierenden Befund in `docs/reviews/` liegt.** Meldet eine Runde einen blockierenden
Befund, ist der Beleg nach Festlegung 2 die **nächste** Runde derselben Rolle, nicht die
Nachmessung des auflösenden Laufs.

**Und ihre Accept-Zeile nennt diesen Beleg.** Festlegung 1 gilt für diese Datei damit ebenso,
obwohl der Cutoff sie vom Bestand ausnimmt: Der Trigger holt **beide** Hälften zurück, nicht eine.
Eine korrigierende Entscheidung, deren Accept-Zeile die Form der korrigierten trüge, wäre keine.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — nichts tun, den Fall als Einzelfall notieren | keine neue Norm; der Zähler des Beobachtungs-Registers läuft weiter und entscheidet bei 3× | der Zähler ist der richtige Weg für eine **beobachtete** Klasse, nicht für eine, die den nächsten Schritt blockiert: [ADR-0039](0039-eingefrorene-adresse-in-den-vendored-baum.md) braucht heute einen Accept-Übergang, und ohne Regel wiederholte ihn derselbe Lauf, der sie geschrieben hat |
| B — Folge-ADR mit `Supersedes ADR-0038` | die Statuszeile bekäme eine Entscheidung, die ihren Trigger hält | `Supersedes` verlangt eine neue Entscheidung über den Sprung `v6.0.0` → `v6.5.0`; dieser Lauf hat sie nicht und prüft den Übergang, nicht den Sprung. Der einzige Inhalts-Beleg, der ihm zur Verfügung stünde, ist die Nachmessung, die Festlegung 2 verwirft. Und er repariert nichts: [ADR-0038](0038-ziel-fassung-regiert-den-sprung-v650.md) bleibt mit ihrem Widerspruch nach [`AGENTS.md`](../../../AGENTS.md) §3.4 eingefroren |
| C — einen annehmenden Akteur benennen | schlösse die Lücke, die [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) misst, an ihrer Wurzel | löste den beobachteten Fall **nicht**: der Akteur war benannt (Auftraggeber, vollzogen in der Architect-Rolle) und der Beleg fehlte trotzdem. Und sie griffe in eine Frage ein, die bei Personalunion dem Auftraggeber gehört ([`MR-015`](../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)) |
| D — Hard Rule in [`AGENTS.md`](../../../AGENTS.md) §3 statt ADR | §3 wird von jedem Lauf gelesen | §3 bindet jeden Lauf; dies bindet einen. Und die Regel spricht über die Innenform einer ADR — sie gehört in die Artefaktklasse, über die sie urteilt |
| **F — mitgewählt: die ausstehende Bestätigungsrunde zu [ADR-0038](0038-ziel-fassung-regiert-den-sprung-v650.md) nachholen, ohne die Datei anzufassen** | der Trigger bekäme, was er verlangt — ein Übergabe-Artefakt der prüfenden Rolle statt einer Nachmessung. Der Beleg liegt an einem **lebenden** Ort, die eingefrorene Datei bleibt unberührt, und die Frage nach ihrem Inhalt bekommt endlich einen zweiten Kontext | heilt die Accept-Zeile **nicht** — sie ist eingefroren und nennt weiterhin keinen Beleg; der Schaden bleibt dauerhaft. Und die Runde entscheidet nichts: eine Prüfung ist keine Norm, die Klasse bliebe ungeregelt. **Nicht exklusiv zu E** — F behandelt die Instanz, E die Klasse |
| **E — gewählt, zusammen mit F: drei Festlegungen an den Übergang, kein `Supersedes`, kein Akteur** | trifft genau den Defekt: der Beleg fehlte, und der vorhandene stammte aus dem falschen Kontext. Kostet keine bestehende Entscheidung, keine Rolle und keine Prüffläche; die **Sache**, die Festlegung 1 verlangt — Beleg genannt, Befundzahl genannt, kein Rest festgestellt —, existiert bereits gelebt in [ADR-0036](0036-ziel-fassung-regiert-den-sprung-v600.md), deren Accept-Zeile ihre drei Reports allerdings als Pfade in Inline-Code führt statt als Kennung | eine Regel ohne Sensor mehr. Sie hängt am Rollen-Wechsel vor dem Übergang, und der ist nicht mechanisch erzwingbar. Für die **Instanz**, die sie ausgelöst hat, trägt sie nichts — dafür steht F daneben |

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
- **Negativ, und Festlegung 2 verursacht ihn:** Eine Zahl über `docs/reviews/**` ist in einer
  `Proposed`-ADR nicht mehr einholbar. Der Korpus wächst durch das Prüfverfahren, das zwischen dem
  Schreiben und der Annahme mindestens eine weitere Runde erzwingt; wer den Betrag braucht, nennt
  ihn mit Stichtag, im Report statt in der Entscheidung, oder als Verhältnis.
- **Negativ, und der Cutoff verursacht ihn:** Für den Bestand ändert sich nichts. Die Instanz, die
  diese Entscheidung ausgelöst hat, bleibt mit einem unbelegten Trigger stehen; sie bekommt ihren
  zweiten Kontext allein über die Folgepflicht unten, nicht über die drei Festlegungen.
- **Negativ /
  [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6):**
  **Kein Sensor.** Sie liegt im Feedforward-Quadranten; Träger ist der Rollen-Wechsel vor dem
  Übergang, nicht ein Gate danach.
- **Folgepflicht (Planner), fällig unabhängig von dieser Entscheidung — Option F:** Die
  Bestätigungsrunde, die der Acceptance-Trigger von
  [ADR-0038](0038-ziel-fassung-regiert-den-sprung-v650.md) verlangt, steht aus. Sie gehört
  eingeplant, und ihr Beleg an einen **lebenden** Ort — die eingefrorene Datei nimmt ihn nicht mehr
  auf. Ohne sie bleibt jener Trigger unbelegt, und der Statuswert, den nachfolgende Läufe als
  Start-Bedingung lesen, sagt über den Inhalt weiterhin nichts.
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
- **Wenn die Runde aus Option F einen blockierenden Befund gegen den Inhalt von
  [ADR-0038](0038-ziel-fassung-regiert-den-sprung-v650.md) meldet** *(beobachtbar an einem dritten
  Report zu jener Entscheidung)*: Dann ist ihre Festlegung nicht nur unbelegt, sondern bestritten,
  und Option B ist mit neuer Evidenz erneut zu halten.
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
