# Slice slice-csharp-skelett: C# als Sprachskelett mit Code-Gate und Guard

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese Datei liegt — eines von
`open/`, `next/`, `in-progress/`, `done/`. Er wechselt nur durch `git mv`, siehe Baseline-Regelwerk
`modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** `welle-sprachprofile-java-python-csharp` — dritter Slice im Reihenfolge-Vorschlag.

**Bezug:** [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) ·
[`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) ·
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) ·
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit). Die ADR des Architect für
C# (Toolchain, Pins, Gate-Targets, Arch-Unterstützung) ist die Entscheidungsgrundlage; ihre Kennung
steht hier, sobald sie `Accepted` ist.

**Berührte Spec-Stellen:** [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4); `ARC-009`, `ARC-010` (über die ADR, soweit sie Layout und
Arch-Achse berührt).

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-10-17.

---

## 1. Ziel und Abgrenzung

**Ziel:** `add-lang csharp` rendert ein C#-Skelett mit Code-Gate-Fragment und Guard-Set nach der ADR,
das im gebootstrappten Ziel `make gates` grün fährt — ohne Host-.NET.

**Vorbedingung — der Architect schreibt zuerst.** Der Architect legt vor dem Start eine ADR für C#
fest: SDK-Image und Pins, Projekt-Form, Gate-Targets und Lint-/Format-Werkzeug, Modul-Schnitt und
welche Layouts mit welcher a-check-Auflösung getragen sind. Dieser Plan schreibt keine ADR und
entscheidet nichts davon.

**Hinweis zur Wiederverwendung — nicht entschieden.** `internal/gen/kotlin.go` zeigt das Muster
(`composeSkeleton`, Rollen-Renderer, Image-Tag-Pin mit Knopf `SKEL_<LANG>_VERSION`,
`blockedByLang`, `gen.CodeGateFragment`; Entscheidungsgliederung in
[ADR-0088](../../adr/0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md)). Eigen bei C#:
Namensraum und Verzeichnis sind nicht gekoppelt, anders als Paket gleich Verzeichnis bei Kotlin; ob
a-check für C#-Importe eine Auflösung trägt, ist nicht gemessen — beides gehört in die ADR.

**Ausdrücklich NICHT in diesem Slice:**
- `java` und `python` — übernehmen `slice-java-skelett` und `slice-python-skelett`.
- Layouts und Arch-Gate über das hinaus, was die C#-ADR festlegt — ohne ADR wäre ein Layout eine
  ungetragene Entscheidung; trägt die ADR mehr, als §2 in drei Liefer-Punkten fasst, geht der Slice
  zurück zum Schneiden (§4).
- Ein Freshness-Werkzeug für den C#-Pin — anderer Vorgang; der Vollständigkeits-Wächter für
  kuratierte Listen steht als Zeile in *Nächste Wellen* der Roadmap.
- Release, Handbuch-Nachzug — gehören in den Release-Schnitt (§6 der Welle).
- `spec/architecture.md` — Folgepflicht aus der ADR, soweit sie eine auslöst, nicht Gegenstand dieses
  Skelett-Slice.

## 2. Definition of Done

- [ ] Renderer `csharp` in `internal/gen/` nach der ADR: Gerüst, Gate-Stages `test`/`lint`/`build`
      (oder die Stages, die die ADR festlegt), Image-Pin mit Knopf `SKEL_CSHARP_VERSION` →
      `gen.DefaultVersion("csharp")`; Test Fragment↔Stages nach dem Muster der Kotlin- und C++-Tests,
      einmal rot gesehen (Stage entfernt); `blockedByLang("csharp")` mit Kopplung an
      `gen.SupportedLangs`
      ([`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4),
      [`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren)).
- [ ] `make full-smoke`: `add-lang csharp` ins Mono-Repo, Skelett-Dateien liegen, `make gates` grün mit
      Beleg, dass das C#-Code-Gate lief, und der Guard blockt die Host-Toolchain;
      `e2e_abdeckung`-Kopfzeile nennt die Sprache und eine Teilmessung an derselben Stelle,
      `docs/user/e2e-abdeckung.md` neu erzeugt; Laufzeit-Zuwachs vorher/nachher mit Image-Lage und
      Variante ([`MR-089`](../../../../harness/conventions.md#mr-089)).
- [ ] Hilfetext nennt `csharp` und `SKEL_CSHARP_VERSION` (öffentlicher Vertrag), Test in
      `cmd/ai-harness-init/main_test.go`.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor (`.harness/skills/reviewer.md`),
      kein Self-Review.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — oder in §7 notiert, dass keine
      Beobachtung anfiel.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen prüft die Closure von `welle-sprachprofile-java-python-csharp`; nach dem
      Move gefahren, §7.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/gen/gen.go`, `internal/gen/csharp.go` | update / neu | `profiles()`, `langArchs()`, `DefaultVersion`; Gerüst und Fragment |
| `internal/gen/csharp_test.go` | neu | Fragment↔Stages, Gerüst-Inhalt |
| `internal/emit/enforce.go` (+ Test) | update | `blockedByLang("csharp")` |
| `cmd/ai-harness-init/main.go`, `main_test.go` | update | Hilfetext nennt Sprache und Versions-Knopf |
| `harness/tools/full-smoke.sh`, `docs/user/e2e-abdeckung.md` | update | Stufe, erzeugte Sicht |
| `internal/gen/gen_test.go`, `internal/emit/zeilenenden_test.go` | update | Sprach-Listen um `csharp` |
| `test/mutations/` | neu / update | ein Fall je neuem Wächter ([`MR-071`](../../../../harness/conventions.md#mr-071)) |

## 4. Trigger

**Start** (`next` → `in-progress`): `welle-sprachprofile-java-python-csharp` eröffnet, die ADR für
C# `Accepted`, WIP-Slot frei. Reihenfolge-Vorschlag: nach `slice-python-skelett` — die Kante ordnet
(dieselben Dateien), sie trägt nicht.

**Rückführungen — vorab benennen:**
- `in-progress` → `next`: die ADR trägt mehr Layouts oder Gate-Targets, als drei Liefer-Punkte fassen
  — je Layout ein eigener Slice.
- `in-progress` → `open`: Toolchain oder Lint-Werkzeug der ADR laufen mit dem gepinnten Stand nicht
  grün (Re-Evaluierungs-Trigger der ADR) — Architect.

## 5. Closure-Trigger

DoD vollständig, die C#-Stufe in `make full-smoke` grün, Closure-Notiz mit Lerneintrag.

## 6. Risiken und offene Punkte

- Image-Pull und Paket-Wiederherstellung verlängern `make full-smoke` — **Ausgang:** bei der
  Closure, Form nach [`MR-089`](../../../../harness/conventions.md#mr-089) (Image-Lage und Variante
  der Messung).
- Das Image-Muster misst die Reproduzierbarkeit nicht nach [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit): kein Lauf vergleicht zwei Bauten
  desselben Tags (`BEO-ALL/cpp-skelett-erfuellt-die-messmethode-von-lh-qa-02-nicht`) —
  **Ausgang:** bei der Closure.
- a-check trägt die Auflösung für das C#-Layout nicht, wie die ADR sie annimmt (Namensraum ungleich
  Verzeichnis) — **Ausgang:** bei der Closure; Gegenbeispiel rot gesehen oder Layout aus dem Slice
  genommen.

## 7. Closure-Notiz

<!-- Erst bei der Closure füllen. -->

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** `*` (`ALL`); das Skelett liegt in `internal/gen/` und
`harness/tools/full-smoke.sh`, für die die Modus-Deklaration keine eigene Sub-Area führt.

**Vorgelagert — offene Beobachtungen sichten** (Zähler je
`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence | wc -l`, gelesen 2026-10-17):
`neuer-waechter-ohne-mutations-fall` — 20, geplant; jeder neue Test ist ein neuer Wächter ·
`pin-digest-ohne-waechter` — 8, verkörpert; der C#-Pin steht unter diesem Regime ·
`kosten-einer-emittierten-pruefung-im-ziel-ungemessen` — 4, verkörpert ([`MR-089`](../../../../harness/conventions.md#mr-089)) ·
`lokaler-full-smoke-scheitert-auf-macos-host` — 3, verkörpert; die neue Stufe erbt es ·
`cpp-skelett-erfuellt-die-messmethode-von-lh-qa-02-nicht` — offen, ohne Beleg-Verzeichnis; trifft das
C#-Image gleich ·
`emittiertes-lint-rezept-uebergibt-die-go-version-nicht` — 1, offen; das C#-Lint-Rezept ist daran zu
prüfen ·
`emittiertes-gate-am-gemischten-root-baut-das-dockerfile-einer-anderen-sprache` — 1, offen; der
Slice fährt den Mono-Repo-Pfad, nicht den gemischten Root; ein Fund dort wäre der zweite Beleg ·
`handbuch-sprachbaum-ohne-sensor-in-full-smoke` — 1, offen; das Handbuch ist Release-Schnitt, der
Slice berührt den Baum nicht.

**Modus:** alle berührten Sub-Areas GF.
