**Vorgang:** Review-Reports `docs/reviews/2026-09-14-adr-0048-konsistenzrunde.md` (MEDIUM-2) und
`docs/reviews/2026-09-14-adr-0048-konsistenzrunde-2.md` (INFO-1) — der Vorgang ist das Schreiben von
[ADR-0048](../../../../../adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) über seine
drei Konsistenzrunden. Zwei Funde, **eine** Gelegenheit, und das Erstauftreten, das dem Eintrag die
Kennung gibt.
**Fund:** Die Entscheidung setzt eine Probe, unter der ein Nachzug im Implementations-Kontext
laufen darf, und der Beleg, der den auslösenden Fall entschied, stand nicht in ihr.
**Zu wenig:** Die erste Fassung verlangte, dass ein **Original** existiert, und von keiner ihrer
Bedingungen, dass der nachgezogene Text dieses Original **wiedergibt**. Die Byte-Gleichheit, die
§Kontext als tragenden Beleg misst, war damit nicht Teil der Probe, die den Namen
*vorlagengebunden* trägt — eine freie Neuformulierung hätte alle Bedingungen bejaht.
**Zu viel:** Dieselbe Bedingung ließ alle neun Ränge der Source Precedence als Original zu, ohne
den Grund zu nennen — darunter die Roadmap, deren Fortschreibung eine andere Quelle dem Planner
zuweist. Der belegte Fall deckte davon einen.

Behoben vor dem Accept: eine vierte Bedingung bindet den neuen Text an sein Original und schließt
die freie Neuformulierung aus; die Breite der ersten Bedingung ist mit dem Grund versehen, warum
Bedingung 2 sie wieder einholt.
