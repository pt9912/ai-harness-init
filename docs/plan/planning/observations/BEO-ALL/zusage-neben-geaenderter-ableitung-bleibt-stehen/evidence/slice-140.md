**Vorgang:** slice-140
**Fund:** Die Abnahme selbst trug die Zusage. DoD (1) band den Zielwert an ein Kommando
(*„die `grep -vc '/\.claude/'`-Zeile fällt auf **0**"*); die **richtige** Behebung eines
HIGH-Befundes — das Backtick-Zitat der Kommentar-Syntax wird geschont statt zerstört — hob
denselben Wert legitim von 0 auf 1, und die Zeile daneben blieb stehen. Die Besonderheit dieses
Auftretens ist, dass sie **stehenbleiben musste**: [`AGENTS.md`](../../../../../../../AGENTS.md)
§3.10 verbietet der ausführenden Rolle, ihr eigenes Abnahmekriterium umzuschreiben. Der Lauf hat
die Verschiebung dreifach als Übergabe-Artefakt dokumentiert, und der Review hat sie gefunden —
der Träger war also da. Was fehlte, war ein Instrument, das die zwei Fälle trennt, die die Zusage
zusammenwirft: ein `<!--`-Zähler unterscheidet eine Kommentar-**Hilfe** nicht von einem
**Zitat** der Kommentar-Syntax.
