# `make traeger-fetch` — legt den Träger per Fetch aus dem gepinnten Release ab

## Vertrag

legt den Träger (`.harness/state/bin/ai-harness-init`) per Fetch aus dem gepinnten Release (Tag: `TRAEGER_TAG` im `Makefile`, `grep -n '^TRAEGER_TAG' Makefile`) ab — das Asset wird vor der Ablage gegen den `SHA256SUMS`-Eintrag desselben Releases verifiziert (das Dogfood-Makefile trägt daneben die sechs Einzeldigests — zwei Kanäle, [`ADR-0059`](../../docs/plan/adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md) Festlegung 3), Transport im gepinnten Bild, kein Prerequisite; braucht Netz an genau diesem Aufruf

