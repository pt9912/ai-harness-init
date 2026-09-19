#!/usr/bin/env bash
# files: harness/tools/full-smoke.sh
# expect: full-smoke: FEHLER — sprachlos: harness/conventions.md fehlt im Ziel — die drei Aussagen ueber den mitgelieferten Baum haetten keinen Ort.
# verify: full-smoke
#
# VERTAUSCHT DAS ZIEL IM ZWEITEN DER ZWEI VARIANTEN-AUFRUFE.
#
# baum_aussagen_im_ziel steht einmal und wird zweimal gerufen — fuer das Ziel mit `--lang go`
# und fuer das sprachlose. Der Operand schickt den zweiten Aufruf auf ein Verzeichnis, unter
# dem keine emittierte harness/conventions.md liegt: die conventions-Assertion faengt das
# falsch-gzielte Ziel mit ihrer benannten Meldung, statt still durchzulaufen. An einem
# Ziel ohne .git bricht der Init-Bootstrap davor laut an der Git-Repo-Sperre (fehlendes
# oder unlesbares .git) — der Bootstrap braucht ein bestehendes Git-Repo, das sprachlose
# Ziel traegt sein `git init -q` an der Ziel-Anlage.
#
# WAS DAS MISST: dass der ZWEITE Aufruf ueberhaupt Zaehne hat. Der erste faengt jeden Defekt
# des Emit, und solange nur er rot gesehen ist, belegt nichts, dass die sprachlose Variante
# geprueft wird — sie koennte auf ein leeres Ziel zeigen und der Lauf bliebe gruen. Genau das
# ist das Risiko, das der Slice-Plan als "der Marker haengt nur an einer Bootstrap-Variante"
# fuehrt.
#
# WARUM `full-smoke` DIE SCHMALSTE AUSREICHENDE STUFE IST: der Aufruf existiert nur zur
# Laufzeit des Voll-E2E ueber einem gebootstrappten Ziel; `make test` faehrt ihn nicht. Der
# Preis des Modus steht im Kopf von harness/tools/mutate.sh.
set -euo pipefail
sed -i "s@^baum_aussagen_im_ziel \"\$tmprepo_doc\" \"sprachlos\"\$@baum_aussagen_im_ziel \"\$tmprepo_doc/harness\" \"sprachlos\"@" harness/tools/full-smoke.sh
