**Stand:** offen

Der heute verfügbare Behelf ist ein Zeiger in der überholten Plandatei auf den Plan, der an ihre
Stelle tritt; er hält die Adresse gültig und sagt über den Zustand der Datei nichts. Ein Wächter
besteht nicht: kein Modul aus `modules:` der [`.d-check.yml`](../../../../../../.d-check.yml)
liest den Lifecycle, und `make mutate` kennt dafür keine Fehlschlag-Form.
