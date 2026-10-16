# mutate-auswahl.sh nutzt paste ohne Datei-Operand und bricht auf BSD

**Sub-Area:** `*` (gesamtes Repo)

`harness/tools/mutate-auswahl.sh` ruft `paste -sd…` ohne Datei-Operand auf (Zeilen 186 und 219: die Anzeige der lokalen Fall-Menge und die Shard-Matrix). Das BSD-`paste` von macOS verlangt einen Operand; der Aufruf bricht dort, und die Verwendung liefert Exit 0 mit leerem `MUTATE_CASES` bzw. leerer Matrix. Die Docker-only-Regel deckt den Aufruf nicht: das Skript läuft auf dem Host.
