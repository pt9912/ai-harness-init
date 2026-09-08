# Träger für den Vorgang belegt den Bestand nicht

**Sub-Area:** `*` (gesamtes Repo)

Ein Slice gibt einem bisher händischen Vorgang seinen Träger — ein `make`-Ziel, ein Sensor, ein
Unterkommando — und schließt damit die Lücke **ab jetzt**. Über den Bestand, der vor ihm entstanden
ist, sagt der Träger nichts: dass das vorhandene Artefakt aus der Quelle stammt, die der Träger
verwendet, belegt er rückwirkend nicht. Wer ihn danach als Deckung des Bestands liest, behauptet
mehr als er liefert
([`LH-QA-01`](../../../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
Die zwei Ebenen — *Vorgang reproduzierbar* und *Bestand belegt* — trennt allein Prosa.

## Benannt, nicht gezählt

Drei Nachbarklassen sind enger und decken den Fall nicht:
[`gruen-aussage-ohne-herkunft`](../gruen-aussage-ohne-herkunft/observation.md) trennt *gemessen*
von *belegt* an derselben Zusage;
[`vollstaendigkeits-zusage-misst-falsche-ebene`](../vollstaendigkeits-zusage-misst-falsche-ebene/observation.md)
misst ein Delta auf der Datei- statt der Hunk-Ebene; und
[`zusage-nennt-sensor-der-form-nicht-sieht`](../zusage-nennt-sensor-der-form-nicht-sieht/observation.md)
setzt einen Sensor voraus, der die ausgegrenzte Form nicht sieht. Hier ist der Träger vorhanden,
richtig und wirksam — nur über einer anderen Menge als der, die die Lücke benennt.
