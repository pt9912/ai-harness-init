# ADR-0032: Die eingefrorene Referenz behält ihre Ausnahme — ihr Quell-Schlüssel folgt dem Rumpf

**Status:** Accepted

**Datum:** 2026-09-03

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (ein Gate,
der dauerhaft rot steht, ist so wenig wert wie einer, den es nicht gibt),
[ADR-0026](0026-eingefrorene-referenz-referenz-weit-ausgenommen.md) (die Entscheidung, deren
Re-Evaluierungs-Trigger hier feuert und deren `in:`-Wert diese ADR ersetzt),
[ADR-0016](0016-verweis-traegt-tag-und-zitat.md) (die Voraussetzung: der Bestand wird nicht
geheilt), [ADR-0023](0023-verweis-beschluss-traegt-ueber-den-sprung.md) (hält jenen Beschluss
gegen den adoptierten Stand neu),
[ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) (dieselbe Klasse — ein vom
Prozess vorgeschriebener Ortswechsel bricht eine Adresse in einem eingefrorenen Artefakt),
[`MR-021`](../../../harness/conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben)
(der Eintrag, der die ausgenommene Referenz trägt),
[`MR-045`](../../../harness/conventions.md#mr-045--der-adaptions-block-läuft-in-der-verzeichnis-form)
(die Verzeichnis-Form, die den Ortswechsel vollzieht),
[`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben dem Kommando, das sie liefert)

**Schärft:** — Prozess-ADR ohne Spec-Stratum: sie zieht einen Config-Schlüssel nach, sie ändert
keine Spec-Aussage.

**Supersedes (Teil):** [ADR-0026](0026-eingefrorene-referenz-referenz-weit-ausgenommen.md)
§Entscheidung, und dort **genau einen Wert** — das `in:`-Feld des ersten `ignore-refs`-Paares.
Alles andere jener Entscheidung bindet unverändert fort: das `refs:`-Feld, die Beschränkung auf
**ein** Paar, und namentlich ihre Aufnahme-**Grenze** — *„jeder zusätzliche Eintrag, jedes
zusätzliche Glob in `in` oder `refs` und jede Verbreiterung eines der beiden auf ein Verzeichnis
ist eine neue Senkung"*. Diese ADR nimmt keine davon weg; sie erfüllt sie, indem sie den einen
Wert in ihrem eigenen Gefäß bewegt statt still.

---

## Kontext

### Der Trigger von [ADR-0026](0026-eingefrorene-referenz-referenz-weit-ausgenommen.md) ist eingetreten — und seine Vorhersage trägt nicht

Jene Entscheidung nennt als ersten Re-Evaluierungs-Trigger den Umzug des Adaptions-Blocks in die
Verzeichnis-Form und sagt für diesen Fall voraus, die Ausnahme werde *gegenstandslos*: der Eintrag
liege dann in einer eigenen Datei, *„wandert mit seinem Auflösungs-Trigger in das
done-Verzeichnis daneben und ist damit konstruktiv ein Zeitdokument"*, für das
[ADR-0016](0016-verweis-traegt-tag-und-zitat.md) Festlegung 4 das Entfallen der Adresse bereits
regelt.

Der Umzug ist vollzogen
([`MR-045`](../../../harness/conventions.md#mr-045--der-adaptions-block-läuft-in-der-verzeichnis-form)),
die **erste Hälfte** der Vorhersage ist eingetreten, die **zweite** nicht:

```sh
grep -c '^- \*\*Auflösungs-Trigger:\*\* permanent' harness/conventions/MR-021-das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben.md   # 1
ls harness/conventions/done/ 2>/dev/null | wc -l                                                                                                        # 0
```

[`MR-021`](../../../harness/conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben)
ist ein **lebender** Eintrag mit permanentem Auflösungs-Trigger. Er hat den Ort gewechselt, nicht
den Zustand; ein Zeitdokument ist er nicht geworden. Damit fällt die Voraussetzung, auf der jene
Entscheidung ihr *gegenstandslos* aufbaut — der Befund ist unverändert richtig und unverändert
unbehebbar, und die Ausnahme wäre zurückgenommen für eine Bedingung, die nicht eingetreten ist.

### Was sich bewegt hat, ist der Träger, nicht die Referenz

Der Rumpf reist byte-gleich um; der einzige Zeichenwechsel an ihm ist die Ebene, die dem relativen
Pfad fehlt
([`MR-045`](../../../harness/conventions.md#mr-045--der-adaptions-block-läuft-in-der-verzeichnis-form)
Setzung 1 (a)). Die ausgenommene Referenz ist dieselbe, an derselben Textstelle, mit demselben
aufgelösten Ziel — nur die Datei, die sie trägt, heißt anders:

```sh
M=harness/conventions/MR-021-das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben.md
grep -cE '\]\([^)]*\.harness/baseline/v3\.5\.2/regelwerk/modul-08-agentenrollen\.md[^)]*\)' "$M"                   # 1
grep -cE '\]\([^)]*\.harness/baseline/v3\.5\.2/regelwerk/modul-08-agentenrollen\.md[^)]*\)' harness/conventions.md # 0
```

**Keine Erwartungswerte**
([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — sie wandern mit dem Bestand.

### Warum das keine neue Senkung ist, und warum es trotzdem eine ADR braucht

**Keine Senkung:** Die Menge der stummgeschalteten Referenzen ist unverändert — ein Link, dasselbe
aufgelöste Ziel. Die Zahl der Paare bleibt drei, jedes `in` nennt weiter **eine** Datei, jedes
`refs` **eine**. Keine der drei Verbreiterungen, die
[ADR-0026](0026-eingefrorene-referenz-referenz-weit-ausgenommen.md) als neue Senkung benennt,
findet statt.

**Trotzdem eine ADR:** Jene Entscheidung nennt den Wert `in: "harness/conventions.md"` **wörtlich**
und steht auf `Accepted`. Nach [`AGENTS.md`](../../../AGENTS.md) §3.4 überschreibt ihn niemand; ein
gefeuerter Re-Evaluierungs-Trigger hat genau zwei Ausgänge — *bestätigen* oder *Folge-ADR mit
`supersedes`* (Baseline-Regelwerk `modul-06-roadmap.md` §Wellen-Closure-Prozedur Schritt 2). Ein
bloßes Bestätigen deckt einen geänderten Wert nicht. Also dieser Ausgang.

### Das Ventil trägt am gepinnten Stand — mit zwei roten Gegenproben

Sonden über dem umgezogenen Baum, gepinnter d-check
(`grep -m1 '^DCHECK_IMAGE' d-check.mk` → `ghcr.io/pt9912/d-check:v0.65.0`), je ein
`make docs-check`, danach zurückgenommen:

| Sonde | `in` | Ergebnis |
|---|---|---|
| **trägt** | die neue Trägerdatei (Wert wörtlich in §Entscheidung) | `553 Datei(en) geprüft, 0 Befund(e)` |
| Gegenprobe Quell-Skopus | `harness/conventions.md` (der alte Wert) | `553 Datei(en) geprüft, 1 Befund(e)` |
| Gegenprobe Ziel-Skopus | `refs` auf `modul-07-carveouts.md` | `553 Datei(en) geprüft, 1 Befund(e)`, Zeile `…-aufgehoben.md:55 … target-missing` |

**Tragend ist die gleiche erste Zahl in allen drei Zeilen:** das Referenz-Ventil lässt die Datei im
Prüfbereich, so wie es das vor dem Umzug tat. Der Nenner ist der Markdown-Bestand des Repos und
wandert mit ihm — **kein Erwartungswert**.

## Entscheidung

**Der erste Top-Level-`ignore-refs`-Eintrag in [`.d-check.yml`](../../../.d-check.yml) behält
`refs` unverändert und trägt als `in` die Datei, in der der Rumpf jetzt liegt:**

- `in:` — die Datei, die den Rumpf trägt:
  [`harness/conventions/MR-021-das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben.md`](../../../harness/conventions/MR-021-das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben.md)
- `refs: [".harness/baseline/v3.5.2/regelwerk/modul-08-agentenrollen.md"]`

**Und die Aufnahme-Grenze aus
[ADR-0026](0026-eingefrorene-referenz-referenz-weit-ausgenommen.md) gilt für diesen Eintrag
unverändert weiter.** Jeder zusätzliche Eintrag, jedes zusätzliche Glob in `in` oder `refs` und
jede Verbreiterung eines der beiden auf ein Verzeichnis ist eine neue Senkung und löst
[`AGENTS.md`](../../../AGENTS.md) §3.5 erneut aus — auch dann, wenn sie dieselbe Bedingung erfüllt.
Namentlich ist ein Glob auf `harness/conventions/**` in `in` **nicht** gedeckt: er autorisierte
jede künftige Referenz **jedes** Eintrags in denselben Baum im Voraus.

**Festlegung 2 — der Ortswechsel eines eingefrorenen Rumpfs zieht seinen Ausnahme-Schlüssel nach,
er hebt ihn nicht auf.** Wandert ein Rumpf, dessen Referenz ausgenommen ist, per `git mv` an einen
anderen Ort, folgt der `in:`-Schlüssel dem Rumpf, solange die ausgenommene Referenz dieselbe ist —
gleicher Link, gleiches aufgelöstes Ziel, gleiche Anzahl. Ist eine dieser drei Gleichheiten
verletzt, ist es kein Nachzug, sondern eine neue Ausnahme mit eigener ADR.

**Was diese ADR nicht entscheidet: was mit dem Eintrag geschieht, wenn er nach
`conventions/done/` wandert.** Dann greift die Vorhersage aus
[ADR-0026](0026-eingefrorene-referenz-referenz-weit-ausgenommen.md) Re-Evaluierungs-Trigger 1 mit
erfüllter Voraussetzung, und die Ausnahme ist zurückzunehmen. Der Trigger unten hält das fest.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — Ausnahme zurücknehmen, wie [ADR-0026](0026-eingefrorene-referenz-referenz-weit-ausgenommen.md) es für diesen Trigger vorsah | wörtliche Befolgung des Triggers; eine Senkung weniger | die Voraussetzung des Triggers ist **nicht** eingetreten: der Eintrag ist lebend (`Auflösungs-Trigger: permanent`) und liegt nicht in `conventions/done/`. `make docs-check` meldete dann `553 Datei(en) geprüft, 1 Befund(e)` — dauerhaft rot an einem Befund, den [`AGENTS.md`](../../../AGENTS.md) §3.4 und die Append-only-Disziplin niemandem zu beheben erlauben ([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)) |
| B — den Schlüssel still nachziehen, ohne ADR | kein Dokument, ein Zeichenwechsel | der Wert steht **wörtlich** in einer `Accepted`-ADR; ihn ohne eigenes Gefäß zu ersetzen ist genau das Überschreiben, das [`AGENTS.md`](../../../AGENTS.md) §3.4 verbietet. Und ein gefeuerter Re-Evaluierungs-Trigger ohne Ausgang ist die Absichtserklärung mit Verfallsdatum, gegen die Baseline-Regelwerk `modul-06-roadmap.md` §Wellen-Closure-Prozedur Schritt 2 den Audit stellt |
| C — den Verweis im Eintrag reparieren | keine Config-Änderung, keine Ausnahme | der Rumpf ist append-only eingefroren ([`MR-032`](../../../harness/conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger) Setzung 1). Den Tag zu ziehen erzeugte ein falsches Zitat bei grünem Gate ([ADR-0016](0016-verweis-traegt-tag-und-zitat.md) Festlegung 1); die Adresse entfallen zu lassen ist für Zeitdokumente geschrieben und trifft einen lebenden Eintrag nicht |
| D — `in` auf `harness/conventions/**` verbreitern | deckt jeden künftigen Umzug innerhalb des Blocks | **intensional statt extensional**: autorisiert jede künftige Referenz jedes Eintrags in denselben Baum im Voraus und legt [`AGENTS.md`](../../../AGENTS.md) §3.5 still. Genau die Verbreiterung, die [ADR-0026](0026-eingefrorene-referenz-referenz-weit-ausgenommen.md) namentlich als neue Senkung führt |
| **E — gewählt: `in` nennt die neue Trägerdatei, `refs` bleibt, Grenze bleibt** | kein Prüfbereichs-Verlust gegenüber dem Stand vor dem Umzug — dieselbe eine Referenz, dieselbe Datei-Zahl; beide Skopen an einer roten Gegenprobe belegt; die Grenze hängt weiter an §3.5 statt an einer Prognose | ein weiterer Umzug desselben Rumpfs (nach `conventions/done/`) verlangt erneut eine Entscheidung. Das ist gewollt: der Trigger unten fängt ihn, statt ihn im Voraus zu decken |

## Konsequenzen

- **Positiv:** `make docs-check` meldet über dem umgezogenen Baum `553 Datei(en) geprüft, 0 Befund(e)`,
  ohne dass ein append-only-Eintrag angefasst wird und ohne dass eine Datei den Prüfbereich verlässt.
- **Positiv:** Die Ausnahme kann nicht stillschweigend wachsen; die Grenze aus
  [ADR-0026](0026-eingefrorene-referenz-referenz-weit-ausgenommen.md) bindet unverändert, und
  Festlegung 2 sagt ausdrücklich, was ein Nachzug ist und was eine neue Ausnahme.
- **Negativ:** Der `in:`-Wert trägt jetzt einen **langen Dateinamen**, der aus der Überschrift des
  Eintrags erzeugt ist. Ändert jemand die Überschrift, bricht der Schlüssel — der Rumpf ist
  eingefroren, also ist das kein laufendes Risiko, aber es ist eines mehr als bei der kurzen Adresse.
- **Negativ:** [`AGENTS.md`](../../../AGENTS.md) §3.5 selbst hat **keinen Sensor**; die Schranke
  gegen eine Verbreiterung ist prozessual, wie bei jeder anderen Senkung dieses Repos.
- **Folgepflicht 1 (der Lauf, der diese ADR annimmt):** den Schlüssel in
  [`.d-check.yml`](../../../.d-check.yml) setzen, den Config-Kommentar auf den neuen Träger
  nachziehen und mit einem `make docs-check` über dem umgezogenen Baum belegen, dass der Befund
  verschwindet — samt der roten Gegenprobe mit dem alten Wert.
- **Folgepflicht 2 (derselbe Lauf):** den Zusatz in der `Status`-Zelle von
  [ADR-0026](0026-eingefrorene-referenz-referenz-weit-ausgenommen.md) im ADR-Index setzen. Der
  Index trägt ihn nur, wo eine `Accepted`-ADR ihn anordnet — **diese ADR ordnet ihn an**, weil
  jene ihre eigene Teil-Revision nicht nachtragen kann.

## Fitness Function (falls maschinell prüfbar)

| Tooling | Regel | Make-Target |
|---|---|---|
| `test/ignore-refs-restbreite.bats` | jedes `ignore-refs`-Paar deckt höchstens **einen** auflösenden Markdown-Link seiner Quelldatei — der Wächter liest den `in:`-Wert als Pfad und meldet *„Quelldatei fehlt"*, wenn er ins Leere zeigt | `make gates` |
| d-check `links` + `anchors` | jeder Markdown-Link des Eintrags **außer** dem einen ausgenommenen Ziel löst auf | `make docs-check` |

**Der Restbreiten-Wächter deckt den Nachzug mit, und das ist gemessen, nicht angenommen:** er
prüft je Paar `[ ! -f "$REPO/$src" ]` und fällt, wenn der `in:`-Wert keine Datei benennt. Ein
vergessener Nachzug wäre damit **nicht** still grün — er wäre rot in `make gates`, nicht nur in
`docs-check`. Das ist der eine Punkt, an dem diese Entscheidung besser gestellt ist als die, die
sie ergänzt.

**Nicht gebaut:** dass eine Verbreiterung eine neue ADR verlangt, ist eine Hard-Rule-Aussage
([`AGENTS.md`](../../../AGENTS.md) §3.5) und wird von keinem Lauf geprüft.

## Re-Evaluierungs-Trigger

- **Wenn [`MR-021`](../../../harness/conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben)
  sich auflöst und seine Datei nach `conventions/done/` wandert** *(an der Verzeichnis-Position
  ablesbar)*: dann ist die Voraussetzung erfüllt, die
  [ADR-0026](0026-eingefrorene-referenz-referenz-weit-ausgenommen.md) Re-Evaluierungs-Trigger 1
  annahm — der Eintrag ist konstruktiv ein Zeitdokument, und die Ausnahme ist **zurückzunehmen**,
  nicht ein zweites Mal nachzuziehen.
- **Wenn eine zweite Referenz aus derselben Quelldatei auf dasselbe Ziel entsteht**
  *(`test/ignore-refs-restbreite.bats` färbt rot)*: dann deckt die Ausnahme etwas mit, das niemand
  entschieden hat — zu entscheiden in einer eigenen ADR.
- **Wenn der gepinnte d-check das geteilte `ignore-refs` verlöre** *(feedforward — eine
  Werkzeug-Version, kein Sensor)*: dann fällt die Voraussetzung, und der Befund kehrt zurück. Ein
  Re-Pin prüft das mit dem Trockenlauf, der ohnehin fällig ist.
- **Wenn [ADR-0016](0016-verweis-traegt-tag-und-zitat.md) nicht mehr gilt** *(am Status ablesbar)*:
  dann wird der Bestand doch geheilt, es gibt keinen unbehebbaren Befund und keinen Grund für diese
  Ausnahme.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-09-03 | **Proposed** | Architect-Entscheid auf den Re-Evaluierungs-Trigger, den der Umzug des Adaptions-Blocks in die Verzeichnis-Form feuert. Drei Läufe am gepinnten Stand tragen ihn: der nachgezogene Schlüssel und seine zwei roten Gegenproben auf Quell- und Ziel-Skopus, alle drei über dem umgezogenen Baum |
| 2026-09-03 | **Accepted** | Angenommen vom Auftraggeber; der Auftrag an diesen Lauf verlangt die Entscheidung **in Kraft** — `make gates` grün mit **0** Befunden über dem umgezogenen Baum — und die Closure des tragenden Slice. Vollzogen in der Architect-Rolle ([`AGENTS.md`](../../../AGENTS.md) §3.8). **Ab hier bindet [`AGENTS.md`](../../../AGENTS.md) §3.4**: jede Korrektur ist eine Folge-ADR mit `Supersedes` |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0032` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).
