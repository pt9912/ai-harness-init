**Vorgang:** slice-kopplungsform-feldnotiz-spec-braucht-architektur-verdikt
**Fund:** Erstauftreten. Das Architect-Verdikt zu diesem Slice (`docs/reviews/2026-09-27-verdikt-kopplungsform-feldnotiz-spec.md`)
misst acht Zeilenpaare zwischen `SchemaNotes()` und Spec §5 nach und findet drei Kategorien:
reine Umformulierung derselben Aussage (`seq`, `slice`, `tool_use_id`), strukturelle Differenz
(`session`/`agent`: die Spec bündelt beide in einer Frage, der Träger stellt für `agent` eine
eigene zweite Frage) und Substanz-Gefälle (`program`/`argc`: die Spec-Zeile trägt mehrere hundert
Wörter Rand-Fälle, der Träger einen Satz). Die gewählte Antwort (bidirektionaler
Existenz-Abgleich, [`ADR-0071`](../../../../../adr/0071-kopplung-feldliste-spec-ist-existenz-abgleich.md), Proposed) deckt bewusst nur die Existenz-Achse — ob ein Feld auf
beiden Seiten überhaupt vorkommt — und lässt die Kernaussage-Achse ausdrücklich als
**akzeptiertes Negativ** offen ([`ADR-0071`](../../../../../adr/0071-kopplung-feldliste-spec-ist-existenz-abgleich.md) §Konsequenzen). Kein Sensor, weder der bestehende
Doku-Gate noch der neu benannte Existenz-Sensor, hält die Kernaussage zweier existierender Zeilen
gegeneinander.
