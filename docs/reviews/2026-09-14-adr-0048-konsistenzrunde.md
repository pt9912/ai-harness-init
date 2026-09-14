# Review-Report — ADR-0048, Konsistenzrunde

**Art:** ADR-Konsistenzrunde (kein Slice-Review). Gegenstand ist eine einzelne Entscheidung im
Status `Proposed`, geprüft gegen die Quellen, die ihr eigener Acceptance-Trigger nennt.

**Datum:** 2026-09-14 · **Rolle:** Reviewer · **Kontext:** frisch, kein Anteil an der Entstehung
der geprüften Datei und kein Anteil an dem Commit, dessen Review sie ausgelöst hat.

**Gegenstand:** [`docs/plan/adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md`](../plan/adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md)
· **Status bei Prüfung:** `Proposed` · **Stand:** `ea3a41b8` (HEAD, `main`), `git status --porcelain`
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

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde — ohne
diese Liste ist der Lauf nicht reproduzierbar):

- Der Diff `ea3a41b8` (ADR-Datei + Index-Zeile) und seine Commit-Message
- [ADR-0015](../plan/adr/0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1 ·
  [ADR-0028](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Festlegung 1, 2, 3 ·
  [ADR-0046](../plan/adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) Festlegung 1, 2,
  §Was diese Entscheidung nicht tut, §Konsequenzen, §Der Acceptance-Trigger
- Die weiteren in der `Bezug:`-Zeile aktiven ADRs, soweit sie eine Aussage tragen:
  [ADR-0024](../plan/adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md) Festlegung 1/2 ·
  [ADR-0040](../plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 1/2/3 ·
  [ADR-0030](../plan/adr/0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) ·
  [ADR-0031](../plan/adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) (`Proposed`) ·
  [ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md)
- [`AGENTS.md`](../../AGENTS.md) §3 (Hard Rules; tragend hier §3.4, §3.5, §3.6, §3.7, §3.8, §3.10, §3.11)
- [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) ·
  [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) ·
  [`MR-033`](../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist) ·
  [`MR-055`](../../harness/conventions.md#mr-055--eine-stellen-messung-trägt-keine-folgerung-über-eine-eigenschaft) ·
  [`MR-058`](../../harness/conventions.md#mr-058--eine-messung-die-ihr-eigener-vorgang-bewegt-wird-nach-dem-vorgang-genommen)
- Baseline `v6.8.0` · `regelwerk/modul-04-adrs.md` §Ziel-Form: ADR (MADR) ·
  `regelwerk/modul-08-agentenrollen.md` §Rollen-Sequenz für eine Welle, §Konflikt-Pfad als
  Rollen-Sequenz · `regelwerk/modul-06-roadmap.md` §Wellen-Closure-Prozedur
- Vorherige Findings am gleichen Gegenstand: `2026-09-14-slice-flache-welle-ist-eroeffnet-nicht-geplant`
  (F-1 HIGH ist der Auslöser) und `2026-09-13-adr-0046-konsistenzrunde` (die Runde, die den
  ausgelegten Satz zuletzt geprüft hat)

**Rollen-Grenze:** Diese Runde ändert an der geprüften Datei nichts. Alle Sonden sind lesend; ein
Docker-Ziel ist gefahren (`make docs-check`), `make gates` fährt der Auftraggeber
([`AGENTS.md`](../../AGENTS.md) §3.9).

---

## Eigene Messungen

Alle Kommandos sind in diesem Lauf über `ea3a41b8` selbst gefahren; keine Zahl ist aus der ADR,
aus der Commit-Message oder aus dem Vorgänger-Report übernommen.

### Die Messung aus §Was gemessen ist — nachgefahren

```sh
git grep -nE 'Welle-Plan|Welle-Datei' -- AGENTS.md harness/ spec/ docs/plan/adr/ .claude/ \
  ':!docs/reviews' ':!.harness/baseline' | grep -ic planner        # 8
git grep -nE 'Welle-Plan|Welle-Datei' ea3a41b8^ -- AGENTS.md harness/ spec/ docs/plan/adr/ \
  .claude/ ':!docs/reviews' ':!.harness/baseline' | grep -ic planner   # 3
```

**Keine Erwartungswerte.** Die abgedruckte `3` gilt für den Stand **vor** dem Commit, der die ADR
anlegt, und in keinem Moment danach; fünf der acht Treffer sind die eigenen Zeilen der Datei
(`:22`, `:64`, `:85`, `:160`, `:194`). Der Treffer `:160` liegt **innerhalb von Festlegung 1**.

### Die Baseline- und Zitat-Kommandos der ADR — sechs von sieben liefern wie abgedruckt

```sh
B=".harness/baseline/$(grep -m1 '^BASELINE_TAG ?= ' Makefile | cut -d' ' -f3)/regelwerk/modul-08-agentenrollen.md"
grep -c 'Die Eröffnung ist Planner-Arbeit' "$B"                                   # 1
grep -cE '^\| \*\*[0-9]' "$B"                                                     # 8
grep -c 'ist der ganze Abschluss: die Closure-Notiz' AGENTS.md                    # 1
grep -c 'ein berührter Welle-Plan und der' AGENTS.md                              # 1
grep -c 'Die ersten drei gehören dem \*\*Planner\*\*' docs/plan/adr/0046-*.md      # 1
grep -c 'sie bestätigt keine fremde Zuordnung und setzt keine neue' docs/plan/adr/0015-*.md  # 1
grep -c 'Eigentum ist eine Eigenschaft des Ablaufs' docs/plan/adr/0028-*.md       # 1
```

Alle sieben stimmen mit den Werten der ADR überein. Die acht Tabellenzeilen aus dem zweiten
Kommando sind gelesen — siehe LOW-1.

### Byte-Gleichheit der drei Kopfnoten — die Schleife und der fehlende Rest

```sh
T=".harness/baseline/$(grep -m1 '^BASELINE_TAG ?= ' Makefile | cut -d' ' -f3)/templates/docs/plan/planning/welle.template.md"
for f in docs/plan/planning/welle-*.md; do
  diff -q <(sed -n '10,15p' "$T") <(sed -n '3,8p' "$f") >/dev/null && echo "byte-gleich: $f"
done                                              # eine Zeile: welle-13
grep -cE 'welle-[0-9]' <(sed -n '10,15p' "$T")    # 0
diff <(sed -n '10,15p' "$T") <(sed -n '3,8p' docs/plan/planning/welle-09-modul-15-konformitaet.md)
diff <(sed -n '10,15p' "$T") <(sed -n '3,8p' docs/plan/planning/welle-11-traeger-aussage.md)
# je eine Differenz, je Zeile 3: `welle-<Kennung>-results.md` gegen `welle-09-` bzw. `welle-11-results.md`
```

Die Sachaussage der ADR (*„byte-gleich … bis auf den eingesetzten Namen der Ergebnis-Notiz"*)
trifft zu. Nachgewiesen hat sie erst dieser Lauf, nicht das abgedruckte Kommando — siehe LOW-3.

### Rollen-Verteilung und Register-Umfang

```sh
git log --format='%s' -- 'docs/plan/planning/welle-*.md' | grep -c '^Rolle Planner'     # 56
git log --format='%s' -- 'docs/plan/planning/welle-*.md' | grep -c '^Rolle Implement'   #  7
ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l                                # 107
grep -n '^modules:' .d-check.yml   # 29:modules: [links, anchors, ids, matrix, codepaths, spans, planning, targets]
```

Alle vier stimmen mit den Werten der ADR überein. **Keine Erwartungswerte.**

### Breitere Suche nach einer Quelle, die die schreibende Rolle benennt

```sh
git grep -nE 'Welle-Plan|Welle-Datei|Wellen-Plan|welle-\*\.md' ea3a41b8^ \
  -- ':!.harness/baseline' ':!docs/reviews' ':!docs/plan/planning/done' | grep -ic planner   # 4
grep -n 'Schreibt Pläne' .claude/agents/planner.md   # 3
```

Der vierte Treffer ist eine Evidence-Datei des Beobachtungs-Registers, keine Norm-Quelle. Die
zweite Zeile liegt **innerhalb** der Pfadliste der ADR und **außerhalb** ihres Suchmusters — siehe
MEDIUM-5.

### Gate-Lauf

```sh
make docs-check   # d-check: 1315 Datei(en) geprüft, 0 Befund(e)
```

Real gefahren, netzlos, gepinnter Digest.

---

## Findings

Jedes Finding folgt dem **§Output-Schema des Reviewer-Skills** — der verbindlichen Single Source
of Truth (`v6.8.0` · `regelwerk/modul-10-review-harness.md` §Ziel-Form: Reviewer-Skill).

### HIGH-1 — Die Messung in §Kontext trifft die eigene Datei, und Re-Evaluierungs-Trigger 1 erfüllt sich damit an Festlegung 1 selbst

- `kategorie`: **HIGH** (MEDIUM *Spec-Treue-Lücke einer Messmethode*, eine Stufe hoch nach der
  Kontext-Eskalation des Skills: Der Defekt sitzt in einem Abschnitt, den der Accept einfriert,
  und ist danach nach [`AGENTS.md`](../../AGENTS.md) §3.4 nur noch per Folge-ADR mit `Supersedes`
  korrigierbar. Die Ein-Zeilen-Behebung ist **jetzt** verfügbar und nie wieder.)
- `quelle`: [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 1 (*„trägt im selben Absatz das Kommando, das **genau sie** ausgibt"*) ·
  [`MR-058`](../../harness/conventions.md#mr-058--eine-messung-die-ihr-eigener-vorgang-bewegt-wird-nach-dem-vorgang-genommen)
  Setzung 2/3 als benannte Klasse (ihr Geltungsbereich nimmt `docs/plan/adr/` aus — sie trägt das
  Finding nicht, sie benennt es) · `v6.8.0` · `regelwerk/modul-04-adrs.md` §Ziel-Form: ADR (MADR)
- `pfad`: `docs/plan/adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md`:64–72 und :295–299
- `befund`: Das abgedruckte Kommando liefert an dem Stand, an dem die Datei lebt, **8** statt **3**;
  fünf Treffer sind ihre eigenen Zeilen, einer davon (`:160`) steht innerhalb von Festlegung 1.
  Re-Evaluierungs-Trigger 1 macht seine Beobachtbarkeit an genau diesem Kommando fest — *„dass das
  `git grep`-Kommando aus §Kontext einen **vierten** Treffer liefert, der eine Festlegung ist"* —
  und ist damit im Moment des Einfrierens von der eigenen Festlegung 1 erfüllt.
- `verifizierbar`: nein — kein Modul aus `modules:` der `.d-check.yml` hält eine Zahl gegen das
  Kommando daneben, und `make comment-claims` liest keine Markdown-Datei; das Kommando selbst ist
  reproduzierbar und steht oben.
- `klasse`: Mess-Zusage trifft das eigene Zitat

**Was daran nicht der Befund ist.** Die drei vorbestehenden Fundstellen sind korrekt aufgezählt und
gelesen; die Ziffer ist nicht falsch *erhoben*, sie ist an keinem Stand nach dem eigenen Commit
nachzumessen. Und der Zusatz *„kein Erwartungswert"* deckt den Fall nicht: er deckt Drift **nach**
dem Schreiben, hier bewegt der schreibende Vorgang die Zahl selbst.

### MEDIUM-1 — Festlegung 1 nennt ihren Geltungsbereich in Überschrift und Rumpf verschieden breit, und die Datei wendet ihn bereits auf eine zweite Artefaktklasse an

- `kategorie`: **MEDIUM** (Bezug-/Abdeckungslücke; sie trifft die **Substanz** von Festlegung 1)
- `quelle`: [ADR-0015](../plan/adr/0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1
  (*„sie bestätigt keine fremde Zuordnung und setzt keine neue"* — die Verengung, auf die sich
  ADR-0048 beruft) · [ADR-0046](../plan/adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md)
  §Konsequenzen, zweite Folgepflicht (Roadmap · **Planner**) ·
  [ADR-0028](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Festlegung 1
- `pfad`: `docs/plan/adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md`:158–164 gegen
  :200–204 und :253–258
- `befund`: Die Überschrift setzt die Regel für *„ein Planungs-Artefakt"*, der Rumpf arbeitet sie
  nur *„für den Welle-Plan"* aus, und der Begriff *Planungs-Artefakt* ist nirgends abgegrenzt;
  §Was diese Entscheidung nicht tut verengt ausschließlich die **Vorgangs**-Klassen und ausdrücklich
  nur für den Welle-Plan (*„wem der Welle-Plan im Übrigen gehört"*). Die Datei liest ihre eigene
  Festlegung dabei bereits breit: die Folgepflicht (Implementer) für `docs/plan/planning/README.md`
  — kein Welle-Plan — sagt *„fällt unter Festlegung 1"*.
- `verifizierbar`: nein — kein Modul liest Commits oder Rollen-Zuordnungen; die Datei selbst ist die
  einzige Fundstelle.
- `klasse`: Geltungsbereich einer Festlegung in Überschrift und Rumpf verschieden breit

**Failure-Szenario.** Ein Lauf wendet die Drei-Bedingungen-Probe auf einen Nachzug an der Roadmap
an (Rang 5, kein Welle-Plan) und schreibt im Implementations-Kontext — gegen die zweite
Folgepflicht von ADR-0046, die genau diesen Abschnitt dem Planner gibt und die ADR-0048 für
unberührt erklärt. Nach der breiten Lesart ist das gedeckt, nach der engen nicht, und die Datei
sagt nicht, welche gilt.

### MEDIUM-2 — Die Drei-Bedingungen-Probe bindet den nachgezogenen Text an kein Original; der Beleg, der den Fall entschied, steht nicht in ihr

- `kategorie`: **MEDIUM** (Bezug-/Abdeckungslücke; sie trifft die **Substanz** von Festlegung 1)
- `quelle`: [ADR-0024](../plan/adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md)
  Festlegung 1 (*„Derivativ ist eine Eigenschaft der **Aussage** … und das Original muss
  existieren"* — die Familie, auf die sich ADR-0048 beruft) ·
  [`AGENTS.md`](../../AGENTS.md) §2 (die neun Ränge, die Bedingung 1 öffnet)
- `pfad`: `docs/plan/adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md`:166–176 gegen
  :122–133
- `befund`: Bedingung 1 verlangt nur, dass ein **Original** in einem der neun Ränge oder in der
  vendored Ziel-Form *existiert*; keine der drei Bedingungen verlangt, dass der nachgezogene Text
  dieses Original wiedergibt. Die Byte-Gleichheit, die §Was der strittige Gegenstand ist als
  tragenden Beleg misst, ist damit nicht Teil der Probe, die den Namen *vorlagengebunden* trägt.
- `verifizierbar`: nein — die Probe ist nach §Fitness Function ausdrücklich ein Urteil und kein
  Muster; kein Gate hält sie.
- `klasse`: Probe verlangt weniger, als ihr Name und ihr Beleg zusagen

**Failure-Szenario.** Ein Implementations-Lauf formuliert die `Lifecycle:`-Kopfnote eines laufenden
Welle-Plans frei neu, nennt ADR-0046 Festlegung 1 als Original, bejaht alle drei Bedingungen (der
ersetzte Text war welle-neutral, der neue sagt über diese Welle nichts) — und der Welle-Plan trägt
danach eine Formulierung, die kein Planner geschrieben hat. Dieselbe Bedingung 1 lässt außerdem
Rang 5 (die Roadmap) als Original zu, also ein Artefakt, dessen Fortschreibung
`v6.8.0` · `regelwerk/modul-08-agentenrollen.md` §Rollen-Sequenz für eine Welle in Schritt 6 dem
Planner zuweist.

### MEDIUM-3 — Die Genealogie-Aussage liest ADR-0028 Festlegung 1 auf einer anderen Achse, als jene sie setzt

- `kategorie`: **MEDIUM** (die Aussage steht in §Bezug, in der Contra-Spalte von Option B und in
  §Konsequenzen — Abschnitte, die mit dem Accept einfrieren)
- `quelle`: [ADR-0028](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)
  Festlegung 1 (*„Eigentum ist eine Eigenschaft des Ablaufs, den ein Anweisungssatz
  **operationalisiert**, nicht der Datei-Existenz. Kriterium: welche Rolle führt diesen Ablauf aus,
  wenn sie dem Artefakt folgt?"*) ·
  [ADR-0024](../plan/adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md)
  Festlegung 1
- `pfad`: `docs/plan/adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md`:15–17, :194 und
  :236–239
- `befund`: ADR-0028 hängt Eigentum an einer Eigenschaft des **Artefakts** auf — an dem Ablauf, den
  es beschreibt —, und die Zuordnung bleibt über alle Änderungen stabil; ADR-0048 hängt sie an den
  **Vorgang, der es ändert**, und die Zuordnung wechselt je Änderung. Der Satz *„Nach ADR-0024
  (Original) und ADR-0028 (Ablauf) kommt keine dritte Achse hinzu"* nennt in derselben Zeile zwei
  Eigenschaften und spricht der eigenen, dritten die Neuheit ab.
- `verifizierbar`: nein — kein Modul hält eine Aussage gegen die Festlegung, die sie zitiert.
- `klasse`: Zusammenfassung stärker als ihre Quelle

**Failure-Szenario.** Ein Lauf liest ADR-0048 und nimmt daraus mit, ADR-0028 entscheide Eigentum
pro Änderung. Angewandt auf `.claude/commands/plan-welle.md` wäre ein vorlagengebundener Nachzug
dort dann kein Planner-Vorgang mehr — gegen die dritte Folgepflicht von ADR-0046, die genau diese
Datei über ADR-0028 Festlegung 1 dem Planner gibt.

### MEDIUM-4 — Der Acceptance-Trigger trägt zwei Fächer, wo der Trigger der ausgelegten Datei drei trägt, und dieser Report füllt das fehlende

- `kategorie`: **MEDIUM**
- `quelle`: [ADR-0046](../plan/adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md)
  §Der Acceptance-Trigger (*„Drei Fächer, nicht zwei … Ohne es fällt ein Befund an der
  Folgepflicht-Menge in keines der zwei"*) ·
  [ADR-0040](../plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 3
- `pfad`: `docs/plan/adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md`:314–322
- `befund`: Der Trigger kennt *Substanz der beiden Festlegungen* und *Darstellung (Adressform, Zahl
  ohne Kommando, Zitat-Stelle)*. HIGH-1 liegt an einem Re-Evaluierungs-Trigger, MEDIUM-3 an einer
  Aussage in §Konsequenzen — beide Abschnitte frieren mit dem Accept ein und tragen keine
  Festlegung; der Trigger sagt über sie weder das eine noch das andere. Genau diese Lücke hat die
  Runde `2026-09-13-adr-0046-konsistenzrunde` benannt, und ADR-0046 hat sie für sich geschlossen.
- `verifizierbar`: nein — kein Modul liest einen Acceptance-Trigger.
- `klasse`: Acceptance-Trigger ohne Fach für den gemeldeten Befund

### MEDIUM-5 — Die tragende Negativ-Prämisse ist eine Mengen-Aussage, ihr Beleg ist eine Zwei-Token-Suche

- `kategorie`: **MEDIUM** (Spec-Treue-Lücke einer Messmethode)
- `quelle`: [`MR-055`](../../harness/conventions.md#mr-055--eine-stellen-messung-trägt-keine-folgerung-über-eine-eigenschaft)
  (eine Stellen-Messung trägt keine Folgerung über eine Eigenschaft) ·
  [ADR-0015](../plan/adr/0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1 (*„wo keine sie
  benennt, bleibt das eine offene Frage"* — die Prämisse, die getragen werden muss)
- `pfad`: `docs/plan/adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md`:64–72 und :112–118
- `befund`: Der Satz *„Für sie benennt heute keine Quelle eine schreibende Rolle"* ist eine Aussage
  über eine **Menge**; belegt ist er durch `grep` nach zwei Komposita (`Welle-Plan|Welle-Datei`)
  über eine Pfadliste, die `docs/plan/planning/**` und `internal/emit/**` nicht enthält. Die
  direkteste Rollen-Aussage des Repos liegt innerhalb der Pfadliste und außerhalb des Musters:
  `.claude/agents/planner.md`:3 — *„Schneidet Wellen und Slices … **Schreibt Pläne**, keinen
  Produktionscode."*
- `verifizierbar`: nein — Vollständigkeit über eine Eigenschaft ist kein `grep`-Ergebnis; die
  Gegenmessung oben ist reproduzierbar.
- `klasse`: Stellen-Messung trägt die Folgerung über eine Eigenschaft

**Was gegen den Befund spricht, und warum er trotzdem steht.** `.claude/agents/planner.md` ist nach
[ADR-0028](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Festlegung 3
ausdrücklich **nicht** mitentschieden und steht in keinem der neun Ränge — als *Quelle* im Sinne
von ADR-0015 trägt sie kaum. Die Folgerung der ADR hält damit sehr wahrscheinlich; belegt ist sie
durch die abgedruckte Messung nicht, und die Datei friert die Prämisse mit ein.

### LOW-1 — „die sechs Closure-Schritte sind Planner-Arbeit" komprimiert die Tabelle, die das eigene Kommando daneben ausgibt

- `kategorie`: **LOW** (Doku-Drift; die Aussage steht in Festlegung 1, ändert aber an dem, was sie
  ausschließt — den Implementer —, nichts)
- `quelle`: `v6.8.0` · `regelwerk/modul-08-agentenrollen.md` §Rollen-Sequenz für eine Welle
  (Schritt 1 *„**Verifier** → Planner"*, Schritt 2 und 3b *„Planner → Architect → Planner"*,
  Schlusssatz *„Nur 1, 2 und 3b tragen einen Rollenwechsel; 3a, 3c, 4, 5 und 6 laufen im
  Planner-Kontext"*) ·
  [ADR-0028](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Festlegung 1, die
  für denselben Zweck genau diesen Schlusssatz zitiert statt zu komprimieren
- `pfad`: `docs/plan/adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md`:160–162
- `befund`: Drei der acht Zeilen, die das Kommando `grep -cE '^\| \*\*[0-9]'` in §Kontext zählt,
  tragen einen Rollenwechsel; Schritt 1 liegt beim Verifier. Der Satz, der sie als *„Planner-Arbeit"*
  zusammenfasst, steht vier Zeilen unter dem Kommando, das die Gegenaussage liefert.
- `verifizierbar`: nein — das Kommando ist gefahren und liefert 8; welche Zeile welche Rolle trägt,
  ist am Text zu lesen.
- `klasse`: Zusammenfassung stärker als ihre Quelle

### LOW-2 — Die Überschrift von Festlegung 2 nennt zwei Limitatoren ohne Verknüpfungsregel; nur der Rumpf löst sie auf

- `kategorie`: **LOW**
- `quelle`: [ADR-0046](../plan/adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md)
  §Was diese Entscheidung nicht tut (der ausgelegte Satz nennt `welle-13` namentlich) ·
  Maintainability
- `pfad`: `docs/plan/adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md`:178–183
- `befund`: *„reicht so weit wie die dort genannten **Artefakte** und die zitierten **Quellen**"*
  lässt offen, ob beide Grenzen kumulativ (Schnittmenge) oder alternativ (Vereinigung) gelten. Unter
  der Vereinigungs-Lesart bleibt `welle-13` — in ADR-0046 namentlich genannt und eine der drei
  Dateien, die der auslösende Commit anfasste — dem Planner zugewiesen, und Festlegung 1 und
  Festlegung 2 widersprechen sich für genau das Artefakt, das den Konflikt erzeugt hat. Aufgelöst
  wird das erst vom Folgesatz *„er bindet, was jene Quellen binden"*.
- `verifizierbar`: nein — kein Modul liest eine Konjunktion.
- `klasse`: Zwei Limitatoren ohne Verknüpfungsregel

**Warum LOW und nicht höher.** Der auflösende Satz steht unmittelbar darunter, und §Kontext
schneidet den Fall zusätzlich auf `welle-13` §1 Punkt 2 zu. Gemeldet wird es, weil in diesem
Vorgang gerade eine **Überschrift** einer Abgrenzungs-Sektion zitiert und breiter gelesen wurde,
als ihr Rumpf trägt — dieselbe Mechanik eine Ebene höher.

### LOW-3 — Die Aussage über drei Kopfnoten steht neben einem Kommando, das eine belegt

- `kategorie`: **LOW**
- `quelle`: [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 1
- `pfad`: `docs/plan/adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md`:122–132
- `befund`: Die Prosa sagt, alle drei Kopfnoten seien byte-gleich zur Ziel-Form *„bis auf den
  eingesetzten Namen der Ergebnis-Notiz"*; die abgedruckte Schleife gibt eine Zeile aus und belegt
  damit `welle-13`. Die Aussage über die zwei übrigen ist erst durch die zwei `diff`-Läufe dieses
  Reports gedeckt.
- `verifizierbar`: nein — kein Modul hält eine Instanz gegen ihre Vorlage; die Kommandos stehen oben.
- `klasse`: Zahl ohne Kommando trifft ihren Gegenstand nicht

### INFO-1 — Die Auslegung einer eingefrorenen Entscheidung wandert selbst in ein einfrierendes Artefakt

- `kategorie`: **INFO** (dokumentationswürdige, aber undokumentierte Annahme)
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.4 ·
  [`harness/conventions.md`](../../harness/conventions.md) §Modus-Deklaration pro Sub-Area
  (*„Diese Umdeutung steht hier und nur hier — die ADR wird dafür nicht angefasst"*, der einzige
  vorhandene Präzedenzfall einer Umdeutung im Repo)
- `pfad`: `docs/plan/adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md`:178–183
- `befund`: Der bestehende Präzedenzfall legt eine `Accepted`-ADR in einem **lebenden** Artefakt aus,
  das nachgezogen werden kann; ADR-0048 legt eine in einer Datei aus, die mit dem eigenen Accept
  einfriert. Beides ist zulässig; die Wahl bestimmt, wo eine spätere Korrektur der Auslegung stehen
  muss (dann: Folge-ADR mit `Supersedes ADR-0048`), und die Datei benennt sie nicht als Wahl.
- `verifizierbar`: nein
- `klasse`: Auslegungs-Ort nicht als Wahl benannt

### INFO-2 — Ein blockierendes MEDIUM des Vorgänger-Reports wartet auf die Annahme dieser Datei

- `kategorie`: **INFO**
- `quelle`: Report `2026-09-14-slice-flache-welle-ist-eroeffnet-nicht-geplant`, F-2 (MEDIUM,
  merge-blockierend) · ADR-0048 §Konsequenzen, Folgepflicht (Implementer)
- `pfad`: `docs/plan/adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md`:253–258
- `befund`: Der Nachzug an `docs/plan/planning/README.md` *„wartet die Annahme ab"*. Damit hängt ein
  blockierendes MEDIUM an einer Datei, deren Annahme dieser Report blockiert; die Kette ist sichtbar
  und aufgelöst, sobald eine Runde die Substanz bestätigt — festgehalten, damit sie nicht als
  stiller Stillstand gelesen wird.
- `verifizierbar`: nein
- `klasse`: Folgepflicht wartet auf einen blockierten Statuswechsel

---

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| **Auftrag 3 — braucht ADR-0048 ein `Supersedes` auf ADR-0046?** | geprüft, ohne Befund — **nein.** Der ausgelegte Satz steht in §Was diese Entscheidung nicht tut, nicht in §Entscheidung; ADR-0046 führt dort genau zwei Festlegungen (flache Datei mit der Eröffnung · kein Eintrag im Adaptions-Block), und keine spricht über Eigentum. Der Satz ist **ableitend** gebaut (*„gehören dem Planner — … **nach** `v6.7.2` … und **nach** AGENTS.md §3.10, … **nach** ADR-0028 Festlegung 1"*) und setzt nichts daneben. Kein Wort von ADR-0046 ist geändert; `docs/plan/adr/0046-*.md` steht nicht im Diff. |
| ADR-0046 Festlegung 1 und 2 — unberührt? | geprüft, ohne Befund — beide gelten wörtlich fort; ADR-0048 nennt Festlegung 1 mehrfach als die Regel, die der auslösende Vorgang gerade umsetzt. |
| ADR-0046 §Konsequenzen — werden ihre vier Folgepflichten berührt? | geprüft, ohne Befund an der Substanz; die Kollisions-**Risiken** aus MEDIUM-1 und MEDIUM-3 betreffen die Auslegung von ADR-0048, nicht den Text von ADR-0046. |
| ADR-0046 §Konsequenzen, Folgepflicht 1 (`welle-13` §1 Punkt 2 · Planner) gegen Festlegung 1 | geprüft, ohne Befund — die ADR trennt den Fall ausdrücklich (*„dort steht eine Anforderung *dieser* Welle an *ihre* Slices"*); Bedingung 3 der Probe schließt ihn aus, und die Zuordnung zum Planner bleibt. |
| ADR-0015 Festlegung 1 — wird eine fremde Zuordnung bestätigt oder eine neue gesetzt? | geprüft, ohne Befund — ADR-0048 beruft sich korrekt auf die dort ausdrücklich offengelassene Frage, bestätigt keine fremde Zuordnung und verengt sich in §Was diese Entscheidung nicht tut nach demselben Muster. |
| ADR-0015 §Was hier NICHT entschieden ist (*„eine Eigentums-Aussage über irgendein drittes Artefakt"*) | geprüft, ohne Befund — ADR-0048 stützt sich auf die Lücke, nicht auf eine ADR-0015 unterstellte Zuordnung; genau der Fehler, den ADR-0028 MEDIUM-2 seinerzeit beheben musste, wiederholt sich nicht. |
| ADR-0028 Festlegung 3 (`.claude/agents/*.md` ausgenommen) | geprüft, ohne Befund — ADR-0048 trifft über diese Klasse keine Aussage. |
| ADR-0031 Option F — trägt die Charakterisierung in §Kontext? | geprüft, ohne Befund — nachgemessen: `Status: Proposed`, Option F ist eine **verworfene** Option (gewählt sind D und H), die Aussage steht in der Contra-Zelle und beruft sich auf ADR-0015, die sie nicht trägt. Die ADR nennt die Stelle korrekt *„ein Befund, keine Quelle"* und behebt sie nicht, sondern hält sie als Folgepflicht fest. |
| ADR-0040 Festlegung 1 und 2 im Acceptance-Trigger | geprüft, ohne Befund — der Trigger verlangt eine Runde der prüfenden Rolle, verwirft die Nachmessung des auflösenden Kontexts ausdrücklich und schreibt für die Accept-Zeile die Kennung statt des Pfad-Links vor. |
| MADR-Ziel-Form (`v6.8.0` · `regelwerk/modul-04-adrs.md` §Ziel-Form: ADR (MADR)) | geprüft, ohne Befund — Kopf (Status · Datum · Autor · Bezug · Schärft · Regeln), Kontext, Verglichene Alternativen, Entscheidung, Konsequenzen mit Fitness Function, Re-Evaluierungs-Trigger, Geschichte. `Schärft: —` ist die Template-Form für eine Prozess-ADR ohne Spec-Stratum. Ein fehlendes `Supersedes:`-Feld entspricht dem Bestand (ADR-0028, ADR-0046) und ist in der `Bezug:`-Zeile ausdrücklich begründet. |
| Mindestens drei Verglichene Alternativen, je mit Trade-off | geprüft, ohne Befund — vier (A *nichts tun* · B Datei-Lesart · C `Supersedes` · **D gewählt**), jede mit Pro und Contra; Option C hält die Gegenposition zum Verzicht auf `Supersedes` fest, Option B die zur Vorgangs-Achse. |
| Referenz-Richtung: referenziert der Kontext aufwärts? | geprüft, ohne Befund — ADRs, `AGENTS.md`, Baseline und `MR`-Einträge; Slice und Welle erscheinen als Kennung im Anlass, nicht als normative Stütze. |
| [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) — wird ein Gate behauptet? | geprüft, ohne Befund — §Fitness Function sagt für **beide** Festlegungen ausdrücklich *„keinen Wächter"*, nennt den Grund (kein Modul liest Commits; `make mutate` kennt dafür keine Fehlschlag-Form) und benennt die eine beobachtbare Hälfte (`git log --stat`) ausdrücklich als *kein Gate*. `grep -n '^modules:' .d-check.yml` bestätigt die Modul-Liste. |
| [`MR-033`](../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist) — Mess-Tag bei jeder Baseline-Aussage | geprüft, ohne Befund — die `Regeln:`-Zeile nennt `v6.8.0`, und beide Kommando-Blöcke lösen den Tag aus `BASELINE_TAG` auf, überleben den nächsten Sprung also. |
| [`AGENTS.md`](../../AGENTS.md) §3.11 — bewegte Adresse in einem einfrierenden Artefakt | geprüft, ohne Befund — `welle-09`/`welle-11`/`welle-13`, `slice-flache-welle-ist-eroeffnet-nicht-geplant` und der Review-Report stehen als **Kennung** ohne Pfad; kein Markdown-Link zeigt in den vendored Baum (`grep -c ']([^)]*\.harness/baseline/'` → **0**); die zwei Pfad-Links gehen auf `docs/plan/planning/README.md` und auf das Beobachtungs-Register — beides ortsfeste Ablagen. |
| [`AGENTS.md`](../../AGENTS.md) §3.7 — Chronik, Konjunktiv, Befund-Kennung in neuem Text | geprüft, ohne Befund — der Anlass steht im Indikativ, die verworfenen Optionen stehen in der dafür vorgesehenen Tabelle, und die Herkunft steht als **ein** auflösbares Feld (§Geschichte). |
| [`AGENTS.md`](../../AGENTS.md) §3.5 — Senkung ohne ADR | geprüft, ohne Befund — §Was diese Entscheidung nicht tut stellt ausdrücklich fest, dass keine Schwelle, kein Modul und keine Gate-Strenge bewegt wird. |
| [`AGENTS.md`](../../AGENTS.md) §3.8 — Commit-Zuschnitt und schreibende Rolle | geprüft, ohne Befund — `git show ea3a41b8 --stat`: zwei Dateien, die ADR und der ADR-Index, der ihr nach ADR-0024 folgt; Subject nennt *„Rolle Architect"*; `Bezug:`-Zeile mit ADR- und `LH-`-IDs; 0 Treffer für `co-authored-by\|generated with\|claude code\|anthropic`. |
| [`AGENTS.md`](../../AGENTS.md) §3.10 — legt die Datei eine Beobachtung an oder schreibt sie einen Abschluss? | geprüft, ohne Befund — §Was diese Entscheidung nicht tut verweist die Register-Route ausdrücklich an die Closure, und die Folgepflicht (Planner) tut dasselbe; im Diff liegt kein Register- und kein Closure-Artefakt. |
| [ADR-0028](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Festlegung 1 — schreibt dieser Lauf fremde Anweisungssätze? | geprüft, ohne Befund — die Folgepflicht (Reviewer) überlässt `.harness/skills/reviewer.md` ausdrücklich dem Reviewer; die ADR schreibt sie nicht. |
| Cutoff und Geltungsbereich | geprüft, ohne Befund — *„ab der Annahme dieser Entscheidung, kein Nachrüsten"* mit derselben Begründung wie ADR-0015/ADR-0024, und *„Geltungsbereich: dieses Repo"* mit Verweis der emittierten Ebene an den Tool-Slice. |
| Konflikt-Pfad: ist das gewählte Verdikt eines der drei zulässigen? | geprüft, ohne Befund — *„Lockerung legitim, aber undokumentiert"* ist das dritte der drei aus `v6.8.0` · `regelwerk/modul-08-agentenrollen.md` §Konflikt-Pfad als Rollen-Sequenz; §Was diese Entscheidung nicht tut schließt das Herabstufen ausdrücklich aus, und das Finding F-1 bleibt HIGH. |
| ADR-Index-Zeile (derivativ nach [ADR-0024](../plan/adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md)) | geprüft, ohne Befund — vier Spalten wie der Bestand, Titel wörtlich aus der `# `-Überschrift, Status `Proposed` aus dem Kopffeld, `Bezug` vollständig aus der `**Bezug:**`-Zeile, Pfad-Tiefe `../../../` wie in den übrigen Zeilen. |
| Links, Anker, IDs, Spans über den Diff | geprüft, ohne Befund — `make docs-check` real gefahren: 1315 Dateien, 0 Befunde, Module `links`/`anchors`/`ids`/`matrix`/`codepaths`/`spans`/`planning`/`targets`. |
| Wortlaut-Proben der zitierten ADR-Stellen | geprüft, ohne Befund — die drei `grep -c`-Zitate aus ADR-0046, ADR-0015 und ADR-0028 liefern je **1**; das Zitat aus dem Beobachtungs-Register (*„dessen Eigentum eine Quelle einer anderen Rolle zuweist"*) steht dort umbrochen und trifft whitespace-normalisiert (**1**) nach [ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 2. |
| Out-of-Scope: die vier Träger des auslösenden Commits | geprüft, ohne Befund — nicht im Diff; ihre Prüfung liegt beim Vorgänger-Report. |
| Out-of-Scope: Produkt-Code, Gate-Konfiguration, emittierte Ebene | geprüft, ohne Befund — `internal/`, `cmd/`, `harness/tools/`, `.d-check.yml`, `internal/emit/templates/` sind unberührt. |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 1 |
| MEDIUM | 5 |
| LOW | 3 |
| INFO | 2 |

**Finding-Klassen dieses Laufs:** Mess-Zusage trifft das eigene Zitat · Geltungsbereich einer
Festlegung in Überschrift und Rumpf verschieden breit · Probe verlangt weniger, als ihr Name und
ihr Beleg zusagen · Zusammenfassung stärker als ihre Quelle · Acceptance-Trigger ohne Fach für den
gemeldeten Befund · Stellen-Messung trägt die Folgerung über eine Eigenschaft · Zwei Limitatoren
ohne Verknüpfungsregel · Zahl ohne Kommando trifft ihren Gegenstand nicht · Auslegungs-Ort nicht
als Wahl benannt · Folgepflicht wartet auf einen blockierten Statuswechsel

*MEDIUM-3 und LOW-1 tragen dieselbe Klasse und stammen aus demselben Vorgang — für den Zähler
**eine** Gelegenheit (`v6.8.0` · `regelwerk/modul-06-roadmap.md` §Das Beobachtungs-Register:
„Zwei Funde im selben Vorgang sind eine Gelegenheit").*

## Verdikt

**Der Beleg trägt in dieser Fassung nicht — ein HIGH und zwei MEDIUM an der Substanz stehen.**

Die drei Fragen des Auftrags getrennt, weil der Acceptance-Trigger sie trennt:

1. **Die Kern-These beider Festlegungen ist bestätigt.** Festlegung 1 schließt eine Lücke, die
   [ADR-0015](../plan/adr/0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1 ausdrücklich
   offen lässt; der Befund ist nachgemessen: `v6.8.0` · `regelwerk/modul-08-agentenrollen.md`
   weist die **Eröffnung** zu und führt die Closure als Schritt-Tabelle,
   [`AGENTS.md`](../../AGENTS.md) §3.10 bindet den **Abschluss** — eine Text-Änderung an einem
   bereits eröffneten Welle-Plan fällt zwischen beide. Festlegung 2 trägt ebenfalls: Der
   ausgelegte Satz steht in einer **Abgrenzungs**-Sektion, ist grammatisch **ableitend** gebaut
   und setzt keine eigene Zuweisung. *Ein `Supersedes` auf ADR-0046 ist nicht erforderlich; die
   Wahl von Option D über Option C ist begründet und durch
   [`AGENTS.md`](../../AGENTS.md) §3.11 präzedenziert.* **Auftrag 3 ist damit bejaht.**
2. **Blockierend ist HIGH-1.** Die Messung, die §Kontext trägt, liefert an keinem Stand nach dem
   eigenen Commit die abgedruckte Zahl, und Re-Evaluierungs-Trigger 1 hängt als **Ordnungszahl**
   an genau diesem Kommando — er ist im Moment des Einfrierens von Festlegung 1 selbst erfüllt.
   Ein Trigger, der beim Accept schon gefeuert hat, ist keiner, und nach
   [`AGENTS.md`](../../AGENTS.md) §3.4 ist er danach nur noch per Folge-ADR erreichbar.
3. **Blockierend sind außerdem MEDIUM-1 und MEDIUM-2, und sie liegen an der Substanz von
   Festlegung 1** — damit in dem Fach, das der eigene Trigger als blockierend bezeichnet.
   MEDIUM-1: Der Geltungsbereich steht in zwei Breiten da (*„ein Planungs-Artefakt"* gegen
   *„für den Welle-Plan"*), der Begriff ist nicht abgegrenzt, und die Datei wendet die breite
   Lesart bereits auf `docs/plan/planning/README.md` an. MEDIUM-2 beantwortet Auftrag 4: Die
   Drei-Bedingungen-Probe ist **nicht zirkulär** — Bedingung 2 misst den ersetzten, Bedingung 3
   den neuen Text, das ist ein sinnvolles Paar —, aber sie ist **unterbestimmt**: keine der drei
   Bedingungen bindet den nachgezogenen Text an das Original, das Bedingung 1 verlangt. Die
   Byte-Gleichheit, die den Fall tatsächlich entschied, steht in §Kontext und nicht in der Probe;
   und Bedingung 1 öffnet alle neun Ränge, einschließlich der Roadmap, die ADR-0046 dem Planner
   zuweist.

**Nicht blockierend, aber vor dem Umschlag zu beheben**, weil sie danach nach
[`AGENTS.md`](../../AGENTS.md) §3.4 nur noch per Folge-ADR korrigierbar sind: MEDIUM-3 (die
Genealogie-Aussage über ADR-0028), MEDIUM-4 (das fehlende dritte Fach im eigenen
Acceptance-Trigger), MEDIUM-5 (die Zwei-Token-Messung unter der tragenden Negativ-Prämisse) und
die drei LOW. Die zwei INFO sind Notizen ohne Handlungspflicht.

**Eine Einordnung, die der Trigger selbst nicht liefert.** HIGH-1 liegt an einem
Re-Evaluierungs-Trigger, MEDIUM-3 an §Konsequenzen — beide Abschnitte frieren mit dem Accept ein
und tragen keine Festlegung. Der Trigger dieser Datei kennt dafür kein Fach; sein Vorgänger
[ADR-0046](../plan/adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) hat genau dieses Fach nach
derselben Beobachtung ergänzt. Dieser Report verdiktiert HIGH-1 deshalb aus eigener
Kategorisierung als blockierend (Kontext-Eskalation des Skills, §Klassifikation), nicht aus dem
Trigger-Wortlaut — und benennt die Lücke als MEDIUM-4, damit der Architect sie schärfen kann,
solange die Datei `Proposed` ist
([ADR-0040](../plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 3).
**Der Preis steht daneben**, und ADR-0046 hat ihn für sich selbst notiert: Wer den Trigger ändert,
während eine Runde gegen seine frühere Fassung vorliegt, verschiebt deren Verdikt, statt es zu
erfüllen.

**Was nach diesem Verdikt gilt:** Ist ein blockierender Befund gemeldet, ist der Beleg nach
[ADR-0040](../plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 2 die
**nächste Runde derselben prüfenden Rolle** — nicht die Nachmessung des Laufs, der den Befund
auflöst.

**Übergabe:** Die Findings gehen an den **Architect**, der die Datei hält; sie steht auf
`Proposed`, und jede Behebung ist bis zum Umschlag ohne Folge-ADR möglich. Die
**Finding-Klassen** gehen zusätzlich in die Slice-Closure §7 und von dort in den Zähler — die
Zuordnung zu einer vorhandenen oder neuen Kennung trifft die Closure und gehört dem Planner
([`AGENTS.md`](../../AGENTS.md) §3.10), nicht dieser Report. Dieser Report selbst ist ein
**Lauf-Beleg** (Audit: dieser Stand, dieser Skill, dieses Modell, dieses Verdikt) — er wird über
Läufe hinweg nicht wieder gelesen. Der Report ersetzt keine Verifikation — DoD-/Spec-Konformität
prüft der Verifier separat (Modul 11; anderes Prüf-Artefakt, anderer Eingabe-Kontext).
