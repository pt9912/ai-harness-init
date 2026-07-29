#!/usr/bin/env bash
# files: cmd/span-emit/main.go
# expect: TestClampSurvivesBrokenPayload
#
# Laesst den Emitter auf STDOUT schreiben.
#
# ADR-0011 Festlegung 6 setzt zwei Eigenschaften: Exit 0 UND stumme Ausgabe. Fall 107
# deckt nur die erste — er laesst den Emitter ueber den Panic-Pfad enden, und dessen
# Ausgabe geht auf stderr; die stdout-Zusicherung kann dort gar nicht feuern. Der
# Kommentar im Emitter behauptete trotzdem, 107 bewache "beides" (Review-Befund
# HIGH-3). ADR-0011 Folgepflicht 5 verlangt fuer die stdout-Setzung ausdruecklich einen
# eigenen Fall — dies ist er.
#
# Bei Hooks liegt auf stdout der ENTSCHEIDUNGS-Kanal: wer dort schreibt, entscheidet
# ueber Berechtigungen mit, statt zu beobachten. `make lint` faengt das nicht — die
# forbidigo-Regel verbietet die Form `fmt.Print*`, nicht das Schreiben nach stdout.
set -euo pipefail
sed -i 's@^\tpayload, err := io.ReadAll@\tos.Stdout.WriteString("span-emit: laeuft\\n")\n\tpayload, err := io.ReadAll@' cmd/span-emit/main.go
