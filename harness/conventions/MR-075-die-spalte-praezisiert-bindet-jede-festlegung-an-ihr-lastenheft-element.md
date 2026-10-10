# MR-075 — Die Spalte Präzisiert bindet jede Festlegung der Spezifikation an ihr Lastenheft-Element

- **Datum:** 2026-09-30
- **Wirksamkeits-Anlass:** [`ADR-0074`](../../docs/plan/adr/0074-spec-5-fliesstext-klassen-ort-und-lh-bezug-spalte.md)
  Festlegung 5 und Folgepflicht 2 — die ADR verlangt diesen Eintrag **vor** dem Schritt, der die
  Spalte in die Spezifikation schreibt.
- **Geltungsbereich:** die Tabellen von Festlegungen in
  [`spec/spezifikation.md`](../../spec/spezifikation.md): die Tabelle von
  [§3](../../spec/spezifikation.md#3-defaults-und-konstanten), die Feld- und die Werkzeug-Tabelle von
  [§5](../../spec/spezifikation.md#5-metriken-und-tracing-felder) und jede künftige Tabelle von
  Festlegungen, die eine `SPEC-<NNN>` je Zeile trägt. **Nicht** die Kopfzeile der Feldtabelle bis
  einschließlich der Spalte `Sensor` (Festlegung 8 derselben ADR hält sie unverändert, damit der
  Existenz-Abgleich sie weiter liest); **nicht** die emittierte Vorlage im Emit-Baum
  ([`ADR-0074`](../../docs/plan/adr/0074-spec-5-fliesstext-klassen-ort-und-lh-bezug-spalte.md)
  Festlegung 9); **nicht** die Spalte `Sensor` selbst — deren Abweichung führt
  [`MR-021`](../conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben)
  Punkt 1 fort.
- **Ersetzt-Baseline-Regel:**
  [`modul-03-spec.md`](../../.harness/baseline/v6.18.0/regelwerk/modul-03-spec.md#ziel-form-spezifikation)
  §Ziel-Form: Spezifikation — *„Technische Festlegungen leben in der Spezifikation
  (`templates/spec/spezifikation.template.md`)"*: die Vorlage führt in §3
  `ID · Name · Wert · Begründung` und in §5 `ID · Span · Pflicht-Attribute · Quelle`, jeweils ohne
  Spalte für die Bindung an das Lastenheft
  (`grep -n '^| ID | Name | Wert | Begründung |\|^| ID | Span | Pflicht-Attribute | Quelle |' .harness/baseline/v6.18.0/templates/spec/spezifikation.template.md`
  nennt beide Kopfzeilen). Genannt ist die Form, an deren Stelle die zusätzliche Spalte tritt; die
  Regel *„Präzisieren, nie erweitern"* derselben Sektion bindet unverändert fort.
- **Adaption:** Jede der genannten Tabellen trägt als **letzte** Spalte `Präzisiert`. Ihr Wert ist ein
  Anker-Link auf das Lastenheft-Element, das die Zeile präzisiert (spec-relativ, Linktext die
  Kennung, Anker der Slug der Lastenheft-Überschrift); trägt kein Element die Zeile, steht `Lücke`.
  Die Spalte kommt hinten, damit Spalte 1 bis zur Spalte `Sensor` der Feldtabelle unverändert
  bleiben. Der Wortlaut der Spalte im Einzelnen (Wert, Ebenen-Test, Übergangswert `Lücke`) steht in
  [`ADR-0074`](../../docs/plan/adr/0074-spec-5-fliesstext-klassen-ort-und-lh-bezug-spalte.md)
  Festlegung 5; er wird hier nicht wiederholt.
  **Überholt wird, was an Zahl und Reichweite von Spalten gesagt ist:**
  [`MR-044`](../conventions.md#mr-044--das-technik-stratum-trägt-die-id-spalte-der-ziel-form) zählt
  die Spalten von §5 und nennt allein `Sensor` als abweichend — mit `Präzisiert` weicht eine
  zweite Spalte ab, und die Zählung verschiebt sich um eine. Beide Einträge tragen dafür eine
  Kopf-Marke ([`MR-032`](../conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)),
  ihr Rumpf bleibt wörtlich.
- **Begründung:** Die Spezifikation präzisiert das Lastenheft und erweitert es nie; ohne benannten
  Anker je Zeile ist das eine Behauptung des Kopfes, keine Eigenschaft der Zeile. Die Spalte macht
  die Bindung je Festlegung lesbar und die Zeile ohne Träger als `Lücke` sichtbar, statt sie
  stillschweigend als Präzisierung mitzuführen. **Ein Anker-Link statt Freitext**, weil die
  link-policy des Doku-Gates einen auflösenden Verweis verlangt und ein Kriterium **im** Element
  keinen Anker hat und in der Zelle ohne Sensor altern würde.
  **Grenze:** `anchors` prüft, dass der Anker auflöst, nicht, dass er das **richtige** Element
  nennt; eine leere Zelle meldet kein bekannter Sensor. Träger ist der Lauf, der die Spalte
  schreibt, und die Review seines Schritts — ein Gate hält es nicht
  (`grep -n '^modules:' .d-check.yml`).
- **Auflösungs-Trigger:** permanent, solange die Vorlage die Bindung an das Lastenheft nicht in
  einer Spalte führt. Nimmt eine künftige Fassung der Vorlage eine solche Spalte auf, ist nicht
  dieser Eintrag nachzubessern, sondern die Abweichung neu zu zählen.
