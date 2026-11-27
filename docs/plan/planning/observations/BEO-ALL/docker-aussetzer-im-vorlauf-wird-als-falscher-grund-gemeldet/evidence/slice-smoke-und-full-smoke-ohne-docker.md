**Vorgang:** [slice-smoke-und-full-smoke-ohne-docker](../../../../done/slice-smoke-und-full-smoke-ohne-docker.md)
**Fund:** Realer `make full-smoke`-Lauf am daemon-losen Host (2026-11-27): die
Vorlauf-Wächter-Stufe über dem vollständigen Klon brach an
`make -f d-check.mk doc-commits` — der docker-Lauf der emittierten
d-check.mk meldete `Cannot connect to the Docker daemon …`, und `einordnen`
las den Ausgang als **BAUM** („Keine der 5 gefuehrten Formen einer nicht
mit 2xx beantworteten Anfrage … steht in den 3 gelesenen Zeilen; der
Fehlschlag wird dem geprueften Baum zugerechnet“), nicht als Docker-Aussetzer.
Grenze am selben Ort: dem `smoke`-Modus ist der Treiber mit diesem Slice
aus der Daemon-Vorbedingung entlassen; `full-smoke` bleibt in ihr
(harness/tools/mutate.sh, main-Einstieg), bis ein Folgeslice die
Restmenge trägt (a-check --print-mk ohne Host-Carrier, Docker-Builds der
nicht-Go-Code-Gates).
