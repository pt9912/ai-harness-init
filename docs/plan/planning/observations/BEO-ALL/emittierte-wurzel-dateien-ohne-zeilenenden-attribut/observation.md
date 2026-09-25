# Emittierte Wurzel-Dateien ohne Zeilenenden-Attribut

**Sub-Area:** `*` (gesamtes Repo)

Die Dateien in der Wurzel des gebootstrappten Ziels — `Makefile`, `d-check.mk`, `a-check.mk`,
`.d-check.yml`, `Dockerfile` — tragen kein Zeilenenden-Attribut: die Wurzel gehört dem Adopter, und
eine genestete `.gitattributes` erreicht sie nicht. Im Klon mit `core.autocrlf=true` tragen sie CR.
Unter GNU Make 4.3 bricht das `Makefile` nicht; ob ein Windows-`make` oder BuildKit über einem
`Dockerfile` an CRLF bricht, ist ungemessen. Die Fehlerrichtung ist *die Emission legt LF fest*, wo
sie es für die Wurzel-Dateien nicht tut — und die Stufe gibt die Restmenge aus, statt sie
zuzusagen.
