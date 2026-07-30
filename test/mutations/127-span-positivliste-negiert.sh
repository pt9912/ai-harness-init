#!/usr/bin/env bash
# files: internal/span/response.go
# expect: TestUnlistedResponseKeyStaysOut
#
# DER GRENZ-ZAHN: stellt die Erfassung von der POSITIV-Liste auf eine NEGATIV-Liste um
# — alles aus `tool_response` wandert in den Span AUSSER den vier gemessenen
# Freitext-Feldern.
#
# WARUM ES DIESEN FALL BRAUCHT, obwohl 123..126 schon vier Zaehne setzen: vier
# namentliche Faelle unterscheiden eine Positiv-Liste NICHT von einer Implementierung,
# die genau diese vier ausfiltert. Sie belegen die Zusage, nicht die EIGENSCHAFT — und
# die Eigenschaft ist das, womit slice-060 §6 die Wahl begruendet: "sie haelt auch, wenn
# eine kuenftige Antwort ein fuenftes Freitext-Feld bringt". Ohne diesen Fall ist genau
# dieser Satz unbelegt. Zugleich ist er der Sensor zu ADR-0011 Festlegung 1 Punkt 3
# ("das Schema ist GESCHLOSSEN") — der EINZIGEN Regel von Festlegung 1, die nicht an
# MR-018 delegiert ist und deren Bruch das Architect-Verdikt vom 2026-07-30 kippt (B3).
#
# DIE VIER BLEIBEN AUSGESCHLOSSEN, und das ist Absicht: so misst dieser Zahn die GRENZE
# und nicht ein zweites Mal die vier Namen (die gehoeren 123..126). Rot wird er allein
# daran, dass ein UNGELISTETER, teils erfundener Schluessel den Span erreicht.
#
# WARUM `model_version` die Senke ist: von den neun erfassten Werten sind acht Zahlen
# oder das gegen sechs Namen normalisierte `spawned_role` — `model_version` ist der
# einzige String, in den sich ungelisteter Inhalt ueberhaupt schreiben laesst, ohne die
# Datenstruktur zu wechseln (und ein Wechsel der Datenstruktur waere keine einzeilige
# Mutation mehr, was die Form-Vorgabe des Plans gerade verhindern soll).
#
# ROT WERDEN DREI, ERWARTET WIRD EINER — das gehoert gesagt, damit der Kopf nicht mehr
# behauptet als er traegt: neben „TestUnlistedResponseKeyStaysOut" fallen auch
# „TestNoResponseFreetextReachesSpan" und „TestResolvedModelIsStructurallyBounded",
# weil beide `model_version` mitpruefen und die Senke ihren Wert verlaengert. Bedingung 4
# des Treibers verlangt den GENANNTEN Waechter in der Fehlschlag-Ausgabe; die beiden
# anderen sind Mitlaeufer der Senke, nicht der Gegenstand.
set -euo pipefail
sed -i 's@^\treturn res$@\tfor key, raw := range obj {\n\t\tswitch key {\n\t\tcase "content", "prompt", "description", "outputFile":\n\t\tdefault:\n\t\t\tres.ModelVersion += key + string(raw)\n\t\t}\n\t}\n\treturn res@' internal/span/response.go
