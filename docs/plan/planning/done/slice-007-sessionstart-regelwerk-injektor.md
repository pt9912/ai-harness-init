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

- [ ] Agent-neutrales Hook-Skript unter `harness/tools/` gibt valides JSON
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
| `harness/tools/` (SessionStart-Injektor) | neu | ein Skript → `additionalContext`-JSON, beide Agenten |
| `harness/tools/` (awk-Encoder) | neu | JSON-String-Encoder, isoliert testbar, kein jq |
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

**Abschluss:** 2026-06-14. DoD vollständig; Gates grün.

**Korrektur (nachträglich, Nutzer-Befund):** Der ursprünglich angelegte
In-Repo-„Cache" war ein **unilateral verfasster Digest** (Kurzfassung) — eine
**Harness-Lüge**: er stellte eine verlustbehaftete Paraphrase an die Stelle der
autoritativen Quelle (Source Precedence invertiert) und hätte Agenten eine
gekürzte Fassung als „die Regeln" untergeschoben; niemand hatte eine Kurzform
beauftragt. Ersetzt durch eine **wortgleiche**, sha256-gepinnte, **gitignorierte**
Kopie unter `.harness/cache/agents-regelwerk.md` (via `make regelwerk-fetch`), die
**Codex** injiziert sie voll via Hook, **Claude** liest sie bei Bedarf (Pointer,
s. Nachtrag); die inline „Hard-Rules-Kurzform" in AGENTS.md §1 ist entfernt.
**Lerneintrag:** kanonische Quellen nie kondensieren/eigenformulieren und als
Quelle ausgeben — verbatim spiegeln oder nur darauf zeigen.

**Nachtrag (Claude-10k-Cap):** Claude kappt jede Hook-`additionalContext` bei
10.000 Zeichen (212 KB → nur 2-KB-Preview + Datei) — der Volltext-Hook
funktioniert daher nur für **Codex**. **Claude** liest den Cache stattdessen
**bei Bedarf** (Pointer-Direktive in `CLAUDE.md`; Test bestätigte das ungefragte
Lesen). Ein `@`-Auto-Import wurde verworfen — 212 KB sprengen Claudes
150k-Memory-Limit (~108k Token + Warnung, und das Modell misstraut dem Embed und
liest die Datei ohnehin). Der Claude-SessionStart-Hook ist entfernt.
AGENTS.md §1 / [`MR-004`](../../../../harness/conventions.md#mr-004--sessionstart-regelwerk-injektor) sind entsprechend pro Agent korrigiert (das frühere
„Volltext für beide via Hook" war falsch).

**End-Stand (maßgeblich):** Der Injektor
(`harness/tools/sessionstart-inject-regelwerk.sh`) gibt
`hookSpecificOutput.additionalContext` aus; JSON-Encoding via
`harness/tools/json-encode.awk` (kein node/jq, [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten); byteweise,
UTF-8- + C0-sicher). Quelle ist der gepinnte, **wortgleiche** Cache
`.harness/cache/agents-regelwerk.md` (sha256-Pin; kein Netz-Fetch im Hook,
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)). **Pro Agent:** **Codex** injiziert voll via Hook
(`.codex/hooks.json`); **Claude** liest den Cache bei Bedarf (Pointer in
`CLAUDE.md`, Hook entfernt — 10k/150k-Caps). Fehlender Cache → **sichtbare
Warnung** (nicht still). Mechanik: [`MR-004`](../../../../harness/conventions.md#mr-004--sessionstart-regelwerk-injektor).

**Nachweise (zwei beobachtbare Closure-Kriterien + Lerneintrag):**

- `make test` deckt Encoder-Escapes (`"`/`\`/Tab/Newline/UTF-8/C0) + Injektor:
  Volltext-Injektion gegen synthetischen Cache; fehlender Cache → **sichtbare
  Warnung** mit `make regelwerk-fetch` (nicht leer/still).
- `make gates` grün; Injektor shellcheck-clean.

**Steering-Loop-Lerneintrag:**

1. **Geschlossener Loop aus slice-006.** Der dort notierte Vorschlag
   (Regelwerk-Lektüre *erzwingen* statt *erinnern*) ist umgesetzt: aus dem
   erinnerten Pointer wurde Computational Feedforward (SessionStart-Hook).
2. **Digest war eine Harness-Lüge.** Der erste „Cache" war eine **unilateral
   verfasste Kurzfassung** — verlustbehaftete Paraphrase an der Stelle der
   autoritativen Quelle (vom Nutzer als Lüge erkannt; niemand hatte sie
   beauftragt). Ein abgelehnter Auto-Fetch ist **kein** echter Block (es ist der
   Inhalt des Nutzers; `curl` liefert die Bytes). **Lehre:** kanonische Quellen
   nie kondensieren und als Quelle ausgeben — verbatim spiegeln oder nur zeigen.
3. **Plattform-Limits empirisch.** Claude kappt Hook-Output bei 10k / Memory bei
   150k → Volltext-Inject nur bei Codex, Claude bekommt Pointer/Read-on-demand.
   Codex-Hook brauchte das korrekte `{ "hooks": {…} }`-Schema **und** den
   getrusteten `.codex/`-Layer (sonst `Installed 0`). Jede Behauptung („wird
   gelesen", „voll injiziert") wurde **nachgewiesen**, nicht angenommen.

**Verifikation (nachgetragen):** über eine **echte** Zeile (z. B. die Titelzeile
`# Agents-Regelwerk …`) — Modell-Zitat / Transcript-Grep / Debug-Logs je Agent;
Prüf-Rezepte + Drift-Verhalten in [`MR-004`](../../../../harness/conventions.md#mr-004--sessionstart-regelwerk-injektor). (Der frühere
Eigenbau-Sentinel ist mit dem Digest entfallen.)

**Folge-Slices / offen:**

- **Codex-Hook real verifizieren** in der eingesetzten Codex-Version (Hooks
  versionsabhängig; repo-lokale Config feuert teils still nicht, codex-Issue
  #17532 → ggf. `~/.codex/hooks.json`); Pfad-Auflösung ggf. härten.
- **Drift-Check** (slice-009): read-only `make regelwerk-check`; die
  sha256-Pin-Verifikation beim `make regelwerk-fetch` deckt Drift bereits ab.
  Kein Auto-Pull im Hook.
- Emission des Injektors ins Zielrepo zusammen mit der Durchsetzungsschicht
  ([`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) Folge-Slice).

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example):
`.claude/`, `.codex/` und `harness/tools/` teilen die adoptierte
Harness-Mechanik ([`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks)); `harness/` ist GF (Doc führt). `.codex/`
ist eine neue, eigenständige Pfad-Familie (Inklusionskriterium erfüllt).
