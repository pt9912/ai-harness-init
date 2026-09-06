# Positive Meldung im Fehlschlag-Zweig einer Auswertung

**Sub-Area:** `*` (gesamtes Repo)

Eine Auswertung, deren Eingabe unbrauchbar ist, meldet trotzdem positiv: Der Zweig, der den Fehler
sehen müsste, hat keine Wache, gibt seine Diagnose auf `stderr` ab oder gar nicht und endet mit
Exit 0 — der Aufrufer liest ein Urteil, das über nichts gefällt wurde. Das ist die Auswertungs-Hälfte
der Klasse *blind und grün*, die
[`MR-007`](../../../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
Setzung 3 für den Gesamt-Lauf benennt; hier sitzt sie eine Ebene tiefer, in der einzelnen Funktion.

## Benannt, nicht gezählt

Zwei Nachbarklassen sind enger und decken den Fall nicht.
[`gruen-aussage-ohne-herkunft`](../gruen-aussage-ohne-herkunft/observation.md) handelt von einer
Grün-Aussage, die ihre Lauf-Art nicht nennt — dort ist das Urteil gefällt und nur seine Herkunft
offen; hier ist gar keines gefällt worden.
[`zusage-nennt-sensor-der-form-nicht-sieht`](../zusage-nennt-sensor-der-form-nicht-sieht/observation.md)
handelt von einem Geltungsbereich, den der Code darunter nicht hält, nicht vom Ausgang eines
Fehlschlag-Zweigs.
