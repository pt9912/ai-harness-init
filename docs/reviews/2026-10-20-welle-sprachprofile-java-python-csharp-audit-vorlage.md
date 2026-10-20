# Welle-Closure welle-sprachprofile-java-python-csharp — Audit-Vorlage und Steering-Loop-Übergabe (Schritte 2, 3a)

- **Rolle:** Planner · **an:** Architect (A, B), Auftraggeber (C) · **Bezug:**
  [`LH-FA-04`](../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4),
  [`LH-FA-07`](../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren), Baseline-Regelwerk
  `modul-06-roadmap.md` §Wellen-Closure-Prozedur und `modul-08-agentenrollen.md` §Rollen-Sequenz für
  eine Welle (`v6.18.1`)
- **Gemessen auf:** `5e1e3f3e`; Fenster = seit der letzten Welle-Closure `ad2ee8ae` (Self-Close
  `welle-kotlin-skelett`), 481 Commits (`git log --format=%h ad2ee8ae..HEAD | wc -l`)
- **Schritt 1:** erledigt — Verifier-Beleg `2026-10-20-welle-sprachprofile-java-python-csharp-trigger.md`
  (Trigger §3 Punkte 1–3 auf `449eaeff` erfüllt, keine Befunde).
- **Die Closure hält hier an.** Schritte 3b, 3c, 4, 5, 6 laufen nach dem Verdikt zu A und B.

## Schritt 2 — vom Planner erledigt

- **Carveouts:** `CO-001` *Auflösung fällig*, Folge-Slices `slice-113` (`open/`) und `slice-141`
  (`next/`); `CO-002` permanent. Im Fenster unverändert (`git log --oneline ad2ee8ae..HEAD -- docs/plan/carveouts`
  → leer). Keine weiteren (`ls docs/plan/carveouts/`).
- **Bootstrap-aware Gates:** keines (`grep -n 'bootstrap-aware' Makefile *.mk` → leer).

## A — Trigger-Audit, ADR- und Hard-Rule-Zweig (Architect)

`git diff --name-status ad2ee8ae HEAD -- docs/plan/adr harness/conventions.md AGENTS.md`: neu
[ADR-0090](../plan/adr/0090-altbestand-commit-traegt-die-kennung-des-aufrufers.md),
[ADR-0091](../plan/adr/0091-ziel-fassung-regiert-den-sprung-v6180.md),
[ADR-0092](../plan/adr/0092-aufgeloeste-welle-zieht-per-move-nach-done-die-adresse-folgt-im-zeitdokument.md),
[ADR-0093](../plan/adr/0093-ziel-fassung-regiert-den-sprung-v6181.md),
[ADR-0094](../plan/adr/0094-java-skelett-toolchain-und-schicht-aufloesung.md),
[ADR-0095](../plan/adr/0095-python-skelett-toolchain-und-schicht-aufloesung.md),
[ADR-0096](../plan/adr/0096-csharp-skelett-toolchain-und-schicht-aufloesung.md),
[ADR-0097](../plan/adr/0097-csharp-hexslice-richtungs-ordner-klein.md);
`MR-090` bis `MR-093` neu; `AGENTS.md` und die Mehrzahl der `MR`-Dateien geändert (Sprung auf
`v6.18.1`, Sprung-Slices — nicht Gegenstand dieser Welle, im Fenster aber geschehen).

| ADR / MR | Trigger | Planner-Lesart |
|---|---|---|
| [ADR-0094](../plan/adr/0094-java-skelett-toolchain-und-schicht-aufloesung.md) | 1 Gegenbeispiel färbt nicht · 2 Checkstyle/Gradle/JDK nicht grün · 3 Adopter verlangt `hexagonal`/Multi-Modul/Maven | **nicht eingetreten** — Stufe 25 `core-impurity` rot (`Greeting.java:4`) im Trigger-Beleg, Lint-Zahn Stufe 15; kein Adopter-Verlangen |
| [ADR-0095](../plan/adr/0095-python-skelett-toolchain-und-schicht-aufloesung.md) | 1 Gegenbeispiel färbt nicht · 2 pytest/ruff/mypy nicht grün · 3 Adopter verlangt `hexagonal`/Build-Backend/Multi-Projekt | **nicht eingetreten** — Stufe 17 `core-impurity: 1`, Stufe 16 F401/TID252 rot, im Trigger-Beleg gefahren und im ci-Lauf gelesen |
| [ADR-0096](../plan/adr/0096-csharp-skelett-toolchain-und-schicht-aufloesung.md) | 1 Gegenbeispiel färbt nicht / Schreibweise · 2 SDK, xunit, `dotnet format` nicht grün · 3 Adopter verlangt `hexagonal`/NuGet-Analyzer/`.slnx`/Projekt je Schicht | **nicht eingetreten** — Stufe 18 IDE0005/CA1822 rot, Stufe 19 `core-impurity: 1` |
| [ADR-0097](../plan/adr/0097-csharp-hexslice-richtungs-ordner-klein.md) | 1 a-check-Pin zieht das Richtungs-Segment ohne Beachtung der Schreibweise ab (Alternative C erfüllt) · 2 Analyzer/SDK/`IDE1006` färbt kleinen Namensraum-Teil · 3 Lauf-Zahn färbt am Stufen-Ziel nicht · 4 Adopter meldet Mischschreibweise · 5 Auftraggeber stellt C als Anforderung oder Adopter trifft die Lücke · 6 `hexagonal` für C# | **1: nicht entschieden, siehe unten.** 2, 3 nicht eingetreten (Stufe 19 färbt `port-locality`). 4, 5, 6 nicht eingetreten — kein Adopter-Verlangen, keine Anforderung gestellt |
| [ADR-0090](../plan/adr/0090-altbestand-commit-traegt-die-kennung-des-aufrufers.md), [ADR-0092](../plan/adr/0092-aufgeloeste-welle-zieht-per-move-nach-done-die-adresse-folgt-im-zeitdokument.md) | je siehe ADR | nicht eingetreten; diese Closure ist der dritte Welle-Plan-Move nach ADR-0092 — der Architect prüft den Trigger *„ein dritter Welle-Plan-Move findet Nennungen in einer `Accepted`-ADR"* gegen den Move dieser Closure (Planner misst ihn im Move-Commit, nicht vorab) |
| [ADR-0091](../plan/adr/0091-ziel-fassung-regiert-den-sprung-v6180.md), [ADR-0093](../plan/adr/0093-ziel-fassung-regiert-den-sprung-v6181.md) | nächster Sprung · `full-smoke` startet rot · d-check-Pin ändert `codepaths`/`reviews` | nicht eingetreten — `full-smoke` und `gates` grün auf `449eaeff` |
| [`MR-093`](../../harness/conventions.md#mr-093) (a-check-Pin `v0.23.2`) | Pin-Sprung, Prüfverhalten laut Eintrag unverändert | siehe ADR-0097 Trigger 1 |

**Verlangt zu ADR-0097 Trigger 1 (Alternative C).** Der Trigger ist an einen **a-check-Pin-Zug** gebunden
(*„Messung 2 wiederholt: `Ports/Inbound` ohne Hinweis"*). Im Fenster liegt ein a-check-Pin-Zug auf `v0.23.2`
([`MR-093`](../../harness/conventions.md#mr-093), Go-Sicherheitsfix, *Prüfverhalten unverändert*). Ob dabei
Messung 2 wiederholt wurde, steht in keinem Beleg, den der Planner gelesen hat. Planner-Lesart: Trigger
**weder eingetreten noch widerlegt** — der Pin-Zug trägt keine Aussage zur Schreibweise. Verdikt gesucht:
bestätigt mit der benannten Lücke · Messung 2 am Pin `v0.23.2` verlangen (Auftrag Verifier) · Folge-ADR.
Offen steht außerdem der Register-Eintrag `csharp-hexslice-adopter-form-ohne-sensor` (1 Beleg, ADR-0097
Festlegung 4: kein Sensor hält die Verzeichnis-Schreibweise beim Adopter).

## B — Lese-Schritt 3a

`make register-ausgang` → `268 Eintraege, 78 ueber der Schwelle, 0 Befund(e)`. Im Fenster: 30 neue
Einträge, Belege auf 56 Einträge verteilt (`git diff --name-status --diff-filter=A ad2ee8ae HEAD --
docs/plan/planning/observations`). **Kein Eintrag mit ≥ 3 Belegen ohne Ausgang.**

**Zählentscheidungen des Planners (Lesart der 4×-Regel wie in der Vorlage `welle-kotlin-skelett`):** die
Schwelle zählt **erneut**, wenn nach dem Commit, der den Stand auf *verkörpert* setzte, drei weitere
Vorgänge belegt sind; die verkörpernde Slice zählt nicht; je Vorgang eine Datei. Bei Gleichstand an
einem Tag ist die Reihenfolge nicht aufgelöst und die Zahl als Obergrenze genannt.

| Eintrag | Belege | Stand | nach Verkörperung | 4×-Regel |
|---|---|---|---|---|
| `waechter-haelt-config-text-wirkung-im-ziel-ohne-lauf-zahn` | 3 (`java-hexslice-layout`, `python-hexslice-layout`, `csharp-skelett`) | verkörpert `AGENTS.md` §3.6 (`seit slice-python-hexslice-layout`) | 1 (`csharp-skelett`) | **greift nicht.** Das ist **kein viertes Auftreten**: 3 Belege, der dritte liegt nach der Verkörperung. `slice-csharp-hexslice-layout` trägt keinen Beleg; ob sein Review die Klasse berührte, hat der Planner nicht neu gelesen |
| `waechter-misst-die-fixture-statt-der-realen-quelle` | 11 | verkörpert `AGENTS.md` §3.6 (`seit slice-release-schnitt-v025-bereitet-vor`); Verdikt zu B-5 der Vorlage `welle-kotlin-skelett` | 4 Release-Schnitt-Belege seit jenem Verdikt (`v070`, `v080`, `v090`, `v0-10-0`), dieselbe **Unterklasse** | **greift jetzt für die Unterklasse**, siehe B-1 |
| `ci-rennt-gegen-die-publikation-des-gepinnten-releases` | 5 | verkörpert `make release-warten` (`seit slice-ci-wartet-die-publikation-des-gepinnten-releases-ab`, 2026-10-08) | 2 (`v070`, `v0-10-0`) | **greift formal nicht** (2 von 3); **neue Möglichkeit** nach [ADR-0076](../plan/adr/0076-ausgaenge-zu-spec-5-luecken-ebene-und-traeger-offener-saetze.md) Festlegung 7, siehe B-2 |
| `lokaler-full-smoke-scheitert-auf-macos-host` | 4 | verkörpert (Weg, nicht Behebung), Zielort `harness/sensors/mutate.md` | 1 (`slice-benutzerhandbuch-fuehrt-java-python-csharp`) | **greift nach dieser Lesart nicht.** Die `state.md` liest *„ab dem vierten Auftreten"* als 4 Belege insgesamt und nennt die Prosa-Form ausgeschöpft — **zwei Lesarten, der Architect entscheidet**, siehe B-3 |
| `kosten-einer-emittierten-pruefung-im-ziel-ungemessen` | 10 | verkörpert [`MR-089`](../../harness/conventions.md#mr-089) | 6 seit `MR-089` (Skelett und hexslice je Java, Python, C#) | **greift**, siehe B-4 |
| `emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht` | 16 | verkörpert `AGENTS.md` §3.6; Unterklasse *Stufen-Kurzbeschreibung*: kein Sensor, Begründung der Vorlage `welle-kotlin-skelett` B-3 | 3 im Fenster (`java-hexslice-layout`, `csharp-hexslice-layout`: Stufen-Kurzbeschreibung · `sprung-auf-v6181`: DoD-Aussage) | **greift für die Unterklasse nicht** (2 Kurzbeschreibungs-Belege seit dem Verdikt); der dritte Beleg ist eine andere Unterklasse. Zur Kenntnis, kein Verdikt gefordert |
| `pin-digest-ohne-waechter` | 8 | verkörpert (`test/pin-fallbacks.bats`, `make freshness-digest`; `seit slice-doppelt-gefuehrte-werte-bekommen-ihren-kopplungs-sensor`, in `done/` am 2026-10-17) | höchstens 2 (`slice-go-toolchain-pin-folgt-dem-freshness-drift`, `slice-golangci-lint-pin-folgt-dem-freshness-drift`, beide 2026-10-17, Reihenfolge am Tag nicht aufgelöst) | **greift nicht** |
| `handbuch-sprachbaum-ohne-sensor-in-full-smoke` | 3 | verkörpert (Stufe *Handbuch-Baum*, `seit slice-benutzerhandbuch-fuehrt-java-python-csharp`) | 0 | Ausgang gesetzt, kein Auftrag |
| `messzahl-der-dod-liegt-bei-der-uebergabe-nicht-im-baum` | 3 (die drei Skelett-Slices) | geplant: `slice-messzahl-der-dod-liegt-im-lieferstand` (`open/`) | — | Ausgang gesetzt, kein Auftrag |
| `cpp-skelett-erfuellt-die-messmethode-von-lh-qa-02-nicht` | 3 (die drei Skelett-Slices) | geplant: `slice-lh-qa-02-messmethode-bekommt-ihren-change-request` (`open/`) | — | Ausgang gesetzt; Change Request an [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) liegt beim Auftraggeber (C) |

- **B-1 `waechter-misst-die-fixture-…`, Unterklasse *Pin des realen `Makefile` vor der Publikation*.** Vier
  Release-Schnitte in Folge (`v070`, `v080`, `v090`, `v0-10-0`) finden denselben Fund: ein verfälschter
  `TRAEGER_SHA256_*` im realen `Makefile` lässt `test/traeger-fetch.bats` ohne Rot; gebunden wird er erst nach
  der Publikation, vom Aufrufer (`comm` gegen die veröffentlichte `SHA256SUMS`, `make traeger-fetch`). Die
  Prosa-Form (`AGENTS.md` §3.6: *„Träger bleibt der Lauf, der den Wächter schreibt"*) ist ausgeschöpft.
  Planner-Lesart: **vor** der Publikation ist ein Sensor strukturell unmöglich (das Asset existiert nicht);
  **nach** der Publikation ist der Vergleich der sechs Digests ein wiederholbarer, urteilsfreier Schritt, den
  heute der Aufrufer von Hand fährt — baubar als Werkzeug im Stil von `make tap-check`. Verdikt: Sensor
  benennen (Folge-Slice) oder Begründung, warum keiner möglich ist. Berührt `pin-digest-ohne-waechter` nicht
  (anderer Gegenstand: Image-Digest gegen Tag).
- **B-2 `ci-rennt-…`.** Die `state.md` trägt bereits einen **Vorschlag an den Architect, nicht verkörpert**
  (Fälle ohne Ergebnis im Bericht nennen, oder die Probe läuft nach der Publikation). Neue Lage seit der
  Verkörperung: der Worker des Workflows `mutate-branch` hat keinen Warte-Schritt, 9 von 31 Fällen blieben ohne
  Ergebnis. Eine **Möglichkeit** (`make release-warten` auch im Worker-Vorlauf) ist baubar und steht in keinem
  Verdikt. Verdikt: Regel-Verkörperung (Ort: Norm-Artefakt nach Wahl des Architect) · Folge-Slice für den
  Worker-Schritt · beides · keines mit Begründung.
- **B-3 `lokaler-full-smoke-…`.** Beide Lesarten stehen oben. Hängt am Verdikt: ob die `state.md` für
  *„beides steht hier nicht"* einen Sensor oder eine Begründung bekommt, oder die Zählregel (3 *nach* der
  Verkörperung) gilt und der Eintrag unberührt bleibt. Offen ist die **Behebung** (der Treiber wählt auf
  Darwin selbst `artifact-host`, Code-Änderung): Entscheidung beim Auftraggeber (C), kein Folge-Slice angelegt.
- **B-4 `kosten-einer-emittierten-pruefung-…`.** Alle sechs Belege nennen den Laufzeit-Zuwachs **mit** Image-Lage
  (warm) und den kalten Pull als *ungemessen* — [`MR-089`](../../harness/conventions.md#mr-089) wird befolgt, der
  Befund bleibt. Neue Möglichkeit: die Dauer je Stufe aus dem `ci`-Job (frischer Klon, kalt) ist abrufbar
  (`gh run view`), kein Sensor liest sie. Verdikt: Sensor (Stufen-Zeit im `full-smoke`-Log) · Begründung, warum
  keiner möglich ist (`make full-smoke` urteilt über Exit-Codes, nicht Laufzeit) · Eintrag als *befolgt*
  einordnen und kein weiteres Auftreten zählen.

## Verkörperungs-Aufträge an den Architect (3b) — Norm-Artefakte schreibt nur er

| # | Gegenstand | Mögliche Ziele (Wahl beim Architect) |
|---|---|---|
| V-1 | B-1: Sensor benennen oder Begründung für die Release-Schnitt-Unterklasse | Abschnitt der Zeile in `AGENTS.md` §3.6 · Folge-Slice (Planner schneidet nach dem Verdikt) |
| V-2 | B-2: geschärfte Regel zu *Fälle ohne Ergebnis* im Release-Schnitt | `AGENTS.md` / `MR` · Folge-Slice für `make release-warten` im Worker |
| V-3 | B-3: Lesart der 4×-Regel (4 insgesamt oder 3 nach Verkörperung) | Verdikt; ggf. `MR` zur Zählregel |
| V-4 | B-4: Sensor oder Begründung | Verdikt · ggf. `MR-089` nachschärfen (eigener Commit) |
| V-5 | ADR-0097 Trigger 1 (Abschnitt A) | Verdikt: Lücke benennen oder Messung 2 am Pin `v0.23.2` |

## Paarungen der Welle-Slices (Planner, vorab)

Die sechs Slice-Closures haben (a)/(b)/(c) nach ihrem Move gefahren (je §7 *„Paarungen geprüft am …"*). Die
Welle-Closure fährt sie in 3c erneut, samt der zweiten Hälfte von (c) über das ganze Register.

## C — Backlog-Lese-Schritt (Vorschläge, Entscheidung beim Auftraggeber)

`open/` 68, `next/` 4 (`ls … | wc -l`; kein Erwartungswert). Gelesen sind nur Titel und Register-Bezug.

| Gruppe / Slice | Vorschlag | Grund |
|---|---|---|
| `slice-messzahl-der-dod-liegt-im-lieferstand` | bestätigt, Priorität hoch | trägt `messzahl-der-dod-…` (3×), alle drei Skelett-Slices belegt |
| `slice-lh-qa-02-messmethode-bekommt-ihren-change-request` | bestätigt; Entscheidung zum Change Request beim Auftraggeber | trägt `cpp-skelett-erfuellt-…` (3×) |
| `slice-gen-go-kommentar-nennt-die-layouts-aller-sprachen` | bestätigt | Folge-Slice aus Review F-4 des Release-Schnitts, frisch angelegt |
| `slice-113`, `slice-141` | bestätigt | `CO-001` *Auflösung fällig* |
| `slice-151-spec-straten-haben-eine-schreibende-rolle` | bestätigt | in `next/`, Träger für [ADR-0062](../plan/adr/0062-eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-nicht-beantwortet.md) Trigger 2 |
| Mutations-Gruppe und Spezifikations-Gruppe (`slice-festlegungen-*`, `slice-hook-festlegungen-…`) | wie in der Vorlage `welle-kotlin-skelett` Teil C offen geblieben: Konsolidierung prüfen | im Fenster nicht gelesen, nicht entschieden |
| Neue Folge-Slices aus B-1/B-2/B-4 | erst nach dem Verdikt geschnitten | ein Slice entsteht erst nach der Entscheidung |

Nichts stillgelegt, nichts abgelehnt.

## D — Archivierung, Schritt 4

Kein `done/*/archiv.zip` (`ls docs/plan/planning/done/*/archiv.zip 2>/dev/null | wc -l` → 0): `[untergrenze]`
sperrt fail-closed wie bei den Vorgänger-Wellen; die Welle schließt ohne Schritt 4, als Feststellung in der
Ergebnisnotiz. Der Planner fährt `archive-welle --vorschau` in 3c und nennt den tatsächlichen Ausgang dort.
