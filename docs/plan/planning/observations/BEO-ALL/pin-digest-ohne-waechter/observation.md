# Pin-Digest und Pin-Fallbacks ohne Wächter

**Sub-Area:** `*` (gesamtes Repo)

Ein Toolchain-Pin hat Stellen, die kein Sensor in `make gates` koppelt: der `@sha256`-Manifest-Digest im Dockerfile (er übersteuert den Tag, ein vergessener lässt den Build still auf dem alten Stand laufen) und wert-hardcodende Fallbacks in `harness/tools/smoke.sh` und `full-smoke.sh`. Ein Pin-Zug, der sie vergisst, bleibt grün. Keine Fixture-Klasse: die reale Quelle selbst ist unbewacht.
