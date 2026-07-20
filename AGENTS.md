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

2-Strata-Spec (Lastenheft → Architektur, keine separate
Spezifikations-Datei). In dieser Reihenfolge:

1. [`spec/lastenheft.md`](spec/lastenheft.md) — vertraglich abnahmebindend.
2. [`spec/architecture.md`](spec/architecture.md) — Komponenten- und Sequenzsicht.
3. [`docs/plan/adr/`](docs/plan/adr/) — Architekturentscheidungen.
4. [`docs/plan/planning/in-progress/roadmap.md`](docs/plan/planning/in-progress/roadmap.md) — aktuelle Welle.
5. [`README.md`](README.md) — Projekt-Überblick.
6. **AGENTS.md (diese Datei).**
7. [`harness/README.md`](harness/README.md) — Harness-Einstieg.

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

## 4. Quality Gates

| Target | Zweck |
|---|---|
| `make baseline-verify` | Vendored Baseline netzlos verifizieren (Integrität + Vollständigkeit, [`MR-007`](harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)) |
| `make docs-check` | Doku-Referenzen (links/anchors/ids/codepaths) via d-check |
| `make test` | Command-Guard-Tests (bats) + Go-Unit-Tests (Dockerfile-`test`-Stage) im gepinnten Image |
| `make lint` | Go-Lint (golangci-lint, Dockerfile-`lint`-Stage) im gepinnten Image |
| `make build` | Go-Binary cross-compilieren (Dockerfile-`build`-Stage) im gepinnten Image |
| `make shell-lint` | Shell-Hooks/-Helfer lint-clean (shellcheck) im gepinnten Image |
| `make gates` | alle aktuell lauffähigen Gates |

Der Dogfood-Go-Gate-Stack ist **vollständig**: `make lint` / `make build` / `make test` (Go via Dockerfile-Stages, slice-001a/b) neben `docs-check` / `shell-lint` / `baseline-verify`. **Nicht behauptet**: das Architektur-Gate (a-check, [`LH-FA-07`](spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren)) — bewusst aufgeschoben, bis hexagonale Schichten existieren; sonst wäre es ein halluziniertes Gate über leerem Prüfbereich ([`LH-QA-01`](spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).

**Nicht-Gate-Verify** (verfügbar, aber **nicht** in `make gates` — wie `regelwerk-check`/`baseline-freshness`): `make smoke` fährt den Tier-2-Emit-Smoke (slice-002) — emittiert die Doc-Gate-Baseline in ein tmp-Repo und lässt das emittierte `docs-check` real laufen. Host-Docker + ggf. Netz-Pull, darum an DoD-Verify/CI/Wellen-Closure, nicht im offline-schlanken `make gates`. `make mutate` ist der Mutations-Sensor zu §3.6 (slice-026): er färbt jeden gelisteten Wächter absichtlich rot und meldet den, der grün bleibt. Jede Mutation kostet einen vollen `make test`-Zyklus — auch er gehört an DoD-Verify/Closure.

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
