**Stand:** offen

Kein Modul aus `modules:` der [`.d-check.yml`](../../../../../../.d-check.yml) liest
Kommentar-Prosa, und `make comment-claims` nimmt die
[`.d-check.yml`](../../../../../../.d-check.yml) dauerhaft aus — sein Prüfbereich sind vier
Pfad-Muster unter `internal/`, `cmd/`, `harness/tools/` und `.claude/hooks/`
([`harness/README.md`](../../../../../../harness/README.md) §Sensors, Punkt 2). Beide Enden fehlen
damit: Die Reichweite eines Eintrags misst nur eine Sonde gegen das gepinnte Werkzeug, und den Satz
daneben liest kein Sensor. Träger ist der Lauf, der den Eintrag schreibt.
