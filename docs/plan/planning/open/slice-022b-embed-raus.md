# Slice slice-022b: Embed raus — gefetchte Baseline ist einzige Template-Quelle

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.0/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-02-fetch-und-readme](../welle-02-fetch-und-readme.md).

**Bezug:** [`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3), [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten), [`ADR-0005`](../../../../docs/plan/adr/0005-ziel-repo-distribution.md), [`MR-008`](../../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert).

**Autor:** Claude (Pair-Session). **Datum:** 2026-07-20.

---

## 1. Ziel

Das Embed-Duplikat **abräumen**: `internal/emit` bezieht die Templates aus der von
[slice-022a](slice-022a-baseline-fetch.md) gefetchten Baseline, `internal/emit/skel`
(15 Dateien) wird **gelöscht**, und der Drift-Wächter `test/skel-drift.bats` entfällt
**ersatzlos** — er bewachte genau die Doppelung, die es dann nicht mehr gibt. Damit ist
die Folgepflicht aus [`ADR-0005`](../../../../docs/plan/adr/0005-ziel-repo-distribution.md) („Embed entfernen") eingelöst und es bleibt
**eine** Quelle.

## 2. Definition of Done

- [ ] `internal/emit/skel` ist **entfernt** (15 Dateien) und `//go:embed skel` aus `internal/emit/templates.go` verschwunden — **kein** zweiter Template-Pfad bleibt zurück.
- [ ] [`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) weiterhin erfüllt: die zweiklassige Ablage (Singletons → `.md` mit gestripptem Hinweis-Block und gestempeltem Namen; Wiederkehrende → verbatim `.template.md`; Set-Index-README nie emittiert) entsteht **unverändert**, nur aus der gefetchten Quelle. Kein Verhaltensverlust gegenüber slice-003 — die bestehenden `templates_test.go`-Fälle bleiben gültig.
- [ ] `test/skel-drift.bats` ist **gelöscht** und in [`MR-008`](../../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert)-Manier als bewusst entfernt behandelt: die Referenzen darauf sind bereinigt bzw. über `codepaths.ignore-refs` deklariert — **kein** `codepath-missing`, aber auch kein stiller Tombstone.
- [ ] [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten): das Binary wird um den eingebetteten Baum kleiner; der Bootstrap braucht weiterhin nur `git + docker`.
- [ ] `make gates` grün — insbesondere `make test` **ohne** die drei entfallenen Drift-Tests, ohne dass ein anderer Test ersatzlos Deckung verliert.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/emit/templates.go` | update | Quelle: `embed.FS` → `fs.FS` über die gefetchte Baseline; `planTemplates` walkt den realen Baum |
| `internal/emit/skel` | entfernt | Embed-Duplikat; Folgepflicht [`ADR-0005`](../../../../docs/plan/adr/0005-ziel-repo-distribution.md) |
| `test/skel-drift.bats` | entfernt | bewachte die Doppelung, die entfällt — ersatzlos, kein Nachfolge-Sensor nötig |
| `.d-check.yml` | update | den entfernten Test als Tombstone deklarieren (`codepaths.ignore-refs`, [`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile)-Muster) |
| Emit-Tests | update | Fixture-Baum statt Embed; die [`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)-Fälle bleiben inhaltlich unverändert |

## 4. Trigger

[slice-022a](slice-022a-baseline-fetch.md) in `done/` — vorher gibt es keine gefetchte
Quelle, aus der `emit` lesen könnte. Bis dahin **blockiert**.

Rückführungen: `in-progress → next`, wenn Umverdrahtung und Test-Umbau getrennt gehören.
`in-progress → open`, wenn sich zeigt, dass die gefetchte Baseline die von
[`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) verlangte In-Scope-Abgrenzung nicht hergibt (die heutige
Vollständigkeits-Achse von `skel-drift.bats` nimmt `project-readme.template.md` und
`.harness/skills/*` ausdrücklich aus — diese Grenze muss die neue Quelle ebenso ziehen).

## 5. Closure-Trigger

DoD vollständig + Review konform + Closure-Notiz → nach `done/`.

## 6. Risiken und offene Punkte

- **Deckungsverlust beim Löschen des Drift-Wächters:** seine *Gleichheits*-Achse wird
  gegenstandslos (keine zwei Quellen mehr), seine *Vollständigkeits*-Achse aber prüfte,
  ob ein bei einem Baseline-Bump **neu** hinzugekommenes Template auch emittiert wird.
  Diese Frage überlebt die Umstellung — sie wandert in die Emit-Tests, statt ersatzlos zu
  verschwinden. Das ist der Punkt, an dem „entfällt ersatzlos" zu billig wäre.
- Der Embed ist heute **gate-relevant**: `make test` fährt drei bats-Fälle darüber. Fallen
  sie, muss der Ersatz benannt sein — sonst sinkt die Prüftiefe unbemerkt
  ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)-Geist: kein stilles Grün).
- Die `.dockerignore`-Grenze (`.harness` ist im Go-Build-Kontext **nicht** sichtbar, darum
  lief der Drift-Test in bats) gilt weiter: liest `emit` zur Laufzeit aus der gefetchten
  Baseline, ist das unkritisch — ein *Test*, der den Baum braucht, gehört weiter nach bats.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example).
