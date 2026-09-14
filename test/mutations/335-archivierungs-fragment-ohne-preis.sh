#!/usr/bin/env bash
# files: internal/emit/templates/enforce/archivierung.mk
# expect: TestArchivierungFragment_TraegtPreisUndMeldung
# verify: test-go
#
# NIMMT DEM FRAGMENT DEN SATZ UEBER DEN AUFRUF: die Zeile, die sagt, dass der
# Aufruf nur ausdruecklich und nie nebenbei laeuft.
#
# Der Aufruf bewegt, loescht und committet im VERSIONIERTEN Baum eines fremden
# Repos. Was er tut, steht sonst allein in der Entscheidung dahinter, und die liegt
# im Zielrepo nicht: ADR-Dateien werden dorthin nicht emittiert. Der Kopf des
# Fragments ist die Stelle, die ein Re-Lauf haelt — die fehlende Zeile nimmt dem
# Adopter die einzige Auskunft ueber die Reichweite des Kommandos.
#
# DIE UEBRIGEN PREIS-SAETZE BLEIBEN STEHEN (versionierter Baum, loescht, committet,
# unsauberer Arbeitsbaum): der Fall trifft genau die eine Zeile, die er nennt, und
# die Meldung des roten Laufs nennt sie im Klartext.
#
# WARUM die Go-Stufe die schmalste ausreichende ist: gemessen wird der emittierte
# Text. Ein Lauf des Kommandos im Ziel ruft die Zeile nie auf — sie beschreibt den
# Aufruf, sie steuert ihn nicht.
set -euo pipefail
sed -i '/^# Er laeuft nur auf ausdruecklichen Aufruf, nie nebenbei\.$/d' internal/emit/templates/enforce/archivierung.mk
