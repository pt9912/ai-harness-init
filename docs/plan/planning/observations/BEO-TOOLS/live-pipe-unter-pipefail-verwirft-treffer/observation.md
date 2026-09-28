# Live-Pipe unter `pipefail` verwirft einen realen Treffer

**Sub-Area:** `harness/tools/` (Kürzel `TOOLS`)

Eine Pipe der Form `grep -E … | grep -qF …` unter `set -o pipefail` kann einen real vorhandenen
Treffer als „fällt nicht“ melden: Das zweite, quiet laufende `grep -qF` beendet sich beim ersten
Treffer und schließt seine Lesepipe; das noch schreibende erste `grep -E` erhält dabei SIGPIPE und
liefert den rechtesten Nicht-Null-Exit der Pipe, obwohl der Treffer real vorhanden war. Trifft jede
Live-Pipe dieser Form, deren Eingabe mehr als eine zur Form passende Zeile enthält — unabhängig vom
konkreten Skript.
