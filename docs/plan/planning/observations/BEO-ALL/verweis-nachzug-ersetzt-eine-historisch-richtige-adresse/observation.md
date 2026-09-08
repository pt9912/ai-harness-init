# Verweis-Nachzug ersetzt eine historisch richtige Adresse

**Sub-Area:** `*` (gesamtes Repo)

Der Verweis-Nachzug eines Lifecycle-`git mv` ersetzt jeden Pfad, der die bewegte Datei nennt — auch
den, der einen **vergangenen** Aufenthalt bezeichnet und deshalb richtig ist, wie er dasteht. Die
Fehlerrichtung ist *das Kommando läuft weiter und misst etwas anderes*: Eine Pfadangabe in einer
Mess-Aussage über die Vergangenheit — die Pathspec eines `git log`, die Adresse in einer
Reihenfolge-Behauptung — bleibt nach der Ersetzung syntaktisch gültig und beantwortet eine andere
Frage, ohne zu scheitern.

Ein Nachbar teilt die Ursache und nicht den Ausgang:
[`verweis-nachzug-bricht-tree-operand`](../verweis-nachzug-bricht-tree-operand/observation.md)
trifft die Form `<sha>:<pfad>`, in der dieselbe Ersetzung das Kommando `fatal` melden lässt — dort
fällt der Schaden laut aus, hier still. Wer nur die laute Form kennt, hält den Nachzug an dieser
Stelle für unauffällig.
