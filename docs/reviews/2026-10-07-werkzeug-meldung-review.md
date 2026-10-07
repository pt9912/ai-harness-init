# Review — slice-lauf-meldet-neue-werkzeug-targets

* Rolle: Reviewer (Modul 10), `.harness/skills/reviewer.md`
* Gegenstand: Commit `5cd2470d` gegen den Slice-Plan (`in-progress/`),
  [`ADR-0080`](../plan/adr/0080-anwender-targets-leben-in-repo-mk-ausserhalb-von-harness-mk.md),
  Kurs `v6.16.0` `modul-13-quality-gates.md` §Hard Rule, [`AGENTS.md`](../../AGENTS.md) §3.6/§3.7
* Datum: 2026-10-07

## Findings

### F-1 — LOW — die Meldung im Bootstrap hält kein Test in `make gates`

- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6
- `pfad`: `cmd/ai-harness-init/main.go:561` (Aufruf `meldeWerkzeugIndex` in `bootstrap`); Kommentar
  `main.go:382-388` („Gehalten von TestRun_AddLangMeldetNeueTargets")
- `befund`: Der Test fährt nur `add-lang`. Wird der Aufruf im Bootstrap neutralisiert
  (`meldeWerkzeugIndex(stdout, bericht)` → `_ = bericht`), endet `make test-go` mit EXIT 0, alle Pakete
  `ok`. Diesen Aufrufort hält allein die full-smoke-Stufe `werkzeug_meldung_im_ziel`, und die gehört
  nicht zu `make gates`. Failure-Szenario: Eine Umstellung des Bootstrap verliert die Meldung,
  `make gates` bleibt grün, und erst der CI-Lauf von `full-smoke` fällt. Die DoD-Zusage 1 („Bootstrap
  und `add-lang` … Ein Go-Test hält das") geht als Prüfpunkt an die Verifikation.
- `verifizierbar`: ja — Probe unten, `make full-smoke`
- `klasse`: Zusage über zwei Aufrufer, Test fährt einen

### F-2 — INFO — der Wechsel von `kein Gate` zu Gate wird als NEUES GATE gemeldet

- `quelle`: Slice-Plan §1 Ziel, Kurs `v6.16.0` Welle 159
- `pfad`: `internal/emit/werkzeugindex.go` `neueWerkzeugTargets`
- `befund`: Der DoD-Wortlaut nennt nur „neu hinzugekommene" Targets. Der Code meldet zusätzlich ein Target,
  das neu in der Gate-Tabelle steht. Das deckt Plan §1 („heben ein neues Gate hervor") und die
  Kurs-Bedingung („neues Gate in make gates"). Gebunden ist der Fall im Unit-Test
  (`record-gates` an `Neu[1]`), das Handbuch nennt ihn. Kein Befund.
- `verifizierbar`: ja — `TestWerkzeugIndex_BerichtNenntNeueTargets`
- `klasse`: —

### F-3 — INFO — der erste Lauf auf einem Ziel ohne Werkzeug-Teil hebt kein Gate hervor

- `quelle`: Kurs `v6.16.0` Welle 159 („besonders bei einem neuen Gate")
- `pfad`: `cmd/ai-harness-init/main.go` `meldeWerkzeugIndex` (Zweig `Erstlauf`)
- `befund`: Ein Ziel aus einer älteren Werkzeug-Fassung hat noch keinen
  `harness/mk/ai-harness-init.md`. Holt es mit dem ersten `add-lang` ein neues Gate, meldet der Lauf
  nur die Zahlen-Zeile. So legen es die DoD („beim ersten Lauf keine Einzelzeilen") und das Handbuch
  fest. Die Lücke ist benannt, aber nicht geschlossen. Zur Kenntnis für den Planner (Risiko-Ausgang §6).
- `verifizierbar`: nein
- `klasse`: —

## Kommandos und Ausgaben

| Kommando | Ausgabe |
|---|---|
| `make mutate MUTATE_CASES="532-lauf-meldet-neues-gate-nicht 533-werkzeug-index-bericht-immer-erstlauf"` | `mutate: 2 ok, 0 Befund(e)`, EXIT 0 |
| Gegenprobe 532 im Klon unter dem Scratchpad: Mutation angewandt, `t.Skip` nur in `TestRun_AddLangMeldetNeueTargets`, `make test-go` | EXIT 0, alle Pakete `ok` — der benannte Test bindet allein |
| Probe F-1 im Klon: Bootstrap-Aufruf → `_ = bericht`, `make test-go` | EXIT 0, alle Pakete `ok` |
| `make e2e-abdeckung`; `git status --short` | EXIT 0; leer — die Datei ist byte-gleich |
| `make gates` | EXIT 0 |

## Negativbefund je Schwerpunkt

- **(a) Vergleich alt/neu:** geprüft, ohne Befund. Der Erstlauf schreibt nur die Zahlen-Zeile, ein
  unveränderter Re-Lauf schreibt nichts (Unit-Test und full-smoke (e)), ein entfallenes Target wird
  nicht genannt. Wechselt ein Target aus dem README-Teil in den Werkzeug-Teil, nennt der Lauf es; die
  Zeile ist in der Datei tatsächlich neu, und das Handbuch sagt „zusätzlich führt". Ein Wechsel in die
  Gegenrichtung bleibt ungenannt. Eine Handänderung, die die Zeilenform bricht, führt zur Nennung des
  Targets; das Neuschreiben heilt sie. Ein unlesbarer Teil bricht mit Exit 1 und der Meldung `… lesen:`
  ab.
- **(b) Aufruf nach `emitAll`:** geprüft, ohne Befund. `emitAll` hat genau einen Aufrufer, und zwischen
  seinem Ende und `WerkzeugIndex` liegt kein Schritt. Der Pfad mit `--lang` gibt den Fehler von
  `wireLang` zurück wie zuvor, der Pfad ohne `--lang` schreibt den Teil weiter. `add-lang` ist bis auf
  die Meldung unverändert.
- **(c) Formulierung von „Gate":** geprüft, ohne Befund. Die Meldung sagt „neu in der Gate-Tabelle",
  nicht „läuft in make gates". Diese Grenze nennen der Funktionskommentar, die Deklaration der Stufe und
  das Handbuch.
- **(d) Tests, Mutationen, E2E:** 532 und 533 werden rot, die Gegenprobe zu 532 wird grün. Die Stufe
  `werkzeug_meldung_im_ziel` misst, was ihre Deklaration nennt: alle drei Targets des Go-Moduls (das
  Fragment bringt nur diese drei Gates mit), ein Target ohne Gate, `docs-check` mit `0 Befund(e)` und
  den Re-Lauf ohne Nennung. Ausnahmen in der Deklaration: `make gates`, ein entfallenes Target,
  cpp/--arch. Die Stufe wurde gelesen, nicht gefahren.
- **(e) Handbuch:** geprüft, ohne Befund. Zeilentexte, die Reihenfolge (Gates zuerst), die Zahlen-Zeile,
  die Grenzen und `gate-phantom` stimmen mit dem Code überein.
- **§3.7 Kommentare im Diff:** geprüft, ohne Befund. Die Kommentare tragen Zusage, Kopplung und Grenze,
  keine Chronik.
