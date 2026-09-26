**Stand:** geplant — Kennung `slice-sync-waechter-tragen-mutations-faelle` (`open/`: Mutations-Fälle für die `sync`-eigenen Wächter und der Absatz *Grenze* in Schritt 7). Schwelle erreicht (`ls docs/plan/planning/observations/BEO-ALL/zusage-mit-bats-bindung-ohne-eigenen-mutations-fall/evidence/*.md | wc -l` → 3, gelesen 2026-09-26, keine Erwartung).

**Was der Ausgang trägt, und was nicht.** Er gilt für die Instanz, an der die Klasse zum dritten Mal auftrat: der Slice legt die Fälle an, die die `sync`-Zusagen unter `make mutate` stellen. Für die Klasse selbst — jede weitere Zusage mit `bats`-Bindung und ohne Fall — besteht kein Wächter und keine Regel; ob eine gebraucht wird, urteilt der Architect (Übergabe: bestätigt er `geplant` für die Instanz, oder verlangt er eine Regel?). Tritt die Klasse außerhalb von `sync` erneut auf, ist das der Anlass.

Gemeldet wird die Klasse von keinem Sensor: `make mutate` urteilt über seinen **eigenen** Fall-Satz,
und eine Zusage ohne Fall ist für ihn keiner
([`AGENTS.md`](../../../../../../AGENTS.md) §3.6 — *wer keinen Fall in `test/mutations/` hat, ist
unbewacht*). Träger ist das Review, das die Zusagen-Liste eines gelisteten Wächters gegen dessen
Fall-Satz hält.
