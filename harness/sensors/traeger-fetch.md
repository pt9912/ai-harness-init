# `make traeger-fetch` — legt den Träger per Fetch aus dem gepinnten Release ab

## Vertrag

legt den Träger (`.harness/state/bin/ai-harness-init`) per Fetch aus dem gepinnten Release (Tag: `TRAEGER_TAG` im `Makefile`, `grep -n '^TRAEGER_TAG' Makefile`) ab — das Asset wird vor der Ablage gegen seinen Digest verifiziert, fail-closed ohne Ablage; die Prüfsummen-Quelle ist der eigene Makefile-Pin (`TRAEGER_SHA256_*`, **zwei Kanäle** — Makefile in git, Asset über den Release-Kanal) oder, ohne Pin, der `SHA256SUMS`-Eintrag desselben Releases (ADR-0059-Form); kein Prerequisite; braucht Netz an genau diesem Aufruf

## Weg (seit slice-binraire-ziehen-ohne-docker)

Der Pflicht-Weg läuft **docker-los am Host** ([ADR-0109](../../docs/plan/adr/0109-gates-lauefer-docker-los-image-weg-opt-in.md)): `harness/tools/traeger-fetch-host.sh` zieht per Host-curl + HTTPS + sha256sum und verifiziert die Byte-Summe, bevor er ablegt; ohne curl bricht er laut am Aufruf (`make traeger-fetch-image` steht daneben). Die gepinnte Image-Fassung bleibt opt-in als `make traeger-fetch-image` (`harness/tools/traeger-fetch.sh`, Transport im digest-gepinnten `TRAEGER_IMAGE`), mit derselben Pin-Kopplung.

## Wächter

`test/traeger-fetch-host.bats` hält die docker-lose Fassung (Happy in beiden Prüfsummen-Modi, Negative je Modus, fail-closed vor dem Transport, Plattform-Matrix), `test/traeger-fetch.bats` unverändert die opt-in Image-Fassung samt der Pin-Kopplung der Makefile-Stelle. Die Kopplung Makefile-Digests↔`SHA256SUMS` hält der Release-Schnitt, wo ein Lauf das Release erreicht ([ADR-0059](../../docs/plan/adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md) Folgepflicht 2) — im netzlosen Gate unprüfbar, benannt.
