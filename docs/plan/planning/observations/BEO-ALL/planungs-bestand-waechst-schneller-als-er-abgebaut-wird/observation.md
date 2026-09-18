# Planungs-Bestand wächst schneller, als er abgebaut wird

**Sub-Area:** `*` (gesamtes Repo)

Der Prozess legt Planungs-Artefakte schneller an, als er sie schließt. Jeder geschlossene Slice
bringt Review- und Verifikations-Befunde; jeder Befund nimmt eine der drei Routen —
Register-Eintrag, Folge-Slice, ausdrückliche Ablehnung —, und die ersten zwei legen wieder ein
Artefakt an, das selbst einen Abschluss verlangt. Der Zuwachs ist damit keine Folge schlechter
Schnitte, sondern die Form des Verfahrens: Die einzige Route, die nichts anlegt, ist die
Ablehnung, und sie verlangt ein Urteil, während die zwei anderen einer Form folgen. Die
Fehlerrichtung ist *der Bestand bildet den offenen Bedarf ab* — er bildet auch ab, was der Prozess
an sich selbst erzeugt hat.

Der Zuwachs ist an drei Stellen messbar, jede mit dem Kommando, das sie ausgibt; die Zahlen wandern
mit dem Baum und sind keine Erwartungswerte
([`MR-025`](../../../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2):

```sh
# Bestand offener Pläne, damals und heute
git ls-tree -r --name-only "$(git rev-list -1 --before=<datum> main)" docs/plan/planning/open | wc -l
ls docs/plan/planning/open/*.md | wc -l
# Bestand der Beobachtungen
ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l
# Bewegung im Fenster, und wieviel davon das Produkt erreicht
git log --oneline <ref>..HEAD | wc -l
git log --oneline <ref>..HEAD -- internal cmd | wc -l
```

Das letzte Paar trägt, was die ersten drei allein nicht tragen: **wie viel** der Bewegung am
Produkt ankommt. Ein wachsender Bestand neben gleichbleibender Produkt-Bewegung ist die Lage, die
diese Beobachtung benennt; ein wachsender Bestand neben wachsender Produkt-Bewegung wäre sie nicht.

## Benannt, nicht gezählt

**Dieser Eintrag trägt keinen Beleg und bewegt keinen Zähler.** Die Beobachtung ist eine Aussage
über den **Bestand** und seine Rate, nicht über ein Auftreten in einem abgeschlossenen Vorgang: Die
Messung oben wird zu einem Zeitpunkt über dem ganzen Baum genommen und hat keine Vorgangs-Kennung,
die sie als Dateinamen trüge. Ein Beleg je Closure wäre zudem eine Fehlmessung — die Klasse tritt in
nahezu jeder Closure auf, der Zähler zählte damit Closures statt Wiederholungen, und die Schwelle
wäre nach drei Vorgängen erreicht, ohne dass etwas dazugekommen wäre.

Drei Nachbarn treffen je einen Ausschnitt und nicht die Bilanz:
[`geplanter-slice-wird-nie-gearbeitet`](../geplanter-slice-wird-nie-gearbeitet/observation.md)
sieht den **einzelnen** Plan, den niemand arbeitet;
[`slice-plan-umfang-waechst-ueber-umsetzung-hinaus`](../slice-plan-umfang-waechst-ueber-umsetzung-hinaus/observation.md)
misst die **Größe eines Plans** gegen seine Umsetzung;
[`beleg-nach-dem-ausgang-findet-keinen-leser`](../beleg-nach-dem-ausgang-findet-keinen-leser/observation.md)
sieht die Belege, die **nach** einem Ausgang weiterlaufen. Keiner von ihnen misst, ob der Bestand
als Ganzes zu- oder abnimmt.
