**Vorgang:** slice-126
**Fund:** Zwei Kommentare dieses Slice beschrieben nicht die Stelle, an der sie stehen. Der Kopf von
`test/commit-msg-guard.bats` trug eine an sich selbst gerichtete Frage samt Antwort — *„… ist am
echten Repo demonstriert (Skriptkopf-BELEG unten in dieser Datei? nein: harness/README.md
dokumentiert den Traeger; …)"* —, also das Protokoll der Überlegung, die den Text erzeugt hat, und
keine der fünf Kommentar-Klassen aus [`AGENTS.md`](../../../../../../../AGENTS.md) §3.7. Der zweite
Fund liegt eine Runde später im Kommentar des neuen Mutations-Falls und beschreibt einen abwesenden
Text. Kein Sensor erreicht beide: `make comment-claims` prüft, ob ein genannter Sensor existiert,
und nimmt `test/` dauerhaft aus seinem Prüfbereich.
