# Verifikation — slice-lauf-meldet-neue-werkzeug-targets

* Rolle: Verifier (Modul 11), an den Planner
* Gegenstand: Commits `5cd2470d` und `34d425cb` gegen die DoD des Slice-Plans (`in-progress/`),
  [`ADR-0080`](../plan/adr/0080-anwender-targets-leben-in-repo-mk-ausserhalb-von-harness-mk.md),
  `LH-QA-01`, `LH-FA-01`; Review-Report `2026-10-07-werkzeug-meldung-review.md`
* Datum: 2026-10-07
* Brüche liefen in einer Kopie unter dem Scratchpad (`git archive HEAD`), nicht im Repo.

## Verdikte je Liefer-DoD-Punkt

- **1 — Meldung im Lauf: bedingt.**
  - Bestätigt: Bootstrap und `add-lang` lesen den Teil vor dem Schreiben und melden. Die Zeile
    `NEUES GATE` steht unter Go-Test für **beide** Aufrufer. Bruch 532 (Zeile gelöscht), `make test-go`
    → EXIT 2, `TestRun_AddLangMeldetNeueTargets`: `stdout nennt das neue Gate lint-apps-web nicht`
    (ebenso build-/test-apps-web), `TestRun_BootstrapMeldetNeueTargets`: `… das neue Gate lint nicht`
    (build, test). Bruch 534 (Bootstrap verwirft den Bericht) → EXIT 2, allein
    `TestRun_BootstrapMeldetNeueTargets`, mit Namen. Damit ist der Befund F-1 des Reviews geschlossen.
  - **Nicht unter Go-Test: die Zeile `neues Target: make <t> (kein Gate)`.** Bruch: die Fprintf-Zeile
    gelöscht, `make test-go` → **EXIT 0**. Diese Zeile hält allein die full-smoke-Stufe, und die gehört
    nicht zu `make gates`. Gegenprobe an der realen Quelle: derselbe Bruch, `make full-smoke` → EXIT 2,
    `FEHLER — Werkzeug-Meldung: der Re-Lauf nennt probe-werkzeug nicht als neues Target ohne Gate`.
    Damit trägt die DoD-Zusage „je neu hinzugekommenem Target eine Zeile … Ein Go-Test hält das“ für
    die Hälfte ohne Gate nur ein E2E-Lauf außerhalb des Gates. Offener Punkt für den Planner.
  - Attrappen-Grenze: `TestRun_BootstrapMeldetNeueTargets` ersetzt nur `d-check --print-mk` durch die
    Roh-Ausgabe aus `internal/emit/testdata/raw-print-mk.txt`. Adaption, `WerkzeugIndex` und Meldung
    laufen real. Was das echte Image liefert, deckt der Test nicht. Das deckt nur `make full-smoke`,
    das den Träger mit `initSources()` fährt.
- **2 — E2E: bestätigt.** `make full-smoke` → EXIT 0 (196 s). Die Stufe `werkzeug_meldung_im_ziel`
  gibt die Zahlen-Zeile aus (`24 Targets, davon 1 in der Gate-Tabelle`). Danach meldet sie
  `>>> NEUES GATE` für `build-/lint-/test-apps-api` und `3 neue Zeile(n) … das Doku-Gate meldet sie
  nicht`, dann `neues Target: make probe-werkzeug (kein Gate)`, `docs-check` mit `0 Befund(e)`, und
  der Re-Lauf ohne Änderung nennt kein Target. Die Deklaration (`full-smoke.sh` Zeile 3800) nennt die
  Grenze: `make gates`, ein entfallenes Target, cpp, `--arch`. Rot an der realen Quelle, siehe Punkt 1.
- **3 — Handbuch: bestätigt.** Der Absatz „Neue Targets des Werkzeugs nennt der Lauf“
  (`benutzerhandbuch.md`) gibt die beiden Zeilentexte wörtlich wie der Code wieder. Er nennt die
  Hervorhebung, sagt, dass das Doku-Gate solche Targets nicht meldet und `docs-check` grün bleibt, und
  führt den Erstlauf, `gate-phantom` und die Umbenennung.
- **`make gates`: bestätigt.** Siehe Kommandos.

## Prüfpunkt PrintMK

- Den realen Pfad ändert der Parameter nicht. `DocGate` hat genau einen Aufrufer (`main.go:580`, über
  `emitAll`). `initSources()` setzt `docMK: emit.DockerPrintMK`, und das ist ein Durchreicher auf
  dasselbe `printMK`, das `DocGate` vorher direkt rief (`archgate.go:96`). Kein Nicht-Test-Literal
  `sources{}` lässt `docMK` leer. Der Test-Default `testSources` setzt ebenfalls `DockerPrintMK`. Im
  Lauf belegt: full-smoke bootstrappt mit dem echten Träger, und `docs-check` im Ziel läuft grün.

## Plan-vs-Code

- **Gebaut ohne Plan:** `internal/emit/emit.go` (Signatur `DocGate`, aus `34d425cb`) und
  `test/mutations/532–534` stehen nicht in §3. Das trifft
  `plan-abweichung-landet-im-commit-bericht-statt-im-plan`, das §8 des Plans selbst nennt.
  Offener Punkt für den Planner, der Nachtrag in §3 gehört ihm.
- **Geplant und nicht gebaut:** nichts. Alle Zeilen aus §3 sind im Diff.
- **Code über den DoD-Wortlaut hinaus:** Ein Wechsel von `kein Gate` zur Gate-Tabelle wird als
  `NEUES GATE` gemeldet (Review F-2). Plan §1 deckt das ab.

## Kommandos

| Kommando | Ausgabe |
|---|---|
| `make mutate MUTATE_CASES="532-… 533-… 534-…"` | `mutate: 3 ok, 0 Befund(e)`, EXIT 0 |
| Kopie: 532 angewandt, `make test-go` | EXIT 2, Meldungen wie unter Punkt 1 |
| Kopie: 534 angewandt, `make test-go` | EXIT 2, nur `TestRun_BootstrapMeldetNeueTargets` |
| Kopie: Zeile `neues Target … (kein Gate)` gelöscht, `make test-go` | **EXIT 0** |
| Kopie: dieselbe Löschung, `make full-smoke` | EXIT 2, `FEHLER — Werkzeug-Meldung: der Re-Lauf nennt probe-werkzeug nicht …` |
| `make full-smoke` (Repo) | EXIT 0 |
| `make gates` (Repo, mit diesem Bericht) | EXIT 0 |

## Offene Punkte für den Planner

- DoD 1, Teil ohne Gate: Die Zeile `(kein Gate)` hält kein Test in `make gates`. Zur Wahl stehen ein
  Go-Fall, der eine eigene Datei unter `harness/mk/` vor dem Re-Lauf ablegt, oder eine Einschränkung
  der Zusage.
- §3 um `internal/emit/emit.go` und `test/mutations/532–534` ergänzen.
- Review F-3 (ein Erstlauf in einem Alt-Ziel hebt kein Gate hervor) und die zwei Risiken aus §6:
  Ihr Ausgang wird bei der Closure entschieden.

## Negativbefunde

- Vergleich alt/neu und Erstlauf: Bruch 533 wird rot, ohne Befund.
- Fehlerpfad: Ein unlesbarer Teil bricht mit Exit 1 ab. Gelesen, nicht gefahren.
