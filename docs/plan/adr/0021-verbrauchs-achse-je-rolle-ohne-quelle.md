# ADR-0021: Die Verbrauchs-Achse je Rolle bleibt ohne Quelle — der Ausfall ist permanent, nicht temporär

**Status:** Accepted

**Datum:** 2026-08-22

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (kein Gate
über leerem Prüfbereich — hier wird **kein** Gate behauptet; die Fitness Function unten nennt drei
vorhandene Wächter und einen fälligen Fall, jeden mit dem, was er **nicht** deckt),
[`AGENTS.md`](../../../AGENTS.md) §3.6 (**der tragende Grund** für Festlegung 3: eine Zusage ohne
rot gesehenes Gegenbeispiel ist keine — daran hängt, was ein Span belegen darf und was nicht),
[ADR-0011](0011-telemetrie-erfassung-policy.md) (**Accepted** — Festlegung 2 schließt fremden
Inhalt aus dem Log aus und trägt damit Alternative C unten; Festlegung 3 dritter Punkt *„Kein
Beleg-Status"* ist der eine Pol der Rangfrage, die Festlegung 3 unten beantwortet),
[ADR-0012](0012-haupt-kontext-ohne-token-bilanz.md) (**Accepted** — der **Bauplan**: dieselbe
Achse, derselbe Trichter, Option F. Ihre Festlegung 1 — kein Auflösungs-Trigger, kein Folge-Slice —
gilt hier für die zweite Hälfte derselben Lücke),
[ADR-0019](0019-agent-guard-prueft-die-aufrufform.md) (**Accepted** — Festlegung 3 führt den
Ausfall als Carveout, Festlegung 4 formuliert die Messung und bindet **beide** Ausgänge; ihr
dritter Re-Evaluierungs-Trigger nennt für den negativen Ausgang ausdrücklich den Pfad von
[ADR-0012](0012-haupt-kontext-ohne-token-bilanz.md)),
[ADR-0020](0020-emittierte-modul-15-regeln.md) (**Accepted** — die **Tool-Ebene ist dort schon
entschieden**: der Carveout ist Vorbedingung des Zähler-Glieds, ausdrücklich **kein**
Auflösungs-Trigger, und sein Maßstab wird dort nicht importiert)

**Schärft:**
[`spezifikation.md §5 Metriken und Tracing-Felder`](../../../spec/spezifikation.md#5-metriken-und-tracing-felder)
— die fünf Stellen, die den Ausfall heute mit einem Zeiger auf eine **offene Frage** beschreiben:
den fünften Punkt der Erfassungs-Liste, die **START-KONVENTION**, den Wächter-Absatz zu deren
Bedingung 2, **Abweichung 1** (Cache-Zähler) und **Abweichung 5**. Aufwärts-Deklaration der
Änderungskopplung: wer diese ADR ändert, zieht von hier die betroffenen Spec-Stellen nach.
**Die emittierte Ebene ist nicht berührt, und das ist gemessen, nicht angenommen:**
`git grep -ln 'span-emit\|spawned_role\|pretooluse-agent-guard' -- internal/emit/` → **leer
(Exit 1)**, und `internal/emit/templates/enforce/settings.json` führt genau einen Matcher, `Bash`.
Gegenstand ist der Dogfood dieses Repos.

---

## Kontext

### Was offen war, und was seither gefahren ist

Der Ausfall ist seit dem 2026-08-15 beschrieben und als temporäre Ausnahme geführt
([`CO-002`](../carveouts/CO-002-token-achse-je-rolle.md)): der `Agent`-Span eines Subagenten-Aufrufs
trägt von neun erfassten Werten genau einen, `model_version`. Es fehlen `spawned_role`, die vier
`usage`-Zähler und die drei Summen — das **Kosten-Aggregat des Aufrufs**. Geführt wurde das als
Carveout und nicht als permanente Abweichung, weil **einer** von drei Wegen zurück in unserer Hand
lag: ein `PreToolUse`-Hook setzt `run_in_background: false` per `updatedInput` **nach** dem Modell
in die Tool-Argumente ein. [ADR-0019](0019-agent-guard-prueft-die-aufrufform.md) Festlegung 4 hat
die Messung dazu formuliert und beide Ausgänge gebunden.

**Die Messung ist gefahren, und sie ist negativ.** Sie steht als Zeitdokument in
[`docs/reviews/2026-08-21-updatedinput-messung.md`](../../reviews/2026-08-21-updatedinput-messung.md)
— jede Zahl dort gilt an ihrem Datum. Ihr Ergebnis in einer Zeile: `updatedInput` **wird
übernommen** — beobachtet am statischen Kontroll-`updatedInput`, dessen Marker in der Tool-Zeile
des Bestätigungs-Dialogs erschien —, und ein so übernommenes Eingabeobjekt mit
`"run_in_background": false` erzeugt trotzdem einen **Hintergrund-Start**: das Werkzeug kehrt
sofort zurück, die Sitzung meldet einen Hintergrund-Lauf, und der `Agent`-Span des Laufs trägt
weder `spawned_role` noch einen der vier Zähler.

**Was daran repo-lokal nachzumessen ist, ist hier nachgemessen** (2026-08-22, jede Zahl mit ihrem
Kommando):

- `git grep -ln 'updatedInput' -- . ':!docs' ':!spec'` → **leer (Exit 1)**. Keine ausführbare Datei
  des Baums stellt die Vordergrund-Form her; der Messaufbau war uncommittet und ist zurückgenommen.
  Damit ist die **zweite Hälfte** der Auflösungs-Schwelle von
  [`CO-002`](../carveouts/CO-002-token-achse-je-rolle.md) — *„und die Mechanik, die ihn erzeugt hat,
  liegt committet im Baum"* — unerfüllt, und zwar **an `git` abzulesen, nicht am Span-Bestand**.
- `grep -n 'CO-002' spec/spezifikation.md .claude/hooks/pretooluse-agent-guard.sh` → **sechs Zeilen
  in zwei Dateien** (fünf im Technik-Stratum, eine im Kopf des Guards). Das sind die Zeiger, die
  Folgepflicht 2 von [ADR-0019](0019-agent-guard-prueft-die-aufrufform.md) gesetzt hat; sie zeigen
  heute auf eine offene Frage und gehören nachgezogen (Folgepflicht 2 unten).
- `ls docs/plan/carveouts/CO-*.md | wc -l` → **2**. Der eine ist Gegenstand dieser Entscheidung, der
  andere betrifft eine Lint-Ausnahme und teilt mit ihm keinen Geltungsbereich. **Diese Zahl bewegt
  sich mit der Umsetzung nicht** — Festlegung 5 lässt die Adresse stehen —, und was daraus für das
  Carveout-Audit folgt, steht unten als Folgepflicht 4.
- Die Hook-Einträge in `.claude/settings.json` gelesen: der `Agent`-Matcher führt **genau einen**
  Hook, den Guard; die übrigen sind `PreToolUse` auf `Bash`, `PostToolUse`, `PostToolUseFailure`,
  `SubagentStart` und `Stop`. **`SubagentStop` ist nicht verdrahtet** — Annahme (b) unten hat
  deshalb keinen Messwert, sondern eine gelesene Quelle.

**Was dieser Architect-Lauf NICHT nachmessen kann:** das Verhalten des Agenten-Werkzeugs. Ein
Subagent führt das `Agent`-Werkzeug nicht. Die Beobachtung des Zeitdokuments ist hier nicht
wiederholt, sondern **eingeordnet** — dieselbe Grenze, die
[ADR-0019](0019-agent-guard-prueft-die-aufrufform.md) für ihren eigenen Lauf benannt hat.

### Der Trichter nach Modul 7 — Frage 1 unverändert, Frage 2 kippt

Regelwerk `v3.5.2`, `modul-07-carveouts.md` §Werkzeug-Wahl bei Diskrepanz — Granularität **vor**
Temporalität:

1. **Granularität — einzelne Diskrepanz oder Cluster?** *Einzelne, unverändert.*
   [ADR-0019](0019-agent-guard-prueft-die-aufrufform.md) §Kontext hat die Frage für denselben
   Gegenstand beantwortet, und keine ihrer Stützen hat sich bewegt: die Faustregel des Moduls für
   *Cluster* ist der **gemeinsame Geltungsbereich**, keine Carveout-Zahl; die Nachbar-Abweichung aus
   [ADR-0012](0012-haupt-kontext-ohne-token-bilanz.md) betrifft dieselbe Achse in einem **anderen**
   Geltungsbereich (dort umschließt kein Aufruf den Gegenstand, hier gibt es einen Aufruf samt
   Payload, nur ohne Zähler); und die zwei BF-Symptome liegen nicht vor — der **andere**
   geführte Carveout teilt mit dieser Diskrepanz keinen Geltungsbereich (Messung oben), und sie
   folgt nicht aus dem Muster *„Code existiert vor Doku"*: die Doku ist vollständig, es fehlt eine
   **Quelle**. → Frage 2.
2. **Temporalität — Trigger ernst zu erreichen?** **Nein.** Dasselbe Modul, derselbe Abschnitt: *„Nein („nichts davon werden
   wir in absehbarer Zeit tun") → permanent, übergeführt in eine ADR."*
   [ADR-0019](0019-agent-guard-prueft-die-aufrufform.md) hat die Antwort *Ja* auf **einen** Weg
   gestützt — den, der in unserer Hand lag, und der ist gefahren. Es bleiben die zwei Wege im
   fremden Vertrag, die dieselbe ADR schon damals **für sich allein** mit *Nein* beantwortet hat:
   eine **wirksame** Vordergrund-Form des Werkzeugs, und ein Hook-Ereignis, das die Zähler trägt.
   Kein Aufwand dieses Repos bringt eines von beiden herbei.

**Der zweite Ausgang war vorgesehen, nicht improvisiert.**
[`CO-002`](../carveouts/CO-002-token-achse-je-rolle.md) §Auflösungs-Trigger sagt: *„Der zweite
Ausgang gehört in denselben Trigger: fällt die Messung aus Weg 1 negativ aus, bleiben nur die zwei
fremden Wege, und die Antwort auf Modul-7-Frage 2 kippt auf Nein."* Und er sagt, was sonst
entstünde: *„Ein Carveout, der nach einer negativen Messung stehen bliebe, wäre die permanente
Ausnahme, die behauptet, temporär zu sein."*

**Der Folge-Slice-Test dazu.** Regelwerk `v3.5.2`, `modul-07-carveouts.md` §Ziel-Form: *„Fehlt der
Folge-Slice, ist der Carveout de facto permanent — dann gehört er nicht in `carveouts/`, sondern
über den Trichter unten in eine ADR."* Der Folge-Slice existierte, hat seinen Gegenstand geliefert und ist damit verbraucht. Ein
**zweiter** hätte den Inhalt *„abwarten"* — das Memo unter anderem Namen
([ADR-0012](0012-haupt-kontext-ohne-token-bilanz.md) Alternative B).

### Wohin der Carveout danach gehört — gemessen, bevor entschieden

**Fünf Stellen sprechen über den Ort, und keine schreibt diesen Fall vor.** Vier stehen im
Regelwerk, die fünfte im Carveout selbst. **Die Abzählung ist prüfbar statt behauptet:** §Ziel-Form
führt genau **vier** Bullets (*„Operative Regeln, die das Template nicht selbst erzwingt"*), und
zwei davon sprechen über den Ort — der **erste** (Pflicht-Header, unten disponiert) und der
**vierte** (`git mv` bei der Auflösung); die zwei dazwischen betreffen die **Form** des
Auflösungs-Triggers und den `# CO-<NNN>`-Kommentar in einer Gate-Konfiguration und nennen keinen
Ablageort. Dazu kommen §Werkzeug-Wahl bei Diskrepanz und §Carveout-Audit-Slice. Regelwerk `v3.5.2`,
`modul-07-carveouts.md` §Carveout-Audit-Slice nennt für den permanenten Übergang **nur** das
Ziel-Artefakt: *„Drei Status-Übergänge je Carveout: aufgelöst (Trigger eingetreten → `git mv` nach
`done/`), permanent (Trigger nie → ADR), weiterhin aktiv (Trigger sinnvoll → `Letzte
Prüfung:`-Datum nachtragen, ggf. Folge-Slice)."* §Ziel-Form bindet den `git mv` an
die **Auflösung** — und an eine Bedingung im selben Satz: *„**Auflösung ist ein `git mv` nach
`done/`** (plus Gate-Ausnahme entfernen, `make gates` grün ohne Ausnahmen). Auflösen ohne
Verschiebung ist eine zweite Lüge: der Carveout wirkt „aufgelöst", liegt aber weiter im aktiven
Verzeichnis."* §Werkzeug-Wahl bei Diskrepanz spricht vom **leeren** Stub: *„Der leere
`CO-<NNN>`-Stub wird gelöscht (Inhalt ganz aufgegangen) oder mit `Status: Überführt in <Ziel>` nach
`done/` verschoben, damit die Werkzeug-Wahl-Spur im Repo lesbar bleibt."* Dieser Carveout ist keiner
der beiden Fälle: er wird nicht **aufgelöst** — sein Trigger tritt nie ein —, und er ist kein
**leerer** Stub, sondern ein gelebtes, vielfach adressiertes Artefakt.

**Der erste Bullet der §Ziel-Form ist der einzige Regelwerks-Satz, der `carveouts/` und *permanent*
zusammen nennt — er greift hier nach seiner Logik, nicht nach seinem Buchstaben, und das gehört
gesagt.** Verbatim: *„Sechs Pflicht-Header-Felder: Status · Datum angelegt · Letzte Prüfung ·
betroffenes Gate · Geltungsbereich · Folge-Slice. Fehlt der Folge-Slice, ist der Carveout de facto
permanent — dann gehört er nicht in `carveouts/`, sondern über den Trichter unten in eine ADR."*
Dieselbe Disposition hat [ADR-0012](0012-haupt-kontext-ohne-token-bilanz.md) §Kontext für denselben
Satz vorgemacht, mit derselben Wendung. Drei Gründe, jeder am Wortlaut prüfbar:

1. **Sein Vordersatz trifft nicht zu.** Die Bedingung ist *„Fehlt der Folge-Slice"* — ein
   **Form**-Mangel des Kopfes, und der Satz steht in genau dem Bullet, der die sechs Pflicht-Felder
   aufzählt. [`CO-002`](../carveouts/CO-002-token-achse-je-rolle.md) hat das Feld **gefüllt**, der
   Slice ist gelaufen und hat den zweiten Ausgang geliefert (oben, §Der Folge-Slice-Test). Die
   Permanenz dieses Carveouts folgt nicht aus einem fehlenden Folge-Slice, sondern aus einer
   gefahrenen Messung und aus Trichter-Frage 2.
2. **Sein Nachsatz ist hier bereits vollzogen.** Er ordnet an, **was zu tun ist**: *„über den
   Trichter unten in eine ADR"*. Genau das ist geschehen — der Trichter ist mit beiden Fragen in
   der Reihenfolge des Moduls gefahren, und diese ADR ist sein Ergebnis. Wer den Satz auf diesen
   Fall anwendet, bekommt diese Entscheidung, keinen Widerspruch zu ihr.
3. **Als Ablage-Regel gelesen widerspräche er sich selbst.** Das Ziel, das dasselbe Modul für einen
   abgeschlossenen Carveout vorsieht, ist `carveouts/done/` — ein **Unterverzeichnis von
   `carveouts/`**. Eine Lesart, unter der `carveouts/done/` das *„gehört nicht in `carveouts/`"*
   erfüllt und `carveouts/` es verletzt, behandelt denselben Pfad-Präfix zugleich als innen und
   außen. Als **Werkzeug**-Aussage — *„das gehört nicht in die Werkzeug-Klasse Carveout, sondern in
   eine ADR"* — ist der Satz widerspruchsfrei, und nur diese Lesart deckt sich mit dem Bullet, in
   dem er steht, und mit dem Ort, auf den er selbst verweist: *„über den Trichter unten"* ist
   §Werkzeug-Wahl bei Diskrepanz, der Abschnitt, der über **Werkzeuge** entscheidet.

**Das Ergebnis dieser Lesung ist ein Negativbefund, und er ist das erste und tragende Bein dieser
Entscheidung:** im Regelwerk steht **kein** Satz, der für einen **gelebten, übergeführten**
Carveout ein Verzeichnis vorschreibt. §Carveout-Audit-Slice nennt für *permanent* nur das
Ziel-Artefakt, §Ziel-Form spricht im vierten Bullet von der **Auflösung** und im ersten von der
**Werkzeug-Klasse** (soeben disponiert), §Werkzeug-Wahl vom **leeren** Stub — und die Leere ist
dort kausal begründet (*„Inhalt ganz aufgegangen"*). **Die Klammer der §Ziel-Form,
*„plus Gate-Ausnahme entfernen, `make gates` grün ohne Ausnahmen"*, ist deshalb hier keine
Bedingung des Moves** — sie gehört zur Auflösung, und sie hat hier nicht einmal einen Gegenstand:
[`CO-002`](../carveouts/CO-002-token-achse-je-rolle.md) führt als betroffenes Gate ausdrücklich
*„keines"*, es gibt keine Gate-Ausnahme zu entfernen. Wer sie zur Move-Bedingung erklärte, schriebe
eine Regel ins Repo, die im Regelwerk nicht steht — und der nächste, der einen Carveout wirklich
**auflöst**, während der Gate aus fremdem Grund rot ist, könnte sie zitieren und die Datei liegen
lassen. Genau das nennt derselbe Satz *„eine zweite Lüge"*.

**Die fünfte Stelle steht im Carveout selbst, und sie ordnet den Move an.** Sein
Auflösungs-Trigger sagt für genau diesen Ausgang: *„Dann ist dieser Carveout **in eine Folge-ADR
zu überführen** (`Status: Permanent — übergeführt in ADR-<NNNN>`) **und nach `done/` zu
verschieben**, damit die Werkzeug-Wahl-Spur lesbar bleibt."* Und seine Verifikations-Checkliste
führt einen Haken *„Datei wird nach docs/plan/carveouts/done/ bewegt (reiner git mv)"* samt
einer `d-check:ignore`-Direktive für ein Verzeichnis, das nicht entsteht. Beides ist **kein
Regelwerks-Satz**, sondern die Erwartung, die der Carveout an seinen eigenen Ausgang schrieb, als
der Ausgang noch offen war. Beides wird von Festlegung 5 aufgehoben; Folgepflicht 1 führt es
ausdrücklich als Änderung, damit die Weiche nicht die Anweisung trägt, die diese ADR verbietet.

**Was der Move kostet, ist gefahren, nicht geschätzt** (2026-08-22, Wegwerf-Kopie außerhalb des
Baums, derselbe digest-gepinnte d-check wie in `make docs-check`; der Arbeitsbaum blieb unberührt):

```sh
cp -a . /tmp/probe && cd /tmp/probe
mkdir -p docs/plan/carveouts/done
git mv docs/plan/carveouts/CO-002-token-achse-je-rolle.md docs/plan/carveouts/done/
docker run --rm --network none -v /tmp/probe:/repo:ro \
  ghcr.io/pt9912/d-check@sha256:3996a593b9cb71aa3bcb4f3ddf8f637e7409db31b3a2dac7eedc28d65814cacf
```

Der Lauf endet mit Exit 1, und **jeder** seiner Befunde ist ein `target-missing`
(`awk -F'\t' 'NF>1{print $NF}' <ausgabe> | sort -u` → eine Zeile). **Die Summe des Laufs steht
hier bewusst nicht.** Sie zählt die Verweise **jedes** lebenden Artefakts mit — auch die dieser
ADR und die der Review-Dokumente, die über sie geschrieben werden — und wächst mit jeder Runde;
als Erwartungswert taugt sie deshalb nicht
([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2, dieselbe Vorsicht wie bei der Datei-Zahl in Folgepflicht 1). **Tragend ist die
Teilmenge, die niemand nachziehen darf**, und sie hat ihr eigenes Kommando über derselben
Ausgabe:

```sh
grep -cE '^docs/plan/adr/(0019|0020)-' <ausgabe>   # 18
grep -cE '^docs/plan/adr/0019-'        <ausgabe>   # 13
grep -cE '^docs/plan/adr/0020-'        <ausgabe>   #  5
```

**18 Befunde liegen in zwei nach [`AGENTS.md`](../../../AGENTS.md) §3.4 eingefrorenen ADRs** — 13
in [ADR-0019](0019-agent-guard-prueft-die-aufrufform.md), 5 in
[ADR-0020](0020-emittierte-modul-15-regeln.md). **Diese Zahl wandert nicht**: beide Dateien sind
immutabel, ihre ausgehenden Verweise stehen fest. Der Rest verteilt sich auf lebende Artefakte —
dort ist Nachziehen die normale Arbeit —, und ein Teil auf diese ADR selbst, die mit ihrer Annahme
in denselben Zustand tritt. Die 18 sind von **keiner Rolle dieses Repos** behebbar: die Reparatur
*in* der Datei wäre eine Textänderung, und §3.4 verbietet sie.

**Der präzise Knopf fehlt weiter — und der Grund ist struktureller Art, nicht der eines
Zahlen-Deltas** (`d-check --print-config` gegen denselben Digest, 2026-08-22; die Sonden je in
derselben Wegwerf-Kopie). `links` trägt inzwischen **eine** Options-Sektion, `resolve-from`, und
sie ist **quellenseitig**: sie verlangt, dass die Links der Dateien **in** einer Verzeichnis-Gruppe
von **jedem** Ort der Gruppe auflösen (*„Dateien hier muessen von JEDEM Ort der Gruppe aufloesen
(>= 2)"*). Die 18 Befunde sind aber **eingehende** Verweise aus Dateien **außerhalb** jeder solchen
Gruppe — sie liegen konstruktiv außerhalb ihrer Reichweite. Das ist gemessen, nicht abgeleitet:
mit `dirs: [docs/plan/carveouts, docs/plan/carveouts/done]` **und** mit derselben Option plus
`fixed-dirs: [docs/plan/adr]` — der Variante, die für wandernde Ziele gebaut ist — bleiben die 18
in beiden Läufen **unverändert** stehen (`grep -cE '^docs/plan/adr/(0019|0020)-'` → 18). Die
Option **fügt** dabei eine neue Befundart hinzu, `link-position-dependent`
(`grep -c 'link-position-dependent' <ausgabe>` → 3), und **alle** ihre Treffer liegen auf
[CO-001](../carveouts/CO-001-bats-shell-lint.md) und dem Carveout-Index — einem Carveout, der mit
dieser Entscheidung nichts zu tun hat; auf `CO-002` keiner. `codepaths.ignore-refs` ist referenz-weit,
aber **modul-lokal**: die Befunde entstehen im Modul `links`, und mit
`docs/plan/carveouts/**` unter `codepaths` bleiben sie sämtlich stehen — auch die 18. **Innerhalb
von `links` gibt es keinen Ausschluss.** Es bleibt allein `scan.ignore`, **datei-weit über alle
Module**, wie [ADR-0017](0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) es für ihren Fall
gemessen hat. Diese Begründung überlebt einen Werkzeug-Sprung; ein Zahlen-Delta täte es nicht.

**Drei Wege, und der Preis des zweiten ist beziffert:**

| Weg | Preis | Befund |
|---|---|---|
| **1 — Move, Befunde stehen lassen** | `make docs-check` und mit ihm `make gates` dauerhaft rot, für niemanden behebbar | scheidet aus. Ein Dauer-Rot erzieht dazu, Rot zu übersehen, und entwertet die übrigen Befunde desselben Laufs — [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) eine Ebene tiefer, in [ADR-0017](0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) für denselben Fall schon so entschieden |
| **2 — Move plus `scan.ignore` für die zwei eingefrorenen ADRs** | zwei Dateien verlassen den Gate **ganz**, über alle sechs Module (Zahlen unten) | scheidet aus. [ADR-0017](0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) hat den Maßstab gesetzt — *„kleinstmöglicher Prüfbereichs-Verlust für das Problem"* — und ihn für **eine** Datei mit **27** Link-Vorkommen bezahlt, weil ihr Auslöser **unvermeidbar** war: die Baseline **muss** ihren Tag wechseln. Hier ist der Auslöser **wählbar**: eine Ablage-Konvention. Dafür zwei der größten und jüngsten ADRs dauerhaft aus dem Gate zu nehmen, kehrt das Verhältnis um; und jeder Eintrag löste [`AGENTS.md`](../../../AGENTS.md) §3.5 erneut aus (*„jeder zusätzliche Eintrag ist eine neue Senkung"*) |
| **3 — der Ort bleibt, der Status trägt den Übergang (gewählt)** | das Verzeichnis hört auf, Träger der Aussage *aktiv* zu sein — wer sie liest, liest den Status; und die zwei Ort-Anweisungen im Carveout selbst müssen mit aufgehoben werden, sonst trägt die Weiche die Anweisung, die diese ADR verbietet | `make docs-check` bleibt grün — über genau dieser Form gefahren (Wegwerf-Kopie, Status-Zeile und Index-Abschnitt gesetzt): **0 Befund(e)**, Exit 0. Keine Gate-Senkung, kein `.d-check.yml`-Eintrag, kein §3.5-Vorgang |

Der Preis von Weg 2, mit seinen Kommandos — je Datei, weil eine Summe über zwei Dateien die
Eindeutigkeit der zweiten Spalte verlöre:

```sh
for F in docs/plan/adr/0019-agent-guard-prueft-die-aufrufform.md \
         docs/plan/adr/0020-emittierte-modul-15-regeln.md; do
  grep -oE '\]\([^)]+\)' "$F" | wc -l                                       # 49 / 66  Link-Vorkommen
  grep -oE '\]\([^)]+\)' "$F" | sort -u | wc -l                             # 18 / 23  eindeutige Ziele
  grep -oE 'ADR-[0-9]{4}|LH-[A-Z]{2}-[0-9]{2}|MR-[0-9]{3}' "$F" | wc -l     # 21 / 56  Kennungs-Nennungen
  grep -oE '`(\.{1,2}/|spec/|docs/|harness/)[^`]*`' "$F" | sort -u | wc -l  #  6 /  6  Inline-Code-Pfade
done
```

**Eine Aussage einer eingefrorenen ADR wird damit überholt, und das gehört ausgesprochen.**
[ADR-0020](0020-emittierte-modul-15-regeln.md) hält als **Prämisse** fest: *„ein Carveout hat nach
Modul 7 genau **zwei** Ausgänge, und **beide** enden in `done/` — *aufgelöst* per `git mv`, oder
*permanent* und in eine Folge-ADR überführt"*. Ihre **Festlegung** hängt daran nicht — sie
entscheidet, dass ihre Zellen auf die **Frage** zeigen statt auf den Carveout als Trigger —, und
ihre eigene Zustands-Aufzählung nennt für den permanenten Ausgang *„die Folge-ADR, die ihn
überführt"*, nicht ein Verzeichnis. Der Ort war dort nicht Gegenstand; er ist mitgeschrieben worden.
Korrigierbar ist der Satz nicht ([`AGENTS.md`](../../../AGENTS.md) §3.4), und diese ADR korrigiert
ihn nicht: sie entscheidet den Gegenstand, über den er beiläufig spricht.

### Woran diese Entscheidung hängt — und woran ausdrücklich nicht

Die tragende Beobachtung des negativen Ausgangs ist am **Span** abgelesen, wie
[ADR-0019](0019-agent-guard-prueft-die-aufrufform.md) Festlegung 4 und
[`CO-002`](../carveouts/CO-002-token-achse-je-rolle.md) es anordnen.
[ADR-0011](0011-telemetrie-erfassung-policy.md) Festlegung 3 dritter Punkt sagt dagegen: *„**Kein
Beleg-Status.** Ein Span ist kein Review-Gegenstand und keine Quelle für eine Zusage im Sinne von
AGENTS.md §3.6. Was belegt werden muss, wird gemessen — nicht aus dem Log gelesen."* Beide sind
**Accepted**, beide gelten, und keine kennt die andere. Der Rang gehört in eine **neue** ADR, nicht
in eine Korrektur an einer der zwei ([`AGENTS.md`](../../../AGENTS.md) §3.4) — er steht unten als
Festlegung 3.

Für den Gegenstand hier folgt daraus zuerst die Prüfung, **was ohne die Span-Lektüre trägt**:

- **Das Feld ist im Eingabe-Schema von `Agent` nicht geführt.** Gemessen an der Payload: am
  2026-07-29 trug `tool_input` über vier echte Aufrufe `subagent_type`, `prompt`, `description`
  **und** `run_in_background`; am 2026-08-15 führt das Schema den letzten nicht mehr
  ([`docs/reviews/2026-08-15-agent-guard-tool-vertrag.md`](../../reviews/2026-08-15-agent-guard-tool-vertrag.md)).
  Das ist eine Messung an der Payload, nicht am Span.
- **Vom Aufrufer gesendet wirkt es nicht** (2026-08-15 gemessen: der Aufruf wird angenommen und
  startet dennoch im Hintergrund). **Am Hook eingesetzt ebenso wenig** (2026-08-21) — und der
  **Hintergrund-Start** dieses Laufs ist zweifach beobachtet: an der sofortigen Rückkehr des
  Werkzeugs und an der Hintergrund-Meldung der Sitzung. Der Span sagt dasselbe ein zweites Mal; er
  ist nicht die einzige Stelle, an der es steht.
- **Beide fremden Wege sind unverändert.** Sie waren am 2026-08-15 *Nein* und sind es geblieben;
  nichts an ihnen hängt an dieser Messung.
- **Die zweite Hälfte der Auflösungs-Schwelle ist an `git` unerfüllt** (Messung oben). Sie ist
  span-unabhängig und für sich allein hinreichend dafür, dass
  [`CO-002`](../carveouts/CO-002-token-achse-je-rolle.md) **nicht aufzulösen** ist — sie entscheidet
  aber nicht die Trichter-Frage.

**Was ohne die Span-Lektüre NICHT trägt, und das gehört in denselben Satz:** die Aussage, dass ein
eingespeister Schalter **auch die Zähler nicht** zurückbringt. Sie ist die tragende Aussage des
negativen Zweigs, und sie steht auf drei Zeilen eines gitignorierten, maschinenlokalen Bestands
ohne Prüfsumme. Diese ADR wird deshalb **unter benannter Unsicherheit** getroffen — dieselbe
Konstruktion, mit der [ADR-0012](0012-haupt-kontext-ohne-token-bilanz.md) ihre ungemessene Fläche
geführt hat (*„eine Entscheidung unter benannter Unsicherheit, und die Fläche steht unten als
Re-Evaluierungs-Trigger"*): die Beobachtung steht als **Annahme (d)**, und der dritte
Re-Evaluierungs-Trigger sagt, wer sie umstößt und woran.

### Die Kontroll-Beobachtung ist prinzipiell nicht belegbar — und was daraus folgt

Der teuerste Fehler dieser Messung wäre ein Negativ aus der falschen Ursache: ein verworfenes
`updatedInput` sähe genauso aus wie ein ignoriertes Feld. Die einzige Gegenkraft ist die
Kontroll-Beobachtung — dass die Hook-Ausgabe **übernommen** wurde. Sie ist eine Sicht am Dialog und
an der Fertigmeldung. **Im Repo trägt sie nichts:** der Span führt nach
[ADR-0011](0011-telemetrie-erfassung-policy.md) weder `description` noch Betriebsart; ein
Screenshot ist kein Artefakt dieses Repos; und die einzige Datei, die den ausgeführten Aufruf mit
seiner Eingabe aufzeichnet — das Sitzungs-Transkript —, ist als Quelle **ausgeschlossen**
([`spec/spezifikation.md`](../../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5
Abweichung 1: *„der `transcript_path` wird deshalb weder erfasst noch gelesen"*, und Abweichung 6;
[ADR-0012](0012-haupt-kontext-ohne-token-bilanz.md) Alternative D;
[ADR-0019](0019-agent-guard-prueft-die-aufrufform.md) Annahme (c)). Die Umkehr ist an diesen
Stellen eine **Erlaubnis des Auftraggebers**, kein Sensor.

**Daraus folgt zweierlei, und das zweite ist das wichtigere.**

1. Diese ADR stellt ihre Entscheidung **nicht** auf die Kontroll-Beobachtung. Sie stellt sie auf
   die Kette oben, in der die Beobachtung als Annahme (d) geführt ist und in der jedes andere Glied
   unabhängig von ihr gilt.
2. **Die Unbelegbarkeit trifft allein den negativen Zweig.** Ein künftiger Lauf, der die Zähler
   trägt, braucht keine Kontroll-Beobachtung — die Zähler **sind** der Beleg, und sie stehen in der
   Payload, nicht in einer Sicht. Die Re-Evaluierung dieser Entscheidung kostet deshalb **eine
   Messung, keine Erlaubnis**: sie ist wiederholbar, ihr positiver Ausgang belegt sich selbst, und
   ihr negativer sagt nur, dass alles bleibt. Nur der vierte Trigger unten hängt an einer Erlaubnis,
   und er öffnet eine **andere** Frage — zuerst eine Sicherheitsfrage.

### Annahmen, auf denen diese ADR steht

Kippt eine, kippt die Entscheidung; alle vier stehen unten als Re-Evaluierungs-Trigger.

- **(a)** Das Agenten-Werkzeug bietet keine **wirksam** anforderbare Vordergrund-Form an — das Feld
  wird angenommen und ändert nichts (2026-08-15 gemessen).
- **(b)** Kein Hook-Ereignis trägt die Zähler. `SubagentStop` trägt `agent_type`,
  `agent_transcript_path` und `last_assistant_message`, **keine** `usage` — der vendored Doku
  entnommen, hier **nicht** gemessen, und dieses Repo hat das Ereignis nicht verdrahtet.
- **(c)** Das Transkript bleibt als Quelle ausgeschlossen — für den Subagenten
  ([ADR-0011](0011-telemetrie-erfassung-policy.md) Festlegung 2: kein Byte fremden Inhalts) wie für
  die Sitzung ([`spec/spezifikation.md`](../../../spec/spezifikation.md#5-metriken-und-tracing-felder)
  §5 Abweichung 1: weder erfasst noch gelesen).
- **(d) — die schwächste, und sie ist neu.** Ein per `updatedInput` **nach** dem Modell eingesetztes
  `run_in_background: false` bringt die Zähler nicht zurück. **Ablese-Ort:** die `Agent`-Zeile des
  Laufs im gitignorierten, maschinenlokalen Span-Bestand unter `.harness/state/spans/`.
  **Kommando** — es gehört hierher und nicht allein ins Zeitdokument (Festlegung 3, zweite
  Bedingung); es ist am 2026-08-21 über den Bestand jener Sitzung gefahren und in **diesem**
  Architect-Lauf nicht wiederholt, weil ein Subagent das `Agent`-Werkzeug nicht führt:
  `grep -h '"tool_use_id":"toolu_0181irqRbg1FHcsrfRaBmpA1"' .harness/state/spans/*.jsonl` — **eine**
  Zeile, und sie trägt weder `spawned_role` noch einen der vier Zähler. **Der Schlüssel ist die
  `tool_use_id`, nicht Zeit oder Reihenfolge**, und das ist kein Detail: der Bestand wird nach
  [`spec/spezifikation.md`](../../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5
  **Abweichung 4** nie aufgeräumt und trägt viele `Agent`-Zeilen aus vielen Sitzungen; ein Glob
  mit `tail -1` griffe irgendeine davon heraus, und `seq` ist je Strom vergeben und deshalb nicht
  eindeutig. **Auf einem fremden Checkout gibt dasselbe Kommando nichts aus** — der Bestand ist
  gitignoriert und maschinenlokal, die Zeile dort also nicht auffindbar; das ist keine Lücke der
  Angabe, sondern die Natur des Ablese-Orts (Festlegung 3, letzter Absatz). Gestützt ist die Ablesung auf eine Kontroll-Beobachtung, die im
  Repo keinen Träger hat. Sie ist eine **Annahme im Sinne von Festlegung 3**, kein Beleg.

## Entscheidung

**Wir wählen Option F: der Ausfall ist permanent.** Nicht als Aufschub, sondern als **Grenze**, die
wir mit der Wahl dieser Erfassungs-Mechanik angenommen haben;
[`CO-002`](../carveouts/CO-002-token-achse-je-rolle.md) wird nach Modul 7 in diese ADR übergeführt.
Fünf Festlegungen:

**1. Der Ausfall der Verbrauchs-Achse je Rolle ist permanent — kein Auflösungs-Trigger, kein
Folge-Slice.** Der Geltungsbereich wandert unverändert aus dem Carveout hierher: **acht der neun**
erfassten Werte des `Agent`-Spans — `spawned_role`, die vier `usage`-Zähler (`input_tokens`,
`output_tokens`, `cache_creation_input_tokens`, `cache_read_input_tokens`) und die drei Summen
(`total_tokens`, `total_duration_ms`, `total_tool_use_count`). **Nicht betroffen:**
`model_version`, der neunte Wert, und die **Rollen-Achse** `agent_type`/`agent_role` in allen
übrigen Spans — sie stammt aus der Hook-Payload *innerhalb* des Subagenten, ist von der Betriebsart
unabhängig und trägt weiter. Was ausfällt, ist das **Kosten-Aggregat des Aufrufs**, nicht die
Zuordnung der Arbeit zu einer Rolle. An die Stelle des Triggers tritt die Re-Evaluierung unten: sie
sagt, **wer** diese Entscheidung wieder aufmacht und **woran** er es merkt — und sie behauptet
nicht, dass das jemand tun wird ([ADR-0012](0012-haupt-kontext-ohne-token-bilanz.md) Festlegung 1).

**2. Die Erfassung bleibt unverändert: permanent ist die Abwesenheit der QUELLE, nicht die
Abwesenheit des Schemas.** Die neun Werte bleiben in der Positiv-Liste, und der Emitter nimmt sie,
sobald sie wieder ankommen. Wer sie entfernt, weil heute keine ankommt, macht aus einer fehlenden
Quelle ein fehlendes Feld — und dann ist der Unterschied zwischen *unbekannt* und *nicht vorhanden*
auch dann noch weg, wenn die Zähler zurückkommen. Das ist die Hälfte dieser Entscheidung, die ein
vorhandener Go-Test bindet (unten) — und der ist **nicht** der, den man dafür zuerst nennt.

**3. Rang zwischen Beleg und Annahme: ein Span belegt keine Zusage, er kann eine Annahme tragen.**
[ADR-0011](0011-telemetrie-erfassung-policy.md) Festlegung 3 dritter Punkt gilt **wörtlich fort**
und wird hier nicht revidiert. Was eine Anordnung wie
[ADR-0019](0019-agent-guard-prueft-die-aufrufform.md) Festlegung 4 verlangt, ist etwas anderes als
ein Beleg — eine **Beobachtung** an einem benannten Ablese-Ort. Die Grenze läuft zwischen zwei
Klassen:

- **Zusage** im Sinne von [`AGENTS.md`](../../../AGENTS.md) §3.6 — Doc-Kommentar, Test-Name,
  DoD-Punkt, Commit-Message: **nie** aus einem Span. Sie verlangt ein rot gesehenes Gegenbeispiel;
  ein gitignorierter Bestand ohne Prüfsumme liefert keines.
- **Annahme einer ADR:** aus einem Span zulässig, **wenn** die ADR sie als Annahme führt, den
  Ablese-Ort samt dem Kommando, das ihn ausliest, **im eigenen Text** nennt — nicht über einen
  Verweis auf ein Zeitdokument — und einen Re-Evaluierungs-Trigger daran hängt. Eine Annahme ist per
  Konstruktion umstoßbar — genau darin unterscheidet sie sich von einer Zusage.
- **Review-Gegenstand:** unverändert **nicht** der Span. Geprüft wird die **Erklärung** der ADR —
  dass die Beobachtung als Annahme geführt ist, dass Ablese-Ort und Kommando dastehen und dass ein
  Re-Evaluierungs-Trigger an ihr hängt. Ein Reviewer muss den Bestand dafür **nicht öffnen**, und
  eine ADR, die ihn dazu zwänge, hätte ihre Annahme falsch geschrieben. Der dritte Satz aus
  [ADR-0011](0011-telemetrie-erfassung-policy.md) Festlegung 3 bleibt damit wörtlich in Kraft: er
  verbietet nicht, eine Annahme am Span **abzulesen**, sondern den Span zum **Prüfstück** zu machen
  — und genau das schließt diese Regel aus, statt es zu öffnen.

**Was das Kommando leistet und was nicht.** Der Span-Bestand ist gitignoriert und maschinenlokal;
auf einem fremden Checkout gibt dasselbe Kommando nichts aus. Es macht die Ablesung
**nachvollziehbar**, nicht **wiederholbar** — wiederholt wird eine span-gestützte Annahme, indem die
**Messung** neu gefahren wird, und dafür steht der Re-Evaluierungs-Trigger. Wäre es anders, wäre die
Beobachtung ein Beleg, und die Klassen-Unterscheidung hätte keinen Gegenstand.

Wer eine Span-Beobachtung als Beleg ausgibt, verletzt
[ADR-0011](0011-telemetrie-erfassung-policy.md); wer eine ADR-Annahme deshalb gar nicht erst am Span
abliest, verwirft die einzige Beobachtung, die es gibt. Diese ADR nimmt den zweiten Weg und führt
die Beobachtung als Annahme (d). **Der Rang ist damit keine Rangfolge, sondern eine
Klassen-Unterscheidung** — die zwei Stellen widersprechen sich nicht, sobald benannt ist, worüber
jede spricht.

**4. Die Verstetigung des `updatedInput`-Weges fällt aus — die committete Permission-Lage bleibt
unverändert.** [ADR-0019](0019-agent-guard-prueft-die-aufrufform.md) Festlegung 4 hat den Preis
vorher benannt: `updatedInput` wirkt nur mit `"allow"` oder `"ask"`; das erste überspringt für
**jeden** Agenten-Aufruf das Permission-System, das zweite fragt bei jedem nach. Der Gegenstand
dieses Preises ist entfallen — es gibt nichts zu verstetigen. Der committete `Agent`-Matcher führt
weiter genau einen Hook, den Guard, und der entscheidet die **Aufrufform**
([ADR-0019](0019-agent-guard-prueft-die-aufrufform.md) Festlegung 1). **Entschieden ist auch die
Gegenrichtung:** ein Hook, der für `Agent` eine Permission-Entscheidung oder ein `updatedInput`
zurückgibt, kehrt nicht ohne Folge-ADR in den Baum zurück — er wäre eine Änderung an der
Durchsetzung ([`AGENTS.md`](../../../AGENTS.md) §3.5). Ein **uncommitteter** Messaufbau bleibt
davon unberührt; er ist geübte Praxis und war es auch hier.

**5. Der Carveout wird übergeführt, und seine Adresse bleibt — das Verdikt steht allein hier.**
Der Stub trägt künftig `Status: Permanent — übergeführt in ADR-0021`, ein aktuelles
`Letzte Prüfung`-Datum und eine Geschichte-Zeile;
[`docs/plan/carveouts/README.md`](../carveouts/README.md) führt ihn aus *Aktiv* heraus in einen
eigenen Abschnitt für den permanenten Übergang.

**Er wandert nicht nach `done/`. Der Grund steht auf einem Bein aus der Quelle und einem aus der
Messung — und die zwei tun Verschiedenes.**

- **Die Quelle lässt den Ort offen.** Im Regelwerk steht **kein** Satz, der für einen gelebten,
  übergeführten Carveout ein Verzeichnis vorschreibt — alle **vier** Bullets der §Ziel-Form sind
  dafür gelesen, dazu §Werkzeug-Wahl und §Carveout-Audit-Slice, jede Ort-Aussage verbatim (Kontext
  oben). Das ist die **Erlaubnis** — und nur sie. Die zwei Sätze, die man dagegen halten könnte,
  sind dort ausdrücklich disponiert: §Ziel-Forms Klammer *„`make gates` grün ohne Ausnahmen"*
  gehört zur **Auflösung** und wird hier **nicht** als Move-Bedingung in Anspruch genommen, und der
  erste Bullet (*„dann gehört er nicht in `carveouts/`"*) spricht über die **Werkzeug-Klasse**, mit
  einem Vordersatz, der hier nicht zutrifft, und einem Nachsatz, den diese ADR **vollzieht**.
- **Die Messung entscheidet innerhalb dieses offenen Raums.** Der reine Move macht **18**
  eingehende Verweise in zwei nach [`AGENTS.md`](../../../AGENTS.md) §3.4 eingefrorenen ADRs zu
  `target-missing` (Kommando oben). Das ist keine Erlaubnis, sondern der **positive Grund** für
  die Wahl: von den drei offenen Wegen ist dieser der einzige, der `make gates` grün lässt, **ohne**
  eine Gate-Senkung zu kaufen — und die 18 sind der Beleg, dass die beiden anderen genau das
  kosten würden.

**Was den Ort ersetzt, ist der Status, nicht das Verzeichnis:** aktiv ist ab hier ein Carveout,
dessen Status es sagt. Das Verzeichnis `docs/plan/carveouts/` hört auf, Träger dieser Aussage zu
sein — wer sie liest, liest den Kopf des Dokuments und den Index. **Für
[CO-001](../carveouts/CO-001-bats-shell-lint.md) ändert das nichts**: sein Ausgang ist offen, und
er wandert bei seiner Auflösung nach `done/` wie vorgesehen.

**Zwei Anweisungen im Carveout selbst werden damit aufgehoben, und sie stehen hier namentlich.**
Sein Auflösungs-Trigger ordnet für diesen Ausgang neben der Überführung *„und nach `done/` zu
verschieben"* an; seine Verifikations-Checkliste führt den Haken *„Datei wird nach
docs/plan/carveouts/done/ bewegt (reiner git mv)"* samt `d-check:ignore`-Direktive. Beide
fallen. Mit ihnen fällt die Checkliste als Ganzes — Regelwerk `v3.5.2`, `modul-07-carveouts.md`
§Werkzeug-Wahl bei Diskrepanz: *„ADR: Trigger fällt weg, Checkliste reduziert auf die
Architektur-Folgen"*; die Architektur-Folgen stehen als Folgepflichten unten, und der Stub trägt
sie nicht ein zweites Mal. **Ohne diesen Schritt trüge die Weiche die Anweisung, die diese
Festlegung verbietet** — sichtbar für keinen Sensor, weil sie keinen Link bricht.

**Die erste Hälfte desselben Zitats — *„Trigger fällt weg"* — wird nicht als Löschung vollzogen,
und der Grund gehört hierher.** Sie heißt: es **wartet nichts mehr** auf diese Schwelle; an ihre
Stelle treten die Re-Evaluierungs-Trigger dieser ADR (Festlegung 1). Sie heißt **nicht**, dass der
Abschnitt `## Auflösungs-Trigger` aus dem Stub verschwindet, und dagegen spricht ein handfester
Grund: **diese ADR zitiert ihn zweimal verbatim** (§Der zweite Ausgang war vorgesehen), und
[ADR-0019](0019-agent-guard-prueft-die-aufrufform.md) führt seine zwei Ausgänge; eine Löschung
machte Zitate zweier ab dann immutabler ADRs quellenlos. Was den Leser trennt, ist der **Status**
im Kopf desselben Dokuments — und damit er dort nicht erst gesucht werden muss, bekommt der
Abschnitt einen Vorspann-Satz, der auf ihn zeigt (Folgepflicht 1, Änderung (3)). Die **Schwelle**
bleibt damit lesbar als das, was sie ist: die Frage, die diese ADR beantwortet hat, nicht eine
offene Bedingung.

**Ein zweiter Ort für das Verdikt entsteht nicht.** Der Stub bleibt eine **Weiche**, keine zweite
Fassung: er beschreibt die Diskrepanz und zeigt auf diese ADR
([ADR-0012](0012-haupt-kontext-ohne-token-bilanz.md) Folgepflicht 1: *„Ein zweiter Ort driftet"* —
*„Wer das Verdikt am Ort der Abweichung sucht, findet es nicht dort, sondern hier"*). Für die fünf
Stellen im Technik-Stratum ist diese Weiche die **einzige** Form, die das Doku-Gate trägt, und auch
das ist gemessen: ein Link von `spec/spezifikation.md` auf diese ADR ist `matrix-forbidden`, die
bare Kennung ist `id-unlinked` (Sonden in Folgepflicht 2). Sie behalten deshalb ihre **Adresse**;
nachgezogen wird ihre **Aussage**.

**Was diese ADR NICHT entscheidet** — drei Posten aus derselben Übergabe, mit anderen Eigentümern:
(i) die **Erlaubnis**, das Transkript als Quelle zu öffnen; sie ist nach
[ADR-0012](0012-haupt-kontext-ohne-token-bilanz.md) und
[ADR-0019](0019-agent-guard-prueft-die-aufrufform.md) eine Auftraggeber-Entscheidung, und sie
betrifft auch die Zahlen, die eine Prüfhandlung bereits committet im Baum abgelegt hat. (ii) ob
[`AGENTS.md`](../../../AGENTS.md) §3.7 §Geltungsbereich verbatim abgelegten **Skript-Text in
Dokumentation** erfasst — eine Hard-Rule-Frage, die einen eigenen Architect-Lauf und nach §3.8 einen
eigenen Commit braucht. (iii) die maschinenlokale, gitignorierte Permission-Datei neben der
committeten; sie gehört dem Auftraggeber. Festlegung 4 bindet den **committeten** Stand, und dass
kein Sensor dieses Repos dessen Verdrahtung prüft, steht unten als Grenze.

**Und ein vierter Posten, der nicht aus der Übergabe stammt, sondern aus dieser Entscheidung
selbst: Festlegung 5 gilt für diesen Carveout, nicht für die Gattung.** Ob ein Carveout **allgemein**
seine Adresse behält, sobald ein nach [`AGENTS.md`](../../../AGENTS.md) §3.4 eingefrorenes Artefakt
auf ihn zeigt, ist hier **nicht** entschieden — eine solche Regel autorisierte den nächsten Fall im
Voraus, und das ist genau die Form, die
[ADR-0017](0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) für ihre eigene Grenze verworfen
hat (*„Eine intensional formulierte Regel … autorisierte den zweiten Eintrag im Voraus"*). Der
nächste Fall wird einzeln entschieden, mit seiner eigenen Messung.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — **nichts tun**: der Carveout bleibt **aktiv** (nicht zu verwechseln mit dem **Ort**: Weg 3 im Kontext oben lässt die Adresse stehen und ändert den Status, A ändert nichts) | kein Aufwand; der Text ist geschrieben | sein Folge-Slice ist gefahren und hat den **zweiten** Ausgang geliefert; ein Carveout, dessen Trigger nur noch im fremden Vertrag liegt, ist nach Regelwerk `v3.5.2`, `modul-07-carveouts.md` §Ziel-Form (*„Fehlt der Folge-Slice, ist der Carveout de facto permanent"*) *de facto* permanent und behauptet dabei das Gegenteil. Das Audit je Welle müsste ihn fortan als *„weiterhin aktiv"* bestätigen, ohne dass sich etwas bewegen kann — genau die Doku-Drift, die Carveouts verhindern sollen |
| B — **zweiter Folge-Slice**: dieselbe Messung mit `"allow"` statt `"ask"` | liefe unbeaufsichtigt, ohne Rückfrage in der Sitzung | er misst dieselbe Kette an derselben Stelle. Die **Übernahme** des `updatedInput` ist gerade das, was beobachtet wurde; wirkungslos ist das **Feld**. `"allow"` erkaufte die Wiederholung mit einer Senkung der Durchsetzung ([`AGENTS.md`](../../../AGENTS.md) §3.5) — eine Permission-Änderung, um eine gemessene Wirkungslosigkeit zu bestätigen |
| C — **Träger wechseln**: Rolle aus `SubagentStop`, Zähler aus dem Transkript | das Ereignis trägt die Rolle unabhängig von der Betriebsart | ein Parser über eine Fremddatei mit dem **Prompt** — gegen [ADR-0011](0011-telemetrie-erfassung-policy.md) Festlegung 2 (*kein Byte fremden Inhalts*), dort schon als Alternative D verworfen und in [ADR-0019](0019-agent-guard-prueft-die-aufrufform.md) als Alternative B. Die Umkehr ist eine Erlaubnis des Auftraggebers, kein Architektur-Schritt |
| D — **Mess-Slice** auf die hier nie vermessenen Ereignis-Payloads | machte aus gelesener Doku eine Messung — *„die Payload ist die Quelle, die Doku ist Herkunft"* | er **löst nichts auf**: er beobachtet den zweiten fremden Weg, er führt ihn nicht herbei. Sein Erwartungswert ist negativ — die vendored Hooks-Referenz nennt ein `usage`-Objekt über ihre ganze Länge nur für die `tool_response` des Agenten-Werkzeugs. Dieselbe Abwägung hat [ADR-0012](0012-haupt-kontext-ohne-token-bilanz.md) als Alternative C geführt; das Wissen ist unten als Re-Evaluierungs-Trigger aufgehoben, ohne einen WIP-Platz zu belegen |
| E — **BF-Sub-Area-Markierung** statt Carveout oder ADR | kippte den Kontext, in dem die Diskrepanz entsteht, statt sie einzeln zu führen | Trichter-Frage 1 leitet hier nicht dorthin: einzelne Diskrepanz, kein gemeinsamer Geltungsbereich mit einem anderen Carveout, und das Symptom ist **invertiert** — die Doku ist vollständig, es fehlt die Quelle. Eine Modus-Deklaration wirkt eine Ebene höher und hätte hier keinen Gegenstand |
| **F — permanent, als ADR (gewählt)** | der Ausfall hört auf, auf einen Träger zu warten, den es nicht gibt; die Einordnung steht dort, wo Architekturentscheidungen stehen, und die Erfassung bekommt ihren Zahn statt einer Absicht | eine ADR ist ab *Accepted* immutabel ([`AGENTS.md`](../../../AGENTS.md) §3.4): kommt die Quelle zurück, entsteht eine neue ADR mit *Supersedes*, kein Federstrich. Und sie schließt keine Lücke — sie benennt sie dauerhaft. Mit dem Carveout entfällt zudem die **Wiedervorlage** (unten als Preis) |

## Konsequenzen

- **Positiv:** der Zustand ist entschieden statt aufgeschoben. Wer die fünf Stellen im
  Technik-Stratum liest, findet nach dem Nachzug (Folgepflicht 2) **keinen Satz mehr, der eine
  Messung als ausstehend führt**, und einen Zeiger, der auf ein Artefakt mit Verdikt-Status führt
  statt auf eine offene Frage. **Das Verdikt selbst steht dort nicht** — es steht hier, und das
  Technik-Stratum darf es nach `.d-check.yml` (`matrix.rules: {from: spec-straten, to: adr,
  allow: false}`) auch gar nicht adressieren. Genau so hat es
  [ADR-0012](0012-haupt-kontext-ohne-token-bilanz.md) Folgepflicht 1 für ihre eigene Abweichung
  gelöst.
- **Positiv:** die **Rollen-Achse** der Telemetrie ist nicht betroffen und trägt weiter; betroffen
  ist das Kosten-Aggregat. Die zwei Größen werden leicht für eine gehalten, und die Trennung ist
  der Grund, warum diese Entscheidung nicht die Telemetrie insgesamt betrifft.
- **Positiv:** die Erfassung bleibt bereit und hat dafür einen Wächter, der unter seiner Mutation
  **rot gesehen** ist; die Ortsfestigkeit des Stubs hat seit Festlegung 5 einen zweiten. Das sind die
  zwei Hälften dieser Entscheidung, die **überprüfbar** sind — die übrigen drei Festlegungen sind es
  nicht, und die Fitness Function sagt es dort.
- **Negativ, und das ist der Preis:** die Token-Bilanz je Rolle bekommt für Subagenten-Läufe
  dauerhaft keinen **neuen** Eingang. [`internal/report/report.go`](../../../internal/report/report.go)
  schreibt `Abdeckung: %d von %d Agent-Laeufen trugen Zaehler`; die erste Zahl **wächst nicht mehr**,
  weil kein neuer Agenten-Lauf Zähler trägt. **Ein Wert steht hier bewusst nicht** — und das ist
  keine Auslassung, sondern dieselbe Vorsicht, die
  [`spec/spezifikation.md`](../../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5 für die
  Nachrechnung von `total_tokens` ausspricht: der Bestand unter `.harness/state/spans/` ist
  gitignoriert, maschinenlokal und wird nach derselben Quelle, §5 **Abweichung 4**, ausdrücklich
  **nicht** aufgeräumt (*„Altbestände werden beim ersten Span einer Sitzung NICHT entfernt."*). Er
  trägt deshalb Läufe aus der Zeit, in der die Zähler ankamen, und `make span-report` gibt auf einer
  gewachsenen Maschine eine erste Zahl **über null** aus. Das widerspricht dieser Entscheidung
  nicht — es ist Altbestand; eine Zahl an dieser Stelle wäre ein Erwartungswert, der mit der
  Maschine wandert
  ([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2). Die Antwort auf
  *„was hat dieser Lauf gekostet?"* fehlt damit für **beide** Kontext-Arten — für den Haupt-Kontext
  nach [ADR-0012](0012-haupt-kontext-ohne-token-bilanz.md), für Subagenten-Läufe nach dieser ADR.
  Modul 15 §Token-Attributions-Regeln bleibt insoweit **unerfüllt**, als erklärte Abweichung, nicht
  als Erfüllung.
- **Negativ — die Wiedervorlage entfällt mit dem Carveout, und das ist keine Nebenwirkung.**
  [ADR-0019](0019-agent-guard-prueft-die-aufrufform.md) hat an die Stelle eines Wächters
  ausdrücklich das `Letzte Prüfung`-Datum des Carveouts und das Audit je Welle gesetzt —
  *„Beobachtung durch Wiedervorlage, nicht durch Sensor"*. Beides endet hier. Was bleibt, sind die
  Re-Evaluierungs-Trigger unten, und die behaupten keinen Termin. Das ist der ehrliche Preis des
  permanenten Pfads: er tauscht eine wiederkehrende Frage gegen eine entschiedene Sache.
- **Grenze, benannt statt geschlossen — kein Sensor prüft die Verdrahtung dieses Repos.** Festlegung
  4 sagt eine **Abwesenheit** in `.claude/settings.json` zu. Über `test/`, `Makefile`,
  `harness/tools/` und die Go-Tests berühren fünf Prüfstellen in drei Dateien diese Datei, und
  **alle fünf** gelten dem **emittierten** Repo
  ([`spec/spezifikation.md`](../../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5
  Abweichung 5). Für die Verdrahtung **dieses** Repos prüft keine etwas — und eine maschinenlokale,
  gitignorierte Permission-Datei sieht ohnehin kein Sensor und kein `git status`. Träger von
  Festlegung 4 ist der Rollen-Wechsel vor der Änderung, nicht ein Gate danach.
- **Folgepflicht 1 — der Übergang wird geschrieben, nicht verschoben; Implementer.** Regelwerk
  `v3.5.2`, `modul-07-carveouts.md` §Carveout-Audit-Slice verteilt die Arbeit ausdrücklich:
  *„Architect entscheidet bei „permanent" über die ADR-Überführung, Implementer führt `git mv` und
  Config-Updates aus."* Auszuführen ist hier **kein `git mv`** (Festlegung 5), sondern eine
  reine Inhaltsänderung an zwei Dateien. An
  [`docs/plan/carveouts/CO-002-token-achse-je-rolle.md`](../carveouts/CO-002-token-achse-je-rolle.md)
  **vier** Stellen, und die letzten zwei sind die, die man beim Statuswechsel übersieht: (1) der
  Status aus Festlegung 5, (2) ein aktuelles `Letzte Prüfung`-Datum und eine Geschichte-Zeile,
  (3) im Abschnitt `## Auflösungs-Trigger` fällt die Handlungs-Anweisung *„und nach `done/` zu
  verschieben"*, und der Abschnitt bekommt einen Vorspann-Satz, der auf den Status im Kopf zeigt —
  der Abschnitt selbst **bleibt**, weil diese ADR ihn zitiert (Festlegung 5, letzter Absatz),
  (4) der Abschnitt `## Verifikation (nach Auflösung)` fällt **als Ganzes** — mit **allen fünf**
  Haken (`awk '/^## Verifikation/,/^## Geschichte/' <datei> | grep -c '^- \[ \]'` → 5), unter
  ihnen der `git mv`-Haken samt `d-check:ignore`-Direktive: seine Bedingungen gelten einer
  Auflösung, die diese ADR ausschließt. An
  [`docs/plan/carveouts/README.md`](../carveouts/README.md) eine Stelle: der Eintrag wandert aus
  *Aktiv* in einen eigenen Abschnitt für den permanenten Übergang. **Die Zwei-Commit-Auflage
  entfällt** — [`AGENTS.md`](../../../AGENTS.md) §3.3 greift bei Move **und** Rewrite; hier gibt es
  nur den Rewrite. **Drei Prüfkommandos nach dem Vollzug**, weil die dritte und vierte Änderung
  keinen Link brechen und deshalb von keinem Gate gesehen werden — **jedes deckt genau die
  Änderung, neben der es steht**, und für (4) ist das die Überschrift, nicht eine ihrer Zeilen:
  über [`docs/plan/carveouts/CO-002-token-achse-je-rolle.md`](../carveouts/CO-002-token-achse-je-rolle.md)
  `grep -n 'zu verschieben'` → **leer (Exit 1)** für (3),
  `grep -n '^## Verifikation'` → **leer (Exit 1)** für (4); über dasselbe Ziel
  `grep -n 'd-check:ignore'` → **leer (Exit 1)** als Gegenprobe zu (4), weil die Direktive in
  seiner letzten Zeile steht. Heute trifft **jedes der drei genau eine Zeile** — und dass ein
  Kommando auf den `git mv`-Haken allein (4) **nicht** deckte, ist gefahren, nicht behauptet: löscht
  man in einer Wegwerf-Kopie **nur** diese eine Zeile, steht `grep -c 'carveouts/done'` auf **0**
  und `grep -c 'd-check:ignore'` auf **0**, während `grep -c '^## Verifikation'` auf **1** steht und
  der Abschnitt noch **4** Haken trägt
  (`awk '/^## Verifikation/,/^## Geschichte/' <datei> | grep -c '^- \[ \]'`). Ein breiteres Muster
  taugt umgekehrt auch nicht:
  `grep -n 'done/'` über dieselbe Datei trifft zusätzlich drei Verweise auf ein abgeschlossenes
  Planungs-Artefakt, die bleiben.
  Dazu `make docs-check` → **`0 Befund(e)`, Exit 0**, über genau dieser Form in einer
  Wegwerf-Kopie außerhalb des Baums gefahren. Die Datei-Zahl derselben d-check-Ausgabezeile wandert mit dem
  Markdown-Bestand und ist **kein** Erwartungswert
  ([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2).
- **Folgepflicht 2 — die sechs Zeiger behalten ihre Adresse, ihre Aussage wird nachgezogen;
  Spec-Eigentümer und Implementer.** Die fünf Stellen im Technik-Stratum sind nach **Eigenschaft**
  benannt, nicht nach Zeile (im `Schärft`-Kopf oben). **Was NICHT geschieht: sie ziehen nicht auf
  diese ADR** — beide wörtlichen Formen färben das Doku-Gate rot, und das ist gefahren
  (Wegwerf-Kopie, derselbe gepinnte d-check): der Link von `spec/spezifikation.md` auf diese ADR
  ergibt `spec/spezifikation.md:166 … matrix-forbidden`, Exit 1; die bare Kennung ohne Link ergibt
  `spec/spezifikation.md:166 ADR-0021 id-unlinked`, Exit 1. Das erste verbietet `.d-check.yml`
  (`matrix.rules: {from: spec-straten, to: adr, allow: false}`), das zweite die Kennungs-Link-Pflicht
  aus [`MR-001`](../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids).
  Die dritte Form — das Verdikt ausschreiben — wäre der zweite Ort, den Festlegung 5 ausschließt.
  **Nachzuziehen ist deshalb die Aussage, nicht die Adresse:** jeder Satz, der eine Messung als
  ausstehend führt oder den Ausfall als offene Frage beschreibt, fällt; der Zeiger bleibt stehen und
  führt auf einen Stub, dessen Kopf den Verdikt-Status trägt. Der sechste Zeiger steht im Kopf von
  [`.claude/hooks/pretooluse-agent-guard.sh`](../../../.claude/hooks/pretooluse-agent-guard.sh);
  [`AGENTS.md`](../../../AGENTS.md) §3.7 bindet ihn — ein Kommentar beschreibt, was da ist.
  **Zwei Prüfkommandos statt Erinnerung:**
  `grep -n 'CO-002' spec/spezifikation.md .claude/hooks/pretooluse-agent-guard.sh` — es müssen
  weiter **sechs Zeilen in zwei Dateien** sein; verschwindet eine, ist eine Aussage entfernt statt
  nachgezogen. Und `make docs-check` — er ist nach dem Nachzug grün, weil keine Adresse sich bewegt.
- **Folgepflicht 3 — zwei Zellen des Wellen-Closure; Planner.** Die Matrix-Zellen
  *Token-Attribution × Repo* (Hintergrund-Teil) und *Cache-Counter × Repo* führen nach dieser
  Entscheidung **ADR-Verdikt** statt *deklariert*: der Welle-Plan macht ihren Wert ausdrücklich vom
  Zustand des Carveouts abhängig, und das Vokabular führt *ADR-Verdikt* als eigenen Wert — eine
  Abweichung **ohne** Auflösungs-Trigger, an dessen Stelle die Re-Evaluierungs-Trigger der ADR
  treten. Die Zelle entsteht mit der Ergebnis-Notiz der Welle und bindet erst mit der Annahme hier.
  **Die Tool-Spalte ist nicht berührt** — [ADR-0020](0020-emittierte-modul-15-regeln.md) hat sie
  entschieden und den Maßstab des Carveouts dort ausdrücklich **nicht** importiert.
- **Folgepflicht 4 — das Carveout-Audit verliert einen Gegenstand, und es findet ihn nicht mehr am
  Verzeichnis; Planner.** Von den zwei geführten Carveouts bleibt **einer** aktiv. Weil der
  übergeführte an seiner Adresse liegen bleibt (Festlegung 5), **zählt ein Audit, das
  `docs/plan/carveouts/CO-*.md` auflistet, weiter zwei** — es muss den **Status** lesen, nicht das
  Verzeichnis. Ein Audit, das den übergeführten weiter als *„weiterhin aktiv"* bestätigt, bestätigt
  eine Entscheidung als offene Frage; ein Closure-Trigger, der beide nennt, ist danach nicht mehr
  erfüllbar, wie er dasteht. Das ist der Preis der Ortsfestigkeit, und er gehört dem Planner
  angesagt, nicht ihm überlassen.
- **Folgepflicht 5 — der fällige Mutations-Fall; Implementer.** Die Bedingung ist eine
  **Eigenschaft**, keine Adresse: ein Fall in `test/mutations/`, der die Erfassung der
  Ergebnis-Werte für `Agent` entfernt und den Test aus der Fitness Function rot färbt. Ohne ihn ist
  Festlegung 2 eine Absicht. **Der umsetzende Slice führt ihn als eigenen Punkt seiner Definition of
  Done** — dieselbe Auflage, die [ADR-0012](0012-haupt-kontext-ohne-token-bilanz.md) Folgepflicht 4
  für denselben Fall gestellt hat (*„Der Slice, der die Bilanz baut, führt die Nenner-Angabe als
  **eigenen** Punkt seiner Definition of Done"*): ohne DoD-Punkt liefe der Slice plan-konform ab,
  `make gates` und `make mutate` blieben grün, und ein nie angelegter Fall erzeugt kein Rot. Diese
  ADR benennt die Bedingung; sie schreibt weder den Fall noch den Plan.
- **Folgepflicht 6 — die emittierte Ebene bleibt unberührt, und das ist eine Entscheidung.** Sie
  führt heute weder Span-Emitter noch Agent-Guard (im `Schärft`-Kopf gemessen). Bekommt sie je
  einen, gilt diese Grenze dort unverändert — sie ist keine Eigenschaft unseres Aufbaus, sondern der
  Mechanik — und gehört dort **genannt**, nicht stillschweigend mitgeliefert.
- **Folgepflicht 7 — KEIN Eintrag im Adaptions-Block, und das ist entschieden, nicht vergessen;
  Architect.** Der Block registriert **Abweichungen** von der adoptierten Baseline
  ([`MR-021`](../../../harness/conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben)
  §Begründung: *„Der Adaptions-Block registriert Abweichungen von der adoptierten Baseline."*). Die
  Ablage eines **gelebten, übergeführten** Carveouts ist im Regelwerk nicht geregelt — das ist der
  Negativbefund des Inventars oben, über alle vier Bullets der §Ziel-Form samt §Werkzeug-Wahl und
  §Carveout-Audit-Slice gelesen, und der eine Satz, der `carveouts/` und *permanent* zusammen nennt,
  ist dort disponiert. **Eine Lücke, keine Abweichung** — und für eine Lücke sieht
  [`AGENTS.md`](../../../AGENTS.md) §3.8 ausdrücklich **keinen** Eintrag vor: *„Die Regel füllt
  damit eine Lücke, statt von der Baseline abzuweichen — deshalb steht zu ihr kein Eintrag im
  Adaptions-Block"*, mit
  [`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage) als Beleg. Ein Eintrag
  behauptete eine Baseline-Aussage, von der abgewichen würde, und die gibt es nicht.
  **Was der Eintrag geleistet hätte, leistet der Index:** wer im aktiven Verzeichnis einen Carveout
  mit Verdikt-Status findet, liest die Auskunft im Abschnitt aus Folgepflicht 1 und folgt dem
  Zeiger hierher. **Diese Folgepflicht ist damit eine Anweisung an den nächsten Architect-Lauf, der
  die Abweichung formulieren wollte:** er fände im Regelwerk nichts, wovon abgewichen wird, und
  das ist kein Versehen. Sollte eine spätere Baseline den Fall regeln, ist die Frage neu zu
  stellen — dann steht der Vergleich an, den [ADR-0016](0016-verweis-traegt-tag-und-zitat.md)
  Festlegung 2 für jeden Regelwerks-Beleg verlangt.

## Fitness Function (falls maschinell prüfbar)

**Die Festlegungen sind verschieden prüfbar, und sie zusammenzufassen wäre die Aussage, die zu weit
reicht.** Prüfbar sind **zwei** — Festlegung 2 (die Bereitschaft der Erfassung) und, seit der Ort
entschieden ist, Festlegung 5 (die Ortsfestigkeit des Stubs). Beide Wächter sind unter ihrer eigenen
Mutation **rot gesehen**, nicht angenommen.

| Tooling | Regel | Make-Target |
|---|---|---|
| Go-Test — `TestNoResponseFreetextReachesSpan` in [`internal/span/response_test.go`](../../../internal/span/response_test.go), `mustContain`-Block (verbatim: *„Die neun gelisteten Werte MUESSEN dastehen — sonst messe dieser Waechter eine Erfassung, die es nicht gibt."*) | Aus der gemessenen Vordergrund-Payload erfasst der Emitter **alle neun** Werte, jeden namentlich. Wer einen Eintrag aus `responseKeys()` in [`internal/span/response.go`](../../../internal/span/response.go) entfernt, weil heute keiner ankommt, färbt den Test rot | `make test` (in `make gates`) |
| Go-Test — `TestOnlyAgentToolGetsResponseValues` in derselben Datei | hält die **Werkzeug-Achse**, **nicht** die neun Werte: erfasst wird nach dem Werkzeug-Namen. Seine Gegenprobe prüft **vier** der neun (`spawned_role`, `total_tokens`, `input_tokens`, `model_version`); die übrigen fünf hält er nicht — dazu gehören die zwei Cache-Zähler. Bewacht von `test/mutations/133-span-werkzeugachse-geweitet.sh` | `make test` (in `make gates`) |
| `test/mutations/` — **fällig (Folgepflicht 5), existiert heute nicht** | Ein Eintrag der Positiv-Liste wird **entfernt**; `TestNoResponseFreetextReachesSpan` **muss** dabei rot werden. Die vorhandenen Fälle decken diese Richtung nicht: 123–126 **fügen** einen Freitext-Schlüssel hinzu, 127 negiert die **Grenze** der Liste, und `grep -ln 'responseKeys' test/mutations/*.sh` → **leer (Exit 1)** | `make mutate` (nicht in `make gates`; CI pro Push, [`MR-014`](../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions)) |
| d-check, Modul `links` (in `.d-check.yml` aktiv) | Die Adresse des Stubs ist ortsfest: wer [`docs/plan/carveouts/CO-002-token-achse-je-rolle.md`](../carveouts/CO-002-token-achse-je-rolle.md) verschiebt oder löscht, färbt den Gate rot — die eingehenden Verweise werden `target-missing` | `make docs-check` (in `make gates`) |

**Die zwei Mutationen sind gefahren, je in einer Wegwerf-Kopie außerhalb des Baums** (2026-08-22;
der Arbeitsbaum blieb unberührt):

```sh
# Zeile 1 der Tabelle — die zwei Cache-Zähler aus der Positiv-Liste entfernen:
sed -i '/{path: \[\]string{"usage", "cache_creation_input_tokens"}/d;
        /{path: \[\]string{"usage", "cache_read_input_tokens"}/d' internal/span/response.go
make test-go
#   --- FAIL: TestNoResponseFreetextReachesSpan
#       "cache_creation_input_tokens":33 fehlt in der Span-Zeile
#   TestOnlyAgentToolGetsResponseValues bleibt GRUEN — er misst eine andere Eigenschaft.

# Zeile 4 der Tabelle — den Stub verschieben (Kommando im Kontext oben):
#   Exit 1, alle Befunde target-missing; davon 18 in den zwei eingefrorenen ADRs
#   (grep -cE '^docs/plan/adr/(0019|0020)-'). Die Summe des Laufs wandert und steht
#   deshalb nirgends in dieser ADR — MR-025 Setzung 2.
```

**Was diese Zeilen NICHT leisten.** (1) Sie binden, dass die Erfassung **bereit bleibt** — nicht,
dass je ein Lauf Zähler trägt. Dafür gibt es kein Gegenbeispiel, das rot werden könnte
([`AGENTS.md`](../../../AGENTS.md) §3.6): solange die Zähler in keiner Payload stehen, ist die
Abwesenheit nicht mutierbar. (2) Die vierte Zeile bindet die **Adresse** des Stubs, nicht seinen
**Status**: dass sein Kopf `Permanent — übergeführt in ADR-0021` trägt und der Index ihn aus *Aktiv*
herausführt, prüft kein Modul von `.d-check.yml` — das ist die Hälfte von Festlegung 5, deren Träger
die Rollen-Trennung bleibt. Ein Gate, das den Stub im aktiven Verzeichnis **duldet**, sagt nichts
darüber, dass er dort richtig steht.

**Für die Festlegungen 1, 3 und 4 gibt es keinen Wächter, und das ist eine Aussage, kein
Auslassen.** Festlegung 1 entscheidet eine **Abwesenheit der Quelle** — dieselbe Lage wie in
[ADR-0012](0012-haupt-kontext-ohne-token-bilanz.md) Festlegung 1. Festlegung 3 ist eine Urteilsregel
über Text: `make comment-claims` prüft vier Pfad-Muster (`internal/**/*.go`, `cmd/**/*.go`,
`harness/tools/*.sh`, `.claude/hooks/*.sh`) und damit **kein** Markdown, und `make docs-check`
prüft Links, Anker, Kennungen, Matrix, Codepfade und Spans — **keine Behauptungen**. Festlegung 4
sagt eine Abwesenheit in einer Datei zu, die kein Sensor dieses Repos liest (Konsequenzen, §Grenze).
Ihr Träger ist die Rollen-Trennung vor der Änderung — [`AGENTS.md`](../../../AGENTS.md) §3.4 und
§3.5 —, nicht ein Gate danach. **Und die Wiedervorlage, die bisher an ihre Stelle trat, endet mit
dem Carveout** (Konsequenzen).

## Re-Evaluierungs-Trigger

- **Wenn `Agent` wieder eine WIRKSAME Vordergrund-Form anbietet** *(feedforward — fremder Vertrag,
  kein Sensor; wirkt nur, wenn jemand sie liest)*: **die bloße Annahme des Feldes ist es nicht** —
  die ist gemessen und wirkungslos. Beobachtbar ist der Trigger daran, dass ein so gestarteter Lauf
  **nicht sofort zurückkehrt** und seine `tool_response` die vier Zähler trägt. **Wer es merkt:**
  wer einen Agenten-Aufruf fährt und die Antwort ansieht. Dann fällt Annahme (a).
- **Wenn ein Hook-Ereignis die Zähler trägt** *(feedforward — nur sichtbar, wer das Ereignis
  verdrahtet und seine Schlüsselmenge misst)*: dann fällt Annahme (b), und der Träger wechselt, ohne
  dass die Betriebsart zurückkommen muss. **Wer es merkt:** der Slice, der ein weiteres Ereignis
  verdrahtet — heute verdrahtet dieses Repo `SubagentStop` nicht.
- **Wenn die Messung wiederholt wird und trägt** *(feedback — eine Messung, keine Erlaubnis; sie ist
  einmal gefahren und ist wiederholbar)*: die Beobachtung ist eine **Momentaufnahme** eines fremden
  Vertrags und gilt für die Werkzeug-Fassung, unter der sie lief. **Woran:** derselbe Aufbau, in
  einer **danach gestarteten** Sitzung — die Hook-Liste einer Sitzung wird beim Start eingefroren,
  der Hook-Befehl dagegen bei jedem Feuern frisch von Platte gelesen (Nebenbefund derselben
  Messung). Trägt der so gestartete Lauf die vier
  Zähler und `spawned_role`, fällt Annahme (d), und die Frage nach der Verstetigung samt
  Permission-Folge ist neu zu entscheiden — Festlegung 4 fällt mit ihr. **Der positive Ausgang
  belegt sich selbst** und braucht keine Kontroll-Beobachtung; der negative bestätigt nur den Stand.
- **Wenn das Doku-Gate einen referenz-weiten Ausschluss für `links` bekommt** *(feedforward — eine
  Werkzeug-Version, kein Sensor; sichtbar wird sie, wer `d-check --print-config` gegen einen neueren
  Digest fährt)*: dann ist der Move nach `done/` ohne datei-weite Senkung bezahlbar, und der Ort aus
  Festlegung 5 ist neu zu entscheiden — dieselbe Lage, die
  [ADR-0017](0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) als ihren Ziel-Zustand benennt
  (*„dann ist der datei-weite Eintrag durch den präzisen zu ersetzen"*). **Wer es merkt:** der
  Slice, der das Werkzeug hebt. Es fällt dann keine Annahme dieser ADR — die Sache bleibt, nur ihr
  Preis ändert sich.
- **Wenn die Transkript-Entscheidung kippt** *(feedforward — eine **Erlaubnis des Auftraggebers**,
  kein Sensor)*: dann fällt Annahme (c), und Alternative C ist neu zu bewerten — **zuerst als
  Sicherheitsfrage, dann als Erfassungsfrage**. Dieser Trigger öffnet nicht die Frage dieser ADR,
  sondern eine andere: was aus einer Quelle mit vollem Gesprächsinhalt überhaupt in einen Span darf.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-08-22 | **Accepted** | Annahme durch den Auftraggeber nach vier dokumentierten Runden — [`2026-08-22-adr-0021-bestaetigungsrunde.md`](../../reviews/2026-08-22-adr-0021-bestaetigungsrunde.md), [`2026-08-22-adr-0021-bestaetigungsrunde-runde-2.md`](../../reviews/2026-08-22-adr-0021-bestaetigungsrunde-runde-2.md), [`2026-08-22-adr-0021-verdikt-runde.md`](../../reviews/2026-08-22-adr-0021-verdikt-runde.md) und [`2026-08-22-adr-0021-schlussrunde.md`](../../reviews/2026-08-22-adr-0021-schlussrunde.md); nach deren Summary-Tabellen läuft der Befund-Stand HIGH 3 → 0 → 0 → 0, MEDIUM 3 → 4 → 1 → 0, LOW 2 → 1 → 2 → 0, die letzte Runde ohne blockierenden Befund. Ab hier immutabel ([`AGENTS.md`](../../../AGENTS.md) §3.4) — spätere Schärfungen als neue ADR mit *Supersedes*. **Die Sache selbst — der Ausfall ist permanent, und der übergeführte Stub behält seine Adresse — ist in keiner der vier Runden angegriffen worden;** beanstandet waren die Sätze, mit denen sie vollzogen und belegt wird. **Zwei benannte Kleinigkeiten sind bewusst nicht mehr nachgezogen worden:** der Zielpfad des Übergangs steht in Folgepflicht 1 als Zuschreibung statt als gezeigter Schritt, und die zweite Hälfte von deren Änderung (3) — der Vorspann-Satz — hat kein Prüfkommando. Beide ändern keine Festlegung und färben kein Gate; sie nach der Freigabe zu ändern hieße, ungeprüften Text in eine einfrierende Datei zu schreiben |
| 2026-08-22 | Überarbeitet, weiter **Proposed** | Der **Ort** des Carveouts ist entschieden statt mitgeschrieben. Die Begründung steht auf zwei Beinen mit verschiedener Aufgabe: das Regelwerk **schreibt für einen gelebten, übergeführten Carveout kein Verzeichnis vor** — alle vier Bullets der §Ziel-Form samt §Werkzeug-Wahl und §Carveout-Audit-Slice gelesen, und die zwei Sätze, die man dagegen halten könnte, sind **disponiert** statt übergangen (die Klammer *„`make gates` grün ohne Ausnahmen"* gehört zur Auflösung; der Pflicht-Header-Satz greift nach seiner Logik, nicht nach seinem Buchstaben — sein Vordersatz trifft nicht zu, seinen Nachsatz vollzieht diese ADR, und als Ablage-Regel widerspräche er sich selbst, weil `carveouts/done/` ein Unterverzeichnis von `carveouts/` ist) —, und die Messung entscheidet darin (**18** eingehende Verweise in zwei nach [`AGENTS.md`](../../../AGENTS.md) §3.4 eingefrorenen ADRs würde der Move zu `target-missing` machen). Daraus folgt für die Ablage-Frage **Lücke, nicht Abweichung** — Folgepflicht 7 ordnet deshalb **keinen** Adaptions-Eintrag an und sagt, warum. Zwei Ort-Anweisungen im Carveout selbst sind namentlich aufgehoben; das Prüfkommando zu (4) sieht den ganzen Abschnitt, nicht eine seiner Zeilen, und dass der Abschnitt `## Auflösungs-Trigger` **bleibt**, ist begründet statt unterlassen. Die Fitness Function nennt den Wächter, der die neun Werte **wirklich** hält, und den, der nur die Werkzeug-Achse hält; beide Mutationen sind gefahren. Annahme (d) trägt ihr Kommando im eigenen Text und als eindeutigen Fundschlüssel die `tool_use_id`. Wandernde Summen stehen nicht mehr im Text. Gegenlage: [`docs/reviews/2026-08-22-adr-0021-bestaetigungsrunde.md`](../../reviews/2026-08-22-adr-0021-bestaetigungsrunde.md), [`docs/reviews/2026-08-22-adr-0021-bestaetigungsrunde-runde-2.md`](../../reviews/2026-08-22-adr-0021-bestaetigungsrunde-runde-2.md) und [`docs/reviews/2026-08-22-adr-0021-verdikt-runde.md`](../../reviews/2026-08-22-adr-0021-verdikt-runde.md) |
| 2026-08-22 | **Proposed** | Übergabe an den Architect aus dem negativen Ausgang der Messung: [`docs/reviews/2026-08-21-updatedinput-messung.md`](../../reviews/2026-08-21-updatedinput-messung.md) §7/§8. Der Trichter aus Modul 7 ist mit derselben Frage-Reihenfolge gefahren wie in [ADR-0019](0019-agent-guard-prueft-die-aufrufform.md); Frage 2 kippt auf *Nein*, weil der Weg, der sie auf *Ja* stellte, gefahren und negativ ist. Mit in die Übergabe kam der Rang zwischen [ADR-0011](0011-telemetrie-erfassung-policy.md) Festlegung 3 und [ADR-0019](0019-agent-guard-prueft-die-aufrufform.md) Festlegung 4 — er steht als Festlegung 3, nicht als Korrektur an einer der beiden ([`AGENTS.md`](../../../AGENTS.md) §3.4) |
