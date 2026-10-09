**Stand:** verkörpert — die Regel (die Fall-Anlage misst ihr sed-Muster gegen
den Quell-Bestand, nicht gegen die Fassung der letzten Fassung) liegt in
[`harness/conventions/MR-071-die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand.md`](../../../../../../harness/conventions/MR-071-die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand.md)
— seit slice-fall-anlage-misst-gegen-den-quell-bestand. Zählerstand 8×
(`ls docs/plan/planning/observations/BEO-ALL/mutations-fall-wird-von-berechtigter-aenderung-entwaffnet/evidence/*.md | wc -l`,
gelesen 2026-10-09, keine Erwartung), der 3×-Übertritt ist unverändert mit dem Beleg
`evidence/slice-stumme-mutations-faelle-folgen-der-config-form.md` erreicht. Vorkommen seit der
Verkörperung: `slice-fall-406-trifft-die-umgebaute-zerlegung`,
`2026-10-08-mutations-anker-29-247-review` und `slice-mutations-anker-greift-in-den-gates`.
Die Auflösungs-Trigger von
[`MR-071`](../../../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)
sind entschieden in
[`MR-090`](../../../../../../harness/conventions.md#mr-090): Trigger 1 eingetreten, die Regel
bleibt; Trigger 3 ist mit dem Sensor beantwortet.

**Sensor:** [`make mutate-greift`](../../../../../../harness/sensors/mutate.md) in `make gates`
meldet einen Anker, der nicht mehr trifft, am Commit
([`MR-090`](../../../../../../harness/conventions.md#mr-090)); das nächtliche `make mutate` meldet
dahinter, ob der Wächter rot wird.
