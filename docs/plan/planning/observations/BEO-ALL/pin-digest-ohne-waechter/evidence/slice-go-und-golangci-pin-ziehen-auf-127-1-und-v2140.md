**Vorgang:** slice-go-und-golangci-pin-ziehen-auf-127-1-und-v2140
**Fund:** Der Implementer ließ den alten `golang`-Digest stehen und belegte real: `make test` blieb grün; Digest und die zwei Fallbacks haben keinen Wächter (Verifikation: nicht bewacht, nicht bestätigt).
