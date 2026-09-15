#!/usr/bin/env bash
# files: harness/tools/commit-msg-traceability.sh
# expect: traeger: Message ohne Kennung wird abgelehnt
# verify: test-bats
#
# NIMMT DEM TRAEGER DIE KENNUNGS-PRUEFUNG: das Muster wird zu ".*", jede Zeile
# gilt damit als Kennung, und der Traeger laesst jede Message durch. Der Hook
# bleibt ansonsten heil — er laeuft, er meldet nichts, er endet mit 0.
#
# DIE STELLE, DIE DER AUFRUFER BENUTZT: Aufrufer ist git ueber den Hook
# .githooks/commit-msg; der reicht die Message-Datei an genau dieses Skript
# weiter. Die bats-Stufe unten faehrt den Aufruf darum UEBER DEN HOOK und nicht
# gegen das Skript direkt — ein Zahn, der die Verdrahtung selbst nachbaut,
# misst sich selbst (die Klasse steht im Beobachtungs-Register).
#
# WARUM die bats-Stufe die schmalste ausreichende ist: gemessen wird das Urteil
# des Traegers ueber eine Message-Datei — bash und coreutils, kein Docker, kein
# d-check-Image. Ein `make full-smoke` haette mit dem Commit-Pfad dieses Repos
# nichts zu tun.
set -euo pipefail
sed -i -E 's@^patterns=.*$@patterns=".*"@' harness/tools/commit-msg-traceability.sh
