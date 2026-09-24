# Shell-Nachbau ohne Tokenizer deckt nicht jede Eingabe-Klasse

**Sub-Area:** `*` (gesamtes Repo)

Ein Wächter bildet eine Eigenschaft der Shell-Zerlegung nach — Wortgrenze, Rand eines
Zuweisungs-Werts, Operator — ohne Tokenizer, und seine Tabelle hält die Fälle, die sie nennt, nicht
die Eingabe-Klassen daneben. Die Fehlerrichtung ist *die Grenze ist bestimmt*: Der Nachbau nennt die
Wortgrenze der Bibliothek, die Shell führt eine andere, und der Unterschied zeigt sich erst an einer
Eingabe, die niemand in die Tabelle schrieb.

## Benannt, nicht gezählt

Die Klasse ist die Lage, in der ein Tokenizer die Stichprobe ersetzen würde; ein Tokenizer ist ein
anderer Gegenstand, den die Slices zum `program`-Feld ausdrücklich ausschließen.
