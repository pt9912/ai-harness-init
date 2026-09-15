**Vorgang:** slice-226-implementer-anweisungssatz-zieht-nach
**Fund:** Der sinntreu aus `modul-09-implementierung.md` übernommene Out-of-Scope-Block nennt eine
Scope-Ausweitung eine *„Plan-Änderung vor dem Code"* und nennt die Rolle nicht, während
[`AGENTS.md`](../../../../../../../AGENTS.md) §3.10 genau diesen Gegenstand — *„eine
Out-of-Scope-Grenze"* — als Übergabe-Artefakt dem Planner zuweist. Gemessen vor dem Nachzug
(`git grep -l 'Out-of-Scope-Grenze' bbd10ea2^ -- ':!docs/reviews' ':!.harness/baseline'`):
[`AGENTS.md`](../../../../../../../AGENTS.md) ist neben einem Register-Beleg und einem offenen Plan
die **einzige normative** Stelle, an der die Wendung steht. Das Regelwerk kennt keine Rollen; die
Kollision entsteht erst beim Übertragen. Der Nachzug hat die Rollen-Zuordnung aus §3.10 in den Block
gezogen — sie hat ihr Original, ist also keine neue Norm —, und kein Sensor liest den Fall.
