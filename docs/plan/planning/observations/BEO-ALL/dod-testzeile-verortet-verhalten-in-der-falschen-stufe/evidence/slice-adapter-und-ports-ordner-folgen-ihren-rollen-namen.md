**Vorgang:** slice-adapter-und-ports-ordner-folgen-ihren-rollen-namen

**Fund:** Der Plan verortete seine Fundstellen in der falschen Renderer-Achse:
alle genannten Stellen (Skelett-Pfade, Composition-Root-Imports, Namespaces,
Gate-Glob) liegen im hexslice-Renderer, den der eigene §1 ausschließt; das
hexagonal-Layout ist bereits rollen-konform, und C++ rendert kein hexagonal —
der gebaute Träger steht in der anderen Stufe, die Deckung selbst war nicht
vollständig (die Ports-Achse widerspricht zudem zwei `Accepted`-ADRs).

**Klasse:** derselbe Defekt wie beim Erstfund
(`slice-zielordner-richtet-das-werkzeug-auf-ein-ziel-repo`, F-4): die
DoD-/Plan-Text-Zeile verortet Verhalten an einer Stelle, an der es nicht
liegt — hier zusätzlich an der falschen Layout-Achse. Die Fehlerrichtung ist
Plan-Text hinter dem gemessenen Baum; der Nachzug bleibt beim Planner.

**Lage:** der Vorgang läuft; seine Position im Planning-Lifecycle liest der
Lauf, der diesen Beleg bei der Closure gegen `done/` prüft — die Lage-Prüfung
läuft nach dem Move, der Beleg beansprucht sie hier nicht.