# ADR-0051: Das Eigentum am Rollen-Anweisungssatz trägt über die Emissionsgrenze — die Grenze verläuft am Ziel-Repo

**Status:** Proposed

**Datum:** 2026-09-15

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) (die Zuordnung, deren Reichweite
diese Datei bestimmt — ihre Festlegung 1 und die Ausnahme *„die emittierte Ebene"*, die kein
Dokument ausführt),
[ADR-0033](0033-wellen-archivierung-als-unterkommando.md) (ihre Festlegung 4 spricht den Text des
emittierten Anweisungssatzes der ausführenden Rolle zu und beruft sich dafür auf
[ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md); diese Datei gibt dem Satz den
Grund, den er zitiert),
[ADR-0048](0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) (der unmittelbare Präzedenzfall
auf demselben Konflikt-Pfad: dieselbe Beweislage, dasselbe gewählte Verdikt, und die Form einer
Auslegung, die kein `Supersedes` trägt; ihr §Was diese Entscheidung nicht tut führt die
Geltungsbereichs-Klausel, an der diese Datei den Gegenstand abgrenzt),
[ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) (Festlegung 1 — eine Zuordnung ohne Original
wird nicht unterstellt; die Disziplin, an der die Verengung unten hängt),
[ADR-0029](0029-agenten-typkarten-derivativ-gemischte-originale.md) (die Typkarten-Klasse, die
diese Datei nicht mitentscheidet),
[ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) (Festlegung 1 und 2 binden den
Acceptance-Trigger unten),
[ADR-0016](0016-verweis-traegt-tag-und-zitat.md) (Festlegung 2 — jede Baseline-Aussage unten trägt
Tag, Dateiname, Abschnitt und Zitat statt eines Pfad-Links),
[`AGENTS.md`](../../../AGENTS.md) §3.8 (der Zeiger auf die Zuordnung; diese Datei legt seine
Reichweite aus und bewegt ihn nicht), §3.4, §3.5,
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert),
[`MR-033`](../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)

**Schärft:** — Prozess-ADR ohne Spec-Stratum: sie entscheidet die Reichweite einer Rollen-Zuordnung
und ändert keine Spec-Aussage. **Kein `Supersedes`** — die Begründung steht in §Entscheidung.

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md` §Ziel-Form: ADR (MADR). Die Rollen-Aussagen unten
messen gegen die regierende Fassung `v6.8.0`
([`MR-033`](../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)).

---

## Kontext

### Der Anlass

Ein Reviewer-Lauf hat gegen den Commit `3e535c3c` (Rolle Implementer, Slice
`slice-174-archivierung-emittieren`) ein **HIGH mit Rollen-Widerspruch** gemeldet: derselbe Commit
ändert den Quelltext eines Rollen-Anweisungssatzes — `internal/emit/templates/commands/close-welle.md`,
Schritt 4 nennt statt der Handarbeit das Kommando. Der Report entscheidet die Rollen-Frage **nicht**;
er benennt beide Lesarten, stuft nicht herab und übergibt an den Architect. Das ist der Weg, den
`v6.8.0`, `modul-08-agentenrollen.md` §Konflikt-Pfad als Rollen-Sequenz für diesen Fall vorschreibt
(`tr '\n' ' ' < .harness/baseline/v6.8.0/regelwerk/modul-08-agentenrollen.md | tr -s ' ' | grep -cF
'Sie greift ab **HIGH mit Rollen-Widerspruch** oder ab dem **dritten** gleichen Konflikttyp'` → **1**;
**kein** Erwartungswert).

Der **Plan** desselben Slice hält beide Antworten nebeneinander: seine §3-Tabelle führt die Datei als
`update` **dieses** Slice, seine §6-Risikozeile nennt dieselbe Text-Hälfte eine *„Übergabe, keine
Implementer-Entscheidung"*. Der Plan hat die Frage damit nicht entschieden; er hat sie zweimal
beantwortet.

**Der zweite Ort derselben Klasse in derselben Sitzung.** Der Planner-Commit `258ab942` hat
`.claude/agents/implementer.md` geändert und das Eigentum **offen benannt**: *„Für diese Datei nennt
damit KEINE angenommene Quelle die schreibende Rolle. Der Zug ist die Anweisung des Auftraggebers und
als solche hier festgehalten."* Dort war der Träger die Ausnahme der
[ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Festlegung 3. Hier ist er die
**Grenze an der Emissionskante**, und sie ist ungeschrieben — dieselbe Klasse, ein anderer Rand.

### Die zwei Sätze, an denen sich die Lesarten trennen

**Lesart 1 — die Zuordnung gilt auch für die emittierte Fassung.** Der Satz steht in
[ADR-0033](0033-wellen-archivierung-als-unterkommando.md) Festlegung 4, verbatim:

> *„Er ist ein Rollen-Anweisungssatz und gehört nach [ADR-0028] der ausführenden Rolle; diese
> Entscheidung stellt die Erreichbarkeit her, sie schreibt den Satz nicht."*

(`tr '\n' ' ' < docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md | tr -s ' ' | grep -cF
'Er ist ein Rollen-Anweisungssatz und gehört nach'` → **1**). Dieselbe Datei wiederholt das an zwei
weiteren Stellen — `grep -cF 'Der Anweisungssatz gehört der ausführenden Rolle (Festlegung 4, letzter
Absatz)'` → **1**, `grep -cF 'Wer den Satz schreibt, entscheidet'` → **1** — und führt es in ihrem
`Bezug:` als *„die Grenze, an der Festlegung 4 endet"*.

**Lesart 2 — die emittierte Ebene ist von jener Zuordnung ausgenommen.** Der Satz steht in
[ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) §Was hier NICHT entschieden ist,
verbatim:

> *„…; **die schreibende Rolle für die Spec-Straten** … — die zwei jüngsten Belege von `BEO-007`
> liegen dort, und diese ADR erreicht sie nicht; **und die emittierte Ebene.**"*

(`grep -cF 'und die emittierte Ebene.'` → **1**), dazu ihre Folgepflicht 3: *„die emittierte Ebene
bleibt unberührt. Ob ein erzeugtes Repo eine Eigentums-Aussage über seine Anweisungssatz-Artefakte
bekommt, entscheidet der Slice, der die Tool-Ebene entscheidet — nicht diese ADR."*
(`grep -cF 'Ob ein erzeugtes Repo eine Eigentums-Aussage über seine Anweisungssatz-Artefakte bekommt'`
→ **1**).

**Die zwei Sätze widerlegen einander nicht — der zweite nimmt den ersten aus, ohne ihn zu ersetzen.**
Festlegung 4 der [ADR-0033](0033-wellen-archivierung-als-unterkommando.md) steht in einem Absatz,
der mit *„Was diese Festlegung nicht entscheidet"* beginnt: sie **spricht die Zuordnung zu, indem sie
sie zitiert**, und ihr Zitat zeigt auf eine Entscheidung, die genau diese Ebene ausnimmt. Damit ist
die Zuordnung im Bestand **angedeutet, aber nicht getragen** — und *das* ist die Lücke, die der
schreibende Lauf vorgefunden hat. Nicht *„die Quelle gilt, der Lauf hat sie gebrochen"*, sondern
*„kein Dokument führt die Grenze, auf der der Lauf stehen musste"*.

### Was gemessen ist, und was die Messung nicht trägt

**Dieselbe Inhaltsänderung, zwei Fassungen derselben Datei, zwei Rollen, elf Tage Abstand:**

```sh
git log --format='%h %ai %s' -1 8655ef20   # 8655ef20 2026-09-04 Rolle Planner:      close-welle.md Schritt 4 nennt den Traeger statt der Handarbeit
git log --format='%h %ai %s' -1 3e535c3c   # 3e535c3c 2026-09-15 Rolle Implementer: die Wellen-Archivierung erreicht das gebootstrappte Ziel
```

`8655ef20` ist die **Dogfood**-Fassung (`.claude/commands/close-welle.md`, +31/−14), `3e535c3c` die
**Vorlage** (+6/−1). **Was diese Messung nicht trägt:** sie zeigt, *dass* die zwei Fassungen von zwei
Rollen getragen wurden, und begründet **nichts** — Bestand ist kein Original
([ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1,
[ADR-0048](0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) §Was den Ausschlag nicht gibt hat
dieselbe Verteilung für dieselbe Frage gemessen und aus demselben Grund verworfen). Die Zahlen stehen
hier, damit die nächste Runde sie nicht unter einer Behauptung findet:

```sh
git log --format='%s' -- internal/emit/templates/commands/close-welle.md | grep -c '^Rolle Planner'      # 2
git log --format='%s' -- internal/emit/templates/commands/close-welle.md | grep -c '^Rolle Implement'    # 3
git log --format='%s' -- .claude/commands/close-welle.md                | grep -c '^Rolle Planner'      # 5
git log --format='%s' -- .claude/commands/close-welle.md                | grep -c '^Rolle Implement'    # 4
```

**Die Adresse des Befunds ist gemessen und trägt die Klasse bereits.** Das Beobachtungs-Register führt
`BEO-ALL/anweisungssatz-eigentum-ohne-quelle` mit **5** Belegen
(`ls docs/plan/planning/observations/BEO-ALL/anweisungssatz-eigentum-ohne-quelle/evidence/*.md | wc -l`
→ **5**) über **115** Verzeichnissen (`ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l` →
**115**) — beide **keine Erwartungswerte**. Seine `state.md` führt die Command-Artefakte als
*verkörpert*; die **emittierte Ebene** steht dort nicht als offener Teil, und ob sie einer ist,
entscheidet diese Datei mit.

**Was den Gegenstand zur Klasse macht, ist am Artefakt selbst ablesbar.** Die drei emittierten
Commands benennen ihre ausführende Rolle in ihrem eigenen Eröffnungssatz
(`grep -l 'Dieser Command führt die' internal/emit/templates/commands/*.md` → **3** Dateien);
`close-welle.md` nennt dort den **Planner**, `plan-welle.md` den **Planner**, `implement-slice.md`
den **Implementer**. [ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Festlegung 1
bindet die Zuordnung an den Ablauf und nicht an die Datei —
*„Gebunden ist die Artefaktklasse, nicht die Datei-Form"* (`grep -cF 'Gebunden ist die Artefaktklasse,
nicht die Datei-Form'` → **1**) — und an die **Rolle**:
*„Eigentum ist eine Eigenschaft des Ablaufs, den ein Anweisungssatz operationalisiert, nicht der
Datei-Existenz"* (`grep -cF 'Eigentum ist eine Eigenschaft des Ablaufs, den ein Anweisungssatz
operationalisiert, nicht der Datei-Existenz'` → **1**).

### Was hier offen blieb, ist genau der Rand

Der Rand ist die **Emissionskante**: dieses Repo schreibt unter `internal/emit/templates/` die
Vorlagen, aus denen ein **Ziel-Repo** seine Dateien bekommt. Kein anderes Rollen-Artefakt des Repos
hat diese Doppelnatur; alle vier Anweisungssätze der
[ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) liegen diesseits der Kante, und
das **Fragment** jenseits von ihr ist ausdrücklich die *andere* Klasse: *„Das **Fragment** ist kein
Anweisungssatz, sondern tool-generierte, konvergente Mechanik"* (Festlegung 4 derselben Datei).
Die Anleitung ist das Gegenteil davon — sie ist `skip-if-present` und gehört nach der Annahme dem
Adopter: *„was ein Adopter dort ändert, zieht kein Re-Lauf nach"* (Festlegung 5). **Die Kante
verläuft also innerhalb einer Datei-Klasse, und der Bestand benennt sie, ohne sie zu entscheiden.**

## Entscheidung

**Wir wählen Option D: die Grenze verläuft am Ziel-Repo, und der Rollen-Anweisungssatz dieses Repos
gehört der Rolle, die seinen Ablauf ausführt — ausgesprochen aus eigener Kraft, nicht als Zitat.**
Zwei Festlegungen, kein `Supersedes`.

### 1. Der Anweisungssatz dieses Repos gehört der ausführenden Rolle — auch als Vorlage

Gebunden ist der **Rollen-Anweisungssatz dieses Repos**, in beiden Fassungen derselben Klasse: die
lebenden Dateien unter `.claude/commands/` und die **Vorlagen** unter
`internal/emit/templates/commands/`. Kriterium ist allein, welche Rolle den Ablauf ausführt, wenn sie
dem Artefakt folgt.

**Kein Kriterium ist der Pfad.** Die Vorlage liegt unter `internal/`, ihr Zielort im Ziel-Repo ist
`.claude/commands/`; beide sind Orte und keine Rollen — dieselbe Absage, die
[ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Option E für den Nachbarfall
ausspricht. **Kein Kriterium ist die Ebene:** ob eine Datei emittiert *wird*, sagt nichts darüber,
wer ihren Text schreibt; die Autorschaft liegt diesseits der Kante, die Auslieferung jenseits.

**Angewandt** auf den gemessenen Bestand (drei Vorlagen, drei Rollen, §Kontext):

| Vorlage | Rolle |
|---|---|
| `internal/emit/templates/commands/close-welle.md` | **Planner** |
| `internal/emit/templates/commands/plan-welle.md` | **Planner** |
| `internal/emit/templates/commands/implement-slice.md` | **Implementer** |

**Nicht gebunden:** `.claude/agents/*.md` — die Ausnahme der
[ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Festlegung 3 bleibt unberührt, und
[ADR-0029](0029-agenten-typkarten-derivativ-gemischte-originale.md) bleibt die offene Frage dort.

### 2. Die Ausnahme *„die emittierte Ebene"* meint das Ziel-Repo, nicht diese Vorlage

Die Ausnahme aus [ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) §Was hier NICHT
entschieden ist wird in ihrer **eigenen** Glosse gelesen — Folgepflicht 3 nennt die Frage, die sie
ausnimmt, und sie ist eine Aussage über ein **erzeugtes Repo**. Ihre zwei Hälften:

- **Was sie trägt:** ob ein erzeugtes Repo eine **Eigentums-Aussage** über seine
  Anweisungssatz-Artefakte bekommt. Diese Frage bleibt **offen**, und sie liegt bei dem Slot, der die
  Tool-Ebene entscheidet — so schon [ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)
  Folgepflicht 3, und [ADR-0048](0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) führt
  dieselbe Klausel für ihren Gegenstand: *„Was ein **emittiertes** Repo an Eigentums-Aussagen
  bekommt, entscheidet der Slice, der die Tool-Ebene entscheidet"* (`grep -cF 'Was ein **emittiertes**
  Repo an Eigentums-Aussagen bekommt, entscheidet der Slice, der die Tool-Ebene entscheidet'` → **1**).
- **Was sie nicht trägt:** die Autorschaft der **Vorlage** in *diesem* Repo. Sie ist ein Artefakt
  dieses Repos wie jede lebende Datei daneben; Festlegung 1 oben entscheidet sie.

**Die emittierte Instanz** selbst ist nicht Gegenstand dieser Datei: im Ziel ist die Datei
`skip-if-present` und gehört dem Adopter — dieselbe Festlegung 5 der
[ADR-0033](0033-wellen-archivierung-als-unterkommando.md), aus der folgt, dass ein Re-Lauf dort
nichts nachzieht.

### Warum kein `Supersedes`

**Es gibt nichts zu korrigieren.** Die Ausnahme der
[ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) ist nicht falsch; sie ist
**kürzer als sie liest**, und ihre eigene Folgepflicht 3 nennt die gemeinte Frage. Ein `Supersedes`
ersetzte eine Entscheidung, die niemand angreift, und nähme der Zuordnung ihren Bestand — genau die
Begründung, mit der [ADR-0048](0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) ihre Option C
verworfen und auf `Supersedes` verzichtet hat. Festlegung 4 der
[ADR-0033](0033-wellen-archivierung-als-unterkommando.md) sagt dasselbe wie diese Datei; sie bekommt
hier den Grund, den sie zitiert.

## Verglichene Alternativen

Regeln dieser Sektion: **mindestens drei Optionen mit Pro/Contra** — „nichts tun" ist eine davon
(Baseline-Regelwerk `modul-04-adrs.md` §Ziel-Form: ADR (MADR)).

| Option | Pro | Contra |
|---|---|---|
| A — nichts tun, die Frage offen lassen | kein Schreibaufwand; der akute Konflikt ließe sich einmalig per Verdikt sprechen | Die Grenze bleibt ungeschrieben, und **der nächste Lauf steht vor derselben Frage**: zwei Rollen und ein Reviewer-Lauf haben in dieser Sitzung an ihr gehalten, ohne sich auf etwas berufen zu können ([ADR-0048](0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) verwarf dieselbe Option einen Tag zuvor aus demselben Grund). Die Adresse des Befunds existiert bereits und wächst mit jeder Runde |
| B — die Vorlage dem **Implementer** zusprechen, wie das Fragment jenseits der Kante | eine Zeile; deckt die Sicht, die den Gegenstand als tool-nahe Mechanik liest (er liegt unter `internal/emit/`) | Sie widerspricht dem Eröffnungssatz der Datei, der Festlegung 4 der [ADR-0033](0033-wellen-archivierung-als-unterkommando.md) und dem Maßstab der [ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Festlegung 1. Der Vergleich mit dem Fragment trägt nicht: das ist **konvergent** und tool-eigen, die Anleitung ist `skip-if-present` und gehört nach der Annahme dem Adopter. Sie verwechselt *wird emittiert* mit *ist Mechanik* |
| C — [ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) per `Supersedes` korrigieren | formal die Bahn, die [`AGENTS.md`](../../../AGENTS.md) §3.4 für eine Korrektur an einer `Accepted`-ADR nennt | Es gibt nichts zu korrigieren: die Ausnahme ist ungenau *gelesen*, nicht falsch geschrieben, und ihre eigene Folgepflicht 3 nennt die gemeinte Frage. Ein `Supersedes` an dieser Stelle träfe eine Entscheidung, die der auslösende Vorgang gerade **umsetzt** — die Zuordnung selbst ist unbestritten |
| **D — gewählt: die Grenze am Ziel-Repo, die Zuordnung aus eigener Kraft, ohne `Supersedes`** | Beantwortet jede künftige Vorlage ohne neue Liste, bleibt in der Verengung, die [ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1 verlangt, und lässt beide Nachbar-Entscheidungen unberührt in Kraft | Der Preis ist eine **Auslegung**: sie ist ein Urteil über eine Kante und kein Muster, sie hat keinen Wächter, und wer nur [ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) liest, bleibt bei der kurzen Lesart |

## Was diese Entscheidung nicht tut

- **Sie entscheidet nichts über die Adopter-Seite.** Ob ein erzeugtes Repo eine Eigentums-Aussage
  über seine Anweisungssatz-Artefakte bekommt, bleibt offen und liegt bei dem Slot, der die
  Tool-Ebene entscheidet — Festlegung 2 (a); diese Datei verschiebt ihn nicht.
- **Sie entscheidet nichts über `.claude/agents/*.md`.** Die Ausnahme der
  [ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Festlegung 3 und die offene
  Frage der [ADR-0029](0029-agenten-typkarten-derivativ-gemischte-originale.md) bleiben, wie sie
  stehen; die Typkarten sind kein Command und distillieren keinen Ablauf *einer* Rolle.
- **Sie entscheidet nichts über die Spec-Straten** — die zweite Hälfte derselben Ausnahme.
- **Sie stuft kein Review-Finding herab.** Das Finding hat eine reale, ungeschriebene Grenze
  freigelegt; was hier entschieden wird, ist die Grenze — nicht die Kategorie. „Herabstufen, weil
  Implementer widerspricht" ist nach `v6.8.0`, `modul-08-agentenrollen.md` §Konflikt-Pfad als
  Rollen-Sequenz kein zulässiges Verdikt und wird hier nicht gewählt. **Die Klasse des Findings
  wechselt damit:** *fremdes Rollen-Artefakt im Implementations-Kontext* setzt eine Quelle voraus, die
  das Artefakt einer anderen Rolle zuweist — für die emittierte Vorlage trug **keine Accepted-ADR**
  sie (§Kontext). Der Befund bleibt als **Lücke**, seine Adresse ist die Registerzeile
  [`BEO-ALL/anweisungssatz-eigentum-ohne-quelle`](../planning/observations/BEO-ALL/anweisungssatz-eigentum-ohne-quelle/observation.md).
- **Sie bewegt [`AGENTS.md`](../../../AGENTS.md) §3.8 nicht.** Dessen Absatz hält den **Zeiger** auf
  die [ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) — *„hier steht der Zeiger,
  nicht ihr Text"* —; diese Datei legt die Reichweite des Gezeigten aus und schreibt den Zeiger nicht
  um. Die Auffindbarkeit trägt der ADR-Index.
- **Sie ist keine Senkung nach [`AGENTS.md`](../../../AGENTS.md) §3.5.** Keine Schwelle, kein Modul
  und keine Gate-Strenge wird bewegt; der Gegenstand ist eine Rollen-Grenze.
- **Sie legt keine Beobachtung an und vergibt keine Kennung im Beobachtungs-Register.** Ob dieser Fall
  unter die vorhandene Zeile fällt oder einen neuen Teil an ihr erzeugt, ist ein Urteil über eine
  Klasse; die Route ist die Closure, und sie gehört dem Planner
  ([`AGENTS.md`](../../../AGENTS.md) §3.10) — dieselbe Abgrenzung, die
  [ADR-0048](0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) für ihren eigenen Anlass zieht.
- **Cutoff: ab der Annahme dieser Entscheidung, kein Nachrüsten.** Gebunden ist der Anweisungssatz,
  der **geschrieben oder geändert** wird. Der Bestand wird nicht nachgezogen — der bereits
  committete Text bleibt, wo er steht, `git` trägt ihn; dieselbe Begründung wie in
  [ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md),
  [ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md) und
  [ADR-0048](0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md).
- **Geltungsbereich: dieses Repo.** Was ein erzeugtes Repo an Regeln bekommt, entscheidet der Slice,
  der die Tool-Ebene entscheidet — nicht diese Datei.

## Konsequenzen

- **Positiv:** Die Frage *„durfte dieser Lauf das schreiben?"* hat an der Emissionskante eine Antwort,
  bevor die Änderung beginnt. Der Bestand zeigt, wie teuer die fehlende ist: zwei Rollen und ein
  Reviewer-Lauf haben sie in einer Sitzung dreimal berührt.
- **Positiv:** Die Zuordnung der [ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)
  bekommt an ihrem Rand einen **Grund** statt eines Zitats — die Lücke, die
  [ADR-0033](0033-wellen-archivierung-als-unterkommando.md) Festlegung 4 mit einem Verweis schließt,
  ist ab hier durch eine eigene Festlegung geschlossen.
- **Positiv:** Die Eigentums-Familie bleibt bei ihren drei Achsen (Original · Ablauf · Vorgang); diese
  Datei fügt **keine vierte** hinzu, sie bestimmt die **Reichweite** der zweiten. Eine vierte Achse
  wäre eine Zuschreibung über den gemessenen Fall hinaus.
- **Negativ, und das ist der Preis:** Die Auslegung ist ein Urteil und kein Muster. Wer nur die kurze
  Lesart der [ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) kennt, entscheidet
  weiter falsch, und kein Gate meldet es (§Fitness Function).
- **Negativ:** Der Cutoff lässt den bereits committeten Text stehen. Wer die Zuordnung am Bestand
  nachlesen will, findet dort weiter beide Rollen — ab hier aber mit einer Quelle, die sagt, welche
  gilt.
- **Folgepflicht 1 (Planner) — die Grenze steht, bevor der Slice schließt.** Das auslösende Finding ist
  merge-blockierend; gewähltes Verdikt ist *„Lockerung legitim, aber undokumentiert"* — der zweiteilige
  Auftrag des Konflikt-Pfads (Baseline `v6.8.0`, `modul-08-agentenrollen.md` §Konflikt-Pfad als
  Rollen-Sequenz: *„Folge-ADR + Erinnerungs-Slice in `next/`"*) lautet: *„Sofort-PR zieht Lockerung als
  Folge-ADR nach; Slice nicht still abschließen"*. **Dieses Dokument ist der erste Teil**; der Slice
  schließt **nicht vor seiner Annahme** — dieselbe Frist, die
  [ADR-0048](0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) für ihren auslösenden Slice gesetzt
  hat.
- **Folgepflicht 2 (Planner) — die Plan-Zeile, die den Gegenstand zweimal beantwortet.** Die §3-Tabelle
  von `slice-174-archivierung-emittieren` führt `internal/emit/templates/commands/close-welle.md` als
  `update` dieses Implementer-Slice, während ihre §6-Risikozeile dieselbe Text-Hälfte eine Übergabe
  nennt. Nach Festlegung 1 trägt §6; §3 wird korrigiert. Der Plan ist ein Planner-Artefakt, und die
  Korrektur ist seine.
- **Folgepflicht 3 (Planner) — die Marker-Stelle desselben Textes.** Der neue `ANPASSEN`-Marker lädt zu
  einer Umbenennung des `make`-Ziels ein (*„der Adopter darf es umbenennen"*), für die das Zielrepo
  keine beständige Stelle hat: `harness/mk/*.mk` ist tool-eigen und konvergent
  ([ADR-0007](0007-bootstrap-phasen.md)). Das ist ein **Inhalt** des Planner-Anweisungssatzes und
  gehört nach Festlegung 1 in die Planner-Rolle — der Implementer trägt an dieser Datei nichts mehr.
- **Folgepflicht 4 (Planner) — der Erinnerungs-Slice, als eigener Vorgang.** Der zweite Teil des
  Übergabe-Artefakts: der Teil der Grenze, der **offen** bleibt, bekommt eine Lifecycle-Adresse statt
  *„später"* — die **Adopter-Seite** aus Festlegung 2 (a), die
  [ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Folgepflicht 3 und
  [ADR-0048](0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) an den Tool-Slot delegieren und
  die heute niemand hält. **Der Architect schneidet ihn nicht:** Zuschnitt und Kennung sind
  Planner-Arbeit ([`AGENTS.md`](../../../AGENTS.md) §3.10), und dies ist die Übergabe — dieselbe
  Aufteilung, die [ADR-0048](0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) für ihren
  Erinnerungs-Slice gezogen hat.

## Fitness Function (falls maschinell prüfbar)

**Diese Entscheidung hat keinen Wächter, und das gehört benannt**
([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). Kein
Modul der [`.d-check.yml`](../../../.d-check.yml) liest Commits — `grep -n '^modules:' .d-check.yml`
nennt die aktivierten —, und `make mutate` kennt zwei Fehlschlag-Formen, keine davon für einen
Commit-Zuschnitt oder eine Rollen-Zuordnung. Dieselbe Lage stellen
[`AGENTS.md`](../../../AGENTS.md) §3.8 und §3.10 für ihren eigenen Commit-Zuschnitt fest.

| Tooling | Regel | Make-Target |
|---|---|---|
| — | Festlegung 1 hat **keinen** Wächter: die Zuordnung hängt an der Frage *„welche Rolle führt diesen Ablauf aus?"*, und die ist am Artefakt zu lesen und nicht zu zählen. Träger ist der Rollen-Wechsel **vor** der Änderung | — |
| — | Festlegung 2 hat **keinen** Wächter: kein Modul hält eine Aussage gegen die Reichweite ihrer Quelle; die Grenze zwischen *diesem* Repo und dem erzeugten ist kein Prüfbereich, den ein Modul führt. Träger ist diese Datei | — |

**Eine Hälfte ist trotzdem beobachtbar, und sie ist nicht die Regel:** ob ein Commit ausschließlich
Artefakte einer Rolle berührt, lässt sich nachträglich an `git log --stat` ablesen — das ist die
Ablesbarkeit, die [`AGENTS.md`](../../../AGENTS.md) §3.8 verlangt, kein Gate.

## Re-Evaluierungs-Trigger

- **Wenn ein künftiger Baseline-Stand eine schreibende Rolle für Command- oder Skill-Artefakte
  benennt** *(feedforward — eine Textänderung upstream, kein Sensor)*: Dann wird der erste
  Re-Evaluierungs-Trigger der [ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)
  fällig, und diese Datei mit ihm.
- **Wenn ein Slice die Adopter-Seite entscheidet** *(beobachtbar an einem Vorgang, der die Frage aus
  Festlegung 2 (a) beantwortet)*: Dann ist die offene Hälfte geschlossen, und diese Datei ist darauf
  hin neu zu halten — sie nimmt sie heute ausdrücklich aus.
- **Wenn dieselbe Klasse ein weiteres Mal auftritt, obwohl diese Grenze steht** *(feedforward — am
  Commit-Bestand ablesbar)*: Dann trägt der Ort nicht, und die Trägerwahl ist der Befund, nicht die
  Wiederholung — dieselbe Probe, die [ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)
  und [ADR-0048](0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) an sich selbst anlegen.
- **Wenn die Klasse im Beobachtungs-Register die Schwelle erneut überschreitet** *(beobachtbar am
  Zähler ihres Verzeichnisses)*: Dann ist die Verengung dieser Datei auf die Emissionskante neu zu
  prüfen, und eine allgemeine Fassung — eine Regel über alle Rollen-Artefakte statt je Klasse — wird
  die billigere Antwort.

## Der Acceptance-Trigger

Diese Entscheidung steht auf `Proposed`. Sie wird `Accepted`, **wenn eine Reviewer-Runde sie gegen
[ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md),
[ADR-0033](0033-wellen-archivierung-als-unterkommando.md) und
[ADR-0048](0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) auf Konsistenz geprüft hat und ihr
Report ohne blockierenden Befund an der **Substanz** der beiden Festlegungen in `docs/reviews/`
liegt.** Ein Befund an der Darstellung — Adressform, Zahl ohne Kommando, Zitat-Stelle — wird behoben
und hindert die Annahme nicht; ein Befund, der eine Festlegung ändert, blockiert. Der Beleg ist eine
Runde der prüfenden Rolle; die Nachmessung des Kontexts, der einen Befund auflöst, ist keiner
([ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 2) — nach einem
blockierenden Verdikt ist es die **nächste** Runde derselben Rolle, und die Accept-Zeile der
§Geschichte nennt ihn als **Kennung**, nicht als Pfad-Link (ebenda, Festlegung 1).

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-09-15 | **Proposed** | Architect-Verdikt im Rollen-Konflikt nach `v6.8.0`, `modul-08-agentenrollen.md` §Konflikt-Pfad als Rollen-Sequenz, ausgelöst von dem HIGH mit Rollen-Widerspruch aus dem Report `2026-09-15-slice-174-archivierung-emittieren.md` gegen den Commit `3e535c3c`. Gewähltes Verdikt: *„Lockerung legitim, aber undokumentiert"* — der schreibende Lauf stützte sich auf die §3-Zeile seines Plans, die §6 desselben Plans widerruft, und **keine** Accepted-ADR trug die Zuordnung für die emittierte Vorlage: [ADR-0033](0033-wellen-archivierung-als-unterkommando.md) Festlegung 4 spricht sie *nach* [ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) zu, und die nimmt *„die emittierte Ebene"* aus. Damit bleibt der Befund als **Lücke** stehen und nicht als Verstoß; diese Datei schreibt die Grenze. Der zweite Teil des Übergabe-Artefakts — der Erinnerungs-Slice in `next/` — ist eine Planner-Folgepflicht (§Konsequenzen, Folgepflicht 4) |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0051` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs: *„Eine ADR mit Status `Accepted` wird nicht inhaltlich überschrieben"*).
