#!/usr/bin/env bash
# files: internal/report/report.go
# expect: TestSchreibe_UnverteilterSammelpostenStehtAusserhalb
#
# Laesst die Ausgabe auch dann "anteilig nach Tool-Calls verteilt" melden, wenn
# gar nichts verteilt werden konnte.
#
# Traegt keine Rolle Tool-Calls, bleibt der Sammelposten in KEINER Zeile und
# damit ausserhalb der Summe. Die Meldung behauptete dann eine Verteilung, die
# nicht stattgefunden hat, und der Prozentsatz bezoege sich auf eine Summe, die
# diese Token nicht enthaelt — er stuende bei 0,00 %, waehrend die Token real
# vorhanden sind. Genau die unvollstaendige Erhebung, die sich wie eine
# vollstaendige liest, gegen die dieser Bericht antritt.
set -euo pipefail
sed -i 's@^\tcase b.Verteilt:$@\tcase true:@' internal/report/report.go
