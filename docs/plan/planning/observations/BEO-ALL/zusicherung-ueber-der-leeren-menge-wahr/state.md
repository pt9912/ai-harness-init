**Stand:** verkörpert

Zielort: [`.harness/skills/reviewer.md`](../../../../../../.harness/skills/reviewer.md) — die MEDIUM-Zeile
*„Zusicherung über einer Menge, die leer sein kann"* in der Liste der Kategorien-Regeln, mit dem
Herkunfts-Anker `seit slice-mutate-fall-filter-und-die-belegform-vereinigung`
(`grep -c 'seit slice-mutate-fall-filter-und-die-belegform-vereinigung' .harness/skills/reviewer.md` → 1).
Der Anweisungssatz gehört der Rolle, die ihn ausführt: die Zeile schreibt der Reviewer
([`ADR-0028`](../../../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)); den Ausgang setzt der
Planner. Der Anker nennt den Slice, in dessen Closure die Klasse ihren dritten Beleg trug; dessen Kennung löst
über `done/` auf.

**Grenze der Verkörperung, benannt.** Ein Wächter existiert nicht: `make mutate` sieht die Vakuität nur, wenn ein
gelisteter Fall genau die Bezugsmenge entfernt — die Klasse ist an denselben Fall-Satz gebunden, dessen Lücke
sie ist. Träger ist das Review, das die Zeile abfragt; der Lauf, der die Zusicherung schreibt, trägt die Frage
danach, was ihr Ausdruck liefert, wenn seine Eingabe leer ist. **Eskalation:** tritt die Klasse nach der Zeile
erneut ein, ist der nächste Schritt eine Falsch/Richtig-Zeile in [`AGENTS.md`](../../../../../../AGENTS.md) §3.6
(Architect, §3.8).
