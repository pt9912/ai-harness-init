# Verifikations-Report: slice-sprung-auf-v6130-wird-vollzogen — 2026-09-29

**Rolle:** Verifier (Modul 11) — DoD-/ADR-Konformität und Plan-vs-Code-Diff an den Planner.
Frischer Kontext, kein Selbst-Verifizieren. Nicht der Reviewer-Maßstab (Diff gegen Plan/ADR/Hard
Rules — `docs/reviews/2026-09-29-slice-sprung-auf-v6130-wird-vollzogen.md`) und nicht Closure
(§7, Register, Risiko-Ausgänge, `git mv` — Planner, [`AGENTS.md`](../../AGENTS.md) §3.10).

**Gegenstand:** Slice `slice-sprung-auf-v6130-wird-vollzogen`
(`docs/plan/planning/in-progress/slice-sprung-auf-v6130-wird-vollzogen.md`, §2 vollständig
gelesen, inkl. der zwei verlinkten Register-Klassen). Diff der Umsetzung
`b8597a22^..3ef54b82`; geprüft über HEAD `3ef54b82`, Arbeitsbaum clean.

**Maßstab:** DoD (§2, drei Liefer-Punkte + fünf Sammelpunkte), [`LH-QA-01`](../../spec/lastenheft.md)/[`LH-QA-02`](../../spec/lastenheft.md),
[ADR-0072](../plan/adr/0072-ziel-fassung-regiert-den-sprung-v6130.md),
[`ADR-0018`](../plan/adr/0018-ziel-fassung-regiert-die-migration.md) Festlegung 2,
[`ADR-0031`](../plan/adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) Festlegung 2,
[`MR-033`](../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist),
[`AGENTS.md`](../../AGENTS.md) §3.6 (kein grüner Test als Behauptung — Bewusstes Brechen
nachgezogen), Baseline-Regelwerk Modul 11.

## Ergebnis

| Punkt | Verdikt |
|---|---|
| DoD 1a — vendored Baum `v6.13.0` + `SHA256SUMS`, kein `v6.9.0`-Ordner, `baseline-verify` OK | **bestätigt** |
| DoD 1b — fünf Pin-Stellen byte-gleich; sha256 am Release-Asset gemessen | **bestätigt + Bewusstes Brechen rot aus richtigem Grund** |
| DoD 1c — sieben Symlinks, 0 auf anderem Tag | **bestätigt** |
| DoD 1d — 0 Markdown-Links auf den alten Tag | **bestätigt** |
| DoD 1e — Inline-Code-Pfade je Treffer geurteilt | **bestätigt — 35 Resttreffer, alle eingefroren oder datiert** |
| DoD 1f — `InventurMessTag` = `v6.13.0`, Wächter grün | **bestätigt + Bewusstes Brechen rot aus richtigem Grund** |
| DoD 2 — Freshness über 71 Einträge, Ausgänge, Delta-Inventur | **bestätigt — Stichprobe 3 von 6 betroffenen Einheiten nachgelesen** |
| DoD 3 — Vorlagen-Bericht in §5-Form, Instanzen als Ist-Maßstab, Delta am Tausch-Commit | **bestätigt** |
| DoD 4 — `make gates` grün über HEAD, Stempel deckungsgleich | **bestätigt** |
| DoD 5 — `make full-smoke` EXIT 0 | **bestätigt durch eigenen Lauf — der übergebene Beleg war ein Alt-Log vom 2026-09-23** |
| DoD 6 — Review-Report vorliegend, Merge-Blocker aufgelöst | **bestätigt, je Befund der Auflösungs-Commit** |
| DoD 7 — Doku-Update (§Baseline, Konventions-Quellen, Sprung-Zeile) im Architect-Commit | **bestätigt** |

## DoD 1 — Sechs Träger-Klassen auf `v6.13.0`

**Bricht, wenn:** eine Pin-Stelle von den übrigen abweicht, ein Link ins Leere zeigt oder der
emittierte Mess-Tag vom gefetchten Stand trennt. Die unbewachte Hälfte (Symlinks, Inline-Pfade)
ist über direkte Messung belegt, wie der Plan §2 es verlangt.

1. **Vendored Baum.** `ls -1 .harness/baseline/` → `v6.13.0` (einziger Eintrag);
   `.harness/baseline/v6.13.0/{regelwerk,templates,SHA256SUMS}` committet
   (`git ls-files .harness/baseline/v6.13.0/` → 55 Dateien);
   `make baseline-verify` → `baseline-verify: v6.13.0 OK — 54 Dateien (Integritaet +
   Vollstaendigkeit, netzlos)`. Tragend das `OK`; die Dateizahl ist kein Erwartungswert.
2. **Fünf Pin-Stellen, byte-gleich** (`sha256` in allen = `b5151e77807e2affebb25cfab9be24b88cf43afc42c075db0b982a2ff1052b96`):
   `Makefile:25` `BASELINE_TAG ?= v6.13.0`, `Makefile:34` `BASELINE_ZIP_SHA256 ?= <Wert>`,
   `.d-check.yml:504-505` (`sources`-`url` + `sha256`), `internal/fetch/baseline.go:48`
   (`DefaultTag`), `baseline.go:54` (`DefaultBaselineSHA256`). Die Messung **am Release-Asset**
   belegt das Übergabe-Artefakt mit drei Quellen (Asset-Download, `gh api … .assets[].digest`,
   Release-`SHA256SUMS`) plus Kontrolllauf gegen `v6.9.0` (byte-gleich dem alten Pin) —
   `docs/reviews/2026-09-29-…-freshness.md` §Gemessene Werte. **Bewusstes Brechen (Klasse
   vertritt, in einer Worktree-Kopie, nicht im Baum):** `DefaultTag` auf `v6.9.0` verdreht →
   `TestDefaultTag_MatchesBaseline` rot mit
   `fetch.DefaultTag "v6.9.0" != Makefile BASELINE_TAG "v6.13.0" (Drift bei Re-Baseline)` —
   die Meldung benennt die gemutete Stelle und die Drift-Richtung, nicht irgendeinen Fehler.
   Kopie verworfen, `git status` clean.
3. **Symlinks.** `readlink .claude/rules/*.md | grep -c '\.harness/baseline/'` → **7**;
   `… | grep '\.harness/baseline/' | grep -vc 'baseline/v6\.13\.0/'` → **0**.
4. **Markdown-Links.** Die zwei Link-Kommandos aus §1 (Pathspec
   `*.md :!.harness/baseline :!docs/reviews :!docs/plan/planning/done :!docs/plan/carveouts/done :!docs/plan/planning/observations`)
   über dem Ergebnis-Stand → **0**.
5. **Inline-Code-Pfade — null Adressen, nicht null Treffer.** 35 Resttreffer, je Treffer
   geurteilt ([`MR-033`](../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)):
   31 in `docs/migrations/v6.9.0.md` — datierte Mess-Aussage (Bericht des vorigen Sprungs; die
   Pfade benennen den Stand, gegen den gemessen ist); 3 in
   `docs/plan/adr/0065-emittierte-kennungs-form-folgt-dem-regelwerk.md` und 1 in
   `docs/plan/adr/0069-…` — `Accepted`, eingefroren (§3.4). **Null Restadressen**; die
   Verdopplung mit dem Review-Report (§Geprüft, ohne Befund) deckungsgleich.
6. **Emittierter Mess-Tag.** `internal/emit/baumaussage.go:36`:
   `const InventurMessTag = "v6.13.0"`. `TestInventurMessTag_IstDerGefetchteStand` grün im
   Docker-Test-Image (`docker build --target test` frisch gebaut;
   `docker run --rm --network none … go test -count=1 -run TestInventurMessTag_IstDerGefetchteStand
   ./internal/emit/` → `PASS`). Die `templates.go`-Kommentar-Proben sind auf `v6.13.0`
   nachgezogen (kein `v6.9.0`-Treffer mehr unter `internal/` — `grep` → 0).

## DoD 2 — Freshness über die 71 aktiven Einträge

Grundgesamtheit nachgemessen: `ls harness/conventions/*.md | wc -l` → **71**. Das
Übergabe-Artefakt (Freshness-Report) weist 6 betroffene Einheiten mit Release-Attribution
(MR-000 · MR-002 · MR-060 · MR-057/059 · MR-063 · MR-035/056) und 65 nicht betroffene aus;
**kein Ausgang *widerspricht*/*Bezug ist entfallen**. Stichprobe — 3 von 6 Einheiten gegen den
Volltext am neuen Tag nachgelesen:

- **MR-000:** `LH-RB-*` steht im ID-Schema des Regelwerks
  (`v6.13.0/regelwerk/grundlagen-source-precedence.md:165`), und die Segment-Aussagen
  (`:279`, `:338`, `:348`: `LH-*`/`SPEC-*`/`ARC-*` ohne, ADR/Carveout mit Bereichssegment) sind
  unverändert — die Aussage des Eintrags bleibt wahr, die Stichprobe im Freshness-Report
  (Kennungs-Grep → 0) an unserem Bestand nachvollzogen.
- **MR-060:** die Baseline trägt die Doctrine selbst —
  `v6.13.0/regelwerk/modul-04-adrs.md:61` §Nachzug ist keine Überschreibung, `:74`
  Template-Feld-Nachzug.
- **MR-063:** dieselbe Datei, `:41-46` — die Aufnahme eines bestehenden Wächters in `make gates`
  ist als ADR-Anlass-Fehlannahme ausdrücklich ausgenommen.

Stützung durch die Symlink-Module (in jedem Claude-Lauf im Kontext, [MR-035](../../harness/conventions.md#mr-035--der-automatische-claude-kontext-trägt-eine-benannte-geschlossene-modul-auswahl)):
`modul-05` (WIP-Limit **pro Lauf**) und `modul-06` (Bestands-Lese-Schritt, `modul-06-roadmap.md:231`)
— die Zuordnung von MR-035/056 im Freshness-Report deckungsgleich mit dem Volltext. Die
Delta-Inventur je Release (Partition v6.10.0–v6.13.0, thematische Zuordnung der 27 Dateien) ist
im Übergabe-Artefakt dokumentiert; die Klone-Zahlen des Plans (13 Commits, 27 Dateien, 0 neu/0
entfallen) stimmen mit der Tausch-Commit-Sicht zusammen (57 Dateien inkl. Rename-Paare, 2 A, 2 D
— 55 neue Baum-Dateien, 55 entfallene).

## DoD 3 — Vorlagen-Bericht

`docs/migrations/v6.13.0.md` liegt vor und hält die Form aus
[`harness/migration.md`](../../harness/migration.md) §5:

- **Je Vorlage eine Zeile:** Buchstabe a — 15 Zeilen (25 abzüglich 9 wiederkehrende, abzüglich 1
  offene), Ausgänge aus der geschlossenen Menge; Buchstabe b — 9 Zeilen append-only mit
  Sprung-Datum 2026-09-29. `find … -name '*.template.md' | wc -l` → 25, nachgemessen.
- **Delta am Tausch-Commit gemessen** (Register `delta-messung-trifft-den-quelltext-statt-den-vendorten-baum`):
  das Report-Kommando (`git diff -M --numstat ad5b56d6^ ad5b56d6 -- …/templates …`) von mir
  nachgefahren → **8 Vorlagen mit Delta**, byte-gleich den 8 Tabellenzeilen.
- **Instanz-Abschnitt als Ist-Maßstab** ([`ADR-0018`](../plan/adr/0018-ziel-fassung-regiert-die-migration.md)
  Festlegung 2) — deklariert im Abschnitt *Bestehende Instanzen*, nicht als Prozedur-Schritt.
- Beleg der *schon erfüllt*-Zeile nachgemessen:
  `grep -rl 'Regeln dieser Datei' harness/sensors/ | wc -l` → **0**.
- **Kein `ausstehend` mehr** (`grep -c ausstehend docs/migrations/v6.13.0.md` → 0): die vier
  Instanz-Gruppen sind im Architect-Commit `3ef54b82` zugeordnet (21+/17−, nur diese Datei).

## DoD 4 — `make gates`

Stempel `.harness/state/gates-passed.diffsha` = `d4359639…`,
`bash harness/tools/working-tree-hash.sh` über HEAD `3ef54b82` → **dieselbe Hash-Zeile**. Der
Stempel deckt den Liefer-Stand inklusive der Review- und Architect-Commits bis `3ef54b82`.

## DoD 5 — `make full-smoke`

**Der übergebene Beleg hielt der Prüfung nicht stand:** das vorgefundene Protokoll
(`/tmp/full-smoke.log`) stammt vom **2026-09-23** und zeigt in allen neun `baseline-verify`-Zeilen
`v6.9.0 OK` — ein Alt-Log aus dem Vorgänger-Slice, kein Beleg für diesen Stand. Ich habe
`make full-smoke` deshalb **selbst gefahren** (2026-09-29, Protokoll
`/tmp/full-smoke-verify-20260929.log`): EXIT **0**, `full-smoke: OK` in 25 Stufen-Zeilen, und
**alle neun** `baseline-verify:`-Zeilen des Laufs — einschließlich der letzten Smoke-Stufe
(`selbstpruefung` im gebootstrappten Ziel) — melden
`baseline-verify: v6.13.0 OK — 54 Dateien (Integritaet + Vollstaendigkeit, netzlos)`. Der
emittierte Stand erbt `v6.13.0` über den Mess-Tag/Pin, gemessen am gebootstrappten Ziel.

## DoD 6 — Review-Report und seine Merge-Blocker

Report liegt vor (`docs/reviews/2026-09-29-slice-sprung-auf-v6130-wird-vollzogen.md`, 2 HIGH +
2 MEDIUM + 1 INFO). Je Befund der Auflösungs-Commit:

- **HIGH-1** (`Stand:`-Feld §Baseline) → `9b10fda9`:
  `harness/conventions.md:11` — `**Stand:** v6.13.0 — Zielstand-Setzung vollzogen am
  2026-09-29; Delta-Nachweis in slice-sprung-auf-v6130-wird-vollzogen; regierende Fassung:
  ADR-0072` (Zustandsfeld mit auflösbarem Anker, keine Chronik im Feld selbst).
- **HIGH-2** (Sprung-Zeile + Präsens-Aussage) → `9b10fda9`:
  `harness/migration.md:51` — `| v6.9.0 → v6.13.0 (vollzogen) | Ziel-Fassung v6.13.0 | ADR-0072 |`;
  `:59` — `Der aktuell vendored Stand ist v6.13.0`.
- **MEDIUM Register-Zuordnung** → `3ef54b82` (migrations-Report, 0 × „ausstehend“, s. DoD 3).
- **MEDIUM Rollen-Zuschnitt reviewer.md** → Commit-Split `9565beb4` (Rolle Reviewer, allein
  `.harness/skills/reviewer.md`, 2 Links) — gegen den Baum geprüft: der Architect-Commit
  `9b10fda9` enthält die Datei nicht mehr.
- **INFO ADR-0061** (Nachzug im Implementer-Commit) — Zuordnungs-Lücke des Plans, vom Reviewer
  als Beobachtung geführt; kein Merge-Blocker, keine DoD-Zusage berührt.
- `f758e6c0` (Rolle Reviewer) behebt die docs-check-Befunde im Report-Text selbst.

## DoD 7 — Doku-Update

Architect-Commit `9b10fda9` (Message nennt Rolle und Kennung):
`harness/conventions.md` §Baseline (Drei-Teil-Form [`ADR-0031`](../plan/adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md)
Festlegung 2) und §Adoptierte Konventions-Quellen; `harness/migration.md` Sprung-Zeile und
Präsens-Absatz; `spec/lastenheft.md` §4 („… und Randbedingungen“, Form-Nachzug der Vorlage,
[v6.11.0]) und die `LH-RB`-Erweiterung der Anforderungs-Bindung in `AGENTS.md`/`harness/README.md`
— die drei *übernommen*-Umschriften aus dem migrations-Bericht, genau an der vom Plan §2
zugewiesenen Stelle. Register-Zuordnung separat in `3ef54b82`.

## Plan-vs-Code

- **Gebaut ohne Plan:** nichts außerhalb der §3-Tabelle sichtbar; die `spec/lastenheft.md`- und
  `AGENTS.md`-Änderungen sind die geplanten Instanz-Umschriften (Liefer-Punkt 3.3, Buchstabe a),
  nicht Zusatzumfang. Der emittierte Inhalt ist auf den Mess-Tag beschränkt (Out-of-Scope-Grenze
  §1 gehalten — `internal/` trägt keinen alten Tag mehr).
- **Geplant ohne Baum:** die Rückführung (b)-Lage des Plans (Register-Zuordnung vor LP 3.3) wurde
  im Vollzug zur Reihenfolge Tausch → Review → Architect-Buchung `3ef54b82` aufgelöst; der Plan
  verlangt die Zuordnung „nach dem Tausch-Commit und vor Liefer-Punkt 3.3“ — die Zuordnung liegt
  nach der migrations-Report-Erstellung, aber vor der Closure; der Review-Report (MEDIUM 3) hatte
  sie als Closure-Blocker geführt, und sie ist durch `3ef54b82` geräumt.

## Bewusstes Brechen (Modul 11) — zusammengefasst

| Wächter | Mutation (Kopie, nicht Baum) | Ergebnis |
|---|---|---|
| `TestInventurMessTag_IstDerGefetchteStand` | `InventurMessTag` → `v6.9.0` | rot, Meldung: `Mess-Stand der Inventur "v6.9.0" != gefetchter Baseline-Tag "v6.13.0" — die Zuordnung ist gegen einen anderen Baum gemessen, als das Ziel bekommt` (`baumaussage_test.go:20`) — behauptete Ursache = gemutete Stelle |
| `TestDefaultTag_MatchesBaseline` | `DefaultTag` → `v6.9.0` | rot, Meldung: `fetch.DefaultTag "v6.9.0" != Makefile BASELINE_TAG "v6.13.0" (Drift bei Re-Baseline)` (`fetch_test.go:18`) |

Beide Mutationen in `git worktree`-Kopien gefahren und verworfen; der Arbeitsbaum blieb clean
(`git status --porcelain` → 0 Zeilen).

## Verbleibende Lücken

1. **`make regelwerk-check` (Netz) nicht neu gefahren** — die Pin→Asset-Hälfte der
   Provenienz-Kette beruht hier auf dem Dreifach-Beleg des Übergabe-Artefakts (Asset-Download,
   GitHub-Digest, Release-SHA256SUMS), nicht auf einem eigenen Netzlauf des Verifiers.
2. **Freshness: Volltext-Nachlesung nur stichprobenartig** — 3 von 6 betroffenen Einheiten am
   Regelwerk geprüft; die 65 nicht-betroffenen Einträge beruhen auf der Lesung des
   Übergabe-Laufs (gemeinsamer Befund „keine der 19 Dateien regelt den Eintrags-Gegenstand“).
3. **full-smoke belegt den Stand zum Laufzeitpunkt** — der Alt-Log-Fall zeigt, dass die
   Behauptung ohne frischen Lauf wertlos ist; der Träger ist der Lauf selbst (Stop-Hook/CI
   decken die Wiederholung), nicht das Log.
4. **Rollen-Zuschnitt von Commits liest kein Gate** (§3.8-Lücke, vom Review bestätigt) — die
   Prüfung von `9565beb4`/`9b10fda9` ist `git show --stat`-Lesung, keine Maschinelle.
5. Nicht Gegenstand dieses Reports: Closure-Notiz §7, Register-Fortschreibung, Risiko-Ausgänge
   §6, DoD-Häkchen, `git mv` — Planner-Arbeit.
