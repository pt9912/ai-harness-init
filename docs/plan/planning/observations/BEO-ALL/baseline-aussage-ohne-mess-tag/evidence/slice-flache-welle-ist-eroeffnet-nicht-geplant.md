**Vorgang:** slice-flache-welle-ist-eroeffnet-nicht-geplant
**Fund:** Runde 1, F-5 (INFO). `docs/plan/planning/README.md` behauptete in §Slices vs. Wellen
*„trägt ihren Status seit Regelwerk v3.5.0"*. Der vendored Baum führt genau **einen** Tag; die
Aussage war netzlos an keiner Stelle nachzumessen und nannte keinen Stand, an dem nachgesehen
wurde — die Klasse, für die
[`MR-033`](../../../../../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
Setzung 1 den Mess-Tag verlangt.

**Die Instanz ist beiläufig entfallen**, nicht die Klasse: Der Satz stand in der Hälfte desselben
Bullets, die der Nachzug ersetzt hat (`grep -c 'v3\.5\.0' docs/plan/planning/README.md` → 0, Exit
1 — kein Erwartungswert). Gezählt wird das Auftreten, nicht der Rest: Kein Schritt des Vorgangs
hat die Aussage als Baseline-Behauptung ohne Tag **erkannt** und darum entfernt; sie fiel mit dem
Absatz.
