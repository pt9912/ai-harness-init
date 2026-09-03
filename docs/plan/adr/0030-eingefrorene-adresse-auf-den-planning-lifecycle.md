# ADR-0030: Eine eingefrorene Adresse auf den Planning-Lifecycle wird ausgenommen — und die Entscheidung wandert vor den Move

**Status:** Accepted

**Datum:** 2026-09-03

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (ein Gate,
dessen einziger Befund unbehebbar ist, erzieht dazu, Rot zu überlesen),
[ADR-0018](0018-ziel-fassung-regiert-die-migration.md) (das eingefrorene Artefakt, das die
Adresse trägt), [ADR-0026](0026-eingefrorene-referenz-referenz-weit-ausgenommen.md) (der
Schlüssel, unter dem der Eintrag steht, und die Aufnahme-Grenze, die diese ADR erfüllt),
[ADR-0027](0027-tote-adresse-in-eingefrorener-adr.md) (dieselbe Klasse am Carveout-Verzeichnis;
Festlegung 3, die diese ADR auf einen zweiten Zielbaum ausdehnt),
[ADR-0016](0016-verweis-traegt-tag-und-zitat.md) (Festlegung 2 — *Eigenschaft statt Adresse*;
Festlegung 4 — die Zeitdokument-Klausel, die hier nicht reicht),
[ADR-0021](0021-verbrauchs-achse-je-rolle-ohne-quelle.md) (Festlegung 5 — das Ziel-Ende, und der
Satz, der den nächsten Fall einzeln stellt),
[ADR-0017](0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) (dieselbe Klasse auf der
Datei-Achse),
[`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben dem Kommando, das sie liefert)

**Schärft:** — Prozess-ADR ohne Spec-Stratum: sie senkt einen Gate-Prüfumfang und setzt eine
Verweis- und eine Reihenfolge-Regel, sie ändert keine Spec-Aussage.

**Abgrenzung — diese ADR supersedet keine.**
[ADR-0026](0026-eingefrorene-referenz-referenz-weit-ausgenommen.md) und
[ADR-0027](0027-tote-adresse-in-eingefrorener-adr.md) schließen ihren `ignore-refs`-Schlüssel
extensional auf ein bzw. ein zusätzliches Paar und verlangen für jedes weitere eine eigene
Entscheidung: *„jeder zusätzliche Eintrag … ist eine neue Senkung und löst
[`AGENTS.md`](../../../AGENTS.md) §3.5 erneut aus — auch dann, wenn er dieselbe Bedingung
erfüllt"*. Diese ADR ist die verlangte eigene Entscheidung; sie erfüllt jene Grenze, statt sie zu
umgehen, und lässt beide Paare unberührt. Festlegung 3 von
[ADR-0027](0027-tote-adresse-in-eingefrorener-adr.md) bindet das Carveout-Verzeichnis; Festlegung
3 unten bindet einen **anderen** Zielbaum und nimmt jener nichts weg.

---

## Kontext

### Der Befund, an einer Sonde und nicht an einer Prognose

Die Closure von `welle-10` verlangt den `git mv` der Welle-Plan-Datei von flach nach `done/`.
Baseline-Regelwerk `v5.12.0`, `modul-06-roadmap.md` §Wellen-Closure-Prozedur, Schritt 3, verbatim:
*„Und die Welle-Plan-Datei wandert per `git mv` von flach nach `done/`"* — der Satz steht dort
einmal:

```sh
grep -c 'Und die Welle-Plan-Datei wandert per `git mv` von flach nach' .harness/baseline/v5.12.0/regelwerk/modul-06-roadmap.md   # 1
```

Der Move wurde in diesem Lauf **probeweise vollzogen**, alle übrigen Verweise in beide Richtungen
nachgezogen, `make docs-check` gefahren und der Zustand danach zurückgenommen:

```
docs/plan/adr/0018-ziel-fassung-regiert-die-migration.md:202	docs/plan/planning/welle-10-re-baseline.md	codepath-missing
d-check: 491 Datei(en) geprüft, 1 Befund(e)
```

Der Befund ist ein **`codepath-missing`**, kein `target-missing`: die Adresse steht in ADR-0018
als Inline-Code, nicht als Markdown-Link. Das ist der Unterschied zu beiden Vorgänger-Fällen und
entscheidet unten die Werkzeug-Frage.

### Warum ihn niemand im Artefakt behebt

[ADR-0018](0018-ziel-fassung-regiert-die-migration.md) steht auf `Accepted`
(`grep -c '^\*\*Status:\*\* Accepted' docs/plan/adr/0018-ziel-fassung-regiert-die-migration.md` →
**1**). [`AGENTS.md`](../../../AGENTS.md) §3.4 bindet nach
[ADR-0027](0027-tote-adresse-in-eingefrorener-adr.md) Festlegung 1 *„das Artefakt, nicht nur seine
Aussage"*; weder [ADR-0016](0016-verweis-traegt-tag-und-zitat.md) Festlegung 4 (Zeitdokumente,
deren Grund — *„Zeitdokumente sind nicht von §3.4 geschützt"* — bei einer ADR gerade abwesend ist)
noch [ADR-0023](0023-verweis-beschluss-traegt-ueber-den-sprung.md) Festlegung 2 (die die Linie
ausdrücklich *„an der Änderbarkeit der Quelle"* zieht) reicht auf eine angenommene ADR. Der Befund
ist richtig und im Artefakt unbehebbar.

**Das Ziel-Ende trägt hier so wenig wie in [ADR-0027](0027-tote-adresse-in-eingefrorener-adr.md).**
[ADR-0021](0021-verbrauchs-achse-je-rolle-ohne-quelle.md) Festlegung 5 hat einen Carveout ortsfest
gestellt; ihr tragender Grund war ein Negativ-Befund — im Regelwerk stehe **kein** Satz, der für
jenen Ausgang ein Verzeichnis vorschreibt. Für die Welle-Plan-Datei steht er (Zitat oben). Den
Move zurückzunehmen wäre eine Abweichung von der adoptierten Baseline und schuldete einen Eintrag
im Adaptions-Block ([`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage)).

### Die Klasse ist erhoben — und sie hat heute zwei lebende Mitglieder, nicht eines

Erhoben über **beide** Adress-Formen, nicht nur über die des Befundes. Zuerst die Code-Spans:

```sh
git grep -coE '`docs/plan/planning/[^`]*`' -- 'docs/plan/adr/[0-9]*.md' | awk -F: '{s+=$NF} END{print s+0}'   # 11  Vorkommen
git grep -lE  '`docs/plan/planning/[^`]*`' -- 'docs/plan/adr/[0-9]*.md' | wc -l                              #  5  Dateien
```

Von den 11 sind neun **ortsfest**: sie nennen ein Verzeichnis (`…/done/`, `…/open/`,
`docs/plan/planning/`), ein Glob (`…/done/**`) oder eine Datei, die bereits in `done/` liegt und
den Lifecycle damit verlassen hat. Beweglich ist genau eine — die aus dem Befund:

```sh
git grep -noE '`docs/plan/planning/[^`]*\.md`' -- 'docs/plan/adr/[0-9]*.md' | grep -vc '/done/'   # 1
```

Die Markdown-Link-Form ist die zweite Hälfte, und sie liefert das zweite Mitglied:

```sh
git grep -noE '\]\([^)]*planning/[^)]*\)' -- 'docs/plan/adr/[0-9]*.md'
# docs/plan/adr/0011-telemetrie-erfassung-policy.md:27   ](../planning/welle-09-modul-15-konformitaet.md)
# docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md:48  ](../planning/observations.md)
# docs/plan/adr/0029-agenten-typkarten-derivativ-gemischte-originale.md:65 ](../../docs/plan/planning/done/slice-060-rollen-achse.md)
```

Von diesen dreien ist einer beweglich: `observations.md` ist die **stehende** Datei des
Beobachtungs-Registers und wandert nicht, `slice-060` liegt in `done/`. `welle-09` dagegen liegt
flach und offen, und seine Quelldatei ist eingefroren
(`grep -c '^\*\*Status:\*\* Accepted' docs/plan/adr/0011-telemetrie-erfassung-policy.md` → **1**).

**Damit steht die Klasse so:** zwei eingefrorene ADRs adressieren je eine flache Welle-Plan-Datei,
auf zwei verschiedenen Adress-Formen und damit über zwei verschiedene d-check-Module. Der eine
Fall ist **eingetreten** (welle-10 schließt), der andere ist **geladen** (welle-09 ist offen und
ruhend). **Keine Erwartungswerte**
([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — die Zahlen wandern mit dem Bestand.

### Der Generator ist derselbe wie bei den Vorgängern, und er ist jetzt zweimal benannt

Baseline-Regelwerk `modul-07-carveouts.md` schreibt den `done/`-Move bei der Carveout-Auflösung
vor; `modul-06-roadmap.md` schreibt ihn für die Welle-Plan-Datei vor. Beide Male gilt: *der
Zustand ist die Verzeichnis-Position*, und beide Male trägt darum **jede** Pfad-Adresse auf ein
Lifecycle-Artefakt ihr Verfallsdatum eingebaut — das Ereignis, das sie bricht, ist genau der
Vorgang, den der Prozess vorschreibt. [ADR-0027](0027-tote-adresse-in-eingefrorener-adr.md) hat
das für den Carveout-Baum ausgesprochen und mit Festlegung 3 die Verweis-Form gesetzt. Der
Planning-Baum ist derselbe Generator mit einem anderen Modul; die Form-Regel dort deckt ihn nicht,
weil sie ihren Zielbaum nennt.

### Das Ventil, gemessen — beide Skopen an einer roten Gegenprobe

Sonde in [`.d-check.yml`](../../../.d-check.yml), je ein `make docs-check` über dem probeweise
bewegten Baum, danach zurückgenommen. Der gepinnte d-check ist derselbe, an dem
[ADR-0026](0026-eingefrorene-referenz-referenz-weit-ausgenommen.md) und
[ADR-0027](0027-tote-adresse-in-eingefrorener-adr.md) gemessen haben
([`d-check.mk`](../../../d-check.mk)):

| Sonde | `in` | `refs` | Ergebnis |
|---|---|---|---|
| trägt | [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) | der **unbewegte** Ort der Welle-Plan-Datei (Wortlaut in Festlegung 2) | `491 Datei(en) geprüft, 0 Befund(e)` |
| Gegenprobe Quell-Skopus | [ADR-0011](0011-telemetrie-erfassung-policy.md) | wie oben | `491 Datei(en) geprüft, 1 Befund(e)` |
| Gegenprobe Ziel-Skopus | [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) | der **bewegte** Ort, also mit `done/`-Segment | `491 Datei(en) geprüft, 1 Befund(e)` |
| Gegenmessung Datei-Achse | — | `scan.ignore` um [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) erweitert | `490 Datei(en) geprüft, 0 Befund(e)` |

**Tragend ist der Unterschied in der ersten Zahl, nicht ihr Betrag.** Das Referenz-Ventil lässt
sie bei 491 stehen, der datei-weite Ausschluss senkt sie auf 490.

**Die erste Sonde beantwortet zugleich eine Werkzeug-Frage, die keine der beiden Vorgänger-ADRs
gestellt hat.** Beide bestehenden Paare schalten einen **Markdown-Link** stumm, also einen Befund
des Moduls `links`. Dieser Fall ist ein `codepath-missing`. Dass der Top-Level-`ignore-refs`
auch `codepaths` honoriert, steht als Aussage im Config-Kommentar der Datei — hier ist es
**gemessen**: die erste Sonde schaltet den `codepath-missing` ab, die dritte lässt ihn stehen.

### Die Senkung ist real, und die Restbreite dieses Paares ist strukturell null

Aus der Prüfung fällt, was `in` und `refs` gemeinsam treffen. Heute ist das genau eine Referenz,
und morgen auch — die Quelldatei ist nach §3.4 eingefroren und kann keine zweite bekommen:

```sh
grep -coF '`docs/plan/planning/welle-10-re-baseline.md`'      docs/plan/adr/0018-ziel-fassung-regiert-die-migration.md   # 1  Code-Span
grep -coE '\]\([^)]*welle-10-re-baseline\.md\)'               docs/plan/adr/0018-ziel-fassung-regiert-die-migration.md   # 0  Markdown-Link
```

Was ein datei-weiter Ausschluss stattdessen kostete, je mit seinem Kommando:

```sh
grep -oE '\]\([^)]+\)' docs/plan/adr/0018-ziel-fassung-regiert-die-migration.md | wc -l            # 35  Link-Vorkommen
grep -oE '\]\([^)]+\)' docs/plan/adr/0018-ziel-fassung-regiert-die-migration.md | sort -u | wc -l  # 13  eindeutige Ziele
```

Der Prüfbereich verliert trotzdem eine Referenz, die dieses Repo autoritativ schreibt — derselbe
Test, mit dem
[`MR-029`](../../../harness/conventions.md#mr-029--der-scanignore-zensus-wandert-und-sein-dritter-grund-ist-keine-scoping-aussage)
Scoping von Senkung trennt. Es ist eine Senkung nach [`AGENTS.md`](../../../AGENTS.md) §3.5, und
darum diese ADR.

### Was die Bereichs-Ausnahme kostet — und dass sie die Klasse nicht einmal deckt

Der naheliegende Ausweg wäre `docs/plan/adr/**` in `codepaths.exempt-paths`. Er schließt den
Befund (`491 Datei(en) geprüft, 0 Befund(e)`), und er kostet:

```sh
git grep -ohE '`[a-zA-Z0-9_.][a-zA-Z0-9_./-]*\.[a-z]{2,5}`' -- 'docs/plan/adr/[0-9]*.md' | wc -l           # 668  Code-Span-Vorkommen
git grep -ohE '`[a-zA-Z0-9_.][a-zA-Z0-9_./-]*\.[a-z]{2,5}`' -- 'docs/plan/adr/[0-9]*.md' | sort -u | wc -l # 143  eindeutige Ziele
ls docs/plan/adr/[0-9]*.md | wc -l                                                                         #  29  ADR-Dateien
grep -L '^\*\*Status:\*\* Accepted' docs/plan/adr/[0-9]*.md | wc -l                                        #   5  davon noch änderbar
```

Fünf der 29 stehen **nicht** auf `Accepted`. Bei ihnen ist eine tote Adresse behebbar, und die
Bereichs-Ausnahme machte sie unsichtbar — sie nähme die Prüfung dort weg, wo die Reparatur erlaubt
ist.

**Und sie deckt die Klasse nicht.** Gemessen an einer Sonde: `docs/plan/adr/**` in
`codepaths.exempt-paths` **und** das zweite `ignore-refs`-Paar entfernt —

```
docs/plan/adr/0026-eingefrorene-referenz-referenz-weit-ausgenommen.md:309	../carveouts/CO-005-adaptions-block-datierter-beleg.md	target-missing
d-check: 491 Datei(en) geprüft, 1 Befund(e)
```

Die Markdown-Link-Hälfte derselben Klasse bleibt rot, weil `exempt-paths` unter `codepaths:` steht
und nur dieses Modul bindet. Die Bereichs-Ausnahme zahlt 668 Referenzen über 143 Ziele in 29
Dateien und löst **eine** von zwei Adress-Formen — sie ist nicht nur breit, sie ist an dieser
Aufgabe vorbei.

## Entscheidung

**Wir wählen Option G: das eingefrorene Artefakt bleibt unberührt, der Doku-Gate bekommt ein
drittes namentlich geschnittenes Referenz-Ventil, und die Klasse wird an beiden Enden angehalten
— an der Verweis-Form vor dem Einfrieren und an der Reihenfolge vor dem Move.** Vier Festlegungen.

**1. [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) wird nicht angefasst — kein Byte, auch
nicht an der Adresse.** [`AGENTS.md`](../../../AGENTS.md) §3.4 bindet das Artefakt, nicht nur seine
Aussage. Der Befund ist richtig und in ihm unbehebbar.

**2. [`.d-check.yml`](../../../.d-check.yml) bekommt genau ein drittes
Top-Level-`ignore-refs`-Paar, dessen beide Skopen je auf eine namentlich genannte Datei geschnitten
sind** —

- `in: "docs/plan/adr/0018-ziel-fassung-regiert-die-migration.md"`
- `refs: ["docs/plan/planning/welle-10-re-baseline.md"]`

**und keinen weiteren.**

Das ist eine Aufnahme-**Grenze**, keine Aufnahme-**Regel**: **jeder zusätzliche Eintrag, jedes
zusätzliche Glob in `in` oder `refs` und jede Verbreiterung eines der beiden auf ein Verzeichnis
ist eine neue Senkung und löst [`AGENTS.md`](../../../AGENTS.md) §3.5 erneut aus — auch dann, wenn
sie dieselbe Bedingung erfüllt wie diese.** Die Grenzen aus
[ADR-0026](0026-eingefrorene-referenz-referenz-weit-ausgenommen.md) und
[ADR-0027](0027-tote-adresse-in-eingefrorener-adr.md) gelten unverändert weiter; diese ADR erhöht
die Zahl der Paare von zwei auf drei und nicht die Zahl der Entscheidungen, die ein viertes
braucht.

**Das geladene zweite Mitglied wird hier ausdrücklich nicht mitgenommen.** Die Referenz aus
[ADR-0011](0011-telemetrie-erfassung-policy.md) auf die Welle-Plan-Datei von `welle-09` löst heute
auf; sie stumm zu schalten hieße, eine **lebende, richtige** Referenz aus der Prüfung zu nehmen,
und zwar für die unbestimmte Zeit, die jene Welle noch offen ist. Das wäre eine größere und
längere Blindheit als der Fall, der ansteht, und es entschiede einen Vorgang, dessen Sonde niemand
gefahren hat. Festlegung 4 fängt ihn stattdessen.

**Der Eintrag trägt im Config-Kommentar seine Begründung und einen Zeiger auf diese ADR** — wie
jede Ventil-Zeile der Datei.

**3. Ein Artefakt, das unveränderlich wird, nennt ein Artefakt des Planning-Lifecycle bei der
Kennung, nicht als Pfad-Adresse.** Gebunden ist dasselbe wie in
[ADR-0027](0027-tote-adresse-in-eingefrorener-adr.md) Festlegung 3 — eine ADR ab *Accepted*, ein
Rollen-Report, eine Closure-Notiz; jedes Artefakt, das nach Abschluss nicht mehr angefasst wird —
und dieselbe Adress-Menge: `welle-<NN>`, `slice-<NNN>`. Der sichtbare Text bleibt die Kennung, die
Adresse entfällt. Träger ist der **Accept-Übergang**, wie
[ADR-0016](0016-verweis-traegt-tag-und-zitat.md) Festlegung 3 (a) ihn führt.

**Gebunden ist nur, was wandert.** Ein Verzeichnis (`docs/plan/planning/done/`), ein Glob, die
stehende Register-Datei und eine Datei, die bereits in `done/` liegt, sind ortsfest und bleiben
als Pfad zulässig — das sind neun der elf heute gemessenen Code-Spans. Die Regel trifft die
bewegliche Adresse, nicht den Baum.

**Was Festlegung 3 nicht verlangt: den Verzicht in änderbaren Artefakten.** In Plandateien,
Registern, [`AGENTS.md`](../../../AGENTS.md) und den Spec-Straten bleibt der Pfad der richtige
Zeiger, und der Move zieht ihn nach — die Linie verläuft an der Änderbarkeit der Quelle
([ADR-0023](0023-verweis-beschluss-traegt-ueber-den-sprung.md) Festlegung 2).

**4. Ein vom Prozess vorgeschriebener Lifecycle-Move wird entschieden, bevor er vollzogen wird.**
Vor dem `git mv` eines Planning- oder Carveout-Artefakts misst der bewegende Lauf, ob ein nach
[`AGENTS.md`](../../../AGENTS.md) §3.4 eingefrorenes Artefakt es als Pfad adressiert — über
**beide** Adress-Formen, Code-Span und Markdown-Link, weil sie auf verschiedene d-check-Module
fallen. Findet er einen, gehört die Entscheidung **vor** den Move und nicht danach.

Das ist die Hälfte, die diese ADR über ihre Vorgänger hinausträgt. Festlegung 3 bindet den
Schreiber des Zeigers und wirkt nur vorwärts — sie kann an einer bereits angenommenen ADR nichts
mehr ändern, und deshalb bleibt der Bestand ihr Rest. Festlegung 4 bindet den **Beweger** und
wirkt auf genau diesen Rest: Sie verwandelt ein rotes Gate mit gesperrter Reparatur in geplante
Arbeit. Der Preis der falschen Reihenfolge ist nicht Aufwand, sondern ein Befund, den niemand
beheben darf, in einem Lauf, der etwas anderes vorhatte.

**Diese ADR wendet Festlegung 3 auf sich selbst an**: sie nennt `welle-09`, `welle-10` und die
Slice-Kennungen bei der Kennung und trägt keine bewegliche Pfad-Adresse in den Planning-Baum. Der
Wortlaut der Adresse in Festlegung 2 ist die Ausnahme, die sich selbst erklärt — er ist der
Gegenstand des Config-Eintrags und steht dort als Zitat der Config, nicht als Zeiger.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — nichts tun, den Befund rot lassen und aussprechen | keine Senkung, keine Änderung | `make docs-check` bliebe dauerhaft rot, und der Befund wäre der **einzige** (`491 Datei(en) geprüft, 1 Befund(e)` an der Sonde). Ein Dauer-Rot mit Zähler 1 ist kein Sensor mehr: jeder echte neue Befund erschiene als Zähler 2 in einem Lauf, den man ohnehin rot erwartet ([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). Und `welle-10` §3 verlangt `make gates` grün **ohne offenen Carveout auf einem Gate dieser Welle** — die Welle könnte nicht schließen |
| B — die Adresse in [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) nachziehen | fünf Zeichen, schließt den Befund | Byte-Änderung an einem §3.4-eingefrorenen Artefakt, von keiner Quelle gedeckt. Und sie setzte in einen Absatz, der den Stand **vor** der Closure festhält, die Adresse nach ihr — dieselbe Verfälschung, die [ADR-0027](0027-tote-adresse-in-eingefrorener-adr.md) an ihrer Geschichte-Zeile beschrieben hat |
| C — die Adresse entfällt, der Text bleibt | schlösse den Fall dauerhaft, nicht nur bis zum nächsten Move | dieselbe Byte-Änderung. [ADR-0016](0016-verweis-traegt-tag-und-zitat.md) Festlegung 4 trägt sie **nicht**: sie ist für Zeitdokumente geschrieben, und ihr Grund — *„Zeitdokumente sind nicht von §3.4 geschützt"* — ist bei einer ADR abwesend. Die Form ist richtig; sie gehört vor das Einfrieren, und dort steht sie als Festlegung 3 |
| D — Ziel-Ende: die Welle-Plan-Datei bleibt flach, wie [ADR-0021](0021-verbrauchs-achse-je-rolle-ohne-quelle.md) Festlegung 5 den Carveout | keine Gate-Senkung; löste beide Mitglieder der Klasse auf einmal | der tragende Grund jener Festlegung fehlt: er ist ein **Negativ**-Befund über eine Quelle, die schweigt, und `modul-06-roadmap.md` schweigt nicht (Zitat im Kontext). Der Zug wäre eine Baseline-Abweichung samt Adaptions-Eintrag und nähme dem Repo den Satz *der Zustand ist die Verzeichnis-Position*, auf dem der ganze Lifecycle steht |
| E — `scan.ignore` auf [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) (Datei-Achse, wie [ADR-0017](0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md)) | eine Zeile Config, sofort grün, ein bereits geführter Schlüssel | nimmt die **ganze Datei** aus der Prüfung statt der einen toten Referenz. Gemessen fällt die geprüfte Datei-Zahl um eins (`490 … 0 Befund(e)` gegen `491 … 0` beim Referenz-Ventil, Sonden-Tabelle oben) — der Prüfbereich schrumpft, was das Referenz-Ventil gerade nicht tut |
| F — Bereichs-Ausnahme `docs/plan/adr/**` in `codepaths.exempt-paths` | eine Zeile, deckte jede künftige tote Code-Span-Adresse in jeder ADR | **intensional statt extensional** und zweifach widerlegt: sie kostet **668** Code-Span-Vorkommen über **143** Ziele in **29** Dateien, davon **5** noch änderbar — dort nähme sie die Prüfung weg, wo die Reparatur erlaubt ist. Und sie **deckt die Klasse nicht**: an der Sonde bleibt die Markdown-Link-Hälfte derselben Klasse rot (`target-missing`, Kontext), weil `exempt-paths` unter `codepaths:` steht. Sie zahlt breit und löst halb |
| G' — drittes **und viertes** Paar, das geladene [ADR-0011](0011-telemetrie-erfassung-policy.md)-Mitglied gleich mit | ersparte die nächste Runde; die Menge ist gemessen und heute geschlossen | schaltete eine **heute auflösende, richtige** Referenz stumm, und zwar für die unbestimmte Zeit, die `welle-09` offen ist — eine größere Blindheit als der anstehende Fall. Der Restbreite-Wächter sähe sie als gedeckt (ein auflösender Link) und schwiege. Und sie entschiede einen Vorgang im Voraus, dessen Sonde niemand gefahren hat — genau die Form, die [ADR-0017](0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md), [ADR-0021](0021-verbrauchs-achse-je-rolle-ohne-quelle.md), [ADR-0026](0026-eingefrorene-referenz-referenz-weit-ausgenommen.md) und [ADR-0027](0027-tote-adresse-in-eingefrorener-adr.md) je verworfen haben |
| **G — gewählt: drittes Paar, beide Skopen namentlich, plus die Verweis-Form für den Planning-Baum und die Reihenfolge-Regel vor dem Move** | kleinstmöglicher Prüfbereichs-Verlust — die geprüfte Datei-Zahl bleibt bei 491, die Restbreite ist strukturell null; beide Skopen sind an einer roten Gegenprobe belegt; und die Klasse wird an **beiden** Enden angehalten, statt beim nächsten Mitglied dieselbe Runde zu kosten: Festlegung 3 verhindert neue Mitglieder, Festlegung 4 fängt die bestehenden vor ihrem Move | es ist die dritte Ausnahme unter demselben Schlüssel und die vierte Gate-Senkung dieser Klasse. Festlegung 4 hat heute **keinen** Sensor; ihr Träger ist ein Übergang, kein Lauf. Und sie behebt nur den eingetretenen Fall — das `welle-09`-Mitglied bleibt geladen und braucht bei seinem Move eine eigene Entscheidung, nur eben **vor** ihm statt danach |

## Konsequenzen

- **Positiv:** `make docs-check` bleibt grün, ohne dass ein eingefrorenes Artefakt angefasst wird
  und ohne dass eine Datei den Prüfbereich verlässt — die geprüfte Datei-Zahl steht vor und nach
  dem Eintrag auf demselben Wert. `welle-10` kann schließen.
- **Positiv:** Die Restbreite dieses Paares ist strukturell null: `in` ist nach §3.4 eingefroren
  und kann keine zweite Referenz bekommen.
- **Positiv:** Festlegung 3 hält die Klasse vorwärts an; Festlegung 4 fängt den Bestand. Zusammen
  hört die Klasse auf, pro Mitglied eine Entscheidungs-Runde zu kosten — nicht weil künftige Fälle
  im Voraus autorisiert wären, sondern weil sie nicht mehr als Notfall auftreten.
- **Negativ:** Der Bestand ist damit nicht geheilt. Die Referenz aus
  [ADR-0011](0011-telemetrie-erfassung-policy.md) auf die Welle-Plan-Datei von `welle-09` ist
  geladen; sie wird bei deren Closure einzeln entschieden.
- **Negativ:** [`AGENTS.md`](../../../AGENTS.md) §3.5 hat **keinen Sensor**. Die Schranke gegen ein
  viertes Paar ist prozessual, wie bei jeder anderen Senkung dieses Repos.
- **Negativ:** Festlegung 4 hat heute keinen Sensor. Kein Modul des Doku-Gates liest
  Lifecycle-Reihenfolgen, und `make slice-mv` — das Werkzeug, das Lifecycle-Moves fährt — bewegt
  ausweislich seiner eigenen Grenze 2 **keine** Welle-Plan-Dateien und misst keine eingefrorenen
  Quellen. Ihr Träger ist der Lauf, der den Move plant.
- **Folgepflicht 1 (der Lauf, der den Eintrag setzt):** das dritte Paar in
  [`.d-check.yml`](../../../.d-check.yml) anlegen — **samt Config-Kommentar mit Begründung und
  Zeiger auf diese ADR** — und mit zwei `make docs-check`-Läufen über dem probeweise bewegten Baum
  belegen, dass der Befund ohne den Eintrag steht und mit ihm fällt, bei unveränderter geprüfter
  Datei-Zahl. `scan.ignore` und `codepaths.exempt-paths` bleiben unverändert.
- **Folgepflicht 2 (benannte Lücke, nicht behauptete Deckung):** der Restbreite-Wächter
  `test/ignore-refs-restbreite.bats` liest **jedes** Paar des Top-Level-Blocks, misst aber
  ausweislich seines eigenen Kopfes nur die **Inline-Markdown-Form** `](ziel)`. Für dieses Paar
  zählt er darum **null** Links und ist grün, ohne die Restbreite gemessen zu haben — die reale
  Breite ist ein Code-Span (Kommando im Kontext). Der Wächter braucht die Code-Span-Achse; **diese
  ADR behauptet ihn nicht als vorhanden**
  ([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). Sein
  Gegenbeispiel ist ein zweiter Code-Span derselben Quelldatei auf dasselbe Ziel, und er muss
  einmal rot gesehen werden ([`AGENTS.md`](../../../AGENTS.md) §3.6).
- **Folgepflicht 3 (der Wächter zu Festlegung 3):** der Sensor, den
  [ADR-0027](0027-tote-adresse-in-eingefrorener-adr.md) Folgepflicht 3 für ihre Festlegung 3
  verlangt, deckt mit dieser ADR einen zweiten Zielbaum und eine zweite Adress-Form ab: er wird
  rot, sobald ein Artefakt mit Status `Accepted` eine **bewegliche** Pfad-Adresse in den
  Planning-Baum trägt. Der heutige Bestand ist **extensional** gemessen (elf Code-Spans, davon
  neun ortsfest; drei Markdown-Links, davon zwei ortsfest — Kommandos im Kontext) und ausgenommen;
  die Prüfung greift auf Zuwachs.

## Fitness Function (falls maschinell prüfbar)

**Gebaut — und was es nach dieser Senkung noch prüft:**

| Tooling | Regel | Make-Target |
|---|---|---|
| d-check `codepaths` + `links` + `anchors` | jede Referenz aus [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) **außer** der einen ausgenommenen löst auf; jede Referenz **auf** die Datei bleibt vollständig bewacht — der Eintrag wirkt auf der Ziel-Achse, nicht auf der Quell-Achse | `make docs-check` |
| bats, `test/ignore-refs-restbreite.bats` | der Top-Level-`ignore-refs`-Block wird vollständig und in bekannter Form gelesen; eine unbekannte Zeilenform färbt rot statt still zu bleiben | `make test` (in `make gates`) |

**Nicht gebaut, und hier ehrlich zu benennen — drei Stück.** Die **Restbreite dieses Paares** hat
keinen Sensor: der vorhandene Wächter misst Markdown-Links und sieht die Code-Span-Form nicht
(Folgepflicht 2). **Festlegung 3** hat keinen: kein Modul des Doku-Gates liest Status und
Adress-Form zusammen (Folgepflicht 3). **Festlegung 4** hat keinen und ist die schwächste der
drei: Sie ist eine Aussage über die **Reihenfolge zweier Commits**, und kein Gate dieses Repos
liest Commits — dieselbe Lage, die [`AGENTS.md`](../../../AGENTS.md) §3.8 für sich selbst
feststellt. Sie liegt im Feedforward-Quadranten: benannt, nicht geschlossen.

## Re-Evaluierungs-Trigger

- **Wenn `welle-09` schließt** *(an der Verzeichnis-Position ihrer Plan-Datei ablesbar; ohne
  vorherige Entscheidung färbt `make docs-check` rot)*: dann bricht die Referenz aus
  [ADR-0011](0011-telemetrie-erfassung-policy.md). Zu entscheiden ist zwischen einem vierten Paar
  und einem anderen Weg — in einer eigenen ADR, nicht hier, und nach Festlegung 4 **vor** dem
  Move. Diese Entscheidung deckt ihn **nicht**.
- **Wenn ein viertes Paar gesetzt werden soll** *(am Vorgang ablesbar; §3.5 greift von selbst)*:
  dann ist zu prüfen, ob Festlegung 3 nicht getragen hat, ob Festlegung 4 übergangen wurde oder ob
  der Fall neu ist. Drei verschiedene Diagnosen mit drei verschiedenen Antworten.
- **Wenn der Restbreite-Wächter die Code-Span-Achse bekommt** *(an
  `test/ignore-refs-restbreite.bats` ablesbar)*: dann ist Folgepflicht 2 eingelöst, und die Zusage
  „dieses Paar deckt genau eine Referenz" hat ihren Sensor statt nur ihre Messung.
- **Wenn die adoptierte Baseline den `done/`-Move der Welle-Plan-Datei nicht mehr verlangt** *(am
  Regelwerk der Baseline ablesbar)*: dann fällt der strukturelle Auslöser, und die Festlegungen 3
  und 4 werden für diesen Zielbaum gegenstandslos.
- **Wenn [`AGENTS.md`](../../../AGENTS.md) §3.4 eingeschränkt würde** *(am Text ablesbar)*: dann
  fällt die Voraussetzung von Festlegung 1, der Befund wäre im Artefakt behebbar, und der Eintrag
  aus Festlegung 2 ist **zurückzunehmen**, nicht stillschweigend mitzuführen.
- **Wenn der gepinnte d-check das geteilte `ignore-refs` verlöre** *(feedforward — eine
  Werkzeug-Version, kein Sensor; sichtbar wird sie, wer den CHANGELOG des neuen Pins gegen den
  alten liest)*: dann fällt die Voraussetzung von Festlegung 2, und der Befund kehrt zurück.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-09-03 | **Proposed** | Architect-Entscheid zu dem Befund, den die `welle-10`-Closure erzeugt. Sechs Läufe am gepinnten Stand tragen ihn: der probeweise vollzogene Move mit nachgezogenen Verweisen, das geschnittene Referenz-Ventil, seine zwei roten Gegenproben, die Gegenmessung auf der Datei-Achse und die Sonde, die der Bereichs-Ausnahme die Deckung der Klasse abspricht. Die Klasse ist über **beide** Adress-Formen erhoben, nicht nur über die des Befundes — daran ist das zweite, geladene Mitglied sichtbar geworden, das Festlegung 4 trägt |
| 2026-09-03 | **Accepted** | Angenommen vom Auftraggeber; der Auftrag an diesen Lauf verlangt die Entscheidung **in Kraft** — `make docs-check` mit **0** Befunden über dem bewegten Baum — und die Closure des tragenden Slice, dessen Closure-Trigger `**Status:** Accepted` nennt. Vollzogen in der Architect-Rolle ([`AGENTS.md`](../../../AGENTS.md) §3.8). **Ab hier bindet [`AGENTS.md`](../../../AGENTS.md) §3.4**: jede Korrektur ist eine Folge-ADR mit `Supersedes`. Festlegung 3 regiert diese Tabelle selbst — `welle-09` und `welle-10` stehen bei der Kennung, ohne bewegliche Pfad-Adresse |
