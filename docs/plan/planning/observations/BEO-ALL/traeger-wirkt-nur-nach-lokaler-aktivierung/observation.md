# Ein git-eigener Träger wirkt nur, wo er lokal aktiviert wurde

**Sub-Area:** `*` (gesamtes Repo)

Ein `.githooks/`-Hook feuert nur in einem Klon, in dem `core.hooksPath` per `make hooks-install`
gesetzt wurde — die Aktivierung reist nicht mit dem Klon —, und `git commit --no-verify` umgeht ihn.
Der `commit-msg`-Träger trägt diese Grenze bereits ([`harness/README.md`](../../../../../../harness/README.md)
§Traceability); mit dem `pre-commit`-Träger gegen `--amend` (`slice-amend-haelt-den-index-pfadrein`)
trägt sie ein zweiter git-eigener Hook, strukturell aus demselben Grund.
