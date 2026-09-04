# MR-001 — Doc-Gate-Schärfung (matrix + Link-Pflicht + Anker-IDs)

> **ÜBERHOLT: die Zensus-Aussage zu `scan.ignore` samt ihrer Klassifikation → [`MR-029`](../conventions.md#mr-029--der-scanignore-zensus-wandert-und-sein-dritter-grund-ist-keine-scoping-aussage).** Die übrigen Setzungen dieses Eintrags gelten fort.

- **Datum:** 2026-06-13
- **Geltungsbereich:** `.d-check.yml` (Doc-Referenz-Gate)
- **Ersetzt-Baseline-Regel:**
  [`grundlagen-referenz-richtung.md`](../../.harness/baseline/v6.0.0/regelwerk/grundlagen-referenz-richtung.md#referenz-richtung-sdp-wer-darf-wen-referenzieren)
  §Referenz-Richtung (SDP) — die **Sektions-Ausnahme über den Spec-Straten**: *„ein Spec-Stratum
  (`lastenheft.md`, `spezifikation.md`, `architecture.md`) enthält `ADR-` oder `slice-` → fail,
  **ohne ausgenommene Sektion**"*, und dazu *„Die ausgenommene Überschrift … gibt es nur auf der
  **Planungs-Ebene**. Über den Spec-Straten läuft der Check über das ganze Dokument."* An ihre
  Stelle tritt `matrix.exclude-sections: [Historie, "7. Historie", Geschichte]` — der Schlüssel
  liegt neben `classes` und `rules`, also über allen Klassen und damit auch über `spec-straten`.
  **Die übrigen Setzungen dieses Eintrags ersetzen nichts** und stehen deshalb nicht im Feld:
  Modul-Aktivierung und `link-policy: always` sind die Reifestufe, die derselbe Abschnitt am
  adoptierten Stand `v5.12.0` ausdrücklich vorsieht (*„die anker-validierende Stufe ist eine
  Reifestufe darüber, kein Startwert"*), und das Wachsen mit den Artefakten schreibt das vendored
  Startgerüst `.harness/baseline/v5.12.0/templates/.d-check.yml` selbst vor.
- **Adaption:** Über die Baseline-Module (`links`, `anchors`, `ids`,
  `codepaths`) hinaus aktiviert: `matrix` (mechanische Referenz-Richtung/SDP —
  Spec-Straten verweisen nie abwärts auf ADR/Slice; Verweise auf
  superseded/deprecated ADRs verboten; `exclude-sections` für
  Historie/Geschichte), `spans` (Markdown-Span-Hygiene) sowie `ids` mit
  `link-policy: always` (Kennungen sind klickbare Links zur Quelle, Requirement-IDs
  mit Abschnitts-Anker; `exempt-paths`: `docs/reviews/**`, `CHANGELOG.md`) plus
  ein `MR`-Pattern (→ diese Datei). **`scan.ignore` führt heute vier Einträge, aus zwei
  Gründen** — beide sind **Scoping**, keine Gate-Lockerung nach
  [`AGENTS.md`](../../AGENTS.md) §3.5, denn der Prüfumfang schrumpft nicht um Bestand, den dieses
  Repo autoritativ schreibt:
  1. **Vendored Fremd-Dokumente** — dieses Repo *spiegelt* sie, statt sie zu schreiben, und darf
     sie deshalb nicht nach seinen Regeln formen: `.harness/baseline/**`
     ([`MR-007`](../conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)) und
     `docs/user/claude-hooks-referenz.md` (die Hooks-Referenz der Herstellerseite, netzlose
     Quelle der Payload-Messungen). Sie umzuschreiben, damit das Gate grün wird, hieße die Quelle
     zu verfälschen; sie zu scannen erzeugt Befunde gegen ihren Autor.
  2. **Kein Fließtext** — `**/*.template.md` sind Ziel-Form-Vorlagen mit Platzhaltern statt
     Verweisen, `.tmp/**` ist Wegwerf-Bestand. Beide tragen keine Aussage, die veralten könnte.
- **Begründung:** Halb-erzwungene ID-Klammer und unbewachte Referenz-Richtung
  geschlossen; „klickbar zur Quelle" als gemessenes Property. Gate-*Anheben* →
  Steering-Loop, kein ADR nötig. Legitime ADR-Supersede-Lineage über Inline-Code
  + `d-check:ignore` (deckt `ids`, nicht `matrix`).
- **Auflösungs-Trigger:** permanent; `codepaths.roots` wachsen mit
  `tools`/`cmd`/`internal` in Phase 2/3.
