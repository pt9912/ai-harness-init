#!/usr/bin/env bash
# files: cmd/ai-harness-init/main.go
# expect: TestClampSurvivesBrokenPayload
# verify: test-go
#
# Haengt den `span-emit`-Zweig des Unterkommando-Dispatchs auf die AUSWERTUNG um.
#
# Seit ADR-0022 Festlegung 2 tragen Schreiber und Auswertung KEINE eigenen Binaries
# mehr; welcher der beiden laeuft, entscheidet allein der Zweig in main(). Damit ist
# das Routing selbst tragend geworden: es steht zwischen dem Hook und den zwei
# Eigenschaften aus ADR-0011 Festlegung 6. Ein falsch geroutetes `span-emit` sieht im
# Betrieb aus wie Erfolg — kein Absturz, kein Hinweis —, schreibt aber keinen Span und
# gibt auf stdout aus, wo der Entscheidungs-Kanal der Hooks liegt.
#
# Warum diese Mutation und nicht ein verstellter Vergleichs-String: ein Zweig, der gar
# nicht mehr trifft, faellt in den Init-Pfad durch, und der holt die Baseline. Der
# Fall waere dann rot ueber einen Netz-Zugriff statt ueber den Waechter. Diese Fassung
# bleibt im Prozess und faellt sofort.
set -euo pipefail
sed -i 's@^\t\t\tspanEmit(os.Stdin)$@\t\t\tos.Exit(spanReport(os.Args[2:], os.Stdout, os.Stderr))@' cmd/ai-harness-init/main.go
