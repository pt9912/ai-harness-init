**Vorgang:** slice-flache-welle-ist-eroeffnet-nicht-geplant
**Fund:** Zweimal in einem Vorgang, an zwei Artefakten — für den Zähler **eine** Gelegenheit, und
das Erstauftreten, das dem Eintrag die Kennung gibt.

**Der Welle-Plan.** Der Umsetzungs-Commit änderte im Implementations-Kontext die
`Lifecycle:`-Kopfnote von drei Welle-Plänen. Ob das zulässig ist, sagte vorher keine Quelle: Die
Baseline weist die **Eröffnung** und die sechs Closure-Schritte zu,
[`AGENTS.md`](../../../../../../../AGENTS.md) §3.10 den **Abschluss** — ein Text-Nachzug an einem
bereits eröffneten Plan fällt zwischen beide. Der Vorgang beantwortete die Frage faktisch, das
Review meldete sie als HIGH mit Rollen-Widerspruch, und die Auflösung kostete ein Architect-Verdikt
plus drei Konsistenzrunden
([ADR-0048](../../../../../adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md)).

**Die Planning-README.** Derselbe Commit änderte `docs/plan/planning/README.md`. Für diese Datei
nennt ebenfalls keine Quelle eine schreibende Rolle — eine eigene Suche findet **eine** Stelle, und
die ordnet ihr im Instanz-Register nur ihre Vorlage zu. Die zweite Runde hat es geprüft und
festgehalten: *„keine Quelle weist sie einer anderen Rolle zu"*. Auch hier ist die Frage durch den
Vorgang beantwortet und durch keine Entscheidung.

**Der Unterschied zur Nachbarklasse ist gemessen, nicht vermutet.**
`BEO-ALL/fremdes-rollen-artefakt-im-implementations-kontext` verlangt ein Artefakt, *„dessen
Eigentum eine Quelle einer anderen Rolle zuweist"*; für beide Fälle oben tut das keine — dieselbe
Messung, die
[ADR-0048](../../../../../adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) §Kontext führt,
in dieser Closure unabhängig reproduziert (**3** Treffer im engen Prüfbereich, **4** in der
breiteren Gegenprobe, alle gelesen; keine Erwartungswerte). Jener Eintrag bekommt aus diesem
Vorgang deshalb **keinen** Beleg.
