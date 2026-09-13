**Vorgang:** slice-sprung-auf-v680-wird-vollzogen
**Fund:** Der Closure-Move macht die Zeile *„In Arbeit: …"* unter *Offene Wellen* der Roadmap
falsch — das Feld, das das Modul `planning` gegen den Inhalt von
`docs/plan/planning/in-progress/` hält. [`make slice-mv`](../../../../../../../harness/sensors/slice-mv.md)
zieht Pfade nach, keine Zustandssätze (Grenze 1 seines Skriptkopfs), und der präfixlose Verweis
**in** dieser Zeile fällt zusätzlich unter Grenze 3 — der Lauf meldete **0** eingehend und **0**
ausgehend, obwohl die Roadmap auf die bewegte Datei zeigte. Beide Defekte hat derselbe Handgriff
behoben, weil die Zeile im Ganzen durch den Ruhe-Marker ersetzt wird; ein Repo, dessen
Zustandsfeld den Zeiger **nicht** enthält, hätte zwei getrennte Schritte.
