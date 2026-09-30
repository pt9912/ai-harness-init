# MR-076 — Cache-Status ist Optional statt Pflicht, weil die Payload die Zähler nicht für jeden Lauf liefert

- **Datum:** 2026-09-30
- **Wirksamkeits-Anlass:** [`ADR-0074`](../../docs/plan/adr/0074-spec-5-fliesstext-klassen-ort-und-lh-bezug-spalte.md)
  Festlegung 3 (Abweichung 1 ist eine echte Abweichung) und Folgepflicht 2.
- **Geltungsbereich:** [`spec/spezifikation.md`](../../spec/spezifikation.md#5-metriken-und-tracing-felder)
  §5, Zeile `SPEC-024` (`cache_creation_input_tokens`, `cache_read_input_tokens`, `Optional`) —
  die **Festlegung** bleibt Tabellenzeile dort; diese Datei trägt die Abweichung und ihre
  Begründung. **Nicht** die Verbrauchs-Achse des Hintergrund-Laufs und des Haupt-Kontexts: sie
  sind keine Abweichung ([`ADR-0074`](../../docs/plan/adr/0074-spec-5-fliesstext-klassen-ort-und-lh-bezug-spalte.md)
  Festlegung 3, Abweichungen 5 und 6) und stehen als Zeilen der Spezifikation.
- **Ersetzt-Baseline-Regel:**
  [`modul-15-observability.md`](../../.harness/baseline/v6.13.0/regelwerk/modul-15-observability.md#span-audit-attribut-regeln)
  §Span-/Audit-Attribut-Regeln, Punkt *Audit-Span-Schema* — *„Pflicht-Minimum: Slice-ID,
  Agent-Rolle, Cache-Status, `requirement.id` — jede Abweichung davon begründest du."*
- **Adaption:** Der Cache-Status steht in der Spezifikation als **Optional**, nicht als Pflicht:
  die beiden Zähler `cache_creation_input_tokens` und `cache_read_input_tokens` erscheinen im Span
  nur, wo die Payload sie trägt. Erfasst werden sie aus dem `usage`-Objekt der `tool_response` eines
  Vordergrund-`Agent`-Aufrufs, ohne Transkript und ohne Zugriff außerhalb des Repos; die Erfassung
  nimmt sie, sobald sie ankommen.
- **Begründung:** Der Grund liegt in der Payload, nicht im Schema: die Antwort, aus der die Zähler
  stammen, entsteht für einen Vordergrund-Lauf nicht mehr, der Hintergrund-Lauf und der
  Haupt-Kontext liefern die Verbrauchs-Achse von vornherein nicht. Ein Pflichtfeld, das für diese
  Läufe leer bliebe, behauptete eine Erfassung, die es nicht gibt; `Optional` sagt, was die Quelle
  hergibt. **Der Ausweg über das Transkript ist ausgeschlossen:** es liegt außerhalb des Repos,
  in fremdem Besitz, und trägt den vollen Gesprächsinhalt; ein Zeiger darauf legte eine Auflösung
  nahe, die niemand genehmigt hat, und der `transcript_path` wird deshalb weder erfasst noch
  gelesen. **Was eine Cache-Hit-Rate-Auswertung damit nicht bekommt:** die Zähler, getrennt nach
  Erzeugung und Lesung, wie das Modul es fordert, und ihre Labels — das Rollen-Label liegt nur
  vor, wo `spawned_role` gefüllt ist; ein Lauf ohne Rolle gehört in den Sammelposten.
  **Grenze:** kein Sensor hält, dass der Feldstatus `Optional` der Payload-Lage folgt; der Eintrag
  sagt nichts über die Zukunft der Payload.
- **Auflösungs-Trigger:** die Payload liefert die Cache-Zähler wieder für jede Lauf-Art, in der
  eine Rolle Verbrauch erzeugt — dann wird das Feld `Pflicht`, und der Eintrag entfällt — oder das
  Modul streicht den Cache-Status aus seinem Pflicht-Minimum.
