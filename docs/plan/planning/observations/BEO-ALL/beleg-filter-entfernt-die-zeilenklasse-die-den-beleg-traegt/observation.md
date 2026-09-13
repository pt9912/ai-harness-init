# Beleg-Filter entfernt die Zeilenklasse, die den Beleg trägt

**Sub-Area:** `*` (gesamtes Repo)

Ein Beleg-Kommando über einem Diff filtert Rauschen heraus — Diff-Kopfzeilen, umformatierte
Tabellen — und nimmt dabei die Zeilenklasse mit, die den Gegenstand trägt: Markdown-Tabellen- und
Listenzeilen. Das Kommando läuft und gibt aus, was danebensteht; sehen kann es die behauptete
Eigenschaft strukturell nicht. Die Fehlerrichtung ist *keine Inhaltsänderung* statt *diese Zeilen
haben sich geändert*.

## Benannt, nicht gezählt

Zwei Nachbarklassen sind enger und decken den Fall nicht:
[`zitat-grep-uebersieht-zeilenumbruch-und-markup`](../zitat-grep-uebersieht-zeilenumbruch-und-markup/observation.md)
setzt ein Muster voraus, das an einem Zeilenumbruch oder an Inline-Markup *zerbricht* — hier ist
das Muster intakt und die geprüfte Menge beschnitten;
[`zahl-neben-nie-gefahrenem-kommando`](../zahl-neben-nie-gefahrenem-kommando/observation.md) setzt
ein Kommando voraus, das nie lief — dieses lief.
