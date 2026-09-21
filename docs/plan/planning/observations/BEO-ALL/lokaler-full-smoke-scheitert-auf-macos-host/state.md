**Stand:** offen (1×)

Für `make full-smoke`/`make smoke` besteht zusätzlich ein additiver, für den Host
cross-kompilierender Pfad (`make full-smoke-host`/`make smoke-host`, Ziele in `Makefile`), der auf
einem macOS-Devhost läuft — der byte-identische Default-Pfad (`make full-smoke`/`make smoke`, und
mit ihm `make mutate`, das keinen eigenen Host-Pfad trägt) bleibt davon laut eigener Zusage des
Fixes unverändert. Die Beobachtung — dass der lokale Default-Lauf auf einem solchen Host
strukturell scheitert — trifft damit weiterhin zu; sie ist gemildert (ein Workaround existiert für
zwei der drei betroffenen Ziele), nicht gelöst.
