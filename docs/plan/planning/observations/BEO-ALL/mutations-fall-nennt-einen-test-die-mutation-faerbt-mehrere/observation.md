# Mutations-Fall nennt einen Test, die Mutation färbt mehrere

**Sub-Area:** `*` (gesamtes Repo)

Ein Fall in `test/mutations/` nennt in `# expect:` **einen** Test, und dieselbe Mutation färbt einen
zweiten Test rot, der dieselbe Quell-Stelle bindet. Eine Gegenprobe, die nur die Zusicherung des
benannten Tests abschwächt, lässt den Fall rot; grün wird er erst, wenn in **allen** bindenden Tests
die geschützten Zeilen fehlen. Die Zusage *ein Fall, der bei geschwächter Zusicherung noch rot wird,
deckt einen anderen Zweig* ist damit am einzelnen Test nicht ablesbar: der Rest-Rot kann derselbe
Zweig in einem Nachbar-Test sein.

Nachbarklasse ist
[`zeichenmenge-mitglied-ohne-eigenen-zahn`](../zeichenmenge-mitglied-ohne-eigenen-zahn/observation.md):
dort hat ein Mitglied **keinen** eigenen Zahn; hier hat es einen, und ein zweiter Test bindet
dieselbe Stelle mit.
