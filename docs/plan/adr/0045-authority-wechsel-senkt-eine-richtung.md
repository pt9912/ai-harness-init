# ADR-0045: Der `authority`-Wechsel auf den Einstiegspunkt senkt die Strenge in genau einer Richtung — die Senkung wird gebucht, ihr Träger ist der vorhandene repo-eigene Wächter, und dessen gemessener Rest wird geschlossen

**Status:** Proposed

**Datum:** 2026-09-13

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[ADR-0043](0043-ziel-fassung-regiert-den-sprung-v671.md) (§Was diese Entscheidung nicht tut stellt
genau die Frage zurück, die hier beantwortet wird — *„Ob `targets.authority` auf den Einstiegspunkt
wandert, … und ob das eine Senkung nach `AGENTS.md` §3.5 ist, entscheidet der Durchgang bzw. die
ADR, die er auslöst"*; dies ist diese ADR),
[ADR-0044](0044-ziel-fassung-regiert-den-sprung-v672.md) (setzt die regierende Fassung `v6.7.2`,
deren Ziel-Form den Wechsel fordert — unberührt),
[ADR-0031](0031-regierende-fassung-und-ort-der-zielstand-setzung.md) (Festlegung 2, Form der
Buchung in §Baseline — unberührt; die Korrektur eines Zustandsfelds dort ist Folgepflicht, keine
Festlegung),
[ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) (Festlegung 2 bindet den
Acceptance-Trigger unten: der Beleg ist eine Runde der prüfenden Rolle, nicht die Nachmessung des
auflösenden Kontexts),
[ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md) (das
Beobachtungs-Register bleibt Planner-Eigentum; diese Entscheidung fasst es nicht an),
[`MR-001`](../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
(die Doc-Gate-Schärfung, deren Gegenrichtung hier gemessen wird),
[`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert),
[`MR-033`](../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist),
[`MR-054`](../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)
(die emittierte Modul-Zusammensetzung — von dieser Entscheidung unberührt),
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)

**Schärft:** — Prozess-ADR ohne Spec-Stratum: sie entscheidet über die Strenge einer
Gate-Konfiguration dieses Repos und über den Träger, der sie hält, nicht über den Inhalt eines
Spec-Dokuments.

**Kopplung:** [`AGENTS.md`](../../../AGENTS.md) §3.5 ist der **Anlass**, nicht der Gegenstand — sie
verlangt für eine Schwellen-Senkung eine ADR; dies ist sie. §3.5 bleibt wörtlich unberührt und
bekommt keine zweite Fassung.

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md`
§Ziel-Form: ADR (MADR).

---

## Kontext

### Das Modul und die eine Stellschraube

Das Modul `targets` des gepinnten d-check prüft zwei Richtungen zwischen Makefile und Doku.
`gate-phantom` hält jede behauptete `make X`-Tabellenzeile gegen ein reales Rezept und liest dafür
**alle** Dateien aus `doc-tables`. `gate-undocumented` hält jede Makefile-Regel gegen eine
Deklaration und liest dafür **genau eine** Datei — den Schlüssel `authority` —, sonst muss der Name
namentlich in `exempt-targets` stehen.

Der Schlüssel nimmt einen Wert, und der Prüfbereich ist die ganze Datei. Beides ist am Schema
ablesbar, und ein Abschnitts-Scope steht nicht darin:

```sh
REF="ghcr.io/pt9912/d-check@$(sed -n 's/^DCHECK_DIGEST ?= //p' d-check.mk)"
docker run --rm --network none "$REF" --print-config | sed -n '/^# --- targets:/,/^$/p' \
  | grep -cE '^#   [a-z-]+:'                                    # 4  — makefiles, doc-tables, authority, exempt-targets
docker run --rm --network none "$REF" --print-config | sed -n '/^# --- targets:/,/^$/p' \
  | grep -ci 'heading\|section\|scope'                          # 0  (Exit 1)
```

**Keine Erwartungswerte**
([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — beide wandern mit dem Pin; gemessen am Stand, den
[`d-check.mk`](../../../d-check.mk) heute führt. Dass das Modul kein Heading-Scoping kennt, stellt
auch der repo-eigene Wächter fest (`test/targets-modul-wiring.bats`, Kommentar über
`authority_table_targets()`).

### Der Wechsel, und warum er alternativlos ist

`slice-225` hat `authority` von `AGENTS.md` auf `harness/README.md` umgestellt. Drei Gründe tragen
ihn, und keiner davon lässt eine Wahl:

1. **Die Ziel-Fassung streicht die Tabelle.** Die regierende Fassung ist `v6.7.2`
   ([ADR-0044](0044-ziel-fassung-regiert-den-sprung-v672.md)); ihre `AGENTS.md`-Vorlage führt §4
   ohne Gate-Tabelle, und der Dogfood ist nachgezogen — ``grep -cE '^\| `make ' AGENTS.md`` → **0**
   gegen ``git show 99bfd1c5^:AGENTS.md | grep -cE '^\| `make '`` → **11**. Eine Autoritäts-Datei
   ohne eine einzige `make X`-Tabellenzeile ließe jede Makefile-Regel unbelegt.
2. **Der Schlüssel nimmt eine Datei.** Zwei Autoritäts-Dateien sind am Schema oben nicht
   ausdrückbar.
3. **Die Vorgabe des Auftraggebers** für diesen Sprung lautet *vollständig übernehmen*.

Die Ziel-Fassung empfiehlt den Wert selbst: ihre Vorlage der Gate-Konfiguration legt einen
auskommentierten Block mit `authority: harness/README.md` und dem Kommentar *„dieselbe Datei — es
gibt nur einen Index"* nach
(`grep -c 'dieselbe Datei — es gibt nur einen Index' .harness/baseline/v6.7.2/templates/.d-check.yml`
→ **1**).

### Was der Wechsel kostet — gemessen, nicht behauptet

Die neue Autoritäts-Datei trägt **zwei** Tabellen, und das ist keine Eigenart dieses Repos: Die
Ziel-Form setzt die Werkzeuge-Tabelle als Unterabschnitt **in** §Sensors.

```sh
grep -nE '^## (Sensors|Traceability)|^\*\*Werkzeuge' .harness/baseline/v6.7.2/templates/harness/README.template.md
#  67: ## Sensors (Feedback-Gates)
# 140: **Werkzeuge — genannt, weil der Lauf sie braucht, aber kein Gate:**
# 154: ## Traceability rules
```

Ohne Heading-Scoping deckt damit auch eine **Werkzeuge**-Zeile die Vollständigkeits-Richtung. Die
Menge der deckenden Zeilen wächst von 11 auf 28, und die 17 hinzugekommenen sind genau die
Nicht-Gates:

```sh
git show 99bfd1c5^:AGENTS.md | grep -cE '^\| `make '                                          # 11
grep -cE '^\|.*`make [a-z][a-z0-9-]*`.*\|$' harness/README.md                                 # 28
awk '/^## Sensors \(Feedback-Gates\)/{p=1;next} p&&/^#/{exit} p' harness/README.md \
  | grep -cE '^\|.*`make [a-z][a-z0-9-]*`.*\|$'                                               # 11
sed -n '/^targets:/,/^ignore-refs:/p' .d-check.yml | grep -c '^    - '                        # 37
comm -12 <(sed -n '/^targets:/,/^ignore-refs:/p' .d-check.yml | grep '^    - ' | sed 's/^    - //' | sort -u) \
         <(grep -E '^\|.*`make [a-z][a-z0-9-]*`.*\|$' harness/README.md \
           | grep -oE '`make [a-z][a-z0-9-]*`' | tr -d '`' | sed 's/^make //' | sort -u) | wc -l   # 17
```

**Keine Erwartungswerte** — alle wandern mit Makefile, Doku und Config.

**Rot gegen grün, über beide Bäume.** Sonde: ein neues Rezept mit Hilfetext, dokumentiert **nur**
in der Werkzeuge-Tabelle, **nicht** in `exempt-targets`.

```sh
# je Baum: git archive <ref> | tar -x -C <kopie>; dann in der Kopie
printf '\nprobe-tool: ## Sonde\n\t@true\n' >> Makefile
# + eine Zeile `| `make probe-tool` | Sonde | kein Gate |` in die Werkzeuge-Tabelle
docker run --rm --network none -v "$PWD":/repo:ro "$REF" --config /repo/.d-check.yml --enable targets

# über 99bfd1c5^ (authority: AGENTS.md):
#   1231 Datei(en) geprüft, 1 Befund(e)
#   Makefile:429  probe-tool  gate-undocumented
# über fae7b7d1  (authority: harness/README.md):
#   1232 Datei(en) geprüft, 0 Befund(e)
```

Ein Repo-Zustand, den der Gate **vorher zurückwies**, geht **jetzt durch**. Das ist eine Senkung
nach [`AGENTS.md`](../../../AGENTS.md) §3.5, und sie ist damit belegt statt behauptet. Unverändert
geblieben ist die Gegenrichtung: `doc-tables` führte `harness/README.md` schon vorher
(`git show 99bfd1c5 -- .d-check.yml` ändert allein die `authority`-Zeile), also deckt `gate-phantom`
die 17 Zeilen nicht erst seit dem Wechsel.

### Was **nicht** gesunken ist — und warum das den naheliegenden Griff verwirft

Das Modul hat *nie* zwischen Gate und Nicht-Gate unterschieden; es fragt „deklariert oder
ausgenommen", nicht „in welcher Tabelle". Dieselbe Sonde über dem **alten** Baum, die Tabellenzeile
aber in der Gate-Tabelle `AGENTS.md` §4 statt in der Werkzeuge-Tabelle:

```sh
#   1231 Datei(en) geprüft, 0 Befund(e)
```

Ein Nicht-Gate in der Gate-Tabelle war also **vorher schon** grün. Ein Wächter, der genau das
verböte, stellte damit nicht die alte Strenge wieder her — er führte eine neue ein. Das ist eine
eigene Entscheidung mit eigenem Auslöser und steht unten unter §Was diese Entscheidung nicht tut.

### Der Träger existiert bereits — und niemand hat ihm die Last zugewiesen

`test/targets-modul-wiring.bats` hält ein **stärkeres** Invariant als das Modul: Der Test *„jedes
.PHONY-Target ohne Tabellenzeile im Sensors-Abschnitt steht genau einmal in exempt-targets"* rechnet
`authority_table_targets()` **am Heading ab** — nur §Sensors, ohne den Unterabschnitt §Werkzeuge.
Er läuft in `make gates` über `make test` → `test-bats`, hermetisch, ohne Docker-Bild für die
Prüfung selbst.

**Rot gesehen, in beiden Ausprägungen** (dieselbe Kopie, dasselbe Rezept, dieselbe Werkzeuge-Zeile,
kein `exempt-targets`-Eintrag):

```sh
make -C <kopie> test-bats
# probe-tool AUCH in .PHONY:
#   not ok  jedes .PHONY-Target ohne Tabellenzeile im Sensors-Abschnitt steht genau einmal in exempt-targets
# probe-tool OHNE .PHONY, sonst gleich:
#   ok      (derselbe Test — der Wächter sieht die Regel nicht)
```

Der Wächter trägt die aufgegebene Strenge also bereits, und zwar für die `.PHONY`-deklarierte
Teilmenge. **Sein Scope steht heute aber aus einem anderen Grund da:** Der Kommentar über
`authority_table_targets()` begründet ihn damit, dass der Test sonst gegen die eigene
Werkzeuge-Tabelle liefe. Dass er daneben die Senkung des Moduls auffängt, sagt keine Stelle — und
wer den Scope entfernte, machte eine zweite Senkung, die in `make gates` grün bliebe.

### Der Rest ist benennbar und heute leer

Die zwei Mengen sind verschieden: Das Modul liest **Makefile-Regeln**, der Wächter liest
**`.PHONY`-Namen**. Der Rest der Kompensation ist damit genau *eine Regel ohne `.PHONY`-Eintrag*.

```sh
comm -23 <(grep -hE '^[a-zA-Z][a-zA-Z0-9._-]*:' Makefile d-check.mk | sed -E 's/:.*//' | sort -u) \
         <(grep -h '^\.PHONY:' Makefile d-check.mk | sed -E 's/^\.PHONY:[[:space:]]*//' \
           | tr ' ' '\n' | grep -v '^$' | sort -u)
# leer — beide Mengen zählen 48 (je `| wc -l` auf dieselben zwei Pipelines)
```

**Kein Erwartungswert**, und *heute leer* ist keine Zusage für morgen: Bestand ist keine Norm.

## Entscheidung

**Drei Festlegungen.**

**1. Die Senkung ist gebucht, und der Wechsel bleibt.** `targets.authority` steht auf
`harness/README.md`. Dass der Gate damit einen Zustand durchlässt, den er vorher zurückwies, ist
oben gemessen und wird hier **entschieden**, nicht wegerklärt. Der dritte Weg — *„die
Mengen-Differenz ist leer, also kein §3.5-Fall"* — ist damit ausdrücklich verworfen: Er misst die
Richtung, die nicht gesunken ist.

**2. Die Senkung wird kompensiert, und ihr Träger ist der §Sensors-Scope von
`authority_table_targets()` in `test/targets-modul-wiring.bats`.** Ab dieser Entscheidung trägt
dieser Scope die Strenge, die der Wechsel dem Modul genommen hat: Ein Nicht-Gate-Rezept braucht
seinen `exempt-targets`-Eintrag weiterhin, auch wenn es eine Werkzeuge-Zeile hat. **Ihn zu
entfernen oder zu verbreitern, ist von hier an selbst eine Senkung nach
[`AGENTS.md`](../../../AGENTS.md) §3.5 und braucht ihre eigene ADR** — auch dann, wenn `make gates`
dabei grün bleibt, denn genau das tut es.

**3. Der gemessene Rest wird geschlossen: der Wächter bindet seine Zielmenge an die
Makefile-**Regel**-Namen statt an die `.PHONY`-Deklaration.** Damit deckt er dieselbe Menge, die
das Modul liest, und die Kompensation hat keinen Rand mehr. Der Umstieg ist heute deckungsgleich
grün — dieselbe Gleichung, die der Test prüft, mit der Regel-Menge statt der `.PHONY`-Menge:

```sh
diff <(comm -23 <(grep -hE '^[a-zA-Z][a-zA-Z0-9._-]*:' Makefile d-check.mk | sed -E 's/:.*//' | sort -u) \
                <(awk '/^## Sensors \(Feedback-Gates\)/{p=1;next} p&&/^#/{exit} p' harness/README.md \
                  | grep -E '^\|.*`make [a-z][a-z0-9-]*`.*\|$' | grep -oE '`make [a-z][a-z0-9-]*`' \
                  | tr -d '`' | sed 's/^make //' | sort -u)) \
     <(sed -n '/^targets:/,/^ignore-refs:/p' .d-check.yml | grep '^    - ' | sed 's/^    - //' | sort -u)
# leer — die Umstellung kostet heute keinen Eintrag
```

Die Ausführung ist **Implementer-Arbeit** an einer Testdatei, nicht Architect-Arbeit
([`AGENTS.md`](../../../AGENTS.md) §3.8); sie steht unten als Folgepflicht. Bis sie landet, ist der
Rest **benannt, nicht geschlossen** — und er ist die eine Zeile, die diese Entscheidung offen
zurücklässt.

### Was diese Entscheidung nicht tut

- **Kein Wächter *„ein Nicht-Gate steht nicht in §Sensors"*.** Er stellte nichts wieder her: Über
  dem alten Baum war derselbe Zustand grün (§Kontext, zweite Sonde). Eine Verschärfung ist zulässig
  und braucht kein ADR — aber sie braucht einen Auslöser, und dieser Vorgang liefert ihn nicht.
- **Keine Bindung der §Sensors-Tabelle an den `gates`-Abschluss.** Der Griff ist verfügbar und
  urteilsfrei — die Zeilen der Sensors-Tabelle und die Vorbedingungen von `record-gates` plus
  `gates` unterscheiden sich um genau einen Namen:

  ```sh
  diff <(awk '/^## Sensors \(Feedback-Gates\)/{p=1;next} p&&/^#/{exit} p' harness/README.md \
         | grep -oE '`make [a-z][a-z0-9-]*`' | tr -d '`' | sed 's/^make //' | sort -u) \
       <( { grep '^record-gates:' Makefile | sed -E 's/^record-gates:[[:space:]]*//; s/##.*//' \
              | tr ' ' '\n'; printf 'gates\nrecord-gates\n'; } | grep -v '^$' | sort -u)
  # > record-gates   — die einzige Differenz, und der Name steht in exempt-targets
  ```

  Er ginge über den alten Stand hinaus, verlangte eine namentliche Ausnahme und träfe jeden Gate,
  der vorübergehend nicht in `gates` hängt. Das ist eine eigene Entscheidung; hier steht sie als
  Re-Evaluierungs-Trigger, nicht als Festlegung.
- **Keine Verschiebung der Werkzeuge-Tabelle aus `harness/README.md`.** Sie stünde dann nicht mehr
  in der Autoritäts-Datei und die Senkung wäre an der Wurzel weg — aber die Ziel-Form setzt beide
  Tabellen in §Sensors (Messung oben), und ein zweiter Einstiegs-Ort wäre eine Abweichung mit
  eigenem Eintrag im Adaptions-Block.
- **Keine Aussage über die emittierte Ebene.** Was ein Zielrepo an `targets`-Konfiguration bekommt,
  entscheidet
  [`MR-054`](../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)
  und der Slice, der die Tool-Ebene entscheidet.
- **Keine Erweiterung der `ignore-refs`-Grenze.** Die Aufnahme-Grenzen dort bleiben, wie
  [`AGENTS.md`](../../../AGENTS.md) §3.11 sie führt; diese Entscheidung berührt einen anderen
  Modul-Schlüssel.
- **Cutoff — ab dieser Entscheidung, kein Nachrüsten.** Gebunden ist die Änderung, die am Scope
  oder an der Zielmenge des Wächters geschrieben wird. **Geltungsbereich: dieses Repo.**

### Der Acceptance-Trigger

Diese Entscheidung steht auf `Proposed`. Sie wird `Accepted`, **wenn eine Reviewer-Runde sie gegen
[ADR-0043](0043-ziel-fassung-regiert-den-sprung-v671.md) §Was diese Entscheidung nicht tut,
[ADR-0044](0044-ziel-fassung-regiert-den-sprung-v672.md) und
[`AGENTS.md`](../../../AGENTS.md) §3.5 auf Konsistenz geprüft hat und ihr Report ohne blockierenden
Befund in `docs/reviews/` liegt** — und **wenn diese Runde die drei Sonden selbst gefahren hat**:
die Werkzeuge-Zeilen-Sonde über beiden Bäumen, die Gate-Tabellen-Sonde über dem alten Baum, und den
`test-bats`-Lauf in beiden `.PHONY`-Ausprägungen. Der auslösende Report vom 2026-09-13 ist der
Beleg **nicht**: Er hat blockiert, und nach
[ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 2 ist der Beleg
dann die nächste Runde derselben Rolle — die Nachmessung des Kontexts, der den Befund auflöst, ist
keiner. Dieser Lauf ist jener Kontext; ein Selbst-Accept ist damit ausgeschlossen.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — nichts tun: die Senkung nicht buchen | kein Aufwand; `make gates` bleibt grün, und die Richtung, die der Plan maß, ist wirklich nicht gesunken | genau der dritte Weg, den der Review verwirft. §3.5 verlangt für eine Senkung eine ADR, und die Senkung ist rot-gegen-grün belegt. Die kuratierte Ausnahmeliste altert still weiter, und die Einordnung *Gate oder kein Gate* fällt aus, ohne dass etwas rot wird |
| B — buchen, aber ausdrücklich **nicht** kompensieren | ehrlich und billig; die Senkung stünde entschieden statt wegerklärt da | ließe einen Träger ungenutzt, der schon läuft und schon rot wird. Und der §Sensors-Scope bliebe unzugewiesen: Wer ihn entfernt, senkt ein zweites Mal, ohne dass eine Quelle ihn hält |
| C — den Wechsel rückgängig machen, `authority` bleibt `AGENTS.md` | die Senkung entfiele vollständig | die Datei trägt keine `make X`-Tabellenzeile mehr (**0**, Messung oben) — jede Makefile-Regel stünde unbelegt da; das ist keine höhere Strenge, sondern ein rotes Gate. Und es widerspräche der Ziel-Fassung und der Vorgabe *vollständig übernehmen* |
| D — die Werkzeuge-Tabelle in eine eigene Datei ziehen, damit die Autoritäts-Datei nur Gates trägt | löste die Senkung an der Wurzel, ohne einen zweiten Wächter zu brauchen | die Ziel-Form setzt beide Tabellen **in** §Sensors (Messung in §Kontext: 67 · 140 · 154). Eine zweite Einstiegs-Datei wäre eine Abweichung mit eigenem Adaptions-Eintrag — teurer als das Problem, und sie spaltete den Einstiegspunkt, den `harness/README.md` sein soll |
| E — Wächter *„ein Nicht-Gate-Rezept steht nicht in §Sensors"* | die kuratierte Einordnung *Gate oder kein Gate* bekäme endlich einen Sensor | stellt die alte Strenge **nicht** wieder her — sie bestand nie (zweite Sonde: über dem alten Baum grün). Eine Verschärfung ohne Auslöser, und sie träfe die Senkung nicht: Das durchgelassene Rezept steht in §Werkzeuge, nicht in §Sensors |
| F — die §Sensors-Tabelle an den `gates`-Abschluss binden | urteilsfrei und stärker als alles andere; die Differenz ist heute genau `record-gates` | geht über den alten Stand hinaus, braucht eine namentliche Ausnahme und trifft jeden Gate, der vorübergehend nicht in `gates` hängt. Eigene Entscheidung, eigener Auslöser — steht unten als Trigger |
| G — Heading-Scoping vom Modul verlangen (`targets.authority-section`) | nähme die Senkung dort weg, wo sie entsteht; d-check ist ein Nachbar-Repo, die Werkzeug-Grenze ist verschiebbar | liegt nicht in diesem Repo und nicht in diesem Lauf; bis dahin bliebe die Senkung unkompensiert. **Nicht exklusiv** zur gewählten Option — steht unten als Re-Evaluierungs-Trigger |
| **H — gewählt: buchen · den vorhandenen Träger binden · den gemessenen Rest schließen** | trifft genau den Defekt: der Träger läuft bereits und wird bereits rot, ihm fehlt allein die Zuweisung. Kostet kein neues Gate, keine neue Datei und keinen neuen Prüfbereich — nur eine Zeile Zielmengen-Wechsel, die heute deckungsgleich grün ist. Und macht das Entfernen des Scopes zu einem §3.5-Fall statt zu einer stillen zweiten Senkung | die Kompensation hängt an einem repo-lokalen bats-Test, nicht am Modul: Wer die Config in ein anderes Repo kopiert, bekommt sie nicht mit. Und Festlegung 2 selbst hat keinen Sensor — sie hängt am Rollen-Wechsel vor der Änderung |

## Konsequenzen

- **Positiv:** Die Senkung steht entschieden statt wegerklärt. Ein späterer Lauf, der die
  `authority`-Zeile liest, findet die Begründung und die Gegenmessung an einer Adresse.
- **Positiv:** Der `exempt-targets`-Eintrag bleibt für ein Nicht-Gate-Rezept Pflicht — nicht mehr
  über das Modul, aber über einen Wächter, der in `make gates` läuft und rot gesehen ist.
- **Positiv:** Der §Sensors-Scope bekommt eine zweite, tragende Begründung. Sein Entfernen ist ab
  hier ein ADR-Fall und nicht mehr eine Aufräum-Zeile.
- **Negativ, und es ist der Preis:** Die Kompensation sitzt eine Ebene tiefer als der Defekt. Das
  Modul bleibt gesenkt; was sie hält, ist ein repo-lokaler Test. Wandert die Gate-Config ohne ihn in
  ein anderes Repo, wandert die Senkung ohne Träger mit.
- **Negativ:** Zwei Stellen beschreiben jetzt denselben Prüfbereich — der Scope im Wächter und diese
  Entscheidung. Das ist der Preis dafür, dass ein Kommentar die Norm nicht trägt; bei Konflikt gilt
  diese Datei (Source Precedence).
- **Negativ:** Bis Festlegung 3 landet, bleibt der `.PHONY`-Rest offen. Er ist heute leer und morgen
  nicht garantiert leer.
- **Negativ /
  [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6):** Für
  Festlegung 2 selbst gibt es **keinen** Sensor — kein Modul und kein `make`-Ziel liest den Scope
  eines bats-Tests. Sie liegt im Feedforward-Quadranten.
- **Folgepflicht (Implementer), fällig mit dem nächsten Anfassen von
  `test/targets-modul-wiring.bats`, spätestens vor der nächsten Makefile-Regel ohne `.PHONY`:**
  Festlegung 3 ausführen — Zielmenge auf Makefile-Regelnamen, Dateikopf und Funktionskommentar
  ziehen nach. Die Zahlen im Dateikopf (`47`) sind am heutigen Stand `48` (`| wc -l` auf dieselben
  zwei Pipelines) und gehören mitgezogen.
- **Folgepflicht (Implementer), fällig unabhängig von dieser Entscheidung:** Der Sensor-Vertrag in
  `harness/sensors/docs-check.md` sagt *„prüft gegen genau eine `authority`-Datei —
  `harness/README.md` §Sensors"* zu. Das Modul liest die **Datei**. Der Vertrag gehört auf das
  eingeschränkt, was das Werkzeug hält, mit dem Wächter aus Festlegung 2 als dem, der den Abschnitt
  trägt.
- **Folgepflicht (Planner), fällig unabhängig von dieser Entscheidung:** Diese Senkung gehört als
  Beleg ins Beobachtungs-Register oder als ausdrückliche Ablehnung dort — das Register ist
  Planner-Eigentum ([ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md))
  und wird von dieser Entscheidung nicht angefasst.
- **Darüber hinaus ändert diese ADR keine Datei außer sich selbst und dem ADR-Index.**

## Fitness Function (falls maschinell prüfbar)

**Gebaut: einer — und er ist der Gegenstand von Festlegung 2.**

| Tooling | Regel | Make-Target |
|---|---|---|
| `test/targets-modul-wiring.bats` | *„jedes .PHONY-Target ohne Tabellenzeile im Sensors-Abschnitt steht genau einmal in exempt-targets"* — hält die aufgegebene Strenge für die `.PHONY`-Menge; rot gesehen mit `probe-tool` | `make test` (in `make gates`) |
| `test/targets-modul-wiring.bats` | *„kein exempt-targets-Eintrag ist zugleich eine Sensors-Tabellenzeile"* — hält die Disjunktheit, die das Modul nie hielt | `make test` (in `make gates`) |

**Nicht gebaut, und die Kandidaten sind einzeln geprüft:**

| Kandidat | Warum er die Regel nicht misst |
|---|---|
| Modul `targets` des gepinnten d-check | kennt kein Heading-Scoping (Schema-Messung oben); genau deshalb gibt es diese Entscheidung |
| Modul `structure` (verfügbar, in `modules:` nicht geführt) | prüft Existenz und Füllung einer Abschnitts-Überschrift, nicht den Prüfbereich eines fremden Tests |
| `make comment-claims` | prüft, ob ein in einem Kommentar **genannter** Sensor existiert — nicht, worüber ein Kommentar spricht; `test/*.bats` liegt ohnehin außerhalb seines Prüfbereichs |
| `make mutate` | kennt zwei Fehlschlag-Formen, `--- FAIL:` und `not ok N`. Eine Mutation, die den §Sensors-Scope entfernt, färbt **keinen** Test rot — sie färbt ihn grün, und das ist die Form, die `mutate` nicht sieht |

**Was ein Sensor könnte, wenn er gebaut würde:** die Zielmenge des Wächters gegen die Menge halten,
die das Modul liest — urteilsfrei, und genau das ist Festlegung 3. **Was er nicht könnte:** die
Entscheidung ersetzen, *ob* kompensiert wird.

## Re-Evaluierungs-Trigger

- **Wenn das Modul `targets` Heading-Scoping lernt** *(beobachtbar an einem Schlüssel wie
  `authority-section` im `targets`-Block von `d-check --print-config` unter einem neuen Pin)*: Die
  Senkung ist an der Wurzel weg, Festlegung 2 verliert ihren Gegenstand, und Option G ist die
  bessere Lösung. Diese Entscheidung ist dann gegen sie zu halten.
- **Wenn `harness/README.md` nur noch eine `make X`-Tabelle trägt** *(beobachtbar daran, dass die
  §Sensors-Zeilenzahl und die Datei-Zeilenzahl der beiden `grep -c`-Kommandos oben gleich sind)*:
  Dieselbe Lage — die Senkung wäre weg, Option D faktisch eingetreten.
- **Wenn `authority` mehr als eine Datei nimmt** *(beobachtbar am Schema oben)*: Der Grund, der den
  Wechsel alternativlos machte, ist weg, und die Wahl der Autoritäts-Datei ist neu zu halten.
- **Wenn eine Makefile-Regel ohne `.PHONY`-Eintrag entsteht, solange Festlegung 3 offen ist**
  *(beobachtbar daran, dass der `comm -23`-Lauf oben eine Zeile ausgibt)*: Der benannte Rest ist
  eingetreten und die Folgepflicht überfällig.
- **Wenn der §Sensors-Scope von `authority_table_targets()` entfernt oder verbreitert wird**
  *(feedforward — `make gates` bleibt dabei grün und meldet es nicht)*: Festlegung 2 ist gebrochen,
  und der Vorgang gehört als eigene Senkung zurück in dieses Gefäß.
- **Wenn ein Gate dauerhaft in §Sensors steht, ohne in `gates` zu hängen** *(beobachtbar am
  `diff`-Lauf unter Option F, der dann mehr als `record-gates` ausgibt)*: Option F ist gegen die
  gewählte zu halten — entweder trägt sie, oder sie ist endgültig verworfen.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-09-13 | **Proposed** | Architect-Lauf; Anlass ist HIGH-1 des Review-Reports zu `slice-225`. Die zurückgestellte Frage aus [ADR-0043](0043-ziel-fassung-regiert-den-sprung-v671.md) §Was diese Entscheidung nicht tut ist damit beantwortet. |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0045` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).
