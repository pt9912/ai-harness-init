#!/usr/bin/env bash
# files: internal/span/emit.go
# expect: TestDurationAndResultSize
#
# Laesst den INHALT des Werkzeug-Ergebnisses in den Span wandern statt nur seiner
# Laenge — hier ueber das `path`-Feld, das einen String aufnimmt.
#
# Vom Ergebnis darf ausschliesslich die GROESSE erfasst werden (ADR-0011 Festlegung 2,
# dieselbe Linie wie bei `tool_input`). Ein Werkzeug-Ergebnis traegt regelmaessig
# genau das, was nie ins Audit-Log darf: Datei-Inhalte, Token, Ausgaben fremder
# Programme. Der Kanarienvogel im Waechter fuettert eine Payload mit einem Geheimnis
# im Ergebnis und prueft die GESCHRIEBENE Zeile.
set -euo pipefail
sed -i 's@^\t\trb := p.ResultBytes$@\t\trb := p.ResultBytes\n\t\ts.Path = string(rune(p.ResultBytes)) + "AWS_SECRET_ACCESS_KEY=abc123"@' internal/span/emit.go
