# Review: slice-emittierte-gate-vorlage-traegt-targets-und-reviews

**Rolle:** Reviewer (Modul 10, `.harness/skills/reviewer.md`) · **Datum:** 2026-10-08 ·
**Gegenstand:** Commit `d4850268` (Claim `708105b7`/`1104d651`) gegen den Slice-Plan
`slice-emittierte-gate-vorlage-traegt-targets-und-reviews`, `MR-054`, `LH-FA-03`, `LH-QA-01` und
`AGENTS.md` §3. Nicht gegen die DoD.

**Summary:** 0 HIGH · 1 MEDIUM · 2 LOW · 0 INFO.

## Findings

### M-1 — MEDIUM

- `quelle`: `MR-054` Setzung 3; `AGENTS.md` §3.8
- `pfad`: `internal/emit/templates/d-check.yml:20-35`; `internal/emit/emit_test.go:485-486`
- `befund`: `MR-054` Setzung 3 lautet „zwei Positionen bleiben aus" und nennt abschließend `codepaths`
  und das Requirement-Muster von `ids`. Der Diff setzt eine dritte Position derselben Art in die
  emittierte Vorlage — `reviews` startet ein frisches Ziel rot (Sonde B unten), fällt also unter
  Kriterium 2 wie die beiden anderen —, und der Test-Kommentar verankert sie an „MR-054 Setzung 3".
  Die Setzung trägt sie nicht. Plan §1 (vierter Ausschluss) benennt für genau diesen Fall ein
  Übergabe-Artefakt an den Architect; der Diff enthält keines, und keine Commit-Message nennt es.
- `verifizierbar`: nein — kein Gate hält die Positions-Liste von `MR-054` gegen die emittierte Datei
- `klasse`: Übergabe an andere Rolle ohne Träger-Artefakt

### L-1 — LOW

- `quelle`: `AGENTS.md` §3.6/§3.7 (Zusage im Kommentar)
- `pfad`: `internal/emit/templates/d-check.yml:26`
- `befund`: Der Kommentar nennt als erkannte Wortfolge „unabhaengiger Review" in Anführungszeichen.
  Am Pin v0.84.0 erkennt das Modul nur die Form mit Umlaut (`reviewPhraseRE` in
  `internal/hexagon/core/rules/reviews.go`). Ein Adopter, der die angeführte Form übernimmt, bekommt
  keinen Befund, obwohl der Report fehlt: Sonde E → `0 Befund(e)`, Sonde F (mit ä) →
  `review-missing`. Die Datei schreibt Nicht-ASCII-Zeichen an anderer Stelle (Gedankenstriche);
  die Umschrift ist hier also keine Zeichensatz-Grenze.
- `verifizierbar`: ja — Sonden E/F unten
- `klasse`: Grenzen-Aufzählung einer erkennenden Regel ohne Formen-Probe

### L-2 — LOW

- `quelle`: `AGENTS.md` §3.6 (Zusage in Nutzerdoku)
- `pfad`: `docs/user/benutzerhandbuch.md:542`
- `befund`: Das Handbuch sagt, das Modul erkenne die Review-Zeile der Slice-Vorlage „an einem Slice
  mit Namen" nicht. Es erkennt sie an keinem Slice: der Zeile fehlt die Wortfolge
  „unabhängiger Review". Ein Adopter mit Slice-Nummern liest daraus, dass die Vorlagen-Zeile bei ihm
  greift; eingeschaltet bleibt das Modul dann grün und prüft nichts (Sonde H). Die Vorlage selbst
  (`d-check.yml:27-28`) trennt beide Grenzen richtig.
- `verifizierbar`: ja — Sonde H unten
- `klasse`: Zusage enger formuliert als die gemessene Grenze

## Kommandos und Ausgaben

Sonden am gepinnten d-check
(`ghcr.io/pt9912/d-check@sha256:e82ef2d2…`, v0.84.0), Scratch-Ziel aus der emittierten Vorlage
(Kopf bis vor `matrix:`, `modules:` je Sonde gesetzt), `docker run --rm --network none -v "$R:/repo:ro" $IMG`:

| Sonde | Lage | Ausgabe | Exit |
|---|---|---|---|
| A | Block ohne `#`, `reviews` nicht in `modules:`, `done/` leer | `0 Befund(e)` | 0 |
| B | `reviews` aktiv, `done/` leer | `review-missing … leere Pruefmenge … fail-closed` | 1 |
| C | `reviews` in `modules:`, Block kommentiert (kein `done-dir`) | `0 Befund(e)` | 0 |
| D | `slice-foo-bar.md` mit Vorlagen-Zeile, kein Report | `0 Befund(e)` | 0 |
| E | `slice-007-x.md`, „unabhaengiger Review", kein Report | `0 Befund(e)` | 0 |
| F | `slice-007-x.md`, „unabhängiger Review", kein Report | `review-missing … fuer slice-007` | 1 |
| G | `slice-foo-bar.md`, „unabhängiger Review", kein Report | `0 Befund(e)` | 0 |
| H | `slice-007-x.md` mit Vorlagen-Zeile (dreizeilig), kein Report | `0 Befund(e)` | 0 |

A–D, G bestätigen die Aussagen der Vorlage und des Handbuchs (inert ohne `modules:`-Eintrag,
fail-closed bei leerer Prüfmenge, `done-dir` als Schalter, Namens-Form nicht erkannt).

`make mutate MUTATE_CASES=568-emittierter-reviews-block-unkommentiert` → `1 ok, 0 Befund(e)`.
Gegenprobe: Mutation 568 angewandt, `t.Skip` allein in
`TestDCheckConfig_ReviewsBleibtKommentarBlock`, `make test-go` → Exit 0 (alle Pakete `ok`): der
benannte Test bindet die Mutation allein. Baum danach per `git checkout --` zurückgesetzt,
`git status --short` leer.

## Geprüft, ohne Befund

- **Ebene (Dogfood vs. emittiert):** `.d-check.yml` des Repos unberührt, `modules:` der Vorlage
  unverändert (`TestDCheckConfig_EntschiedeneModulListe` hält die Liste exakt).
- **§3.6 am realen Ziel:** Der Wächter liest `emit.DCheckConfig()`, also die eingebettete reale
  Vorlage, keine Fixture; Mutation 568 rot, Gegenprobe bindend (oben). Die Teil-Zusage „kein
  `reviews` in `modules:`" bindet zusätzlich der Modul-Listen-Test.
- **Werkzeug-Aussagen gegen den Pin:** gegen `reviews.go`/`run.go` am Tag v0.84.0 gelesen und mit
  Sonden A–H gefahren; außer L-1/L-2 stimmen sie. Gefahrene Formen: leeres `done/`, fehlendes
  `done-dir`, Namens- und Ziffern-Kennung, Phrase mit und ohne Umlaut, mehrzeiliges DoD-Item.
- **§3.7 Kommentare:** Vorlagen- und Test-Kommentar tragen Zusage, Grenze und Trigger; keine
  Chronik, keine Befund-Kennung.
- **Handbuch Ist-Zustand:** keine Kennungen, keine Chronik, keine Prognose; Inhalt außer L-2
  durch die Sonden gedeckt.
- **`LH-QA-01`:** nichts aktiviert, kein Target behauptet.
