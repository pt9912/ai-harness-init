# ADR-0048: Eigentum an einem Planungs-Artefakt hängt am Vorgang, nicht an der Datei — der vorlagengebundene Nachzug im laufenden Welle-Plan

**Status:** Proposed

**Datum:** 2026-09-14

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[ADR-0046](0046-welle-datei-entsteht-mit-der-eroeffnung.md) (ihre Abgrenzungs-Sektion trägt den
Satz, dessen Reichweite hier ausgelegt wird — **unberührt und in Kraft**; diese Entscheidung löst
sie nicht ab und trägt darum kein `Supersedes`),
[ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) (Festlegung 1 verengt sich ausdrücklich auf
zwei Artefakte und lässt die Frage, die hier entschieden wird, offen),
[ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) (Festlegung 1 trägt das
Prinzip, das diese Entscheidung auf eine zweite Artefaktklasse anwendet: Eigentum folgt dem
Ablauf, nicht der Datei),
[ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md) (dieselbe Familie, die
Ableitung aus dem Original — und dieselbe Disziplin, die Ableitung dort enden zu lassen, wo eine
bindende Aussage ohne Original beginnt),
[ADR-0031](0031-regierende-fassung-und-ort-der-zielstand-setzung.md) (ihre Option F nennt den
Welle-Plan *„fremdes Eigentum (Planner)"* und beruft sich dafür auf
[ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) — §Kontext hält fest, warum das keine
Quelle ist),
[ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) (die Welle-Plan-Datei wandert
bei der Closure; darum steht sie hier als Kennung und nicht als Pfad),
[ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) (Festlegung 1 und 2 binden den
Acceptance-Trigger unten),
[ADR-0016](0016-verweis-traegt-tag-und-zitat.md) (Festlegung 2 — *Eigenschaft statt Adresse*; jede
Baseline-Aussage unten trägt Tag und Zitat statt eines Pfad-Links),
[`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert),
[`MR-033`](../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist),
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)

**Schärft:** — Prozess-ADR ohne Spec-Stratum: sie entscheidet über die schreibende Rolle für eine
Vorgangs-Klasse im Planning-Lifecycle dieses Repos und ändert keine Spec-Aussage.

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md` §Ziel-Form: ADR (MADR). Die Rollen-Aussagen unten
messen gegen die regierende Fassung `v6.8.0`
([`MR-033`](../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)).

---

## Kontext

### Der Anlass

Ein Reviewer-Lauf hat gegen einen Commit im Implementations-Kontext ein HIGH mit Rollen-Widerspruch
gemeldet: Der Commit glich die `Lifecycle:`-Kopfnote von `welle-09`, `welle-11` und `welle-13`
sowie den Abschnitt *Slices vs. Wellen* in
[`docs/plan/planning/README.md`](../planning/README.md) an
[ADR-0046](0046-welle-datei-entsteht-mit-der-eroeffnung.md) Festlegung 1 an. Das Finding beruft
sich auf einen Satz in §Was diese Entscheidung nicht tut jener Datei
(`grep -c 'Die ersten drei gehören dem \*\*Planner\*\*' docs/plan/adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md`
→ **1**, kein Erwartungswert) und liest ihn als Zuweisung des **Artefakt-Typs** an den Planner. Der
Report benennt den Gegeneinwand selbst und stuft nicht herab, sondern übergibt an den Architect —
Baseline-Regelwerk `modul-08-agentenrollen.md` §Konflikt-Pfad als Rollen-Sequenz.

Die Frage ist damit nicht, ob jener Satz gilt, sondern **wie weit er reicht** — und was für alles
gilt, was er nicht erreicht.

### Was gemessen ist

Drei lebende Stellen dieses Repos bringen *Welle-Plan* und *Planner* in einem Satz zusammen; alle
drei sind gelesen. **Kein Erwartungswert**
([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — die Zahl wandert mit dem Bestand:

```sh
git grep -nE 'Welle-Plan|Welle-Datei' -- AGENTS.md harness/ spec/ docs/plan/adr/ .claude/ \
  ':!docs/reviews' ':!.harness/baseline' | grep -ic planner      # 3
```

- [ADR-0031](0031-regierende-fassung-und-ort-der-zielstand-setzung.md) §Verglichene Alternativen,
  Contra-Spalte einer **verworfenen** Option, Status `Proposed`: *„fremdes Eigentum (Planner,
  ADR-0015)"*. Die dort zitierte Quelle trägt die Aussage nicht — Festlegung 1 von
  [ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) lautet
  (`grep -c 'sie bestätigt keine fremde Zuordnung und setzt keine neue' docs/plan/adr/0015-rollen-eigentum-an-norm-artefakten.md`
  → **1**): *„Über die übrigen Norm-Artefakte trifft diese ADR **keine** Aussage — sie bestätigt
  keine fremde Zuordnung und setzt keine neue."* Eine Contra-Zelle einer nicht gewählten Option ist
  ohnehin keine Festlegung. Diese Stelle ist ein Befund, keine Quelle.
- [ADR-0046](0046-welle-datei-entsteht-mit-der-eroeffnung.md) §Was diese Entscheidung nicht tut —
  der strittige Satz.
- [ADR-0046](0046-welle-datei-entsteht-mit-der-eroeffnung.md) §Konsequenzen, erste Folgepflicht:
  *„Wie der Welle-Plan beides abbildet, entscheidet der Planner"*. Sie spricht über `welle-13` §1
  Punkt 2 — eine Aussage der Welle über ihre eigenen Slices.

### Was die zwei zitierten Quellen binden

Der strittige Satz ist **ableitend** formuliert: er beruft sich auf zwei Quellen und setzt nichts
daneben. Beide binden **Vorgänge**, nicht Dateien.

Baseline `v6.8.0`, `modul-08-agentenrollen.md` §Rollen-Sequenz für eine Welle weist die
**Eröffnung** zu — *„Die Eröffnung ist Planner-Arbeit"* — und führt die Closure als Tabelle mit
einer Zeile je **Schritt**. Kein Satz dort weist die Datei zu. Die Kommandos lösen den Tag aus
`BASELINE_TAG` auf und überleben damit den nächsten Sprung; **keine Erwartungswerte**:

```sh
B=".harness/baseline/$(grep -m1 '^BASELINE_TAG ?= ' Makefile | cut -d' ' -f3)/regelwerk/modul-08-agentenrollen.md"
grep -c 'Die Eröffnung ist Planner-Arbeit' "$B"   # 1
grep -cE '^\| \*\*[0-9]' "$B"                     # 8  (Schritt-Zeilen, je ein Vorgang)
```

[`AGENTS.md`](../../../AGENTS.md) §3.10 bindet den **Abschluss** und nennt den Welle-Plan als einen
seiner Bestandteile, nicht als eigenen Eigentumsposten:

```sh
grep -c 'ist der ganze Abschluss: die Closure-Notiz' AGENTS.md   # 1
grep -c 'ein berührter Welle-Plan und der' AGENTS.md             # 1
```

Eine Änderung an einem **bereits eröffneten** Welle-Plan, die weder zur Eröffnung noch zu einer
Closure gehört, fällt zwischen beide Quellen. Für sie benennt heute keine Quelle eine schreibende
Rolle — genau die Lage, die
[ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1 ausdrücklich offen lässt und
die [ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md) und
[ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) je für ihre Artefaktklasse
geschlossen haben.

### Was der strittige Gegenstand ist

Die drei Kopfnoten sind nach dem Nachzug byte-gleich zur vendored Ziel-Form, bis auf den
eingesetzten Namen der Ergebnis-Notiz, und die Ziel-Form nennt **keine** Welle-Kennung — sie sagt
über die einzelne Welle nichts. **Keine Erwartungswerte:**

```sh
T=".harness/baseline/$(grep -m1 '^BASELINE_TAG ?= ' Makefile | cut -d' ' -f3)/templates/docs/plan/planning/welle.template.md"
for f in docs/plan/planning/welle-*.md; do
  diff -q <(sed -n '10,15p' "$T") <(sed -n '3,8p' "$f") >/dev/null && echo "byte-gleich: $f"
done                                                # eine Zeile
grep -cE 'welle-[0-9]' <(sed -n '10,15p' "$T")      # 0
```

Der Text ist damit eine **Vorlagen-Instanz**, deren Originale die Ziel-Form und
[ADR-0046](0046-welle-datei-entsteht-mit-der-eroeffnung.md) Festlegung 1 sind — kein Planner-Urteil
über diese Welle. Daran trennt sich der Fall von `welle-13` §1 Punkt 2, den der Vorgänger-Vorgang
zu Recht in der Planner-Rolle nachzog: dort steht eine Anforderung *dieser* Welle an *ihre* Slices.

### Was den Ausschlag nicht gibt

Die Verteilung der Rollen-Präfixe über denselben Artefakt-Typ. Sie ist Bestand, und Bestand
begründet nichts — weder in die eine noch in die andere Richtung:

```sh
git log --format='%s' -- 'docs/plan/planning/welle-*.md' | grep -c '^Rolle Planner'     # 56
git log --format='%s' -- 'docs/plan/planning/welle-*.md' | grep -c '^Rolle Implement'   #  7
```

**Keine Erwartungswerte.** Die Zahlen zeigen allein, dass die Grenze ungeschrieben ist: Dieselbe
Kopfnote ist im Bestand sowohl in der Planner- als auch in der Implementer-Rolle angefasst worden,
und keine der beiden Läufe konnte sich auf etwas berufen.

## Entscheidung

**Wir wählen Option D: die offene Frage wird an der Eigenschaft entschieden, die die
Eigentums-Familie dieses Repos ohnehin trägt — am Vorgang.** Zwei Festlegungen:

### 1. Die schreibende Rolle eines Planungs-Artefakts folgt dem Vorgang, der es ändert, nicht dem Dateityp

Für den Welle-Plan heißt das: Eröffnung und die sechs Closure-Schritte sind Planner-Arbeit
(Baseline `v6.8.0`, `modul-08-agentenrollen.md` §Rollen-Sequenz für eine Welle;
[`AGENTS.md`](../../../AGENTS.md) §3.10 für den berührten Welle-Plan im Slice-Abschluss). Ein
**vorlagengebundener Nachzug** an einem bereits eröffneten Welle-Plan ist keiner dieser Vorgänge
und darf im Implementations-Kontext laufen.

Vorlagengebunden ist ein Nachzug, der drei Bedingungen **zugleich** erfüllt:

- Sein **Original** ist eine kanonische Quelle ([`AGENTS.md`](../../../AGENTS.md) §2) oder die
  vendored Ziel-Form.
- Er ersetzt **Text, der über die Sache gleich bleibt, welche Welle die Datei auch führt**.
- Er trifft **keine Aussage über diese Welle** — nicht über ihr Ziel, ihre Abgrenzung, ihren
  Trigger, ihre Slices, ihren Zustand.

Trifft ein Nachzug eine solche Aussage, ist er Planner-Arbeit. Die Probe ist in beide Richtungen
benannt: Wer die drei Bedingungen nicht alle bejahen kann, hat den Fall nicht — Zweifel fällt auf
den Planner zurück, nicht auf den laufenden Kontext.

### 2. Die Zuschreibung in [ADR-0046](0046-welle-datei-entsteht-mit-der-eroeffnung.md) §Was diese Entscheidung nicht tut reicht so weit wie die dort genannten Artefakte und die zitierten Quellen, und nicht weiter

Ein Satz in einer begrenzenden Sektion, der seine Zuweisung aus zwei Quellen **ableitet**, setzt
keine eigene; er bindet, was jene Quellen binden.
[ADR-0046](0046-welle-datei-entsteht-mit-der-eroeffnung.md) bleibt im Übrigen unverändert — beide
Festlegungen gelten fort, und diese Entscheidung trägt deshalb kein `Supersedes`.

## Verglichene Alternativen

Regeln dieser Sektion: **mindestens drei Optionen mit Pro/Contra** — „nichts tun" ist eine davon.
Eine ADR ohne Alternativen ist ein Postulat, kein Entscheidungsprotokoll (Baseline-Regelwerk
`modul-04-adrs.md` §Ziel-Form: ADR (MADR)).

| Option | Pro | Contra |
|---|---|---|
| A — nichts tun, die Frage offen lassen | kein Schreibaufwand; der Konflikt ließe sich einmalig per Verdikt schließen | Die Grenze bleibt ungeschrieben, und der nächste Nachzug steht vor derselben Frage. Der Bestand zeigt beide Antworten nebeneinander (56 gegen 7, Kommandos in §Kontext) — eine Lage, in der jeder Lauf sich auf Bestand berufen kann und keiner auf eine Quelle. Das ist genau die Klasse, für die [ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md) und [ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) schon zweimal eine Entscheidung gebraucht haben |
| B — die Datei-Lesart bestätigen: der Welle-Plan gehört als Datei dem Planner | eine Zeile, leicht zu prüfen; deckt sich mit dem Übergewicht im Bestand | Widerspricht dem Prinzip der eigenen Eigentums-Familie — [ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Festlegung 1: *„Eigentum ist eine Eigenschaft des Ablaufs, den ein Anweisungssatz operationalisiert, nicht der Datei-Existenz"* (`grep -c 'Eigentum ist eine Eigenschaft des Ablaufs' docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md` → **1**). Sie verlagerte außerdem jeden vorlagengebundenen Nachzug und jeden Adress-Nachzug in einen Planner-Vorgang, obwohl er keine Planungs-Entscheidung enthält, und machte aus einem Sprung-Nachzug über zehn Artefakte einen Rollen-Wechsel je Datei |
| C — [ADR-0046](0046-welle-datei-entsteht-mit-der-eroeffnung.md) per `Supersedes` ablösen und den Satz dort präzisieren | formal die Bahn, die [`AGENTS.md`](../../../AGENTS.md) §3.4 für eine Korrektur an einer `Accepted`-ADR nennt | Es gibt nichts zu korrigieren: Beide Festlegungen von [ADR-0046](0046-welle-datei-entsteht-mit-der-eroeffnung.md) sind unbestritten, und Festlegung 1 ist die Regel, die der auslösende Vorgang gerade umsetzt. Sie in eine abgelöste Datei zu schieben, um einen Satz aus ihrer **Abgrenzungs**-Sektion auszulegen, ersetzte eine Entscheidung, die niemand angreift. Der Präzedenzfall dieses Repos ist der andere: [`AGENTS.md`](../../../AGENTS.md) §3.11 verallgemeinert vier Entscheidungen, ohne eine davon abzulösen — *„Ihren Text schreibt sie **nicht** ab, und bei Konflikt gilt die ADR"* |
| **D — gewählt: eigene Entscheidung an der Vorgangs-Eigenschaft, ohne `Supersedes`** | Schließt die Lücke dort, wo sie ist, statt eine fremde Entscheidung zu bewegen. Wendet das Prinzip an, das [ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) bereits trägt, und bleibt in der Verengung, die [ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1 verlangt. Lässt [ADR-0046](0046-welle-datei-entsteht-mit-der-eroeffnung.md) unberührt in Kraft | Der Preis ist eine Probe mit **drei** Bedingungen statt einer Zeile: Sie ist ein Urteil und kein Muster, also nicht maschinell zu halten (§Fitness Function). Und sie entscheidet nur diese Vorgangs-Klasse — für jede weitere bleibt die Frage offen, wie schon nach [ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md) und [ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) |

### Was diese Entscheidung nicht tut

- **Sie entscheidet nicht, wem der Welle-Plan im Übrigen gehört.** Entschieden sind die zwei
  Vorgangs-Klassen aus Festlegung 1; für jeden Vorgang, der unter keine von beiden fällt, bleibt
  die Frage offen — dieselbe Verengung, die
  [ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1 für sich zieht. Eine
  abgeschriebene Übersicht wäre eine zweite Fassung, die driftet.
- **Sie ändert [ADR-0046](0046-welle-datei-entsteht-mit-der-eroeffnung.md) nicht.** Die Datei steht
  auf `Accepted` und ist nach [`AGENTS.md`](../../../AGENTS.md) §3.4 eingefroren; Festlegung 2 legt
  die Reichweite eines ihrer Sätze aus und nimmt ihr nichts.
- **Sie stuft kein Review-Finding herab.** Das Finding hat eine reale, ungeschriebene Grenze
  freigelegt; was hier entschieden wird, ist die Grenze — nicht die Kategorie des Findings.
  „Herabstufen, weil der Implementer widerspricht" ist nach Baseline `v6.8.0`,
  `modul-08-agentenrollen.md` §Konflikt-Pfad als Rollen-Sequenz kein zulässiges Verdikt und wird
  hier nicht gewählt.
- **Sie ist keine Senkung nach [`AGENTS.md`](../../../AGENTS.md) §3.5.** Keine Schwelle, kein
  Modul, keine Gate-Strenge wird bewegt; die Entscheidung betrifft eine Rollen-Grenze.
- **Sie legt keine Beobachtung an und vergibt keine Kennung im Beobachtungs-Register.** Ob dieser
  Fall unter eine vorhandene Kennung fällt oder eine neue braucht, ist ein Urteil über eine Klasse;
  die Route ist die Closure, und die gehört dem Planner
  ([`AGENTS.md`](../../../AGENTS.md) §3.10) — dieselbe Abgrenzung, die
  [ADR-0046](0046-welle-datei-entsteht-mit-der-eroeffnung.md) für ihren eigenen Anlass zieht.
- **Geltungsbereich: dieses Repo.** Was ein **emittiertes** Repo an Eigentums-Aussagen bekommt,
  entscheidet der Slice, der die Tool-Ebene entscheidet — nicht diese Datei.
- **Cutoff: ab der Annahme dieser Entscheidung, kein Nachrüsten.** Der Bestand wird nicht
  nachgezogen; ein Maßstab über ihn wäre dauerhaft rot und entwertete die Setzung — dieselbe
  Begründung wie in [ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) und
  [ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md).

## Konsequenzen

- **Positiv:** Der nächste vorlagengebundene Nachzug an einem laufenden Welle-Plan hat eine
  Antwort, statt sich auf Bestand berufen zu müssen. Die Klasse *fremdes Rollen-Artefakt im
  Implementations-Kontext* bekommt für diesen Fall eine Grenze, an der sie prüfbar ist — ihre
  eigene Definition verlangt ein Artefakt, *„dessen Eigentum eine Quelle einer anderen Rolle
  zuweist"*
  ([`BEO-ALL/fremdes-rollen-artefakt-im-implementations-kontext`](../planning/observations/BEO-ALL/fremdes-rollen-artefakt-im-implementations-kontext/observation.md)),
  und ab hier ist entscheidbar, wann eine zuweist.
- **Positiv:** Die Eigentums-Familie bleibt an **einer** Eigenschaft aufgehängt. Nach
  [ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md) (Original) und
  [ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) (Ablauf) kommt keine dritte
  Achse hinzu, sondern eine zweite Anwendung derselben.
- **Negativ:** Die Probe hat drei Bedingungen und ist ein Urteil. Wer sie falsch bejaht, hat eine
  Planungs-Entscheidung im Implementations-Kontext getroffen, und kein Gate meldet es
  (§Fitness Function).
- **Negativ:** Für jede Vorgangs-Klasse am Welle-Plan, die weder Eröffnung noch Closure noch
  vorlagengebundener Nachzug ist, bleibt die Frage offen. Das ist sichtbar und benannt, aber es
  bleibt eine Lücke.
- **Folgepflicht (Reviewer), fällig als eigener Vorgang:** Der Review-Report
  `2026-09-14-slice-flache-welle-ist-eroeffnet-nicht-geplant` ist Lauf-Beleg und wird nicht
  überschrieben; sein Finding F-1 ist mit dieser Entscheidung aufgelöst, nicht widerlegt. Ob die
  Grenze aus Festlegung 1 in `.harness/skills/reviewer.md` aufgenommen wird, entscheidet der
  Reviewer — die Datei gehört der ausführenden Rolle
  ([ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Festlegung 1), und diese
  Entscheidung schreibt sie nicht.
- **Folgepflicht (Implementer), fällig nach der Annahme:** Der Abschnitt *Slices vs. Wellen* in
  [`docs/plan/planning/README.md`](../planning/README.md) ist an die Kopfnote der Welle-Vorlage
  angeglichen statt an seine eigene Ziel-Form und hat dabei die Zuschreibung
  *Sequenzierungs-Autorität* an die Roadmap verloren. Das ist keine Rollen-, sondern eine
  Ziel-Form-Frage und fällt unter Festlegung 1; der Nachzug wartet die Annahme ab, damit während
  der offenen Frage kein zweiter Fall derselben Klasse entsteht.
- **Folgepflicht, fällig vor dem nächsten Accept-Übergang von
  [ADR-0031](0031-regierende-fassung-und-ort-der-zielstand-setzung.md):** Deren Option F beruft
  sich für *„fremdes Eigentum (Planner)"* auf
  [ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md), die das nicht trägt (§Kontext). Solange
  jene Datei `Proposed` ist, ist das behebbar; mit ihrem Accept friert es ein. Diese Entscheidung
  behebt es nicht — sie hält den Befund fest.
- **Folgepflicht (Planner), fällig bei der Closure des auslösenden Slice:** Dass eine
  Eigentums-Frage ohne Quelle im laufenden Vorgang faktisch beantwortet wurde, ist eine
  Beobachtung. Ob sie unter eine vorhandene Kennung fällt oder eine neue braucht, ist ein Urteil
  über eine Klasse und keine Messung; gemessen ist allein der Umfang des Registers, `107`
  Verzeichnisse (`ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l`, kein Erwartungswert,
  datierte Messung nach
  [`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)).
  Die Closure entscheidet es; diese Datei legt nichts an.

## Fitness Function (falls maschinell prüfbar)

**Diese Entscheidung hat keinen Wächter, und das gehört benannt**
([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). Kein
Modul der [`.d-check.yml`](../../../.d-check.yml) liest Commits — `grep -n '^modules:' .d-check.yml`
nennt die aktivierten —, und `make mutate` kennt zwei Fehlschlag-Formen, keine davon für einen
Commit-Zuschnitt oder eine Rollen-Zuordnung. Dieselbe Lage stellen
[`AGENTS.md`](../../../AGENTS.md) §3.8 und §3.10 für ihren eigenen Commit-Zuschnitt fest.

| Tooling | Regel | Make-Target |
|---|---|---|
| — | Festlegung 1 (die Drei-Bedingungen-Probe) hat **keinen** Wächter. Sie ist ein **Urteil und kein Muster**: Ob ein Absatz eine Aussage über *diese* Welle trifft, ist am Text zu lesen und nicht zu zählen — ein `grep` zählte Absätze, nicht Verstöße, und gäbe ein Muster als Kriterium aus, das keines ist ([`AGENTS.md`](../../../AGENTS.md) §3.6). Träger ist der Rollen-Wechsel **vor** der Änderung | — |
| — | Festlegung 2 (die Reichweite eines Satzes in einer fremden, eingefrorenen Datei) hat **keinen** Wächter: Kein Modul hält eine Aussage gegen die Reichweite ihrer Quelle. Träger ist diese Datei | — |

**Eine Hälfte ist trotzdem beobachtbar, und sie ist nicht die Regel:** Ob ein Commit ausschließlich
Artefakte einer Rolle berührt, lässt sich nachträglich an `git log --stat` ablesen — das ist die
Ablesbarkeit, die [`AGENTS.md`](../../../AGENTS.md) §3.8 verlangt, kein Gate. Sie sagt, *welche
Dateien* ein Commit anfasste, und nichts darüber, *welcher Vorgang* er war.

## Re-Evaluierungs-Trigger

- **Wenn eine Quelle das Eigentum am Welle-Plan datei- statt vorgangsgebunden ausspricht** — ein
  Baseline-Sprung, eine Hard Rule in [`AGENTS.md`](../../../AGENTS.md) oder eine spätere ADR
  *(beobachtbar daran, dass das `git grep`-Kommando aus §Kontext einen vierten Treffer liefert,
  der eine Festlegung ist)*: Festlegung 1 ist dann abgelöst statt ergänzend, und die Wahl zwischen
  den Optionen ist neu zu halten — die Gegenposition steht in Option B.
- **Wenn ein Nachzug unter Festlegung 1 nachweislich eine Aussage über eine Welle verändert hat**
  *(beobachtbar an einem Review-Finding, das genau das meldet)*: Die Drei-Bedingungen-Probe trennt
  dann nicht, und die Grenze ist neu zu ziehen — im Zweifel zurück auf Option B.
- **Wenn die regierende Fassung die Rollen-Sequenz für eine Welle von Schritten auf Artefakte
  umstellt** *(beobachtbar daran, dass eines der zwei `grep -c`-Kommandos aus §Kontext unter einem
  neuen `BASELINE_TAG` **0** ausgibt)*: Festlegung 1 stützt sich dann auf eine Stelle, die es nicht
  mehr gibt, und der Adaptions-Durchgang des Sprungs hält sie neu.
- **Wenn dieselbe Klasse — eine Eigentums-Frage ohne Quelle wird im laufenden Vorgang faktisch
  beantwortet — im Beobachtungs-Register 3× erreicht** *(beobachtbar am Zähler ihres
  Verzeichnisses)*: Dann ist die Verengung oben aufgebraucht, und die Frage gehört als allgemeine
  Regel entschieden statt ein viertes Mal je Artefaktklasse.

### Der Acceptance-Trigger

Diese Entscheidung steht auf `Proposed`. Sie wird `Accepted`, **wenn eine Reviewer-Runde sie gegen
[ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md),
[ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) und
[ADR-0046](0046-welle-datei-entsteht-mit-der-eroeffnung.md) auf Konsistenz geprüft hat und ihr
Report ohne blockierenden Befund an der Substanz der beiden Festlegungen in `docs/reviews/`
liegt.** Ein blockierender Befund an der **Darstellung** — Adressform, Zahl ohne Kommando,
Zitat-Stelle — wird behoben und hindert die Annahme nicht, solange die Datei `Proposed` ist und die
Behebung keine der beiden Festlegungen ändert; ändert sie eine, ist es ein Substanz-Befund und
blockiert.

Der Beleg ist eine Runde der prüfenden Rolle; die Nachmessung des Kontexts, der einen Befund
auflöst, ist keiner
([ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 2). Die
Accept-Zeile der §Geschichte nennt ihn als **Kennung**, nicht als Pfad-Link (ebenda, Festlegung 1).

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-09-14 | **Proposed** | Architect-Lauf als Verdikt im Rollen-Konflikt nach Baseline `v6.8.0`, `modul-08-agentenrollen.md` §Konflikt-Pfad als Rollen-Sequenz. Anlass ist Finding F-1 (HIGH, Rollen-Widerspruch) des Review-Reports `2026-09-14-slice-flache-welle-ist-eroeffnet-nicht-geplant`. Gewähltes Verdikt: *Lockerung legitim, aber undokumentiert* — der Vorgang stützte sich auf eine Geltungsbereichs-Grenze, die sachlich trägt und die kein Dokument führte; diese Datei zieht sie nach, und der auslösende Slice schließt nicht vor ihrer Annahme. |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0048` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).
