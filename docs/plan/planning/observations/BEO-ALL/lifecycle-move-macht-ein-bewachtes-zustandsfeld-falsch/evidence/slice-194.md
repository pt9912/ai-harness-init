**Vorgang:** slice-194
**Fund:** Der Closure-Move macht [`in-progress/`](../../../../in-progress) slice-frei und den
fehlenden Ruhe-Marker *„Nichts in Arbeit."* damit falsch. Das Modul `planning` hält genau diese
Invariante (Grund-Code `planning-drift`), und `make slice-mv` trägt sie nicht — es zieht Pfade
nach, keine Zustandssätze. Zwischen dem Move-Commit und dem Marker-Commit ist `make docs-check`
deshalb rot; die Lücke folgt aus der Trennung von Move und Inhalt
([`AGENTS.md`](../../../../../../../AGENTS.md) §3.3) und nicht aus einem Versäumnis.
