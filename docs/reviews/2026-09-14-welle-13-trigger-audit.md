# Trigger-Audit welle-13, Schritt 2 (ADR- und Reifestufen-Zweig) — ein ausgeführter Trigger ohne Ausgang, und der übergebene Fall ist keiner

**Rolle:** Architect (Baseline-Regelwerk `v6.8.0`, `modul-08-agentenrollen.md` §Rollen-Sequenz für
eine Welle — *„Nur 1, 2 und 3b tragen einen Rollenwechsel"*; Schritt 2 führt `Planner → Architect →
Planner`) · **Datum:** 2026-09-14 · **Geprüfter Stand:** `0fa065f9` (`main`, Arbeitsbaum sauber,
`git status --porcelain` leer) · **Gegenstand:** die drei Artefaktklassen des Trigger-Audits —
Carveout, bootstrap-aware Gate, ADR (Baseline-Regelwerk `v6.8.0`, `modul-06-roadmap.md`
§Wellen-Closure-Prozedur Schritt 2) · **Auftrag:** den **ADR- und Reifestufen-Zweig** verdikten.

**Nicht mein Gegenstand:** die Schritte 3 bis 6 der Closure (Lese-Schritt, Results-Notiz, `git mv`,
Archivierung, Roadmap) — Planner-Kontext; und die **Bestätigung** der zwei offenen Carveouts, die der
Planner aus dem Bestand führt. Die Carveouts sind hier nur auf einen **Widerspruch** beim Lesen
geprüft.

**Was dieser Lauf geschrieben hat.** Diese Datei, die Folge-ADR
[`ADR-0050`](../plan/adr/0050-geteiltes-ventil-ersetzt-die-datei-weite-ausnahme.md) und ihre Zeile
im [ADR-Index](../plan/adr/README.md). Kein Produkt-Code, keine Plan-Datei, keine Norm-Datei,
**keine `Accepted`-ADR** — die zwei Sonden an
[`.d-check.yml`](../../.d-check.yml) sind zurückgesetzt, der Arbeitsbaum ist am Ende der Läufe leer.

---

## Ergebnis in einer Tabelle

| Artefaktklasse | geprüft | Ausgang |
|---|---|---|
| **Carveout** (Modul 7) — nicht mein Zweig | zwei aktive Dateien; auf Widerspruch gelesen | **kein Widerspruch** — beide tragen ihren Stand; eine Zahlendrift in `CO-001` ist benannt (§1) |
| **Bootstrap-aware Gate** (Modul 13) — mein Zweig | `Makefile`, `d-check.mk`, `harness/README.md`, `harness/conventions.md` | **keines vorhanden** — Feststellung, kein Auslassen (§2) |
| **ADR** (Modul 4) — mein Zweig | **188** Re-Evaluierungs-Trigger über **49** ADR-Dateien; die **43** `Accepted` vollständig, die `Proposed`/`Superseded` als Kontext | **ein ausgeführter Trigger ohne Ausgang** → Folge-ADR `ADR-0050` (`Proposed`); der namentlich übergebene Fall ist **nicht** ausgelöst (§3, §4) |

```sh
awk '/^## Re-Evaluierungs-Trigger/{p=1} p&&/^## /&&!/Re-Evaluierungs-Trigger/{p=0}
     p&&/^- \*\*|^[0-9]+\. \*\*/' docs/plan/adr/[0-9]*.md | wc -l   # Träger-Zeilen der Trigger
ls docs/plan/adr/[0-9]*.md | wc -l                                   # 49
grep -l '^\*\*Status:\*\* Accepted' docs/plan/adr/[0-9]*.md | wc -l   # 43
grep -l '^\*\*Status:\*\* Proposed' docs/plan/adr/[0-9]*.md | wc -l   #  4
grep -l '^\*\*Status:\*\* Superseded' docs/plan/adr/[0-9]*.md | wc -l #  2
```

Die erste Zeile zählt **188** Träger-Zeilen über alle **49** Dateien; **keine Erwartungswerte**
([`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). Sie sind hier **nicht** als Dateien-Zahl der Trigger gemeint: die zweite Spalte der
`Proposed`-Dateien trägt teils nummerierte statt `- **`-Zeilen, und dieser Lauf zählt die
Aufzählung, nicht die Semantik.

## 1. Carveouts — nicht mein Zweig, und ohne Widerspruch

Zwei aktive Dateien (`ls docs/plan/carveouts/*.md | wc -l` → **2**).

[`CO-001`](../plan/carveouts/CO-001-bats-shell-lint.md) (Gate `shell-lint`): Stand *verlängert mit
Folge-Slice* — [slice-141](../plan/planning/next/slice-141-co-001-aufloesung-ist-vorher-entschieden.md)
entscheidet vor, [slice-113](../plan/planning/open/slice-113-co-001-ist-faellig.md) führt aus; beide
liegen im Lifecycle. Der Auflösungs-Trigger ist weiterhin eingetreten und der Ausgang ist gesetzt —
**kein Widerspruch**, der eine Architect-Frage wäre.
[`CO-002`](../plan/carveouts/CO-002-token-achse-je-rolle.md) (*permanent*, in
[ADR-0021](../plan/adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md) übergeführt): bestätigt; es
gibt keine Schwelle mehr, die wieder eintreten könnte.

**Ein Befund beim Lesen, und er gehört dem Planner.** `CO-001` führt drei verschiedene Zahlen für
denselben Gegenstand: das Feld *Geltungsbereich* sagt **16**, seine *Letzte Prüfung* vom 2026-09-01
sagt **20**, und derselbe Bestand liefert heute **30**
(`git ls-files 'test/*.bats' | wc -l`). Kein Widerspruch gegen den **Ausgang** — der Trigger fragt
über den Bestand, und der ist gewachsen —, aber ein Zahl-Feld, das seine Fundmenge nicht mehr nennt.

## 2. Bootstrap-aware Gates — keines vorhanden

Das ist die Feststellung, nicht ihr Fehlen. Ein bootstrap-aware Gate dokumentiert seine **Stufe** und
seinen **Hochschalt-Trigger** im Make-Target (Baseline-Regelwerk `v6.8.0`,
`modul-13-quality-gates.md` §Bootstrap-aware Gates: *„Ein bootstrap-aware Gate dokumentiert seine
Stufe und seinen Hochschalt-Trigger im Make-Target"*).

```sh
grep -rc 'bootstrap-aware' Makefile d-check.mk harness/README.md harness/conventions.md
# Makefile:0  d-check.mk:0  harness/README.md:0  harness/conventions.md:0
grep -nE 'Stufe|Hochschalt' Makefile
# 50,51  die zwei Stufen von `make mutate` (Go-Stufe / bats-Stufe)
# 172    die Range-Stufen von `make adr-immutable`
# 306    die Bild-Stufe des Trägers
```

Vier Treffer für das Wort *Stufe*, und **keiner** davon ist eine Reifestufe eines Gates: die
`mutate`-Stufen sind zwei Prüf-Verfahren, die `adr-immutable`-Stufe ist eine Range-Form, die
Bild-Stufe ist eine Bau-Phase. Damit gibt es in diesem Repo **nichts hochzuschalten** — dieselbe
Feststellung, die der Trigger-Audit von `welle-10` für sich getroffen hat, hier gegen den heutigen
Stand neu gefahren.

## 3. ADR-Zweig — was der Durchgang gefunden hat

**Methode.** Je `Accepted`-ADR ist ihr Re-Evaluierungs-Trigger-Abschnitt gelesen und **gegen einen
Zustand dieses Repos** gehalten. Die Trigger fallen in zwei Klassen, und nur die erste ist hier
entscheidbar: solche mit einer **an diesem Baum ablesbaren Bedingung** (ein Verzeichnis, eine Zahl,
ein Gate-Lauf, ein Konfigurationswert) und solche, die an einem **fremden Vertrag** hängen (die
Hook-Oberfläche des Agenten-Werkzeugs, der Inhalt eines künftigen Baseline-Stands) oder an einem
**künftigen Vorgang** (der nächste Sprung, der nächste Accept-Übergang). Die zweite Klasse ist je
einzeln als solche klassifiziert, nicht ausgelassen (§6 nennt die Grenze).

### Der ausgeführte Trigger ohne Ausgang: ADR-0017 Trigger 2

**Gefunden.** [ADR-0017](../plan/adr/0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) nimmt
unter `scan.ignore` **eine** Datei aus —
`docs/plan/adr/0013-technik-stratum-als-zielort.md` — und begründet den Preis über fünf Module mit
einer Werkzeug-Lage: *„der referenz-weite Knopf existiert nicht"* (§Konsequenzen; §Kontext führt die
Tabelle, aus der die Folgerung stammt). Ihr Re-Evaluierungs-Trigger 2 nennt die Bedingung, unter der
die Ausnahme weichen soll: *„Wenn `links` einen referenz-weiten Ausschluss bekommt … dann ist der
datei-weite Eintrag durch den präzisen zu ersetzen."*

**Die Bedingung ist erfüllt — und sie war es schon, als die ADR geschrieben wurde.** Der gepinnte
d-check führt `ignore-refs` als Top-Level-Schlüssel, den `links`, `anchors` und `codepaths`
gemeinsam honorieren; [ADR-0026](../plan/adr/0026-eingefrorene-referenz-referenz-weit-ausgenommen.md)
hat ihn an einer roten Gegenprobe gemessen, [`MR-034`](../../harness/conventions.md#mr-034--das-geteilte-referenz-ventil-trägt-am-gepinnten-stand)
hält es als Werkzeug-Aussage fest:

```sh
grep -n '^  - in:' .d-check.yml          # sieben Paare, keines auf die ADR-0013
grep -c '^  - in:' .d-check.yml          # 7
grep -n '0013-technik-stratum' .d-check.yml
# 17,28   der Kommentar und der `scan.ignore`-Eintrag — ein Paar fehlt
```

**Die Gegenprobe, über den unveränderten Baum gefahren** (gepinnter Digest aus
[`d-check.mk`](../../d-check.mk), netzlos, Mount `:ro`; die Config je Lauf geändert und danach
zurückgesetzt):

| Lauf | `scan.ignore` | `ignore-refs` | Ergebnis |
|---|---|---|---|
| Bestand | trägt die ADR-0013 | unverändert | `1367 Datei(en) geprüft, 0 Befund(e)` |
| Datei-Achse geöffnet | trägt sie **nicht** | unverändert | `1368 Datei(en) geprüft, 1 Befund(e)` — `0013-technik-stratum-als-zielort.md:48 … target-missing` |
| Sonde | trägt sie **nicht** | Paar `in: …/0013-technik-stratum-als-zielort.md`, `refs: [".harness/baseline/v3.5.2/regelwerk/grundlagen-konventionen.md"]` | `1368 Datei(en) geprüft, 0 Befund(e)` |
| Quell-Skopus verstellt | trägt sie **nicht** | dasselbe `refs`, `in: "AGENTS.md"` | `1368 Datei(en) geprüft, 1 Befund(e)` |

`1367` gegen `1368` ist die tragende Differenz: Die Datei **kehrt in den Prüfbereich zurück**, den
die Ausnahme für ihren einen toten Link geräumt hatte. Die zwei `1 Befund(e)`-Zeilen sind der
Rot-Beleg in beide Richtungen — ohne Paar kommt der Befund, mit falschem `in` kommt er wieder
([`AGENTS.md`](../../AGENTS.md) §3.6).

**Warum daraus eine Folge-ADR und nicht ein Slice.** Der `scan.ignore`-Eintrag steht **wörtlich** in
§Entscheidung einer `Accepted`-ADR; ihn zurückzuziehen bewegt einen eingefrorenen Wert
([`AGENTS.md`](../../AGENTS.md) §3.4). Der Präzedenzfall steht in
[ADR-0032](../plan/adr/0032-eingefrorene-referenz-folgt-ihrem-rumpf.md) — dieselbe Bewegung an
einem `in:`-Wert, dieselbe Form (Teil-`Supersedes`). Und
[ADR-0026](../plan/adr/0026-eingefrorene-referenz-referenz-weit-ausgenommen.md) §Abgrenzung hat den
Vorgang ausdrücklich dorthin verwiesen: *„was daraus für jene Entscheidung folgt, gehört in eine
eigene."*

**Ausgang: Folge-ADR mit `Supersedes (Teil)`** —
[`ADR-0050`](../plan/adr/0050-geteiltes-ventil-ersetzt-die-datei-weite-ausnahme.md), Status
`Proposed`, Zeile im [ADR-Index](../plan/adr/README.md). Sie ändert keine Datei; der Eintrag und das
Paar sind Implementer-Arbeit, und die Zusage lautet **Gate-Anheben** — §3.5 wird nicht ausgelöst.

### Was sonst ausgeführt ist und schon einen Ausgang trägt

- **[ADR-0026](../plan/adr/0026-eingefrorene-referenz-referenz-weit-ausgenommen.md) Trigger 1**
  („der Adaptions-Block wandert in die Verzeichnis-Form"): seit `MR-045` in Kraft und **bereits
  ausgegeben** — [ADR-0032](../plan/adr/0032-eingefrorene-referenz-folgt-ihrem-rumpf.md) zieht den
  `in:`-Wert nach und trägt dafür ein Teil-`Supersedes`. Kein neuer Vorgang.
- **[ADR-0014](../plan/adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md) Trigger 2** („der
  Adaptions-Block bekommt einen Index"): in Kraft — am ADR-Datum trug der Block `### MR-NNN`-Rümpfe
  und **keine** Index-Tabelle
  (`git show $(git log --before=2026-08-02 --format=%H -1 -- harness/conventions.md):harness/conventions.md | grep -c '^| MR-'`
  → **0**), seit `MR-045` trägt er sie. Die Folge („der Kopf ist gegen den Index zu prüfen, nicht zu
  verdoppeln") ist durch dieselbe Setzung und
  [ADR-0024](../plan/adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md) getragen:
  die Index-Tabellen sind **derivativ**, bei Abweichung gilt die Datei. **Ausgang: bestätigt.**
- **[ADR-0015](../plan/adr/0015-rollen-eigentum-an-norm-artefakten.md) Trigger 4** („ein
  Commit-Sensor wird gebaut"): der Sensor **ist** gebaut — `make commit-msg-check` samt PreToolUse-
  Hook ([slice-126](../plan/planning/done/slice-126-commit-message-traegt-eine-kennung.md)), dazu
  das Modul `commits`. Die Cutoff-Begründung der ADR ruht aber nicht auf einem messbaren Bestand
  ihrer eigenen Regel: `commit-msg-check` prüft die **Anwesenheit einer Kennung** in der Message,
  nicht den **Commit-Zuschnitt** nach Rollen-Eigentum. Kein Sensor dieses Repos liest den
  letzteren. **Ausgang: bestätigt** — die Begründung trägt fort.

### Was nicht ausgeführt ist (gemessen, nicht angenommen)

| Trigger | Bedingung | Messung | Ausgang |
|---|---|---|---|
| [ADR-0030](../plan/adr/0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) 1 | `welle-09` schließt | `ls docs/plan/planning/welle-09-*.md` → die Datei liegt **flach**; sie steht unter *Offene Wellen* der [Roadmap](../plan/planning/in-progress/roadmap.md) und ruht (*„welle-09 bleibt offen und ruhend"*, Drift-Log) | nicht ausgeführt |
| [ADR-0032](../plan/adr/0032-eingefrorene-referenz-folgt-ihrem-rumpf.md) 1 | `MR-021` löst sich auf und wandert nach `conventions/done/` | `ls harness/conventions/done/` → vier Dateien, `MR-021` ist **nicht** darunter; sein Auflösungs-Trigger ist `permanent` | nicht ausgeführt |
| [ADR-0041](../plan/adr/0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md) 5 | das Sammel-Archiv aus Festlegung 2 liegt | `ls docs/plan/planning/done/ \| grep -iE 'sammel\|archiv'` → kein Treffer; kein `.zip` flach in `done/` | nicht ausgeführt |
| [ADR-0046](../plan/adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) 1 | `waves` deaktiviert, `mode: one` oder im Umfang gesenkt | `.d-check.yml`: `waves: {dir: docs/plan/planning, mode: many}` — unverändert | nicht ausgeführt |
| [ADR-0040](../plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) 4 | das Modul `reviews` wird aktiviert | `grep -m1 '^modules:' .d-check.yml` → acht Module, `reviews` ist **nicht** dabei | nicht ausgeführt |
| [ADR-0006](../plan/adr/0006-durchsetzung-commands-tool-als-quelle.md) 1 | der Kurs nimmt Command-Templates upstream auf | `ls .harness/baseline/v6.8.0/templates/` → kein Command-/Skill-Zweig unter `templates/`; `find … -iname '*command*'` → leer | nicht ausgeführt |
| [ADR-0038](../plan/adr/0038-ziel-fassung-regiert-den-sprung-v650.md) 3 | der Baum wird vor dem Schnitt des Durchgangs getauscht | `ls -1 .harness/baseline/` → **ein** Tag (`v6.8.0`); die Zwei-Fassungen-Phase ist beendet, und der Trigger selbst nennt seinen Ausgang *„am Ergebnis ändert das nichts, an der Begründungslast eines künftigen Sprungs schon"* | ausgeführt, ohne Handlung — bestätigt |

**Zu [ADR-0038](../plan/adr/0038-ziel-fassung-regiert-den-sprung-v650.md) Trigger 3, und warum er
kein zweiter Befund ist.** Er ist die einzige Zeile dieser Tabelle, deren Bedingung **wahr** ist.
Sein eigener Text nimmt ihr aber die Handlung: Die Folge ist eine **Begründungslast für den nächsten
Sprung**, kein Zustand dieses Baums — und der nächste Sprung steht selbst unter einem Trigger
([ADR-0047](../plan/adr/0047-ziel-fassung-regiert-den-sprung-v680.md) 1), der ihn einholt.
**Ausgang: bestätigt**, keine Folge-ADR.

## 4. Der namentlich übergebene Fall: ADR-0048 Trigger 3 — **nicht ausgeführt**

[ADR-0048](../plan/adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md)
Re-Evaluierungs-Trigger 3 lautet:

> *„Wenn dieselbe Frage für ein zweites Planungs-Artefakt entschieden werden muss (beobachtbar an
> einem Vorgang, der eine Eigentums-Frage an Roadmap, Slice-Plan oder `docs/plan/planning/README.md`
> stellt)."*

**Er ist nicht ausgeführt. Der Vorgang, der ihn auslöste, liegt nicht vor.** Die Prüfung geht über
die drei genannten Artefakte, und zwei von ihnen sind bereits durch eine Quelle gebunden — die
„dieselbe Frage" ist für sie keine offene:

- **Roadmap** — gebunden. [ADR-0048](../plan/adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md)
  §Was diese Entscheidung nicht tut nennt es selbst: *„Für die **Roadmap** gilt unverändert, was
  [ADR-0046](../plan/adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) §Konsequenzen ihrer zweiten
  Folgepflicht zuweist und was Baseline `v6.8.0`, `modul-08-agentenrollen.md` Schritt 6 (`Roadmap
  fortschreiben · Planner`) bindet."*
- **Slice-Plan** — gebunden. [ADR-0012](../plan/adr/0012-haupt-kontext-ohne-token-bilanz.md):214
  sagt es wörtlich: *„Der Slice-Plan gehört dem Planner; diese ADR benennt die Bedingung, sie
  schreibt ihn nicht."*
- **`docs/plan/planning/README.md`** — **ungebunden**, und das ist unverändert so:
  [ADR-0048](../plan/adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) §Konsequenzen sagt
  es wörtlich: *„Diese Entscheidung deckt die Datei **nicht** — sie ist kein Welle-Plan —, und sie
  weist sie auch niemandem zu."* Ein Vorgang, der ihre **Eigentums-Frage stellt**, liegt trotzdem
  nicht vor — siehe unten.

### Woran gemessen, und was der nahe liegende Kandidat wirklich ist

Zwei Vorgänge dieses Repos berühren ein Planungs-Artefakt, ohne die Eigentums-Frage zu stellen:

- **Der Report `2026-09-14-slice-flache-welle-ist-eroeffnet-nicht-geplant`, Finding F-2** —
  Gegenstand ist [`docs/plan/planning/README.md`](../plan/planning/README.md), und er ist als
  **Ziel-Form**-Frage kategorisiert (*„Nachzug an der Vorlage eines anderen Artefakts statt an der
  eigenen Ziel-Form"*). Ein Ziel-Form-Schnitt sagt, *welche Vorlage* gilt; er sagt nicht, *wer*
  schreiben darf.
  [ADR-0048](../plan/adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) §Konsequenzen zieht
  dieselbe Grenze: *„Das ist eine **Ziel-Form-Frage**."*
- **`slice-die-vorgangs-grenze-erreicht-den-reviewer-skill`** (in `next/`) — Gegenstand ist die
  **Urteilsgrundlage der prüfenden Rolle**, also [ADR-0028](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)-
  Territorium, kein Planungs-Artefakt (§5).

Daneben liegt der in der Übergabe genannte `slice-153` (Roadmap-Abschnittsnamen in den zwei
Command-Dateien) — über [ADR-0028](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)
eine **Anweisungssatz**-Frage, ausdrücklich keine Eigentums-Frage, und damit kein Träger dieses
Triggers.

**Die Suche ist keine Trefferliste, sie ist über den Gegenstand gefahren:** die lebenden
Planungs-Artefakte und die September-Reports nach einer Rollen-Aussage über die drei Artefakte.

```sh
git grep -nE '(planning/README|Roadmap|Slice-Plan).{0,80}(schreibende Rolle|Eigentum|gehört (dem|der)|wem gehört)' \
  -- 'docs/plan/planning/open' 'docs/plan/planning/next' 'docs/plan/planning/in-progress' 'docs/reviews/2026-09*'
# ein Treffer: die Konsistenzrunde zu ADR-0048 selbst — ein Beleg, keine Quelle
```

**Der Übergabe-Text hat also recht in der Feststellung und nicht in der Folgerung:** Dass
[ADR-0048](../plan/adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) §Konsequenzen die
Frage *„für jedes andere Planungs-Artefakt offen"* nennt, ist **kein** Beleg gegen ein Auslösen —
ein Trigger fragt nach dem Vorgang, nicht nach der Offenheit. Der Vorgang fehlt trotzdem.

**Was bleibt: ein benannter Gegenstand und kein offener Trigger.** Die einzige *ungebundene* der
drei Stellen ist `docs/plan/planning/README.md`. Wer ihre Behebung fährt, entscheidet die
Eigentumsfrage für sie mit
([ADR-0048](../plan/adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) §Konsequenzen:
*„weder freigegeben noch blockiert"*); die zwei Vorgänge, die sie heute anfassen, sind
Ziel-Form-Schnitte. **Sobald einer dieser Vorgänge die Frage stellt statt sie zu umgehen, ist
Trigger 3 ausgeführt** — dann steht Option E (eine Regel für alle lebenden Planungs-Artefakte) gegen
die Verengung, und das ist eine eigene ADR.

## 5. Die Reviewer-Folgepflicht aus ADR-0048 §Konsequenzen — gedeckt

Sie lautet: *„Ob die Grenze aus Festlegung 1 in `.harness/skills/reviewer.md` aufgenommen wird,
entscheidet der Reviewer."* Ihr Träger ist
[`slice-die-vorgangs-grenze-erreicht-den-reviewer-skill`](../plan/planning/next/slice-die-vorgangs-grenze-erreicht-den-reviewer-skill.md)
(in `next/`): sein §1 nennt ihn als **zweite Hälfte** des zweiteiligen Übergabe-Artefakts aus
[ADR-0048](../plan/adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) §Konsequenzen, sein
Verantwortlich-Feld weist ihn dem Reviewer zu
([ADR-0028](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Festlegung 1), und
sein Liefer-Punkt lässt **beide** Ausgänge zu — Aufnahme oder begründete Ablehnung.
**Gedeckt; kein Befund.**

**Er berührt Trigger 3 nicht.** Sein Gegenstand ist die Urteilsgrundlage der prüfenden Rolle, keines
der drei Planungs-Artefakte, und sein §1 nimmt *„Keine Eigentums-Entscheidung für ein zweites
Planungs-Artefakt"* ausdrücklich aus. Er sagt außerdem selbst, wer Trigger 3 auswertet: *„Sein
Träger ist das Trigger-Audit"* — also dieser Lauf. Die Rechnung geht auf: Der Slice liefert die
Adresse, an der die Reviewer-Frage fällt, und dieser Lauf hat sie ausgewertet.

## 6. Was ich nicht entscheiden konnte

- **Die Trigger, die an einem fremden Vertrag hängen.** Die Hook-Oberfläche und die
  Konfigurations-Orte des Agenten-Werkzeugs, die `Agent`-Vordergrund-Form und die
  Transkript-Erlaubnis des Auftraggebers — sie sind an diesem Baum nicht messbar
  ([ADR-0011](../plan/adr/0011-telemetrie-erfassung-policy.md), [ADR-0012](../plan/adr/0012-haupt-kontext-ohne-token-bilanz.md),
  [ADR-0019](../plan/adr/0019-agent-guard-prueft-die-aufrufform.md),
  [ADR-0021](../plan/adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md),
  [ADR-0022](../plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md)). Sie sind als
  *feedforward, kein Sensor* klassifiziert — das ist die ehrliche Einordnung, kein Verdikt.
- **Die Trigger, die an einem künftigen Vorgang hängen** — der nächste Baseline-Sprung
  ([ADR-0018](../plan/adr/0018-ziel-fassung-regiert-die-migration.md) und die Sprung-Familie), der
  nächste Accept-Übergang, der nächste Baum-Tausch. Kein Ausgang ist hier nötig; sie laufen in
  dem Vorgang, der sie auslöst.
- **Die `Proposed`-ADRs** (4: [ADR-0025](../plan/adr/0025-register-mit-gemischten-originalen.md),
  [ADR-0029](../plan/adr/0029-agenten-typkarten-derivativ-gemischte-originale.md),
  [ADR-0031](../plan/adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md),
  [ADR-0035](../plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)) — ihre
  **Re**-Evaluierungs-Trigger sind mitgelesen, aber kein ausgeführt. Ihre **Acceptance**-Trigger
  gehören nicht in den Auftrag dieses Laufs (*für die `Accepted`*); angemerkt sei nur, dass
  [ADR-0035](../plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) keinen
  Acceptance-Trigger **führt** und die Suche nach einem Träger-Slice leer ausgeht — die Klasse, die
  der `welle-14`-Audit für [ADR-0031](../plan/adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md)
  mit [slice-171](../plan/planning/open/slice-171-adr-0031-acceptance-trigger.md) geschlossen hat.
- **Die zwei Carveouts** — bestätigt der Planner aus dem Bestand; ich habe sie nur auf den
  Widerspruch in §1 gelesen.

## Verdikt

**Der ADR-Zweig trägt einen ausgeführten Trigger ohne Ausgang, und er ist nicht der übergebene.**

1. **Ausgeführt:** [ADR-0017](../plan/adr/0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md)
   Trigger 2. Die Ausnahme ruht auf einer Werkzeug-Aussage, die
   [ADR-0026](../plan/adr/0026-eingefrorene-referenz-referenz-weit-ausgenommen.md) an einer roten
   Gegenprobe widerlegt hat. Ausgang: **Folge-ADR** —
   [`ADR-0050`](../plan/adr/0050-geteiltes-ventil-ersetzt-die-datei-weite-ausnahme.md), `Proposed`,
   Teil-`Supersedes` auf §Entscheidung der ADR-0017. Vier `make docs-check`-Läufe tragen sie.
2. **Nicht ausgeführt:** [ADR-0048](../plan/adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md)
   Trigger 3. Für Roadmap und Slice-Plan ist die Frage durch eine Quelle gebunden, für
   [`docs/plan/planning/README.md`](../plan/planning/README.md) ist sie offen, und **kein Vorgang
   stellt sie**. Damit keine Folge-ADR, kein Optionswechsel — und die Verengung auf den Welle-Plan
   **trägt weiter**.
3. **Bestätigt, ohne Handlung:** [ADR-0014](../plan/adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md)
   Trigger 2, [ADR-0015](../plan/adr/0015-rollen-eigentum-an-norm-artefakten.md) Trigger 4,
   [ADR-0026](../plan/adr/0026-eingefrorene-referenz-referenz-weit-ausgenommen.md) Trigger 1
   (bereits ausgelöst und ausgegeben), [ADR-0038](../plan/adr/0038-ziel-fassung-regiert-den-sprung-v650.md)
   Trigger 3.
4. **Reifestufen:** keine vorhanden — Feststellung.
5. **Die Reviewer-Folgepflicht aus
   [ADR-0048](../plan/adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) §Konsequenzen ist
   durch `slice-die-vorgangs-grenze-erreicht-den-reviewer-skill` gedeckt.**

**Für den Planner (Schritt 3):** Der Vorgang aus Punkt 1 ist eine **Zusage an den Implementer** —
Eintrag zurückziehen, Paar setzen, drei Nachzüge (Config-Kommentare, `MR-029`-Zensus). Er schließt
nicht vor `Accepted` der [ADR-0050](../plan/adr/0050-geteiltes-ventil-ersetzt-die-datei-weite-ausnahme.md);
deren Acceptance-Trigger verlangt eine Reviewer-Runde. Der Zahl-Befund aus §1 gehört auf die
Carveout-Seite und nicht hierher.
