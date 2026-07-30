#!/usr/bin/env bash
# files: internal/span/emit.go
# expect: TestDurationAndResultSize
#
# Laesst FREITEXT aus dem Werkzeug-Ergebnis in den Span wandern — hier ueber das
# `path`-Feld, das einen String aufnimmt. Das Werkzeug ist dabei `Bash`, also KEIN
# namentlich gelistetes Agenten-Werkzeug: dieser Zahn deckt die Flaeche, die fuer JEDES
# Werkzeug gilt.
#
# AUS DEM ERGEBNIS ERREICHT KEIN FREITEXT DEN SPAN. Erfasst werden die LAENGE (fuer
# jedes Werkzeug) und — seit slice-060 DoD (2), NUR fuer `Agent` — die neun Werte der
# Positiv-Liste in internal/span/response.go: Zahlen, ein gegen sechs Namen
# normalisiertes Etikett und ein strukturell begrenzter Modell-Bezeichner. Kein
# Rohstring aus dem Ergebnis.
#
# DIESE ZUSAGE HIESS BIS 2026-07-30 "ausschliesslich die GROESSE" und ist mit DoD (2)
# falsch geworden. Sie wurde ERSETZT, nicht ergaenzt; der Waechter selbst bleibt richtig
# und ist der EINZIGE Zahn dieser Flaeche, deshalb umformuliert statt geloescht.
# `make comment-claims` faengt das nicht — es prueft die Existenz des Sensors, nicht die
# Wahrheit des Satzes.
#
# FUNDSTELLE KORRIGIERT (Architect-Befund Z3 vom 2026-07-30): das Verbot von
# Ergebnis-INHALT ruht NICHT auf ADR-0011 Festlegung 2 — die regelt die ARGUMENT-Achse
# ("keine Argumente", und `tool_input` ist ihr Gegenstand) —, sondern auf Festlegung 1
# Punkt 3 ("das Schema ist GESCHLOSSEN") und dem flaechen-unabhaengigen Satz "kein Byte
# fremden Inhalts".
#
# Ein Werkzeug-Ergebnis traegt regelmaessig genau das, was nie ins Audit-Log darf:
# Datei-Inhalte, Token, Ausgaben fremder Programme. Der Kanarienvogel im Waechter
# fuettert eine Payload mit einem Geheimnis im Ergebnis und prueft die GESCHRIEBENE
# Zeile.
set -euo pipefail
sed -i 's@^\t\trb := p.ResultBytes$@\t\trb := p.ResultBytes\n\t\ts.Path = string(rune(p.ResultBytes)) + "AWS_SECRET_ACCESS_KEY=abc123"@' internal/span/emit.go
