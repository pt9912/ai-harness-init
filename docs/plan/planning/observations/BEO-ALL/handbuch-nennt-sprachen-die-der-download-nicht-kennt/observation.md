# Das Handbuch nennt Sprachen, die der ausgelieferte Download nicht kennt

**Sub-Area:** `*` (gesamtes Repo)

`docs/user/benutzerhandbuch.md` beschreibt den Quellbaum, der Download-Stand liegt dahinter: `java`, `python` und `csharp` stehen im Handbuch, `v0.9.0` kennt sie nicht (`git show v0.9.0:internal/gen/gen.go | grep -c '"java"'` → 0). Ein Quellstand-Hinweis am Kopf und an den Aufzählungen sagt das; er bleibt nach dem Release stehen, wenn ihn niemand entfernt, und die Versionsnummer bleibt auf dem Tag, bis der Release-Schnitt sie zieht. Kein Sensor hält den Hinweis gegen den Tag.
