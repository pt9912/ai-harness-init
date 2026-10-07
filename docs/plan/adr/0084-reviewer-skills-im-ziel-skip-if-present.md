# ADR-0084: Die Reviewer-Skills im Ziel sind Adopter-Boden — skip-if-present statt konvergent

**Status:** Proposed

**Datum:** 2026-10-07

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:** [`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) (Boundary:
adopter-gefüllter Inhalt wird nie überschrieben),
[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
[ADR-0007](0007-bootstrap-phasen.md) (teilweise abgelöst, siehe §Entscheidung 1),
[ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md),
[ADR-0054](0054-emittierter-commit-traeger-skip-if-present.md) (Form der Meldung)

**Schärft:** [`spec/architecture.md` §5](../../../spec/architecture.md#5-idempotenz-fragment-assembly-und-resume)
(Idempotenz-Klassifikation: „Skills" verlässt die konvergente Aufzählung) ·
[`ARC-006`](../../../spec/architecture.md#1-komponenten-übersicht) (Commands- und Skills-Emitter).

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md` §Ziel-Form: ADR (MADR); `modul-08-agentenrollen.md`
§Welche Rolle braucht welche Artefaktklasse.

---

## Kontext

**Ist.** `Templates` in `internal/emit/templates.go` schreibt `.harness/skills/*` konvergent
(`writeFileMode`), den übrigen Satz skip-if-present — nach der Klassen-Tabelle von
[ADR-0007](0007-bootstrap-phasen.md), Zeile der konvergenten Infrastruktur. Jeder Lauf ersetzt
damit `.harness/skills/reviewer.md` und `.harness/skills/closure-note-reviewer.md` durch die
Vorlage.

**Die Vorlage ist eine Ausfüll-Vorlage.** `reviewer.template.md` (v6.17.0) sagt *„Kopiere nach
`.harness/skills/reviewer.md`, ersetze `<Platzhalter>`"*; der Skill trägt laut
`modul-08-agentenrollen.md` das repo-spezifische Wissen, das aus keinem Artefakt ableitbar ist. Ein
gefüllter Skill ist Adopter-Inhalt, und [`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) Boundary verbietet, ihn zu überschreiben. Ein
Adopter hat genau das erlebt (v0.2.8: ausgefüllter Skill vom Re-Lauf überschrieben; CR-2, v0.4.0;
Auftraggeber-Entscheidung 2026-10-07: umsetzen). Im Dogfood gehört der Skill der Reviewer-Rolle
(ADR-0028); dieses Repo emittiert sich nicht selbst, die Entscheidung betrifft nur das Ziel.

## Entscheidung

Wir wählen **skip-if-present für beide Skills, mit Meldung je stehengelassener Datei**.

**1. Klasse.** `.harness/skills/reviewer.md` und `.harness/skills/closure-note-reviewer.md` werden
nur an einem freien Pfad abgelegt. Das löst aus [ADR-0007](0007-bootstrap-phasen.md) allein den
Eintrag `.harness/skills/*` der konvergenten Zeile ab; alles Übrige dort gilt fort, ADR-0007 bleibt
byte-gleich. Die Marke in ihrer Index-Zeile setzt der Accept-Übergang dieser ADR.

**2. Der Lauf nennt, was er stehen lässt** — je Skill den Pfad und die mitgelieferte Vorlage unter
`.harness/baseline/<tag>/templates/.harness/skills/` zum Abgleich, in der Form der Meldung zum
Commit-Träger ([ADR-0054](0054-emittierter-commit-traeger-skip-if-present.md)).

**3. Die Baum-Aussage nennt sie.** Der Absatz *„Gesagt ist, was ein frisches Repo bekommt"* der
emittierten Baum-Aussage (Erzeuger `internal/emit/baumaussage.go`) zählt die zwei Skills zu den
Pfaden, die der Lauf nennt; der Satz *„Einen einzigen solchen Pfad nennt der Lauf"* fällt.

**4. Akzeptiertes Negativ:** ein Baseline-Sprung heilt den Skill nicht mehr — auch einen
unausgefüllten nicht. Die neue Vorlage liegt vendored im Ziel, und der Lauf nennt sie (Punkt 2);
der Abgleich ist Handarbeit des Adopters, wie bei jedem anderen Ausfüll-Dokument.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — nichts tun | Baseline-Sprung heilt den Skill | überschreibt Adopter-Inhalt bei jedem Lauf; bricht [`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) Boundary; Vorfall belegt |
| B — konvergent, nur wenn die Datei noch der früheren Emission gleicht | heilt den unausgefüllten, schont den gefüllten | braucht die frühere Fassung oder eine Marke — eine dritte Klasse in einer zweiklassigen Ordnung, für zwei Dateien; dieselbe Abwägung wie ADR-0054 Option C |
| C — Skills nicht emittieren, nur auf die vendored Vorlage zeigen | kein Überschreiben möglich | der Reviewer startet ohne Skill-Datei und driftet (`modul-08-agentenrollen.md`); bricht den bewachten Emissions-Bestand |
| **D — skip-if-present mit Meldung** | Adopter-Inhalt überlebt; Klasse wie jedes Ausfüll-Dokument; Meldung macht die Vorlage sichtbar | Sprung-Heilung entfällt (§Entscheidung 4) |

## Konsequenzen

- Positiv: ein gefüllter Skill überlebt jeden Re-Lauf; die Klasse folgt der Vorlage.
- Negativ: §Entscheidung 4.
- Folgepflicht: ein Slice (Planner) — Klasse in `internal/emit/templates.go`, Meldung,
  Baum-Aussage, `spec/architecture.md` §5 nachziehen, Test und Mutationsfall umkehren,
  Selbstprüfung; Release `v0.5.0` (minor: Verhalten des Re-Laufs ändert sich).

## Fitness Function (falls maschinell prüfbar)

| Tooling | Regel | Make-Target |
|---|---|---|
| Go-Test (ersetzt `TestTemplates_SkillsConvergent`) | ein veränderter Skill überlebt den zweiten Lauf byte-gleich; ein fehlender wird angelegt | `make test` |
| Selbstprüfung des Ziels | beide Fälle: Re-Lauf über gefülltem Skill → unverändert und gemeldet; über fehlendem → angelegt | `make selbstpruefung` (kein Gate), gefahren von `make full-smoke` |
| Mutationsfall (Nachfolger von `test/mutations/53-skills-konvergent.sh`) | die Skills wieder konvergent schreiben → der Go-Test wird rot | `make mutate` |

## Re-Evaluierungs-Trigger

- Der Kurs trennt den Skill in einen tool-eigenen und einen Adopter-Teil (zwei Dateien) — dann
  kann der tool-eigene Teil wieder konvergent werden.
- Eine Beobachtung *„veraltete Skill-Vorlage im Ziel unbemerkt"* erreicht 3× im
  Beobachtungs-Register — dann Option B neu prüfen.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-10-07 | Proposed | Auftraggeber-Entscheidung zu CR-2 eines Adopters (v0.4.0) |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0084` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).
