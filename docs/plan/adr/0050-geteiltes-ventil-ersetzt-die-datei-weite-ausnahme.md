# ADR-0050: Das geteilte Referenz-Ventil ersetzt die datei-weite Ausnahme für die eingefrorene ADR-0013

**Status:** Proposed

**Datum:** 2026-09-14

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[ADR-0017](0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) (deren Re-Evaluierungs-Trigger 2
in Kraft ist; diese Entscheidung ersetzt genau den einen `scan.ignore`-Eintrag, den sie setzt, und
lässt ihre Aufnahme-Grenze unberührt),
[ADR-0013](0013-technik-stratum-als-zielort.md) (die betroffene Datei; sie wird nicht angefasst —
ihr Befund ist in ihr nicht behebbar),
[ADR-0016](0016-verweis-traegt-tag-und-zitat.md) (Festlegung 1 — der Bestand wird nicht geheilt;
Festlegung 2 — Eigenschaft statt Adresse, darum trägt jede Baseline-Stelle unten Tag und Zitat),
[ADR-0023](0023-verweis-beschluss-traegt-ueber-den-sprung.md) (hält jenen Beschluss gegen den
adoptierten Stand neu),
[ADR-0026](0026-eingefrorene-referenz-referenz-weit-ausgenommen.md) (die Messung des geteilten
Ventils, und die Abgrenzung, die den Vorgang dieser Datei ausdrücklich in eine eigene Entscheidung
verweist),
[ADR-0032](0032-eingefrorene-referenz-folgt-ihrem-rumpf.md) (der Präzedenzfall: eine Folge-ADR mit
Teil-`Supersedes` auf einen **wörtlich** genannten Wert einer `Accepted`-ADR),
[ADR-0039](0039-eingefrorene-adresse-in-den-vendored-baum.md) (dieselbe Werkzeug-Fähigkeit eine
Achse weiter — baum-weit statt paarweise),
[`MR-034`](../../../harness/conventions.md#mr-034--das-geteilte-referenz-ventil-trägt-am-gepinnten-stand)
(die Werkzeug-Aussage über den geteilten Schlüssel),
[`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben dem Kommando, das sie liefert),
[`MR-033`](../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
(jede Baseline-Aussage nennt ihren Tag),
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (ein Gate,
dessen Befund unbehebbar ist, erzieht dazu, Rot zu überlesen),
[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (der Tausch des
`<tag>`-gescopten Baums ist der Auslöser)

**Schärft:** — Prozess-ADR ohne Spec-Stratum: sie **hebt** eine Gate-Ausnahme an, sie ändert keine
Spec-Aussage.

**Supersedes (Teil):** [ADR-0017](0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md)
§Entscheidung, und dort genau **einen** Gegenstand — den einen `scan.ignore`-Eintrag für
`docs/plan/adr/0013-technik-stratum-als-zielort.md`. Alles andere jener Entscheidung bindet
unverändert fort: die Aufnahme-**Grenze** (*„jeder zusätzliche Eintrag ist eine neue Senkung und
löst [`AGENTS.md`](../../../AGENTS.md) §3.5 erneut aus"*), der Config-Kommentar als Träger der
Begründung und die Kopplung an [ADR-0016](0016-verweis-traegt-tag-und-zitat.md). Diese ADR nimmt
keine davon weg; sie **zieht** einen Eintrag zurück, statt einen hinzuzufügen.

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md` §Ziel-Form: ADR (MADR). Den lebenden d-check-Pin
führt [`d-check.mk`](../../../d-check.mk); er steht hier nicht als zweite Fassung
([`harness/conventions.md`](../../../harness/conventions.md#baseline) §Baseline).

---

## Kontext

### Die Bedingung ist erfüllt, und die Prämisse trug nie

[ADR-0017](0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) nimmt unter `scan.ignore` genau
eine Datei aus und begründet die Grobheit — die Datei verlässt den Gate **ganz**, statt nur ihren
einen toten Link zu verlieren — mit einer Werkzeug-Lage. Ihr §Kontext führt die Tabelle, aus der die
Folgerung stammt:

> *„`links` und `anchors` tragen überhaupt keine Options-Sektion. Der Knopf, den dieses Repo
> bräuchte, hieße `links.ignore-refs` … solange es ihn nicht gibt, bleibt nur `scan.ignore`."*

und ihre §Konsequenzen schreiben dieselbe Folgerung als Negativ-Posten aus:

> *„Diese Grobheit ist erzwungen, nicht gewählt — der referenz-weite Knopf existiert nicht."*

Ihr Re-Evaluierungs-Trigger 2 nennt die Bedingung, unter der die Ausnahme weichen soll: *„Wenn
`links` einen referenz-weiten Ausschluss bekommt … dann ist der datei-weite Eintrag durch den
präzisen zu ersetzen, und der Preis über fünf Module entfällt. Das ist der Zustand, den diese ADR
eigentlich will."*

**Die Bedingung ist erfüllt, und sie war es schon, als jene Datei geschrieben wurde.** Der gepinnte
d-check führt `ignore-refs` als **Top-Level**-Schlüssel, den `links`, `anchors` und `codepaths`
gemeinsam honorieren, mit `in` und `refs` je als Dateiname oder Glob. Der Schlüssel ist **älter als
der Pin** und wurde zwischen seiner Einführung und ihm nicht entfernt:

```sh
grep -n '^DCHECK_IMAGE' d-check.mk
grep -c '^## \[0\.49\.0\]' <Klon des d-check-Repos>/CHANGELOG.md                                          # 1
awk '/^## \[0\.65\.0\]/,/^## \[0\.49\.0\]/' <Klon des d-check-Repos>/CHANGELOG.md | grep -c '^### Removed'  # 0
```

**Keine Erwartungswerte** ([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2); die zwei folgenden Kommandos lesen den Klon des Werkzeug-Repos und sind damit netzlos nur dort
fahrbar, wo er liegt.

[ADR-0017](0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) suchte den Knopf **modul-lokal** —
`links.ignore-refs` — und schloss aus seiner Abwesenheit auf die fehlende Fähigkeit. Genau diesen
Schluss hat [ADR-0026](0026-eingefrorene-referenz-referenz-weit-ausgenommen.md) §Kontext
zurückgenommen: *„Der Name, unter dem man ihn sucht, ist nicht der, unter dem er steht. Wer unter
`links:` nach `ignore-refs` sucht, findet nichts; `d-check --print-config` gibt eine kommentierte
Beispiel-Config aus, keine Schema-Liste, und Abwesenheit darin ist keine Abwesenheit der Option."*
Dieselbe Datei hat das Ventil an einer roten Gegenprobe **gemessen** — `in: "harness/conventions.md"`
gegen das eine tote Ziel liefert `0 Befund(e)` bei **unveränderter** Datei-Zahl, ein Nachbarziel und
eine Nachbar-Quelldatei bringen den Befund je zurück.

**Der Folge-Vorgang war dorthin verwiesen, und er ist nie gefahren.** Die Abgrenzungs-Sektion jener
Entscheidung sagt es wörtlich: *„Was jene Entscheidung über die **Werkzeug-Lage** feststellt, trägt
diese ADR nicht fort; die Nachmessung steht im Kontext, und was daraus für jene Entscheidung folgt,
gehört in eine eigene."* Diese Datei ist diese eigene.

### Was hier nicht zur Debatte steht

- **Der Befund in [ADR-0013](0013-technik-stratum-als-zielort.md) ist unverändert richtig und
  unverändert unbehebbar.** Der Link zeigt unter einen Tag, den der Baum-Tausch abgelöst hat, und
  die Datei steht auf `Accepted` ([`AGENTS.md`](../../../AGENTS.md) §3.4). Weder Tag noch Adresse
  werden angefasst; die Reparatur-Alternativen sind in
  [ADR-0016](0016-verweis-traegt-tag-und-zitat.md) und
  [ADR-0023](0023-verweis-beschluss-traegt-ueber-den-sprung.md) verworfen, und diese ADR hält sie
  nicht neu.
- **Die Aufnahme-Grenze aus [ADR-0017](0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) gilt
  fort.** Diese Entscheidung ist keine weitere Ausnahme; sie ist die **Rücknahme** einer, die ihr
  eigener Trigger für erledigt erklärt. Ein zweites eingefrorenes Artefakt mit gebrochenem
  Baseline-Link bleibt von ihr ungedeckt.

### Gemessen, in vier Läufen über den unveränderten Baum

Jeder Lauf fährt `make docs-check` gegen den gepinnten Digest aus
[`d-check.mk`](../../../d-check.mk), netzlos, Mount `:ro`; die Config wird für die Dauer des Laufs
geändert und danach zurückgesetzt — der Arbeitsbaum ist am Ende der Läufe leer
(`git status --porcelain` gibt nichts aus). **Keine Erwartungswerte**
([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — beide Zahlen wandern mit dem Markdown-Bestand:

| Lauf | `scan.ignore` | `ignore-refs` | Ergebnis |
|---|---|---|---|
| **Bestand** | trägt die ADR-0013 | unverändert | `1367 Datei(en) geprüft, 0 Befund(e)` |
| **Gegenprobe Datei-Achse** | trägt die ADR-0013 **nicht** | unverändert | `1368 Datei(en) geprüft, 1 Befund(e)` — `0013-technik-stratum-als-zielort.md:48 … target-missing` |
| **Sonde** | trägt die ADR-0013 **nicht** | `in: "docs/plan/adr/0013-technik-stratum-als-zielort.md"`, `refs: [".harness/baseline/v3.5.2/regelwerk/grundlagen-konventionen.md"]` | `1368 Datei(en) geprüft, 0 Befund(e)` |
| **Gegenprobe Quell-Skopus** | trägt die ADR-0013 **nicht** | dasselbe `refs`, `in: "AGENTS.md"` | `1368 Datei(en) geprüft, 1 Befund(e)` — derselbe Befund kehrt zurück |

**Tragend ist die Kombination zweier Zeilen, nicht eine Zahl.** Die zweite zeigt, was die
datei-weite Ausnahme verschweigt — genau **ein** Befund; die dritte zeigt, dass die Referenz-Achse
ihn trägt, **ohne** dass die geprüfte Datei-Zahl fällt; die vierte zeigt, dass die `in`-Seite des
Paares die Arbeit tut und nicht der gepinnte Digest allein. Die geprüfte Datei-Zahl **steigt** um
eins: die Datei kehrt in den Prüfbereich zurück, den [ADR-0017](0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md)
für ihren einen Link geräumt hatte.

## Entscheidung

**Wir wählen Option E: der `scan.ignore`-Eintrag aus
[ADR-0017](0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) wird zurückgezogen und durch genau
ein Referenz-Paar ersetzt** —

- `scan.ignore` behält `["**/*.template.md", ".tmp/**", ".harness/baseline/**", "docs/user/claude-hooks-referenz.md"]`
  — die drei Scoping-Einträge und die eine fremde Quelle, ohne die ADR-0013;
- `ignore-refs` bekommt **ein** weiteres Paar, extensional geschlossen:
  - `in: "docs/plan/adr/0013-technik-stratum-als-zielort.md"`
  - `refs: [".harness/baseline/v3.5.2/regelwerk/grundlagen-konventionen.md"]`
  - mit dem Config-Kommentar, dem Zeiger auf **diese** ADR und der Deklaration `Deckung: 1`.

**und kein weiteres.** Jeder weitere Eintrag, jedes weitere Glob und jede Verbreiterung eines der
beiden Skopen ist nach §3.5 eine eigene Entscheidung — die Grenze aus
[ADR-0017](0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) und
[ADR-0026](0026-eingefrorene-referenz-referenz-weit-ausgenommen.md) gilt für dieses Paar
unverändert.

**Warum es trotzdem ein Gefäß braucht.** Der `scan.ignore`-Eintrag steht **wörtlich** in
§Entscheidung einer `Accepted`-ADR. Ihn zurückzuziehen ist kein stilles Nachziehen, sondern die
Bewegung eines Werts, den [`AGENTS.md`](../../../AGENTS.md) §3.4 einfriert — dieselbe Lage, für die
[ADR-0032](0032-eingefrorene-referenz-folgt-ihrem-rumpf.md) mit einem Teil-`Supersedes` auf den
`in:`-Wert von [ADR-0026](0026-eingefrorene-referenz-referenz-weit-ausgenommen.md) gebildet wurde.
Die Richtung ist dabei die Gegenrichtung der bisherigen Ventile: Jene haben eine Senkung
**eröffnet**; diese **schließt** eine.

**Was diese Entscheidung nicht tut.** Sie ändert
[ADR-0013](0013-technik-stratum-als-zielort.md) nicht und
[ADR-0017](0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) nicht — die eine ist eingefroren,
die andere wird durch diesen Teil-`Supersedes` nicht überschrieben, sondern in genau einem Wert
abgelöst. Sie ändert keine Datei; der Eintrag und das Paar sind Implementer-Arbeit, und diese
Entscheidung ist ihr Constraint.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — nichts tun, die Ausnahme bestätigen | kein Schreibaufwand, keine Config-Änderung; der Gate bleibt grün | Der Re-Evaluierungs-Trigger 2 von [ADR-0017](0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) ist erfüllt und die Prämisse seiner Negativ-Konsequenz ist widerlegt; die Datei bleibt aus **fünf** Modulen draußen, obwohl **ein** Link das Problem ist. Eine erfüllte Bedingung ohne Ausgang ist die Absichtserklärung mit Verfallsdatum (Baseline-Regelwerk `v6.8.0`, `modul-06-roadmap.md` §Wellen-Closure-Prozedur Schritt 2) |
| B — nur die Werkzeug-Aussage richtigstellen, den Eintrag stehen lassen | eine Zeile Prosa, kein Config-Risiko | Die Aussage steht in einer `Accepted`-ADR und ist nach §3.4 dort nicht behebbar; sie zu berichtigen **ist** die Bewegung eines eingefrorenen Werts. Und sie berichtigt nur den Text, nicht die Wirkung: Der Preis von fünf Modulen bliebe gezahlt |
| C — [ADR-0013](0013-technik-stratum-als-zielort.md) mit einer Folge-ADR superseden | löste auch jeden künftigen Verweis auf sie | dieselbe Verwerfung, die [ADR-0016](0016-verweis-traegt-tag-und-zitat.md) als Option E führt: *„die Entscheidung hat sich nicht geändert; ein Supersede für einen kaputten Pfad ist ADR-Inflation und macht aus einem Doku-Defekt einen Entscheidungs-Vorgang"* — und `matrix.status` verbietet Verweise auf superseded ADRs, während **22** Verweis-Vorkommen aus **11** lebenden Dateien auf sie zeigen (Kommando in [ADR-0017](0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) §Konsequenzen; die Zahl wächst mit jedem neuen Verweis) |
| D — `refs` auf `.harness/baseline/**` verbreitern | deckte jeden künftigen toten Tag-Verweis derselben Quelldatei | **intensional statt extensional**: autorisiert künftige Referenzen im Voraus und legt §3.5 still. Dieselbe Verwerfung wie die Option E' in [ADR-0026](0026-eingefrorene-referenz-referenz-weit-ausgenommen.md). Zudem ist die Datei eingefroren — sie kann keine zweite Referenz erwerben, und die eine steht auf einem Pfad, der tot bleibt: der Wert ist tag-stabil, ohne Glob zu sein |
| **E — gewählt: Eintrag zurückziehen, ein geschlossenes Paar setzen** | die Datei kehrt in den Prüfbereich zurück; der Preis schrumpft von fünf Modulen auf eine Referenz; beide Skopen sind an je einer roten Gegenprobe belegt; die Grenze hängt weiter an §3.5 statt an einer Prognose | ein Paar mehr in einer kuratierten Liste und ein Config-Kommentar, der gepflegt werden will; die geprüfte Datei-Zahl **steigt** um eins, und ein künftiger Verweis derselben Datei auf ein anderes totes Ziel fiele nicht mehr unter die Ausnahme — er meldete sich, statt still zu bleiben |

## Konsequenzen

- **Positiv:** Die Datei verlässt den Gate nicht mehr. Vier der fünf damals betroffenen Module —
  `anchors`, `ids`, `matrix`, `codepaths` — prüfen sie wieder; `links` prüft sie bis auf die eine
  ausgenommene Referenz. Der Preis der Senkung schrumpft von *eine Datei, fünf Module* auf *eine
  Referenz*.
- **Positiv:** Die Ausnahme kann nicht stillschweigend wachsen. Sie ist wie die vier Paare vor ihr
  extensional geschlossen, und ihre Breite hat einen Wächter
  (`test/ignore-refs-restbreite.bats`) statt nur einer Messung — die Deklaration `Deckung: 1` steht
  im Config-Kommentar.
- **Positiv — und das ist die Richtung:** Diese Entscheidung ist ein **Gate-Anheben**. Sie
  löst [`AGENTS.md`](../../../AGENTS.md) §3.5 **nicht** aus; die Prüfung wird strenger, nicht
  lascher.
- **Negativ:** Die Werkzeug-Aussage in [ADR-0017](0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md)
  §Kontext und §Konsequenzen bleibt **falsch stehen**. Sie ist ab `Accepted` nicht behebbar, und
  der Teil-`Supersedes` nimmt ihr den Gegenstand, nicht den Satz. Wer sie liest, liest einen
  Befund, kein Argument — dieselbe Einordnung, die
  [ADR-0048](0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) §Kontext für eine Contra-Zelle
  trifft (*„Diese Stelle ist ein Befund, keine Quelle"*).
- **Negativ:** Der Config-Kommentar zum `scan.ignore`-Eintrag fällt mit dem Eintrag weg. Seine
  Begründung ist nicht verloren — sie steht im Eintrag von
  [ADR-0017](0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) und in dieser Datei —, aber der
  nächstliegende Ort am Config-Ort ist dann die Paar-Zeile.
- **Folgepflicht 1 (der Lauf, der diese ADR annimmt):** den `scan.ignore`-Eintrag entfernen und das
  Paar samt Kommentar, Zeiger und `Deckung: 1` setzen; mit **einem** `make docs-check` belegen, dass
  der Befund aus der Gegenprobe-Zeile oben nicht mehr erscheint, und mit **einem** Lauf `make gates`
  belegen, dass `test/ignore-refs-restbreite.bats` die Deklaration trägt.
- **Folgepflicht 2 (derselbe Lauf):** die zwei Kommentar-Posten am `ignore-refs`-Block nachziehen,
  die die Paar-Menge aufzählen — der Übersichts-Kommentar *„die vier Paare ADR-0026/ADR-0027/ADR-0030/ADR-0034"*
  und die `§3.5`-Grenze darunter nennen die Menge; mit dem neuen Paar sind es fünf vor den drei
  Baum-Einträgen aus [ADR-0039](0039-eingefrorene-adresse-in-den-vendored-baum.md).
- **Folgepflicht 3 (derselbe Lauf):** den `scan.ignore`-Zensus in
  [`MR-029`](../../../harness/conventions.md#mr-029--der-scanignore-zensus-wandert-und-sein-dritter-grund-ist-keine-scoping-aussage)
  nachführen, der die Einträge **zählt und klassifiziert** — die Liste fällt um eins, und der eine
  Nicht-Scoping-Eintrag aus [ADR-0017](0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) fällt
  mit ihm. **Diese ADR ändert keine Datei.**

## Fitness Function (falls maschinell prüfbar)

| Tooling | Regel | Make-Target |
|---|---|---|
| d-check `links` + `anchors` | jeder Markdown-Link aus [ADR-0013](0013-technik-stratum-als-zielort.md) **außer** dem einen ausgenommenen Ziel löst auf — die Datei ist damit wieder bewacht, statt ganz ausgenommen | `make docs-check` |
| d-check `ids` / `matrix` / `codepaths` | die Datei kehrt in den Prüfbereich dieser drei Module zurück; ihre Kennungs-Nennungen, ihre Rolle als Matrix-Quelle und ihre Inline-Code-Pfade sind wieder Gegenstand | `make docs-check` |
| `test/ignore-refs-restbreite.bats` | das Paar deckt höchstens **einen** auflösenden Markdown-Link seiner Quelldatei; der Wächter liest den `in:`-Wert als Pfad und fällt, wenn er ins Leere zeigt | `make gates` |

**Nicht gebaut:** dass eine Verbreiterung dieses Paares eine neue ADR verlangt, ist eine
Hard-Rule-Aussage ([`AGENTS.md`](../../../AGENTS.md) §3.5) und wird von keinem Lauf geprüft.
Die Gegenrichtung derselben Grenze prüft der Breiten-Wächter von
[ADR-0026](0026-eingefrorene-referenz-referenz-weit-ausgenommen.md) Folgepflicht 2 mit.

## Re-Evaluierungs-Trigger

- **Wenn der gepinnte d-check das geteilte `ignore-refs` verlöre** *(feedforward — eine
  Werkzeug-Version, kein Sensor)*: dann kehrt der Befund zurück, und die Ausnahme wäre neu zu
  schneiden. Ein Re-Pin prüft das mit dem Trockenlauf, der ohnehin fällig ist — derselbe Trigger wie
  in [ADR-0026](0026-eingefrorene-referenz-referenz-weit-ausgenommen.md).
- **Wenn die ausgenommene Referenz sich bewegt** *(beobachtbar an einem Commit, der den Link in
  [ADR-0013](0013-technik-stratum-als-zielort.md) anfasst)*: Dann ist die Grundlage dieser
  Entscheidung berührt — die Datei ist eingefroren, also ist das die größere Frage
  ([`AGENTS.md`](../../../AGENTS.md) §3.4), und `test/ignore-refs-restbreite.bats` färbt mit.
- **Wenn eine zweite Referenz der Quelldatei auf dasselbe Ziel entsteht** *(der Breiten-Wächter
  färbt rot)*: dann deckt das Paar etwas mit, das niemand entschieden hat — zu entscheiden in einer
  eigenen ADR.
- **Wenn die Rename-Messung der Verweis-Nachzüge einen Weg findet, einen gefrorenen Rumpf zu
  heilen, ohne eine Aussage zu ändern** *(beobachtbar an einer Entscheidung, die
  [ADR-0016](0016-verweis-traegt-tag-und-zitat.md) Festlegung 1 ablöst)*: Dann fällt die
  Voraussetzung dieser Ausnahme mit der von [ADR-0017](0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md),
  und beide sind zurückzunehmen statt fortzuführen.

### Der Acceptance-Trigger

Diese Entscheidung steht auf `Proposed`. Sie wird `Accepted`, **wenn eine Reviewer-Runde sie gegen
[ADR-0017](0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md),
[ADR-0026](0026-eingefrorene-referenz-referenz-weit-ausgenommen.md),
[ADR-0032](0032-eingefrorene-referenz-folgt-ihrem-rumpf.md) und
[ADR-0039](0039-eingefrorene-adresse-in-den-vendored-baum.md) auf Konsistenz geprüft hat und ihr
Report ohne blockierenden Befund an der Substanz der einen Festlegung in `docs/reviews/` liegt.**

**Drei Fächer, wie bei den zwei Vorbildern** ([ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md)
Festlegung 1 und 3): Ein blockierender Befund an der **Darstellung** — Adressform, Zahl ohne
Kommando, Zitat-Stelle — wird behoben und hindert die Annahme nicht; dasselbe gilt für einen Befund
an jedem Abschnitt, der mit dem Accept einfriert, **ohne eine Festlegung zu tragen** — die
Kopffelder, §Kontext, §Verglichene Alternativen, §Konsequenzen, §Fitness Function, die
Re-Evaluierungs-Trigger, dieser Trigger-Abschnitt selbst und §Geschichte. Ändert eine Behebung die
Festlegung, ist es ein Substanz-Befund und blockiert.

Der Beleg ist eine Runde der prüfenden Rolle; ihre **Kennung** steht in der Accept-Zeile der
§Geschichte, nicht als Pfad-Link ([ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md)
Festlegung 1).

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-09-14 | **Proposed** | Architect-Verdikt im Trigger-Audit der Wellen-Closure `welle-13` (Baseline-Regelwerk `v6.8.0`, `modul-06-roadmap.md` §Wellen-Closure-Prozedur Schritt 2). Der Re-Evaluierungs-Trigger 2 von [ADR-0017](0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) ist in Kraft: die Ausnahme ruht auf der Aussage, der referenz-weite Knopf existiere nicht, und genau diese Aussage hat [ADR-0026](0026-eingefrorene-referenz-referenz-weit-ausgenommen.md) an einer roten Gegenprobe widerlegt. Vier `make docs-check`-Läufe tragen die Entscheidung (§Kontext). Der Audit-Report liegt in `docs/reviews/` |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0050` (Baseline-Regelwerk `v6.8.0`, `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).
