**Vorgang:** slice-223
**Fund:** Zwei `cp`-Quellen im Planner-Anweisungssatz `.claude/commands/close-welle.md` nannten das
Tag-Segment als Inline-Code und zeigten nach dem Baum-Tausch ins Leere. Gefunden hat sie das
Review, kein Sensor — die Adresse steht in einer **Handlungsanweisung** statt in einer Messung, und
der dokumentierte Ausweichpfad einer fehlgeschlagenen Kopie ist die hand-geschriebene
Ergebnisnotiz, die die `cp`-Pflicht gerade ausschließt. Das Instrument, das sie fand, ist ein
`git grep` über den abgehenden Tag; der Stand vor der Behebung steht als Tree-Operand:

```sh
git grep -cE '`[^`]*\.harness/baseline/v6\.5\.0[^`]*`' a262a26f^ -- .claude/commands/close-welle.md   # 2
```

Die in `state.md` gemessene Verengung trägt eine Achse weiter, als sie dort erhoben ist:
`.claude/` liegt wie `.harness/` außerhalb von `codepaths.roots`, und `make comment-claims` nimmt
jede Markdown-Datei dauerhaft aus dem Prüfbereich. Für **diese** zwei Stellen ist der Ausgang nicht
der Nachzug, sondern die Tag-Form `<tag>`, die dieselbe Datei in ihrer Quellen-Zeile bereits führte
— sie stirbt am nächsten Sprung nicht. Die Klasse schließt das nicht: Der nächste feste Pfad in
einer nicht gescannten Datei ist wieder stumm.
