**Stand:** offen

Unterhalb der Schwelle; `offen` ist hier der Normalzustand und kein Ausgang — *geplant* und
*verkörpert* sind die Antwort auf die Schwelle
(`modul-06-roadmap.md` §Das Beobachtungs-Register), und sie ist mit einem Beleg nicht erreicht.

Der vorgeschlagene Träger ist geliefert: `slice-mutate-fall-filter-und-die-belegform-vereinigung` ist
geschlossen. Der Fall-Filter `MUTATE_CASES` und die Regel, unter der zwei Läufe am identischen Schlüssel
eine Aussage im Verifikationsbericht tragen, stehen in `harness/sensors/mutate.md` (§Zwei Läufe, eine
Aussage). Der Slice erlebte selbst keinen weiteren Vorgang der Klasse und trägt darum keinen Beleg; der
Stand bleibt `offen`, und der Ausgang ist mit der Schwelle nicht gefordert.

Die Regel ist Prosa: kein Doku-Modul hält ihren Inhalt.

Ein Wächter besteht nicht: Die Ursache liegt außerhalb des Repos. Träger ist der Lauf, der den Beleg
liest — er liest die Ursache je Befund und weist nach, dass der Fall im anderen Lauf `ok` ist und dass
der Prüfgegenstand nicht bewegt wurde.
