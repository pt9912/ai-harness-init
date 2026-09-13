**Vorgang:** slice-224
**Fund:** Drei Sendungen dieses Slice hatten keinen annehmenden Träger, und die drei zerfallen in
zwei Formen.

**Kein Empfänger.** Liefer-Punkt 3 nennt `.claude/commands/implement-slice.md` (Implementer) und
`.harness/skills/reviewer.md` (Reviewer) als Empfänger; beide sind Rollen-Anweisungssätze
([`ADR-0028`](../../../../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)), und für
beide existierte kein Vorgang, der sie aufnimmt. Für den Reviewer erzeugt der Nachweis nicht
einmal eine Zeile — keiner der 42 Posten ist diese Datei —, während ihr Kopf einen Stand nennt,
den der Baum nicht mehr führt:

```sh
sed -n '4p' .harness/skills/reviewer.md   # **Baseline:** Agents-Regelwerk v6.0.0 (Kurs-Welle 116), …
ls .harness/baseline/                     # v6.7.2
```

**Empfänger, der ausschließt.** Die dritte Sendung hatte eine Adresse, und die Adresse schloss
genau das aus, was sie bekommen sollte: Der Nachweis schickt die Kennungs-Form-Deklaration an
einen Folge-Slice, dessen §1 *„kein neuer `MR`-Eintrag"* zweimal ausschließt. Eine Adresse, die
die Sendung nicht annimmt, ist keine — dieselbe Prüfung, die Baseline-Regelwerk
`modul-05-planning-harness.md` §Ziel-Form: Slice für die Ausschluss-Klasse *Folge-Slice übernimmt
es* verlangt.

Beide Formen fallen durch dieselbe Lücke: Die Folge-Slice-Paarung prüft **genannte** Kennungen auf
Existenz, nicht darauf, ob der genannte Plan den Gegenstand annimmt, und eine Sendung ohne
Kennung ist für sie gar kein Gegenstand. Die Closure hat für die ersten zwei je einen Träger
geschnitten und für die dritte den Ausschluss des Empfängers berichtigt.
