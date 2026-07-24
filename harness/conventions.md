# Harness-Konventionen

## Purpose

Repo-lokale Strukturregeln gegenüber der adoptierten Baseline. Bei
Konflikt mit einer kanonischen Quelle gilt diese (Source Precedence).

## Baseline

- **Konvention:** AI-Harness-Kurs
- **Regelwerk + Templates:** `v3.5.0` committet vendored
  (`.harness/baseline/v3.5.0/`, [`MR-007`](#mr-007--baseline-committet-vendored-statt-gefetchter-cache)); Regelwerks-Stand laut
  `regelwerk/README.md`: **Kurs-Welle 32 · 2026-07-19**.
- **d-check:** Image v0.51.1 (Digest in d-check.mk, [`MR-010`](#mr-010--d-check-gate-fragment-tool-generiert), [`MR-011`](#mr-011--zitat-verifikation-via-d-check-adoptiert-check-lines), [`MR-012`](#mr-012--d-check-pin-v0511-sources-verfügbar))
- **Datum der Adoption:** 2026-06-13 (Templates-Stand damals: `templates-v4`).
  **Re-Baseline auf `v3.1.0`:** 2026-07-17 (slice-011/012); **auf `v3.5.0`:** 2026-07-19 (slice-019).

## Adoptierte Konventions-Quellen

- **Extern (Kurs, kanonisch):** <https://github.com/pt9912/ai-harness-course/tree/v3.5.0/kurs/de>
  — auf den Tag `v3.5.0` gepinnt, **nicht** `main`-floating
  ([`LH-QA-02`](../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit); Erreichbarkeit
  am 2026-07-19 per `curl` als HTTP 200 belegt). Ersetzt die frühere
  `raw…/main/…/agents-regelwerk.md`-Monolith-URL, die **404** liefert (der Monolith
  existiert upstream seit v2.0.0 nicht mehr — die Module leben unter `/kurs/de/`).
- **In-Repo (verkörperte Form):** die committet vendored Baseline
  `.harness/baseline/v3.5.0/{regelwerk,templates}/` ([`MR-007`](#mr-007--baseline-committet-vendored-statt-gefetchter-cache)) — die
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
  bash+curl ohne jq/node ([`LH-QA-03`](../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)).
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
- **Setzung 2 — Frequenz nach Sensor-Klasse.** „Alles pro Push" für die hermetischen Sensoren
  (`gates`/`smoke`/`mutate`); die **Netz-Sensoren** `regelwerk-check`/`baseline-freshness` laufen
  **nur nächtlich** (`schedule`). Grund: sie erreichen einen Fremd-Host (Kurs-Release); ein
  Upstream-Ausfall ist kein Defekt des Commits und darf keinen Push röten — sonst werden Gates
  umgangen ([`LH-QA-01`](../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)-Geist auf Prozess-Ebene).
- **Setzung 3 — `ci-lint` ist ein Gate.** actionlint prüft `.github/workflows/` (gepinntes Image,
  Docker-only, [`ADR-0003`](../docs/plan/adr/0003-go-native-binaries.md)) und läuft **in** `make gates`:
  der Workflow ist ein reales committetes Artefakt (nicht-leerer Prüfbereich,
  [`LH-QA-01`](../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)), und ein Syntaxfehler
  darin ist **lokal vor dem Push** fangbar statt erst im ersten Actions-Lauf — das lokale
  Gegenbeispiel-Gate zur Zusage „die CI läuft" ([`AGENTS.md`](../AGENTS.md) §3.6).
- **Setzung 4 — Runner + Actions gepinnt, so weit es geht ([`LH-QA-02`](../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)).** `runs-on: ubuntu-24.04`
  (benannte Version, **nicht** `ubuntu-latest`); `actions/checkout` per **Commit-SHA** gepinnt
  (`@11bd719…` = v4.2.2), nicht per wanderndem `@v4`. **Grenze:** ein GitHub-**hosted** Runner-Image
  ist nicht *digest*-pinnbar (das erlauben nur self-hosted/Container-Jobs) — `ubuntu-24.04` benennt
  eine Version, deren Paketstand GitHub periodisch aktualisiert. Die Reproduzierbarkeit der *Checks*
  trägt daher nicht der Runner, sondern die **digest-gepinnten Tool-Images** der `make`-Targets
  (bats/shellcheck/actionlint/d-check/golang/golangci); der Runner liefert nur Docker + Checkout.
- **Grenze — nicht lokal rot-sehbar.** Der Workflow selbst läuft auf GitHub; `ci-lint` belegt nur
  seine **Syntax**, nicht sein **Verhalten**. Ob `make gates` auf einem *wirklich* frischen Klon grün
  ist, zeigt erst der erste Actions-Lauf. **Lokal so weit belegt wie möglich** (Verifikation
  slice-027): `git clone` in ein frisches tmp ohne `.harness/state/` → `make gates` Exit 0; offen
  bleibt allein die GitHub-gehostete Ausführung.
- **Auflösungs-Trigger:** permanent; `ACTIONLINT_IMAGE` bei Bedarf neu pinnen (wie
  `BATS_IMAGE`/`SHELLCHECK_IMAGE`).

## Modus-Deklaration pro Sub-Area

| Sub-Area | Modus | Begründung | Graduation |
|---|---|---|---|
| `*` (gesamtes Repo) | Greenfield | Neues Repo, Doc führt, Code folgt | n/a (GF) |
| `harness/tools/` | Greenfield | adoptierte Harness-Mechanik (Adaptions-Block) | n/a (GF) |
| `.codex/` | Greenfield | neue Pfad-Familie, adoptierte SessionStart-Hook-Mechanik | n/a (GF) |
