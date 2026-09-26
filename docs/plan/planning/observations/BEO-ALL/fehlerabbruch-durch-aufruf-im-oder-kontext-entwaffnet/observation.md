# Fehlerabbruch durch Aufruf im `||`-Kontext entwaffnet

**Sub-Area:** `*` (gesamtes Repo)

Ein Skript unter `set -e` bricht bei einem Fehler in einer Funktion ab, solange die Funktion als bloßer
Aufruf steht. Wird derselbe Aufruf um `|| …` ergänzt — hier, um den Status auszuwerten oder eine Schleife
fortzusetzen —, gilt `set -e` im **gesamten Funktionsrumpf** nicht mehr, auch nicht für die Zeilen, die die
Änderung nicht berühren wollte. Der Helfer darunter läuft nach einem Fehler weiter, kann Folgeschaden
anrichten (eine geleerte Zieldatei) und meldet Erfolg. Die Fehlerrichtung ist *ein Fehler bricht ab*; die
Änderung der Aufrufform liest sich im Diff nicht als Änderung der Fehlersemantik.

## Benannt, nicht gezählt

[`positive-meldung-im-fehlschlag-zweig`](../positive-meldung-im-fehlschlag-zweig/observation.md) trifft die
Folge — eine Erfolgsmeldung im Zweig, der den Fehler sehen müsste — in einer einzelnen Funktion; hier ist die
Ursache die Aufrufform, und der Abbruch entfällt für einen Rumpf, der ihn vorher trug.
