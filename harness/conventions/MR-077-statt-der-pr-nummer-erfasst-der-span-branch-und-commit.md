# MR-077 — Statt der PR-Nummer erfasst der Span branch und commit

- **Datum:** 2026-09-30
- **Wirksamkeits-Anlass:** [`ADR-0074`](../../docs/plan/adr/0074-spec-5-fliesstext-klassen-ort-und-lh-bezug-spalte.md)
  Festlegung 3 (Abweichung 2 ist eine echte Abweichung) und Folgepflicht 2.
- **Geltungsbereich:** [`spec/spezifikation.md`](../../spec/spezifikation.md#5-metriken-und-tracing-felder)
  §5, Zeile `SPEC-014` (`branch`, `commit`, `Pflicht`) — die **Festlegung** bleibt Tabellenzeile
  dort; diese Datei trägt die Abweichung und ihre Begründung. **Nicht** die Frage, ob `SPEC-014`
  einen Anker im Lastenheft trägt: sie gehört zur Spalte
  ([`MR-075`](../conventions.md#mr-075--die-spalte-präzisiert-bindet-jede-festlegung-der-spezifikation-an-ihr-lastenheft-element)).
- **Ersetzt-Baseline-Regel:**
  [`modul-15-observability.md`](../../.harness/baseline/v6.13.0/regelwerk/modul-15-observability.md#span-audit-attribut-regeln)
  §Span-/Audit-Attribut-Regeln, Punkt *Mindestfelder eines Tool-Call-Spans* — *„`tool.name`,
  `tool.arguments` (redacted), `tool.result.status` plus Korrelations-IDs zu Slice/PR/Agent-Rolle."*
- **Adaption:** Das Schema führt keine PR-Angabe. An ihrer Stelle erfasst der Span `branch` und
  `commit`, abgeleitet aus `.git/HEAD`; beide sind `Pflicht`. Ist die Ableitung nicht möglich,
  stehen sie leer da statt zu fehlen — „unbekannt" ist von „nicht vorhanden" unterscheidbar. Ein
  `.git` als Datei (Worktree, Submodul) wird nicht aufgelöst; dann sind beide Felder leer und als
  leer erkennbar.
- **Begründung:** Eine PR-Nummer lebt bei der Forge. Der Emitter läuft je Tool-Call, geht nicht ins
  Netz und ruft kein `gh`; `branch` und `commit` sind die Größen, über die eine Auswertung den PR
  nachschlägt. **Das ist eine Ableitung, keine Erfüllung:** liegt zum Branch kein PR vor, bleibt die
  Frage offen. **Grenze:** kein Sensor hält, dass `branch` und `commit` tatsächlich zu einem PR
  führen; die Zusage endet an der Ableitung.
- **Auflösungs-Trigger:** der Emitter bekommt eine PR-Angabe ohne Netz-Zugriff je Tool-Call, oder
  das Modul streicht die PR-Korrelation aus den Mindestfeldern.
