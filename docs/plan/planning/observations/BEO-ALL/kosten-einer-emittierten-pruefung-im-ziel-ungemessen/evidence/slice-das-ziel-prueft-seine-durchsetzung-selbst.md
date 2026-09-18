**Vorgang:** slice-das-ziel-prueft-seine-durchsetzung-selbst
**Fund:** Die emittierte Selbstprüfung fährt `make gates` in einem Klon des Ziels; die Stufe des
Emitters ruft sie am **sprachlosen** Ziel, dessen Kette allein das Doku-Gate führt — der billigste
Vertreter. Der Verifikations-Lauf hat daneben ein `--lang go`-Ziel gefahren: dort läuft im Klon die
volle Code-Gate-Kette, Exit 0 und deutlich teurer, gemessen von Hand und von keinem Lauf dieses
Repos. Damit trägt der Emitter-Lauf eine Kosten-Aussage über eine Variante und keine über die, die
ein Adopter typischerweise fährt. Eingetragen als Ausgang *weiter offen* von §6 Risiko 2 dieses
Slice.
