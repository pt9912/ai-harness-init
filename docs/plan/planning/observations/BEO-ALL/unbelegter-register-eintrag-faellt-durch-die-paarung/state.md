**Stand:** verkörpert

Zielort: [`ADR-0069`](../../../../adr/0069-beleglose-register-verzeichnisse-sind-ein-befund-der-paarung-keine-ausnahme.md)
Festlegungen 1 bis 4 (`Accepted`) — die Lesart *„benannt, nicht gezählt" ist ein Abschnitt des belegten
Eintrags, ein Verzeichnis ohne Beleg ein Befund der Paarung (c), keine Ausnahme* — und die
[Register-README](../../README.md), Absätze *Ein Verzeichnis ohne Beleg ist ein Befund der
Register-Paarung (c)* und *Die zweite Hälfte von (c)*. **Die Regel folgt aus einer ADR**, darum trägt
der Zielort an dieser Stelle seine eigene Kennung und keinen Herkunfts-Anker `seit …`
(`grep -c 'adr/0069-beleglose' docs/plan/planning/observations/README.md` → 1, kein Erwartungswert).

**Grenze der Verkörperung, benannt.** Ein Wächter existiert nicht: kein Modul aus `modules:` der
[`.d-check.yml`](../../../../../../.d-check.yml) hält die zweite Hälfte von (c), und `make docs-check` bleibt
über einem weiteren Verzeichnis ohne `evidence/*.md` grün
([`ADR-0069`](../../../../adr/0069-beleglose-register-verzeichnisse-sind-ein-befund-der-paarung-keine-ausnahme.md)
§Kontext). Träger ist der Lauf, der die Paarung fährt: die Results-Notiz der Wellen-Closure trägt die
Zeile mit N und den Namen der Verzeichnisse ohne Beleg
(`.claude/commands/close-welle.md`, Abschnitt der drei Paarungen); die Namen liefert das Kommando in der
Register-README. Ein Wächter ist erst verdrahtbar, wenn der Bestand durch Belege getilgt ist, nicht durch eine
Ausnahmeliste (Re-Evaluierungs-Trigger 2 derselben ADR).
