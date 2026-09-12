**Vorgang:** slice-219
**Fund:** Der Slice änderte die Ableitung — die Vorprüfung hebt unter dem Schlüssel `altbestand`
vier Ausgänge auf — und ließ die Zusage daneben unverändert stehen. Sie steht in
[`harness/sensors/archive-welle.md`](../../../../../../../harness/sensors/archive-welle.md) und
sagt, die Vorschau sei *„die Vorprüfung des schreibenden Laufs, und was sie an Sperren nennt, sind
genau die Ausgänge, an denen er abbricht"*. Für diesen Schlüssel gilt das seit dem
Umsetzungs-Commit nicht mehr: `Anwenden` in
[`internal/archive/anwenden.go`](../../../../../../../internal/archive/anwenden.go) beginnt mit
`if len(b.Plaene) != 1`, und `Einsammeln` liefert für einen Schlüssel ohne Welle-Plan null Pläne.
Fiele die letzte verbliebene Sperre, druckte der Lauf *„Sperren: keine — der schreibende Lauf
liefe"* und bräche dennoch ab.

Die Zusage war vor diesem Slice wahr und ist durch ihn falsch geworden, ohne dass ein Zeichen an
ihr sich bewegte — dieselbe Richtung wie in den übrigen Belegen dieses Eintrags. Kein Sensor
erreicht sie: Ein Doku-Absatz über das Verhalten einer Funktion ist kein Anker, und die Module aus
`modules:` der [`.d-check.yml`](../../../../../../../.d-check.yml) urteilen über Referenzen, nicht
über Wahrheitsgehalt. Die Zusage ist mit der Nacharbeit auf das eingeschränkt, was der Code hält
(§Grenze Punkt 7 derselben Datei, dazu ein `ABGRENZUNG`-Block in
[`internal/archive/vorschau.go`](../../../../../../../internal/archive/vorschau.go)); die Lücke
selbst hat ihre Adresse in slice-220 bekommen.
