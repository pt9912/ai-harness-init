# Verifikation: Modul `planning` im emittierten Doc-Gate — 2026-10-08

**Rolle:** Verifier (Modul 11). **Gegenstand:** Slice-Plan
`slice-210-planning-modul-im-emittierten-doc-gate` (Welle `welle-emittiertes-doc-gate`), Diff
`git log 9e0c65f6..4de69177`, Review `docs/reviews/2026-10-08-slice-210-review.md`.
**Bezug:** [`MR-054`](../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel),
[`LH-FA-03`](../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7),
[`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3),
[`AGENTS.md`](../../AGENTS.md) §3.6.

Stichproben statt Volllesen: Der Review hat den Diff vollständig gelesen und die Fälle 295 und
569–571 gefahren. Diese Läufe sind hier nicht wiederholt. Selbst gefahren wurden die Läufe, die der
Review nur gelesen hat.

## Verdikte je DoD-Punkt

- **(1) Kriterium 2 und 3 am frisch gebootstrappten Ziel — bestätigt.**
  - Aufbau: `make host-bin`, dann `git init` in ein Scratchpad-Verzeichnis außerhalb des Repos,
    dann `ai-harness-init --name pl <ziel>`. Gemessen mit `make -s docs-check` im Ziel. Das Rezept
    fährt `docker run --rm --network none -v "$(CURDIR):/repo:ro"`. Der Pin ist
    `DCHECK_DIGEST sha256:e82ef2d2…bba` (v0.84.0), gleich dem in `d-check.mk` dieses Repos.
  - Out-of-the-box → `21 Datei(en) geprüft, 0 Befund(e)`, rc 0.
  - Marker gelöscht, `in-progress/` leer → `1 Befund(e)`, rc 2.
    `roadmap.md:11 … planning-drift kein Slice in docs/plan/planning/in-progress, aber … trägt den Ruhe-Marker „Nichts in Arbeit.“ nicht`.
    **Diese Richtung hatte der Review nur gelesen.**
  - Gegenprobe ohne `planning` in `modules:` mit demselben Zustand → `0 Befund(e)`, rc 0.
  - Slice in `in-progress/`, Marker steht → `1 Befund(e)`, rc 2, `planning-drift … trägt den Ruhe-Marker — die Sektion muss die Arbeit benennen`.
    Ohne Modul → `0 Befund(e)`, rc 0.
  - Konsistenter Zustand (Slice da, Marker weg) → `0 Befund(e)`. Das Modul meldet also nicht
    pauschal.
  - Die Zahlen stehen mit Kommando in der Message von `f9fa9e13` (MR-051). Im Plan stehen sie
    noch nicht; das ist Sache der Closure.
- **(2) Verkörpert im Emissions-Zweig — bestätigt.**
  - `modules:` trägt `planning`. Der Block `planning:` hat `roadmap`, `heading` und `marker`.
    `InjectRoadmapRuheMarker` ist im Roadmap-Zweig verdrahtet. Im Ziel steht der Marker in Zeile 21
    unter `## Offene Wellen` (Zeile 11) vor `## Nächste Wellen` (Zeile 25).
  - Die vier Wächter existieren: `grep -n 'func Test…' internal/emit/*_test.go` →
    `emit_test.go:24,123,162`, `neutralisierung_test.go:162`.
  - Rot-Beleg für die zwei `full-smoke`-Fälle:
    `make mutate MUTATE_CASES='514-… 572-…'` → `2 ok, 0 Befund(e)`, EXIT 0, 417,98 s.
    - `572 -> FEHLER — planning-Gegenbeispiel rot`
    - `514 -> FEHLER — Zellenlaenge-Gegenbeispiel (Vertrag) rot`
  - Der Grund des Rots ist der behauptete: Die Meldung ist der `# expect:`-Text des Falls. Grenze:
    Bei 572 fällt die Stufe schon am **ersten** Gegenbeispiel (Slice + Marker). Die Richtung
    „Marker fehlt" ohne Modul deckt im Fall nichts. Gedeckt ist sie durch die manuelle Gegenprobe
    oben.
- **(3) `make gates` grün, `make full-smoke` grün, Review — bestätigt (Closure-Teil offen, Planner).**
  - `make gates` auf HEAD `4de69177` → EXIT 0, 168,37 s, `d-check: 2466 Datei(en) geprüft, 0 Befund(e)`.
    Der Stempel `gates-passed.head` stand vorher auf `192ac0a1`; nach dem Lauf steht er auf HEAD.
  - `full-smoke` ist unmutiert grün: Der Grün-Vorlauf des Mutate-Laufs läuft in einer isolierten
    Kopie desselben HEAD und meldet `1 full-smoke 148.48`. Der Lauf hätte sonst abgebrochen.
    Grenze: Welche zwei „Bootstrap-Formen" die DoD meint, nennt der Plan nicht. Belegt ist der
    eine Lauf `make full-smoke`, der Lauf `make full-smoke-host` nicht.
  - Der Review-Report liegt vor.
  - Closure-Notiz, Register und Risiko-Ausgänge sind offen. Das ist Planner-Arbeit (§3.10).

## Plan-vs-Code (beide Richtungen)

- **§1, Pfad `v6.7.2` — Plan-Befund, bestätigt.** Das Kommando in §1 zeigt auf
  `.harness/baseline/v6.7.2/…`, und `ls .harness/baseline/` zeigt nur `v6.17.0`. Das Kommando
  läuft also ins Leere. Die Aussage selbst hält am gültigen Stand:
  `grep -c 'Nichts in Arbeit' .harness/baseline/v6.17.0/templates/docs/plan/planning/roadmap.template.md`
  → **0**.
- **§4, Rückführung `in-progress → next` — nicht eingetreten, bestätigt.** Das Grün verlangte
  eine Änderung an der Emission (`InjectRoadmapRuheMarker`), nicht an der vendored Vorlage. Der
  Diff berührt nichts unter `.harness/` (`git log --stat 9e0c65f6..4de69177`).
- **§4, Rückführung `in-progress → open` — nicht eingetreten.** Die Invariante ist stabil
  herstellbar: grüner Start, beide Richtungen rot, beide Gegenproben grün. Sie wandert mit dem
  Lifecycle, und das ist Risiko 2.
- **§6, Risiko 2 — eingetreten, am realen Ziel belegt.** Im Ziel lagen `next/slice-probe.md` und
  ein Commit mit lokaler Identität vor. Dann
  `make slice-mv SLICE=slice-probe TO=in-progress` → `slice-mv: slice-probe.md next/ -> in-progress/ (reiner Move)`.
  Der Marker steht danach unverändert (`grep -c '^Nichts in Arbeit\.$' roadmap.md` → 1), und
  `make docs-check` meldet `1 Befund(e)`, `planning-drift`.
  - Die Arbeit liegt damit beim Adopter. Benannt ist sie an zwei Stellen: im Kopfkommentar der
    emittierten `.d-check.yml` und im Benutzerhandbuch („`make slice-mv` ändert die Roadmap nicht").
  - Die emittierte `.claude/commands/implement-slice.md` nennt den Schritt nicht.
    `grep -rln 'Nichts in Arbeit\|Ruhe-Marker'` im Ziel ohne `.harness`/`.git` findet nur
    `roadmap.md` und `.d-check.yml`. Ein Agent im Ziel erfährt ihn erst aus dem Rot.
  - Den Ausgang setzt der Planner: Folge-Slice oder Evidenz zu
    `BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch`.
- **Gebautes ohne Plan-Zeile:** `docs/user/benutzerhandbuch.md`, `docs/user/e2e-abdeckung.md`
  (erzeugt) und die nachgezogenen sed-Anker der Fälle 295 und 514.
  - Das Handbuch deckt [`AGENTS.md`](../../AGENTS.md) §6 Schritt 7 (öffentlicher Vertrag des
    Ziels). Die beiden anderen sind Folge der Listen-Änderung.
  - Keine Bedeutungsabweichung.
- **Plan-Zeile ohne Gebautes:** keine. Die Nicht-Emissions-Zeilen (`harness/conventions*`) fallen
  mit der Zweig-Wahl weg.

## Offene Punkte für den Planner

- §1 trägt den toten Pfad `v6.7.2`. Ob er vor dem `git mv` nach `done/` nachgezogen wird,
  entscheidet der Planner (§3.11).
- Ausgang für Risiko 2 (eingetreten, s. oben). Risiko 1 hat sich erledigt: Der Emissions-Zweig
  wurde mit Messung gewählt. Risiko 3 entscheidet der Planner.
- DoD (3) „beide Bootstrap-Formen" ist im Plan nicht aufgelöst. Belegt ist ein grüner
  `full-smoke`, der Lauf `full-smoke-host` nicht.

## Negativbefunde

- **Pin und Hermetik:** Digest gleich dem Dogfood-Pin, `--network none`, `:ro` — ohne Befund.
- **Mutationsfälle 572 und 514:** Beide färben `full-smoke` mit der `# expect:`-Meldung rot —
  ohne Befund.
- **Gate-Lauf:** `make gates` grün auf HEAD — ohne Befund.
