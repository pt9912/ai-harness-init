# Verifikation — slice-mutations-anker-greift-in-den-gates

**Rolle:** Verifier (Baseline-Regelwerk `modul-11-verification.md`) · **Datum:** 2026-10-09 ·
**Gegenstand:** `9fbc304c`, `aeb318d4`, `e49b8534`, `baa07505`, `ef226660` gegen die DoD des Slice
`slice-mutations-anker-greift-in-den-gates`, `LH-QA-01` und `MR-071` §Grenze. Review:
`2026-10-09-slice-mutations-anker-greift-in-den-gates.md` (`196d917d`). Stichproben-Grundlage: das
Review hat den Diff vollständig gelesen; hier nachgefahren sind die Rot-Belege, die Zähne und der
Gesamtlauf des Modus.

**Urteil:** Die drei Liefer-Punkte sind bestätigt. `make gates` ist bestätigt (Lauf unten). Die fünf
Closure-Punkte sind offen und gehören dem Planner. Zum Code gibt es keinen Befund. Für die Closure
bleiben zwei Abweichungen vom Plan: die Reparatur 145/147 trotz §1 ohne Rückführung nach §4 (M-4)
und die Liefermenge über §3 hinaus.

## Verdikte je DoD-Punkt

- **DoD 1 — Greift-Modus, Verdrahtung, Doku, Laufzeit: bestätigt.**
  - Modus: `greift_case`/`greift_main` in `harness/tools/mutate.sh`. Je Fall eine Kopie der
    `# files:` unter `mktemp -d`, das Fall-Skript läuft dort, der Hash wird je exaktem Pfad
    verglichen; sonst `BEFUND <fall>` und Exit 1. Kein `green_prerun`, kein Sensor-Lauf, kein
    Beleg-Slot (gelesen).
  - Verdrahtung: `record-gates: … mutate-greift …`, Rezept `unset MUTATE_CASES; bash
    harness/tools/mutate.sh --greift`.
  - Doku: Zeile `make mutate-greift` in `harness/README.md` §Sensors, dazu
    `harness/sensors/mutate.md` §Greift-Modus mit Vertrag, Sensor, Laufzeit und Grenze.
  - `time make mutate-greift` → `624 Fall/Faelle, 624 greifen, 0 Befund(e)`, `real 0m17,155s`. Lage:
    `nproc` 20, warmer Seiten-Cache, ohne Docker. Den Gate-Zuwachs (18,2 s laut Commit `aeb318d4`)
    habe ich nicht nachgemessen; der Modus allein liegt in derselben Größe. Damit liegt er unter der
    Schwelle aus §4 (eine Minute), und die Rückführung `in-progress → next` greift nicht.
- **DoD 2 — Rot an der realen Quelle, HEAD grün, bats hält beide Richtungen: bestätigt.**
  - Gegen die reale Quelle, nicht gegen die Fixtures:
    `git show 98bfab0b^:test/mutations/<fall>.sh` in ein Scratch-Verzeichnis, dann
    `greift_main <scratch> <repo>`. Ergebnis: `BEFUND 247-archive-welle-go-schalter-erreicht-zweig-nicht
    — Mutation hat nicht gegriffen bei: cmd/ai-harness-init/archive_welle.go — Anker veraltet?`,
    `BEFUND 29-roadmap-nicht-neutralisiert — … bei: internal/emit/templates.go — …`,
    `2 Fall/Faelle, 0 greifen, 2 Befund(e)`, EXIT 1. Gelesen: beide Meldungen nennen den Fall und
    die Zieldatei, die der Anker verfehlt — `98bfab0b` hat genau diese zwei Anker nachgezogen.
  - HEAD-Fassung derselben zwei Fälle → `2 Fall/Faelle, 2 greifen, 0 Befund(e)`, EXIT 0.
  - `cmp` der Fixtures `test/fixtures/mutate-greift/{29,247}…` gegen `git show 98bfab0b^:…` →
    byte-gleich.
  - Ein zweiter realer Fall, ohne Fixture: die Fassungen von 145/147 aus `9fbc304c^` gegen HEAD →
    beide `BEFUND … internal/report/report.go — Anker veraltet?`, EXIT 1. Der Modus fängt also auch
    die Entwaffnung durch `ac429eec`, die ihn in diesem Slice ausgelöst hat.
  - Abweichung ohne Bedeutung: Die DoD verlangt *einen* bats-Fall für beide Richtungen; es sind
    zwei Fälle in `test/mutate-driver.bats` (rot und grün). Beide Richtungen sind gehalten.
- **DoD 3 — Übergabe an den Architect: bestätigt.**
  - Die Datei `2026-10-09-slice-mutations-anker-greift-in-den-gates-uebergabe-architect.md` liegt
    vor (`e49b8534`, `ef226660`). Sie nennt den falsch gewordenen Satz aus `MR-071` §Grenze, schlägt
    die Form mit Kopf-Marke nach `MR-032` vor und nennt Sensor sowie acht Grenzen. M-1, M-2 und I-1
    führt sie als gedeckt, M-3 als offen.
  - Die Fallzahl 621 in Grenze 4 ist auf den Stand vor dem Slice datiert; heute sind es 624 (s. o.).
    Sie ist datiert und darum kein Befund.
  - Norm-Text steht dort nicht (§3.8). Kein Commit berührt `AGENTS.md` oder `harness/conventions*`
    (`git show --stat` der fünf Commits).
- **DoD 4 — `make gates` grün: bestätigt.** Der Lauf ist unten unter *Kommandos* belegt.
- **DoD 5 — Review liegt vor, kein Self-Review: bestätigt.** `196d917d`, Rolle Reviewer, eigener Commit.
- **DoD 6–9 — Closure-Notiz, Register, Risiko-Ausgänge, Paarungen: nicht bestätigt (offen).** Das ist
  Planner-Arbeit (`AGENTS.md` §3.10); §6/§7 tragen `*bei Closure*`.

## Rot-Belege der Zähne (Bewusstes Brechen)

`make mutate MUTATE_CASES='145-… 147-… 635-… 636-… 637-…'` → `5 ok, 0 Befund(e)` (real 4m45s):

- 145 → `TestAggregiere_RollenloseCallsNichtImNenner rot`. Der Anker ist eng: Er entfernt nur
  `s.AgentRole != "" &&` (L-1 erledigt).
- 147 → `TestAggregiere_SpawnSpanZaehltNichtAlsToolCall rot`.
- 635, 636, 637 → jeweils der benannte bats-Fall `greift: …` rot.

**Aus dem behaupteten Grund?** Jede Mutation habe ich in einer Scratch-Kopie angewandt und das Rezept
aus dem Makefile mit `MUTATE_CASES=29-…` als Prozess gefahren. Fall-Set waren die Fixtures 29/247:

- unmutiert: `2 Fall/Faelle, 0 greifen, 2 Befund(e)`, EXIT 1.
- 635: `2 Fall/Faelle, 2 greifen, 0 Befund(e)`, EXIT 0. Das ist stilles Grün über entwaffneten
  Fällen, die behauptete Ursache.
- 636: EXIT 0 ohne jede Ausgabe. Der Einstieg ruft den Modus nicht, die behauptete Ursache.
- 637: `1 Fall/Faelle, 0 greifen, 1 Befund(e)`. `MUTATE_CASES` engt das Gate ein, die behauptete
  Ursache. Den Test färbt hier nicht der Status (der bleibt ≠ 0), sondern seine Zeile
  `2 Fall/Faelle, 0 greifen, 2 Befund(e)`.

## Plan-vs-Code-Diff

- **Gebaut, aber im Plan ausgeschlossen:** `9fbc304c` repariert die Anker 145/147. §1 Punkt 3 schließt
  die Reparatur von Fällen aus, die der Modus auf HEAD als entwaffnet meldet. §4 verlangt für diesen
  Fund die Rückführung `in-progress → open`: erst die Reparatur als eigener Vorgang, dann der
  Gate-Anschluss. Die Rückführung wurde nicht gezogen, und einen Plan-Diff gibt es nicht (Review M-4).
  Das ist eine Abweichung für die Closure, kein Verdikt über den Code: Die Reparatur ist richtig
  (Rot-Belege oben, Erwartung unverändert).
- **Gebaut über §3 hinaus:**
  - `test/fixtures/mutate-greift/` (zwei Dateien); trägt DoD 2.
  - `test/gate-nachweis-kante.bats`: die Erwartungsliste der Kante ist um `mutate-greift` ergänzt;
    das ist eine Folge der Verdrahtung.
  - Drei Zähne statt einem (635, 636, 637) und zwei bats-Fälle mehr (Rezept als Prozess,
    Präfix-Pfade); das sind Review-Folgen M-1, M-2 und I-1.
  - Die GNU-Grenze in `harness/sensors/mutate.md` (M-3).

  Keines davon verschiebt ein Akzeptanzkriterium.
- **Geplant, nicht gebaut:** nichts. Jede Zeile aus §3 hat ihren Diff.
- **Abgrenzung gehalten:** Es gibt kein zweites Skript. Zeilennummer-Anker sowie `# files:`/`# expect:`
  sind nicht angefasst, und Norm-Text steht nicht im Slice.

## Negativbefunde

- **Verdrahtung:** Rezept → `--greift` → `greift_main` ist durch den bats-Fall *Rezept als Prozess*
  gedeckt, Zahn 636 färbt ihn rot.
- **`LH-QA-01`:** Die Zeile in §Sensors sagt *„Jeder Mutations-Fall greift"*. Das stimmt im Gate
  dank `unset MUTATE_CASES`, Zahn 637 hält es. Das Ziel existiert und läuft.
- **`AGENTS.md` §3.9:** keine Toolchain und kein Paketmanager in der Befehlsposition. Die
  GNU-Abhängigkeit ist benannt (M-3, Risiko §6 Punkt 2).
- **Kommentare (§3.7):** Kopf von `greift_case` und Makefile-Kommentar nennen Sensor und Grenze im
  Indikativ; Herkunft nur als `seit slice-…`.

## Offen für die Closure (Planner)

- M-4: Abweichung von §1/§4 in §7 benennen — als *„was ging anders als geplant"* oder als
  nachträglicher Plan-Diff.
- I-2: Entscheiden, ob die Entwaffnung 145/147 durch `ac429eec` ein weiterer Beleg in
  `BEO-ALL/mutations-fall-wird-von-berechtigter-aenderung-entwaffnet` ist. Ist sie es, steht der
  dritte Auflösungs-Trigger von `MR-071` an.
- Ausgänge für die Risiken §6:
  - Punkt 1 (Patch wirkt nicht allein über `# files:`): heute *entfallen* zu begründen, weil
    624 von 624 Fällen greifen.
  - Punkt 2 (Host ohne Container): *eingetreten* als benannte Grenze M-3, oder *weiter offen*.
- Die Übergabe liegt beim Architect: der Nachfolge-Eintrag zu `MR-071` mit Kopf-Marke.

## Kommandos

```text
git show 98bfab0b^:test/mutations/<29|247>.sh → greift_main → 2 Befund(e), EXIT 1
HEAD-Fassung 29/247 → greift_main            → 2 greifen, 0 Befund(e), EXIT 0
git show 9fbc304c^:test/mutations/<145|147>.sh → greift_main → 2 Befund(e), EXIT 1
cmp Fixtures gegen 98bfab0b^                  → gleich
time make mutate-greift                       → 624/624 greifen, 0 Befund(e), real 17,2 s (nproc 20)
make mutate MUTATE_CASES=<145 147 635 636 637> → 5 ok, 0 Befund(e)
Scratch: Mutation 635/636/637 + Rezept als Prozess → s. Rot-Belege
make gates                                    → s. Commit-Message dieses Berichts
```
