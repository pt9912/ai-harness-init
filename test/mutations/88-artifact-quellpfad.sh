#!/usr/bin/env bash
# files: harness/tools/artifact-copy.sh
# expect: artifact-copy nimmt das uebergebene Image und den erwarteten Quellpfad
#
# Verfaelscht den Pfad IM CONTAINER, aus dem kopiert wird. Ohne diesen Fall waere
# ein Tippfehler dort unbemerkt geblieben: die Zieldatei entsteht beim Test
# trotzdem (der Stub schreibt sie), und alle uebrigen Waechter blieben gruen —
# real gegengeprueft, bevor der Waechter geschrieben wurde (Review-Befund INFO-1).
# Mit echtem Daemon faellt der Aufruf dagegen erst zur Release-Zeit auf.
set -euo pipefail
sed -i 's|out/ai-harness-init|out/ai-harness-init-mutiert|' harness/tools/artifact-copy.sh
