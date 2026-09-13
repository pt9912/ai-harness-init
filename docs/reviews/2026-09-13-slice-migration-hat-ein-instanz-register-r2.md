# Review-Report: slice-migration-hat-ein-instanz-register, Runde 2 — 2026-09-13

**Review-Art:** Code-Review — die beiden Nacharbeits-Commits gegen den Slice-Plan, gegen die sechs
Sprung-ADRs und gegen die Befunde der Runde 1. Kein Plan-Review, keine Verifikation (DoD-Abhakung
ist Verifier-Arbeit, Modul 11).

**Gegenstand:** `6fedb06b` (+85/−20, `harness/migration.md`) und `d2f1c11d` (+27/−0, dieselbe
Datei). Arbeitsbaum leer; `d2f1c11d` ist `HEAD` und liegt **zwei Commits vor** `origin/main`
(`origin/main` == `6fedb06b`).

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
> des Laufs und darf ihn festhalten (`v6.7.2` ·
> `regelwerk/modul-02-harness-bootstrap.md` §Freshness-Audit der vendored Baseline (Schritt 2) —
> diese Zeile ist selbst ein Beispiel der Form).

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde — ohne diese Liste ist der Lauf nicht
reproduzierbar):

- Slice-Plan `slice-migration-hat-ein-instanz-register`, gelesen an seinem Lifecycle-Stand
  `in-progress/` — §1 *Ziel und Abgrenzung* samt der sechs Out-of-Scope-Punkte und §2 DoD
- die sechs Sprung-ADRs, jede im Volltext ihrer §Entscheidung:
  [ADR-0018](../plan/adr/0018-ziel-fassung-regiert-die-migration.md) (`Accepted`, Festlegung 4 im
  Wortlaut),
  [ADR-0031](../plan/adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) (**`Proposed`**),
  [ADR-0036](../plan/adr/0036-ziel-fassung-regiert-den-sprung-v600.md) (`Accepted`),
  [ADR-0038](../plan/adr/0038-ziel-fassung-regiert-den-sprung-v650.md) (`Accepted`),
  [ADR-0043](../plan/adr/0043-ziel-fassung-regiert-den-sprung-v671.md) (`Accepted`, Festlegung 2
  im Wortlaut),
  [ADR-0044](../plan/adr/0044-ziel-fassung-regiert-den-sprung-v672.md) (`Accepted`)
- [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
- [`AGENTS.md`](../../AGENTS.md) §3 (Hard Rules), namentlich §3.4, §3.6, §3.7, §3.8, §3.9, §3.10
- [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert),
  [`MR-030`](../../harness/conventions.md#mr-030--der-rollen-name-der-baseline-und-der-bezeichner-fallen-zusammen),
  [`MR-033`](../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist),
  [`MR-039`](../../harness/conventions.md#mr-039--ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines),
  [`MR-040`](../../harness/conventions.md#mr-040--drei-ausgänge-für-eine-präsens-aussage-über-den-vendored-baum),
  [`MR-045`](../../harness/conventions.md#mr-045--der-adaptions-block-läuft-in-der-verzeichnis-form),
  [`MR-058`](../../harness/conventions.md#mr-058--eine-messung-die-ihr-eigener-vorgang-bewegt-wird-nach-dem-vorgang-genommen)
  — jeder im Volltext seiner Datei, nicht über die Index-Zeile
- `v6.7.2` · `regelwerk/modul-02-harness-bootstrap.md` §Freshness-Audit der vendored Baseline
  (Schritt 2) **und** §Anmerkung zum Instanziierungs-Zeitpunkt (Schritt 2) — beide selbst gelesen,
  nicht über die Wiedergabe im Prüfgegenstand
- `v6.7.2` · `regelwerk/modul-06-roadmap.md` §Das Beobachtungs-Register · `v6.7.2` ·
  `regelwerk/grundlagen-begriffe.md` (Artefakt-Tabelle, Zeile `harness/sensors/<target>.md`)
- vorherige Findings am gleichen Gegenstand: der Report der **Runde 1**
  ([2026-09-13-slice-migration-hat-ein-instanz-register.md](2026-09-13-slice-migration-hat-ein-instanz-register.md),
  Commit `93c54d1b`) und der Verifikations-Report
  ([…-verify.md](2026-09-13-slice-migration-hat-ein-instanz-register-verify.md), Commit
  `fe401bc7`) — letzterer als **Kontext**, nicht als übernommene Einschätzung

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
| N-1 | **MEDIUM** | Die Sechs-Menge ist aus der zitierten Klausel nicht eindeutig ableitbar: Diese nennt **fünf Klassen** (ADR, Slice, Welle, Carveout, Review-Report), und §4 dehnt *Welle* auf zwei Zeilen aus, *Slice* und *Welle* aber nicht auf ihre Archiv-Stubs — obwohl `archiv-stub-slice.template.md` mit `# slice-<Kennung> — <Titel>` überschrieben ist und `archiv-stub-welle.template.md` mit `# <welle-id>`, beide also dieselben Artefakte in Stub-Form. Der Ausdehnungs-Schritt ist weder benannt noch einheitlich angewandt; ein zweiter Leser kommt auf fünf oder auf acht. | `v6.7.2` · `regelwerk/modul-02-harness-bootstrap.md` §Freshness-Audit der vendored Baseline (Schritt 2), Eigenschaft *Der Review vergleicht auch die Form* · [ADR-0018](../plan/adr/0018-ziel-fassung-regiert-die-migration.md) Festlegung 4, erster Punkt (*„Sie wählt die Quelle, sie liest sie nicht vor"*) · Auflage des Auftraggebers (§1 des Slice-Plans) | `harness/migration.md:139-155` (Ableitung), `:111-112` (die zwei Stub-Zeilen) | **nein** — kein Modul der [`.d-check.yml`](../../.d-check.yml) hält eine Klassen-Zuordnung gegen ihre Quelle | Ableitungs-Schritt einer Mengen-Zuordnung unmarkiert und uneinheitlich angewandt |
| N-2 | **MEDIUM** | Die neue §6-Frage zur `observation.template.md` zitiert *„unveränderlich ab Anlage"* / *„unveränderlich ab Merge"* und wertet sie als nicht entscheidend — setzt die Zeile dann aber per Default unter Buchstabe a, dessen erster Ausgang *übernommen* genau das Einarbeiten der neuen Fassung **in die bestehenden 104 Instanzen** verlangt. Die zitierte Regel schließt diesen Ausgang aus; rückwirkende Form-Anwendung *ist* eine Änderung an der Instanz. | `v6.7.2` · `regelwerk/modul-06-roadmap.md` §Das Beobachtungs-Register, *Form — drei Dateien, drei Lebensdauern* · [`AGENTS.md`](../../AGENTS.md) §3.6 | `harness/migration.md:227-235` (Frage), `:177` (Ausgang *übernommen*) | **nein** — kein Sensor hält einen Ausgang gegen die Mutabilität seiner Instanzen | Zitierte Regel schließt den Default aus, den der Eintrag dann setzt |
| N-3 | **MEDIUM** | Alle drei neuen §6-Einträge enden mit *„Bleibt unten unter Buchstabe a, bis das entschieden ist"*, während §5 Buchstabe a seine Vier-Menge unqualifiziert als *„eine geschlossene Menge, kein Freitext"* ausspricht und keinen Vorbehalt auf die drei Zeilen trägt. Wer §5 als Formvorgabe liest — und dafür ist der Abschnitt da —, bekommt eine bindende Anweisung für **178** Instanzen, deren Richtigkeit das Dokument an anderer Stelle bestreitet. | [`AGENTS.md`](../../AGENTS.md) §3.6 · Auflage des Auftraggebers (§1 des Slice-Plans: *„steht als offene Frage drin statt als Regel"*) | `harness/migration.md:172-173` (unqualifizierte Zusage), `:234-235`, `:246`, `:252-253` (die drei Defaults) | **nein** — kein Modul der [`.d-check.yml`](../../.d-check.yml) hält eine Zusage gegen einen Vorbehalt in einem anderen Abschnitt | Offene Frage trägt einen bindenden Default in eine geschlossene Menge |
| N-4 | **MEDIUM** | Die neue §6-Frage zur `MR-NNN-titel.template.md` erklärt für offen, *„ob eine geänderte Template-Form rückwirkend auf bestehende `MR-<NNN>.md` angewendet würde"*, und belegt das aus der Baseline. Die Beleg-Suche endet dort: [`MR-039`](../../harness/conventions.md#mr-039--ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines) Setzung 1 führt als Geltungsbereich wörtlich *„die **Form** eines Eintrags dieses Blocks, wenn ein adoptierter Baseline-Stand ein neues Pflichtfeld einführt"* und antwortet — jeder Eintrag mit vollem Rumpf bekommt es, retirierte nicht. Der Satz steht auch im Index. | [`MR-039`](../../harness/conventions.md#mr-039--ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines) Setzung 1 und 2 · [`harness/conventions.md`](../../harness/conventions.md) §Adaptions-Block (*„ein nachgetragenes Pflichtfeld tritt hinzu statt zu ersetzen"*) | `harness/migration.md:236-246` | **nein** — kein Sensor prüft, ob eine als offen erklärte Frage anderswo im Repo beantwortet ist | Beleg-Suche endet an der Baseline und übergeht die eigene Norm-Schicht |
| N-5 | **MEDIUM** | Die Zeile bucht **378** Instanzen; am geprüften Stand sind es **379**. Der Betrag war schon bei `d2f1c11d` falsch, weil der Verifikations-Report `fe401bc7` ihm vorausging — der Commit, der die Zeile bewusst stehen ließ, veröffentlichte einen Betrag, den ein früherer Commit derselben Kette bereits falsch gemacht hatte. Der Zusatz *„kein Erwartungswert"* ist genau der, den [`MR-058`](../../harness/conventions.md#mr-058--eine-messung-die-ihr-eigener-vorgang-bewegt-wird-nach-dem-vorgang-genommen) Setzung 3 für diesen Fall ausschließt, und er steht neben einem Zeiger auf ebendiesen Eintrag. | [`MR-058`](../../harness/conventions.md#mr-058--eine-messung-die-ihr-eigener-vorgang-bewegt-wird-nach-dem-vorgang-genommen) Setzung 2 und 3 (*„der Zusatz machte aus einem falschen Betrag einen falschen Betrag mit Disclaimer"*) | `harness/migration.md:120` | **ja** — `ls docs/reviews/*.md \| wc -l` gegen den Betrag in der Zeile; kein `make`-Ziel fährt das | Messung vor dem Vorgang genommen, den sie selbst bewegt |
| N-6 | **LOW** | §3 schreibt *„Fällt einer dennoch aus, wächst die Basis weiter, und die Kosten wachsen mit — **wörtlich** aus der Quelle"*. Die Quelle schreibt *„Fällt **auch dieser** aus …"*; der Satz ist paraphrasiert, und er steht — anders als jedes andere Zitat der Datei — ohne die `*„…"*`-Auszeichnung. Die Prohibition selbst ist korrekt wiedergegeben (Runde-1-Befund F-3 ist in der Sache behoben). | [ADR-0043](../plan/adr/0043-ziel-fassung-regiert-den-sprung-v671.md) Festlegung 2, §Was Festlegung 2 nicht tut | `harness/migration.md:87-89` | **nein** — `check-lines` prüft ausgezeichnete Zitate, keine Verbatim-Behauptung in Prosa | Verbatim-Zusage über eine paraphrasierte Stelle |
| N-7 | **INFO** | Die Rollen-Bezeichnung *„Rolle Implementation"* in `d2f1c11d` ist **kein** Einzelfall und keine Abweichung vom Repo: beide Formen laufen parallel und im selben Zeitraum — **79** gegen **86** Commits, alle seit dem 2026-08-28. Ein Konventions-Anker für das Token der Commit-Message existiert nicht; [`MR-030`](../../harness/conventions.md#mr-030--der-rollen-name-der-baseline-und-der-bezeichner-fallen-zusammen) bindet ausdrücklich nur [`MR-021`](../../harness/conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben) Punkt 2 und [`spec/spezifikation.md`](../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5, [`AGENTS.md`](../../AGENTS.md) §3.8/§3.10 verlangen nur, *dass* die Rolle genannt wird. **Kein LOW-Finding** — der Befund gehört als Konventions-Lücke an den Architect. | [`MR-030`](../../harness/conventions.md#mr-030--der-rollen-name-der-baseline-und-der-bezeichner-fallen-zusammen) §Geltungsbereich · Reviewer-Skill §Was dieser Skill NICHT macht (*„Kein Stil-Polizist … ohne Konventions-Anker"*) | Commit-Message `d2f1c11d`, Zeile 1 | **ja, in einer Richtung** — `git log --format='%s' \| grep -oE '^Rolle [A-Za-zä]+' \| sort \| uniq -c`; kein Gate liest Commit-Messages auf dieses Token | Bezeichner-Form ohne Konventions-Anker |
| N-8 | **INFO** | §1 *Ziel* des Slice-Plans sagt weiterhin *„eine **Report-Form** für `docs/migrations/<tag>.md` mit vier Ausgängen je Vorlage"*; geliefert sind vier **plus einer**. Der Plan ist korrekt unangetastet geblieben (beide Commits berühren nur `harness/migration.md`), ein Übergabe-Artefakt an den Planner benennt die Plan-Hälfte der Divergenz aber nicht. Die DoD-Hälfte liegt beim Verifier und ist von ihm bereits an den Planner gerichtet. | `v6.7.2` · `regelwerk/modul-08-agentenrollen.md` §Konflikt-Pfad als Rollen-Sequenz (*„Kein Pfeil ohne benennbares Artefakt"*) · [`AGENTS.md`](../../AGENTS.md) §3.10 | `docs/plan/planning/in-progress/slice-migration-hat-ein-instanz-register.md` §1 *Ziel* | **nein** | Plan-Ziel und Lieferung auseinander, ohne Übergabe-Artefakt |

### Belege zu N-1, N-3 und N-5

```sh
# N-1 — die Klausel nennt fünf Klassen; die zweite Fundstelle derselben Quelle ebenfalls fünf
sed -n '281,284p' .harness/baseline/v6.7.2/regelwerk/modul-02-harness-bootstrap.md   # ADR, Slice, Welle, Carveout, Review-Report
sed -n '174,175p' .harness/baseline/v6.7.2/regelwerk/modul-02-harness-bootstrap.md   # slice, welle, NNNN-*, carveout, review-report
head -1 .harness/baseline/v6.7.2/templates/docs/plan/planning/archiv-stub-slice.template.md  # "# slice-<Kennung> — <Titel>"
head -1 .harness/baseline/v6.7.2/templates/docs/plan/planning/archiv-stub-welle.template.md  # "# <welle-id> — <Titel>"
grep -cE '^archive-welle:' Makefile                                                          # 1

# N-3 — Summe der Instanzen der drei per Default nach Buchstabe a gesetzten Zeilen
find docs/plan/planning/observations -mindepth 2 -maxdepth 2 -type d | wc -l   # 104
{ ls harness/conventions/*.md; ls harness/conventions/done/*.md; } | wc -l     #  59
ls harness/sensors/*.md | wc -l                                               #  15   -> 178

# N-5 — der Betrag war schon am eigenen Commit falsch
git ls-tree -r --name-only fe401bc7 docs/reviews/ | grep -c '\.md$'            # 379  (Verify-Report)
git ls-tree -r --name-only d2f1c11d docs/reviews/ | grep -c '\.md$'            # 379  (der Commit, der 378 stehen ließ)
ls docs/reviews/*.md | wc -l                                                   # 379  (Stand dieses Laufs)

# N-7 — beide Rollen-Formen laufen parallel
git log --format='%s' | grep -oE '^Rolle [A-Za-zä]+' | sort | uniq -c | sort -rn
git log --since=2026-08-28 --format='%s' | grep -c '^Rolle Implementation'      #  79
```

**Keine Erwartungswerte** — alle Beträge wandern mit dem Baum. Die `379` aus N-5 wandert
ausdrücklich auch durch **diesen** Report: sein Commit macht sie zu `380`. Genau das ist der
Grund, warum [`MR-058`](../../harness/conventions.md#mr-058--eine-messung-die-ihr-eigener-vorgang-bewegt-wird-nach-dem-vorgang-genommen)
Setzung 2 für diesen Fall nicht die Zahl, sondern *„die Eigenschaft, die tragen soll"* verlangt;
der Befund ist damit ein **Formulierungs**-Problem einer einzelnen, selbstbezüglichen Zeile und
kein struktureller Regress des Registers.

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| **Instanz-Register, Vollständigkeit — erneut als Bijektion, nicht als Stichprobe**: die 25 `Vorlage`-Zellen gegen `find .harness/baseline/v6.7.2/templates -name '*.template.md'`, beide sortiert und `diff`-verglichen | geprüft, ohne Befund — **25/25 identisch**, keine Vorlage ohne Zeile, keine Zeile ohne Vorlage, keine Dublette. Unverändert gegenüber Runde 1 |
| **Alle 25 Register-Zeilen einzeln nachvollzogen** — jedes der 13 Beleg-Kommandos neu gefahren (ADR **46**, Carveout **6**, Observation **104**, Slice **229**, welle-results **12**, welle **3**+**12**=**15**, Review **379**, `MR` **55**+**4**=**59**, Sensor **15**, Skills **1**, Reconciliation Exit **2**, Archiv `.zip` **0**, Vorlagen gesamt **25**) | geprüft — **24 von 25 Zeilen stimmen mit der Ausgabe ihres eigenen Kommandos überein**; die einzige Abweichung ist die Review-Report-Zeile (N-5). Die Runde-1-Verifikation der übrigen ist damit **nicht** invalidiert, sondern in diesem Lauf unabhängig **neu bestätigt** — nicht fortgeschrieben |
| **Die vier `keine Instanz`-Begründungen, erneut einzeln nachgefahren** | geprüft, ohne Befund — (1)+(2) Archiv-Stubs: `git ls-files 'docs/plan/planning/done/**/*.zip'` leer, kein `done/<welle-id>/`-Unterverzeichnis; (3) `reconciliation.md` fehlt (Exit 2); (4) `ls .harness/skills/*.md` → **1**. Die **Begründungen** tragen weiterhin; dass die ersten beiden Zeilen daneben eine Klassifikations-Frage aufwerfen, ist N-1 und kein Beleg-Befund |
| **HIGH F-1 aus Runde 1 — die sechs wiederkehrenden Zeilen** | geprüft — **für diese sechs geschlossen**. §5 trägt jetzt zwei disjunkte Fälle, Buchstabe b nennt den Ausgang *append-only* mit Bedingung und Beleg-Art, und §5 sagt ausdrücklich, dass b *„keine fünfte Ergänzung dieser Menge"* ist. Das zitierte Klausel-Fragment ist gegen `v6.7.2` · `regelwerk/modul-02-harness-bootstrap.md` **byte-gleich** gehalten und in [ADR-0018](../plan/adr/0018-ziel-fassung-regiert-die-migration.md) Festlegung 4, dritter Punkt, tatsächlich wörtlich zitiert. Der Rest von F-1 lebt in N-1 bis N-3 fort |
| **Das Ellipsen-Argument in §4** (*„nennt die Menge ohne Fortsetzungspunkte — anders als die Singleton-Aufzählung direkt davor"*) | geprüft, ohne Befund am Sachgehalt — die Singleton-Aufzählung derselben Quelle endet auf `Lastenheft, …`, die wiederkehrende auf `Review-Report)` ohne Fortsetzungspunkte. Die **Folgerung** *„und damit abschließend"* ist eine Inferenz des Dokuments, keine Aussage der Quelle; dass sie nicht als solche markiert ist, trägt N-1. Gegen die Folgerung spricht daneben, dass `observation.template.md` **104** Instanzen erzeugt und in **keiner** der beiden Aufzählungen steht |
| **Die zwei vom Implementer verworfenen Baseline-Zitate — unabhängig nachgelesen, nicht nachvollzogen** | geprüft — **Einschätzung geteilt, mit einer Einschränkung.** `grundlagen-begriffe.md` (*„kein Lifecycle-Verzeichnis, ein retiriertes Gate verschwindet"*) spricht über den Lebenszyklus der Sensor-Datei und entscheidet die Form-Frage nicht — geteilt; sie stützt Buchstabe a sogar, und der Eintrag sagt das selbst. `modul-02` (*„Rückbau ist ein neuer Eintrag, kein Edit"* + *„Append-only-Disziplin wie bei ADRs"*) betrifft die Auflösung eines Eintrags, nicht die Form-Migration — geteilt. **Nicht geteilt** wird, dass die Frage damit unbeantwortet ist: N-4 nennt die Stelle im eigenen Repo, die sie beantwortet |
| **Der dritte §6-Eintrag (`gate.template.md`)** | geprüft, ohne Befund — die Frage ist als Frage gestellt, das Zitat ist verbatim und korrekt eingeordnet, und der Default nach Buchstabe a steht hier nicht gegen die zitierte Quelle (anders als bei der Observation-Zeile, N-2): eine Sensor-Datei ohne Bestandsschutz kann eine neue Form tatsächlich übernehmen. Der Eintrag fällt allein unter die allgemeine Default-Kritik N-3 |
| **Verortung aller 25 Zeilen in §5 (a) / §5 (b) / §6** | geprüft — **lückenlos und disjunkt**: 6 Zeilen in Buchstabe b, 19 in Buchstabe a, davon 3 mit §6-Vorbehalt; 6+19 = 25. Eine vierte, unbenannte Lage gibt es **nicht**. Der Befund liegt nicht in der Vollständigkeit der Verortung, sondern in zwei Zuordnungen innerhalb von a (N-1) und im Rang des Vorbehalts (N-2, N-3) |
| **Behobene Runde-1-Befunde F-2, F-3, F-5, F-6, F-8, F-9, F-10, F-11 — jeder einzeln am neuen Text gegengelesen** | geprüft, ohne Befund — F-2: ADR-0031 trägt an **beiden** Zitierstellen (§1 und §2) den `Proposed`-Vermerk, Statuszeile der ADR gegengeprüft. F-3: Prohibition wiederhergestellt (Rest-Befund N-6 betrifft nur die Verbatim-Behauptung). F-5: beide Präsens-Aussagen tragen jetzt `v6.7.2` · `regelwerk/…`. F-6: Beleg-Zeiger auf §Entscheidung Festlegung 4 korrigiert und dort tatsächlich gefunden; der Zusatz über §Kontext stimmt. F-8: Vorspann und Tabellenzeile widersprechen sich nicht mehr. F-9: der wirkungslose Marker ist entfernt, die zwei verbliebenen stehen zeilengleich mit ihrem Inline-Code-Pfad. F-10: Beleg-Art nennt kein Werkzeug mehr, das den Beleg nicht liefern kann. F-11: §5 trägt jetzt dieselbe Nicht-ADR-Marke wie §4 |
| **Offen gebliebene Runde-1-INFOs F-12 und F-13** | geprüft — **unverändert, weiterhin INFO**. §3 nennt [ADR-0044](../plan/adr/0044-ziel-fassung-regiert-den-sprung-v672.md) Festlegung 2 weiter *„unverändert angewendet"*, ohne deren Selbstbeschreibung als *Anwendung mit Zusatz* aufzunehmen; *„kein Ziel für einen siebten Sprung ist gesetzt"* steht weiter ohne Kommando. Beide blockierten schon in Runde 1 nicht und werden hier nicht neu gezählt |
| **F-7 aus Runde 1 (Commit-Message `f0d58786`)** | geprüft — nach dem Push unveränderlich, keine Nacharbeit möglich und keine versucht. Die zwei neuen Messages nennen keine Zahl als Beleg des Gelieferten; [`MR-051`](../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung) Setzung 1 ist in beiden **nicht** verletzt |
| **Out-of-Scope-Treue gegen §1 des Slice-Plans, alle sechs Punkte, an beiden neuen Commits** | geprüft, ohne Befund — `git show --pretty=format: --name-only` gibt für **beide** Commits genau `harness/migration.md`. Kein Durchgang gegen einen siebten Tag, kein `docs/migrations/`-Report (das Verzeichnis existiert nicht), kein rückwirkender Report, keine ADR, kein `MR`-Eintrag, kein Sensor und kein `.d-check.yml`-Modul, keine Änderung an [`harness/conventions.md`](../../harness/conventions.md) §Baseline, kein Produkt-Code. Kein Übergriff |
| **[`AGENTS.md`](../../AGENTS.md) §3.8 — schreibt eine der Nacharbeiten eine neue Norm?** | geprüft, ohne Befund — weder [`AGENTS.md`](../../AGENTS.md) noch [`harness/conventions.md`](../../harness/conventions.md) noch `harness/conventions/` noch `docs/plan/adr/` sind berührt. §5 Buchstabe b ist eine Formvorgabe **für einen künftigen Bericht** innerhalb eines ausdrücklich als Nicht-ADR deklarierten Dokuments; §3.8 spricht über andere Norm-Artefakte ausdrücklich nicht, und keine Quelle weist `harness/migration.md` einer schreibenden Rolle zu. Die inhaltliche Deckungs-Frage trägt N-1, nicht §3.8 |
| **[`AGENTS.md`](../../AGENTS.md) §3.10 — der ausführende Lauf schreibt sein eigenes Abnahmekriterium nicht um** | geprüft, ohne Befund — und das ist der stärkste Punkt beider Nacharbeiten: Der Implementer hat DoD-Punkt (2) **nicht** an die gelieferte Zwei-Fall-Struktur angepasst, obwohl das die bequeme Reaktion gewesen wäre. Die DoD-Häkchen stehen unverändert auf `- [ ]`, §6 und §7 des Plans sind unberührt, kein `git mv`, `docs/plan/planning/observations/` unberührt. Die daraus folgende Plan-Divergenz ist N-8 |
| **[`AGENTS.md`](../../AGENTS.md) §3.7 — Kommentar- und Zustandsfeld-Regel am neuen Text** | geprüft, ohne Befund — die **112** neuen Zeilen tragen keine Befund-Kennung, keine Slice-Nummer als Erzählung und kein Lauf-Protokoll. Die §6-Einträge beschreiben durchweg den **Zustand** der Frage im Indikativ (*„misst dieses Dokument nicht"*), nicht den Vorgang, der sie aufwarf; der Verifikations-Report, der sie auslöste, wird an keiner Stelle im Text genannt — korrekt, er löste nach `docs/reviews/**` auf und steht in keinem Rang |
| **[`AGENTS.md`](../../AGENTS.md) §3.1 / [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)** | geprüft, ohne Befund — der neue Text behauptet **kein** Target. `make archive-welle` bleibt die einzige Target-Nennung der Datei, existiert im `Makefile` (Zeile 364) und steht in `harness/README.md` §Werkzeuge als *kein Gate*. `harness/README.md` ist von beiden Commits nicht berührt |
| **Verweis-Integrität nach beiden Nacharbeiten** | geprüft, ohne Befund — **18/18** verschiedene Link-Ziele lösen vom Ruheort `harness/` aus auf; die drei `conventions.md`-Anker (`mr-025`, `mr-033`, `mr-058`) sind je genau einmal als `id="…"` in [`harness/conventions.md`](../../harness/conventions.md) belegt; der interne Anker `#6-offene-fragen` deckt sich mit der Überschrift `## 6. Offene Fragen` (Zeile 217) |
| **[`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) / [`MR-033`](../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist) über den neuen Text** | geprüft, ohne Befund über die **Form** — jede Zahl der drei neuen §6-Einträge steht neben ihrem Kommando und trägt *kein Erwartungswert*; die Kommandos sind in diesem Lauf gefahren und liefern **104**, **59**, **15**. Jede Baseline-Aussage der neuen Zeilen trägt `v6.7.2` als Mess-Tag. Der einzige Zahl-Befund ist N-5, und er betrifft den **Zeitpunkt**, nicht die Form |
| **§6-Kommando *„zwischen 0 und 16 Mal"*** | geprüft, ohne Befund — `for f in 0018 0031 0036 0038 0043 0044; do grep -c templates docs/plan/adr/$f-*.md; done` → `9 0 0 7 12 16`; Minimum **0**, Maximum **16**, die Spanne im Text stimmt |
| **§3-Kommando zur Delta-Basis** | geprüft, ohne Befund — die letzte Zeile mit gefülltem Nachweis-Feld ist `**auf `v6.7.2`:** 2026-09-12, Delta-Nachweis in slice-224`; die Aussage *„Für einen siebten Sprung wäre `v6.7.2` damit die Basis"* trägt |
| **Commit-Hygiene beider neuer Commits** | geprüft, ohne Befund — keine Attributions-Zeile (kein `Co-Authored-By`, kein `Generated-with`), Traceability in beiden erfüllt (`ADR-0018`, `LH-QA-01`), Rolle in beiden genannt. Die Rollen-**Schreibweise** in `d2f1c11d` ist N-7 und kein Hygiene-Befund |

### Ausdrücklich **nicht** geprüft

| Bereich | Grund |
|---|---|
| `make gates`, `make docs-check`, `make mutate`, jedes Docker-Ziel | [`AGENTS.md`](../../AGENTS.md) §3.9 und ausdrückliche Auflage des Auftraggebers — er fährt sie. Alle Aussagen dieses Reports über Gate-Verhalten sind **Lesungen der Konfiguration**, kein Lauf |
| DoD-Abhakung, Risiko-Ausgänge §6 des Plans, Closure-Notiz §7 | Verifier- bzw. Planner-Arbeit (`v6.7.2` · `regelwerk/modul-11-verification.md`; [`AGENTS.md`](../../AGENTS.md) §3.10). Der Verifikations-Report liegt vor; dieser Lauf hat ihn als **Kontext** gelesen und keine seiner Einschätzungen übernommen — die Gegenprobe zu seinem *„Befund: keiner"* steht als N-5 |
| Ob [`MR-039`](../../harness/conventions.md#mr-039--ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines) Setzung 1 nach dem Umzug in die Verzeichnis-Form fortgilt | [`MR-045`](../../harness/conventions.md#mr-045--der-adaptions-block-läuft-in-der-verzeichnis-form) hält fest, dass ihr Auflösungs-Trigger eingetreten und ihre Re-Evaluierung *„ein eigener Vorgang"* ist; der Eintrag steht weiter in der **aktiven** Tabelle. N-5 hängt daran nicht — N-4 sagt, dass die Frage im Repo **behandelt** ist, nicht, wie sie ausgeht. Die Re-Evaluierung ist Architect-Arbeit |
| Die sechs Sprung-ADRs **als Entscheidungen** | Gegenstand ist ihre Wiedergabe, nicht ihre Güte. Fünf sind `Accepted` und nach [`AGENTS.md`](../../AGENTS.md) §3.4 eingefroren; ADR-0031 hat ihre eigene Konsistenzrunde |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 5 |
| LOW | 1 |
| INFO | 2 |

**Finding-Klassen dieses Laufs:** Ableitungs-Schritt einer Mengen-Zuordnung unmarkiert und
uneinheitlich angewandt · Zitierte Regel schließt den Default aus, den der Eintrag dann setzt ·
Offene Frage trägt einen bindenden Default in eine geschlossene Menge · Beleg-Suche endet an der
Baseline und übergeht die eigene Norm-Schicht · Messung vor dem Vorgang genommen, den sie selbst
bewegt · Verbatim-Zusage über eine paraphrasierte Stelle · Bezeichner-Form ohne Konventions-Anker
· Plan-Ziel und Lieferung auseinander, ohne Übergabe-Artefakt

**Hinweis an die Slice-Closure, nicht an den Implementer:** Die Klasse *Messung vor dem Vorgang
genommen, den sie selbst bewegt* trägt hier **denselben Namen wie F-4 aus Runde 1** — das ist
Absicht und nicht Kopie: derselbe Fundort, derselbe Vorgang, also **eine** Gelegenheit und **ein**
Beleg, nicht zwei (`v6.7.2` · `regelwerk/modul-06-roadmap.md` §Das Beobachtungs-Register,
*Ein Vorgang zählt einmal*). Ob dieser Slice der Beleg ist und welcher Ausgang folgt, entscheidet
der Lese-Schritt — Planner-Arbeit.

## Verdikt

**Merge-blockierend: ja** — aber auf einer Stufe tiefer als in Runde 1: **kein HIGH mehr.**

**Was F-1 betrifft, ist zur größeren Hälfte erledigt.** Für die sechs wiederkehrenden Zeilen ist
die Lücke geschlossen, sauber als eigener, disjunkter Fall statt als fünfter Eintrag in der
Vier-Menge, und die tragende Baseline-Klausel ist byte-gleich und mit korrektem ADR-Beleg zitiert.
Das war der blockierende Teil, und er trägt.

**Was blockiert, sind drei Reste desselben Befundes.** Die *Ableitung* der Sechs-Menge ist nicht
reproduzierbar (N-1): Die Quelle nennt fünf Klassen, das Dokument dehnt *Welle* auf zwei Zeilen
aus und *Slice*/*Welle* nicht auf ihre Archiv-Stubs, ohne den unterscheidenden Grundsatz zu
nennen. **Die Antwort auf die gestellte Frage lautet damit: die Doppelzählung der Welle-Familie
ist in der Sache vertretbar — `welle-results.md` entsteht je Welle und ist ein Welle-Artefakt —,
aus dem Wortlaut allein aber nicht ableitbar.** Sie ist eine Inferenz, und weil dieselbe Inferenz
zwei Zeilen weiter unterbleibt, ist sie eine **selektive**. Heute ist das folgenlos, weil beide
Stub-Zeilen *keine Instanz* tragen; `make archive-welle` ist verdrahtet, und mit der ersten
Archivierung wird aus der Klassifikations-Frage genau die Ausgangs-Lücke, die F-1 war.

**Die drei neuen §6-Einträge sind echte Fragen — aber sie tragen eine Antwort im Schlusssatz.**
*„Bleibt unten unter Buchstabe a, bis das entschieden ist"* ist eine Zuweisung in eine Menge, die
§5 unqualifiziert als geschlossen ausspricht (N-3). Für die Observation-Zeile steht diese
Zuweisung gegen die Regel, die der Eintrag selbst zitiert: 104 ab Anlage unveränderliche Instanzen
können den Ausgang *übernommen* nicht tragen (N-2). Das ist F-1 für eine Zeile statt für neun —
kleiner, benannt statt still, und deshalb MEDIUM statt HIGH; ungelöst ist es trotzdem.

**Zur Beleg-Prüfung des Implementers:** Seine Einschätzung zu den zwei verworfenen Zitaten wird
nach eigener Lektüre **geteilt** — beide entscheiden die Form-Frage nicht. Nicht geteilt wird die
Schlussfolgerung für die `MR`-Zeile: [`MR-039`](../../harness/conventions.md#mr-039--ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines)
Setzung 1 führt als Geltungsbereich wörtlich die Frage, die §6 für offen erklärt, und
[`harness/conventions.md`](../../harness/conventions.md) §Adaptions-Block wiederholt die Antwort
im Index (N-4). Die Suche endete an der Baseline; die eigene Norm-Schicht des Repos stand nicht im
Prüfbereich.

**Zum `MR-058`-Punkt wird die Einschätzung des Verifiers nicht geteilt** (N-5). Sein *„Befund:
keiner"* stimmte für den Stand, an dem er ihn schrieb. Sein eigener Commit `fe401bc7` hat die
Bezugsmenge dann auf **379** gehoben — und `d2f1c11d`, der die Zeile bewusst stehen ließ, hat
`378` danach erneut veröffentlicht. Der Betrag ist nicht *später* falsch geworden, er war am
eigenen Commit falsch, und die Parenthese *„Stand nach dem Review-Report zu diesem Register"*
benennt einen Zustand, den es nicht gab. Der Zusatz *kein Erwartungswert* heilt das nicht —
[`MR-058`](../../harness/conventions.md#mr-058--eine-messung-die-ihr-eigener-vorgang-bewegt-wird-nach-dem-vorgang-genommen)
Setzung 3 schließt ihn für genau diesen Fall aus. **Und nein, es ist nicht strukturell
unvermeidlich:** Setzung 2 nennt den Ausweg im selben Satz — steht die Zahl nicht,
*„steht an ihrer Stelle die Eigenschaft, die tragen soll"*. Ein Formulierungs-Problem einer
einzigen selbstbezüglichen Zeile, nicht ein Regress des Registers.

**Die Rollen-Bezeichnung ist weder LOW noch Bagatelle, sondern ein zurückgewiesener Befund**
(N-7): *„Rolle Implementation"* steht in **79** Commits, *„Rolle Implementer"* in **86**, alle im
selben Zeitraum seit dem 2026-08-28. Die Prämisse *„inkonsistent mit dem Rest des Repos"* hält der
Messung nicht stand — inkonsistent ist das Repo mit sich selbst, und kein Konventions-Anker bindet
das Token einer Commit-Message. Als Finding gegen `d2f1c11d` wäre es Stil-Polizei; als
Konventions-Lücke gehört es an den Architect.

**Was ausdrücklich trägt.** Das Instanz-Register bleibt die stärkste Hälfte: **25/25** in beide
Richtungen, **24 von 25** Beträgen in diesem Lauf unabhängig neu gemessen und bestätigt, alle vier
`keine Instanz`-Begründungen erneut standgehalten. Acht der elf Runde-1-Befunde sind sauber
behoben, keiner davon durch Weichschreiben. Und das Wichtigste: Der Implementer hat DoD-Punkt (2)
**nicht** an seine eigene Lieferung angepasst, obwohl der Widerspruch offen zutage lag — genau die
Selbstbeschränkung, die [`AGENTS.md`](../../AGENTS.md) §3.10 verlangt und die am leichtesten
unterlaufen worden wäre. Kein Out-of-Scope-Übergriff in beiden Commits, kein §3.8-Befund.

**Negativbefund-Pflicht — wie viel dieser Lauf wirklich neu gemessen hat:** **alle 25**
Register-Zeilen, nicht die neun/sechs plus drei. Jedes der 13 Beleg-Kommandos ist neu gefahren,
die Bijektion Vorlage ↔ Zeile neu gebildet, die vier `keine Instanz`-Begründungen neu geprüft. Die
Runde-1-Verifikation der nicht angefassten Zeilen ist dadurch **weder fortgeschrieben noch als
gültig unterstellt**, sondern ersetzt; invalidiert hat die Nacharbeit nichts davon — mit der einen
Ausnahme der Review-Report-Zeile, deren Betrag sich seit Runde 1 zweimal bewegt hat (377 → 378 →
379).

**Übergabe:** Findings gehen an den Implementer; N-8 und N-7 gehen an den Planner bzw. Architect
und nicht an ihn. Die **Finding-Klassen** gehen zusätzlich in die Slice-Closure §7 und von dort in
den Zähler — mit dem Vermerk oben, dass die Klasse aus N-5 mit F-4 der Runde 1 **einen** Vorgang
teilt und einmal zählt. Dieser Report ist ein **Lauf-Beleg** (Audit: dieser Diff, dieser Skill,
dieses Modell, dieses Verdikt) und wird über Läufe hinweg nicht wieder gelesen. Er ersetzt keine
Verifikation — DoD-/Spec-Konformität prüft der Verifier separat (Modul 11).
