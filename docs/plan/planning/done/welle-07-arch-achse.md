# Welle welle-07-arch-achse: Architektur-Achse (`--arch`) + konditionales Arch-Gate

**Lifecycle:** Die aktive Welle liegt flach unter `docs/plan/planning/`; bei
Closure wandert diese Datei per `git mv` nach `done/` (neben ihre
`welle-<NN>-results.md`). Der Zustand ist die Verzeichnis-Position — kein
Status-Feld. Ob eine flache Welle *aktuell* oder *geplant* ist, sagt die Roadmap.

**Zielmeilenstein:** M4 — Arch-Gate integriert (a-check, [`LH-FA-07`](../../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren)).

**Verantwortlich:** ai-harness-init-Team (pt9912). **Datum:** 2026-07-24.

---

## 1. Welle-Ziel

Die Architektur-Achse `--arch` ([`ADR-0008`](../../adr/0008-arch-achse-emittiertes-skelett.md)) wird gebaut:
das emittierte Skelett wird optional **hexslice** (`domain`/`application`/`ports`/`adapters` + `cmd/`), und das **Architektur-Gate**
(a-check) wird **konditional** emittiert — nur bei einem schichten-tragenden Layout. Dazu wird der
Generator von der flachen `profiles()`-Map auf eine **Kompositions-Schicht** `lang-renderer × arch-layout`
gehoben (arch-invariante Bau-Gerüstung + arch-gegatetes Code-Layout, `flat` **byte-identisch** zum
heutigen Skelett). Spiegelbar an [`LH-FA-07`](../../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren):
`add-lang … --arch hexslice` → `make a-check` Exit 0; `--arch flat` → **kein** a-check
([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). Damit ist **M4** erreicht.

## 2. Trigger (Welle startet)

- [`ADR-0008`](../../adr/0008-arch-achse-emittiertes-skelett.md) **Accepted** (nach zwei Proposed-Review-Runden) — die Achsen-Trennung, die Kompositions-Mechanik und die konditionale a-check-Emission sind entschieden. [`ADR-0009`](../../adr/0009-hexslice-arch-realisierung.md) **Accepted** (verfeinert die Skizze auf das konkrete `hexslice`-Layout + a-check-Config nach der kanonischen Referenz).
- **Doc-Kette komplett:** Lastenheft **0.12.0** ([`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) um die Arch-Achse mit Wert `hexslice`, [`LH-FA-07`](../../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren)-Happy-Path + erfüllte a-check-Vorbedingung) + `architecture.md`-Nachzug (Kompositions-Schicht, `--arch`, hexSlice-Layout, a-check-Config). Ein Dritter kann ohne Rückfrage prüfen: [`ADR-0009`](../../adr/0009-hexslice-arch-realisierung.md) Status `Accepted`, Lastenheft-Version `0.12.0`.
- welle-06-freshness **done** (keine andere aktive Welle; WIP-Limit frei).

## 3. Closure-Trigger (Welle schließt)

- Alle Welle-Slices in `done/`.
- `make gates` + `make mutate` grün (die neuen Kompositions-/Emitter-Wächter je rot gesehen).
- `make full-smoke` belegt **beide** [`LH-FA-07`](../../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren)-Richtungen: `add-lang <sprache> <pfad> --arch hexslice` → das Skelett trägt `domain`/`application`/`ports`/`adapters` und `make a-check` ist Exit 0; `--arch flat` (bzw. ohne) → **kein** `.a-check.yml`/`a-check.mk`, `make gates` grün ohne a-check ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- Closure-Notiz in `welle-07-results.md`.

## 4. Slices in dieser Welle

<!-- Zustand jedes Slice = sein Lifecycle-Verzeichnis (open/next/in-progress/
done), hier NICHT gespiegelt — eine Status-Spalte driftete gegen die
Verzeichnisse (dieselbe zweite Wahrheit, die beim Slice retired wurde). -->

slice-044 ist **done**. Reihenfolge nach Abhängigkeit: erst die Kompositions-Seam (Fundament, done),
dann das hexSlice-Layout + Go-Renderer, dann die CLI-Verdrahtung, dann die a-check-Emission (die an
der Tool-Verfügbarkeit hängt, s. §5). slice-045 ist beim Schnitt in **045a/045b** re-sliced worden
([`ADR-0009`](../../adr/0009-hexslice-arch-realisierung.md) pinnte das konkrete hexSlice-Layout auf ~25
Rollen-Dateien — Layout+Renderer und die CLI-Verdrahtung sind je eine eigene, unabhängig verifizierbare
DoD; Layout ohne CLI ist testbar, CLI ohne fertiges Layout nicht). Jeder Slice ist per `cp` aus dem
Template angelegt (cp-Disziplin).

| Slice | Titel | Bezug |
|---|---|---|
| slice-044 | Generator-Kompositions-Seam (`profiles()` → `lang-renderer × arch-layout`, `flat` byte-identisch) — **done** | [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) |
| slice-045a | hexSlice-Arch-Layout (`archLayout("hexslice")`) + Go-Rollen-Renderer (`domain`/`application`/`ports`/`adapters` + `cmd/`, ~25 Dateien aus der kanonischen Referenz) | [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) |
| slice-045b | CLI `--arch`-Verdrahtung durch `add-lang`/Init (unbekannte Architektur → Exit 2 + sortierte Liste) | [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) |
| slice-046 | a-check-Tool-Beleg (Image+Pin+`--print-mk`) + konditionaler a-check-Emitter + full-smoke | [`LH-FA-07`](../../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren) |

## 5. Abhängigkeiten

- **Wird blockiert von:** nichts hart — die Doc-Kette ist komplett, Generator/Emitter/CLI existieren.
- **Wellen-Vorbedingung (aus dem [`ADR-0008`](../../adr/0008-arch-achse-emittiertes-skelett.md)-Review — jetzt **aufgelöst**):** slice-046 (a-check-Emission) hängt an der **Verfügbarkeit des a-check-Tools** — ein gepinntes Image mit `--print-mk`, wie d-check. Dieses Risiko ist durch [`ADR-0009`](../../adr/0009-hexslice-arch-realisierung.md) **abgeräumt**: a-check ist real (v0.15.0, Digest-gepinnt `ghcr.io/pt9912/a-check@sha256:…`, `--print-mk` erzeugt `a-check.mk`) — Tool-als-Quelle aus der kanonischen `hexslice-architecture`-Referenz. slice-046 **beginnt trotzdem mit diesem Beleg** (Pin verifizieren); fällt er wider Erwarten weg, liefert die Welle 044+045a+045b (die Arch-Achse + das hexSlice-Skelett) und vertagt die a-check-Emission als Carveout/Folge-Slice (Re-Scope, Modul 7 — der Sensor-über-leerem-Bereich-Verstoß entfällt, weil bei fehlendem a-check schlicht kein Gate emittiert wird).
- **Blockiert:** nichts hart. M4 ist erst erreicht, wenn slice-046 die a-check-Emission liefert.

## 6. Out-of-Scope für diese Welle

- **Weitere Architekturen** (clean/onion/…): nur `flat` (Default) + `hexslice`; weitere Werte nur mit belegtem Bedarf (kein spekulatives Layout, [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)-Geist).
- **Dogfood-Restrukturierung** von ai-harness-init: a-check ist emitted-only ([`ADR-0008`](../../adr/0008-arch-achse-emittiertes-skelett.md)); der Dogfood bleibt flach — ein hexSlice-Umbau wäre ein eigener Folge-ADR.
- **Rollen-Renderer außer Go:** die Welle baut das erste `hexslice`-Layout mit dem **Go**-Renderer; cpp/andere folgen je Bedarf (linear, opt-in) — nicht in dieser Welle.

## 7. Closure-Notiz

**Geschlossen** — die Belege stehen in [`welle-07-results.md`](welle-07-results.md) (Modul-6-Struktur:
Geliefert · was funktionierte · was anders lief · Steering-Loop-Einträge · Folge-Slices · Verifikation).

Kurz: alle vier Slices (044, 045a, 045b, 046) in `done/`; `make gates` Exit 0, `make mutate` 67 ok/0,
`make full-smoke` Exit 0 mit **beiden** [`LH-FA-07`](../../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren)-Richtungen
und rot gesehenem emittierten Gate; Carveout-Audit: ein offener Carveout ([`CO-001`](../../carveouts/CO-001-bats-shell-lint.md)),
unverändert gültig, kein stilles rotes Gate. **M4 erreicht.**
