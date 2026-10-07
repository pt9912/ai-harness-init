# MR-081 — Der Cache-Status ist Pflicht mit Kennzeichnung *nicht bekannt*, seine Abweichung entfällt

- **Datum:** 2026-10-07
- **Wirksamkeits-Anlass:** slice-span-pflichtfeld-traegt-nicht-bekannt;
  [`ADR-0078`](../../docs/plan/adr/0078-ziel-fassung-regiert-den-sprung-v6160.md) Festlegung 4 Punkt 2.
- **Geltungsbereich:** [`MR-076`](../conventions.md#mr-076) vollständig.
- **Ersetzt-Baseline-Regel:** keine. Dieser Eintrag setzt **keine** Abweichung, er baut eine
  zurück; die Baseline-Regel, an deren Stelle [`MR-076`](../conventions.md#mr-076) trat, gilt
  wieder unverändert.
- **Löst auf:** [`MR-076`](../conventions.md#mr-076) vollständig.
- **Ausgelöst durch Baseline-Stand:** `v6.14.0` (Kurs-Welle 154), adoptiert mit `v6.16.0`.
- **Adaption:** Der Cache-Status folgt dem Pflicht-Minimum aus
  [`modul-15-observability.md`](../../.harness/baseline/v6.17.0/regelwerk/modul-15-observability.md#span-audit-attribut-regeln)
  §Span-/Audit-Attribut-Regeln: [`spec/spezifikation.md`](../../spec/spezifikation.md#5-metriken-und-tracing-felder)
  §5 führt `SPEC-024` als `Pflicht`, und liefert die Quelle die Zähler nicht, trägt das Feld die
  Kennzeichnung *nicht bekannt* samt Quelle (`SPEC-087`). Eine Abweichung, die ein Eintrag tragen
  müsste, besteht nicht mehr
  (`grep -c "SPEC-024.*| Pflicht |" spec/spezifikation.md` → **1**).
- **Begründung:** Seit `v6.14.0` sagt das Modul selbst: *„Liefert deine Quelle den Wert nicht,
  ist das keine Abweichung: Das Pflicht-Feld bleibt Pflicht und ist ausdrücklich als nicht bekannt
  gekennzeichnet … unter Nennung der Quelle, die es nicht liefert."* Damit ist der zweite
  Auflösungs-Trigger von [`MR-076`](../conventions.md#mr-076) in der Sache eingetreten — die
  Payload-Lage, die `Optional` begründete, erzwingt keine Abweichung mehr. Zurückgenommen ist die
  Wahl erst mit der Umstellung von `SPEC-024`, nicht mit dem Vendoring
  ([`ADR-0078`](../../docs/plan/adr/0078-ziel-fassung-regiert-den-sprung-v6160.md) Festlegung 4).
  Der Ausschluss des Transkripts bleibt bestehen; er steht als `SPEC-055` in der Spezifikation,
  nicht in diesem Block.
- **Auflösungs-Trigger:** permanent als Sachstands-Feststellung; neu zu prüfen erst, wenn ein
  künftiger Baseline-Stand die Kennzeichnung *nicht bekannt* aus dem Modul streicht.
