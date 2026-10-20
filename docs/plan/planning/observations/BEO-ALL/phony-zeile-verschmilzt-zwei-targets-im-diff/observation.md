# `.PHONY`-Zeile verschmilzt zwei Targets durch einen Tippfehler im Diff

**Sub-Area:** `*` (gesamtes Repo)

Beim Einfügen eines neuen Targets in die eine lange `.PHONY`-Zeile des `Makefile` verschwand ein Leerzeichen:
`tap-checktap-nachzug` statt `tap-check tap-nachzug`. Beide Targets sind damit nicht mehr als `.PHONY` deklariert, und liegt eine
gleichnamige Datei im Wurzelverzeichnis, meldet `make` „up to date" und fährt nichts. Kein Gate fängt es: `make docs-check`
(Modul `targets`) hält Index und Rezepte gegeneinander, nicht die `.PHONY`-Zeile; gefunden hat es der Review am Diff. Ein Sensor,
der die Tokens der `.PHONY`-Zeile gegen die Rezept-Namen des `Makefile` hielte, ist baubar und nicht gebaut.
