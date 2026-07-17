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
**+ das relevante Modul on-demand**, **nicht** der Volltext am Stück (er sprengt
Claudes 150k-Zeichen-/108k-Token-Limit; kein `@`-Auto-Import).

**Zugriff (pro Agent verschieden).** **Codex** injiziert via SessionStart-Hook nur
den **Index** (`.codex/hooks.json` → `harness/tools/sessionstart-inject-regelwerk.sh`);
**Claude** liest **bei Bedarf** (Pointer: `CLAUDE.md`-Direktive + Source
Precedence). **Beide** lesen das relevante Modul **on-demand** aus dem Verzeichnis.
Die 15 `../templates/…`-Ziel-Form-Verweise des Regelwerks lösen netzlos lokal auf,
weil beide Bäume Geschwister sind. Fehlt die Baseline, ist der **Checkout kaputt**
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

## 4. Quality Gates

| Target | Zweck |
|---|---|
| `make baseline-verify` | Vendored Baseline netzlos verifizieren (Integrität + Vollständigkeit, [`MR-007`](harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)) |
| `make docs-check` | Doku-Referenzen (links/anchors/ids/codepaths) via d-check |
| `make test` | Command-Guard-Tests (bash+awk) via bats im gepinnten Image |
| `make shell-lint` | Shell-Hooks/-Helfer lint-clean (shellcheck) im gepinnten Image |
| `make gates` | alle aktuell lauffähigen Gates |

**Nicht behauptet** (folgt mit dem Go-Code): `build`/`lint` (Go-Toolchain im gepinnten Image — `go build` / `golangci-lint`); `make test`/`make shell-lint` decken aktuell die bash+awk-Guard-Suite (bats) und die Shell-Hooks (shellcheck), die Go-Unit-Tests (`go test`) folgen mit dem Code.

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
