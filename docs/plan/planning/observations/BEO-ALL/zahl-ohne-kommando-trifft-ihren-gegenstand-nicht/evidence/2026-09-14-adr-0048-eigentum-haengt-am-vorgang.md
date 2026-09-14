**Vorgang:** Review-Reports `docs/reviews/2026-09-14-adr-0048-konsistenzrunde.md` (LOW-3) und
`docs/reviews/2026-09-14-adr-0048-konsistenzrunde-2.md` (LOW-3) — der Vorgang ist das Schreiben von
[ADR-0048](../../../../../adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) über seine
drei Konsistenzrunden. Zwei Funde, **eine** Gelegenheit.
**Fund:** Zweimal spricht ein Satz über eine Menge, und das Kommando daneben deckt einen Teil davon.
Die Prosa sagte, **alle drei** Kopfnoten seien byte-gleich zur Ziel-Form bis auf den eingesetzten
Namen der Ergebnis-Notiz; die abgedruckte Schleife gibt **eine** Zeile aus und belegt damit eine
davon — die zwei übrigen waren erst durch zwei `diff`-Läufe des Reports gedeckt. Und ein
Re-Evaluierungs-Trigger zeigte auf *„die drei `grep -c`-Kommandos aus §Kontext"*, während der
Abschnitt zehn führt.

Beide sind vor dem Accept behoben — durch eine zweite Schleife, die die Differenzen ausgibt, und
durch einen Trigger, der seinen Block benennt statt zu zählen.
