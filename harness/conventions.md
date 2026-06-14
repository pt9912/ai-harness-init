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
- **Geltungsbereich:** [`harness/tools/`](../harness/tools/), [`.claude/`](../.claude/), `make record-gates`
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
- **Geltungsbereich:** [`harness/tools/working-tree-hash.sh`](../harness/tools/working-tree-hash.sh), [`.claude/hooks/`](../.claude/hooks/)
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
- **Geltungsbereich:** [`harness/tools/`](../harness/tools/), [`.claude/`](../.claude/), [`.codex/`](../.codex/), `.harness/cache/`, `CLAUDE.md`, `Makefile`, `.d-check.yml`
- **Adaption:** Das **wortgleiche** Betriebsregelwerk wird **pro Agent
  verschieden** verfügbar gemacht — der 212-KB-Volltext passt in keinen Claude-
  Auto-Kanal (Hook-Ausgaben gekappt bei **10.000 Zeichen**, Memory/`@`-Import
  bei **150k Zeichen** → ~108k Token + Warnung): **Codex** injiziert ihn **im
  Volltext** über den SessionStart-Hook (`.codex/hooks.json`, Schema
  `{ "hooks": { … } }` + getrusteter `.codex/`-Layer) →
  `harness/tools/sessionstart-inject-regelwerk.sh`
  (`hookSpecificOutput.additionalContext`); **Claude** liest den Cache **bei
  Bedarf** (Pointer-Direktive in `CLAUDE.md` + Source Precedence; Test bestätigte:
  Claude las `.harness/cache/agents-regelwerk.md` bei einer Harness-Aufgabe
  ungefragt — `Read` paginiert >2000 Zeilen). Quelle ist ein **lokaler,
  gitignorierter** Cache `.harness/cache/agents-regelwerk.md`, den
  `make regelwerk-fetch` per `curl` (Raw-URL, **sha256-gepinnt**) befüllt — kein
  committeter Fremd-Blob und **keine** Kurzfassung/Paraphrase (das war eine frühere
  Harness-Lüge, siehe slice-007-Korrektur). JSON-String-Encoding via
  `harness/tools/json-encode.awk` (**kein** node/jq,
  [`LH-QA-03`](../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)); **kein**
  Netz-Fetch im Hook (nur die lokale Kopie,
  [`LH-QA-02`](../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)). Fehlender Cache
  (vor dem Fetch) → leerer `additionalContext`, exit 0 (degradiert leise). Der
  Cache ist gitignored und vom Doc-Gate ausgenommen (`.d-check.yml` `scan.ignore`).
- **Begründung:** Die in AGENTS.md §1 verlangte Regelwerk-Lektüre war nur
  *erinnert*, nicht *erzwungen* (Steering-Befund aus slice-006). Der Hook macht
  sie zu Computational Feedforward — mit dem **echten** Text, nicht einer
  Eigenbau-Kurzfassung. Kosten: ~53K Token je Session (bewusst akzeptiert für
  „Regeln garantiert im Kontext"). Der awk-Encoder hält die node/jq-freie Linie.
- **Verifikation & Drift:** Injektion prüfbar, indem das Modell eine **echte
  Zeile** zitiert (z. B. die Titelzeile `Agents-Regelwerk …`) bzw. im Transcript
  danach gegreppt wird (Claude `~/.claude/projects/.../*.jsonl`, Codex
  `~/.codex/sessions/.../rollout-*.jsonl`); Hook-Lauf via Debug (`claude --debug`
  → `~/.claude/debug/<id>.txt`; Codex `RUST_LOG=codex_core=debug codex` →
  `~/.codex/log/codex-tui.log`). **Kein** Auto-Check im Hook (offline); Drift
  erkennt `make regelwerk-fetch` über den sha256-Pin. **Codex-Setup:**
  `.codex/hooks.json` braucht das `{ "hooks": { "SessionStart": … } }`-Schema
  (Wrapper) **und** der Projekt-`.codex/`-Layer muss in Codex via `/hooks`
  **getrustet** sein — sonst zeigt `/hooks` `Installed 0` und der Hook feuert
  nicht. (Claude: `.claude/settings.json`, eigener Trust-/Reload-Pfad.)
- **Auflösungs-Trigger:** permanent; Cache-Refresh + Re-Pin (`REGELWERK_SHA256`)
  bei Upstream-Änderung manuell; Codex-Hook-Verfügbarkeit ist versionsabhängig.

### MR-005 — Harness-Tools unter harness/tools/ (Layout-Adaption)

- **Datum:** 2026-06-14
- **Geltungsbereich:** [`harness/tools/`](../harness/tools/), [`.claude/`](../.claude/), [`.codex/`](../.codex/), `Makefile`, `.d-check.yml`
- **Adaption:** Die ausführbaren Harness-Tools (Gate-Nachweis, Working-Tree-Hash,
  Command-Guard-Extraktor, SessionStart-Injektor + awk-Encoder) liegen unter
  `harness/tools/` statt dem Baseline-Default `tools/harness/`. Damit liegt die
  gesamte Harness — Docs (`harness/README.md`, `harness/conventions.md`) und
  Tooling — unter einem `harness/`-Dach (der Regelwerk-Cache liegt gitignored
  unter `.harness/cache/`, siehe [`MR-004`](#mr-004--sessionstart-regelwerk-injektor)).
  Folge: `codepaths.roots` verliert das nicht mehr existierende `tools` (die
  Tools sind unter `harness` weiter abgedeckt); alle Hook-/Makefile-/Test-
  Referenzen und die vorherigen Tooling-MR-Geltungsbereiche sind angepasst.
- **Begründung:** Kohäsion — eine Wurzel für die Harness (Nutzer-Entscheidung).
- **Auflösungs-Trigger:** permanent. **Offen — Reconciliation:** Die in
  [`LH-FA-06`](../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) und [`ADR-0004`](../docs/plan/adr/0004-durchsetzungs-emission.md) beschriebene **emittierte**/Template-Struktur nennt
  weiterhin `tools/harness/`; ob die Emission der lokalen Konvention folgt, ist
  ein CR-/ADR-Folgepunkt (hier bewusst nicht berührt — Lastenheft ist rank-1,
  die Accepted-ADR immutable).

## Modus-Deklaration pro Sub-Area

| Sub-Area | Modus | Begründung | Graduation |
|---|---|---|---|
| `*` (gesamtes Repo) | Greenfield | Neues Repo, Doc führt, Code folgt | n/a (GF) |
| `harness/tools/` | Greenfield | adoptierte Harness-Mechanik (Adaptions-Block) | n/a (GF) |
| `.codex/` | Greenfield | neue Pfad-Familie, adoptierte SessionStart-Hook-Mechanik | n/a (GF) |
