# Kosten einer emittierten Prüfung im Ziel ungemessen

**Sub-Area:** `*` (gesamtes Repo)

Eine emittierte Prüfung ruft die Gate- oder Bau-Kette **des Ziels** auf, und was dieser Aufruf im
Adopter-Repo kostet, misst dieses Repo nicht: Der Emitter-Lauf nimmt für seine Messung die
billigste Ziel-Variante, und die Laufzeit-Aussage, die daraus entsteht, gilt nur für sie. Ein Ziel
mit voller Code-Gate-Kette zahlt ein Vielfaches, ohne dass ein Lauf hier das je sähe.

Die Nachbarklasse
[`emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht`](../emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht/observation.md)
misst eine **Aussage** gegen das, was im Ziel wirklich geschieht; hier ist die Aussage richtig und
ihr **Preis** an nur einer Variante gemessen.
