# harness/migration.md — Instanz-Register und Report-Form für den nächsten Baseline-Sprung

## Zweck

Dieses Dokument leitet ab, es setzt nicht. Es hält zwei Dinge bereit: ein **Instanz-Register** —
je vendored Vorlage genau eine Zeile, welches Artefakt dieses Repos ihre Instanz ist, oder *keine
Instanz* mit Begründung — und die **Report-Form** für künftige `docs/migrations/<tag>.md`-Berichte <!-- d-check:ignore (geplante Ablage) -->
: vier Ausgänge für die **einmaligen** Vorlagen dieses Registers, eine Append-only-Antwort für die
**wiederkehrenden** (§5). Ein Report entsteht mit diesem Dokument nicht.

Jeder normative Punkt unten trägt die ADR, an der er belegt ist —
[ADR-0018](../docs/plan/adr/0018-ziel-fassung-regiert-die-migration.md),
[ADR-0031](../docs/plan/adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md),
[ADR-0036](../docs/plan/adr/0036-ziel-fassung-regiert-den-sprung-v600.md),
[ADR-0038](../docs/plan/adr/0038-ziel-fassung-regiert-den-sprung-v650.md),
[ADR-0043](../docs/plan/adr/0043-ziel-fassung-regiert-den-sprung-v671.md) und
[ADR-0044](../docs/plan/adr/0044-ziel-fassung-regiert-den-sprung-v672.md). Was sich dort nicht
belegen lässt, steht in [§6 Offene Fragen](#6-offene-fragen) — benannt, nicht als Regel getarnt. Das
Dokument ist keine ADR und ersetzt keine der sechs Entscheidungen; es zitiert sie.

## 1. Regierende Fassung eines Sprungs

**Kriterium** ([ADR-0018](../docs/plan/adr/0018-ziel-fassung-regiert-die-migration.md) Festlegung 3):
Vor jedem künftigen Sprung wird gemessen, ob die **gepinnte** Fassung die Migrations-Prozedur
(den Freshness-Audit-Abschnitt der Baseline) führt. Führt sie ihn nicht, regiert die Ziel-Fassung
ohne neue Abwägung. Führen beide ihn, ist die Wahl offen und wird in jenem Sprung begründet
entschieden — eine allgemeine Regel *„es regiert stets die Ziel-Fassung"* besteht ausdrücklich
nicht.

**Prozedur ≠ Ist-Maßstab**
([ADR-0018](../docs/plan/adr/0018-ziel-fassung-regiert-die-migration.md) Festlegung 2): Bis der
vendored Baum getauscht ist, bleibt die gepinnte Fassung für **jede Konformitäts-Frage**
maßgeblich, unabhängig davon, welche Fassung die Prozedur des laufenden Sprungs stellt.

**Bisherige Anwendungen** — jede Zeile ist eine für ihren Sprung geschlossene Entscheidung; nur
eine wird von der Zeile darunter teilweise abgelöst (`v6.5.0` → `v6.7.1`, siehe deren dritte
Spalte), alle anderen bleiben unangetastet:

| Sprung | Regierende Fassung | ADR |
|---|---|---|
| `v3.5.2` → `v5.12.0` | Ziel-Fassung `v5.12.0` | [ADR-0018](../docs/plan/adr/0018-ziel-fassung-regiert-die-migration.md) Festlegung 1 |
| `v5.12.0` → `v5.18.0` | Ziel-Fassung `v5.18.0` | [ADR-0031](../docs/plan/adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) Festlegung 1 |
| `v5.18.0` → `v6.0.0` | Ziel-Fassung `v6.0.0` | [ADR-0036](../docs/plan/adr/0036-ziel-fassung-regiert-den-sprung-v600.md) |
| `v6.0.0` → `v6.5.0` | Ziel-Fassung `v6.5.0` | [ADR-0038](../docs/plan/adr/0038-ziel-fassung-regiert-den-sprung-v650.md) |
| `v6.5.0` → `v6.7.1` (Ziel unerreichbar geworden, bevor ein Pin es trug) | Ziel-Fassung `v6.7.1` | [ADR-0043](../docs/plan/adr/0043-ziel-fassung-regiert-den-sprung-v671.md) Festlegung 1, teilweise abgelöst durch [ADR-0044](../docs/plan/adr/0044-ziel-fassung-regiert-den-sprung-v672.md) |
| `v6.5.0` → `v6.7.2` (vollzogen) | Ziel-Fassung `v6.7.2` | [ADR-0044](../docs/plan/adr/0044-ziel-fassung-regiert-den-sprung-v672.md) Festlegung 1 |
| `v6.7.2` → `v6.8.0` (vollzogen) | Ziel-Fassung `v6.8.0` | [ADR-0047](../docs/plan/adr/0047-ziel-fassung-regiert-den-sprung-v680.md) |
| `v6.8.0` → `v6.9.0` (Vollzug steht aus) | Ziel-Fassung `v6.9.0` | [ADR-0056](../docs/plan/adr/0056-ziel-fassung-regiert-den-sprung-v690.md) |

Die Zeile zu `v5.12.0` → `v5.18.0` zitiert
[ADR-0031](../docs/plan/adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) Festlegung 1;
die ADR steht auf **`Proposed`** (ihre eigene §Geschichte) und ist damit nach
[`AGENTS.md`](../AGENTS.md) §3.4 noch nicht eingefroren — die Zeile hält fest, was sie **heute**
vorschlägt, nicht, dass die Entscheidung feststeht. Für die Zeile zu `v6.8.0` → `v6.9.0` gilt
dieselbe Lesart: Auch [ADR-0056](../docs/plan/adr/0056-ziel-fassung-regiert-den-sprung-v690.md)
steht auf **`Proposed`**.

Der aktuell vendored Stand ist `v6.8.0`
(`ls -1 .harness/baseline/` — kein Erwartungswert, wandert mit jedem Tausch); die
Zwei-Fassungen-Phase des siebten Sprungs ist geschlossen. Der Zielstand steht auf `v6.9.0`
(§Baseline von [`conventions.md`](conventions.md)); der Tausch steht aus, und damit läuft die
Zwei-Fassungen-Phase des achten Sprungs.

## 2. Ort und Form der Zielstand-Setzung

[ADR-0031](../docs/plan/adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) steht auf
**`Proposed`** (ihre eigene §Geschichte) und ist damit nach [`AGENTS.md`](../AGENTS.md) §3.4 noch
nicht eingefroren; ihre eigene Konsistenzrunde ist offen. Was folgt, ist ihre **derzeit
vorgeschlagene** Festlegung 2, wiedergegeben als solche, nicht als eingefrorene Entscheidung:

Eine Zielstand-Setzung wird in [`harness/conventions.md`](conventions.md) §Baseline verbucht, in
der Re-Baseline-Aufzählung, mit einem geschlossenen Mindestumfang von **drei Teilen**, kein
vierter:

1. Ziel-Tag und Datum der Setzung bzw. ihres Vollzugs.
2. Der Slice, der den Delta-Nachweis führt, als Zeiger — der Nachweis selbst bleibt in jenem Slice.
3. Sonst nichts: kein Konformitäts-Urteil, keine Ausgangs-Liste, keine Begründung der Setzung.

Sie bekommt **keine eigene ADR**, keine Zeile in einer fremden §Geschichte und keinen zweiten
stehenden Ort. Wer den Zielstand bewegen darf, entscheidet diese Festlegung nicht — das bleibt
[ADR-0018](../docs/plan/adr/0018-ziel-fassung-regiert-die-migration.md) §Wer den Zielstand bewegt
vorbehalten (dem Auftraggeber).

## 3. Delta-Basis des Adaptions-Durchgangs

[ADR-0043](../docs/plan/adr/0043-ziel-fassung-regiert-den-sprung-v671.md) Festlegung 2, unverändert
angewendet durch
[ADR-0044](../docs/plan/adr/0044-ziel-fassung-regiert-den-sprung-v672.md) Festlegung 2: Die
Delta-Basis der fünf Ausgänge des Adaptions-Durchgangs und der Stichproben-Komplementärmenge ist
**nicht** der zuletzt vendorte Stand, sondern der letzte Stand, für den
[`harness/conventions.md`](conventions.md) §Baseline einen Slice mit **gefülltem**
Delta-Nachweis-Feld ausweist. Die Festlegung erlaubt **nicht**, einen Durchgang auszulassen:
*„Fällt auch dieser aus, wächst die Basis weiter, und die Kosten wachsen mit."* — wörtlich aus der
Quelle zitiert, nicht als Beschreibung abgeschwächt.

Gemessen am Stand dieses Dokuments trägt die letzte Zeile mit gefülltem Nachweis-Feld `v6.8.0`
(`grep -o '\*\*auf \`v[0-9.]*\`:\*\* [0-9-]*, Delta-Nachweis[^.;]*' harness/conventions.md` — die
Zeile mit `Delta-Nachweis in slice-sprung-auf-v680-wird-vollzogen`, kein Erwartungswert). Für einen
achten Sprung wäre `v6.8.0` damit die Basis, **solange** kein weiterer Durchgang zwischenzeitlich
läuft.

## 4. Instanz-Register

Je Vorlage unter `.harness/baseline/v6.8.0/templates/` genau eine Zeile
(`find .harness/baseline/v6.8.0/templates -name '*.template.md' | wc -l` → **25**, kein
Erwartungswert — die Zahl wandert mit dem Tag). Die Zuordnung ist eine **Beobachtung am Bestand**,
keine ADR-Aussage: Die sechs Sprung-ADRs entscheiden über die regierende Fassung, nicht über die
Zuordnung Vorlage → Instanz (dazu [§6](#6-offene-fragen)).

| Vorlage | Instanz(en) in diesem Repo | Beleg / Begründung |
|---|---|---|
| `.harness/baseline/v6.8.0/templates/AGENTS.template.md` | [`AGENTS.md`](../AGENTS.md) | eine Instanz, Repo-Wurzel |
| `.harness/baseline/v6.8.0/templates/docs/plan/adr/NNNN-titel.template.md` | `docs/plan/adr/[0-9]*.md` | 46 Instanzen (`ls docs/plan/adr/[0-9]*.md \| wc -l`, kein Erwartungswert) |
| `.harness/baseline/v6.8.0/templates/docs/plan/adr/README.template.md` | [`docs/plan/adr/README.md`](../docs/plan/adr/README.md) | eine Instanz, derivativ ([ADR-0024](../docs/plan/adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md)) |
| `.harness/baseline/v6.8.0/templates/docs/plan/carveouts/carveout.template.md` | `docs/plan/carveouts/CO-*.md` (offen und `done/`) | 6 Instanzen (`ls docs/plan/carveouts/*.md docs/plan/carveouts/done/*.md 2>/dev/null \| grep -v README \| wc -l`, kein Erwartungswert) |
| `.harness/baseline/v6.8.0/templates/docs/plan/carveouts/README.template.md` | `docs/plan/carveouts/README.md` | eine Instanz |
| `.harness/baseline/v6.8.0/templates/docs/plan/planning/archiv-stub-slice.template.md` | keine Instanz | dieses Repo hat noch keine Welle archiviert — `git ls-files 'docs/plan/planning/done/**/*.zip'` → leer (kein Erwartungswert); [`make archive-welle`](sensors/archive-welle.md) ist verdrahtet, aber gegen keine geschlossene Welle gelaufen. Zur wiederkehrenden **Slice**-Familie gezählt (unten, §4 Ausdehnungs-Schritt) und darum schon jetzt §5 Buchstabe b zugeordnet, nicht den vier Ausgängen aus Buchstabe a — die Klassenzugehörigkeit ist eine Eigenschaft der Vorlage und unabhängig vom heutigen Instanzenstand; der Instanzenstand selbst ändert sich erst, sobald `make archive-welle` die erste Archivierung erzeugt |
| `.harness/baseline/v6.8.0/templates/docs/plan/planning/archiv-stub-welle.template.md` | keine Instanz | dieselbe Begründung wie die Zeile darüber — derselbe Vorgang erzeugt beide Stub-Arten gemeinsam. Zur wiederkehrenden **Welle**-Familie gezählt (unten, §4 Ausdehnungs-Schritt); dieselbe Zuordnung wie in der Zeile darüber |
| `.harness/baseline/v6.8.0/templates/docs/plan/planning/observation.template.md` | `docs/plan/planning/observations/BEO-*/**/observation.md` | 104 Instanzen (`find docs/plan/planning/observations -mindepth 2 -maxdepth 2 -type d \| wc -l`, kein Erwartungswert) |
| `.harness/baseline/v6.8.0/templates/docs/plan/planning/README.template.md` | `docs/plan/planning/README.md` | eine Instanz |
| `.harness/baseline/v6.8.0/templates/docs/plan/planning/reconciliation.template.md` | keine Instanz | Datei existiert nicht (`ls docs/plan/planning/reconciliation.md` → Exit 2, kein Erwartungswert); die berührte Sub-Area ist Greenfield und führt kein Reconciliation-Register |
| `.harness/baseline/v6.8.0/templates/docs/plan/planning/roadmap.template.md` | [`docs/plan/planning/in-progress/roadmap.md`](../docs/plan/planning/in-progress/roadmap.md) | eine Instanz |
| `.harness/baseline/v6.8.0/templates/docs/plan/planning/slice.template.md` | `docs/plan/planning/{open,next,in-progress,done}/slice-*.md` | 229 Instanzen (`find docs/plan/planning/open docs/plan/planning/next docs/plan/planning/in-progress docs/plan/planning/done -maxdepth 1 -iname 'slice-*.md' \| wc -l`, kein Erwartungswert) |
| `.harness/baseline/v6.8.0/templates/docs/plan/planning/welle-results.template.md` | `docs/plan/planning/done/welle-*-results.md` | 12 Instanzen (`find docs/plan/planning/done -maxdepth 1 -iname 'welle-*-results.md' \| wc -l`, kein Erwartungswert) |
| `.harness/baseline/v6.8.0/templates/docs/plan/planning/welle.template.md` | `docs/plan/planning/welle-*.md` (offen) und `docs/plan/planning/done/welle-*.md` ohne `-results` | 15 Instanzen (3 offen + 12 in `done/`, `find docs/plan/planning -maxdepth 1 -iname 'welle-*.md' \| wc -l` und `find docs/plan/planning/done -maxdepth 1 -iname 'welle-*.md' ! -iname '*-results.md' \| wc -l`, kein Erwartungswert) |
| `.harness/baseline/v6.8.0/templates/docs/reviews/review-report.template.md` | `docs/reviews/*.md` | die Zahl der `docs/reviews/*.md`-Dateien zum Zeitpunkt des Lesens (`ls docs/reviews/*.md \| wc -l` — am Stand dieses Commits **382**); kein Endwert, weil jeder Commit, der eine Datei unter `docs/reviews/` hinzufügt, diese Zahl vor dem nächsten Lesen selbst bewegt — auch der Review-Lauf, der diese Zeile prüft ([`MR-058`](conventions.md#mr-058--eine-messung-die-ihr-eigener-vorgang-bewegt-wird-nach-dem-vorgang-genommen) Setzung 2 und 3) |
| `.harness/baseline/v6.8.0/templates/harness/conventions/MR-NNN-titel.template.md` | `harness/conventions/MR-*.md` (aktiv und `done/`) | 59 Instanzen (55 aktiv + 4 `done/`, `ls harness/conventions/*.md \| wc -l` und `ls harness/conventions/done/*.md \| wc -l`, kein Erwartungswert) |
| `.harness/baseline/v6.8.0/templates/harness/conventions.template.md` | [`harness/conventions.md`](conventions.md) | eine Instanz, Index des Adaptions-Blocks |
| `.harness/baseline/v6.8.0/templates/harness/README.template.md` | [`harness/README.md`](README.md) | eine Instanz |
| `.harness/baseline/v6.8.0/templates/harness/sensors/gate.template.md` | `harness/sensors/*.md` | 15 Instanzen (`ls harness/sensors/*.md \| wc -l`, kein Erwartungswert) |
| `.harness/baseline/v6.8.0/templates/.harness/skills/closure-note-reviewer.template.md` | keine Instanz | dieses Repo führt bislang nur eine Skill-Datei (`ls .harness/skills/*.md \| wc -l` → **1**, kein Erwartungswert); `v6.8.0` · `regelwerk/modul-08-agentenrollen.md` §Welche Rolle braucht welche Artefaktklasse verlangt diese Skill nur, wenn das Urteil inferential **und** aus keinem Artefakt ableitbar ist — bislang nicht eingetreten |
| `.harness/baseline/v6.8.0/templates/.harness/skills/reviewer.template.md` | [`.harness/skills/reviewer.md`](../.harness/skills/reviewer.md) | eine Instanz |
| `.harness/baseline/v6.8.0/templates/project-readme.template.md` | [`README.md`](../README.md) | eine Instanz, Repo-Wurzel |
| `.harness/baseline/v6.8.0/templates/spec/architecture.template.md` | [`spec/architecture.md`](../spec/architecture.md) | eine Instanz |
| `.harness/baseline/v6.8.0/templates/spec/lastenheft.template.md` | [`spec/lastenheft.md`](../spec/lastenheft.md) | eine Instanz |
| `.harness/baseline/v6.8.0/templates/spec/spezifikation.template.md` | [`spec/spezifikation.md`](../spec/spezifikation.md) | eine Instanz |

**Vollständigkeit** ist die Übereinstimmung der Zeilenzahl oben (25) mit
`find .harness/baseline/<tag>/templates -name '*.template.md' | wc -l`, `<tag>` aus
`grep -m1 '^BASELINE_TAG' Makefile` gelesen — nicht ein eingefrorenes Literal
([`MR-025`](conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2, [`MR-033`](conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)).
Eine Vorlage ohne Zeile ist der Befund, keine Auslassung.

**Sieben dieser Zeilen sind wiederkehrend und tragen in §5 keinen der dortigen vier Ausgänge.**
Modul 2 §Freshness-Audit der vendored Baseline (Schritt 2), Eigenschaft *Der Review vergleicht auch
die Form*, nennt die Menge ohne Fortsetzungspunkte — anders als die Singleton-Aufzählung direkt
davor in derselben Quelle — und damit abschließend (`v6.8.0` ·
`regelwerk/modul-02-harness-bootstrap.md`; dieselbe Klausel wörtlich zitiert in
[ADR-0018](../docs/plan/adr/0018-ziel-fassung-regiert-die-migration.md) §Entscheidung
Festlegung 4): *„Für wiederkehrende Templates (ADR, Slice, Welle, Carveout, Review-Report) gilt
die Append-only-Logik: Neue Instanzen folgen der neuen Form, bestehende werden nicht rückwirkend
umgeschrieben."* Die Klausel benennt fünf **Artefakt-Klassen**, keine Vorlagen-Dateien. Dieses
Dokument liest jede Klasse als Verweis auf **alle** Lebenszyklus-Formen desselben Artefakts — nicht
nur seine offene Form —, und wendet diesen Ausdehnungs-Schritt **einheitlich** an: Er ist eine
eigene Interpretation dieses Dokuments, keine Aussage der Klausel selbst. Ein Grund trägt ihn: die
**Archiv-Stub-Form** von Slice und Welle
(`.harness/baseline/v6.8.0/templates/docs/plan/planning/archiv-stub-slice.template.md`, Kopf
`# slice-<Kennung> — <Titel>`, und
`.harness/baseline/v6.8.0/templates/docs/plan/planning/archiv-stub-welle.template.md`, Kopf
`# <welle-id> — <Titel>`) — beide sind nach `v6.8.0` · `regelwerk/modul-06-roadmap.md`
Wellen-Closure-Prozedur, Schritt 4, dasselbe Artefakt wie Slice bzw. Welle, nur gekürzt, kein
eigener Artefakt-Typ: dieselbe Datei über ihren Lebenszyklus, in ihrer Schlussform. Auf dieses
Register abgebildet sind es **sieben** Zeilen, keine mehr — die
Slice-Familie und die Welle-Familie führen je zwei Vorlagen —, mit den Vorlagen
`.harness/baseline/v6.8.0/templates/docs/plan/adr/NNNN-titel.template.md` (ADR),
`.harness/baseline/v6.8.0/templates/docs/plan/planning/slice.template.md` **und**
`.harness/baseline/v6.8.0/templates/docs/plan/planning/archiv-stub-slice.template.md` (Slice),
`.harness/baseline/v6.8.0/templates/docs/plan/planning/welle.template.md` **und**
`.harness/baseline/v6.8.0/templates/docs/plan/planning/archiv-stub-welle.template.md` (Welle),
`.harness/baseline/v6.8.0/templates/docs/plan/carveouts/carveout.template.md` (Carveout),
`.harness/baseline/v6.8.0/templates/docs/reviews/review-report.template.md` (Review-Report). Für
sie gilt unten §5 Buchstabe b statt Buchstabe a — auch für die zwei Archiv-Stub-Zeilen, obwohl §4
sie oben (noch) als *keine Instanz* führt: Die Zuordnung zu Buchstabe a oder b folgt der
Artefakt-Klassen-Zugehörigkeit aus diesem Ausdehnungs-Schritt, nicht dem heutigen Instanzenstand —
eine Vorlage kann append-only-klassifiziert sein und trotzdem aktuell keine Instanz haben, wie die
beiden Archiv-Stub-Zeilen; das eine ist eine Eigenschaft der Vorlage, das andere ein Zustand des
Repos. Die Klassenzugehörigkeit gilt bereits jetzt; der Instanzenstand ändert sich erst künftig,
sobald `make archive-welle` die erste Archivierung erzeugt.

Drei der übrigen mehrinstanzigen Zeilen dieses Registers —
`.harness/baseline/v6.8.0/templates/docs/plan/planning/welle-results.template.md` (12 Instanzen),
`.harness/baseline/v6.8.0/templates/docs/plan/planning/observation.template.md` (104) und
`.harness/baseline/v6.8.0/templates/harness/sensors/gate.template.md` (15) — nennt dieselbe Stelle
**nicht**. Ob sie strukturell dieselbe Append-only-Logik tragen, misst dieses Dokument nicht und
behauptet es deshalb auch nicht ([§6](#6-offene-fragen)); bis zur Entscheidung sind sie von §5
Buchstabe a **ausgenommen**, nicht ihm zugeordnet.

Eine vierte — `.harness/baseline/v6.8.0/templates/harness/conventions/MR-NNN-titel.template.md`
(59 Instanzen) — ist aus demselben Grund offen, nicht zugeordnet:
[`MR-039`](conventions.md#mr-039--ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines)
regelt nur einen Teilaspekt — Setzung 1 trägt ein neues Pflichtfeld bei jedem Eintrag mit vollem
Rumpf nach, Setzung 2 nimmt die vier retirierten Einträge davon aus —, beantwortet aber nicht, ob
eine geänderte **Gesamt-Form** der Vorlage unter Buchstabe a oder b fällt. Keine der sechs
Sprung-ADRs oder
[`MR-039`](conventions.md#mr-039--ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines)
entscheidet das eindeutig ([§6](#6-offene-fragen)).

## 5. Report-Form für `docs/migrations/<tag>.md`

Wie §4 ist auch dieser Abschnitt eine Formvorgabe für einen künftigen Bericht, keine ADR-Aussage —
dazu [§6](#6-offene-fragen). Er unterscheidet zwei Fälle, je nachdem, ob §4 die betroffene Vorlage
als wiederkehrend ausweist.

### a) Einmalige Vorlagen — vier Ausgänge

Für jede Vorlage, die §4 **nicht** als wiederkehrend ausweist, führt ein künftiger
Migrations-Report genau einen von **vier** Ausgängen — eine geschlossene Menge, kein Freitext.
Ausgenommen sind die in [§6](#6-offene-fragen) als offen geführten Zeilen: Für sie ist noch nicht
entschieden, ob sie in diese Menge fallen oder unter Buchstabe b gehören.

| Ausgang | Bedingung | Beleg-Art |
|---|---|---|
| **übernommen** | die neue Fassung der Vorlage ist in die Instanz(en) dieses Repos eingearbeitet | Commit-Hash |
| **schon erfüllt** | die Instanz(en) erfüllen die neue Fassung bereits, ohne Änderung | Fundstelle der übereinstimmenden Stelle (kein `diff`-Fund, weil kein Unterschied besteht) |
| **bewusst abweichend** | dieses Repo weicht von der neuen Fassung ab | `MR`-Kennung des tragenden Adaptions-Eintrags |
| **keine Instanz** | die Vorlage hat in diesem Repo keine Instanz (§4) | Begründung |

Report-Skelett je Vorlage:

| Vorlage | Instanz(en) | Ausgang | Beleg |
|---|---|---|---|
| `<Vorlagen-Pfad>` | `<Instanz-Pfad oder „—">` | übernommen / schon erfüllt / bewusst abweichend / keine Instanz | `<Commit-Hash / Fundstelle / MR-Kennung / Begründung>` |

**Für den Sprung `v6.8.0` → `v6.9.0` entfällt ein Ausgang.**
[ADR-0056](../docs/plan/adr/0056-ziel-fassung-regiert-den-sprung-v690.md) §Konsequenzen verbucht
die Vorgabe des Auftraggebers: *„Der Durchgang übernimmt die Ziel-Fassung vollständig; eine
Abweichung wird nicht gesetzt."* Der Ausgang **bewusst abweichend** steht in diesem Sprung damit
nicht zur Verfügung, auch nicht mit einem bestehenden `MR`-Eintrag als Beleg: Der Eintrag tritt
zurück, und die neue Fassung wird übernommen. Welcher Eintrag betroffen ist, klärt der Durchgang;
die ADR steht auf **`Proposed`**.

### b) Wiederkehrende Vorlagen — Append-only

Für die sieben in §4 aus der [ADR-0018](../docs/plan/adr/0018-ziel-fassung-regiert-die-migration.md)-Klausel
abgeleiteten Zeilen (ADR, Slice, Slice-Archiv-Stub, Welle, Welle-Archiv-Stub, Carveout,
Review-Report) trägt ein künftiger Migrations-Report **keinen** der vier Ausgänge aus Buchstabe a:
*übernommen* verlangt genau das rückwirkende Umschreiben bestehender Instanzen, das die jeweilige
Quelle für diese Vorlagen untersagt oder auf einen Teil der Instanzen beschränkt. *schon erfüllt* /
*bewusst abweichend* / *keine Instanz* gehen dagegen von einer **einzelnen, über die Zeit
stabilen** Instanzlage aus, die sich mit einem Bericht endgültig festhalten lässt — eingeschlossen
der Fall, dass diese Lage *keine Instanz* ist. Eine wiederkehrende Vorlage hat stattdessen laufend
neue Instanzen, die je nach Sprung-Datum die alte oder die neue Form tragen: Der einmal berichtete
Zustand veraltet mit der nächsten Instanz, unabhängig davon, ob heute überhaupt schon Instanzen
bestehen (bei den beiden Archiv-Stub-Vorlagen, §4, sind es heute **keine**). Der Report notiert
stattdessen einmal je Vorlage:

| Ausgang | Bedingung | Beleg-Art |
|---|---|---|
| **append-only** | die Vorlage ist wiederkehrend (§4); neue Instanzen folgen ab dem Sprung-Datum der neuen Form, bestehende Instanzen bleiben unverändert | das Sprung-Datum, ab dem neue Instanzen die neue Form tragen |

Buchstabe a bleibt für seine Vorlagen eine geschlossene Vier-Menge; Buchstabe b ist keine fünfte
Ergänzung dieser Menge, sondern eine eigene, disjunkte Antwort für eine andere Vorlagen-Klasse
([`AGENTS.md`](../AGENTS.md) §3.6;
[ADR-0018](../docs/plan/adr/0018-ziel-fassung-regiert-die-migration.md) §Entscheidung
Festlegung 4).

**Diese Ausgänge (vier aus Buchstabe a, einer aus Buchstabe b) sind nicht die fünf Ausgänge des
Adaptions-Durchgangs.** `v6.8.0` · `regelwerk/modul-02-harness-bootstrap.md` §Freshness-Audit der
vendored Baseline (Schritt 2) führt für den **Adaptions-Eintrag** (`MR-<NNN>`) fünf eigene
Ausgänge — *gegenstandslos · bleibt gültig · teilweise überholt · Bezug ist entfallen ·
widerspricht* —, benannt in
[ADR-0018](../docs/plan/adr/0018-ziel-fassung-regiert-die-migration.md) §Entscheidung Festlegung 4
(§Kontext derselben ADR nennt an der zitierten Stelle nur die Zahl *fünf Ausgängen*, nicht die
Namen). Die Ausgänge dieses Abschnitts gelten der **Vorlage** dieses Registers — zwei verschiedene
Achsen, die nicht ineinander übersetzt werden: dazu [§6](#6-offene-fragen).

## 6. Offene Fragen

- **Ob die sechs Sprung-ADRs eine Pflicht zum Führen des Instanz-Registers oder der Report-Form
  überhaupt tragen, ist gemessen offen.** Sie entscheiden über die regierende Fassung eines
  Sprungs, nicht nachweislich über die Zuordnung Vorlage → Instanz — sie nennen das Wort
  `templates` zwischen 0 und 16 Mal
  (`for f in 0018 0031 0036 0038 0043 0044; do grep -c templates docs/plan/adr/$f-*.md; done`, kein
  Erwartungswert), und eine bloße Nennung ist kein Beleg. §4 und §5 dieses Dokuments sind darum
  **keine** aus den sechs ADRs abgeleiteten Normen, sondern eine am Bestand gemessene Beobachtung
  bzw. eine Formvorgabe für einen künftigen Bericht.
- **`.harness/baseline/v6.8.0/templates/docs/plan/planning/welle-results.template.md` — 12
  Instanzen (`find docs/plan/planning/done -maxdepth 1 -iname 'welle-*-results.md' | wc -l`, kein
  Erwartungswert): append-only wie die sieben Zeilen aus §5 Buchstabe b, oder Buchstabe a (vier
  Ausgänge)? Sie ist keine Lebenszyklus-Form von `welle.template.md` — nach `v6.8.0` ·
  `regelwerk/modul-06-roadmap.md` Wellen-Closure-Prozedur Schritt 4 bleibt die Ergebnisnotiz
  vollständig und flach, während Slice-Datei und Welle-Plan zum Stub werden —, sondern die
  Ergebnis-Notiz, die derselbe Abschluss-Vorgang zusätzlich zur offenen Form erzeugt; die
  Archiv-Stub-Begründung aus §4 trägt hier darum nicht. Die einzig greifbare Gemeinsamkeit mit den
  sieben append-only-Zeilen ist dieselbe **wachsende Instanzmenge**, die auch
  `observation.template.md` (104) und `gate.template.md` (15) haben — keine der sechs
  Sprung-ADRs entscheidet, ob eine wachsende Instanzmenge allein für Buchstabe b genügt. Weder
  Buchstabe a noch Buchstabe b ist damit zugewiesen; die Zeile bleibt offen (siehe §5 Buchstabe a,
  Ausnahme-Satz).
- **`.harness/baseline/v6.8.0/templates/docs/plan/planning/observation.template.md` — 104
  Instanzen (`find docs/plan/planning/observations -mindepth 2 -maxdepth 2 -type d | wc -l`, kein
  Erwartungswert): append-only wie die sieben Zeilen aus §5 Buchstabe b, oder Buchstabe a (vier
  Ausgänge)? Keine der sechs Sprung-ADRs entscheidet es. `v6.8.0` ·
  `regelwerk/modul-06-roadmap.md` §Das Beobachtungs-Register führt `observation.md` und
  `evidence/*.md` zwar als „unveränderlich ab Anlage" bzw. „unveränderlich ab Merge" — das
  beschreibt die Lebensdauer einer einzelnen Beobachtung innerhalb des Registers, nicht, ob eine
  geänderte Template-**Form** rückwirkend auf bestehende Instanzen angewendet würde. Die zitierte
  Unveränderlichkeit schließt allerdings den Ausgang *übernommen* aus Buchstabe a aus — eine
  rückwirkende Form-Anwendung wäre eine Änderung an 104 ab Anlage unveränderlichen Instanzen.
  Weder Buchstabe a noch Buchstabe b ist damit zugewiesen; die Zeile bleibt offen (siehe §5
  Buchstabe a, Ausnahme-Satz).
- **`.harness/baseline/v6.8.0/templates/harness/sensors/gate.template.md` — 15 Instanzen
  (`ls harness/sensors/*.md | wc -l`, kein Erwartungswert): append-only oder Buchstabe a? `v6.8.0` ·
  `regelwerk/grundlagen-begriffe.md` nennt für `harness/sensors/<target>.md`: *„kein
  Lifecycle-Verzeichnis, ein retiriertes Gate verschwindet."* Das spricht gegen eine
  Bestandsschutz-Logik für die einzelne Sensor-Datei, entscheidet aber nicht, ob eine geänderte
  Template-**Form** rückwirkend auf bestehende Instanzen angewendet würde. Weder Buchstabe a noch
  Buchstabe b ist damit zugewiesen; die Zeile bleibt offen (siehe §5 Buchstabe a, Ausnahme-Satz).
- **`.harness/baseline/v6.8.0/templates/harness/conventions/MR-NNN-titel.template.md` — 59
  Instanzen (55 aktiv + 4 `done/`, §4): append-only oder Buchstabe a?
  [`MR-039`](conventions.md#mr-039--ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines)
  regelt nur einen Teilaspekt — Setzung 1 trägt ein neues Pflichtfeld bei jedem Eintrag mit vollem
  Rumpf nach, Setzung 2 nimmt die vier retirierten Einträge davon aus —, beantwortet aber nicht, ob
  eine geänderte **Gesamt-Form** der Vorlage unter Buchstabe a oder b fällt. Keine der sechs
  Sprung-ADRs oder
  [`MR-039`](conventions.md#mr-039--ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines)
  entscheidet das eindeutig. Weder Buchstabe a noch Buchstabe b ist damit zugewiesen; die Zeile
  bleibt offen (siehe §5 Buchstabe a, Ausnahme-Satz).
- **Das Verhältnis der vier Report-Ausgänge zu den fünf Baseline-Ausgängen bleibt uneindeutig,
  solange niemand einen Durchgang gegen beide Mengen gleichzeitig fährt.** Sie messen
  unterschiedliche Gegenstände (Vorlage gegen Adaptions-Eintrag); ob ein künftiger Durchgang beide
  Register nebeneinander braucht oder eines das andere trägt, ist hier nicht entschieden.
- **Keine der sechs ADRs benennt, wer ein `docs/migrations/<tag>.md` schreibt oder wann.** <!-- d-check:ignore (geplante Ablage) -->
  Die Report-Form in §5 ist ohne einen solchen Anlass reine Vorbereitung.
- **Ob `harness/migration.md` selbst bei jedem Baseline-Sprung fortzuschreiben ist** (neue Vorlagen,
  entfallene Vorlagen, geänderte Instanz-Zuordnungen), sagt keine der sechs ADRs — sie sind
  Prozess-ADRs über die regierende Fassung, nicht über die Pflege dieses Dokuments.
