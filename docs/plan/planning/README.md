# Planning — ai-harness-init

Slice-Lifecycle: `open/` → `next/` → `in-progress/` → `done/`.

Reine `git mv`-Commits beim Wechsel zwischen Verzeichnissen — siehe Hard
Rule „git mv + Inhaltsänderung = zwei Commits" in
[`../../../AGENTS.md`](../../../AGENTS.md).

## Lifecycle-Bedeutungen

| Verzeichnis | Bedeutung |
|---|---|
| `open/` | Geplant, noch nicht priorisiert. Keine Garantie auf Umsetzung. |
| `next/` | Als Nächstes priorisiert. Verantwortlicher zugeordnet (`Verantwortlich:`-Feld im Slice-Kopf). |
| `in-progress/` | Beansprucht: Der `git mv` hierher liegt auf dem **Hauptzweig, vor der Arbeit** — Branch/PR entsteht danach. |
| `done/` | DoD erfüllt, gemerged, Closure-Notiz vorhanden — oder Gegenstand an einen anderen Slice übergegangen oder entfallen: §7 nennt Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer (Baseline-Regelwerk `modul-05-planning-harness.md` §Ein Slice, dessen Gegenstand ein anderer übernimmt). |

## Slices vs. Wellen — zwei Ablagen, dieselbe Regel

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Wann Arbeit eine Welle braucht.

- **Slices** tragen ihren Zustand über das **Verzeichnis**
  (`open/` → `next/` → `in-progress/` → `done/`).
- Eine **Welle** (Bündel von Slices) ebenso: Der Zustand ist die
  Verzeichnis-Position, kein `Status:`-Feld. Der Welle-Plan (`<welle-id>.md`)
  liegt **flach** in `planning/`, solange die Welle läuft, und wandert bei
  Closure per `git mv` nach `done/` — neben seine
  `welle-<Kennung>-results.md`. Den aktiven Durchlauf `open/` → `next/` →
  `in-progress/` durchläuft er nicht; `done/` ist sein einziges
  Lifecycle-Verzeichnis. **Geplante** Wellen haben noch keine Datei — sie
  stehen in der Roadmap, die auch Sequenzierungs-Autorität bleibt
  ([`in-progress/roadmap.md`](in-progress/roadmap.md): Meilensteine, nächste
  Wellen, Zeiger auf die offenen).
- Der aktive Durchlauf `open/` → `next/` → `in-progress/` nimmt ausschließlich
  **Slices** auf; `done/` archiviert **zusätzlich** abgeschlossene
  **Nicht-Slice-Records** — Welle-Plan und Welle-Closure
  `done/welle-<Kennung>-results.md`. Aufgelöste Carveouts wandern **nicht**
  hierher, sondern in ihr eigenes `docs/plan/carveouts/done/` (Baseline-Regelwerk
  `modul-07-carveouts.md`).

### Beobachtungs-Register

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
