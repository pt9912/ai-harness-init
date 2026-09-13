# Review-Report: slice-migration-hat-ein-instanz-register, Runde 3 — 2026-09-13

**Review-Art:** Code-Review — der Nacharbeits-Commit gegen die sechs Befunde der Runde 2, gegen
den Slice-Plan und gegen die dort benannten Quellen. Kein Plan-Review, keine Verifikation
(DoD-Abhakung ist Verifier-Arbeit, Modul 11).

**Gegenstand:** `f2196cf8` (+56/−36, `harness/migration.md`). Arbeitsbaum leer; `f2196cf8` ist
`HEAD` und liegt **einen Commit vor** `origin/main` (`origin/main` == `8647edd3`, der
Runde-2-Report).

**Skill:** `.harness/skills/reviewer.md` @ Version 2.0.0 (Accepted) · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-5 · **Datum:** 2026-09-13

> **Zitier-Form** *(dieser Block bleibt stehen — er ist Norm, kein Ausfüll-Hinweis; die
> `<Platzhalter>` darin sind Formbeispiele)*. Dieser Report friert ein; was er zitiert, bewegt
> sich weiter. Deshalb: **Kennung, nicht Adresse** — `slice-<Kennung>` statt seines
> Lifecycle-Pfads, `make <target>` statt eines Links auf die Sensor-Datei, eine Baseline-Stelle
> als **Tag + Pfad in Inline-Code** statt als Link (`v<X.Y.Z>` · `regelwerk/<datei>.md`
> §<Abschnitt>). Der vendored Baum trägt genau einen Tag; der Sprung löscht den alten, und ein
> Link darauf färbt beim nächsten Bump ein Artefakt rot, das niemand mehr anfassen darf. Ein
> `pfad`-Feld auf den **geprüften Gegenstand** ist davon nicht betroffen — es zitiert den Stand
> des Laufs und darf ihn festhalten (`v6.7.2` · `regelwerk/modul-06-roadmap.md`
> §Wellen-Closure-Prozedur — diese Zeile ist selbst ein Beispiel der Form).

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde — ohne diese Liste ist der Lauf nicht
reproduzierbar):

- Slice-Plan `slice-migration-hat-ein-instanz-register`, gelesen an seinem Lifecycle-Stand
  `in-progress/` — §1 *Ziel und Abgrenzung* samt der **Auflage des Auftraggebers** und den sechs
  Out-of-Scope-Punkten
- [ADR-0018](../plan/adr/0018-ziel-fassung-regiert-die-migration.md) (`Accepted`) §Entscheidung
  Festlegung 4 im Volltext — beide tragenden Punkte: *„Sie wählt die Quelle, sie liest sie nicht
  vor"* und das wörtliche Zitat der Fünf-Klassen-Klausel;
  [ADR-0043](../plan/adr/0043-ziel-fassung-regiert-den-sprung-v671.md) (`Accepted`) §Was
  Festlegung 2 nicht tut, zeichenweise gegen das Zitat in §3 gehalten;
  [ADR-0031](../plan/adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) (**`Proposed`**),
  [ADR-0036](../plan/adr/0036-ziel-fassung-regiert-den-sprung-v600.md),
  [ADR-0038](../plan/adr/0038-ziel-fassung-regiert-den-sprung-v650.md),
  [ADR-0044](../plan/adr/0044-ziel-fassung-regiert-den-sprung-v672.md)
- [`MR-039`](../../harness/conventions.md#mr-039--ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines)
  und [`MR-058`](../../harness/conventions.md#mr-058--eine-messung-die-ihr-eigener-vorgang-bewegt-wird-nach-dem-vorgang-genommen)
  im **Volltext ihrer Datei**, nicht über die Index-Zeile — samt Kopf-Marke, Geltungsbereich und
  Auflösungs-Trigger; dazu
  [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2 und [`harness/conventions.md`](../../harness/conventions.md) §Adaptions-Block
- `v6.7.2` · `regelwerk/modul-06-roadmap.md` §Wellen-Closure-Prozedur, Schritt 4 — selbst gelesen,
  nicht über die Wiedergabe im Prüfgegenstand; dazu `v6.7.2` ·
  `regelwerk/modul-02-harness-bootstrap.md` §Freshness-Audit der vendored Baseline (Schritt 2),
  Eigenschaft *Der Review vergleicht auch die Form*
- [`AGENTS.md`](../../AGENTS.md) §3 (Hard Rules), namentlich §3.4, §3.6, §3.7, §3.8, §3.9, §3.10
- vorherige Findings am gleichen Gegenstand: die Reports der **Runde 1** (`93c54d1b`) und der
  **Runde 2** (`8647edd3`) sowie der Verifikations-Report (`fe401bc7`) — alle drei als
  **Kontext**, keine ihrer Einschätzungen übernommen; jeder Fund unten ist gegen seine Quelle neu
  gemessen

**Rollen-Grenze:** Dieser Lauf ändert am Gegenstand nichts. Alle Sonden sind lesend; kein
Gate-Lauf, keine Docker-Stufe ([`AGENTS.md`](../../AGENTS.md) §3.9 — `make gates`, `make mutate`
und alle Docker-Ziele fährt der Auftraggeber).

---

## Findings

Jedes Finding folgt dem **§Output-Schema des Reviewer-Skills** — der verbindlichen Single Source
of Truth. Die Spalten unten sind nur **gespiegelt**, nicht neu definiert; bei Abweichung gilt der
Skill bzw. dessen Quelle `v6.7.2` · `regelwerk/modul-10-review-harness.md`
§Ziel-Form: Reviewer-Skill.

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| N-9 | **MEDIUM** | Die neue Begründung, warum die zwei Archiv-Stub-Zeilen Buchstabe a verlassen, lautet *„Die vier Ausgänge aus Buchstabe a setzen eine bestehende Instanz voraus"* — der vierte Ausgang derselben Datei lautet *„**keine Instanz** \| die Vorlage hat in diesem Repo keine Instanz (§4) \| Begründung"*. Die Aussage wird von der Tabelle widerlegt, auf die sie sich bezieht; dasselbe gilt für die zweite Hälfte der Buchstabe-b-Begründung (*„passen nicht auf eine wachsende Menge von Alt-Instanzen"*), die für zwei Zeilen mit **null** Instanzen keinen Gegenstand hat. | [`AGENTS.md`](../../AGENTS.md) §3.6 · Slice-Plan §1 (*„Dieses Dokument leitet ab"*) | `harness/migration.md:169-172` (Begründung), `:207` (der widerlegende Ausgang), `:221-223` (zweite Hälfte) | **nein** — kein Modul der [`.d-check.yml`](../../.d-check.yml) hält einen Prosa-Satz gegen eine Tabelle derselben Datei | Begründung einer Mengen-Zuordnung von der eigenen Tabelle widerlegt |
| N-10 | **MEDIUM** | Für **denselben** Zeitpunkt geben Tabellenzeile und Ableitungs-Absatz zwei Antworten: Die Zeile sagt *„**sobald** die erste Archivierung eine Instanz erzeugt, gilt für sie §5 Buchstabe b"*, der Absatz sagt, Buchstabe b gelte **jetzt schon**, *„obwohl §4 sie oben (noch) als keine Instanz führt"*. Ein Report, der heute geschrieben wird, bekommt aus der Zeile *keine Instanz* (Buchstabe a) und aus dem Absatz *append-only* (Buchstabe b). | Slice-Plan §2 Liefer-Punkt (2) (*„genau einer von vier Ausgängen … eine geschlossene Menge, kein Freitext"*) · [`AGENTS.md`](../../AGENTS.md) §3.6 | `harness/migration.md:111-112` (die zwei Zeilen), `:169-172` (der Absatz) | **nein** — kein Sensor hält zwei Stellen derselben Datei gegeneinander | Zwei Antworten derselben Datei für denselben Zeitpunkt |
| N-11 | **MEDIUM** | Die MR-Zeile wird als *„**nicht** offen"* geschlossen und ganz unter Buchstabe a gebucht, obwohl [`MR-039`](../../harness/conventions.md#mr-039--ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines) seinen Geltungsbereich ausdrücklich konditioniert — *„die **Form** eines Eintrags dieses Blocks, **wenn** ein adoptierter Baseline-Stand ein neues Pflichtfeld einführt. **Nicht** der Inhalt eines akzeptierten Rumpfs"* — und die Ausgangsfrage die **ganze** geänderte Template-Form betraf; die Baseline nennt an derselben Stelle *„neue **Pflicht**-Felder **und umbenannte Sektionen**"* als zwei Auslöser, von denen `MR-039` nur den ersten beantwortet. Dazu teilt sich die Zeile: nach Setzung 2 bekommen 4 der 59 Instanzen das Feld nicht, während Buchstabe a genau **einen** Ausgang je Vorlage verlangt. | [`MR-039`](../../harness/conventions.md#mr-039--ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines) §Geltungsbereich, Setzung 1 und 2 · `v6.7.2` · `regelwerk/modul-02-harness-bootstrap.md` §Freshness-Audit der vendored Baseline (Schritt 2) | `harness/migration.md:181-187` (Schließung), `:198` (ein Ausgang je Vorlage) | **nein** — kein Sensor hält eine Zuordnung gegen den Geltungsbereich des `MR`, auf den sie sich beruft | Norm-Beleg trägt einen Teilfall, die Zuordnung schließt den ganzen Fall |
| N-12 | **LOW** | Das Ausdehnungs-Kriterium ist formuliert als *„alle Vorlagen, die dasselbe Artefakt über seinen Lebenszyklus annimmt"*; die Aufnahme von `welle-results.template.md` wird im selben Satz mit einer **anderen** Eigenschaft begründet (*„beide entstehen während der laufenden Welle"*). Nach `v6.7.2` · `regelwerk/modul-06-roadmap.md` §Wellen-Closure-Prozedur Schritt 4 *„bleibt die Ergebnisnotiz vollständig und flach"*, während Slice-Datei und Welle-Plan zum Stub werden — sie ist damit keine Form, die der Welle-Plan annimmt. Wer das geschriebene Kriterium auf eine künftige Vorlage anwendet, kommt auf sieben statt auf acht. | `v6.7.2` · `regelwerk/modul-06-roadmap.md` §Wellen-Closure-Prozedur, Schritt 4 · Maintainability | `harness/migration.md:147-159` | **nein** | Formuliertes Kriterium und angewandte Eigenschaft fallen auseinander |
| N-13 | **INFO** | Die Review-Report-Zeile trägt neben der Eigenschaft den Zeitanker *„am Stand dieses Commits **380**"*. *„Dieses Commits"* löst nicht auf: Am schreibenden Commit `f2196cf8` sind es **380**, ab dem Commit dieses Reports **381** — die Annahme, gemeint sei der Commit, der die Zeile **schrieb**, steht nirgends. Die tragende Hälfte der Zeile (Eigenschaft + Kommando) ist davon unberührt und hält auch diesen Lauf aus. **Kein LOW** — die Zeile erfüllt, was [`MR-058`](../../harness/conventions.md#mr-058--eine-messung-die-ihr-eigener-vorgang-bewegt-wird-nach-dem-vorgang-genommen) Setzung 2 verlangt. | [`MR-058`](../../harness/conventions.md#mr-058--eine-messung-die-ihr-eigener-vorgang-bewegt-wird-nach-dem-vorgang-genommen) Setzung 2 · [`AGENTS.md`](../../AGENTS.md) §3.7 | `harness/migration.md:120` | **ja** — `git ls-tree -r --name-only <commit> docs/reviews/ \| grep -c '\.md$'` gegen den Betrag; kein `make`-Ziel fährt das | Zeitanker ohne auflösbare Adresse |

### Belege

```sh
# N-9 — die Begründung und der Ausgang, der sie widerlegt, stehen in derselben Datei
sed -n '170p;207p' harness/migration.md
git ls-files 'docs/plan/planning/done/**/*.zip' | wc -l                      # 0  -> beide Stub-Zeilen haben null Instanzen

# N-10 — dieselbe Zeile, zwei Zeitpunkte
sed -n '111p' harness/migration.md | grep -o 'sobald die erste Archivierung[^;|]*'
sed -n '169,170p' harness/migration.md

# N-11 — der Geltungsbereich, auf den sich die Schließung beruft
grep -n 'Geltungsbereich' -A 5 harness/conventions/MR-039-*.md
grep -n 'umbenannte Sektionen' .harness/baseline/v6.7.2/regelwerk/modul-02-harness-bootstrap.md
{ ls harness/conventions/*.md; ls harness/conventions/done/*.md; } | wc -l   # 59 = 55 + 4

# N-12 — was die Quelle über die Ergebnisnotiz sagt
sed -n '256,265p' .harness/baseline/v6.7.2/regelwerk/modul-06-roadmap.md

# N-13 — der Betrag am schreibenden Commit und an diesem Lauf
git ls-tree -r --name-only f2196cf8 docs/reviews/ | grep -c '\.md$'          # 380
ls docs/reviews/*.md | wc -l                                                # 380 (vor diesem Report)
```

**Keine Erwartungswerte** — alle Beträge wandern mit dem Baum.

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| **N-1, erste Hälfte** — Ausdehnungs-Schritt als eigene Interpretation benannt? | **behoben.** `:147-151` spricht ihn aus: *„Die Klausel benennt fünf Artefakt-Klassen, keine Vorlagen-Dateien … Er ist eine eigene Interpretation dieses Dokuments, keine Aussage der Klausel selbst."* Selbst gegen [ADR-0018](../plan/adr/0018-ziel-fassung-regiert-die-migration.md) Festlegung 4 gehalten (*„Sie wählt die Quelle, sie liest sie nicht vor"*) — die Deklaration ist genau das, was die ADR für sich ausschließt |
| **N-1, zweite Hälfte** — beide Stub-Vorlagen in §5 b und in ihren §4-Zeilen verknüpft? | **behoben, formal.** `:217-218` nennt acht Zeilen namentlich, `:111-112` tragen den Rückverweis. Die *Begründung* der Aufnahme ist N-9/N-10 |
| **N-1 — trägt `modul-06` Schritt 4 die Stub-Lesart?** | **ja, selbst gelesen** (`v6.7.2`, Zeilen 256–265): *„Slice-Dateien und Welle-Plan bleiben als gekürzter Stub"* — der Stub **ist** dieselbe Datei in gekürzter Form. Die Lesart trägt für die zwei Stubs; für `welle-results` nicht (N-12) |
| **N-1 — neue Asymmetrie bei anderen Klassen?** | **geprüft, ohne Befund.** Die fünf Klassen einzeln durchgezählt: ADR (1 Vorlage, kein Stub), Carveout (1), Review-Report (1 — `modul-06` Schritt 4: *„Review-Reports bekommen keinen Stub"*), Slice (2), Welle (3). Keine Klasse hat eine Lifecycle-Vorlage, die die Aufzählung übergeht |
| **N-2** — Default-Widerspruch bei der Observation-Zeile | **behoben.** `:262-266` zieht die Folgerung jetzt selbst: die zitierte Unveränderlichkeit *„schließt den Ausgang übernommen aus Buchstabe a aus"*, die Zeile bleibt offen statt per Default zugeordnet |
| **N-3** — Default-Satz in allen drei §6-Einträgen | **behoben, gemessen:** `grep -c "Bleibt unten unter Buchstabe a" harness/migration.md` → **0**. Zwei Einträge tragen jetzt *„Weder Buchstabe a noch Buchstabe b ist damit zugewiesen"*, der dritte ist entfallen (N-11) |
| **N-3** — Ausnahme-Satz in §5 a: Ausnahme oder versteckte Zuordnung? | **echte Ausnahme.** `:199-200`: *„Ausgenommen sind die in §6 als offen geführten Zeilen: Für sie ist noch nicht entschieden, ob sie in diese Menge fallen oder unter Buchstabe b gehören."* Keine der beiden Seiten wird genannt; `:178-179` sagt dasselbe von der anderen Seite (*„ausgenommen, nicht ihm zugeordnet"*) |
| **N-3** — wie viele Zeilen sind jetzt offen? | **zwei** (`observation.template.md`, `gate.template.md`), zusammen **119** Instanzen gegen **178** in Runde 2. Das ist die Zahl, die der Abschluss von N-3 verlangte: jede Zeile, für die das Dokument die Zuordnung bestreitet, steht außerhalb der geschlossenen Menge |
| **N-4** — trägt `MR-039` die Umklassifizierung? | **nur zur Hälfte** — N-11. Die Richtung stimmt (Setzung 1 antwortet für das neue Pflichtfeld), die Reichweite nicht |
| **N-4** — ist `MR-039` überhaupt zitierfähig? | **ja, eigens geprüft.** Der Eintrag trägt eine Kopf-Marke (*ÜBERHOLT: die Deckungs-Messung …*) und einen Auflösungs-Trigger, der mit dem Umzug in die Verzeichnis-Form gefeuert hat; die Marke erklärt ausdrücklich *„Setzung 1, 2 und 3 gelten fort — je einzeln geprüft"*, und `grep -c '^\| \[MR-039\]' harness/conventions.md` → **1** in der **aktiven** Tabelle |
| **N-5** — Eigenschaft statt Endwert, und hält sie diesen Lauf aus? | **behoben.** `:120` nennt zuerst die Eigenschaft mit Kommando und benennt den Selbstbezug ausdrücklich: *„auch der Review-Lauf, der diese Zeile prüft"*. Betrag am schreibenden Commit `f2196cf8` gemessen: **380** = korrekt. Rest-Befund nur INFO (N-13) |
| **N-5** — Markierung *kein Endwert* statt *kein Erwartungswert* | **kein Befund.** [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) Setzung 2 lässt zwei Wege — Kennzeichnung **oder** *„ein Kriterium, das den Gegenstand selbst misst"*; die Zeile geht den zweiten |
| **N-6** — `ADR-0043`-Zitat zeichenweise | **behoben.** Quelle: *„Fällt auch dieser aus, wächst die Basis weiter, und die Kosten wachsen mit."* — Prüfgegenstand `:88` identisch inklusive Schlusspunkt, jetzt in `*„…"*`-Auszeichnung |
| **N-7** (INFO Runde 2) — Rollen-Bezeichnung | **nachgezogen.** `f2196cf8` trägt *„Rolle Implementer"*. Weiterhin ohne Konventions-Anker, weiterhin kein Finding |
| **Hypothese, geprüft und verworfen:** bindet §5 b eine nicht belegbare Interpretation entgegen der Auflage aus Slice-Plan §1? | **REFUTED mit Beleg.** `:191-192` erklärt §5 vorab als *„Formvorgabe für einen künftigen Bericht, keine ADR-Aussage"*, und §6 erster Punkt bucht genau das: *„§4 und §5 dieses Dokuments sind darum **keine** aus den sechs ADRs abgeleiteten Normen"*. Die Auflage ist auf Abschnitts-Ebene erfüllt; die Differenz zu `observation`/`gate` ist eine Differenz der Beleglage, keine der Behandlung |
| Register-Vollständigkeit und jede Zahl der Tabelle | **geprüft, ohne Befund** — alle elf Kommandos nachgefahren: 25 Vorlagen = 25 Zeilen · ADR 46 · Carveout 6 · Observation 104 (und 104 `observation.md`) · Slice 229 · Welle-Results 12 · Welle 3+12=15 · MR 55+4=59 · Sensor 15 · Skill 1 · Archiv-ZIP 0. Keine Zahl steht an zwei Stellen unterschiedlich |
| Anker und Links nach der Umformulierung | **geprüft, ohne Befund** — alle 18 relativen Ziele existieren, die vier neu/geändert zitierten `MR`-Anker lösen in [`harness/conventions.md`](../../harness/conventions.md) auf (`grep -c 'id="…"'` → je **1**), `#6-offene-fragen` passt zur Überschrift |
| [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) — behauptete Targets | **geprüft, ohne Befund** — der neue Satz `:172` nennt `make archive-welle`; `grep -cE '^archive-welle:' Makefile` → **1**, und das Ziel steht in [`harness/README.md`](../../harness/README.md) §Werkzeuge als *kein Gate* |
| [`AGENTS.md`](../../AGENTS.md) §3.8 an `f2196cf8` | **geprüft, ohne Befund** — der Commit berührt genau eine Datei (`harness/migration.md`); weder [`AGENTS.md`](../../AGENTS.md) §3 noch [`harness/conventions.md`](../../harness/conventions.md) noch `harness/conventions/` sind angefasst |
| Out-of-Scope-Treue (sechs Punkte aus Slice-Plan §1) | **geprüft, ohne Befund** — kein Report unter `docs/migrations/`, kein rückwirkender Report, keine ADR, kein Eintrag im Adaptions-Block, kein Sensor, keine Änderung an §Baseline, kein Produkt-Code und keine emittierte Vorlage |
| [`AGENTS.md`](../../AGENTS.md) §3.7 — Chronik im Prüfgegenstand | **geprüft, ohne Befund** — der neue Text trägt keine Befund-Kennung, keine Runden-Erzählung und keinen Konjunktiv über verworfene Fassungen; die Begründungs-Arbeit steht in der Commit-Message, nicht im Dokument |
| Commit-Form `f2196cf8` | **geprüft, ohne Befund** — Rolle in der Message, `Ref: ADR-0018, MR-039, MR-058`, keine Attributions-Zeilen |

### Negativbefund-Pflicht: die 25 Register-Zeilen nach dieser Runde

| Kategorie | Zeilen | welche |
|---|---|---|
| **Fall a** (vier Ausgänge) | **15** | `AGENTS` · `adr/README` · `carveouts/README` · `planning/README` · `reconciliation` · `roadmap` · `MR-NNN-titel` · `conventions` · `harness/README` · `closure-note-reviewer` · `reviewer` · `project-readme` · `architecture` · `lastenheft` · `spezifikation` |
| **Fall b** (append-only) | **8** | `adr/NNNN-titel` · `slice` · `archiv-stub-slice` · `welle` · `welle-results` · `archiv-stub-welle` · `carveout` · `review-report` |
| **offen in §6** | **2** | `observation` · `gate` |

**15 + 8 + 2 = 25**, und **25** ist die gemessene Zahl der Vorlagen
(`find .harness/baseline/v6.7.2/templates -name '*.template.md' | wc -l`, kein Erwartungswert).
Die Summe geht auf; jede Zeile steht in genau einer Kategorie. **Vorbehalt zu zwei der acht:**
`archiv-stub-slice` und `archiv-stub-welle` stehen unter Fall b nur nach dem Ableitungs-Absatz —
ihre eigenen Tabellenzeilen lesen sich für den heutigen Stand anders (N-10).

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 3 |
| LOW | 1 |
| INFO | 1 |

**Finding-Klassen dieses Laufs:** Begründung einer Mengen-Zuordnung von der eigenen Tabelle
widerlegt · Zwei Antworten derselben Datei für denselben Zeitpunkt · Norm-Beleg trägt einen
Teilfall, die Zuordnung schließt den ganzen Fall · Formuliertes Kriterium und angewandte
Eigenschaft fallen auseinander · Zeitanker ohne auflösbare Adresse

## Verdikt

**Merge-blockierend: ja** — drei MEDIUM, kein HIGH. Die sechs Befunde der Runde 2 sind der Sache
nach abgearbeitet: N-2, N-3, N-5 und N-6 sind behoben, N-1 zur Hälfte (der Schritt ist benannt,
seine Begründung trägt nicht), N-4 in der Richtung richtig und in der Reichweite zu weit. Die drei
MEDIUM liegen **alle** in der Begründungs-Schicht der Zuordnung, nicht im Register selbst — die 25
Zeilen, ihre Zahlen und ihre Vollständigkeit sind unverändert tragfähig, und keiner der Befunde
verlangt eine Änderung an einem Artefakt außerhalb von `harness/migration.md`.

Der Rückschritt gegenüber Runde 2 ist **keiner**: N-9 und N-10 entstehen an Sätzen, die `f2196cf8`
neu geschrieben hat, um N-1 zu schließen; sie sind der Preis dieser Nacharbeit, nicht ein Regress
des Gegenstands. N-12 ist die verbliebene Kante desselben Schritts.

**Übergabe:** Findings gehen an den Implementer. Die **Finding-Klassen** gehen zusätzlich in die
Slice-Closure §7 und von dort in den Zähler des Beobachtungs-Registers — das ist **Planner**-Arbeit
([`AGENTS.md`](../../AGENTS.md) §3.10), nicht die dieses Laufs. Dieser Report ist ein
**Lauf-Beleg** und wird über Läufe hinweg nicht wieder gelesen. Er ersetzt keine Verifikation —
DoD-/Spec-Konformität prüft der Verifier separat (Modul 11; anderes Prüf-Artefakt, anderer
Eingabe-Kontext).
