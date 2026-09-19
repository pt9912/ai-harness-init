# Ohne Argument startet das Werkzeug den Init-Pfad

**Sub-Area:** * (gesamtes Repo)

Ein Aufruf des Trägers (`.harness/state/bin/ai-harness-init`) **ohne Argument**
fällt in den Init-Pfad — der Dispatch führt seine Unterkommando-Fälle und keinen
Default-Zweig — und fährt einen Bootstrap-Lauf gegen das Repo, in dem er steht.
Die Fehlerrichtung ist *still wirksam statt laut abweisend*: Ein Aufruf, der
nichts bewegen soll, überschreibt Adopter-Inhalt.