**Vorgang:** slice-targets-modul-im-emittierten-doc-gate
**Fund:** Das Modul `targets` liest im Ziel jede Makefile-Quelle und beide Index-Teile; seine Laufzeit im Ziel misst kein Lauf — `make full-smoke` urteilt über Exit-Codes, die Verifikation nennt nur die Gesamtdauer des Laufs. Eingetragen als Ausgang *weiter offen* von §6 Risiko 2 dieses Slice.
