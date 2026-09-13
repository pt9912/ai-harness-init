**Vorgang:** slice-werkzeug-erkennt-die-benannte-kennung
**Fund:** Der Nachzug des Closure-Move ersetzt in den zwei Review-Reports dieses Slice drei
Pfadangaben, die einen **vergangenen** Aufenthalt bezeichnen und deshalb richtig dastanden. Die
schärfste ist ein zitierter **Messwert**: Runde 2 hielt als Sonden-Ergebnis
`"../../in-progress/slice-…"` fest; nach dem Nachzug steht dort `"../../done/slice-…"` — ein Wert,
den die Sonde nie geliefert hat. Dazu das Feld `**pfad:**` desselben Berichts, das seinen Fund auf
einen Commit datiert (*„in `004335cc`"*), zu dem die Datei in `in-progress/` lag, und eine
Prosa-Adresse des Prüfgegenstands in Runde 1. Alle drei stehen in Backticks und sind keine Links;
die Eingehend-Ersetzung liest die Datei flach und unterscheidet Link-Ziel und Zitat nicht.
`make docs-check` sieht davon nichts — der Schaden fällt still aus, wie die Klasse es beschreibt.
Die Reports selbst bleiben unberührt: Träger ist nach dem Stand dieser Zeile der Lauf, der die
Mess-Aussage schreibt.
