**Vorgang:** slice-wellen-schnitt-folgt-der-eroeffnungs-regel
**Fund:** Zwei Zusagen desselben Vorgangs — ein Vorgang, eine Gelegenheit. Beide entstanden **im
Nachzug selbst**, in den Sätzen, die die von
[`ADR-0046`](../../../../../adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) Festlegung 1
beendete Gleichsetzung ersetzen.

*(a) Die Roadmap.* §Nächste Wellen sagte zu, `make docs-check` melde `wave-preview-exists`, sobald
zu *einer hier genannten Kennung* bereits eine flache Datei existiert. Das Modul `waves` liest dafür
die **erste** Spalte der Vorschau-Tabelle; eine Nennung in Spalte 3 (*Wichtigste Slices*) sieht es
nicht — und genau dort stehen `welle-13` und `welle-09`, beide mit flacher Datei, beide ohne Befund.

*(b) Der Anweisungssatz.* `.claude/commands/plan-welle.md` stellte im Kopf die Trigger-Pflicht und
die Gate-Folge (*„Wer die Datei früher anlegt, färbt `make docs-check` rot"*) in denselben Absatz.
Kein Modul liest den Start-Trigger: Geprüft ist allein die Kopplung Datei ⟺ Zeiger ⟺ Vorschau-Zeile,
und eine **vollständig** vorgezogene Eröffnung bleibt grün.

Gefunden hat beide der Review (F-1/F-2, 2 MEDIUM, merge-blockierend); ein Sensor kann es nicht —
kein Modul hält einen Prosa-Satz gegen den Prüfumfang eines anderen Moduls. Behoben sind sie in
`233e1385`, und zwar durch das **Zitat** der Grenze, die
[`ADR-0046`](../../../../../adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) §Fitness Function
bereits führt, statt durch eine zweite, neu formulierte Zusage.
