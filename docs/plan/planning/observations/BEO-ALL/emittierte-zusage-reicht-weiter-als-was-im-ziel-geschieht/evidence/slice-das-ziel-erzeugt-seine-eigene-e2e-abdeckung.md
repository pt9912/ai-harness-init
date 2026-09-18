**Vorgang:** slice-das-ziel-erzeugt-seine-eigene-e2e-abdeckung
**Fund:** Der Kopf der emittierten Vorlage `e2e-abdeckung.sh` sagte dem Adopter
**unbedingt** zu, was ihr Ableitungs-Zweig nur **bedingt** hielt: *„Das ist die Wahl gegen
einen Verweis, der ins Leere zeigt: ein toter Link faerbt ein Doku-Gate rot"*, während der
Zweig den Anker aus der Überschrift der Ziel-Spec selbst bildete und ihn gegen die
Zieldatei **nicht** prüfte. Eine Überschrift mit Zeichen außerhalb der Lösch-Menge
(reproduziert mit `»«`) ergab einen Verweis ins Leere, der Lauf endete mit Exit 0 und
meldete *„0 ohne Verweis"* — und das `docs-check` **des Ziels** fiel mit `anchor-missing`
auf einer Datei, die das Werkzeug selbst geschrieben hatte. Die Fehlerrichtung ist die
dieses Eintrags: im Ziel liegt, was hier steht, und der Adopter kann es nicht gegenprüfen,
weil er den Emitter nicht liest.

**Dreimal in drei Review-Runden, jedes Mal mit verschobener Ursache** (Runde 1: die
Lösch-Menge; Runde 2 und 3: die Nachfolge-Fassungen derselben Ableitung) — die
Summary-Zeile jeder Runde führt die Klasse wörtlich. **Ein Vorgang, ein Beleg.** Aufgelöst
ist sie nicht durch eine Kalibrierung, sondern durch den Wegfall des Zweigs: die
ausgelieferte Fassung schreibt jede Kennung als Code-Span und leitet keinen Anker mehr ab
(`grep -c '](' docs/user/e2e-abdeckung.md` im gebootstrappten Ziel → **0**, gemessen vom
Verifier; kein Erwartungswert).
