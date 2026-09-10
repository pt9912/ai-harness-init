# Neue öffentliche Funktion ohne benannte Grenze

**Sub-Area:** `*` (gesamtes Repo)

Eine neu eingeführte öffentliche Funktion nennt in ihrem Doc-Kommentar keine ihrer Grenzen —
oder nennt sie unvollständig, während die Nachbar-Funktionen derselben Datei ihre Annahmen
ausdrücklich führen. [`AGENTS.md`](../../../../../../AGENTS.md) §3.7 kennt *Grenze* als eine der
fünf Klassen, die ein Kommentar tragen kann, verlangt sie aber nicht; die Fehlerrichtung ist
*die Funktion tut, was ihr Name sagt*, und der nächste Lauf erfährt erst durch einen Fund, wo sie
es nicht tut. Die Klasse ist auch dann getroffen, wenn die Grenzen **aufgezählt** sind und eine
Bilanz-Zeile darüber weniger nennt als die Aufzählung führt.

Der Unterschied zur Nachbarklasse
[`zusage-nennt-sensor-der-form-nicht-sieht`](../zusage-nennt-sensor-der-form-nicht-sieht/observation.md)
ist die Richtung: Dort steht eine Deckungs-Behauptung, die zu weit greift; hier fehlt die Aussage
über den ungedeckten Rest ganz oder bleibt hinter ihm zurück.
