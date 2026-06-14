# Harness-Konventionen

## Purpose

Repo-lokale Strukturregeln gegenüber der adoptierten Baseline. Bei
Konflikt mit einer kanonischen Quelle gilt diese (Source Precedence).

## Baseline

- **Konvention:** AI-Harness-Kurs
- **Templates:** templates-v4
- **d-check:** Image v0.8.0 (Digest in harness.mk)
- **Datum der Adoption:** 2026-06-13

## Adoptierte Konventions-Quellen

- **Extern (Lehrmaterial):** <https://github.com/pt9912/ai-harness-course>
- **Extern (Agenten-Regelwerk):** <https://raw.githubusercontent.com/pt9912/ai-harness-course/main/kurs/de/agents-regelwerk.md>
- **In-Repo (verkörperte Form):** die adoptierten Templates (zweiklassig abgelegt)

## Adaptions-Block

### MR-000 — Baseline-Aussage

- **Datum:** 2026-06-13
- **Geltungsbereich:** gesamtes Repo
- **Adaption:** keine inhaltlichen Adaptionen ggü. Baseline-Default.
  ID-Schema: `LH-FA-NN` / `LH-QA-NN`, `ADR-NNNN`, `CO-NNN`, `slice-NNN`,
  `MR-NNN`. **2-Strata-Spec** (Lastenheft → Architektur, keine separate
  Spezifikations-Datei) — entspricht dem Kurs-Default.
- **Begründung:** Initial-Setzung.
- **Auflösungs-Trigger:** permanent.

### MR-001 — Doc-Gate-Schärfung (matrix + Link-Pflicht + Anker-IDs)

- **Datum:** 2026-06-13
- **Geltungsbereich:** `.d-check.yml` (Doc-Referenz-Gate)
- **Adaption:** Über die Baseline-Module (`links`, `anchors`, `ids`,
  `codepaths`) hinaus aktiviert: `matrix` (mechanische Referenz-Richtung/SDP —
  Spec-Straten verweisen nie abwärts auf ADR/Slice; Verweise auf
  superseded/deprecated ADRs verboten; `exclude-sections` für
  Historie/Geschichte), `spans` (Markdown-Span-Hygiene) sowie `ids` mit
  `link-policy: always` (Kennungen sind klickbare Links zur Quelle, Requirement-IDs
  mit Abschnitts-Anker; `exempt-paths`: `docs/reviews/**`, `CHANGELOG.md`) plus
  ein `MR`-Pattern (→ diese Datei).
- **Begründung:** Halb-erzwungene ID-Klammer und unbewachte Referenz-Richtung
  geschlossen; „klickbar zur Quelle" als gemessenes Property. Gate-*Anheben* →
  Steering-Loop, kein ADR nötig. Legitime ADR-Supersede-Lineage über Inline-Code
  + `d-check:ignore` (deckt `ids`, nicht `matrix`).
- **Auflösungs-Trigger:** permanent; `codepaths.roots` wachsen mit
  `tools`/`cmd`/`internal` in Phase 2/3.

### MR-002 — Gate-Nachweis-Mechanik und Claude-Hooks

- **Datum:** 2026-06-13
- **Geltungsbereich:** [`tools/harness/`](../tools/harness/), [`.claude/`](../.claude/), `make record-gates`
- **Adaption:** Übernahme der Working-Tree-Hash-Mechanik (`record-gates`
  als letzter `gates`-Prerequisite, der Stop-Hook vergleicht den Hash) und
  der `.claude`-Hooks (PreToolUse-Guard, Stop-Gate) aus d-check/b-cad. Der
  PreToolUse-Guard blockt Host-Paketmanager **und die Host-Go-Toolchain**
  (`go`/`gofmt`/`golangci-lint`) — der Build ist Docker-only.
- **Begründung:** Bewährte Mechanik gegen „Erfolgsmeldung ohne Gate-Lauf";
  der Host-Go-Block setzt das Docker-only-Build-Model durch (kein
  Host-Toolchain-Leak). Keine Logik-Dopplung zwischen Makefile und Hook.
- **Auflösungs-Trigger:** permanent.

### MR-003 — Härtung: inhaltsbasierter Nachweis und Sub-Shell-Prüfung

- **Datum:** 2026-06-13
- **Geltungsbereich:** [`tools/harness/working-tree-hash.sh`](../tools/harness/working-tree-hash.sh), [`.claude/hooks/`](../.claude/hooks/)
- **Adaption:** (a) Der Working-Tree-Hash ist **inhaltsbasiert** (sha256
  über getrackte + untracked Dateien) statt diff-basiert — der Gate-Nachweis
  gilt über Commits hinweg; ein Commit *ohne* Gate-Lauf macht den Stop-Hook
  nicht grün. Restlücke: frischer Klon bzw. gelöschter `.harness`-State mit
  cleanem Tree wird freigegeben (CI ist dort das Netz). (b) Der
  PreToolUse-Guard prüft Sub-Shell-Strings (`bash -c "…"`) rekursiv
  (Tiefe ≤ 3, darüber fail-closed).
- **Begründung:** schließt Commit-Bypass des Stop-Hooks und Guard-Umgehung
  via `bash -c`.
- **Auflösungs-Trigger:** permanent.

### MR-004 — SessionStart-Regelwerk-Injektor

- **Datum:** 2026-06-14
- **Geltungsbereich:** [`tools/harness/`](../tools/harness/), [`.claude/`](../.claude/), [`.codex/`](../.codex/), `harness/agents-regelwerk.cache.md`, `.d-check.yml`
- **Adaption:** Ein agent-neutraler **SessionStart-Hook**
  (`tools/harness/sessionstart-inject-regelwerk.sh`) injiziert das gepinnte
  Betriebsregelwerk (`harness/agents-regelwerk.cache.md`) beim Session-Start in
  den Agenten-Kontext — registriert in `.claude/settings.json`
  (`hooks.SessionStart`) **und** `.codex/hooks.json` (`SessionStart`,
  `startup|resume`); beide Agenten teilen die
  `hookSpecificOutput.additionalContext`-Form. JSON-String-Encoding via
  `tools/harness/json-encode.awk` (**kein** node/jq,
  [`LH-QA-03`](../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)); **kein**
  Netz-Fetch (nur lokale Kopie,
  [`LH-QA-02`](../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)). Fehlender Cache
  → leerer `additionalContext`, exit 0 (degradiert leise). Der Cache ist als
  derivativer externer Inhalt vom Doc-Gate ausgenommen (`.d-check.yml`
  `scan.ignore`); für Codex-Cloud/-IDE (kein Hook) trägt zusätzlich die
  Hard-Rules-Kurzform inline in AGENTS.md §1.
- **Begründung:** Die in AGENTS.md §1 verlangte Regelwerk-Lektüre war nur
  *erinnert*, nicht *erzwungen* (Steering-Befund aus slice-006). Der Hook macht
  sie zu Computational Feedforward; der awk-Encoder hält die node/jq-freie Linie
  des Command-Guards. Codex hat kein eigenes Format (`CODEX.md`) und folgt keinen
  Links in AGENTS.md → Inline-Kurzform für den Cloud/IDE-Pfad.
- **Auflösungs-Trigger:** permanent; Cache-Refresh bei Upstream-Änderung manuell;
  Codex-Hook-Verfügbarkeit ist versionsabhängig.

## Modus-Deklaration pro Sub-Area

| Sub-Area | Modus | Begründung | Graduation |
|---|---|---|---|
| `*` (gesamtes Repo) | Greenfield | Neues Repo, Doc führt, Code folgt | n/a (GF) |
| `tools/harness/` | Greenfield | adoptierte Harness-Mechanik (Adaptions-Block) | n/a (GF) |
| `.codex/` | Greenfield | neue Pfad-Familie, adoptierte SessionStart-Hook-Mechanik | n/a (GF) |
