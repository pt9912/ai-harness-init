**Stand:** geplant

Kennung: `slice-werkzeug-luecke-im-nachbar-repo-bekommt-eine-adresse`. Er schreibt die Regel,
welche Adresse eine gemessene Lücke im gepinnten Nachbar-Werkzeug bekommt und wer über sie
entscheidet. Zielort und schreibende Rolle bestätigt der Architect.

Bis dahin besteht kein Träger: Kein Modul aus `modules:` der
[`.d-check.yml`](../../../../../../.d-check.yml) urteilt über das Werkzeug, das es selbst ist, und
`make mutate` kennt keine Fehlschlag-Form für eine Anforderung an einen anderen Baum. Die Messung
steht in dem Zeitdokument, das sie erhoben hat.
