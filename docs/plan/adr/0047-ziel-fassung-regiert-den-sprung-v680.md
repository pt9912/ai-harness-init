# ADR-0047: Die Ziel-Fassung regiert auch den Sprung `v6.7.2` → `v6.8.0` — Prozedur und Delegate sind unverändert, tragend ist deshalb die Tag-Klammer, und ohne Vorlagen-Delta bleibt allein die Freshness-Review des Adaptions-Blocks

**Status:** Accepted

**Datum:** 2026-09-13

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[ADR-0018](0018-ziel-fassung-regiert-die-migration.md) (deren Festlegung 3 stellt das Kriterium;
diese Entscheidung **wendet es an**, statt es zu ändern — ihr zweiter Fall ist zum sechsten Mal
eingetreten; ihre Festlegung 2 trennt Prozedur und Ist-Maßstab; ihr §*Wer den Zielstand bewegt*
behält die Setzung dem Auftraggeber vor),
[ADR-0044](0044-ziel-fassung-regiert-den-sprung-v672.md) (die regierende Fassung des vorigen,
vollzogenen Sprungs; ihr erster Re-Evaluierungs-Trigger verlangt die Messung hier, ihr vierter
stellt fest, dass ihr tragender Grund einen Fall wie diesen **nicht** deckt, und in ihren
§Konsequenzen steht die Vorgabe des Auftraggebers zur vollständigen Übernahme),
[ADR-0043](0043-ziel-fassung-regiert-den-sprung-v671.md) (ihre Festlegung 2 — die Leseregel für
die Delta-Basis — bindet unverändert fort und wird hier gelesen, nicht ersetzt),
[ADR-0038](0038-ziel-fassung-regiert-den-sprung-v650.md) und
[ADR-0036](0036-ziel-fassung-regiert-den-sprung-v600.md) (von dort stammen die Meta-Frage-Prüfung
und die Rauschklassen),
[ADR-0031](0031-regierende-fassung-und-ort-der-zielstand-setzung.md) (**`Proposed`**; deren
Festlegung 2 — Ort und Drei-Teil-Form einer Zielstand-Setzung — bindet die Buchung, die mit dieser
Entscheidung entsteht. Ob eine nicht angenommene Entscheidung so zitiert werden darf, ist hier
nicht entschieden; die Frage führt
[ADR-0044](0044-ziel-fassung-regiert-den-sprung-v672.md) §Konsequenzen als benannte Lücke),
[ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) (der Accept-Übergang dieser
Datei nennt den Beleg, den ihr Acceptance-Trigger verlangt),
[ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md) (das derivative
Register [`harness/migration.md`](../../../harness/migration.md) gehört der Rolle, die seine
Originale schreibt — dem Architect),
[ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) (die Wahl der normativen Quelle und der Ort
einer Norm-Buchung sind Architect-Sache),
[ADR-0016](0016-verweis-traegt-tag-und-zitat.md) (Form jedes Belegs in diesem Dokument),
[ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) (Festlegung 3 — die Slices
dieses Vorgangs stehen hier als Kennung ohne Pfad-Adresse),
[`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl neben ihrem Kommando),
[`MR-033`](../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
(jede Baseline-Aussage nennt ihren Tag),
[`MR-035`](../../../harness/conventions.md#mr-035--der-automatische-claude-kontext-trägt-eine-benannte-geschlossene-modul-auswahl)
und
[`MR-056`](../../../harness/conventions.md#mr-056--die-auswahl-im-auto-kontext-hängt-an-der-lauf-berührung-nicht-am-prozess-modul-begriff)
(die Auswahl im automatischen Claude-Kontext; diese Entscheidung misst, wo das Delta sie berührt,
und greift ihr nicht vor),
[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (der Tag ist die
Reproduzierbarkeits-Klammer — hier der **tragende** Grund, nicht nur der Rahmen),
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (kein Gate
liest, nach welcher Fassung ein Durchgang lief — hier so benannt)

**Schärft:** — Prozess-ADR ohne Spec-Stratum: sie wählt die **normative Quelle eines Vorgangs**,
nicht den Inhalt eines Spec-Dokuments.

**Kopplung:** §Baseline von [`harness/conventions.md`](../../../harness/conventions.md) — dort ist
die Zielstand-Setzung auf `v6.8.0` verbucht, und dort steht der Zeiger auf diese Entscheidung als
regierende Fassung des Sprungs; der **Ort** ist der von
[ADR-0031](0031-regierende-fassung-und-ort-der-zielstand-setzung.md) Festlegung 2 (`Proposed`,
siehe Bezug-Feld). Daneben [`harness/migration.md`](../../../harness/migration.md) §1, das
derivative Register der Sprung-Entscheidungen. Beide Dateien sind Architect-Eigentum
([`AGENTS.md`](../../../AGENTS.md) §3.8,
[ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md)).

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md`
§Ziel-Form: ADR (MADR).

---

## Kontext

[ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 3 gibt für jeden künftigen
Sprung ein **Kriterium** statt eines Ergebnisses: gemessen wird, ob die **gepinnte** Fassung die
Migrations-Prozedur führt. Führt sie sie nicht, regiert die Ziel-Fassung ohne neue Abwägung;
führen beide sie, ist die Wahl offen und in jenem Sprung begründet zu entscheiden. Den zweiten
Fall haben [ADR-0031](0031-regierende-fassung-und-ort-der-zielstand-setzung.md),
[ADR-0036](0036-ziel-fassung-regiert-den-sprung-v600.md),
[ADR-0038](0038-ziel-fassung-regiert-den-sprung-v650.md),
[ADR-0043](0043-ziel-fassung-regiert-den-sprung-v671.md) und
[ADR-0044](0044-ziel-fassung-regiert-den-sprung-v672.md) je für ihren Sprung entschieden.

**Der vorige Sprung ist vollzogen, und der Zielstand steht auf `v6.8.0`:** Der Auftraggeber hat ihn
am 2026-09-13 dorthin gezogen — der Akt, den
[ADR-0018](0018-ziel-fassung-regiert-die-migration.md) §Wer den Zielstand bewegt ihm vorbehält. Die
bloße **Existenz** des Releases ist diese Setzung nicht; sie ist ihr Anlass.

### Die Achse: der vendored Baum ist das Release-Asset, unverändert

Gemessen am 2026-09-13 gegen den lokalen Kurs-Klon — eine **Host-Voraussetzung**, kein Artefakt
dieses Repos:

```sh
K=/Development/KI/ai-harness-course
mkdir -p /tmp/v672 && git -C "$K" archive v6.7.2 lab/regelwerk lab/templates \
  | tar -x -C /tmp/v672 --strip-components=1
diff -rq -x SHA256SUMS .harness/baseline/v6.7.2 /tmp/v672 | wc -l                       # -> 28
diff -r  -x SHA256SUMS .harness/baseline/v6.7.2 /tmp/v672 | grep -c '^[<>]'             # -> 58
diff -r  -x SHA256SUMS .harness/baseline/v6.7.2 /tmp/v672 | grep '^[<>]' \
  | grep -v 'github\.com/pt9912/ai-harness-course' | grep -vE '\.\./\.\./' | wc -l      # ->  0
```

**28 Dateien, 58 Zeilen, keine davon außerhalb der zwei bekannten Umschrift-Klassen** —
`<!-- Quelle: … -->`-Ziele und `<tag>`-gescopte Download-URLs. Der dritte
Re-Evaluierungs-Trigger von [ADR-0044](0044-ziel-fassung-regiert-den-sprung-v672.md) ist damit
**nicht** gefeuert; die Achse gilt unverändert, und jede Zahl unten wird aus derselben Quelle
gezogen (`git`-Baum gegen `git`-Baum), damit die Umschrift sich aufhebt. **Keine Erwartungswerte**
([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — die Beträge wandern mit den Tags.

### Der Sprung überspannt genau ein Release

```sh
git -C "$K" log --oneline --decorate v6.7.2..v6.8.0
# -> ba6c95e (tag: v6.8.0) feat(kurs+regelwerk+docs): Welle 135 - E2E-Gate-Typ + Bewusstes-Brechen-Pflicht fuer DoD-Testbehauptungen
#    f37abb8 docs(kennungs-namen-plan): Status auf committet nachziehen
#    e26fccf docs(roadmap): Meilenstein v6.7.2 mit Beleg eintragen
git -C "$K" diff --numstat v6.7.2..v6.8.0 -- lab/regelwerk lab/templates \
  | awk '{a+=$1;d+=$2;n++} END{printf "%d Dateien  +%d  -%d\n", n,a,d}'
# -> 4 Dateien  +36  -4
```

Genau ein Tag liegt in der Range, keiner wird übersprungen.

### Stufe (a) — beide Fassungen führen die Prozedur

```sh
grep -c '^#### Freshness-Audit der vendored Baseline (Schritt 2)$' \
  .harness/baseline/v6.7.2/regelwerk/modul-02-harness-bootstrap.md            # -> 1
git -C "$K" show v6.8.0:lab/regelwerk/modul-02-harness-bootstrap.md \
  | grep -c '^#### Freshness-Audit der vendored Baseline (Schritt 2)$'        # -> 1
```

Damit greift **nicht** der erste Fall von
[ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 3 — der Fall, dessen tragendes
Argument *„die Wahl steht zwischen einem Verfahren und keinem"* lautet —, sondern zum sechsten Mal
der zweite.

### Stufe (b) — die Prozedur ist unverändert, und alle vier Delegate auch

Die Delegate werden aus dem vendored Abschnitt abgeleitet, nicht aus einer Liste abgeschrieben:

```sh
sed -n '/^#### Freshness-Audit/,/^#### Gate-Fragment/p' \
  .harness/baseline/v6.7.2/regelwerk/modul-02-harness-bootstrap.md \
  | grep -oE '\]\([a-z0-9-]+\.md' | sed 's/](//' | sort -u
# -> grundlagen-bootstrap.md  grundlagen-harness-dateien.md
#    modul-04-adrs.md         modul-07-carveouts.md
git -C "$K" diff --name-only v6.7.2..v6.8.0 -- \
  lab/regelwerk/modul-02-harness-bootstrap.md lab/regelwerk/grundlagen-bootstrap.md \
  lab/regelwerk/grundlagen-harness-dateien.md lab/regelwerk/modul-04-adrs.md \
  lab/regelwerk/modul-07-carveouts.md | wc -l                                 # -> 0
```

**Fünf Dateien, null Änderungen.** Der Abschnitt ist nicht nur byte-gleich — auch jede Datei, in
die er delegiert, ist es. Der Rausch-Abzug der Vorgänger (Herkunfts-Kommentar, Tabellenform) hat
hier kein Objekt: Wo `roh` null ist, ist `netto` null.

**Damit ist der Grund, auf dem
[ADR-0044](0044-ziel-fassung-regiert-den-sprung-v672.md) Festlegung 1 allein trug, hier nicht
verfügbar** — und jene Entscheidung sagt das selbst voraus. Ihr vierter Re-Evaluierungs-Trigger
lautet für den Fall, dass ein Delegat-Delta ausschließlich außerhalb der delegierten Sektionen
liegt: *„dann trägt der einzige Grund von Festlegung 1 nicht, und der Fall braucht eine eigene
Begründung — diese ADR liefert sie nicht."* Hier liegt der Fall noch eine Stufe klarer: Es gibt
**gar kein** Delegat-Delta.

### Was sich ändert, liegt außerhalb des Audits — erreicht aber jeden Claude-Lauf

```sh
git -C "$K" diff --name-only v6.7.2..v6.8.0 -- lab/regelwerk
# -> lab/regelwerk/README.md                    lab/regelwerk/modul-05-planning-harness.md
#    lab/regelwerk/modul-11-verification.md     lab/regelwerk/modul-13-quality-gates.md
git -C "$K" diff --name-only v6.7.2..v6.8.0 -- lab/regelwerk | sed 's|lab/regelwerk/||' \
  | while read -r f; do readlink .claude/rules/*.md | grep '\.harness/baseline/' \
      | grep -q "/$f$" && echo "$f"; done | wc -l                             # -> 3
readlink .claude/rules/modul-11-verification.md
# -> ../../.harness/baseline/v6.7.2/regelwerk/modul-11-verification.md
```

Drei der vier geänderten Dateien stehen als Symlink in `.claude/rules/` und damit in **jedem**
Claude-Lauf im Kontext
([`MR-035`](../../../harness/conventions.md#mr-035--der-automatische-claude-kontext-trägt-eine-benannte-geschlossene-modul-auswahl),
[`MR-056`](../../../harness/conventions.md#mr-056--die-auswahl-im-auto-kontext-hängt-an-der-lauf-berührung-nicht-am-prozess-modul-begriff)).
**Automatisch geschieht das nicht:** Das Symlink-Ziel trägt den Tag im Pfad, wie das dritte
Kommando zeigt — ein Baum unter `v6.8.0` lässt jeden dieser Zeiger ins Leere laufen. Das Umhängen
gehört damit zum Baum-Tausch und ist keine eigene Auswahl-Entscheidung: Die Mitglieder-Menge
bleibt dieselbe, nur ihr Inhalt wechselt. Wie viele Zeiger umzuhängen sind, sagt
`readlink .claude/rules/*.md | grep -c '\.harness/baseline/'` → **7**. **Keine Erwartungswerte** —
beide Zahlen wandern mit dem Verzeichnis.

### Kein Vorlagen-Delta

```sh
git -C "$K" diff --name-only v6.7.2..v6.8.0 -- lab/templates | wc -l          # -> 0
find .harness/baseline/v6.7.2/templates -name '*.template.md' | wc -l         # -> 25
```

Alle 25 Vorlagen sind über die zwei Tags byte-gleich. Das **Instanz-Register** und die
**Report-Form** in [`harness/migration.md`](../../../harness/migration.md) §4 und §5 haben für
diesen Sprung damit keinen Gegenstand — nicht, weil sie ausgesetzt wären, sondern weil keine
Vorlage eine neue Fassung hat, gegen die eine Instanz zu halten wäre.

### Die Delta-Basis ist der vendored Stand selbst

[ADR-0043](0043-ziel-fassung-regiert-den-sprung-v671.md) Festlegung 2 bindet die Delta-Basis an
ein Feld: den letzten Stand, für den §Baseline von
[`harness/conventions.md`](../../../harness/conventions.md) einen Slice mit **gefülltem**
Delta-Nachweis-Feld ausweist. Das Feld sagt heute:

```sh
grep -o '\*\*auf `v[0-9.]*`:\*\* [0-9-]*, Delta-Nachweis[^.;]*' harness/conventions.md
# -> **auf `v5.18.0`:** 2026-09-03, Delta-Nachweis in slice-155
#    **auf `v6.0.0`:** 2026-09-04, Delta-Nachweis in slice-176
#    **auf `v6.5.0`:** 2026-09-07, Delta-Nachweis in slice-224
#    **auf `v6.7.2`:** 2026-09-12, Delta-Nachweis in slice-224
```

Kein Feld ist leer, und die letzte Zeile nennt den vendored Stand: **Die Basis ist `v6.7.2` und
fällt mit dem zuletzt vendorten Stand zusammen.** Das ist genau die Lage, die der fünfte
Re-Evaluierungs-Trigger von [ADR-0044](0044-ziel-fassung-regiert-den-sprung-v672.md) beschreibt —
*„dann fallen zuletzt-vendored und zuletzt-geprüft zusammen, und Festlegung 2 kostet nichts"*.
Eine eigene Festlegung zur Basis braucht dieser Sprung deshalb nicht; sie wird **gelesen**.
**Kein Erwartungswert** — die Aufzählung wandert mit §Baseline.

### Auch `v6.8.0` beantwortet die Frage dieser ADR nicht

Geprüft über die hinzugefügten Zeilen, mit denselben dreizehn Suchbegriffen wie in allen
Vorgängern:

```sh
git -C "$K" diff v6.7.2..v6.8.0 -- lab/regelwerk lab/templates | grep '^+' | grep -cE \
  'welche Fassung|maßgeblich|regiert|gepinnte Fassung|alte Fassung|Prozedur|Migration|Re-Vendor|Bump|adoptiert|Adoption|Übergang|Reihenfolge des Wechsels'
# -> 0
```

**Null.** Der Trigger ist **nicht** gefeuert. **Grenze**, unverändert die der Vorgänger: ein
Negativ aus dreizehn aufgezählten Zeichenketten — eine Regel ohne eines dieser Wörter wäre nicht
gefunden worden.

## Entscheidung

**Eine Festlegung.**

### Für den Sprung `v6.7.2` → `v6.8.0` regiert die Prozedur der Ziel-Fassung `v6.8.0`

(`v6.8.0`, `lab/regelwerk/modul-02-harness-bootstrap.md`, §Freshness-Audit der vendored Baseline
(Schritt 2)) — mit ihren sieben Eigenschaften, ihren fünf Ausgängen und den vier Abschnitten, in
die sie delegiert.

Tragend sind **zwei** gemessene Gründe, und der Grund der Vorgängerin ist keiner von beiden:

1. **Inhaltlich kostet die Wahl nichts — gemessen, nicht angenommen.** Prozedur und alle vier
   Delegate sind über beide Tags unverändert (§Stufe (b)). Was immer der Durchgang nach dieser
   Festlegung urteilt, urteilt er nach demselben Text, den auch die gepinnte Fassung führt. Das
   trägt die Wahl nicht allein — es nimmt ihr nur jedes inhaltliche Gegenargument.
2. **Die Klammer entscheidet, was der Inhalt offenlässt.** Nach dem Vollzug tragen die fünf
   Pin-Stellen dieses Repos und der vendored Baum `v6.8.0`. Eine Entscheidung, die `v6.7.2`
   nennt, zeigte danach auf einen Text, den kein Pin mehr trägt und der netzlos nicht mehr im
   Arbeitsbaum liegt; Buchung und regierende Entscheidung stünden auf verschiedenen Tags. Diesen
   Grund führt [ADR-0044](0044-ziel-fassung-regiert-den-sprung-v672.md) §Verglichene Alternativen
   bereits aus: *„die Größe des Deltas ist nicht das Kriterium, sondern die **Klammer**:
   [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) bindet
   Reproduzierbarkeit an den Tag"*. Hier trägt er allein.

Der zweite Grund aus [ADR-0036](0036-ziel-fassung-regiert-den-sprung-v600.md) — die gepinnte
Fassung liege nicht mehr vendored — wird ausdrücklich **nicht** in Anspruch genommen: sie liegt
(`ls -1 .harness/baseline/` → `v6.7.2`, kein Erwartungswert).

### Was diese Festlegung nicht tut

- **Kein `Supersedes`.** [ADR-0044](0044-ziel-fassung-regiert-den-sprung-v672.md) Festlegung 1 ist
  auf ihren Sprung geschlossen und vollzogen; sie verliert ihr Objekt nicht und wird nicht
  widerlegt. [ADR-0043](0043-ziel-fassung-regiert-den-sprung-v671.md) Festlegung 2 bindet
  unverändert fort und wird hier **gelesen**, nicht ersetzt.
- **Keine zweite Festlegung zur Delta-Basis.** Sie ist `v6.7.2` und folgt aus der Leseregel
  (§Die Delta-Basis).
- **Keine allgemeine Regel** — weder *„es regiert stets die Ziel-Fassung"* (verworfen in
  [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) §Verglichene Alternativen, Option C) noch
  *„bei unveränderter Prozedur regiert die Ziel-Fassung"*. Der nächste Sprung misst erneut, und
  die Messung ist der Aufwand, nicht das Aufschreiben.
- **Sie deutet die fünf Ausgänge nicht** und entscheidet keinen einzelnen Eintrag des
  Adaptions-Blocks; das bleibt bei
  [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 4.
- **Sie inventarisiert das Delta nicht.** Welche der vier geänderten Dateien welchen Eintrag,
  welches Artefakt und welchen Sensor dieses Repos trifft, ist Gegenstand der Review, die
  §Konsequenzen beauftragt.
- **Sie nennt keinen sha256.** Der des `v6.8.0`-Assets wird beim Vollzug am Asset gemessen; eine
  Zahl, die hier stünde, wäre nicht belegt.
- **Sie greift
  [`MR-035`](../../../harness/conventions.md#mr-035--der-automatische-claude-kontext-trägt-eine-benannte-geschlossene-modul-auswahl)
  und
  [`MR-056`](../../../harness/conventions.md#mr-056--die-auswahl-im-auto-kontext-hängt-an-der-lauf-berührung-nicht-am-prozess-modul-begriff)
  nicht vor.** Dass drei geänderte Dateien im Auto-Kontext stehen, ist hier gemessen; ob ihr neuer
  Inhalt den Auswahl-Maßstab berührt, beantwortet die Review.

### Der Acceptance-Trigger

Diese Entscheidung steht auf `Proposed`. Sie wird `Accepted`, **wenn eine Reviewer-Runde in
frischem Kontext sie gegen [ADR-0018](0018-ziel-fassung-regiert-die-migration.md),
[ADR-0043](0043-ziel-fassung-regiert-den-sprung-v671.md),
[ADR-0044](0044-ziel-fassung-regiert-den-sprung-v672.md) und
[ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) auf Konsistenz geprüft hat
und ihr Report ohne blockierenden Befund in `docs/reviews/` liegt** — die Aufteilung, die das
Baseline-Regelwerk `v6.7.2`, `modul-08-agentenrollen.md` §Rollen-Regeln verbatim vorschreibt:
*„ADR-Änderung: Architect schreibt; Reviewer prüft auf Konsistenz; Implementer liest als
Constraint"*. **Der Accept-Übergang nennt diesen Report namentlich**, und eine Nachmessung durch
denselben Kontext, der einen Befund auflöste, ist kein Beleg
([ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegungen 1 und 2).

**Der Prüfgegenstand der Runde ist eigens benannt, weil er neu ist:** ob der zweite tragende Grund
trägt, wo der erste nur entlastet. Die Vorgängerin trug auf einem **inhaltlichen** Unterschied —
ihr vierter Re-Evaluierungs-Trigger sagt es selbst (§Stufe (b)). Diese Entscheidung hat keinen und
steht auf einer Adress-Eigenschaft. Die Runde prüft beide Richtungen: **zu viel** behauptet, wer
daraus eine allgemeine Regel liest; **zu wenig**, wer die Wahl für beliebig hält, weil der Text
derselbe ist.

Bis dahin ist sie ein Architect-Verdikt und das Übergabe-Artefakt, das der Schnitt des
Tausch-Slice als Constraint liest; sie ist nicht eingefroren
([`AGENTS.md`](../../../AGENTS.md) §3.4 bindet ab `Accepted`).

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — nichts entscheiden, die Wahl fällt faktisch beim Tausch | kein Aufwand; der Text ist über beide Tags derselbe, also „egal" | [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 3 verlangt für diesen Fall ausdrücklich eine Begründung. Und beim Vollzug nennt keine Quelle die regierende Fassung, während fünf Pin-Stellen den Ziel-Tag tragen und die Setzung des Auftraggebers nirgends gebucht wäre |
| B — die gepinnte Fassung `v6.7.2` regiert | sie liegt netzlos im Arbeitsbaum, und ihre Prozedur ist wortgleich mit der der Ziel-Fassung — sie gewinnt inhaltlich nichts, verliert aber auch nichts | nach dem Tausch trägt kein Pin sie mehr; die Buchung in §Baseline zeigte auf einen anderen Tag als die regierende Entscheidung. Der Vorteil *netzlos lesbar* ist zudem auf die Zwei-Fassungen-Phase befristet und kehrt sich mit dem Tausch um |
| C — die allgemeine Regel setzen: *bei unveränderter Prozedur regiert die Ziel-Fassung* | spart jedem künftigen Sprung diese Runde; der Fall ist scharf definiert und maschinell prüfbar | die Messung, die *unverändert* feststellt, ist der Aufwand — die Regel spart nur das Aufschreiben des Ergebnisses. Und sie nähme dem nächsten Sprung die Prüfung ab, deren Ausbleiben [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) mit Option C bereits verworfen hat. Wer sie will, braucht dafür eine eigene Entscheidung mit eigener Evidenz, nicht einen Sprung, in dem sie zufällig nichts kostet |
| D — zusätzlich die Delta-Basis neu setzen | machte die Basis ohne Umweg über §Baseline lesbar | sie steht bereits fest und ist heute gleich dem vendored Stand (§Die Delta-Basis); eine zweite Fassung der Leseregel aus [ADR-0043](0043-ziel-fassung-regiert-den-sprung-v671.md) Festlegung 2 stünde dann in zwei Dateien verschieden da |
| **E — gewählt: Ziel-Fassung `v6.8.0` für diesen Sprung, ohne allgemeine Regel, ohne zweite Festlegung** | entscheidet den anstehenden Fall auf zwei hier gemessenen Gründen — kein inhaltlicher Unterschied, und die Tag-Klammer als das, was bleibt —, hält den Tag der Pins und den Tag der regierenden Entscheidung zusammen und lässt jede fortgeltende Regel unangetastet | der tragende Grund ist ein Adress-Grund und damit schwächer als der ihrer Vorgängerin: Er sagt nichts darüber, *welcher* Text besser ist, sondern nur, welcher auffindbar bleibt. Und der nächste Sprung erbt die Messpflicht ein siebtes Mal |

## Konsequenzen

- **Positiv:** Der Sprung auf den gesetzten Zielstand hat eine benannte, zitierte Quelle, bevor das
  erste Konformitäts-Urteil fällt — und der Tag, den die fünf Pin-Stellen tragen werden, ist
  derselbe, den die regierende Entscheidung nennt.
- **Positiv:** Die Delta-Basis fällt mit dem vendored Stand zusammen — die Lage, die
  [ADR-0044](0044-ziel-fassung-regiert-den-sprung-v672.md) als fünften Re-Evaluierungs-Trigger
  benennt. Der Durchgang bleibt damit so klein wie der Sprung selbst: vier Dateien, `+36/−4`,
  kein Vorlagen-Delta.
- **Positiv:** Die Zwei-Fassungen-Phase kostet hier inhaltlich nichts: Solange der Baum `v6.7.2`
  trägt, ist der Ist-Maßstab ([ADR-0018](0018-ziel-fassung-regiert-die-migration.md)
  Festlegung 2) derselbe Text wie die regierende Prozedur.
- **Negativ:** Diese Entscheidung trägt auf einem **Adress**-Grund. Fiele die Gleichheits-Messung
  aus §Stufe (b), stünde sie ohne inhaltliches Argument da — und müsste dann neu geführt werden,
  nicht nachgebessert.
- **Negativ:** Was der Sprung ändert, liegt vollständig außerhalb der Prozedur und ihrer Delegate.
  Der Durchgang misst damit gegen einen Text, den der Sprung nicht bewegt hat; die Wirkung des
  Deltas trifft das Repo an anderer Stelle — in drei Dateien, die in jedem Claude-Lauf im Kontext
  stehen (§Was sich ändert).
- **Negativ / [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6):**
  **Kein Sensor.** Kein Gate liest, nach welcher Fassung ein Durchgang lief, keines liest, ab
  welchem Stand er misst, und keines hält eine Zielstand-Buchung gegen die Entscheidung, auf die
  sie zeigt — dieselbe Lage, die
  [ADR-0044](0044-ziel-fassung-regiert-den-sprung-v672.md) für sich feststellt. Träger sind der
  Zeiger in §Baseline von [`harness/conventions.md`](../../../harness/conventions.md) und der
  Review des Durchgangs-Ergebnisses.
- **Folgepflicht (Architect), im selben Commit eingelöst:** §Baseline von
  [`harness/conventions.md`](../../../harness/conventions.md) trägt die Zielstand-**Setzung** auf
  `v6.8.0` und den Zeiger auf diese Entscheidung als regierende Fassung; der ADR-Index bekommt die
  Zeile dieser Datei; [`harness/migration.md`](../../../harness/migration.md) §1 bekommt die Zeile
  des siebten Sprungs. Den **Vollzug** bucht der Lauf, der ihn ausführt, in der Drei-Teil-Form von
  [ADR-0031](0031-regierende-fassung-und-ort-der-zielstand-setzung.md) Festlegung 2 (`Proposed`,
  siehe Bezug-Feld).
- **Folgepflicht (Architect), fällig nach dieser Entscheidung:** die Reviewer-Runde, die der
  Acceptance-Trigger verlangt, und der Accept-Übergang, der ihren Report namentlich nennt.
- **Folgepflicht (Architect), fällig im Durchgang, nicht hier — der eigentliche Auftrag dieses
  Sprungs:** die **Freshness-Review des Adaptions-Blocks** nach der gewählten Prozedur
  (`v6.8.0` · `regelwerk/modul-02-harness-bootstrap.md` §Freshness-Audit der vendored Baseline
  (Schritt 2), Eigenschaft *„Der Review geht durch die Adaptions-Liste"*): Regelt eine der vier
  geänderten Regelwerks-Dateien etwas, wofür ein aktiver Eintrag unter
  [`harness/conventions/`](../../../harness/conventions/) besteht
  (`ls harness/conventions/*.md | wc -l` → **55**, kein Erwartungswert)? Wo ja, trägt der Eintrag
  einen der fünf Ausgänge — *gegenstandslos · bleibt gültig · teilweise überholt · Bezug ist
  entfallen · widerspricht*. **Diese Entscheidung führt die Review nicht aus und nimmt kein
  Ergebnis vorweg**; sie beauftragt sie und nennt ihren Gegenstand. Ein Ausgang, der hier stünde,
  wäre ein Urteil ohne den Durchgang, der es trägt.
- **Vorgabe des Auftraggebers für den Durchgang — hier verbucht, nicht abgewogen:** Der Durchgang
  übernimmt die Ziel-Fassung **vollständig**; eine Abweichung wird nicht gesetzt. Die Vorgabe ist
  nicht neu: [ADR-0044](0044-ziel-fassung-regiert-den-sprung-v672.md) §Konsequenzen verbucht sie
  für ihren Durchgang wörtlich als *„Der Adaptions-Durchgang übernimmt die Ziel-Fassung
  **vollständig**; eine Abweichung wird nicht gesetzt."* — und benennt dort auch, welchen der fünf
  Ausgänge sie überhaupt trifft: *widerspricht*, den einzigen, an dem das Delta die Antwort nicht
  vorgibt. Der Auftraggeber hat sie am 2026-09-13 für diesen Durchgang erneut erteilt; sie steht
  hier aus demselben Grund und mit derselben Reichweite. **Eine allgemeine Regel darüber, wer
  diese Wahl trifft, entsteht auch hier nicht.**
- **Folgepflicht (Planner), fällig vor dem Vollzug:** **ein** Slice ist zu schneiden — der
  **Baum-Tausch** samt Nachzug der fünf Pins auf `v6.8.0` und den am Asset gemessenen sha256
  (kanonisch ist das Makefile-Paar; die vier übrigen sind fail-closed daran gekoppelt), samt dem
  Umhängen der sieben tag-tragenden Symlinks in `.claude/rules/` (§Was sich ändert). Ein zweiter
  Slice für einen **Instanz-Durchgang** entsteht nicht: Ohne Vorlagen-Delta hätte er keinen
  Gegenstand (§Kein Vorlagen-Delta). Der Wortlaut des Plans ist Planner-Eigentum
  ([ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md)); diese Entscheidung ist das
  Übergabe-Artefakt, nicht der Text.
- **Darüber hinaus ändert diese ADR keine Datei außer sich selbst, dem ADR-Index, §Baseline von
  `harness/conventions.md` und `harness/migration.md` §1.**

## Fitness Function (falls maschinell prüfbar)

**Gebaut: keine** — und das ist die Eigenschaft der Frage, nicht ein Versäumnis.

| Kandidat | Warum er die Regel nicht misst |
|---|---|
| `make baseline-verify` | belegt, **welcher Tag vendored** ist (genau einer, integer, vollständig). Nach welcher Fassung ein Durchgang **gelaufen** ist, sieht er nicht |
| `make docs-check` | prüft Auflösbarkeit von Zielen und Ankern, nicht die Herkunft eines Verfahrens |
| `make regelwerk-check` | hält den gepinnten Tag gegen sein Release-Asset (Netz, nicht in `make gates`) — eine Aussage über **einen** Tag, keine über die Wahl zwischen zweien |
| `make baseline-freshness` | meldet einen neueren Upstream-Tag (Netz, nicht in `make gates`) — der Anlass einer Setzung, nicht ihre Buchung |

**Nicht mechanisierbar:** ob ein Durchgang der gewählten Prozedur *gefolgt* ist, ist ein Urteil
über einen Vorgang — dieselbe Grenze, die
[ADR-0044](0044-ziel-fassung-regiert-den-sprung-v672.md) §Fitness Function für sich und ihre
Vorgänger benennt.

## Re-Evaluierungs-Trigger

- **Wenn der nächste Sprung ansteht** *(feedforward — die Messung aus
  [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 3 läuft in jenem Sprung, kein
  Gate meldet sie)*: Diese Festlegung gilt **nur** für `v6.7.2` → `v6.8.0`. Der nächste Sprung
  misst neu — die Achse zuerst, dann beide Stufen.
- **Wenn ein künftiger Sprung die Prozedur oder einen ihrer vier Delegate ändert** *(beobachtbar an
  `git diff --name-only <alt>..<neu>` über die fünf Dateien aus §Stufe (b))*: dann steht wieder ein
  inhaltlicher Grund zur Verfügung, und die Abwägung ist gegen ihn zu führen statt gegen die
  Klammer allein.
- **Wenn der Zielstand sich bewegt, bevor dieser Sprung vollzogen ist** *(beobachtbar an §Baseline
  von [`harness/conventions.md`](../../../harness/conventions.md))*: dann verliert diese Festlegung
  ihr Objekt wie die von
  [ADR-0043](0043-ziel-fassung-regiert-den-sprung-v671.md), und der Schnitt der Teil-Ablösung in
  [ADR-0044](0044-ziel-fassung-regiert-den-sprung-v672.md) ist die Vorlage — nicht ihr Ergebnis.
- **Wenn eine künftige Baseline die Meta-Frage selbst beantwortet** *(feedforward, Textänderung
  upstream)*: dann bindet sie unabhängig von ihrer Rezeption hier, und diese Festlegung ist gegen
  den neuen Wortlaut neu zu begründen oder als Abweichung zu deklarieren.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-09-13 | **Proposed** | Architect-Lauf auf die Zielstand-Setzung des Auftraggebers vom selben Tag. Anlass sind der sechste Eintritt des zweiten Falls aus [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 3 und der erste Re-Evaluierungs-Trigger von [ADR-0044](0044-ziel-fassung-regiert-den-sprung-v672.md) |
| 2026-09-13 | **Accepted** | **Angenommen auf Weisung des Auftraggebers vom 2026-09-13, vollzogen in der Architect-Rolle.** **Der Acceptance-Trigger ist eingelöst**, und der Beleg, den er verlangt, ist die **Reviewer-Konsistenzrunde vom 2026-09-13 zu ADR-0047** — Kennung `2026-09-13-adr-0047-konsistenzrunde` ([ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 1: Kennung, kein Pfad-Link) —, gefahren in frischem Kontext gegen [ADR-0018](0018-ziel-fassung-regiert-die-migration.md), [ADR-0043](0043-ziel-fassung-regiert-den-sprung-v671.md), [ADR-0044](0044-ziel-fassung-regiert-den-sprung-v672.md) und [ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md). Ihre Summary nennt **kein HIGH**, ihr Verdikt lautet *nicht merge-blockierend*, ihr Report liegt damit ohne blockierenden Befund in `docs/reviews/`; [ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 2 verlangt eine weitere Runde nur nach einem **blockierenden** Befund und ist hier nicht ausgelöst. Den eigens benannten Prüfgegenstand — trägt der zweite Grund, wo der erste nur entlastet — prüft sie in **beide** Richtungen und bejaht ihn in beiden. **Ihr MEDIUM und ihr LOW sind vor diesem Umschlag behoben, solange die Datei `Proposed` war:** der Beleg im Acceptance-Trigger trägt jetzt seinen Mess-Tag, wie [ADR-0016](0016-verweis-traegt-tag-und-zitat.md) Festlegung 3 (a) es für genau diesen Übergang verlangt, und die zwei derivativen Register nennen diese Datei in der Form, die sie für eine einzige Festlegung führen. **Benannte Grenze:** Behoben hat beides derselbe Lauf, der sie fand — die reparierte Fassung hat keine Runde bestätigt; Festlegung 2 fordert das nur nach einem blockierenden Befund. **Ab hier bindet [`AGENTS.md`](../../../AGENTS.md) §3.4:** Korrekturen entstehen als Folge-ADR mit `Supersedes`. |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0047` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).
