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
| [CO-005](CO-005-adaptions-block-datierter-beleg.md) | Ein datierter Beleg im Adaptions-Block hat kein auflösbares Ziel | `docs-check` (Modul `links`) | 2026-08-28 |

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

| ID | Titel | Angelegt | Aufgelöst | Wodurch |
|---|---|---|---|---|
| [CO-003](done/CO-003-mutate-ohne-zeitschranke.md) | `make mutate` hatte keine Zeitschranke — ein hängender Worker färbte den Lauf nicht rot | 2026-08-27 | 2026-08-28 | [slice-117](../planning/done/slice-117-lauf-ohne-ende-faerbt-rot.md) baute die Schranke, [slice-120](../planning/done/slice-120-co-003-wird-vollzogen.md) vollzog ihn |
| [CO-004](done/CO-004-emitter-klassifikation-offen.md) | Der Emitter hatte für vier neue Vorlagen keine Klasse | 2026-08-28 | 2026-08-30 | [slice-130](../planning/in-progress/slice-130-emitter-entscheidet-jedes-neue-template.md) entschied die vier Klassen und vollzog den Übergang: `git mv` nach `done/` als eigener Commit, der Link-Abgleich als zweiter |
