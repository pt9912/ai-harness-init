# Verifikation: slice-werkzeug-festlegungen-ziehen-in-die-spezifikation

**Rolle:** Verifier · **Datum:** 2026-10-07 · **Gegenstand:** Commits `7978f3ca`, `50a0dff0`, `1548a06d`
gegen Plan/DoD (Schnitt `74571e08`), [ADR-0078](../plan/adr/0078-ziel-fassung-regiert-den-sprung-v6160.md)
Festlegung 3, Vorlage `.harness/baseline/v6.16.0/templates/spec/spezifikation.template.md`,
Architect-Verdikt `docs/reviews/2026-10-07-spezifikation-nummern-verdikt.md`.
Review `docs/reviews/2026-10-07-werkzeug-festlegungen-review.md` hat vollständig gelesen; die
emittierte Seite (gebootstrapptes Ziel, vier docs-check-Läufe) übernehme ich als Stichprobe, nicht neu.

## Verdikte je Liefer-Punkt

- **DoD 1 — Gliederung: bedingt.**
  - `grep -n '^## ' spec/spezifikation.md` → `219:## 7. Festlegungen der Harness-Werkzeuge`,
    `226:## 8. Historie`; Titel und Reihenfolge gleich der Vorlage (`:115`, `:128`).
  - §7 trägt keine Tabelle, sondern nennt die Spalten `ID · Werkzeug · Festlegung · Präzisiert` als Satz
    (`50a0dff0`, weil `test/spec-tabellenform.bats` eine `Präzisiert`-Tabelle ohne `SPEC`-Zeile rot färbt).
    Die DoD verlangt „Spaltenform der Vorlage … ohne Zeilen" — sachlich getragen, Wortlaut der DoD
    passt nicht (Review F-3); Anpassung ist Planner-Sache (§3.10).
  - `.d-check.yml:408` → `exclude-sections: [Historie, "7. Historie", "8. Historie", Geschichte]`.
  - **Rot-Beleg (Review F-2): bestätigt, so wie die DoD ihn formuliert, trägt er nicht.** Kopien per
    `git archive HEAD | tar -x`, `make -s -C <kopie> docs-check`:

    | Lauf | Änderung | Ergebnis |
    |---|---|---|
    | va | nur `"8. Historie"` aus `exclude-sections` (DoD-Wortlaut) | EXIT 0, `2334 Datei(en) geprüft, 0 Befund(e)` |
    | vb | va + ADR-Link als Zeile in §8 | EXIT 2, `spec/spezifikation.md:241 … matrix-forbidden Referenz spec-straten → adr ist nicht erlaubt` |
    | vc | ADR-Link in §8, `exclude-sections` unverändert (Kontrolle) | EXIT 0, 0 Befunde |

    Die Ausnahme bindet (vb rot, vc grün, Ursache `matrix-forbidden` aus dem Historie-Abschnitt) — aber
    nur mit Probe-Link; am heutigen Bestand ist das beschriebene Rot nicht zu sehen. Rot-Beleg damit
    nachgetragen; die DoD-Formulierung braucht den Probe-Link (Planner).
- **DoD 2 — Aufnahme-Regel: bestätigt.** `spec/spezifikation.md` Formregel trägt Ausnahme der
  adoptierten Vorlage, Messung über Link und Code-Span vor der Umnummerierung, Entscheidung davor; §8
  trägt die Zeile `2026-10-07 | Die Aufnahme-Regel lässt die Neuvergabe …`. Bedeutung deckt sich mit
  Verdikt Punkt 2. Kein Rot-Beleg verlangt (Prozess-Regel; Wächter fehlt — Review F-1).
- **DoD 3 — Emittierte Kommentare: bestätigt.** `internal/emit/templates/d-check.yml:34,43-45` nennen
  `"8. Historie"` bzw. „7. Historie im Lastenheft und 8. Historie in der Spezifikation";
  `:151 exclude-sections: [Geschichte]` unverändert; `internal/emit/emit_test.go:111` nennt die
  Dogfood-Liste wie `.d-check.yml`. Ziel-Überschriften laut Review-Bootstrap (`spezifikation.md:110 ## 8.
  Historie`, `lastenheft.md:103 ## 7. Historie`) — Stichprobe übernommen.
  `make full-smoke` → letzte Zeile `EXIT 0` (eigener Lauf).
- **`make gates`:** siehe letzte Zeile unten.

## Plan vs. Code

- Plan §3 → Code: alle vier Zeilen geliefert.
- Code → Plan: `harness/sensors/adr-immutable.md` und `harness/sensors/docs-check.md` zitieren die
  `exclude-sections`-Liste und sind mitgezogen (`7978f3ca`); nicht in Plan §3, aber Folge derselben
  Zusage (Zitat stimmt sonst nicht). Kein Befund in der Bedeutung, Planner kann §3 nachführen.

## Offene Punkte für Planner/Architect

- **Planner:** DoD-1-Wortlaut (Probe-Link; Satz statt leerer Tabelle); F-1-Lücke (kein Wächter vor der
  Umnummerierung, Code-Span-Form fängt kein Sensor) in §6/§7 benennen; Risiko 3 (`MR-001` ohne
  `"8. Historie"`) wartet weiter auf Architect-Verdikt.
- **Architect (INFO):** das Verdikt zählt „drei" bloße „§7"-Nennungen der Historie in Zeitdokumenten;
  `git grep -nE '§ ?7 Historie' -- 'docs/reviews/**' 'docs/plan/planning/done/**' | grep -i spezifikation | wc -l`
  → **8** Zeilen (u. a. `done/slice-spec-tabellen-tragen-die-lh-bezug-spalte.md:27`,
  `2026-09-17-…-nachpruefung.md:50`). Die Klasse (bloßer Text, kein Link/Code-Span) ist vom akzeptierten
  Negativ gedeckt; nur die Fundmenge ist größer als benannt. Links auf `#7-historie`: 0.

## Negativbefunde

- Gliederung: keine weitere Abweichung von der Vorlage in Titel/Reihenfolge.
- Emission: keine Kommentar-Aussage, die vom Template-Inhalt abweicht.
- Aufnahme-Regel: keine Bedeutungsabweichung vom Verdikt.
- **`make gates`:** EXIT 0 (letzte Zeile `span-check: Traeger vorhanden, span-emit hat einen Span geschrieben, Ablageort git-ignoriert`).

Laufzeit Verifikation: 366 s.
