**Vorgang:** slice-d-check-pin-bringt-den-go-sicherheitsfix

**Fund:** Der emittierte `reviews`-Kommentar in `internal/emit/templates/d-check.yml` beschrieb das Verhalten am Pin `v0.84.0` neben `DefaultImage` `v0.85.0` (Review MEDIUM-1, behoben in `724b63ff`); die Pin-Fassung im `codepaths`-Kommentar bleibt von Hand nachgezogen und an `DefaultImage` ungekoppelt (INFO-2 beider Nachprüfungen).
