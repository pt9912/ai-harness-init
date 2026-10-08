**Vorgang:** slice-210-planning-modul-im-emittierten-doc-gate
**Fund:** Erstes Auftreten **im gebootstrappten Ziel**. Das Modul `planning` geht ins emittierte
Doc-Gate; dort macht `make slice-mv SLICE=slice-probe TO=in-progress` den Ruhe-Marker
*Nichts in Arbeit.* falsch, und `make docs-check` meldet danach `1 Befund(e)`, `planning-drift`.
Die emittierte `.claude/commands/implement-slice.md` nennt den Nachzug nicht; benannt ist er nur im
Kopfkommentar der emittierten `.d-check.yml` und im Benutzerhandbuch. Die geplante Kennung im Stand
nennt die Ziel-Hälfte in ihrem §1 nicht.
