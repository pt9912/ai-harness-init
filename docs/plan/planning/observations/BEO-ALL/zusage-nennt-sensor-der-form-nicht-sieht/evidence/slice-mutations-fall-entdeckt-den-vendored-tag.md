**Vorgang:** slice-mutations-fall-entdeckt-den-vendored-tag
**Fund:** Zwei Zusagen über neuem Code nannten einen Geltungsbereich, den der Code nicht hält.
**Erstens** sagten Skript-Kopf und Sensor-Vertrag für **beide** Leser der `# files:`-Zeile
dieselbe Fehlschlag-Form zu — *„bricht den Lauf laut ab und nennt den Fall (`mutation_targets`
bzw. `run_case`)"*; in `run_case` bricht nichts ab, dort steht `report_fail`, und die übrigen
Fälle laufen weiter. Die Korrektur differenzierte die zwei Leser, ließ aber den **zweiten
Aufrufer** von `mutation_targets` außen vor (der Lauf ruft es nach dem Fall-Satz erneut, dort wird
derselbe Rückgabewert zu `report_fail "host-baum"` statt zu einem Abbruch) und eine **dritte
Stelle** auf der alten, vereinheitlichten Fassung. **Zweitens** nennt der Funktionskopf die
Eingabe *„Bash-Glob oder literaler Pfad"*, während jede Angabe durch `compgen -G` läuft: ein
literaler Pfad mit Glob-Metazeichen im Namen löst nicht auf. Beide sind dieselbe Klasse und
bekommen darum **einen** Beleg; der Review-Report führte sie als zwei neu erfundene Namen
(`zusage-vereinheitlicht-zwei-stellen-mit-verschiedener-fehlschlag-form`,
`eingabe-klasse-im-kopf-weiter-gefasst-als-die-verarbeitung`) — die Closure hat sie auf diesen
Eintrag zurückgeführt, statt den Zähler zu spalten.
