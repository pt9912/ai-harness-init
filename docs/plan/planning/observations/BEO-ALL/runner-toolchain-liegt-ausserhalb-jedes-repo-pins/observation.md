# Die Runner-Toolchain-Umgebung liegt außerhalb jedes Repo-Pins

**Sub-Area:** `*` (gesamtes Repo)

Die Toolchain-Umgebung der CI-Runner-Images (Ubuntu-, macOS-, Windows-Runner
je `MR-014`-Läufer) liegt außerhalb jedes Repo-Pins: die Mischform
(`MR-098`) trägt sie am Pin-Standort — der `GO_VERSION`-Pin im `Makefile`,
das Inventar-Manifest je übriges Werkzeug, abgeleitet und am Pin geprüft
(`make ci-runner-setup`, `pinsync`) — aber kein Pin und kein Sensor hält das
Runner-Image selbst. Die SKIP-Belehnform der CI behauptet kein
Runner-Verdikt (`ADR-0108` Festlegung 4). Die Grenze steht als
Negativ-Konsequenz in `ADR-0115` Festlegung 3; die Re-Evaluierungs-Trigger
1/2 derselben ADR tragen die Beobachtung.
