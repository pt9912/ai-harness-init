# Aufnahme-Grenze für ignore-refs-Paare hat keinen Sensor

**Sub-Area:** `*` (gesamtes Repo)

Jedes weitere Paar im Schlüssel `ignore-refs` der `.d-check.yml` ist eine Senkung nach
[`AGENTS.md`](../../../../../../AGENTS.md) §3.5 mit eigener ADR. `test/ignore-refs-restbreite.bats` misst, wie viele
Links ein Paar stumm schaltet, nicht, ob es existieren darf. Fehlerrichtung: *das nächste Paar wird ohne
Entscheidung eingetragen und bleibt grün*.
