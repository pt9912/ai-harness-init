# ADR-0031: Die Ziel-Fassung regiert auch den Sprung `v5.12.0` → `v5.18.0` — und wo eine Zielstand-Setzung steht

**Status:** Proposed

**Datum:** 2026-09-03

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[ADR-0018](0018-ziel-fassung-regiert-die-migration.md) (deren Festlegung 3 diese Entscheidung
**anwendet** statt sie zu ändern — der zweite Fall ist eingetreten; deren §*Wer den Zielstand
bewegt* nennt eine eigene ADR für den Beleg-Mindestumfang ausdrücklich als den richtigen Ort),
[ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) (die Wahl der normativen Quelle und der Ort
einer Norm-Buchung sind Architect-Sache),
[ADR-0016](0016-verweis-traegt-tag-und-zitat.md) (Form jedes Belegs in diesem Dokument),
[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (der Tag ist die
Reproduzierbarkeits-Klammer; diese ADR entscheidet, welcher der beiden Tags während des Wechsels
das Verfahren stellt und wo seine Bewegung verbucht wird),
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (kein Gate
liest, nach welcher Fassung ein Durchgang lief — hier so benannt)

**Schärft:** — Prozess-ADR ohne Spec-Stratum: sie regelt die **normative Quelle eines Vorgangs**
und den **Ort einer Buchung**, nicht den Inhalt eines Spec-Dokuments.

**Kopplung:** Festlegung 2 verlegt eine Buchung in §Baseline von `harness/conventions.md`. Diese
Datei ist Architect-Eigentum ([`AGENTS.md`](../../../AGENTS.md) §3.8); die Verlegung schafft dort
kein neues Feld, sondern benennt das vorhandene als den Ort.

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md`
§Ziel-Form: ADR (MADR).

---

## Kontext

[ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 3 gibt für jeden künftigen
Sprung ein **Kriterium** statt eines Ergebnisses: gemessen wird, ob die **gepinnte** Fassung die
Migrations-Prozedur führt. Führt sie sie nicht, regiert die Ziel-Fassung ohne neue Abwägung;
**führen beide sie, ist die Wahl offen und in jenem Sprung begründet zu entscheiden.** Für den
Sprung `v3.5.2` → `v5.12.0` griff der erste Fall. Für `v5.12.0` → `v5.18.0` greift der zweite.

### Beide Fassungen führen die Prozedur — der Abschnitt ist byte-gleich

Gemessen 2026-09-03, gegen den Baum vor dem Tausch (`db83415^`) und den vendored Baum danach:

```sh
git show db83415^:.harness/baseline/v5.12.0/regelwerk/modul-02-harness-bootstrap.md \
  | sed -n '/^#### Freshness-Audit/,/^#### Gate-Fragment/p' > /tmp/fa-alt
sed -n '/^#### Freshness-Audit/,/^#### Gate-Fragment/p' \
  .harness/baseline/v5.18.0/regelwerk/modul-02-harness-bootstrap.md > /tmp/fa-neu
wc -l /tmp/fa-alt /tmp/fa-neu   # -> 123  123
diff /tmp/fa-alt /tmp/fa-neu    # -> leer
```

Der Abschnitt §Freshness-Audit der vendored Baseline (Schritt 2) steht in **beiden** Fassungen
Zeichen für Zeichen gleich da — sieben Eigenschaften, fünf Ausgänge, derselbe Schlusssatz
*„Ein neuer Tag löst einen **Review** aus (Re-Vendoring mit eigenem Diff), keinen stillen
Auto-Bump."* Damit fällt das tragende Argument von
[ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 1 weg: Die Wahl steht diesmal
**nicht** zwischen einem Verfahren und keinem.

### Das Argument, das an seine Stelle tritt: die Prozedur ist nicht abgeschlossen

Der byte-gleiche Abschnitt beantwortet vier Fragen **nicht selbst**, sondern verweist dafür in
andere Dateien seines eigenen Baums — und die haben ein Delta:

| Was der Abschnitt delegiert | Zieldatei | geänderte Zeilen `v5.12.0` → `v5.18.0` |
|---|---|---|
| ob ein Feld **Pflicht** ist (Pflichtgliederung für `harness/conventions.md`) | `grundlagen-harness-dateien.md` §harness/conventions.md als Konventionsspeicher | **17** in der Datei |
| Werkzeug-Wahl bei einem Stichproben-Fund | `modul-07-carveouts.md` §Werkzeug-Wahl | 2 |
| Append-only-Disziplin beim Rückbau | `modul-04-adrs.md` | 2 |
| dass eine Migration keine Modus-Frage ist | `grundlagen-bootstrap.md` §Modus pro Sub-Area | 2 |

```sh
for f in grundlagen-harness-dateien modul-07-carveouts modul-04-adrs grundlagen-bootstrap; do
  printf '%s: ' "$f"
  diff <(git show "db83415^:.harness/baseline/v5.12.0/regelwerk/$f.md") \
       ".harness/baseline/v5.18.0/regelwerk/$f.md" | grep -c '^[<>]'
done
# -> grundlagen-harness-dateien: 17   modul-07-carveouts: 2
#    modul-04-adrs: 2                 grundlagen-bootstrap: 2
```

**Und der Unterschied trifft genau die delegierte Frage.** Die Pflichtgliederungs-Tabelle in
`grundlagen-harness-dateien.md` §harness/conventions.md als Konventionsspeicher führt die Zeile
*Modus-Deklaration pro Sub-Area* am Stand `v5.12.0` als *„Greenfield · Brownfield (mit
Konvergenz-Auftrag) · Hybrid"* und am Stand `v5.18.0` als *„Greenfield · Brownfield (mit
Konvergenz-Auftrag) · Hybrid; dazu je Sub-Area ihr **Kürzel**, sobald Kennungen dieses Repos ein
Bereichssegment tragen"*. Derselbe Prozedur-Wortlaut, zwei verschiedene Pflichten.

Daraus folgt: **die Wahl hat auch bei byte-gleichem Abschnitt eine Wirkung.** Ein Durchgang nach
der gepinnten Fassung fragte die Pflichtgliederung des abgelösten Stands ab und käme grün heraus,
wo die adoptierte Fassung rot ist — der laute Fehler würde still. Das ist dieselbe Verwandlung,
die [ADR-0016](0016-verweis-traegt-tag-und-zitat.md) in ihrer Option C verwirft.

### Die Reihenfolge dieser Welle entscheidet den Rest mit

[ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 2 trennt **Prozedur** und
**Ist-Maßstab**: bis der Baum getauscht ist, bleibt die gepinnte Fassung für jede
Konformitäts-Frage maßgeblich. In diesem Sprung ist der Tausch **früh**: Er ist Mitglied 2 von 10
und liegt in `done/`, während die substanziellen Durchgänge — Adaptions-Durchgang, Form-Vergleich,
Stichprobe — sämtlich danach laufen (`ls docs/plan/planning/done/slice-15[56]-*.md` gegen
`ls docs/plan/planning/open/slice-1{57,58,59,60,61,65}-*.md`). Ab dem Tausch fallen adoptierter
Stand und Ziel-Fassung zusammen; die Zwei-Fassungen-Phase, die Festlegung 2 regelt, ist vorbei.
Der gepinnten Fassung zu folgen hieße von hier an, nach einem Text zu arbeiten, der **gar nicht
mehr vendored** ist.

### Auch `v5.18.0` beantwortet die Frage dieser ADR nicht

[ADR-0018](0018-ziel-fassung-regiert-die-migration.md) trägt als zweiten Re-Evaluierungs-Trigger,
dass eine künftige Baseline die Meta-Frage selbst beantworten könnte. Geprüft ist der Delta,
mit denselben dreizehn Suchbegriffen über die **hinzugefügten** Zeilen:

```sh
mkdir -p /tmp/alt && git archive db83415^ .harness/baseline/v5.12.0 | tar -x -C /tmp/alt
diff -ru /tmp/alt/.harness/baseline/v5.12.0 .harness/baseline/v5.18.0 | grep '^+' | grep -cE \
  'welche Fassung|maßgeblich|regiert|gepinnte Fassung|alte Fassung|Prozedur|Migration|Re-Vendor|Bump|adoptiert|Adoption|Übergang|Reihenfolge des Wechsels'
# -> 10
```

**Zehn** Zeilen, alle gelesen. Sie sprechen von der `MR-<NNN>`-Glossarzeile, vom `versions`-Sensor
gegen Tag-Drift der Pins, vom Kopf-Feld `Stand:` als Version statt Datum und von der
Schritt-Zählung der Wellen-Closure. Eine Meta-Regel darüber, welche Fassung einen Wechsel regiert,
ist nicht darunter. **Grenze:** ein Negativ aus dreizehn aufgezählten Zeichenketten — eine Regel
ohne eines dieser Wörter wäre nicht gefunden worden. Der Trigger ist damit **nicht** gefeuert.

### Der zweite Gegenstand: eine Zielstand-Setzung hat heute keinen Ort

[ADR-0018](0018-ziel-fassung-regiert-die-migration.md) §*Wer den Zielstand bewegt* hält fest, dass
die Bewegung des Zielstands eine **Setzung des Auftraggebers** ist, die eine repo-interne Regel
nicht binden, sondern nur belegpflichtig machen kann, und beziffert den Preis: *„ein
Delta-Nachweis je Schritt und eine Zeile in §Geschichte"*. Die zweite Hälfte ist seit der Annahme
jener ADR unerreichbar — ihre §Geschichte ist nach [`AGENTS.md`](../../../AGENTS.md) §3.4
eingefroren, und ihr eigener Accepted-Eintrag sagt es: *„die drei Zeilen darüber sind der letzte
Fall, in dem eine Bewegung des Zielstands in dieser Datei nachgezogen werden durfte"*.

Die Setzung, die diesen Sprung trägt, steht deshalb heute nirgends mit Nachweis. Dass sie stattfand,
ist an zwei Stellen ablesbar — der Welle-Plan nennt `v5.18.0` als Ziel, das
Beobachtungs-Register führt den Freshness-Ausgang —, aber keine davon ist eine Buchung, und beide
sind fremdes Eigentum. Genau für diesen Fall verweist jene ADR nach vorn: *„Bräuchte diese Frage
eine eigene Bindung — etwa einen Beleg-Mindestumfang je Setzung —, wäre das eine eigene ADR."*

## Entscheidung

**Zwei Festlegungen.**

**1. Für den Sprung `v5.12.0` → `v5.18.0` regiert die Prozedur der Ziel-Fassung `v5.18.0`**
(`v5.18.0`, `modul-02-harness-bootstrap.md`, §Freshness-Audit der vendored Baseline (Schritt 2)) —
mit ihren sieben Eigenschaften, ihren fünf Ausgängen und den Abschnitten, in die sie delegiert.

Der Grund ist **nicht** der von
[ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 1; der ist hier nicht verfügbar,
weil beide Fassungen den Abschnitt byte-gleich führen. Tragend sind zwei gemessene Gründe: Die
Prozedur ist **nicht abgeschlossen** — sie delegiert vier Fragen in Abschnitte, die ein Delta
haben, und eines dieser Deltas trifft genau die delegierte Pflichtgliederung. Und der Tausch liegt
in diesem Sprung **vor** den Durchgängen, womit die gepinnte Fassung ab jetzt gar nicht mehr
vendored ist.

**Diese Festlegung ändert [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) nicht, sie wendet
sie an.** Kein `Supersedes`: Festlegung 3 dort ist so gebaut, dass jeder Sprung sie erfüllt statt
sie zu ersetzen; ihre Konsequenz *„Künftige Sprünge erben eine Pflicht ohne Antwort"* ist hier
eingelöst, nicht widerlegt. Die allgemeine Regel *„es regiert stets die Ziel-Fassung"* entsteht
damit ausdrücklich **nicht** — sie bleibt verworfen (dort Option C), und der nächste Sprung misst
erneut.

**2. Eine Zielstand-Setzung wird in §Baseline von `harness/conventions.md` verbucht — in der
Re-Baseline-Aufzählung, mit genau drei Teilen.** Sie bekommt keine eigene ADR, keine Zeile in einer
fremden §Geschichte und keinen zweiten stehenden Ort.

Der **Beleg-Mindestumfang** ist geschlossen — drei Teile, kein vierter:

- **Ziel-Tag und Datum** der Setzung bzw. ihres Vollzugs.
- **Der Slice, der den Delta-Nachweis führt**, als Zeiger. Der Nachweis selbst — Aufpreis je
  Schritt, unberührte tragende Quellen, Trefferzahlen — bleibt in jenem Slice: Er ist eine
  **Messung**, sie ist datiert, und eine datierte Messung wandert nicht mit dem lebenden Register
  mit ([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 1 verlangt das Kommando neben der Zahl; §Baseline kann es nicht mitführen, ohne bei
  jedem Sprung zu veralten).
- **Sonst nichts.** Kein Konformitäts-Urteil, keine Ausgangs-Liste, keine Begründung der Setzung.
  Die Ausgänge trägt der Adaptions-Durchgang, die Reihenfolge die Welle.

**Was Festlegung 2 nicht tut.** Sie entscheidet **nicht**, wer den Zielstand bewegen darf — das
steht in [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) §*Wer den Zielstand bewegt* und
bleibt unberührt. Sie bindet **nicht** den Welle-Plan: ein Plan darf sein Ziel nennen, das ist
Plan-Sache ([ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md)); er ist nur nicht die Buchung.
Und sie schreibt **keinen** Adaptions-Eintrag vor: Die Buchung ist eine Tatsache über den
adoptierten Stand, keine Abweichung von einer Baseline-Regel — sie steht in §Baseline, nicht im
Adaptions-Block.

## Verglichene Alternativen

### Zu Festlegung 1 — welche Fassung regiert

| Option | Pro | Contra |
|---|---|---|
| A — nichts entscheiden, die Wahl fällt faktisch beim ersten Durchgang | kein Aufwand; der Abschnitt ist ja byte-gleich, also „egal" | *egal* ist gemessen falsch: die Prozedur delegiert in Abschnitte mit Delta, und eines davon ändert die Pflichtgliederung. Zudem verlangt [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 3 für diesen Fall ausdrücklich eine Begründung — sie zu unterlassen hieße, ihr erstes Anwendungsereignis auszulassen |
| B — die gepinnte Fassung `v5.12.0` regiert | formal der Status quo zu Beginn der Welle; der Abschnitt ist identisch, also kostet es nichts | ab dem Tausch ist sie **nicht mehr vendored** — die Durchgänge liefen nach einem Text, der netzlos gar nicht vorliegt. Und ihre delegierten Abschnitte messen die Artefakte an einer Pflichtgliederung, die das Repo verlassen hat: grün, wo die adoptierte Fassung rot ist |
| C — allgemeine Regel *„stets die Ziel-Fassung"*, in Ablösung von [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 3 | jeder künftige Sprung startet ohne Vorlauf; die Messung entfiele | dort schon verworfen (Option C) und hier unverändert gültig: sie bände Prozeduren, deren Wortlaut niemand kennt, und wäre der stille Auto-Bump eine Ebene höher — den **beide** Fassungen wortgleich verbieten. Zusätzlich verlangte sie ein `Supersedes` auf eine ADR, auf die 39 Verweis-Vorkommen aus 13 lebenden Dateien zeigen (`git grep -oE '\]\([^)]*0018-ziel-fassung-regiert-die-migration\.md[^)]*\)' -- ':!docs/reviews' ':!docs/plan/planning/done' \| wc -l`, dazu dieselbe Abfrage mit `-l`; beide wandern und sind keine Erwartungswerte, [`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) Setzung 2), und `matrix.status` verbietet Verweise auf superseded ADRs |
| **D — gewählt: Ziel-Fassung für diesen Sprung, mit dem Grund, der diesmal trägt** | entscheidet den anstehenden Fall auf einer Messung, die ihn trägt — und benennt ausdrücklich, dass der Grund von [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 1 hier **nicht** verfügbar ist, statt ihn abzuschreiben; das Kriterium bleibt für den nächsten Sprung unangetastet | der nächste Sprung erbt dieselbe Pflicht; wer „byte-gleich" liest, muss die Delegation mitlesen, sonst hält er die Frage für erledigt |

### Zu Festlegung 2 — wo eine Zielstand-Setzung steht

| Option | Pro | Contra |
|---|---|---|
| E — Folge-ADR mit `Supersedes` je Setzung | formal die Bahn, die [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) §Geschichte selbst nennt (*„später wäre dieselbe Bewegung eine Folge-ADR mit `Supersedes`"*) | eine ADR über eine **Tatsache** statt über eine Abwägung, und ihr Objekt fehlt: an [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) ändert eine Zielstand-Bewegung nichts, ihre vier Festlegungen gelten unverändert. Der Preis ist zudem eine Supersede-Kaskade über die 39 Verweis-Vorkommen oben — ADR-Inflation in der Form, die [ADR-0016](0016-verweis-traegt-tag-und-zitat.md) Option E verwirft |
| F — die Setzung bleibt im Welle-Plan | sie steht ohnehin dort, als Ziel der Welle | fremdes Eigentum (Planner, [ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md)) und Rang 5 statt einer Buchung; die Datei wandert bei Closure nach `done/` und wird dort nicht mehr gelesen — dieselbe Contra-Kette, mit der [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) ihre Option A verwarf. Und ohne Welle — dieses Repo führt auch wellenlose Arbeit ([`MR-016`](../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)) — gibt es gar keinen Träger |
| G — ein neuer stehender Ort (eigene Datei im Planning-Layout oder ein Feld im Beobachtungs-Register) | ein Ort, der genau dafür gemacht ist | eine dritte Fassung derselben Aussage neben §Baseline und dem Inventur-Slice; zwei Fassungen desselben Zustands driften, drei schneller. Das Beobachtungs-Register führt Beobachtungen mit Zähler, keine Adoptions-Akte — die Form passt nicht |
| **H — gewählt: §Baseline von `harness/conventions.md`, drei Teile** | der Ort führt den adoptierten Stand bereits und wird bei jedem Sprung ohnehin angefasst — die Buchung entsteht dort, wo sie sowieso hin muss, statt daneben; er lebt (kein §3.4), gehört der schreibenden Rolle ([`AGENTS.md`](../../../AGENTS.md) §3.8) und ist wellen-unabhängig | `harness/conventions.md` steht in **keinem** Rang der Source Precedence — die Buchung liegt damit tiefer als die Entscheidung, die sie verlangt. Das ist hingenommen und nicht übersehen: gebucht wird eine **Tatsache**, keine Regel, und für Regeln nennt die Baseline den Konventionsspeicher ohnehin als zulässigen Ort neben den gerankten Quellen |

## Konsequenzen

- **Positiv:** Der Durchgang dieser Welle hat eine benannte, zitierte Quelle, und der Grund dafür
  ist an dieser Fassungs-Paarung gemessen statt von der vorigen abgeschrieben.
- **Positiv:** *Byte-gleich* ist als Argument entkräftet, bevor es gebraucht wird: die Prozedur
  delegiert, und die Delegate haben ein Delta. Der nächste Sprung erbt diese Lesart mit.
- **Positiv:** Eine Zielstand-Setzung hat einen Ort mit geschlossenem Mindestumfang. Die Frage
  *„wer hat das entschieden, und auf welchen Nachweis hin?"* ist beim nächsten Sprung ohne
  Rückfrage beantwortbar.
- **Positiv:** [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) bleibt unberührt — kein
  `Supersedes`, keine Kaskade über `matrix.status`, kein Byte an einer eingefrorenen Datei.
- **Negativ:** Die Buchung liegt in einer Datei ohne Rang. Wer nur die Source Precedence liest,
  findet sie nicht; der Zeiger dorthin steht in dieser ADR und sonst nirgends.
- **Negativ:** Der Beleg zerfällt auf zwei Artefakte — die Zeile lebt, der Nachweis ist datiert
  und liegt im Slice. Wer nur §Baseline liest, sieht *dass*, nicht *woraufhin*.
- **Negativ / [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6):**
  **Kein Sensor**, für keine der beiden Festlegungen. Kein Gate liest, nach welcher Fassung ein
  Durchgang lief, und keines prüft, ob eine Zeile in §Baseline drei Teile trägt.
- **Folgepflicht (Architect):** §Baseline von `harness/conventions.md`
  trägt für den Sprung auf `v5.18.0` die Zeile in der Form aus Festlegung 2 und zeigt für
  Prozedur und Ort hierher. **Darüber hinaus ändert diese ADR keine Datei außer sich selbst und
  dem ADR-Index.**

## Fitness Function (falls maschinell prüfbar)

**Gebaut: keine** — und das ist die Eigenschaft der Frage, nicht ein Versäumnis.

| Kandidat | Warum er die Regel nicht misst |
|---|---|
| `make baseline-verify` | belegt, **welcher Tag vendored** ist (genau einer, integer, vollständig). Nach welcher Fassung ein Durchgang **gelaufen** ist, sieht er nicht |
| `make docs-check` | prüft Auflösbarkeit von Zielen und Ankern, nicht die Herkunft eines Verfahrens und nicht den Inhalt einer Tabellenzeile |
| `make comment-claims` | hat keine Markdown-Datei im Prüfbereich |

**Teilweise mechanisierbar, hier nicht gebaut:** Festlegung 2 hat eine urteilsfreie Hälfte — *jede
Re-Baseline-Zeile in §Baseline nennt einen Tag, ein Datum und eine `slice-<NNN>`*. Das ist ein
Muster und damit prüfbar; **ob** der genannte Slice den Delta-Nachweis wirklich führt, ist ein
Urteil und bleibt es. Ein Sensor für die erste Hälfte wäre bash + `grep`; ihn hier als vorhanden
auszugeben wäre [`AGENTS.md`](../../../AGENTS.md) §3.1 eine Ebene tiefer.

**Nicht mechanisierbar:** ob ein Durchgang der gewählten Prozedur *gefolgt* ist, ist ein Urteil
über einen Vorgang — dieselbe Grenze, die
[ADR-0018](0018-ziel-fassung-regiert-die-migration.md) für sich benennt.

## Re-Evaluierungs-Trigger

- **Wenn der nächste Sprung ansteht** *(feedforward — die Messung aus
  [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 3 läuft in jenem Sprung, kein
  Gate meldet sie)*: Festlegung 1 gilt **nur** für `v5.12.0` → `v5.18.0`. Der nächste Sprung misst
  neu — und zwar beides: ob die dann gepinnte Fassung die Prozedur führt, **und**, wenn sie sie
  byte-gleich führt, ob deren Delegate ein Delta haben.
- **Wenn ein Tausch nicht mehr vor den Durchgängen liegt** *(beobachtbar an der Slice-Reihenfolge
  der Welle)*: dann lebt die Zwei-Fassungen-Phase aus
  [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 2 wieder auf, und das zweite
  Argument von Festlegung 1 trägt nicht mehr; das erste allein ist dann zu prüfen.
- **Wenn eine künftige Baseline die Meta-Frage selbst beantwortet** *(feedforward, Textänderung
  upstream)*: dann bindet sie unabhängig von ihrer Rezeption hier, und beide Festlegungen sind
  gegen den neuen Wortlaut neu zu begründen oder als Abweichung zu deklarieren.
- **Wenn §Baseline von `harness/conventions.md` seinen Ort verlässt** — etwa weil der
  Adaptions-Block auf die Verzeichnis-Form umgestellt wird, die das Baseline-Regelwerk als Default
  führt *(beobachtbar daran, dass die Einträge je eine eigene Datei bekommen)*: dann verliert
  Festlegung 2 ihren Zielort und ist neu zu setzen, nicht stillschweigend mitzuziehen.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-09-03 | **Proposed** | Architect-Lauf zu `slice-163`. Anlass ist der erste Eintritt des zweiten Falls aus [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 3 — beide Fassungen führen die Migrations-Prozedur byte-gleich —, dazu die mit der Annahme jener ADR geschlossene §Geschichte, die einer Zielstand-Setzung ihren bisherigen Ort nimmt |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0031` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).
