# Idempotente Anlage erreicht den Bestand nicht

**Sub-Area:** `*` (gesamtes Repo)

Ein Ort oder eine Datei, die der Bootstrap neu anlegt, entsteht allein im frischen Ziel: die Anlage
ist *skip-if-present*
([`ADR-0007`](../../../../adr/0007-bootstrap-phasen.md)), und ein bereits gebootstrapptes Repo
bekommt sie nicht. Der Beleg einer solchen Änderung misst darum am frischen Ziel und sagt über den
Bestand nichts — welcher Vorgang den Bestand nachzieht, nennt keine Quelle dieses Repos.

Die Idempotenz-Klasse ist dabei kein Versehen, sondern die getroffene Entscheidung; die Lücke
entsteht daneben, weil der emittierte Text im Bestand denselben Indikativ führt wie im frischen
Ziel und dort auf etwas zeigt, das nicht kommt.
