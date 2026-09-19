# Rest-Vektoren am Init-Dispatch bleiben ungemessen

**Sub-Area:** * (gesamtes Repo)

Der Init-Dispatch trägt drei Sperren — fehlendes Argument, mehr als ein
Positionsargument, Ziel ohne `.git` —; falsch positionierte Argumente und
unbekannte Flags tragen keine, und ein einzelnes Positionsargument, das
zufällig ein bestehendes Git-Repo benennt, wird als Zielordner gelesen. Die
Abgrenzung steht dokumentiert im Code-Kommentar; kein Test misst sie.