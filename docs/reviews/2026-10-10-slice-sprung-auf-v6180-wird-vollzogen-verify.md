# Verifikation slice-sprung-auf-v6180-wird-vollzogen (HEAD e5a3000b)

Rolle Verifier. Frage: bauen wir es richtig, gegen Plan und DoD.

## Verdikte je DoD-Punkt

- **1 Traeger auf v6.18.0 — bestaetigt.**
  - `make baseline-verify` -> `v6.18.0 OK — 54 Dateien`; `ls .harness/baseline` -> nur `v6.18.0`.
  - Fuenf Pins gemessen: Makefile (`BASELINE_TAG`, `BASELINE_ZIP_SHA256` 18e5443b...), `.d-check.yml` sources-Paar, `DefaultTag`/`DefaultBaselineSHA256` in `internal/fetch/baseline.go`, `InventurMessTag` — alle `v6.18.0`, sha identisch.
  - Symlinks: 7 auf `baseline/v6.18.0`, 0 auf anderen Stand. Link-Kommando aus §1: 0; Inline-Pfade: 1 (nur die Plan-Tabelle des Slice selbst, §3, Zustandsangabe „entfernt").
  - Nicht gelesen: `make regelwerk-check` (Netz) — Beleg im Tausch-Commit nicht nachgemessen.
  - **Rot-Beleg selbst gefahren:** `BASELINE_TAG ?= v6.17.0` im Makefile gesetzt, `make test` -> `not ok 424 sources-url in .d-check.yml traegt den aktuellen BASELINE_TAG (Kopplung, MR-013)` (test/sources-pin.bats:28). Zurueckgesetzt (`git checkout`).
- **2 Dogfood folgt dem Delta — bestaetigt.** `.harness/skills/reviewer.md:200` nennt `docs/reviews/<YYYY-MM-DD>-<slice-Kennung>.md` mit voller Kennung; `harness/README.md` nennt die Review-Deckung ausdruecklich nicht aktiv, mit Grund (Zeilen 232-244, ADR-0091 F3); `make gates` (inkl. docs-check) EXIT 0.
- **3 Emission folgt dem Delta — bestaetigt, mit Luecke (F-2).**
  - `internal/emit/templates/d-check.yml`: `reviews` bleibt Kommentar-Block, vier neue Schluessel + `match: name`.
  - Go-Test `TestDCheckConfig_ReviewsBleibtKommentarBlock` prueft jeden Schluessel einzeln; Stufe `review_vorlagen_im_ziel` in `full-smoke.sh` prueft Text im Ziel (aus, fuenf Zeilen, Report- und README-Vorlage im Baum).
  - **Rot-Beleg selbst gefahren:** Zeile `#   skip-allows-empty: true` aus der Vorlage entfernt, `make test` -> `--- FAIL: TestDCheckConfig_ReviewsBleibtKommentarBlock … emit_test.go:629: Kommentar-Block reviews traegt "#   skip-allows-empty: true" nicht`. Zurueckgesetzt.
  - `make full-smoke` -> EXIT 0; Zeile `Review-Deckung im Ziel (--lang go) — reviews aus, Kommentar-Block mit den fuenf Schluesseln …`. `make e2e-abdeckung` erzeugt nichts Neues (Arbeitsbaum sauber).
- **`make gates` einmal am Ende:** EXIT 0, Arbeitsbaum danach sauber.
- **`make full-smoke`:** EXIT 0 (Mess-Aufruf ueber `make`).
- **Review durchgefuehrt, Report liegt vor — nicht bestaetigt (F-1).**
- **A1–A3 als eigene Architect-Commits — bestaetigt:** ADR-0091 `Accepted`; 4a617506, 32bbd041, ed76b475 (Adress-Nachzug, Buchung, Freshness-Verdikt) tragen Rolle Architect.
- Closure, Register, Risiko-Ausgaenge: Planner-Arbeit, nicht geprueft.

## Mutations-Ergebnis (CI-Branch)

`git show FETCH_HEAD:mutate-ergebnis.txt` von `mutate/slice-sprung-auf-v6180-wird-vollzogen-e5a3000b`: geprueft e5a3000b4ce68bbf…, Basis 458e0836, 10 Shards alle Exit 0, `Fallmenge: 140 (Slice: 140)`, 140 `ok`-Zeilen, Wanduhr 1678 s, Urteil gruen. Geprueft-Commit = verifizierter HEAD. Beide Branches (`…-e5a3000b`, `…-f3bc1d30`) geloescht; `git ls-remote` danach leer.

## Findings

- **F-1 (offen, Planner):** unter `docs/reviews/` liegt kein Review-Report zum Slice (`ls docs/reviews | grep -i sprung` nennt nur v6160/v6170-Dateien; kein `…-slice-sprung-auf-v6180-wird-vollzogen*`). Der Reviewer-Commit 693b05bd aendert nur den Skill. DoD-Punkt „Report liegt vor" und Closure-Trigger 2 sind damit offen; ob der Review gelaufen ist, belegt nichts im Baum.
- **F-2 (Zusage breiter als Sensor, AGENTS.md §3.6):** die vier neuen Schluessel (`require-promises`, `recursive`, `skip-pattern`, `skip-allows-empty`) haben keinen Fall in `test/mutations/`; die Faelle 666/667 binden nur Pin-Prosa und `match: name`. Die DoD verlangt fuer „auskommentiert halten" einen Mutationsfall; gedeckt ist es durch Go-Test und full-smoke-Stufe (oben rot gesehen), aber `make mutate` ueberwacht deren Haltbarkeit fuer die vier Schluessel nicht. Kein Blocker; Folge-Fall oder benannte Grenze.
- **F-3 (Grenze, bekannt):** Emission ist am Text gemessen; dass ein aktivierter Block im Ziel greift, misst keine Stufe (Kopfkommentar der Stufe benennt es, ADR-0091 F2).
- Plan-vs-Code: Diff stimmt mit §3-Tabelle ueberein; Gebautes ohne Plan nicht gefunden (`harness/migration.md` Sprung-Zeile = A3). Stichprobe, nicht den ganzen 111-Dateien-Diff gelesen.

## Empfehlung

Verdikt: DoD 1–3 und Gates bestaetigt; Closure erst nach F-1 (Review-Report) — Entscheidung beim Planner.
