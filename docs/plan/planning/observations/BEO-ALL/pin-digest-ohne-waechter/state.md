**Stand:** verkörpert

Zielorte: [`test/pin-fallbacks.bats`](../../../../../../test/pin-fallbacks.bats) (Fallbacks in
`harness/tools/smoke.sh`/`full-smoke.sh` gegen den Pin, netzlos in `make gates`) und
[`harness/tools/digest-freshness.sh`](../../../../../../harness/tools/digest-freshness.sh) mit
`make freshness-digest` (`@sha256`-Digest gegen den Tag, nächtlich mit Netz). Herkunfts-Anker in beiden
Dateien: `seit slice-doppelt-gefuehrte-werte-bekommen-ihren-kopplungs-sensor`.
`slice-pin-kopplung-und-sync-tragen-ihre-mutations-faelle` ist ein anderer Gegenstand.

**Grenze der Verkörperung, benannt.** Erfasst sind die tag-tragenden Image-Pins (Liste im Skriptkopf).
**Nicht erfasst:** Pins ohne Tag neben dem Digest (bats, shellcheck, actionlint im `Makefile`; curl in
`harness/tools/tap-nachzug.sh` und `harness/tools/traeger-fetch.sh`, samt Vorlagen-Kopie) — kein Tag,
gegen den ein Digest zu halten wäre; sie liegen außerhalb des Wortlauts dieser Beobachtung, und
kein Slice trägt sie. **Unbelegt:** die Positivrichtung gegen die Registry für `golang` und
`golangci-lint` (anonymes Docker-Hub-429, siehe `BEO-ALL/anonymes-hub-rate-limit-faerbt-den-nacht-lauf-der-digest-achse`);
der Nacht-Schritt ist nie gegen den Runner gelaufen.
