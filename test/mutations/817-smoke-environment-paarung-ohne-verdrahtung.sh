#!/usr/bin/env bash
# files: internal/emit/environment.go
# expect: das Target hinter dem make-Anspruch fehlt
# verify: smoke
#
# Die GATE_CHECKS-Verdrahtung des emittierten environment.mk weicht von der
# Kopf-Form ab — die Paarungs-Probe des docker-losen Smokes
# (harness/tools/smoke.sh, umgebung_paarung_pruefen, seit
# slice-smoke-und-full-smoke-ohne-docker) liest sie: der Bootstrap emittiert ein
# environment.mk ohne die `^GATE_CHECKS := environment-check`-Form, und der Smoke
# bricht an der Probe ("das Target hinter dem make-Anspruch fehlt") — die
# make-Anspruch-Aussage im Singleton stünde damit am Ziel ohne die Verdrahtung
# dahinter. Vor diesem Slice trug kein kurierter Fall die Proben: sie liefen nur,
# wenn jemand `make smoke` fuhr.
#
# ANKER: das Muster trifft die Verdrahtungs-Zeile in environmentMk
# (internal/emit/environment.go) mit Wildcard-Charakter statt eines literalen Dollar
# — die Fall-Skripte dieses Verzeichnisses verankern ohne literales Dollar (SC2016);
# `.` ist hier der Dollar, der einzige `$(GATE_CHECKS)`-Aufruf in dem Konstanttext.
set -euo pipefail
sed -i 's/GATE_CHECKS := environment-check .(GATE_CHECKS)/GATE_CHECKS += environment-check/' internal/emit/environment.go
