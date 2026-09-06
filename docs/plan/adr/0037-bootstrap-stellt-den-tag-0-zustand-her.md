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

**Wie (a) ausgewertet wird — die Regel steht hier, nicht in ihrem Anwendungsfall.** (a) fragt nach
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

**Das Wort *Existenz* grenzt die zweite Regel gegen Form 2 ab, und die Grenze ist tragend.** Die
Glosse zu Form 2 sagt, ein Text über das *Wodurch* sage damit etwas über das *Vorher*. Griffe die
zweite Regel schon daran, entkräftete jede Ziel-Nennung jede unbedingte — und die erste Regel sagt
das Gegenteil; zwei Regeln trügen dasselbe Prädikat mit entgegengesetzter Wirkung. Form 2
disqualifiziert deshalb **die Nennung, in der sie steht**, und trägt nicht über sie hinaus; die
zweite Kollisions-Regel greift allein an einer Aussage über die Existenz des Ortes selbst.

**Der Fall ist nicht konstruiert.** Der Lifecycle-Ordner `done/` — ein Verzeichnis und damit
ortsfest, als Pfad also nach [`AGENTS.md`](../../../AGENTS.md) §3.11 zulässig — trägt in der
Verzeichniskonvention eine eigene, zusatzfreie Zeile: Baseline `v6.0.0`,
`grundlagen-harness-dateien.md` §Verzeichniskonvention, *„docs/plan/planning/done/ #
abgeschlossene Slices"*. Und die mitemittierte `slice.template.md` nennt dieselbe Ablage als Ziel
eines `git mv` — Baseline `v6.0.0`, `templates/docs/plan/planning/slice.template.md`, Kopf-Feld
**Lifecycle**, das den Template-Abbau überlebt: *„Der Zustand dieses Slice ist das Verzeichnis, in
dem diese Datei liegt … Er wechselt nur durch `git mv`"*. Nach der ersten Regel ist (a) erfüllt,
und der Bootstrap legt den Ort an; ohne die Abgrenzung oben gäbe dasselbe Kriterium hier zwei
Antworten.

```sh
grep -c '^docs/plan/planning/done/' \
  .harness/baseline/v6.0.0/regelwerk/grundlagen-harness-dateien.md            # 1
grep -c 'wechselt nur durch `git mv`' \
  .harness/baseline/v6.0.0/templates/docs/plan/planning/slice.template.md     # 1
sed -n '/^func structureGitkeeps/,/^}/p' internal/emit/templates.go \
  | grep -c '"docs/plan/planning/done"'                                       # 1
```

**Keine Erwartungswerte.**

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

**Die Einschränkung auf das Lastenheft steht dort mit Absicht.** Eine Zusage in einem **Plan** —
ein Abnahmekriterium eines Slice — liegt auf einer anderen Ebene und ist von diesem Satz nicht
gedeckt. Diese Entscheidung berührt eine solche: Festlegung 4 benennt sie, und Folgepflicht 4
nennt die Rolle, die daraus die Folgerung schreibt.

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

**Unter der Gegen-Lesart bleibt die Change-Request-Antwort dieselbe; die Träger-Frage beantwortet
sie nicht.** Wer den Satz als Vorgabe für **jedes** Struktur-Verzeichnis liest, findet auch dann
keine geänderte Anforderung, keine zurückgenommene Zusage des Lastenhefts und keinen berührten
Out-of-Scope-Punkt — das sind Fragen an den **Text** von Rang 1, und den ändert diese Entscheidung
nicht. **Erfüllung, kein Change Request**, gilt darum in beiden Lesarten
([`MR-015`](../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler),
[`MR-036`](../../../harness/conventions.md#mr-036--die-change-request-regel-bei-personalunion-steht-jetzt-in-der-adoptierten-baseline)).

**Was jene Lesart daneben aufwirft, trägt dieser Absatz nicht.** Ob die gewählte Datei der Vorgabe
**folgt**, ist eine Frage an die Befolgung, nicht an den Text — und sie ist oben am **Wortlaut**
entschieden: Subjekt des Satzes sind *leere* Struktur-Verzeichnisse. Die Gegen-Lesart verwirft
genau dieses Subjekt und bekommt hier keine zweite Begründung; die Einordnung des Trägers steht
auf der Haupt-Lesart. Der Zweck des Absatzes — *out-of-the-box gate-sicher* — wird unter beiden
erreicht.

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

  **Diese Festlegung berührt eine bestehende Zusage — die eines Plans, nicht die des
  Lastenhefts, und das gehört ausgesprochen.** `slice-190` — der Slice, dessen zwei Fragen diese
  Datei beantwortet — verlangt in **DoD (1)** `docs/plan/carveouts/done` namentlich für die
  Struktur-Liste des Emitters. Diese Entscheidung trägt den Ort nicht; der DoD-Punkt ist in seiner
  heutigen Fassung mit ihr **nicht erfüllbar**. Das ist keine Nebenwirkung, sondern die Folge, und
  sie wird hier benannt statt stillschweigend vollzogen.

  **Von drei weiteren Stellen desselben Plans ist eine nicht betroffen, zwei sind es — und der
  Unterschied liegt in der Achse, nicht in der Formulierung.** Ein Satz seines §3 stellt fest,
  `docs/plan/carveouts/done` sei *„ein Carveout-Ordner und damit gedeckt"*. Er steht im Absatz
  *„Die Change-Request-Frage steht vor dem Code"* und mündet in *„ist hier nicht entschieden"*; er
  beantwortet damit die **Change-Request-Frage** — ob die Aufnahme eines Ortes den Vertrag ändert —
  und bleibt richtig: Wäre der Ort aufzunehmen, bräuchte es dafür keinen Change Request, weil die
  Rang-1-Klammer *„ADR-/Carveout-/Reviews-Ordner"* ihn deckte. Die Frage, die diese Festlegung
  beantwortet, ist die andere: **ob** er aufzunehmen ist. Dazu sagt **jener Satz** nichts.

  **§1 steht dagegen auf der Anlege-Achse, und seine Prämisse fällt mit dieser Festlegung.** Sein
  *„Nur die ersten zwei sind unstrittig"* führt `docs/plan/carveouts/done` neben
  `harness/conventions` als die Orte, die dieser Slice anlegt, und **DoD (1)** knüpft dasselbe
  Wort ans Anlegen: *„Der Bootstrap legt die zwei unstrittigen Orte an"*. Drei Messungen tragen
  die Zuordnung. §1 nennt die Change-Request-Frage **kein einziges Mal** — sie kommt im Plan erst
  in §3 vor. Auf der Change-Request-Achse stehen die zwei Orte **verschieden**: §3 führt den einen
  als von der Rang-1-Klammer gedeckt, während §6 für `harness/conventions` die
  Change-Request-Frage ausdrücklich offen führt; §1 nennt sie gleich, und das geht nur auf der
  Anlege-Achse auf. **Ein zweiter Satz derselben Sektion fällt mit:** nach DoD (1) und (2) blieben
  *„drei Fundstellen … alle aus dem Register-Konflikt"* — eine Zahl, die den hier
  ausgeschlossenen Ort als angelegt voraussetzt.

  **Die dritte Stelle steht in derselben Sektion wie die erste und auf derselben Achse wie die
  zweite.** Die Tabelle *Plan (vor Code)* in §3 weist `structureGitkeeps()` auf *„die zwei
  fehlenden Verzeichnisse"* an — dieselbe Funktion und dieselbe Zahl wie **DoD (1)**, und
  Festlegung 4 trägt nur einen der zwei Orte. Sie fällt mit derselben Prämisse wie der DoD-Punkt.
  Die Unberührtheit oben gilt deshalb dem zitierten Satz und nicht der Sektion, in der er steht.

  **Der Plan hat den Fall selbst offengehalten.** Sein §6 führt als eigenes Risiko, dass ein
  `.gitkeep` für diesen Ort einer Aussage der Baseline widerspricht — genau der oben zitierten —,
  und verlangt vom Slice, **einen** von zwei Wegen ausdrücklich zu wählen: *„Marker **oder**
  Verzeichnis, nicht beides und nicht keines"*. Diese Festlegung schließt den zweiten Weg; der
  erste bleibt offen und ist Umsetzung.

  ```sh
  P='docs/plan/planning/*/slice-190-*.md'
  sed -n '/^## 1\. Ziel/,/^## 2\./p' $P | grep -c 'Change Request\|Change-Request'      # 0
  sed -n '/^## 1\. Ziel/,/^## 2\./p' $P | grep -c 'Nur die ersten zwei sind unstrittig' # 1
  sed -n '/^## 1\. Ziel/,/^## 2\./p' $P | grep -c 'Fundstellen stehen, alle aus dem'    # 1
  sed -n '/^## 2\. Definition of Done/,/^## 3\./p' $P \
    | grep -c 'legt die zwei unstrittigen Orte an'                                      # 1
  sed -n '/^## 2\. Definition of Done/,/^## 3\./p' $P \
    | grep -c 'docs/plan/carveouts/done'                                                # 1
  sed -n '/^## 3\./,/^## 4\./p' $P | grep -c 'ist \*\*hier nicht entschieden\*\*'       # 1
  sed -n '/^## 3\./,/^## 4\./p' $P | grep -c 'die zwei fehlenden Verzeichnisse'         # 1
  sed -n '/^## 3\./,/^## 4\./p' $P | grep -c 'structureGitkeeps'                        # 1
  sed -n '/^## 6\./,/^## 7\./p' $P | grep -c 'Ob `harness/conventions` unter'           # 1
  sed -n '/^## 6\./,/^## 7\./p' $P \
    | grep -c 'Marker \*\*oder\*\* Verzeichnis, nicht beides und nicht keines'          # 1
  ```

  **Keine Erwartungswerte**; der Glob statt der Pfad-Adresse nach
  [`AGENTS.md`](../../../AGENTS.md) §3.11. **Was aus der Kollision folgt, schreibt der Planner**
  (§3.10) — diese Datei ist das Übergabe-Artefakt und nimmt weder den neuen Schnitt vorweg noch
  die Frage, ob die Messzahl in DoD (3) auf dem verbleibenden Weg gehalten wird. Sie benennt
  **vier** Stellen, an denen die Kollision im Plan aufschlägt — **DoD (1)**, **DoD (3)**, §1 und
  die `structureGitkeeps`-Zeile in §3 —, und schlägt für keine dieser Stellen einen Wortlaut vor.
  **Die Menge ist damit nicht geschlossen:** gemessen sind diese vier, nicht die Vollständigkeit
  über den ganzen Plan — die misst der Planner an ihm. Folgepflicht 4 benennt die Übergabe.
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
| 2026-09-06 | **Proposed** | Architect-Lauf zu zwei Fragen aus `slice-190`: der **Change-Request-Frage** aus §3 — die §4 am 2026-09-06 neben dem WIP-Limit als Bedingung für `open → next` führte — und dem **Register-Ort** aus §6, den derselbe Plan als *„Entscheidung des Architect, kein Code-Zug"* führt. Welche Risiken §6 mit welchem Ausgang schließt, sagt diese Datei nicht (Folgepflicht 3). Anlass ist die vom Emitter selbst benannte Grenze (*„Ob einer dazukommt, entscheidet der Architect"*) und die Klasse [`BEO-ALL/emittierte-vorlagen-klassifikation-ohne-traeger`](../planning/observations/BEO-ALL/emittierte-vorlagen-klassifikation-ohne-traeger/observation.md), deren abgeleiteter Zähler am 2026-09-06 bei `ls docs/plan/planning/observations/BEO-ALL/emittierte-vorlagen-klassifikation-ohne-traeger/evidence/*.md \| wc -l` → **2** steht — **kein Erwartungswert** ([`MR-051`](../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung) Setzung 2); der Beleg für diesen Vorgang fällt mit der Slice-Closure, nicht mit dieser Datei ([`AGENTS.md`](../../../AGENTS.md) §3.10). Geprüft und als nicht tragend verworfen sind die zwei möglichen Gegen-Gründe [ADR-0007](0007-bootstrap-phasen.md) und [ADR-0034](0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md); die Aufzählungs-Frage ist an drei Messungen entschieden, nicht an der Lesart |
| 2026-09-06 | Überarbeitet, weiter **Proposed** | Reviewer-Runde `2026-09-06-adr-0037-konsistenz-review.md`, Verdikt *Konsistenz NICHT BESTÄTIGT* — **ohne Einwand gegen die Entscheidung selbst**: alle elf abgedruckten Kommandos reproduzieren, beide Kern-Argumentationen halten dem Volltext stand, und die zwei Gegenbeispiele fallen nicht unter die Eigenschaft. Die **fünf** blockierenden MEDIUM sind im `Proposed`-Fenster behoben, jede Zahl dieser Runde neu gefahren. **M-1:** Der Ausschluss der derivativen Indexe hing an Bedingung (c); der Emit-Pfad nimmt jedem Link mit `<…>` im Ziel-Pfad die Link-Syntax (`NeutralizePlaceholderLinks`), und beide Index-Vorlagen tragen genau einen solchen Link — (c) trägt nicht. Festlegung 4 stand damit auf zwei gemessenen Gründen (Subjekt-Grenze *Ort statt Inhalt*; die eigene Klassen-Regel desselben [`LH-FA-02`](../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)-Absatzes), und die Enge-Zusage von Alternative E nannte dieselben. **M-2:** Die Antwort auf die zweite Frage nannte für keine der drei Bedingungen eine Fundstelle; sie stehen jetzt einzeln, mit Kommando, Regelwerks-Zitat nach [ADR-0016](0016-verweis-traegt-tag-und-zitat.md) Festlegung 2 und einer Gegenprobe, die die Null von (b) gegen einen leeren Ausschnitt absichert. **M-3:** *„die zwei Struktur-Aufzählungen"* bestimmte keine Menge — der Absatz trägt **vier** Klassen-Klammern; ausgelegt wird genau eine, die der leeren Struktur-Verzeichnisse, und für die drei übrigen steht, warum sie unberührt bleiben. Titel, Abschnittsüberschrift, Entscheidungssatz und der ADR-Index sind auf den Singular nachgezogen. **M-4:** Die Zeile darüber beschrieb den Anlass als *zwei offene Risiken, die den Trigger sperren*; gemessen führte §4 am 2026-09-06 neben dem WIP-Limit die Change-Request-Frage aus §3, und §6 trug am selben Tag **sechs** Risiken ohne Ausgang (`sed -n '/^## 6\./,/^## 7\./p' docs/plan/planning/*/slice-190-*.md \| grep -c 'Ausgang:\*\* <offen>'` → **6**, kein Erwartungswert; der Glob statt der Pfad-Adresse nach [`AGENTS.md`](../../../AGENTS.md) §3.11). Sie nennt jetzt die zwei beantworteten Fragen und keine Zahl über fremden Stand. **M-5:** Beide Messwerte tragen ihr Kommando — die Lifecycle-Zahl in beiden Lesarten (vier Ebenen im Regelwerk, drei `.gitkeep` im Emitter) und der Register-Zähler mit Stand, Ableitungs-Kommando und *kein Erwartungswert*; [`MR-051`](../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung) steht dafür jetzt im `Bezug`. **L-1 bis L-4 sowie INFO-2 und INFO-3 sind hier nicht behoben** — jene Runde führt keinen von ihnen als blockierend; **INFO-1 ist mitgezogen**, weil sein Kommando ohnehin neu gefahren wurde und jetzt `cmd/` mitliest. Der Statuswechsel bleibt offen: eine zweite Runde prüft diese Korrektur |
| 2026-09-06 | Überarbeitet, weiter **Proposed** | Reviewer-Runde `2026-09-06-adr-0037-konsistenz-review-runde-2.md`, Verdikt *Konsistenz NICHT BESTÄTIGT* — die fünf MEDIUM der Vorrunde sind am Ist-Stand als behoben nachgemessen, alle 23 abgedruckten Kommandos reproduzieren, und gegen die Entscheidung selbst steht weiterhin **kein** Befund. Behoben sind hier **beide** blockierenden MEDIUM **und jeder übrige Posten**; maßgeblich war je die bindende Quelle, nicht das Severity-Label. **M-1:** Die Aussage über das Reconciliation-Register trägt jetzt die Form aus [ADR-0016](0016-verweis-traegt-tag-und-zitat.md) Festlegung 2 — Tag, Regelwerks-Datei, Abschnitt, Zitat —, die deren Träger (a) zur Vorbedingung des `Accepted`-Übergangs macht; der Posten stand seit Runde 1 als L-3 und war allein wegen des Labels liegen geblieben. **M-2:** Der Grund *„ein Index ist eine Datei in einem angelegten Ort"* ist **gestrichen** — symmetrisch angewandt hätte er Festlegung 2s eigenen Gegenstand ausgeschlossen, deren Träger eine Datei mit Inhalt ist. Den Ausschluss der derivativen Indexe trägt jetzt allein die Klassen-Regel desselben [`LH-FA-02`](../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)-Absatzes; daneben steht, dass Festlegung 1 für sie gegenstandslos ist, und dass sie nur das *Ob* eines Ortes entscheidet, nicht seinen Träger. Konsequenz 2, Festlegung 2 und die Contra-Zelle von Alternative E nennen diese Grenze. **L-1, L-3 und Runde-1-L-4:** Die Auswertungs-Regel zu (a) steht jetzt geschrieben — eine Nennung mit Modus- oder Bedingungs-Zusatz führt den Ort nicht für ein frisches Repo, und die Disjunktion eröffnet zwei Quellen, nicht zwei Maßstäbe. Nach ihr bleiben `harness/conventions/done/` und `docs/plan/carveouts/done/` draußen, je mit Zitat und Kommando; die Umsetzungs-Frage zur stehenbleibenden Fundstelle bleibt beim Slice. **L-2:** Die zweite Aussage über den fremden Plan-Stand ist datiert und trägt keine Zahl mehr, in beiden Geschichte-Zeilen. **Runde-1-L-1:** Festlegung 3 begründet die Idempotenz-Klasse aus der Zweifels-Regel von [ADR-0007](0007-bootstrap-phasen.md) statt aus dem Bestand. **Runde-1-L-2:** §Kontext und §Konsequenzen weisen den Handbuch-Nachzug jetzt gleich zu. **INFO-1** (Beleg-Kommando auf die Funktion des Mengen-Vergleichs verengt), **INFO-2** (Abschnittsname und Rumpf-Lage der Vorlagen-Hälfte), **INFO-3** (was *„unberührt"* heißt, mit Messung an der Singleton-Klammer), **INFO-4** (die widersprüchliche Halbaussage über INFO-1) und **INFO-5** (Zitat-Reihenfolge der zwei Emitter-Absätze; `Bezug` um [ADR-0016](0016-verweis-traegt-tag-und-zitat.md), [`MR-015`](../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) und [`MR-036`](../../../harness/conventions.md#mr-036--die-change-request-regel-bei-personalunion-steht-jetzt-in-der-adoptierten-baseline) ergänzt, [ADR-0005](0005-ziel-repo-distribution.md) im Rumpf verankert) sind mitgezogen. Ein sechster Re-Evaluierungs-Trigger fängt den Fall, dass ein Baseline-Sprung einen der drei ausgeschlossenen Orte unbedingt führt. **Aus diesem Report bleibt nichts offen.** Der Statuswechsel bleibt es: er braucht eine Runde mit tragendem Verdikt. Das wiederkehrende Muster beider Runden — *das Kriterium verspricht eine Reichweite, die sein geschriebener Text nicht hat*, dritte Wiederholung — ist als Steering-Loop-Signal benannt; seine Register-Zuordnung fällt bei der Slice-Closure, nicht hier ([`AGENTS.md`](../../../AGENTS.md) §3.10) |
| 2026-09-06 | Überarbeitet, weiter **Proposed** | Reviewer-Runde `2026-09-06-adr-0037-konsistenz-review-runde-3.md`, Verdikt *Konsistenz NICHT BESTÄTIGT* — alle **32** abgedruckten Kommandos reproduzieren ohne Abweichung, die sieben neuen Zitate sind verbatim, und die Vorbedingung des Accept-Übergangs aus [ADR-0016](0016-verweis-traegt-tag-und-zitat.md) Festlegung 3 (a) ist am Ist-Stand als erfüllt nachgemessen. Gegen die **Entscheidung** steht in drei Runden kein Befund; alle drei blockierenden MEDIUM entstanden aus der Nacharbeit. **M-1 — Rollen-Konflikt, Ausgang ausdrücklich gewählt:** Der Ausschluss von `docs/plan/carveouts/done/` bleibt, weil (a) ihn nicht trägt; die Datei sagt jetzt, dass sie damit ein **Abnahmekriterium** von `slice-190` berührt — **DoD (1)** verlangt den Ort namentlich und ist in seiner heutigen Fassung nicht mehr erfüllbar. **Nicht** berührt sind §3 (*„ein Carveout-Ordner und damit gedeckt"*) und die Nennung *„unstrittig"* in §1: Beide beantworten die Change-Request-Frage, nicht die Anlege-Frage, und bleiben richtig. Der Plan hat den Fall in §6 selbst offengehalten (*„Marker **oder** Verzeichnis"*); diese Festlegung schließt den zweiten Weg, der erste bleibt Umsetzung. Was aus der Kollision für Schnitt und DoD folgt, schreibt der **Planner** — Folgepflicht 4, [`AGENTS.md`](../../../AGENTS.md) §3.10. Festlegung 1s Satz *„keine Zusage wird zurückgenommen"* ist dafür auf die Zusagen des **Lastenhefts** eingeschränkt, die Ebene, für die er galt. **M-2:** Die Auswertungs-Regel zu (a) führt jetzt **drei** Formen, an denen sie scheitert — Modus-Zusatz · Ziel eines ereignisabhängigen Vorgangs · **Glosse statt Eintrag** — und **zwei** Kollisions-Regeln, darunter die fehlende Richtung: Eine bedingte Nennung entkräftet keine unbedingte. Die dritte Form trägt den Ausschluss von `harness/conventions/done/`, dessen Nennung im (a)-Kronzeugen-Zitat rechts des `#` steht und keine eigene Baumzeile hat; die tragende Formel steht damit in der Regel statt nur in ihrer Anwendung. **M-3:** Die zwei *„weicht ab"*-Sätze sind durch die **Einordnung** ersetzt: Das Subjekt des `.gitkeep`-Satzes sind *leere* Struktur-Verzeichnisse, und der Register-Ort ist keines — seine Datei ist Bestandteil der Ablage, nicht Träger eines leeren Verzeichnisses; unter der Gegen-Lesart lautet die Einordnung gleich. **Erfüllung, kein Change Request**, für Aufnahme (Festlegung 1) wie Träger (Festlegung 2); der `Bezug`-Kopf sagt das jetzt für beide. **L-1** behoben — beide gekürzten Zitate tragen die Auslassungsmarke. **INFO-2** mitgezogen: Die Kommentar-Lage des zweiten Carveout-Belegs steht in der Datei, samt dem Grund, warum er trotzdem zählt — der Template-Abbau nimmt `d-check:ignore`-Marker ausdrücklich aus. **INFO-1 ist nicht behoben, und der Grund steht hier:** [ADR-0016](0016-verweis-traegt-tag-und-zitat.md) Festlegung 2 lässt beide Zitier-Formen zu (*„der Wortlaut ohne Auszeichnung"*), und die substanzielle Hälfte — ein grünes Gate sagt über den **emittierten** Stand nichts — steht bereits als *nicht gebaut* in der Fitness-Function-Tabelle. Das Muster *„das Kriterium verspricht eine Reichweite, die sein geschriebener Text nicht hat"* ist damit **fünfte und sechste Wiederholung über drei Läufe**: nicht geschlossen, sondern **versetzt** — in Runde 2 fehlte die Regel, in Runde 3 war sie zu eng. Seine Register-Zuordnung fällt bei der Slice-Closure, nicht hier ([`AGENTS.md`](../../../AGENTS.md) §3.10) |
| 2026-09-06 | Überarbeitet, weiter **Proposed** | Reviewer-Runde `2026-09-06-adr-0037-konsistenz-review-runde-4.md`, Verdikt *Konsistenz NICHT BESTÄTIGT* — **0 HIGH · 1 MEDIUM · 1 LOW · 2 INFO**; alle **39** abgedruckten Kommandos reproduzieren, gegen die **Entscheidung** steht in vier Runden kein Befund, und M-2 wie M-3 der Vorrunde sind am Ist-Stand als behoben nachgemessen — M-2 so, dass die *unbedingte Nennung*, an der Runde 3 hing, mit der neuen Form 3 als Glosse messbar wird. **M-1 — die Reichweiten-Angabe der Kollision war zu eng.** Der Absatz erklärte §3 **und** §1 von `slice-190` für unberührt, weil beide die Change-Request-Frage beantworteten. Für §3 trägt das: Der Satz steht im Absatz *„Die Change-Request-Frage steht vor dem Code"* und mündet in *„ist hier nicht entschieden"*. Für §1 nicht — dort steht *„Nur die ersten zwei sind unstrittig"* auf der **Anlege-Achse**, an drei Messungen: §1 nennt die Change-Request-Frage kein einziges Mal, **DoD (1)** knüpft das Wort ans Anlegen (*„Der Bootstrap legt die zwei unstrittigen Orte an"*), und auf der Change-Request-Achse stehen die zwei Orte gerade **verschieden**, weil §6 für `harness/conventions` die Frage offen führt. Mit der Prämisse fällt ein zweiter Satz derselben Sektion, den der Absatz nicht erwähnte: *„drei Fundstellen … alle aus dem Register-Konflikt"*. Die Datei nennt jetzt **DoD (1)**, **DoD (3)** und §1 als die Stellen, an denen die Kollision aufschlägt, und schlägt für keine einen Wortlaut vor — was daraus folgt, schreibt der **Planner** (Folgepflicht 4, [`AGENTS.md`](../../../AGENTS.md) §3.10). Die Klasse ist *Aussage über den Stand eines fremden Artefakts ohne Messung an ihm* — dieselbe wie Runde-1-M-4; ihre Register-Zuordnung fällt bei der Slice-Closure, nicht hier (§3.10). **L-1 behoben, obwohl der Report ihn als nicht blockierend ausweist:** Die zweite Kollisions-Regel greift jetzt allein an einer Aussage über die **Existenz** eines Ortes und nicht an einer Nennung nach Form 2 — sonst trügen die zwei Regeln dasselbe Prädikat mit entgegengesetzter Wirkung. Der reale Fall dazu steht daneben: der Lifecycle-Ordner `done/` hat eine eigene, zusatzfreie Baumzeile **und** ist Ziel eines `git mv` in der mitemittierten `slice.template.md`. **INFO-1 behoben:** *„nach dieser Festlegung"* hatte einen zweideutigen Antezedenten an der Stelle, die die M-3-Nacharbeit trägt, und heißt jetzt *„nach diesem Rang-1-Satz"*. **INFO-2 behoben:** Die Gegen-Lesart-Hälfte trägt jetzt nur, was sie misst — die Change-Request-Antwort —; die Träger-Frage ist eine Frage an die **Befolgung** und am Wortlaut der Haupt-Lesart entschieden, aus der Gegen-Lesart bekommt sie keine zweite Begründung. **Aus diesem Report bleibt nichts offen.** Der Statuswechsel bleibt es: er braucht eine Runde mit tragendem Verdikt |
| 2026-09-06 | Überarbeitet, weiter **Proposed** | Reviewer-Runde `2026-09-06-adr-0037-konsistenz-review-runde-5.md`, Verdikt *Konsistenz NICHT BESTÄTIGT* — **0 HIGH · 1 MEDIUM · 0 LOW · 1 INFO**; alle abgedruckten Kommandos reproduzieren, die Trennung §1/§3 auf der Change-Request-Achse ist unabhängig nachgemessen, L-1 der Vorrunde trägt je Ausschluss einzeln, und gegen die **Entscheidung** steht in fünf Runden kein Befund. **M-1 — diesmal war die Reichweiten-Angabe zu weit.** Die Nacharbeit zu Runde-4-M-1 hatte das Subjekt des Schlusssatzes von *„jene zwei Stellen"* auf *„§3"* gehoben; §3 heißt **Plan (vor Code)** und weist in seiner Tabelle `structureGitkeeps()` auf *„die zwei fehlenden Verzeichnisse"* an — eine Aussage auf der **Anlege-Achse**, die der Satz für unberührt erklärte. Die Unberührtheit gilt jetzt dem **zitierten Satz**, die Anlege-Zeile steht als dritte Stelle daneben und in der Aufzählung der Kollisionsstellen als vierte, und diese Aufzählung schließt die Menge ausdrücklich **nicht** — gemessen sind die vier, nicht die Vollständigkeit über den Plan. Der Beleg-Block zu `slice-190` trägt dafür zwei Kommandos mehr. **INFO-1 mitgezogen, weil er die Ursache der Klasse benennt:** Die Liste der nicht gebauten Deckungen führte *zwei Stück* und ließ gerade die aus, unter die alle bisherigen Instanzen fallen — dass **kein Lauf** eine Aussage dieser Datei über den Inhalt einer Plandatei gegen jenen Inhalt hält. Sie steht jetzt als dritte in §Fitness Function, mit der Ablesestelle für die Modul-Liste ([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6): eine Deckung, die kein Lauf prüft, wird nicht als vorhanden verbucht). Die Klasse *Aussage über den Stand eines fremden Artefakts ohne Messung an ihm* steht am 2026-09-06 bei **4** Instanzen — gezählt an der `klasse`-Zeile eines Findings, je Report einmal (`grep -lE '^- .klasse.:.*Stand eines fremden Artefakts' docs/reviews/2026-09-06-adr-0037-konsistenz-review*.md \| wc -l` → **4**, kein Erwartungswert) — und hat ihre Schwelle überschritten; ihre Register-Zuordnung fällt bei der Slice-Closure, nicht hier ([`AGENTS.md`](../../../AGENTS.md) §3.10). **Aus diesem Report bleibt nichts offen.** Der Statuswechsel bleibt es: er braucht eine Runde mit tragendem Verdikt |
| 2026-09-06 | Überarbeitet, weiter **Proposed** | Reviewer-Runde `2026-09-06-adr-0037-konsistenz-review-runde-6.md`, Verdikt *Konsistenz NICHT BESTÄTIGT* — **0 HIGH · 1 MEDIUM · 0 LOW · 1 INFO**. Gegen die **Entscheidung** steht in sechs Runden kein Befund, und die Rang-1-Frage ist eigens angegriffen und verneint: Festlegung 4 verengt die Klammer *„ADR-/Carveout-/Reviews-Ordner"* nicht, weil diese Datei den Rang-1-Satz durchgängig als **Träger**-Regel liest und nicht als Aufnahme-Regel. Der eine blockierende Posten lag im **Protokoll** der Nacharbeit, nicht in ihrem Argument. **M-1:** Der Klassen-Zähler der Zeile darüber war **unverankert** — sein Muster traf jede Zeile, die es selbst enthält, also auch jeden Report, der die Klasse nur **nennt**, statt ein Finding dieser Klasse zu tragen; über einem Baum, der einen solchen Report führt, gab er nicht mehr den Wert aus, der daneben stand. Er ist jetzt an die `klasse`-Zeile eines Findings verankert und in beide Richtungen nachgefahren: über einer Datei, die die Klasse nur zitiert, greift er nicht, über einer echten `klasse`-Zeile greift er — unter GNU grep wie unter ugrep gleich. Der ausgewiesene Wert ändert sich dadurch nicht; bestritten war das Instrument, nicht die Zahl. Die Zeile trägt damit, was [`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) Setzung 1 verlangt: das Kommando, das **genau** die behauptete Zahl ausgibt. **INFO-1 ist geprüft und bewusst nicht aufgenommen.** Er meldet eine **fünfte** Kollisionsstelle in §8 von `slice-190` und weist sie selbst als von der Nicht-Schließungs-Klausel der Festlegung 4 gedeckt aus; die Klausel bleibt unverändert, und die Stelle tritt nicht in die Aufzählung. Zwei Gründe tragen das. Sie steht im Block *Vorgelagert — offene Beobachtungen sichten*, dessen Stand der Plan ausdrücklich nicht selbst setzt (`sed -n '/^## 8\./,$p' docs/plan/planning/*/slice-190-*.md \| tr '\n' ' ' \| tr -s ' ' \| grep -c 'Den Stand setzt der Lese-Schritt der Closure, nicht dieser Plan'` → **1**, kein Erwartungswert; der Glob statt der Pfad-Adresse nach [`AGENTS.md`](../../../AGENTS.md) §3.11) — das ist Closure- und Planungs-Arbeit (§3.10), dieselbe Grenze, an der Folgepflicht 3 die Risiko-Ausgänge und die Trigger-Zeile liegen lässt. Und ein fünfter Eintrag vergrößerte eine ausdrücklich **offene** Menge, ohne sie zu schließen: Die vier benannten Stellen sind ein Urteil über die Anlege-Achse, keine Fundmenge eines Musters, und die Vollständigkeit über den ganzen Plan misst der Planner an ihm (Folgepflicht 4). **Ein neuer Vollständigkeits-Anspruch entsteht hier nicht.** Der Statuswechsel bleibt offen: er braucht eine Runde mit tragendem Verdikt |
| 2026-09-06 | Überarbeitet, weiter **Proposed** | **Kein Review-Befund — Accept-Vorprüfung.** Runde 7 (`2026-09-06-adr-0037-konsistenz-review-runde-7.md`) hat alles Übrige bestätigt; dieser Posten stammt aus Träger (a) von [ADR-0016](0016-verweis-traegt-tag-und-zitat.md) Festlegung 3, der die Beleg-Form **vor** den `Accepted`-Übergang legt — danach ist derselbe Satz durch [`AGENTS.md`](../../../AGENTS.md) §3.4 unerreichbar. Die Datei trug **einen** Markdown-Link in den tag-gepinnten vendored Baum: die Vorlagen-Nennung des Reconciliation-Registers. Er steht jetzt in der Form, die die Datei ohnehin führt — Tag genannt, Pfad baseline-relativ, Inline-Code statt Link ([ADR-0016](0016-verweis-traegt-tag-und-zitat.md) Festlegung 2: *„**Nicht** dazu gehören der lokale Präfix … und die Zeilennummer als alleiniger Locator"*) —, und damit tragen **11** Belege sie (`grep -cE 'Baseline .v6\.0\.0.,' docs/plan/adr/0037-*.md` → **11**, kein Erwartungswert). **Verloren geht allein die Navigierbarkeit**: Sie zählt nach jener Festlegung nicht zum Beleg, dessen drei Teile Tag, Datei- und Abschnittsname sowie Zitat sind, und sie wäre beim nächsten Sprung ohnehin verfallen. **Gemessen ist die Klasse, nicht die Zeile.** Alle **107** Markdown-Links fallen auf **12** eindeutige Ziele, und keines bewegt der Prozess: Links in den Planning-Lifecycle und nach `docs/reviews/**` trägt die Datei **keine**, die ADR-Geschwister liegen flach (`ls -d docs/plan/adr/*/ 2>/dev/null \| wc -l` → **0**), und die Register-Ablage ist samt ihren Verzeichnissen ortsfest ([ADR-0034](0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md) Festlegung 5). **Die Vollständigkeit des Musters ist geprüft, nicht geglaubt** — drei Zählungen müssen übereinstimmen: der rohe Link-Kopf (`grep -oE '[]][(]' <datei> \| wc -l`), das Ziel-Muster zeilenweise und dasselbe Muster über `tr '\n' ' '` umbruch-sicher (`grep -oE '\]\([^)]+\)' <datei> \| wc -l`), je **107**. Ein Ziel mit `)` darin und ein über den Zeilenumbruch gesetzter Link ließen sie auseinanderfallen. **Zwei Instrument-Fallen sind dabei umgangen und gehören zur Aussage:** Beide Sonden sind so geschrieben, dass ihr eigener Abdruck sie nicht trifft — die Sequenz, die sie suchen, kommt in ihnen nicht vor —, und keine zählt mit `-c -o`, dessen Ergebnis zwischen GNU grep (Zeilen) und ugrep (Vorkommen) auseinandergeht; `grep -oE … \| wc -l` liefert unter beiden dieselbe Zahl. **Beide Richtungen gesehen** ([`AGENTS.md`](../../../AGENTS.md) §3.6): die Simulation des nächsten Re-Baselines — `v6.0.0` → `v6.1.0` auf der betroffenen Zeile, `make docs-check`, byte-exakt zurückgesetzt — meldete **vorher** genau **1** `target-missing` und **nachher 0**. **Die zweite Adress-Form bleibt stehen und ist benannt:** die **19** tag-gepinnten Nennungen (`sed -E 's/\]\([^)]*\)//g' <datei> \| grep -oE '\.harness/baseline/v[0-9]' \| wc -l` → **19**, kein Erwartungswert) sind Operanden der Kommandos, die [`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) Setzung 1 verlangt, nicht Adressen eines Belegs; sie liegen außerhalb von `codepaths.roots` (`grep -n 'roots:' .d-check.yml`) und sind die *stille Hälfte*, die [ADR-0016](0016-verweis-traegt-tag-und-zitat.md) Festlegung 1 ausdrücklich stehen lässt. **Steering-Loop-Gehalt: die Klasse blieb über sieben Runden ungeprüft.** Alle sieben Reports führen [`AGENTS.md`](../../../AGENTS.md) §3.11 in ihrem Eingangs-Kontext, keiner nennt die Fundstelle (`grep -l 'reconciliation\.template\.md' docs/reviews/2026-09-06-adr-0037-konsistenz-review*.md \| wc -l` → **0**, kein Erwartungswert). Ihre Register-Zuordnung fällt bei der Slice-Closure, nicht hier ([`AGENTS.md`](../../../AGENTS.md) §3.10) |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0037` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).
