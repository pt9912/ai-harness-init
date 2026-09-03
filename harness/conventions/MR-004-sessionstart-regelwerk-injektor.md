# MR-004 — SessionStart-Regelwerk-Injektor

> **HISTORIE — der Cache-Teil ist seit slice-011 überholt → [`MR-007`](../conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache).**
> Der folgende Body beschreibt den Stand **vor** dem Split-Modul-Cache
> (Einzeldatei, Codex injiziert im Volltext); der Zwischenstand steht in
> [`MR-006`](../conventions.md#mr-006--regelwerk-cache-als-split-modul-verzeichnis). **Beide sind
> als Cache-Mechanik abgelöst:** es gibt weder `.harness/cache/` noch
> `make regelwerk-fetch` — die Baseline ist committet vendored
> ([`MR-007`](../conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)).
> Unverändert gültig bleibt hier die **Injektor-Mechanik** (Codex-Hook-Schema,
> awk-Encoder, kein Netz im Hook, sichtbare Degradation) — nur ihre Quelle ist
> jetzt der vendored Baum. Historische Einträge werden **nicht** umgeschrieben.

- **Datum:** 2026-06-14
- **Geltungsbereich:** [`harness/tools/`](../../harness/tools/), [`.claude/`](../../.claude/), [`.codex/`](../../.codex/), `.harness/cache/`, `CLAUDE.md`, `Makefile`, `.d-check.yml`
- **Ersetzt-Baseline-Regel:** keine — nach dem Wortlaut der Eintrags-Vorlage damit ein **Fork**.
  Der Rumpf unten setzte eine Abweichung: **Volltext-Injektion je Codex-Session** gegen
  [`modul-02-harness-bootstrap.md`](../../.harness/baseline/v5.18.0/regelwerk/modul-02-harness-bootstrap.md#greenfield-bootstrap-schritt-sequenz-modul-2)
  §Anmerkung zur vendored Baseline (Schritt 2), die das Nachschlagen pro Entscheidung verlangt
  *„ohne das ganze Regelwerk im Kontext zu halten"*. Diese Setzung ist mit
  [`MR-006`](../conventions.md#mr-006--regelwerk-cache-als-split-modul-verzeichnis) auf Index-only umgestellt und
  trägt nicht mehr (Kopf-Marke oben). Was hier fort gilt, ist die **Injektor-Mechanik** —
  Codex-Hook-Schema, awk-Encoder, kein Netz im Hook, sichtbare Degradation —, und über die sagt die
  Baseline am adoptierten Stand `v5.12.0` nichts: sie schreibt vor, dass das Regelwerk **nicht
  ganz** im Kontext steht, nicht, **wodurch** ein Teil hineinkommt. Dieselbe Lücke misst
  [`MR-035`](../conventions.md#mr-035--der-automatische-claude-kontext-trägt-eine-benannte-geschlossene-modul-auswahl)
  für die Gegenrichtung.
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
  [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)); **kein**
  Netz-Fetch im Hook (nur die lokale Kopie,
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)). Fehlender Cache
  (vor dem Fetch) → **sichtbare Warnung** mit `make regelwerk-fetch` (statt leer),
  exit 0 (degradiert sichtbar, blockt nichts; kein Netz im Hook — der Hinweis
  nennt nur den Maintenance-Befehl). Der Cache ist gitignored und vom Doc-Gate
  ausgenommen (`.d-check.yml` `scan.ignore`).
- **Begründung:** Die in AGENTS.md §1 verlangte Regelwerk-Lektüre war nur
  *erinnert*, nicht *erzwungen* (Steering-Befund aus slice-006). Der Hook macht
  sie zu Computational Feedforward — mit dem **echten** Text, nicht einer
  Eigenbau-Kurzfassung. **Codex** lädt den Volltext je Session (Kosten bewusst
  akzeptiert); **Claude** liest on-demand (kein Dauer-Aufschlag, aber **nicht**
  garantiert im Kontext — 10k/150k-Caps). Der awk-Encoder hält die node/jq-freie
  Linie.
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
- **Aktualisierung ([`MR-006`](../conventions.md#mr-006--regelwerk-cache-als-split-modul-verzeichnis)):** Seit slice-010 ist der Cache ein
  **Split-Modul-Verzeichnis** (`.harness/cache/agents-regelwerk/`,
  ZIP-sha256-gepinnt); der Codex-Hook injiziert nur den **Index** (`README.md`),
  Module werden on-demand gelesen.
