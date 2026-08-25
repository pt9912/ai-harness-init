# AGENTS.md — Briefing für AI-Coding-Agenten

## 1. Was diese Datei ist

Onboarding-Briefing für jede AI-Session, die in diesem Repo Code oder
Doku ändert. Verweist auf die kanonischen Quellen und formuliert die
Hard Rules. Bei Konflikt zwischen dieser Datei und einer kanonischen
Quelle gilt die kanonische Quelle (Source Precedence, §2).

Strukturregeln und Adaptionen leben in [`harness/conventions.md`](harness/conventions.md).

**Betriebsregelwerk der adoptierten Baseline — committet vendored, netzlos.**
Regelwerk **und** Templates liegen unter `.harness/baseline/<tag>/{regelwerk,templates}/`
(+ `SHA256SUMS`), auf **jedem Checkout präsent** — kein Fetch pro Lauf, kein
Netz. Der Baum ist eine **derivative Sicht** auf den Kurs; bei Konflikt gilt die
kanonische Quelle (§2 und der Kurs selbst, den `regelwerk/README.md` nennt).
**Lektüre vor dem Workflow (§6): der Index** (`.harness/baseline/<tag>/regelwerk/README.md`)
**+ das relevante Modul on-demand**, **nicht** der Volltext am Stück (der
`regelwerk/`-Baum misst ~170 KB / ~2800 Zeilen und sprengt damit Claudes
150k-Zeichen-Memory-Limit; kein `@`-Auto-Import).

**Zugriff (pro Agent verschieden).** **Codex** injiziert via SessionStart-Hook nur
den **Index** (`.codex/hooks.json` → `harness/tools/sessionstart-inject-regelwerk.sh`);
**Claude** liest **bei Bedarf** (Pointer: `CLAUDE.md`-Direktive + Source
Precedence). **Beide** lesen das relevante Modul **on-demand** aus dem Verzeichnis.
Die `../templates/…`-Ziel-Form-Verweise des Regelwerks lösen netzlos lokal auf,
weil beide Bäume Geschwister sind (12 eindeutige Ziele, 0 tot — gemessen; roh-`grep`
zählt je nach Muster mehr, s. [`MR-007`](harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)). Fehlt die Baseline, ist der **Checkout kaputt**
(sie ist committet) — `make baseline-verify` meldet Details; sie **nicht** als
geladen voraussetzen. Mechanik: [`MR-007`](harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) (löst den gefetchten Cache aus
[`MR-004`](harness/conventions.md#mr-004--sessionstart-regelwerk-injektor)/[`MR-006`](harness/conventions.md#mr-006--regelwerk-cache-als-split-modul-verzeichnis) ab).

**Skelett-Vorlagen der Baseline** liegen im selben vendored Baum
(`.harness/baseline/<tag>/templates/`) — sie kommen **nicht** aus einem zweiten
Asset.

## 2. Kanonische Quellen (Source Precedence)

3-Strata-Spec (Vertrag → Technik → Sicht, [`MR-019`](harness/conventions.md#mr-019--technik-stratum-als-rang-2-der-source-precedence)).
In dieser Reihenfolge:

1. [`spec/lastenheft.md`](spec/lastenheft.md) — vertraglich abnahmebindend.
2. [`spec/spezifikation.md`](spec/spezifikation.md) — technisch verbindlich, ohne Vertragsänderung fortschreibbar.
3. [`spec/architecture.md`](spec/architecture.md) — Komponenten- und Sequenzsicht.
4. [`docs/plan/adr/`](docs/plan/adr/) — Architekturentscheidungen.
5. [`docs/plan/planning/in-progress/roadmap.md`](docs/plan/planning/in-progress/roadmap.md) — aktuelle Welle.
6. [`README.md`](README.md) — Projekt-Überblick.
7. **AGENTS.md (diese Datei).**
8. [`harness/README.md`](harness/README.md) — Harness-Einstieg.

## 3. Harte Regeln

### 3.1 Keine halluzinierten Gates

Jeder in AGENTS.md, harness/README.md oder im Makefile genannte Gate
muss auf frischem Checkout laufen. Der Gate-Config wächst mit den
Artefakten — `ids`/`codepaths` nur mit existierenden Targets/roots
aktivieren ([`LH-QA-01`](spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).

### 3.2 Lint-Suppression-Verbot

Kein `//nolint` (golangci-lint) und kein `# shellcheck disable` ohne
begründeten, zentralen Eintrag in der jeweiligen Lint-Config. Inline-Suppression
bricht den `lint`- bzw. `shell-lint`-Gate.

### 3.3 git mv + Inhaltsänderung = zwei Commits

Move und Rewrite getrennt committen, sonst fällt die Rename-Detection
unter die Similarity-Schwelle.

### 3.4 ADRs sind nach Accepted immutable

Korrekturen entstehen als neue ADR mit Supersedes, nicht durch
Überschreiben.

### 3.5 Gates nicht ohne ADR lockern

Jede Schwellen-Senkung (Modul-Aktivierung, Strenge) ist ein ADR, kein
PR-Kommentar.

### 3.6 Keine Zusage ohne rot gesehenes Gegenbeispiel

Eine Zusage — Doc-Kommentar, Test-Name, DoD-Punkt, Commit-Message — ist erst
fertig, wenn benannt ist, **was passieren müsste, damit sie bricht**, und das
einmal **rot gesehen** wurde. Ein Test, dessen Name eine Eigenschaft behauptet,
muss die Eigenschaft messen, nicht ihre heutige Implementierung.

**Falsch:** ein Test `…AusserScopeNichtEmittiert`, der die **Quell**-Namen
prüft, während der Code **transformierte Ziel**-Namen schreibt — er kann unter
keiner Mutation rot werden.
**Richtig:** den **vollständigen Ist-Bestand** gegen die erwartete Liste prüfen
und die Regel einmal aufheben, bis der Test fällt.

**Falsch:** „Byte-Gleichheit belegt `make smoke`", ohne `smoke` gelesen zu haben.
**Richtig:** benennen, was wirklich deckt — oder dass nichts deckt.

**Falsch:** ein Doc-Kommentar, der „bei jedem Fehler bleibt das Ziel
unverändert" zusagt, während ein `MkdirAll` davor läuft.
**Richtig:** die Zusage auf das einschränken, was der Code hält.

**Feedback:** `make mutate` (Nicht-Gate-Verify, §4) fährt ein kuratiertes Set aus
*(Mutation → erwartet rot färbender Test)* und meldet jeden **gelisteten** Wächter,
der seine Zähne verloren hat — gelistet heißt: wer keinen Fall in `test/mutations/`
hat, ist unbewacht. Es prüft die **Haltbarkeit** vorhandener Zähne, nicht die
**Entstehung** neuer — letztere hängt an der Pre-completion-Checkliste, die zu
jeder Zusage die rot färbende Mutation verlangt.

**Begründung (gemessen, nicht postuliert):** In slice-022a fünf Instanzen dieser
Klasse, in slice-022b vier — gefunden von vier getrennten Rollen-Durchgängen.
Ein Test, der eine Eigenschaft im Namen führt und ein Implementierungsdetail
prüft, ist ein stilles Grün im Gate — §3.1 eine Ebene tiefer. Die Regel ist eine
**Verschärfung** und braucht darum kein ADR (§3.5 gilt für Senkungen; vgl.
[`MR-001`](harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids) „Gate-*Anheben* → Steering-Loop").

### 3.7 Ein Kommentar beschreibt, was da ist

Gilt für Code, Konfiguration und Skripte. Ein Kommentar trägt eine der fünf
Klassen — **Zusage · Kopplung · Abgrenzung · Rang-Zeiger · Grenze** — und
schreibt an den, der die Stelle *ändert*, nicht an den, der die Entscheidung
*trifft*.

**Falsch:** „Ohne dieses Feld behauptete die Ausgabe eine Verteilung, die nicht
stattgefunden hat" — Konjunktiv über die verworfene Alternative.
**Richtig:** „Verteilt ist wahr, wenn die Splitting-Regel angewendet werden
konnte" — Indikativ über den Zustand.

**Falsch:** „die frühere Fassung prüfte nur die Länge" — beschreibt abwesenden
Text.
**Richtig:** die geltende Zusage nennen; die vorige hält `git`.

**Begründung:** Die Abwägung gehört in die ADR, die Historie in `git`, die
Herkunft in **ein** auflösbares Feld ([`LH-*`](spec/lastenheft.md),
[`ADR-*`](docs/plan/adr/)). Was daneben steht, liest jeder Lauf mit und bezahlt
es mit Kontext.

**Geltungsbereich:** Code, Konfiguration und Skripte, **die dieses Repo besitzt**.
Ausgenommen ist `.harness/baseline/` — ein committet vendored Fremd-Blob, den
[`MR-007`](harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) nicht anfasst und den das Doc-Gate aus demselben Grund
per `scan.ignore` ausnimmt. Was ein **emittiertes** Repo an Regeln bekommt,
entscheidet der Slice, der die Tool-Ebene entscheidet — nicht diese Sektion.

**Cutoff — ab Einführung, kein Nachrüsten.** Gebunden ist der Kommentar, der
geschrieben oder geändert wird; der **Bestand ist kein Arbeitsauftrag**. Er ist
gemessen, nicht geschätzt — jede Zahl mit ihrem Kommando, beide über denselben
Pathspec, der den Geltungsbereich oben abbildet (Stand 2026-08-09):
`git ls-files '*.go' '*.sh' '*.awk' '*Makefile' 'Dockerfile' ':!internal/emit/templates' ':!.harness/baseline' | wc -l` → **212** Dateien im Prüfbereich; davon
`git grep -lE '^[[:space:]]*(#|//).*Review-Befund' -- '*.go' '*.sh' '*.awk' '*Makefile' 'Dockerfile' ':!internal/emit/templates' ':!.harness/baseline' | wc -l` → **36** mit einer Befund-Kennung im Kommentar (63 Zeilen).
**Untergrenze, mit Absicht:** die zweite Falsch-Klasse dieser Sektion — Prosa über
abwesenden Text — ist ein Urteil, kein Muster; sie hier zu beziffern hieße, ein
Muster als Kriterium auszugeben, das keines ist (§3.6). Schon die Untergrenze
trägt den Cutoff: ein Maßstab über diesen Bestand wäre dauerhaft rot und
entwertete die Regel, statt sie zu tragen — dieselbe Begründung trägt ihn in
[`MR-015`](harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler). Wer eine solche Zeile ohnehin anfasst, zieht sie nach;
wer sie stehen lässt, bricht nichts.

**Herkunft, mit Mess-Stand:** die adoptierte Baseline `v3.5.2` führt diese Regel
**nicht** — diese Sektion ist ein **Vorgriff** auf einen späteren Kurs-Stand und als
[`MR-022`](harness/conventions.md#mr-022--kommentar-regel-als-vorgriff-auf-eine-neuere-baseline) deklariert. Gegen den Tag `v5.3.0` gemessen (2026-08-09, lokaler
Kurs-Klon) steht sie dort an derselben Stelle wie hier: als Hard Rule mit derselben
Nummer und demselben Titel im Hard-Rules-Block der AGENTS-Vorlage, ausgeschrieben in
den Grundlagen. Mit der Re-Baseline ist gegen die Upstream-Fassung zu halten
([`MR-023`](harness/conventions.md#mr-023--die-platzierung-der-kommentar-regel-ist-keine-abweichung)).
**Ein Wächter existiert nicht:** `make comment-claims` prüft, ob ein genannter
Sensor existiert, nicht, worüber ein Kommentar spricht.

### 3.8 Hard Rules und Adaptions-Block schreibt der Architect

Die Hard Rules dieser Datei (§3) und der Adaptions-Block in
[`harness/conventions.md`](harness/conventions.md) werden vom **Architect** geschrieben. Eine
Änderung an ihnen landet in einem **eigenen Commit**, der ausschließlich Artefakte derselben
schreibenden Rolle berührt — ADRs und diese zwei — und die Rolle in seiner Message nennt.
Gebunden ist das **Schreiben**; **gelesen** werden beide von jeder Rolle uneingeschränkt.

**Über andere Norm-Artefakte sagt diese Regel nichts.** Wo eine Quelle die schreibende Rolle
benennt, gilt sie unverändert; wo keine sie benennt, bleibt die Frage offen. Eine Übersicht, die
fremde Zuordnungen abschriebe, wäre eine zweite Fassung, die driftet.

**Falsch:** eine Anweisung im laufenden Implementations-Kontext dadurch erfüllen, dass derselbe
Lauf die Hard Rule und den Adaptions-Eintrag schreibt.
**Richtig:** die Anweisung ist die **Quelle**; was der laufende Kontext liefert, ist ein
**Übergabe-Artefakt**, und der Norm-Text entsteht im Architect-Lauf.

**Falsch:** die Norm-Änderung im Commit des Slice mitnehmen, der sie ausgelöst hat.
**Richtig:** eigener Commit, nur Architect-Artefakte, Rolle in der Message — nachträglich an
`git log --stat` ablesbar.

**Warum diese zwei, und warum der Architect.** Für die ADR spricht das Regelwerk die Dreiteilung
aus (`v3.5.2`, `modul-08-agentenrollen.md` §Rollen-Regeln: *„ADR-Änderung: Architect schreibt;
Reviewer prüft auf Konsistenz; Implementer liest als Constraint"*). Der Adaptions-Block ist das
Abweichungs-Register — ob eine Abweichung von der Baseline **besteht**, ist eine
Architektur-Frage —, die Hard Rules sind derselbe Gegenstand eine Ebene allgemeiner; beide sind
normativ wie eine ADR, nur ohne deren Immutabilität (§3.4). Dass für diese zwei **keine** Quelle
eine schreibende Rolle benennt, ist über die adoptierte wie über die Ziel-Fassung gemessen:
[ADR-0015](docs/plan/adr/0015-rollen-eigentum-an-norm-artefakten.md) §Kontext, die auch die
Abwägung trägt. Die Regel füllt damit eine Lücke, statt von der Baseline abzuweichen — deshalb
steht zu ihr **kein** Eintrag im Adaptions-Block
([`MR-000`](harness/conventions.md#mr-000--baseline-aussage)).

**Begründung (gemessen, nicht postuliert):** In einem einzigen Slice wurde dreimal ein Artefakt
einer anderen Rolle im Implementations-Kontext geändert, und die Klasse bewegte sich **aufwärts** —
Definition of Done, Roadmap, repo-weite Norm. Der dritte Fall setzte eine Hard Rule samt
Adaptions-Eintrag in Kraft, die eine Baseline-Abweichung behauptete, die es nicht gibt: gemessen
gegen einen Tag, den zwei Releases überholt hatten, und ohne die Mess-Version zu nennen. Ein
zweiter Kontext hätte das in einem `git show`-Lauf gefunden — genau die Eigenschaft, für die
Rollen-Trennung existiert.

**Cutoff — ab der Annahme von [ADR-0015](docs/plan/adr/0015-rollen-eigentum-an-norm-artefakten.md),
kein Nachrüsten.** Gebunden ist die Norm-Änderung, die geschrieben wird; der **Bestand ist kein
Arbeitsauftrag**, und ein Maßstab über ihn wäre dauerhaft rot — gemessen, nicht geschätzt
(Stand 2026-08-09): `git log --format=%H -- AGENTS.md harness/conventions.md | wc -l` → **100**
Commits berühren eine der zwei Dateien; davon tragen **89** daneben Dateien außerhalb der
Architect-Artefakte (dieselbe Commit-Liste, je Commit
`git show --pretty=format: --name-only "$c" | grep -cvE '^(AGENTS|harness/conventions)\.md$|^docs/plan/adr/|^$'`,
gezählt die Nicht-Null-Ausgaben). **Obergrenze, mit Absicht:** `git` sieht Dateien, nicht
Abschnitte — ein Commit, der allein §6 dieser Datei berührt, zählt mit, obwohl die Regel ihn nicht
bindet.

**Geltungsbereich: dieses Repo.** Was ein **emittiertes** Repo an Eigentums-Aussagen bekommt,
entscheidet der Slice, der die Tool-Ebene entscheidet — nicht diese Sektion.

**Ein Wächter existiert nicht.** Kein Modul des Doku-Gates liest Commits (`.d-check.yml` führt
`links, anchors, ids, matrix, codepaths, spans`), und `make mutate` kennt zwei Fehlschlag-Formen —
`--- FAIL:` der Go-Stufe, `not ok N` der bats-Stufe —, keine, in der ein Commit-Zuschnitt rot
wird. Die Regel liegt im Feedforward-Quadranten: benannt, nicht geschlossen; ihr Träger ist der
Rollen-Wechsel vor der Änderung, nicht ein Gate danach.

## 4. Quality Gates

| Target | Zweck |
|---|---|
| `make baseline-verify` | Vendored Baseline netzlos verifizieren (Integrität + Vollständigkeit, [`MR-007`](harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)) |
| `make docs-check` | Doku-Referenzen (links/anchors/ids/codepaths) via d-check |
| `make test` | Command-Guard-Tests (bats) + Go-Unit-Tests (Dockerfile-`test`-Stage) im gepinnten Image; die Stage erbt von einer **Vorwärm-Stufe** (vorübersetzte Standardbibliothek) und erzwingt die Test-Ausführung mit `-count=1` (slice-057) |
| `make lint` | Go-Lint (golangci-lint, Dockerfile-`lint`-Stage) im gepinnten Image |
| `make build` | Go-Binary cross-compilieren (Dockerfile-`build`-Stage) im gepinnten Image |
| `make shell-lint` | Shell-Hooks/-Helfer lint-clean (shellcheck) im gepinnten Image |
| `make ci-lint` | GitHub-Actions-Workflows syntax-clean (actionlint) im gepinnten Image (slice-027) |
| `make comment-claims` | Kommentar-Behauptungen nennen ihren Sensor, und der genannte Test existiert (§3.6, hermetisch: bash+awk). **Prüfbereich = vier Pfad-Muster** (`internal/**/*.go`, `cmd/**/*.go`, `harness/tools/*.sh`, `.claude/hooks/*.sh`) **im Index, ohne `_test.go`** — damit in **drei** Achsen enger als der Gate-Stempel, nicht in einer: (1) untrackt zählt nicht (heilt beim ersten `git add`), (2) `Makefile`, `harness/tools/*.awk`, `internal/emit/templates/`, `test/` und jede Markdown-Datei liegen **dauerhaft** außerhalb, (3) Test-Dateien sind ausgenommen. Wie groß der Ausschnitt ist, sagt die „N Datei(en) geprueft"-Zeile selbst (2026-07-30: 38) — Details in [`harness/README.md`](harness/README.md) |
| `make host-bin` | Den **Träger** — das Produkt-Binär — für die **Host**-Plattform bauen und in den gitignorierten Zustands-Bereich legen; der Hook ruft ihn dort als `ai-harness-init span-emit` ([`ADR-0022`](docs/plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 2) |
| `make span-check` | Der Träger ist vorhanden **und** sein Unterkommando `span-emit` erzeugt für eine synthetische Payload einen Span, dessen Ablageort `git check-ignore` bestätigt (Schema: [`spec/spezifikation.md`](spec/spezifikation.md#5-metriken-und-tracing-felder) §5) |
| `make gates` | alle aktuell lauffähigen Gates |

Der Dogfood-Go-Gate-Stack ist **vollständig**: `make lint` / `make build` / `make test` (Go via Dockerfile-Stages, slice-001a/b) neben `docs-check` / `shell-lint` / `baseline-verify`. **Nicht behauptet**: das Architektur-Gate (a-check, [`LH-FA-07`](spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren)) — der Dogfood ist **flach**, hier hätte a-check einen leeren Prüfbereich ([`LH-QA-01`](spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). **Emittiert wird es trotzdem** (slice-046, emitted-only): ein Zielrepo mit einem **schichten-tragenden** Layout — heute `--arch hexslice` (go, cpp) oder `--arch hexagonal` (go) — bekommt `.a-check.yml` + `a-check.mk` + sein Gate-Fragment und fährt a-check in seinem `make gates` mit; ein flaches Ziel bekommt keines. Welche Layouts das sind, entscheidet **keine Namensliste**, sondern die strukturelle Frage, ob das Layout eine geprüfte Schicht trägt. Belegt in `make full-smoke` (beide Richtungen + ein verbotener Import, der das emittierte Gate rot färbt), nicht hier.

**Nicht-Gate-Verify** (verfügbar, aber **nicht** in `make gates` — wie `regelwerk-check`/`baseline-freshness`): `make smoke` fährt den Tier-2-Emit-Smoke (slice-002) — emittiert die Doc-Gate-Baseline in ein tmp-Repo und lässt das emittierte `docs-check` real laufen. Host-Docker + ggf. Netz-Pull, darum an DoD-Verify/CI/Wellen-Closure, nicht im offline-schlanken `make gates`. `make full-smoke` ist der **Voll-E2E-Smoke** (slice-024): Bootstrap in ein tmp-Repo, dann dort der **zusammengeführte** `make gates` ([`MR-010`](harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert): docs-check + Go-Gates) — der Happy-Path-Beweis ([`LH-FA-01`](spec/lastenheft.md#lh-fa-01--repo-bootstrappen)), dass ein frisch gebootstrapptes Repo out-of-the-box grün fährt (die Nutzer-Sicht, die `make smoke` mit seinen getrennten Schritten bewusst nicht nimmt); ebenfalls Host-Docker/Netz, an DoD-Verify/CI/Closure. `make span-report` rechnet aus dem Span-Bestand eine **Token-Bilanz je Rolle** — ein **Bericht, kein Sensor**: er prüft nichts, färbt nichts rot und gehört darum in keine der beiden Gate-Tabellen ([`LH-QA-01`](spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). Er liest den Bestand read-only und netzlos; seine Ausgabe nennt ihren **Nenner** (Subagenten-Läufe, nicht der Lauf — [ADR-0012](docs/plan/adr/0012-haupt-kontext-ohne-token-bilanz.md)), den **Sammelposten-Anteil** und die **Abdeckungszahl mit Bezugsmenge**. `make mutate` ist der Mutations-Sensor zu §3.6 (slice-026): er färbt jeden gelisteten Wächter absichtlich rot und meldet den, der grün bleibt. Je Fall läuft **nur der Sensor, dessen Rot erwartet wird** (aus der `# expect:`-Zeile abgeleitet; im Zweifel beide — slice-056). Je Fall läuft **nur der Sensor, dessen Rot erwartet wird** — abgeleitet aus der `# expect:`-Zeile, im Zweifel (leer, mehrdeutig) beide Stufen (slice-056). Er arbeitet gegen eine **isolierte Kopie außerhalb des Repos** — der Arbeitsbaum wird nie verändert, parallele Gate-/Test-Läufe sind unbedenklich, und ein Abbruch lässt **im Arbeitsbaum** kein Residuum zurück (außerhalb bleiben ein Temp-Verzeichnis und, nach hartem Kill, das Lock-Verzeichnis liegen — Letzteres bewusst fail-closed). Der Lauf misst das mit: er vergleicht die Mutations-Zieldateien im Arbeitsbaum vor, **während** und nach dem Lauf (nur diese Dateien — nicht den ganzen Baum, damit paralleles Arbeiten den Lauf nicht rötet). Jede Mutation kostet einen Sensor-Lauf (`make test-go` **oder** `make test-bats`, bei unklarer Erwartung beide) — auch er gehört an DoD-Verify/Closure.

**CI** ([`MR-014`](harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions), slice-027): GitHub Actions fährt `make gates` + `make smoke` + `make mutate` pro Push/PR auf frischem Klon (schließt die [`MR-003`](harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)-Restlücke, gibt `make mutate` seinen Pro-Push-Auslöser); die Netz-Sensoren nur nächtlich. Die CI ruft **nur `make`-Targets**. **Was CI prüft, ist genau der Inhalt dieser Targets — nichts darüber hinaus;** ein grüner Lauf ist keine Aussage über ungetestete Flächen.

## 5. Dokumentations-Regeln

- Requirement- und ADR-IDs in PRs/Commits referenzieren (als Link oder Inline-Code).
- Neue ADRs aktualisieren den ADR-Index.
- Der Gate-Config wächst mit den Artefakten — keine halluzinierten Gates.

## 6. Minimal Agent Workflow

1. [`harness/README.md`](harness/README.md) lesen.
2. Relevante kanonische Quelle lesen (Source Precedence beachten).
3. Betroffene Requirement-/ADR-IDs identifizieren.
4. Kleinste sinnvolle Änderung planen.
5. Engsten nützlichen Sensor laufen lassen.
6. Repo-weiten Gate-Lauf vor Handoff (`make gates`).
7. Doku/Indizes aktualisieren, falls ein öffentlicher Vertrag berührt.
8. Ausgeführte Sensors und Risiken berichten — keine Erfolgsmeldung ohne Gate-Lauf.
