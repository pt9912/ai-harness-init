**Vorgang:** slice-full-smoke-erkennt-unveroeffentlichtes-artefakt
**Fund:** Tag-Pushes `v0.3.0` (`ce9d0753`), `v0.4.0` (`365be814`) und `v0.5.0` (`05619ae5`): der
`ci`-Lauf am Tag-Commit fiel im ersten Versuch im `full-smoke` an `make traeger-fetch` im frischen
Klon mit `curl: (22) … 404` (Jobs `112691251599`, `112729405107`, `112925525011`). Drei Schnitte ohne
eigenen Slice, ein Vorgang; operativer Ausgang war der Re-Run.
