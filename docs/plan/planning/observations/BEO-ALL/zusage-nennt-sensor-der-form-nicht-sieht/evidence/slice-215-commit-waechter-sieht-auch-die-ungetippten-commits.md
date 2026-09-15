**Vorgang:** slice-215-commit-waechter-sieht-auch-die-ungetippten-commits
**Fund:** Eine Zelle der neuen Reichweiten-Tabelle behauptete eine **absolute** Eigenschaft ihrer
Klasse und war durch den Bestand widerlegt. Sie sagte über die Werkzeug-Klasse *,heute trägt keine
eine* (nämlich keine Kennung) — gemessen tragen **367 von 411** `slice-mv`-Messages eine
Ziffern-Kennung, und die drei jüngsten alle:

```sh
RE='ADR-[0-9]{4}|LH-[A-Z]{2}-[0-9]{2}|MR-[0-9]{3}|slice-[0-9]+'
git log --format='%s' | grep '^slice-mv:' | grep -cE  "$RE"                 # 367
git log --format='%s' | grep '^slice-mv:' | grep -vcE "$RE"                 #  44
```

Verletzt ist damit genau die Form, die dieser Eintrag führt: Die Zelle nennt einen Geltungsbereich
(*die Werkzeug-Klasse trägt keine Kennung*), den der Bestand nicht hält — er **teilt** ihn. Der
Satz ist in beiden Lesarten zu stark: als Aussage über die **resultierende Message** falsch, als
Aussage über die **vier Message-Formen** müßte er *„die Formen tragen keine eigene Kennung"*
heißen; die
[`ADR-0053`](../../../../../../../docs/plan/adr/0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md)
formuliert dieselbe Sache genau so und vorsichtiger.

**Die Klasse war der eigene angekündigte Fall.** DoD (3) des Plans führt als Rot-Kriterium
*„eine Zusage im Text, für die der Lauf kein Gegenbeispiel herstellen kann"*, und §8 nennt diesen
Eintrag als das Evidenz-Risiko der DoD (3) — mit dem Zähler-Stand des Plan-Zeitpunkts. Der Befund
ist damit nicht nebenher angefallen, sondern der eingetretene Fall der eigenen Ankündigung.

**Geschlossen im Vorgang, nicht vertagt:** Die Zelle ist in `dc392dd9` auf die gemessene Aussage
gezogen — sie nennt jetzt die zwei kennungslosen Teil-Mengen (die Namens-Form aus
[`MR-057`](../../../../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
und `archive-welle`) samt dem Kommando, das die 44 liefert. Die Form der Zusage ist damit an den
Teil gebunden, den der Bestand trägt.
