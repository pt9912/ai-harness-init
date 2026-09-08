**Vorgang:** slice-201
**Fund:** Der Verweis-Nachzug des Closure-Move schreibt in den Review-Report dieses Slice —
`make slice-mv SLICE=slice-201 TO=done` meldet vier Dateien mit eingehenden Verweisen, und eine
davon ist ein Rollen-Report unter `docs/reviews/`, der seinen Gegenstand abschließend beurteilt
hat. Drei Zeilen sind ersetzt (ein `pfad:`-Feld, zwei Kommando-Operanden in
Reproduktions-Blöcken), während der Eingangs-Kontext desselben Reports den Plan unverändert
*„gelesen in `in-progress/`"* verortet: Der Report beschreibt nach dem Nachzug einen Baum, den er
nicht gelesen hat. Die Ausnahmeliste des Werkzeugs nimmt allein den vendored Baum aus; dass sie
`docs/reviews/**` einschließt, ist seine dokumentierte Zusage und keine Panne, und genau darum
liegt die Frage beim Architect und nicht beim bewegenden Lauf.
