**Stand:** offen

Ein Wächter besteht nicht, obwohl das Werkzeug ihn trüge: Das d-check-Modul `structure` prüft
Struktur-Invarianten innerhalb eines Dokuments und ist im gepinnten Bild verfügbar, aber nicht
aktiviert (`grep -c structure .d-check.yml` → **0**, Exit 1 —
[`MR-024`](../../../../../../harness/conventions.md#mr-024--d-check-pin-v0620-structure-verfügbar)
§Zweck). Ob es genau diese Gliederung halten könnte, ist **ungemessen**; verfügbar heißt nicht
passend. Keines der Module aus `modules:` der
[`.d-check.yml`](../../../../../../.d-check.yml) prüft heute die Sektionsfolge einer Datei.

**Ohne Beleg — ein Befund der Register-Paarung (c), keine Ausnahme**
([`ADR-0069`](../../../../adr/0069-beleglose-register-verzeichnisse-sind-ein-befund-der-paarung-keine-ausnahme.md)).
Das einzige Vorkommen steht unter *Benannt, nicht gezählt*, und kein abgeschlossener Vorgang trägt es.
**Weg zum Beleg:** `slice-114` misst die Abweichung in §1, liegt aber in `next/`; seine Closure legt den
ersten Beleg an, wenn er schließt. Trifft die Aussage nach dessen Closure nicht mehr zu, ist der Weg
`gestrichen` mit Begründung. Die Einstiegs-Datei führt inzwischen die acht Abschnitte
(`grep -c '^## ' harness/README.md` → 8, kein Erwartungswert).
