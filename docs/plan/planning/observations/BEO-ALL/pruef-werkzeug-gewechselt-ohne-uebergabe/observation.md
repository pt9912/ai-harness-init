# Prüf-Werkzeug gewechselt ohne Übergabe

**Sub-Area:** `*` (gesamtes Repo)

Ein Liefer-Punkt nennt das Werkzeug, mit dem seine Zusage gemessen wird (etwa bats), und der
ausführende Lauf misst sie mit einem anderen (etwa einem Go-Test), ohne den Wechsel dem Planner zu
übergeben. Die Regel-Seite kann vollständig gehalten sein; abweichend ist der Wortlaut der
Abnahme, den der Verifier wörtlich liest. Die Fehlerrichtung ist *der Planner sieht den Wechsel
erst im Review*: entweder findet der Verifier keinen Fall des genannten Werkzeugs, oder er hakt den
Punkt ab, ohne dass jemand den Tausch entschieden hat.
