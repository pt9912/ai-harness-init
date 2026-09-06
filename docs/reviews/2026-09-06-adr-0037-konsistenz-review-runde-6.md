# Review: ADR-0037 — Konsistenz-Review, Runde 6

**Review-Art:** Plan-Review gegen Spec/ADR (Modul 10 §Drei Review-Arten) — geprüft wird die
Entscheidung gegen ihre zitierten Quellen, **nicht** DoD-Konformität (Verifier-Rolle, getrennter
Kontext).

**Gegenstand:** [`docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md`](../plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md)
Status `Proposed`, Nacharbeit-Commit `674e0ca` (Diff `674e0ca^..674e0ca` = `ca150b2..674e0ca`,
**eine** Datei: die ADR).

**Skill:** `.harness/skills/reviewer.md` @ 1.7.0 ·
**Modell:** claude-opus-5[1m] · **Datum:** 2026-09-06

**Reviewer:** frischer Kontext. Keines der geprüften Artefakte selbst geschrieben, an keinem etwas
geändert. **Jede Zahl und jedes Kommando dieses Reports ist in diesem Lauf selbst gefahren**;
nichts ist aus der Commit-Message von `674e0ca`, aus dem Slice-Plan oder aus der ADR übernommen.
Der blockierende Befund der Vorrunde ist am Ist-Stand nachgeprüft, nicht am Änderungsbericht.

---

## Eingangs-Kontext (fünf Pflicht-Punkte + Plan)

- **Diff-Range:** `674e0ca` gegen `674e0ca^` = `ca150b2`. **Der Arbeitsbaum ruhte über die ganze
  Strecke.** Gemessen zu Beginn und am Ende: `git log --oneline -1` → `674e0ca` in beiden Fällen,
  `git status --porcelain` bis zum Schreiben dieses Reports leer. Die Feststellung ist eigene
  Messung, nicht die übernommene Zusage des Auftrags.
- **`LH-*`:** [`LH-FA-01`](../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen),
  [`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) (Rang 1, der
  ausgelegte Absatz), [`LH-FA-03`](../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7),
  [`LH-FA-09`](../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren),
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6).
- **Referenzierte aktive ADRs**, Status in diesem Lauf gemessen
  (`for f in 0005 0006 0007 0016 0034; do grep -m1 '^\*\*Status:\*\*' docs/plan/adr/$f-*.md; done`):
  alle fünf `Accepted`. Keine `Superseded`/`Deprecated` unter den zitierten.
- **Hard Rules:** [`AGENTS.md`](../../AGENTS.md) §3, insbesondere §3.4, §3.5, §3.6, §3.8, §3.9,
  §3.10, §3.11. Dazu [`MR-000`](../../harness/conventions.md#mr-000--baseline-aussage),
  [`MR-001`](../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids),
  [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler),
  [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert),
  [`MR-033`](../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist),
  [`MR-036`](../../harness/conventions.md#mr-036--die-change-request-regel-bei-personalunion-steht-jetzt-in-der-adoptierten-baseline)
  und [`MR-051`](../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung).
- **Vorherige Findings am gleichen Modul:**
  [Runde 1](2026-09-06-adr-0037-konsistenz-review.md) (0 HIGH · 5 MEDIUM · 4 LOW · 3 INFO),
  [Runde 2](2026-09-06-adr-0037-konsistenz-review-runde-2.md) (0 HIGH · 2 MEDIUM · 4 LOW · 5 INFO),
  [Runde 3](2026-09-06-adr-0037-konsistenz-review-runde-3.md) (0 HIGH · 3 MEDIUM · 1 LOW · 2 INFO),
  [Runde 4](2026-09-06-adr-0037-konsistenz-review-runde-4.md) (0 HIGH · 1 MEDIUM · 1 LOW · 2 INFO)
  und [Runde 5](2026-09-06-adr-0037-konsistenz-review-runde-5.md) (0 HIGH · 1 MEDIUM · 0 LOW ·
  1 INFO), alle fünf *Konsistenz NICHT BESTÄTIGT*.
- **Slice-Plan:** `slice-190` — das Übergabe-Artefakt, dessen zwei Fragen die ADR beantwortet.
  Seine Verzeichnis-Position steht hier bewusst nicht als Pfad
  ([`AGENTS.md`](../../AGENTS.md) §3.11); die Kommandos unten adressieren ihn über den Glob
  `docs/plan/planning/*/slice-190-*.md`, der in diesem Lauf **genau eine** Datei trifft
  (`ls -1 docs/plan/planning/*/slice-190-*.md | wc -l` → **1**, kein Erwartungswert).

**Gate-Lauf, Docker-only (§3.9).** `make docs-check` vor dem Schreiben dieses Reports →
`d-check: 889 Datei(en) geprüft, 0 Befund(e)`, EXIT 0. `make gates` **nach** dem Schreiben →
EXIT 0; dieser Lauf schließt `docs-check` ein und deckt damit auch diese Datei.

---

## Findings

Jedes Finding folgt dem §Output-Schema des Reviewer-Skills.

### M-1 — Das in der neuen Geschichte-Zeile abgedruckte Zähl-Kommando misst die Klasse nicht: es zählt jede Datei mit, die es zitiert

- `kategorie`: **MEDIUM** (blockiert den Statuswechsel)
- `quelle`: [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 1 — *„trägt im selben Absatz das Kommando, das **genau sie** ausgibt … ein ungefähr
  passendes Kommando danebenzustellen ist der Fehler, nicht die Lücke"* · Maintainability
- `pfad`: `docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md:769` (die in `674e0ca` neu
  angelegte Geschichte-Zeile zu Runde 5)
- `befund`: Die Zeile sagt, die Klasse *Aussage über den Stand eines fremden Artefakts ohne
  Messung an ihm* stehe bei **4** Instanzen, und stellt als Beleg
  `grep -l 'klasse.*fremden Artefakts' docs/reviews/2026-09-06-adr-0037-konsistenz-review*.md | wc -l`
  daneben. Das Muster ist **unverankert** und trifft deshalb nicht nur die `klasse`-Zeile eines
  Findings, sondern **jede Zeile, die das Muster selbst enthält** — also jeden Report, der das
  Kommando abdruckt oder die Klasse beim Namen nennt. Der Zähler misst damit die Klasse *plus
  ihre eigenen Zitierungen*.
- **Rot gesehen, an diesem Report** ([`AGENTS.md`](../../AGENTS.md) §3.6 — kein Befund ohne
  Gegenbeispiel): Mit dieser Datei im Baum liefert das abgedruckte Kommando **5**, während die
  Klasse unverändert bei **4** steht. Die fünfte Datei ist dieser Report, und sein einziges
  Finding dieser Art trägt die Klasse **nicht**.
- **Failure-Szenario:** Die ADR geht auf `Accepted`, die Zeile ist nach
  [`AGENTS.md`](../../AGENTS.md) §3.4 gesperrt. Ein späterer Lauf — der Planner beim Lese-Schritt
  der Closure, ein Reviewer einer Folge-Runde — fährt das abgedruckte Kommando, um zu sehen, ob
  die Klasse weiter gewachsen ist, und liest 5, 6, 7. Er schließt auf Wiederholung und weist der
  Beobachtung einen Ausgang nach einer Zahl zu, die zum Teil aus Zitaten ihrer selbst besteht.
  Das ist der Schaden, den [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  benennt: *„Nicht die falsche Ziffer, sondern was ein Lauf aus ihr macht."*
- **Warum die Datierung den Posten nicht deckt.** Die Zeile ist datiert (*„steht am 2026-09-06 bei
  4 Instanzen"*) und als *kein Erwartungswert* gekennzeichnet, und
  [`MR-051`](../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
  Setzung 2 macht einen zitierten Zähler zur datierten Messung. Das deckt **Drift des
  Gegenstands** — die Zahl wandert, weil die Klasse wächst. Hier wandert sie, weil das Instrument
  sein eigenes Umfeld mitzählt; der Gegenstand bewegt sich nicht. Eine datierte Messung
  entschuldigt, dass eine Zahl altert, nicht, dass ein Kommando etwas anderes zählt als der Satz
  daneben behauptet.
- **Was der Befund nicht bestreitet:** die Zahl **4** selbst — sie ist am Stand von `674e0ca`
  richtig, wie die verankerte Messung unten zeigt —, und nicht die Aussage, dass die Klasse ihre
  Schwelle überschritten hat. Bestritten ist allein, dass das abgedruckte Kommando sie liefert.
- `verifizierbar`: **nein** — kein Gate hält ein abgedrucktes Kommando gegen seinen abgedruckten
  Wert. Reproduzierbar:
  ```sh
  G='docs/reviews/2026-09-06-adr-0037-konsistenz-review*.md'
  grep -l 'klasse.*fremden Artefakts' $G | wc -l    # 5 — das abgedruckte Instrument
  grep -lE '^- .klasse.:.*fremden' $G | wc -l       # 4 — nur echte klasse-Zeilen
  comm -13 <(grep -lE '^- .klasse.:.*fremden' $G | sort) \
           <(grep -l 'klasse.*fremden Artefakts' $G | sort)
  # docs/reviews/2026-09-06-adr-0037-konsistenz-review-runde-6.md  — diese Datei
  ```
  Und die isolierte Gegenprobe, dass eine reine **Zitat**-Zeile genügt:
  ```sh
  printf "grep -l 'klasse.*fremden Artefakts' irgendwo.md\n" > /tmp/zit.md
  grep -c  'klasse.*fremden Artefakts' /tmp/zit.md   # 1 — das abgedruckte Muster trifft
  grep -cE '^- .klasse.:.*fremden'     /tmp/zit.md   # 0 — das verankerte nicht
  ```
  **Keine Erwartungswerte.**
- `klasse`: *Zähl-Instrument trifft seine eigene Zitierung mit*

### INFO-1 — Eine fünfte Kollisionsstelle liegt in §8 des Plans, außerhalb der vier gemessenen — und sie ist von der Nicht-Schließungs-Klausel gedeckt

- `kategorie`: **INFO** (blockiert **nicht** — die Begründung steht unten und im Verdikt)
- `quelle`: Maintainability · [`AGENTS.md`](../../AGENTS.md) §3.10 (die ADR ist das
  Übergabe-Artefakt, aus dem der Planner schöpft)
- `pfad`: `docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md:647–650` (die Aufzählung
  der vier Stellen samt Nicht-Schließungs-Klausel), gegen §8 des Plans
- `befund`: Die Datei benennt **vier** Stellen, an denen Festlegung 4 im Plan aufschlägt —
  **DoD (1)**, **DoD (3)**, §1 und die `structureGitkeeps`-Zeile in §3. Eine **fünfte** liegt in
  §8, im Block *Vorgelagert — offene Beobachtungen sichten*: *„Der Übertritt ist damit erreicht,
  und der Ausgang ist geteilt: **die zwei unstrittigen Orte löst DoD (1)**; der Register-Ort ist
  ein Norm-Konflikt und bleibt offen."* Das ist dieselbe Prämisse wie DoD (1) und die §3-Zeile —
  DoD (1) legt **zwei** Orte an —, und Festlegung 4 trägt nur einen davon. Die Stelle ist
  unbedingt betroffen, nicht bedingt wie §4 und §5.
- **Warum ein zeilenweises `grep` sie nicht findet:** Sie steht über einen **Zeilenumbruch**
  verteilt (*„die zwei"* / *„unstrittigen Orte löst DoD (1)"*) und enthält das Literal
  `carveouts/done` **nicht**. Ein Muster-Lauf über den Plan trifft sie also nicht; sie ist nur
  durch Lesen und ein Achsen-Urteil erreichbar.
- **Warum das kein blockierender Befund ist — und warum das nicht Nachsicht ist:** Die Datei
  **schließt die Menge ausdrücklich nicht**: *„Die Menge ist damit nicht geschlossen: gemessen
  sind diese vier, nicht die Vollständigkeit über den ganzen Plan — die misst der Planner an
  ihm."* Damit wird **kein Satz der ADR durch diese Stelle falsch**. Ein Planner, der die Klausel
  befolgt, misst den Plan und findet §8; ein Planner, der sie ignoriert, handelt gegen eine
  ausdrückliche Anweisung der Datei. Das ist die Umkehrung des Runde-5-Falls, wo die Datei eine
  Aussage traf, die **nicht zutraf** — dort führte Befolgung in den Fehler, hier aus ihm heraus.
- **Der Plan selbst führt diese Stelle als vorläufig.** Zwei Sätze weiter steht dort *„Den Stand
  setzt der Lese-Schritt der Closure, nicht dieser Plan"*. Der §8-Ausgang ist damit Planner-Arbeit
  am Closure-Punkt, und genau dorthin verweisen Folgepflicht 3 und Folgepflicht 4.
- **Der Posten steht trotzdem hier**, weil er dem Planner eine Suche erspart und weil er der
  empirische Beleg dafür ist, dass die Nicht-Schließungs-Klausel wirkt: Ein Leser, der ihrer
  Anweisung folgt, findet die Stelle.
- `verifizierbar`: **nein** — kein Gate hält einen ADR-Satz gegen den Inhalt einer Plandatei; die
  Datei sagt das inzwischen selbst (§Fitness Function, dritte Lücke). Reproduzierbar:
  ```sh
  P='docs/plan/planning/*/slice-190-*.md'
  sed -n '/^## 8\./,$p' $P | tr '\n' ' ' | tr -s ' ' \
    | grep -c 'die zwei unstrittigen Orte löst DoD (1)'   # 1 — entfaltet gefunden
  sed -n '/^## 8\./,$p' $P | grep -c 'die zwei unstrittigen Orte löst DoD (1)'  # 0 — zeilenweise nicht
  sed -n '/^## 8\./,$p' $P | wc -l                        # 79 — Gegenprobe: Ausschnitt nicht leer
  ```
  **Keine Erwartungswerte**; der Glob statt der Pfad-Adresse nach
  [`AGENTS.md`](../../AGENTS.md) §3.11.
- `klasse`: *Nicht geschlossene Aufzählung, eine weitere Instanz gefunden*

---

## Die Zusatzfrage: Trägt die Nicht-Schließung, oder ist sie ein Freibrief?

**Sie trägt.** Das ist ein Urteil, und es steht auf vier Prüfungen statt auf einem Eindruck.

**1. Sie hat einen Adressaten und eine Aufgabe, nicht nur einen Vorbehalt.** Die Klausel nennt
*was* ungemessen blieb (*„die Vollständigkeit über den ganzen Plan"*), *wer* misst (*„der
Planner"*) und *woran* (*„an ihm"*). Eine Immunisierung sagte nur *„nicht abschließend"* und
ließe offen, wer den Rest trägt. Diese hier verlagert Arbeit, statt sie verschwinden zu lassen.

**2. Sie kostet den Schreiber etwas.** Mit ihr kann Folgepflicht 4 den Planner nicht mehr auf eine
Liste von vier Korrekturen schicken; sie schickt ihn auf eine Messung über den ganzen Plan. Das
ist die teurere Übergabe, nicht die billigere — ein Freibrief geht in die andere Richtung.

**3. Die Menge, über die sie spricht, ist ein Urteils- und kein Muster-Gegenstand — und deshalb
wäre ihre Schließung der Fehler, nicht ihre Offenheit.** Das ist gemessen: Ein `grep` auf das
Literal `carveouts/done` findet im Plan **vier** Stellen, und alle vier sind in der ADR bereits
richtig eingeordnet (§1-Tabelle, DoD (1), der §3-Change-Request-Satz als unberührt, §6-Risiko 3
als vom Plan selbst offengehalten). Die fünfte — INFO-1 — trägt das Literal **nicht** und steht
über einen Zeilenumbruch verteilt. Wer über einer solchen Menge eine geschlossene Zahl ausgibt,
gibt ein Muster als Kriterium aus, das keines ist — genau das, was
[`AGENTS.md`](../../AGENTS.md) §3.6 und §3.7 verbieten.

```sh
P='docs/plan/planning/*/slice-190-*.md'
grep -c 'carveouts/done' $P                                      # 4 — Muster-Fundmenge
awk '/^## /{sec=$0} /carveouts\/done/{print sec}' $P | sort -u    # §1, §2, §3, §6
```

**Keine Erwartungswerte.**

**4. Die Konstruktion ist die des höchstrangigen Norm-Artefakts dieses Repos, für dasselbe
Problem.** [`AGENTS.md`](../../AGENTS.md) §3.7 druckt Zählungen ab und schreibt daneben: *„Zwei
Klassen sind gezählt, zwei nicht … sie hier zu beziffern hieße, ein Muster als Kriterium
auszugeben, das keines ist (§3.6). Die Zahlen oben sind darum kein Gesamtmaß des Bestands, sondern
der Ausschnitt, den ein `grep` trifft."* Die ADR tut wörtlich dasselbe. Eine Form, die die
Hard Rules für sich selbst wählen, kann in einer ADR kein Freibrief sein.

```sh
tr '\n' ' ' < AGENTS.md | tr -s ' ' \
  | grep -c 'kein Gesamtmaß des Bestands, sondern der Ausschnitt, den ein `grep` trifft'   # 1
```

**Keine Erwartungswerte** — der Satz bricht in `AGENTS.md` über zwei Zeilen um, ein zeilenweises
`grep` liefert hier **0**. Dieselbe Falle wie in INFO-1; sie ist mir beim Nachfahren meines
eigenen Kommandos zugestoßen und steht darum hier statt stillschweigend korrigiert.

**Die Gegenprobe, die den Freibrief-Verdacht bestätigt hätte:** Wäre die Vollständigkeit **billig**
messbar — ein Kommando, das alle Kollisionsstellen ausgibt —, dann wäre die Klausel Vermeidung.
Sie ist es nicht: Das billige Kommando (Punkt 3) findet vier Stellen, die alle schon eingeordnet
sind, und verfehlt gerade die, die INFO-1 meldet. Die Klausel verdeckt keine erreichbare Messung;
sie beschreibt eine reale Grenze.

**Und der Kontrast zu M-1 ist der Punkt.** Beide Posten handeln von einer Zahl über fremden Text.
Bei den vier Stellen ist die Menge nicht mechanisch bestimmbar, und die Datei **sagt das** — das
trägt. Beim Klassen-Zähler ist sie mechanisch bestimmbar, die Datei druckt ein Kommando ab, und
das Kommando trifft daneben — das trägt nicht. Der Unterschied liegt nicht in der Ehrlichkeit der
Absicht, sondern darin, ob eine Messung möglich war.

---

## Negativbefunde (geprüft, ohne Befund)

**Alle 52 abgedruckten Kommandos der ADR in diesem Lauf nachgefahren — jedes liefert den
abgedruckten Wert.** Die Datei trägt **19** ` ```sh `-Zäune mit zusammen **48** Kommandos, dazu
**vier** wertetragende Inline-Kommandos und eine Inline-Ablesestelle ohne Wert. Die zwei Zahlen
sind gemessen, nicht gezählt:

```sh
A=docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md
grep -cE '^[[:space:]]*```sh$' "$A"                                                       # 19
awk '/^[[:space:]]*```sh$/{inb=1;cont=0;next} /^[[:space:]]*```$/{inb=0;next}
     inb{ l=$0; sub(/^[[:space:]]+/,"",l); if(l==""||l ~ /^#/) next;
          if(cont==0) n++; cont = (l ~ /\\$/) }
     END{print n}' "$A"                                                                   # 48
```

**Keine Erwartungswerte.** Gefahren wurde blockweise über eine `awk`-Extraktion der Zäune, danach
`bash` unter **GNU grep 3.11** (`PATH=/usr/bin:/bin`), nicht über den `ugrep`-Umweg der
interaktiven Sitzung — der Defekt, den mein Vorrunden-Report an sich selbst fand. Ergebnisse in
der Reihenfolge der Datei: `1`·`1` · `1`·`1` · `3`·`2` · `3`·`2` · die vierzeilige
Klammer-Ausgabe · die einzeilige Lifecycle-Klammer · `4`·`3` · `| 0.8.0 | 2026-07-21`·die
Datums-Zeile `2026-09-03` · `0` · `1`·`0` · `1`·`1`·`1` · `0`·`3` · `1`·`1` · `1`·`0` · die
einzeilige `.gitkeep`-Satz-Ausgabe · `2`·`1`· die zweizeilige Link-Ausgabe der zwei
Index-Vorlagen · `1`·`1` · `0`·`1`·`1`·`1`·`1` · **`0`·`1`·`1`·`1`·`1`·`1`·`1`·`1`·`1`·`1` (der auf
zehn Kommandos gewachsene `slice-190`-Block)**. Inline: **2** Zeilen `git log --follow` · **2**
(Register-Zähler) · **6** (Risiken ohne Ausgang) · **4** (Klassen-Instanzen — der **Wert** stimmt
am Stand von `674e0ca`; zur Instrument-Frage siehe M-1). **Keine Abweichung.**

**Die übrige Selbstmeldung des Architect ist unabhängig bestätigt**, Posten für Posten:

```sh
A=docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md
grep -c 'Dazu sagt §3 nichts' "$A"                                          # 0 — alte Form weg
grep -c 'Dazu sagt \*\*jener Satz\*\* nichts' "$A"                          # 1 — satz-skopiert
grep -c 'slice-190-bootstrap' "$A"                                          # 0 — kein Pfad-Link
grep -cE 'grep -[a-zA-Z]*c[a-zA-Z]*o|grep -[a-zA-Z]*o[a-zA-Z]*c' "$A"       # 0 — kein -c mit -o
grep -noE 'docs/plan/planning/(open|next|in-progress|done)/' "$A"
# 324:docs/plan/planning/done/   — Baseline-Zitat, Verzeichnis
# 333:docs/plan/planning/done/   — abgedrucktes Kommando, Verzeichnis
```

**Keine Erwartungswerte.** Beide `planning/`-Treffer adressieren ein **Verzeichnis**, das
[`AGENTS.md`](../../AGENTS.md) §3.11 ausdrücklich für ortsfest erklärt — **§3.11 gewahrt**.

**Der blockierende Befund der Vorrunde, am Ist-Stand nachgeprüft:**

- **M-1 (Runde 5) behoben, auf der belegbaren Reichweite.** Der Schlusssatz ist von der
  **Sektion** auf den **zitierten Satz** zurückgenommen. Der zitierte Satz — *„`docs/plan/carveouts/done`
  ist ein Carveout-Ordner und damit gedeckt"* — steht im Absatz *„Die Change-Request-Frage steht
  vor dem Code"* und mündet in *„ist hier nicht entschieden"*; er beantwortet die
  Change-Request-Frage und bleibt richtig. Zur Anlege-Frage sagt er tatsächlich nichts.
- **Die drei Folgestellen tragen, je einzeln nachgemessen.** Der Kopfsatz zählt jetzt *„drei
  weitere Stellen"* und ordnet sie **eine unberührt / zwei betroffen** — das geht auf: §3-Satz
  (unberührt), §1 (betroffen), §3-Tabelle (betroffen). Der neue Absatz zur dritten Stelle stimmt
  in allen drei Behauptungen: sie steht in derselben Sektion wie die erste (§3), auf derselben
  Achse wie die zweite (Anlege), und sie nennt *dieselbe Funktion und dieselbe Zahl* wie DoD (1).
  Die Aufzählung nennt **vier** betroffene Stellen, und die Geschichte-Zeile löst die scheinbare
  Ordinal-Kollision selbst auf (*„als dritte Stelle daneben und in der Aufzählung der
  Kollisionsstellen als vierte"*).
- **Die zwei neuen Beleg-Kommandos reproduzieren** (`die zwei fehlenden Verzeichnisse` → **1**,
  `structureGitkeeps` → **1**); der `slice-190`-Block ist damit auf zehn Kommandos gewachsen.

**INFO-1 der Vorrunde behoben — und die Formulierung deckt die Lücke wirklich.** §Fitness Function
sagt jetzt *„drei Stück"* und führt als dritte: *„keine Aussage dieser Datei über den Inhalt von
`slice-190` ist gegen jenen Inhalt gedeckt"*. Zwei Prüfungen dazu, beide bestanden:

- **Die Aussage stimmt.** Die Modul-Liste des Doku-Gates trägt sieben Module, und **keines** hält
  einen ADR-Satz gegen Plan-Inhalt. Besonders geprüft habe ich das namensverdächtige `planning`:
  sein Block in [`.d-check.yml`](../../.d-check.yml) führt genau `roadmap`, `heading` und
  `marker` — es hält den Ruhe-Marker der Roadmap gegen `in-progress/` und sonst nichts. Und die
  Plandatei ist in der ADR über einen Glob genannt, ist also nicht einmal Ziel einer
  Referenz-Prüfung.

  ```sh
  grep -n '^modules:' .d-check.yml
  # 29:modules: [links, anchors, ids, matrix, codepaths, spans, planning]
  sed -n '/^planning:/,/^#/p' .d-check.yml | grep -cE '^  (roadmap|heading|marker):'   # 3
  ```

  **Keine Erwartungswerte.** Die ADR nennt hier **das Kommando** statt einer abgeschriebenen
  Modul-Liste — die driftfeste Form, und der Grund, warum die Aussage den Zuwachs um `planning`
  unbeschadet überstanden hat.
- **Die Reichweite stimmt.** Der Hauptsatz quantifiziert über *jede* Aussage der Datei zu
  `slice-190`, nicht nur über Festlegung 4; der Zusatz *„Unter diese dritte Lücke fällt jede
  Aussage der Festlegung 4 über den Plan"* hebt hervor, statt einzuschränken. Damit fallen alle
  vier Instanzen der Klasse aus den Runden 1–5 darunter — und auch INFO-1 dieser Runde.

**Sonstiges, geprüft ohne Befund:**

- **Gegen die Entscheidung selbst steht in sechs Läufen kein Befund.** Die zwei
  Kern-Argumentationen sind unverändert und halten dem Volltext stand:
  [ADR-0007](../plan/adr/0007-bootstrap-phasen.md) beantwortet *wie* eine emittierte Datei beim
  Re-Lauf behandelt wird, nicht *ob* sie entsteht;
  [ADR-0034](../plan/adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
  Festlegung 1 schreibt die `README.md` als Bestandteil der Ablage vor. Der emittierte
  Selbstwiderspruch ist in diesem Lauf erneut gemessen (`3` Anweisungssätze, `2` davon namentlich,
  `3` Go-Fundstellen, keine schreibend).
- **Die Rang-1-Frage, die ich eigens angegriffen habe, löst sich sauber auf — und das ist der
  Punkt, an dem ein HIGH gestanden hätte.** Ich habe geprüft, ob Festlegung 4 den Rang-1-Satz
  *verengt*, indem sie einen Ort ausschließt, den die Klammer *„ADR-/Carveout-/Reviews-Ordner"*
  nennt. Sie tut es nicht, weil die Datei den Rang-1-Satz durchgängig als **Träger**-Regel liest
  (welches `.gitkeep` ein leeres Struktur-Verzeichnis hält) und nicht als **Aufnahme**-Regel
  (welche Orte entstehen). Diese Lesart steht an drei Stellen konsistent: Festlegung 2
  (*„ist nach diesem Rang-1-Satz keines"*), Konsequenz 2 (*„Was sie nicht beantworten, ist der
  Träger"*) und im §3-Absatz. Damit greifen Rang 1 und Festlegung 1 auf verschiedene Fragen, und
  *„Keine Anforderung wird geändert"* bleibt wahr. Die vier Klassen der Rang-1-Klammer sind vom
  Emitter zudem heute schon vollständig bedient — `docs/plan/adr`, `docs/plan/carveouts`,
  `docs/reviews` und drei Lifecycle-Ordner.

  ```sh
  sed -n '/^func structureGitkeeps/,/^}/p' internal/emit/templates.go \
    | grep -c '^[[:space:]]*"docs/'   # 6
  ```

  **Keine Erwartungswerte.**
- **§4 und §5 des Plans bleiben zu Recht außerhalb der Kollisionsliste.** Beide wiederholen die
  Messzahl aus DoD (3) (`eine andere Zahl als **3**` → **1**; `**6** vorher und` → **1**) und
  hängen damit an der Frage, die die ADR ausdrücklich offen lässt — auf dem Marker-Weg aus §6 kann
  die Zahl **3** halten. Sie sind bedingt; INFO-1 dieser Runde ist es nicht. Die Einordnung deckt
  sich mit der der Vorrunde.
- **[ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 3 (a) — die
  Vorbedingung des Accept-Übergangs ist erfüllt.** Jeder Baseline-Beleg der Datei nennt Tag
  (`v6.0.0`), Regelwerks- bzw. Vorlagen-Datei, Abschnitt und Zitat; kein Beleg führt einen
  `.harness/baseline/<tag>/`-Pfad als alleinigen Locator. Das Handbuch-Zitat weicht von der Quelle
  nur um die Auszeichnung `**selbst**` ab und ist damit *verbatim* im Sinn von Festlegung 2
  (*„der Wortlaut ohne Auszeichnung, Whitespace normalisiert"*) — gegen den entfalteten Quelltext
  geprüft, nicht zeilenweise.
- **[`AGENTS.md`](../../AGENTS.md) §3.8 — Commit-Zuschnitt korrekt.**
  `git show --pretty=format: --name-only 674e0ca` gibt **eine** Datei, die ADR; die Message trägt
  das Rollen-Präfix. Der ADR-Index braucht keinen Nachzug — Titel, Status und die **sechzehn**
  Bezugs-IDs stimmen in Reihenfolge und Bestand mit dem `Bezug`-Kopf überein (gegen
  `docs/plan/adr/README.md:44` gehalten).
- **§3.4 nicht verletzt.** Die Datei steht auf `Proposed`; Überarbeitungen sind in diesem Fenster
  zulässig, und [ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 3 verlangt
  die Beleg-Korrektur ausdrücklich hier. Die Zitate der alten Fassungen in den Geschichte-Zeilen
  sind als solche gekennzeichnet.
- **§3.5 — keine Gate-Lockerung**, kein Schwellwert, kein `ignore`-Eintrag, keine
  Modul-Abschaltung berührt; die Datei trägt **null** HTML-Kommentare (`grep -c '<!--'` → **0**),
  die `d-check:ignore`-Treffer stehen sämtlich in Zitaten und Kommandos.
- **§3.10 gewahrt.** Der Commit berührt kein Planner-Artefakt; die Datei schlägt für keine
  Kollisionsstelle einen Wortlaut vor, setzt keinen Risiko-Ausgang und keine DoD-Fassung.
- **[`MR-033`](../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
  gewahrt** — jede Baseline-Aussage nennt den Tag `v6.0.0`.
  [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  ist an **einer** Stelle verletzt (M-1); an allen übrigen steht jede Messwert-Zahl neben dem
  Kommando, das genau sie liefert, und ist als kein Erwartungswert gekennzeichnet. Der
  Register-Zähler ist datiert und trägt sein Ableitungs-Kommando; nachgefahren → **2**.
- **[`MR-000`](../../harness/conventions.md#mr-000--baseline-aussage) — kein Adaptions-Eintrag
  fällig.** Keine der vier Festlegungen weicht von einer Baseline-Regel ab; die Entscheidung
  stellt Baseline-Konformität her.
- **[`MR-001`](../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
  gewahrt.** `make docs-check` ist mit `ids: link-policy: always` grün (889 Dateien, 0 Befunde).
- **[`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) — kein
  halluziniertes Gate.** `TestTemplates_EmittierterBestandVollstaendig` existiert, `make full-smoke`
  existiert und ist als Nicht-Gate ausgewiesen; die drei nicht gebauten Deckungen sind benannt
  statt behauptet.
- **Ziel-Form vollständig.** Gegen
  [`NNNN-titel.template.md`](../../.harness/baseline/v6.0.0/templates/docs/plan/adr/NNNN-titel.template.md)
  geprüft: Status · Datum · Autor · Bezug · Schärft · Regeln · Kontext · Entscheidung ·
  Verglichene Alternativen (fünf Optionen, *nichts tun* dabei) · Konsequenzen · Fitness Function ·
  Re-Evaluierungs-Trigger (sechs, alle mit Ablesestelle) · Geschichte · Immutabilitäts-Schluss.
- **Docker-only (§3.9).** Kein Host-Paketmanager, keine Host-Toolchain in diesem Lauf; alles über
  `make`, `git`, `grep`, `sed`, `awk`, `tr`, `comm`, `ls`, `find`, `bash`.
- **Nicht geprüft (fremde Rolle):** DoD-Abhakung und Plan-vs-Code-Konformität — Verifikation,
  getrennter Kontext, anderes Prüf-Artefakt.

---

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 1 |
| LOW | 0 |
| INFO | 1 |

**Finding-Klassen dieses Laufs:** *Zähl-Instrument trifft seine eigene Zitierung mit* ·
*Nicht geschlossene Aufzählung, eine weitere Instanz gefunden*

**Die Klasse der Runden 1–5 findet in dieser Runde keine Instanz, und sie steht weiter bei 4.**
Sie trug Runde-1-M-4, Runde-2-L-2, Runde-4-M-1 und Runde-5-M-1. Weder M-1 noch INFO-1 dieses Laufs
gehören dazu: Die Datei hat in beiden Fällen gemessen — bei INFO-1 hat sie ihre Grenze zusätzlich
deklariert, bei M-1 misst das Kommando nur nicht, was der Satz behauptet. Verankert gezählt:

```sh
grep -lE '^- .klasse.:.*fremden' \
  docs/reviews/2026-09-06-adr-0037-konsistenz-review*.md | wc -l   # 4
```

**Kein Erwartungswert.** Die Zuordnung der Klasse zu einer `BEO-ALL/<slug>` fällt bei der
Slice-Closure, nicht hier ([`AGENTS.md`](../../AGENTS.md) §3.10) — sie steht seit Runde 4 über
ihrer Schwelle und braucht dort einen Ausgang.

**Was sich gegenüber Runde 5 verschoben hat, und es ist ein Bruch in der Reihe.** Die inhaltliche
Kette ist zu Ende: Die Reichweiten-Angabe der Kollision war in Runde 3 zu eng, in Runde 4 zu eng,
in Runde 5 zu weit — und ist jetzt eine **deklarierte** Größe, der die Pendelbewegung keine
Angriffsfläche mehr bietet. Der verbleibende MEDIUM liegt nicht mehr in der Sache, sondern in der
**Erzählung** der Nacharbeit: in einem Kommando, das die neue Geschichte-Zeile zum Beleg abdruckt.
Er ist eine Zeile groß und hat keinen Bezug zu den vier Festlegungen.

---

## Verdikt

**Konsistenz NICHT BESTÄTIGT — ein blockierendes MEDIUM, kein HIGH.**

**Der Baseline-Trigger kann mit diesem Verdikt nicht feuern.** *„ADR-Review-Runde abgeschlossen →
bindend"* (Baseline `v6.0.0`, `grundlagen-bootstrap.md` §Vier Trigger-Klassen, Zeile der
Acceptance-Trigger-Klasse,
`grep -c 'ADR-Review-Runde abgeschlossen → bindend' .harness/baseline/v6.0.0/regelwerk/grundlagen-bootstrap.md`
→ **1**, kein Erwartungswert) setzt eine abgeschlossene Runde voraus; diese Runde schließt mit
einem blockierenden Befund. **Das sage ich ungern**, weil gegen die Entscheidung in sechs Läufen
kein einziger Befund steht und die inhaltliche Nacharbeit abgeschlossen ist — aber ein Verdikt
nach Runden-Müdigkeit statt nach Quelle wäre genau die Herabstufung, die
[Modul 8](../../.harness/baseline/v6.0.0/regelwerk/modul-08-agentenrollen.md) §Konflikt-Pfad als
den vierten, falschen Pfad benennt.

**Die ausdrücklich gestellte Frage, ausdrücklich beantwortet: die Nicht-Schließung ist eine
ehrliche Grenze, kein Freibrief.** Vier Prüfungen tragen das (§Die Zusatzfrage): Sie nennt
Adressat, Aufgabe und Messgegenstand; sie verteuert die Übergabe statt sie zu entlasten; die
Menge, über die sie spricht, ist gemessen ein Urteils- und kein Muster-Gegenstand — ein `grep`
findet vier Stellen, die alle schon eingeordnet sind, und verfehlt die fünfte; und die
Konstruktion ist die, die [`AGENTS.md`](../../AGENTS.md) §3.7 für dasselbe Problem an sich selbst
anwendet. **Der Gegentest ist gefahren und ausgegangen:** Wäre die Vollständigkeit billig messbar,
wäre die Klausel Vermeidung — sie ist es nicht. **Der Kontrast zu M-1 schärft die Antwort:**
Dieselbe Datei darf eine Menge offen lassen, die sie nicht messen kann, und muss eine Zahl
belegen, die sie messen kann. Beides zugleich ist kein Widerspruch, sondern die Regel.

**INFO-1 reist als benannte Grenze mit, und er liegt anders als der Runde-5-Fall.** Dort war es
**Wahrheit**: Der Satz *„Dazu sagt §3 nichts"* traf nicht zu, und ein Planner, der ihm folgte,
ließ die Zeile stehen, aus der der Implementer liest. Hier ist es **Vollständigkeit**: Kein Satz
der ADR wird durch die §8-Stelle falsch, weil die Datei ihre Aufzählung selbst nicht schließt und
die Messung ausdrücklich dem Planner zuweist. Befolgung führt in Runde 5 in den Fehler und hier
aus ihm heraus. Hinzu kommt, dass der Plan die §8-Stelle selbst als vorläufig führt (*„Den Stand
setzt der Lese-Schritt der Closure, nicht dieser Plan"*).

**Liegt der neue blockierende Befund wieder in der letzten Nacharbeit? Ja — und diesmal sagt das
etwas anderes als die vier Male davor.** Das beanstandete Kommando ist mit `674e0ca` entstanden,
in der Geschichte-Zeile, die die Runde-5-Korrektur protokolliert. Die vier vorigen Befunde lagen
im **Argument** der Nacharbeit: die Regel zu eng, die Reichweite zu eng, die Reichweite zu weit.
Dieser liegt im **Protokoll** der Nacharbeit — in einem Beleg-Kommando einer Zeile, die nichts
festlegt. Das ist kein Zeichen, dass der Text nicht trägt: die vier Festlegungen, die
Auswertungs-Regel, die vier Kollisionsstellen und die drei nicht gebauten Deckungen sind in diesem
Lauf sämtlich nachgemessen und tragen. Es ist auch kein Zeichen, dass die Schleife das Problem
ist: Sie hat in fünf Runden zwölf blockierende Befunde geschlossen, von denen keiner die
Entscheidung betraf. Es ist ein Zeichen für etwas Drittes — **jede Runde erzeugt Protokoll, und
Protokoll ist prüfpflichtiger Text.** Wer eine Korrektur mit einer Messung belegt, hat eine neue
Messung zu verantworten. Das ist der Preis der Nachvollziehbarkeit und keine Fehlfunktion; er
sinkt hier auf eine Zeile und ist mit der nächsten Nacharbeit bezahlt.

**Was der Statuswechsel jetzt braucht.** Ein verankertes Zähl-Muster in der Geschichte-Zeile, das
die `klasse`-Zeile eines Findings trifft und nicht seine Zitierung — oder der ausdrückliche
Hinweis, dass der Zähler zitierende Reports mitzählt. Beides ist eine Zeile, und beides ist nach
`Accepted` durch [`AGENTS.md`](../../AGENTS.md) §3.4 gesperrt; der Preis stiege dann von einer
Zeile auf eine Folge-ADR mit `Supersedes`. Genau dieses Kosten-Argument bindet
[ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 3 an das
`Proposed`-Fenster. **`slice-190` ist nicht anzufassen**, und keine Festlegung ist zu ändern.
**Über den `Accepted`-Übergang entscheidet dieser Report nicht** — das ist Architect-Arbeit
([`AGENTS.md`](../../AGENTS.md) §3.8); er stellt fest, dass ihm heute ein Posten entgegensteht und
nach dessen Korrektur keiner mehr.

**Zur Baumlage.** `git log --oneline -1` zu Beginn und am Ende dieses Laufs → beide Male
`674e0ca`; `git status --porcelain` bis zum Schreiben dieses Reports leer. **Der Prüfgegenstand
war über die Strecke stabil** — eigene Messung, nicht die übernommene Zusage des Auftrags.

**Übergabe.** Die Findings gehen an den **Architect** — er hält die ADR
([`AGENTS.md`](../../AGENTS.md) §3.8), und dieser Report hat kein Artefakt außer sich selbst
angefasst. **Keiner der zwei Posten trägt eine eigene Kante an den Planner:** Die Folgerung aus
der Kollision für Schnitt und Abnahmekriterien von `slice-190` ist als Folgepflicht 4 verdrahtet
und bleibt Planner-Arbeit ([`AGENTS.md`](../../AGENTS.md) §3.10); dieser Report schreibt sie nicht
und schlägt sie nicht vor.

Dieser Report ist ein **Lauf-Beleg** und ersetzt keine Verifikation — DoD-/Spec-Konformität prüft
der Verifier separat (Modul 11, anderes Prüf-Artefakt, anderer Eingabe-Kontext).
