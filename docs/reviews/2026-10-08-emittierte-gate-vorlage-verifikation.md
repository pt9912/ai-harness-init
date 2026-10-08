# Verifikation: slice-emittierte-gate-vorlage-traegt-targets-und-reviews

**Rolle:** Verifier (Modul 11) · **Datum:** 2026-10-08 · **Stand:** HEAD `1d2442f7` (Diff
`d4850268`, `1d2442f7`; Architect `8ff21c81`; Review `49ad1f60`) · **Bezug:** `MR-054`, `MR-086`,
`LH-FA-03`, `LH-QA-01` · **An:** Planner. Den Slice schließt der Planner.

## Verdikte je DoD-Punkt

- **DoD 1 — bedingt (Wortlaut nicht erfüllbar, Absicht erfüllt).**
  `grep -cE '^# (targets|reviews):' internal/emit/templates/d-check.yml` → **1**, nicht 2.
  `targets` steht schon vor dem Diff aktiv in `modules:` (`git show d4850268^:internal/emit/templates/d-check.yml | grep '^modules:'`
  → `modules: [links, anchors, ids, matrix, spans, structure, targets]`, identisch mit HEAD) —
  die Prämisse in Plan §1 („im Ziel nicht emittiert") war falsch. `modules:` unverändert (beide
  Stände gleich, s. o.). Der `reviews`-Block trägt eine eigene `# Trigger:`-Zeile. Für `targets`
  hat ein Kommentar-Block keinen Gegenstand. **DoD-Verletzung im Wortlaut** — die Zahl 2 und
  die `targets`-Zeile der Tabelle in §1 gehören vom Planner korrigiert; der Implementer hat den
  Ist-Stand nur in §3 notiert, nicht die DoD geändert (§3.10 eingehalten).
- **DoD 2 — bedingt: Grün bestätigt, das zugesagte Rot ist falsch formuliert.**
  - Grün: `make full-smoke` → `EXIT 0`, 25 `full-smoke: OK`-Zeilen, im Ziel
    `d-check: 21 Datei(en) geprüft, 0 Befund(e)`; alle `FEHL`-Treffer im Log sind die
    absichtlichen Gegenbeispiele des Laufs. Eigenes Doc-Only-Ziel (`.harness/state/bin/ai-harness-init --name verif-ziel`)
    trägt den Block und meldet `make docs-check` → `21 Datei(en) geprüft, 0 Befund(e)`.
  - Rot: Die Zusage „ein Block, dem die führenden `#` fehlen, bricht denselben Lauf" ist am Pin
    v0.84.0 **widerlegt**. Gefahren im bootstrappten Ziel, `make docs-check`:

    | Sonde | Lage | Ausgabe | Exit |
    |---|---|---|---|
    | A | alle drei Block-Zeilen ohne `#`, `modules:` unverändert | `0 Befund(e)` | 0 |
    | B | nur `reviews:` ohne `#` | `0 Befund(e)` | 0 |
    | B2 | `reviews:` + `done-dir` ohne `#` | `error: … reviews.done-dir gesetzt, reviews.reviews-dir fehlt` | 2 |
    | B3 | nur `done-dir` ohne `#` | `error: … yaml: unmarshal errors` | 2 |

    Rot wird also nur der **halb** entkommentierte Block; der vollständig entkommentierte bleibt
    grün und täuscht eine Konfiguration vor. Die Implementer-Abweichung ist damit bestätigt.
    Den vollständigen Fall fängt statt des E2E der Wächter
    `TestDCheckConfig_ReviewsBleibtKommentarBlock` über der eingebetteten realen Vorlage, mit
    Mutations-Fall 568; dessen Rot-Beleg samt Bindungs-Gegenprobe fuhr der Review
    (`make mutate MUTATE_CASES=568-…` → `1 ok, 0 Befund(e)`) — hier nicht wiederholt.
    **Für den Planner:** der DoD-Satz gehört auf „halb entkommentiert → Konfig-Fehler;
    vollständig entkommentiert → Unit-Wächter" umgeschrieben, sonst behauptet die abgehakte DoD
    ein Rot, das nicht existiert.
- **`make gates` — bestätigt (Stempel).** `.harness/state/gates-passed.head` =
  `1d2442f74b0b…` = HEAD. Kein Neulauf; dieser Lauf ändert nur den Bericht.
- **Review — bestätigt.** `docs/reviews/2026-10-08-emittierte-gate-vorlage-review.md`
  (0 HIGH · 1 MEDIUM · 2 LOW); M-1 durch Architect-Verdikt + `MR-086` getragen, L-1/L-2 in
  `1d2442f7` umgesetzt (s. u.).
- **Doku-Update — bestätigt.** `docs/user/benutzerhandbuch.md` führt den Absatz „Die
  Review-Report-Deckung ist nicht eingeschaltet"; jede Aussage darin durch Sonden A, C–G2 gedeckt.
- **Closure-Notiz, Register, Risiko-Ausgänge, Paarungen — offen** (Planner-Arbeit, §7 leer).

## Rot-Beleg zur Phrasen-Zusage (korrektheitskritisch, nachgetragen am realen Ziel)

Zusage in Vorlage und Handbuch: erkannt wird allein „unabhängiger Review" (mit ä) an
`slice-<NNN>`; Vorlagen-Zeile an keinem Slice; Namens-Form auch mit der Wortfolge nicht.
Ziel wie oben, Block entkommentiert und `reviews` in `modules:`:

| Sonde | Lage | Ausgabe | Exit |
|---|---|---|---|
| C | `done/` leer | `review-missing … leere Pruefmenge … fail-closed` | 2 |
| D | `slice-007-x.md`, „unabhängiger Review", kein Report | `review-missing … fuer slice-007` | 2 |
| E | dasselbe, „unabhaengiger Review" | `0 Befund(e)` | 0 |
| F | `slice-foo-bar.md`, „unabhängiger Review" | `0 Befund(e)` | 0 |
| G2 | `slice-007-x.md` = reale `slice.template.md` des Ziels (Zeile 92 „Review durchgeführt, …"), kein Report | `0 Befund(e)` | 0 |
| H | wie D, dazu `docs/reviews/2026-10-08-slice-007-review.md` | `0 Befund(e)` | 0 |

D gegen H zeigt, dass das Modul wirklich prüft (rot ohne, grün mit Report); E, F, G2 zeigen die
Blindstellen. **Zusage bestätigt**, in allen drei Teilen.

## Plan-vs-Code

- Plan → Code: `full-smoke.sh` (bedingte Zeile) nicht geändert — durch den Unit-Wächter ersetzt;
  Handbuch geändert, Bedingung („zählt die Modul-Lage auf") traf zu.
- Code → Plan: `emit_test.go` und Mutation 568 sind nachträglich in §3 eingetragen (im
  Implementer-Commit) — Gebautes ohne ursprünglichen Plan, aber deklariert. `MR-086` entstand auf
  dem in §1 vorgesehenen Weg (Übergabe an den Architect), nicht im Implementer-Diff.
- Plan §4 Rückführung (`targets` braucht `makefiles:`-Aussage) hat keinen Gegenstand mehr, weil
  `targets` bereits aktiv ist.

## Offene Punkte für Planner/Architect

- DoD 1 und DoD 2 im Wortlaut korrigieren (s. o.), bevor sie abgehakt werden.
- Risiko „Kommentar-Block ohne Wächter" (§6): die Form ist bewacht (Unit-Test + 568), die
  **Werkzeug-Aussagen** im Kommentar (Phrase, Fail-closed) hält kein Sensor gegen einen künftigen
  Pin — bei einem d-check-Sprung bleiben sie still falsch. Gehört als Ausgang in die Closure.

## Negativbefunde

- Ebene: Dogfood-`.d-check.yml` unberührt (`git show --stat d4850268 1d2442f7` nennt sie nicht).
- `LH-QA-01`: kein Modul aktiviert, kein Target neu behauptet.

Sonden-Skript: Doc-Only-Bootstrap im Scratch, je Sonde Kopie + `make docs-check` des Ziels
(Image `ghcr.io/pt9912/d-check@sha256:e82ef2d2…`, v0.84.0, `--network none`).
