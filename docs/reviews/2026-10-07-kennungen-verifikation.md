# Verifikation — slice-emittierte-dateien-tragen-nur-im-ziel-aufloesende-kennungen

**Rolle:** Verifier (Modul 11) · **Datum:** 2026-10-08 · **Gegenstand:** `c5bc8656`, `445efe8c`,
`54b5b37e`, `78dd879f` gegen Slice-Plan §1–§3 (DoD) und den Review-Report
`docs/reviews/2026-10-07-kennungen-review.md`. **An:** Planner.

## Verdikte je Liefer-DoD-Punkt

- **DoD 1 — Wortlaut statt Kennung: bestätigt.**
  - `git grep -nE '\b(ADR-[0-9]{4}|LH-[A-Z]{2}-[0-9]{2}|MR-[0-9]{3}|SPEC-[0-9]{3}|CO-[0-9]{3})\b' -- internal/emit/templates`
    → genau zwei Zeilen, `selbstpruefung.mk:38` und `selbstpruefung.sh:88` (`SELBSTPRUEFUNG_MSG_GRUEN`).
  - Rot-Werkzeug über dem Vorzustand nachgetragen: `internal/` auf `c5bc8656^` zurückgesetzt, Wächter
    von HEAD, `make test-go` → EXIT 2, allein `TestEmittierteDateienTragenNurImZielAufloesendeKennungen`
    rot, Meldung nennt je Datei die Fundmenge (16 Dateien, z. B.
    `harness/mk/traeger.mk: emittiert ADR-0058, ADR-0059, LH-QA-03, MR-007 — erlaubt:`;
    `tools/harness/selbstpruefung.sh: emittiert ADR-0007, ADR-0054, ADR-0083, LH-FA-01 — erlaubt: LH-FA-01`).
    Danach `git checkout HEAD -- internal/`, Baum sauber. Damit ist die Zusage „nach dem Nachzug grün
    mit genau den zwei Nutzlast-Zeilen“ am realen Vorzustand belegt, nicht nur an einer Mutation.
  - Grenze: Laufzeit-Meldungen des Binärs (Review INFO-1) bindet DoD 1 nicht („Dateien“); Plan §1 Ziel
    sagt „keine emittierte Meldung“ — die Lücke zwischen Ziel und DoD ist offen, siehe unten.
- **DoD 2 — Wächter: bedingt.** Verhalten bestätigt, Ort weicht vom Plan ab.
  - Bewusstes Brechen, je erkannte Form: in `internal/emit/templates/enforce/record-gates.sh` eine Zeile
    `# Probe ADR-0999 LH-ZZ-99 MR-999 SPEC-999 CO-999 slice-999`, in `internal/gen/golang.go:527`
    (`.a-check.yml`, Go-generierte Emission) `welle-77`. `make test-go` → EXIT 2, ein `--- FAIL`,
    Meldung gelesen:
    `.a-check.yml: emittiert welle-77 — erlaubt:` und
    `tools/harness/record-gates.sh: emittiert ADR-0999, CO-999, LH-ZZ-99, MR-999, SPEC-999, slice-999 — erlaubt:`.
    Alle sieben Formen des Musters greifen, mit Dateiname. Zurückgesetzt.
  - Gegenrichtung (Ausnahme gestrichen) und Fall 558: `make mutate` für 558/559 lief im Review (EXIT 0,
    2 ok), nicht wiederholt. Fall 560: `make mutate MUTATE_CASES='560-emittierte-vorlage-traegt-spec-kennung'`
    → EXIT 0, `1 ok, 0 Befund(e)`.
  - Abweichung: der Test liegt in `cmd/ai-harness-init/kennungen_test.go`, DoD 2 und Plan §3 nennen
    `internal/emit/`. Die Abweichung trägt (nur `run()` liest auch die `internal/gen`-Emission — oben
    an `.a-check.yml` rot gesehen), steht aber in keinem Plan-Text (Review INFO-2).
  - `d-check.mk` ist im Test eine Fixture; der reale `--print-mk`-Text bleibt unbeobachtet — im Testkopf
    benannt (§3.6, Fixture statt realer Quelle; Fremdtext, folgenlos für die Zusage).
- **DoD 3 — `make gates` grün; `make mutate` ohne Befund:** `make gates` siehe letzte Zeile; Mutationen
  wie oben.

## Plan vs. Code

- **Gebaut ohne Plan:** `harness/tools/traeger-fetch.sh` (Dogfood) ändert `c5bc8656` mit, obwohl §1 Dogfood-
  Skripte ausschließt. Hält die Datei byte-gleich zur Vorlage; ein Sensor, der diese Gleichheit hält,
  ist nicht auffindbar (`git grep -nE 'cmp .*traeger-fetch' -- test cmd internal Makefile` → leer).
  Ohne Wirkung auf die Zusage; Plan-Text deckt ihn nicht.
- **Gebaut ohne Plan:** Muster um `SPEC-`, `CO-`, `slice-NNN`, `welle-NN` erweitert (`78dd879f`), Plan §1
  nennt drei Formen. Erweiterung, keine Senkung; die Namensform `slice-<name>` als GRENZE im Testkopf.
- **Geplant, gebaut:** Vorlagen, Go-Meldungs-Strings in `emit.go`/`makefile.go`, `internal/gen`,
  Fall 360 nachgezogen; Wächter + drei Mutations-Fälle (Plan: zwei).

## Offene Punkte für Planner/Architect

- Plan §1 Ziel („keine emittierte Meldung“) gegen DoD 1 („Dateien“): Laufzeit-Meldungen tragen weiter
  Kennungen (Review INFO-1) — Ausgang für Risiko §6 Punkt 1 an der Closure.
- Testort `cmd/` statt `internal/emit/` und die Dogfood-Mitänderung im Plan-/Closure-Text nachziehen.
- Namensform-Kennungen in emittierten Dateien: kein Sensor (GRENZE im Test) — Kandidat Register.

## Negativbefunde

- Ausnahme-Liste: genau zwei Einträge, beide Nutzlast; kein weiterer Fund über der realen Emission.
- Varianten: sieben Lauf-Varianten inkl. ohne Erfassung, die Variante prüft ihren eigenen Zustand.
