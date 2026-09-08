# Hintergrund-Lauf wird gepollt statt abgewartet

**Sub-Area:** `*` (gesamtes Repo)

Ein Agenten-Lauf startet ein langlaufendes Kommando im Hintergrund und liest danach dessen
Ausgabe-Datei im Sekundentakt nach, statt auf ihr Ende zu warten. Der Anlass ist die
Zeit-Vorgabe des Bash-Werkzeugs: Ein Vordergrund-Lauf wird bei ihr abgeschnitten, der Lauf
weicht auf den Hintergrund aus — und findet für das Warten kein Mittel, das er benutzt.
Die Folge ist ein Strom, dessen Werkzeug-Mischung fast vollständig aus Lese-Zugriffen auf
denselben Gegenstand besteht; die Arbeit am Slice steht daneben in einstelliger Zahl.

Die Ausweich-Bewegung selbst ist regelkonform — ein blockierendes Kommando im Hintergrund zu
fahren ist der vorgesehene Weg. Beobachtet ist, was **danach** fehlt: der Lauf hat für
„warten, bis fertig" keinen Träger, den er wählt, und ersetzt ihn durch Wiederholung.

## Benannt, nicht gezählt

Der Lauf an `slice-127` zeigt dasselbe Muster in ausgeprägterer Form, bekommt hier aber
**keine** Beleg-Datei: Er fährt noch, sein Slice hat seinen Lifecycle nicht verlassen, und
ein Beleg erwartet den Vorgang dort, wo seine Klasse abschließt (`done/`). Er zählt, wenn er
schließt — nicht früher, auch wenn zwei Belege überzeugender aussähen als einer. Die Kennung
steht hier ohne Pfad, weil diese Datei ab Anlage unveränderlich ist und der Prozess den Ort
des genannten Slice noch bewegt ([`AGENTS.md`](../../../../../../AGENTS.md) §3.11).

**Der Bestand trägt keinen dritten Beleg mehr, und das ist eine Eigenschaft des Bestands,
nicht der Klasse.** Der Span-Bestand unter `.harness/state/spans/` ist gitignored und
maschinenlokal ([`spec/spezifikation.md`](../../../../../../spec/spezifikation.md#5-metriken-und-tracing-felder)
§5: *„Die Probe gehört gefahren, nicht zitiert"*); am 2026-09-08 wurde alles vor dem
2026-09-05 gelöscht. Ob das Muster davor auftrat, ist damit **nicht mehr messbar** — wer
hier zwei Vorkommen liest, liest den verbliebenen Ausschnitt und nicht die Geschichte.
