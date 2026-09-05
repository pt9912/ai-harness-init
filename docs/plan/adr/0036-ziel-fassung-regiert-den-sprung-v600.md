# ADR-0036: Die Ziel-Fassung regiert auch den Sprung `v5.18.0` → `v6.0.0`

**Status:** Proposed

**Datum:** 2026-09-05

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[ADR-0018](0018-ziel-fassung-regiert-die-migration.md) (deren Festlegung 3 stellt das Kriterium;
diese Entscheidung **wendet es an**, statt es zu ändern — ihr zweiter Fall ist zum zweiten Mal
eingetreten),
[ADR-0031](0031-regierende-fassung-und-ort-der-zielstand-setzung.md) (deren Festlegung 1 ist
ausdrücklich auf den Sprung davor geschlossen; ihr erster Re-Evaluierungs-Trigger verlangt für
diesen Sprung die zweistufige Messung, auf der diese Entscheidung steht — ihre Festlegung 2 bleibt
unberührt),
[ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) (die Wahl der normativen Quelle und der Ort
einer Norm-Buchung sind Architect-Sache),
[ADR-0016](0016-verweis-traegt-tag-und-zitat.md) (Form jedes Belegs in diesem Dokument),
[ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) (Festlegung 3 — die Slices
dieses Vorgangs stehen hier als Kennung ohne Pfad-Adresse),
[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (der Tag ist die
Reproduzierbarkeits-Klammer; diese ADR entscheidet, welcher der beiden Tags während des Wechsels
das Verfahren stellt),
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (kein Gate
liest, nach welcher Fassung ein Durchgang lief — hier so benannt)

**Schärft:** — Prozess-ADR ohne Spec-Stratum: sie wählt die **normative Quelle eines Vorgangs**,
nicht den Inhalt eines Spec-Dokuments.

**Kopplung:** §Baseline von `harness/conventions.md` führt heute den Zustand *offen* für die
regierende Fassung dieses Sprungs. Die Folgepflicht unten wechselt diesen Zustand; die Datei ist
Architect-Eigentum ([`AGENTS.md`](../../../AGENTS.md) §3.8), und die Zeile bekommt kein neues Feld.

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md`
§Ziel-Form: ADR (MADR).

---

## Kontext

[ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 3 gibt für jeden künftigen
Sprung ein **Kriterium** statt eines Ergebnisses: gemessen wird, ob die **gepinnte** Fassung die
Migrations-Prozedur führt. Führt sie sie nicht, regiert die Ziel-Fassung ohne neue Abwägung;
**führen beide sie, ist die Wahl offen und in jenem Sprung begründet zu entscheiden.**

[ADR-0031](0031-regierende-fassung-und-ort-der-zielstand-setzung.md) hat den zweiten Fall einmal
entschieden — für `v5.12.0` → `v5.18.0`, und **nur** dafür. Ihr erster Re-Evaluierungs-Trigger
sagt für den nächsten Sprung: *„misst neu — und zwar beides: ob die dann gepinnte Fassung die
Prozedur führt, **und**, wenn sie sie byte-gleich führt, ob deren Delegate ein Delta haben."* Die
zweistufige Messung liegt in `slice-176` §9; die Abschnitte darunter fahren sie in diesem Lauf
noch einmal selbst, gegen die zwei **vendored** Bäume statt gegen den Kurs-Klon — netzlos und aus
`git`, weil das die Quelle ist, die jeder Lauf dieses Repos hat.

### Stufe (a) — die gepinnte Fassung führt die Prozedur

`v5.18.0`, `modul-02-harness-bootstrap.md`, §Freshness-Audit der vendored Baseline (Schritt 2):
*„Der Freshness-Audit hat sieben Eigenschaften"*, mit fünf Ausgängen im Adaptions-Durchgang und
dem Schlusssatz *„Ein neuer Tag löst einen **Review** aus (Re-Vendoring mit eigenem Diff), keinen
stillen Auto-Bump."* Damit greift **nicht** der erste Fall von
[ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 3 — der Fall, dessen tragendes
Argument *„die Wahl steht zwischen einem Verfahren und keinem"* lautet —, sondern der zweite.

### Stufe (b) — der Abschnitt ist byte-gleich, und genau ein Delegat ändert seine Regel

Der Abschnitt steht in beiden Fassungen Zeichen für Zeichen gleich da; `d75cd8c` ist der Commit,
der den vendored Baum getauscht hat:

```sh
git show d75cd8c^:.harness/baseline/v5.18.0/regelwerk/modul-02-harness-bootstrap.md \
  | sed -n '/^#### Freshness-Audit/,/^#### Gate-Fragment/p' > /tmp/fa-alt
sed -n '/^#### Freshness-Audit/,/^#### Gate-Fragment/p' \
  .harness/baseline/v6.0.0/regelwerk/modul-02-harness-bootstrap.md > /tmp/fa-neu
wc -l /tmp/fa-alt /tmp/fa-neu   # -> 123  123
diff /tmp/fa-alt /tmp/fa-neu    # -> leer
grep -c '^\* \*\*' /tmp/fa-neu  # -> 7   (die sieben Eigenschaften)
```

**Der Abschnitt beantwortet nicht alles selbst — er verweist neun Mal in vier andere Dateien
seines eigenen Baums, und die Verteilung ist ungleich:**

```sh
sed -n '/^#### Freshness-Audit/,/^#### Gate-Fragment/p' \
  .harness/baseline/v6.0.0/regelwerk/modul-02-harness-bootstrap.md \
  | grep -oE '\]\([a-z0-9-]+\.md[^)]*\)' | sort | uniq -c | sort -rn
# -> 3 grundlagen-harness-dateien.md#harnessconventionsmd-als-konventionsspeicher
#    2 modul-07-carveouts.md
#    1 modul-07-carveouts.md#werkzeug-wahl
#    1 modul-04-adrs.md
#    1 grundlagen-harness-dateien.md#harnessreadmemd-als-einstiegspunkt
#    1 grundlagen-bootstrap.md#modus-pro-sub-area-greenfield-vs-brownfield
```

**Vier** der neun zeigen nach `grundlagen-harness-dateien.md`, **drei** davon in dieselbe Sektion
§harness/conventions.md als Konventionsspeicher — und genau diese Datei ist die einzige der vier,
die zwischen den Tags eine Regel ändert. Gemessen über die zwei vendored Bäume, **netto** (die
Klammer darunter sagt, was abgezogen ist):

| Delegierte Frage | Zieldatei | Regel-Zeilen mit Delta |
|---|---|---|
| Adaptions-Durchgang: *Regelt die neue Fassung das, wofür diese Adaption angelegt wurde?* | `grundlagen-harness-dateien.md` §Konventionsspeicher | **11** |
| Form-Vergleich: *Ist dieses Feld Pflicht?* | dieselbe Datei, §Konventionsspeicher und §Einstiegspunkt | (dieselben 11) |
| Werkzeug-Wahl bei einem Stichproben-Fund | `modul-07-carveouts.md` §Werkzeug-Wahl | **0** |
| Append-only-Disziplin beim Rückbau | `modul-04-adrs.md` | **0** |
| dass eine Migration keine Modus-Frage ist | `grundlagen-bootstrap.md` §Modus pro Sub-Area | **0** |

```sh
for f in grundlagen-harness-dateien modul-07-carveouts modul-04-adrs grundlagen-bootstrap; do
  git show "d75cd8c^:.harness/baseline/v5.18.0/regelwerk/$f.md" > "/tmp/$f.alt"
  printf '%s: roh=%s herkunfts-kommentar=%s\n' "$f" \
    "$(diff "/tmp/$f.alt" ".harness/baseline/v6.0.0/regelwerk/$f.md" | grep -c '^[<>]')" \
    "$(diff "/tmp/$f.alt" ".harness/baseline/v6.0.0/regelwerk/$f.md" | grep -c '^[<>].*<!-- Quelle:')"
done
# -> grundlagen-harness-dateien: roh=13 herkunfts-kommentar=2
#    modul-07-carveouts: roh=2 herkunfts-kommentar=2
#    modul-04-adrs: roh=2 herkunfts-kommentar=2
#    grundlagen-bootstrap: roh=2 herkunfts-kommentar=2
```

**Und die 11 treffen die delegierte Frage — eine Ebene tiefer, als ein Zeilen-Diff sie findet.**
Die Pflichtgliederungs-**Tabellenzeile** *Modus-Deklaration pro Sub-Area* ist zwischen den Tags
byte-gleich (in beiden Fassungen Zeile 236,
`grep -n 'Modus-Deklaration pro Sub-Area' <datei>`). Gekippt ist die Prosa darunter, die ihre
Bedingung auflöst: aus *„Wo Kennungen **kein** Segment tragen, entfällt die Spalte"* wird
*„**Die Spalte ist nicht bedingt.**"* — begründet damit, dass die Kennung einer Beobachtung seit
`v6.0.0` der Pfad `BEO-<KUERZEL>/<slug>` **ist** und damit jedes Repo mindestens eine
Kennungsklasse mit Segment führt. Wer die Tabelle vergleicht, liest *unverändert* und meint
*andere Pflicht*.

### Was das Messinstrument mitzählt — der Herkunfts-Kommentar des vendored Baums

**25** der **26** Regelwerks-Dateien des vendored Baums tragen genau einen Kommentar
`<!-- Quelle: … -->`, der auf die Kurs-Datei zeigt — acht in Zeile 2, siebzehn in Zeile 3; die
Ausnahme ist `README.md`, die keinen trägt:

```sh
ls -1 .harness/baseline/v6.0.0/regelwerk/*.md | wc -l                                   # -> 26
grep -c '<!-- Quelle:' .harness/baseline/v6.0.0/regelwerk/*.md | grep -c ':1$'          # -> 25
grep -n '<!-- Quelle:' .harness/baseline/v6.0.0/regelwerk/*.md \
  | awk -F'md:' '{print $2}' | awk -F: '{print $1}' | sort -n | uniq -c                 # -> 8 in Zeile 2, 17 in Zeile 3
```

**Keine Erwartungswerte** ([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — die Beträge wandern mit dem gepinnten Tag. Das **Ziel** dieses Kommentars wandert
zwischen zwei Vendorings, ohne dass eine Regel sich ändert: in den älteren Bäumen steht es als
`<tag>`-gescopte URL, im Baum `v6.0.0` als relativer Pfad. Ein Zeilen-Diff über zwei vendored
Bäume zählt ihn als zwei geänderte Zeilen je Datei, und das ist **der ganze Unterschied** bei
drei der vier Delegate: `roh=2`, davon `2` Herkunfts-Kommentar, Regel-Delta **0**.

Das gilt rückwirkend auch für den Sprung davor. Die Vergleichszahlen sind mit demselben Kommando
über `db83415^` (den Tausch-Commit jener Runde) und `d75cd8c^` zu erheben:

```sh
for f in grundlagen-harness-dateien modul-07-carveouts modul-04-adrs grundlagen-bootstrap; do
  git show "db83415^:.harness/baseline/v5.12.0/regelwerk/$f.md" > "/tmp/$f.v5120"
  git show "d75cd8c^:.harness/baseline/v5.18.0/regelwerk/$f.md" > "/tmp/$f.v5180"
  printf '%s: roh=%s herkunfts-kommentar=%s\n' "$f" \
    "$(diff "/tmp/$f.v5120" "/tmp/$f.v5180" | grep -c '^[<>]')" \
    "$(diff "/tmp/$f.v5120" "/tmp/$f.v5180" | grep -c '^[<>].*<!-- Quelle:')"
done
# -> grundlagen-harness-dateien: roh=17 herkunfts-kommentar=2
#    modul-07-carveouts: roh=2 herkunfts-kommentar=2
#    modul-04-adrs: roh=2 herkunfts-kommentar=2
#    grundlagen-bootstrap: roh=2 herkunfts-kommentar=2
```

**Was daraus folgt und was nicht.** Der Satz *„der Abschnitt delegiert in vier Dateien, und die
haben ein Delta"* trägt in beiden Sprüngen für **eine** Datei, nicht für vier;
[ADR-0031](0031-regierende-fassung-und-ort-der-zielstand-setzung.md) §Kontext führt ihre Tabelle
mit den Roh-Zahlen und stützt ihre Festlegung 1 ausdrücklich auf denselben einen Delegaten
(*„Und der Unterschied trifft genau die delegierte Frage"*). Der Befund **verengt einen Satz ihres
Kontexts, nicht ihre Festlegung** — und er wird hier benannt statt in jener Datei nachgetragen:
Ihre Konsistenz-Prüfung ist ein eigener Vorgang mit eigenem Träger (`slice-171`), und ein
Architect-Lauf, der fremde Befunde still einarbeitet, nimmt ihm sein Objekt.

### Die Wirkung ist nicht hypothetisch — sie steht heute im Konventionsspeicher

`harness/conventions.md` §Modus-Deklaration pro Sub-Area beginnt mit dem Satz *„Eine Kürzel-Spalte
führt diese Tabelle nicht."* und begründet ihn mit der **abgelösten** Fassung (der Absatz nennt
`adoptierter Stand v5.18.0` und deren `grundlagen-harness-dateien.md` §harness/conventions.md als
Konventionsspeicher). Gegen die gepinnte Pflichtgliederung ist das richtig — dieses Repo vergibt
keine Kennung mit Bereichssegment. Gegen die Ziel-Fassung ist es falsch, denn dort ist die Spalte
unbedingt.

**Das ist die Wahl in einem Satz:** Ein Durchgang nach der gepinnten Fassung liest diese Stelle
grün, ein Durchgang nach der Ziel-Fassung rot. Nicht weil die Prozedur andere Worte hätte —
sie hat dieselben —, sondern weil sie ihre Frage an zwei verschiedene Pflichtgliederungen stellt.
**Welchen Ausgang der Fund bekommt, entscheidet diese ADR nicht**; er gehört dem
Adaptions-Durchgang und der Folgepflicht von
[ADR-0034](0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md).

### Die gepinnte Fassung liegt nicht mehr vendored

`ls -1 .harness/baseline/` gibt **eine** Zeile aus: `v6.0.0`. Der Tausch ist in diesem Sprung
früh — er liegt in `done/`, während der einzige Durchgang der Welle (`slice-185`) noch in `open/`
liegt. Damit ist die Zwei-Fassungen-Phase aus
[ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 2 vorbei: Ist-Maßstab **und**
adoptierter Stand sind `v6.0.0`. Der gepinnten Fassung zu folgen hieße von hier an, nach einem
Text zu arbeiten, den ein netzloser Lauf nicht öffnen kann — er steht nur noch in `git`, und für
das Fehlen der Baseline sagt [`AGENTS.md`](../../../AGENTS.md) §1 *„ist der **Checkout kaputt**"*
([`MR-007`](../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)).

### Auch `v6.0.0` beantwortet die Frage dieser ADR nicht

[ADR-0031](0031-regierende-fassung-und-ort-der-zielstand-setzung.md) trägt als dritten
Re-Evaluierungs-Trigger, dass eine künftige Baseline die Meta-Frage selbst beantworten könnte.
Geprüft über die **hinzugefügten** Zeilen des vendored Delta, mit denselben dreizehn Suchbegriffen:

```sh
git archive d75cd8c^ .harness/baseline/v5.18.0 -o /tmp/alt.tar && mkdir -p /tmp/alt \
  && tar -xf /tmp/alt.tar -C /tmp/alt
diff -ru /tmp/alt/.harness/baseline/v5.18.0 .harness/baseline/v6.0.0 | grep '^+' | grep -cE \
  'welche Fassung|maßgeblich|regiert|gepinnte Fassung|alte Fassung|Prozedur|Migration|Re-Vendor|Bump|adoptiert|Adoption|Übergang|Reihenfolge des Wechsels'
# -> 0
```

**Null.** Der Trigger ist **nicht** gefeuert. **Grenze**, unverändert die der Vorgänger: ein
Negativ aus dreizehn aufgezählten Zeichenketten — eine Regel ohne eines dieser Wörter wäre nicht
gefunden worden.

## Entscheidung

**Eine Festlegung.**

**Für den Sprung `v5.18.0` → `v6.0.0` regiert die Prozedur der Ziel-Fassung `v6.0.0`**
(`v6.0.0`, `modul-02-harness-bootstrap.md`, §Freshness-Audit der vendored Baseline (Schritt 2)) —
mit ihren sieben Eigenschaften, ihren fünf Ausgängen und den Abschnitten, in die sie delegiert.

Tragend sind zwei gemessene Gründe, und keiner davon ist von
[ADR-0031](0031-regierende-fassung-und-ort-der-zielstand-setzung.md) abgeschrieben:

1. **Die Prozedur ist nicht abgeschlossen, und ihr Delegat mit Delta ist der, auf den sie am
   häufigsten zeigt.** Vier der neun Verweise gehen nach `grundlagen-harness-dateien.md`, drei
   davon in §Konventionsspeicher — die einzige der vier Zieldateien mit einem Regel-Delta. Die
   Wahl entscheidet damit, gegen welche Pflichtgliederung der Durchgang misst, und der Unterschied
   ist an einer lebenden Stelle des Konventionsspeichers ablesbar.
2. **Die gepinnte Fassung liegt nicht mehr vendored.** Der Tausch liegt vor dem Durchgang; ein
   Lauf nach `v5.18.0` arbeitete netzlos nach einem Text, der im Arbeitsbaum fehlt.

**Was diese Festlegung nicht tut.**

- **Kein `Supersedes`.** An [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) ändert sie
  nichts: Deren Festlegung 3 ist so gebaut, dass jeder Sprung sie **erfüllt** statt sie zu
  ersetzen, und ihre Konsequenz *„Künftige Sprünge erben eine Pflicht ohne Antwort"* ist hier zum
  zweiten Mal eingelöst. An
  [ADR-0031](0031-regierende-fassung-und-ort-der-zielstand-setzung.md) ändert sie ebenfalls
  nichts: Deren Festlegung 1 bleibt für ihren Sprung wahr, deren Festlegung 2 — der Ort einer
  Zielstand-Setzung — gilt unverändert und ist für diesen Sprung bereits vollzogen.
- **Keine allgemeine Regel.** *„Es regiert stets die Ziel-Fassung"* entsteht hier ausdrücklich
  nicht; sie bleibt verworfen ([ADR-0018](0018-ziel-fassung-regiert-die-migration.md)
  §Verglichene Alternativen, Option C), und der nächste Sprung misst erneut — beide Stufen.
- **Sie deutet die fünf Ausgänge nicht** und entscheidet keinen einzelnen Eintrag des
  Adaptions-Blocks. Beides bleibt bei
  [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 4.
- **Sie macht aus dem Herkunfts-Kommentar keine Mess-Regel.** Dass ein Zeilen-Diff über den
  vendored Baum ihn mitzählt, ist hier gemessen und benannt; ob daraus eine Regel wird, entscheidet
  der Steering Loop über seinen Zähler, nicht diese ADR.

### Der Acceptance-Trigger

Diese Entscheidung steht auf `Proposed`. Sie wird `Accepted`, **wenn eine Reviewer-Runde sie gegen
[ADR-0018](0018-ziel-fassung-regiert-die-migration.md) und
[ADR-0031](0031-regierende-fassung-und-ort-der-zielstand-setzung.md) auf Konsistenz geprüft hat
und ihr Report ohne blockierenden Befund in `docs/reviews/` liegt** — die Aufteilung, die das
Baseline-Regelwerk `modul-08-agentenrollen.md` §Rollen-Regeln verbatim vorschreibt: *„ADR-Änderung:
Architect schreibt; Reviewer prüft auf Konsistenz; Implementer liest als Constraint"*. Der Trigger
steht **in dieser Datei**, weil ein Acceptance-Trigger ohne Träger eine Absichtserklärung mit
Verfallsdatum ist und zwei Slice-Kennungen in `open/` diese Restpflicht für ältere Entscheidungen
bereits tragen (`slice-152`, `slice-171`); eine dritte wäre ein Muster statt eines Einzelfalls.

Bis dahin ist sie ein Architect-Verdikt und als solches das Übergabe-Artefakt, das der
Adaptions-Durchgang als Constraint liest; sie ist nicht eingefroren
([`AGENTS.md`](../../../AGENTS.md) §3.4 bindet ab `Accepted`). **Wer annimmt, sagt keine Quelle
dieses Repos** — das ist in [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) §Geschichte
gemessen und wird hier nicht gedoppelt; der Umschlag ist ein Vollzug in der Architect-Rolle auf
eine Entscheidung des Auftraggebers hin.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — nichts entscheiden, die Wahl fällt faktisch beim ersten Durchgang | kein Aufwand; der Abschnitt ist byte-gleich, also „egal" | *egal* ist gemessen falsch: die Prozedur delegiert, und das Delegat mit dem Delta ändert genau die abgefragte Pflichtgliederung. [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 3 verlangt für diesen Fall ausdrücklich eine Begründung; sie zu unterlassen hieße, ihr zweites Anwendungsereignis auszulassen. Und der Durchgang selbst wäre blockiert: sein Start-Trigger nennt eine entschiedene normative Quelle |
| B — die gepinnte Fassung `v5.18.0` regiert | formal der Stand zu Beginn der Welle; der Abschnitt ist identisch, also kostet es nichts | sie ist **nicht mehr vendored** — `ls -1 .harness/baseline/` gibt allein `v6.0.0` aus, und ein netzloser Lauf öffnet den Text nicht. Ihre Delegate messen den Bestand an einer Pflichtgliederung, die das Repo verlassen hat: die Kürzel-Spalten-Stelle im Konventionsspeicher wäre grün, wo der adoptierte Stand rot ist |
| C — allgemeine Regel *„stets die Ziel-Fassung"*, in Ablösung von [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 3 | jeder künftige Sprung startet ohne Vorlauf; die Messung entfiele | dort verworfen und hier unverändert gültig: sie bände Prozeduren, deren Wortlaut niemand kennt, und wäre der stille Auto-Bump eine Ebene höher — den **beide** Fassungen wortgleich verbieten. Zusätzlich verlangte sie ein `Supersedes` auf eine ADR, auf die 62 Verweis-Vorkommen aus 16 lebenden Dateien zeigen (`git grep -oE '\]\([^)]*0018-ziel-fassung-regiert-die-migration\.md[^)]*\)' -- ':!docs/reviews' ':!docs/plan/planning/done' \| wc -l`, dazu dieselbe Abfrage mit `-l`; beide wandern und sind keine Erwartungswerte, [`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) Setzung 2), und `matrix.status` in [`.d-check.yml`](../../../.d-check.yml) verbietet Verweise auf superseded ADRs |
| D — die Prozedur aus der Ziel-Fassung, die Delegate aus der gepinnten | nähme die Fassung, die im Baum liegt, und ließe den Maßstab, unter dem die Welle eröffnet wurde | der Abschnitt adressiert seine Delegate **relativ im eigenen Baum** (`grundlagen-harness-dateien.md#…`); die Aufteilung stünde in keiner Fassung und wäre eine Erfindung dieses Repos — derselbe Fehler wie Option D in [ADR-0018](0018-ziel-fassung-regiert-die-migration.md), nur an anderer Stelle. Und sie hätte genau die Wirkung von B: die abgefragte Pflichtgliederung käme aus dem abgelösten Stand |
| **E — gewählt: Ziel-Fassung für diesen Sprung, auf einer für dieses Fassungspaar gefahrenen Messung** | entscheidet den anstehenden Fall auf Gründen, die hier gemessen sind — Verweis-Verteilung, Netto-Delta je Delegat, die netzlose Verfügbarkeit der zwei Bäume — statt sie von der Vorgänger-Entscheidung zu übernehmen; das Kriterium aus [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) bleibt für den nächsten Sprung unangetastet | der nächste Sprung erbt dieselbe Pflicht ein drittes Mal; und wer *byte-gleich* liest, muss die Delegation **und** den Herkunfts-Kommentar mitlesen, sonst hält er die Frage für erledigt oder findet ein Delta, das keines ist |

## Konsequenzen

- **Positiv:** Der Adaptions-Durchgang dieser Welle hat eine benannte, zitierte Quelle, bevor er
  sein erstes Konformitäts-Urteil fällt — sein Start-Trigger verlangt genau das.
- **Positiv:** *Byte-gleich* ist zum zweiten Mal entkräftet, und diesmal eine Ebene tiefer: auch
  die delegierte **Tabellenzeile** ist byte-gleich, gekippt ist die Prosa, die ihre Bedingung
  auflöst. Wer künftig nur Zeilen vergleicht, hat die Gegenprobe hier stehen.
- **Positiv:** Der Netto-Begriff des Delegat-Deltas ist gemessen: drei der vier Delegate ändern in
  beiden Sprüngen **null** Regel-Zeilen; was ein Roh-Diff dort zeigt, ist der Herkunfts-Kommentar
  des vendored Baums.
- **Negativ:** Die Wahl ist für diesen Sprung entschieden und für keinen weiteren. Der nächste
  erbt die Messpflicht — inzwischen zweistufig plus die Netto-Frage, also mehr Arbeit als beim
  ersten Mal.
- **Negativ:** Ein Fall bleibt offen und wird hier ausdrücklich **nicht** entschieden: Was gilt,
  wenn **kein** Delegat ein Regel-Delta trägt? Dann führen beide Fassungen dieselbe Prozedur mit
  denselben Antworten, und keiner der zwei Gründe oben trägt — nur der zweite, und auch der nur,
  solange der Tausch vor dem Durchgang liegt. Das ist eine benannte Lücke, keine Regel.
- **Negativ / [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6):**
  **Kein Sensor.** Kein Gate liest, nach welcher Fassung ein Durchgang lief. Träger ist der
  Zeiger in §Baseline von `harness/conventions.md` und der Review des Durchgangs-Ergebnisses.
- **Folgepflicht (Architect), im selben Commit eingelöst:** §Baseline von
  `harness/conventions.md` trägt für die regierende Fassung dieses Sprungs den Zustand statt des
  Vermerks *offen* und zeigt hierher. **Darüber hinaus ändert diese ADR keine Datei außer sich
  selbst und dem ADR-Index.**

## Fitness Function (falls maschinell prüfbar)

**Gebaut: keine** — und das ist die Eigenschaft der Frage, nicht ein Versäumnis.

| Kandidat | Warum er die Regel nicht misst |
|---|---|
| `make baseline-verify` | belegt, **welcher Tag vendored** ist (genau einer, integer, vollständig). Nach welcher Fassung ein Durchgang **gelaufen** ist, sieht er nicht |
| `make docs-check` | prüft Auflösbarkeit von Zielen und Ankern, nicht die Herkunft eines Verfahrens |
| `make comment-claims` | hat keine Markdown-Datei im Prüfbereich |

**Nicht mechanisierbar:** ob ein Durchgang der gewählten Prozedur *gefolgt* ist, ist ein Urteil
über einen Vorgang — dieselbe Grenze, die
[ADR-0018](0018-ziel-fassung-regiert-die-migration.md) und
[ADR-0031](0031-regierende-fassung-und-ort-der-zielstand-setzung.md) für sich benennen.

**Teilweise mechanisierbar, hier nicht gebaut:** die Netto-Frage aus §Kontext ist ein Muster — ein
Zeilen-Diff über zwei vendored Bäume, abzüglich der Zeilen mit `<!-- Quelle:`. Ein Sensor dafür
wäre `git` + `diff` + `grep`; ihn hier als vorhanden auszugeben wäre
[`AGENTS.md`](../../../AGENTS.md) §3.1 eine Ebene tiefer.

## Re-Evaluierungs-Trigger

- **Wenn der nächste Sprung ansteht** *(feedforward — die Messung aus
  [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 3 läuft in jenem Sprung, kein
  Gate meldet sie)*: Diese Festlegung gilt **nur** für `v5.18.0` → `v6.0.0`. Der nächste Sprung
  misst neu — beide Stufen, und das Delegat-Delta **netto**.
- **Wenn ein Tausch nicht mehr vor dem Durchgang liegt** *(beobachtbar an der Slice-Reihenfolge
  der Welle)*: dann lebt die Zwei-Fassungen-Phase aus
  [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 2 wieder auf, der zweite Grund
  oben trägt nicht mehr, und der erste allein ist zu prüfen.
- **Wenn ein Sprung kein Delegat mit Regel-Delta hat** *(beobachtbar am Netto-Diff der vier
  Zieldateien)*: dann ist der offene Fall aus §Konsequenzen eingetreten und braucht eine eigene
  Begründung — diese ADR liefert sie nicht.
- **Wenn der vendored Baum seinen Herkunfts-Kommentar verliert oder seine Form ändert**
  *(beobachtbar daran, dass die Zahl der Regelwerks-Dateien mit genau einem `<!-- Quelle:`-Kommentar
  nicht mehr um genau eine unter ihrer Gesamtzahl liegt — die zwei Kommandos in §Was das
  Messinstrument mitzählt)*: dann ist die Netto-Rechnung oben gegenstandslos oder anders zu ziehen.
- **Wenn eine künftige Baseline die Meta-Frage selbst beantwortet** *(feedforward, Textänderung
  upstream)*: dann bindet sie unabhängig von ihrer Rezeption hier, und diese Festlegung ist gegen
  den neuen Wortlaut neu zu begründen oder als Abweichung zu deklarieren.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-09-05 | **Proposed** | Architect-Lauf zu `slice-178`. Anlass ist der zweite Eintritt des zweiten Falls aus [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 3 und der erste Re-Evaluierungs-Trigger von [ADR-0031](0031-regierende-fassung-und-ort-der-zielstand-setzung.md), der für diesen Sprung eine eigene zweistufige Messung verlangt. Die Messung ist in diesem Lauf gegen die zwei **vendored** Bäume nachgefahren statt aus dem Katalog übernommen; dabei ist die Netto-Frage des Delegat-Deltas entstanden |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0036` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).
