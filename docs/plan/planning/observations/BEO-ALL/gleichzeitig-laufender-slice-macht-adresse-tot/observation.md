# Gleichzeitig laufender Slice macht Adresse tot

**Sub-Area:** `*` (gesamtes Repo)

Ein Slice schreibt eine Adresse in ein **lebendes** Artefakt, und ein **anderer**, gleichzeitig in
`in-progress/` liegender Slice löst ihr Ziel auf, bevor der erste schließt — kein `git mv` des
Lifecycle, keine Prozess-Anweisung, sondern zwei legitime Vorgänge, die denselben Ort berühren. Der
erste Slice merkt nichts: Sein Umsetzungs-Commit war richtig, als er entstand, und der zweite hat
keinen Anlass, in einen fremden, noch offenen Slice zu sehen.

Drei Nachbarklassen teilen das Symptom und nicht die Ursache:
[`vorgeschriebener-ortswechsel-macht-adresse-tot`](../vorgeschriebener-ortswechsel-macht-adresse-tot/observation.md)
setzt ein nach [`AGENTS.md`](../../../../../../AGENTS.md) §3.4 eingefrorenes Artefakt und einen vom
Prozess **vorgeschriebenen** Ortswechsel voraus — hier ist beides lebend und der Wechsel
freiwillig;
[`verweise-brechen-beim-ortswechsel`](../verweise-brechen-beim-ortswechsel/observation.md) misst die
Verweis-Formen auf eine Slice-Datei beim Lifecycle-`git mv` und ist in `make slice-mv` verkörpert,
das den bewegenden Lauf bedient — hier bewegt sich keine Datei, sondern der Inhalt einer bleibenden;
und [`sensor-pruefbereich-deckt-den-bewegten-ort-nicht`](../sensor-pruefbereich-deckt-den-bewegten-ort-nicht/observation.md)
trifft den Prüfbereich eines Sensors statt eine Adresse.

## Benannt, nicht gezählt

Die Gleichzeitigkeit ist die Bedingung der Klasse, und sie ist an der Ablage ablesbar: Das
WIP-Limit des Baseline-Regelwerks (`modul-05-planning-harness.md` §Trigger je Lifecycle-Übergang
und WIP-Limit) ist **1 pro Rolleninhaber**, und `in-progress/` führt mehr als einen Slice
desselben. Ob das die Ursache ist oder nur ihre Gelegenheit, ist hier **nicht** entschieden —
dieser Eintrag registriert die Adress-Klasse, er beurteilt die Lifecycle-Disziplin nicht.
