**Vorgang:** slice-217
**Fund:** `d-check --print-mk` gibt **je Modul ein Ziel** aus, ohne die Konfiguration zu lesen —
gemessen über einer Kopie außerhalb des Repos, netzlos, gegen den in
[`d-check.mk`](../../../../../../../d-check.mk) gepinnten Digest:

```sh
D=$(grep -oE 'DCHECK_DIGEST \?= sha256:[0-9a-f]+' d-check.mk | cut -d' ' -f3)
docker run --rm --network none "ghcr.io/pt9912/d-check@$D" --print-mk | grep -cE '^docs?-[a-z-]*:'   # 13
docker run --rm --network none -v "$PWD":/repo:ro "ghcr.io/pt9912/d-check@$D" \
  --print-mk --config /repo/.d-check.yml | grep -cE '^docs?-[a-z-]*:'                                # 13
diff <(docker run --rm --network none "ghcr.io/pt9912/d-check@$D" --print-mk) \
     <(docker run --rm --network none -v "$PWD":/repo:ro "ghcr.io/pt9912/d-check@$D" \
         --print-mk --config /repo/.d-check.yml) && echo identisch                                   # identisch
```

Das ist die **Ursache** dafür, dass [`d-check.mk`](../../../../../../../d-check.mk) zwei Ziele
führt, deren Modul in [`.d-check.yml`](../../../../../../../.d-check.yml) keinen Block hat, und
dafür, dass eine Neu-Erzeugung die Marke, die genau das sagt, stillschweigend wieder wegnähme. Der
Slice trägt die Folge lokal — Handgriff 5 im Adopter-Kopf und ein Wächter, der den Verlust beim
nächsten `make gates` laut macht. Die Ursache selbst bleibt ohne Adresse: Sie zu schließen hieße,
im Nachbar-Repo zu arbeiten, und eine Slice-Kennung dieses Repos dafür zu vergeben behauptete eine
Datei, die es hier nicht gibt.
