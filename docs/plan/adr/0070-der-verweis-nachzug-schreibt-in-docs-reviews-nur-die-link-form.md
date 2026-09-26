# ADR-0070: Der Verweis-Nachzug schreibt in `docs/reviews/**` nur die Adresse in Link-Form — ein Pfad im Code-Span ist dort Chronik, die das Doku-Gate ausdrücklich nicht prüft

**Status:** Accepted

**Datum:** 2026-09-26

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md) (**Accepted** — Festlegung 1 ist der
Gegenstand, den diese Entscheidung an **einer** Stelle schneidet; Festlegung 2 bis 5 bleiben),
[ADR-0033](0033-wellen-archivierung-als-unterkommando.md) (**Accepted** — der zweite Träger des
Nachzugs; sein Abnahme-Kriterium 1 ist hier gelesen, nicht geändert),
[ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) (**Accepted** — Festlegung 3
bindet den Schreiber, Festlegung 4 den Beweger; beide unberührt),
[ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) (**Accepted** — der Beleg des
Accept-Übergangs),
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (das Gate
sagt nur über seinen Prüfbereich etwas; der Prüfbereich wird hier nicht verkleinert),
[`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage) (eine Abweichung von der
Baseline schuldet einen Eintrag — hier besteht keine, §Kontext),
[`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben dem Kommando, das sie liefert; keine ist ein Erwartungswert)

**Schärft:** — Prozess-ADR ohne Spec-Stratum: sie ändert die Reichweite eines Werkzeugs, keine
Spec-Aussage und keine Gate-Schwelle.

**Supersedes (Teil):** [ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md)
§Entscheidung Festlegung 1, und dort **genau einen Wert** — die Reichweite *„ersetzt die
Pfad-Adresse"* für den Baum `docs/reviews/`: Sie gilt dort künftig für die Adresse in Link-Form
(`](ziel)`), nicht mehr für jede Form. Alles andere jener Festlegung bindet unverändert fort — das
Kriterium (*ändert sich die Aussage?*), die drei übrigen Bäume, die Aussage *„beide Träger behalten
ihre heutige Ausnahmeliste; keiner bekommt einen weiteren ausgenommenen Baum"* — und die
Festlegungen 2 bis 5 bleiben vollständig unberührt. Das ist **kein** ausgenommener Baum, sondern eine
Form-Regel. Die eine Nebenwirkung auf Festlegung 4 jener ADR (Gegenform 2, der Operand im
Mess-Kommando) steht unter §Konsequenzen.

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md`
§Ziel-Form: ADR (MADR); Baseline-Regelwerk `modul-08-agentenrollen.md` §Rollen-Regeln
(ADR-Änderung: Architect schreibt; Accepted-ADRs überschreibt niemand — Folge-ADR).

---

## Kontext

### Der Anlass: der Nachzug hat in einem Report eine Tatsache umgeschrieben

Ein Verifikations-Report nennt in einer Mess-Zeile die Ausgabe eines Kommandos: es *„nennt … einen
fremden Slice"* unter dem Pfad, unter dem der Slice **zu diesem Zeitpunkt** lag. Der Nachzug eines
späteren Lifecycle-Moves ersetzte den Pfad; der Report behauptete danach einen Ort, an dem die
Datei nie lag. Wiederhergestellt hat es ein Planner-Commit von Hand
(`git show --stat bd76d800`), begründet mit [`AGENTS.md`](../../../AGENTS.md) §3.11 und dem
Abnahme-Kriterium 1 aus [ADR-0033](0033-wellen-archivierung-als-unterkommando.md). **Der Ausgang
war richtig, die Begründung trägt nicht:**

- [`AGENTS.md`](../../../AGENTS.md) §3.11 bindet den **Schreiber** und den Lauf, der einen Move
  **plant**; ein Verbot für den Nachzug steht dort nicht.
- Abnahme-Kriterium 1 von [ADR-0033](0033-wellen-archivierung-als-unterkommando.md) lautet
  verbatim: *„Der fail-closed-Wächter gegen einen lebenden Verweis auf einen zu löschenden
  Review-Report schließt `docs/reviews/**` nicht aus."* Es spricht über den **Suchraum des
  Hänger-Wächters**, nicht über den Nachzug
  (`grep -c 'Der fail-closed-Wächter gegen einen lebenden Verweis' docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md`
  → **1**). Ein Wächter, der auf `docs/reviews/**` **liest**, und ein Nachzug, der dort **schreibt**,
  sind zwei Zweige desselben Trägers; die Zeile in `harness/tools/slice-mv.sh`, die das Kriterium
  für die Ausnahmeliste zitiert, überträgt es auf den falschen Zweig.

Für den Nachzug in `docs/reviews/**` steht die Quelle in
[ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 1 — und die kennt in
diesem Baum **eine** Reichweite, nicht zwei.

### Das Doku-Gate unterscheidet die Formen dort schon — und in `done/` nur zum Teil

```sh
grep -n 'exempt-paths: \["docs/reviews/\*\*"\]' .d-check.yml    # unter codepaths: — der Kommentar darüber sagt,
                                                                # Lifecycle-Pfade in Reviews veralten per Definition
```

Ein Pfad im **Code-Span** wird in `docs/reviews/**` nicht geprüft (`codepaths`), die
`ids`-Regeln nehmen den Baum ebenso aus; der **Markdown-Link** wird geprüft (`links`, `anchors`
tragen keine Ausnahme). Der Nachzug einer Code-Span-Adresse in einem Report beweist damit
nichts und schreibt trotzdem — und was er schreibt, ist dort oft eine Tatsachenaussage über den
damaligen Ort.

**Was `codepaths` in `done/` prüft, ist gemessen und enger als der Code-Span.** Eine Kopie von
`git archive` mit konstruierter Probe (Konsistenz-Runde `2026-09-26-review-adr-0070-konsistenz`,
§Prüfpunkte (e) 3): ein **reiner Pfad-Code-Span** auf einen bewegten Slice in `done/` färbt
`make docs-check` mit `codepath-missing` rot; derselbe Pfad als **Operand in einem Kommando-Span**
und der Pfad in einem **Code-Block** bleiben grün; der reine Pfad-Span in einem Report bleibt grün
(Ausnahme des Baums). Die Aussage ist **an einer konstruierten Probe** gefahren, an keinem realen
Move: Ein fünfter Lauf desselben Moves mit der Form-Regel auch in `done/` ließ **kein**
`codepaths` rot werden — die eine dann nicht ersetzte Zeile lag in einem Code-Block. **Kein Sensor
hält diese Gate-Aussage**; sie steht hier als Messung.

```sh
export LC_ALL=C
git grep -ohE '`[^`]*(open|next|in-progress)/slice-[^`]*`' -- docs/plan/planning/done |
  awk '{ if ($0 ~ /^`[^ ]*`$/) r++; else o++ } END{print "rein " r+0 " · mit Leerzeichen " o+0}'   # rein 17 · mit Leerzeichen 42
git grep -ohE '`[^`]*(open|next|in-progress)/slice-[^`]*`' -- docs/plan/planning/done |
  grep -cE '^`(git |grep |ls |cat |sed |make |awk |test |wc )'                                    # 32 der 42 beginnen mit einem Kommandowort
```

**Keine Erwartungswerte**, und die Trennung „rein / mit Leerzeichen" ist eine Näherung an
*Pfad-Span / Operand*. Tragend ist die Größenordnung: In `done/` ist der reine Pfad-Span die
kleinere Hälfte der Code-Spans, und die größere ist die Form, die das Gate nicht sieht.

### Gemessen — je Baum, je Form

```sh
export LC_ALL=C
for t in docs/plan/planning/done docs/reviews; do
  echo "$t"
  git grep -noE '\]\([^)#]*/(open|next|in-progress)/[^)#]*\)' -- "$t" | wc -l           # Markdown-Link-Vorkommen
  git grep -noE '`[^`]*(open|next|in-progress)/slice-[^`]*`' -- "$t" | wc -l            # Code-Span-Vorkommen
done
# Stand f8d33b38 (spätere Reports zählen mit; das Kommando liefert am jeweiligen Stand die Zahl):
# docs/plan/planning/done  527 Links · 59 Code-Spans
# docs/reviews              55 Links · 610 Code-Spans
git grep -lE '`[^`]*(open|next|in-progress)/slice-[^`]*`' -- docs/reviews | wc -l       # 213 Dateien
```

**Keine Erwartungswerte** — die Zahlen wandern mit dem Bestand. Tragend ist das Verhältnis: In
`docs/reviews/**` ist die Code-Span-Form die **überwiegende** Adress-Form, und sie ist die, die das
Gate nicht liest.

### Vier Ausnahme-Politiken, an einem Move gemessen

Derselbe Move (ein Slice, auf den zwei Link-Zeilen und weitere Code-Span-Zeilen in Reports und
sechzehn Zeilen in `done/` zeigen) in vier Kopien von `git archive f8d33b38` außerhalb des Repos, je
ein `make docs-check`; A bis C stellt die Kopie durch eine Zeile in der Ausnahmeliste her, D bildet
einen Link-Nachzug per `sed` auf B nach. Rezept und Skript stehen im Verdikt
[`2026-09-26-architect-verdikt-slice-mv-und-eingefrorene-adressen.md`](../../reviews/2026-09-26-architect-verdikt-slice-mv-und-eingefrorene-adressen.md).
Alle vier tragen denselben **einen** Befund, den der Zustand `in-progress/` ohne Roadmap-Marker
erzeugt (`planning-drift`); tragend ist die Differenz. Die Spalte *geprüfte Dateien* ist die Zeile
`d-check: N Datei(en) geprüft` aus der Ausgabe von `make docs-check` je Kopie, Stand des
Basis-Commits.

| Politik | `target-missing` (Differenz zu A) | Code-Span-Zeilen in Reports geändert | geprüfte Dateien (Stand `f8d33b38`) |
|---|---|---|---|
| A — heute: Nachzug in jeder Form, jeder Baum | 0 | **ja** (Tatsache umgeschrieben) | 1964 |
| B — `docs/reviews` ganz ausgenommen | **+2** (die zwei Links sterben) | nein | 1964 |
| C — `docs/plan/planning/done` ganz ausgenommen | **+15** | ja | 1964 |
| **D — `docs/reviews` nur Link-Form** | **0** | **nein** | 1964 |

**D erreicht, was B will (die Tatsache bleibt stehen), ohne was B kostet (tote Links).** Die Zahl der
geprüften Dateien ist in allen vier Zeilen dieselbe: keine dieser Politiken nimmt eine Datei aus dem
Prüfbereich; B und C lassen ein **Gate rot** werden, das in den Baum hineinschaut, D nicht.

### Die Träger lesen kein Markdown — das trägt die Form-Regel und ihre Grenze

Beide Träger ersetzen kontext-blind: `harness/tools/slice-mv.sh` mit einer `sed`-Regel über die
ganze Datei, `internal/archive/refs.go` mit einer Wortgrenzen-Regex (`ErsetzePraefix`); die
präfixlose Form ist an `](` verankert, mehr nicht. `harness/sensors/slice-mv.md` führt die Folge als
Grenze: Steht Link-Syntax selbst in einem Code-Span oder Code-Block, wird sie mitersetzt. Wie viel
das im Baum `docs/reviews/` betrifft, ist gemessen:

```sh
export LC_ALL=C
git ls-files 'docs/reviews/*.md' | xargs awk '/^```/{f=!f;next} f{b+=gsub(/\]\([^)#]*\/(open|next|in-progress)\/[^)#]*\)/,"")} !f{n=split($0,p,"`");for(i=2;i<=n;i+=2)s+=gsub(/\]\([^)#]*\/(open|next|in-progress)\/[^)#]*\)/,"",p[i])} END{print "Span " s+0 " · Block " b+0}'   # Span 9 · Block 0
git ls-files 'docs/reviews/*.md' | xargs awk '/^```/{f=!f;next} !f{n=split($0,p,"`");for(i=2;i<=n;i+=2)while(match(p[i],/\]\([^)#]*\/(open|next|in-progress)\/[^)#]*\)/)){print substr(p[i],RSTART+2,RLENGTH-3);p[i]=substr(p[i],RSTART+RLENGTH)}}' |
  sed 's#.*/##' | while IFS= read -r b; do ls docs/plan/planning/open/"$b" docs/plan/planning/next/"$b" docs/plan/planning/in-progress/"$b" 2>/dev/null; done | wc -l   # 0
```

**Neun** Zitat-Vorkommen von Link-Syntax vollständig innerhalb eines Einzel-Backtick-Spans, **keines**
in einem Code-Block, und **keines** nennt heute einen Slice, der in `open/`, `next/` oder
`in-progress/` liegt: Die Menge ist real und derzeit inert. **Keine Erwartungswerte**; der Zähler
liest Einzel-Backtick-Spans zeilenweise und ist eine Näherung.

### Baseline: keine Abweichung, kein Eintrag

Die Baseline `v6.9.0` sagt zum Nachzug (`modul-06-roadmap.md` §Wellen-Closure-Prozedur, Schritt 4):
*„Der Umzug ändert Pfade; die Operation zieht die Verweise nach — in **beiden** Formen, mit
Verzeichnis-Präfix und geschwister-relativ."* **Beide Formen** sind dort zwei Schreibweisen desselben
Pfades, nicht Link gegen Code-Span; die Stelle sagt über die Form des Umfelds nichts. Diese
Entscheidung liest sie und weicht nicht von ihr ab: Die Link-Form bleibt in beiden Schreibweisen
vollständig nachgezogen. Ob ein Pfad in einem Code-Span ein *Verweis* ist, lässt die Stelle offen;
die Entscheidung nimmt für den Baum `docs/reviews/` die enge Lesart (ein Verweis ist ein Link) — **die Einordnung hängt an dieser Lesart**: liest der Kurs die Stelle einmal weiter, ist der Eintrag fällig. Eine
Abweichung, die [`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage) mit einem
Eintrag belegte, besteht darum nicht — dieselbe Einordnung wie in
[ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md), die ebenfalls keinen Eintrag führt.

### Der Schreiber trägt nur zum Teil — und das ist hier kein Grund für eine neue Pflicht

Seit der Einführung von §3.11 (`git log -S'3.11 Eine Adresse, die der Prozess bewegt' --format=%h -- AGENTS.md`)
sind Pfad-Links auf bewegliche Slices in Zeitdokumente **hineingeschrieben** worden:

```sh
git log --format='C %h' --invert-grep --grep='^slice-mv:' --grep='^archive-welle' 05332d63..HEAD -p -U0 \
    -- docs/plan/planning/done docs/reviews |
  awk '/^\+\+\+ /{f=$2} /^\+[^+]/ && /\]\([^)]*\/(open|next|in-progress)\/slice-/{ if (f ~ /docs\/reviews/) {r++} else {d++} }
       END{print "done " d+0 " Zeilen · reviews " r+0 " Zeilen"}'    # done 67 · reviews 81
```

(**keine Erwartungswerte**; die Zahl zählt Zeilen, ohne Werkzeug-Commits.) Die Schreiber-Regel
([ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) Festlegung 3) hält also für
Markdown-Links **nicht vollständig**, und sie muss es nicht: Der Nachzug ist für diese Form die
entschiedene Antwort ([ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 1),
und unterbleibt er, färbt sich `make docs-check` rot (B, C oben). **Eine zusätzliche Pflicht am
Closure-Commit wäre ein Urteil je Link ohne Sensor** — und sie sparte nur, was das Werkzeug
kostenlos und gate-geprüft tut. **Akzeptiertes Negativ, mit Grund:** die Link-Form im Zeitdokument
bleibt zulässig, der Nachzug ist ihr Träger, und der Schreiber-Verzicht bleibt eine Empfehlung mit
dem Rang, den ihr [`AGENTS.md`](../../../AGENTS.md) §3.11 gibt — *Adresse, die der Prozess bewegt, steht
nicht in einem einfrierenden Artefakt* —, ohne dass ein Lauf daran scheitert. Der Schaden, den eine
Schreiber-Pflicht verhinderte, wäre ein Link-Nachzug, der eine Aussage verändert; ihn fängt
Re-Evaluierungs-Trigger 4, und mit ihm ist die Frage nach der Pflicht neu.

## Entscheidung

**Wir wählen Option D: in `docs/reviews/**` ersetzt der Nachzug die Adresse nur dort, wo sie das
Ziel eines Inline-Markdown-Links ist; jede andere Pfad-Adresse bleibt Byte für Byte.** Fünf
Festlegungen.

**1. Form-Regel für den Baum `docs/reviews/`.** Beide Träger des Verweis-Nachzugs — `make slice-mv`
(eingehend) und der Nachzug von `archive-welle` — ersetzen in einer Datei unter `docs/reviews/` die
Adresse ausschließlich dort, wo sie **unmittelbar hinter `](` steht** und bis zum schließenden `)`
oder `#` reicht. **Die Erkennung ist syntaktisch, nicht kontextuell** — die Träger lesen kein
Markdown (§Kontext), und die Regel verlangt keine Kontext-Erkennung. Daraus folgt:

- **Byte für Byte bleibt jede Pfad-Adresse, die nicht hinter `](` steht:** der reine Pfad-Code-Span,
  der Operand in einem Kommando-Span, der Pfad im Code-Block, der Pfad im Fließtext. Ein Link, dessen
  **Text** ein Code-Span ist (`` [`name`](ziel) ``), ist Link-Form — sein Ziel steht hinter `](`.
- **Link-Syntax, die als Zitat innerhalb eines Code-Spans oder Code-Blocks steht, ist Link-Form im
  Sinne dieser Regel und wird ersetzt.** Das ist die Grenze, die `harness/sensors/slice-mv.md` dem
  Träger heute schon zuschreibt, und sie ist **benannt statt behoben**: Byte-gleich wäre sie nur
  mit Kontext-Erkennung — Span-Grenzen und Fence-Zustand — in zwei Trägern und zwei Sprachen
  (zeilenweises `sed`, Go-Regex), mit der Kopplung der Liste `KERN` aus `test/slice-mv.bats`, für
  eine Menge von 9 inerten Vorkommen (§Kontext). Sie wird nicht zugesagt; Re-Evaluierungs-Trigger 6
  hält, wann sie neu zu bewerten ist.
  **Gebunden ist nur die Span-Hälfte:** Fitness-Zeile 2 fährt den Span-Fall. Für den Code-Block bindet
  kein Fall die Grenze — sein Bestand ist 0 (`Block 0` hinter dem Kommando in §Kontext, Absatz *Die
  Träger lesen kein Markdown*), und eine Zusage über ihn hätte kein rot gesehenes Gegenbeispiel
  ([`AGENTS.md`](../../../AGENTS.md) §3.6). Benannte Lücke wie die Referenz-Definition; Trigger 6 gilt
  für Span und Block.
- **Die Referenz-Definition `[name]: ziel` ist nicht Teil der Regel.** Bestand: 0
  (`git grep -nE '^\[[^]]+\]:[[:space:]]*\S*(open|next|in-progress)/' -- docs/reviews | wc -l` →
  **0**), und keine Fitness-Zeile bindet sie; eine Zusage über sie hätte kein rot gesehenes
  Gegenbeispiel ([`AGENTS.md`](../../../AGENTS.md) §3.6). Benannte Lücke; Trigger 7.

In den übrigen Bäumen aus [ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 1 —
`docs/plan/planning/done/`, `docs/plan/carveouts/done/`, dem eingefrorenen Glied des
Beobachtungs-Registers — gilt der Nachzug in **jeder** Form wie bisher; das ist jene Festlegung
unverändert, nicht diese. Was das für die Begründung des Unterschieds heißt, steht in Festlegung 3.

**2. Die Ausnahmeliste beider Träger bleibt, wie sie ist.** `.harness/baseline/**` und
`docs/plan/adr/**` — kein Baum kommt hinzu, und `docs/reviews/**` ist **kein** Eintrag der Liste.
Ein ganz ausgenommener `docs/reviews/**` oder `done/**` ist verworfen (Tabelle oben, B und C): er
macht tote Links, die niemand reparieren darf. Stumm zu schalten wären sie nur durch eine
**Senkung nach [`AGENTS.md`](../../../AGENTS.md) §3.5** — baum-weit, oder als namentliche
`ignore-refs`-Paare je bewegter Adresse. Der engere Weg existiert:
[ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 3 schneidet zwei Paare, mit
der Aufnahme-**Grenze** *„und keinen weiteren"* — jedes weitere Paar ist eine neue Senkung mit
eigener ADR. Für einen Baum, den jeder Move betrifft, wäre das je Move und Report eine Entscheidung
ohne Ende; darum ist er hier keine Wahl. **Diese Entscheidung ist keine Senkung:** `.d-check.yml`
bleibt unberührt, `codepaths.exempt-paths` steht wie zuvor, und die Zahl der geprüften Dateien
bewegt sich nicht (Tabelle, letzte Spalte).

**3. Die Begründung des Baum-Unterschieds — wo sie trägt und wo nicht.** Zwei Begründungen sind zu
trennen, und nur eine gilt für beide Bäume.

- **Die Tatsache-Begründung ist baum-unabhängig.** Ein Zeitdokument hält eine Messung zu ihrem
  Datum fest ([ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 1,
  Kriterium). Ein **Link** ist ein Zeiger: sein Nachzug nennt denselben Vorgang an seinem neuen Ort,
  der sichtbare Text bleibt. Ein **Span, Operand oder Block** ist ein Beleg des damaligen Orts: sein
  Nachzug nennt einen Ort, an dem der Vorgang nie stattfand. Das gälte in `done/` ebenso wie in
  `docs/reviews/**`.
- **Die Gate-Begründung trägt nur für den reinen Pfad-Span in `done/`.** Dort sieht `codepaths` die
  Form (gemessen, §Kontext). Der Nachzug unterbleibt → `codepaths` färbt `make docs-check` rot
  (`codepath-missing`) → stumm würde es erst durch das Ventil (`ignore-refs`), das der rote Lauf
  erzwingt, und das ist eine Senkung nach §3.5, gegen die
  [ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 1 (*„Die Alternative wäre
  nicht ‚weniger schreiben', sondern ‚weniger prüfen'"*) das Nachziehen gewogen hat; diese
  Kostenabwägung deckt die Position für die Teilmenge. In `docs/reviews/**` gibt es das
  Kostenargument nicht: `codepaths.exempt-paths` nimmt den Baum aus, und nicht zu schreiben fügt
  keine Blindheit hinzu. Für den Operand im Kommando-Span und den Code-Block in `done/` trägt es
  **nicht** (beide bleiben ohne Nachzug grün).
- **Die Gate-Begründung ist kein Maßstab des Baums — und gegen die Alternativen von ADR-0042 steht
  sie an einer Stelle.** [ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md) schließt die
  Gate-Sichtbarkeit als **Kriterium** aus: Alternative A führt als Contra, dass ohne Entscheidung
  *„die **Sichtbarkeit für das Gate** statt die Eigenschaft des Artefakts"* entschiede, was ein
  Nachzug anfasst, und Alternative D (Pro) setzt dagegen *„Das Kriterium ist die **Aussage**, nicht
  die Gate-Sichtbarkeit"*. Die Tatsache-Begründung (erster Punkt) ist dieses Kriterium und trägt für
  beide Bäume. Dass `done/` den reinen Pfad-Span dennoch weiter schreibt, folgt **nicht** aus dem
  Kriterium, sondern aus der Kostenabwägung von Festlegung 1 — und diese deckt die Position nur als
  Preis für die Teilmenge, den jene ADR für ein gate-geprüftes Nachziehen in Kauf nahm, nicht als
  Maßstab je Baum. Die Entscheidung unterscheidet die Bäume damit an einem Punkt nach
  Gate-Sichtbarkeit — der Wirkung, die Alternative A dem Nichtstun vorhält — und löst das nicht auf,
  sondern benennt es im nächsten Punkt. Ein **Kostenargument, kein Prinzip.**
- **Die Restungleichbehandlung ist damit benannt.** Die Operand-Form in `done/` bleibt
  bei [ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 4, Gegenform 2 — der
  Nachzug schreibt sie weiter, obwohl die Tatsache-Begründung dagegen spräche; 42 Spans dieser
  Klasse stehen dort (Kommando in §Kontext, Näherung). Das ist **nicht** die Menge der fünf
  Fundstellen, die Gegenform 2 nennt (dort der Operand im Code-**Block**, Messung 5 von
  [ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md)): hier zählt die Näherung die
  Code-Spans mit Leerzeichen; beide stehen unter derselben Gegenform, und keine ist die andere. Sie
  mitzunehmen verlangte, im Träger den reinen
  Pfad-Span vom Kommando-Span zu trennen — **eine Kontext-Erkennung**, dieselbe, die Festlegung 1 für
  das Zitat verwirft, und die Trennung *„Adresse ja, aussagetragende Adresse nein"*, die
  [ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Alternative E verwirft. Träger der
  Vermeidung bleibt der Schreiber, der eine Form ohne Pfad-Literal wählt. Bekommt ein Träger eine
  Kontext-Erkennung (Trigger 6), ist die Operand-Form in `done/` in **derselben** Entscheidung neu zu
  bewerten.

**4. Abnahme-Kriterium 1 von [ADR-0033](0033-wellen-archivierung-als-unterkommando.md) ist die Regel
über den Suchraum des Hänger-Wächters und keine über den Nachzug.** Es gilt unverändert weiter —
der Wächter liest `docs/reviews/**` vollständig —, und **kein** Wort jener ADR wird hier
überschrieben. Wer es für die Ausnahmeliste des Nachzugs zitiert, zitiert eine Quelle, die diese
Frage nicht regelt; die Quelle des Nachzugs in `docs/reviews/**` ist
[ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 1 in der Fassung dieser
Entscheidung.

**5. Eine von Hand wiederhergestellte Code-Span-Adresse in `docs/reviews/**` bleibt zulässig — bis der
Träger die Regel hält, und danach ist sie überflüssig.** Zeitdokumente sind für den Nachzug **nicht**
von §3.4 geschützt ([ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 1), und
die Wiederherstellung der Code-Span-Form ist für das Gate neutral (`codepaths` nimmt den Baum aus).
Für die **Link-Form** gilt das nicht: ein von Hand zurückgesetzter Link ist ein toter Link und ein
rotes Gate (Politik B). **Die Übergangsregel ist damit dieselbe wie die Dauerregel; der Aufwand
entfällt, sobald der Träger die Form-Regel führt.**

**Was diese Entscheidung nicht tut.**

- **Sie ändert nichts an einer Zustandsaussage neben dem Link.** *„lag in `open/`"* neben einem
  nachgezogenen Link bleibt stehen ([ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md)
  Festlegung 4, erste Gegenform) — der Text ist die Tatsachenaussage und wird nicht angefasst.
- **Sie ändert am Nachzug in `done/` nichts.** Was das für die Operand-Form heißt, sagt Festlegung 3;
  die Gegenform *„der Operand eines Mess-Kommandos"* bleibt dort, was
  [ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 4 benennt.
- **Sie sagt nichts über ein emittiertes Repo.** Die Ausnahmeliste ist dort setzbar Politik; die
  Form-Regel gilt für dieses Repo, und was ein Zielrepo bekommt, entscheidet der Vorgang, der die
  Tool-Ebene entscheidet.
- **Sie schafft keine neue Schreiber-Pflicht** — Kontext, letzter Abschnitt.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — nichts tun, die Restores von Hand fortsetzen | keine Änderung | die Restores sind ein Lauf pro betroffenem Report, ohne Sensor und mit falscher Begründung in der Historie; und ohne Regel überschreibt der nächste Move sie wieder. Der Report-Bestand fällt pro Move an derselben Stelle |
| B — `docs/reviews/**` in die Ausnahmeliste beider Träger | eine Zeile pro Träger; nichts in Reports wird je geschrieben | gemessen **+2** tote Links an einem Move, und jeder weitere Move mit einem Report-Link verlängert die Liste; das Gate färbte rot, und stumm zu schalten wäre es nur durch eine **Senkung nach §3.5** — baum-weit oder als namentliche `ignore-refs`-Paare je Move und Report (Festlegung 2), um zwei Zeichen zu sparen |
| C — `done/**` in die Ausnahmeliste | schützt Ergebnis-Notizen und Slices | gemessen **+15** an einem Move; dort prüft `codepaths` den reinen Pfad-Span und `links` jeden Link, und die Ergebnis-Notiz ist die Stelle, an der Links auf bewegliche Träger stehen (67 geschriebene Zeilen seit §3.11, Kontext) |
| D′ — Kennungs-Umschreibung im selben Akt: der Nachzug macht aus dem Link eine Kennung | löst die Adresse dauerhaft | aus einem Zeiger wird Text: ein **Urteil je Fundstelle** ([ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 4 verwirft es), und es ändert die Aussage, die die Regel hält |
| D″ — Form-Regel **mit** Kontext-Erkennung: auch das Link-Zitat im Code-Span bleibt byte-gleich | schließt die Grenze aus Festlegung 1 und trüge die Tatsache-Begründung bis in den Span | Span-Grenzen und Fence-Zustand in zwei Trägern und zwei Sprachen, dazu die `KERN`-Kopplung — für 9 Vorkommen, von denen keines heute einen beweglichen Träger nennt. Der Umbau wäre größer als die Regel, die er schützt; Trigger 6 hält, wann er sich lohnt |
| **D — gewählt: Form-Regel für `docs/reviews/**` an der Link-Syntax `](`, Nachzug sonst wie bisher** | Prüfbereich unverändert (1964 in allen Politiken); Tatsachen in Reports bleiben stehen; der Nachzug bleibt dort, wo er das Gate hält; keine Senkung; je Träger eine Regel und ein Pfad-Zweig, keine Markdown-Erkennung | eine Erkennung im Träger, die die Link-Syntax von jeder anderen Form trennt — zwei Fassungen (Shell, Go), und die Kopplung an `codepaths.exempt-paths` ist eine Zusage zwischen zwei Dateien; das Link-Zitat im Span wird mitersetzt (Grenze), und die Operand-Form in `done/` bleibt ungleich behandelt (Festlegung 3) |

## Konsequenzen

- **Positiv:** Die Zeile *„Ein Nachzug in `docs/reviews/**` umschreibt eine Tatsache"* verschwindet als
  Klasse für jede Form außer dem Link-Zitat im Span; die Restores von Hand entfallen; die
  Bestands-Beobachtung zur historisch richtigen Adresse ist für diesen Baum an der Quelle
  geschlossen.
- **Positiv:** Kein Gate wird gesenkt, kein `ignore-refs`-Paar entsteht, die Zahl der Paare bleibt.
- **Negativ:** Code-Span-Adressen in `docs/reviews/**` sterben **still**: nach einem Move zeigen sie
  auf den alten Ort, und kein Gate sieht es — das ist der Zustand, den
  [`codepaths.exempt-paths`](../../../.d-check.yml) für den Baum schon heute deklariert, nur ohne
  dass der Nachzug ihn bisher mitgetragen hätte. Trigger 5 hält, wann *„Chronik"* nicht mehr trägt.
- **Negativ:** Ein Link-Zitat innerhalb eines Code-Spans oder Code-Blocks in `docs/reviews/**` wird vom Nachzug
  mitersetzt (Festlegung 1). Der Bestand ist inert; der Zustand ist benannt, nicht behoben.
- **Negativ:** Die Operand-Form in `done/` behält den Nachzug, den die Tatsache-Begründung für
  `docs/reviews/**` verwirft (Festlegung 3).
- **Negativ:** Die Regel hängt an einer Eigenschaft der Config (`exempt-paths` für `docs/reviews/**`).
  Fällt jene, fällt der Grund dieser (Re-Evaluierungs-Trigger 1).
- **Nebenwirkung auf [ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 4.**
  Gegenform 2 (der Operand im Mess-Kommando) ist für `docs/reviews/**` als Nachzug-Fall
  gegenstandslos — der Operand steht nicht hinter `](` und bleibt, die Mess-Aussage bleibt wahr; für
  `done/` gilt sie unverändert. Gegenform 1 (der Zustandssatz neben dem Link) und Gegenform 3 (der
  Abschnitts-Verweis auf einen künftigen Stub) sind Link-Formen und bleiben, wie sie sind.
- **Der Pfad zum Verdikt ist zulässig.** Der Kontext verlinkt ein Zeitdokument in `docs/reviews/`, und
  §3.11 bindet, was wandert. Ein Report wandert nur, wenn die Archivierung ihn einsammelt, und sie
  sammelt nach einer Ziffern-Slice-Nummer im Dateinamen (`Reviews` in `internal/archive/collect.go`);
  das Verdikt trägt keine, und `docs/reviews/` ist eine stehende Ablage. Träfe ein künftiger Schnitt
  es doch, bräche der Hänger-Wächter aus [ADR-0033](0033-wellen-archivierung-als-unterkommando.md)
  Abnahme-Kriterium 1 laut — sein Suchraum schließt `docs/plan/adr/` ein
  (`Suchraum` gegen `AusgenommenePfadeNachzug` in `internal/archive/scan.go`) —, nicht still.
- **Folgepflicht 1 — ein Implementer-Slice** (dieselbe Größe wie ein Nachzug-Schnitt: drei
  Liefer-Punkte). (a) `make slice-mv`: `harness/tools/slice-mv.sh` ersetzt in `docs/reviews/`
  nur die Adresse hinter `](`; der Kommentar an der Ausnahmeliste zitiert
  [ADR-0033](0033-wellen-archivierung-als-unterkommando.md) Abnahme-Kriterium 1 für den falschen
  Zweig und wird auf diese Entscheidung umgestellt; Fall in `test/slice-mv.bats` nach Fitness-Zeile 1
  und 2. (b) `archive-welle`: `internal/archive` (Nachzug) mit demselben Verhalten, Test und
  Mutations-Fall unter `test/mutations/`. (c) `harness/sensors/slice-mv.md` und
  `harness/sensors/archive-welle.md` nennen die Form-Regel in ihrer Grenze. **Der Umbau ist je Träger
  eine Regel mit dem Anker `](` und ein Pfad-Zweig für Dateien unter `docs/reviews/`, keine
  Kontext-Erkennung** — die Zusage aus Festlegung 1 ist damit ohne den Umbau erfüllbar, den D″
  bräuchte (Lektüre beider Träger, nicht gebaut). Ob die Erkennung in den Funktionen der Liste `KERN`
  aus `test/slice-mv.bats` liegt — dann zieht die emittierte Fassung mit oder die Regel liegt
  außerhalb der Liste —, entscheidet der Implementer und sagt es in seinem Bericht; die Zusage gilt
  für dieses Repo.
- **Folgepflicht 2 — der Planner schreibt den Register-Stand nach**, wenn diese Entscheidung
  `Accepted` ist: die Beobachtung *„der Nachzug ersetzt eine historisch richtige Adresse"* nennt für den
  Baum `docs/reviews/` diese Entscheidung als Zielort; das Register gehört nicht dem Architect.
- **Folgepflicht 3 — der Architect zieht beim Accept die Index-Marke nach.** Die Status-Zelle der
  Zeile von [ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md) im ADR-Index bekommt die
  Teil-Revision nach dem Muster der Zeile von
  [ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) (*„Accepted (§Entscheidung
  Festlegung 1 — die Reichweite … für den Baum `docs/reviews/` — revidiert durch
  [ADR-0070](0070-der-verweis-nachzug-schreibt-in-docs-reviews-nur-die-link-form.md) …)"*). **Erst mit dem Accept:** vorher wäre sie eine unwahre Zustandsaussage. Die Datei
  von ADR-0042 bleibt unberührt (§3.4).
- **Folgepflicht 4 — die Kopplung ist baubar und wird gebaut.** Ein bats-Fall im Stil von
  `test/sources-pin.bats` hält die Zeile `exempt-paths: ["docs/reviews/**"]` unter `codepaths:` in
  `.d-check.yml` gegen die Form-Regel (Fitness-Zeile 6). Der Planner schneidet ihn nach dem
  Größen-Maß in den Slice von Folgepflicht 1 oder in einen eigenen.

## Fitness Function (falls maschinell prüfbar)

**Noch nicht gebaut — sie ist die Abnahme von Folgepflicht 1 und 4, und für jede Zusage steht das
Gegenbeispiel, das rot werden muss** ([`AGENTS.md`](../../../AGENTS.md) §3.6):

| Tooling | Zusage | Rot ist zu sehen, wenn |
|---|---|---|
| bats (`test/slice-mv.bats`) · Go-Test in `internal/archive` | in **einer** Datei unter `docs/reviews/` wird der Link auf den bewegten Slice nachgezogen, und **vier** Nicht-Link-Formen bleiben Byte für Byte: der reine Pfad-Span, der Operand in einem Kommando-Span, der Pfad im Code-Block, der Pfad im Fließtext | die Form-Regel entfällt (dann ist die Adresse umgeschrieben — Politik A) **oder** der Link-Nachzug entfällt (dann ist der Link tot — Politik B, gemessen **+2** `target-missing`) **oder** ein Träger nimmt nur den **unmittelbaren Backtick-Kontext** aus: er besteht den reinen Pfad-Span und bricht Operand, Block und Fließtext. Ein Fall mit nur dem reinen Span lässt ihn grün |
| bats · Go-Test | die Grenze ist gemessen, nicht behauptet: Link-Syntax als Zitat in einem Code-Span unter `docs/reviews/` wird mitersetzt (nur die Span-Hälfte der Grenze — für den Code-Block bindet kein Fall, Festlegung 1) | ein Träger bekommt eine Kontext-Erkennung — der Fall fällt, und das ist Re-Evaluierungs-Trigger 6: Festlegung 1 ist dann per Folge-ADR zu ändern, der Fall nicht stillschweigend umzudrehen |
| `make mutate` (Fall je Träger, `test/mutations/`) | beide Mutationen färben je einen Fall rot | der Fall bindet **beide** Hälften einer Datei (Link und Nicht-Link-Form nebeneinander): ein Fall mit nur einer Hälfte bleibt bei der geschwächten Regel grün |
| `make docs-check` | nach dem Move löst jeder nachgezogene Link auf | der Nachzug in `docs/reviews/` unterbleibt (Politik B) |
| bats | in `docs/plan/planning/done/` wird jede Form weiter ersetzt — Link, reiner Pfad-Span und Operand in einer Datei | die Form-Regel wird auf einen zweiten Baum ausgedehnt (dann sind reiner Span und Operand in `done/` stehen geblieben). **Das Gate-Rot dazu hält kein Sensor:** `codepath-missing` für den reinen Pfad-Span in `done/` ist an einer konstruierten Probe gefahren (§Kontext), an keinem realen Move |
| bats (Kopplung, Folgepflicht 4) | die Form-Regel besteht nur, solange `.d-check.yml` `docs/reviews/**` aus `codepaths` ausnimmt | die Zeile unter `codepaths:` entfällt, die Form-Regel bleibt — der Test färbt rot |

**Nicht gebaut, und hier benannt.** Die **Zustandsaussage neben dem Link** bleibt ein Urteil
([ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 4). Die **Referenz-Definition**
hat keinen Bestand und keinen Fall (Festlegung 1, Trigger 7); ebenso die **Block-Hälfte der Grenze** (Festlegung 1, Trigger 6). Die **Gate-Aussage zu `done/`** hat
keinen Sensor (Zeile 5).

## Re-Evaluierungs-Trigger

1. **Wenn `codepaths.exempt-paths` den Baum `docs/reviews/**` nicht mehr ausnimmt** *(an
   [`.d-check.yml`](../../../.d-check.yml) ablesbar)*: dann prüft das Gate die Code-Span-Form dort, und
   Festlegung 1 schützt eine Form, die ein unterbliebener Nachzug rot färbte — die Regel ist zu
   streichen.
2. **Wenn `links` für `docs/reviews/**` eine Ausnahme bekommt** *(an derselben Datei ablesbar)*: dann
   trägt der Nachzug der Link-Form dort nichts mehr, und die Frage, ob er noch schreiben soll, ist neu.
3. **Wenn ein Träger den Nachzug nach Status schneiden kann** ([ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md)
   Re-Evaluierungs-Trigger 3): dann ist die Form-Regel gegen den Status-Schnitt zu halten.
4. **Wenn eine Form auftritt, die eine Tatsache umschreibt, obwohl die Regel sie nicht ersetzen
   dürfte — eine Form, die weder Link noch Code-Span ist, oder ein Link-Nachzug, der die Aussage
   verändert** *(am Bericht eines Laufs ablesbar)*: dann ist die Trennlinie *„Link"* zu grob, die
   Klasse ist größer als gemessen, und die Frage einer Schreiber-Pflicht am Closure-Commit
   (Kontext, letzter Abschnitt) ist neu.
5. **Wenn ein Lauf an einer toten Code-Span-Adresse in `docs/reviews/**` scheitert** — er kann den
   Ort, den sie nennt, nicht deuten *(am Bericht des Laufs ablesbar)*: dann trägt *„Chronik, nicht
   Verweis"* für diese Form nicht, und die Frage, ob der Nachzug sie mit einer Zustandsmarke
   mitführen soll, ist neu.
6. **Wenn ein Move eine Zitat-Zeile mit Link-Syntax im Code-Span oder Code-Block in `docs/reviews/**` umschreibt, die
   einen beweglichen Träger nennt** *(am Diff des Nachzug-Commits ablesbar, `git show -U0`)*, **oder
   wenn ein Träger eine Kontext-Erkennung bekommt**: dann ist die Grenze aus Festlegung 1 nicht mehr
   inert bzw. aufgehoben, und Festlegung 1 samt der Operand-Form in `done/` (Festlegung 3) ist per
   Folge-ADR neu zu bewerten.
7. **Wenn in `docs/reviews/**` eine Referenz-Definition auf einen beweglichen Träger entsteht**
   *(`git grep -nE '^\[[^]]+\]:[[:space:]]*\S*(open|next|in-progress)/' -- docs/reviews | wc -l`
   größer 0)*: dann ist die benannte Lücke aus Festlegung 1 mit einem Fall zu schließen.

## Der Acceptance-Trigger

Diese Entscheidung steht auf `Proposed`. Sie wird `Accepted`, **wenn eine Reviewer-Runde sie gegen
[ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md),
[ADR-0033](0033-wellen-archivierung-als-unterkommando.md) und
[ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) auf Konsistenz geprüft hat und ihr
Report gegen den Gegenstand dieser Entscheidung selbst keinen blockierenden Befund führt.** Hat eine
Runde einen blockierenden Befund gemeldet, ist der Beleg die **nächste** Runde derselben Rolle
([ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 2). Die Accept-Zeile
der §Geschichte nennt den Beleg als Kennung
([ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 1). Der Vollzug
liegt beim Auftraggeber.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-09-26 | **Proposed** | Architect-Lauf zu zwei Fragen des Auftraggebers; das Verdikt trägt die Begründung, das Skript der Kopien-Probe und die Gegenwahl je Frage |
| 2026-09-26 | **Proposed, korrigiert** | Architect-Lauf zum Konsistenz-Review `2026-09-26-review-adr-0070-konsistenz`, Status unverändert: die Gate-Zusage für `done/` gilt für den reinen Pfad-Span und ist als konstruierte Probe gemessen; die Begründung des Baum-Unterschieds ist getrennt (Tatsache baum-unabhängig, Gate nur für den reinen Span, Restungleichbehandlung der Operand-Form benannt); die Form-Regel ist an der Link-Syntax `](` geschnitten, das Link-Zitat im Span ist benannte Grenze mit Trigger, die Referenz-Definition benannte Lücke; Baseline-Einordnung, Index-Folgepflicht, Kopplungs-Test und Trigger ergänzt; Verdikt `2026-09-26-architect-verdikt-korrektur-adr-0070` |
| 2026-09-26 | **Proposed, korrigiert** | Architect-Lauf zur Kurzrunde `2026-09-26-review-kurzrunde-adr-0070`, Status unverändert; Darstellung und Deckung, kein neuer Norm-Inhalt: die Gate-Begründung in Festlegung 3 nennt die volle Kette (Nachzug unterbleibt, `codepaths` rot, stumm erst durch das Ventil) und die Stellen von ADR-0042, gegen die sie steht (Alternative A und D) und die sie deckt (Festlegung 1, *„weniger prüfen"*), samt Abgrenzung der 42 Spans gegen die fünf Fundstellen von Gegenform 2; die Code-Block-Hälfte der Grenze steht als benannte Lücke (Bestand 0) mit Trigger 6, Fitness-Zeile 2 bindet den Span; die Zählung in §Kontext trägt ihren Stand; die Baseline-Einordnung nennt ihre Lesart |
| 2026-09-26 | **Accepted** | Beleg nach [ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 2: die Konsistenz-Runde `2026-09-26-review-adr-0070-konsistenz` (0 HIGH, zwei MEDIUM — die Gate-Zusage für `done/` und die Link-Syntax im Code-Span — nach dem Wortlaut jener ADR blockierend) und, als erneute Runde der prüfenden Rolle nach deren Auflösung, die Kurzrunde `2026-09-26-review-kurzrunde-adr-0070` (0 HIGH, 0 MEDIUM, 3 LOW, 3 INFO, Empfehlung „ja"; geprüft gegen ADR-0042, ADR-0033 und ADR-0030, wie der Acceptance-Trigger es verlangt). Die Differenz der angenommenen zur geprüften Fassung ist Darstellung und Einschränkung, kein neuer Norm-Inhalt, und folgt den drei Wortlaut-Punkten der Kurzrunde: die Gate-Begründung in Festlegung 3 nennt die volle Kette und die Stellen von ADR-0042 (Alternative A und D; Festlegung 1), gegen die sie steht bzw. die sie deckt, samt Abgrenzung der 42 Spans gegen die fünf Fundstellen von Gegenform 2; die Code-Block-Hälfte der Grenze steht als benannte Lücke (Bestand 0, Trigger 6), Fitness-Zeile 2 bindet den Span; die Zählung in §Kontext trägt ihren Stand, und die Baseline-Einordnung nennt die Lesart, an der sie hängt. Die Annahme hat der Auftraggeber am 2026-09-26 erteilt. **Ab hier bindet [`AGENTS.md`](../../../AGENTS.md) §3.4:** Korrekturen entstehen als Folge-ADR mit `Supersedes ADR-0070`. |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0070` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).
