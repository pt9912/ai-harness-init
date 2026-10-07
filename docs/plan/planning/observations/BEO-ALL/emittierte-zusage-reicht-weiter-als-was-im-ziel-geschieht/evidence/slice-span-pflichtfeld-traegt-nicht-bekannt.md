**Vorgang:** slice-span-pflichtfeld-traegt-nicht-bekannt
**Fund:** Ein Ziel, gebootstrappt von unveröffentlichtem `main`, bekommt die Feldliste mit den
Cache-Zählern als *Pflicht*, während `make traeger-fetch` den gepinnten Träger `v0.2.8` holt, der die
Felder weglässt; je Release-Tag stimmen beide überein.
