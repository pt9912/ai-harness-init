# Vendored Baum entsteht aus anderer Quelle als sein Pin

**Sub-Area:** `*` (gesamtes Repo)

Der committet vendored Fremd-Baum wird von Hand aus einer anderen Quelle erzeugt, als der Pin
neben ihm beschreibt — aus dem `git`-Baum des Ursprungs-Repos statt aus dem Release-Asset, dessen
sha256 die Pin-Stellen nennen. Beide Quellen tragen denselben Regel-Text, aber nicht dieselben
Bytes: Das Release-Verfahren schreibt repo-relative Links in absolute, tag-gepinnte URLs um, weil
das Asset außerhalb seines Repos ausgepackt wird. Der Baum trägt danach Adressen, die in keinem
adoptierenden Repo auflösen, und **kein Sensor hält die beiden Seiten gegeneinander**:
`make regelwerk-check` hasht die Roh-Bytes des ZIP (`unpack: none`) und sieht den Baum nie,
`make baseline-verify` hält den Baum gegen ein `SHA256SUMS`, das derselbe Vorgang selbst erzeugt
hat. Die Lücke hängt am Vendoring-Vorgang, und der hat in diesem Repo keinen `make`-Träger.

## Benannt, nicht gezählt

Ob dieselbe Abweichung schon in einem früheren Tag lag, ist **in diesem Repo nicht messbar** und
darum hier nicht beziffert: Der Herkunfts-Kommentar, an dem die zwei Quellen sich unterscheiden
lassen, ist eine Neuerung des Ziel-Stands — der abgelöste Baum trägt ihn in keiner Datei
(`git grep -lE '<!-- Quelle: ' 697b772^ -- '.harness/baseline'` gegen dieselbe Frage am heutigen
Baum). Eine Aussage über frühere Tags stützt sich auf einen Diff gegen den lokalen Kurs-Klon, also
auf eine **Host-Voraussetzung** und kein Artefakt dieses Repos.
