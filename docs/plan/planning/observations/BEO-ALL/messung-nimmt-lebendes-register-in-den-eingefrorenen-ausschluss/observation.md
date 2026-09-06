# Messung nimmt ein lebendes Register in den Ausschluss der eingefrorenen Originale

**Sub-Area:** `*` (gesamtes Repo)

Eine Fundmengen-Messung schließt ein **Verzeichnis** aus, weil die Artefakte darin eingefroren sind
([`AGENTS.md`](../../../../../../AGENTS.md) §3.4), und nimmt das **derivative Register** daneben
still mit — den Index, den der Prozess mit jedem neuen Original fortschreibt und der nach
[`ADR-0024`](../../../../../../docs/plan/adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md)
der Rolle seiner Originale gehört, nicht deren Immutabilität. Die Fehlerrichtung ist
*die Fundmenge ist kleiner*: Der Ausschluss ist auf dem Verzeichnis begründet und trennt nicht nach
der Eigenschaft, die ihn trägt.
