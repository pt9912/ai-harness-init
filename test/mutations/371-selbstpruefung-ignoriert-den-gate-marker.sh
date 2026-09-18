#!/usr/bin/env bash
# files: internal/emit/templates/enforce/selbstpruefung.sh
# expect: traegt weiter die Spur
# verify: full-smoke
#
# NIMMT DER EMITTIERTEN VORLAGE DEN GATE-MARKER: der Gate-Schritt faehrt danach fest
# `make gates`, waehrend die Ankuendigungs-Zeile `Gate=[…]` den gesetzten Wert weiter
# nennt — sie interpoliert die Variable. Ein Marker, der nur in der Ankuendigung steht,
# ist keine Adaption (LH-FA-02).
#
# WAS DAS MISST: die Stufe im Voll-E2E liest die SPUR des gefahrenen Kommandos, nicht die
# Ankuendigung — `make baseline-verify` schreibt `Integritaet + Vollstaendigkeit`,
# `make gates` zusaetzlich die Zeile des Doku-Gates und den Gate-Nachweis. Ohne diesen
# Fall bliebe die Unterscheidung zwischen "der gesetzte Wert lenkt" und "der gesetzte Wert
# steht daneben" am ruhenden Baum unsichtbar (AGENTS.md 3.6).
#
# WARUM full-smoke DIE SCHMALSTE AUSREICHENDE STUFE IST: die Spur entsteht erst, wenn das
# Gate-Kommando in einem Klon eines gebootstrappten Ziels wirklich laeuft. Die Go-Zaehne
# der Vorlage lesen ihre Verdrahtung, nicht ihren Lauf. Der Preis eines solchen Falls
# steht im Kopf von harness/tools/mutate.sh.
set -euo pipefail
# Das Dollarzeichen der Zielstelle steht hier als `.`: in einfachen Anfuehrungszeichen
# waere es eine Expansion, die keine ist, und der Shell-Lint dieses Repos meldet sie.
sed -i 's|bash -c ".SELBSTPRUEFUNG_GATE"|bash -c "make gates"|' internal/emit/templates/enforce/selbstpruefung.sh
