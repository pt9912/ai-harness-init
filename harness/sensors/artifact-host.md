# `make artifact-host` — Artefakt für den Host cross-kompiliert

## Vertrag

wie `artifact`, aber für den HOST cross-kompiliert (`TARGET_OS`/`TARGET_ARCH` aus `uname`, wie `host-bin`) statt den byte-identischen Default-Pfad zu nehmen ([`LH-QA-04`](../../spec/lastenheft.md#lh-qa-04--plattform-matrix)/slice-048 unberührt). Das Ziel baut den Träger für die Plattform des Hosts.

Eine Hilfe ohne Anspruch: Host der Läufer `make full-smoke` und `make mutate` ist Linux, macOS ist dafür nicht getragen (`AGENTS.md` §3.9); ein Lauf über dieses Ziel ist kein Beleg. Das Produkt-Binary ([`LH-QA-04`](../../spec/lastenheft.md#lh-qa-04--plattform-matrix)) bleibt davon unberührt.

Der Release-Bau läuft am HOST über `make release-artifacts-host` (docker-los, [`ADR-0115`](../../docs/plan/adr/0115-release-bau-docker-los-in-ci.md) Festlegung 1) — dieses Ziel baut ihn nicht: es bleibt die Träger-Ablage für Gates-Kette und Smokes. Der gepinnte Image-Weg des Bauens (`artifact`, `release-artifacts`) bleibt als opt-in Weg gepinnt und ungestrichen (Festlegung 2).
