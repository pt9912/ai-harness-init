**Vorgang:** slice-140
**Fund:** Sieben Review-Runden über derselben Stelle
(`ls docs/reviews/*slice-140*review-runde*.md | wc -l`, kein Erwartungswert). Jede Regex- und
Heuristik-Reparatur zog den im Report genannten Randfall und tauschte ihn gegen einen anderen,
während die reale Ausgabe byte-gleich blieb — die Fundmenge war nie gemessen, sondern jeweils aus
dem zuletzt gemeldeten Fundort erschlossen. Aufgelöst hat es erst die Kappung des Umfangs: den
Kommentar auf das einschränken, was hält, statt Vollständigkeit über eine ungemessene Menge zu
jagen.
