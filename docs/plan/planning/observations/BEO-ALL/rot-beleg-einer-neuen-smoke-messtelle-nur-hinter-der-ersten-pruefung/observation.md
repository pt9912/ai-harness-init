# Rot-Beleg einer neuen Smoke-Messtelle nur hinter der ersten von zwei Prüfungen

**Sub-Area:** `*` (gesamtes Repo)

Ein Zug legt in `make smoke` zwei Messtellen an, und der Rot-Beleg wird nur für die **erste**
geführt — die Hand-Mutation am Real-Pfad färbte allein die Existenz-Messtelle rot. Die zweite
(Gate-Neutralität, ein `grep`-Anspruch) läuft mit, ohne je gebrochen worden zu sein: Rot ist sie
reell (der geprüfte Satz steht in der Ausgangs-Vorlage nachweislich), aber ihr Mechanismus ist auf
Unit-Ebene gebunden — über einer Anspruchs-Fixtur, nicht über dem Real-Träger, und der Unit-Fall ist
kein Fall dieser Messtelle. Die Grenze trägt die Grenz-Zeile der Closure-Notiz des Träger-Slices,
nicht still grün.

Nachbarklassen: [`neuer-waechter-ohne-mutations-fall`](../neuer-waechter-ohne-mutations-fall/observation.md)
dort fehlt jeder Fall, hier bindet ein Fall auf Mechanismus-Ebene über einer Fixtur;
[`waechter-misst-die-fixture-statt-der-realen-quelle`](../waechter-misst-die-fixture-statt-der-realen-quelle/observation.md)
dort bleibt ein grüner Wächter über der Fixture behauptet, hier nennt die Messtelle ihren Ausschnitt
am eigenen Ort.

## Benannt, nicht gezählt

<keine>
