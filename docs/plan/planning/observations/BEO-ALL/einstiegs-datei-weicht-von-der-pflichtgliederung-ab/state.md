**Stand:** offen

Ein Wächter besteht nicht, obwohl das Werkzeug ihn trüge: Das d-check-Modul `structure` prüft
Struktur-Invarianten innerhalb eines Dokuments und ist im gepinnten Bild verfügbar, aber nicht
aktiviert (`grep -c structure .d-check.yml` → **0**, Exit 1 —
[`MR-024`](../../../../../../harness/conventions.md#mr-024--d-check-pin-v0620-structure-verfügbar)
§Zweck). Ob es genau diese Gliederung halten könnte, ist **ungemessen**; verfügbar heißt nicht
passend. Keines der Module aus `modules:` der
[`.d-check.yml`](../../../../../../.d-check.yml) prüft heute die Sektionsfolge einer Datei.
