**Vorgang:** slice-go-toolchain-pin-zieht-auf-1-27-3

**Fund:** `TestGenerate_GoVersionThreaded` reichte `1.27.3`, nach dem Sprung gleich `DefaultGoVersion`; Fall `20-gen-go-version-threading` war rot aus dem falschen Grund (CI-Lauf 39544032717), bis der Test eine nie gepinnte Eingabe nutzte.
