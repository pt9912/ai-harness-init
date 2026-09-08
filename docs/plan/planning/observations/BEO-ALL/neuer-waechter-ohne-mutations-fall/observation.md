# Neuer Wächter ohne Mutations-Fall

**Sub-Area:** `*` (gesamtes Repo)

Ein Slice legt einen neuen Wächter an — Test-Fälle über frisch geschriebener Verdrahtung — und
kein Fall in `test/mutations/` nennt die neue Datei. Nach der Feststellung des Repos *„wer keinen
Fall in `test/mutations/` hat, ist unbewacht"*
([`AGENTS.md`](../../../../../../AGENTS.md) §3.6) kann der Wächter seine Zähne verlieren, ohne dass
ein Lauf davon spricht: `make mutate` meldet jeden **gelisteten** Wächter, der grün bleibt, und
eine fehlende Listung ist für ihn kein Fall.

## Benannt, nicht gezählt

Zwei Nachbarklassen setzen einen **vorhandenen** Fall voraus und decken den Fall darum nicht:
[`mutations-fall-deckt-den-lauten-statt-den-stillen-pfad`](../mutations-fall-deckt-den-lauten-statt-den-stillen-pfad/observation.md)
— der Fall existiert und trifft die laute Stelle — und
[`mutations-fall-zeigt-auf-falsche-datei`](../mutations-fall-zeigt-auf-falsche-datei/observation.md)
— der Fall existiert und trifft nach einem Umzug gar nichts mehr. Hier existiert keiner.
