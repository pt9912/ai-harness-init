# Carveouts — Index

**Modul 7.** Ein Carveout dokumentiert, warum ein Gate an einer Stelle
(noch) nicht hart sein kann — mit einem **prüfbaren Auflösungs-Trigger**, nicht
mit „noch nicht geschafft". Vorlage: carveout.template.md (vendored unter der
Baseline). Aufgelöste Carveouts wandern per `git mv` nach done/ (das Verzeichnis
entsteht bei der ersten Auflösung).

Dieses Verzeichnis kehrt mit dem ersten realen Carveout zurück (Backlog-
Formalisierung 2026-07-21, Roadmap §Backlog Cluster E).

## Aktiv

| ID | Titel | Betroffenes Gate | Angelegt |
|---|---|---|---|
| [CO-001](CO-001-bats-shell-lint.md) | shell-lint deckt die bats-Dateien nicht ab | `shell-lint` | 2026-07-21 |
| [CO-003](CO-003-mutate-ohne-zeitschranke.md) | `make mutate` hat keine Zeitschranke — ein hängender Worker färbt den Lauf nicht rot | keines (`make mutate` ist Nicht-Gate-Verify) | 2026-08-27 |

## Permanent — in eine ADR übergeführt

Nicht aufgelöst, sondern entschieden: der Trigger tritt nicht ein, und die Einordnung steht in
einer ADR. **Was daraus für den Ort folgt, steht nicht hier, sondern in der ADR, die den
jeweiligen Carveout überführt** — je Fall entschieden, mit seiner eigenen Messung. Für den Eintrag
unten ist der Ort **belassen**: die Datei liegt weiter neben den aktiven, und ob sie eine von
ihnen ist, sagt der **Status** in ihrem Kopf. Die Begründung steht an genau einem Ort, der ADR.

| ID | Titel | Übergeführt in | Übergeführt am |
|---|---|---|---|
| [CO-002](CO-002-token-achse-je-rolle.md) | Der `Agent`-Span trägt keine Token-Achse je Rolle | [ADR-0021](../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md) | 2026-08-22 |

## Aufgelöst

_(noch keine)_
