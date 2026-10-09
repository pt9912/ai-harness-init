# Slice slice-kotlin-root-bootstrap: Kotlin als One-Shot am Root

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese Datei liegt — eines von
`open/`, `next/`, `in-progress/`, `done/`. Er wechselt nur durch `git mv`, siehe Baseline-Regelwerk
`modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** [welle-kotlin-skelett](../welle-kotlin-skelett.md).

**Bezug:** [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) · [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) · [ADR-0088](../../adr/0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md). Grundlage: Vorklärung
`2026-10-08-kotlin-welle-architect-vorklaerung`.

**Berührte Spec-Stellen:** —

**Verantwortlich:** Implementer (pt9912).

**Autor:** Planner. **Datum:** 2026-10-09.

---

## 1. Ziel und Abgrenzung

**Ziel:** `ai-harness-init --lang kotlin [--arch hexslice]` bootstrappt ein Repo am Root in einem
Schritt, wie die cpp-Form.

**Ausdrücklich NICHT in diesem Slice:**

- Renderer und Arch-Gate — liefern `slice-kotlin-flaches-skelett` und
  `slice-kotlin-hexslice-mit-arch-gate`; dieser Slice verdrahtet nur den Root-Pfad.
- Handbuch-Nachzug — gehört in den Release-Schnitt.

## 2. Definition of Done

- [x] `--lang kotlin` und `--lang kotlin --arch hexslice` am Root, mit Unit-Tests
      ([`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen)).
- [x] `make full-smoke`: Root-Bootstrap `--lang kotlin --arch hexslice`, im Ziel `make gates` grün
      einschließlich Arch-Gate; Stufe mit `e2e_abdeckung`-Kopfzeile; Laufzeit-Zuwachs gemessen, in §7.
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor (`.harness/skills/reviewer.md`), kein Self-Review.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — oder in §7 notiert, dass keine Beobachtung anfiel.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen prüft die Closure von `welle-kotlin-skelett`; nach dem Move gefahren, §7.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `cmd/ai-harness-init/`, `internal/gen/` (+ Tests) | update | Root-Pfad für `kotlin` — gemessen: der One-Shot verdrahtet `kotlin` am Root ohne Code-Änderung (`wireLang` mit Pfad `.` ist sprach-agnostisch); geändert sind nur die Tests (`TestRun_BootstrapKotlinRoot`, zwei Kotlin-Varianten in `TestEmittierteDateienTragenNurImZielAufloesendeKennungen`) und die Mutationsfälle 626–628 |
| `harness/tools/full-smoke.sh`, `docs/user/e2e-abdeckung.md` | update | Stufe, erzeugte Sicht |

## 4. Trigger

**Start** (`next` → `in-progress`): `slice-kotlin-hexslice-mit-arch-gate` liegt in `done/`.

**Rückführungen:**

- `in-progress` → `next`: der Root-Pfad verlangt sprach-spezifische Verzweigung außerhalb von
  `internal/gen/` — eigener Schnitt.
- `in-progress` → `open`: das Ziel fährt `make gates` am Root nicht grün, ohne dass der Renderer geändert
  wird — zurück an den Renderer-Slice.

## 5. Closure-Trigger

DoD vollständig, Root-Stufe in `make full-smoke` grün, Closure-Notiz mit Lerneintrag.

## 6. Risiken und offene Punkte

- JVM/Gradle verlängern `make full-smoke` je Stufe um einen `docker build` mit
  Dependency-Auflösung — **Ausgang:** entfallen — gemessen und mit Lage benannt (§7): rund +39,6 s
  bei kaltem Gradle-Layer, Stufendauer 5 s bei warmem; die Klasse trägt
  [MR-089](../../../../harness/conventions.md#mr-089), keine Folge.

## 7. Closure-Notiz

- **Was hat funktioniert:** Der One-Shot verdrahtet `kotlin` am Root ohne Produktcode-Änderung
  (`wireLang` mit Pfad `.` ist sprachunabhängig); keine Rückführung aus §4 trat ein. Der Root-Arch-Zahn
  färbt mit `Greeting.kt:4: core-impurity: Kern importiert app.adapters.driven.notify.StdoutNotifier`;
  die Fälle 626–628 nennen nach `a96c30e0` den direkt lesenden Test, `make mutate` → `3 ok, 0 Befund(e)`
  (Verifikation `2026-10-09-slice-kotlin-root-bootstrap-verifikation`).
- **Laufzeit (DoD 2, [MR-089](../../../../harness/conventions.md#mr-089)):** Wanduhr um den Lauf —
  `start=$(date +%s.%N); make full-smoke > LOG 2>&1; end=$(date +%s.%N); echo "$end - $start" | bc`;
  `full-smoke.sh` gibt keine Gesamtdauer aus. Mit der Stufe 250,55 s, ohne 210,95 s (nur
  `harness/tools/full-smoke.sh` aus `c6e01934` im sonst neuen Baum), Δ ≈ +39,6 s; ein zweiter Lauf
  ohne die Stufe 211,38 s, Streuung ≈ 0,4 s. Die Stufe meldet selbst 51 s; warum Δ kleiner ist, ist
  nicht belegt. Lage: gleiche Maschine, 2026-10-09, Images lokal, Basis-Cache warm, Gradle-Layer
  kalt (Abhängigkeiten im Lauf neu aufgelöst); Variante `--lang kotlin --arch hexslice` am Root.
  Gegenmessung des Verifiers bei warmem Gradle-Layer:
  `/usr/bin/time -f 'FULLSMOKE_SECONDS=%e' make full-smoke` → `218.54`, Stufe 5 s, ein Lauf. Die
  +39,6 s gelten nur bei kaltem Gradle-Layer, nicht je Lauf. Ungemessen: `--lang kotlin` ohne
  `--arch` am Root, ein komplett kalter Host.
- **Was ging anders als geplant:** Geändert sind nur Tests, Fälle und die Stufe, kein Produktcode
  (§3 nachgezogen). `--lang kotlin` ohne `--arch` am Root deckt allein der Unit-Test; Stufen-Kopfzeile
  und Testkopf nennen das. Die `cmd/`-Verdrahtung ist sprachunabhängig und hat keinen Kotlin-eigenen
  Fall; ein Bruch des Pfads `.` färbt `TestRun_BootstrapKotlinRoot` und
  `TestRun_BootstrapMeldetNeueTargets` gemeinsam — Grenze im Testkopf, vom Verifier bestätigt.
- **Steering-Loop-Eintrag:** geschärfte Regel, gezählt, nicht verkörpert — die Cache-Lage einer
  Laufzeit-Aussage nennt die Schicht, die den Preis trägt (hier der Gradle-Dependency-Layer), getrennt
  vom Basis-Cache; „Basis-Cache warm“ ließ eine Kalt-Layer-Zahl als Wert je Lauf stehen. Beleg in
  `BEO-ALL/kosten-einer-emittierten-pruefung-im-ziel-ungemessen`; die Schärfung von
  [MR-089](../../../../harness/conventions.md#mr-089) ist Architect-Sache.
- **Beobachtungs-Register (`../observations/`):** Belege in
  `BEO-ALL/mutations-fall-nennt-einen-test-die-mutation-faerbt-mehrere` (LOW-1, verkörpert) ·
  `BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht` (LOW-2, geplant `slice-181`) ·
  `BEO-ALL/zahl-in-commit-message-ohne-kommando` (LOW-3, 2×, offen) ·
  `BEO-ALL/kosten-einer-emittierten-pruefung-im-ziel-ungemessen` (INFO-2 mit Verifier-Gegenmessung,
  verkörpert). Benannt, nicht gezählt: INFO-1 — der Root-Arch-Zahn hat keine Kotlin-eigene
  Quell-Stelle, die Kopfzeile sagt nicht mehr zu als gemessen. Kein Eintrag erreicht mit diesem Slice
  3× ohne Ausgang.
- **Folge-Slices:** keine.
- **Paarungen geprüft am 2026-10-09:** (a) kein Eintrag in §7 trägt das Zielort-Feld · (b) keine
  Folge-Slices genannt; die Register-Kennung `slice-181` liegt unter `open/` · (c) die vier hier
  genannten `BEO-ALL/…` existieren, je `evidence/*.md` ≥ 1; zweite Hälfte über das Register: 2
  Verzeichnisse ohne Beleg, namentlich `cpp-skelett-erfuellt-die-messmethode-von-lh-qa-02-nicht` und
  `einstiegs-datei-weicht-von-der-pflichtgliederung-ab`; nicht als getragen behauptet (Kommando:
  Schleife über `BEO-ALL/*/evidence/*.md`, `close-welle.md` Schritt 3).
- **Risiken aus §6:** Ausgang steht in §6.

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** `*` (`ALL`); das Skelett liegt in `internal/gen/` und
`harness/tools/full-smoke.sh`, für die die Modus-Deklaration keine eigene Sub-Area führt.

**Vorgelagert — offene Beobachtungen sichten** (Zähler je
`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence | wc -l`, gelesen 2026-10-09):
`neuer-waechter-ohne-mutations-fall` — 19, geplant; jeder neue Kotlin-Test ist ein neuer Wächter ·
`pin-digest-ohne-waechter` — 4, geplant; Kotlin pinnt per Tag ([ADR-0088](../../adr/0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md) Festlegung 2) ·
`cpp-skelett-erfuellt-die-messmethode-von-lh-qa-02-nicht` — offen; trifft das Kotlin-Image gleich ·
`lokaler-full-smoke-scheitert-auf-macos-host` — 2, offen; neue full-smoke-Stufen erben ihn.

**Modus:** alle berührten Sub-Areas GF.
