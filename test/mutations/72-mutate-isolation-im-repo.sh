#!/usr/bin/env bash
# files: harness/tools/mutate.sh
# expect: die isolierte Kopie liegt AUSSERHALB des Repos
#
# Verlegt die isolierte Kopie UNTER das Repo. Fachlich ist das die slice-044-Falle:
# ein ungetracktes Verzeichnis im Working Tree verschiebt den MR-003-Stop-Hook-Hash,
# der Hook feuert dann bei jedem Lauf — und die Mutationen laegen wieder in dem Baum,
# den die lesenden Rollen messen. Die Isolation waere dem Namen nach da und der
# Wirkung nach weg. Doppelte Anfuehrungszeichen mit escaptem Dollar: so traegt das
# Muster den literalen Variablennamen, ohne SC2016 auszuloesen.
set -euo pipefail
sed -i "s|dest=\"\$root/repo\"|dest=\"\$REPO/.mutate-iso\"|" harness/tools/mutate.sh
