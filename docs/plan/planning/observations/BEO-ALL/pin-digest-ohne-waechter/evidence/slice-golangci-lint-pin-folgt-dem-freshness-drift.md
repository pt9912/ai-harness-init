**Vorgang:** slice-golangci-lint-pin-folgt-dem-freshness-drift
**Fund:** Beim Pin-Sprung golangci-lint hält allein `TestGoProfile_PinsMatchRepo` den `ARG` gegen `golangciVersion`; der Makefile-Pin färbt nur `freshness-golangci` (Netz, nicht in `make gates`), der `@sha256`-Digest hat keinen Wächter (Review INFO-1; Verifikation: `make -n gates` nennt kein `freshness`).
