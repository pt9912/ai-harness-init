# Änderung nach der letzten Review-Runde bleibt ungesehen

**Sub-Area:** `*` (gesamtes Repo)

Nach dem letzten Report eines Reviewers ändert der Implementer noch Code, Tests, Mutations-Fälle oder eine Sensor-Doku. Kein Reviewer liest diese Commits, der Verifier misst sie, und der Planner schließt ohne weitere Runde. Reviewer und Verifier stellen verschiedene Fragen — der Reviewer prüft den Diff gegen Plan, ADR und Hard Rules, der Verifier gegen DoD und Spec —, und die erste Frage stellt an den Nachrunden-Diff niemand. Die Fehlerrichtung ist *der Stand, der schließt, ist reviewt*.
