# Planning — ai-harness-init

Slice-Lifecycle: `open/` → `next/` → `in-progress/` → `done/`.

Reine `git mv`-Commits beim Wechsel zwischen Verzeichnissen — siehe Hard
Rule „git mv + Inhaltsänderung = zwei Commits" in
[`../../../AGENTS.md`](../../../AGENTS.md).

## Lifecycle-Bedeutungen

| Verzeichnis | Bedeutung |
|---|---|
| `open/` | Geplant, noch nicht priorisiert. Keine Garantie auf Umsetzung. |
| `next/` | Als Nächstes priorisiert. Verantwortlicher zugeordnet. |
| `in-progress/` | Branch / PR existiert. |
| `done/` | DoD erfüllt, gemerged, Closure-Notiz vorhanden. |

## Slices vs. Wellen — beide über die Verzeichnis-Position

- **Slices** tragen ihren Status über das **Verzeichnis** (open → … → done).
- Eine **Welle** (Bündel von Slices) trägt ihren Status seit Regelwerk v3.5.0
  **ebenfalls über die Verzeichnis-Position, kein `Status:`-Feld** (Modul 6):
  die **aktive** Welle liegt **flach** in `planning/` (z. B.
  `welle-02-fetch-und-readme.md`), bei Closure wandert die Plan-Datei per
  `git mv` nach `done/` — neben ihren Lerneintrag `done/<welle-id>-results.md`.
  Ob eine flache Welle *aktuell* oder *geplant* ist, sagt die
  [`in-progress/roadmap.md`](in-progress/roadmap.md) (Sequenzierungs-Autorität).

## Beobachtungs-Register

[`observations.md`](observations/README.md) liegt **flach** in diesem Verzeichnis, neben den Wellen — und
ist keine Welle: die Datei steht, sie wandert nicht, und sie hat keinen Lifecycle-Zustand. Sie ist
der Zähler des Steering Loops. Geschrieben wird bei der **Slice-Closure**, gelesen bei der
**Welle-Closure** (was 3× erreicht hat) und in **§8 jedes Slice-Plans** (was darunter steht). Die
Regeln stehen in der Datei selbst.

## Aktueller Stand

Nicht als Snapshot hier eintragen — der Stand ergibt sich aus den
`open/`/`next/`/`in-progress/`/`done/`-Verzeichnissen, sonst driftet die
Tabelle.

## Roadmap

Siehe [`in-progress/roadmap.md`](in-progress/roadmap.md).
