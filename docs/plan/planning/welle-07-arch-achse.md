# Welle welle-07-arch-achse: Architektur-Achse (`--arch`) + konditionales Arch-Gate

**Lifecycle:** Die aktive Welle liegt flach unter `docs/plan/planning/`; bei
Closure wandert diese Datei per `git mv` nach `done/` (neben ihre
`welle-<NN>-results.md`). Der Zustand ist die Verzeichnis-Position — kein
Status-Feld. Ob eine flache Welle *aktuell* oder *geplant* ist, sagt die Roadmap.

**Zielmeilenstein:** M4 — Arch-Gate integriert (a-check, [`LH-FA-07`](../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren)).

**Verantwortlich:** ai-harness-init-Team (pt9912). **Datum:** 2026-07-24.

---

## 1. Welle-Ziel

Die Architektur-Achse `--arch` ([`ADR-0008`](../adr/0008-arch-achse-emittiertes-skelett.md)) wird gebaut:
das emittierte Skelett wird optional **hexagonal** (`domain/ports/adapters`), und das **Architektur-Gate**
(a-check) wird **konditional** emittiert — nur bei einem schichten-tragenden Layout. Dazu wird der
Generator von der flachen `profiles()`-Map auf eine **Kompositions-Schicht** `lang-renderer × arch-layout`
gehoben (arch-invariante Bau-Gerüstung + arch-gegatetes Code-Layout, `flat` **byte-identisch** zum
heutigen Skelett). Spiegelbar an [`LH-FA-07`](../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren):
`add-lang … --arch hexagonal` → `make a-check` Exit 0; `--arch flat` → **kein** a-check
([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). Damit ist **M4** erreicht.

## 2. Trigger (Welle startet)

- [`ADR-0008`](../adr/0008-arch-achse-emittiertes-skelett.md) **Accepted** (nach zwei Proposed-Review-Runden) — die Achsen-Trennung, die Kompositions-Mechanik und die konditionale a-check-Emission sind entschieden.
- **Doc-Kette komplett:** Lastenheft **0.11.0** ([`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) um die Arch-Achse, [`LH-FA-07`](../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren)-Happy-Path) + `architecture.md`-Nachzug (Kompositions-Schicht, `--arch`, konditionale a-check-Emission). Ein Dritter kann ohne Rückfrage prüfen: [`ADR-0008`](../adr/0008-arch-achse-emittiertes-skelett.md) Status `Accepted`, Lastenheft-Version `0.11.0`.
- welle-06-freshness **done** (keine andere aktive Welle; WIP-Limit frei).

## 3. Closure-Trigger (Welle schließt)

- Alle Welle-Slices in `done/`.
- `make gates` + `make mutate` grün (die neuen Kompositions-/Emitter-Wächter je rot gesehen).
- `make full-smoke` belegt **beide** [`LH-FA-07`](../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren)-Richtungen: `add-lang <sprache> <pfad> --arch hexagonal` → das Skelett trägt `domain/ports/adapters` und `make a-check` ist Exit 0; `--arch flat` (bzw. ohne) → **kein** `.a-check.yml`/`a-check.mk`, `make gates` grün ohne a-check ([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- Closure-Notiz in `welle-07-results.md`.

## 4. Slices in dieser Welle

<!-- Zustand jedes Slice = sein Lifecycle-Verzeichnis (open/next/in-progress/
done), hier NICHT gespiegelt — eine Status-Spalte driftete gegen die
Verzeichnisse (dieselbe zweite Wahrheit, die beim Slice retired wurde). -->

Nur der erste Slice ist geschnitten (cp-Disziplin — slice-045/046 werden bei ihrem Schnitt per `cp`
angelegt). Reihenfolge nach Abhängigkeit: erst die Kompositions-Seam (Fundament), dann Layout + CLI,
dann die a-check-Emission (die an der Tool-Verfügbarkeit hängt, s. §5).

| Slice | Titel | Bezug |
|---|---|---|
| slice-044 | Generator-Kompositions-Seam (`profiles()` → `lang-renderer × arch-layout`, `flat` byte-identisch) | [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) |
| slice-045 | erstes `hexagonal`-Arch-Layout + Go-Rollen-Renderer + CLI `--arch` (unbekannte Architektur → Exit 2) | [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) |
| slice-046 | a-check-Tool-Beleg (Image+Pin+`--print-mk`) + konditionaler a-check-Emitter + full-smoke | [`LH-FA-07`](../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren) |

## 5. Abhängigkeiten

- **Wird blockiert von:** nichts hart — die Doc-Kette ist komplett, Generator/Emitter/CLI existieren.
- **Wellen-Vorbedingung (Risiko, aus dem [`ADR-0008`](../adr/0008-arch-achse-emittiertes-skelett.md)-Review):** slice-046 (a-check-Emission) hängt an der **Verfügbarkeit des a-check-Tools** — ein gepinntes Image mit `--print-mk`, wie d-check. Heute ist a-check im Repo **nur** eine Dockerfile-Kopf-Referenz (Schwester-Repo), **nicht** integriert (kein Pin, kein `a-check.mk`, kein `--print-mk`-Aufruf). slice-046 **beginnt mit diesem Beleg**; ist a-check nicht verfügbar, liefert die Welle 044+045 (die Arch-Achse + das hexagonale Skelett) und vertagt die a-check-Emission als Carveout/Folge-Slice (Re-Scope, Modul 7 — der Sensor-über-leerem-Bereich-Verstoß entfällt, weil bei fehlendem a-check schlicht kein Gate emittiert wird).
- **Blockiert:** nichts hart. M4 ist erst erreicht, wenn slice-046 die a-check-Emission liefert.

## 6. Out-of-Scope für diese Welle

- **Weitere Architekturen** (clean/onion/…): nur `flat` (Default) + `hexagonal`; weitere Werte nur mit belegtem Bedarf (kein spekulatives Layout, [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)-Geist).
- **Dogfood-Restrukturierung** von ai-harness-init: a-check ist emitted-only ([`ADR-0008`](../adr/0008-arch-achse-emittiertes-skelett.md)); der Dogfood bleibt flach — ein hexagonaler Umbau wäre ein eigener Folge-ADR.
- **Rollen-Renderer außer Go:** die Welle baut das erste `hexagonal`-Layout mit dem **Go**-Renderer; cpp/andere folgen je Bedarf (linear, opt-in) — nicht in dieser Welle.

## 7. Closure-Notiz

<!-- Erst nach Welle-Abschluss füllen. Verweis auf welle-<NN>-results.md. -->
