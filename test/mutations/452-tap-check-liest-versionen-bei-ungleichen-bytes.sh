#!/usr/bin/env bash
# files: harness/tools/tap-nachzug-nutzlast.sh
# expect: check liest keine Version: ungleiche Bytes
# verify: test-bats
#
# LAESST EINEN UNTERSCHIED MIT GROESSERER TAP-VERSION ALS GLEICH GELTEN: der Zweig "cmp meldet
# Unterschied" von gleich() liest die version-Zeilen von Asset und Tap und endet mit Status 0,
# wenn die Tap-Version die spaetere ist. Ein Tap, das dem Asset voraus ist, wird damit nie als
# Formel-Unterschied gemeldet.
# Rot faerbt der Fall, dessen Tap bei ungleichen Bytes eine groessere version-Zeile traegt und
# Exit 1, die Meldung des Unterschieds und die Zeile `tap-check: Exit 1` liest. Eine kleinere
# Tap-Version und eine gleiche version-Zeile bei sonst ungleichen Bytes faerbt dieser Fall nicht.
set -euo pipefail
sed -i 's~^\t1) return 1 ;;$~\t1) va=\x24(grep "^  version" "\x24work/asset"); vt=\x24(grep "^  version" "\x24work/tap"); if [ "\x24va" != "\x24vt" ] \&\& [ "\x24(printf "%s\\n%s\\n" "\x24va" "\x24vt" | sort | tail -n 1)" = "\x24vt" ]; then return 0; fi; return 1 ;;~' harness/tools/tap-nachzug-nutzlast.sh
