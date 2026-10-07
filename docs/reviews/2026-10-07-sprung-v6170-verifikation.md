# Verifikation — slice-sprung-auf-v6170-wird-vollzogen

- **Rolle:** Verifier (Modul 11), frischer Kontext
- **Datum:** 2026-10-07
- **Gegenstand:** `f9f082c5`, `53094b41`, `94a258ce`, `8b08c3ab`, `78381a2b`, `e8469f9c`,
  `43f37383`, `dfa42f8a`, `25a85c8b`, `6fb392e7`; Review `2026-10-07-sprung-v6170-review`
- **Geprüft gegen:** Slice-Plan (in-progress) §1/§2/§3/§5, `ADR-0082` Festlegung 2 und
  §Fitness Function
- **Stichproben statt Volllese:** Der Review hat vollständig gelesen; Mutationsfall 541 und seine
  Gegenprobe sowie der Digest-Abgleich sind dort gefahren und hier nicht wiederholt.

## Verdikte je Liefer-DoD-Punkt

| DoD | Verdikt | Kommando → Ausgabe |
|---|---|---|
| 1.1 Baum | bestätigt | `ls .harness/baseline/` → `v6.17.0`; `make baseline-verify` → `v6.17.0 OK — 54 Dateien`, rc 0 |
| 1.2 Pins | bestätigt | `grep` aus Plan §1: Makefile 25/34, `.d-check.yml` 538/539, `baseline.go` 48/54 — alle `v6.17.0` bzw. `afe50df8…fa32a3`; `make regelwerk-check` → `2366 Datei(en) geprüft, 0 Befund(e)`, rc 0. Rot-Beleg an echten Pins steht in `f9f082c5` (Meldungen von `TestDefaultTag_MatchesBaseline` und `TestInventurMessTag_IstDerGefetchteStand` zitiert) — nicht nachgetragen |
| 1.3 Mess-Tag, Symlinks | bestätigt | `InventurMessTag = "v6.17.0"`; `readlink .claude/rules/*.md \| grep '\.harness/baseline/' \| grep -vc 'baseline/v6\.17\.0/'` → 0 (7 auf `v6.17.0`) |
| 1.4 Adressen | bestätigt | Link-Kommando aus §1 → **0**; Inline-Pfade: 40 in `docs/migrations/v6.16.0.md` (eingefrorener Report), 1 im Plan selbst; außerhalb Markdown nur `Kurs v6.16.0`-Zitate in Kommentaren (datierte Aussagen) |
| 2 d-check-Pin | bedingt | `d-check.mk` 78/79 und `emit.go` auf `v0.83.0`/`sha256:cdc88b04…a1c3`; Gegenmessung im Commit `94a258ce`. **Aber** Closure-Trigger 2 (`grep -rn 'v0\.82\.0' d-check.mk internal/emit/emit.go internal/emit/werkzeugindex.go` → „kein Treffer") liefert einen Treffer, s. V-1 |
| 3.1 Schalter, Grenz-Zeile | bestätigt | `internal/emit/templates/d-check.yml:160` → `authority-disjoint: true`; `DisjunktheitsBedingung` nennt drei Bedingungen, *sonst*-Hälfte und Sensor-Grenze wie Festlegung 2 |
| 3.2 full-smoke-Stufen | bestätigt | `make full-smoke` voll gefahren, EXIT 0 (Ausgabe gelesen, s. unten) |
| 3.3 Test, Mutation, Handbuch | bestätigt | `TestWerkzeugIndex_GrenzeNenntDisjunktheitsBedingung` hält den Satz literal am geschriebenen Werkzeug-Teil; Fall 541 rot + bindend laut Review; Handbuch-Diff in `8b08c3ab` |
| gates / full-smoke | bestätigt | `make full-smoke` EXIT 0; `make gates` über dem Stand mit diesem Bericht — Ergebnis in der Commit-Message |

**Die zwei Stufen in der Ausgabe von `make full-smoke`:**

- `targets_im_ziel` (d): `harness/mk/ai-harness-init.md:31 baseline-verify gate-declared-twice …
  (zuerst in harness/README.md)`; Gegenprobe „ohne den Schalter bleibt dieselbe Zeile grün";
  vorher „grüner Start … '0 Befund(e)'".
- `disjunktheit_im_v02x_ziel`: „.d-check.yml byte-gleich, Doppelzeile make baseline-verify mit
  Schalter ohne targets in modules '0 Befund(e)'"; Gegenprobe „targets in modules eingetragen
  färbt dieselbe Doppelzeile rot".

Die zwei `FEHLER`-Zeilen der Ausgabe (3443, 3451) sind eingerückte Zitate erwarteter
Gegenbeispiele anderer Stufen, kein Abbruch.

## ADR-0082 §Fitness Function

Alle drei Zeilen gedeckt: Zeile 1 und 2 durch die zwei Stufen oben (je mit Gegenprobe), Zeile 3
durch Test + Fall 541. Die benannten Lücken (Menge der Formen; Release-Bedingung) bleiben
unbewacht, wie die ADR sagt.

## Plan-vs-Code

- Plan → Code: jede Zeile der Tabelle §3 hat ihren Commit; `test/sources-pin.bats` und
  `internal/fetch/*_test.go` unverändert, wie geplant.
- Code → Plan: kein Gebautes ohne Plan; `.harness/skills/reviewer.md` (`78381a2b`) ist Nachzug
  nach DoD 1.4 durch den Eigentümer.

## Befunde

### V-1 — Closure-Trigger 2 wörtlich nicht erfüllt

`internal/emit/werkzeugindex.go:24`:
`// KOPPLUNG: dieselbe Erkennung wie das Modul targets am Pin d-check v0.82.0`. Der Kommentar
nennt den Pin, an dem die Regel-Erkennung gemessen ist; laut Review trägt `v0.82.0..v0.83.0`
allein `authority-disjoint`, die Aussage bleibt also wahr. Das Kommando in §5 Closure-Trigger 2
liefert trotzdem einen Treffer. **An den Planner:** Kommentar nachziehen lassen (Implementer,
Pin-Nennung auf `v0.83.0` nach Messung) oder den Trigger auf die Pin-Träger verengen — die
Abnahme verschiebt der Lauf nicht selbst.

## Offene Punkte für Planner/Architect

- V-1 (oben).
- Review I-1 (Freshness-Reihenfolge) und I-2 (`MR-083` ohne `Löst auf`) unverändert offen; keine
  DoD-Wirkung.
- Negativbefunde: Pins, Symlinks, Adressen, Schalter, Grenz-Zeile, Stufen — ohne Befund außer V-1.
