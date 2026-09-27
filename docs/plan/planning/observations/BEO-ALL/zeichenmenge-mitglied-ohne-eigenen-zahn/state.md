**Stand:** offen

Unterhalb der Schwelle (2×,
`ls docs/plan/planning/observations/BEO-ALL/zeichenmenge-mitglied-ohne-eigenen-zahn/evidence/*.md | wc -l`,
gelesen 2026-09-27, keine Erwartung); `offen` ist hier der Normalzustand und kein Ausgang. Ein Wächter besteht nicht:
`make mutate` fährt die gelisteten Fälle, und ein Mitglied einer Menge ist
kein Fall. Träger ist das Review, das die Menge Mitglied für Mitglied gegen den Test hält.

**Stand je Menge — zwei Mengen des ersten Vorgangs, verschiedene Zusagen.** Beleg: Gegenprobe-Bericht des Verifiers,
`docs/reviews/2026-09-24-slice-program-feld-nennt-weder-operator-noch-wertfragment-gegenprobe.md`,
Abschnitt *F-3*, und Review Runde 2 (`docs/reviews/2026-09-24-slice-program-feld-nennt-weder-operator-noch-wertfragment-runde-2.md`, F-7).

- `unsureValueChars` (`internal/span/span.go`, Rand eines Zuweisungs-Werts): jedes Zeichen der
  Konstante hat in `TestCommandProgramWithholdsProgramForEachUnsureValueChar` einen eigenen Zahn.
  Gegengeprobt sind alle bis auf `"` und `\`; `<` und `>` sind dort **keine** äquivalenten Mutanten
  (nur dieser Test färbt sich rot).
- `shellMetaStart` (`internal/span/span.go`, Anfang eines Worts nach einer Zuweisung): `&` und `)`
  haben keinen eigenen Zahn (die volle Suite bleibt grün), `<` und `>` sind äquivalente Mutanten,
  weil die Ziffernregel in `namesProgram` dieselben Wörter deckt.

Die Aussage *„`<` und `>` sind äquivalente Mutanten"* gilt allein für `shellMetaStart`; für
`unsureValueChars` gilt das Gegenteil. Die Evidence-Datei des Vorgangs nennt sie im Satz über
`shellMetaStart` und ist für diese Menge richtig.

**Zwei weitere Mengen im zweiten Vorgang** (`slice-204-das-programm-feld-nennt-das-programm`): die Operator-Guards in
`skipNavigation` und die Whitelist der schlichten Zeichen in `internal/span/span.go`. Beide sind je Mitglied gebunden — die
Whitelist durch den Sweep über alle Zeichen ab 0 und die Fälle 486 und 487, gefahren mit 45 Erweiterungen und 18 Verkürzungen —,
und die Liste in `SPEC-031` hält kein Sensor gegen den Code (siehe `zusage-nennt-sensor-der-form-nicht-sieht`).
