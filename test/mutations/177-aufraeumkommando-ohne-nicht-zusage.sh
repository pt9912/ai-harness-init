#!/usr/bin/env bash
# files: internal/emit/templates/enforce/erfassung.mk
# expect: TestErfassungFragment_ZielUndNichtZusage
# verify: test-go
#
# STREICHT DIE NICHT-ZUSAGE NEBEN DEM AUFRAEUM-KOMMANDO: das Ziel bekommt weiter ein
# Kommando, sagt aber nicht mehr, dass sein Bestand ohne dessen Aufruf unbegrenzt
# waechst. Die Begruendung daneben bleibt stehen — genau die Fassung, in der die
# fehlende Aussage am ehesten uebersehen wird.
#
# LH-FA-10 §Aufbewahrung verlangt beides in einem Satz: "ohne dessen Aufruf waechst der
# Bestand unbegrenzt, UND DAS REPO SAGT ES". Ein Kommando ohne diesen Satz liest sich
# wie ein Komfort-Ziel neben einer Rotation, die es nicht gibt; der Adopter erfaehrt vom
# Wachstum erst an der Platte.
set -euo pipefail
sed -i '/^# OHNE DIESEN AUFRUF WAECHST DER BESTAND UNBEGRENZT\.$/d' internal/emit/templates/enforce/erfassung.mk
