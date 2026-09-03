#!/usr/bin/env bash
# files: cmd/ai-harness-init/main.go
# expect: TestSubkommandoRouting_ArchiveWelleFaelltNichtInDenInitPfad
# verify: test-go
#
# Haengt den `archive-welle`-Zweig des Unterkommando-Dispatchs auf die
# Span-Auswertung um.
#
# Der Zweig steht zwischen dem Aufrufer und der einen Eigenschaft, die dieses
# Unterkommando traegt: es schreibt nichts. Trifft er nicht mehr, faellt
# `archive-welle` in run() durch — dort ist der Name ein Positionsargument, das
# der Flag-Parser stehen laesst, und der Init-Pfad legt ein Repo im
# Arbeitsverzeichnis an. Im Betrieb sieht das nicht nach einem Fehler aus: der
# Aufrufer bekommt eine Ausgabe und einen Exit-Code, nur eben die einer anderen
# Faehigkeit.
#
# Warum das Umhaengen und nicht ein geloeschter `case`: ein Zweig, der gar nicht
# mehr trifft, laeuft in den Init-Pfad und der holt die Baseline. Der Fall waere
# dann rot ueber einen Netz-Zugriff statt ueber den Waechter. Diese Fassung
# bleibt im Prozess und faellt sofort — an Exit-Code und stdout; die
# Verzeichnis-Pruefung des Falls faengt die andere Richtung.
set -euo pipefail
sed -i 's@^\t\t\tos.Exit(archiveWelle(os.Args\[2:\], os.Stdout, os.Stderr))$@\t\t\tos.Exit(spanReport(os.Args[2:], os.Stdout, os.Stderr))@' cmd/ai-harness-init/main.go
