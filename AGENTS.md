# AGENTS.md — Briefing für AI-Coding-Agenten

## 1. Was diese Datei ist

Onboarding-Briefing für jede AI-Session, die in diesem Repo Code oder
Doku ändert. Verweist auf die kanonischen Quellen und formuliert die
Hard Rules. Bei Konflikt zwischen dieser Datei und einer kanonischen
Quelle gilt die kanonische Quelle (Source Precedence, §2).

Strukturregeln und Adaptionen leben in [`harness/conventions.md`](harness/conventions.md).

**Betriebsregelwerk der adoptierten Baseline** (Agenten-Kurzform) —
einmal pro Session lesen, bevor der Workflow (§6) startet:
<https://raw.githubusercontent.com/pt9912/ai-harness-course/main/kurs/de/agents-regelwerk.md>
Derivativ; bei Konflikt gelten die kanonischen Quellen.

**In-Repo-Cache + Auto-Injektion.** Das Regelwerk liegt gepinnt als
`harness/agents-regelwerk.cache.md`; ein SessionStart-Hook injiziert es
automatisch in Claude Code (`.claude/settings.json`) und Codex CLI
(`.codex/hooks.json`) über `tools/harness/sessionstart-inject-regelwerk.sh`
(Mechanik: [`MR-004`](harness/conventions.md#mr-004--sessionstart-regelwerk-injektor)).
Codex liest `AGENTS.md` nativ — für Codex-Cloud/-IDE ohne Hook trägt daher die
folgende Kurzform (Codex folgt keinen Links → Inhalt inline):

**Hard Rules (Kurzform — Volltext im Cache):**

1. **Keine halluzinierten Gates** — nur real existierende Gates behaupten.
2. **Source Precedence ist total** — höherrangige Quelle gewinnt, niedrigere wird korrigiert.
3. **Spec → ADR im Bindungstext verboten** — nur Historie-Tabelle.
4. **Traceability je Commit** — Requirement-/ADR-/Test-/Gate-/Doku-Bezug.
5. **WIP = 1** — ein Slice je Implementierer in in-progress.
6. **Closure braucht Lerneintrag** — Übergang nach done nur mit Steering-Eintrag.
7. **Brownfield braucht Graduation-Plan** — keine getarnte Dauerausnahme.
8. **Carveout braucht Trigger** — expliziter Auflösungs-Trigger oder als permanent dokumentiert.
9. **Fail-closed Gates** — fehlende/unlesbare Eingabe → block.
10. **Entropie-Management ist dauerhaft** — Drift, tote Constraints, Carveout-Wildwuchs aktiv jagen.

**Skelett-Vorlagen der Baseline** als ZIP zum Bootstrap:
<https://github.com/pt9912/ai-harness-course/releases/latest/download/lab-templates.zip>

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

Kein `//nolint` (golangci-lint) ohne begründeten, zentralen Eintrag in der
zentralen Lint-Config. Inline-Suppression bricht den lint-Gate.

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
| `make docs-check` | Doku-Referenzen (links/anchors/ids/codepaths) via d-check |
| `make test` | Command-Guard-Tests (bash+awk) via bats im gepinnten Image |
| `make gates` | alle aktuell lauffähigen Gates |

**Nicht behauptet** (folgt mit dem Go-Code): `build`/`lint` (Go-Toolchain im gepinnten Image — `go build` / `golangci-lint`); `make test` deckt aktuell die bash+awk-Guard-Suite (bats), die Go-Unit-Tests (`go test`) folgen mit dem Code.

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
