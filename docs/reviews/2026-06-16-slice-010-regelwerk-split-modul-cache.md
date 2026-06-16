# Review-Report: slice-010-regelwerk-split-modul-cache — 2026-06-16

**Review-Art:** Code — geprüft gegen Slice-Plan, `AGENTS.md` (Hard Rules),
`harness/conventions.md` ([`MR-004`](../../harness/conventions.md#mr-004--sessionstart-regelwerk-injektor)/[`MR-006`](../../harness/conventions.md#mr-006--regelwerk-cache-als-split-modul-verzeichnis)) und die Regelwerk-Prinzipien
(Modul 10/13: keine Harness-Lüge, Source Precedence, ehrliche Grenz-Benennung).

**Gegenstand:** Working-Tree-Diff slice-010 (AGENTS.md, CLAUDE.md, Makefile,
harness/conventions.md, harness/tools/sessionstart-inject-regelwerk.sh,
test/sessionstart.bats, docs/plan/planning/open/slice-009-…, neue Slice-Datei).

**Reviewer:** unabhängiger `code-reviewer`-Agent (Agent-Tool, kein Selbst-Review). <!-- d-check:ignore (Agent-Lauf, kein versionierter Skill-Pfad) -->
**Datum:** 2026-06-16.

**Eingangs-Kontext** (Verträge, gegen die geprüft wurde):

- Slice-Plan [`docs/plan/planning/done/slice-010-regelwerk-split-modul-cache.md`](../plan/planning/done/slice-010-regelwerk-split-modul-cache.md)
- aktive Konvention [`MR-004`](../../harness/conventions.md#mr-004--sessionstart-regelwerk-injektor) / neue [`MR-006`](../../harness/conventions.md#mr-006--regelwerk-cache-als-split-modul-verzeichnis) in [`harness/conventions.md`](../../harness/conventions.md)
- berührte LH-IDs: [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (Reproduzierbarkeit), [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (minimale Abhängigkeiten)
- `AGENTS.md` (Hard Rules)

> Gates waren vor dem Review grün (`docs-check`/`test`/`shell-lint`); geprüft wurde
> bewusst das, was die Gates **nicht** sehen (Semantik, Doku-Wahrheit, Race/Grenzen).

---

## Findings

### F-1 — MR-004-Body liest als aktuelle Mechanik; Vorwärtsverweis stand zu spät

- `kategorie`: MEDIUM
- `quelle`: Maintainability / Doku-Wahrheit (Entropy Management)
- `pfad`: `harness/conventions.md` ([`MR-004`](../../harness/conventions.md#mr-004--sessionstart-regelwerk-injektor)-Block)
- `befund`: Der Adaptionsblock beschreibt im Präsens die alte Mechanik (Codex „im
  Volltext", Einzeldatei `.harness/cache/agents-regelwerk.md`); der
  Korrektur-Spiegelstrich stand erst am Block-Ende. Ein per Anker einsteigender
  Leser liest die überholte Mechanik als gültig.
- `behebung`: Blockquote-Hinweis „**Teilweise überholt seit slice-010 → [`MR-006`](../../harness/conventions.md#mr-006--regelwerk-cache-als-split-modul-verzeichnis)**;
  Body ist Historie" **direkt unter** die Überschrift gesetzt.
- `verifizierbar`: teils — `docs-check` bestätigt die Link-/Anker-Auflösung; die
  Rahmung als Historie ist eine inhaltliche Prüfung.

### F-2 — bats-Coverage-Lücke: Verzeichnis vorhanden, aber `README.md` fehlt

- `kategorie`: LOW
- `quelle`: Behaviour-Harness (Test-Coverage)
- `pfad`: `test/sessionstart.bats`
- `befund`: Getestet waren „voller Index + Modul" und „kein Verzeichnis". Der
  Teil-Fetch-/Korruptionsfall „Verzeichnis da, `README.md` fehlt" trifft denselben
  `[ ! -f "$index" ]`-Pfad, war aber nicht separat fixiert.
- `behebung`: dritter Injektor-Test ergänzt (Verzeichnis ohne `README.md` → WARN +
  exit 0). Suite jetzt 37/37.
- `verifizierbar`: ja — `make test`.

### F-3 — „atomar" überspitzt (nur das `mv` ist atomar, nicht das Replace)

- `kategorie`: LOW
- `quelle`: Regelwerk „Grenzen ehrlich benennen" (Durchsetzungsschicht §Grenzen)
- `pfad`: `Makefile` (regelwerk-fetch-Kommentar), `harness/conventions.md`
  ([`MR-006`](../../harness/conventions.md#mr-006--regelwerk-cache-als-split-modul-verzeichnis)), Slice-Datei (§2/§3/§7)
- `befund`: Pin-vor-Mutation macht Fehler/Drift sicher (Cache unverändert,
  verifiziert). Aber zwischen `rm -rf CACHE` und `mv tmpd CACHE` besteht ein
  kurzes Fenster ohne Cache; „entpackt atomar" überschreibt diese Grenze.
- `behebung`: Wording präzisiert auf „Replace via temp→`mv` (`mv` atomar,
  Gesamt-Replace nicht); Cache gitignored/regenerierbar". Kein Code-Risiko
  (regenerierbar, fail-visible über den Injektor).
- `verifizierbar`: nein — Wording/Semantik.

### F-4 — `find … -maxdepth 1 -type f | wc -l` zählt nur Top-Level

- `kategorie`: INFO
- `quelle`: Maintainability
- `pfad`: `Makefile` (Erfolgsmeldung regelwerk-fetch)
- `befund`: Die Datei-Zählung berücksichtigt nur die oberste Ebene; aktuell korrekt
  (ZIP entpackt flach, 21 Dateien real verifiziert), bei künftigen
  Unterverzeichnissen zu niedrig.
- `behebung`: keine — bewusste Annahme (flaches ZIP), nur kosmetisch.
- `verifizierbar`: ja — `make regelwerk-fetch` (zeigt „21 Dateien").

## Negativbefunde (geprüft, ohne Befund)

- geprüft, ohne Befund: `regelwerk-fetch` — sha256-Verify **vor** jeder
  Cache-Mutation; mktemp-Template same-fs (`mv` = echter Rename, kein Cross-Device);
  Cleanup-`||`-Zweig räumt temp; Fehler/Drift lassen Cache unverändert.
- geprüft, ohne Befund: Injektor — `set -euo pipefail` + `$( { …; cat; } | awk )`
  + `if !` fängt awk-Crash **und** `cat`-Fehler ab (kein stilles Leer-Emit);
  Pointer-Präfix steuert korrekt zum On-demand-Lesen, behauptet keinen Volltext.
- geprüft, ohne Befund: Harness-Prinzipien — keine Harness-Lüge (ZIP = wortgleiche
  Kurs-Sicht, kein Eigen-Digest); kein halluziniertes Gate (`regelwerk-fetch` nicht
  in `gates`); Source Precedence respektiert; MR-statt-ADR vertretbar begründet.
- geprüft, ohne Befund: Doku-Konsistenz — `CLAUDE.md`/`AGENTS.md` §1 konsistent auf
  Verzeichnis + Index + on-demand; keine falschen aktuellen Volltext-Behauptungen
  außerhalb des (behobenen) [`MR-004`](../../harness/conventions.md#mr-004--sessionstart-regelwerk-injektor)-Body-Punkts; Tradeoff ehrlich benannt.

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 1 |
| LOW | 2 |
| INFO | 1 |

## Verdikt

**Ausgangs-Verdikt:** APPROVE-WITH-NITS. **Merge-blockierend:** nein — kein HIGH;
das eine MEDIUM ist eine nicht-blockierende Doku-Falle. Alle vier Findings (MEDIUM,
2× LOW, INFO-Annahme dokumentiert) wurden **im selben Lauf behoben** und mit
`make gates` (grün) gegengeprüft. Damit erfüllt der Slice den Closure-Trigger §5
„Review konform". Verifikation der DoD/Spec bleibt separat (Verifier, Modul 11).

> **Config-Beobachtung (nachträglich aufgelöst):** Unter d-check **≤ v0.9.0**
> unterdrückte `exempt-paths` (`docs/reviews/**`) den `id-unlinked`-Check für
> `docs/reviews/`-Dateien **nicht** — ein **bestätigter d-check-Bug** (kein
> Glob-Syntaxfehler: auch exakte Pfade matchten nicht; v0.8.0 ≡ v0.9.0). Deshalb
> sind die IDs in diesem Report manuell verlinkt (Workaround). **Behoben in
> d-check v0.10.0**: `docs/reviews/**` exemptet Review-Reports nun korrekt vom
> Link-Zwang (empirisch verifiziert).
