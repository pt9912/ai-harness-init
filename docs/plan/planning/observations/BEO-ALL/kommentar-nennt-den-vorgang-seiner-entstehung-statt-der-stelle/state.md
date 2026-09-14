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
