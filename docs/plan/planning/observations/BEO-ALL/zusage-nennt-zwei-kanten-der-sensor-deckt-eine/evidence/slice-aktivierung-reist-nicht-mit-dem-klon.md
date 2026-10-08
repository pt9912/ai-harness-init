**Vorgang:** slice-aktivierung-reist-nicht-mit-dem-klon
**Fund:** Die neue `full-smoke`-Stufe *Aktivierung im Klon* sagt vier Teile zu — (a) Commit ohne
Kennung im unaktivierten Klon geht durch, (b) Träger fehlt, (c) Träger ist ein Verzeichnis,
(d) `HOOKS_DIR` auf ein leeres Verzeichnis —, und `make mutate` bindet mit
`test/mutations/588-aktivierung-ohne-traeger-pruefung.sh` allein (b). Die Prüfungen für (c) und (d)
haben Zähne in der Stufe, aber keinen gelisteten Fall, der sie gegen ein späteres Aufweichen hält.
Review INFO-1 (`docs/reviews/2026-10-08-aktivierung-im-klon-review.md`), von der Verifikation als
bestehend bestätigt.
