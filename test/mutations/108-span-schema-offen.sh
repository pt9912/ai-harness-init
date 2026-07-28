#!/usr/bin/env bash
# files: harness/tools/span-fields.awk
# expect: span: ein unbekanntes Werkzeug gibt nur Name und Status preis
#
# Oeffnet das geschlossene Schema um ein einziges Feld: der Scanner nimmt neben
# dem Pfad auch `prompt` aus `tool_input` mit. Das sieht harmlos aus — ein Feld
# mehr, mehr Kontext im Audit — und ist genau der Weg, auf dem ein Audit-Log zum
# Schaden wird: `prompt` ist Freitext, und das Werkzeug, das ihn traegt, ist
# ausgerechnet jenes, ueber das die Rollen-Achse laeuft.
#
# ADR-0011 Festlegung 1.3 entscheidet dagegen: erfasst wird, was namentlich im
# Schema steht, alles andere faellt auf Name und Status zurueck. Nicht aus
# Geheimhaltung, sondern weil sonst der WERKZEUG-HERSTELLER bestimmt, was in
# unserem Log landet.
set -euo pipefail
sed -i 's@if (k2 == "file_path" || k2 == "notebook_path") emit("path", buf)@if (k2 == "file_path" || k2 == "notebook_path" || k2 == "prompt") emit("path", buf)@' harness/tools/span-fields.awk
