# MR-021 — Das Span-Schema zieht ins Technik-Stratum, sein Eintrag wird aufgehoben

> **ÜBERHOLT: Punkt 2 der Liste „Was als Delta bleibt" → [`MR-030`](../conventions.md#mr-030--der-rollen-name-der-baseline-und-der-bezeichner-fallen-zusammen).** Die übrigen Setzungen dieses Eintrags gelten fort.

> **ÜBERHOLT: die Spaltenzahl in Punkt 1 der Liste „Was als Delta bleibt" → [`MR-044`](../conventions.md#mr-044--das-technik-stratum-trägt-die-id-spalte-der-ziel-form).** Die Setzung selbst — die `Sensor`-Spalte ist eine Abweichung von der Vorlagen-Form — gilt fort.

- **Datum:** 2026-08-02
- **Geltungsbereich:** [`MR-018`](../conventions.md#mr-018--span-schema-der-telemetrie-erfassung) sowie die
  Abschnitte [3](../../spec/spezifikation.md#3-defaults-und-konstanten) und
  [5](../../spec/spezifikation.md#5-metriken-und-tracing-felder) von
  [`spec/spezifikation.md`](../../spec/spezifikation.md).
- **Ersetzt-Baseline-Regel:**
  [`modul-15-observability.md`](../../.harness/baseline/v5.18.0/regelwerk/modul-15-observability.md#span-audit-attribut-regeln)
  §Span-/Audit-Attribut-Regeln — die Form des Audit-Span-Schemas: *„liste jeden Attribut-Namen,
  markiere ihn als Pflicht oder Optional und nenne pro Attribut die Incident-Frage, die es
  beantwortet"*, also drei Spalten. An ihre Stelle tritt die vierte Spalte `Sensor` in
  [`spec/spezifikation.md`](../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5 — Punkt 1
  der Liste *Was als Delta bleibt* unten; Punkt 2 derselben Liste ist mit
  [`MR-030`](../conventions.md#mr-030--der-rollen-name-der-baseline-und-der-bezeichner-fallen-zusammen) fort.
  **Der Umzug selbst ersetzt nichts:** dass eine fortschreibbare technische Festlegung ins
  Technik-Stratum gehört, ist Baseline-Default
  ([`modul-03-spec.md`](../../.harness/baseline/v5.18.0/regelwerk/modul-03-spec.md#ziel-form-spezifikation)),
  und die Aufhebung von [`MR-018`](../conventions.md#mr-018--span-schema-der-telemetrie-erfassung) folgt der Form
  aus [`MR-020`](../conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf). Gemessen am
  adoptierten Stand `v5.12.0`.
- **Adaption:** [`MR-018`](../conventions.md#mr-018--span-schema-der-telemetrie-erfassung) wird **vollständig
  aufgehoben.** Kein Satz seines Rumpfs bindet noch von dort. Er behält Nummer, Überschrift
  **wörtlich** (sie ist der Anker), das `Datum` und eine Zeiger-Zeile; den Rumpf trägt `git`
  ([`MR-020`](../conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf), Bedingungen und
  Abwägung in [`ADR-0014`](../../docs/plan/adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md)).
  Zielort je Posten-Art — der Zielort des ersten und zweiten ist die Setzung aus
  [`ADR-0013`](../../docs/plan/adr/0013-technik-stratum-als-zielort.md) Festlegung 1:
  - **technische Festlegung, die mit ihrem Gegenstand wächst** (Feldtabelle, Werkzeug-Liste,
    Positiv-Liste, Start-Konvention, erfasste Menge, Strom-Identität, die sechs erklärten
    Abweichungen, die Wächter-Bindungen) → [`spec/spezifikation.md`](../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5;
  - **Wert, der als Schranke fest ist** (Länge und Zeichensatz von `model_version`) →
    [§3](../../spec/spezifikation.md#3-defaults-und-konstanten);
  - **Inhalt des Regelwerks, nacherzählt** → ein auflösender Link ins Modul, im umgezogenen Text
    durchgehend gesetzt;
  - **datierte Messung** (Messreihen, Gegenproben, rot-gesehen-Nachweise) →
    `docs/reviews/2026-08-02-span-schema-messreihen.md`, der etablierte Ort für Zeitdokumente;
  - **Prozess-Zustand** (wer trägt was, was ist offen) → der Plan, der ihn führt — nicht dieser
    Block;
  - **Abweichung von der adoptierten Baseline** → dieser Eintrag, nächster Punkt.
- **Was als Delta bleibt, und damit den Gegenstand dieses Blocks trifft — zwei Posten:**
  1. **Die Sensor-Spalte ist eine dritte Abweichung von der Vorlagen-Form.** §5 trägt jetzt vier
     Spalten (Feld · Pflicht · Incident-Frage · **Sensor**) statt der drei, die
     [`modul-15-observability.md`](../../.harness/baseline/v5.18.0/regelwerk/modul-15-observability.md#span-audit-attribut-regeln)
     vorschreibt. Grund: eine Zusicherung ohne benannten Wächter ist nach
     [`AGENTS.md`](../../AGENTS.md) §3.6 unbelegt, und die Bindung wächst mit ihrem Gegenstand wie
     die Zeile selbst. [`MR-019`](../conventions.md#mr-019--technik-stratum-als-rang-2-der-source-precedence) zählt
     für das Stratum *„zwei Abweichungen von der Vorlagen-Form"*; jener Eintrag wird dafür nicht
     angefasst, seine Zahl ist überholt.
  2. **`implementer` statt *Implementation*.**
     [`modul-08-agentenrollen.md`](../../.harness/baseline/v3.5.2/regelwerk/modul-08-agentenrollen.md#rollen-sequenz-für-einen-slice)
     nennt die dritte Rolle *Implementation*; als **Bezeichner** der Agenten-Typen gilt hier
     `implementer` — kurz und gleichförmig mit den übrigen fünf. Die Abweichung ist eine
     Schreibweise, keine Rollen-Änderung. Der **Wert** steht im Stratum, weil er eine technische
     Festlegung ist; dass er von der Modul-Schreibweise abweicht, steht hier.
- **Sensor, und seine Grenze (gemessen 2026-08-02).** Die Sensor-Spalte hat **einen Namen und
  keinen Sensor.** `codepaths.roots` in `.d-check.yml` sind `[spec, docs, harness]`; `test/` steht
  dort nicht. Fünf Sonden in **einer** Datei einer isolierten Kopie, je ein `make docs-check`
  (gepinntes Image, `--network none`, ohne Sonden 281 Datei(en) / 0 Befund(e)): ein nicht
  existierender Pfad unter `test/` bleibt **still**, derselbe Fehler unter `harness/` meldet
  `codepath-missing`; eine Zeilen-Referenz `…:9000-9001` unter `test/` bleibt **still**, dieselbe
  Form auf `harness/tools/mutate.sh` meldet `citation-out-of-range`. Kein Gate prüft also, ob ein
  in der Spalte genannter Fall noch existiert oder noch so heißt — `make mutate` fährt nur die
  Dateien, die es findet, und `make comment-claims` lässt jede Markdown-Datei außen vor. Die
  Spalte ist Feedforward; ihre Alterung fängt niemand mechanisch. Diesen Rest trägt der Mensch.
- **Was ersatzlos entfällt, je mit Grund.** Vier bindende Posten und zwei Klassen:
  1. Die **Zielort-Setzung** *„die Feldtabelle gehört hierher"* — genau sie ist teil-revidiert;
     ihre Begründung (*„sie wächst mit jedem Feld"*) ist die Aufnahme-Regel des Zielorts und steht
     dort.
  2. Das **Verdikt *permanent*** zur Abweichung *Haupt-Kontext ohne Zahl* samt seinem Trichter:
     der Posten ist in [`ADR-0012`](../../docs/plan/adr/0012-haupt-kontext-ohne-token-bilanz.md)
     übergeführt, und die trägt Verdikt, Begründung und Re-Evaluierung. Ein zweiter Ort driftet.
  3. Die **Tooling-Klarstellung** *„drei Zeilen der Fitness Function nennen `bats`, umgesetzt sind
     sie als Go-Tests"*: beide Hälften stehen andernorts bindend — dass `make test` `test-bats`
     **und** `test-go` fährt, sagt die Gate-Tabelle in [`AGENTS.md`](../../AGENTS.md) §4; **wo** die
     Wächter liegen, sagt die Sensor-Spalte namentlich.
  4. Die **zugesagte Sonde auf die Schlüsselnamen von `tool_input`**: sie trennt die zwei offenen
     Lesarten in keinem Zweig, und ihren Gegenstand trägt ein Plan. Sie wird deshalb nicht
     richtiggestellt, sondern entfällt.
  5. **Entstehungs-Erzählung** — Befund-Herkunft, *„bis <Datum> stand hier …"*, *„frühere
     Fassung"*, *„Vorgänger"*: das Artefakt beschreibt seinen Gegenstand, nicht seine eigene
     Entstehung; die Fassungen trägt `git`.
  6. **Prozess-Zustand** — welcher Slice was trägt, welcher Trigger auf welchen Slice wartet: er
     gehört in den Plan, der ihn führt, und ein Eintrag dieses Blocks ist kein Entscheidungs-Ort
     für offene Arbeit.
- **Begründung.** Der Adaptions-Block registriert Abweichungen von der adoptierten Baseline. Die
  Feldtabelle weicht von nichts ab; sie *ist* die Festlegung — und sie lag damit in einem
  Dokument, das in keiner der beiden Precedence-Listen des Repos steht. Das Gefäß dafür existiert
  seit [`MR-019`](../conventions.md#mr-019--technik-stratum-als-rang-2-der-source-precedence). Mit diesem Eintrag
  hat der Block seinen Gegenstand zurück: was hier bleibt, sind zwei Deltas gegenüber Regelwerk
  und Vorlage, und die passen in zwei Absätze.
- **Auflösungs-Trigger:** permanent. Fiele die Setzung, dass das Technik-Stratum der Zielort ist,
  wäre nicht dieser Eintrag nachzubessern, sondern jene Entscheidung abzulösen.
