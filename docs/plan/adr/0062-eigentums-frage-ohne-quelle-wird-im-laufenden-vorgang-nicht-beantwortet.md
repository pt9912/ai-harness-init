# ADR-0062: Eine Eigentums-Frage ohne Quelle wird im laufenden Vorgang nicht beantwortet

**Status:** Proposed

**Datum:** 2026-09-23

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[ADR-0048](0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) (ihr Re-Evaluierungs-Trigger 5 ist
gefeuert; diese Entscheidung ist seine Antwort — die Datei bleibt unberührt und in Kraft, und diese
Entscheidung löst sie nicht ab, sondern trägt darum kein `Supersedes`),
[ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) (Festlegung 1 verengt sich auf zwei
Norm-Artefakte und lässt die Frage für alle übrigen ausdrücklich offen; ihre Festlegung 2 ist die
Commit-Konstruktion, die Festlegung 2 unten wiederverwendet; ihre Begründung — eine Norm-Frage ohne
Original ist eine Architektur-Frage — trägt das Residuum unten),
[ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md) (die Original-Achse,
eine der Instanz-Regeln, die unten in Kraft bleiben; ihre Ableitung endet an der bindenden Aussage
ohne Original und lässt genau dieses Residuum offen),
[ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) (die Ablauf-Achse; ihre
Festlegung 2 lässt das Residuum ausdrücklich offen und weist es keiner Rolle zu — diese
Entscheidung schließt es, ohne die Festlegung anzutasten),
[ADR-0046](0046-welle-datei-entsteht-mit-der-eroeffnung.md) und
[ADR-0048](0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) (die Drei-Fächer-Form des
Acceptance-Trigger unten),
[ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) (Festlegung 1–3: der Beleg des
Accept-Übergangs ist die Runde der prüfenden Rolle, genannt bei ihrer Kennung),
[ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) (Festlegung 3 — ein Slice-Plan,
den der Prozess bewegt, steht hier bei seiner Kennung, nicht unter seiner Adresse),
[ADR-0016](0016-verweis-traegt-tag-und-zitat.md) (Festlegung 2 — die Form der Baseline-Belege unten:
Tag, Dateiname, Abschnittsname, Zitat verbatim),
[`MR-015`](../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
(die Konstruktion: eigener Commit, ausschließlich Artefakte derselben Rolle),
[`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert),
[`MR-051`](../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
(Setzung 2 — der Register-Zähler unten ist eine datierte Messung),
[`MR-057`](../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
(die Welle-Kennung im Herkunfts-Anker ist der Name),
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)

**Schärft:** — Prozess-ADR ohne Spec-Stratum: sie entscheidet, wie eine Eigentums-Frage, die keine
Quelle benennt, in diesem Repo beantwortet wird, und ändert keine Spec-Aussage.

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md` §Ziel-Form: ADR (MADR). Die Rollen-Aussagen unten
messen gegen die regierende Fassung `v6.9.0`
([`MR-033`](../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)).

---

## Kontext

### Der gefeuerte Trigger

[ADR-0048](0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) hängt ihren fünften
Re-Evaluierungs-Trigger an den Zähler eines Verzeichnisses des
[Beobachtungs-Registers](../planning/observations/BEO-ALL/eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet/observation.md)
— die Register-Ablage ist ortsfest
([ADR-0034](0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
Festlegung 5). Der Wortlaut:

> *„Wenn dieselbe Klasse — eine Eigentums-Frage ohne Quelle wird im laufenden Vorgang faktisch
> beantwortet — im Beobachtungs-Register 3× erreicht** *(beobachtbar am Zähler ihres
> Verzeichnisses)*: Dann ist die Verengung oben aufgebraucht, und die Frage gehört als allgemeine
> Regel entschieden statt ein viertes Mal je Artefaktklasse."*

Der Zähler steht auf der Schwelle — **kein** Erwartungswert
([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2), eine **datierte Messung** im Sinne von
[`MR-051`](../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
Setzung 2, gemessen am 2026-09-23:

```sh
ls docs/plan/planning/observations/BEO-ALL/eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet/evidence/ | wc -l   # 3
```

Die drei Belege sind die Evidence-Dateien desselben Verzeichnisses; sie heißen:

- [`slice-flache-welle-ist-eroeffnet-nicht-geplant`](../planning/observations/BEO-ALL/eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet/evidence/slice-flache-welle-ist-eroeffnet-nicht-geplant.md)
  (2026-09-14) — das Erstauftreten, das dem Eintrag die Kennung gibt: der Welle-Plan-Fall, den
  [ADR-0048](0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) entschieden hat, und daneben
  [`docs/plan/planning/README.md`](../planning/README.md), für den bis heute keine Quelle eine
  schreibende Rolle benennt.
- [`slice-stilllegungs-kanten-sind-gemessen`](../planning/observations/BEO-ALL/eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet/evidence/slice-stilllegungs-kanten-sind-gemessen.md)
  (2026-09-17) — eine Norm-Aussage ohne Original im Planner-Anweisungssatz; genau das Residuum, das
  [ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Festlegung 2 ausdrücklich
  offen lässt.
- [`slice-spec-straten-zeigen-nicht-nach-aussen`](../planning/observations/BEO-ALL/eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet/evidence/slice-spec-straten-zeigen-nicht-nach-aussen.md)
  (2026-09-18) — die Spec-Straten; ausdrücklich außerhalb von
  [ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md), und die offene Frage trägt die
  Kennung `slice-151-spec-straten-haben-eine-schreibende-rolle` als Adresse
  ([ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) Festlegung 3).

Der dritte Beleg ist am 2026-09-18 gemerged; die Vorgänger-Welle
`welle-emittierte-werkzeuge` schloss am 2026-09-15. Der Übertritt über die Schwelle fällt damit in
das Fenster dieser Welle — ihr Trigger-Audit (Schritt 2, ADR-Zweig) ist der Träger, und die
Verkörperung (Schritt 3b) schreibt diese Datei. Der erste Beleg liegt vor jenem Abschluss; er stand
bei dessen Lese-Schritt unter der Schwelle und ist der Anlass der Kennung, nicht Teil des Übertritts.

### Die Klasse, die der Zähler zählt

Die [Bezeichnung des Eintrags](../planning/observations/BEO-ALL/eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet/observation.md):
für ein Artefakt sagt keine Quelle, welche Rolle es schreiben darf — und die Frage wird trotzdem
beantwortet, nicht durch eine Entscheidung, sondern dadurch, dass ein laufender Vorgang das
Artefakt anfasst. Der nächste Lauf findet Bestand statt Norm und kann sich auf beides berufen, je
nachdem, welchen Commit er liest.

Die Auflösung dieser Klasse kostet bislang eine Entscheidung **je Artefaktklasse** — vier trägt
dieses Repo:

| Entscheidung | Artefaktklasse | Was sie offen lässt |
|---|---|---|
| [ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) | die zwei Norm-Artefakte (`AGENTS.md` §3, Adaptions-Block) | *„Über die übrigen Norm-Artefakte trifft diese ADR keine Aussage"* (Festlegung 1) |
| [ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md) | derivatives Register | die bindende Aussage ohne Original — die Ableitung endet dort und sagt nichts über jenen Teil (Festlegung 1) |
| [ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) | Rollen-Anweisungssatz | die Norm-Aussage ohne Original im Anweisungssatz (Festlegung 2) und `.claude/agents/*.md` (Festlegung 3) |
| [ADR-0048](0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) | der Welle-Plan | jeder Vorgang, der unter keine der dort benannten Klassen fällt |

Der zweifach belegte dritte Fall und der zweite Fall fallen in genau diese Residuen: Die
Norm-Aussage ohne Original und die Spec-Straten sind keine Welle-Pläne und keine Anweisungssätze im
Sinne der tragenden Eigenschaft, und die Ableitungen, die für jene zwei Klassen stehen, liefern für
sie nichts. Der Trigger sagt darum: die Verengung ist **aufgebraucht** — nicht, weil eine der vier
Entscheidungen falsch wäre, sondern weil das Residuum, das jede bewusst stehen lässt, dreimal
faktisch beantwortet worden ist.

### Was die Baseline regelt

`v6.9.0`, `modul-08-agentenrollen.md` §Rollen-Regeln weist die Architektur-Entscheidung zu —
whitespace-normalisiert geprüft, die Ausgabe jedes Kommandos ist **1**:

```sh
B=.harness/baseline/v6.9.0/regelwerk/modul-08-agentenrollen.md
tr '\n' ' ' < $B | tr -s ' ' | grep -cF 'ADR-Änderung: Architect schreibt; Reviewer prüft auf Konsistenz; Implementer liest als Constraint'   # 1
```

> *„ADR-Änderung: Architect schreibt; Reviewer prüft auf Konsistenz; Implementer liest als
> Constraint."*

Die Architektur-Entscheidung ist damit an eine Rolle gebunden, und die Antwort auf eine
Eigentums-Frage ohne Quelle ist eine solche: Sie entscheidet, wer Norm-Text an einem Artefakt
schreiben darf, und Norm ist der Gegenstand, den
[ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) für ihre zwei Artefakte aus demselben Grund
beim Architect besiedelt hat. Derselbe Abschnitt regelt, wie ein Rollen-Konflikt um ein Übergabe-Artefakt
läuft — Verdikt *„Lockerung legitim, aber undokumentiert"*, zweiter Zeile der Tabelle
(whitespace-normalisiert, jedes Kommando **1**):

```sh
tr '\n' ' ' < $B | tr -s ' ' | grep -cF 'Lockerung legitim, aber undokumentiert'   # 1
tr '\n' ' ' < $B | tr -s ' ' | grep -cF 'Folge-ADR + Erinnerungs-Slice in `next/`'   # 1
```

Und die Konstruktion, die der Übergabe im Commit-Pfad folgt, steht bereits im Repo:
[ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 2 und
[`MR-015`](../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
— der laufende Kontext liefert das Übergabe-Artefakt, der Norm-Text entsteht im eigenen Commit der
schreibenden Rolle.

## Entscheidung

**Wir wählen Option D: die allgemeine Regel an derselben Achse, an der
[ADR-0048](0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) sie für den Welle-Plan gesetzt
hat — dem Vorgang —, und für das Residuum eine Antwort-Pflicht statt der stillen Berührung.** Drei
Festlegungen:

### 1. Die schreibende Rolle eines Artefakts hängt an dem Vorgang, zu dem seine Änderung gehört — nicht an der Datei, ihrem Pfad, ihrem Typ oder ihrem Bestand · seit welle-v021-faehigkeit

Die vier Entscheidungen der Familie sind **Instanzen** dieser Regel: Je eine Vorgangs-Klasse je
Artefaktklasse, wo keine Quelle nach [`AGENTS.md`](../../../AGENTS.md) §2 die Rolle benennt.
[ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md) leitet aus dem
**Original** ab — die Rolle, die die Originale schreibt, schreibt die Projektion;
[ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) aus dem **Ablauf** — wer ihn
ausführt, schreibt seinen Anweisungssatz;
[ADR-0048](0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) am **Änderungsobjekt** —
Eröffnung und Closure sind Planner-Arbeit, der vorlagengebundene Nachzug läuft im
Implementations-Kontext; [ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) an der **Frage, die
das Artefakt trägt** — eine Baseline-Abweichungs-Frage ist eine Architektur-Frage. Keine der vier
widpricht dieser Regel: Jede benennt den Vorgang, zu dem die Änderung gehört, und keine von ihnen
hängt Eigentum an Pfad, Typ oder Bestand. Sie bleiben in Kraft, solange sie konsistent sind; diese
Entscheidung löst keine von ihnen ab und trägt darum kein `Supersedes`. Bei Konflikt gilt die ADR
([`AGENTS.md`](../../../AGENTS.md) §2).

### 2. Berührung ist keine Antwort

Für ein Artefakt — oder einen Teil eines Artefakts —, für das **keine Quelle** nach
[`AGENTS.md`](../../../AGENTS.md) §2 eine schreibende Rolle benennt und auf das **keine der
Instanz-Regeln** aus Festlegung 1 greift, ist die Eigentums-Frage im laufenden Vorgang **nicht
beantwortbar** — auch nicht durch Tun. Vier Sätze tragen sie:

- Der laufende Vorgang schreibt das Artefakt nicht, und er nimmt auch keine Zuordnung still an.
- Er liefert ein **Übergabe-Artefakt**: Anlass, berührter Bestand, Änderungsbedarf — dieselbe
  Konstruktion, die
  [ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 2 für ihre zwei Artefakte setzt
  und die Baseline `v6.9.0` für das Lastenheft formuliert hat.
- Die Entscheidung fällt im **Architect-Lauf** — eine Norm-Aussage ohne Original ist eine
  Architektur-Frage ([`MR-015`](../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler),
  [ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1, Begründung oben). Ihre Form
  ist die ADR, wo sie eine **Klasse** entscheidet; wo die Antwort an einer bestehenden Quelle hängt,
  genügt die Nennung jener Quelle im Übergabe-Artefakt — dann war die Frage keine quellenlose.
- Der laufende Kontext nimmt keinen der beiden Schritte vor: weder das Schreiben noch das
  stillschweigende Annehmen.

**Der Preis ist gemessen und billiger als die Alternative.** Jeder der drei Belege ist im laufenden
Vorgang beantwortet worden und hat das Review dann als Rollen-Widerspruch gemeldet; die Auflösung
kostete ein Architect-Verdikt plus — beim Erstauftreten — drei Konsistenzrunden. Die Übergabe
kostet einen Rollen-Wechsel; die stille Berührung kostet ihn danach, mit einem Finding obendrauf.

### 3. Die Residuen der Instanz-Regeln fallen unter Festlegung 2

Die Stellen, an denen die vier Instanz-Entscheidungen ihre Ableitung bewusst enden lassen — die
übrigen Norm-Artefakte ([ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1), die
bindende Aussage ohne Original
([ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md) Festlegung 1), die
Norm-Aussage ohne Original im Anweisungssatz und
[`.claude/agents/*.md`](../../../.claude/agents/)
([ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Festlegungen 2 und 3) und die
Vorgänge, die unter keine Klasse von
[ADR-0048](0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) fallen — sind ab hier nicht mehr
„offen", sondern unter Festlegung 2 entschieden: **Übergabe statt Tun.** Das schließt die offenen
Fragen, ohne eine der vier Festlegungen anzutasten — jede von ihnen sagt ausdrücklich, dass sie
über diesen Teil nichts sagt; diese Datei sagt es, mit dem gemessenen Zähler als Beleg.

**Cutoff: geprüft wird ab dem Commit, der diese ADR annimmt.** Die drei Belege werden nicht
nachgerichtet — dieselbe Begründung wie in
[ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md),
[ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md) und
[ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md): ein Maßstab, der den Bestand
mitprüfte, wäre dauerhaft rot und entwertete die Setzung. **Die offenen Fragen sind kein Bestand:**
Für [`docs/plan/planning/README.md`](../planning/README.md) und die Spec-Straten (Kennung
`slice-151-spec-straten-haben-eine-schreibende-rolle`) gilt Festlegung 2, sobald diese ADR
angenommen ist; bis dahin beantwortet sie keine von beiden.

**Was hier NICHT entschieden ist:** die schreibende Rolle für die Spec-Straten — die Adresse ist
die Kennung `slice-151-spec-straten-haben-eine-schreibende-rolle`, und der Architect-Verdikt, der
den Vorgang begleitete (Kennung `2026-09-18-spec-straten-architect`), greift der Frage ausdrücklich
nicht vor; die für [`docs/plan/planning/README.md`](../planning/README.md); die für
[`.claude/agents/*.md`](../../../.claude/agents/) —
[ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Festlegung 3 grenzt sie ab, und
Festlegung 2 hier gibt ihr den Weg, nicht die Antwort; und die emittierte Ebene.

## Verglichene Alternativen

Regeln dieser Sektion: **mindestens drei Optionen mit Pro/Contra** — „nichts tun" ist eine davon
(Baseline-Regelwerk `modul-04-adrs.md` §Ziel-Form: ADR (MADR)).

| Option | Pro | Contra |
|---|---|---|
| A — **nichts tun**, die Familie weiter je Artefaktklasse schließen | kein neuer Text; die vier Instanzen tragen die Fälle, solange sie auftreten | Genau das ist die Klasse, deren Zähler **3** steht: dreimal wurde die Frage durch Tun beantwortet, und jede Auflösung kostete ein Verdikt plus Runden. [ADR-0048](0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) Trigger 5 verlangt die allgemeine Regel — ihn zu lassen, ist ein stiller, stehengebliebener Trigger |
| B — die **Datei-Lesart**: ein quellenloses Artefakt gehört der Rolle, die es bisher geschrieben hat | eine Zeile, ohne Probe | Bestand begründet nichts — weder in die eine noch in die andere Richtung ([`AGENTS.md`](../../../AGENTS.md) §3.7); [ADR-0048](0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) §Kontext misst für denselben Artefakt-Typ beide Antworten nebeneinander (56 gegen 7 Rollen-Präfixe). Die Lesart beantwortet die Frage mit genau der Klasse, die der Zähler zählt |
| C — die vier Instanz-Entscheidungen per `Supersedes` ablösen und alles in **eine** Regel ziehen | eine Datei statt vier; keine Instanz-Aufzählung | Die vier tragen je eine geprüfte Achse mit eigenen Proben und Triggern, und keine ist angegriffen. Sie zu ablösen, bewegte vier Entscheidungen, die niemand angreift — derselbe Contra, den [ADR-0048](0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) Option C gegen das Ablösen von [ADR-0046](0046-welle-datei-entsteht-mit-der-eroeffnung.md) führt; der Präzedenzfall dieses Repos ist [`AGENTS.md`](../../../AGENTS.md) §3.11, das vier Entscheidungen verallgemeinert, ohne eine davon abzulösen |
| E — **auf die Baseline warten** | kein eigener Norm-Text | Gemessen: `v6.9.0`, `modul-08-agentenrollen.md` §Rollen-Regeln benennt die schreibende Rolle für ADRs und keine für ein quellenloses Artefakt allgemein (§Kontext, Kommando **1**). [ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) hat denselben Zweig über **alle 26** Regelwerk-Dateien ihres damaligen Stands geprüft und verworfen |
| **D — gewählt: die allgemeine Regel als Instanz-Familie mit geschlossenem Residuum, ohne `Supersedes`** | Schließt die Lücke, die der Zähler zählt, ohne eine fremde Entscheidung zu bewegen; die Antwort-Pflicht hängt an einer Handlung (Übergabe), nicht an einem Urteil über Bestand; [ADR-0048](0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) Trigger 5 ist bedient | Die Vorfrage — greift eine Instanz-Regel, oder ist es Residuum? — ist ein Urteil je Änderung, kein Muster, also nicht maschinell zu halten (§Fitness Function); und ein dringender Norm-Nachzug läuft nicht mehr im laufenden Kontext, sondern über die Übergabe — derselbe Preis, den [ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) für ihre zwei Artefakte führt |

## Konsequenzen

- **Positiv:** Die Frage *„durfte dieser Lauf das schreiben?"* ist für das Residuum **vor** der
  Änderung beantwortbar — mit einer Handlung (Übergabe-Artefakt), nicht mit einer Berufung auf
  Bestand. Das ist dieselbe Wirkung, die
  [ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) für ihre zwei Artefakte misst, hier für
  die Klasse statt für zwei Dateien.
- **Positiv:** [ADR-0048](0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) Trigger 5 ist
  bedient — diese Datei ist die allgemeine Regel, die er verlangt. An ADR-0048 wird nichts
  geändert; sein Trigger bleibt als Geschichte der Entscheidung stehen.
- **Positiv:** Die offenen Fälle haben einen Weg, ohne dass diese Entscheidung vorgreift. Die
  Spec-Straten-Frage bleibt bei ihrer Kennung
  (`slice-151-spec-straten-haben-eine-schreibende-rolle`); ab der Annahme läuft ihre Beantwortung
  über Festlegung 2 — Übergabe, dann Entscheidung im Architect-Lauf — statt über eine Berührung.
- **Negativ:** Die Vorfrage aus Festlegung 1 (greift eine Instanz-Regel?) und die Grenze aus
  Festlegung 2 (ist die Aussage quellenlos?) sind Urteile je Änderung, keine Muster — **kein
  Wächter** (§Fitness Function). Wer sie falsch zieht, hat entweder eine Planungs-Entscheidung im
  Implementations-Kontext getroffen oder eine operative Kleinigkeit unnötig übergeben.
- **Negativ:** Eine Norm-Änderung unterbricht den laufenden Vorgang — derselbe Preis, den
  [ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 2 für ihre zwei Artefakte
  misst, jetzt für das ganze Residuum.
- **Folgepflicht (Planner), fällig bei der Closure dieser Welle:** der Ausgang des
  Register-Eintrags [`BEO-ALL/eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet`](../planning/observations/BEO-ALL/eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet/observation.md).
  Diese Datei empfiehlt **`geplant`** mit der Kennung dieser ADR — die Regel ist geschrieben, aber
  auf `Proposed`, und ein `verkörpert`-Eintrag behauptete Bindung, die der Acceptance-Trigger unten
  noch nicht trägt (dieselbe Zurückhaltung, die
  [ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Folgepflicht 1 für den Zeiger
  aus der `Proposed`-Fassung ausspricht). Mit dem Accept wird derselbe Ausgang `verkörpert` —
  Zielort diese Datei, Anker `· seit welle-v021-faehigkeit` trägt sie in Festlegung 1 selbst. Ob
  und wann, entscheidet der Planner; diese Datei schreibt das Register nicht.
- **Folgepflicht (Reviewer), fällig als eigene Runde:** die Annahme läuft über den
  Acceptance-Trigger unten — gegen die vier Instanz-Entscheidungen und
  [`MR-015`](../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
  geprüft.
- **Folgepflicht — kein Eintrag im Adaptions-Block.** Die Regel weicht von der Baseline nicht ab,
  sie füllt eine Lücke, die vier Instanz-Entscheidungen je für sich offen ließen; ein Eintrag dort
  wäre eine erfundene Abweichung und verstieße gegen den Zweck, den
  [`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage) dem Block gibt — dieselbe
  Folgepflicht führen [ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md),
  [ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md) und
  [ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) aus demselben Grund.
- **Folgepflicht — die emittierte Ebene bleibt unberührt.** Ob ein erzeugtes Repo eine
  Eigentums-Aussage bekommt, entscheidet der Slice, der die Tool-Ebene entscheidet — nicht diese
  ADR.

## Fitness Function (falls maschinell prüfbar)

| Tooling | Regel | Make-Target |
|---|---|---|
| — | **keine.** Die Probe aus Festlegung 1 (greift eine Instanz-Regel, oder ist es Residuum?) ist ein Urteil, kein Muster — dieselbe Lage, die [ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md), [ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md), [ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) und [ADR-0048](0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) für ihre eigenen Festlegungen feststellen. Ein Sensor müsste **Commits** lesen; kein Modul der [`.d-check.yml`](../../../.d-check.yml) tut das (`grep -n '^modules:' .d-check.yml`), und `make mutate` kennt zwei Fehlschlag-Formen, keine für einen Commit-Zuschnitt oder eine Rollen-Zuordnung. Träger ist der Rollen-Wechsel **vor** der Änderung und das Review danach | — |

Behauptet wird hier **kein** Gate
([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).

## Re-Evaluierungs-Trigger

- **Wenn eine kanonische Quelle nach [`AGENTS.md`](../../../AGENTS.md) §2 eine schreibende Rolle für
  ein bisher quellenloses Artefakt benennt** *(beobachtbar an dieser Quelle selbst)*: Der Fall fällt
  aus dem Residuum heraus — die Regel ist subsidiär und greift nur, wo keine Quelle benennt; nichts
  ist nachzuziehen.
- **Wenn die Klasse ein weiteres Mal auftritt, obwohl der Träger steht** *(beobachtbar am
  Zähler des Register-Verzeichnisses
  [`BEO-ALL/eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet`](../planning/observations/BEO-ALL/eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet/observation.md))*:
  Dann trägt der Ort nicht, und die Trägerwahl ist der Befund, nicht die Wiederholung — dieselbe
  Probe, die [ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) Trigger 1,
  [ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md) und
  [ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) an sich selbst anlegen.
- **Wenn eine der vier Instanz-Entscheidungen durch eine Folge-ADR mit `Supersedes` abgelöst wird**
  *(beobachtbar an deren Index-Zeile)*: Die Instanz-Aufzählung in Festlegung 1 ist dann gegen die
  Nachfolgerin neu zu lesen — diese Datei greift in die abgelöste Datei nicht ein, und ein
  Widerspruch der neuen Fassung gegen Festlegung 1 ist ein echter Konflikt und braucht eine
  eigene Entscheidung.
- **Wenn die Baseline eine schreibende Rolle für quellenlose Artefakte allgemein benennt**
  *(feedforward — eine Textänderung upstream, kein Sensor; gegen `BASELINE_TAG` gemessen)*: Dann ist
  diese Entscheidung gegenstandslos und wird durch eine Nachfolge-ADR mit `Supersedes` auf den
  Baseline-Abschnitt zurückgeführt. `v6.9.0` benennt keine (§Kontext).

### Der Acceptance-Trigger

Diese Entscheidung steht auf `Proposed`. Sie wird `Accepted`, **wenn eine Reviewer-Runde sie gegen
[ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md),
[ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md),
[ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md),
[ADR-0048](0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) und
[`MR-015`](../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
auf Konsistenz geprüft hat und ihr Report ohne blockierenden Befund an der **Substanz** der drei
Festlegungen in `docs/reviews/` liegt.**

**Drei Fächer, nicht zwei** — dieselbe Dreiteilung, die
[ADR-0046](0046-welle-datei-entsteht-mit-der-eroeffnung.md) §Der Acceptance-Trigger gesetzt hat und
die [ADR-0048](0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) §Der Acceptance-Trigger mit
derselben Beobachtung für sich übernommen hat. Ein blockierender Befund an der **Darstellung** —
Adressform, Zahl ohne Kommando, Zitat-Stelle — wird behoben und hindert die Annahme nicht; dasselbe
gilt für einen Befund an **jedem Abschnitt, der mit dem Accept einfriert, ohne eine Festlegung zu
tragen**. Tragend ist die Kennzeichnung: bei Zweifel geht die Kennzeichnung vor, nicht die
Aufzählung. Die drei Abschnitte, die **nicht** einfrieren, sind die drei, die
[ADR-0048](0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) nennt — §Kontext samt seiner
Messungen, die Re-Evaluierungs-Trigger und **dieser Trigger-Abschnitt selbst** —, und ein Befund
dort wird behoben, solange die Datei `Proposed` ist, **solange die Behebung keine der drei
Festlegungen ändert**; ändert sie eine, ist es ein Substanz-Befund und blockiert.

Der Beleg ist eine Runde der prüfenden Rolle; die Nachmessung durch den Kontext, der einen Befund
aufgelöst hat, ist keine
([ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 2) — nach einem
blockierenden Verdikt ist es die **nächste** Runde derselben Rolle. Die Accept-Zeile der §Geschichte
nennt ihn als **Kennung**, nicht als Pfad-Link (ebenda, Festlegung 1).

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-09-23 | **Proposed** | Architect-Lauf im Welle-Closure-Kontext von `welle-v021-faehigkeit`, Schritt 2 (Trigger-Audit, ADR-Zweig) und Schritt 3b (Verkörperung). Anlass ist der gefeuerte Re-Evaluierungs-Trigger 5 von [ADR-0048](0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md), gelesen am Zähler des Register-Verzeichnisses `BEO-ALL/eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet` — **3** Belege (Kommando in §Kontext). Die Annahme läuft in einer eigenen Reviewer-Runde, nicht in dieser Closure. |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0062` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).