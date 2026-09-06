# ADR-0037: Der Bootstrap stellt den Tag-0-Zustand des Prozesses her — die Struktur-Aufzählungen in `LH-FA-02` nennen Instanzen, nicht die Menge

**Status:** Proposed

**Datum:** 2026-09-06

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) (Init legt die
sprach-agnostische Harness-Struktur an),
[`LH-FA-02`](../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) (die zwei
Aufzählungen, deren Reichweite hier entschieden wird, und die Zusage *out-of-the-box
gate-sicher*),
[`LH-FA-03`](../../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7) (die
Präzedenz einer tool-autorierten Datei ohne Baseline-Vorlage),
[`LH-FA-09`](../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren) (das Regelwerk, dessen
Tag-0-Aussage das Ziel mitbekommt),
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (die
Gegenkraft: kein Gate und keine Zusage über einem Bestand, den kein Lauf herstellt),
[ADR-0007](0007-bootstrap-phasen.md) (die Idempotenz-Klassifikation, die Festlegung 3 anwendet),
[ADR-0005](0005-ziel-repo-distribution.md) (der vendored Template-Baum im Ziel),
[ADR-0006](0006-durchsetzung-commands-tool-als-quelle.md) (Tool-als-Quelle als bereits
beschlossene Herkunfts-Klasse),
[ADR-0034](0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
(Festlegung 1 — die Ablage besteht aus `README.md` plus je Beobachtung einem Verzeichnis;
Festlegung 5 — die Ablage ist ortsfest),
[`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage) (eine Abweichung von der
Baseline schuldet einen Eintrag — diese Entscheidung setzt keine),
[`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben dem Kommando, das sie liefert),
[`MR-033`](../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
(jede Baseline-Aussage nennt ihren Tag)

**Schärft:** `ARC-003` (Idempotente Ablage,
[`spec/architecture.md §1`](../../../spec/architecture.md#1-komponenten-übersicht)) — Festlegung 3
weist die eine neue Datei einer der zwei Klassen zu. Aufwärts-Deklaration: wer diese ADR ändert,
prüft die Klassen-Tabelle in [ADR-0007](0007-bootstrap-phasen.md) Entscheidung 3 und den
Idempotenz-Abschnitt in
[`spec/architecture.md §5`](../../../spec/architecture.md#5-idempotenz-fragment-assembly-und-resume)
nach. **Keine Anforderung wird geändert** — Festlegung 1 legt einen bestehenden Satz aus, sie
schreibt ihn nicht um ([`AGENTS.md`](../../../AGENTS.md) §2 Rang 1).

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md`
§Ziel-Form: ADR (MADR).

---

## Kontext

### Die Frage kommt aus dem Emitter selbst, nicht von außen

`internal/emit/templates.go` benennt seine eigene offene Stelle im Klartext — zwei Kommentar-
Absätze, verbatim:

```text
GRENZE: LH-FA-02 fuehrt diese Disposition nicht — es nennt Singletons,
Wiederkehrende, derivative Indexe, .gitkeeps und die nie kopierte Set-Index-README.
Das Lastenheft ist Rang 1 und wird nicht vom Emit fortgeschrieben.

Im Adaptions-Block steht zu dieser Weiche kein Eintrag; wo keiner steht, gilt die
Baseline unveraendert (MR-000 Baseline-Aussage). Ob einer dazukommt, entscheidet
der Architect (AGENTS 3.8) — nicht diese Datei und nicht der Lauf, der sie anfasst.
```

```sh
grep -c 'GRENZE: LH-FA-02 fuehrt diese Disposition nicht' internal/emit/templates.go   # 1
grep -c 'Ob einer dazukommt, entscheidet der Architect' internal/emit/templates.go     # 1
```

**Keine Erwartungswerte**
([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). Der Implementations-Kontext hat die Frage korrekt liegen gelassen; sie wird hier
beantwortet.

### Was die adoptierte Baseline `v6.0.0` über den Tag-0-Zustand sagt

Zwei Stellen in `modul-06-roadmap.md` §Das Beobachtungs-Register, beide im Indikativ und beide
über *jedes* Repo:

```sh
grep -c 'README.md                          existiert ab Repo-Beginn' \
  .harness/baseline/v6.0.0/regelwerk/modul-06-roadmap.md                                    # 1
grep -c 'Die leere Ablage \*\*ist\*\* die Aussage, und sie ist die, mit der jedes Repo anfängt' \
  .harness/baseline/v6.0.0/regelwerk/modul-06-roadmap.md                                    # 1
```

Der zweite Satz trägt seine Begründung mit: *„Ohne sie wäre nichts beobachtet nicht von nie
geführt zu unterscheiden."* Die Ablage ist damit kein Nebenprodukt der ersten Beobachtung,
sondern eine **Aussage über den Anfangszustand** — und `ai-harness-init` ist genau das Werkzeug,
das diesen Anfangszustand herstellt
([`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen)).

### Der emittierte Stand widerspricht sich heute selbst

Alle drei mitemittierten Anweisungssätze nennen den Ort, **zwei** davon namentlich die Datei:

```sh
grep -rlc 'docs/plan/planning/observations' internal/emit/templates/commands/*.md | wc -l        # 3
grep -rl 'docs/plan/planning/observations/README.md' internal/emit/templates/commands/ | wc -l   # 2
```

Angelegt wird nichts davon. Im ganzen Go-Code steht der Name dreimal, und keine der drei Stellen
schreibt den Ort:

```sh
grep -rn 'observations' internal/ --include='*.go' | grep -v '_test.go' | wc -l          # 3
grep -rn 'observations' internal/ --include='*.go' | grep -v '_test.go' | grep -c '//'   # 2
```

Zwei sind **Kommentare** im Emitter, die die Vorlagen-Klassifikation erläutern; die dritte liegt
im Archiv-Werkzeug des Dogfood und setzt einen **Link** in einen Stub, nicht ein Verzeichnis. Ein
Emissionspfad, der die Ablage anlegte, existiert nicht.

Ein Adopter, der dem mitgelieferten `/plan-welle` folgt, wird damit auf eine Datei geschickt, die
sein Repo nicht hat. Das ist die Klasse, die
[`BEO-ALL/emittierte-vorlagen-klassifikation-ohne-traeger`](../planning/observations/BEO-ALL/emittierte-vorlagen-klassifikation-ohne-traeger/observation.md)
führt.

### Die Gegenposition, und warum sie nicht trägt

[`docs/user/benutzerhandbuch.md`](../../user/benutzerhandbuch.md) §Änderungshistorie 1.13
beschreibt die Nicht-Anlage als gewollt: *„Das Register selbst legt der Bootstrap nicht an — seit
es ein Verzeichnis je Beobachtung ist, gibt es keine stehende Register-Datei mehr, und das erste
Verzeichnis entsteht mit der ersten Beobachtung."*

Der Satz vermengt zwei Dinge, die
[ADR-0034](0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
auseinanderhält. Entfallen ist die **stehende Register-Datei** — die Tabelle, die den Zähler
führte (Festlegung 1: *„Die stehende Register-Datei entfällt, und keine Index-Datei tritt an ihre
Stelle"*). Nicht entfallen ist die **Ablage**, und dieselbe Festlegung schreibt ihre Form aus:
*„ein Verzeichnis `observations` unter `docs/plan/planning/` mit `README.md` und je Beobachtung
einem Verzeichnis"*. Die `README.md` ist Bestandteil der Ablage, nicht ein Eintrag darin; aus dem
Wegfall der Tabelle folgt für sie nichts.

Die Handbuch-Zeile beschreibt damit den **Ist-Stand des Werkzeugs**, nicht eine Entscheidung —
der Bestand ist keine Norm. Sie wird durch diese ADR an einem Punkt falsch; ihre Korrektur ist
Sache des Slice, der den Bestandsbaum des Handbuchs schreibt (`slice-191`), nicht dieser Datei.

### Zwei geprüfte Gegen-Gründe, beide tragen nicht

- **[ADR-0007](0007-bootstrap-phasen.md) (Idempotenz-Klassen)** rechtfertigt die Nicht-Anlage
  nicht. Sie sagt, *wie* eine emittierte Datei beim Re-Lauf behandelt wird — *„im Zweifel gilt
  `skip-if-present`"* —, und beantwortet damit eine andere Frage als *ob* sie beim ersten Lauf
  entsteht. Für die eine neue Datei liefert sie die Klasse (Festlegung 3), nicht ein Veto.
- **[ADR-0034](0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)**
  ebenso wenig: Ihr Geltungsbereich ist der Dogfood, und dort schreibt sie die Ablage samt
  `README.md` gerade **vor**. Über die emittierte Ebene sagt sie nichts — die Ebenen-Trennung
  bleibt bestehen, und deshalb braucht die emittierte Hälfte diese eigene Entscheidung.

### Die zwei Aufzählungen in [`LH-FA-02`](../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) — was sie zählen und was nicht

Der tragende Satz lautet: *„Leere Struktur-Verzeichnisse (Lifecycle-Ordner, ADR-/Carveout-/
Reviews-Ordner) werden mit `.gitkeep` gehalten"*. Drei Messungen sprechen gegen die Lesart *die
Klammer ist die Menge*:

1. **Die Klammer mischt Klasse und Instanz.** *„Lifecycle-Ordner"* ist eine Klassen-Bezeichnung
   ohne Namen — sie deckt heute drei Verzeichnisse, ohne eines zu nennen; daneben stehen drei
   namentliche. Eine geschlossene Menge zählt nicht teils Klassen, teils Mitglieder.
2. **Das strittige Verzeichnis existierte zum Zeitpunkt der Aufzählung nicht.** Der Satz kam mit
   dem Change Request `0.8.0`; die Verzeichnis-Form des Adaptions-Blocks kam sechs Wochen später:

   ```sh
   grep -oE '^\| 0\.8\.0 \| [0-9-]+' spec/lastenheft.md   # | 0.8.0 | 2026-07-21
   grep -m1 '^- \*\*Datum:\*\*' \
     harness/conventions/MR-045-der-adaptions-block-laeuft-in-der-verzeichnis-form.md   # 2026-09-03
   ```

   Eine Aufzählung schließt nichts aus, was es bei ihrer Abfassung nicht gab; sie kannte es nicht.
3. **Die Regel hängt am Zweck, den derselbe Absatz nennt** — *out-of-the-box gate-sicher*. Ein
   leeres Struktur-Verzeichnis, das der emittierte Text nennt und das `git` nicht führt, ist
   genau der Defekt, gegen den der Satz geschrieben wurde. Dass die Namensliste ihn nicht
   erwähnt, macht ihn nicht zu einem anderen Defekt.

Dieselbe Bewegung — **Eigenschaft statt Aufzählung** — hat dieses Repo für die Adress-Klasse
schon vollzogen ([`AGENTS.md`](../../../AGENTS.md) §3.11: *„die Linie hängt an der Eigenschaft …
und nicht an der Aufzählung der Bäume"*). Sie wird hier nicht erfunden, sondern auf einen zweiten
Gegenstand angewandt.

### Dass eine Datei ohne Baseline-Vorlage entstehen darf, ist bereits entschieden

Für die Register-`README.md` führt der vendored Baum keine Vorlage:

```sh
find .harness/baseline/v6.0.0/templates -iname '*observation*README*' | wc -l   # 0
```

Das ist kein Hindernis, sondern eine bereits geführte Klasse. `.d-check.yml` ist ebenso
tool-autoriert — `internal/emit/emit.go` sagt über sie *„vom Tool AUTORIERTE minimale Config"* —,
und sie steht in der Aufzählung der Herkunfts-Klassen in
[`spec/lastenheft.md §5`](../../../spec/lastenheft.md#5-globale-out-of-scope-punkte) **nicht**:
dort sind [`LH-FA-06`](../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren),
[`LH-FA-08`](../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren) und
[`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) als
Tool-als-Quelle genannt,
[`LH-FA-03`](../../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7) nicht.
Die §5-Liste ordnet **Quellen zu**; sie zählt nicht die emittierten Dateien ab. Was sie verlangt,
ist eine *nachvollziehbare* Herkunft — und die ist hier dieselbe wie bei den Anweisungssätzen:
eine generische, aus Dogfood und Kurs-Prozess-Modulen abgeleitete Fassung
([ADR-0006](0006-durchsetzung-commands-tool-als-quelle.md)).

### Warum die Datei kein „Fülle-wenn-Inhalt-da"-Fall ist

[`LH-FA-02`](../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) hält
**derivative Index-Sichten** bis zum ersten Inhalt zurück, und der Emitter zieht die Linie
bereits selbst: *„Der Planning-Index … ist bewusst NICHT dabei: er dokumentiert die
Lifecycle-Konvention (nuetzlich auch leer) und traegt keinen broken Link."* Die
Register-`README.md` steht auf derselben Seite dieser Linie — sie **listet keine Beobachtung**
(genau das verbietet
[ADR-0034](0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
Festlegung 1), sie beschreibt die Ablage-Regeln, sie ist leer nützlich, und sie trägt keinen
Platzhalter-Link, der ein frisches `docs-check` röten könnte.

## Entscheidung

**Der Bootstrap stellt den Zustand her, den der von ihm mitgelieferte Prozess für Tag 0
beschreibt; die Struktur-Aufzählungen in
[`LH-FA-02`](../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) nennen
Instanzen, keine Menge.** Vier Festlegungen.

**1. Die zwei Struktur-Aufzählungen in
[`LH-FA-02`](../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) sind
beispielhaft, nicht abschließend.** Maßgeblich ist die **Eigenschaft**, nicht die Namensliste:

> Ein Ort ist vom Bootstrap anzulegen, wenn (a) das mitemittierte Regelwerk oder ein
> mitemittierter Text ihn für ein frisches Repo im **Indikativ** als vorhanden führt, (b) er
> ohne den Bootstrap nicht entsteht, weil `git` ein leeres Verzeichnis nicht führt, und (c) sein
> Anlegen keinen Platzhalter-Link erzeugt, der das Doku-Gate des Ziels rot färbt.

Alle drei Bedingungen zusammen, nicht einzeln. Die Aufnahme eines Ortes, der sie erfüllt, ist
**Erfüllung** von
[`LH-FA-02`](../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) und
[`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen), **kein Change Request**:
keine Anforderung ändert sich, keine Zusage wird zurückgenommen, und die Zusage *aus dem Nichts
wird nichts emittiert*
([`spec/lastenheft.md §5`](../../../spec/lastenheft.md#5-globale-out-of-scope-punkte)) bleibt
unangetastet, weil (a) die Quelle benennt. **`harness/conventions/` erfüllt die drei** und ist
damit gedeckt.

**2. `docs/plan/planning/observations/` entsteht beim Init, und zwar mit einer `README.md`, nicht
mit einer `.gitkeep`.** Die Nicht-Anlage ist eine Lücke gegenüber dem mitgelieferten Regelwerk,
keine Design-Alternative. Der Träger der Aussage ist die Datei selbst — ein `.gitkeep` hielte das
Verzeichnis, träfe aber die zwei Anweisungssätze nicht, die namentlich auf
`observations/README.md` zeigen, und trüge die Unterscheidung *nichts beobachtet* gegen *nie
geführt* nicht, die das Regelwerk als ihren Zweck nennt.

**Die Datei ist keine Kopie des Dogfood-Textes.** Der hiesige Text ist repo-spezifisch (er
zitiert Einträge des eigenen Adaptions-Blocks); emittiert wird eine generische Fassung, die die
Ablage-Form, die Schreib-/Lese-Rollen, die Beleg-Form und die drei Ausgänge nennt und sonst
nichts.

**3. Idempotenz-Klasse: `skip-if-present`** ([ADR-0007](0007-bootstrap-phasen.md)
Entscheidung 3). Sie ist Adopter-Boden: er schreibt sie fort, sobald sein Register lebt — dieses
Repo hat es getan. Die Klasse folgt damit nicht aus dem Zweifels-Default, sondern positiv aus dem
beobachteten Umgang mit derselben Datei. Ein `.gitkeep` einer Struktur-Ablage bleibt davon
unberührt und behält seine bisherige Behandlung.

**4. Was diese Entscheidung ausdrücklich nicht öffnet.** Sie ist ein **Kriterium**, keine
Blankovollmacht:

- Die **derivativen Index-Sichten** (ADR-Index, Carveout-Index) bleiben *Fülle-wenn-Inhalt-da* —
  sie scheitern an Bedingung (c) der Festlegung 1, und genau daran hat sie der Voll-Smoke einmal
  gemessen.
- Das **Reconciliation-Register** des Brownfield-Rückbaus bleibt **unemittiert** (Vorlage:
  [`reconciliation.template.md`](../../../.harness/baseline/v6.0.0/templates/docs/plan/planning/reconciliation.template.md)).
  Das Regelwerk legt es im Rückbau an, nicht im Skelett-Schritt — es scheitert an (a), weil der
  mitemittierte Planning-Index es einem Greenfield-Repo ausdrücklich abspricht.
- **Kein Eintrag im Adaptions-Block.** Diese Entscheidung stellt Baseline-Konformität her, statt
  von ihr abzuweichen; es gibt nichts zu deklarieren
  ([`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage)).
- **Kein Auftrag an bereits gebootstrappte Repos.** Der Bestand fällt unter *skip-if-present*
  ([ADR-0007](0007-bootstrap-phasen.md)); ein Migrationspfad ist hier nicht beschlossen und wäre
  ein eigener Vorgang.
- **Die Umsetzung ist nicht Gegenstand dieser ADR.** Welcher Slice welchen Ort in welchem Zug
  anlegt, entscheidet die Planung; hier steht, *dass* und *wonach*.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — nichts tun (Status quo) | keine Entscheidung, kein Code | Der emittierte Stand widerspricht sich messbar selbst: drei Anweisungssätze nennen einen Ort, den kein Pfad anlegt, zwei davon namentlich eine Datei. Die Zusage *out-of-the-box gate-sicher* ist damit für ein Ziel mit aktivem `codepaths` nicht einlösbar, und `harness/conventions/` bliebe ein von der emittierten `harness/conventions.md` genannter Ort ohne Existenz. „Nichts tun" heißt hier: die Lücke bleibt, und die nächste Runde stellt dieselbe Frage |
| B — die Handbuch-Linie festschreiben: Nicht-Anlage ist gewollt, dafür die drei Anweisungssätze umschreiben, bis sie den Ort nicht mehr nennen | löst die Fundstellen ohne neue emittierte Datei; das Werkzeug bleibt, wie es ist | Löst den Konflikt auf der falschen Ebene: Das mitgelieferte Regelwerk sagt weiter, dass jedes Repo mit der Ablage anfängt — es ist Teil desselben emittierten Standes ([`LH-FA-09`](../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren)), und ein Umschreiben der Anweisungssätze macht sie nur stumm, nicht richtig. Und es verschlechtert sie: der Sichtungs- und der Lese-Schritt bekämen keine Adresse mehr |
| C — `.gitkeep` in `observations/` statt einer `README.md` | eine Zeile in einer bestehenden Liste, keine autorierte Datei, keine Herkunfts-Frage | Trifft die zwei Fundstellen nicht, die auf `observations/README.md` zeigen, und lässt die eine Aussage weg, für die die Datei laut Regelwerk existiert. Ein `.gitkeep` sagt *hier ist ein Verzeichnis*; verlangt ist *hier wird geführt, und es ist leer* |
| D — Change Request an [`LH-FA-02`](../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3): Aufzählung als Menge lesen und per Version-Bump erweitern | maximale Formtreue gegenüber Rang 1; der Auftraggeber entscheidet ausdrücklich | Behandelt eine Auslegungs-Frage als Vertragsänderung und erzeugt damit eine Vertragsänderung je künftigem Struktur-Ort — dieselbe Runde, die [`AGENTS.md`](../../../AGENTS.md) §3.11 für die Adress-Klasse gerade abgeschafft hat. Und sie wäre inhaltlich falsch begründet: der CR `0.8.0` konnte `harness/conventions/` nicht ausschließen, weil es die Form erst sechs Wochen später gab |
| **E — gewählt: Eigenschaft statt Aufzählung (drei kumulative Bedingungen) + tool-autorierte Register-`README.md` als `skip-if-present`** | Der emittierte Stand hört auf, sich selbst zu widersprechen; die Regel gilt für den nächsten Ort ohne neue Runde; sie bleibt eng, weil alle drei Bedingungen zusammen gelten und die zwei bekannten Gegenbeispiele (derivative Indexe, Reconciliation-Register) an ihr scheitern statt ausgenommen zu werden; die Herkunfts-Klasse ist eine bereits geführte, nicht eine neue | Legt einen Rang-1-Satz aus, ohne dass der Auftraggeber ihn geändert hätte — wer die Aufzählung als Menge liest, sieht darin eine Vertragsdehnung. Die drei Bedingungen sind **Urteil**, nicht Muster: kein Sensor prüft (a), und wer *„nennt ihn im Indikativ"* weit auslegt, kann den Bestand ausdehnen. Und die emittierte `README.md` ist eine zweite Fassung einer Aussage des Regelwerks — sie kann gegen `modul-06-roadmap.md` driften, ohne dass etwas rot wird |

## Konsequenzen

- **Positiv:** Ein frisch gebootstrapptes Repo trägt die Orte, die sein eigener mitgelieferter
  Text nennt. Der Adopter, der `/plan-welle` folgt, findet, wohin er geschickt wird.
- **Positiv:** Die Frage ist als **Kriterium** entschieden, nicht als Einzelfall — der nächste
  Ort derselben Klasse braucht keine eigene Runde, sondern nur die drei Bedingungen.
- **Positiv:** Der Zweck von
  [`LH-FA-02`](../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) —
  *out-of-the-box gate-sicher* — wird für ein Ziel mit aktivem `codepaths` überhaupt erst
  erreichbar. Erreicht ist er damit nicht: das entscheidet der Slice, der die emittierte
  Modul-Liste anfasst (`slice-073`).
- **Negativ:** Festlegung 1 hat **keinen Sensor** und kann keinen bekommen — Bedingung (a) ist
  ein Urteil über einen Text, kein Muster. Die Schranke gegen eine ausufernde Anwendung ist
  prozessual: die drei Bedingungen gelten kumulativ, und der Reviewer prüft sie.
- **Negativ:** Die emittierte Register-`README.md` ist eine **zweite Fassung** einer Aussage, die
  im mitemittierten `modul-06-roadmap.md` bereits steht. Sie kann gegen den vendored Baum
  driften, wenn ein Baseline-Sprung die Ablage-Form ändert, und kein Gate hält die zwei zusammen.
  Das ist die bekannte Klasse
  [`BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen`](../planning/observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md)
  und hier benannt, nicht geschlossen.
- **Negativ:** [`docs/user/benutzerhandbuch.md`](../../user/benutzerhandbuch.md)
  §Änderungshistorie 1.13 wird an einem Punkt falsch. Ein Historie-Eintrag beschreibt einen
  vergangenen Stand und wird nicht rückwirkend umgeschrieben; was das Handbuch **im Präsens**
  über den Bestand sagt, zieht der Slice nach, der seinen Bestandsbaum schreibt.
- **Folgepflicht 1 (der umsetzende Lauf):** Beim Anlegen der `README.md` die drei Bedingungen aus
  Festlegung 1 je Ort **einzeln** im Slice-Plan oder Commit benennen — nicht pauschal. Die
  `want`-Liste des Mengen-Vergleichs im Emitter-Test wird dabei nachgezogen, nicht aufgeweicht.
- **Folgepflicht 2 (der Lauf, der den Handbuch-Bestandsbaum schreibt):** die Präsens-Aussage über
  den Register-Ort an den dann geltenden Bestand halten.
- **Folgepflicht 3 (Planner):** Die Risiko-Ausgänge in `slice-190` §6 und die Trigger-Zeile in §4
  werden von dieser ADR **nicht** gesetzt — das ist Closure- und Planungs-Arbeit
  ([`AGENTS.md`](../../../AGENTS.md) §3.10). Diese Datei ist das Übergabe-Artefakt, aus dem der
  Planner beim `open → next`-Schritt schöpft.

## Fitness Function (falls maschinell prüfbar)

| Tooling | Regel | Make-Target |
|---|---|---|
| Go-Test, `TestTemplates_EmittierterBestandVollstaendig` | der emittierte Baum ist **mengengleich** zur erwarteten Liste — ein hinzugefügter Ort ohne `want`-Eintrag und ein `want`-Eintrag ohne Emission färben beide rot | `make test` (in `make gates`) |
| `make full-smoke` | das frisch gebootstrappte Ziel fährt seinen zusammengeführten `make gates` grün — die Zusage *out-of-the-box gate-sicher* wird am Ziel gemessen, nicht hier behauptet | `make full-smoke` |

**Nicht gebaut, und hier benannt statt behauptet — zwei Stück.** **Festlegung 1** hat keinen
Sensor: Bedingung (a) fragt, ob ein Text einen Ort im Indikativ führt, und das ist ein Urteil.
**Die Deckung zwischen emittiertem Text und emittiertem Bestand** hat ebenfalls keinen: Das
Doku-Gate des Ziels fährt `codepaths` heute nicht, und im Dogfood liegt der emittierte Bestand
außerhalb des Prüfbereichs. Beide liegen im Feedforward-Quadranten
([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6): eine
Deckung, die kein Lauf prüft, wird nicht als vorhanden verbucht).

## Re-Evaluierungs-Trigger

- **Wenn ein Baseline-Sprung die Aussage *jedes Repo fängt mit der Ablage an* fallen lässt oder
  die Ablage-Form ändert** *(am vendored Baum ablesbar)*: dann fällt die Voraussetzung von
  Festlegung 2, und die emittierte `README.md` ist nachzuziehen oder zurückzunehmen.
- **Wenn ein Change Request die Struktur-Aufzählung in
  [`LH-FA-02`](../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)
  ausdrücklich als geschlossene Menge fasst** *(am Lastenheft ablesbar)*: dann ist Festlegung 1
  gegenstandslos, und jeder weitere Ort braucht seinen eigenen CR.
- **Wenn der vendored Baum eine Vorlage für die Register-`README.md` bekommt** *(am Baum
  ablesbar)*: dann fällt der Grund für die Tool-Autorierung, und die Datei wird gestempelt wie
  jedes andere Singleton.
- **Wenn `codepaths` im emittierten Ziel aktiviert wird** *(an der emittierten Modul-Liste
  ablesbar)*: dann wird die zweite nicht gebaute Deckung oben messbar, und die
  Fitness-Function-Tabelle ist um sie zu ergänzen.
- **Wenn ein Ort aufgenommen werden soll, der nur zwei der drei Bedingungen erfüllt** *(am
  Vorgang ablesbar)*: dann ist zu prüfen, ob die dritte Bedingung zu eng geschnitten ist oder ob
  der Fall ein anderer ist — zwei Diagnosen mit zwei Antworten, und keine davon ist, die
  Bedingung stillschweigend fallen zu lassen.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-09-06 | **Proposed** | Architect-Lauf zu den zwei offenen Risiken aus `slice-190` §6, die dessen `open → next`-Trigger sperren. Anlass ist die vom Emitter selbst benannte Grenze (*„Ob einer dazukommt, entscheidet der Architect"*) und der dritte Eintritt der Klasse [`BEO-ALL/emittierte-vorlagen-klassifikation-ohne-traeger`](../planning/observations/BEO-ALL/emittierte-vorlagen-klassifikation-ohne-traeger/observation.md). Geprüft und als nicht tragend verworfen sind die zwei möglichen Gegen-Gründe [ADR-0007](0007-bootstrap-phasen.md) und [ADR-0034](0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md); die Aufzählungs-Frage ist an drei Messungen entschieden, nicht an der Lesart |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0037` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).
