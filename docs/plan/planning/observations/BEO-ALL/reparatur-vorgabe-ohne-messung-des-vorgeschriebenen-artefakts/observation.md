# Reparatur-Vorgabe ohne Messung des vorgeschriebenen Artefakts

**Sub-Area:** `*` (gesamtes Repo)

Eine prüfende Rolle benennt in ihrem Report nicht nur den Befund, sondern den **Weg** seiner
Erledigung — *„der Befund fällt, wenn X zurückkehrt"* —, ohne X selbst gemessen zu haben. Die
ausführende Rolle liefert X, weil es die verlangte Handlung ist; die nächste Runde findet in X
denselben Fehler noch einmal und meldet ihn der ausführenden Rolle. Die Schleife verlängert sich
um eine Runde, und ihr Verursacher steht auf der Seite, die prüft.

Die Klasse liegt **über** den Rollen und nicht in einer: Ihr Gegenmittel ist keine Regel für
Reviewer und keine für Implementer, sondern die Trennung von *Befund* und *Vorgabe* — ein Report
darf sagen, was nicht hält, und muss messen, was er statt dessen vorschreibt. Sie hat eine
Spiegelform, die dieselbe Ursache hat: eine prüfende Rolle bestätigt eine Formulierung, weil sie
aus dem eigenen Strang stammt, statt die Eigenschaft unabhängig zu messen.

Die Nachbarklasse
[`uebergabe-an-andere-rolle-ohne-traeger-artefakt`](../uebergabe-an-andere-rolle-ohne-traeger-artefakt/observation.md)
deckt den Fall nicht: dort fehlt das Übergabe-Artefakt, hier ist es da und trägt eine ungemessene
Anweisung.
