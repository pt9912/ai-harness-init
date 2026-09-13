**Stand:** offen

Kein Modul aus `modules:` der [`.d-check.yml`](../../../../../../.d-check.yml) liest einen Diff,
und `make mutate` kennt dafür keine Fehlschlag-Form. Träger ist der Lauf, der den Beleg schreibt,
und der Griff, den dieser Fall gemessen hat: der whitespace-normalisierte Volltext-Vergleich
beider Stände statt eines Filters über dem Diff.
