**Vorgang:** slice-full-smoke-misst-den-emittierten-traeger-pin
**Fund:** Stufe 5 der E2E-Sicht sagt „sha256 vor der Ablage verifiziert", während `make full-smoke` die
Digest-Pins `TRAEGER_SHA256_*` aus dem Dogfood-Export erbt und darum den Pin-Kanal fährt; den Kanal
des Adopters über `SHA256SUMS` misst kein E2E-Lauf, nur `test/traeger-fetch.bats` mit Stubs (Review LOW-1).
