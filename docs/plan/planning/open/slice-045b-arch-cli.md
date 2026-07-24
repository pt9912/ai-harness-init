# Slice slice-045b: CLI `--arch`-Verdrahtung

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.1/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-07-arch-achse](../welle-07-arch-achse.md).

**Bezug:** [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), [ADR-0009](../../adr/0009-hexslice-arch-realisierung.md), [ADR-0008](../../adr/0008-arch-achse-emittiertes-skelett.md).

**Autor:** ai-harness-init-Team (pt9912). **Datum:** 2026-07-24.

---

## 1. Ziel

Das `--arch <arch>`-Flag ist durch `add-lang` und die `--lang`-One-Shot-Kurzform des Init
**verdrahtet**: der CLI-Wert wird an `composeSkeleton(…, arch)` durchgereicht, sodass
`add-lang go <pfad> --arch hexslice` das hexSlice-Skelett (aus slice-045a) emittiert und ohne
`--arch` (bzw. `--arch flat`) das flache. Eine **unbekannte Architektur** endet mit **Exit 2 +
sortierter Architektur-Liste** (Spiegel zur unbekannten-Sprache-Negative-AC).

## 2. Definition of Done

- [ ] [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) (Arch-Achse, CLI-Teil): `add-lang <sprache> <pfad> --arch hexslice` emittiert das hexSlice-Layout; ohne `--arch`/`--arch flat` das flache — je ein `cmd`-Test.
- [ ] **Negative-AC:** `add-lang go <pfad> --arch <unbekannt>` → **Exit 2** + sortierte Architektur-Liste (`flat`, `hexslice`); analog beim Init-`--lang … --arch <unbekannt>`. Test referenziert.
- [ ] `--arch` je Modul (Mono-Repo): zwei `add-lang`-Läufe mit verschiedenen Architekturen koexistieren.
- [ ] `make gates` grün.
- [ ] `make mutate` grün — der neue Arch-Dispatch-/Exit-2-Wächter je rot gesehen (Mutation benannt + als `test/mutations/`-Fall).
- [ ] `make full-smoke` belegt die `--arch hexslice`-Richtung end-to-end (das Skelett trägt die Schichten; a-check selbst erst slice-046).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

Vor Code den Ist-Stand messen: den `add-lang`/`--lang`-Dispatch in `cmd/` und `wireLang`
lesen (slice-037/038-Fluss), sehen wie `arch` heute (fest `archFlat`) durchgereicht wird.
`archLayout`/`goRole` für `hexslice` liegen aus slice-045a vor — dieser Slice fügt **nur** die
CLI-Achse hinzu.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `cmd/ai-harness-init/*.go` — Arg-Parsing | update | `--arch <arch>` neben `--lang` parsen; Default `flat`; an `wireLang`/`composeSkeleton` durchreichen |
| `cmd/ai-harness-init/*.go` — Arch-Validierung | update | unbekannte Architektur (`archLayout(arch) == nil`) → Exit 2 + sortierte Liste `gen.SupportedArchs()`, spiegelbildlich zur unbekannten-Sprache-Klasse |
| `internal/gen` — `SupportedArchs()` | neu | sortierte Architektur-Liste als eine Quelle (für die Fehlermeldung + Tests), analog `SupportedLangs()` |
| `cmd/…_test.go` | neu | Happy-Path (`--arch hexslice`/`flat`) + Negative (Exit 2 + Liste) verankern |
| `test/mutations/NN-arch-cli-*.sh` | neu | rot-färbende Mutation für den Exit-2-Pfad (z. B. die Validierung entfernen → unbekannte Architektur nicht mehr Exit 2) |

## 4. Trigger

- **Beginn (`next` → `in-progress`):** slice-045a **done** — der `hexslice`-Renderer existiert,
  sonst hat das CLI-Flag kein Ziel-Layout zum Emittieren.
- **`in-progress` → `next` (zu groß):** unwahrscheinlich (reine CLI-Achse); falls doch,
  Happy-Path und Negative-AC trennen.
- **`in-progress` → `open` (blockiert):** falls der Init-`--lang`-One-Shot die Arch-Achse anders
  durchreichen muss als `add-lang` — Carveout + Rückfrage.

## 5. Closure-Trigger

DoD vollständig, `make gates` + `make mutate` + `make full-smoke` grün mit rot-gesehener Mutation,
Review konform + Verifier bestätigt die DoD, Closure-Notiz mit Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **Zwei Eintrittspunkte** (`add-lang` + Init-`--lang`-One-Shot) müssen dieselbe Arch-Achse tragen —
  ein geteilter `wireLang`-Kern verhindert Divergenz (slice-037-Lehre: geteilter Kern).
- **Exit-2-Konsistenz:** die unbekannte-Architektur-Meldung muss dem unbekannte-Sprache-Format
  gleichen (Exit-Code + sortierte Liste), sonst zwei divergente Fehlerklassen.
- **Byte-Identität `flat`:** ohne `--arch` bleibt der Default-Pfad `flat` — der bestehende
  full-smoke-doc-only/flat-Lauf muss unverändert grün bleiben.

## 7. Closure-Notiz (nach `done/`)

<!--
Wird *nach* Abschluss ergänzt. Inhalt:
- Was hat funktioniert?
- Was ging anders als geplant?
- Steering-Loop-Eintrag: welcher Guide/Sensor sollte verbessert werden?
  (kanonische Definition: [`/kurs/de/grundlagen/klassifikation.md` §Steering Loop](https://github.com/pt9912/ai-harness-course/blob/v3.5.1/kurs/de/grundlagen/klassifikation.md#steering-loop))
- Folge-Slices: welche neuen open/-Einträge?
-->

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): additive CLI-Erweiterung
(`cmd/`, ein neuer Flag-Zweig + Validierung + Tests) auf dem bereits etablierten `add-lang`/`wireLang`-Dispatch —
kein Umbau, das Default-Verhalten (`flat`) bleibt byte-identisch. Kein Diskrepanz-Risiko.
