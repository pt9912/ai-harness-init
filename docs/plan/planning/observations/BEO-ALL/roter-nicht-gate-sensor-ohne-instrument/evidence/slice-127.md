**Vorgang:** slice-127
**Fund:** Die DoD führt den Standard-Punkt *„`make mutate` ohne Befund"*. Der vollständige Lauf
meldete **269 ok, 1 Befund(e)**, und der eine Befund ist `221-ignore-refs-restbreite` — ein
vorbestehender Fall, dessen Ursache in einem anderen, bereits geschlossenen Vorgang liegt und den
Review wie Verifikation übereinstimmend außerhalb dieses Slice verorten. Kein Fall dieses Slice ist
betroffen, und der Wächter unter `221` ist intakt; rot ist die Buchhaltung seines Kopfes.

Für genau diese Lage hält die Closure kein Werkzeug bereit. `make mutate` führt
[`harness/README.md`](../../../../../../../harness/README.md) ausdrücklich unter *Nicht-Gate-Verify* —
die Carveout-Regel, die einen roten **Gate**-Status auf einen Trigger schaltet, hat damit keinen
Gegenstand. Der Punkt konnte deshalb weder abgehakt noch mit dem vorgesehenen Instrument getragen
werden; getragen hat ihn ein eigens geschnittener Folge-Slice plus dieser Registereintrag, also
zwei Behelfe statt einer Form.
