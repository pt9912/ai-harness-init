**Vorgang:** slice-073
**Fund:** Der Verweis-Nachzug hat in diesem Vorgang zweimal in eingefrorene Zeitdokumente
geschrieben. Beim Lifecycle-Übergang eines Nachbar-Slice traf er
`docs/plan/planning/done/slice-190-bootstrap-legt-die-versprochenen-orte-an.md` und den
Review-Report `docs/reviews/2026-09-10-slice-073-emittierte-doc-gate-module.md` — im ersten Fall
steht danach ein Link auf `next/` neben einem Prosa-Satz, der dieselbe Datei unverändert in `open/`
verortet: Der Nachzug bewegt Pfade, keine Zustandssätze.

Vor dem Closure-Move dieses Slice ist die Lage nach
[`AGENTS.md`](../../../../../../../AGENTS.md) §3.11 Absatz 2 über **beide** Adress-Formen gemessen —
über die eingefrorenen Artefakte des Repos (ADR ab `Accepted`, Rollen-Report, Zeitdokument in
`done/`): **14** nennen die bewegte Datei als Markdown-Link, **1** als Code-Span. Der Move schreibt
damit in fünfzehn Artefakte, die nach §3.4 unveränderlich sind. Entschieden ist der Nachzug — die
Alternative wäre, fünfzehn tote Adressen zu hinterlassen —, und der Preis steht hier statt
weggeredet zu werden.
