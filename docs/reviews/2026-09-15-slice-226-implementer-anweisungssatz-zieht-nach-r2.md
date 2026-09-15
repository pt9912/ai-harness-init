# Review-Report: slice-226-implementer-anweisungssatz-zieht-nach — Runde 2 — 2026-09-15

**Review-Art:** Code-Review gegen **Plan + ADRs + Hard Rules** (Modul 10 §Drei Review-Arten).
Gegenstand sind zwei **Nacharbeits-Commits** an einem Rollen-Anweisungssatz und an dem
Slice-Plan, der ihn abnimmt — eine Markdown-Lauf-Instruktion und ihr Abnahme-Kontrakt, kein
ausführbarer Pfad. **Kein DoD-Review** — DoD-/Spec-Konformität prüft der Verifier
(Modul 11, anderer Eingabe-Kontext).

**Gegenstand dieser Runde:** die zwei Commits, die die Befunde der Runde 1 versorgen —

- `b053b205` (Rolle Implementer) — **eine** Datei, +4/−2: `.claude/commands/implement-slice.md`
- `89919a1a` (Rolle Planner) — **eine** Datei, +15/−7: `slice-226-implementer-anweisungssatz-zieht-nach` §1 · §2 Liefer-Punkt 1 · §2 Liefer-Punkt 2

Beide Commits sind Vorfahren von `HEAD`; danach hat kein Commit eine der zwei Dateien berührt
(`git log --oneline 89919a1a..HEAD -- .claude/commands/implement-slice.md 'docs/plan/planning/in-progress/slice-226-*'`
→ leer), `git status --porcelain` → leer. **Runde 1** dieses Gegenstands:
`docs/reviews/2026-09-15-slice-226-implementer-anweisungssatz-zieht-nach.md` (`e8a8187a`),
**0 HIGH · 2 MEDIUM · 3 INFO**.

**Kein Self-Review:** dieser Lauf hat an dem Gegenstand **nicht** geschrieben — weder an den
Commits noch an den zwei Dateien noch an einer Vorlage daraus. Kein Befund dieses Reports ist
aus einer Commit-Message oder einem Implementer-Bericht übernommen; jede Zahl unten ist in
diesem Lauf gefahren.

**Skill:** `.harness/skills/reviewer.md` @ `0565f274` (2.0.0) · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** deepseek-v4.1-flash:cloud[1m] · **Datum:** 2026-09-15

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
> Stand des Laufs und darf ihn festhalten.

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde):

- Slice-Plan `slice-226-implementer-anweisungssatz-zieht-nach` — §1 (Ziel und Abgrenzung),
  §2 DoD 1/2, §3 (Plan), §5 (Closure-Trigger), §6 (Risiken), §8 (Sub-Area)
- Runde-1-Report desselben Gegenstands (`e8a8187a`) — seine Befunde F-1 … F-5 sind der Prüfstand dieser Runde
- [`AGENTS.md`](../../AGENTS.md) §3 (Hard Rules; tragend hier §3.6, §3.7, §3.10, §3.11) · §2
  (Source Precedence) · §6 (Minimal Agent Workflow)
- [`ADR-0028`](../../docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) (Festlegung 1
  Eigentum, Festlegung 2 Grenze der Ableitung) · [`ADR-0051`](../../docs/plan/adr/0051-anweisungssatz-eigentum-traegt-ueber-die-emissionsgrenze.md)
- [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) ·
  [`MR-033`](../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist) ·
  [`MR-057`](../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer) (Setzung 3) ·
  [`MR-058`](../../harness/conventions.md#mr-058--eine-messung-die-ihr-eigener-vorgang-bewegt-wird-nach-dem-vorgang-genommen) (Setzung 2)
- [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) ·
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
- Baseline `v6.8.0` · `regelwerk/modul-09-implementierung.md` §Minimal Agent Workflow ·
  `regelwerk/modul-10-review-harness.md` §Ziel-Form: Reviewer-Skill
- Vorherige Findings an den Schwester-Gegenständen dieser Sitzung; die wiederkehrende Klasse hier
  ist `uebernahme-ohne-rollen-zuordnung` (Runde 1, F-1)

---

## Eigene Messungen

Jedes Kommando dieses Abschnitts ist in diesem Lauf gefahren. Wo eine Zahl steht, steht das
Kommando daneben, das sie liefert; **keine Erwartungswerte**
([`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2).

### 1. F-2 — beide Sonden heute, und ihr Zahn am Anlege-Stand

```sh
git grep -cE 'slice-<NNN>|welle-<NN>' -- .claude/commands/implement-slice.md
#  (keine Ausgabe)                                                        EXIT 1
git grep -cE 'slice-<NNN>|welle-<NN>|<slice-NNN>|<welle-NN>' -- .claude/commands/implement-slice.md
#  (keine Ausgabe)                                                        EXIT 1
git grep -cE 'slice-<NNN>|welle-<NN>|<slice-NNN>|<welle-NN>' bbd10ea2^ -- .claude/commands/implement-slice.md
#  bbd10ea2^:.claude/commands/implement-slice.md:5                        EXIT 0
git grep -cE 'slice-<NNN>|welle-<NN>'                        bbd10ea2^ -- .claude/commands/implement-slice.md
#  bbd10ea2^:.claude/commands/implement-slice.md:3                        EXIT 0
```

**Die Zahl des Anlass-Blocks trägt, und der Zahn der breiten Sonde ist sichtbar.** Die zwei
Zeilen, die die breite Sonde **mehr** sieht als die schmale, sind genau die zwei Stellen der
geklammerten Form — `git grep -nE … bbd10ea2^ -- .claude/commands/implement-slice.md` →
Zeile **58** und Zeile **159**, beide `SLICE=<slice-NNN>`, daneben die drei Zeilen **133**,
**173**, **182** der spitzen Form. Die Erweiterung schneidet damit ihren Gegenstand: sie färbt
eine Wiederkehr der geklammerten Form rot, die die alte Sonde grün durchgelassen hätte.

**Zwei Zahlen über denselben Stand, beide richtig und beide verschieden:** `git grep -c`
zählt **Zeilen** (5), `git show bbd10ea2^:… | grep -oE … | wc -l` zählt **Vorkommen** (**7**,
weil Zeile 133 zwei Formen trägt). Der Betrag neben dem Kommando ist der des Kommandos
(5) — das ist die Form, die [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
verlangt; das Substantiv „Stellen" im Satz daneben trifft die Vorkommen (7).

### 2. F-2 — schneidet die breite Sonde jetzt zu viel?

```sh
git grep -cE 'slice-<NNN>|welle-<NN>'                 -- docs/plan/planning/open | awk -F: '{s+=$NF} END{print s+0}'   #  0
git grep -cE 'slice-<NNN>|welle-<NN>|<slice-NNN>|<welle-NN>' -- docs/plan/planning/open | awk -F: '{s+=$NF} END{print s+0}'   # 10
git grep -ohE '<slice-NNN>|<welle-NN>|slice-<NNN>|welle-<NN>' -- docs/plan/planning/open | sort | uniq -c
#  10 <slice-NNN>
```

**In ihrem deklarierten Prüfbereich nicht — außerhalb seiner ja, und die Trennlinie ist
gemessen.** Alle zehn Zusatz-Treffer stammen aus **einer** Form: `<slice-NNN>`, und zwar in der
Meta-Notation einer Auslöser-Zeile (`Auslöser: `BEO-<NNN>` (`<slice-NNN>`, `<slice-MMM>`,
`<slice-KKK>` — 3×)` in zehn Plänen unter `open/`), die „drei Slices" meint und nicht die alte
Notation ist. Dieselbe Überdeckung trifft `AGENTS.md:282`, wo die Form als **Suchmuster-Zitat**
steht und nach [`AGENTS.md`](../../AGENTS.md) §3.7 ausdrücklich wörtlich bleibt. Beide liegen
außerhalb des Kommandos dieses Slice; F-1 der Messung (§1) — kein Befund gegen den Diff, die
Grenze als **N-1** gemeldet.

### 3. F-2 — trägt der Ref `bbd10ea2^`?

```sh
git log --oneline -1 bbd10ea2^          # e71d061b Rolle Planner: In-Arbeit-Zeile -- slice-226-… beansprucht
git log --oneline -1 bbd10ea2           # bbd10ea2  Rolle Implementer: Der Implementer-Anweisungssatz zieht …
git show --stat e71d061b | tail -3      # docs/plan/planning/in-progress/roadmap.md | 2 +-   (Nichts in Arbeit. → In Arbeit: slice-226-…)
git log --oneline --follow --diff-filter=A -- 'docs/plan/planning/*/slice-226-*' | tail -1
#  351e0883 Rolle Planner: Traeger fuer die drei offenen Sendungen aus slice-224      ← der Anlege-Commit des Plans
for c in 351e0883 e71d061b bbd10ea2^; do git show $c:.claude/commands/implement-slice.md | grep -cE 'slice-<NNN>|welle-<NN>|<slice-NNN>|<welle-NN>'; done
#  5 / 5 / 5   — die Zahl ist an **jedem** Vor-Stand dieselbe
```

**Der Ref löst auf (5, EXIT 0) und er ist unveränderlich** — er wandert nicht, wenn der Plan bei
der Closure nach `done/` geht; [`AGENTS.md`](../../AGENTS.md) §3.11 bindet bewegte **Adressen**,
ein Commit ist keine. Die Prosabezeichnung „am Anlege-Commit" trifft ihren Ref aber nicht
eindeutig: `bbd10ea2^` ist der **Beanspruchungs-Commit** (`e71d061b`, die In-Arbeit-Zeile),
während dieses Repo „Anlege-Commit" sonst für den **Erzeugungs-Commit des Artefakts** führt
(`ADR-0028` §Der Anlass und §Kontext — *„am Anlege-Commit dieser ADR"*; `ADR-0051` —
*„gemessen am Anlege-Commit"*; `next/slice-114-…` §8 — *„Anlege-Commit `d30db38`"*) — für
diesen Plan `351e0883`. **Material ist die Unschärfe nicht:** die Zahl 5 gilt an allen drei
Ständen. Als **N-2** gemeldet, nicht blockierend.

### 4. F-2 — die Zitation von [`MR-058`](../../harness/conventions.md#mr-058--eine-messung-die-ihr-eigener-vorgang-bewegt-wird-nach-dem-vorgang-genommen)

Setzung 2 des Eintrags lautet wörtlich: *„bewegt der schreibende Vorgang seine eigene Bezugsmenge,
wird die Messung über den Zustand **nach** dem Vorgang genommen."* — der Plan misst §1 am
Zustand **vor** dem Nachzug und §2 nach ihm (`EXIT 1` ohne Ref, §1 oben). Dieselbe
Vor-Stand-Bindung mit Ref und Zitation von
[`MR-058`](../../harness/conventions.md#mr-058--eine-messung-die-ihr-eigener-vorgang-bewegt-wird-nach-dem-vorgang-genommen)
Setzung 2 und 3 führt der lebende Bestand in `harness/migration.md:122` (*„am Stand dieses
Commits **382**"*, mit *„kein Endwert"*) — die Lesart, unter der eine auf einen unveränderlichen
Stand **gepinnte** Zahl keine „von ihrem eigenen Vorgang bewegte" ist, ist damit die des Repos.
Beide Fassungen erfüllen den Eintrag: §2 seine Nachher-Hälfte, §1 seine Pin-Hälfte. Kein Befund.

### 5. F-4 — der Regelwerks-Name und sein Stand

```sh
grep -n 'Tests-Zeile' .harness/baseline/v6.8.0/regelwerk/modul-09-implementierung.md
#  27:**Die Tests-Zeile bindet an die Akzeptanzkriterien der in Schritt 3
cd <Klon des Kurs-Repos>
git diff --stat v6.7.2..v6.8.0 -- lab/regelwerk/modul-09-implementierung.md   # leer
```

Der Plan führt jetzt beide Formen und nennt den Stand (`v6.8.0`); der zitierte Regelwerks-Name
**existiert am gepinnten Tag wörtlich** (Zeile 27). Die zwei Basen des Plans — Delta-Basis
`v6.7.2` (§1, Bezug über [`ADR-0044`](../../docs/plan/adr/0044-ziel-fassung-regiert-den-sprung-v672.md))
und Beleg-Basis `v6.8.0` (DoD 1) — **divergieren für diese Datei nicht**: der Diff zwischen
beiden Tags über sie ist leer. [`ADR-0044`](../../docs/plan/adr/0044-ziel-fassung-regiert-den-sprung-v672.md)
ist `Accepted` und **nicht** superseded (`grep -F '**Supersedes' docs/plan/adr/0047-…-v680.md`
→ kein Treffer; `ADR-0047` nennt sie in §Bezug als *„die regierende Fassung des vorigen,
vollzogenen Sprungs"*).

### 6. Der Closure-Trigger trägt kein zweites Kommando

```sh
grep -n 'git grep\|git diff --shortstat' docs/plan/planning/in-progress/slice-226-*.md
#  76: git diff --shortstat …            (§1, Delta-Nachweis)
#  98: git grep -cE … bbd10ea2^ …       (§1, Anlass-Zahl mit Ref)
# 123: (git grep -cE … | awk …)         (§1, emittierte Ebene)
# 154: git grep -cE …                   (§2 Liefer-Punkt 2, Nachzug ohne Ref)
```

§5 des Plans nennt *„das Notations-Kommando"* und führt **keinen** Code-Block: die eine Sonde
steht in §2 Liefer-Punkt 2, §5 verweist auf sie. Die Behebung ist damit an **einer** Stelle
gezogen und nicht an zweien.

### 7. Kein neuer Wächter — die Aussage stimmt

```sh
git show --stat --format='%h %s' b053b205 89919a1a | grep -E '^\s' | grep -v '^commit'
#  .claude/commands/implement-slice.md | 6 ++++--
#  …slice-226-implementer-anweisungssatz-zieht-nach.md | 22 +++++++++++------
grep -n '^modules:' .d-check.yml
#  29:modules: [links, anchors, ids, matrix, codepaths, spans, planning, targets]
grep -rn 'slice-<NNN>\|welle-<NN>' --include='*.sh' --include='*.yml' --include='Makefile' --include='*.bats' --include='*.go' . | grep -v '^./.harness/baseline/'
#  test/mutations/215-welle-results-als-singleton.sh:8    (Kommentar, anderer Gegenstand)
#  internal/emit/templates.go:30                          (Doc-Kommentar, anderer Gegenstand)
```

Zwei Commits, zwei Dateien, **keine** Testdatei, kein Mutations-Fall, keine Gate-Config, kein
Makefile-Ziel, kein Hook — die Suche nach der Notation führt weiterhin nur die zwei
vorbestehenden Träger. **Kein voller `make mutate`** (Post-integration-Stufe,
`v6.8.0` · `regelwerk/grundlagen-klassifikation.md` §Klassifikation und Steering Loop ›
Lifecycle-Verteilung); er hätte hier auch kein Objekt: kein Wächter ist entstanden, und die
Zusage des Nachzugs trägt ihr rot gesehenes Gegenbeispiel in §1 dieser Messung (EXIT 0 auf `5`
am Vor-Stand, EXIT 1 danach).

### 8. `Makefile:340` — die eine lebende Fundstelle außerhalb

```sh
git grep -nE 'slice-<NNN>|welle-<NN>|<slice-NNN>|<welle-NN>' -- Makefile harness/tools/slice-mv.sh harness/sensors/slice-mv.md
#  Makefile:340:slice-mv: ## Lifecycle-Wechsel eines Slice inkl. Verweise (SLICE=<slice-NNN> TO=<open|next|in-progress|done>) — NICHT in gates
for c in 351e0883 21f8da86 bbd10ea2 HEAD; do git show $c:Makefile | sed -n '340p'; done   # viermal dieselbe Zeile
```

**Der Singular der DoD-2 trägt.** Die zweite Stelle, die Runde 1 als Träger nannte
(`harness/tools/slice-mv.sh:170`), führt die alte Form **nicht mehr**; `harness/sensors/slice-mv.md`
führt die Ziel-Form. Die Adresse ist eine **Zeilennummer** in einer lebenden Datei; sie war über
die vier geprüften Stände stabil — beide Eigenschaften zusammen sind die Grenze dieser Nennung,
kein Befund.

### 9. `make gates`

```text
$ make gates
baseline-verify: v6.8.0 OK — 54 Dateien (Integritaet + Vollstaendigkeit, netzlos)
d-check: 1417 Datei(en) geprüft, 0 Befund(e)
comment-claims: 59 Datei(en) geprueft, 0 Befund(e)
span-check: Traeger vorhanden, span-emit hat einen Span geschrieben, Ablageort git-ignoriert
EXIT=0
```

**EXIT 0** auf dem geprüften Stand (`HEAD = 89919a1a`, Arbeitsbaum leer). Die Kette ist
vollständig gefahren: `golangci-lint` · `shellcheck` · `actionlint` · `go test`
(281 × `ok`, 0 × `not ok` in den bats- und Go-Stufen) · `docs-check` (1417/0) ·
`comment-claims` (59/0) · `baseline-verify` (54 Dateien, `OK`). Die entscheidende Zeile ist die
Zählung des Doku-Gates — die geänderte Datei liegt in seinem Prüfbereich
(`scan.roots: ["."]`, nicht in `scan.ignore`), und ihre neuen Zeilen führen keine bloße
Kennung: die zwei `make`-Zeilen nennen existierende Targets
(`grep -nE '^(slice-mv|gates):' Makefile` → `Makefile:340`, `Makefile:427`), die Zitate sind
Inline-Code. Ein zweiter Lauf nach dem Commit dieser Report-Datei deckt sie mit ab (§Verdikt).

---

## Was Runde 1 gemeldet hat — Stand jetzt

| Runde 1 | Kategorie | Stand | Beleg dieses Laufs |
|---|---|---|---|
| F-1 | MEDIUM | **behoben** | `.claude/commands/implement-slice.md:95-98` nennt jetzt Adressat und Quelle („**Planner-Arbeit**", „**Übergabe-Artefakt** an den Planner (`AGENTS.md` §3.10)") — §Negativbefunde, Zeile *F-1 gegen §3.10* |
| F-2 | MEDIUM | **behoben** | beide Sonden lesen die zwei Schreibweisen (§1, §2 oben); die Zahl steht am Anlege-Stand und ist fahrbar (§3); der Nachzug ist an **einer** Stelle gezogen (§6) |
| F-3 | INFO | **benannt** | die eine verbliebene lebende Fundstelle (`Makefile:340`) steht jetzt in §2 Liefer-Punkt 2 (§8); der zweite damals genannte Träger führt die Form nicht mehr |
| F-4 | INFO | **behoben** | beide Formen stehen im DoD-Punkt, der Regelwerks-Name wörtlich belegt, Stand genannt (§5) |
| F-5 | INFO | **unverändert offen** | kein dauerhafter Wächter — bestätigt in §7; §1 schließt seinen Bau weiterhin aus, §6 führt die Lücke als Risiko |

**Kein Befund aus Runde 1 ist „neu entstanden"** — die zwei Behebungen haben ihre Kanten, aber
keine davon erzeugt einen neuen Mangel; die zwei neuen INFO unten benennen **Grenzen** der
Behebung, keinen Fehler.

## Findings

Jedes Finding folgt dem **§Output-Schema des Reviewer-Skills**. Die Spalten sind gespiegelt, nicht
neu definiert; bei Abweichung gilt der Skill.

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| N-1 | INFO | Die breite Notations-Sonde trägt **in ihrem deklarierten Prüfbereich** (die eine Datei) — außerhalb seiner deckt sie eine **Meta-Notation** mit: ihre zwei geklammerten Alternativen (`<slice-NNN>`, `<welle-NN>`) treffen die Auslöser-Zeile `(<slice-NNN>, <slice-MMM>, <slice-KKK> — 3×)` in zehn Plänen unter `open/` (schmal **0**, breit **10**, allein aus `<slice-NNN>`), die „drei Slices" meint und nicht die alte Form, sowie das Suchmuster-Zitat in [`AGENTS.md`](../../AGENTS.md):282, das §3.7 dort ausdrücklich stehen lässt. Die Sonde setzt damit unausgesprochen voraus, daß `<slice-NNN>` **innerhalb** der Datei nur die alte Form sein kann — heute wahr (5 von 5 Treffern am Vor-Stand sind die alte Form, §1), repo-weit falsch. Wer sie auf einen weiteren Baum legt, wie slice-224 es für den Planungs-Baum tat, liest Falsch-Treffer. | [`MR-057`](../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer) Setzung 3 · `slice-226-implementer-anweisungssatz-zieht-nach` §1 · §2 Liefer-Punkt 2 | `docs/plan/planning/done/slice-226-implementer-anweisungssatz-zieht-nach.md:98` · `:154` | ja — die zwei Kommandos in §2 dieser Messung, beide gefahren | notations-sonde-ueberdeckt-eine-meta-notation *(**neu***) |
| N-2 | INFO | Der Anlass-Block bindet seine Zahl an `bbd10ea2^` und nennt diesen Stand in Prosa **„der Anlege-Commit"**. Der Ref ist der **Beanspruchungs-Commit** (`e71d061b`, *„In-Arbeit-Zeile — slice-226-… beansprucht"*, die Roadmap-Zeile), während dasselbe Repo „Anlege-Commit" sonst für den **Erzeugungs-Commit des Artefakts** führt (dort wäre es `351e0883`). Die Unschärfe ist **inert** — die Zahl 5 gilt an allen drei Vor-Ständen (gemessen, §3), und das Kommando im Block nennt den Ref ausdrücklich —, aber die Prosa-Bezeichnung löst **für sich** nicht auf. | [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) · [`MR-058`](../../harness/conventions.md#mr-058--eine-messung-die-ihr-eigener-vorgang-bewegt-wird-nach-dem-vorgang-genommen) | `docs/plan/planning/done/slice-226-implementer-anweisungssatz-zieht-nach.md:93-98` | ja — `git log --oneline -1 bbd10ea2^` gegen `git log --diff-filter=A -- 'docs/plan/planning/*/slice-226-*'` | mess-stand-in-der-prosa-loest-nicht-auf *(**neu***) |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| **F-1 gegen [`AGENTS.md`](../../AGENTS.md) §3.10 — sagt der neue Satz mehr oder weniger als die Hard Rule?** | **geprüft, ohne Befund.** §3.10 sagt: *„Fällt im ausführenden Lauf eine Änderung an, die die **Abnahme selbst** verschiebt (ein DoD-Punkt, ein Closure-Trigger, eine **Out-of-Scope-Grenze**), ist sie kein Closure-Schritt, sondern ein **Übergabe-Artefakt** an den Planner: die ausführende Rolle schreibt ihr eigenes Abnahmekriterium nicht um."* Die zwei tragenden Halbsätze sind **wörtlich** übernommen, „Planner-Arbeit" ist §3.10s eigener Term (*„Der Abschluss eines Slice ist **Planner-Arbeit**"*), die Quelle steht als Adresse daneben. **Nicht zu weit:** §3.10 nennt als Adressaten den Planner — der Satz nennt ihn. **Nicht zu eng:** „kein Schritt dieses Laufs" wird im selben Satz durch *„ist ein Übergabe-Artefakt an den Planner"* qualifiziert, die Übergabe also nicht weggenommen. Die drei übrigen §3.10-Gegenstände (DoD-Punkt, Closure-Trigger) bleiben unberührt, weil der Block nur den Out-of-Scope-Fall führt. Der Satz überträgt damit **genau** die Hard Rule, nicht mehr. |
| **F-1 und [`AGENTS.md`](../../AGENTS.md) §3.7 — Zustand oder Vorgang?** | **geprüft, ohne Befund.** „ist das **Planner-Arbeit**", „ist ein **Übergabe-Artefakt** an den Planner" — Indikativ und Zuordnung, keine verworfene Alternative, kein *„vorher stand"*, keine Befund-Kennung, kein Lauf-Protokoll, kein Zeilenverweis. Die zwei Nachsätze („Die Plan-Änderung geht dem Code voraus, keine Zeile im Bericht danach") stehen im Indikativ über eine Abfolge und sind aus dem Modul erhalten. |
| **[`MR-058`](../../harness/conventions.md#mr-058--eine-messung-die-ihr-eigener-vorgang-bewegt-wird-nach-dem-vorgang-genommen) — die Zitation am Anlass-Block** | **geprüft, ohne Befund — mit benannter Doppellesart.** Setzung 2 nimmt die Messung *über den Zustand **nach** dem Vorgang*; §2 des Plans tut das (EXIT 1 ohne Ref), §1 pinnt die Vor-Stand-Zahl an einen unveränderlichen Ref. Dieselbe Bauart führt der lebende Bestand in `harness/migration.md:122` (Zahl „am Stand dieses Commits", Zitation von Setzung 2 **und** 3) — die Pin-Lesart ist damit die des Repos, und der Betrag am Vor-Stand kann nicht falsch werden, weil nichts ihn mehr bewegt. **Beide Lesarten stehen offen**; die Entscheidung ist nicht die des Reviewers. |
| **`bbd10ea2^` als Adresse in einem Plan, der bei Closure nach `done/` wandert ([`AGENTS.md`](../../AGENTS.md) §3.11)** | **geprüft, ohne Befund.** §3.11 bindet Adressen auf Artefakte, deren **Ort** der Prozess bewegt; ein Commit-Hash wird von keinem `git mv` bewegt und löst in jedem Zustand des Repos auf, in dem er erreichbar ist. Gemessen: `git grep -cE … bbd10ea2^ -- .claude/commands/implement-slice.md` → `5`, EXIT 0. Die einzige Unschärfe ist die Prosabezeichnung — N-2. |
| **Die Zahl „5" — trägt sie gegen [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)?** | **geprüft, ohne Befund.** Das Kommando steht im selben Code-Block und liefert exakt 5; es ist auf einen unveränderlichen Ref gebunden und damit **kein** wandernder Wert. Die zweite zählbare Größe desselben Stands (Vorkommen: 7) steht in §1 dieser Messung — der Betrag neben dem Kommando ist der des Kommandos; das Substantiv „Stellen" daneben ist ungenau, aber die Zahl trägt. |
| **Der emittierte Prüfbereich — bleibt er draußen, und stimmt seine Zahl?** | **geprüft, ohne Befund.** §1 schließt ihn aus (`make full-smoke` als eigener Beleg, [`MR-054`](../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel), [`MR-017`](../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)); die Zahl **6** daneben bleibt richtig und ist von der Behebungs-Sonde **nicht** betroffen: ihre Sonde ist die schmale, gemessen liefern schmal und breit dort dieselben **6** (`internal/emit/templates/commands/close-welle.md:2` + `…/implement-slice.md:4`). Die zwei ungleichen Sonden in derselben Sektion sind damit ohne Zahlenfolge. |
| **Ein neuer Wächter oder ein halluziniertes Gate** | **geprüft, ohne Befund.** Kein neuer Wächter entstanden (§7, gemessen über zwei Commit-Zuschnitte und die Gate-Config); kein `make`-Ziel neu genannt (`Makefile:340`, `Makefile:427` existieren); `harness/README.md` §Sensors unberührt. |
| **Slice referenziert eine superseded ADR** | **geprüft, ohne Befund.** [`ADR-0044`](../../docs/plan/adr/0044-ziel-fassung-regiert-den-sprung-v672.md) ist `Accepted`, und [`ADR-0047`](../../docs/plan/adr/0047-ziel-fassung-regiert-den-sprung-v680.md) führt **kein** `Supersedes`-Feld; sie nennt ADR-0044 in §Bezug als *„die regierende Fassung des vorigen, vollzogenen Sprungs"*. |
| **F-4 — die Selbstbezüglichkeit des DoD-Punktes** | **geprüft, ohne Befund.** Die neue Klausel (*„so nennt dieser Punkt die Stelle; das Regelwerk führt sie als „Tests-Zeile"")* beschreibt die Kopplung zweier Namen an derselben Stelle — eine der fünf Kommentar-Klassen —, nicht die Entstehung des eigenen Textes: keine Befund-Kennung, keine Runde, kein *„hier stand bis"*. Ein Plan ist zudem kein Code-/Config-/Skript-Artefakt im Sinne der §3.7-HIGH-Klausel des Reviewer-Skills. |
| **[`ADR-0028`](../../docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Festlegung 1/2 — hält der Zuschnitt?** | **geprüft, ohne Befund.** Die Datei ist der Anweisungssatz der **Implementer**-Rolle, ihre Commit-Message nennt sie; die zwei Posten, die die Abnahme selbst treffen (F-2, F-4), sind vom **Planner** gezogen — sie berühren §2 und §5 des Plans, nicht den Anweisungssatz. Kein Norm-Artefakt (keine Hard Rule, kein Adaptions-Eintrag, keine ADR, kein Gate-Index) liegt in einem der zwei Diffs; [`AGENTS.md`](../../AGENTS.md) §3.8 hält. |
| **Der Plan-Berührte: sind die zwei Behebungen untereinander widerspruchsfrei?** | **geprüft, ohne Befund.** §1 zählt die Vor-Stand-Stellen (5, mit Ref), §2 prüft den Nach-Stand (EXIT 1, ohne Ref), §5 verweist auf §2 — drei Aussagen über dasselbe, keine zweite Fassung derselben Zahl; die Zählung der emittierten Ebene (§1) bleibt bei ihrem Gegenstand. |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 0 |
| LOW | 0 |
| INFO | 2 |

**Finding-Klassen dieses Laufs:** notations-sonde-ueberdeckt-eine-meta-notation ·
mess-stand-in-der-prosa-loest-nicht-auf

Beide sind **neu vergeben** und im Befund als solche gekennzeichnet; beide sind **INFO** und
tragen nicht blockierend. Die Klasse der Runde 1, die nicht behoben ist, geht unverändert in
denselben Zähler (`anweisungssatz-notation-ohne-dauerhaften-waechter`, F-5 — sie ist benannt und
wird nicht neu gemeldet). Die Zuordnung und das Anlegen der Belege sind Sache der Slice-Closure,
nicht dieses Reports.

## Verdikt

**Merge-blockierend: nein.** Die zwei MEDIUM der Runde 1 sind **behoben**, und keine der zwei
Behebungen hat einen neuen Mangel erzeugt — die zwei INFO dieses Laufs benennen Grenzen
(Prüfbereich der erweiterten Sonde, Auflösbarkeit einer Prosa-Bezeichnung), keinen Fehler am
Gelieferten und keinen an der Abnahme. **0 HIGH · 0 MEDIUM · 0 LOW · 2 INFO.**

**Was der Reviewer geprüft und was er nicht geprüft hat.** Gezogen: beide Sonden in beiden
Fassungen, an drei Ständen; der Ref und seine drei Kandidaten-Stände; die Zitation von
[`MR-058`](../../harness/conventions.md#mr-058--eine-messung-die-ihr-eigener-vorgang-bewegt-wird-nach-dem-vorgang-genommen)
gegen ihren Wortlaut und gegen den Bestand; der Regelwerks-Name und sein Stand gegen den
gepinnten Tag; der Commit-Zuschnitt der zwei Commits und die Gate-Config auf einen neuen
Wächter hin; `make gates` vollständig (EXIT 0). **Nicht gezogen:** die emittierte Vorlage in
ihrem eigenen Prüfbereich (`make full-smoke`), die zwei übrigen Wellen-Mitglieder, die
Wellen-Closure und die zwei Architect-Posten — sie sind nicht Gegenstand dieses Slice, und
**kein voller `make mutate`** (Post-integration-Stufe; ohne neuen Wächter ohne Objekt).

**Übergabe:** die zwei INFO gehen an den **Planner** (sie treffen den Plan, nicht den
Anweisungssatz: N-1 die Sonde in §1/§2, N-2 die Prosa des Anlass-Blocks) — und beide sind
**Entscheidungen**, keine Nacharbeit: ob die weite Sonde ihren Prüfbereich behält und ob die
Prosa-Bezeichnung stehen bleibt, entscheidet die Rolle, der der Plan gehört. Die Finding-Klassen
gehen zusätzlich in die Slice-Closure §7 und von dort in den Zähler. DoD-/Spec-Konformität prüft
der Verifier separat (Modul 11; anderes Prüf-Artefakt, anderer Eingabe-Kontext).
