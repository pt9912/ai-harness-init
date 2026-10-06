# Review: slice-werkzeug-zellenlaenge-hat-einen-sensor (Commit df0a34f6)

Rolle Reviewer · Bezug LH-QA-01 · AGENTS.md §3.5/§3.6/§3.7 · MR-025

## Findings

- **LOW** · Maintainability · `harness/sensors/docs-check.md` (Absatz §Modul `structure`, "zwei Regeln; die erste (Zellenlänge: …)")
  · befund: Der Satz nennt die Zellenlängen-Regel die erste, der anschließende Text beschreibt aber die
  `done/`-Regel; die Zellenlänge steht in der `.d-check.yml` an zweiter Stelle und heißt im neuen Absatz
  selbst "die zweite Regel". · verifizierbar: nein · klasse: Ordnungszahl einer Regel widerspricht ihrer Fundstelle

## Geprüft, ohne Befund

- (a) Selektor: Abschnitt `## Sensors (Feedback-Gates)` enthält genau zwei Tabellen (Zeilen 47 und 69, beide `Target`-Kopf); die Traceability-Tabelle liegt in `## Traceability` und trägt keine der Spalten. Beide Tabellen werden gemessen (Sonde: Befund auf README:78 `Tut was`, README:50 `Vertrag`).
- (b) Bestand nachgemessen je Zelle, Zeichen (`wc -m`): `Tut was` max 257, `Vertrag` max 149. Sonde in Wegwerf-Kopie (`:ro`, `--network none`, d-check-Digest aus d-check.mk): 260 grün, 261 rot; 150 grün, 151 rot; mehrbyte-Zeichen zählen je 1; Bestand `0 Befund(e)`; Kopf `Tut was`/`Vertrag` umbenannt: `section-column-missing`. Die Plan-Angabe 257/256 und 149/148 (Plan Z. 49, 109) ist die Grenzlage bei Schwelle = Bestand; der Plan setzt selbst 260/150 (Bestand+3, Z. 69, 98) — Abweichung gedeckt, Plan-Text intern uneinheitlich (Planner-Sache, kein Verhaltensbefund).
- (c) Doku-Absatz: Tabelle, Zahlen mit Kommando (MR-025, "keine Erwartungswerte"), Grenzen (kein Dauer-Wächter, Wachstum statt Kürze, `Bindung` unbegrenzt, Kopf-Umbenennen) stimmen mit der Sonde; "vierte Spalte trägt Werkzeug-Text" bestätigt.
- (d) Ältere v0.76.1-Messungen (docs-check.md Z. 164, 302) vom neuen Absatz nicht fortgeschrieben; der neue Absatz nennt v0.79.0 (= `DCHECK_IMAGE` in d-check.mk).
- (e) Kein `exempt-paths`, kein `hint`, keine Schwellen-Senkung (neue Regel, Verschärfung); `.d-check.yml`-Kommentar trägt nur Zusage/Kopplung/Rang-Zeiger.
