# Rotes Gate mit Diagnose, aber ohne angenommenen Träger

**Sub-Area:** `*` (gesamtes Repo)

Ein Gate steht rot, die Ursache ist vollständig diagnostiziert und die Abhilfe benannt — aber das
Instrument, das den roten Status an einen **Trigger** bindet, ist nicht angelegt. Der Slice führt
das grüne Gate zugleich als Liefer-Punkt und als Closure-Kriterium, und beides ist unerreichbar,
solange die Diagnose kein Artefakt hat. Die Fehlerrichtung ist *die Ursache ist doch verstanden*
statt *ein verstandenes Rot ist noch kein gehaltenes Rot*: Der Preis fällt nicht beim Verstehen an,
sondern beim nächsten Lauf, der ein rotes `make gates` vorfindet und aus dem Repo nicht erfährt,
ob es geduldet ist.
