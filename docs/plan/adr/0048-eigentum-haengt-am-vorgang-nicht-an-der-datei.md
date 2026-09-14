# ADR-0048: Eigentum am Welle-Plan hängt am Vorgang, der ihn ändert, nicht an der Datei

**Status:** Proposed

**Datum:** 2026-09-14

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[ADR-0046](0046-welle-datei-entsteht-mit-der-eroeffnung.md) (ihre Abgrenzungs-Sektion trägt den
Satz, dessen Reichweite hier ausgelegt wird — **unberührt und in Kraft**; diese Entscheidung löst
sie nicht ab und trägt darum kein `Supersedes`),
[ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) (Festlegung 1 verengt sich ausdrücklich auf
zwei Artefakte und lässt die Frage, die hier entschieden wird, offen),
[ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) (Festlegung 1 zeigt, dass
Eigentum an einer **Eigenschaft** hängen darf statt an der Datei-Existenz — ihre Eigenschaft ist
der Ablauf, den das Artefakt **beschreibt**, und die Zuordnung bleibt darum über jede Änderung
stabil. Diese Entscheidung hängt Eigentum an den **Vorgang, der das Artefakt ändert**; das ist eine
andere Achse und wird unten als solche benannt, nicht als dieselbe ausgegeben. Festlegung 1
derselben Datei ist zugleich die dritte Quelle des Satzes, den Festlegung 2 unten auslegt),
[ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md) (dieselbe Familie: die
Ableitung aus dem **Original**, das eine Aussage wiedergibt — und dieselbe Disziplin, die Ableitung
dort enden zu lassen, wo ein Artefakt eine bindende Aussage ohne Original trägt),
[ADR-0031](0031-regierende-fassung-und-ort-der-zielstand-setzung.md) (ihre Option F nennt den
Welle-Plan *„fremdes Eigentum (Planner)"* und beruft sich dafür auf
[ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) — §Kontext hält fest, warum das keine
Quelle ist),
[ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) (die Welle-Plan-Datei wandert
bei der Closure; darum steht sie hier als Kennung und nicht als Pfad),
[ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) (Festlegung 1, 2 und 3 binden
den Acceptance-Trigger unten),
[ADR-0016](0016-verweis-traegt-tag-und-zitat.md) (Festlegung 2 — *Eigenschaft statt Adresse*; jede
Baseline-Aussage unten trägt Tag und Zitat statt eines Pfad-Links),
[`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert),
[`MR-033`](../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist),
[`MR-051`](../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
(Setzung 2 für den Register-Zähler in §Konsequenzen — die Klasse, die
[`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
nach eigener Kopf-Marke nicht erreicht),
[`MR-055`](../../../harness/conventions.md#mr-055--eine-stellen-messung-trägt-keine-folgerung-über-eine-eigenschaft)
(die Grenze, die die Negativ-Messungen in §Kontext und §Konsequenzen ausdrücklich ziehen; sein
Geltungsbereich nimmt `docs/plan/adr/` aus — diese Datei wendet ihn als Selbstbindung an),
[`MR-057`](../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
(die Kennungs-Form, gegen die das letzte Muster in §Kontext misst — Nummer **und** Name),
[`MR-058`](../../../harness/conventions.md#mr-058--eine-messung-die-ihr-eigener-vorgang-bewegt-wird-nach-dem-vorgang-genommen)
(die benannte Klasse hinter der Pathspec-Verengung in §Kontext; ihr Geltungsbereich nimmt
`docs/plan/adr/` ebenso aus — sie benennt die Lage, sie bindet diese Datei nicht),
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)

**Schärft:** — Prozess-ADR ohne Spec-Stratum: sie entscheidet über die schreibende Rolle für eine
Vorgangs-Klasse am Welle-Plan dieses Repos und ändert keine Spec-Aussage.

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
Baseline `v6.8.0`, `modul-08-agentenrollen.md` §Konflikt-Pfad als Rollen-Sequenz.

Die Frage ist damit nicht, ob jener Satz gilt, sondern **wie weit er reicht** — und was für alles
gilt, was er nicht erreicht.

### Was gemessen ist, und was die Messung nicht trägt

Im Prüfbereich des Kommandos unten bringen **drei** Stellen *Welle-Plan* und *Planner* in einem
Satz zusammen; alle drei sind gelesen. Der Prüfbereich ist fünf Pfade breit und **nicht** das Repo —
`docs/plan/planning/**`, `docs/user/`, `README.md` und `internal/` erreicht er nicht. **Der Pathspec
nimmt außerdem diese Datei aus** — sie ist der **Gegenstand** der Frage und keine ihrer Quellen;
ohne die Verengung zählte die Messung ihre eigenen Zeilen mit und wäre an keinem Stand nach ihrem
eigenen Commit nachzumessen (die benannte Klasse führt
[`MR-058`](../../../harness/conventions.md#mr-058--eine-messung-die-ihr-eigener-vorgang-bewegt-wird-nach-dem-vorgang-genommen)).
**Kein Erwartungswert**
([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — die Zahl wandert mit dem Bestand:

```sh
git grep -nE 'Welle-Plan|Welle-Datei' -- AGENTS.md harness/ spec/ docs/plan/adr/ .claude/ \
  ':!docs/reviews' ':!.harness/baseline' ':!docs/plan/adr/0048-*.md' | grep -ic planner   # 3
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
  der ausgelegte Satz.
- [ADR-0046](0046-welle-datei-entsteht-mit-der-eroeffnung.md) §Konsequenzen, erste Folgepflicht:
  *„Wie der Welle-Plan beides abbildet, entscheidet der Planner"*. Sie spricht über `welle-13` §1
  Punkt 2 — eine Aussage der Welle über ihre eigenen Slices.

**Was diese Messung nicht trägt, steht hier, weil sie sonst als Vollständigkeits-Aussage gelesen
wird.** Sie ist eine **Stellen-Messung** über zwei Komposita und eine Pfadliste und trägt keine
Folgerung über die Eigenschaft *es gibt keine Quelle*
([`MR-055`](../../../harness/conventions.md#mr-055--eine-stellen-messung-trägt-keine-folgerung-über-eine-eigenschaft)).
Eine breitere Suche findet einen vierten Treffer, und eine Rollen-Aussage liegt ganz außerhalb des
Musters:

```sh
git grep -nE 'Welle-Plan|Welle-Datei|Wellen-Plan|welle-\*\.md' \
  -- ':!.harness/baseline' ':!docs/reviews' ':!docs/plan/planning/done' \
     ':!docs/plan/adr/0048-*.md' | grep -ic planner        # 4
grep -n 'Schreibt Pläne' .claude/agents/planner.md         # 3
```

Der vierte Treffer ist eine Evidence-Datei des Beobachtungs-Registers — ein Beleg, keine
Norm-Quelle. Die zweite Zeile ist das `description`-Feld von
[`.claude/agents/planner.md`](../../../.claude/agents/planner.md): *„Schneidet Wellen und Slices …
**Schreibt Pläne**, keinen Produktionscode."* Sie ist die direkteste Rollen-Aussage des Repos und
trotzdem **keine Quelle im Sinne von** [ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md):
`.claude/agents/*.md` steht in keinem der neun Ränge
([`AGENTS.md`](../../../AGENTS.md) §2) und ist nach
[ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Festlegung 3 ausdrücklich
**nicht** mitentschieden. **Das ist ein Urteil über eine Stelle, kein Messergebnis**
([`AGENTS.md`](../../../AGENTS.md) §3.6) — es steht hier, damit die nächste Runde es prüfen kann,
statt es unter einer Zahl zu finden.

Was die Messungen tragen, ist deshalb der schwächere und ausreichende Satz: **Über jede Stelle, die
sie erreichen, benennt keine Quelle eine schreibende Rolle für eine Text-Änderung an einem bereits
eröffneten Welle-Plan.** Wer eine kennt, die sie nicht erreichen, hat den Fall — und dann greift
Re-Evaluierungs-Trigger 1.

### Was die zitierten Quellen binden

Der ausgelegte Satz ist **ableitend** formuliert: er beruft sich auf **drei** Quellen und setzt
nichts daneben. Zwei davon tragen Welle-Plan und Roadmap, die dritte den Anweisungssatz zum
Wellen-Schnitt; der volle Wortlaut steht in Festlegung 2. Die zwei, die den Welle-Plan betreffen,
binden **Vorgänge**, nicht Dateien.

Baseline `v6.8.0`, `modul-08-agentenrollen.md` §Rollen-Sequenz für eine Welle weist die
**Eröffnung** zu — *„Die Eröffnung ist Planner-Arbeit"* — und führt die Closure als Tabelle mit
einer Zeile je **Schritt**. Über deren Träger sagt derselbe Abschnitt wörtlich: *„Nur 1, 2 und 3b
tragen einen Rollenwechsel; 3a, 3c, 4, 5 und 6 laufen im Planner-Kontext"* — Schritt 1 liegt beim
Verifier, Schritt 2 und 3b führen über den Architect. Der Implementer ist in keinem der sechs
Schritte Träger. Kein Satz dort weist die **Datei** zu. Die drei Kommandos dieses Blocks lösen den
Tag aus `BASELINE_TAG` auf und überleben damit den nächsten Sprung; **keine Erwartungswerte**:

```sh
B=".harness/baseline/$(grep -m1 '^BASELINE_TAG ?= ' Makefile | cut -d' ' -f3)/regelwerk/modul-08-agentenrollen.md"
grep -c 'Die Eröffnung ist Planner-Arbeit' "$B"               # 1
grep -cE '^\| \*\*[0-9]' "$B"                                 # 8  (Schritt-Zeilen, je ein Vorgang)
grep -c 'Nur 1, 2 und 3b tragen einen Rollenwechsel' "$B"     # 1
```

[`AGENTS.md`](../../../AGENTS.md) §3.10 bindet den **Abschluss** und nennt den Welle-Plan als einen
seiner Bestandteile, nicht als eigenen Eigentumsposten:

```sh
grep -c 'ist der ganze Abschluss: die Closure-Notiz' AGENTS.md   # 1
grep -c 'ein berührter Welle-Plan und der' AGENTS.md             # 1
```

Eine Änderung an einem **bereits eröffneten** Welle-Plan, die weder zur Eröffnung noch zu einer
Closure gehört, fällt zwischen beide Quellen. Für sie benennt keine der gemessenen Stellen eine
schreibende Rolle — genau die Lage, die
[ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1 ausdrücklich offen lässt und
die [ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md) und
[ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) je für ihre Artefaktklasse
geschlossen haben.

### Was der strittige Gegenstand ist

Die drei Kopfnoten sind nach dem Nachzug byte-gleich zur vendored Ziel-Form, bis auf den
eingesetzten Namen der Ergebnis-Notiz, und die Ziel-Form nennt **keine** Welle-Kennung — sie sagt
über die einzelne Welle nichts. Die Schleife belegt die byte-gleiche Datei, die zwei `diff`-Läufe
darunter belegen die zwei übrigen; das letzte Muster trifft beide Kennungs-Formen, die Nummer wie
den Namen
([`MR-057`](../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)).
**Keine Erwartungswerte:**

```sh
T=".harness/baseline/$(grep -m1 '^BASELINE_TAG ?= ' Makefile | cut -d' ' -f3)/templates/docs/plan/planning/welle.template.md"
for f in docs/plan/planning/welle-*.md; do
  diff -q <(sed -n '10,15p' "$T") <(sed -n '3,8p' "$f") >/dev/null && echo "byte-gleich: $f"
done                                                    # eine Zeile
for f in docs/plan/planning/welle-*.md; do
  diff <(sed -n '10,15p' "$T") <(sed -n '3,8p' "$f")
done                                                    # zwei Differenzen, je Zeile 3, je der Name der Ergebnis-Notiz
grep -cE 'welle-[0-9a-zäöü]' <(sed -n '10,15p' "$T")    # 0  (die Ziel-Form trägt nur `welle-<Kennung>`)
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
und keiner der beiden Läufe konnte sich auf etwas berufen.

## Entscheidung

**Wir wählen Option D: die offene Frage wird an der Eigenschaft entschieden, die den Konflikt
erzeugt hat — am Vorgang —, und nur für das Artefakt, an dem sie gemessen ist.** Zwei Festlegungen:

### 1. Die schreibende Rolle am Welle-Plan folgt dem Vorgang, der ihn ändert, nicht dem Dateityp

Gebunden ist **der Welle-Plan** (`docs/plan/planning/welle-*.md` und sein Ruheort in `done/`) und
kein anderes Artefakt; §Was diese Entscheidung nicht tut zählt auf, was damit **nicht** entschieden
ist.

**Planner-Arbeit sind:** die Eröffnung (Baseline `v6.8.0`, `modul-08-agentenrollen.md`
§Rollen-Sequenz für eine Welle: *„Die Eröffnung ist Planner-Arbeit"*) und die sechs Schritte der
Closure, die dort im Planner-Kontext laufen und ihre drei Rollenwechsel an Verifier und Architect
führen, nie an den Implementer; dazu der berührte Welle-Plan im Slice-Abschluss
([`AGENTS.md`](../../../AGENTS.md) §3.10).

**Ein vorlagengebundener Nachzug** an einem bereits eröffneten Welle-Plan ist keiner dieser
Vorgänge und darf im Implementations-Kontext laufen. Vorlagengebunden ist ein Nachzug, der **vier**
Bedingungen **zugleich** erfüllt:

1. **Original benannt.** Der Nachzug nennt sein Original: die vendored Ziel-Form des betroffenen
   Artefakts oder eine kanonische Quelle nach [`AGENTS.md`](../../../AGENTS.md) §2.
2. **Original wiedergegeben.** Der neue Text **gibt dieses Original wieder** — byte-gleich bis auf
   Kennungen, die die Vorlage als Platzhalter führt, oder im wörtlichen Zitat. Eine freie
   Neuformulierung ist keine Wiedergabe, auch wenn sie dasselbe meint; sie ist eine Formulierung,
   und Formulieren ist der Vorgang, der dem Planner gehört.
3. **Der ersetzte Text war welle-neutral.** Er sagt über die Sache dasselbe, welche Welle die Datei
   auch führt.
4. **Der neue Text trifft keine Aussage über diese Welle** — nicht über ihr Ziel, ihre Abgrenzung,
   ihren Trigger, ihre Slices, ihren Zustand.

Bedingung 3 misst den **ersetzten**, Bedingung 4 den **neuen** Text; Bedingung 1 und 2 binden ihn
an sein Original. Trifft ein Nachzug eine Aussage über die Welle, oder gibt er kein Original wieder,
ist er Planner-Arbeit. Die Probe ist in beide Richtungen benannt: Wer die vier Bedingungen nicht
alle bejahen kann, hat den Fall nicht — Zweifel fällt auf den Planner zurück, nicht auf den
laufenden Kontext.

**Warum Bedingung 1 neben der Ziel-Form auch eine kanonische Quelle zulässt:** Ein Welle-Plan gibt
nicht nur seine Vorlage wieder, sondern auch Regeln, die in [`AGENTS.md`](../../../AGENTS.md) oder
im Baseline-Regelwerk stehen — die `Lifecycle:`-Kopfnote ist beides zugleich. Die Breite dieser
Bedingung wird von Bedingung 2 wieder eingeholt: Was an einer Stelle nicht als Aussage über die
Form des Welle-Plans dasteht, lässt sich dort auch nicht **wiedergeben**. Ein Rang, der über diese
Form nichts sagt, wird damit praktisch kein Original, ohne dass die Bedingung ihn namentlich
ausschließen müsste.

### 2. Der ausgelegte Satz in [ADR-0046](0046-welle-datei-entsteht-mit-der-eroeffnung.md) §Was diese Entscheidung nicht tut bindet, was die von ihm zitierten Quellen binden — und nicht mehr

**Eine Grenze, nicht zwei.** Der Satz nennt Artefakte, aber er weist ihnen nichts aus eigener Kraft
zu; er leitet ab — und zwar aus **drei** Quellen, im vollen Wortlaut
([ADR-0016](0016-verweis-traegt-tag-und-zitat.md) Festlegung 2):

> *„Die ersten drei gehören dem **Planner** — für Welle-Plan und Roadmap nach `v6.7.2`,
> `modul-08-agentenrollen.md` §Rollen-Sequenz für eine Welle (*„Die Eröffnung ist Planner-Arbeit"*
> und Schritt 6 *Roadmap fortschreiben · Planner*) und nach `AGENTS.md` §3.10, für den
> Anweisungssatz nach ADR-0028 Festlegung 1."*

Ein Satz in einer begrenzenden Sektion, der seine Zuweisung ableitet, setzt keine eigene. Für jedes
der drei genannten Artefakte gilt deshalb, was **die ihm zugeordnete** Quelle ihm zuweist — nicht
mehr und nicht weniger, und die Zuordnung ist im Satz selbst ausgesprochen: `welle-13` und die
Roadmap über die ersten zwei Quellen, der Anweisungssatz zum Wellen-Schnitt über
[ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Festlegung 1. **Die dritte
Zuordnung bleibt damit unberührt**, und sie steht ohnehin nicht auf diesem Satz: Jene Festlegung
bindet den Anweisungssatz aus eigener Kraft.

Für `welle-13` §1 Punkt 2 ändert das nichts: Der Nachzug dort bleibt Planner-Arbeit, weil
Bedingung 3 und 4 aus Festlegung 1 ihn ausschließen — dort steht eine Anforderung dieser Welle an
ihre Slices. Er bleibt es also aus der Sache, nicht aus einer Zuweisung, die der Satz nicht trägt.

[ADR-0046](0046-welle-datei-entsteht-mit-der-eroeffnung.md) bleibt im Übrigen unverändert — beide
Festlegungen gelten fort, und diese Entscheidung trägt deshalb kein `Supersedes`.

## Verglichene Alternativen

Regeln dieser Sektion: **mindestens drei Optionen mit Pro/Contra** — „nichts tun" ist eine davon.
Eine ADR ohne Alternativen ist ein Postulat, kein Entscheidungsprotokoll (Baseline-Regelwerk
`modul-04-adrs.md` §Ziel-Form: ADR (MADR)).

| Option | Pro | Contra |
|---|---|---|
| A — nichts tun, die Frage offen lassen | kein Schreibaufwand; der Konflikt ließe sich einmalig per Verdikt schließen | Die Grenze bleibt ungeschrieben, und der nächste Nachzug steht vor derselben Frage. Der Bestand zeigt beide Antworten nebeneinander (56 gegen 7, Kommandos in §Kontext) — eine Lage, in der jeder Lauf sich auf Bestand berufen kann und keiner auf eine Quelle. Das ist genau die Klasse, für die [ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md) und [ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) schon zweimal eine Entscheidung gebraucht haben |
| B — die Datei-Lesart bestätigen: der Welle-Plan gehört als Datei dem Planner | eine Zeile, leicht zu prüfen; deckt sich mit dem Übergewicht im Bestand; **und sie braucht keine Probe** — genau die vier Bedingungen aus Festlegung 1 entfielen, und mit ihnen das Urteil, das sie verlangen | Verlagert jeden vorlagengebundenen Nachzug und jeden Adress-Nachzug in einen Planner-Vorgang, obwohl er keine Planungs-Entscheidung enthält, und macht aus einem Sprung-Nachzug über zehn Artefakte einen Rollen-Wechsel je Datei. Sie widerspricht außerdem der Bauform, die [ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Festlegung 1 vorführt — *„Eigentum ist eine Eigenschaft des Ablaufs, den ein Anweisungssatz operationalisiert, nicht der Datei-Existenz"* (`grep -c 'Eigentum ist eine Eigenschaft des Ablaufs' docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md` → **1**); dort ist die tragende Eigenschaft eine andere als hier, die Absage an die **Datei** als Träger ist dieselbe |
| C — [ADR-0046](0046-welle-datei-entsteht-mit-der-eroeffnung.md) per `Supersedes` ablösen und den Satz dort präzisieren | formal die Bahn, die [`AGENTS.md`](../../../AGENTS.md) §3.4 für eine Korrektur an einer `Accepted`-ADR nennt | Es gibt nichts zu korrigieren: Beide Festlegungen von [ADR-0046](0046-welle-datei-entsteht-mit-der-eroeffnung.md) sind unbestritten, und Festlegung 1 ist die Regel, die der auslösende Vorgang gerade umsetzt. Sie in eine abgelöste Datei zu schieben, um einen Satz aus ihrer **Abgrenzungs**-Sektion auszulegen, ersetzte eine Entscheidung, die niemand angreift. Der Präzedenzfall dieses Repos ist der andere: [`AGENTS.md`](../../../AGENTS.md) §3.11 verallgemeinert vier Entscheidungen, ohne eine davon abzulösen — *„Ihren Text schreibt sie **nicht** ab, und bei Konflikt gilt die ADR"* |
| E — dieselbe Regel für alle lebenden Planungs-Artefakte setzen (Welle-Plan, Roadmap, Slice-Plan, `docs/plan/planning/README.md`) | eine Regel statt vier; die Vorgangs-Eigenschaft ist nicht auf den Welle-Plan beschränkt | Gemessen ist nur der Welle-Plan (§Kontext). Für die Roadmap benennt [ADR-0046](0046-welle-datei-entsteht-mit-der-eroeffnung.md) §Konsequenzen den Planner, und Baseline `v6.8.0`, `modul-08-agentenrollen.md` Schritt 6 weist *Roadmap fortschreiben* ebenfalls ihm zu — eine breite Fassung liefe Gefahr, beides zu unterlaufen. Sie wäre genau der Zug, den diese Datei einem anderen gerade vorwirft: eine Zuschreibung über den gemessenen Fall hinaus zu dehnen ([ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1) |
| **D — gewählt: eigene Entscheidung an der Vorgangs-Eigenschaft, nur für den Welle-Plan, ohne `Supersedes`** | Schließt die Lücke dort, wo sie gemessen ist, statt eine fremde Entscheidung zu bewegen oder eine ungemessene Fläche mitzunehmen. Bleibt in der Verengung, die [ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1 verlangt. Lässt [ADR-0046](0046-welle-datei-entsteht-mit-der-eroeffnung.md) unberührt in Kraft | Der Preis ist doppelt: eine Probe mit **vier** Bedingungen statt einer Zeile — ein Urteil, kein Muster, also nicht maschinell zu halten (§Fitness Function) —, und ein Geltungsbereich, der nur ein Artefakt deckt. Für jedes weitere Planungs-Artefakt bleibt die Frage offen, wie schon nach [ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md) und [ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) |

### Was diese Entscheidung nicht tut

- **Sie entscheidet nichts über ein anderes Planungs-Artefakt als den Welle-Plan.** Nicht über
  [`docs/plan/planning/README.md`](../planning/README.md), nicht über die Roadmap, nicht über den
  Slice-Plan, nicht über das Beobachtungs-Register und nicht über die Register-README daneben. Für
  die **Roadmap** gilt unverändert, was
  [ADR-0046](0046-welle-datei-entsteht-mit-der-eroeffnung.md) §Konsequenzen ihrer zweiten
  Folgepflicht zuweist und was Baseline `v6.8.0`, `modul-08-agentenrollen.md` Schritt 6
  (*Roadmap fortschreiben · Planner*) bindet; diese Datei unterläuft beides nicht und dehnt ihre
  Probe nicht dorthin.
- **Sie entscheidet nichts über den Anweisungssatz zum Wellen-Schnitt.** Für
  [`.claude/commands/plan-welle.md`](../../../.claude/commands/plan-welle.md) gilt unverändert
  [ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Festlegung 1 — er gehört der
  Rolle, die ihn **ausführt**, und das ist nach seinem eigenen Eröffnungssatz der Planner. Er ist
  kein Welle-Plan, die Probe aus Festlegung 1 greift für ihn nicht, und Festlegung 2 nimmt ihm
  nichts: Sie hält gerade fest, dass die dritte Quelle des ausgelegten Satzes ihn trägt.
- **Sie entscheidet nicht, wem der Welle-Plan im Übrigen gehört.** Entschieden sind die
  Vorgangs-Klassen aus Festlegung 1; für jeden Vorgang, der unter keine von ihnen fällt, bleibt die
  Frage offen — dieselbe Verengung, die
  [ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1 für sich zieht. Eine
  abgeschriebene Übersicht wäre eine zweite Fassung, die driftet.
- **Sie ändert [ADR-0046](0046-welle-datei-entsteht-mit-der-eroeffnung.md) nicht.** Die Datei steht
  auf `Accepted` und ist nach [`AGENTS.md`](../../../AGENTS.md) §3.4 eingefroren; Festlegung 2 legt
  die Reichweite eines ihrer Sätze aus und nimmt ihr nichts.
- **Der Ort dieser Auslegung ist eine Wahl, und sie steht hier.** Eine `Accepted`-ADR wird in
  diesem Repo auch in einem **lebenden** Artefakt ausgelegt — der Präzedenzfall steht in
  [`harness/conventions.md`](../../../harness/conventions.md) §Modus-Deklaration pro Sub-Area
  (*„Diese Umdeutung steht hier und nur hier — die ADR wird dafür nicht angefasst"*). Gewählt ist
  hier die ADR, weil die Auslegung eine **Festlegung** trägt und Festlegungen in ADRs leben. Der
  Preis: Eine spätere Korrektur der Auslegung ist nach dem Accept nur noch als Folge-ADR mit
  `Supersedes ADR-0048` erreichbar.
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
  und ab hier ist für den Welle-Plan entscheidbar, wann eine zuweist.
- **Positiv:** Die Eigentums-Familie bekommt eine **dritte** Achse, und sie steht als solche da.
  [ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md) leitet aus dem
  **Original** ab, das eine Aussage wiedergibt — *„Derivativ ist eine Eigenschaft der Aussage,
  nicht der Datei"* —, und lässt die Zuordnung dort enden, wo ein Artefakt eine bindende Aussage
  **ohne** Original trägt. [ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) hängt
  sie an den **Ablauf, den ein Artefakt beschreibt**, und bleibt darin über seine Änderungen
  stabil. Diese Entscheidung hängt sie an den **Vorgang, der das Artefakt ändert**; die Zuordnung
  wechselt damit je Änderung. Drei Achsen, keine davon die andere — und diese ist neu und gehört
  benannt statt in eine Reihe gestellt: Ein Welle-Plan beschreibt keinen Rollen-Ablauf und
  projiziert keine Originale, er plant eine Welle.
- **Negativ:** Die Probe hat vier Bedingungen und ist ein Urteil. Wer sie falsch bejaht, hat eine
  Planungs-Entscheidung im Implementations-Kontext getroffen, und kein Gate meldet es
  (§Fitness Function).
- **Negativ:** Eine wechselnde Zuordnung ist teurer zu lesen als eine feste. Wer wissen will, wem
  eine Welle-Plan-Änderung gehört, muss den Vorgang bestimmen, nicht die Datei ansehen.
- **Negativ:** Für jedes andere Planungs-Artefakt bleibt die Frage offen. Das ist sichtbar und
  benannt, aber es bleibt eine Lücke.
- **Feststellung, keine Zuweisung — zum Nachzug an
  [`docs/plan/planning/README.md`](../planning/README.md):** Der Abschnitt *Slices vs. Wellen* ist
  an die Kopfnote der Welle-Vorlage angeglichen statt an seine eigene Ziel-Form und hat dabei die
  Zuschreibung *Sequenzierungs-Autorität* an die Roadmap verloren; der Review-Report
  `2026-09-14-slice-flache-welle-ist-eroeffnet-nicht-geplant` führt das als MEDIUM. Das ist eine
  **Ziel-Form-Frage**. Diese Entscheidung deckt die Datei **nicht** — sie ist kein Welle-Plan —,
  und sie weist sie auch niemandem zu. Eine eigene Suche, die diese Datei zum Gegenstand hat statt
  des Welle-Plans, findet **eine** Stelle:

  ```sh
  git grep -nE 'planning/README\.md' -- AGENTS.md harness/ spec/ docs/plan/adr/ .claude/ \
    .harness/skills/ ':!.harness/baseline' ':!docs/reviews' ':!docs/plan/adr/0048-*.md'   # 1
  ```

  Sie liegt in `harness/migration.md` und ordnet der Datei ihre Vorlage zu — eine Zeile des
  Instanz-Registers, keine Rollen-Aussage. **Kein Erwartungswert**, und auch das ist eine
  Stellen-Messung ohne Folgerung über die Eigenschaft
  ([`MR-055`](../../../harness/conventions.md#mr-055--eine-stellen-messung-trägt-keine-folgerung-über-eine-eigenschaft)):
  Sie trägt, dass dieser Lauf keine Zuweisung gefunden hat, nicht, dass es keine gibt. Die Behebung
  ist von dieser Entscheidung damit weder freigegeben noch blockiert; wer sie fährt, entscheidet
  die Eigentumsfrage für diese Datei mit — und das ist ein eigener Vorgang.
- **Folgepflicht (Planner), fällig als eigener Vorgang — die zweite Hälfte des Übergabe-Artefakts:**
  Das gewählte Konflikt-Verdikt *„Lockerung legitim, aber undokumentiert"* trägt nach Baseline
  `v6.8.0`, `modul-08-agentenrollen.md` §Konflikt-Pfad als Rollen-Sequenz ein **zweiteiliges**
  Übergabe-Artefakt: *„Folge-ADR + Erinnerungs-Slice in `next/`"*. Diese Datei ist der erste Teil.
  Der zweite — ein Erinnerungs-Slice, der den Folgepflichten unten und in §Was diese Entscheidung
  nicht tut eine Lifecycle-Adresse gibt, statt sie auf *„später"* stehen zu lassen — ist ein
  **Planner**-Artefakt ([`AGENTS.md`](../../../AGENTS.md) §3.10); der Architect schneidet ihn
  nicht. Diese Datei ist die Übergabe: Sie nennt den Bedarf, der Planner entscheidet Zuschnitt und
  Kennung.
- **Folgepflicht (Reviewer), fällig als eigener Vorgang:** Die Review-Reports sind Lauf-Belege und
  werden nicht überschrieben; das auslösende Finding ist mit dieser Entscheidung aufgelöst, nicht
  widerlegt. Ob die Grenze aus Festlegung 1 in `.harness/skills/reviewer.md` aufgenommen wird,
  entscheidet der Reviewer — die Datei gehört der ausführenden Rolle
  ([ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Festlegung 1), und diese
  Entscheidung schreibt sie nicht.
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
  Verzeichnisse (`ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l`, kein Erwartungswert —
  ein Zähler-Stand außerhalb des Registers ist eine **datierte Messung** nach
  [`MR-051`](../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
  Setzung 2, der Klasse, die
  [`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  nach eigener Kopf-Marke nicht erreicht). Die Closure entscheidet es; diese Datei legt nichts an.

## Fitness Function (falls maschinell prüfbar)

**Diese Entscheidung hat keinen Wächter, und das gehört benannt**
([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). Kein
Modul der [`.d-check.yml`](../../../.d-check.yml) liest Commits — `grep -n '^modules:' .d-check.yml`
nennt die aktivierten —, und `make mutate` kennt zwei Fehlschlag-Formen, keine davon für einen
Commit-Zuschnitt oder eine Rollen-Zuordnung. Dieselbe Lage stellen
[`AGENTS.md`](../../../AGENTS.md) §3.8 und §3.10 für ihren eigenen Commit-Zuschnitt fest.

| Tooling | Regel | Make-Target |
|---|---|---|
| — | Festlegung 1 (die Vier-Bedingungen-Probe) hat **keinen** Wächter. Bedingung 2 wäre für den byte-gleichen Fall messbar — ein `diff` gegen die Ziel-Form —, die übrigen drei sind ein **Urteil und kein Muster**: Ob ein Absatz eine Aussage über *diese* Welle trifft, ist am Text zu lesen und nicht zu zählen; ein `grep` zählte Absätze, nicht Verstöße ([`AGENTS.md`](../../../AGENTS.md) §3.6). Eine Teil-Prüfung, die nur die messbare Bedingung hält, wäre ein Gate, dessen Grün mehr behauptet als es prüft. Träger ist der Rollen-Wechsel **vor** der Änderung | — |
| — | Festlegung 2 (die Reichweite eines Satzes in einer fremden, eingefrorenen Datei) hat **keinen** Wächter: Kein Modul hält eine Aussage gegen die Reichweite ihrer Quelle. Träger ist diese Datei | — |

**Eine Hälfte ist trotzdem beobachtbar, und sie ist nicht die Regel:** Ob ein Commit ausschließlich
Artefakte einer Rolle berührt, lässt sich nachträglich an `git log --stat` ablesen — das ist die
Ablesbarkeit, die [`AGENTS.md`](../../../AGENTS.md) §3.8 verlangt, kein Gate. Sie sagt, *welche
Dateien* ein Commit anfasste, und nichts darüber, *welcher Vorgang* er war.

## Re-Evaluierungs-Trigger

- **Wenn eine Quelle das Eigentum am Welle-Plan als Eigenschaft der Datei ausspricht** — eine
  kanonische Quelle nach [`AGENTS.md`](../../../AGENTS.md) §2, eine Festlegung einer
  `Accepted`-ADR oder eine Hard Rule *(beobachtbar an dieser Stelle selbst: sie steht dann da und
  sagt es)*: Festlegung 1 ist abgelöst statt ergänzend, und die Wahl zwischen den Optionen ist neu
  zu halten — die Gegenposition steht in Option B. Der Trigger hängt ausdrücklich **nicht** an der
  Trefferzahl eines `grep`: Die Messungen in §Kontext sind Stellen-Messungen
  ([`MR-055`](../../../harness/conventions.md#mr-055--eine-stellen-messung-trägt-keine-folgerung-über-eine-eigenschaft)),
  und eine Ordnungszahl über sie wäre eine Bedingung, die schon das Wachstum dieses Verzeichnisses
  erfüllt.
- **Wenn ein Nachzug unter Festlegung 1 nachweislich eine Aussage über eine Welle verändert hat**
  *(beobachtbar an einem Review-Finding, das genau das meldet)*: Die Vier-Bedingungen-Probe trennt
  dann nicht, und die Grenze ist neu zu ziehen — im Zweifel zurück auf Option B.
- **Wenn dieselbe Frage für ein zweites Planungs-Artefakt entschieden werden muss** *(beobachtbar
  an einem Vorgang, der eine Eigentums-Frage an Roadmap, Slice-Plan oder
  [`docs/plan/planning/README.md`](../planning/README.md) stellt)*: Dann ist zu prüfen, ob die
  Verengung auf den Welle-Plan noch trägt oder ob Option E — eine Regel für alle lebenden
  Planungs-Artefakte — die billigere Antwort ist.
- **Wenn die regierende Fassung die Rollen-Sequenz für eine Welle von Schritten auf Artefakte
  umstellt** *(beobachtbar daran, dass eines der drei `grep -c`-Kommandos des `modul-08`-Blocks in
  §Kontext — §Was die zitierten Quellen binden — unter einem neuen `BASELINE_TAG` **0** ausgibt)*:
  Festlegung 1 stützt sich dann auf eine Stelle, die es nicht mehr gibt, und der
  Adaptions-Durchgang des Sprungs hält sie neu.
- **Wenn dieselbe Klasse — eine Eigentums-Frage ohne Quelle wird im laufenden Vorgang faktisch
  beantwortet — im Beobachtungs-Register 3× erreicht** *(beobachtbar am Zähler ihres
  Verzeichnisses)*: Dann ist die Verengung oben aufgebraucht, und die Frage gehört als allgemeine
  Regel entschieden statt ein viertes Mal je Artefaktklasse.

### Der Acceptance-Trigger

Diese Entscheidung steht auf `Proposed`. Sie wird `Accepted`, **wenn eine Reviewer-Runde sie gegen
[ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md),
[ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) und
[ADR-0046](0046-welle-datei-entsteht-mit-der-eroeffnung.md) auf Konsistenz geprüft hat und ihr
Report ohne blockierenden Befund an der **Substanz** der beiden Festlegungen in `docs/reviews/`
liegt.**

**Drei Fächer, nicht zwei** — dieselbe Dreiteilung, die
[ADR-0046](0046-welle-datei-entsteht-mit-der-eroeffnung.md) §Der Acceptance-Trigger nach derselben
Beobachtung für sich gesetzt hat. Ein blockierender Befund an der **Darstellung** — Adressform,
Zahl ohne Kommando, Zitat-Stelle — wird behoben und hindert die Annahme nicht. Dasselbe gilt für
einen Befund an **jedem Abschnitt, der mit dem Accept einfriert, ohne eine Festlegung zu tragen**.
Das ist die Kennzeichnung, und sie trägt; die Aufzählung darunter nennt den heutigen Bestand
vollständig und ist keine Verengung: §Kontext samt seinen Messungen, §Verglichene Alternativen,
§Was diese Entscheidung nicht tut, die Folgepflichten und Feststellungen in §Konsequenzen, die
Wächter-Aussagen in §Fitness Function, die Re-Evaluierungs-Trigger, **dieser Trigger-Abschnitt
selbst** und **§Geschichte**. Auch ein Befund dort wird behoben, solange die Datei `Proposed` ist,
und hindert die Annahme nicht — **solange die Behebung keine der beiden Festlegungen ändert**;
ändert sie eine, ist es ein Substanz-Befund und blockiert.

**Was das dritte Fach ändert.** Ohne es fällt ein Befund an einer Messung in §Kontext, an einem
Re-Evaluierungs-Trigger oder an einer Zeile der §Geschichte in keines der zwei: Er liegt nicht an
der Substanz der Festlegungen und nicht an ihrer Darstellung, und der Trigger sagt über ihn dann
weder das eine noch das andere. **Der Preis steht daneben:** Wer den Trigger ändert, während eine
Runde gegen seine frühere Fassung vorliegt, verschiebt deren Verdikt, statt es zu erfüllen — die
Runde `2026-09-14-adr-0048-konsistenzrunde` hat gegen die Zwei-Fächer-Fassung verdiktiert und ihren
schärfsten Befund ausdrücklich aus eigener Kategorisierung als blockierend geführt, nicht aus dem
Trigger-Wortlaut.
[ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 3 erlaubt die
Schärfung und nur, solange die Datei `Proposed` ist; danach frieren Statuszeile und
Trigger-Abschnitt gemeinsam ein.

Der Beleg ist eine Runde der prüfenden Rolle; die Nachmessung des Kontexts, der einen Befund
auflöst, ist keiner
([ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 2) — nach einem
blockierenden Verdikt ist es die **nächste** Runde derselben Rolle. Die Accept-Zeile der §Geschichte
nennt ihn als **Kennung**, nicht als Pfad-Link (ebenda, Festlegung 1).

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-09-14 | **Proposed** | Architect-Lauf als Verdikt im Rollen-Konflikt nach Baseline `v6.8.0`, `modul-08-agentenrollen.md` §Konflikt-Pfad als Rollen-Sequenz. Anlass ist das HIGH mit Rollen-Widerspruch im Review-Report `2026-09-14-slice-flache-welle-ist-eroeffnet-nicht-geplant`. Gewähltes Verdikt: *Lockerung legitim, aber undokumentiert* — der Vorgang stützte sich auf eine Geltungsbereichs-Grenze, die sachlich trägt und die kein Dokument führte; diese Datei zieht sie nach, und der auslösende Slice schließt nicht vor ihrer Annahme. |
| 2026-09-14 | **Überarbeitet, weiter `Proposed`** | Beleg ist die Runde `2026-09-14-adr-0048-konsistenzrunde`, die die Kern-These beider Festlegungen bestätigt und den Verzicht auf `Supersedes` ausdrücklich bejaht, dabei aber blockierend verdiktiert. Geschärft sind: der Geltungsbereich von Festlegung 1, jetzt auf den Welle-Plan verengt und mit einer Aufzählung dessen, was er nicht deckt; die Probe, jetzt mit einer vierten Bedingung, die den nachgezogenen Text an sein Original bindet; die Messung in §Kontext, jetzt mit Pathspec-Verengung auf Quellen statt auf den Gegenstand und mit benannter Grenze der Stellen-Messung; die Genealogie-Aussage, die die eigene Achse jetzt als dritte führt; Re-Evaluierungs-Trigger 1, der nicht mehr an einer Ordnungszahl hängt; und der Acceptance-Trigger um sein drittes Fach. |
| 2026-09-14 | **Überarbeitet, weiter `Proposed`** | Beleg ist die Runde `2026-09-14-adr-0048-konsistenzrunde-2`, die alle Befunde der Vorrunde als behoben nachmisst und an einer Stelle blockierend verdiktiert: Festlegung 2 zählte **zwei** zitierte Quellen, wo der ausgelegte Satz **drei** nennt, und quantifizierte über alle von ihm genannten Artefakte. Festlegung 2 führt den Satz jetzt im vollen Wortlaut, ordnet jedem der drei Artefakte seine Quelle zu und hält fest, dass die dritte den Anweisungssatz zum Wellen-Schnitt trägt; §Was diese Entscheidung nicht tut nimmt ihn ebenso namentlich aus wie die Roadmap. Daneben geschärft: die Feststellung zu `docs/plan/planning/README.md` steht jetzt neben einer Messung, die diese Datei zum Gegenstand hat; die Genealogie liest [ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md) auf ihrer eigenen Achse; die zweite Hälfte des Übergabe-Artefakts — der Erinnerungs-Slice in `next/` — steht als Folgepflicht an den Planner; die Eröffnungs-Zahl von §Kontext nennt ihren Prüfbereich; das Kennungs-Muster trifft beide Formen nach [`MR-057`](../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer); Re-Evaluierungs-Trigger 4 benennt die gemeinten drei Kommandos; das dritte Fach führt §Geschichte und sich selbst; und der Register-Zähler beruft sich auf [`MR-051`](../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung) statt auf [`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert). |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0048` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).
