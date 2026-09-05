# Verweise brechen beim Ortswechsel

**Sub-Area:** `*` (gesamtes Repo)

Der Abgleich nach einem Lifecycle-`git mv` läuft von Hand, und eine Adresse auf eine Slice-Datei
tritt in mehreren Formen auf, die dabei regelmäßig brechen — 13 gemessene Präfix-Formen plus eine
14., präfixlose Form ganz ohne Verzeichnis-Segment, die als einzige in beide Richtungen bricht
(Ziel wegzieht und tragende Datei wegzieht).
