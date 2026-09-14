# Review-Report — ADR-0048, Konsistenzrunde 2

**Review-Art:** ADR-Konsistenzrunde (kein Slice-Review). Gegenstand ist eine einzelne Entscheidung
im Status `Proposed`, geprüft gegen die Quellen, die ihr eigener Acceptance-Trigger nennt.

**Datum:** 2026-09-14 · **Rolle:** Reviewer · **Kontext:** frisch und unabhängig — kein Anteil an
der Entstehung oder Überarbeitung der geprüften Datei, kein Anteil am Vorgänger-Report. Jede Zahl
unten ist in diesem Lauf selbst erhoben; keine ist aus der ADR, aus der Commit-Message oder aus dem
Vorgänger-Report übernommen.

**Gegenstand:** [`docs/plan/adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md`](../plan/adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md)
· **Status bei Prüfung:** `Proposed` · **Stand:** `2b914403` (HEAD, `main`), `git status --porcelain`
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

- Der Diff `2b914403` (ADR-Datei + Index-Zeile) und seine Commit-Message; zum Vergleich der
  Vorgänger-Stand `ea3a41b8`
- [ADR-0015](../plan/adr/0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1, 2,
  §Was hier NICHT entschieden ist ·
  [ADR-0028](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Festlegung 1, 2, 3 ·
  [ADR-0046](../plan/adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) Festlegung 1, 2,
  §Was diese Entscheidung nicht tut, §Konsequenzen (alle fünf Folgepflichten), §Der Acceptance-Trigger
- Die weiteren in der `Bezug:`-Zeile geführten ADRs:
  [ADR-0024](../plan/adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md) Festlegung 1/2 ·
  [ADR-0040](../plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 1/2/3 ·
  [ADR-0030](../plan/adr/0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) ·
  [ADR-0031](../plan/adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) (`Proposed`) ·
  [ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 2 ·
  [ADR-0034](../plan/adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
  Festlegung 5
- [`AGENTS.md`](../../AGENTS.md) §3 (Hard Rules; tragend hier §3.3, §3.4, §3.5, §3.6, §3.7, §3.8,
  §3.10, §3.11) · [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
- [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) ·
  [`MR-033`](../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist) ·
  [`MR-051`](../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung) ·
  [`MR-055`](../../harness/conventions.md#mr-055--eine-stellen-messung-trägt-keine-folgerung-über-eine-eigenschaft) ·
  [`MR-057`](../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer) ·
  [`MR-058`](../../harness/conventions.md#mr-058--eine-messung-die-ihr-eigener-vorgang-bewegt-wird-nach-dem-vorgang-genommen)
- Baseline `v6.8.0` · `regelwerk/modul-04-adrs.md` §Ziel-Form: ADR (MADR) ·
  `regelwerk/modul-08-agentenrollen.md` §Rollen-Sequenz für eine Welle, §Konflikt-Pfad als
  Rollen-Sequenz · `templates/docs/plan/adr/NNNN-titel.template.md` ·
  `templates/docs/plan/planning/welle.template.md`
- Vorherige Findings am gleichen Gegenstand: `2026-09-14-adr-0048-konsistenzrunde` (die Runde, deren
  blockierendes Verdikt die Überarbeitung auslöste) und
  `2026-09-14-slice-flache-welle-ist-eroeffnet-nicht-geplant` (F-1 HIGH ist der ursprüngliche
  Auslöser)

**Rollen-Grenze:** Diese Runde ändert an der geprüften Datei nichts. Alle Sonden sind lesend; ein
Docker-Ziel ist gefahren (`make docs-check`), `make gates` fährt der Auftraggeber
([`AGENTS.md`](../../AGENTS.md) §3.9).

---

## Eigene Messungen

### Die Messung aus §Kontext — Auftrag 1, und sie trägt jetzt

```sh
git grep -nE 'Welle-Plan|Welle-Datei' -- AGENTS.md harness/ spec/ docs/plan/adr/ .claude/ \
  ':!docs/reviews' ':!.harness/baseline' ':!docs/plan/adr/0048-*.md' | grep -ic planner   # 3
# ohne den 0048-Ausschluss, zur Gegenprobe:                                                 8
```

Der abgedruckte Wert **3** reproduziert am lebenden Stand. Die Pathspec-Verengung wirkt (Gegenprobe
**8**), und die drei Treffer sind genau die drei Stellen, die der Aufzählung darunter entsprechen:
`docs/plan/adr/0031-…`:206 (Contra-Zelle Option F), `docs/plan/adr/0046-…`:256 (der ausgelegte
Satz), `docs/plan/adr/0046-…`:306 (erste Folgepflicht). **Der blockierende HIGH der Vorgänger-Runde
ist behoben.** Keine Erwartungswerte.

### Die breitere Suche und der vierte Treffer

```sh
git grep -nE 'Welle-Plan|Welle-Datei|Wellen-Plan|welle-\*\.md' \
  -- ':!.harness/baseline' ':!docs/reviews' ':!docs/plan/planning/done' \
     ':!docs/plan/adr/0048-*.md' | grep -ic planner        # 4
grep -n 'Schreibt Pläne' .claude/agents/planner.md         # 3:description: Schneidet Wellen …
```

Beide reproduzieren. Der vierte Treffer ist
`…/observations/BEO-ALL/fremdes-rollen-artefakt-im-implementations-kontext/evidence/slice-178.md`:2
— eine Evidence-Datei, keine Norm-Quelle, wie die ADR sagt.

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

Alle neun stimmen mit den Werten der ADR überein. Die acht Tabellenzeilen sind gelesen: Schritt 1
trägt **Verifier → Planner**, Schritt 2 und 3b **Planner → Architect → Planner**, die übrigen fünf
Zeilen **Planner** — kein Implementer. Die Aussage der ADR hält.

### Byte-Gleichheit der drei Kopfnoten — Auftrag zu LOW-3 der Vorrunde

```sh
T=".harness/baseline/$(grep -m1 '^BASELINE_TAG ?= ' Makefile | cut -d' ' -f3)/templates/docs/plan/planning/welle.template.md"
for f in docs/plan/planning/welle-*.md; do
  diff -q <(sed -n '10,15p' "$T") <(sed -n '3,8p' "$f") >/dev/null && echo "byte-gleich: $f"
done                                                # eine Zeile: welle-13
for f in docs/plan/planning/welle-*.md; do
  diff <(sed -n '10,15p' "$T") <(sed -n '3,8p' "$f")
done                                                # zwei Differenzen, je Zeile 3
grep -cE 'welle-[0-9]' <(sed -n '10,15p' "$T")      # 0
```

Der Block belegt jetzt **alle drei** Dateien: eine byte-gleich (`welle-13`, sie führt den
Vorlagen-Platzhalter unersetzt), zwei mit je genau einer Differenz in Zeile 3 —
`welle-09-results.md` bzw. `welle-11-results.md` gegen `welle-<Kennung>-results.md`. Die Sachaussage
der ADR trifft zu. **LOW-3 der Vorrunde ist behoben** (zur Reichweite des letzten Kommandos siehe
LOW-2 unten).

### Rollen-Verteilung, Modul-Liste, Gate

```sh
git log --format='%s' -- 'docs/plan/planning/welle-*.md' | grep -c '^Rolle Planner'     # 56
git log --format='%s' -- 'docs/plan/planning/welle-*.md' | grep -c '^Rolle Implement'   #  7
grep -n '^modules:' .d-check.yml   # 29:modules: [links, anchors, ids, matrix, codepaths, spans, planning, targets]
make docs-check                    # d-check: 1316 Datei(en) geprüft, 0 Befund(e)
```

`make docs-check` real gefahren, netzlos, gepinnter Digest. **Keine Erwartungswerte.**

### Gegenmessung zur Feststellung über `docs/plan/planning/README.md`

```sh
git grep -nE 'Welle-Plan|Welle-Datei|Wellen-Plan|welle-\*\.md' \
  -- ':!.harness/baseline' ':!docs/reviews' ':!docs/plan/planning/done' \
     ':!docs/plan/adr/0048-*.md' | grep -i planner | grep -ci 'planning/README'   # 0
git grep -nE 'planning/README\.md' -- AGENTS.md harness/ spec/ docs/plan/adr/ .claude/ \
  .harness/skills/ ':!.harness/baseline' ':!docs/reviews'
# -> 5x die ADR selbst, dazu harness/migration.md:116 (Instanz-Register, keine Rollen-Aussage)
```

Die Messungen aus §Kontext erreichen **null** Stellen über diese Datei. Siehe MEDIUM-2.

### Anzahl der `grep -c`-Kommandos in §Kontext

```sh
awk 'NR>=51 && NR<=202' docs/plan/adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md \
  | grep -cE 'grep -c'                                                            # 10
```

Drei davon stehen im `modul-08`-Block. Siehe LOW-3.

### Commit-Zuschnitt

```sh
git show --pretty=format: --name-only 2b914403
# docs/plan/adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md
# docs/plan/adr/README.md
git log -1 --format='%B%n%an %ae' 2b914403 | grep -ci 'co-authored-by\|generated with\|claude code\|anthropic'  # 0
```

---

## Findings

Jedes Finding folgt dem **§Output-Schema des Reviewer-Skills** — der verbindlichen Single Source of
Truth (`v6.8.0` · `regelwerk/modul-10-review-harness.md` §Ziel-Form: Reviewer-Skill).

### MEDIUM-1 — Festlegung 2 zählt zwei zitierte Quellen, wo der ausgelegte Satz drei nennt, und quantifiziert dann über alle von ihm genannten Artefakte

- `kategorie`: **MEDIUM** (Bezug-/Abdeckungslücke; sie trifft die **Substanz** von Festlegung 2)
- `quelle`: [ADR-0046](../plan/adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md)
  §Was diese Entscheidung nicht tut (der ausgelegte Satz) ·
  [ADR-0028](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Festlegung 1 ·
  [ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 2 (*verbatim*)
- `pfad`: `docs/plan/adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md`:241 gegen :243–247
  (und gleichlautend :130–133)
- `befund`: Der ausgelegte Satz beruft sich auf **drei** Quellen — `modul-08-agentenrollen.md` und
  [`AGENTS.md`](../../AGENTS.md) §3.10 für Welle-Plan und Roadmap, dazu
  [ADR-0028](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Festlegung 1 für
  den Anweisungssatz zum Wellen-Schnitt. Festlegung 2 sagt *„er leitet aus **zwei** Quellen ab"*,
  kürzt den dritten Beleg im Zitat weg und schließt dann universell: *„Für jedes der genannten
  Artefakte gilt deshalb, was **jene** Quellen ihm zuweisen — nicht mehr und nicht weniger."*
- `verifizierbar`: nein — kein Modul aus `modules:` der `.d-check.yml` hält eine Aussage gegen die
  Reichweite ihrer Quelle; der Wortlaut beider Sätze ist in den zwei Dateien nachlesbar.
- `klasse`: Geltungsbereich einer Festlegung in Überschrift und Rumpf verschieden breit

**Failure-Szenario.** Der Satz nennt drei Artefakte, die dem Planner gehören: `welle-13`, die
Roadmap, den Anweisungssatz. Für das dritte trägt allein die weggelassene Quelle. Ein Lauf, der
Festlegung 2 wörtlich anwendet, liest für `.claude/commands/plan-welle.md` *„was jene zwei Quellen
ihm zuweisen"* — und das ist nichts; die dritte Folgepflicht von
[ADR-0046](../plan/adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) verlöre aus jenem Satz ihre
Rollen-Adresse. §Was diese Entscheidung nicht tut schirmt die **Roadmap** namentlich ab, den
Anweisungssatz nicht — er ist kein Planungs-Artefakt und steht in keiner der beiden Aufzählungen.
Die **Überschrift** derselben Festlegung ist korrekt (*„was die von ihm zitierten Quellen binden"*,
ohne Zahl); Überschrift und Rumpf sagen Verschiedenes — dieselbe Mechanik, die die Vorrunde für
Festlegung 1 meldete, jetzt in Festlegung 2.

**Was den Schaden begrenzt, und warum der Befund trotzdem steht.**
[ADR-0028](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Festlegung 1 bindet
den Anweisungssatz aus eigener Kraft, unabhängig von jenem Satz; praktisch ändert sich für ihn
nichts. Der Defekt ist die **Reichweite der Festlegung**, und sie friert mit dem Accept ein.

### MEDIUM-2 — Die Feststellung zu `docs/plan/planning/README.md` stützt sich auf eine Messung, die über diese Datei nichts messen kann

- `kategorie`: **MEDIUM** (Spec-Treue-Lücke einer Messmethode)
- `quelle`: [`MR-055`](../../harness/conventions.md#mr-055--eine-stellen-messung-trägt-keine-folgerung-über-eine-eigenschaft)
  Setzung 2 (*„… schreibt neben ein Kommando keinen Satz, der mehr behauptet als dessen Prüfbereich
  hergibt"* — die Grenze, die die ADR in §Kontext für sich selbst zieht) ·
  [`AGENTS.md`](../../AGENTS.md) §3.6
- `pfad`: `docs/plan/adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md`:344–345
- `befund`: Der Satz *„Über jede Stelle, die die Messungen in §Kontext erreichen, benennt keine
  Quelle eine schreibende Rolle für sie"* ist die Begründung dafür, `docs/plan/planning/README.md`
  niemandem zuzuweisen. Die Messungen suchen nach `Welle-Plan|Welle-Datei|Wellen-Plan|welle-\*\.md`
  und erreichen über diese Datei **null** Stellen (Gegenmessung oben); die Aussage ist damit leer
  wahr und liest sich als Befund.
- `verifizierbar`: nein — Vollständigkeit über eine Eigenschaft ist kein `grep`-Ergebnis; die
  Gegenmessung oben ist reproduzierbar.
- `klasse`: Stellen-Messung trägt die Folgerung über eine Eigenschaft

**Failure-Szenario.** Ein Lauf, der den Nachzug an `docs/plan/planning/README.md` fährt, liest in
einer eingefrorenen ADR, dass *gemessen* keine Quelle eine schreibende Rolle für diese Datei
benennt, und lässt die eigene Suche aus. Der ADR-Satz hat die Frage aber nie gestellt. **Die
Folgerung selbst hält** — meine eigene Suche über die Datei findet nur `harness/migration.md`:116,
eine Instanz-Register-Zeile ohne Rollen-Aussage —, belegt ist sie durch die zitierte Messung nicht.
§Kontext zieht diese Grenze für die eigene tragende Prämisse ausdrücklich; §Konsequenzen fällt eine
Sektion später hinter sie zurück.

### MEDIUM-3 — Die Genealogie-Aussage schreibt ADR-0024 eine Stabilität zu, die jene Entscheidung für sich ausdrücklich nicht beansprucht

- `kategorie`: **MEDIUM** (die Aussage steht in §Konsequenzen und friert mit dem Accept ein)
- `quelle`: [ADR-0024](../plan/adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md)
  Festlegung 1 (*„**Derivativ** ist eine Eigenschaft der **Aussage**, nicht der Datei"* und *„Die
  Ableitung endet dort, wo ein Artefakt eine bindende Aussage über den Gegenstand trägt, die kein
  Original hat"*) und Festlegung 2 (gemischte Originale bleiben offen)
- `pfad`: `docs/plan/adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md`:323–330, dort
  :326–327; gegen die eigene `Bezug:`-Zeile :20–22
- `befund`: Die dritte Achse wird gegen zwei ältere abgesetzt mit *„beides Eigenschaften des
  Artefakts, stabil über seine Änderungen"*. Für
  [ADR-0028](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) trifft das zu; für
  [ADR-0024](../plan/adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md) nicht —
  dort hängt die Zuordnung an der **Aussage**, die gerade geschrieben wird, und endet bei einer
  bindenden Aussage ohne Original. Die eigene `Bezug:`-Zeile derselben Datei benennt genau diese
  Grenze korrekt.
- `verifizierbar`: nein — kein Modul hält eine Aussage gegen die Festlegung, die sie zitiert.
- `klasse`: Zusammenfassung stärker als ihre Quelle

**Failure-Szenario.** Ein Lauf nimmt aus ADR-0048 mit, ein derivatives Register gehöre als Artefakt
einer Rolle, unabhängig davon, was gerade hineingeschrieben wird — und schreibt eine bindende
Aussage ohne Original in ein Register unter dieser Rolle. Genau diesen Teil lässt ADR-0024
ausdrücklich offen. Das ist dieselbe Klasse, die die Vorrunde als MEDIUM-3 für ADR-0028 meldete;
dort behoben, hier für die Schwester-ADR neu entstanden.

### MEDIUM-4 — Das gewählte Konflikt-Verdikt hat ein zweiteiliges Übergabe-Artefakt; die Datei liefert einen Teil und nennt den anderen nicht

- `kategorie`: **MEDIUM** (Bezug-/Abdeckungslücke gegenüber der Quelle, auf die sich §Geschichte
  beruft)
- `quelle`: `v6.8.0` · `regelwerk/modul-08-agentenrollen.md` §Konflikt-Pfad als Rollen-Sequenz,
  Verdikt-Tabelle Zeile 3 — Übergabe-Artefakt: *„Folge-ADR + Erinnerungs-Slice in `next/`"* ·
  [`AGENTS.md`](../../AGENTS.md) §3.10 (Slices sind Planner-Artefakte)
- `pfad`: `docs/plan/adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md`:459 (§Geschichte,
  Zeile *Proposed*), gegen §Konsequenzen :338–368
- `befund`: §Geschichte benennt das Verdikt *„Lockerung legitim, aber undokumentiert"* und nimmt
  damit die Zeile jener Tabelle in Anspruch. Deren Übergabe-Artefakt hat zwei Teile; die Datei ist
  der erste (Folge-ADR), der zweite — der Erinnerungs-Slice in `next/` — kommt in der ganzen Datei
  nicht vor, weder als Folgepflicht noch als ausdrücklicher Verzicht mit Rollen-Adresse.
- `verifizierbar`: nein — kein Modul liest eine Rollen-Sequenz; der Bestand von `next/` ist mit
  `ls docs/plan/planning/next/` ablesbar und führt sechs Slices, keinen zu diesem Vorgang.
- `klasse`: Übergabe-Artefakt einer zitierten Rollen-Sequenz nur zur Hälfte geliefert

**Failure-Szenario.** Die drei Folgepflichten in §Konsequenzen sind *„fällig als eigener Vorgang"*
ohne Lifecycle-Adresse. Genau dafür führt die Baseline den Erinnerungs-Slice in `next/` — damit
*„später"* eine Adresse bekommt. Nach dem Accept friert §Konsequenzen ein, und ob ein Vorgang
geschnitten wird, hängt daran, dass sich jemand erinnert. Dass der Slice ein Planner-Artefakt ist
und der Architect ihn nicht schreiben darf, spricht nicht gegen den Befund, sondern für eine
benannte Übergabe — die Datei nennt sie für drei andere Punkte und hier nicht.

### LOW-1 — Die Eröffnungs-Zahl von §Kontext behauptet eine Repo-Eigenschaft, die ihr Pathspec nicht deckt

- `kategorie`: **LOW** (Doku-Drift; der Abschnitt friert ein)
- `quelle`: [`MR-055`](../../harness/conventions.md#mr-055--eine-stellen-messung-trägt-keine-folgerung-über-eine-eigenschaft)
  Setzung 2
- `pfad`: `docs/plan/adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md`:71–72 gegen :99–111
- `befund`: *„Drei lebende Stellen **dieses Repos** bringen Welle-Plan und Planner in einem Satz
  zusammen"* steht als Aussage über das Repo, während das Kommando darunter fünf Pfade prüft
  (`AGENTS.md harness/ spec/ docs/plan/adr/ .claude/`) und `docs/plan/planning/**`, `docs/user/`,
  `README.md` und `internal/` nicht erreicht. Dreißig Zeilen weiter nennt dieselbe Sektion einen
  vierten Treffer.
- `verifizierbar`: nein — die zwei Kommandos stehen oben und sind gefahren.
- `klasse`: Stellen-Messung trägt die Folgerung über eine Eigenschaft

**Warum LOW und nicht höher.** Der Absatz *„Was diese Messung nicht trägt"* korrigiert die
Überdehnung ausdrücklich und benennt den vierten Treffer; der Fehler liegt allein im Einleitungssatz
und ist in derselben Sektion aufgehoben.

### LOW-2 — Das Kennungs-Kommando misst die Zahl-Form, während dieses Repo auf die Namens-Form umgestellt hat

- `kategorie`: **LOW** (latente Wartungsfalle)
- `quelle`: [`MR-057`](../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
  (Namens-Form für jede neu vergebene Welle-Kennung) ·
  [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 1 (*„das Kommando, das **genau sie** ausgibt"*)
- `pfad`: `docs/plan/adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md`:169 gegen :181
- `befund`: Die Prosa sagt *„die Ziel-Form nennt **keine** Welle-Kennung"*; belegt wird das mit
  `grep -cE 'welle-[0-9]'` → **0**, also allein über die **Nummern**-Form. Eine Kennung in der
  Namens-Form, die [`MR-057`](../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
  für jede neu vergebene Welle setzt, träfe dieses Muster nicht.
- `verifizierbar`: nein — der Ausschnitt der Ziel-Form ist gelesen und trägt tatsächlich nur den
  Platzhalter `welle-<Kennung>`; die Aussage ist wahr, der Beleg misst weniger als sie.
- `klasse`: Zahl ohne Kommando trifft ihren Gegenstand nicht

### LOW-3 — Re-Evaluierungs-Trigger 4 zeigt auf „die drei `grep -c`-Kommandos aus §Kontext"; §Kontext führt zehn

- `kategorie`: **LOW** (latente Wartungsfalle; der Trigger friert ein)
- `quelle`: `v6.8.0` · `regelwerk/modul-04-adrs.md` §Kernidee (Modul 4) (Trigger als beobachtbare
  Bedingung) · Maintainability
- `pfad`: `docs/plan/adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md`:408–411
- `befund`: Die Beobachtbarkeits-Klausel lautet *„dass eines der drei `grep -c`-Kommandos aus
  §Kontext unter einem neuen `BASELINE_TAG` **0** ausgibt"*. §Kontext führt **10** solche Kommandos
  (Zeilen 61, 89, 145, 146, 147, 154, 155, 181, 195, 196), davon drei im `modul-08`-Block; nur die
  Bedingungs-Hälfte des Triggers grenzt die Menge ein, die Klausel selbst nicht.
- `verifizierbar`: nein — die Zählung steht oben und ist über die Datei nachgefahren.
- `klasse`: Zwei Limitatoren ohne Verknüpfungsregel

### LOW-4 — Das dritte Fach des Acceptance-Triggers hat eine allgemeine Kennzeichnung und eine Aufzählung, die enger ist als sie

- `kategorie`: **LOW**
- `quelle`: [ADR-0040](../plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md)
  Festlegung 3 · [ADR-0046](../plan/adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md)
  §Der Acceptance-Trigger (das Muster, dem die Schärfung folgt)
- `pfad`: `docs/plan/adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md`:429–433
- `befund`: Die Kennzeichnung lautet *„Abschnitte, die mit dem Accept einfrieren, ohne eine
  Festlegung zu tragen"*; die Aufzählung danach nennt §Kontext, §Konsequenzen, §Fitness Function,
  die Re-Evaluierungs-Trigger und §Verglichene Alternativen — nicht §Geschichte und nicht den
  Trigger-Abschnitt selbst, die beide einfrieren und keine Festlegung tragen. MEDIUM-4 dieses
  Reports liegt in §Geschichte und fällt damit unter die Kennzeichnung, aber unter keinen ihrer
  aufgezählten Posten.
- `verifizierbar`: nein — kein Modul liest einen Acceptance-Trigger.
- `klasse`: Acceptance-Trigger ohne Fach für den gemeldeten Befund

### LOW-5 — Eine Baseline-Aussage in §Der Anlass nennt Modul und Abschnitt, aber keinen Tag im eigenen Absatz

- `kategorie`: **LOW**
- `quelle`: [`MR-033`](../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
  Setzung 1 (*„im selben Absatz und nicht implizit über den gerade gepinnten Tag"*)
- `pfad`: `docs/plan/adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md`:64
- `befund`: *„Baseline-Regelwerk `modul-08-agentenrollen.md` §Konflikt-Pfad als Rollen-Sequenz"*
  steht ohne Tag; gedeckt ist es allein durch die `Regeln:`-Zeile zwanzig Zeilen höher
  (*„Die Rollen-Aussagen unten messen gegen die regierende Fassung `v6.8.0`"*). Die sechs übrigen
  Baseline-Aussagen der Datei (:135, :214, :277, :297, :459 und das Zitat :245) führen den Tag im
  eigenen Absatz.
- `verifizierbar`: nein — kein `versions`-Modul in der `.d-check.yml`
  (`grep -n '^modules:' .d-check.yml`); die Fundstelle steht oben.
- `klasse`: Baseline-Aussage ohne Mess-Tag

### LOW-6 — Die Zähler-Zahl beruft sich auf MR-025 für eine Klasse, die MR-025 ausdrücklich nicht erreicht

- `kategorie`: **LOW** (latente Wartungsfalle; der Zeiger friert mit dem Accept ein)
- `quelle`: [`MR-051`](../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
  §Geltungsbereich (*„zwei benannte Klassen von Messwerten, die MR-025 **nicht erreicht**: … der
  **Zähler-Stand des Beobachtungs-Registers**, wo er außerhalb des Registers zitiert wird"*) und
  Setzung 2 (*„ein Zähler-Stand … ist eine **datierte Messung**, kein Wert im Text"*) ·
  [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Kopf-Marke (*„ÜBERHOLT … → MR-051"*)
- `pfad`: `docs/plan/adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md`:364–367
- `befund`: Der Registerumfang steht als *„`107` Verzeichnisse (…, kein Erwartungswert, **datierte
  Messung** nach `MR-025`)"*. Den Begriff *datierte Messung* führt
  [`MR-051`](../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
  Setzung 2, und dessen Geltungsbereich sagt ausdrücklich, dass MR-025 genau diese Klasse **nicht**
  erreicht; MR-025 trägt dafür eine Kopf-Marke auf MR-051. Die `Bezug:`-Zeile der ADR führt MR-025,
  MR-033, MR-055 und MR-058 — MR-051 nicht.
- `verifizierbar`: nein — kein Modul hält eine Aussage gegen die Reichweite ihrer Quelle; beide
  Einträge sind gelesen, das ableitende Kommando ist gefahren (**107**).
- `klasse`: Zusammenfassung stärker als ihre Quelle

**Warum LOW und nicht MEDIUM.** Die **Sache** stimmt: Der Registerumfang steht neben dem Kommando,
das ihn ableitet, ist als *kein Erwartungswert* gekennzeichnet, und die Schwellen-Folgerung bleibt
ausdrücklich der Closure überlassen — damit ist MR-051 Setzung 2 inhaltlich erfüllt. Defekt ist
allein der **Zeiger**: Wer ihm folgt, landet in einem Eintrag, der die Klasse von sich weist.

### INFO-1 — Bedingung 1 der Probe lässt alle neun Ränge als Original zu, ohne den Grund zu nennen

- `kategorie`: **INFO** (dokumentationswürdige, aber undokumentierte Annahme)
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §2 (die neun Ränge) ·
  [ADR-0046](../plan/adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) §Konsequenzen, zweite
  Folgepflicht (Roadmap · Planner)
- `pfad`: `docs/plan/adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md`:224–225
- `befund`: Als Original zulässig ist *„die vendored Ziel-Form des betroffenen Artefakts oder eine
  kanonische Quelle nach [`AGENTS.md`](../../AGENTS.md) §2"* — einschließlich Rang 5, der Roadmap,
  deren Fortschreibung `v6.8.0` · `regelwerk/modul-08-agentenrollen.md` Schritt 6 dem Planner
  zuweist. Bedingung 2, 3 und 4 halten den Fall praktisch zusammen (Wiedergabe statt Formulierung,
  welle-neutral, keine Aussage über diese Welle); warum ein Original außerhalb der Ziel-Form für
  einen Welle-Plan-Nachzug überhaupt gebraucht wird, sagt die Datei nicht.
- `verifizierbar`: nein
- `klasse`: Probe-Bedingung breiter als ihr belegter Anwendungsfall

### INFO-2 — Dieser Report misst gegen den geänderten Trigger; die Vorrunde hat gegen den früheren verdiktiert

- `kategorie`: **INFO**
- `quelle`: [ADR-0040](../plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md)
  Festlegung 2 und 3 · ADR-0048 §Der Acceptance-Trigger (*„Der Preis steht daneben"*)
- `pfad`: `docs/plan/adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md`:436–447
- `befund`: Die Datei hat ihren Trigger zwischen den zwei Runden um ein drittes Fach erweitert und
  benennt den Preis selbst. Für diesen Report heißt das: MEDIUM-2, MEDIUM-3, MEDIUM-4 und die sechs
  LOW fallen in das neue dritte Fach und blockieren nach dem **heutigen** Wortlaut nicht; unter der
  Zwei-Fächer-Fassung, gegen die die Vorrunde verdiktierte, fielen die meisten von ihnen in keines.
  Festgehalten, damit der Unterschied nicht als Nachgeben gelesen wird.
- `verifizierbar`: nein
- `klasse`: Acceptance-Trigger zwischen zwei Runden geändert

---

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| **Auftrag 1 — trifft die §Kontext-Messung den abgedruckten Wert?** | geprüft, ohne Befund — **ja.** Das Kommando liefert an `2b914403` genau **3**; die Pathspec-Verengung `':!docs/plan/adr/0048-*.md'` wirkt (Gegenprobe ohne sie: **8**), und die drei Treffer entsprechen der Aufzählung eins zu eins. Der Wert ist an jedem Stand nach dem eigenen Commit nachzumessen. **HIGH-1 der Vorrunde ist behoben.** |
| **Auftrag 2 — Geltungsbereich von Festlegung 1 in Überschrift und Rumpf** | geprüft, ohne Befund — Dateititel, `### 1.`-Überschrift und Rumpf sagen alle drei *Welle-Plan*; der Rumpf präzisiert *„Gebunden ist **der Welle-Plan** (`docs/plan/planning/welle-*.md` und sein Ruheort in `done/`) und kein anderes Artefakt"*. Die breite Fassung steht als verworfene Option E in §Verglichene Alternativen. **MEDIUM-1 der Vorrunde ist behoben.** |
| **Auftrag 2b — schließt §Was diese Entscheidung nicht tut die Roadmap aus?** | geprüft, ohne Befund — **ja, namentlich und mit beiden Quellen**: *„Für die **Roadmap** gilt unverändert, was [ADR-0046](../plan/adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) §Konsequenzen ihrer zweiten Folgepflicht zuweist und was Baseline `v6.8.0`, `modul-08-agentenrollen.md` Schritt 6 (*Roadmap fortschreiben · Planner*) bindet"*. Nachgemessen: die zweite Folgepflicht von ADR-0046 ist die Roadmap-Zeile und trägt die Rollen-Marke *(Planner)*; `modul-08` Schritt 6 trägt **Planner**. Die frühere Anwendung der breiten Lesart auf `docs/plan/planning/README.md` ist durch eine **Feststellung ohne Zuweisung** ersetzt (Einwand dazu in MEDIUM-2 — er trifft den Beleg, nicht die Abgrenzung). |
| **Auftrag 3 — binden die vier Bedingungen den nachgezogenen Text an sein Original?** | geprüft, ohne Befund — **ja.** Bedingung 2 (neu) verlangt *„Der neue Text **gibt dieses Original wieder** — byte-gleich bis auf Kennungen, die die Vorlage als Platzhalter führt, oder im wörtlichen Zitat"* und schließt die freie Neuformulierung ausdrücklich aus (*„Formulieren ist der Vorgang, der dem Planner gehört"*). Damit ist das Failure-Szenario von MEDIUM-2 der Vorrunde geschlossen: eine frei neu formulierte Kopfnote erfüllt die Probe nicht mehr. Die Aufgabenteilung ist benannt (1/2 binden ans Original, 3 misst den ersetzten, 4 den neuen Text), und die Beweislast liegt beim Nachziehenden (*„Wer die vier Bedingungen nicht alle bejahen kann, hat den Fall nicht"*). Restbreite von Bedingung 1: INFO-1. |
| **Auftrag 4 — ist der Acceptance-Trigger dreifächrig wie bei ADR-0046?** | geprüft, ohne Befund — **ja, und breiter als das Vorbild.** ADR-0046 zählt Folgepflichten, Wächter-Aussagen und Gegenpositionen; ADR-0048 nimmt zusätzlich §Kontext samt Messungen, die Feststellungen und die Re-Evaluierungs-Trigger auf — genau die zwei Orte, an denen die Vorrunde HIGH-1 und MEDIUM-3 fand. Der Preis der Änderung während einer offenen Runde ist benannt. **MEDIUM-4 der Vorrunde ist behoben**, Restlücke in LOW-4. |
| **MEDIUM-3 der Vorrunde (Genealogie/ADR-0028)** | geprüft, **behoben für ADR-0028** — `Bezug:`-Zeile, Option-B-Contra und §Konsequenzen führen die eigene Achse jetzt als **dritte**, mit Begründung, und benennen den Unterschied zu ADR-0028 (Ablauf des Artefakts, stabil) ausdrücklich. Neu aufgetreten ist dieselbe Klasse für ADR-0024 — siehe MEDIUM-3 dieses Laufs. |
| **MEDIUM-5 der Vorrunde (Zwei-Token-Messung)** | geprüft, **behoben** — §Kontext trägt jetzt den Absatz *„Was diese Messung nicht trägt"* mit [`MR-055`](../../harness/conventions.md#mr-055--eine-stellen-messung-trägt-keine-folgerung-über-eine-eigenschaft), die breitere Gegensuche (**4**, nachgefahren) und den übersehenen Fund `.claude/agents/planner.md`:3, ausdrücklich als **Urteil über eine Stelle** statt als Messergebnis. Die tragende Prämisse ist auf den schwächeren, ausreichenden Satz zurückgenommen. |
| **LOW-1 der Vorrunde (sechs Closure-Schritte)** | geprüft, **behoben** — §Kontext zitiert den Schlusssatz `v6.8.0` · `regelwerk/modul-08-agentenrollen.md` *„Nur 1, 2 und 3b tragen einen Rollenwechsel; 3a, 3c, 4, 5 und 6 laufen im Planner-Kontext"* wörtlich und benennt Verifier und Architect. Festlegung 1 führt die Kurzform jetzt mit dem Zusatz *„und ihre drei Rollenwechsel an Verifier und Architect führen, nie an den Implementer"*; die für sie tragende Aussage (kein Implementer) ist an der Tabelle nachgemessen und richtig. |
| **LOW-2 der Vorrunde (zwei Limitatoren in Festlegung 2)** | geprüft, **behoben** — Überschrift und Rumpf nennen jetzt **eine** Grenze (*„Eine Grenze, nicht zwei"*); die Vereinigungs-Lesart ist entfallen. Der verbleibende Einwand betrifft die Zahl der **Quellen**, nicht die Zahl der Limitatoren (MEDIUM-1). |
| **LOW-3 der Vorrunde (Kopfnoten-Beleg)** | geprüft, **behoben** — der Block belegt alle drei Dateien: eine Schleife für die byte-gleiche, eine zweite für die zwei Differenzen. Beide in diesem Lauf gefahren, Ergebnis wie abgedruckt. |
| **INFO-1 der Vorrunde (Auslegungs-Ort)** | geprüft, **eingearbeitet** — §Was diese Entscheidung nicht tut führt jetzt *„Der Ort dieser Auslegung ist eine Wahl, und sie steht hier"*, mit dem Präzedenzfall aus [`harness/conventions.md`](../../harness/conventions.md) §Modus-Deklaration pro Sub-Area und mit dem Preis (spätere Korrektur nur als Folge-ADR). |
| **INFO-2 der Vorrunde (wartende Folgepflicht)** | geprüft, **aufgelöst** — die frühere *Folgepflicht (Implementer)* mit *„wartet die Annahme ab"* ist durch eine **Feststellung ohne Zuweisung** ersetzt (*„weder freigegeben noch blockiert"*). Die Kette blockierter Statuswechsel besteht damit nicht mehr. |
| Braucht ADR-0048 ein `Supersedes` auf ADR-0046? | geprüft, ohne Befund — **nein**, unverändert gegenüber der Vorrunde. Der ausgelegte Satz steht in einer **Abgrenzungs**-Sektion, nicht in §Entscheidung; beide Festlegungen von ADR-0046 gelten wörtlich fort; `docs/plan/adr/0046-*.md` ist nicht im Diff und seit `7cfd8283` (Accept) unverändert. Option C hält die Gegenposition. |
| ADR-0015 Festlegung 1 und §Was hier NICHT entschieden ist | geprüft, ohne Befund — ADR-0048 stützt sich auf die dort ausdrücklich offengelassene Frage, bestätigt keine fremde Zuordnung und verengt sich nach demselben Muster (*„für jeden Vorgang, der unter keine von ihnen fällt, bleibt die Frage offen"*). |
| ADR-0028 Festlegung 3 (`.claude/agents/*.md` ausgenommen) | geprüft, ohne Befund — die ADR nennt `.claude/agents/planner.md` als Fundstelle und weist ihr ausdrücklich **keine** Quellen-Rolle zu, mit Verweis auf Festlegung 3 und auf die neun Ränge. Korrekt gelesen. |
| ADR-0031 Option F — trägt die Charakterisierung? | geprüft, ohne Befund — nachgemessen: `Status: Proposed`; gewählt sind D und H, **F ist verworfen**; die Aussage steht in der Contra-Zelle und beruft sich auf ADR-0015, deren Festlegung 1 sie nicht trägt. Die ADR nennt die Stelle *„ein Befund, keine Quelle"* und hält sie als Folgepflicht fest, ohne sie zu beheben. |
| ADR-0040 Festlegung 1, 2 und 3 | geprüft, ohne Befund — der Trigger verlangt eine Runde der prüfenden Rolle, verwirft die Nachmessung des auflösenden Laufs ausdrücklich (*„nach einem blockierenden Verdikt ist es die **nächste** Runde derselben Rolle"* — dieser Report ist sie), und schreibt für die Accept-Zeile die Kennung statt des Pfad-Links vor. Die Trigger-Schärfung ist von Festlegung 3 gedeckt, solange die Datei `Proposed` ist. |
| ADR-0016 Festlegung 2 (*verbatim* = Wortlaut ohne Auszeichnung) | geprüft, ohne Befund — die hinzugefügte Fett-Auszeichnung im Zitat aus ADR-0046 ist von *„der Wortlaut ohne Auszeichnung, Whitespace normalisiert"* gedeckt. Die **Auslassung** im selben Zitat ist ein anderer Gegenstand und steht als MEDIUM-1. |
| Referenz auf eine superseded ADR | geprüft, ohne Befund — alle acht referenzierten ADRs geprüft: 0015, 0016, 0024, 0028, 0030, 0040, 0046 `Accepted`, 0031 `Proposed`; keine `Superseded by`. |
| MADR-Ziel-Form (`v6.8.0` · `regelwerk/modul-04-adrs.md` §Ziel-Form: ADR (MADR)) | geprüft, ohne Befund — Kopf (Status · Datum · Autor · Bezug · Schärft · Regeln), Kontext, Entscheidung, Verglichene Alternativen, Konsequenzen, Fitness Function, Re-Evaluierungs-Trigger, Geschichte — alle acht Abschnitte der Vorlage vorhanden und in ihrer Reihenfolge. `Schärft: —` ist die Vorlagen-Form für eine Prozess-ADR ohne Spec-Stratum. Ein `Supersedes:`-Feld führt die Vorlage nicht; sein Ausbleiben ist in der `Bezug:`-Zeile begründet. |
| Mindestens drei Alternativen mit Pro/Contra | geprüft, ohne Befund — **fünf** (A *nichts tun* · B Datei-Lesart · C `Supersedes` · E breite Fassung · **D gewählt**), jede mit Pro **und** Contra; die gewählte steht fett und zuletzt wie in der Vorlage. B und E halten die zwei Gegenpositionen, die die Vorrunde als fehlend oder ungeschrieben markierte. |
| Re-Evaluierungs-Trigger — vorhanden und beobachtbar | geprüft, ohne Befund an der Vollständigkeit — fünf Trigger, jeder mit einer Beobachtbarkeits-Klausel in Klammern; Trigger 1 hängt nicht mehr an einer Ordnungszahl, sondern an einer Quellen-Aussage, und sagt das ausdrücklich. Einwand zur Präzision von Trigger 4: LOW-3. |
| [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) — wird ein Gate behauptet? | geprüft, ohne Befund — §Fitness Function sagt für **beide** Festlegungen *„keinen Wächter"*, nennt den Grund (kein Modul liest Commits; `make mutate` kennt dafür keine Fehlschlag-Form) und markiert die eine beobachtbare Hälfte (`git log --stat`) ausdrücklich als **kein Gate**. Die Modul-Liste ist nachgemessen. Kein `make`-Target wird behauptet, das es nicht gibt. |
| [`AGENTS.md`](../../AGENTS.md) §3.11 — bewegte Adresse in einem einfrierenden Artefakt | geprüft, ohne Befund — `welle-09`/`welle-11`/`welle-13`, `slice-flache-welle-ist-eroeffnet-nicht-geplant` und die zwei Review-Reports stehen als **Kennung** ohne Pfad; **0** Markdown-Links in den vendored Baum und **0** Code-Spans mit `.harness/baseline/`-Pfad außerhalb der Kommando-Blöcke; die vier Pfad-Links gehen auf `docs/plan/planning/README.md`, auf `.claude/agents/planner.md`, auf `.d-check.yml` und auf ein Verzeichnis des Beobachtungs-Registers — alles ortsfest ([ADR-0034](../plan/adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md) Festlegung 5: die Ablage *„und die Verzeichnisse darin"*; die `observation.md` darin wandert nicht). `docs/plan/planning/welle-*.md` steht als **Glob**, den §3.11 ausdrücklich zulässt. |
| [`AGENTS.md`](../../AGENTS.md) §3.7 — Chronik, Konjunktiv, Befund-Kennung in neuem Text | geprüft, ohne Befund — die Datei ist weder Code/Konfiguration/Skript noch ein Zustandsfeld eines lebenden Registers und fällt nicht in den Geltungsbereich; unabhängig davon steht der Anlass im Indikativ, die verworfenen Optionen in der dafür vorgesehenen Tabelle und die Herkunft als **ein** auflösbares Feld (§Geschichte). |
| [`AGENTS.md`](../../AGENTS.md) §3.5 — Senkung ohne ADR | geprüft, ohne Befund — §Was diese Entscheidung nicht tut stellt ausdrücklich fest, dass keine Schwelle, kein Modul und keine Gate-Strenge bewegt wird. |
| [`AGENTS.md`](../../AGENTS.md) §3.4 — Immutabilität | geprüft, ohne Befund — ADR-0046 ist seit ihrem Accept-Commit unverändert (`git log` über die Datei: zwei Commits, beide vor diesem Vorgang) und nicht im Diff. |
| [`AGENTS.md`](../../AGENTS.md) §3.8 — Commit-Zuschnitt und schreibende Rolle | geprüft, ohne Befund — `git show --stat 2b914403`: **zwei** Dateien, die ADR und der ADR-Index, der ihr nach [ADR-0024](../plan/adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md) folgt; Subject nennt *„Rolle Architect"*; `Bezug:`-Zeile mit ADR- und `LH-`-IDs; **0** Treffer für `co-authored-by\|generated with\|claude code\|anthropic`. Keine Messzahl in der Message, also keine offene Beleg-Pflicht nach [`MR-051`](../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung) Setzung 1. |
| [`AGENTS.md`](../../AGENTS.md) §3.3 — `git mv` und Inhaltsänderung getrennt | geprüft, ohne Befund — der Commit enthält keine Umbenennung. |
| [`AGENTS.md`](../../AGENTS.md) §3.10 — Abschluss nicht im ausführenden Lauf | geprüft, ohne Befund — im Diff liegt kein Closure- und kein Register-Artefakt; §Was diese Entscheidung nicht tut und die Folgepflicht (Planner) verweisen die Register-Route ausdrücklich an die Closure. |
| [`AGENTS.md`](../../AGENTS.md) §3.6 — Zusage mit benanntem Gegenbeispiel | geprüft, ohne Befund — die Datei behauptet für keine ihrer zwei Festlegungen einen Wächter, benennt die Urteilshälften als *„Urteil und kein Muster"* und führt in Re-Evaluierungs-Trigger 2 den beobachtbaren Fall, der die Probe widerlegte. |
| ADR-Index-Zeile (derivativ nach [ADR-0024](../plan/adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md)) | geprüft, ohne Befund — vier Spalten; Titel wörtlich aus der `# `-Überschrift ohne `ADR-0048: `-Präfix und mit dem neuen, verengten Wortlaut; Status `Proposed` aus dem Kopffeld; `Bezug` vollständig und in derselben Reihenfolge wie die `**Bezug:**`-Zeile; Pfad-Tiefe wie im Bestand. |
| [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) — Zahl neben ihrem Kommando | geprüft, ohne weiteren Befund — jede Messzahl der Datei ist in diesem Lauf gefahren und trifft; alle sind als *kein Erwartungswert* gekennzeichnet. Das `# 3` neben `grep -n 'Schreibt Pläne' …` ist eine **Zeilennummer**, kein Messwert, und von der Setzung nicht gebunden; die Prosa daneben liest es korrekt als Fundstelle. Einwände zu Reichweite und Zuordnung stehen als LOW-1, LOW-2 und LOW-6. |
| [`MR-058`](../../harness/conventions.md#mr-058--eine-messung-die-ihr-eigener-vorgang-bewegt-wird-nach-dem-vorgang-genommen) | geprüft, ohne Befund — die Datei nennt den Eintrag als **benannte Klasse** und sagt zugleich richtig, dass sein Geltungsbereich `docs/plan/adr/` ausnimmt (*„sie benennt die Lage, sie bindet diese Datei nicht"*). Nachgelesen und bestätigt. Die Setzung ist trotzdem eingehalten: die Messung ist nach dem eigenen Vorgang nachmessbar. |
| [`MR-055`](../../harness/conventions.md#mr-055--eine-stellen-messung-trägt-keine-folgerung-über-eine-eigenschaft) — Geltungsbereich | geprüft, ohne Befund an der Anwendung — auch dieser Eintrag nimmt `docs/plan/adr/` aus; die ADR wendet ihn freiwillig als Selbstbindung an, was zulässig ist. Dass die `Bezug:`-Zeile das bei MR-058 sagt und bei MR-055 nicht, ist eine Ungleichbehandlung ohne Folge. |
| Konflikt-Pfad: ist das gewählte Verdikt eines der drei zulässigen? | geprüft, ohne Befund an der Wahl — *„Lockerung legitim, aber undokumentiert"* ist das dritte der drei aus `v6.8.0` · `regelwerk/modul-08-agentenrollen.md` §Konflikt-Pfad als Rollen-Sequenz; §Was diese Entscheidung nicht tut schließt das Herabstufen ausdrücklich aus, und F-1 der auslösenden Runde bleibt HIGH. Zum Übergabe-Artefakt desselben Verdikts: MEDIUM-4. |
| Cutoff und Geltungsbereich | geprüft, ohne Befund — *„ab der Annahme dieser Entscheidung, kein Nachrüsten"* mit derselben Begründung wie ADR-0015/ADR-0024, und *„Geltungsbereich: dieses Repo"* mit Verweis der emittierten Ebene an den Tool-Slice. |
| Links, Anker, IDs, Spans über den Diff | geprüft, ohne Befund — `make docs-check` real gefahren: **1316** Dateien, **0** Befunde, Module `links`/`anchors`/`ids`/`matrix`/`codepaths`/`spans`/`planning`/`targets`. Kein Erwartungswert. |
| Wortlaut-Proben der zitierten Stellen | geprüft, ohne Befund — alle acht `grep -c`-Zitate liefern **1**; das Zitat aus dem Beobachtungs-Register (*„dessen Eigentum eine Quelle einer anderen Rolle zuweist"*) steht dort umbrochen und trifft whitespace-normalisiert (**1**) nach [ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 2. |
| Charakterisierung des auslösenden Review-Reports | geprüft, ohne Befund — nachgelesen: F-1 ist HIGH mit Rollen-Widerspruch, der Report benennt den Gegeneinwand selbst (*„Zu F-1, und was dagegen spricht"*), stuft nicht herab und übergibt ausdrücklich an den Architect; F-2 (README.md, *Sequenzierungs-Autorität*) ist MEDIUM. Beide Aussagen der ADR treffen. |
| Out-of-Scope: die vier Träger des auslösenden Commits | geprüft, ohne Befund — nicht im Diff; ihre Prüfung liegt beim auslösenden Report. |
| Out-of-Scope: Produkt-Code, Gate-Konfiguration, emittierte Ebene | geprüft, ohne Befund — `internal/`, `cmd/`, `harness/tools/`, `.d-check.yml`, `internal/emit/templates/` sind unberührt. |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 4 |
| LOW | 6 |
| INFO | 2 |

**Finding-Klassen dieses Laufs:** Geltungsbereich einer Festlegung in Überschrift und Rumpf
verschieden breit · Stellen-Messung trägt die Folgerung über eine Eigenschaft · Zusammenfassung
stärker als ihre Quelle · Übergabe-Artefakt einer zitierten Rollen-Sequenz nur zur Hälfte geliefert
· Zahl ohne Kommando trifft ihren Gegenstand nicht · Zwei Limitatoren ohne Verknüpfungsregel ·
Acceptance-Trigger ohne Fach für den gemeldeten Befund · Baseline-Aussage ohne Mess-Tag ·
Probe-Bedingung breiter als ihr belegter Anwendungsfall · Acceptance-Trigger zwischen zwei Runden
geändert

*MEDIUM-2 und LOW-1 tragen dieselbe Klasse, MEDIUM-3 und LOW-6 ebenfalls — und alle vier stammen aus
demselben Vorgang. Für den Zähler ist das je **eine** Gelegenheit (`v6.8.0` ·
`regelwerk/modul-06-roadmap.md` §Das Beobachtungs-Register: „Zwei Funde im selben Vorgang sind eine
Gelegenheit").*

## Verdikt

**Blockierend — ein MEDIUM an der Substanz von Festlegung 2 steht. Alles Übrige ist behoben oder
fällt in das dritte Fach.**

**1. Die Kern-These beider Festlegungen ist bestätigt, zum zweiten Mal und unabhängig.** Die Lücke,
die Festlegung 1 schließt, ist in diesem Lauf neu gemessen: `v6.8.0` ·
`regelwerk/modul-08-agentenrollen.md` weist die **Eröffnung** zu und führt die Closure als
Schritt-Tabelle (acht Zeilen, gelesen — kein Implementer); [`AGENTS.md`](../../AGENTS.md) §3.10
bindet den **Abschluss**. Eine Text-Änderung an einem bereits eröffneten Welle-Plan fällt zwischen
beide, und [ADR-0015](../plan/adr/0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1 lässt
genau das offen. Festlegung 2 trägt ebenfalls: Der ausgelegte Satz steht in einer
**Abgrenzungs**-Sektion, ist ableitend gebaut und setzt keine eigene Zuweisung. *Ein `Supersedes`
auf [ADR-0046](../plan/adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) ist nicht erforderlich.*

**2. Die vier blockierenden Befunde der Vorrunde sind behoben — nachgemessen, nicht abgehakt.**
Die §Kontext-Messung reproduziert am lebenden Stand (**3**, Gegenprobe **8**); Festlegung 1 ist in
Titel, Überschrift und Rumpf auf den Welle-Plan verengt, und die Roadmap ist namentlich mit beiden
Quellen ausgenommen; die Probe bindet den neuen Text über Bedingung 2 an sein Original und schließt
die freie Neuformulierung ausdrücklich aus; der Acceptance-Trigger hat sein drittes Fach und ist
breiter als das Vorbild. Auch die drei LOW und die zwei INFO der Vorrunde sind eingearbeitet.

**3. Was blockiert, ist MEDIUM-1.** Festlegung 2 zählt **zwei** zitierte Quellen, wo der ausgelegte
Satz **drei** nennt, kürzt die dritte im Zitat weg und quantifiziert dann über *„jedes der genannten
Artefakte"*. Das dritte Artefakt jenes Satzes — der Anweisungssatz zum Wellen-Schnitt — hängt allein
an der weggelassenen Quelle und wird von §Was diese Entscheidung nicht tut nicht abgeschirmt, anders
als die Roadmap. Die **Überschrift** derselben Festlegung ist korrekt; Überschrift und Rumpf sagen
Verschiedenes. Das ist ein Befund an der Substanz einer der beiden Festlegungen und damit in dem
Fach, das der eigene Acceptance-Trigger als blockierend bezeichnet. Praktischer Schaden ist
begrenzt — [ADR-0028](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)
Festlegung 1 bindet unabhängig —, aber die Reichweite friert mit dem Accept ein, und die Behebung
ist **jetzt** ohne Folge-ADR möglich und danach nie wieder.

**4. Nicht blockierend nach dem eigenen Trigger, aber vor dem Umschlag zu beheben:** MEDIUM-2
(Feststellung zu `docs/plan/planning/README.md` mit einem Beleg, der ihren Gegenstand nicht
erreicht), MEDIUM-3 (die Genealogie-Aussage über ADR-0024) und MEDIUM-4 (die zweite Hälfte des
Übergabe-Artefakts) liegen in §Konsequenzen bzw. §Geschichte, die sechs LOW in §Kontext, den
Re-Evaluierungs-Triggern, dem Trigger-Abschnitt und einer Folgepflicht. Alle neun frieren mit dem
Accept ein und sind danach nach [`AGENTS.md`](../../AGENTS.md) §3.4 nur noch per Folge-ADR
erreichbar. **MEDIUM-4 liegt in §Geschichte, das der eigene dritte Fach-Katalog nicht aufzählt** —
das ist LOW-4, an einem realen Fall.

**Eine Einordnung, die der Trigger nicht selbst liefert.** Dieser Report ist die Runde, die
[ADR-0040](../plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 2 nach
einem blockierenden Verdikt verlangt. Er misst gegen den **heutigen**, dreifächrigen Trigger; die
Vorrunde verdiktierte gegen den zweifächrigen. Der Unterschied ist vom Architect bewusst gesetzt,
in der Datei benannt und von Festlegung 3 gedeckt — er ist festgehalten (INFO-2), damit er nicht als
Nachgeben gelesen wird.

**Übergabe:** Die Findings gehen an den **Architect**, der die Datei hält; sie steht auf `Proposed`,
und jede Behebung ist bis zum Umschlag ohne Folge-ADR möglich. Die **Finding-Klassen** gehen
zusätzlich in die Slice-Closure §7 und von dort in den Zähler — die Zuordnung zu einer vorhandenen
oder neuen Kennung trifft die Closure und gehört dem Planner ([`AGENTS.md`](../../AGENTS.md) §3.10),
nicht diesem Report. Dieser Report selbst ist ein **Lauf-Beleg** (Audit: dieser Stand, dieser Skill,
dieses Modell, dieses Verdikt) — er wird über Läufe hinweg nicht wieder gelesen. Der Report ersetzt
keine Verifikation — DoD-/Spec-Konformität prüft der Verifier separat (Modul 11; anderes
Prüf-Artefakt, anderer Eingabe-Kontext).
