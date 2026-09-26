**Vorgang:** slice-mutate-fall-filter-und-die-belegform-vereinigung
**Fund:** Die Regel *„Zwei Läufe, eine Aussage"* in `harness/sensors/mutate.md` verlangte als Bedingung 1, dass beide
Läufe denselben `mutate: Pruefgegenstand <hash>` nennen. Nur ein Teillauf druckte die Zeile; ein voller Lauf, der mit
Befund endet — der Hauptlauf im Anlass der Regel —, druckte keinen Schlüssel (Review R-1, MEDIUM,
`docs/reviews/2026-09-26-slice-mutate-fall-filter-und-die-belegform-vereinigung.md`). Gelöst durch das Werkzeug: `report_key`
im Zweig des vollen Laufs; der Verifier maß die Zeile in einem vollen Lauf **mit** Befund und in einem grünen
(bats-Tests 67 und 68) und sah die Schwächungen *„nur bei grün"*, *„nur bei Befund"* und *„gestrichen"* rot
(`docs/reviews/2026-09-26-verify-slice-mutate-fall-filter-und-die-belegform-vereinigung.md`).
