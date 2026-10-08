# Review: Wächter `register-ausgang` — Eintrag über der 3×-Schwelle ohne Ausgang

**Rolle:** Reviewer (Modul 10), Skill `.harness/skills/reviewer.md` 2.3.0. **Datum:** 2026-10-08.
**Review-Art:** Code — gegen Plan und ADR, nicht gegen die DoD.
**Gegenstand:** Commits `2b1ed744`, `0eaf51f8`, `d0fc706a` (dazu Move `f560954d`/`d00a0098`, Roadmap
`bc229415`) gegen den Slice-Plan `slice-register-ueber-der-schwelle-bekommt-seinen-waechter`.
**Bezug:** [ADR-0069](../plan/adr/0069-beleglose-register-verzeichnisse-sind-ein-befund-der-paarung-keine-ausnahme.md),
[ADR-0049](../plan/adr/0049-ausgang-traegt-die-benannte-luecke.md),
[`docs/plan/planning/observations/README.md`](../plan/planning/observations/README.md),
[`AGENTS.md`](../../AGENTS.md) §3.1/§3.6/§3.7.

Laut Auftrag kein Finding: der Wächter steht nicht in `make gates`, und Liefer-Punkt (2) ist offen
(Übergabe an Planner und Architect). Bruchproben liefen in einer Kopie unter dem Scratchpad. Der Baum
blieb unberührt.

## Findings

### F-1 — MEDIUM: der Wächter meldet einen Zustand als Befund, den ADR-0049 erlaubt

- `quelle`: ADR-0049 Festlegung 3; `observations/README.md` (Absätze *„Der Lese-Schritt liest alle
  Einträge …"* und *„Zugewiesen wird der Ausgang vom Lese-Schritt …"*)
- `pfad`: `harness/tools/register-ausgang.sh:2-12`, `:56-61`; `harness/README.md` §Werkzeuge, Zeile
  `make register-ausgang`; `Makefile` Kommentar über `register-ausgang:`
- `befund`: Die Regel sagt: `offen` über der Schwelle ist **zwischen zwei Lese-Schritten zulässig und
  vorübergehend**. Erst danach ist es eine Vollzugs-Lücke. Der Wächter meldet jedes `offen` ab 3 Belegen
  ohne Bedingung als Befund. Sein Kopf nennt die Regel ohne die Übergangs-Klausel. Die Index-Zeile
  kündigt die Verdrahtung an, sobald der Bestand sauber ist. Dann wird `make gates` rot, sobald eine
  Slice-Closure einen dritten Beleg anlegt und die Welle-Closure noch aussteht. Dieses Repo fährt
  Wellen-Betrieb (Slice-Plan §2). Die Prüfung ist damit schärfer als die ADR (Baseline-Regelwerk
  `modul-11-verification.md` §Fitness Function ohne Standard-Tool: *„Ein Gate, das schärfer ist als
  seine ADR, ist genauso falsch"*). Plan §1 verlangt genau diese Schärfe. Ob der Plan oder die
  Prüfung nachzieht, entscheiden Planner und Architect. Der Implementer entscheidet es nicht.
- Beleg: `sed -n 89,98p docs/plan/planning/observations/README.md`; `sed -n 226,230p
  docs/plan/adr/0049-ausgang-traegt-die-benannte-luecke.md`; `case`-Zweig `:56-61` ohne
  Zeit- oder Lese-Schritt-Bedingung.
- `verifizierbar`: nein. Kein Gate liest den Wächter gegen die ADR.
- `klasse`: Wächter schärfer als die Regel, die er zitiert

### F-2 — MEDIUM: über einem leeren Prüfbereich bleibt der Wächter still

- `quelle`: Skill §MEDIUM *Zusicherung über einer Menge, die leer sein kann*; `AGENTS.md` §3.6
- `pfad`: `harness/tools/register-ausgang.sh:27-37`, `:65-69`
- `befund`: Exit 2 tritt nur ein, wenn die Wurzel fehlt. Trifft der Glob `BEO-*/*/` nichts, endet der
  Lauf mit Exit 0. Das gilt zum Beispiel für ein umbenanntes Kürzel-Verzeichnis oder eine geänderte
  Tiefe. Kein Fall in `test/register-ausgang.bats` belegt, dass der reale Prüfbereich nicht leer ist.
  Der Testkopf verweist dafür auf den Lauf von `make register-ausgang`, und der fällt nur bei einer
  Rot-Meldung auf. Für den angekündigten Gate-Einsatz ist das ein Pfad, auf dem der Lauf grün meldet,
  ohne etwas geprüft zu haben.
- Beleg: Register mit `beo-all/x/` (3 Belege, `offen`) →
  `register-ausgang: 0 Eintraege, 0 ueber der Schwelle, 0 Befund(e)`, `EXIT 0`.
- `verifizierbar`: ja (Bruchprobe oben).
- `klasse`: Negation über einer Menge, die leer sein kann

### F-3 — LOW: Bindung und Kopf zeigen auf ADR-0069, die Ausgangs-Regel steht in ADR-0049

- `quelle`: ADR-0069 §Was hier NICHT entschieden ist (*„Die Ausgangs-Regel (ADR-0049)"*) und
  Re-Evaluierungs-Trigger 2 (*„Ein Wächter für die **zweite Hälfte**"*)
- `pfad`: `harness/README.md` §Werkzeuge (Bindung `ADR-0069`); `harness/tools/register-ausgang.sh:5`;
  `Makefile` Hilfetext und Kommentar `register-ausgang`; Slice-Plan §3 *Umsetzungsstand*
- `befund`: Der Wächter hält die Ausgangs-Regel. Die Bindung nennt aber nur ADR-0069, und diese ADR
  schließt die Ausgangs-Regel ausdrücklich aus. Sie trägt nur die Zählregel (Folgepflicht 2). Der
  Plan begründet *„eine Ausnahmeliste verbietet ADR-0069 (Re-Evaluierungs-Trigger 2)"*. Dieser
  Trigger spricht über einen Wächter für beleglose Verzeichnisse und nicht über diesen. Wer der
  Bindung folgt, landet bei einer Entscheidung über einen anderen Gegenstand.
- `verifizierbar`: nein
- `klasse`: Rang-Zeiger auf eine Entscheidung über einen Nachbar-Gegenstand

### F-4 — INFO: die erste `**Stand:**`-Zeile entscheidet, und der Kopf sagt es nicht

- `quelle`: Maintainability; `AGENTS.md` §3.6
- `pfad`: `harness/tools/register-ausgang.sh:52`
- `befund`: `grep -m1` liest die erste passende Zeile. Steht vor der echten Zeile
  `**Stand:** offen` eine weitere `**Stand:** verkörpert …`, etwa als Zitat in einem
  Grenzen-Abschnitt, bleibt der Lauf still. Bruchprobe: ein Eintrag mit 3 Belegen und dieser Folge
  wird nicht gemeldet. Der Bestand enthält keinen solchen Fall
  (`grep -c '^\*\*Stand:\*\*' …/state.md | awk -F: '$2!=1'` → leer). Eine `state.md` mit CRLF wird
  laut gemeldet, mit `Stand 'verkörpert'`, also verwirrend, aber nicht still.
- `verifizierbar`: ja
- `klasse`: erste Fundstelle als Zustand ohne Eindeutigkeits-Annahme im Kopf

## Negativbefunde

- **Zählung `evidence/*.md`:** sie entspricht ADR-0069 Folgepflicht 2. `.gitkeep` und ein Verzeichnis
  `*.md` zählen nicht, und der bats-Fall 4 bindet beides. Ohne Befund.
- **Mutations-Fälle 564/565:** beide sed-Anker treffen in einer Kopie genau die Zielzeile (`diff`:
  `:57` bzw. `:42`). Die Behauptung *„allein"* in 565 ist korrekt, denn nur Fall 4 legt ein
  Verzeichnis `*.md` an. 564 beansprucht keine Exklusivität und nennt das Mitfärben. Ohne Befund.
- **Realer Lauf:** `bash harness/tools/register-ausgang.sh` → 233 Einträge, 65 über der Schwelle,
  8 Befunde, Exit 1. Das stimmt mit der Commit-Message überein. Die Stand-Wörter im Bestand sind
  ausschließlich `offen`/`verkörpert`/`geplant`/`gestrichen`, gezählt über die erste Wortspalte aller
  `state.md`. Ohne Befund.
- **Gate-Index und `exempt-targets`:** die Zeile steht unter §Werkzeuge mit `kein Gate` und ist in
  `targets.exempt-targets` sowie der Zählzeile von `.d-check.yml` (21 von 25) nachgezogen. Es gibt
  kein halluziniertes Gate. Ohne Befund.
- **Hard Rules §3.3/§3.7/§3.9:** Move und Inhalt liegen in getrennten Commits. Die neuen Kommentare
  tragen Zusage, Grenze und Rang-Zeiger. Das Skript ist reines bash ohne Host-Toolchain. Ohne Befund
  (für den Rang-Zeiger siehe F-3).

## Summary

0 HIGH · 2 MEDIUM · 1 LOW · 1 INFO.
**Finding-Klassen dieses Laufs:** Wächter schärfer als die Regel, die er zitiert · Negation über
einer Menge, die leer sein kann · Rang-Zeiger auf eine Entscheidung über einen Nachbar-Gegenstand ·
erste Fundstelle als Zustand ohne Eindeutigkeits-Annahme im Kopf

## Verdikt

**Merge-blockierend:** ja — F-1 und F-2 sind MEDIUM. F-1 ist eine Frage zwischen Plan und ADR-0049
und geht an Planner und Architect. F-2, F-3 und F-4 gehen an den Implementer.
