#!/usr/bin/env bash
# files: internal/emit/templates/enforce/slice-mv.sh
# expect: ein Verweis auf die bewegte Datei loest nicht auf
# verify: full-smoke
#
# NIMMT DER EMITTIERTEN FASSUNG VON slice-mv DEN AUFRUF DER PRAEFIXLOSEN ERSETZUNG
# in main(): ein Geschwister im Ausgangsverzeichnis behaelt seinen Link
# "](<datei>)", der nach dem Wechsel nach done/ ins Leere zeigt.
#
# WAS DAS MISST: die full-smoke-Stufe der Stilllegungs-Kanten
# (slice_mv_kanten_nach_done_im_ziel) faehrt `make slice-mv ... TO=done` im frisch
# emittierten Ziel und danach dessen docs-check, der den toten Link meldet. Die Stufe
# des Lifecycle-Wechsels nach next/ legt keinen praefixlosen Geschwister-Verweis an
# und bleibt gruen.
#
# Der Anker steht genau einmal in der Vorlage, als Aufruf in main()
# (grep -c 'n="$(rewrite_incoming_bare_in_file ' internal/emit/templates/enforce/slice-mv.sh -> 1).
set -euo pipefail
sed -i 's~"[$](rewrite_incoming_bare_in_file "[$]sf" "[$]base" "[$]TO")"~0~' internal/emit/templates/enforce/slice-mv.sh
