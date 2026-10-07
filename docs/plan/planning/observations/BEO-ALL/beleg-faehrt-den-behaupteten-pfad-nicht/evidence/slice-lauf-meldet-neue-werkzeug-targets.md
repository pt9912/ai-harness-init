**Vorgang:** slice-lauf-meldet-neue-werkzeug-targets
**Fund:** DoD 1 sagte „Ein Go-Test hält das" für jede Meldezeile; die Zeile `neues Target: … (kein Gate)` führte kein Go-Test aus — ihre Löschung blieb unter `make test-go` grün und fiel nur in `make full-smoke` (Verifikation). Im Slice geschlossen mit `ece52b28` (Mutationsfall 535).
