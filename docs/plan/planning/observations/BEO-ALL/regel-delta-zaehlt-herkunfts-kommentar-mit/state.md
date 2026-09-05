**Stand:** offen

Gemessen an den vier Delegaten des §Freshness-Audit über die zwei vendored Bäume:
`modul-07-carveouts.md`, `modul-04-adrs.md` und `grundlagen-bootstrap.md` liefern je `roh=2`,
davon `2` Herkunfts-Kommentar, Regel-Delta **0**; `grundlagen-harness-dateien.md` liefert `roh=13`
bei Regel-Delta **11**. Dieselbe Rechnung trägt für den Sprung davor (`roh=2/2/2` bei Regel-Delta
0, `roh=17` bei 15). Die Kommandos stehen in
[`ADR-0036`](../../../../../../docs/plan/adr/0036-ziel-fassung-regiert-den-sprung-v600.md)
§Was das Messinstrument mitzählt. **Wirkung im Bestand:**
[`ADR-0031`](../../../../../../docs/plan/adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md)
führt dieselbe Mehrzahl an drei Stellen, davon in §Entscheidung als einen der tragenden Gründe von
Festlegung 1 — nicht nur in ihrem §Kontext. Das Ergebnis von Festlegung 1 bleibt unberührt: der
eine Delegat mit echtem Delta trägt sie unabhängig. Die Konsistenz-Prüfung jener Datei ist
ein eigener Vorgang
([slice-171](../../../../../../docs/plan/planning/open/slice-171-adr-0031-acceptance-trigger.md)).
**Kein Sensor:** kein Modul aus `modules:` der
[`.d-check.yml`](../../../../../../.d-check.yml) vergleicht zwei Baseline-Bäume, und
`.harness/baseline/**` liegt dort in `scan.ignore`.
