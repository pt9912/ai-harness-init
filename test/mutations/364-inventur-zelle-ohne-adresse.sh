#!/usr/bin/env bash
# files: internal/emit/baumaussage.go
# expect: TestTraegerInventur_JedeZeileTraegtGenauEinenWert
# verify: test-go
#
# NIMMT EINER ABWESENHEITS-ZELLE IHRE ADRESSE: die Zelle sagt weiter "kommt nicht mit",
# nennt aber kein Praefix mehr, unter dem ein Traeger dieser Klasse erschiene.
#
# WAS DAS MISST: eine Abwesenheits-Aussage ohne Adresse kann unter keiner Mutation rot
# werden — sie behauptet eine Nicht-Existenz, die nichts prueft (AGENTS.md 3.6). Die Zelle
# bliebe still richtig, bis der Emit den Traeger ablegt und niemand die Inventur ansieht.
set -euo pipefail
sed -i 's@Abwesend: "tools/harness/"}@Abwesend: ""}@' internal/emit/baumaussage.go
