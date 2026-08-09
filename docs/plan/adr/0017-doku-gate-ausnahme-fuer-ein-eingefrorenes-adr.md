# ADR-0017: Der Doku-Gate lässt ein eingefrorenes ADR aus — namentlich, nicht als Klasse

**Status:** Accepted

**Datum:** 2026-08-09

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (ein Gate,
der dauerhaft rot steht, ist so wenig wert wie einer, den es nicht gibt),
[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (der Tausch des
`<tag>`-gescopten Baums ist der Auslöser),
[ADR-0016](0016-verweis-traegt-tag-und-zitat.md) (die Voraussetzung: der Bestand wird nicht
geheilt), [ADR-0013](0013-technik-stratum-als-zielort.md) (die betroffene Datei)

**Schärft:** — Prozess-ADR ohne Spec-Stratum: sie senkt einen Gate-Prüfumfang, sie ändert keine
Spec-Aussage.

**Kopplung — sie gehört in beide Richtungen genannt.** Diese Senkung existiert **nur, weil**
[ADR-0016](0016-verweis-traegt-tag-und-zitat.md) Festlegung 1 die Aussagen des Bestands nicht
heilt; ohne jene Entscheidung gäbe es hier nichts zu senken. Umgekehrt ist jene Entscheidung nur
bezahlbar, weil diese den Gate grün hält. **Ohne die andere ist diese ADR nicht vollständig
lesbar:** *warum* ein §3.4-immutabler Verweis nicht einfach nachgezogen oder superseded wird,
steht dort und wird hier nicht wiederholt. Fällt [ADR-0016](0016-verweis-traegt-tag-und-zitat.md),
fällt die Voraussetzung dieser ADR mit.

**Trennungsgrund:** [`AGENTS.md`](../../../AGENTS.md) §3.5 verlangt für eine Schwellen-Senkung
ein ADR als Gefäß. Eine Senkung hat einen eigenen Preis, eine eigene Grenze und einen eigenen
Re-Evaluierungs-Trigger; sie mit einer Doku-Regel zu bündeln zwingt eine Unterschrift auf zwei
verschiedene Arten von Entscheidung.

---

## Kontext

Die vendored Baseline liegt `<tag>`-gescopt und trägt einen Tag zur Zeit
([`MR-007`](../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)).
Beim Bump verschwindet das alte Verzeichnis, und jeder Markdown-Link mit dem alten Tag im Pfad
meldet `target-missing`.

**Gemessen, nicht hochgerechnet.** `.harness/baseline/v3.5.2` nach `v5.3.0` umbenannt,
`make docs-check`, zurückbenannt (danach `baseline-verify: v3.5.2 OK — 42 Dateien`, Arbeitsbaum
sauber):

```
d-check: 309 Datei(en) geprüft, 21 Befund(e)     # alle target-missing
```

Tragend ist die **Befund**-Zahl und ihre Verteilung; die geprüfte Datei-Zahl ist der
Markdown-Bestand des Repos zum Lauf-Zeitpunkt und wächst mit ihm.

Davon liegt **genau einer** in einer Datei, die [`AGENTS.md`](../../../AGENTS.md) §3.4
eingefroren hat: [ADR-0013](0013-technik-stratum-als-zielort.md). 16 liegen in lebenden
Artefakten und werden nachgezogen, 4 in Zeitdokumenten.

**Das ist ein Befund, den niemand beheben darf.** Die einzige Reparatur *in* der Datei wäre eine
Textänderung — §3.4 verbietet sie. Ein Gate, dessen Befund unbehebbar ist, färbt `make gates`
dauerhaft rot und erzieht dazu, Rot zu übersehen; das ist
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) eine
Ebene tiefer.

**Der präzise Knopf fehlt — gemessen am Werkzeug** (`d-check --print-config`, gepinnter Digest):

| Modul | referenz-weit | datei-weit |
|---|---|---|
| `codepaths` | `ignore-refs` | `exempt-paths` |
| `ids` | — | `exempt-paths` |
| `matrix` | — | `exempt-paths` |
| **`links`** | **keines** | **keines** |
| **`anchors`** | **keines** | **keines** |

`links` und `anchors` tragen überhaupt keine Options-Sektion. Der Knopf, den dieses Repo
bräuchte, hieße `links.ignore-refs` (referenz-weit, im Muster von
[`MR-008`](../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert));
solange es ihn nicht gibt, bleibt nur `scan.ignore` — und das wirkt **datei-weit über alle
Module**.

## Entscheidung

**Wir wählen Option D: `.d-check.yml` nimmt unter `scan.ignore` genau eine namentlich genannte
Datei auf** —

- `docs/plan/adr/0013-technik-stratum-als-zielort.md`

**und keine weitere.**

Das ist eine Aufnahme-**Grenze**, keine Aufnahme-**Regel**: **jeder zusätzliche Eintrag ist eine
neue Senkung und löst [`AGENTS.md`](../../../AGENTS.md) §3.5 erneut aus — auch dann, wenn er
dieselbe Bedingung erfüllt wie dieser.** Ein zweites eingefrorenes ADR mit gebrochenem
Baseline-Link ist durch diese ADR **nicht** gedeckt und braucht eine eigene Entscheidung.

Der Unterschied ist der zwischen einer Schranke und einer Beobachtung. Eine intensional
formulierte Regel (*„alle Dateien, die Bedingung X erfüllen"*) autorisierte den zweiten Eintrag
im Voraus und legte §3.5 still; die extensionale Liste tut das nicht. Der Boden hängt damit nicht
an einer Prognose über die Wirksamkeit einer Doku-Regel, sondern an einer Hard Rule, die bei
jedem Zuwachs erneut greift.

**Der Eintrag trägt im Config-Kommentar seine Begründung und einen Zeiger auf diese ADR** — wie
die vier bestehenden Einträge auch, von denen jeder seine Begründung im Kommentar führt.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — rot lassen und aussprechen | keine Senkung, keine Config-Änderung, maximale Ehrlichkeit | `make gates` wäre nach dem Tausch dauerhaft rot, ohne dass jemand es beheben darf. Ein Dauer-Rot ist kein Sensor mehr: es trainiert, Rot zu überlesen, und entwertet damit **alle** übrigen Befunde desselben Laufs |
| B — Ausnahme für **alle** Ziele unter `.harness/baseline/` | eine Zeile Config, deckt jeden künftigen Fall im Voraus | nimmt die **16** gate-sichtbaren Links in `spec/spezifikation.md` (12) und `harness/conventions.md` (4) mit aus der Prüfung — genau den einzigen Sensor, der den Bump zwingt, sie nachzuziehen. Geltungsbereich um Faktor 16 größer als der Anlass, und er wächst mit jedem neuen Baseline-Verweis weiter: **kein Boden**. Widerspricht zudem der Ziel-Fassung `v5.3.1`, deren Freshness-Audit (`modul-02-harness-bootstrap.md`, im Delta `v5.3.0` → `v5.3.1` byte-gleich) den Formcheck ausdrücklich dem Doku-Gate zuweist (*„ihre Dateien sind gültige Link-Ziele"*) |
| C — die drei betroffenen Zeitdokumente mit aufnehmen | löste die vier übrigen Befunde derselben Klasse gleich mit | gemessen **siebenmal teurer**: die drei Dateien führen zusammen **185** Link-Vorkommen (120 · 48 · 17, `grep -oE '\]\([^)]+\)' \| wc -l`) gegenüber 27 der einen Datei — dauerhaft und über alle fünf Module. Vor allem machte es die Liste zu einer, die bei **jedem** Bump um jeden neuen Report wächst. Die Zeitdokumente brauchen die Senkung auch nicht: sie sind nicht von §3.4 geschützt, ihre Adresse ist auflösbar, ohne dass eine Aussage sich ändert ([ADR-0016](0016-verweis-traegt-tag-und-zitat.md) Festlegung 4) |
| **D — gewählt: eine namentlich genannte Datei, extensional geschlossen** | kleinstmöglicher Prüfbereichs-Verlust für das Problem; die Grenze hängt an §3.5 statt an einer Prognose; der Preis ist über alle Module beziffert und die Gegen-Messung entlastet ihn quellenseitig | die Datei verlässt den Gate **ganz**, nicht nur für ihren Baseline-Link — fünf Module statt einem, weil der präzise Knopf fehlt; und §3.5 selbst hat keinen Sensor |

## Konsequenzen

**Der Preis, gemessen über alle Module — nicht nur über `links`.** `scan.ignore` liest die Datei
**nicht mehr**; die geprüfte Datei-Zahl fällt um **genau eins**. Tragend ist dieser Delta, nicht
ein Absolutwert-Paar — der Nenner ist der Markdown-Bestand des Repos, der Delta ist die Wirkung
des Eintrags. Betroffen sind fünf aktive Module:

| Modul | was die Datei verliert | gemessen mit |
|---|---|---|
| `links` / `anchors` | 27 Link-Vorkommen über 12 Ziele, 5 anker-tragend (4 davon repo-intern) | `grep -oE '\]\([^)]+\)'` |
| `ids` | 18 Kennungs-Nennungen (8 eindeutig) unter der Linkpflicht | `grep -oE` über die drei Kennungs-Muster |
| `codepaths` (samt `check-lines`) | 4 eindeutige Inline-Code-Pfade | `grep -oE` über die Inline-Code-Pfade |
| `matrix` | die Datei als **Quelle**, inklusive des Verbots, auf superseded ADRs zu zeigen | — |

Die Kommandos ausgeschrieben — eine Tabellenzelle trägt das Pipe-Zeichen nicht; jede Zeile nennt,
was **sie** ausgibt:

```sh
F=docs/plan/adr/0013-technik-stratum-als-zielort.md
grep -oE '\]\([^)]+\)' "$F" | wc -l                                       # 27  Link-Vorkommen
grep -oE '\]\([^)]+\)' "$F" | sort -u | wc -l                             # 12  eindeutige Ziele
grep -oE '\]\([^)]+\)' "$F" | sort -u | grep -c '#'                       #  5  davon anker-tragend
grep -oE 'ADR-[0-9]{4}|LH-[A-Z]{2}-[0-9]{2}|MR-[0-9]{3}' "$F" | wc -l      # 18  Kennungs-Nennungen
grep -oE 'ADR-[0-9]{4}|LH-[A-Z]{2}-[0-9]{2}|MR-[0-9]{3}' "$F" | sort -u | wc -l   #  8  eindeutig
grep -oE '`(\.{1,2}/|spec/|docs/|harness/)[^`]*`' "$F" | sort -u | wc -l   #  4  Inline-Code-Pfade
```

**Entlastend, ebenfalls gemessen:** `scan.ignore` wirkt **quellenseitig**. Eingehende Links,
eingehende Anker und `matrix.status` über eingehende Verweise auf die ausgenommene Datei bleiben
vollständig bewacht — dieselbe Sonde, die das für den vendored Baum zeigt (Link auf den gepinnten
Tag: kein Befund; erfundener Anker: `anchor-missing`), zeigt es hier. Der Preis wächst also
**nicht** mit den **22** Verweis-Vorkommen aus **11** lebenden Dateien, die *auf*
[ADR-0013](0013-technik-stratum-als-zielort.md) zeigen, sondern bleibt auf ihre 27 ausgehenden
begrenzt. Die eingehende Seite, ebenfalls mit ihrem Kommando — und sie wächst mit jedem neuen
Verweis, während die 27 an einer §3.4-immutablen Datei feststehen:

```sh
P=(':!.harness/baseline' ':!docs/reviews' ':!docs/plan/planning/done')
git grep -oE '\]\([^)]*0013-technik-stratum-als-zielort\.md[^)]*\)' -- "${P[@]}" | wc -l   # 22
git grep -lE '\]\([^)]*0013-technik-stratum-als-zielort\.md[^)]*\)' -- "${P[@]}" | wc -l   # 11
```

- **Positiv:** `make gates` bleibt nach dem Tausch grün, ohne dass ein eingefrorenes Artefakt
  angefasst wird.
- **Positiv:** Die Liste kann nicht stillschweigend wachsen; jeder Zuwachs ist ein sichtbarer
  §3.5-Vorgang.
- **Negativ:** Eine Datei verliert ihren Wächter in **fünf** Modulen, obwohl nur ein Link das
  Problem ist. Diese Grobheit ist erzwungen, nicht gewählt — der referenz-weite Knopf existiert
  nicht.
- **Negativ:** §3.5 selbst hat **keinen Sensor** (siehe Fitness Function). Die Schranke ist
  prozessual.
- **Folgepflicht 1 (der Slice, der den Baum tauscht):** den `scan.ignore`-Eintrag setzen —
  **samt Config-Kommentar und Zeiger auf diese ADR**.
- **Folgepflicht 2 (derselbe Slice):**
  [`MR-001`](../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
  nachführen. Er ist der einzige Ort im Repo, der die `scan.ignore`-Einträge **zählt und
  klassifiziert** — heute vier, alle als *Scoping, keine Gate-Lockerung nach §3.5*. Dieser
  Eintrag ist der erste, für den beides nicht mehr stimmt: er nimmt Bestand aus, den dieses Repo
  autoritativ schreibt. Nachzuführen sind **Zahl, Klassifikation und die Grenze aus der
  Entscheidung oben** — dort liest sie, wer den nächsten Eintrag anlegen will.
  **Diese ADR ändert keine Datei.**

## Fitness Function (falls maschinell prüfbar)

**Gebaut — und was es nach dieser Senkung noch prüft:**

| Tooling | Regel | Make-Target |
|---|---|---|
| d-check `links` + `anchors` | jeder Markdown-Link **außer** denen der einen ausgenommenen Datei löst auf, Ziel und Anker — auch in den vendored Baum hinein | `make docs-check` |
| d-check `links` / `matrix` | Verweise **auf** die ausgenommene Datei bleiben vollständig bewacht (quellenseitige Wirkung, oben gemessen) | `make docs-check` |

**Nicht gebaut, und hier ehrlich zu benennen: die Grenze dieser Entscheidung hat keinen Sensor.**
Dass ein zweiter `scan.ignore`-Eintrag eine neue ADR verlangt, ist eine Hard-Rule-Aussage
([`AGENTS.md`](../../../AGENTS.md) §3.5) und wird von keinem Lauf geprüft — dieselbe Trägerschaft
wie bei jeder anderen Senkung dieses Repos, aber eben keine gemessene. **Mechanisierbar wäre
sie:** ein Sensor, der die `scan.ignore`-Liste gegen die in ADRs autorisierten Einträge hält und
bei jedem nicht autorisierten Eintrag rot färbt; sein Gegenbeispiel wäre ein fünfter Eintrag ohne
ADR-Zeiger im Kommentar. **Diese ADR baut ihn nicht**, und sie behauptet ihn nicht
([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).

## Re-Evaluierungs-Trigger

- **Wenn ein zweiter Eintrag beantragt wird** *(am Vorgang ablesbar; §3.5 greift von selbst)*:
  dann ist zu entscheiden, ob die Verweis-Regel aus
  [ADR-0016](0016-verweis-traegt-tag-und-zitat.md) nicht getragen hat oder ob der Fall neu ist.
  Die Entscheidung fällt in einer eigenen ADR, nicht hier.
- **Wenn `links` einen referenz-weiten Ausschluss bekommt** *(feedforward — eine Tool-Version,
  kein Sensor)*: dann ist der datei-weite Eintrag durch den präzisen zu ersetzen, und der Preis
  über fünf Module entfällt. Das ist der Zustand, den diese ADR eigentlich will.
- **Wenn [ADR-0016](0016-verweis-traegt-tag-und-zitat.md) nicht angenommen wird** *(am Status
  ablesbar)*: dann fällt die Voraussetzung — wird der Bestand doch geheilt oder superseded, gibt
  es keinen unbehebbaren Befund und keinen Grund für diese Senkung.
- **Wenn die ausgenommene Datei einen zweiten Defekt bekäme, den ein anderes Modul sähe**
  *(nicht beobachtbar — genau das ist der Punkt)*: sie ist §3.4-immutabel, kann also keinen neuen
  Defekt erwerben. Tritt es doch ein, war die Immutabilität nicht durchgesetzt, und das ist die
  größere Frage.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-08-09 | **Proposed** | Architect-Entscheid zur Gate-Lage der Re-Baseline `v3.5.2` → `v5.3.0`. Auslöser: der gefahrene Tausch meldet 21 `target-missing`, davon genau einen in einem nach §3.4 eingefrorenen Artefakt — ein Befund, den keine Regel des Repos beheben darf |
| 2026-08-09 | Überarbeitet, weiter **Proposed** | Ziel-Stand `v5.3.1`. Gezogen ist genau ein vorwärts gerichteter Zeiger (die Ziel-Fassung in Option B); die Freshness-Audit-Aussage trägt, weil `modul-02-harness-bootstrap.md` im Delta byte-gleich ist. Die Sonden-Beschreibung nennt weiter `v5.3.0`, weil das der Name ist, unter dem der Lauf stattfand |
| 2026-08-09 | **Accepted** | Annahme durch den Auftraggeber nach der Bestätigungsrunde `docs/reviews/2026-08-09-adr-0015-0016-0017-bestaetigungsrunde.md` (extensionale Schließung bestätigt, kein blockierender Befund); ab hier immutabel ([`AGENTS.md`](../../../AGENTS.md) §3.4) — spätere Schärfungen als neue ADR mit *Supersedes*. Voraussetzung erfüllt: [ADR-0016](0016-verweis-traegt-tag-und-zitat.md) ist mit derselben Runde angenommen. Vor dem Wechsel gezogen: die **zwei unvereinbaren Datei-Zahlen** — der Nenner eines `d-check`-Laufs ist der Markdown-Bestand des Repos und altert, tragend sind die Befund-Zahl und der Delta *um genau eins*; beide selbst nachgefahren (Tausch: 311 Dateien, 21 Befunde; Eintrag: 311 → 310). Dazu stehen die Preis-Kommandos ausgeschrieben, weil eine Tabellenzelle das Pipe-Zeichen nicht trägt und die gedruckte Form wörtlich kopiert **0** lieferte, und die eingehende Seite trägt ihre gemessene Zahl (**22** aus **11** statt 16 aus 10) |
