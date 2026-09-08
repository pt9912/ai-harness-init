**Vorgang:** slice-201
**Fund:** Der Verwerfungs-Beleg in
[`harness/README.md`](../../../../../../../harness/README.md) §Sensors fasst die Fundmenge eines
Sonden-Laufs zusammen und ist an ihr gemessen zu stark: Die Formel *„fast alle aus drei Klassen,
die kein Bug sind"* verbucht Fundstellen als Rauschen, die wörtlich der Fall sind, den derselbe
Absatz zwei Sätze weiter oben als den tragenden benennt. Der Fehler trat **zweimal in derselben
Ausgabe** auf, in komplementären Teilmengen: zuerst unter den Treffern mit
Vendoring-Präfix (Review), danach im ganzen Rest, dessen Filterzeile nur eine einzelne Fundstelle
herausgriff und die übrigen nicht klassifizierte (Verifikation). Beide Runden filterten auf
dieselbe Teilmenge und teilten damit denselben blinden Fleck.
