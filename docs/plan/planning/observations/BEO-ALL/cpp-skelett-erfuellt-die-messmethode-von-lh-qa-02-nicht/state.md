**Stand:** offen

Die Aussage über die Messmethode ist aus [`LH-QA-02`](../../../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) und der Skelett-Vorlage gelesen, an keinem
Sensor gemessen: kein Lauf hat zwei Bauten desselben Tags verglichen. **Ohne Beleg — ein Befund der
Register-Paarung (c), keine Ausnahme**
([`ADR-0069`](../../../../adr/0069-beleglose-register-verzeichnisse-sind-ein-befund-der-paarung-keine-ausnahme.md)):
das einzige Vorkommen steht unter *Benannt, nicht gezählt*. **Weg zum Beleg:** ein abgeschlossener
Vorgang, dessen Lauf die Messmethode am Skelett misst — zwei Bauten desselben Tags —, mit seiner Kennung
als Dateiname unter `evidence/`. **`gestrichen`** mit Begründung erst, wenn die Aussage nicht mehr
zutrifft: die Messmethode von `LH-QA-02` ist per Change Request so gefasst, dass das Skelett sie erfüllt,
oder das Skelett pinnt per Digest.
