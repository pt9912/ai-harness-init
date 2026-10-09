**Vorgang:** slice-kotlin-root-bootstrap
**Fund:** Der Kopf von `TestRun_BootstrapKotlinRoot` gab beiden Varianten den Gate-Lauf einer full-smoke-Stufe und nannte sie mit einem Namen, den keine Stufe trägt; die Stufe „Root-Bootstrap (--lang kotlin --arch hexslice)“ fährt nur `hexslice`, die flache Variante am Root sieht sie nicht (Review LOW-2, behoben in `a96c30e0`).
