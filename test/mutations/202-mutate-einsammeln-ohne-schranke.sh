#!/usr/bin/env bash
# files: harness/tools/mutate.sh
# expect: driver: das Einsammeln endet OHNE Hilfe von aussen
#
# Nimmt dem Einsammeln seine Zeitschranke: `wait` steht danach wieder ohne Vorlauf da und
# blockiert unbegrenzt, wenn ein Worker nicht zurueckkommt. Der Lauf endet dann nur noch
# durch Zutun von aussen — und ein Sensor, der schweigend haengt, ist von einem langsamen
# nicht zu unterscheiden.
# Das ist der Zahn zu slice-117 DoD (1). Er trifft die VERDRAHTUNG, nicht die Funktion:
# await_workers bleibt vollstaendig, wird nur nicht mehr gerufen — genau der Zustand, den
# das Review als ungedeckt gemessen hat.
set -euo pipefail
sed -i 's|^  await_workers .*|  :|' harness/tools/mutate.sh
