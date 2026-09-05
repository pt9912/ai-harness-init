# Zitat-Grep übersieht Zeilenumbruch und Markup

**Sub-Area:** `*` (gesamtes Repo)

Ein `grep` auf einen zitierten Baseline-Satz gibt 0 aus, obwohl der Satz wörtlich am geprüften
Stand steht — ein Zeilenumbruch oder ein Inline-Markup innerhalb des Zitats trennt das Muster; die
Fehlerrichtung ist *der Satz ist fort* statt *der Satz steht*.
