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
# ABWEICHUNG VON DER PLAN-FORMULIERUNG, benannt statt uebergangen (Review-Befund LOW-4
# vom 2026-07-30): slice-060 DoD (2) formuliert die Mutation als „einen Eintrag aus der
# Liste ENTFERNEN und stattdessen alles Nicht-Gelistete durchlassen". Dieser Fall
# entfernt keinen Eintrag; er haengt hinter die Erfassung eine Negativ-Liste. Der Grund
# ist der TRAEGER: `AgentResult` ist ein geschlossenes Struct, „alles Nicht-Gelistete
# durchlassen" braucht also eine Senke, und die einzige ist `model_version`. Die
# Zusage „einzeilig mutierbar" haelt damit fuer die vier namentlichen Zaehne (123..126,
# je ein `sed` auf einen Listen-Eintrag), NICHT fuer diesen: ein `sed`, sieben eingefuegte
# Zeilen und eine Senken-Wahl. Die Form-Vorgabe selbst (Auswahl = benannte Liste an einer
# Stelle) ist erfuellt; ihre Begruendung gilt nur fuer die vier.
#
# ROT WERDEN DREI, ERWARTET WIRD EINER — das gehoert gesagt, damit der Kopf nicht mehr
# behauptet als er traegt: neben „TestUnlistedResponseKeyStaysOut" fallen auch
# „TestNoResponseFreetextReachesSpan" und „TestResolvedModelIsStructurallyBounded",
# weil beide `model_version` mitpruefen und die Senke ihren Wert verlaengert. Bedingung 4
# des Treibers verlangt den GENANNTEN Waechter in der Fehlschlag-Ausgabe; die beiden
# anderen sind Mitlaeufer der Senke, nicht der Gegenstand.
#
# IM BENANNTEN WAECHTER ist die Rot-Ursache dagegen EINE (Review-Befund MEDIUM-4 vom
# 2026-07-30, hier aufgeloest): bis zum 2026-07-30 pruefte die Gegenprobe von
# TestUnlistedResponseKeyStaysOut zusaetzlich `"model_version":"claude-opus-5[1m]"` — die
# Senke verschob die schliessende Anfuehrung, und der Waechter fiel AUCH ohne seine
# Grenz-Zusicherung. Ein Streichen des mustNotContain-Blocks haette diesen Fall bei
# „ok" gelassen, waehrend genau die Eigenschaft unbewacht war, um derentwillen es ihn
# gibt. Die Gegenprobe nennt jetzt nur Werte, die die Senke nicht beruehrt; damit ist
# „127 rot" gleichbedeutend mit „die Grenz-Zusicherung greift". Gegenprobe dazu einmal
# gefahren: mit entferntem mustNotContain-Block meldet der Treiber diesen Fall als
# BEFUND („rot, aber '...' faellt nicht — falscher Grund"), vorher als „ok".
set -euo pipefail
sed -i 's@^\treturn res$@\tfor key, raw := range obj {\n\t\tswitch key {\n\t\tcase "content", "prompt", "description", "outputFile":\n\t\tdefault:\n\t\t\tres.ModelVersion += key + string(raw)\n\t\t}\n\t}\n\treturn res@' internal/span/response.go
