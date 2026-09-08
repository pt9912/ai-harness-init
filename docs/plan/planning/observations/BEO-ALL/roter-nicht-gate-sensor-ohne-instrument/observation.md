# Roter Nicht-Gate-Sensor ohne Instrument

**Sub-Area:** `*` (gesamtes Repo)

Ein Sensor, der ausdrücklich **kein** Gate ist (Nicht-Gate-Verify), steht rot aus einem bekannten,
außerhalb des laufenden Slice verorteten Grund — und die Closure hat für diese Lage keine Form. Der
Standard-Punkt der DoD-Vorlage nennt ihn absolut (*„`make mutate` ohne Befund"*) und kennt keinen
Ausgang für einen fremden Vorbefund; das Instrument, das einen roten Status an einen Trigger bindet,
ist der **Carveout**, und der bindet nach Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln an ein **Gate**. Übrig bleiben zwei falsche Wege: den Punkt
stillschweigend abhaken, oder ihn unerfüllt stehen lassen, ohne dass irgendwo steht, warum das
den Abschluss nicht hindert.

Die Nachbarklasse
[`rotes-gate-mit-diagnose-ohne-angenommenen-traeger`](../rotes-gate-mit-diagnose-ohne-angenommenen-traeger/observation.md)
teilt das Symptom und nicht die Ursache: Dort **besteht** das Instrument und nur der Schritt fehlt,
der vor der Closure prüft, ob einer liegt. Hier greift es gar nicht erst, weil der rote Sensor
kein Gate ist — ein Carveout darauf wäre die Fehlanwendung, nicht die Abhilfe.
