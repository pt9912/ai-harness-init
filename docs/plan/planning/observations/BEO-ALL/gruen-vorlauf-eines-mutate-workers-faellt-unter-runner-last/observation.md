# Der Grün-Vorlauf eines Mutations-Workers fällt unter Runner-Last

**Sub-Area:** `*` (gesamtes Repo)

Im CI-Lauf `mutate` fahren vier Worker denselben Grün-Vorlauf (`make test-go`, `make test-bats`) gleichzeitig auf einem Runner. Ein zeit- oder lastabhängiger Test fällt dort rot, ohne dass am geprüften Code etwas falsch ist; der rote Grün-Vorlauf lässt den Worker sterben, und die übrigen Fälle des Shards bleiben ohne Ergebnis. Die Ursache liegt in der Last, nicht in einem Fall, und ist lokal nicht herstellbar. Die Klasse umfasst ausdrücklich nicht den Image-Tag-Konflikt paralleler lokaler Worker (`paralleler-mutate-lauf-verliert-das-image-eines-workers`): anderes Symptom (`No such image`), anderer Ort (lokaler Image-Speicher).

**Benannt, nicht gezählt:** zwei weitere rote Grün-Vorläufe derselben Läufe (Shard 2 am 2026-10-16 mit `make test-bats`, 63 von 66 Fällen ohne Ergebnis; Shard 7 am 2026-10-14) — ohne abgeschlossenen Vorgang, der sie belegt; die Zuordnung am 2026-10-14 ist nicht shard-genau gemessen.
