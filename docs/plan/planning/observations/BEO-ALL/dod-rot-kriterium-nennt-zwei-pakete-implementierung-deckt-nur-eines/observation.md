# Ein DoD-Rot-Kriterium nennt zwei Pakete, der erste Anlauf deckt nur eines

**Sub-Area:** `*` (gesamtes Repo)

Ein DoD-Punkt verlangt wörtlich einen Test über zwei benannten Paketen, weil der gebundene Pfad
durch beide läuft. Die fachliche Fallunterscheidung sitzt oft nur in einem der beiden — das andere
trägt nur die Verdrahtung (z. B. eine Argument-Durchreichung ohne eigene Verzweigung). Ein erster
Anlauf, der nur das Paket mit der Fallunterscheidung testet, wirkt vollständig, deckt das
Rot-Kriterium aber nicht ein: Ein Rot-Kriterium, das zwei Pakete nennt, ist erst eingelöst, wenn
beide real getestet sind, auch wenn die fachliche Entscheidung nur in einem liegt — der zweite Test
deckt dann die Verdrahtung, nicht die Logik.
