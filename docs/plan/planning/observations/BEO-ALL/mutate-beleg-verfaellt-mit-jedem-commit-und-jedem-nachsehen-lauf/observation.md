# `make mutate`: Der Beleg verfällt mit jedem Commit und mit jedem Nachsehen-Lauf

**Sub-Area:** `*` (gesamtes Repo)

Der Beleg von `make mutate` hängt an einem Schlüssel über den ganzen Baum außer dem Zustands-Bereich
und `.git`. Jeder spätere Commit — auch ein reiner Doku-Commit wie ein Review-Report — entwertet den
Übersprung, und der nächste Lauf fährt voll. Ein Lauf, der den Beleg nur **bestätigen** will
(`timeout 120 make mutate`), löscht den Beleg-Slot, bevor er endet: der Beleg der vorigen Rolle
bleibt als bloße Aussage zurück. Die Fehlerrichtung ist *ein Beleg ist da*.

Beide Eigenschaften sind so gebaut
([`ADR-0035`](../../../../../plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md));
die Beobachtung nennt ihren Preis in einer Sequenz aus Implementer, Reviewer, Verifier und Planner,
von denen jeder nach dem Lauf einen Doku-Commit setzt.

## Benannt, nicht gezählt

[`baum-hash-deckt-nicht-jeden-pruefgegenstand`](../baum-hash-deckt-nicht-jeden-pruefgegenstand/observation.md)
trifft die Gegenrichtung: der Schlüssel deckt **zu wenig**; hier deckt er zu viel, und ein Beleg
lebt kürzer als der Vorgang, der ihn braucht.
