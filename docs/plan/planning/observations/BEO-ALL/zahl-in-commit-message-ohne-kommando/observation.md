# Zahl in der Commit-Message ohne Kommando

**Sub-Area:** `*` (gesamtes Repo)

Eine Commit-Message nennt einen Messwert ohne das Kommando, das ihn ausgibt, obwohl
[`MR-051`](../../../../../../harness/conventions.md#mr-051) Setzung 1 die Message bindet. Ab dem Push ist die
Message unveränderlich; ein Befund darüber lässt sich zählen, aber nicht mehr beheben.

Die Nachbarklasse
[`zahl-ohne-kommando-trifft-ihren-gegenstand-nicht`](../zahl-ohne-kommando-trifft-ihren-gegenstand-nicht/observation.md)
verlangt eine Zahl, die ihren Gegenstand verfehlt, in einem lebenden Artefakt. Hier kann die Zahl
stimmen, und ihr Träger ist die Message.

Ein Wächter besteht nicht: Der `commit-msg`-Träger und
[`make commit-msg-check`](../../../../../../harness/sensors/commit-msg-check.md) prüfen die Kennung, nicht
Zahlen. Träger ist der Lauf, der die Message schreibt.
