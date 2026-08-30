# ADR-0027: Eine tote Adresse in einer eingefrorenen ADR wird ausgenommen, nicht nachgezogen — und ein Carveout-Zeiger entsteht künftig ohne Adresse

**Status:** Accepted

**Datum:** 2026-08-30

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (ein Gate,
dessen einziger Befund unbehebbar ist, erzieht dazu, Rot zu überlesen),
[ADR-0016](0016-verweis-traegt-tag-und-zitat.md) (Festlegung 1 — der Bestand wird nicht geheilt;
Festlegung 2 — *Eigenschaft statt Adresse*; Festlegung 4 — die Zeitdokument-Klausel, die hier
nicht reicht), [ADR-0023](0023-verweis-beschluss-traegt-ueber-den-sprung.md) (die drei Klassen
einer Nennung, und die Linie an der **Änderbarkeit der Quelle**),
[ADR-0017](0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) (dieselbe Klasse auf der
Datei-Achse), [ADR-0021](0021-verbrauchs-achse-je-rolle-ohne-quelle.md) (Festlegung 5 — der Weg
über das Ziel-Ende, und der Satz, der den nächsten Fall einzeln stellt),
[ADR-0026](0026-eingefrorene-referenz-referenz-weit-ausgenommen.md) (der Schlüssel, unter dem
dieser Eintrag steht, und die Aufnahme-Grenze, die diese ADR erfüllt),
[`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben dem Kommando, das sie liefert)

**Schärft:** — Prozess-ADR ohne Spec-Stratum: sie senkt einen Gate-Prüfumfang und setzt eine
Verweis-Form, sie ändert keine Spec-Aussage.

**Abgrenzung — diese ADR supersedet keine.**
[ADR-0026](0026-eingefrorene-referenz-referenz-weit-ausgenommen.md) schließt ihren
`ignore-refs`-Schlüssel extensional auf **ein** Paar und verlangt für jedes weitere eine eigene
Entscheidung: *„jeder zusätzliche Eintrag, jedes zusätzliche Glob in `in` oder `refs` und jede
Verbreiterung eines der beiden auf ein Verzeichnis ist eine neue Senkung und löst
[`AGENTS.md`](../../../AGENTS.md) §3.5 erneut aus"*. Diese ADR ist die verlangte eigene
Entscheidung; sie erfüllt jene Grenze, statt sie zu umgehen, und lässt jenes Paar unberührt.

---

## Kontext

### Der Befund

`make docs-check` meldet genau einen Befund, und es ist der letzte rote im Repo:

```
docs/plan/adr/0026-eingefrorene-referenz-referenz-weit-ausgenommen.md:309	../carveouts/CO-005-adaptions-block-datierter-beleg.md	target-missing
d-check: 469 Datei(en) geprüft, 1 Befund(e)
```

Die Zeile ist die `Accepted`-Zeile der Geschichte-Tabelle von
[ADR-0026](0026-eingefrorene-referenz-referenz-weit-ausgenommen.md). Ihr Link-Text ist die
Kennung `CO-005`, ihre Adresse löst in `docs/plan/carveouts/` auf — den Ort **vor** der
Auflösung. Dort liegt die Datei nicht; sie liegt in `docs/plan/carveouts/done/` daneben.

### Der Ortswechsel ist Pflicht, nicht Zufall

Baseline-Regelwerk `v5.12.0`, `modul-07-carveouts.md` §Ziel-Form: Carveout, verbatim:
*„Auflösung ist ein `git mv` nach `done/`"* — und, zur Begründung: *„Auflösen ohne Verschiebung
ist eine zweite Lüge: der Carveout wirkt ‚aufgelöst', liegt aber weiter im aktiven
Verzeichnis."* Beide Sätze stehen dort je einmal:

```sh
grep -c 'Auflösung ist ein `git mv` nach `done/`' .harness/baseline/v5.12.0/regelwerk/modul-07-carveouts.md   # 1
grep -c 'Auflösen ohne'                           .harness/baseline/v5.12.0/regelwerk/modul-07-carveouts.md   # 1
```

Damit trägt **jeder** Pfad-Link auf einen aktiven Carveout sein Verfallsdatum eingebaut: die
Auflösung, die er oft gerade ankündigt, ist zugleich das Ereignis, das ihn bricht. Der Befund ist
kein Schreibfehler, sondern die Kollision zweier Regeln an einem Artefakt, das keine von beiden
anfassen kann.

### Warum ihn niemand im Artefakt behebt

Zwei Reparaturen liegen nahe, und beide sind eine **Byte-Änderung an einem nach**
[`AGENTS.md`](../../../AGENTS.md) **§3.4 eingefrorenen Artefakt**: die Adresse auf `done/`
nachziehen, oder die Adresse entfallen lassen und den Text stehen lassen. Keine Quelle deckt eine
von beiden.

- **§3.4 nimmt die Adresse nicht aus.** Der Satz bindet das Artefakt, und der ADR-Index sagt
  dasselbe über sich selbst: *„Auch dieser Index bessert nicht nach, was in der Quelle nicht mehr
  änderbar ist"* (`grep -c 'bessert nicht nach' docs/plan/adr/README.md` → 1).
  [ADR-0021](0021-verbrauchs-achse-je-rolle-ohne-quelle.md) sagt es in ihrer Alternativen-Zeile F
  als Preis der eigenen Wahl: *„eine ADR ist ab Accepted immutabel … kein Federstrich"*.
- **[ADR-0016](0016-verweis-traegt-tag-und-zitat.md) Festlegung 4 reicht nicht hierher.** Sie
  lässt eine Adresse entfallen und den Text stehen — für **Zeitdokumente**, und ihr Grund ist
  genau die fehlende Sperre: *„Zeitdokumente sind nicht von §3.4 geschützt, geschützt ist ihre
  Aussage."* Eine ADR ist von §3.4 geschützt.
  [ADR-0026](0026-eingefrorene-referenz-referenz-weit-ausgenommen.md) hat dieselbe Linie für einen
  anderen Gegenstand gezogen (Alternativen-Zeile C: die Festlegung *„ist für Zeitdokumente
  geschrieben … und trifft einen Eintrag in einer lebenden Datei nicht"*).
- **[ADR-0023](0023-verweis-beschluss-traegt-ueber-den-sprung.md) gibt die Klasse, nicht den
  Schluss.** Ihre Drei-Klassen-Trennung ordnet diesen Zeiger als **Adresse** ein — *„Ein Zeiger,
  der auflösen soll. Der Tausch macht ihn falsch, das Nachziehen ist richtig."* Ihre Festlegung 2
  bindet diesen Schluss aber an **änderbare** Artefakte und zieht die Linie ausdrücklich *„nicht
  am Verweis-Ziel, sondern an der Änderbarkeit der Quelle"*. Die Quelle ist hier unveränderlich.

Was ein Nachziehen zusätzlich anrichtete, steht in der Zeile selbst: sie hält den Stand fest, an
dem die Auflösung noch bevorsteht, und trüge dann die Adresse nach der Auflösung.

### Warum das Ziel-Ende hier nicht trägt

[ADR-0021](0021-verbrauchs-achse-je-rolle-ohne-quelle.md) Festlegung 5 hat dieselbe Kollision am
**Ziel-Ende** gelöst: der Carveout behält seine Adresse, *„Was den Ort ersetzt, ist der Status,
nicht das Verzeichnis"*. Ihr tragender Grund ist ein Negativ-Befund über die Quelle — *„Im
Regelwerk steht **kein** Satz, der für einen gelebten, übergeführten Carveout ein Verzeichnis
vorschreibt"*. Dieser Grund fehlt hier: er gilt dem Ausgang *übergeführt*, und für den Ausgang
*aufgelöst* schreibt Modul 7 das Verzeichnis vor (Zitat oben). Derselbe Zug wäre hier eine
Abweichung von der adoptierten Baseline und schuldete einen Eintrag im Adaptions-Block
([`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage)).

Jene Festlegung nennt zudem ihre eigene Reichweite und die Prozedur für den Fall danach: *„Ob ein
Carveout **allgemein** seine Adresse behält, sobald ein nach [`AGENTS.md`](../../../AGENTS.md)
§3.4 eingefrorenes Artefakt auf ihn zeigt, ist hier **nicht** entschieden … Der nächste Fall wird
einzeln entschieden, mit seiner eigenen Messung."* Dies ist dieser Fall, und dies ist die Messung.

### Die Klasse ist erhoben, und sie hat drei Mitglieder

Pfad-Links aus ADR-Dateien in das Carveout-Verzeichnis, je mit ihrem Kommando:

```sh
git grep -coE '\]\(\.\./carveouts/(done/)?CO-[0-9][^)]*\)' -- 'docs/plan/adr/[0-9]*.md' | awk -F: '{s+=$NF} END{print s}'   # 33  Vorkommen
git grep -lE  '\]\(\.\./carveouts/(done/)?CO-[0-9][^)]*\)' -- 'docs/plan/adr/[0-9]*.md' | wc -l                            #  5  Dateien
git grep -lE  '\]\(\.\./carveouts/(done/)?CO-[0-9][^)]*\)' -- 'docs/plan/adr/[0-9]*.md' | xargs grep -L '^\*\*Status:\*\* Accepted' | wc -l   # 0  nicht eingefroren
```

Alle fünf Quelldateien sind `Accepted` und damit unerreichbar. Die 33 Vorkommen verteilen sich auf
drei Ziele:

```sh
for co in CO-001 CO-002 CO-005; do printf '%s ' "$co"; \
  git grep -coE "\]\(\.\./carveouts/(done/)?$co-[^)]*\)" -- 'docs/plan/adr/[0-9]*.md' \
  | awk -F: '{s+=$NF} END{print s+0}'; done
# CO-001 2
# CO-002 30
# CO-005 1
```

Ihre Lage ist verschieden:

- `CO-002` ist ortsfest — [ADR-0021](0021-verbrauchs-achse-je-rolle-ohne-quelle.md) Festlegung 5
  hat das entschieden. Seine 30 Verweise können nicht brechen.
- `CO-005` ist aufgelöst und verschoben. Sein einer Verweis ist der Befund.
- `CO-001` ist **geladen**: sein Status sagt, der Auflösungs-Trigger sei eingetreten und die
  Auflösung fällig (`grep -c 'Auflösung fällig' docs/plan/carveouts/CO-001-bats-shell-lint.md` →
  1). Seine Auflösung bricht die zwei Verweise aus
  [ADR-0021](0021-verbrauchs-achse-je-rolle-ohne-quelle.md).

**Keine Erwartungswerte** ([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — die Zahlen wandern mit dem Bestand. Tragend ist, dass die Menge heute **benannt und
geschlossen** ist und nur dann wächst, wenn ein weiteres Artefakt einen Carveout als Pfad-Link
nennt, bevor es einfriert. Genau das hält Festlegung 3 unten an.

### Das Ventil, gemessen — mit beiden Skopen an einer roten Gegenprobe

Sonde in [`.d-check.yml`](../../../.d-check.yml), je ein `make docs-check`, danach zurückgenommen
(Arbeitsbaum sauber). Der gepinnte d-check ist derselbe, an dem
[ADR-0026](0026-eingefrorene-referenz-referenz-weit-ausgenommen.md) gemessen hat
([`d-check.mk`](../../../d-check.mk)):

| Sonde | `in` | `refs` | Ergebnis |
|---|---|---|---|
| trägt | [ADR-0026](0026-eingefrorene-referenz-referenz-weit-ausgenommen.md) | der **unaufgelöste** Ort von `CO-005` (Wortlaut in Festlegung 2) | `469 Datei(en) geprüft, 0 Befund(e)` |
| Gegenprobe Quell-Skopus | [ADR-0021](0021-verbrauchs-achse-je-rolle-ohne-quelle.md) | wie oben | `469 Datei(en) geprüft, 1 Befund(e)` |
| Gegenprobe Ziel-Skopus | [ADR-0026](0026-eingefrorene-referenz-referenz-weit-ausgenommen.md) | der **aufgelöste** Ort, also mit `done/`-Segment | `469 Datei(en) geprüft, 1 Befund(e)` |
| Gegenmessung Datei-Achse | — | `scan.ignore` um [ADR-0026](0026-eingefrorene-referenz-referenz-weit-ausgenommen.md) erweitert | `468 Datei(en) geprüft, 0 Befund(e)` |

**Tragend ist der Unterschied in der ersten Zahl, nicht ihr Betrag.** Das Referenz-Ventil lässt
sie bei 469 stehen, der datei-weite Ausschluss senkt sie auf 468.

### Die Senkung ist real, und sie ist die schmalste dieser Klasse

Aus der Prüfung fällt, was `in` und `refs` gemeinsam treffen — Referenzen aus
[ADR-0026](0026-eingefrorene-referenz-referenz-weit-ausgenommen.md) auf den unaufgelösten
Carveout-Pfad. Heute ist das genau eine
(`grep -coE '\]\(\.\./carveouts/CO-005-adaptions-block-datierter-beleg\.md\)' docs/plan/adr/0026-eingefrorene-referenz-referenz-weit-ausgenommen.md`
→ 1), und morgen auch: **die Quelldatei ist nach §3.4 eingefroren und kann keine zweite Referenz
bekommen.** Die Restbreite dieses Paares ist damit nicht klein, sondern strukturell null — der
Unterschied zum ersten Paar, dessen Quelle eine lebende Datei ist.

**Was ein datei-weiter Ausschluss stattdessen kostete**, je mit seinem Kommando:

```sh
grep -oE '\]\([^)]+\)' docs/plan/adr/0026-eingefrorene-referenz-referenz-weit-ausgenommen.md | wc -l            # 54  Link-Vorkommen
grep -oE '\]\([^)]+\)' docs/plan/adr/0026-eingefrorene-referenz-referenz-weit-ausgenommen.md | sort -u | wc -l  # 19  eindeutige Ziele
```

Sie bleibt trotzdem eine Senkung nach [`AGENTS.md`](../../../AGENTS.md) §3.5: der Prüfbereich
verliert eine Referenz, die dieses Repo autoritativ schreibt — derselbe Test, mit dem
[`MR-029`](../../../harness/conventions.md#mr-029--der-scanignore-zensus-wandert-und-sein-dritter-grund-ist-keine-scoping-aussage)
Scoping von Senkung trennt. Darum diese ADR.

## Entscheidung

**Wir wählen Option F: das eingefrorene Artefakt bleibt unberührt, der Doku-Gate bekommt ein
zweites namentlich geschnittenes Referenz-Ventil, und die Verweis-Form für künftige eingefrorene
Artefakte wird gesetzt.** Drei Festlegungen:

**1. [ADR-0026](0026-eingefrorene-referenz-referenz-weit-ausgenommen.md) wird nicht angefasst —
kein Byte, auch nicht an der Adresse.** [`AGENTS.md`](../../../AGENTS.md) §3.4 bindet das
Artefakt, nicht nur seine Aussage; weder
[ADR-0016](0016-verweis-traegt-tag-und-zitat.md) Festlegung 4 (Zeitdokumente) noch
[ADR-0023](0023-verweis-beschluss-traegt-ueber-den-sprung.md) Festlegung 2 (änderbare Quelle)
reicht auf eine angenommene ADR. Der Befund ist richtig und im Artefakt unbehebbar.

**2. [`.d-check.yml`](../../../.d-check.yml) bekommt genau ein zweites
Top-Level-`ignore-refs`-Paar, dessen beide Skopen je auf eine namentlich genannte Datei geschnitten
sind** —

- `in: "docs/plan/adr/0026-eingefrorene-referenz-referenz-weit-ausgenommen.md"`
- `refs: ["docs/plan/carveouts/CO-005-adaptions-block-datierter-beleg.md"]`

**und keinen weiteren.**

Das ist eine Aufnahme-**Grenze**, keine Aufnahme-**Regel**: **jeder zusätzliche Eintrag, jedes
zusätzliche Glob in `in` oder `refs` und jede Verbreiterung eines der beiden auf ein Verzeichnis
ist eine neue Senkung und löst [`AGENTS.md`](../../../AGENTS.md) §3.5 erneut aus — auch dann, wenn
sie dieselbe Bedingung erfüllt wie diese.** Die Grenze aus
[ADR-0026](0026-eingefrorene-referenz-referenz-weit-ausgenommen.md) gilt damit unverändert weiter;
diese ADR erhöht die Zahl der Paare von eins auf zwei und nicht die Zahl der Entscheidungen, die
ein drittes braucht.

**Der Eintrag trägt im Config-Kommentar seine Begründung und einen Zeiger auf diese ADR** — wie
jede Ventil-Zeile der Datei.

**3. Ein Artefakt, das unveränderlich wird, nennt einen Carveout bei der Kennung, nicht als
Pfad-Link.** Gebunden ist dasselbe wie in
[ADR-0016](0016-verweis-traegt-tag-und-zitat.md) Festlegung 2: eine ADR ab *Accepted*, ein
Rollen-Report, eine Closure-Notiz — jedes Artefakt, das nach Abschluss nicht mehr angefasst wird.
Der sichtbare Text bleibt die Kennung; die Adresse entfällt. Träger ist der **Accept-Übergang**,
wie [ADR-0016](0016-verweis-traegt-tag-und-zitat.md) Festlegung 3 (a) ihn führt: vor dem Wechsel
auf *Accepted* wird die Form hergestellt.

Das ist die dritte Anwendung derselben Regel — *Eigenschaft statt Adresse*:
[ADR-0014](0014-aufgehobener-eintrag-kopf-statt-rumpf.md) hat sie für den Adaptions-Block gezogen,
[ADR-0016](0016-verweis-traegt-tag-und-zitat.md) für den vendored Baum, hier gilt sie für das
Carveout-Verzeichnis. Der Grund ist derselbe und steht oben: der Ort wandert, und zwar auf Anweisung.

**Was Festlegung 3 nicht verlangt: den Verzicht in änderbaren Artefakten.** In Plandateien,
Registern, [`AGENTS.md`](../../../AGENTS.md) und den Spec-Straten bleibt der Pfad-Link der richtige
Zeiger, und der Move zieht ihn nach — die Linie verläuft an der Änderbarkeit der Quelle
([ADR-0023](0023-verweis-beschluss-traegt-ueber-den-sprung.md) Festlegung 2).

**Was sie nicht kostet, gemessen:** eine bare Kennung `CO-NNN` ist nicht linkpflichtig. Die
`ids.patterns` in [`.d-check.yml`](../../../.d-check.yml) führen drei Präfixe, und `CO-` ist keines
davon:

```sh
grep -cE "regex: '(ADR|LH|MR)-" .d-check.yml   # 3
grep -c  "regex: 'CO-"          .d-check.yml   # 0, Exit 1
```

**Diese ADR wendet Festlegung 3 auf sich selbst an**: sie nennt `CO-001`, `CO-002` und `CO-005` bei
der Kennung und trägt keinen Pfad-Link in das Carveout-Verzeichnis.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — nichts tun, den Befund rot lassen und aussprechen | keine Senkung, keine Änderung | `make docs-check` bleibt dauerhaft rot, und der Befund ist der **einzige**. Ein Dauer-Rot mit Zähler 1 ist kein Sensor mehr: jeder echte neue Befund erscheint als Zähler 2 in einem Lauf, den man ohnehin rot erwartet ([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)) |
| B — die Adresse nachziehen (`carveouts/` → `carveouts/done/`) | zwei Zeichen, schließt den Befund | Byte-Änderung an einem §3.4-eingefrorenen Artefakt, von keiner Quelle gedeckt ([ADR-0023](0023-verweis-beschluss-traegt-ueber-den-sprung.md) Festlegung 2 bindet den Navigations-Zeiger an eine **änderbare** Quelle). Und sie setzte in eine Zeile, die den Stand vor der Auflösung festhält, die Adresse nach ihr. Bricht außerdem beim nächsten Umbau des Verzeichnisses erneut |
| C — die Adresse entfällt, der Text bleibt | schlösse den Fall dauerhaft, nicht nur bis zum nächsten Move | dieselbe Byte-Änderung. [ADR-0016](0016-verweis-traegt-tag-und-zitat.md) Festlegung 4 trägt sie **nicht**: sie ist für Zeitdokumente geschrieben, und ihr Grund — *„Zeitdokumente sind nicht von §3.4 geschützt"* — ist bei einer ADR gerade abwesend. Die Form ist richtig; sie gehört vor das Einfrieren, und dort steht sie als Festlegung 3 |
| D — Ziel-Ende: den Move zurücknehmen, wie [ADR-0021](0021-verbrauchs-achse-je-rolle-ohne-quelle.md) Festlegung 5 | keine Gate-Senkung; löste zugleich den geladenen Fall `CO-001` | der tragende Grund jener Festlegung fehlt hier: er ist ein Negativ-Befund über den Ausgang *übergeführt*, und für *aufgelöst* schreibt Modul 7 das Verzeichnis vor. Der Zug wäre eine Baseline-Abweichung samt Adaptions-Eintrag, nähme einen vollzogenen, regelkonformen Schritt zurück — und entschiede `CO-001` **im Voraus**, also genau die intensionale Form, die [ADR-0017](0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md), [ADR-0021](0021-verbrauchs-achse-je-rolle-ohne-quelle.md) und [ADR-0026](0026-eingefrorene-referenz-referenz-weit-ausgenommen.md) je verworfen haben |
| E — `scan.ignore` auf [ADR-0026](0026-eingefrorene-referenz-referenz-weit-ausgenommen.md) (Datei-Achse, wie [ADR-0017](0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md)) | eine Zeile Config, sofort grün, ein bereits geführter Schlüssel | nimmt die **ganze Datei** aus der Prüfung, nicht die eine tote Referenz — 54 Link-Vorkommen über 19 eindeutige Ziele, von denen heute alle bis auf eines auflösen (Zensus mit Kommandos im Kontext). Gemessen fällt die geprüfte Datei-Zahl um eins (`468 … 0 Befund(e)` gegen `469 … 0` beim Referenz-Ventil, Sonden-Tabelle oben) |
| G — [`AGENTS.md`](../../../AGENTS.md) §3.4 auf die **Aussage** einschränken, damit B und C zulässig werden | löste die Klasse an der Wurzel und ohne jede Senkung; die Zuständigkeit liegt beim Architect ([`AGENTS.md`](../../../AGENTS.md) §3.8) | die uneingeschränkte Lesart ist die **Prämisse**, unter der drei angenommene Entscheidungen ihren Preis gewählt haben: unter einer eingeschränkten wären [ADR-0017](0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) und [ADR-0021](0021-verbrauchs-achse-je-rolle-ohne-quelle.md) Festlegung 5 nicht nötig gewesen. Eine Prämisse dreier angenommener Entscheidungen fällt nicht als Nebenprodukt eines Link-Befundes — und der Lauf, der die Erlaubnis braucht, ist der falsche, sie zu schreiben ([`AGENTS.md`](../../../AGENTS.md) §3.8) |
| F' — `ignore-refs` mit Verzeichnis-Glob `refs: ["docs/plan/carveouts/**"]` | deckte `CO-001` gleich mit | **intensional statt extensional**: autorisierte jeden künftigen Carveout-Verweis derselben Quelldatei im Voraus und legte §3.5 still. Und der Vorteil ist keiner: die Quelldatei ist eingefroren und bekommt keine weiteren Verweise; das Glob kaufte Blindheit ohne Deckung |
| **F — gewählt: zweites Top-Level-`ignore-refs`-Paar, beide Skopen namentlich, plus die Verweis-Form für künftige eingefrorene Artefakte** | kleinstmöglicher Prüfbereichs-Verlust — die geprüfte Datei-Zahl bleibt bei 469, und jedes Link-Vorkommen der Datei außer dem einen ausgenommenen bleibt bewacht; die Restbreite ist strukturell null, weil die Quelldatei eingefroren ist; die Grenze hängt an §3.5 statt an einer Prognose; Festlegung 3 hält die Klasse an, statt sie zu verwalten | es ist die zweite Ausnahme unter demselben Schlüssel und die dritte Gate-Senkung dieser Klasse. Sie behebt nur den eingetretenen Fall; `CO-001` ist geladen und braucht bei seiner Auflösung eine eigene Entscheidung |

## Konsequenzen

- **Positiv:** `make docs-check` wird grün, ohne dass ein eingefrorenes Artefakt angefasst wird und
  ohne dass eine Datei den Prüfbereich verlässt — die geprüfte Datei-Zahl steht vor und nach dem
  Eintrag auf demselben Wert.
- **Positiv:** Die Restbreite dieses Paares ist strukturell null: `in` ist nach §3.4 eingefroren
  und kann keine zweite Referenz bekommen.
- **Positiv:** Festlegung 3 hält die Klasse an. Sie wächst nur noch durch Artefakte, die vor dem
  Einfrieren einen Pfad-Link in das Carveout-Verzeichnis tragen — und genau das ist ab hier
  verboten.
- **Negativ:** Der Bestand ist damit nicht geheilt. `CO-001` trägt zwei Verweise aus einer
  eingefrorenen ADR, und seine Auflösung ist fällig; sie wird einzeln entschieden.
- **Negativ:** [`AGENTS.md`](../../../AGENTS.md) §3.5 hat **keinen Sensor**. Die Schranke gegen ein
  drittes Paar ist prozessual, wie bei jeder anderen Senkung dieses Repos.
- **Negativ:** Festlegung 3 hat heute keinen Sensor; ihr Träger ist ein Übergang, kein Lauf.
- **Folgepflicht 1 (der Lauf, der den Eintrag setzt):** das zweite Paar in
  [`.d-check.yml`](../../../.d-check.yml) anlegen — **samt Config-Kommentar mit Begründung und
  Zeiger auf diese ADR** — und mit zwei `make docs-check`-Läufen belegen, dass die geprüfte
  Datei-Zahl vor und nach dem Eintrag dieselbe ist. `scan.ignore` bleibt unverändert.
- **Folgepflicht 2 (derselbe Lauf):** `make test` fahren und das neue Paar als vom
  Restbreite-Wächter gedeckt zeigen. **Ein neuer Wächter entsteht dafür nicht:**
  `test/ignore-refs-restbreite.bats` liest jedes Paar des Top-Level-Blocks — seine Schleife läuft
  über die vollständige Paar-Liste (`grep -c 'done < <(pairs)' test/ignore-refs-restbreite.bats` →
  1) —, und er sagt das selbst zu: *„jeder kuenftige Eintrag faellt vom ersten Lauf an unter
  dieselbe Messung"*.
- **Folgepflicht 3 (der Slice zu Festlegung 3):** den Träger mechanisieren — eine Prüfung, die rot
  wird, sobald ein Artefakt mit Status `Accepted` einen Pfad-Link in das Carveout-Verzeichnis
  trägt. Der heutige Bestand ist **extensional** zu nennen (fünf Dateien, 33 Vorkommen, Kommandos
  im Kontext) und ausgenommen; die Prüfung greift auf Zuwachs. Ihr Gegenbeispiel ist ein solcher
  Link in einem nicht ausgenommenen `Accepted`-Artefakt, und es muss einmal rot gesehen werden
  ([`AGENTS.md`](../../../AGENTS.md) §3.6). **Ohne ihn bleibt Festlegung 3 eine Zusage ohne
  Wächter**, und diese ADR behauptet ihn nicht als vorhanden.

## Fitness Function (falls maschinell prüfbar)

**Gebaut — und was es nach dieser Senkung noch prüft:**

| Tooling | Regel | Make-Target |
|---|---|---|
| d-check `links` + `anchors` | jeder Markdown-Link aus [ADR-0026](0026-eingefrorene-referenz-referenz-weit-ausgenommen.md) **außer** dem einen ausgenommenen Ziel löst auf, Ziel und Anker; jeder Link **auf** die Datei bleibt vollständig bewacht | `make docs-check` |
| bats, `test/ignore-refs-restbreite.bats` | **jedes** Paar des Top-Level-`ignore-refs`-Blocks deckt höchstens einen auflösenden Markdown-Link seiner Quelldatei; eine unbekannte Zeilenform im Block färbt rot statt still zu bleiben | `make test` (in `make gates`) |

**Nicht gebaut, und hier ehrlich zu benennen:** Festlegung 3 hat keinen Sensor — sie ist eine
Form-Aussage über den Accept-Übergang, und kein Modul des Doku-Gates liest Status und Link-Form
zusammen. Sie ist **mechanisierbar** (Folgepflicht 3), heute aber vom Rollen-Wechsel getragen und
nicht von einem Lauf. Ebenso ohne Sensor ist die Aufnahme-Grenze aus Festlegung 2: dass ein drittes
Paar eine neue ADR verlangt, ist eine Hard-Rule-Aussage
([`AGENTS.md`](../../../AGENTS.md) §3.5) und wird von keinem Lauf geprüft.

## Re-Evaluierungs-Trigger

- **Wenn `CO-001` aufgelöst wird** *(an seinem Ort ablesbar; `make docs-check` färbt rot)*: dann
  brechen zwei Verweise aus [ADR-0021](0021-verbrauchs-achse-je-rolle-ohne-quelle.md). Zu
  entscheiden ist dann zwischen einem dritten Paar und dem Ziel-Ende — in einer eigenen ADR, nicht
  hier. Diese Entscheidung deckt ihn **nicht**.
- **Wenn `ids.patterns` das Präfix `CO-` aufnimmt** *(an [`.d-check.yml`](../../../.d-check.yml)
  ablesbar)*: dann wird die bare Kennung linkpflichtig und kollidiert mit Festlegung 3. Zu
  entscheiden ist, welche der beiden weicht.
- **Wenn die adoptierte Baseline den `done/`-Move bei Auflösung nicht mehr verlangt** *(am
  Regelwerk der Baseline ablesbar)*: dann fällt der strukturelle Auslöser, und Festlegung 3 wird
  gegenstandslos.
- **Wenn [`AGENTS.md`](../../../AGENTS.md) §3.4 eingeschränkt würde** *(am Text ablesbar)*: dann
  fällt die Voraussetzung von Festlegung 1, der Befund wäre im Artefakt behebbar, und der Eintrag
  aus Festlegung 2 ist **zurückzunehmen**, nicht stillschweigend mitzuführen.
- **Wenn der gepinnte d-check das geteilte `ignore-refs` verlöre** *(feedforward — eine
  Werkzeug-Version, kein Sensor; sichtbar wird sie, wer den CHANGELOG des neuen Pins gegen den
  alten liest)*: dann fällt die Voraussetzung von Festlegung 2, und der Befund kehrt zurück.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-08-30 | **Proposed** | Architect-Entscheid zum letzten roten Befund des Doku-Gates. Vier Läufe am gepinnten Stand tragen ihn: das geschnittene Referenz-Ventil, seine zwei roten Gegenproben und die Gegenmessung auf der Datei-Achse |
| 2026-08-30 | **Accepted** | Angenommen vom Auftraggeber. Festlegung 3 regiert diese Zeile selbst: `CO-005` steht bei der Kennung, ohne Pfad-Link — die Form, deren Fehlen den Befund erzeugt hat, den Festlegung 1 stehen lässt |
