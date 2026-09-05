**Vorgang:** slice-187
**Fund:** Der Sprung auf `v0.74.1` ist ein reiner Security-Release (zwei behebbare CVEs in `golang.org/x/crypto`, Fremdquelle CHANGELOG des Klons); ausgelöst hat ihn `make freshness-dcheck` mit der Aussage *„gepinnt und latest laufen auseinander"*, und kein Sensor dieses Repos hätte den Grund genannt.
