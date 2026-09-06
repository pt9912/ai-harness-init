# ADR-0037: Der Bootstrap stellt den Tag-0-Zustand des Prozesses her — die Struktur-Aufzählung in `LH-FA-02` nennt Instanzen, nicht die Menge

**Status:** Proposed

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
[ADR-0034](0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
(Festlegung 1 — die Ablage besteht aus `README.md` plus je Beobachtung einem Verzeichnis;
Festlegung 5 — die Ablage ist ortsfest),
[`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage) (eine Abweichung von der
Baseline schuldet einen Eintrag — diese Entscheidung setzt keine),
[`MR-015`](../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
(die Change-Request-Frage bei Personalunion — Festlegung 1 beantwortet sie als *Erfüllung*),
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
der Bestand ist keine Norm. Sie wird durch diese ADR an einem Punkt falsch. **Umgeschrieben wird
sie deshalb nicht:** Ein Historie-Eintrag beschreibt einen vergangenen Stand; was das Handbuch
**im Präsens** über den Bestand sagt, zieht der Slice nach, der seinen Bestandsbaum schreibt
(`slice-191`). Diese Datei tut weder das eine noch das andere — dieselbe Zuweisung steht in
§Konsequenzen.

### Zwei geprüfte Gegen-Gründe, beide tragen nicht

- **[ADR-0007](0007-bootstrap-phasen.md) (Idempotenz-Klassen)** rechtfertigt die Nicht-Anlage
  nicht. Sie sagt, *wie* eine emittierte Datei beim Re-Lauf behandelt wird — *„im Zweifel gilt
  `skip-if-present`"* —, und beantwortet damit eine andere Frage als *ob* sie beim ersten Lauf
  entsteht. Für die eine neue Datei liefert sie die Klasse (Festlegung 3), nicht ein Veto.
- **[ADR-0034](0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)**
  ebenso wenig: Ihr Geltungsbereich ist der Dogfood, und dort schreibt sie die Ablage samt
  `README.md` gerade **vor**. Über die emittierte Ebene sagt sie nichts — die Ebenen-Trennung
  bleibt bestehen, und deshalb braucht die emittierte Hälfte diese eigene Entscheidung.

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

**Wie (a) ausgewertet wird — die Regel steht hier, nicht in ihrem Anwendungsfall.** Maßgeblich
ist, ob der Text den Ort **unbedingt** führt. Trägt die Nennung einen Modus- oder
Bedingungs-Zusatz (*„nur im Brownfield-Bootstrap"*), oder steht sie in einer Wenn-dann-Form, die
ein Ereignis voraussetzt (*„ist ihr Auflösungs-Trigger eingetreten, wandert sie … nach
`conventions/done/`"*), dann führt sie den Ort **nicht für ein frisches Repo**, und (a) trägt
nicht — beide Beispiele sind Baseline `v6.0.0` und in Festlegung 4 belegt. Die Disjunktion
*„Regelwerk **oder** mitemittierter Text"* ändert daran nichts: Sie eröffnet zwei **Quellen**,
nicht zwei Maßstäbe — ein zweiter Text hilft nur, wenn **er** den Ort unbedingt führt.

Die Aufnahme eines Ortes, der die drei erfüllt, ist **Erfüllung** von
[`LH-FA-02`](../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) und
[`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen), **kein Change Request**
([`MR-015`](../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler),
seit `v5.12.0` in der Baseline —
[`MR-036`](../../../harness/conventions.md#mr-036--die-change-request-regel-bei-personalunion-steht-jetzt-in-der-adoptierten-baseline)):
keine Anforderung ändert sich, keine Zusage wird zurückgenommen, und die Zusage *aus dem Nichts
wird nichts emittiert*
([`spec/lastenheft.md §5`](../../../spec/lastenheft.md#5-globale-out-of-scope-punkte)) bleibt
unangetastet, weil (a) die Quelle benennt.

**Die drei übrigen Klassen-Klammern desselben Absatzes bleiben unberührt.** Die
Singleton-Klammer *„(authored-once: …)"* zählt **template-abgeleitete** Dateien — die
Register-`README.md` ist keine, der vendored Baum führt für sie keine Vorlage, und ihre
Herkunfts-Klasse ist die tool-autorierte aus
[`LH-FA-03`](../../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7) /
[ADR-0006](0006-durchsetzung-commands-tool-als-quelle.md). Die Klammer der **Wiederkehrenden**
und die der **derivativen Index-Sichten** tragen im selben Absatz je ihre eigene Klassen-Regel;
Festlegung 4 lässt beide stehen. Festlegung 1 legt eine Klammer aus und hebt keine
Klassen-Regel auf.

**„Unberührt" heißt: diese Entscheidung legt sie nicht aus — nicht, dass sie als geschlossene
Menge zu lesen wären.** Für die Singleton-Klammer trägt der Ist-Stand die Instanzen-Lesart
bereits: Sie nennt Root-`README.md`, das der Emitter nicht schreibt, und sie nennt drei Dateien
nicht, die er schreibt — `docs/plan/planning/README.md` und die zwei `.harness/skills/*.md`.

```sh
sed -n '/^func TestTemplates_EmittierterBestandVollstaendig/,/^}/p' \
  internal/emit/templates_test.go | grep -c '^[[:space:]]*"README\.md",'   # 0
sed -n '/^func TestTemplates_EmittierterBestandVollstaendig/,/^}/p' \
  internal/emit/templates_test.go \
  | grep -cE '"(docs/plan/planning/README\.md|\.harness/skills/)'          # 3
```

**Keine Erwartungswerte.** Die Lesart wird hier also nicht erfunden; sie wird für **eine** Klammer
ausgesprochen.

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
**ob** ein Ort entsteht; **womit** er gehalten wird, sagt
[`LH-FA-02`](../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) mit `.gitkeep`
als Vorgabe. Diese Festlegung weicht davon für **einen** benannten Ort ab und begründet die
Abweichung im Satz davor; die drei Bedingungen begründen sie nicht und könnten es nicht.

**Die Datei ist keine Kopie des Dogfood-Textes.** Der hiesige Text ist repo-spezifisch (er
zitiert Einträge des eigenen Adaptions-Blocks); emittiert wird eine generische Fassung, die die
Ablage-Form, die Schreib-/Lese-Rollen, die Beleg-Form und die drei Ausgänge nennt und sonst
nichts.

**3. Idempotenz-Klasse: `skip-if-present`** ([ADR-0007](0007-bootstrap-phasen.md)
Entscheidung 3). Sie folgt aus deren eigener Regel — *„jede emittierte Datei ist **genau einer**
Klasse zugeordnet; im **Zweifel gilt `skip-if-present`** (nie Adopter-Inhalt clobbern — der
sichere Default)"* —, und der Zweifel besteht, sobald ein Adopter den Text an sein Repo anpasst.
**Aus dem Bestand wird die Klasse nicht begründet:** In diesem Repo trägt die Datei zwei Commits,
beide aus dem Slice, der sie anlegte (`git log --oneline --follow --
docs/plan/planning/observations/README.md` → **2** Zeilen, kein Erwartungswert), und mit dem
Register wachsen kann sie ohnehin nicht — der Index ist verboten
([ADR-0034](0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
Festlegung 1). Ein `.gitkeep` einer Struktur-Ablage bleibt davon unberührt und behält seine
bisherige Behandlung.

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

  **Zwei Gründe tragen den Ausschluss nicht und stehen darum nicht daneben.** **(c)** trägt ihn
  nicht: der Emit-Pfad nimmt jedem Markdown-Link, dessen Ziel-Pfad einen `<…>`-Platzhalter trägt,
  die Link-Syntax, und beide Index-Vorlagen tragen genau einen solchen Link und sonst keinen — ein
  Index-Skelett röte ein frisches `docs-check` heute nicht mehr. Und ein Satz der Art *„ein Index
  ist eine Datei und fällt darum aus dem Subjekt"* trägt ihn ebenso wenig: Festlegung 2 legt einen
  Ort gerade über eine **Datei mit Inhalt** an. Was die Fälle trennt, ist nicht Datei gegen
  Verzeichnis, sondern ob der Ort ohne den Bootstrap entsteht — und das ist Bedingung (b), die
  bereits dasteht.

  ```sh
  sed -n '/^func structureGitkeeps/,/^}/p' internal/emit/templates.go \
    | grep -cE '"docs/plan/(adr|carveouts)"'                                    # 2
  grep -c 'body = NeutralizePlaceholderLinks(body)' internal/emit/templates.go  # 1
  grep -oE '\]\([^)]*\)' \
    .harness/baseline/v6.0.0/templates/docs/plan/adr/README.template.md \
    .harness/baseline/v6.0.0/templates/docs/plan/carveouts/README.template.md
  # je genau eine Zeile, beide mit einem <…>-Platzhalter im Ziel-Pfad
  ```

  **Keine Erwartungswerte.**
- Das **Reconciliation-Register** des Brownfield-Rückbaus bleibt **unemittiert** (Vorlage:
  [`reconciliation.template.md`](../../../.harness/baseline/v6.0.0/templates/docs/plan/planning/reconciliation.template.md)).
  Es scheitert an (a), und der Beleg steht in derselben Quelle und derselben Form wie der von
  `harness/conventions/`: Baseline `v6.0.0`, `grundlagen-harness-dateien.md`
  §Verzeichniskonvention führt es mit einem **Modus-Zusatz** —
  *„docs/plan/planning/reconciliation.md # Reconciliation-Register: nur im Brownfield-Bootstrap"*.
  Angelegt wird es dort, wo dieser Modus läuft: Baseline `v6.0.0`,
  `modul-02-harness-bootstrap.md` §Brownfield-Bootstrap: Schritt-Sequenz, Detail-Tabelle
  Schritte 5–9, Schritt 8 — *„Diskrepanz-Schock: docs/plan/planning/reconciliation.md
  anlegen"*. Der mitemittierte Planning-Index spricht es einem Greenfield-Repo zusätzlich
  ausdrücklich ab.

  ```sh
  grep -c 'Reconciliation-Register: nur im Brownfield-Bootstrap' \
    .harness/baseline/v6.0.0/regelwerk/grundlagen-harness-dateien.md   # 1
  grep -c 'docs/plan/planning/reconciliation.md` anlegen' \
    .harness/baseline/v6.0.0/regelwerk/modul-02-harness-bootstrap.md   # 1
  ```

  **Keine Erwartungswerte.**
- **Die zwei `done/`-Ablagen bleiben draußen, und zwar nach derselben Auswertungs-Regel.**
  `harness/conventions/done/` steht im (a)-Beleg oben mit im Zitat (*„done/ = aufgelöst"*), und
  die Vorlage nennt es in der Wenn-dann-Form — Baseline `v6.0.0`,
  `templates/harness/conventions.template.md` §Adaptions-Block: *„ist ihr Auflösungs-Trigger
  eingetreten, wandert sie per `git mv` nach `conventions/done/`"*. `docs/plan/carveouts/done/`
  steht in der Vorlage des mitemittierten Planning-Index ebenso als Ziel eines Umzugs —
  `templates/docs/plan/planning/README.template.md` §Slices vs. Wellen: *„Aufgelöste Carveouts
  wandern **nicht** hierher, sondern in ihr eigenes `docs/plan/carveouts/done/`"* —, und
  `templates/docs/plan/carveouts/carveout.template.md` §Verifikation (nach Auflösung) schaltet
  ihre eigene Zeile mit einem Marker stumm und begründet das mit *„done/ entsteht erst bei erster
  Carveout-Auflösung"*. Beide sind damit als **Ziel eines Umzugs** genannt, den ein frisches Repo
  nicht hinter sich hat; (a) trägt sie nicht. Was daraus für die stehenbleibende Fundstelle im
  Planning-Index folgt — Marker, Umformulierung oder etwas Drittes —, ist **Umsetzung** und steht
  hier nicht.

  ```sh
  grep -c 'wandert sie per `git mv` nach' \
    .harness/baseline/v6.0.0/templates/harness/conventions.template.md          # 1
  grep -c 'sondern in ihr eigenes `docs/plan/carveouts/done/`' \
    .harness/baseline/v6.0.0/templates/docs/plan/planning/README.template.md    # 1
  grep -c 'done/ entsteht erst bei erster Carveout-Auflösung' \
    .harness/baseline/v6.0.0/templates/docs/plan/carveouts/carveout.template.md # 1
  ```

  **Keine Erwartungswerte.**
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
| **E — gewählt: Eigenschaft statt Aufzählung (drei kumulative Bedingungen) + tool-autorierte Register-`README.md` als `skip-if-present`** | Der emittierte Stand hört auf, sich selbst zu widersprechen; die Regel gilt für den nächsten Ort ohne neue Runde; sie bleibt eng, und zwar aus drei Gründen statt aus einem: die drei Bedingungen gelten kumulativ, (a) wird nach einer **geschriebenen** Auswertungs-Regel gemessen (unbedingte Nennung), und sie hebt keine der drei übrigen Klassen-Regeln desselben [`LH-FA-02`](../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)-Absatzes auf — die derivativen Indexe behalten ihre (Festlegung 4), das Reconciliation-Register und die zwei `done/`-Ablagen scheitern an (a); die Herkunfts-Klasse ist eine bereits geführte, nicht eine neue | Legt einen Rang-1-Satz aus, ohne dass der Auftraggeber ihn geändert hätte — wer die Aufzählung als Menge liest, sieht darin eine Vertragsdehnung. Die drei Bedingungen sind **Urteil**, nicht Muster: kein Sensor prüft (a), und wer *„nennt ihn im Indikativ"* weit auslegt, kann den Bestand ausdehnen. Sie entscheiden zudem nur das *Ob* eines Ortes — welcher **Träger** ihn hält, bleibt eine zweite Frage, die sie nicht beantworten (Festlegung 2 beantwortet sie für ihren einen Fall eigens). Und die emittierte `README.md` ist eine zweite Fassung einer Aussage des Regelwerks — sie kann gegen `modul-06-roadmap.md` driften, ohne dass etwas rot wird |

## Konsequenzen

- **Positiv:** Ein frisch gebootstrapptes Repo trägt die Orte, die sein eigener mitgelieferter
  Text nennt. Der Adopter, der `/plan-welle` folgt, findet, wohin er geschickt wird.
- **Positiv, mit benannter Grenze:** Die Frage ist als **Kriterium** entschieden, nicht als
  Einzelfall — *ob* der nächste Ort derselben Klasse aufzunehmen ist, beantworten die drei
  Bedingungen samt der Auswertungs-Regel zu (a), ohne eigene Runde. **Was sie nicht beantworten,
  ist der Träger:** Vorgabe bleibt das `.gitkeep` aus
  [`LH-FA-02`](../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3), und eine
  Abweichung davon — wie sie Festlegung 2 für **einen** Ort trifft — ist eine eigene Frage mit
  eigener Begründung. Für die spart dieses Kriterium keine Runde.
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
| 2026-09-06 | **Proposed** | Architect-Lauf zu zwei Fragen aus `slice-190`: der **Change-Request-Frage** aus §3 — die §4 am 2026-09-06 neben dem WIP-Limit als Bedingung für `open → next` führte — und dem **Register-Ort** aus §6, den derselbe Plan als *„Entscheidung des Architect, kein Code-Zug"* führt. Welche Risiken §6 mit welchem Ausgang schließt, sagt diese Datei nicht (Folgepflicht 3). Anlass ist die vom Emitter selbst benannte Grenze (*„Ob einer dazukommt, entscheidet der Architect"*) und die Klasse [`BEO-ALL/emittierte-vorlagen-klassifikation-ohne-traeger`](../planning/observations/BEO-ALL/emittierte-vorlagen-klassifikation-ohne-traeger/observation.md), deren abgeleiteter Zähler am 2026-09-06 bei `ls docs/plan/planning/observations/BEO-ALL/emittierte-vorlagen-klassifikation-ohne-traeger/evidence/*.md \| wc -l` → **2** steht — **kein Erwartungswert** ([`MR-051`](../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung) Setzung 2); der Beleg für diesen Vorgang fällt mit der Slice-Closure, nicht mit dieser Datei ([`AGENTS.md`](../../../AGENTS.md) §3.10). Geprüft und als nicht tragend verworfen sind die zwei möglichen Gegen-Gründe [ADR-0007](0007-bootstrap-phasen.md) und [ADR-0034](0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md); die Aufzählungs-Frage ist an drei Messungen entschieden, nicht an der Lesart |
| 2026-09-06 | Überarbeitet, weiter **Proposed** | Reviewer-Runde `2026-09-06-adr-0037-konsistenz-review.md`, Verdikt *Konsistenz NICHT BESTÄTIGT* — **ohne Einwand gegen die Entscheidung selbst**: alle elf abgedruckten Kommandos reproduzieren, beide Kern-Argumentationen halten dem Volltext stand, und die zwei Gegenbeispiele fallen nicht unter die Eigenschaft. Die **fünf** blockierenden MEDIUM sind im `Proposed`-Fenster behoben, jede Zahl dieser Runde neu gefahren. **M-1:** Der Ausschluss der derivativen Indexe hing an Bedingung (c); der Emit-Pfad nimmt jedem Link mit `<…>` im Ziel-Pfad die Link-Syntax (`NeutralizePlaceholderLinks`), und beide Index-Vorlagen tragen genau einen solchen Link — (c) trägt nicht. Festlegung 4 stand damit auf zwei gemessenen Gründen (Subjekt-Grenze *Ort statt Inhalt*; die eigene Klassen-Regel desselben [`LH-FA-02`](../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)-Absatzes), und die Enge-Zusage von Alternative E nannte dieselben. **M-2:** Die Antwort auf die zweite Frage nannte für keine der drei Bedingungen eine Fundstelle; sie stehen jetzt einzeln, mit Kommando, Regelwerks-Zitat nach [ADR-0016](0016-verweis-traegt-tag-und-zitat.md) Festlegung 2 und einer Gegenprobe, die die Null von (b) gegen einen leeren Ausschnitt absichert. **M-3:** *„die zwei Struktur-Aufzählungen"* bestimmte keine Menge — der Absatz trägt **vier** Klassen-Klammern; ausgelegt wird genau eine, die der leeren Struktur-Verzeichnisse, und für die drei übrigen steht, warum sie unberührt bleiben. Titel, Abschnittsüberschrift, Entscheidungssatz und der ADR-Index sind auf den Singular nachgezogen. **M-4:** Die Zeile darüber beschrieb den Anlass als *zwei offene Risiken, die den Trigger sperren*; gemessen führte §4 am 2026-09-06 neben dem WIP-Limit die Change-Request-Frage aus §3, und §6 trug am selben Tag **sechs** Risiken ohne Ausgang (`sed -n '/^## 6\./,/^## 7\./p' docs/plan/planning/*/slice-190-*.md \| grep -c 'Ausgang:\*\* <offen>'` → **6**, kein Erwartungswert; der Glob statt der Pfad-Adresse nach [`AGENTS.md`](../../../AGENTS.md) §3.11). Sie nennt jetzt die zwei beantworteten Fragen und keine Zahl über fremden Stand. **M-5:** Beide Messwerte tragen ihr Kommando — die Lifecycle-Zahl in beiden Lesarten (vier Ebenen im Regelwerk, drei `.gitkeep` im Emitter) und der Register-Zähler mit Stand, Ableitungs-Kommando und *kein Erwartungswert*; [`MR-051`](../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung) steht dafür jetzt im `Bezug`. **L-1 bis L-4 sowie INFO-2 und INFO-3 sind hier nicht behoben** — jene Runde führt keinen von ihnen als blockierend; **INFO-1 ist mitgezogen**, weil sein Kommando ohnehin neu gefahren wurde und jetzt `cmd/` mitliest. Der Statuswechsel bleibt offen: eine zweite Runde prüft diese Korrektur |
| 2026-09-06 | Überarbeitet, weiter **Proposed** | Reviewer-Runde `2026-09-06-adr-0037-konsistenz-review-runde-2.md`, Verdikt *Konsistenz NICHT BESTÄTIGT* — die fünf MEDIUM der Vorrunde sind am Ist-Stand als behoben nachgemessen, alle 23 abgedruckten Kommandos reproduzieren, und gegen die Entscheidung selbst steht weiterhin **kein** Befund. Behoben sind hier **beide** blockierenden MEDIUM **und jeder übrige Posten**; maßgeblich war je die bindende Quelle, nicht das Severity-Label. **M-1:** Die Aussage über das Reconciliation-Register trägt jetzt die Form aus [ADR-0016](0016-verweis-traegt-tag-und-zitat.md) Festlegung 2 — Tag, Regelwerks-Datei, Abschnitt, Zitat —, die deren Träger (a) zur Vorbedingung des `Accepted`-Übergangs macht; der Posten stand seit Runde 1 als L-3 und war allein wegen des Labels liegen geblieben. **M-2:** Der Grund *„ein Index ist eine Datei in einem angelegten Ort"* ist **gestrichen** — symmetrisch angewandt hätte er Festlegung 2s eigenen Gegenstand ausgeschlossen, deren Träger eine Datei mit Inhalt ist. Den Ausschluss der derivativen Indexe trägt jetzt allein die Klassen-Regel desselben [`LH-FA-02`](../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)-Absatzes; daneben steht, dass Festlegung 1 für sie gegenstandslos ist, und dass sie nur das *Ob* eines Ortes entscheidet, nicht seinen Träger. Konsequenz 2, Festlegung 2 und die Contra-Zelle von Alternative E nennen diese Grenze. **L-1, L-3 und Runde-1-L-4:** Die Auswertungs-Regel zu (a) steht jetzt geschrieben — eine Nennung mit Modus- oder Bedingungs-Zusatz führt den Ort nicht für ein frisches Repo, und die Disjunktion eröffnet zwei Quellen, nicht zwei Maßstäbe. Nach ihr bleiben `harness/conventions/done/` und `docs/plan/carveouts/done/` draußen, je mit Zitat und Kommando; die Umsetzungs-Frage zur stehenbleibenden Fundstelle bleibt beim Slice. **L-2:** Die zweite Aussage über den fremden Plan-Stand ist datiert und trägt keine Zahl mehr, in beiden Geschichte-Zeilen. **Runde-1-L-1:** Festlegung 3 begründet die Idempotenz-Klasse aus der Zweifels-Regel von [ADR-0007](0007-bootstrap-phasen.md) statt aus dem Bestand. **Runde-1-L-2:** §Kontext und §Konsequenzen weisen den Handbuch-Nachzug jetzt gleich zu. **INFO-1** (Beleg-Kommando auf die Funktion des Mengen-Vergleichs verengt), **INFO-2** (Abschnittsname und Rumpf-Lage der Vorlagen-Hälfte), **INFO-3** (was *„unberührt"* heißt, mit Messung an der Singleton-Klammer), **INFO-4** (die widersprüchliche Halbaussage über INFO-1) und **INFO-5** (Zitat-Reihenfolge der zwei Emitter-Absätze; `Bezug` um [ADR-0016](0016-verweis-traegt-tag-und-zitat.md), [`MR-015`](../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) und [`MR-036`](../../../harness/conventions.md#mr-036--die-change-request-regel-bei-personalunion-steht-jetzt-in-der-adoptierten-baseline) ergänzt, [ADR-0005](0005-ziel-repo-distribution.md) im Rumpf verankert) sind mitgezogen. Ein sechster Re-Evaluierungs-Trigger fängt den Fall, dass ein Baseline-Sprung einen der drei ausgeschlossenen Orte unbedingt führt. **Aus diesem Report bleibt nichts offen.** Der Statuswechsel bleibt es: er braucht eine Runde mit tragendem Verdikt. Das wiederkehrende Muster beider Runden — *das Kriterium verspricht eine Reichweite, die sein geschriebener Text nicht hat*, dritte Wiederholung — ist als Steering-Loop-Signal benannt; seine Register-Zuordnung fällt bei der Slice-Closure, nicht hier ([`AGENTS.md`](../../../AGENTS.md) §3.10) |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0037` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).
