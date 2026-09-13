# Review-Report: slice-migration-hat-ein-instanz-register, Runde 4 — 2026-09-13

**Review-Art:** Code-Review — der Nacharbeits-Commit gegen die vier Befunde der Runde 3, gegen den
Slice-Plan und gegen die dort benannten Quellen. Kein Plan-Review, keine Verifikation
(DoD-Abhakung ist Verifier-Arbeit, Modul 11).

**Gegenstand:** `3bef03c8` (+55/−25, `harness/migration.md`). Arbeitsbaum leer; `3bef03c8` ist
`HEAD`.

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
> des Laufs und darf ihn festhalten (`v6.7.2` · `regelwerk/modul-02-harness-bootstrap.md`
> §Freshness-Audit der vendored Baseline — diese Zeile ist selbst ein Beispiel der Form).

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde — ohne diese Liste ist der Lauf nicht
reproduzierbar):

- Slice-Plan `slice-migration-hat-ein-instanz-register`, gelesen an seinem Lifecycle-Stand
  `in-progress/` — §1 *Ziel und Abgrenzung* samt der **Auflage des Auftraggebers** und den sechs
  Out-of-Scope-Punkten
- [ADR-0018](../plan/adr/0018-ziel-fassung-regiert-die-migration.md) (`Accepted`) §Entscheidung
  Festlegung 4, und die von ihr zitierte Klausel **an ihrer Quelle**: `v6.7.2` ·
  `regelwerk/modul-02-harness-bootstrap.md` §Freshness-Audit der vendored Baseline (Schritt 2),
  Eigenschaft *Der Review vergleicht auch die Form* — im **ganzen** Absatz gelesen, nicht nur im
  zitierten Satz
- [`MR-039`](../../harness/conventions.md#mr-039--ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines)
  im **Volltext seiner Datei** — Kopf-Marke, Geltungsbereich, Setzung 1/2/3, Begründung und
  Auflösungs-Trigger; dazu
  [`MR-058`](../../harness/conventions.md#mr-058--eine-messung-die-ihr-eigener-vorgang-bewegt-wird-nach-dem-vorgang-genommen),
  [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2 und [`harness/conventions.md`](../../harness/conventions.md) §Adaptions-Block
- `v6.7.2` · `regelwerk/modul-06-roadmap.md` §Wellen-Closure-Prozedur Schritt 4 **und** §Das
  Beobachtungs-Register — beide selbst gelesen, nicht über die Wiedergabe im Prüfgegenstand
- [`AGENTS.md`](../../AGENTS.md) §3 (Hard Rules), namentlich §3.4, §3.6, §3.7, §3.8, §3.9
- vorherige Findings am gleichen Gegenstand: die Reports der **Runde 1** (`93c54d1b`), **Runde 2**
  (`8647edd3`) und **Runde 3** (`0cbb4d7e`) sowie der Verifikations-Report (`fe401bc7`) — alle vier
  als **Kontext**, keine ihrer Einschätzungen übernommen; jeder Fund unten ist gegen seine Quelle
  neu gemessen

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
| N-14 | **MEDIUM** | Die MR-Zeile bekommt den Ausgang *append-only* — Bedingung: *„bestehende Instanzen bleiben unverändert"* —, und als Beleg dient [`MR-039`](../../harness/conventions.md#mr-039--ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines) Setzung 1, die das Gegenteil anordnet: *„bekommt es **jeder** Eintrag mit vollem Rumpf, **auch der vor dem Sprung geschriebene**"*, also 55 der 59 Instanzen rückwirkend. Die Quelle, aus der beide Antworten stammen, führt an der zitierten Stelle **zwei** Zweige — Singletons (neue Pflicht-Felder und umbenannte Sektionen: Nacharbeit) und wiederkehrende Templates (Append-only) —, und `MR-039` ist der erste; das Dokument führt ihn als *„zweiten, unabhängigen Beleg derselben Struktur"*. | [ADR-0018](../plan/adr/0018-ziel-fassung-regiert-die-migration.md) §Entscheidung Festlegung 4 · `v6.7.2` · `regelwerk/modul-02-harness-bootstrap.md` §Freshness-Audit der vendored Baseline (Schritt 2) · [`AGENTS.md`](../../AGENTS.md) §3.6 | `harness/migration.md:190-202` (Zuordnung), `:249` (die Bedingung, die sie erbt), `:251-257` (Ausnahme) | **nein** — kein Modul der [`.d-check.yml`](../../.d-check.yml) hält eine Zuordnung gegen den Wortlaut des `MR`, auf den sie sich beruft | Norm-Beleg belegt den Gegenzweig derselben Klausel |
| N-15 | **MEDIUM** | Die Ausnahme verschiebt die Grenze der eingefrorenen Teilmenge vom Sprung-Datum auf den Retirement-Status und stützt das auf `MR-039` Setzung 1/2 — deren Geltungsbereich aber ausdrücklich lautet *„die **Form** eines Eintrags dieses Blocks, **wenn** ein adoptierter Baseline-Stand ein neues **Pflichtfeld** einführt"*, während dieselbe Baseline-Stelle **zwei** Auslöser nennt (*„neue **Pflicht**-Felder **und umbenannte Sektionen**"*). Für den zweiten Auslöser antwortet das Dokument jetzt *append-only*, obwohl keine Quelle ihn beantwortet — die Auflage des Slice-Plans verlangt für genau diesen Fall eine offene Frage. | [`MR-039`](../../harness/conventions.md#mr-039--ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines) §Geltungsbereich · `v6.7.2` · `regelwerk/modul-02-harness-bootstrap.md` §Freshness-Audit der vendored Baseline (Schritt 2) · Slice-Plan §1 *Auflage des Auftraggebers* | `harness/migration.md:251-257`, `:190-202` | **nein** | Norm-Beleg trägt einen Teilfall, die Zuordnung schließt den ganzen Fall |
| N-16 | **MEDIUM** | §5 a bestimmt seinen Geltungsbereich über *„jede Vorlage, die §4 **nicht** als wiederkehrend ausweist"*, und die Bedingung von §5 b lautet *„die Vorlage ist wiederkehrend (§4)"* — §4 weist aber weiterhin genau **acht** Zeilen als wiederkehrend aus (`:139`), die MR-Zeile nicht. Wer das Dokument als Report-Form anwendet, erhält für dieselbe Zeile aus §4 + §5 a die vier Ausgänge und aus §5 b *append-only*; beide Partitionen gehen auf 25 auf (15/8/2 bzw. 14/9/2). | Slice-Plan §2 Liefer-Punkt (2) (*„genau einer von vier Ausgängen … eine geschlossene Menge"*) · [`AGENTS.md`](../../AGENTS.md) §3.6 | `harness/migration.md:139`, `:8`, `:209`, `:213`, `:249` gegen `:236-238` | **nein** — kein Sensor hält zwei Stellen derselben Datei gegeneinander | Zwei Antworten derselben Datei für denselben Zeitpunkt |
| N-17 | **MEDIUM** | Die Begründung, warum a) für wiederkehrende Vorlagen nicht passt, sagt über den Ausgang *keine Instanz*, er setze *„eine **einzelne**, feste Instanz voraus"* — derselbe Ausgang ist in `:223` definiert als *„die Vorlage hat in diesem Repo **keine** Instanz (§4)"* und trägt die zwei a)-Zeilen `reconciliation.template.md` und `closure-note-reviewer.template.md`, die beide null Instanzen haben. Als Kriterium gelesen entzieht der Satz genau den zwei Zeilen, die ihn brauchen, ihren einzigen Ausgang. | [`AGENTS.md`](../../AGENTS.md) §3.6 · Slice-Plan §1 (*„Dieses Dokument leitet ab"*) | `harness/migration.md:241-242` gegen `:223`, `:115`, `:125` | **nein** | Begründung einer Mengen-Zuordnung von der eigenen Tabelle widerlegt |
| N-18 | **MEDIUM** | Das Ausdehnungs-Kriterium lautet jetzt *„alle Vorlagen, die zum selben wiederkehrenden **Vorgang** gehören"* und wird laut Text *„einheitlich"* angewandt; `v6.7.2` · `regelwerk/modul-06-roadmap.md` §Das Beobachtungs-Register sagt *„Eingetragen wird bei der **Slice-Closure**"*, womit `observation.template.md` zum selben wiederkehrenden Vorgang gehört wie `slice.template.md`. §6 führt dieselbe Zeile als unentschieden, und der Schlusssatz *„acht Zeilen, keine mehr"* hält das neue Kriterium nicht aus. | `v6.7.2` · `regelwerk/modul-06-roadmap.md` §Das Beobachtungs-Register · [`AGENTS.md`](../../AGENTS.md) §3.6 | `harness/migration.md:148-149`, `:164` gegen `:113`, `:285-291` | **nein** | Geweitetes Kriterium deckt eine ausdrücklich offen gehaltene Zeile mit |
| N-19 | **LOW** | Die Review-Report-Zeile trägt *„am Stand dieses Commits **380**"*; an `3bef03c8`, dem Commit, der sie heute trägt, gibt `git ls-tree -r --name-only 3bef03c8 docs/reviews/ \| grep -c '\.md$'` → **381**. Der Betrag stimmte an `f2196cf8` und wurde von `0cbb4d7e` überholt; `3bef03c8` hat dieselbe Datei angefasst und die Zahl stehen lassen. | [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) Setzung 2 · [`MR-058`](../../harness/conventions.md#mr-058--eine-messung-die-ihr-eigener-vorgang-bewegt-wird-nach-dem-vorgang-genommen) Setzung 2 | `harness/migration.md:120` | **ja** — das Kommando oben gegen den Betrag; kein `make`-Ziel fährt es | Zeitanker ohne auflösbare Adresse |
| N-20 | **INFO** | Die Zuordnung der MR-Zeile setzt voraus, dass die Verzeichnis-Form des Adaptions-Blocks an der Geltung von `MR-039` nichts ändert. Dessen eigener Auflösungs-Trigger sagt für genau diesen Fall: *„permanent, solange dieser Block in der **Inline-Form** läuft. Er fällt mit dem Umzug in die Verzeichnis-Form … Setzung 2 verliert ihren Gegenstand, Setzung 1 und 3 sind neu zu prüfen."* Die Kopf-Marke hält die drei Setzungen *„je einzeln geprüft"* am Leben; welche Prüfung das war, nennt weder sie noch das Dokument. **Kein Finding** — die Annahme ist plausibel und nur undokumentiert. | [`MR-039`](../../harness/conventions.md#mr-039--ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines) §Auflösungs-Trigger · [`MR-045`](../../harness/conventions.md#mr-045--der-adaptions-block-läuft-in-der-verzeichnis-form) | `harness/migration.md:190-202` | **nein** | Beleg-Eintrag mit gefeuertem Auflösungs-Trigger zitiert |

### Belege

```sh
# N-14 — beide Zweige derselben Klausel, im selben Absatz der Quelle
sed -n '277,284p' .harness/baseline/v6.7.2/regelwerk/modul-02-harness-bootstrap.md
grep -n 'auch der vor dem Sprung geschriebene' harness/conventions/MR-039-*.md
{ ls harness/conventions/*.md; ls harness/conventions/done/*.md; } | wc -l   # 59 = 55 aktiv + 4 done

# N-15 — der Geltungsbereich und der zweite, unbeantwortete Auslöser
grep -n 'Geltungsbereich' -A 4 harness/conventions/MR-039-*.md
grep -n 'umbenannte Sektionen' .harness/baseline/v6.7.2/regelwerk/modul-02-harness-bootstrap.md

# N-16 — die vier Stellen, die b) weiter bei acht kappen
grep -nE 'Acht dieser Zeilen|nicht\*\* als wiederkehrend ausweist|die Vorlage ist wiederkehrend' harness/migration.md
sed -n '8p;139p;213p;249p' harness/migration.md

# N-17 — der Satz und die zwei a)-Zeilen mit null Instanzen
sed -n '223p;241,242p' harness/migration.md
grep -nE '^\| .*\| keine Instanz \|' harness/migration.md | cut -d: -f1        # 111 112 115 125

# N-18 — das Kriterium und die Quelle, die observation.md am Slice-Vorgang aufhaengt
sed -n '148,149p' harness/migration.md
grep -n 'Eingetragen wird bei der \*\*Slice-Closure\*\*' .harness/baseline/v6.7.2/regelwerk/modul-06-roadmap.md

# N-19 — der Betrag je Commit
for c in f2196cf8 0cbb4d7e 3bef03c8; do git ls-tree -r --name-only $c docs/reviews/ | grep -c '\.md$'; done   # 380 381 381

# N-20 — der gefeuerte Trigger und die Verzeichnis-Form
grep -n 'Auflösungs-Trigger' -A 4 harness/conventions/MR-039-*.md
grep -c 'Der Adaptions-Block läuft in der Verzeichnis-Form' harness/conventions.md   # 1
```

**Keine Erwartungswerte** — alle Beträge wandern mit dem Baum.

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| **N-9, erste Hälfte** — Satz *„Die vier Ausgänge aus Buchstabe a setzen eine bestehende Instanz voraus"* getilgt? | **behoben, gemessen:** `grep -c 'setzen eine bestehende Instanz voraus' harness/migration.md` → **0**. Die Zuordnung der zwei Stub-Zeilen ruht jetzt auf der Klassenzugehörigkeit, nicht auf einer Aussage über den Instanzenstand |
| **N-9, zweite Hälfte** — hat die Umformulierung die Klasse geschlossen? | **nein** — N-17. Der Nachfolgesatz *„setzen eine **einzelne**, feste Instanz voraus"* wird von demselben Ausgang widerlegt, nur eine Stufe schwächer. Die zweite gemeldete Hälfte (*„passen nicht auf eine wachsende Menge von Alt-Instanzen"*) ist dagegen sauber geschlossen: `:243-245` sagt ausdrücklich *„unabhängig davon, ob heute überhaupt schon Instanzen bestehen … sind es heute **keine**"* |
| **N-10** — tragen §4-Zeilen und Ableitungs-Absatz dieselbe Zeitform? | **behoben, gemessen:** `grep -c 'sobald die erste Archivierung eine Instanz erzeugt, gilt für sie' harness/migration.md` → **0**. Beide Stellen sagen jetzt dasselbe — `:111` *„schon jetzt §5 Buchstabe b zugeordnet … unabhängig vom heutigen Instanzenstand"*, `:200-202` *„Die Klassenzugehörigkeit gilt bereits jetzt; der Instanzenstand ändert sich erst künftig"*. Die Trennung Eigenschaft-der-Vorlage / Zustand-des-Repos trägt und ist widerspruchsfrei |
| **N-10** — neue Unschärfe durch die Umformulierung? | **ja, aber nicht an den zwei Stub-Zeilen** — N-17 (Begründungs-Satz in b) und N-16 (die Klasse *wiederkehrend* ist für die MR-Zeile nirgends gesetzt). Die Stub-Zeilen selbst sind nach dieser Runde die saubersten Zeilen des Registers |
| **N-11** — deckt „aktiv/retiriert" wirklich „vor/nach Sprung"? | **nein, und darin liegt N-14/N-15.** Zwei verschiedene Trennlinien: zeitlich (ADR-0018: keine bestehende Instanz wird angefasst) gegen Zustand (`MR-039`: 55 von 59 bestehenden Instanzen **werden** angefasst). Die Gemeinsamkeit ist, dass *irgendeine* Teilmenge eingefroren bleibt — ein Merkmal, das auch der Ausgang *übernommen* aus Buchstabe a erfüllt, sobald er eine Instanz auslässt; als Kriterium trennt es a) und b) nicht mehr |
| **N-11** — ist die Umbuchung von a) nach b) wenigstens innerhalb des Dokuments konsistent? | **nein** — N-16. Die Zuordnung steht in §4 Absatz 3 und §5 b; die vier Stellen, die den Geltungsbereich von a) und b) definieren, sind unverändert |
| **N-12** — ist *„Begleit-Vorlage desselben Abschluss-Vorgangs"* in der Quelle belegt? | **die zitierte Hälfte ja, die tragende nein.** `v6.7.2` · `regelwerk/modul-06-roadmap.md` Schritt 4 sagt wörtlich *„Die **Ergebnisnotiz** bleibt vollständig und flach"* — die Abgrenzung gegen die Stub-Form ist damit belegt. Die **Aufnahme**-Begründung (*„derselbe Vorgang füllt beide Vorlagen"*) ist es nicht: Die Welle-Plan-Datei wird bei der **Eröffnung** angelegt (Schritt 3 der Eröffnung), die Ergebnisnotiz bei der **Closure**; das Dokument sagt an `:161-163` beides nebeneinander (*„zusätzlich zur offenen Form"* und *„derselbe Vorgang füllt beide"*) |
| **N-12** — gehört `welle-results` nach dem neuen Kriterium noch zu b)? | **ja, aber nicht aus dem genannten Grund.** Die Eigenschaft, die sie mit den acht teilt, ist die **wachsende Instanzmenge** (12 Instanzen, `find docs/plan/planning/done -maxdepth 1 -iname 'welle-*-results.md' \| wc -l`) — dieselbe Eigenschaft, die `observation` (104) und `gate` (15) haben und die §6 offen lässt. Der genannte Grund (*Vorgangs-Zugehörigkeit*) ist der, der über-deckt: N-18 |
| **Vier unverlinkte `MR-*`/`ADR-*`-Tokens (Selbstfund des Implementers)** | **behoben, und vollständig gegengeprüft:** Alle Vorkommen der Form `(MR\|ADR)-[0-9]{3,4}` in `harness/migration.md` stehen in einem Link — gemessen, indem zuerst jede korrekt verlinkte Form entfernt und dann der Rest gesucht wurde (`sed -E 's/\[\`?(MR\|ADR)-[0-9]{3,4}\`?\]\([^)]*\)//g'` → `grep -nE '(MR\|ADR)-[0-9]{3,4}'` → **keine Treffer**). Nicht nur die vier genannten: **35** Tokens insgesamt, **0** unverlinkt |
| Link- und Anker-Auflösung nach der Umformulierung | **geprüft, ohne Befund** — alle **18** eindeutigen relativen Ziele existieren; der neu mehrfach zitierte `MR-039`-Anker löst in [`harness/conventions.md`](../../harness/conventions.md) auf (`grep -c 'id="mr-039--…"'` → **1**), `#6-offene-fragen` passt zur Überschrift |
| Register-Vollständigkeit und Zählung | **geprüft, ohne Befund bei der Arithmetik.** Unabhängig nachgezählt: **25** Tabellenzeilen = **25** Vorlagen im Baum; b) namentlich **8** im Ableitungs-Absatz + **1** (MR) = **9**; §6 offen **2**; a) als Rest **14**. **14 + 9 + 2 = 25** geht auf, und jede Zeile steht in genau einer Kategorie. **Vorbehalt:** Dieselbe Datei stützt zugleich die Partition **15 / 8 / 2**, die ebenfalls auf 25 aufgeht — das ist N-16, kein Rechenfehler |
| Zahlen der §4-Tabelle | **geprüft, ohne Befund außer `:120`** — alle Kommandos nachgefahren: ADR 46 · Carveout 6 · Observation 104 · Slice 229 · Welle-Results 12 · Welle 3+12=15 · MR 55+4=59 · Sensor 15 · Skill 1 · Archiv-ZIP 0. Einzige Abweichung: die Review-Report-Zeile (N-19) |
| [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) — behauptete Targets | **geprüft, ohne Befund** — das Dokument nennt genau ein `make`-Ziel (`make archive-welle`); es existiert als Regel und steht in [`harness/README.md`](../../harness/README.md) §Werkzeuge als *kein Gate* |
| [`AGENTS.md`](../../AGENTS.md) §3.8 an `3bef03c8` | **geprüft, ohne Befund** — der Commit berührt genau **eine** Datei (`harness/migration.md`); weder [`AGENTS.md`](../../AGENTS.md) §3 noch [`harness/conventions.md`](../../harness/conventions.md) noch `harness/conventions/` sind angefasst. `MR-039` und [ADR-0018](../plan/adr/0018-ziel-fassung-regiert-die-migration.md) werden zitiert, nicht geändert — **eine Erweiterung findet an ihnen nicht statt.** Was das Dokument über sie hinaus setzt, setzt es in sich selbst (N-14/N-15) |
| [`AGENTS.md`](../../AGENTS.md) §3.4 — Umgang mit der immutablen ADR | **ein Randbefund, unterhalb der Meldeschwelle:** Der neue Text formuliert den Kern der zitierten Klausel als *„die eingefrorene Teilmenge wird nicht rückwirkend umgeschrieben"* (`:255-256`); der Wortlaut der Quelle lautet *„**bestehende** werden nicht rückwirkend umgeschrieben"*. Die ADR selbst bleibt unangetastet — die Abschwächung wirkt nur innerhalb dieses Dokuments und ist in N-14 enthalten |
| [`AGENTS.md`](../../AGENTS.md) §3.7 — Chronik im Prüfgegenstand | **geprüft, ohne Befund** — keine Befund-Kennung, keine Runden-Erzählung, kein Konjunktiv über verworfene Fassungen. Der einzige Treffer eines Chronik-Musters (`:93`, *„Delta-Nachweis in slice-224"*) ist die zitierte Ausgabe des danebenstehenden `grep`, kein Erzähl-Satz |
| Out-of-Scope-Treue (sechs Punkte aus Slice-Plan §1) | **geprüft, ohne Befund** — kein Report unter `docs/migrations/`, kein rückwirkender Report, keine ADR, kein Eintrag im Adaptions-Block, kein Sensor, keine Änderung an §Baseline, kein Produkt-Code und keine emittierte Vorlage |
| Regress an den Fixes der Runden 1 und 2 | **geprüft, ohne Befund.** N-1 (Ausdehnungs-Schritt als eigene Interpretation benannt) steht unverändert an `:150-151`; N-2 und N-3 (kein Default-Satz, zwei Zeilen ausdrücklich unzugewiesen) halten — `grep -c 'Bleibt unten unter Buchstabe a'` → **0**, beide §6-Einträge tragen weiter *„Weder Buchstabe a noch Buchstabe b ist damit zugewiesen"*; N-6 (`ADR-0043`-Zitat) zeichenweise unverändert. **Kein vorher bestätigter Fix ist wieder aufgerissen** |
| Commit-Form `3bef03c8` | **geprüft, ohne Befund** — Rolle in der Message, `Ref: ADR-0018, MR-039, MR-058`, keine Attributions-Zeilen |

### Negativbefund-Pflicht: die 25 Register-Zeilen nach dieser Runde

| Kategorie | Zeilen | welche |
|---|---|---|
| **Fall a** (vier Ausgänge) | **14** | `AGENTS` · `adr/README` · `carveouts/README` · `planning/README` · `reconciliation` · `roadmap` · `conventions` · `harness/README` · `closure-note-reviewer` · `reviewer` · `project-readme` · `architecture` · `lastenheft` · `spezifikation` |
| **Fall b** (append-only) | **9** | `adr/NNNN-titel` · `slice` · `archiv-stub-slice` · `welle` · `welle-results` · `archiv-stub-welle` · `carveout` · `review-report` · **`MR-NNN-titel`** |
| **offen in §6** | **2** | `observation` · `gate` |

**14 + 9 + 2 = 25**, und **25** ist die gemessene Zahl der Vorlagen
(`find .harness/baseline/v6.7.2/templates -name '*.template.md' | wc -l`, kein Erwartungswert).
Die Summe des Implementers geht auf. **Vorbehalt zur neunten Zeile:** Sie steht unter Fall b nur
nach §4 Absatz 3 und §5 b; nach `:139`, `:213` und `:249` steht sie unter Fall a (N-16). **Vorbehalt
zur Zeile `observation`:** Nach dem Kriterium an `:148-149` gehörte sie zu Fall b, nach §6 ist sie
offen (N-18).

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 5 |
| LOW | 1 |
| INFO | 1 |

**Finding-Klassen dieses Laufs:** Norm-Beleg belegt den Gegenzweig derselben Klausel ·
Norm-Beleg trägt einen Teilfall, die Zuordnung schließt den ganzen Fall · Zwei Antworten
derselben Datei für denselben Zeitpunkt · Begründung einer Mengen-Zuordnung von der eigenen
Tabelle widerlegt · Geweitetes Kriterium deckt eine ausdrücklich offen gehaltene Zeile mit ·
Zeitanker ohne auflösbare Adresse · Beleg-Eintrag mit gefeuertem Auflösungs-Trigger zitiert

**Drei dieser Klassen laufen zum zweiten Mal:** *Zwei Antworten derselben Datei für denselben
Zeitpunkt* (Runde 3 als N-10), *Begründung einer Mengen-Zuordnung von der eigenen Tabelle
widerlegt* (Runde 3 als N-9) und *Zeitanker ohne auflösbare Adresse* (Runde 3 als N-13); *Norm-Beleg
trägt einen Teilfall* ebenfalls (Runde 3 als N-11). Sie treffen jeweils **anderen** Text als in
Runde 3 — die Nacharbeit hat die gemeldete Stelle geschlossen und die Klasse an einer neuen Stelle
reproduziert.

## Verdikt

**Merge-blockierend: ja** — fünf MEDIUM, kein HIGH.

**Zwei der vier Befunde der Runde 3 sind geschlossen, zwei nicht.** N-10 ist **sauber behoben**:
Tabellenzeilen und Ableitungs-Absatz tragen dieselbe Zeitform, und die Trennung *Eigenschaft der
Vorlage* gegen *Zustand des Repos* ist widerspruchsfrei — an den zwei Stub-Zeilen hat die
Umformulierung keine neue Unschärfe erzeugt. N-12 ist **belegt, aber mit verschobenem Grund**: Das
wörtliche Zitat aus Schritt 4 trägt die Abgrenzung, die Aufnahme-Begründung trägt dafür jetzt ein
weiteres Kriterium, das mehr deckt als acht Zeilen (N-18). N-9 ist **zur Hälfte offen** (N-17), und
N-11 ist **nicht geschlossen, sondern verlagert** (N-14/N-15): Die Zeile hat die Seite gewechselt,
die Beleglücke ist dieselbe geblieben und eine zweite dazugekommen.

**Die Antwort auf die gestellte Kernfrage:** Die Analogie trägt **nicht**. `MR-039` Setzung 1 und
die Append-only-Klausel ziehen ihre Grenze nicht nur an verschiedenen Achsen — sie geben für die
**bestehenden** Instanzen entgegengesetzte Anweisungen: Die Klausel lässt sie unberührt, `MR-039`
verlangt die Nacharbeit an 55 von 59. Die Gemeinsamkeit, die der Ausnahme-Absatz als Kern
ausgibt — *irgendeine* Teilmenge bleibt eingefroren —, ist so schwach, dass sie auch den Ausgang
*übernommen* aus Buchstabe a erfüllt; damit trennt sie die beiden Buchstaben nicht mehr.

Alle fünf MEDIUM liegen weiterhin in der **Begründungs- und Zuordnungs-Schicht**, nicht im Register
selbst: Die 25 Zeilen, ihre Zahlen und ihre Vollständigkeit sind unverändert tragfähig (einzige
Ausnahme ist der Zeitanker in `:120`, N-19), und kein Befund verlangt eine Änderung an einem
Artefakt außerhalb von `harness/migration.md`. Es ist **kein** neuer Gegenstand entstanden und
**kein** bestätigter Fix der Runden 1–3 wieder aufgerissen.

**Übergabe:** Findings gehen an den Implementer. Die **Finding-Klassen** gehen zusätzlich in die
Slice-Closure §7 und von dort in den Zähler des Beobachtungs-Registers — das ist **Planner**-Arbeit
([`AGENTS.md`](../../AGENTS.md) §3.10), nicht die dieses Laufs; vier der sieben Klassen stehen nach
dieser Runde bei zwei Vorgängen. Dieser Report ist ein **Lauf-Beleg** und wird über Läufe hinweg
nicht wieder gelesen. Er ersetzt keine Verifikation — DoD-/Spec-Konformität prüft der Verifier
separat (Modul 11; anderes Prüf-Artefakt, anderer Eingabe-Kontext).
