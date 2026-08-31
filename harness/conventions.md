# Harness-Konventionen

## Purpose

Repo-lokale Strukturregeln gegenüber der adoptierten Baseline. Bei
Konflikt mit einer kanonischen Quelle gilt diese (Source Precedence).

## Baseline

- **Konvention:** AI-Harness-Kurs
- **Regelwerk + Templates:** `v5.12.0` committet vendored
  (`.harness/baseline/v5.12.0/`, [`MR-007`](#mr-007--baseline-committet-vendored-statt-gefetchter-cache)); Regelwerks-Stand laut
  `regelwerk/README.md`: **Kurs-Welle 98 · 2026-08-26**
  (`sed -n '3p' .harness/baseline/v5.12.0/regelwerk/README.md`).
- **d-check:** der lebende Pin steht in `d-check.mk` (`DCHECK_IMAGE`/`DCHECK_DIGEST`) und, per
  go-Test daran gekoppelt, in `internal/emit/emit.go` — hier steht keine zweite Fassung davon
  ([`MR-027`](#mr-027--d-check-pin-v0650-ignore-marker-in-zwei-achsen-verengt) §Kein Wächter).
  Die Sprünge dieser Linie führen [`MR-009`](#mr-009--d-check-pin-sprung-und-codepath-ventile),
  [`MR-010`](#mr-010--d-check-gate-fragment-tool-generiert), [`MR-011`](#mr-011--zitat-verifikation-via-d-check-adoptiert-check-lines), [`MR-012`](#mr-012--d-check-pin-v0511-sources-verfügbar), [`MR-024`](#mr-024--d-check-pin-v0620-structure-verfügbar) und [`MR-027`](#mr-027--d-check-pin-v0650-ignore-marker-in-zwei-achsen-verengt).
- **Datum der Adoption:** 2026-06-13 (Templates-Stand damals: `templates-v4`).
  **Re-Baseline auf `v3.1.0`:** 2026-07-17 (slice-011/012); **auf `v3.5.0`:** 2026-07-19 (slice-019);
  **auf `v3.5.1`:** 2026-07-24 (slice-043); **auf `v3.5.2`:** 2026-07-26 (slice-049,
  Normativ-Delta in [`MR-015`](#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) entschieden);
  **auf `v5.12.0`:** 2026-08-28 (slice-081). Die Prozedur für diesen Sprung steht in
  [`ADR-0018`](../docs/plan/adr/0018-ziel-fassung-regiert-die-migration.md), der
  Verweis-Beschluss ist in
  [`ADR-0023`](../docs/plan/adr/0023-verweis-beschluss-traegt-ueber-den-sprung.md) gegen genau
  diesen Zielstand neu gehalten. **Wie viele Upstream-Releases dazwischenliegen, steht hier
  nicht:** die Zahl ist nur am lokalen Kurs-Klon zu messen, und kein Kommando dieses Repos gibt
  sie aus ([`MR-025`](#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 1).

## Adoptierte Konventions-Quellen

- **Extern (Kurs, kanonisch):** <https://github.com/pt9912/ai-harness-course/tree/v5.12.0/kurs/de>
  — auf den Tag `v5.12.0` gepinnt, **nicht** `main`-floating
  ([`LH-QA-02`](../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)). Der Ladeweg ist am
  2026-08-28 belegt, nicht behauptet: das Release-Asset `lab-regelwerk.zip` dieses Tags wurde
  containerisiert **zweimal unabhängig** geladen und trug beide Male denselben sha256, der als
  `BASELINE_ZIP_SHA256` gepinnt ist (`grep -m1 '^BASELINE_ZIP_SHA256' Makefile`); netzlos
  nachprüfbar ist daraus der Baum — `make baseline-verify` →
  `baseline-verify: v5.12.0 OK — 51 Dateien (Integritaet + Vollstaendigkeit, netzlos)`. **Die
  Dateizahl ist kein Erwartungswert** ([`MR-025`](#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2) — sie wandert mit dem Asset; tragend ist das `OK`. Ersetzt die frühere
  `raw…/main/…/agents-regelwerk.md`-Monolith-URL, die **404** liefert (der Monolith
  existiert upstream seit v2.0.0 nicht mehr — die Module leben unter `/kurs/de/`).
- **In-Repo (verkörperte Form):** die committet vendored Baseline
  `.harness/baseline/v5.12.0/{regelwerk,templates}/` ([`MR-007`](#mr-007--baseline-committet-vendored-statt-gefetchter-cache)) — die
  präsente, netzlose Sicht auf die kanonische Quelle; bei Konflikt gilt der Kurs.

## Adaptions-Block

### MR-000 — Baseline-Aussage

> **ÜBERHOLT: die 2-Strata-Klausel → [`MR-019`](#mr-019--technik-stratum-als-rang-2-der-source-precedence).** Die übrigen Setzungen dieses Eintrags gelten fort.
>
> **ÜBERHOLT: die Blankett-Klausel „keine inhaltlichen Adaptionen ggü. Baseline-Default", punktweise → `grep -n Blankett-Klausel harness/conventions.md`.** Die Ausnahmen sind eine **offene Menge** — jeder spätere Eintrag kann eine hinzufügen —, darum steht hier das Kommando, das sie ausgibt, und kein Link auf einen von mehreren. Wo kein Eintrag sie ausnimmt, gilt die Klausel fort; das ID-Schema und die Verzeichniskonvention dieses Eintrags sind unberührt.

- **Datum:** 2026-06-13
- **Geltungsbereich:** gesamtes Repo
- **Adaption:** keine inhaltlichen Adaptionen ggü. Baseline-Default.
  ID-Schema: `LH-FA-NN` / `LH-QA-NN`, `ADR-NNNN`, `CO-NNN`, `slice-NNN`,
  `MR-NNN`. **2-Strata-Spec** (Lastenheft → Architektur, keine separate
  Spezifikations-Datei) — entspricht dem Kurs-Default.
- **Begründung:** Initial-Setzung.
- **Auflösungs-Trigger:** permanent.

### MR-001 — Doc-Gate-Schärfung (matrix + Link-Pflicht + Anker-IDs)

> **ÜBERHOLT: die Zensus-Aussage zu `scan.ignore` samt ihrer Klassifikation → [`MR-029`](#mr-029--der-scanignore-zensus-wandert-und-sein-dritter-grund-ist-keine-scoping-aussage).** Die übrigen Setzungen dieses Eintrags gelten fort.

- **Datum:** 2026-06-13
- **Geltungsbereich:** `.d-check.yml` (Doc-Referenz-Gate)
- **Adaption:** Über die Baseline-Module (`links`, `anchors`, `ids`,
  `codepaths`) hinaus aktiviert: `matrix` (mechanische Referenz-Richtung/SDP —
  Spec-Straten verweisen nie abwärts auf ADR/Slice; Verweise auf
  superseded/deprecated ADRs verboten; `exclude-sections` für
  Historie/Geschichte), `spans` (Markdown-Span-Hygiene) sowie `ids` mit
  `link-policy: always` (Kennungen sind klickbare Links zur Quelle, Requirement-IDs
  mit Abschnitts-Anker; `exempt-paths`: `docs/reviews/**`, `CHANGELOG.md`) plus
  ein `MR`-Pattern (→ diese Datei). **`scan.ignore` führt heute vier Einträge, aus zwei
  Gründen** — beide sind **Scoping**, keine Gate-Lockerung nach
  [`AGENTS.md`](../AGENTS.md) §3.5, denn der Prüfumfang schrumpft nicht um Bestand, den dieses
  Repo autoritativ schreibt:
  1. **Vendored Fremd-Dokumente** — dieses Repo *spiegelt* sie, statt sie zu schreiben, und darf
     sie deshalb nicht nach seinen Regeln formen: `.harness/baseline/**`
     ([`MR-007`](#mr-007--baseline-committet-vendored-statt-gefetchter-cache)) und
     `docs/user/claude-hooks-referenz.md` (die Hooks-Referenz der Herstellerseite, netzlose
     Quelle der Payload-Messungen). Sie umzuschreiben, damit das Gate grün wird, hieße die Quelle
     zu verfälschen; sie zu scannen erzeugt Befunde gegen ihren Autor.
  2. **Kein Fließtext** — `**/*.template.md` sind Ziel-Form-Vorlagen mit Platzhaltern statt
     Verweisen, `.tmp/**` ist Wegwerf-Bestand. Beide tragen keine Aussage, die veralten könnte.
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

> **HISTORIE — der Cache-Teil ist seit slice-011 überholt → [`MR-007`](#mr-007--baseline-committet-vendored-statt-gefetchter-cache).**
> Der folgende Body beschreibt den Stand **vor** dem Split-Modul-Cache
> (Einzeldatei, Codex injiziert im Volltext); der Zwischenstand steht in
> [`MR-006`](#mr-006--regelwerk-cache-als-split-modul-verzeichnis). **Beide sind
> als Cache-Mechanik abgelöst:** es gibt weder `.harness/cache/` noch
> `make regelwerk-fetch` — die Baseline ist committet vendored
> ([`MR-007`](#mr-007--baseline-committet-vendored-statt-gefetchter-cache)).
> Unverändert gültig bleibt hier die **Injektor-Mechanik** (Codex-Hook-Schema,
> awk-Encoder, kein Netz im Hook, sichtbare Degradation) — nur ihre Quelle ist
> jetzt der vendored Baum. Historische Einträge werden **nicht** umgeschrieben.

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
- **Aktualisierung ([`MR-006`](#mr-006--regelwerk-cache-als-split-modul-verzeichnis)):** Seit slice-010 ist der Cache ein
  **Split-Modul-Verzeichnis** (`.harness/cache/agents-regelwerk/`,
  ZIP-sha256-gepinnt); der Codex-Hook injiziert nur den **Index** (`README.md`),
  Module werden on-demand gelesen.

### MR-005 — Harness-Tools unter harness/tools/ (Layout-Adaption)

- **Datum:** 2026-06-14
- **Geltungsbereich:** [`harness/tools/`](../harness/tools/), [`.claude/`](../.claude/), [`.codex/`](../.codex/), `Makefile`, `.d-check.yml`
- **Adaption:** Die ausführbaren Harness-Tools (Gate-Nachweis, Working-Tree-Hash,
  Command-Guard-Extraktor, SessionStart-Injektor + awk-Encoder) liegen unter
  `harness/tools/` statt dem Baseline-Default `tools/harness/`. **Eine Ausnahme, und
  sie ist keine Aufweichung:** der Span-Emitter (slice-059) ist ein **kompiliertes**
  Harness-Tool und liegt deshalb im Go-Modulbaum (`cmd/span-emit/` + `internal/span/`)
  — Go-Quellen können nicht unter `harness/tools/` liegen, ohne aus dem Modul zu
  fallen. Die Regel gilt für **Skripte**; die Shell-Hälfte desselben Slice
  (`harness/tools/span-check.sh`) liegt regelkonform hier. Wer das Layout für die
  Emission liest (slice-062/063), muss den Emitter also **zusätzlich** zu diesem
  Verzeichnis betrachten (Review-Befund LOW-3). Damit liegt die
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

### MR-006 — Regelwerk-Cache als Split-Modul-Verzeichnis

> **HISTORIE — überholt seit slice-011 → [`MR-007`](#mr-007--baseline-committet-vendored-statt-gefetchter-cache).**
> Der folgende Body beschreibt den **gefetchten, gitignorierten** Split-Modul-Cache
> (`.harness/cache/agents-regelwerk/`, `make regelwerk-fetch`). Beides existiert
> nicht mehr: die Baseline ist **committet vendored**
> ([`MR-007`](#mr-007--baseline-committet-vendored-statt-gefetchter-cache)).
> Übernommen wurden von hier: die Split-Modul-Form, das **Index-only-Inject** und
> das read-on-demand (samt des unten benannten Presence-Tradeoffs), sowie
> `regelwerk-check` als Drift-Monitor — dessen **Grenze** (er sieht nur das Asset
> des gepinnten Tags, keinen neuen Tag) [`MR-007`](#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
> ausdrücklich benennt. Der „wortgleich"-Wortlaut unten galt für v1.2.0 und wird
> **nicht** umgeschrieben.

- **Datum:** 2026-06-16
- **Geltungsbereich:** `Makefile`, [`harness/tools/`](../harness/tools/), `.harness/cache/`, `CLAUDE.md`, `AGENTS.md`, [`test/`](../test/); ergänzt [`MR-004`](#mr-004--sessionstart-regelwerk-injektor).
- **Adaption:** Der Regelwerk-Cache ist ein **Split-Modul-Verzeichnis**
  `.harness/cache/agents-regelwerk/` (21 Dateien: `grundlagen-*`, `modul-00`…`modul-16`,
  `README.md`-Index) statt der bisherigen Einzeldatei. `make regelwerk-fetch` zieht
  `lab-regelwerk.zip` vom Release-Tag (`REGELWERK_URL`), **ZIP-sha256-gepinnt**
  (`REGELWERK_SHA256`), verifiziert **vor** jeder Cache-Mutation und ersetzt den
  Cache via temp→`mv` (bei Fehler/Drift unverändert,
  [`LH-QA-02`](../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit); das `mv` ist
  atomar, das Replace als Ganzes nicht — der Cache ist gitignored/regenerierbar). Der
  Codex-SessionStart-Hook injiziert künftig **nur den Index** (`README.md`, ~3,7 KB)
  mit Pointer-Präfix aufs Cache-Verzeichnis; **beide Agenten** lesen das relevante
  Modul **on-demand**. awk-Encoder bleibt (kein node/jq,
  [`LH-QA-03`](../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)); **kein** Netz
  im Hook. Neue Maintenance-Abhängigkeit: `unzip` (host, wie `curl` bei
  `regelwerk-fetch`; nicht in `gates`, nicht im emittierten Zielrepo).
- **Tradeoff (bewusst):** Der Index-only-Inject **schwächt die Presence-Garantie**
  ggü. dem Codex-Volltext-Inject aus slice-007 (Lopopolo: „was nicht im Kontext
  ist, existiert nicht"). Gewinn: kein 212-KB-Aufschlag je Codex-Session,
  einheitliches read-on-demand für beide Agenten, kohärent zum Split-Cache. Die
  Bewegung bleibt im **inferential-feedforward**-Quadranten (Context Engineering)
  — die fail-closed-Gates (PreToolUse-Guard, Stop-Gate) sind **unberührt**, kein
  Durchsetzungs-Verlust.
- **Begründung:** Der 212-KB-Volltext war für Claude ohnehin nie geladen
  (10k/150k-Caps, [`MR-004`](#mr-004--sessionstart-regelwerk-injektor)-Nachtrag) und
  für Codex ein Per-Session-Kostenblock; das Split-ZIP serviert pro Modul. Quelle
  bleibt **wortgleich** (ZIP-`README.md`: derivative Sicht, bei Konflikt gilt die
  Kurs-Quelle) — **kein** selbst erzeugter Digest/Kurzfassung (kein Rückfall in die
  slice-007-Harness-Lüge).
- **Auflösungs-Trigger:** permanent; Re-Pin (`REGELWERK_SHA256`) + Tag-Bump bei
  Upstream-Release manuell. Read-only Drift-Überwachung: `make regelwerk-check`
  (slice-009) vergleicht `sha256(Upstream-ZIP)` gegen `REGELWERK_SHA256` und
  mutiert nichts — `regelwerk-fetch` *aktualisiert*, `regelwerk-check` *überwacht*
  (beide Maintenance/Netz, nicht in `gates`).

### MR-007 — Baseline committet vendored statt gefetchter Cache

- **Datum:** 2026-07-17
- **Geltungsbereich:** `.harness/baseline/`, `Makefile`, [`harness/tools/`](../harness/tools/), `.gitignore`, `.d-check.yml`, `AGENTS.md`, `CLAUDE.md`, [`harness/README.md`](README.md), [`test/`](../test/); löst den Cache-Teil von [`MR-004`](#mr-004--sessionstart-regelwerk-injektor)/[`MR-006`](#mr-006--regelwerk-cache-als-split-modul-verzeichnis) ab.
- **Adaption:** Regelwerk **und** Templates liegen **committet vendored** unter
  `.harness/baseline/<tag>/{regelwerk,templates}/` + `SHA256SUMS` (42 Dateien:
  21 + 21), netzlos auf jedem Checkout präsent — Baseline-Vorgabe aus Modul 2
  („nicht pro Lauf extern gefetcht"). `make regelwerk-fetch` entfällt; an seine
  Stelle tritt das **netzlose** `make baseline-verify` (in `gates` — anders als
  ein Netz-Fetch verletzt es offline-grün nicht,
  [`LH-QA-01`](../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). Die
  Geschwister-Lage ist funktional: die `../templates/…`-Ziel-Form-Verweise des
  Regelwerks lösen dadurch lokal auf (12 eindeutige Ziele, 0 tot — gemessen).
- **Setzung 1 — Provenienz ≠ Integrität (beide nötig).** `SHA256SUMS` ist
  **selbst erzeugt**: es beweist, dass der Baum sich seit dem Vendoring nicht
  bewegt hat, **nicht**, dass er vom offiziellen Release stammt. Die
  Upstream-Kette hängt allein an `BASELINE_ZIP_SHA256` (`Makefile`) — dem sha256
  des Release-Assets, gegen das **vor** dem Entpacken verifiziert wird. Beide
  Anker sind zu führen; wer nur `SHA256SUMS` hat, hat Integrität ohne Herkunft.
- **Setzung 2 — `SHA256SUMS`-Umfang.** Die Baseline schreibt nur *dass* die Datei
  existiert; Format, Umfang und Erzeugung sind unspezifiziert, und das ZIP liefert
  **keine** mit. Setzung: `sha256sum` über **alle** Dateien beider Bäume, Pfade
  relativ zu `<tag>/`, `LC_ALL=C`-sortiert, die Datei **selbst ausgenommen** (sie
  kann sich nicht selbst hashen — ihre Integrität trägt git).
- **Setzung 3 — Vollständigkeits-Check ist Pflicht, nicht Kür.** `sha256sum -c`
  prüft **nur, was gelistet ist**, und bleibt bei einer **zusätzlich eingelegten**
  Datei grün. `baseline-verify` vergleicht deshalb zusätzlich den Dateibestand
  gegen die Liste. Real vorgeführt (slice-011): geänderte Datei → rot; eingelegte
  Datei → `sha256sum -c` **grün**, `baseline-verify` **rot**. Ohne diesen Schritt
  wäre „prüft die Integrität der Arbeitskopie" überdehnt — ein stilles Grün.
- **Setzung 4 — `<tag>`-Politik.** Das Regelwerk sagt zu alten
  `<tag>`-Verzeichnissen nichts (Koexistenz vs. Ersetzen). Setzung: **ein Tag zur
  Zeit** (Ersetzen), Historie liegt in git. Der Tag-String hat **genau eine**
  Quelle: `BASELINE_TAG` (`Makefile`). `baseline-verify` und der SessionStart-Injektor
  **entdecken** das Verzeichnis (Glob) statt es zu kennen, `.d-check.yml` nutzt
  `.harness/baseline/**` — so ist ein Tag-Bump eine Zeile + der Baum, kein
  repo-weiter Grep ([`LH-QA-02`](../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)).
  Beide Werkzeuge **erzwingen** die Setzung: mehr als ein `<tag>`-Verzeichnis ist
  ein Fehler (Verify rot, Injektor warnt und injiziert **nichts** — er sucht sich
  nicht still einen aus).
- **Begründung:** Netzlose Präsenz auf jedem Checkout und Wegfall der
  Host-`unzip`-Abhängigkeit zahlen auf
  [`LH-QA-02`](../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)/[`LH-QA-03`](../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)
  ein; der Preis ist ein ~241 KB großer committeter Fremd-Blob, den `AGENTS.md` §1
  bisher ausdrücklich verbot (bewusst umgestellt). Der Baum ist **derivativ** und
  trägt kurs-eigene MR-/ADR-Kennungen (Beispiele, nicht die des Repos) → vom
  Doc-Gate ausgenommen (`scan.ignore`), sonst träfe ihn die `ids`-Link-Pflicht.
- **Auflösungs-Trigger:** permanent. **Upstream-Überwachung — und ihre Grenze:**
  `make regelwerk-check` (Maintenance/Netz, **nicht** in `gates`) vergleicht das
  Upstream-Asset **des gepinnten Tags** gegen `BASELINE_ZIP_SHA256`. Es erkennt
  damit ein **nachträglich verändertes Release-Asset** — **nicht** einen **neuen
  Tag**. Ein Upstream-Release bleibt unsichtbar, bis jemand die Release-Liste
  prüft; genau so entging dem Repo v3.0.0/v3.1.0, während sein Sensor auf v1.2.0
  „kein Drift" meldete. Diese Lücke schließt **`make baseline-freshness`** (slice-018):
  ein read-only Sensor auf die Release-*Liste* — er folgt dem `releases/latest`-Redirect
  und vergleicht den effektiven Tag gegen `BASELINE_TAG` (die **Tag-Achse** neben
  `regelwerk-check`s Asset-Achse). Maintenance/Netz, **nicht** in `gates` (offline-grün
  bleibt); der Sensor mutiert nichts (Re-Baseline bleibt die bewusste Operation oben).
  `baseline-verify` deckt weiterhin **keine** der beiden Upstream-Achsen ab — es prüft nur
  die eigene Arbeitskopie, nie den Upstream. **Generalisiert (slice-040):** die
  `releases/latest`-Tag-Mechanik von `baseline-freshness` lebt seit slice-040 als
  parametrierter Sensor `harness/tools/component-freshness.sh` (`name · pinned ·
  releases-latest-url`); `baseline-freshness` ist ein dünner Wrapper darum, und
  **`make freshness-golangci`** (Pin: `GOLANGCI_LINT_VERSION`) sowie
  **`make freshness-dcheck`** (Pin: `DCHECK_IMAGE`-Tag aus [`d-check.mk`](../d-check.mk))
  tragen dieselbe Read-only-/Nachtlauf-Disziplin auf zwei weitere Komponenten-Achsen —
  Maintenance/Netz, **nicht** in `gates` ([`LH-QA-01`](../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)),
  bash+curl ohne jq/node ([`LH-QA-03`](../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)). **Sonderquelle Go
  (slice-041):** die Go-Toolchain hat kein GitHub-`releases/latest` (`golang/go` redirected auf
  `.../releases`), darum ein eigener Wrapper `harness/tools/go-freshness.sh` — Fetch von
  `go.dev/VERSION?m=text` + Normalisierung (`go1.x.y` → `1.x.y`), dann derselbe wiederverwendete
  Vergleicher; **`make freshness-go`** (Pin: `GO_VERSION`) hängt ebenfalls im Nachtlauf.
  **Sonderquelle C++/ubuntu (slice-042):** der ubuntu-Base-Tag des emittierten C++-Skeletts
  (`DefaultCppVersion` in `internal/gen/cpp.go`) wird gegen das **Docker-Hub-LTS** geprüft — Wrapper
  `harness/tools/cpp-freshness.sh` holt die ubuntu-Tags (`hub.docker.com/v2/…/ubuntu/tags`) und
  extrahiert das aktuelle LTS (höchstes `NN.04` mit **geradem** `NN`; Interims `23.04`/`25.04`/`.10`
  raus), dann derselbe Vergleicher; **`make freshness-cpp`** hängt im Nachtlauf.
- **Reichweite des Drift-Jobs — ehrlich, nicht rund.** Er deckt die **Baseline**, **d-check**,
  **golangci-lint**, die **Go-Toolchain** und den **ubuntu-Base-Tag** ab. **Nicht** abgedeckt sind
  die drei übrigen digest-gepinnten Werkzeug-Images: **bats**, **shellcheck** und **actionlint** —
  sie altern unbeobachtet. Hier stand bis 2026-07-25 „damit deckt der Drift-Job jede versions-gepinnte
  Komponente ab"; das war eine Zusage über der halben Menge, aufgefallen erst, als ein Nutzer den
  veralteten bats-Pin von Hand fand (real **1.11.0**, während bats-core bereits weiter ist).
  Der Grund für die Lücke ist mechanisch: diese drei sind **nur per Digest** gepinnt, tragen also
  keinen Versions-String, den ein Vergleich lesen könnte. Der saubere Weg ist, die Version **aus dem
  gepinnten Image selbst** zu lesen (`bats --version`, `shellcheck --version`, `actionlint -version`)
  und gegen `releases/latest` zu vergleichen — dann gibt es keine zweite Quelle, die driften kann.
  Bis das gebaut ist, gilt die Lücke als **benannt**, nicht als geschlossen.
- **Migration:** Ein bestehender `.harness/cache/`-Cache aus
  [`MR-006`](#mr-006--regelwerk-cache-als-split-modul-verzeichnis) ist nach dem
  Umstieg ein nicht mehr regenerierbares Überbleibsel (`regelwerk-fetch` existiert
  nicht mehr) und **lokal zu löschen**. Frische Checkouts sind nicht betroffen —
  der Cache war gitignored und daher nie im Repo.

### MR-008 — Ausfüll-Templates referenziert statt kopiert

- **Datum:** 2026-07-17
- **Geltungsbereich:** die fünf in slice-013 gelöschten Repo-Template-Kopien
  `docs/plan/planning/slice.template.md`, `docs/plan/planning/welle.template.md`,
  `docs/plan/adr/NNNN-titel.template.md`, `docs/plan/carveouts/carveout.template.md`,
  `docs/reviews/review-report.template.md` — seit slice-016 als Tombstones referenz-weit
  über `codepaths.ignore-refs` deklariert ([`MR-009`](#mr-009--d-check-pin-sprung-und-codepath-ventile)), sodass hier die klaren
  vollen Pfade statt der früheren Glob-Workarounds stehen; ergänzt [`MR-007`](#mr-007--baseline-committet-vendored-statt-gefetchter-cache).
- **Adaption:** Das Repo hält **keine eigenen Kopien** der Ausfüll-Templates mehr.
  Einzige Quelle ist die committet vendored Baseline
  `.harness/baseline/<tag>/templates/…` ([`MR-007`](#mr-007--baseline-committet-vendored-statt-gefetchter-cache)). Ein neues Artefakt
  (Slice, ADR, Welle, Carveout, Review-Report) entsteht per **`cp` aus dem vendored
  Baum** und wird dann ausgefüllt — z. B.
  `cp .harness/baseline/$(BASELINE_TAG)/templates/docs/plan/planning/slice.template.md docs/plan/planning/open/slice-NNN-….md`.
- **Abweichung von der Baseline (Modul 2):** Modul 2 beschreibt die Templates in
  **zwei** Rollen — *vendored als Referenz-Form* **und** *kopiert-und-ausgefüllt als
  eigene Artefakte*. MR-008 behält die zweite Rolle (Artefakte entstehen weiter durch
  Kopieren-und-Ausfüllen), streicht aber die **dauerhaft im Repo gehaltene
  Blank-Kopie**: die Vorlage wird pro Artefakt frisch aus dem vendored Baum kopiert,
  nicht als `docs/…/*.template.md`-Dublette gepflegt.
- **Abgrenzung gegen [`LH-FA-02`](../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) (emittierte Struktur) — kein Widerspruch.**
  [`LH-FA-02`](../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) (rank-1) verlangt für die vom Go-Tool **emittierte**
  Zielstruktur weiterhin co-located `.template.md` für wiederkehrende Artefakte (ADR ·
  slice · welle · carveout · review-report) — dieselbe Liste, die MR-008 hier löscht.
  Das ist **keine** Kollision: MR-008 gilt **nur** für die eigenen Planungs-Artefakte
  *dieses* Repos, das die **volle** Baseline vendored ([`MR-007`](#mr-007--baseline-committet-vendored-statt-gefetchter-cache)) und deshalb
  referenzieren *kann*. Ein emittiertes Fremdrepo erhält nicht notwendig den ganzen
  vendored Baum → dort **braucht** es die co-located Kopien, und
  [`LH-FA-02`](../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) bleibt
  bindend. **MR-008 generalisiert ausdrücklich nicht** auf die Emissions-Logik
  (slice-003): wer sie umsetzt, folgt
  [`LH-FA-02`](../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3), nicht MR-008.
- **Nachzug 2026-07-21 ([`ADR-0005`](../docs/plan/adr/0005-ziel-repo-distribution.md)):** die obige
  Abgrenzung trägt nicht mehr. Ihre Prämisse — „ein emittiertes Fremdrepo erhält nicht notwendig den
  vollen vendored Baum" — ist durch die ADR aufgehoben: das Zielrepo fetcht seither die **volle**
  Baseline (Regelwerk **+ Templates**, [`LH-FA-09`](../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren))
  und *kann* referenzieren wie der Dogfood. Die Emissions-Logik folgt daher jetzt dem **referenzierten**
  Modell — kein Co-Location der wiederkehrenden Vorlagen mehr;
  [`LH-FA-02`](../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) ist auf 0.8.0 nachgezogen.
  Die Reconciliation wurde beim 0.7.0-CR übersehen; slice-024s Voll-Smoke deckte sie auf.
- **Begründung (empirisch, 2026-07-17 gemessen):** Die fünf bisher kopierten
  Blank-Templates waren **verbatim/nachhinkend** (null Repo-Adaptionen — jeder Diff
  gegen den vendored Baum war reines Upstream-Lag), **von nichts Stabilem
  referenziert** (kein Makefile/Hook/Test/README, nur die Slices, die sie gerade
  bearbeiteten) und ohnehin **d-check-exempt** (`**/*.template.md` in `scan.ignore`).
  Das Kopier-Modell lieferte hier also **reine Wartungskosten** (jeder Baseline-Bump
  erzwingt eine Reconciliation — slice-013 *war* diese Kosten) bei **null Nutzen**.
  Referenzieren beseitigt die Drift-Klasse dauerhaft.
- **Tag im Referenzpfad:** Verweise auf `.harness/baseline/<tag>/templates/…` tragen
  den Tag; beim Bump repinnt er mit `BASELINE_TAG` (dieselbe Mechanik wie überall). Ein
  tag-stabiler Zeiger (Symlink) ist bewusst **nicht** gebaut (YAGNI — aktuell verweist
  **nichts** dauerhaft auf die Templates; [`LH-QA-03`](../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)).
- **Nebeneffekt (benigne):** `carveout.template.md` war die einzige Datei unter
  `docs/plan/carveouts/*`; mit ihrer Löschung verschwindet das (leere) Verzeichnis (git
  trackt keine leeren Verzeichnisse). Kein aktives Artefakt braucht es — es kehrt
  zurück, sobald der erste Carveout entsteht (`cp` aus dem vendored Baum + `mkdir -p`,
  Modul 7). Konsistent damit, dass `open/`/`next/`/`done/` nur existieren, wenn sie
  Inhalt tragen.
- **Auflösungs-Trigger:** gilt, **solange das Repo seine Templates nicht adaptiert.**
  Wird an *einem* Template eine echte Repo-Adaption nötig, wird **genau dieses** wieder
  als Repo-Kopie geführt — mit MR-Eintrag, der die Adaption begründet — die übrigen
  bleiben referenziert. Der Nutzen-Beleg (verbatim/unreferenziert) ist dann für dieses
  eine Template neu zu prüfen.

### MR-009 — d-check-Pin-Sprung und Codepath-Ventile

- **Datum:** 2026-07-18
- **Geltungsbereich:** `harness.mk` (`D_CHECK_IMAGE`), `.d-check.yml`
  (`codepaths.exempt-paths`, `codepaths.ignore-refs`), [`docs/reviews/`](../docs/reviews/)
  (entfernte Zeilen-Marker), diese Datei (§Baseline-Version + MR-008-Geltungsbereich);
  ergänzt [`MR-001`](#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids).
- **Adaption:** Das gepinnte d-check-Image springt von **v0.10.0** auf **v0.46.0**
  (Digest in `harness.mk`, gegen den Release belegt,
  [`LH-QA-02`](../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)). Zwei seit d-check 0.34.0
  verfügbare `codepaths`-Ventil-Achsen werden adoptiert:
  **`exempt-paths`** nimmt `docs/reviews/**` **datei-weit** aus der Codepath-Prüfung (die
  Zeitdokumente frieren den Stand ihres Review-Laufs ein; die Lifecycle-Pfade
  `next/`→`in-progress/`→`done/` darin veralten per Definition). **`ignore-refs`** deklariert
  die fünf in slice-013 gelöschten Ausfüll-Templates
  ([`MR-008`](#mr-008--ausfüll-templates-referenziert-statt-kopiert)) **referenz-weit** als
  Tombstones, sodass normative Doku ihre klaren vollen Pfade nennen darf statt der bisherigen
  Glob-Workarounds.
- **Belegter Bedarf (kein spekulativer).** Über den Regelwerk-Zug slice-011…014 musste
  `` `d-check:ignore` `` **wiederholt von Hand** gesetzt werden, weil v0.10.0s `codepaths`
  nur `scope`/`roots` kannte: fünf Lifecycle-Wanderungen in Review-Reports, mehrere
  Template-Tombstones. Die beiden Ventil-Achsen ersetzen die verstreute Handarbeit durch
  zwei zentrale, begründete Config-Zeilen — im Geist von
  [`MR-001`](#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids) („Gate-*Anheben* →
  Steering-Loop, kein ADR nötig").
- **Trockenlauf vor dem Pin (Pflicht, belegt).** v0.46.0 gegen den unveränderten Baum mit
  unveränderter Config: **40 Dateien, 0 Befunde, Exit 0** — trotz **29 real veröffentlichter
  Minors** (0.11–0.46, ohne die nie existierten 0.13–0.16/0.20/0.21) kein Schema-Bruch und
  kein neu feuerndes Pflicht-Modul (die `modules:`-Liste ist explizit). Die in dieser
  d-check-Generation hinzugekommenen Module (`planning`, `commits`, `tracked`, `targets`, …)
  bleiben **opt-in** und werden hier **nicht** aktiviert — kein existierendes Target/Bedarf
  ([`LH-QA-01`](../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), kein
  halluziniertes Gate).
- **Kein Rückfall auf stilles Grün.** Jede Ventil-Zeile nennt, *was* sie ausnimmt und
  *warum*: `exempt-paths` nur `docs/reviews/**` (Zeitdokumente), `ignore-refs` nur die fünf
  konkret gelöschten Template-Pfade (bewusst **entfernt**, nicht *geplant* — die Abgrenzung
  aus slice-015 §6 gilt; ein geplanter Pfad bleibt Doc-führt-Code-folgt und kein Tombstone).
  Keine breite oder leere Liste.
- **Auflösungs-Trigger:** permanent; Re-Pin bei d-check-Release manuell (Trockenlauf
  wiederholen — seit [`MR-010`](#mr-010--d-check-gate-fragment-tool-generiert) via `DCHECK_DIGEST`,
  früher `D_CHECK_IMAGE`), `ignore-refs` wächst nur mit weiteren **bewusst entfernten** Artefakten.

### MR-010 — d-check-Gate-Fragment tool-generiert

- **Datum:** 2026-07-18
- **Geltungsbereich:** `d-check.mk` (aus `harness.mk` umbenannt), `Makefile` (`include`), §Baseline,
  [`harness/README.md`](README.md) §Sensors; ergänzt [`MR-009`](#mr-009--d-check-pin-sprung-und-codepath-ventile).
- **Adaption:** Das handgepflegte `harness.mk` wird durch das **tool-generierte** Fragment
  `d-check.mk` (aus `d-check --print-mk`, v0.46.0) ersetzt — die Ziel-Form
  (`.harness/baseline/<tag>/templates/Makefile`) segnet das ausdrücklich ab („Fragment frisch
  erzeugen: `d-check --print-mk`"). Effekte: (a) **`--network none`** auf jedem Run (härtet die
  Netzlosigkeit auf Container-Ebene, [`LH-QA-02`](../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)/[`LH-QA-03`](../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten));
  (b) **`DCHECK_IMAGE` (Tag) + `DCHECK_DIGEST` (Override, sticht den Tag)** statt des inline
  gepinnten `D_CHECK_IMAGE` aus [`MR-009`](#mr-009--d-check-pin-sprung-und-codepath-ventile) —
  Re-Pin ist eine `DCHECK_DIGEST`-Zeile; (c) das **volle** Target-Set lebt tool-generiert im
  Repo, die Recipe-Form pflegt d-check — seine Größe wächst mit dem Tool und steht mit ihrem
  Kommando in Setzung 2.
- **Setzung 1 — Namens-Adaption `doc-check` → `docs-check`.** Nur das Befund-Gate wird umbenannt:
  Ziel-Form-`Makefile`, Regelwerk `modul-13` und der bestehende Repo-Stand nennen es `docs-check`
  (mit „s"); `--print-mk` erzeugt `doc-check`. Bei jeder Neu-Erzeugung sind es vier kleine,
  dokumentierte Handgriffe: `doc-check`→`docs-check` (Target **und** Hilfetext), `DCHECK_DIGEST`
  pinnen, den adaptierten Kopfkommentar setzen und `doc-help`s Grep auf `docs?-` erweitern (damit
  das umbenannte Haupt-Target gelistet wird). Die advisory-Targets bleiben sonst **verbatim**
  (`doc-`-Präfix).
- **Setzung 2 — nur `docs-check` ist ein *behaupteter* Gate ([`LH-QA-01`](../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).** `d-check.mk`
  führt **zwölf** Targets (`grep -cE '^docs?-[a-z-]+:' d-check.mk` → **12**; `make doc-help` listet
  dieselben zwölf). Genau eines davon, `docs-check`, steht in `make gates`,
  [`AGENTS.md`](../AGENTS.md) §4 und [`harness/README.md`](README.md) §Sensors; die übrigen **elf**
  sind advisory/opt-in (`doc-trace`/`doc-complete`/`doc-doctor`/`doc-repair`/`doc-immutable`/
  `doc-commits`/`doc-planning`/`doc-tracked`/`doc-targets`/`doc-structure`/`doc-help`) — also
  **verfügbar, aber nicht als Gate behauptet**, exakt wie `regelwerk-check` (Makefile-Target, nicht
  in `gates`). Kein halluziniertes Gate: „behauptet" ≠ „vorhanden". Die Aufzählung **ist** die
  Grenzziehung: ein Target, das in ihr fehlt, ist weder als behauptet noch als advisory
  ausgewiesen — deshalb ist sie an den Re-Pin gebunden (§Auflösungs-Trigger) und nicht an das
  Datum dieses Eintrags.
- **Setzung 3 — `d-check.mk` (tool-eigener Name) statt `harness.mk`.** Der Rename trägt den Namen,
  den `--print-mk` selbst vergibt (Herkunft ist selbst-dokumentiert) und macht die Neu-Erzeugung
  mechanisch (`d-check --print-mk` → `d-check.mk`). Er ist ein **reiner git-mv-Commit vor** dem
  Inhalts-Rewrite (Hard Rule 3.3); `Makefile`-`include`/-Kommentar, §Baseline und der
  [`MR-009`](#mr-009--d-check-pin-sprung-und-codepath-ventile)-Verweis („Digest in …") sind
  nachgezogen. Historische `harness.mk`-Nennungen (z. B. im [`MR-009`](#mr-009--d-check-pin-sprung-und-codepath-ventile)-Body, in slice-016)
  bleiben als Zeitbezug stehen — sie feuern kein `codepaths` (root-level Datei, nicht unter `harness/`).
- **Begründung:** `--network none` schließt eine Netzlos-Lücke (das Gate erzwang es bisher nicht,
  auch wenn die aktiven Module hermetisch sind); `DCHECK_DIGEST` beseitigt die manuelle
  Digest-Chirurgie, die [`MR-009`](#mr-009--d-check-pin-sprung-und-codepath-ventile) noch von Hand
  machte; das tool-generierte Fragment beseitigt die Drift-Klasse „Hand-mk hinkt d-check nach" und
  stellt das volle, aktuelle Target-Set bereit.
- **Auflösungs-Trigger:** permanent; bei d-check-Release `d-check --print-mk` neu erzeugen,
  `doc-check`→`docs-check` re-adaptieren, `DCHECK_DIGEST` neu pinnen und die Target-Aufzählung in
  Setzung 2 gegen `make doc-help` abgleichen — das Set wächst mit dem Tool, die Aufzählung nur von
  Hand. **Dazu gehört die Fixture** `internal/emit/testdata/raw-print-mk.txt`, an der
  `TestAdaptMK_Fixture` dieselben vier Handgriffe prüft: sie friert eine ältere Tool-Ausgabe ein,
  und nachzuziehen ist nicht ihre Zeilenzahl, sondern ob `AdaptMK` an der **frischen** Ausgabe
  noch greift. Das misst je ein `grep -c` über der frischen `--print-mk`-Ausgabe für die fünf
  Anker, an denen die Funktion hängt — `DCHECK_IMAGE ?=`, `.PHONY: doc-check`, `doc-check:` am
  Zeilenanfang, die **leere** `DCHECK_DIGEST ?=`-Zeile und `'^doc-[a-z-]+:`; steht jeder genau
  einmal (über v0.65.0 am 2026-08-28 alle fünf **1**, wie in der Fixture), kostet ihr Alter
  nichts. Fehlt einer, ist die Fixture zu erneuern, denn dann trifft der Test eine Form, die das
  Tool nicht mehr liefert. Ein **stilles** Grün ist das in keinem Fall: `AdaptMK` bricht auf drei
  der vier Handgriffe hart ab (Rename, `doc-help`-Grep, Digest-Pin) und auf dem fehlenden Anker
  dazu; der vierte Handgriff — der Adopter-Kopf — kann nicht fehlschlagen, weil der Rumpf erst am
  Anker beginnt. Maintenance-Override (Dry-Run) via `DCHECK_DIGEST=…`/`DCHECK_IMAGE=…`, nicht mehr
  `D_CHECK_IMAGE=…`.

### MR-011 — Zitat-Verifikation via d-check adoptiert (check-lines)

- **Datum:** 2026-07-19
- **Geltungsbereich:** `d-check.mk` (`DCHECK_IMAGE`/`DCHECK_DIGEST`), `.d-check.yml`
  (`codepaths.check-lines`), `internal/emit/emit.go` (emittierter Default-Pin), §Baseline-Version;
  setzt [`MR-009`](#mr-009--d-check-pin-sprung-und-codepath-ventile)/[`MR-010`](#mr-010--d-check-gate-fragment-tool-generiert) fort.
- **Adaption:** Das gepinnte d-check-Image springt **v0.46.0 → v0.50.0** (Digest in
  `d-check.mk`, **dreifach belegt**: lokaler RepoDigest · d-check-Closure-Notiz/Release-Run ·
  `imagetools`-Registry-Inspektion, [`LH-QA-02`](../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)). Die seit v0.50.0 verfügbare
  **Zeilenreferenz-Prüfung** `codepaths.check-lines: true` wird aktiviert: sie verifiziert je
  Inline-Code-Pfad mit `datei:<von>-<bis>` die Existenz der Zieldatei sowie `bis ≤ Zeilenzahl`
  und `von ≤ bis`. Das ist ein **additives Property am bereits aktiven `codepaths`-Modul**
  (nicht-leerer Prüfbereich via `docs-check`) — **kein** eigenständiger Gate-Name in
  [`AGENTS.md`](../AGENTS.md) §4 / [`harness/README.md`](README.md) §Sensors
  ([`LH-QA-01`](../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- **Emitter-Pin gekoppelt (Tier-1-Drift).** Der d-check-Default-Pin des Bootstrap-Tools
  (`internal/emit`s `DefaultImage`/`DefaultDigest`) ist per go-test an `d-check.mk` gekoppelt
  und zieht mit; die *emittierte* Starter-Config bleibt `modules: [links, anchors]` (codepaths
  dort auskommentiert → **kein** `check-lines`) — Emitter ≠ Dogfood.
- **Löst slice-015 auf.** Der Slice wollte ursprünglich einen lokalen bash-Sensor
  `make cite-check` bauen; dieselbe Fähigkeit ist seit v0.50.0 (d-check-slice-079) nativ
  ausgeliefert. Der Eigenbau entfällt — eine zweite Implementierung derselben Prüfung wäre
  reine Wartungslast ([`LH-QA-03`](../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)).
- **Trockenlauf vor dem Pin (Pflicht, belegt — [`MR-009`](#mr-009--d-check-pin-sprung-und-codepath-ventile)-Muster).** Beide Läufe netzlos
  (`--network none`): (a) v0.50.0 gegen unveränderte Config → **0 Befunde, Exit 0**
  (Pin-Sprung inert; die explizite `modules:`-Liste immunisiert gegen neue Default-Module);
  (b) v0.50.0 mit `check-lines: true` → **0 Befunde, Exit 0** über dem realen Korpus (die
  Zähne unabhängig belegt: `citation-out-of-range` feuert real auf eine Out-of-range-Referenz). Die einzige inhaltliche `--print-mk`-Fragment-Differenz zu v0.46.0: die fünf
  fokussierten advisory-Recipes gewinnen je `--disable citations` (18. Modul neu, opt-in) —
  verbatim vom Tool übernommen.
- **`citations`-Modul bewusst nicht aktiviert.** Das eigenständige verbatim-Modul feuert nur
  auf `d-check:cite`-Direktiven; davon trägt das Repo null → es zu aktivieren wäre ein nie
  feuerndes Gate ([`LH-QA-01`](../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). Adoption erst mit einem realen Zitat-Direktiven-Korpus
  (eigener Slice, eigenes False-Positive-Risiko).
- **Kein Rückfall auf stilles Grün / keine spekulative Exemption.** Von den real vorhandenen
  Inline-Code-Zeilenreferenzen (alle in eingefrorenen `done/`-Slices) werden nach
  `codepaths.roots` zwei tatsächlich zeilen-geprüft und bestehen heute. Eine spekulative
  `done/**`-Exemption gegen künftige Frozen-Doc-Drift wäre die breite, unbelegte Liste, vor der
  [`MR-009`](#mr-009--d-check-pin-sprung-und-codepath-ventile) warnt; sie unterbleibt — der konkrete Fall wird bei Eintritt belegt behandelt.
- **Auflösungs-Trigger:** permanent; Re-Pin bei d-check-Release manuell (Trockenlauf
  wiederholen, [`MR-010`](#mr-010--d-check-gate-fragment-tool-generiert) §Auflösungs-Trigger); die `citations`-Aktivierung ist ein eigener
  Slice, sobald der Direktiven-Korpus nicht-leer ist.

### MR-012 — d-check-Pin v0.51.1 (sources verfügbar)

- **Datum:** 2026-07-19
- **Geltungsbereich:** `d-check.mk` (`DCHECK_IMAGE`/`DCHECK_DIGEST`), `internal/emit/emit.go`
  (emittierter Default-Pin), §Baseline-Version; setzt [`MR-011`](#mr-011--zitat-verifikation-via-d-check-adoptiert-check-lines) fort.
- **Adaption:** Das gepinnte d-check-Image springt **v0.50.0 → v0.51.1** (Digest
  `sha256:fede3d02…`, **dreifach belegt**: lokaler RepoDigest · `imagetools` · d-check-`version.md`/
  Handbuch, [`LH-QA-02`](../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)). **Zweck:** das opt-in-Modul `sources`
  (19., Netz, seit v0.51.0) **verfügbar** machen — Vorbedingung für die geplante `sources`-Adoption
  (slice-020: ersetzt den Eigenbau `regelwerk-check` durch das tool-gelieferte Content-Pin-Modul).
  **`sources` ist hier NICHT aktiviert** (leer aktiviert wäre ein Phantom-Gate,
  [`LH-QA-01`](../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- **Trockenlauf vor dem Pin (Pflicht, belegt — [`MR-009`](#mr-009--d-check-pin-sprung-und-codepath-ventile)-Muster).** v0.51.1 gegen die
  unveränderte Config, netzlos: **0-Befund-Differenz** zum v0.50.0-Stand (`sources` opt-in/Netz/nie
  Default → inert; Handbuch v0.51.1: „ohne aktives `sources` byte-identisch" — hier gemessen bestätigt).
  Einzige inhaltliche `--print-mk`-Fragment-Differenz zu v0.50.0: `--disable sources` in den fünf
  fokussierten advisory-Recipes (verbatim vom Tool, wie damals `--disable citations`).
- **Emitter-Pin gekoppelt (Tier-1-Drift).** `internal/emit`s `DefaultImage`/`DefaultDigest` zieht per
  go-test mit (`TestDefault…_MatchesCanonical` liest `d-check.mk`); die emittierte Starter-Config bleibt
  `modules: [links, anchors]` (Emitter ≠ Dogfood).
- **Auflösungs-Trigger:** permanent; bei d-check-Release `d-check --print-mk` neu erzeugen + Digest neu
  pinnen ([`MR-010`](#mr-010--d-check-gate-fragment-tool-generiert) §Auflösungs-Trigger).

### MR-013 — regelwerk-check auf d-check `sources` (Tool statt Skript)

- **Datum:** 2026-07-19
- **Geltungsbereich:** `Makefile` (`regelwerk-check`-Recipe), `.d-check.yml` (`sources:`-Block),
  `test/sources-pin.bats` (Kopplung); nutzt das mit [`MR-012`](#mr-012--d-check-pin-v0511-sources-verfügbar) verfügbar gemachte Modul.
- **Adaption:** Das Maintenance-Target `make regelwerk-check` (Asset-Content-Drift der vendored
  Baseline gegen den Upstream) wird vom Eigenbau (`curl` + `sha256sum`) auf das d-check-Modul
  `sources` (opt-in, Netz, seit v0.51.0) umgestellt — „Tools verteilen statt Skripte pflegen". Der
  `.d-check.yml`-`sources:`-Eintrag pinnt das Release-Asset (`unpack: none` = Roh-Byte-Hash);
  `source-drift` meldet Abweichung mit vollem Ist-Hash, `source-unreachable` den Netzfehler. **Der
  Target-Name `regelwerk-check` bleibt** (Kontinuität, keine Referenz-Churn; frozen MR-Historie
  beschreibt weiter den Bash-Stand ihrer Zeit).
- **Zwei-Pin-Kopplung (Setzung).** Der Baseline-Asset-Hash lebt **kanonisch** im `Makefile`
  (`BASELINE_ZIP_SHA256`, [`MR-007`](#mr-007--baseline-committet-vendored-statt-gefetchter-cache) Setzung 1 — die Re-Baseline nutzt ihn) und **dupliziert** im
  `.d-check.yml`-`sources:`-Block (d-check liest nur seine Config). Gegen stille Divergenz koppelt
  **`test/sources-pin.bats`** beide **fail-closed in `make gates`** (netzlos): `sources`-`sha256` ==
  `BASELINE_ZIP_SHA256`, `sources`-`url` trägt `BASELINE_TAG`. Eine Re-Baseline muss beide Pins
  bewegen — der Test erzwingt es.
- **`sources` NICHT in `modules:`** ([`LH-QA-01`](../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)): es ist ein Netz-Modul und bräche den netzlosen
  `docs-check`/`make gates`. Aktiviert **nur** via `make regelwerk-check` (`--enable sources`, auf
  `sources` isoliert). `make gates` bleibt offline-grün; die Netz-Prüfung ist Maintenance/CI (wie
  `baseline-freshness`).
- **Unpack-Setzung (gemessen).** `unpack: none` (Roh-Bytes) — nicht `unpack: zip` (reihenfolge-
  invariantes Content-Manifest): der bestehende `BASELINE_ZIP_SHA256` ist ein Roh-Byte-Hash, und die
  Vendoring-Prüfung ([`MR-007`](#mr-007--baseline-committet-vendored-statt-gefetchter-cache)) verifiziert dieselben Roh-Bytes vor dem Entpacken. Gemessen:
  `unpack: none` → 0 Drift; `unpack: zip` mit demselben Hash → `source-drift` (anderer Hash-Raum).
- **Auflösungs-Trigger:** permanent; bei Re-Baseline beide Pins nachziehen (der Kopplungstest
  erzwingt es); bei d-check-Release neu gepinnt ([`MR-012`](#mr-012--d-check-pin-v0511-sources-verfügbar)).

### MR-014 — CI auf frischem Klon (GitHub Actions)

- **Datum:** 2026-07-20
- **Geltungsbereich:** `.github/workflows/ci.yml` (neu), `Makefile` (`ACTIONLINT_IMAGE`,
  `ci-lint`-Target, in `gates`), [`AGENTS.md`](../AGENTS.md) §4, [`harness/README.md`](README.md) §Sensors;
  löst die seit [`MR-003`](#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung) offene
  „CI ist dort das Netz"-Restlücke ein.
- **Adaption:** GitHub Actions fährt bei **jedem Push und PR** `make gates` + `make smoke` +
  `make mutate` — jeder Job **frisch ausgecheckt**. Das schließt die
  [`MR-003`](#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)-Restlücke: der lokale
  Stop-Hook gibt einen cleanen Tree **ohne** `.harness/state/` frei (kein Nachweis prüfbar), CI ist
  dort die Absicherung. Zugleich bekommt `make mutate` (slice-026) seinen mechanischen
  **Pro-Push-Auslöser** — die Durchsetzungs-Hälfte von dessen Befund N-6, die der lokale Hook nicht
  leisten kann (er deckt nur `make gates`).
- **Setzung 1 — nur `make`-Targets, keine zweite Gate-Definition.** Die Workflow-Steps rufen
  ausschließlich `make <target>` auf; was ein Gate *ist*, steht weiterhin allein im Makefile
  (Geist von [`MR-010`](#mr-010--d-check-gate-fragment-tool-generiert): eine Quelle, nicht zwei). Ein
  CI-Step, der Build-Logik dupliziert, driftet gegen den lokalen Lauf und ist verboten.
  **Nachtrag 2026-07-25 (slice-048) — Präzisierung, keine Aufweichung.** Die Setzung meint
  „**eine** Quelle je Check", und `make <target>` ist die **Regelform**, in der das erreicht wird —
  nicht der Zweck selbst. Deshalb gilt: **ein Check wird nie in der Workflow-YAML definiert.** Er
  lebt als versioniertes, von `shell-lint` gedecktes Artefakt im Repo (ein `make`-Target oder ein
  Skript unter `harness/tools/`); der Workflow-Step **ruft** ihn nur auf. Ein Inline-Prüfblock in
  der YAML bleibt verboten — unabhängig davon, auf welchem Runner er liefe.
  **Warum die Regelform hier nicht greift (gemessen, nicht angenommen):** der Plattform-Start-Smoke
  in `release.yml` läuft auf sechs Runnern, und `make` ist auf den Windows- und macOS-Images
  **nicht** installiert (an den Runner-Images-Readmes für `windows-2025` und `macos-26` geprüft,
  <https://github.com/actions/runner-images>, Stand 2026-07-25; die übrigen `make`-losen Labels
  wurden nicht einzeln geprüft). Ein Aufruf `make start-smoke` wäre dort schlicht nicht
  ausführbar. Der Check liegt daher als `harness/tools/start-smoke.sh` im Repo und wird auf
  **allen** sechs Runnern gleich aufgerufen — bewusst **nicht** gesplittet in „`make` auf Linux,
  Skript sonst": ein Split erzeugte genau die zwei Definitionen, die die Setzung verhindert.
- **Setzung 2 — Frequenz nach Sensor-Klasse.** „Alles pro Push" für die hermetischen Sensoren
  (`gates`/`smoke`/`full-smoke`/`mutate`); die **Netz-Sensoren** (`regelwerk-check`,
  `baseline-freshness`, `freshness-golangci`/`-dcheck`/`-go`) laufen **nur nächtlich**
  (`schedule`). Grund: sie erreichen einen Fremd-Host (Kurs-Release, golangci-lint/d-check/Go);
  ein Upstream-Ausfall ist kein Defekt des Commits und darf keinen Push röten — sonst werden Gates
  umgangen ([`LH-QA-01`](../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)-Geist auf Prozess-Ebene).
  **Seit dem Split (Nachtrag unten) ist diese Trennung strukturell** (zwei Workflow-Dateien) statt
  per `if: github.event_name` in einer Datei.
- **Setzung 3 — `ci-lint` ist ein Gate.** actionlint prüft `.github/workflows/` (gepinntes Image,
  Docker-only, [`ADR-0003`](../docs/plan/adr/0003-go-native-binaries.md)) und läuft **in** `make gates`:
  der Workflow ist ein reales committetes Artefakt (nicht-leerer Prüfbereich,
  [`LH-QA-01`](../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)), und ein Syntaxfehler
  darin ist **lokal vor dem Push** fangbar statt erst im ersten Actions-Lauf — das lokale
  Gegenbeispiel-Gate zur Zusage „die CI läuft" ([`AGENTS.md`](../AGENTS.md) §3.6).
- **Setzung 4 — Runner + Actions gepinnt, so weit es geht ([`LH-QA-02`](../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)).** `runs-on: ubuntu-24.04`
  (benannte Version, **nicht** `ubuntu-latest`); `actions/checkout` per **Commit-SHA** gepinnt
  (`@fbc6f399…` = v5.1.0, seit dem Nachtrag unten; zuvor `@11bd719…` = v4.2.2), nicht per
  wanderndem `@v5`. **Grenze:** ein GitHub-**hosted** Runner-Image
  ist nicht *digest*-pinnbar (das erlauben nur self-hosted/Container-Jobs) — `ubuntu-24.04` benennt
  eine Version, deren Paketstand GitHub periodisch aktualisiert. Die Reproduzierbarkeit der *Checks*
  trägt daher nicht der Runner, sondern die **digest-gepinnten Tool-Images** der `make`-Targets
  (bats/shellcheck/actionlint/d-check/golang/golangci); der Runner liefert nur Docker + Checkout.
- **Grenze — nicht lokal rot-sehbar.** Der Workflow selbst läuft auf GitHub; `ci-lint` belegt nur
  seine **Syntax**, nicht sein **Verhalten**. Ob `make gates` auf einem *wirklich* frischen Klon grün
  ist, zeigt erst der erste Actions-Lauf. **Lokal so weit belegt wie möglich** (Verifikation
  slice-027): `git clone` in ein frisches tmp ohne `.harness/state/` → `make gates` Exit 0; offen
  bleibt allein die GitHub-gehostete Ausführung.
- **Nachtrag 2026-07-24 — Split + `workflow_dispatch` + checkout v5.** Der Workflow ist in **zwei
  Dateien** getrennt: `.github/workflows/ci.yml` trägt nur die hermetischen Pro-Push-Sensoren
  (`gates`/`smoke`/`full-smoke`/`mutate`), `.github/workflows/upstream-drift.yml` die Netz-Sensoren.
  Damit ist die Sensor-Klassen-Trennung (Setzung 2) strukturell statt per `if: github.event_name`.
  `upstream-drift.yml` trägt **`schedule` (01:00 UTC) + `workflow_dispatch`** — Letzteres gibt einen
  „Run workflow"-Button, um den Drift-Lauf **manuell** anzustoßen (z. B. sofortige Gegenprüfung nach
  einem gemeldeten Release), ohne bis zum Nachtlauf zu warten. Beide Dateien folgen weiter Setzung 1
  (nur `make`-Targets); `ci-lint`/actionlint (Setzung 3) prüft `.github/workflows/` **glob**, deckt
  also beide. Zugleich `actions/checkout` **v4.2.2 → v5.1.0** (`@fbc6f399…`, weiter SHA-gepinnt,
  [`LH-QA-02`](../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)) — Auslöser war die GitHub-Warnung
  „Node.js 20 is deprecated"; v5 läuft auf Node 24, `ubuntu-24.04` trägt das, die `checkout`-API ist
  unverändert.
- **Auflösungs-Trigger:** permanent; `ACTIONLINT_IMAGE` bei Bedarf neu pinnen (wie
  `BATS_IMAGE`/`SHELLCHECK_IMAGE`); `actions/checkout` bei Node-Deprecation neu auf den dann
  aktuellen SHA-Pin heben.

### MR-015 — Change Request bei Personalunion von Auftraggeber und Entwickler

> **ÜBERHOLT: dieser Eintrag, mit einer Ausnahme → [`MR-036`](#mr-036--die-change-request-regel-bei-personalunion-steht-jetzt-in-der-adoptierten-baseline).** Der Cutoff-Absatz (permanente Ausnahme von rückwirkender Prüfung) bindet als eigenständiges Präzedens fort — [`AGENTS.md`](../AGENTS.md) §3.7 und [`MR-025`](#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) zitieren ihn.

- **Datum:** 2026-07-26
- **Geltungsbereich:** `spec/lastenheft.md` §7 Historie (**Form künftiger** Einträge, nicht die
  bestehenden) und die Commit-Disziplin um diese Datei. [`AGENTS.md`](../AGENTS.md) bleibt
  **unverändert**: dies ist eine MR-Adaption, **keine** neue Hard Rule — ob die Setzung in den
  Hard-Rule-Katalog gehört, entscheidet der Slice, der ihren Sensor baut (s. §Durchsetzung).
  Adoptiert den Normativ-Delta, den die Baseline `v3.5.2` mitbringt
  (`.harness/baseline/v3.5.2/regelwerk/grundlagen-konventionen.md`, §Spec-Stratifizierung).
- **Der adoptierte Wortlaut** (verbatim aus dem vendored Baum, nicht paraphrasiert):

  > „Change Request" ist **bewusst kein Harness-Konstrukt** — kein `CR-*`-ID-Schema, keine eigene
  > Datei, kein Gate — sondern der *externe* Vorgang, in dem eine Vertragsänderung mit dem
  > Auftraggeber vereinbart wird. Im Repo hinterlässt ein *angenommener* Change Request nur einen
  > **Fußabdruck**: ein Version-Bump des Lastenhefts, eine Zeile in dessen `## Historie` mit
  > Verweis auf den externen CR (Ticket, Vertragsanhang), und die geänderten `LH-*`/`HSM-*`
  > selbst. Abgelehnte oder schwebende CRs leben außerhalb des Repos. Weil nur dieser externe
  > Prozess das Lastenheft ändern darf, gilt die Hard Rule für *jede* interne Quelle: **weder ADR
  > noch Slice dürfen `LH-*` je ändern** — sie referenzieren nur.

- **Ist-Messung gegen die reale Praxis (2026-07-26, drei Achsen — zwei konform, eine adaptiert):**
  (1) *Kein `CR-*`-ID-Schema, keine CR-Datei, kein Gate* — **konform**: `spec/lastenheft.md` führt
  `CR:`-Prosa in der Änderungs-Spalte, keine IDs, keine Dateien, kein Target.
  (2) *Fußabdruck = Version-Bump + Historie-Zeile + geänderte Anforderungs-IDs* — **konform**:
  13 Zeilen 0.1.0…0.13.0, Spalte „Verweis" vorhanden, Header-Version mitgezogen.
  (3) *Verweis zeigt auf den **externen** CR; keine interne Quelle ändert `LH-*`* — **hier war zu
  entscheiden**: die Verweise zeigen nach innen (`slice-017-Folge`, `Messmethoden-CR`), und
  Zeile 0.13.0 trägt wörtlich „Getrieben von slice-048".
- **Warum das keine Schlamperei ist, sondern eine Struktur-Eigenheit.** Dieses Repo hat keinen
  externen Auftraggeber — es ist sein eigener. Die Auftraggeber-**Rolle** ist besetzt (der Nutzer),
  nur die **Ticket-Form** fehlt. Zu entscheiden war daher nicht „haben wir die Regel gebrochen",
  sondern **woran man nachträglich erkennt**, ob eine Lastenheft-Änderung eine angenommene
  Vertragsänderung war oder ein Nebeneffekt der Implementierung.
- **Setzung 1 — der externe Vorgang ist die Nutzer-Entscheidung, und sie geht dem Slice voraus.**
  Der annehmende Akt ist die Entscheidung des Nutzers in der Sitzung, gefällt **vor** dem
  umsetzenden Slice („Schritt 0, Doc-führt vor Code"). Was die Baseline-Regel trägt, ist nicht die
  Externalität des Ticket-Systems, sondern die **Trennung der Entscheidung von der Umsetzung** —
  und die ist hier real herstellbar.
- **Setzung 2 — die Trennung ist am Commit ablesbar, nicht an der Prosa.** Ein angenommener CR
  landet **ab diesem Eintrag** in einem **eigenen Commit**, der **ausschließlich**
  `spec/lastenheft.md` ändert und **vor** dem `open → in-progress`-Move des umsetzenden Slice
  liegt. Damit ist die Frage nachträglich mechanisch beantwortbar:
  `git log -- spec/lastenheft.md` + `git show --stat`.
- **Setzung 2 ist eine NEUE Disziplin, keine Beschreibung des Ist-Standes** — gemessen, nicht
  geschätzt. *(Die erste Fassung dieses Eintrags behauptete hier das Gegenteil; der Review zu
  slice-049 hat sie widerlegt. Der Befund ist die eigene Klasse dieses Repos —
  [`AGENTS.md`](../AGENTS.md) §3.6, „Zusage weiter als Abdeckung" — und wird darum stehen
  gelassen statt geglättet.)* **Ist-Messung 2026-07-26:** **16 Commits** berühren
  `spec/lastenheft.md`; **6** ändern sie allein (`5c4930b`, `9ce4721`, `af0d454`, `2c8227b`,
  `2879429`, `27628b5`), **10 bündeln** sie. Die Bündel zerfallen in drei Klassen:
  **sieben Entscheidungs-Bündel**, die das Lastenheft gemeinsam mit dem **ADR** tragen, der die
  Entscheidung trug (`43f1eda`, `65f4bcf`, `ec3af11`, `a0e74f1`, `bc447fe`), bzw. mit
  [`harness/conventions.md`](conventions.md) (`beec837`) oder einer Slice-Datei (`4b0d0d5`);
  der **Initial-Bootstrap** (`d30db38`, 21 Dateien); und **zwei rein redaktionelle** Berührungen
  (`c615da7` — Link-Form einer Historie-Zeile bei der Doc-Gate-Schärfung; `7b717f4` —
  Zeilenreihenfolge 0.12.0/0.13.0 im slice-048-Fix).
- **Was der Ist-Stand trotzdem belegt.** Keine **Anforderung** wurde je in einem
  Slice-Implementierungs-Commit **inhaltlich** geändert: die beiden slice-nahen Berührungen sind
  genau die zwei redaktionellen. Die **substanzielle** Regel hält also; das **mechanische**
  Merkmal wird hier neu eingeführt. Es gilt **auch für rein redaktionelle** Änderungen —
  `c615da7`/`7b717f4` sind der Beleg, dass genau die das Signal verwischen.
  **Cutoff:** geprüft wird ab dem Commit, der diesen Eintrag trägt. Ein Sensor, der die Historie
  mitprüfte, wäre dauerhaft rot (10 von 16) und entwertete die Setzung, statt sie zu tragen.
- **Setzung 3 — die Verweis-Spalte nennt die annehmende Instanz, die Änderungs-Spalte den Anlass.**
  Künftige Zeilen tragen im Verweis den annehmenden Akt (`Nutzer-Entscheidung YYYY-MM-DD`), nicht
  den umsetzenden Slice; der Anlass (ein ADR, ein Slice-Befund) bleibt in der Änderungs-Spalte.
  Das ist die **einzige** Abweichung vom Baseline-Wortlaut, und sie ist eine Ersetzung des
  fehlenden externen Belegs, keine Aufweichung.
- **Die bestehenden 13 Zeilen werden NICHT umgeschrieben.** Ein Slice, der zur Adoption dieser
  Regel `spec/lastenheft.md` anfasst, widerlegt sie im Vollzug — slice-049 verankert das
  ausdrücklich in seiner DoD. Die Zeilen sind nach dieser Lesart **einzuordnen**, nicht zu
  korrigieren: „Getrieben von slice-048" nennt den **Anlass** der Entscheidung, nicht ihren
  Urheber. Eine Angleichung wäre ein eigener CR mit eigenem Trigger.
- **Durchsetzung — benannt, nicht geschlossen (ehrlich, kein stilles Grün).** Die Regel lebt heute
  allein im **inferential-feedforward**-Quadranten: kein Sensor prüft, ob ein Commit
  `spec/lastenheft.md` gemeinsam mit anderen Dateien ändert. Mechanisierbar wäre sie (genau diese
  Bedingung ist ein Befund) — gebaut ist sie **nicht**. Das ist dieselbe Klasse, aus der
  [`AGENTS.md`](../AGENTS.md) §3.6 und `make mutate` entstanden sind („Hard Rule nur in einem
  Quadranten ist halb durchgesetzt"); der Sensor ist ein Roadmap-Kandidat, keine Zusage dieses
  Eintrags.
- **Kein ADR nötig.** Die Adoption **verschärft** (eine zusätzliche Commit-Disziplin, eine engere
  Verweis-Form); [`AGENTS.md`](../AGENTS.md) §3.5 verlangt einen ADR für **Senkungen**, und
  [`MR-001`](#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids) hält „Anheben →
  Steering-Loop" fest. `spec/lastenheft.md` bleibt in slice-049 unberührt (belegt per
  `git diff --stat`).
- **Auflösungs-Trigger:** Setzung 3 fällt, sobald ein **externer** Auftraggeber existiert — dann
  zeigt der Verweis wieder auf Ticket/Vertragsanhang, wie die Baseline es schreibt. Setzung 1 und 2
  bleiben permanent (sie sind die Substanz, nicht der Ersatz). Bei einem Baseline-Bump, der diesen
  Abschnitt erneut ändert, ist die Adaption neu zu prüfen.

### MR-016 — Welle oder nicht, und wo wellenlose Arbeit geführt wird

- **Datum:** 2026-07-26
- **Aufgehoben durch [`MR-037`](#mr-037--wellenlose-arbeit-ist-jetzt-baseline-default-ihr-auslöser-test-ist-neu-gefasst).** Der Platzierungs-Teil (wellenlose Arbeit nicht in der Roadmap) ist jetzt Baseline-Default; der Auslöser-Test (Bündel · Closure-Kriterium · reaktiv/gewollt) ist durch das engere Baseline-Kriterium ersetzt. Den Rumpf trägt `git`.

### MR-017 — Default-Regel für emittierte Prüfbereiche (fail-closed)

- **Datum:** 2026-07-27
- **Geltungsbereich:** jede vom Tool **emittierte** Gate-Konfiguration, die ein Adopter
  danach selbst pflegt (`.a-check.yml`, `.d-check.yml`, `tools/harness/blocked/*`) — also
  jeder Prüfbereich, dessen Schärfe wir für **unbekannte** Nutzer festlegen.
- **Warum hier:** die Regel ist in
  [`ADR-0010`](../docs/plan/adr/0010-hexagonal-arch-realisierung.md) (Festlegung 3)
  entschieden worden, steht dort aber in einer **Layout**-ADR. Wer nach der Default-Regel
  sucht, sucht nicht nach dem hexagonalen Go-Layout — dieser Eintrag ist der Zeiger
  ([`ADR-0010`](../docs/plan/adr/0010-hexagonal-arch-realisierung.md) Folgepflicht 6). Die
  ADR bleibt die Quelle; dies ist keine zweite Fassung.
- **Setzung:** Defaults für unbekannte Adopter werden **nicht nach vermuteter Präferenz**
  gewählt, sondern nach dem **Fehlerbild**: ein zu **strenger** Default wird beim ersten
  Lauf rot und kostet eine Glob-Zeile in einer Datei, die dem Adopter gehört (die
  emittierten Configs sind *skip-if-present*, sie werden nie überschrieben). Ein zu
  **lascher** Default lässt einen Bereich ungeprüft — und meldet sich **nie**. **Laut
  falsch schlägt leise falsch.**
- **Gelebte Instanzen (Belege, nicht Beispiele):** der Command-Guard trägt seinen
  universellen Boden **gebacken** und liest die Fragmente nur additiv
  ([`MR-003`](#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)-Linie,
  nie fail-open); der Mutations-Sensor fährt bei unklarer Erwartung **beide** Stufen; die
  emittierte hexagonale Schicht-Config prüft die treibende Seite **strenger** als die
  Referenz-Repos, aus denen ihr Layout stammt.
- **Was das NICHT heißt:** strenger ist nicht automatisch besser. Die Regel greift genau
  dort, wo wir den Adopter **nicht kennen** und beide Fehlrichtungen offenstehen — nicht
  als Freibrief für Regeln ohne belegten Nutzen (die Gegenkraft bleibt
  [`LH-QA-01`](../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6): kein
  Gate über leerem Prüfbereich).
- **Auflösungs-Trigger:** permanent, solange das Tool Prüfbereiche emittiert, die der
  Adopter danach besitzt. Neu zu bewerten, sobald ein Adopter belegt, dass ein strenger
  Default ihn mehr kostet als eine Zeile — dann ist das Fehlerbild falsch modelliert.

### MR-018 — Span-Schema der Telemetrie-Erfassung

- **Datum:** 2026-07-28
- **Aufgehoben durch [`MR-021`](#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben).** Feldtabelle, Werkzeug-Liste, Positiv-Liste, Start-Konvention, die sechs erklärten Abweichungen und die Wächter-Bindungen stehen in [`spec/spezifikation.md`](../spec/spezifikation.md#5-metriken-und-tracing-felder) §5, die strukturelle Schranke um `model_version` in [§3](../spec/spezifikation.md#3-defaults-und-konstanten), die datierten Messungen in `docs/reviews/2026-08-02-span-schema-messreihen.md`; den Rumpf trägt `git`.

### MR-019 — Technik-Stratum als Rang 2 der Source Precedence

> **ÜBERHOLT: die Zahl „zwei Abweichungen von der Vorlagen-Form" → [`MR-021`](#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben).** Die übrigen Setzungen dieses Eintrags gelten fort.

- **Datum:** 2026-08-01
- **Geltungsbereich:** [`spec/spezifikation.md`](../spec/spezifikation.md),
  [`AGENTS.md`](../AGENTS.md) §2, [`harness/README.md`](README.md) §Source precedence,
  `.d-check.yml` (`matrix.classes`).
- **Adaption:** Das Repo führt das **Technik-Stratum**. `spec/spezifikation.md` steht als
  eigener **Rang 2** zwischen Vertrag (Rang 1) und Sicht (Rang 3); die nachfolgenden Ränge
  verschieben sich um eins. Damit ist das Stratum **deklariert** — der Kurs
  ([`grundlagen-referenz-richtung.md` §Spec-Straten](../.harness/baseline/v5.12.0/regelwerk/grundlagen-referenz-richtung.md#spec-straten-mehr-als-ein-spec-dokument))
  verlangt die Deklaration hier und nennt ein undeklariertes Spec-Dokument *„nicht normativ
  zitierbar“*.
- **Hebt die 2-Strata-Klausel aus [`MR-000`](#mr-000--baseline-aussage) auf** —
  *„2-Strata-Spec (Lastenheft → Architektur, keine separate Spezifikations-Datei)“*. Die
  Vorlage lässt für akzeptierte Einträge genau diesen Weg zu (*„nur neue Einträge oder
  explizite Aufhebungen via neuen MR“*); [`MR-000`](#mr-000--baseline-aussage) bleibt deshalb
  unangetastet, seine übrigen Setzungen (ID-Schema, Verzeichniskonvention) gelten fort.
- **Form des Gefäßes.** Die Abschnittsnummern sind die der vendored Vorlage
  `.harness/baseline/v3.5.2/templates/spec/spezifikation.template.md` und werden **nie neu
  vergeben**: geführt sind die Abschnitte 3 · 5 · 6 plus die Historie (7), die übrigen
  (1 · 2 · 4) lassen ihre Nummer frei. Grund ist die Anker-Stabilität — ein `Schärft:`-Zeiger
  steht in Dokumenten, die ab *Accepted* nicht mehr geändert werden dürfen
  ([`AGENTS.md`](../AGENTS.md) §3.4). Zwei Abweichungen von der Vorlagen-Form: §5 trägt die
  Drei-Spalten-Gestalt, die
  [`modul-15-observability.md`](../.harness/baseline/v5.12.0/regelwerk/modul-15-observability.md)
  vorschreibt (Feld · Pflicht/Optional · Incident-Frage) statt der Vorlagen-Spalten
  *Span · Pflicht-Attribute · Quelle* — die Vorlage verweist an dieser Stelle selbst auf das
  Modul, und der vorhandene Bestand trägt bereits diese drei Spalten; und vor §3 steht ein
  **nicht nummerierter** Abschnitt `Aufnahme-Regel`, den die Vorlage nicht kennt — er nennt die
  Bedingungen, unter denen ein Satz hierher gehört, nimmt keine Nummer und verschiebt damit
  keinen Anker.
- **Sensor, und seine Grenze (gemessen 2026-08-01).** `spec/spezifikation.md` ist in
  `.d-check.yml` der `matrix`-Klasse `spec-straten` beigetreten. Rot färbt `make docs-check`
  damit jeden Link im bindenden Text (außerhalb der Historie-Tabelle), dessen **Ziel** in der
  `matrix`-Klasse `adr` oder `slice` liegt, als `matrix-forbidden` — entschieden wird über die
  Klasse des Ziels, nicht über den Text der Kennung —, und eine **nackte** `ADR-`-Kennung als
  `id-unlinked`. **Nicht** rot färbt eine **nackte** `slice-`-Kennung (`ids.patterns` führt kein
  Muster für sie), und ebensowenig eine `ADR-`- oder `slice-`-Kennung, deren Link an einem Ziel
  außerhalb beider Klassen endet — beides lässt den Gate bei Exit 0. Diesen Rest der Regel trägt
  der Mensch.
- **Begründung (gemessen 2026-08-01 am Stand `5200da6`, jede Zahl über die Blockgrenzen
  `grep -nE '^### MR-[0-9]{3}|^## Modus-Deklaration'`).** Der Adaptions-Block hat technische
  Festlegungen aufgenommen, für die er nicht das Gefäß ist:
  [`MR-018`](#mr-018--span-schema-der-telemetrie-erfassung) trug dort **824 Zeilen** und damit
  mehr als die übrigen achtzehn Einträge **zusammen** (801). Am 2026-07-28 waren es noch **47**;
  von den 803 Zeilen, um die die Datei seither gewachsen war, entfielen **777 auf diesen einen
  Eintrag**. Der Eintrag nennt den Grund selbst — die Tabelle *„wächst mit jedem Feld“* und
  gehört nicht in eine ab *Accepted* immutable Entscheidung. Das ist die Definition des
  Technik-Stratums; das Gefäß fehlte, also wuchs der Inhalt in das nächstbeste. Dazu ein
  Rang-Befund: der Adaptions-Block steht in **keiner** der beiden Precedence-Listen des Repos —
  eine fortschreibbare technische Festlegung lag damit in einem ungerangten Dokument.
- **Was hier NICHT entschieden ist:** dass Bestand aus dem Adaptions-Block umzieht. Diese
  Adaption legt das Gefäß an und rangt es; welcher Satz wohin wandert, ist eine eigene Arbeit
  — und der Umzug einer Festlegung, deren Zielort eine akzeptierte ADR vorschreibt, braucht
  zuerst deren Teil-Revision
  ([`ADR-0013`](../docs/plan/adr/0013-technik-stratum-als-zielort.md)).
- **Auflösungs-Trigger:** permanent. Fällt der letzte Abschnitt mit Bestand weg, ist das
  Stratum neu zu begründen — ein Spec-Dokument ohne Inhalt ist ein Rang ohne Gegenstand.

### MR-020 — Aufgehobener Eintrag behält Kopf und Zeiger statt Rumpf

> **ÜBERHOLT: die Aufgehoben-durch-Form für baseline-getriebene Rückbauten → [`MR-038`](#mr-038--ein-retirierender-eintrag-nennt-den-baseline-stand-der-seinen-trigger-feuerte).** Festlegung 1–3 (Kopf bleibt, Rumpf geht bei vollständiger Aufhebung) gelten fort — geprüft und bestätigt gegen `v5.12.0`, nicht widerlegt.

- **Datum:** 2026-08-01
- **Geltungsbereich:** dieser Adaptions-Block. **Nicht** `docs/plan/adr/` — dort gilt
  [`AGENTS.md`](../AGENTS.md) §3.4 unverändert.
- **Adaption:** Die Disziplin-Regel der vendored Vorlage
  (`.harness/baseline/v3.5.2/templates/harness/conventions.template.md`, Kommentar über dem
  Adaptions-Block) verlangt *„keine nachträglichen inhaltlichen Änderungen an akzeptierten
  Einträgen — nur neue Einträge oder explizite Aufhebungen via neuen MR"*. Davon weicht dieses
  Repo in **einem** Punkt ab: **der Rumpf eines vollständig aufgehobenen Eintrags wird
  entfernt.** Es bleiben stehen die Nummer, die Überschrift **wörtlich** (sie ist der Anker),
  das `Datum` und **eine** Zeile mit dem aufhebenden Eintrag und den Zielorten je Posten-Art;
  die Historie trägt `git`. Bedingungen, Abwägung und Reichweite:
  [`ADR-0014`](../docs/plan/adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md).
- **„Akzeptiert" heißt committet.** Ein Eintrag hier führt kein Status-Feld (Pflichtfelder: ID ·
  Datum · Geltungsbereich · Adaption · Begründung · Auflösungs-Trigger); ohne diese Festlegung
  hätte die Regel keinen bestimmbaren Auslöser.
- **Hebt die Blankett-Klausel aus [`MR-000`](#mr-000--baseline-aussage) für diesen Punkt auf** —
  *„keine inhaltlichen Adaptionen ggü. Baseline-Default"*.
  [`MR-000`](#mr-000--baseline-aussage) bleibt unangetastet, seine übrigen Setzungen gelten
  fort.
- **Nur die Dogfood-Ebene.** Das emittierte `harness/conventions.md` ist dieselbe vendored
  Vorlage mit zwei Transformationen (Hinweis-Blockquote entfernt, `<Projektname>` gestempelt);
  ihre neun HTML-Kommentare und mit ihnen die Disziplin-Regel wandern unverändert ins Zielrepo,
  wo die Baseline-Regel gilt.
- **Begründung (gemessen 2026-08-01 am Stand `c145f2b`).** Die drei sitzungsfesten Posten der
  Einstiegs-Leseliste messen zusammen 165.197 Bytes; der größte Eintrag dieses Blocks misst 824
  Zeilen / 70.727 Bytes und damit 42,8 % davon. Ein stehengelassener aufgehobener Rumpf dieser
  Größe macht diesen Anteil des Pflicht-Lesepfads zu Text ohne Bindung und führt seine
  Festlegung an zwei Orten, von denen nur einer bindet. Was die append-only-Führung dagegen
  leisten soll — Nachvollziehbarkeit — leistet `git` vollständig und besser: jede Fassung, ihr
  Autor und der aufhebende Commit. Nicht in `git` steht, was der Kopf hält: Nummer, Anker und
  die Reichweite am Ort des Lesens.
- **Auflösungs-Trigger:** an [`ADR-0014`](../docs/plan/adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md)
  gebunden — fällt ihre Annahme (die Historie ist da, wo der Rumpf gebraucht wird), fällt diese
  Adaption mit ihr.

### MR-021 — Das Span-Schema zieht ins Technik-Stratum, sein Eintrag wird aufgehoben

> **ÜBERHOLT: Punkt 2 der Liste „Was als Delta bleibt" → [`MR-030`](#mr-030--der-rollen-name-der-baseline-und-der-bezeichner-fallen-zusammen).** Die übrigen Setzungen dieses Eintrags gelten fort.

- **Datum:** 2026-08-02
- **Geltungsbereich:** [`MR-018`](#mr-018--span-schema-der-telemetrie-erfassung) sowie die
  Abschnitte [3](../spec/spezifikation.md#3-defaults-und-konstanten) und
  [5](../spec/spezifikation.md#5-metriken-und-tracing-felder) von
  [`spec/spezifikation.md`](../spec/spezifikation.md).
- **Adaption:** [`MR-018`](#mr-018--span-schema-der-telemetrie-erfassung) wird **vollständig
  aufgehoben.** Kein Satz seines Rumpfs bindet noch von dort. Er behält Nummer, Überschrift
  **wörtlich** (sie ist der Anker), das `Datum` und eine Zeiger-Zeile; den Rumpf trägt `git`
  ([`MR-020`](#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf), Bedingungen und
  Abwägung in [`ADR-0014`](../docs/plan/adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md)).
  Zielort je Posten-Art — der Zielort des ersten und zweiten ist die Setzung aus
  [`ADR-0013`](../docs/plan/adr/0013-technik-stratum-als-zielort.md) Festlegung 1:
  - **technische Festlegung, die mit ihrem Gegenstand wächst** (Feldtabelle, Werkzeug-Liste,
    Positiv-Liste, Start-Konvention, erfasste Menge, Strom-Identität, die sechs erklärten
    Abweichungen, die Wächter-Bindungen) → [`spec/spezifikation.md`](../spec/spezifikation.md#5-metriken-und-tracing-felder) §5;
  - **Wert, der als Schranke fest ist** (Länge und Zeichensatz von `model_version`) →
    [§3](../spec/spezifikation.md#3-defaults-und-konstanten);
  - **Inhalt des Regelwerks, nacherzählt** → ein auflösender Link ins Modul, im umgezogenen Text
    durchgehend gesetzt;
  - **datierte Messung** (Messreihen, Gegenproben, rot-gesehen-Nachweise) →
    `docs/reviews/2026-08-02-span-schema-messreihen.md`, der etablierte Ort für Zeitdokumente;
  - **Prozess-Zustand** (wer trägt was, was ist offen) → der Plan, der ihn führt — nicht dieser
    Block;
  - **Abweichung von der adoptierten Baseline** → dieser Eintrag, nächster Punkt.
- **Was als Delta bleibt, und damit den Gegenstand dieses Blocks trifft — zwei Posten:**
  1. **Die Sensor-Spalte ist eine dritte Abweichung von der Vorlagen-Form.** §5 trägt jetzt vier
     Spalten (Feld · Pflicht · Incident-Frage · **Sensor**) statt der drei, die
     [`modul-15-observability.md`](../.harness/baseline/v5.12.0/regelwerk/modul-15-observability.md#span-audit-attribut-regeln)
     vorschreibt. Grund: eine Zusicherung ohne benannten Wächter ist nach
     [`AGENTS.md`](../AGENTS.md) §3.6 unbelegt, und die Bindung wächst mit ihrem Gegenstand wie
     die Zeile selbst. [`MR-019`](#mr-019--technik-stratum-als-rang-2-der-source-precedence) zählt
     für das Stratum *„zwei Abweichungen von der Vorlagen-Form"*; jener Eintrag wird dafür nicht
     angefasst, seine Zahl ist überholt.
  2. **`implementer` statt *Implementation*.**
     [`modul-08-agentenrollen.md`](../.harness/baseline/v3.5.2/regelwerk/modul-08-agentenrollen.md#rollen-sequenz-für-einen-slice)
     nennt die dritte Rolle *Implementation*; als **Bezeichner** der Agenten-Typen gilt hier
     `implementer` — kurz und gleichförmig mit den übrigen fünf. Die Abweichung ist eine
     Schreibweise, keine Rollen-Änderung. Der **Wert** steht im Stratum, weil er eine technische
     Festlegung ist; dass er von der Modul-Schreibweise abweicht, steht hier.
- **Sensor, und seine Grenze (gemessen 2026-08-02).** Die Sensor-Spalte hat **einen Namen und
  keinen Sensor.** `codepaths.roots` in `.d-check.yml` sind `[spec, docs, harness]`; `test/` steht
  dort nicht. Fünf Sonden in **einer** Datei einer isolierten Kopie, je ein `make docs-check`
  (gepinntes Image, `--network none`, ohne Sonden 281 Datei(en) / 0 Befund(e)): ein nicht
  existierender Pfad unter `test/` bleibt **still**, derselbe Fehler unter `harness/` meldet
  `codepath-missing`; eine Zeilen-Referenz `…:9000-9001` unter `test/` bleibt **still**, dieselbe
  Form auf `harness/tools/mutate.sh` meldet `citation-out-of-range`. Kein Gate prüft also, ob ein
  in der Spalte genannter Fall noch existiert oder noch so heißt — `make mutate` fährt nur die
  Dateien, die es findet, und `make comment-claims` lässt jede Markdown-Datei außen vor. Die
  Spalte ist Feedforward; ihre Alterung fängt niemand mechanisch. Diesen Rest trägt der Mensch.
- **Was ersatzlos entfällt, je mit Grund.** Vier bindende Posten und zwei Klassen:
  1. Die **Zielort-Setzung** *„die Feldtabelle gehört hierher"* — genau sie ist teil-revidiert;
     ihre Begründung (*„sie wächst mit jedem Feld"*) ist die Aufnahme-Regel des Zielorts und steht
     dort.
  2. Das **Verdikt *permanent*** zur Abweichung *Haupt-Kontext ohne Zahl* samt seinem Trichter:
     der Posten ist in [`ADR-0012`](../docs/plan/adr/0012-haupt-kontext-ohne-token-bilanz.md)
     übergeführt, und die trägt Verdikt, Begründung und Re-Evaluierung. Ein zweiter Ort driftet.
  3. Die **Tooling-Klarstellung** *„drei Zeilen der Fitness Function nennen `bats`, umgesetzt sind
     sie als Go-Tests"*: beide Hälften stehen andernorts bindend — dass `make test` `test-bats`
     **und** `test-go` fährt, sagt die Gate-Tabelle in [`AGENTS.md`](../AGENTS.md) §4; **wo** die
     Wächter liegen, sagt die Sensor-Spalte namentlich.
  4. Die **zugesagte Sonde auf die Schlüsselnamen von `tool_input`**: sie trennt die zwei offenen
     Lesarten in keinem Zweig, und ihren Gegenstand trägt ein Plan. Sie wird deshalb nicht
     richtiggestellt, sondern entfällt.
  5. **Entstehungs-Erzählung** — Befund-Herkunft, *„bis <Datum> stand hier …"*, *„frühere
     Fassung"*, *„Vorgänger"*: das Artefakt beschreibt seinen Gegenstand, nicht seine eigene
     Entstehung; die Fassungen trägt `git`.
  6. **Prozess-Zustand** — welcher Slice was trägt, welcher Trigger auf welchen Slice wartet: er
     gehört in den Plan, der ihn führt, und ein Eintrag dieses Blocks ist kein Entscheidungs-Ort
     für offene Arbeit.
- **Begründung.** Der Adaptions-Block registriert Abweichungen von der adoptierten Baseline. Die
  Feldtabelle weicht von nichts ab; sie *ist* die Festlegung — und sie lag damit in einem
  Dokument, das in keiner der beiden Precedence-Listen des Repos steht. Das Gefäß dafür existiert
  seit [`MR-019`](#mr-019--technik-stratum-als-rang-2-der-source-precedence). Mit diesem Eintrag
  hat der Block seinen Gegenstand zurück: was hier bleibt, sind zwei Deltas gegenüber Regelwerk
  und Vorlage, und die passen in zwei Absätze.
- **Auflösungs-Trigger:** permanent. Fiele die Setzung, dass das Technik-Stratum der Zielort ist,
  wäre nicht dieser Eintrag nachzubessern, sondern jene Entscheidung abzulösen.

### MR-022 — Kommentar-Regel als Vorgriff auf eine neuere Baseline

- **Datum:** 2026-08-08
- **Aufgehoben durch [`MR-031`](#mr-031--die-kommentar-regel-steht-in-der-adoptierten-baseline).** Der Vorgriff ist eingeholt: die adoptierte Baseline `v5.12.0` führt die Regel. Die Regel selbst steht in [`AGENTS.md`](../AGENTS.md) §3.7, ihre Deckung gegen die Upstream-Fassung samt der offenen Textprüfung in [`MR-031`](#mr-031--die-kommentar-regel-steht-in-der-adoptierten-baseline); den Rumpf trägt `git`.

### MR-023 — Die Platzierung der Kommentar-Regel ist keine Abweichung

- **Datum:** 2026-08-09
- **Aufgehoben durch [`MR-031`](#mr-031--die-kommentar-regel-steht-in-der-adoptierten-baseline).** Sein Gegenstand war die Teil-Aufhebung von [`MR-022`](#mr-022--kommentar-regel-als-vorgriff-auf-eine-neuere-baseline); mit dessen vollständiger Aufhebung hat er keinen. Die Textprüfung, die er ausdrücklich offenließ, und der Mess-Stand gegen `v5.12.0` stehen in [`MR-031`](#mr-031--die-kommentar-regel-steht-in-der-adoptierten-baseline); den Rumpf trägt `git`.

### MR-024 — d-check-Pin v0.62.0 (structure verfügbar)

- **Datum:** 2026-08-22
- **Geltungsbereich:** `d-check.mk` (`DCHECK_IMAGE`/`DCHECK_DIGEST`, Kopfkommentar),
  `internal/emit/emit.go` (emittierter Default-Pin), `Makefile` (das Tag-Beispiel im Kommentar
  über `DCHECK_TAG`), §Baseline-Version; setzt [`MR-012`](#mr-012--d-check-pin-v0511-sources-verfügbar) fort.
- **Adaption:** Das gepinnte d-check-Image springt **v0.51.1 → v0.62.0** — **elf** Minor-Releases
  (v0.52.0 vom 2026-08-09 bis v0.62.0 vom 2026-08-21, die bislang größte Spanne dieser Linie).
  Digest `sha256:3996a593b9cb71aa3bcb4f3ddf8f637e7409db31b3a2dac7eedc28d65814cacf`, **dreifach
  belegt**: lokaler RepoDigest (`docker inspect`) · `docker buildx imagetools inspect` ·
  Release-Body v0.62.0 ([`LH-QA-02`](../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)). Der **lebende** Pin steht in `d-check.mk`
  und, daran gekoppelt, in `internal/emit/emit.go`; hier steht, wogegen er belegt ist.
- **Zweck: `structure` wird verfügbar, nicht aktiviert.** Das opt-in-Modul `structure` — das 20.,
  Struktur-Invarianten **innerhalb** eines Dokuments, mit dem advisory-Target `doc-structure` —
  liegt mit diesem Pin im Repo, wie `sources` es mit
  [`MR-012`](#mr-012--d-check-pin-v0511-sources-verfügbar) wurde. **Aktiviert ist es nicht**
  (`grep -c structure .d-check.yml` → **0**); leer aktiviert wäre es ein Phantom-Gate
  ([`LH-QA-01`](../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)), und ob dieses Repo eine Struktur-Prüfung will, ist eine Frage an
  Prüfbereich und Strenge — ein eigener Schnitt mit eigenem False-Positive-Risiko. Ausgeliefert
  ist das Modul samt Target seit **v0.57.0** (2026-08-15), gemessen am lokalen d-check-Klon
  (`git ls-tree v0.57.0` führt die Regel-Datei des Moduls, `v0.56.0` nicht; der CHANGELOG-Eintrag
  „das 20. Regelmodul" steht unter `[0.57.0]`); v0.62.0 ist der Stand, mit dem es **hier** ankommt.
- **Trockenlauf vor dem Pin (Pflicht, belegt — [`MR-009`](#mr-009--d-check-pin-sprung-und-codepath-ventile)-Muster).** v0.62.0 per Digest gegen den
  unveränderten Baum mit unveränderter `.d-check.yml`, netzlos (`--network none`):
  `d-check: 333 Datei(en) geprüft, 0 Befund(e)`, Exit 0 — **byte-gleich** mit dem v0.51.1-Lauf über
  denselben Baum (333/0, Exit 0; der `diff` beider Ausgaben ist leer): **0-Befund-Differenz über
  elf Minors**. Einzige inhaltliche `--print-mk`-Fragment-Differenz zu v0.51.1: das neue Target
  `doc-structure` (elf → zwölf Targets, [`MR-010`](#mr-010--d-check-gate-fragment-tool-generiert)
  §Setzung 2) und je ein zusätzliches `--disable structure` in den bestehenden fokussierten
  advisory-Recipes — verbatim vom Tool, wie damals `--disable sources`; die vier Handgriffe der
  Re-Adaption stehen in [`MR-010`](#mr-010--d-check-gate-fragment-tool-generiert).
- **Was dieser Lauf trägt — und was nicht.** Er trägt **eine** Richtung: über diesem Korpus
  entsteht kein neuer Befund. In der **Gegenrichtung** ist er über einer 0-Befund-Basis
  informationsleer — eine weggefallene Befundklasse erzeugt dieselbe Ausgabe wie eine unveränderte,
  `333/0` bleibt `333/0`. „Der Sprung senkt keine Strenge" folgt also **nicht** aus dem
  Trockenlauf; das ist eine Aussage über die Regelmodule und wird an ihnen belegt.
- **Strenge-Bilanz der elf Minors, an den aktiven Modulen gemessen.** Aktiv sind sechs
  (`.d-check.yml`: `modules: [links, anchors, ids, matrix, codepaths, spans]`); `sources` läuft
  daneben allein im Maintenance-Target `regelwerk-check`, ausdrücklich **nicht** in `gates`. Gegen
  den lokalen d-check-Klon über `v0.51.1..v0.62.0` gemessen berühren **zwei** der elf Minors ein
  aktives Modul, **beide in Richtung mehr Strenge**: (a) **v0.53.0** gibt `spans` die dritte
  Befundklasse `fence-unclosed` (Fence-Öffnung ohne Schluss bis zum Dateiende) — der Diff der
  Regeldatei dieses Moduls ist rein additiv, `git diff v0.51.1..v0.62.0` zählt dort **null**
  entfernte Zeilen; Anlass war ein ausgelieferter stiller Grün-Pfad, hinter dem Gates grün
  meldeten, ohne geprüft zu haben, und dieses Repo stand auf v0.51.1. Dass die Klasse über diesem
  Baum nicht feuert, sagt der Trockenlauf, nicht die `modules:`-Liste — genau die Grenze, die
  [`MR-009`](#mr-009--d-check-pin-sprung-und-codepath-ventile) zieht. (b) **v0.60.0** gibt `links`
  den opt-in-Schlüssel `resolve-from` für wandernde Quellorte; hier **nicht** gesetzt, und ohne ihn
  prüft er über einer leeren Gruppenliste — seine Adoption ist eine eigene Entscheidung. Die
  Regeldateien von `ids`, `codepaths` und `matrix` sind über die Spanne **unverändert**
  (`git diff --numstat v0.51.1..v0.62.0` → keine Zeile je Datei); `anchors` ist umgebaut, aber
  nicht in seiner Antwort: Slug- und Anker-Erkennung sind in geteilte Funktionen gezogen, damit
  `versions`, `pins` und `citations` **ihr** folgen (CHANGELOG `[0.58.0]`).
- **Die ausgewiesenen Lockerungen liegen sämtlich in Modulen, die dieses Repo nicht fährt.** Der
  d-check-CHANGELOG benennt Lockerungen wörtlich; über `[0.52.0]`…`[0.62.0]` sind es zweimal
  `closure-note-boilerplate` („findet weniger", „es ist eine **Lockerung**", `[0.56.0]`) und zwei
  weggefallene Falsch-Rot in `planning` (`[0.58.0]`) — beides `planning`/`planning.closure`, hier
  nicht aktiviert — sowie in `[0.58.0]` je ein „findet weniger" bei `citations`, `pins` und
  `versions`, ebenfalls nicht aktiviert. Der einzige Fall an einer **geteilten** Lexik („die
  Fence-Lexik trimmt an allen fünf Konsumenten identisch … Wer hier Befunde verliert, verliert
  Fehlmessungen", `[0.53.0]`) ist am Klon nachgezählt: bewegt hat sich der Trimmer allein im Modul
  `planning` (unicode-weites `TrimSpace` → Space und Tab); die übrigen vier Konsumenten — darunter
  die Vorverarbeitung, aus der **alle** hier aktiven Module lesen — trimmten schon vor v0.53.0
  Space und Tab. `sources` bekam in `[0.52.0]` eine Herkunfts-Korrektur an seiner Befund-Meldung;
  sie greift nur unter `--config`, und `--config` fährt dieses Repo nicht.
- **Welches der zwei Beine die Bilanz trägt.** Die CHANGELOG-Aufzählung ist **bestätigend, nicht
  tragend**: upstream weist sie selbst als unvollständig aus — *„**Diese Aufzählung ist offen** —
  sie nennt die gemessenen Fälle, nicht alle möglichen; in drei Review-Runden ist sie dreimal
  unvollständig gewesen."* (`[0.58.0]`, am lokalen d-check-Klon:
  `awk '/^## \[0\.58\.0\]/,/^## \[0\.57\.0\]/' CHANGELOG.md`). Eine Liste, die ihre eigene
  Vollständigkeit bestreitet, kann die §3.5-Frage nicht beantworten. **Tragend ist das andere
  Bein:** die Quell-Differenz über die Regeldateien der aktiven Module
  (`git diff --numstat v0.51.1..v0.62.0 -- <Regeldatei>`, Bullet oben) — sie ist geschlossen, weil
  sie den Bestand misst statt eine Aufzählung zu lesen. Wer die Bilanz auf die schnellere Hälfte
  verkürzt — CHANGELOG nach „findet weniger" durchsuchen, Modul zuordnen, fertig —, bekommt über
  einer Spanne mit **nicht ausgewiesener** Lockerung an einem aktiven Modul ein grünes Ergebnis
  ohne Deckung.
- **Kein ADR nötig ([`AGENTS.md`](../AGENTS.md) §3.5).** §3.5 verlangt einen ADR für **Senkungen**.
  Gemessen senkt der Sprung an keinem aktiven Modul und hebt an einem (`spans`) — „Anheben →
  Steering-Loop, kein ADR nötig" hält
  [`MR-001`](#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids) fest. Diese Bilanz hängt
  an der **Versions-Differenz der Regelmodule**, nicht am Trockenlauf; sie ist gegen einen lokalen
  d-check-Klon aus CHANGELOG und `git diff` reproduzierbar, nicht gegen ein Gate — kein Modul
  dieses Repos vergleicht Befund**klassen** zweier d-check-Versionen.
- **Emitter-Pin gekoppelt (Tier-1-Drift).** `internal/emit`s `DefaultImage`/`DefaultDigest` zieht
  per go-test mit (`TestDefaultImage_MatchesCanonical`/`TestDefaultDigest_MatchesCanonical` lesen
  `d-check.mk`); die emittierte Starter-Config bleibt `modules: [links, anchors]`
  ([`MR-017`](#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)) — dort ist `structure` so wenig aktiviert wie `sources` oder `citations`.
  Das Gate-Fragment des Ziels entsteht zur Bootstrap-Zeit live per `--print-mk` aus dem gepinnten
  Image; `make full-smoke` ist der Lauf, der das emittierte Gate mit ihm fährt.
- **Auflösungs-Trigger:** permanent; bei d-check-Release `d-check --print-mk` neu erzeugen + Digest
  neu pinnen ([`MR-010`](#mr-010--d-check-gate-fragment-tool-generiert) §Auflösungs-Trigger) und
  die Strenge-Bilanz über die neue Spanne neu ziehen — **an der Quell-Differenz der Regeldateien**,
  nicht an der CHANGELOG-Aufzählung; der Trockenlauf allein beantwortet die §3.5-Frage nicht.

### MR-025 — Eine Zahl im Text steht neben dem Kommando, das sie liefert

- **Datum:** 2026-08-22
- **Geltungsbereich:** die **lebenden**, repo-eigenen Markdown-Artefakte — gemessen
  `git ls-files '*.md' ':!docs/reviews/**' ':!docs/plan/planning/done/**' ':!.harness/baseline/**' | wc -l`
  → **108** von **476** Markdown-Dateien im Index (`git ls-files '*.md' | wc -l`). Draußen liegen,
  jeweils mit Grund: `docs/reviews/**` und `docs/plan/planning/done/**` — **328** Dateien
  (`git ls-files 'docs/reviews/*.md' 'docs/plan/planning/done/*.md' | wc -l`), **Zeitdokumente**,
  die eine Messung zu ihrem Datum festhalten und darum nicht nachgezogen werden;
  `.harness/baseline/**` — **40** Dateien (`git ls-files '.harness/baseline/**/*.md' | wc -l`),
  committet vendored Fremd-Bestand, den dieses Repo spiegelt statt schreibt
  ([`MR-007`](#mr-007--baseline-committet-vendored-statt-gefetchter-cache)); und
  `**/*.template.md`, Ziel-Form-Vorlagen mit Platzhaltern statt Aussagen
  ([`MR-001`](#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids) §`scan.ignore`). **Alle
  vier Zahlen sind keine Erwartungswerte** — sie wandern mit dem Bestand und messen ihn, nicht den
  Geltungsbereich (Setzung 2 an sich selbst angelegt); der Geltungsbereich sind die vier Kommandos.
  **Dieses Repo, nicht das emittierte:** was ein emittiertes Repo an Beleg-Regeln bekommt,
  entscheidet der Slice, der die Tool-Ebene entscheidet.
- **Setzung 1 — die Zahl und ihr Kommando stehen beieinander, und das Kommando ist gefahren.**
  Eine Zahl, die als **Messwert** auftritt — Erwartungswert, Bruch-Kriterium, Beleg —, trägt im
  selben Absatz das Kommando, das **genau sie** ausgibt, und wer sie schreibt, hat es über dem
  Baum gefahren, von dem sie spricht. Liefert kein Kommando sie — Fremdquelle, Zählung von Hand,
  Beobachtung an einer Oberfläche —, steht **das** dabei; ein ungefähr passendes Kommando
  danebenzustellen ist der Fehler, nicht die Lücke. Zahlen ohne Messwert-Rolle (Versionen, Daten,
  Aufzählungen im Fließtext) bindet die Setzung nicht.
- **Setzung 2 — ein Erwartungswert misst seinen Gegenstand, nicht sein Umfeld.** Eine Zahl, die
  mit dem Artefakt mitwandert — die Dateizahl eines Gate-Laufs, die Trefferzahl über einen
  wachsenden Baum, die Vorkommen-Zahl in einer Datei, deren Kopf noch bearbeitet wird —, taugt
  nicht als Erwartungswert: sie bricht, ohne dass am Gegenstand etwas bricht. Sie wird entweder
  ausdrücklich als **kein** Erwartungswert gekennzeichnet oder durch ein Kriterium ersetzt, das
  den Gegenstand selbst misst (`grep -c '^docs-check:' d-check.mk` statt der Zahl aller
  `docs-check`-Vorkommen derselben Datei). Musterfall ist die Dateizahl des Doku-Gates: am
  2026-08-22 meldet `make docs-check` → `336 Datei(en) geprüft, 0 Befund(e)`, Exit 0, und jedes
  neu angelegte Dokument erhöht sie.
- **Begründung (gemessen, nicht postuliert):** Die Klasse — *eine Zahl im Fließtext, die ihr
  danebenstehendes Kommando nicht liefert* — ist über **zwei** Slices und **sechs** Review-Runden
  wiederholt gemeldet worden. Der Nenner ist mechanisch:
  `grep -h '^### \(HIGH\|MEDIUM\|LOW\|INFO\)-' docs/reviews/2026-08-22-slice-08*.md | wc -l` →
  **29** Findings über sieben Dateien. **Zehn** davon tragen diese Klasse — **Untergrenze, mit
  Absicht:** die Zugehörigkeit ist ein Urteil, kein Muster, und sie mechanisch zu beziffern hieße,
  ein Muster als Kriterium auszugeben, das keines ist ([`AGENTS.md`](../AGENTS.md) §3.6). Die
  Fundorte liegen in Planungs-Text, in einer Commit-Message und in einem Mess-Zeitdokument — drei
  Artefakt-Arten und mehr als eine schreibende Rolle. **Zwei** der zehn entstehen in demselben
  Commit, der die Klasse an anderer Stelle behebt: `git show abe01f4` (**eine** Datei, ein
  Slice-Plan) streicht in einem DoD-Punkt eine mitwandernde Dateizahl als Erwartungswert und setzt
  in einem anderen zwei Zahlen, die ihre danebenstehenden Kommandos nicht liefern. Der Befund ist damit
  nicht die Wiederholung, sondern die fehlende **Trägerschaft**: was allein in Zeitdokumenten
  steht, schlägt kein Lauf wieder auf.
- **Was der Schaden ist.** Nicht die falsche Ziffer, sondern was ein Lauf aus ihr macht, der sie
  nachzählt: entweder ein falsches Rot an einem korrekten Gegenstand oder die Gewohnheit,
  ausgewiesene Messungen gar nicht erst nachzuzählen. Die zweite Wirkung ist die teurere — sie
  entwertet jede Zahl im Repo, auch die richtigen.
- **Kein Wächter, und das gehört dazu — die Setzung liegt im Feedforward-Quadranten.** Der
  nächstliegende Kandidat deckt sie in **zwei** Achsen nicht: `make comment-claims` bildet seinen
  Prüfbereich im Rezept aus vier `git ls-files`-Mustern, und keines trifft eine Markdown-Datei
  (`git ls-files 'internal/*.go' 'internal/**/*.go' 'cmd/**/*.go' 'harness/tools/*.sh' '.claude/hooks/*.sh' | grep -c '\.md$'`
  → **0**, Exit 1); dieser Ausschluss ist **dauerhaft** ([`AGENTS.md`](../AGENTS.md) §4
  Ausschluss 2, [`harness/README.md`](README.md) §*Was `comment-claims` nicht deckt* Punkt 2 —
  „(2) und (3) sind permanent"). Und er prüft die **Existenz** eines genannten Sensors, nicht
  seinen Wert.
- **Drei Kandidaten liegen im Bestand; ihre Eignung ist ungeprüft.** `citations` und
  `codepaths.check-lines`
  ([`MR-011`](#mr-011--zitat-verifikation-via-d-check-adoptiert-check-lines)) binden Text an eine
  **Datei-Spanne**; `structure` — mit dem Pin aus
  [`MR-024`](#mr-024--d-check-pin-v0620-structure-verfügbar) verfügbar, nicht aktiviert
  (`grep -c 'structure' .d-check.yml` → **0**) — bindet Abschnitte an **Struktur-Invarianten**.
  Das ist aus ihren Modul-Verträgen gelesen und an diesem Repo **nicht** erprobt; daraus folgt
  bestenfalls, dass eines von ihnen die **Form** fordern könnte (Zahl und Kommando im selben
  Abschnitt). Den **Wert** gegen einen Lauf zu halten kann keines, denn keines fährt einen Lauf:
  `git grep -ln 'os/exec' v0.65.0 -- 'internal/*.go' 'internal/**/*.go' 'cmd/**/*.go' ':!*_test.go'`
  am lokalen d-check-Klon ist **leer** (Exit 1) — ohne die Test-Ausnahme bleibt genau ein
  Akzeptanztest übrig, kein Produktionspfad.
- **Cutoff — ab diesem Eintrag, kein Nachrüsten.** Gebunden ist die Zahl, die geschrieben oder
  geändert wird; der **Bestand ist kein Arbeitsauftrag**. Seine Fläche ist gemessen: **95** der
  **108** lebenden Markdown-Dateien nennen mindestens ein Kommando
  (`git grep -lE '(make [a-z-]+|grep -|docker run|git (grep|ls-files|show|log|diff))' -- '*.md' ':!docs/reviews/**' ':!docs/plan/planning/done/**' ':!.harness/baseline/**' | wc -l`).
  Das ist die **Obergrenze der Fläche** und **kein Erwartungswert** — keine Zahl von Verstößen,
  und mit dem Bestand wandernd: wie viele Zahlen dort ihr Kommando nicht liefern, sagt kein
  Kommando, weil die Zugehörigkeit ein Urteil ist. Ein Maßstab
  über diesen Bestand wäre dauerhaft rot und entwertete die Setzung, statt sie zu tragen —
  dieselbe Begründung trägt den Cutoff in
  [`MR-015`](#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) und in
  [`AGENTS.md`](../AGENTS.md) §3.7. Wer eine solche Zeile ohnehin anfasst, zieht sie nach; wer sie
  stehen lässt, bricht nichts.
- **Kein ADR nötig ([`AGENTS.md`](../AGENTS.md) §3.5).** §3.5 verlangt einen ADR für **Senkungen**.
  Beide Setzungen sind eine **Verschärfung** — eine zusätzliche Beleg-Pflicht, eine engere Form
  des Erwartungswerts —, und „Anheben → Steering-Loop, kein ADR nötig" hält
  [`MR-001`](#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids) fest.
- **Der Ort ist offen, die Verbindlichkeit nicht.** Hierher gestellt hat die Setzung ihre
  Befristung: eine Hard Rule ist permanent, ein Eintrag mit fälligem Trigger nicht. Diese Hälfte
  des Grundes ist mit dem Auflösungs-Trigger unten entfallen, und die andere Hälfte — der
  Sensor-Vorbehalt — trennt nicht, denn [`AGENTS.md`](../AGENTS.md) §3.7 und §3.8 tragen denselben
  Vorbehalt im Katalog. Nach [`AGENTS.md`](../AGENTS.md) §3.8 gehört eine Regel, die eine **Lücke
  füllt** statt von der Baseline abzuweichen, ohnehin nicht in den Adaptions-Block, und diese
  Setzung füllt eine: die Baseline `v3.5.2` kennt die Klasse als **Harness-Lüge** dem Begriff nach
  (`.harness/baseline/v3.5.2/regelwerk/grundlagen-konventionen.md` §Kernbegriffe: *„Der Harness
  behauptet eine Kontrolle, die real nicht (mehr) greift"*), führt aber keine Regel über den Beleg
  einer Zahl in Prosa. Die Verlegung nach [`AGENTS.md`](../AGENTS.md) §3 hat einen eigenen Preis —
  hier bleiben nach [`MR-020`](#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf)
  Kopf und Zeiger, der Rumpf wird dort **angehängt**, nicht eingeschoben
  ([`MR-026`](#mr-026--die-hard-rule-nummer-ist-eine-adresse-keine-baseline-entsprechung)
  Setzung 2) — und wird deshalb nicht beiläufig mitgenommen. Bis sie fällt, gilt die Setzung von
  hier: der Adaptions-Block ist normativ wie eine ADR, nur ohne deren Immutabilität
  ([`AGENTS.md`](../AGENTS.md) §3.8). Dieselbe Grenzziehung trifft
  [`MR-015`](#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) für seine
  eigene Setzung.
- **Auflösungs-Trigger: keiner — die Setzung ist permanent und liegt bewusst im
  Feedforward-Quadranten.** Von den drei Wegen, die beim d-check-Pin-Sprung zur Wahl standen, ist
  keiner gangbar, und beide Absagen sind gemessen. **(a) Ein eigener hermetischer Prüfer** müsste
  entscheiden, ob eine Zahl in einer **Messwert-Rolle** steht, und das ist ein Urteil, kein Muster
  (Begründung oben, zweimal). Das nächstliegende mechanisierbare Surrogat — eine fett gesetzte
  Zahl, in deren Absatz kein Kommando steht — trifft über den lebenden Markdown-Bestand **228**
  Absätze mit fetter Zahl, davon **30** ohne Kommando im selben Absatz (ein `awk` mit `RS=""` über
  die Dateiliste des §Geltungsbereichs, Zahl-Muster `\*\*[0-9][0-9.]*\*\*`, Kommando-Muster wie im
  Cutoff-Bullet; **keine Erwartungswerte**, beide wandern mit dem Bestand). Die **30** sind
  gelesen: sie führen ADR-Nummern, das Wort **Accepted** aus einer Historie-Tabelle,
  Zeilenspannen und Zahlen, deren Kommando einen Absatz weiter steht. **10** von ihnen liegen in
  `docs/plan/adr/` (dieselbe Ausgabe durch `grep -c '^docs/plan/adr/'`), verteilt auf sechs
  Dateien, von denen **fünf** `**Status:** Accepted` tragen
  (`grep -m1 '^\*\*Status:\*\*' <datei>` je Datei) — ein Wächter dieser Bauart stünde auf
  unveränderlichen Artefakten dauerhaft rot ([`AGENTS.md`](../AGENTS.md) §3.4), und die einzige
  Abhilfe dafür wäre eine Ausnahme wie
  [`ADR-0017`](../docs/plan/adr/0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md). **(b) Ein
  d-check-Modul, das die Form trägt**, deckt den **Wert** nicht: die Vorfrage ist am neuen Tag
  wiederholt und unverändert — das `os/exec`-Kommando oben ist über `v0.65.0` leer (Exit 1), kein
  Modul fährt einen Lauf. Und die Form allein trägt die Setzung nicht, denn eine Zahl mit einem
  falschen Kommando daneben erfüllt sie. Aktiviert eine spätere Entscheidung ein Modul, das die
  Form fordern kann (heute keines: `grep -c 'structure' .d-check.yml` → **0**, Exit 1), ist die
  Form-Hälfte hier nachzutragen; an der Permanenz ändert das nichts, solange der Wert ungedeckt
  bleibt. **(c) Bleibt** — und steht hier als Entscheidung, nicht als Rest.
- **Ihr Träger ist der Rollen-Wechsel, nicht ein Gate — und ein Trigger, der auf einen fremden
  Lauf zeigt, ist keiner.** Der Sprung auf `v0.65.0` ist erfolgt; die Planungsdateien des
  Pin-Commits nennen diesen Eintrag nicht. `git grep -c 'MR-025' 3ce4ea3 -- '*slice-122-*.md'`
  ist leer (Exit 1), während dieselbe Suche über die Kennung des Vorgänger-Sprungs **5** Treffer
  in einer Datei liefert, und `git log -1 --format=%B 3ce4ea3 | grep -c 'MR-025'` → **0**. Die
  Messung hängt an `3ce4ea3`, nicht am heutigen Baum — über diesem fände sie sich selbst.
  Gefunden hat die Klasse in genau jenem Lauf etwas anderes: zwei getrennte Kontexte, Review nach
  Modul 10 und Verifikation nach Modul 11, meldeten **unabhängig** dieselbe falsche Zeile
  ([Review](../docs/reviews/2026-08-28-slice-122-review.md) HIGH-1,
  [Verifikation](../docs/reviews/2026-08-28-slice-122-verify.md) V-2). Das ist die
  Trägerschaft, die diese Setzung hat.

### MR-026 — Die Hard-Rule-Nummer ist eine Adresse, keine Baseline-Entsprechung

- **Datum:** 2026-08-27
- **Geltungsbereich:** der Hard-Rule-Block [`AGENTS.md`](../AGENTS.md) §3 gegenüber
  `.harness/baseline/v3.5.2/templates/AGENTS.template.md` §3. **Dieses Repo, nicht das
  emittierte:** die emittierte `AGENTS.md` entsteht aus jener Vorlage, nicht aus dieser
  Fassung — dort trägt jede Regel die Nummer der Vorlage.
- **Setzung 1 — die beiden Sätze decken sich in der Nummer nicht, und sie sollen es nicht.**
  Eine Hard-Rule-Nummer adressiert einen Abschnitt **dieses** Repos; sie sagt weder eine
  Rangfolge noch eine Entsprechung in der Vorlage zu. Deckungsgleich ist **eine einzige**
  Überschrift, nämlich §3.3 —
  `comm -12 <(grep -E '^### 3\.' AGENTS.md | sort) <(grep -E '^### 3\.' .harness/baseline/v3.5.2/templates/AGENTS.template.md | sort) | wc -l`
  → **1**. Die Docker-only-Regel führt die Vorlage als §3.1, dieses Repo als §3.9. Die
  Architektur-Regel der Vorlage (§3.4) steht hier gar nicht in §3, sondern als Hard Rule im
  Kopf des Artefakts, das sie bindet —
  `grep -c 'sprach- und meilensteinfrei' spec/architecture.md` → **1**: eine Aussage hat
  einen Ort, und für diese ist es die Architektur-Sicht selbst.
- **Setzung 2 — eine neue Hard Rule wird angehängt, nicht eingeschoben.** Die Nummer folgt
  dem Zeitpunkt der Aufnahme, nicht der Wichtigkeit. Der Grund ist die Reichweite einer
  Umnummerierung: `git grep -oE '§ ?3\.[1-8]([^0-9]|$)' | wc -l` → **2292** Nennungen im
  Index (**kein Erwartungswert** — die Zahl wandert mit jedem neuen Verweis;
  [`MR-025`](#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) Setzung 2).
  Davon lägen **333** in lebenden Artefakten und wären nachzuziehen
  (`git grep -oE '§ ?3\.[1-8]([^0-9]|$)' -- ':!.harness/baseline' ':!docs/reviews' ':!docs/plan/planning/done' | wc -l`),
  **1958** in Zeitdokumenten
  (`git grep -oE '§ ?3\.[1-8]([^0-9]|$)' -- 'docs/reviews' 'docs/plan/planning/done' | wc -l`),
  die nicht nachgezogen werden
  ([`MR-025`](#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  §Geltungsbereich) und danach eine **andere** Regel benennen würden als zum Zeitpunkt
  ihrer Messung. Diese Verschiebung sieht kein Gate: die Nennungen sind Fließtext, kein
  Anker — ein HTML-Anker mit der alten Kennung rettet sie darum nicht. Ein Anhängen kostet
  **0** Nachzüge.
- **Setzung 3 — die Durchsetzungsschicht nennt je Ebene die Nummer ihrer Ebene.** Der
  Begründungstext eines Guards zeigt auf den Abschnitt, den der geblockte Lauf lesen soll.
  Für die Dogfood-Fassung ist das die Nummer dieses Repos, für die emittierte die der
  Vorlage — `grep -c 'Hard Rule 3\.1' .claude/hooks/pretooluse-command-guard.sh` → **3**
  (diese drei Stellen nennen die Docker-only-Regel und gehören auf §3.9 gezogen; sie sind
  Implementer-Artefakt) gegenüber
  `grep -c 'Hard Rule 3\.1' internal/emit/templates/enforce/pretooluse-command-guard.sh`
  → **1**, die richtig steht und **nicht** mitwandert
  ([`ADR-0004`](../docs/plan/adr/0004-durchsetzungs-emission.md) trennt die Ebenen,
  [`MR-002`](#mr-002--gate-nachweis-mechanik-und-claude-hooks) die Mechanik).
- **Begründung — dieselbe Kennung bezeichnet heute zwei Regeln.** Außerhalb dieses Eintrags,
  der sie zitiert, führen **drei** lebende Artefakte die Kennung „Hard Rule 3.1"
  (`git grep -lF 'Hard Rule 3.1' -- ':!docs/reviews' ':!docs/plan/planning/done' ':!.harness/baseline' ':!harness/conventions.md' | wc -l`);
  die **2** Nennungen der Roadmap
  (`grep -c 'Hard Rule 3\.1' docs/plan/planning/in-progress/roadmap.md`) meinen *Keine
  halluzinierten Gates*, die Guard-Nennungen meinen Docker-only. Eine Nummer, die beide
  Sätze zugleich adressieren soll, trägt genau diese Kollision; als bloße Adresse mit
  deklarierter Ebene trägt sie sie nicht.
- **Kein Wächter, und das gehört dazu.** Kein Modul der heutigen `.d-check.yml` hält eine
  Fließtext-Nennung „§3.N" gegen die Überschriften von [`AGENTS.md`](../AGENTS.md)
  (`grep -m1 '^modules:' .d-check.yml` führt `links, anchors, ids, matrix, codepaths, spans`
  — `anchors` prüft Link-Ziele, nicht Prosa), und `make comment-claims` hat keine
  Markdown-Datei im Prüfbereich. Die Setzungen liegen im Feedforward-Quadranten; ihr Träger
  ist der Griff beim Anlegen einer Regel, nicht ein Gate danach.
- **Auflösungs-Trigger:** die Re-Baseline auf einen Stand, dessen AGENTS-Vorlage einen
  Hard-Rule-Satz führt, der sich mit dem hiesigen deckt — dann ist gegen die
  Upstream-Nummerierung zu halten und dieser Eintrag nach
  [`MR-020`](#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf) auf Kopf und
  Zeiger zurückzuführen. Bis dahin permanent.
- **Hebt die Blankett-Klausel aus [`MR-000`](#mr-000--baseline-aussage) für diesen Punkt auf**
  — *„keine inhaltlichen Adaptionen ggü. Baseline-Default"*.
  [`MR-000`](#mr-000--baseline-aussage) bleibt unangetastet, seine übrigen Setzungen gelten
  fort.

### MR-027 — d-check-Pin v0.65.0 (Ignore-Marker in zwei Achsen verengt)

- **Datum:** 2026-08-28
- **Geltungsbereich:** `d-check.mk` (`DCHECK_IMAGE`/`DCHECK_DIGEST`, Kopfkommentar),
  `internal/emit/emit.go` (emittierter Default-Pin), `Makefile` (das Tag-Beispiel im Kommentar
  über `DCHECK_TAG`), §Baseline; setzt
  [`MR-024`](#mr-024--d-check-pin-v0620-structure-verfügbar) fort.
- **Adaption:** Das gepinnte d-check-Image springt **v0.62.0 → v0.65.0**. Digest
  `sha256:5ea03abe7918381c68203d8ac078a78d0d4ab91b5478e87c66b5a7b4fda41288`, **dreifach belegt**
  und jedes Bein hier gefahren: lokaler RepoDigest
  (`docker image inspect --format '{{index .RepoDigests 0}}' ghcr.io/pt9912/d-check:v0.65.0`),
  Registry (`docker buildx imagetools inspect ghcr.io/pt9912/d-check:v0.65.0`, Zeile `Digest:`)
  und der Release-Body als Fremdquelle
  (`gh release view v0.65.0 --repo pt9912/d-check --json body -q .body`, daraus die
  `sha256:`-Zeichenkette) — alle drei mit demselben Wert
  ([`LH-QA-02`](../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)). Der **lebende** Pin steht
  in `d-check.mk` und, daran gekoppelt, in `internal/emit/emit.go`; hier steht, wogegen er
  belegt ist.
- **Zweck: der Zeilen-Marker `d-check:ignore` verengt sich, in zwei Achsen.** Ab v0.65.0
  unterdrückt er einen Befund nur noch, wenn er **(a)** in einem echten HTML-Kommentar steht
  (**Form**) **und (b)** nicht in Inline-Code eingeschlossen ist (**Lage**). An einer Sonde
  außerhalb des Repos gemessen statt dem CHANGELOG geglaubt — vier Marker-Lagen über einem toten
  Codepath und über einer unverlinkten Kennung, beide Digests, netzlos, Mount `:ro`; `codepaths`
  und `ids` antworten in allen vier Lagen gleich:

  | Lage des Markers | `v0.62.0` | `v0.65.0` |
  |---|---|---|
  | echter HTML-Kommentar, `<!-- d-check:ignore -->` | unterdrückt | unterdrückt |
  | blanke Prosa, Marker ohne Kommentar | unterdrückt | **meldet** |
  | Kommentar-Form in Inline-Code eingeschlossen | unterdrückt | **meldet** |
  | ohne Marker (Kontrolle) | meldet | meldet |

  Die Kontrollzeile färbt unter beiden Versionen — der Aufbau misst seinen Gegenstand und nicht
  seine eigene Untauglichkeit. Die Summen der Sonde: `3 Datei(en) geprüft, 2 Befund(e)` gegen
  `3 Datei(en) geprüft, 6 Befund(e)`, beide Exit 1, je Modul **zwei** zusätzliche Meldungen aus
  den zwei entwerteten Lagen; die Befundmenge von `v0.62.0` ist **echte Teilmenge** der von
  `v0.65.0`.
- **An der Quelle bestätigt, nicht nur am Verhalten.** Am lokalen d-check-Klon trägt
  `git show v0.65.0:internal/hexagon/core/rules/ids.go` beide Bedingungen in **einer** Funktion
  `markerLines` — `commentMarkerRe` für die Form, `stripInlineCodeByLine` für die Lage (Zeilen
  **161** und **182** derselben Ausgabe, `grep -n 'commentMarkerRe = \|stripped := stripInlineCodeByLine'`)
  —, und `codepaths.go` konsumiert dieselbe Funktion
  (`git show v0.65.0:internal/hexagon/core/rules/codepaths.go | grep -n 'markers := markerLines'`
  → **64**). Die zwei Module reagieren identisch, weil es **eine** Änderung an **einer**
  geteilten Stelle ist, nicht zwei zufällig gleichlautende.
- **Strenge-Bilanz an der Quell-Differenz, nicht an der CHANGELOG-Aufzählung
  ([`MR-024`](#mr-024--d-check-pin-v0620-structure-verfügbar)-Muster).** Aktiv sind sechs Module
  (`grep -m1 '^modules:' .d-check.yml` → `links, anchors, ids, matrix, codepaths, spans`). Über
  `v0.62.0..v0.65.0` bewegen sich am Klon genau **zwei** ihrer Regeldateien, und **beide
  verlieren Zeilen**: `git diff --numstat v0.62.0..v0.65.0 -- internal/hexagon/core/rules/ids.go`
  → **35/11**, dasselbe Kommando für `codepaths.go` → **28/6**. Für `links.go`, `anchors.go`,
  `matrix.go` und `spans.go` gibt es **keine** Zeile aus. Entfernte Zeilen an einem aktiven Modul
  sind der Grund, die Bilanz nicht am Trockenlauf zu ziehen.
- **Trockenlauf vor dem Pin (Pflicht, belegt —
  [`MR-009`](#mr-009--d-check-pin-sprung-und-codepath-ventile)-Muster).** Beide Digests netzlos
  (`--network none`) gegen eine Kopie des Baums außerhalb des Repos (`git archive b3d6dcc`),
  Mount `:ro`, unveränderte `.d-check.yml`: beide `d-check: 435 Datei(en) geprüft, 0 Befund(e)`,
  Exit 0, `diff` der zwei Ausgaben leer. **Die Dateizahl ist kein Erwartungswert** — sie wächst
  mit jedem Dokument
  ([`MR-025`](#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) Setzung 2);
  tragend sind die **0** und die leere `diff`-Ausgabe.
- **Was dieser Lauf trägt — und was nicht.** Er trägt **eine** Richtung, und in ihr ist er
  diesmal die ganze Antwort: kein Marker, den v0.65.0 nicht mehr beachtet, unterdrückt über
  diesem Korpus einen Befund — das sagt die **0** unter v0.65.0 unmittelbar. Der Grund ist
  ausdrücklich **nicht**, dass das Repo keine solchen Marker führte: von den Marker-Zeilen in
  getracktem Markdown außerhalb der vendored Baseline stehen **84** von **268** **nicht** in
  Kommentar-Form — `git grep -h 'd-check:ignore' -- '*.md' ':!.harness/baseline/**' | wc -l`
  für die Gesamtzahl, derselbe Strom durch `grep -c '<!--[^>]*d-check:ignore'` → **184** für die
  Kommentar-Form. **Keine Erwartungswerte:** alle drei wachsen mit jedem Dokument, das den Marker
  erwähnt. Sie tragen nur nichts — es ist Prosa *über* den Marker. Die **Baseline gehört per
  Pathspec ausgenommen, nicht per Zeilen-Filter**: ein nachgeschaltetes
  `grep -v '.harness/baseline'` verwirft auch Treffer, die den Baseline-Pfad bloß im Text nennen,
  und liegt über diesem Bestand um **12** Zeilen zu niedrig (derselbe Strom durch
  `grep -c '\.harness/baseline'`). In der **Gegenrichtung** ist der Lauf über einer
  0-Befund-Basis **informationsleer**: eine weggefallene Befundklasse erzeugt dieselbe Ausgabe
  wie eine unveränderte.
- **Die Gegenrichtung, auf einer Nicht-Null-Basis gemessen.** Dieselbe Kopie, alle Marker in
  getracktem Markdown außerhalb der vendored Baseline entwertet
  (`find . -name '*.md' -not -path './.harness/baseline/*' -print0 | xargs -0 grep -l 'd-check:ignore'`
  → **142** Dateien, darin per `sed -i` die Zeichenkette ersetzt; Restzähler danach **0**), dann
  beide Digests: **beide** melden `435 Datei(en) geprüft, 37 Befund(e)`, Exit 1, `diff` der
  sortierten Ausgaben ist **leer**, und die Klassen decken sich je Version
  (`grep -v '^d-check:' <ausgabe> | awk -F'\t' '{print $NF}' | sort | uniq -c` → **15**
  `codepath-missing`, **22** `id-unlinked`). Auf einer Basis, auf der ein Wegfall sichtbar
  geworden wäre, fällt nichts weg. **Tragend sind die Gleichheit der zwei Mengen und die leere
  `diff`-Ausgabe**, nicht die Datei- oder Befundzahl — beide wandern mit dem Baum.
- **Kein ADR nötig ([`AGENTS.md`](../AGENTS.md) §3.5).** §3.5 verlangt einen ADR für
  **Senkungen**. Gemessen verengt der Sprung an zwei aktiven Modulen und senkt an keinem; die
  zwei Läufe oben sind die zwei Richtungen dieser Aussage, und keiner von beiden ist der
  Trockenlauf allein. „Anheben → Steering-Loop, kein ADR nötig" hält
  [`MR-001`](#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids) fest.
- **Das Gate-Fragment ändert sich in genau einer Zeile.** `--print-mk` unter beiden Digests,
  netzlos: je **68** Zeilen (`wc -l`), und `diff` der zwei Ausgaben führt **genau eine** Zeile —
  `DCHECK_IMAGE ?= …:v0.62.0` → `…:v0.65.0`. Die Target-Aufzählung aus
  [`MR-010`](#mr-010--d-check-gate-fragment-tool-generiert) Setzung 2 bleibt damit inhaltlich
  stehen (`grep -cE '^docs?-[a-z-]+:' <fragment>` → **12** über beide Ausgaben und über
  `d-check.mk`); abgeglichen ist sie trotzdem, weil ihr Auflösungs-Trigger den Abgleich verlangt
  und nicht sein Ergebnis. `diff <frische v0.65.0-Ausgabe> d-check.mk | grep -c '^[0-9]'` → **4**
  Hunks: genau die vier Handgriffe aus
  [`MR-010`](#mr-010--d-check-gate-fragment-tool-generiert) Setzung 1.
- **Emitter-Pin gekoppelt (Tier-1-Drift).** `internal/emit`s `DefaultImage`/`DefaultDigest` zieht
  per go-Test mit (`TestDefaultImage_MatchesCanonical`/`TestDefaultDigest_MatchesCanonical` lesen
  `d-check.mk`); die emittierte Starter-Config bleibt `modules: [links, anchors]`
  ([`MR-017`](#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)) — dieser Sprung
  bewegt eine Versions-Referenz, keine Prüfbereichs-Entscheidung.
- **Der Sprung ist nicht nur Wartung, und der Grund steht hier, weil er sonst nirgends stünde.**
  d-checks `[0.65.0]` behebt **vierzehn** behebbare HIGH-CVEs im ausgelieferten Image (neun
  `golang.org/x/crypto`, vier `golang.org/x/net`, eine `go-git`) — gelesen am lokalen Klon mit
  `awk '/^## \[0\.65\.0\]/,/^## \[0\.64\.0\]/' CHANGELOG.md`, also **Fremdquelle**, nicht hier
  gemessen. Kein Gate dieses Repos scannt das gepinnte Fremd-Image, und
  `make freshness-dcheck` sagt „ein neuer Tag ist da", nicht „der gepinnte ist verwundbar".
- **Kein Wächter über einer Versions-Nennung in Prosa, und das gehört dazu.** Keines der sechs
  aktiven Module hält eine solche Nennung gegen den lebenden Pin
  (`grep -c 'versions\|pins' .d-check.yml` → **0**, Exit 1). Das gelieferte Modul mit genau
  diesem Vertrag ist `versions` (`DC-FA-VER-001`: *„jeder Versions-Pin muss die aktuelle Version
  seines Paares tragen, sonst Befund `version-stale`"* —
  `git show v0.65.0:internal/hexagon/core/rules/versions.go` am lokalen Klon); es liegt im
  gepinnten Image und ist **nicht** adoptiert. Solange kein Wächter zwei Fassungen
  zusammenhält, führt §Baseline die Version deshalb nicht als zweite Fassung, sondern zeigt auf
  den lebenden Ort.
- **Auflösungs-Trigger:** permanent; bei d-check-Release `d-check --print-mk` neu erzeugen +
  Digest neu pinnen ([`MR-010`](#mr-010--d-check-gate-fragment-tool-generiert)
  §Auflösungs-Trigger) und die Strenge-Bilanz über die neue Spanne neu ziehen — **an der
  Quell-Differenz der Regeldateien** und, wo ein aktives Modul Zeilen **verliert**, zusätzlich an
  einer Gegenmessung auf **Nicht-Null-Basis**; der Trockenlauf allein beantwortet die
  §3.5-Frage in keiner der beiden Richtungen.

### MR-028 — Der Wirksamkeits-Anlass steht im Eintrag, blank statt verlinkt

- **Datum:** 2026-08-28
- **Geltungsbereich:** die **Form** eines Eintrags dieses Blocks. **Nicht** `docs/plan/adr/`,
  **nicht** `docs/plan/planning/**` — dort entscheidet, wer sie führt.
- **Adaption — Zusatz zur Vorlagen-Form, keine Abweichung von einer Baseline-Regel.** Die
  vendored Vorlage (`.harness/baseline/v3.5.2/templates/harness/conventions.template.md`,
  Kommentar über dem Adaptions-Block) nennt sechs Pflichtfelder — ID · Datum · Geltungsbereich ·
  Adaption · Begründung · Auflösungs-Trigger — und verbietet daneben nichts. Ein Eintrag nennt
  zusätzlich seinen **Wirksamkeits-Anlass**: die Arbeitseinheit, durch die die Abweichung in Kraft
  trat. `Datum` beantwortet *wann*, der Anlass *wodurch* — ein Register, das seine Abweichungen
  ohne ihn führt, behauptet sie. Denselben Rang haben zwei verwandte Nennungen: der
  **Beleg-Anlass** (unter welchem Lauf eine hier stehende Messung entstand) und die **Umdeutung
  einer Adresse in einem immutablen Artefakt**, für die es keinen zweiten Ort gibt
  ([`AGENTS.md`](../AGENTS.md) §3.4; §Modus-Deklaration trägt den Fall).
- **Form: blank, nicht als Link — Setzung, nicht Lücke.** `ids.patterns` in `.d-check.yml` führt
  drei Muster (`grep -c 'regex:' .d-check.yml` → **3**), und keines trifft eine Slice-Nummer
  (`grep -A1 'regex:' .d-check.yml | grep -c 'slice'` → **0**). Eine Slice-Nummer ist eine
  **Adresse**, und Adressen verfallen: dieselbe Grenze ziehen
  [`ADR-0014`](../docs/plan/adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md) und
  [`ADR-0016`](../docs/plan/adr/0016-verweis-traegt-tag-und-zitat.md) als *Eigenschaft statt
  Adresse*. Unter Link-Pflicht ginge
  [`MR-016`](#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird) rot, dessen Satz
  über das Nachschneiden zwei Nummern nennt, deren **Nicht**-Auflösen sein Beleg ist — die
  Link-Pflicht bestrafte dort genau die Aussage. Eine Nummer aus einem fremden Projekt trägt
  dessen Namen als Präfix: blanke Nummern haben keinen Namensraum, und dieser Block nennt eine
  fremde Nummer, die auch als eigene existiert.
- **Grenze: Anlass ist Herkunft, nicht Prozess-Zustand.** Eine Nennung, die auf **ungeschnittene**
  Arbeit zeigt, nennt keinen Anlass, sondern eine Erwartung; ihr Ort ist der Plan, der sie führt.
  Gemessen:
  `grep -oE 'slice-[0-9]{2,}(/[0-9]{2,})*' harness/conventions.md | tr '/' '\n' | sed 's/^\([0-9]\)/slice-\1/' | sort -u | while read n; do ls docs/plan/planning/*/$n-*.md >/dev/null 2>&1 || echo "$n"; done`
  → **vier** Ausgaben, davon **eine** eine ungeschnittene Einheit. Die drei übrigen sind keine
  Verweise: zwei sind der Beleg aus
  [`MR-016`](#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird), einer ein Glob in
  einem Kommando. Welche der vier was ist, trennt das Kommando nicht — das ist ein **Urteil, kein
  Muster** ([`AGENTS.md`](../AGENTS.md) §3.6), und die Nummer steht deshalb hier nicht noch einmal.
  Der eine Fall liegt in
  [`MR-005`](#mr-005--harness-tools-unter-harnesstools-layout-adaption) und wird dort **nicht
  angefasst**: der Eintrag ist akzeptiert, und die Nennung heilt oder verfällt mit der
  Entscheidung über den Schnitt.
- **Was hier nicht entschieden wird.** Die Punkte 5 und 6 der Liste *„Was ersatzlos entfällt"* in
  [`MR-021`](#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben)
  binden nach dessen Pflichtfeld `Geltungsbereich`
  [`MR-018`](#mr-018--span-schema-der-telemetrie-erfassung) und zwei Abschnitte des
  Technik-Stratums. Sie sind das Streich-Protokoll **eines** Rumpfs — die vier Posten davor nennen
  einzelne Sätze jenes Eintrags —, kein blockweites Verbot; blockweit lesbar sind allein ihre
  allgemein formulierten Begründungen. Dieser Eintrag nimmt jenen deshalb nicht zurück und
  bessert ihn nicht nach: die append-only-Disziplin der Vorlage steht, und
  [`MR-020`](#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf) hebt sie nur für den
  Rumpf eines **vollständig aufgehobenen** Eintrags auf. Er stellt die Form daneben, gegen die zu
  lesen ist.
- **Kein Wächter, und die Lücke ist die Regel selbst.** Kein Modul aus `modules:` der
  `.d-check.yml` sieht eine blanke Slice-Nummer — `links` prüft Links, `ids` die drei Muster oben.
  Ein Wächter wäre nur um den Preis der Link-Pflicht zu haben, und die ist oben verworfen. Träger
  ist der Rollen-Wechsel vor der Änderung.
- **Auflösungs-Trigger:** permanent für die Form. Die Grenze fällt neu an, sobald `ids.patterns`
  ein Slice-Muster führt — dann ist zuerst zu entscheiden, was mit den Nummern geschieht, deren
  Nicht-Auflösen heute ein Beleg ist.

### MR-029 — Der `scan.ignore`-Zensus wandert, und sein dritter Grund ist keine Scoping-Aussage

> **ÜBERHOLT: die Werkzeug-Aussage des Auflösungs-Triggers — *„Am heutigen Pin gibt es ihn nicht"* → [`MR-034`](#mr-034--das-geteilte-referenz-ventil-trägt-am-gepinnten-stand).** Die übrigen Setzungen dieses Eintrags gelten fort, Zensus und Aufnahme-Grenze eingeschlossen.

- **Datum:** 2026-08-28
- **Wirksamkeits-Anlass:** slice-081 — derselbe Lauf, der den Eintrag in `.d-check.yml` gesetzt
  hat ([`MR-028`](#mr-028--der-wirksamkeits-anlass-steht-im-eintrag-blank-statt-verlinkt)).
- **Geltungsbereich:** `scan.ignore` in `.d-check.yml`, und **nur** dieser Posten von
  [`MR-001`](#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids). Dessen übrige
  Setzungen — die Modul-Aktivierung `matrix`/`spans`, `ids` mit `link-policy: always`, das
  `MR`-Pattern — bleiben unangetastet und gelten fort.
- **Löst auf:** die Zensus-Aussage aus
  [`MR-001`](#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids) — *„`scan.ignore` führt
  heute vier Einträge, aus zwei Gründen"* samt der Klassifikation *„beide sind Scoping, keine
  Gate-Lockerung …"*. Jener Eintrag bleibt unangetastet; seine Zahl und seine Klassifikation sind
  ab hier überholt, und **hier** steht der geltende Stand.
- **Ausgelöst durch:** [`ADR-0017`](../docs/plan/adr/0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md)
  §Konsequenzen, Folgepflicht 2 — fällig geworden mit dem Baseline-Stand `v5.12.0`, der den dort
  vorausgesetzten Tausch wirklich gefahren hat.
- **Adaption — der Zensus, mit dem Kommando, das ihn ausgibt.** `scan.ignore` führt **fünf**
  Einträge: `grep -m1 '^  ignore:' .d-check.yml | grep -o '"[^"]*"' | wc -l` → **5**. Sie stehen
  aus **drei** Gründen, und der dritte ist von anderer Klasse als die zwei davor:
  1. **Vendored Fremd-Dokumente** — dieses Repo *spiegelt* sie, statt sie zu schreiben:
     `.harness/baseline/**` ([`MR-007`](#mr-007--baseline-committet-vendored-statt-gefetchter-cache))
     und `docs/user/claude-hooks-referenz.md`. **Scoping:** der Prüfumfang schrumpft nicht um
     Bestand, den dieses Repo autoritativ schreibt.
  2. **Kein Fließtext** — `**/*.template.md` sind Ziel-Form-Vorlagen mit Platzhaltern statt
     Verweisen, `.tmp/**` ist Wegwerf-Bestand. **Scoping:** beide tragen keine Aussage, die
     veralten könnte.
  3. **Ein eingefrorenes, repo-autoritatives Artefakt** —
     `docs/plan/adr/0013-technik-stratum-als-zielort.md`. **Hier stimmt *Scoping* nicht mehr:**
     diese Datei schreibt das Repo selbst, und sie verlässt den Gate ganz, über alle aktiven
     Module. Der Eintrag ist eine **Senkung** nach [`AGENTS.md`](../AGENTS.md) §3.5 und
     ausschließlich durch
     [`ADR-0017`](../docs/plan/adr/0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md)
     autorisiert. Grund dort: die Datei trägt einen Markdown-Link in den vendored Baum unter dem
     abgelösten Tag, [`AGENTS.md`](../AGENTS.md) §3.4 sperrt die Reparatur, und ein Befund, den
     niemand beheben darf, hält `make gates` dauerhaft rot
     ([`LH-QA-01`](../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) eine
     Ebene tiefer).
- **Die Aufnahme-Grenze, verbatim aus der Entscheidung, die sie setzt.**
  [`ADR-0017`](../docs/plan/adr/0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md)
  §Entscheidung: *„Das ist eine Aufnahme-Grenze, keine Aufnahme-Regel: jeder zusätzliche Eintrag
  ist eine neue Senkung und löst `AGENTS.md` §3.5 erneut aus — auch dann, wenn er dieselbe
  Bedingung erfüllt wie dieser."* Die Liste ist **extensional geschlossen**: Punkt 3 deckt genau
  eine namentlich genannte Datei, nicht ihre Klasse. Ein zweites eingefrorenes Artefakt mit
  gebrochenem Baseline-Link braucht eine eigene ADR.
- **Der Preis, selbst nachgefahren (2026-08-28).** Sonde über einer isolierten Kopie des
  Index-Baums außerhalb des Repos (`git ls-files -z | tar --null -T - -cf -`, entpackt in ein
  temporäres Verzeichnis), gepinntes Image, `--network none`, Mount `:ro`, einziger Unterschied
  der fünfte Eintrag: ohne ihn `d-check: 441 Datei(en) geprüft, 9 Befund(e)`, mit ihm
  `d-check: 440 Datei(en) geprüft, 8 Befund(e)`. **Tragend ist der Delta — je genau eins —, nicht
  das Absolutwert-Paar:** der Nenner ist der Markdown-Bestand des Repos und wandert mit ihm
  ([`MR-025`](#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) Setzung 2).
  Der eine erkaufte Befund ist der unbehebbare.
- **Warum ein neuer Eintrag und keine Korrektur in
  [`MR-001`](#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids) — die Folgepflicht
  verlangt eine Wirkung, nicht einen Mechanismus.**
  [`ADR-0017`](../docs/plan/adr/0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) nennt
  jenen Eintrag als den Ort, an dem Zahl, Klassifikation und Grenze zu lesen sein müssen. Die
  Append-only-Disziplin verbietet, sie *dort hinein* zu schreiben — und sie tut es am adoptierten
  Stand schärfer als am abgelösten. `v3.5.2` sagte *„keine nachträglichen inhaltlichen Änderungen
  an akzeptierten Einträgen — nur neue Einträge oder explizite Aufhebungen via neuen MR"*
  (`.harness/baseline/v3.5.2/templates/harness/conventions.template.md`, Kommentar über dem
  Adaptions-Block; die Zeile existiert am neuen Stand nicht mehr). `v5.12.0` sagt
  *„Einträge werden nie überschrieben"*
  ([`grundlagen-harness-dateien.md`](../.harness/baseline/v5.12.0/regelwerk/grundlagen-harness-dateien.md#harnessconventionsmd-als-konventionsspeicher)
  §harness/conventions.md als Konventionsspeicher) und benennt diesen Fall eigens:
  *„Rückbau ist ein neuer Eintrag, kein Edit — eine aufgelöste `MR-<NNN>` wird nicht
  überschrieben, sondern bekommt einen Nachfolger, der sie auflöst und den Baseline-Stand nennt,
  der den Trigger gefeuert hat. Die alte Zeile ist die historisch korrekte Aussage über den
  damaligen Zustand"*
  ([`modul-02-harness-bootstrap.md`](../.harness/baseline/v5.12.0/regelwerk/modul-02-harness-bootstrap.md)).
  Der Satz in [`MR-001`](#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids) ist die
  richtige Aussage über den 13. Juni; ihn zu überschreiben löschte, **wann** die Klassifikation
  noch stimmte. **Dieses Repo hat den Fall bereits einmal so entschieden:**
  [`MR-021`](#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben)
  lässt die Zahl *„zwei Abweichungen von der Vorlagen-Form"* in
  [`MR-019`](#mr-019--technik-stratum-als-rang-2-der-source-precedence) stehen und schreibt
  daneben, dass sie überholt ist. Die Folgepflicht ist damit **erfüllt, nicht umgangen** — nur
  der Ort ist der Nachfolger statt des Originals.
- **Wo der nächste Antragsteller die Grenze liest, steht sie zweimal.** Nicht nur hier, sondern
  im Kommentar über `scan.ignore` in `.d-check.yml` selbst — an der Stelle, an der ein sechster
  Eintrag entstünde. Das ist Absicht: ein Register wird gelesen, wenn man es sucht, ein
  Config-Kommentar, wenn man die Zeile anfasst.
- **Kein Wächter, und das gehört dazu.** Kein Modul aus `modules:` der `.d-check.yml` hält die
  `scan.ignore`-Liste gegen die in ADRs autorisierten Einträge; [`AGENTS.md`](../AGENTS.md) §3.5
  hat keinen Sensor. Das steht in
  [`ADR-0017`](../docs/plan/adr/0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md)
  §Fitness Function so und wird hier nicht anders behauptet
  ([`LH-QA-01`](../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). Träger ist
  der Rollen-Wechsel vor der Änderung.
- **Auflösungs-Trigger:** Der Zensus wandert mit der Liste — ein sechster Eintrag ist ein eigener
  §3.5-Vorgang mit eigener ADR und löst diesen Eintrag ab. Die **Klassifikation** fällt neu an,
  sobald `links` einen referenz-weiten Ausschluss bekommt: dann ersetzt der präzise Knopf den
  datei-weiten Eintrag, Punkt 3 entfällt, und der Zensus steht wieder auf zwei Gründen. Am
  heutigen Pin gibt es ihn nicht, und auch der Zeilen-Marker ist keiner: eine Sonde außerhalb des
  Repos — eine Datei mit drei gebrochenen Links, einer ohne Marker, einer mit
  `<!-- d-check:ignore -->` auf derselben Zeile, einer mit dem Marker in der Zeile davor,
  `modules: [links, anchors]` — meldet **alle drei**
  (`d-check: 1 Datei(en) geprüft, 3 Befund(e)`). `d-check:ignore` deckt `links` **nicht**;
  [`MR-027`](#mr-027--d-check-pin-v0650-ignore-marker-in-zwei-achsen-verengt) misst ihn an `ids`
  und `codepaths`.

### MR-030 — Der Rollen-Name der Baseline und der Bezeichner fallen zusammen

> **ÜBERHOLT: der Halbsatz *„ohne dass jemand sie richtig beheben kann"* → [`MR-034`](#mr-034--das-geteilte-referenz-ventil-trägt-am-gepinnten-stand).** Die übrigen Setzungen dieses Eintrags gelten fort — der Link bleibt tot und wird nicht repariert.

- **Datum:** 2026-08-28
- **Wirksamkeits-Anlass:** slice-081.
- **Geltungsbereich:** Punkt 2 der Liste *„Was als Delta bleibt"* in
  [`MR-021`](#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben)
  und der Absatz über die kanonischen Agenten-Typ-Namen in
  [`spec/spezifikation.md`](../spec/spezifikation.md#5-metriken-und-tracing-felder) §5. **Nicht**
  Punkt 1 desselben Eintrags — die vierte Spalte (`Sensor`) weicht weiter von der
  Modul-Vorschrift ab und bindet fort.
- **Löst auf:** die Abweichung *„`implementer` statt Implementation"*. Sie hat keinen Gegenstand
  mehr.
- **Ausgelöst durch Baseline-Stand:** `v5.12.0`. Der abgelöste Stand schrieb
  `participant I as Implementation`, der adoptierte schreibt `participant I as Implementer` —
  `grep -c 'participant I as Implementer' .harness/baseline/v5.12.0/regelwerk/modul-08-agentenrollen.md`
  → **1**.
- **Sachstand, gemessen statt behauptet.** Die sechs Rollen-Namen des Moduls sind
  kleingeschrieben Zeichen für Zeichen die sechs Bezeichner des Technik-Stratums — die Ausgabe
  dieses Vergleichs ist **leer**:

  ```sh
  diff <(grep -oE 'participant [A-Za-z]+ as [A-Za-z]+' .harness/baseline/v5.12.0/regelwerk/modul-08-agentenrollen.md | awk '{print tolower($4)}' | sort -u) \
       <(grep -A1 'kanonischen Namen der Agenten-Typen' spec/spezifikation.md | grep -oE '`[a-z]+`' | tr -d '`' | sort -u)
  ```

  Was bleibt, ist die **Kleinschreibung**, und sie trifft alle sechs gleich — eine
  Bezeichner-Konvention, keine Aussage über die dritte Rolle. Der kleingeschriebene Bezeichner
  kommt im Regelwerk selbst nicht vor
  (`grep -rl 'implementer' .harness/baseline/v5.12.0/regelwerk/ | wc -l` → **0**); es gibt also
  auch keine Modul-Schreibweise, von der er abwiche.
- **Der Wert bleibt, wo er steht.** Die Zielort-Setzung aus
  [`MR-021`](#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben) —
  technische Festlegung ins Stratum — ist unberührt: die sechs kanonischen Namen stehen weiter in
  [`spec/spezifikation.md`](../spec/spezifikation.md#5-metriken-und-tracing-felder) §5. Was dort
  entfällt, ist allein der **Abweichungs**-Satz; er benannte eine Differenz, die es nicht mehr
  gibt.
- **[`MR-021`](#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben)
  wird nicht angefasst — und sein Verweis wird nicht nachgezogen.** Der Rumpf bleibt, weil dies
  eine Teil-Aufhebung ist:
  [`ADR-0014`](../docs/plan/adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md) Festlegung 2 (a)
  lässt ihn nur bei **vollständiger** Aufhebung fallen — *„bei Teil-Aufhebung bleibt der Rumpf,
  weil sein Rest bindet"*. Und der Markdown-Link jenes Punktes bleibt auf dem alten Tag stehen:
  der Satz um ihn herum sagt, das Modul nenne die dritte Rolle *Implementation*, und das ist
  **über `v3.5.2` wahr**. Ein Tag-Tausch machte daraus eine Aussage, die die Quelle nicht
  hergibt — bei grünem Gate, also von *laut* nach *stumm*. Genau diese Klasse verwirft
  [`ADR-0016`](../docs/plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 1, und
  [`ADR-0023`](../docs/plan/adr/0023-verweis-beschluss-traegt-ueber-den-sprung.md) hält den
  Beschluss gegen genau diesen Zielstand neu. Der Verweis ist eine **datierte Aussage**
  (Klasse 2), kein Navigations-Zeiger.
- **Was das kostet, und es wird hier nicht kleingeredet.** Diese eine Zeile bleibt ein
  `target-missing`-Befund von `make docs-check` — in einem **lebenden** Artefakt, dauerhaft, ohne
  dass jemand sie richtig beheben kann. Die Ausnahme aus
  [`ADR-0017`](../docs/plan/adr/0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) deckt sie
  **nicht**: jene ist extensional auf eine Datei geschlossen, und ein Eintrag für diese Datei
  nähme ihre **254** Link-Vorkommen über **68** eindeutige Ziele mit aus der Prüfung —
  `grep -oE '\]\([^)]+\)' harness/conventions.md | wc -l` und derselbe Strom durch
  `sort -u | wc -l`, **keine Erwartungswerte**
  ([`MR-025`](#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) Setzung 2), sie
  wachsen mit jedem Verweis. Der Zeilen-Marker deckt sie ebenfalls nicht: `d-check:ignore` wirkt
  auf `ids` und `codepaths`, nicht auf `links`
  ([`MR-029`](#mr-029--der-scanignore-zensus-wandert-und-sein-dritter-grund-ist-keine-scoping-aussage)
  §Auflösungs-Trigger, dort an einer Sonde gemessen).
- **Die strukturelle Ursache ist benannt, nicht behoben: dieser Block läuft in der Inline-Form.**
  Ein akzeptierter Eintrag ist eine **unveränderliche Region in einer änderbaren Datei** — diesen
  Fall kennt [`ADR-0016`](../docs/plan/adr/0016-verweis-traegt-tag-und-zitat.md) nicht: dort
  verläuft die Linie *„an der Änderbarkeit der Quelle"*, und `harness/conventions.md` steht
  namentlich auf der änderbaren Seite, deren lokaler Pfad ein *„Navigations-Zeiger"* ist und wo
  *„der Bump zieht ihn nach"* gilt. In der **Verzeichnis-Form**, die der adoptierte Stand zum
  Default macht, gäbe es die Kollision nicht: jeder Eintrag läge in einer eigenen Datei unter
  *harness/conventions/*, und mit dem Eintreten seines Auflösungs-Triggers wanderte er nach
  *conventions/done/* — dieselbe Zeitdokument-Klasse, für die
  [`ADR-0016`](../docs/plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 4 das Entfallen
  der Adresse bei stehenbleibendem Text bereits regelt. Die Migration ist ein eigener Slice und
  wird hier weder vollzogen noch beschlossen.
- **Kein Wächter, und die Lücke ist die Regel selbst.** Zu welcher Klasse eine Nennung des alten
  Tags gehört, steht im Satz um sie herum und nicht in der Zeichenkette;
  [`ADR-0023`](../docs/plan/adr/0023-verweis-beschluss-traegt-ueber-den-sprung.md) Festlegung 3
  verwirft den nächstliegenden Kandidaten mit gemessener Begründung und gibt die stille Hälfte
  ausdrücklich als **unbewacht** aus. Träger ist der Rollen-Wechsel vor der Änderung.
- **Auflösungs-Trigger:** permanent als Sachstands-Feststellung — eine aufgelöste Abweichung löst
  sich nicht ein zweites Mal auf. Neu zu entscheiden ist der Gegenstand erst, wenn ein künftiger
  Baseline-Stand die dritte Rolle wieder anders schreibt als die übrigen fünf; dann ist die
  Differenz gegen den dann geltenden Tag zu messen und als neuer Eintrag zu führen.

### MR-031 — Die Kommentar-Regel steht in der adoptierten Baseline

- **Datum:** 2026-08-29
- **Wirksamkeits-Anlass:** slice-081 — der Baum-Tausch, mit dem der Auflösungs-Trigger von
  [`MR-022`](#mr-022--kommentar-regel-als-vorgriff-auf-eine-neuere-baseline) feuerte. slice-082 §3
  weist den Vollzug einem Architect-Lauf zu ([`AGENTS.md`](../AGENTS.md) §3.8); dieser Eintrag
  ist sein Ergebnis.
- **Geltungsbereich:** [`MR-022`](#mr-022--kommentar-regel-als-vorgriff-auf-eine-neuere-baseline)
  und [`MR-023`](#mr-023--die-platzierung-der-kommentar-regel-ist-keine-abweichung) je
  **vollständig**, dazu [`AGENTS.md`](../AGENTS.md) §3.7. **Nicht** die emittierte Ebene: was ein
  Zielrepo an Kommentar-Regeln bekommt, entscheidet der Slice, der die Tool-Ebene entscheidet.
- **Ersetzt-Baseline-Regel:** keine. Dieser Eintrag setzt **keine** Abweichung, er baut zwei
  zurück. Nach dem Wortlaut der Eintrags-Vorlage — *„Ein Eintrag, der keine benannte Regel
  ersetzt, ist ein **Fork**, keine Adaption"* — ist er damit ein Fork; die Einordnung wird hier
  ausgesprochen, nicht bestritten. Was daraus für den Block folgt — ob ein Rückbau-Eintrag hier
  stehen darf oder anderswohin gehört —, entscheidet slice-083 §2 für den ganzen Block und nicht
  dieser Eintrag für sich.
- **Adaption:** [`AGENTS.md`](../AGENTS.md) §3.7 ist keine Abweichung mehr, sondern die
  repo-lokale Fassung einer Baseline-Regel: die Vorlage des adoptierten Standes führt sie unter
  derselben Nummer und demselben Titel, der Grundlagen-Abschnitt schreibt sie aus, und §3.7 zeigt
  seit diesem Eintrag dorthin. Die zwei Einträge, die sie als *Vorgriff* und als
  *Platzierungs-Abweichung* führten, sind vollständig aufgehoben.
- **Begründung:** Ein Vorgriff hört auf, einer zu sein, sobald der Stand da ist, auf den er
  vorgriff. Bliebe er stehen, führte der Block eine Abweichung, die es nicht gibt — dieselbe
  Klasse von Schaden, gegen die
  [`MR-023`](#mr-023--die-platzierung-der-kommentar-regel-ist-keine-abweichung) entstand, nur mit
  umgekehrtem Vorzeichen.
- **Löst auf:** beide Einträge, vollständig.
  [`MR-022`](#mr-022--kommentar-regel-als-vorgriff-auf-eine-neuere-baseline) deklarierte die Regel
  als **Vorgriff** auf einen Kurs-Stand, den die adoptierte Baseline nicht führte;
  [`MR-023`](#mr-023--die-platzierung-der-kommentar-regel-ist-keine-abweichung) hob dessen Punkt 2
  auf und ließ eine Textprüfung offen. Beide Gegenstände sind fort. Nach
  [`MR-020`](#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf) behalten sie Nummer,
  Überschrift wörtlich, `Datum` und eine Zeiger-Zeile; den Rumpf trägt `git`. **Das ist die heute
  geltende Form**, und sie bleibt richtig, falls der Adaptions-Durchgang
  [`MR-020`](#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf) selbst ablöst: der
  Rumpf liegt in `git`, gleich welche Form danach gilt.
- **Ausgelöst durch Baseline-Stand:** `v5.12.0`. Die AGENTS-Vorlage führt die Regel als Hard Rule
  mit derselben Nummer und demselben Titel
  (`grep -c '^### 3\.7 Ein Kommentar beschreibt, was da ist$' .harness/baseline/v5.12.0/templates/AGENTS.template.md`
  → **1**), ausgeschrieben trägt sie der Grundlagen-Abschnitt
  (`grep -c '^### Was ein Kommentar trägt — Code, Konfiguration, Skripte$' .harness/baseline/v5.12.0/regelwerk/grundlagen-harness-dateien.md`
  → **1**). Damit ist der Trigger aus
  [`MR-022`](#mr-022--kommentar-regel-als-vorgriff-auf-eine-neuere-baseline) in seinem **ersten**
  Zweig eingetreten — *deckt sie sich* —, und zwar gemessen am adoptierten Baum, nicht vorab.
- **Die Textprüfung, die [`MR-023`](#mr-023--die-platzierung-der-kommentar-regel-ist-keine-abweichung)
  offenließ — gefahren, mit Ausgang.** Ihre Frage: *trägt der hiesige Wortlaut die
  Upstream-Semantik?* Die Antwort ist **nein an drei Posten** (die Liste unten zählt sie auf), und
  alle drei sind **übernommen**; keiner bleibt als Abweichung stehen. Ein Kommando misst beide
  Seiten:

  ```sh
  for p in 'Zustandsfeld' 'seit welle-' 'grundlagen-harness-dateien'; do
    printf '%-28s AGENTS.md=%s Vorlage=%s\n' "$p" \
      "$(grep -c "$p" AGENTS.md)" \
      "$(grep -c "$p" .harness/baseline/v5.12.0/templates/AGENTS.template.md)"
  done
  ```

  **Keine Erwartungswerte** ([`MR-025`](#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2) — die Zahlen wandern mit beiden Texten; tragend ist, dass keine der drei Zeilen links
  auf **0** steht.
  1. **Die Zustandsfeld-Hälfte.** Die Vorlage bindet dieselbe Regel auf `Stand`-/`Status`-Zellen
     und nennt sie schon in der Geltungszeile. §3.7 trägt sie jetzt als eigenen Absatz, mit den
     Orten dieses Repos (Roadmap-Faden, Meilenstein-Tabelle, ADR-Index) und der Trennung
     Drift-Log ↔ Closure-Log.
  2. **Der dritte Herkunfts-Anker `· seit welle-<NN>`.** Er fehlte in der Aufzählung der
     Begründung. Dieses Repo fährt Wellen-Betrieb
     ([`MR-016`](#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)), also greift er.
  3. **Der Zeiger auf den Grundlagen-Abschnitt.** Die Vorlage nennt ihn; §3.7 nannte ihn nicht und
     war damit die einzige Fassung der Regel im Repo — genau die zweite Fassung, die driftet.
- **Was über die Vorlage hinaus stehen bleibt, und warum es keine Abweichung ist.** Vier Stücke:
  der **Geltungsbereich** (`.harness/baseline/` ausgenommen, ein Zeitdokument ist kein lebendes
  Register, die emittierte Ebene entscheidet ein anderer Slice), der **Cutoff**, die
  **Quellen-Klausel** (*„Beschrieben wird die Stelle, nicht der Vorgang, der sie erzeugt hat"* —
  ein Kommentar sitzt in keinem Rang der Source Precedence und trägt darum nicht den Grund einer
  Entscheidung) und die **Wächter-Aussage** *„`make comment-claims` prüft, ob ein genannter Sensor
  existiert, nicht, worüber ein Kommentar spricht"*. Keines schränkt die Baseline-Regel ein — die
  Baseline sagt über den Bestand nichts, verlangt also kein Nachrüsten; einen Sensor behauptet
  keine der beiden Fassungen; und die Quellen-Klausel wendet die Baseline-Hard-Rule *„Wer Herkunft
  nennt, nennt sie als **ein** auflösbares Feld … und nie als Absatz"* an, statt sie zu verengen:
  Sie nimmt keine der fünf Klassen weg und keine der dort genannten Anker-Formen — `· seit
  welle-<NN>` und, für wellenlos verkörperte Regeln, `· seit slice-<NNN>` bleiben zulässig.

  ```sh
  grep -c 'nennt sie als \*\*ein\*\* auflösbares Feld' .harness/baseline/v5.12.0/regelwerk/grundlagen-harness-dateien.md   # Hard-Rule-Satz, den die Klausel anwendet
  grep -c 'seit slice-<NNN>'                           .harness/baseline/v5.12.0/regelwerk/grundlagen-traceability.md      # die Anker-Form, die erhalten bleibt
  grep -c 'Rang-Zeiger'                                AGENTS.md                                                          # die Klasse, die nicht wegfällt
  ```

  **Keine Erwartungswerte** ([`MR-025`](#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2) — tragend ist, dass keine der drei Zeilen auf **0** steht. Eine Ergänzung ohne
  Einschränkung ist keine Adaption; [`MR-000`](#mr-000--baseline-aussage) wird für diesen Punkt
  nicht ausgenommen.
- **Was hinter der Vorlage zurückbleibt: der zweite Träger fehlt — eine Lücke, keine Adaption.**
  Der Grundlagen-Abschnitt nennt für **beide** Hälften zwei Träger: *„Träger aller drei ist das
  Briefing … plus der HIGH-Eintrag Kommentar trägt keine der fünf Klassen im Reviewer-Skill …"*
  — die zwei ausgelassenen Klammern nennen die Ziel-Form-Pfade der Vorlagen — und, für
  Zustandsfelder, *„ist das eine Chronik?" ist ein Urteil — Träger sind das Briefing (§3.7) und
  der HIGH-Eintrag Zustandsfeld trägt Chronik im Reviewer-Skill."* Der zweite existiert im Repo
  für **keine** der beiden Hälften:

  ```sh
  grep -c 'Kommentar trägt keine' .harness/skills/reviewer.md                                                      # 0
  grep -c 'Zustandsfeld' .harness/skills/reviewer.md                                                               # 0
  grep -c 'Kommentar trägt keine' .harness/baseline/v5.12.0/templates/.harness/skills/reviewer.template.md          # 1
  grep -c 'Zustandsfeld trägt Chronik' .harness/baseline/v5.12.0/templates/.harness/skills/reviewer.template.md     # 1
  ```

  **Keine Erwartungswerte** ([`MR-025`](#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2) — alle vier wandern; tragend ist, dass die zwei oberen **0** sind. §3.7 trägt die
  Regel im Repo damit **allein**, und dieser Eintrag beansprucht für den fehlenden zweiten Träger
  **keine** Deckung. Geschlossen wird die Lücke am Reviewer-Skill; den führt slice-083 §2
  namentlich, samt der Feststellung, dass für ihn keine Quelle eine schreibende Rolle benennt.
- **Zwei allgemeine Sätze aus dem Rumpf von
  [`MR-023`](#mr-023--die-platzierung-der-kommentar-regel-ist-keine-abweichung) binden weiter —
  hier steht, wo.** [`ADR-0014`](../docs/plan/adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md)
  Festlegung 2 (b) lässt einen Rumpf nur fallen, wenn jede bindende Aussage einen bindenden Ort
  hat oder als *ersatzlos* mit Grund verzeichnet ist. Zwei Sätze jenes Rumpfs galten über seinen
  Gegenstand hinaus:
  1. *„Ein Sachfehler ist dabei kein eigener Vorgang und braucht keine eigene Regel: entweder kann
     der Punkt ersatzlos entfallen … oder an seiner Stelle muss etwas Richtiges binden — dann
     trägt es der aufhebende Eintrag. In beiden Fällen bleibt der Rumpf unangetastet."*
     **Bindender Ort:** [`ADR-0014`](../docs/plan/adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md)
     Festlegung 2 (a) und (b) — dieselbe Regel eine Ebene höher, als aktive ADR und damit stärker
     gebunden als hier.
  2. *„Eine Aussage über die Baseline nennt darum den Tag, gegen den sie gemessen ist."*
     **Bindender Ort:** [`MR-033`](#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist),
     wo der Satz wörtlich als Setzung 1 steht. Ein bestehender Ort trägt ihn nicht:
     [`ADR-0016`](../docs/plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 2 bindet die
     Beleg-Form in Artefakten, *die unveränderlich werden*, und stellt
     [`AGENTS.md`](../AGENTS.md) und diese Datei ausdrücklich auf die änderbare Seite; das
     Pflichtfeld `Ausgelöst durch Baseline-Stand` der Eintrags-Vorlage greift nur zusammen mit
     `Löst auf`. Übrig bliebe genau die Klasse, in der der Fehler entstand — eine
     Baseline-Aussage in einem lebenden Artefakt.

  **Ersatzlos entfällt nichts.** Der übrige Rumpf hatte seinen Gegenstand in
  [`MR-022`](#mr-022--kommentar-regel-als-vorgriff-auf-eine-neuere-baseline) Punkt 2 und in einer
  Vorab-Messung gegen einen Tag, der nie adoptiert wurde; er fällt mit dem Gegenstand, nicht gegen
  eine fortbestehende Bindung.
- **Die Vorab-Messung ist ersetzt, nicht fortgeschrieben.**
  [`MR-023`](#mr-023--die-platzierung-der-kommentar-regel-ist-keine-abweichung) maß den ersten
  Zweig gegen `v5.3.0` und erklärte ihn für `v5.3.1`; adoptiert wurde `v5.12.0`. Die zwei
  Kommandos oben laufen gegen den Baum, der im Repo liegt — eine Messung gegen einen Tag, der nie
  adoptiert wurde, trägt hier nichts.
- **Kein Wächter, und das gehört dazu.** Kein Sensor dieses Repos hält [`AGENTS.md`](../AGENTS.md)
  §3.7 gegen die Vorlage: kein Modul aus `modules:` der `.d-check.yml` vergleicht zwei
  Markdown-Abschnitte, und `.harness/baseline/**` steht ohnehin in `scan.ignore`
  ([`MR-029`](#mr-029--der-scanignore-zensus-wandert-und-sein-dritter-grund-ist-keine-scoping-aussage)).
  `make comment-claims` hat keine Markdown-Datei im Prüfbereich. Auch der fehlende zweite Träger
  ist unbewacht: kein Ziel liest den Reviewer-Skill gegen seine Vorlage. Die Kommandos oben sind
  reproduzierbar, gefahren werden sie von keinem Gate. Träger ist der Form-Vergleich der
  Re-Baseline (slice-083 für die Singleton-Form und für den Skill) und der Rollen-Wechsel vor der
  Änderung.
- **Auflösungs-Trigger:** permanent als Sachstands-Feststellung — ein eingeholter Vorgriff wird
  nicht ein zweites Mal eingeholt. Neu anzufassen ist der Gegenstand erst, wenn ein künftiger
  Baseline-Stand §3.7 ändert; dann ist gegen den dann geltenden Tag zu messen und als neuer
  Eintrag zu führen.

### MR-032 — Ein überholter Eintrag trägt eine Kopf-Marke auf seinen Nachfolger

- **Datum:** 2026-08-29
- **Wirksamkeits-Anlass:** slice-081 — dort entstand die erste Teil-Ablösung dieses Blocks
  ([`MR-029`](#mr-029--der-scanignore-zensus-wandert-und-sein-dritter-grund-ist-keine-scoping-aussage)),
  und ihr Vorgänger blieb ohne Zeiger. slice-082 §2 (3) führt die Form als **einmal zu
  entscheidenden** Posten; entschieden ist sie hier, weil dieser Block dem Architect gehört
  ([`AGENTS.md`](../AGENTS.md) §3.8). **Der Bestands-Durchgang jenes Slice ist damit nicht
  vorweggenommen:** gesetzt sind hier nur die Marken, die kein Zeichen eines bestehenden Eintrags
  ersetzen; was in der älteren `HISTORIE`-Beschriftung liegt, bleibt liegen (unten).
- **Geltungsbereich:** die **Form** eines Eintrags dieses Blocks, dessen Aussage ein späterer
  Eintrag ablöst. **Nicht** `docs/plan/adr/` — dort gilt [`AGENTS.md`](../AGENTS.md) §3.4
  unverändert; **nicht** die emittierte Ebene.
- **Ersetzt-Baseline-Regel:**
  [`grundlagen-harness-dateien.md`](../.harness/baseline/v5.12.0/regelwerk/grundlagen-harness-dateien.md#harnessconventionsmd-als-konventionsspeicher)
  §harness/conventions.md als Konventionsspeicher — *„Der Zustand ist die Verzeichnis-Position,
  kein Status-Feld."*
- **Adaption:** Der Zustand *überholt* bekommt in diesem Block einen Träger im Text — eine
  Blockquote-Zeile im Kopf des überholten Eintrags —, weil die Verzeichnis-Position, die ihn in
  der Baseline trägt, hier nicht existiert.
- **Begründung:** Wer auf dem Vorgänger landet, erfährt sonst nichts. Gemessen ist der Fall:
  [`MR-029`](#mr-029--der-scanignore-zensus-wandert-und-sein-dritter-grund-ist-keine-scoping-aussage)
  löste eine Aussage von [`MR-001`](#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
  ab, und [`MR-001`](#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids) — der Eintrag,
  den jeder Lauf zuerst liest — sagte sie weiter unwidersprochen.
- **Setzung 1 — die Form ist eine Zeile, und sie wird gesetzt, nicht getauscht.** Direkt unter der
  Überschrift, vor der Feldliste, steht eine Blockquote-Zeile in dieser Gestalt:

  ```text
  > **ÜBERHOLT: <Reichweite> → <Ziel>.** <Fortgeltung, optional>
  ```

  `<Reichweite>` ist die abgelöste Aussage, benannt — oder *dieser Eintrag*, wenn alles fällt.
  `<Ziel>` ist die Anker-Adresse des ablösenden Eintrags, wie sie jeder Verweis
  auf eine Adaption trägt. Nehmen **mehrere** spätere Einträge dieselbe Aussage punktweise aus und
  ist die Menge offen, tritt an die Stelle des Links das **Kommando**, das die Menge ausgibt: ein
  Link auf einen von mehreren behauptete eine Rangfolge, die es nicht gibt, und eine Liste von
  Links müsste bei jedem weiteren Eintrag nachgezogen werden. `<Fortgeltung>` sagt in einem Satz,
  was am Eintrag weiter bindet. Weitere Blockquote-Zeilen sind frei.

  **Sonst wird am Eintrag nichts geändert:** der Rumpf bleibt wörtlich, kein Satz wird
  nachgezogen, keine Adresse getauscht — **und eine Marke, die in einer früheren Beschriftung
  schon dasteht, wird nicht umgeschrieben.** Sie zu ersetzen wäre genau das Überschreiben, das die
  Ziel-Form ausschließt; die Form bindet die Marke, die **gesetzt** wird.
- **Setzung 2 — warum das Setzen kein Überschreiben ist.** Die Ziel-Form sagt *„Einträge werden
  nie überschrieben"*. Die Marke ersetzt keine Aussage des Eintrags; sie tritt daneben und nennt
  seinen **Zustand**. Diesen Zustand trägt die Baseline in ihrer **Default-Form** ohne einen
  einzigen Zeichenwechsel im Eintrag: dort liegt jede Adaption in einer eigenen Datei, und mit dem
  Eintreten ihres Triggers wandert sie nach `conventions/done/` — *„Der Zustand ist die
  Verzeichnis-Position, kein Status-Feld."* Dieses Repo führt den Block **inline**; eine Position
  gibt es nicht, also braucht der Zustand einen Träger im Text.
- **Setzung 3 — wer sie setzt und wann.** Der **ablösende** Eintrag setzt sie in derselben
  Änderung, in der er entsteht. Ein Nachfolger ohne Marke am Vorgänger ist unvollständig.
- **Setzung 4 — wann sie fällig ist und wann nicht.** Fällig, wenn ein späterer Eintrag eine
  Aussage **namentlich** ablöst oder für überholt erklärt. **Nicht** fällig, wo ein Eintrag von
  vornherein eine datierte Momentaufnahme ist, deren lebender Wert anderswo deklariert steht: die
  d-check-Pin-Kette ist dieser Fall — §Baseline nennt den lebenden Pin und führt die Kette, und
  ein Pin-Eintrag löst keine Aussage ab, sondern datiert einen Sprung. Und **nicht** fällig macht
  sie ein Satz, der einem anderen Eintrag zusagt, er werde nicht **korrigiert**: einen solchen
  Satz löst die Marke nicht ab, sie hält ihn ein — siehe die Auslegung unten.
- **Die Nicht-Anfassen-Sätze dieses Blocks werden nicht aufgehoben, sondern in ihrer Reichweite
  ausgesprochen.** Sechs Sätze sagen über einen anderen Eintrag, er bleibe *unangetastet* bzw.
  werde *nicht angefasst*: in
  [`MR-019`](#mr-019--technik-stratum-als-rang-2-der-source-precedence),
  [`MR-020`](#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf) und
  [`MR-026`](#mr-026--die-hard-rule-nummer-ist-eine-adresse-keine-baseline-entsprechung) über
  [`MR-000`](#mr-000--baseline-aussage), in
  [`MR-021`](#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben) über
  [`MR-019`](#mr-019--technik-stratum-als-rang-2-der-source-precedence), in
  [`MR-029`](#mr-029--der-scanignore-zensus-wandert-und-sein-dritter-grund-ist-keine-scoping-aussage)
  über [`MR-001`](#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids) und in
  [`MR-030`](#mr-030--der-rollen-name-der-baseline-und-der-bezeichner-fallen-zusammen) über
  [`MR-021`](#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben).
  Was sie schützen, ist der **Rumpf**: keine Korrektur, kein nachgezogener Satz, keine getauschte
  Adresse. Genau das lässt die Marke unberührt (Setzung 2) — sie ist damit **erfüllt, nicht
  aufgehoben**, und keiner der sechs Einträge bekommt deswegen eine Marke.
  [`MR-029`](#mr-029--der-scanignore-zensus-wandert-und-sein-dritter-grund-ist-keine-scoping-aussage)
  sagt den Grund selbst: *„ihn zu überschreiben löschte, wann die Klassifikation noch stimmte"* —
  die Marke löscht davon nichts, sie sagt daneben, dass es nicht mehr stimmt. Diese Auslegung
  steht hier und nur hier; die sechs Einträge werden dafür nicht angefasst.

  **Die Menge ist gelesen, nicht gegrept.** Ein zeilenweises Muster findet sie nicht vollständig —
  der Satz in
  [`MR-021`](#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben)
  bricht zwischen *nicht* und *angefasst* um. Absatzweise gelesen liefert
  `awk 'BEGIN{RS=""} /unangetastet|nicht[[:space:]]+angefasst/ {n++} END{print n}' harness/conventions.md`
  die **Kandidaten**; welche davon ein Satz über einen anderen Eintrag sind, ist ein Urteil, kein
  Muster ([`AGENTS.md`](../AGENTS.md) §3.6) — die Zahl der Kandidaten wandert mit dem Block
  ([`MR-025`](#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) Setzung 2).
- **Warum `ÜBERHOLT` und nicht `HISTORIE`.** *Historie* ist das falsche Wort für ein Zustandsfeld:
  die Marke nennt den **Zustand** und den Beleg, nicht die Chronik
  ([`AGENTS.md`](../AGENTS.md) §3.7, Zustandsfeld-Hälfte); die Chronik hält `git`. Das ist der
  ganze Grund. **Ein Zensus-Argument steht hier bewusst nicht:** eine Zählung der gesetzten Marken
  (`grep -c '^> \*\*ÜBERHOLT: ' harness/conventions.md`) misst, wie oft die Beschriftung gewählt
  wurde, nicht, ob die Wahl richtig war — und die Zahl im anderen Instrument
  (`grep -c '^- \*\*Aufgehoben durch ' harness/conventions.md`) hängt von der Beschriftung
  überhaupt nicht ab. Beide Zahlen wandern
  ([`MR-025`](#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) Setzung 2).
- **Zwei Beschriftungen liegen im Bestand, und sie bleiben liegen.**
  [`MR-004`](#mr-004--sessionstart-regelwerk-injektor) und
  [`MR-006`](#mr-006--regelwerk-cache-als-split-modul-verzeichnis) tragen ihre Marke
  in der älteren Beschriftung `HISTORIE` (`grep -c '^> \*\*HISTORIE' harness/conventions.md`; die Zahl wandert).
  Sie werden **nicht** umgeschrieben — Setzung 1 bindet die Marke, die gesetzt wird, und ein
  Tausch wäre ein Überschreiben. Der Preis ist benannt: bis zu einem Durchgang, der die zwei
  Einträge aus einem eigenen Grund anfasst, findet man Marken über **zwei** Muster statt über
  eines. Der Zuschnitt dieses Durchgangs liegt bei slice-082 §2 (3).
- **Zwei Instrumente, zwei Fälle, und sie werden nicht zusammengelegt.** **Teil-Ablösung** → Rumpf
  bleibt, Kopf-Marke; [`ADR-0014`](../docs/plan/adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md)
  Festlegung 2 (a) lässt den Rumpf nur bei **vollständiger** Aufhebung fallen. **Vollständige
  Aufhebung** → Nummer, Überschrift wörtlich, `Datum` und eine `Aufgehoben durch`-Zeile, Rumpf
  entfällt ([`MR-020`](#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf)). Ein
  Eintrag trägt genau eines von beiden.
- **Kein Wächter, und das gehört dazu.** Kein Modul aus `modules:` der `.d-check.yml` liest, ob
  ein Eintrag, dessen Aussage abgelöst ist, eine Marke trägt — `links` prüft Link-Ziele, `ids` die
  drei Muster —, und die Fälligkeit aus Setzung 4 ist ein **Urteil, kein Muster**
  ([`AGENTS.md`](../AGENTS.md) §3.6). Ein `grep` zählt gesetzte Marken, nicht fehlende.
  Träger ist der Rollen-Wechsel vor der Änderung.
- **Auflösungs-Trigger:** die Migration dieses Blocks in die **Verzeichnis-Form**, die der
  adoptierte Stand zum Default macht und die
  [`MR-030`](#mr-030--der-rollen-name-der-baseline-und-der-bezeichner-fallen-zusammen) als eigenen,
  noch ungeschnittenen Vorgang benennt. Dann trägt die Verzeichnis-Position den Zustand, und die
  Marke wird gegenstandslos.
- **Hebt die Blankett-Klausel aus [`MR-000`](#mr-000--baseline-aussage) für diesen Punkt auf**
  — *„keine inhaltlichen Adaptionen ggü. Baseline-Default"*.
  [`MR-000`](#mr-000--baseline-aussage) behält seinen Rumpf wörtlich; dass die Klausel punktweise
  ausgenommen ist, sagt seit diesem Eintrag seine Kopf-Marke, und seine übrigen Setzungen gelten
  fort.

### MR-033 — Eine Aussage über die Baseline nennt den Tag, gegen den sie gemessen ist

- **Datum:** 2026-08-29
- **Wirksamkeits-Anlass:** die vollständige Aufhebung von
  [`MR-023`](#mr-023--die-platzierung-der-kommentar-regel-ist-keine-abweichung) durch
  [`MR-031`](#mr-031--die-kommentar-regel-steht-in-der-adoptierten-baseline). Der Satz stand in
  jenem Rumpf und band über dessen Gegenstand hinaus;
  [`ADR-0014`](../docs/plan/adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md) Festlegung 2 (b)
  verlangt für ihn einen bindenden Ort oder einen Vermerk *ersatzlos mit Grund*. Dies ist der Ort.
- **Geltungsbereich:** die **lebenden**, repo-eigenen Markdown-Artefakte — derselbe Ausschnitt,
  den [`MR-025`](#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  §Geltungsbereich über vier Kommandos definiert; er steht hier nicht ein zweites Mal, weil zwei
  Fassungen desselben Ausschnitts driften. **Dieses Repo, nicht das emittierte:** was ein
  emittiertes Repo an Beleg-Regeln bekommt, entscheidet der Slice, der die Tool-Ebene entscheidet.
- **Ersetzt-Baseline-Regel:** keine — nach dem Wortlaut der Eintrags-Vorlage damit ein **Fork**.
  Dieselbe Einordnung und dieselbe offene Folge wie bei
  [`MR-031`](#mr-031--die-kommentar-regel-steht-in-der-adoptierten-baseline): was daraus für den
  Block folgt, entscheidet slice-083 §2.
- **Setzung 1, wörtlich aus dem aufgehobenen Rumpf übernommen:** *„Eine Aussage über die Baseline
  nennt darum den Tag, gegen den sie gemessen ist."* Wer schreibt, die Baseline führe etwas oder
  führe es nicht, sage es so oder anders, nennt den Stand, an dem er nachgesehen hat — im selben
  Absatz und nicht implizit über den gerade gepinnten Tag. Ein Kommando, dessen Pfad den Tag
  enthält, erfüllt die Setzung; ein Satz ohne Tag erfüllt sie nicht.
- **Setzung 2 — was die Setzung nicht verlangt.** Sie verlangt keine bestimmte Verweis-Form. Wo
  ein Artefakt unveränderlich wird, gilt daneben
  [`ADR-0016`](../docs/plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 2 mit ihren drei
  Teilen; wo es lebt, genügt der Tag. Und sie bindet die **Aussage über die Baseline**, nicht jede
  Nennung eines Pfad-Musters: eine Layout-Beschreibung nennt keinen Tag, sonst beschriebe sie
  einen Einzelfall — die Unterscheidung ist dieselbe, die
  [`ADR-0016`](../docs/plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 2 zwischen Beleg
  und Layout zieht.
- **Adaption:** Die Eintrags-Vorlage verlangt den Baseline-Stand als Pflichtfeld nur zusammen mit
  `Löst auf`. Hier gilt er für jede Baseline-Aussage in einem lebenden Artefakt dieses Repos,
  unabhängig von Feld und Datei.
- **Begründung (gemessen, nicht postuliert):** Der Schaden ist eingetreten und protokolliert. Eine
  Hard Rule samt Adaptions-Eintrag wurde in Kraft gesetzt auf eine behauptete Baseline-Abweichung,
  die es nicht gab — *„gemessen gegen einen Tag, den zwei Releases überholt hatten, und ohne die
  Mess-Version zu nennen"* ([`AGENTS.md`](../AGENTS.md) §3.8 §Begründung, wo derselbe Vorfall die
  Rollen-Trennung trägt). Ohne den Tag ist eine Baseline-Aussage nicht falsch, sondern
  **unprüfbar**: der Baum unter `.harness/baseline/` wandert mit jeder Re-Baseline, und ein Leser
  kann nicht unterscheiden, ob eine Aussage am heutigen Stand gemessen wurde oder an einem, den
  niemand mehr sehen kann.
- **Warum ein eigener Eintrag und nicht ein Satz in
  [`MR-031`](#mr-031--die-kommentar-regel-steht-in-der-adoptierten-baseline).** Die Setzung hat
  einen anderen Gegenstand als jener Eintrag; unter dessen Überschrift fände sie niemand, der sie
  sucht. Eine Aussage hat einen Ort.
- **Der Ort ist offen, die Verbindlichkeit nicht.** Wie
  [`MR-025`](#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) §*Der Ort ist
  offen* für seine Schwester-Setzung festhält, gehört eine Regel, die eine **Lücke füllt** statt
  von der Baseline abzuweichen, nach [`AGENTS.md`](../AGENTS.md) §3.8 nicht in diesen Block. Bis
  über den Block entschieden ist (slice-083 §2), gilt die Setzung von hier: er ist normativ wie
  eine ADR, nur ohne deren Immutabilität.
- **Cutoff — ab diesem Eintrag, kein Nachrüsten.** Gebunden ist die Baseline-Aussage, die
  geschrieben oder geändert wird; der **Bestand ist kein Arbeitsauftrag**. Seine Fläche ist
  gemessen, nicht geschätzt:
  `git grep -l 'Baseline' -- '*.md' ':!docs/reviews/**' ':!docs/plan/planning/done/**' ':!.harness/baseline/**' ':!*.template.md' | wc -l`
  nennt die lebenden Markdown-Dateien, in denen das Wort überhaupt vorkommt. Das ist die
  **Obergrenze der Fläche** und **kein Erwartungswert**
  ([`MR-025`](#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) Setzung 2) —
  keine Zahl von Verstößen: wie viele dieser Dateien eine Aussage ohne Tag tragen, sagt kein
  Kommando, weil die Zugehörigkeit ein Urteil ist ([`AGENTS.md`](../AGENTS.md) §3.6). Ein Maßstab
  über diesen Bestand wäre dauerhaft rot und entwertete die Setzung, statt sie zu tragen —
  dieselbe Begründung trägt den Cutoff in
  [`MR-025`](#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) und in
  [`AGENTS.md`](../AGENTS.md) §3.7.
- **Kein Wächter, und das gehört dazu.** Kein Modul aus `modules:` der `.d-check.yml` prüft, ob
  ein Satz über die Baseline einen Tag nennt; `links` prüft Auflösbarkeit, `ids` drei Kennungs-
  Muster. `make comment-claims` hat keine Markdown-Datei in seinem Prüfbereich. Die Setzung liegt
  im Feedforward-Quadranten; ihr Träger ist der Rollen-Wechsel vor der Änderung und die
  Review-Runde danach — der Vorfall aus der Begründung ist von einem zweiten Kontext gefunden
  worden, nicht von einem Gate.
- **Auflösungs-Trigger:** permanent. Ein Tag, gegen den gemessen wurde, hört nicht auf, die
  Prüfbarkeit zu tragen. Fällt die Setzung, dann durch Verlegung nach
  [`AGENTS.md`](../AGENTS.md) §3 — dann bleiben hier nach
  [`MR-020`](#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf) Kopf und Zeiger.

### MR-034 — Das geteilte Referenz-Ventil trägt am gepinnten Stand

- **Datum:** 2026-08-30
- **Wirksamkeits-Anlass:** slice-132.
- **Geltungsbereich:** die **Werkzeug-Aussage** über das Doku-Gate in zwei Einträgen dieses
  Blocks — der Satz *„Am heutigen Pin gibt es ihn nicht"* im Auflösungs-Trigger von
  [`MR-029`](#mr-029--der-scanignore-zensus-wandert-und-sein-dritter-grund-ist-keine-scoping-aussage)
  und der Halbsatz *„ohne dass jemand sie richtig beheben kann"* in
  [`MR-030`](#mr-030--der-rollen-name-der-baseline-und-der-bezeichner-fallen-zusammen). **Nicht**
  deren übrige Setzungen: der `scan.ignore`-Zensus samt seiner Klassifikation
  und seiner Aufnahme-Grenze gilt fort, ebenso die Feststellung, dass die Abweichung
  *„`implementer` statt Implementation"* keinen Gegenstand mehr hat, und ebenso beider Aussage,
  dass der Zeilen-Marker `d-check:ignore` das Modul `links` nicht deckt.
- **Löst auf:** genau die zwei Sätze oben. Jene Einträge bleiben unangetastet; ihr Rumpf ist die
  richtige Aussage über den Tag ihres Datums, und **hier** steht der geltende Stand.
- **Ausgelöst durch Baseline-Stand:** keiner. Die Ablösung hat keinen Baseline-Anlass — ausgelöst
  hat sie eine Messung gegen den gepinnten d-check. Die Eintrags-Vorlage
  (`.harness/baseline/v5.12.0/templates/harness/conventions/MR-NNN-titel.template.md`) kennt zu
  `Löst auf` nur den Baseline-Stand als Auslöser; dass eine Aussage über ein **Werkzeug** ihren
  Auslöser im Werkzeug-Pin hat, steht deshalb hier ausgeschrieben statt in einem Feld, das ihn
  nicht vorsieht.
- **Ersetzt-Baseline-Regel:** keine — nach dem Wortlaut der Eintrags-Vorlage damit ein **Fork**.
  Dieselbe Einordnung und dieselbe offene Folge wie bei
  [`MR-031`](#mr-031--die-kommentar-regel-steht-in-der-adoptierten-baseline) und
  [`MR-033`](#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist):
  was daraus für den Block folgt, entscheidet slice-083 §2.
- **Adaption — der Sachstand, mit den Kommandos, die ihn ausgeben.** Der gepinnte d-check ist
  `ghcr.io/pt9912/d-check:v0.65.0` unter dem Digest in `d-check.mk`. Er führt `ignore-refs` als
  **Top-Level**-Schlüssel, den `links`, `anchors` und `codepaths` gemeinsam honorieren, mit `in`
  (Glob auf die Quelldatei), `refs` (Globs auf das aufgelöste Ziel) und `keep`; der modul-lokale
  `codepaths.ignore-refs` aus [`MR-009`](#mr-009--d-check-pin-sprung-und-codepath-ventile) ist
  sein Alias. Der Schlüssel ist **älter als der Pin** und wurde zwischen seiner Einführung und
  ihm nicht entfernt — beide Zeilen gegen den lokalen Klon des Werkzeug-Repos:

  ```sh
  grep -c '^## \[0\.49\.0\] — 2026-07-18' /Development/d-check/CHANGELOG.md                             # 1
  awk '/^## \[0\.65\.0\]/,/^## \[0\.49\.0\]/' /Development/d-check/CHANGELOG.md | grep -c '^### Removed' # 0
  ```

  **Gemessen am eigenen Baum, mit beiden Skopen an einer roten Gegenprobe:** eine Sonde in
  `.d-check.yml` mit `in: "harness/conventions.md"` und
  `refs: [".harness/baseline/v3.5.2/regelwerk/modul-08-agentenrollen.md"]` liefert
  `469 Datei(en) geprüft, 0 Befund(e)` bei **unveränderter** Datei-Zahl; mit `in: "AGENTS.md"`
  und mit `refs` auf eine Nachbardatei desselben Baums kehrt der Befund je zurück. Das Ventil
  sitzt auf der **Referenz-Achse**: es nimmt keine Datei aus dem Prüfbereich, sondern die
  Referenzen, die `in` und `refs` gemeinsam treffen.
- **Der Name, unter dem man ihn sucht, ist nicht der, unter dem er steht.** Wer unter `links:`
  nach `ignore-refs` sucht, findet nichts und schließt aus der Abwesenheit auf die fehlende
  Fähigkeit. `d-check --print-config` gibt eine kommentierte **Beispiel**-Config aus, keine
  Schema-Liste; Abwesenheit darin ist keine Abwesenheit der Option. Dieselbe Klasse wie eine
  Trefferliste, die als Vollständigkeitsaussage gelesen wird.
- **Was daraus folgt — und was ausdrücklich nicht.** Der Link in
  [`MR-021`](#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben)
  Punkt 2 bleibt tot und wird nicht repariert: die Setzung aus
  [`MR-030`](#mr-030--der-rollen-name-der-baseline-und-der-bezeichner-fallen-zusammen) ist
  unberührt, und das Ventil ändert an jenem Eintrag kein Zeichen. Was nicht mehr trägt, ist
  allein die Folgerung, der **Befund** sei unvermeidbar. Ihn stummzuschalten ist eine Senkung
  nach [`AGENTS.md`](../AGENTS.md) §3.5 — der Prüfumfang kürzt sich um eine Referenz, die dieses
  Repo autoritativ schreibt — und wird darum nicht hier autorisiert, sondern in
  [`ADR-0026`](../docs/plan/adr/0026-eingefrorene-referenz-referenz-weit-ausgenommen.md).
- **Warum ein neuer Eintrag und keine Korrektur an den zwei Sätzen.** Der Block läuft
  append-only: *„Einträge werden nie überschrieben"*
  ([`grundlagen-harness-dateien.md`](../.harness/baseline/v5.12.0/regelwerk/grundlagen-harness-dateien.md#harnessconventionsmd-als-konventionsspeicher)
  §harness/conventions.md als Konventionsspeicher). Ein Satz, der zu seinem Datum richtig war,
  bleibt stehen; dass er es nicht mehr ist, sagt die Kopf-Marke daneben
  ([`MR-032`](#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)
  Setzungen 1 und 3, mit diesem Eintrag gesetzt).
- **Kein Wächter, und das gehört dazu.** Kein Modul aus `modules:` der `.d-check.yml` hält eine
  Aussage über ein Werkzeug gegen den Stand, unter dem das Werkzeug läuft — `links` prüft
  Link-Ziele, `ids` drei Kennungs-Muster —, und `make comment-claims` hat keine Markdown-Datei in
  seinem Prüfbereich. Ob ein Satz über ein Werkzeug spricht, ist überdies ein **Urteil, kein
  Muster** ([`AGENTS.md`](../AGENTS.md) §3.6). Träger ist der Rollen-Wechsel vor der Änderung.
- **Auflösungs-Trigger:** Der Sachstand wandert mit dem Pin. Verlöre ein künftiger d-check das
  geteilte `ignore-refs`, wäre die Aussage neu zu erheben und als neuer Eintrag zu führen; ein
  Re-Pin prüft das mit dem Trockenlauf, der ohnehin fällig ist. Die **Ablösung** der zwei Sätze
  ist davon unabhängig und permanent. Beide Sätze sprechen über den Stand, unter dem sie
  geschrieben wurden, und trafen ihn schon dort nicht: der gepinnte d-check war an ihrem Datum
  derselbe wie heute ([`MR-027`](#mr-027--d-check-pin-v0650-ignore-marker-in-zwei-achsen-verengt)),
  und der Schlüssel steht seit einem Release, das dieser Pin überholt (`0.49.0` gegen `v0.65.0`).
  Ihre Ablösung fällt darum nicht mit einem künftigen Pin weg.

### MR-035 — Der automatische Claude-Kontext trägt eine benannte, geschlossene Modul-Auswahl

- **Datum:** 2026-08-31
- **Wirksamkeits-Anlass:** kein Slice — die Ablage entstand außerhalb des Slice-Betriebs. Wirksam
  wurde sie mit dem Commit, der `.claude/rules/` in den Index nahm
  (`git log --diff-filter=A --format=%h -- .claude/rules/` → genau **ein** Hash).
  [`MR-028`](#mr-028--der-wirksamkeits-anlass-steht-im-eintrag-blank-statt-verlinkt) verlangt den
  Anlass als Arbeitseinheit und setzt für Slice-Nummern die blanke Form; hier steht das Kommando
  statt des Hashs, weil ein Hash eine Adresse ist und ein Rebase sie bewegt.
- **Geltungsbereich:** `.claude/rules/` und der Zugriffs-Absatz in
  [`AGENTS.md`](../AGENTS.md) §1. **Dieses Repo, nicht das emittierte** — das Werkzeug emittiert
  kein solches Verzeichnis (`ls internal/emit/templates/` nennt `agents`, `commands`, `enforce`
  und zwei Dateien, kein `rules`); was ein emittiertes Repo an Kontext-Regeln bekommt, entscheidet
  der Slice, der die Tool-Ebene entscheidet.
- **Ersetzt-Baseline-Regel:** keine — nach dem Wortlaut der Eintrags-Vorlage damit ein **Fork**.
  Dieselbe Einordnung und dieselbe offene Folge wie bei
  [`MR-031`](#mr-031--die-kommentar-regel-steht-in-der-adoptierten-baseline),
  [`MR-033`](#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
  und [`MR-034`](#mr-034--das-geteilte-referenz-ventil-trägt-am-gepinnten-stand): was daraus für
  den Block folgt, entscheidet slice-083 §2.
- **Was die Baseline sagt, gemessen am adoptierten Stand `v5.12.0`.** Zwei Sätze sprechen über das
  Halten des Regelwerks im Kontext, beide über den **ganzen** Baum:

  ```sh
  grep -c 'ohne das ganze Regelwerk im Kontext zu halten' .harness/baseline/v5.12.0/regelwerk/README.md                    # 1
  grep -c 'ohne das ganze Regelwerk im Kontext zu halten' .harness/baseline/v5.12.0/regelwerk/modul-02-harness-bootstrap.md # 1
  grep -rl 'claude/rules' .harness/baseline/v5.12.0/ | wc -l                                                               # 0
  ```

  Der erste ist eine **Fähigkeits**-Aussage (*„Pro Abschnitt eine Datei, damit ein Agent einen
  einzelnen Abschnitt laden kann, ohne …"*), der zweite beschreibt das **Nachschlagen** pro
  Entscheidung als Anwendung des Modul-0-Prinzips
  (`grep -c 'Per-Lauf-Relevantes gehört verkörpert, nicht extern' …/modul-02-harness-bootstrap.md`
  → **1**). Die Baseline kennt den Mechanismus nicht. **Grenze der Messung:** dass **kein** Satz
  eine Teilmenge im Auto-Kontext verbietet, ist eine Lesart und kein `grep` — die Zugehörigkeit
  eines Satzes zu dieser Frage ist ein **Urteil, kein Muster**
  ([`AGENTS.md`](../AGENTS.md) §3.6). Gemessen ist, was oben steht.
- **Setzung 1 — was der Zustand ist.** Unter `.claude/rules/` liegen **4** Einträge, alle als
  Symlink in den vendored Baum (`ls .claude/rules/*.md | wc -l` → **4**;
  `git ls-files -s .claude/rules/ | awk '$1=="120000"' | wc -l` → **4**, also keiner mit eigenem
  Text). Der Bestand des Regelwerks ist **26** Dateien
  (`ls .harness/baseline/v5.12.0/regelwerk/*.md | wc -l`); der Anteil im Auto-Kontext beträgt
  **18,1 %** der Zeichen
  (`awk -v a="$(cat .claude/rules/*.md | wc -c)" -v b="$(cat .harness/baseline/v5.12.0/regelwerk/*.md | wc -c)" 'BEGIN{printf "%.1f\n", a/b*100}'`).
  **Keine Erwartungswerte** ([`MR-025`](#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2) — alle drei wandern mit dem Verzeichnis und mit dem Tag. Dass Dateien unter diesem
  Pfad in den Kontext geladen werden, steht in der committet vendored Werkzeug-Doku
  ([`docs/user/claude-hooks-referenz.md`](../docs/user/claude-hooks-referenz.md) §InstructionsLoaded,
  `grep -c 'claude/rules/\*\.md' docs/user/claude-hooks-referenz.md` → **2**): geladen wird
  **beim Sitzungsstart** (`load_reason: session_start`), träge nur bei `paths:`-Frontmatter oder
  verschachtelter `CLAUDE.md`. Die vier tragen kein Frontmatter — ein Symlink hat keinen eigenen
  Text —, also gilt für sie der Sitzungsstart-Fall.
- **Setzung 2 — die Menge ist geschlossen, und ihre Quelle ist das Verzeichnis.** Welche Module im
  Auto-Kontext liegen, sagt `ls .claude/rules/` und sonst nichts; eine zweite Aufzählung stünde
  neben der ersten und alterte. Geschlossen heißt: **ein Eintrag mehr oder weniger ist ein neuer
  Eintrag dieses Blocks**, keine Variante dieses einen — geschrieben von der Rolle, die den Block
  schreibt ([`AGENTS.md`](../AGENTS.md) §3.8). Ein automatischer Kontext, der ohne Registereintrag
  wächst, ist genau die stille Norm-Änderung, gegen die dieser Block existiert. **Das ist eine
  Form-Setzung über das Register, kein Verbot des Verzeichnisses.**
- **Setzung 3 — Präsenz ist keine Durchsetzung.** Ein Modul im Auto-Kontext liegt im Quadranten
  *inferential feedforward* (Baseline `v5.12.0`,
  [`grundlagen-durchsetzungsschicht.md`](../.harness/baseline/v5.12.0/regelwerk/grundlagen-durchsetzungsschicht.md)
  §Die Lücke: aspirativ vs. bindend — *„er **informiert**. Ein driftender oder vergesslicher Agent
  kann ihn ignorieren"*). Es erzwingt nichts, färbt nichts rot und ersetzt keinen Sensor. Wer eine
  Regel dort ablegt, hat sie **gezeigt**, nicht **gebunden**; die zwei fail-closed Bindepunkte
  dieses Repos bleiben der PreToolUse-Guard und der Stop-Hook.
- **Setzung 4 — die On-demand-Pflicht bleibt, und Codex ist unberührt.** Für jedes Modul außerhalb
  von `.claude/rules/` gilt der Lesepfad aus [`AGENTS.md`](../AGENTS.md) §1 unverändert: Index
  plus relevantes Modul, nicht der Baum. Der Codex-Pfad ändert sich gar nicht — `.codex/hooks.json`
  führt allein den SessionStart-Injektor mit dem Index, und `.claude/` liest Codex nicht. Die
  beiden Agenten stehen damit wieder unterschiedlich, wie schon zwischen
  [`MR-004`](#mr-004--sessionstart-regelwerk-injektor) und
  [`MR-006`](#mr-006--regelwerk-cache-als-split-modul-verzeichnis) — nur mit vertauschten Rollen.
- **Setzung 5 — die Symlink-Form schließt die bedingte Ladung aus, und das ist der bezahlte
  Preis.** Ein Symlink kann nicht driften, weil er keinen eigenen Text hat; genau deshalb kann er
  auch kein `paths:`-Frontmatter tragen, mit dem die Werkzeug-Doku (§InstructionsLoaded,
  `load_reason: path_glob_match`) eine Regel-Datei nur bei passendem Dateizugriff lädt. Die
  Alternative — kopieren und Frontmatter setzen — erzeugt einen zweiten Wortlaut derselben Module,
  der beim nächsten Tag-Wechsel still veraltet. Gewählt ist Drift-Freiheit gegen unbedingtes
  Laden. **Ein dritter Weg ist denkbar und hier nicht gemessen:** die Doku führt
  `load_reason: include` mit einem `parent_file_path`, also eingebundene Anweisungsdateien; ob eine
  Regel-Datei mit Frontmatter den vendored Baum einbinden kann, ist an diesem Repo nicht erprobt
  und wird hier nicht behauptet.
- **Begründung.** Die vier sind die Prozess-Module — Entwicklungszyklus, Planning Harness, Roadmap
  Engineering, Agentenrollen (`for f in .claude/rules/*.md; do head -1 "$f"; done`) —, also der
  Teil des Regelwerks, den Slice-Lifecycle, Wellen-Prozedur und Rollen-Übergaben in **jedem** Lauf
  berühren, nicht nur bei einer Einzelentscheidung. Das Review-Modul fehlt darin und soll fehlen:
  dessen Urteil führt nach Modul 8 §Welche Rolle braucht welche Artefaktklasse eine Skill-Datei,
  und die liegt hier (`ls .harness/skills/`). Für den Gewinn gibt es einen Namen im Block selbst:
  [`MR-006`](#mr-006--regelwerk-cache-als-split-modul-verzeichnis) §Tradeoff hat das Index-only-
  Injizieren als **Schwächung der Presence-Garantie** ausgewiesen (*„was nicht im Kontext ist,
  existiert nicht"*) und den Preis bewusst gezahlt. Diese Ablage holt die Garantie für eine
  benannte Teilmenge zurück, auf der Claude-Achse, gegen einen Kontext-Aufschlag, den Setzung 1
  beziffert.
- **Grenze — was der Zustand an zwei Mess-Pfaden bewegt, und was nicht.** (1) Die vier Pfade
  fallen in den Geltungsbereichs-Pathspec von
  [`MR-025`](#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert), der
  `.harness/baseline/**` ausdrücklich ausnimmt:
  `git ls-files '*.md' ':!docs/reviews/**' ':!docs/plan/planning/done/**' ':!.harness/baseline/**' | grep -c '^\.claude/rules/'`
  → **4**. **Zählende** Messungen über diesen Pathspec verschieben sich dadurch um vier;
  **inhaltliche** nicht: `git grep` liest den Blob, und der Blob eines Symlinks ist der Zielpfad —
  `grep -c 'Baseline' .claude/rules/modul-01-entwicklungszyklus.md` → **1** (das Dateisystem folgt),
  `git grep -c 'Baseline' -- '.claude/rules/modul-01-entwicklungszyklus.md'` → leer, Exit **1**
  (git folgt nicht). Jener Eintrag wird deshalb **nicht** angefasst; der Block ist append-only, und
  seine Ausnahme hat durch diese Pfade keinen Gegenstand verloren. (2) Das Doku-Gate prüft die vier
  nicht: `make docs-check` meldet `475 Datei(en) geprüft, 0 Befund(e)`, und die Differenz ist
  aufgelöst — der Kandidatenbestand nach den Regeln aus `.d-check.yml` §`scan.ignore` ist **479**
  (`find . -path ./.git -prune -o -name '*.md' -print | grep -v '^\./\.harness/baseline/' | grep -v '\.template\.md$' | grep -v '^\./\.tmp/' | grep -v '^\./docs/user/claude-hooks-referenz\.md$' | grep -v '^\./docs/plan/adr/0013-technik-stratum-als-zielort\.md$' | wc -l`),
  davon **475** ohne die vier Symlinks (dieselbe Pipeline, abschließend
  `grep -vc '^\./\.claude/rules/'`). **Keine Erwartungswerte** — beide wandern mit dem Baum. Die
  Ausnahme der Baseline vom Doku-Gate hält damit über beide Pfade, und das ist gewollt: geprüft
  wird, was dieses Repo schreibt.
- **Kein Wächter, und der Kandidat ist benannt, nicht gebaut.** Kein Modul aus `modules:` der
  `.d-check.yml` liest eine Ladeform — `links` prüft Link-Ziele, `ids` drei Kennungs-Muster —, und
  `make comment-claims` hat keine Markdown-Datei in seinem Prüfbereich. Ein **beobachtender**
  Kandidat existiert im Werkzeug: der Hook `InstructionsLoaded` feuert je geladener Datei mit
  `file_path` und `load_reason`
  ([`docs/user/claude-hooks-referenz.md`](../docs/user/claude-hooks-referenz.md) §InstructionsLoaded).
  Er ist **kein** Gate — dieselbe Quelle sagt *„Der Hook unterstützt keine Blockierung oder
  Entscheidungskontrolle"* —, er hängt wie der PreToolUse-Guard an **einem** Agenten
  ([`AGENTS.md`](../AGENTS.md) §3.9 §Grenze des Feedback-Quadranten), und er ist hier nicht
  verdrahtet (`grep -c InstructionsLoaded .claude/settings.json` → **0**, Exit 1). Träger dieser
  Setzungen ist der Rollen-Wechsel vor der Änderung.
- **Kein ADR nötig ([`AGENTS.md`](../AGENTS.md) §3.5).** §3.5 bindet **Senkungen**. Hier sinkt
  keine Schwelle: kein Gate-Modul wird deaktiviert, kein Prüfbereich gekürzt, keine Strenge
  gelockert — es kommt Kontext hinzu, der nichts erzwingt (Setzung 3). Und keine Accepted-ADR
  entscheidet die Ladeform des Regelwerks **in diesem** Repo: `grep -n 'on-demand' docs/plan/adr/*.md`
  ist leer (Exit 1), `grep -n 'claude/rules' docs/plan/adr/*.md` ebenso; die ADRs, die das
  Regelwerk nennen, entscheiden über das **emittierte** Ziel-Repo
  ([`ADR-0005`](../docs/plan/adr/0005-ziel-repo-distribution.md)) oder über Registerformen.
- **Was hier nicht entschieden ist.** Das Modul-0-Prinzip kennt zwei Zustände — *verkörpert* und
  *nachgeschlagen*. Ein Modul im Auto-Kontext ist keiner von beiden: die Quelle wird unbedingt
  geladen, ohne dass ihr per-Lauf-relevanter Gehalt in Hard Rule, Gate, Skill oder `MR` überführt
  wäre. Ob die Antwort des Prinzips hier **Verkörperung** wäre und das Verzeichnis danach
  entfiele, ist offen; sie zu geben verlangt, für jedes der vier Module zu bestimmen, welcher
  Gehalt per-Lauf-relevant ist und wo er hingehört. Das ist Arbeit für einen geschnittenen Slice
  und danach für eine ADR, nicht für diesen Eintrag. Bis dahin steht der Zustand hier
  **deklariert**, und Setzung 2 hält ihn davon ab, still zu wachsen.
- **Auflösungs-Trigger:** Die Setzungen 2 bis 4 sind permanent — sie hängen an keinem Tag und an
  keinem Pin. **Setzung 1 wandert** mit dem Verzeichnis und mit `BASELINE_TAG`: die Symlink-Ziele
  tragen den Tag im Pfad, ein Re-Baseline bricht sie, und `make baseline-verify` sieht das nicht
  (es prüft den Baum, nicht wer auf ihn zeigt). Ein Tag-Bump zieht die vier Symlinks nach oder
  entfernt sie; welches von beidem, ist ein neuer Eintrag nach Setzung 2. **Setzung 5** fällt neu
  an, sobald eine bedingte Ladung ohne zweiten Wortlaut möglich ist.

### MR-036 — Die Change-Request-Regel bei Personalunion steht jetzt in der adoptierten Baseline

- **Datum:** 2026-08-31
- **Wirksamkeits-Anlass:** slice-082 — Adaptions-Durchgang von welle-10, Achse 1.
- **Geltungsbereich:** [`MR-015`](#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
  Setzungen 1–3, der zitierte "adoptierte Wortlaut" und die Begründung. **Nicht** der
  Cutoff-Absatz — er bindet fort, siehe die Kopf-Marke an MR-015.
- **Löst auf:** die Adaption selbst. Die adoptierte Baseline `v5.12.0` regelt den Fall
  "Auftraggeber- und Entwickler-Rolle fallen zusammen" jetzt an derselben Stelle, aus der
  MR-015 seinen Wortlaut zitierte.
- **Ausgelöst durch Baseline-Stand:** `v5.12.0`.
- **Ersetzt-Baseline-Regel:**
  [`grundlagen-source-precedence.md`](../.harness/baseline/v5.12.0/regelwerk/grundlagen-source-precedence.md)
  — der Absatz **„Fallen Auftraggeber- und Entwickler-Rolle zusammen"**: *„fehlt nicht der
  Vorgang, sondern nur seine Ticket-Form: Die Rolle ist besetzt, und der annehmende Akt ist die
  Entscheidung, die vor der Umsetzung fällt. Was die Regel trägt, ist nicht die Externalität,
  sondern die Trennung von Entscheidung und Umsetzung — und die ist auch ohne Ticket
  herstellbar. Der Träger ist dann der Commit: Ein angenommener Change Request ändert in einem
  eigenen Commit ausschließlich das Lastenheft und liegt vor dem Slice, der ihn umsetzt."*
- **Gemessen, nicht vermutet.** Der v3.5.2-Wortlaut, den MR-015 als "adoptierten Wortlaut"
  zitiert, steht am Zielstand unverändert
  (`grep -c 'bewusst kein Harness-Konstrukt' .harness/baseline/v5.12.0/regelwerk/grundlagen-source-precedence.md`
  → **1**) — die Basisregel selbst war also nie der Adaptions-Gegenstand von MR-015. Gegenstand
  war die **Lücke**, die die Baseline für Personalunion offen ließ, und MR-015 füllte sie
  selbst. Diese Lücke ist jetzt geschlossen — Satz für Satz deckungsgleich mit MR-015s drei
  Setzungen: *„Die Rolle ist besetzt … der annehmende Akt ist die Entscheidung, die vor der
  Umsetzung fällt"* deckt Setzung 1; *„Der Träger ist dann der Commit: … ausschließlich das
  Lastenheft … vor dem Slice"* deckt Setzung 2 wörtlich; die neue Draft/In-Review/Accepted-
  Schwelle für den CR-Beginn ergänzt, ohne MR-015 zu widersprechen. MR-015 selbst benannte die
  Lücke, die jetzt schließt: *„Dieses Repo hat keinen externen Auftraggeber … nur die
  Ticket-Form fehlt."*
- **Ausgang: gegenstandslos → Rückbau, als Teil-Ablösung.** Der Cutoff-Absatz wird an zwei
  Stellen dieses Repos als Präzedenz zitiert
  ([`AGENTS.md`](../AGENTS.md) §3.7 und
  [`MR-025`](#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert): *„dieselbe
  Begründung trägt den Cutoff in MR-015"*) und bindet damit fort
  ([ADR-0014](../docs/plan/adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md) Festlegung 2 (a):
  *„bei Teil-Aufhebung bleibt der Rumpf, weil sein Rest bindet"*). MR-015 behält deshalb seinen
  vollständigen Rumpf und bekommt nur die Kopf-Marke
  ([`MR-032`](#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)) —
  keine Entfernung, kein zweiter Commit.
- **Achse 2 — eigener Bedarf.** MR-015 Setzung 3 (Verweis-Spalte nennt die annehmende Instanz
  statt eines Tickets) trägt einen eigenen Auflösungs-Trigger — *„fällt, sobald ein externer
  Auftraggeber existiert"*. Der ist unverändert nicht eingetreten und bleibt an MR-015
  gebunden, nicht an diesem Eintrag.
- **Auflösungs-Trigger:** permanent als Sachstands-Feststellung — eine eingeholte Adaption wird
  nicht ein zweites Mal eingeholt. Neu zu entscheiden ist der Gegenstand erst, wenn ein
  künftiger Baseline-Stand diesen Absatz erneut ändert; dann gegen den dann geltenden Tag zu
  messen und als neuer Eintrag zu führen.

### MR-037 — Wellenlose Arbeit ist jetzt Baseline-Default, ihr Auslöser-Test ist neu gefasst

- **Datum:** 2026-08-31
- **Wirksamkeits-Anlass:** slice-082 — Adaptions-Durchgang von welle-10, Achse 1.
- **Geltungsbereich:** [`MR-016`](#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
  vollständig (Setzungen 1–3, Ist-Messung, Durchsetzung-Beobachtung).
- **Löst auf:** MR-016 vollständig. Die adoptierte Baseline `v5.12.0` regelt "Welle oder nicht"
  und "wo wellenlose Arbeit steht" jetzt selbst, mit einem engeren Kriterium an genau der
  Stelle, an der MR-016 zu weit ging.
- **Ausgelöst durch Baseline-Stand:** `v5.12.0`.
- **Ersetzt-Baseline-Regel:**
  [`modul-06-roadmap.md`](../.harness/baseline/v5.12.0/regelwerk/modul-06-roadmap.md)
  §Wann Arbeit eine Welle braucht und §Wellenlos heißt nicht wächterlos.
- **Was jetzt Baseline-Default ist (gegenstandslos).** MR-016 Setzung 2/3 — wellenlose Arbeit
  erscheint nicht in der Roadmap, ein geschlossener wellenloser Slice hinterlässt dort keine
  Spur, sein Zustand ist die Verzeichnis-Position — steht wörtlich in der neuen Fassung:
  *„Wellenlose Arbeit erscheint nicht in der Roadmap — weder beim Start noch beim Abschluss.
  Ihr Zustand ist die Verzeichnis-Position … Ein Eintrag daneben wäre eine zweite Quelle für
  denselben Zustand, und die altert"* und *„Die Belege eines geschlossenen wellenlosen Slice
  stehen in seiner Datei und in git; das Closure-Log der Roadmap ist für Wellen."* Was MR-016
  als eigene Repo-Adaption begründen musste, begründet die Baseline jetzt selbst.
- **Was widersprach, und was übernommen wird (widerspricht → übernehmen).** MR-016 Setzung 1,
  dritte Frage, entschied: *„Auslöser reaktiv oder gewollt? … 'Wir wollen eine neue Fähigkeit'
  → gewollt, Welle — auch wenn es zunächst nach einem Slice aussieht."* Die neue Fassung
  widerspricht dem ausdrücklich: *„Wellenlose Arbeit … typisch für Reaktives … aber nicht
  darauf beschränkt: auch eine neue Fähigkeit kann ein einzelner Slice sein."* Das eigene
  Register dieses Repos stützt die Baseline gegen die eigene alte Regel: Die drei von MR-016
  selbst genannten Gegenbeispiele (slice-027, slice-039, slice-048) waren *„fast immer
  nachgeschnitten"* — sie wurden erst zu Wellen, als sich ein Bündel zeigte, nicht weil
  "gewollt" allein schon eine Welle verlangte. Statt die widerlegte Regel zu verteidigen,
  übernimmt dieser Eintrag das engere Baseline-Kriterium: *„Eine Welle liegt vor, wenn es eine
  beobachtbare Closure-Bedingung gibt, die mehr beobachtet, als die DoDs ihrer Slices schon
  belegen."* Bündel und ein eigenes Closure-Kriterium bleiben die tragenden Fragen (MR-016
  Frage 1/2 decken sich mit der neuen Fassung); die dritte Frage (reaktiv/gewollt) entfällt als
  eigenständiges Kriterium.
- **Was nicht anderswo steht, und wo es jetzt lebt.** Die "Durchsetzung"-Beobachtung aus
  MR-016 (d-checks Modul `planning` liegt im Bild, ist aber an keinen Trigger gehängt) ist
  **ersatzlos** im Sinn von
  [ADR-0014](../docs/plan/adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md) Festlegung 2 (b) —
  nicht weil sie falsch wäre, sondern weil sie seit dem 2026-08-28-Eintrag der
  Roadmap-Drift-Tabelle (welle-13-Kandidat *„Regeln ohne Feedback-Quadrant schließen"*) an
  einem aktuelleren, genaueren Ort weitergeführt wird.
- **Ausgang:** gegenstandslos (Setzung 2/3) und widerspricht → übernehmen (Setzung 1, Frage 3)
  führen zusammen zum Rückbau derselben Aussage. Da nichts vom Rumpf mehr eigenständig bindet
  (die einzige verbleibende Aussage ist oben umgezogen), ist dies eine **vollständige
  Aufhebung** ([`MR-020`](#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf)):
  Nummer, Überschrift wörtlich, Datum und die `Aufgehoben durch`-Zeile bleiben, der Rumpf fällt
  in einem eigenen, additionsfreien Commit ([`AGENTS.md`](../AGENTS.md) §3.3,
  [ADR-0014](../docs/plan/adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md) Festlegung 2 (c)).
- **Achse 2 — eigener Bedarf.** MR-016 trug keinen numerischen Auflösungs-Trigger außer
  *„permanent"* mit der Bedingung *„Setzung 2/3 fallen, sobald Modul 6 selbst einen Ort für
  wellenlose Arbeit vorsieht"* — genau das ist eingetreten (siehe oben); der eigene Bedarf ist
  damit durch den Baseline-Bezug erschöpft, kein separater Achse-2-Befund bleibt offen.
- **Auflösungs-Trigger:** permanent als Sachstands-Feststellung.

### MR-038 — Ein retirierender Eintrag nennt den Baseline-Stand, der seinen Trigger feuerte

- **Datum:** 2026-08-31
- **Wirksamkeits-Anlass:** slice-082 — Adaptions-Durchgang von welle-10, Achse 1, Posten
  [`MR-020`](#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf) (§6 des
  Slice-Plans).
- **Geltungsbereich:** [`MR-020`](#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf)
  — nur die **Form** der `Aufgehoben durch`-Zeile bei baseline-getriebenem Rückbau. Die
  Festlegung selbst (Option C: Kopf bleibt, Rumpf geht bei vollständiger Aufhebung) bleibt
  unverändert und bindet fort.
- **Ersetzt-Baseline-Regel:**
  [`modul-02-harness-bootstrap.md`](../.harness/baseline/v5.12.0/regelwerk/modul-02-harness-bootstrap.md)
  §Freshness-Audit der vendored Baseline: *„Rückbau ist ein neuer Eintrag, kein Edit — eine
  aufgelöste `MR-<NNN>` wird nicht überschrieben, sondern bekommt einen Nachfolger, der sie
  auflöst und den Baseline-Stand nennt, der den Trigger gefeuert hat. Die alte Zeile ist die
  historisch korrekte Aussage über den damaligen Zustand."*
- **Ausgelöst durch Baseline-Stand:** `v5.12.0`.
- **Der Auflösungs-Trigger von
  [ADR-0014](../docs/plan/adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md) ist eingetreten,
  und die Entscheidung ist neu begründet, nicht umgestoßen.** Die ADR benennt den Fall selbst:
  *„Wenn die Baseline die Disziplin-Regel aus dem Vorlagen-Kommentar in ein Prosa-Modul hebt …
  dann bindet sie unabhängig von ihrer Rezeption hier, und die Abweichung ist gegen den neuen
  Wortlaut neu zu begründen."* Genau das ist geschehen: die Disziplin-Regel des
  v3.5.2-Vorlagen-Kommentars (*„keine nachträglichen inhaltlichen Änderungen … nur neue
  Einträge oder explizite Aufhebungen"*, existiert am Zielstand nicht mehr als Kommentar
  — `grep -n 'nur neue Eintr\|explizite Aufhebung\|append-only' .harness/baseline/v5.12.0/templates/harness/conventions.template.md`
  ist leer) lebt jetzt als Prosa in
  [`grundlagen-harness-dateien.md`](../.harness/baseline/v5.12.0/regelwerk/grundlagen-harness-dateien.md#harnessconventionsmd-als-konventionsspeicher)
  (*„Einträge werden nie überschrieben"*) und in modul-02 (Zitat oben, siehe auch
  [`MR-029`](#mr-029--der-scanignore-zensus-wandert-und-sein-dritter-grund-ist-keine-scoping-aussage)).
- **Geprüft: widerspricht Option C (Kopf bleibt, Rumpf geht) dem neuen Wortlaut?** Nein.
  *„Nicht überschrieben"* und *„kein Edit"* richten sich gegen das **Verändern** einer
  bestehenden Aussage; Option C verändert nichts — sie entfernt den Rumpf per **eigenem,
  additionsfreien Commit**
  ([ADR-0014](../docs/plan/adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md) Festlegung 2 (c))
  und lässt Nummer, Überschrift wörtlich und `Datum` stehen: genau das, was *„ein Nachfolger,
  der sie auflöst"* voraussetzt — einen stabilen Anker, auf den er zeigt. *„Die alte Zeile ist
  die historisch korrekte Aussage über den damaligen Zustand"* begründet, den Wortlaut nicht zu
  **verändern** — sie sagt nicht, ihn ewig sichtbar zu halten. MR-020s eigene Begründung trifft
  denselben Punkt bereits: *„Nicht in `git` steht, was der Kopf hält … Was die
  append-only-Führung dagegen leisten soll — Nachvollziehbarkeit — leistet `git` vollständig
  und besser."* Der Rückschluss auf *„widerspricht"* trägt darum nicht; die Adaption bleibt
  gültig, keine Folge-ADR, keine Rückführung `in-progress → open`.
- **Was neu ist, und was der Nachfolger ergänzt.** Die neue Fassung verlangt zusätzlich: der
  Nachfolger *„nennt den Baseline-Stand, der den Trigger gefeuert hat"* — ein Element, das
  MR-020s eigener Regel-Text bisher nicht ausdrücklich forderte (seine `Aufgehoben
  durch`-Beispiele im Bestand betreffen bislang ausschließlich repo-interne Umbauten, keinen
  Baseline-Sprung — deshalb blieb die Lücke bisher unbemerkt). **Setzung:** Wo eine Aufhebung
  baseline-getrieben ist — dieser Durchgang produziert genau solche —, trägt die `Aufgehoben
  durch`-Zeile zusätzlich den Tag (Feld `Ausgelöst durch Baseline-Stand`, wie bei
  [`MR-030`](#mr-030--der-rollen-name-der-baseline-und-der-bezeichner-fallen-zusammen) bereits
  gelebt). Wo eine Aufhebung repo-intern getrieben ist (kein Baseline-Sprung als Ursache),
  bleibt das Feld aus — es gäbe nichts zu nennen.
- **Ausgang:** teilweise überholt → engere Nachfolgerin. MR-020 bekommt eine Kopf-Marke
  ([`MR-032`](#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)); der
  Rumpf bleibt vollständig stehen (Teil-Ablösung, kein Widerspruch zu ADR-0014).
- **Achse 2 — eigener Bedarf.** MR-020s eigener Auflösungs-Trigger — *„an ADR-0014 gebunden —
  fällt ihre Annahme … fällt diese Adaption mit ihr"* — ist nicht eingetreten: ADR-0014 bleibt
  Accepted; ihr dritter Re-Evaluierungs-Trigger hat eine Neubegründung verlangt, keine
  Aufhebung, und die steht hiermit.
- **Auflösungs-Trigger:** permanent als Sachstands-Feststellung — eine neu begründete Adaption
  wird nicht ein zweites Mal neu begründet. Fällig erst, wenn ein künftiger Baseline-Stand die
  Freshness-Audit-Eigenschaft erneut ändert.

## Modus-Deklaration pro Sub-Area

| Sub-Area | Modus | Begründung | Graduation |
|---|---|---|---|
| `*` (gesamtes Repo) | Greenfield | Neues Repo, Doc führt, Code folgt | n/a (GF) |
| `harness/tools/` | Greenfield | adoptierte Harness-Mechanik (Adaptions-Block) | n/a (GF) |
| `.codex/` | Greenfield | neue Pfad-Familie, adoptierte SessionStart-Hook-Mechanik | n/a (GF) |

**Wer der „Auswerter (slice-060)" aus [`ADR-0011`](../docs/plan/adr/0011-telemetrie-erfassung-policy.md) ist.**
Die ADR ist ab *Accepted* immutabel und nennt an drei Stellen die Slice-**ID** 060 als den
Auswertungs-Slice (Festlegung 1 Punkt 3 sowie die Re-Evaluierungs-Trigger 2 und 6). Der Schnitt
vom 2026-07-29 hat die Arbeit geteilt: **slice-060 ist die Rollen-Achse** (Erfassung),
**slice-066 ist die Auswertung**. Gemeint ist an allen drei Stellen der **auswertende** Slice,
also slice-066. Diese Umdeutung steht hier und nur hier — die ADR wird dafür nicht angefasst
([`AGENTS.md`](../AGENTS.md) §3.4).
