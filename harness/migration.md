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
[ADR-0043](../docs/plan/adr/0043-ziel-fassung-regiert-den-sprung-v671.md),
[ADR-0044](../docs/plan/adr/0044-ziel-fassung-regiert-den-sprung-v672.md),
[ADR-0047](../docs/plan/adr/0047-ziel-fassung-regiert-den-sprung-v680.md) und
[ADR-0056](../docs/plan/adr/0056-ziel-fassung-regiert-den-sprung-v690.md). Was sich dort nicht
belegen lässt, steht in [§6 Offene Fragen](#6-offene-fragen) — benannt, nicht als Regel getarnt. Das
Dokument ist keine ADR und ersetzt keine dieser Entscheidungen; es zitiert sie.

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
| `v6.8.0` → `v6.9.0` (vollzogen) | Ziel-Fassung `v6.9.0` | [ADR-0056](../docs/plan/adr/0056-ziel-fassung-regiert-den-sprung-v690.md) |

Die Zeile zu `v5.12.0` → `v5.18.0` zitiert
[ADR-0031](../docs/plan/adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) Festlegung 1;
die ADR steht auf **`Proposed`** (ihre eigene §Geschichte) und ist damit nach
[`AGENTS.md`](../AGENTS.md) §3.4 noch nicht eingefroren — die Zeile hält fest, was sie **heute**
vorschlägt, nicht, dass die Entscheidung feststeht.

Der aktuell vendored Stand ist `v6.9.0`
(`ls -1 .harness/baseline/` — kein Erwartungswert, wandert mit jedem Tausch); der Zielstand steht
auf demselben Tag (§Baseline von [`conventions.md`](conventions.md)), der Baum ist getauscht, und
damit ist die Zwei-Fassungen-Phase des achten Sprungs geschlossen. Der Sprung ist vollzogen:
[ADR-0056](../docs/plan/adr/0056-ziel-fassung-regiert-den-sprung-v690.md) §Konsequenzen legt den
Instanz-Durchgang vor den Vollzug; sein Report ist [`docs/migrations/v6.9.0.md`](../docs/migrations/v6.9.0.md).

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

Gemessen am Stand dieses Dokuments trägt die letzte Zeile mit gefülltem Nachweis-Feld `v6.9.0`
(`grep -o '\*\*auf \`v[0-9.]*\`:\*\* [0-9-]*, Delta-Nachweis[^.;]*' harness/conventions.md` — die
Zeile mit `Delta-Nachweis in slice-sprung-auf-v690-wird-vollzogen`, kein Erwartungswert). Für einen
neunten Sprung wäre `v6.9.0` damit die Basis, **solange** kein weiterer Durchgang zwischenzeitlich
läuft.

## 4. Instanz-Register

Je Vorlage unter `.harness/baseline/v6.9.0/templates/` genau eine Zeile
(`find .harness/baseline/v6.9.0/templates -name '*.template.md' | wc -l` → **25**, kein
Erwartungswert — die Zahl wandert mit dem Tag). Die Zuordnung ist eine **Beobachtung am Bestand**,
keine ADR-Aussage: Die Sprung-ADRs aus §1 entscheiden über die regierende Fassung, nicht über die
Zuordnung Vorlage → Instanz (dazu [§6](#6-offene-fragen)).

| Vorlage | Instanz(en) in diesem Repo | Beleg / Begründung |
|---|---|---|
| `.harness/baseline/v6.9.0/templates/AGENTS.template.md` | [`AGENTS.md`](../AGENTS.md) | eine Instanz, Repo-Wurzel |
| `.harness/baseline/v6.9.0/templates/docs/plan/adr/NNNN-titel.template.md` | `docs/plan/adr/[0-9]*.md` | 46 Instanzen (`ls docs/plan/adr/[0-9]*.md \| wc -l`, kein Erwartungswert) |
| `.harness/baseline/v6.9.0/templates/docs/plan/adr/README.template.md` | [`docs/plan/adr/README.md`](../docs/plan/adr/README.md) | eine Instanz, derivativ ([ADR-0024](../docs/plan/adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md)) |
| `.harness/baseline/v6.9.0/templates/docs/plan/carveouts/carveout.template.md` | `docs/plan/carveouts/CO-*.md` (offen und `done/`) | 6 Instanzen (`ls docs/plan/carveouts/*.md docs/plan/carveouts/done/*.md 2>/dev/null \| grep -v README \| wc -l`, kein Erwartungswert) |
| `.harness/baseline/v6.9.0/templates/docs/plan/carveouts/README.template.md` | `docs/plan/carveouts/README.md` | eine Instanz |
| `.harness/baseline/v6.9.0/templates/docs/plan/planning/archiv-stub-slice.template.md` | keine Instanz | dieses Repo hat noch keine Welle archiviert — `git ls-files 'docs/plan/planning/done/**/*.zip'` → leer (kein Erwartungswert); [`make archive-welle`](sensors/archive-welle.md) ist verdrahtet, aber gegen keine geschlossene Welle gelaufen. Zur wiederkehrenden **Slice**-Familie gezählt (unten, §4 *Neun dieser Zeilen sind wiederkehrend*) und darum schon jetzt §5 Buchstabe b zugeordnet, nicht den vier Ausgängen aus Buchstabe a — die Klassenzugehörigkeit ist eine Eigenschaft der Vorlage und unabhängig vom heutigen Instanzenstand; der Instanzenstand selbst ändert sich erst, sobald `make archive-welle` die erste Archivierung erzeugt |
| `.harness/baseline/v6.9.0/templates/docs/plan/planning/archiv-stub-welle.template.md` | keine Instanz | dieselbe Begründung wie die Zeile darüber — derselbe Vorgang erzeugt beide Stub-Arten gemeinsam. Zur wiederkehrenden **Welle**-Familie gezählt (unten, §4 *Neun dieser Zeilen sind wiederkehrend*); dieselbe Zuordnung wie in der Zeile darüber |
| `.harness/baseline/v6.9.0/templates/docs/plan/planning/observation.template.md` | `docs/plan/planning/observations/BEO-*/**/observation.md` | 104 Instanzen (`find docs/plan/planning/observations -mindepth 2 -maxdepth 2 -type d \| wc -l`, kein Erwartungswert) |
| `.harness/baseline/v6.9.0/templates/docs/plan/planning/README.template.md` | `docs/plan/planning/README.md` | eine Instanz |
| `.harness/baseline/v6.9.0/templates/docs/plan/planning/reconciliation.template.md` | keine Instanz | Datei existiert nicht (`ls docs/plan/planning/reconciliation.md` → Exit 2, kein Erwartungswert); die berührte Sub-Area ist Greenfield und führt kein Reconciliation-Register |
| `.harness/baseline/v6.9.0/templates/docs/plan/planning/roadmap.template.md` | [`docs/plan/planning/in-progress/roadmap.md`](../docs/plan/planning/in-progress/roadmap.md) | eine Instanz |
| `.harness/baseline/v6.9.0/templates/docs/plan/planning/slice.template.md` | `docs/plan/planning/{open,next,in-progress,done}/slice-*.md` | 229 Instanzen (`find docs/plan/planning/open docs/plan/planning/next docs/plan/planning/in-progress docs/plan/planning/done -maxdepth 1 -iname 'slice-*.md' \| wc -l`, kein Erwartungswert) |
| `.harness/baseline/v6.9.0/templates/docs/plan/planning/welle-results.template.md` | `docs/plan/planning/done/welle-*-results.md` | 12 Instanzen (`find docs/plan/planning/done -maxdepth 1 -iname 'welle-*-results.md' \| wc -l`, kein Erwartungswert) |
| `.harness/baseline/v6.9.0/templates/docs/plan/planning/welle.template.md` | `docs/plan/planning/welle-*.md` (offen) und `docs/plan/planning/done/welle-*.md` ohne `-results` | 15 Instanzen (3 offen + 12 in `done/`, `find docs/plan/planning -maxdepth 1 -iname 'welle-*.md' \| wc -l` und `find docs/plan/planning/done -maxdepth 1 -iname 'welle-*.md' ! -iname '*-results.md' \| wc -l`, kein Erwartungswert) |
| `.harness/baseline/v6.9.0/templates/docs/reviews/review-report.template.md` | `docs/reviews/*.md` | die Zahl der `docs/reviews/*.md`-Dateien zum Zeitpunkt des Lesens (`ls docs/reviews/*.md \| wc -l` — am Stand dieses Commits **382**); kein Endwert, weil jeder Commit, der eine Datei unter `docs/reviews/` hinzufügt, diese Zahl vor dem nächsten Lesen selbst bewegt — auch der Review-Lauf, der diese Zeile prüft ([`MR-058`](conventions.md#mr-058--eine-messung-die-ihr-eigener-vorgang-bewegt-wird-nach-dem-vorgang-genommen) Setzung 2 und 3) |
| `.harness/baseline/v6.9.0/templates/harness/conventions/MR-NNN-titel.template.md` | `harness/conventions/MR-*.md` (aktiv und `done/`) | 59 Instanzen (55 aktiv + 4 `done/`, `ls harness/conventions/*.md \| wc -l` und `ls harness/conventions/done/*.md \| wc -l`, kein Erwartungswert) |
| `.harness/baseline/v6.9.0/templates/harness/conventions.template.md` | [`harness/conventions.md`](conventions.md) | eine Instanz, Index des Adaptions-Blocks |
| `.harness/baseline/v6.9.0/templates/harness/README.template.md` | [`harness/README.md`](README.md) | eine Instanz |
| `.harness/baseline/v6.9.0/templates/harness/sensors/gate.template.md` | `harness/sensors/*.md` | 15 Instanzen (`ls harness/sensors/*.md \| wc -l`, kein Erwartungswert) |
| `.harness/baseline/v6.9.0/templates/.harness/skills/closure-note-reviewer.template.md` | keine Instanz | dieses Repo führt bislang nur eine Skill-Datei (`ls .harness/skills/*.md \| wc -l` → **1**, kein Erwartungswert); `v6.9.0` · `regelwerk/modul-08-agentenrollen.md` §Welche Rolle braucht welche Artefaktklasse verlangt diese Skill nur, wenn das Urteil inferential **und** aus keinem Artefakt ableitbar ist — bislang nicht eingetreten |
| `.harness/baseline/v6.9.0/templates/.harness/skills/reviewer.template.md` | [`.harness/skills/reviewer.md`](../.harness/skills/reviewer.md) | eine Instanz |
| `.harness/baseline/v6.9.0/templates/project-readme.template.md` | [`README.md`](../README.md) | eine Instanz, Repo-Wurzel |
| `.harness/baseline/v6.9.0/templates/spec/architecture.template.md` | [`spec/architecture.md`](../spec/architecture.md) | eine Instanz |
| `.harness/baseline/v6.9.0/templates/spec/lastenheft.template.md` | [`spec/lastenheft.md`](../spec/lastenheft.md) | eine Instanz |
| `.harness/baseline/v6.9.0/templates/spec/spezifikation.template.md` | [`spec/spezifikation.md`](../spec/spezifikation.md) | eine Instanz |

**Vollständigkeit** ist die Übereinstimmung der Zeilenzahl oben (25) mit
`find .harness/baseline/<tag>/templates -name '*.template.md' | wc -l`, `<tag>` aus
`grep -m1 '^BASELINE_TAG' Makefile` gelesen — nicht ein eingefrorenes Literal
([`MR-025`](conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2, [`MR-033`](conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)).
Eine Vorlage ohne Zeile ist der Befund, keine Auslassung.

**Neun dieser Zeilen sind wiederkehrend und tragen in §5 keinen der dortigen vier Ausgänge.** Die
Baseline benennt sie selbst, in `v6.9.0` · `regelwerk/modul-02-harness-bootstrap.md`
§Freshness-Audit der vendored Baseline (Schritt 2), Eigenschaft *Der Review vergleicht auch die
Form*: *„Für **wiederkehrende** Templates (ADR, Slice, Welle, Carveout, Review-Report, `MR`) gilt
die Append-only-Logik: Neue Instanzen folgen der neuen Form, bestehende werden nicht rückwirkend
umgeschrieben."* Dieselbe Stelle liest die Aufzählung als Artefakt-Klassen — *„Das Wort
**Templates** benennt hier die Artefakt-Klasse, nicht 1:1 eine einzelne Vorlagen-Datei"* — und
ordnet die Vorlagen je Klasse zu: für Slice und Welle jede Lebenszyklus-Form, einschließlich der
Ergebnis-Notiz der Welle und der zwei Archiv-Stubs (*„Auch ein Archiv-Stub ist eine eingefrorene
historische Form"*), und für den Adaptions-Eintrag *„`MR`-Einträge
(…) gehören ebenfalls dazu"*. Auf dieses Register
abgebildet sind es **neun** Zeilen, keine mehr:

| Klasse | Vorlage |
|---|---|
| ADR | `.harness/baseline/v6.9.0/templates/docs/plan/adr/NNNN-titel.template.md` |
| Slice | `.harness/baseline/v6.9.0/templates/docs/plan/planning/slice.template.md` |
| Slice | `.harness/baseline/v6.9.0/templates/docs/plan/planning/archiv-stub-slice.template.md` |
| Welle | `.harness/baseline/v6.9.0/templates/docs/plan/planning/welle.template.md` |
| Welle | `.harness/baseline/v6.9.0/templates/docs/plan/planning/welle-results.template.md` |
| Welle | `.harness/baseline/v6.9.0/templates/docs/plan/planning/archiv-stub-welle.template.md` |
| Carveout | `.harness/baseline/v6.9.0/templates/docs/plan/carveouts/carveout.template.md` |
| Review-Report | `.harness/baseline/v6.9.0/templates/docs/reviews/review-report.template.md` |
| `MR` | `.harness/baseline/v6.9.0/templates/harness/conventions/MR-NNN-titel.template.md` |

Für sie gilt unten §5 Buchstabe b statt Buchstabe a — auch für die zwei Archiv-Stub-Zeilen, die die
Register-Tabelle oben als *keine Instanz* führt. Die Zuordnung folgt der Klasse, nicht dem heutigen
Instanzenstand: Das eine ist eine Eigenschaft der Vorlage, das andere ein Zustand des Repos, der
sich erst mit der ersten Archivierung durch [`make archive-welle`](sensors/archive-welle.md) ändert.

**Eine mehrinstanzige Zeile nimmt dieselbe Stelle ausdrücklich aus:**
`.harness/baseline/v6.9.0/templates/harness/sensors/gate.template.md` — *„**Sensor-Gate-Dateien
(…) dagegen nicht**, obwohl auch sie mehrfach vendored vorliegen:
Ihr Vertrag wird bei einer Mechanismus-Änderung fortgeschrieben statt durch einen neuen Eintrag
abgelöst"*. §4 weist sie damit **nicht** als wiederkehrend aus, obwohl sie mehrere Instanzen hat;
sie steht unter §5 Buchstabe a.

**Eine weitere nennt die Stelle nicht:**
`.harness/baseline/v6.9.0/templates/docs/plan/planning/observation.template.md`. Ob sie die
Append-only-Logik trägt, misst dieses Dokument nicht und behauptet es deshalb auch nicht
([§6](#6-offene-fragen)); bis zur Entscheidung ist sie von §5 Buchstabe a **ausgenommen**, nicht ihm
zugeordnet.

## 5. Report-Form für `docs/migrations/<tag>.md`

Wie §4 ist auch dieser Abschnitt eine Formvorgabe für einen künftigen Bericht, keine ADR-Aussage —
dazu [§6](#6-offene-fragen). Ausgenommen ist der sprung-bezogene Absatz am Ende von Buchstabe a; er
projiziert [ADR-0056](../docs/plan/adr/0056-ziel-fassung-regiert-den-sprung-v690.md) §Konsequenzen. Der Abschnitt unterscheidet zwei Fälle, je nachdem, ob §4 die betroffene Vorlage
als wiederkehrend ausweist.

### a) Einmalige Vorlagen — vier Ausgänge

Für jede Vorlage, die §4 **nicht** als wiederkehrend ausweist, führt ein künftiger
Migrations-Report genau einen von **vier** Ausgängen — eine geschlossene Menge, kein Freitext.
Ausgenommen sind die in [§6](#6-offene-fragen) als offen geführten Zeilen: Für sie ist noch nicht
entschieden, ob sie in diese Menge fallen oder unter Buchstabe b gehören. Für den Sprung
`v6.8.0` → `v6.9.0` sind außerdem die Vorlagen ohne Delta ausgenommen (Absatz unten).

| Ausgang | Bedingung | Beleg-Art |
|---|---|---|
| **übernommen** | die neue Fassung der Vorlage ist in die Instanz(en) dieses Repos eingearbeitet | Commit-Hash |
| **schon erfüllt** | die Instanz(en) erfüllen die neue Fassung bereits, ohne Änderung | Fundstelle der übereinstimmenden Stelle (kein `diff`-Fund, weil kein Unterschied besteht) |
| **bewusst abweichend** | dieses Repo weicht von der neuen Fassung ab | `MR`-Kennung des tragenden Adaptions-Eintrags |
| **keine Instanz** | die Vorlage hat in diesem Repo keine Instanz (§4) | Begründung |

**Woran *schon erfüllt* bei der Gliederung gemessen wird.** Die `##`-Abschnitte der Instanz sind
die der Vorlage; eigener Stoff steht als Unterabschnitt im passenden Vorlagen-Abschnitt. Ein
`##`-Abschnitt, den die Vorlage nicht führt, schließt *schon erfüllt* aus, und ebenso ein
Vorlagen-Abschnitt, der in der Instanz fehlt. **Fehlen darf ein Abschnitt nur, wenn die Vorlage ihn
selbst als bedingt kennzeichnet und seine Bedingung nicht zutrifft.** Gekennzeichnet ist er im
Titel (`conventions.template.md`: `## Glossar (optional)`) oder durch einen Hinweis im
Abschnitt, der die Bedingung nennt (`gate.template.md`, `## Ausgabe und Ausgänge`:
*„Nur, wenn der Lauf mehr als grün/rot sagt."*). Jeder andere Abschnitt steht in jeder Instanz,
auch wenn er nichts trägt; dann trägt er die gemessene Aussage, dass er leer ist. Bietet die
Vorlage dafür eine Leer-Form an (`conventions.template.md` §Zusatzklassen-Deklaration für
Sensors-Bindung: *„Tabelle entfernen oder "— keine —" eintragen"*), betrifft sie den Inhalt des
Abschnitts, nicht seine Existenz. Die Lesart ist die des Auftraggebers (2026-09-16); ihre Quelle
ist die Baseline selbst, `v6.9.0` · `templates/README.md` §Pflichtgliederung vs. freie Form:
*„Die Templates geben **Pflichtgliederung** vor (Abschnitte, IDs, Verlinkung). Innerhalb der
Abschnitte hast du Freiraum"*. Das Kriterium wendet diese Stelle an und weicht von ihr nicht ab;
ein Adaptions-Eintrag folgt daraus nicht ([`MR-000`](conventions.md#mr-000--baseline-aussage)).

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
die ADR ist **`Accepted`**.

**Und die Vorgabe ist delta-gebunden** (Auftraggeber, 2026-09-16): Sie greift, wo das Delta dieses
Sprungs eine Vorlage oder ihre Instanz erreicht. Eine einmalige Vorlage **ohne** Delta ist darum
nicht Gegenstand des Instanz-Durchgangs dieses Sprungs und trägt keinen der vier Ausgänge; der
Report führt sie als *nicht Gegenstand dieses Sprungs*. Ergibt der Ist-Maßstab
([ADR-0018](../docs/plan/adr/0018-ziel-fassung-regiert-die-migration.md) Festlegung 2) für ihre
Instanz eine Abweichung, bekommt der Befund statt eines Ausgangs die Kennung eines Folge-Slice als
Adresse. Das gilt für diesen Sprung, wie der Absatz darüber; ob es darüber hinaus gilt, ist nicht
entschieden.

### b) Wiederkehrende Vorlagen — Append-only

Für die neun Zeilen, die §4 aus der Klausel von `v6.9.0` ableitet (ADR, Slice, Slice-Archiv-Stub,
Welle, Welle-Ergebnis-Notiz, Welle-Archiv-Stub, Carveout, Review-Report, `MR`-Eintrag), trägt ein
künftiger Migrations-Report **keinen** der vier Ausgänge aus Buchstabe a:
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
Adaptions-Durchgangs.** `v6.9.0` · `regelwerk/modul-02-harness-bootstrap.md` §Freshness-Audit der
vendored Baseline (Schritt 2) führt für den **Adaptions-Eintrag** (`MR-<NNN>`) fünf eigene
Ausgänge — *gegenstandslos · bleibt gültig · teilweise überholt · Bezug ist entfallen ·
widerspricht* —, benannt in
[ADR-0018](../docs/plan/adr/0018-ziel-fassung-regiert-die-migration.md) §Entscheidung Festlegung 4
(§Kontext derselben ADR nennt an der zitierten Stelle nur die Zahl *fünf Ausgängen*, nicht die
Namen). Die Ausgänge dieses Abschnitts gelten der **Vorlage** dieses Registers — zwei verschiedene
Achsen, die nicht ineinander übersetzt werden: dazu [§6](#6-offene-fragen).

## 6. Offene Fragen

- **Ob die acht Sprung-ADRs aus §1 eine Pflicht zum Führen des Instanz-Registers oder der Report-Form
  überhaupt tragen, ist gemessen offen.** Sie entscheiden über die regierende Fassung eines
  Sprungs, nicht nachweislich über die Zuordnung Vorlage → Instanz — sie nennen das Wort
  `templates` zwischen 0 und 16 Mal
  (`for f in 0018 0031 0036 0038 0043 0044 0047 0056; do grep -c templates docs/plan/adr/$f-*.md; done`, kein
  Erwartungswert), und eine bloße Nennung ist kein Beleg. §4 und §5 dieses Dokuments sind darum
  **keine** aus den acht ADRs abgeleiteten Normen, sondern eine am Bestand gemessene Beobachtung
  bzw. eine Formvorgabe für einen künftigen Bericht, ausgenommen der sprung-bezogene Absatz in §5 a.
  [ADR-0056](../docs/plan/adr/0056-ziel-fassung-regiert-den-sprung-v690.md) nennt die Report-Form außerdem als Form ihres Instanz-Durchgangs; ob daraus eine
  Pflicht über ihren Sprung hinaus folgt, bleibt offen.
- **`.harness/baseline/v6.9.0/templates/docs/plan/planning/observation.template.md` — 104
  Instanzen (`find docs/plan/planning/observations -mindepth 2 -maxdepth 2 -type d | wc -l`, kein
  Erwartungswert): append-only wie die neun Zeilen aus §5 Buchstabe b, oder Buchstabe a (vier
  Ausgänge)? Keine der acht Sprung-ADRs entscheidet es, und die Klausel aus §4 nennt die Vorlage
  weder als wiederkehrend noch als ausgenommen. `v6.9.0` ·
  `regelwerk/modul-06-roadmap.md` §Das Beobachtungs-Register führt `observation.md` und
  `evidence/*.md` zwar als „unveränderlich ab Anlage" bzw. „unveränderlich ab Merge" — das
  beschreibt die Lebensdauer einer einzelnen Beobachtung innerhalb des Registers, nicht, ob eine
  geänderte Template-**Form** rückwirkend auf bestehende Instanzen angewendet würde. Die zitierte
  Unveränderlichkeit schließt allerdings den Ausgang *übernommen* aus Buchstabe a aus — eine
  rückwirkende Form-Anwendung wäre eine Änderung an 104 ab Anlage unveränderlichen Instanzen.
  Weder Buchstabe a noch Buchstabe b ist damit zugewiesen; die Zeile bleibt offen (siehe §5
  Buchstabe a, Ausnahme-Satz).
- **Das Verhältnis der vier Report-Ausgänge zu den fünf Baseline-Ausgängen bleibt uneindeutig,
  solange niemand einen Durchgang gegen beide Mengen gleichzeitig fährt.** Sie messen
  unterschiedliche Gegenstände (Vorlage gegen Adaptions-Eintrag); ob ein künftiger Durchgang beide
  Register nebeneinander braucht oder eines das andere trägt, ist hier nicht entschieden.
- **Keine der acht ADRs benennt, wer ein `docs/migrations/<tag>.md` schreibt.** <!-- d-check:ignore (geplante Ablage) -->
  [ADR-0056](../docs/plan/adr/0056-ziel-fassung-regiert-den-sprung-v690.md) legt für ihren Sprung nur fest, dass der Instanz-Durchgang vor dem Vollzug in
  dieser Form läuft. Die Report-Form in §5 ist ohne einen solchen Anlass reine Vorbereitung.
- **Ob `harness/migration.md` selbst bei jedem Baseline-Sprung fortzuschreiben ist** (neue Vorlagen,
  entfallene Vorlagen, geänderte Instanz-Zuordnungen), sagt keine der acht ADRs als allgemeine
  Regel. [ADR-0047](../docs/plan/adr/0047-ziel-fassung-regiert-den-sprung-v680.md) zieht für ihren Sprung §1 nach; [ADR-0056](../docs/plan/adr/0056-ziel-fassung-regiert-den-sprung-v690.md) zieht für ihren
  Sprung zusätzlich §5 a und die Stellen nach, die Sprung-ADRs aufzählen oder zählen. Sie sind
  Prozess-ADRs über die regierende Fassung, nicht über die Pflege dieses Dokuments.
