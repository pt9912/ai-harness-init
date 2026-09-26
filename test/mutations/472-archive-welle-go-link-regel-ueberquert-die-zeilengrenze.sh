#!/usr/bin/env bash
# files: internal/archive/refs.go
# expect: TestNachziehenUnterReviewsUeberquertKeineZeilengrenze
# verify: test-go
#
# LAESST DIE LINK-REGEL UEBER DIE ZEILENGRENZE HINWEG SUCHEN: der Praefix-Teil des
# Musters in praefixLinkRE nimmt danach `\n` aus beiden Zeichenklassen. Ein "](" am
# Zeilenende und eine Adresse, die erst in einer spaeteren Zeile steht, gelten
# dann als Link-Ziel und werden umgeschrieben — ein Umbruch im Fliesstext eines
# Reports wird zum Link.
#
# WAS DAS MISST: der Fall traegt zwei Umbrueche (die Adresse mitten in der
# Folgezeile und am Zeilenanfang) und einen echten Link, und liest den ganzen
# Dateiinhalt, den Zaehler und das Nachziehen-Ergebnis. Faellt nur die eine der
# zwei Klassen (`[^)#\n]*` oder die einzelne Zeichenklasse), faerbt einer der
# beiden Umbrueche; die Mutation nimmt beide.
#
# Der Anker ist derselbe Praefix-Teil wie in 471 und steht genau einmal in refs.go
# (grep -cF '(?:[^)#\n]*[^A-Za-z0-9_)#\n-])?' internal/archive/refs.go -> 1).
set -euo pipefail
sed -i 's~[[]^)#\\n]\*[[]^A-Za-z0-9_)#\\n-]~[^)#]*[^A-Za-z0-9_)#-]~' internal/archive/refs.go
