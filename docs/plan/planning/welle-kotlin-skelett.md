# Welle welle-kotlin-skelett: Kotlin als drittes Sprachskelett

**Lifecycle:** Diese Datei entsteht bei der **Eröffnung** der Welle und liegt
flach unter `docs/plan/planning/`; bei Closure wandert sie per `git mv` nach
`done/` (neben ihre `welle-<Kennung>-results.md`). Der Zustand ist die
Verzeichnis-Position — kein Status-Feld. **Geplante Wellen bekommen noch keine
Datei:** Sie stehen in der Roadmap unter *Nächste Wellen* und nirgends sonst —
zwei Positionen, nicht drei.

**Zielmeilenstein:** kein Meilenstein-Bezug.

**Verantwortlich:** Planner. **Datum:** 2026-10-09.

---

## 1. Welle-Ziel

Kotlin wird ein Sprachskelett wie Go und C++ ([`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4)):
`add-lang kotlin` und `--lang kotlin` am Root rendern ein JVM-Gradle-Einzelmodul in den Layouts
`flat` und `hexslice`, mit Code-Gate, Guard-Set, emittiertem Arch-Gate und Freshness-Werkzeug nach
[ADR-0088](../adr/0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md). Das *Mehr* über die
Slice-DoDs: der volle E2E-Lauf trägt alle Kotlin-Stufen zugleich und bleibt neben Go und C++ grün.

## 2. Trigger (Welle startet)

- [ADR-0088](../adr/0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md) trägt `Status: Accepted`
  — eingetreten, Beleg Commit `5d3fecb2`.

## 3. Closure-Trigger (Welle schließt)

- Alle Slices aus §4 liegen in `done/`.
- `make gates` grün.
- `make full-smoke` grün mit allen Kotlin-Stufen (flat, hexslice samt rotem Arch-Gate-Gegenbeispiel,
  Root-Bootstrap).
- Closure-Notiz in `welle-kotlin-skelett-results.md`.

## 4. Slices in dieser Welle

| Slice | Titel | Bezug |
|---|---|---|
| `slice-kotlin-flaches-skelett` | Kotlin als flaches Skelett mit Code-Gate und Guard | [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), [`LH-FA-06`](../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) |
| `slice-kotlin-hexslice-mit-arch-gate` | Kotlin-hexslice mit emittiertem Arch-Gate und core-impurity-Zahn | [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), [`LH-FA-07`](../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren) |
| `slice-kotlin-root-bootstrap` | Kotlin als One-Shot am Root | [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), [`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) |
| `slice-kotlin-freshness` | freshness-kotlin meldet einen neueren Gradle-Image-Tag | [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) |

Offene Beobachtungen sind gesichtet in §8 jedes Slice-Plans.

## 5. Abhängigkeiten

- Binnen-Kanten: `slice-kotlin-flaches-skelett` → `slice-kotlin-hexslice-mit-arch-gate` →
  `slice-kotlin-root-bootstrap`; `slice-kotlin-flaches-skelett` → `slice-kotlin-freshness` (je
  Start-Bedingung in §4 des Slice-Plans).
- Blockiert: keine Welle. Wird blockiert von: keiner Welle.

## 6. Out-of-Scope für diese Welle

- Layout `hexagonal` für Kotlin — [ADR-0088](../adr/0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md)
  legt es nicht fest; Re-Evaluierungs-Trigger 3, Folge-ADR.
- Gradle-Multi-Modul, KMP/Android — von derselben ADR nicht festgelegt.
- Handbuch-Nachzug — gehört in den Release-Schnitt.

## 7. Closure-Notiz

Erst nach Welle-Abschluss: Ergebnis `welle-kotlin-skelett-results.md` (Geschwister im Ruheort
`done/`), Zähler: das Beobachtungs-Register, eine Ebene über dem Ruheort.
