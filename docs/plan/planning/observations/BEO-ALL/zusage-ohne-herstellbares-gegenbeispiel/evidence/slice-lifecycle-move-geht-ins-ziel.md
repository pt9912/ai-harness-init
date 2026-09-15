**Vorgang:** slice-lifecycle-move-geht-ins-ziel
**Fund:** Die Sensor-Prosa des Vorgangs sagt vom Fragment des Nachzugs, es komme „aus dem tool-eigenen
Fragment, das jeder Bootstrap kanonisch neu schreibt“. Die Aussage ist **wahr** und **unbewacht**:
sie ruht auf der Emission, und kein gelisteter Sensor nimmt wahr, wenn die zwei Zielorte nicht mehr
kanonisch neu geschrieben werden. Gelesen und gefahren von der zweiten Verifikations-Runde des
Vorgangs (Report `2026-09-15-slice-lifecycle-move-geht-ins-ziel-verify-runde-2.md` §1.3) in einer
Baum-Kopie unter `/tmp` — erst ein Sondentest macht die Drift sichtbar, und er ist der einzige rote
Punkt:

```sh
# (a) Sondentest driftet die zwei Zielorte und laesst Enforce ein zweites Mal laufen
make test-go    # EXIT 0 — die Drift wird geheilt (die Aussage ist WAHR)
# (b) derselbe Sondentest, Enforce fuer die zwei Zielorte auf skip-if-present gepatcht
make test-go    # EXIT 2 — nur der Sondentest faellt
# (c) ohne den Sondentest, bei unveraenderter Mutation
make test-go    # EXIT 0 — kein gelisteter Waechter faellt
```

Der Vorgang hat die Grenze **benannt**, nicht geschlossen: sie steht jetzt als Satz an der Stelle der
Zusage. **Die Abgrenzung zu den zwei Nachbarn**, damit der Zähler die Klasse nicht spaltet:
[`zusage-nennt-sensor-der-form-nicht-sieht`](../../zusage-nennt-sensor-der-form-nicht-sieht/observation.md)
setzt voraus, dass die Zusage einen Sensor **nennt**, der die abgegrenzte Form nicht sieht — hier wird
keiner genannt. [`zusage-neben-geaenderter-ableitung-bleibt-stehen`](../../zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md)
setzt einen Fix voraus, der **Verhalten** ändert; hier ist keine Verhaltensänderung im Spiel. Was
diesen Eintrag trifft, ist seine zweite Hälfte: *nicht ein Sensor ist zu eng, es gibt gar keinen.*
