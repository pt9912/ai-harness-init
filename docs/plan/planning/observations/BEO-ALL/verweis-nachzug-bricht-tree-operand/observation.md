# Verweis-Nachzug bricht Tree-Operand

**Sub-Area:** `*` (gesamtes Repo)

Der Verweis-Nachzug eines Lifecycle-Moves ersetzt auch den Pfad, der als Tree-Operand an einer
Commit-Kennung hängt (`<sha>:<pfad>`) — dort ist der alte Pfad der richtige, und die Ersetzung
macht aus einem laufenden Kommando eines, das `fatal` meldet.
