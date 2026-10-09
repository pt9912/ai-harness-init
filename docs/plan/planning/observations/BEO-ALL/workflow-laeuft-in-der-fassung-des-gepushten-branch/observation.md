# Workflow mit Schreibrecht läuft in der Fassung des gepushten Branch

**Sub-Area:** `*` (gesamtes Repo)

Ein Workflow mit `contents: write`, der auf einen Push nach einem Branch-Präfix startet, läuft in der Fassung dieses Branch: wer dorthin pushen darf, bestimmt, was der Job mit dem Token tut, auch einen Push auf `main`. Solange `main` keinen Branch-Schutz trägt, schützt nichts im Repo davor; den Schutz setzt nur der Auftraggeber.
