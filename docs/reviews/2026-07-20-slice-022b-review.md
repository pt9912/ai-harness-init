# Review-Report: slice-022b (Embed raus) — 2026-07-20

**Review-Art:** Code — geprüft wird der Diff gegen **Plan + ADR + Hard Rules**
(Modul 10 §Drei Review-Arten). **Nicht** geprüft: die DoD-Abhakung — das ist
die Verifikation (Modul 11, getrennter Kontext).

**Gegenstand:** `f1b9b20` („slice-022b: Embed raus — die gefetchte Baseline ist
einzige Template-Quelle"), 19 Dateien, +158/−1553. Eintritts-Move davor:
`15b355f` (reiner Move + drei Pfad-Korrekturen, kein Inhalt am Slice).

**Skill:** `.harness/skills/reviewer.md` @ 1.2.0 · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-4-8[1m] · **Datum:** 2026-07-20

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde — ohne
diese Liste ist der Lauf nicht reproduzierbar):

- Slice-Plan: `docs/plan/planning/in-progress/slice-022b-embed-raus.md`
- Aktive ADRs: `ADR-0005` (Ziel-Repo-Distribution, Accepted; Folgepflicht
  „Embed entfernen"), berührt `ADR-0004` (Durchsetzungs-Emission)
- Berührte `LH-*`: `LH-FA-02` (zweiklassige Ablage), `LH-FA-05`, `LH-FA-06`,
  `LH-QA-01`, `LH-QA-03`
- Konventionen: `MR-007`, `MR-008`, `MR-009`
- `AGENTS.md` §3 (Hard Rules 3.1–3.5)
- **Vorherige Findings am gleichen Modul:** `docs/reviews/2026-07-20-slice-022a-review.md`
  und `-re-review.md`. Zwei Klassen sind hier einschlägig und wiederholen sich:
  **(a)** „Zusage/Test-Name greift weiter als die Abdeckung" (022a M1/N1, N2),
  **(b)** „Fixture divergiert von der Realität, die sie nachbildet" (022a N5).

**Ausgeführte Sensoren (eigener Lauf, nicht übernommen):**

| Lauf | Ergebnis |
|---|---|
| `make gates` | **EXIT=0** — baseline-verify OK · d-check 82 Dateien/0 Befunde · golangci-lint 0 issues · bats **64 ok** · go-Tests cmd/emit/fetch ok |
| Echter Bootstrap (`docker build --target artifact` → `--lang go --name SmokeProj` in tmp-Repo) | EXIT=0; emittierter Baum Datei für Datei gegen die gefetchte Baseline verglichen |
| Mutations-Sonde (Kopie in `/tmp`, **kein** Repo-Code geändert): `inScope` auf `return true` neutralisiert, `go test ./internal/emit/` im Container | siehe **F-1** |
| Regel-Simulation der `inScope`/`singletonTarget`-Logik über den realen 21-Datei-Satz (shell) | 15 in scope / 6 out — deckungsgleich mit dem Ist des Bootstraps |

---

## Findings

Jedes Finding folgt dem **§Output-Schema des Reviewer-Skills** — der
verbindlichen Single Source of Truth. Die Felder unten sind nur
**gespiegelt** (Bequemlichkeit beim Ausfüllen), nicht neu definiert; bei
Abweichung gilt der Skill bzw. dessen Quelle
[Kurs Modul 10 §Output-Schema](https://github.com/pt9912/ai-harness-course/blob/v3.5.0/kurs/de/04-qualitaet/modul-10-review-harness.md#worked-example-eine-reviewer-skill-datei-schreiben).

### HIGH

### F-1 — `TestTemplates_AusserScopeNichtEmittiert` kann die Regel, die es laut eigenem Kommentar bewacht, nicht rot färben: alle sieben Zusicherungen prüfen den **Quell**-Pfad, nie den Pfad, den der Code schreiben würde

- `kategorie`: **HIGH**
- `quelle`: `LH-QA-01` (kein stilles Grün — der Fall sitzt **in** `make test`,
  einem Gate) · `LH-FA-05` · `LH-FA-06`/`ADR-0004` · Reviewer-Skill §HIGH
  (Stilles-Grün-Pfad in einem Gate) + §Kontext-Eskalation (Gate-Pfad ⇒ eine
  Stufe höher) · Wiederholung der 022a-Klasse N2
- `pfad`: `internal/emit/templates_test.go:141-153` (die Fall-Tabelle) ·
  `:131-135` (der Kommentar „ist der Kern von slice-022b") ·
  `internal/emit/templates.go:124-132` (`singletonTarget`)
- `befund`: Der Test stat't für jeden Ausschluss den **Quell**-Namen
  (`project-readme.template.md`, `.harness/skills/reviewer.template.md`,
  `README.md`, `.d-check.yml`, `Makefile`). Fiele der jeweilige `inScope`-Zweig
  weg, schriebe der Code die Datei aber unter ihrem **Singleton-Ziel**
  (`project-readme.md`, `.harness/skills/reviewer.md`, `README.md.md`,
  `.d-check.yml.md`, `Makefile.md`) — die geprüften Pfade blieben in **jedem**
  dieser Fälle abwesend, der Test grün. Vorgeführt an einer Wegwerf-Kopie im
  gepinnten Image: mit `func inScope(rel string) bool { return true }` (Regel
  vollständig entfernt) laufen `TestTemplates_AusserScopeNichtEmittiert`,
  `TestTemplates_Layout`, `TestTemplates_RecurringVerbatim` und
  `TestTemplates_StampAndStrip` **PASS**, während im Zielverzeichnis
  `.harness/skills/reviewer.md`, `.harness/skills/closure-note-reviewer.md`,
  `project-readme.md`, `README.md.md`, `.d-check.yml.md` und `Makefile.md`
  landen — also genau die vier Grenzen (`LH-FA-05`, `LH-FA-06`, Set-Index,
  Tool-eigene Config), die der Slice als seinen Kern deklariert. Rot wird
  einzig `TestTemplates_LeereQuelle`, und der misst eine **andere** Eigenschaft
  (er fällt nur, weil seine `irgendwas.txt`-Fixture nun in-scope ist) — die
  Rot-Färbung ist Zufall, nicht Abdeckung. Der Diff verschiebt die Filterregel
  aus einem gelöschten bats-Wächter in Produktivcode und benennt genau diesen
  Test als ihren Sensor; der Sensor ist nicht an sie gekoppelt.
- `verifizierbar`: **ja** — reproduzierbar: `internal/emit` kopieren,
  `inScope` auf `return true` setzen,
  `docker run --rm -v <kopie>:/src -w /src golang:1.26.4 go test -run 'TestTemplates_' ./internal/emit/`;
  gemessen `PASS` für alle vier Fälle. Ein Fall, der stattdessen den
  Ist-Bestand des Zielverzeichnisses gegen die erwartete 15er-Menge stellt,
  wäre unter derselben Mutation rot.

### MEDIUM

### F-2 — Der Empty-Source-Guard deckt die Wurzelungs-Klasse nicht ab, die sein Kommentar und der Test-Name ihm zuschreiben; jede **Vorfahren**-Wurzelung ist nicht-leer und umgeht zusätzlich beide Pfad-verankerten Ausschlüsse

- `kategorie`: **MEDIUM**
- `quelle`: `LH-QA-01` (die Zusage „kein stilles Grün" trägt hier nicht so weit
  wie behauptet) · `LH-FA-05` · `LH-FA-06`/`ADR-0004` · Reviewer-Skill §MEDIUM
  (Spec-Treue-Lücke einer Messmethode) · Wiederholung der 022a-Klasse N1/N2
- `pfad`: `internal/emit/templates.go:70-74` (Guard + Kommentar „Ein falsch
  gewurzeltes src emittierte sonst stillschweigend NICHTS") ·
  `internal/emit/templates.go:44-47` (`rel == "project-readme.template.md"`,
  `strings.HasPrefix(rel, ".harness/skills/")`) ·
  `internal/emit/templates_test.go:173-183` (`TestTemplates_LeereQuelle`,
  Kommentar „eine falsch gewurzelte **oder** leere Quelle") ·
  `cmd/ai-harness-init/main.go:134`
- `befund`: `len(plan) == 0` feuert ausschließlich, wenn der gewalkte Baum
  **kein** `*.template.md` enthält — also nur für eine Wurzelung auf einen
  template-freien Zweig (z. B. `…/<tag>/regelwerk`). Wird stattdessen auf einen
  **Vorfahren** des `templates/`-Verzeichnisses gewurzelt (`…/<tag>`,
  `…/baseline`, oder das Zielrepo-Root), ist das Ergebnis nicht-leer, der Guard
  schweigt und der Bootstrap meldet Erfolg. Am realen Satz gemessen (Wurzel
  `.harness/baseline/v3.5.0`, Regel-Simulation): **18** Treffer statt 15, alle
  unter einem `templates/`-Präfix — und weil beide Ausschlüsse am FS-**Root**
  verankert sind (Gleichheit bzw. `HasPrefix`), greift für
  `templates/project-readme.template.md` und
  `templates/.harness/skills/*.template.md` **keiner** von beiden: sie würden
  als Singletons emittiert (`templates/project-readme.md`,
  `templates/.harness/skills/reviewer.md`) und damit die `LH-FA-05`- und
  `LH-FA-06`-Grenze verletzen. Auch die `roadmap`-Sonderbehandlung
  (`singletonTarget`) greift dann nicht mehr. Der Kommentar am Guard und der
  Kommentar am Test setzen „falsch gewurzelt" mit „leer" gleich; diese
  Gleichsetzung ist falsch.
- `verifizierbar`: **ja** — ein Fall, der `emit.Templates` mit einem `fs.FS`
  aufruft, dessen Wurzel eine Ebene über `templates/` liegt, und den
  Ist-Bestand des Ziels zusichert, wäre heute rot bzw. deckte die
  Pfad-Verletzung auf. Heute existiert kein solcher Fall.

### F-3 — Die Wurzelung `os.DirFS(<target>/.harness/baseline/<tag>/templates)` ist von **keinem** Test und von **keinem** Nicht-Gate-Verify zugesichert; `emit.Templates` aus `run()` zu entfernen färbt nichts rot

- `kategorie`: **MEDIUM**
- `quelle`: `LH-QA-01` (Prüftiefe sinkt unbemerkt) · Reviewer-Skill §MEDIUM
  (Abdeckungslücke) · direkte Wiederholung von 022a **M2** („bis hierher
  behauptete KEIN Test, dass `run()` … überhaupt ablegt")
- `pfad`: `cmd/ai-harness-init/main.go:130-138` ·
  `cmd/ai-harness-init/main_test.go:144-197` · `harness/tools/smoke.sh:37-53`
- `befund`: Alle `run()`-Fälle, die den Fetch passieren
  (`TestRun_EmitFehler`, `TestRun_BaselineUndVerifierLanden`), enden
  **bewusst** mit Exit 1 an `emit.DocGate` — also **vor** dem
  `emit.Templates`-Aufruf. Kein Go-Test und kein bats-Fall beobachtet, dass
  `run()` Templates ablegt oder mit welcher Wurzel. `make smoke` prüft
  nachweislich nur (1) Bootstrap-Exit, (2) `.harness/skeleton/Makefile`
  vorhanden, (3) das emittierte `d-check` läuft — **keine** Zusicherung über
  emittierte Templates; die im Test-Kommentar
  (`templates_test.go:114-116`) behauptete „Byte-Gleichheit mit dem REALEN
  Kurs-Satz belegt seit slice-022b `make smoke`" steht so nicht im
  Smoke-Skript. Zusammen mit **F-2** heißt das: der einzige Sensor für die
  Wurzelung ist der Empty-Guard, und der fängt nur eine von mehreren
  Wurzelungs-Klassen. Erschwerend liegt die Layout-Kenntnis
  `<base>/<tag>/{regelwerk,templates}` doppelt (in `internal/fetch/baseline.go`
  und neu in `cmd/…/main.go:134`), ohne dass `fetch.Baseline` den platzierten
  Pfad zurückgäbe — die im Kommentar (`main.go:130-133`) benannte
  Reihenfolge-Kopplung „Der Baseline-Schritt oben MUSS deshalb vorher gelaufen
  sein" ist damit rein prosaisch, nicht durch Signatur oder Datenfluss
  erzwungen.
- `verifizierbar`: **ja** — `emit.Templates(...)` aus `run()` auskommentieren
  und `make gates` fahren: heute grün. Gegenprobe im echten Bootstrap: die
  Templates landen (selbst gemessen), aber kein Gate belegt es.

### F-4 — Für die Klasse „neues **wiederkehrendes** Upstream-Template" ist der gelöschte Wächter ein Deckungsverlust: `isRecurring` bleibt eine 5er-Aufzählung, und die Fehlklassifikation wird jetzt still statt laut

- `kategorie`: **MEDIUM**
- `quelle`: `LH-FA-02` (rank-1: wiederkehrende Templates bleiben verbatim
  co-located) · Slice-Plan §6 („Deckungsverlust beim Löschen des
  Drift-Wächters … das ist der Punkt, an dem ‚entfällt ersatzlos' zu billig
  wäre") · Reviewer-Skill §MEDIUM
- `pfad`: `internal/emit/templates.go:15-22` (`isRecurring`) ·
  `internal/emit/templates.go:32-36` (die Zusage „kann strukturell nicht mehr
  entstehen") · `internal/emit/templates_test.go:156-171`
  (`TestTemplates_NeuesUpstreamTemplateFliesstMit`)
- `befund`: Die REGEL macht die Klasse „Baseline gebumpt, Emit nicht
  nachgezogen" nur für die **Singleton**-Hälfte gegenstandslos. Die
  **Klassifikation** hängt weiter an einer hart aufgezählten 5er-Liste von
  Basenamen. Käme upstream ein sechstes wiederkehrendes Template hinzu, flösse
  es mit — aber als **Singleton**: Hinweis-Block gestrippt, nach `.md`
  umbenannt, damit genau die von `LH-FA-02` verlangte Zweiklassigkeit
  verletzt. Vor diesem Diff hätte die Vollständigkeits-Achse von
  `test/skel-drift.bats` in derselben Situation **rot** gefärbt (das Template
  fehlte im Embed) und eine menschliche Klassen-Entscheidung erzwungen; danach
  passiert dasselbe Ereignis geräuschlos und falsch. `TestTemplates_Neues…`
  fügt mit `spec/glossar.template.md` ausschließlich einen Singleton hinzu und
  belegt damit nur die abgedeckte Hälfte — die Test-Zusage („ein Template, das
  niemand kennt, kommt trotzdem an") greift weiter als das Gemessene.
  Zusätzlich matcht `isRecurring` über `path.Base`, ist also ortsunabhängig:
  ein gleichnamiges Template an anderer Stelle wechselte die Klasse mit.
- `verifizierbar`: **ja** — ein Fall, der der Fixture ein sechstes
  wiederkehrendes Template (z. B. `docs/plan/planning/experiment.template.md`)
  hinzufügt und verbatim-Ablage zusichert, ist heute rot.

### LOW

### F-5 — Der Fall `{"readme.md", …}` kann per Konstruktion nicht fehlschlagen

- `kategorie`: **LOW**
- `quelle`: Reviewer-Skill §LOW (latente Wartungsfalle) · `LH-QA-01` (Geist)
- `pfad`: `internal/emit/templates_test.go:144`
- `befund`: Kein Pfad im Code erzeugt jemals ein kleingeschriebenes
  `readme.md`: `project-readme.template.md` würde als
  `project-readme.md` landen, die Set-Index-`README.md` als `README.md.md`
  (siehe **F-1**). Die Zusicherung ist damit auf einem case-sensitiven
  Dateisystem nicht falsifizierbar und zählt in der Fall-Tabelle dennoch als
  eine von sieben „je mit Begründung" belegten Ausschluss-Zeilen.
- `verifizierbar`: nein — kein Gate misst Mutations-Empfindlichkeit einzelner
  Fälle; der Befund folgt aus `singletonTarget`.

### F-6 — Doku-Drift: `welle-02` beschreibt den Drift-Wächter weiter im Präsens als aktiven Bewacher

- `kategorie`: **LOW**
- `quelle`: Reviewer-Skill §LOW (Doku-Drift) · Slice-Plan §2 („kein stiller
  Tombstone")
- `pfad`: `docs/plan/planning/welle-02-fetch-und-readme.md:72-74`
- `befund`: Die Welle sagt weiter „der Zwischenzustand zweier Template-Quellen
  … bleibt von `test/skel-drift.bats` bewacht, bis das Embed fällt" — das
  Embed ist mit diesem Commit gefallen und die Datei gelöscht. Der Slice-Plan
  §2 verlangte für den gelöschten Wächter ausdrücklich „die Referenzen darauf
  sind bereinigt bzw. über `codepaths.ignore-refs` deklariert — kein
  `codepath-missing`, aber auch **kein stiller Tombstone**"; gewählt wurde
  keine der beiden Varianten. Dass `d-check` nicht anschlägt, ist selbst
  gemessen korrekt (`codepaths.roots: [spec, docs, harness]` — `test/` ist
  keine Root, `make gates` EXIT=0) und die Begründung im Commit gegen einen
  `ignore-refs`-Eintrag trägt `MR-009` („keine breite oder leere Liste");
  die Präsens-Aussage in `welle-02` bleibt davon unberührt stehen.
- `verifizierbar`: nein — `docs-check` prüft `test/`-Referenzen nicht (genau
  das ist die Beobachtung).

### INFO

### F-7 — Ausschluss-Kriterium und Ausschluss-Gründe fallen auseinander: drei sachlich verschiedene Fälle hängen an einem Suffix-Test

- `kategorie`: **INFO**
- `quelle`: Maintainability · `ADR-0005` (Herkunftsklassen-Tabelle)
- `pfad`: `internal/emit/templates.go:38-43`
- `befund`: Der Kommentar nennt drei eigenständige Gründe (Tool autoriert seine
  eigene `.d-check.yml`; `Makefile` gehört dem Skelett-Generator; Set-Index-
  README ist nie ein Ziel-Artefakt), das Prädikat ist aber ein einziger
  `!HasSuffix(".template.md")`. Die drei Fälle sind heute **nur** deshalb
  ausgeschlossen, weil der Kurs sie nicht `*.template.md` nennt — nicht wegen
  der genannten Gründe. Umgekehrt fiele ein upstream neu hinzukommendes
  Ziel-Artefakt mit anderer Namenskonvention (die der Satz mit `Makefile` und
  `.d-check.yml` bereits kennt) ohne Signal heraus; die Commit-Aussage „ein
  upstream neu hinzugekommenes Template fließt automatisch mit" gilt nur unter
  der undokumentierten Annahme, dass alle künftigen Ziel-Templates dem
  `*.template.md`-Muster folgen.
- `verifizierbar`: nein — dokumentationswürdige Annahme, kein heutiges Versagen.

## Negativbefunde

<!-- Eine Zeile pro betrachtetem Bereich. -->

- **geprüft, ohne Befund — Korrektheit und Vollständigkeit von `inScope` gegen
  den realen v3.5.0-Satz:** Die Regel wurde Datei für Datei über alle **21**
  Dateien simuliert und zusätzlich am **echten Bootstrap** verifiziert. Ergebnis
  identisch und exakt der Zuschnitt des alten Embeds: **15 in scope** (10
  Singletons + 5 wiederkehrende), **6 out** (`README.md`, `.d-check.yml`,
  `Makefile`, `project-readme.template.md`, beide `.harness/skills/*`). Keine
  Datei wird emittiert, die nicht sollte; keine fehlt. Im tmp-Repo gemessen:
  `README.md`, `project-readme.md`, `Makefile` und `.harness/skills/` existieren
  **nicht**, die emittierte `.d-check.yml` trägt den Kopf „emittiert von
  ai-harness-init" (Tool-eigene, nicht die des Kurses).
- **geprüft, ohne Befund — `isRecurring` gegen `LH-FA-02`:** Die fünf Namen
  (`NNNN-titel`, `slice`, `welle`, `carveout`, `review-report`) stimmen exakt
  mit der Aufzählung in `spec/lastenheft.md` §`LH-FA-02` und mit dem realen
  Satz überein. Der Wechsel `filepath.Base` → `path.Base` ist für ein `fs.FS`
  (Slash-Pfade) korrekt. (Der Rest der Klassen-Frage steht in **F-4**.)
- **geprüft, ohne Befund — Treue der Fixture `courseSet()` zum realen Satz
  (Klasse 022a-N5):** Alle **21** Pfade stimmen 1:1 mit
  `.harness/baseline/v3.5.0/templates/` überein — keine fehlende, keine
  erfundene Datei, korrekte Groß-/Kleinschreibung, `.harness/skills/` mit
  beiden Dateien. Die getesteten Eigenschaften sind am realen Satz nachgemessen:
  alle 15 in-scope-Dateien tragen genau einen `> **Template-Hinweis.**`-Block
  (Voraussetzung von `StripHintBlock`), und `<Projektname>` kommt in 6 der 10
  Singletons vor (die Fixture setzt es in allen 10 — Stempeln ist dort ein
  No-op, kein Fehlschluss). Der einzige Unterschied ist der trivialisierte
  Datei-**Inhalt**; keine der geprüften Eigenschaften hängt daran.
- **geprüft, ohne Befund — Verbatim-Zusage der wiederkehrenden Templates am
  realen Baum:** Alle fünf im tmp-Repo emittierten `.template.md` sind
  `diff`-identisch zu ihrem Zwilling in der gefetchten
  `.harness/baseline/v3.5.0/templates/`. Die Eigenschaft hält; nur ihr
  behaupteter *Sensor* ist falsch benannt (**F-3**).
- **geprüft, ohne Befund — Singleton-Transformation am realen Baum:**
  `spec/lastenheft.md` im tmp-Repo enthält `SmokeProj` (1×), **kein**
  `<Projektname>` und **kein** `Template-Hinweis`. Der `roadmap`-Sonderfall
  landet korrekt unter `docs/plan/planning/in-progress/roadmap.md`, nicht flach.
- **geprüft, ohne Befund — `ADR-0005`-Konformität:** Die Folgepflicht „Embed
  (`internal/emit/skel`) entfernen" ist eingelöst (15 Dateien gelöscht,
  `//go:embed` weg, kein zweiter Template-Pfad im Baum — `grep` über
  `internal/`/`cmd/` findet nur historische Kommentar-Erwähnungen). Die
  Herkunftsklassen-Tabelle wird eingehalten: Regelwerk+Doc-Templates aus dem
  Fetch, `.d-check.yml`/`d-check.mk` weiter generiert (`MR-010`), Skelett
  weiter gefetcht/gestaged. Die Fitness Function „Drift-Test | Ziel-Baseline-
  Content == Kurs-Version | `make test`" überlebt die Löschung von
  `skel-drift.bats`: sie wird von `TestDefaultBaselineSHA256_MatchesMakefile`,
  `TestDefaultTag_MatchesBaseline` und `test/sources-pin.bats` getragen, die im
  Lauf grün waren.
- **geprüft, ohne Befund — Hard Rule 3.2 (Lint-Suppression-Verbot):** Der Diff
  fügt kein `//nolint` und kein `# shellcheck disable` hinzu; der einzige
  `nolint`-Treffer ist eine **gelöschte** Zeile aus dem Template-Text
  `internal/emit/skel/AGENTS.template.md`. `golangci-lint` 0 issues,
  `shellcheck` sauber.
- **geprüft, ohne Befund — Hard Rule 3.3 (`git mv` + Inhalt = zwei Commits):**
  Der Eintritts-Move `15b355f` bewegt `slice-022b-embed-raus.md`
  `open/`→`in-progress/` mit **0** Inhaltsänderung (die drei begleitenden
  Zeilen sind Pfad-Korrekturen in *anderen* Dateien); `f1b9b20` enthält keinen
  Rename. Die Löschungen sind Löschungen, keine Moves.
- **geprüft, ohne Befund — Hard Rules 3.1/3.5 (halluzinierte Gates /
  Gate-Lockerung ohne ADR):** Kein Gate-Name kommt hinzu oder fällt weg; der
  bats-Rückgang **67 → 64** entspricht exakt den drei Fällen des gelöschten
  Wächters, deren *Gegenstand* (das Embed) verschwindet — von `ADR-0005`
  ausdrücklich als Folgepflicht verlangt, also keine Lockerung ohne ADR. Die
  `.d-check.yml` wird nicht angefasst; keine Schwelle gesenkt. (Die *Prüftiefe*
  betreffenden Befunde stehen als **F-1**/**F-3**/**F-4**.)
- **geprüft, ohne Befund — Hard Rule 3.4 (ADRs immutable):** Keine ADR im Diff.
- **geprüft, ohne Befund — `MR-009`-Konformität der `.d-check.yml`-Entscheidung:**
  Die Plan-Abweichung (kein `ignore-refs`-Eintrag für den gelöschten Wächter)
  ist im Commit begründet und selbst nachgemessen korrekt: `codepaths.roots`
  ist `[spec, docs, harness]`, `test/` ist keine Root, `docs-check` läuft mit
  82 Dateien / 0 Befunden. Ein Eintrag für etwas, das das Gate nicht prüft,
  wäre die von `MR-009` verbotene unbelegte Liste. Die Prosa-Seite der
  Plan-Zeile bleibt offen (**F-6**).
- **geprüft, ohne Befund — `MR-008` für dieses Artefakt:** Der Report entstand
  per `cp` aus
  `.harness/baseline/v3.5.0/templates/docs/reviews/review-report.template.md`,
  nicht hand-modelliert.
- **geprüft, ohne Befund — Force-/Boundary-Verhalten:** Der Pre-Flight vor dem
  ersten Schreiben ist unverändert (`LH-FA-01` Boundary-AC); der neue
  Empty-Guard sitzt **vor** dem Pre-Flight, verschiebt die Reihenfolge also
  nicht zum Schlechteren. `TestTemplates_ForceBoundary` deckt beide Richtungen.
- **geprüft, ohne Befund — `LH-QA-03` (minimale Abhängigkeiten):** Der Diff
  fügt keine Modul-Abhängigkeit hinzu (`go.mod` unberührt); die neuen Imports
  `io/fs`, `path`, `testing/fstest` sind Stdlib. Der Bootstrap braucht weiter
  nur `git + docker` — selbst gefahren.
- **geprüft, ohne Befund — Hermetik der Tests:** `fstest.MapFS` ersetzt den
  Embed vollständig; `internal/emit`-Tests brauchen kein `.harness/` und laufen
  in der go-test-Stage (im eigenen `make gates`-Lauf gesehen). Die
  `.dockerignore`-Begründung des Plans §6 ist damit sauber aufgelöst.

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 1 |
| MEDIUM | 3 |
| LOW | 2 |
| INFO | 1 |

- **HIGH:** F-1 zentraler Ausschluss-Test ist mutations-blind
- **MEDIUM:** F-2 Empty-Guard deckt Wurzelungs-Klasse nicht ab · F-3 Wurzelung
  von `cmd` nach `emit` ohne jede Zusicherung · F-4 Deckungsverlust für neue
  *wiederkehrende* Upstream-Templates
- **LOW:** F-5 nicht-falsifizierbarer Fall · F-6 Präsens-Doku-Drift in `welle-02`
- **INFO:** F-7 Suffix-Kriterium trägt drei verschiedene Gründe

## Verdikt

**Merge-blockierend: ja** — wegen F-1 (HIGH) und F-2/F-3/F-4 (MEDIUM).

Zur Einordnung, damit das Verdikt nicht mit einem Sach-Urteil verwechselt wird:
**die Filterregel selbst ist korrekt und vollständig.** Am realen 21-Datei-Satz
und am echten Bootstrap nachgemessen emittiert der Diff exakt die richtigen 15
Dateien in der richtigen Klasse an der richtigen Stelle, byte-identisch wo
verbatim gefordert. Die ADR-0005-Folgepflicht ist sauber eingelöst, die Hard
Rules sind eingehalten, `make gates` ist grün.

Blockierend ist die **Sensorik**, nicht das Verhalten: der Diff nimmt einen
Wächter weg und benennt drei Nachfolge-Sensoren — den Ausschluss-Test, den
Empty-Guard und `make smoke`. Alle drei tragen weniger, als der Commit und die
Code-Kommentare ihnen zuschreiben (F-1, F-2, F-3), und für eine benannte
Deckungs-Frage des Plans §6 tragen sie gar nichts (F-4). Der Slice-Plan §6 hat
genau diesen Ausgang vorweggenommen: „das ist der Punkt, an dem ‚entfällt
ersatzlos' zu billig wäre". Der Commit argumentiert, die REGEL mache den
Ersatz-Sensor überflüssig — das stimmt für die Singleton-Vollständigkeit und
nur dafür.

**Steering-Loop-Signal (Modul 10 §Kontext-Eskalation).** F-1, F-2, F-3 und F-4
sind vier Instanzen **derselben** Klasse: *eine Zusage in Kommentar, Test-Name
oder Commit-Prosa greift weiter als das, was der Sensor misst.* Dieselbe Klasse
trug in slice-022a die Nummern M1, N1 und N2, und der Implementer hat sie als
Steering-Loop-Eintrag protokolliert. Sie ist damit nicht mehr als Einzelbefund
zu behandeln: es ist die dritte Sitzung in Folge, und diesmal steht die Klasse
**im Gate selbst** statt nur im Kommentar. Die Rückkante gehört an den Guide
(Sensor-Design: „welche Mutation färbt diesen Test rot?" als Pflicht-Frage vor
dem Löschen eines Wächters), nicht in einen weiteren Findings-Durchlauf.

**Übergabe:** Findings gehen an die Implementation (Rückkante
Review → Plan bei Plan-Defekt). Der Report ersetzt keine
Verifikation — DoD-/Spec-Konformität prüft der Verifier separat
(Modul 11; anderes Prüf-Artefakt, anderer Eingabe-Kontext).
