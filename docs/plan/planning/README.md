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
  Die Plan-Datei entsteht bei der **Eröffnung** der Welle und liegt danach
  **flach** in `planning/` (z. B. `welle-02-fetch-und-readme.md`); bei Closure
  wandert sie per `git mv` nach `done/` — neben ihren Lerneintrag
  `done/<welle-id>-results.md`. **Geplante Wellen bekommen noch keine Datei:**
  Sie stehen in der [`in-progress/roadmap.md`](in-progress/roadmap.md) unter
  *Nächste Wellen* und nirgends sonst — zwei Positionen, nicht drei.

## Beobachtungs-Register

[`observations/`](observations/README.md) liegt als Verzeichnis in diesem Ordner, neben den Wellen —
und ist keine Welle: je Beobachtung ein eigenes Verzeichnis, kein Lifecycle-Zustand. Sie ist der
Zähler des Steering Loops. Geschrieben wird bei der **Slice-Closure**, gelesen bei der
**Welle-Closure** (was 3× erreicht hat) und in **§8 jedes Slice-Plans** (was darunter steht). Die
Regeln stehen in [`observations/README.md`](observations/README.md).

## Aktueller Stand

Nicht als Snapshot hier eintragen — der Stand ergibt sich aus den
`open/`/`next/`/`in-progress/`/`done/`-Verzeichnissen, sonst driftet die
Tabelle.

## Roadmap

Siehe [`in-progress/roadmap.md`](in-progress/roadmap.md).
