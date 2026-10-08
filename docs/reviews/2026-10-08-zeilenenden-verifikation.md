# Verifikation: slice-zeilenenden-meldungstest-bindet-das-verzeichnis — 2026-10-08

**Rolle:** Verifier (Modul 11) · **Modell:** claude-opus-5-5 · **Datum:** 2026-10-08

**Gegenstand:** `e5ab0209`, `83eca5a8` (Stand `HEAD` = `83eca5a8`) gegen §2 DoD und §3 Plan des Slice;
`ADR-0067` Festlegung 3 und 4, `MR-071`, `AGENTS.md` §3.6. Review-Report
`2026-10-08-zeilenenden-review.md` (0/0/1, LOW F-1 in `83eca5a8` behoben).

**Messweg:** alle Sonden in Scratchpad-Kopien per `git archive HEAD`, Host-Baum unberührt; je Sonde
`make test-go`. `make gates` einmal am Ende (Stempel deckte den Arbeits-Commit nicht).

## Verdikte je DoD-Punkt

- **Liefer-Punkt 1 — die Assertion bindet das Verzeichnis: bestätigt.**
  - Code: `rest := zeile[strings.Index(zeile, rel)+len(rel):]`; drei Zeichenketten per `Contains` in
    `rest`, das Verzeichnis `path.Dir(rel)+"/"` über `zeilenendenNenntVerzeichnis(rest, verz)`
    (Wortgrenze: Anfang, Leerzeichen, Backtick). Erwartung aus `skip`, nicht aus der Meldung.
  - Rot an `HEAD` unter Mutation 586 und 587 (Treiber, unten). Gelesene Meldung 587:
    `zeilenenden_test.go:321: die Meldung zu harness/mk/.gitattributes nennt das Verzeichnis "harness/mk/" hinter dem Pfad nicht als eigenes Wort …`
    mit Meldungszeile `… tragen die Dateien in tools/harness/mk/ im Klon …` — trägt die behauptete
    Ursache; `--- FAIL:` genau 1×.
  - Vorzustand grün: nicht neu gefahren; der Review hat ihn gemessen (Test von `e5ab0209~1`, Mutation 586,
    `make test-go` EXIT 0) — Stichprobe übernommen, im Report des Reviews mit Kommando.
  - Kommentare: Doc-Kommentar nennt 586 und 587 unter den Rot-Gegenbeispielen und sagt „im Text hinter
    dem Pfad"; Helfer-Kommentar nennt die Wortgrenze und ihr Gegenbeispiel. Deckt sich mit dem Code.
- **Liefer-Punkt 2 — Fall mit Gegenprobe: bestätigt** (für 586 und 587).
  - Kopf: beide `100755` (`git ls-files -s`), `# files: internal/emit/zeilenenden.go`,
    `# expect: TestZeilenenden_BelegterPfadBleibtUndWirdGemeldet`. Nummer: `ls test/mutations | grep -oE '^[0-9]+' | sort -n | tail -3` → 585, 586, 587.
  - (a) Anker gegen Quell-Bestand: `grep -cF 'zeilenendenMeldung(".githooks")'` → 1,
    `grep -cF 'zeilenendenMeldung("harness/mk")'` → 1 (Zeilen 30 bzw. 28 von `internal/emit/zeilenenden.go`).
  - (b) Treiber: `make mutate MUTATE_CASES="446-… 447-… 448-… 449-… 450-… 451-… 586-zeilenenden-meldung-nennt-fremdes-verzeichnis 587-zeilenenden-meldung-nennt-verzeichnis-mit-praefix"`
    → `mutate: 8 ok, 0 Befund(e)`, EXIT 0, Prüfgegenstand `67d791e1…`, 1m0s.
  - (c) Gegenproben, je `make test-go`:

    | Sonde | Erwartung | Ergebnis |
    |---|---|---|
    | 587 angewandt, sonst nichts | rot | EXIT 2, ein `--- FAIL:` (der benannte Test) |
    | 587 + `t.Skip("gegenprobe")` nur im benannten Test | grün = kein anderer Test bindet mit | EXIT 0, `internal/emit` ok |
    | 587 + Wortgrenze entwaffnet (`zeilenendenNenntVerzeichnis` → `strings.Contains(rest, verz)`) | grün = die Wortgrenze bindet | EXIT 0 |
    | 586 + Aussage-Teil entwaffnet (`…NenntVerzeichnis(rest, …)` → `(zeile, …)`) | grün = der Aussage-Teil bindet | EXIT 0 |

    Die `t.Skip`-Gegenprobe für 586 hat der Review gefahren (EXIT 0) — nicht wiederholt.
  - (d) Bestehende Fälle 446–451 über den Treiber ok (Lauf unter (b)) — stärker als die im Plan
    verlangte Emulation.
- **Sonden je Zeichenkette (§3 Schritt 4, Grundlage von Risiko 1): nachgetragen, alle rot.** Je eine
  aus `zeilenendenMeldung` entfernt: `` `* text=auto eol=lf` `` → `nennt "* text=auto eol=lf" hinter dem Pfad nicht`;
  `core.autocrlf=true` → `nennt "core.autocrlf=true" …`; `CRLF` → `nennt "CRLF" …`; jeweils EXIT 2, ein
  `--- FAIL:` (der benannte Test). Risiko 1 hat damit den vorab benannten Ausgang *entfallen*.
- **`make gates` grün: bestätigt.** Der Stempel stand vor diesem Lauf auf `69db6a33`, nicht auf dem
  Arbeits-Commit; `make gates` am Stand `83eca5a8` (plus dieser unversionierte Bericht) → EXIT 0, 3m04s,
  danach `.harness/state/gates-passed.head` → `83eca5a8…`.
- **Review-Report liegt vor: bestätigt** (`2026-10-08-zeilenenden-review.md`).
- **Doku-Update entfällt: bestätigt** — `git show --stat e5ab0209 83eca5a8` berührt nur
  `internal/emit/zeilenenden_test.go` und `test/mutations/586-*`, `587-*`; kein Produktions-Code.
- Closure-Notiz, Register, Risiko-Ausgänge, Paarungen: Planner-Arbeit, nicht Gegenstand.

## Plan vs. Code

- **Gebaut ohne Plan:** Fall 587 und der Helfer `zeilenendenNenntVerzeichnis`. §3 nennt „neu (ein
  Fall)"; der zweite entstand aus Review-F-1 im selben Liefer-Punkt, keine Out-of-Scope-Grenze aus §1
  ist berührt. Für die Closure-Notiz (*Was ging anders als geplant*).
- **Geplant, gebaut:** Test-Update und Fall 586 wie §3; Produktions-Code unberührt wie §1.
- **Kennung:** `83eca5a8` trägt `LH-FA-01`, der Slice-Kopf führt `LH-QA-04`/`LH-FA-06`
  (`LH-FA-01` nur über die Welle). Kein Befund zum Verhalten; die Kennung löst über die Welle auf.

## Offene Punkte für Planner/Architect

- Risiko 3 (*Fall in keinem Vollauf*) ist mit dem Treiber-Teillauf oben teilweise bedient: Isolation
  und Fingerabdruck sind für 586/587 gemessen, ein Vollauf nicht.
- Keine Findings zu Bedeutung, Verhalten oder Zusage.
