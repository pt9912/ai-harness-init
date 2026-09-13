**Vorgang:** slice-225
**Fund:** Zwei Messungen dieses Slice bewegten ihre eigene Bezugsmenge, und beide standen im
Moment ihres Schreibens falsch da.

**Erstens im Adaptions-Block.** `MR-057` beziffert im Feld `Löst auf`, wie oft das abgelöste Token
in seinem Vorgänger vorkommt:

```sh
grep -c 'slice-NNN' harness/conventions/MR-000-baseline-aussage.md   # 2
git show 3c2b4d82^:harness/conventions/MR-000-baseline-aussage.md | grep -c 'slice-NNN'   # 1
```

Der geschriebene Betrag `1` galt für den Stand **vor** dem Commit. Derselbe Commit setzte die
Kopf-Marke auf `MR-000`, und die zitiert das gesuchte Token in ihrer eigenen Reichweiten-Angabe —
der Betrag war in keinem Moment nach seinem Schreiben richtig.

**Zweitens in der Retirement-Kandidatenmenge.** Sie stand im Plan bei 21, im Review bei 23, beim
Verifier bei 24; alle drei waren zu ihrem Zeitpunkt richtig. Der Slice erzeugt mit `MR-057` und
`MR-058` **zwei seiner eigenen Kandidaten** — die Bezugsmenge wächst, während die Zahl über sie
geschrieben wird.

Die Klasse ist damit nicht mehr auf Slice-Pläne beschränkt: Die drei früher gebuchten Belege
treffen Zusagen in Plandateien, dieser trifft den Adaptions-Block und eine Closure-Zahl. Der
Ausweg ist in beiden Fällen derselbe und steht seit diesem Slice als Form da
([`MR-058`](../../../../../../../harness/conventions.md#mr-058--eine-messung-die-ihr-eigener-vorgang-bewegt-wird-nach-dem-vorgang-genommen)
Setzung 2): Die Messung wird **nach** dem Vorgang genommen, oder an ihrer Stelle steht die
Eigenschaft statt des Betrags. Der Zusatz *kein Erwartungswert* trägt den Fall nicht — er deckt
Drift **nach** dem Schreiben, nicht einen Betrag, den der eigene Commit falsch macht.
