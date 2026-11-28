# Die Runner-Toolchain-Umgebung liegt außerhalb jedes Repo-Pins

**Sub-Area:** `*` (gesamtes Repo)

Die Toolchain-Umgebung der CI-Runner-Images (Ubuntu-, macOS-, Windows-Runner
je [MR-014](../../../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions)-Läufer) liegt außerhalb jedes Repo-Pins: die Mischform
([MR-098](../../../../../../harness/conventions.md#mr-098--die-umgebungs-zusage-trägt-mischform-die-dogfood-gates-und-lab-läufer-fahren-am-host)) trägt sie am Pin-Standort — der `GO_VERSION`-Pin im `Makefile`,
das Inventar-Manifest je übriges Werkzeug, abgeleitet und am Pin geprüft
(`make ci-runner-setup`, `pinsync`) — aber kein Pin und kein Sensor hält das
Runner-Image selbst. Die SKIP-Belehnform der CI behauptet kein
Runner-Verdikt ([ADR-0108](../../../../adr/0108-stempel-synthese-je-check-pruefgegenstand.md) Festlegung 4). Die Grenze steht als
Negativ-Konsequenz in [ADR-0115](../../../../adr/0115-release-bau-docker-los-in-ci.md) Festlegung 3; die Re-Evaluierungs-Trigger
1/2 derselben ADR tragen die Beobachtung.
