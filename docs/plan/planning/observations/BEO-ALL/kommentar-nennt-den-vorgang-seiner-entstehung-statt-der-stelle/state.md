**Stand:** verkörpert

Zielort: [`AGENTS.md`](../../../../../../AGENTS.md) §3.7 — ein Kommentar beschreibt, was da ist,
und trägt Herkunft nur als **ein** auflösbares Feld, nie als Erzählung. Ein zweiter Herkunfts-Anker
steht nicht: Die Regel folgt aus dem adoptierten Stand `v6.8.0`, dessen Vorlage sie unter derselben
Nummer und demselben Titel führt ([`MR-031`](../../../../../../harness/conventions.md#mr-031--die-kommentar-regel-steht-in-der-adoptierten-baseline)),
und der Zielort trägt seine eigene Adresse.

**Grenze der Verkörperung, benannt.** Der Zielort nennt sie selbst (Absatz *Ein Wächter existiert
nicht*): `make comment-claims` prüft, ob ein **genannter** Sensor existiert, nicht, worüber ein
Kommentar spricht, und [`d-check.mk`](../../../../../../d-check.mk) liegt außerhalb seiner vier
Pfad-Muster. Träger bleibt der Lauf, der den Kommentar schreibt, und der Review danach.

**Sensor baubar, ohne Träger — offen beim Auftraggeber.** `make comment-claims` könnte in
Kommentaren die zwei zählbaren Klassen erkennen (Befund-Kennung; Slice-Kennung außerhalb der Form
`seit slice-…`). [`slice-070-comment-claims-pruefbereich`](../../../open/slice-070-comment-claims-pruefbereich.md)
nimmt ihn nicht an: er trägt mit Prüfbereich, Erkennung und Zähnen bereits drei Liefer-Punkte, und
die Frage *worüber ein Kommentar spricht* ist eine neue Erkennungs-Klasse neben seiner Frage *nennt
eine Zusage ihren Sensor* — ein vierter Liefer-Punkt bräche die Größenregel.
