# Review-Report — ADR-0048, Konsistenzrunde 3

**Review-Art:** ADR-Konsistenzrunde (kein Slice-Review). Gegenstand ist eine einzelne Entscheidung
im Status `Proposed`, geprüft gegen die Quellen, die ihr eigener Acceptance-Trigger nennt.

**Datum:** 2026-09-14 · **Rolle:** Reviewer · **Kontext:** frisch und unabhängig — kein Anteil an
der Entstehung oder Überarbeitung der geprüften Datei, kein Anteil an einem der zwei
Vorgänger-Reports. Jede Zahl unten ist in diesem Lauf selbst erhoben; keine ist aus der ADR, aus
der Commit-Message oder aus einem Vorgänger-Report übernommen. Die zwei Vorgänger sind als
Kontext gelesen, ihre Verdikte sind **nachgemessen**, nicht übernommen.

**Gegenstand:** [`docs/plan/adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md`](../plan/adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md)
· **Status bei Prüfung:** `Proposed` · **Stand:** `9ccf81ed` (HEAD, `main`), `git status --porcelain`
leer.

**Skill:** `.harness/skills/reviewer.md` @ `0565f274` (2.0.0) · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-5[1m]

> **Zitier-Form** *(dieser Block bleibt stehen — er ist Norm, kein
> Ausfüll-Hinweis; die `<Platzhalter>` darin sind Formbeispiele)*. Dieser
> Report friert ein; was er zitiert, bewegt sich
> weiter. Deshalb: **Kennung, nicht Adresse** — `slice-<Kennung>` statt seines
> Lifecycle-Pfads, `make <target>` statt eines Links auf die Sensor-Datei, eine
> Baseline-Stelle als **Tag + Pfad in Inline-Code** statt als Link
> (`v<X.Y.Z>` · `regelwerk/<datei>.md` §<Abschnitt>). Der vendored Baum trägt
> genau einen Tag; der Sprung löscht den alten, und ein Link darauf färbt beim
> nächsten Bump ein Artefakt rot, das niemand mehr anfassen darf. Ein `pfad`-Feld
> auf den **geprüften Gegenstand** ist davon nicht betroffen — es zitiert den
> Stand des Laufs und darf ihn festhalten (`v<X.Y.Z>` ·
> `regelwerk/grundlagen-harness-dateien.md` §harness/README.md als
> Einstiegspunkt — diese Zeile ist selbst ein Beispiel der Form).

**Prüfgrundlage (Acceptance-Trigger der Datei, §Der Acceptance-Trigger):**
[ADR-0015](../plan/adr/0015-rollen-eigentum-an-norm-artefakten.md),
[ADR-0028](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md),
[ADR-0046](../plan/adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md).

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde — ohne diese Liste ist der Lauf nicht
reproduzierbar):

- Der Diff `9ccf81ed` (ADR-Datei + Index-Zeile) und seine Commit-Message; zum Vergleich der
  Vorgänger-Stand `2b914403`
- [ADR-0015](../plan/adr/0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1, 2,
  §Was hier NICHT entschieden ist ·
  [ADR-0028](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Festlegung 1, 2, 3,
  §Was hier NICHT entschieden ist ·
  [ADR-0046](../plan/adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) Festlegung 1, 2,
  §Was diese Entscheidung nicht tut (der ausgelegte Satz im Volltext), §Konsequenzen
  (Folgepflicht 1 und 2), §Der Acceptance-Trigger
- Die weiteren in der `Bezug:`-Zeile geführten ADRs:
  [ADR-0024](../plan/adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md)
  Festlegung 1/2/3 ·
  [ADR-0040](../plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 1/2/3 ·
  [ADR-0030](../plan/adr/0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) ·
  [ADR-0031](../plan/adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) (`Proposed`,
  Option F) · [ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 2 ·
  [ADR-0034](../plan/adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
  Festlegung 5
- [`AGENTS.md`](../../AGENTS.md) §3 (Hard Rules; tragend hier §3.3, §3.4, §3.5, §3.6, §3.7, §3.8,
  §3.10, §3.11) · [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
- [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  (samt Kopf-Marke) ·
  [`MR-033`](../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
  Setzung 1/2 ·
  [`MR-051`](../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
  §Geltungsbereich, Setzung 1/2 ·
  [`MR-055`](../../harness/conventions.md#mr-055--eine-stellen-messung-trägt-keine-folgerung-über-eine-eigenschaft) ·
  [`MR-057`](../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer) ·
  [`MR-058`](../../harness/conventions.md#mr-058--eine-messung-die-ihr-eigener-vorgang-bewegt-wird-nach-dem-vorgang-genommen)
- Baseline `v6.8.0` · `regelwerk/modul-04-adrs.md` §Ziel-Form: ADR (MADR) ·
  `regelwerk/modul-08-agentenrollen.md` §Rollen-Sequenz für eine Welle, §Konflikt-Pfad als
  Rollen-Sequenz · `templates/docs/plan/adr/NNNN-titel.template.md` ·
  `templates/docs/plan/planning/welle.template.md` ·
  `templates/docs/reviews/review-report.template.md`
- `.claude/commands/plan-welle.md` (Eröffnungssatz) · `.claude/agents/planner.md` (`description`)
- Vorherige Findings am gleichen Gegenstand: `2026-09-14-adr-0048-konsistenzrunde` (1 HIGH,
  5 MEDIUM, 3 LOW, 2 INFO) und `2026-09-14-adr-0048-konsistenzrunde-2` (0 HIGH, 4 MEDIUM, 6 LOW,
  2 INFO), dazu `2026-09-14-slice-flache-welle-ist-eroeffnet-nicht-geplant` (F-1 HIGH ist der
  ursprüngliche Auslöser)

**Rollen-Grenze:** Diese Runde ändert an der geprüften Datei nichts. Alle Sonden sind lesend; ein
Docker-Ziel ist gefahren (`make docs-check`), `make gates` fährt der Auftraggeber
([`AGENTS.md`](../../AGENTS.md) §3.9).

---

## Eigene Messungen

### Die Messung aus §Kontext — reproduziert am lebenden Stand

```sh
git grep -nE 'Welle-Plan|Welle-Datei' -- AGENTS.md harness/ spec/ docs/plan/adr/ .claude/ \
  ':!docs/reviews' ':!.harness/baseline' ':!docs/plan/adr/0048-*.md' | grep -ic planner   # 3
# ohne den 0048-Ausschluss, zur Gegenprobe:                                                 9
```

Der abgedruckte Wert **3** trifft. Die drei Treffer sind genau die drei Stellen der Aufzählung:
`docs/plan/adr/0031-…`:206 (Contra-Zelle Option F), `docs/plan/adr/0046-…`:256 (der ausgelegte
Satz), `docs/plan/adr/0046-…`:306 (erste Folgepflicht). **Keine Erwartungswerte** — die Gegenprobe
liefert heute **9** statt der **8**, die die Vorrunde maß; die Datei ist seither gewachsen, und
genau das ist der Grund für die Pathspec-Verengung
([`MR-058`](../../harness/conventions.md#mr-058--eine-messung-die-ihr-eigener-vorgang-bewegt-wird-nach-dem-vorgang-genommen)).

### Die breitere Suche, der vierte Treffer und die Stelle außerhalb des Musters

```sh
git grep -nE 'Welle-Plan|Welle-Datei|Wellen-Plan|welle-\*\.md' \
  -- ':!.harness/baseline' ':!docs/reviews' ':!docs/plan/planning/done' \
     ':!docs/plan/adr/0048-*.md' | grep -ic planner        # 4
grep -n 'Schreibt Pläne' .claude/agents/planner.md         # 3
```

Beide reproduzieren. Der vierte Treffer ist
`…/observations/BEO-ALL/fremdes-rollen-artefakt-im-implementations-kontext/evidence/slice-178.md`:2
— eine Evidence-Datei, keine Norm-Quelle. Die `description`-Zeile von `.claude/agents/planner.md`
lautet gelesen *„Schneidet Wellen und Slices … **Schreibt Pläne**, keinen Produktionscode."* Die
Einordnung der ADR (keine Quelle nach [ADR-0015](../plan/adr/0015-rollen-eigentum-an-norm-artefakten.md),
weil `.claude/agents/*.md` in keinem der neun Ränge steht und
[ADR-0028](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Festlegung 3 sie
ausnimmt) ist an beiden Quellen nachgelesen und trifft.

### Baseline- und Zitat-Kommandos — alle neun neu gefahren

```sh
B=".harness/baseline/$(grep -m1 '^BASELINE_TAG ?= ' Makefile | cut -d' ' -f3)/regelwerk/modul-08-agentenrollen.md"
grep -c 'Die Eröffnung ist Planner-Arbeit' "$B"                                              # 1
grep -cE '^\| \*\*[0-9]' "$B"                                                                # 8
grep -c 'Nur 1, 2 und 3b tragen einen Rollenwechsel' "$B"                                    # 1
grep -c 'ist der ganze Abschluss: die Closure-Notiz' AGENTS.md                               # 1
grep -c 'ein berührter Welle-Plan und der' AGENTS.md                                         # 1
grep -c 'Die ersten drei gehören dem \*\*Planner\*\*' docs/plan/adr/0046-*.md                 # 1
grep -c 'sie bestätigt keine fremde Zuordnung und setzt keine neue' docs/plan/adr/0015-*.md  # 1
grep -c 'Eigentum ist eine Eigenschaft des Ablaufs' docs/plan/adr/0028-*.md                  # 1
ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l                                     # 107
```

Alle neun treffen. `$B` löst auf `.harness/baseline/v6.8.0/…` auf. Die acht Tabellenzeilen sind
einzeln gelesen: Schritt 1 **Verifier → Planner**, Schritt 2 und 3b **Planner → Architect →
Planner**, Schritt 3a, 3c, 4, 5, 6 **Planner** — in keiner Zeile ein Implementer. Die tragende
Aussage von Festlegung 1 hält. **Keine Erwartungswerte.**

### Der ausgelegte Satz im Volltext — Auftrag 1

Gelesen an der Quelle (`docs/plan/adr/0046-…`:254–261), inklusive des Vordersatzes, der *„die
ersten drei"* auflöst:

> *„Sie fasst kein fremdes Rollen-Artefakt an. `welle-13`, die Roadmap, der Anweisungssatz zum
> Wellen-Schnitt und der Sensor-Text bekommen Folgepflichten, keinen Schreibzugriff aus diesem
> Lauf. Die ersten drei gehören dem **Planner** — für Welle-Plan und Roadmap nach `v6.7.2`,
> `modul-08-agentenrollen.md` §Rollen-Sequenz für eine Welle (…) und nach `AGENTS.md` §3.10, für
> den Anweisungssatz nach ADR-0028 Festlegung 1."*

Der Satz beruft sich auf **drei** Quellen: `modul-08-agentenrollen.md`,
[`AGENTS.md`](../../AGENTS.md) §3.10 und
[ADR-0028](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Festlegung 1. Das
Zitat in Festlegung 2 der geprüften Datei (:270–273) ist gegen das Original abgeglichen und
vollständig bis zum Satzende; abgetragen sind allein zwei Markdown-Links, was
[ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 2 (*Wortlaut ohne
Auszeichnung*) deckt. **MEDIUM-1 der Vorrunde ist behoben** — siehe Negativbefunde.

### Byte-Gleichheit der drei Kopfnoten und das neue Kennungs-Muster

```sh
T=".harness/baseline/$(grep -m1 '^BASELINE_TAG ?= ' Makefile | cut -d' ' -f3)/templates/docs/plan/planning/welle.template.md"
for f in docs/plan/planning/welle-*.md; do
  diff -q <(sed -n '10,15p' "$T") <(sed -n '3,8p' "$f") >/dev/null && echo "byte-gleich: $f"
done                                                    # eine Zeile: welle-13
for f in docs/plan/planning/welle-*.md; do
  diff <(sed -n '10,15p' "$T") <(sed -n '3,8p' "$f")
done                                                    # zwei Differenzen, je Zeile 3
grep -cE 'welle-[0-9a-zäöü]' <(sed -n '10,15p' "$T")    # 0
```

Alle drei reproduzieren: `welle-13` byte-gleich, `welle-09` und `welle-11` mit je genau einer
Differenz in Zeile 3 (`welle-09-results.md` bzw. `welle-11-results.md` gegen
`welle-<Kennung>-results.md`). Der Ausschnitt der Ziel-Form ist gelesen und trägt allein den
Platzhalter. Das Muster deckt jetzt Nummer **und** Name; **LOW-2 der Vorrunde ist behoben.**

### Rollen-Verteilung, README-Gegenstand, Modul-Liste, Gate

```sh
git log --format='%s' -- 'docs/plan/planning/welle-*.md' | grep -c '^Rolle Planner'     # 56
git log --format='%s' -- 'docs/plan/planning/welle-*.md' | grep -c '^Rolle Implement'   #  7
git grep -nE 'planning/README\.md' -- AGENTS.md harness/ spec/ docs/plan/adr/ .claude/ \
  .harness/skills/ ':!.harness/baseline' ':!docs/reviews' ':!docs/plan/adr/0048-*.md'   # 1
grep -n '^modules:' .d-check.yml   # 29:modules: [links, anchors, ids, matrix, codepaths, spans, planning, targets]
make docs-check                    # d-check: 1318 Datei(en) geprüft, 0 Befund(e)  (Lauf mit dieser Datei)
```

Die eine Stelle über `docs/plan/planning/README.md` ist `harness/migration.md`:116 — eine Zeile des
Instanz-Registers (`README.template.md` → `docs/plan/planning/README.md` | *eine Instanz*) und
keine Rollen-Aussage. `make docs-check` real gefahren, netzlos, gepinnter Digest. **Keine
Erwartungswerte.**

### Commit-Zuschnitt

```sh
git show --pretty=format: --name-only 9ccf81ed
# docs/plan/adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md
# docs/plan/adr/README.md
git log -1 --format='%B%n%an %ae' 9ccf81ed | grep -ci 'co-authored-by\|generated with\|claude code\|anthropic'  # 0
git log -1 --format='%B' 9ccf81ed | grep -ci 'supersedes'                                                       # 0
```

### Herkunft der beanstandeten Formulierung

```sh
git show 2b914403:docs/plan/adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md \
  | grep -c 'projiziert keine Originale'   # 1
git show 2b914403:docs/plan/adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md \
  | grep -c 'Ein Welle-Plan gibt'          # 0  (Exit 1)
```

Der Satz aus MEDIUM-1 unten stand schon am Stand der Vorrunde; der Absatz, der ihm widerspricht,
ist mit `9ccf81ed` hinzugekommen. Festgehalten, damit der Befund nicht falsch als reine Regression
und nicht falsch als reines Altlast-Problem gelesen wird.

---

## Findings

Jedes Finding folgt dem **§Output-Schema des Reviewer-Skills** — der verbindlichen Single Source of
Truth (`v6.8.0` · `regelwerk/modul-10-review-harness.md` §Ziel-Form: Reviewer-Skill).

### MEDIUM-1 — §Konsequenzen sagt, ein Welle-Plan projiziere keine Originale; §Kontext und Bedingung 1/2 derselben Datei sagen über den strittigen Text das Gegenteil

- `kategorie`: **MEDIUM** (die Aussage steht in §Konsequenzen und friert mit dem Accept ein)
- `quelle`: [ADR-0024](../plan/adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md)
  Festlegung 1 (*„**Derivativ** ist eine Eigenschaft der **Aussage**, nicht der Datei"*) ·
  ADR-0048 §Kontext, *Was der strittige Gegenstand ist* · ADR-0048 Festlegung 1, Bedingung 1 und 2
- `pfad`: `docs/plan/adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md`:371–372, gegen
  :199–200, :239–242 und :256–258
- `befund`: Der Genealogie-Punkt schließt mit *„Ein Welle-Plan beschreibt keinen Rollen-Ablauf und
  **projiziert keine Originale**, er plant eine Welle"* — eine Aussage über die **Datei**, vier
  Zeilen nachdem derselbe Punkt zitiert, dass Derivativität eine Eigenschaft der **Aussage** und
  nicht der Datei ist. Über den Text, um den der ganze Vorgang geht, sagt dieselbe Datei zweimal
  das Gegenteil: §Kontext nennt ihn *„eine **Vorlagen-Instanz**, deren Originale die Ziel-Form und
  [ADR-0046](../plan/adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) Festlegung 1 sind"*, und
  der neue Absatz zu Bedingung 1 sagt *„Ein Welle-Plan **gibt** nicht nur seine Vorlage **wieder**,
  sondern auch Regeln, die in `AGENTS.md` oder im Baseline-Regelwerk stehen"*.
- `verifizierbar`: nein — kein Modul aus `modules:` der `.d-check.yml` hält zwei Aussagen derselben
  Datei gegeneinander; die vier Stellen sind oben mit Zeilennummern benannt und gelesen.
- `klasse`: Begründungssatz widerspricht einer Bedingung derselben Datei

**Failure-Szenario.** Der Satz ist die Begründung dafür, dass die dritte Achse **neu** ist und die
zwei vorhandenen für den Welle-Plan nichts liefern. Ein Lauf, der eine künftige Eigentums-Frage an
einem anderen Artefakt entscheidet, liest daraus die Faustregel *„ein Planungs-Artefakt ist
derivativ oder nicht, je nach Dateityp"* — und trifft damit die Unterscheidung auf der Ebene, die
[ADR-0024](../plan/adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md) Festlegung 1
ausdrücklich verwirft. Umgekehrt gilt: Nimmt man die Aussagen-Ebene ernst, ist die `Lifecycle:`-
Kopfnote eine Aussage **mit** Original, die ADR-0024-Achse also anwendbar; **welche Antwort sie für
diesen Text liefert, sagt die Datei nirgends** — die Abwehr geschieht über die Datei-Ebene statt
über die Sache.

**Was den Schaden begrenzt, und warum der Befund trotzdem steht.** Festlegung 1 und 2 sind von
dieser Formulierung nicht abhängig — sie stützen sich auf `modul-08`, [`AGENTS.md`](../../AGENTS.md)
§3.10 und [ADR-0015](../plan/adr/0015-rollen-eigentum-an-norm-artefakten.md), nicht auf die
Genealogie. Der Defekt liegt in einem Abschnitt, der mit dem Accept einfriert und danach nur noch
per Folge-ADR erreichbar ist.

### LOW-1 — Die Genealogie-Formel „das Original, das eine Aussage wiedergibt" kehrt in ihrer nächstliegenden Lesart die Richtung um, die ADR-0024 setzt

- `kategorie`: **LOW** (Doku-Drift in einem einfrierenden Abschnitt)
- `quelle`: [ADR-0024](../plan/adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md)
  Festlegung 1 (*„eine Register-Zeile **gibt** Felder eines Originals **wieder**, und das Original
  muss existieren"*)
- `pfad`: `docs/plan/adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md`:21–22
  (`Bezug:`-Zeile) und :364–365 (§Konsequenzen)
- `befund`: Beide Stellen fassen ADR-0024 als *„die Ableitung aus dem **Original**, das eine Aussage
  wiedergibt"*. Im Original gibt die **Aussage** (die Register-Zeile) das **Original** wieder, nicht
  umgekehrt. Der Relativsatz ist im Deutschen in beide Richtungen lesbar; die nächstliegende
  Subjekt-zuerst-Lesart ist die falsche.
- `verifizierbar`: nein — kein Modul hält eine Zusammenfassung gegen die Festlegung, die sie
  zitiert; beide Sätze sind oben nebeneinandergelegt.
- `klasse`: Wiedergabe einer fremden Festlegung richtungsoffen formuliert

**Failure-Szenario.** Ein Lauf, der die Eigentums-Familie aus ADR-0048 kennenlernt statt aus
ADR-0024, sucht für ein neues Artefakt nach *dem Original, das die fragliche Aussage wiedergibt* —
also nach dem falschen Ende der Kette — und landet bei der Rolle, die das abgeleitete Artefakt
schreibt, statt bei der, die die Quelle schreibt. Dass dieselbe Datei die Richtung in ihrem zweiten
Halbsatz (*„bindende Aussage **ohne** Original"*) korrekt führt, begrenzt den Schaden.

### LOW-2 — Das dritte Fach des Acceptance-Triggers behauptet, seine Aufzählung nenne den heutigen Bestand vollständig; zwei Posten fehlen, und einer davon trägt MEDIUM-1 dieses Reports

- `kategorie`: **LOW** (latente Wartungsfalle; der Trigger-Abschnitt friert ein)
- `quelle`: [ADR-0040](../plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md)
  Festlegung 3 · [`AGENTS.md`](../../AGENTS.md) §3.6 (eine Zusage nennt, was sie bricht)
- `pfad`: `docs/plan/adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md`:494–499
- `befund`: Nach der Kennzeichnung (*„jedem Abschnitt, der mit dem Accept einfriert, ohne eine
  Festlegung zu tragen"*) steht *„die Aufzählung darunter nennt den heutigen Bestand vollständig
  und ist keine Verengung"*. Sie nennt für §Konsequenzen aber nur *„die Folgepflichten und
  Feststellungen"* — die zwei `Positiv:`- und drei `Negativ:`-Punkte desselben Abschnitts stehen
  nicht darin, und MEDIUM-1 dieses Reports liegt in einem `Positiv:`-Punkt. Ebenfalls nicht genannt
  sind die Kopffelder `Bezug:`, `Schärft:` und `Regeln:`, die gleichfalls einfrieren und keine
  Festlegung tragen; LOW-1 dieses Reports liegt zur Hälfte dort.
- `verifizierbar`: nein — kein Modul liest einen Acceptance-Trigger; die Punkte von §Konsequenzen
  sind gezählt (2 × `Positiv:`, 3 × `Negativ:`, 1 × `Feststellung`, 4 × `Folgepflicht`).
- `klasse`: Vollständigkeits-Behauptung über die eigene Aufzählung

**Warum LOW und nicht höher.** Die Fach-**Zuordnung** funktioniert trotzdem: Der Absatz sagt
ausdrücklich *„Das ist die Kennzeichnung, und sie trägt"*, und die Kennzeichnung deckt beide
Fundorte. Defekt ist allein die Vollständigkeits-Zusage daneben. Sie ist die Fortsetzung von LOW-4
der Vorrunde in geänderter Gestalt — dort war die Aufzählung enger als die Kennzeichnung *ohne*
Vorrang-Regel, hier ist die Vorrang-Regel da und die Zusage über die Aufzählung falsch. **Zweites
Auftreten derselben Familie am selben Abschnitt.**

### INFO-1 — Der Acceptance-Trigger ist zwischen Runde 2 und dieser Runde unverändert

- `kategorie`: **INFO**
- `quelle`: [ADR-0040](../plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md)
  Festlegung 2 und 3 · ADR-0048 §Der Acceptance-Trigger (*„Der Preis steht daneben"*)
- `pfad`: `docs/plan/adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md`:481–519
- `befund`: Die Vorrunde hielt fest, dass ihr Maßstab gegenüber Runde 1 gewachsen war (INFO-2
  dort). Für diese Runde gilt das nicht: Der Diff `2b914403 → 9ccf81ed` berührt §Der
  Acceptance-Trigger nur redaktionell — die Kennzeichnung des dritten Fachs wird zur
  Vorrang-Regel und die Aufzählung um vier Posten ergänzt; die **Grenze** zwischen blockierend und
  nicht blockierend (Substanz der beiden Festlegungen) steht wörtlich wie zuvor. Das Verdikt unten
  misst damit gegen denselben Maßstab wie das der Vorrunde.
- `verifizierbar`: nein — der Diff des Abschnitts ist gelesen.
- `klasse`: Maßstab zwischen zwei Runden stabil

### INFO-2 — Die Datei trägt eine Folgepflicht, deren Adressat sie nicht schneiden darf, und drei weitere ohne Lifecycle-Adresse

- `kategorie`: **INFO** (dokumentationswürdige, bewusst getroffene Annahme)
- `quelle`: `v6.8.0` · `regelwerk/modul-08-agentenrollen.md` §Konflikt-Pfad als Rollen-Sequenz
  (Übergabe-Artefakt *„Folge-ADR + Erinnerungs-Slice in `next/`"*, an der Quelle gelesen) ·
  [`AGENTS.md`](../../AGENTS.md) §3.10
- `pfad`: `docs/plan/adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md`:401–431
- `befund`: MEDIUM-4 der Vorrunde ist behoben — die zweite Hälfte des Übergabe-Artefakts steht
  jetzt als benannte Folgepflicht an den Planner, mit der Begründung, warum der Architect sie nicht
  selbst schneidet. Bis der Planner sie aufnimmt, bleibt die Lage aber unverändert: `ls
  docs/plan/planning/next/` führt **sechs** Slices, keinen zu diesem Vorgang, und die drei übrigen
  Folgepflichten sind weiter *„fällig als eigener Vorgang"* ohne Adresse. Das ist die korrekte
  Rollen-Grenze und kein Defekt der Datei — festgehalten, weil es nach dem Accept einfriert und
  dann nur noch am Gedächtnis hängt.
- `verifizierbar`: ja — teilweise: `ls docs/plan/planning/next/` ist reproduzierbar, die Existenz
  eines künftigen Slice ist es nicht.
- `klasse`: Folgepflicht ohne Lifecycle-Adresse, Rollen-Grenze korrekt gezogen

---

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| **Auftrag 1a — zählt Festlegung 2 jetzt drei Quellen?** | geprüft, ohne Befund — **ja.** §Kontext (*„er beruft sich auf **drei** Quellen"*, Abschnittstitel jetzt ohne Zahl) und Festlegung 2 (*„er leitet ab — und zwar aus **drei** Quellen"*) stimmen überein. Ich habe den ausgelegten Satz an ADR-0046 selbst gezählt: `modul-08-agentenrollen.md`, `AGENTS.md` §3.10, ADR-0028 Festlegung 1 — drei. **MEDIUM-1 der Vorrunde ist behoben.** |
| **Auftrag 1b — steht der Satz im vollen Wortlaut?** | geprüft, ohne Befund — **ja.** Das Blockzitat :270–273 ist Zeichen für Zeichen gegen `docs/plan/adr/0046-…`:256–261 gehalten und reicht bis zum Satzende (*„… nach ADR-0028 Festlegung 1."*). Abgetragen sind nur die zwei Markdown-Links; [ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 2 deckt das (*Wortlaut ohne Auszeichnung*). Die Kürzung, die die Vorrunde beanstandete, ist weg. |
| **Auftrag 1c — Zuordnung einzeln statt universell über „jene Quellen"?** | geprüft, ohne Befund — **ja.** Der Rumpf sagt *„was **die ihm zugeordnete** Quelle ihm zuweist"* und löst die Zuordnung im selben Satz auf: *„`welle-13` und die Roadmap über die ersten zwei Quellen, der Anweisungssatz zum Wellen-Schnitt über ADR-0028 Festlegung 1"*. Die universelle Quantifikation über *„jene Quellen"* ist entfallen. **Ausdrücklich geprüft und kein Finding:** der Numerus (*„die ihm zugeordnete Quelle"*, Singular) passt für zwei der drei Artefakte nicht, die je **zwei** Quellen tragen — die Auflösung im selben Satz nennt sie korrekt (*„die ersten zwei Quellen"*), damit ist keine Fehllesart möglich, und ein Finding daraus wäre Stil-Polizei ohne Failure-Szenario. |
| **Auftrag 2 — nimmt die Datei `.claude/commands/plan-welle.md` namentlich aus?** | geprüft, ohne Befund — **ja**, als eigener Punkt in §Was diese Entscheidung nicht tut (:314–319), mit [ADR-0028](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Festlegung 1 als der unabhängig bindenden Quelle, mit der Feststellung *„Er ist kein Welle-Plan, die Probe aus Festlegung 1 greift für ihn nicht"* und mit dem Rückbezug auf Festlegung 2. Nachgemessen: ADR-0028 Festlegung 1 führt die Datei in ihrer Anwendungstabelle mit der Rolle **Planner** und dem Beleg *Eröffnungssatz*; `.claude/commands/plan-welle.md`:5 lautet tatsächlich *„Dieser Command führt die **Planner**-Rolle für *eine* Welle"*. Die Aussage der ADR trifft an beiden Enden. |
| **Auftrag 3 — MEDIUM-2 der Vorrunde (Feststellung zu `docs/plan/planning/README.md`)** | geprüft, **behoben** — die Feststellung steht jetzt neben einer Suche, die **diese Datei** zum Gegenstand hat (**1** Treffer, `harness/migration.md`:116, in diesem Lauf gefahren), und die Folgerung ist ausdrücklich auf *„dass dieser Lauf keine Zuweisung gefunden hat, nicht, dass es keine gibt"* zurückgenommen, mit [`MR-055`](../../harness/conventions.md#mr-055--eine-stellen-messung-trägt-keine-folgerung-über-eine-eigenschaft) daneben. Der Rückgriff auf die Welle-Plan-Messung, der leer wahr war, ist entfernt. |
| **Auftrag 3 — MEDIUM-3 der Vorrunde (ADR-0024-Achse)** | geprüft, **an der beanstandeten Stelle behoben** — die Zuschreibung *„beides Eigenschaften des Artefakts, stabil über seine Änderungen"* ist weg; ADR-0024 wird jetzt auf ihrer eigenen Achse gelesen (Ableitung aus dem Original, endend bei einer bindenden Aussage ohne Original), und die `Bezug:`-Zeile sagt dasselbe. Zwei Rest-Einwände an derselben Passage stehen als MEDIUM-1 und LOW-1 dieses Reports. |
| **Auftrag 3 — MEDIUM-4 der Vorrunde (zweite Hälfte des Übergabe-Artefakts)** | geprüft, **behoben** — §Konsequenzen führt eine eigene *Folgepflicht (Planner)*, die das Verdikt, seine zweiteilige Übergabe und die Rollen-Grenze benennt; das Baseline-Zitat *„Folge-ADR + Erinnerungs-Slice in `next/`"* ist an `v6.8.0` · `regelwerk/modul-08-agentenrollen.md`:213 nachgelesen und trifft wörtlich. Zur verbleibenden Lage: INFO-2. |
| **Auftrag 3 — LOW-1 der Vorrunde (Eröffnungs-Zahl)** | geprüft, **behoben** — der Einleitungssatz lautet jetzt *„Im Prüfbereich des Kommandos unten …"* und benennt die Grenze ausdrücklich (*„fünf Pfade breit und **nicht** das Repo — `docs/plan/planning/**`, `docs/user/`, `README.md` und `internal/` erreicht er nicht"*). Nachgezählt: das Kommando führt genau fünf positive Pfade. |
| **Auftrag 3 — LOW-2 der Vorrunde (Kennungs-Form)** | geprüft, **behoben** — das Muster ist `welle-[0-9a-zäöü]` und deckt damit die Namens-Form aus [`MR-057`](../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer) mit; die Prosa sagt es (*„trifft beide Kennungs-Formen, die Nummer wie den Namen"*), und MR-057 ist in die `Bezug:`-Zeile aufgenommen. In diesem Lauf gefahren: **0**, wie abgedruckt. |
| **Auftrag 3 — LOW-3 der Vorrunde (Re-Evaluierungs-Trigger 4)** | geprüft, **behoben** — die Klausel zeigt jetzt auf *„die drei `grep -c`-Kommandos des `modul-08`-Blocks in §Kontext — §Was die zitierten Quellen binden"*. Nachgezählt: dieser Block führt genau drei Kommandos (zwei `grep -c`, eines `grep -cE`); die Menge ist damit eindeutig adressiert. |
| **Auftrag 3 — LOW-4 der Vorrunde (drittes Fach)** | geprüft, **teilweise behoben** — die Kennzeichnung ist jetzt ausdrücklich die tragende Regel (*„Das ist die Kennzeichnung, und sie trägt"*), und die Aufzählung ist um §Verglichene Alternativen, §Was diese Entscheidung nicht tut, den Trigger-Abschnitt selbst und §Geschichte gewachsen — damit fällt MEDIUM-4 der Vorrunde, der Anlass, jetzt unter einen benannten Posten. Der Rest steht als LOW-2 dieses Reports. |
| **Auftrag 3 — LOW-5 der Vorrunde (Baseline-Aussage ohne Tag)** | geprüft, **behoben** — §Der Anlass:72 führt jetzt *„Baseline `v6.8.0`, `modul-08-agentenrollen.md` §Konflikt-Pfad als Rollen-Sequenz"*. **Ausdrücklich geprüft und kein Finding:** die zwei verbliebenen `modul-04-adrs.md`-Nennungen ohne Tag (:293, :531) sind **wörtliche Vorlagen-Instanzen** aus `templates/docs/plan/adr/NNNN-titel.template.md` (§Verglichene Alternativen-Vorspann und der Schlusssatz nach §Geschichte, beide dort verglichen); [`MR-033`](../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist) Setzung 2 bindet die *Aussage über die Baseline*, nicht die Wiedergabe der eigenen Ziel-Form, und das Kopffeld `Regeln:` trägt den Zeiger einmal. Ebenso kein Finding: *„Regeln, die … im Baseline-Regelwerk stehen"* (:258) nennt weder Modul noch Abschnitt und ist eine Kategorie-Nennung, keine Messaussage. |
| **Auftrag 3 — LOW-6 der Vorrunde (MR-025 vs. MR-051)** | geprüft, **behoben** — der Register-Umfang beruft sich jetzt auf [`MR-051`](../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung) Setzung 2 und nennt MR-025 als die Fassung, die die Klasse *„nach eigener Kopf-Marke nicht erreicht"*; MR-051 steht in der `Bezug:`-Zeile und in der Index-Zelle. Beide Einträge sind in diesem Lauf gelesen: MR-051 §Geltungsbereich nennt den außerhalb des Registers zitierten Zähler-Stand namentlich, MR-025 trägt die Kopf-Marke `ÜBERHOLT … → MR-051`. Der Zähler selbst ist gefahren: **107**. |
| **Auftrag 3 — INFO-1 der Vorrunde (Breite von Bedingung 1)** | geprüft, **eingearbeitet** — Festlegung 1 trägt jetzt einen eigenen Absatz *„Warum Bedingung 1 neben der Ziel-Form auch eine kanonische Quelle zulässt"*, der den Bedarf benennt und die Eingrenzung durch Bedingung 2 ausspricht. Der Absatz ist zugleich eine der Stellen, die MEDIUM-1 dieses Reports trägt. |
| **Auftrag 4 — neue Inkonsistenzen durch die Fixes** | geprüft, **ein Befund**: MEDIUM-1. Der beanstandete Satz selbst ist Altbestand (an `2b914403` nachgemessen), der ihm widersprechende Absatz zu Bedingung 1 ist mit `9ccf81ed` entstanden — die Kollision ist neu. Sonst: keine der neun übrigen Änderungen erzeugt einen Widerspruch, den ich finden konnte; Abschnittstitel, Rumpf, `Bezug:`-Zeile und Index-Zelle sind einzeln gegeneinander gehalten. |
| Braucht ADR-0048 ein `Supersedes` auf ADR-0046? | geprüft, ohne Befund — **nein**, unverändert gegenüber beiden Vorrunden. Der ausgelegte Satz steht in einer **Abgrenzungs**-Sektion, nicht in §Entscheidung; beide Festlegungen von ADR-0046 gelten wörtlich fort; `docs/plan/adr/0046-*.md` ist nicht im Diff (`git show --stat 9ccf81ed` führt zwei Dateien) und trägt `Status: Accepted` ohne `Superseded by`. Option C hält die Gegenposition. Die Commit-Message führt **0** Treffer für `supersedes`. |
| ADR-0015 Festlegung 1 und §Was hier NICHT entschieden ist | geprüft, ohne Befund — ADR-0048 stützt sich auf die dort ausdrücklich offengelassene Frage (*„sie bestätigt keine fremde Zuordnung und setzt keine neue"*, in diesem Lauf zitiert), bestätigt keine fremde Zuordnung und verengt sich nach demselben Muster (*„für jeden Vorgang, der unter keine von ihnen fällt, bleibt die Frage offen"*). |
| ADR-0028 Festlegung 1, 2 und 3 | geprüft, ohne Befund — Festlegung 1 ist korrekt als *andere Achse* abgesetzt (Ablauf, den das Artefakt **beschreibt**) und zusätzlich korrekt als **dritte Quelle** des ausgelegten Satzes geführt; Festlegung 3 (`.claude/agents/*.md` ausgenommen) wird für die Einordnung von `.claude/agents/planner.md` richtig herangezogen; Festlegung 2 (bindende Aussage ohne Original bleibt offen) wird nicht überdehnt. |
| ADR-0031 Option F — trägt die Charakterisierung? | geprüft, ohne Befund — nachgemessen: `Status: Proposed`, die Zeile :206 steht in der **Contra**-Spalte einer Option und beruft sich auf ADR-0015, deren Festlegung 1 die Aussage nicht trägt. Die ADR nennt die Stelle *„ein Befund, keine Quelle"* und hält sie als Folgepflicht fest, ohne sie zu beheben — korrekt, weil jene Datei fremdes Eigentum in einem anderen Vorgang ist. |
| ADR-0040 Festlegung 1, 2 und 3 | geprüft, ohne Befund — der Trigger verlangt eine Runde der prüfenden Rolle; nach dem blockierenden Verdikt der Vorrunde ist **diese** Runde die nächste derselben Rolle (Festlegung 2). Die Trigger-Schärfung im Vorgänger-Commit war von Festlegung 3 gedeckt, solange die Datei `Proposed` ist; in diesem Commit ist die Grenze zwischen den Fächern unverändert (INFO-1). Die Accept-Zeile der §Geschichte hat den Bericht als **Kennung** zu nennen (Festlegung 1) — die Datei sagt das selbst. |
| ADR-0016 Festlegung 2 (*verbatim*) | geprüft, ohne Befund — das neue Blockzitat aus ADR-0046 ist vollständig, die hinzugefügte Fett-Auszeichnung und die abgetragenen Links sind von *„Wortlaut ohne Auszeichnung, Whitespace normalisiert"* gedeckt. Das Zitat aus ADR-0024 (*„Derivativ ist eine Eigenschaft der Aussage, nicht der Datei"*) trifft die Quelle ebenfalls wörtlich; der Einwand aus LOW-1 betrifft den **Rahmensatz**, nicht das Zitat. |
| Referenz auf eine superseded ADR | geprüft, ohne Befund — alle acht referenzierten ADRs einzeln geprüft: 0015, 0016, 0024, 0028, 0030, 0040, 0046 `Accepted`, 0031 `Proposed`; **0** Treffer für `Superseded` in allen acht Dateien. |
| MADR-Ziel-Form (`v6.8.0` · `regelwerk/modul-04-adrs.md` §Ziel-Form: ADR (MADR)) | geprüft, ohne Befund — gegen `templates/docs/plan/adr/NNNN-titel.template.md` gehalten: Kopffelder `Status` · `Datum` · `Autor` · `Bezug` · `Schärft` · `Regeln` alle vorhanden und in der Reihenfolge der Vorlage; die sieben Abschnitte `Kontext` · `Entscheidung` · `Verglichene Alternativen` · `Konsequenzen` · `Fitness Function (falls maschinell prüfbar)` · `Re-Evaluierungs-Trigger` · `Geschichte` vorhanden und in der Reihenfolge der Vorlage. `Schärft: —` ist die Vorlagen-Form für eine Prozess-ADR ohne Spec-Stratum. Ein `Supersedes:`-Feld führt die Vorlage nicht. |
| Mindestens drei Alternativen mit Pro/Contra | geprüft, ohne Befund — **fünf** (A *nichts tun* · B Datei-Lesart · C `Supersedes` · E breite Fassung · **D gewählt**), jede mit Pro **und** Contra; die gewählte steht fett und zuletzt wie in der Vorlage. |
| Re-Evaluierungs-Trigger — vorhanden und beobachtbar | geprüft, ohne Befund — fünf Trigger, jeder mit Beobachtbarkeits-Klausel in Klammern; Trigger 1 hängt ausdrücklich nicht an einer Trefferzahl, Trigger 4 adressiert seine Kommando-Menge jetzt eindeutig. |
| [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) — wird ein Gate behauptet? | geprüft, ohne Befund — §Fitness Function sagt für **beide** Festlegungen *„keinen Wächter"*, nennt den Grund und markiert die eine beobachtbare Hälfte (`git log --stat`) ausdrücklich als **kein Gate**. Genannt sind `make mutate` und die `.d-check.yml`-Modul-Liste; beide existieren (`grep -cE '^mutate:' Makefile` → **1**, `grep -n '^modules:' .d-check.yml` → Zeile 29). Kein Target wird behauptet, das das Makefile nicht führt. |
| [`AGENTS.md`](../../AGENTS.md) §3.11 — bewegte Adresse in einem einfrierenden Artefakt | geprüft, ohne Befund — alle 22 Link-Ziele der Datei aufgelistet und einzeln eingeordnet: ADR-Dateien (ortsfest), `AGENTS.md`, `harness/conventions.md`, `spec/lastenheft.md`, `.d-check.yml`, `docs/plan/planning/README.md`, `.claude/agents/planner.md`, **neu** `.claude/commands/plan-welle.md` — alles stehende Ablagen — und ein Verzeichnis des Beobachtungs-Registers ([ADR-0034](../plan/adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md) Festlegung 5). Jeder Code-Span mit `docs/plan/planning` oder `done/` ist geprüft: Glob (`welle-*.md`), Verzeichnis (`done/`, `docs/plan/planning/**`), stehende Datei (`README.md`) oder Kommando-Text. Slice-, Welle- und Report-Kennungen stehen als **Kennung** ohne Pfad. |
| [`AGENTS.md`](../../AGENTS.md) §3.7 — Chronik, Konjunktiv, Befund-Kennung | geprüft, ohne Befund — die Datei ist weder Code/Konfiguration/Skript noch das Zustandsfeld eines lebenden Registers und fällt nicht in den Geltungsbereich. Unabhängig davon: der Anlass steht im Indikativ, verworfene Optionen stehen in der dafür vorgesehenen Tabelle, und die Herkunft steht als **ein** auflösbares Feld (§Geschichte). §Geschichte misst **3343** von **44021** Bytes (7,6 %, `wc -c` über die Datei und über `sed -n '/^## Geschichte/,$p'`, keine Erwartungswerte) — keine Chronik-Dominanz. |
| [`AGENTS.md`](../../AGENTS.md) §3.6 — Zusage mit benanntem Gegenbeispiel | geprüft, ohne Befund — die Datei behauptet für keine ihrer zwei Festlegungen einen Wächter, markiert die Urteilshälften der Probe als *„Urteil und kein Muster"*, kennzeichnet die Einordnung von `.claude/agents/planner.md` ausdrücklich als *„ein Urteil über eine Stelle, kein Messergebnis"* und führt in Re-Evaluierungs-Trigger 2 den beobachtbaren Fall, der die Probe widerlegte. |
| [`AGENTS.md`](../../AGENTS.md) §3.5 / §3.4 / §3.3 | geprüft, ohne Befund — §3.5: §Was diese Entscheidung nicht tut stellt fest, dass keine Schwelle, kein Modul, keine Gate-Strenge bewegt wird. §3.4: ADR-0046 ist nicht im Diff und unverändert; die eigene Immutabilitäts-Folge nach dem Accept ist benannt. §3.3: der Commit enthält keine Umbenennung. |
| [`AGENTS.md`](../../AGENTS.md) §3.8 — Commit-Zuschnitt und schreibende Rolle | geprüft, ohne Befund — `git show --stat 9ccf81ed`: **zwei** Dateien, die ADR und der ADR-Index, der ihr nach [ADR-0024](../plan/adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md) folgt; Subject nennt *„Rolle Architect"*; die Message führt `Bezug: ADR-0048, ADR-0046, ADR-0015, ADR-0028, ADR-0024, LH-QA-01`; **0** Treffer für `co-authored-by\|generated with\|claude code\|anthropic`. Keine Messzahl in der Message (die Zählwörter *„drei Quellen"*, *„zwei"* sind Lesungen eines zitierten Satzes, kein Kommando-Ergebnis), also keine offene Beleg-Pflicht nach [`MR-051`](../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung) Setzung 1. |
| [`AGENTS.md`](../../AGENTS.md) §3.10 — Abschluss nicht im ausführenden Lauf | geprüft, ohne Befund — im Diff liegt kein Closure- und kein Register-Artefakt; §Was diese Entscheidung nicht tut und zwei Folgepflichten verweisen Register-Route und Erinnerungs-Slice ausdrücklich an den Planner. |
| ADR-Index-Zeile (derivativ nach [ADR-0024](../plan/adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md)) | geprüft, ohne Befund — vier Spalten; `Titel` wörtlich aus der `# `-Überschrift ohne Präfix; `Status` `Proposed` aus dem Kopffeld; `Bezug` vollständig und in **derselben Reihenfolge** wie die `**Bezug:**`-Zeile, inklusive der zwei neuen Einträge MR-051 und MR-057 — einzeln abgeglichen. Der Index-Diff berührt genau diese eine Zeile. Die Index-Konventionen verlangen die volle Spiegelung; kein Sensor hält sie, die Prüfung ist von Hand gefahren. |
| [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) — Zahl neben ihrem Kommando | geprüft, ohne Befund — jede Messzahl der Datei ist in diesem Lauf gefahren und trifft (3 · 8 · 1 · 1 · 1 · 1 · 1 · 1 · 4 · 1 · 56 · 7 · 0 · 107); alle sind als *kein Erwartungswert* gekennzeichnet. Das `# 3` neben `grep -n 'Schreibt Pläne' …` ist eine **Zeilennummer**, kein Messwert, und die Prosa liest es korrekt als Fundstelle. |
| [`MR-055`](../../harness/conventions.md#mr-055--eine-stellen-messung-trägt-keine-folgerung-über-eine-eigenschaft) und [`MR-058`](../../harness/conventions.md#mr-058--eine-messung-die-ihr-eigener-vorgang-bewegt-wird-nach-dem-vorgang-genommen) | geprüft, ohne Befund — beide Einträge in diesem Lauf gelesen: beide nehmen `docs/plan/adr/` vom Geltungsbereich aus, und die `Bezug:`-Zeile sagt das jetzt für **beide** (bei MR-055 neu). Die Datei wendet sie als Selbstbindung an, was zulässig ist; die zwei Stellen-Messungen tragen ihre Grenze ausdrücklich. |
| Konflikt-Pfad: ist das gewählte Verdikt eines der drei zulässigen? | geprüft, ohne Befund — *„Lockerung legitim, aber undokumentiert"* ist Zeile 3 der Verdikt-Tabelle in `v6.8.0` · `regelwerk/modul-08-agentenrollen.md`, an der Quelle gelesen; §Was diese Entscheidung nicht tut schließt das Herabstufen ausdrücklich aus, und F-1 der auslösenden Runde bleibt HIGH. |
| Cutoff und Geltungsbereich | geprüft, ohne Befund — *„ab der Annahme dieser Entscheidung, kein Nachrüsten"* mit derselben Begründung wie ADR-0015/ADR-0024, und *„Geltungsbereich: dieses Repo"* mit Verweis der emittierten Ebene an den Tool-Slice. |
| §Geschichte — dritte Zeile gegen den Vorgänger-Report | geprüft, ohne Befund — die Zeile beschreibt den Befund der Vorrunde (zwei statt drei Quellen, Quantifikation über alle genannten Artefakte) und die Behebungen sachlich richtig; ich habe sie Punkt für Punkt gegen `2026-09-14-adr-0048-konsistenzrunde-2` und gegen den Diff gehalten. |
| Links, Anker, IDs, Spans über den Diff | geprüft, ohne Befund — `make docs-check` zweimal real gefahren — vor und nach dem Schreiben dieses Reports; der Lauf, den ein Leser am Commit dieses Reports wiederholt, meldet **1318** Dateien, **0** Befunde (der Lauf davor, ohne diese Datei: **1317**/**0**), Module `links`/`anchors`/`ids`/`matrix`/`codepaths`/`spans`/`planning`/`targets`, netzlos (`--network none`), gepinnter Digest. Kein Erwartungswert. |
| Out-of-Scope: die vier Träger des auslösenden Commits | geprüft, ohne Befund — nicht im Diff; ihre Prüfung liegt beim auslösenden Report. |
| Out-of-Scope: Produkt-Code, Gate-Konfiguration, emittierte Ebene | geprüft, ohne Befund — `internal/`, `cmd/`, `harness/tools/`, `.d-check.yml`, `internal/emit/templates/` sind unberührt. |
| Out-of-Scope: DoD-/Spec-Konformität | nicht geprüft — Verifier-Aufgabe (Modul 11), anderer Eingabe-Kontext. |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 1 |
| LOW | 2 |
| INFO | 2 |

**Finding-Klassen dieses Laufs:** Begründungssatz widerspricht einer Bedingung derselben Datei ·
Wiedergabe einer fremden Festlegung richtungsoffen formuliert · Vollständigkeits-Behauptung über
die eigene Aufzählung · Maßstab zwischen zwei Runden stabil · Folgepflicht ohne Lifecycle-Adresse,
Rollen-Grenze korrekt gezogen

*MEDIUM-1 und LOW-1 liegen in derselben Passage und stammen aus demselben Vorgang; für den Zähler
ist das **eine** Gelegenheit (`v6.8.0` · `regelwerk/modul-06-roadmap.md` §Das Beobachtungs-Register:
„Zwei Funde im selben Vorgang sind eine Gelegenheit"). LOW-2 trägt eine Klasse, die am selben
Abschnitt zum **zweiten** Mal auftritt (Vorrunde LOW-4) — der Zähler zählt sie trotzdem einmal je
Vorgang.*

## Verdikt

**NICHT blockierend.** Das ist ausdrücklich gesagt, weil es der Beleg ist, den
§Der Acceptance-Trigger für den Umschlag auf `Accepted` verlangt: Diese Runde hat die Datei gegen
[ADR-0015](../plan/adr/0015-rollen-eigentum-an-norm-artefakten.md),
[ADR-0028](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) und
[ADR-0046](../plan/adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) auf Konsistenz geprüft, und
**kein Befund liegt an der Substanz der beiden Festlegungen.**

**1. Die Kern-These beider Festlegungen ist bestätigt — zum dritten Mal und unabhängig.** Die
Lücke, die Festlegung 1 schließt, ist in diesem Lauf neu gemessen: `v6.8.0` ·
`regelwerk/modul-08-agentenrollen.md` weist die **Eröffnung** dem Planner zu und führt die Closure
als Schritt-Tabelle (acht Zeilen, einzeln gelesen — Verifier in Schritt 1, Architect in 2 und 3b,
sonst Planner, in keiner Zeile der Implementer); [`AGENTS.md`](../../AGENTS.md) §3.10 bindet den
**Abschluss**. Eine Text-Änderung an einem bereits eröffneten Welle-Plan fällt zwischen beide, und
[ADR-0015](../plan/adr/0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1 lässt genau das
offen. Festlegung 2 trägt ebenfalls: Der ausgelegte Satz steht in einer **Abgrenzungs**-Sektion,
ist ableitend gebaut, nennt drei Quellen und setzt keine eigene Zuweisung. *Ein `Supersedes` auf
[ADR-0046](../plan/adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) ist nicht erforderlich.*

**2. Der blockierende Befund der Vorrunde ist behoben — nachgemessen, nicht abgehakt.** Ich habe
den ausgelegten Satz an seiner Quelle selbst gezählt: drei Quellen. Festlegung 2 zählt jetzt drei,
führt den Satz bis zum Satzende im Wortlaut, ordnet `welle-13` und der Roadmap die ersten zwei
Quellen zu und dem Anweisungssatz
[ADR-0028](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Festlegung 1, und
§Was diese Entscheidung nicht tut nimmt `.claude/commands/plan-welle.md` namentlich aus — mit
derselben Quelle, an beiden Enden nachgelesen. Auch die drei übrigen MEDIUM und die sechs LOW der
Vorrunde sind eingearbeitet; fünf davon habe ich durch eigene Messung bestätigt, die übrigen durch
Lektüre der geänderten Stelle.

**3. Was offen ist, liegt im dritten Fach und blockiert nach dem eigenen Trigger nicht.** MEDIUM-1
liegt in einem `Positiv:`-Punkt von §Konsequenzen, LOW-1 in derselben Passage und in der
`Bezug:`-Zeile, LOW-2 im Trigger-Abschnitt. Keiner dieser Orte trägt eine Festlegung, und keine der
drei Behebungen würde Festlegung 1 oder 2 ändern — damit greift die Kennzeichnung des dritten
Fachs (*„jedem Abschnitt, der mit dem Accept einfriert, ohne eine Festlegung zu tragen"*) für alle
drei, auch für die zwei, die seine Aufzählung nicht nennt (das ist LOW-2, wieder an einem realen
Fall).

**4. Trotzdem: alle drei frieren mit dem Accept ein.** Danach sind sie nach
[`AGENTS.md`](../../AGENTS.md) §3.4 nur noch per Folge-ADR mit `Supersedes ADR-0048` erreichbar —
die Datei sagt das selbst. Der teuerste davon ist MEDIUM-1: Er steht an der Stelle, an der die
Datei ihre eigene Neuheit begründet, und er widerspricht der Bedingung, auf der ihre Probe ruht.
Ob er vor dem Umschlag behoben wird, entscheidet der Architect; **der Befund hindert den Umschlag
nicht.**

**Keine weitere Runde ist für den Accept nötig.** Wird einer der drei Befunde vor dem Umschlag
behoben, bleibt **dieser** Report der Beleg: §Der Acceptance-Trigger sagt für das dritte Fach
ausdrücklich *„Auch ein Befund dort wird behoben, solange die Datei `Proposed` ist, und hindert die
Annahme nicht"*, und
[ADR-0040](../plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 2
verlangt eine neue Runde nur **nach einem blockierenden Verdikt**. Dieses Verdikt ist keines.

**Übergabe:** Die Findings gehen an den **Architect**, der die Datei hält. Die **Finding-Klassen**
gehen zusätzlich in die Slice-Closure §7 und von dort in den Zähler — die Zuordnung zu einer
vorhandenen oder neuen Kennung trifft die Closure und gehört dem Planner
([`AGENTS.md`](../../AGENTS.md) §3.10), nicht diesem Report. Dieser Report selbst ist ein
**Lauf-Beleg** (Audit: dieser Stand, dieser Skill, dieses Modell, dieses Verdikt) — er wird über
Läufe hinweg nicht wieder gelesen. Der Report ersetzt keine Verifikation — DoD-/Spec-Konformität
prüft der Verifier separat (Modul 11; anderes Prüf-Artefakt, anderer Eingabe-Kontext).
