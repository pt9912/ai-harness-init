# Slice slice-007: SessionStart-Regelwerk-Injektor (Claude Code + Codex)

**Status:** open → next → in-progress → done (Datei wird durch die
Verzeichnisse bewegt, siehe
[Kurs Modul 5](https://github.com/pt9912/ai-harness-course/blob/templates-v4/kurs/de/02-planung/modul-05-planning-harness.md)).

**Welle:** welle-03-durchsetzung-und-emission (Welle-Plan folgt). Einordnung
*(Kontext, nicht normativ)*: [roadmap](../in-progress/roadmap.md).

**Bezug:** [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten), [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks).

**Autor:** Demo. **Datum:** 2026-06-14.

---

## 1. Ziel

Ein **SessionStart-Hook** injiziert das (lokal gecachte) Betriebsregelwerk in
den Session-Kontext, sodass die in `AGENTS.md` §1 verlangte Vorbedingung
*erzwungen* statt nur *erinnert* wird (Computational Feedforward). Agent-neutral
für **Claude Code und Codex CLI**: beide nutzen dieselbe
`hookSpecificOutput.additionalContext`-JSON-Form, also **ein** Hook-Skript mit
**zwei** Registrierungen (`.claude/settings.json`, `.codex/hooks.json`).
JSON-Encoding in **awk** (kein `node`/`jq`). Single Source of Truth ist ein
**gepinnter In-Repo-Cache**. Für Codex-Cloud/-IDE und ältere Codex-Versionen
ohne Hooks dient **`AGENTS.md`** (von Codex nativ gelesen) als portabler Träger
der Hard-Rules-Kurzform.

## 2. Definition of Done

- [ ] Agent-neutrales Hook-Skript unter `tools/harness/` gibt valides JSON
      (`hookSpecificOutput.additionalContext`, passender `hookEventName`) aus,
      das den Regelwerk-Cache injiziert; **kein `node`/`jq`** — JSON-String-
      Encoding via awk-Helfer ([`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)).
- [ ] Registriert in **beiden**: `.claude/settings.json` (`hooks.SessionStart`)
      **und** `.codex/hooks.json` (`SessionStart`, matcher `startup|resume`) —
      dasselbe Skript.
- [ ] In-Repo-Cache unter `harness/` (Single Source; Kopf mit Quell-URL +
      Abruf-Datum/Version); Hook injiziert die lokale Kopie, **kein Netz-Fetch**
      → reproduzierbar ([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)).
- [ ] Portabler Fallback: `AGENTS.md` trägt die **Hard-Rules-Kurzform** inline
      (Codex liest AGENTS.md nativ, folgt aber **keinen** Links → Inhalt muss
      inline sein); das 32-KiB-AGENTS.md-Limit ist beachtet (Codex truncatet
      still) → Kurzform, nicht Volltext.
- [ ] Fehlender Cache → Hook degradiert leise (leerer `additionalContext`,
      exit 0), blockt **keine** Session; Hook + awk-Helfer shellcheck-clean;
      `bats` deckt: korrektes JSON-Encoding (auch `"`/`\`/Newlines), fehlender
      Cache → leer + exit 0.
- [ ] Neuer MR-Eintrag in `harness/conventions.md` (Nummer beim Implementieren
      vergeben): Multi-Agent-Injektor-Mechanik + Cache-Reproduzierbarkeit
      (Geltungsbereich `.claude/`, `.codex/`, `harness/`); Pointer aus
      `AGENTS.md` §1 (Sync-Trigger).
- [ ] `make gates` grün; Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `tools/harness/` (SessionStart-Injektor) | neu | ein Skript → `additionalContext`-JSON, beide Agenten |
| `tools/harness/` (awk-Encoder) | neu | JSON-String-Encoder, isoliert testbar, kein jq |
| `harness/` (Regelwerk-Cache) | neu | gepinnter Cache: Quell-URL + Datum im Kopf |
| `.claude/settings.json` | update | `hooks.SessionStart` registrieren |
| `.codex/hooks.json` | neu | `SessionStart` (`startup\|resume`) auf dasselbe Skript |
| `AGENTS.md` §1 | update | Hard-Rules-Kurzform inline (Codex-Fallback) + Pointer |
| `harness/conventions.md` | update | neuer MR-Eintrag (Multi-Agent-Injektor) |
| `test/` (bats) | neu | JSON-Encoding + fail-safe (fehlender Cache) |

## 4. Trigger

Sofort startbar — reine Harness-Mechanik, unabhängig vom Go-CLI. Vorab in der
gepinnten Codex-Version prüfen, ob Hooks vorhanden sind; sonst greift für Codex
nur der AGENTS.md-Fallback (plus der Claude-Hook). Sinnvoll zusammen mit dem
shell-lint-Slice (mehr Shell-Hooks zu prüfen).

## 5. Closure-Trigger

DoD vollständig + Review konform + Closure-Notiz → nach `done/`.

## 6. Risiken und offene Punkte

- **Codex AGENTS.md-Limit (32 KiB, stilles Truncate)** (codex-Issue #7138) →
  nur die Hard-Rules-Kurzform inline, nicht der Volltext; ggf.
  `project_doc_max_bytes` erhöhen. Codex folgt **keinen** Links in AGENTS.md →
  Inhalt muss tatsächlich im Kontext landen (inline oder Hook).
- **Kein eigenes Codex-Format:** es gibt **kein** auto-geladenes `CODEX.md`/
  `codex.md`. Codex liest nur `AGENTS.md` / `AGENTS.override.md` / globales
  `~/.codex/AGENTS.md`. `project_doc_fallback_filenames` lädt einen Custom-Namen
  **nur, wenn AGENTS.md im Verzeichnis fehlt** (max. eine Datei je Verzeichnis)
  — eine **separate Regelwerk-Datei *neben* AGENTS.md geht also nicht**.
  Cloud/IDE-Abdeckung daher zwingend via AGENTS.md-Inline (CLI zusätzlich via Hook).
- **Codex-Hooks sind CLI-lokal** — greifen nicht in Codex-Cloud/-IDE; dort trägt
  ausschließlich `AGENTS.md`. Hook-Verfügbarkeit ist versionsabhängig.
- **`additionalContext`-Escaping** bei großem Cache (Claude) laut Doku
  unbestätigt → `bats`-Test mit realem Cache; Fallback Kurzform, auch wegen
  Token-Kosten pro Session.
- **Cache-Drift** ggü. Upstream → „derivativ; bei Konflikt gelten kanonische
  Quellen"; Refresh-Mechanik (manuell/scheduled) als Folge-Punkt, kein
  Netz-Fetch im Hook.
- **Resume-Doppelinjektion** (beide Agenten, `matcher` resume) inhaltlich
  idempotent, akzeptabel.
- **jq-Versuchung**: bewusst awk-Encoder, um die node/jq-freie Linie
  ([`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)) zu halten — konsistent zum Command-Guard.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example):
`.claude/`, `.codex/` und `tools/harness/` teilen die adoptierte
Harness-Mechanik ([`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks)); `harness/` ist GF (Doc führt). `.codex/`
ist eine neue, eigenständige Pfad-Familie (Inklusionskriterium erfüllt).
