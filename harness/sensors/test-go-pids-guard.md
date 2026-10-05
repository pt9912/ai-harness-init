# `make test-go-pids-guard` — Wirkungs-Wächter für den pids-Deckel

## Vertrag

Wirkungs-Wächter für den pids-Deckel des Go-Testlaufs (`internal/resourcecap`, Build-Tag `resourcecap`, aus `go test ./...` ausgenommen): startet 700 gleichzeitige Prozesse und erwartet, dass mindestens einer am `TEST_PIDS_LIMIT` (Makefile) scheitert — mit Deckel grün, ohne Deckel rot (von Hand belegt)

