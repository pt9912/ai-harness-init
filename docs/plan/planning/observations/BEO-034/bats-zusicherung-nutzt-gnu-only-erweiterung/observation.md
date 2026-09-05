# Bats-Zusicherung nutzt GNU-only Erweiterung

**Sub-Area:** `*` (gesamtes Repo)

Eine bats-Zusicherung benutzt eine GNU-only Coreutils-Erweiterung, die im gepinnten
Alpine/BusyBox-Testbild lautlos scheitert — die Vergleichsmenge bleibt leer statt zu warnen, und
die Zusicherung ist unter jeder Mutation grün, unabhängig vom geprüften Code.
