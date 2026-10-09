#!/usr/bin/env bash
# files: Makefile
# expect: greift: das Rezept von make mutate-greift faehrt mutate.sh --greift als Prozess ueber das ganze Fall-Set, MUTATE_CASES aus der Umgebung engt es nicht ein
#
# Das Rezept von `make mutate-greift` nimmt MUTATE_CASES nicht mehr aus der Umgebung: ein
# gesetzter Wert engt den Lauf unter `make gates` auf die genannten Faelle ein, und der
# Gate-Stempel deckt einen Baum, ueber dessen uebrige Faelle der Modus nie geurteilt hat.
set -euo pipefail
sed -i 's/^\t@unset MUTATE_CASES; bash harness\/tools\/mutate.sh --greift$/\t@bash harness\/tools\/mutate.sh --greift/' Makefile
