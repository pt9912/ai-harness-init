# Ränder des Nachzugs am Doku-Gate: kein Melder oder keine Nennung

**Sub-Area:** `*` (gesamtes Repo)

Der Nachzug in `docs/reviews/` lässt bewusst Formen stehen, die er nicht als Link liest; was danach am
Doku-Gate steht, ist für zwei Formen ungeklärt: Eine tote Referenz-Definition (`[name]: ziel`) erzeugt
keinen Befund — der Wächter der benannten Lücke ist ein `git grep`, kein Gate-Lauf —, und ein Link mit
Anker auf einen umgezogenen Slice fällt auf den gekürzten Stub und meldet `anchor-missing`, was die
Sensor-Doku nicht nennt. Die Fehlerrichtung ist *was der Nachzug stehen lässt, meldet das Gate, und die
Doku sagt es*.

## Benannt, nicht gezählt

[`regel-rand-ohne-benannte-luecke`](../regel-rand-ohne-benannte-luecke/observation.md) trifft den Rand der
Regel selbst, der nicht genannt ist; hier ist die Referenz-Definition benannt und die Wirkung am Gate
offen, und der Anker auf den Stub ist eine Wirkung der Archiv-Form, nicht der Form-Regel.
