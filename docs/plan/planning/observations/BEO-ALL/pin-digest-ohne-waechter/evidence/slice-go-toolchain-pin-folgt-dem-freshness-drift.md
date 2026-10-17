**Vorgang:** slice-go-toolchain-pin-folgt-dem-freshness-drift
**Fund:** Der Verifier belegte, dass ein real existierender, aber falscher Digest (der von `golang:1.27.1` an dem Tag `1.27.2`) baut und keinen Sensor färbt; der Makefile-Pin färbt nur `freshness-go` (Netz, nicht in `make gates`), und die Fallbacks in `smoke.sh`/`full-smoke.sh` bleiben ohne Wächter und Kommentar (Review INFO-1).
