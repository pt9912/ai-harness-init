**Vorgang:** slice-stop-hook-bindet-an-den-commit
**Fund:** Der Stop-Hook liegt zweimal im Repo — `.claude/hooks/stop-require-gates.sh` (Dogfood) und
`internal/emit/templates/enforce/stop-require-gates.sh` (Vorlage) —, und die Funktion `head_wert`
steht in vier Kopien (Hook und `record-gates.sh`, je Fassung), gekoppelt nur per Kommentar; kein
textueller Sensor hält sie gegeneinander. Der Go-Test fährt beide Fassungen über denselben Fällen
und deckt damit Verhaltens-Drift der §4-Klassen; die Mutationsfälle in `test/mutations/` zielen
aber allein auf die Vorlage, und die Streichung der Dogfood-Zeile aus der Fassungs-Liste des Tests
färbt nichts (Review INFO-1). Den Rot-Beleg für die Dogfood-Fassung trug die Verifikation einmal
von Hand nach; ein dauerhafter Fall fehlt.
