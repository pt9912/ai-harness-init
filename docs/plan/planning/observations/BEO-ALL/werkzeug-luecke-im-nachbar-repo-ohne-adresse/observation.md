# Werkzeug-Lücke im Nachbar-Repo ohne Adresse

**Sub-Area:** `*` (gesamtes Repo)

Ein Lauf misst eine Lücke im gepinnten Fremd-Werkzeug `d-check` und stellt fest, dass dieses Repo
sie nicht schließen kann — die Abhilfe liegt im Nachbar-Repo desselben Nutzers und ist dort eine
**Anforderung**, keine feste Werkzeug-Grenze. Eine Adresse hat sie hier nicht: Eine Slice-Kennung
dieses Repos behauptete eine Datei, die es nicht gibt
([`LH-QA-01`](../../../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)),
und über den anderen Baum entscheidet kein Slice dieses Repos. Die Messung bleibt damit im
Zeitdokument liegen, das sie erhoben hat, und die laufende Nachpflege, die sie erzwingt, trägt
dieses Repo ohne Endtermin.

## Benannt, nicht gezählt

Ein zweiter Fall steht im Bestand, gemessen und beschrieben, aber ohne abgeschlossenen Vorgang, der
ihn als Beleg trüge: `make doc-commits` ist am gepinnten Stand unbedienbar — jeder `--range`-Lauf
des `commits`-Moduls bricht ab, solange `commits.id-patterns` eine nicht-leere Liste trägt, und mit
leerer Liste prüft es nichts. Der Absatz, der das führt, zieht dieselbe Folgerung:

```sh
grep -c 'Nachbar-Repo desselben' harness/sensors/commit-msg-check.md   # 1
```

Zwei Nachbarklassen decken den Fall nicht:
[`benannte-luecke-ohne-ausgang`](../benannte-luecke-ohne-ausgang/observation.md) fragt, wohin eine
**Grenz-Beschreibung** wieder verschwindet, wenn sie erledigt ist — hier ist offen, wer sie
überhaupt erledigt; und
[`vorhandene-faehigkeit-ohne-traeger-wird-von-hand-nachgebaut`](../vorhandene-faehigkeit-ohne-traeger-wird-von-hand-nachgebaut/observation.md)
setzt eine Fähigkeit im **eigenen** Code voraus, die nur keinen Einstieg hat.
