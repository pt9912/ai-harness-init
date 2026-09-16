# ADR-0055: Die abgeschaffte Kennung `TestEnforce_Convergent` verläßt die Fitness Function der ADR-0054 als Teil-Ablösung — die Regel bleibt, die Deckung wird neu benannt

**Status:** Accepted

**Datum:** 2026-09-16

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[ADR-0054](0054-emittierter-commit-traeger-skip-if-present.md) (**Accepted** — der Gegenstand: ihr
§Fitness Function trägt die abgelöste Aussage. Ihre vier Festlegungen, der Regel-Gehalt aller drei
Zeilen ihrer Fitness-Tabelle, die Abgrenzung gegen [ADR-0007](0007-bootstrap-phasen.md) und ihre
Re-Evaluierungs-Trigger binden unverändert fort),
[ADR-0007](0007-bootstrap-phasen.md) (**Accepted** — ihre Festlegung 3 führt die
Idempotenz-Klassifikation **je Datei**, ihre §Fitness Function die Zeile *„Klassifikation"*, deren
Deckung hier neu benannt wird. **Kein `Supersedes`** — keine ihrer Festlegungen ändert sich),
[ADR-0032](0032-eingefrorene-referenz-folgt-ihrem-rumpf.md) (**Accepted** — der Präzedenzfall der
Form: eine Folge-ADR mit Teil-`Supersedes` auf **einen** wörtlich genannten Wert einer
`Accepted`-ADR, samt ihrer Folgepflicht, den Zusatz im ADR-Index anzuordnen),
[ADR-0050](0050-geteiltes-ventil-ersetzt-die-datei-weite-ausnahme.md) (**Proposed** — dieselbe Form
ein zweites Mal; dort nimmt sie einen `scan.ignore`-Eintrag zurück, hier eine Begründung),
[ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md) (**Accepted** — Festlegung 2 nimmt die
`Accepted`-ADR von jedem Verweis-Nachzug aus; diese Datei heilt ihren Rumpf darum nicht, sie bildet
ein eigenes Gefäß),
[ADR-0022](0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) (**Accepted** — Festlegung 5
teilt den Zweig der Erfassung mit dem Träger; daraus folgt, daß die Aufzählung des Enforce-Emitters
Pfade nicht führt, die ein Lauf schreibt),
[ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) (**Accepted** — Festlegung 1
nennt den Beleg des Accept-Übergangs, Festlegung 3 den Ort des Acceptance-Triggers),
[`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben dem Kommando, das sie liefert),
[`MR-033`](../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
(jede Baseline-Aussage nennt den Tag, gegen den sie gemessen ist),
[`MR-055`](../../../harness/conventions.md#mr-055--eine-stellen-messung-trägt-keine-folgerung-über-eine-eigenschaft)
(eine Stellen-Messung trägt keine Folgerung über eine Eigenschaft — die Grenze, die §Kontext zieht),
[`MR-057`](../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
(die Form der Kennung für einen neuen Vorgang; diese Datei nennt keine — §Konsequenzen),
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (ein
Artefakt, das eine Kennung nennt, die nicht mehr läuft, behauptet eine Deckung, die es nicht hat)

**Schärft:** — Prozess-ADR ohne Spec-Stratum: sie löst die Deckungs-Aussage in einem eingefrorenen
Artefakt ab und ändert keine Spec-Aussage. Ihr Prüfbereich wächst um keinen Pfad.

**Supersedes (Teil):** [ADR-0054](0054-emittierter-commit-traeger-skip-if-present.md) §Fitness
Function, und dort **genau einen Gegenstand** — die Aussage über die Deckung der zweiten Zeile, wie
der Zusatz ihrer Tabellenzelle (*„Diese Vollständigkeit trägt heute nur einer der zwei Emitter"*) und
der Absatz darunter (*„Für die zweite Zeile trägt damit der Vorlagen-Emitter und der Enforce-Emitter
nicht: benannt, nicht bewacht."*) sie führen, **samt der Begründung, die sie auf den abgeschafften
Test-Namen stützt**. Alles andere jener Datei bindet unverändert fort: ihre Festlegungen 1 bis 4, der
Regel-Gehalt aller drei Zeilen ihrer Fitness-Tabelle, ihr Satz unter §Konsequenzen, der
[ADR-0007](0007-bootstrap-phasen.md) ausdrücklich **nicht** ablöst, und ihre drei
Re-Evaluierungs-Trigger. Diese ADR nimmt nichts davon weg; sie zieht eine Begründung nach, statt eine
Entscheidung zu ändern.

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md` §Ziel-Form: ADR (MADR) und §Hard Rule für
Accepted-ADRs (*„Eine ADR mit Status `Accepted` wird nicht inhaltlich überschrieben. Spätere
Korrekturen oder Schärfungen entstehen als neue ADR mit explizitem Verweis auf die abgelöste oder
geschärfte Vorgängerin."*) — beides gelesen gegen die regierende Fassung `v6.8.0`
([`MR-033`](../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)).
Den lebenden d-check-Pin führt `d-check.mk`; er steht hier nicht als zweite Fassung.

---

## Kontext

### Der Gegenstand: eine Kennung, die im Code nicht mehr läuft

[ADR-0054](0054-emittierter-commit-traeger-skip-if-present.md) Folgepflicht 1 hat den Träger der
emittierten Commit-Kennung aus der konvergenten Menge genommen. Mit dem Vollzug fiel die Stelle, die
jene Datei in ihrer §Fitness Function beim Namen nennt — der Test über die ganze Menge, der für
**jeden** Pfad der Aufzählung die konvergente Klasse verlangte. An seiner Stelle steht ein Test neuen
Namens, der je Pfad die Richtung der Klasse fährt, die dieser Pfad trägt:

```sh
grep -rn 'TestEnforce_Convergent' --include='*.go' . | wc -l                       # 0 — im Code lebt der Name nicht
grep -n 'func TestEnforce_IdempotenzKlasseJePfad' internal/emit/enforce_test.go    # :348 — der Test, der an seiner Stelle steht
git grep -n 'TestEnforce_Convergent' ':!docs/reviews' ':!docs/plan/adr/0055-*'    # außerhalb dieser Datei drei Stellen: ADR-0054:252, ein done/-Zeitdokument, die Titel-Zelle des Index
```

**Keine Erwartungswerte** ([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — die Zahlen wandern mit dem Baum; tragend ist, daß die dritte Ausgabe **keine** lebende
Go-Stelle nennt und die drei Stellen, die sie zeigt, außerhalb dieser Datei liegen.

Die drei Fundstellen der dritten Zeile gehören drei Klassen an. Die eine ist ein
`done/`-Zeitdokument: es hält den Stand seines Vorgangs fest, die Kennung steht dort als Chronik von
Beruf, und es wird nicht nachgezogen ([`AGENTS.md`](../../../AGENTS.md) §3.7, Geltungsbereich). Die
zweite steht in einer `Accepted`-ADR, und **sie** ist der Gegenstand dieser Entscheidung. Die dritte
ist die Titel-Zelle dieser Entscheidung im ADR-Index: sie führt den Namen im Wortlaut, weil der
Titel dieser Datei ihn führt, und zeigt damit auf die Entscheidung, die ihn abschafft.

### Was der Absatz behauptet hat — und was davon steht

Der abzulösende Absatz führt drei Behauptungen in einem Zug: *der Test läuft über jeden Pfad dieser
Aufzählung* · *er verlangt dort die konvergente Klasse* · *ein korrekt skip-if-present geführter Pfad
ist dort kein erkennbarer Zustand, sondern ein Rot*. Die ersten zwei tragen die dritte, und aus allen
dreien zieht der Absatz seinen Schlusssatz.

Die **erste** Behauptung trägt weiter — unter neuem Namen fährt der Test über dieselbe Aufzählung.
Die **zweite** und die **dritte** stehen heute umgekehrt: die Richtung kommt je Pfad aus seiner
Klasse, und der Rot-Fall des Tests ist der Pfad **ohne** Klasse:

```sh
grep -n 'for _, rel := range emit.EnforcePaths()' internal/emit/enforce_test.go   # :32 :271 :362 :401 — die zwei Läufe über die Menge sind :362 und :401; :32 prüft die Emission, :271 den Zielpfad
grep -n 'case emit.SkipIfPresent:' internal/emit/enforce_test.go                  # :418 — die Richtung dieses Pfades: unberührt, kein Rot
grep -n 'traegt keine Idempotenz-Klasse' internal/emit/enforce_test.go            # :367 — der Rot-Fall ist der klassenlose Pfad
grep -n '^# expect:' test/mutations/361-traeger-ohne-klasse.sh                    # :3 — der gelistete Fall, der genau diesen Zustand rot färbt
```

### Was von der Folgerung bleibt — und auf welchem Grund

Der Schlusssatz des Absatzes stand auf **zwei** Gründen: der Teilmengen-Inventur des Enforce-Emitters
und dem Ganz-Mengen-Test. Der zweite **Grund** ist mit der Umbenennung entfallen; der erste steht, und
die Menge, auf die er sich bezieht, ist enger als das, was ein Lauf schreibt:

```sh
grep -n 'strings.Contains(got, w)' internal/emit/enforce_test.go    # :61 — die Erwartungs-Seite ist ein Enthaltensein, keine Gleichheit
grep -rn 'EnforcePaths()' --include='*.go' . | grep -v '^internal/emit/enforce.go' | wc -l   # 6 — die Leser der Aufzählung, alle in Tests
grep -n 'FieldList(targetDir)' internal/emit/enforce.go             # :319 — der Lauf schreibt einen Pfad, den die Aufzählung nicht führt
grep -c 'erfassung-feldliste' internal/emit/enforce.go              # 0 — ihn führt sie nicht
grep -n 'captureFiles()' internal/emit/enforce.go                   # :178 die Deklaration, :304 der Aufruf im Gelingens-Zweig; :103 :108 :115 :231 nennen sie nur im Kommentar
grep -n 'writeFileMode(targetDir, FieldListPath' internal/emit/fieldlist.go   # :37 — ein eigener Writer, ohne Klasseneintrag
```

Die zwei Pfade außerhalb der Aufzählung sind kein Versehen: der Erfassungs-Wrapper und die Feldliste
teilen den Zweig des Trägers und entstehen nur mit ihm ([ADR-0022](0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md)
Festlegung 5) — eine Aufzählung, die beide führte, behauptete eine Anwesenheit, die der Fehlerzweig
ausschließt.

**Urteil: die Zeile ist nicht haltbar — in einer Hälfte abgeschafft, in der anderen gekehrt.**

- **Abgeschafft ist die Kennung.** Sie löst im Code nicht mehr auf (erste Messung: null Go-Treffer),
  und wer ihr folgt, findet den Test nicht.
- **Gekehrt sind die zwei Behauptungen, die auf ihr stehen.** Ein korrekt skip-if-present geführter
  Pfad ist dort kein Rot mehr, sondern genau der Zustand, den der Test als seinen mißt; rot färbt der
  Pfad ohne Klasse.
- **Getragen hat die Folgerung nur zur Hälfte.** *„Benannt, nicht bewacht"* gilt weiter, aber allein
  auf dem verbleibenden Grund: die **Mengen**-Richtung hält keiner der sechs Leser der Aufzählung,
  und ein Lauf schreibt Pfade, die die Aufzählung nicht führt.

Was fällt, ist damit nicht die Deckungs-Aussage, sondern ihre doppelte Begründung: sie steht ab hier
auf **einem** Grund, und der Satz, der auf dem zweiten stand, nennt einen Namen, den es nicht mehr
gibt.

**Grenze der Messung** ([`MR-055`](../../../harness/conventions.md#mr-055--eine-stellen-messung-trägt-keine-folgerung-über-eine-eigenschaft)):
gemessen sind die zwei namentlich genannten Tests und die Leser der Aufzählung. Das ist ein negativer
Befund über **diesen** Ausschnitt und kein Beweis, daß im Repo kein Sensor die Mengen-Richtung hält —
ein solcher Sensor ist die Re-Evaluierungs-Bedingung dieser Datei, nicht ihr Widerspruch.

### Die Zeile bleibt in ihrer Datei stehen, und der Zeiger liegt daneben

[ADR-0054](0054-emittierter-commit-traeger-skip-if-present.md) steht auf `Accepted`;
[`AGENTS.md`](../../../AGENTS.md) §3.4 friert sie ein, und der zitierte Baseline-Satz nennt als Weg
ausdrücklich die neue ADR mit explizitem Verweis. Die Datei behält darum ihren Wortlaut — **diese**
Entscheidung heilt ihren Rumpf nicht ([ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md)
Festlegung 2 zieht dieselbe Grenze für ein anderes Gefäß). Den Zeiger trägt der **ADR-Index**
([`docs/plan/adr/README.md`](README.md)): er ist die derivative Sicht auf beide Entscheidungen und
kein Byte der einen ([ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md)).
Damit trifft ein Leser der [ADR-0054](0054-emittierter-commit-traeger-skip-if-present.md) an der
Status-Zelle des Index die abgelöste Stelle und den Nachfolger.

**Die Form liegt zweimal vor.** [ADR-0032](0032-eingefrorene-referenz-folgt-ihrem-rumpf.md) hat als
erste eine Folge-ADR mit Teil-`Supersedes` auf **einen** wörtlich genannten Wert einer
`Accepted`-ADR gebildet, [ADR-0050](0050-geteiltes-ventil-ersetzt-die-datei-weite-ausnahme.md) folgt
ihr mit einem `scan.ignore`-Eintrag. Der gemeinsame Zug ist, den abgelösten Gegenstand zu benennen
**und** danebenzustellen, was unverändert fortbindet: ein Teil-`Supersedes`, der seinen Umfang nicht
nennt, liest sich wie ein ganzes.

**Warum es nicht die ganze Entscheidung ist.** Die Klasse der drei Träger-Dateien, die
[ADR-0054](0054-emittierter-commit-traeger-skip-if-present.md) festlegt, ist unberührt — keine ihrer
vier Festlegungen ändert sich. Ein `Supersedes` auf die Datei behauptete eine neue Entscheidung über
denselben Gegenstand, die es nicht gibt; dieselbe Verwerfung, die
[ADR-0016](0016-verweis-traegt-tag-und-zitat.md) als Option E führt und
[ADR-0050](0050-geteiltes-ventil-ersetzt-die-datei-weite-ausnahme.md) für seine Lage wiederholt.
Dazu fiele ihre Status-Zeile auf *Superseded by …*, und auf die Datei zeigen — diese Entscheidung
selbst nicht mitgezählt — sechs lebende Markdown-Dateien mit achtzehn Nennungen:

```sh
git grep -l '0054-emittierter-commit-traeger-skip-if-present' -- ':!docs/reviews' ':!docs/plan/planning/done' ':!docs/plan/adr/0055-*' | wc -l   # 6
git grep -o '0054-emittierter-commit-traeger-skip-if-present' -- ':!docs/reviews' ':!docs/plan/planning/done' ':!docs/plan/adr/0055-*' | wc -l   # 18
```

**Keine Erwartungswerte** ([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — der Bestand wächst mit jedem neuen Verweis. **Die zwei Läufe zählen diese Datei nicht
mit:** ihre Nennungen setzt sie selbst, und eine Zitation aus der ablösenden Entscheidung ist kein
Zeugnis fremder Abhängigkeit. **Tragend ist, daß die Status-Zelle von mehreren lebenden Dokumenten
angesprochen wird und nicht von einem einzigen.**

## Entscheidung

**Zwei Festlegungen.**

**1. Der Gegenstand wird abgelöst, nicht nachgebessert.**
[ADR-0054](0054-emittierter-commit-traeger-skip-if-present.md) §Fitness Function verliert ihren
Deckungs-Absatz zur zweiten Zeile **in seiner Geltung**, nicht im Text: der Absatz bleibt stehen und
wird durch diese Datei abgelöst (Kopf-Feld oben, §Geschichte unten, Zeiger im ADR-Index). Er ist ab
hier ein Befund, kein Argument — wer ihn liest, liest den Stand, gegen den diese Entscheidung
gerichtet war, und findet den Nachfolger über den Index.

**2. Die abgelöste Aussage hat eine Adresse, und sie steht auf einem Grund statt zwei.** Was für die
zweite Zeile ab hier gilt:

- **Die Regel bleibt, wo sie steht.** *„jeder emittierte Pfad trägt genau eine Klasse — ein Pfad ohne
  Klasse färbt rot"* ist die Zeile *„Klassifikation"* in [ADR-0007](0007-bootstrap-phasen.md)
  §Fitness Function. Diese Entscheidung ändert sie nicht und schärft sie nicht.
- **Die Aussage über den Vorlagen-Emitter bleibt, wo sie steht** — ihre Vollständigkeit trägt
  [`TestTemplates_EmittierterBestandVollstaendig`](../../../internal/emit/templates_test.go); diese
  Datei wiederholt sie nicht und nimmt ihr nichts.
- **Für den Enforce-Emitter hält der Test Klasse und Richtung jedes *gelisteten* Pfades.** Ein Pfad
  ohne Klasse färbt rot (`TestEnforce_IdempotenzKlasseJePfad`), und die Richtung jedes Pfades kommt
  aus der Klasse, die er trägt — das ist die erste Zeile der Fitness-Tabelle aus
  [ADR-0054](0054-emittierter-commit-traeger-skip-if-present.md), unverändert.
- **Die Mengen-Richtung trägt keiner.** Daß ein Lauf keinen Pfad schreibt, den die Aufzählung nicht
  führt, prüft keiner der sechs Leser der Aufzählung; der Lauf schreibt zwei solche Pfade, und beide
  stehen dort aus einem benannten Grund ([ADR-0022](0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md)
  Festlegung 5). **Benannt, nicht bewacht** — die Hälfte, die trägt, ist jetzt eine andere als die,
  welche die abgelöste Begründung genannt hat.

**Was diese Entscheidung nicht ist.** Sie ist keine Form für Präsens-Aussagen in einfrierenden
Artefakten: sie löst **einen** Gegenstand ab und sagt nichts darüber, wie ein Satz über ein lebendes
Artefakt zu schreiben ist, damit er nach dem Einfrieren auflösbar bleibt. Der Absatz darüber — *„Was
heute gegen die erste Zeile läuft …"* — bleibt darum ebenfalls stehen: er nennt seinen eigenen Ablauf
(*„Er fällt mit dem Vorgang aus Folgepflicht 1"*), und Folgepflicht 1 ist vollzogen. Das ist ein
datierter Zustand und keine fortgeltende Aussage; benannt wird es hier, damit kein Leser ihn als
offen nimmt.

## Verglichene Alternativen

Regeln dieser Sektion: **mindestens drei Optionen mit Pro/Contra** — „nichts tun" ist eine davon
(Baseline-Regelwerk `modul-04-adrs.md` §Ziel-Form: ADR (MADR)).

| Option | Pro | Contra |
|---|---|---|
| A — **nichts tun**, die Zeile stehen lassen | kein Schreibaufwand, keine neue ADR | die Kennung löst nicht mehr auf, und die zwei Behauptungen, die auf ihr stehen, gelten umgekehrt: wer den Absatz liest, liest einen Sensor beschrieben, den es so nicht mehr gibt. Nach [`AGENTS.md`](../../../AGENTS.md) §3.4 ist die Stelle danach **dauerhaft** nicht mehr behebbar — die Korrektur, die jetzt billig ist, wird nie wieder möglich |
| B — **die Datei an der Stelle berichtigen** („nur klarstellend") | der kürzeste Text: ein Satz ersetzt, kein neues Artefakt | §3.4 verbietet es, und der zitierte Baseline-Satz sagt warum: eine `Accepted`-ADR ist ein Geschichtsdokument, kein Wiki. Wird sie nachgebessert, kann der Reviewer-Agent auf ältere Entscheidungen nicht mehr vertrauen, ohne Versionsstände zu vergleichen — der Schaden ist größer als der Satz, um den es geht |
| C — **[ADR-0054](0054-emittierter-commit-traeger-skip-if-present.md) ganz superseden** | der abgelöste Absatz wäre mit einer ganzen Entscheidung als abgelöst markiert | **ADR-Inflation:** die Entscheidung — die Klasse der drei Träger-Dateien — ist unverändert, und ein `Supersedes` behauptete eine neue über denselben Gegenstand. Zudem fiele die Status-Zeile auf *Superseded by …*, während sechs lebende Markdown-Dateien mit achtzehn Nennungen genau dorthin zeigen (§Kontext) |
| **D — gewählt: Teil-`Supersedes` auf den einen Gegenstand** | die Geltung des Absatzes endet, sein Text bleibt als Befund; die Festlegungen, die Regel-Zeilen und die Geltungsbereichs-Grenze bleiben unangetastet und sind im Kopf-Feld **benannt**; die Bewegung ist an `git log` und in §Geschichte ablesbar; die Form hat zwei Vorgänger ([ADR-0032](0032-eingefrorene-referenz-folgt-ihrem-rumpf.md), [ADR-0050](0050-geteiltes-ventil-ersetzt-die-datei-weite-ausnahme.md)) | der abgelöste Absatz steht weiter in [ADR-0054](0054-emittierter-commit-traeger-skip-if-present.md) — der Teil-`Supersedes` nimmt ihm den Gegenstand, nicht die Worte; ein Leser ohne den Index merkt nichts davon. Und die Nachfolge-Kette wird um ein Glied länger, ohne daß sich eine Entscheidung ändert |

## Konsequenzen

- **Positiv:** Die zweite Zeile hat für ihren Deckungsstand wieder eine Adresse, und sie steht auf
  einem Grund, der heute gemessen ist, statt auf zweien, von denen einer weggefallen ist.
- **Positiv:** Der abgeschaffte Name ist als abgeschafft gekennzeichnet. Wer ihn sucht, findet ihn
  über den Index bei der ablösenden Entscheidung — und nicht als Adresse eines Sensors, den es nicht
  mehr gibt.
- **Positiv:** Was fortbindet, ist ausdrücklich aufgezählt: die vier Festlegungen, der Regel-Gehalt
  der drei Fitness-Zeilen, die Grenze gegen [ADR-0007](0007-bootstrap-phasen.md), die drei
  Re-Evaluierungs-Trigger. Kein Leser muß raten, was der Teil-`Supersedes` nimmt.
- **Negativ:** Der abgelöste Absatz bleibt in
  [ADR-0054](0054-emittierter-commit-traeger-skip-if-present.md) stehen und bleibt dort falsch. §3.4
  nimmt dem Satz den Gegenstand, nicht die Worte — dieselbe Einordnung, die
  [ADR-0050](0050-geteiltes-ventil-ersetzt-die-datei-weite-ausnahme.md) für eine Werkzeug-Aussage
  trifft. Der Träger dagegen ist der Index, und er ist kein Gate.
- **Negativ, und das ist der Preis:** Der Korrektur-Weg hängt an einem Leser des Index. Kein Modul
  des Doku-Gates prüft, ob eine Kennung, die ein einfrierendes Artefakt nennt, noch existiert
  (§Fitness Function). Eine Zeile dieser Art fällt erst auf, wenn ihr jemand folgt.
- **Folgepflicht (der Lauf, der diese ADR annimmt, im selben Commit wie ihr Umschlag):** den Zusatz in
  der `Status`-Zelle von [ADR-0054](0054-emittierter-commit-traeger-skip-if-present.md) im ADR-Index
  setzen. Der Index trägt ihn nur, wo eine `Accepted`-ADR ihn anordnet — **diese ADR ordnet ihn an**,
  weil jene ihre eigene Teil-Revision nicht nachtragen kann. Inhalt: der Umfang der Revision und die
  revidierende ADR, sonst nichts; was fortgilt, steht im Kopf-Feld dieser Datei und wird hier nicht
  wiederholt. **Beide Änderungen sind ein Commit:** kein Stand führt den Index mit einer noch
  `Proposed` geführten ADR als der revidierenden.
- **Keine Folgepflicht in Code und Konfiguration.** Diese Entscheidung bewegt außer sich selbst nur
  ihren Eintrag im ADR-Index. Kein Pfad, keine Schwelle, kein Gate ändert sich; `make gates` prüft
  über demselben Baum.
- **Und der Vorgang, der hier *nicht* geführt wird.** Die Klasse *„Präsens-Aussage in einem
  einfrierenden Artefakt ohne Form"* steht mit der Closure des tragenden Vorgangs bei **3×** — diese
  Entscheidung ist ihr dritter Fall. Ob daraus eine Form für solche Zeilen folgt, ist **nicht** hier
  entschieden: diese Datei löst einen Gegenstand ab und setzt keine Schreib-Regel. Den Ausgang der
  Beobachtung weist der Lese-Schritt zu; ist er *geplant*, ist der Träger ein eigener Vorgang, und
  sein Norm-Text entsteht nach [`AGENTS.md`](../../../AGENTS.md) §3.8 in der Architect-Rolle. **Eine
  Kennung nennt diese Datei dafür nicht:** der Schnitt ist Planner-Arbeit
  ([`MR-057`](../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)),
  und ein Name in einem einfrierenden Artefakt ist genau die Klasse, die hier offen bleibt.

## Fitness Function (falls maschinell prüfbar)

**Diese Entscheidung behauptet keinen neuen Sensor — sie benennt, was trägt, und was nicht.**

| Tooling | Regel | Make-Target |
|---|---|---|
| `go test` | **die zweite Zeile, auf einem Grund:** der Vorlagen-Emitter hält seinen Ist-Bestand gegen eine Erwartungsliste; für den Enforce-Emitter hält `TestEnforce_IdempotenzKlasseJePfad` Klasse und Richtung jedes **gelisteten** Pfades, und ein Pfad ohne Klasse färbt rot (roter Fall: `test/mutations/361-traeger-ohne-klasse.sh`). Die **Mengen**-Richtung — kein geschriebener Pfad ohne Listeneintrag — hält keiner der sechs Leser der Aufzählung | `make test` |
| **kein Gate** — ob eine Kennung, die ein **einfrierendes Artefakt** beim Namen nennt, noch existiert, prüft kein Modul des Doku-Gates (`grep -n '^modules:' .d-check.yml` nennt `links, anchors, ids, matrix, codepaths, spans, planning, targets`), `make comment-claims` hat **keine** Markdown-Datei in seinem Prüfbereich, und `make mutate` kennt keine Fehlschlag-Form dafür. **Benannt, nicht bewacht** | — | — |

## Re-Evaluierungs-Trigger

- **Wenn ein Sensor dieses Repos, den *diese* Datei beim Namen nennt, umbenannt oder abgeschafft
  wird.** Dann trifft dieselbe Bewegung, die diese Datei zieht, ihren eigenen Text, und die
  Namens-Achse der Tabelle oben ist neu zu ziehen. Beobachtbar an dem Commit, der ihn umbenennt; der
  Fall ist nicht konstruiert — er ist der Anlaß dieser Datei.
- **Wenn ein Sensor die Mengen-Richtung übernimmt** — kein geschriebener Pfad ohne Listeneintrag —,
  dann trägt der Enforce-Emitter die zweite Zeile ganz, und der vierte Punkt von Festlegung 2 ist zu
  ziehen.
- **Wenn die Klasse *„Präsens-Aussage in einem einfrierenden Artefakt"* eine Form bekommt**, ist zu
  prüfen, ob diese Datei sie trägt oder von ihr abgelöst wird (§Konsequenzen, letzter Punkt).
- **Permanent** ist der Teil-`Supersedes` selbst: ein abgelöster Gegenstand wird nicht erneut
  abgelöst, und der Absatz in [ADR-0054](0054-emittierter-commit-traeger-skip-if-present.md) bleibt
  stehen, wo er steht ([`AGENTS.md`](../../../AGENTS.md) §3.4).

### Der Acceptance-Trigger

Diese Entscheidung steht auf `Proposed`. Sie wird `Accepted`, **wenn eine Reviewer-Runde sie gegen
[ADR-0054](0054-emittierter-commit-traeger-skip-if-present.md),
[ADR-0007](0007-bootstrap-phasen.md), [ADR-0032](0032-eingefrorene-referenz-folgt-ihrem-rumpf.md),
[ADR-0050](0050-geteiltes-ventil-ersetzt-die-datei-weite-ausnahme.md) und
[ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) auf Konsistenz geprüft hat und
ihr Report ohne blockierenden Befund in `docs/reviews/` liegt.**

**Drei Fächer** — die Dreiteilung, die [ADR-0046](0046-welle-datei-entsteht-mit-der-eroeffnung.md)
§Der Acceptance-Trigger gesetzt hat und
[ADR-0048](0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) und
[ADR-0051](0051-anweisungssatz-eigentum-traegt-ueber-die-emissionsgrenze.md) führen: Ein
blockierender Befund an der **Darstellung** — Adressform, Zahl ohne Kommando, Zitat-Stelle — wird
behoben und hindert die Annahme nicht; dasselbe gilt für einen Befund an jedem Abschnitt, der mit
dem Accept einfriert, **ohne eine Festlegung zu tragen** — die Kopffelder, §Kontext, §Verglichene
Alternativen, §Konsequenzen, §Fitness Function, die Re-Evaluierungs-Trigger, dieser
Trigger-Abschnitt selbst und §Geschichte. Ändert eine Behebung eine der zwei **Festlegungen dieser
Datei** oder die Feststellung, was der abgelöste Absatz trägt und was nicht, ist es ein
Substanz-Befund und blockiert.

Der Beleg ist eine Runde der prüfenden Rolle; ihre **Kennung** steht in der Accept-Zeile der
§Geschichte, nicht als Pfad-Link ([ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md)
Festlegung 1).

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-09-16 | **Proposed** | Architect-Entscheid auf den Vollzug der Folgepflicht 1 von [ADR-0054](0054-emittierter-commit-traeger-skip-if-present.md): der Ganz-Mengen-Test ist mit dem Vorgang umbenannt, und die Kennung, die jene Datei in ihrer §Fitness Function führt, löst im Code nicht mehr auf. Die Messungen in §Kontext stehen neben ihren Kommandos; der ADR-Index trägt den Eintrag dieser Datei, der Zusatz an der Status-Zelle von [ADR-0054](0054-emittierter-commit-traeger-skip-if-present.md) ist Folgepflicht des annehmenden Laufs |
| 2026-09-16 | **Accepted** | Beleg nach [ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 1 ist die Konsistenzrunde `2026-09-16-adr-0055-konsistenz` — ihr Verdikt lautet *„Annahmefähig: ja"*, und kein Befund berührt eine der zwei Festlegungen dieser Datei; ihre Summary nennt 3 LOW und 2 INFO, und die drei Darstellungs-Befunde wie die zwei Anmerkungen sind vor diesem Umschlag gezogen. [ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 2 ist nicht ausgelöst: die Runde meldet keinen blockierenden Befund. **Der Zusatz an der Status-Zelle von [ADR-0054](0054-emittierter-commit-traeger-skip-if-present.md) entsteht in demselben Commit.** **Ab hier bindet [`AGENTS.md`](../../../AGENTS.md) §3.4:** Korrekturen entstehen als Folge-ADR mit `Supersedes ADR-0055`. |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0055` (Baseline-Regelwerk `v6.8.0`, `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).
