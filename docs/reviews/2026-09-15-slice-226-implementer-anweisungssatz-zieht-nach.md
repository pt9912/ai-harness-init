# Review-Report: slice-226-implementer-anweisungssatz-zieht-nach — 2026-09-15

**Review-Art:** Code-Review gegen **Plan + ADRs + Hard Rules** (Modul 10 §Drei Review-Arten).
Gegenstand ist ein **Rollen-Anweisungssatz** — eine Markdown-Lauf-Instruktion, kein ausführbarer
Pfad. **Kein DoD-Review** — DoD-/Spec-Konformität prüft der Verifier (Modul 11, anderer
Eingabe-Kontext).

**Gegenstand:** Commit `bbd10ea2` (Rolle Implementer) — **eine** Datei, +26/−6:
`.claude/commands/implement-slice.md`. Der Commit ist die Spitze dieses Laufs
(`git log --oneline -1` → `bbd10ea2`); danach hat kein Commit die Datei berührt
(`git log --oneline bbd10ea2..HEAD -- .claude/commands/implement-slice.md` → leer),
`git status --porcelain` → leer.

**Kein Self-Review:** dieser Lauf hat an dem Gegenstand **nicht** geschrieben — weder am Commit noch
an der Datei. Kein Befund dieses Reports ist aus der Commit-Message oder aus einem
Implementer-Bericht übernommen; die als strittig gemeldeten Punkte (§5 dieses Reports) und die zwei
Rot-Belege (§2, §3) sind einzeln nachgefahren.

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

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde — ohne
diese Liste ist der Lauf nicht reproduzierbar):

- Slice-Plan `slice-226-implementer-anweisungssatz-zieht-nach` (§1 Ziel und Abgrenzung, §2 DoD,
  §3 Plan, §4 Trigger, §5 Closure-Trigger, §6 Risiken, §8)
- [`AGENTS.md`](../../AGENTS.md) §3 (Hard Rules; tragend hier §3.7, §3.10, §3.11) · §2
  (Source Precedence) · §6 (Minimal Agent Workflow)
- [`ADR-0028`](../../docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)
  (Festlegung 1 Eigentum, Festlegung 2 Grenze der Ableitung) ·
  [`ADR-0051`](../../docs/plan/adr/0051-anweisungssatz-eigentum-traegt-ueber-die-emissionsgrenze.md)
  (`Accepted`: das Eigentum trägt über die Emissionsgrenze, für die **Autorschaft**) ·
  [`ADR-0044`](../../docs/plan/adr/0044-ziel-fassung-regiert-den-sprung-v672.md) (die regierende
  Fassung des Sprungs)
- [`MR-057`](../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
  (Setzung 3: die Platzhalter-Notation lebender Regeln ist `<Kennung>`; der Bestand zieht nicht nach) ·
  [`MR-058`](../../harness/conventions.md#mr-058--eine-messung-die-ihr-eigener-vorgang-bewegt-wird-nach-dem-vorgang-genommen) ·
  [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) ·
  [`MR-033`](../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
- [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
  (kein Sensor behaupten, der nicht existiert) ·
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (Gegenstand ist der
  committet vendored Baum, netzlos)
- Baseline `v6.8.0` · `regelwerk/modul-09-implementierung.md` §Minimal Agent Workflow (8 Schritte)
  und §Rücksprungkanten-Regeln · `regelwerk/modul-10-review-harness.md` §Ziel-Form: Reviewer-Skill
- Vorherige Findings an den Schwester-Gegenständen dieser Sitzung, daraus die wiederkehrenden
  Klassen: `test-anker-aus-der-prosa-erfuellbar` (`slice-vorlauf-waechter-geht-ins-ziel`, Runden
  1–4) · `fremdes-rollen-artefakt-im-implementations-kontext` und
  `kommentar-im-konjunktiv-ueber-die-verworfene-alternative`
  (`slice-174-archivierung-emittieren`, `slice-mutations-fall-…`)

---

## Eigene Messungen

Jedes Kommando dieses Abschnitts ist in diesem Lauf gefahren. Wo eine Zahl steht, steht das
Kommando daneben, das sie liefert; **keine Erwartungswerte**
([`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2).

### 1. Der Delta-Nachweis — nachgefahren, er trägt

```sh
cd /Development/KI/ai-harness-course
git diff --shortstat v6.0.0..v6.7.2 -- lab/regelwerk/modul-09-implementierung.md
#  1 file changed, 35 insertions(+), 4 deletions(-)

for p in 'Die Tests-Zeile bindet' 'Betrifft dieselbe Ursache viele gleichrangige' \
         'Die Plan-Ausgabe in Schritt 4 nennt Out-of-Scope' 'Der Plan lebt in §3 des Slice-Plans'; do
  printf 'v6.0.0=%s v6.7.2=%s  %s\n' \
    "$(git show v6.0.0:lab/regelwerk/modul-09-implementierung.md | grep -cF "$p")" \
    "$(git show v6.7.2:lab/regelwerk/modul-09-implementierung.md | grep -cF "$p")" "$p"
done
#  v6.0.0=0 v6.7.2=1  (alle vier Block-Köpfe)
```

Genau die vier Blöcke, die §1 des Slice als Gegenstand benennt, stehen in `v6.0.0` **nicht** und in
`v6.7.2` **je einmal**. Die vier übrigen Hunks desselben Diffs sind zwei Tabellen-Trenner-Zeilen,
der Notation-Satz des Moduls selbst (`git show v6.0.0:…` auf `'(seit welle-<NN>)'` → **1**;
dieselbe Sonde gegen `v6.7.2` auf `'(seit welle-<Kennung>)'` → **1**) und ein Absatz der Ziel-Form
`AGENTS.md` — **keiner** davon ist ein Plan-vor-Code-Block; der Notation-Satz stützt §5 (b).

**Die Zahl „vier" trägt.** Der Delta-Nachweis des Senders (§9, Zeile
`lab/regelwerk/modul-09-implementierung.md` im Plan des Vorgänger-Slice) nennt drei Inhalts-Posten;
der Plan hat dagegen **selbst gemessen** und zwei weitere gefunden — der stärkere Beleg, und der
Gegenstand ist damit nach §1 nicht vermutet, sondern gemessen.

### 2. Der Notations-Rot-Beleg des Umsetzers (die DoD-2-Sonde)

```sh
git grep -cE 'slice-<NNN>|welle-<NN>' bbd10ea2^ -- .claude/commands/implement-slice.md
#  bbd10ea2^:.claude/commands/implement-slice.md:3          EXIT 0
git grep -cE 'slice-<NNN>|welle-<NN>' -- .claude/commands/implement-slice.md
#  (keine Ausgabe)                                          EXIT 1
```

**Der Beleg reproduziert.** Der rote Lauf vor dem Commit gab **eine** Datei-Zeile mit der Zahl `3`
aus (die Form, in der der Umsetzer „EXIT=0 mit 1 Treffer" berichtet hat), der grüne Lauf danach
nichts, EXIT 1 — die Bedingung der DoD-2 ist erfüllt.

**Der Rückstand vor dem Commit, in beiden Schreibweisen der alten Form:**

```sh
git grep -nE 'slice-<NNN>|welle-<NN>' bbd10ea2^ -- .claude/commands/implement-slice.md
#  133:  `· seit welle-<NN>`, wellenlos `· seit slice-<NNN>`
#  173:  **formgebunden**: `evidence/slice-<NNN>.md`
#  182:  `seit slice-<NNN>` statt `seit welle-<NN>`
git grep -nF 'SLICE=<slice-NNN>' bbd10ea2^ -- .claude/commands/implement-slice.md
#  zwei Stellen (Schritt 9, Schritt 24) — von der DoD-2-Sonde nicht getroffen
```

Der gelieferte Text trägt **keine** Restform — geprüft mit einer weiteren Sonde über **beide**
Schreibweisen und die geprüfte Datei (`grep -nE 'NNN|welle-<NN|<slice-|<welle-'
.claude/commands/implement-slice.md` → keine Ausgabe). **Die Zusage hält; die Sonde der DoD ist
nicht der Grund dafür** — das ist F-2.

### 3. Der zweite Rot-Beleg des Umsetzers (vier Block-Sonden) — im Ergebnis bestätigt, in der Reihe nicht reproduzierbar

Die berichtete Reihe `1/1/0/1 → 1/1/1/1` nennt ihren **Anker-Satz** nicht. Eigene Sonde über vier
block-eigene Wörter (`git show bbd10ea2^:…` gegen die Arbeitsfassung):
`Akzeptanzkriterien` 0/1 · `gleichrangig` 0/2 · `Out-of-Scope` 0/1 · `Chat-Verlauf` 0/1 — also
**0/0/0/0 → 1/2/1/1**. Das Ergebnis ist damit unabhängig bestätigt (alle vier Blöcke sind neu),
die berichtete Reihe selbst nicht. **Kein Finding:** der Reviewer erhält nach Modul 8
(Implementer→Reviewer: *Diff + Plan-Verweis*) keinen Implementer-Bericht, in dem der Anker-Satz
stehen könnte; die Zahl ist hier als **Frage** geführt und nicht als Mangel.

### 4. Wörtlichkeit der vier Blöcke gegen das Modul

Verglichen ist `v6.8.0` · `regelwerk/modul-09-implementierung.md` §Minimal Agent Workflow und
§Rücksprungkanten-Regeln gegen `.claude/commands/implement-slice.md` Zeilen 82–96 und 109–111.
Kein Block ist ein Zitat; alle vier sind sinntreue Übertragungen — die Frage je Block ist, ob eine
Weglassung die Aussage kippt:

| Block | Modul-Aussage | Übertragung im Anweisungssatz | Verdikt |
|---|---|---|---|
| Tests-Zeile bindet an die Akzeptanzkriterien-ID | *„Die Tests-Zeile bindet … Die Plan-Ausgabe zitiert die ID, nicht den Text"* | *„Die Testdatei-Zeile der Plan-Ausgabe bindet … Die Zeile zitiert die ID, nicht ihren Text"* | **trägt** — Umbenennung nach F-4, kein Bedeutungswechsel |
| Eine Ursache über viele gleichrangige Dateien | *„über zwölf Implementierer … zwölf wortgleiche … tragen dieselbe Wiederholungs-Last wie eine ausgeschriebene Kennung statt eines Verweises"* | *„über viele gleichrangige Aufrufer … ebenso viele wortgleiche … driften beim nächsten Refactor gegeneinander"* | **trägt** — die Zwölf-Zahl ist im Modul Beispiel, der Satz dahinter ist übernommen |
| Out-of-Scope in Schritt 4 | *„Das ist keine Zutat, sondern die Schritt-Hälfte einer Regel … darf sie nicht stillschweigend weiten: … eine Plan-Änderung und gehört vor den Code"* | *„Das ist die Schritt-Hälfte einer Regel … weitet sie nicht stillschweigend. … eine Plan-Änderung vor dem Code, keine Zeile im Bericht danach"* | **Bedeutung trägt, Zuordnung kollidiert** — F-1 |
| Der Plan lebt in §3 | *„erweitert die Datei-Tabelle aus §3 derselben Datei, in der Planner zuvor §1/§2 geschrieben hat (`slice.template.md`)"* | *„erweitert die Datei-Tabelle aus §3 derselben Datei"* | **trägt** — der Template-Zeiger entfällt, die Aussage bleibt |

Die Adressen, die die vier Blöcke nennen, lösen **im Anweisungssatz** auf: *Schritt 3* und *Schritt
4* sind die Modul-9-Schritte, mit denen die Abschnitts-Überschriften der Datei ihre Abschnitte
selbst beschriften (`## Kontext lesen (Modul 9, Schritte 1–3)`,
`## Plan vor Code (Modul 9, Schritt 4 — nicht optional)`), *§1* und *§3* sind die des Slice-Plans,
*5→4* und *6→4* die Kanten desselben Abschnitts. Zeilenverweise führt **keiner** der Blöcke.

### 5. Verortung der vier Blöcke — die zwei Setzungen des Umsetzers

**(a) Punkt 13 gegen Punkt 15 — der Zug hält.** Der Block „Tests-Zeile" steht bei Punkt 13
(Zeile 82); der Umsetzer hat Punkt 15 erwogen und verworfen. Das Modul bindet den Block an
**Schritt 4** (*„Kleinste sinnvolle Änderung planen"*) — im Anweisungssatz die Nummer **13** unter
der Überschrift `## Plan vor Code (Modul 9, Schritt 4)`. Punkt 15 ist **Modul-9-Schritt 5**, an dem
ein Sensor *läuft*; die Zeile gehört in den **Plan**, nicht in seinen Vollzug. Gegenprobe: das
Modul selbst begründet die Zeile mit *„Die **Plan-Ausgabe** zitiert die ID"* — sie ist Eigenschaft
der Ausgabe, nicht des Laufs.

**(b) `SLICE=<slice-NNN>` (Zeilen 58/179) — der Zug hält, dreifach gedeckt.** Diese zwei Stellen
liegen außerhalb der DoD-2-Sonde (§2: sie sieht die Klammer-Form nicht). Die Erweiterung ist gedeckt
durch den **Vertrag** in `harness/sensors/slice-mv.md` (*„`make slice-mv SLICE=slice-<Kennung>
TO=<open|next|in-progress|done>`"*), durch
[`MR-057`](../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
Setzung 3 (*„Wo eine **lebende** Regel die Form **vorschreibt**, steht ab hier `<Kennung>` statt
`<NNN>`/`<NN>`"* — ein Anweisungssatz schreibt vor) und durch den Delta-Nachweis selbst, der die
Notation des Moduls mitgezogen hat (§1). **Keine Zusage ohne Deckung.**

**(c) Drei Linien in der Sonde, fünf geänderte Stellen.** Der Zähl-Unterschied ist kein
Widerspruch des Umsetzers, sondern der Prüfumfang seiner Sonde: drei Stellen in der von ihr
gesehenen Schreibweise, zwei in der Klammer-Form (unter (b) begründet) — F-2.

### 6. Kein neuer Wächter — die Sonde lebt nur im Bericht

```sh
grep -rn 'slice-<NNN>\|welle-<NN>' --include='*.sh' --include='*.yml' --include='Makefile' \
        --include='*.bats' --include='*.go' . | grep -v '^./.harness/baseline/'
#  test/mutations/215-welle-results-als-singleton.sh:8   (Kommentar, anderer Gegenstand)
#  internal/emit/templates.go:30                          (Doc-Kommentar, anderer Gegenstand)
grep -n '^modules:' .d-check.yml
#  modules: [links, anchors, ids, matrix, codepaths, spans, planning, targets]  — kein Modul liest einen Anweisungssatz
```

Kein `make`-Ziel, kein bats-/Go-Test, kein Mutations-Fall führt die Notations-Suche. **Die Aussage
des Umsetzers stimmt** — und ist mehr als wahr: §1 schließt den Bau eines Sensors ausdrücklich aus
(*„Es wäre ein anderer Vorgang"*), §6 führt die Lücke als Risiko mit dem Ausgang *offen bis zur
Closure*. Die Lücke steht damit **benannt**, nicht verschwiegen — F-5.

### 7. `make gates`

```text
$ make gates
span-check: Traeger vorhanden, span-emit hat einen Span geschrieben, Ablageort git-ignoriert
EXIT=0
```

**EXIT 0** auf dem geprüften Stand (Arbeitsbaum leer, `bbd10ea2` = Spitze) und **EXIT 0** erneut
nach dem Commit dieser Report-Datei — der zweite Lauf deckt sie mit ab. Die entscheidende Zeile ist
der Schluss-Sensor `span-check`, der die Kette abschließt; `docs-check` ist in der Kette mitgelaufen,
und die berührte Datei liegt in seinem Scan-Bereich (`scan.roots: ["."]`, nicht in `scan.ignore`) —
sie trägt keine bloße Kennung: die neuen Zeilen führen `LH-*`/`ADR-*` nur als Wildcard-Formen, und
die zwei `make`-Zeilen nennen Targets.

---

## Findings

Jedes Finding folgt dem **§Output-Schema des Reviewer-Skills**. Die Spalten sind gespiegelt, nicht
neu definiert; bei Abweichung gilt der Skill.

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | MEDIUM | Der übertragene Out-of-Scope-Block nennt eine Scope-Ausweitung eine *„**Plan-Änderung** vor dem Code"* und **nennt die Rolle nicht**, während [`AGENTS.md`](../../AGENTS.md) §3.10 genau diesen Gegenstand einer anderen Rolle zuweist: *„Fällt im ausführenden Lauf eine Änderung an, die die Abnahme selbst verschiebt (ein DoD-Punkt, ein Closure-Trigger, eine **Out-of-Scope-Grenze**), ist sie kein Closure-Schritt, sondern ein **Übergabe-Artefakt** an den Planner: die ausführende Rolle schreibt ihr eigenes Abnahmekriterium nicht um."* Der Satz steht in der Lese-Anweisung genau dieser Rolle, und sein Umfeld stützt die Gegenlesart (*„führt zurück zum **Plan** (13) — den Plan verfeinern"*, Zeile 104–107): ein Lauf kann daraus ableiten, er dürfe §1 selbst weiten. Das Regelwerk kennt keine Rollen — die Kollision entsteht erst beim Übertragen in ein Repo, das eine Hard Rule dazu führt (gemessen: `Out-of-Scope-Grenze` kommt repo-weit **nur** in §3.10 vor). Der Reviewer entscheidet die Rollen-Frage **nicht**; er hält fest, dass der Text sie offenlässt. | [`AGENTS.md`](../../AGENTS.md) §3.10 (Zeile 419) · `v6.8.0` · `regelwerk/modul-09-implementierung.md` §Minimal Agent Workflow | `.claude/commands/implement-slice.md:92-96` | nein — kein Modul liest Rollen, Prosa oder Commit-Zuschnitt ([`AGENTS.md`](../../AGENTS.md) §3.8 und §3.10, *Ein Wächter existiert nicht*) | uebernommener-regelwerk-satz-kollidiert-mit-eigener-hard-rule *(**neu** — kein Register-Slug trifft die Klasse: die vorhandenen `out-of-scope-und-doku-dod-widersprechen-sich` und `schwellen-uebertritt-ohne-zustaendige-rolle` sprechen über Welle-vs-DoD bzw. über Trigger, nicht über die Rolle der verschobenen Abnahme-Grenze)* |
| F-2 | MEDIUM | Die Notations-Sonde der DoD-2 **sieht eine der zwei Schreibweisen der alten Form nicht**: `slice-<NNN>` trifft `SLICE=<slice-NNN>` nicht, weil dort die spitzen Klammern das ganze Token umschließen (zwei Stellen vor dem Commit, §2). Dieselbe Sonde ist das Beleg-Kommando des Closure-Triggers (§5 Punkt 1), und die Zählung daneben (§1: *„an **3** Stellen"*) trägt denselben Prüfumfang — real waren es **fünf**. Der **gelieferte** Text hält die Zusage (§2, breitere eigene Kontrolle); der Befund gilt der **Messmethode**, die eine Wiederkehr an genau den zwei Stellen grün durchließe. Das ist die Form *Spec-Treue-Lücke einer Messmethode* der MEDIUM-Liste des Skills. | `slice-226-implementer-anweisungssatz-zieht-nach` §1 · §2 Liefer-Punkt 2 · §5 Punkt 1 · [`MR-057`](../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer) Setzung 1 | `docs/plan/planning/in-progress/` (Slice-Plan, §1/§2/§5) | ja — die Sonde selbst: EXIT 0 vor dem Rückstand, EXIT 1 danach. Was sie **nicht** kann, zeigt die Sondierung gegen die Klammer-Form (`git grep -nF 'SLICE=<slice-NNN>'` bleibt auf beiden Ständen leer) | zusage-nennt-sensor-der-form-nicht-sieht *(zitiert; Nähe und Abweichung im Verdikt benannt)* |
| F-3 | INFO | Die Schreibweise, die dieser Commit in **zwei** Zeilen des Anweisungssatzes auf die Ziel-Form zieht, steht an zwei **weiteren** Trägern unverändert: `Makefile:340` (Hilfetext des Ziels) und `harness/tools/slice-mv.sh:170`, während `harness/sensors/slice-mv.md` §Vertrag die Ziel-Form führt — dieselbe Invokation ist damit nach diesem Commit in **zwei** Schreibweisen im Baum. Beide Stellen sind **registriert**: die Beobachtung `uebergabe-an-andere-rolle-ohne-traeger-artefakt` führt sie in ihrer jüngsten Evidence als ausgesprochene Übergabe an die Eigentümer zweier Träger **ohne Träger-Artefakt**. Kein Befund gegen diesen Diff (beide liegen außerhalb seiner §3-Tabelle und außerhalb der §1-Ausschlüsse); der Report nennt sie, weil sie dieselbe Fundmenge sind — der Befund nennt den Fundort, die Fundmenge hält der Vorgang. | [`MR-057`](../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer) Setzung 3 · `BEO-ALL/uebergabe-an-andere-rolle-ohne-traeger-artefakt` | `Makefile:340` · `harness/tools/slice-mv.sh:170` | nein — kein Modul liest die Form einer `make`-Invokation | uebergabe-an-andere-rolle-ohne-traeger-artefakt *(zitiert; die Klasse trägt den Fund bereits)* |
| F-4 | INFO | Der Block nennt *„Die **Testdatei-Zeile der Plan-Ausgabe**"* (Zeile 82) — einen Namen aus §2 der DoD, den weder das Modul (*„Tests-Zeile"*) noch die Datei an dieser Stelle führt; ihr Gegenstand wird erst später greifbar (*„die Datei-Tabelle aus §3"*, Zeile 109–110). Der Umsetzer hat die **Stelle** richtig gewählt (§5 (a)); offen ist allein, ob der DoD-Name oder der Modul-Name trägt. Diese Auflösung ist nicht die des Reviewers; sie berührt die Form-Vergleichs-Zusage des Liefer-Punkts 1. | `slice-226-implementer-anweisungssatz-zieht-nach` §2 Liefer-Punkt 1 · `v6.8.0` · `regelwerk/modul-09-implementierung.md` §Minimal Agent Workflow | `.claude/commands/implement-slice.md:82` · `:109-110` | nein — kein Gate liest Prosa | anweisungssatz-fuehrt-einen-namen-ohne-quelle *(**neu***) |
| F-5 | INFO | Die Notations-Zusage hat **keinen dauerhaften Wächter**: die Suche lebt in §1/§2/§5 des Slice-Plans und in diesem Report, kein Target, kein Test, kein Mutations-Fall führt sie (§6). Der Umsetzer **behauptet keine** Deckung ([`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)), §1 schließt den Sensor-Bau ausdrücklich aus, §6 führt die Lücke als Risiko mit Ausgang *offen bis zur Closure*. Benannt, nicht geschlossen — keine Harness-Lüge, aber die Lücke überlebt diesen Slice. | [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) · `slice-226-implementer-anweisungssatz-zieht-nach` §1 · §6 Risiko 1 | `.claude/commands/implement-slice.md` (Gegenstand) · `.d-check.yml` (`modules:`) | nein — der Wächter existiert gerade nicht; herstellbar als Modul-Erweiterung oder Test, beides außerhalb dieses Slice | anweisungssatz-notation-ohne-dauerhaften-waechter *(**neu**)* |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| **Die zwei Rot-Belege des Umsetzers** | **einer reproduziert, einer im Ergebnis bestätigt.** Die Notation stimmt exakt (§2). Die vier Block-Sonden stimmen im **Ergebnis** (alle vier Blöcke sind neu, §3), nicht in der berichteten Reihe; ihr Anker-Satz ist nicht benannt. Kein Finding — der Reviewer-Kontext führt nach Modul 8 nur *Diff + Plan-Verweis*. |
| **[`ADR-0028`](../../docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) / [`ADR-0051`](../../docs/plan/adr/0051-anweisungssatz-eigentum-traegt-ueber-die-emissionsgrenze.md) — hält der Zug die Rollen-Grenze?** | **geprüft, ohne Befund.** Die Datei ist der Anweisungssatz der **Implementer**-Rolle (Eröffnungssatz: *„Dieser Command führt die **Implementation**-Rolle (Modul 9)"*), das Eigentum liegt nach ADR-0028 Festlegung 1 bei ihr, und die Commit-Message nennt sie. Die Erweiterung stützt sich ausschließlich auf Material **mit Original** — drei Blöcke aus `modul-09-implementierung.md`, der vierte ebenso, die Notation aus [`MR-057`](../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer) Setzung 3 und `harness/sensors/slice-mv.md`; **keine** Aussage ohne Quelle ist geschrieben, Festlegung 2 wird nicht berührt. Kein Norm-Artefakt (keine Hard Rule, kein Adaptions-Eintrag, keine ADR, kein Gate-Index) liegt im Diff — §3.8 hält. |
| **[`AGENTS.md`](../../AGENTS.md) §3.7 (Kommentar-Regel) über den hinzugefügten Zeilen** | **geprüft, mit F-1 als einziger Berührung, sonst ohne Befund.** Keine Befund-Kennung, keine Slice-Nummer als Erzählung, kein *„früher stand"*, kein Lauf-Protokoll, **kein Zeilenverweis** (§4 letzter Absatz). Der einzige Konjunktiv-Verdachtsfall — *„Ohne diese Zeile sagt der Plan nur, *was* sich ändert"* — steht im **Indikativ** über eine Konfiguration, nicht im Irrealis über eine verworfene Alternative, und ist **wortgleich aus dem Modul** übernommen; §3.7 bindet Kommentare in Code/Config/Skript, diese Datei ist Lauf-Instruktion. Kein Finding. |
| **`mess-zusage-trifft-das-eigene-zitat` (Register, 5×, verkörpert) — tritt die Klasse hier auf?** | **geprüft, ohne Befund — REFUTED, und der Grund ist eine Setzung des Plans.** Die Klasse verlangt, dass die Bezugsmenge einer DoD-Zusage den Plan **selbst** enthält, der das Muster zitiert. §2 der DoD-2 schneidet das ausdrücklich aus: *„Die Zusage gilt dem **Prüfbereich einer Datei** und nicht dem Repo"* — die Menge ist eine Datei, der Plan liegt nicht darin, der Zielwert ist im Moment des Abhakens erreichbar. Ein zweites Auftreten entsteht hier nicht. |
| **Die Verkörperung der Notations-Form ([`MR-057`](../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)) — greift sie an allen fünf geänderten Stellen?** | **geprüft, ohne Befund.** Die zwei `make slice-mv`-Zeilen decken sich wörtlich mit dem Vertrag in `harness/sensors/slice-mv.md` (nur `TO` als Teilmenge — für den jeweiligen Schritt richtig); die Belegform `evidence/slice-<Kennung>.md` deckt sich mit dem Bestand (`ls docs/plan/planning/observations/BEO-ALL/fremdes-rollen-artefakt-im-implementations-kontext/evidence/` → `slice-129.md` … neben `slice-werkzeug-erkennt-die-benannte-kennung.md`, also Kennung = Nummer **oder** Name); die vier Herkunfts-Anker-Formen der Zeile 152 decken sich **zeichengleich** mit der Aufzählung in [`AGENTS.md`](../../AGENTS.md) §3.7. |
| **[`MR-028`](../../harness/conventions.md#mr-028--der-wirksamkeits-anlass-steht-im-eintrag-blank-statt-verlinkt) und [`MR-031`](../../harness/conventions.md#mr-031--die-kommentar-regel-steht-in-der-adoptierten-baseline) führen die alte Form — Rückstand derselben Klasse?** | **geprüft, ohne Befund — REFUTED.** [`MR-057`](../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer) Setzung 3 nimmt *„die angenommenen Einträge dieses Blocks"* ausdrücklich vom Nachzug aus. Ein Befund wäre hier ein zweiter Maßstab. |
| **Die emittierte Ebene (`internal/emit/templates/commands/`, 6 Vorkommen, kein Nachzug)** | **geprüft, ohne Befund — der Ausschluss trägt.** Nachgemessen: die zwei Fassungen sind **keine** Kopien voneinander (171 zu 204 Zeilen, `ANPASSEN`-Marker nur in der Vorlage), und [`MR-057`](../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer) nimmt die emittierte Ebene in seinem Geltungsbereich ausdrücklich aus (*„Was ein Zielrepo an Kennungs-Form bekommt, entscheidet der Slice, der die Tool-Ebene entscheidet"*). [`ADR-0051`](../../docs/plan/adr/0051-anweisungssatz-eigentum-traegt-ueber-die-emissionsgrenze.md) bewegt allein die **Autorschaft** über die Grenze, nicht den Lieferumfang dieses Slice; §1 erklärt die Grenze selbst und nennt den fehlenden Folge-Träger, statt sie als Adresse zu öffnen. Ein Finding wäre hier eine Forderung ohne Quelle. |
| **[`AGENTS.md`](../../AGENTS.md) §3.11 (Adresse im einfrierenden Artefakt)** | **geprüft, ohne Befund.** Der Diff führt keine Pfad-Adresse auf ein bewegtes Artefakt ein; die neuen Adressen sind Struktur-Adressen innerhalb derselben Datei, die zwei `make`-Zeilen nennen ein Target. |
| **Halluziniertes Gate ([`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6))** | **geprüft, ohne Befund.** Der Diff nennt kein `make`-Ziel neu; die zwei genannten existieren (`grep -nE '^(slice-mv\|gates):' Makefile` → `Makefile:340`, `Makefile:427`), und `harness/README.md` §Sensors ist unberührt. |
| **Ein neuer Wächter ([`AGENTS.md`](../../AGENTS.md) §3.6)** | **geprüft, ohne Befund — es ist keiner entstanden**, und die Aussage des Umsetzers stimmt (§6). Damit entfällt die Pflicht eines rot gesehenen Gegenbeispiels für einen **neuen** Wächter; die Zusage des Nachzugs trägt ihr Gegenbeispiel in §2 und ist dort rot gesehen worden. **Kein voller `make mutate`** — er gehört auf die Post-Integration-Stufe (`v6.8.0` · `regelwerk/grundlagen-klassifikation.md` §Klassifikation und Steering Loop › Lifecycle-Verteilung). |
| **Ein fremder Verweis / eine fremde Kennung** | **geprüft, ohne Befund.** Der Diff führt keine Kennung eines anderen Repos oder Slice ein; `BEO-ALL/verweise-brechen-beim-ortswechsel` (Zeile 182) ist die etablierte Register-Adresse und stand vor dem Commit bereits dort. |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 2 |
| LOW | 0 |
| INFO | 3 |

**Finding-Klassen dieses Laufs:** uebernommener-regelwerk-satz-kollidiert-mit-eigener-hard-rule ·
zusage-nennt-sensor-der-form-nicht-sieht · uebergabe-an-andere-rolle-ohne-traeger-artefakt ·
anweisungssatz-fuehrt-einen-namen-ohne-quelle ·
anweisungssatz-notation-ohne-dauerhaften-waechter

Drei davon sind **neu vergeben** (F-1, F-4, F-5) und im Befund als solche gekennzeichnet;
`zusage-nennt-sensor-der-form-nicht-sieht` und `uebergabe-an-andere-rolle-ohne-traeger-artefakt`
zitieren bestehende Register-Einträge, statt sie neu zu benennen. Die Zuordnung und das Anlegen der
Belege sind Sache der Slice-Closure, nicht dieses Reports — ebenso die Entscheidung, ob F-3 ein
**neues Auftreten** derselben Beobachtung ist oder der bereits registrierte Fund.

## Verdikt

**Merge-blockierend: nein — mit zwei MEDIUM, die vor dem Merge zu klären sind.**

F-1 ist der schwerere der beiden und **nicht** herabgestuft. Er trifft keinen Übertragungsfehler
(die vier Blöcke sind sinntreu, §4), sondern die **Kollision**, die die Übertragung erzeugt: Der
Satz des Regelwerks kennt keine Rollen, [`AGENTS.md`](../../AGENTS.md) §3.10 kennt sie und weist die
verschobene Out-of-Scope-Grenze dem Planner zu. Beides steht jetzt im Kontext desselben Laufs, und
die Datei, in der die eine Fassung steht, ist die Lese-Anweisung der Rolle, über die die andere
spricht. Wer auflöst, ist **nicht** der Reviewer: die Fassung des Anweisungssatzes gehört nach
[`ADR-0028`](../../docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)
Festlegung 1 der ausführenden Rolle, die Hard Rule nach §3.8 dem Architect. Fällt die Auflösung
zwischen zwei Rollen streitig aus, ist das der Konflikt-Pfad (`v6.8.0` ·
`regelwerk/modul-08-agentenrollen.md` §Konflikt-Pfad als Rollen-Sequenz) und nicht eine
Herabstufung.

F-2 betrifft nicht das Gelieferte, sondern den **Beleg**, auf den die Closure sich stützt: die
Notations-Sonde der DoD-2 kann eine der beiden Schreibweisen der alten Form nicht sehen, und §5 des
Slice hängt den Closure-Trigger an genau diese Sonde. Der gelieferte Text hält die Zusage — das ist
in §2 unabhängig gemessen und nicht aus der Sonde gefolgert. Wer den Maßstab ändert, ist die
Planung.

**F-2 zitiert `zusage-nennt-sensor-der-form-nicht-sieht` und weicht von dessen Raster ab:** jener
Eintrag spricht von einem *Skript- oder Funktionskopf*, hier steht das Beleg-Kommando einer DoD.
Die Nähe ist die Fehlerrichtung — *ein Träger, der einen Rest auffangen soll und genau diese Form
nicht sieht* —, die Nachbarklasse `zitat-grep-uebersieht-zeilenumbruch-und-markup` trifft den
Mechanismus, läuft aber in die **Gegenrichtung** (*„der Satz ist fort" statt „der Satz steht"*).
Ob zitiert oder getrennt geführt, entscheidet die Closure; der Report gibt ihr beide Seiten.

Die drei INFO tragen nicht blockierend: F-3 nennt die zwei weiteren Träger derselben Schreibweise,
deren Fund bereits registriert ist; F-4 ist eine Namens-Frage an der Form-Vergleichs-Zusage (der
Umsetzer hat die **Stelle** richtig gewählt); F-5 ist eine ausdrücklich benannte, nicht als Deckung
behauptete Lücke.

**Die zwei Setzungen des Umsetzers — beide halten.** Punkt 13 ist die richtige Stelle für die
Akzeptanzkriterien-Bindung (Punkt 15 ist Modul-9-Schritt 5 und damit der Vollzug, nicht der Plan);
die Erweiterung auf `SLICE=<slice-NNN>` an den Zeilen 58/179 ist keine Zusage ohne Deckung, sondern
dreifach gedeckt (§5 (b)).

**Was dieser Report nicht entscheidet:** die Rollen-Frage aus F-1, die Wahl zwischen DoD-Name und
Modul-Name aus F-4, ob der Sensor aus F-5 gebaut wird und wie F-3s Klasse zu führen ist. **Was er
nicht geprüft hat:** die emittierte Ebene in ihrem eigenen Prüfbereich (`make full-smoke`) und die
DoD-Konformität als solche (Modul 11, anderer Kontext).
