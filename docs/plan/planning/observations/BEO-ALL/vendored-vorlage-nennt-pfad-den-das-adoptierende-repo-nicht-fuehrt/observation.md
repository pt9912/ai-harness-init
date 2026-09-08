# Vendored Vorlage nennt Pfad, den das adoptierende Repo nicht führt

**Sub-Area:** `*` (gesamtes Repo)

Eine vendored Ausfüll-Vorlage nennt einen Repo-Pfad als Inline-Code, den ein adoptierendes Repo je
nach Bootstrap-Modus gar nicht führt — und das emittierte Doku-Gate prüft Inline-Code-Pfade auf
Existenz. Jedes daraus kopierte Artefakt trägt den Befund weiter, ohne dass der Kopierende einen
Fehler gemacht hätte. Die Vorlage selbst bleibt stumm, weil `scan.ignore` den vendored Baum
ausnimmt; laut wird erst die Kopie. Der Bestand behilft sich, indem er den Pfad als
**Kommando-Operanden** schreibt, der seine eigene Abwesenheit belegt — eine Praxis ohne Regel und
ohne Sensor.
