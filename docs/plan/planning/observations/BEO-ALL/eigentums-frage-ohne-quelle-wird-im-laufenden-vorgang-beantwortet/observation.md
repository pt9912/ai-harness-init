# Eigentums-Frage ohne Quelle wird im laufenden Vorgang beantwortet

**Sub-Area:** `*` (gesamtes Repo)

Für ein Artefakt sagt keine Quelle, welche Rolle es schreiben darf — und die Frage wird trotzdem
beantwortet: nicht durch eine Entscheidung, sondern dadurch, dass ein laufender Vorgang das
Artefakt anfasst. Der nächste Lauf findet dann Bestand statt Norm und kann sich auf beides berufen,
je nachdem, welchen Commit er liest.

Die Klasse ist an einem Muster kenntlich: Sie wird erst **sichtbar**, wenn ein Review sie als
Rollen-Widerspruch meldet, und die Auflösung kostet dann eine Entscheidung je Artefaktklasse. Vier
solcher Entscheidungen führt dieses Repo bereits — für zwei Norm-Artefakte
([ADR-0015](../../../../adr/0015-rollen-eigentum-an-norm-artefakten.md)), für ein derivatives
Register ([ADR-0024](../../../../adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md)),
für den Rollen-Anweisungssatz
([ADR-0028](../../../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)) und für den
Welle-Plan ([ADR-0048](../../../../adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md)) —,
und jede verengt sich ausdrücklich auf ihren Gegenstand. Was sie **nicht** erreichen, bleibt offen,
und der nächste Vorgang beantwortet es wieder faktisch.

**Dieser Eintrag hat einen benannten Konsumenten.**
[ADR-0048](../../../../adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) hängt ihren
fünften Re-Evaluierungs-Trigger an den Zähler dieses Verzeichnisses: Erreicht er 3×, ist die
Verengung auf je eine Artefaktklasse aufgebraucht, und die Frage gehört als allgemeine Regel
entschieden statt ein fünftes Mal einzeln.

## Benannt, nicht gezählt

Die Nachbarklasse
[`anweisungssatz-eigentum-ohne-quelle`](../anweisungssatz-eigentum-ohne-quelle/observation.md) ist
derselbe Befund für **einen** Gegenstand — die Anweisungssätze unter `.claude/commands/` — und
trägt dort ihren eigenen Ausgang. Hier ist der Gegenstand die Wiederkehr über Artefaktklassen
hinweg, nicht die einzelne Lücke.
