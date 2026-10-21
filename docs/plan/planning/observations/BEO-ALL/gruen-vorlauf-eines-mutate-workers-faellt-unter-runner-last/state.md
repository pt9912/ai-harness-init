**Stand:** offen

Zähler 2 (`ls evidence | wc -l`), unter der Schwelle: der Nacht-Lauf 39387625541 (`has_amend_flag`) und der Lauf vom 2026-10-17 (`go-freshness`, 141) haben keinen abgeschlossenen Vorgang und zählen nicht. Beide Fundstellen des Branch-Laufs nutzen die Form `printf … | grep -q` bzw. eine Pipe unter `set -euo pipefail` (`harness/tools/pre-commit-amend-guard.sh` `has_amend_flag`; Quelle des 141 in `test/go-freshness.bats` Zeile 65 nicht gelesen); die Pipe als Ursache ist vermutet, nicht belegt.
