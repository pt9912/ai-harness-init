# MR-006 — Regelwerk-Cache als Split-Modul-Verzeichnis

> **HISTORIE — überholt seit slice-011 → [`MR-007`](../conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache).**
> Der folgende Body beschreibt den **gefetchten, gitignorierten** Split-Modul-Cache
> (`.harness/cache/agents-regelwerk/`, `make regelwerk-fetch`). Beides existiert
> nicht mehr: die Baseline ist **committet vendored**
> ([`MR-007`](../conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)).
> Übernommen wurden von hier: die Split-Modul-Form, das **Index-only-Inject** und
> das read-on-demand (samt des unten benannten Presence-Tradeoffs), sowie
> `regelwerk-check` als Drift-Monitor — dessen **Grenze** (er sieht nur das Asset
> des gepinnten Tags, keinen neuen Tag) [`MR-007`](../conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
> ausdrücklich benennt. Der „wortgleich"-Wortlaut unten galt für v1.2.0 und wird
> **nicht** umgeschrieben.

- **Datum:** 2026-06-16
- **Geltungsbereich:** `Makefile`, [`harness/tools/`](../../harness/tools/), `.harness/cache/`, `CLAUDE.md`, `AGENTS.md`, [`test/`](../../test/); ergänzt [`MR-004`](../conventions.md#mr-004--sessionstart-regelwerk-injektor).
- **Ersetzt-Baseline-Regel:** keine — nach dem Wortlaut der Eintrags-Vorlage damit ein **Fork**,
  und er setzt keine Abweichung: er **baut eine zurück**. Was von ihm fort gilt — Split-Modul-Form,
  Index-only-Inject, read-on-demand — ist genau das, was
  [`modul-02-harness-bootstrap.md`](../../.harness/baseline/v5.18.0/regelwerk/modul-02-harness-bootstrap.md#greenfield-bootstrap-schritt-sequenz-modul-2)
  §Anmerkung zur vendored Baseline (Schritt 2) am adoptierten Stand `v5.12.0` verlangt: pro
  Entscheidung den relevanten Abschnitt nachschlagen *„ohne das ganze Regelwerk im Kontext zu
  halten"*. Der Tradeoff unten benennt den Preis dieser Bewegung, nicht eine Abweichung von ihr.
  Der **Cache** dagegen — gefetcht und gitignoriert — wich ab und existiert nicht mehr
  ([`MR-007`](../conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache), Kopf-Marke oben).
- **Adaption:** Der Regelwerk-Cache ist ein **Split-Modul-Verzeichnis**
  `.harness/cache/agents-regelwerk/` (21 Dateien: `grundlagen-*`, `modul-00`…`modul-16`,
  `README.md`-Index) statt der bisherigen Einzeldatei. `make regelwerk-fetch` zieht
  `lab-regelwerk.zip` vom Release-Tag (`REGELWERK_URL`), **ZIP-sha256-gepinnt**
  (`REGELWERK_SHA256`), verifiziert **vor** jeder Cache-Mutation und ersetzt den
  Cache via temp→`mv` (bei Fehler/Drift unverändert,
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit); das `mv` ist
  atomar, das Replace als Ganzes nicht — der Cache ist gitignored/regenerierbar). Der
  Codex-SessionStart-Hook injiziert künftig **nur den Index** (`README.md`, ~3,7 KB)
  mit Pointer-Präfix aufs Cache-Verzeichnis; **beide Agenten** lesen das relevante
  Modul **on-demand**. awk-Encoder bleibt (kein node/jq,
  [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)); **kein** Netz
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
  (10k/150k-Caps, [`MR-004`](../conventions.md#mr-004--sessionstart-regelwerk-injektor)-Nachtrag) und
  für Codex ein Per-Session-Kostenblock; das Split-ZIP serviert pro Modul. Quelle
  bleibt **wortgleich** (ZIP-`README.md`: derivative Sicht, bei Konflikt gilt die
  Kurs-Quelle) — **kein** selbst erzeugter Digest/Kurzfassung (kein Rückfall in die
  slice-007-Harness-Lüge).
- **Auflösungs-Trigger:** permanent; Re-Pin (`REGELWERK_SHA256`) + Tag-Bump bei
  Upstream-Release manuell. Read-only Drift-Überwachung: `make regelwerk-check`
  (slice-009) vergleicht `sha256(Upstream-ZIP)` gegen `REGELWERK_SHA256` und
  mutiert nichts — `regelwerk-fetch` *aktualisiert*, `regelwerk-check` *überwacht*
  (beide Maintenance/Netz, nicht in `gates`).
