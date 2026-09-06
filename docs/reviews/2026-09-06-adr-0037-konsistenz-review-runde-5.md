# Review: ADR-0037 — Konsistenz-Review, Runde 5

**Review-Art:** Plan-Review gegen Spec/ADR (Modul 10 §Drei Review-Arten) — geprüft wird die
Entscheidung gegen ihre zitierten Quellen, **nicht** DoD-Konformität (Verifier-Rolle, getrennter
Kontext).

**Gegenstand:** [`docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md`](../plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md)
Status `Proposed`, Nacharbeit-Commit `a0bf8da` (Diff `a0bf8da^..a0bf8da` = `f26e5ac..a0bf8da`,
**eine** Datei: die ADR).

**Skill:** `.harness/skills/reviewer.md` @ 1.7.0 ·
**Modell:** claude-opus-5[1m] · **Datum:** 2026-09-06

**Reviewer:** frischer Kontext. Keines der geprüften Artefakte selbst geschrieben, an keinem etwas
geändert. **Jede Zahl und jedes Kommando dieses Reports ist in diesem Lauf selbst gefahren**;
nichts ist aus der Commit-Message von `a0bf8da`, aus dem Slice-Plan oder aus der ADR übernommen.
Der blockierende Befund der Vorrunde ist am Ist-Stand nachgeprüft, nicht am Änderungsbericht.

---

## Eingangs-Kontext (fünf Pflicht-Punkte + Plan)

- **Diff-Range:** `a0bf8da` gegen `a0bf8da^` = `f26e5ac`. **Der Arbeitsbaum ruhte in diesem Lauf**
  — anders als in Runde 4, wo während der Prüfung sieben fremde Commits landeten. Gemessen zu
  Beginn und am Ende: `git log --oneline -1` → `a0bf8da` in beiden Fällen,
  `git status --porcelain` bis zum Schreiben dieses Reports leer. Der Prüfgegenstand ist über die
  Strecke **byte-gleich**; kein fremder Commit ist eingegangen. Die Feststellung steht hier, weil
  ein Report, der einen ruhenden Baum behauptet, den er nicht hatte, seine eigene
  Reproduzierbarkeit falsch beschriebe — und weil die Auftragslage der Vorrunde genau daran
  scheiterte.
- **`LH-*`:** [`LH-FA-01`](../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen),
  [`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) (Rang 1, der
  ausgelegte Absatz), [`LH-FA-03`](../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7),
  [`LH-FA-09`](../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren),
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6).
- **Referenzierte aktive ADRs**, Status in diesem Lauf gemessen
  (`for f in 0005 0006 0007 0016 0034; do grep -m1 '^\*\*Status:\*\*' docs/plan/adr/$f-*.md; done`):
  alle fünf `Accepted`. Keine `Superseded`/`Deprecated` unter den zitierten.
- **Hard Rules:** [`AGENTS.md`](../../AGENTS.md) §3, insbesondere §3.4 (die Kosten-Asymmetrie, die
  diesen Report trägt), §3.5, §3.6, §3.8, §3.9, §3.10, §3.11. Dazu
  [`MR-000`](../../harness/conventions.md#mr-000--baseline-aussage),
  [`MR-001`](../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids),
  [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler),
  [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert),
  [`MR-033`](../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist),
  [`MR-036`](../../harness/conventions.md#mr-036--die-change-request-regel-bei-personalunion-steht-jetzt-in-der-adoptierten-baseline)
  und [`MR-051`](../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung).
- **Vorherige Findings am gleichen Modul:**
  [Runde 1](2026-09-06-adr-0037-konsistenz-review.md) (0 HIGH · 5 MEDIUM · 4 LOW · 3 INFO),
  [Runde 2](2026-09-06-adr-0037-konsistenz-review-runde-2.md) (0 HIGH · 2 MEDIUM · 4 LOW · 5 INFO),
  [Runde 3](2026-09-06-adr-0037-konsistenz-review-runde-3.md) (0 HIGH · 3 MEDIUM · 1 LOW · 2 INFO)
  und [Runde 4](2026-09-06-adr-0037-konsistenz-review-runde-4.md) (0 HIGH · 1 MEDIUM · 1 LOW ·
  2 INFO), alle vier *Konsistenz NICHT BESTÄTIGT*.
- **Slice-Plan:** `slice-190` — das Übergabe-Artefakt, dessen zwei Fragen die ADR beantwortet.
  Seine Verzeichnis-Position steht hier bewusst nicht als Pfad
  ([`AGENTS.md`](../../AGENTS.md) §3.11); die Kommandos unten adressieren ihn über den Glob
  `docs/plan/planning/*/slice-190-*.md`, der in diesem Lauf **genau eine** Datei trifft
  (`ls -1 docs/plan/planning/*/slice-190-*.md | wc -l` → **1**, kein Erwartungswert).

**Gate-Lauf, Docker-only (§3.9).** `make docs-check` vor dem Schreiben dieses Reports →
`d-check: 888 Datei(en) geprüft, 0 Befund(e)`, EXIT 0. `make gates` **nach** dem Schreiben →
EXIT 0; dieser Lauf schließt `docs-check` ein und deckt damit auch diese Datei, die den
Prüfbereich auf `d-check: 889 Datei(en) geprüft, 0 Befund(e)` hebt.

---

## Findings

Jedes Finding folgt dem §Output-Schema des Reviewer-Skills.

### M-1 — Die Nacharbeit verbreitert den Satz von „jene zwei Stellen" auf „§3" und erklärt damit eine Sektion für unberührt, die in ihrer Plan-Tabelle eine unbedingt entwertete Anlege-Aussage trägt

- `kategorie`: **MEDIUM** (blockiert den Statuswechsel)
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.10 (diese ADR ist das Übergabe-Artefakt, aus dem der
  Planner schöpft — so sagt es ihre eigene Folgepflicht 4) · Maintainability
- `pfad`: `docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md:593` (Kopfsatz) und
  `:600` (Schlusssatz), gegen `:638–640` (die Aufzählung der Kollisionsstellen)
- `befund`: Der Absatz trägt jetzt den Kopfsatz *„Von zwei weiteren Stellen desselben Plans ist
  **eine** nicht betroffen, die andere schon"* und schließt mit *„Dazu sagt **§3** nichts."* —
  wobei *„dazu"* die Anlege-Frage meint (*„ob er aufzunehmen ist"*). Gemessen sagt §3 dazu etwas:
  Seine Tabelle *Plan (vor Code)* führt die Zeile
  `` | `internal/emit/templates.go` (`structureGitkeeps`) | update | die zwei fehlenden Verzeichnisse; … | ``
  Das ist eine Aussage auf der **Anlege-Achse** — sie setzt voraus, dass `structureGitkeeps()` um
  **zwei** Verzeichnisse wächst —, und Festlegung 4 trägt `docs/plan/carveouts/done` nicht. Die
  Zeile steht **vor** dem Absatz *„Die Change-Request-Frage steht vor dem Code"*, über den der
  Absatz der ADR allein spricht: innerhalb von §3 an Position 10 gegen Position 17. **Die
  Verbreiterung ist neu in dieser Runde:** Der Vorgänger-Stand schloss mit *„Dazu sagen jene zwei
  **Stellen** nichts"* — satz-skopiert und in dieser Hinsicht unangreifbar; die M-1-Nacharbeit hat
  das Subjekt auf die **Sektion** gehoben und damit eine Aussage erzeugt, die falsch ist. Betroffen
  ist damit auch die Aufzählung, die Folgepflicht 4 trägt: *„Sie benennt, wo die Kollision im Plan
  aufschlägt — **DoD (1)**, **DoD (3)** und §1"*.
- **Failure-Szenario:** Folgepflicht 4 schickt den Planner mit drei benannten Stellen los. Er
  korrigiert DoD (1), DoD (3) und §1 und lässt §3 stehen, weil die — dann nach
  [`AGENTS.md`](../../AGENTS.md) §3.4 unveränderliche — ADR ihm sagt, §3 sage dazu nichts. §3 ist
  die Sektion **Plan (vor Code)**, also genau die, aus der der Implementer liest, *was* er ändert.
  Sie weist ihn auf *„die zwei fehlenden Verzeichnisse"* an, und er legt
  `docs/plan/carveouts/done` an — den Ort, den Festlegung 4 ausschließt. Der Widerspruch steht dann
  zwischen einer korrigierten DoD und einer stehengebliebenen Plan-Tabelle, und die ADR-Seite ist
  gesperrt: Die Korrektur ist eine Folge-ADR mit `Supersedes`, heute ist sie ein Satz.
- **Steelman, geprüft und nicht tragend:** *„Dazu"* ließe sich als *„entscheidet darüber"* lesen —
  §3 entscheide nichts, es setze nur die Entscheidung aus §1/DoD (1) voraus. Der Test des Absatzes
  ist aber nicht *entscheidet*, sondern **betroffen** (Kopfsatz) bzw. *wo die Kollision
  **aufschlägt*** (Folgepflicht-Satz). Unter dem eigenen Test der Datei wird die §3-Zeile falsch,
  sobald Festlegung 4 gilt — sie ist betroffen.
- **Was dieser Befund nicht bestreitet:** die **Entscheidung**, `docs/plan/carveouts/done/`
  draußen zu lassen — sie trägt, in fünf Runden unwidersprochen. Und ausdrücklich **bestätigt** ist
  die Nacharbeit an §1: Die drei Messungen, mit denen die Datei §1 auf die Anlege-Achse stellt,
  reproduzieren sämtlich (siehe Negativbefunde), und die Zuordnung ist richtig.
- **Zwei weitere Stellen, geprüft und ausdrücklich *nicht* als Befund geführt:** §4
  (Rückführung *„falls die Nachmessung eine andere Zahl als **3** liefert"*) und §5
  (Closure-Kriterium (a), *„**6** vorher und **3** nachher"*) wiederholen die Messzahl aus DoD (3).
  Sie hängen an derselben Frage, die die Datei **ausdrücklich offen lässt** (*„nimmt … nicht die
  Frage [vorweg], ob die Messzahl in DoD (3) auf dem verbleibenden Weg gehalten wird"*, `:638`) —
  auf dem Marker-Weg aus §6 kann die Zahl **3** halten. Sie sind damit bedingt und tragen den
  Befund nicht; die §3-Zeile ist unbedingt betroffen und trägt ihn allein.
- `verifizierbar`: **nein** — kein Gate hält einen ADR-Satz gegen den Inhalt einer Plandatei.
  Reproduzierbar:
  ```sh
  P='docs/plan/planning/*/slice-190-*.md'
  A=docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md
  grep -c 'Dazu sagt §3 nichts' "$A"                                          # 1
  grep -c 'ist eine nicht betroffen, die andere schon' "$A"                   # 1
  sed -n '/^## 3\./,/^## 4\./p' $P | grep -c 'die zwei fehlenden Verzeichnisse'  # 1
  sed -n '/^## 3\./,/^## 4\./p' $P | grep -c 'structureGitkeeps'                 # 1
  sed -n '/^## 3\./,/^## 4\./p' $P | wc -l                                       # 30 — Gegenprobe:
                                                                                 #      Ausschnitt
                                                                                 #      nicht leer
  git show 3a90ceb:"$A" | grep -c 'Dazu sagen jene zwei Stellen nichts'       # 1 — der Vorstand
  ```
  **Keine Erwartungswerte**; der Glob statt der Pfad-Adresse nach
  [`AGENTS.md`](../../AGENTS.md) §3.11.
- `klasse`: *Aussage über den Stand eines fremden Artefakts ohne Messung an ihm*

### INFO-1 — Die Liste der nicht gebauten Deckungen führt zwei Stück und nennt die Klasse nicht, an der vier Befunde aus vier Runden hingen

- `kategorie`: INFO
- `quelle`: [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
  (eine Deckung, die kein Lauf prüft, wird nicht als vorhanden verbucht) · Maintainability
- `pfad`: `docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md:713–719`
- `befund`: Der Abschnitt sagt *„Nicht gebaut, und hier benannt statt behauptet — **zwei
  Stück**"* und nennt (i) Festlegung 1 ohne Sensor, weil (a) ein Urteil ist, und (ii) die Deckung
  zwischen emittiertem Text und emittiertem Bestand. Die dritte, in dieser Datei am häufigsten
  wirksame Lücke steht **nicht** dabei: dass die Datei durchgehend Aussagen über den Inhalt von
  `slice-190` trifft und kein Lauf sie hält. Genau an dieser Klasse hingen Runde-1-M-4, Runde-2-L-2,
  Runde-4-M-1 und M-1 dieser Runde — vier Instanzen in vier Runden. Die Zahl *zwei* ist damit eine
  Vollständigkeits-Angabe über eine Menge, die die Datei selbst enger zieht als ihr Inhalt.
- **Warum nur INFO:** Die Ziel-Form verlangt in §Fitness Function eine Aussage über die
  maschinelle Prüfbarkeit der **Entscheidung**, nicht über jede beschreibende Passage; das
  Weglassen verletzt keine bindende Quelle. Der Posten steht hier, weil er die Ursache des
  wiederkehrenden Musters benennt — nicht als Nacharbeits-Auflage.
- `verifizierbar`: nein.
  ```sh
  A=docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md
  grep -c 'Nicht gebaut, und hier benannt statt behauptet — zwei Stück' "$A"   # 1
  grep -c 'Plandatei\|Plan-Datei\|Slice-Plan' "$A"                             # 1 — die einzige
                                                                               #     Nennung steht
                                                                               #     nicht dort
  ```
- `klasse`: *Vollständigkeits-Angabe über eine Menge, die enger gezogen ist als der Inhalt*

---

## Korrektur an meinem eigenen Instrument (Nebenbefund des Architect, geprüft — und ein größerer daneben)

Der Architect kritisiert den §3.11-Test meiner Vorrunde,
`grep -coE 'docs/plan/planning/(open|next|in-progress|done)/'` → **0**. Die Kritik trifft **zur
Hälfte**, ihre Folgerung trägt **nicht**, und beim Nachfahren fällt ein **dritter, größerer**
Defekt an, den sie nicht nennt. Alles drei in diesem Lauf gemessen statt übernommen.

**Richtig ist seine Beobachtung:** Die damalige Datei enthielt die Alternation als abgedruckten
Text (das Kommando in Festlegung 1 zu Form 3), und mein ERE trifft sie nicht — der Text führt nach
`planning/` eine Klammer, nicht eines der vier Wörter.

```sh
printf "%s\n" "   grep -oE '^docs/plan/planning/(open|next|in-progress|done)/' \\" > /tmp/lit.txt
/usr/bin/grep -coE 'docs/plan/planning/(open|next|in-progress|done)/' /tmp/lit.txt   # 0
```

**Nicht richtig ist seine Folgerung**, das Verdikt sei deshalb „unbelegt" gewesen. Eine
abgedruckte Regex-Alternation *ist* keine Pfad-Adresse; sie nicht zu treffen ist richtiges
Verhalten, kein Defekt. Dass das Instrument echte Adressen findet, belegt derselbe Test an der
neuen Fassung: dasselbe Kommando liefert dort **2**. Und der Vorstand trug tatsächlich keine
solche Adresse — die `planning/`-Treffer waren `observations/…`, `README.md`,
`reconciliation.md`, die Vorlagen-Pfade und der Glob.

**Der Defekt, den er nicht nennt, ist der größere: `-c` zusammen mit `-o` ist
implementierungsabhängig.** GNU grep 3.11 — was jedes `bash`-Skript, jedes `make`-Rezept und jeder
CI-Lauf auflöst — zählt mit `-c` **Zeilen** und ignoriert `-o`. Die interaktive Sitzung, in der
mein Vorrunden-Report entstand, leitet `grep` über eine Shell-Funktion auf **ugrep 7.8.4** um, und
das zählt **Vorkommen**. Dieselbe abgedruckte Zeile liefert damit über einer Datei mit zwei
Adressen **in einer** Zeile zwei verschiedene Zahlen:

```sh
printf "docs/plan/planning/done/ und docs/plan/planning/open/ in EINER Zeile\n" > /tmp/zwei.txt
/usr/bin/grep --version | head -1        # grep (GNU grep) 3.11
/usr/bin/grep -coE 'docs/plan/planning/(open|next|in-progress|done)/' /tmp/zwei.txt   # 1 — Zeilen
/usr/bin/grep -oE  'docs/plan/planning/(open|next|in-progress|done)/' /tmp/zwei.txt \
  | wc -l                                                                            # 2 — Vorkommen
```

**Keine Erwartungswerte.** Ein Report, der `-co` abdruckt und eine Zahl daneben stellt, sagt damit
nicht, *was* er gezählt hat — dieselbe Klasse wie eine Zahl ohne Kommando
([`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)),
nur eine Ebene tiefer, und ein Reproduzierbarkeits-Risiko nach
[`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit). Es ist zugleich der Grund,
warum die zwei Läufe dieses Reports auseinanderliefen: interaktiv `2`, im Skript `1`.

**Am Verdikt ändert das nichts, und das ist gemessen, nicht gehofft.** Über beiden Fassungen der
ADR liefern die zwei Zählweisen dasselbe, weil keine Zeile mehr als eine Adresse trägt:

```sh
A=docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md
/usr/bin/grep -coE 'docs/plan/planning/(open|next|in-progress|done)/' "$A"           # 2
/usr/bin/grep -oE  'docs/plan/planning/(open|next|in-progress|done)/' "$A" | wc -l   # 2
/usr/bin/grep -noE 'docs/plan/planning/(open|next|in-progress|done)/' "$A"
# 324:docs/plan/planning/done/
# 333:docs/plan/planning/done/
```

**Keine Erwartungswerte.** Beide Treffer sind `docs/plan/planning/done/` — ein Baseline-Zitat und
ein abgedrucktes Kommando, beide über ein **Verzeichnis**, das
[`AGENTS.md`](../../AGENTS.md) §3.11 ausdrücklich für ortsfest erklärt. **§3.11 bleibt gewahrt**,
und der zweite Teil der Architect-Meldung stimmt vollständig.

**Die ADR ist von der Zweideutigkeit nicht betroffen** — sie kombiniert `-c` und `-o` an keiner
Stelle, und alle 19 Blöcke sind unten unter GNU grep gefahren:

```sh
/usr/bin/grep -cE 'grep -[a-zA-Z]*c[a-zA-Z]*o|grep -[a-zA-Z]*o[a-zA-Z]*c' \
  docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md   # 0
```

**Keine Erwartungswerte.** Betroffen ist allein mein Vorrunden-Report, an genau einer Zeile.
---

## Negativbefunde (geprüft, ohne Befund)

**Alle 49 abgedruckten Kommandos der ADR in diesem Lauf nachgefahren — jedes liefert den
abgedruckten Wert.** Die Datei trägt **19** ` ```sh `-Zäune (auch eingerückte) mit zusammen **46**
Kommandos, dazu **drei** inline (Festlegung 3 und die zwei Geschichte-Zeilen, die eine Zahl
tragen). Die zwei Zahlen sind gemessen, nicht gezählt:

```sh
A=docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md
grep -cE '^[[:space:]]*```sh$' "$A"                                                       # 19
awk '/^[[:space:]]*```sh$/{inb=1;cont=0;next} /^[[:space:]]*```$/{inb=0;next}
     inb{ l=$0; sub(/^[[:space:]]+/,"",l); if(l==""||l ~ /^#/) next;
          if(cont==0) n++; cont = (l ~ /\\$/) }
     END{print n}' "$A"                                                                   # 46
```

**Keine Erwartungswerte.** Gefahren wurde blockweise über eine `awk`-Extraktion der Zäune, danach
`bash` — also unter **GNU grep 3.11**, nicht unter dem `ugrep`-Umweg der
interaktiven Sitzung (siehe §Korrektur oben). Ergebnisse in der Reihenfolge der Datei:
`1`·`1` · `1`·`1` · `3`·`2` · `3`·`2` · die
vierzeilige Klammer-Ausgabe · die einzeilige Lifecycle-Klammer · `4`·`3` ·
`| 0.8.0 | 2026-07-21`·`2026-09-03` · `0` · `1`·`0` · **`1`·`1`·`1` (der neue `done/`-Block)** ·
`0`·`3` · `1`·`1` · `1`·`0` · die einzeilige `.gitkeep`-Satz-Ausgabe · `2`·`1`· die zweizeilige
Link-Ausgabe der zwei Index-Vorlagen · `1`·`1` · `0`·`1`·`1`·`1`·`1` ·
**`0`·`1`·`1`·`1`·`1`·`1`·`1`·`1` (der auf acht erweiterte `slice-190`-Block)** · **2** Zeilen
`git log --follow` · **2** (Register-Zähler) · **6** (Risiken ohne Ausgang). **Keine Abweichung.**
Damit ist auch die Meldung des Architect-Laufs, alle 19 Blöcke plus drei Inline-Kommandos seien
gefahren worden, unabhängig bestätigt.

**Die vom Architect zusätzlich gemeldete Messung, die mein Vorrunden-Report nicht führte,
reproduziert exakt.** Die Change-Request-Frage kommt im Kopf vor §1 **null**-mal, in §1
**null**-mal, in §2 **null**-mal und in §3 **drei**-mal vor; das erste Vorkommen der ganzen Datei
liegt in §3. Die Trennung §1/§3 auf der Change-Request-Achse ist damit **sauber gezogen**.

```sh
P=docs/plan/planning/*/slice-190-*.md
sed -n '1,/^## 1\. Ziel/p' $P | head -n -1 | grep -c 'Change Request\|Change-Request'          # 0
sed -n '/^## 1\. Ziel/,/^## 2\./p' $P | grep -c 'Change Request\|Change-Request'               # 0
sed -n '/^## 2\. Definition of Done/,/^## 3\./p' $P | grep -c 'Change Request\|Change-Request' # 0
sed -n '/^## 3\./,/^## 4\./p' $P | grep -c 'Change Request\|Change-Request'                    # 3
```

**Keine Erwartungswerte.**

**Der blockierende Befund der Vorrunde, am Ist-Stand nachgeprüft:**

- **M-1 (Runde 4) auf seiner tragenden Achse behoben.** Die Datei zieht §1 jetzt auf die
  **Anlege-Achse** und begründet das an drei Messungen, die alle drei reproduzieren (siehe die
  acht Kommandos des `slice-190`-Blocks oben): §1 nennt die Change-Request-Frage **null**-mal,
  **DoD (1)** knüpft *„unstrittig"* ans Anlegen (*„Der Bootstrap legt die zwei unstrittigen Orte
  an"*), und auf der Change-Request-Achse stehen die zwei Orte **verschieden**, weil §6 für
  `harness/conventions` die Frage ausdrücklich offen führt. **Der zweite Satz derselben Sektion
  ist nachgezogen:** *„drei Fundstellen … alle aus dem Register-Konflikt"* steht jetzt als
  mitfallende Prämisse in der Datei. **Die Aussage über §3 bleibt richtig, soweit sie den
  zitierten Satz meint** — er steht im Absatz *„Die Change-Request-Frage steht vor dem Code"* und
  mündet in *„ist hier nicht entschieden"*. Was nicht behoben ist, ist die **Sektions**-Skopierung
  desselben Satzes; das ist M-1 dieser Runde und ein kleinerer Gegenstand als der der Vorrunde.
- **Die Übergabe ist unverändert sauber.** Der Commit berührt **genau eine** Datei
  (`git show --pretty=format: --name-only a0bf8da` → die ADR), also kein Planner-Artefakt —
  [`AGENTS.md`](../../AGENTS.md) §3.10 gewahrt; die Message trägt das Rollen-Präfix (§3.8). Die
  Datei schlägt für keine der genannten Stellen einen Wortlaut vor und lässt die Messzahl-Frage
  ausdrücklich offen.

**Die drei nicht blockierenden Posten der Vorrunde, je am Ist-Stand geprüft:**

- **L-1 behoben, und die Einschränkung kippt keinen der Ausschlüsse — je Ausschluss einzeln
  geprüft.** Die zweite Kollisions-Regel greift jetzt allein an einer Aussage über die **Existenz**
  eines Ortes; der neue Absatz begründet die Grenze aus der Selbst-Widerlegung heraus (griffe sie
  an Form 2, entkräftete jede Ziel-Nennung jede unbedingte, und die erste Regel sagt das
  Gegenteil). **Gegenprobe je Ausschluss:** Die **derivativen Indexe** stehen auf der eigenen
  Klassen-Regel des [`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)-Absatzes
  und auf der Gegenstandslosigkeit von Festlegung 1 — Regel 2 kommt dort nicht vor. Das
  **Reconciliation-Register** scheitert an Form 1 (Modus-Zusatz) — Regel 2 kommt nicht vor.
  `harness/conventions/done/` scheitert an Form 3 und Form 2, und die Datei sagt ausdrücklich, eine
  unbedingte Nennung trage keine der beiden Quellen — Regel 2 wird dort nicht gebraucht.
  `docs/plan/carveouts/done/` ist der **einzige** Ausschluss, der Regel 2 benutzt, und dort nur
  *„dazu tretend"*; die zitierte Stelle prädiziert tatsächlich die **Existenz**
  (*„done/ entsteht erst bei erster Carveout-Auflösung"*) und fällt damit unter die verengte
  Fassung. **Alle drei Ausschlüsse stehen unverändert** — die Meldung des Architect ist
  unabhängig bestätigt.
- **Der neue Gegen-Fall trägt und ist nicht konstruiert.** `docs/plan/planning/done/` hat in der
  Verzeichniskonvention eine eigene Zeile ohne Modus- oder Bedingungs-Zusatz
  (`docs/plan/planning/done/    # abgeschlossene Slices`), ist in der mitemittierten
  `slice.template.md` Ziel eines `git mv` — im **Rumpf**, außerhalb des mit *„Lösche diesen Block"*
  markierten Template-Hinweises —, und der Emitter legt ihn an. Regel 1 liefert *(a) erfüllt*, und
  das Ergebnis stimmt mit dem Ist-Verhalten überein. Ohne die neue Grenze gäbe dasselbe Kriterium
  hier zwei Antworten; mit ihr eine.
- **INFO-1 (Runde 4) behoben.** *„nach dieser Festlegung"* heißt jetzt *„nach diesem
  Rang-1-Satz"*; der Antezedent ist eindeutig, die zirkuläre Lesart ist ausgeschlossen
  (`grep -c 'ist nach diesem Rang-1-Satz \*\*keines\*\*'` → **1**,
  `grep -c 'ist nach dieser Festlegung \*\*keines\*\*'` → **0**).
- **INFO-2 (Runde 4) behoben, und zwar durch Einschränkung statt durch Zusatz-Begründung.** Die
  Gegen-Lesart-Hälfte trägt jetzt nur noch, was sie misst — die Change-Request-Antwort, eine Frage
  an den **Text** von Rang 1. Die Träger-Frage ist ausdrücklich als Frage an die **Befolgung**
  abgetrennt und auf der Haupt-Lesart entschieden; die Datei sagt selbst, dass die Gegen-Lesart
  dafür *„keine zweite Begründung"* liefert. Das ist die ehrliche Form: eine benannte Grenze statt
  einer Robustheits-Zusage, die eine andere Frage beantwortet.

**Sonstiges, geprüft ohne Befund:**

- **Gegen die Entscheidung selbst steht in fünf Läufen kein Befund.** Die zwei
  Kern-Argumentationen ([ADR-0007](../plan/adr/0007-bootstrap-phasen.md) beantwortet *wie*, nicht
  *ob*; [ADR-0034](../plan/adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
  Festlegung 1 schreibt die `README.md` als Bestandteil der Ablage vor) sind unverändert; der
  emittierte Selbstwiderspruch ist in diesem Lauf erneut gemessen (`3` Anweisungssätze, `2` davon
  namentlich, `3` Go-Fundstellen, keine schreibend).
- **[`AGENTS.md`](../../AGENTS.md) §3.8 — Commit-Zuschnitt korrekt.**
  `git show --pretty=format: --name-only a0bf8da` gibt **eine** Datei, die ADR; die Message nennt
  die Rolle im Präfix. Der ADR-Index braucht keinen Nachzug — Titel, Status und die Reihenfolge
  der sechzehn Bezugs-IDs sind unverändert (in diesem Lauf gegen `docs/plan/adr/README.md:44`
  gehalten).
- **§3.4 nicht verletzt.** Die Datei steht auf `Proposed`; Überarbeitungen sind in diesem Fenster
  zulässig, und [ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 3 verlangt
  die Beleg-Korrektur ausdrücklich hier. Die Zitate der alten Fassungen in den Geschichte-Zeilen
  sind als solche gekennzeichnet.
- **§3.5 — keine Gate-Lockerung**, kein Schwellwert, kein `ignore`-Eintrag, keine
  Modul-Abschaltung berührt; die Datei trägt **null** HTML-Kommentare und damit auch keinen
  `d-check:ignore`-Marker (`grep -c '<!--'` → **0**; die `d-check:ignore`-Treffer stehen sämtlich
  in Zitaten und Kommandos).
- **[ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 3 (a) — die
  Vorbedingung des Accept-Übergangs steht weiter erfüllt.** Die zwei in dieser Runde neu
  hinzugekommenen Baseline-Belege tragen je Tag (`v6.0.0`), Datei, Abschnitt bzw. Kopf-Feld und
  Zitat; beide Abschnittsangaben existieren wörtlich (`### Verzeichniskonvention`; Kopf-Feld
  `**Lifecycle:**`), und beide zitierten Sätze liegen im **Rumpf**, der eine im Regelwerks-Baum,
  der andere außerhalb des Template-Hinweis-Blocks der Vorlage. Die Auslassungsmarke im
  Lifecycle-Zitat ist gesetzt.
- **[`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert),
  [`MR-033`](../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
  und [`MR-051`](../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
  gewahrt.** Jede Messwert-Zahl steht neben ihrem Kommando und ist als kein Erwartungswert
  gekennzeichnet — auch die **neun** in dieser Runde neuen (drei im `done/`-Block, sechs im
  erweiterten `slice-190`-Block, der von zwei auf acht Kommandos gewachsen ist). Jede
  Baseline-Aussage nennt den Tag `v6.0.0`. Der Register-Zähler ist datiert und trägt sein
  Ableitungs-Kommando; nachgefahren → **2**.
- **[`MR-000`](../../harness/conventions.md#mr-000--baseline-aussage) — kein Adaptions-Eintrag
  fällig.** Keine der vier Festlegungen weicht von einer **Baseline**-Regel ab; die Entscheidung
  stellt Baseline-Konformität her.
- **[`MR-001`](../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
  gewahrt.** `make docs-check` ist mit `ids: link-policy: always` grün (888 Dateien, 0 Befunde).
- **[`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) — kein
  halluziniertes Gate.** `TestTemplates_EmittierterBestandVollstaendig` existiert, `make full-smoke`
  existiert und ist als Nicht-Gate ausgewiesen; die zwei genannten nicht gebauten Deckungen sind
  benannt statt behauptet. Dass die Aufzählung *zwei* eine dritte auslässt, steht als INFO-1 — das
  ist keine Halluzination eines Gates, sondern eine zu enge Selbst-Auskunft.
- **Ziel-Form vollständig.** Gegen
  [`NNNN-titel.template.md`](../../.harness/baseline/v6.0.0/templates/docs/plan/adr/NNNN-titel.template.md)
  geprüft: Status · Datum · Autor · Bezug · Schärft · Regeln · Kontext · Entscheidung ·
  Verglichene Alternativen (fünf Optionen, *nichts tun* dabei) · Konsequenzen · Fitness Function ·
  Re-Evaluierungs-Trigger (**sechs**, und **alle sechs** tragen eine Ablesestelle:
  `… | grep -c 'ablesbar)\*'` → **6** bei `grep -c '^- \*\*Wenn'` → **6**) · Geschichte ·
  Immutabilitäts-Schluss.
- **Docker-only (§3.9).** Kein Host-Paketmanager, keine Host-Toolchain in diesem Lauf; alles über
  `make`, `git`, `grep`, `sed`, `awk`, `ls`, `find`, `bash`.
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

**Finding-Klassen dieses Laufs:** *Aussage über den Stand eines fremden Artefakts ohne Messung an
ihm* · *Vollständigkeits-Angabe über eine Menge, die enger gezogen ist als der Inhalt*

**Das Muster aus den Runden 2–3 bleibt geschlossen.** *„Das Kriterium verspricht eine Reichweite,
die sein geschriebener Text nicht hat"* findet auch in dieser Runde keine Instanz: Die
Auswertungs-Regel zu (a) ist durch die Existenz/Ziel-Grenze eher **enger** und in sich
widerspruchsfrei geworden, sie deckt ihren neuen Gegen-Fall `docs/plan/planning/done/` aus eigenem
Text, und keiner der vier Ausschlüsse hängt an der verengten Regel, außer dem einen, für den sie
weiterhin trägt.

**Stattdessen läuft eine andere Klasse zum vierten Mal — und sie hat ihre Schwelle schon in
Runde 4 überschritten.** *Aussage über den Stand eines fremden Artefakts ohne Messung an ihm* trug
Runde-1-M-4 (eine Zahl über den Stand von `slice-190` §6), Runde-2-L-2 (die zweite Zahl über
denselben fremden Stand), Runde-4-M-1 (§1 zu Unrecht für unberührt erklärt) und jetzt M-1 (§3 zu
Unrecht für unberührt erklärt) — **vier Instanzen in vier Runden**, in diesem Lauf über die
`klasse`-Zeilen der vier Reports gemessen:

```sh
grep -l 'klasse.*fremden Artefakts' \
  docs/reviews/2026-09-06-adr-0037-konsistenz-review*.md | wc -l   # 4
```

**Keine Erwartungswerte.** Die 3×-Schwelle war damit **bereits vor dieser Runde** erreicht
(Reviewer-Skill §Kontext-Eskalation;
[Modul 8](../../.harness/baseline/v6.0.0/regelwerk/modul-08-agentenrollen.md) §Konflikt-Pfad, *ab
dem dritten gleichen Konflikttyp*), ohne dass ein Ausgang zugewiesen wurde — der Zähler läuft
weiter, und das ist die eigentliche Beobachtung dieser Runde. Bemerkenswert ist die Richtung: Die
Nacharbeit zu Runde-4-M-1 hat den Satz von *„jene zwei Stellen"* auf *„§3"* **verbreitert** und
damit die vierte Instanz erst erzeugt — die Korrektur einer zu engen Reichweiten-Angabe hat eine
zu weite Unberührtheits-Angabe hinterlassen. INFO-1 benennt die strukturelle Ursache: Die Datei
zählt ihre nicht gebauten Deckungen und lässt gerade die aus, unter die alle vier Instanzen
fallen. Die Register-Zuordnung der Klasse fällt bei der Slice-Closure, nicht hier
([`AGENTS.md`](../../AGENTS.md) §3.10).

**Was sich gegenüber Runde 4 verschoben hat.** Findings von vier auf zwei, LOW auf null, INFO von
zwei auf eins. Das eine blockierende MEDIUM ist **kleiner** als das der Vorrunde: Dort war eine
Sektion des Plans sachlich falsch zugeordnet (Change-Request- statt Anlege-Achse); hier ist die
Zuordnung richtig und nur das Subjekt eines Satzes eine Ebene zu groß. Die Zahl der Befunde gegen
die Entscheidung selbst bleibt in fünf Runden **null**.

---

## Verdikt

**Konsistenz NICHT BESTÄTIGT — ein blockierendes MEDIUM, kein HIGH.**

**Der Baseline-Trigger kann mit diesem Verdikt nicht feuern.** *„ADR-Review-Runde abgeschlossen →
bindend"* (Baseline `v6.0.0`, `grundlagen-bootstrap.md` §Vier Trigger-Klassen, Zeile der
Acceptance-Trigger-Klasse,
`grep -c 'ADR-Review-Runde abgeschlossen → bindend' .harness/baseline/v6.0.0/regelwerk/grundlagen-bootstrap.md`
→ **1**, kein Erwartungswert) setzt eine abgeschlossene Runde voraus; diese Runde schließt mit
einem blockierenden Befund.

**Der eine Posten ist M-1, und er liegt im Text der ADR — nicht in einem fremden Artefakt.** Zu
ändern ist das Subjekt eines Satzes: *„Dazu sagt §3 nichts"* trifft für den zitierten §3-**Satz**
zu und für die §3-**Sektion** nicht, weil deren Plan-Tabelle *„die zwei fehlenden Verzeichnisse"*
anweist. `slice-190` ist **nicht** anzufassen; die Folgerung daraus bleibt Planner-Arbeit
(Folgepflicht 4, [`AGENTS.md`](../../AGENTS.md) §3.10).

**Muss er den Übergang halten, oder kann er als benannte Grenze mitreisen?** Er muss ihn halten,
und der Grund ist nicht Vollständigkeit, sondern **Wahrheit**: Eine benannte Grenze ist eine
Aussage, die zutrifft und deren Reichweite beschränkt ist. Hier steht eine Aussage, die **nicht
zutrifft** — gemessen, an einer Zeile, die im Plan über der zitierten steht. Ab `Accepted` sperrt
[`AGENTS.md`](../../AGENTS.md) §3.4 sie, und der Preis steigt von einer Zeile auf eine Folge-ADR
mit `Supersedes`. Hinzu kommt, welche Sektion betroffen ist: §3 heißt *Plan (vor Code)* und ist
die Stelle, aus der der Implementer liest, *was* er ändert — sie weist heute auf zwei
Verzeichnisse an, und die ADR sagt dem Planner, sie sage dazu nichts. Eine Grenze, die man
mitreisen ließe, wäre der Satz **ohne** das Wort *§3*; ihn zu bekommen kostet dasselbe wie ihn zu
korrigieren.

**Was trägt, und es ist wieder fast alles.** Alle **49** abgedruckten Kommandos reproduzieren ohne
Abweichung, einschließlich der acht des `slice-190`-Blocks und der drei des neuen `done/`-Blocks.
Die vom Architect zusätzlich gemeldete Messung — Change-Request-Frage vor §1 / in §1 / in §2 / in
§3 = 0 / 0 / 0 / 3 — reproduziert exakt, und die Trennung §1/§3 ist auf der Change-Request-Achse
**sauber gezogen**. **DoD (1)**, **DoD (3)** und §1 sind als Kollisionsstellen **richtig benannt**;
sie sind nur nicht alle. Die Existenz/Ziel-Grenze aus L-1 trägt und kippt **keinen** der
Ausschlüsse — je Ausschluss einzeln nachgemessen —, und ihr neuer Gegen-Fall
`docs/plan/planning/done/` stimmt mit dem Ist-Verhalten des Emitters überein. INFO-1 und INFO-2
der Vorrunde sind behoben, INFO-2 in der ehrlichen Form: als eingeschränkte statt als
nachgereichte Begründung. Gegen die **Entscheidung** steht in fünf Läufen kein einziger Befund.

**Zur Selbst-Benennung der Lücken, ausdrücklich gefragt:** Sie ist **unvollständig**. Von den zwei
Lücken, die der Architect meldet, steht eine in der Datei (*Festlegung 1 hat keinen Sensor, (a) ist
ein Urteil* — das deckt auch die Existenz/Ziel-Grenze). Die andere — *kein Gate hält einen
ADR-Satz gegen den Inhalt einer Plandatei* — steht **nicht** in der Datei; die
Fitness-Function-Liste führt an ihrer Stelle die Deckung zwischen emittiertem Text und emittiertem
Bestand. Das ist INFO-1 und blockiert nicht.

**Zum Nebenbefund an meinem eigenen Instrument, ausdrücklich gefragt:** Er **trägt zur Hälfte**,
und die Nachprüfung fördert einen dritten, größeren Defekt zutage, den er nicht nennt. Richtig ist,
dass mein ERE das abgedruckte Kommando-Literal nicht trifft; falsch ist der Schluss, das Verdikt
sei damit unbelegt — eine abgedruckte Regex ist keine Pfad-Adresse, und dasselbe Kommando findet
echte Adressen nachweislich (neue Fassung → **2**). Der eigentliche Defekt liegt woanders: `-c`
zusammen mit `-o` zählt unter **GNU grep 3.11** Zeilen und unter dem **ugrep**, auf den diese
Sitzung `grep` umleitet, Vorkommen — dieselbe abgedruckte Zeile liefert über einer Datei mit zwei
Adressen in einer Zeile `1` bzw. `2`. Über beiden Fassungen der ADR fällt das nicht ins Gewicht
(keine Zeile trägt mehr als eine Adresse, beide Zählweisen liefern **2** bzw. **0**), und **§3.11
bleibt gewahrt**; die Zeile in meinem Vorrunden-Report bleibt trotzdem eine Zahl, die nicht sagt,
was sie zählt. Das ist ein Befund **an mir**, nicht an der ADR — die kombiniert `-c` und `-o` an
keiner Stelle (`0` Treffer) — und er steht hier, weil ein Reviewer, der eine Kritik an seinem
Instrument ungeprüft übernimmt oder ungeprüft abweist, in beiden Fällen dasselbe tut: nicht messen.

**Über den `Accepted`-Übergang entscheidet dieser Report nicht** — das ist Architect-Arbeit
([`AGENTS.md`](../../AGENTS.md) §3.8). Er stellt fest: **der Übergang ist heute nicht möglich, und
er ist es nach der Streichung eines Wortes.**

**Zur Baumlage.** `git log --oneline -1` zu Beginn und am Ende dieses Laufs → beide Male `a0bf8da`;
`git status --porcelain` bis zum Schreiben dieses Reports leer. **Der Prüfgegenstand war über die
Strecke stabil**, anders als in Runde 4.

**Übergabe.** Die Findings gehen an den **Architect** — er hält die ADR
([`AGENTS.md`](../../AGENTS.md) §3.8), und dieser Report hat kein Artefakt außer sich selbst
angefasst. **M-1 trägt keine eigene Kante an den Planner:** Die Folgerung aus der Kollision für
Schnitt und Abnahmekriterien von `slice-190` ist bereits als Folgepflicht 4 verdrahtet und bleibt
Planner-Arbeit ([`AGENTS.md`](../../AGENTS.md) §3.10); dieser Report schreibt sie nicht und
schlägt sie nicht vor. **Das Steering-Loop-Signal** aus der inzwischen **vierten** Instanz der Klasse
*Aussage über den Stand eines fremden Artefakts ohne Messung an ihm* geht in die Slice-Closure §7
und von dort in den Zähler; die Zuordnung zu einer `BEO-ALL/<slug>` fällt beim Schreiben der
Closure, nicht hier
([`docs/plan/planning/observations/README.md`](../plan/planning/observations/README.md)).

Dieser Report ist ein **Lauf-Beleg** und ersetzt keine Verifikation — DoD-/Spec-Konformität prüft
der Verifier separat (Modul 11, anderes Prüf-Artefakt, anderer Eingabe-Kontext).
