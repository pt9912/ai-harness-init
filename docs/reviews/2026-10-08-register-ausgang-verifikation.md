# Verifikation — slice-register-ueber-der-schwelle-bekommt-seinen-waechter

**Rolle:** Verifier (Modul 11). **Datum:** 2026-10-08. **Stand:** HEAD `b710e1c6`.
**Gegenstand:** `docs/plan/planning/in-progress/slice-register-ueber-der-schwelle-bekommt-seinen-waechter.md`,
Bindung ADR-0049 (Regel), ADR-0085 (Zeitpunkt), ADR-0069 (Zählung).
**Eingang:** Commits `2b1ed744`, `0eaf51f8`, `d0fc706a`, `2578fee1`, `a5495478`; Nachzug `525e36b7`,
`d4cd1a63` (Planner); Reviews `2026-10-08-register-ausgang-review.md`, `…-einbindung-review.md`,
Verdikte `…-architect-verdikt.md`, `…-zwei-eintraege-verdikt.md`.
**Stichprobe:** Die Reviews haben den Diff gelesen; hier gelesen: Prüfer, Makefile-Kante, Sensors-Zeile,
`.d-check.yml`, Testfall-Liste, die fünf Mutations-Fälle, die zehn nachgezogenen `state.md`.

## Verdikte je DoD-Punkt

- **(1) Klasse färbt rot aus dem richtigen Grund, still über dem Bestand, verdrahtet — bedingt.**
  - Rot an der realen Quelle (nicht Fixture): `BEO-ALL/aenderung-nach-der-letzten-review-runde-bleibt-ungesehen/state.md`
    `**Stand:** verkörpert` → `offen` (3 Belege), dann `make gates` → `EXIT=2`:
    `register-ausgang: BEO-ALL/aenderung-nach-der-letzten-review-runde-bleibt-ungesehen: 3 Belege (evidence/*.md), Stand 'offen' — ueber der 3x-Schwelle ohne Ausgang`,
    `register-ausgang: 233 Eintraege, 66 ueber der Schwelle, 1 Befund(e)`, `make: *** [Makefile:276: register-ausgang] Fehler 1`.
    Alle Stufen davor (baseline-verify … comment-claims) im selben Lauf grün. Datei per `git checkout --` zurückgesetzt.
  - Still: `make register-ausgang` → `233 Eintraege, 66 ueber der Schwelle, 0 Befund(e)`, Exit 0.
  - Verdrahtung: `Makefile:656` `record-gates: … comment-claims register-ausgang host-bin …`; `gates: record-gates`;
    `harness/README.md:57` §Sensors; `grep -n register-ausgang .d-check.yml` → kein Treffer (nicht mehr exempt);
    Kante `test/gate-nachweis-kante.bats:155` führt das Ziel. Netzlos: reines `bash`-Rezept.
  - **Bedingt, weil** Closure-Kriterium 1 „beide Läufe mit Kommando im Umsetzungs-Commit" nur teilweise
    getragen ist: `a5495478` nennt das Rot (`make gates rc=2` mit Meldung), aber nicht den stillen Lauf
    über dem gezogenen Bestand; `2b1ed744` nennt einen stillen Lauf über dem **un**gezogenen Bestand
    (8 Befunde). Die Wirkung selbst ist oben gemessen — offen ist nur die Form des Belegs (Planner-Urteil).
- **(2) Bestand ohne Befund — bestätigt (Wirkung); §7-Messung offen.** `make register-ausgang` → 0 Befund(e)
  bei 66 über der Schwelle (Kommando oben, 2026-10-08, kein Erwartungswert). Die zehn in `525e36b7`/`d4cd1a63`
  nachgezogenen `state.md` tragen je einen Rumpf mit Zielort bzw. Kennung; jede genannte `slice-<name>`-Kennung
  löst im Lifecycle auf (`ls docs/plan/planning/{open,next,in-progress,done}/<kennung>.md`; `slice-184`/`slice-194`
  in `emittierte-vorlagen-klassifikation-ohne-traeger` sind Altnummern, nicht nachgeprüft). Die datierte Zahl mit
  Kommando in §7 steht noch nicht — §7 ist Planner-Closure.
- **`make gates` grün — bestätigt.** `.harness/state/gates-passed.head` = `b710e1c6…` = HEAD (fremder grüner Lauf,
  nicht wiederholt; dieser Lauf ändert nur den Bericht).
- **Review liegt vor — bestätigt.** Drei Reports + zwei Verdikte unter `docs/reviews/2026-10-08-register-ausgang-*`.
- **Doku-Update (= Liefer-Punkt 1) — bestätigt** (Sensors-Zeile, s. o.).
- **Closure-Notiz, Register, Risiko-Ausgänge, Paarungen** — nicht Gegenstand der Verifikation (Planner).

## Mutations-Fälle (Rot-Beleg der Wächter-Zweige)

`make mutate MUTATE_CASES='564-… 565-… 566-… 567-… 582-…'` → `5 ok, 0 Befund(e)`, Teillauf ohne Beleg-Slot:
- 564 (`offen` als Ausgang) → rot: „offen ueber der Schwelle -> exit 1 …"
- 565 (`-f` → `-e`, Verzeichnis `*.md` zählt) → rot: „gezaehlt werden Dateien evidence/*.md …"
- 566 (leerer Prüfbereich grün) → rot: „Wurzel ohne Eintrag … exit 2"
- 567 (erste Stand-Zeile entscheidet) → rot: „mehr als eine Stand-Zeile … Befund"
- 582 (Ziel aus der `record-gates`-Kante) → rot: „gate-nachweis: an der Kante haengen genau die erwarteten Checks"

## Plan-vs-Code

- Plan → Code: §3 (Prüfer unter `harness/tools/`, Makefile-Ziel, §Sensors, bats, Mutations-Fälle) vollständig gebaut;
  `state.md`-Nachzug lag laut §3 *Umsetzungsstand* bei Architect/Planner und ist dort erfolgt.
- Code → Plan: Exit-2-Zweig und Mehrdeutigkeits-Befund gehen über die DoD hinaus, stehen aber in §3 *Umsetzungsstand*
  — kein ungeplant Gebautes.
- Grenze des Sensors (Stand-Wort, nicht ob der Ausgang trägt) steht im Skriptkopf; §6 Risiko 1 bleibt damit für die
  Closure zu entscheiden (Kandidat *weiter offen* → `BEO-ALL/ausgang-nennt-traeger-der-nicht-traegt`).

## Offene Punkte für den Planner

- Closure-Kriterium 1: stiller Lauf über dem gezogenen Bestand fehlt als Commit-Beleg — in §7 nachtragen oder als
  erfüllt durch diese Messung werten.
- Liefer-Punkt (2): datierte Zahl mit Kommando in §7 (z. B. die Zeile `make register-ausgang` oben).

## Negativbefunde

- Zählung: keine Abweichung von ADR-0069 (Dateien `evidence/*.md`, Unterverzeichnis und Nicht-`.md` zählen nicht; Test + Fall 565).
- Hermetik/Netz: kein Netzzugriff im Rezept.
- Ausnahmeliste: keine vorhanden, keine erwartete Liste im Prüfer.
