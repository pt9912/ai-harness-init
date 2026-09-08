# Mutations-Fall überlebt die Umbenennung seines Wächters

**Sub-Area:** `*` (gesamtes Repo)

Ein Mutations-Fall zitiert in seiner `# expect:`-Zeile den **Titel** des Wächters, dessen Rot er
erwartet. Wird der Wächter umbenannt, reist die Fall-Datei nicht mit: Die Mutation trifft weiterhin,
der Wächter fällt weiterhin — aber der Treiber findet den zitierten Titel in keiner Fehlschlag-Zeile
und meldet fail-closed *„falscher Grund"*. Der Lauf ist damit rot aus einem
Buchhaltungs-Grund, während die Sache in Ordnung ist; wer die Meldung für einen Sachbefund hält,
sucht am falschen Ende, und wer sie für Rauschen hält, gewöhnt sich das Rot an.

Die Nachbarklasse
[`mutations-fall-zeigt-auf-falsche-datei`](../mutations-fall-zeigt-auf-falsche-datei/observation.md)
teilt die Ursache — eine Kopplung, die einen Umzug nicht überlebt — und hat die **entgegengesetzte
Fehlerrichtung**: Dort nennt der Fall die falsche Datei, trifft nichts und bleibt **grün**, also
still. Hier ist die Datei richtig, der Fall trifft, und der Lauf wird **laut**. Beide sind
Kopplungs-Brüche, aber ein Sensor, der den einen fängt, fängt den anderen nicht.
