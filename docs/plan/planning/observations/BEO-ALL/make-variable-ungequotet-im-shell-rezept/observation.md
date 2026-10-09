# Make-Variable ungequotet im Shell-Rezept

**Sub-Area:** `*` (gesamtes Repo)

Ein Make-Rezept setzt eine Variable, deren Wert aus fremder Eingabe kommt (ein Ref-Name, eine Kennung), als `'$(VAR)'` in die Shell. Ein Wert mit Anführungszeichen bricht aus dem Quoting aus; die Zusage gilt für das Skript dahinter, nicht für das Rezept davor.
