# Redundanter Nachlauf-Zustand nach Vorverlagerung

**Sub-Area:** * (gesamtes Repo)

Ein Fix verlagert eine Anlage nach vorne und lässt die Zeilen an der alten
Stelle stehen — auf dem Erfolgspfad No-ops; sitzt der einzige tragende
Kommentar an der Nachlauf-Stelle, reißt ein späterer Lauf, der den
„redundanten" Nachlauf löscht, die Vorbedingung ein, und der Bruch zeigt an
einer unerkennbaren Stelle statt an der Sperre.