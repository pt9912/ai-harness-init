**Vorgang:** slice-127
**Fund:** Der `vcs:`-Block in [`.d-check.yml`](../../../../../../../.d-check.yml) führte fünf
Schlüssel, sein Wächter `test/vcs-modul-wiring.bats` pinnte vier — ungepinnt blieb ausgerechnet
`status-line`, der Schlüssel, auf dem die zweite Zusage des Slice ruht. Zwei Köpfe behaupteten
dabei die volle Deckung: der des Wächters (*„haelt nur die KONFIGURATION gegen Regression"*) und
[`harness/README.md`](../../../../../../../harness/README.md) (*„hält beide Felder gegen
Regression"*). Entfernt man die eine Zeile, kippt der **erlaubte** Supersede-Übergang von
`0 Befund(e)` auf `1 Befund(e)` `core-drift-vcs` — und alle Wächter bleiben grün: Der genannte
Sensor sieht genau die Form nicht, deren Verlust die Zusage aufhebt. Behoben in derselben Runde
(der Wächter hält seitdem alle vier Felder, dazu die Mutations-Fälle `281`–`284`); der Beleg zählt
das Auftreten, nicht den Reststand.
