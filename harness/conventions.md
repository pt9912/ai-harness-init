# Harness-Konventionen

## Purpose

Repo-lokale Strukturregeln gegenüber der adoptierten Baseline. Bei
Konflikt mit einer kanonischen Quelle gilt diese (Source Precedence).

## Baseline

- **Konvention:** AI-Harness-Kurs
- **Regelwerk + Templates:** `v3.5.2` committet vendored
  (`.harness/baseline/v3.5.2/`, [`MR-007`](#mr-007--baseline-committet-vendored-statt-gefetchter-cache)); Regelwerks-Stand laut
  `regelwerk/README.md`: **Kurs-Welle 34 · 2026-07-24**.
- **d-check:** Image v0.51.1 (Digest in d-check.mk, [`MR-010`](#mr-010--d-check-gate-fragment-tool-generiert), [`MR-011`](#mr-011--zitat-verifikation-via-d-check-adoptiert-check-lines), [`MR-012`](#mr-012--d-check-pin-v0511-sources-verfügbar))
- **Datum der Adoption:** 2026-06-13 (Templates-Stand damals: `templates-v4`).
  **Re-Baseline auf `v3.1.0`:** 2026-07-17 (slice-011/012); **auf `v3.5.0`:** 2026-07-19 (slice-019);
  **auf `v3.5.1`:** 2026-07-24 (slice-043); **auf `v3.5.2`:** 2026-07-26 (slice-049,
  Normativ-Delta in [`MR-015`](#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) entschieden).

## Adoptierte Konventions-Quellen

- **Extern (Kurs, kanonisch):** <https://github.com/pt9912/ai-harness-course/tree/v3.5.2/kurs/de>
  — auf den Tag `v3.5.2` gepinnt, **nicht** `main`-floating
  ([`LH-QA-02`](../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit); Erreichbarkeit
  am 2026-07-26 per `curl` belegt — das Release-Asset `lab-regelwerk.zip` gefetcht + sha256-verifiziert). Ersetzt die frühere
  `raw…/main/…/agents-regelwerk.md`-Monolith-URL, die **404** liefert (der Monolith
  existiert upstream seit v2.0.0 nicht mehr — die Module leben unter `/kurs/de/`).
- **In-Repo (verkörperte Form):** die committet vendored Baseline
  `.harness/baseline/v3.5.2/{regelwerk,templates}/` ([`MR-007`](#mr-007--baseline-committet-vendored-statt-gefetchter-cache)) — die
  präsente, netzlose Sicht auf die kanonische Quelle; bei Konflikt gilt der Kurs.

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
  Re-Pin ist eine `DCHECK_DIGEST`-Zeile; (c) das **volle** Target-Set (elf Targets) lebt
  tool-generiert im Repo, die Recipe-Form pflegt d-check.
- **Setzung 1 — Namens-Adaption `doc-check` → `docs-check`.** Nur das Befund-Gate wird umbenannt:
  Ziel-Form-`Makefile`, Regelwerk `modul-13` und der bestehende Repo-Stand nennen es `docs-check`
  (mit „s"); `--print-mk` erzeugt `doc-check`. Bei jeder Neu-Erzeugung sind es vier kleine,
  dokumentierte Handgriffe: `doc-check`→`docs-check` (Target **und** Hilfetext), `DCHECK_DIGEST`
  pinnen, den adaptierten Kopfkommentar setzen und `doc-help`s Grep auf `docs?-` erweitern (damit
  das umbenannte Haupt-Target gelistet wird). Die advisory-Targets bleiben sonst **verbatim**
  (`doc-`-Präfix).
- **Setzung 2 — nur `docs-check` ist ein *behaupteter* Gate ([`LH-QA-01`](../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).** `d-check.mk`
  bringt zehn advisory/opt-in-Targets mit (`doc-trace`/`doc-complete`/`doc-doctor`/`doc-repair`/
  `doc-immutable`/`doc-commits`/`doc-planning`/`doc-tracked`/`doc-targets`/`doc-help`). Nur
  `docs-check` steht in `make gates`, [`AGENTS.md`](../AGENTS.md) §4 und [`harness/README.md`](README.md)
  §Sensors — die übrigen sind **verfügbar, aber nicht als Gate behauptet**, exakt wie
  `regelwerk-check` (Makefile-Target, nicht in `gates`). Kein halluziniertes Gate: „behauptet" ≠
  „vorhanden".
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
  `doc-check`→`docs-check` re-adaptieren, `DCHECK_DIGEST` neu pinnen. Maintenance-Override
  (Dry-Run) via `DCHECK_DIGEST=…`/`DCHECK_IMAGE=…`, nicht mehr `D_CHECK_IMAGE=…`.

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
- **Geltungsbereich:** `docs/plan/planning/` (Schnitt-Entscheidung je Slice) und
  `docs/plan/planning/in-progress/roadmap.md` §Aktuelle Welle.
- **Warum überhaupt eine Adaption:** Die Baseline sieht wellenlose Slices **ausdrücklich vor** —
  das vendored Template schreibt `**Welle:** <welle-id> oder "ohne Welle" (Wartung/Spike)`. Modul 6
  strukturiert die Roadmap aber **wellen-zentriert** (fünf Abschnitte, alle über Wellen). Für
  wellenlose Arbeit gibt es dort **keinen Ort** — und genau deshalb ist sie in *Aktuelle Welle*
  gelandet, bis der Abschnitt 23 Zeilen lang war und zugleich „Keine aktive Welle" meldete
  (Nutzer-Beobachtung 2026-07-26).
- **Ist-Messung (2026-07-26, Kommando neben der Aussage):**
  `grep -l '^\*\*Welle:\*\* ohne Welle' docs/plan/planning/{done,in-progress,open}/slice-*.md | wc -l`
  → **21 von 56** Slices, durchgehend seit slice-011. Das ist kein Ausnahmefall mehr, sondern ein
  zweiter Modus — und er war **nirgends deklariert** (`grep "ohne Welle" harness/conventions.md`
  war leer).
- **Setzung 1 — der Schnitt-Test: drei Fragen, alle beim Schneiden beantwortbar.** Modul 6
  definiert die Welle als *„Bündel paralleler/serialisierter Slices mit Closure-Kriterien"*. Daraus
  folgt, dass die Frage **nicht** „wie groß" lautet:
  1. **Bündel?** Braucht es **mindestens zwei** Slices, die zusammen landen müssen, damit die
     Aussage stimmt? Nein → ohne Welle.
  2. **Gemeinsames Closure-Kriterium?** Gibt es eine beobachtbare Bedingung, die **erst wahr wird,
     wenn alle fertig sind**, und die sich von den einzelnen DoDs unterscheidet? Nein → ohne Welle.
     Eine Welle um einen einzelnen Slice hätte einen Closure-Trigger, der dessen DoD nur abschreibt.
  3. **Auslöser reaktiv oder gewollt?** Sensor hat gefeuert, Nutzer hat gemeldet, Pin ist veraltet
     → **reaktiv**, ohne Welle. „Wir wollen eine neue Fähigkeit" → **gewollt**, Welle — auch wenn es
     zunächst nach einem Slice aussieht.
- **Frage 3 ist die, die gefehlt hat — mit Belegen.** Drei der 21 wellenlosen Slices waren keine
  Wartung, sondern Fähigkeits-Sprünge: [slice-027](../docs/plan/planning/done/slice-027-ci.md) (CI überhaupt erst aufbauen),
  [slice-039](../docs/plan/planning/done/slice-039-cpp-zweite-sprache.md) (zweite Zielsprache),
  [slice-048](../docs/plan/planning/done/slice-048-release-artefakte.md) (Release-Pipeline mit Plattform-Matrix). Sie werden **nicht** rückwirkend
  umgeschrieben — sie sind der Beleg, dass die Grenze nötig ist. Empirischer Zusatz: Fähigkeits-Arbeit
  wird hier fast immer nachgeschnitten (slice-001 → 001a/001b, slice-022 → 022a/022b); was re-sliced
  wird, war ein Bündel.
- **Setzung 2 — wellenlose Arbeit wird in der Roadmap NICHT geführt.** Ihr Zustand **ist** das
  Verzeichnis (Modul 5; [`docs/plan/planning/README.md`](../docs/plan/planning/README.md) sagt es wörtlich: „Slices tragen ihren
  Status über das **Verzeichnis**"). `ls docs/plan/planning/in-progress/` beantwortet „was läuft
  gerade" autoritativ und ohne Pflegeaufwand. Eine Abschrift in der Roadmap wäre eine **zweite
  Quelle** — und sie ist real gealtert (Drift-Log 2026-07-25: slice-047 stand dort als
  `in-progress`, obwohl geschlossen). *Aktuelle Welle* trägt daher die Welle und sonst nichts.
- **Setzung 3 — ein geschlossener wellenloser Slice hinterlässt in der Roadmap keine Spur.** Seine
  Belege stehen in `done/<slice>.md` §7 und in git; das Closure-Log der Roadmap ist für **Wellen**
  (Modul 6: Zeiger auf die `welle-NN-results.md`, keine Beleg-Prosa). Das war bis `80eec58` die
  gelebte Praxis — sie wurde am 2026-07-26 versehentlich aufgegeben und ist damit wiederhergestellt.
- **Durchsetzung — benannt, und diesmal muss nichts gebaut werden.** d-checks Modul **`planning`**
  prüft genau die Konsistenz *Roadmap ↔ `in-progress/`*. Es ist im gepinnten Image vorhanden, als
  `doc-planning` in [`d-check.mk`](../d-check.mk) erzeugt und **an keinen Trigger gehängt** —
  Achse (4) des Roadmap-Kandidaten *Regeln ohne Feedback-Quadrant schließen*. Bis es verdrahtet ist,
  lebt diese Setzung im **inferential-feedforward**-Quadranten. Setzung 1 (der Schnitt-Test) ist
  eine Urteilsregel und bleibt dort ohnehin.
- **Auflösungs-Trigger:** permanent. Setzung 2/3 fallen, sobald Modul 6 selbst einen Ort für
  wellenlose Arbeit vorsieht; Setzung 1 ist neu zu prüfen, wenn der Anteil wellenloser Slices
  wieder sinkt oder ein Fall auftritt, den die drei Fragen nicht entscheiden.

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
- **Geltungsbereich:** die Spans, die `cmd/span-emit` je Tool-Call in den
  gitignorierten Zustands-Bereich schreibt (Logik in `internal/span/`). Umsetzung von
  [`ADR-0011`](../docs/plan/adr/0011-telemetrie-erfassung-policy.md) Folgepflicht 1: die
  **Feldtabelle** gehört hierher und nicht in die ab *Accepted* immutable ADR — sie wächst mit
  jedem Feld, das seine Incident-Frage nachweist.
- **Das Schema ist GESCHLOSSEN.** Erfasst wird, was hier steht; jedes andere Feld einer künftigen
  Payload wird **nicht** still mitgeschrieben. Wer eines aufnimmt, trägt es hier ein — mit seiner
  Incident-Frage, sonst gar nicht (*„Ein Attribut ohne Incident-Frage fliegt raus"*, Modul 15).

| Feld | Pflicht | Incident-Frage |
|---|---|---|
| `seq` | Pflicht | *Fehlt ein Span?* — je Strom monoton steigend, damit der **Leser** eine Lücke sieht |
| `ts` | Pflicht | *Wann geschah es?* |
| `event` | Pflicht | *Erfolg oder Fehlschlag?* (Nach- bzw. Fehlschlag-Ereignis) |
| `tool` | Pflicht | *Welches Werkzeug lief?* |
| `tool_use_id` | Pflicht | *Welche Ereignisse gehören zu einem Aufruf?* |
| `session`, `agent` | Pflicht | *Welcher Lauf war es?* — zusammen bilden sie den **Strom** |
| `agent_type` | Pflicht | *Welche Art Lauf?* — der **Subagent-Typ** der Payload, roh. **Pflicht wie `agent`**: die vier Felder `session`/`agent`/`agent_type`/`agent_role` sind ein Block, und leer ist dort eine Aussage (Haupt-Kontext), kein fehlender Wert |
| `agent_role` | Pflicht | *Welche Rolle verursachte den Zugriff?* — das Modul-15-Pflichtfeld. Gefüllt, wenn `agent_type` eine Harness-Rolle **nennt** (`planner`, `architect`, `implementer`, `reviewer`, `verifier`, `validator`). **Leer heißt UNBEKANNT, nie „rollenlos“** — s. die Lesevorschrift unten |
| `slice` | Pflicht | *Auf wessen Rechnung lief der Zugriff?* — aus dem Lifecycle-Verzeichnis, Liste (kein Slice ⇒ leer und als leer erkennbar) |
| `requirement` | Pflicht | *Gegen welche Anforderung?* — aus der `Bezug:`-Zeile der Slices, Liste |
| `adr` | Pflicht | *Auf wessen Entscheidung lief der Zugriff?* — die dritte Korrelations-Achse aus Modul 15 §Kernidee, aus demselben `Bezug:`-Block wie `requirement`, Liste |
| `branch`, `commit` | Pflicht | *Zu welcher Änderung gehört der Zugriff?* — die dritte Korrelations-Achse aus Modul 15 (*Slice/**PR**/Agent-Rolle*), abgeleitet aus `.git/HEAD`; die PR-Nummer selbst ist nicht erreichbar, s. Abweichung 2 |
| `status` | Pflicht | *Ging es gut?* |
| `permission_mode` | Optional | *Unter welcher Berechtigungs-Lage?* |
| `path` | Optional | *Was wurde wohin geschrieben/gelesen?* — nur bei namentlich gelisteten Datei-Werkzeugen |
| `bytes`, `sha256_16` | Optional | *Hat sich etwas geändert?* — aus dem **Dateisystem**, nie aus der Payload |
| `duration_ms` | Optional | *Wie lange dauerte der Aufruf?* — aus der Payload übernommen. Ohne sie ist **Gleichzeitigkeit nicht entscheidbar**: ein Span trägt sonst nur seinen Abschluss, und zwei Ströme lassen sich nicht überlagern |
| `result_bytes` | Optional | *Wie groß war das Ergebnis?* — **nur die Länge, nie der Inhalt**; gemessen wird die **JSON-Kodierung**, wie die Payload sie trägt (samt Anführungszeichen und Escapes), nicht die Zeichenzahl des Ergebnisses. Ohne sie ist nicht entscheidbar, ob ein **einzelner** Aufruf eine Ressourcenspitze erklärt |
| `program`, `argc` | Optional | *Welches Programm lief?* — erstes Token und Argument-Anzahl, nie die Kommandozeile |
| `spawned_role` | Optional | *Welche Rolle lief im Subagenten — auf wessen Rechnung geht sein Verbrauch?* — aus `tool_response.agentType`, gegen die sechs kanonischen Typnamen normalisiert. **Nie** aus `tool_input.subagent_type`: das ist die *Anforderung*, nicht der *Lauf*, und es liegt auf der Argument-Achse. Eigener Feldname, weil `agent_type`/`agent_role` schon den Typ des **laufenden** Agenten führen. **ABWESEND heißt UNBEKANNT, nie „rollenlos"** — dieselbe *Lesart* wie bei `agent_role`, aber ausdrücklich **nicht** dessen Draht-Form: `agent_role` ist **Pflicht** und steht als `""` in jeder Zeile, `spawned_role` ist `omitempty` und **fehlt** bei leerem Wert. Das ist Absicht und keine Nachlässigkeit — ein `"spawned_role":""` in jedem `Bash`-Span behauptete einen Subagenten, den es nicht gab; die Present-and-empty-Regel gilt für den Vierer-Block, den **jeder** Span trägt, nicht für ein Feld, das nur ein Werkzeug erzeugt. **Unterscheidbar bleibt es am Pflichtfeld `tool`:** ein `Agent`-Span **ohne** `spawned_role` ist ein Lauf mit *unbekannter* Rolle und gehört in den Sammelposten — eine Auswertung, die nach `spawned_role: ""` sucht, findet ihn nicht und darf ihn deshalb nicht aus der Bilanz fallen lassen (Review-Befund MEDIUM-2 vom 2026-07-30; bis dahin berief sich diese Zeile auf die `agent_role`-Vorschrift und sagte damit das Gegenteil dessen, was der Draht tut) |
| `input_tokens`, `output_tokens` | Optional | *Wie teuer war dieser Subagenten-Lauf?* — die Verbrauchs-Achse, ohne die eine Token-Bilanz je Rolle eine Summe statt einer Rechnung ist |
| `cache_creation_input_tokens`, `cache_read_input_tokens` | Optional | *Zahlte der Lauf den Cache oder nutzte er ihn?* — der Cache-Status, der bis 2026-07-29 als nicht erreichbar galt und seit 2026-07-30 für Subagenten-Läufe **erfasst** ist (Abweichung 1 unten, dort auf den Rest-Zustand zurückgeschnitten) |
| `total_tokens` | Optional | *Wie groß war der Lauf insgesamt?* — die Summe, die das **Werkzeug selbst** ausweist. **Ob** sie die Addition der vier Zähler ist, war bis 2026-07-30 **nicht gemessen** (die Ist-Messung erfasste nur Schlüsselnamen und Wertlängen, nie Werte). Am eigenen Bestand nachgerechnet **ist** sie es, exakt, an jedem geprüften Zähler-Span. Eine Auswertung addiert sie deshalb **nicht** zu den vier, sondern gegen sie. **Hier steht bewusst keine Zahl und keine Stichprobengröße mehr:** der Bestand unter `.harness/state/spans/` ist gitignored, maschinenlokal und wächst mit jedem Subagenten-Lauf — die zuvor hier eingefrorene Rechnung über „beide vorliegenden Zähler-Spans" war drei Minuten nach ihrem Commit falsch und für einen anderen Checkout ohnehin nicht nachvollziehbar (Review-Befund R2-LOW-1 vom 2026-07-30). Die Probe gehört **gefahren**, nicht zitiert, und sie bleibt eine Stichprobe |
| `total_duration_ms` | Optional | *Wie lange lief der Subagent wirklich?* — **nicht** `duration_ms`: das misst den Aufruf, wie der Hook ihn sieht (gemessen 4 ms gegen 4.184 ms tatsächlicher Laufzeit) |
| `total_tool_use_count` | Optional | *Wie viele Werkzeug-Aufrufe verursachte der Subagent?* — der Teiler, ohne den „Token je Aufruf" nicht rechenbar ist |
| `model_version` | Optional | *Welches Modell verursachte die Kosten?* — das Modul-15-Label `model.version`, aus `tool_response.resolvedModel`, **strukturell begrenzt** (Länge und geschlossener Zeichensatz). Was die Gestalt eines Bezeichners nicht hat, wird **verworfen, nicht gekürzt** |

- **Welches Werkzeug gibt was preis — die namentliche Liste.** Die Feldtabelle oben sagt
  *„nur bei namentlich gelisteten Werkzeugen"*; hier stehen die Namen. Sie stand zuerst
  ausschließlich im Code, worauf die Feldtabelle dann ins Leere verwies
  ([`ADR-0011`](../docs/plan/adr/0011-telemetrie-erfassung-policy.md) Folgepflicht 1
  verlangt sie **hier**: *„der nächste Leser muss es ohne Code finden"* — Review-Befund
  HIGH-1). Ein Werkzeug aufzunehmen ist eine **Entscheidung** und wird hier eingetragen,
  nicht im Code nachgezogen.

| Werkzeug-Name | erfasst zusätzlich zu Name und Status |
|---|---|
| `Write`, `Edit`, `MultiEdit`, `NotebookEdit` | `path` (aus `file_path`/`notebook_path`) + `bytes` + `sha256_16` **aus dem Dateisystem** |
| `Read` | `path` — **kein** Fingerabdruck (er wäre auf einem gelesenen Pfad ein Bestätigungs-Orakel ohne Incident-Frage) |
| `Bash` | `program` (erstes Token nach übersprungenen `NAME=WERT`-Präfixen) + `argc` |
| `BashOutput` | **nichts** — seine Eingabe ist eine Shell-Kennung, keine Kommandozeile; die Zeile sagte bis 2026-07-29 `program`/`argc` zu, was strukturell nie eintreten konnte (Review Runde 2, LOW-7) |
| `Agent` | `spawned_role` + die vier `usage`-Zähler + `total_tokens` + `total_duration_ms` + `total_tool_use_count` + `model_version` — **neun Werte aus sechs Schlüsseln**, alle aus `tool_response` und alle nach der **Positiv-Liste** (nächster Punkt). **Kein** `path`, `program`, `argc`, `bytes`, `sha256_16`: aus `Agent`s `tool_input` erreicht nichts den Span (dort liegen `subagent_type`, `prompt`, `description`, `run_in_background`; `ToolInput` in `internal/span/span.go` führt weiterhin genau drei Felder) |
| **jedes andere** | **nichts** — der fail-closed Default aus [`ADR-0011`](../docs/plan/adr/0011-telemetrie-erfassung-policy.md) Festlegung 2 |

- **Die Erfassung aus `tool_response` ist eine POSITIV-Liste, und die Form ist tragend.**
  Die Werkzeug-Tabelle regelte bis 2026-07-30 ausschließlich, was aus den **Argumenten**
  erfasst wird; die `Agent`-Zeile ist die erste, die aus dem **Ergebnis** erfasst. Das ist
  eine zweite Fläche mit eigenem Risiko und **nicht** die harmlose: `tool_response` trägt
  vier gemessene Freitext-Felder — `content` (der vollständige Bericht des Subagenten,
  der größte Freitext-Block des ganzen Aufrufs), `prompt`, `description`, `outputFile` —
  und `prompt` ist genau das Feld, das
  [`ADR-0011`](../docs/plan/adr/0011-telemetrie-erfassung-policy.md) Festlegung 2
  namentlich als das benennt, was nie ins Log darf. Es steht in **beiden** Flächen. Daraus
  fünf Festlegungen:
  1. **Erfasst wird ausschließlich, was `responseKeys()` in
     `internal/span/response.go` namentlich nennt** — sechs Schlüssel, **neun** Blatt-Werte
     (die vier `usage`-Zähler einzeln), oben in **sieben** Tabellenzeilen geführt. Wer die
     drei Zahlen verwechselt, zählt Rolle und Modell nicht mit — genau die zwei Werte, an
     denen die Grenzen des Architect-Verdikts hängen. Alles andere fällt heraus, **ohne
     genannt zu werden**: es gibt keinen Zweig, der einen ungelisteten Schlüssel überhaupt
     ansieht. Das ist der konstruktive Ausschluss aus Festlegung 1 Punkt 3 (*„das Schema
     ist GESCHLOSSEN"*), die einzige Regel von Festlegung 1, die **nicht** hierher
     delegiert ist.
  2. **Positiv und nicht negativ.** Vier gemessene Aufrufe zeigten **fünf**
     undokumentierte Schlüssel; die Fläche wächst erkennbar weiter. Eine Negativ-Liste
     altert mit jedem neuen Antwortfeld, eine Positiv-Liste hält auch beim fünften
     Freitext-Feld. Eine frühere Fassung zählte stattdessen vier verbotene Felder auf —
     das ist die Fassung, die altert.
  3. **Der Fehlschlag braucht keine Sonderregel.** Bei einem fehlgeschlagenen
     Agenten-Aufruf fehlt `tool_response` **ganz** (gemessen — nicht leer, sondern nicht
     vorhanden); es existiert also nichts Gelistetes. Es entsteht ein Span mit Name und
     Status, kein halber.
  4. **`model_version` ist der einzige Rohstring** unter den neun Werten — die übrigen acht
     sind Zahlen oder das gegen sechs Namen normalisierte Etikett. Er trägt deshalb eine
     **strukturelle** Schranke: Länge höchstens 64 und ein geschlossener Zeichensatz
     (Buchstaben, Ziffern, `.`, `_`, `-` und die Klammern `[` `]`, die zur
     Bezeichner-Sprache des Herstellers gehören). Was das nicht erfüllt, wird
     **verworfen, nicht gekürzt**: 64 Byte eines Geheimnisses sind auch 64 Byte fremden
     Inhalts, und ein verstümmeltes Präfix ist ein falsches Protokoll, wo „unbekannt" das
     ehrliche ist (dieselbe fail-closed Linie wie `commandProgram`). **Der Zeichensatz ist
     eine Entscheidung unter Unsicherheit, und das gehört gesagt:** die Messung erfasste
     nur Schlüsselnamen und Wertlängen, nie Werte — die Gestalt eines echten
     `resolvedModel` ist **nicht** gemessen. Der Fehlermodus ist ein **fehlendes** Feld,
     nicht ein falsches, und er ist am Bestand ablesbar: trägt kein `Agent`-Span mit
     Zählern ein `model_version`, ist die Schranke zu eng geraten und wird **hier**
     geweitet, nicht im Code aufgeweicht.
  5. **Die Zähler kommen nur im Vordergrund an.** Ein Hintergrund-Lauf liefert weder
     Zähler noch `agentType`, dafür u. a. `agentId`, `isAsync`, `outputFile` und
     `canReadOutputFile` (gemessen); die Erfassung ist insoweit konstruktiv unvollständig.
     Den Vordergrund **herstellen** kann nur etwas, das den Start verweigert: der
     `PreToolUse`-Guard `.claude/hooks/pretooluse-agent-guard.sh`, und er tut es für
     **Rollen**-Typen. Die **Regel** dazu — wie ein Rollen-Lauf zu starten ist — steht als
     **Start-Konvention** im nächsten Punkt; hier steht nur ihre Folge für die Erfassung.
     Was der Guard nicht herstellt, steht als **Abweichung 5** unten — mit der
     Prüfung davor und einem Auflösungs-Trigger. Die Lücke ist damit benannt und nicht
     durch die `Agent`-Zeile überdeckt.

- **Die START-KONVENTION für Rollen-Läufe — zwei Bedingungen, zwei BELEGKLASSEN.** Die
  Erfassung oben setzt einen so gestarteten Lauf voraus; die Regel gehört deshalb hierher
  und nicht in ein Gedächtnis. Wer Rollen-Arbeit an einen Subagenten gibt, startet ihn
  1. **unter seinem Rollen-Typ, per @-Erwähnung** — das entscheidet, **WELCHE** Rolle
     läuft. **Belegklasse: fremde Doku, im Repo NICHT vorliegend.** Die Subagenten-Seite
     der Herstellerseite (`/docs/de/sub-agents`) nennt die @-Erwähnung als den Weg, der die
     Ausführung *garantiert*, während natürliche Sprache die Delegation dem Modell
     überlässt. Die vendored Hooks-Referenz `docs/user/claude-hooks-referenz.md` **verweist**
     in ihrem `Agent`-Eintrag nur auf diese Seite und trägt den Satz nicht. Er steht hier
     als **fremde Zusage**, nicht als Repo-Beleg — wer ihn nachprüfen will, findet im Repo
     nichts, woran.
  2. **im VORDERGRUND** — `run_in_background: false`; das entscheidet, **WIE** er läuft.
     **Belegklasse: gemessen, und zusätzlich repo-lokal dokumentiert.** Gemessen ist, dass
     ein Hintergrund-Lauf keine Verbrauchs-Achse trägt — im Einzelnen in **Abweichung 5**,
     hier nicht wiederholt. Dokumentiert ist dasselbe in
     `docs/user/claude-hooks-referenz.md`: ihr `Agent`-Eintrag führt den Hintergrund als
     **Standard** und sagt, die Antwort eines Hintergrund-Subagenten trage keine
     Nutzungsfelder, sondern `status: "async_launched"`, `agentId`, `description`,
     `prompt`, `outputFile` und `resolvedModel`. Zwei unabhängige Belege für dieselbe
     Bedingung — und der einzige Punkt dieser Konvention, für den das gilt.

  **Die zwei Bedingungen sind UNABHÄNGIG — gemessen, nicht angenommen.** Ein per
  @-Erwähnung angeforderter Lauf **ohne** ausdrücklichen Schalter lief im **Hintergrund**:
  sein Span trug `duration_ms: 3` — der Hook feuert beim **Start** — bei 4.184 ms
  tatsächlicher Laufzeit des Subagenten. Die @-Erwähnung wählt den **Typ**, nicht die
  **Betriebsart**. Wer nur Bedingung 1 einhält, bekommt die Rolle und keine Zahl.

  **Was diese Konvention ERZWINGT und was sie nur behauptet** — beides gehört in denselben
  Punkt, sonst liest sich die Regel breiter als ihr Sensor
  ([`AGENTS.md`](../AGENTS.md) §3.6):
  - **Bedingung 2 ist für Rollen-Typen erzwungen.** Der `PreToolUse`-Guard
    `.claude/hooks/pretooluse-agent-guard.sh` verweigert den Start. **An einem echten
    Aufruf rot gesehen**, nicht nur am Test: ein Rollen-Typ mit `run_in_background: true`
    wurde abgelehnt, der Ablehnungsgrund kam wörtlich als Fehler beim Aufrufer an, der
    Subagent lief nicht — derselbe Typ mit `false` lief unmittelbar davor durch. Ableitung
    der Rollen-Liste, fail-closed-Politik bei fehlendem Schalter, Dauer-Sensoren und
    **Grenzen** stehen in **Abweichung 5**; kurz: er greift nur für Typen mit einer Datei
    in `.claude/agents/`, und er kann fehlen oder abgeschaltet sein.
  - **Bedingung 1 ist NICHT durchsetzbar, und der Grund ist strukturell, nicht
    organisatorisch.** Die Payload hält die **Wahl** nicht fest. Gemessen über vier echte
    Aufrufe — darunter den per @-Erwähnung angeforderten — trägt `tool_input` die Schlüssel
    `subagent_type`, `prompt`, `description` und `run_in_background`; das dokumentierte
    Eingabe-Schema in `docs/user/claude-hooks-referenz.md` nennt darüber hinaus nur
    `model`. **Keiner** davon sagt, *wie* der Typ angefordert wurde: ein per @-Erwähnung
    angeforderter Rollen-Typ und ein sprachlich delegierter kommen am Hook identisch an.
    Ein Guard hat damit nichts, worauf er prüfen könnte — und **darum** prüft **kein
    Sensor dieses Repos** Bedingung 1. Die Abwesenheit folgt aus der Payload, nicht aus
    einer Trefferliste. Hier **benannt**, nicht mitgezählt. Wer die Rolle nicht anfordert,
    bekommt `general-purpose`: nach der Lesevorschrift zu `agent_role` ein ehrliches
    „unbekannt", aber eben keine Rolle, und der Lauf fällt in den Sammelposten samt
    Splitting-Pflicht (Abweichung 3).

  **Abgrenzung, damit keine zweite Wahrheit entsteht:** hier steht **WIE** ein Rollen-Lauf
  startet, wenn einer startet. **DASS** Rollen-Arbeit überhaupt als Rolle läuft, ist eine
  andere Regel — sie trägt slice-068.

- **Was die Payload sonst noch trägt — gemessen, nicht aus der Doku.** Am 2026-07-29
  wurde eine echte Hook-Payload auf ihre **Schlüsselnamen** hin vermessen (nur Namen und
  Wertlängen, nie Werte):
  `cwd · duration_ms · effort · hook_event_name · permission_mode · prompt_id ·
  session_id · tool_input · tool_name · tool_response · tool_use_id · transcript_path`.
  Zwei Lehren daraus, beide unbequem: **`duration_ms` liegt bereit** — die Annahme, dafür
  brauche es einen zweiten Hook auf `PreToolUse`, war falsch. Und das Ergebnis heißt
  **`tool_response`**, nicht `tool_output`; der Slice-Plan hatte den richtigen Namen
  stehen und „korrigierte" ihn anhand der Doku zum falschen. **Die Payload ist die
  Quelle, die Doku ist Herkunft.**
  **Nicht erfasst und damit ausdrücklich abgelehnt:** `cwd` (steht implizit im Pfad),
  `effort` (keine Incident-Frage), `prompt_id` — letzteres ist ein ernsthafter Kandidat
  (*„welche Aufrufe gehören zu einer Nutzer-Anweisung?"*), aber ein neues Feld ist eine
  Entscheidung und keine Gelegenheit.

- **Die erfasste MENGE, ausgesprochen statt suggeriert.** Verdrahtet sind **zwei**
  Ereignisse — `PostToolUse` und `PostToolUseFailure` — je mit leerem Matcher, der
  **jedes** Werkzeug sieht (belegt: live liegen Spans für `Bash`, `Read`, `Write`,
  `Edit`, `Agent`, `ToolSearch`, `Monitor` vor, auch aus Subagenten-Strömen). Erfasst
  wird damit der **abgeschlossene** Aufruf. **Nicht erfasst und nicht behauptet:** ein
  vom PreToolUse-Guard **geblockter** Aufruf hinterlässt keinen Span — die Frage
  *„was wurde versucht und geblockt?"* beantwortet dieses Schema nicht (Verifier-Befund;
  `PermissionDenied` ist als eigenes Ereignis Kandidat, aber keine Zusage).

- **Sechs erklärte Abweichungen vom Modul-15-Pflicht-Minimum** (die ADR verlangt sie zu benennen,
  nicht wegzulassen). Die Zahl ist **gewachsen, nicht korrigiert**: vier standen hier seit
  slice-059, die zwei letzten kamen am 2026-07-31 dazu und benennen, was die Erfassung aus
  `tool_response` **nicht** erreicht:
  1. **Cache-Status ist für Subagenten-Läufe im Vordergrund erfasst — für den Haupt-Kontext
     und für Hintergrund-Läufe bleibt er unerreichbar.** Das ist der Rest-Zustand; die
     Abweichung ist **verkleinert, nicht aufgehoben**, und die Überschrift sagt es jetzt
     (bis 2026-07-30 stand hier *„nicht erfasst — und auch nicht auflösbar"*, während die
     Feldtabelle oben die Cache-Zähler schon führte: derselbe Absatz und dieselbe Tabelle
     sagten Gegenteiliges, Review-Befund MEDIUM-1). **Erfasst** sind
     `cache_creation_input_tokens` und `cache_read_input_tokens` aus dem `usage`-Objekt der
     `tool_response` eines Vordergrund-`Agent`-Aufrufs (gemessen 2026-07-29, erfasst seit
     2026-07-30) — ohne Transkript und ohne Zugriff außerhalb des Repos. Eine Auswertung, die
     die Cache-Hit-Rate aus Modul 15 rechnet, findet für Subagenten-Läufe die **Zähler** vor —
     Erzeugung und Lesung getrennt, wie Modul 15 es fordert (*„Eine einzelne Metrik
     `cache.hit_ratio` reicht nicht"*) — und darf die Größe **nicht** als unerreichbar führen.
     **Vollständig ist die Rechnung damit nicht, und das gehört in denselben Satz:** Modul 15
     verlangt zu den Zählern die Labels `slice.id`, `agent.role` und `model.version`; das
     Rollen-Label liegt nur vor, wenn `spawned_role` gefüllt ist — bei einem
     `general-purpose`-Subagenten fehlt es, und der Lauf gehört in den Sammelposten samt seiner
     Splitting-Pflicht (Abweichung 3 unten). Bis zum 2026-07-30 stand hier *„hat … alles, was
     sie braucht"*; das ging einen Schritt weiter als das Erfasste (Review-Befund R2-INFO-1).
     **Unerreichbar bleibt zweierlei, und das ist die fortbestehende Abweichung:** der
     **Hintergrund-Lauf** und der **Haupt-Kontext**. Beiden fehlt nicht nur der
     Cache-Status, sondern die **ganze** Verbrauchs-Achse; sie stehen deshalb seit dem
     2026-07-31 als **Abweichung 5 und 6** unten — je mit der Prüfung davor und einem
     Auflösungs-Trigger. Hier sind sie nur benannt: derselbe Ausfall zweimal beschrieben
     wäre zwei Stellen, die auseinanderdriften.
     **Warum nicht über das Transkript** — die frühere Quelle: eine frühere Fassung trug den
     `transcript_path` als **Zeiger** und überließ die Auflösung der Auswertung; der Zeiger ist
     am 2026-07-29 auf Entscheidung des Auftraggebers **entfernt** worden, und zwar samt dem
     Lesen des Feldes. Der Grund ist keine Sparsamkeit: das Transkript liegt **außerhalb des
     Repos**, in fremdem Besitz, und trägt den vollen Gesprächsinhalt. Ein Zeiger darauf legt
     eine Auflösung nahe, die niemand genehmigt hat.
     [`ADR-0011`](../docs/plan/adr/0011-telemetrie-erfassung-policy.md) lässt diese Wahl
     ausdrücklich offen (*„ob ein Span, der den `transcript_path` trägt … den Mindestsatz
     erfüllt oder von ihm abweicht, entscheidet der umsetzende Slice"*) — es ist damit eine
     **erklärte Abweichung**, keine Regelverletzung.
  2. **Die PR-NUMMER steht nicht im Span, ihr Anker schon.** Modul 15 verlangt die
     Korrelation zu *Slice/PR/Agent-Rolle*. Eine PR-Nummer lebt bei der Forge; der
     Emitter geht nicht ins Netz und ruft kein `gh` (er läuft je Tool-Call). Erfasst
     werden deshalb `branch` und `commit` — die Größen, über die eine Auswertung den
     PR nachschlägt. Das ist eine Ableitung, keine Erfüllung: liegt kein PR zum
     Branch vor, bleibt die Frage offen. Die Felder sind **Pflicht**: ist die Ableitung
     nicht möglich, stehen sie leer da statt zu fehlen — der Unterschied zwischen
     „unbekannt" und „nicht vorhanden" (Review-Befund HIGH-2). Ein `.git` als Datei (Worktree, Submodul)
     wird nicht aufgelöst; dann sind beide Felder leer und als leer erkennbar.
  3. **`agent_role` ist heute durchweg leer, und das ist der Befund — nicht das Feld.**
     Die Payload liefert `agent_type`; dort steht bei Review- **und** Verify-Läufen
     derselbe Wert (`general-purpose`), die beiden Rollen sind in den Daten also
     ununterscheidbar (gemessen 2026-07-29 über alle Ströme). `agent_role` wird deshalb
     **abgeleitet, nicht geraten**: nennt der Agenten-Typ eine Rolle, ist er die Rolle;
     sonst bleibt das Feld leer. Es ist trotzdem **Pflicht** — dieselbe Begründung wie
     bei `branch`/`commit`: die Lücke gehört in **jeden** Span, nicht nur in diesen
     Absatz, sonst kann ein Auswerter „unbekannt" nicht von „nicht vorhanden"
     unterscheiden. Aufgelöst wird sie durch rollen-benannte Agenten-Typen — eine
     **Prozess**-Entscheidung (slice-060), nach der sich das Feld **ohne** Änderung an
     der Erfassung füllt.
     **Die kanonischen Namen der Agenten-Typen** (Festlegung vom 2026-07-29, slice-060
     Frage A): `planner` · `architect` · `implementer` · `reviewer` · `verifier` ·
     `validator`. Modul 8 nennt die dritte Rolle *Implementation*; als **Bezeichner**
     gilt `implementer` — kurz, gleichförmig mit den übrigen fünf und bereits im Code.
     Die Abweichung ist eine Schreibweise, keine Rollen-Änderung, und sie steht hier,
     damit sie nicht im Code lebt.

     **Was auch dann nicht abgedeckt ist:** der Haupt-Strom trägt keinen Agenten-Typ
     (`agent` und `agent_type` sind dort strukturell leer) und wechselt innerhalb einer
     Sitzung zwischen Planer und Implementation. Für ihn ist die Splitting-Regel des
     Sammelpostens zu entscheiden (Modul 15 verlangt sie begründet, nicht perfekt);
     ableitbar aus bereits erfassten Feldern sind zwei Signale — das `slice`-Feld
     (Lifecycle-Verzeichnis, WIP-Limit 1) und das Schreibziel (`docs/plan/**` gegen
     Code-Pfade).

     **Lesevorschrift, bindend für jede Auswertung:** eine Rolle gibt es **immer** —
     jeder Tool-Call wurde von jemandem in einer Rolle verursacht. Ein leeres
     `agent_role` ist deshalb eine Aussage über **unser Wissen**, nicht über den Lauf:
     es heißt *unbekannt*, niemals *ohne Rolle*.

     Modul 15 verlangt an dieser Stelle wörtlich: *„Wo ein Span keinen Rollen-Tag trägt
     (Sammelposten), entscheide begründet, wie du ihn aufteilst (anteilig nach
     Tool-Calls? dem auslösenden Slice zugeschlagen?)"*. Daraus folgt genau dreierlei,
     und die Reihenfolge ist die Prüfreihenfolge:
     1. **Pflicht:** eine begründete Splitting-Regel, angewendet — am Ende liegt jedes
        Token auf einer der realen Rollen, nicht auf *unbekannt*.
     2. **Ebenfalls Pflicht, weil dieses Repo Annahmen benennt:** wie **groß** der
        aufgeteilte Anteil war. Ohne diese Zahl kann der Leser nicht beurteilen, wie
        viel des Ergebnisses auf der Regel ruht statt auf Messung.
     3. **Falsch ist nur das eine:** den Sammelposten **ungeteilt** als Rolle führen
        (*„ohne Rolle: 60 %"* als Ergebniszeile) — das erfindet eine Kostenstelle, die
        es nicht gibt. Die Größe zu **zeigen** ist erlaubt und erwünscht; sie
        **stehenzulassen** ist es nicht.

     Nicht gemessen und deshalb offen: ob ein vom **Nutzer** direkt abgesetzter Aufruf
     einen Span erzeugt — dessen Verursacher wäre der Nutzer und keine der sechs
     Rollen, also eine eigene Kostenstelle.
  4. **Altbestände werden beim ersten Span einer Sitzung NICHT entfernt.**
     [`ADR-0011`](../docs/plan/adr/0011-telemetrie-erfassung-policy.md) Festlegung 3
     sieht das vor; der Emitter hängt ausschließlich an. Praktisch folgenlos, solange
     die Sitzungs-Kennung eine UUID ist — aber ein Werkzeug, das Kennungen
     wiederverwendet, mischt zwei Läufe in einer Datei. Aufgeräumt wird ausdrücklich
     (`make span-clean`), nicht nebenbei (Review-Befund LOW-5).
  5. **Ein Hintergrund-Lauf trägt keine Verbrauchs-Achse — der Guard verkleinert die
     Lücke, er schließt sie nicht.** *Erst die Prüfung, dann die Abweichung*, und in
     dieser Reihenfolge, weil
     [`ADR-0011`](../docs/plan/adr/0011-telemetrie-erfassung-policy.md) Festlegung 1
     Punkt 5 die deklarierte Abweichung als die billige Hälfte kennzeichnet
     (*„billiger zu schreiben als eine Lösung und deshalb verdächtig"*).
     1. **Ableitbar? Nein — und das ist gemessen, nicht angenommen.** Die
        `tool_response` eines Hintergrund-Laufs trägt `agentId`, `isAsync`,
        `outputFile`, `canReadOutputFile`, `resolvedModel`, `status`, `prompt` und
        `description` (2026-07-29, an einem echten Aufruf); **keinen** der vier
        `usage`-Zähler, kein `totalTokens`/`totalDurationMs`/`totalToolUseCount`, kein
        `agentType`. Es gibt keinen Teilwert, aus dem ein Zähler folgte. Der einzige
        Zeiger auf mehr — `outputFile` — führt auf einen Freitext-Bestand außerhalb der
        Payload und ist aus demselben Grund ausgeschlossen wie das Transkript in
        Abweichung 1.
     2. **Vermeidbar? Für Rollen-Typen ja — und dieser Teil ist gelöst, nicht erklärt.**
        Der `PreToolUse`-Guard `.claude/hooks/pretooluse-agent-guard.sh` lehnt einen
        Agenten-Typ, für den `.claude/agents/<name>.md` existiert, im Hintergrund ab;
        ein **fehlender** Schalter gilt dabei als Hintergrund, weil die Abwesenheit der
        gemessene Normalfall ist. Bewacht von `test/agent-guard.bats` (in `make test`)
        und den Fällen
        `test/mutations/117-agentguard-rollenpruefung-entfernt.sh`,
        `test/mutations/118-agentguard-namensliste-statt-ableitung.sh` und
        `test/mutations/119-agentguard-schalter-failopen.sh`.
     3. **Was er nicht deckt — und erst das ist die Abweichung.** (a) Ein Typ **ohne**
        Datei in `.claude/agents/` ist keine Rolle: `general-purpose`, `Explore` und die
        übrigen eingebauten Typen laufen im Hintergrund durch, **absichtlich** — sie
        tragen ohnehin keine Rolle in den Span. Ihre `Agent`-Spans tragen von den neun
        Werten genau **einen**: `model_version`, weil `resolvedModel` auch im
        Hintergrund gesetzt ist. Ein Etikett ohne Zahl — die **acht** Werte an
        `usage`/`total*`/`agentType` fehlen. (b) Der Guard ist eine Verdrahtung in
        `.claude/settings.json`; er kann fehlen, abgeschaltet oder umgangen sein, und
        **kein Sensor dieses Repos prüft, dass er verdrahtet ist** — gemessen am
        2026-07-31 über `test/**`, `Makefile`, `harness/tools/*.sh` und die Go-Tests: die
        einzige Verdrahtungs-Prüfung an einer `settings.json` steht in
        `harness/tools/smoke.sh` und gilt dem **emittierten** Repo und dessen
        Command-Guard.

     **Die Abweichung:** ein `Agent`-Span aus einem Hintergrund-Lauf sieht aus wie ein
     erfasster Lauf und ist keiner. Die Erfassung ist insoweit **konstruktiv
     unvollständig** — sie erfindet nichts, sie fehlt.
     **Auflösungs-Trigger, zwei, beide beobachtbar:** (1) die **Abdeckungszahl** aus
     slice-066 DoD (1) — wie viele `Agent`-Spans überhaupt Zähler trugen, mit einem
     Nenner aus `SubagentStart` statt aus denselben Spans; zeigt sie einen nennenswerten
     Anteil zählerloser `Agent`-Spans, ist zu entscheiden, ob der Guard auf **alle**
     Agenten-Typen geweitet wird oder die Zusage einzuschränken ist. (2) Trägt die
     `tool_response` eines Hintergrund-Laufs eines Tages Zähler, entfällt die Abweichung
     ersatzlos — das ist der Hook-Oberflächen-Trigger aus
     [`ADR-0011`](../docs/plan/adr/0011-telemetrie-erfassung-policy.md)
     §Re-Evaluierungs-Trigger, hier nur zugeordnet.
  6. **Der Haupt-Kontext hat keine Zahl — die härtere Hälfte.** Abweichung 3 oben
     benennt seine fehlende **Rolle**; hier steht seine fehlende **Zahl**. Die zwei sind
     verschieden, und die Reihenfolge der Härte ist die umgekehrte der Bequemlichkeit:
     selbst eine gelöste Rollen-Ableitung gäbe dem Haupt-Kontext ein Etikett, aber
     keinen Zähler. Auch hier zuerst die Prüfung:
     1. **Woher die Zähler kommen — gemessen.** Die vier `usage`-Zähler und die drei
        `total*`-Werte stehen ausschließlich in der `tool_response` eines
        `Agent`-Aufrufs. Den Haupt-Kontext umschließt **kein** `Agent`-Aufruf; es gibt
        also kein Ereignis, an dem seine Token anfielen, und keine Payload, die sie
        trüge.
     2. **Aus den erfassten Feldern ableitbar? Nein.** Ein Span trägt `result_bytes` und
        `duration_ms` — Größen **eines** Aufrufs, keine Token. Eine Umrechnung wäre eine
        Schätzung, und eine Schätzung an dieser Stelle ist genau das Raten, das
        [`ADR-0011`](../docs/plan/adr/0011-telemetrie-erfassung-policy.md) Festlegung 1
        Punkt 4 ausschließt (*leer und als leer erkennbar*, nicht geraten).
     3. **Eine zweite Quelle? Keine, die offen steht.** Das Transkript ist als Quelle
        ausgeschlossen (Abweichung 1, letzter Absatz: fremder Besitz, außerhalb des
        Repos, voller Gesprächsinhalt). `SubagentStart` zählt Spawns und trägt keine
        Token.

     **Die Abweichung:** der Verbrauch des Haupt-Kontexts steht in keiner Payload. Jede
     Token-Bilanz aus diesen Spans ist damit eine Bilanz über **Subagenten-Läufe**; ihr
     Nenner ist nicht der Verbrauch des Laufs, und ein Prozentsatz daraus ist ein Anteil
     an der erfassten Teilmenge. Wer ihn schreibt, schreibt das dazu. Für den
     Haupt-Strom selbst gilt unverändert die Splitting-Pflicht aus Abweichung 3 samt der
     Pflicht, die Größe des Sammelpostens zu **zeigen**.
     **Auflösungs-Trigger:** eine Quelle **innerhalb des Repos**, die Haupt-Kontext-Token
     trägt — dieselbe Bedingung führt slice-068 DoD (2). **Ehrlich zu ihrer
     Erreichbarkeit**, weil Modul 7 einen ernst erreichbaren Trigger verlangt und sonst
     die Überführung in eine Dauer-Entscheidung: niemand kann diesen Trigger
     **herbeiführen**, er wird **beobachtet**. Ausgeschlossen ist er nicht — die
     Payload-Fläche wächst messbar (fünf undokumentierte Schlüssel in vier gemessenen
     Aufrufen). Bleibt er auf absehbare Zeit aus, ist der Ort dieser Abweichung nicht
     länger dieser Eintrag, sondern eine ADR.

- **Tooling-Klarstellung zur Fitness Function.** Drei ihrer Zeilen nennen als Tooling
  `bats (make test)`; umgesetzt sind sie als **Go**-Tests unter demselben Target
  (`make test` umfasst `test-bats` **und** `test-go`). Die ADR ist ab *Accepted*
  immutabel ([`AGENTS.md`](../AGENTS.md) §3.4), die Klarstellung gehört also hierher und
  nicht dorthin — wer die Wächter in `test/*.bats` sucht, findet sie nicht
  (Review-Befund LOW-8).

- **Der Strom ist `(session, agent)` — die FELDER, nicht der Dateiname.** Der Dateiname
  ist eine Ableitung davon und darf sich ändern; die Identität nicht. Das ist keine
  Formalie, sondern eine gemessene Lehre: die Korrektur der Namensbildung am 2026-07-29
  (Trenner `-` innerhalb der Teile zu `_`, gegen Strom-Kollisionen) hat den **laufenden**
  Strom dieser Sitzung in zwei Dateien mit **identischem `(session, agent)`** und zwei
  Zählerkreisen zerlegt — **58 doppelt vergebene Nummern**. Eine Doppelvergabe erzeugt
  keine Lücke; der Leser sieht Vollständigkeit, wo zwei Läufe stehen — genau das
  Fehlerbild, gegen das [`ADR-0011`](../docs/plan/adr/0011-telemetrie-erfassung-policy.md)
  Folgepflicht 4 die Nummern eingeführt hat.
  **Daraus zwei bindende Regeln:** (1) eine Auswertung gruppiert nach den **Feldern**,
  nie nach dem Dateinamen, und setzt die Eindeutigkeit von `seq` **je Datei** voraus,
  nicht je `(session, agent)`; (2) wer die Namensbildung ändert, räumt vorher mit
  `make span-clean` auf — sonst wandert der Bruch in den Bestand statt in die
  Änderung. Dieselbe Klasse trat schon einmal auf (awk→Go, 16 Duplikate); beide Male
  war der Auslöser ein Wechsel der Mechanik bei laufendem Strom.

- **Bewacht:** `internal/span/span_test.go` und `cmd/span-emit/main_test.go` (Klemme und stumme
  Ausgabe als Prozess-Eigenschaft, fail-closed Default an fremden Werkzeug-Namen, kein
  Payload-Inhalt im Span, vergebene statt abgeleitete Folgenummer, Nebenläufigkeit, Modus,
  Strom-Trennung, Ableitung von `slice`/`requirement`/`branch`), `make span-check`
  (Emitter vorhanden **und** funktionsfähig, Ablageort real `git check-ignore`-geprüft) sowie
  `test/mutations/107-span-klemme-entfernt.sh`, `test/mutations/108-span-schema-offen.sh`,
  `test/mutations/109-span-folgenummer-eingefroren.sh`,
  `test/mutations/110-span-pflichtfeld-verschwindet.sh` (die Pflicht-Spalte oben: ein
  `omitempty` am falschen Feld ließe es bei leerem Wert lautlos verschwinden),
  `test/mutations/111-span-korrelationsfeld-verschwindet.sh` (dieselbe Mechanik an
  `branch` — dem Feld, an dem der Wächter zuerst vorbeisah),
  `test/mutations/112-span-stdout-geschwaetzig.sh` (die **stdout**-Hälfte von
  Festlegung 6; Fall 107 deckt nur die Exit-Hälfte, weil der Panic-Pfad auf stderr
  schreibt) und `test/mutations/113-span-ablageort-getrackt.sh` (Zeile 3 der Fitness
  Function: Ablageort auf einen getrackten Pfad), `test/mutations/114-span-lock-verzeichnis.sh` (ein liegengebliebenes Lock-**Verzeichnis** der Vorgänger-Fassung legte den Strom lautlos still) und `test/mutations/115-span-ergebnis-inhalt.sh` (**kein Freitext** aus dem Ergebnis — für jedes Werkzeug die Länge, darüber hinaus nur die Positiv-Liste bei `Agent`). Die Zeile sagte bis 2026-07-30 „vom Ergebnis darf nur die Länge in den Span" zu; das wurde mit der Positiv-Liste falsch und ist **ersetzt, nicht ergänzt** — `make comment-claims` fängt so etwas nicht, es prüft die Existenz des Sensors, nicht die Wahrheit des Satzes.
- **Bewacht (die Erfassung aus `tool_response`, seit 2026-07-30) — Zusicherung für
  Zusicherung, nicht Wächter für Wächter.** Die Liste unten nennt, **was** ein Zahn
  bindet; sie nennt die Wächter deshalb mehrfach, wo sie mehreres zusagen.

  **Warum diese Form — die Vorgängerin stellte Namen und Zahlen nebeneinander und wurde
  als 1:1-Abbildung gelesen** (Verifier-Befund V-1 vom 2026-07-30). Dort standen sieben
  Wächter und **sieben** Zähne (123–129). Gezählt nach *„irgendein Fall nennt ihn"*
  hatten **fünf** der sieben einen Zahn; gezählt nach *„ein Zahn bindet die Zusicherung,
  die dieser Absatz ihm zuschreibt"* waren es **vier**. Die Differenz ist genau
  `TestAgentGetsNoArgumentFields`: `test/mutations/131-span-werkzeugname-leer.sh` nennt
  ihn, bindet aber seine Gegenprobe `"tool":"Agent"` — nicht die Zusicherung, für die es
  ihn gibt. **Gemessen, nicht geschlossen** (2026-07-30, einzeln über den
  `run_case`-Pfad des Treibers): streicht man seine beiden B1-Zusicherungen — das
  `"spawned_role"` im `mustNotContain` und die `s.SpawnedRole != ""`-Prüfung —, bleibt
  `make test-go` **grün** und Fall 131 meldet weiter „ok". Die Grenze, auf der das
  Architect-Verdikt vom 2026-07-30 ruht
  (`docs/reviews/2026-07-30-slice-060-dod2-adr-0011-architect.md`), durfte damit lautlos
  verschwinden.

  Die vier Fälle 132–135 schließen das; 136 und 137 kamen am selben Tag aus den
  Review-Befunden MEDIUM-1 und MEDIUM-2 dazu, 138 am 2026-07-31. **Jeder ist einzeln über
  den `run_case`-Pfad des Treibers gefahren** (Grün-Vorlauf und -Nachlauf grün, Host-Baum
  unberührt), und **fünf der sieben färben genau EINEN Wächter an genau der Zeile ihrer
  Zusicherung**; 137 und 138 färben bauartbedingt **zwei**, weil die Draht-Form von
  `spawned_role` in zwei Wächtern zugesagt ist — ihre Köpfe sagen welche, und ihre
  `# expect:`-Zeilen binden je einen der zwei Einträge. Mehrfach-Rot verdeckt seinen
  eigenen Grund — die Lehre aus Review-Befund MEDIUM-4 —, deshalb steht die Zahl je Fall
  auch in seinem Kopf.

  **„Ein Wächter" heißt eine Test-FUNKTION, nicht eine `--- FAIL:`-Zeile** — bei 133
  fallen **vier** Zeilen an: die Funktion `TestOnlyAgentToolGetsResponseValues` und ihre
  drei Untertests `Bash`, `Read`, `Write`, alle an derselben Zeile. Wer am `--- FAIL:`
  abzählt, bekommt dort eine andere Zahl als hier; gezählt wird die Funktion.

  **Wo genau sie fielen, ist eine datierte MESSUNG und keine lebende Zusage** — die
  Nummern altern mit der nächsten in `response_test.go` eingefügten Zeile, und **kein
  Sensor prüft sie**. Der Grund ist **nicht** die Form der Referenz, sondern ihr Ort:
  `codepaths` — und mit ihm die Zeilen-Prüfung `check-lines` — arbeitet nur unter
  `roots: [spec, docs, harness]` (`.d-check.yml`, Zeile 50), und `internal/` steht dort
  nicht; der Konfigurations-Kommentar sagt es selbst (*„tools/cmd/internal folgen mit dem
  Go-Code (Phase 3)"*). **Gemessen am 2026-07-31** (drei `make docs-check`-Läufe gegen
  eine isolierte Kopie, alle Sonden in **derselben** Datei, damit das referenzierende
  Dokument konstant bleibt): eine Zeilen-Referenz auf `internal/span/response_test.go`
  weit jenseits seiner Zeilenzahl bleibt **still** — als Bereich **und** als Einzelzeile,
  mit voller Verzeichnis-Komponente (259 Datei(en), 0 Befund(e)) —, während dieselbe Form
  auf `harness/tools/mutate.sh` **einen** Befund `citation-out-of-range` meldet. Die
  Verzeichnis-Komponente ist also weder notwendig noch hinreichend; bindend ist `roots`.
  **Was daraus für die zurückgestellte Sensor-Arbeit folgt:** sie ist eine **Erweiterung
  von `codepaths.roots` um `internal`** — eine Gate-Anhebung, ab der **jeder**
  Inline-Code-Pfad unter `internal/` mitvalidiert wird, mit entsprechender Sprengweite —
  und damit ein Steering-Loop nach [`MR-001`](#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids),
  **nicht** ein Weiten von `check-lines` auf Referenzen ohne Verzeichnis-Komponente. Bis
  zum 2026-07-30 stand dieser Satz im Präsens und datiert war nur die Klammer —
  Review-Befund LOW-2. **Gemessen am 2026-07-31** (Roh-Läufe, alle `--- FAIL:`-Zeilen
  ausgezählt): 132 fiel an `response_test.go:207`, 133 an `:169`, 135 an `:221`, 134 an
  `:343`, 136 an `:343`, 137 an `:207` **und** `:343`, 138 ebenso an `:207` **und**
  `:343` — 134/136/137/138 an derselben `mustNotContain`-Zeile `:343`, je an einem
  anderen **Eintrag** (134 an `input_tokens`, 136 an `output_tokens`, 137 und 138 an
  `spawned_role`), 137 und 138 zusätzlich an `:207`, der gleichlautenden Zusicherung des
  ersten Wächters. Die Vorgänger-Messung vom 2026-07-30 nannte `:209`/`:171`/`:223`/`:347`
  — dieselben Zusicherungen, um zwei bis vier Zeilen verschoben, genau die Alterung, die
  der Absatz oben benennt.

  1. `TestNoResponseFreetextReachesSpan` — **keines der vier gemessenen Freitext-Felder
     erreicht die Zeile**, je mit eigenem Kanarienvogel. Zähne:
     `test/mutations/123-span-ergebnis-content.sh`,
     `test/mutations/124-span-ergebnis-prompt.sh`,
     `test/mutations/125-span-ergebnis-description.sh`,
     `test/mutations/126-span-ergebnis-outputfile.sh` (je ein Freitext-Feld in die
     Positiv-Liste aufgenommen).
  2. `TestUnlistedResponseKeyStaysOut` — die **Grenze** selbst: ein ungelisteter
     Schlüssel bleibt draußen, auch ein verschachtelter. Zahn:
     `test/mutations/127-span-positivliste-negiert.sh` (die Liste **negiert**: alles
     außer den vier wandert durch).
  3. `TestOnlyAgentToolGetsResponseValues` — die Achse ist der Werkzeug-**Name**, nicht
     die Gestalt der Antwort. Zahn:
     `test/mutations/133-span-werkzeugachse-geweitet.sh` (die Achse auf **jedes**
     klassifizierte Werkzeug geweitet; `Bash`, `Read` und `Write` geben dann Zähler,
     Rolle und Modell preis).
  4. `TestAgentGetsNoArgumentFields` — **B1**: `spawned_role` kommt aus
     `tool_response.agentType`, **nie** aus `tool_input.subagent_type`. Zahn:
     `test/mutations/132-span-rolle-aus-argument.sh` (der Rückfall auf das Argument,
     wenn das Ergebnis keine Rolle lieferte).
  5. `TestAgentGetsNoArgumentFields` — **B2**: `Agent` liegt auf **keiner**
     Gattungszeile (kein `path`, `program`, `argc`, `bytes`, `sha256_16`). Zahn:
     `test/mutations/135-span-agent-auf-gattungszeile.sh` (`Agent` als Kommando-Werkzeug
     abgeleitet).
  6. `TestSpawnedRoleIsNormalised` — der Wert aus dem Ergebnis wird gegen die sechs
     kanonischen Namen normalisiert. Zahn:
     `test/mutations/128-span-rolle-unnormalisiert.sh` (die Normalisierung entfernt —
     danach steht `general-purpose` als Rolle im Span, die erfundene Kostenstelle, die
     die Lesevorschrift verbietet).
  7. `TestResolvedModelIsStructurallyBounded` — die Schranke um `model_version`
     **verwirft, statt zu kürzen**. Zahn:
     `test/mutations/129-span-modellschranke-kuerzt.sh` (die feinere der beiden Zusagen
     aus Festlegung 4 der Positiv-Liste; sie impliziert die gröbere).
  8. `TestFailedAgentCallCapturesNothing` — **kein halber Span**: die neun Werte fehlen,
     statt anwesend-und-ungemessen dazustehen. Seine `mustNotContain`-Liste nennt sie
     seit dem 2026-07-30 **alle neun** namentlich. **Vorher trennten sich zwei
     Zählungen, und das Auseinanderhalten ist der Punkt:** *namentlich* standen **sechs**
     der neun da (`spawned_role`, `input_tokens`, `total_tokens`, `total_duration_ms`,
     `total_tool_use_count`, `model_version`), *gedeckt* waren **acht** — die zwei
     Cache-Zähler fielen als Teilstring unter `"input_tokens"`. **Acht** ist also die
     Abdeckungs-, nicht die Nennungs-Zahl. (Das Literal selbst trug zehn Argumente:
     die sechs Namen, `result_bytes` — das **keiner** der neun ist — und drei
     Nicht-Feld-Proben.) `output_tokens` war weder genannt noch gedeckt und stand
     repo-weit in keiner Negativ-Prüfung — die Zeile hier schrieb dem Wächter also eine
     Zusicherung zu, die er nicht hatte (Review-Befund MEDIUM-1). Genau diese
     Verwechslung von *genannt* mit *gedeckt* ist der Mechanismus, der ihn verborgen
     hat. **Gemessen, nicht geschlossen:** mit
     `json:"output_tokens"` statt `json:"output_tokens,omitempty"` blieb `make test-go`
     bei **Exit 0** mit **null** `--- FAIL:`-Zeilen, während jede geschriebene Zeile —
     auch ein reiner `Bash`-Span — `"output_tokens":null` trug (beides in isolierter
     Kopie gefahren, die Span-Zeile aus dem gebauten Emitter gelesen). Zähne:
     `test/mutations/134-span-zaehler-praesent-leer.sh` (`omitempty` von `input_tokens`
     genommen — der Zähler steht danach als `null` in **jeder** Zeile),
     `test/mutations/136-span-ausgabezaehler-praesent-leer.sh` (dasselbe an
     `output_tokens`) und `test/mutations/137-span-rollenfeld-praesent-leer.sh`
     (dasselbe an `spawned_role`; er gehört zugleich zur Draht-Form weiter unten).
     **Was diese drei NICHT binden, und darum hier steht:** sie binden **drei** der neun
     Listen-Einträge. **Der Prüfstein dafür ist das Kippen, nicht das Rot:** ein Zahn
     bindet einen Eintrag genau dann, wenn das **Streichen dieses Eintrags** den Fall von
     „ok" auf **Befund** kippt. Dass seine Mutation genau diesen Namen in die
     Fehlschlag-Zeile schreibt, ist dafür **notwendig, nicht hinreichend** —
     `mustNotContain` prüft per `strings.Contains` und bricht beim **ersten** Treffer ab.
     Ein Fall an `cache_read_input_tokens` schriebe den Namen und bliebe trotzdem
     ungebunden: streicht man den Eintrag, greift weiterhin `"input_tokens"` als
     Teilstring, der Wächter bleibt rot, `make mutate` meldet „ok". 134 (`input_tokens`),
     136 (`output_tokens`) und 137 (`spawned_role`) sind in dieser Richtung **gefahren**,
     nicht abgeleitet. Die übrigen **sechs** (die zwei
     Cache-Zähler, `total_tokens`, `total_duration_ms`, `total_tool_use_count`,
     `model_version`) prüft der Wächter, aber **kein Fall des heutigen Sets schreibt
     einen von ihnen in diese Zeile** — wer einen aus der Liste streicht, bekommt von
     `make mutate` keinen Befund. Das ist aus der Bauart der Fälle **abgeleitet**, nicht
     einzeln gefahren. Sechs weitere `omitempty`-Kopien wären möglich und sind bewusst
     **nicht** geschnitten (sie kosten je einen vollen Sensor-Lauf und binden je einen
     Namen); wer sie will, schneidet sie — und misst dann das **Kippen**, denn für die
     zwei Cache-Zähler ist es aus dem Teilstring-Grund oben **nicht** zu haben, solange
     `"input_tokens"` in derselben Liste steht. Hier steht, was gedeckt ist, statt die
     Zahl neun ein zweites Mal auf einen Zahn zu schreiben, der einen Eintrag bindet.
  9. `TestAgentGetsNoArgumentFields` **und** `TestFailedAgentCallCapturesNothing` — die
     Gegenprobe `"tool":"Agent"`: ein `Agent`-Span ist an der geschriebenen Zeile als
     solcher erkennbar. Zahn: `test/mutations/131-span-werkzeugname-leer.sh` (Punkt 2 der
     Voraussetzung weiter unten; dieser Fall färbt bauartbedingt mehrere Wächter, sein
     Kopf sagt welche).

  **Was hier KEINEN Zahn hat, und darum benannt ist:** die
  `mustContain`-**Gegenproben** — die Zeilen, die diese Wächter davor bewahren, eine
  Erfassung von *nichts* für grün zu halten. **Gemessen (2026-07-30), nicht geschlossen:**
  macht man `mustContain` in der isolierten Kopie wirkungslos, bleibt `make test-go`
  grün, und die Fälle 123 und 127 melden weiter „ok" — sie färben ihre Wächter über die
  `mustNotContain`-Hälfte und merken vom Verlust der anderen nichts. Unbewacht ist damit
  **nicht die Eigenschaft** (eine ganz ausfallende Erfassung bräche die Gegenproben und
  damit `make test`), sondern **der Wächter dieser Eigenschaft**: er darf seine Zähne
  verlieren, ohne dass `make mutate` es meldet — dieselbe Klasse wie V-1, eine Ebene
  tiefer. Ein Fall dafür ist **möglich** (eine Mutation, die die Erfassung abschaltet),
  färbte aber mehrere Wächter dieser Liste auf einmal; ob dieser Preis richtig ist,
  entscheidet der Slice, der ihn schneidet. Hier ist die Lücke **benannt**, nicht
  mitgezählt.

  **127 ist der tragende:** vier namentliche Fälle unterscheiden eine
  Positiv-Liste **nicht** von einer Implementierung, die genau diese vier ausfiltert.
  **Seine Grenz-Zusicherung ist eindeutig an ihn gebunden**, und das ist gemessen: mit
  entferntem `mustNotContain`-Block meldet der Treiber ihn als **Befund** (*„rot, aber …
  fällt nicht — falscher Grund"*), nicht als „ok" — bis 2026-07-30 blieb er dort „ok",
  weil die Gegenprobe desselben Wächters `model_version` mitprüfte und die Senke des Falls
  genau dieses Feld ist (Review-Befund MEDIUM-4).
  **Die zwei zuletzt ergänzten Zähne haben eine Vorgeschichte, die hierher gehört:** bis
  2026-07-30 stand an dieser Stelle, die Normalisierung von `spawned_role` und die
  Schranke um `model_version` seien „je einmal rot gesehen worden", und als Beleg war ein
  *Implementations-Bericht vom 2026-07-30* genannt — ein Artefakt, das im Repo **nie
  existierte** und auch in keiner Commit-Message stand (Review-Befund MEDIUM-3). Der
  Beleg ist jetzt der Lauf selbst: Fall 128 und Fall 129 sind am 2026-07-30 einzeln über
  den `run_case`-Pfad des Treibers gefahren und **rot gesehen** (Grün-Vorlauf und
  -Nachlauf grün, Host-Baum unberührt), und sie wiederholen die Messung bei jedem
  `make mutate`. Damit ist zugleich die Lücke geschlossen, die derselbe Absatz benannte:
  die beiden Wächter hatten keinen **Dauer**-Sensor.
  **Die Draht-Form von `spawned_role`** — abwesend statt `""`, und damit die Lesevorschrift,
  die darauf ruht — bewachen `TestAgentGetsNoArgumentFields` und
  `TestFailedAgentCallCapturesNothing` an der geschriebenen Zeile, **jeder mit einem
  EIGENEN `mustNotContain`-Eintrag**. Zwei Einträge brauchen **zwei** Zähne, denn der
  Treiber sucht je Fall genau **einen** Namen in der Fehlschlag-Ausgabe (Bedingung 4) —
  ein Fall kann höchstens einen Eintrag binden, auch wenn seine Mutation beide Wächter
  rot färbt. Die zwei Zähne tragen darum **dieselbe** Mutation (das `omitempty` an
  `json:"spawned_role"` genommen: danach steht `"spawned_role":""` in jeder Zeile und
  behauptet in jedem `Bash`-Span einen Subagenten, den es nicht gab) und unterscheiden
  sich nur in ihrer `# expect:`-Zeile:
  **`test/mutations/137-span-rollenfeld-praesent-leer.sh`** (seit 2026-07-30) bindet den
  Eintrag im **Fehlschlag**-Wächter,
  **`test/mutations/138-span-rollenfeld-praesent-leer-erfolgsfall.sh`** (seit 2026-07-31)
  den im **ersten**. **Zweiseitig gemessen am 2026-07-31** (isolierte Kopie, Grün-Vorlauf
  und -Nachlauf grün, alle `--- FAIL:`-Zeilen ausgezählt): mit intakten Wächtern melden
  beide „ok" und färben je **zwei** Wächter (`response_test.go:207` und `:343`); streicht
  man `"spawned_role"` aus der Liste des **ersten** Wächters, meldet **138 Befund**
  (*„rot, aber … faellt nicht — falscher Grund"* — es fällt nur noch der Fehlschlag-
  Wächter), während **137 „ok"** meldet; streicht man ihn aus der Liste des
  **Fehlschlag**-Wächters, kehrt es sich um (**137 Befund**, **138 „ok"**).
  **Die Strukt-Prüfung `s.SpawnedRole != ""` im ersten Wächter deckt das nicht ab** und
  darum ist dessen Eintrag tragend: das Feld ist in **beiden** Draht-Formen `""`, über
  An- oder Abwesenheit entscheidet allein das JSON-Tag. **Bis 2026-07-31 war dieser
  Eintrag von keinem Fall gebunden** — man konnte ihn streichen, und `make gates` wie
  `make mutate` blieben still. **Das ist eine Vollständigkeits-Aussage und darum
  ausgezählt statt behauptet:** kippen kann nur ein Fall, dessen `# expect:`-Zeile genau
  diesen Wächter nennt (Bedingung 4 prüft **einen** Namen); das sind über alle Fälle
  genau **vier** — 131, 132, 135 und der neue 138. Mit gestrichenem Eintrag melden 131,
  132 und 135 weiter „ok" (gemessen 2026-07-31, ein Lauf), weil sie an der Gegenprobe
  `"tool":"Agent"`, an der Strukt-Prüfung bzw. an der Gattungszeile fallen — **nur 138**
  meldet Befund. Vor dem 2026-07-30
  hatte die Draht-Form **überhaupt** keinen Zahn — der Code-Kommentar an `intoSpawnedRole`
  nannte dafür Fall 134,
  der `json:"input_tokens,omitempty"` mutiert und `spawned_role` nirgends berührt
  (Review-Befund MEDIUM-2; gemessen: mit gestrichenem `"spawned_role"` in der
  `mustNotContain`-Liste des Fehlschlag-Wächters meldet 134 weiter „ok"). **Fall 132
  trägt sie nicht:** er bindet die *Herkunft* und nur im ersten der beiden Wächter — der
  zweite führt `subagent_type: "nope"`, das zu leer normalisiert, und bleibt unter 132
  absichtlich grün (gemessen 2026-07-31: 132 färbt **genau einen** Wächter, alle
  `--- FAIL:`-Zeilen ausgezählt). **Die Herkunfts-Achse des zweiten Wächters hat damit
  keinen Zahn** — und zwar bewusst: ein *roher* Rückfall färbte ihn mit, und „132 rot"
  hieße dann nicht mehr eindeutig „B1 greift im ERSTEN Wächter" (die Begründung steht im
  Kopf von 132). Hier **benannt**, nicht mitgezählt. Ihre
  **Voraussetzung** hat
  **zwei Hälften**, und beide hingen bis zum 2026-07-30 an einer falschen Fundstelle: hier stand,
  `TestMandatoryFieldsAlwaysPresent` bewache sie *„mit dem Zahn
  `test/mutations/110-span-pflichtfeld-verschwindet.sh`"*. Fall 110 mutiert aber `tool_use_id`
  und Fall 111 `branch`; **kein** Fall berührte `tool` (Review-Befund R2-MEDIUM-1 vom
  2026-07-30). Gemessen statt geschlossen: streicht man `"tool":` aus der Pflicht-Liste in
  `internal/span/span_test.go`, meldet 110 weiter „ok". Die zwei Hälften mit ihren echten
  Sensoren:
  1. **`tool` bleibt Pflicht** — es steht auch bei leerem Wert in der Zeile. Wächter:
     `TestMandatoryFieldsAlwaysPresent` (die Listen-Zeile). Dauer-Zahn:
     `test/mutations/130-span-werkzeugfeld-verschwindet.sh` (`omitempty` an `json:"tool"`).
  2. **Ein `Agent`-Span ist an der Zeile als solcher erkennbar** (`"tool":"Agent"`). Wächter:
     `TestAgentGetsNoArgumentFields` und `TestFailedAgentCallCapturesNothing`. Dauer-Zahn:
     `test/mutations/131-span-werkzeugname-leer.sh` (der Werkzeug-Name erreicht die Zeile nicht
     mehr). **Hälfte 1 trägt Hälfte 2 nicht:** `"Agent"` ist ein nicht-leerer Wert, den ein
     `omitempty` nicht verschwinden lässt — die zwei Zähne sind darum zwei und nicht einer.

  **Beide Zähne sind zweiseitig gemessen** (2026-07-30, einzeln über den `run_case`-Pfad des
  Treibers; Grün-Vorlauf und -Nachlauf grün, Host-Fingerabdruck vor/nach gleich): mit intakten
  Wächtern melden sie „ok"; mit gestrichener Listen-Zeile meldet 130 **Befund** (*„blieb
  GRUEN — … hat keine Zaehne mehr"*), mit gestrichener Zeilen-Gegenprobe meldet 131 **Befund**
  (*„rot, aber … faellt nicht — falscher Grund"*). Die **vierzehn** Zähne oben (123–129 und
  132–138) bewachen die **Erfassung**; diese **zwei** (130, 131) bewachen ihre
  **Voraussetzung** — zwei Zählungen über zwei Eigenschaften, keine Korrektur der ersten.
  Die erste Zahl war bis 2026-07-30 **sieben**, wuchs mit den vier Fällen aus
  Verifier-Befund V-1 auf elf, mit den zwei Fällen aus den Review-Befunden MEDIUM-1
  und MEDIUM-2 (136, 137) auf dreizehn und am 2026-07-31 mit 138 auf vierzehn —
  gewachsen, nicht korrigiert.

  **Auch Fall 132 ist zweiseitig gemessen** (2026-07-30, derselbe Pfad): mit intaktem
  Wächter meldet er „ok" (`-> TestAgentGetsNoArgumentFields rot`, gefallen an der
  B1-Zeile — am 2026-07-31 `response_test.go:207` —, als einziger Wächter des ganzen
  Laufs); mit
  gestrichenen B1-Zusicherungen meldet er **Befund** (*„make test-go blieb GRUEN —
  … hat keine Zaehne mehr"*), **während 131 im selben Lauf weiter „ok" meldet**. Genau
  diese zwei Zeilen nebeneinander sind der Beleg, dass B1 jetzt gebunden ist und vorher
  nicht. **Was er bindet, ist die EIGENSCHAFT B1, nicht der `mustNotContain`-Eintrag:**
  streicht man nur diesen, fällt der Wächter weiter über die Strukt-Prüfung und 132
  meldet „ok" (gemessen 2026-07-31). Den Eintrag bindet 138.
- **Auflösungs-Trigger:** permanent, solange Spans erfasst werden. Die Tabelle ändert sich mit
  jedem neuen Feld — jede Änderung ist ein Eintrag hier, kein Nebeneffekt im Skript.

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
