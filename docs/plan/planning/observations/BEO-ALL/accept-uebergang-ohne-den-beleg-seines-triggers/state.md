**Stand:** offen

Die Regel steht seit dem ersten Beleg:
[ADR-0040](../../../../../../docs/plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md)
ist `Accepted` und bindet jeden Lauf, der eine ADR annimmt — Festlegung 2 verwirft die Nachmessung
durch den behebenden Kontext ausdrücklich. Ein Wächter besteht nicht: Kein Modul aus `modules:`
der [`.d-check.yml`](../../../../../../.d-check.yml) liest Status-Übergänge oder Report-Verdikte,
und das Modul `reviews`, das die Report-**Deckung** prüfen könnte, ist nicht aktiviert. Der
ausstehende Beleg für den auslösenden Fall ist als `slice-199` geschnitten.
