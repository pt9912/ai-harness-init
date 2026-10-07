**Vorgang:** slice-full-smoke-erkennt-unveroeffentlichtes-artefakt
**Fund:** Stufe 5 der E2E-Sicht (`docs/user/e2e-abdeckung.md`) sagt „holt den Träger per Fetch aus
dem gepinnten Release", während `make full-smoke` den Pin aus dem Dogfood-Export erbt; ein falscher
Variablenname im emittierten `traeger.mk` bliebe an beiden Wächtern grün (Review F4).
