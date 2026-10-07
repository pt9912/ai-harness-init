# Review: slice-werkzeug-festlegungen-ziehen-in-die-spezifikation

**Rolle:** Reviewer · **Datum:** 2026-10-07 · **Gegenstand:** Commits `7978f3ca`, `50a0dff0`,
`1548a06d` gegen den Plan (Schnitt `74571e08`), [ADR-0078](../plan/adr/0078-ziel-fassung-regiert-den-sprung-v6160.md)
Festlegung 3 (Zeile Welle 158), Vorlage `.harness/baseline/v6.16.0/templates/spec/spezifikation.template.md`,
Architect-Verdikt `docs/reviews/2026-10-07-spezifikation-nummern-verdikt.md`, `AGENTS.md` §3.6/§3.7.

**Summary:** 0 HIGH · 0 MEDIUM · 2 LOW · 2 INFO. Klassen: *Prozess-Regel ohne Wächter, Lücke unbenannt* ·
*Rot-Beleg einer DoD nicht am heutigen Bestand reproduzierbar*.

## Findings

**F-1 — LOW**
- `quelle`: `AGENTS.md` §3.6 (Lücke benennen), Linie aus §3.11
- `pfad`: `spec/spezifikation.md` · „misst der Lauf vor der Umnummerierung über Link und Code-Span"; Plan §6
- `befund`: Die neue Formregel hat keinen Wächter vor der Umnummerierung. Die Link-Form fängt `anchors`
  erst danach (Probe: Link auf `spezifikation.md#7-historie` in einem Review-Report → `anchor-missing`,
  EXIT 2); die Code-Span-Form fängt nichts (derselbe Lauf, derselbe Absatz: kein Befund). Weder Plan §6
  noch ein anderes Planungs-Artefakt nennt die Lücke. Failure-Szenario: ein künftiger Sprung nummeriert
  nach der Vorlage um, ohne zu messen; ein Code-Span-Zeiger in einem eingefrorenen Artefakt wird still tot.
- `verifizierbar`: ja (Probe unten, Lauf c5)
- `klasse`: Prozess-Regel ohne Wächter, Lücke unbenannt
- Ort der Benennung: Plan §6 bzw. Closure §7 (Planner, §3.10) — nicht die Spezifikation.

**F-2 — LOW**
- `quelle`: Plan §2 DoD 1 (Rot-Beleg, §3.6)
- `pfad`: Plan §2 · „`exclude-sections` behält einmal den alten Namen, und `make docs-check` meldet einen
  Befund aus dem Historie-Abschnitt"
- `befund`: So formuliert bleibt der Lauf grün: `"8. Historie"` entfernt, sonst nichts → EXIT 0, 0 Befunde
  (c4), weil §8 heute keinen abwärts zeigenden Link trägt. Rot wird er erst mit einem Probe-Link in §8 (c3,
  `matrix-forbidden`, Zeile 241). Der Eintrag selbst ist richtig; der Beleg trägt nur mit Probe. Failure-
  Szenario: die Verifikation nimmt den Satz als bestätigt, ohne dass das beschriebene Rot existiert.
- `verifizierbar`: ja (c3/c4)
- `klasse`: Rot-Beleg einer DoD nicht am heutigen Bestand reproduzierbar

**F-3 — INFO** — Plan §2 DoD 1 verlangt §7 „mit der Spaltenform der Vorlage"; `50a0dff0` nennt die Spalten
als Satz statt als leere Tabelle, weil `test/spec-tabellenform.bats:40` (Gegenrichtung) eine Tabelle mit
`Präzisiert` ohne `SPEC`-Zeile rot färbt. Sachlich getragen; die Abnahme-Formulierung passt der Planner an
(§3.10), nicht der Implementer.

**F-4 — INFO** — §7 der Spezifikation übernimmt aus der Vorlage nicht den Satz, dass eine nach `Accepted`
der Gate-ADR auftauchende Randform dort fortgeschrieben wird, wo die Festlegung des Werkzeugs steht. Die
Regel bindet weiter über Vorlage und ADR-0078; für die Folge-Slices ist sie dort zu lesen. Und: die neue
Formregel macht „eine Zeile in der Historie" allgemein zur Pflicht jeder Neuvergabe — das Verdikt verlangte
sie für diesen Vorgang; kein Widerspruch.

## Kommandos und Ausgaben

Kopien per `git archive HEAD | tar -x` unter dem Scratchpad, je Lauf `make -s -C <kopie> docs-check`:

| Lauf | Änderung | Ergebnis |
|---|---|---|
| c1 | Link auf ADR als Tabellenzeile in §8 | EXIT 0, 0 Befunde |
| c2 | derselbe Link als Absatz in §7 | EXIT 2, `spezifikation.md:226 matrix-forbidden` |
| c3 | Link in §8, `"8. Historie"` aus `exclude-sections` | EXIT 2, `spezifikation.md:241 matrix-forbidden` |
| c4 | nur `"8. Historie"` entfernt | EXIT 0, 0 Befunde |
| c5 | c4 + Link und Code-Span auf `#7-historie` in `docs/reviews/2026-06-13-plan-review-slices.md` | EXIT 2, ein Befund (`anchor-missing`, nur der Link) |

Emittiertes Ziel: `make host-bin`, `git init` + `ai-harness-init .` im Scratchpad (EXIT 0), ADR-Datei
`docs/plan/adr/0001-x.md` angelegt, `make -s docs-check` im Ziel:

| Lauf | Änderung | Ergebnis |
|---|---|---|
| Basis | — | EXIT 0, 21 Dateien, 0 Befunde |
| §8 | Link auf die ADR unter `## 8. Historie` | EXIT 2, `matrix-forbidden` |
| §7 | Link als Absatz in §7 | EXIT 2, `matrix-forbidden` |
| Geschichte | Link unter angehängtem `## Geschichte` | EXIT 0, 0 Befunde |

`grep -n '^## '` im Ziel: `spezifikation.md:97 ## 7. Festlegungen der Harness-Werkzeuge`,
`:110 ## 8. Historie`, `lastenheft.md:103 ## 7. Historie`.

## Geprüft, ohne Befund

- (a) Titel und Reihenfolge §7/§8 gleich der Vorlage (`grep -n '^## '` beider Dateien); §7 trägt die
  Werkzeug-Festlegungen, die Spalte `Präzisiert` folgt `MR-075`; keine Begründungsprosa über die Vorlage hinaus.
- (b) `exclude-sections` dogfood und emittiert tun, was die Kommentare sagen (Tabellen oben). Gefahren:
  Tabellenzeile in §8, Absatz in §8, Absatz in §7, `## Geschichte`; gelesen, nicht gefahren: Unterabschnitt
  `###` unter §8, Überschrift ohne Punkt.
- (c) Formregel deckt sich in der Bedeutung mit dem Verdikt (Ausnahme der Vorlage, Messung über beide
  Adress-Formen, Entscheidung vor der Umnummerierung, Historie-Zeile vorhanden).
- (d) Kommentare in `internal/emit/templates/d-check.yml` und `internal/emit/emit_test.go` stimmen mit dem
  gebootstrappten Ziel und der Dogfood-Liste überein; `harness/sensors/adr-immutable.md` und `docs-check.md`
  zitieren die Liste gleich; Kommentare tragen Zustand/Abgrenzung, keine Chronik (§3.7).
- `make gates` am Ende: EXIT 0.
