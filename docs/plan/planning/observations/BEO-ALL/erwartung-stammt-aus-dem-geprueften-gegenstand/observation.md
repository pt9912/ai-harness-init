# Erwartung stammt aus dem geprüften Gegenstand

**Sub-Area:** `*` (gesamtes Repo)

Eine Assertion leitet ihren Erwartungswert aus derselben Quelle ab, die sie prüft, und kann damit
unter keiner Mutation rot werden: sie vergleicht einen Teilstring mit einer Zeile, die ihn durch
Konstruktion enthält, oder sie liest die Klasse je Pfad aus der Aufzählung, deren Klasse sie
halten soll. Der Test trägt den Namen einer Eigenschaft und misst die Übereinstimmung mit sich
selbst; die Fehlerrichtung ist *die Zusage ist gehalten*, wo nichts sie halten kann.

## Benannt, nicht gezählt

Zwei Nachbarn teilen das stille Grün und nicht den Mechanismus.
[`zusicherung-ueber-der-leeren-menge-wahr`](../zusicherung-ueber-der-leeren-menge-wahr/observation.md)
ist eine Negation über einer Menge, die wegfällt; hier ist die Menge da und die Erwartung fällt mit
dem Geprüften zusammen.
[`weite-assertion-verdeckt-die-bindung-der-engen`](../weite-assertion-verdeckt-die-bindung-der-engen/observation.md)
hat zwei Assertions verschiedener Weite, von denen die weite die enge verdeckt; hier ist die Assertion
allein und ohne Gegenüber.
