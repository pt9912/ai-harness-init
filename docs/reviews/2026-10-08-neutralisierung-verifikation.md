# Verifikation — slice-neutralisierung-haelt-ihren-wortlaut-am-gepinnten-stand

**Gegenstand:** Commits `604a5aad`, `1181ce2f`, `7a062230` gegen den Slice-Plan (Stand in
`in-progress/`) und den Review-Report `2026-10-08-neutralisierung-review.md`. **Rolle:** Verifier
(Modul 11), frischer Kontext. **Datum:** 2026-10-08. **Bezug:**
[`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3),
[`AGENTS.md`](../../AGENTS.md) §3.6/§3.10.

Bruchproben liefen in Kopien (`git archive HEAD`) unter dem Scratchpad; der Arbeitsbaum blieb
unberührt.

## Verdikte je Liefer-DoD-Punkt

- **DoD 1 — `NeutralizeRoadmap` … entfallen; Roadmap gate-sicher: nicht bestätigt (Wortlaut), Wirkung bestätigt.**
  - Der Code an `7a062230` führt `NeutralizeRoadmap`, `roadmapDoneLink`, den Aufruf
    (`internal/emit/templates.go:465`), `TestNeutralizeRoadmap`, `TestTemplates_RoadmapGateSafe` und
    den Mutations-Fall 29 wieder — Antwort auf Review-MEDIUM-1 (`COURSE_TAG` älterer Stände). Der
    DoD-Punkt und §1 („`NeutralizeRoadmap` … entfällt") sagen das Gegenteil; die Abnahme verschiebt
    sich, das ist Planner-Sache (§3.10), nicht durch den Implementer geschlossen.
  - Gate-Sicherheit am Pin: `make full-smoke` → EXIT 0 (189 s).
  - Das Rot-Werkzeug des Punkts („rot, 0 Treffer für `roadmapDoneLink`") gibt es in dieser Form
    nicht mehr: `test/neutralisierung-marker.bats` erwartet jetzt `roadmapDoneLink:0`.
  - Fixture gegen den Kurs-Klon (nur gelesen):
    `git -C /Development/KI/ai-harness-course show v6.5.0:lab/templates/docs/plan/planning/roadmap.template.md | sed -n 107p`
    gegen `roadmapAlterStand` per `diff` → byte-gleich. Marker-Zeile an `v3.5.2` (Z. 62), `v6.0.0`
    (Z. 107), `v6.5.0` (Z. 107), an `v6.8.0` keine — wie der Kommentar zu `roadmapDoneLink` sagt.
  - **Grenze:** kein Bootstrap mit `COURSE_TAG=v6.5.0`. Der Fetch braucht das Release-Asset
    `lab-regelwerk.zip` zu `v6.5.0`; lokal liegt keines
    (`find /Development /home/db -name 'lab-regelwerk*.zip'` → leer), und ein aus dem Klon
    gebautes Ersatz-ZIP wäre eine Fixture, nicht die reale Quelle. Ob ein älterer Tag sonst
    gate-sicher emittiert, ist weiter ungemessen.

- **DoD 2 — Marker-Fall am vendored Baum, Rot-Werkzeug in `test/mutations/`: bestätigt.**
  - `make mutate MUTATE_CASES='29-roadmap-nicht-neutralisiert 561-neutralisierungs-marker-verfehlt-den-gepinnten-stand 562-wortlaut-ersetzung-ausserhalb-der-tabelle'`
    → `mutate: 3 ok, 0 Befund(e)` (561 → bats-Fall 2 rot, 562 → `TestWortlautNeutralisierungen_EineTabelle` rot, 29 → `TestTemplates_RoadmapGateSafe` rot).
  - Meldung selbst gelesen (561 in Kopie, `make test-bats BATS_TARGET=test/neutralisierung-marker.bats`):
    `carveoutsDoneRefOld: 0 Treffer in docs/plan/planning/README.template.md (v6.17.0) — erwartet 1`;
    Fälle 1 und 3 bleiben `ok`. Das `expect:` nennt den Testnamen, nicht die Meldung (Review-INFO-1,
    bleibt).

- **DoD 3 — `make gates` grün:** einmal nach dem Commit dieses Berichts, Ergebnis im Bericht an den Planner.

- **DoD 4 — Review liegt vor:** bestätigt (`2026-10-08-neutralisierung-review.md`, anderer Kontext).

## go/ast-Test (`TestWortlautNeutralisierungen_EineTabelle`), selbst gebrochen

- Raw-String-Konstante + `strings.ReplaceAll(s, rawMarker, "")` in einer neuen Funktion (eine der
  Review-HIGH-1-Formen) → rot:
  `templates.go:1140: strings.ReplaceAll in neutralisiereRaw bezieht seinen Marker nicht aus WortlautNeutralisierungen`.
- **Finding (Zusage breiter als Sensor, LOW):** derselbe Aufruf über einen Import-Alias
  (`strs "strings"`, `strs.ReplaceAll(s, aliasMarker, "")`) → `ok`. Der Doc-Kommentar sagt „jeder
  strings.Replace/ReplaceAll/NewReplacer-Aufruf"; die Grenz-Zeile nennt regexp und eigene Schleife,
  nicht Alias-Import oder Funktionswert (`f := strings.ReplaceAll`, nicht gefahren). Entweder die
  Grenze nennen oder über `file.Imports` auflösen.

## Plan vs. Code

- **Gebaut ohne Plan:** die exportierte Tabelle `WortlautNeutralisierungen()` samt
  `neutralisiereWortlaut` (öffentliche API von `internal/emit`), `internal/emit/neutralisierung_test.go`
  (go/ast-Strukturtest), Mutations-Fall 562, die Wiederherstellung von `NeutralizeRoadmap` mit
  `ERWARTUNG roadmapDoneLink:0`. §3 nennt weder die neue Testdatei noch die Tabelle.
- **Plan ohne Code:** §1-Ziel und DoD 1 („entfällt") — siehe oben.
- **Risiko §6** (Go-`test`-Stage sieht `.harness/` nicht): eingetreten, getragen von
  `test/neutralisierung-marker.bats` in `make test` — Ausgang setzt der Planner.

## Offene Punkte für den Planner

- DoD 1 und §1 an die Wiederherstellung anpassen oder sie zurückweisen; das `COURSE_TAG`-Opt-in als
  Abgrenzung oder Ziel aufnehmen.
- Das LOW-Finding Alias-Import (Grenze nennen oder schließen).

## Negativbefunde

- Fixture: byte-gleich zur realen Vorlage an `v6.5.0`.
- Wächter-Bindung: alle drei Fälle des Slice werden rot, über der richtigen Meldung.
