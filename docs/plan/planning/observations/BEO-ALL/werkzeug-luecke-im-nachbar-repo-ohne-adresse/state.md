**Stand:** offen

Ein Träger besteht nicht: Kein Modul aus `modules:` der
[`.d-check.yml`](../../../../../../.d-check.yml) urteilt über das Werkzeug, das es selbst ist, und
`make mutate` kennt keine Fehlschlag-Form für eine Anforderung an einen anderen Baum. Auch die
Planungs-Seite hat keine: Der Lifecycle dieses Repos kennt `open/` für Arbeit **in** diesem Baum,
und [`docs/plan/adr/`](../../../../adr/) entscheidet, es beauftragt nicht. Träger ist der Lauf,
der die Lücke misst, und das Zeitdokument, in dem seine Messung stehen bleibt.
