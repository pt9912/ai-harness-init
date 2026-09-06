# ADR-0037: Der Bootstrap stellt den Tag-0-Zustand des Prozesses her — die Struktur-Aufzählung in `LH-FA-02` nennt Instanzen, nicht die Menge

**Status:** Accepted

**Datum:** 2026-09-06

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) (Init legt die
sprach-agnostische Harness-Struktur an),
[`LH-FA-02`](../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) (die
Aufzählung, deren Reichweite hier entschieden wird, und die Zusage *out-of-the-box
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
[ADR-0016](0016-verweis-traegt-tag-und-zitat.md) (Festlegung 2 — die Form eines Baseline-Belegs
in einem einfrierenden Artefakt; Träger (a) bindet sie an den Accept-Übergang),
[ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md) (das derivative
Register gehört der Rolle seines Originals — der ADR-Index wird im selben Architect-Commit
nachgezogen),
[ADR-0034](0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
(Festlegung 1 — die Ablage besteht aus `README.md` plus je Beobachtung einem Verzeichnis;
Festlegung 5 — die Ablage ist ortsfest),
[`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage) (eine Abweichung von der
Baseline schuldet einen Eintrag — diese Entscheidung setzt keine),
[`MR-015`](../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
(die Change-Request-Frage bei Personalunion — Festlegung 1 beantwortet sie für die **Aufnahme**
eines Ortes, Festlegung 2 für dessen **Träger**; beide als *Erfüllung*),
[`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben dem Kommando, das sie liefert),
[`MR-033`](../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
(jede Baseline-Aussage nennt ihren Tag),
[`MR-036`](../../../harness/conventions.md#mr-036--die-change-request-regel-bei-personalunion-steht-jetzt-in-der-adoptierten-baseline)
(dieselbe Change-Request-Regel steht seit `v5.12.0` in der adoptierten Baseline),
[`MR-051`](../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
(Setzung 2 — ein zitierter Register-Zähler ist eine datierte Messung)

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
Absätze, verbatim und in der Reihenfolge der Quelle:

```text
Im Adaptions-Block steht zu dieser Weiche kein Eintrag; wo keiner steht, gilt die
Baseline unveraendert (MR-000 Baseline-Aussage). Ob einer dazukommt, entscheidet
der Architect (AGENTS 3.8) — nicht diese Datei und nicht der Lauf, der sie anfasst.

GRENZE: LH-FA-02 fuehrt diese Disposition nicht — es nennt Singletons,
Wiederkehrende, derivative Indexe, .gitkeeps und die nie kopierte Set-Index-README.
Das Lastenheft ist Rang 1 und wird nicht vom Emit fortgeschrieben.
```

```sh
grep -c 'Ob einer dazukommt, entscheidet der Architect' internal/emit/templates.go     # 1
grep -c 'GRENZE: LH-FA-02 fuehrt diese Disposition nicht' internal/emit/templates.go   # 1
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

Angelegt wird nichts davon. Im Go-Code des Emitters und des Dogfood-Werkzeugs steht der Name
dreimal, und keine der drei Stellen schreibt den Ort:

```sh
grep -rn 'observations' internal/ cmd/ --include='*.go' | grep -v '_test.go' | wc -l          # 3
grep -rn 'observations' internal/ cmd/ --include='*.go' | grep -v '_test.go' | grep -c '//'   # 2
```

Zwei sind **Kommentare** im Emitter, die die Vorlagen-Klassifikation erläutern; die dritte liegt
im Archiv-Werkzeug des Dogfood und setzt einen **Link** in einen Stub, nicht ein Verzeichnis. Ein
Emissionspfad, der die Ablage anlegte, existiert nicht.

Ein Adopter, der dem mitgelieferten `/plan-welle` folgt, wird damit auf eine Datei geschickt, die
sein Repo nicht hat. Das ist die Klasse, die
[`BEO-ALL/emittierte-vorlagen-klassifikation-ohne-traeger`](../planning/observations/BEO-ALL/emittierte-vorlagen-klassifikation-ohne-traeger/observation.md)
führt.

### Welche Aufzählung in [`LH-FA-02`](../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) ausgelegt wird — und was sie zählt

Der Absatz trägt **vier** Klammern, die je eine Klasse aufzählen:

```sh
sed -n '/^### LH-FA-02/,/^### LH-FA-03/p' spec/lastenheft.md | tr '\n' ' ' \
  | grep -oE '\([^()]*\)' | grep -E 'authored-once|ADR ·|Carveout-Index|Lifecycle-'
# (authored-once: `AGENTS.md`, `spec/*`, `harness/*`, Root-`README.md`, Roadmap)
# (ADR · slice · welle · carveout · review-report)
# (ADR-/ Carveout-Index)
# (Lifecycle- Ordner, ADR-/Carveout-/Reviews-Ordner)
```

**Keine Erwartungswerte.** Ausgelegt wird hier **die vierte** — die Klammer der leeren
Struktur-Verzeichnisse. Ihr tragender Satz lautet: *„Leere Struktur-Verzeichnisse
(Lifecycle-Ordner, ADR-/Carveout-/Reviews-Ordner) werden mit `.gitkeep` gehalten"*. Drei
Messungen sprechen gegen die Lesart *die Klammer ist die Menge*:

1. **Die Klammer mischt Klasse und Instanz.** Sie nennt eine Klassen-Bezeichnung ohne Namen und
   daneben drei Ordner beim Namen:

   ```sh
   sed -n '/^### LH-FA-02/,/^### LH-FA-03/p' spec/lastenheft.md | tr '\n' ' ' \
     | grep -oE '\(Lifecycle-[^()]*\)'
   # (Lifecycle- Ordner, ADR-/Carveout-/Reviews-Ordner)
   ```

   Wie viele Verzeichnisse *„Lifecycle-Ordner"* deckt, sagt die Klammer nicht — und die zwei
   Antworten, die der Bestand gibt, sind verschieden: die Verzeichniskonvention des Regelwerks
   führt **vier** Ebenen, der Emitter hält **drei** davon mit `.gitkeep`, weil `in-progress/`
   bereits die Roadmap trägt.

   ```sh
   grep -oE '^docs/plan/planning/(open|next|in-progress|done)/' \
     .harness/baseline/v6.0.0/regelwerk/grundlagen-harness-dateien.md | sort -u | wc -l   # 4
   sed -n '/^func structureGitkeeps/,/^}/p' internal/emit/templates.go \
     | grep -c '"docs/plan/planning/'                                                     # 3
   ```

   **Keine Erwartungswerte.** Eine geschlossene Menge zählt nicht teils Klassen, teils
   Mitglieder — und sie lässt die Zahl ihrer Mitglieder nicht offen.
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

Für die Register-`README.md` führt der vendored Template-Baum, den das Ziel mitbekommt
([ADR-0005](0005-ziel-repo-distribution.md)), keine Vorlage:

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
beschreibt; die Struktur-Aufzählung in
[`LH-FA-02`](../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) nennt
Instanzen, keine Menge.** Vier Festlegungen.

**1. Die Aufzählung der leeren Struktur-Verzeichnisse in
[`LH-FA-02`](../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) — die vierte
der vier Klassen-Klammern des Absatzes, *„(Lifecycle-Ordner, ADR-/Carveout-/Reviews-Ordner)"* —
ist beispielhaft, nicht abschließend.** Maßgeblich ist die **Eigenschaft**, nicht die Namensliste:

> Ein Ort ist vom Bootstrap anzulegen, wenn (a) das mitemittierte Regelwerk oder ein
> mitemittierter Text ihn für ein frisches Repo im **Indikativ** als vorhanden führt, (b) er
> ohne den Bootstrap nicht entsteht, weil `git` ein leeres Verzeichnis nicht führt, und (c) sein
> Anlegen keinen Platzhalter-Link erzeugt, der das Doku-Gate des Ziels rot färbt.

Alle drei Bedingungen zusammen, nicht einzeln.

**Wie (a) ausgewertet wird.** (a) fragt nach
dem **Tag-0-Zustand**: Führt der Text den Ort als in einem **frischen** Repo vorhanden? **Drei
Formen tun das nicht**, und alle drei sind an der Form der Nennung erkennbar, nicht am Gegenstand:

1. **Modus- oder Bedingungs-Zusatz** — *„nur im Brownfield-Bootstrap"*. Der Text führt den Ort für
   einen Lauf, den ein Greenfield-Bootstrap nicht fährt.
2. **Ziel eines Vorgangs, der ein Ereignis voraussetzt** — ein Umzug, eine Auflösung, ein erster
   Eintrag: *„ist ihr Auflösungs-Trigger eingetreten, wandert sie … nach `conventions/done/`"*.
   Ein Text, der sagt, **wodurch** ein Ort entsteht, sagt damit, dass er vorher nicht da ist.
3. **Glosse statt Eintrag** — in einer Verzeichnisdarstellung ist der **Eintrag** die Zeile; was
   rechts des `#` steht, erläutert ihn. Ein Pfad, der dort und nur dort vorkommt, ist kein
   geführter Ort. Die Unterscheidung ist keine Lesart, sondern messbar:

   ```sh
   sed -n '/^### Verzeichniskonvention/,/^### Template-Schichtung/p' \
     .harness/baseline/v6.0.0/regelwerk/grundlagen-harness-dateien.md \
     | grep -c '^harness/conventions/ .*# .*done/ = aufgelöst'            # 1 — Eintrag links,
                                                                          #     done/ rechts
   sed -n '/^### Verzeichniskonvention/,/^### Template-Schichtung/p' \
     .harness/baseline/v6.0.0/regelwerk/grundlagen-harness-dateien.md \
     | grep -cE '^harness/conventions/done/|^docs/plan/carveouts/done/'   # 0 — keine eigene Zeile
   ```

   **Keine Erwartungswerte.**

Alle drei Formen sind Baseline `v6.0.0` und in Festlegung 4 je an ihrem Fall belegt. Dazu **zwei
Kollisions-Regeln**, weil die Disjunktion *„Regelwerk **oder** mitemittierter Text"* zwei
**Quellen** eröffnet, nicht zwei Maßstäbe:

- Eine Nennung nach 1–3 **entkräftet nichts**; sie trägt (a) nur selbst nicht. Führt **eine** der
  Quellen den Ort unbedingt, ist (a) erfüllt, und ein zweiter, bedingter Text ändert daran nichts.
- Umgekehrt entkräftet eine **ausdrückliche Tag-0-Aussage** — ein mitemittierter Text, der über
  die **Existenz** des Ortes sagt, sie entstehe erst durch ein Ereignis — jede Nennung, die man
  sonst als unbedingt läse: Sie beantwortet genau die Frage, die (a) stellt, und beantwortet sie
  mit *nein*.

Form 2 disqualifiziert **die Nennung, in der sie steht**, und trägt nicht über sie hinaus; die
zweite Kollisions-Regel greift allein an einer Aussage über die **Existenz** des Ortes selbst.

Die Aufnahme eines Ortes, der die drei erfüllt, ist **Erfüllung** von
[`LH-FA-02`](../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) und
[`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen), **kein Change Request**
([`MR-015`](../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler),
seit `v5.12.0` in der Baseline —
[`MR-036`](../../../harness/conventions.md#mr-036--die-change-request-regel-bei-personalunion-steht-jetzt-in-der-adoptierten-baseline)):
keine Anforderung ändert sich, keine **Zusage des Lastenhefts** wird zurückgenommen, und die
Zusage *aus dem Nichts wird nichts emittiert*
([`spec/lastenheft.md §5`](../../../spec/lastenheft.md#5-globale-out-of-scope-punkte)) bleibt
unangetastet, weil (a) die Quelle benennt.

Eine Zusage in einem **Plan** — ein Abnahmekriterium eines Slice — liegt auf einer anderen Ebene
und ist von diesem Satz nicht gedeckt; Festlegung 4 benennt die eine, die diese Entscheidung
berührt.

**Die drei übrigen Klassen-Klammern desselben Absatzes bleiben unberührt.** Die
Singleton-Klammer *„(authored-once: …)"* zählt **template-abgeleitete** Dateien — die
Register-`README.md` ist keine, der vendored Baum führt für sie keine Vorlage, und ihre
Herkunfts-Klasse ist die tool-autorierte aus
[`LH-FA-03`](../../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7) /
[ADR-0006](0006-durchsetzung-commands-tool-als-quelle.md). Die Klammer der **Wiederkehrenden**
und die der **derivativen Index-Sichten** tragen im selben Absatz je ihre eigene Klassen-Regel;
Festlegung 4 lässt beide stehen. Festlegung 1 legt eine Klammer aus und hebt keine
Klassen-Regel auf.

*Unberührt* heißt: diese Entscheidung legt sie nicht aus — nicht, dass sie als geschlossene Menge
zu lesen wären.

**`harness/conventions/` erfüllt die drei** — je Bedingung einzeln belegt, in genau der Form, die
Folgepflicht 1 unten vom umsetzenden Lauf verlangt:

- **(a)** Das mitemittierte Regelwerk führt den Ort **unbedingt** im Indikativ: Baseline `v6.0.0`,
  `grundlagen-harness-dateien.md` §Verzeichniskonvention, in derselben Baumdarstellung wie
  `docs/plan/planning/observations/` — *„harness/conventions/ # ein MR je Datei; done/ =
  aufgelöst"*. Die Vorlage, aus der der Bootstrap den Konventionsspeicher stempelt, nennt ihn ein
  zweites Mal — Baseline `v6.0.0`, `templates/harness/conventions.template.md`
  §Adaptions-Block, und zwar im **Rumpf**, der den Template-Abbau überlebt, nicht in einem
  Kommentarblock: *„Jede Adaption ist eine eigene Datei unter `harness/conventions/`"*.

  ```sh
  grep -c '^harness/conventions/ ' \
    .harness/baseline/v6.0.0/regelwerk/grundlagen-harness-dateien.md      # 1
  grep -c 'Jede Adaption ist eine eigene Datei unter `harness/conventions/`' \
    .harness/baseline/v6.0.0/templates/harness/conventions.template.md    # 1
  ```

- **(b)** Der emittierte Bestand trägt unter `harness/conventions/` nichts — ohne den Bootstrap
  entsteht das Verzeichnis nicht, weil `git` ein leeres Verzeichnis nicht führt. Gemessen an der
  `want`-Liste des Mengen-Vergleichs — der Ausschnitt ist auf **dessen** Funktion begrenzt, damit
  die zweite `want`-Liste der Datei nicht mitzählt —, mit Gegenprobe an derselben Liste, damit die
  Null nicht aus einem leeren Ausschnitt stammt:

  ```sh
  sed -n '/^func TestTemplates_EmittierterBestandVollstaendig/,/^}/p' \
    internal/emit/templates_test.go | grep -c 'harness/conventions\.md'   # 1 — die Index-Datei
                                                                          #     steht in der Liste
  sed -n '/^func TestTemplates_EmittierterBestandVollstaendig/,/^}/p' \
    internal/emit/templates_test.go | grep -c 'harness/conventions/'      # 0 — das Verzeichnis
                                                                          #     daneben nicht
  ```

- **(c)** Der Träger ist ein `.gitkeep`. Es ist leer, trägt also keinen Link und damit keinen
  Platzhalter-Link.

**Keine Erwartungswerte** — alle vier Zahlen wandern mit dem Baum.

**2. `docs/plan/planning/observations/` entsteht beim Init, und zwar mit einer `README.md`, nicht
mit einer `.gitkeep`.** Die Nicht-Anlage ist eine Lücke gegenüber dem mitgelieferten Regelwerk,
keine Design-Alternative. Der Träger der Aussage ist die Datei selbst — ein `.gitkeep` hielte das
Verzeichnis, träfe aber die zwei Anweisungssätze nicht, die namentlich auf
`observations/README.md` zeigen, und trüge die Unterscheidung *nichts beobachtet* gegen *nie
geführt* nicht, die das Regelwerk als ihren Zweck nennt.

**Die Träger-Frage ist damit hier entschieden, nicht in Festlegung 1.** Festlegung 1 entscheidet,
**ob** ein Ort entsteht; über den Träger sagen ihre drei Bedingungen nichts und könnten es nicht.

**Und diese Wahl ist Erfüllung von
[`LH-FA-02`](../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3), keine
Vertragsänderung** — dieselbe Einordnung, die Festlegung 1 für die *Aufnahme* eines Ortes trifft,
hier für seinen *Träger*. Der `.gitkeep`-Satz jenes Absatzes trägt ein benanntes Subjekt:

```sh
sed -n '/^### LH-FA-02/,/^### LH-FA-03/p' spec/lastenheft.md | tr '\n' ' ' \
  | grep -oE 'Leere Struktur-Verzeichnisse[^;]*'
# Leere Struktur-Verzeichnisse (Lifecycle- Ordner, ADR-/Carveout-/Reviews-Ordner)
# werden mit `.gitkeep` gehalten
```

`docs/plan/planning/observations/` ist nach diesem Rang-1-Satz **keines**: Es trägt eine Datei, die
das mitemittierte Regelwerk als **Bestandteil der Ablage** führt — dieselbe Form, die
[ADR-0034](0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
Festlegung 1 für den Dogfood vorschreibt —, nicht als Träger eines sonst leeren Verzeichnisses.
Der Unterschied hängt nicht an der Wortwahl, sondern an einer Aufgabe, die das eine erfüllt und
das andere nicht: Ein `.gitkeep` lässt `git` ein leeres Verzeichnis führen, und mehr nicht. Die
`README.md` trägt daneben die Unterscheidung *nichts beobachtet* gegen *nie geführt*, für die das
Regelwerk sie verlangt und die kein `.gitkeep` tragen kann. Der Satz wird damit nicht abbedungen;
sein Subjekt trifft für diesen Ort nicht zu.

**Die Datei ist keine Kopie des Dogfood-Textes.** Der hiesige Text ist repo-spezifisch (er
zitiert Einträge des eigenen Adaptions-Blocks); emittiert wird eine generische Fassung, die die
Ablage-Form, die Schreib-/Lese-Rollen, die Beleg-Form und die drei Ausgänge nennt und sonst
nichts.

**3. Idempotenz-Klasse: `skip-if-present`** ([ADR-0007](0007-bootstrap-phasen.md)
Entscheidung 3). Sie folgt aus deren eigener Regel — *„jede emittierte Datei ist **genau einer**
Klasse zugeordnet; im **Zweifel gilt `skip-if-present`** (nie Adopter-Inhalt clobbern — der
sichere Default)"* —, und der Zweifel besteht, sobald ein Adopter den Text an sein Repo anpasst.
Ein `.gitkeep` einer Struktur-Ablage bleibt davon unberührt und behält seine bisherige Behandlung.

**4. Was diese Entscheidung ausdrücklich nicht öffnet.** Sie ist ein **Kriterium**, keine
Blankovollmacht:

- Die **derivativen Index-Sichten** (ADR-Index, Carveout-Index) bleiben *Fülle-wenn-Inhalt-da*.
  **Der tragende Grund ist die eigene Klassen-Regel desselben
  [`LH-FA-02`](../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)-Absatzes:**
  *„Derivative Index-Sichten (ADR-/Carveout-Index) sind Fülle-wenn-Inhalt-da — sie entstehen durch
  Kopieren aus der Baseline, sobald der erste ADR/Carveout existiert, nicht als gate-unsichere
  Platzhalter-Skelette bei Bootstrap."* Festlegung 1 legt die Klammer der leeren
  Struktur-Verzeichnisse aus; sie hebt diese Regel nicht auf. Hinzu tritt, dass Festlegung 1 für
  sie **gegenstandslos** ist: Sie entscheidet, ob ein **Ort** entsteht, und `docs/plan/adr/` wie
  `docs/plan/carveouts/` entstehen bereits — der Bootstrap hält beide mit `.gitkeep`.

- Das **Reconciliation-Register** des Brownfield-Rückbaus bleibt **unemittiert**
  (Vorlage: Baseline `v6.0.0`, `templates/docs/plan/planning/reconciliation.template.md`).
  Es scheitert an (a), und der Beleg steht in derselben Quelle und derselben Form wie der von
  `harness/conventions/`: Baseline `v6.0.0`, `grundlagen-harness-dateien.md`
  §Verzeichniskonvention führt es mit einem **Modus-Zusatz** —
  *„docs/plan/planning/reconciliation.md # Reconciliation-Register: nur im Brownfield-Bootstrap"*.
  Angelegt wird es dort, wo dieser Modus läuft: Baseline `v6.0.0`,
  `modul-02-harness-bootstrap.md` §Brownfield-Bootstrap: Schritt-Sequenz, Detail-Tabelle
  Schritte 5–9, Schritt 8 — *„Diskrepanz-Schock: docs/plan/planning/reconciliation.md
  anlegen …"*. Der mitemittierte Planning-Index spricht es einem Greenfield-Repo zusätzlich
  ausdrücklich ab.

  ```sh
  grep -c 'Reconciliation-Register: nur im Brownfield-Bootstrap' \
    .harness/baseline/v6.0.0/regelwerk/grundlagen-harness-dateien.md   # 1
  grep -c 'docs/plan/planning/reconciliation.md` anlegen' \
    .harness/baseline/v6.0.0/regelwerk/modul-02-harness-bootstrap.md   # 1
  ```

  **Keine Erwartungswerte.**
- **Die zwei `done/`-Ablagen bleiben draußen, und zwar nach den drei Formen der
  Auswertungs-Regel — jede an ihrem eigenen Fall.**

  `harness/conventions/done/` kommt im (a)-Beleg oben ausschließlich als **Glosse** vor (Form 3):
  Eintrag der Baumzeile ist `harness/conventions/`, das *„done/ = aufgelöst"* steht rechts des `#`
  und erläutert ihn; eine eigene Zeile hat der Ort dort nicht. Die Vorlage nennt ihn daneben als
  **Ziel eines Umzugs** (Form 2) — Baseline `v6.0.0`,
  `templates/harness/conventions.template.md` §Adaptions-Block: *„ist ihr Auflösungs-Trigger
  eingetreten, wandert sie per `git mv` nach `conventions/done/`"*. Eine unbedingte Nennung, die
  die erste Kollisions-Regel greifen ließe, trägt keine der beiden Quellen.

  `docs/plan/carveouts/done/` hat in derselben Baumdarstellung ebenfalls keine eigene Zeile und
  steht in der Vorlage des mitemittierten Planning-Index als Ziel eines Umzugs (Form 2) —
  Baseline `v6.0.0`, `templates/docs/plan/planning/README.template.md` §Slices vs. Wellen:
  *„Aufgelöste Carveouts wandern **nicht** hierher, sondern in ihr eigenes
  `docs/plan/carveouts/done/` …"*. Dazu tritt die **ausdrückliche Tag-0-Aussage** der zweiten
  Kollisions-Regel: Baseline `v6.0.0`,
  `templates/docs/plan/carveouts/carveout.template.md` §Verifikation (nach Auflösung) schaltet
  ihre eigene Zeile mit einem `d-check:ignore`-Marker stumm und begründet das mit *„done/ entsteht
  erst bei erster Carveout-Auflösung"*.

  **Diese Begründung liegt in der Kommentar-Schicht — und sie zählt trotzdem.** Die Vorlage ist
  **wiederkehrend**: Sie wird nicht gestempelt, sondern liegt im Ziel unverändert im vendored Baum
  ([ADR-0005](0005-ziel-repo-distribution.md)). Und der Template-Abbau, der beim Ausfüllen alle
  HTML-Kommentare löscht, nimmt genau die `d-check:ignore`-Marker davon aus — Baseline `v6.0.0`,
  `grundlagen-harness-dateien.md` §Template-Schichtung: *„alle HTML-Kommentare gelöscht — bis auf
  die `d-check:ignore`-Marker, die Falsch-Positive unterdrücken und bleiben müssen"*. Der Satz
  überlebt damit auf beiden Wegen.

  ```sh
  sed -n '/^### Verzeichniskonvention/,/^### Template-Schichtung/p' \
    .harness/baseline/v6.0.0/regelwerk/grundlagen-harness-dateien.md \
    | grep -cE '^harness/conventions/done/|^docs/plan/carveouts/done/'          # 0
  grep -c 'wandert sie per `git mv` nach' \
    .harness/baseline/v6.0.0/templates/harness/conventions.template.md          # 1
  grep -c 'sondern in ihr eigenes `docs/plan/carveouts/done/`' \
    .harness/baseline/v6.0.0/templates/docs/plan/planning/README.template.md    # 1
  grep -c 'd-check:ignore (done/ entsteht erst bei erster Carveout-Auflösung)' \
    .harness/baseline/v6.0.0/templates/docs/plan/carveouts/carveout.template.md # 1
  tr '\n' ' ' < .harness/baseline/v6.0.0/regelwerk/grundlagen-harness-dateien.md \
    | grep -c 'alle HTML-Kommentare gelöscht\*\* — bis auf die `d-check:ignore`-Marker'   # 1
  ```

  **Keine Erwartungswerte.** Was daraus für die stehenbleibende Fundstelle im Planning-Index
  folgt — Marker, Umformulierung oder etwas Drittes —, ist **Umsetzung** und steht hier nicht.

  **Diese Festlegung berührt eine Zusage von `slice-190`** — die eines Plans, nicht die des
  Lastenhefts. Sein **DoD (1)** verlangt `docs/plan/carveouts/done` namentlich für die
  Struktur-Liste des Emitters; diese Entscheidung trägt den Ort nicht, der DoD-Punkt ist in seiner
  heutigen Fassung mit ihr **nicht erfüllbar**. Dieselbe Prämisse tragen drei weitere Stellen:
  **DoD (3)** mit der Fundstellen-Zahl nach DoD (1) und (2), §1 mit *„Nur die ersten zwei sind
  unstrittig"* und die `structureGitkeeps()`-Zeile der Plan-Tabelle in §3 mit *„die zwei fehlenden
  Verzeichnisse"*. **Nicht** betroffen ist der §3-Satz, `docs/plan/carveouts/done` sei *„ein
  Carveout-Ordner und damit gedeckt"*: Er beantwortet die **Change-Request**-Frage, nicht die
  **Anlege**-Frage, und bleibt richtig.

  ```sh
  P='docs/plan/planning/*/slice-190-*.md'
  sed -n '/^## 1\. Ziel/,/^## 2\./p' $P | grep -c 'Nur die ersten zwei sind unstrittig' # 1
  sed -n '/^## 1\. Ziel/,/^## 2\./p' $P | grep -c 'Fundstellen stehen, alle aus dem'    # 1
  sed -n '/^## 2\. Definition of Done/,/^## 3\./p' $P \
    | grep -c 'docs/plan/carveouts/done'                                                # 1
  sed -n '/^## 3\./,/^## 4\./p' $P | grep -c 'die zwei fehlenden Verzeichnisse'         # 1
  ```

  **Keine Erwartungswerte**; der Glob statt der Pfad-Adresse nach
  [`AGENTS.md`](../../../AGENTS.md) §3.11. **Die Menge ist nicht geschlossen** — gemessen sind
  diese vier Stellen, nicht die Vollständigkeit über den ganzen Plan. Der Plan hält den Fall
  selbst offen: sein §6 verlangt *„Marker **oder** Verzeichnis, nicht beides und nicht keines"* —
  diese Festlegung schließt den zweiten Weg, der erste bleibt offen und ist Umsetzung. **Was aus
  der Kollision folgt, schreibt der Planner** (§3.10); Folgepflicht 4 benennt die Übergabe.
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
| **E — gewählt: Eigenschaft statt Aufzählung (drei kumulative Bedingungen) + tool-autorierte Register-`README.md` als `skip-if-present`** | Der emittierte Stand hört auf, sich selbst zu widersprechen; die Regel gilt für den nächsten Ort ohne neue Runde; sie bleibt eng, und zwar aus drei Gründen statt aus einem: die drei Bedingungen gelten kumulativ, (a) wird nach einer **geschriebenen** Auswertungs-Regel gemessen — unbedingte Nennung, drei benannte Formen, an denen sie scheitert, zwei Kollisions-Regeln —, und sie hebt keine der drei übrigen Klassen-Regeln desselben [`LH-FA-02`](../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)-Absatzes auf — die derivativen Indexe behalten ihre (Festlegung 4), das Reconciliation-Register und die zwei `done/`-Ablagen scheitern an (a); die Herkunfts-Klasse ist eine bereits geführte, nicht eine neue | Legt einen Rang-1-Satz aus, ohne dass der Auftraggeber ihn geändert hätte — wer die Aufzählung als Menge liest, sieht darin eine Vertragsdehnung. Die drei Bedingungen sind **Urteil**, nicht Muster: kein Sensor prüft (a), und wer *„nennt ihn im Indikativ"* weit auslegt, kann den Bestand ausdehnen. Sie entscheiden zudem nur das *Ob* eines Ortes — welcher **Träger** ihn hält, bleibt eine zweite Frage, die sie nicht beantworten (Festlegung 2 beantwortet sie für ihren einen Fall eigens). Und die emittierte `README.md` ist eine zweite Fassung einer Aussage des Regelwerks — sie kann gegen `modul-06-roadmap.md` driften, ohne dass etwas rot wird |

## Konsequenzen

- **Positiv:** Ein frisch gebootstrapptes Repo trägt die Orte, die sein eigener mitgelieferter
  Text nennt. Der Adopter, der `/plan-welle` folgt, findet, wohin er geschickt wird.
- **Positiv, mit benannter Grenze:** Die Frage ist als **Kriterium** entschieden, nicht als
  Einzelfall — *ob* der nächste Ort derselben Klasse aufzunehmen ist, beantworten die drei
  Bedingungen samt der Auswertungs-Regel zu (a), ohne eigene Runde. **Was sie nicht beantworten,
  ist der Träger:** Für ein **leeres** Struktur-Verzeichnis bleibt das `.gitkeep` aus
  [`LH-FA-02`](../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) die Vorgabe;
  ein Ort, dessen Form eine Datei mit Inhalt verlangt — wie ihn Festlegung 2 für **einen** Fall
  entscheidet —, ist eine eigene Frage mit eigener Begründung und eigener Einordnung. Für die
  spart dieses Kriterium keine Runde.
- **Positiv:** Der Zweck von
  [`LH-FA-02`](../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) —
  *out-of-the-box gate-sicher* — wird für ein Ziel mit aktivem `codepaths` überhaupt erst
  erreichbar. Erreicht ist er damit nicht: das entscheidet der Slice, der die emittierte
  Modul-Liste anfasst (`slice-073`).
- **Negativ:** Festlegung 1 hat **keinen Sensor** und kann keinen bekommen — Bedingung (a) ist
  ein Urteil über einen Text, kein Muster. Die Schranke gegen eine ausufernde Anwendung ist
  prozessual: die drei Bedingungen gelten kumulativ, die Auswertungs-Regel zu (a) steht
  geschrieben, und der Reviewer prüft beides.
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
- **Folgepflicht 4 (Planner):** Festlegung 4 trägt `docs/plan/carveouts/done` **nicht**, und
  **DoD (1)** von `slice-190` verlangt ihn namentlich. Was daraus für Schnitt und
  Abnahmekriterien dieses Slice folgt, ist Planungs-Arbeit
  ([`AGENTS.md`](../../../AGENTS.md) §3.10); diese Datei ändert sie nicht und schlägt keinen
  Wortlaut vor. Sie benennt die Kollision, solange sie noch ein Satz ist.
- **Folgepflicht 5 (der annehmende Lauf):** Fünf Auflagen binden den Übergang nach `Accepted`;
  **keine** hat einen Wächter — kein Modul des Doku-Gates liest sie
  (`grep -n '^modules:' .d-check.yml`). (1) **Kein tag-gepinnter Baseline-Pfad als Markdown-Link**
  ([ADR-0016](0016-verweis-traegt-tag-und-zitat.md) Festlegung 3 a). (2) **Keine neue
  Aussage über einen laufenden Bestand** — mit Zahl wie ohne — **und keine Änderung, die eine
  stehende falsch macht**. Die Trennlinie ist das **Subjekt**: Eine Aussage über einen benannten
  abgeschlossenen Vorgang ist durch ihr Subjekt datiert und bleibt wahr; eine über einen Bestand,
  den der Prozess fortschreibt, ist es nicht — gleich ob dieser Bestand diese Datei ist oder ein
  **fremdes** Artefakt, dessen Zustand derselbe Commit ändert. Unter das zweite Verbot fällt
  namentlich das Urteil über die tag-gepinnten Baseline-Nennungen: Eine Nennung außerhalb eines
  Kommando-Operanden machte es falsch, und [ADR-0016](0016-verweis-traegt-tag-und-zitat.md)
  Festlegung 2 nimmt den lokalen Präfix ohnehin aus der Beleg-Form heraus. (3) **Kein
  Markdown-Link auf ein Ziel, dessen Ort ein vom Prozess vorgeschriebener Vorgang bewegt:**
  Gefragt wird je Ziel nach dieser Eigenschaft und nicht nach dem Baum —
  [`AGENTS.md`](../../../AGENTS.md) §3.11 bindet an *wandert auf Anweisung* und verwirft die
  Aufzählung der Bäume —, und verlangt ist dann die **Kennung** statt der Pfad-Adresse. Unter die
  Eigenschaft fallen unter anderem der `git mv` des Planning-Lifecycle, die Archivierung einer
  Welle, die Auflösung eines Carveouts und der `git mv` eines Eintrags des Adaptions-Blocks;
  geprüft wird gegen die Eigenschaft, nicht gegen diese vier. (4) **Kein Link-Ziel mit `)` darin
  und kein über einen Zeilenumbruch gesetzter Link.** Das Verbot gilt beiden, ihre Wirkung ist
  verschieden und steht je Fall: Der **Umbruch-Link** lässt die drei Zählungen auseinanderfallen,
  deren **Gleichheit** die Sonden-Aussage trägt — ihn zeigt die Sonde an. Ein **Ziel mit `)`
  darin** lässt die drei gleich und kürzt statt dessen die **Extraktion**, weil `[^)]+` an der
  ersten Klammer endet; in die Pfad-Menge, über die die Erschöpfungs-Aussage Ziel für Ziel
  läuft, gerät dann der Teil vor ihr. Die drei Zählungen prüfen die **Vollzähligkeit** der
  Treffer, nicht die **Richtigkeit** der Ziele — der zweite Fall steht als Verbot, weil keine
  von ihnen ihn anzeigt. (5) **Keine rohe
  Link-Kopf-Sequenz in einem Code-Span:** Sie verfälscht beide Sonden und ist gate-unsichtbar.
  Dazu, außerhalb dieser Datei: Der ADR-Index ([`README.md`](README.md)) wird beim Übergang auf
  den neuen Status nachgezogen — nach
  [ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md) gehört das
  derivative Register der Rolle seines Originals, der Nachzug liegt also im selben
  Architect-Commit ([`AGENTS.md`](../../../AGENTS.md) §5).

## Fitness Function (falls maschinell prüfbar)

| Tooling | Regel | Make-Target |
|---|---|---|
| Go-Test, `TestTemplates_EmittierterBestandVollstaendig` | der emittierte Baum ist **mengengleich** zur erwarteten Liste — ein hinzugefügter Ort ohne `want`-Eintrag und ein `want`-Eintrag ohne Emission färben beide rot | `make test` (in `make gates`) |
| `make full-smoke` | das frisch gebootstrappte Ziel fährt seinen zusammengeführten `make gates` grün — die Zusage *out-of-the-box gate-sicher* wird am Ziel gemessen, nicht hier behauptet | `make full-smoke` |

**Nicht gebaut, und hier benannt statt behauptet — drei Stück.** **Festlegung 1** hat keinen
Sensor: Bedingung (a) fragt, ob ein Text einen Ort im Indikativ führt, und das ist ein Urteil.
**Die Deckung zwischen emittiertem Text und emittiertem Bestand** hat ebenfalls keinen: Das
Doku-Gate des Ziels fährt `codepaths` heute nicht, und im Dogfood liegt der emittierte Bestand
außerhalb des Prüfbereichs. **Und keine Aussage dieser Datei über den Inhalt von `slice-190` ist
gegen jenen Inhalt gedeckt:** Kein Modul des Doku-Gates hält einen Satz dieser Datei gegen den
Inhalt einer Plandatei (`grep -n '^modules:' .d-check.yml`), und die Plandatei ist hier über einen
Glob genannt statt über eine Pfad-Adresse ([`AGENTS.md`](../../../AGENTS.md) §3.11) — sie ist
damit nicht einmal Ziel einer Referenz-Prüfung. **Unter diese dritte Lücke fällt jede Aussage
der Festlegung 4 über den Plan**; was sie hält, sind die abgedruckten Kommandos und das Review,
kein Lauf. Alle drei liegen im Feedforward-Quadranten
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
- **Wenn ein Baseline-Sprung eine der zwei `done/`-Ablagen oder das Reconciliation-Register
  **unbedingt** führt** *(am vendored Baum ablesbar)*: dann trägt (a) für sie, und die Ausschlüsse
  in Festlegung 4 sind neu zu messen — nicht stillschweigend beizubehalten.
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
| 2026-09-06 | **Proposed** | `slice-190` |
| 2026-09-06 | **Accepted** | Entscheidung des Auftraggebers vom 2026-09-06, vollzogen in der Architect-Rolle. |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0037` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).
