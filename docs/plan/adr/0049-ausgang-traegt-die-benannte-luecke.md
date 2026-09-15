# ADR-0049: Der Ausgang einer Register-Beobachtung trägt die benannte Lücke — und der Lese-Schritt liest alle Einträge über der Schwelle

**Status:** Accepted

**Datum:** 2026-09-14

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[ADR-0034](0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md) (Festlegung 3
— die Kennung einer Beobachtung **ist** der Pfad `BEO-<KUERZEL>/<slug>`; Festlegung 5 — die Ablage
ist ortsfest und als Pfad zulässig),
[ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) (Festlegung 1 bindet die
Accept-Zeile unten, Festlegung 2 die Runde nach einem blockierenden Befund),
[`AGENTS.md`](../../../AGENTS.md) §3.7, §3.8, §3.10 und §3.11 (die vier Absätze der Form *„Ein
Wächter existiert nicht"* — `grep -n 'Ein Wächter existiert nicht' AGENTS.md` —, an denen die
Festlegung 1 ihre Form liest; §3.9 schließt dieselbe Form mit einem Grenzen-Absatz ohne diese
Wendung. §3.7 trägt darunter den Zustands-Rahmen, in den beide Festlegungen fallen, §3.8 die Rolle,
der die Hard Rules und der Adaptions-Block gehören),
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (eine
benannte Lücke als Deckung auszugeben wäre die Lüge, die diese Entscheidung verbietet),
[`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben dem Kommando, das sie liefert),
[`MR-051`](../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
(Setzung 2 — ein Register-Zähler ist eine datierte Messung),
[`MR-057`](../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
(die Kennungs-Form des Vorgangs)

**Schärft:** — Prozess-ADR ohne Spec-Stratum: sie entscheidet die Form eines Zustandsfelds und den
Lese-Gegenstand eines Schritts, nicht den Inhalt eines Spec-Dokuments.

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md`
§Ziel-Form: ADR (MADR).

---

## Kontext

### Der Befund: achtzehn Einträge über der Schwelle tragen keinen Ausgang

Das Beobachtungs-Register dieses Repos steht bei **114** Einträgen; **31** davon haben die 3×-Schwelle
erreicht, und **18** tragen über der Schwelle keinen der drei Ausgänge:

```sh
ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l            # 114  Einträge gesamt
for d in docs/plan/planning/observations/BEO-*/*/; do
  printf '%s\n' "$(ls "$d"evidence 2>/dev/null | wc -l)"
done | awk '$1 >= 3' | wc -l                                        #  31  über der Schwelle
for d in docs/plan/planning/observations/BEO-*/*/; do
  n=$(ls "$d"evidence 2>/dev/null | wc -l)
  if [ "$n" -ge 3 ] && grep -q '^\*\*Stand:\*\* offen' "$d/state.md"; then echo "$n $d"; fi
done | sort -rn | wc -l                                             #  18  über der Schwelle und offen
```

**Keine Erwartungswerte** ([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2, geschärft durch [`MR-051`](../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
Setzung 2) — die drei Zahlen wandern mit dem Baum. Verteilt über den ganzen Bestand stehen **7**
`verkörpert`, **6** `geplant`, **0** `gestrichen` und **101** `offen`:

```sh
grep -h '^\*\*Stand:\*\*' docs/plan/planning/observations/BEO-ALL/*/state.md | sort | uniq -c
```

### Die achtzehn stehen nicht für eine einzige Klasse — gemessen

Zehn ihrer `state.md` benennen in ihrem Rumpf eine **Lücke** (*kein Wächter / kein Sensor / Träger*) —
fünf davon wörtlich mit *„Träger ist der Lauf, der …"* —, drei nennen stattdessen eine
Slice-Kennung:

```sh
for d in docs/plan/planning/observations/BEO-*/*/; do
  n=$(ls "$d"evidence 2>/dev/null | wc -l)
  [ "$n" -ge 3 ] || continue
  grep -q '^\*\*Stand:\*\* offen' "$d/state.md" || continue
  printf 'Luecke=%s Kennung=%s\n' \
    "$(grep -cE 'Wächter (besteht|existiert|fehlt)|kein (Wächter|Sensor)|Träger (ist|bleibt)' "$d/state.md")" \
    "$(grep -cE 'slice-[a-z0-9-]+' "$d/state.md")"
done | awk '{t++} $1!="Luecke=0"{l++} $2!="Kennung=0"{k++} END{print t, l, k}'   # 18 10 3

for d in docs/plan/planning/observations/BEO-*/*/; do
  n=$(ls "$d"evidence 2>/dev/null | wc -l)
  [ "$n" -ge 3 ] || continue
  grep -q '^\*\*Stand:\*\* offen' "$d/state.md" || continue
  grep -c 'Träger ist der Lauf' "$d/state.md"
done | awk '{s+=$1} END{print s}'                                   #   5  wörtlich
```

Ein Teil der achtzehn hat seinen Träger damit längst **geschrieben** und ihn nur nicht in die
Stand-Zeile gehoben; ein anderer Teil trägt die Lücke selbst.

### Was `verkörpert` heute schon trägt — an zwei angenommenen Fällen

Der Ausgang `verkörpert` ist **nicht** die Aussage *„es gibt einen Wächter"*. Der Wortlaut nennt als
Bedingung *„die Regel steht"*:

> | **verkörpert** | die Regel steht | Zielort **und** Herkunfts-Anker (`seit welle-<Kennung>` bzw. `seit slice-<Kennung>`) |

Und der Bestand führt den Fall angenommen: **Zwei** Einträge stehen auf `verkörpert`, während
derselbe `state.md` in seinem Abschnitt *Grenze der Verkörperung, benannt* einen **Lauf** als Träger
nennt:

```sh
for f in docs/plan/planning/observations/BEO-ALL/*/state.md; do
  grep -q '^\*\*Stand:\*\* verkörpert' "$f" || continue
  awk '/Grenze der Verkörperung/{g=1} g && /Lauf/{print FILENAME; exit}' "$f"
done
# …/BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt/state.md
# …/BEO-ALL/vorgeschriebener-ortswechsel-macht-adresse-tot/state.md

sed -n '1p;14p' docs/plan/planning/observations/BEO-ALL/vorgeschriebener-ortswechsel-macht-adresse-tot/state.md
# **Stand:** verkörpert
# bleiben der Accept-Übergang und der Lauf, der den Move plant.
```

Der Zielort dieser Einträge ist ein Norm-Artefakt, der Träger der Wirkung ein Lauf, und die fehlende
Bewachung steht in derselben Datei. Die Form ist also vorhanden; was fehlt, ist ihre **Reichweite** —
ob sie auch dann trägt, wenn die Lücke der **ganze Inhalt** der Beobachtung ist.

### Der Lese-Schritt der `welle-15` — an einem datierten Lauf gemessen

Die Frage, was der Lese-Schritt liest, ist an einem Zeitpunkt entscheidbar. Der Register-Eintrag,
an dem der auslösende Vorgang seinen Befund mißt, steht auf `offen`; sein Anlage-Zeitpunkt liegt
**hinter** dem Lese-Schritt der `welle-15`:

```sh
sed -n '1p' docs/plan/planning/observations/BEO-ALL/kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle/state.md
# **Stand:** offen
git log --diff-filter=A --format='%ci %h %s' -- \
  docs/plan/planning/observations/BEO-ALL/kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle/observation.md
# 2026-09-05 20:43:05 +0200 8c9e3710 Rolle Planner: slice-187 -- Closure, sieben Risiko-Ausgaenge, vier Register-Belege
git log -1 --format='%ci %h %s' 86349419
# 2026-09-05 18:13:10 +0200 86349419 Rolle Planner: welle-15-Results -- drei Aussagen auf ihre Messung gezogen
```

Zu diesem Zeitpunkt standen genau **zehn** Einträge über der Schwelle — dieselbe Zahl, die der
Lese-Schritt selbst nennt —, und er las sie **alle**:

```sh
CUT=$(git log -1 --format=%ct 86349419)
for d in docs/plan/planning/observations/BEO-*/*/; do
  c=0
  for f in "$d"evidence/*.md; do
    [ -e "$f" ] || continue
    t=$(git log -1 --format=%ct -- "$f")
    [ "$t" -le "$CUT" ] && c=$((c+1))
  done
  [ "$c" -ge 3 ] && echo "$c"
done | wc -l                                                        #  10  über der Schwelle zu diesem Zeitpunkt
```

**Das ist die tragende Messung für Festlegung 3.** Eine Praxis *„nur die neu übergetretenen"* ist
damit nicht belegt: Die achtzehn sind der **Zuwachs** seit dem letzten Lese-Schritt, nicht sein
Versehen.

### Die Nachbar-Repos führen dieselbe geschlossene Menge

Zwei Repos desselben Nutzers fahren dieselbe Baseline und dasselbe Rollen-Verfahren. Ihre Register
kennen ebenfalls **drei** Ausgänge und keinen vierten; eines davon trägt die fehlende Stand-Zeile
sogar in seiner High-Liste:

```sh
grep -n 'Ausgängen\|Ausgänge' <Klon des d-check-Repos>/docs/plan/planning/observations/README.md \
  <Klon des a-check-Repos>/docs/plan/planning/observations/README.md
# d-check :10  "… einer von drei Ausgängen"      (eine Zeile)
# a-check :5   "welchen der drei Ausgänge ein Eintrag ab 3× trägt."
# a-check :9   "… `offen` oder einer der drei Ausgänge"    (zwei Zeilen)
grep -n 'keinen der drei Ausgänge' <Klon des a-check-Repos>/.harness/skills/reviewer.md
# 45:  `Stand:`-Zeile bei 3× keinen der drei Ausgänge trägt.
```

**Die Form ist dort abschreibbar, das Ergebnis nicht** — übernommen wird aus diesen Treffern allein
die Beobachtung, dass die Menge **geschlossen** bleibt; beide Antworten unten sind an diesem Repo
gemessen.

### Die Anker-Pflicht des Zielorts hat einen Geltungsbereich — im selben Baseline-Stand

Die Zeile der Ausgangs-Tabelle oben verlangt „Zielort **und** Herkunfts-Anker", unbedingt gelesen.
Derselbe Baseline-Stand begrenzt den Anker an seiner eigenen Stelle:

> - **Geltungsbereich — eng.** Nur Regeln, die die 3×-Schwelle erreicht haben. Was aus Lastenheft,
>   Spezifikation oder ADR folgt, trägt bereits eine ID und braucht keinen zweiten Anker.

Beide Stellen liegen im adoptierten Stand `v6.8.0` (`modul-06-roadmap.md` §Das Beobachtungs-Register
bzw. `grundlagen-traceability.md` §Herkunfts-Anker). Diese Entscheidung liest sie zusammen statt die
zweite zu überlesen — die erste regelt die **Form**, die zweite den **Fall**, in dem der Anker
entsteht.

## Entscheidung

**Drei Festlegungen. Sie binden den Lese-Schritt der Wellen-Closure — in einem Repo ohne
Wellen-Betrieb den der Slice-Closure — und die Form, in der ein `state.md` seinen Ausgang trägt.**

**1. `verkörpert` trägt die benannte Lücke — und sein Zielort ist kein Lauf.** Eine Beobachtung,
deren Inhalt eine benannte Lücke ist (*die Klasse ist benannt, kein Wächter fängt sie*), trägt
`verkörpert`, sobald **die Regel und die Aussage über ihre fehlende Bewachung an einem Zielort
stehen**. Der Zielort ist das **Norm-Artefakt**, an dem die Regel steht — eine Hard-Rule-Sektion,
ein Adaptions-Eintrag, eine Sensor-Datei, eine Entscheidung. Der Herkunfts-Anker steht daneben,
**wo die Regel aus dem Steering Loop entstand**; folgt sie aus Lastenheft, Spezifikation, Baseline
oder ADR, trägt der Zielort an dieser Stelle seine eigene Kennung.

**Baseline ist der vierte Fall, und die Geltungsbereichs-Klausel, die ihn nicht aufzählt, deckt ihn
mit ihrem eigenen Grund.** Sie nennt Lastenheft, Spezifikation und ADR und schließt mit *„trägt
bereits eine ID"* — dasselbe trifft eine Regel zu, die aus dem adoptierten Stand folgt: ihr Träger
nennt seine eigene Stelle. Ein zweiter Anker daneben wäre hier erfunden statt verlangt; die Folge
*„kein Adaptions-Eintrag"* stützt sich damit auf den Geltungsbereich des Ankers und nicht auf einen
vierten Quellentyp.

**Ein Satz der Form *„Träger ist der Lauf, der X schreibt"* nennt keinen Zielort.** Er beschreibt,
**wer** die Regel wirksam hält, und gehört in den Abschnitt *Grenze der Verkörperung, benannt*
desselben `state.md` — die Form, die der Bestand für zwei Einträge schon führt (§Kontext). Ein Lauf
ist kein Ort: er hat keine Adresse, an der eine Regel steht, und der nächste Lauf findet ihn nicht
wieder.

**`verkörpert` behauptet damit keine Deckung.** Es sagt, *daß* die Regel steht und *wo*; ob ein
Wächter sie hält, steht als benannte Grenze daneben und wird **nicht** durch den Ausgangswert
behauptet ([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).

**2. Wo kein Zielort steht, trägt die Beobachtung `geplant` — und ein vierter Ausgang entsteht
nicht.** Steht die Klasse nirgends normiert, gibt es keinen Zielort; dann ist das die Aufgabe des
Lese-Schritts: er **schneidet** einen Träger und nennt dessen Kennung. `gestrichen` bleibt, was es
ist. **Die Menge der drei Ausgänge bleibt geschlossen** — dieselbe Menge, die der Nachbar-Bestand
führt (§Kontext) und die der Baseline-Stand als *„eine geschlossene Menge, kein Freitext"*
bezeichnet. Ein vierter Ausgang wäre genau die Erfindung, gegen die die Menge gebaut ist.

**3. Der Lese-Schritt liest alle Einträge über der Schwelle, zu seinem Zeitpunkt.** Er verengt
seinen Gegenstand **nicht** auf die seit dem letzten Lauf neu übergetretenen. `offen` über der
Schwelle ist **zwischen zwei Lese-Schritten** zulässig und vorübergehend — danach ist es eine
**Vollzugs-Lücke des Schritts**, kein Ausgang, und kein zulässiger Zustand eines Registers, dessen
Wellen-Closure stattgefunden hat.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — nichts tun; die achtzehn dem nächsten Lese-Schritt überlassen | keine Norm-Änderung, die Menge bleibt unangetastet | Der nächste Lese-Schritt stünde vor derselben Frage und müsste sie ohne Regel beantworten — dieselbe Lage, in der die achtzehn stehen. Und die Frage blockiert einen anderen Vorgang: Das Register über der Schwelle ist zugleich der Prüfgegenstand des Sensors, der es künftig hält; ohne die Regel hätte er keinen Maßstab |
| B — ein **vierter** Ausgang *„benannt, nicht verkörpert"* | träfe den Fall genau; die Lücke bekäme ein eigenes Wort | Er hebt die geschlossene Menge auf, und die Menge ist die Eigenschaft, die den Ausgang prüfbar macht: *welcher der drei* ist urteilsfrei entscheidbar, ein vierter Wert ist es nur gegen eine zweite Liste. Der Nachbar-Bestand führt drei und nennt die Erfindung eines vierten ausdrücklich als Defekt (§Kontext). Und er wäre eine **Senkung** nach [`AGENTS.md`](../../../AGENTS.md) §3.5 — die Menge ist eine Setzung der Baseline |
| C — jede benannte Lücke bekommt `geplant` und einen Folge-Slice | nichts fällt durch; jede Lücke hat eine Adresse | Es schneidet Träger für Klassen, deren Regel **steht** und deren Lücke **benannt** ist — der Slice hätte keinen Gegenstand als die Wiederholung eines Satzes, der schon dasteht. Und es zählte die Lücke zweimal: einmal als benannte Grenze im Zielort, einmal als Slice |
| D — den Lese-Gegenstand auf *„nur die neu übergetretenen"* verengen | billiger Lauf; der Schritt bliebe kurz | Es ist die Verengung eines Prüfumfangs und damit nach [`AGENTS.md`](../../../AGENTS.md) §3.5 ADR-pflichtig — und sie ist **an der Messung widerlegt**: Der auslösende Eintrag wurde hinter dem letzten Lese-Schritt angelegt, und der letzte Lese-Schritt las alle zehn, die über der Schwelle standen (§Kontext). Eine Verengung hätte kein Vorbild im Bestand, sondern nur eine Vermutung |
| E — `verkörpert` nur mit Wächter zulassen und die Lücke bis dahin `offen` lassen | hält den Ausgangswert streng; keine Aussage ohne Deckung | Ein Eintrag, der eine Closure über der Schwelle ohne Ausgang übersteht, ist nach dem Baseline-Wortlaut unzulässig. Diese Option macht ihn zum Dauerzustand und erklärt damit die achtzehn selbst zur Antwort. Und sie verwechselt zwei Dinge: *verkörpert* sagt, wo die Regel steht, der Wächter sagt, ob sie hält |
| **F — gewählt: `verkörpert` trägt die benannte Lücke, der Zielort ist ein Norm-Artefakt und kein Lauf, kein vierter Ausgang, und der Lese-Schritt liest alle** | Sie liest die Form, die der Bestand für zwei Einträge schon führt, und gibt ihr ihre Reichweite (§Kontext); sie hält die Menge geschlossen; sie macht aus dem Lauf einen benannten Grenzen-Satz statt eines Zielorts, statt ihn zu verwerfen; und Festlegung 3 ist an einem datierten Lauf **gemessen** statt aus dem Wortlaut geschlossen | Sie verlangt vom Lese-Schritt eine Arbeit, die bisher an der Form scheiterte: den Zielort zu **suchen** statt den nächstliegenden Lauf zu nennen. Und sie sagt etwas über achtzehn Einträge, ohne sie zuzuweisen — die Zuweisung bleibt beim nächsten Lese-Schritt und beim Folge-Slice, der den Sensor baut |

## Konsequenzen

- **Positiv:** Die achtzehn stehen unter einer Regel statt unter Vermutung: Wer ihren Rumpf liest,
  findet vor der Stand-Zeile eine Entscheidung, die *„Träger ist der Lauf"* zu einem **Teil** der
  Antwort macht statt zu ihrem Ganzen.
- **Positiv:** Der Zielort wird suchenswert. Ein Leser, der die Regel sucht, bekommt eine Adresse
  statt einer Rolle; die Rolle bleibt daneben stehen, verliert aber den Platz, an dem sie wie eine
  Adresse aussah.
- **Positiv:** `verkörpert` wird für die Klasse benutzbar, für die es gebaut wurde, ohne die
  Deckungs-Aussage zu erben: Die fehlende Bewachung bleibt ein benannter Satz
  ([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- **Negativ, und es ist der Preis:** *„Der Zielort ist ein Norm-Artefakt"* ist eine **Urteils**-Frage
  bei der Zuweisung. Ein Lese-Schritt kann ein Artefakt nennen, an dem die Regel nicht steht; der
  Wächter prüft später seine **Existenz**, nicht sein **Tragen** — dieselbe Grenze, die
  [`BEO-ALL/ausgang-nennt-traeger-der-nicht-traegt`](../planning/observations/BEO-ALL/ausgang-nennt-traeger-der-nicht-traegt/observation.md)
  für die Form schon führt.
- **Negativ:** Festlegung 3 verlangt einen Lese-Schritt, der **wachsen** kann; ein Register mit
  dreißig Einträgen über der Schwelle ist ein längerer Lauf als eines mit zehn. Das ist die
  Gegenbewegung zu Option D und ausdrücklich gewählt.
- **Negativ:** Die Regel kann eine Lücke als *verkörpert* festhalten, an der niemand mehr arbeitet.
  Was dagegen hält, ist kein Sensor, sondern der Re-Evaluierungs-Trigger unten.
- **Negativ, und der Cutoff verursacht ihn:** Weder die achtzehn noch der Eintrag, an dem der
  Vorgang gemessen wurde, werden von dieser Entscheidung nachgezogen. Ihre Zuweisung ist mechanisch,
  sobald die Regel steht, und gehört hinter sie — in den **Lese-Schritt** der nächsten
  Wellen-Closure und in den Folge-Slice, der den Sensor baut.
- **Folgepflicht 1 (Architect, mit dieser Entscheidung erledigt):** die Ausgangs-Tabelle in
  [`docs/plan/planning/observations/README.md`](../planning/observations/README.md) trägt die drei
  Festlegungen und ihren Herkunfts-Anker. Ein Adaptions-Eintrag entsteht **nicht**: Die drei
  Festlegungen sind Anwendungen des adoptierten Stands `v6.8.0` (`modul-06-roadmap.md` §Das
  Beobachtungs-Register für Festlegungen 1 bis 3, `grundlagen-traceability.md` §Herkunfts-Anker für
  die Anker-Hälfte) und setzen keine Abweichung.
- **Folgepflicht 2 (Planner):** der Folge-Slice, der *„über der Schwelle ohne Ausgang"* färbt, hängt
  an dieser Regel und ist ohne sie nicht baubar; er ist geschnitten und bleibt bei den Planenden.
- **Folgepflicht 3 (Lese-Schritt der nächsten Wellen-Closure):** die achtzehn bekommen ihren Ausgang
  nach dieser Regel — **nicht** durch diesen Vorgang.

## Fitness Function (falls maschinell prüfbar)

**Gebaut: keine — und die Kandidaten sind einzeln geprüft, statt die Lücke zu verschweigen.**

| Kandidat | Warum er diese Regel nicht misst |
|---|---|
| die Module des gepinnten Doku-Gates (`grep -n '^modules:' .d-check.yml`) | keines liest ein `state.md`, eine Stand-Zeile oder einen Register-Zähler; das Modul `planning` hält die Lifecycle-Invariante über dem Ruhe-Marker, nicht das Register |
| `make mutate` | kennt die zwei Fehlschlag-Formen `--- FAIL:` und `not ok N`; keine, in der eine Stand-Zeile ohne Ausgang rot wird |
| ein Skript über `evidence/` und `state.md` | **baubar** und der Liefergegenstand des Folge-Slice — es ist hier nicht gebaut, und diese Datei behauptet es nicht |

**Was ein Sensor könnte:** *über der Schwelle **und** `offen`* ist urteilsfrei aus dem Dateisystem
ableitbar — beide Hälften sind Zahl beziehungsweise erstes Feld. **Was er nicht könnte:** ob der
genannte Zielort die Regel wirklich trägt (Festlegung 1) und ob die Menge der über der Schwelle
stehenden Einträge die richtige ist (Festlegung 3) — beides bleibt Urteil.

## Re-Evaluierungs-Trigger

- **Wenn ein Lese-Schritt einen vierten Ausgangswert schreibt** *(beobachtbar an der ersten
  Stand-Zeile, deren Wert keiner der drei ist)*: Festlegung 2 ist gebrochen; die Menge ist dann
  entweder neu zu entscheiden oder die Zeile zurückzuziehen.
- **Wenn ein Eintrag über zwei Wellen-Closures hinweg `offen` bleibt** *(beobachtbar an seinem
  Zähler und dem Datum des letzten Lese-Schritts)*: Festlegung 3 trägt dann praktisch nicht, und die
  Frage nach einem engeren Lese-Gegenstand ist mit neuer Evidenz erneut zu halten — Option D.
- **Wenn der Folge-Slice den Sensor gebaut hat** *(beobachtbar an seinem Target in
  [`harness/README.md`](../../../harness/README.md) §Sensors)*: Dann ist Festlegung 3 mechanisch
  gedeckt, und die zwei Urteils-Hälften aus §Fitness Function sind gegen seinen Prüfbereich zu
  halten.
- **Wenn eine Baseline-Fassung die Ausgangs-Tabelle ändert** *(beobachtbar an
  `modul-06-roadmap.md` unter einem neuen Tag)*: Die zwei Anwendungen aus §Kontext sind gegen den
  neuen Wortlaut neu zu halten, und ein Delta-Nachweis des Adaptions-Durchgangs führt sie.
- **Wenn die Nachbar-Repos einen vierten Ausgang aufnehmen** *(beobachtbar an ihrem Register-Satz)*:
  Dann ist die Gegenposition aus §Kontext — *die Menge bleibt geschlossen* — mit neuer Evidenz
  erneut zu halten statt mit Verweis auf den heutigen Treffer.
- **Wenn die Ausgangs-Tabelle in
  [`docs/plan/planning/observations/README.md`](../planning/observations/README.md) sich ändert**
  *(beobachtbar an einem Vorgang, der ihre Zeilen oder die zwei Absätze darunter anfasst)*: Diese
  Datei ist der Regeltäger und fortschreibbar, die Entscheidung hier ab `Accepted` nicht — die
  Änderung ist daraufhin zu prüfen, ob sie eine der drei Festlegungen berührt, und deren Fassung
  dann als Folge-ADR mit `Supersedes` nachzuziehen.

### Der Acceptance-Trigger

Diese Entscheidung steht auf `Proposed`. Sie wird `Accepted`, **wenn eine Reviewer-Runde sie gegen
die Ausgangs-Tabelle in
[`docs/plan/planning/observations/README.md`](../planning/observations/README.md), das
Baseline-Regelwerk `modul-06-roadmap.md` §Das Beobachtungs-Register und §Wellen-Closure-Prozedur
sowie `grundlagen-traceability.md` §Herkunfts-Anker (Stand `v6.8.0`) und
[ADR-0034](0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
auf Konsistenz geprüft hat und ihr Report ohne blockierenden Befund in `docs/reviews/` liegt.**
Meldet eine Runde einen blockierenden Befund, ist der Beleg nach
[ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 2 die **nächste**
Runde derselben Rolle, nicht die Nachmessung des auflösenden Laufs.

**Eingelöst ist er durch die Runde `2026-09-14-adr-0049-konsistenzrunde`** (in `docs/reviews/`):
ihre Kategorie-Summary nennt **kein HIGH** (0 HIGH · 2 MEDIUM · 4 LOW · 2 INFO), und die zwei
MEDIUM dieser Runde sind vor dem Umschlag eingearbeitet.

**Und ihre Accept-Zeile nennt diesen Beleg** ([ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md)
Festlegung 1) — als Kennung, nicht als Pfad-Link.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-09-14 | **Proposed** | Architect-Lauf auf den wellenlosen Slice `slice-die-ausgangs-regel-des-registers-deckt-die-benannte-luecke` ([`MR-057`](../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer) Kennungs-Form) |
| 2026-09-14 | **Accepted** | Beleg ist die Runde `2026-09-14-adr-0049-konsistenzrunde` in `docs/reviews/` — sie verdiktiert nicht blockierend: ihre Kategorie-Summary nennt **kein HIGH** (0 HIGH · 2 MEDIUM · 4 LOW · 2 INFO). *Blockierend* ist an der Kategorie des Reviewer-Skills gelesen, die **HIGH** als die den Merge blockierende führt; die Praxis dieses Repos hält es ebenso (`git log --oneline --all | grep -i 'NICHT BLOCKIEREND'`). Die zwei MEDIUM und die vier LOW dieser Runde sind vor diesem Umschlag eingearbeitet, die zwei INFO entschieden; eine **weitere** Runde verlangt [ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 2 nur nach einem blockierenden Befund. **Ab hier bindet [`AGENTS.md`](../../../AGENTS.md) §3.4:** Korrekturen entstehen als Folge-ADR mit `Supersedes ADR-0049`. |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0049` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).
