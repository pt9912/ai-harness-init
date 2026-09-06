**Stand:** offen

Die geschlossene Menge der drei Ausgänge steht in der Baseline, nicht in diesem Repo — eine
repo-seitige Antwort wäre ein Architect-Artefakt (Hard Rule oder Adaptions-Eintrag,
[`AGENTS.md`](../../../../../../AGENTS.md) §3.8), eine baseline-seitige ein Delta gegen den
adoptierten Stand. Ein Wächter besteht nicht: Kein Modul aus `modules:` der
[`.d-check.yml`](../../../../../../.d-check.yml) hält den Zähler eines Eintrags gegen den Zeitpunkt
seines Ausgangs, und die Register-Paarung prüft Deckung, nicht Wachstum.
