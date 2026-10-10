# Handbuch-Sprachbaum ohne Sensor in `full-smoke`

**Sub-Area:** `*` (gesamtes Repo)

Das Benutzerhandbuch beschreibt je Sprache einen Baum, den die Emission erzeugt. `make full-smoke` fährt
den Bootstrap nur für `dokument-only`, `go` und `cpp`; der Baum der Sprache `kotlin` im Handbuch hat
keinen Sensor, der ihn gegen die Emission hält. Die Aussage trägt allein der Reviewer, der sie liest.
